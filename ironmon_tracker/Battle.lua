Battle = {
	inBattle = false,
	isWildEncounter = false,
	enemyTransformed = false, -- TODO: Handle both enemy battlers
	isGhost = false,

	-- "Low accuracy" values
	battleMsg = 0,
	battler = 0, -- 0 or 2 if player, 1 or 3 if enemy
	battlerTarget = 0,

	-- "High accuracy" values
	attacker = 0, -- 0 or 2 if player, 1 or 3 if enemy
	turnCount = -1,
	prevDamageTotal = 0,
	damageReceived = 0,
	lastEnemyMoveId = 0,
	enemyHasAttacked = false,

	-- "Low accuracy" values
	Synchronize = {
		turnCount = 0,
		battler = -1,
		attacker = -1,
		battlerTarget = -1,
	},
	-- "Low accuracy" values
	CurrentRoute = {
		mapId = 0,
		encounterArea = RouteData.EncounterArea.LAND,
		hasInfo = false,
	},
}

function Battle.update()
	if Program.Frames.lowAccuracyUpdate == 0 and not Program.inCatchingTutorial then
		Battle.updateBattleStatus()
	end

	if not Battle.inBattle then return end

	if Program.Frames.highAccuracyUpdate == 0 then
		Battle.updateHighAccuracy()
	end
	if Program.Frames.lowAccuracyUpdate == 0 then
		Battle.updateLowAccuracy()
	end
end

-- Check if we can enter battle (opposingPokemon check required for lab fight), or if a battle has just finished
function Battle.updateBattleStatus()
	-- BattleStatus [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
	local lastBattleStatus = Memory.readbyte(GameSettings.gBattleOutcome)
	local opposingPokemon = Tracker.getPokemon(1, false) -- get the lead pokemon on the enemy team

	if not Battle.inBattle and lastBattleStatus == 0 and opposingPokemon ~= nil then
		Battle.isWildEncounter = Tracker.Data.trainerID == opposingPokemon.trainerID -- testing this shorter version
		-- Battle.isWildEncounter = Tracker.Data.trainerID ~= nil and Tracker.Data.trainerID ~= 0 and Tracker.Data.trainerID == opposingPokemon.trainerID
		Battle.beginNewBattle()
	elseif Battle.inBattle and lastBattleStatus ~= 0 then
		Battle.endCurrentBattle()
	end
end

-- Updates once every [10] frames. Be careful adding too many things to this 10 frame update
function Battle.updateHighAccuracy()
	Battle.processBattleTurn()
end

-- Updates once every [30] frames.
function Battle.updateLowAccuracy()
	local viewingWhichPokemon = Tracker.Data.otherViewSlot

	Program.updateViewSlots()
	Battle.updateTrackedInfo()

	if viewingWhichPokemon ~= Tracker.Data.otherViewSlot then
		Battle.changeOpposingPokemonView()
	end
end

function Battle.processBattleTurn()
	-- attackerValue = 0 or 2 for player mons and 1 or 3 for enemy mons (2,3 are doubles partners)
	Battle.attacker = Memory.readbyte(GameSettings.gBattlerAttacker)

	local currentTurn = Memory.readbyte(GameSettings.gBattleResults + 0x13)
	local currDamageTotal = Memory.readword(GameSettings.gTakenDmg)

	-- As a new turn starts, note the previous amount of total damage
	if currentTurn ~= Battle.turnCount then
		Battle.turnCount = currentTurn
		Battle.prevDamageTotal = currDamageTotal
		Battle.enemyHasAttacked = false
	end

	local damageDelta = currDamageTotal - Battle.prevDamageTotal
	if damageDelta ~= 0 then
		-- Check current and previous attackers to see if enemy attacked within the last 30 frames
		if Battle.attacker % 2 ~= 0 then
			local enemyMoveId = Memory.readword(GameSettings.gBattleResults + 0x24)
			if enemyMoveId ~= 0 then
				-- If a new move is being used, reset the damage from the last move
				if not Battle.enemyHasAttacked then
					Battle.damageReceived = 0
					Battle.enemyHasAttacked = true
				end

				Battle.lastEnemyMoveId = enemyMoveId
				Battle.damageReceived = Battle.damageReceived + damageDelta
				Battle.prevDamageTotal = currDamageTotal
			end
		else
			Battle.prevDamageTotal = currDamageTotal
		end
	end
end

function Battle.updateTrackedInfo()
	--Ghost battle info is immediately loaded. If we wait until after the delay ends, the user can toggle views in that window and still see the 'Actual' Pokemon.
	local battleFlags = Memory.readdword(GameSettings.gBattleTypeFlags)
	--If this is a Ghost battle (bit 15), and the Silph Scope has not been obtained (bit 13). Also, game must be FR/LG
	Battle.isGhost = GameSettings.game == 3 and (Utils.getbits(battleFlags, 15, 1) == 1 and Utils.getbits(battleFlags, 13, 1) == 0)

	-- Required delay between reading Pokemon data from battle, as it takes ~N frames for old battle values to be cleared out
	if Program.Frames.battleDataDelay > 0 then
		Program.Frames.battleDataDelay = Program.Frames.battleDataDelay - 30 -- 30 for low accuracy updates
		return
	end

	local ownersPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
	local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)

	if ownersPokemon == nil or opposingPokemon == nil then -- unsure if this is ever true at this point
		return
	end

	-- Update useful battle values, will expand/rework this later
	Program.readBattleValues()

	local ownersAbilityId = PokemonData.getAbilityId(ownersPokemon.pokemonID, ownersPokemon.abilityNum)
	-- Always track your own Pokemon's ability once you decide to use it
	Tracker.TrackAbility(ownersPokemon.pokemonID, ownersAbilityId)

	Battle.updateStatStages(ownersPokemon, true)
	--Don't track anything for Ghosts
	if not Battle.isGhost then
		local opposingAbilityId = PokemonData.getAbilityId(opposingPokemon.pokemonID, opposingPokemon.abilityNum)

		Battle.updateStatStages(opposingPokemon, false)
		Battle.checkEnemyEncounter(opposingPokemon)
		Battle.checkEnemyMovesUsed(opposingPokemon)

		-- Auto-track opponent abilities if they go off
		if Battle.checkEnemyAbilityUsed(opposingAbilityId, ownersAbilityId) then
			Tracker.TrackAbility(opposingPokemon.pokemonID, opposingAbilityId)
		end
	end
end

function Battle.updateStatStages(pokemon, isOwn)
	local startAddress = GameSettings.gBattleMons + Utils.inlineIf(isOwn, 0x0, 0x58)
	local hp_atk_def_speed = Memory.readdword(startAddress + 0x18)
	local spatk_spdef_acc_evasion = Memory.readdword(startAddress + 0x1C)

	pokemon.statStages.hp = Utils.getbits(hp_atk_def_speed, 0, 8)
	if pokemon.statStages.hp ~= 0 then
		pokemon.statStages = {
			hp = pokemon.statStages.hp,
			atk = Utils.getbits(hp_atk_def_speed, 8, 8),
			def = Utils.getbits(hp_atk_def_speed, 16, 8),
			spa = Utils.getbits(spatk_spdef_acc_evasion, 0, 8),
			spd = Utils.getbits(spatk_spdef_acc_evasion, 8, 8),
			spe = Utils.getbits(hp_atk_def_speed, 24, 8),
			acc = Utils.getbits(spatk_spdef_acc_evasion, 16, 8),
			eva = Utils.getbits(spatk_spdef_acc_evasion, 24, 8),
		}
	else
		-- Unsure if this reset is necessary, or what the if condition is checking for
		pokemon.statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 }
	end
end

-- If the pokemon doesn't belong to the player, and hasn't been encountered yet, increment
function Battle.checkEnemyEncounter(opposingPokemon)
	if opposingPokemon.hasBeenEncountered then return end

	opposingPokemon.hasBeenEncountered = true
	Tracker.TrackEncounter(opposingPokemon.pokemonID, Battle.isWildEncounter)

	local battleTerrain = Memory.readword(GameSettings.gBattleTerrain)
	local battleFlags = Memory.readdword(GameSettings.gBattleTypeFlags)

	Battle.CurrentRoute.encounterArea = RouteData.getEncounterAreaByTerrain(battleTerrain, battleFlags)

	-- Check if fishing encounter, if so then get the rod that was used
	local gameStat_FishingCaptures = Utils.getGameStat(Constants.GAME_STATS.FISHING_CAPTURES)
	if gameStat_FishingCaptures ~= Tracker.Data.gameStatsFishing then
		Tracker.Data.gameStatsFishing = gameStat_FishingCaptures

		local fishingRod = Memory.readword(GameSettings.gSpecialVar_ItemId)
		if RouteData.Rods[fishingRod] ~= nil then
			Battle.CurrentRoute.encounterArea = RouteData.Rods[fishingRod]
		end
	end

	-- Check if rock smash encounter, if so then check encounter happened
	local gameStat_UsedRockSmash = Utils.getGameStat(Constants.GAME_STATS.USED_ROCK_SMASH)
	if gameStat_UsedRockSmash > Tracker.Data.gameStatsRockSmash then
		Tracker.Data.gameStatsRockSmash = gameStat_UsedRockSmash

		local rockSmashResult = Memory.readword(GameSettings.gSpecialVar_Result)
		if rockSmashResult == 1 then
			Battle.CurrentRoute.encounterArea = RouteData.EncounterArea.ROCKSMASH
		end
	end

	Battle.CurrentRoute.hasInfo = RouteData.hasRouteEncounterArea(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea)

	if Battle.isWildEncounter and Battle.CurrentRoute.hasInfo then
		Tracker.TrackRouteEncounter(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea, opposingPokemon.pokemonID)
	end
end

-- Check if the opposing Pokemon used a move (it's missing pp from max), and if so track it
function Battle.checkEnemyMovesUsed(opposingPokemon)
	if Battle.enemyTransformed then return end

	for _, move in pairs(opposingPokemon.moves) do
		if MoveData.isValid(move.id) then
			local moveUsed = false

			-- Manually track Focus Punch, since PP isn't deducted if the mon charges the move but then dies
			if move.id == 264 and Battle.attacker % 2 == 1 and Battle.battleMsg ~= 0 and Battle.battleMsg == GameSettings.BattleScript_FocusPunchSetUp then
				moveUsed = true
			elseif move.pp < tonumber(MoveData.Moves[move.id].pp) then
				moveUsed = true
			end

			if moveUsed then
				Tracker.TrackMove(opposingPokemon.pokemonID, move.id, opposingPokemon.level)

				if move.id == 144 then -- 144 = Transform
					Battle.enemyTransformed = true
				end
			end
		end
	end
end

-- Checks if ability should be auto-tracked. Returns true if so; false otherwise
function Battle.checkEnemyAbilityUsed(enemyAbility, playerAbility)
	if Battle.Synchronize.turnCount < Battle.turnCount then
		Battle.Synchronize.turnCount = Battle.turnCount
		Battle.Synchronize.battler = -1
		Battle.Synchronize.attacker = -1
		Battle.Synchronize.battlerTarget = -1
	end

	--Levitate doesn't get a message, so it gets checked independently
	if enemyAbility == 26 and Battle.attacker % 2 == 0 then
		local levitateCheck = Memory.readbyte(GameSettings.gBattleCommunication + 0x6)
		if levitateCheck == 4 then
		-- Requires checking gBattleCommunication for the B_MSG_GROUND_MISS flag (4)
			return true
		end
	end

	-- Abilities to check via battler read
	local battlerMsg = GameSettings.ABILITIES.BATTLER[Battle.battleMsg]

	if battlerMsg ~= nil then
		if battlerMsg[playerAbility] and playerAbility == 36 and Battle.battler % 2 == 0 then -- 36 = Trace
			-- Track the enemy's ability if the player's Pokemon uses its Trace ability
			return true
		elseif battlerMsg[enemyAbility] then
			if enemyAbility == 28 then -- 28 = Synchronize
				-- Enemy is using Synchronize on the player, battler is set to status target instead
				if Battle.battler % 2 == 0 then return true end
			elseif Battle.battler % 2 == 1 then
				-- Enemy is the one that used the ability
				return true
			end
		end
	end

	-- Abilities to check for when ally is the battler
	local reverseBattlerMsg = GameSettings.ABILITIES.REVERSE_BATTLER[Battle.battleMsg]

	if reverseBattlerMsg ~= nil then
		if reverseBattlerMsg[enemyAbility] and Battle.battler % 2 == 0 then
			return true
		end
	end

	-- Abilities to check via attacker read
	local attackerMsg = GameSettings.ABILITIES.ATTACKER[Battle.battleMsg]
	local reverseAttackerMsg = GameSettings.ABILITIES.REVERSE_ATTACKER[Battle.battleMsg]

	if attackerMsg ~= nil and attackerMsg[enemyAbility] and Battle.attacker % 2 == 0 then
		if Battle.battlerTarget % 2 == 1 then
			-- Otherwise, player activated enemy's ability
			return true
		end
	end
	if reverseAttackerMsg ~= nil and reverseAttackerMsg[enemyAbility] and Battle.attacker % 2 == 1 then
		--Owner of the ability is logged as the attacker
		return true
	end

	-- Contact-based status-inflicting abilities
	local statusInflictMsg = GameSettings.ABILITIES.STATUS_INFLICT[Battle.battleMsg]

	if statusInflictMsg ~= nil then
		-- Log allied pokemon contact status ability trigger for Synchronize
		if statusInflictMsg[enemyAbility] then
			if Battle.battler % 2 == 1 then
				if (Battle.battlerTarget % 2 == 1 and Battle.attacker % 2 == 0) or (Battle.Synchronize.attacker == Battle.attacker and Battle.Synchronize.battlerTarget == Battle.battlerTarget and Battle.Synchronize.battler ~= Battle.battler) then
					-- Player activated enemy's contact-based status ability
					return true
				end
			end
		end
		if statusInflictMsg[playerAbility] and Battle.attacker % 2 == 1 then
			Battle.Synchronize.turnCount = Battle.turnCount
			Battle.Synchronize.battler = Battle.battler
			Battle.Synchronize.attacker = Battle.attacker
			Battle.Synchronize.battlerTarget = Battle.battlerTarget
		end
	end

	-- Abilities not covered by the above checks
	local battleTargetMsg = GameSettings.ABILITIES.BATTLE_TARGET[Battle.battleMsg]

	if battleTargetMsg ~= nil and battleTargetMsg[enemyAbility] then
		if Battle.battlerTarget % 2 == 1 then
			if battleTargetMsg.scope == "both" and enemyAbility ~= playerAbility then
				-- Allied prevention ability takes priority over enemy, so if we both have it, ignore theirs
				return true
			elseif battleTargetMsg.scope == "self" then
				return true
			end
		elseif Battle.battlerTarget % 2 == 0 and battleTargetMsg.scope == "other" then
			-- Leech seed sets gBattlerTarget to mon receiving hp, so this is where we see liquid ooze
			return true
		end
	end

	return false
end

function Battle.beginNewBattle()
	if Battle.inBattle then return end

	Program.Frames.battleDataDelay = 60

	-- If this is a new battle, reset views and other pokemon tracker info
	Battle.inBattle = true
	Battle.turnCount = 0
	Battle.prevDamageTotal = 0
	Battle.damageReceived = 0
	Battle.enemyHasAttacked = false
	Battle.Synchronize.turnCount = 0
	Battle.Synchronize.attacker = -1
	Battle.Synchronize.battlerTarget = -1
	
	Battle.isGhost = false

	Tracker.Data.isViewingOwn = not Options["Auto swap to enemy"]
	Tracker.Data.ownViewSlot = 1
	Tracker.Data.otherViewSlot = 1
	Input.resetControllerIndex()

	-- Handles a common case of looking up a move, then entering combat. As a battle begins, the move info screen should go away.
	if Program.currentScreen == Program.Screens.INFO then
		InfoScreen.clearScreenData()
		Program.currentScreen = Program.Screens.TRACKER
	end

	 -- Delay drawing the new pokemon (or effectiveness of your own), because of send out animation
	Program.Frames.waitToDraw = Utils.inlineIf(Battle.isWildEncounter, 150, 250)
end

function Battle.endCurrentBattle()
	if not Battle.inBattle then return end

	Battle.inBattle = false
	Battle.turnCount = -1
	Battle.lastEnemyMoveId = 0
	Battle.Synchronize.turnCount = 0
	Battle.Synchronize.attacker = -1
	Battle.Synchronize.battlerTarget = -1

	Battle.isGhost = false

	Battle.CurrentRoute.hasInfo = false
	Battle.enemyTransformed = false

	Tracker.Data.isViewingOwn = true
	Tracker.Data.ownViewSlot = 1
	Tracker.Data.otherViewSlot = 1
	-- While the below clears our currently stored enemy pokemon data, most gets read back in from memory anyway
	Tracker.Data.otherPokemon = {}
	Tracker.Data.otherTeam = { 0, 0, 0, 0, 0, 0 }

	-- Reset stat stage changes for the owner's pokemon team
	for i=1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, true)
		if pokemon ~= nil then
			pokemon.statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 }
		end
	end

	-- Handles a common case of looking up a move, then moving on with the current battle. As the battle ends, the move info screen should go away.
	if Program.currentScreen == Program.Screens.INFO then
		InfoScreen.clearScreenData()
		Program.currentScreen = Program.Screens.TRACKER
	end

	-- Delay drawing the return to viewing your pokemon screen
	Program.Frames.waitToDraw = Utils.inlineIf(Battle.isWildEncounter, 70, 150)
	Program.Frames.saveData = Utils.inlineIf(Battle.isWildEncounter, 70, 150) -- Save data after every battle
end

function Battle.changeOpposingPokemonView()
	Battle.enemyTransformed = false

	if Options["Auto swap to enemy"] then
		Tracker.Data.isViewingOwn = false
	end

	Input.resetControllerIndex()

	-- Delay drawing the new pokemon, because of send out animation
	Program.Frames.waitToDraw = 0
end
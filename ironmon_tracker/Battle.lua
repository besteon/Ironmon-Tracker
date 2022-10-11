Battle = {
	inBattle = false,
	isWildEncounter = false,
	isGhost = false,
	isViewingLeft = true, -- By default, out of battle should view the left combatant slot (index = 0)
	numBattlers = 0,
	isNewTurn = true,

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
	firstActionTaken = false,

	-- "Low accuracy" values
	Synchronize = {
		turnCount = 0,
		battler = -1,
		attacker = -1,
		battlerTarget = -1,
	},
	AbilityChangeData = {
		prevAction = 4,
		recordNextMove = false
	},
	-- "Low accuracy" values
	CurrentRoute = {
		mapId = 0,
		encounterArea = RouteData.EncounterArea.LAND,
		hasInfo = false,
	},

	-- A "Combatant" is a Pokemon that is visible on the battle screen, represented by the slot # in the owner's team [1-6].
	Combatants = {
		LeftOwn = 1,
		LeftOther = 1,
		RightOwn = 2,
		RightOther = 2,
	},
	BattleAbilities = {
		[0] = {},
		[1] = {},
	},
}

-- Game Code maps the combatants in battle as follows: OwnTeamIndexes [L=0, R=2], EnemyTeamIndexes [L=1, R=3]
Battle.IndexMap = {
	[0] = "LeftOwn",
	[1] = "LeftOther",
	[2] = "RightOwn",
	[3] = "RightOther",
}

function Battle.update()
	if Program.Frames.highAccuracyUpdate == 0 and not Program.inCatchingTutorial then
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
	elseif Battle.inBattle and (lastBattleStatus ~= 0 or opposingPokemon==nil) then
		Battle.endCurrentBattle()
	end
end

-- Updates once every [10] frames. Be careful adding too many things to this 10 frame update
function Battle.updateHighAccuracy()
	Battle.processBattleTurn()
end

-- Updates once every [30] frames.
function Battle.updateLowAccuracy()
	Battle.updateViewSlots()
	Battle.updateTrackedInfo()
end

-- isOwn: true if it belongs to the player; false otherwise
function Battle.getViewedPokemon(isOwn)
	local viewSlot
	if isOwn then
		viewSlot = Utils.inlineIf(Battle.isViewingLeft or not Tracker.Data.isViewingOwn, Battle.Combatants.LeftOwn, Battle.Combatants.RightOwn)
	else
		viewSlot = Utils.inlineIf(Battle.isViewingLeft or Tracker.Data.isViewingOwn, Battle.Combatants.LeftOther, Battle.Combatants.RightOther)
	end

	return Tracker.getPokemon(viewSlot, isOwn)
end

function Battle.updateViewSlots()
	local prevEnemyPokemonLeft = Battle.Combatants.LeftOther
	local prevEnemyPokemonRight = Battle.Combatants.RightOther
	local prevOwnPokemonLeft = Battle.Combatants.LeftOwn
	local prevOwnPokemonRight = Battle.Combatants.RightOwn

	--update all 2 (or 4)
	Battle.Combatants.LeftOwn = Memory.readbyte(GameSettings.gBattlerPartyIndexes) + 1
	Battle.Combatants.LeftOther = Memory.readbyte(GameSettings.gBattlerPartyIndexes + 2) + 1

	-- Verify the view slots are within bounds, and that for doubles, the pokemon is not fainted (data is not cleared if there are no remaining pokemon)
	if Battle.Combatants.LeftOwn < 1 or Battle.Combatants.LeftOwn > 6 then
		Battle.Combatants.LeftOwn = 1
	end
	if Battle.Combatants.LeftOther < 1 or Battle.Combatants.LeftOther > 6 then
		Battle.Combatants.LeftOther = 1
	end

	-- Now also track the slots of the other 2 mons in double battles
	if Battle.numBattlers == 4 then
		Battle.Combatants.RightOwn = Memory.readbyte(GameSettings.gBattlerPartyIndexes + 4) + 1
		Battle.Combatants.RightOther = Memory.readbyte(GameSettings.gBattlerPartyIndexes + 6) + 1

		if Battle.Combatants.RightOwn < 1 or Battle.Combatants.RightOwn > 6 then
			Battle.Combatants.RightOwn = Utils.inlineIf(Battle.Combatants.LeftOwn == 1, 2, 1)
		end
		if Battle.Combatants.RightOther < 1 or Battle.Combatants.RightOther > 6 then
			Battle.Combatants.RightOther = Utils.inlineIf(Battle.Combatants.LeftOther == 1, 2, 1)
		end
	end

	--Track if ally pokemon changes, to reset transform and ability changes
	if prevOwnPokemonLeft ~= nil and prevOwnPokemonLeft ~= Battle.Combatants.LeftOwn then
		Battle.resetAbilityMapPokemon(prevOwnPokemonLeft,true)
	elseif Battle.numBattlers == 4 and prevOwnPokemonRight ~= nil and prevOwnPokemonRight ~= Battle.Combatants.RightOwn then
		Battle.resetAbilityMapPokemon(prevOwnPokemonRight,true)
	end
	-- Pokemon on the left is not the one that was there previously
	if prevEnemyPokemonLeft ~= nil and prevEnemyPokemonLeft ~= Battle.Combatants.LeftOther then
		Battle.resetAbilityMapPokemon(prevEnemyPokemonLeft,false)
		Battle.changeOpposingPokemonView(true)
	elseif Battle.numBattlers == 4 and prevEnemyPokemonRight ~= nil and prevEnemyPokemonRight ~= Battle.Combatants.RightOther then
		Battle.resetAbilityMapPokemon(prevEnemyPokemonRight,false)
		Battle.changeOpposingPokemonView(false)
	end
end

function Battle.processBattleTurn()
	-- attackerValue = 0 or 2 for player mons and 1 or 3 for enemy mons (2,3 are doubles partners)
	Battle.attacker = Memory.readbyte(GameSettings.gBattlerAttacker)

	local currentTurn = Memory.readbyte(GameSettings.gBattleResults + 0x13)
	local currDamageTotal = Memory.readword(GameSettings.gTakenDmg)

	-- As a new turn starts, note the previous amount of total damage, reset turn counters
	if currentTurn ~= Battle.turnCount then
		Battle.turnCount = currentTurn
		Battle.prevDamageTotal = currDamageTotal
		Battle.enemyHasAttacked = false
		Battle.isNewTurn = true
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

	-- Track moves for transformed mons if applicable; need high accuracy checking since moves window can be opened an closed in < .5 second
	Battle.trackTransformedMoves()
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

	-- Update useful battle values, will expand/rework this later
	Battle.readBattleValues()
	if Battle.isNewTurn then
		Battle.handleNewTurn()
	end

	local confirmedCount = Memory.readbyte(GameSettings.gBattleCommunication + 0x4)
	local actionCount = Memory.readbyte(GameSettings.gCurrentTurnActionNumber)
	local currentAction = Memory.readbyte(GameSettings.gActionsByTurnOrder + actionCount)
	--handles this value not being cleared from the previous battle
	local lastMoveByAttacker = Memory.readword(GameSettings.gBattleResults + 0x22 + ((Battle.attacker % 2) * 0x2))
	if actionCount == 0 and (lastMoveByAttacker ~= 0 or currentAction ~= 0) then Battle.firstActionTaken = true end
	--ignore focus punch setup, only priority move that isn't actually a used move yet. Also don't bother tracking abilities/moves for ghosts
	if not Battle.moveDelayed() and not Battle.isGhost then
		-- Check if we are on a new action cycle (Range 0 to numBattlers - 1)
		-- firstActionTaken fixes leftover data issue going from Single to Double battle
		-- If the same attacker was just logged, stop logging

		if actionCount < Battle.numBattlers and Battle.firstActionTaken and confirmedCount == 0 then
			-- 0 = MOVE_USED
			if lastMoveByAttacker > 0 and lastMoveByAttacker < #MoveData.Moves + 1 then
				if Battle.AbilityChangeData.prevAction ~= actionCount then
					Battle.AbilityChangeData.recordNextMove = true
					Battle.AbilityChangeData.prevAction = actionCount
				elseif Battle.AbilityChangeData.recordNextMove then
					local hitFlags = Memory.readdword(GameSettings.gHitMarker)
					local moveFlags = Memory.readbyte(GameSettings.gMoveResultFlags)
					--Do nothing if attacker was unable to use move (Fully paralyzed, Truant, etc.; HITMARKER_UNABLE_TO_USE_MOVE)
					if bit.band(hitFlags,0x80000) == 0 then
						-- Track move so long as the mon was able to use it
						local attackerSlot = Battle.Combatants[Battle.IndexMap[Battle.attacker]]
						local transformData = Battle.BattleAbilities[Battle.attacker % 2][attackerSlot].transformData
						--Only track moves for enemies; our moves could be TM moves, or moves we didn't forget from earlier levels
						if not transformData.isOwn then
							local attackingMon = Tracker.getPokemon(transformData.slot,transformData.isOwn)
							if attackingMon ~= nil then
								Tracker.TrackMove(attackingMon.pokemonID, lastMoveByAttacker, attackingMon.level)
							end
						end

						--Only track ability-changing moves if they also did not fail/miss
						if bit.band(moveFlags,0x29) == 0 then -- MOVE_RESULT_MISSED | MOVE_RESULT_DOESNT_AFFECT_FOE | MOVE_RESULT_FAILED
							Battle.trackAbilityChanges(lastMoveByAttacker,nil)
						end
					end
					--only get one chance to record
					Battle.AbilityChangeData.recordNextMove = false
				end
			end
		end
	end

	-- Always track your own Pokemons' abilities
	local ownLeftPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn,true)
	if ownLeftPokemon ~= nil then
		local ownLeftAbilityId = PokemonData.getAbilityId(ownLeftPokemon.pokemonID, ownLeftPokemon.abilityNum)
		Tracker.TrackAbility(ownLeftPokemon.pokemonID, ownLeftAbilityId)
		Battle.updateStatStages(ownLeftPokemon, true)
	end

	if Battle.numBattlers == 4 then
		local ownRightPokemon = Tracker.getPokemon(Battle.Combatants.RightOwn,true)
		if ownRightPokemon ~= nil then
			local ownRightAbilityId = PokemonData.getAbilityId(ownRightPokemon.pokemonID, ownRightPokemon.abilityNum)
			Tracker.TrackAbility(ownRightPokemon.pokemonID, ownRightAbilityId)
			Battle.updateStatStages(ownRightPokemon, true)
		end
	end
	--Don't track anything for Ghost opponents
	if not Battle.isGhost then
		local combatantIndexesToTrack = Battle.checkAbilitiesToTrack()
		for _, indexToTrack in pairs(combatantIndexesToTrack) do
			if indexToTrack >= 0 and indexToTrack < Battle.numBattlers then
				local battleMon = Battle.BattleAbilities[indexToTrack % 2][Battle.Combatants[Battle.IndexMap[indexToTrack]]]
				local abilityOwner = Tracker.getPokemon(battleMon.abilityOwner.slot,battleMon.abilityOwner.isOwn)
				if abilityOwner ~= nil then
					Tracker.TrackAbility(abilityOwner.pokemonID, battleMon.ability)
				end
			end
		end
		local otherLeftPokemon = Tracker.getPokemon(Battle.Combatants.LeftOther,false)
		if otherLeftPokemon ~= nil then
			Battle.updateStatStages(otherLeftPokemon, false)
			Battle.checkEnemyEncounter(otherLeftPokemon)
		end
		if Battle.numBattlers == 4 then
			local otherRightPokemon = Tracker.getPokemon(Battle.Combatants.RightOther,false)
			if otherRightPokemon ~= nil then
				Battle.updateStatStages(otherRightPokemon, false)
				Battle.checkEnemyEncounter(otherRightPokemon)
			end
		end
	end
end

function Battle.readBattleValues()
	Battle.numBattlers = Memory.readbyte(GameSettings.gBattlersCount)
	Battle.battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)
	Battle.battler = Memory.readbyte(GameSettings.gBattleScriptingBattler) % Battle.numBattlers
	Battle.battlerTarget = Memory.readbyte(GameSettings.gBattlerTarget) % Battle.numBattlers
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

function Battle.checkAbilitiesToTrack()

	-- Track previous ability activation for handling Synchronize
	if Battle.Synchronize.turnCount < Battle.turnCount then
		Battle.Synchronize.turnCount = Battle.turnCount
		Battle.Synchronize.battler = -1
		Battle.Synchronize.attacker = -1
		Battle.Synchronize.battlerTarget = -1
	end
	local combatantIndexesToTrack = {}

	local attackerAbility = Battle.BattleAbilities[Battle.attacker % 2][Battle.Combatants[Battle.IndexMap[Battle.attacker]]].ability
	local battlerAbility = Battle.BattleAbilities[Battle.battler % 2][Battle.Combatants[Battle.IndexMap[Battle.battler]]].ability
	local battleTargetAbility = Battle.BattleAbilities[Battle.battlerTarget % 2][Battle.Combatants[Battle.IndexMap[Battle.battlerTarget]]].ability

	-- BATTLER: 'battler' had their ability triggered
	local abilityMsg = GameSettings.ABILITIES.BATTLER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[battlerAbility] then
		-- Track a Traced pokemon's ability
		if battlerAbility == 36 then
			Battle.trackAbilityChanges(nil,36)
			combatantIndexesToTrack[Battle.battlerTarget] = Battle.battlerTarget
		end
		combatantIndexesToTrack[Battle.battler] = Battle.battler
	end

	-- REVERSE_BATTLER: 'battlerTarget' had their ability triggered by the battler's ability
	abilityMsg = GameSettings.ABILITIES.REVERSE_BATTLER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[battleTargetAbility] then
		combatantIndexesToTrack[Battle.battlerTarget] = Battle.battlerTarget
		combatantIndexesToTrack[Battle.battler] = Battle.battler
	end

	-- ATTACKER: 'battleTarget' had their ability triggered
	abilityMsg = GameSettings.ABILITIES.ATTACKER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[battleTargetAbility] then
		combatantIndexesToTrack[Battle.battlerTarget] = Battle.battlerTarget
	end

	-- REVERSE ATTACKER: 'attacker' had their ability triggered
	abilityMsg = GameSettings.ABILITIES.REVERSE_ATTACKER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[attackerAbility] then
		combatantIndexesToTrack[Battle.attacker] = Battle.attacker
	end

	abilityMsg = GameSettings.ABILITIES.STATUS_INFLICT[Battle.battleMsg]
	if abilityMsg ~= nil then
		-- Log allied pokemon contact status ability trigger for Synchronize
		if abilityMsg[battlerAbility] and ((Battle.battler == Battle.battlerTarget) or (Battle.Synchronize.attacker == Battle.attacker and Battle.Synchronize.battlerTarget == Battle.battlerTarget and Battle.Synchronize.battler ~= Battle.battler)) then
			combatantIndexesToTrack[Battle.battler] = Battle.battler
		end
		if abilityMsg[battleTargetAbility] then
			Battle.Synchronize.turnCount = Battle.turnCount
			Battle.Synchronize.battler = Battle.battler
			Battle.Synchronize.attacker = Battle.attacker
			Battle.Synchronize.battlerTarget = Battle.battlerTarget
		end
	end

	abilityMsg = GameSettings.ABILITIES.BATTLE_TARGET[Battle.battleMsg]
	if abilityMsg ~= nil then
		if abilityMsg[battleTargetAbility] and abilityMsg.scope == "self" then
			combatantIndexesToTrack[Battle.battlerTarget] = Battle.battlerTarget
		end
		if abilityMsg.scope == "other" and abilityMsg[attackerAbility] then
			combatantIndexesToTrack[Battle.attacker] = Battle.attacker
		end
	end

	local levitateCheck = Memory.readbyte(GameSettings.gBattleCommunication + 0x6)
	for i = 0, Battle.numBattlers, 1 do
		if levitateCheck == 4 and Battle.attacker ~= i then
			combatantIndexesToTrack[Battle.battlerTarget] = Battle.battlerTarget
		--check for first Damp mon
		elseif abilityMsg ~= nil and abilityMsg.scope == "both" then
			local monAbility = Battle.BattleAbilities[i%2][Battle.Combatants[Battle.IndexMap[i]]].ability
			if abilityMsg[monAbility] then
				combatantIndexesToTrack[i] = i
			end
		end
	end

	return combatantIndexesToTrack
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
	Battle.firstActionTaken = false
	Battle.AbilityChangeData.prevAction = 4
	Battle.AbilityChangeData.recordNextMove= false
	Battle.Synchronize.turnCount = 0
	Battle.Synchronize.attacker = -1
	Battle.Synchronize.battlerTarget = -1

	Battle.isGhost = false

	Tracker.Data.isViewingOwn = not Options["Auto swap to enemy"]
	Battle.isViewingLeft = true
	Battle.Combatants = {
		LeftOwn = 1,
		LeftOther = 1,
		RightOwn = 2,
		RightOther = 2,
	}
	Battle.populateBattleAbilityObject()
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

	--Most of the time, Run Away message is present only after the battle ends
	Battle.battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)
	if Battle.battleMsg == GameSettings.BattleScript_RanAwayUsingMonAbility then
		local battleMon = Battle.BattleAbilities[0][Battle.Combatants[Battle.IndexMap[0]]]
		local abilityOwner = Tracker.getPokemon(battleMon.abilityOwner.slot,battleMon.abilityOwner.isOwn)
		if abilityOwner ~= nil then
			Tracker.TrackAbility(abilityOwner.pokemonID, battleMon.ability)
		end
	end

	Battle.numBattlers = 0
	Battle.inBattle = false
	Battle.turnCount = -1
	Battle.lastEnemyMoveId = 0
	Battle.Synchronize.turnCount = 0
	Battle.Synchronize.attacker = -1
	Battle.Synchronize.battlerTarget = -1

	Battle.isGhost = false

	Battle.CurrentRoute.hasInfo = false

	Tracker.Data.isViewingOwn = true
	Battle.isViewingLeft = true
	Battle.Combatants = {
		LeftOwn = 1,
		LeftOther = 1,
		RightOwn = 2,
		RightOther = 2,
	}
	Battle.isTransformed = {
		LeftOwn = false,
		LeftOther = false,
		RightOwn = false,
		RightOther = false,
	}
	BattleAbilities = {
		[0] = {},
		[1] = {},
	}
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

function Battle.handleNewTurn()
	--Reset counters
	Battle.AbilityChangeData.prevAction = 4
	Battle.AbilityChangeData.recordNextMove= false
	Battle.isNewTurn = false
end

function Battle.changeOpposingPokemonView(isLeft)
	if Options["Auto swap to enemy"] then
		Tracker.Data.isViewingOwn = false
		Battle.isViewingLeft = isLeft
	end

	Input.resetControllerIndex()

	-- Delay drawing the new pokemon, because of send out animation
	Program.Frames.waitToDraw = 0
end

function Battle.populateBattleAbilityObject()
	--populate BattleAbilities for all Pokemon with their starting Abilities and pokemonIDs
	Battle.BattleAbilities[0] = {}
	Battle.BattleAbilities[1] = {}
	for i=1, 6, 1 do
		local ownPokemon = Tracker.getPokemon(i, true)
		if ownPokemon ~= nil then
			local ability = PokemonData.getAbilityId(ownPokemon.pokemonID, ownPokemon.abilityNum)
			Battle.BattleAbilities[0][i] = {
				abilityOwner = {
					isOwn = true,
					slot = i
				},
				["originalAbility"] = ability,
				["ability"] = ability,
				transformData = {
					isOwn = true,
					slot = i,
				},
			}
		end
		local enemyPokemon = Tracker.getPokemon(i, false)
		if enemyPokemon ~= nil then
			local ability = PokemonData.getAbilityId(enemyPokemon.pokemonID, enemyPokemon.abilityNum)
			Battle.BattleAbilities[1][i] = {
				abilityOwner = {
					isOwn = false,
					slot = i
				},
				["originalAbility"] = ability,
				["ability"] = ability,
				transformData = {
					isOwn = false,
					slot = i,
				},
			}
		end
	end
end

function Battle.trackAbilityChanges(moveUsed, ability)

	--check if ability changing move is being used. If so, make appropriate swaps in the table based on attacker/target
	if moveUsed ~= nil and moveUsed ~=0 then
		if moveUsed == 285 then
			--Skill Swap; swap abilities and sources of target and attacker
			local attackerTeamIndex =  Battle.attacker % 2
			local attackerSlot = Battle.Combatants[Battle.IndexMap[Battle.attacker]]
			local targetTeamIndex =  Battle.battlerTarget % 2
			local targetSlot = Battle.Combatants[Battle.IndexMap[Battle.battlerTarget]]

			local tempOwnerIsOwn = Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.isOwn
			local tempOwnerSlot = Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.slot
			local tempAbility = Battle.BattleAbilities[attackerTeamIndex][attackerSlot].ability

			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.isOwn = Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.isOwn
			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.slot = Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.slot
			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].ability = Battle.BattleAbilities[targetTeamIndex][targetSlot].ability
			Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.isOwn = tempOwnerIsOwn
			Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.slot = tempOwnerSlot
			Battle.BattleAbilities[targetTeamIndex][targetSlot].ability = tempAbility
		elseif moveUsed == 272 or moveUsed == 144 then
			--Role Play/Transform; copy abilities and sources of target and attacker, and turn on/off transform tracking
			local attackerTeamIndex =  Battle.attacker % 2
			local attackerSlot = Battle.Combatants[Battle.IndexMap[Battle.attacker]]
			local targetTeamIndex =  Battle.battlerTarget % 2
			local targetSlot = Battle.Combatants[Battle.IndexMap[Battle.battlerTarget]]

			if moveUsed == 272 then
				local abilityOwner = Tracker.getPokemon(Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.slot,Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.isOwn)
				if abilityOwner ~= nil then
					Tracker.TrackAbility(abilityOwner.pokemonID, Battle.BattleAbilities[targetTeamIndex][targetSlot].ability)
				end
			end

			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.isOwn = Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.isOwn
			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.slot = Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.slot
			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].ability = Battle.BattleAbilities[targetTeamIndex][targetSlot].ability

			--Track Transform changes
			if moveUsed == 144 then
				Battle.BattleAbilities[attackerTeamIndex][attackerSlot].transformData.isOwn = Battle.BattleAbilities[targetTeamIndex][targetSlot].transformData.isOwn
				Battle.BattleAbilities[attackerTeamIndex][attackerSlot].transformData.slot = Battle.BattleAbilities[targetTeamIndex][targetSlot].transformData.slot
			end

		end
	elseif ability ~= nil and ability ~=0 then
		if ability == 36 then --Trace
			-- In double battles, Trace picks a random target, so we need to grab the battle index from the text variable, gBattleTextBuff1[2]
			local tracerTeamIndex = Battle.battler % 2
			local tracerTeamSlot = Battle.Combatants[Battle.IndexMap[Battle.battler]]
			local target = Memory.readbyte(GameSettings.gBattleTextBuff1 + 2)
			local targetTeamIndex = target % 2
			local targetTeamSlot = Battle.Combatants[Battle.IndexMap[target]]

			--Track Trace here, otherwise when we try to track normally, the pokemon's battle ability and owner will have already updated to what was traced.
			local abilityOwner = Tracker.getPokemon(Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].abilityOwner.slot,Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].abilityOwner.isOwn)
			if abilityOwner ~= nil then
				Tracker.TrackAbility(abilityOwner.pokemonID, ability)
			end

			Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].abilityOwner.isOwn = Battle.BattleAbilities[targetTeamIndex][targetTeamSlot].abilityOwner.isOwn
			Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].abilityOwner.slot = Battle.BattleAbilities[targetTeamIndex][targetTeamSlot].abilityOwner.slot
			Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].ability = Battle.BattleAbilities[targetTeamIndex][targetTeamSlot].ability
		end
	end
end

function Battle.resetAbilityMapPokemon(slot, isOwn)
	local teamIndex = Utils.inlineIf(isOwn,0,1)
	Battle.BattleAbilities[teamIndex][slot].abilityOwner.isOwn = isOwn
	Battle.BattleAbilities[teamIndex][slot].abilityOwner.slot = slot
	Battle.BattleAbilities[teamIndex][slot].ability = Battle.BattleAbilities[teamIndex][slot].originalAbility

	Battle.BattleAbilities[teamIndex][slot].transformData.isOwn = isOwn
	Battle.BattleAbilities[teamIndex][slot].transformData.slot = slot
end

function Battle.trackTransformedMoves()

	--Do nothing if no pokemon is viewing their moves
	if Memory.readbyte(GameSettings.sBattleBuffersTransferData) ~= 20 then return end

	-- First 4 bits indicate attacker
	local currentSelectingMon = Utils.getbits(Memory.readbyte(GameSettings.gBattleControllerExecFlags),0,4)

	-- Get 0 or 2 battler Index (bitshift the bits until you find the 1)
	for i = 0,3,1 do
		if currentSelectingMon == 1 then
			currentSelectingMon = i
			break
		else
			currentSelectingMon = bit.rshift(currentSelectingMon, 1)
		end
	end

	-- somehow got an enemy Pokemon's ID
	if currentSelectingMon % 2 ~= 0 then return end

	-- Track all moves, if we are copying an enemy mon
	local transformData = Battle.BattleAbilities[0][Battle.Combatants[Battle.IndexMap[currentSelectingMon]]].transformData
	if not transformData.isOwn then
		local copiedMon = Tracker.getPokemon(transformData.slot, false)
		if copiedMon ~= nil then
			for _, move in pairs(copiedMon.moves) do
				if MoveData.isValid(move.id) then
					Tracker.TrackMove(copiedMon.pokemonID, move.id, copiedMon.level)
				end
			end
		end
	end
end

function Battle.moveDelayed()
	return Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsConfused -- Pause for "X is confused"
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsConfused2 -- Confusion animation
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsConfusedNoMore -- Pause for "X snapped out of confusion"
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsInLove -- Pause for the "X is in love with Y" delay
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsInLove2 --Infatuation animation
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsFrozen -- Ignore "X is frozen solid"
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsFrozen2 -- Frozen animation
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedIsFrozen3 -- Frozen animation 2
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedUnfroze -- Pause for "X thawed out"
	or Battle.battleMsg == GameSettings.BattleScript_MoveUsedUnfroze2 -- Thawed out 2
end

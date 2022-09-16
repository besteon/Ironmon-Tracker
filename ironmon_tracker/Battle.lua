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
		attacker = -1,
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
	Battle.handleTransformedMons()
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

	--TODO: replace placeholder addresses 
	local confirmedCount = Memory.readbyte(0x02023e86) --gBattleCommunication + 0x4
	local actionCount = Memory.readbyte(0x02023be2) --gCurrentTurnActionNumber
	if actionCount == 0 then Battle.firstActionTaken = true end
	local lastMoveByAttacker = Memory.readword(GameSettings.gBattleResults + 0x22 + ((Battle.attacker % 2) * 0x2))
	local battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)
	local actionChosen = Memory.readbyte(0x02023d7c + Battle.attacker) -- gChosenActionByBattler
	
	--print ("Move: " .. lastMoveByAttacker .. "; Attacker: " .. Battle.attacker .. "; Battler: " .. Battle.battler .. "; Target: " .. Battle.battlerTarget .. "; Message: " .. battleMsg .. "; Action: " .. actionCount .. "; AbilityDataAttacker: " .. Battle.AbilityChangeData.attacker .. "; confirmedCount: " .. confirmedCount)
	--ignore focus punch setup, only priority move that isn't actually a used move yet. Also don't bother tracking abilities/moves for ghosts
	if not (GameSettings.BattleScript_FocusPunchSetUp ~= 0x00000000 and battleMsg == GameSettings.BattleScript_FocusPunchSetUp) and not Battle.isGhost then	
		-- Check if we are on a new action cycle (Range 0 to numBattlers - 1)
		-- firstActionTaken fixes leftover data issue going from Single to Double battle
		-- If the same attacker was just looged, stop logging for efficiency
		if actionCount < Battle.numBattlers and Battle.firstActionTaken and Battle.AbilityChangeData.attacker ~= Battle.attacker and confirmedCount == 0 then
			--print ("Action: " .. actionCount)
			-- 0 = MOVE_USED
			if actionChosen ~= 0 then
				-- Mark enemy as took their turn if they aren't using a move.
				print ("Non-move action taken.")
				Battle.AbilityChangeData.attacker = Battle.attacker
			--Only log if it was a valid move
			elseif actionChosen == 0 and lastMoveByAttacker > 0 and lastMoveByAttacker < #MoveData.Moves then
				local moveFlags = Memory.readbyte (GameSettings.gMoveResultFlags)
				--local hitFlags = Memory.readdword(GameSettings.gHitMarker)
				--hitflags; 20th bit from the right marks moves that failed to execute (Full Paralyzed, Truant, hurt in confusion, Sleep)
				local hitFlags = Memory.readdword(0x02023dd0)
				--Do nothing if attacker was unable to use move
				if bit.band(hitFlags,0x80000) == 0 --and [[TODO: check that the pokemon is actually attacking]]
				 then -- HITMARKER_UNABLE_TO_USE_MOVE
					--Only track ability-changing moves if they did not fail/miss, otherwise still track the move
					if bit.band(moveFlags,0x29) == 0 then -- MOVE_RESULT_MISSED | MOVE_RESULT_DOESNT_AFFECT_FOE | MOVE_RESULT_FAILED
						print ("Move used and successful")
						Battle.trackAbilityChanges(lastMoveByAttacker,nil)
					end
					local attackerSlot = Battle.Combatants[Battle.IndexMap[Battle.attacker]]
					local attackingMon = Tracker.getPokemon(attackerSlot,Battle.attacker % 2 == 0)
					local transformData = Battle.BattleAbilities[Battle.attacker % 2][attackerSlot].transformData
					local isTransformed = transformData.slot ~= attackerSlot or transformData.isOwn ~= (Battle.attacker % 2 == 0)
					--Do not track move if the attacker is transformed and either an allied mon, or transformed into an allied mon (enemies transformed into other enemies are fine)
					-- Update: DO track moves for transformed mons, but for the mon they are transformed into
					if not isTransformed or (not transformData.isOwn and Battle.attacker % 2 == 1) then
						print ("Tracking Move: " .. lastMoveByAttacker)
						Tracker.TrackMove(attackingMon.pokemonID, lastMoveByAttacker, attackingMon.level)
					end
				end
				Battle.AbilityChangeData.attacker = Battle.attacker
			end
		end
	end
	-- Do track focus punch though for move tracking when the appears 

	-- Always track your own Pokemons' abilities

	local ownLeftPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn,true)
	local ownLeftAbilityId = PokemonData.getAbilityId(ownLeftPokemon.pokemonID, ownLeftPokemon.abilityNum)
	Tracker.TrackAbility(ownLeftPokemon.pokemonID, ownLeftAbilityId)
	Battle.updateStatStages(ownLeftPokemon, true)

	if Battle.numBattlers == 4 then
		local ownRightPokemon = Tracker.getPokemon(Battle.Combatants.RightOwn,true)
		local ownRightAbilityId = PokemonData.getAbilityId(ownRightPokemon.pokemonID, ownRightPokemon.abilityNum)
		Tracker.TrackAbility(ownRightPokemon.pokemonID, ownRightAbilityId)
		Battle.updateStatStages(ownRightPokemon, true)
	end
	--Don't track anything for Ghost opponents
	if not Battle.isGhost then
		local otherLeftPokemon = Tracker.getPokemon(Battle.Combatants.LeftOther,false)
		local otherRightPokemon = Tracker.getPokemon(Battle.Combatants.RightOther,false)
		local indexToTrack = Battle.checkAbilitiesToTrack()
		if indexToTrack >= 0 and indexToTrack < Battle.numBattlers then
			local battleMon = Battle.BattleAbilities[indexToTrack % 2][Battle.Combatants[Battle.IndexMap[indexToTrack]]]
			local abilityOwner = Tracker.getPokemon(battleMon.abilityOwner.slot,battleMon.abilityOwner.isOwn)
			print("Tracking ability: " .. battleMon.ability .. " for Pokemon " .. abilityOwner.pokemonID)
			Tracker.TrackAbility(abilityOwner.pokemonID, battleMon.ability)
		end
		Battle.updateStatStages(otherLeftPokemon, false)
		Battle.checkEnemyEncounter(otherLeftPokemon)
		if Battle.numBattlers == 4 then
			Battle.updateStatStages(otherRightPokemon, false)
			Battle.checkEnemyEncounter(otherRightPokemon)
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

	local attackerAbility = Battle.BattleAbilities[Battle.attacker % 2][Battle.Combatants[Battle.IndexMap[Battle.attacker]]].ability
	local battlerAbility = Battle.BattleAbilities[Battle.battler % 2][Battle.Combatants[Battle.IndexMap[Battle.battler]]].ability
	local battleTargetAbility = Battle.BattleAbilities[Battle.battlerTarget % 2][Battle.Combatants[Battle.IndexMap[Battle.battlerTarget]]].ability

	-- TODO: Re-test all abilities

	-- BATTLER: 'battler' had their ability triggered
	abilityMsg = GameSettings.ABILITIES.BATTLER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[battlerAbility] then
		-- Track a Traced pokemon's ability
		if battlerAbility == 36 then
			Battle.trackAbilityChanges(nil,36)
			return Battle.battlerTarget
		end
		return Battle.battler
	end

	-- REVERSE_BATTLER: 'battlerTarget' had their ability triggered
	abilityMsg = GameSettings.ABILITIES.REVERSE_BATTLER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[battleTargetAbility] then
		return Battle.battlerTarget
	end

	-- ATTACKER: 'battleTarget' had their ability triggered
	abilityMsg = GameSettings.ABILITIES.ATTACKER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[battleTargetAbility] then
		return Battle.battlerTarget
	end

	-- REVERSE ATTACKER: 'attacker' had their ability triggered
	abilityMsg = GameSettings.ABILITIES.REVERSE_ATTACKER[Battle.battleMsg]
	if abilityMsg ~= nil and abilityMsg[attackerAbility] then
		return Battle.attacker
	end

	abilityMsg = GameSettings.ABILITIES.STATUS_INFLICT[Battle.battleMsg]
	if abilityMsg ~= nil then
		-- Log allied pokemon contact status ability trigger for Synchronize
		if abilityMsg[battlerAbility] and ((Battle.battler == Battle.battlerTarget) or (Battle.Synchronize.attacker == Battle.attacker and Battle.Synchronize.battlerTarget == Battle.battlerTarget and Battle.Synchronize.battler ~= Battle.battler)) then
			return Battle.battler
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
			return Battle.battlerTarget
		end
		if abilityMsg.scope == "other" and abilityMsg[battlerAbility] then
			return Battle.battler
		end
	end

	-- TODO: check that this logs levitate only as a mon is avoiding levitate damage in multi-battles
	local levitateCheck = Memory.readbyte(GameSettings.gBattleCommunication + 0x6)
	for i = 0, Battle.numBattlers, 1 do
		if levitateCheck == 4 and Battle.attacker ~= i then
			return Battle.battlerTarget
		--check for first Damp mon
		elseif abilityMsg ~= nil and abilityMsg.scope == "both" then
			local monAbility = Battle.BattleAbilities[i%2][Battle.Combatants[Battle.IndexMap[i]]].ability
			if abilityMsg[monAbility] then
				return i
			end
		end
	end

	return -1
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
	Battle.AbilityChangeData.attacker = -1
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
	--populate BattleAbilities for all Pokemon
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
	Battle.AbilityChangeData.attacker = -1
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

			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.isOwn = Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.isOwn
			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].abilityOwner.slot = Battle.BattleAbilities[targetTeamIndex][targetSlot].abilityOwner.slot
			Battle.BattleAbilities[attackerTeamIndex][attackerSlot].ability = Battle.BattleAbilities[targetTeamIndex][targetSlot].ability

			--Track Transform changes
			if moveUsed == 144 then
				Battle.BattleAbilities[attackerTeamIndex][attackerSlot].transformData.isOwn = Battle.BattleAbilities[targetTeamIndex][targetSlot].transformData.isOwn
				Battle.BattleAbilities[attackerTeamIndex][attackerSlot].transformData.slot = Battle.BattleAbilities[targetTeamIndex][targetSlot].transformData.slot
			end
			if moveUsed == 272 then
				local abilityOwner = Tracker.getPokemon(targetSlot,targetTeamIndex == 0)
				Tracker.TrackAbility(abilityOwner.pokemonID, Battle.BattleAbilities[targetTeamIndex][targetSlot].ability)
			end
		end
	elseif ability ~= nil and ability ~=0 then
		if ability == 36 then --Trace
			-- In double battles, Trace picks a random target, so we need to grab the battle index from the text variable, gBattleTextBuff1[2]
			local tracerTeamIndex = Battle.battler % 2
			local tracerTeamSlot = Battle.Combatants[Battle.IndexMap[Battle.battler]]
			--TODO: replace with gBattleTextBuff1
			local target = Memory.readbyte(0x02022ab8 + 2)
			local targetTeamIndex = target % 2
			local targetTeamSlot = Battle.Combatants[Battle.IndexMap[target]]

			Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].abilityOwner.isOwn = Battle.BattleAbilities[targetTeamIndex][targetTeamSlot].abilityOwner.isOwn
			Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].abilityOwner.slot = Battle.BattleAbilities[targetTeamIndex][targetTeamSlot].abilityOwner.slot
			Battle.BattleAbilities[tracerTeamIndex][tracerTeamSlot].ability = Battle.BattleAbilities[targetTeamIndex][targetTeamSlot].ability

			--Track Trace here, otherwise when we try to track normally, the pokemon's battle ability and owner will have already updated to what was traced.
			local abilityOwner = Tracker.getPokemon(tracerTeamSlot,tracerTeamIndex == 0)
			print("Tracking ability: " .. ability .. " for Pokemon " .. abilityOwner.pokemonID)
			Tracker.TrackAbility(abilityOwner.pokemonID, ability)
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

function Battle.handleTransformedMons()

	--Do nothing if no pokemon is viewing their moves
	if Memory.readbyte(0x02022874) ~= 20 then return end --sBattleBuffersTransferData

	-- First 4 bits indicate attacker
	local currentSelectingMon = Utils.getbits(Memory.readbyte(0x02023bc8),0,4) -- gBattleControllerExecFlags

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
		for _, move in pairs(copiedMon.moves) do
			if MoveData.isValid(move.id) then
				Tracker.TrackMove(copiedMon.pokemonID, move.id, copiedMon.level)
			end
		end
	end
end
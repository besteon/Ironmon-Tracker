State = {
	TRACKER = "Tracker",
	INFOSCREEN = "InfoScreen",
	SETTINGS = "Settings",
	THEME = "Theme",
}

Program = {
	state = State.TRACKER,
	inCatchingTutorial = false,
	hasCompletedTutorial = false,
	lastSeenEnemyAbilityId = 0,
}

Program.frames = {
	waitToDraw = 0,
	battleDataDelay = 0,
	half_sec_update = 30,
	three_sec_update = 180,
	saveData = 3600,
}

Program.transformedPokemon = {
	isTransformed = false,
	forceSwitch = false,
}

function Program.main()
	Input.update()

	-- Updating data on pokemon should be unrelated to which screen is being displayed, otherwise the Tracker wouldn't know a battle ended in the Theme menu for example.
	Program.updateTrackedAndCurrentData()

	if Program.state == State.TRACKER then
		-- Only draw the Tracker screen every half second (60 frames/sec)
		if Program.frames.waitToDraw == 0 then
			Program.frames.waitToDraw = 30

			TrackerScreen.updateButtonStates()

			local ownersPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
			local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)

			-- Depending on which pokemon is being viewed, draw it using the other pokemon's info for calculations (effectiveness/weight)
			if Tracker.Data.isViewingOwn then
				Drawing.drawPokemonView(ownersPokemon, opposingPokemon)
			else
				Drawing.drawPokemonView(opposingPokemon, ownersPokemon)
			end
		end

		Program.frames.waitToDraw = Program.frames.waitToDraw - 1
	elseif Program.state == State.INFOSCREEN then
		if InfoScreen.redraw then
			Drawing.drawInfoScreen()
			InfoScreen.redraw = false
		end
	elseif Program.state == State.SETTINGS then
		if Options.redraw then
			Drawing.drawOptionsScreen()
			Options.redraw = false
		end
	elseif Program.state == State.THEME then
		if Theme.redraw and Program.frames.waitToDraw == 0 then
			Program.frames.waitToDraw = 5
			Drawing.drawThemeScreen()
			Theme.redraw = false
		elseif Program.frames.waitToDraw > 0 then -- Required because of Theme.redraw check
			Program.frames.waitToDraw = Program.frames.waitToDraw - 1
		end
	end
end

function Program.updateTrackedAndCurrentData()
	-- Get any "new" information from game memory for player's pokemon team every half second (60 frames/sec)
	if Program.frames.half_sec_update == 0 then
		Program.frames.half_sec_update = 30

		local viewingWhichPokemon = Tracker.Data.otherViewSlot

		Program.inCatchingTutorial = Program.isInCatchingTutorial()

		if not Program.inCatchingTutorial then -- Don't update/track data while in the catching tutorial
			Program.updatePokemonTeamsFromMemory()
			Program.updateBattleDataFromMemory() -- This will only read memory data if in battle.

			-- Check for if summary screen is being shown
			if not Tracker.Data.hasCheckedSummary then
				local summaryCheck = Memory.readbyte(GameSettings.sMonSummaryScreen)
				if summaryCheck ~= 0 then
					Tracker.Data.hasCheckedSummary = true
				end
			end
		end

		-- Use this to check if the opposing Pokemon changes
		if Tracker.Data.inBattle and viewingWhichPokemon ~= Tracker.Data.otherViewSlot then
			-- Reset the transform tracking disable unless player was force-switched by roar/whirlwind
			if Program.transformedPokemon.isTransformed and not Program.transformedPokemon.forceSwitch then
				Program.transformedPokemon.isTransformed = false
			end
		
			if Options["Auto swap to enemy"] then
				Tracker.Data.isViewingOwn = false
			end
		
			-- Reset the controller's position when a new pokemon is sent out
			Input.controller.statIndex = 6

			-- Delay drawing the new pokemon, because of send out animation
			Program.frames.waitToDraw = 0
		end

	end

	-- Only update "Heals in Bag", "PC Heals", and "Badge Data" info every 3 seconds (3 seconds * 60 frames/sec)
	if Program.frames.three_sec_update == 0 then
		Program.frames.three_sec_update = 180

		Program.updateBagHealingItemsFromMemory()
		Program.updatePCHealsFromMemory()
		Program.updateBadgesObtainedFromMemory()
	end

	-- Only save tracker data every 1 minute (60 seconds * 60 frames/sec)
	if Program.frames.saveData == 0 then
		Program.frames.saveData = 3600
		Tracker.saveData()
	end

	Program.frames.half_sec_update = Program.frames.half_sec_update - 1
	Program.frames.three_sec_update = Program.frames.three_sec_update - 1
	Program.frames.saveData = Program.frames.saveData - 1
end

function Program.updatePokemonTeamsFromMemory()
	-- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
	local lastBattleStatus = Memory.readbyte(GameSettings.gBattleOutcome)
	local isOpposingPokemonWild = false

	-- Check for updates to each pokemon team
	local addressOffset = 0
	for i = 1, 6, 1 do
		-- Lookup information on the player's Pokemon first
		local personality = Memory.readdword(GameSettings.pstats + addressOffset)
		Tracker.Data.ownTeam[i] = personality

		if personality ~= 0 then
			local newPokemonData = Program.readNewPokemonFromMemory(GameSettings.pstats + addressOffset, personality)

			if Program.validPokemonData(newPokemonData) then
				-- Sets the player's trainerID as soon as they get their first Pokemon
				if Tracker.Data.trainerID == nil or Tracker.Data.trainerID == 0 then
					Tracker.Data.trainerID = newPokemonData.trainerID
				end
				-- Remove trainerID value from the pokemon data itself since it's now owned by the player, saves data space
				newPokemonData.trainerID = nil

				Tracker.addUpdatePokemon(newPokemonData, personality, true)
			end
		end

		-- Then lookup information on the opposing Pokemon
		personality = Memory.readdword(GameSettings.estats + addressOffset)
		Tracker.Data.otherTeam[i] = personality

		if personality ~= 0 then
			newPokemonData = Program.readNewPokemonFromMemory(GameSettings.estats + addressOffset, personality)

			if Program.validPokemonData(newPokemonData) then
				if Tracker.Data.trainerID ~= nil and Tracker.Data.trainerID ~= 0 then
					isOpposingPokemonWild = Tracker.Data.trainerID == newPokemonData.trainerID
				end

				-- Double-check a race condition where current PP values are wildly out of range if retrieved right before a battle begins
				if not Tracker.Data.inBattle then
					for _, move in pairs(newPokemonData.moves) do
						if move.id ~= 0 then
							move.pp = tonumber(MoveData.Moves[move.id].pp) -- set value to max PP
						end
					end
				end

				Tracker.addUpdatePokemon(newPokemonData, personality, false)
			end
		end

		addressOffset = addressOffset + 100
	end

	-- If the pokemon doesn't have an ability yet, look it up
	-- Lookup data on the last pokemon we fought (for purposes of it being a wild pokemon and we catch it)
	local lastSeenPersonality = Tracker.Data.otherTeam[1]
	local lastSeenPokemon = Tracker.Data.ownPokemon[lastSeenPersonality]

	if lastBattleStatus == 7 and lastSeenPokemon ~= nil and Program.lastSeenEnemyAbilityId ~= 0 then
		lastSeenPokemon.abilityId = Program.lastSeenEnemyAbilityId
		Program.lastSeenEnemyAbilityId = 0
	end

	-- Check if we can enter battle (opposingPokemon check required for lab fight), or if a battle has just finished
	local opposingPokemon = Tracker.getPokemon(1, false)
	if not Tracker.Data.inBattle and lastBattleStatus == 0 and opposingPokemon ~= nil then
		Program.beginNewBattle(isOpposingPokemonWild)
	elseif Tracker.Data.inBattle and lastBattleStatus ~= 0 then
		Program.endBattle(isOpposingPokemonWild)
	end
end

function Program.readNewPokemonFromMemory(startAddress, personality)
	local otid = Memory.readdword(startAddress + 4)
	local magicword = bit.bxor(personality, otid) -- The XOR encryption key for viewing the Pokemon data

	local aux          = personality % 24
	local growthoffset = (MiscData.TableData.growth[aux + 1] - 1) * 12
	local attackoffset = (MiscData.TableData.attack[aux + 1] - 1) * 12
	local effortoffset = (MiscData.TableData.effort[aux + 1] - 1) * 12
	local miscoffset   = (MiscData.TableData.misc[aux + 1] - 1) * 12

	-- Pokemon Data structure: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_(Generation_III)
	local growth1 = bit.bxor(Memory.readdword(startAddress + 32 + growthoffset), magicword)
	-- local growth2 = bit.bxor(Memory.readdword(startAddress + 32 + growthoffset + 4), magicword) -- Currently unused
	local growth3 = bit.bxor(Memory.readdword(startAddress + 32 + growthoffset + 8), magicword)
	local attack1 = bit.bxor(Memory.readdword(startAddress + 32 + attackoffset), magicword)
	local attack2 = bit.bxor(Memory.readdword(startAddress + 32 + attackoffset + 4), magicword)
	local attack3 = bit.bxor(Memory.readdword(startAddress + 32 + attackoffset + 8), magicword)

	-- Unused data memory reads
	-- local effort1 = bit.bxor(Memory.readdword(startAddress + 32 + effortoffset), magicword)
	-- local effort2 = bit.bxor(Memory.readdword(startAddress + 32 + effortoffset + 4), magicword)
	-- local effort3 = bit.bxor(Memory.readdword(startAddress + 32 + effortoffset + 8), magicword)
	-- local misc1   = bit.bxor(Memory.readdword(startAddress + 32 + miscoffset), magicword)
	-- local misc2   = bit.bxor(Memory.readdword(startAddress + 32 + miscoffset + 4), magicword)
	-- local misc3   = bit.bxor(Memory.readdword(startAddress + 32 + miscoffset + 8), magicword)

	-- Checksum, currently unused
	-- local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	-- 		+ Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
	-- 		+ Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
	-- 		+ Utils.addhalves(misc1) + Utils.addhalves(misc2) + Utils.addhalves(misc3)
	-- cs = cs % 65536

	-- Determine status condition
	local status_aux = Memory.readdword(startAddress + 80)
	local sleep_turns_result = 0
	local status_result = 0
	if status_aux == 0 then
		status_result = 0
	elseif status_aux < 8 then
		sleep_turns_result = status_aux
		status_result = 1
	elseif status_aux == 8 then
		status_result = 2
	elseif status_aux == 16 then
		status_result = 3
	elseif status_aux == 32 then
		status_result = 4
	elseif status_aux == 64 then
		status_result = 5
	elseif status_aux == 128 then
		status_result = 6
	end

	-- Can likely improve this further using memory.read_bytes_as_array but would require testing to verify
	local level_and_currenthp = Memory.readdword(startAddress + 84)
	local maxhp_and_atk = Memory.readdword(startAddress + 88)
	local def_and_speed = Memory.readdword(startAddress + 92)
	local spatk_and_spdef = Memory.readdword(startAddress + 96)

	local pokemonData = {
		trainerID = Utils.getbits(otid, 0, 16),
		pokemonID = Utils.getbits(growth1, 0, 16),
		heldItem = Utils.getbits(growth1, 16, 16),
		friendship = Utils.getbits(growth3, 72, 8),
		level = Utils.getbits(level_and_currenthp, 0, 8),
		nature = personality % 25,
		abilityId = nil, -- Leave unset, since this currently can only be found via in-battle data
		status = status_result,
		sleep_turns = sleep_turns_result,
		curHP = Utils.getbits(level_and_currenthp, 16, 16),
		stats = {
			hp = Utils.getbits(maxhp_and_atk, 0, 16),
			atk = Utils.getbits(maxhp_and_atk, 16, 16),
			def = Utils.getbits(def_and_speed, 0, 16),
			spa = Utils.getbits(spatk_and_spdef, 0, 16),
			spd = Utils.getbits(spatk_and_spdef, 16, 16),
			spe = Utils.getbits(def_and_speed, 16, 16),
		},
		statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
		moves = {
			{ id = Utils.getbits(attack1, 0, 16), level = 1, pp = Utils.getbits(attack3, 0, 8) },
			{ id = Utils.getbits(attack1, 16, 16), level = 1, pp = Utils.getbits(attack3, 8, 8) },
			{ id = Utils.getbits(attack2, 0, 16), level = 1, pp = Utils.getbits(attack3, 16, 8) },
			{ id = Utils.getbits(attack2, 16, 16), level = 1, pp = Utils.getbits(attack3, 24, 8) },
		},

		-- Unused data that can be added back in later
		-- secretID = Utils.getbits(otid, 16, 16), -- Unused
		-- experience = Utils.getbits(growth2, 32, 31), -- Unused
		-- pokerus = Utils.getbits(misc1, 0, 8), -- Unused
		-- iv = misc2,
		-- ev1 = effort1,
		-- ev2 = effort2,
	}

	return pokemonData
end

-- Updates viewslots for display, increment encounter count, update abilities if they don't exist already, as well as any stat stage changes
function Program.updateBattleDataFromMemory()
	if not Tracker.Data.inBattle then return end

	Program.updateViewSlotsFromMemory()

	-- Required delay between reading Pokemon data from battle, as it takes ~N frames for old battle values to be cleared out
	if Program.frames.battleDataDelay > 0 then
		Program.frames.battleDataDelay = Program.frames.battleDataDelay - 30
		return
	end

	local ownersPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
	local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)

	if ownersPokemon ~= nil and opposingPokemon ~= nil then
		Program.updateAbilityDataFromMemory(ownersPokemon, true)
		Program.updateAbilityDataFromMemory(opposingPokemon, false)
	
		Program.updateStatStagesDataFromMemory(ownersPokemon, true)
		Program.updateStatStagesDataFromMemory(opposingPokemon, false)

		-- ENCOUNTERS: If the pokemon doesn't belong to the player, and hasn't been encountered yet, increment
		if opposingPokemon.hasBeenEncountered == nil or not opposingPokemon.hasBeenEncountered then
			opposingPokemon.hasBeenEncountered = true
			local isWild = Tracker.Data.trainerID == opposingPokemon.trainerID -- equal IDs = wild pokemon, nonequal = trainer
			Tracker.TrackEncounter(opposingPokemon.pokemonID, isWild)
		end

		-- ABILITIES: TODO: Not all games/versions supported
		if GameSettings.gBattlescriptCurrInstr ~= 0x00000000 then
			local battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)

			-- TODO: Hacky workaround when both active Pokemon share an ability, currently no way to know which triggered, so skip revealing anything
			if opposingPokemon.abilityId ~= ownersPokemon.abilityId then
				-- Only track the triggered ability if that ability belongs to the enemy Pokemon (matches its real ability)
				if GameSettings.ABILITIES[battleMsg] == opposingPokemon.abilityId then
					Tracker.TrackAbility(opposingPokemon.pokemonID, opposingPokemon.abilityId)
				end
			end

			-- Also track the enemy's ability if the player's Pokemon triggered its Trace ability
			if GameSettings.ABILITIES[battleMsg] == 36 and ownersPokemon.abilityId == 36 then -- 36 = Trace
				Tracker.TrackAbility(opposingPokemon.pokemonID, opposingPokemon.abilityId)
			end
		end

		-- MOVES: Check if the opposing Pokemon used a move (it's missing pp from max), and if so track it
		for _, move in pairs(opposingPokemon.moves) do
			if move.id ~= 0 and move.pp < tonumber(MoveData.Moves[move.id].pp) then
				Program.handleAttackMove(move.id, Tracker.Data.otherViewSlot, false)
			end
		end

		-- TODO: Disabling this for now as it triggers when your pokemon or enemy pokemon trigger Focus Punch animation. Similar concern to tracking abilitys info and revealing too much
		-- if GameSettings.gBattlescriptCurrInstr ~= 0x00000000 and GameSettings.BattleScript_FocusPunchSetUp ~= 0x00000000 then
		-- 	local battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)
			
		-- 	-- Manually track Focus Punch, since PP isn't deducted if the mon charges the move but then dies
		-- 	if battleMsg == GameSettings.BattleScript_FocusPunchSetUp then
		-- 		Program.handleAttackMove(264, Tracker.Data.otherViewSlot, false)
		-- 	end
		-- end
	end
end

function Program.updateViewSlotsFromMemory()
	-- First update which own/other slots are being viewed
	Tracker.Data.ownViewSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
	Tracker.Data.otherViewSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1

	-- Secondary enemy pokemon (likely the doubles battle partner)
	local attackerValue = Memory.readbyte(GameSettings.gBattlerAttacker)
	if attackerValue % 2 == 3 then
		Tracker.Data.otherViewSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1
	end

	-- Verify the view slots are within bounds
	if Tracker.Data.ownViewSlot < 1 or Tracker.Data.ownViewSlot > 6 then
		Tracker.Data.ownViewSlot = 1
	end
	if Tracker.Data.otherViewSlot < 1 or Tracker.Data.otherViewSlot > 6 then
		Tracker.Data.otherViewSlot = 1
	end
end

function Program.updateAbilityDataFromMemory(pokemon, isOwn)
	-- If the Pokemon doesn't have an ability yet, look it up and save it (only works in battle)
	if pokemon.abilityId == nil or pokemon.abilityId == 0 then
		local abilityFromMemory = Memory.readbyte(GameSettings.gBattleMons + 0x20 + Utils.inlineIf(isOwn, 0x0, 0x58))
		pokemon.abilityId = abilityFromMemory

		-- Save information on enemy ability as "last seen ability" to be used for when you catch this Pokemon to add to your own team
		if not isOwn then
			Program.lastSeenEnemyAbilityId = pokemon.abilityId
		end
	end
end

function Program.updateStatStagesDataFromMemory(pokemon, isOwn)
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

-- This should be called every time the player gets into a battle (wild pokemon or trainer battle)
function Program.beginNewBattle(isWild)
	if Tracker.Data.inBattle then return end
	if isWild == nil then isWild = false end

	Program.frames.battleDataDelay = 60

	-- If this is a new battle, reset views and other pokemon tracker info
	Tracker.Data.inBattle = true
	Tracker.Data.isViewingOwn = not Options["Auto swap to enemy"]
	Tracker.Data.ownViewSlot = 1
	Tracker.Data.otherViewSlot = 1
	Input.controller.statIndex = 6 -- Reset the controller's position when a new pokemon is sent out

	-- Handles a common case of looking up a move, then entering combat. As a battle begins, the move info screen should go away.
	if Program.state == State.INFOSCREEN then
		Program.state = State.TRACKER
	end

	 -- Delay drawing the new pokemon (or effectiveness of your own), because of send out animation
	Program.frames.waitToDraw = Utils.inlineIf(isWild, 150, 250)
end

-- This should be called every time the player finishes a battle (wild pokemon or trainer battle)
function Program.endBattle(isWild)
	if not Tracker.Data.inBattle then return end
	if isWild == nil then isWild = false end

	Tracker.Data.inBattle = false
	Tracker.Data.isViewingOwn = true
	Tracker.Data.ownViewSlot = 1
	Tracker.Data.otherViewSlot = 1
	-- While the below clears our currently stored enemy pokemon data, most gets read back in from memory anyway
	Tracker.Data.otherPokemon = nil
	Tracker.Data.otherTeam = { 0, 0, 0, 0, 0, 0 }

	-- Reset stat stage changes for the pokemon team
	for i=1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, true)
		if pokemon ~= nil then
			pokemon.statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 }
		end
	end

	-- Handles a common case of looking up a move, then moving on with the current battle. As the battle ends, the move info screen should go away.
	if Program.state == State.INFOSCREEN then
		Program.state = State.TRACKER
	end

	-- Delay drawing the return to viewing your pokemon screen
	Program.frames.waitToDraw = Utils.inlineIf(isWild, 70, 150)
	Program.frames.saveData = Utils.inlineIf(isWild, 70, 150) -- Save data after every battle
end

function Program.updatePCHealsFromMemory()
	-- Updates PC Heal tallies and handles auto-tracking PC Heal counts when the option is on
	local gameStatsAddr = 0x0
	if GameSettings.game == 1 then
		-- Ruby/Sapphire doesn't have gSaveBlock1Ptr and just uses gSaveBlock1 directly
		gameStatsAddr = GameSettings.gSaveBlock1 + GameSettings.gameStatsOffset
	else
		-- Seems like in FRLG/Emerald we need to refresh the pointer's address similarly to the encryption key
		local saveblock1PtrAddr = Memory.readdword(GameSettings.gSaveBlock1ptr)
		gameStatsAddr = saveblock1PtrAddr + GameSettings.gameStatsOffset
	end
	
	-- Currently checks the total number of heals from pokecenters and from mom
	-- Does not include whiteouts, as those don't increment either of these gamestats
	local gameStat_UsedPokecenter = Memory.readdword(gameStatsAddr + 15 * 0x4)
	-- Turns out Game Freak are weird and only increment mom heals in RSE, not FRLG
	local gameStat_RestedAtHome = Memory.readdword(gameStatsAddr + 16 * 0x4)

	if GameSettings.EncryptionKeyOffset ~= 0 then
		-- Need to decrypt the data in FRLG/Emerald
		local saveBlock2addr = Memory.readdword(GameSettings.gSaveBlock2ptr)
		local key = Memory.readdword(saveBlock2addr + GameSettings.EncryptionKeyOffset)
		gameStat_UsedPokecenter = bit.bxor(gameStat_UsedPokecenter, key)
		gameStat_RestedAtHome = bit.bxor(gameStat_RestedAtHome, key)
	end

	local combinedHeals = gameStat_UsedPokecenter + gameStat_RestedAtHome

	if combinedHeals ~= Tracker.Data.gameStatsHeals then
		-- Update the local tally if there is a new heal
		Tracker.Data.gameStatsHeals = combinedHeals
		-- Only change the displayed PC Heals count when the option is on and auto-tracking is enabled
		if Options["Track PC Heals"] and TrackerScreen.buttons.PCHealAutoTracking.toggleState then
			if Options["PC heals count downward"] then
				-- Automatically count down
				Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
				if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			else
				-- Automatically count up
				Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
				if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			end
		end
	end
end

function Program.updateBadgesObtainedFromMemory()
	local badgeBits = nil
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	if GameSettings.game == 1 then -- Ruby/Sapphire
		badgeBits = Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 2 then -- Emerald
		badgeBits = Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 3 then -- FireRed/LeafGreen
		badgeBits = Memory.readbyte(saveblock1Addr + GameSettings.badgeOffset)
	end

	if badgeBits ~= nil then
		for i = 1, 8, 1 do
			Tracker.Data.badges[i] = Utils.getbits(badgeBits, i - 1, 1)
		end
	end
end

function Program.handleAttackMove(moveId, slotNumber, isOwn)
	if moveId == nil then return end
	if slotNumber == nil or slotNumber < 1 or slotNumber > 6 then slotNumber = 1 end
	if isOwn == nil then isOwn = true end

	-- For now, only handle moves from opposing Pokemon
	if not isOwn then
		-- Update view to the Pokemon that attacked; don't know if this is still needed
		-- Tracker.Data.otherViewSlot = slotNumber

		-- Stop tracking moves temporarily while transformed
		if not Program.transformedPokemon.isTransformed then
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				if not Tracker.isTrackingMove(pokemon.pokemonID, moveId, pokemon.level) then
					Tracker.TrackMove(pokemon.pokemonID, moveId, pokemon.level)
				end
			end
		elseif moveId == 18 or moveId == 46 then -- 18 = Whirlwind, 46 = Roar
			-- Account for niche scenario of force-switch moves being used while transformed
			Program.transformedPokemon.forceSwitch = true
		elseif Program.transformedPokemon.forceSwitch then
			-- Reset when another move is used
			Program.transformedPokemon.forceSwitch = false
		end

		-- This comes after so transform itself gets tracked
		if moveId == 144 then -- 144 = Transform
			Program.transformedPokemon.isTransformed = true
		end
	end
end

function Program.HandleExit()
	Drawing.clearGUI()
	forms.destroyall()
end

-- Returns true only if the player hasn't completed the catching tutorial
function Program.isInCatchingTutorial()
	if Program.hasCompletedTutorial then return false end

	local tutorialFlag = Memory.readbyte(GameSettings.sSpecialFlags)
	if tutorialFlag == 3 then
		Program.inCatchingTutorial = true
	elseif Program.inCatchingTutorial and tutorialFlag == 0 then
		Program.inCatchingTutorial = false
		Program.hasCompletedTutorial = true
	end

	return Program.inCatchingTutorial
end

-- Pokemon is valid if it has a valid id, helditem, and each move that exists is a real move.
function Program.validPokemonData(pokemonData)
	if pokemonData == nil then return false end

	-- If the Pokemon exists, but it's ID is invalid
	if pokemonData.pokemonID ~= nil and (pokemonData.pokemonID < 0 or pokemonData.pokemonID > #PokemonData.Pokemon) then
		return false
	end

	-- If the Pokemon is holding an item, and that item is invalid
	if pokemonData.heldItem ~= nil and (pokemonData.heldItem < 0 or pokemonData.heldItem > 376) then
		return false
	end

	-- For each of the Pokemon's moves that isn't blank, is that move real
	for _, move in pairs(pokemonData.moves) do
		if move.id < 0 or move.id > #MoveData.Moves then -- 0 = blank move id
			return false
		end
	end

	return true
end

function Program.updateBagHealingItemsFromMemory()
	if not Tracker.Data.isViewingOwn then return end

	local leadPokemon = Tracker.getPokemon(1, true)
	if leadPokemon ~= nil then
		local healingItems = Program.calcBagHealingItemsFromMemory(leadPokemon.stats.hp)
		if healingItems ~= nil then
			Tracker.Data.healingItems = healingItems
		end
	end
end

function Program.calcBagHealingItemsFromMemory(pokemonMaxHP)
	local totals = {
		healing = 0,
		numHeals = 0,
	}

	-- Check for potential divide-by-zero errors
	if pokemonMaxHP == nil or pokemonMaxHP == 0 then
		return totals
	end

	-- Formatted as: healingItemsInBag[itemID] = quantity
	local healingItemsInBag = Program.getHealingItemsFromMemory()
	if healingItemsInBag == nil then
		return totals
	end

	-- for _, item in pairs(MiscData.healingItems) do
	for itemID, quantity in pairs(healingItemsInBag) do
		local healItemData = MiscData.HealingItems[itemID]
		if healItemData ~= nil and quantity > 0 then
			local healingPercentage = 0
			if healItemData.type == MiscData.HealingType.Constant then
				local percentage = healItemData.amount / pokemonMaxHP * 100
				if percentage > 100 then
					percentage = 100
				end
				healingPercentage = percentage * quantity
			elseif healItemData.type == MiscData.HealingType.Percentage then
				healingPercentage = healItemData.amount * quantity
			end
			-- Healing is in a percentage compared to the mon's max HP
			totals.healing = totals.healing + healingPercentage
			totals.numHeals = totals.numHeals + quantity
		end
	end

	-- Sanity checking, because for some reason gSaveBlock2Ptr
	if totals.healing > 1000000 then
		return nil
	end

	return totals
end

function Program.getHealingItemsFromMemory()
	-- I believe this key has to be looked-up each time, as the ptr changes periodically
	local key = nil -- Ruby/Sapphire don't have an encryption key
	if GameSettings.EncryptionKeyOffset ~= 0 then
		local saveBlock2addr = Memory.readdword(GameSettings.gSaveBlock2ptr)
		key = Memory.readword(saveBlock2addr + GameSettings.EncryptionKeyOffset)
	end

	local healingItems = {}
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local addressesToScan = {
		[saveBlock1Addr + GameSettings.bagPocket_Items_offset] = GameSettings.bagPocket_Items_Size,
		[saveBlock1Addr + GameSettings.bagPocket_Berries_offset] = GameSettings.bagPocket_Berries_Size,
	}
	for address, size in pairs(addressesToScan) do
		for i = 0, (size - 1), 1 do
			--read 4 bytes at once, should be less expensive than reading two sets of 2 bytes.
			local itemid_and_quantity = Memory.readdword(address + i * 0x4)
			local itemID = Utils.getbits(itemid_and_quantity, 0, 16)
			if itemID ~= 0 and MiscData.HealingItems[itemID] ~= nil then
				local quantity = Utils.getbits(itemid_and_quantity, 16, 16)
				if key ~= nil then quantity = bit.bxor(quantity, key) end
				healingItems[itemID] = quantity
			end
		end
	end

	return healingItems
end
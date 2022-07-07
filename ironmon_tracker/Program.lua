State = {
	TRACKER = "Tracker",
	SETTINGS = "Settings",
	THEME = "Theme",
}

Program = {
	pokemonDataFrames = 0,
	itemCheckFrames = 0,
	waitToDrawFrames = 0,
	saveDataFrames = 3600,
	state = State.TRACKER,
	PCHealTrackingButtonState = false,
}

Program.StatButtonState = {
	hp = 1,
	atk = 1,
	def = 1,
	spa = 1,
	spd = 1,
	spe = 1
}

Program.transformedPokemon = {
	isTransformed = false,
	forceSwitch = false,
}

function Program.main()
	Input.update()

	if Program.state == State.TRACKER then
		Program.updateTrackedAndCurrentData()

		-- Only draw the Tracker screen every half second (60 frames/sec)
		if Program.waitToDrawFrames == 0 then
			Program.waitToDrawFrames = 30

			local ownersPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
			local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)

			if opposingPokemon ~= nil then
				Program.StatButtonState = Tracker.getStatMarkings(opposingPokemon.pokemonID)
				Buttons = Program.updateButtons(Program.StatButtonState)
			end

			-- Depending on which pokemon is being viewed, draw it using the other pokemon's info for calculations (effectiveness/weight)
			if Tracker.Data.isViewingOwn then
				Drawing.drawPokemonView(ownersPokemon, opposingPokemon)
			else
				Drawing.drawPokemonView(opposingPokemon, ownersPokemon)
			end
		else
			Program.waitToDrawFrames = Program.waitToDrawFrames - 1
		end

		-- Only save tracker data every 1 minute (60 seconds * 60 frames/sec)
		if Program.saveDataFrames == 0 then
			Program.saveDataFrames = 3600
			Tracker.saveData()
		else
			Program.saveDataFrames = Program.saveDataFrames - 1
		end
	elseif Program.state == State.SETTINGS then
		if Options.redraw then
			Drawing.drawSettings()
			Options.redraw = false
		end
	elseif Program.state == State.THEME then
		if Theme.redraw and Program.waitToDrawFrames == 0 then
			Program.waitToDrawFrames = 5
			Drawing.drawThemeMenu()
			Theme.redraw = false
		elseif Program.waitToDrawFrames > 0 then
			Program.waitToDrawFrames = Program.waitToDrawFrames - 1
		end
	end
end

function Program.updateTrackedAndCurrentData()
	-- Get any "new" information from game memory for player's pokemon team every half second (60 frames/sec)
	if Program.pokemonDataFrames == 0 then
		Program.pokemonDataFrames = 30

		local viewingWhichPokemon = Tracker.Data.otherViewSlot

		Program.updatePokemonTeamsFromMemory()
		Program.updateBattleDataFromMemory() -- This will only read memory data if in battle.

		-- Check for if summary screen is being shown
		if not Tracker.Data.hasCheckedSummary and GameSettings.sMonSummaryScreen ~= 0 then
			local summaryCheck = Memory.readbyte(GameSettings.sMonSummaryScreen)
			if summaryCheck ~= 0 then
				Tracker.Data.hasCheckedSummary = true
			end
		end

		-- Use this to check if the opposing Pokemon changes
		if Tracker.Data.inBattle and viewingWhichPokemon ~= Tracker.Data.otherViewSlot then
			-- print("Opposing pokemon swapped! " .. viewingWhichPokemon .. " -> " .. Tracker.Data.otherViewSlot)
			-- Reset the transform tracking disable unless player was force-switched by roar/whirlwind
			if Program.transformedPokemon.isTransformed and not Program.transformedPokemon.forceSwitch then
				Program.transformedPokemon.isTransformed = false
			end
		
			if Options["Auto swap to enemy"] then
				Tracker.Data.isViewingOwn = false
			end
		
			-- Reset the controller's position when a new pokemon is sent out
			Tracker.controller.statIndex = 6
			-- Delay drawing the new pokemon, because of send out animation
			Program.waitToDrawFrames = 60
		end
	else
		Program.pokemonDataFrames = Program.pokemonDataFrames - 1
	end

	-- Only update "Heals in Bag" information every 5 seconds (5 seconds * 60 frames/sec)
	if Program.itemCheckFrames == 0 then
		Program.itemCheckFrames = 300
		Program.calculateBagHealingItemsFromMemory()
	else
		Program.itemCheckFrames = Program.itemCheckFrames - 1
	end
end

-- Checks if any updates to own/other pokemon data are required based on a few conditions
-- 1) A move was used, 2) Pokemon levels up, 3) Walking around deals poison damage or changes friendship, 4) ...?
function Program.updatePokemonTeamsFromMemory()
	-- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
	local lastBattleStatus = Memory.readbyte(GameSettings.gBattleOutcome)

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
				Tracker.addUpdatePokemon(newPokemonData, personality, false)
			end
		end

		addressOffset = addressOffset + 100
	end

	-- If the pokemon doesn't have an ability yet, look it up
	-- Lookup data on the last pokemon we fought (for purposes of it being a wild pokemon and we catch it)
	local lastSeenPersonality = Tracker.Data.otherTeam[1]
	local lastSeenPokemon = Tracker.Data.ownPokemon[lastSeenPersonality]
	if lastBattleStatus == 7 and lastSeenPokemon ~= nil and (lastSeenPokemon.ability == nil or lastSeenPokemon.ability.id == 0) then
		local abilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x1)

		if lastSeenPokemon.ability == nil or lastSeenPokemon.ability.id == 0 then
			lastSeenPokemon.ability = {
				id = abilityId,
				revealed = true,
			}

			-- TODO: This tracks data in the case of a catch & release, with no intent to view pokemon data. This shouldnt happen.
			-- Update tracked ability data for when we encounter this pokemon in the future
			-- Tracker.TrackAbility(recentPokemon.pokemonID, recentPokemon.ability.id, true)
		end

		-- TODO: This tracks data in the case of a catch & release, with no intent to view pokemon data. This shouldnt happen.
		-- Update tracked moved data for when we encounter this pokemon in the future
		-- if recentPokemon.moves ~= nil then
		-- 	for _, move in pairs(recentPokemon.moves) do
		-- 		Tracker.TrackMove(recentPokemon.pokemonID, move.id, recentPokemon.level)
		-- 	end
		-- end
	end

	-- Check if we can enter battle (opposingPokemon check required for lab fight), or if a battle has just finished
	local opposingPokemon = Tracker.getPokemon(1, false)
	if not Tracker.Data.inBattle and lastBattleStatus == 0 and opposingPokemon ~= nil then
		Program.beginNewBattle()
	elseif Tracker.Data.inBattle and lastBattleStatus ~= 0 then
		Program.endBattle()
	end
end

function Program.readNewPokemonFromMemory(startAddress, personality)
	local otid = Memory.readdword(startAddress + 4)
	local magicword = bit.bxor(personality, otid) -- The XOR encryption key for viewing the Pokemon data

	local aux          = personality % 24
	local growthoffset = (TableData.growth[aux + 1] - 1) * 12
	local attackoffset = (TableData.attack[aux + 1] - 1) * 12
	local effortoffset = (TableData.effort[aux + 1] - 1) * 12
	local miscoffset   = (TableData.misc[aux + 1] - 1) * 12

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

	-- TODO: Can likely improve this further using memory.read_bytes_as_array but would require testing to verify
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
		ability = nil, -- Leave unset, since this currently can only be found via in-battle data
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
			{ id = Utils.getbits(attack1, 0, 16) + 1, level = 1, pp = Utils.getbits(attack3, 0, 8) },
			{ id = Utils.getbits(attack1, 16, 16) + 1, level = 1, pp = Utils.getbits(attack3, 8, 8) },
			{ id = Utils.getbits(attack2, 0, 16) + 1, level = 1, pp = Utils.getbits(attack3, 16, 8) },
			{ id = Utils.getbits(attack2, 16, 16) + 1, level = 1, pp = Utils.getbits(attack3, 24, 8) },
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

	-- First update which own/other slots are being viewed
	Tracker.Data.ownViewSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
	if Tracker.Data.ownViewSlot < 1 or Tracker.Data.ownViewSlot > 6 then
		Tracker.Data.ownViewSlot = 1
	end

	local attackerValue = Memory.readbyte(GameSettings.gBattlerAttacker)
	if attackerValue == 1 then -- Primary enemy pokemon
		Tracker.Data.otherViewSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
	elseif attackerValue == 3 then -- Secondary enemy pokemon (doubles partner)
		Tracker.Data.otherViewSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1
	end
	if Tracker.Data.otherViewSlot < 1 or Tracker.Data.otherViewSlot > 6 then
		Tracker.Data.otherViewSlot = 1
	end

	-- Then update ability/statstage data for each of the viewed pokemon
	-- [i=1] is own pokemon, [i=2] is other pokemon
	for i=1, 2, 1 do
		local pokemon = Utils.inlineIf(i == 1, Tracker.getPokemon(Tracker.Data.ownViewSlot, true), Tracker.getPokemon(Tracker.Data.otherViewSlot, false))
		if pokemon ~= nil then
			-- If the pokemon doesn't belong to the player, and hasn't been encountered yet, increment
			if i ~= 1 and (pokemon.hasBeenEncountered == nil or not pokemon.hasBeenEncountered) then
				pokemon.hasBeenEncountered = true
				Tracker.TrackEncounter(pokemon.pokemonID, Tracker.Data.trainerID ~= pokemon.trainerID) -- equal IDs = wild pokemon, nonequal = trainer
			end

			-- If the player's Pokemon doesn't have an ability yet, look it up
			local newAbilityFromMemory = Memory.readbyte(GameSettings.sBattlerAbilities)
			if i == 1 and (pokemon.ability == nil or pokemon.ability.id ~= newAbilityFromMemory) then
				pokemon.ability = {
					id = newAbilityFromMemory,
					revealed = true,
				}
				Tracker.TrackAbility(pokemon.pokemonID, pokemon.ability.id, pokemon.ability.revealed)
			end

			local startAddress = GameSettings.gBattleMons + Utils.inlineIf(i == 1, 0x0, 0x58)
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
	end

	-- Check if the opposing Pokemon used a move (it's missing pp from max), and if so track it
	local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
	if opposingPokemon ~= nil then
		for _, move in pairs(opposingPokemon.moves) do
			if move.pp ~= tonumber(MoveData[move.id].pp) then
				Program.handleAttackMove(move.id, Tracker.Data.otherViewSlot, false)
			end
		end
	end
end

-- This should be called every time the player gets into a battle (wild pokemon or trainer battle)
function Program.beginNewBattle()
	if Tracker.Data.inBattle then return end

	-- If this is a new battle, reset views and other pokemon tracker info
	Tracker.Data.inBattle = true
	Tracker.Data.isViewingOwn = not Options["Auto swap to enemy"]
	Tracker.Data.ownViewSlot = 1
	Tracker.Data.otherViewSlot = 1
	Tracker.controller.statIndex = 6 -- Reset the controller's position when a new pokemon is sent out
	Program.waitToDrawFrames = 90 -- Delay drawing the new pokemon, because of send out animation
end

-- This should be called every time the player finishes a battle (wild pokemon or trainer battle)
function Program.endBattle()
	if not Tracker.Data.inBattle then return end

	Tracker.Data.inBattle = false
	Tracker.Data.isViewingOwn = true
	Tracker.Data.ownViewSlot = 1
	Tracker.Data.otherViewSlot = 1
	Tracker.Data.otherPokemon = nil
	Tracker.Data.otherTeam = { 0, 0, 0, 0, 0, 0 }

	-- Reset stat stage changes for the pokemon team
	for i=1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, true)
		if pokemon ~= nil then
			pokemon.statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 }
		end
	end
	Program.waitToDrawFrames = 90 -- Delay drawing the new pokemon
end

function Program.updateButtons(state)
	Buttons[1].text = StatButtonStates[state["hp"]]
	Buttons[2].text = StatButtonStates[state["atk"]]
	Buttons[3].text = StatButtonStates[state["def"]]
	Buttons[4].text = StatButtonStates[state["spa"]]
	Buttons[5].text = StatButtonStates[state["spd"]]
	Buttons[6].text = StatButtonStates[state["spe"]]
	Buttons[1].textcolor = StatButtonColors[state["hp"]]
	Buttons[2].textcolor = StatButtonColors[state["atk"]]
	Buttons[3].textcolor = StatButtonColors[state["def"]]
	Buttons[4].textcolor = StatButtonColors[state["spa"]]
	Buttons[5].textcolor = StatButtonColors[state["spd"]]
	Buttons[6].textcolor = StatButtonColors[state["spe"]]
	return Buttons
end

-- This is called by event.onmemoryexecute
-- TODO: Nonfunctional. Find a way to get this information without a Bizhawk 'event'
-- Triggers when an event causes the players entire party to get healed, usually Pokecenter or NPC
function Program.HandleHealPlayerParty()
	if Program.PCHealTrackingButtonState and Options["Track PC Heals"] then
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

function Program.handleAttackMove(moveId, slotNumber, isOwn)
	if moveId == nil then return end
	if slotNumber == nil or slotNumber < 1 or slotNumber > 6 then slotNumber = 1 end
	if isOwn == nil then isOwn = true end

	-- if moveId < 1 or moveId > 355 then print("[INVALID] MoveId: " .. moveId) end

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
		elseif moveId == 19 or moveId == 47 then
			-- Account for niche scenario of force-switch moves being used while transformed
			Program.transformedPokemon.forceSwitch = true
		elseif Program.transformedPokemon.forceSwitch then
			-- Reset when another move is used
			Program.transformedPokemon.forceSwitch = false
		end

		-- This comes after so transform itself gets tracked
		if moveId == 145 then
			Program.transformedPokemon.isTransformed = true
		end
	end
end

function Program.HandleExit()
	Drawing.clearGUI()
	if Input.noteForm then
		forms.destroy(Input.noteForm)
	end
end

-- Pokemon is valid if it has a valid id, helditem, and each move is real.
function Program.validPokemonData(pokemonData)
	if pokemonData == nil then return false end

	-- If the Pokemon exists, but it's ID is invalid
	if pokemonData.pokemonID ~= nil and (pokemonData.pokemonID < 0 or pokemonData.pokemonID > 412) then
		return false
	end

	-- If the Pokemon is holding an item, and that item is invalid
	if pokemonData.heldItem ~= nil and (pokemonData.heldItem < 0 or pokemonData.heldItem > 376) then
		return false
	end

	-- For each of the Pokemon's moves, is that move invalid
	for _, move in pairs(pokemonData.moves) do
		if move.id < 1 or move.id > 355 then -- offset with +1 since that is being added to moveId when we read data from memory
			return false
		end
	end

	return true
end

function Program.calculateBagHealingItemsFromMemory()
	if not Tracker.Data.isViewingOwn then return end

	local leadPokemon = Tracker.getPokemon(1, true)
	if leadPokemon ~= nil then
		local healingItems = Program.getBagHealingItemsFromMemory(leadPokemon.stats.hp)
		if healingItems ~= nil then
			Tracker.Data.healingItems = healingItems
		end
	end
end

function Program.getBagHealingItemsFromMemory(pokemonMaxHP)
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
		local healItemData = MiscData.healingItems[itemID]
		if healItemData ~= nil and quantity > 0 then
			local healingPercentage = 0
			if healItemData.type == HealingType.Constant then
				local percentage = healItemData.amount / pokemonMaxHP * 100
				if percentage > 100 then
					percentage = 100
				end
				healingPercentage = percentage * quantity
			elseif healItemData.type == HealingType.Percentage then
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

-- Currently unused. Requires a rewrite to use the new Program.getHealingItemsFromMemory() function
function Program.getBagStatusItems()
	local statusItems = {
		poison = 0,
		burn = 0,
		freeze = 0,
		sleep = 0,
		paralyze = 0,
		confuse = 0,
		all = 0,
	}

	for _, item in pairs(MiscData.statusItems) do
		local quantity = Program.getNumItemsFromMemory(item.pocket, item.id)
		if quantity > 0 then
			print(item.name)
			if item.type == StatusType.Poison then
				statusItems.poison = statusItems.poison + quantity
			elseif item.type == StatusType.Burn then
				statusItems.burn = statusItems.burn + quantity
			elseif item.type == StatusType.Freeze then
				statusItems.freeze = statusItems.freeze + quantity
			elseif item.type == StatusType.Sleep then
				statusItems.sleep = statusItems.sleep + quantity
			elseif item.type == StatusType.Paralyze then
				statusItems.paralyze = statusItems.paralyze + quantity
			elseif item.type == StatusType.Confuse then
				statusItems.confuse = statusItems.confuse + quantity
			elseif item.type == StatusType.All then
				statusItems.all = statusItems.all + quantity
			end
			print(statusItems)
		end
	end

	return statusItems
end

function Program.getHealingItemsFromMemory()
	--battle can be set a few frames before item bag for battle gets updated, need to check this value as well
	-- local startAddress = Utils.inlineIf(Tracker.Data.inBattle, GameSettings.itemStartBattle, GameSettings.itemStartNoBattle)
	-- local itemid_and_quantity = Memory.readdword(GameSettings.bagPocket_Items)
	-- local itemid = Utils.getbits(itemid_and_quantity, 0, 16)
	-- local quantity = Utils.getbits(itemid_and_quantity, 16, 16)
	-- if quantity > 1000 or itemid > 600 then
	-- 	startAddress = GameSettings.itemStartNoBattle
	-- end

	-- I believe this key has to be looked-up each time, as the ptr changes periodically
	if GameSettings.gSaveBlock2ptr == 0 then return nil end -- safety check since ruby/sapphire ptr location is unknown
	local saveBlock2addr = Memory.readdword(GameSettings.gSaveBlock2ptr)
	local key = Memory.readword(saveBlock2addr + GameSettings.bagEncryptionKeyOffset)

	local healingItems = {}

	-- TODO: Definitely need to update this based on the battle-check info above^ Issue #37
	-- local addressesToScan = { startAddress, }
	local addressesToScan = {
		GameSettings.bagPocket_Items,
		GameSettings.bagPocket_Berries,
	}

	for _, address in pairs(addressesToScan) do
		local size = Utils.inlineIf(address == GameSettings.bagPocket_Items, GameSettings.bagPocket_Items_Size, GameSettings.bagPocket_Berries_Size)
		-- currentAddress = address
		-- local keepScanning = true
		for i = 0, (size - 1), 1 do
			--read 4 bytes at once, should be less expensive than reading two sets of 2 bytes.
			local itemid_and_quantity = Memory.readdword(address + i * 0x4)
			local itemID = Utils.getbits(itemid_and_quantity, 0, 16)
			-- print((address + i * 0x4) .. " -> " ..itemid_and_quantity .. ", id: " .. itemID .. ", q: " .. bit.bxor(Utils.getbits(itemid_and_quantity, 16, 16), key))
			if itemID ~= 0 then
				local quantity = bit.bxor(Utils.getbits(itemid_and_quantity, 16, 16), key)
				healingItems[itemID] = quantity
			-- else
				-- keepScanning = false
			end
		end
	end

	return healingItems
end
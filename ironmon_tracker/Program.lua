State = {
	TRACKER = "Tracker",
	SETTINGS = "Settings",
	THEME = "Theme",
}

Program = {
	trainerPokemonTeam = {},
	enemyPokemonTeam = {},
	state = State.TRACKER,
	PCHealTrackingButtonState = false,
}

Program.tracker = {
	movesToUpdate = {},
	abilitiesToUpdate = {},
	itemsToUpdate = {},
}

Program.StatButtonState = {
	hp = 1,
	att = 1,
	def = 1,
	spa = 1,
	spd = 1,
	spe = 1
}

Program.transformedPokemon = {
	isTransformed = false,
	forceSwitch = false,
}

Program.eventCallbacks = {}

function Program.main()
	Input.update()

	if Program.state == State.TRACKER then
		-- Update moves in the tracker
		for _, move in ipairs(Program.tracker.movesToUpdate) do
			Tracker.TrackMove(move.pokemonId, move.move, move.level)
		end
		Program.tracker.movesToUpdate = {}

		-- Update abilities in the tracker
		for _, ability in ipairs(Program.tracker.abilitiesToUpdate) do
			Tracker.TrackAbility(ability.pokemonId, ability.abilityId, false)
		end
		Program.tracker.abilitiesToUpdate = {}

		-- Update items in the tracker
		for _, item in ipairs(Program.tracker.itemsToUpdate) do
			Tracker.TrackItem(item.pokemonId, item.itemId)
		end
		Program.tracker.items = {}

		--Track encounter count?


		-- Execute event callbacks
		-- We do this during the next main loop instead of the callback itself because Bizhawk callback function context is JANK
		-- For example, the working directory in the context becomes the directory of EmuHawk.exe instead of the directory of the main Lua script
		for _, callback in ipairs(Program.eventCallbacks) do
			callback()
		end
		Program.eventCallbacks = {}

		-- Only redraw the UI when an event has occurred which requires the UI to be redrawn.
		-- TODO: This could be more granular for even more performance gains. In general, drawing to the UI is very cheap but reading values from emulated memory is very expensive
		if Tracker.redraw == true and Tracker.waitFrames == 0 then
			if Tracker.Data.inBattle == 1 then
				Program.UpdateMonPartySlots()
			end
			-- Refer to this for more improvement options https://github.com/Brian0255/NDS-Ironmon-Tracker/blob/main/ironmon_tracker/Program.lua
			Program.UpdatePokemonTeamDataFromMemory()
			Program.UpdateSelectedPokemonData()
			Program.UpdateTargetedPokemonData()
			Program.UpdateAbilityData()
			Program.UpdateMonStatStages()
			Program.UpdateMonPartySlots()
			Program.UpdateBagHealingItems()

			Program.StatButtonState = Tracker.getStatMarkings(Tracker.Data.selectedPokemon.pokemonID)
			Buttons = Program.updateButtons(Program.StatButtonState)

			if Tracker.Data.selectedPlayer == 2 then
				Drawing.DrawTracker(Tracker.Data.selectedPokemon, true, Tracker.Data.targetedPokemon)
			else
				if Tracker.Data.needCheckSummary == 0 then
					Drawing.DrawTracker(Tracker.Data.selectedPokemon, false, Tracker.Data.targetedPokemon)
				else
					Drawing.DrawTracker(Tracker.Data.selectedPokemon, true, Tracker.Data.targetedPokemon)
				end
			end

			Tracker.redraw = false
		end

		if Tracker.waitFrames > 0 then
			Tracker.waitFrames = Tracker.waitFrames - 1
		end
	elseif Program.state == State.SETTINGS then
		if Options.redraw then
			Drawing.drawSettings()
			Options.redraw = false
		end
	elseif Program.state == State.THEME then
		if Theme.redraw == true and Tracker.waitFrames == 0 then
			if Theme.redraw then
				Drawing.drawThemeMenu()
				Theme.redraw = false
				Tracker.waitFrames = 5
			end
		end
		if Tracker.waitFrames > 0 then
			Tracker.waitFrames = Tracker.waitFrames - 1
		end
	end
end

function Program.UpdatePokemonTeamDataFromMemory()
	Program.trainerPokemonTeam = Program.getTrainerData(1)
	Program.enemyPokemonTeam = Program.getTrainerData(2)
end

function Program.UpdateSelectedPokemonData()
	local pokemonaux = Program.getPokemonData({ player = Tracker.Data.selectedPlayer, slot = Tracker.Data.selectedSlot })
	if Program.validPokemonData(pokemonaux) then
		Tracker.Data.selectedPokemon = pokemonaux
	end

	-- TODO: Verify we don't need to do this since all the data is being tracked already.
	-- if Tracker.Data.selectedPokemon ~= nil then
	-- 	if Tracker.Data.selectedPokemon.pokemonID ~= nil then
	-- 		Tracker.Data.selectedPokemon.moves = Tracker.getMoves(Tracker.Data.selectedPokemon.pokemonID + 1)
	-- 		Tracker.Data.selectedPokemon.abilities = Tracker.getAbilities(Tracker.Data.selectedPokemon.pokemonID + 1)
	-- 	end
	-- end
end

-- TODO: Is this the "last seen pokemon" we want to try?
function Program.UpdateTargetedPokemonData()
	local pokemontarget = Program.getPokemonData({ player = Tracker.Data.targetPlayer, slot = Tracker.Data.targetSlot })
	if Program.validPokemonData(pokemontarget) then
		Tracker.Data.targetedPokemon = pokemontarget
	else
		Tracker.Data.targetedPokemon = nil
	end
end

-- TODO: Rewrite this later
function Program.UpdateAbilityData()
	-- Only update ability data if new data was found [during battle]
	if Tracker.Data.inBattle == 0 then
		return
	end

	-- TODO: First we want to be tracking our pokemon team data and last seen pokemon. 
	-- Then, if that data has holes, use this to update with memory reads.

	-- Note which ability (of possible two) the selected Pokemon has
	local battleAbility = Memory.readbyte(GameSettings.gBattleMons + 0x20 + ((Tracker.Data.selectedPlayer - 1) * 0x58))
	if battleAbility ~= 0 then
		-- Store this data somehow so we can have it permanently without tracking literally every seen pokemon
		Tracker.Data.selectedPokemon.currentAbility = battleAbility
	end

	local slotZeroAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities)
	local slotOneAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x1)
	local slotTwoAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x2)
	local slotThreeAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x3)

	local selfSlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
	local selfSlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotTwo) + 1
	local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
	local enemySlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1

	-- TODO: Check if Trace and Transform override this information (they probably do)
	if Program.trainerPokemonTeam[selfSlotOne] ~= nil and slotZeroAbilityId ~= 0 then
		print("T1pkmID: " .. (Program.trainerPokemonTeam[selfSlotOne].pkmID + 1) .. ", abilityId: " .. slotZeroAbilityId)
		Tracker.TrackAbility(Program.trainerPokemonTeam[selfSlotOne].pkmID + 1, slotZeroAbilityId, true)
	end
	if Program.trainerPokemonTeam[selfSlotTwo] ~= nil and slotTwoAbilityId ~= 0 then
		print("T2pkmID: " .. (Program.trainerPokemonTeam[selfSlotTwo].pkmID + 1) .. ", abilityId: " .. slotTwoAbilityId)
		Tracker.TrackAbility(Program.trainerPokemonTeam[selfSlotTwo].pkmID + 1, slotTwoAbilityId, true)
	end
	if Program.enemyPokemonTeam[enemySlotOne] ~= nil and slotOneAbilityId ~= 0 then
		print("E1pkmID: " .. (Program.enemyPokemonTeam[enemySlotOne].pkmID + 1) .. ", abilityId: " .. slotOneAbilityId)
		Tracker.TrackAbility(Program.enemyPokemonTeam[enemySlotOne].pkmID + 1, slotOneAbilityId, false)
	end
	if Program.enemyPokemonTeam[enemySlotTwo] ~= nil and slotThreeAbilityId ~= 0 then
		print("E2pkmID: " .. (Program.enemyPokemonTeam[enemySlotTwo].pkmID + 1) .. ", abilityId: " .. slotThreeAbilityId)
		Tracker.TrackAbility(Program.enemyPokemonTeam[enemySlotTwo].pkmID + 1, slotThreeAbilityId, false)
	end
	
	-- OLD CODE TO RECHECK
	-- Tracker.Data.main.ability = Program.getMainAbility()
end

function Program.UpdateMonStatStages()
	-- TODO: Update for double battles
	local battleMonSlot = Tracker.Data.selectedPlayer - 1
	local battleMon = Program.getBattleMon(battleMonSlot)
	if battleMon.statStages["HP"] ~= 0 then
		Tracker.Data.selectedPokemon.statStages = battleMon.statStages
	else
		Tracker.Data.selectedPokemon.statStages = { HP = 6, ATK = 6, DEF = 6, SPE = 6, SPA = 6, SPD = 6, ACC = 6, EVASION = 6 }
	end
end

function Program.UpdateMonPartySlots()
	local attackerValue = Memory.readbyte(GameSettings.gBattlerAttacker)
	Tracker.Data.selfSlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
	Tracker.Data.enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
	Tracker.Data.selfSlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotTwo) + 1
	Tracker.Data.enemySlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1

	if attackerValue % 2 == 1 then
		if attackerValue == 1 then
			Tracker.Data.selectedSlot = Tracker.Data.enemySlotOne
			Tracker.Data.targetSlot = Tracker.Data.selfSlotOne
		elseif attackerValue == 3 then
			Tracker.Data.selectedSlot = Tracker.Data.enemySlotTwo
			Tracker.Data.targetSlot = Tracker.Data.selfSlotOne
		end
	end

	if Tracker.Data.selectedPlayer == 1 then
		Tracker.Data.selectedSlot = Tracker.Data.selfSlotOne
		Tracker.Data.targetSlot = Tracker.Data.enemySlotOne
	end
end

function Program.UpdateBagHealingItems()
	local healingItems = Program.getBagHealingItems(Tracker.Data.selectedPokemon)
	if healingItems ~= nil then
		Tracker.Data.healingItems = healingItems
	end
end

function Program.BattleEnded()
	Tracker.Data.selfSlotOne = 1
	Tracker.Data.selectedSlot = Tracker.Data.selfSlotOne
	Tracker.Data.selectedPokemon.statStages = { HP = 6, ATK = 6, DEF = 6, SPE = 6, SPA = 6, SPD = 6, ACC = 6, EVASION = 6 }

	Tracker.Data.targetedPokemon = nil
	Tracker.redraw = true
	Tracker.waitFrames = 60

	Tracker.saveData()
end

function Program.updateButtons(state)
	Buttons[1].text = StatButtonStates[state["hp"]]
	Buttons[2].text = StatButtonStates[state["att"]]
	Buttons[3].text = StatButtonStates[state["def"]]
	Buttons[4].text = StatButtonStates[state["spa"]]
	Buttons[5].text = StatButtonStates[state["spd"]]
	Buttons[6].text = StatButtonStates[state["spe"]]
	Buttons[1].textcolor = StatButtonColors[state["hp"]]
	Buttons[2].textcolor = StatButtonColors[state["att"]]
	Buttons[3].textcolor = StatButtonColors[state["def"]]
	Buttons[4].textcolor = StatButtonColors[state["spa"]]
	Buttons[5].textcolor = StatButtonColors[state["spd"]]
	Buttons[6].textcolor = StatButtonColors[state["spe"]]
	return Buttons
end

-- TODO: Verify we don't need this anymore
function Program.getMainAbility()
	local abilityValue = Memory.readbyte(GameSettings.sBattlerAbilities) + 1
	if abilityValue ~= 1 then
		return abilityValue
	else
		return Tracker.Data.main.ability
	end
	-- Set main pokemon's ability. TODO: Update when main pokemon changes
	return abilityValue
end

function Program.HandleTrainerSentOutPkmn()
	Tracker.controller.statIndex = 6
	Tracker.Data.inBattle = 1
	Tracker.Data.selectedSlot = 1

	if Options["Auto swap to enemy"] then
		Tracker.Data.selectedPlayer = 2
		Tracker.Data.targetPlayer = 1
		Tracker.Data.targetSlot = 1
	end

	Tracker.waitFrames = 100
	Tracker.redraw = true
end

function Program.HandleEndBattle()
	Tracker.Data.inBattle = 0
	Tracker.Data.selectedPlayer = 1
	Tracker.Data.selectedSlot = 1
	Tracker.Data.targetPlayer = 2
	Tracker.Data.targetSlot = 1

	Tracker.Data.targetedPokemon = nil

	Tracker.redraw = true

	table.insert(Program.eventCallbacks, Program.BattleEnded)
end

function Program.HandleShowSummary()
	Tracker.Data.needCheckSummary = 0
	Tracker.redraw = true
end

function Program.HandleSwitchSelectedMons()
	Tracker.redraw = true
	Tracker.waitFrames = 30

	if Options["Hide stats until summary shown"] == true then
		Tracker.Data.needCheckSummary = 1
	end
end

function Program.HandleCalculateMonStats()
	Tracker.redraw = true
end

function Program.HandleDisplayMonLearnedMove()
	Tracker.redraw = true
end

function Program.HandleUpdatePoisonStepCounter()
	-- Only update the tracker for poison damage if the lead Pokémon is poisoned
	if Tracker.Data.selectedPokemon.status == 2 then
		Tracker.redraw = true
	end
end

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
	-- This goes here so mon hp always gets updated on PC heal
	Tracker.redraw = true
end

function Program.HandleWeHopeToSeeYouAgain()
	Tracker.redraw = true
end

function Program.HandleDoPokeballSendOutAnimation()
	if Tracker.Data.inBattle == 0 then
		Tracker.Data.selectedSlot = 1
		Tracker.Data.targetPlayer = 2
		Tracker.Data.targetSlot = 1
	end

	if Program.transformedPokemon.isTransformed and not Program.transformedPokemon.forceSwitch then
		-- Reset the transform tracking disable unless player was force-switched by roar/whirlwind
		Program.transformedPokemon.isTransformed = false
	end

	if Options["Auto swap to enemy"] then
		Tracker.Data.selectedPlayer = 2
		Tracker.Data.targetPlayer = 1
		Tracker.Data.targetSlot = 1
	end

	Tracker.controller.statIndex = 6
	Tracker.Data.inBattle = 1
	Tracker.waitFrames = 90
	Tracker.redraw = true
end

-- ABILITY EVENT HANDLERS

function Program.HandleBattleScriptDrizzleActivates()
	Program.HandleAbilityActivate(2)
end

function Program.HandleBattleScriptSpeedBoostActivates()
	Program.HandleAbilityActivate(3)
end

function Program.HandleBattleScriptTraceActivates()
	Program.HandleAbilityActivate(36)
end

function Program.HandleBattleScriptRainDishActivates()
	Program.HandleAbilityActivate(44)
end

function Program.HandleBattleScriptSandstreamActivates()
	Program.HandleAbilityActivate(45)
end

function Program.HandleBattleScriptShedSkinActivates()
	Program.HandleAbilityActivate(61)
end

function Program.HandleBattleScriptIntimidateActivates()
	Program.HandleAbilityActivate(22)
end

function Program.HandleBattleScriptDroughtActivates()
	Program.HandleAbilityActivate(70)
end

function Program.HandleBattleScriptStickyHoldActivates()
	Program.HandleAbilityActivate(60)
end

function Program.HandleBattleScriptColorChangeActivates()
	Program.HandleAbilityActivate(16)
end

function Program.HandleBattleScriptRoughSkinActivates()
	Program.HandleAbilityActivate(24)
end

function Program.HandleBattleScriptCuteCharmActivates()
	Program.HandleAbilityActivate(56)
end

function Program.HandleBattleScriptSynchronizeActivates()
	Program.HandleAbilityActivate(28)
end

-- END ABILITY EVENT HANDLERS

function Program.obtainBadge(badgeNumber)
	if badgeNumber >= 1 and badgeNumber <= 8 then
		Tracker.Data.badges[badgeNumber] = 1 -- Marks badge as obtained
		Buttons.updateBadges()
		Tracker.redraw = true
	else
		print("Unable to track obtaining badge #" .. badgeNumber)
	end
end

function Program.HandleBadgeOneObtained()
	Program.obtainBadge(1)
end
function Program.HandleBadgeTwoObtained()
	Program.obtainBadge(2)
end
function Program.HandleBadgeThreeObtained()
	Program.obtainBadge(3)
end
function Program.HandleBadgeFourObtained()
	Program.obtainBadge(4)
end
function Program.HandleBadgeFiveObtained()
	Program.obtainBadge(5)
end
function Program.HandleBadgeSixObtained()
	Program.obtainBadge(6)
end
function Program.HandleBadgeSevenObtained()
	Program.obtainBadge(7)
end
function Program.HandleBadgeEightObtained()
	Program.obtainBadge(8)
end

function Program.HandleExit()
	Drawing.clearGUI()
	if Input.noteForm then
		forms.destroy(Input.noteForm)
	end
end

function Program.HandleMove()
	local moveValue = Memory.readword(GameSettings.gChosenMove) + 1
	local attackerValue = Memory.readbyte(GameSettings.gBattlerAttacker)

	if attackerValue % 2 == 1 then -- Opponent pokemon
		local selfSlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1

		local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
		local enemySlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1

		local pokemonId = 1
		local level = 1
		if attackerValue == 1 then
			pokemonId = Program.enemyPokemonTeam[enemySlotOne].pkmID
			level = Program.enemyPokemonTeam[enemySlotOne].level
			if Options["Auto swap to enemy"] then
				Tracker.Data.selectedPlayer = 2
				Tracker.Data.selectedSlot = enemySlotOne
				Tracker.Data.targetPlayer = 1
				Tracker.Data.targetSlot = selfSlotOne
			end
		elseif attackerValue == 3 then
			pokemonId = Program.enemyPokemonTeam[enemySlotTwo].pkmID
			level = Program.enemyPokemonTeam[enemySlotTwo].level
			if Options["Auto swap to enemy"] then
				Tracker.Data.selectedPlayer = 2
				Tracker.Data.selectedSlot = enemySlotTwo
				Tracker.Data.targetPlayer = 1
				Tracker.Data.targetSlot = selfSlotOne
			end
		end

		-- Stop tracking moves temporarily while transformed
		if not Program.transformedPokemon.isTransformed then
			table.insert(Program.tracker.movesToUpdate, { pokemonId = pokemonId + 1, move = moveValue, level = level })
		elseif moveValue == 19 or moveValue == 47 then
			-- Account for niche scenario of force-switch moves being used while transformed
			Program.transformedPokemon.forceSwitch = true
		elseif Program.transformedPokemon.forceSwitch then
			-- Reset when another move is used
			Program.transformedPokemon.forceSwitch = false
		end
		-- This comes after so transform itself gets tracked
		if moveValue == 145 then
			Program.transformedPokemon.isTransformed = true
		end
	end

	Tracker.redraw = true
	Tracker.waitFrames = 30
end

function Program.HandleAbilityActivate(abilityId)
	local slotZeroAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities)
	local slotOneAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x1)
	local slotTwoAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x2)
	local slotThreeAbilityId = Memory.readbyte(GameSettings.sBattlerAbilities + 0x3)

	local selfSlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
	local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
	local selfSlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotTwo) + 1
	local enemySlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1

	local pkmnId = 0
	if slotZeroAbilityId == abilityId then
		pkmnId = Program.trainerPokemonTeam[selfSlotOne].pkmID
	elseif slotOneAbilityId == abilityId then
		pkmnId = Program.enemyPokemonTeam[enemySlotOne].pkmID
	elseif slotTwoAbilityId == abilityId then
		pkmnId = Program.trainerPokemonTeam[selfSlotTwo].pkmID
	elseif slotThreeAbilityId == abilityId then
		pkmnId = Program.enemyPokemonTeam[enemySlotTwo].pkmID
	end

	table.insert(Program.tracker.abilitiesToUpdate, { pokemonId = pkmnId + 1, abilityId = abilityId })

	Tracker.redraw = true
end

function Program.getTrainerData(index)
	local trainerdata = {}
	local st = 0
	if index == 1 then
		st = GameSettings.pstats
	else
		st = GameSettings.estats
	end
	for i = 1, 6, 1 do
		local start = st + 100 * (i - 1)
		local personality = Memory.readdword(start)
		local magicword = bit.bxor(personality, Memory.readdword(start + 4))
		local growthoffset = (TableData.growth[(personality % 24) + 1] - 1) * 12
		local growth = bit.bxor(Memory.readdword(start + 32 + growthoffset), magicword)
		trainerdata[i] = {
			pkmID = Utils.getbits(growth, 0, 16),
			curHP = Memory.readword(start + 86),
			maxHP = Memory.readword(start + 88),
			level = Memory.readbyte(start + 84)
		}
	end
	return trainerdata
end

function Program.getPokemonData(index)
	local start
	if index.player == 1 then
		start = GameSettings.pstats + 100 * (index.slot - 1)
	else
		start = GameSettings.estats + 100 * (index.slot - 1)
	end

	local personality = Memory.readdword(start)
	local otid = Memory.readdword(start + 4)
	local magicword = bit.bxor(personality, otid)

	local aux          = personality % 24
	local growthoffset = (TableData.growth[aux + 1] - 1) * 12
	local attackoffset = (TableData.attack[aux + 1] - 1) * 12
	local effortoffset = (TableData.effort[aux + 1] - 1) * 12
	local miscoffset   = (TableData.misc[aux + 1] - 1) * 12

	local growth1 = bit.bxor(Memory.readdword(start + 32 + growthoffset), magicword)
	local growth2 = bit.bxor(Memory.readdword(start + 32 + growthoffset + 4), magicword)
	local growth3 = bit.bxor(Memory.readdword(start + 32 + growthoffset + 8), magicword)
	local attack1 = bit.bxor(Memory.readdword(start + 32 + attackoffset), magicword)
	local attack2 = bit.bxor(Memory.readdword(start + 32 + attackoffset + 4), magicword)
	local attack3 = bit.bxor(Memory.readdword(start + 32 + attackoffset + 8), magicword)
	local effort1 = bit.bxor(Memory.readdword(start + 32 + effortoffset), magicword)
	local effort2 = bit.bxor(Memory.readdword(start + 32 + effortoffset + 4), magicword)
	local effort3 = bit.bxor(Memory.readdword(start + 32 + effortoffset + 8), magicword)
	local misc1   = bit.bxor(Memory.readdword(start + 32 + miscoffset), magicword)
	local misc2   = bit.bxor(Memory.readdword(start + 32 + miscoffset + 4), magicword)
	local misc3   = bit.bxor(Memory.readdword(start + 32 + miscoffset + 8), magicword)

	local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
			+ Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
			+ Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
			+ Utils.addhalves(misc1) + Utils.addhalves(misc2) + Utils.addhalves(misc3)
	cs = cs % 65536

	local status_aux = Memory.readdword(start + 80)
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

	return {
		pokemonID = Utils.getbits(growth1, 0, 16),
		heldItem = Utils.getbits(growth1, 16, 16),
		experience = Utils.getbits(growth2, 32, 31),
		friendship = Utils.getbits(growth3, 72, 8),
		pokerus = Utils.getbits(misc1, 0, 8),
		tid = Utils.getbits(otid, 0, 16),
		sid = Utils.getbits(otid, 16, 16),
		iv = misc2,
		ev1 = effort1,
		ev2 = effort2,
		level = Memory.readbyte(start + 84),
		nature = personality % 25,
		pp = attack3,
		move1 = Utils.getbits(attack1, 0, 16),
		move2 = Utils.getbits(attack1, 16, 16),
		move3 = Utils.getbits(attack2, 0, 16),
		move4 = Utils.getbits(attack2, 16, 16),
		curHP = Memory.readword(start + 86),
		maxHP = Memory.readword(start + 88),
		atk = Memory.readword(start + 90),
		def = Memory.readword(start + 92),
		spe = Memory.readword(start + 94),
		spa = Memory.readword(start + 96),
		spd = Memory.readword(start + 98),
		status = status_result,
		sleep_turns = sleep_turns_result,
		ability = 0,
	}
end

function Program.validPokemonData(pokemonData)
	if pokemonData["pokemonID"] < 0 or pokemonData["pokemonID"] > 412 or pokemonData["heldItem"] < 0 or pokemonData["heldItem"] > 376 then
		return false
	elseif pokemonData["move1"] < 0 or pokemonData["move2"] < 0 or pokemonData["move3"] < 0 or pokemonData["move4"] < 0 then
		return false
	elseif pokemonData["move1"] > 354 or pokemonData["move2"] > 354 or pokemonData["move3"] > 354 or pokemonData["move4"] > 354 then
		return false
	else
		return true
	end
end

function Program.getBattleMon(index)
	local base = GameSettings.gBattleMons + (index * 0x58)

	return {
		-- species = Memory.readword(base + 0x0),
		-- attack = Memory.readword(base + 0x2),
		-- defense = Memory.readword(base + 0x4),
		-- speed = Memory.readword(base + 0x6),
		-- spAttack = Memory.readword(base + 0x8),
		-- spDefense = Memory.readword(base + 0xA),
		-- moves = {
		-- 	[1] = Memory.readword(base + 0xC),
		-- 	[2] = Memory.readword(base + 0xE),
		-- 	[3] = Memory.readword(base + 0x10),
		-- 	[4] = Memory.readword(base + 0x12)
		-- },
		-- IVs, isEgg, abilityNum excluded
		statStages = {
			HP = Memory.readbyte(base + 0x18),
			ATK = Memory.readbyte(base + 0x19),
			DEF = Memory.readbyte(base + 0x1A),
			SPE = Memory.readbyte(base + 0x1B),
			SPA = Memory.readbyte(base + 0x1C),
			SPD = Memory.readbyte(base + 0x1D),
			ACC = Memory.readbyte(base + 0x1E),
			EVASION = Memory.readbyte(base + 0x1F)
		},
		ability = Memory.readbyte(base + 0x20),
		friendship = Memory.readbyte(base + 0x2B),
	}
end

function Program.getNumItems(pocket, itemId)
	local pockets = {
		[BagPocket.Items] = {
			addr = GameSettings.bagPocket_Items,
			size = GameSettings.bagPocket_Items_Size,
		},
		[BagPocket.Berries] = {
			addr = GameSettings.bagPocket_Berries,
			size = GameSettings.bagPocket_Berries_Size,
		},
	}

	local saveBlock2addr = Memory.readdword(GameSettings.gSaveBlock2ptr)
	local key = Memory.readword(saveBlock2addr + GameSettings.bagEncryptionKeyOffset)
	for i = 0x0, pockets[pocket].size * 0x4, 0x4 do
		local id = Memory.readword(pockets[pocket].addr + i)
		if id == itemId then
			local quantity = bit.bxor(Memory.readword(pockets[pocket].addr + i + 0x2), key)
			return quantity
		end
	end
	return 0
end

function Program.getBagHealingItems(pkmn)
	local totals = {
		healing = 0,
		numHeals = 0,
	}
	-- Need a null check before getting maxHP
	if pkmn == nil then
		return totals
	end

	local maxHP = pkmn["maxHP"]
	if maxHP == 0 then
		return totals
	end

	for _, item in pairs(MiscData.healingItems) do
		local quantity = Program.getNumItems(item.pocket, item.id)
		if quantity > 0 then
			local healing = 0
			if item.type == HealingType.Constant then
				local percentage = ((item.amount / maxHP) * 100)
				if percentage > 100 then
					percentage = 100
				end
				healing = percentage * quantity
			elseif item.type == HealingType.Percentage then
				healing = item.amount * quantity
			end
			-- Healing is in a percentage compared to the mon's max HP
			totals.healing = totals.healing + healing
			totals.numHeals = totals.numHeals + quantity
		end
	end

	-- Sanity checking, because for some reason gSaveBlock2Ptr
	if totals.healing > 1000000 then
		return nil
	end

	return totals
end

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
		local quantity = Program.getNumItems(item.pocket, item.id)
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

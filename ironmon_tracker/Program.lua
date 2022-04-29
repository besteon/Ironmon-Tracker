Program = {
	trainerPokemonTeam = {},
	enemyPokemonTeam = {},
}
Program.rng = {
	current = 0,
	previous = 0,
	grid = {}
}
Program.map = {
	id = 0,
	encounters = {
		{
			encrate = -1,
			SLOTS = 12,
			RATES = {20,20,10,10,10,10,5,5,4,4,1,1}
		},
		{
			encrate = -1,
			SLOTS = 5,
			RATES = {60,30,5,4,1}
		},
		{
			encrate = -1,
			SLOTS = 5,
			RATES = {60,30,5,4,1}
		}
	}
}
Program.catchdata = {
	pokemon = 1,
	curHP = 20,
	maxHP = 20,
	level = 5,
	ball = 4,
	status = 0,
	rng = 0,
	rate = 0
}

Program.tracker = {
	movesToUpdate = {},
	abilitiesToUpdate = {},
	itemsToUpdate = {},
	previousAttacker = 0,
}

Program.StatButtonState = {
	hp = 1,
	att = 1,
	def = 1,
	spa = 1,
	spd = 1,
	spe = 1
}

function Program.main()
	Input.update()

	-- Update moves in the tracker
	for _, move in ipairs(Program.tracker.movesToUpdate) do
		Tracker.TrackMove(move.pokemonId, move.move, move.level)
	end
	Program.tracker.movesToUpdate = {}

	-- Update abilities in the tracker
	for _, ability in ipairs(Program.tracker.abilitiesToUpdate) do
		Tracker.TrackAbility(ability.pokemonId, ability.abilityId)
	end
	Program.tracker.abilitiesToUpdate = {}

	-- Update items in the tracker
	for _, item in ipairs(Program.tracker.itemsToUpdate) do
		Tracker.TrackItem(item.pokemonId, item.itemId)
	end
	Program.tracker.items = {}

	if Tracker.Data.inBattle == 1 then
		Tracker.redraw = true
	end

	if Tracker.redraw == true and Tracker.waitFrames == 0 then
		Program.trainerPokemonTeam = Program.getTrainerData(1)
		Program.enemyPokemonTeam = Program.getTrainerData(2)
	
		Program.updateTracker()
	
		if Tracker.Data.player == 2 then
			Drawing.drawTrackerView()
		else
			if Tracker.Data.needCheckSummary == 0 then
				Drawing.drawPokemonView()
			else
				Drawing.drawTrackerView()
			end
		end
		Program.StatButtonState = Tracker.getButtonState()
		Buttons = Program.updateButtons(Program.StatButtonState)
		Drawing.drawButtons()
		Drawing.drawInputOverlay()
		Tracker.redraw = false
	end

	if Tracker.waitFrames > 0 then
		Tracker.waitFrames = Tracker.waitFrames - 1
	end
end

function Program.updateTracker()
	local pokemonaux = Program.getPokemonData({ player = Tracker.Data.player, slot = Tracker.Data.slot })
	local attackerValue = Memory.readbyte(GameSettings.gBattlerAttacker)

	local battleMonSlot = Tracker.Data.slot + ((Tracker.Data.player + 1) % 2)

	if Program.validPokemonData(pokemonaux) then
		Tracker.Data.selectedPokemon = pokemonaux
	end
	
	Tracker.Data.main.ability = Program.getMainAbility()

	if Tracker.Data.inBattle == 1 then
		local battleMon = Program.getBattleMon(battleMonSlot)
		if battleMon.statStages["HP"] ~= 0 then
			Tracker.Data.selectedPokemon.statStages = battleMon.statStages
			Tracker.Data.selectedPokemon.ability = battleMon.ability
		else
			Tracker.Data.selectedPokemon.statStages = { HP = 6, ATK = 6, DEF = 6, SPEED = 6, SPATK = 6, SPDEF = 6, ACC = 6, EVASION = 6 }
		end

		Tracker.Data.selfSlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
		Tracker.Data.enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
		Tracker.Data.selfSlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotTwo) + 1
		Tracker.Data.enemySlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1

		if attackerValue % 2 == 1 then
			if attackerValue == 1 then
				Tracker.Data.slot = Tracker.Data.enemySlotOne
			elseif attackerValue == 3 then
				Tracker.Data.slot = Tracker.Data.enemySlotTwo
			end
		end

		if Tracker.Data.player == 1 then
			Tracker.Data.slot = Tracker.Data.selfSlotOne
		end
	else
		Tracker.Data.selfSlotOne = 1
		Tracker.Data.slot = Tracker.Data.selfSlotOne
		Tracker.Data.selectedPokemon.statStages = { HP = 6, ATK = 6, DEF = 6, SPEED = 6, SPATK = 6, SPDEF = 6, ACC = 6, EVASION = 6 }
	end

	if Tracker.Data.selectedPokemon ~= nil then
		if Tracker.Data.selectedPokemon.pokemonID ~= nil then
			Tracker.Data.currentlyTrackedPokemonMoves = Tracker.getMoves(Tracker.Data.selectedPokemon.pokemonID + 1)
			Tracker.Data.currentlyTrackedPokemonAbilities = Tracker.getAbilities(Tracker.Data.selectedPokemon.pokemonID + 1)
		end
	end
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

function Program.HandleBeginBattle()
	Tracker.controller.statIndex = 6
	Tracker.Data.inBattle = 1
	Tracker.Data.slot = 1

	if Settings.autoTrackOpponentMons then
		Tracker.Data.player = 2
	end

	Tracker.waitFrames = 180
end

function Program.HandleStartWildBattle()
	Tracker.controller.statIndex = 6
	Tracker.Data.inBattle = 1
	Tracker.Data.slot = 1

	if Settings.autoTrackOpponentMons then
		Tracker.Data.player = 2
	end

	Tracker.waitFrames = 280
end

function Program.HandleTrainerSentOutPkmn()
	Tracker.controller.statIndex = 6
	Tracker.Data.inBattle = 1
	Tracker.Data.slot = 1

	if Settings.autoTrackOpponentMons then
		Tracker.Data.player = 2
	end

	Tracker.waitFrames = 100
end

function Program.HandleEndBattle()
	Tracker.Data.inBattle = 0
	Tracker.Data.player = 1
	Tracker.Data.slot = 1

	Tracker.redraw = true
end

function Program.HandleShowSummary()
	Tracker.Data.needCheckSummary = 0
	Tracker.redraw = true
end

function Program.HandleSwitchSelectedMons()
	Tracker.redraw = true
	Tracker.waitFrames = 30

	if Settings.streamerMode == true then
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
	Tracker.redraw = true
end

function Program.HandleWeHopeToSeeYouAgain()
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

function Program.HandleExit()
	Drawing.clearGUI()
end

function Program.HandleMove()
	local moveValue = Memory.readword(GameSettings.gChosenMove) + 1
	local attackerValue = Memory.readbyte(GameSettings.gBattlerAttacker)

	if attackerValue % 2 == 1 then -- Opponent pokemon
		local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
		local enemySlotTwo = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotTwo) + 1

		local pokemonId = 1
		local level = 1
		if attackerValue == 1 then
			pokemonId = Program.enemyPokemonTeam[enemySlotOne].pkmID
			level = Program.enemyPokemonTeam[enemySlotOne].level
			if Settings.autoTrackOpponentMons then
				Tracker.Data.player = 2
				Tracker.Data.slot = enemySlotOne
			end
		elseif attackerValue == 3 then
			pokemonId = Program.enemyPokemonTeam[enemySlotTwo].pkmID
			level = Program.enemyPokemonTeam[enemySlotTwo].level
			if Settings.autoTrackOpponentMons then
				Tracker.Data.player = 2
				Tracker.Data.slot = enemySlotTwo
			end
		end
		table.insert(Program.tracker.movesToUpdate, { pokemonId = pokemonId + 1, move = moveValue, level = level })
	end
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
end

function Program.getTrainerData(index)
	local trainerdata = {}
	local st = 0
	if index == 1 then
		st = GameSettings.pstats
	else
		st = GameSettings.estats
	end
	for i = 1,6,1 do
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
	
	local aux = personality % 24
	local growthoffset = (TableData.growth[aux+1] - 1) * 12
	local attackoffset = (TableData.attack[aux+1] - 1) * 12
	local effortoffset = (TableData.effort[aux+1] - 1) * 12
	local miscoffset   = (TableData.misc[aux+1]   - 1) * 12
	
	local growth1 = bit.bxor(Memory.readdword(start+32+growthoffset),   magicword)
	local growth2 = bit.bxor(Memory.readdword(start+32+growthoffset+4), magicword)
	local growth3 = bit.bxor(Memory.readdword(start+32+growthoffset+8), magicword)
	local attack1 = bit.bxor(Memory.readdword(start+32+attackoffset),   magicword)
	local attack2 = bit.bxor(Memory.readdword(start+32+attackoffset+4), magicword)
	local attack3 = bit.bxor(Memory.readdword(start+32+attackoffset+8), magicword)
	local effort1 = bit.bxor(Memory.readdword(start+32+effortoffset),   magicword)
	local effort2 = bit.bxor(Memory.readdword(start+32+effortoffset+4), magicword)
	local effort3 = bit.bxor(Memory.readdword(start+32+effortoffset+8), magicword)
	local misc1   = bit.bxor(Memory.readdword(start+32+miscoffset),     magicword)
	local misc2   = bit.bxor(Memory.readdword(start+32+miscoffset+4),   magicword)
	local misc3   = bit.bxor(Memory.readdword(start+32+miscoffset+8),   magicword)
	
	local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	         + Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
			 + Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
			 + Utils.addhalves(misc1)   + Utils.addhalves(misc2)   + Utils.addhalves(misc3)
	cs = cs % 65536
	
	local status_aux = Memory.readdword(start+80)
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
		sleep_turns = sleep_turns_result
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
	local base = GameSettings.gBattleMons + ((index - 1) * 0x58)

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
			SPEED = Memory.readbyte(base + 0x1B),
			SPATK = Memory.readbyte(base + 0x1C),
			SPDEF = Memory.readbyte(base + 0x1D),
			ACC = Memory.readbyte(base + 0x1E),
			EVASION = Memory.readbyte(base + 0x1F)
		},
		ability = Memory.readbyte(base + 0x20)
	}
end
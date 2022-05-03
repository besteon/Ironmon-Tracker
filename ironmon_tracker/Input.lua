Input = {
	mousetab = {},
	mousetab_prev = {},
	joypad = {}
}

function Input.exp_offsets()
    -- Returns the exp offset, reminder that the exp is encrypted.
    -- Source : https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_III)#Data
    -- Source : https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_(Generation_III)
    local perso_orders = {
        1,      1,      1,      1,      1,      1,
        2,      2,      3,      4,      3,      4,
        2,      2,      3,      4,      3,      4,
        2,      2,      3,      4,      3,      4
    }  -- Couldn't manage to keep the strings and use indexing. The number are the index of the G accordin to personality % 24

    local personality_Gindex, substrct_offset, experience_offset
    personality_Gindex = memory.read_u32_le(0x02024284) % 24
    substrct_offset = perso_orders[(personality_Gindex) + 1] - 1

    -- + 32 to reach the data "section", then +4 to finally reach the exp of the G section.
    experience_offset = 0x02024284 + 32 + (12 * substrct_offset) + 4
    return experience_offset
end

function Input.decryption_key()
    -- Key used to decrypt the data... And to encrypt the new data...!
    -- Source : https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_(Generation_III)
    local personality, trainer_id
    personality = memory.read_u32_le(0x02024284)
    trainer_id = memory.read_u32_le(0x02024284 + 4)
    return bit.bxor(personality, trainer_id)

end

function Input.set_exp_for_evolve()
    local decrypted_exp
    decrypted_exp = bit.bxor(Input.decryption_key(), memory.read_u32_le(Input.exp_offsets()))

    -- Couldn't go higher except by doing some more shenanigans I don't want to at the moment.
    -- In the fluctuating category, it should set the pokemon lvl to 39ish.
    local new_exp, new_exp_crypted
    new_exp = 60000  
    new_exp_crypted = bit.bxor(new_exp, Input.decryption_key())

    local checksum
    checksum = memory.read_u16_le(0x02024284 + 28)

    Input.mousetab = input.getmouse()
	if Input.mousetab["Right"] then  -- We should change this command to something else. An ideas?
        memory.write_u32_le(Input.exp_offsets(), new_exp_crypted)
        memory.write_u16_le(0x02024284 + 28, checksum + (new_exp - decrypted_exp))        
    end
    Input.mousetab_prev = Input.mousetab
end

function Input.update()
	Input.mousetab = input.getmouse()
	if Input.mousetab["Left"] and not Input.mousetab_prev["Left"] then
		local xmouse = Input.mousetab["X"]
		local ymouse = Input.mousetab["Y"] + GraphicConstants.UP_GAP
		Input.check(xmouse, ymouse)
	end
	Input.mousetab_prev = Input.mousetab

	local joypadButtons = joypad.get()
	-- "Settings.controls.CYCLE_VIEW" pressed
	if joypadButtons[Settings.controls.CYCLE_VIEW] == true and Input.joypad[Settings.controls.CYCLE_VIEW] ~= joypadButtons[Settings.controls.CYCLE_VIEW] then
		if Tracker.Data.inBattle == 1 then
			Tracker.Data.player = (Tracker.Data.player % 2) + 1
			if Tracker.Data.player == 1 then
				Tracker.Data.slot = 1
			elseif Tracker.Data.player == 2 then
				local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
				Tracker.Data.slot = enemySlotOne
			end
		end

		Program.tracker.nextView = true
	end

	-- "Settings.controls.CYCLE_STAT" pressed, display box over next stat
	if joypadButtons[Settings.controls.CYCLE_STAT] == true and Input.joypad[Settings.controls.CYCLE_STAT] ~= joypadButtons[Settings.controls.CYCLE_STAT] then
		Tracker.controller.statIndex = (Tracker.controller.statIndex % 6) + 1
		Tracker.controller.framesSinceInput = 0
	else
		if Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames then
			Tracker.controller.framesSinceInput = Tracker.controller.framesSinceInput + 1
		end
	end

	-- "Settings.controls.NEXT_SEED"
	local allPressed = true
	for button in string.gmatch(Settings.controls.NEXT_SEED, '([^,]+)') do
		if joypadButtons[button] ~= true then
			allPressed = false
		end
	end
	if allPressed == true then
		Main.LoadNextSeed = true
	end

	-- "Settings.controls.CYCLE_PREDICTION" pressed, cycle stat prediction for selected stat
	if joypadButtons[Settings.controls.CYCLE_PREDICTION] == true and Input.joypad[Settings.controls.CYCLE_PREDICTION] ~= joypadButtons[Settings.controls.CYCLE_PREDICTION] then
		if Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames then
			if Tracker.controller.statIndex == 1 then
				Program.StatButtonState.hp = ((Program.StatButtonState.hp + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.hp]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.hp]
			elseif Tracker.controller.statIndex == 2 then
				Program.StatButtonState.att = ((Program.StatButtonState.att + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.att]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.att]
			elseif Tracker.controller.statIndex == 3 then
				Program.StatButtonState.def = ((Program.StatButtonState.def + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.def]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.def]
			elseif Tracker.controller.statIndex == 4 then
				Program.StatButtonState.spa = ((Program.StatButtonState.spa + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spa]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spa]
			elseif Tracker.controller.statIndex == 5 then
				Program.StatButtonState.spd = ((Program.StatButtonState.spd + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spd]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spd]
			elseif Tracker.controller.statIndex == 6 then
				Program.StatButtonState.spe = ((Program.StatButtonState.spe + 1) % 3) + 1
				Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spe]
				Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spe]
			end
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	end

	Input.joypad = joypadButtons
end

function Input.check(xmouse, ymouse)
---@diagnostic disable-next-line: deprecated
	for i = 1, table.getn(Buttons), 1 do
		if Buttons[i].visible() then
			if Buttons[i].type == ButtonType.singleButton then
				if Input.isInRange(xmouse, ymouse, Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4]) then
					Buttons[i].onclick()
				end
			end
		end
	end	
end

function Input.isInRange(xmouse,ymouse,x,y,xregion,yregion)
	if xmouse >= x and xmouse <= x + xregion then
		if ymouse >= y and ymouse <= y + yregion then
			return true
		end
	end
	return false
end
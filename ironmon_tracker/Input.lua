Input = {
	mousetab = {},
	mousetab_prev = {},
	joypad = {}
}

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
			Tracker.Data.selectedPlayer = (Tracker.Data.selectedPlayer % 2) + 1
			if Tracker.Data.selectedPlayer == 1 then
				Tracker.Data.selectedSlot = 1
				Tracker.Data.targetPlayer = 2
				Tracker.Data.targetSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
			elseif Tracker.Data.selectedPlayer == 2 then
				local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
				Tracker.Data.selectedSlot = enemySlotOne
				Tracker.Data.targetPlayer = 1
				Tracker.Data.targetSlot = Memory.readbyte(GameSettings.gBattlerPartyIndexesSelfSlotOne) + 1
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
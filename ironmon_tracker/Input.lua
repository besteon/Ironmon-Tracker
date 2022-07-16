Input = {
	mousetab = {},
	mousetab_prev = {},
	joypad = {},
	noteForm = nil,
	currentColorPicker = nil,
}

function Input.update()
	if Input.currentColorPicker ~= nil then
		Input.currentColorPicker:handleInput()
	else
		Input.mousetab = input.getmouse()
		if Input.mousetab["Left"] and not Input.mousetab_prev["Left"] then
			local xmouse = Input.mousetab["X"]
			local ymouse = Input.mousetab["Y"] + GraphicConstants.UP_GAP
			Input.check(xmouse, ymouse)
		end
		Input.mousetab_prev = Input.mousetab

		local joypadButtons = joypad.get()
		-- "Options.CONTROLS["Toggle view"]" pressed
		if joypadButtons[Options.CONTROLS["Toggle view"]] and Input.joypad[Options.CONTROLS["Toggle view"]] ~= joypadButtons[Options.CONTROLS["Toggle view"]] then
			if Tracker.Data.inBattle then
				Tracker.Data.isViewingOwn = not Tracker.Data.isViewingOwn
			end

			Program.waitToDrawFrames = 0
		end

		-- "Options.CONTROLS["Cycle through stats"]" pressed, display box over next stat
		if joypadButtons[Options.CONTROLS["Cycle through stats"]] and Input.joypad[Options.CONTROLS["Cycle through stats"]] ~= joypadButtons[Options.CONTROLS["Cycle through stats"]] then
			Tracker.controller.statIndex = (Tracker.controller.statIndex % 6) + 1
			Tracker.controller.framesSinceInput = 0
			Program.waitToDrawFrames = 0
		else
			if Tracker.controller.framesSinceInput == Tracker.controller.boxVisibleFrames - 1 then
				Program.waitToDrawFrames = 0
			end
			if Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames then
				Tracker.controller.framesSinceInput = Tracker.controller.framesSinceInput + 1
			end
		end

		-- "Options.CONTROLS["Load next seed"]"
		local allPressed = true
		for button in string.gmatch(Options.CONTROLS["Load next seed"], '([^,%s]+)') do
			if joypadButtons[button] ~= true then
				allPressed = false
			end
		end
		if allPressed == true then
			Main.LoadNextSeed = true
		end

		-- "Options.CONTROLS["Mark stat"]" pressed, cycle stat prediction for selected stat
		if joypadButtons[Options.CONTROLS["Mark stat"]] and Input.joypad[Options.CONTROLS["Mark stat"]] ~= joypadButtons[Options.CONTROLS["Mark stat"]] then
			if Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames then
				if Tracker.controller.statIndex == 1 then
					Program.StatButtonState.hp = ((Program.StatButtonState.hp + 1) % 3) + 1
					Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.hp]
					Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.hp]
					Tracker.controller.framesSinceInput = 0
				elseif Tracker.controller.statIndex == 2 then
					Program.StatButtonState.atk = ((Program.StatButtonState.atk + 1) % 3) + 1
					Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.atk]
					Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.atk]
					Tracker.controller.framesSinceInput = 0
				elseif Tracker.controller.statIndex == 3 then
					Program.StatButtonState.def = ((Program.StatButtonState.def + 1) % 3) + 1
					Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.def]
					Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.def]
					Tracker.controller.framesSinceInput = 0
				elseif Tracker.controller.statIndex == 4 then
					Program.StatButtonState.spa = ((Program.StatButtonState.spa + 1) % 3) + 1
					Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spa]
					Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spa]
					Tracker.controller.framesSinceInput = 0
				elseif Tracker.controller.statIndex == 5 then
					Program.StatButtonState.spd = ((Program.StatButtonState.spd + 1) % 3) + 1
					Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spd]
					Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spd]
					Tracker.controller.framesSinceInput = 0
				elseif Tracker.controller.statIndex == 6 then
					Program.StatButtonState.spe = ((Program.StatButtonState.spe + 1) % 3) + 1
					Buttons[Tracker.controller.statIndex].text = StatButtonStates[Program.StatButtonState.spe]
					Buttons[Tracker.controller.statIndex].textcolor = StatButtonColors[Program.StatButtonState.spe]
					Tracker.controller.framesSinceInput = 0
				end
				local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
				if pokemon ~= nil then
					Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
				end
				Program.waitToDrawFrames = 0
			end
		end

		Input.joypad = joypadButtons
	end
end

function Input.check(xmouse, ymouse)
	-- Tracker input regions
	if Program.state == State.TRACKER then
		---@diagnostic disable-next-line: deprecated
		for i = 1, table.getn(Buttons), 1 do
			if Buttons[i].visible() then
				if Buttons[i].type == ButtonType.singleButton and Buttons[i].text ~= "Hidden Power" then -- Move HP clicking logic to info screen
					if Input.isInRange(xmouse, ymouse, Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4]) then
						Buttons[i].onclick()
						Program.waitToDrawFrames = 0
					end
				end
			end
		end

		--badges
		for index, button in pairs(BadgeButtons.badgeButtons) do
			if button.visible() then
				if Input.isInRange(xmouse, ymouse, button.box[1], button.box[2], button.box[3], button.box[4]) then
					button:onclick()
					Program.waitToDrawFrames = 0
				end
			end
		end

		-- settings gear
		if Input.isInRange(xmouse, ymouse, GraphicConstants.SCREEN_WIDTH + 101 - 8, 7, 7, 7) then
			Options.redraw = true
			Program.waitToDrawFrames = 0
			Program.state = State.SETTINGS
		end

		local pokemonMoves = nil
		local pokemonViewed = Tracker.getPokemon(Utils.inlineIf(Tracker.Data.isViewingOwn, Tracker.Data.ownViewSlot, Tracker.Data.otherViewSlot), Tracker.Data.isViewingOwn)
		if pokemonViewed ~= nil then
			if not Tracker.Data.isViewingOwn then
				pokemonMoves = Tracker.getMoves(pokemonViewed.pokemonID) -- tracked moves only
			elseif Tracker.Data.hasCheckedSummary then
				pokemonMoves = pokemonViewed.moves
			end
		end

		-- move info lookup, only if pokemon exists and the user should know about its moves already
		if pokemonMoves ~= nil then
			local moveOffsetX = GraphicConstants.SCREEN_WIDTH + 7
			local moveOffsetY = 95
			for moveIndex = 1, 4, 1 do
				if Input.isInRange(xmouse, ymouse, moveOffsetX, moveOffsetY, 75, 10) then
					InfoScreen.infoLookup = pokemonMoves[moveIndex].id
					InfoScreen.viewScreen = InfoScreen.SCREENS.MOVE_INFO
					InfoScreen.redraw = true
					Program.state = State.INFOSCREEN
					break
				end
				moveOffsetY = moveOffsetY + 10
			end
		end

		--note box
		if not Tracker.Data.isViewingOwn then
			-- Check if clicked anywhere near the abilities area
			if Input.isInRange(xmouse, ymouse, GraphicConstants.SCREEN_WIDTH + 37, 35, 63, 22) then
				AbilityTrackingButton.onclick()

			-- Check if clicked near the original note taking area near the bottom
			elseif Input.noteForm == nil and Input.isInRange(xmouse, ymouse, GraphicConstants.SCREEN_WIDTH + 6, 141, GraphicConstants.RIGHT_GAP - 12, 12) then
				local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
				local pokemonName = "this Pokemon"
				if pokemon ~= nil then
					pokemonName = PokemonData[pokemon.pokemonID + 1].name
				end
				--forms buttons and textbox initial  width is wrong width its being set in setproperty Width
				--had to change it after the initial value because the built in functions use UIHelper.Scale which mess everything
				local actualGameSize = client.transformPoint(GraphicConstants.SCREEN_WIDTH,0)
				Input.noteForm = forms.newform(465, 125, "Leave a Note", function() Input.noteForm = nil end)
				local formWidth = client.screenwidth() - actualGameSize['x'] + 15
				forms.setproperty(Input.noteForm,"Width",formWidth)
				Utils.setFormLocation(Input.noteForm,GraphicConstants.SCREEN_WIDTH,50)
				forms.label(Input.noteForm, "Enter a note for " .. pokemonName .. " (70 char. max):", 9, 10, 300, 20)
				local noteTextBox = forms.textbox(Input.noteForm, Tracker.getNote(pokemon.pokemonID), 430, 20, nil, 10, 30)
				forms.setproperty(noteTextBox,"Width",formWidth - 40)
				local btn = forms.button(Input.noteForm, "Save", function()
					local formInput = forms.gettext(noteTextBox)
					local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
					if formInput ~= nil and pokemon ~= nil then
						Tracker.TrackNote(pokemon.pokemonID, formInput)
						Program.waitToDrawFrames = 0
					end
					forms.destroy(Input.noteForm)
					Input.noteForm = nil
				end, 187, 55)
				local defualtBtnWidth = 75
				forms.setproperty(btn,"Left",formWidth / 2 - defualtBtnWidth/2)
			end
		end
	-- Info Screen mouse input regions
	elseif Program.state == State.INFOSCREEN then
		-- Check area where the type icon is shown on the info screen; visible check to confirm the player's Pokemon has the Hidden Power move
		if HiddenPowerButton.visible and Input.isInRange(xmouse, ymouse, GraphicConstants.SCREEN_WIDTH + 111, 8, 31, 13) then
			HiddenPowerButton.onclick()
			InfoScreen.redraw = true
		end

		-- Check for input on 'Close' button
		if Input.isInRange(xmouse, ymouse, InfoScreen.closeButton.box[1], InfoScreen.closeButton.box[2], InfoScreen.closeButton.box[3], InfoScreen.closeButton.box[4]) then
			InfoScreen.closeButton.onClick()
		end
	-- Settings menu mouse input regions
	elseif Program.state == State.SETTINGS then
		-- Check for input on any of the option buttons
		for _, button in pairs(Options.optionsButtons) do
			if Input.isInRange(xmouse, ymouse, button.box[1], button.box[2], GraphicConstants.RIGHT_GAP - (button.box[3] * 2), button.box[4]) then
				button.onClick()
			end
		end

		-- Check for input on 'Roms Folder', 'Edit Controls', 'Customize Theme', and 'Close' buttons
		if Input.isInRange(xmouse, ymouse, Options.romsFolderOption.box[1], Options.romsFolderOption.box[2], GraphicConstants.RIGHT_GAP - (Options.romsFolderOption.box[3] * 2), Options.romsFolderOption.box[4]) then
			Options.romsFolderOption.onClick()
		end
		if Input.isInRange(xmouse, ymouse, Options.controlsButton.box[1], Options.controlsButton.box[2], Options.controlsButton.box[3], Options.controlsButton.box[4]) then
			Options.controlsButton.onClick()
		end
		if Input.isInRange(xmouse, ymouse, Options.themeButton.box[1], Options.themeButton.box[2], Options.themeButton.box[3], Options.themeButton.box[4]) then
			Options.themeButton.onClick()
		end
		if Input.isInRange(xmouse, ymouse, Options.closeButton.box[1], Options.closeButton.box[2], Options.closeButton.box[3], Options.closeButton.box[4]) then
			Options.closeButton.onClick()
		end
	elseif Program.state == State.THEME then
		-- Check for input on 'Import', 'Export', and 'Presets' buttons
		if Input.isInRange(xmouse, ymouse, Theme.importThemeButton.box[1], Theme.importThemeButton.box[2], Theme.importThemeButton.box[3], Theme.importThemeButton.box[4]) then
			Theme.importThemeButton.onClick()
		end
		if Input.isInRange(xmouse, ymouse, Theme.exportThemeButton.box[1], Theme.exportThemeButton.box[2], Theme.exportThemeButton.box[3], Theme.exportThemeButton.box[4]) then
			Theme.exportThemeButton.onClick()
		end
		if Input.isInRange(xmouse, ymouse, Theme.presetsButton.box[1], Theme.presetsButton.box[2], Theme.presetsButton.box[3], Theme.presetsButton.box[4]) then
			Theme.presetsButton.onClick()
		end

		-- Check for input on any of the theme config buttons
		for _, button in pairs(Theme.themeButtons) do
			if Input.isInRange(xmouse, ymouse, button.box[1], button.box[2], GraphicConstants.RIGHT_GAP - (button.box[3] * 2), button.box[4]) then
				button.onClick()
			end
		end
		if Input.isInRange(xmouse, ymouse, Theme.moveTypeEnableButton.box[1], Theme.moveTypeEnableButton.box[2], GraphicConstants.RIGHT_GAP - (Theme.moveTypeEnableButton.box[3] * 2), Theme.moveTypeEnableButton.box[4]) then
			Theme.moveTypeEnableButton.onClick()
		end

		-- Check for input on 'Restore Defaults' and 'Close' buttons
		if Input.isInRange(xmouse, ymouse, Theme.restoreDefaultsButton.box[1], Theme.restoreDefaultsButton.box[2], Theme.restoreDefaultsButton.box[3], Theme.restoreDefaultsButton.box[4]) then
			Theme.restoreDefaultsButton.onClick()
		end
		if Input.isInRange(xmouse, ymouse, Theme.closeButton.box[1], Theme.closeButton.box[2], Theme.closeButton.box[3], Theme.closeButton.box[4]) then
			Theme.closeButton.onClick()
		end
	end
end

--[[
	Checks if a mouse click is within a range and returning true.

	xmouse, ymouse: number -> coordinates of the mouse
	x, y: number -> starting coordinate of the region being tested for clicks
	xregion, yregion -> size of the region being tested from the starting coordinates
]]
function Input.isInRange(xmouse, ymouse, x, y, xregion, yregion)
	if xmouse >= x and xmouse <= x + xregion then
		if ymouse >= y and ymouse <= y + yregion then
			return true
		end
	end
	return false
end

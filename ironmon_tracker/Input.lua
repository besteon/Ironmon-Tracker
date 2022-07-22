Input = {
	prevMouseInput = {},
	prevJoypadInput = {},
	currentColorPicker = nil,
}

Input.controller = {
	statIndex = 1, -- Value between 1 and 6 (for each stat stage)
	framesSinceInput = 120,
	boxVisibleFrames = 120,
}

function Input.update()
	if Input.currentColorPicker ~= nil then
		Input.currentColorPicker:handleInput()
	else
		-- Check inputs from the Mouse
		local mouseInput = input.getmouse()
		if mouseInput["Left"] and not Input.prevMouseInput["Left"] then
			local xmouse = mouseInput["X"]
			local ymouse = mouseInput["Y"] + Constants.SCREEN.UP_GAP
			Input.checkMouseInput(xmouse, ymouse)
		end
		Input.prevMouseInput = mouseInput

		-- Check inputs from the Joypad controller
		local joypadButtons = joypad.get()
		Input.checkJoypadInput(joypadButtons)
		Input.prevJoypadInput = joypadButtons
	end
end

function Input.checkJoypadInput(joypadButtons)
	-- "Options.CONTROLS["Toggle view"]" pressed
	if joypadButtons[Options.CONTROLS["Toggle view"]] and Input.prevJoypadInput[Options.CONTROLS["Toggle view"]] ~= joypadButtons[Options.CONTROLS["Toggle view"]] then
		if Tracker.Data.inBattle then
			Tracker.Data.isViewingOwn = not Tracker.Data.isViewingOwn
		end
		Program.frames.waitToDraw = 0
	end

	-- "Options.CONTROLS["Cycle through stats"]" pressed, display box over next stat
	if joypadButtons[Options.CONTROLS["Cycle through stats"]] and Input.prevJoypadInput[Options.CONTROLS["Cycle through stats"]] ~= joypadButtons[Options.CONTROLS["Cycle through stats"]] then
		Input.controller.statIndex = (Input.controller.statIndex % 6) + 1
		Input.controller.framesSinceInput = 0
		Program.frames.waitToDraw = 0
	else
		if Input.controller.framesSinceInput == Input.controller.boxVisibleFrames - 1 then
			Program.frames.waitToDraw = 0
		end
		if Input.controller.framesSinceInput < Input.controller.boxVisibleFrames then
			Input.controller.framesSinceInput = Input.controller.framesSinceInput + 1
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
	if joypadButtons[Options.CONTROLS["Mark stat"]] and Input.prevJoypadInput[Options.CONTROLS["Mark stat"]] ~= joypadButtons[Options.CONTROLS["Mark stat"]] then
		if Input.controller.framesSinceInput < Input.controller.boxVisibleFrames then
			Input.controller.framesSinceInput = 0

			local statKey = Constants.ORDERED_LISTS.STATSTAGES[Input.controller.statIndex]
			local statButton = TrackerScreen.buttons[statKey]
			statButton:onClick()
		end
	end
end

function Input.checkMouseInput(xmouse, ymouse)
	if Program.state == State.TRACKER then
		Input.checkButtonsClicked(xmouse, ymouse, TrackerScreen.buttons)

		-- settings gear TODO: Turn this into a button
		if Input.isInRange(xmouse, ymouse, Constants.SCREEN.WIDTH + 93, 7, 7, 7) then
			Options.redraw = true
			Program.frames.waitToDraw = 0
			Program.state = State.SETTINGS
		end

		local pokemon = Tracker.getPokemon(Utils.inlineIf(Tracker.Data.isViewingOwn, Tracker.Data.ownViewSlot, Tracker.Data.otherViewSlot), Tracker.Data.isViewingOwn)
		Input.checkPokemonIconClicked(xmouse, ymouse, pokemon)
		Input.checkAnyMovesClicked(xmouse, ymouse, pokemon)
	elseif Program.state == State.INFOSCREEN then
		Input.checkButtonsClicked(xmouse, ymouse, InfoScreen.buttons)
	elseif Program.state == State.SETTINGS then
		Input.checkButtonsClicked(xmouse, ymouse, Options.buttons)
	elseif Program.state == State.THEME then
		Input.checkButtonsClicked(xmouse, ymouse, Theme.buttons)
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

function Input.checkButtonsClicked(xmouse, ymouse, buttons)
	for _, button in pairs(buttons) do
		local isAreaClicked = false

		-- If the button has an override for which area to check for mouse clicks, use that
		if button.clickableArea ~= nil then
			isAreaClicked = Input.isInRange(xmouse, ymouse, button.clickableArea[1], button.clickableArea[2], button.clickableArea[3], button.clickableArea[4])
		else
			isAreaClicked = Input.isInRange(xmouse, ymouse, button.box[1], button.box[2], button.box[3], button.box[4])
		end

		if isAreaClicked and button.onClick ~= nil then
			button:onClick()
		end
	end
end

function Input.checkPokemonIconClicked(xmouse, ymouse, pokemon)
	-- pokemon info lookup TODO: Turn this into a button
	if pokemon ~= nil and Input.isInRange(xmouse, ymouse, Constants.SCREEN.WIDTH + 5, 5, 32, 29) then
		InfoScreen.infoLookup = pokemon.pokemonID
		InfoScreen.viewScreen = InfoScreen.SCREENS.POKEMON_INFO
		InfoScreen.redraw = true
		Program.state = State.INFOSCREEN
	end
end

function Input.checkAnyMovesClicked(xmouse, ymouse, pokemon)
	local pokemonMoves = nil
	if pokemon ~= nil then
		if not Tracker.Data.isViewingOwn then
			pokemonMoves = Tracker.getMoves(pokemon.pokemonID) -- tracked moves only
		elseif Tracker.Data.hasCheckedSummary then
			pokemonMoves = pokemon.moves
		end
	end

	-- move info lookup, only if pokemon exists and the user should know about its moves already
	-- TODO: Turn these into buttons
	if pokemonMoves ~= nil then
		local moveOffsetX = Constants.SCREEN.WIDTH + 7
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
end
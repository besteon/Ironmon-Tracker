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

function Input.checkForInput()
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
		if Battle.inBattle then
			Tracker.Data.isViewingOwn = not Tracker.Data.isViewingOwn
			if Tracker.Data.isViewingOwn and Battle.numBattlers > 2 then
				--swap sides on returning to allied side
				Battle.isViewingLeft = not Battle.isViewingLeft
				--undo changes for special double battles
				if Battle.isViewingLeft == false and Battle.Combatants.RightOwn > Battle.partySize then
					Tracker.Data.isViewingOwn = not Tracker.Data.isViewingOwn
				end
				-- Recalculate "Heals In Bag" HP percentages using a constant value (so player sees the update)
				Program.Frames.three_sec_update = 30
			end
		end
		Program.redraw(true)
	end

	-- "Options.CONTROLS["Cycle through stats"]" pressed, display box over next stat
	if joypadButtons[Options.CONTROLS["Cycle through stats"]] and Input.prevJoypadInput[Options.CONTROLS["Cycle through stats"]] ~= joypadButtons[Options.CONTROLS["Cycle through stats"]] then
		Input.controller.statIndex = (Input.controller.statIndex % 6) + 1
		Input.controller.framesSinceInput = 0
		Program.redraw(true)
	else
		if Input.controller.framesSinceInput == Input.controller.boxVisibleFrames - 1 then
			Program.redraw(true)
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
		Main.loadNextSeed = true
	end

	-- "Options.CONTROLS["Mark stat"]" pressed, cycle stat prediction for selected stat
	if joypadButtons[Options.CONTROLS["Mark stat"]] and Input.prevJoypadInput[Options.CONTROLS["Mark stat"]] ~= joypadButtons[Options.CONTROLS["Mark stat"]] then
		if Input.controller.framesSinceInput < Input.controller.boxVisibleFrames then
			Input.controller.framesSinceInput = 0

			-- This might be redundant, but adding in the extra safety check
			if Input.controller.statIndex < 1 then Input.controller.statIndex = 1 end
			if Input.controller.statIndex > 6 then Input.controller.statIndex = 6 end

			local statKey = Constants.OrderedLists.STATSTAGES[Input.controller.statIndex]
			local statButton = TrackerScreen.Buttons[statKey]
			statButton:onClick()
		end
	end
end

function Input.checkMouseInput(xmouse, ymouse)
	if Program.currentScreen == Program.Screens.TRACKER then
		Input.checkButtonsClicked(xmouse, ymouse, TrackerScreen.Buttons)
		Input.checkAnyMovesClicked(xmouse, ymouse)
	elseif Program.currentScreen == Program.Screens.INFO then
		Input.checkButtonsClicked(xmouse, ymouse, InfoScreen.Buttons)
		Input.checkButtonsClicked(xmouse, ymouse, InfoScreen.TemporaryButtons)
	elseif Program.currentScreen == Program.Screens.NAVIGATION then
		Input.checkButtonsClicked(xmouse, ymouse, NavigationMenu.Buttons)
	elseif Program.currentScreen == Program.Screens.STARTUP then
		Input.checkButtonsClicked(xmouse, ymouse, StartupScreen.Buttons)
	elseif Program.currentScreen == Program.Screens.UPDATE then
		Input.checkButtonsClicked(xmouse, ymouse, UpdateScreen.Buttons)
	elseif Program.currentScreen == Program.Screens.SETUP then
		Input.checkButtonsClicked(xmouse, ymouse, SetupScreen.Buttons)
	elseif Program.currentScreen == Program.Screens.EXTRAS then
		Input.checkButtonsClicked(xmouse, ymouse, ExtrasScreen.Buttons)
	elseif Program.currentScreen == Program.Screens.QUICKLOAD then
		Input.checkButtonsClicked(xmouse, ymouse, QuickloadScreen.Buttons)
	elseif Program.currentScreen == Program.Screens.GAME_SETTINGS then
		Input.checkButtonsClicked(xmouse, ymouse, GameOptionsScreen.Buttons)
	elseif Program.currentScreen == Program.Screens.THEME then
		Input.checkButtonsClicked(xmouse, ymouse, Theme.Buttons)
	elseif Program.currentScreen == Program.Screens.MANAGE_DATA then
		Input.checkButtonsClicked(xmouse, ymouse, TrackedDataScreen.Buttons)
	end

	-- Check if mouse clicked on the game screen itself
	-- Clicked on a new move learned, show info
	if Input.isInRange(xmouse, ymouse, 0, Constants.SCREEN.HEIGHT - 45, Constants.SCREEN.WIDTH, 45) then
		-- Only lookup/show move if not editing settings
		if Program.currentScreen == Program.Screens.TRACKER or Program.currentScreen == Program.Screens.INFO then
			local moveId = Program.getLearnedMoveId()
			if moveId ~= nil then
				InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, moveId)
			end
		end
	end
end

function Input.resetControllerIndex()
	-- Start at the end, so when the next stat controler button is pressed it will wrap around to the 1st box
	Input.controller.statIndex = 6
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
		-- Only check for clicks on the button if it's visible (no function implies visibility)
		if button.isVisible == nil or button:isVisible() then
			local isAreaClicked

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
end

function Input.checkAnyMovesClicked(xmouse, ymouse)
	local pokemon = Tracker.getViewedPokemon()
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
				InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, pokemonMoves[moveIndex].id)
				break
			end
			moveOffsetY = moveOffsetY + 10
		end
	end
end
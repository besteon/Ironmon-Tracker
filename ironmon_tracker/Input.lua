Input = {
	prevMouseInput = {},
	prevJoypadInput = {},
	currentColorPicker = nil,
}

Input.StatHighlighter = {
	statIndex = 1, -- Value between 1 and 6 (for each stat stage)
	framesSinceInput = 150,
	framesHighlightMax = 150,
	framesToHighlight = 30, -- Highlight the selected stat every other N frames
	getSelectedStat = function(self)
		if self.statIndex < 1 then
			self.statIndex = 1
		elseif self.statIndex > #Constants.OrderedLists.STATSTAGES then
			self.statIndex = #Constants.OrderedLists.STATSTAGES
		end

		return Constants.OrderedLists.STATSTAGES[self.statIndex]
	end,
	-- Cycle through the six visible stats to enable marking them as high/low/neutral
	cycleToNextStat = function(self)
		if Tracker.Data.isViewingOwn then return end
		if self.framesSinceInput < self.framesHighlightMax then
			self.statIndex = (self.statIndex % 6) + 1
		end
		self.framesSinceInput = 0
		Program.redraw(true)
	end,
	markSelectedStat = function(self)
		if not self:isActive() then return end
		self.framesSinceInput = 0
		local statKey = self:getSelectedStat()
		local statButton = TrackerScreen.Buttons[statKey]
		statButton:onClick()
	end,
	resetSelectedStat = function(self)
		self.statIndex = 1
	end,
	-- The selected stat to highlight is only visible N frames
	incrementHighlightedFrames = function(self)
		if not self:isActive() then return end
		self.framesSinceInput = self.framesSinceInput + 1
		if self.framesSinceInput == self.framesHighlightMax then
			Program.redraw(true)
		end
	end,
	isActive = function(self)
		return not Tracker.Data.isViewingOwn and self.framesSinceInput < self.framesHighlightMax
	end,
	shouldDisplay = function(self)
		if not self:isActive() then
			return false
		else
			return (self.framesSinceInput % (self.framesToHighlight * 2)) < self.framesToHighlight
		end
	end,
}

function Input.checkForInput()
	if not Main.IsOnBizhawk() then
		return
	end

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

		Input.checkJoypadInput()

		CustomCode.inputCheckBizhawk()
	end
end

-- returns a table such that 'table[button] = true' if that button is being pressed
function Input.getJoypadInputFormatted()
	if Main.IsOnBizhawk() then
		-- Check inputs from the Joypad controller
		return joypad.get()
	else
		local keysMasked = emu:getKeys()

		return {
			["A"] = Utils.getbits(keysMasked, 0, 1) == 1,
			["B"] = Utils.getbits(keysMasked, 1, 1) == 1,
			["Select"] = Utils.getbits(keysMasked, 2, 1) == 1,
			["Start"] = Utils.getbits(keysMasked, 3, 1) == 1,
			["Right"] = Utils.getbits(keysMasked, 4, 1) == 1,
			["Left"] = Utils.getbits(keysMasked, 5, 1) == 1,
			["Up"] = Utils.getbits(keysMasked, 6, 1) == 1,
			["Down"] = Utils.getbits(keysMasked, 7, 1) == 1,
			["R"] = Utils.getbits(keysMasked, 8, 1) == 1,
			["L"] = Utils.getbits(keysMasked, 9, 1) == 1,
		}
	end
end

function Input.checkJoypadInput()
	local joypadButtons = Input.getJoypadInputFormatted()

	CustomCode.inputCheckMGBA()

	-- "Options.CONTROLS["Toggle view"]" pressed
	if joypadButtons[Options.CONTROLS["Toggle view"]] and Input.prevJoypadInput[Options.CONTROLS["Toggle view"]] ~= joypadButtons[Options.CONTROLS["Toggle view"]] then
		Input.togglePokemonViewed()
	end

	-- "Options.CONTROLS["Cycle through stats"]" pressed, display box over next stat
	if joypadButtons[Options.CONTROLS["Cycle through stats"]] and Input.prevJoypadInput[Options.CONTROLS["Cycle through stats"]] ~= joypadButtons[Options.CONTROLS["Cycle through stats"]] then
		Input.StatHighlighter:cycleToNextStat()
	else
		Input.StatHighlighter:incrementHighlightedFrames()
	end

	-- "Options.CONTROLS["Load next seed"]"
	if not Main.loadNextSeed then
		local allPressed = true
		for button in string.gmatch(Options.CONTROLS["Load next seed"], '([^,%s]+)') do
			if joypadButtons[button] ~= true then
				allPressed = false
			end
		end
		if allPressed == true then
			Main.loadNextSeed = true
		end
	end

	-- "Options.CONTROLS["Mark stat"]" pressed, cycle stat prediction for selected stat
	if joypadButtons[Options.CONTROLS["Mark stat"]] and Input.prevJoypadInput[Options.CONTROLS["Mark stat"]] ~= joypadButtons[Options.CONTROLS["Mark stat"]] then
		Input.StatHighlighter:markSelectedStat()
	end

	-- Save the joypad inputs to prevent triggering on the next frame (no autofire)
	Input.prevJoypadInput = joypadButtons
end

function Input.togglePokemonViewed()
	if Battle.inBattle then
		Tracker.Data.isViewingOwn = not Tracker.Data.isViewingOwn

		-- Check toggling through other Pokemon available in doubles battles
		if Tracker.Data.isViewingOwn and Battle.numBattlers > 2 then
			-- Swap sides on returning to allied side
			Battle.isViewingLeft = not Battle.isViewingLeft

			-- For some doubles battles, do not reveal your ally partner's Pokémon (such as Emerald Steven fight)
			local shouldHideAlly = Battle.EnemyTrainersToHideAlly[GameSettings.game or 1][Battle.opposingTrainerId or 0]
			if not Battle.isViewingLeft and shouldHideAlly then
				Tracker.Data.isViewingOwn = not Tracker.Data.isViewingOwn
			end
		end

		if Tracker.Data.isViewingOwn then
			-- Recalculate "Heals In Bag" HP percentages using a constant value (so player sees the update)
			Program.Frames.three_sec_update = 30
		end
	end

	-- Always redraw the screen to show any changes; Toggle works as a refresh button
	Program.redraw(true)
end

function Input.checkMouseInput(xmouse, ymouse)
	if Program.currentScreen ~= nil and type(Program.currentScreen.checkInput) == "function" then
		Program.currentScreen.checkInput(xmouse, ymouse)
	end

	-- The extra screens don't occupy the same screen space and need their own check
	if TeamViewArea.isDisplayed() then
		TeamViewArea.checkInput(xmouse, ymouse)
	end
	if LogOverlay.isDisplayed then
		LogOverlay.checkInput(xmouse, ymouse)
	end
end

function Input.isMouseInArea(xmouse, ymouse, x, y, width, height)
	return (xmouse >= x and xmouse <= x + width) and (ymouse >= y and ymouse <= y + height)
end

function Input.checkButtonsClicked(xmouse, ymouse, buttons)
	for _, button in pairs(buttons) do
		-- Only check for clicks on the button if it's visible (no function implies visibility)
		if button.isVisible == nil or button:isVisible() then
			local isAreaClicked

			-- If the button has an override for which area to check for mouse clicks, use that
			if button.clickableArea ~= nil then
				isAreaClicked = Input.isMouseInArea(xmouse, ymouse, button.clickableArea[1], button.clickableArea[2], button.clickableArea[3], button.clickableArea[4])
			elseif button.box ~= nil then
				isAreaClicked = Input.isMouseInArea(xmouse, ymouse, button.box[1], button.box[2], button.box[3], button.box[4])
			else
				isAreaClicked = false
			end

			if isAreaClicked and button.onClick ~= nil then
				CustomCode.onButtonClicked(button)
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
			if Input.isMouseInArea(xmouse, ymouse, moveOffsetX, moveOffsetY, 75, 10) then
				InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, pokemonMoves[moveIndex].id)
				break
			end
			moveOffsetY = moveOffsetY + 10
		end
	end
end

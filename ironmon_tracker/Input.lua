Input = {
	prevMouseInput = {},
	prevJoypadInput = {},
	joypadUsedRecently = false,
	currentColorPicker = nil,
	allowNewRunCombo = false, -- Disable button combo for 1 second to prevents accidental, consecutive triggers
	allowMouse = true, -- Accepts input from Mouse; false will ignore all clicks
	allowJoypad = true, -- Accepts input from Joypad controller; false will ignore joystick/buttons
	resumeMouse = false, -- Set to true to enable corresponding input on the next frame
	resumeJoypad = false, -- Set to true to enable corresponding input on the next frame
}

Input.NO_KEY_MAPPING = "NOTBOUND"

Input.OrderedControllerInputs = { "A", "B",  "Select",  "Start",  "Right",  "Left",  "Up",  "Down",  "R",  "L" }

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
		if Battle.isViewingOwn then return end
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
		local statButton = TrackerScreen.Buttons[statKey or false]
		if statButton and type(statButton.onClick) == "function" then
			statButton:onClick()
		end
	end,
	resetSelectedStat = function(self)
		self.statIndex = 1
		self.framesSinceInput = self.framesHighlightMax
	end,
	-- The selected stat to highlight is only visible N frames
	incrementHighlightedFrames = function(self)
		if not self:isActive() then return end
		self.framesSinceInput = self.framesSinceInput + (1.0 / Program.clientFpsMultiplier)
		if self.framesSinceInput >= self.framesHighlightMax then
			Program.redraw(true)
		end
	end,
	isActive = function(self)
		return not Battle.isViewingOwn and self.framesSinceInput < self.framesHighlightMax
	end,
	shouldDisplay = function(self)
		return self:isActive() and (self.framesSinceInput % (self.framesToHighlight * 2)) < self.framesToHighlight
	end,
}

function Input.initialize()
	Input.allowNewRunCombo = false
	Input.allowMouse = true
	Input.allowJoypad = true
	Input.resumeMouse = false
	Input.resumeJoypad = false
	-- Add compatibility for deprecated functions
	Input.togglePokemonViewed = Battle.togglePokemonViewed
	-- Delay 1 second before enabling the New Run button combo
	Program.addFrameCounter("EnableAllowNewRunCombo", 60, function()
		Input.allowNewRunCombo = true
	end, 1, true)
end

function Input.checkForInput()
	if not Main.IsOnBizhawk() then
		return
	end

	if Input.currentColorPicker ~= nil then
		Input.currentColorPicker:handleInput()
	else
		if Input.allowMouse then
			local mouseInput = input.getmouse()
			if mouseInput["Left"] and not Input.prevMouseInput["Left"] then
				local xmouse = mouseInput["X"]
				local ymouse = mouseInput["Y"] + Constants.SCREEN.UP_GAP
				Input.checkMouseInput(xmouse, ymouse)
			end
			Input.prevMouseInput = mouseInput
		end

		if Input.allowJoypad then
			Input.checkJoypadInput()
		end

		CustomCode.inputCheckBizhawk()

		-- If instructed to resume input, do so after 1 frame of input checks, to prevent "resume into immediate input trigger"
		if Input.resumeMouse then
			Input.resumeMouse = false
			Input.allowMouse = true
		end
		if Input.resumeJoypad then
			Input.resumeJoypad = false
			Input.allowJoypad = true
		end
	end
end

-- Returns a table with all joypad buttons as keys, and the value of true if its pressed down
function Input.getJoypadInputFormatted()
	if Main.IsOnBizhawk() then
		-- Check inputs from the Joypad controller
		return joypad.get() or {}
	else
		local keysMasked = emu:getKeys() or 0
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
	-- Don't process controller buttons while rebinding them
	if SetupScreen.inProcessOfBinding() then
		return
	end

	local joypad = Input.getJoypadInputFormatted()
	local toggleViewBtn = Options.CONTROLS["Toggle view"] or ""
	local infoShortcutBtn = Options.CONTROLS["Info shortcut"] or ""
	local cycleStatBtn = Options.CONTROLS["Cycle through stats"] or ""
	local markStatBtn = Options.CONTROLS["Mark stat"] or ""
	local nextBtn = Options.CONTROLS["Next page"] or ""
	local previousBtn = Options.CONTROLS["Previous page"] or ""
	local quickloadBtns = Options.CONTROLS["Load next seed"] or ""

	CustomCode.inputCheckMGBA()

	if joypad[toggleViewBtn] and not Input.prevJoypadInput[toggleViewBtn] then
		Battle.togglePokemonViewed()
	end

	if joypad[cycleStatBtn] and not Input.prevJoypadInput[cycleStatBtn] then
		if Program.currentScreen == TrackerScreen and not Battle.isViewingOwn then
			Input.StatHighlighter:cycleToNextStat()
		end
	else
		Input.StatHighlighter:incrementHighlightedFrames()
	end

	if joypad[markStatBtn] and not Input.prevJoypadInput[markStatBtn] then
		if Program.currentScreen == TrackerScreen and not Battle.isViewingOwn then
			Input.StatHighlighter:markSelectedStat()
		end
	end

	if joypad[nextBtn] and not Input.prevJoypadInput[nextBtn] then
		if LogOverlay.isDisplayed then
			if LogOverlay.Windower.currentTab == LogTabPokemonDetails then
				LogTabPokemonDetails.Pager:nextPage()
			else
				LogOverlay.Windower:nextPage()
			end
		elseif StreamConnectOverlay.isDisplayed then
			StreamConnectOverlay.Pager:nextPage()
		elseif Program.currentScreen and Program.currentScreen.Pager and type(Program.currentScreen.Pager.nextPage) == "function" then
			Program.currentScreen.Pager:nextPage()
		end
	end

	if joypad[previousBtn] and not Input.prevJoypadInput[previousBtn] then
		if LogOverlay.isDisplayed then
			if LogOverlay.Windower.currentTab == LogTabPokemonDetails then
				LogTabPokemonDetails.Pager:prevPage()
			else
				LogOverlay.Windower:prevPage()
			end
		elseif StreamConnectOverlay.isDisplayed then
			StreamConnectOverlay.Pager:prevPage()
		elseif Program.currentScreen and Program.currentScreen.Pager and type(Program.currentScreen.Pager.prevPage) == "function" then
			Program.currentScreen.Pager:prevPage()
		end
	end

	if joypad[infoShortcutBtn] and not Input.prevJoypadInput[infoShortcutBtn] then
		Input.infoShortcutPressed()
	end

	-- If both next and previous paging buttons pressed, perform a "Go Back" to the previous screen
	if joypad[nextBtn] and joypad[previousBtn] and not (Input.prevJoypadInput[nextBtn] and Input.prevJoypadInput[previousBtn]) then
		if Program.currentScreen and Program.currentScreen.Buttons then
			local backBtn = Program.currentScreen.Buttons.Back or {}
			if type(backBtn.onClick) == "function" then
				backBtn:onClick()
			end
			if Program.currentScreen == InfoScreen then
				Program.currentScreen.Buttons.BackTop:onClick()
			end
		end
	end

	if not Main.loadNextSeed and Input.allowNewRunCombo then
		local allPressed = true
		for button in string.gmatch(quickloadBtns, '([^,%s]+)') do
			if not joypad[button] then
				allPressed = false
				break
			end
		end
		if allPressed == true then
			Main.loadNextSeed = true
		end
	end

	-- Save the joypad inputs to prevent triggering on the next frame (no autofire)
	Input.prevJoypadInput = joypad

	-- Record that a button was pressed recently
	if not Input.joypadUsedRecently then
		Input.joypadUsedRecently = joypad["Up"] or joypad["Down"] or joypad["Left"] or joypad["Right"]
			or joypad["A"] or joypad["B"] or joypad["Start"] or joypad["Select"] or joypad["R"] or joypad["L"]
	end
end

function Input.infoShortcutPressed()
	-- Only open an info screen for Bizhawk if on the base tracker screen, to prevent opening while changing settings or viewing other pages
	if not Main.IsOnBizhawk() or Program.currentScreen ~= TrackerScreen or Input.StatHighlighter:isActive() then
		return
	end

	-- If in battle, lookup on the opposing Pokémon or enemy Trainer
	if Battle.inBattleScreen then -- Use `inBattleScreen` instead of `inActiveBattle()` for proper timing
		if Battle.isWildEncounter then
			local pokemon = Tracker.getPokemon(1, false) or {}
			if PokemonData.isValid(pokemon.pokemonID) then
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.pokemonID)
			end
		else
			if TrainerInfoScreen.buildScreen(Battle.opposingTrainerId) then
				TrainerInfoScreen.previousScreen = TrackerScreen
				Program.changeScreenView(TrainerInfoScreen)
			end
		end
		return
	end

	-- Check what type of contextual info to display (such as early game pivots, safari zone, or trainers on routes)
	local pokemon = Tracker.getPokemon(1, true) or {}
	local mapId = TrackerAPI.getMapId()
	if (pokemon.level or 0) < 13 or RouteData.Locations.IsInSafariZone[mapId] then
		-- If the current route has encounters, use that
		if RouteData.hasRouteEncounterArea(mapId, RouteData.EncounterArea.LAND) then
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, {
				mapId = mapId,
				encounterArea = RouteData.EncounterArea.LAND,
			})
		-- Otherwise, check if the current route is an early game city and use the first route
		elseif RouteData.Locations.EarlyGameCity[mapId] then
			local earlyRoutes = RouteData.getPivotOrSafariRouteIds() or {}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, {
				mapId = earlyRoutes[1] or mapId,
				encounterArea = RouteData.EncounterArea.LAND,
			})
		end
	else
		if TrainersOnRouteScreen.buildScreen(mapId) then
			TrainersOnRouteScreen.previousScreen = TrackerScreen
			Program.changeScreenView(TrainersOnRouteScreen)
		end
	end
end

function Input.getSpriteFacingDirection(animationType)
	if animationType ~= SpriteData.Types.Walk or not SpriteData.screenCanControlWalking(Program.currentScreen) then
		return 1
	end
	local joypad = Input.getJoypadInputFormatted()
	if joypad["Right"] and joypad["Down"] then return 2
	elseif joypad["Right"] and joypad["Up"] then return 4
	elseif joypad["Left"] and joypad["Up"] then return 6
	elseif joypad["Left"] and joypad["Down"] then return 8
	elseif joypad["Down"] then return 1
	elseif joypad["Right"] then return 3
	elseif joypad["Up"] then return 5
	elseif joypad["Left"] then return 7
	else return 1
	end
end

function Input.checkMouseInput(xmouse, ymouse)
	if Program.currentScreen ~= nil and type(Program.currentScreen.checkInput) == "function" then
		Program.currentScreen.checkInput(xmouse, ymouse)
	end

	Program.GameTimer:checkInput(xmouse, ymouse)

	-- The extra screens don't occupy the same screen space and need their own check; order matters
	if TeamViewArea.isDisplayed() then
		TeamViewArea.checkInput(xmouse, ymouse)
	end
	if UpdateScreen.showNotes then
		Input.checkButtonsClicked(xmouse, ymouse, UpdateScreen.Pager.Buttons)
	elseif StreamConnectOverlay.isDisplayed then
		StreamConnectOverlay.checkInput(xmouse, ymouse)
	elseif LogOverlay.isDisplayed then
		LogOverlay.checkInput(xmouse, ymouse)
	end
end

function Input.isMouseInArea(xmouse, ymouse, x, y, width, height)
	return (xmouse >= x and xmouse <= x + width) and (ymouse >= y and ymouse <= y + height)
end

function Input.checkButtonsClicked(xmouse, ymouse, buttons)
	local buttonQueue = {}
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

			-- Queue up all of the buttons to click before clicking any of them
			if isAreaClicked and button.onClick ~= nil then
				table.insert(buttonQueue, button)
			end
		end
	end
	-- Finally, click all buttons at once
	for _, button in pairs(buttonQueue) do
		CustomCode.onButtonClicked(button)
		button:onClick()
	end
end

function Input.checkAnyMovesClicked(xmouse, ymouse)
	local pokemon = Tracker.getViewedPokemon()
	if pokemon == nil then
		return
	end

	local pokemonMoves
	if not Battle.isViewingOwn and not Options["Open Book Play Mode"] then
		pokemonMoves = Tracker.getMoves(pokemon.pokemonID, pokemon.level) -- tracked moves only
	elseif Tracker.Data.hasCheckedSummary then
		pokemonMoves = pokemon.moves
	end
	if pokemonMoves == nil then
		return
	end

	-- move info lookup, only if pokemon exists and the user should know about its moves already
	-- TODO: Turn these into buttons
	local moveOffsetX = Constants.SCREEN.WIDTH + 7
	local moveOffsetY = 95
	for i = 1, 4, 1 do
		local move = pokemonMoves[i] or {}
		if MoveData.isValid(move.id) and Input.isMouseInArea(xmouse, ymouse, moveOffsetX, moveOffsetY, 75, 10) then
			InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, move.id)
			break
		end
		moveOffsetY = moveOffsetY + 10
	end
end

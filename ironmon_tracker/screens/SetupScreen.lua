SetupScreen = {
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
	changeIconInSeconds = 3, -- Number of seconds
	timeLastChanged = -1,
}

SetupScreen.Buttons = {
	ChoosePortrait = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local iconset = Options.getIconSet()
			return string.format("%s:  %s", Resources.SetupScreen.PokemonIconSetLabel, iconset.name)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 12, 65, 11 },
	},
	PortraitAuthor = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local iconset = Options.getIconSet()
			return string.format("%s:  %s", Resources.SetupScreen.PokemonIconSetAuthor, iconset.author)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 22, 65, 11 },
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 27, 32, 32 },
		pokemonID = 1,
		getIconId = function(self)
			local animType = Options["Allow sprites to walk"] and SpriteData.Types.Walk or SpriteData.Types.Idle
			return self.pokemonID, animType
		end,
		onClick = function(self)
			self.pokemonID = Utils.randomPokemonID()
			SetupScreen.timeLastChanged = os.time()
			Program.redraw(true)
		end
	},
	CycleIconForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 94, Constants.SCREEN.MARGIN + 42, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"]) or 1
			local nextSet = tostring((currIndex % #Options.IconSetMap) + 1)
			SetupScreen.timeLastChanged = os.time()
			Options.addUpdateSetting("Pokemon icon set", nextSet)
			if Options.getIconSet().isAnimated then
				SpriteData.changeIconSet(nextSet)
			end
			Program.redraw(true)
		end
	},
	CycleIconBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 34, Constants.SCREEN.MARGIN + 42, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"]) or 1
			local prevSet = tostring((currIndex - 2 ) % #Options.IconSetMap + 1)
			SetupScreen.timeLastChanged = os.time()
			Options.addUpdateSetting("Pokemon icon set", prevSet)
			if Options.getIconSet().isAnimated then
				SpriteData.changeIconSet(prevSet)
			end

			Program.redraw(true)
		end
	},
	OptionAllowSpritesToWalk = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Allow sprites to walk",
		getText = function(self) return Resources.SetupScreen.OptionAllowSpritesToWalk end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 55, 33, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 55, 8, 8 },
		isVisible = function(self) return Options.getIconSet().isAnimated end,
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			SetupScreen.timeLastChanged = os.time()
			if not Options[self.optionKey] then
				SpriteData.changeAllActiveIcons(SpriteData.DefaultType)
			end
			Program.redraw(true)
		end
	},
	EditControls = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.SetupScreen.ButtonEditControls end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 38, 11 },
		onClick = function() SetupScreen.openEditControlsWindow() end
	},
	ManageData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.SetupScreen.ButtonManageData end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 47, Constants.SCREEN.MARGIN + 135, 60, 11 },
		onClick = function() Program.changeScreenView(TrackedDataScreen) end
	},
	Back = Drawing.createUIElementBackButton(function() Program.changeScreenView(NavigationMenu) end),
}

function SetupScreen.initialize()
	SetupScreen.createButtons()

	for _, button in pairs(SetupScreen.Buttons) do
		button.textColor = SetupScreen.textColor
		button.boxColors = { SetupScreen.borderColor, SetupScreen.boxFillColor }
	end

	-- Randomize what Pokemon icon is shown
	SetupScreen.Buttons.PokemonIcon.pokemonID = Utils.randomPokemonID()
	SetupScreen.timeLastChanged = os.time()

	local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
	local animatedBtnOption = SetupScreen.Buttons["Animated Pokemon popout"]
	if not FileManager.fileExists(abraGif) and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

function SetupScreen.createButtons()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 66

	local optionKeyMap = {
		{"Show Team View", "OptionShowTeamView", },
		{"Right justified numbers", "OptionRightJustifiedNumbers", },
		{"Show nicknames", "OptionShowNicknames", },
		{"Disable mainscreen carousel", "OptionDisableCarousel", },
		{"Track PC Heals", "OptionTrackPCHeals", },
		{"PC heals count downward", "OptionPCHealsCountDown", },
	}

	for _, optionTuple in ipairs(optionKeyMap) do
		SetupScreen.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources.SetupScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)
				-- If PC Heal tracking switched, invert the count
				if self.optionKey == "PC heals count downward" then
					Tracker.Data.centerHeals = math.max(10 - Tracker.Data.centerHeals, 0)
				end
				Program.redraw(true)
				if self.optionKey == "Show Team View" then
					TeamViewArea.refreshDisplayPadding()
					TeamViewArea.buildOutPartyScreen()
					Program.Frames.waitToDraw = 1 -- required to redraw after the redraw
				end
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING
	end
end

function SetupScreen.openEditControlsWindow()
	local form = Utils.createBizhawkForm(Resources.SetupScreen.PromptEditControllerTitle, 445, 215)

	forms.label(form, Resources.SetupScreen.PromptEditControllerDesc, 39, 10, 410, 20)

	local controlKeyMap = {
		{"Load next seed", "PromptEditControllerLoadNext", },
		{"Toggle view", "PromptEditControllerToggleView", },
		{"Cycle through stats", "PromptEditControllerCycleStats", },
		{"Mark stat", "PromptEditControllerMarkStat", },
	}

	local inputTextboxes = {}
	local offsetX = 90
	local offsetY = 35

	for i, controlTuple in ipairs(controlKeyMap) do
		local controlLabel = string.format("%s:", Resources.SetupScreen[controlTuple[2]])
		forms.label(form, controlLabel, offsetX, offsetY, 105, 20)
		inputTextboxes[i] = forms.textbox(form, Options.CONTROLS[controlTuple[1]], 140, 21, nil, offsetX + 110, offsetY - 2)
		offsetY = offsetY + 24
	end

	-- Buttons
	local saveCloseLabel = string.format("%s && %s", Resources.AllScreens.Save, Resources.AllScreens.Close)
	forms.button(form, saveCloseLabel, function()
		for i, controlTuple in ipairs(controlKeyMap) do
			local controlCombination = Utils.formatControls(forms.gettext(inputTextboxes[i] or ""))
			if not Utils.isNilOrEmpty(controlCombination) then
				Options.CONTROLS[controlTuple[1]] = controlCombination
			end
		end
		Main.SaveSettings(true)
		Program.redraw(true)

		Utils.closeBizhawkForm(form)
	end, 45, offsetY + 5, 105, 25)

	forms.button(form, Resources.SetupScreen.PromptEditControllerResetDefault, function()
		for i, controlTuple in ipairs(controlKeyMap) do
			local default = Options.Defaults.CONTROLS[controlTuple[1]]
			forms.settext(inputTextboxes[i], default or "")
		end
	end, 175, offsetY + 5, 120, 25)

	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 320, offsetY + 5, 75, 25)
end

-- USER INPUT FUNCTIONS
function SetupScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SetupScreen.Buttons)
end

-- DRAWING FUNCTIONS
function SetupScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SetupScreen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[SetupScreen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.SetupScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[SetupScreen.borderColor], Theme.COLORS[SetupScreen.boxFillColor])

	-- Draw all buttons
	for _, button in pairs(SetupScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
	-- Redraw so it appears over any other buttons
	Drawing.drawButton(SetupScreen.Buttons.PokemonIcon, shadowcolor)

	-- Randomize the pokemon shown every 'changeIconInSeconds'
	local currentTime = os.time()
	if currentTime >= SetupScreen.timeLastChanged + SetupScreen.changeIconInSeconds then
		SetupScreen.Buttons.PokemonIcon.pokemonID = Utils.randomPokemonID()
		SetupScreen.timeLastChanged = currentTime
	end
end
SetupScreen = {
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
	iconChangeInterval = 10,
}

SetupScreen.Buttons = {
	ChoosePortrait = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return string.format("%s:  %s", Resources.SetupScreen.PokemonIconSetLabel, iconset.name)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 12, 65, 11 },
	},
	PortraitAuthor = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return string.format("%s:  %s", Resources.SetupScreen.PokemonIconSetAuthor, iconset.author)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 22, 65, 11 },
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 27, 32, 32 },
		pokemonID = 1,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			self.pokemonID = Utils.randomPokemonID()
			SetupScreen.iconChangeInterval = 10
			Program.redraw(true)
		end
	},
	CycleIconForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 94, Constants.SCREEN.MARGIN + 42, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"])
			local nextSet = tostring((currIndex % Options.IconSetMap.totalCount) + 1)
			SetupScreen.iconChangeInterval = 10
			Options.addUpdateSetting("Pokemon icon set", nextSet)
			Program.redraw(true)
		end
	},
	CycleIconBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 34, Constants.SCREEN.MARGIN + 42, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"])
			local prevSet = tostring((currIndex - 2 ) % Options.IconSetMap.totalCount + 1)
			SetupScreen.iconChangeInterval = 10
			Options.addUpdateSetting("Pokemon icon set", prevSet)
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

	local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
	local animatedBtnOption = SetupScreen.Buttons["Animated Pokemon popout"]
	if not FileManager.fileExists(abraGif) and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

function SetupScreen.createButtons()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 66
	local linespacing = Constants.SCREEN.LINESPACING + 1

	local optionKeyMap = {
		{"Show Team View", "OptionShowTeamView", },
		{"Right justified numbers", "OptionRightJustifiedNumbers", },
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
		startY = startY + linespacing
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

	-- 'Save & Close' and 'Cancel' buttons
	local saveCloseLabel = string.format("%s && %s", Resources.AllScreens.Save, Resources.AllScreens.Close)
	forms.button(form, saveCloseLabel, function()
		for i, controlTuple in ipairs(controlKeyMap) do
			local controlCombination = Utils.formatControls(forms.gettext(inputTextboxes[i] or ""))
			if controlCombination ~= "" then
				Options.CONTROLS[controlTuple[1]] = controlCombination
			end
		end
		Main.SaveSettings(true)
		Program.redraw(true)

		Utils.closeBizhawkForm(form)
	end, 120, offsetY + 5, 95, 30)

	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 230, offsetY + 5, 65, 30)
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

	-- Randomize the pokemon shown every iconChangeInterval
	-- Tracker screen redraw occurs every Program.Frames.waitToDraw frames,
	-- so overall interval is effectively iconChangeInterval * Program.Frames.waitToDraw frames
	if SetupScreen.iconChangeInterval == 0 then
		SetupScreen.Buttons.PokemonIcon.pokemonID = Utils.randomPokemonID()
	end

	SetupScreen.iconChangeInterval = (SetupScreen.iconChangeInterval - 1) % 10
end
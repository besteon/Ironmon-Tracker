SetupScreen = {
	Colors = {
		text = "Lower box text",
		highlight = "Intermediate text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Tabs = {
		General = {
			index = 1,
			tabKey = "General",
			resourceKey = "TabGeneral",
		},
		Carousel = {
			index = 2,
			tabKey = "Carousel",
			resourceKey = "TabCarousel",
		},
		Controls = {
			index = 3,
			tabKey = "Controls",
			resourceKey = "TabControls",
		},
	},
	currentTab = 1,
	changeIconInSeconds = 3, -- Number of seconds
	currentButtonToBind = nil,
	currentInputsPressed = {},
}
local SCREEN = SetupScreen
local TAB_HEIGHT = 12

SCREEN.Buttons = {
	-- GENERAL TAB BUTTONS
	ChoosePortrait = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local iconset = Options.getIconSet()
			return string.format("%s:  %s", Resources.SetupScreen.PokemonIconSetLabel, iconset.name)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 24, 65, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
	},
	PortraitAuthor = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local iconset = Options.getIconSet()
			return string.format("%s:  %s", Resources.SetupScreen.PokemonIconSetAuthor, iconset.author)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 34, 65, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 39, 32, 32 },
		pokemonID = 1,
		getIconId = function(self)
			local animType = Options["Allow sprites to walk"] and SpriteData.Types.Walk or SpriteData.Types.Idle
			return self.pokemonID, animType
		end,
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		randomize = function(self)
			self.pokemonID = Utils.randomPokemonID()
			self.timeLastChanged = os.time()
		end,
		onClick = function(self)
			self:randomize()
			Program.redraw(true)
		end
	},
	CycleIconForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 94, Constants.SCREEN.MARGIN + 54, 10, 10, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"]) or 1
			local nextSet = tostring((currIndex % #Options.IconSetMap) + 1)
			SCREEN.Buttons.PokemonIcon.timeLastChanged = os.time()
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 34, Constants.SCREEN.MARGIN + 54, 10, 10, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"]) or 1
			local prevSet = tostring((currIndex - 2 ) % #Options.IconSetMap + 1)
			SCREEN.Buttons.PokemonIcon.timeLastChanged = os.time()
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
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 67, 33, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 67, 8, 8 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General and Options.getIconSet().isAnimated end,
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			SCREEN.Buttons.PokemonIcon.timeLastChanged = os.time()
			if not Options[self.optionKey] then
				SpriteData.changeAllActiveIcons(SpriteData.DefaultType)
			end
			Program.redraw(true)
		end
	},
	ManageData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.SetupScreen.ButtonManageData end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 60, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function() Program.changeScreenView(TrackedDataScreen) end
	},

	-- CAROUSEL TAB BUTTONS
	EnableCarousel = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Allow carousel rotation",
		getText = function(self) return " " .. Resources.SetupScreen.OptionAllowCarouselRotation end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 26, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 26, 8, 8 },
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Carousel end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end
	},

	-- CONTROL TAB BUTTONS
	OptionHaveTrackerChangeLR = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Override Button Mode to LR",
		getText = function(self) return " " .. Resources.SetupScreen.OptionOverrideButtonModeLR end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 26, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 26, 8, 8 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and not SCREEN.inProcessOfBinding() end,
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			if Options["Override Button Mode to LR"] then
				Program.changeGameSettingForLR()
			end
			Program.redraw(true)
		end
	},
	ControlsEditAll = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.SetupScreen.ButtonEditAll end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 35, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and not SCREEN.inProcessOfBinding() end,
		onClick = function() SCREEN.openEditControlsWindow() end,
	},
	ControlsRestoreDefaults = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if self.confirmReset then
				return Resources.TrackedDataScreen.ButtonClearConfirm
			else
				return "Restore Defaults" or Resources.TrackedDataScreen.ButtonClearData
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 43, Constants.SCREEN.MARGIN + 135, 72, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and not SCREEN.inProcessOfBinding() end,
		confirmReset = false,
		updateSelf = function(self)
			if self.confirmReset then
				self.textColor = "Negative text"
			else
				self.textColor = SCREEN.Colors.text
			end
		end,
		onClick = function(self)
			if self.confirmReset then
				self.confirmReset = false
				SCREEN.restoreDefaultControls()
			else
				self.confirmReset = true
			end
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		reset = function(self)
			self.confirmReset = false
			self:updateSelf()
		end,
	},

	-- BINDING A BUTTON SCREEN
	ControlBindingChosenButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.SetupScreen.LabelCurrentControllerBinding) end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 27, 11, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			local controlLabel = Utils.replaceText(SCREEN.currentButtonToBind:getCustomText(), ":", "")
			local centerX = Utils.getCenteredTextX(controlLabel, Constants.SCREEN.RIGHT_GAP) - 1
			Drawing.drawText(Constants.SCREEN.WIDTH + centerX, y + 12, controlLabel, highlight, shadowcolor)

			local controlBinding = Options.CONTROLS[SCREEN.currentButtonToBind.optionKey]
			local style
			if controlBinding == Input.NO_KEY_MAPPING then
				controlBinding = "- - -"
			else
				controlBinding = controlBinding:gsub(" ", ""):gsub(",", " + ") -- Format as "A + B + START"
				style = "underline"
			end
			centerX = Utils.getCenteredTextX(controlBinding, Constants.SCREEN.RIGHT_GAP) - 2
			Drawing.drawText(Constants.SCREEN.WIDTH + centerX, y + 23, controlBinding, highlight, shadowcolor, nil, nil, style)
		end,
	},
	ControlBindingNewButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.SetupScreen.LabelNewControllerBinding) end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 67, 11, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local buttonBeingPressed, centerX
			if #SCREEN.currentInputsPressed > 0 then
				buttonBeingPressed = table.concat(SCREEN.currentInputsPressed, " + ")
				centerX = Utils.getCenteredTextX(buttonBeingPressed, Constants.SCREEN.RIGHT_GAP) - 2
			else
				local currentTimeCounter = (os.time() % 3) + 1
				buttonBeingPressed = string.format("%s%s", Resources.SetupScreen.LabelWaiting, string.rep(".", currentTimeCounter))
				centerX = Constants.SCREEN.MARGIN + 50
			end
			Drawing.drawText(Constants.SCREEN.WIDTH + centerX, y + 12, buttonBeingPressed, Theme.COLORS["Positive text"], shadowcolor)
		end,
	},
	ControlBindingInstructions = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.SetupScreen.LabelPressControllerButtons end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 106, 11, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() end,
	},
	ControlBindingNumAllowed = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s: %s", Resources.SetupScreen.LabelButtonsAllowed, SCREEN.currentButtonToBind.allowedInputs) end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 117, 11, 11 },
		isVisible = function(self)
			return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() and SCREEN.currentButtonToBind.allowedInputs < 999
		end,
	},
	ControlBindingUnbind = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Unbind" or Resources.AllScreens.Save end, -- TODO: Language
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 101, Constants.SCREEN.MARGIN + 93, 34, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() end,
		onClick = function()
			Options.CONTROLS[SCREEN.currentButtonToBind.optionKey] = Input.NO_KEY_MAPPING
			Main.SaveSettings(true)
			SCREEN.currentButtonToBind = nil
			SCREEN.currentInputsPressed = {}
			Program.redraw(true)
		end,
	},
	ControlBindingSave = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return " " .. Resources.AllScreens.Save end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 27, Constants.SCREEN.MARGIN + 135, 36, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() end,
		onClick = function()
			if #SCREEN.currentInputsPressed > 0 then
				local newBinding = table.concat(SCREEN.currentInputsPressed, ", ")
				Options.CONTROLS[SCREEN.currentButtonToBind.optionKey] = newBinding
				Main.SaveSettings(true)
			end
			SCREEN.currentButtonToBind = nil
			SCREEN.currentInputsPressed = {}
			Program.redraw(true)
		end,
	},
	ControlBindingCancel = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return " " .. Resources.AllScreens.Cancel end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 72, Constants.SCREEN.MARGIN + 135, 36, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and SCREEN.inProcessOfBinding() end,
		onClick = function()
			SCREEN.currentButtonToBind = nil
			SCREEN.currentInputsPressed = {}
			Program.redraw(true)
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		local isBinding = SCREEN.inProcessOfBinding()
		SCREEN.currentButtonToBind = nil
		SCREEN.currentInputsPressed = {}
		if isBinding then
			Program.redraw(true)
		else
			SCREEN.currentTab = SCREEN.Tabs.General
			SCREEN.Buttons.ControlsRestoreDefaults:reset()
			Program.changeScreenView(SCREEN.previousScreen or NavigationMenu)
			SCREEN.previousScreen = nil
		end
	end),
}

SetupScreen.Pager = {
	prevPage = function(self)
		SetupScreen.Buttons.CycleIconBackward:onClick()
	end,
	nextPage = function(self)
		SetupScreen.Buttons.CycleIconForward:onClick()
	end,
}

function SetupScreen.initialize()
	SCREEN.previousScreen = nil
	SCREEN.currentTab = SCREEN.Tabs.General
	SCREEN.currentButtonToBind = nil

	SCREEN.checkForNewCarouselSettings()
	SCREEN.createTabs()
	SCREEN.createButtons()

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	SCREEN.Buttons.PokemonIcon:randomize()

	local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
	local animatedBtnOption = SCREEN.Buttons["Animated Pokemon popout"]
	if not FileManager.fileExists(abraGif) and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

-- Loads carousel settings that may not have existed in a legacy Tracker version
function SetupScreen.checkForNewCarouselSettings()
	if Options["Has checked carousel battle details"] then
		return
	end

	-- Add in the new carousel setting for Battle Details
	if Utils.isNilOrEmpty(Options["CarouselItems"]) then
		Options["CarouselItems"] = "BattleDetails"
	elseif not Utils.containsText(Options["CarouselItems"], "BattleDetails") then
		Options["CarouselItems"] = Options["CarouselItems"] .. ",BattleDetails"
	end

	Options["Has checked carousel battle details"] = true
	Main.SaveSettings(true)
end

function SetupScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function SetupScreen.createTabs()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local startY = Constants.SCREEN.MARGIN + 10
	local tabPadding = 6

	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return Resources.SetupScreen[tab.resourceKey] end,
			tab = SCREEN.Tabs[tab.tabKey],
			isSelected = false,
			box = {
				startX,
				startY,
				(tabPadding * 2) + Utils.calcWordPixelLength(Resources.SetupScreen[tab.resourceKey]),
				TAB_HEIGHT
			},
			updateSelf = function(self)
				self.isSelected = (self.tab == SCREEN.currentTab)
				self.textColor = self.isSelected and SCREEN.Colors.highlight or SCREEN.Colors.text
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local color = Theme.COLORS[self.boxColors[1]]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, bgColor, bgColor) -- Box fill
				if not self.isSelected then
					gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, Drawing.ColorEffects.DARKEN, Drawing.ColorEffects.DARKEN)
				end
				gui.drawLine(x + 1, y, x + w - 1, y, color) -- Top edge
				gui.drawLine(x, y + 1, x, y + h - 1, color) -- Left edge
				gui.drawLine(x + w, y + 1, x + w, y + h - 1, color) -- Right edge
				if self.isSelected then
					gui.drawLine(x + 1, y + h, x + w - 1, y + h, bgColor) -- Remove bottom edge
				end
				local centeredOffsetX = Utils.getCenteredTextX(self:getCustomText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getCustomText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self)
				if self.tab ~= SCREEN.Tabs.Controls then
					SCREEN.Buttons.ControlsRestoreDefaults:reset()
				end
				SCREEN.currentTab = self.tab
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + (tabPadding * 2) + Utils.calcWordPixelLength(Resources.SetupScreen[tab.resourceKey])
	end
end

function SetupScreen.createButtons()
	-- TAB: GENERAL
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 78

	local optionKeyMap = {
		{ "Show random ball picker", "OptionShowRandomBallPicker", },
		{ "Show Team View", "OptionShowTeamView", },
		{ "Right justified numbers", "OptionRightJustifiedNumbers", },
		{ "Track PC Heals", "OptionTrackPCHeals", },
		{ "PC heals count downward", "OptionPCHealsCountDown", },
	}

	for _, optionTuple in ipairs(optionKeyMap) do
		SCREEN.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources.SetupScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
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

	-- TAB: CAROUSEL
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	startY = Constants.SCREEN.MARGIN + 38

	SCREEN.Buttons.CarouselSpeedHeader = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.SetupScreen.LabelSpeedSetting) end,
		box = {
			startX - 3,
			startY,
			Utils.calcWordPixelLength(string.format("%s:", Resources.SetupScreen.LabelSpeedSetting)) + 5,
			11
		},
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Carousel end,
	}
	startX = startX + 32
	for _, speedOption in ipairs(Utils.getSortedList(Options.CarouselSpeedMap)) do
		local speedLabel = speedOption.optionKey .. "x"
		local speedWidth = Utils.calcWordPixelLength(speedLabel) + 5
		SCREEN.Buttons["CarouselSpeed" .. speedLabel] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return speedLabel end,
			box = {	startX, startY, speedWidth, 11 },
			isSelected = false,
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Carousel end,
			updateSelf = function(self)
				self.isSelected = (Options["CarouselSpeed"] == speedOption.optionKey)
				self.textColor = self.isSelected and SCREEN.Colors.highlight or SCREEN.Colors.text
			end,
			draw = function(self, shadowcolor)
				if self.isSelected then
					local color = Theme.COLORS[LogTabRouteDetails.Colors.highlight]
					Drawing.drawSelectionIndicators(self.box[1], self.box[2], self.box[3], self.box[4], color, 1, 5, 1)
				end
			end,
			onClick = function(self)
				Options["CarouselSpeed"] = speedOption.optionKey
				Main.SaveSettings(true)
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + speedWidth + 4
	end

	startY = startY + Constants.SCREEN.LINESPACING + 4

	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4

	local infoText = string.format("%s:", Resources.SetupScreen.LabelInfoToShow)
	SCREEN.Buttons.CarouselInfoHeader = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return infoText end,
		box = {	startX - 2, startY, Utils.calcWordPixelLength(infoText) + 5, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Carousel end,
		draw = function(self, shadowcolor) Drawing.drawUnderline(self) end,
	}
	startY = startY + Constants.SCREEN.LINESPACING + 3

	local carouselKeyMap = {
		{ "Badges", "CarouselBadges", },
		{ "Notes", "CarouselNotes", },
		{ "RouteInfo", "CarouselRouteInfo", },
		{ "Trainers", "CarouselTrainers", },
		{ "LastAttack", "CarouselLastAttack", },
		{ "BattleDetails", "CarouselBattleDetails", },
		{ "Pedometer", "CarouselPedometer", },
	}

	local function saveCarouselSettings()
		local carouselItems = {}
		for _, tuple in ipairs(carouselKeyMap) do
			if SCREEN.Buttons["Carousel" .. tuple[1]].toggleState then
				table.insert(carouselItems, tuple[1])
			end
		end
		Options["CarouselItems"] = table.concat(carouselItems, ",")
		Main.SaveSettings(true)
	end

	for _, tuple in ipairs(carouselKeyMap) do
		local optionWidth = Utils.calcWordPixelLength(Resources.SetupScreen[tuple[2]]) + 5
		SCREEN.Buttons["Carousel" .. tuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = tuple[1],
			getText = function(self) return " " .. Resources.SetupScreen[tuple[2]] end,
			clickableArea = { startX, startY, optionWidth + 10, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Utils.containsText(Options["CarouselItems"], tuple[1]),
			updateSelf = function(self)
				self.toggleState = Utils.containsText(Options["CarouselItems"], tuple[1])
			end,
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Carousel end,
			onClick = function(self)
				self.toggleState = not self.toggleState
				saveCarouselSettings()
				Program.redraw(true)
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING
	end

	-- TAB: CONTROLS
	local controlKeyMap = {
		{ "Toggle view", "PromptEditControllerToggleView", },
		{ "Info shortcut", "PromptEditControllerInfoShortcut", },
		{ "Cycle through stats", "PromptEditControllerCycleStats", },
		{ "Mark stat", "PromptEditControllerMarkStat", },
		{ "Next page", "PromptEditControllerNextPage", },
		{ "Previous page", "PromptEditControllerPreviousPage", },
	}

	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - 13
	startY = Constants.SCREEN.MARGIN + 40

	SCREEN.Buttons["Control" .. "Load next seed"] = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		optionKey = "Load next seed",
		allowedInputs = 999, -- No limit to number of button input allowed for this binding
		getCustomText = function(self) return string.format("%s:", Resources.SetupScreen.PromptEditControllerLoadNext) end,
		clickableArea = { startX - 90, startY, 100, 21 },
		box = {	startX, startY, 10, 10 },
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and not SCREEN.inProcessOfBinding() end,
		onClick = function(self)
			SCREEN.currentButtonToBind = self
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local bindingColor
			local controlLabel = self:getCustomText()
			local controlBinding = Options.CONTROLS[self.optionKey]
			if controlBinding ~= Options.Defaults.CONTROLS[self.optionKey] then
				bindingColor = Theme.COLORS["Positive text"]
			else
				bindingColor = Theme.COLORS[SCREEN.Colors.highlight]
			end
			controlBinding = controlBinding:gsub(" ", ""):gsub(",", " + ") -- Format as "A + B + START"
			local centerX = Utils.getCenteredTextX(controlBinding, Constants.SCREEN.RIGHT_GAP) - 2
			Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, y - 2, controlLabel, Theme.COLORS[SCREEN.Colors.text], shadowcolor)
			Drawing.drawText(Constants.SCREEN.WIDTH + centerX, y + 8, controlBinding, bindingColor, shadowcolor, nil, nil, "underline")
		end,
	}

	startY = startY + (Constants.SCREEN.LINESPACING * 2)

	local COL2_X_OFFSET = 86
	for _, controlTuple in ipairs(controlKeyMap) do
		SCREEN.Buttons["Control" .. controlTuple[1]] = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.GEAR,
			optionKey = controlTuple[1],
			allowedInputs = 1, -- Max of 1 button input allowed for this binding
			getCustomText = function(self) return string.format("%s:", Resources.SetupScreen[controlTuple[2]]) end,
			clickableArea = { startX - 50, startY, 60, 10 },
			box = {	startX, startY, 10, 10 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Controls and not SCREEN.inProcessOfBinding() end,
			onClick = function(self)
				SCREEN.currentButtonToBind = self
				Program.redraw(true)
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local leftX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
				local bindingColor, style
				local controlLabel = self:getCustomText()
				local controlBinding = Options.CONTROLS[self.optionKey]
				if controlBinding == Input.NO_KEY_MAPPING then
					controlBinding = "- - -"
				else
					style = "underline"
				end
				if controlBinding ~= Options.Defaults.CONTROLS[self.optionKey] then
					bindingColor = Theme.COLORS["Positive text"]
				else
					bindingColor = Theme.COLORS[SCREEN.Colors.highlight]
				end
				Drawing.drawText(leftX, y - 2, controlLabel, Theme.COLORS[SCREEN.Colors.text], shadowcolor)
				Drawing.drawText(leftX + COL2_X_OFFSET, y - 2, controlBinding, bindingColor, shadowcolor, nil, nil, style)
			end,
		}
		startY = startY + Constants.SCREEN.LINESPACING + 1
	end
end

function SetupScreen.inProcessOfBinding()
	return SCREEN.currentButtonToBind ~= nil
end

function SetupScreen.checkCurrentJoypadInput()
	local joypad = Input.getJoypadInputFormatted()
	local pressedInputs = {}
	for _, inputKey in ipairs(Input.OrderedControllerInputs) do
		if joypad[inputKey] then
			table.insert(pressedInputs, inputKey)
		end
	end
	if #pressedInputs > 0 then
		if SetupScreen.inProcessOfBinding() and #pressedInputs > SCREEN.currentButtonToBind.allowedInputs then
			SCREEN.currentInputsPressed = { pressedInputs[1] }
		else
			SCREEN.currentInputsPressed = pressedInputs
		end
	end
	return pressedInputs
end

function SetupScreen.restoreDefaultControls()
	FileManager.copyTable(Options.Defaults.CONTROLS, Options.CONTROLS)
	Main.SaveSettings(true)
end

function SetupScreen.openEditControlsWindow()
	local form = ExternalUI.BizForms.createForm(Resources.SetupScreen.PromptEditControllerTitle, 445, 290, 75, 20)

	form:createLabel(Resources.SetupScreen.PromptEditControllerDesc, 19, 10)

	local controlKeyMap = {
		{"Load next seed", "PromptEditControllerLoadNext", },
		{"Toggle view", "PromptEditControllerToggleView", },
		{"Info shortcut", "PromptEditControllerInfoShortcut", },
		{"Cycle through stats", "PromptEditControllerCycleStats", },
		{"Mark stat", "PromptEditControllerMarkStat", },
		{"Next page", "PromptEditControllerNextPage", },
		{"Previous page", "PromptEditControllerPreviousPage", },
	}

	local inputTextboxes = {}
	local col1X = 70
	local col2X = 220
	local offsetY = 35

	local NOT_BOUND_TEXT = "- - -"
	for i, controlTuple in ipairs(controlKeyMap) do
		local controlLabel = string.format("%s:", Resources.SetupScreen[controlTuple[2]])
		local controlBinding = Options.CONTROLS[controlTuple[1]]
		if controlBinding == Input.NO_KEY_MAPPING then
			controlBinding = NOT_BOUND_TEXT
		end
		form:createLabel(controlLabel, col1X, offsetY)
		inputTextboxes[i] = form:createTextBox(controlBinding, col2X, offsetY - 2, 140, 21)
		offsetY = offsetY + 24
	end

	-- Buttons
	local saveCloseLabel = string.format("%s && %s", Resources.AllScreens.Save, Resources.AllScreens.Close)
	form:createButton(saveCloseLabel, 45, offsetY + 5, function()
		for i, controlTuple in ipairs(controlKeyMap) do
			local controlCombination = ExternalUI.BizForms.getText(inputTextboxes[i])
			if controlCombination == NOT_BOUND_TEXT then
				controlCombination = Input.NO_KEY_MAPPING
			else
				controlCombination = Utils.formatControls(controlCombination)
			end
			if not Utils.isNilOrEmpty(controlCombination) then
				Options.CONTROLS[controlTuple[1]] = controlCombination
			end
		end
		Main.SaveSettings(true)
		SCREEN.refreshButtons()
		Program.redraw(true)
		form:destroy()
	end)
	form:createButton(Resources.SetupScreen.PromptEditControllerResetDefault, 175, offsetY + 5, function()
		for i, controlTuple in ipairs(controlKeyMap) do
			local defaultText = Options.Defaults.CONTROLS[controlTuple[1]] or ""
			ExternalUI.BizForms.setText(inputTextboxes[i], defaultText)
		end
	end)
	form:createButton(Resources.AllScreens.Cancel, 320, offsetY + 5, function()
		form:destroy()
	end)
end

-- USER INPUT FUNCTIONS
function SetupScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function SetupScreen.drawScreen()
	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SCREEN.Colors.boxFill])

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.SetupScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw canvas box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y + TAB_HEIGHT, canvas.width, canvas.height - TAB_HEIGHT, canvas.border, canvas.fill)
	-- Draw bottom edge for the window tab bars
	gui.drawLine(canvas.x, canvas.y + TAB_HEIGHT, canvas.x + canvas.width, canvas.y + TAB_HEIGHT, canvas.border)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		if button ~= SCREEN.Buttons.PokemonIcon then
			Drawing.drawButton(button, canvas.shadow)
		end
	end
	-- Draw last so it appears over any other buttons
	Drawing.drawButton(SCREEN.Buttons.PokemonIcon, canvas.shadow)

	-- Randomize the pokemon shown every 'changeIconInSeconds'
	if os.time() >= SCREEN.Buttons.PokemonIcon.timeLastChanged + SCREEN.changeIconInSeconds then
		SCREEN.Buttons.PokemonIcon:randomize()
	end
end
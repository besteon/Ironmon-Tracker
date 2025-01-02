GameOptionsScreen = {
	Colors = {
		text = "Lower box text",
		highlight = "Intermediate text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Tabs = {
		Battle = {
			index = 1,
			tabKey = "Battle",
			resourceKey = "TabBattle",
		},
		GameOver = {
			index = 2,
			tabKey = "GameOver",
			resourceKey = "TabGameOver",
		},
		Other = {
			index = 3,
			tabKey = "Other",
			resourceKey = "TabOther",
		},
	},
	currentTab = nil,
}
local SCREEN = GameOptionsScreen
local TAB_HEIGHT = 12

SCREEN.Buttons = {
	GameStats = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.GameOptionsScreen.ButtonGameStats end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 52, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Battle end,
		onClick = function() Program.changeScreenView(StatsScreen) end,
	},
	GameOverLabel = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.GameOptionsScreen.LabelGameOverCondition) end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 24, 120, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.GameOver end,
	},
	Back = Drawing.createUIElementBackButton(function()
		SCREEN.currentTab = SCREEN.Tabs.Battle
		SCREEN.refreshButtons()
		Program.changeScreenView(NavigationMenu)
	end),
}

function GameOptionsScreen.initialize()
	SCREEN.currentTab = SCREEN.Tabs.Battle
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
end

function GameOptionsScreen.createTabs()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local startY = Constants.SCREEN.MARGIN + 10
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources.GameOptionsScreen[tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return tabText end,
			tab = SCREEN.Tabs[tab.tabKey],
			isSelected = false,
			box = {	startX, startY, tabWidth, TAB_HEIGHT },
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
				SCREEN.currentTab = self.tab
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end

function GameOptionsScreen.createButtons()
	-- BATTLE TAB
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + TAB_HEIGHT + 14
	local optionKeyMapBattle = {
		{ "Auto swap to enemy", "OptionAutoSwapEnemy", },
		{ "Show physical special icons", "OptionShowPhysicalSpecial", },
		{ "Show move effectiveness", "OptionShowMoveEffectiveness", },
		{ "Calculate variable damage", "OptionCalculateVariableDamage", },
		{ "Show Poke Ball catch rate", "OptionShowBallCatchRate", },
		{ "Count enemy PP usage", "OptionCountEnemyPP", },
		{ "Show last damage calcs", "OptionShowLastDamage", },
		{ "Reveal info if randomized", "OptionRevealRandomizedInfo", },
	}

	for _, optionTuple in ipairs(optionKeyMapBattle) do
		SCREEN.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources.GameOptionsScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Battle end,
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)
				Program.redraw(true)
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING + 1
	end

	-- GAME OVER TAB
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	startY = SCREEN.Buttons.GameOverLabel.box[2] + Constants.SCREEN.LINESPACING + 6
	local optionKeyMapGameOver = {
		{ "LeadPokemonFaints", "OptionLeadPokemonFaints", },
		{ "HighestLevelFaints", "OptionHighestLevelFaints", },
		{ "EntirePartyFaints", "OptionEntirePartyFaints", },
	}

	for _, optionTuple in ipairs(optionKeyMapGameOver) do
		SCREEN.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			getText = function(self) return string.format(" %s", Resources.GameOptionsScreen[optionTuple[2]]) end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.GameOver end,
			toggleState = Options["Game Over condition"] == optionTuple[1],
			updateSelf = function(self)
				self.toggleState = Options["Game Over condition"] == optionTuple[1]
			end,
			onClick = function(self)
				if self.toggleState == true then return end -- do nothing if only option selected
				Options["Game Over condition"] = optionTuple[1]
				Main.SaveSettings(true)
				SCREEN.refreshButtons()
				Program.redraw(true)
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING + 1
	end

	-- OTHER TAB
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	startY = Constants.SCREEN.MARGIN + TAB_HEIGHT + 14
	local optionKeyMapOther = {
		{ "Show starter ball info", "OptionShowStarterBallInfo", },
		{ "Hide stats until summary shown", "OptionHideStatsUntilSummary", },
		{ "Show nicknames", "OptionShowNicknames", },
		{ "Show experience points bar", "OptionShowExpBar", },
		{ "Show heals as whole number", "OptionShowHealsAsValue", },
		{ "Determine friendship readiness", "OptionDetermineFriendship", },
		{ "Open Book Play Mode", "OptionOpenBookPlayMode", },
	}
	for _, optionTuple in ipairs(optionKeyMapOther) do
		SCREEN.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources.GameOptionsScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Other end,
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)
				-- If check summary gets toggled, force update on tracker data (case for just starting the game and turning option on)
				if self.optionKey == "Hide stats until summary shown" then
					-- If enabled, then default to hiding the summary. Otherwise reveal the information
					if self.toggleState then
						Tracker.Data.hasCheckedSummary = false
					else
						Tracker.Data.hasCheckedSummary = true
					end
				elseif self.optionKey == "Open Book Play Mode" then
					if self.toggleState and not LogOverlay.hasParsedThisLog() then
						LogOverlay.preloadForOpenBook()
					end
				end
				Program.redraw(true)
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING + 1
	end

	SCREEN.Buttons["Open Book Play Mode"].draw = function(self, shadowcolor)
		if not self.toggleState then
			return
		end
		local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
		local color = Theme.COLORS[SCREEN.Colors.highlight]
		local warningMsg = Resources.GameOptionsScreen.LabelExtraTimeWarning
		Drawing.drawImageAsPixels(Constants.PixelImages.WARNING, x + 10, y + h + 3, color, shadowcolor)
		Drawing.drawText(x + 20, y + h + 2, warningMsg, color, shadowcolor)
	end
end

function GameOptionsScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

-- USER INPUT FUNCTIONS
function GameOptionsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function GameOptionsScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SCREEN.Colors.boxFill])

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10 + TAB_HEIGHT,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10 - TAB_HEIGHT,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.GameOptionsScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
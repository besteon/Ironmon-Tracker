LanguageScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		highlight = "Intermediate text",
	},
	Tabs = {
		Display = {
			index = 1,
			tabKey = "Display",
			resourceKey = "TabDisplay",
		},
		Options = {
			index = 2,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	currentTab = nil,
}
local SCREEN = LanguageScreen
local TAB_HEIGHT = 12

SCREEN.Buttons = {
	DisplayLanguage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local displayLang = (Resources.currentLanguage or {}).DisplayName or Constants.BLANKLINE
			return string.format("%s:  %s", Resources.LanguageScreen.DisplayLanguage, displayLang)
		end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + TAB_HEIGHT + 12, 70, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Display end,
	},
	HelpContribute = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.LanguageScreen.ButtonHelpContribute end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 67, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Options end,
		onClick = function() Utils.openBrowserWindow(FileManager.Urls.DISCUSSIONS) end
	},
	Back = Drawing.createUIElementBackButton(function()
		SCREEN.currentTab = SCREEN.Tabs.Display
		SCREEN.refreshButtons()
		Program.changeScreenView(NavigationMenu)
	end),
}

function LanguageScreen.initialize()
	SCREEN.currentTab = SCREEN.Tabs.Display
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

	SCREEN.refreshButtons()
end

function LanguageScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function LanguageScreen.createTabs()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local startY = Constants.SCREEN.MARGIN + 10
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources.LanguageScreen[tab.resourceKey]
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

function LanguageScreen.createButtons()
	-- DISPLAY TAB
	local availableLanguages = {}
	for _, language in pairs(Resources.Languages) do
		local isSupportedByEmulator = Main.supportsSpecialChars or not language.RequiresUTF16
		if isSupportedByEmulator and not language.ExcludeFromSettings then
			table.insert(availableLanguages, language)
		end
	end
	table.sort(availableLanguages, function(a, b) return a.Ordinal < b.Ordinal end)

	local btnWidth = 63
	local btnHeight = 16
	local spacer = 6
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + TAB_HEIGHT + 22 + spacer
	for i, language in ipairs(availableLanguages) do
		local button = {
			type = Constants.ButtonTypes.ICON_BORDER,
			getText = function(self) return language.DisplayName end,
			box = { startX, startY, btnWidth, btnHeight },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Display end,
			iconColors = { SCREEN.Colors.highlight, },
			updateSelf = function(self)
				if language == Resources.currentLanguage then
					self.image = Constants.PixelImages.CHECKMARK
					self.boxColors[1] = SCREEN.Colors.highlight
				else
					self.image = nil
					self.boxColors[1] = SCREEN.Colors.border
				end
			end,
			onClick = function()
				Resources.changeLanguageSetting(language)
				SCREEN.refreshButtons()
				LogOverlay.rebuildScreen()
				Program.redraw(true)
			end,
		}

		table.insert(SCREEN.Buttons, button)

		if i % 2 == 1 then -- left column
			startX = startX + btnWidth + spacer
		else -- right column
			startY = startY + btnHeight + spacer
			startX = startX - btnWidth - spacer
		end
	end

	-- OPTIONS TAB
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	startY = Constants.SCREEN.MARGIN + TAB_HEIGHT + 14
	local optionKeyMap = {
		{ "Autodetect language from game", "AutodetectSetting", },
		{ "Show game words in language", "OptionGameWordsInLanguage", },
		{ "Show menu text in language", "OptionMenusTextInLanguage", },
	}

	for _, optionTuple in ipairs(optionKeyMap) do
		SCREEN.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources.LanguageScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Options end,
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)

				if self.optionKey == "Show game words in language" then
					Resources.loadLanguageData()
				elseif self.optionKey == "Show menu text in language" then
					Resources.loadLanguageData()
				elseif self.optionKey == "Autodetect language from game" and Options["Autodetect language from game"] then
					-- If this setting changes from OFF to ON, check game language
					Resources.autoDetectForeignLanguage()
				end

				SCREEN.refreshButtons()
				Program.redraw(true)
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING + 1
	end
end

-- USER INPUT FUNCTIONS
function LanguageScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function LanguageScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
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
	local headerText = Utils.toUpperUTF8(Resources.LanguageScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end
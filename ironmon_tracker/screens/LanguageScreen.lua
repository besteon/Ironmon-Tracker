LanguageScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		highlight = "Intermediate text",
	},
}

LanguageScreen.Buttons = {
	DisplayLanguage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			local displayLang = (Resources.currentLanguage or {}).DisplayName or Constants.BLANKLINE
			return string.format("%s:  %s", Resources.LanguageScreen.DisplayLanguage, displayLang)
		end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 12, 70, 11 },
	},
	AutodetectLanguageOption = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Autodetect language from game",
		getText = function(self) return Resources.LanguageScreen.AutodetectSetting end,
		-- The y-position for this button is calculated later in createLanguageButtons()
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 120, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 120, 8, 8 },
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)

			-- If this setting changes from OFF to ON, check game language
			if Options[self.optionKey] then
				Resources.autoDetectForeignLanguage()
				LanguageScreen.refreshButtons()
			end
			Program.redraw(true)
		end
	},
	HelpContribute = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.LanguageScreen.ButtonHelpContribute end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 67, 11 },
		onClick = function() Utils.openBrowserWindow(FileManager.Urls.DISCUSSIONS) end
	},
	Back = Drawing.createUIElementBackButton(function() Program.changeScreenView(NavigationMenu) end),
}

function LanguageScreen.initialize()
	LanguageScreen.createLanguageButtons()

	for _, button in pairs(LanguageScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = LanguageScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { LanguageScreen.Colors.border, LanguageScreen.Colors.boxFill }
		end
	end

	LanguageScreen.refreshButtons()
end

function LanguageScreen.refreshButtons()
	for _, button in pairs(LanguageScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function LanguageScreen.createLanguageButtons()
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
	local startY = Constants.SCREEN.MARGIN + 22 + spacer
	for i, language in ipairs(availableLanguages) do
		local button = {
			type = Constants.ButtonTypes.ICON_BORDER,
			getText = function(self) return language.DisplayName end,
			box = { startX, startY, btnWidth, btnHeight },
			iconColors = { LanguageScreen.Colors.highlight, },
			updateSelf = function(self)
				if language == Resources.currentLanguage then
					self.image = Constants.PixelImages.CHECKMARK
					self.boxColors[1] = LanguageScreen.Colors.highlight
				else
					self.image = nil
					self.boxColors[1] = LanguageScreen.Colors.border
				end
			end,
			onClick = function()
				Resources.changeLanguageSetting(language)
				LanguageScreen.refreshButtons()
				LogOverlay.rebuildScreen()
				Program.redraw(true)
			end,
		}

		table.insert(LanguageScreen.Buttons, button)

		if i % 2 == 1 then -- left column
			startX = startX + btnWidth + spacer
		else -- right column
			startY = startY + btnHeight + spacer
			startX = startX - btnWidth - spacer
		end
	end

	-- Shift the autodetect option below the last created box
	local lastButton = LanguageScreen.Buttons[#LanguageScreen.Buttons]
	startY = lastButton.box[2] + lastButton.box[4] + 7
	LanguageScreen.Buttons.AutodetectLanguageOption.box[2] = startY
	LanguageScreen.Buttons.AutodetectLanguageOption.clickableArea[2] = startY
end

-- USER INPUT FUNCTIONS
function LanguageScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LanguageScreen.Buttons)
end

-- DRAWING FUNCTIONS
function LanguageScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[LanguageScreen.Colors.text],
		border = Theme.COLORS[LanguageScreen.Colors.border],
		fill = Theme.COLORS[LanguageScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[LanguageScreen.Colors.boxFill]),
	}
	local textLineY = topBox.y + 2

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.LanguageScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 7

	-- Draw all buttons
	for _, button in pairs(LanguageScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end
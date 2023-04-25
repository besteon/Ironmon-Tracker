LanguageScreen = {
	Colors = {
		upperText = "Default text",
		upperBorder = "Upper box border",
		upperBoxFill = "Upper box background",
		highlight = "Intermediate text",
	},
}

LanguageScreen.Buttons = {
	AutodetectLanguageOption = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return Resources.LanguageScreen.AutodetectSetting end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 8, 8 },
		toggleState = true,
		toggleColor = "Positive text",
		updateSelf = function(self)
			self.toggleState = Options["Autodetect language from game"] == true
		end,
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting("Autodetect language from game", self.toggleState)
			Options.forceSave()
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Back end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self) Program.changeScreenView(NavigationMenu) end
	},
}

function LanguageScreen.initialize()
	LanguageScreen.createLanguageButtons()

	for _, button in pairs(LanguageScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = LanguageScreen.Colors.upperText
		end
		if button.boxColors == nil then
			button.boxColors = { LanguageScreen.Colors.upperBorder, LanguageScreen.Colors.upperBoxFill }
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
	local startY = Constants.SCREEN.MARGIN + 38 + spacer
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
					self.boxColors[1] = LanguageScreen.Colors.upperBorder
				end
			end,
			onClick = function()
				Resources.changeLanguageSetting(language)
				LanguageScreen.refreshButtons()
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
		text = Theme.COLORS[LanguageScreen.Colors.upperText],
		border = Theme.COLORS[LanguageScreen.Colors.upperBorder],
		fill = Theme.COLORS[LanguageScreen.Colors.upperBoxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[LanguageScreen.Colors.upperBoxFill]),
	}
	local textLineY = topBox.y + 2

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	local headerText = Resources.LanguageScreen.Header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local offsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + offsetX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 7

	local chooseLanguageText = string.format("%s:", Resources.LanguageScreen.ChangeLanguageText)
	Drawing.drawText(topBox.x + 2, textLineY, chooseLanguageText, topBox.text, topBox.shadow)

	-- Draw all buttons
	for _, button in pairs(LanguageScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end
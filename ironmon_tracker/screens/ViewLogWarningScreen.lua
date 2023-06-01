ViewLogWarningScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

ViewLogWarningScreen.Buttons = {
	Yes = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.WARNING,
		getText = function(self) return Resources.ViewLogWarningScreen.ButtonYesImSure end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 40, 75, 16 },
		textColor = "Intermediate text",
		onClick = function(self)
			LogOverlay.viewLogFile(FileManager.PostFixes.AUTORANDOMIZED)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Back end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self) Program.changeScreenView(ExtrasScreen) end
	},
}

-- Initialize the screen
function ViewLogWarningScreen.initialize()
	-- Set default colors for buttons
	for _, button in pairs(ViewLogWarningScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = ViewLogWarningScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { ViewLogWarningScreen.Colors.border, ViewLogWarningScreen.Colors.boxFill }
		end
	end
end

-- Check if any buttons were clicked
function ViewLogWarningScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, ViewLogWarningScreen.Buttons)
end

-- Draw the screen
function ViewLogWarningScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[ViewLogWarningScreen.Colors.boxFill])
	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[ViewLogWarningScreen.Colors.text],
		border = Theme.COLORS[ViewLogWarningScreen.Colors.border],
		fill = Theme.COLORS[ViewLogWarningScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[ViewLogWarningScreen.Colors.boxFill]),
	}

	-- Draw header text
	local headerText = Resources.ViewLogWarningScreen.Title:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	local textLineY = topBox.y + 3

	local wrappedDesc = Utils.getWordWrapLines(Resources.ViewLogWarningScreen.WarningAreYouSure, 32)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 4, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
	end
	textLineY = textLineY + Constants.SCREEN.LINESPACING * 2 + 5 -- Skip over the Yes button

	wrappedDesc = Utils.getWordWrapLines(Resources.ViewLogWarningScreen.WarningSpiritOfIronmon, 35)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 4, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
	end
	textLineY = textLineY + 7

	wrappedDesc = Utils.getWordWrapLines(Resources.ViewLogWarningScreen.WarningIfUnsure, 35)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 4, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
	end

	-- Draw buttons
	for _, button in pairs(ViewLogWarningScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

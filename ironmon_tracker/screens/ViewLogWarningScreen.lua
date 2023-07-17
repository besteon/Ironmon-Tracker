ViewLogWarningScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

ViewLogWarningScreen.Buttons = {
	ViewLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self) return Resources.ViewLogWarningScreen.ButtonViewCurrentLog end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 39, 56, 16 },
		onClick = function(self)
			LogOverlay.viewLogFile(FileManager.PostFixes.AUTORANDOMIZED)
		end,
	},
	ViewPreviousLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self) return Resources.ViewLogWarningScreen.ButtonViewPreviousLog end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 64, Constants.SCREEN.MARGIN + 39, 72, 16 },
		onClick = function(self)
			LogOverlay.viewLogFile(FileManager.PostFixes.PREVIOUSATTEMPT)
		end
	},
	WarningIcon1 = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.WARNING,
		textColor = "Intermediate text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 41, Constants.SCREEN.MARGIN + 60, 10, 10 },
	},
	WarningIcon2 = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.WARNING,
		textColor = "Intermediate text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 65, Constants.SCREEN.MARGIN + 60, 10, 10 },
	},
	WarningIcon3 = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.WARNING,
		textColor = "Intermediate text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 89, Constants.SCREEN.MARGIN + 60, 10, 10 },
	},
	Back = Drawing.createUIElementBackButton(function() Program.changeScreenView(ExtrasScreen) end),
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
	local headerText = Utils.toUpperUTF8(Resources.ViewLogWarningScreen.Title)
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
	textLineY = textLineY + Constants.SCREEN.LINESPACING * 2 + 14 -- Skip over the view log buttons

	wrappedDesc = Utils.getWordWrapLines(Resources.ViewLogWarningScreen.WarningSpiritOfIronmon, 35)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 4, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
	end
	textLineY = textLineY + 6

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

ViewLogWarningScreen = {
	Labels = {
		-- First warnings paragraph. Second value is text color
		warnings1 = {
			{ "Are you sure you want to view the",   "Intermediate text" },
			{ "log file?",                           "Intermediate text" },
			{ "",                                    "" },
			{ "In Ironmon, it's against the spirit", "" },
			{ "of the challenge to view log info",   "" },
			{ "about the game before it's over.",    "" },
		},
		-- Second warnings paragraph, displayed below "yes" button
		warnings2 = {
			{ "If you are unsure, simply do not", "" },
			{ "view the log file.",               "" }
		},
		header = "! ! W A R N I N G ! !",
		yes = "Yes, I'm sure",
	},
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

local buttonHeight = 16
local buttonWidth = 75
-- Used to more easily place the "Yes" button
local buttonYOffset = Constants.SCREEN.MARGIN + 10 +
	 ((#ViewLogWarningScreen.Labels.warnings1 + 1) * (Constants.SCREEN.LINESPACING))
-- Center the "Yes" button
local buttonXOffset = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN +
	 ((Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)) / 2) - (buttonWidth / 2)

ViewLogWarningScreen.Buttons = {
	-- "Yes, I'm sure" button, displayed in the middle of the screen
	Yes = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.WARNING,
		text = ViewLogWarningScreen.Labels.yes,
		box = { buttonXOffset, buttonYOffset, buttonWidth, buttonHeight },
		textColor = "Intermediate text",
		onClick = function(self)
			LogOverlay.viewLogFile(FileManager.PostFixes.AUTORANDOMIZED)
		end
	},
	-- "Back" button, displayed in the bottom right corner of the screen
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(ExtrasScreen)
		end
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
	local headerText = ViewLogWarningScreen.Labels.header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local centerOffsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + centerOffsetX, Constants.SCREEN.MARGIN - 2, headerText,
		Theme.COLORS[ViewLogWarningScreen.Colors.text],
		headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw buttons
	for _, button in pairs(ViewLogWarningScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end

	-- Draw warning paragraph 1
	for i in ipairs(ViewLogWarningScreen.Labels.warnings1) do
		local text = ViewLogWarningScreen.Labels.warnings1[i][1]
		local color = ViewLogWarningScreen.Labels.warnings1[i][2]
		if color == "" then
			color = ViewLogWarningScreen.Colors.text
		end
		local shadow = Utils.calcShadowColor(Theme.COLORS[ViewLogWarningScreen.Colors.boxFill])
		local centerOffsetX = Utils.getCenteredTextX(text, topBox.width)
		Drawing.drawText(topBox.x + centerOffsetX, topBox.y + (i * Constants.SCREEN.LINESPACING) - 9, text,
			Theme.COLORS[color],
			shadow)
	end

	-- Draw warning paragraph 2
	for i in ipairs(ViewLogWarningScreen.Labels.warnings2) do
		local text = ViewLogWarningScreen.Labels.warnings2[i][1]
		local color = ViewLogWarningScreen.Labels.warnings2[i][2]
		if color == "" then
			color = ViewLogWarningScreen.Colors.text
		end
		local shadow = Utils.calcShadowColor(Theme.COLORS[ViewLogWarningScreen.Colors.boxFill])
		local centerOffsetX = Utils.getCenteredTextX(text, topBox.width)
		Drawing.drawText(topBox.x + centerOffsetX, buttonYOffset + buttonHeight + (i * Constants.SCREEN.LINESPACING) - 4,
			text,
			Theme.COLORS[color],
			shadow)
	end
end

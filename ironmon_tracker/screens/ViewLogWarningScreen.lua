ViewLogWarningScreen = {
	Labels = {
		warnings =
		{ "Are you sure you want to view the",
			"log file? Viewing the log file wihout ",
			"completing a run or losing a battle ",
			"is considered cheating.",
			"",
			"If you are unsure,",
			"please do not view the log file." },
		header = "! ! W A R N I N G ! !",
		yes = "Yes, I'm sure",
	},
	viewLogWarning = false,
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}
local buttonYOffset = Constants.SCREEN.MARGIN + 10 + ((#ViewLogWarningScreen.Labels.warnings + 1) * (Constants.SCREEN.LINESPACING)) + 4

ViewLogWarningScreen.Buttons = {
	Yes = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.WARNING,
		text = ViewLogWarningScreen.Labels.yes,

		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, buttonYOffset, 112, 16 },
		onClick = function(self)
			ViewLogWarningScreen.viewLogWarning = true
			Utils.tempDisableBizhawkSound()
			if not GameOverScreen.viewLogFile() then
				-- If the log file was already parsed, re-use that
				if RandomizerLog.Data.Settings ~= nil then
					LogOverlay.parseAndDisplay()
				else
					GameOverScreen.openLogFilePrompt()
				end
			end

			Utils.tempEnableBizhawkSound()
		end
	},
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

function ViewLogWarningScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 14
	local linespacing = Constants.SCREEN.LINESPACING + 1

	for _, button in pairs(ViewLogWarningScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = ViewLogWarningScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { ViewLogWarningScreen.Colors.border, ViewLogWarningScreen.Colors.boxFill }
		end
	end
end

function ViewLogWarningScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, ViewLogWarningScreen.Buttons)
end

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
	Drawing.drawText(topBox.x + centerOffsetX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"],
		headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	for _, button in pairs(ViewLogWarningScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
	local warningTextEndY = 0
	-- Draw warning text
	for i in ipairs(ViewLogWarningScreen.Labels.warnings) do
		local text = ViewLogWarningScreen.Labels.warnings[i]
		local shadow = Utils.calcShadowColor(Theme.COLORS[ViewLogWarningScreen.Colors.boxFill])
		local centerOffsetX = Utils.getCenteredTextX(text, topBox.width)
		Drawing.drawText(topBox.x + centerOffsetX, topBox.y + (i * Constants.SCREEN.LINESPACING) + 2, text, topBox.text,
			shadow)
	end
end

GameOptionsScreen = {
	Labels = {
		header = "Gameplay Options",
	},
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

GameOptionsScreen.OptionKeys = {
	"Auto swap to enemy",
	"Hide stats until summary shown",  -- Text referenced in initialize()
	"Show experience points bar",
	"Show physical special icons",
	"Show move effectiveness",
	"Calculate variable damage",
	"Determine friendship readiness",
	"Count enemy PP usage",
	"Show last damage calcs",
	"Reveal info if randomized",
}

GameOptionsScreen.Buttons = {
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Back end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(NavigationMenu)
		end
	},
}

function GameOptionsScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
	local startY = Constants.SCREEN.MARGIN + 14
	local linespacing = Constants.SCREEN.LINESPACING + 1

	for _, optionKey in ipairs(GameOptionsScreen.OptionKeys) do
		GameOptionsScreen.Buttons[optionKey] = {
			type = Constants.ButtonTypes.CHECKBOX,
			text = optionKey,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionKey],
			toggleColor = "Positive text",
			onClick = function(self)
				-- Toggle the setting and store the change to be saved later in Settings.ini
				self.toggleState = not self.toggleState

				-- If check summary gets toggled, force update on tracker data (case for just starting the game and turning option on)
				if self.text == "Hide stats until summary shown" then
					Tracker.Data.hasCheckedSummary = Options[self.text]
				end

				Options.updateSetting(self.text, self.toggleState)
			end
		}
		startY = startY + linespacing
	end

	for _, button in pairs(GameOptionsScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = GameOptionsScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { GameOptionsScreen.Colors.border, GameOptionsScreen.Colors.boxFill }
		end
	end
end

-- USER INPUT FUNCTIONS
function GameOptionsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, GameOptionsScreen.Buttons)
end

-- DRAWING FUNCTIONS
function GameOptionsScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[GameOptionsScreen.Colors.boxFill])

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[GameOptionsScreen.Colors.text],
		border = Theme.COLORS[GameOptionsScreen.Colors.border],
		fill = Theme.COLORS[GameOptionsScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[GameOptionsScreen.Colors.boxFill]),
	}

	-- Draw header text
	local headerText = GameOptionsScreen.Labels.header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local centerOffsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + centerOffsetX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw all buttons
	for _, button in pairs(GameOptionsScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end
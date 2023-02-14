GameOptionsScreen = {
	Key = "GameOptionsScreen",
	headerText = "Gameplay Options",
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

GameOptionsScreen.OptionKeys = {
	"Auto swap to enemy",
	"Hide stats until summary shown",  -- Text referenced in initialize()
	"Show physical special icons",
	"Show move effectiveness",
	"Calculate variable damage",
	"Count enemy PP usage",
	"Show last damage calcs",
	"Reveal info if randomized",
}

GameOptionsScreen.Buttons = {
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
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
		button.textColor = GameOptionsScreen.textColor
		button.boxColors = { GameOptionsScreen.borderColor, GameOptionsScreen.boxFillColor }
	end
end

-- USER INPUT FUNCTIONS
function GameOptionsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, GameOptionsScreen.Buttons)
end

-- DRAWING FUNCTIONS
function GameOptionsScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[GameOptionsScreen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[GameOptionsScreen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 29, Constants.SCREEN.MARGIN - 2, GameOptionsScreen.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[GameOptionsScreen.borderColor], Theme.COLORS[GameOptionsScreen.boxFillColor])

	-- Draw all buttons
	for _, button in pairs(GameOptionsScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
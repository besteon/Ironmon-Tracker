GameOptionsScreen = {
	headerText = "Gameplay Options",
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

GameOptionsScreen.OptionKeys = {
	"Auto swap to enemy",
	"Show random ball picker",
	"Hide stats until summary shown",  -- Text referenced in initialize()
	"Show physical special icons",
	"Show move effectiveness",
	"Calculate variable damage",
	"Count enemy PP usage",
	"Show last damage calcs",
	"Reveal info if randomized",
}

GameOptionsScreen.Buttons = {
	EstimateIVs = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "  Estimate " .. Constants.Words.POKEMON .. "'s Potential",
		ivText = "",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 114, 130, 11 },
		onClick = function() GameOptionsScreen.displayJudgeMessage() end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			GameOptionsScreen.Buttons.EstimateIVs.ivText = "" -- keep hidden
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
}

function GameOptionsScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
	local startY = Constants.SCREEN.MARGIN + 14

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
		startY = startY + Constants.SCREEN.LINESPACING
	end

	for _, button in pairs(GameOptionsScreen.Buttons) do
		button.textColor = GameOptionsScreen.textColor
		button.boxColors = { GameOptionsScreen.borderColor, GameOptionsScreen.boxFillColor }
	end
end

function GameOptionsScreen.displayJudgeMessage()
	local leadPokemon = Battle.getViewedPokemon(true)
	if leadPokemon ~= nil then
		-- https://bulbapedia.bulbagarden.net/wiki/Stats_judge
		local result
		local ivEstimate = Utils.estimateIVs(leadPokemon) * 186
		if ivEstimate >= 151 then
			result = "Outstanding!!!"
		elseif ivEstimate >= 121 and ivEstimate <= 150 then
			result = "Quite impressive!!"
		elseif ivEstimate >= 91 and ivEstimate <= 120 then
			result = "Above average!"
		else
			result = "Decent."
		end

		GameOptionsScreen.Buttons.EstimateIVs.ivText = PokemonData.Pokemon[leadPokemon.pokemonID].name .. " is: " .. result

		-- Joey's Rattata meme (saving for later)
		-- local topPercentile = math.max(100 - 100 * Utils.estimateIVs(leadPokemon), 1)
		-- local percentText = string.format("%g", string.format("%d", topPercentile)) .. "%" -- %g removes insignificant 0's
		-- message = "In the top " .. percentText .. " of  " .. PokemonData.Pokemon[leadPokemon.pokemonID].name
	else
		GameOptionsScreen.Buttons.EstimateIVs.ivText = "Estimate is unavailable."
	end
	Program.redraw(true)
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

	local ivEstimate = GameOptionsScreen.Buttons.EstimateIVs
	Drawing.drawText(topboxX + 4, ivEstimate.box[2] + ivEstimate.box[4] + 1, ivEstimate.ivText, Theme.COLORS[ivEstimate.textColor], shadowcolor)
end
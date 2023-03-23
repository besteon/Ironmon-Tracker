ExtrasScreen = {
	Labels = {
		header = "Tracker Extras",
		timeMachineBtn = "Time Machine",
		estimateIvBtn = " Estimate " .. Constants.Words.POKEMON .. " IV Potential",
		resultIs = "is",
		resultOutstanding = "Outstanding!!!",
		resultQuiteImpressive = "Quite impressive!!",
		resultAboveAverage = "Above average!",
		resultDecent = "Decent.",
		resultUnavailable = "Estimate is unavailable.",
		viewLogFile = "View log",
		viewPreviousLogFile = "Previous log",
	},
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

ExtrasScreen.OptionKeys = {
	"Show random ball picker",
	"Display repel usage",
	"Display pedometer",
	"Animated Pokemon popout", -- Text referenced in initialize()
}
-- Holds all the buttons for the screen
-- Buttons are created in CreateButtons()
ExtrasScreen.Buttons = {
	ViewLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		text = ExtrasScreen.Labels.viewLogFile,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 15, 55, 16 },
		onClick = function(self)
			Program.changeScreenView(ViewLogWarningScreen)
		end,
	},
	ViewPreviousLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		text = ExtrasScreen.Labels.viewPreviousLogFile,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 65, Constants.SCREEN.MARGIN + 15, 70, 16 },
		onClick = function(self)
			LogOverlay.viewLogFile(FileManager.PostFixes.PREVIOUSATTEMPT)
		end
	},
	TimeMachine = {
		type = Constants.ButtonTypes.ICON_BORDER,
		text = ExtrasScreen.Labels.timeMachineBtn,
		image = Constants.PixelImages.CLOCK,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 30, Constants.SCREEN.MARGIN + 88, 78, 16 },
		onClick = function()
			TimeMachineScreen.buildOutPagedButtons()
			Program.changeScreenView(TimeMachineScreen)
		end
	},
	EstimateIVs = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = ExtrasScreen.Labels.estimateIvBtn,
		ivText = "",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 109, 130, 11 },
		onClick = function() ExtrasScreen.displayJudgeMessage() end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			ExtrasScreen.Buttons.EstimateIVs.ivText = "" -- keep hidden
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(NavigationMenu)
		end
	},
}

-- Creates the log view buttons
-- Buttons are stored in ExtrasScreen.Buttons
function ExtrasScreen.alignViewLogButtons()
	-- CURRENTLY UNUSED
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)

	local magnifyingGlassSize = #Constants.PixelImages.MAGNIFYING_GLASS[1]
	local logViewButtonsWidth = Constants.SCREEN.MARGIN * 2 + magnifyingGlassSize +
		math.max(math.floor((16 - magnifyingGlassSize) / 2), 0) + 1

	-- Center the two buttons within the top box
	local viewLogButtonBox = {
		0,
		0,
		Utils.calcWordPixelLength(ExtrasScreen.Labels.viewLogFile) + logViewButtonsWidth,
		Constants.SCREEN.LINESPACING + 5
	}
	local viewPrevLogButtonBox = {
		0,
		0,
		Utils.calcWordPixelLength(ExtrasScreen.Labels.viewPreviousLogFile) + logViewButtonsWidth,
		Constants.SCREEN.LINESPACING + 5
	}

	local totalViewLogButtonsWidth = viewLogButtonBox[3] + viewPrevLogButtonBox[3] + Constants.SCREEN.MARGIN
	viewLogButtonBox[1] = topboxX + (topboxWidth - totalViewLogButtonsWidth) / 2
	viewLogButtonBox[2] = topboxY + Constants.SCREEN.MARGIN + 1
	viewPrevLogButtonBox[1] = viewLogButtonBox[1] + viewLogButtonBox[3] + Constants.SCREEN.MARGIN
	viewPrevLogButtonBox[2] = viewLogButtonBox[2]

	ExtrasScreen.Buttons.ViewLogFile.box = viewLogButtonBox
	ExtrasScreen.Buttons.ViewPreviousLogFile.box = viewPrevLogButtonBox
end

function ExtrasScreen.initialize()
	-- ExtrasScreen.alignViewLogButtons()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5
	local startY = ExtrasScreen.Buttons.ViewLogFile.box[2] + ExtrasScreen.Buttons.ViewLogFile.box[4] + Constants.SCREEN.MARGIN + 2
	local linespacing = Constants.SCREEN.LINESPACING + 1

	for _, optionKey in ipairs(ExtrasScreen.OptionKeys) do
		ExtrasScreen.Buttons[optionKey] = {
			type = Constants.ButtonTypes.CHECKBOX,
			text = optionKey,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionKey],
			toggleColor = "Positive text",
			onClick = function(self)
				-- Toggle the setting and store the change to be saved later in Settings.ini
				self.toggleState = not self.toggleState
				Options.updateSetting(self.text, self.toggleState)

				-- If Animated Pokemon popout is turned on, create the popup form, or destroy it.
				if self.text == "Animated Pokemon popout" then
					if self.toggleState then
						Drawing.AnimatedPokemon:create()
					else
						Drawing.AnimatedPokemon:destroy()
					end
				end
			end
		}
		startY = startY + linespacing
	end

	for _, button in pairs(ExtrasScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = ExtrasScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { ExtrasScreen.Colors.border, ExtrasScreen.Colors.boxFill }
		end
	end

	local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
	local animatedBtnOption = ExtrasScreen.Buttons["Animated Pokemon popout"]
	if not FileManager.fileExists(abraGif) and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

function ExtrasScreen.displayJudgeMessage()
	local leadPokemon = Battle.getViewedPokemon(true)
	if leadPokemon ~= nil and PokemonData.isValid(leadPokemon.pokemonID) then
		-- Source: https://bulbapedia.bulbagarden.net/wiki/Stats_judge
		local result
		local ivEstimate = Utils.estimateIVs(leadPokemon) * 186
		if ivEstimate >= 151 then
			result = ExtrasScreen.Labels.resultOutstanding
		elseif ivEstimate >= 121 and ivEstimate <= 150 then
			result = ExtrasScreen.Labels.resultQuiteImpressive
		elseif ivEstimate >= 91 and ivEstimate <= 120 then
			result = ExtrasScreen.Labels.resultAboveAverage
		else
			result = ExtrasScreen.Labels.resultDecent
		end

		local pokemonName = PokemonData.Pokemon[leadPokemon.pokemonID].name
		ExtrasScreen.Buttons.EstimateIVs.ivText = string.format("%s %s: %s", pokemonName, ExtrasScreen.Labels.resultIs, result)

		-- Joey's Rattata meme (saving for later)
		-- local topPercentile = math.max(100 - 100 * Utils.estimateIVs(leadPokemon), 1)
		-- local percentText = string.format("%g", string.format("%d", topPercentile)) .. "%" -- %g removes insignificant 0's
		-- message = "In the top " .. percentText .. " of  " .. PokemonData.Pokemon[leadPokemon.pokemonID].name
	else
		ExtrasScreen.Buttons.EstimateIVs.ivText = ExtrasScreen.Labels.resultUnavailable
	end
	Program.redraw(true)
end

-- USER INPUT FUNCTIONS
function ExtrasScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, ExtrasScreen.Buttons)
end

-- DRAWING FUNCTIONS
function ExtrasScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[ExtrasScreen.Colors.boxFill])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[ExtrasScreen.Colors.boxFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 33, Constants.SCREEN.MARGIN - 2, ExtrasScreen.Labels.header:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[ExtrasScreen.Colors.border], Theme.COLORS[ExtrasScreen.Colors.boxFill])

	-- Draw all buttons
	for _, button in pairs(ExtrasScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	local ivBtn = ExtrasScreen.Buttons.EstimateIVs
	Drawing.drawText(topboxX + 4, ivBtn.box[2] + ivBtn.box[4] + 1, ivBtn.ivText, Theme.COLORS[ivBtn.textColor],
		shadowcolor)
end


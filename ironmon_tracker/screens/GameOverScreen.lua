GameOverScreen = {
	Labels = {
		headerTop = Constants.BLANKLINE .. "  G a m e O v e r  " .. Constants.BLANKLINE,
		attemptNumber = "Attempt:",
		trainersDefeated = "Trainers defeated:",
		continuePlaying = "     " .. "Continue Playing",
		saveGameFiles = "        " .. "Save this Run",
		saveSuccessful = "Saved in Tracker folder!",
		viewLogFile = " View the Log",
		openLogFile = " Open a Log",
	},
}

GameOverScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 105, Constants.SCREEN.MARGIN + 10, 31, 29 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 105, Constants.SCREEN.MARGIN + 6, 32, 32 },
		teamIndex = 1,
		getIconPath = function(self)
			local pokemon = Tracker.getPokemon(self.teamIndex or 1, true) or Tracker.getDefaultPokemon()
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			local imagepath = FileManager.buildImagePath(iconset.folder, tostring(pokemon.pokemonID), iconset.extension)
			return imagepath
		end,
		onClick = function(self)
			GameOverScreen.nextTeamPokemon(self.teamIndex)
			Program.redraw(true)
		end,
	},
	ContinuePlaying = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = GameOverScreen.Labels.continuePlaying,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 22, Constants.SCREEN.MARGIN + 90, 95, 12 },
		onClick = function(self)
			GameOverScreen.Buttons.SaveGameFiles:resetText()
			Program.changeScreenView(Program.Screens.TRACKER)
		end,
	},
	SaveGameFiles = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = GameOverScreen.Labels.saveGameFiles,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 22, Constants.SCREEN.MARGIN + 110, 95, 12 },
		resetText = function(self)
			self.text = GameOverScreen.Labels.saveGameFiles
			self.textColor = "Lower box text"
		end,
		onClick = function(self)
			if self.text == GameOverScreen.Labels.saveGameFiles then
				self.text = GameOverScreen.Labels.saveSuccessful
				self.textColor = "Positive text"
				GameOverScreen.saveCurrentGameFiles()
				Program.redraw(true)
			end
		end,
	},
	ViewLogFile = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = GameOverScreen.Labels.viewLogFile,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 130, 57, 12 },
		isVisible = function(self) return true end,
		onClick = function(self) GameOverScreen.viewLogFilePrompt() end,
	},
	OpenLogFile = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = GameOverScreen.Labels.openLogFile,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 78, Constants.SCREEN.MARGIN + 130, 52, 12 },
		onClick = function(self) GameOverScreen.openLogFilePrompt() end,
	},
}

function GameOverScreen.initialize()
	GameOverScreen.isDisplayed = false -- Prevents repeated changing screens due to BattleOutcome persisting
	GameOverScreen.trainerBattlesLost = 0 -- Total battles counts wins & losses, use this to show wins only

	for _, button in pairs(GameOverScreen.Buttons) do
		button.textColor = "Lower box text"
		button.boxColors = { "Lower box border", "Lower box background" }
	end
end

-- Returns true if the conditions are correct to display the screen
function GameOverScreen.shouldDisplay(battleOutcome)
	if battleOutcome ~= 2 then -- Didn't lose the Battle
		if GameOverScreen.isDisplayed then
			GameOverScreen.isDisplayed = false -- Clears it out for when playing chooses to continue playing
		end
		return false
	end
	return not GameOverScreen.isDisplayed
end

function GameOverScreen.incrementLosses()
	GameOverScreen.trainerBattlesLost = (GameOverScreen.trainerBattlesLost or 0) + 1
end

function GameOverScreen.nextTeamPokemon(startingIndex)
	if type(startingIndex) ~= "number" or startingIndex < 1 or startingIndex > 6 then
		GameOverScreen.Buttons.PokemonIcon.teamIndex = 1
		return
	end

	-- Search through the player's pokemon team for the next one in order (unsure if skips eggs)
	local nextIndex = (startingIndex % 6) + 1
	local pokemon = Tracker.getPokemon(nextIndex, true)
	while pokemon == nil and nextIndex ~= startingIndex do
		nextIndex = (nextIndex % 6) + 1
		pokemon = Tracker.getPokemon(nextIndex, true)
	end
	GameOverScreen.Buttons.PokemonIcon.teamIndex = nextIndex
end

-- Saves the currently loaded ROM, it's log file (if any), and the TDAT file to the Tracker's 'saved_games' folder
function GameOverScreen.saveCurrentGameFiles()

end

-- Attempts to open the current game's log file (if any). Unsure if this will always be discoverable, hence openLogFile function
function GameOverScreen.viewLogFilePrompt()

end

-- Prompts user to select a log file to parse, then displays the parsed data on a new left-screen
function GameOverScreen.openLogFilePrompt()
	local suggestedFileName = (GameSettings.getRomName() or "") .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local filterOptions = "Randomizer Log (*.log)|*.log|All files (*.*)|*.*"

	local workingDir = FileManager.dir
	if workingDir ~= "" then
		workingDir = workingDir:sub(1, -2) -- remove trailing slash
	end

	local wasSoundOn = client.GetSoundOn()
	client.SetSoundOn(false)
	local filepath = forms.openfile(suggestedFileName, workingDir, filterOptions)
	if filepath ~= nil and filepath ~= "" then
		-- TODO: parse and show on game screen
		RandomizerLog.parseLog(filepath)
	end
	if client.GetSoundOn() ~= wasSoundOn then
		client.SetSoundOn(wasSoundOn)
	end
end

-- DRAWING FUNCTIONS
function GameOverScreen.drawScreen()
	if not GameOverScreen.isDisplayed then
		GameOverScreen.isDisplayed = true
	end

	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = 77,
		text = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height + 5,
		width = topBox.width,
		height = Constants.SCREEN.HEIGHT - topBox.height - 15,
		text = Theme.COLORS["Lower box text"],
		border = Theme.COLORS["Lower box border"],
		fill = Theme.COLORS["Lower box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"]),
	}
	-- local topcolX = topBox.x + 55
	local textLineY = topBox.y + 2
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	Drawing.drawText(topBox.x + 29, textLineY, GameOverScreen.Labels.headerTop:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing + 1

	-- Draw some game stats
	local topcolX = 80
	local attemptNumber = Main.currentSeed or 1
	Drawing.drawText(topBox.x + 3, textLineY, GameOverScreen.Labels.attemptNumber, topBox.text, topBox.shadow)
	Drawing.drawText(topBox.x + topcolX, textLineY, Utils.formatNumberWithCommas(attemptNumber), topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	local trainersDefeated = Utils.getGameStat(Constants.GAME_STATS.TRAINER_BATTLES) or 0
	trainersDefeated = trainersDefeated - (GameOverScreen.trainerBattlesLost or 0) -- Decreased by trainer battles lost
	Drawing.drawText(topBox.x + 3, textLineY, GameOverScreen.Labels.trainersDefeated, topBox.text, topBox.shadow)
	Drawing.drawText(topBox.x + topcolX, textLineY, Utils.formatNumberWithCommas(trainersDefeated), topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	-- Draw the Team Pokemon's stats and bst
	textLineY = textLineY + 15
	local pokemonOnTeam = Tracker.getPokemon(GameOverScreen.Buttons.PokemonIcon.teamIndex or 1, true) or Tracker.getDefaultPokemon()
	if pokemonOnTeam ~= nil then
		local statColSpacing = 19
		local statLineX = topBox.x + 5
		for _, statLabel in ipairs(Constants.OrderedLists.STATSTAGES) do
			local offsetX = 0
			if Options["Right justified numbers"] then
				offsetX = 15 - statLabel:len() * 5
			end
			Drawing.drawText(statLineX + offsetX, textLineY, statLabel:upper(), topBox.text, topBox.shadow)
			Drawing.drawNumber(statLineX, textLineY + 10, pokemonOnTeam.stats[statLabel], 3, topBox.text, topBox.shadow)
			statLineX = statLineX + statColSpacing
		end
		Drawing.drawText(statLineX, textLineY, "BST", topBox.text, topBox.shadow)
		Drawing.drawNumber(statLineX, textLineY + 10, PokemonData.Pokemon[pokemonOnTeam.pokemonID].bst, 3, topBox.text, topBox.shadow)
	end

	-- Draw bottom border box
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)

	-- Draw all buttons
	for _, button in pairs(GameOverScreen.Buttons) do
		Drawing.drawButton(button, botBox.shadow)
	end
end
GameOverScreen = {
	Labels = {
		headerTop = "G a m e O v e r",
		announcer = "Announcer:",
		attemptNumber = "Attempt",
		trainersDefeated = "Trainers defeated:",
		continuePlaying = "Continue playing",
		retryBattle = "Retry the battle",
		restartBattleConfirm = "Are you sure?",
		saveGameFiles = "Save this attempt",
		saveSuccessful = "Saved in: saved- games",
		saveFailed = "Unable to save",
		viewLogFile = "Inspect the log",
		openLogFile = "Open a log file",
		winningQuote = "CONGRATULATIONS!!"
	},
	AnnouncerQuotes = {
		"What's the matter trainer?",
		"What will the trainer do now?",
		"Oh! Another failure!",
		"Boom!",
		"Devastating!",
		"Gone! It didn't stand a chance!",
		-- "There's a distinct difference in the number of remaining " .. Constants.Words.POKEMON .. ".", -- too long
		"Can strategy overcome the level disadvantage?",
		"It's in no condition to fight!",
		"This is a battle between obviously mismatched " .. Constants.Words.POKEMON .. ".",
		"The " .. Constants.Words.POKEMON .. " returns to its " .. Constants.Words.POKE .. " Ball.",
		"Down! That didn't take much!",
		"That one hurt!",
		"And there goes the battle!",
		"What a wild turn of events!",
		"Taken down on the word go!",
		"Woah! That was overpowering!",
		"It's finally taken down!",
		"Harsh blow!",
		"That was brutal!",
		"Nailed the weak spot!",
		"Hey! What's it doing? Down it goes!",
	},
	chosenQuoteIndex = 1,
}

GameOverScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 106, 6, 31, 29 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 106, 2, 32, 32 },
		teamIndex = 1,
		getIconPath = function(self)
			local pokemon = Tracker.getPokemon(self.teamIndex or 1, true) or Tracker.getDefaultPokemon()
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(pokemon.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			GameOverScreen.nextTeamPokemon(self.teamIndex)
			-- GameOverScreen.chosenQuoteIndex = GameOverScreen.chosenQuoteIndex % #GameOverScreen.AnnouncerQuotes + 1 -- Optionally, cycle in order
			GameOverScreen.randomizeAnnouncerQuote()
			Program.redraw(true)
		end,
	},
	ContinuePlaying = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.RIGHT_ARROW,
		text = GameOverScreen.Labels.continuePlaying,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 66, 112, 16 },
		onClick = function(self)
			-- Clear out this flag if player continues playing
			if Battle.defeatedSteven then
				Battle.defeatedSteven = false
			end
			LogOverlay.isDisplayed = false
			GameOverScreen.refreshButtons()
			Program.changeScreenView(Program.Screens.TRACKER)
		end,
	},
	RetryBattle = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SWORD_ATTACK,
		text = GameOverScreen.Labels.retryBattle,
		confirmAction = false,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 87, 112, 16 },
		isVisible = function(self) return Main.IsOnBizhawk() and GameOverScreen.battleStartSaveState ~= nil and not Battle.defeatedSteven end,
		updateText = function(self)
			self.text = GameOverScreen.Labels.retryBattle
			self.textColor = "Lower box text"
			self.confirmAction = false
		end,
		onClick = function(self)
			if not self.confirmAction then
				self.text = GameOverScreen.Labels.restartBattleConfirm
				self.textColor = "Negative text"
				self.confirmAction = true
				Program.redraw(true)
			else
				GameOverScreen.trainerBattlesLost = GameOverScreen.trainerBattlesLost - 1
				LogOverlay.isDisplayed = false
				GameOverScreen.refreshButtons()
				Program.changeScreenView(Program.Screens.TRACKER)
				GameOverScreen.loadTempSaveState()
			end
		end,
	},
	SaveGameFiles = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		text = GameOverScreen.Labels.saveGameFiles,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 108, 112, 16 },
		-- Only visible if the player is using the Tracker's Quickload feature
		isVisible = function(self) return Options["Use premade ROMs"] or Options["Generate ROM each time"] end,
		updateText = function(self)
			self.text = GameOverScreen.Labels.saveGameFiles
			self.textColor = "Lower box text"
		end,
		onClick = function(self)
			if self.text == GameOverScreen.Labels.saveGameFiles then
				if GameOverScreen.saveCurrentGameFiles() then
					self.text = GameOverScreen.Labels.saveSuccessful
					self.textColor = "Positive text"
				else
					self.text = GameOverScreen.Labels.saveFailed
					self.textColor = "Negative text"
				end
				Program.redraw(true)
			end
		end,
	},
	ViewLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		text = GameOverScreen.Labels.viewLogFile,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 129, 112, 16 },
		isVisible = function(self) return true end,
		updateText = function(self)
			if Options["Use premade ROMs"] or Options["Generate ROM each time"] then
				self.text = GameOverScreen.Labels.viewLogFile
			else
				self.text = GameOverScreen.Labels.openLogFile
			end
		end,
		onClick = function(self)
			local wasSoundOn
			if Main.IsOnBizhawk() then
				-- Disable Bizhawk sound while the update is in process
				wasSoundOn = client.GetSoundOn()
				client.SetSoundOn(false)
			end

			if not GameOverScreen.viewLogFile() then
				-- If the log file was already parsed, re-use that
				if RandomizerLog.Data.Settings ~= nil then
					LogOverlay.parseAndDisplay()
				else
					GameOverScreen.openLogFilePrompt()
				end
			end

			if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
				client.SetSoundOn(wasSoundOn)
			end
		end,
	},
}

function GameOverScreen.initialize()
	GameOverScreen.isDisplayed = false -- Prevents repeated changing screens due to BattleOutcome persisting
	GameOverScreen.trainerBattlesLost = 0 -- Total battles counts wins & losses, use this to show wins only
	GameOverScreen.battleStartSaveState = nil -- Creates a temporary save state in memory, for restarting a battle

	for _, button in pairs(GameOverScreen.Buttons) do
		button.textColor = "Lower box text"
		button.boxColors = { "Lower box border", "Lower box background" }
	end
	GameOverScreen.refreshButtons()
end

function GameOverScreen.randomizeAnnouncerQuote()
	local currentQuoteIndex = GameOverScreen.chosenQuoteIndex
	local totalQuotes = #GameOverScreen.AnnouncerQuotes
	local retries = 0
	while GameOverScreen.chosenQuoteIndex == currentQuoteIndex and retries < 50 do
		GameOverScreen.chosenQuoteIndex = math.random(totalQuotes)
		retries = retries + 1
	end
	return GameOverScreen.AnnouncerQuotes[GameOverScreen.chosenQuoteIndex]
end

function GameOverScreen.refreshButtons()
	for _, button in pairs(GameOverScreen.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

-- Returns true if the conditions are correct to display the screen
function GameOverScreen.shouldDisplay(battleOutcome)
	if battleOutcome ~= 2 and battleOutcome ~= 3 then -- Didn't lose or tie the Battle
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

function GameOverScreen.createTempSaveState()
	if not Main.IsOnBizhawk() then return end

	GameOverScreen.clearTempSaveStates()

	---@diagnostic disable-next-line: undefined-global
	GameOverScreen.battleStartSaveState = memorysavestate.savecorestate()
end

function GameOverScreen.loadTempSaveState()
	if not Main.IsOnBizhawk() or GameOverScreen.battleStartSaveState == nil then return end

	---@diagnostic disable-next-line: undefined-global
	memorysavestate.loadcorestate(GameOverScreen.battleStartSaveState)

	GameOverScreen.clearTempSaveStates()
	Battle.resetBattle()
end

function GameOverScreen.clearTempSaveStates()
	if not Main.IsOnBizhawk() or GameOverScreen.battleStartSaveState == nil then return end

	---@diagnostic disable-next-line: undefined-global
	memorysavestate.removestate(GameOverScreen.battleStartSaveState)
	GameOverScreen.battleStartSaveState = nil
end

-- Saves the currently loaded ROM, it's log file (if any), and the TDAT file to the Tracker's 'saved_games' folder
function GameOverScreen.saveCurrentGameFiles()
	local savePathDir = FileManager.prependDir(FileManager.Folders.SavedGames .. FileManager.slash)

	local romname, rompath, romnameToSave
	if Options["Use premade ROMs"] and Options.FILES["ROMs Folder"] ~= nil then
		-- First make sure the ROMs Folder ends with a slash
		if Options.FILES["ROMs Folder"]:sub(-1) ~= FileManager.slash then
			Options.FILES["ROMs Folder"] = Options.FILES["ROMs Folder"] .. FileManager.slash
		end

		romname = GameSettings.getRomName() or ""
		rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(rompath) then
			-- File doesn't exist, try again with underscores instead of spaces (awkward Bizhawk issue)
			romname = romname:gsub(" ", "_")
			rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		end
		romnameToSave = romname
	elseif Options["Generate ROM each time"] then
		-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
		local quickloadFiles = Main.GetQuickloadFiles()
		local settingsFileName = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1] or "")

		romname = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
		rompath = FileManager.prependDir(romname)
		romnameToSave = string.format("%s %s", (Main.currentSeed or 1), romname)
	end

	if romname == nil or rompath == nil or romnameToSave == nil then
		print("> ERROR: Unable to find the game ROM currently loaded.")
		return false
	end

	FileManager.createFolder(FileManager.prependDir(FileManager.Folders.SavedGames))

	local rompathToSave = savePathDir .. romnameToSave .. FileManager.Extensions.GBA_ROM
	-- Don't replace existing save games, instead make a new one based on current time
	if FileManager.fileExists(rompathToSave) then
		romnameToSave = string.format("%s %s", os.time(), romname)
		rompathToSave = savePathDir .. romnameToSave .. FileManager.Extensions.GBA_ROM
	end
	if not FileManager.CopyFile(rompath, rompathToSave, "overwrite") then
		print("> ERROR: Unable to save a copy of your game's ROM file.")
		print(rompath or romname or "Unknown ROM")
		return false
	end

	local logname = romname .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local logpath = rompath .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local lognameToSave = romnameToSave .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local logpathToSave = savePathDir .. lognameToSave
	if not FileManager.CopyFile(logpath, logpathToSave, "overwrite") then
		print("> ERROR: Unable to save a copy of your game's log file.")
		print(logpath or logname or "Unknown LOG")
		return false
	end

	if Options["Auto save tracked game data"] then
		local tdatname = GameSettings.getTrackerAutoSaveName()
		local tdatpath = FileManager.prependDir(tdatname)
		local tdatnameToSave = romnameToSave .. FileManager.Extensions.TRACKED_DATA
		local tdatpathToSave = savePathDir .. tdatnameToSave
		if not FileManager.CopyFile(tdatpath, tdatpathToSave, "overwrite") then
			print("> ERROR: Unable to save a copy of your game's tracked data file.")
			print(tdatpath or tdatname or "Unknown TDAT")
			return false
		end
	end

	local savestatePath = savePathDir .. romnameToSave .. FileManager.Extensions.SAVESTATE
	---@diagnostic disable-next-line: undefined-global
	savestate.save(savestatePath)

	return true
end

--Attempts to get the Randomizer log filepath based on the currently loaded ROM's filepath (usually both in same folder)
function GameOverScreen.viewLogFile()
	local romname, rompath
	if Options["Use premade ROMs"] and Options.FILES["ROMs Folder"] ~= nil then
		-- First make sure the ROMs Folder ends with a slash
		if Options.FILES["ROMs Folder"]:sub(-1) ~= FileManager.slash then
			Options.FILES["ROMs Folder"] = Options.FILES["ROMs Folder"] .. FileManager.slash
		end

		romname = GameSettings.getRomName() or ""
		rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(rompath) then
			romname = romname:gsub(" ", "_")
			rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		end
	elseif Options["Generate ROM each time"] then
		-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
		local quickloadFiles = Main.GetQuickloadFiles()
		local settingsFileName = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1] or "")
		romname = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
		rompath = FileManager.prependDir(romname)
	end

	local logpath = FileManager.getPathIfExists((rompath or "") .. FileManager.Extensions.RANDOMIZER_LOGFILE)
	if logpath == nil then
		return false
	end

	return LogOverlay.parseAndDisplay(logpath)
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
		LogOverlay.parseAndDisplay(filepath)
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
		height = 56,
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
	local textLineY = topBox.y + 2

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	Drawing.drawText(topBox.x + 2, textLineY, GameOverScreen.Labels.headerTop:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw some game stats
	local attemptNumber = Main.currentSeed or 1
	if attemptNumber ~= 1 then
		local attemptsText = string.format("%s:  %s", GameOverScreen.Labels.attemptNumber, Utils.formatNumberWithCommas(attemptNumber))
		-- local centerOffsetX = math.floor(topBox.width / 2 - Utils.calcWordPixelLength(attemptsText) / 2) - 1
		Drawing.drawText(topBox.x + 2, textLineY, attemptsText, topBox.text, topBox.shadow)
	end
	textLineY = textLineY + Constants.SCREEN.LINESPACING
	textLineY = textLineY + Constants.SCREEN.LINESPACING - 1

	local inHallOfFame = Battle.CurrentRoute.mapId ~= nil and RouteData.Locations.IsInHallOfFame[Battle.CurrentRoute.mapId]

	-- Draw the game winning message or a random Pokémon Stadium announcer quote
	if inHallOfFame or Battle.defeatedSteven then
		local wrappedQuotes = Utils.getWordWrapLines(GameOverScreen.Labels.winningQuote, 30)
		local firstTwoLines = { wrappedQuotes[1], wrappedQuotes[2] }
		textLineY = textLineY + 5 * (2 - #firstTwoLines)
		for _, line in pairs(firstTwoLines) do
			local centerOffsetX = math.floor(topBox.width / 2 - Utils.calcWordPixelLength(line) / 2) - 1
			Drawing.drawText(topBox.x + centerOffsetX, textLineY, line, topBox.text, topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
	else
		-- Drawing.drawText(topBox.x + 2, textLineY, GameOverScreen.Labels.announcer, topBox.text, topBox.shadow)
		local announcerQuote = GameOverScreen.AnnouncerQuotes[GameOverScreen.chosenQuoteIndex]
		local wrappedQuotes = Utils.getWordWrapLines(announcerQuote, 30)
		local firstTwoLines = { wrappedQuotes[1], wrappedQuotes[2] }
		textLineY = textLineY + 5 * (2 - #firstTwoLines)
		for _, line in pairs(firstTwoLines) do
			local centerOffsetX = math.floor(topBox.width / 2 - Utils.calcWordPixelLength(line) / 2) - 1
			Drawing.drawText(topBox.x + centerOffsetX, textLineY, line, topBox.text, topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
	end

	-- TODO: Might add back in later

	-- local trainersDefeated = Utils.getGameStat(Constants.GAME_STATS.TRAINER_BATTLES) or 0
	-- trainersDefeated = trainersDefeated - (GameOverScreen.trainerBattlesLost or 0) -- Decreased by trainer battles lost
	-- Drawing.drawText(topBox.x + 3, textLineY, GameOverScreen.Labels.trainersDefeated, topBox.text, topBox.shadow)
	-- Drawing.drawText(topBox.x + topcolX, textLineY, Utils.formatNumberWithCommas(trainersDefeated), topBox.text, topBox.shadow)
	-- textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw the Team Pokemon's stats and bst
	-- textLineY = textLineY + 2
	-- local pokemonOnTeam = Tracker.getPokemon(GameOverScreen.Buttons.PokemonIcon.teamIndex or 1, true) or Tracker.getDefaultPokemon()
	-- if pokemonOnTeam ~= nil then
	-- 	local statColSpacing = 19
	-- 	local statLineX = topBox.x + 28
	-- 	for _, statLabel in ipairs(Constants.OrderedLists.STATSTAGES) do
	-- 		local offsetX = 0
	-- 		if Options["Right justified numbers"] then
	-- 			offsetX = 15 - statLabel:len() * 5
	-- 		end
	-- 		Drawing.drawText(statLineX + offsetX, textLineY, statLabel:upper(), topBox.text, topBox.shadow)
	-- 		Drawing.drawNumber(statLineX, textLineY + 10, pokemonOnTeam.stats[statLabel], 3, topBox.text, topBox.shadow)
	-- 		statLineX = statLineX + statColSpacing
	-- 	end
	-- 	-- Drawing.drawText(statLineX, textLineY, "BST", topBox.text, topBox.shadow)
	-- 	-- Drawing.drawNumber(statLineX, textLineY + 10, PokemonData.Pokemon[pokemonOnTeam.pokemonID].bst, 3, topBox.text, topBox.shadow)
	-- end

	-- Draw bottom border box
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)

	-- Draw all buttons
	for _, button in pairs(GameOverScreen.Buttons) do
		Drawing.drawButton(button, botBox.shadow)
	end
end
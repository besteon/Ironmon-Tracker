GameOverScreen = {
	Statuses = {
		STILL_PLAYING = 1,
		LOST = 2,
		WON = 3,
	},
	isDisplayed = false, -- Prevents repeated changing screens due to BattleOutcome persisting
	chosenQuoteIndex = 1,
	enteredFromSpecialLocation = false, -- prevents constantly changing back to game over screen
	status = nil,
}

GameOverScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 106, 6, 31, 29 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 106, 2, 32, 32 },
		teamIndex = 1,
		getIconId = function(self)
			local pokemon = Tracker.getPokemon(self.teamIndex or 1, true) or Tracker.getDefaultPokemon()
			local animType = GameOverScreen.status == GameOverScreen.Statuses.WON and SpriteData.Types.Idle or SpriteData.Types.Faint
			-- Safety check to make sure this icon has the requested sprite animation type
			if SpriteData.canDrawPokemonIcon(pokemon.pokemonID) and not SpriteData.IconData[pokemon.pokemonID][animType] then
				animType = SpriteData.getNextAnimType(pokemon.pokemonID, animType)
			end
			return pokemon.pokemonID, animType
		end,
		onClick = function(self)
			GameOverScreen.nextTeamPokemon(self.teamIndex)
			GameOverScreen.randomizeAnnouncerQuote()
			Program.redraw(true)
		end,
	},
	ContinuePlaying = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.RIGHT_ARROW,
		getText = function(self) return Resources.GameOverScreen.ButtonContinuePlaying end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 66, 112, 16 },
		onClick = function(self)
			GameOverScreen.status = GameOverScreen.Statuses.STILL_PLAYING
			LogOverlay.isGameOver = false
			LogOverlay.isDisplayed = false
			Program.GameTimer:unpause()
			GameOverScreen.refreshButtons()
			GameOverScreen.Buttons.SaveGameFiles:reset()
			Program.changeScreenView(TrackerScreen)
		end,
	},
	RetryBattle = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SWORD_ATTACK,
		getText = function(self)
			if self.confirmAction then
				return Resources.GameOverScreen.ButtonRetryBattleConfirm
			else
				return Resources.GameOverScreen.ButtonRetryBattle
			end
		end,
		confirmAction = false,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 87, 112, 16 },
		isVisible = function(self) return Main.IsOnBizhawk() and GameOverScreen.battleStartSaveState ~= nil and GameOverScreen.status ~= GameOverScreen.Statuses.WON end,
		updateSelf = function(self)
			self.textColor = "Lower box text"
			self.confirmAction = false
		end,
		onClick = function(self)
			if not self.confirmAction then
				self.textColor = "Negative text"
				self.confirmAction = true
				Program.redraw(true)
			else
				GameOverScreen.status = GameOverScreen.Statuses.STILL_PLAYING
				LogOverlay.isDisplayed = false
				Program.GameTimer:unpause()
				GameOverScreen.refreshButtons()
				GameOverScreen.Buttons.SaveGameFiles:reset()
				Program.changeScreenView(TrackerScreen)
				GameOverScreen.loadTempSaveState()
			end
		end,
	},
	SaveGameFiles = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		getText = function(self)
			if self.clickedStatus == "Success" then
				return Resources.GameOverScreen.ButtonSaveSuccessful
			elseif self.clickedStatus == "Failed" then
				return Resources.GameOverScreen.ButtonSaveFailed
			else
				return Resources.GameOverScreen.ButtonSaveAttempt
			end
		end,
		clickedStatus = "Not Clicked", -- checked later when clicked
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 108, 112, 16 },
		-- Only visible if the player is using the Tracker's Quickload feature
		isVisible = function(self) return Options["Use premade ROMs"] or Options["Generate ROM each time"] end,
		reset = function(self)
			self.clickedStatus = "Not Clicked"
			self.textColor = "Lower box text"
		end,
		onClick = function(self)
			if self.clickedStatus ~= "Not Clicked" then return end

			if GameOverScreen.saveCurrentGameFiles() then
				self.clickedStatus = "Success"
				self.textColor = "Positive text"
			else
				self.clickedStatus = "Failed"
				self.textColor = "Negative text"
			end
			Program.redraw(true)
		end,
	},
	ViewLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self)
			if Options["Generate ROM each time"] or Options["Use premade ROMs"] then
				return Resources.GameOverScreen.ButtonInspectLogFile
			else
				return Resources.GameOverScreen.ButtonOpenLogFile
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 129, 112, 16 },
		isVisible = function(self) return true end,
		onClick = function(self)
			LogOverlay.viewLogFile(FileManager.PostFixes.AUTORANDOMIZED)
		end,
	},
}

function GameOverScreen.initialize()
	GameOverScreen.isDisplayed = false
	GameOverScreen.battleStartSaveState = nil -- Creates a temporary save state in memory, for restarting a battle
	GameOverScreen.enteredFromSpecialLocation = false
	GameOverScreen.status = GameOverScreen.Statuses.STILL_PLAYING

	for _, button in pairs(GameOverScreen.Buttons) do
		button.textColor = "Lower box text"
		button.boxColors = { "Lower box border", "Lower box background" }
	end
	GameOverScreen.refreshButtons()
	GameOverScreen.Buttons.SaveGameFiles:reset()
end

function GameOverScreen.refreshButtons()
	for _, button in pairs(GameOverScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function GameOverScreen.randomizeAnnouncerQuote()
	if not Resources.GameOverScreenQuotes or #Resources.GameOverScreenQuotes == 0 then
		return ""
	elseif #Resources.GameOverScreenQuotes == 1 then
		return Resources.GameOverScreenQuotes[1] or ""
	end

	local currentQuoteIndex = GameOverScreen.chosenQuoteIndex
	local totalQuotes = #Resources.GameOverScreenQuotes
	local retries = 50
	-- Attempt to randomly pick a different quote (dumb implementation but kind of works)
	while GameOverScreen.chosenQuoteIndex == currentQuoteIndex and retries > 0 do
		GameOverScreen.chosenQuoteIndex = math.random(totalQuotes)
		retries = retries - 1
	end
	return Resources.GameOverScreenQuotes[GameOverScreen.chosenQuoteIndex] or ""
end

---Returns true if a GameOver has occurred and the screen should be displayed (lost/tied, or won final battle)
---@param lastBattleStatus number?
---@param lastTrainerId number? The TrainerId of the most recent enemy trainer that was battled
---@return boolean isGameOver
function GameOverScreen.checkForGameOver(lastBattleStatus, lastTrainerId)
	if not Main.IsOnBizhawk() or LogOverlay.isGameOver or GameOverScreen.isDisplayed or Battle.recentBattleWasTutorial then
		return false
	end

	lastBattleStatus = lastBattleStatus or Memory.readbyte(GameSettings.gBattleOutcome)
	lastTrainerId = lastTrainerId or Memory.readword(GameSettings.gTrainerBattleOpponent_A)

	-- BattleStatus [2 = Lost the match, 3 = Tied]
	if lastBattleStatus == 2 or lastBattleStatus == 3 then
		GameOverScreen.status = GameOverScreen.Statuses.LOST
	elseif Battle.wonFinalBattle(lastBattleStatus, lastTrainerId) then
		GameOverScreen.status = GameOverScreen.Statuses.WON
	end

	return GameOverScreen.status ~= GameOverScreen.Statuses.STILL_PLAYING
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

	local savestatePath = savePathDir .. romnameToSave .. FileManager.Extensions.BIZHAWK_SAVESTATE
	---@diagnostic disable-next-line: undefined-global
	savestate.save(savestatePath)

	return true
end

-- USER INPUT FUNCTIONS
function GameOverScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, GameOverScreen.Buttons)
end

-- DRAWING FUNCTIONS
function GameOverScreen.drawScreen()
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

	-- Draw Pokemon Icon first, so text can overlap it
	Drawing.drawButton(GameOverScreen.Buttons.PokemonIcon, topBox.shadow)

	-- Draw header text
	Drawing.drawText(topBox.x + 2, textLineY, Utils.toUpperUTF8(Resources.GameOverScreen.Title), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw some game stats
	local columnOffsetX = 54
	if Main.currentSeed and Main.currentSeed ~= 1 then
		Drawing.drawText(topBox.x + 2, textLineY, Resources.GameOverScreen.LabelAttempt .. ":", topBox.text, topBox.shadow)
		Drawing.drawText(topBox.x + columnOffsetX, textLineY, Utils.formatNumberWithCommas(Main.currentSeed), topBox.text, topBox.shadow)
	end
	textLineY = textLineY + Constants.SCREEN.LINESPACING - 1

	if Tracker.Data.playtime and Tracker.Data.playtime > 0 then
		Drawing.drawText(topBox.x + 2, textLineY, Resources.GameOverScreen.LabelPlayTime .. ":", topBox.text, topBox.shadow)
		Drawing.drawText(topBox.x + columnOffsetX, textLineY, Program.GameTimer:getText(), topBox.text, topBox.shadow)
	end
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw the game winning message or a random Pokémon Stadium announcer quote
	if GameOverScreen.status == GameOverScreen.Statuses.WON then
		local wrappedQuotes = Utils.getWordWrapLines(Resources.GameOverScreen.QuoteCongratulations, 30)
		local firstTwoLines = { wrappedQuotes[1], wrappedQuotes[2] }
		textLineY = textLineY + 5 * (2 - #firstTwoLines)
		for _, line in pairs(firstTwoLines) do
			local centerOffsetX = math.floor(topBox.width / 2 - Utils.calcWordPixelLength(line) / 2) - 1
			Drawing.drawText(topBox.x + centerOffsetX, textLineY, line, topBox.text, topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
	else
		local announcerQuote = Resources.GameOverScreenQuotes[GameOverScreen.chosenQuoteIndex] or ""
		local wrappedQuotes = Utils.getWordWrapLines(announcerQuote, 30)
		local firstTwoLines = { wrappedQuotes[1], wrappedQuotes[2] }
		textLineY = textLineY + 5 * (2 - #firstTwoLines)
		for _, line in pairs(firstTwoLines) do
			local centerOffsetX = math.floor(topBox.width / 2 - Utils.calcWordPixelLength(line) / 2) - 1
			Drawing.drawText(topBox.x + centerOffsetX, textLineY, line, topBox.text, topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
	end

	-- Draw bottom border box
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)

	-- Draw all other buttons
	for _, button in pairs(GameOverScreen.Buttons) do
		if button ~= GameOverScreen.Buttons.PokemonIcon then
			Drawing.drawButton(button, botBox.shadow)
		end
	end
end
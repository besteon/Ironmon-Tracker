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

-- Different functions to confirm if the game has ended in a loss (game over)
GameOverScreen.LossConditions = {
	LeadPokemonFaints = function()
		local pokemon = TrackerAPI.getPlayerPokemon(1)
		return pokemon and pokemon.curHP == 0 and pokemon.isEgg ~= 1
	end,
	HighestLevelFaints = function()
		local highestLevel, highestFainted = 0, false
		for _, pokemon in ipairs(Program.GameData.PlayerTeam or {}) do
			if pokemon.isEgg ~= 1 then -- ignore eggs
				if pokemon.level > highestLevel then
					highestLevel = pokemon.level
					highestFainted = pokemon.curHP == 0
				elseif pokemon.level == highestLevel then -- check all ties for a faint
					highestFainted = highestFainted or pokemon.curHP == 0
				end
			end
		end
		return highestFainted
	end,
	EntirePartyFaints = function()
		for _, pokemon in ipairs(Program.GameData.PlayerTeam or {}) do
			if pokemon.curHP ~= 0 and pokemon.isEgg ~= 1 then -- ignore eggs
				return false
			end
		end
		return true
	end,
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
			if SpriteData.canDrawIcon(pokemon.pokemonID) and not SpriteData.IconData[pokemon.pokemonID][animType] then
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 60, 112, 16 },
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 78, 112, 16 },
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
				LogOverlay.isGameOver = false
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 96, 112, 16 },
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
	NotesGrade = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.NOTEPAD,
		getText = function(self) return Resources.GameOverScreen.ButtonGradeMyNotes end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 114, 112, 16 },
		onClick = function(self)
			StatMarkingScoreSheet.previousScreen = GameOverScreen
			StatMarkingScoreSheet.buildScreen()
			Program.changeScreenView(StatMarkingScoreSheet)
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 132, 112, 16 },
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
		if button.textColor == nil then
			button.textColor = "Lower box text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Lower box border", "Lower box background" }
		end
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
---@param lastBattleStatus number? [2 = Lost the match, 3 = Tied]
---@param lastTrainerId number? The TrainerId of the most recent enemy trainer that was battled
---@return boolean isGameOver
function GameOverScreen.checkForGameOver(lastBattleStatus, lastTrainerId)
	if not Main.IsOnBizhawk() or LogOverlay.isGameOver or GameOverScreen.isDisplayed or Battle.recentBattleWasTutorial then
		return false
	end

	local conditionKey = Options["Game Over condition"] or ""
	local lossConditionFunc = GameOverScreen.LossConditions[conditionKey] or GameOverScreen.LossConditions.LeadPokemonFaints
	if lossConditionFunc() then
		GameOverScreen.status = GameOverScreen.Statuses.LOST
	else
		lastBattleStatus = lastBattleStatus or Memory.readbyte(GameSettings.gBattleOutcome)
		lastTrainerId = lastTrainerId or Memory.readword(GameSettings.gTrainerBattleOpponent_A)
		if Battle.wonFinalBattle(lastBattleStatus, lastTrainerId) then
			GameOverScreen.status = GameOverScreen.Statuses.WON
		end
	end

	local isGameOver = GameOverScreen.status ~= GameOverScreen.Statuses.STILL_PLAYING
	if isGameOver then
		EventHandler.triggerEvent(EventHandler.DefaultEvents.GE_GameOver.Key)
	end
	return isGameOver
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
	Program.updateDataNextFrame()
end

function GameOverScreen.clearTempSaveStates()
	if not Main.IsOnBizhawk() or GameOverScreen.battleStartSaveState == nil then return end

	---@diagnostic disable-next-line: undefined-global
	memorysavestate.removestate(GameOverScreen.battleStartSaveState)
	GameOverScreen.battleStartSaveState = nil
end

-- Saves the currently loaded ROM, it's log file (if any), and the TDAT file to the Tracker's 'saved_games' folder
function GameOverScreen.saveCurrentGameFiles()
	local saveFolder = FileManager.getPathOverride("Backup Saves") or FileManager.prependDir(FileManager.Folders.SavedGames, true)
	FileManager.createFolder(saveFolder)

	local romname = QuickloadScreen.getGameProfileRomName()
	local rompath = QuickloadScreen.getGameProfileRomPath()

	local romnameToSave
	if Options["Generate ROM each time"] then
		romnameToSave = string.format("%s %s", (Main.currentSeed or 1), romname)
	else
		romnameToSave = romname
	end
	local rompathToSave = saveFolder .. romnameToSave .. FileManager.Extensions.GBA_ROM

	-- Don't replace existing save games, instead make a new one based on current time
	if FileManager.fileExists(rompathToSave) then
		romnameToSave = string.format("%s %s", os.time(), romname)
		rompathToSave = saveFolder .. romnameToSave .. FileManager.Extensions.GBA_ROM
	end
	if not FileManager.CopyFile(rompath, rompathToSave, "overwrite") then
		print("> ERROR: Unable to save a copy of your game's ROM file.")
		print(rompath or romname or "Unknown ROM")
		return false
	end

	local logname = romname .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local logpath = rompath .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local lognameToSave = romnameToSave .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local logpathToSave = saveFolder .. lognameToSave
	if not FileManager.CopyFile(logpath, logpathToSave, "overwrite") then
		print("> ERROR: Unable to save a copy of your game's log file.")
		print(logpath or logname or "Unknown LOG")
		return false
	end

	local tdatnameToSave = romnameToSave .. FileManager.Extensions.TRACKED_DATA
	local tdatpathToSave = saveFolder .. tdatnameToSave
	Tracker.saveData(tdatpathToSave)

	if Main.IsOnBizhawk() then
		local savestatePath = saveFolder .. romnameToSave .. FileManager.Extensions.BIZHAWK_SAVESTATE
		---@diagnostic disable-next-line: undefined-global
		savestate.save(savestatePath)
	end

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
		height = 58,
		text = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height,
		width = topBox.width,
		height = Constants.SCREEN.HEIGHT - topBox.height - 10,
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
	local columnOffsetX = 57
	if Main.currentSeed and Main.currentSeed ~= 1 then
		Drawing.drawText(topBox.x + 2, textLineY, Resources.GameOverScreen.LabelAttempt .. ":", topBox.text, topBox.shadow)
		Drawing.drawText(topBox.x + columnOffsetX, textLineY, Utils.formatNumberWithCommas(Main.currentSeed), topBox.text, topBox.shadow)
	end
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	if Tracker.Data.playtime and Tracker.Data.playtime > 0 then
		Drawing.drawText(topBox.x + 2, textLineY, Resources.GameOverScreen.LabelPlayTime .. ":", topBox.text, topBox.shadow)
		Drawing.drawText(topBox.x + columnOffsetX, textLineY, Program.GameTimer:getText(), topBox.text, topBox.shadow)
	end
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw the game winning message or a random Pokémon Stadium announcer quote
	local msgToDisplay
	if GameOverScreen.status == GameOverScreen.Statuses.WON then
		msgToDisplay = Resources.GameOverScreen.QuoteCongratulations
	else
		msgToDisplay = Resources.GameOverScreenQuotes[GameOverScreen.chosenQuoteIndex] or ""
	end
	local wrappedQuotes = Utils.getWordWrapLines(msgToDisplay, 30)
	local firstTwoLines = { wrappedQuotes[1], wrappedQuotes[2] }
	textLineY = textLineY + 5 * (2 - #firstTwoLines)
	for _, line in pairs(firstTwoLines) do
		local centerOffsetX = math.floor(topBox.width / 2 - Utils.calcWordPixelLength(line) / 2) - 1
		Drawing.drawText(topBox.x + centerOffsetX, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
	end

	-- Draw bottom border box
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)

	-- Draw all other buttons
	for _, button in pairs(GameOverScreen.Buttons) do
		if button ~= GameOverScreen.Buttons.PokemonIcon then
			if button.location == "top" then
				Drawing.drawButton(button, topBox.shadow)
			else
				Drawing.drawButton(button, botBox.shadow)
			end
		end
	end
end
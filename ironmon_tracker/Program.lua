Program = {
	currentScreen = 1,
	previousScreens = {}, -- breadcrumbs for clicking the Back button
	inStartMenu = false,
	inCatchingTutorial = false,
	hasCompletedTutorial = false,
	activeFormId = 0,
	lastActiveTimestamp = 0,
	clientFpsMultiplier = 1,
	Frames = {
		waitToDraw = 30, -- counts down
		highAccuracyUpdate = 10, -- counts down
		lowAccuracyUpdate = 30, -- counts down
		three_sec_update = 180, -- counts down
		saveData = 3600, -- counts down
		carouselActive = 0, -- counts up
		hideEnemy = 0, -- counts down
		--battleDataDelay = 60, -- counts down
		Others = {}, -- list of other frame counter objects
	},
}

Program.GameData = {
	mapId = 0, -- was previously Battle.CurrentRoute.mapId
	wildBattles = -999, -- used to track differences in GAME STATS
	trainerBattles = -999, -- used to track differences in GAME STATS
	friendshipRequired = 220,
	evolutionStones = { -- The evolution stones currently in bag
			[93] = 0, -- Sun Stone
			[94] = 0, -- Moon Stone
			[95] = 0, -- Fire Stone
			[96] = 0, -- Thunder Stone
			[97] = 0, -- Water Stone
			[98] = 0, -- Leaf Stone
	},
}

Program.GameTimer = {
	timeLastChecked = 0, -- Number of seconds
	showPauseTipUntil = 0, -- Displays "how to pause timer" tip until this time occurs; number of seconds
	hasStarted = false, -- Used to determine if the game has started (not in Title menus)
	isPaused = false, -- Used to manually pause the timer
	readyToDraw = false, -- Anytime the timer changes, it needs to be redrawn
	textColor = 0xFFFFFFFF,
	pauseColor = 0xFFFFFF00,
	notStartedColor = 0xFFAAAAAA,
	boxColor = 0x78000000,
	margin = 0,
	padding = 2,
	location = "LowerRight",
	box = {
		x = Constants.SCREEN.WIDTH,
		y = Constants.SCREEN.HEIGHT,
		width = 20,
		height = Constants.Font.SIZE,
	},
	getText = function(self)
		return Utils.formatTime(Tracker.Data.playtime or 0)
	end,
	initialize = function(self)
		self.hasStarted = false
		self.location = Options["Game timer location"] or "LowerRight"
		self.box.height = Constants.Font.SIZE - 4 + (2 * self.padding)
		self:update()
	end,
	start = function(self)
		self.hasStarted = true
		self.isPaused = false
		self.timeLastChecked = os.time()
		self.showPauseTipUntil = self.timeLastChecked
	end,
	pause = function(self)
		if not self.hasStarted then return end
		self.isPaused = true
	end,
	unpause = function(self)
		if self.isPaused then
			self.timeLastChecked = os.time()
		end
		self.isPaused = false
	end,
	update = function(self)
		local currTime = os.time()
		local prevTime = self.timeLastChecked
		self.timeLastChecked = currTime
		if self.hasStarted and not self.isPaused then
			local timeDelta = math.floor(os.difftime(currTime, prevTime))
			-- If emulator itself is paused-unpaused, don't add all that "paused time"
			if timeDelta > 0 then
				Tracker.Data.playtime = Tracker.Data.playtime + 1
			end
			self.readyToDraw = (timeDelta ~= 0)
		end

		self.box.width = Utils.calcWordPixelLength(self:getText() or "") - 1 + (2 * self.padding)
		self:updateLocationCoords()
	end,
	updateLocationCoords = function(self)
		if self.location == "UpperLeft" or self.location == "LowerLeft" then
			self.box.x = math.max(self.margin, 0)
		elseif self.location == "UpperCenter" or self.location == "LowerCenter" then
			self.box.x = math.floor(math.max((Constants.SCREEN.WIDTH - self.box.width) / 2 - 1, 0))
		else -- Lower-X
			self.box.x = math.max(Constants.SCREEN.WIDTH - self.box.width - self.margin - 1, 0)
		end
		if self.location == "UpperLeft" or self.location == "UpperCenter" or self.location == "UpperRight" then
			self.box.y = math.max(self.margin, 0)
		else -- Lower-Y
			self.box.y = math.max(Constants.SCREEN.HEIGHT - self.box.height - self.margin - 1, 0)
		end
	end,
	reset = function(self)
		Tracker.Data.playtime = 0
		self.hasStarted = false
		self.readyToDraw = false
		self:unpause()
	end,
	checkInput = function(self, xmouse, ymouse)
		-- Don't pause if either game screen overlay is covering the screen
		if not Options["Display play time"] or LogOverlay.isDisplayed or UpdateScreen.showNotes then return end
		local clicked = Input.isMouseInArea(xmouse, ymouse, self.box.x, self.box.y, self.box.width, self.box.height)
		if clicked then
			if self.isPaused then
				self:unpause()
			else
				self:pause()
			end
			self.readyToDraw = true
		end
	end,
	draw = function(self)
		self.readyToDraw = false
		if Options["Display play time"] then
			local x, y, width, height = self.box.x, self.box.y, self.box.width, self.box.height
			local formattedTime = self:getText()
			local color = self.textColor
			if not self.hasStarted then
				color = self.notStartedColor
			elseif self.isPaused then
				color = self.pauseColor
			end
			gui.drawRectangle(x, y, width, height, self.boxColor, self.boxColor)
			Drawing.drawText(x, y - 1, formattedTime, color)

			if self.showPauseTipUntil > self.timeLastChecked then
				width = Utils.calcWordPixelLength(Resources.ExtrasScreen.TimerPauseTip) - 1 + (2 * self.padding)
				x = math.max(self.box.x + self.box.width - width - self.margin, 0)
				y = math.max(self.box.y - self.box.height - self.margin - 2, self.box.height + self.margin + 2)
				gui.drawRectangle(x, y, width, height, self.boxColor, self.boxColor)
				Drawing.drawText(x, y - 1, Resources.ExtrasScreen.TimerPauseTip, self.textColor)
			end
		end
	end,
}

Program.ActiveRepel = {
	inUse = false,
	stepCount = 0,
	duration = 100,
	shouldDisplay = function(self)
		local enabledAndAllowed = Options["Display repel usage"] and Program.ActiveRepel.inUse and Program.isValidMapLocation()
		local hasConflict = Battle.inBattle or Battle.battleStarted or Program.inStartMenu or GameOverScreen.isDisplayed or LogOverlay.isDisplayed
		local inHallOfFame = Program.GameData.mapId ~= nil and RouteData.Locations.IsInHallOfFame[Program.GameData.mapId]
		return enabledAndAllowed and not hasConflict and not inHallOfFame
	end,
	draw = function(self)
		if self:shouldDisplay() then
			Drawing.drawRepelUsage()
		end
	end,
}

Program.Pedometer = {
	totalSteps = 0, -- updated from GAME_STATS
	lastResetCount = 0, -- num steps since last "reset", for counting new steps
	goalSteps = 0, -- num steps that is set by the user as a milestone goal to reach, 0 to disable
	getCurrentStepcount = function(self) return math.max(self.totalSteps - self.lastResetCount, 0) end,
	isInUse = function(self)
		local enabledAndAllowed = Options["Display pedometer"] and Program.isValidMapLocation()
		local hasConflict = Battle.inBattle or Battle.battleStarted or GameOverScreen.isDisplayed or LogOverlay.isDisplayed
		return enabledAndAllowed and not hasConflict
	end,
}

Program.AutoSaver = {
	knownSaveCount = 0,
	framesUntilNextSave = -1,
	updateSaveCount = function(self) -- returns true if the savecount has been updated
		local currentSaveCount = Utils.getGameStat(Constants.GAME_STATS.SAVED_GAME) or 0
		local saveSuccessCountdown = Memory.readbyte(GameSettings.sSaveDialogDelay) or 0
		-- Starts at 60 on success, then immediately decrements to 59 before checking if the save menu should close
		if saveSuccessCountdown == 60 and currentSaveCount > self.knownSaveCount and currentSaveCount < 99999 then
			self.knownSaveCount = currentSaveCount
			return true
		end
		return false
	end,
	checkForNextSave = function(self)
		if self:updateSaveCount() then
			-- Force Tracker Data to also save
			Program.Frames.saveData = 0

			-- Flush saveRAM only for Bizhawk
			if Main.IsOnBizhawk() then
				client.saveram()
			end
		end
	end
}

function Program.initialize()
	-- If an update is available, offer that up first before going to the Tracker StartupScreen
	if Main.Version.showUpdate then
		Program.currentScreen = UpdateScreen
	else
		Program.currentScreen = StartupScreen
	end

	if Main.IsOnBizhawk() then
		Program.clientFpsMultiplier = math.max(client.get_approx_framerate() / 60, 1) -- minimum of 1
	end

	-- Check if requirement for Friendship evos has changed (Default:219, MakeEvolutionsFaster:159)
	local friendshipRequired = Memory.readbyte(GameSettings.FriendshipRequiredToEvo) + 1
	if friendshipRequired > 1 and friendshipRequired <= 220 then
		Program.GameData.friendshipRequired = friendshipRequired
	end

	Program.AutoSaver:updateSaveCount()
	Program.GameTimer:initialize()
	Program.lastActiveTimestamp = os.time()

	-- Update data asap
	Program.Frames.highAccuracyUpdate = 0
	Program.Frames.lowAccuracyUpdate = 0
	Program.Frames.three_sec_update = 0
	Program.Frames.waitToDraw = 1
	Program.Frames.Others = {}
end

function Program.mainLoop()
	if Main.loadNextSeed and not Main.IsOnBizhawk() then -- required escape for mGBA
		Main.LoadNextRom()
		return
	end
	Input.checkForInput()
	Program.update()
	Battle.update()
	CustomCode.afterEachFrame()
	Program.redraw(false)
	Program.stepFrames() -- TODO: Really want a better way to handle this
end

-- 'forced' = true will force a draw, skipping the normal frame wait time
function Program.redraw(forced)
	local shouldDraw = (forced == true) or (Program.Frames.waitToDraw <= 0) or Program.GameTimer.readyToDraw

	if not shouldDraw then
		if Program.Frames.waitToDraw > 0 then
			Program.Frames.waitToDraw = Program.Frames.waitToDraw - 1
		end
		return
	end

	-- Only redraw the screen every half second (60 frames/sec)
	Program.Frames.waitToDraw = 30

	if Main.IsOnBizhawk() then
		Program.ActiveRepel:draw()
		Program.GameTimer:draw()

		-- These screens occupy the main game screen space, overlayed on top, and need their own check; order matters
		if UpdateScreen.showNotes then
			UpdateScreen.drawReleaseNotesOverlay()
		elseif LogOverlay.isDisplayed then
			LogOverlay.drawScreen()
		end

		if Program.currentScreen ~= nil and type(Program.currentScreen.drawScreen) == "function" then
			Program.currentScreen.drawScreen()
		end

		if TeamViewArea.isDisplayed() then
			TeamViewArea.drawScreen()
		end
	else
		MGBA.ScreenUtils.updateTextBuffers()
	end

	CustomCode.afterRedraw()
	SpriteData.cleanupActiveIcons()
end

function Program.changeScreenView(screen)
	-- table.insert(Program.previousScreens, Program.currentScreen) -- TODO: implement later
	Program.lastActiveTimestamp = os.time()
	if type(screen.refreshButtons) == "function" then
		screen:refreshButtons()
	end
	Program.currentScreen = screen
	Program.redraw(true)
end

-- TODO: Currently unused, implement later
function Program.goBackToPreviousScreen()
	Utils.printDebug("DEBUG: From %s previous screens.", #Program.previousScreens)
	if #Program.previousScreens == 0 then
		Program.currentScreen = TrackerScreen
	else
		Program.currentScreen = table.remove(Program.previousScreens)
	end
	Program.redraw(true)
end

function Program.destroyActiveForm()
	if Program.activeFormId ~= nil and Program.activeFormId ~= 0 then
		Utils.closeBizhawkForm(Program.activeFormId)
	end
end

function Program.update()
	-- Be careful adding too many things to this 10 frame update
	if Program.Frames.highAccuracyUpdate == 0 then
		if Main.IsOnBizhawk() then
			Program.clientFpsMultiplier = math.max(client.get_approx_framerate() / 60, 1) -- minimum of 1
		end

		Program.updateMapLocation() -- trying this here to solve many future problems

		if not Program.GameTimer.hasStarted and Program.isValidMapLocation() then
			Program.GameTimer:start()
		end
		Program.GameTimer:update()
		if not CrashRecoveryScreen.started and Program.isValidMapLocation() then
			CrashRecoveryScreen.startSavingBackups()
		end

		-- If the lead Pokemon changes, then update the animated Pokemon picture box
		if Options["Animated Pokemon popout"] then
			local leadPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn, true)
			if leadPokemon ~= nil and leadPokemon.pokemonID ~= 0 and Program.isValidMapLocation() then
				if leadPokemon.pokemonID ~= Drawing.AnimatedPokemon.pokemonID then
					Drawing.AnimatedPokemon:setPokemon(leadPokemon.pokemonID)
				elseif Drawing.AnimatedPokemon.requiresRelocating then
					Drawing.AnimatedPokemon:relocatePokemon()
				end
			end
		end
	end

	-- Don't bother reading game data before a game even begins
	if not Program.isValidMapLocation() then
		return
	end

	-- Get any "new" information from game memory for player's pokemon team every half second (60 frames/sec)
	if Program.Frames.lowAccuracyUpdate == 0 then
		Program.updateCatchingTutorial()

		if not Program.inCatchingTutorial and not Program.isInEvolutionScene() then
			Program.updatePokemonTeams()
			TeamViewArea.buildOutPartyScreen()

			if Program.isValidMapLocation() then
				if Program.currentScreen == StartupScreen then
					-- If the game hasn't started yet, show the start-up screen instead of the main Tracker screen
					Program.currentScreen = TrackerScreen
				elseif RouteData.Locations.IsInHallOfFame[Program.GameData.mapId] and not GameOverScreen.enteredFromSpecialLocation then
					GameOverScreen.enteredFromSpecialLocation = true
					Program.currentScreen = GameOverScreen
				end
			elseif GameOverScreen.enteredFromSpecialLocation then
				GameOverScreen.enteredFromSpecialLocation = false
			end

			-- Check if summary screen has being shown
			if not Tracker.Data.hasCheckedSummary then
				if Memory.readbyte(GameSettings.sMonSummaryScreen) ~= 0 then
					Tracker.Data.hasCheckedSummary = true
				end
			end

			-- Check if a Pokemon in the player's party is learning a move, if so track it
			local learnedInfoTable = Program.getLearnedMoveInfoTable()
			if learnedInfoTable.pokemonID ~= nil then
				Tracker.TrackMove(learnedInfoTable.pokemonID, learnedInfoTable.moveId, learnedInfoTable.level)
			end

			if Options["Display repel usage"] and not (Battle.inBattle or Battle.battleStarted) then
				-- Check if the player is in the start menu (for hiding the repel usage icon)
				Program.inStartMenu = Program.isInStartMenu()
				-- Check for active repel and steps remaining
				if not Program.inStartMenu then
					Program.updateRepelSteps()
				end
			end

			-- Update step count only if the option is enabled
			if Program.Pedometer:isInUse() then
				Program.Pedometer.totalSteps = Utils.getGameStat(Constants.GAME_STATS.STEPS)
			end

			Program.AutoSaver:checkForNextSave()
			TimeMachineScreen.checkCreatingRestorePoint()
		end

		if Input.joypadUsedRecently then
			Program.lastActiveTimestamp = os.time()
			SpriteData.checkForIdleSleeping(0)
		end
	end

	-- Only update "Heals in Bag", Evolution Stones, "PC Heals", and "Badge Data" info every 3 seconds (3 seconds * 60 frames/sec)
	if Program.Frames.three_sec_update == 0 then
		Program.updateBagItems()
		Program.updatePCHeals()
		Program.updateBadgesObtained()
		CrashRecoveryScreen.trySaveBackup()

		if not Input.joypadUsedRecently then
			local secondsSinceLastActive = math.max(os.time() - Program.lastActiveTimestamp, 0)
			SpriteData.checkForIdleSleeping(secondsSinceLastActive)
		else
			-- Reset the joypad button tracking, checking only once every 3 seconds if active
			Input.joypadUsedRecently = false
		end
	end

	-- Only save tracker data every 1 minute (60 seconds * 60 frames/sec) and after every battle (set elsewhere)
	if Program.Frames.saveData == 0 then
		-- Don't bother saving tracked data if the player doesn't have a Pokemon yet
		if Options["Auto save tracked game data"] and Tracker.getPokemon(1, true) ~= nil then
			Tracker.saveData()
		end
	end

	if Program.Frames.lowAccuracyUpdate == 0 then
		CustomCode.afterProgramDataUpdate()
	end
end

function Program.stepFrames()
	Program.Frames.highAccuracyUpdate = (Program.Frames.highAccuracyUpdate - 1) % 10
	Program.Frames.lowAccuracyUpdate = (Program.Frames.lowAccuracyUpdate - 1) % 30
	Program.Frames.three_sec_update = (Program.Frames.three_sec_update - 1) % 180
	Program.Frames.saveData = (Program.Frames.saveData - 1) % 3600
	Program.Frames.carouselActive = Program.Frames.carouselActive + 1
	if Program.Frames.hideEnemy > 0 then
		Program.Frames.hideEnemy = Program.Frames.hideEnemy - 1
	end

	for _, framecounter in pairs(Program.Frames.Others or {}) do
		if type(framecounter.step) == "function" then
			framecounter:step()
		end
	end

	SpriteData.updateActiveIcons()
end

--- Creates a frame counter that counts down N frames (or emulation steps), and repeats indefinitely.
--- @param label string The name key for this counter, referenced by Program.Frames.Other[label]
--- @param frames integer The number of frames, N, to count down. When it reaches 0, it restarts.
--- @param callFunc function|nil Optional function to call each time the counter reaches 0.
--- @param scaleWithSpeedup boolean|nil If true, will sync the counter to real time instead of the client's frame rate, ignoring speedup
--- @return table|nil FrameCounter Returns the created frame counter
function Program.addFrameCounter(label, frames, callFunc, scaleWithSpeedup)
	if label == nil or (frames or 0) <= 0 then return nil end
	Program.Frames.Others[label] = {
		framesElapsed = 0.0,
		maxFrames = frames,
		paused = false,
		pause = function(self) self.paused = true end,
		unpause = function(self) self.paused = false end,
		step = function(self)
			if self.paused then return end
			-- Sync with client frame rate (turbo/unthrottle)
			local delta = scaleWithSpeedup and (1.0 / Program.clientFpsMultiplier) or 1
			self.framesElapsed = self.framesElapsed + delta
			if self.framesElapsed >= self.maxFrames then
				self.framesElapsed = 0.0
				if type(callFunc) == "function" then
					callFunc()
				end
			end
		end,
	}
	return Program.Frames.Others[label]
end

function Program.removeFrameCounter(label)
	if label == nil then return end
	Program.Frames.Others[label] = nil
end

function Program.updateRepelSteps()
	-- Checks for an active repel and updates the current steps remaining
	-- Game uses a variable for the repel steps remaining, which remains at 0 when there's no active repel
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	local repelStepCountOffset = Utils.inlineIf(GameSettings.game == 3, 0x40, 0x42)
	local repelStepCount = Memory.readbyte(saveblock1Addr + GameSettings.gameVarsOffset + repelStepCountOffset)
	if repelStepCount ~= nil and repelStepCount > 0 then
		Program.ActiveRepel.inUse = true
		if repelStepCount ~= Program.ActiveRepel.stepCount then
			Program.ActiveRepel.stepCount = repelStepCount
			-- Duration is defaulted to normal repel (100 steps), check if super or max is used instead
			if repelStepCount > Program.ActiveRepel.duration then
				if repelStepCount <= 200 then
					-- Super Repel
					Program.ActiveRepel.duration = 200
				elseif repelStepCount <= 250 then
					-- Max Repel
					Program.ActiveRepel.duration = 250
				end
			end
		end
	elseif repelStepCount == 0 then
		-- Reset the active repel data when none is active (remaining step count 0)
		Program.ActiveRepel.inUse = false
		Program.ActiveRepel.stepCount = 0
		Program.ActiveRepel.duration = 100
	end
end

function Program.updatePokemonTeams()
	-- Check for updates to each pokemon team
	local addressOffset = 0

	-- Check if it's a new game (no Pokémon yet)
	if not Tracker.Data.isNewGame and Tracker.Data.ownTeam[1] == 0 then
		Tracker.Data.isNewGame = true
	end

	for i = 1, 6, 1 do
		-- Lookup information on the player's Pokemon first
		local personality = Memory.readdword(GameSettings.pstats + addressOffset)
		local trainerID = Memory.readdword(GameSettings.pstats + addressOffset + 4)
		-- local previousPersonality = Tracker.Data.ownTeam[i] -- See below
		Tracker.Data.ownTeam[i] = personality

		if personality ~= 0 or trainerID ~= 0 then
			local newPokemonData = Program.readNewPokemon(GameSettings.pstats + addressOffset, personality)

			if Program.validPokemonData(newPokemonData) then
				-- Sets the player's trainerID as soon as they get their first Pokemon
				if Tracker.Data.isNewGame and newPokemonData.trainerID ~= nil and newPokemonData.trainerID ~= 0 then
					if Tracker.Data.trainerID == nil or Tracker.Data.trainerID == 0 then
						Tracker.Data.trainerID = newPokemonData.trainerID
					elseif Tracker.Data.trainerID ~= newPokemonData.trainerID then
						-- Reset the tracker data as old data was loaded and we have a different trainerID now
						print("Old/Incorrect data was detected for this ROM. Initializing new data.")
						local playtime = Tracker.Data.playtime
						Tracker.resetData()
						Tracker.Data.trainerID = newPokemonData.trainerID
						Tracker.Data.playtime = playtime
					end

					-- Unset the new game flag
					Tracker.Data.isNewGame = false
				end

				-- Remove trainerID value from the pokemon data itself since it's now owned by the player, saves data space
				-- No longer remove, as it's currently used to verify Trainer pokemon with personality values of 0
				-- newPokemonData.trainerID = nil

				-- Include experience information for each Pokemon in the player's team
				local curExp, totalExp = Program.getNextLevelExp(newPokemonData.pokemonID, newPokemonData.level, newPokemonData.experience)
				newPokemonData.currentExp = curExp
				newPokemonData.totalExp = totalExp

				Tracker.addUpdatePokemon(newPokemonData, personality, true)
			end
		end

		-- Then lookup information on the opposing Pokemon
		personality = Memory.readdword(GameSettings.estats + addressOffset)
		trainerID = Memory.readdword(GameSettings.estats + addressOffset + 4)
		Tracker.Data.otherTeam[i] = personality

		if personality ~= 0 or trainerID ~= 0 then
			local newPokemonData = Program.readNewPokemon(GameSettings.estats + addressOffset, personality)

			if Program.validPokemonData(newPokemonData) then
				-- Double-check a race condition where current PP values are wildly out of range if retrieved right before a battle begins
				if not Battle.inBattle then
					for _, move in pairs(newPokemonData.moves) do
						if move.id ~= 0 then
							move.pp = tonumber(MoveData.Moves[move.id].pp) -- set value to max PP
						end
					end
				end

				Tracker.addUpdatePokemon(newPokemonData, personality, false)
			end
		end

		-- Next Pokemon - Each is offset by 100 bytes
		addressOffset = addressOffset + 100
	end
end

function Program.readNewPokemon(startAddress, personality)
	-- Pokemon Data structure: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_III)
	local otid = Memory.readdword(startAddress + 4)
	local magicword = Utils.bit_xor(personality, otid) -- The XOR encryption key for viewing the Pokemon data

	local aux = personality % 24
	local growthoffset = (MiscData.TableData.growth[aux + 1] - 1) * 12
	local attackoffset = (MiscData.TableData.attack[aux + 1] - 1) * 12
	-- local effortoffset = (MiscData.TableData.effort[aux + 1] - 1) * 12
	local miscoffset = (MiscData.TableData.misc[aux + 1] - 1) * 12

	-- Pokemon Data substructure: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_(Generation_III)
	local growth1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + growthoffset), magicword)
	local growth2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + growthoffset + 4), magicword) -- Experience
	local growth3 = Utils.bit_xor(Memory.readdword(startAddress + 32 + growthoffset + 8), magicword)
	local attack1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + attackoffset), magicword)
	local attack2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + attackoffset + 4), magicword)
	local attack3 = Utils.bit_xor(Memory.readdword(startAddress + 32 + attackoffset + 8), magicword)
	local misc2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + miscoffset + 4), magicword)

	local nickname = ""
	for i=0, 9, 1 do
		local charByte = Memory.readbyte(startAddress + 8 + i)
		if charByte == 0xFF then break end -- end of sequence
		nickname = nickname .. (GameSettings.GameCharMap[charByte] or Constants.HIDDEN_INFO)
	end
	nickname = Utils.formatSpecialCharacters(nickname)

	-- Unused data memory reads
	-- local effort1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + effortoffset), magicword)
	-- local effort2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + effortoffset + 4), magicword)
	-- local effort3 = Utils.bit_xor(Memory.readdword(startAddress + 32 + effortoffset + 8), magicword)
	-- local misc3   = Utils.bit_xor(Memory.readdword(startAddress + 32 + miscoffset + 8), magicword)

	-- Checksum, currently unused
	-- local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	-- 		+ Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
	-- 		+ Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
	-- 		+ Utils.addhalves(misc1) + Utils.addhalves(misc2) + Utils.addhalves(misc3)
	-- cs = cs % 65536

	local species = Utils.getbits(growth1, 0, 16) -- Pokemon's Pokedex ID
	local abilityNum = Utils.getbits(misc2, 31, 1) -- [0 or 1] to determine which ability, available in PokemonData

	-- Check for shininess: https://bulbapedia.bulbagarden.net/wiki/Personality_value#Shininess
	local trainerID = Utils.getbits(otid, 0, 16)
	local secretID = Utils.getbits(otid, 16, 16)
	local p1 = math.floor(personality / 65536)
	local p2 = personality % 65536
	local isShiny = Utils.bit_xor(Utils.bit_xor(Utils.bit_xor(trainerID, secretID), p1), p2) < 8
	local hasPokerus
	if GameSettings.game ~= 3 then -- PokeRus doesn't exist in FRLG due to lack of passing time
		local misc1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + miscoffset), magicword)
		-- First 4 bits are number of days until Pokerus is cured, Second 4 bits are the strain variation
		hasPokerus = Utils.getbits(misc1, 0, 8) > 0
	end

	-- Determine status condition
	local status_aux = Memory.readdword(startAddress + 80)
	local sleep_turns_result = 0
	local status_result = 0
	if status_aux == 0 then --None
		status_result = 0
	elseif status_aux < 8 then -- Sleep
		sleep_turns_result = status_aux
		status_result = 1
	elseif status_aux == 8 then -- Poison
		status_result = 2
	elseif status_aux == 16 then -- Burn
		status_result = 3
	elseif status_aux == 32 then -- Freeze
		status_result = 4
	elseif status_aux == 64 then -- Paralyze
		status_result = 5
	elseif status_aux == 128 then -- Toxic Poison
		status_result = 6
	end

	-- Can likely improve this further using memory.read_bytes_as_array but would require testing to verify
	local level_and_currenthp = Memory.readdword(startAddress + 84)
	local maxhp_and_atk = Memory.readdword(startAddress + 88)
	local def_and_speed = Memory.readdword(startAddress + 92)
	local spatk_and_spdef = Memory.readdword(startAddress + 96)

	return {
		personality = personality,
		nickname = nickname,
		trainerID = trainerID,
		pokemonID = species,
		heldItem = Utils.getbits(growth1, 16, 16),
		experience = growth2,
		friendship = Utils.getbits(growth3, 8, 8),
		level = Utils.getbits(level_and_currenthp, 0, 8),
		nature = personality % 25,
		isEgg = Utils.getbits(misc2, 30, 1), -- [0 or 1] to determine if mon is still an egg (1 if true)
		isShiny = isShiny,
		hasPokerus = hasPokerus, -- Not realistically available in FRLG
		abilityNum = abilityNum,
		status = status_result,
		sleep_turns = sleep_turns_result,
		curHP = Utils.getbits(level_and_currenthp, 16, 16),
		stats = {
			hp = Utils.getbits(maxhp_and_atk, 0, 16),
			atk = Utils.getbits(maxhp_and_atk, 16, 16),
			def = Utils.getbits(def_and_speed, 0, 16),
			spa = Utils.getbits(spatk_and_spdef, 0, 16),
			spd = Utils.getbits(spatk_and_spdef, 16, 16),
			spe = Utils.getbits(def_and_speed, 16, 16),
		},
		statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
		moves = {
			{ id = Utils.getbits(attack1, 0, 16), level = 1, pp = Utils.getbits(attack3, 0, 8) },
			{ id = Utils.getbits(attack1, 16, 16), level = 1, pp = Utils.getbits(attack3, 8, 8) },
			{ id = Utils.getbits(attack2, 0, 16), level = 1, pp = Utils.getbits(attack3, 16, 8) },
			{ id = Utils.getbits(attack2, 16, 16), level = 1, pp = Utils.getbits(attack3, 24, 8) },
		},

		-- Unused data that can be added back in later
		-- iv = misc2,
		-- ev1 = effort1,
		-- ev2 = effort2,
	}
end

-- Returns two values [numAlive, total] for a given Trainer's Pokémon team.
function Program.getTeamCounts()
	local numAlive, total = 0, 0
	for i = 1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, false)
		if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
			total = total + 1
			if (pokemon.curHP or 0) > 0 then
				numAlive = numAlive + 1
			end
		end
	end

	return numAlive, total
end

-- Returns two exp values that describe the amount of experience points needed to reach the next level.
-- currentExp: A value between 0 and 'totalExp'
-- totalExp: The amount of exp needed to reach the next level
function Program.getNextLevelExp(pokemonID, level, experience)
	if not PokemonData.isValid(pokemonID) or level == nil or level >= 100 or experience == nil or GameSettings.gExperienceTables == nil then
		return 0, 100 -- arbitrary returned values to indicate this information isn't found and it's 0% of the way to next level
	end

	local growthRateIndex = Memory.readbyte(GameSettings.gBaseStats + (pokemonID * 0x1C) + 0x13)
	local expTableOffset = GameSettings.gExperienceTables + (growthRateIndex * 0x194) + (level * 0x4)
	local expAtLv = Memory.readdword(expTableOffset)
	local expAtNextLv = Memory.readdword(expTableOffset + 0x4)

	local currentExp = experience - expAtLv
	local totalExp = expAtNextLv - expAtLv

	return currentExp, totalExp
end

function Program.updatePCHeals()
	-- Updates PC Heal tallies and handles auto-tracking PC Heal counts when the option is on
	-- Currently checks the total number of heals from pokecenters and from mom
	-- Does not include whiteouts, as those don't increment either of these gamestats

	-- Save blocks move and are re-encrypted right as the battle starts
	if Battle.inBattle or Battle.battleStarted then
		return
	end

	-- Make sure the player is in a map location that can perform a PC heal
	if not RouteData.Locations.CanPCHeal[Program.GameData.mapId] then
		return
	end

	local gameStat_UsedPokecenter = Utils.getGameStat(Constants.GAME_STATS.USED_POKECENTER)
	-- Turns out Game Freak are weird and only increment mom heals in RSE, not FRLG
	local gameStat_RestedAtHome = Utils.getGameStat(Constants.GAME_STATS.RESTED_AT_HOME)

	local combinedHeals = gameStat_UsedPokecenter + gameStat_RestedAtHome

	if combinedHeals ~= Tracker.Data.gameStatsHeals then
		-- Update the local tally if there is a new heal
		Tracker.Data.gameStatsHeals = combinedHeals
		-- Only change the displayed PC Heals count when the option is on and auto-tracking is enabled
		if Options["Track PC Heals"] and TrackerScreen.Buttons.PCHealAutoTracking.toggleState then
			if Options["PC heals count downward"] then
				-- Automatically count down
				Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
				if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			else
				-- Automatically count up
				Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
				if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			end
		end
	end
end

function Program.updateBadgesObtained()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return
	end

	local badgeBits = nil
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	if GameSettings.game == 1 then -- Ruby/Sapphire
		badgeBits = Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 2 then -- Emerald
		badgeBits = Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 3 then -- FireRed/LeafGreen
		badgeBits = Memory.readbyte(saveblock1Addr + GameSettings.badgeOffset)
	end

	if badgeBits ~= nil then
		for index = 1, 8, 1 do
			local badgeName = "badge" .. index
			local badgeButton = TrackerScreen.Buttons[badgeName]
			local badgeState = Utils.getbits(badgeBits, index - 1, 1)
			badgeButton:updateState(badgeState)
		end
	end
end

function Program.updateMapLocation()
	local newMapId = Memory.readword(GameSettings.gMapHeader + 0x12) -- 0x12: mapLayoutId

	-- If the player is in a new area, auto-lookup for mGBA screen
	if not Main.IsOnBizhawk() and newMapId ~= Program.GameData.mapId then
		local isFirstLocation = Program.GameData.mapId == nil or Program.GameData.mapId == 0
		MGBA.Screens.LookupRoute:setData(newMapId, isFirstLocation)
	end
	Program.GameData.mapId = newMapId
end

-- More or less used to determine if the player has begun playing the game, returns true if so.
function Program.isValidMapLocation()
	return Program.GameData.mapId ~= nil and Program.GameData.mapId ~= 0
end

function Program.HandleExit()
	if not Main.IsOnBizhawk() then
		return
	end

	gui.clearImageCache()
	Drawing.clearGUI()
	client.SetGameExtraPadding(0, 0, 0, 0)
	forms.destroyall()

	-- Emulator is closing as expected; no crash
	CrashRecoveryScreen.logCrashReport(false)
end

-- Returns focus back to Bizhawk, using the name of the rom as the name of the Bizhawk window
function Program.focusBizhawkWindow()
	if not Main.IsOnBizhawk() then return end
	local bizhawkWindowName = GameSettings.getRomName()
	if bizhawkWindowName and bizhawkWindowName ~= "" then
		local command = string.format("AppActivate(%s)", bizhawkWindowName)
		FileManager.tryOsExecute(command)
	end
end

-- Returns a table that contains {pokemonID, level, and moveId} of the player's Pokemon that is currently learning a new move via experience level-up.
function Program.getLearnedMoveInfoTable()
	local battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)

	-- If the battle message relates to learning a new move, read in that move id
	if GameSettings.BattleScript_LearnMoveLoop <= battleMsg and battleMsg <= GameSettings.BattleScript_LearnMoveReturn then
		local moveToLearnId = Memory.readword(GameSettings.gMoveToLearn)

		local battleStructAddress
		if GameSettings.gBattleStructPtr ~= nil then -- Pointer unavailable in RS
			battleStructAddress = Memory.readdword(GameSettings.gBattleStructPtr)
		else
			battleStructAddress = 0x02000000 -- gSharedMem
		end

		local partyIndex = Memory.readbyte(battleStructAddress + 0x10) + 1 -- expGetterMonId: Party index of player (1-6)
		local pokemon = Tracker.getPokemon(partyIndex, true)
		if pokemon ~= nil then
			return {
				pokemonID = pokemon.pokemonID,
				level = pokemon.level,
				moveId = moveToLearnId,
			}
		end

		return {
			pokemonID = nil,
			level = nil,
			moveId = moveToLearnId,
		}
	end

	return {
		pokemonID = nil,
		level = nil,
		moveId = nil,
	}
end

-- Useful for dynamically getting the Pokemon's types if they have changed somehow (Color change, Transform, etc)
function Program.getPokemonTypes(isOwn, isLeft)
	local ownerAddressOffset = Utils.inlineIf(isOwn, 0x0, 0x58)
	local leftAddressOffset = Utils.inlineIf(isLeft, 0x0, 0xB0)
	local typesData = Memory.readword(GameSettings.gBattleMons + 0x21 + ownerAddressOffset + leftAddressOffset)
	return {
		PokemonData.TypeIndexMap[Utils.getbits(typesData, 0, 8)],
		PokemonData.TypeIndexMap[Utils.getbits(typesData, 8, 8)],
	}
end

-- Updates 'inCatchingTutorial' and 'hasCompletedTutorial' based on if the player has/hasn't completed the catching tutorial
function Program.updateCatchingTutorial()
	if Program.hasCompletedTutorial then return end

	local tutorialFlag = Memory.readbyte(GameSettings.sSpecialFlags)

	-- At some point after the tutorial has begun, it will end (Flag=0)
	if Program.inCatchingTutorial and tutorialFlag == 0 then
		Program.hasCompletedTutorial = true
	end

	Program.inCatchingTutorial = (tutorialFlag == 3)
	if Program.inCatchingTutorial then
		Battle.recentBattleWasTutorial = true
	end
end

function Program.isInEvolutionScene()
	local evoInfo
	--Ruby and Sapphire reference sEvoInfo (EvoInfo struct) directly. All other Gen 3 games instead store a pointer to the EvoInfo struct which needs to be read first
	if GameSettings.game ~= 1 then
		evoInfo = Memory.readdword(GameSettings.sEvoStructPtr)
	else
		evoInfo = GameSettings.sEvoInfo
	end
	-- third byte of EvoInfo is dedicated to the taskId
	local taskID = Memory.readbyte(evoInfo + 0x2)

	--only 16 tasks possible max in gTasks
	if taskID > 15 then return false end

	--Check for Evolution Task (Task_EvolutionScene + 0x1); Task struct size is 0x28
	local taskFunc = Memory.readdword(GameSettings.gTasks + (0x28 * taskID))
	if taskFunc ~= GameSettings.Task_EvolutionScene then return false end

	--Check if the Task is active
	local isActive = Memory.readbyte(GameSettings.gTasks + (0x28 * taskID) + 0x4)
	if isActive ~= 1 then return false end

	return true
end

-- Returns true if player is in the start menu (or the subsequent pokedex/pokemon/bag/etc menus)
function Program.isInStartMenu()
	-- Current Issues:
	-- 1) Sometimes this window ID gets unset for a brief duration during the transition back to the start menu
	-- 2) This window ID doesn't exist at all in Ruby/Sapphire, yet to figure out an alternative
	if GameSettings.game == 1 then return false end -- Skip checking for Ruby/Sapphire

	local startMenuWindowId = Memory.readbyte(GameSettings.sStartMenuWindowId)
	return startMenuWindowId == 1
end

-- Pokemon is valid if it has a valid id, helditem, and each move that exists is a real move.
function Program.validPokemonData(pokemonData)
	if pokemonData == nil then return false end

	-- If the Pokemon exists, but it's ID is invalid
	if not PokemonData.isValid(pokemonData.pokemonID) and pokemonData.pokemonID ~= 0 then -- 0 = blank pokemon id
		return false
	end

	-- If the Pokemon is holding an item, and that item is invalid
	if pokemonData.heldItem ~= nil and (pokemonData.heldItem < 0 or pokemonData.heldItem > 376) then
		return false
	end

	-- For each of the Pokemon's moves that isn't blank, is that move real
	for _, move in pairs(pokemonData.moves) do
		if not MoveData.isValid(move.id) and move.id ~= 0 then -- 0 = blank move id
			return false
		end
	end

	return true
end

function Program.updateBagItems()
	if not Tracker.Data.isViewingOwn then return end

	local leadPokemon = Battle.getViewedPokemon(true)
	if leadPokemon ~= nil then
		local healingItems, evolutionStones = Program.getBagItems()
		if healingItems ~= nil then
			Tracker.Data.healingItems = Program.calcBagHealingItems(leadPokemon.stats.hp, healingItems)
		end
		if evolutionStones ~= nil then
			Program.GameData.evolutionStones = evolutionStones
		end
	end
end

function Program.calcBagHealingItems(pokemonMaxHP, healingItemsInBag)
	local totals = {
		healing = 0,
		numHeals = 0,
	}

	-- Check for potential divide-by-zero errors
	if pokemonMaxHP == nil or pokemonMaxHP == 0 then
		return totals
	end

	-- Define some max values to prevent erroneous game data reads
	local maxPossibleQuantity = 999
	-- Formatted as: healingItemsInBag[itemID] = quantity
	for itemID, quantity in pairs(healingItemsInBag) do
		local healItemData = MiscData.HealingItems[itemID]
		if healItemData ~= nil and quantity > 0 then
			local healingPercentage = 0
			if healItemData.type == MiscData.HealingType.Constant then
				-- Healing is in a percentage compared to the mon's max HP
				local percentage = healItemData.amount / pokemonMaxHP * 100
				if percentage > 100 then
					percentage = 100
				end
				healingPercentage = percentage * quantity
			elseif healItemData.type == MiscData.HealingType.Percentage then
				healingPercentage = healItemData.amount * quantity
			end

			if quantity > 0 and quantity <= maxPossibleQuantity then
				totals.healing = totals.healing + healingPercentage
				totals.numHeals = totals.numHeals + quantity
			end
		end
	end

	return totals
end

function Program.getBagItems()
	local healingItems = {}
	local evoStones = {
		[93] = 0, -- Sun Stone
		[94] = 0, -- Moon Stone
		[95] = 0, -- Fire Stone
		[96] = 0, -- Thunder Stone
		[97] = 0, -- Water Stone
		[98] = 0, -- Leaf Stone
	}

	local key = Utils.getEncryptionKey(2) -- Want a 16-bit key
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local addressesToScan = {
		[saveBlock1Addr + GameSettings.bagPocket_Items_offset] = GameSettings.bagPocket_Items_Size,
		[saveBlock1Addr + GameSettings.bagPocket_Berries_offset] = GameSettings.bagPocket_Berries_Size,
	}
	for address, size in pairs(addressesToScan) do
		for i = 0, (size - 1), 1 do
			--read 4 bytes at once, should be less expensive than reading two sets of 2 bytes.
			local itemid_and_quantity = Memory.readdword(address + i * 0x4)
			local itemID = Utils.getbits(itemid_and_quantity, 0, 16)
			if itemID ~= 0 then
				local quantity = Utils.getbits(itemid_and_quantity, 16, 16)
				if key ~= nil then quantity = Utils.bit_xor(quantity, key) end

				if MiscData.HealingItems[itemID] ~= nil then
					healingItems[itemID] = quantity
				elseif MiscData.EvolutionStones[itemID] ~= nil then
					evoStones[itemID] = quantity
				end
			end
		end
	end

	return healingItems, evoStones
end

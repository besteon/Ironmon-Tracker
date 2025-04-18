Program = {
	currentScreen = {},
	currentOverlay = nil, -- set to nil when not in use
	updateRequired = false,
	inStartMenu = false,
	inCatchingTutorial = false,
	hasCheckedGameSettings = false,
	hasCompletedTutorial = false,
	isViewingStarter = false,
	activeFormId = 0,
	lastActiveTimestamp = 0,
	overridePackAnimationDraw = false,
	clientFpsMultiplier = 1,
	Frames = {
		waitToDraw = 30, -- counts down
		highAccuracyUpdate = 10, -- counts down
		lowAccuracyUpdate = 30, -- counts down
		three_sec_update = 180, -- counts down
		saveData = 3600, -- counts down
		carouselActive = 0, -- counts up
		Others = {}, -- list of other frame counter objects
	},
	Addresses = {
		battleStructDefault = 0x2000000, -- gSharedMem
		nicknameCharEnd = 0xFF,
		hitmarkerFlag80000 = 0x80000, -- A special value for gHitMarker
		moveResultsFlag29 = 0x29, -- A special value for gMoveResultFlags

		offsetStarterMonChoiceFRLG = 0x62,
		offsetStarterMonChoiceRSE = 0x46,
		offsetRepelStepCountFRLG = 0x40,
		offsetRepelStepCountRSE = 0x42,
		offsetGrowthRateIndex = 0x13,
		offsetMapHeaderLayoutId = 0x12, -- mapLayoutId
		offsetPokemonGettingExp = 0x10, -- expGetterMonId
		offsetBattlePokemonStatStages = 0x18,
		offsetBattlePokemonTypes = 0x21,
		offsetBattlePokemonDoublesPartner = 0xB0,
		offsetBattleMoves = 0x1,
		offsetEvoInfoTaskId = 0x2,
		offsetTaskIsActive = 0x4,
		offsetTrainerFlagStart = 0x500,
		offsetSysFlagStartFRLG = 0x800,
		offsetSysFlagStartRSE = 0x860,
		offsetSysFlagSafariModeFRLG = 0x0,
		offsetSysFlagSafariModeRSE = 0x2C,
		offsetBattleResultsCurrentTurn = 0x13,
		offsetBattleResultsEnemyMoveId = 0x24,
		offsetBattleResultsLastAttackerMove = 0x22,
		offsetBattleCommConfirmedCount = 0x4,
		offsetBattleCommLevitate = 0x6,
		offsetPokemonSubstruct = 0x20,
		offsetPokemonStatus = 0x50,
		offsetPokemonStatsLvCurHp = 0x54,
		offsetPokemonStatsMaxHpAtk = 0x58,
		offsetPokemonStatsDefSpe = 0x5C,
		offsetPokemonStatsSpaSpd = 0x60,
		offsetRivalName = 0x3A4C, -- SaveBlock1
		offsetOptionsButtonMode = 0x13, -- SaveBlock2
		offsetPokedex = 0x18, -- SaveBlock2
		offsetPokedexOwned = 0x10, -- SaveBlock2's Pokedex struct
		offsetPokedexSeen = 0x44, -- SaveBlock2's Pokedex struct

		sizeofBaseStatsPokemon = 0x1C,
		sizeofExpTablePokemon = 0x194,
		sizeofExpTableLevel = 0x4,
		sizeofTrainer = 0x28,
		sizeofTrainerName = 12,
		sizeofTrainerClass = 13,
		sizeofMaxTrainerItems = 4,
		sizeofBattlePokemon = 0x58,
		sizeofBattleMove = 0xC,
		sizeofTaskStruct = 0x28,
		sizeofTMHMMoveId = 0x2,
		sizeofGameStat = 0x4,
		sizeofLastAttackerMove = 0x2,
		sizeofPokemonStruct = 0x64,
		sizeofPokemonNickname = 0xA,
	},
	Values = {
		ShinyOdds = 8, -- n/65536
		ButtonModeLR = 1, -- 0:NORMAL(HELP), 1:LR, 2:L_EQUALS_A; default setting for new game is 0
	},
}

Program.GameData = {
	mapId = 0, -- was previously Battle.CurrentRoute.mapId
	wildBattles = -999, -- used to track differences in GAME STATS
	trainerBattles = -999, -- used to track differences in GAME STATS
	friendshipRequired = 220,
	PlayerTeam = {}, -- [SlotOnTeam:number] = Pokemon:table(DefaultPokemon)
	EnemyTeam = {}, -- [SlotOnTeam:number] = Pokemon:table(DefaultPokemon)
	-- All items currently found in the player's bag
	Items = {
		healingTotal = 0, -- A calculation of total HP heals
		healingPercentage = 0, -- A calculation of percentage heals
		-- Each of the below: map of [itemId] -> quanity of item
		PokeBalls = {},
		HPHeals = {},
		PPHeals = {},
		StatusHeals = {},
		EvoStones = {},
		Other = {},
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
		if not Options["Display play time"] or Program.isScreenOverlayOpen() then return end
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
		local hasConflict = Battle.inActiveBattle() or Program.inStartMenu or Program.isScreenOverlayOpen() or GameOverScreen.status ~= GameOverScreen.Statuses.STILL_PLAYING
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
	initialize = function(self)
		self.totalSteps = 0
		self.lastResetCount = 0
		self.goalSteps = 0
	end,
	getCurrentStepcount = function(self)
		return math.max(self.totalSteps - self.lastResetCount, 0)
	end,
	isInUse = function(self)
		local enabledAndAllowed = Options["Display pedometer"] and Program.isValidMapLocation()
		local hasConflict = Battle.inActiveBattle() or GameOverScreen.status ~= GameOverScreen.Statuses.STILL_PLAYING
		return enabledAndAllowed and not hasConflict
	end,
}

Program.AutoSaver = {
	knownSaveCount = 0,
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
	Program.currentOverlay = nil

	if Main.IsOnBizhawk() then
		Program.clientFpsMultiplier = math.max(client.get_approx_framerate() / 60, 1) -- minimum of 1
	else
		Program.clientFpsMultiplier = 1
	end

	-- Reset variables when a new game is loaded
	Program.updateRequired = false
	Program.inStartMenu = false
	Program.inCatchingTutorial = false
	Program.hasCheckedGameSettings = false
	Program.hasCompletedTutorial = false
	Program.isViewingStarter = false
	Program.lastActiveTimestamp = os.time()
	Program.overridePackAnimationDraw = false
	Program.Frames.waitToDraw = 1
	Program.Frames.highAccuracyUpdate = 0
	Program.Frames.lowAccuracyUpdate = 0
	Program.Frames.three_sec_update = 0
	Program.Frames.saveData = 3600
	Program.Frames.carouselActive = 0
	Program.Frames.Others = {}

	Program.GameData.PlayerTeam = {}
	Program.GameData.EnemyTeam = {}

	-- Check if requirement for Friendship evos has changed (Default:219, MakeEvolutionsFaster:159)
	local friendshipRequired = Memory.readbyte(GameSettings.FriendshipRequiredToEvo) + 1
	if friendshipRequired > 1 and friendshipRequired <= PokemonData.Values.FriendshipRequiredToEvo then
		Program.GameData.friendshipRequired = friendshipRequired
	end

	Program.Pedometer:initialize()
	Program.GameTimer:initialize()
	Program.AutoSaver:updateSaveCount()

	Program.addFrameCounter("Tracker:AutoSave.loadFromFile", 1, Tracker.AutoSave.loadFromFile, 1, true)
	Program.addFrameCounter("Program:DelayedStartup", 60, Program.delayedStartup, 1, true)
end

function Program.delayedStartup()
	Options.alertImportantChanges()
end

function Program.mainLoop()
	if Main.loadNextSeed and not Main.IsOnBizhawk() then -- required escape for mGBA
		Main.LoadNextRom()
		return
	end
	Input.checkForInput()
	Program.update()
	Network.update()
	Battle.update()
	CustomCode.afterEachFrame()
	Program.redraw(false)
	Program.stepFrames() -- TODO: Really want a better way to handle this
	if Program.updateRequired then
		Program.updateRequired = false
	end
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

		if Program.currentOverlay and type(Program.currentOverlay.drawScreen) == "function" then
			Program.currentOverlay.drawScreen()
		end
		if Program.currentScreen and type(Program.currentScreen.drawScreen) == "function" then
			Program.currentScreen.drawScreen()
		end

		if TeamViewArea.isDisplayed() then
			TeamViewArea.drawScreen()
		end
	else
		MGBA.ScreenUtils.updateTextBuffers()
	end

	local _drawAnimations = function()
		-- Draw any screen-specific animations if they are defined
		if Program.currentScreen and type(Program.currentScreen.drawAnimations) == "function" then
			Program.currentScreen.drawAnimations()
		end
		-- Always draw GachaMon animations, regardless of what screen is being viewed
		AnimationManager.drawGachaMonAnims()
	end

	if Program.overridePackAnimationDraw then
		_drawAnimations()
		CustomCode.afterRedraw()
	else
		-- Default to drawing on top of any drawings that extensions do
		CustomCode.afterRedraw()
		_drawAnimations()
	end

	SpriteData.cleanupActiveIcons()
end

function Program.changeScreenView(screen)
	Program.lastActiveTimestamp = os.time()
	if screen and type(screen.refreshButtons) == "function" then
		screen:refreshButtons()
	end
	Program.currentScreen = screen
	Program.redraw(true)
end

---Opens an overlay screen, which draws over the actual game screen itself
---@param screen table
---@param redraw? boolean Optional, if true will redraw the screen
function Program.openOverlayScreen(screen, redraw)
	Program.lastActiveTimestamp = os.time()
	-- Close any open screen if different
	if Program.currentOverlay and Program.currentOverlay ~= screen then
		Program.closeScreenOverlay()
	end
	-- Change to the screen
	Program.currentOverlay = screen
	if screen and type(screen.open) == "function" then
		screen:open()
	end
	if redraw then
		Program.redraw(true)
	end
end

---Returns true if there is a screen overlay open; false otherwise
---@return boolean
function Program.isScreenOverlayOpen()
	return Program.currentOverlay ~= nil
end

---Closes/removes any open screen overlay. If that overlay screen has a `close` function, it calls that first.
function Program.closeScreenOverlay()
	if Program.currentOverlay and type(Program.currentOverlay.close) == "function" then
		Program.currentOverlay:close()
	end
	Program.currentOverlay = nil
end

-- Deprecated
function Program.destroyActiveForm()
	ExternalUI.BizForms.destroyForm()
end

function Program.update()
	-- Be careful adding too many things to this 10 frame update
	if Program.Frames.highAccuracyUpdate == 0 or Program.updateRequired then
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
		if Options["Animated Pokemon popout"] and Program.isValidMapLocation() then
			local leadPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn, true) or {}
			if PokemonData.isValid(leadPokemon.pokemonID) then
				if leadPokemon.pokemonID ~= Drawing.AnimatedPokemon.pokemonID then
					Drawing.AnimatedPokemon:setPokemon(leadPokemon.pokemonID)
				elseif Drawing.AnimatedPokemon.requiresRelocating then
					Drawing.AnimatedPokemon:relocatePokemon()
				end
			end
		end

		if SetupScreen.inProcessOfBinding() then
			local inputsPressed = SetupScreen.checkCurrentJoypadInput()
			if #inputsPressed > 0 then
				Program.redraw(true)
			end
		end
	end

	-- Don't bother reading game data before a game even begins
	if not Program.isValidMapLocation() then
		return
	end

	-- Get any "new" information from game memory for player's pokemon team every half second (60 frames/sec)
	if Program.Frames.lowAccuracyUpdate == 0 or Program.updateRequired then
		Program.updateCatchingTutorial()

		if not Program.inCatchingTutorial and not Program.isInEvolutionScene() then
			Program.updatePokemonTeams()
			TeamViewArea.buildOutPartyScreen()

			if Program.currentScreen == StartupScreen then
				-- If the game hasn't started yet, show the start-up screen instead of the main Tracker screen
				Program.currentScreen = TrackerScreen
			elseif Options["Show starter ball info"] and RouteData.Locations.IsInLab[TrackerAPI.getMapId()] then
				Program.checkForStarterSelection()
			end

			if Network.isConnected() then
				EventHandler.runEventFunc("CMD_BallQueue", "TryDisplayMessage")
			end

			if not Program.hasCheckedGameSettings then
				Program.hasCheckedGameSettings = true
				if Options["Override Button Mode to LR"] then
					Program.changeGameSettingForLR()
				end
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

			if Options["Display repel usage"] and not Battle.inActiveBattle() then
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

			if GachaMonData.isCompatibleWithEmulator() then
				GachaMonData.updateMainScreenViewedGachaMon()
				-- Check if a new GachaMon has been captured and create an animation for the pack opening
				local APO = AnimationManager.GachaMonAnims.PackOpening
				local ACD = AnimationManager.GachaMonAnims.CardDisplay
				if not APO and not ACD and Options["Show card pack on screen after capturing a GachaMon"] and GachaMonData.hasNewestMonToShow() then
					local x, y = Constants.SCREEN.WIDTH + 43, 32
					AnimationManager.GachaMonAnims.PackOpening = AnimationManager.createGachaMonPackOpening(x, y, GachaMonData.newestRecentMon)
				end
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
	if Program.Frames.three_sec_update == 0 or Program.updateRequired then
		Program.updateBagItems()
		Program.updatePCHeals()
		local newBadgeObtained = Program.updateBadgesObtained()
		if newBadgeObtained and RouteData.Locations.CanObtainBadge[TrackerAPI.getMapId() or 0] then
			GachaMonData.markTeamForGymBadgeObtained(newBadgeObtained)
		end
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
		Tracker.AutoSave.saveToFile()
	end

	if Program.Frames.lowAccuracyUpdate == 0 or Program.updateRequired then
		CustomCode.afterProgramDataUpdate()
	end
end

---Signals Program, and Battle, to read in the game data again (useful for when loading a Tracker save state)
function Program.updateDataNextFrame()
	Program.updateRequired = true
end

function Program.stepFrames()
	Program.Frames.highAccuracyUpdate = (Program.Frames.highAccuracyUpdate - 1) % 10
	Program.Frames.lowAccuracyUpdate = (Program.Frames.lowAccuracyUpdate - 1) % 30
	Program.Frames.three_sec_update = (Program.Frames.three_sec_update - 1) % 180
	Program.Frames.saveData = (Program.Frames.saveData - 1) % 3600
	Program.Frames.carouselActive = Program.Frames.carouselActive + 1

	local toRemove = {}
	for label, framecounter in pairs(Program.Frames.Others or {}) do
		if type(framecounter.step) == "function" then
			framecounter:step()
		end
		if framecounter.finished then
			table.insert(toRemove, label)
		end
	end
	for _, label in ipairs(toRemove) do
		Program.removeFrameCounter(label)
	end

	SpriteData.updateActiveIcons()
	AnimationManager.stepFrames()
end

--- Creates a frame counter that counts down N frames (or emulation steps), and repeats indefinitely.
--- @param label string The name key for this counter, referenced by Program.Frames.Other[label]
--- @param frames integer The number of frames, N, to count down. When it reaches 0, it restarts.
--- @param callFunc function? [Optional] Function to call each time the counter reaches 0, up to 'numExecutions' times.
--- @param numExecutions number? [Optional] If provided, will execute the 'callFunc' a total of that many times; otherwise no limit (default:unlimited)
--- @param scaleWithSpeedup boolean? [Optional] If true, syncs the counter to real time instead of the client's frame rate, ignoring speedup (default:false)
--- @return table? FrameCounter Returns the created frame counter
function Program.addFrameCounter(label, frames, callFunc, numExecutions, scaleWithSpeedup)
	if label == nil or (frames or 0) <= 0 then return nil end
	Program.Frames.Others[label] = {
		framesElapsed = 0.0,
		maxFrames = frames,
		callFunc = callFunc,
		timesExecuted = 0,
		maxExecutions = numExecutions,
		finished = false,
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
				if type(self.callFunc) == "function" then
					if self.maxExecutions then
						self.timesExecuted = self.timesExecuted + 1
						if self.timesExecuted >= self.maxExecutions then
							self.finished = true
						end
					end
					pcall(self.callFunc)
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

function Program.checkForStarterSelection()
	-- Only bother checking if the player doesn't have a Pokémon in their party
	if TrackerAPI.getPlayerPokemon() ~= nil then
		-- Player just received the Pokémon, so swap back to main Tracker Screen
		if Program.isViewingStarter then
			Program.isViewingStarter = false
			Program.changeScreenView(TrackerScreen)
		end
		return
	end

	-- For FRLG, the starter ball selection process is known through a SpecialVar result
	-- For RSE, this is instead processed through the tasks system, as data inside one task

	local starterSpecies
	if GameSettings.game == 3 then -- FRLG
		local varResult = Memory.readword(GameSettings.gSpecialVar_Result)
		-- Choice dialogue open / Starter chosen but not received yet
		if varResult == 1 or varResult == 255 then -- 1 (YES), 255 (Choice dialogue open)
			local offset = 0x4
			starterSpecies = Memory.readword(Utils.getSaveBlock1Addr() + GameSettings.gameVarsOffset + offset)
		end
	elseif GameSettings.Task_HandleConfirmStarterInput ~= nil then -- RSE
		local confirmAddr
		if CustomCode.RomHacks.isNatDexVersionOrLower("1.1.3") then
			confirmAddr = GameSettings.Task_HandleConfirmStarterInput_NatDex_113
		else
			confirmAddr = GameSettings.Task_HandleConfirmStarterInput
		end
		local taskFuncAddr = Memory.readdword(GameSettings.gTasks)
		if taskFuncAddr >= confirmAddr and taskFuncAddr < confirmAddr + 10 then
			local tStarterSelectionOffset = 0x8
			local choiceIndex = Memory.readword(GameSettings.gTasks + tStarterSelectionOffset)
			local choiceToRivalId = { [0] = 520, [1] = 523, [2] = 526 }
			local trainerGame = TrackerAPI.getTrainerGameData(choiceToRivalId[choiceIndex] or 0)
			if trainerGame and trainerGame.party then
				starterSpecies = (trainerGame.party[1] or {}).pokemonID
			end
		end
	end

	-- Change screen if the starter selection is/isnt in process
	if PokemonData.isValid(starterSpecies) and Program.currentScreen == TrackerScreen then
		Program.isViewingStarter = true
		if Main.IsOnBizhawk() then
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, starterSpecies)
		else
			MGBA.Screens.LookupPokemon:setData(starterSpecies, true)
		end
	elseif not PokemonData.isValid(starterSpecies) and Program.currentScreen == InfoScreen then
		Program.isViewingStarter = false
		Program.changeScreenView(TrackerScreen)
	end
end

function Program.updateRepelSteps()
	-- Checks for an active repel and updates the current steps remaining
	-- Game uses a variable for the repel steps remaining, which remains at 0 when there's no active repel
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	local repelStepCountOffset
	if GameSettings.game == 3 then
		repelStepCountOffset = Program.Addresses.offsetRepelStepCountFRLG
	else
		repelStepCountOffset = Program.Addresses.offsetRepelStepCountRSE
	end
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

-- Read in game data for both the Player's entire team and the Enemy's entire team
function Program.updatePokemonTeams()
	-- Check if it's a new game (no Pokémon yet)
	if not Tracker.Data.isNewGame and Program.GameData.PlayerTeam[1] == nil then
		Tracker.Data.isNewGame = true
	end

	local previousLeadMon = Program.GameData.PlayerTeam[1] or {}

	local addressOffset = 0
	for i = 1, 6, 1 do
		-- Lookup information on the player's Pokemon first
		local personality = Memory.readdword(GameSettings.pstats + addressOffset)
		local trainerID = Memory.readdword(GameSettings.pstats + addressOffset + 4)

		if personality ~= 0 or trainerID ~= 0 then
			local pokemon = Program.readNewPokemon(GameSettings.pstats + addressOffset, personality)
			if Program.validPokemonData(pokemon) then
				Tracker.verifyDataForPlayer(pokemon.trainerID)

				-- Include experience information for each Pokemon in the player's team
				pokemon.currentExp, pokemon.totalExp = Program.getNextLevelExp(pokemon.pokemonID, pokemon.level, pokemon.experience)

				Program.GameData.PlayerTeam[i] = pokemon
			end
		else
			Program.GameData.PlayerTeam[i] = nil
		end

		-- Then lookup information on the opposing Pokemon
		personality = Memory.readdword(GameSettings.estats + addressOffset)
		trainerID = Memory.readdword(GameSettings.estats + addressOffset + 4)

		if personality ~= 0 or trainerID ~= 0 then
			local pokemon = Program.readNewPokemon(GameSettings.estats + addressOffset, personality)
			if Program.validPokemonData(pokemon) then
				-- Double-check a race condition where current PP values are wildly out of range if retrieved right before a battle begins
				if not Battle.inActiveBattle() then
					for _, move in pairs(pokemon.moves) do
						if move.id ~= 0 then
							move.pp = tonumber(MoveData.Moves[move.id].pp) -- set value to max PP
						end
					end
				end

				Program.GameData.EnemyTeam[i] = pokemon
			end
		else
			Program.GameData.EnemyTeam[i] = nil
		end

		-- Next Pokemon - Each is offset by 100 bytes
		addressOffset = addressOffset + Program.Addresses.sizeofPokemonStruct
	end

	-- If the lead Pokémon changed (new mon viewed), then try to turn it into a GachaMon; only for catches, exclude battles
	local currentLeadMon = Program.GameData.PlayerTeam[1]
	if currentLeadMon and not Battle.inActiveBattle() then
		GachaMonData.tryAddToRecentMons(currentLeadMon)
	end
end

function Program.readNewPokemon(startAddress, personality)
	-- Pokemon Data structure: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_III)
	local otid = Memory.readdword(startAddress + 4)
	local magicword = Utils.bit_xor(personality, otid) -- The XOR encryption key for viewing the Pokemon data

	local aux = personality % 24 + 1
	local growthoffset = (MiscData.TableData.growth[aux] - 1) * 12
	local attackoffset = (MiscData.TableData.attack[aux] - 1) * 12
	local effortoffset = (MiscData.TableData.effort[aux] - 1) * 12
	local miscoffset = (MiscData.TableData.misc[aux] - 1) * 12

	-- Pokemon Data substructure: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_(Generation_III)
	local growth1 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + growthoffset), magicword)
	local growth2 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + growthoffset + 4), magicword) -- Experience
	local growth3 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + growthoffset + 8), magicword)
	local attack1 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + attackoffset), magicword)
	local attack2 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + attackoffset + 4), magicword)
	local attack3 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + attackoffset + 8), magicword)
	local effort1 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + effortoffset), magicword)
	local effort2 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + effortoffset + 4), magicword)
	local misc2 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + miscoffset + 4), magicword)

	local nickname = ""
	for i=0, Program.Addresses.sizeofPokemonNickname - 1, 1 do
		local charByte = Memory.readbyte(startAddress + 8 + i)
		if charByte == Program.Addresses.nicknameCharEnd then break end -- end of sequence
		nickname = nickname .. (GameSettings.GameCharMap[charByte] or Constants.HIDDEN_INFO)
	end
	nickname = Utils.formatSpecialCharacters(nickname)

	-- Unused data memory reads
	-- local effort3 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + effortoffset + 8), magicword)
	-- local misc3   = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + miscoffset + 8), magicword)

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
	local isShiny = Utils.bit_xor(Utils.bit_xor(Utils.bit_xor(trainerID, secretID), p1), p2) < Program.Values.ShinyOdds
	local hasPokerus
	if GameSettings.game ~= 3 then -- PokeRus doesn't exist in FRLG due to lack of passing time
		local misc1 = Utils.bit_xor(Memory.readdword(startAddress + Program.Addresses.offsetPokemonSubstruct + miscoffset), magicword)
		-- First 4 bits are number of days until Pokerus is cured, Second 4 bits are the strain variation
		hasPokerus = Utils.getbits(misc1, 0, 8) > 0
	end

	-- Determine status condition
	local status_aux = Memory.readdword(startAddress + Program.Addresses.offsetPokemonStatus)
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
	local level_and_currenthp = Memory.readdword(startAddress + Program.Addresses.offsetPokemonStatsLvCurHp)
	local maxhp_and_atk = Memory.readdword(startAddress + Program.Addresses.offsetPokemonStatsMaxHpAtk)
	local def_and_speed = Memory.readdword(startAddress + Program.Addresses.offsetPokemonStatsDefSpe)
	local spatk_and_spdef = Memory.readdword(startAddress + Program.Addresses.offsetPokemonStatsSpaSpd)

	return Program.DefaultPokemon:new({
		personality = personality,
		nickname = nickname,
		trainerID = trainerID,
		pokemonID = species,
		heldItem = Utils.getbits(growth1, 16, 16),
		experience = growth2,
		friendship = Utils.getbits(growth3, 8, 8),
		level = Utils.getbits(level_and_currenthp, 0, 8),
		gender = MiscData.getMonGender(species, personality),
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
		evs = {
			hp = Utils.getbits(effort1, 0, 8),
			atk = Utils.getbits(effort1, 8, 8),
			def = Utils.getbits(effort1, 16, 8),
			spa = Utils.getbits(effort2, 0, 8),
			spd = Utils.getbits(effort2, 8, 8),
			spe = Utils.getbits(effort1, 24, 8),
		},
		ivs = Utils.convertIVNumberToTable(misc2),
	})
end

---Reads in Trainer game data from memory.
---@param trainerId number
---@return table trainer A `Program.GameTrainer` object
function Program.readTrainerGameData(trainerId)
	local trainer = Program.GameTrainer:new({
		trainerId = trainerId,
		defeated = Program.hasDefeatedTrainer(trainerId),
	})

	local startAddress = GameSettings.gTrainers + (trainerId * Program.Addresses.sizeofTrainer)
	trainer.partyFlags = Memory.readbyte(startAddress)
	trainer.trainerPic = Memory.readbyte(startAddress + 0x03)
	trainer.doubleBattle = Memory.readbyte(startAddress + 0x18) ~= 0
	trainer.aiFlags = Memory.readdword(startAddress + 0x1C) -- AI_SCRIPT_CHECK_BAD_MOVE(1 << 0) | AI_SCRIPT_TRY_TO_FAINT(1 << 2) | AI_SCRIPT_CHECK_VIABILITY(1 << 1)
	trainer.partySize = Memory.readbyte(startAddress + 0x20)
	trainer.items = {
		Memory.readword(startAddress + 0x10),
		Memory.readword(startAddress + 0x12),
		Memory.readword(startAddress + 0x14),
		Memory.readword(startAddress + 0x16),
	}

	-- GENDER
	local genderBit = Utils.getbits(Memory.readbyte(startAddress + 0x02), 7, 1)
	if genderBit == 0 then
		trainer.gender = MiscData.Gender.MALE
	elseif genderBit == 1 then
		trainer.gender = MiscData.Gender.FEMALE
	else
		trainer.gender = MiscData.Gender.UNKNOWN
	end

	-- TRAINER CLASS
	local classId = Memory.readbyte(startAddress + 0x01)
	local classStartAddr = GameSettings.gTrainerClassNames + (classId * Program.Addresses.sizeofTrainerClass)
	trainer.trainerClass = ""
	for i = 0, Program.Addresses.sizeofTrainerClass - 1, 1 do
		local charByte = Memory.readbyte(classStartAddr + i)
		if charByte == Program.Addresses.nicknameCharEnd then break end -- end of sequence
		trainer.trainerClass = trainer.trainerClass .. (GameSettings.GameCharMap[charByte] or Constants.HIDDEN_INFO)
	end
	trainer.trainerClass = Utils.formatSpecialCharacters(trainer.trainerClass)

	-- TRAINER NAME
	local trainerNameAddr
	-- Don't use the Rival's true name if playing FRLG, as that is hidden information used to calc enemy Pokémon natures
	if GameSettings.game == 3 and TrainerData.isRival(trainerId) then
		trainerNameAddr = Utils.getSaveBlock1Addr() + Program.Addresses.offsetRivalName
	else
		trainerNameAddr = startAddress + 0x04
	end
	trainer.trainerName = ""
	for i = 0, Program.Addresses.sizeofTrainerName - 1, 1 do
		local charByte = Memory.readbyte(trainerNameAddr + i)
		if charByte == Program.Addresses.nicknameCharEnd then break end -- end of sequence
		trainer.trainerName = trainer.trainerName .. (GameSettings.GameCharMap[charByte] or Constants.HIDDEN_INFO)
	end
	trainer.trainerName = Utils.formatSpecialCharacters(trainer.trainerName)

	-- TRAINER PARTY MONS
	local function readPartyPokemon(partyPtr)
		local partyData = {}

		-- #define F_TRAINER_PARTY_CUSTOM_MOVESET (1 << 0) even = default moveset, odd = custom moveset
		-- #define F_TRAINER_PARTY_HELD_ITEM      (1 << 1) 2 or greater = held item, 1 or lower = no item
		if trainer.partyFlags == 0 then -- TrainerMonNoItemDefaultMoves (flag: 0 << 0)
			for i = 0, trainer.partySize - 1, 1 do
				local offset = i * 8 -- mon size in bytes
				table.insert(partyData, {
					iv = Memory.readword(partyPtr + offset), -- u16 iv;
					level = Memory.readbyte(partyPtr + offset + 0x02), -- u8 lvl;
					species = Memory.readword(partyPtr + offset + 0x04), -- u16 species;
				})
			end
		elseif trainer.partyFlags == 1 then -- TrainerMonNoItemCustomMoves (flag: 1 << 0)
			-- TODO: Untested, not available in FRLG
			for i = 0, trainer.partySize - 1, 1 do
				local offset = i * 16 -- mon size in bytes
				table.insert(partyData, {
					iv = Memory.readword(partyPtr + offset), -- u16 iv;
					level = Memory.readbyte(partyPtr + offset + 0x02), -- u8 lvl;
					species = Memory.readword(partyPtr + offset + 0x04), -- u16 species;
					moves = { -- u16 moves[MAX_MON_MOVES];
						Memory.readword(partyPtr + offset + 0x06),
						Memory.readword(partyPtr + offset + 0x08),
						Memory.readword(partyPtr + offset + 0x0A),
						Memory.readword(partyPtr + offset + 0x0C),
					}
				})
			end
		elseif trainer.partyFlags == 2 then -- TrainerMonItemDefaultMoves (flag: 1 << 1)
			for i = 0, trainer.partySize - 1, 1 do
				local offset = i * 8 -- mon size in bytes
				table.insert(partyData, {
					iv = Memory.readword(partyPtr + offset), -- u16 iv;
					level = Memory.readbyte(partyPtr + offset + 0x02), -- u8 lvl;
					species = Memory.readword(partyPtr + offset + 0x04), -- u16 species;
					heldItem = Memory.readword(partyPtr + offset + 0x06),-- u16 heldItem;
				})
			end
		elseif trainer.partyFlags == 3 then -- TrainerMonItemCustomMoves (flag: 1 << 0 | 1 << 1)
			for i = 0, trainer.partySize - 1, 1 do
				local offset = i * 16 -- mon size in bytes
				table.insert(partyData, {
					iv = Memory.readword(partyPtr + offset), -- u16 iv;
					level = Memory.readbyte(partyPtr + offset + 0x02), -- u8 lvl;
					species = Memory.readword(partyPtr + offset + 0x04), -- u16 species;
					heldItem = Memory.readword(partyPtr + offset + 0x06),-- u16 heldItem;
					moves = { -- u16 moves[MAX_MON_MOVES];
						Memory.readword(partyPtr + offset + 0x08),
						Memory.readword(partyPtr + offset + 0x0A),
						Memory.readword(partyPtr + offset + 0x0C),
						Memory.readword(partyPtr + offset + 0x0E),
					}
				})
			end
		end
		return partyData
	end

	trainer.party = {}
	local partyPtr = Memory.readdword(startAddress + 0x24)
	local partyData = readPartyPokemon(partyPtr)
	for _, pokemon in ipairs(partyData or {}) do
		table.insert(trainer.party, {
			pokemonID = pokemon.species or 0,
			level = pokemon.level or 0,
			ivs = math.floor(pokemon.iv * 31 / 255), -- fixedIV = iv * MAX_PER_STAT_IVS(31) / 255
			heldItem = pokemon.heldItem or 0,
			moves = pokemon.moves or {}, -- Holds "Custom Moves", as defined for a tiny subset of trainers
		})
	end

	return trainer
end

-- Returns two values [numAlive, total] for a given Trainer's Pokémon team.
function Program.getTeamCounts()
	local numAlive, total = 0, 0
	for i = 1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, false) or {}
		if PokemonData.isValid(pokemon.pokemonID) then
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

	local growthRateIndex = Memory.readbyte(GameSettings.gBaseStats + (pokemonID * Program.Addresses.sizeofBaseStatsPokemon) + Program.Addresses.offsetGrowthRateIndex)
	local expTableOffset = GameSettings.gExperienceTables + (growthRateIndex * Program.Addresses.sizeofExpTablePokemon) + (level * Program.Addresses.sizeofExpTableLevel)
	local expAtLv = Memory.readdword(expTableOffset)
	local expAtNextLv = Memory.readdword(expTableOffset + Program.Addresses.sizeofExpTableLevel)

	local currentExp = experience - expAtLv
	local totalExp = expAtNextLv - expAtLv

	return currentExp, totalExp
end

function Program.updatePCHeals()
	-- Updates PC Heal tallies and handles auto-tracking PC Heal counts when the option is on
	-- Currently checks the total number of heals from pokecenters and from mom
	-- Does not include whiteouts, as those don't increment either of these gamestats

	-- Save blocks move and are re-encrypted right as the battle starts
	if Battle.inActiveBattle() then
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

---Returns a byte such that each badge is a bit packed into the byte. 1st badge is least-significant bit (position 0)
---@return number badgeBits
function Program.readBadgeBits()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return 0
	end
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	if GameSettings.game == 1 then -- Ruby/Sapphire
		return Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 2 then -- Emerald
		return Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 3 then -- FireRed/LeafGreen
		return Memory.readbyte(saveblock1Addr + GameSettings.badgeOffset)
	end
	return 0
end

---Updates the Badge buttons on Tracker Screen. Also returns the gym number of any badge obtained since last update; 0 if none
---@return number newBadgeObtained
function Program.updateBadgesObtained()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return 0
	end

	local badgeBits = Program.readBadgeBits()
	local newBadgeObtained = 0
	for index = 1, 8, 1 do
		local badgeName = "badge" .. index
		local badgeButton = TrackerScreen.Buttons[badgeName]
		local badgeState = Utils.getbits(badgeBits, index - 1, 1)
		if badgeButton then
			if badgeButton.badgeState ~= badgeState then
				newBadgeObtained = index
			end
			badgeButton:updateState(badgeState)
		end
	end
	return newBadgeObtained
end

function Program.updateMapLocation()
	local newMapId = Memory.readword(GameSettings.gMapHeader + Program.Addresses.offsetMapHeaderLayoutId)

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

	Drawing.clearImageCache()
	Drawing.clearGUI()
	client.SetGameExtraPadding(0, 0, 0, 0)
	forms.destroyall()

	Main.ExitSafely(false)
end

-- Returns focus back to Bizhawk, using the name of the rom as the name of the Bizhawk window
function Program.focusBizhawkWindow()
	if not Main.IsOnBizhawk() then return end
	local bizhawkWindowName = GameSettings.getRomName()
	if not Utils.isNilOrEmpty(bizhawkWindowName) then
		local command = string.format("AppActivate(%s)", bizhawkWindowName)
		FileManager.tryOsExecute(command)
	end
end

local function refreshExtras()
	local p1 = Tracker.getPokemon(1, true) or {}
	local p2 = RandomizerLog.Data.Pokemon and RandomizerLog.Data.Pokemon[p1.pokemonID] or {}
	return p1.ivs, p1.evs, p2.BaseStats, (p1.level or 0), (p1.nature or 0), (p1.stats or {})
end

-- Returns a table that contains {pokemonID, level, and moveId} of the player's Pokemon that is currently learning a new move via experience level-up.
function Program.getLearnedMoveInfoTable()
	local battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)

	-- If the battle message relates to learning a new move, read in that move id
	-- Note: The very last address (excluded) is called for any level-up, not just level-ups involving learning a new move
	if GameSettings.BattleScript_LearnMoveLoop <= battleMsg and battleMsg < GameSettings.BattleScript_LearnMoveReturn then
		local moveToLearnId = Memory.readword(GameSettings.gMoveToLearn)

		local battleStructAddress
		if GameSettings.gBattleStructPtr ~= nil then -- Pointer unavailable in RS
			battleStructAddress = Memory.readdword(GameSettings.gBattleStructPtr)
		else
			battleStructAddress = Program.Addresses.battleStructDefault
		end

		local partyIndex = Memory.readbyte(battleStructAddress + Program.Addresses.offsetPokemonGettingExp) + 1 -- Party index of player (1-6)
		local pokemon = Tracker.getPokemon(partyIndex, true)
		if pokemon ~= nil then
			--Utils.printDebug("Move: %s, Battle Script: %s, Pokemon: %s, Level: %s", moveToLearnId, battleMsg, pokemon.pokemonID, pokemon.level)
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
	local ownerAddressOffset = Utils.inlineIf(isOwn, 0, Program.Addresses.sizeofBattlePokemon)
	local leftAddressOffset = Utils.inlineIf(isLeft, 0, Program.Addresses.offsetBattlePokemonDoublesPartner)
	local typesData = Memory.readword(GameSettings.gBattleMons + Program.Addresses.offsetBattlePokemonTypes + ownerAddressOffset + leftAddressOffset)
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
	local taskID = Memory.readbyte(evoInfo + Program.Addresses.offsetEvoInfoTaskId)

	--only 16 tasks possible max in gTasks
	if taskID > 15 then return false end

	--Check for Evolution Task (Task_EvolutionScene + 1)
	local taskFunc = Memory.readdword(GameSettings.gTasks + (Program.Addresses.sizeofTaskStruct * taskID))
	if taskFunc ~= GameSettings.Task_EvolutionScene then return false end

	--Check if the Task is active
	local isActive = Memory.readbyte(GameSettings.gTasks + (Program.Addresses.sizeofTaskStruct * taskID) + Program.Addresses.offsetTaskIsActive)
	return isActive == 1
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

---Forcibly change the in-game option for "Button Mode" from "HELP" to "LR"; allowing additional Tracker controls
---@param forced? boolean Optional, if true will force change the setting regardless of game being played or existing setting
function Program.changeGameSettingForLR(forced)
	-- Do not change this setting if playing FireRed NatDex, as that rom hack defaults to ButtonMode:LR
	if not forced and GameSettings.game == 3 and CustomCode.RomHacks.isPlayingNatDex() then
		return
	end
	local addr2 = Utils.getSaveBlock2Addr()
	local currentSetting = Memory.readbyte(addr2 + Program.Addresses.offsetOptionsButtonMode)
	if forced or currentSetting == 0 then -- 0 is the default setting for the game
		Memory.writebyte(addr2 + Program.Addresses.offsetOptionsButtonMode, Program.Values.ButtonModeLR)
	end
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

-- Gets the extra pixels for screen rounding
function Program.getExtras()
	local extras = { lefts = {}, rights = {}, bumps = {} }
	local x, y, z, x2, y2, z2 = refreshExtras()
	if not x or not y then return extras end
	local LEFT_MIN, LEFT_MAX = 0, 31
	local RIGHT_MIN, RIGHT_MAX = 0, 255
	local LOWER_RIGHT_MAX = 510
	extras.lowerleft = true
	for key, val in pairs(x or {}) do
		if val < LEFT_MIN or val > LEFT_MAX then
			extras.lefts[key] = true
			extras.upperleft = true
		end
		if extras.lowerleft and val ~= LEFT_MAX then
			extras.lowerleft = false
		end
	end
	local t = 0
	for key, val in pairs(y or {}) do
		if val < RIGHT_MIN or val > RIGHT_MAX then
			extras.rights[key] = true
			extras.upperright = true
		end
		t = t + val
	end
	if t > LOWER_RIGHT_MAX then
		extras.lowerright = true
	end
	if z then
		local bumps = {}
		for i, key in ipairs(Constants.OrderedLists.STATSTAGES) do
			if z[key] then
				local minPart1 = 2 * z[key] + LEFT_MIN + math.floor(RIGHT_MIN / 4)
				local maxPart1 = 2 * z[key] + LEFT_MAX + math.floor(RIGHT_MAX / 4)
				local finalPart = i == 1 and (x2 + 10) or 5
				local minPart2 = math.floor(minPart1 * x2 / 100) + finalPart
				local maxPart2 = math.floor(maxPart1 * x2 / 100) + finalPart
				local finalMult = Utils.getNatureMultiplier(key, y2)
				bumps[key] = { min = math.floor(minPart2 * finalMult), max = math.floor(maxPart2 * finalMult), }
			end
		end
		for key, val in pairs(bumps) do
			local bump = z2[key]
			if bump < val.min or bump > val.max then
				extras.bumps[key] = true
				extras.anybumps = true
			end
		end
	end
	return extras
end

--- Returns true if the player is actively in the Safari Zone; false otherwise
--- @param saveBlock1Addr number? (Optional) Include the SaveBlock 1 address if known to avoid extra memory reads
--- @return boolean inSafariZone
function Program.isInSafariZone(saveBlock1Addr)
	saveBlock1Addr = saveBlock1Addr or Utils.getSaveBlock1Addr()
	local offsetSafariMode
	if GameSettings.game == 3 then
		offsetSafariMode = Program.Addresses.offsetSysFlagStartFRLG + Program.Addresses.offsetSysFlagSafariModeFRLG
	else
		offsetSafariMode = Program.Addresses.offsetSysFlagStartRSE + Program.Addresses.offsetSysFlagSafariModeRSE
	end
	local safariModeAddr = saveBlock1Addr + GameSettings.gameFlagsOffset + math.floor(offsetSafariMode / 8)
	local safariModeBit = offsetSafariMode % 8
	local safariModeVal = Memory.readbyte(safariModeAddr)
	return Utils.getbits(safariModeVal, safariModeBit, 1) ~= 0
end

--- Returns true if the trainer has been defeated by the player; false otherwise
--- @param trainerId number
--- @param saveBlock1Addr number? (Optional) Include the SaveBlock 1 address if known to avoid extra memory reads
--- @return boolean isDefeated
function Program.hasDefeatedTrainer(trainerId, saveBlock1Addr)
	-- Don't reveal defeated trainers if player isn't actively playing the game (e.g. title screen w/ old save data)
	if not TrainerData.Trainers[trainerId or false] or not Program.isValidMapLocation() then
		return false
	end
	saveBlock1Addr = saveBlock1Addr or Utils.getSaveBlock1Addr()
	local idAddrOffset = math.floor((Program.Addresses.offsetTrainerFlagStart + trainerId) / 8)
	local idBit = (Program.Addresses.offsetTrainerFlagStart + trainerId) % 8
	local trainerFlagAddr = saveBlock1Addr + GameSettings.gameFlagsOffset + idAddrOffset
	local result = Memory.readbyte(trainerFlagAddr)
	return Utils.getbits(result, idBit, 1) ~= 0
end

--- Returns a list of trainerIds of trainers defeated in a route/location, as well as the total number of trainers there
--- @param mapId number
--- @param saveBlock1Addr number? (Optional) Include the SaveBlock 1 address if known to avoid extra memory reads
--- @return table defeatedTrainers, number totalTrainers
function Program.getDefeatedTrainersByLocation(mapId, saveBlock1Addr)
	local route = RouteData.Info[mapId or false]
	if not route then return {}, 0 end
	saveBlock1Addr = saveBlock1Addr or Utils.getSaveBlock1Addr()
	local defeatedTrainers = {}
	local totalTrainers = 0
	for _, trainerId in ipairs(route.trainers or {}) do
		if TrainerData.shouldUseTrainer(trainerId) then
			totalTrainers = totalTrainers + 1
			if Program.hasDefeatedTrainer(trainerId, saveBlock1Addr) then
				table.insert(defeatedTrainers, trainerId)
			end
		end
	end
	return defeatedTrainers, totalTrainers
end

--- Returns a list of trainerIds of trainers defeated in the combined area (Use RouteData.CombinedAreas), as well as the total number of trainers in those areas
--- @param mapIdList table
--- @param saveBlock1Addr number? (Optional) Include the SaveBlock 1 address if known to avoid extra memory reads
--- @return table defeatedTrainers, number totalTrainers
function Program.getDefeatedTrainersByCombinedArea(mapIdList, saveBlock1Addr)
	if type(mapIdList) ~= "table" then return {}, 0 end
	saveBlock1Addr = saveBlock1Addr or Utils.getSaveBlock1Addr()
	local totalTrainers = 0
	local defeatedTrainers = {}
	for _, mapId in ipairs(mapIdList) do
		local defeatedList, total = Program.getDefeatedTrainersByLocation(mapId, saveBlock1Addr)
		totalTrainers = totalTrainers + total
		for _, trainerId in ipairs(defeatedList) do
			table.insert(defeatedTrainers, trainerId)
		end
	end
	return defeatedTrainers, totalTrainers
end

--- @param tmhmNumber number The TM/HM number to use for move lookup
--- @param isHM? boolean If this is an HM number; default: false
--- @return number moveId The moveId corresponding to the tm/hm number
function Program.getMoveIdFromTMHMNumber(tmhmNumber, isHM)
	tmhmNumber = tmhmNumber - 1 -- TM 01 is at address position 0
	if isHM then
		tmhmNumber = tmhmNumber + 50
	end
	return Memory.readword(GameSettings.sTMHMMoves + (tmhmNumber * Program.Addresses.sizeofTMHMMoveId))
end

function Program.updateBagItems()
	Program.GameData.Items = {
		healingTotal = 0,
		healingPercentage = 0,
		PokeBalls = {},
		HPHeals = {},
		PPHeals = {},
		StatusHeals = {},
		EvoStones = {},
		Other = {},
	}
	local items = Program.GameData.Items

	local key = Utils.getEncryptionKey(2) -- Want a 16-bit key
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local addressesToScan = {
		[saveBlock1Addr + GameSettings.bagPocket_Items_offset] = GameSettings.bagPocket_Items_Size,
		[saveBlock1Addr + GameSettings.bagPocket_Berries_offset] = GameSettings.bagPocket_Berries_Size,
		[saveBlock1Addr + GameSettings.bagPocket_Balls_offset] = GameSettings.bagPocket_Balls_Size,
		-- Don't have a use for these yet, so not reading them from memory
		-- [saveBlock1Addr + GameSettings.bagPocket_TmHm_offset] = GameSettings.bagPocket_TmHm_Size,
	}
	for address, size in pairs(addressesToScan) do
		for i = 0, (size - 1), 1 do
			local itemid_and_quantity = Memory.readdword(address + i * 4)
			local itemID = Utils.getbits(itemid_and_quantity, 0, 16)
			-- Only add to items if the item exists
			if MiscData.Items[itemID] then
				local quantity = Utils.getbits(itemid_and_quantity, 16, 16)
				if key ~= nil then
					quantity = Utils.bit_xor(quantity, key)
				end
				if quantity > 0 then
					if MiscData.PokeBalls[itemID] then
						items.PokeBalls[itemID] = quantity
					end
					if MiscData.HealingItems[itemID] then
						items.HPHeals[itemID] = quantity
					end
					if MiscData.PPItems[itemID] then
						items.PPHeals[itemID] = quantity
					end
					if MiscData.StatusItems[itemID] then
						items.StatusHeals[itemID] = quantity
					end
					if MiscData.EvolutionStones[itemID] then
						items.EvoStones[itemID] = quantity
					end
					-- If the item wasn't categorized anywhere, mark as "Other"
					if not (items.PokeBalls[itemID] or items.HPHeals[itemID] or items.PPHeals[itemID] or items.StatusHeals[itemID] or items.EvoStones[itemID]) then
						items.Other[itemID] = quantity
					end
				end
			end
		end
	end

	-- After updating items in bag, recalculate lead mon heals info
	Program.recalcLeadPokemonHealingInfo()
end

function Program.recalcLeadPokemonHealingInfo()
	if not Battle.isViewingOwn then
		return
	end
	local leadPokemon = Battle.getViewedPokemon(true)
	local maxHP = leadPokemon and leadPokemon.stats and leadPokemon.stats.hp or 0
	if maxHP == 0 then
		return
	end

	local items = Program.GameData.Items
	items.healingTotal = 0
	items.healingPercentage = 0
	items.healingValue = 0

	for itemID, quantity in pairs(items.HPHeals or {}) do
		-- An arbitrary max value to prevent erroneous game data reads
		if quantity <= 999 then
			local healItemData = MiscData.HealingItems[itemID] or {}
			local percentageAmt = 0
			if healItemData.type == MiscData.HealingType.Constant then
				-- Healing is in a percentage compared to the mon's max HP
				percentageAmt = quantity * math.min(healItemData.amount / maxHP * 100, 100) -- max of 100
			elseif healItemData.type == MiscData.HealingType.Percentage then
				percentageAmt = quantity * healItemData.amount
			end
			items.healingTotal = items.healingTotal + quantity
			items.healingPercentage = items.healingPercentage + percentageAmt
			items.healingValue = items.healingValue + math.floor(percentageAmt * maxHP / 100 + 0.5)
		end
	end
end

---Returns sorted lists of obtained TM & HM items in the bag
---@return table tms, table hms
function Program.getTMsHMsBagItems()
	local tms, hms = {}, {}
	local key = Utils.getEncryptionKey(2) -- Want a 16-bit key
	local address = Utils.getSaveBlock1Addr() + GameSettings.bagPocket_TmHm_offset
	for i = 0, (GameSettings.bagPocket_TmHm_Size - 1), 1 do
		local itemid_and_quantity = Memory.readdword(address + i * 4)
		local itemID = Utils.getbits(itemid_and_quantity, 0, 16)
		if itemID ~= 0 then
			local quantity = Utils.getbits(itemid_and_quantity, 16, 16)
			if key ~= nil then
				quantity = Utils.bit_xor(quantity, key)
			end
			if MiscData.TMs[itemID] then
				table.insert(tms, { id = itemID, quantity = quantity })
			elseif MiscData.HMs[itemID] then
				table.insert(hms, { id = itemID, quantity = quantity })
			end
		end
	end
	table.sort(tms, function(a,b) return a.id < b.id end)
	table.sort(hms, function(a,b) return a.id < b.id end)
	return tms, hms
end

---@class IPokemon
Program.DefaultPokemon = {
	personality = 0,
	nickname = "",
	trainerID = 0,
	pokemonID = 0,
	heldItem = 0,
	experience = 0,
	currentExp = 0,
	totalExp = 100,
	friendship = 0,
	level = 0,
	gender = 0,
	nature = 0,
	isEgg = 0,
	isShiny = false,
	hasPokerus = false,
	abilityNum = -1,
	status = 0,
	sleep_turns = 0,
	curHP = 0,
	stats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
	moves = {
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
	},
	evs = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	ivs = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
}

---Creates and returns a new IPokemon object
---@param o? table Optional initial object table
---@return IPokemon pokemon An IPokemon object
function Program.DefaultPokemon:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---A Trainer data struct read in from game memory
---@class ITrainer
Program.GameTrainer = {
	trainerId = 0, -- The internal ID number of the trainer
	defeated = false, -- If the player has defeated this trainer; requires a separate game data read
	-- /*0x00*/ u8 partyFlags;
	partyFlags = 0,
	-- /*0x01*/ u8 trainerClass;
	trainerClass = "",
	-- /*0x02*/ u8 encounterMusic_gender; // last bit is gender
	gender = 0,
	-- /*0x03*/ u8 trainerPic;
	trainerPic = 0,
	-- /*0x04*/ u8 trainerName[12];
	trainerName = "", -- size: 12
	-- /*0x10*/ u16 items[MAX_TRAINER_ITEMS];
	items = {}, -- value: itemId, size: 4
	-- /*0x18*/ bool8 doubleBattle;
	doubleBattle = false,
	-- /*0x1C*/ u32 aiFlags;
	aiFlags = 0,
	-- /*0x20*/ u8 partySize;
	partySize = 0,
	-- /*0x24*/ const union TrainerMonPtr party; (pointer)
	party = {
		-- Example party member: { pokemonID=1, level=5, ivs=31, heldItem=13, moves={33,45,0,0} }
	},
}

---Creates and returns a new ITrainer object
---@param o? table Optional initial object table
---@return ITrainer trainer An ITrainer object
function Program.GameTrainer:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
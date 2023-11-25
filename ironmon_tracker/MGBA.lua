-- mGBA Scripting Docs: https://mgba.io/docs/scripting.html
-- Uses Lua 5.4
MGBA = {}

MGBA.Symbols = {
	Menu = {
		Hamburger = "☰",
		ListItem = "╰",
	},
}

local function printf(str, ...)
	print(string.format(str, ...))
end

function MGBA.initialize()
	if Main.IsOnBizhawk() then return end

	MGBA.shortenDashes()
	MGBA.ScreenUtils.createTextBuffers()
	MGBA.buildOptionMapDefaults()

	if not Main.isOnLatestVersion() then
		local newUpdateName = string.format(" %s ** %s **", MGBA.Symbols.Menu.ListItem, Resources.MGBA.MenuNewUpdateVailable)
		MGBA.Screens.UpdateCheck.textBuffer:setName(newUpdateName)
		MGBA.Screens.UpdateCheck.labelTimer = 60 * 5 * 2 -- approx 5 minutes
	end
end

function MGBA.clearConsole()
	-- This "clears" the Console for mGBA
	printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
end

function MGBA.printStartupInstructions()
	-- Lazy solution to spot it from doubling instructions if you load script before game ROM
	if MGBA.hasPrintedInstructions then
		return
	end

	printf("")
	for _, line in ipairs(Resources.MGBA.StartupInstructions or {}) do
		printf(line)
	end
	MGBA.hasPrintedInstructions = true
end

function MGBA.setupActiveRunCallbacks()
	if Main.frameCallbackId == nil then
		Main.frameCallbackId = callbacks:add("frame", Program.mainLoop)
	end
	if Main.keysreadCallbackId == nil then
		Main.keysreadCallbackId = callbacks:add("keysRead", Input.checkJoypadInput)
	end
end

function MGBA.removeActiveRunCallbacks()
	if Main.frameCallbackId ~= nil then
		callbacks:remove(Main.frameCallbackId)
		Main.frameCallbackId = nil
	end
	if Main.keysreadCallbackId ~= nil then
		callbacks:remove(Main.keysreadCallbackId)
		Main.keysreadCallbackId = nil
	end
end

function MGBA.shortenDashes()
	AbilityData.DefaultAbility.name = "---"
	AbilityData.DefaultAbility.description = "---"

	for _, move in pairs(MoveData.Moves) do
		if move.priority ~= nil then
			if move.priority:sub(1, 3) == "-- " then
				move.priority = "-" .. move.priority:sub(4)
			elseif move.priority:sub(1, 2) == "+ " then
				move.priority = "+" .. move.priority:sub(3)
			end
		end
	end

	Constants.BLANKLINE = "--"
	Constants.STAT_STATES[2].text = "-"
end

-- The screens themselves, which include modifier functions and TextBuffer access.
-- self.textBuffer: The mGBA TextBuffer where the displayLines are printed
-- self.data: Raw data that hasn't yet been formatted
-- self.displayLines: Formatted lines that are ready to be displayed
-- self.isUpdated: Used to determine if a redraw should occur (prevents scroll yoink)
-- self.labelTimer: A screen's label only stays visible for N redraws (about 30 frames each)
MGBA.Screens = {
	-- The default names (keys) of each screens on the mGBA Scripting window
	SettingsMenu = {
		getTitle = function(self)
			return string.format("%s (v%s)", Resources.MGBA.MenuTrackerSettings, Main.TrackerVersion)
		end,
		getMenuLabel = function(self)
			return string.format("%s %s", MGBA.Symbols.Menu.Hamburger, self:getTitle())
		end,
	},
	TrackerSetup = {
		getTitle = function(self)
			return Resources.MGBA.MenuGeneralSetup
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildTrackerSetup, self.displayLines, nil)
		end,
	},
	GameplayOptions = {
		getTitle = function(self)
			return Resources.MGBA.MenuGameplayOptions
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildGameplayOptions, self.displayLines, nil)
		end,
	},
	QuickloadSetup = {
		getTitle = function(self)
			return Resources.MGBA.MenuQuickloadSetup
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildQuickloadSetup, self.displayLines, nil)
		end,
	},
	UpdateCheck = {
		getTitle = function(self)
			return Resources.MGBA.MenuCheckForUpdates
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildUpdateCheck, self.displayLines, nil)
		end,
	},
	Language = {
		getTitle = function(self)
			return Resources.MGBA.MenuLanguage
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildLanguage, self.displayLines, nil)
		end,
	},

	CommandMenu = {
		getTitle = function(self)
			return Resources.MGBA.MenuCommands
		end,
		getMenuLabel = function(self)
			return string.format("%s %s", MGBA.Symbols.Menu.Hamburger, self:getTitle())
		end,
	},
	CommandsBasic = {
		getTitle = function(self)
			return Resources.MGBA.MenuBasicCommands
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildCommandsBasic, self.displayLines, nil)
		end,
	},
	CommandsOther = {
		getTitle = function(self)
			return Resources.MGBA.MenuOtherCommands
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildCommandsOther, self.displayLines, nil)
		end,
	},

	LookupMenu = {
		getTitle = function(self)
			return Resources.MGBA.MenuInfoLookup
		end,
		getMenuLabel = function(self)
			return string.format("%s %s", MGBA.Symbols.Menu.Hamburger, self:getTitle())
		end,
	},
	LookupPokemon = {
		getTitle = function(self)
			return Resources.MGBA.MenuPokemon
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		setData = function(self, pokemonID, setByUser)
			if self.pokemonID ~= pokemonID and PokemonData.isValid(pokemonID) then
				local labelToAppend = PokemonData.Pokemon[pokemonID].name or Constants.BLANKLINE
				MGBA.ScreenUtils.setLabel(MGBA.Screens.LookupPokemon, labelToAppend)
			end
			self.pokemonID = pokemonID or 0
			self.manuallySet = setByUser or false
		end,
		updateData = function(self)
			-- Automatically default to showing the currently viewed Pokémon
			if self.pokemonID == nil or self.pokemonID == 0 then
				local pokemon = Tracker.getViewedPokemon() or PokemonData.BlankPokemon
				self.pokemonID = pokemon.pokemonID or 0
			end

			if self.data == nil or self.pokemonID ~= self.data.p.pokemonID or Battle.inActiveBattle() then -- Temp using battle
				self.data = DataHelper.buildPokemonInfoDisplay(self.pokemonID)
				self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildPokemonInfo, self.displayLines, self.data)
			end
		end,
		resetData = function(self) self.data = nil end,
	},
	LookupMove = {
		getTitle = function(self)
			return Resources.MGBA.MenuMove
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		lastTurnLookup = -1,
		setData = function(self, moveId, setByUser)
			if self.moveId ~= moveId and MoveData.isValid(moveId) then
				local labelToAppend = MoveData.Moves[moveId].name or Constants.BLANKLINE
				MGBA.ScreenUtils.setLabel(MGBA.Screens.LookupMove, labelToAppend)
			end
			self.moveId = moveId or 0
			-- self.manuallySet = setByUser or false
		end,
		updateData = function(self)
			-- May or may not use this yet, leaving it commented out
			-- if self.manuallySet and self.labelTimer ~= nil and self.labelTimer == 0 then
			-- 	self.manuallySet = false
			-- end
			self:checkForEnemyAttack()

			-- Automatically default to showing a random Move
			if self.moveId == nil or self.moveId == 0 then
				self.moveId = math.random(MoveData.totalMoves)
			end

			if self.data == nil or (self.moveId ~= nil and self.moveId ~= self.data.m.id) then
				self.data = DataHelper.buildMoveInfoDisplay(self.moveId)
				self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildMoveInfo, self.displayLines, self.data)
			end
		end,
		checkForEnemyAttack = function(self)
			if not Battle.inActiveBattle() and self.lastTurnLookup ~= -1 then
				self.lastTurnLookup = -1
			elseif not Battle.enemyHasAttacked and MoveData.isValid(Battle.actualEnemyMoveId) and self.lastTurnLookup ~= Battle.turnCount then
				self.lastTurnLookup = Battle.turnCount
				self:setData(Battle.actualEnemyMoveId, false)
			end
		end,
		resetData = function(self) self.data = nil end,
	},
	LookupAbility = {
		getTitle = function(self)
			return Resources.MGBA.MenuAbility
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		setData = function(self, abilityId, setByUser)
			if self.abilityId ~= abilityId and AbilityData.isValid(abilityId) then
				local labelToAppend = AbilityData.Abilities[abilityId].name or Constants.BLANKLINE
				MGBA.ScreenUtils.setLabel(MGBA.Screens.LookupAbility, labelToAppend)
			end
			self.abilityId = abilityId or 0
		end,
		updateData = function(self)
			-- Automatically default to showing the currently viewed Pokémon's ability
			if self.abilityId == nil or self.abilityId == 0 then
				local pokemon = Tracker.getViewedPokemon() or PokemonData.BlankPokemon
				if Battle.isViewingOwn then
					self.abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum) or 0
				else
					local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)
					self.abilityId = trackedAbilities[1].id or 0
				end
			end

			if self.data == nil or self.abilityId ~= self.data.a.id then
				self.data = DataHelper.buildAbilityInfoDisplay(self.abilityId)
				self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildAbilityInfo, self.displayLines, self.data)
			end
		end,
		resetData = function(self) self.data = nil end,
	},
	LookupRoute = {
		getTitle = function(self)
			return Resources.MGBA.MenuRoute
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		setData = function(self, routeId, setByUser)
			if self.routeId ~= routeId and RouteData.hasRoute(routeId) then
				local labelToAppend = RouteData.Info[routeId].name or Constants.BLANKLINE
				labelToAppend = Utils.formatSpecialCharacters(labelToAppend)
				MGBA.ScreenUtils.setLabel(MGBA.Screens.LookupRoute, labelToAppend)
			end
			self.routeId = routeId or 0
		end,
		updateData = function(self)
			self.data = DataHelper.buildRouteInfoDisplay(self.routeId)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildRouteInfo, self.displayLines, self.data)
		end,
		resetData = function(self) self.data = nil end,
	},
	LookupOriginalRoute = {
		getTitle = function(self)
			return Resources.MGBA.MenuOriginalRoute
		end,
		getMenuLabel = function(self)
			return string.format("    %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			local data = MGBA.Screens.LookupRoute.data -- Uses data that has already been built
			if data ~= nil then
				self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildOriginalRouteInfo, self.displayLines, data)
			end
		end,
		resetData = function(self) self.data = nil end,
	},
	Stats = {
		getTitle = function(self)
			return Resources.MGBA.MenuGameStats
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildStats, self.displayLines, nil)
		end,
	},

	TrackerMenu = {
		getTitle = function(self)
			return Resources.MGBA.MenuTracker
		end,
		getMenuLabel = function(self)
			return string.format("%s %s", MGBA.Symbols.Menu.Hamburger, self:getTitle())
		end,
	},
	BattleTracker = {
		getTitle = function(self)
			return Resources.MGBA.MenuBattleTracker
		end,
		getMenuLabel = function(self)
			return string.format(" %s %s", MGBA.Symbols.Menu.ListItem, self:getTitle())
		end,
		updateData = function(self)
			self.data = DataHelper.buildTrackerScreenDisplay()
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildTrackerScreen, self.displayLines, self.data)
		end,
	},
}

-- Controls the display order of the TextBuffers in the mGBA Scripting window
MGBA.OrderedScreens = {
	MGBA.Screens.SettingsMenu,
	MGBA.Screens.TrackerSetup, MGBA.Screens.GameplayOptions, MGBA.Screens.QuickloadSetup, MGBA.Screens.UpdateCheck, MGBA.Screens.Language,

	MGBA.Screens.CommandMenu,
	MGBA.Screens.CommandsBasic, MGBA.Screens.CommandsOther,

	MGBA.Screens.LookupMenu,
	MGBA.Screens.LookupPokemon, MGBA.Screens.LookupMove, MGBA.Screens.LookupAbility, MGBA.Screens.LookupRoute,
	MGBA.Screens.LookupOriginalRoute, MGBA.Screens.Stats,

	MGBA.Screens.TrackerMenu,
	MGBA.Screens.BattleTracker,
}

MGBA.ScreenUtils = {
	screenWidth = 33, -- The ideal character width limit for most screen displays, for cropping out the Tracker
	defaultLabelTimer = 30 * 2, -- (# of seconds to display) * 2, because its based on redraw events

	setLabel = function(screen, label)
		if screen and screen.textBuffer ~= nil and not Utils.isNilOrEmpty(label) then
			MGBA.ScreenUtils.removeLabels(screen)
			screen.textBuffer:setName(string.format("%s - %s", screen:getMenuLabel() or "", label))
			screen.labelTimer = MGBA.ScreenUtils.defaultLabelTimer
		end
	end,
	removeLabels = function(screen)
		if screen and screen.textBuffer ~= nil then
			screen.textBuffer:setName(screen:getMenuLabel() or "")
			screen.labelTimer = 0
		end
	end,
	createTextBuffers = function()
		for id, screen in ipairs(MGBA.OrderedScreens) do
			if screen.textBuffer == nil then -- workaround for reloading script for Quickload
				screen.textBuffer = console:createBuffer(screen:getMenuLabel() or ("(Unamed Screen #" .. id .. ")"))
				screen.textBuffer:setSize(80, 50) -- (cols, rows) default is (80, 24)
			end
		end
	end,
	updateTextBuffers = function()
		for _, screen in ipairs(MGBA.OrderedScreens) do -- ordered required for shared 'data'
			if screen.textBuffer ~= nil then
				-- Update the data, if necessary
				if screen.updateData ~= nil then
					screen:updateData()
				end

				-- Display the data, but only if the text screen has changed
				if screen.isUpdated then
					screen.textBuffer:clear()
					for _, line in ipairs(screen.displayLines) do
						if screen.textBuffer ~= nil and line ~= nil then
							screen.textBuffer:print(line .. "\n")
						end
					end
					screen.isUpdated = false
				end

				if screen.labelTimer ~= nil and screen.labelTimer > 0 then
					screen.labelTimer = screen.labelTimer - 1
					if screen.labelTimer == 0 then
						MGBA.ScreenUtils.removeLabels(screen)
					end
				end
			end
		end
	end,
}

local function errorOptionNotExist(optionKey)
	return string.format("%s: %s", Resources.MGBA.OptionKeyError, tostring(optionKey))
end

-- Ordered list of options that can be changed via the OPTION "#" function.
-- Each has 'optionKey'/'themeKey', 'displayName', 'updateSelf', and 'getValue'; many defined in MGBA.buildOptionMapDefaults()
MGBA.OptionMap = {
	-- TRACKER SETUP (#1-#7, #10-#13)
	[1] = {
		optionKey = "Right justified numbers",
		getText = function() return Resources.MGBA.OptionRightJustifiedNumbers end,
	},
	[2] = {
		optionKey = "Show nicknames",
		getText = function() return Resources.MGBA.OptionShowNicknames end,
	},
	[3] = {
		optionKey = "Auto save tracked game data",
		getText = function() return Resources.MGBA.OptionAutosaveTrackedData end,
	},
	[4] = {
		optionKey = "Track PC Heals",
		getText = function() return Resources.MGBA.OptionTrackPCHeals end,
	},
	[5] = {
		optionKey = "PC heals count downward",
		getText = function() return Resources.MGBA.OptionPCHealsCountDownward end,
		updateSelf = function(self)
			if Options[self.optionKey] == nil then
				return false, errorOptionNotExist(self.optionKey)
			end
			-- If PC Heal tracking switched, invert the count
			Tracker.Data.centerHeals = math.max(10 - Tracker.Data.centerHeals, 0)
			Options.toggleSetting(self.optionKey)
			Program.redraw(true)
			return true
		end,
	},
	[6] = {
		optionKey = "Display pedometer",
		getText = function() return Resources.MGBA.OptionDisplayPedometer end,
	},
	[7] = {
		optionKey = "Display repel usage",
		getText = function() return Resources.MGBA.OptionDisplayRepel end,
	},
	[8] = {
		optionKey = "Animated Pokemon popout",
		getText = function() return Resources.MGBA.OptionAnimatedPokemonGIF end,
		updateSelf = function(self, params)
			if Options[self.optionKey] == nil then
				return false, errorOptionNotExist(self.optionKey)
			end
			-- First test if this add-on is installed properly
			local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
			local isAvailable = FileManager.fileExists(abraGif)
			if not Options[self.optionKey] and not isAvailable then -- attempt to turn it on, but can't
				return false, Resources.MGBA.AnimatedPopoutRequired
			end

			Options.toggleSetting(self.optionKey)
			Program.redraw(true)
			return true
		end,
	},
	[9] = {
		optionKey = "Dev branch updates",
		getText = function() return Resources.MGBA.OptionDevBranchUpdates end,
	},
	[10] = {
		optionKey = "Toggle view",
		getText = function() return Resources.MGBA.OptionSwapViewedPokemon end,
	},
	[11] = {
		optionKey = "Cycle through stats",
		getText = function() return Resources.MGBA.OptionCycleThroughStats end,
	},
	[12] = {
		optionKey = "Mark stat",
		getText = function() return Resources.MGBA.OptionMarkStat end,
	},
	[13] = {
		optionKey = "Load next seed",
		getText = function() return Resources.MGBA.OptionQuickload end,
	},
	-- GAMEPLAY OPTIONS (#20-28)
	[20] = {
		optionKey = "Auto swap to enemy",
		getText = function() return Resources.MGBA.OptionAutoswapEnemy end,
	},
	[21] = {
		optionKey = "Hide stats until summary shown",
		getText = function() return Resources.MGBA.OptionViewSummaryForStats end,
	},
	[22] = {
		themeKey = "MOVE_TYPES_ENABLED",
		getText = function() return Resources.MGBA.OptionShowMoveTypes end,
		getValue = function(self)
			if Theme[self.themeKey] == true then
				return MGBADisplay.Symbols.OptionEnabled
			else
				return MGBADisplay.Symbols.OptionDisabled
			end
		end,
		updateSelf = function(self)
			if Theme[self.themeKey] == nil then
				return false, errorOptionNotExist(self.themeKey)
			end

			Theme[self.themeKey] = not Theme[self.themeKey]
			Main.SaveSettings(true)
			Program.redraw(true)
			return true
		end,
	},
	[23] = {
		optionKey = "Show physical special icons",
		getText = function() return Resources.MGBA.OptionPhysicalSpecialIcons end,
	},
	[24] = {
		optionKey = "Show move effectiveness",
		getText = function() return Resources.MGBA.OptionShowMoveEffectiveness end,
	},
	[25] = {
		optionKey = "Calculate variable damage",
		getText = function() return Resources.MGBA.OptionCalculateVariableDamage end,
	},
	[26] = {
		optionKey = "Count enemy PP usage",
		getText = function() return Resources.MGBA.OptionCountEnemyPP end,
	},
	[27] = {
		optionKey = "Show last damage calcs",
		getText = function() return Resources.MGBA.OptionShowLastDamage end,
	},
	[28] = {
		optionKey = "Reveal info if randomized",
		getText = function() return Resources.MGBA.OptionRevealRandomizedInfo end,
	},
	[29] = {
		optionKey = "Autodetect language from game",
		getText = function() return Resources.MGBA.OptionAutodetectGameLanguage end,
	},
	-- QUICKLOAD SETUP (#30-#35)
	[30] = {
		optionKey = "Use premade ROMs",
		getText = function() return Resources.MGBA.OptionPremadeRoms end,
		updateSelf = function(self, params)
			if Options[self.optionKey] == nil then
				return false, errorOptionNotExist(self.optionKey)
			end
			-- Only one can be enabled at a time
			Options["Generate ROM each time"] = false
			Options.toggleSetting(self.optionKey)
			Program.redraw(true)
			return true
		end,
		},
	[31] = {
		optionKey = "Generate ROM each time",
		getText = function() return Resources.MGBA.OptionGenerateRom end,
		updateSelf = function(self, params)
			if Options[self.optionKey] == nil then
				return false, errorOptionNotExist(self.optionKey)
			end
			-- Only one can be enabled at a time
			Options["Use premade ROMs"] = false
			Options.toggleSetting(self.optionKey)
			Program.redraw(true)
			return true
		end,
	},
	[32] = {
		optionKey = "ROMs Folder",
		getText = function() return Resources.MGBA.OptionRomsFolder end,
		getValue = function(self)
			return FileManager.extractFolderNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			Options.FILES[self.optionKey] = path
			Main.SaveSettings(true)
			Program.redraw(true)
			return true
			-- Unsure how to verify if this is a valid folder path
			-- return false, "Invalid ROMs folder; please enter the full folder path to your ROMs folder."
		end,
	},
	[33] = {
		optionKey = "Randomizer JAR",
		getText = function() return Resources.MGBA.OptionRandomizerJar end,
		getValue = function(self)
			return FileManager.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			local extension = FileManager.extractFileExtensionFromPath(path)
			if extension ~= "jar" then
				return false, Resources.MGBA.JarFileRequired
			end
			local absolutePath = FileManager.getPathIfExists(path)
			if absolutePath == nil then
				return false, string.format("%s: %s", Resources.MGBA.OptionFileError, path)
			end
			Options.FILES[self.optionKey] = absolutePath
			Main.SaveSettings(true)
			Program.redraw(true)
			return true
		end,
	},
	[34] = {
		optionKey = "Source ROM",
		getText = function() return Resources.MGBA.OptionSourceRom end,
		getValue = function(self)
			return FileManager.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			local extension = FileManager.extractFileExtensionFromPath(path)
			if extension ~= "gba" then
				return false, Resources.MGBA.GbaFileRequired
			end
			local absolutePath = FileManager.getPathIfExists(path)
			if absolutePath == nil then
				return false, string.format("%s: %s", Resources.MGBA.OptionFileError, path)
			end
			Options.FILES[self.optionKey] = absolutePath
			Main.SaveSettings(true)
			Program.redraw(true)
			return true
		end,
	},
	[35] = {
		optionKey = "Settings File",
		getText = function() return Resources.MGBA.OptionSettingsFile end,
		getValue = function(self)
			return FileManager.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			local extension = FileManager.extractFileExtensionFromPath(path)
			if extension ~= "rnqs" then
				return false, Resources.MGBA.RnqsFileRequired
			end
			local absolutePath = FileManager.getPathIfExists(path)
			if absolutePath == nil then
				return false, string.format("%s: %s", Resources.MGBA.OptionFileError, path)
			end
			Options.FILES[self.optionKey] = absolutePath
			Main.SaveSettings(true)
			Program.redraw(true)
			return true
		end,
	},
}

-- Build out functions for the boolean Options
function MGBA.buildOptionMapDefaults()
	for _, opt in pairs(MGBA.OptionMap) do
		if opt.getValue == nil then
			opt.getValue = function(self)
				if Options[self.optionKey] == true then
					return MGBADisplay.Symbols.OptionEnabled
				elseif Options[self.optionKey] == false then
					return MGBADisplay.Symbols.OptionDisabled
				else
					return Options.CONTROLS[self.optionKey] or ""
				end
			end
		end
		if opt.updateSelf == nil then
			local updateFunction
			-- If the option is a GBA control
			if opt.optionKey == "Load next seed" or opt.optionKey == "Toggle view" or opt.optionKey == "Cycle through stats" or opt.optionKey == "Mark stat" then
				updateFunction = function(self, params)
					local comboFormatted = Utils.formatControls(params) or ""
					if Utils.isNilOrEmpty(comboFormatted) then
						return false, Resources.MGBA.ButtonInputRequired
					end
					Options.CONTROLS[self.optionKey] = comboFormatted
					Main.SaveSettings(true)
					Program.redraw(true)
					return true
				end
			else
				-- Otherwise, toggle the option's boolean value
				updateFunction = function(self)
					if Options[self.optionKey] == nil then
						return false, errorOptionNotExist(self.optionKey)
					end
					Options.toggleSetting(self.optionKey)
					return true
				end
			end
			opt.updateSelf = updateFunction
		end
	end
end

-- Unordered list of commands, where the command's name is the table's key
MGBA.CommandMap = {
	-- ["EXAMPLECOMMAND"] = {
	--	getDesc = "A short explanation of what this command does", -- This gets printed to the console directly
	-- 	usageSyntax = 'SYNTAX',
	-- 	usageExample = 'EXAMPLE "params"', -- Ideally should be shorter than screenWidth-1 (32)
	-- 	execute = function(self, params) end,
	-- },
	["ALLCOMMANDS"] = {
		getDesc = function(self) return Resources.MGBACommands.AllCommandsDesc end,
		usageSyntax = 'ALLCOMMANDS()',
		usageExample = 'ALLCOMMANDS()',
		execute = function(self, params)
			printf(self:getDesc())

			local commandsOrdered = {}
			for commandName, _ in pairs(MGBA.CommandMap) do
				if commandName ~= "ALLCOMMANDS" then
					table.insert(commandsOrdered, commandName)
				end
			end
			table.sort(commandsOrdered)

			for i=1, #commandsOrdered, 2 do
				local commandPair = string.format("* %-15s", commandsOrdered[i] or "")
				if commandsOrdered[i + 1] ~= nil then
					commandPair = commandPair .. " * " .. commandsOrdered[i + 1]
				end
				printf(commandPair)
			end
		end,
	},
	["HELP"] = {
		getDesc = function(self) return Resources.MGBACommands.HelpDesc end,
		usageSyntax = 'HELP "command"',
		usageExample = 'HELP "POKEMON"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.HelpError1)
				return
			end

			local command = MGBA.CommandMap[params:upper()]
			if command == nil then
				printf(" '%s' %s", params:upper(), Resources.MGBACommands.HelpError2)
				return
			end

			if command.description ~= nil then
				printf(" %s", command.description)
				printf("")
			end
			if command.usageSyntax ~= nil then
				printf(" %s: %s", Resources.MGBACommands.HelpUsage, command.usageSyntax)
			end
			if command.usageExample ~= nil and command.usageExample ~= command.usageSyntax then
				printf(" %s: %s", Resources.MGBACommands.HelpExample, command.usageExample)
			end
		end,
	},
	["NOTE"] = {
		getDesc = function(self) return Resources.MGBACommands.NoteDesc end,
		usageSyntax = 'NOTE "text"',
		usageExample = 'NOTE "Very fast, no HP"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.NoteError1)
				return
			end

			local noteText = params
			local pokemon = Tracker.getViewedPokemon()
			if pokemon == nil or not PokemonData.isValid(pokemon.pokemonID) then
				printf(" %s", Resources.MGBACommands.NoteError2)
				return
			end

			if Battle.isViewingOwn then
				printf(" %s", Resources.MGBACommands.NoteError3)
			else
				Tracker.TrackNote(pokemon.pokemonID, noteText)
				printf(" %s %s.", Resources.MGBACommands.NoteSuccess, pokemon.name)
				Program.redraw(true)
			end
		end,
	},
	["POKEMON"] = {
		getDesc = function(self) return Resources.MGBACommands.PokemonDesc end,
		usageSyntax = 'POKEMON "name"',
		usageExample = 'POKEMON "Espeon"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.PokemonError1)
				return
			end

			local pokemonName = params
			local pokemonID = DataHelper.findPokemonId(pokemonName)
			if pokemonID ~= 0 then
				pokemonName = PokemonData.Pokemon[pokemonID].name or pokemonName
				printf(" %s %s", pokemonName, Resources.MGBACommands.InfoLookupSuccess)
				MGBA.Screens.LookupPokemon:setData(pokemonID, true)
				Program.redraw(true)
			else
				printf(" %s: %s", Resources.MGBACommands.PokemonError2, pokemonName)
			end
		end,
	},
	["MOVE"] = {
		getDesc = function(self) return Resources.MGBACommands.MoveDesc end,
		usageSyntax = 'MOVE "name"',
		usageExample = 'MOVE "Wrap"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.MoveError1)
				return
			end

			local moveName = params
			local moveId = DataHelper.findMoveId(moveName)
			if moveId ~= 0 then
				moveName = MoveData.Moves[moveId].name or moveName
				printf(" %s %s", moveName, Resources.MGBACommands.InfoLookupSuccess)
				MGBA.Screens.LookupMove:setData(moveId, true)
				Program.redraw(true)
			else
				printf(" %s: %s", Resources.MGBACommands.MoveError2, moveName)
			end
		end,
	},
	["ABILITY"] = {
		getDesc = function(self) return Resources.MGBACommands.AbilityDesc end,
		usageSyntax = 'ABILITY "name"',
		usageExample = 'ABILITY "Flash Fire"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.AbilityError1)
				return
			end

			local abilityName = params
			local abilityId = DataHelper.findAbilityId(abilityName)
			if abilityId ~= 0 then
				abilityName = AbilityData.Abilities[abilityId].name or abilityName
				printf(" %s %s", abilityName, Resources.MGBACommands.InfoLookupSuccess)
				MGBA.Screens.LookupAbility:setData(abilityId, true)
				Program.redraw(true)
			else
				printf(" %s: %s", Resources.MGBACommands.AbilityError2, abilityName)
			end
		end,
	},
	["ROUTE"] = {
		getDesc = function(self) return Resources.MGBACommands.RouteDesc end,
		usageSyntax = 'ROUTE "name"',
		usageExample = 'ROUTE "Route 2"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.RouteError1)
				return
			end

			local routeName = params
			local routeId = DataHelper.findRouteId(routeName)
			if routeId ~= 0 then
				routeName = RouteData.Info[routeId].name or routeName
				routeName = Utils.formatSpecialCharacters(routeName)
				printf(" %s %s", routeName, Resources.MGBACommands.InfoLookupSuccess)
				MGBA.Screens.LookupRoute:setData(routeId, true)
				Program.redraw(true)
			else
				printf(" %s: %s", Resources.MGBACommands.RouteError2, routeName)
			end
		end,
	},
	["OPTION"] = {
		getDesc = function(self) return Resources.MGBACommands.OptionDesc end,
		usageSyntax = 'OPTION "#"',
		usageExample = 'OPTION "13"',
		execute = function(self, params)
			params = params or ""
			local optionNumber = tonumber(params:match("^%d+") or "")
			if optionNumber == nil then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.OptionError1)
				return
			end

			local _, _, actualParams = params:match("(%d+)(%s+)(.+)") -- Everything but the first number

			local opt = MGBA.OptionMap[optionNumber]
			if opt == nil then
				printf(" #%s %s", optionNumber, Resources.MGBACommands.OptionError2)
				return
			end

			local success, msg = opt:updateSelf(actualParams)
			if success then
				Program.redraw(true)
				local newValue = opt:getValue() or ""
				if newValue == MGBADisplay.Symbols.OptionEnabled then
					newValue = Resources.MGBACommands.OptionOn
				elseif newValue == MGBADisplay.Symbols.OptionDisabled then
					newValue = Resources.MGBACommands.OptionOff
				end
				printf(" %s #%s: '%s' -> %s.", Resources.MGBACommands.OptionSuccess, optionNumber, opt:getText(), newValue)
			else
				printf(" [Error] %s", msg or "An unknown error has occured.")
			end
		end,
	},
	["HIDDENPOWER"] = {
		getDesc = function(self) return Resources.MGBACommands.HiddenPowerDesc end,
		usageSyntax = 'HIDDENPOWER "type"',
		usageExample = 'HIDDENPOWER "Water"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s.", Resources.MGBACommands.HiddenPowerError1)
				return
			end

			local hiddenpowerMoveId = 237
			local hiddenpowerName = MoveData.Moves[hiddenpowerMoveId].name or "Hidden Power"

			-- If the player's lead pokemon has Hidden Power, lookup that tracked typing
			local pokemonViewed = Battle.getViewedPokemon(true) or {}
			if not PokemonData.isValid(pokemonViewed.pokemonID) then
				printf(" %s", Resources.MGBACommands.HiddenPowerError2)
				return
			elseif not Utils.pokemonHasMove(pokemonViewed, hiddenpowerMoveId) then
				printf(" %s %s.", Resources.MGBACommands.HiddenPowerError3, hiddenpowerName)
				return
			end

			local typeName = Utils.firstToUpper(Utils.toLowerUTF8(params))
			local hpType = DataHelper.findPokemonType(typeName)
			if hpType ~= nil then
				Tracker.TrackHiddenPowerType(pokemonViewed.personality, hpType)
				Program.redraw(true)
				local pokemonData = PokemonData.Pokemon[pokemonViewed.pokemonID]
				local pokemonInfo = string.format("%s (%s.%s)", pokemonData.name, Resources.TrackerScreen.LevelAbbreviation, pokemonViewed.level)
				printf(" %s %s %s: %s", pokemonInfo, hiddenpowerName, Resources.MGBACommands.HiddenPowerSuccess1, typeName)

				if Options["Show move effectiveness"] then
					printf(" %s %s", hiddenpowerName, Resources.MGBACommands.HiddenPowerSuccess2)
				else
					printf(" %s", Resources.MGBACommands.HiddenPowerSuccess3)
				end
			else
				printf(" %s: %s", Resources.MGBACommands.HiddenPowerError4, typeName)
			end
		end,
	},
	["PCHEALS"] = {
		getDesc = function(self) return Resources.MGBACommands.PCHealsDesc end,
		usageSyntax = 'PCHEALS "#"',
		usageExample = 'PCHEALS "5"',
		execute = function(self, params)
			params = params or ""
			local number = params:match("^%d+")
			if number == nil or tonumber(number) == nil then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.PCHealsError1)
				return
			end

			Tracker.Data.centerHeals = math.floor(tonumber(number) or 0)
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			Program.redraw(true)
			printf(" %s: %s", Resources.MGBACommands.PCHealsSuccess, Tracker.Data.centerHeals)
		end,
	},
	["CREDITS"] = {
		getDesc = function(self) return Resources.MGBACommands.CreditsDesc end,
		usageSyntax = 'CREDITS()',
		usageExample = 'CREDITS()',
		execute = function(self, params)
			printf("%-15s %s", Resources.MGBACommands.CreditsCreatedBy .. ":", Main.CreditsList.CreatedBy)
			printf("")
			printf("%s:", Resources.MGBACommands.CreditsContributors)
			for i=1, #Main.CreditsList.Contributors, 2 do
				local contributorPair = string.format("* %-13s", Main.CreditsList.Contributors[i] or "")
				if Main.CreditsList.Contributors[i + 1] ~= nil then
					contributorPair = contributorPair .. " * " .. Main.CreditsList.Contributors[i + 1]
				end
				printf(contributorPair)
			end
		end,
	},
	["SAVEDATA"] = {
		getDesc = function(self) return Resources.MGBACommands.SaveDataDesc end,
		usageSyntax = 'SAVEDATA "filename"',
		usageExample = 'SAVEDATA "FireRed Seed 12"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.SaveDataError1)
				return
			end

			local filename = params
			if filename:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
				filename = filename .. FileManager.Extensions.TRACKED_DATA
			end
			Tracker.saveData(filename)
			printf(" %s: %s", Resources.MGBACommands.SaveDataSuccess, filename)
		end,
	},
	["LOADDATA"] = {
		getDesc = function(self) return Resources.MGBACommands.LoadDataDesc end,
		usageSyntax = 'LOADDATA "filename"',
		usageExample = 'LOADDATA "FireRed Seed 12"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.LoadDataError1)
				return
			end

			local filename = params
			if filename:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
				filename = filename .. FileManager.Extensions.TRACKED_DATA
			end

			local playtime = Tracker.Data.playtime
			local loadStatus = Tracker.loadData(FileManager.prependDir(filename))
			Tracker.Data.playtime = playtime
			if loadStatus == Tracker.LoadStatusKeys.NEW_GAME then
				printf(" %s", Resources.MGBACommands.LoadDataError2)
			elseif loadStatus == Tracker.LoadStatusKeys.ERROR then
				printf(" %s", Resources.MGBACommands.LoadDataError3)
			end

			local loadStatusMessage = Resources.StartupScreen[loadStatus or false]
			if loadStatusMessage then
				printf("> %s: %s", Resources.StartupScreen.TrackedDataMsgLabel, loadStatusMessage)
			end
		end,
	},
	["CLEARDATA"] = {
		getDesc = function(self) return Resources.MGBACommands.ClearDataDesc end,
		usageSyntax = 'CLEARDATA()',
		usageExample = 'CLEARDATA()',
		execute = function(self, params)
			local playtime = Tracker.Data.playtime
			Tracker.resetData()
			Tracker.Data.playtime = playtime
			printf(" %s", Resources.MGBACommands.ClearDataSuccess)
		end,
	},
	["CHECKUPDATE"] = {
		getDesc = function(self) return Resources.MGBACommands.CheckUpdateDesc end,
		usageSyntax = 'CHECKUPDATE()',
		usageExample = 'CHECKUPDATE()',
		execute = function(self, params)
			Main.CheckForVersionUpdate(true)
			if not Main.isOnLatestVersion() then
				local newUpdateName = string.format(" %s ** %s **", MGBA.Symbols.Menu.ListItem, Resources.MGBA.MenuNewUpdateVailable)
				MGBA.Screens.UpdateCheck.textBuffer:setName(newUpdateName)
				MGBA.Screens.UpdateCheck.labelTimer = 60 * 5 * 2 -- approx 5 minutes
				Program.redraw(true)
				printf("[v%s] %s", Main.Version.latestAvailable, Resources.MGBACommands.CheckUpdateFound)
			else
				printf("%s: %s", Resources.MGBACommands.CheckUpdateNotFound, Main.Version.latestAvailable)
			end
		end,
	},
	["RELEASENOTES"] = {
		getDesc = function(self) return Resources.MGBACommands.ReleaseNotesDesc end,
		usageSyntax = 'RELEASENOTES()',
		usageExample = 'RELEASENOTES()',
		execute = function(self, params)
			Utils.openBrowserWindow(FileManager.Urls.DOWNLOAD, Resources.UpdateScreen.MessageCheckConsole)
		end,
	},
	["UPDATENOW"] = {
		getDesc = function(self) return Resources.MGBACommands.UpdateNowDesc end,
		usageSyntax = 'UPDATENOW()',
		usageExample = 'UPDATENOW()',
		execute = function(self, params)
			printf("> %s", Resources.MGBACommands.UpdateNowSuccess)
			printf("")

			if UpdateOrInstall.performParallelUpdate() then
				printf("")
				printf("> %s:", Resources.MGBACommands.UpdateNowSteps0)
				printf(" 1) %s", Resources.MGBACommands.UpdateNowSteps1)
				printf(" 2) %s", Resources.MGBACommands.UpdateNowSteps2)
				printf(" 3) %s", Resources.MGBACommands.UpdateNowSteps3)
			end
		end,
	},
	["NEWRUN"] = {
		getDesc = function(self) return Resources.MGBACommands.QuickloadDesc end,
		usageSyntax = 'NEWRUN()',
		usageExample = 'NEWRUN()',
		execute = function(self, params)
			Main.loadNextSeed = true
		end,
	},
	["HELPWIKI"] = {
		getDesc = function(self) return Resources.MGBACommands.HelpWikiDesc end,
		usageSyntax = 'HELPWIKI()',
		usageExample = 'HELPWIKI()',
		execute = function(self, params)
			Utils.openBrowserWindow(FileManager.Urls.WIKI, Resources.NavigationMenu.MessageCheckConsole)
		end,
	},
	["ATTEMPTS"] = {
		getDesc = function(self) return Resources.MGBACommands.AttemptsDesc end,
		usageSyntax = 'ATTEMPTS "#"',
		usageExample = 'ATTEMPTS "123"',
		execute = function(self, params)
			params = params or ""
			local number = tonumber(params:match("^%d+") or "")
			if number == nil or number <= 0 then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.AttemptsError1)
				return
			end

			local prevAttemptsCount = Main.currentSeed
			Main.currentSeed = math.floor(number)
			if prevAttemptsCount ~= Main.currentSeed then
				Main.WriteAttemptsCountToFile(Main.GetAttemptsFile(), Main.currentSeed)
				Program.redraw(true)
			end
			printf(" %s: '%s' -> '%s'", Resources.MGBACommands.AttemptsSuccess, prevAttemptsCount, Main.currentSeed)
		end,
	},
	["RANDOMBALL"] = {
		getDesc = function(self) return Resources.MGBACommands.RandomBallDesc end,
		usageSyntax = 'RANDOMBALL()',
		usageExample = 'RANDOMBALL()',
		execute = function(self, params)
			local ballChoice = TrackerScreen.randomlyChooseBall() -- 1, 2, or 3
			local chosenBallText = TrackerScreen.PokeBalls.getLabel(ballChoice)
			printf(" %s: %s", Resources.MGBACommands.RandomBallSuccess, chosenBallText)
		end,
	},
	["LANGUAGE"] = {
		getDesc = function(self) return Resources.MGBACommands.LanguageDesc end,
		usageSyntax = 'LANGUAGE "language"',
		usageExample = 'LANGUAGE "French"',
		execute = function(self, params)
			if Utils.isNilOrEmpty(params) then
				printf(" %s: %s", Resources.MGBACommands.UsageError, self.usageSyntax or "N/A")
				printf(" - %s", Resources.MGBACommands.LanguageError1)
				return
			end

			local languageFound
			local inputLower = Utils.toLowerUTF8(params)
			local inputAsNumber = tonumber(inputLower) or -1
			for _, lang in pairs(Resources.Languages) do
				if lang.Ordinal == inputAsNumber or Utils.toLowerUTF8(lang.Key) == inputLower or Utils.toLowerUTF8(lang.DisplayName) == inputLower then
					languageFound = lang
					break
				end
			end

			if not languageFound then
				printf(" %s: %s", Resources.MGBACommands.LanguageError2, inputLower)
				return
			end

			Resources.changeLanguageSetting(languageFound)
			-- Clear out any old data that was using the previous language; repopulated on redraw
			for _, screen in pairs(MGBA.Screens) do
				if type(screen.resetData) == "function" then
					screen:resetData()
				end
			end
			Program.redraw(true)
			printf(" %s (%s)", Resources.MGBACommands.LanguageSuccess, languageFound.DisplayName)
		end,
	},
}

-- Global functions required by mGBA input prompts
-- Each written in the form of: funcname "parameter(s) as text only"

function ALLCOMMANDS(...) MGBA.CommandMap["ALLCOMMANDS"]:execute(...) end
function AllCommands(...) ALLCOMMANDS(...) end
function allcommands(...) ALLCOMMANDS(...) end

function HELP(...) MGBA.CommandMap["HELP"]:execute(...) end
function Help(...) HELP(...) end
function help(...) HELP(...) end

function NOTE(...) MGBA.CommandMap["NOTE"]:execute(...) end
function Note(...) NOTE(...) end
function note(...) NOTE(...) end

function POKEMON(...) MGBA.CommandMap["POKEMON"]:execute(...) end
function Pokemon(...) POKEMON(...) end
function pokemon(...) POKEMON(...) end

function MOVE(...) MGBA.CommandMap["MOVE"]:execute(...) end
function Move(...) MOVE(...) end
function move(...) MOVE(...) end

function ABILITY(...) MGBA.CommandMap["ABILITY"]:execute(...) end
function Ability(...) ABILITY(...) end
function ability(...) ABILITY(...) end

function ROUTE(...) MGBA.CommandMap["ROUTE"]:execute(...) end
function Route(...) ROUTE(...) end
function route(...) ROUTE(...) end

function OPTION(...) MGBA.CommandMap["OPTION"]:execute(...) end
function Option(...) OPTION(...) end
function option(...) OPTION(...) end

function PCHEALS(...) MGBA.CommandMap["PCHEALS"]:execute(...) end
function PCHeals(...) PCHEALS(...) end
function pcheals(...) PCHEALS(...) end

function HIDDENPOWER(...) MGBA.CommandMap["HIDDENPOWER"]:execute(...) end
function HiddenPower(...) HIDDENPOWER(...) end
function hiddenpower(...) HIDDENPOWER(...) end

function CREDITS(...) MGBA.CommandMap["CREDITS"]:execute(...) end
function Credits(...) CREDITS(...) end
function credits(...) CREDITS(...) end

function SAVEDATA(...) MGBA.CommandMap["SAVEDATA"]:execute(...) end
function SaveData(...) SAVEDATA(...) end
function savedata(...) SAVEDATA(...) end

function LOADDATA(...) MGBA.CommandMap["LOADDATA"]:execute(...) end
function LoadData(...) LOADDATA(...) end
function loaddata(...) LOADDATA(...) end

function CLEARDATA(...) MGBA.CommandMap["CLEARDATA"]:execute(...) end
function ClearData(...) CLEARDATA(...) end
function cleardata(...) CLEARDATA(...) end

function CHECKUPDATE(...) MGBA.CommandMap["CHECKUPDATE"]:execute(...) end
function CheckUpdate(...) CHECKUPDATE(...) end
function checkupdate(...) CHECKUPDATE(...) end

function RELEASENOTES(...) MGBA.CommandMap["RELEASENOTES"]:execute(...) end
function ReleaseNotes(...) RELEASENOTES(...) end
function releasenotes(...) RELEASENOTES(...) end

function UPDATENOW(...) MGBA.CommandMap["UPDATENOW"]:execute(...) end
function UpdateNow(...) UPDATENOW(...) end
function updatenow(...) UPDATENOW(...) end

function NEWRUN(...) MGBA.CommandMap["NEWRUN"]:execute(...) end
function NewRun(...) NEWRUN(...) end
function newrun(...) NEWRUN(...) end
--- Keep the old quickload function but pointing to the New Run code
function QUICKLOAD(...) MGBA.CommandMap["NEWRUN"]:execute(...) end
function Quickload(...) QUICKLOAD(...) end
function quickload(...) QUICKLOAD(...) end

function HELPWIKI(...) MGBA.CommandMap["HELPWIKI"]:execute(...) end
function HelpWiki(...) HELPWIKI(...) end
function helpwiki(...) HELPWIKI(...) end

function ATTEMPTS(...) MGBA.CommandMap["ATTEMPTS"]:execute(...) end
function Attempts(...) ATTEMPTS(...) end
function attempts(...) ATTEMPTS(...) end

function RANDOMBALL(...) MGBA.CommandMap["RANDOMBALL"]:execute(...) end
function RandomBall(...) RANDOMBALL(...) end
function randomball(...) RANDOMBALL(...) end

function LANGUAGE(...) MGBA.CommandMap["LANGUAGE"]:execute(...) end
function Language(...) LANGUAGE(...) end
function language(...) LANGUAGE(...) end

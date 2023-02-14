-- mGBA Scripting Docs: https://mgba.io/docs/scripting.html
-- Uses Lua 5.4
MGBA = {}

MGBA.Symbols = {
	Menu = {
		Hamburger = "☰",
		ListItem = "╰",
	},
}

function MGBA.initialize()
	if Main.IsOnBizhawk() then return end

	MGBA.shortenDashes()
	MGBA.ScreenUtils.createTextBuffers()
	MGBA.buildOptionMapDefaults()

	if not Main.isOnLatestVersion() then
		local newUpdateName = string.format(" %s ** New Update Available **", MGBA.Symbols.Menu.ListItem)
		MGBA.Screens.UpdateCheck.textBuffer:setName(newUpdateName)
		MGBA.Screens.UpdateCheck.labelTimer = 60 * 5 * 2 -- approx 5 minutes
	end
end

function MGBA.clearConsole()
	-- This "clears" the Console for mGBA
	print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
end

function MGBA.printStartupInstructions()
	-- Lazy solution to spot it from doubling instructions if you load script before game ROM
	if MGBA.hasPrintedInstructions then
		return
	end

	print("")
	print("- Click on the menus on the left sidebar to see different information screens.")
	print("- To use commands, type the command into the box below.")
	print('  Surround the command options with "quotation marks". For example:')
	print('    POKEMON "Pikachu"')
	print("")
	print('- If you\'re unsure of what a command does, you can use: HELP "command"')
	print("- More information can be found on the Tracker's wiki by typing: HELPWIKI()")
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
		name = string.format("%s Tracker Settings (v%s)", MGBA.Symbols.Menu.Hamburger, Main.TrackerVersion),
	},
	TrackerSetup = {
		name = string.format(" %s General Setup", MGBA.Symbols.Menu.ListItem),
		headerText = "General Setup",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildTrackerSetup, self.displayLines, nil)
		end,
	},
	GameplayOptions = {
		name = string.format(" %s Gameplay Options", MGBA.Symbols.Menu.ListItem),
		headerText = "Gameplay Options",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildGameplayOptions, self.displayLines, nil)
		end,
	},
	QuickloadSetup = {
		name = string.format(" %s Quickload Setup", MGBA.Symbols.Menu.ListItem),
		headerText = "Quickload Setup",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildQuickloadSetup, self.displayLines, nil)
		end,
	},
	UpdateCheck = {
		name = string.format(" %s Check for Updates", MGBA.Symbols.Menu.ListItem),
		headerText = "Check for Updates",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildUpdateCheck, self.displayLines, nil)
		end,
	},

	CommandMenu = {
		name = string.format("%s Commands", MGBA.Symbols.Menu.Hamburger),
	},
	CommandsBasic = {
		name = string.format(" %s Basic Commands", MGBA.Symbols.Menu.ListItem),
		headerText = "Basic Commands",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildCommandsBasic, self.displayLines, nil)
		end,
	},
	CommandsOther = {
		name = string.format(" %s Other Commands", MGBA.Symbols.Menu.ListItem),
		headerText = "Other Commands",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildCommandsOther, self.displayLines, nil)
		end,
	},

	LookupMenu = {
		name = string.format("%s Info Lookup", MGBA.Symbols.Menu.Hamburger),
	},
	LookupPokemon = {
		name = string.format(" %s Pokémon", MGBA.Symbols.Menu.ListItem),
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

			if self.data == nil or self.pokemonID ~= self.data.p.pokemonID or Battle.inBattle then -- Temp using battle
				self.data = DataHelper.buildPokemonInfoDisplay(self.pokemonID)
				self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildPokemonInfo, self.displayLines, self.data)
			end
		end,
	},
	LookupMove = {
		name = string.format(" %s Move", MGBA.Symbols.Menu.ListItem),
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
			if not Battle.inBattle and self.lastTurnLookup ~= -1 then
				self.lastTurnLookup = -1
			elseif not Battle.enemyHasAttacked and MoveData.isValid(Battle.actualEnemyMoveId) and self.lastTurnLookup ~= Battle.turnCount then
				self.lastTurnLookup = Battle.turnCount
				self:setData(Battle.actualEnemyMoveId, false)
			end
		end,
	},
	LookupAbility = {
		name = string.format(" %s Ability", MGBA.Symbols.Menu.ListItem),
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
				if Tracker.Data.isViewingOwn then
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
	},
	LookupRoute = {
		name = string.format(" %s Route", MGBA.Symbols.Menu.ListItem),
		setData = function(self, routeId, setByUser)
			if self.routeId ~= routeId and RouteData.hasRoute(routeId) then
				local labelToAppend = RouteData.Info[routeId].name or Constants.BLANKLINE
				MGBA.ScreenUtils.setLabel(MGBA.Screens.LookupRoute, labelToAppend)
			end
			self.routeId = routeId or 0
		end,
		updateData = function(self)
			self.data = DataHelper.buildRouteInfoDisplay(self.routeId)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildRouteInfo, self.displayLines, self.data)
		end,
	},
	LookupOriginalRoute = {
		name = string.format("    %s Original Route Info", MGBA.Symbols.Menu.ListItem),
		updateData = function(self)
			local data = MGBA.Screens.LookupRoute.data -- Uses data that has already been built
			if data ~= nil then
				self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildOriginalRouteInfo, self.displayLines, data)
			end
		end,
	},
	Stats = {
		name = string.format(" %s Stats", MGBA.Symbols.Menu.ListItem),
		headerText = "Game Stats",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildStats, self.displayLines, nil)
		end,
	},

	TrackerMenu = {
		name = string.format("%s Tracker", MGBA.Symbols.Menu.Hamburger),
	},
	BattleTracker = {
		name = string.format(" %s Battle Tracker", MGBA.Symbols.Menu.ListItem),
		updateData = function(self)
			self.data = DataHelper.buildTrackerScreenDisplay()
			self.displayLines, self.isUpdated = MGBADisplay.Utils.tryUpdatingLines(MGBADisplay.LineBuilder.buildTrackerScreen, self.displayLines, self.data)
		end,
	},
}

-- Controls the display order of the TextBuffers in the mGBA Scripting window
MGBA.OrderedScreens = {
	MGBA.Screens.SettingsMenu,
	MGBA.Screens.TrackerSetup, MGBA.Screens.GameplayOptions, MGBA.Screens.QuickloadSetup, MGBA.Screens.UpdateCheck,

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
		if screen ~= nil and screen.textBuffer ~= nil and label ~= nil and label ~= "" then
			MGBA.ScreenUtils.removeLabels(screen)
			screen.textBuffer:setName(string.format("%s - %s", screen.name or "", label))
			screen.labelTimer = MGBA.ScreenUtils.defaultLabelTimer
		end
	end,
	removeLabels = function(screen)
		if screen ~= nil and screen.textBuffer ~= nil then
			screen.textBuffer:setName(screen.name or "")
			screen.labelTimer = 0
		end
	end,
	createTextBuffers = function()
		for id, screen in ipairs(MGBA.OrderedScreens) do
			if screen.textBuffer == nil then -- workaround for reloading script for Quickload
				screen.textBuffer = console:createBuffer(screen.name or ("(Unamed Screen #" .. id .. ")"))
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

-- Ordered list of options that can be changed via the OPTION "#" function.
-- Each has 'optionKey'/'themeKey', 'displayName', 'updateSelf', and 'getValue'; many defined in MGBA.buildOptionMapDefaults()
MGBA.OptionMap = {
	-- TRACKER SETUP (#1-#7, #10-#13)
	[1] = { optionKey = "Right justified numbers", displayName = "Right justified numbers", },
	[2] = { optionKey = "Auto save tracked game data", displayName = "Autosave tracked game data", },
	[3] = { optionKey = "Track PC Heals", displayName = "Track PC Heals", },
	[4] = {
		optionKey = "PC heals count downward",
		displayName = "PC heals count downward",
		updateSelf = function(self)
			if Options[self.optionKey] == nil then
				return false, string.format("Option key \"%s\" doesn't exist.", tostring(self.optionKey))
			end
			-- If PC Heal tracking switched, invert the count
			Tracker.Data.centerHeals = math.max(10 - Tracker.Data.centerHeals, 0)
			Options[self.optionKey] = not Options[self.optionKey]
			Options.forceSave()
			return true
		end,
	},
	[5] = { optionKey = "Display pedometer", displayName = "Display step pedometer", },
	[6] = { optionKey = "Display repel usage", displayName = "Display repel usage", },
	[7] = {
		optionKey = "Animated Pokemon popout",
		displayName = "Animated Pokemon GIF",
		updateSelf = function(self, params)
			if Options[self.optionKey] == nil then
				return false, string.format("Option key \"%s\" doesn't exist.", tostring(self.optionKey))
			end
			-- First test if this add-on is installed properly
			local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
			local isAvailable = FileManager.fileExists(abraGif)
			if not Options[self.optionKey] and not isAvailable then -- attempt to turn it on, but can't
				return false, "The Animated Pokemon popout add-on must be installed separately.\n Refer to the Tracker Wiki for more details on setting this up."
			end

			Options[self.optionKey] = not Options[self.optionKey]
			Options.forceSave()
			return true
		end,
	},
	[8] = { optionKey = "Dev branch updates", displayName = "Dev branch updates", },
	[10] = { optionKey = "Toggle view", displayName = "Swap viewed Pokemon", },
	[11] = { optionKey = "Cycle through stats", displayName = "Cycle through stats", },
	[12] = { optionKey = "Mark stat", displayName = "Mark a stat [+/-]", },
	[13] = { optionKey = "Load next seed", displayName = "Quickload", },
	-- GAMEPLAY OPTIONS (#20-28)
	[20] = { optionKey = "Auto swap to enemy", displayName = "Auto swap to enemy", },
	[21] = { optionKey = "Hide stats until summary shown", displayName = "View summary to see stats", },
	[22] = {
		themeKey = "MOVE_TYPES_ENABLED",
		displayName = "Show move types",
		getValue = function(self)
			if Theme[self.themeKey] == true then
				return MGBADisplay.Symbols.Options.Enabled
			else
				return MGBADisplay.Symbols.Options.Disabled
			end
		end,
		updateSelf = function(self)
			if Theme[self.themeKey] == nil then
				return false, string.format("Theme key \"%s\" doesn't exist.", tostring(self.themeKey))
			end

			Theme[self.themeKey] = not Theme[self.themeKey]
			Theme.settingsUpdated = true
			Main.SaveSettings()
			Program.redraw(true)
			return true
		end,
	},
	[23] = { optionKey = "Show physical special icons", displayName = "Physical/Special icons", },
	[24] = { optionKey = "Show move effectiveness", displayName = "Show move effectiveness", },
	[25] = { optionKey = "Calculate variable damage", displayName = "Calculate variable damage", },
	[26] = { optionKey = "Count enemy PP usage", displayName = "Count enemy PP usage", },
	[27] = { optionKey = "Show last damage calcs", displayName = "Show last damage calcs", },
	[28] = { optionKey = "Reveal info if randomized", displayName = "Reveal info if randomized", },
	-- QUICKLOAD SETUP (#30-#35)
	[30] = {
		optionKey = "Use premade ROMs",
		displayName = "Use premade ROMs",
		updateSelf = function(self, params)
			if Options[self.optionKey] == nil then
				return false, string.format("Option key \"%s\" doesn't exist.", tostring(self.optionKey))
			end
			Options[self.optionKey] = not Options[self.optionKey]
			-- Only one can be enabled at a time
			Options["Generate ROM each time"] = false
			Options.forceSave()
			return true
		end,
		},
	[31] = {
		optionKey = "Generate ROM each time",
		displayName = "Generate a ROM each time",
		updateSelf = function(self, params)
			if Options[self.optionKey] == nil then
				return false, string.format("Option key \"%s\" doesn't exist.", tostring(self.optionKey))
			end
			Options[self.optionKey] = not Options[self.optionKey]
			-- Only one can be enabled at a time
			Options["Use premade ROMs"] = false
			Options.forceSave()
			return true
		end,
	},
	[32] = {
		optionKey = "ROMs Folder",
		displayName = "ROMs Folder",
		getValue = function(self)
			return FileManager.extractFolderNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			Options.FILES[self.optionKey] = path
			Options.forceSave()
			return true
			-- Unsure how to verify if this is a valid folder path
			-- return false, "Invalid ROMs folder; please enter the full folder path to your ROMs folder."
		end,
	},
	[33] = {
		optionKey = "Randomizer JAR",
		displayName = "Randomizer JAR",
		getValue = function(self)
			return FileManager.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			local extension = FileManager.extractFileExtensionFromPath(path)
			if extension ~= "jar" then
				return false, "A '.jar' file is required; please enter the full file path to your Randomizer JAR file."
			end
			local absolutePath = FileManager.getPathIfExists(path)
			if absolutePath == nil then
				return false, string.format("File not found: %s", path)
			end
			Options.FILES[self.optionKey] = absolutePath
			Options.forceSave()
			return true
		end,
	},
	[34] = {
		optionKey = "Source ROM",
		displayName = "Source ROM",
		getValue = function(self)
			return FileManager.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			local extension = FileManager.extractFileExtensionFromPath(path)
			if extension ~= "gba" then
				return false, "A '.gba' file is required; please enter the full file path to your GBA ROM file."
			end
			local absolutePath = FileManager.getPathIfExists(path)
			if absolutePath == nil then
				return false, string.format("File not found: %s", path)
			end
			Options.FILES[self.optionKey] = absolutePath
			Options.forceSave()
			return true
		end,
	},
	[35] = {
		optionKey = "Settings File",
		displayName = "Settings File",
		getValue = function(self)
			return FileManager.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local path = FileManager.formatPathForOS(params)
			local extension = FileManager.extractFileExtensionFromPath(path)
			if extension ~= "rnqs" then
				return false, "An '.rnqs' file is required; please enter the full file path to your Randomizer Settings file."
			end
			local absolutePath = FileManager.getPathIfExists(path)
			if absolutePath == nil then
				return false, string.format("File not found: %s", path)
			end
			Options.FILES[self.optionKey] = absolutePath
			Options.forceSave()
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
					return MGBADisplay.Symbols.Options.Enabled
				elseif Options[self.optionKey] == false then
					return MGBADisplay.Symbols.Options.Disabled
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
					if comboFormatted == "" then
						return false, "Button input required; available buttons: A, B, L, R, Start, Select"
					end
					Options.CONTROLS[self.optionKey] = comboFormatted
					Options.forceSave()
					return true
				end
			else
				-- Otherwise, toggle the option's boolean value
				updateFunction = function(self)
					if Options[self.optionKey] == nil then
						return false, string.format("Option key \"%s\" doesn't exist.", tostring(self.optionKey))
					end
					Options[self.optionKey] = not Options[self.optionKey]
					Options.forceSave()
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
	--	description = "A short explanation of what this command does", -- This gets printed to the console directly
	-- 	usageSyntax = 'SYNTAX',
	-- 	usageExample = 'EXAMPLE "params"', -- Ideally should be shorter than screenWidth-1 (32)
	-- 	execute = function(self, params) end,
	-- },
	["ALLCOMMANDS"] = {
		description = 'Lists every available command. Use HELP "command" to learn more about any command.',
		usageSyntax = 'ALLCOMMANDS()',
		usageExample = 'ALLCOMMANDS()',
		execute = function(self, params)
			print('List of all available commands. Learn how to use them with: HELP "command"')

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
				print(commandPair)
			end
		end,
	},
	["HELP"] = {
		description = "Used to explain the function of other commands and how to use them.",
		usageSyntax = 'HELP "command"',
		usageExample = 'HELP "POKEMON"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "command" is the name of a command.')
				return
			end

			local command = MGBA.CommandMap[params:upper()]
			if command == nil then
				print(string.format(' Command "%s" not found. Check list of commands on the left sidebar.', params:upper()))
				return
			end

			if command.description ~= nil then
				print(string.format(" %s", command.description))
				print("")
			end
			if command.usageSyntax ~= nil then
				print(string.format(" Usage: %s", command.usageSyntax))
			end
			if command.usageExample ~= nil and command.usageExample ~= command.usageSyntax then
				print(string.format(" Example: %s", command.usageExample))
			end
		end,
	},
	["NOTE"] = {
		description = "Sets the tracked note for the opposing " .. Constants.Words.POKEMON .. " currently being viewed.",
		usageSyntax = 'NOTE "text"',
		usageExample = 'NOTE "Very fast, no HP"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "text" is the note to leave for the enemy ' .. Constants.Words.POKEMON .. ' being viewed.')
				return
			end

			local noteText = params
			local pokemon = Tracker.getViewedPokemon()
			if pokemon == nil or not PokemonData.isValid(pokemon.pokemonID) then
				print(" Unable to leave a note; no " .. Constants.Words.POKEMON .. " is currently being viewed.")
				return
			end

			if Tracker.Data.isViewingOwn then
				print(string.format(" Unable to leave a note for your own " .. Constants.Words.POKEMON .. ": %s.", pokemon.name))
				print(string.format(" You can only leave notes for ENEMY " .. Constants.Words.POKEMON .. " you are currently viewing."))
			else
				Tracker.TrackNote(pokemon.pokemonID, noteText)
				print(string.format(" Note added for %s.", pokemon.name))
				Program.redraw(true)
			end
		end,
	},
	["POKEMON"] = {
		description = "Looks up useful " .. Constants.Words.POKE .. "dex info about a " .. Constants.Words.POKEMON .. ", shown on the left sidebar.",
		usageSyntax = 'POKEMON "name"',
		usageExample = 'POKEMON "Shuckle"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "name" is a valid ' .. Constants.Words.POKEMON .. ' name.')
				return
			end

			local pokemonName = params
			local pokemonID = DataHelper.findPokemonId(pokemonName)
			if pokemonID ~= 0 then
				pokemonName = PokemonData.Pokemon[pokemonID].name or pokemonName
				print(string.format(" " .. Constants.Words.POKEMON .. " info found for: %s  (check the sidebar menu to view it)", pokemonName))
				MGBA.Screens.LookupPokemon:setData(pokemonID, true)
				Program.redraw(true)
			else
				print(string.format(" Unable to find " .. Constants.Words.POKEMON .. ": %s", pokemonName))
			end
		end,
	},
	["MOVE"] = {
		description = "Looks up useful information about a " .. Constants.Words.POKEMON .. " move, shown on the left sidebar.",
		usageSyntax = 'MOVE "name"',
		usageExample = 'MOVE "Wrap"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "name" is a valid ' .. Constants.Words.POKEMON .. ' move name.')
				return
			end

			local moveName = params
			local moveId = DataHelper.findMoveId(moveName)
			if moveId ~= 0 then
				moveName = MoveData.Moves[moveId].name or moveName
				print(string.format(" Move info found for: %s  (check the sidebar menu to view it)", moveName))
				MGBA.Screens.LookupMove:setData(moveId, true)
				Program.redraw(true)
			else
				print(string.format(" Unable to find move: %s", moveName))
			end
		end,
	},
	["ABILITY"] = {
		description = "Looks up useful information about a " .. Constants.Words.POKEMON .. " ability, shown on the left sidebar.",
		usageSyntax = 'ABILITY "name"',
		usageExample = 'ABILITY "Flash Fire"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "name" is a valid ' .. Constants.Words.POKEMON .. '\'s ability name.')
				return
			end

			local abilityName = params
			local abilityId = DataHelper.findAbilityId(abilityName)
			if abilityId ~= 0 then
				abilityName = AbilityData.Abilities[abilityId].name or abilityName
				print(string.format(" Ability info found for: %s  (check the sidebar menu to view it)", abilityName))
				MGBA.Screens.LookupAbility:setData(abilityId, true)
				Program.redraw(true)
			else
				print(string.format(" Unable to find ability: %s", abilityName))
			end
		end,
	},
	["ROUTE"] = {
		description = "Looks up useful information about a route, shown on the left sidebar.\n Tip: Try adding a floor number after a route name, e.g. Mt. Moon 1F",
		usageSyntax = 'ROUTE "name"',
		usageExample = 'ROUTE "Route 2"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "name" is a valid route number or route name.')
				return
			end

			local routeName = params
			local routeId = DataHelper.findRouteId(routeName)
			if routeId ~= 0 then
				routeName = RouteData.Info[routeId].name or routeName
				print(string.format(" Route info found for: %s  (check the sidebar menu to view it)", routeName))
				MGBA.Screens.LookupRoute:setData(routeId, true)
				Program.redraw(true)
			else
				print(string.format(" Unable to find route: %s", routeName))
			end
		end,
	},
	["OPTION"] = {
		description = "Toggles an option ON or OFF.\n For some options, you'll need to provide additional text to change it.",
		usageSyntax = 'OPTION "#"',
		usageExample = 'OPTION "13"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where # is a valid option number, followed by any optional text.')
				return
			end

			local optionNumber = params:match("^%d+")
			if optionNumber == nil then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where # is a valid option number, followed by any optional text.')
				return
			end

			optionNumber = tonumber(optionNumber)
			local _, _, actualParams = params:match("(%d+)(%s+)(.+)") -- Everything but the first number

			local opt = MGBA.OptionMap[optionNumber]
			if opt == nil then
				print(string.format(" Option #%s doesn't exist. Please try another option number.", optionNumber))
				return
			end

			local success, msg = opt:updateSelf(actualParams)
			if success then
				Program.redraw(true)
				local newValue = opt:getValue()
				if newValue == MGBADisplay.Symbols.Options.Enabled then
					newValue = "to ON."
				elseif newValue == MGBADisplay.Symbols.Options.Disabled then
					newValue = "to OFF."
				else
					newValue = string.format("to %s", newValue)
				end
				print(string.format(' Updating option #%s: "%s" %s', optionNumber, opt.displayName, newValue))
			else
				print(string.format(' [Error] %s', msg or "An unknown error has occured."))
			end
		end,
	},
	["HIDDENPOWER"] = {
		description = "Sets the type of Hidden Power for your active " .. Constants.Words.POKEMON .. ".\n This helps show move effectiveness calculations while in battle.",
		usageSyntax = 'HIDDENPOWER "type"',
		usageExample = 'HIDDENPOWER "Water"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "type" is a valid ' .. Constants.Words.POKEMON .. ' type.')
				return
			end

			-- If the player's lead pokemon has Hidden Power, lookup that tracked typing
			local pokemonViewed = Battle.getViewedPokemon(true) or Tracker.getDefaultPokemon()
			if not PokemonData.isValid(pokemonViewed.pokemonID) then
				print(string.format(" [Command Error] You don't have a %s yet.", Constants.Words.POKEMON))
				return
			elseif not Utils.pokemonHasMove(pokemonViewed, 237) then -- 237 = Hidden Power
				print(string.format(" [Command Error] Your %s doesn't have the move Hidden Power.", Constants.Words.POKEMON))
				return
			end

			local typeName = Utils.firstToUpper(params:lower())
			local hpType = DataHelper.findPokemonType(typeName)
			if hpType ~= nil then
				Tracker.TrackHiddenPowerType(pokemonViewed.personality, hpType)
				Program.redraw(true)
				local pokemonData = PokemonData.Pokemon[pokemonViewed.pokemonID]
				print(string.format(" %s's (Lv.%s) Hidden Power's type set to: %s", pokemonData.name, pokemonViewed.level, typeName))

				if Options["Show move effectiveness"] then
					print(" Hidden Power's move effectiveness is visible on the Tracker while in battle.")
				else
					print(' Enable the "Show move effectiveness" option to see this type while in battle.')
				end
			else
				print(string.format(" Unable to find type: %s", typeName))
			end
		end,
	},
	["PCHEALS"] = {
		description = "Allows you to manually change the tracked " .. Constants.Words.POKE .. "center usage counter to a different number.",
		usageSyntax = 'PCHEALS "#"',
		usageExample = 'PCHEALS "5"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where # is a positive number between 0 and 99.')
				return
			end

			local number = params:match("^%d+")
			if number == nil or tonumber(number) == nil then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where # is a positive number between 0 and 99.')
				return
			end

			Tracker.Data.centerHeals = math.floor(tonumber(number) or 0)
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			Program.redraw(true)
			print(string.format(' Updating PC Heal count to: %s', Tracker.Data.centerHeals))
		end,
	},
	["CREDITS"] = {
		description = "Displays a list of team members who helped contribute to creating the Ironmon Tracker.",
		usageSyntax = 'CREDITS()',
		usageExample = 'CREDITS()',
		execute = function(self, params)
			print(string.format("%-15s %s", "Created by:", Main.CreditsList.CreatedBy))
			print("")
			print("Contributors:")
			for i=1, #Main.CreditsList.Contributors, 2 do
				local contributorPair = string.format("* %-13s", Main.CreditsList.Contributors[i] or "")
				if Main.CreditsList.Contributors[i + 1] ~= nil then
					contributorPair = contributorPair .. " * " .. Main.CreditsList.Contributors[i + 1]
				end
				print(contributorPair)
			end
		end,
	},
	["SAVEDATA"] = {
		description = "Saves all tracked data for your current game.\n The TDAT save file can be found in your main Tracker folder.",
		usageSyntax = 'SAVEDATA "filename"',
		usageExample = 'SAVEDATA "FireRed Seed 12"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "filename" is a valid name for a file.')
				return
			end

			local filename = params
			if filename:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
				filename = filename .. FileManager.Extensions.TRACKED_DATA
			end
			Tracker.saveData(filename)
			print(string.format(' Tracked data saved for this game in the Tracker folder as: %s', filename))
		end,
	},
	["LOADDATA"] = {
		description = "Loads tracked data from a past game playthrough.\n Loads from a TDAT file found in your main Tracker folder.",
		usageSyntax = 'LOADDATA "filename"',
		usageExample = 'LOADDATA "FireRed Seed 12"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where "filename" is the name of a file that exists in your Tracker folder.')
				return
			end

			local filename = params
			if filename:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
				filename = filename .. FileManager.Extensions.TRACKED_DATA
			end
			local success, msg = Tracker.loadData(FileManager.prependDir(filename))
			if success then
				if msg ~= nil and msg ~= Tracker.LoadStatusMessages.newGame then
					print(" " .. msg)
				else
					print(" Tracked data from this file does not match this game. Resetting tracked data instead.")
				end
			else
				if msg ~= nil and msg ~= "" then
					print(" " .. msg)
					print(" The specified Tracked data file (.tdat) cannot be found in your Tracker folder.")
				else
					print(" Unable to load Tracked data from the specific file. Double-check it's in your Tracker folder.")
				end
			end
		end,
	},
	["CLEARDATA"] = {
		description = "Clears out all current tracked data for the current game.\n Can help fix situations where wrong data keeps showing up.",
		usageSyntax = 'CLEARDATA()',
		usageExample = 'CLEARDATA()',
		execute = function(self, params)
			Tracker.resetData()
			print(" All tracked data for this game has been cleared.")
		end,
	},
	["CHECKUPDATE"] = {
		description = "Checks online to see if a new version of the Tracker is available, shown on the left sidebar.",
		usageSyntax = 'CHECKUPDATE()',
		usageExample = 'CHECKUPDATE()',
		execute = function(self, params)
			Main.CheckForVersionUpdate(true)
			if not Main.isOnLatestVersion() then
				local newUpdateName = string.format(" %s ** New Update Available **", MGBA.Symbols.Menu.ListItem)
				MGBA.Screens.UpdateCheck.textBuffer:setName(newUpdateName)
				MGBA.Screens.UpdateCheck.labelTimer = 60 * 5 * 2 -- approx 5 minutes
				Program.redraw(true)
				print(string.format("New update found! Version: %s  (check the sidebar menu to view it)", Main.Version.latestAvailable))
			else
				print(string.format("No new updates available. Latest version available: %s", Main.Version.latestAvailable))
			end
		end,
	},
	["RELEASENOTES"] = {
		description = "Opens a browser window with details about the current version's release notes.",
		usageSyntax = 'RELEASENOTES()',
		usageExample = 'RELEASENOTES()',
		execute = function(self, params)
			UpdateScreen.openReleaseNotesWindow()
		end,
	},
	["UPDATENOW"] = {
		description = "Automatically updates the Tracker by downloading and installing the latest release.",
		usageSyntax = 'UPDATENOW()',
		usageExample = 'UPDATENOW()',
		execute = function(self, params)
			print("> Update in progress, please wait...")
			print("")

			if UpdateOrInstall.performParallelUpdate() then
				print("")
				print("> Follow these steps to restart the Tracker to apply the update:")
				print(" 1) Complete any ongoing battles first")
				print(" 2) On the mGBA scripting window: Click File -> Reset")
				print(" 3) Click File -> Load script (or Load recent script)")
			end
		end,
	},
	["QUICKLOAD"] = {
		description = "Forces the Tracker to Quickload a new game ROM.",
		usageSyntax = 'QUICKLOAD()',
		usageExample = 'QUICKLOAD()',
		execute = function(self, params)
			Main.loadNextSeed = true
		end,
	},
	["HELPWIKI"] = {
		description = "Opens a browser window showing helpful wiki pages that explain various features of the Tracker.",
		usageSyntax = 'HELPWIKI()',
		usageExample = 'HELPWIKI()',
		execute = function(self, params)
			NavigationMenu.openWikiBrowserWindow()
		end,
	},
	["ATTEMPTS"] = {
		description = "Allows you to manually change the Attempts counter to a different number, shown on the Stats sidebar",
		usageSyntax = 'ATTEMPTS "#"',
		usageExample = 'ATTEMPTS "123"',
		execute = function(self, params)
			if params == nil or params == "" then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where # is a positive number.')
				return
			end

			local number = tonumber(params:match("^%d+") or "")
			if number == nil or number <= 0 then
				print(string.format(' [Command Error] Usage syntax: %s', self.usageSyntax))
				print(' - Where # is a positive number.')
				return
			end

			local prevAttemptsCount = Main.currentSeed
			Main.currentSeed = math.floor(number)
			if prevAttemptsCount ~= Main.currentSeed then
				Main.WriteAttemptsCountToFile(Main.GetAttemptsFile(), Main.currentSeed)
				Program.redraw(true)
				print(string.format(' Updating Attempts counter from "%s" to "%s"', prevAttemptsCount, Main.currentSeed))
			else
				print(string.format(' Attempts counter already set to "%s"', Main.currentSeed))
			end
		end,
	},
	["RANDOMBALL"] = {
		description = "Chooses a random " .. Constants.Words.POKEMON .. " starter " .. Constants.Words.POKE .. "ball from among: Left, Middle, Right",
		usageSyntax = 'RANDOMBALL()',
		usageExample = 'RANDOMBALL()',
		execute = function(self, params)
			local ballChoice = TrackerScreen.randomlyChooseBall() -- 1, 2, or 3
			local chosenBallText = TrackerScreen.PokeBalls.Labels[ballChoice] or Constants.BLANKLINE
			print(string.format(" Randomly chosen starter %sball: %s", Constants.Words.POKE, chosenBallText))
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

function QUICKLOAD(...) MGBA.CommandMap["QUICKLOAD"]:execute(...) end
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

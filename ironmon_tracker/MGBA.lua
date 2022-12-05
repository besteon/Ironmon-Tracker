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
	MGBA.updateSpecialWords()
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
	print("")
	print("Click on 'Basic Commands' to learn how to look-up game info as you play.")
	print("")
end

function MGBA.activateQuickload()
	if Main.frameCallbackId ~= nil then
		---@diagnostic disable-next-line: undefined-global
		callbacks:remove(Main.frameCallbackId)
	end
	if Main.keysreadCallbackId ~= nil then
		---@diagnostic disable-next-line: undefined-global
		callbacks:remove(Main.keysreadCallbackId)
	end
	Main.LoadNextRom()
end

-- Adjust some written Constants so that they display properly
function MGBA.updateSpecialWords()
	-- Keep these the same old values
	AbilityData.DefaultAbility.name = Constants.BLANKLINE
	AbilityData.DefaultAbility.description = Constants.BLANKLINE

	local pokemonWord = "Pokémon"
	local pokeWord = "Poké"

	-- First replace existing words with new ones
	for _, move in pairs(MoveData.Moves) do
		if move.summary:find(Constants.Words.POKEMON) then
			move.summary = move.summary:gsub(Constants.Words.POKEMON, pokemonWord)
		end
	end
	for _, ability in pairs(AbilityData.Abilities) do
		if ability.description:find(Constants.Words.POKEMON) then
			ability.description = ability.description:gsub(Constants.Words.POKEMON, pokemonWord)
		end
		if ability.description:find(Constants.Words.POKE) then
			ability.description = ability.description:gsub(Constants.Words.POKE, pokeWord)
		end
		if ability.descriptionEmerald ~= nil and ability.descriptionEmerald:find(Constants.Words.POKEMON) then
			ability.descriptionEmerald = ability.descriptionEmerald:gsub(Constants.Words.POKEMON, pokemonWord)
		end
		if ability.descriptionEmerald ~= nil and ability.descriptionEmerald:find(Constants.Words.POKE) then
			ability.descriptionEmerald = ability.descriptionEmerald:gsub(Constants.Words.POKE, pokeWord)
		end
	end
	for _, route in pairs(RouteData.Info) do
		if route.name:find(Constants.Words.POKEMON) then
			route.name = route.name:gsub(Constants.Words.POKEMON, pokemonWord)
		end
		if route.name:find(Constants.Words.POKE) then
			route.name = route.name:gsub(Constants.Words.POKE, pokeWord)
		end
	end
	for _, statPair in pairs(StatsScreen.StatTables) do
		if statPair.name:find(Constants.Words.POKEMON) then
			statPair.name = statPair.name:gsub(Constants.Words.POKEMON, pokemonWord)
		end
		if statPair.name:find(Constants.Words.POKE) then
			statPair.name = statPair.name:gsub(Constants.Words.POKE, pokeWord)
		end
	end
	Constants.Words.POKEMON = pokemonWord
	Constants.Words.POKE = pokeWord

	Constants.BLANKLINE = "--" -- change from triple dash to double
	Constants.STAT_STATES[2].text = "-" -- change from double dash to single
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
		name = string.format("%s Settings", MGBA.Symbols.Menu.Hamburger),
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
		setData = function(self, moveId, setByUser)
			if self.moveId ~= moveId and MoveData.isValid(moveId) then
				local labelToAppend = MoveData.Moves[moveId].name or Constants.BLANKLINE
				MGBA.ScreenUtils.setLabel(MGBA.Screens.LookupMove, labelToAppend)
			end
			self.moveId = moveId or 0
		end,
		updateData = function(self)
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
			if Battle.inBattle and not Battle.enemyHasAttacked and Battle.actualEnemyMoveId ~= 0 and MoveData.isValid(Battle.actualEnemyMoveId) then
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
-- Each has 'optionKey', 'displayName', 'updateSelf', and 'getValue'; many defined in MGBA.buildOptionMapDefaults()
MGBA.OptionMap = {
	-- TRACKER SETUP (#1-#5, #10-#13)
	[1] = { optionKey = "Right justified numbers", displayName = "Right justified numbers", },
	[2] = { optionKey = "Auto save tracked game data", displayName = "Autosave tracked game data", },
	[3] = { optionKey = "Track PC Heals", displayName = "Track PC Heals", },
	[4] = { optionKey = "PC heals count downward", displayName = "PC heals count downward", },
	[5] = { optionKey = "Display pedometer", displayName = "Display step pedometer", },
	[6] = { optionKey = "Display repel usage", displayName = "Display repel usage", },
	[10] = { optionKey = "Load next seed", displayName = "Quickload", },
	[11] = { optionKey = "Toggle view", displayName = "Toggle view", },
	[12] = { optionKey = "Cycle through stats", displayName = "Cycle stats", },
	[13] = { optionKey = "Mark stat", displayName = "Mark stat", },
	-- GAMEPLAY OPTIONS (#20-27)
	[20] = { optionKey = "Auto swap to enemy", displayName = "Auto swap to enemy", },
	[21] = { optionKey = "Hide stats until summary shown", displayName = "View summary to see stats", },
	[22] = { optionKey = "Show physical special icons", displayName = "Physical/Special icons", },
	[23] = { optionKey = "Show move effectiveness", displayName = "Show move effectiveness", },
	[24] = { optionKey = "Calculate variable damage", displayName = "Calculate variable damage", },
	[25] = { optionKey = "Count enemy PP usage", displayName = "Count enemy PP usage", },
	[26] = { optionKey = "Show last damage calcs", displayName = "Show last damage calcs", },
	[27] = { optionKey = "Reveal info if randomized", displayName = "Reveal info if randomized", },
	-- QUICKLOAD SETUP (#30-#35)
	[30] = {
		optionKey = "Use premade ROMs",
		displayName = "Use premade ROMs",
		updateSelf = function(self, params)
			if Options[self.optionKey] ~= nil then
				Options[self.optionKey] = not Options[self.optionKey]
				-- Only one can be enabled at a time
				Options["Generate ROM each time"] = false
				Options.forceSave()
				return true
			end
			return false, string.format("Option key \"%s\" doesn't exist", tostring(self.optionKey))
		end,
		},
	[31] = {
		optionKey = "Generate ROM each time",
		displayName = "Generate a ROM each time",
		updateSelf = function(self, params)
			if Options[self.optionKey] ~= nil then
				Options[self.optionKey] = not Options[self.optionKey]
				-- Only one can be enabled at a time
				Options["Use premade ROMs"] = false
				Options.forceSave()
				return true
			end
			return false, string.format("Option key \"%s\" doesn't exist", tostring(self.optionKey))
		end,
	},
	[32] = {
		optionKey = "ROMs Folder",
		displayName = "ROMs Folder",
		getValue = function(self)
			return Utils.extractFolderNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			Options.FILES[self.optionKey] = params
			Options.forceSave()
			return true
			-- return false, "Invalid ROMs folder; please enter the full folder path to your ROMs folder."
		end,
	},
	[33] = {
		optionKey = "Randomizer JAR",
		displayName = "Randomizer JAR",
		getValue = function(self)
			return Utils.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local extension = Utils.extractFileExtensionFromPath(params)
			if extension == "jar" then
				Options.FILES[self.optionKey] = params
				Options.forceSave()
				return true
			end
			return false, "A '.jar' file is required; please enter the full file path to your Randomizer JAR file."
		end,
	},
	[34] = {
		optionKey = "Source ROM",
		displayName = "Source ROM",
		getValue = function(self)
			return Utils.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local extension = Utils.extractFileExtensionFromPath(params)
			if extension == "gba" then
				Options.FILES[self.optionKey] = params
				Options.forceSave()
				return true
			end
			return false, "A '.gba' file is required; please enter the full file path to your GBA ROM file."
		end,
	},
	[35] = {
		optionKey = "Settings File",
		displayName = "Settings File",
		getValue = function(self)
			return Utils.extractFileNameFromPath(Options.FILES[self.optionKey]) or ""
		end,
		updateSelf = function(self, params)
			local extension = Utils.extractFileExtensionFromPath(params)
			if extension == "rnqs" then
				Options.FILES[self.optionKey] = params
				Options.forceSave()
				return true
			end
			return false, "An '.rnqs' file is required; please enter the full file path to your Randomizer Settings file."
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
					if comboFormatted ~= "" then
						Options.CONTROLS[self.optionKey] = comboFormatted
						Options.forceSave()
						return true
					end
					return false, "Button input required; available buttons: A, B, L, R, Start, Select"
				end
			else
				-- Otherwise, toggle the option's boolean value
				updateFunction = function(self)
					if Options[self.optionKey] ~= nil then
						Options[self.optionKey] = not Options[self.optionKey]
						Options.forceSave()
						return true
					end
					return false, string.format("Option key \"%s\" doesn't exist", tostring(self.optionKey))
				end
			end
			opt.updateSelf = updateFunction
		end
	end
end

-- Global functions required by mGBA input prompts
-- Each written in the form of: funcname "parameter(s) as text only"
---@diagnostic disable-next-line: lowercase-global
function note(...)
	local noteText = ...
	if not Tracker.Data.isViewingOwn then
		local pokemon = Tracker.getViewedPokemon()
		if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
			Tracker.TrackNote(pokemon.pokemonID, noteText)
			print(string.format("Note added for %s", pokemon.name))
			Program.redraw(true)
		end
	end
end
function Note(...) note(...) end
function NOTE(...) note(...) end

---@diagnostic disable-next-line: lowercase-global
function pokemon(...)
	local pokemonName = ...
	if pokemonName == nil or pokemonName == "" then
		return
	end

	local pokemonID = DataHelper.findPokemonId(pokemonName)
	if pokemonID ~= 0 then
		pokemonName = PokemonData.Pokemon[pokemonID].name or pokemonName
		print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", pokemonName))
		MGBA.Screens.LookupPokemon:setData(pokemonID, true)
		Program.redraw(true)
	else
		print(string.format(" Unable to find %s: %s", Constants.Words.POKEMON, pokemonName))
	end
end
function Pokemon(...) pokemon(...) end
function POKEMON(...) pokemon(...) end

---@diagnostic disable-next-line: lowercase-global
function move(...)
	local moveName = ...
	if moveName == nil or moveName == "" then
		return
	end

	local moveId = DataHelper.findMoveId(moveName)
	if moveId ~= 0 then
		moveName = MoveData.Moves[moveId].name or moveName
		print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", moveName))
		MGBA.Screens.LookupMove:setData(moveId, true)
		Program.redraw(true)
	else
		print(string.format(" Unable to find move: %s", moveName))
	end
end
function Move(...) move(...) end
function MOVE(...) move(...) end

---@diagnostic disable-next-line: lowercase-global
function ability(...)
	local abilityName = ...
	if abilityName == nil or abilityName == "" then
		return
	end

	local abilityId = DataHelper.findAbilityId(abilityName)
	if abilityId ~= 0 then
		abilityName = AbilityData.Abilities[abilityId].name or abilityName
		print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", abilityName))
		MGBA.Screens.LookupAbility:setData(abilityId, true)
		Program.redraw(true)
	else
		print(string.format(" Unable to find ability: %s", abilityName))
	end
end
function Ability(...) ability(...) end
function ABILITY(...) ability(...) end

---@diagnostic disable-next-line: lowercase-global
function route(...)
	local routeName = ...
	if routeName == nil or routeName == "" then
		return
	end

	local routeId = DataHelper.findRouteId(routeName)
	if routeId ~= 0 then
		routeName = RouteData.Info[routeId].name or routeName
		print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", routeName))
		MGBA.Screens.LookupRoute:setData(routeId, true)
		Program.redraw(true)
	else
		print(string.format(" Unable to find route: %s", routeName))
	end
end
function Route(...) route(...) end
function ROUTE(...) route(...) end

---@diagnostic disable-next-line: lowercase-global
function option(...)
	local optionParams = ...
	if optionParams == nil or optionParams == "" then
		return
	end

	local optionNumber = optionParams:match("^%d+")
	if optionNumber ~= nil then
		optionNumber = tonumber(optionNumber)
		local _, _, params = optionParams:match("(%d+)(%s+)(.+)") -- Everything but the first number

		local opt = MGBA.OptionMap[optionNumber]
		if opt ~= nil then
			local success, msg = opt:updateSelf(params)
			if success then
				Program.redraw(true)
				local newValue = opt:getValue()
				if newValue == MGBADisplay.Symbols.Options.Enabled then
					newValue = " to ON."
				elseif newValue == MGBADisplay.Symbols.Options.Disabled then
					newValue = " to OFF."
				else
					newValue = string.format(" to %s", newValue)
				end
				print(string.format(' Updating option #%s: "%s"%s', optionNumber, opt.displayName, newValue))
			else
				print(string.format(' Error! %s', msg or "Unknown error has occured."))
			end
		else
			print(string.format(" Option #%s doesn't exist. Please try another option number.", optionNumber))
		end
	else
		print(' Error with command; usage syntax: OPTION "#", where # is the option number.')
	end
end
function Option(...) option(...) end
function OPTION(...) option(...) end

---@diagnostic disable-next-line: lowercase-global
function pcheals(...)
	local optionParams = ...
	if optionParams == nil or optionParams == "" then
		return
	end

	local number = optionParams:match("^%d+")
	if number ~= nil and tonumber(number) ~= nil then
		Tracker.Data.centerHeals = math.floor(tonumber(number) or 0)
		if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
		if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
		Program.redraw(true)
		print(string.format(' Updating PC Heal count to: %s', Tracker.Data.centerHeals))
	else
		print(' Error with command; usage syntax: PCHEALS "#", where # is a number (0-99).')
	end
end
function PCHeals(...) pcheals(...) end
function PCHEALS(...) pcheals(...) end

---@diagnostic disable-next-line: lowercase-global
function credits(...)
	print(string.format("%-15s %s", "Created by:", Main.CreditsList.CreatedBy))
	print("\nContributors:")
	for i=1, #Main.CreditsList.Contributors, 2 do
		local contributorPair = string.format("* %-13s", Main.CreditsList.Contributors[i] or "")
		if Main.CreditsList.Contributors[i + 1] ~= nil then
			contributorPair = contributorPair .. " * " .. Main.CreditsList.Contributors[i + 1]
		end
		print(contributorPair)
	end
end
function Credits(...) credits(...) end
function CREDITS(...) credits(...) end

-- Commands to add:

-- HELP "command"
-- SAVEDATA "filename" -- NOT file path
-- LOADDATA "filename" -- NOT file path
-- CLEARDATA()
-- - output "put file in your tracker folder" if cannot be found

---@diagnostic disable-next-line: lowercase-global
function checkupdate(...)
	Main.TrackerVersion = "3.2.1"
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
end
function CheckUpdate(...) checkupdate(...) end
function CHECKUPDATE(...) checkupdate(...) end

---@diagnostic disable-next-line: lowercase-global
function releasenotes(...)
	UpdateScreen.openReleaseNotesWindow()
	print(string.format("Release notes: %s", Constants.Release.DOWNLOAD_URL))
end
function ReleaseNotes(...) releasenotes(...) end
function RELEASENOTES(...) releasenotes(...) end

---@diagnostic disable-next-line: lowercase-global
function updatenow(...)
	print(string.format("%s  (check the sidebar menu to view status)", UpdateScreen.States.IN_PROGRESS))
	-- UpdateScreen.performAutoUpdate() -- TODO: commented to prevent accidental code overwrrite; uncomment later
	if UpdateScreen.currentState == UpdateScreen.States.SUCCESS then
		print("")
		print("You can now restart the Tracker to apply the update. Exit any battle first.")
		print(" - On mGBA Scripting Window, click File -> Load script (or Load recent script)")
		print(" - Then click File -> Reset")
		-- restart() -- currently doesn't work well on mGBA, see below
	end
end
function UpdateNow(...) updatenow(...) end
function UPDATENOW(...) updatenow(...) end

-- RESTART doesn't work since we don't have control over the TextBuffers that have already been created; can't remove them
-- ---@diagnostic disable-next-line: lowercase-global
-- function restart(...)
-- 	print("Restarting the Tracker. Saving tracked data and settings.")
-- 	if Options["Auto save tracked game data"] and Tracker.getPokemon(1, true) ~= nil then
-- 		Tracker.saveData()
-- 	end
-- 	Main.SaveSettings(true)

-- 	IronmonTracker.startTracker()
-- end
-- function Restart(...) restart(...) end
-- function RESTART(...) restart(...) end
-- ---@diagnostic disable-next-line: lowercase-global
-- function reload(...) restart(...) end
-- function Reload(...) restart(...) end
-- function RELOAD(...) restart(...) end

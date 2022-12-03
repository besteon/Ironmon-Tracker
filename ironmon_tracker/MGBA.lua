-- mGBA Scripting Docs: https://mgba.io/docs/scripting.html
-- Uses Lua 5.4
MGBA = {}

MGBA.Symbols = {
	Menu = {
		Hamburger = "☰",
		ListItem = "╰",
	},
	Stab = "!",
	Effectiveness = { -- 2 char width
		[0] = "X ",
		[0.25] = "--",
		[0.5] = "- ",
		[1] = "  ",
		[2] = "+ ",
		[4] = "++",
	},
	Category = {
		[MoveData.Categories.STATUS] = " ",
		[MoveData.Categories.PHYSICAL] = "P",
		[MoveData.Categories.SPECIAL] = "S",
	},
}

MGBA.Screens = {} -- Populated later in initialize()
MGBA.screenWidth = 33 -- The ideal character width limit for most screen displays, for cropping out the Tracker
MGBA.timeToDisplayLabel = 30 * 2 -- (# of seconds to display) * 2, because its based on redraw events

-- Define the keys here in case the TextBuffer name needs to change
MGBA.ScreenKeys = {
	SettingsMenu = string.format("%s Settings", MGBA.Symbols.Menu.Hamburger),
	TrackerSetup = string.format(" %s General", MGBA.Symbols.Menu.ListItem),
	GameplayOptions = string.format(" %s Gameplay", MGBA.Symbols.Menu.ListItem),
	QuickloadSetup = string.format(" %s Quickload", MGBA.Symbols.Menu.ListItem),
	UpdateCheck = string.format(" %s Update", MGBA.Symbols.Menu.ListItem),

	CommandMenu = string.format("%s Commands", MGBA.Symbols.Menu.Hamburger),
	CommandsBasic = string.format(" %s Basic Commands", MGBA.Symbols.Menu.ListItem),

	LookupMenu = string.format("%s Info Lookup", MGBA.Symbols.Menu.Hamburger),
	LookupPokemon = string.format(" %s Pokémon", MGBA.Symbols.Menu.ListItem),
	LookupMove = string.format(" %s Move", MGBA.Symbols.Menu.ListItem),
	LookupAbility = string.format(" %s Ability", MGBA.Symbols.Menu.ListItem),
	LookupRoute = string.format(" %s Route", MGBA.Symbols.Menu.ListItem),
	LookupOriginalRoute = string.format("    %s Original Route Info", MGBA.Symbols.Menu.ListItem),

	TrackerMenu = string.format("%s Tracker", MGBA.Symbols.Menu.Hamburger),
	Stats = string.format(" %s Stats", MGBA.Symbols.Menu.ListItem),
	BattleTracker = string.format(" %s Battle Tracker", MGBA.Symbols.Menu.ListItem),
}

-- Ordered list of things
MGBA.OrderedLists = {
	ScreenNames = {
		MGBA.ScreenKeys.SettingsMenu,
			MGBA.ScreenKeys.TrackerSetup, MGBA.ScreenKeys.GameplayOptions, MGBA.ScreenKeys.QuickloadSetup, MGBA.ScreenKeys.UpdateCheck,
		MGBA.ScreenKeys.CommandMenu,
			MGBA.ScreenKeys.CommandsBasic,
		MGBA.ScreenKeys.LookupMenu,
			MGBA.ScreenKeys.LookupPokemon, MGBA.ScreenKeys.LookupMove, MGBA.ScreenKeys.LookupAbility, MGBA.ScreenKeys.LookupRoute,
				MGBA.ScreenKeys.LookupOriginalRoute,
		MGBA.ScreenKeys.TrackerMenu,
			MGBA.ScreenKeys.Stats, MGBA.ScreenKeys.BattleTracker,
	},
	Effectiveness = { "0x Immunities", "1/4x Resistances", "1/2x Resistances", "2x Weaknesses", "4x Weaknesses", },
}

function MGBA.initialize()
	AbilityData.DefaultAbility.name = Constants.BLANKLINE
	AbilityData.DefaultAbility.description = Constants.BLANKLINE

	MGBA.updateSpecialWords()
	MGBA.buildScreens()
end

function MGBA.clear()
	-- This "clears" the Console for mGBA
	print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
end

function MGBA.setScreenLabel(screenKey, label)
	local screen = MGBA.Screens[screenKey]
	if screen ~= nil and screen.textBuffer ~= nil and label ~= nil and label ~= "" then
		MGBA.removeScreenLabels(screenKey)
		screen.textBuffer:setName(string.format("%s - %s", screenKey, label))
		screen.tagTimer = MGBA.timeToDisplayLabel
	end
end

function MGBA.removeScreenLabels(screenKey)
	local screen = MGBA.Screens[screenKey]
	if screen ~= nil and screen.textBuffer ~= nil then
		screen.textBuffer:setName(screenKey)
		screen.tagTimer = 0
	end
end

function MGBA.displayInputCommands()
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

-- Each screen has this properties set later in createTextBuffers()
-- self.data: Raw data that hasn't yet been formatted
-- self.displayLines: Formatted lines that are ready to be displayed
-- self.textBuffer: The mGBA TextBuffer where the displayLines are printed
-- self.isUpdated: Used to determine if a redraw should occur (prevents scroll yoink)
-- self.tagTimer: A tag only stays visible for N redraws (about 30 frames each)
function MGBA.buildScreens()
	MGBA.Screens[MGBA.ScreenKeys.TrackerSetup] = {
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatSettingsDisplayLines, self.displayLines, nil)
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.CommandsBasic] = {
		headerText = "Basic Commands",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatCommandsBasicDisplayLines, self.displayLines, nil)
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.LookupPokemon] = {
		setData = function(self, pokemonID, setByUser)
			if self.pokemonID ~= pokemonID and PokemonData.isValid(pokemonID) then
				local labelToAppend = PokemonData.Pokemon[pokemonID].name or Constants.BLANKLINE
				MGBA.setScreenLabel(MGBA.ScreenKeys.LookupPokemon, labelToAppend)
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
				self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatPokemonInfoDisplayLines, self.displayLines, self.data)
			end
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.LookupMove] = {
		setData = function(self, moveId, setByUser)
			if self.moveId ~= moveId and MoveData.isValid(moveId) then
				local labelToAppend = MoveData.Moves[moveId].name or Constants.BLANKLINE
				MGBA.setScreenLabel(MGBA.ScreenKeys.LookupMove, labelToAppend)
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
				self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatMoveInfoDisplayLines, self.displayLines, self.data)
			end
		end,
		checkForEnemyAttack = function(self)
			if Battle.inBattle and not Battle.enemyHasAttacked and Battle.actualEnemyMoveId ~= 0 and MoveData.isValid(Battle.actualEnemyMoveId) then
				self:setData(Battle.actualEnemyMoveId, false)
			end
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.LookupAbility] = {
		setData = function(self, abilityId, setByUser)
			if self.abilityId ~= abilityId and AbilityData.isValid(abilityId) then
				local labelToAppend = AbilityData.Abilities[abilityId].name or Constants.BLANKLINE
				MGBA.setScreenLabel(MGBA.ScreenKeys.LookupAbility, labelToAppend)
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
				self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatAbilityInfoDisplayLines, self.displayLines, self.data)
			end
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.LookupRoute] = {
		setData = function(self, routeId, setByUser)
			if self.routeId ~= routeId and RouteData.hasRoute(routeId) then
				local labelToAppend = RouteData.Info[routeId].name or Constants.BLANKLINE
				MGBA.setScreenLabel(MGBA.ScreenKeys.LookupRoute, labelToAppend)
			end
			self.routeId = routeId or 0
		end,
		updateData = function(self)
			-- if self.data == nil or (self.routeId ~= nil and self.routeId ~= self.data.r.id) or Battle.inBattle then -- Temp using battle
			self.data = DataHelper.buildRouteInfoDisplay(self.routeId)
			self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatRouteInfoDisplayLines, self.displayLines, self.data)
			-- end
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.LookupOriginalRoute] = {
		updateData = function(self)
			local data = MGBA.Screens[MGBA.ScreenKeys.LookupRoute].data -- Uses data that has already been built
			if data ~= nil then
				self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatRouteInfoOriginalDisplayLines, self.displayLines, data)
			end
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.Stats] = {
		headerText = "Game Stats",
		updateData = function(self)
			self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatStatsDisplayLines, self.displayLines, nil)
		end,
	}
	MGBA.Screens[MGBA.ScreenKeys.BattleTracker] = {
		updateData = function(self)
			self.data = DataHelper.buildTrackerScreenDisplay()
			self.displayLines, self.isUpdated = MGBA.tryUpdatingDisplayLines(MGBA.formatTrackerScreenDisplayLines, self.displayLines, self.data)
		end,
	}
end

-- Returns two results: updated display lines and true/false, true if lines were updated
function MGBA.tryUpdatingDisplayLines(formattingFunction, prevDisplayLines, data)
	prevDisplayLines = prevDisplayLines or {}
	local newDisplayLines = formattingFunction(data) or {}
	local isUpdated = #prevDisplayLines == 0 or table.concat(prevDisplayLines) ~= table.concat(newDisplayLines)
	return newDisplayLines, isUpdated
end

function MGBA.createTextBuffers()
	for _, screenKey in ipairs(MGBA.OrderedLists.ScreenNames) do
		local screen = MGBA.Screens[screenKey] or {}
		if screen.textBuffer == nil then -- workaround for reloading script for Quickload
			screen.textBuffer = console:createBuffer(screenKey)
			screen.textBuffer:setSize(80, 50) -- (cols, rows) default is (80, 24)
		end
	end
end

function MGBA.updateTextBuffers()
	-- Unlikely, but double-check screen related things exist (TODO: Testing without)
	-- MGBA.createTextBuffers()

	for _, screenKey in ipairs(MGBA.OrderedLists.ScreenNames) do
		local screen = MGBA.Screens[screenKey]
		if screen ~= nil and screen.textBuffer ~= nil then
			-- Update the data, if necessary
			if screen.updateData ~= nil then
				screen:updateData()
			end

			-- Display the data, but only if the text screen has changed
			if screen.isUpdated then
				screen.textBuffer:clear()
				for _, line in ipairs(screen.displayLines) do
					MGBA.printToScreenBuffer(line, screen.textBuffer)
				end
				screen.isUpdated = false
			end

			if screen.tagTimer ~= nil and screen.tagTimer > 0 then
				screen.tagTimer = screen.tagTimer - 1
				if screen.tagTimer == 0 then
					MGBA.removeScreenLabels(screenKey)
				end
			end
		end
	end
end

-- Prints `line` to the mGBA TextBuffer 'MGBA.currentScreen' or optionally the `textBuffer`
function MGBA.printToScreenBuffer(line, textBuffer)
	line = line or ""
	textBuffer = textBuffer or MGBA.currentScreen
	if textBuffer ~= nil then
		textBuffer:print(line .. "\n")
	end
end

function MGBA.addLinesWrapped(linesTable, text, width)
	if text == nil then return end
	width = width or MGBA.screenWidth

	if string.len(text) <= width then
		table.insert(linesTable, text)
	else
		for _, line in pairs(Utils.getWordWrapLines(text, width)) do
			table.insert(linesTable, line)
		end
	end
end

function MGBA.formatSettingsDisplayLines()
	local lines = {}
	return lines
end

function MGBA.formatCommandsBasicDisplayLines()
	local lines = {}

	local commandBar = " %-" .. MGBA.screenWidth .. "s" -- left-align
	local exampleBar = "%" .. MGBA.screenWidth .. "s" -- right-align
	table.insert(lines, MGBA.Screens[MGBA.ScreenKeys.CommandsBasic].headerText:upper())

	local usageInstructions = 'Enter a command in the textbox below; parameter in "quotes"'
	MGBA.addLinesWrapped(lines, usageInstructions)
	table.insert(lines, "")

	table.insert(lines, "Command Syntax:")
	table.insert(lines, string.format(commandBar, 'NOTE "text"'))
	table.insert(lines, string.format(commandBar, 'POKEMON "name"'))
	table.insert(lines, string.format(commandBar, 'MOVE "name"'))
	table.insert(lines, string.format(commandBar, 'ABILITY "name"'))
	table.insert(lines, string.format(commandBar, 'ROUTE "name"'))
	table.insert(lines, "")

	table.insert(lines, "Example Usage:")
	table.insert(lines, string.format(commandBar, 'NOTE "survives Stomp at lv47"'))
	table.insert(lines, string.format(commandBar, 'POKEMON "Shuckle"'))
	table.insert(lines, string.format(commandBar, 'MOVE "Rock Slide"'))
	table.insert(lines, string.format(commandBar, 'ABILITY "Soundproof"'))
	table.insert(lines, string.format(commandBar, 'ROUTE "7"'))

	return lines
end

function MGBA.formatTrackerScreenData(data)
	data.p.name = data.p.name:upper()

	if data.p.evo == PokemonData.Evolutions.NONE then
		data.p.evo = Constants.BLANKLINE
	end

	if data.p.status ~= "" then
		data.p.status = string.format("[%s]", data.p.status)
	end

	-- Format type as "Normal" or "Flying/Normal"
	if data.p.types[2] ~= PokemonData.Types.EMPTY and data.p.types[2] ~= data.p.types[1] then
		data.p.typeline = string.format("%s/%s", Utils.firstToUpper(data.p.types[1]), Utils.firstToUpper(data.p.types[2]))
	else
		data.p.typeline = Utils.firstToUpper(data.p.types[1] or Constants.BLANKLINE)
	end

	TrackerScreen.updateButtonStates() -- required prior to using TrackerScreen.Buttons[statKey]

	data.p.labels = {}
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		data.p.labels[statKey] = statKey:upper()
		if data.x.viewingOwn then
			if statKey == data.p.positivestat then
				data.p.labels[statKey] = data.p.labels[statKey] .. "+"
			elseif statKey == data.p.negativestat then
				data.p.labels[statKey] = data.p.labels[statKey] .. "-"
			end
		else
			local statBtn = TrackerScreen.Buttons[statKey] or {}
			data.p[statKey] = string.format(" %s ", Constants.STAT_STATES[statBtn.statState or 0].text)
		end

		local stageChange = data.p.stages[statKey] - 6
		if stageChange > 0 then
			data.p.stages[statKey] = "+" .. stageChange
		elseif stageChange < 0 then
			data.p.stages[statKey] = tostring(stageChange) -- includes negative sign
		else
			data.p.stages[statKey] = ""
		end
	end

	if not data.x.viewingOwn and Input.StatHighlighter:shouldDisplay() then
		local selectedStat = Input.StatHighlighter:getSelectedStat()
		data.p[selectedStat] = string.format("[%s]", data.p[selectedStat]:sub(2, 2))
	end

	for _, move in ipairs(data.m.moves) do
		move.name = move.name .. Utils.inlineIf(move.starred, "*", "")
		move.type = Utils.firstToUpper(move.type)
	end
end

function MGBA.formatTrackerScreenDisplayLines(data)
	local lines = {}

	MGBA.formatTrackerScreenData(data)

	-- %-#s means to left-align, padding out the right-part of the string with spaces
	local justify3 = Utils.inlineIf(Options["Right justified numbers"], "%3s", "%-3s")

	local formattedStats = {}
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		formattedStats[statKey] = string.format("%-5s" .. justify3 .. "%-2s", data.p.labels[statKey], data.p[statKey], data.p.stages[statKey])
	end

	-- Header and top dividing line (with types)
	lines[1] = string.format("%-23s%-5s%-5s", string.format("%-13s %-3s", data.p.name, data.p.status), "BST", data.p.bst)
	lines[2] = string.format("%-23s%-10s", data.p.typeline, "----------")

	-- Top six lines of the box: Pokemon related stuff
	local topFormattedLine = "%-23s%-10s"
	local levelLine = string.format("Lv.%s (%s)", data.p.level, data.p.evo)
	if data.x.viewingOwn then
		local hpLine = string.format("HP: %s/%s", data.p.curHP, data.p.hp)
		lines[3] = string.format(topFormattedLine, hpLine, formattedStats.hp)
		lines[4] = string.format(topFormattedLine, levelLine, formattedStats.atk)

		if Options["Track PC Heals"] then
			local survivalHeals = string.format("Survival PCs: %s", data.x.pcheals)
			lines[7] = string.format(topFormattedLine, survivalHeals, formattedStats.spd)
		else
			lines[7] = string.format(topFormattedLine, "", formattedStats.spd)
		end

		local availableHeals = string.format("Heals: %.0f%% (%s)", data.x.healperc, data.x.healnum)
		lines[8] = string.format(topFormattedLine, availableHeals, formattedStats.spe)
	else
		lines[3] = string.format(topFormattedLine, levelLine, formattedStats.hp)

		local lastLevelSeen
		if data.p.lastlevel ~= nil and data.p.lastlevel ~= "" then
			lastLevelSeen = string.format("Last seen Lv.%s", data.p.lastlevel)
		else
			lastLevelSeen = "New encounter!"
		end
		lines[4] = string.format(topFormattedLine, lastLevelSeen, formattedStats.atk)

		local encountersText = string.format("Seen %s: %s", Utils.inlineIf(Battle.isWildEncounter, "in the wild", "on trainers"), data.x.encounters)
		lines[7] = string.format(topFormattedLine, encountersText, formattedStats.spd)
		lines[8] = string.format(topFormattedLine, data.x.route, formattedStats.spe)
	end

	lines[5] = string.format(topFormattedLine, data.p.line1, formattedStats.def)
	lines[6] = string.format(topFormattedLine, data.p.line2, formattedStats.spa)
	table.insert(lines, "")

	-- Bottom five lines of the box: Move related stuff
	local botFormattedLine = "%-19s%-3s%-7s%-4s"
	table.insert(lines, string.format(botFormattedLine, data.m.nextmoveheader, "PP", "  Pow", "Acc"))
	table.insert(lines, "---------------------------------")
	for i, move in ipairs(data.m.moves) do
		local nameText = move.name
		if Options["Show physical special icons"] and (data.x.viewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType) then
			nameText = (MGBA.Symbols.Category[move.category] or " ") .. " " .. nameText
		end

		local powerText = tostring(move.power):sub(1, 3) -- for move powers with too much text (eg "100x")
		if move.isstab then
			powerText = powerText .. MGBA.Symbols.Stab
		end
		powerText = string.format(justify3, powerText)
		if move.showeffective then
			powerText = (MGBA.Symbols.Effectiveness[move.effectiveness] or "  ") .. powerText
		else
			powerText = (MGBA.Symbols.Effectiveness[1] or "  ") .. powerText
		end

		table.insert(lines, string.format(botFormattedLine, nameText, move.pp, powerText, move.accuracy))
	end
	table.insert(lines, "---------------------------------")

	-- Footer, carousel related stuff
	-- local botFormattedLine = "%-33s"
	for _, carousel in ipairs(TrackerScreen.CarouselItems) do
		if carousel.isVisible() then
			local carouselText = MGBA.convertCarouselToText(carousel, data.p.id)
			table.insert(lines, carouselText)
		end
	end
	table.insert(lines, "---------------------------------")

	return lines
end

function MGBA.convertCarouselToText(carousel, pokemonID)
	local carouselText = ""
	if carousel == nil then return carouselText end
	pokemonID = pokemonID or 0

	local carouselContent = carousel.getContentList(pokemonID)
	if carousel.type == TrackerScreen.CarouselTypes.BADGES then
		carouselText = "Badges: "
		for badgeNumber, badgeButton in ipairs(carouselContent) do
			local badgeText = string.format("[%s]", Utils.inlineIf(badgeButton.badgeState ~= 0, badgeNumber, " "))
			carouselText = carouselText .. badgeText
		end
	elseif carousel.type == TrackerScreen.CarouselTypes.LAST_ATTACK then
		carouselText = carouselContent
	elseif carousel.type == TrackerScreen.CarouselTypes.ROUTE_INFO then
		carouselText = carouselContent
	elseif carousel.type == TrackerScreen.CarouselTypes.NOTES then
		carouselText = "Note: " .. carouselContent
	elseif carousel.type == TrackerScreen.CarouselTypes.PEDOMETER then
		carouselText = carouselContent
	end

	return carouselText
end

function MGBA.formatPokemonInfoData(data)
	local listSeparator = ", "

	data.p.name = data.p.name:upper()

	-- Format type as "Normal" or "Flying/Normal"
	if data.p.types[2] ~= PokemonData.Types.EMPTY and data.p.types[2] ~= data.p.types[1] then
		data.p.typeline = string.format("%s/%s", Utils.firstToUpper(data.p.types[1]), Utils.firstToUpper(data.p.types[2]))
	else
		data.p.typeline = Utils.firstToUpper(data.p.types[1] or Constants.BLANKLINE)
	end

	if tonumber(data.p.weight) ~= nil then
		data.p.weight = string.format("%s kg", data.p.weight)
	else
		data.p.weight = Constants.BLANKLINE
	end
	data.p.evodetails = table.concat(data.p.evo, listSeparator)

	if data.p.movelvls == {} or #data.p.movelvls == 0 then
		data.p.moveslearned = "None"
	else
		for i = 1, #data.p.movelvls, 1 do
			if type(data.p.movelvls[i]) == "number" and data.p.movelvls[i] <= data.x.viewedPokemonLevel then
				data.p.movelvls[i] = data.p.movelvls[i] .. "*"
			end
		end
		data.p.moveslearned = table.concat(data.p.movelvls, listSeparator)
	end

	data.e.list = {}
	local effectLabelMappings = {
		[0] = MGBA.OrderedLists.Effectiveness[1],
		[0.25] = MGBA.OrderedLists.Effectiveness[2],
		[0.5] = MGBA.OrderedLists.Effectiveness[3],
		[2] = MGBA.OrderedLists.Effectiveness[4],
		[4] = MGBA.OrderedLists.Effectiveness[5],
	}
	for typeMultiplier, label in pairs(effectLabelMappings) do
		local effectTypes = data.e[typeMultiplier]
		if effectTypes ~= nil and #effectTypes ~= 0 then
			for i = 1, #effectTypes, 1 do
				effectTypes[i] = Utils.firstToUpper(effectTypes[i])
			end
			data.e.list[label] = table.concat(data.e[typeMultiplier], listSeparator)
		end
	end

	if data.x.note == nil or data.x.note == "" then
		data.x.note = "(Leave a note)" -- TODO: Change this to explain the mGBA command
	end
end

function MGBA.formatPokemonInfoDisplayLines(data)
	local lines = {}

	MGBA.formatPokemonInfoData(data)

	local labelBar = "%-12s %s"
	table.insert(lines, string.format("%-13s%s", data.p.name, string.format("[%s]", data.p.typeline)))
	table.insert(lines, string.format(labelBar, "BST:", data.p.bst))
	table.insert(lines, string.format(labelBar, "Weight:", data.p.weight))
	table.insert(lines, string.format(labelBar, "Evolution:", data.p.evodetails))

	table.insert(lines, "Level-up moves:")
	MGBA.addLinesWrapped(lines, data.p.moveslearned)

	table.insert(lines, "")
	for _, label in ipairs(MGBA.OrderedLists.Effectiveness) do
		if data.e.list[label] ~= nil then
			table.insert(lines, string.format("%s:", label))
			MGBA.addLinesWrapped(lines, string.format(" %s", data.e.list[label]))
		end
	end

	table.insert(lines, "")
	table.insert(lines, "Note:")
	MGBA.addLinesWrapped(lines, data.x.note)

	return lines
end

function MGBA.formatMoveInfoData(data)
	data.m.name = data.m.name:upper()
	data.m.type = Utils.firstToUpper(data.m.type)

	if tonumber(data.m.accuracy) ~= nil then
		data.m.accuracy = data.m.accuracy .. "%"
	end

	if data.m.category == MoveData.Categories.PHYSICAL or data.m.category == MoveData.Categories.SPECIAL then
		data.m.category = string.format("%s (%s)", data.m.category, MGBA.Symbols.Category[data.m.category])
	end

	data.m.iscontact = Utils.inlineIf(data.m.iscontact, "Yes", "No")

	if data.m.priority == "0" then
		data.m.priority = "Normal"
	end
end

function MGBA.formatMoveInfoDisplayLines(data)
	local lines = {}

	MGBA.formatMoveInfoData(data)

	local labelBar = "%-12s %s"
	table.insert(lines, string.format(labelBar, data.m.name, string.format("[%s]", data.m.type)))
	table.insert(lines, string.format(labelBar, "Category:", data.m.category))
	table.insert(lines, string.format(labelBar, "Contact:", data.m.iscontact))
	table.insert(lines, string.format(labelBar, "PP:", data.m.pp))
	table.insert(lines, string.format(labelBar, "Power:", data.m.power))
	table.insert(lines, string.format(labelBar, "Accuracy:", data.m.accuracy))
	table.insert(lines, string.format(labelBar, "Priority:", data.m.priority))

	if data.m.summary ~= Constants.BLANKLINE then
		table.insert(lines, "")
		table.insert(lines, "Move Summary:")
		MGBA.addLinesWrapped(lines, data.m.summary)
	end

	return lines
end

function MGBA.formatAbilityInfoData(data)
	data.a.name = data.a.name:upper()
end

function MGBA.formatAbilityInfoDisplayLines(data)
	local lines = {}

	MGBA.formatAbilityInfoData(data)

	table.insert(lines, data.a.name)

	table.insert(lines, "")
	MGBA.addLinesWrapped(lines, data.a.description)


	if data.a.descriptionEmerald ~= Constants.BLANKLINE then
		table.insert(lines, "")
		table.insert(lines, "Emerald Bonus:")
		MGBA.addLinesWrapped(lines, data.a.descriptionEmerald)
	end

	return lines
end

function MGBA.formatRouteInfoData(data)
	local unseenPokemon = "???"
	local justify4 = Utils.inlineIf(Options["Right justified numbers"], "%4s", "%-4s")
	local originalPokemonBar = " %-12s  " .. justify4 .. "    Lv.%s"

	if not RouteData.hasRoute(data.r.id) then
		data.r.name = string.format("UNKNOWN AREA (%s)", math.floor(data.r.id))
	else
		data.r.name = data.r.name:upper()
	end

	for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
		local area = data.e[encounterArea]

		area.originalLines = {}
		for _, enc in ipairs(area.originalPokemon) do
			local name = PokemonData.Pokemon[enc.pokemonID].name
			local rate = math.floor((enc.rate or 0) * 100) .. "%"
			local bar = string.format(originalPokemonBar, name, rate, enc.minLv)
			if enc.minLv ~= enc.maxLv then
				bar = bar .. "-" .. enc.maxLv
			end
			table.insert(area.originalLines, bar)
		end

		area.trackedLines = {}
		for i = 1, area.totalPossible, 1 do
			if PokemonData.isValid(area.trackedIDs[i]) then
				table.insert(area.trackedLines, string.format(" %s", PokemonData.Pokemon[area.trackedIDs[i]].name))
			else
				table.insert(area.trackedLines, string.format(" %s", unseenPokemon))
			end
		end
	end
end

function MGBA.formatRouteInfoDisplayLines(data)
	local lines = {}

	MGBA.formatRouteInfoData(data)

	table.insert(lines, string.format("%-22s%11s", data.r.name, "[Tracked]"))
	table.insert(lines, "")

	-- No wild encounters, such as a building, don't show anything else
	if data.r.totalWildEncounters == 0 and data.r.totalTrainerEncounters == 0 then
		return lines
	end

	for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
		local area = data.e[encounterArea]
		if area.totalPossible > 0 then -- Only display areas that have encounters
			table.insert(lines, string.format("%s (%s/%s seen)", encounterArea, area.totalSeen, area.totalPossible))
			for _, line in ipairs(area.trackedLines) do
				table.insert(lines, line)
			end
		end
	end

	return lines
end

function MGBA.formatRouteInfoOriginalDisplayLines(data)
	local lines = {}

	table.insert(lines, string.format("%-22s%11s", data.r.name, "[Original]"))
	table.insert(lines, "")

	-- No wild encounters, such as a building, don't show anything else
	if data.r.totalWildEncounters == 0 and data.r.totalTrainerEncounters == 0 then
		return lines
	end

	for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
		local area = data.e[encounterArea]
		if area.totalPossible > 0 then -- Only display areas that have encounters
			table.insert(lines, string.format("%s (%s/%s seen)", encounterArea, area.totalSeen, area.totalPossible))
			for _, line in ipairs(area.originalLines) do
				table.insert(lines, line)
			end
		end
	end

	return lines
end

function MGBA.formatStatsDisplayLines()
	local lines = {}

	local statBar = "%-21s%s"
	table.insert(lines, MGBA.Screens[MGBA.ScreenKeys.Stats].headerText:upper())
	table.insert(lines, "")

	local attemptsCount = tostring(Main.currentSeed) or Constants.BLANKLINE
	table.insert(lines, string.format(statBar, "Total attempts:", attemptsCount))
	table.insert(lines, "")

	for _, statPair in ipairs(StatsScreen.StatTables) do
		statPair.name = statPair.name:gsub("é", "e") -- The 'é' character doesn't work with format padding like %-20s
		local formattedValue = Utils.formatNumberWithCommas(statPair.getValue() or 0)
		table.insert(lines, string.format(statBar, statPair.name .. ":", formattedValue))
	end

	return lines
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
	local screen = MGBA.Screens[MGBA.ScreenKeys.LookupPokemon]
	local pokemonName = ...
	if pokemonName ~= nil and pokemonName ~= "" then
		local pokemonID = DataHelper.findPokemonId(pokemonName)
		if pokemonID ~= 0 then
			pokemonName = PokemonData.Pokemon[pokemonID].name or pokemonName
			print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", pokemonName))
			screen:setData(pokemonID, true)
			Program.redraw(true)
		else
			print(string.format(" Unable to find %s: %s", Constants.Words.POKEMON, pokemonName))
		end
	end
end
function Pokemon(...) pokemon(...) end
function POKEMON(...) pokemon(...) end

---@diagnostic disable-next-line: lowercase-global
function move(...)
	local screen = MGBA.Screens[MGBA.ScreenKeys.LookupMove]
	local moveName = ...
	if moveName ~= nil and moveName ~= "" then
		local moveId = DataHelper.findMoveId(moveName)
		if moveId ~= 0 then
			moveName = MoveData.Moves[moveId].name or moveName
			print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", moveName))
			screen:setData(moveId, true)
			Program.redraw(true)
		else
			print(string.format(" Unable to find move: %s", moveName))
		end
	end
end
function Move(...) move(...) end
function MOVE(...) move(...) end

---@diagnostic disable-next-line: lowercase-global
function ability(...)
	local screen = MGBA.Screens[MGBA.ScreenKeys.LookupAbility]
	local abilityName = ...
	if abilityName ~= nil and abilityName ~= "" then
		local abilityId = DataHelper.findAbilityId(abilityName)
		if abilityId ~= 0 then
			abilityName = AbilityData.Abilities[abilityId].name or abilityName
			print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", abilityName))
			screen:setData(abilityId, true)
			Program.redraw(true)
		else
			print(string.format(" Unable to find ability: %s", abilityName))
		end
	end
end
function Ability(...) ability(...) end
function ABILITY(...) ability(...) end

---@diagnostic disable-next-line: lowercase-global
function route(...)
	local screen = MGBA.Screens[MGBA.ScreenKeys.LookupRoute]
	local routeName = ...
	if routeName ~= nil and routeName ~= "" then
		local routeId = DataHelper.findRouteId(routeName)
		if routeId ~= 0 then
			routeName = RouteData.Info[routeId].name or routeName
			print(string.format(" Game info found for: %s  (check the sidebar menu to view it)", routeName))
			screen:setData(routeId, true)
			Program.redraw(true)
		else
			print(string.format(" Unable to find route: %s", routeName))
		end
	end
end
function Route(...) route(...) end
function ROUTE(...) route(...) end

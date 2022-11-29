-- mGBA Scripting Docs: https://mgba.io/docs/scripting.html
-- Uses Lua 5.4
MGBA = {}

-- Ordered list of things
MGBA.Labels = {
	Screens = { "Lookup Pokémon", "Your Pokémon", },
	Effectiveness = { "Immunity (0x)", "Resist (0.25x)", "Resist (0.5x)", "SuperEffective (2x)", "SuperEffective (4x)", },
}

MGBA.Screens = {
	-- TODO: Add in these later
	-- SETTINGS ☰ MENU ITEM(S)
	-- COMMAND LIST
	-- LOOKUP MOVE INFO
	-- LOOKUP ABILITY INFO
	-- LOOKUP ROUTE INFO

	-- Each screen has this properties set later in createTextBuffers()
	-- self.data: Raw data that hasn't yet been formatted
	-- self.displayLines: Formatted lines that are ready to be displayed
	-- self.textBuffer: The mGBA TextBuffer where the displayLines are printed

	["Lookup Pokémon"] = {
		setData = function(self, pokemonName)
			self.pokemon = DataHelper.findPokemon(pokemonName)
		end,
		updateData = function(self)
			-- TODO: Determine reasons to update this data, such as pokemon ID change or level change
			if self.data == nil or (self.pokemon ~= nil and self.pokemon.pokemonID ~= self.data.p.pokemonID) then
				self.data = DataHelper.buildPokemonInfoDisplay(self.pokemon)
			end
			self.displayLines = MGBA.formatPokemonInfoDisplayLines(self.data)
		end,
	},
	["Your Pokémon"] = {
		updateData = function(self)
			self.data = DataHelper.buildTrackerScreenDisplay()
			self.displayLines = MGBA.formatTrackerScreenDisplayLines(self.data)
		end,
	},
}

MGBA.Symbols = {
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

function MGBA.initialize()
	-- Adjust some written Constants so that they display properly
	Constants.BLANKLINE = "--"
	Constants.STAT_STATES[2].text = "-"
	Constants.Words.POKEMON = "Pokémon"
	Constants.Words.POKE = "Poké"
end

function MGBA.clear()
	-- This "clears" the Console for mGBA
	print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
end

function MGBA.displayInputCommands()
	print('')
	print('Use the following commands via the input text box below:')
	print('note "text to add a note about the active visible Pokémon"')
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

function MGBA.createTextBuffers()
	for _, label in ipairs(MGBA.Labels.Screens) do
		local screen = MGBA.Screens[label]
		if screen.textBuffer == nil then -- workaround for reloading script for Quickload
			screen.textBuffer = console:createBuffer(label)
		end
	end
	-- MGBA.currentScreen = MGBA.Screens["Your Pokémon"] -- not really used (yet?)
end

function MGBA.updateTextBuffers()
	for _, screen in pairs(MGBA.Screens) do
		-- Unlikely, but double-check the text buffer exists
		if screen.textBuffer == nil then
			MGBA.createTextBuffers()
		end

		-- Update the data, if necessary
		screen:updateData()

		-- Display the data
		screen.textBuffer:clear()
		for _, line in ipairs(screen.displayLines) do
			MGBA.printToScreenBuffer(line, screen.textBuffer)
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

	data.p.evodetails = table.concat(data.p.evo, listSeparator)

	if data.p.movelvls == {} or #data.p.movelvls == 0 then
		data.p.moveslearned = "None"
	else
		data.p.moveslearned = table.concat(data.p.movelvls, listSeparator)
	end

	data.e.list = {}
	local effectLabelMappings = {
		[0] = MGBA.Labels.Effectiveness[1],
		[0.25] = MGBA.Labels.Effectiveness[2],
		[0.5] = MGBA.Labels.Effectiveness[3],
		[2] = MGBA.Labels.Effectiveness[4],
		[4] = MGBA.Labels.Effectiveness[5],
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

	-- TODO: Later format these all to fit inside a box, probably

	table.insert(lines, data.p.name)
	table.insert(lines, string.format("%s: %s", "Type", data.p.typeline))
	table.insert(lines, string.format("%s: %s", "BST", data.p.bst))
	table.insert(lines, string.format("%s: %s kg", "Weight", data.p.weight))
	table.insert(lines, string.format("%s: %s", "Evolution", data.p.evodetails))
	table.insert(lines, "")
	table.insert(lines, string.format("%s: %s", "Level-up moves", data.p.moveslearned))
	table.insert(lines, "")

	for _, label in ipairs(MGBA.Labels.Effectiveness) do
		if data.e.list[label] ~= nil then
			table.insert(lines, string.format("%s: %s", label, data.e.list[label]))
		end
	end

	table.insert(lines, "")
	table.insert(lines, string.format("%s: %s", "Note", data.x.note))

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
			Program.redraw(true)
		end
	end
end
function Note(...) note(...) end

---@diagnostic disable-next-line: lowercase-global
function pokemon(...)
	local pokemonName = ...

	if pokemonName ~= nil and pokemonName ~= "" then
		MGBA.Screens["Lookup Pokémon"]:setData(pokemonName)
		Program.redraw(true)
	end
end
function Pokemon(...) pokemon(...) end
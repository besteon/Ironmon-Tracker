MGBA = {
	-- TextBuffer screens
	Screens = {
	},
	currentScreen = nil,
}

MGBA.Symbols = {
	Stab = "=",
	Effectiveness = {
		[0] = "X",
		[0.25] = "~",
		[0.5] = "-",
		[1] = " ",
		[2] = "+",
		[4] = "*",
	},
	Category = {
		[MoveData.Categories.STATUS] = " ",
		[MoveData.Categories.PHYSICAL] = "P",
		[MoveData.Categories.SPECIAL] = "S",
	},
}

function MGBA.initialize()
	-- Currently unused
end

-- Prints `line` to the mGBA TextBuffer 'MGBA.currentScreen' or optionally the `screenBuffer`
function MGBA.printToScreenBuffer(line, screenBuffer)
	line = line or ""
	screenBuffer = screenBuffer or MGBA.currentScreen
	if screenBuffer ~= nil then
		screenBuffer:print(line .. "\n")
	end
end

function MGBA.createTextBuffers()
	local screens = { "☰ Menu", "Your Pokémon", }--"Enemy Pokémon" }
	for _, screen in ipairs(screens) do
		MGBA.Screens[screen] = console:createBuffer(screen)
	end
	MGBA.currentScreen = MGBA.Screens["Your Pokémon"]
end

function MGBA.updateTextBuffers()
	local screen = MGBA.Screens["Your Pokémon"]
	local data = DataHelper.buildTrackerScreenDisplay()

	MGBA.formatTrackerScreenData(data)
	local displayBoxes = MGBA.formatTrackerScreenDisplayLines(data)

	screen:clear()
	-- screen:moveCursor(0, 0) -- not sure when/how to use this yet

	for _, boxLineSet in ipairs(displayBoxes) do
		for _, line in ipairs(boxLineSet) do
			MGBA.printToScreenBuffer(line, screen)
		end
	end

	-- screen = MGBA.Screens["Enemy Pokémon"]
	-- data = DataHelper.buildTrackerScreenDisplay(false)
	-- MGBA.formatTrackerScreenData(data)
	-- displayBoxes = MGBA.formatTrackerScreenDisplayLines(data)

	-- screen:clear()
	-- for _, boxLineSet in ipairs(displayBoxes) do
	-- 	for _, line in ipairs(boxLineSet) do
	-- 		MGBA.printToScreenBuffer(line, screen)
	-- 	end
	-- end
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
	if data.p.types[2] ~= data.p.types[1] and data.p.types[2] ~= nil then
		data.p.types = string.format("%s/%s", Utils.firstToUpper(data.p.types[1]), Utils.firstToUpper(data.p.types[2]))
	else
		data.p.types = Utils.firstToUpper(data.p.types[1] or Constants.BLANKLINE)
	end

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
	local topLines, botLines, footerLines = {}, {}, {}

	-- %-#s means to left-align, padding out the right-part of the string with spaces
	local justify3 = Utils.inlineIf(Options["Right justified numbers"], "%3s", "%-3s")

	local formattedStats = {}
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		formattedStats[statKey] = string.format("%-5s" .. justify3 .. "%-2s", data.p.labels[statKey], data.p[statKey], data.p.stages[statKey])
	end

	-- Header and top dividing line (with types)
	topLines[1] = string.format("%-23s%-5s%-5s", string.format("%-13s %-3s", data.p.name, data.p.status), "BST", data.p.bst)
	topLines[2] = string.format("%-23s%-10s", data.p.types, "----------")

	-- Top six lines of the box: Pokemon related stuff
	local topFormattedLine = "%-23s%-10s"
	local levelLine = string.format("Lv.%s (%s)", data.p.level, data.p.evo)
	if data.x.viewingOwn then
		local hpLine = string.format("HP: %s/%s", data.p.curHP, data.p.hp)
		topLines[3] = string.format(topFormattedLine, hpLine, formattedStats.hp)
		topLines[4] = string.format(topFormattedLine, levelLine, formattedStats.atk)

		if Options["Track PC Heals"] then
			local survivalHeals = string.format("Survival PCs: %s", data.x.pcheals)
			topLines[7] = string.format(topFormattedLine, survivalHeals, formattedStats.spd)
		else
			topLines[7] = string.format(topFormattedLine, "", formattedStats.spd)
		end

		local availableHeals = string.format("Heals: %.0f%% (%s)", data.x.healperc, data.x.healnum)
		topLines[8] = string.format(topFormattedLine, availableHeals, formattedStats.spe)
	else
		topLines[3] = string.format(topFormattedLine, levelLine, formattedStats.hp)

		local lastLevelSeen
		if data.p.lastlevel ~= nil and data.p.lastlevel ~= "" then
			lastLevelSeen = string.format("Last seen Lv.%s", data.p.lastlevel)
		else
			lastLevelSeen = "New encounter!"
		end
		topLines[4] = string.format(topFormattedLine, lastLevelSeen, formattedStats.atk)

		local encountersText = string.format("Seen %s: %s", Utils.inlineIf(Battle.isWildEncounter, "in the wild", "on trainers"), data.x.encounters)
		topLines[7] = string.format(topFormattedLine, encountersText, formattedStats.spd)
		topLines[8] = string.format(topFormattedLine, data.x.route, formattedStats.spe)
	end

	topLines[5] = string.format(topFormattedLine, data.p.line1, formattedStats.def)
	topLines[6] = string.format(topFormattedLine, data.p.line2, formattedStats.spa)
	table.insert(topLines, "")

	-- Bottom five lines of the box: Move related stuff
	local botFormattedLine = "%-20s%-3s%-6s%-4s"
	table.insert(botLines, string.format("%-20s%-3s%-6s%-4s", data.m.nextmoveheader, "PP", " Pow", "Acc"))
	table.insert(botLines, "---------------------------------")
	for i, move in ipairs(data.m.moves) do
		local nameText = move.name
		if Options["Show physical special icons"] and (data.x.viewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType) then
			nameText = (MGBA.Symbols.Category[move.category] or " ") .. " " .. nameText
		end

		local powerText = string.format(justify3, move.power):sub(1, 3)
		if move.showeffective then
			powerText = (MGBA.Symbols.Effectiveness[move.effectiveness] or " ") .. powerText
		else
			powerText = " " .. powerText
		end
		if move.isstab then
			powerText = powerText .. MGBA.Symbols.Stab
		end

		table.insert(botLines, string.format(botFormattedLine, nameText, move.pp, powerText, move.accuracy))
	end
	table.insert(botLines, "---------------------------------")

	-- Footer, carousel related stuff
	-- local botFormattedLine = "%-33s"
	for _, carousel in ipairs(TrackerScreen.CarouselItems) do
		if carousel.isVisible() then
			local carouselText = MGBA.convertCarouselToText(carousel, data.p.id)
			table.insert(footerLines, carouselText)
		end
	end

	return { topLines, botLines, footerLines, }
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
		carouselText = carouselContent[1].text or ""
	elseif carousel.type == TrackerScreen.CarouselTypes.ROUTE_INFO then
		carouselText = carouselContent[1].text or ""
	elseif carousel.type == TrackerScreen.CarouselTypes.NOTES then
		carouselText = "Note: "
		if type(carouselContent[1]) ~= nil and type(carouselContent[1]) == "string" then
			carouselText = carouselText .. carouselContent[1]
		end
	elseif carousel.type == TrackerScreen.CarouselTypes.PEDOMETER then
		carouselText = carouselContent[1].text or ""
	end

	return carouselText
end
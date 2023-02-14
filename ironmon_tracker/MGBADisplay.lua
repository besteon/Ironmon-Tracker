MGBADisplay = {}

MGBADisplay.Symbols = {
	StabL = "[",
	StabR = "]",
	Effectiveness = { -- 2 char width, right-aligned
		[0] = " X",
		[0.25] = "--",
		[0.5] = " -",
		[1] = "  ",
		[2] = " +",
		[4] = "++",
	},
	Category = {
		[MoveData.Categories.STATUS] = " ",
		[MoveData.Categories.PHYSICAL] = "P",
		[MoveData.Categories.SPECIAL] = "S",
	},
	Options = {
		Enabled = "X",
		Disabled = " ",
	}
}
-- Ordered list of things
MGBADisplay.OrderedLists = {
	Effectiveness = { "0x Immunities", "1/4x Resistances", "1/2x Resistances", "2x Weaknesses", "4x Weaknesses", },
}

function MGBADisplay.initialize()
	if Main.IsOnBizhawk() then return end
	-- Currently unused
end

MGBADisplay.DataFormatter = {
	formatPokemonInfo = function(data)
		local listSeparator = ", "

		data.p.name = data.p.name:upper()

		-- Format type as "Normal" or "Flying/Normal"
		if data.p.types[2] ~= PokemonData.Types.EMPTY and data.p.types[2] ~= data.p.types[1] then
			data.p.typeline = Utils.formatUTF8("%s/%s", Utils.firstToUpper(data.p.types[1]), Utils.firstToUpper(data.p.types[2]))
		else
			data.p.typeline = Utils.firstToUpper(data.p.types[1] or Constants.BLANKLINE)
		end

		if tonumber(data.p.weight) ~= nil then
			data.p.weight = Utils.formatUTF8("%s kg", data.p.weight)
		else
			data.p.weight = Constants.BLANKLINE
		end
		data.p.evodetails = table.concat(data.p.evo, listSeparator)
		if data.p.evodetails == Constants.BLANKLINE then
			data.p.evodetails = "None"
		end

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
			[0] = MGBADisplay.OrderedLists.Effectiveness[1],
			[0.25] = MGBADisplay.OrderedLists.Effectiveness[2],
			[0.5] = MGBADisplay.OrderedLists.Effectiveness[3],
			[2] = MGBADisplay.OrderedLists.Effectiveness[4],
			[4] = MGBADisplay.OrderedLists.Effectiveness[5],
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
	end,
	formatMoveInfo = function(data)
		data.m.name = data.m.name:upper()
		data.m.type = Utils.firstToUpper(data.m.type)

		if tonumber(data.m.accuracy) ~= nil then
			data.m.accuracy = data.m.accuracy .. "%"
		end

		if data.m.category == MoveData.Categories.PHYSICAL or data.m.category == MoveData.Categories.SPECIAL then
			data.m.category = Utils.formatUTF8("%s (%s)", data.m.category, MGBADisplay.Symbols.Category[data.m.category])
		end

		data.m.iscontact = Utils.inlineIf(data.m.iscontact, "Yes", "No")

		if data.m.priority == "0" then
			data.m.priority = "Normal"
		end
	end,
	formatRouteInfo = function(data)
		local unseenPokemon = "???"
		local justify4 = Utils.inlineIf(Options["Right justified numbers"], "%4s", "%-4s")
		local originalPokemonBar = " %-12s  " .. justify4 .. "    %s"

		if not RouteData.hasRoute(data.r.id) then
			data.r.name = Utils.formatUTF8("UNKNOWN AREA (%s)", math.floor(data.r.id))
		else
			data.r.name = data.r.name:upper()
		end

		for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
			local area = data.e[encounterArea]

			area.originalLines = {}
			for _, enc in ipairs(area.originalPokemon) do
				local name = PokemonData.Pokemon[enc.pokemonID].name
				local rate = math.floor(enc.rate * 100) .. "%"
				local level = "Lv."
				if enc.minLv ~= 0 then
					if enc.maxLv ~= 0 and enc.minLv ~= enc.maxLv then
						level = Utils.formatUTF8("Lv.%s-%s", math.floor(enc.minLv), math.floor(enc.maxLv))
					else
						level = Utils.formatUTF8("Lv.%s", math.floor(enc.minLv))
					end
				else
					level = ""
				end
				table.insert(area.originalLines, Utils.formatUTF8(originalPokemonBar, name, rate, level))
			end

			area.trackedLines = {}
			for i = 1, area.totalPossible, 1 do
				if PokemonData.isValid(area.trackedIDs[i]) then
					table.insert(area.trackedLines, Utils.formatUTF8(" %s", PokemonData.Pokemon[area.trackedIDs[i]].name))
				else
					table.insert(area.trackedLines, Utils.formatUTF8(" %s", unseenPokemon))
				end
			end
		end
	end,
	formatTrackerScreen = function(data)
		data.p.name = data.p.name:upper()

		if data.p.evo == PokemonData.Evolutions.NONE then
			data.p.evo = Constants.BLANKLINE
		end

		if data.p.status ~= "" then
			data.p.status = Utils.formatUTF8("[%s]", data.p.status)
		end

		-- Format type as "Normal" or "Flying/Normal"
		if data.p.types[2] ~= PokemonData.Types.EMPTY and data.p.types[2] ~= data.p.types[1] then
			data.p.typeline = Utils.formatUTF8("%s/%s", Utils.firstToUpper(data.p.types[1]), Utils.firstToUpper(data.p.types[2]))
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
				data.p[statKey] = Utils.formatUTF8(" %s ", Constants.STAT_STATES[statBtn.statState or 0].text)
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
			data.p[selectedStat] = Utils.formatUTF8("[%s]", data.p[selectedStat]:sub(2, 2))
		end

		for _, move in ipairs(data.m.moves) do
			move.name = move.name .. Utils.inlineIf(move.starred, "*", "")
			move.type = Utils.firstToUpper(move.type)
		end
	end,
}

MGBADisplay.LineBuilder = {
	buildTrackerSetup = function()
		local lines = {}

		local optionBar = "%-2s %-26s [%s]"
		local controlBar = "%-2s %-21s %8s"
		table.insert(lines, MGBA.Screens.TrackerSetup.headerText:upper())
		table.insert(lines, "---------------------------------")
		table.insert(lines, 'Toggle option with: OPTION "#"')

		table.insert(lines, Utils.formatUTF8("%-2s %-20s [%s]", "#", "Option", "Enabled"))
		for i = 1, 8, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(optionBar, i, opt.displayName, opt:getValue()))
			end
		end

		table.insert(lines, "---------------------------------")
		table.insert(lines, 'Change with: OPTION "# button(s)"')
		table.insert(lines, Utils.formatUTF8("%-2s %-13s %16s", "#", "Controls", "GBA Buttons"))
		for i = 10, 12, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(controlBar, i, opt.displayName, opt:getValue()))
			end
		end
		local qid = 13 -- "Quickload"
		if MGBA.OptionMap[qid] ~= nil then
			table.insert(lines, Utils.formatUTF8("%-2s %-13s %16s", qid, MGBA.OptionMap[qid].displayName, MGBA.OptionMap[qid]:getValue()))
		end

		table.insert(lines, "---------------------------------")

		return lines
	end,
	buildGameplayOptions = function()
		local lines = {}

		local optionBar = "%-2s %-26s [%s]"
		table.insert(lines, MGBA.Screens.GameplayOptions.headerText:upper())
		table.insert(lines, "---------------------------------")
		table.insert(lines, 'Toggle option with: OPTION "#"')

		table.insert(lines, Utils.formatUTF8("%-2s %-20s [%s]", "#", "Option", "Enabled"))
		for i = 20, 28, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(optionBar, i, opt.displayName, opt:getValue()))
			end
		end
		table.insert(lines, "---------------------------------")
		table.insert(lines, "Manually save/load tracked data:")
		table.insert(lines, ' SAVEDATA "filename"')
		table.insert(lines, ' LOADDATA "filename"')
		table.insert(lines, ' CLEARDATA()')
		table.insert(lines, "---------------------------------")

		return lines
	end,
	buildQuickloadSetup = function()
		local lines = {}

		local optionBar = "%-2s %-26s [%s]"
		table.insert(lines, MGBA.Screens.QuickloadSetup.headerText:upper())
		table.insert(lines, "---------------------------------")
		MGBADisplay.Utils.addLinesWrapped(lines, "To use either Quickload option, put the required files in the [quickload] folder found in your main Tracker folder.")
		table.insert(lines, "---------------------------------")

		table.insert(lines, 'Choose a mode with: OPTION "#"')
		table.insert(lines, Utils.formatUTF8("%-2s %-19s [%s]", "#", "Mode", "Selected"))

		for i = 30, 31, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(optionBar, i, opt.displayName, opt:getValue()))
			end
		end
		table.insert(lines, "")

		-- local fileBar = "%-2s %-30s"
		if MGBA.OptionMap[30] ~= nil and MGBA.OptionMap[30]:getValue() == MGBADisplay.Symbols.Options.Enabled then
			-- local romFolderId = 32
			-- local opt = MGBA.OptionMap[romFolderId]
			-- if opt ~= nil then
			-- 	local foldername = opt:getValue()
			-- 	if foldername == "" then
			-- 		foldername = "(NOT SET)"
			-- 	end
			-- 	table.insert(lines, Utils.formatUTF8(fileBar, romFolderId, opt.displayName .. " *"))
			-- 	table.insert(lines, Utils.formatUTF8(" %-32s", foldername))
			-- end
			-- table.insert(lines, "")
			-- table.insert(lines, '* Set above files in Settings.ini')
			-- table.insert(lines, 'Set folder using: OPTION "# path"') -- temp hide this option from user
			table.insert(lines, "Required Files:")
			table.insert(lines, "- Multiple GBA ROM files with #'s")
			table.insert(lines, "")
			table.insert(lines, "")
		elseif MGBA.OptionMap[31] ~= nil and MGBA.OptionMap[31]:getValue() == MGBADisplay.Symbols.Options.Enabled then
			-- for i = 33, 35, 1 do
			-- 	local opt = MGBA.OptionMap[i]
			-- 	if opt ~= nil then
			-- 		local filename = opt:getValue()
			-- 		if filename:len() > 32 then
			-- 			filename = filename:sub(1, 29) .. "..."
			-- 		elseif filename == "" then
			-- 			filename = "(NOT SET)"
			-- 		end
			-- 		table.insert(lines, Utils.formatUTF8(fileBar, i, opt.displayName .. ": *"))
			-- 		table.insert(lines, Utils.formatUTF8(" %-32s", filename))
			-- 		table.insert(lines, "")
			-- 	end
			-- end
			-- table.insert(lines, '* Set above files in Settings.ini')
			-- table.insert(lines, 'Set file: OPTION "# filepath"') -- temp hide this option from user
			table.insert(lines, "Required Files (only 1 of each):")
			table.insert(lines, "- JAR file from your Randomizer")
			table.insert(lines, "- RNQS Randomizer settings file")
			table.insert(lines, "- GBA ROM file to randomize")
		end

		table.insert(lines, "---------------------------------")

		local instructionBar = "%-14s %-18s"
		local quickloadCombo = Options.CONTROLS["Load next seed"]:gsub(" ", ""):gsub(",", " + ")
		table.insert(lines, Utils.formatUTF8(instructionBar, "Button Combo:", quickloadCombo))
		table.insert(lines, Utils.formatUTF8(instructionBar, "Text Command:", MGBA.CommandMap["QUICKLOAD"].usageExample))
		table.insert(lines, "")

		return lines
	end,
	buildUpdateCheck = function()
		local lines = {}

		local columnBar = "%-26s%-7s"
		table.insert(lines, MGBA.Screens.UpdateCheck.headerText:upper())
		table.insert(lines, "---------------------------------")

		local versionStatus
		if Main.isOnLatestVersion() then
			versionStatus = "Last checked version:"
		else
			versionStatus = "New version available:"
			table.insert(lines, "  New version update available!")
			table.insert(lines, "")
		end
		table.insert(lines, Utils.formatUTF8(columnBar, "Current version:", Main.TrackerVersion or Constants.BLANKLINE))
		table.insert(lines, Utils.formatUTF8(columnBar, versionStatus, Main.Version.latestAvailable or Constants.BLANKLINE))
		table.insert(lines, "---------------------------------")

		table.insert(lines, "Manually check for new updates:")
		table.insert(lines, " CHECKUPDATE()")
		table.insert(lines, "")
		table.insert(lines, "View release notes:")
		table.insert(lines, " RELEASENOTES()")
		table.insert(lines, "")
		table.insert(lines, "Download & install automatically:")
		table.insert(lines, " UPDATENOW()")
		table.insert(lines, "---------------------------------")

		return lines
	end,
	buildCommandsBasic = function()
		local lines = {}

		local commandBar = " %-10s%-s"
		table.insert(lines, MGBA.Screens.CommandsBasic.headerText:upper())

		local usageInstructions = 'To use, type into below textbox. Example command: POKEMON "Espeon"'
		MGBADisplay.Utils.addLinesWrapped(lines, usageInstructions)
		table.insert(lines, "")

		local commandList = {
			MGBA.CommandMap["POKEMON"],
			MGBA.CommandMap["MOVE"],
			MGBA.CommandMap["ABILITY"],
			MGBA.CommandMap["ROUTE"],
			MGBA.CommandMap["NOTE"],
		}

		table.insert(lines, "Usage Syntax:")
		for _, command in ipairs(commandList) do
			if command.usageSyntax ~= nil then
				local commandName, commandParams = MGBADisplay.Utils.splitCommandUsage(command.usageSyntax)
				table.insert(lines, Utils.formatUTF8(commandBar, commandName, commandParams))
			end
		end
		table.insert(lines, "")

		table.insert(lines, "Example Usage:")
		for _, command in ipairs(commandList) do
			if command.usageExample ~= nil then
				local commandName, commandParams = MGBADisplay.Utils.splitCommandUsage(command.usageExample)
				table.insert(lines, Utils.formatUTF8(commandBar, commandName, commandParams))
			end
		end

		return lines
	end,
	buildCommandsOther = function()
		local lines = {}

		local commandBar = " %-13s%-s"
		table.insert(lines, MGBA.Screens.CommandsOther.headerText:upper())

		local usageInstructions = 'To use, type into below textbox. Example command: PCHEALS "10"'
		MGBADisplay.Utils.addLinesWrapped(lines, usageInstructions)
		table.insert(lines, "")

		local commandList = {
			MGBA.CommandMap["HELP"],
			MGBA.CommandMap["PCHEALS"],
			MGBA.CommandMap["HIDDENPOWER"],
			MGBA.CommandMap["ATTEMPTS"],
			MGBA.CommandMap["RANDOMBALL"],
			MGBA.CommandMap["HELPWIKI"],
			MGBA.CommandMap["CREDITS"],
			MGBA.CommandMap["ALLCOMMANDS"],
		}

		table.insert(lines, "Usage Syntax:")
		for _, command in ipairs(commandList) do
			if command.usageSyntax ~= nil then
				local commandName, commandParams = MGBADisplay.Utils.splitCommandUsage(command.usageSyntax)
				table.insert(lines, Utils.formatUTF8(commandBar, commandName, commandParams))
			end
		end
		table.insert(lines, "")

		table.insert(lines, "Example Usage:")
		for _, command in ipairs(commandList) do
			if command.usageExample ~= nil then
				local commandName, commandParams = MGBADisplay.Utils.splitCommandUsage(command.usageExample)
				table.insert(lines, Utils.formatUTF8(commandBar, commandName, commandParams))
			end
		end

		return lines
	end,
	buildPokemonInfo = function(data)
		local lines = {}

		MGBADisplay.DataFormatter.formatPokemonInfo(data)

		local labelBar = "%-12s %s"
		table.insert(lines, Utils.formatUTF8("%-13s%s", data.p.name, Utils.formatUTF8("[%s]", data.p.typeline)))
		table.insert(lines, Utils.formatUTF8(labelBar, "BST:", data.p.bst))
		table.insert(lines, Utils.formatUTF8(labelBar, "Weight:", data.p.weight))
		table.insert(lines, Utils.formatUTF8(labelBar, "Evolution:", data.p.evodetails))

		table.insert(lines, "")
		table.insert(lines, "Level-up moves:")
		MGBADisplay.Utils.addLinesWrapped(lines, data.p.moveslearned)

		table.insert(lines, "")
		for _, label in ipairs(MGBADisplay.OrderedLists.Effectiveness) do
			if data.e.list[label] ~= nil then
				table.insert(lines, Utils.formatUTF8("%s:", label))
				MGBADisplay.Utils.addLinesWrapped(lines, Utils.formatUTF8(" %s", data.e.list[label]))
			end
		end

		table.insert(lines, "")
		table.insert(lines, "Note:")
		MGBADisplay.Utils.addLinesWrapped(lines, data.x.note)

		return lines
	end,
	buildMoveInfo = function(data)
		local lines = {}

		MGBADisplay.DataFormatter.formatMoveInfo(data)

		local labelBar = "%-12s %s"
		table.insert(lines, Utils.formatUTF8(labelBar, data.m.name, Utils.formatUTF8("[%s]", data.m.type)))
		table.insert(lines, Utils.formatUTF8(labelBar, "Category:", data.m.category))
		table.insert(lines, Utils.formatUTF8(labelBar, "Contact:", data.m.iscontact))
		table.insert(lines, Utils.formatUTF8(labelBar, "PP:", data.m.pp))
		table.insert(lines, Utils.formatUTF8(labelBar, "Power:", data.m.power))
		table.insert(lines, Utils.formatUTF8(labelBar, "Accuracy:", data.m.accuracy))
		table.insert(lines, Utils.formatUTF8(labelBar, "Priority:", data.m.priority))

		if data.m.summary ~= Constants.BLANKLINE then
			table.insert(lines, "")
			table.insert(lines, "Move Summary:")
			MGBADisplay.Utils.addLinesWrapped(lines, data.m.summary)
		end

		return lines
	end,
	buildAbilityInfo = function(data)
		local lines = {}

		table.insert(lines, data.a.name:upper())

		table.insert(lines, "")
		MGBADisplay.Utils.addLinesWrapped(lines, data.a.description)


		if data.a.descriptionEmerald ~= Constants.BLANKLINE then
			table.insert(lines, "")
			table.insert(lines, "Emerald Bonus:")
			MGBADisplay.Utils.addLinesWrapped(lines, data.a.descriptionEmerald)
		end

		return lines
	end,
	buildRouteInfo = function(data)
		local lines = {}

		MGBADisplay.DataFormatter.formatRouteInfo(data)

		table.insert(lines, Utils.formatUTF8("%-22s%11s", data.r.name, "[Tracked]"))
		table.insert(lines, "")

		-- No wild encounters, such as a building, don't show anything else
		if data.r.totalWildEncounters == 0 and data.r.totalTrainerEncounters == 0 then
			return lines
		end

		for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
			local area = data.e[encounterArea]
			if area.totalPossible > 0 then -- Only display areas that have encounters
				table.insert(lines, Utils.formatUTF8("%s (%s/%s seen)", encounterArea, area.totalSeen, area.totalPossible))
				for _, line in ipairs(area.trackedLines) do
					table.insert(lines, line)
				end
			end
		end

		return lines
	end,
	buildOriginalRouteInfo = function(data)
		local lines = {}

		table.insert(lines, Utils.formatUTF8("%-22s%11s", data.r.name, "[Original]"))
		table.insert(lines, "")

		-- No wild encounters, such as a building, don't show anything else
		if data.r.totalWildEncounters == 0 and data.r.totalTrainerEncounters == 0 then
			return lines
		end

		for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
			local area = data.e[encounterArea]
			if area.totalPossible > 0 then -- Only display areas that have encounters
				table.insert(lines, Utils.formatUTF8("%s (%s/%s seen)", encounterArea, area.totalSeen, area.totalPossible))
				for _, line in ipairs(area.originalLines) do
					table.insert(lines, line)
				end
			end
		end

		return lines
	end,
	buildStats = function()
		local lines = {}

		local statBar = "%-21s%s"
		table.insert(lines, MGBA.Screens.Stats.headerText:upper())
		table.insert(lines, "")

		for _, statPair in ipairs(StatsScreen.StatTables) do
			statPair.name = statPair.name:gsub("é", "e") -- The 'é' character doesn't work with format padding like %-20s
			local formattedValue = Utils.formatNumberWithCommas(statPair.getValue() or 0)
			table.insert(lines, Utils.formatUTF8(statBar, statPair.name .. ":", formattedValue))
		end

		return lines
	end,
	buildTrackerScreen = function(data)
		local lines = {}

		MGBADisplay.DataFormatter.formatTrackerScreen(data)

		-- %-#s means to left-align, padding out the right-part of the string with spaces
		local justify2 = Utils.inlineIf(Options["Right justified numbers"], "%2s", "%-2s")
		local justify3 = Utils.inlineIf(Options["Right justified numbers"], "%3s", "%-3s")
		local justify5 = Utils.inlineIf(Options["Right justified numbers"], "%5s", "%-5s")

		local formattedStats = {}
		for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local statText = Utils.inlineIf(data.p[statKey] ~= 0, data.p[statKey], Constants.BLANKLINE)
			formattedStats[statKey] = Utils.formatUTF8("%-5s" .. justify3 .. "%-2s", data.p.labels[statKey], statText, data.p.stages[statKey])
		end

		-- Header and top dividing line (with types)
		local bstAligned = Utils.formatUTF8(justify3, data.p.bst)
		lines[1] = Utils.formatUTF8("%-23s%-5s%-5s", Utils.formatUTF8("%-13s %-3s", data.p.name, data.p.status), "BST", bstAligned)
		lines[2] = Utils.formatUTF8("%-23s%-10s", data.p.typeline, "----------")

		-- Top six lines of the box: Pokemon related stuff
		local topFormattedLine = "%-23s%-10s"
		local levelLine = Utils.formatUTF8("Lv.%s (%s)", data.p.level, data.p.evo)
		if data.x.viewingOwn then
			local hpLine = Utils.formatUTF8("HP: %s/%s", data.p.curHP, data.p.hp)
			lines[3] = Utils.formatUTF8(topFormattedLine, hpLine, formattedStats.hp)
			lines[4] = Utils.formatUTF8(topFormattedLine, levelLine, formattedStats.atk)

			if Options["Track PC Heals"] then
				local survivalHeals = Utils.formatUTF8("Survival PCs: %s", data.x.pcheals)
				lines[7] = Utils.formatUTF8(topFormattedLine, survivalHeals, formattedStats.spd)
			else
				lines[7] = Utils.formatUTF8(topFormattedLine, "", formattedStats.spd)
			end

			local availableHeals = Utils.formatUTF8("Heals: %.0f%% (%s)", data.x.healperc, data.x.healnum)
			lines[8] = Utils.formatUTF8(topFormattedLine, availableHeals, formattedStats.spe)
		else
			lines[3] = Utils.formatUTF8(topFormattedLine, levelLine, formattedStats.hp)

			local lastLevelSeen
			if data.p.lastlevel ~= nil and data.p.lastlevel ~= "" then
				lastLevelSeen = Utils.formatUTF8("Last seen Lv.%s", data.p.lastlevel)
			else
				lastLevelSeen = "New encounter!"
			end
			lines[4] = Utils.formatUTF8(topFormattedLine, lastLevelSeen, formattedStats.atk)

			local encountersText = Utils.formatUTF8("Seen %s: %s", Utils.inlineIf(Battle.isWildEncounter, "in the wild", "on trainers"), data.x.encounters)
			lines[7] = Utils.formatUTF8(topFormattedLine, encountersText, formattedStats.spd)
			lines[8] = Utils.formatUTF8(topFormattedLine, data.x.route, formattedStats.spe)
		end

		lines[5] = Utils.formatUTF8(topFormattedLine, data.p.line1, formattedStats.def)
		lines[6] = Utils.formatUTF8(topFormattedLine, data.p.line2, formattedStats.spa)
		table.insert(lines, "")

		-- Bottom five lines of the box: Move related stuff
		local botFormattedLine = "%-18s%-3s%-7s  %-3s"
		local moveHeader = Utils.formatUTF8(botFormattedLine, data.m.nextmoveheader, "PP", "   Pow", "Acc")
		local moveDivider = "---------------------------------"
		if Theme.MOVE_TYPES_ENABLED then
			moveHeader = string.format("%s   %s", moveHeader, "Type")
			moveDivider = string.format("%s   %s", moveDivider, "------")
		end
		table.insert(lines, moveHeader)
		table.insert(lines, moveDivider)
		for i, move in ipairs(data.m.moves) do
			local nameText = move.name
			if Options["Show physical special icons"] and (data.x.viewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType) then
				nameText = (MGBADisplay.Symbols.Category[move.category] or " ") .. " " .. nameText
			end

			local ppAligned = Utils.formatUTF8(justify2, move.pp)
			local accuracyAligned = Utils.formatUTF8(justify3, move.accuracy)
			local powerText = tostring(move.power):sub(1, 3) -- for move powers with too much text (eg "100x")

			if move.isstab then
				powerText = MGBADisplay.Symbols.StabL .. powerText .. MGBADisplay.Symbols.StabR
			else
				powerText = " " .. powerText .. " "
			end
			powerText = Utils.formatUTF8(justify5, powerText)

			if move.showeffective then
				powerText = (MGBADisplay.Symbols.Effectiveness[move.effectiveness] or "  ") .. powerText
			else
				powerText = (MGBADisplay.Symbols.Effectiveness[1] or "  ") .. powerText
			end

			local moveLine = Utils.formatUTF8(botFormattedLine, nameText, ppAligned, powerText, accuracyAligned)

			-- Append the move type as text if this option is enabled (ON by default)
			-- Note: this goes out of bounds of the normal Tracker box, but really no other good solution
			if Theme.MOVE_TYPES_ENABLED then
				moveLine = string.format("%s   %s", moveLine, move.type or MoveData.BlankMove.type)
			end

			table.insert(lines, moveLine)
		end
		table.insert(lines, "---------------------------------")

		-- Footer, carousel related stuff
		-- local botFormattedLine = "%-33s"
		for _, carousel in ipairs(TrackerScreen.CarouselItems) do
			if carousel.isVisible() then
				local carouselText = MGBADisplay.Utils.carouselToText(carousel, data.p.id)
				table.insert(lines, carouselText)
			end
		end
		if Options["Display repel usage"] and Program.ActiveRepel.inUse and not (Battle.inBattle or Battle.battleStarting) then
			local repelBarSize = 20
			local remainingFraction = math.floor(Program.ActiveRepel.stepCount * repelBarSize / Program.ActiveRepel.duration)
			local repelFillBar = string.rep("=", remainingFraction)
			if Program.ActiveRepel.stepCount > 0 then
				repelFillBar = Utils.formatUTF8("%-".. repelBarSize .. "s", repelFillBar)
				table.insert(lines, Utils.formatUTF8("Repel: %26s", Utils.formatUTF8("[%s]", repelFillBar))) -- right-align
			end
		end
		table.insert(lines, "---------------------------------")

		return lines
	end,
}

MGBADisplay.Utils = {
	-- Returns two results: updated display lines and true/false, true if lines were updated
	tryUpdatingLines = function(formattingFunction, prevDisplayLines, data)
		prevDisplayLines = prevDisplayLines or {}
		local newDisplayLines = formattingFunction(data) or {}
		local isUpdated = #prevDisplayLines == 0 or table.concat(prevDisplayLines) ~= table.concat(newDisplayLines)
		return newDisplayLines, isUpdated
	end,
	addLinesWrapped = function(linesTable, text, width)
		if text == nil then return end
		width = width or MGBA.ScreenUtils.screenWidth

		if string.len(text) <= width then
			table.insert(linesTable, text)
		else
			for _, line in pairs(Utils.getWordWrapLines(text, width)) do
				table.insert(linesTable, line)
			end
		end
	end,
	-- Returns two separate results, the 'head', or first word, and the 'tail', or the remainder of the words after a space
	splitCommandUsage = function(usageText)
		if usageText:find("%s") == nil then return usageText, "" end -- single word, no spaces
		local head, _, tail = usageText:match('^([%w%p]+)(%s+)(.+)')
		return head, tail
	end,
	carouselToText = function(carousel, pokemonID)
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
	end,
}
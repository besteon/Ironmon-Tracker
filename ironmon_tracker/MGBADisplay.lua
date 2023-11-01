MGBADisplay = {}

MGBADisplay.Symbols = {
	EmptyLine = "",
	DividerLine = string.rep("-", 33), -- "---------------------------------"
	StabL = "[",
	StabR = "]",
	OptionEnabled = "X",
	OptionDisabled = " ",
}

MGBADisplay.Categories = {
	[MoveData.Categories.STATUS] = {
		getText = function(self) return Resources.MGBAScreens.LabelStatus end,
		getSymbol = function(self) return Resources.MGBAScreens.SymbolStatus end,
		getShorthand = function(self) return Utils.formatUTF8("%s", self:getText()) end,
	},
	[MoveData.Categories.PHYSICAL] = {
		getText = function(self) return Resources.MGBAScreens.LabelPhysical end,
		getSymbol = function(self) return Resources.MGBAScreens.SymbolPhysical end,
		getShorthand = function(self) return Utils.formatUTF8("%s (%s)", self:getText(), self:getSymbol()) end,
	},
	[MoveData.Categories.SPECIAL] = {
		getText = function(self) return Resources.MGBAScreens.LabelSpecial end,
		getSymbol = function(self) return Resources.MGBAScreens.SymbolSpecial end,
		getShorthand = function(self) return Utils.formatUTF8("%s (%s)", self:getText(), self:getSymbol()) end,
	},
	[MoveData.Categories.NONE] = {
		getText = function(self) return "" end,
		getSymbol = function(self) return "" end,
		getShorthand = function(self) return "" end,
	},
}

MGBADisplay.Effectiveness = {
	[0] = {
		getText = function(self) return "0x " .. Resources.MGBAScreens.LabelImmunities end,
		getSymbol = function(self) return " " .. Resources.MGBAScreens.SymbolEffectivenessImmune end,
	},
	[0.25] = {
		getText = function(self) return "1/4x " .. Resources.MGBAScreens.LabelResistances end,
		getSymbol = function(self) return Resources.MGBAScreens.SymbolEffectivenessResistDouble end,
	},
	[0.5] = {
		getText = function(self) return "1/2x " .. Resources.MGBAScreens.LabelResistances end,
		getSymbol = function(self) return " " .. Resources.MGBAScreens.SymbolEffectivenessResist end,
	},
	[1] = {
		getText = function(self) return "1x " end, -- Unused
		getSymbol = function(self) return "  " end,
	},
	[2] = {
		getText = function(self) return "2x " .. Resources.MGBAScreens.LabelWeaknesses end,
		getSymbol = function(self) return " " .. Resources.MGBAScreens.SymbolEffectivenessWeak end,
	},
	[4] = {
		getText = function(self) return "4x " .. Resources.MGBAScreens.LabelWeaknesses end,
		getSymbol = function(self) return Resources.MGBAScreens.SymbolEffectivenessWeakDouble end,
	},
}

function MGBADisplay.initialize()
	if Main.IsOnBizhawk() then return end
	-- Currently unused
end

MGBADisplay.DataFormatter = {
	formatPokemonInfo = function(data)
		local listSeparator = ", "

		data.p.name = Utils.toUpperUTF8(data.p.name)

		-- Format type as "Normal" or "Flying/Normal"
		if data.p.types[2] ~= PokemonData.Types.EMPTY and data.p.types[2] ~= data.p.types[1] then
			data.p.typeline = Utils.formatUTF8("%s/%s", PokemonData.getTypeResource(data.p.types[1]), PokemonData.getTypeResource(data.p.types[2]))
		else
			data.p.typeline = PokemonData.getTypeResource(data.p.types[1])
		end

		if tonumber(data.p.weight) ~= nil then
			data.p.weight = Utils.formatUTF8("%s %s", data.p.weight, Resources.MGBAScreens.PokemonInfoKg)
		else
			data.p.weight = Constants.BLANKLINE
		end
		if data.p.evo == PokemonData.Evolutions.NONE then
			data.p.evodetails = Resources.MGBAScreens.PokemonInfoNone
		else
			data.p.evodetails = table.concat(Utils.getDetailedEvolutionsInfo(data.p.evo), listSeparator)
		end

		if data.p.movelvls == {} or #data.p.movelvls == 0 then
			data.p.moveslearned = Resources.MGBAScreens.PokemonInfoNone
		else
			for i = 1, #data.p.movelvls, 1 do
				if type(data.p.movelvls[i]) == "number" and data.p.movelvls[i] <= data.x.viewedPokemonLevel then
					data.p.movelvls[i] = data.p.movelvls[i] .. "*"
				end
			end
			data.p.moveslearned = table.concat(data.p.movelvls, listSeparator)
		end

		data.e.list = {}
		local effectivenessOrdered = { 0, 0.25, 0.5, 2, 4, }
		for _, typeMultiplier in ipairs(effectivenessOrdered) do
			local effectTypes = data.e[typeMultiplier]
			if effectTypes ~= nil and #effectTypes ~= 0 then
				for i = 1, #effectTypes, 1 do
					effectTypes[i] = PokemonData.getTypeResource(effectTypes[i])
				end
				local label = MGBADisplay.Effectiveness[typeMultiplier]:getText()
				data.e.list[label] = table.concat(data.e[typeMultiplier], listSeparator)
			end
		end

		if Utils.isNilOrEmpty(data.x.note) then
			data.x.note = Resources.MGBAScreens.PokemonInfoLeaveNote
		end
	end,
	formatMoveInfo = function(data)
		data.m.name = Utils.toUpperUTF8(data.m.name)
		data.m.type = PokemonData.getTypeResource(data.m.type)

		if tonumber(data.m.accuracy) ~= nil then
			data.m.accuracy = data.m.accuracy .. "%"
		end

		if MGBADisplay.Categories[data.m.category] then
			data.m.category = MGBADisplay.Categories[data.m.category]:getShorthand()
		end

		if data.m.iscontact then
			data.m.iscontact = Resources.AllScreens.Yes
		else
			data.m.iscontact = Resources.AllScreens.No
		end

		if data.m.priority == "0" then
			data.m.priority = Resources.MGBAScreens.MoveInfoNormalPriority
		end
	end,
	formatRouteInfo = function(data)
		local unseenPokemon = "???"
		local justify4 = Utils.inlineIf(Options["Right justified numbers"], "%4s", "%-4s")
		local originalPokemonBar = " %-12s  " .. justify4 .. "    %s"

		if not RouteData.hasRoute(data.r.id) then
			data.r.name = Utils.formatUTF8("%s (%s)", Resources.MGBAScreens.RouteInfoUnknownArea, math.floor(data.r.id))
		else
			data.r.name = Utils.toUpperUTF8(data.r.name)
		end

		for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
			local area = data.e[encounterArea]

			area.originalLines = {}
			for _, enc in ipairs(area.originalPokemon) do
				local name = PokemonData.Pokemon[enc.pokemonID].name
				local rate = math.floor(enc.rate * 100) .. "%"
				local level
				if enc.minLv ~= 0 then
					level = Utils.formatUTF8("%s.%s", Resources.TrackerScreen.LevelAbbreviation, math.floor(enc.minLv))
					if enc.maxLv ~= 0 and enc.minLv ~= enc.maxLv then
						level = Utils.formatUTF8("%s-%s", level, math.floor(enc.maxLv))
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
		-- Don't capitalize if nicknames are being used
		data.p.name = Options["Show nicknames"] and data.p.name or Utils.toUpperUTF8(data.p.name)

		if not Utils.isNilOrEmpty(data.p.status) then
			data.p.status = Utils.formatUTF8("[%s]", data.p.status)
		end

		-- Format type as "Normal" or "Flying/Normal"
		if data.p.types[2] ~= PokemonData.Types.EMPTY and data.p.types[2] ~= data.p.types[1] then
			data.p.typeline = Utils.formatUTF8("%s/%s", PokemonData.getTypeResource(data.p.types[1]), PokemonData.getTypeResource(data.p.types[2]))
		else
			data.p.typeline = PokemonData.getTypeResource(data.p.types[1])
		end

		TrackerScreen.updateButtonStates() -- required prior to using TrackerScreen.Buttons[statKey]

		local statLabels = {
			["HP"] = Resources.MGBAScreens.TrackerHP,
			["ATK"] = Resources.MGBAScreens.TrackerAttack,
			["DEF"] = Resources.MGBAScreens.TrackerDefense,
			["SPA"] = Resources.MGBAScreens.TrackerSpAttack,
			["SPD"] = Resources.MGBAScreens.TrackerSpDefense,
			["SPE"] = Resources.MGBAScreens.TrackerSpeed,
		}
		data.p.labels = {}
		for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			data.p.labels[statKey] = statLabels[statKey:upper()] or "???"
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
			if move.type == nil or move.type == MoveData.BlankMove.type then
				move.type = Constants.BLANKLINE
			else
				move.type = PokemonData.getTypeResource(move.type)
			end
		end
	end,
}

MGBADisplay.LineBuilder = {
	buildTrackerSetup = function()
		local lines = {}

		local optionBar = "%-2s %-26s [%s]"
		local controlBar = "%-2s %-21s %8s"
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.TrackerSetup:getTitle()))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)
		table.insert(lines, Utils.formatUTF8("%s: %s", Resources.MGBAScreens.LabelToggleOption, MGBA.CommandMap["OPTION"].usageSyntax))

		table.insert(lines, Utils.formatUTF8("%-2s %-20s [%s]", "#", Utils.toUpperUTF8(Resources.MGBAScreens.LabelOption), Utils.toUpperUTF8(Resources.MGBAScreens.LabelEnabled)))
		for i = 1, 9, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(optionBar, i, opt:getText(), opt:getValue()))
			end
		end

		table.insert(lines, MGBADisplay.Symbols.DividerLine)
		table.insert(lines, Utils.formatUTF8("%s: OPTION \"# %s\"", Resources.MGBAScreens.GeneralSetupChange, Resources.MGBAScreens.GeneralSetupButtons))
		table.insert(lines, Utils.formatUTF8("%-2s %-13s %16s", "#", Utils.toUpperUTF8(Resources.MGBAScreens.GeneralSetupControls), Utils.toUpperUTF8(Resources.MGBAScreens.GeneralSetupGBAButtons)))
		for i = 10, 12, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(controlBar, i, opt:getText(), opt:getValue()))
			end
		end
		local qid = 13 -- "Quickload"
		if MGBA.OptionMap[qid] ~= nil then
			table.insert(lines, Utils.formatUTF8("%-2s %-13s %16s", qid, MGBA.OptionMap[qid]:getText(), MGBA.OptionMap[qid]:getValue()))
		end

		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		return lines
	end,
	buildGameplayOptions = function()
		local lines = {}

		local optionBar = "%-2s %-26s [%s]"
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.GameplayOptions:getTitle()))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)
		table.insert(lines, Utils.formatUTF8("%s: %s", Resources.MGBAScreens.LabelToggleOption, MGBA.CommandMap["OPTION"].usageSyntax))

		table.insert(lines, Utils.formatUTF8("%-2s %-20s [%s]", "#", Utils.toUpperUTF8(Resources.MGBAScreens.LabelOption), Utils.toUpperUTF8(Resources.MGBAScreens.LabelEnabled)))
		for i = 20, 28, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(optionBar, i, opt:getText(), opt:getValue()))
			end
		end
		table.insert(lines, MGBADisplay.Symbols.DividerLine)
		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.GameplayOptionsManualSave))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["SAVEDATA"].usageSyntax))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["LOADDATA"].usageSyntax))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["CLEARDATA"].usageSyntax))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		return lines
	end,
	buildQuickloadSetup = function()
		local lines = {}

		local optionBar = "%-2s %-26s [%s]"
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.QuickloadSetup:getTitle()))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)
		MGBADisplay.Utils.addLinesWrapped(lines, Resources.MGBAScreens.QuickloadDesc)
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		table.insert(lines, Utils.formatUTF8('%s: %s', Resources.MGBAScreens.QuickloadChooseMode, MGBA.CommandMap["OPTION"].usageSyntax))
		table.insert(lines, Utils.formatUTF8("%-2s %-19s [%s]", "#", Utils.toUpperUTF8(Resources.MGBAScreens.QuickloadMode), Utils.toUpperUTF8(Resources.MGBAScreens.QuickloadSelected)))

		for i = 30, 31, 1 do
			local opt = MGBA.OptionMap[i]
			if opt ~= nil then
				table.insert(lines, Utils.formatUTF8(optionBar, i, opt:getText(), opt:getValue()))
			end
		end
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		-- local fileBar = "%-2s %-30s"
		if MGBA.OptionMap[30] ~= nil and MGBA.OptionMap[30]:getValue() == MGBADisplay.Symbols.OptionEnabled then
			-- local romFolderId = 32
			-- local opt = MGBA.OptionMap[romFolderId]
			-- if opt ~= nil then
			-- 	local foldername = opt:getValue()
			-- 	if Utils.isNilOrEmpty(foldername) then
			-- 		foldername = "(NOT SET)"
			-- 	end
			-- 	table.insert(lines, Utils.formatUTF8(fileBar, romFolderId, opt:getText() .. " *"))
			-- 	table.insert(lines, Utils.formatUTF8(" %-32s", foldername))
			-- end
			-- table.insert(lines, MGBADisplay.Symbols.EmptyLine)
			-- table.insert(lines, '* Set above files in Settings.ini')
			-- table.insert(lines, 'Set folder using: OPTION "# path"') -- temp hide this option from user
			table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.QuickloadRequiredFiles))
			table.insert(lines, Utils.formatUTF8("- %s", Resources.MGBAScreens.QuickloadMultipleRoms))
			table.insert(lines, MGBADisplay.Symbols.EmptyLine)
			table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		elseif MGBA.OptionMap[31] ~= nil and MGBA.OptionMap[31]:getValue() == MGBADisplay.Symbols.OptionEnabled then
			-- for i = 33, 35, 1 do
			-- 	local opt = MGBA.OptionMap[i]
			-- 	if opt ~= nil then
			-- 		local filename = opt:getValue()
			-- 		if filename:len() > 32 then
			-- 			filename = filename:sub(1, 29) .. "..."
			-- 		elseif Utils.isNilOrEmpty(filename) then
			-- 			filename = "(NOT SET)"
			-- 		end
			-- 		table.insert(lines, Utils.formatUTF8(fileBar, i, opt:getText() .. ": *"))
			-- 		table.insert(lines, Utils.formatUTF8(" %-32s", filename))
			-- 		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
			-- 	end
			-- end
			-- table.insert(lines, '* Set above files in Settings.ini')
			-- table.insert(lines, 'Set file: OPTION "# filepath"') -- temp hide this option from user
			table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.QuickloadRequiredFilesOneEach))
			table.insert(lines, Utils.formatUTF8("- %s", Resources.MGBAScreens.QuickloadJarFile))
			table.insert(lines, Utils.formatUTF8("- %s", Resources.MGBAScreens.QuickloadRnqsFile))
			table.insert(lines, Utils.formatUTF8("- %s", Resources.MGBAScreens.QuickloadGbaFile))
		end

		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		local instructionBar = "%-14s %-18s"
		local quickloadCombo = Options.CONTROLS["Load next seed"]:gsub(" ", ""):gsub(",", " + ")
		table.insert(lines, Utils.formatUTF8(instructionBar, Resources.MGBAScreens.QuickloadButtonCombo .. ":", quickloadCombo))
		table.insert(lines, Utils.formatUTF8(instructionBar, Resources.MGBAScreens.QuickloadTextCommand .. ":", MGBA.CommandMap["NEWRUN"].usageSyntax))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		return lines
	end,
	buildUpdateCheck = function()
		local lines = {}

		local columnBar = "%-26s%-7s"
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.UpdateCheck:getTitle()))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		local versionStatus
		if Main.isOnLatestVersion() then
			versionStatus = Utils.formatUTF8("%s:", Resources.MGBAScreens.UpdateLastCheckedVersion)
		else
			versionStatus = Utils.formatUTF8("%s:", Resources.MGBAScreens.UpdateNewVersionAvailable)
			table.insert(lines, Utils.formatUTF8("  %s", Resources.MGBAScreens.UpdateAvailable))
			table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		end
		table.insert(lines, Utils.formatUTF8(columnBar, Resources.MGBAScreens.UpdateCurrentVersion .. ":", Main.TrackerVersion or Constants.BLANKLINE))
		table.insert(lines, Utils.formatUTF8(columnBar, versionStatus, Main.Version.latestAvailable or Constants.BLANKLINE))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.UpdateManualCheck))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["CHECKUPDATE"].usageSyntax))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.UpdateViewReleaseNotes))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["RELEASENOTES"].usageSyntax))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.UpdateDownloadInstall))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["UPDATENOW"].usageSyntax))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		return lines
	end,
	buildLanguage = function()
		local lines = {}

		local userLanguageKey = Options["Language"] or Resources.Default.Language.Key
		local userLanguage = Resources.Languages[userLanguageKey]

		table.insert(lines, Utils.formatUTF8("%s (%s)", Utils.toUpperUTF8(MGBA.Screens.Language:getTitle()), userLanguage.DisplayName))
		table.insert(lines, MGBADisplay.Symbols.DividerLine)
		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.LanguageChangeWith))
		table.insert(lines, Utils.formatUTF8(" %s", MGBA.CommandMap["LANGUAGE"].usageSyntax))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		table.insert(lines, Utils.formatUTF8("%-2s %-13s %-16s", "#", Utils.toUpperUTF8(Resources.MGBAScreens.LanguageHeaderLang), Utils.toUpperUTF8(Resources.MGBAScreens.LanguageHeaderLang)))

		local orderedLanguages = {}
		for _, lang in pairs(Resources.Languages) do
			if not lang.ExcludeFromSettings then
				table.insert(orderedLanguages, lang)
			end
		end
		table.sort(orderedLanguages, function(a,b) return a.Ordinal < b.Ordinal end)
		for _, lang in ipairs(orderedLanguages) do
			table.insert(lines, Utils.formatUTF8("%-2s %-13s %-16s", lang.Ordinal, Utils.firstToUpper(Utils.toLowerUTF8(lang.Key)), lang.DisplayName))
		end

		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		local optionBar = "%-2s %-26s [%s]"
		table.insert(lines, Utils.formatUTF8("%s: %s", Resources.MGBAScreens.LabelToggleOption, MGBA.CommandMap["OPTION"].usageSyntax))
		table.insert(lines, Utils.formatUTF8("%-2s %-20s [%s]", "#", Utils.toUpperUTF8(Resources.MGBAScreens.LabelOption), Utils.toUpperUTF8(Resources.MGBAScreens.LabelEnabled)))

		local optionAutodetectId = 29
		local opt = MGBA.OptionMap[optionAutodetectId]
		if opt ~= nil then
			table.insert(lines, Utils.formatUTF8(optionBar, optionAutodetectId, opt:getText(), opt:getValue()))
		end

		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		return lines
	end,
	buildCommandsBasic = function()
		local lines = {}

		local commandBar = " %-10s%-s"
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.CommandsBasic:getTitle()))

		local usageInstructions = Utils.formatUTF8("%s: %s", Resources.MGBAScreens.CommandsDesc, MGBA.CommandMap["POKEMON"].usageExample)
		MGBADisplay.Utils.addLinesWrapped(lines, usageInstructions)
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		local commandList = {
			MGBA.CommandMap["POKEMON"],
			MGBA.CommandMap["MOVE"],
			MGBA.CommandMap["ABILITY"],
			MGBA.CommandMap["ROUTE"],
			MGBA.CommandMap["NOTE"],
		}

		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.CommandsUsageSyntax))
		for _, command in ipairs(commandList) do
			if command.usageSyntax ~= nil then
				local commandName, commandParams = MGBADisplay.Utils.splitCommandUsage(command.usageSyntax)
				table.insert(lines, Utils.formatUTF8(commandBar, commandName, commandParams))
			end
		end
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.CommandsExampleUsage))
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
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.CommandsOther:getTitle()))

		local usageInstructions = Utils.formatUTF8("%s: %s", Resources.MGBAScreens.CommandsDesc, MGBA.CommandMap["PCHEALS"].usageExample)
		MGBADisplay.Utils.addLinesWrapped(lines, usageInstructions)
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

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

		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.CommandsUsageSyntax))
		for _, command in ipairs(commandList) do
			if command.usageSyntax ~= nil then
				local commandName, commandParams = MGBADisplay.Utils.splitCommandUsage(command.usageSyntax)
				table.insert(lines, Utils.formatUTF8(commandBar, commandName, commandParams))
			end
		end
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.CommandsExampleUsage))
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
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.PokemonInfoBST .. ":", data.p.bst))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.PokemonInfoWeight .. ":", data.p.weight))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.PokemonInfoEvolution .. ":", data.p.evodetails))

		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.PokemonInfoLevelupMoves))
		MGBADisplay.Utils.addLinesWrapped(lines, data.p.moveslearned)

		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		local effectivenessOrdered = { 0, 0.25, 0.5, 2, 4, }
		for _, typeMultiplier in ipairs(effectivenessOrdered) do
			local label = MGBADisplay.Effectiveness[typeMultiplier]:getText()
			if data.e.list[label] ~= nil then
				table.insert(lines, Utils.formatUTF8("%s:", label))
				MGBADisplay.Utils.addLinesWrapped(lines, Utils.formatUTF8(" %s", data.e.list[label]))
			end
		end

		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.PokemonInfoNote))
		MGBADisplay.Utils.addLinesWrapped(lines, data.x.note)

		return lines
	end,
	buildMoveInfo = function(data)
		local lines = {}

		MGBADisplay.DataFormatter.formatMoveInfo(data)

		local labelBar = "%-12s %s"
		table.insert(lines, Utils.formatUTF8(labelBar, data.m.name, Utils.formatUTF8("[%s]", data.m.type)))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.MoveInfoCategory .. ":", data.m.category))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.MoveInfoContact .. ":", data.m.iscontact))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.MoveInfoPP .. ":", data.m.pp))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.MoveInfoPower .. ":", data.m.power))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.MoveInfoAccuracy .. ":", data.m.accuracy))
		table.insert(lines, Utils.formatUTF8(labelBar, Resources.MGBAScreens.MoveInfoPriority .. ":", data.m.priority))

		if data.m.summary ~= Constants.BLANKLINE then
			table.insert(lines, MGBADisplay.Symbols.EmptyLine)
			table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.MoveInfoSummary))
			MGBADisplay.Utils.addLinesWrapped(lines, data.m.summary)
		end

		return lines
	end,
	buildAbilityInfo = function(data)
		local lines = {}

		table.insert(lines, Utils.toUpperUTF8(data.a.name))

		table.insert(lines, MGBADisplay.Symbols.EmptyLine)
		MGBADisplay.Utils.addLinesWrapped(lines, data.a.description)


		if data.a.descriptionEmerald ~= Constants.BLANKLINE then
			table.insert(lines, MGBADisplay.Symbols.EmptyLine)
			table.insert(lines, Utils.formatUTF8("%s:", Resources.MGBAScreens.MoveInfoEmeraldBonus))
			MGBADisplay.Utils.addLinesWrapped(lines, data.a.descriptionEmerald)
		end

		return lines
	end,
	buildRouteInfo = function(data)
		local lines = {}

		MGBADisplay.DataFormatter.formatRouteInfo(data)

		table.insert(lines, Utils.formatUTF8("%-22s%11s", data.r.name, "[" .. Resources.MGBAScreens.RouteInfoTracked .. "]"))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		-- No wild encounters, such as a building, don't show anything else
		if data.r.totalWildEncounters == 0 and data.r.totalTrainerEncounters == 0 then
			return lines
		end

		for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
			local area = data.e[encounterArea]
			if area.totalPossible > 0 then -- Only display areas that have encounters
				table.insert(lines, Utils.formatUTF8("%s (%s/%s %s)", encounterArea, area.totalSeen, area.totalPossible, Resources.MGBAScreens.RouteInfoSeen))
				for _, line in ipairs(area.trackedLines) do
					table.insert(lines, line)
				end
			end
		end

		return lines
	end,
	buildOriginalRouteInfo = function(data)
		local lines = {}

		table.insert(lines, Utils.formatUTF8("%-22s%11s", data.r.name, "[" .. Resources.MGBAScreens.RouteInfoOriginal .. "]"))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		-- No wild encounters, such as a building, don't show anything else
		if data.r.totalWildEncounters == 0 and data.r.totalTrainerEncounters == 0 then
			return lines
		end

		for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
			local area = data.e[encounterArea]
			if area.totalPossible > 0 then -- Only display areas that have encounters
				table.insert(lines, Utils.formatUTF8("%s (%s/%s %s)", encounterArea, area.totalSeen, area.totalPossible, Resources.MGBAScreens.RouteInfoSeen))
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
		table.insert(lines, Utils.toUpperUTF8(MGBA.Screens.Stats:getTitle()))
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		for _, statPair in ipairs(StatsScreen.StatTables) do
			local statName = statPair.getText()
			local statValue = statPair.getValue() or 0
			if type(statValue) == "number" then
				statValue = Utils.formatNumberWithCommas(statValue)
			end
			table.insert(lines, Utils.formatUTF8(statBar, statName .. ":", statValue))
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
			local statValue = Utils.inlineIf(data.p[statKey] ~= 0, data.p[statKey], Constants.BLANKLINE)
			formattedStats[statKey] = Utils.formatUTF8("%-5s" .. justify3 .. "%-2s", data.p.labels[statKey], statValue, data.p.stages[statKey])
		end

		-- Header and top dividing line (with types)
		local bstAligned = Utils.formatUTF8(justify3, data.p.bst)
		lines[1] = Utils.formatUTF8("%-23s%-5s%-5s", Utils.formatUTF8("%-13s %-3s", data.p.name, data.p.status), Resources.MGBAScreens.TrackerBST, bstAligned)
		lines[2] = Utils.formatUTF8("%-23s%-10s", data.p.typeline, "----------")

		-- Top six lines of the box: Pokemon related stuff
		local topFormattedLine = "%-23s%-10s"
		local levelLine
		if data.p.evo == PokemonData.Evolutions.NONE then
			levelLine = Utils.formatUTF8("%s.%s", Resources.MGBAScreens.TrackerLevel, data.p.level)
		else
			local abbreviationText = Utils.getEvoAbbreviation(data.p.evo)
			levelLine = Utils.formatUTF8("%s.%s (%s)", Resources.MGBAScreens.TrackerLevel, data.p.level, abbreviationText)
		end
		if data.x.viewingOwn then
			local hpLine = Utils.formatUTF8("%s: %s/%s", Resources.MGBAScreens.TrackerHP, data.p.curHP, data.p.hp)
			lines[3] = Utils.formatUTF8(topFormattedLine, hpLine, formattedStats.hp)
			lines[4] = Utils.formatUTF8(topFormattedLine, levelLine, formattedStats.atk)

			if Options["Track PC Heals"] then
				local survivalHeals = Utils.formatUTF8("%s: %s", Resources.MGBAScreens.TrackerSurvivalPCs, data.x.pcheals)
				lines[7] = Utils.formatUTF8(topFormattedLine, survivalHeals, formattedStats.spd)
			else
				lines[7] = Utils.formatUTF8(topFormattedLine, "", formattedStats.spd)
			end

			local availableHeals = Utils.formatUTF8("%s: %.0f%% (%s)", Resources.MGBAScreens.TrackerHeals, data.x.healperc, data.x.healnum)
			lines[8] = Utils.formatUTF8(topFormattedLine, availableHeals, formattedStats.spe)
		else
			lines[3] = Utils.formatUTF8(topFormattedLine, levelLine, formattedStats.hp)

			local lastLevelSeen
			if not Utils.isNilOrEmpty(data.p.lastlevel) then
				lastLevelSeen = Utils.formatUTF8("%s %s.%s", Resources.MGBAScreens.TrackerLastSeen, Resources.MGBAScreens.TrackerLevel, data.p.lastlevel)
			else
				lastLevelSeen = Resources.MGBAScreens.TrackerNewEncounter
			end
			lines[4] = Utils.formatUTF8(topFormattedLine, lastLevelSeen, formattedStats.atk)

			local encountersText, routeText
			if Battle.isWildEncounter then
				encountersText = Utils.formatUTF8("%s: %s", Resources.MGBAScreens.TrackerSeenWild, data.x.encounters)
				routeText = data.x.route
			else
				local numAlive, totalMons = Program.getTeamCounts()
				encountersText = Utils.formatUTF8("%s: %s", Resources.MGBAScreens.TrackerSeenTrainers, data.x.encounters)
				routeText = Utils.formatUTF8("%s: %s/%s", Resources.MGBAScreens.TrackerTrainerTeam, numAlive, totalMons)
			end

			lines[7] = Utils.formatUTF8(topFormattedLine, encountersText, formattedStats.spd)
			lines[8] = Utils.formatUTF8(topFormattedLine, routeText, formattedStats.spe)
		end

		lines[5] = Utils.formatUTF8(topFormattedLine, data.p.line1, formattedStats.def)
		lines[6] = Utils.formatUTF8(topFormattedLine, data.p.line2, formattedStats.spa)
		table.insert(lines, MGBADisplay.Symbols.EmptyLine)

		-- Bottom five lines of the box: Move related stuff
		local botFormattedLine = "%-18s%-3s%-7s  %-3s"
		local moveHeader = Utils.formatUTF8(botFormattedLine, data.m.nextmoveheader,
			Resources.MGBAScreens.TrackerHeaderPP,
			"   " .. Resources.MGBAScreens.TrackerHeaderPow,
			Resources.MGBAScreens.TrackerHeaderAcc)
		local moveDivider = MGBADisplay.Symbols.DividerLine
		if Theme.MOVE_TYPES_ENABLED then
			moveHeader = string.format("%s   %s", moveHeader, Resources.MGBAScreens.TrackerHeaderType)
			moveDivider = string.format("%s   %s", moveDivider, "------")
		end
		table.insert(lines, moveHeader)
		table.insert(lines, moveDivider)
		for i, move in ipairs(data.m.moves) do
			local nameText = move.name
			if Options["Show physical special icons"] and (data.x.viewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType) then
				local catSymbol = " "
				if MGBADisplay.Categories[move.category] then
					catSymbol = MGBADisplay.Categories[move.category]:getSymbol()
				end
				nameText = catSymbol .. " " .. nameText
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

			local effectivenessLabel
			if move.showeffective and MGBADisplay.Effectiveness[move.effectiveness] then
				effectivenessLabel = MGBADisplay.Effectiveness[move.effectiveness]:getSymbol() or "  "
			else
				effectivenessLabel = "  "
			end
			powerText = effectivenessLabel .. powerText

			local moveLine = Utils.formatUTF8(botFormattedLine, nameText, ppAligned, powerText, accuracyAligned)

			-- Append the move type as text if this option is enabled (ON by default)
			-- Note: this goes out of bounds of the normal Tracker box, but really no other good solution
			if Theme.MOVE_TYPES_ENABLED then
				moveLine = string.format("%s   %s", moveLine, move.type)
			end

			table.insert(lines, moveLine)
		end
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

		-- Footer, carousel related stuff
		-- local botFormattedLine = "%-33s"
		for _, carousel in ipairs(TrackerScreen.CarouselItems) do
			if carousel.isVisible() then
				local carouselText = MGBADisplay.Utils.carouselToText(carousel, data.p.id)
				table.insert(lines, carouselText)
			end
		end
		if Options["Display repel usage"] and Program.ActiveRepel.inUse and not Battle.inActiveBattle() then
			local repelBarSize = 20
			local remainingFraction = math.floor(Program.ActiveRepel.stepCount * repelBarSize / Program.ActiveRepel.duration)
			local repelBarFill = string.rep("=", remainingFraction)
			if Program.ActiveRepel.stepCount > 0 then
				repelBarFill = Utils.formatUTF8("[%-".. repelBarSize .. "s]", repelBarFill)
				table.insert(lines, Utils.formatUTF8("%s: %26s", Resources.MGBAScreens.TrackerRepel, repelBarFill)) -- right-align
			end
		end
		table.insert(lines, MGBADisplay.Symbols.DividerLine)

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
			carouselText = Resources.MGBAScreens.TrackerBadges ..  ": "
			for badgeNumber, badgeButton in ipairs(carouselContent) do
				local badgeText = string.format("[%s]", Utils.inlineIf(badgeButton.badgeState ~= 0, badgeNumber, " "))
				carouselText = carouselText .. badgeText
			end
		elseif carousel.type == TrackerScreen.CarouselTypes.LAST_ATTACK then
			carouselText = carouselContent
		elseif carousel.type == TrackerScreen.CarouselTypes.ROUTE_INFO then
			carouselText = carouselContent
		elseif carousel.type == TrackerScreen.CarouselTypes.NOTES then
			carouselText = Resources.MGBAScreens.PokemonInfoNote .. ": " .. carouselContent
		elseif carousel.type == TrackerScreen.CarouselTypes.PEDOMETER then
			carouselText = carouselContent
		end

		return carouselText
	end,
}
LogTabRouteDetails = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		hightlight = "Intermediate text",
	},
	Tabs = {
		-- These keys should be identical to RandomizerLog.EncounterTypes keys (not logkeys)
		Trainers = 1,
		GrassCave = 2,
		Surfing = 3,
		Fishing = 4,
		RockSmash = 5,
	},
	defaultSortKey = "TrainerLevel",
	defaultFilterKey = "TrainerName",
	levelRangeSpacer = "--",
	infoId = -1,
	dataSet = nil,
}

LogTabRouteDetails.TemporaryButtons = {}

LogTabRouteDetails.Pager = {
	Trainers = {},
	WildEncounters = {},
	itemsPerPage = 8,
	currentPage = 0,
	currentTab = 0,
	totalPages = 0,
	tabTotals = {
		[LogTabRouteDetails.Tabs.Trainers] = 0,
		[LogTabRouteDetails.Tabs.GrassCave] = 0,
		[LogTabRouteDetails.Tabs.Surfing] = 0,
		[LogTabRouteDetails.Tabs.Fishing] = 0,
		[LogTabRouteDetails.Tabs.RockSmash] = 0,
	},
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
	changeTab = function(self, newTab)
		if newTab == LogTabRouteDetails.Tabs.Trainers and self.currentTab ~= LogTabRouteDetails.Tabs.Trainers then
			LogSearchScreen.currentSortOrder = LogSearchScreen.SortBy["TrainerLevel"]
			LogSearchScreen.currentFilter = LogSearchScreen.FilterBy["TrainerName"]
			LogSearchScreen.refreshDropDowns()
		elseif newTab ~= LogTabRouteDetails.Tabs.Trainers and self.currentTab == LogTabRouteDetails.Tabs.Trainers then
			LogSearchScreen.currentSortOrder = LogSearchScreen.SortBy["EncounterRate"]
			LogSearchScreen.currentFilter = LogSearchScreen.FilterBy["PokemonName"]
			LogSearchScreen.refreshDropDowns()
		end
		LogOverlay.Windower.filterGrid = newTab
		self.currentTab = newTab
		LogTabRouteDetails.realignGrid()
		self.currentPage = 1
		self.totalPages = self.tabTotals[newTab] or 1
	end,
}

function LogTabRouteDetails.initialize()

end

function LogTabRouteDetails.refreshButtons()
	for _, button in pairs(LogTabRouteDetails.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabRouteDetails.Pager.Trainers) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabRouteDetails.Pager.WildEncounters) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabRouteDetails.rebuild()
	LogTabRouteDetails.buildZoomButtons()
end

function LogTabRouteDetails.buildZoomButtons(mapId)
	mapId = mapId or LogTabRouteDetails.infoId or -1
	local data = DataHelper.buildRouteLogDisplay(mapId)
	LogTabRouteDetails.infoId = mapId
	LogTabRouteDetails.dataSet = data

	LogTabRouteDetails.TemporaryButtons = {}
	LogTabRouteDetails.Pager.Trainers = {}
	LogTabRouteDetails.Pager.WildEncounters = {}

	-- ROUTE NAME
	local routeName = Utils.toUpperUTF8(data.r.name)
	local routeNameButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return routeName end,
		textColor = LogTabRouteDetails.Colors.hightlight,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 2, 120, 12 },
	}
	table.insert(LogTabRouteDetails.TemporaryButtons, routeNameButton)

	-- ROUTE TAB NAVIGATION
	-- TODO: do this in reverse actually
	local tabNavigation = { "Trainers", "GrassCave", "Surfing", "Fishing", "RockSmash", }
	local navItemSpacer = 5
	local navX, navY = LogOverlay.TabBox.x + 160, LogOverlay.TabBox.y + 2
	for _, enc in ipairs(tabNavigation) do
		local resourceKey = "Tab" .. enc
		local navButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- TODO: Update resources
			getText = function(self) return string.format("%s (%s)", enc or Resources.LogTabRouteDetails[resourceKey], #data.e[enc]) end,
			textColor = LogTabRouteDetails.Colors.text,
			tab = LogTabRouteDetails.Tabs[enc],
			isSelected = false,
			box = { navX, navY, 60, 11 },
			isVisible = function(self) return #data.e[enc] > 0 end,
			updateSelf = function(self)
				self.isSelected = (LogTabRouteDetails.Pager.currentTab == self.tab)
				self.textColor = Utils.inlineIf(self.isSelected, LogTabRouteDetails.Colors.hightlight, LogTabRouteDetails.Colors.text)
				self.box[3] = Utils.calcWordPixelLength(self:getText()) + 4
			end,
			draw = function(self)
				if self.isSelected then
					Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
				end
			end,
			onClick = function(self)
				if self.isSelected then return end -- Don't change if already on this tab
				LogTabRouteDetails.Pager:changeTab(self.tab)
				Program.redraw(true)
			end,
		}
		navButton:updateSelf()

		table.insert(LogTabRouteDetails.TemporaryButtons, navButton)

		-- Trainers nav button is on a row  by itself
		if enc == "Trainers" then
			navX = LogOverlay.TabBox.x + 10
			navY = navY + 12
		else
			navX = navX + navButton.box[3] + navItemSpacer
		end
	end

	-- LEFT/RIGHT PAGING BUTTONS (easy access)
	local centerY = LogOverlay.TabBox.height / 2
	local leftArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		textColor = LogTabRouteDetails.Colors.text,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + centerY, 10, 10 },
		isVisible = function() return LogTabRouteDetails.Pager.totalPages > 1 end,
		onClick = function(self) LogTabRouteDetails.Pager:prevPage() end,
	}
	local rightArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		textColor = LogTabRouteDetails.Colors.text,
		box = { LogOverlay.TabBox.x + LogOverlay.TabBox.width - 12, LogOverlay.TabBox.y + centerY, 10, 10 },
		isVisible = function() return LogTabRouteDetails.Pager.totalPages > 1 end,
		onClick = function(self) LogTabRouteDetails.Pager:nextPage() end,
	}
	table.insert(LogTabRouteDetails.TemporaryButtons, leftArrow)
	table.insert(LogTabRouteDetails.TemporaryButtons, rightArrow)

	-- GRID: TRAINER & WILD ENCOUNTERS
	for key, encounterList in pairs(data.e) do
		local button
		if key == "Trainers" then
			for _, trainer in ipairs(encounterList or {}) do
				button = LogTabRouteDetails.createTrainerButton(trainer)
				table.insert(LogTabRouteDetails.Pager.Trainers, button)
			end
		else
			for _, pokemonEnc in ipairs(encounterList or {}) do
				button = LogTabRouteDetails.createPokemonButton(key, pokemonEnc)
				table.insert(LogTabRouteDetails.Pager.WildEncounters, button)
			end
		end
	end

	local firstTabToShow
	if #data.e.Trainers > 0 then
		firstTabToShow = LogTabRouteDetails.Tabs.Trainers
	elseif #data.e.GrassCave > 0 then
		firstTabToShow = LogTabRouteDetails.Tabs.GrassCave
	else
		firstTabToShow = LogTabRouteDetails.Tabs.Surfing
	end
	LogTabRouteDetails.Pager:changeTab(firstTabToShow)
end

function LogTabRouteDetails.createTrainerButton(encounter)
	local whichRival = TrainerData.getTrainerInfo(encounter.id).whichRival
	-- Always exclude extra rivals
	if whichRival ~= nil and Tracker.Data.whichRival ~= nil and Tracker.Data.whichRival ~= whichRival then
		return nil
	end

	local trainerLog = RandomizerLog.Data.Trainers[encounter.id] or {}
	local fileInfo = TrainerData.FileInfo[encounter.filename or false] or { width = 64, height = 64 }
	local trainerImage
	if encounter.filename then
		trainerImage = FileManager.buildImagePath(FileManager.Folders.Trainers, encounter.filename, FileManager.Extensions.TRAINER)
	end

	local button = {
		type = Constants.ButtonTypes.IMAGE,
		image = trainerImage,
		getText = function(self) return encounter.fullname end,
		trainerClass = encounter.class,
		trainerName = encounter.name,
		id = encounter.id,
		dimensions = { width = fileInfo.width, height = fileInfo.height, extraX = fileInfo.offsetX, extraY = fileInfo.offsetY, },
		tab = LogTabRouteDetails.Tabs.Trainers,
		isVisible = function(self) return LogTabRouteDetails.Pager.currentTab == self.tab and LogTabRouteDetails.Pager.currentPage == self.pageVisible end,
		includeInGrid = function(self)
			-- If no search text entered, check any filter groups
			if LogSearchScreen.searchText == "" then
				if LogTabRouteDetails.Pager.currentTab == self.tab then
					return true
				end
				return false
			end

			if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.TrainerName then
				if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
					return true
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
				for _, partyMon in ipairs(trainerLog.party or {}) do
					local pokemonName = RandomizerLog.getPokemonName(partyMon.pokemonID)
					if Utils.containsText(pokemonName, LogSearchScreen.searchText, true) then
						return true
					end
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
				for _, partyMon in ipairs(trainerLog.party or {}) do
					for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
						local abilityText = AbilityData.Abilities[abilityId].name
						if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
							return true
						end
					end
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
				for _, partyMon in ipairs(trainerLog.party or {}) do
					for _, moveId in ipairs(partyMon.moveIds or {}) do
						local moveText = MoveData.Moves[moveId].name
						if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
							return true
						end
					end
				end
			end

			return false
		end,
		onClick = function(self)
			LogOverlay.Windower:changeTab(LogTabTrainerDetails, 1, 1, self.id)
			Program.redraw(true)
			-- InfoScreen.changeScreenView(InfoScreen.Screens.TRAINER_INFO, self.id) -- TODO: (future feature) implied redraw
		end,
		draw = function(self, shadowcolor)
			-- Draw a centered box for the Trainer's name
			local textColor = Theme.COLORS[LogTabRouteDetails.Colors.text]
			local borderColor = Theme.COLORS[LogTabRouteDetails.Colors.border]
			local fillColor = Theme.COLORS[LogTabRouteDetails.Colors.boxFill]
			local bottomPadding = 9
			if self.trainerClass ~= "" then
				local classCenterOffset = Utils.getCenteredTextX(self.trainerClass, self.box[3])
				local classX = self.box[1] + classCenterOffset
				local classY = self.box[2] + 64 - (bottomPadding * 2) - (self.dimensions.extraY or 0)
				gui.drawRectangle(classX - 1, classY, self.box[3], (bottomPadding * 2) + 2, borderColor, fillColor)
				Drawing.drawText(classX, classY, self.trainerClass, textColor, shadowcolor)
			end
			local nameCenterOffset = Utils.getCenteredTextX(self.trainerName, self.box[3])
			local nameX = self.box[1] + nameCenterOffset
			local nameY = self.box[2] + 64 - bottomPadding - (self.dimensions.extraY or 0)
			if self.trainerClass == "" then
				gui.drawRectangle(nameX - 1, nameY, self.box[3], bottomPadding + 2, borderColor, fillColor)
			end
			Drawing.drawText(nameX, nameY, self.trainerName, textColor, shadowcolor)

			-- local nameWidth = Utils.calcWordPixelLength(self:getText())
			-- local offsetX = self.box[1] + self.box[3] / 2 - nameWidth / 2
			-- local offsetY = self.box[2] + TrainerData.FileInfo.maxHeight - bottomPadding - (self.dimensions.extraY or 0)
			-- gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, borderColor, fillColor)
			-- Drawing.drawText(offsetX, offsetY, self:getText(), textColor, shadowcolor)
			-- gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabTrainers.Colors.border]) -- to cutoff the shadows
		end,
	}

	return button
end

function LogTabRouteDetails.createPokemonButton(encounterKey, encounterInfo)
	local pokemonLog = RandomizerLog.Data.Pokemon[encounterInfo.pokemonID]

	local levelRangeText = string.format("%s %s", Resources.TrackerScreen.LevelAbbreviation, encounterInfo.levelMin)
	if encounterInfo.levelMax ~= encounterInfo.levelMin then
		levelRangeText = string.format("%s %s %s", levelRangeText, LogTabRouteDetails.levelRangeSpacer, encounterInfo.levelMax)
	end
	local rateText = math.floor(encounterInfo.rate * 100) .. " %"

	local button = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		id = encounterInfo.pokemonID,
		getText = function(self) return RandomizerLog.getPokemonName(encounterInfo.pokemonID) end,
		textColor = LogTabRouteDetails.Colors.text,
		boxColors = { LogTabRouteDetails.Colors.border, LogTabRouteDetails.Colors.boxFill },
		tab = LogTabRouteDetails.Tabs[encounterKey],
		levelMin = encounterInfo.levelMin,
		levelMax = encounterInfo.levelMax,
		rate = encounterInfo.rate,
		dimensions = { width = 32, height = 32, },
		isVisible = function(self) return LogTabRouteDetails.Pager.currentTab == self.tab and LogTabRouteDetails.Pager.currentPage == self.pageVisible end,
		includeInGrid = function(self)
			-- If no search text entered, check any filter groups
			if LogSearchScreen.searchText == "" then
				if LogTabRouteDetails.Pager.currentTab == self.tab then
					return true
				end
				return false
			end

			if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
				if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
					return true
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
				for _, abilityId in pairs(pokemonLog.Abilities) do
					local abilityText = AbilityData.Abilities[abilityId].name
					if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
						return true
					end
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
				for _, move in pairs(pokemonLog.MoveSet) do
					local moveText = move.name -- potentially a custom move name
					if MoveData.isValid(move.moveId) then
						moveText = MoveData.Moves[move.moveId].name
					end
					if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
						return true
					end
				end
			end

			return false
		end,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.id), iconset.extension)
		end,
		onClick = function(self)
			LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.id)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
		end,
		draw = function(self, shadowcolor)
			-- Draw the Pokemon's name above the icon
			gui.drawRectangle(self.box[1], self.box[2], 32, 8, Theme.COLORS[self.boxColors[2]], Theme.COLORS[self.boxColors[2]])
			Drawing.drawText(self.box[1] - 5, self.box[2] - 1, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			-- Draw the level range and encounter rate below the icon
			Drawing.drawText(self.box[1] - 2, self.box[2] + 33, levelRangeText, Theme.COLORS[self.textColor], shadowcolor)
			Drawing.drawText(self.box[1] - 2, self.box[2] + 43, rateText, Theme.COLORS[self.textColor], shadowcolor)
		end,
	}
	return button
end

function LogTabRouteDetails.realignGrid(gridFilter, sortFunc, startingPage)
	if LogTabRouteDetails.Pager.currentTab == LogTabRouteDetails.Tabs.Trainers then
		LogTabRouteDetails.realignTrainerGrid(sortFunc, startingPage)
	else
		LogTabRouteDetails.realignPokemonGrid(sortFunc, startingPage)
	end

	LogTabRouteDetails.refreshButtons()
end

function LogTabRouteDetails.realignTrainerGrid(sortFunc, startingPage)
	local currentTab = LogTabRouteDetails.Pager.currentTab
	local gridItems = LogTabRouteDetails.Pager.Trainers
	sortFunc = sortFunc or LogSearchScreen.SortBy.PokedexNum.sortFunc -- synonymous with id (trainerid)
	startingPage = startingPage or 1

	table.sort(gridItems, sortFunc)

	local x = LogOverlay.TabBox.x + 30
	local y = LogOverlay.TabBox.y + 30
	local colSpacer = 25
	local rowSpacer = 10
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	local totalPages = Utils.gridAlign(gridItems, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogTabRouteDetails.Pager.tabTotals[currentTab] = totalPages
	LogTabRouteDetails.Pager.currentPage = math.min(startingPage, totalPages)
end

function LogTabRouteDetails.realignPokemonGrid(sortFunc, startingPage)
	local currentTab = LogTabRouteDetails.Pager.currentTab
	local gridItems = LogTabRouteDetails.Pager.WildEncounters
	sortFunc = sortFunc or LogSearchScreen.SortBy.EncounterRate.sortFunc
	startingPage = startingPage or 1

	table.sort(gridItems, sortFunc)

	local x = LogOverlay.TabBox.x + 20
	local y = LogOverlay.TabBox.y + 30
	local colSpacer = 23
	local rowSpacer = 26
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	local totalPages = Utils.gridAlign(gridItems, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogTabRouteDetails.Pager.tabTotals[currentTab] = totalPages
	LogTabRouteDetails.Pager.currentPage = math.min(startingPage, totalPages)
end

-- USER INPUT FUNCTIONS
function LogTabRouteDetails.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRouteDetails.TemporaryButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRouteDetails.Pager.Trainers)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRouteDetails.Pager.WildEncounters)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabRouteDetails.drawTab()
	local textColor = Theme.COLORS[LogTabRouteDetails.Colors.text]
	local highlightColor = Theme.COLORS[LogTabRouteDetails.Colors.hightlight]
	local borderColor = Theme.COLORS[LogTabRouteDetails.Colors.border]
	local fillColor = Theme.COLORS[LogTabRouteDetails.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	if RandomizerLog.Data.Routes[LogTabRouteDetails.infoId or -1] == nil then
		return
	end

	-- Ideally this is done only once on tab change
	local data = LogTabRouteDetails.dataSet
	if data == nil then
		data = DataHelper.buildRouteLogDisplay(LogTabRouteDetails.infoId)
		LogTabRouteDetails.dataSet = data
	end

	-- Draw all buttons
	for _, button in pairs(LogTabRouteDetails.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabRouteDetails.Pager.Trainers) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabRouteDetails.Pager.WildEncounters) do
		Drawing.drawButton(button, shadowcolor)
	end
end
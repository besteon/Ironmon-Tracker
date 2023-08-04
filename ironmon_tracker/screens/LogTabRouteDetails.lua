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
		OldRod = 4,
		GoodRod = 5,
		SuperRod = 6,
		RockSmash = 7,
	},
	levelRangeSpacer = "--",
	infoId = -1,
	dataSet = nil,
}

LogTabRouteDetails.TemporaryButtons = {}
LogTabRouteDetails.PagedButtons = {}

function LogTabRouteDetails.initialize()

end

function LogTabRouteDetails.refreshButtons()
	for _, button in pairs(LogTabRouteDetails.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabRouteDetails.PagedButtons) do
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
	LogTabRouteDetails.PagedButtons = {}

	-- ROUTE NAME
	local routeName = Utils.toUpperUTF8(data.r.name)
	local routeNameButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return routeName end,
		textColor = LogTabRouteDetails.Colors.hightlight,
		box = { LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 2, 120, 12 },
	}
	table.insert(LogTabRouteDetails.TemporaryButtons, routeNameButton)

	-- GRID: TRAINER & WILD ENCOUNTERS
	local encTotals = {}
	for key, encounterList in pairs(data.e) do
		local button
		if key == "Trainers" then
			for _, trainer in ipairs(encounterList or {}) do
				button = LogTabRouteDetails.createTrainerButton(trainer)
				if button ~= nil then
					encTotals[button.tab] = (encTotals[button.tab] or 0) + 1
					table.insert(LogTabRouteDetails.PagedButtons, button)
				end
			end
		else
			for _, pokemonEnc in ipairs(encounterList or {}) do
				button = LogTabRouteDetails.createPokemonButton(key, pokemonEnc)
				if button ~= nil then
					encTotals[button.tab] = (encTotals[button.tab] or 0) + 1
					table.insert(LogTabRouteDetails.PagedButtons, button)
				end
			end
		end
	end

	-- ROUTE TAB NAVIGATION
	local navX = LogOverlay.TabBox.x + 2
	local navY = 32
	local headerTextWidth = Utils.calcWordPixelLength("Encounters" or Resources.LogTabRouteDetails.Encounters) + 4
	local navHeaderButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		-- TODO: Update resources
		getText = function(self) return "Encounters" or Resources.LogTabRouteDetails.Encounters end,
		textColor = LogTabRouteDetails.Colors.text,
		box = { navX, navY, headerTextWidth, 11 },
		draw = function(self)
			Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
		end,
	}
	navY = navY + navHeaderButton.box[4] + 4
	table.insert(LogTabRouteDetails.TemporaryButtons, navHeaderButton)

	local tabNavigation = { "Trainers", "GrassCave", "Surfing", "OldRod", "GoodRod", "SuperRod", "RockSmash", }
	for _, enc in ipairs(tabNavigation) do
		local total = encTotals[LogTabRouteDetails.Tabs[enc] or 0] or 0
		if total > 0 then
			local resourceKey = "Tab" .. enc
			local navButton = {
				type = Constants.ButtonTypes.NO_BORDER,
				-- TODO: Update resources
				getText = function(self) return string.format("%s: %s", enc or Resources.LogTabRouteDetails[resourceKey], total) end,
				textColor = LogTabRouteDetails.Colors.text,
				tab = LogTabRouteDetails.Tabs[enc],
				isSelected = false,
				box = { navX, navY, 60, 11 }, -- [3] width updated later on next line
				isVisible = function(self) return total > 0 end,
				updateSelf = function(self)
					self.isSelected = (LogOverlay.Windower.filterGrid == self.tab)
					self.box[3] = Utils.calcWordPixelLength(self:getText()) + 4
				end,
				draw = function(self)
					if self.isSelected then
						-- Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
						local color = Theme.COLORS[LogTabRouteDetails.Colors.hightlight]
						Drawing.drawSelectionIndicators(self.box[1] + 1, self.box[2] + 1, self.box[3] - 1, self.box[4] - 2, color, 1, 4, 1)
					end
				end,
				onClick = function(self)
					if self.isSelected then return end -- Don't change if already on this tab
					LogTabRouteDetails.realignGrid(self.tab)
					Program.redraw(true)
				end,
			}
			navButton:updateSelf()
			navY = navY + navButton.box[4] + 1
			table.insert(LogTabRouteDetails.TemporaryButtons, navButton)
		end
	end

	local alreadyViewingTab = false
	for _, tab in pairs(LogTabRouteDetails.Tabs) do
		if LogOverlay.Windower.filterGrid == tab then
			alreadyViewingTab = true
			break
		end
	end
	if not alreadyViewingTab then
		if #data.e.Trainers > 0 then
			LogOverlay.Windower.filterGrid = LogTabRouteDetails.Tabs.Trainers
		elseif #data.e.GrassCave > 0 then
			LogOverlay.Windower.filterGrid = LogTabRouteDetails.Tabs.GrassCave
		else
			LogOverlay.Windower.filterGrid = LogTabRouteDetails.Tabs.Surfing
		end
	end
end

function LogTabRouteDetails.createTrainerButton(trainer)
	if not TrainerData.shouldUseTrainer(trainer.id) then
		return nil
	end
	local trainerInternal = TrainerData.getTrainerInfo(trainer.id) or {}
	local trainerLog = RandomizerLog.Data.Trainers[trainer.id] or {}
	local trainerImage = TrainerData.getPortraitIcon(trainerInternal.class)

	local button = {
		type = Constants.ButtonTypes.IMAGE,
		image = trainerImage,
		getText = function(self) return trainer.fullname end,
		textColor = LogTabRouteDetails.Colors.text,
		isSelected = false,
		class = trainer.class,
		name = trainer.name,
		id = trainer.id,
		maxlevel = trainer.maxlevel,
		dimensions = { width = 32, height = 32, },
		tab = LogTabRouteDetails.Tabs.Trainers,
		isVisible = function(self) return LogOverlay.Windower.filterGrid == self.tab and LogOverlay.Windower.currentPage == self.pageVisible end,
		updateSelf = function(self)
			self.isSelected = false
			-- Highlight anything that is found by the search
			if LogSearchScreen.searchText == "" then
				return
			end
			if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.TrainerName then
				if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
					self.isSelected = true
					return
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
				for _, partyMon in ipairs(trainerLog.party or {}) do
					local pokemonName = RandomizerLog.getPokemonName(partyMon.pokemonID)
					if Utils.containsText(pokemonName, LogSearchScreen.searchText, true) then
						self.isSelected = true
						return
					end
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
				for _, partyMon in ipairs(trainerLog.party or {}) do
					for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
						local abilityText = AbilityData.Abilities[abilityId].name
						if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
							self.isSelected = true
							return
						end
					end
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
				for _, partyMon in ipairs(trainerLog.party or {}) do
					for _, moveId in ipairs(partyMon.moveIds or {}) do
						local moveText = MoveData.Moves[moveId].name
						if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
							self.isSelected = true
							return
						end
					end
				end
			end
		end,
		includeInGrid = function(self) return LogOverlay.Windower.filterGrid == self.tab end,
		onClick = function(self)
			LogOverlay.Windower:changeTab(LogTabTrainerDetails, 1, 1, self.id)
			Program.redraw(true)
			-- InfoScreen.changeScreenView(InfoScreen.Screens.TRAINER_INFO, self.id) -- TODO: (future feature) implied redraw
		end,
		draw = function(self, shadowcolor)
			LogTabTrainers.drawTrainerPortraitInfo(self, shadowcolor)
			-- If this was found through search
			if self.isSelected then
				local color = Theme.COLORS[LogTabRouteDetails.Colors.hightlight]
				Drawing.drawSelectionIndicators(self.box[1], self.box[2], self.box[3], self.box[4], color, 1, 5, 1)
			end
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
	local rateText = string.format("(%s%%)", math.floor(encounterInfo.rate * 100))
	local rateCenterX = Utils.getCenteredTextX(rateText, 32)

	local button = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		id = encounterInfo.pokemonID,
		getText = function(self) return RandomizerLog.getPokemonName(encounterInfo.pokemonID) end,
		textColor = LogTabRouteDetails.Colors.text,
		isSelected = false,
		boxColors = { LogTabRouteDetails.Colors.border, LogTabRouteDetails.Colors.boxFill },
		tab = LogTabRouteDetails.Tabs[encounterKey],
		levelMin = encounterInfo.levelMin,
		levelMax = encounterInfo.levelMax,
		rate = encounterInfo.rate,
		dimensions = { width = 32, height = 32, },
		isVisible = function(self) return LogOverlay.Windower.filterGrid == self.tab and LogOverlay.Windower.currentPage == self.pageVisible end,
		updateSelf = function(self)
			self.isSelected = false
			-- Highlight anything that is found by the search
			if LogSearchScreen.searchText == "" then
				return
			end
			if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
				if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
					self.isSelected = true
					return
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
				for _, abilityId in pairs(pokemonLog.Abilities or {}) do
					local abilityText = AbilityData.Abilities[abilityId].name
					if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
						self.isSelected = true
						return
					end
				end
			elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
				for _, move in pairs(pokemonLog.MoveSet or {}) do
					local moveText = move.name -- potentially a custom move name
					if MoveData.isValid(move.moveId) then
						moveText = MoveData.Moves[move.moveId].name
					end
					if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
						self.isSelected = true
						return
					end
				end
			end
		end,
		includeInGrid = function(self) return LogOverlay.Windower.filterGrid == self.tab end,
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
			Drawing.drawText(self.box[1] - 3, self.box[2] - 1, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			-- Draw the level range and encounter rate below the icon
			local belowY = 34
			Drawing.drawText(self.box[1] - 3, self.box[2] + belowY, levelRangeText, Theme.COLORS[self.textColor], shadowcolor)
			Drawing.drawText(self.box[1] + rateCenterX + 1, self.box[2] + belowY + 9, rateText, Theme.COLORS[self.textColor], shadowcolor)
			-- If this was found through search
			if self.isSelected then
				local color = Theme.COLORS[LogTabRouteDetails.Colors.hightlight]
				Drawing.drawSelectionIndicators(self.box[1], self.box[2] + 10, self.box[3] - 2, self.box[4] - 9, color, 1, 5, 1)
			end
		end,
	}
	return button
end

function LogTabRouteDetails.realignGrid(gridFilter, sortFunc, startingPage)
	if gridFilter ~= nil then
		LogOverlay.Windower.filterGrid = gridFilter
	end

	if LogOverlay.Windower.filterGrid == LogTabRouteDetails.Tabs.Trainers then
		LogTabRouteDetails.realignTrainerGrid(gridFilter, sortFunc, startingPage)
	else
		LogTabRouteDetails.realignPokemonGrid(gridFilter, sortFunc, startingPage)
	end

	LogTabRouteDetails.refreshButtons()
end

function LogTabRouteDetails.realignTrainerGrid(gridFilter, sortFunc, startingPage)
	sortFunc = sortFunc or LogSearchScreen.SortBy.TrainerLevel.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabRouteDetails.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 73
	local y = LogOverlay.TabBox.y + 30
	local colSpacer = 24
	local rowSpacer = 28
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	LogOverlay.Windower.filterGrid = gridFilter or LogTabRouteDetails.Tabs.Trainers
	local totalPages = Utils.gridAlign(LogTabRouteDetails.PagedButtons, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogOverlay.Windower.totalPages = totalPages
	LogOverlay.Windower.currentPage = math.min(startingPage, totalPages)
end

function LogTabRouteDetails.realignPokemonGrid(gridFilter, sortFunc, startingPage)
	sortFunc = sortFunc or function(a, b)
		return (a.rate or 0) > (b.rate or 0) or (a.rate == b.rate and a.id < b.id)
	end
	startingPage = startingPage or 1

	table.sort(LogTabRouteDetails.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 73
	local y = LogOverlay.TabBox.y + 20
	local colSpacer = 24
	local rowSpacer = 28
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	LogOverlay.Windower.filterGrid = gridFilter or LogOverlay.Windower.filterGrid
	local totalPages = Utils.gridAlign(LogTabRouteDetails.PagedButtons, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogOverlay.Windower.totalPages = totalPages
	LogOverlay.Windower.currentPage = math.min(startingPage, totalPages)
end

-- USER INPUT FUNCTIONS
function LogTabRouteDetails.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRouteDetails.TemporaryButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRouteDetails.PagedButtons)
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
	for _, button in pairs(LogTabRouteDetails.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
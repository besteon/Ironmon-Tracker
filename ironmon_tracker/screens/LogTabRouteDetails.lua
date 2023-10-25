LogTabRouteDetails = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		highlight = "Intermediate text",
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
	LogTabRouteDetails.realignGrid(LogOverlay.Windower.filterGrid, nil, LogOverlay.Windower.currentPage)
end

function LogTabRouteDetails.buildZoomButtons(mapId)
	mapId = mapId or LogTabRouteDetails.infoId or -1
	local data = DataHelper.buildRouteLogDisplay(mapId)
	LogTabRouteDetails.infoId = mapId
	LogTabRouteDetails.dataSet = data

	LogTabRouteDetails.TemporaryButtons = {}
	LogTabRouteDetails.PagedButtons = {}

	-- ROUTE NAME & ICON
	local routeName = Utils.toUpperUTF8(data.r.name)
	local routeNameButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return routeName end,
		textColor = LogTabRouteDetails.Colors.highlight,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 2, 120, 12 },
	}
	table.insert(LogTabRouteDetails.TemporaryButtons, routeNameButton)
	-- Currentl unused, doesn't quite fit
	-- local routeIconButton = {
	-- 	type = Constants.ButtonTypes.IMAGE,
	-- 	image = data.r.icon:getIconPath(),
	-- 	box = { LogOverlay.TabBox.x + LogOverlay.TabBox.width - 20, LogOverlay.TabBox.y + 1, 20, 20 },
	-- }
	-- table.insert(LogTabRouteDetails.TemporaryButtons, routeIconButton)

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
	local navX = LogOverlay.TabBox.x + LogOverlay.TabBox.width - 69 + 3
	local navY = 62

	local navHeaderButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.LabelEncounters .. ":" end,
		textColor = LogTabRouteDetails.Colors.text,
		box = { navX, navY, 64, 11 },
		draw = function(self, shadowcolor)
			-- Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
		end,
	}
	local encDetailsButton = {
		type = Constants.ButtonTypes.NO_BORDER,
		getEncText = function(self) return Resources.LogOverlay[self.resourceKey] or "" end,
		resourceKey = "",
		textColor = LogTabRouteDetails.Colors.highlight,
		box = { navX, LogOverlay.TabBox.y + 7, 64, 11 },
		draw = function(self, shadowcolor)
			if self.image then
				local x, y = self.box[1] + 23, self.box[2] + 14
				if self.imageType == Constants.ButtonTypes.IMAGE then
					Drawing.drawImage(self.image, x, y + 1)
				elseif self.imageType == Constants.ButtonTypes.PIXELIMAGE then
					Drawing.drawImageAsPixels(self.image, x, y, self.iconColors, shadowcolor)
				end
			end
			local encText = self:getEncText()
			local textCenteredX = navX + Utils.getCenteredTextX(encText, 69) - 6
			Drawing.drawText(textCenteredX, self.box[2], encText, Theme.COLORS[self.textColor], shadowcolor)
		end,
	}
	table.insert(LogTabRouteDetails.TemporaryButtons, navHeaderButton)
	table.insert(LogTabRouteDetails.TemporaryButtons, encDetailsButton)
	navY = navY + navHeaderButton.box[4] + 5

	local tabNavigation = {
		{
			encKey = "Trainers",
			resourceKey = "TabTrainers",
			tab = LogTabRouteDetails.Tabs.Trainers,
			type = Constants.ButtonTypes.IMAGE,
			image = LogOverlay.getPlayerIconHead(),
		},
		{
			encKey = "GrassCave",
			resourceKey = "TabGrassCave",
			tab = LogTabRouteDetails.Tabs.GrassCave,
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.GRASS,
			iconColors = { 0xFF385810, 0xFF389030, 0xFF40B088, 0xFF70C8A0, 0xFFA0E0C0, 0xFF70C8A0 },
		},
		{
			encKey = "Surfing",
			resourceKey = "TabSurfing",
			tab = LogTabRouteDetails.Tabs.Surfing,
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.SURFING,
			iconColors = { 0xFF000000, 0xFF4A4A5A, 0xFF8C8C94, 0xFFFFFFFF, 0xFF6384CE, 0xFF94C5EF, 0xFFC5C5D6, 0xFFFFD6B5, 0xFFDE9473, 0xFF7B4242, 0xFF4890D8 },
		},
		{
			encKey = "OldRod",
			resourceKey = "TabOldRod",
			tab = LogTabRouteDetails.Tabs.OldRod,
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.FISHING_ROD,
			iconColors = { 0xFF292829, 0xFF6B3808, 0xFF946100, 0xFFC69239, 0xFFCE4D29, 0xFF6B8221, 0xFFFFFFFF, 0xFFC6DBE7, 0xFF4890D8 },
		},
		{
			encKey = "GoodRod",
			resourceKey = "TabGoodRod",
			tab = LogTabRouteDetails.Tabs.GoodRod,
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.FISHING_ROD,
			-- 3rd and 4th are the rod's colors, 5th and 6th for ball
			iconColors = { 0xFF292829, 0xFF404040, 0xFF424584, 0xFF7371AD, 0xFF3890F8, 0xFFF8A8A8, 0xFFFFFFFF, 0xFFC6DBE7, 0xFF4890D8 },
		},
		{
			encKey = "SuperRod",
			resourceKey = "TabSuperRod",
			tab = LogTabRouteDetails.Tabs.SuperRod,
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.FISHING_ROD,
			-- 3rd and 4th are the rod's colors, 5th and 6th for ball
			iconColors = { 0xFF292829, 0xFF4A4542, 0xFF94AEB5, 0xFFC6DBE7, 0xFFB038F0, 0xFFE020C0, 0xFFFFFFFF, 0xFFC6DBE7, 0xFF4890D8 },
		},
		{
			encKey = "RockSmash",
			resourceKey = "TabRockSmash",
			tab = LogTabRouteDetails.Tabs.RockSmash,
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.ROCK,
			iconColors = { 0xFF000000, 0xFF383818, 0xFF787040, 0xFFC8A860, 0xFF908870 },
		},
	}
	local iconX, iconY = navX + 2, navY
	local numAdded = 0
	for _, enc in ipairs(tabNavigation) do
		local total = encTotals[enc.tab or 0] or 0
		if total > 0 then
			local navButton = {
				type = enc.type,
				image = enc.image,
				textColor = LogTabRouteDetails.Colors.text,
				iconColors = enc.iconColors,
				tab = enc.tab,
				totalCount = total,
				isSelected = false,
				box = { iconX, iconY, 16, 16 },
				clickableArea = { iconX, iconY, 16 + 18, 16 },
				updateSelf = function(self)
					self.isSelected = (LogOverlay.Windower.filterGrid == self.tab)
				end,
				draw = function(self, shadowcolor)
					local totalText = tostring(self.totalCount)
					Drawing.drawText(self.box[1] + self.box[3] + 1, self.box[2] + 1, totalText, Theme.COLORS[self.textColor], shadowcolor)
					if self.isSelected then
						local color = Theme.COLORS[LogTabRouteDetails.Colors.highlight]
						local textWidth = Utils.calcWordPixelLength(totalText) + 4
						Drawing.drawSelectionIndicators(self.box[1] - 1, self.box[2] - 1, self.box[3] + textWidth, self.box[4] + 1, color, 1, 4, 1)
					end
				end,
				onClick = function(self)
					if self.isSelected then return end -- Don't change if already on this tab
					LogTabRouteDetails.realignGrid(self.tab)
					encDetailsButton.imageType = enc.type
					encDetailsButton.image = enc.image
					encDetailsButton.iconColors = enc.iconColors
					encDetailsButton.resourceKey = enc.resourceKey or ""
					Program.redraw(true)
				end,
			}
			table.insert(LogTabRouteDetails.TemporaryButtons, navButton)
			numAdded = numAdded + 1
			if numAdded % 2 == 1 then
				iconX = iconX + navButton.box[3] + 17
			else
				iconX = iconX - navButton.box[3] - 17
				iconY = iconY + navButton.box[4] + 4
			end
		end
	end

	local currentViewedTab
	for _, tab in pairs(LogTabRouteDetails.Tabs) do
		if LogOverlay.Windower.filterGrid == tab then
			currentViewedTab = tab
			break
		end
	end
	if not currentViewedTab then
		if #data.e.Trainers > 0 then
			currentViewedTab = LogTabRouteDetails.Tabs.Trainers
		elseif #data.e.GrassCave > 0 then
			currentViewedTab = LogTabRouteDetails.Tabs.GrassCave
		else
			currentViewedTab = LogTabRouteDetails.Tabs.Surfing
		end
		LogOverlay.Windower.filterGrid = currentViewedTab
	end
	local navTabViewed = tabNavigation[currentViewedTab] or {}
	encDetailsButton.imageType = navTabViewed.type
	encDetailsButton.image = navTabViewed.image
	encDetailsButton.iconColors = navTabViewed.iconColors
	encDetailsButton.resourceKey = navTabViewed.resourceKey or ""
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
		getText = function(self)
			if Options["Use Custom Trainer Names"] then
				return trainer.customFullname
			else
				return trainer.fullname
			end
		end,
		textColor = LogTabRouteDetails.Colors.text,
		isSelected = false,
		class = trainer.class,
		name = trainer.name,
		customClass = trainer.customClass,
		customName = trainer.customName,
		id = trainer.id,
		maxlevel = trainer.maxlevel,
		dimensions = { width = 32, height = 32, },
		tab = LogTabRouteDetails.Tabs.Trainers,
		isVisible = function(self) return LogOverlay.Windower.filterGrid == self.tab and LogOverlay.Windower.currentPage == self.pageVisible end,
		updateSelf = function(self)
			self.isSelected = false
			-- Highlight anything that is found by the search
			if Utils.isNilOrEmpty(LogSearchScreen.searchText) then
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
				local color = Theme.COLORS[LogTabRouteDetails.Colors.highlight]
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
			if Utils.isNilOrEmpty(LogSearchScreen.searchText) then
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
		getIconId = function(self) return self.id, SpriteData.Types.Walk end,
		onClick = function(self)
			LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.id)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[self.boxColors[2]]
			-- Draw the Pokemon's name above the icon
			Drawing.drawTransparentTextbox(x - 3, y - 4, self:getText() or "", textColor, bgColor, shadowcolor)
			-- Draw the level range and encounter rate below the icon
			local belowY = 34
			Drawing.drawTransparentTextbox(x - 3, y + belowY, levelRangeText, textColor, bgColor, shadowcolor)
			Drawing.drawTransparentTextbox(x + rateCenterX + 1, y + belowY + 9, rateText, textColor, bgColor, shadowcolor)
			-- If this was found through search
			if self.isSelected then
				local color = Theme.COLORS[LogTabRouteDetails.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y + 7, self.box[3] - 1, self.box[4] - 5, color, 1, 5, 1)
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

	local x = LogOverlay.TabBox.x + 7
	local y = LogOverlay.TabBox.y + 28
	local colSpacer = 24
	local rowSpacer = 32
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x - 69
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

	local x = LogOverlay.TabBox.x + 7
	local y = LogOverlay.TabBox.y + 21
	local colSpacer = 24
	local rowSpacer = 32
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x - 69
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
	local highlightColor = Theme.COLORS[LogTabRouteDetails.Colors.highlight]
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

	-- Draw box surrounding the encounters nav tables
	local w, h = 69 - 1, 96
	local x, y = LogOverlay.TabBox.x + LogOverlay.TabBox.width - w, LogOverlay.TabBox.y + LogOverlay.TabBox.height - h
	gui.drawRectangle(x, y, w, h, borderColor)

	-- Draw all buttons
	for _, button in pairs(LogTabRouteDetails.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabRouteDetails.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
LogOverlay = {
	Colors = {
		headerText = "Header text",
		headerBorder = "Upper box background",
		headerFill = "Main background",
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Tabs = {
		POKEMON = "Pokémon",
		POKEMON_ZOOM = "Pokémon Zoom",
		POKEMON_ZOOM_LEVELMOVES = "Levelup Moves", -- non-primary tab
		POKEMON_ZOOM_TMMOVES = "TM Moves", -- non-primary tab
		TRAINER = "Trainers",
		TRAINER_ZOOM = "Trainer Zoom",
		TMS = "TMs",
		MISC = "Misc.",
		GO_BACK = "Back",
	},
	debugTrainerIconBoxes = false,
	margin = 2,
	tabHeight = 12,
	currentTab = nil,
	currentTabInfoId = nil,
	isDisplayed = false,
	isGameOver = false, -- Set to true when game is over, so we known to show game over screen if X is pressed
}

-- Dimensions of the screen space occupied by the currentl visible Tab
LogOverlay.TabBox = {
	x = LogOverlay.margin,
	y = LogOverlay.tabHeight,
	width = Constants.SCREEN.WIDTH - (LogOverlay.margin * 2),
	height = Constants.SCREEN.HEIGHT - LogOverlay.tabHeight - LogOverlay.margin - 1,
}

LogOverlay.Windower = {
	currentPage = nil,
	totalPages = nil,
	filterGrid = "#",
	getPageText = function(self)
		if self.totalPages == nil or self.totalPages < 1 then return Resources.AllScreens.Page end
		return string.format("%s %s/%s", Resources.AllScreens.Page, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages == nil or self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages == nil or self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
	changeTab = function(self, newTab, pageNum, totalPages, tabInfoId, filterGrid)
		local prevTab = {
			tab = LogOverlay.currentTab,
			infoId = LogOverlay.currentTabInfoId,
			page = self.currentPage,
			totalPages = self.totalPages,
			filterGrid = self.filterGrid,
		}

		LogOverlay.currentTab = newTab
		LogOverlay.currentTabInfoId = tabInfoId or LogOverlay.currentTabInfoId
		self.currentPage = pageNum or self.currentPage or 1
		self.totalPages = totalPages or self.totalPages or 1
		self.filterGrid = filterGrid or self.filterGrid or "#"

		if newTab == LogOverlay.Tabs.POKEMON_ZOOM then
			LogOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(tabInfoId)
			LogTabPokemonDetails.buildZoomButtons(LogOverlay.currentTabData)
			if prevTab.tab ~= LogOverlay.Tabs.POKEMON_ZOOM then
				table.insert(LogOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogOverlay.Tabs.TRAINER_ZOOM then
			LogOverlay.currentTabData = DataHelper.buildTrainerLogDisplay(tabInfoId)
			LogOverlay.buildTrainerZoomButtons(LogOverlay.currentTabData)
			if prevTab.tab ~= LogOverlay.Tabs.TRAINER_ZOOM then
				table.insert(LogOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogOverlay.Tabs.GO_BACK then
			prevTab = table.remove(LogOverlay.TabHistory)
			if prevTab ~= nil then
				self:changeTab(prevTab.tab, prevTab.page, prevTab.totalPages, prevTab.infoId, prevTab.filterGrid)
			else
				LogTabPokemon.realignGrid()
				self:changeTab(LogOverlay.Tabs.POKEMON)
			end
			return
		end

		LogOverlay.refreshTabBar()
		LogOverlay.refreshInnerButtons()

		-- After reloading the search results content, update to show the last viewed page and grid
		if LogSearchScreen.tryDisplayOrHide() then
			self.currentPage = pageNum or self.currentPage or 1
			self.totalPages = totalPages or self.totalPages or 1
			self.filterGrid = filterGrid or self.filterGrid or "#"
		end
		Program.redraw(true)
	end,
}

LogOverlay.TabBarButtons = {
	PokemonTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.HeaderTabPokemon end,
		tab = LogOverlay.Tabs.POKEMON,
		box = { LogOverlay.margin + 1, 0, 41, 11, },
		updateSelf = function(self)
			self.textColor = Utils.inlineIf(LogOverlay.currentTab == self.tab, Theme.headerHighlightKey, LogOverlay.Colors.headerText)
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == Theme.headerHighlightKey then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogOverlay.currentTab ~= self.tab then
				LogTabPokemon.realignGrid()
				LogOverlay.TabHistory = {}
				LogOverlay.Windower:changeTab(self.tab)
				LogSearchScreen.resetSortFilterSearch(self.tab)
				Program.redraw(true)
			end
		end,
	},
	TrainersTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.HeaderTabTrainers end,
		tab = LogOverlay.Tabs.TRAINER,
		box = { LogOverlay.margin + 45, 0, 34, 11, },
		updateSelf = function(self)
			self.textColor = Utils.inlineIf(LogOverlay.currentTab == self.tab, Theme.headerHighlightKey, LogOverlay.Colors.headerText)
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == Theme.headerHighlightKey then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogOverlay.currentTab ~= self.tab then
				LogTabTrainers.realignGrid()
				LogOverlay.TabHistory = {}
				LogOverlay.Windower:changeTab(self.tab)
				LogSearchScreen.resetSortFilterSearch(self.tab)
				Program.redraw(true)
			end
		end,
	},
	TMsTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.HeaderTabTMs end,
		tab = LogOverlay.Tabs.TMS,
		box = { LogOverlay.margin + 45 + 38, 0, 18, 11, },
		updateSelf = function(self)
			self.textColor = Utils.inlineIf(LogOverlay.currentTab == self.tab, Theme.headerHighlightKey, LogOverlay.Colors.headerText)
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == Theme.headerHighlightKey then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogOverlay.currentTab ~= self.tab then
				LogTabTMs.realignGrid()
				LogOverlay.TabHistory = {}
				LogOverlay.Windower:changeTab(self.tab)
				LogSearchScreen.resetSortFilterSearch(self.tab)
				Program.redraw(true)
			end
		end,
	},
	MiscTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.HeaderTabMisc end,
		tab = LogOverlay.Tabs.MISC,
		box = { LogOverlay.margin + 45 + 38 + 22, 0, 22, 11, },
		updateSelf = function(self)
			self.textColor = Utils.inlineIf(LogOverlay.currentTab == self.tab, Theme.headerHighlightKey, LogOverlay.Colors.headerText)
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == Theme.headerHighlightKey then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogOverlay.currentTab ~= self.tab then
				LogOverlay.TabHistory = {}
				LogOverlay.Windower:changeTab(self.tab, 1, 1)
				LogSearchScreen.resetSortFilterSearch(self.tab)
				Program.redraw(true)
			end
		end,
	},
	XIcon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOSE,
		textColor = Theme.headerHighlightKey,
		box = { LogOverlay.margin + 228, 2, 10, 10 },
		updateSelf = function(self)
			self.textColor = Theme.headerHighlightKey
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.image = Constants.PixelImages.LEFT_ARROW
				self.box[2] = 1
			else
				self.image = Constants.PixelImages.CLOSE
				self.box[2] = 2
			end
		end,
		onClick = function(self)
			if self.image == Constants.PixelImages.CLOSE then
				LogOverlay.TabHistory = {}
				LogOverlay.isDisplayed = false
				LogSearchScreen.clearSearch()
				if LogOverlay.isGameOver then
					Program.changeScreenView(GameOverScreen)
				elseif not Program.isValidMapLocation() then
					-- If the game hasn't started yet
					Program.changeScreenView(StartupScreen)
				else
					Program.changeScreenView(TrackerScreen)
				end
			else -- Constants.PixelImages.PREVIOUS_BUTTON
				LogOverlay.Windower:changeTab(LogOverlay.Tabs.GO_BACK)
				Program.redraw(true)
			end
		end,
	},
}

LogOverlay.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return LogOverlay.Windower:getPageText() end,
		textColor = Theme.headerHighlightKey,
		box = { LogOverlay.margin + 151, 0, 50, 10, },
		isVisible = function() return LogOverlay.Windower.totalPages > 1 end, -- Likely won't use, unsure where to place it
		updateSelf = function(self)
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.textColor = Theme.headerHighlightKey
			else
				self.textColor = Theme.headerHighlightKey
			end
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		textColor = Theme.headerHighlightKey,
		shadowcolor = false,
		-- Left of CurrentPage
		box = { LogOverlay.margin + 151 - 13, 1, 10, 10 },
		isVisible = function() return LogOverlay.Windower.totalPages > 1 end,
		updateSelf = function(self)
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.textColor = "Lower box text"
			else
				self.textColor = Theme.headerHighlightKey
			end
		end,
		onClick = function(self) LogOverlay.Windower:prevPage() end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		textColor = Theme.headerHighlightKey,
		shadowcolor = false,
		-- Right of CurrentPage, account for current page text
		box = { LogOverlay.margin + 151 + 50 + 3, 1, 10, 10 },
		isVisible = function() return LogOverlay.Windower.totalPages > 1 end,
		updateSelf = function(self)
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.textColor = "Lower box text"
			else
				self.textColor = Theme.headerHighlightKey
			end
		end,
		onClick = function(self) LogOverlay.Windower:nextPage() end,
	},
}

LogOverlay.NavFilterButtons = {}

-- Holds temporary buttons that only exist while drilling down on specific log info, e.g. pokemon evo icons
LogOverlay.TemporaryButtons = {}

-- Holds all of the parsed data in nicely formatted buttons for display and interaction
LogOverlay.PagedButtons = {}

-- A stack manage the back-button within tabs, each element is { tab, page, }
LogOverlay.TabHistory = {}

-- Navigation filters for each of the window tabs. Each has a label for the button, and a sort function for the grid
LogOverlay.NavFilters = {
	Trainers = {
		All = {
			getText = function() return Resources.LogOverlay.FilterAll end,
			group = TrainerData.TrainerGroups.All,
			index = 1,
			sortFunc = function(a, b)
				if a.group < b.group then
					return true
				elseif a.group == b.group then
					if a.group == TrainerData.TrainerGroups.Rival or a.group == TrainerData.TrainerGroups.Boss then -- special sort for rival/wally #s
						return a:getText() < b:getText()
					elseif a.filename < b.filename then
						return a.filename < b.filename
					end
				end
				return false
			end,
		},
		Rival = {
			getText = function() return Resources.LogOverlay.FilterRival end,
			group = TrainerData.TrainerGroups.Rival,
			index = 2,
			sortFunc = function(a, b) return a:getText() < b:getText() end,
		},
		Gym = {
			getText = function() return Resources.LogOverlay.FilterGym end,
			group = TrainerData.TrainerGroups.Gym,
			index = 3,
			sortFunc = function(a, b) return a.filename:sub(-1) < b.filename:sub(-1) end,
		},
		Elite4 = {
			getText = function() return Resources.LogOverlay.FilterElite4 end,
			group = TrainerData.TrainerGroups.Elite4,
			index = 4,
			sortFunc = function(a, b) return a.filename:sub(-1) < b.filename:sub(-1) end,
		},
		Boss = {
			getText = function() return Resources.LogOverlay.FilterBoss end,
			group = TrainerData.TrainerGroups.Boss,
			index = 5,
			sortFunc = function(a, b) return a:getText() < b:getText() end,
		},
		-- { -- Temp Removing both of these until better data gets sorted out
		-- 	getText = function() return Resources.LogOverlay.FilterOther end,
		-- 	group = TrainerData.TrainerGroups.Other,
		-- 	sortFunc = function(a, b) return a:getText() < b:getText() end,
		-- },
		-- {
		-- 	getText = function() return "(?)" end,
		-- 	group = "?",
		-- },
	},
	TMs = {
		TMNumber = { -- If this changes from index 2, update it's references
			getText = function() return Resources.LogOverlay.FilterTMNumber end,
			group = "TM #",
			index = 10,
			sortFunc = function(a, b) return a.tmNumber < b.tmNumber end,
		},
		GymTMs = { -- If this changes from index 2, update it's references
			getText = function() return Resources.LogOverlay.FilterGymTMs end,
			group = "Gym TMs",
			index = 11,
			sortFunc = function(a, b) return a.gymNumber < b.gymNumber end,
		},
	},
}

function LogOverlay.initialize()
	LogOverlay.currentTab = nil
	LogOverlay.isDisplayed = false
	LogOverlay.isGameOver = false

	LogOverlay.TabHistory = {}

	for _, button in pairs(LogOverlay.TabBarButtons) do
		if button.textColor == nil then
			button.textColor = LogOverlay.Colors.headerText
		end
		if button.boxColors == nil then
			button.boxColors = { LogOverlay.Colors.headerBorder, LogOverlay.Colors.headerFill }
		end
	end
	for _, button in pairs(LogOverlay.Buttons) do
		if button.textColor == nil then
			button.textColor = LogOverlay.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { LogOverlay.Colors.border, LogOverlay.Colors.boxFill }
		end
	end
end

-- Build out all paged buttons for all Tab screens using the parsed data
function LogOverlay.buildAllTabs()
	-- Pokemon
	LogTabPokemon.buildPagedButtons()
	-- Trainers
	local gymTMs = LogTabTrainers.buildPagedButtons()
	-- TMs
	LogTabTMs.buildPagedButtons(gymTMs)
	LogTabTMs.buildGymTMButtons()
end

-- Organizes a list of buttons in a row by column fashion based on (x,y,w,h) and what page they should display on.
-- Returns total pages
function LogOverlay.gridAlign(buttonList, startX, startY, width, height, colSpacer, rowSpacer, listVerticallyFirst)
	listVerticallyFirst = listVerticallyFirst == true
	local offsetX, offsetY = 0, 0
	local maxWidth = Constants.SCREEN.WIDTH - LogOverlay.margin
	local maxHeight = Constants.SCREEN.HEIGHT - LogOverlay.margin -- - 10 -- 10 padding near bottom for filter options
	local maxItemSize = 0

	local itemCount = 0
	local itemsPerPage = nil
	for _, button in ipairs(buttonList) do
		if button:includeInGrid() then
			local w, h, extraX, extraY = width, height, 0, 0
			if button.dimensions ~= nil then
				w = button.dimensions.width or width or 40
				h = button.dimensions.height or height or 40
				extraX = button.dimensions.extraX or 0
				extraY = button.dimensions.extraY or 0
			end

			if listVerticallyFirst then
				-- Check if new height requires starting a new column
				if (startY + offsetY + h) > maxHeight then
					offsetX = offsetX + maxItemSize + colSpacer
					offsetY = 0
					maxItemSize = 0
				end
				-- Check if new width requires starting a new page
				if (startX + offsetX + w) > maxWidth then
					offsetX, offsetY, maxItemSize = 0, 0, 0
					if itemsPerPage == nil then
						itemsPerPage = itemCount
					end
				end
			else
				-- Check if new width requires starting a new row
				if (startX + offsetX + w) > maxWidth then
					offsetX = 0
					offsetY = offsetY + maxItemSize + rowSpacer
					maxItemSize = 0
				end
				-- Check if new height requires starting a new page
				if (startY + offsetY + h) > maxHeight then
					offsetX, offsetY, maxItemSize = 0, 0, 0
					if itemsPerPage == nil then
						itemsPerPage = itemCount
					end
				end
			end

			itemCount = itemCount + 1
			local x = startX + offsetX + extraX
			local y = startY + offsetY + extraY
			if button.type == Constants.ButtonTypes.POKEMON_ICON then
				button.clickableArea = { x, y + 4, w, h - 4 }
			end
			button.box = { x, y, w, h }
			if itemsPerPage == nil then
				button.pageVisible = 1
			else
				button.pageVisible = math.ceil(itemCount / itemsPerPage)
			end

			if listVerticallyFirst then
				if w > maxItemSize then
					maxItemSize = w
				end
				offsetY = offsetY + h + rowSpacer
			else
				if h > maxItemSize then
					maxItemSize = h
				end
				offsetX = offsetX + w + colSpacer
			end

		else
			button.pageVisible = -1
		end
	end

	-- Return number of items per page, total pages
	if itemsPerPage == nil then
		return 1
	else
		return math.ceil(itemCount / itemsPerPage)
	end
end

function LogOverlay.buildTrainerZoomButtons(data)
	LogOverlay.TemporaryButtons = {}

	local partyListX, partyListY = LogOverlay.margin + 1, LogOverlay.tabHeight + 76
	local startX, startY = LogOverlay.margin + 60, LogOverlay.tabHeight + 2
	local offsetX, offsetY = 0, 0
	local colOffset, rowOffset = 86, 49 -- 2nd column, and 2nd/3rd rows
	for i, partyPokemon in ipairs(data.p or {}) do
		-- PARTY POKEMON
		local pokemonNameButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return string.format("%s. %s", i, partyPokemon.name) end, -- e.g. "1. Shuckle"
			textColor = "Lower box text",
			pokemonID = partyPokemon.id,
			tab = LogOverlay.Tabs.TRAINER_ZOOM,
			box = { partyListX, partyListY, 60, 11 },
			isVisible = function(self) return LogOverlay.currentTab == self.tab end,
			updateSelf = function(self)
				self.textColor = "Lower box text"
				-- Highlight moves that are found by the search
				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName and LogSearchScreen.searchText ~= "" then
					if Utils.containsText(partyPokemon.name, LogSearchScreen.searchText, true) then
						self.textColor = "Intermediate text"
					end
				end
			end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end
			end,
		}
		partyListY = partyListY + Constants.SCREEN.LINESPACING
		local pokemonIconButton = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getText = function(self) return string.format("%s.%s", Resources.TrackerScreen.LevelAbbreviation, partyPokemon.level) end,
			pokemonID = partyPokemon.id,
			tab = LogOverlay.Tabs.TRAINER_ZOOM,
			textColor = "Lower box text",
			clickableArea = { startX + offsetX, startY + offsetY, 32, 29, },
			box = { startX + offsetX, startY + offsetY - 4, 32, 32, },
			isVisible = function(self) return LogOverlay.currentTab == self.tab end,
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
			end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end
			end,
			draw = function(self, shadowcolor)
				-- Draw the Pokemon's level below the icon
				local levelOffsetX = self.box[1] + 5
				local levelOffsetY = self.box[2] + self.box[4] + 2
				Drawing.drawText(levelOffsetX, levelOffsetY, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
		}
		table.insert(LogOverlay.TemporaryButtons, pokemonNameButton)
		table.insert(LogOverlay.TemporaryButtons, pokemonIconButton)

		-- helditem = partyMon.helditem ???

		-- PARTY POKEMON's MOVES
		local moveOffsetX = startX + offsetX + 30
		local moveOffsetY = startY + offsetY
		for _, moveInfo in ipairs(partyPokemon.moves or {}) do
			local moveColor = Utils.inlineIf(moveInfo.isstab, "Positive text", "Lower box text")
			local moveBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				getText = function(self) return moveInfo.name end,
				textColor = moveColor,
				moveId = moveInfo.moveId,
				tab = LogOverlay.Tabs.TRAINER_ZOOM,
				box = { moveOffsetX, moveOffsetY, 60, 11 },
				isVisible = function(self) return LogOverlay.currentTab == self.tab end,
				updateSelf = function(self)
					self.textColor = moveColor
					-- Highlight moves that are found by the search
					if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove and LogSearchScreen.searchText ~= "" then
						if Utils.containsText(moveInfo.name, LogSearchScreen.searchText, true) then
							self.textColor = "Intermediate text"
						end
					end
				end,
				onClick = function(self)
					if MoveData.isValid(self.moveId) then
						InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
					end
				end,
			}
			table.insert(LogOverlay.TemporaryButtons, moveBtn)
			moveOffsetY = moveOffsetY + Constants.SCREEN.LINESPACING - 1
		end

		if i % 2 == 1 then
			offsetX = offsetX + colOffset
		else
			offsetX = 0
			offsetY = offsetY + rowOffset
		end
	end
end

-- For showing what's highlighted and updating the page #
function LogOverlay.refreshTabBar()
	for _, button in pairs(LogOverlay.TabBarButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogOverlay.refreshInnerButtons()
	for _, button in pairs(LogOverlay.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogOverlay.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogOverlay.NavFilterButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

-- Rebuilds the buttons for the currently displayed screen. Useful when the Tracker's display language changes
function LogOverlay.rebuildScreen()
	if not LogOverlay.isDisplayed then return end

	local gridFilter = LogOverlay.Windower.filterGrid

	-- Rebuild majority of the data, and clear out navigation history
	LogOverlay.TabHistory = {}
	LogOverlay.buildAllTabs()

	-- Depending on what tab screen is visible, need to rebuild it
	if LogOverlay.currentTab == LogOverlay.Tabs.TRAINER then
		LogTabTrainers.realignGrid(gridFilter)
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TMS then
		LogTabTMs.realignGrid(gridFilter)
	elseif LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM then
		LogOverlay.Windower.currentPage = 1
		LogOverlay.Windower.totalPages = 1
		LogOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(LogOverlay.currentTabInfoId)
		LogTabPokemonDetails.buildZoomButtons(LogOverlay.currentTabData)
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
		LogOverlay.Windower.currentPage = 1
		LogOverlay.Windower.totalPages = 1
		LogOverlay.currentTabData = DataHelper.buildTrainerLogDisplay(LogOverlay.currentTabInfoId)
		LogOverlay.buildTrainerZoomButtons(LogOverlay.currentTabData)
	end

	LogOverlay.refreshTabBar()
	LogOverlay.refreshInnerButtons()
end

-- USER INPUT FUNCTIONS
function LogOverlay.checkInput(xmouse, ymouse)
	if not LogOverlay.isDisplayed then return end

	-- Order here matters
	Input.checkButtonsClicked(xmouse, ymouse, LogOverlay.TemporaryButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogOverlay.NavFilterButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogOverlay.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, LogOverlay.TabBarButtons)
	for _, buttonSet in pairs(LogOverlay.PagedButtons) do
		Input.checkButtonsClicked(xmouse, ymouse, buttonSet)
	end
end

-- DRAWING FUNCTIONS
function LogOverlay.drawScreen()
	if not LogOverlay.isDisplayed then return end

	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)

	local box = {
		x = LogOverlay.margin,
		y = LogOverlay.tabHeight,
		width = Constants.SCREEN.WIDTH - (LogOverlay.margin * 2),
		height = Constants.SCREEN.HEIGHT - LogOverlay.tabHeight - LogOverlay.margin - 1,
	}

	local borderColor, shadowcolor
	if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON then
		LogTabPokemon.drawTab()
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TRAINER then
		LogTabTrainers.drawTab()
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TMS then
		LogTabTMs.drawTab()
	elseif LogOverlay.currentTab == LogOverlay.Tabs.MISC then
		LogTabMisc.drawTab()
	elseif LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM then
		LogTabPokemonDetails.drawTab()
		borderColor = Theme.COLORS[LogTabPokemonDetails.Colors.border]
		shadowcolor = Utils.calcShadowColor(Theme.COLORS[LogTabPokemonDetails.Colors.boxFill])
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
		borderColor, shadowcolor = LogOverlay.drawTrainerZoomed(box.x, box.y, box.width, box.height)
	end

	-- Draw tab dividers
	gui.drawLine(box.x, 1, box.x, box.y - 1, borderColor or Theme.COLORS["Upper box border"])
	gui.drawLine(box.x + 44, 1, box.x + 44, box.y - 1, borderColor or Theme.COLORS["Upper box border"])
	gui.drawLine(box.x + 82, 1, box.x + 82, box.y - 1, borderColor or Theme.COLORS["Header text"])
	gui.drawLine(box.x + 104, 1, box.x + 104, box.y - 1, borderColor or Theme.COLORS["Header text"])

	-- Draw all buttons
	local bgColor = Utils.calcShadowColor(Theme.COLORS["Main background"]) -- Note, "header text" doesn't do shadows for transparency bgs
	for _, button in pairs(LogOverlay.TabBarButtons) do
		Drawing.drawButton(button, bgColor)
	end
	for _, button in pairs(LogOverlay.Buttons) do
		-- The page display currently lives in the header
		if button == LogOverlay.Buttons.CurrentPage or button == LogOverlay.Buttons.NextPage or button ==  LogOverlay.Buttons.PrevPage then
			Drawing.drawButton(button, bgColor)
		else
			Drawing.drawButton(button, shadowcolor)
		end
	end
	for _, button in pairs(LogOverlay.NavFilterButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

function LogOverlay.drawTrainerZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	local trainerId = LogOverlay.currentTabInfoId
	local data = LogOverlay.currentTabData
	if RandomizerLog.Data.Trainers[trainerId] == nil then
		return borderColor, shadowcolor
	elseif data == nil then -- ideally this is done only once on tab change
		LogOverlay.currentTabData = DataHelper.buildTrainerLogDisplay(trainerId)
		data = LogOverlay.currentTabData
	end

	-- GYM LEADER BADGE
	local badgeOffsetX = 0
	if data.x.gymNumber ~= nil then
		badgeOffsetX = 3
		local badgeName = GameSettings.badgePrefix .. "_badge" .. data.x.gymNumber
		local badgeImage = FileManager.buildImagePath(FileManager.Folders.Badges, badgeName, FileManager.Extensions.BADGE)
		gui.drawImage(badgeImage, LogOverlay.margin + 1, LogOverlay.tabHeight + 1)
	end

	-- TRAINER NAME
	local nameAsUppercase = Utils.toUpperUTF8(data.t.name)
	local nameWidth = Utils.calcWordPixelLength(nameAsUppercase)
	local nameOffsetX = (TrainerData.FileInfo.maxWidth - nameWidth) / 2 -- center the trainer name a bit
	Drawing.drawText(x + nameOffsetX + badgeOffsetX + 3, y + 2, nameAsUppercase, Theme.COLORS["Intermediate text"], shadowcolor)

	-- TRAINER ICON
	local trainerIcon = FileManager.buildImagePath(FileManager.Folders.Trainers, data.t.filename, FileManager.Extensions.TRAINER)
	local iconWidth = TrainerData.FileInfo[data.t.filename].width
	local iconOffsetX = (TrainerData.FileInfo.maxWidth - iconWidth) / 2 -- center the trainer icon a bit
	gui.drawImage(trainerIcon, x + iconOffsetX + 3, y + 16)

	for _, button in pairs(LogOverlay.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	return borderColor, shadowcolor
end

function LogOverlay.viewLogFile(postfix)
	local logpath = LogOverlay.getLogFileAutodetected(postfix)

	-- Check if there exists a parsed log with the same postfix as the one being requested
	local hasParsedThisLog = RandomizerLog.Data.Settings ~= nil and string.find(RandomizerLog.loadedLogPath or "", postfix, 1, true) ~= nil

	-- Only prompt for a new file if no autodetect and nothing has been parsed yet
	if logpath == nil and not hasParsedThisLog then
		logpath = LogOverlay.getLogFileFromPrompt()
	end

	LogOverlay.parseAndDisplay(logpath)
end

--- Attempts to determine the log file that matches the currently loaded rom. If not match or can't find, returns nil
--- @param postFix string The file's postFix, most likely FileManager.PostFixes.AUTORANDOMIZED or FileManager.PostFixes.PREVIOUSATTEMPT
--- @return string|nil
function LogOverlay.getLogFileAutodetected(postFix)
	postFix = postFix or FileManager.PostFixes.AUTORANDOMIZED

	local romname, rompath
	if Options["Use premade ROMs"] and Options.FILES["ROMs Folder"] ~= nil then
		-- First make sure the ROMs Folder ends with a slash
		if Options.FILES["ROMs Folder"]:sub(-1) ~= FileManager.slash then
			Options.FILES["ROMs Folder"] = Options.FILES["ROMs Folder"] .. FileManager.slash
		end

		romname = GameSettings.getRomName() or ""
		if postFix == FileManager.PostFixes.PREVIOUSATTEMPT then
			local currentRomPrefix = string.match(romname, '[^0-9]+') or ""
			local currentRomNumber = string.match(romname, '[0-9]+') or "0"
			-- Decrement to the previous ROM and determine its full file path
			local prevRomName = string.format(currentRomPrefix .. "%0" .. string.len(currentRomNumber) .. "d", tonumber(currentRomNumber) - 1)
			romname = prevRomName
		end

		rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(rompath) then
			romname = romname:gsub(" ", "_")
			rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		end
	elseif Options["Generate ROM each time"] then
		-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
		local quickloadFiles = Main.GetQuickloadFiles()
		local settingsFileName = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1] or "")
		romname = string.format("%s %s%s", settingsFileName, postFix, FileManager.Extensions.GBA_ROM)
		rompath = FileManager.prependDir(romname)
	end

	-- Check if the name of the rom being played on the emulator matches the name of the autodetected rom
	if Main.IsOnBizhawk() then
		local plainFormatter = function(filename)
			-- strip out any auto appended postfixes
			filename = filename:gsub(FileManager.PostFixes.AUTORANDOMIZED, "")
			filename = filename:gsub(FileManager.PostFixes.PREVIOUSATTEMPT, "")
			filename = filename:gsub("%.gba", "")
			filename = filename:gsub(" ", "_")
			filename = filename:gsub("%d", "")
			return filename:lower()
		end
		local loadedRomName = GameSettings.getRomName() or "N/A"
		loadedRomName = plainFormatter(loadedRomName .. FileManager.Extensions.GBA_ROM)
		local autodetectedName = plainFormatter(romname or "")
		if loadedRomName ~= autodetectedName then
			return nil
		end
	end

	-- Return the full file path of the log file, or nil if it can't be found
	return FileManager.getPathIfExists((rompath or "") .. FileManager.Extensions.RANDOMIZER_LOGFILE)
end

--- Prompts user to select a log file to parse
--- @return string|nil
function LogOverlay.getLogFileFromPrompt()
	local suggestedFileName = (GameSettings.getRomName() or "") .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local filterOptions = "Randomizer Log (*.log)|*.log|All files (*.*)|*.*"

	local workingDir = FileManager.dir
	if workingDir ~= "" then
		workingDir = workingDir:sub(1, -2) -- remove trailing slash
	end

	Utils.tempDisableBizhawkSound()
	local filepath = forms.openfile(suggestedFileName, workingDir, filterOptions)
	if filepath == "" then
		filepath = nil
	end
	Utils.tempEnableBizhawkSound()

	return filepath
end

function LogOverlay.parseAndDisplay(logpath)
	-- Check for what log we're trying to display, and if it's already been parsed
	if logpath ~= nil and RandomizerLog.loadedLogPath ~= logpath then
		RandomizerLog.Data = {}
		RandomizerLog.loadedLogPath = logpath
	end

	-- If data has already been loaded and parsed, use that first, otherwise try parsing the provided log file
	if RandomizerLog.Data.Settings ~= nil then
		LogOverlay.isDisplayed = true
	else
		LogOverlay.isDisplayed = RandomizerLog.parseLog(logpath)
	end

	if LogOverlay.isDisplayed then
		LogOverlay.buildAllTabs()
		LogOverlay.TabHistory = {}
		LogOverlay.Windower:changeTab(LogOverlay.Tabs.POKEMON)
		-- If the player has a Pokemon, show it on the side-screen
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		if PokemonData.isValid(leadPokemon.pokemonID) then
			LogOverlay.Windower:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, leadPokemon.pokemonID)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, leadPokemon.pokemonID)
		end
	end

	return LogOverlay.isDisplayed
end

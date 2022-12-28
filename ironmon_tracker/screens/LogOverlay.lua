LogOverlay = {
	Labels = {
		header = "Log Viewer",
		bstStatBox = "Base Stats",
		bstTotalFormat = "Total: %s",
		gymTMIndicator = "(Gym)",
		tabFormat = "%s",
		pageFormat = "Page %s/%s" -- e.g. Page 1/3
	},
	Tabs = {
		POKEMON = Constants.Words.POKEMON,
		POKEMON_ZOOM = Constants.Words.POKEMON .. " Zoom",
		POKEMON_ZOOM_LEVELMOVES = "Levelup Moves", -- non-primary tab
		POKEMON_ZOOM_TMMOVES = "TM Moves", -- non-primary tab
		TRAINER = "Trainers",
		TRAINER_ZOOM = "Trainer Zoom",
		TMS = "TMs",
		MISC = "Misc.",
		GO_BACK = "Back",
	},
	margin = 2,
	tabHeight = 12,
	currentTab = nil,
	currentTabInfoId = nil,
	isDisplayed = false,
}

LogOverlay.Pagination = {
	currentPage = 0,
	totalPages = 0,
	filterGrid = "#",
	getPageText = function(self)
		if self.totalPages < 1 then return "Page" end
		return string.format(LogOverlay.Labels.pageFormat, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
	changeTab = function(self, newTab, pageNum, totalPages, tabInfoId)
		local prevTab = {
			tab = LogOverlay.currentTab,
			infoId = LogOverlay.currentTabInfoId,
			page = self.currentPage,
			totalPages = self.totalPages,
		}

		LogOverlay.currentTab = newTab
		LogOverlay.currentTabInfoId = tabInfoId or LogOverlay.currentTabInfoId
		self.currentPage = pageNum or self.currentPage or 1
		self.totalPages = totalPages or self.totalPages or 1

		if newTab == LogOverlay.Tabs.POKEMON or newTab == LogOverlay.Tabs.TRAINER or newTab == LogOverlay.Tabs.TMS or newTab == LogOverlay.Tabs.MISC then
			LogOverlay.TabHistory = {}
		elseif newTab == LogOverlay.Tabs.POKEMON_ZOOM then
			LogOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(tabInfoId)
			LogOverlay.buildPokemonTempButtons(LogOverlay.currentTabData)
			if prevTab.tab ~= LogOverlay.Tabs.POKEMON_ZOOM then
				table.insert(LogOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogOverlay.Tabs.TRAINER_ZOOM then
			LogOverlay.currentTabData = DataHelper.buildTrainerLogDisplay(tabInfoId)
			LogOverlay.buildTrainerTempButtons(LogOverlay.currentTabData)
			if prevTab.tab ~= LogOverlay.Tabs.TRAINER_ZOOM then
				table.insert(LogOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogOverlay.Tabs.GO_BACK then
			prevTab = table.remove(LogOverlay.TabHistory)
			if prevTab ~= nil then
				self:changeTab(prevTab.tab, prevTab.page, prevTab.totalPages, prevTab.infoId)
			else
				LogOverlay.realignDefaultPokemonGrid()
				self:changeTab(LogOverlay.Tabs.POKEMON)
			end
			return
		else -- Currently unused
			table.insert(LogOverlay.TabHistory, prevTab)
		end
		LogOverlay.refreshTabBar()
		LogOverlay.refreshInnerButtons()
	end,
}

LogOverlay.PokemonMovesPagination = {
	currentPage = 0,
	currentTab = 0,
	totalPages = 0,
	movesPerPage = 8,
	totalLearnedMoves = 0, -- set each time new pokemon zoom is built
	totalTMMoves = 0, -- set each time new pokemon zoom is built
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
	changeTab = function(self, newTab)
		self.currentTab = newTab
		self.currentPage = 1

		if newTab == LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES then
			self.totalPages = math.ceil(self.totalLearnedMoves / self.movesPerPage)
		elseif newTab == LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES then
			self.totalPages = math.ceil(self.totalTMMoves / self.movesPerPage)
		else -- Currently unused
			self.totalPages = 1
		end
		LogOverlay.refreshInnerButtons()
	end,
}

LogOverlay.TabBarButtons = {
	PokemonTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogOverlay.Tabs.POKEMON,
		textColor = "Header text",
		tab = LogOverlay.Tabs.POKEMON,
		box = { LogOverlay.margin + 1, 0, 41, 11, },
		updateText = function(self)
			if LogOverlay.currentTab == self.tab then
				self.text = string.format(LogOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
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
				LogOverlay.realignDefaultPokemonGrid()
				LogOverlay.Pagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	},
	TrainersTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogOverlay.Tabs.TRAINER,
		textColor = "Header text",
		tab = LogOverlay.Tabs.TRAINER,
		box = { LogOverlay.margin + 45, 0, 34, 11, },
		updateText = function(self)
			if LogOverlay.currentTab == self.tab then
				self.text = string.format(LogOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
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
				LogOverlay.Pagination:changeTab(self.tab, 1, 1)
				Program.redraw(true)
			end
		end,
	},
	TMsTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogOverlay.Tabs.TMS,
		textColor = "Header text",
		tab = LogOverlay.Tabs.TMS,
		box = { LogOverlay.margin + 45 + 38, 0, 18, 11, },
		updateText = function(self)
			if LogOverlay.currentTab == self.tab then
				self.text = string.format(LogOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
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
				LogOverlay.Pagination:changeTab(self.tab, 1, 1)
				Program.redraw(true)
			end
		end,
	},
	MiscTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogOverlay.Tabs.MISC,
		textColor = "Header text",
		tab = LogOverlay.Tabs.MISC,
		box = { LogOverlay.margin + 45 + 38 + 22, 0, 22, 11, },
		updateText = function(self)
			if LogOverlay.currentTab == self.tab then
				self.text = string.format(LogOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
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
				LogOverlay.Pagination:changeTab(self.tab, 1, 1)
				Program.redraw(true)
			end
		end,
	},
	XIcon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CROSS,
		textColor = Theme.headerHighlightKey,
		box = { LogOverlay.margin + 226, 0, 11, 11 },
		updateText = function(self)
			self.textColor = Theme.headerHighlightKey
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.image = Constants.PixelImages.PREVIOUS_BUTTON
				self.box[2] = 1
			else
				self.image = Constants.PixelImages.CROSS
				self.box[2] = 0
			end
		end,
		onClick = function(self)
			if self.image == Constants.PixelImages.CROSS then
				LogOverlay.TabHistory = {}
				LogOverlay.isDisplayed = false
				Program.changeScreenView(Program.Screens.GAMEOVER)
			else -- Constants.PixelImages.PREVIOUS_BUTTON
				LogOverlay.Pagination:changeTab(LogOverlay.Tabs.GO_BACK)
				Program.redraw(true)
			end
		end,
	},
}

LogOverlay.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		textColor = Theme.headerHighlightKey,
		box = { LogOverlay.margin + 151, 0, 50, 10, },
		isVisible = function() return LogOverlay.Pagination.totalPages > 1 end, -- Likely won't use, unsure where to place it
		updateText = function(self)
			self.text = LogOverlay.Pagination:getPageText() or ""
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.textColor = Theme.headerHighlightKey --"Lower box text"
			else
				self.textColor = Theme.headerHighlightKey -- "Default text"
			end
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		textColor = "Upper box border",
		box = { LogOverlay.margin + 3, LogOverlay.tabHeight + 65, 10, 10, },
		isVisible = function() return LogOverlay.Pagination.totalPages > 1 end,
		updateText = function(self)
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.textColor = "Lower box border"
			else
				self.textColor = "Upper box border"
			end
		end,
		onClick = function(self)
			LogOverlay.Pagination:prevPage()
			LogOverlay.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		textColor = "Upper box border",
		box = { Constants.SCREEN.WIDTH - LogOverlay.margin - 13, LogOverlay.tabHeight + 65, 10, 10, },
		isVisible = function() return LogOverlay.Pagination.totalPages > 1 end,
		updateText = function(self)
			if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM or LogOverlay.currentTab == LogOverlay.Tabs.TRAINER_ZOOM then
				self.textColor = "Lower box border"
			else
				self.textColor = "Upper box border"
			end
		end,
		onClick = function(self)
			LogOverlay.Pagination:nextPage()
			LogOverlay.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end,
	},
}

-- Holds temporary buttons that only exist while drilling down on specific log info, e.g. pokemon evo icons
LogOverlay.TemporaryButtons = {}

-- Holds all of the parsed data in nicely formatted buttons for display and interaction
LogOverlay.PagedButtons = {}

-- A stack manage the back-button within tabs, each element is { tab, page, }
LogOverlay.TabHistory = {}

function LogOverlay.initialize()
	LogOverlay.TabHistory = {}
	for _, button in pairs(LogOverlay.TabBarButtons) do
		if button.textColor == nil then
			button.textColor = "Header text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Upper box border", "Main background" }
		end
	end
	for _, button in pairs(LogOverlay.Buttons) do
		if button.textColor == nil then
			button.textColor = "Default text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Upper box border", "Upper box background" }
		end
	end

	LogOverlay.Buttons.CurrentPage:updateText()
end

function LogOverlay.parseAndDisplay(logpath)
	-- Check first if data has already been loaded and parsed
	if RandomizerLog.Data.Settings ~= nil or RandomizerLog.parseLog(logpath) then
		LogOverlay.isDisplayed = true
		local totalPages = LogOverlay.buildPagedButtons()
		LogOverlay.Pagination:changeTab(LogOverlay.Tabs.POKEMON, 1, totalPages)
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		if PokemonData.isValid(leadPokemon.pokemonID) then
			LogOverlay.Pagination:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, leadPokemon.pokemonID)
		end
		Program.redraw(true)
	else
		LogOverlay.isDisplayed = false
	end

	return LogOverlay.isDisplayed
end

-- Builds out paged-buttons that are shown on the log viewer overlay based on the parse data
function LogOverlay.buildPagedButtons()
	LogOverlay.PagedButtons = {}
	LogOverlay.PagedButtons.Pokemon = {}
	LogOverlay.PagedButtons.Trainers = {}
	LogOverlay.PagedButtons.TMs = {}

	-- Build Pokemon buttons
	for id = 1, PokemonData.totalPokemon, 1 do
		if RandomizerLog.Data.Pokemon[id] ~= nil then
			local button = {
				type = Constants.ButtonTypes.POKEMON_ICON,
				pokemonID = id,
				pokemonName = PokemonData.Pokemon[id].name,
				tab = LogOverlay.Tabs.POKEMON,
				isVisible = function(self)
					return LogOverlay.currentTab == self.tab and LogOverlay.Pagination.currentPage == self.pageVisible
				end,
				includeInGrid = function(self)
					return LogOverlay.Pagination.filterGrid == "#" or LogOverlay.Pagination.filterGrid == self.pokemonName:sub(1,1)
				end,
				getIconPath = function(self)
					local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
					return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
				end,
				onClick = function(self)
					LogOverlay.Pagination:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end,
			}
			table.insert(LogOverlay.PagedButtons.Pokemon, button)
		end
	end

	-- After sorting, determine which are visible on which page using grid align
	local startX = LogOverlay.margin + 18
	local startY = LogOverlay.margin + LogOverlay.tabHeight + 9
	local colGap, rowGap = 23, 1
	-- Also change the above variables in LogOverlay.showDefaultPokemonGrid()

	table.sort(LogOverlay.PagedButtons.Pokemon, function(a, b) return a.pokemonID < b.pokemonID end)
	LogOverlay.Pagination.pokemonPerPage, LogOverlay.Pagination.totalPages = LogOverlay.gridAlign(LogOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, colGap, rowGap)
	LogOverlay.Buttons.CurrentPage:updateText()

	local offsetX = 5
	local alphabet = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ?"
	local kernings = { ["#"] = -3, ["I"] = 1, ["M"] = -1, ["X"] = 1, ["?"] = 4, }
	for letter in alphabet:gmatch("(.)") do
		local kerning = kernings[letter] or 0
		local jumpBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = letter,
			textColor = "Default text",
			tab = LogOverlay.Tabs.POKEMON,
			box = { LogOverlay.margin + offsetX + kerning, LogOverlay.tabHeight, 8, 10 },
			isVisible = function(self) return LogOverlay.currentTab == self.tab end,
			onClick = function(self)
				if self.text == "#" then
					LogOverlay.realignDefaultPokemonGrid()
					Program.redraw(true)
				elseif self.text == "?" then
					local pokemonId = Utils.randomPokemonID()
					LogOverlay.Pagination:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, pokemonId)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemonId) -- implied redraw
				else
					LogOverlay.Pagination.filterGrid = self.text
					table.sort(LogOverlay.PagedButtons.Pokemon, function(a, b) return a.pokemonName < b.pokemonName end)
					LogOverlay.Pagination.pokemonPerPage, LogOverlay.Pagination.totalPages = LogOverlay.gridAlign(LogOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, colGap, rowGap)
					local pageToJump = 1
					for _, pokemonBtn in ipairs(LogOverlay.PagedButtons.Pokemon) do
						if self.text == pokemonBtn.pokemonName:sub(1, 1):upper() then
							pageToJump = pokemonBtn.pageVisible or 1
							break
						end
					end
					LogOverlay.Pagination.currentPage = pageToJump
					LogOverlay.Buttons.CurrentPage:updateText()
					Program.redraw(true)
				end
			end,
		}
		table.insert(LogOverlay.Buttons, jumpBtn)
		offsetX = offsetX + 8
	end

	return LogOverlay.Pagination.totalPages
end

function LogOverlay.realignDefaultPokemonGrid()
	local startX = LogOverlay.margin + 18
	local startY = LogOverlay.margin + LogOverlay.tabHeight + 9
	local colGap, rowGap = 23, 1

	LogOverlay.Pagination.filterGrid = "#"
	table.sort(LogOverlay.PagedButtons.Pokemon, function(a, b) return a.pokemonID < b.pokemonID end)
	LogOverlay.Pagination.pokemonPerPage, LogOverlay.Pagination.totalPages = LogOverlay.gridAlign(LogOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, colGap, rowGap)
	LogOverlay.Pagination.currentPage = 1
	LogOverlay.Buttons.CurrentPage:updateText()
end

function LogOverlay.buildPokemonTempButtons(data)
	LogOverlay.TemporaryButtons = {}

	local offsetX, offsetY
	if data.p.abilities[1] == data.p.abilities[2] then
		data.p.abilities[2] = nil
	end

	-- ABILITIES
	offsetY = 0
	for i, abilityId in ipairs(data.p.abilities) do
		local btnText
		if AbilityData.isValid(abilityId) then
			btnText = string.format("%s: %s", i, AbilityData.Abilities[abilityId].name)
		else
			btnText = Constants.BLANKLINE
		end
		local abilityBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = btnText,
			textColor = "Lower box text",
			abilityId = abilityId,
			tab = LogOverlay.Tabs.POKEMON_ZOOM,
			box = { LogOverlay.margin + 1, LogOverlay.tabHeight + offsetY + 13, 60, 11 },
			isVisible = function(self) return LogOverlay.currentTab == self.tab end,
			onClick = function(self)
				if AbilityData.isValid(abilityId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, self.abilityId) -- implied redraw
				end
			end,
		}
		table.insert(LogOverlay.TemporaryButtons, abilityBtn)
		offsetY = offsetY + Constants.SCREEN.LINESPACING
	end

	-- POKEMON ICON
	local viewedPokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		pokemonID = data.p.id,
		tab = LogOverlay.Tabs.POKEMON_ZOOM,
		box = { LogOverlay.margin + 74, LogOverlay.tabHeight, 32, 32 },
		isVisible = function(self) return LogOverlay.currentTab == self.tab end,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
		end,
	}
	table.insert(LogOverlay.TemporaryButtons, viewedPokemonIcon)

	-- POKEMON EVOLUTIONS
	offsetX = 0
	for _, evoInfo in ipairs(data.p.evos) do
		local evoBtn = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			pokemonID = evoInfo.id,
			tab = LogOverlay.Tabs.POKEMON_ZOOM,
			box = { LogOverlay.margin + 124 + offsetX, LogOverlay.tabHeight, 32, 32 },
			isVisible = function(self) return LogOverlay.currentTab == self.tab end,
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
			end,
			onClick = function(self)
				LogOverlay.Pagination:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, self.pokemonID)
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
			end,
		}
		table.insert(LogOverlay.TemporaryButtons, evoBtn)
		offsetX = offsetX + 37
	end

	local hasEvo = #data.p.evos > 0
	local movesColX = LogOverlay.margin + 118
	local movesRowY = LogOverlay.tabHeight + Utils.inlineIf(hasEvo, 42, 0)
	LogOverlay.PokemonMovesPagination.movesPerPage = Utils.inlineIf(hasEvo, 8, 12)

	local levelupMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
		textColor = "Lower box text",
		tab = LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
		box = { movesColX, movesRowY, 60, 11 },
		isVisible = function(self) return LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM end,
		updateText = function(self)
			if LogOverlay.PokemonMovesPagination.currentTab == self.tab then
				self.text = string.format(LogOverlay.Labels.tabFormat, self.tab)
				self.textColor = "Intermediate text"
			else
				self.text = self.tab
				self.textColor = "Lower box text"
			end
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == "Intermediate text" then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogOverlay.PokemonMovesPagination.currentTab ~= self.tab then
				LogOverlay.PokemonMovesPagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	}
	local tmMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
		textColor = "Lower box text",
		tab = LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
		box = { movesColX + 70, movesRowY, 41, 11 },
		isVisible = function(self) return LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM end,
		updateText = function(self)
			if LogOverlay.PokemonMovesPagination.currentTab == self.tab then
				self.text = string.format(LogOverlay.Labels.tabFormat, self.tab)
				self.textColor = "Intermediate text"
			else
				self.text = self.tab
				self.textColor = "Lower box text"
			end
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == "Intermediate text" then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogOverlay.PokemonMovesPagination.currentTab ~= self.tab then
				LogOverlay.PokemonMovesPagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	}
	table.insert(LogOverlay.TemporaryButtons, levelupMovesTab)
	table.insert(LogOverlay.TemporaryButtons, tmMovesTab)

	-- LEARNABLE MOVES
	offsetY = 0
	for i, moveInfo in ipairs(data.p.moves) do
		local moveBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = string.format("%02d   %s", moveInfo.level, moveInfo.name),
			textColor = "Lower box text",
			moveId = moveInfo.id,
			tab = LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
			pageVisible = math.ceil(i / LogOverlay.PokemonMovesPagination.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY + Utils.inlineIf(hasEvo, 0, -2), 80, 11 },
			isVisible = function(self) return LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM and LogOverlay.PokemonMovesPagination.currentTab == self.tab and LogOverlay.PokemonMovesPagination.currentPage == self.pageVisible end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogOverlay.TemporaryButtons, moveBtn)
		if i % LogOverlay.PokemonMovesPagination.movesPerPage == 0 then
			offsetY = 0
		else
			offsetY = offsetY + Constants.SCREEN.LINESPACING
		end
	end

	-- Determine gym TMs for the game, they'll be highlighted
	local gymTMs = {}
	for _, gymTM in pairs(RandomizerLog.GymTMs[GameSettings.game]) do
		gymTMs[gymTM.number] = gymTM.leader
	end

	-- LEARNABLE TMS
	offsetY = 0
	for i, tmInfo in ipairs(data.p.tmmoves) do
		local gymAppend = Utils.inlineIf(gymTMs[tmInfo.tm], " " .. LogOverlay.Labels.gymTMIndicator, "")
		local moveBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = string.format("TM%02d   %s%s", tmInfo.tm, tmInfo.moveName, gymAppend),
			textColor = Utils.inlineIf(gymTMs[tmInfo.tm], "Intermediate text", "Lower box text"),
			moveId = tmInfo.moveId,
			tab = LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
			pageVisible = math.ceil(i / LogOverlay.PokemonMovesPagination.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY + Utils.inlineIf(hasEvo, 0, -2), 80, 11 },
			isVisible = function(self) return LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM and LogOverlay.PokemonMovesPagination.currentTab == self.tab and LogOverlay.PokemonMovesPagination.currentPage == self.pageVisible end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogOverlay.TemporaryButtons, moveBtn)
		if i % LogOverlay.PokemonMovesPagination.movesPerPage == 0 then
			offsetY = 0
		else
			offsetY = offsetY + Constants.SCREEN.LINESPACING
		end
	end

	-- UP/DOWN PAGING ARROWS
	local upArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		textColor = "Lower box border",
		box = { movesColX + 107, movesRowY + 24 + Utils.inlineIf(hasEvo, 0, 10), 10, 10 },
		isVisible = function() return LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM and LogOverlay.PokemonMovesPagination.totalPages > 1 end,
		onClick = function(self)
			LogOverlay.PokemonMovesPagination:prevPage()
			Program.redraw(true)
		end,
	}
	local downArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		textColor = "Lower box border",
		box = { movesColX + 107, movesRowY + 81 + Utils.inlineIf(hasEvo, 0, 30), 10, 10 },
		isVisible = function() return LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM and LogOverlay.PokemonMovesPagination.totalPages > 1 end,
		onClick = function(self)
			LogOverlay.PokemonMovesPagination:nextPage()
			Program.redraw(true)
		end,
	}
	table.insert(LogOverlay.TemporaryButtons, upArrow)
	table.insert(LogOverlay.TemporaryButtons, downArrow)

	LogOverlay.PokemonMovesPagination.totalLearnedMoves = #data.p.moves
	LogOverlay.PokemonMovesPagination.totalTMMoves = #data.p.tmmoves
	LogOverlay.PokemonMovesPagination:changeTab(LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES)
end

-- Organizes a list of buttons in a row by column fashion based on (x,y,w,h) and what page they should display on.
-- Returns # items per page, total pages
function LogOverlay.gridAlign(buttonList, startX, startY, width, height, colSpacer, rowSpacer)
	local offsetX, offsetY = 0, 0
	local maxWidth = Constants.SCREEN.WIDTH - LogOverlay.margin
	local maxHeight = Constants.SCREEN.HEIGHT - LogOverlay.margin

	local itemCount = 0
	local itemsPerPage = nil
	for _, button in ipairs(buttonList) do
		if button:includeInGrid() then
			itemCount = itemCount + 1
			local x = startX + offsetX
			local y = startY + offsetY -- - Options.IconSetMap[Options["Pokemon icon set"]].yOffset
			button.clickableArea = { x, y + 4, width, height - 4 }
			button.box = { x, y, width, height }
			if itemsPerPage == nil then
				button.pageVisible = 1
			else
				button.pageVisible = math.ceil(itemCount / itemsPerPage)
			end

			offsetX = offsetX + width + colSpacer
			if (startX + offsetX + width) > maxWidth then -- check to start a new row
				offsetX = 0
				offsetY = offsetY + height + rowSpacer
			end
			if (startY + offsetY + height) > maxHeight then -- check to start a new page
				offsetX = 0
				offsetY = 0
				if itemsPerPage == nil then
					itemsPerPage = itemCount
				end
			end
		else
			button.pageVisible = -1
		end
	end

	-- Return number of items per page, total pages
	if itemsPerPage == nil then
		return 1, 1
	else
		return itemsPerPage, math.ceil(itemCount / itemsPerPage)
	end
end

-- For showing what's highlighted and updating the page #
function LogOverlay.refreshTabBar()
	for _, button in pairs(LogOverlay.TabBarButtons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

function LogOverlay.refreshInnerButtons()
	for _, button in pairs(LogOverlay.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
	for _, button in pairs(LogOverlay.TemporaryButtons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

-- DRAWING FUNCTIONS
function LogOverlay.drawScreen()
	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)

	local box = {
		x = LogOverlay.margin,
		y = LogOverlay.tabHeight,
		width = Constants.SCREEN.WIDTH - (LogOverlay.margin * 2),
		height = Constants.SCREEN.HEIGHT - LogOverlay.tabHeight - LogOverlay.margin - 1,
	}

	local borderColor, shadowcolor
	if LogOverlay.currentTab == LogOverlay.Tabs.POKEMON then
		borderColor, shadowcolor = LogOverlay.drawPokemonTab(box.x, box.y, box.width, box.height)
		-- gui.drawLine(box.x + 2, box.y - 2, box.x + 40, box.y - 2, Theme.COLORS[Theme.headerHighlightKey])
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TRAINER then
		borderColor, shadowcolor = LogOverlay.drawTrainersTab(box.x, box.y, box.width, box.height)
		-- gui.drawLine(box.x + 48, box.y - 2, box.x + 78, box.y - 2, Theme.COLORS[Theme.headerHighlightKey])
	elseif LogOverlay.currentTab == LogOverlay.Tabs.TMS then
		borderColor, shadowcolor = LogOverlay.drawTMsTab(box.x, box.y, box.width, box.height)
		-- gui.drawLine(box.x + 86, box.y - 2, box.x + 100, box.y - 2, Theme.COLORS[Theme.headerHighlightKey])
	elseif LogOverlay.currentTab == LogOverlay.Tabs.MISC then
		borderColor, shadowcolor = LogOverlay.drawMiscTab(box.x, box.y, box.width, box.height)
		-- gui.drawLine(box.x + 107, box.y - 2, box.x + 126, box.y - 2, Theme.COLORS[Theme.headerHighlightKey])
	elseif LogOverlay.currentTab == LogOverlay.Tabs.POKEMON_ZOOM then
		borderColor, shadowcolor = LogOverlay.drawPokemonZoomed(box.x, box.y, box.width, box.height)
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
		-- The page display currently lives in the header for the Pokemon tab
		if button == LogOverlay.Buttons.CurrentPage and LogOverlay.currentTab == LogOverlay.Tabs.POKEMON then
			Drawing.drawButton(button, bgColor)
		else
			Drawing.drawButton(button, shadowcolor)
		end
	end
end

-- Unsure if this will actually be needed, likely some of them
function LogOverlay.drawPokemonTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	-- VISIBLE POKEMON ICONS
	for _, buttonSet in pairs(LogOverlay.PagedButtons) do
		for _, button in pairs(buttonSet) do
			-- First draw the Pokemon Icon
			Drawing.drawButton(button, shadowcolor)
			-- Then draw the text on top of it, with a background
			if button:isVisible() then
				local pokemonName = PokemonData.Pokemon[button.pokemonID].name
				gui.drawRectangle(button.box[1], button.box[2], 32, 10, fillColor, fillColor) -- cut-off top of icon
				Drawing.drawText(button.box[1] - 5, button.box[2], pokemonName, textColor, shadowcolor)
			end
		end
	end

	return borderColor, shadowcolor
end

function LogOverlay.drawTrainersTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return borderColor, shadowcolor
end

function LogOverlay.drawTMsTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return borderColor, shadowcolor
end

function LogOverlay.drawMiscTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return borderColor, shadowcolor
end

function LogOverlay.drawPokemonZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	local pokemonID = LogOverlay.currentTabInfoId
	local data = LogOverlay.currentTabData
	if not PokemonData.isValid(pokemonID) then
		return shadowcolor
	elseif data == nil then -- ideally this is done only once on tabchange
		LogOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(pokemonID)
		data = LogOverlay.currentTabData
	end

	-- POKEMON NAME
	Drawing.drawText(x + 3, y + 2, data.p.name:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- POKEMON TYPES
	-- Drawing.drawTypeIcon(data.p.types[1], x + 5, y + 13)
	-- if data.p.types[2] ~= data.p.types[1] then
	-- 	Drawing.drawTypeIcon(data.p.types[2], x + 5, y + 25)
	-- end

	-- EVOLUTION ARROW
	if #data.p.evos > 0 then
		Drawing.drawImageAsPixels(Constants.PixelImages.NEXT_BUTTON, x + 109, y + 14, { borderColor }, shadowcolor)
	end

	local statBox = {
		x = x + 6,
		y = y + 53,
		width = 103,
		height = 68,
		barW = 8,
		labelW = 17,
	}
	-- Draw header for stat box
	local bstTotal = string.format(LogOverlay.Labels.bstTotalFormat, data.p.bst)
	Drawing.drawText(statBox.x, statBox.y - 11, LogOverlay.Labels.bstStatBox, textColor, shadowcolor)
	Drawing.drawText(statBox.x + statBox.width - 39, statBox.y - 11, bstTotal, textColor, shadowcolor)
	-- Draw stat box
	gui.drawRectangle(statBox.x, statBox.y, statBox.width, statBox.height, borderColor, fillColor)
	local quarterMark = statBox.height/4
	gui.drawLine(statBox.x - 2, statBox.y, statBox.x, statBox.y, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y, statBox.x + statBox.width + 2, statBox.y, borderColor)
	gui.drawLine(statBox.x - 1, statBox.y + quarterMark * 1, statBox.x, statBox.y + quarterMark * 1, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + quarterMark * 1, statBox.x + statBox.width + 1, statBox.y + quarterMark * 1, borderColor)
	gui.drawLine(statBox.x - 2, statBox.y + quarterMark * 2, statBox.x, statBox.y + quarterMark * 2, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + quarterMark * 2, statBox.x + statBox.width + 2, statBox.y + quarterMark * 2, borderColor)
	gui.drawLine(statBox.x - 1, statBox.y + quarterMark * 3, statBox.x, statBox.y + quarterMark * 3, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + quarterMark * 3, statBox.x + statBox.width + 1, statBox.y + quarterMark * 3, borderColor)
	gui.drawLine(statBox.x - 2, statBox.y + statBox.height, statBox.x, statBox.y + statBox.height, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + statBox.height, statBox.x + statBox.width + 2, statBox.y + statBox.height, borderColor)

	local statX = statBox.x + 1
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		-- Draw the vertical bar
		local barH = math.floor(data.p[statKey] / 255 * (statBox.height - 2) + 0.5)
		local barY = statBox.y + statBox.height - barH - 1 -- -1/-2 for box pixel border margin
		local barColor
		if data.p[statKey] >= 180 then -- top ~70%
			barColor = Theme.COLORS["Positive text"]
		elseif data.p[statKey] <= 40 then -- bottom ~15%
			barColor = Theme.COLORS["Negative text"]
		else
			barColor = textColor
		end
		gui.drawRectangle(statX + (statBox.labelW - statBox.barW) / 2, barY, statBox.barW, barH, barColor, barColor)

		-- Draw the bar's label
		local statLabelOffsetX = (3 - string.len(statKey)) * 2
		local statValueOffsetX = (3 - string.len(tostring(data.p[statKey]))) * 2
		Drawing.drawText(statX + statLabelOffsetX, statBox.y + statBox.height + 1, Utils.firstToUpper(statKey), textColor, shadowcolor)
		Drawing.drawText(statX + statValueOffsetX, statBox.y + statBox.height + 11, data.p[statKey], barColor, shadowcolor)
		statX = statX + statBox.labelW
	end

	-- data.p.helditems -- unused

	for _, button in pairs(LogOverlay.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	return borderColor, shadowcolor
end

function LogOverlay.drawTrainerZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return borderColor, shadowcolor
end

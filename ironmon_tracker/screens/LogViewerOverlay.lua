LogViewerOverlay = {
	Labels = {
		header = "Log Viewer",
		basestatFormat = "Base Stats       Total: %s",
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

LogViewerOverlay.Pagination = {
	currentPage = 0,
	totalPages = 0,
	pokemonPerPage = 28,
	trainersPerPage = 32,
	tmsPerPage = 25,
	getPageText = function(self)
		if self.totalPages < 1 then return "Page" end
		return string.format(LogViewerOverlay.Labels.pageFormat, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
	changeTab = function(self, newTab, pageNum, tabInfoId)
		local prevTab = {
			tab = LogViewerOverlay.currentTab,
			page = self.currentPage,
			infoId = LogViewerOverlay.currentTabInfoId,
		}

		LogViewerOverlay.currentTab = newTab
		self.currentPage = pageNum or 1
		LogViewerOverlay.currentTabInfoId = tabInfoId

		if newTab == LogViewerOverlay.Tabs.POKEMON then
			self.totalPages = math.ceil(#LogViewerOverlay.PagedButtons.Pokemon / self.pokemonPerPage)
			LogViewerOverlay.TabHistory = {}
		elseif newTab == LogViewerOverlay.Tabs.TRAINER then
			self.totalPages = math.ceil(#LogViewerOverlay.PagedButtons.Trainers / self.trainersPerPage)
			LogViewerOverlay.TabHistory = {}
		elseif newTab == LogViewerOverlay.Tabs.TMS then
			self.totalPages = math.ceil(#LogViewerOverlay.PagedButtons.TMs / self.tmsPerPage)
			LogViewerOverlay.TabHistory = {}
		elseif newTab == LogViewerOverlay.Tabs.POKEMON_ZOOM then
			self.totalPages = 1
			LogViewerOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(tabInfoId)
			LogViewerOverlay.buildPokemonTempButtons(LogViewerOverlay.currentTabData)
			if prevTab.tab ~= LogViewerOverlay.Tabs.POKEMON_ZOOM then
				table.insert(LogViewerOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogViewerOverlay.Tabs.TRAINER_ZOOM then
			self.totalPages = 1
			LogViewerOverlay.currentTabData = DataHelper.buildTrainerLogDisplay(tabInfoId)
			LogViewerOverlay.buildTrainerTempButtons(LogViewerOverlay.currentTabData)
			if prevTab.tab ~= LogViewerOverlay.Tabs.TRAINER_ZOOM then
				table.insert(LogViewerOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogViewerOverlay.Tabs.GO_BACK then
			prevTab = table.remove(LogViewerOverlay.TabHistory)
			self:changeTab(prevTab.tab, prevTab.page, prevTab.infoId)
			return
		else -- Currently unused
			self.totalPages = 1
			table.insert(LogViewerOverlay.TabHistory, prevTab)
		end
		LogViewerOverlay.refreshTabBar()
	end,
}

LogViewerOverlay.PokemonMovesPagination = {
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

		if newTab == LogViewerOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES then
			self.totalPages = math.ceil(self.totalLearnedMoves / self.movesPerPage)
		elseif newTab == LogViewerOverlay.Tabs.POKEMON_ZOOM_TMMOVES then
			self.totalPages = math.ceil(self.totalTMMoves / self.movesPerPage)
		else -- Currently unused
			self.totalPages = 1
		end
		LogViewerOverlay.refreshTempButtons()
	end,
}

LogViewerOverlay.TabBarButtons = {
	PokemonTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogViewerOverlay.Tabs.POKEMON,
		textColor = "Header text",
		tab = LogViewerOverlay.Tabs.POKEMON,
		box = { LogViewerOverlay.margin, 0, 45, 11, },
		updateText = function(self)
			if LogViewerOverlay.currentTab == self.tab then
				self.text = string.format(LogViewerOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
		end,
		onClick = function(self)
			if LogViewerOverlay.currentTab ~= self.tab then
				LogViewerOverlay.Pagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	},
	TrainersTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogViewerOverlay.Tabs.TRAINER,
		textColor = "Header text",
		tab = LogViewerOverlay.Tabs.TRAINER,
		box = { LogViewerOverlay.margin + 45, 0, 38, 11, },
		updateText = function(self)
			if LogViewerOverlay.currentTab == self.tab then
				self.text = string.format(LogViewerOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
		end,
		onClick = function(self)
			if LogViewerOverlay.currentTab ~= self.tab then
				LogViewerOverlay.Pagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	},
	TMsTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogViewerOverlay.Tabs.TMS,
		textColor = "Header text",
		tab = LogViewerOverlay.Tabs.TMS,
		box = { LogViewerOverlay.margin + 45 + 38, 0, 22, 11, },
		updateText = function(self)
			if LogViewerOverlay.currentTab == self.tab then
				self.text = string.format(LogViewerOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
		end,
		onClick = function(self)
			if LogViewerOverlay.currentTab ~= self.tab then
				LogViewerOverlay.Pagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	},
	MiscTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogViewerOverlay.Tabs.MISC,
		textColor = "Header text",
		tab = LogViewerOverlay.Tabs.MISC,
		box = { LogViewerOverlay.margin + 45 + 38 + 22, 0, 28, 11, },
		updateText = function(self)
			if LogViewerOverlay.currentTab == self.tab then
				self.text = string.format(LogViewerOverlay.Labels.tabFormat, self.tab)
				self.textColor = Theme.headerHighlightKey
			else
				self.text = self.tab
				self.textColor = "Header text"
			end
		end,
		onClick = function(self)
			if LogViewerOverlay.currentTab ~= self.tab then
				LogViewerOverlay.Pagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		textColor = "Header text",
		box = { LogViewerOverlay.margin + 151, 0, 50, 10, },
		isVisible = function() return LogViewerOverlay.Pagination.totalPages > 1 end,
		updateText = function(self)
			self.text = LogViewerOverlay.Pagination:getPageText() or ""
			local maxWidthTxt = string.format(LogViewerOverlay.Labels.pageFormat, LogViewerOverlay.Pagination.totalPages, LogViewerOverlay.Pagination.totalPages)
			LogViewerOverlay.TabBarButtons.PrevPage.box[1] = self.box[1] - 12
			LogViewerOverlay.TabBarButtons.NextPage.box[1] = self.box[1] + maxWidthTxt:len() * 4 + 12
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		textColor = "Header text",
		box = { LogViewerOverlay.margin + 84, 1, 10, 10, },
		isVisible = function() return LogViewerOverlay.Pagination.totalPages > 1 end,
		onClick = function(self)
			LogViewerOverlay.Pagination:prevPage()
			LogViewerOverlay.TabBarButtons.CurrentPage:updateText()
			Program.redraw(true)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		textColor = "Header text",
		box = { LogViewerOverlay.margin + 133, 1, 10, 10, },
		isVisible = function() return LogViewerOverlay.Pagination.totalPages > 1 end,
		onClick = function(self)
			LogViewerOverlay.Pagination:nextPage()
			LogViewerOverlay.TabBarButtons.CurrentPage:updateText()
			Program.redraw(true)
		end,
	},
	XIcon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CROSS,
		textColor = "Negative text",
		box = { LogViewerOverlay.margin + 226, 0, 11, 11 },
		updateText = function(self)
			if LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM or LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.TRAINER_ZOOM then
				self.image = Constants.PixelImages.PREVIOUS_BUTTON
				self.box[2] = 1
			else
				self.image = Constants.PixelImages.CROSS
				self.box[2] = 0
			end
		end,
		onClick = function(self)
			local prevTab = table.remove(LogViewerOverlay.TabHistory)
			if prevTab ~= nil then
				LogViewerOverlay.Pagination:changeTab(prevTab.tab, prevTab.page, prevTab.infoId)
				Program.redraw(true)
			elseif self.image == Constants.PixelImages.PREVIOUS_BUTTON then
				LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON)
				Program.redraw(true)
			else
				LogViewerOverlay.TabHistory = {}
				LogViewerOverlay.isDisplayed = false
				Program.changeScreenView(Program.Screens.GAMEOVER)
			end
		end,
	},
}

LogViewerOverlay.Buttons = {

}

-- Holds temporary buttons that only exist while drilling down on specific log info, e.g. pokemon evo icons
LogViewerOverlay.TemporaryButtons = {}

-- Holds all of the parsed data in nicely formatted buttons for display and interaction
LogViewerOverlay.PagedButtons = {}

-- A stack manage the back-button within tabs, each element is { tab, page, }
LogViewerOverlay.TabHistory = {}

function LogViewerOverlay.initialize()
	LogViewerOverlay.TabHistory = {}
	for _, button in pairs(LogViewerOverlay.TabBarButtons) do
		if button.textColor == nil then
			button.textColor = "Header text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Upper box border", "Main background" }
		end
	end
	for _, button in pairs(LogViewerOverlay.Buttons) do
		if button.textColor == nil then
			button.textColor = "Default text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Upper box border", "Upper box background" }
		end
	end

	LogViewerOverlay.TabBarButtons.CurrentPage:updateText()
end

function LogViewerOverlay.parseAndDisplay(logpath)
	-- Check first if data has already been loaded and parsed
	if RandomizerLog.Data.Settings ~= nil or RandomizerLog.parseLog(logpath) then
		LogViewerOverlay.isDisplayed = true
		LogViewerOverlay.buildPagedButtons()
		LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON)
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		if PokemonData.isValid(leadPokemon.pokemonID) then
			LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON_ZOOM, 1, leadPokemon.pokemonID)
		end
		Program.redraw(true)
	else
		LogViewerOverlay.isDisplayed = false
	end

	return LogViewerOverlay.isDisplayed
end

-- Builds out paged-buttons that are shown on the log viewer overlay based on the parse data
function LogViewerOverlay.buildPagedButtons()
	LogViewerOverlay.PagedButtons = {}
	LogViewerOverlay.PagedButtons.Pokemon = {}
	LogViewerOverlay.PagedButtons.Trainers = {}
	LogViewerOverlay.PagedButtons.TMs = {}

	-- Build Pokemon buttons
	for id = 1, PokemonData.totalPokemon, 1 do
		if RandomizerLog.Data.Pokemon[id] ~= nil then
			local button = {
				type = Constants.ButtonTypes.POKEMON_ICON,
				pokemonID = id,
				pokemonName = PokemonData.Pokemon[id].name,
				tab = LogViewerOverlay.Tabs.POKEMON,
				isVisible = function(self)
					return LogViewerOverlay.currentTab == self.tab and LogViewerOverlay.Pagination.currentPage == self.pageVisible
				end,
				getIconPath = function(self)
					local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
					return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
				end,
				onClick = function(self)
					LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON_ZOOM, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end,
			}
			table.insert(LogViewerOverlay.PagedButtons.Pokemon, button)
		end
	end

	-- After sorting, determine which are visible on which page using grid align
	local startX = LogViewerOverlay.margin + 4
	local startY = LogViewerOverlay.margin + LogViewerOverlay.tabHeight + 7

	table.sort(LogViewerOverlay.PagedButtons.Pokemon, function(a, b) return a.pokemonID < b.pokemonID end)
	LogViewerOverlay.gridAlign(LogViewerOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, 1, LogViewerOverlay.Pagination.pokemonPerPage)

	local offsetX = 5
	local alphabet = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ?"
	for letter in alphabet:gmatch("(.)") do
		local jumpBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = letter,
			textColor = "Default text",
			tab = LogViewerOverlay.Tabs.POKEMON,
			box = { LogViewerOverlay.margin + offsetX, LogViewerOverlay.tabHeight + 2, 8, 10 },
			isVisible = function(self) return LogViewerOverlay.currentTab == self.tab end,
			onClick = function(self)
				if self.text == "#" then
					table.sort(LogViewerOverlay.PagedButtons.Pokemon, function(a, b) return a.pokemonID < b.pokemonID end)
					LogViewerOverlay.gridAlign(LogViewerOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, 1, LogViewerOverlay.Pagination.pokemonPerPage)
					LogViewerOverlay.Pagination.currentPage = 1
					LogViewerOverlay.TabBarButtons.CurrentPage:updateText()
					Program.redraw(true)
				elseif self.text == "?" then
					local pokemonId = Utils.randomPokemonID()
					LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON_ZOOM, 1, pokemonId)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemonId) -- implied redraw
				else
					table.sort(LogViewerOverlay.PagedButtons.Pokemon, function(a, b) return a.pokemonName < b.pokemonName end)
					LogViewerOverlay.gridAlign(LogViewerOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, 1, LogViewerOverlay.Pagination.pokemonPerPage)
					local pageToJump = 1
					for _, pokemonBtn in ipairs(LogViewerOverlay.PagedButtons.Pokemon) do
						if self.text == pokemonBtn.pokemonName:sub(1, 1):upper() then
							pageToJump = pokemonBtn.pageVisible or 1
							break
						end
					end
					LogViewerOverlay.Pagination.currentPage = pageToJump
					LogViewerOverlay.TabBarButtons.CurrentPage:updateText()
					Program.redraw(true)
				end
			end,
		}
		table.insert(LogViewerOverlay.Buttons, jumpBtn)
		offsetX = offsetX + 8
	end
end

function LogViewerOverlay.buildPokemonTempButtons(data)
	LogViewerOverlay.TemporaryButtons = {}
	-- width ~ 235
	-- height ~ 145

	local offsetX, offsetY
	if data.p.abilities[1] == data.p.abilities[2] then
		data.p.abilities[2] = nil
	end

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
			tab = LogViewerOverlay.Tabs.POKEMON_ZOOM,
			box = { LogViewerOverlay.margin + 1, LogViewerOverlay.tabHeight + offsetY + 13, 60, 11 },
			isVisible = function(self) return LogViewerOverlay.currentTab == self.tab end,
			onClick = function(self)
				if AbilityData.isValid(abilityId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, self.abilityId) -- implied redraw
				end
			end,
		}
		table.insert(LogViewerOverlay.TemporaryButtons, abilityBtn)
		offsetY = offsetY + Constants.SCREEN.LINESPACING
	end

	local viewedPokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		pokemonID = data.p.id,
		tab = LogViewerOverlay.Tabs.POKEMON_ZOOM,
		box = { LogViewerOverlay.margin + 70, LogViewerOverlay.tabHeight, 32, 32 },
		isVisible = function(self) return LogViewerOverlay.currentTab == self.tab end,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
		end,
	}
	table.insert(LogViewerOverlay.TemporaryButtons, viewedPokemonIcon)

	offsetX = 0
	for _, evoInfo in ipairs(data.p.evos) do
		local evoBtn = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			pokemonID = evoInfo.id,
			tab = LogViewerOverlay.Tabs.POKEMON_ZOOM,
			box = { LogViewerOverlay.margin + 120 + offsetX, LogViewerOverlay.tabHeight, 32, 32 },
			isVisible = function(self) return LogViewerOverlay.currentTab == self.tab end,
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
			end,
			onClick = function(self)
				LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON_ZOOM, 1, self.pokemonID)
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
			end,
		}
		table.insert(LogViewerOverlay.TemporaryButtons, evoBtn)
		offsetX = offsetX + 38
	end

	local movesColX = LogViewerOverlay.margin + 118
	local movesRowY = LogViewerOverlay.tabHeight + 42
	local levelupMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogViewerOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
		textColor = "Lower box text",
		tab = LogViewerOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
		box = { movesColX, movesRowY, 60, 11 },
		isVisible = function(self) return LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM end,
		updateText = function(self)
			if LogViewerOverlay.PokemonMovesPagination.currentTab == self.tab then
				self.text = string.format(LogViewerOverlay.Labels.tabFormat, self.tab)
				self.textColor = "Intermediate text"
			else
				self.text = self.tab
				self.textColor = "Lower box text"
			end
		end,
		onClick = function(self)
			if LogViewerOverlay.PokemonMovesPagination.currentTab ~= self.tab then
				LogViewerOverlay.PokemonMovesPagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	}
	local tmMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = LogViewerOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
		textColor = "Lower box text",
		tab = LogViewerOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
		box = { movesColX + 70, movesRowY, 60, 11 },
		isVisible = function(self) return LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM end,
		updateText = function(self)
			if LogViewerOverlay.PokemonMovesPagination.currentTab == self.tab then
				self.text = string.format(LogViewerOverlay.Labels.tabFormat, self.tab)
				self.textColor = "Intermediate text"
			else
				self.text = self.tab
				self.textColor = "Lower box text"
			end
		end,
		onClick = function(self)
			if LogViewerOverlay.PokemonMovesPagination.currentTab ~= self.tab then
				LogViewerOverlay.PokemonMovesPagination:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	}
	table.insert(LogViewerOverlay.TemporaryButtons, levelupMovesTab)
	table.insert(LogViewerOverlay.TemporaryButtons, tmMovesTab)

	-- LEARNABLE MOVES
	offsetY = 0
	for i, moveInfo in ipairs(data.p.moves) do
		local moveBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = string.format("%02d   %s", moveInfo.level, moveInfo.name),
			textColor = "Lower box text",
			moveId = moveInfo.id,
			tab = LogViewerOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
			pageVisible = math.ceil(i / LogViewerOverlay.PokemonMovesPagination.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY, 80, 11 },
			isVisible = function(self) return LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM and LogViewerOverlay.PokemonMovesPagination.currentTab == self.tab and LogViewerOverlay.PokemonMovesPagination.currentPage == self.pageVisible end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogViewerOverlay.TemporaryButtons, moveBtn)
		if i % LogViewerOverlay.PokemonMovesPagination.movesPerPage == 0 then
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
		local gymAppend = Utils.inlineIf(gymTMs[tmInfo.tm], " " .. LogViewerOverlay.Labels.gymTMIndicator, "")
		local moveBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			text = string.format("TM%02d   %s%s", tmInfo.tm, tmInfo.moveName, gymAppend),
			textColor = Utils.inlineIf(gymTMs[tmInfo.tm], "Intermediate text", "Lower box text"),
			moveId = tmInfo.moveId,
			tab = LogViewerOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
			pageVisible = math.ceil(i / LogViewerOverlay.PokemonMovesPagination.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY, 80, 11 },
			isVisible = function(self) return LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM and LogViewerOverlay.PokemonMovesPagination.currentTab == self.tab and LogViewerOverlay.PokemonMovesPagination.currentPage == self.pageVisible end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogViewerOverlay.TemporaryButtons, moveBtn)
		if i % LogViewerOverlay.PokemonMovesPagination.movesPerPage == 0 then
			offsetY = 0
		else
			offsetY = offsetY + Constants.SCREEN.LINESPACING
		end
	end

	-- UP/DOWN PAGING ARROWS
	local upArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		textColor = "Lower box text",
		box = { movesColX + 105, movesRowY + 33, 10, 10 },
		isVisible = function() return LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM and LogViewerOverlay.PokemonMovesPagination.totalPages > 1 end,
		onClick = function(self)
			LogViewerOverlay.PokemonMovesPagination:prevPage()
			Program.redraw(true)
		end,
	}
	local downArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		textColor = "Lower box text",
		box = { movesColX + 105, movesRowY + 70, 10, 10 },
		isVisible = function() return LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM and LogViewerOverlay.PokemonMovesPagination.totalPages > 1 end,
		onClick = function(self)
			LogViewerOverlay.PokemonMovesPagination:nextPage()
			Program.redraw(true)
		end,
	}
	table.insert(LogViewerOverlay.TemporaryButtons, upArrow)
	table.insert(LogViewerOverlay.TemporaryButtons, downArrow)

	LogViewerOverlay.PokemonMovesPagination.totalLearnedMoves = #data.p.moves
	LogViewerOverlay.PokemonMovesPagination.totalTMMoves = #data.p.tmmoves
	LogViewerOverlay.PokemonMovesPagination:changeTab(LogViewerOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES)
end

-- Organizes a list of buttons in a row by column fashion based on (x,y,w,h) and what page they should display on
function LogViewerOverlay.gridAlign(buttonList, startX, startY, width, height, spacer, itemsPerPage)
	local offsetX = 0
	local offsetY = 0
	for i, button in ipairs(buttonList) do
		local x = startX + offsetX
		local y = startY + offsetY -- - Options.IconSetMap[Options["Pokemon icon set"]].yOffset
		button.clickableArea = { x, y + 4, width, height - 4 }
		button.box = { x, y, width, height }
		button.pageVisible = math.ceil(i / itemsPerPage)

		offsetX = offsetX + width + spacer
		if (startX + offsetX + width) > Constants.SCREEN.WIDTH then -- check to start a new row
			offsetX = 0
			offsetY = offsetY + height + spacer
		end
		if (startY + offsetY + height) > Constants.SCREEN.HEIGHT then -- check to start a new page
			offsetX = 0
			offsetY = 0
		end
	end
end

-- For showing what's highlighted and updating the page #
function LogViewerOverlay.refreshTabBar()
	for _, button in pairs(LogViewerOverlay.TabBarButtons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

function LogViewerOverlay.refreshTempButtons()
	for _, button in pairs(LogViewerOverlay.TemporaryButtons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

-- DRAWING FUNCTIONS
function LogViewerOverlay.drawScreen()
	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)

	local box = {
		x = LogViewerOverlay.margin,
		y = LogViewerOverlay.tabHeight,
		width = Constants.SCREEN.WIDTH - (LogViewerOverlay.margin * 2),
		height = Constants.SCREEN.HEIGHT - LogViewerOverlay.tabHeight - LogViewerOverlay.margin - 1,
	}

	local shadowcolor
	if LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON then
		shadowcolor = LogViewerOverlay.drawPokemonTab(box.x, box.y, box.width, box.height)
	elseif LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.TRAINER then
		shadowcolor = LogViewerOverlay.drawTrainersTab(box.x, box.y, box.width, box.height)
	elseif LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.TMS then
		shadowcolor = LogViewerOverlay.drawTMsTab(box.x, box.y, box.width, box.height)
	elseif LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.MISC then
		shadowcolor = LogViewerOverlay.drawMiscTab(box.x, box.y, box.width, box.height)
	elseif LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM then
		shadowcolor = LogViewerOverlay.drawPokemonZoomed(box.x, box.y, box.width, box.height)
	elseif LogViewerOverlay.currentTab == LogViewerOverlay.Tabs.TRAINER_ZOOM then
		shadowcolor = LogViewerOverlay.drawTrainerZoomed(box.x, box.y, box.width, box.height)
	end

	-- Draw all buttons
	local bgColor = Utils.calcShadowColor(Theme.COLORS["Main background"]) -- Note, "header text" doesn't do shadows for transparency bgs
	for _, button in pairs(LogViewerOverlay.TabBarButtons) do
		Drawing.drawButton(button, bgColor)
	end
	for _, buttonSet in pairs(LogViewerOverlay.PagedButtons) do
		for _, button in pairs(buttonSet) do
			Drawing.drawButton(button, shadowcolor)
		end
	end
	for _, button in pairs(LogViewerOverlay.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

-- Unsure if this will actually be needed, likely some of them
function LogViewerOverlay.drawPokemonTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowcolor
end

function LogViewerOverlay.drawTrainersTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowcolor
end

function LogViewerOverlay.drawTMsTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowcolor
end

function LogViewerOverlay.drawMiscTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowcolor
end

function LogViewerOverlay.drawPokemonZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	local pokemonID = LogViewerOverlay.currentTabInfoId
	local data = LogViewerOverlay.currentTabData
	if not PokemonData.isValid(pokemonID) then
		return shadowcolor
	elseif data == nil then -- ideally this is done only once on tabchange
		LogViewerOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(pokemonID)
		data = LogViewerOverlay.currentTabData
	end

	-- POKEMON NAME
	Drawing.drawText(x + 3, y + 2, data.p.name:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- POKEMON TYPES
	-- Drawing.drawTypeIcon(data.p.types[1], x + 5, y + 13)
	-- if data.p.types[2] ~= data.p.types[1] then
	-- 	Drawing.drawTypeIcon(data.p.types[2], x + 5, y + 25)
	-- end

	-- EVO ARROW
	if #data.p.evos > 0 then
		Drawing.drawImageAsPixels(Constants.PixelImages.NEXT_BUTTON, x + 105, y + 14, { textColor }, shadowcolor)
	end

	local statBox = {
		x = x + 7,
		y = y + 53,
		width = 103,
		height = 68,
		barW = 8,
		labelW = 17,
	}
	local boxHeader = string.format(LogViewerOverlay.Labels.basestatFormat, data.p.bst)
	Drawing.drawText(statBox.x + 4, statBox.y - 11, boxHeader, textColor, shadowcolor)
	-- Draw stat box
	gui.drawRectangle(statBox.x, statBox.y, statBox.width, statBox.height, borderColor, fillColor)
	local quarterMark = statBox.height/4
	gui.drawLine(statBox.x - 3, statBox.y, statBox.x, statBox.y, borderColor)
	gui.drawLine(statBox.x - 1, statBox.y + quarterMark * 1, statBox.x, statBox.y + quarterMark * 1, borderColor)
	gui.drawLine(statBox.x - 2, statBox.y + quarterMark * 2, statBox.x, statBox.y + quarterMark * 2, borderColor)
	gui.drawLine(statBox.x - 1, statBox.y + quarterMark * 3, statBox.x, statBox.y + quarterMark * 3, borderColor)
	gui.drawLine(statBox.x - 3, statBox.y + statBox.height, statBox.x, statBox.y + statBox.height, borderColor)

	local statX = statBox.x + 1
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
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
		-- Draw bar
		gui.drawRectangle(statX + (statBox.labelW - statBox.barW) / 2, barY, statBox.barW, barH, barColor, barColor)

		local statValueOffsetX = (3 - string.len(tostring(data.p[statKey]))) * 2
		Drawing.drawText(statX, statBox.y + statBox.height + 1, Utils.firstToUpper(statKey), textColor, shadowcolor)
		Drawing.drawText(statX + statValueOffsetX, statBox.y + statBox.height + 11, data.p[statKey], barColor, shadowcolor)
		statX = statX + statBox.labelW
	end

	-- data.p.helditems -- unused

	local movesColX = LogViewerOverlay.margin + 121
	local movesRowY = LogViewerOverlay.tabHeight + 42 + 11
	if LogViewerOverlay.PokemonMovesPagination.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES then
		gui.drawLine(movesColX, movesRowY, movesColX + 56, movesRowY, Theme.COLORS["Intermediate text"])
	elseif LogViewerOverlay.PokemonMovesPagination.currentTab == LogViewerOverlay.Tabs.POKEMON_ZOOM_TMMOVES then
		movesColX = movesColX + 70
		gui.drawLine(movesColX, movesRowY, movesColX + 37, movesRowY, Theme.COLORS["Intermediate text"])
	end

	for _, button in pairs(LogViewerOverlay.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	return shadowcolor
end

function LogViewerOverlay.drawTrainerZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowcolor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowcolor
end

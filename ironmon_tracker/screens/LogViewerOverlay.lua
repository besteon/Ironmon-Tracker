LogViewerOverlay = {
	Labels = {
		header = "Log Viewer",
		tabFormat = "%s",
		pageFormat = "Page %s/%s" -- e.g. Page 1/3
	},
	Tabs = {
		POKEMON = Constants.Words.POKEMON,
		POKEMON_ZOOM = Constants.Words.POKEMON .. " Zoom",
		TRAINER = "Trainers",
		TRAINER_ZOOM = "Trainer Zoom",
		TMS = "TMs",
		MISC = "Misc.",
	},
	margin = 2,
	tabHeight = 12,
	currentTab = nil,
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
	changeTab = function(self, newTab)
		LogViewerOverlay.currentTab = newTab
		self.currentPage = 1
		if newTab == LogViewerOverlay.Tabs.POKEMON then
			self.totalPages = math.ceil(#LogViewerOverlay.PagedButtons.Pokemon / self.pokemonPerPage)
		elseif newTab == LogViewerOverlay.Tabs.TRAINER then
			self.totalPages = math.ceil(#LogViewerOverlay.PagedButtons.Trainers / self.trainersPerPage)
		elseif newTab == LogViewerOverlay.Tabs.TMS then
			self.totalPages = math.ceil(#LogViewerOverlay.PagedButtons.TMs / self.tmsPerPage)
		else
			self.totalPages = 1
		end
		LogViewerOverlay.TabHistory = {}
		LogViewerOverlay.refreshTabBar()
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
		onClick = function(self)
			LogViewerOverlay.TabHistory = {}
			LogViewerOverlay.isDisplayed = false
			Program.changeScreenView(Program.Screens.GAMEOVER)
		end,
	},
}

LogViewerOverlay.Buttons = {

}

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
		LogViewerOverlay.Pagination:changeTab(LogViewerOverlay.Tabs.POKEMON) -- TODO: Remove this later
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
				tab = LogViewerOverlay.Tabs.POKEMON,
				isVisible = function(self)
					return LogViewerOverlay.currentTab == self.tab and LogViewerOverlay.Pagination.currentPage == self.pageVisible
				end,
				getIconPath = function(self)
					local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
					return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
				end,
				onClick = function(self)
					-- TODO:
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end,
			}
			table.insert(LogViewerOverlay.PagedButtons.Pokemon, button)
		end
	end

	-- After sorting the moves, determine which are visible on which page, and where on the page vertically
	local startX = LogViewerOverlay.margin + 4
	local startY = LogViewerOverlay.margin + LogViewerOverlay.tabHeight + 7

	LogViewerOverlay.gridAlign(LogViewerOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, 1, LogViewerOverlay.Pagination.pokemonPerPage)
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
	local shadowColor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowColor
end

function LogViewerOverlay.drawTrainersTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowColor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowColor
end

function LogViewerOverlay.drawTMsTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowColor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowColor
end

function LogViewerOverlay.drawMiscTab(x, y, width, height)
	local textColor = Theme.COLORS["Default text"]
	local borderColor = Theme.COLORS["Upper box border"]
	local fillColor = Theme.COLORS["Upper box background"]
	local shadowColor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowColor
end

function LogViewerOverlay.drawPokemonZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowColor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowColor
end

function LogViewerOverlay.drawTrainerZoomed(x, y, width, height)
	local textColor = Theme.COLORS["Lower box text"]
	local borderColor = Theme.COLORS["Lower box border"]
	local fillColor = Theme.COLORS["Lower box background"]
	local shadowColor = Utils.calcShadowColor(fillColor)
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(x, y, width, height, borderColor, fillColor)

	return shadowColor
end

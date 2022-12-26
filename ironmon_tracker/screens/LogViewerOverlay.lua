LogViewerOverlay = {
	Labels = {
		header = "Log Viewer",
		pageFormat = "Page %s/%s" -- e.g. Page 1/3
	},
	Tabs = {
		POKEMON = Constants.Words.POKEMON,
		TRAINER = "Trainers",
		TMS = "TMs",
		MISC = "Misc.",
	},
	margin = 2,
	tabHeight = 15,
	isDisplayed = false,
}

LogViewerOverlay.Pagination = {
	currentPage = 0,
	currentTab = 0,
	totalPages = 0,
	pokemonPerPage = 28,
	trainersPerPage = 32,
	tmsPerPage = 25,
	getPageText = function(self)
		if self.totalPages <= 1 then return "Page" end
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
		self.currentTab = newTab
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
		LogViewerOverlay.Buttons.CurrentPage:updateText()
	end,
}

LogViewerOverlay.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		box = { LogViewerOverlay.margin + 102, LogViewerOverlay.margin + 2, 50, 10, },
		-- isVisible = function() return true end,
		updateText = function(self)
			self.text = LogViewerOverlay.Pagination:getPageText() or ""
			LogViewerOverlay.Buttons.PrevPage.box[1] = self.box[1] - 12
			LogViewerOverlay.Buttons.NextPage.box[1] = self.box[1] + self.text:len() * 4 + 12
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		box = { LogViewerOverlay.margin + 98, LogViewerOverlay.margin + 3, 10, 10, },
		isVisible = function() return LogViewerOverlay.Pagination.totalPages > 1 end,
		onClick = function(self)
			LogViewerOverlay.Pagination:prevPage()
			LogViewerOverlay.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		box = { LogViewerOverlay.margin + 147, LogViewerOverlay.margin + 3, 10, 10, },
		isVisible = function() return LogViewerOverlay.Pagination.totalPages > 1 end,
		onClick = function(self)
			LogViewerOverlay.Pagination:nextPage()
			LogViewerOverlay.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "X",
		textColor = "Negative text",
		box = { LogViewerOverlay.margin + 227, LogViewerOverlay.margin, 9, 11 },
		onClick = function(self)
			LogViewerOverlay.isDisplayed = false
			Program.changeScreenView(Program.Screens.GAMEOVER)
		end
	},
}

-- Holds all of the parsed data in nicely formatted buttons for display and interaction
LogViewerOverlay.PagedButtons = {}

function LogViewerOverlay.initialize()
	for _, button in pairs(LogViewerOverlay.Buttons) do
		if button.textColor == nil then
			button.textColor = "Upper box text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Upper box border", "Upper box background" }
		end
	end
	LogViewerOverlay.Buttons.CurrentPage:updateText()
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
					return LogViewerOverlay.Pagination.currentTab == self.tab and LogViewerOverlay.Pagination.currentPage == self.pageVisible
				end,
				getIconPath = function(self)
					local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
					return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
				end,
				onClick = function(self) InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) end,
			}
			table.insert(LogViewerOverlay.PagedButtons.Pokemon, button)
		end
	end

	-- After sorting the moves, determine which are visible on which page, and where on the page vertically
	local startX = LogViewerOverlay.margin + 3
	local startY = LogViewerOverlay.margin + LogViewerOverlay.tabHeight + 1

	LogViewerOverlay.gridAlign(LogViewerOverlay.PagedButtons.Pokemon, startX, startY, 32, 32, 1, LogViewerOverlay.Pagination.pokemonPerPage)
end

-- Organizes a list of buttons in a row by column fashion based on (x,y,w,h) and what page they should display on
function LogViewerOverlay.gridAlign(buttonList, startX, startY, width, height, spacer, itemsPerPage)
	local offsetX = 0
	local offsetY = 0
	for i, button in ipairs(buttonList) do
		local x = startX + offsetX
		local y = startY + offsetY -- - Options.IconSetMap[Options["Pokemon icon set"]].yOffset
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

-- DRAWING FUNCTIONS
function LogViewerOverlay.drawScreen()
		local topBox = {
		x = LogViewerOverlay.margin,
		y = LogViewerOverlay.margin,
		width = Constants.SCREEN.WIDTH - (LogViewerOverlay.margin * 2),
		height = Constants.SCREEN.HEIGHT - (LogViewerOverlay.margin * 2) - 1,
		text = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}
	local textLineY = topBox.y + 2
	local linespacing = Constants.SCREEN.LINESPACING

	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	Drawing.drawText(topBox.x + 2, textLineY, LogViewerOverlay.Labels.header:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing + 2

	-- Draw all buttons
	for _, buttonSet in pairs(LogViewerOverlay.PagedButtons) do
		for _, button in pairs(buttonSet) do
			Drawing.drawButton(button, topBox.shadow)
		end
	end
	for _, button in pairs(LogViewerOverlay.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end
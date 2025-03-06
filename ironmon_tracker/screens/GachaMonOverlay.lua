GachaMonOverlay = {
	Key = "GachaMonOverlay",
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Upper box border",
		boxFill = "Upper box background",
		headerText = "Header text",
		headerBorder = "Upper box background",
		headerFill = "Main background",
	},
	Tabs = {
		Stats = {
			index = 1,
			tabKey = "Stats",
			resourceKey = "TabStats",
		},
		GamePack = {
			index = 2,
			tabKey = "GamePack",
			resourceKey = "TabGamePack",
		},
		Collection = {
			index = 3,
			tabKey = "Collection",
			resourceKey = "TabCollection",
		},
		Options = {
			index = 4,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	currentTab = nil,
	isDisplayed = false,
}
local SCREEN = GachaMonOverlay
local MARGIN = 2
local TAB_HEIGHT = 12
local CANVAS = {
	X = MARGIN,
	Y = MARGIN + TAB_HEIGHT,
	W = Constants.SCREEN.WIDTH - (MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - TAB_HEIGHT - MARGIN - 1,
}

-- A stack manage the back-button within tabs, each element is { tab, page, }
SCREEN.TabHistory = {}

-- UNUSED
SCREEN.Windower = {
	currentTab = nil,
	currentPage = nil,
	totalPages = nil,
	infoId = -1,
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
		if newTab == nil then return end
		if not SCREEN.isDisplayed then
			SCREEN.isDisplayed = true
		end

		local prevTab = {
			tab = self.currentTab,
			page = self.currentPage,
			totalPages = self.totalPages,
			infoId = self.infoId,
			filterGrid = self.filterGrid,
		}

		self.currentTab = newTab
		self.currentPage = pageNum or self.currentPage or 1
		self.totalPages = totalPages or self.totalPages or 1
		self.infoId = tabInfoId or self.infoId or -1
		self.filterGrid = filterGrid or self.filterGrid or "#"

		SCREEN.refreshButtons()

		-- After reloading the search results content, update to show the last viewed page and grid
		if LogSearchScreen.tryDisplayOrHide() then
			self.currentPage = pageNum or self.currentPage or 1
			self.totalPages = totalPages or self.totalPages or 1
			self.infoId = tabInfoId or self.infoId or -1
			self.filterGrid = filterGrid or self.filterGrid or "#"
		end
	end,
	goBack = function(self)
		local prevTab = table.remove(SCREEN.TabHistory)
		if prevTab ~= nil then
			self:changeTab(prevTab.tab, prevTab.page, prevTab.totalPages, prevTab.infoId, prevTab.filterGrid)
		else
			LogTabPokemon.realignGrid()
			self:changeTab(LogTabPokemon)
		end
	end,
}

SCREEN.HeaderButtons = {
	XIcon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOSE,
		textColor = SCREEN.Colors.headerText,
		box = { CANVAS.X + CANVAS.W - 8, 2, 10, 10 },
		updateSelf = function(self)
			local canGoBackTabs = {
				[LogTabPokemonDetails] = true,
				[LogTabTrainerDetails] = true,
				[LogTabRouteDetails] = true,
			}
			if canGoBackTabs[SCREEN.currentTab] then
				self.textColor = Theme.headerHighlightKey
				self.image = Constants.PixelImages.LEFT_ARROW
				self.box[2] = 1
			else
				self.textColor = SCREEN.Colors.headerText
				self.image = Constants.PixelImages.CLOSE
				self.box[2] = 2
			end
		end,
		onClick = function(self)
			if self.image == Constants.PixelImages.CLOSE then
				SCREEN.TabHistory = {}
				SCREEN.isDisplayed = false
				LogSearchScreen.clearSearch()
				if not Program.isValidMapLocation() then
					-- If the game hasn't started yet
					Program.changeScreenView(StartupScreen)
				else
					Program.changeScreenView(TrackerScreen)
				end
			else -- Constants.PixelImages.LEFT_ARROW
				SCREEN.Windower:goBack()
				Program.redraw(true)
			end
		end,
	},
}
SCREEN.Buttons = {}

function SCREEN.initialize()
	SCREEN.currentTab = nil
	SCREEN.isDisplayed = false
	SCREEN.TabHistory = {}

	SCREEN.createTabs()

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
end

function SCREEN.refreshButtons()
	for _, button in pairs(SCREEN.HeaderButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function SCREEN.createTabs()
	local startX = CANVAS.X
	local startY = CANVAS.Y - TAB_HEIGHT
	local tabPadding = 5
	local tabTextColor = SCREEN.Colors.headerText
	local tabHighlightColor = SCREEN.Colors.highlight
	local tabBorderColor = SCREEN.Colors.headerBorder
	local tabFillColor = SCREEN.Colors.headerFill

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources[SCREEN.Key][tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.HeaderButtons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return tabText end,
			tab = SCREEN.Tabs[tab.tabKey],
			isSelected = false,
			box = {	startX, startY, tabWidth, TAB_HEIGHT },
			textColor = tabTextColor,
			boxColors = { tabBorderColor, tabFillColor },
			updateSelf = function(self)
				self.isSelected = (self.tab == SCREEN.currentTab)
				self.textColor = self.isSelected and tabHighlightColor or tabTextColor
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local color = Theme.COLORS[self.boxColors[1]]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, bgColor, bgColor) -- Box fill
				if not self.isSelected then
					gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, Drawing.ColorEffects.DARKEN, Drawing.ColorEffects.DARKEN)
				end
				gui.drawLine(x + 1, y, x + w - 1, y, color) -- Top edge
				gui.drawLine(x, y + 1, x, y + h - 1, color) -- Left edge
				gui.drawLine(x + w, y + 1, x + w, y + h - 1, color) -- Right edge
				if self.isSelected then
					gui.drawLine(x + 1, y + h, x + w - 1, y + h, bgColor) -- Remove bottom edge
				end
				local centeredOffsetX = Utils.getCenteredTextX(self:getCustomText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getCustomText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self)
				SCREEN.currentTab = self.tab
				SCREEN.TabHistory = {}
				-- SCREEN.Pager.currentPage = 1
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end


-- USER INPUT FUNCTIONS
function SCREEN.checkInput(xmouse, ymouse)
	if not SCREEN.isDisplayed then
		return
	end

	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.HeaderButtons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function SCREEN.drawScreen()
	if not SCREEN.isDisplayed then
		return
	end

	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)

	local canvas = {
		x = CANVAS.X,
		y = CANVAS.Y,
		width = CANVAS.W,
		height = CANVAS.H,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])

	-- Draw all buttons
	for _, button in pairs(SCREEN.HeaderButtons) do
		Drawing.drawButton(button, headerShadow)
	end
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

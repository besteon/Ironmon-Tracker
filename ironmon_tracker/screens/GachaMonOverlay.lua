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
	},
	Tabs = {
		Recent = {
			index = 1,
			tabKey = "Recent",
			resourceKey = "TabRecent",
		},
		Collection = {
			index = 2,
			tabKey = "Collection",
			resourceKey = "TabCollection",
		},
		Battle = {
			index = 3,
			tabKey = "Battle",
			resourceKey = "TabBattle",
		},
		Options = {
			index = 4,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	currentTab = nil,
}
local SCREEN = GachaMonOverlay
local MARGIN = 2
local TAB_HEIGHT = 12
local CANVAS = {
	X = MARGIN,
	Y = MARGIN + TAB_HEIGHT,
	W = Constants.SCREEN.WIDTH - (MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - TAB_HEIGHT - (MARGIN * 2) - 1,
}

GachaMonOverlay.TabButtons = {
	XIcon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOSE,
		textColor = SCREEN.Colors.headerText,
		box = { CANVAS.X + CANVAS.W - 8, 2, 10, 10 },
		updateSelf = function(self)
			if false then -- TODO: if conditions are needed for using a back button
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
				Program.closeScreenOverlay()
			else -- Constants.PixelImages.LEFT_ARROW
			end
			Program.redraw(true)
		end,
	},
}

GachaMonOverlay.Buttons = {
	CollectionSize = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", "GachaMons in Collection" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return GachaMonData.isCollectionLoaded and SCREEN.Stats and (SCREEN.Stats.NumCollection or 0) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 4, CANVAS.Y + 4, 140, 11, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Collection end,
		draw = function(self, shadowcolor)
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local text = self:getValue()
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawText(x + w, y, text, color, shadowcolor)
		end,
	},
	GamePackSize = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", "GachaMons caught this attempt" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return GachaMonData.isCollectionLoaded and SCREEN.Stats and (SCREEN.Stats.NumGamePack or 0) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 4, CANVAS.Y + 16, 140, 11, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Collection end,
		draw = function(self, shadowcolor)
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local text = self:getValue()
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawText(x + w, y, text, color, shadowcolor)
		end,
	},
	LoadingStatus = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		getText = function(self) return string.format("%s...", "Loading Collection" or Resources[SCREEN.Key].Label) end,
		box = { CANVAS.X + 4, CANVAS.Y + CANVAS.H - 14, 12, 11, },
		textColor = SCREEN.Colors.highlight,
		isVisible = function(self) return not GachaMonData.isCollectionLoaded end,
	},
}

function GachaMonOverlay.initialize()
	SCREEN.createTabs()
	SCREEN.currentTab = SCREEN.Tabs.Recent

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
end

function GachaMonOverlay.refreshButtons()
	for _, button in pairs(SCREEN.TabButtons) do
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

function GachaMonOverlay.createTabs()
	local startX = CANVAS.X
	local startY = CANVAS.Y - TAB_HEIGHT
	local tabPadding = 5
	local tabTextColor = SCREEN.Colors.text
	local tabHighlightColor = SCREEN.Colors.highlight
	local tabBorderColor = SCREEN.Colors.border
	local tabFillColor = SCREEN.Colors.boxFill

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources[SCREEN.Key][tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.TabButtons["Tab" .. tab.tabKey] = {
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
				-- SCREEN.Pager.currentPage = 1
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end

function GachaMonOverlay.tryLoadCollection()
	if GachaMonData.isCollectionLoaded then
		return
	end
	Program.addFrameCounter("GachaMonOverlay:LoadCollection", 4, function()
		GachaMonData.FileStorage.importHistorialCollection()
		-- Temporary method to hold some stats
		SCREEN.Stats = GachaMonData.getStats()
		Program.redraw(true)
	end, 1)
end

-- OVERLAY OPEN
function GachaMonOverlay.open()
	LogSearchScreen.clearSearch()
	GachaMonOverlay.tryLoadCollection()
	-- Temporary method to hold some stats
	SCREEN.Stats = GachaMonData.getStats()
	SCREEN.currentTab = SCREEN.Tabs.Recent
	SCREEN.refreshButtons()
end

-- OVERLAY CLOSE
function GachaMonOverlay.close()
	LogSearchScreen.clearSearch()
	-- If the game hasn't started yet
	if not Program.isValidMapLocation() then
		Program.changeScreenView(StartupScreen)
	else
		Program.changeScreenView(TrackerScreen)
	end
end

-- USER INPUT FUNCTIONS
function SCREEN.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.TabButtons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function SCREEN.drawScreen()
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
	Drawing.drawButton(SCREEN.TabButtons.XIcon, headerShadow)

	-- Draw surrounding border box
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw all buttons
	for _, button in pairs(SCREEN.TabButtons) do
		if button ~= SCREEN.TabButtons.XIcon then
			Drawing.drawButton(button, canvas.shadow)
		end
	end
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

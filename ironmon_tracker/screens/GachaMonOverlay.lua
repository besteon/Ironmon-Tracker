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
	Data = {},
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
	PartyLeadGachaMon = {
		type = Constants.ButtonTypes.NO_BORDER,
		box = { CANVAS.X + 40, CANVAS.Y + 20, 70, 70, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Recent end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local card = SCREEN.Data.LeadGachaMonCard
			GachaMonOverlay.drawCard(card, x, y)
		end,
		onClick = function(self)

		end,
	},
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
		getText = function(self) return string.format("%s:", "GachaMons caught this seed" or Resources[SCREEN.Key].Label) end,
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

---Draws a GachaMon card
---@param card table
function GachaMonOverlay.drawCard(card, x, y)
	if not card then
		return
	end
	local numStars = card.Stars or 0
	local W, H, TOPW, TOPH = 70, 70, 40, 10
	local COLORS = {
		bg = Drawing.Colors.BLACK,
		-- border = Drawing.Colors.WHITE,
		border1 = card.FrameColors and card.FrameColors[1] or Drawing.Colors.WHITE,
		border2 = card.FrameColors and card.FrameColors[2] or Drawing.Colors.WHITE,
		stars = numStars > 5 and Drawing.Colors.YELLOW or Drawing.Colors.WHITE,
		power = Drawing.Colors.WHITE,
		text = Drawing.Colors.WHITE,
		name = Drawing.Colors.YELLOW - Drawing.ColorEffects.DARKEN,
	}

	-- Draw frame border
	gui.drawRectangle(x, y, W, H, COLORS.bg, COLORS.bg)
	-- left-half
	gui.drawLine(x+1, y+1, x+1+TOPW, y+1, COLORS.border1)
	gui.drawLine(x+1, y+1, x+1, y+H-1, COLORS.border1)
	gui.drawLine(x+1, y+H-1, x+W/2, y+H-1, COLORS.border1)
	local barW = 4
	gui.drawLine(x+1, y+H-15, x+W/2, y+H-15, COLORS.border1)
	gui.drawLine(x+W/2+1, y+H-15, x+W-1, y+H-15, COLORS.border2)
	local angleW = 4
	gui.drawLine(x+TOPW, y+1, x+TOPW+angleW, y+1+TOPH, COLORS.border2)
	gui.drawLine(x+TOPW+1, y+1, x+TOPW+1+angleW, y+1+TOPH, COLORS.border2)
	-- right-half
	gui.drawLine(x+1+TOPW+angleW, y+1+TOPH, x+W-1, y+1+TOPH, COLORS.border2)
	gui.drawLine(x+W-1, y+H-1, x+W-1, y+1+TOPH, COLORS.border2)
	gui.drawLine(x+W/2+1, y+H-1, x+W-1, y+H-1, COLORS.border2)

	-- STARS
	numStars = math.max(numStars, 5)
	Drawing.drawText(x + 2, y + 2, string.rep("*", card.Stars or 0), COLORS.stars)
	-- POWER
	local powerRightAlign = 3 + Utils.calcWordPixelLength(tostring(card.Power))
	Drawing.drawText(x + W - powerRightAlign, y, card.Power or Constants.BLANKLINE, COLORS.power)
	-- ICON
	if PokemonData.isImageIDValid(card.PokemonId) then
		Drawing.drawPokemonIcon(card.PokemonId, x + W / 2 - 16, y + 8)
	end
	-- ABILITY TEXT
	if AbilityData.isValid(card.AbilityId) then
		local abilityName = AbilityData.Abilities[card.AbilityId].name
		local abilityX = Utils.getCenteredTextX(abilityName, W) - 1
		Drawing.drawText(x + abilityX, y + H - 28, abilityName, COLORS.text)
	end
	-- NAME TEXT
	if PokemonData.isValid(card.PokemonId) then
		local monName = PokemonData.Pokemon[card.PokemonId].name
		local monX = Utils.getCenteredTextX(monName, W) - 1
		Drawing.drawText(x + monX, y + H - 14, monName, COLORS.name)
	end
end

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

	-- CREATE OPTIONS CHECKBOXES
	startX = CANVAS.X + 4
	startY = CANVAS.Y + 4
	local optionKeyMap = {
		{ "Show GachaMon catch info in Carousel box", "OptionShowGachaMonInCarouselBox", },
		{ "Add GachaMon to collection after defeating a trainer", "OptionAutoAddGachaMonToCollection", },
		{ "Animate GachaMon pack opening", "OptionAnimateGachaMonPackOpening", },
	}
	for _, optionTuple in ipairs(optionKeyMap) do
		local textWidth = Utils.calcWordPixelLength(Resources[SCREEN.Key][optionTuple[2]])
		textWidth = math.max(textWidth, 50) -- minimum 50 pixels
		SCREEN.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources[SCREEN.Key][optionTuple[2]] end,
			clickableArea = { startX, startY, textWidth + 8, 8 },
			box = {	startX, startY, 8, 8 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Options end,
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)
				Program.redraw(true)
			end
		}
		startY = startY + Constants.SCREEN.LINESPACING + 1
	end
end

function GachaMonOverlay.buildData()
	SCREEN.Data = {}

	-- Create the display card for the lead pokemon
	local leadPokemon = TrackerAPI.getPlayerPokemon(1)
	if leadPokemon then
		GachaMonData.tryAddToRecentMons(leadPokemon)
		local leadGachamon = GachaMonData.RecentMons[leadPokemon.personality or false]
		if leadGachamon then
			SCREEN.Data.LeadGachaMonCard = leadGachamon:getCardDisplayData()
		end
	end

	-- Temporary method to hold some stats
	SCREEN.Stats = GachaMonData.getStats()
end

function GachaMonOverlay.tryLoadCollection()
	if GachaMonData.isCollectionLoaded then
		return
	end
	Program.addFrameCounter("GachaMonOverlay:LoadCollection", 2, function()
		GachaMonData.FileStorage.importCollection()
		-- Temporary method to hold some stats
		SCREEN.Stats = GachaMonData.getStats()
		Program.redraw(true)
	end, 1)
end

-- OVERLAY OPEN
function GachaMonOverlay.open()
	LogSearchScreen.clearSearch()
	SCREEN.tryLoadCollection()
	SCREEN.buildData()
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

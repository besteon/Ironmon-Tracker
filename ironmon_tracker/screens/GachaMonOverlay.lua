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
		View = {
			index = 1,
			tabKey = "View",
			resourceKey = "TabView",
		},
		Recent = {
			index = 2,
			tabKey = "Recent",
			resourceKey = "TabRecent",
		},
		Collection = {
			index = 3,
			tabKey = "Collection",
			resourceKey = "TabCollection",
		},
		Battle = {
			index = 4,
			tabKey = "Battle",
			resourceKey = "TabBattle",
		},
		Options = {
			index = 5,
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

GachaMonOverlay.Buttons = {}

local TEMPCOL = 90
GachaMonOverlay.Tabs.View.Buttons = {
	Dividers = {
		box = { CANVAS.X + 88, CANVAS.Y, 1, CANVAS.H, },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local color = Theme.COLORS[SCREEN.Colors.border]
			local segmentLength, segmentSpacer = 4, 6
			for iy = y, (y + h), segmentLength + segmentSpacer do
				gui.drawLine(x, iy, x, math.min(iy + segmentLength, y + h), color)
			end
		end,
	},
	GachaMonCard = {
		box = { CANVAS.X + 3, CANVAS.Y + 3, 70, 70, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local card = SCREEN.Data.ViewedMon:getCardDisplayData()
			GachaMonOverlay.drawGachaCard(card, x, y)
		end,
	},
	ShareCode = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		getText = function(self) return "Share Code" end,
		box = { CANVAS.X + 4, CANVAS.Y + 85, 80, 16, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		updateSelf = function(self)
		end,
		onClick = function(self)
		end,
	},
	Favorite = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.HEART,
		getText = function(self) return "Favorite" end,
		box = { CANVAS.X + 4, CANVAS.Y + 104, 80, 16, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		updateSelf = function(self)
		end,
		onClick = function(self)
		end,
	},
	KeepInCollection = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CHECKMARK,
		iconColors = { SCREEN.Colors.positive },
		getText = function(self) return "In Collection" end,
		box = { CANVAS.X + 4, CANVAS.Y + 123, 80, 16, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		updateSelf = function(self)
		end,
		onClick = function(self)
		end,
	},
	Stats = {
		box = { CANVAS.X + TEMPCOL + 1, CANVAS.Y + 3, 100, 66, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local langOffset = (Resources.currentLanguage == Resources.Languages.JAPANESE) and 3 or 0
			local statLabels = {
				Resources.TrackerScreen.StatHP, Resources.TrackerScreen.StatATK, Resources.TrackerScreen.StatDEF,
				Resources.TrackerScreen.StatSPA, Resources.TrackerScreen.StatSPD, Resources.TrackerScreen.StatSPE,
			}
			local stats = SCREEN.Data.ViewedMon:getStats()
			for i, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
				local iy = y + 10 * (i-1)
				local color = Theme.COLORS[SCREEN.Colors.text]
				local natureSymbol
				local natureMultiplier = Utils.getNatureMultiplier(statKey, SCREEN.Data.ViewedMon:getNature())
				if natureMultiplier == 1.1 then
					color = Theme.COLORS[SCREEN.Colors.positive]
					natureSymbol = "+"
				elseif natureMultiplier == 0.9 then
					color = Theme.COLORS[SCREEN.Colors.negative]
					natureSymbol = Constants.BLANKLINE
				end
				-- STAT LABEL
				Drawing.drawText(x, iy, statLabels[i], color, shadowcolor)
				if natureSymbol then
					Drawing.drawText(x + 16 + langOffset, iy - 1, natureSymbol, color, nil, 5, Constants.Font.FAMILY)
				end
				-- STAT VALUE
				if not Options["Color stat numbers by nature"] then
					color = Theme.COLORS[SCREEN.Colors.text]
				end
				local statVal = (stats[statKey] or 0) == 0 and Constants.BLANKLINE or stats[statKey]
				Drawing.drawNumber(x + 25, iy, statVal, 3, color, shadowcolor)
			end
		end,
	},
	Moves = {
		box = { CANVAS.X + TEMPCOL + 50, CANVAS.Y + 3, 100, 44, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		onClick = function(self)
			-- local moveIds = SCREEN.Data.ViewedMon:getMoveIds()
			-- if MoveData.isValid(moveIds[1]) then
			-- 	InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, moveIds[1]) -- implied redraw
			-- end
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local moveIds = SCREEN.Data.ViewedMon:getMoveIds()
			for i, moveId in ipairs(moveIds or {}) do
				local name, power = Constants.BLANKLINE, ""
				if MoveData.isValid(moveId) then
					name = MoveData.Moves[moveId].name
					power = MoveData.Moves[moveId].power
					if power == "0" then
						power = Constants.BLANKLINE
					end
				end
				local color = Theme.COLORS[SCREEN.Colors.text]
				local iy = y + 11 * (i-1)
				Drawing.drawText(x, iy, name, color, shadowcolor)
				Drawing.drawNumber(x + 75, iy, power, 3, color, shadowcolor)
			end
			-- local moveColor = Constants.MoveTypeColors[move.type or false] or Theme.COLORS[SCREEN.Colors.text]
			-- local pokemonInternal = PokemonData.Pokemon[SCREEN.Data.ViewedMon.PokemonId or false] or PokemonData.BlankPokemon
		end,
	},
	NameLevelGender = {
		getText = function(self)
			local pokemonInternal = PokemonData.Pokemon[SCREEN.Data.ViewedMon.PokemonId or false] or PokemonData.BlankPokemon
			return string.format("%s  (%s.%s)", pokemonInternal.name, Resources.TrackerScreen.LevelAbbreviation, SCREEN.Data.ViewedMon.Level or 0)
		end,
		textColor = SCREEN.Colors.text,
		box = { CANVAS.X + TEMPCOL, CANVAS.Y + 70, 100, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local gender = SCREEN.Data.ViewedMon:getGender()
			local gSymbol
			if gender == 1 then
				gSymbol = Constants.PixelImages.MALE_SYMBOL
			elseif gender == 2 then
				gSymbol = Constants.PixelImages.FEMALE_SYMBOL
			end
			if gSymbol then
				Drawing.drawImageAsPixels(gSymbol, x + 90, y + 2, Theme.COLORS[self.textColor], shadowcolor)
			end
		end,
	},
	Nature = {
		getText = function(self)
			local nature = SCREEN.Data.ViewedMon:getNature()
			return string.format("%s:  %s", "Nature", Resources.Game.NatureNames[nature + 1] or Constants.BLANKLINE)
		end,
		textColor = SCREEN.Colors.text,
		box = { CANVAS.X + TEMPCOL, CANVAS.Y + 81, 100, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
	},
	RatingAndStars = {
		getText = function(self)
			return string.format("%s:  %s   %s", "Rating", SCREEN.Data.ViewedMon.RatingScore or 0, string.rep("*", SCREEN.Data.ViewedMon:getStars()))
		end,
		textColor = SCREEN.Colors.text,
		box = { CANVAS.X + TEMPCOL, CANVAS.Y + 92, 100, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
	},
	SeedAndDate = {
		getText = function(self)
			local seedFormatted = Utils.formatNumberWithCommas(SCREEN.Data.ViewedMon.SeedNumber or 0)
			local dateFormatted = os.date("%x", os.time(SCREEN.Data.ViewedMon:getDateObtainedTable()))
			return string.format("%s:  %s  (%s)", "Seed", seedFormatted, dateFormatted)
		end,
		textColor = SCREEN.Colors.text,
		box = { CANVAS.X + TEMPCOL, CANVAS.Y + 103, 100, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
	},
	GameVersion = {
		getText = function(self)
			return string.format("%s:  %s", "Version", SCREEN.Data.ViewedMon:getGameVersion())
		end,
		textColor = SCREEN.Colors.text,
		box = { CANVAS.X + TEMPCOL, CANVAS.Y + 114, 100, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
	},
}

GachaMonOverlay.Tabs.Recent.Buttons = {
	PartyLeadGachaMon = {
		type = Constants.ButtonTypes.NO_BORDER,
		box = { CANVAS.X + 40, CANVAS.Y + 20, 70, 70, },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local card = SCREEN.Data.LeadGachaMonCard
			GachaMonOverlay.drawGachaCard(card, x, y)
		end,
		onClick = function(self)

		end,
	},
}

GachaMonOverlay.Tabs.Collection.Buttons = {
	CollectionSize = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", "GachaMons in Collection" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return GachaMonData.isCollectionLoaded and SCREEN.Stats and (SCREEN.Stats.NumCollection or 0) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 4, CANVAS.Y + 4, 140, 11, },
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

GachaMonOverlay.Tabs.Battle.Buttons = {

}

GachaMonOverlay.Tabs.Options.Buttons = {

}

local function _getCurrentTabButtons()
	return SCREEN.currentTab and SCREEN.currentTab.Buttons or {}
end

---Draws a GachaMon card
---@param card table
---@param showFavoriteOverride? boolean Optional, displays the heart (empty or full); default: only if actually favorited
function GachaMonOverlay.drawGachaCard(card, x, y, showFavoriteOverride)
	if not card then
		return
	end
	local numStars = card.Stars or 0
	local W, H, TOP_W, TOP_H, BOT_H = 70, 70, 40, 10, 15
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

	-- FRAME
	gui.drawRectangle(x, y, W, H, COLORS.bg, COLORS.bg)
	-- left-half
	gui.drawLine(x+1, y+1, x+1+TOP_W, y+1, COLORS.border1)
	gui.drawLine(x+1, y+1, x+1, y+H-1, COLORS.border1)
	gui.drawLine(x+1, y+H-1, x+W/2, y+H-1, COLORS.border1)
	local botBarY = y+H-BOT_H
	gui.drawLine(x+1, botBarY, x+W/2, botBarY, COLORS.border1)
	gui.drawLine(x+W/2+1, botBarY, x+W-1, botBarY, COLORS.border2)
	local angleW = 4
	gui.drawLine(x+TOP_W, y+1, x+TOP_W+angleW, y+1+TOP_H, COLORS.border2)
	gui.drawLine(x+TOP_W+1, y+1, x+TOP_W+1+angleW, y+1+TOP_H, COLORS.border2)
	-- right-half
	gui.drawLine(x+1+TOP_W+angleW, y+1+TOP_H, x+W-1, y+1+TOP_H, COLORS.border2)
	gui.drawLine(x+W-1, y+H-1, x+W-1, y+1+TOP_H, COLORS.border2)
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
	-- FAVORITE ICON
	if card.Favorite == 1 or showFavoriteOverride then
		local heartFill = Constants.PixelImages.HEART.iconColors
		if card.Favorite ~= 1 then
			heartFill = { COLORS.border2, COLORS.bg, COLORS.bg }
		end
		Drawing.drawImageAsPixels(Constants.PixelImages.HEART, x+W-13, y+TOP_H+3, heartFill)
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
	-- STAT BARS
	if type(card.StatBars) == "table" then
		for i, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local statY = botBarY + 2 * i
			local statW = card.StatBars[statKey] or 0
			gui.drawLine(x+1, statY, x+1+statW, statY, COLORS.border1)
			gui.drawLine(x+W-1-statW, statY, x+W-1, statY, COLORS.border2)
		end
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
	for _, button in pairs(_getCurrentTabButtons()) do
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
		SCREEN.Tabs.Options.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources[SCREEN.Key][optionTuple[2]] end,
			clickableArea = { startX, startY, textWidth + 8, 8 },
			box = {	startX, startY, 8, 8 },
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
			SCREEN.Data.ViewedMon = leadGachamon
		end
	end

	-- Temporary method to hold some stats
	SCREEN.Stats = GachaMonData.getOverlayStats()
end

function GachaMonOverlay.tryLoadCollection()
	if GachaMonData.isCollectionLoaded then
		return
	end
	Program.addFrameCounter("GachaMonOverlay:LoadCollection", 2, function()
		GachaMonData.FileStorage.importCollection()
		-- Temporary method to hold some stats
		SCREEN.Stats = GachaMonData.getOverlayStats()
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
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons) -- TODO: unneeded
	Input.checkButtonsClicked(xmouse, ymouse, _getCurrentTabButtons())
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
	for _, button in pairs(_getCurrentTabButtons()) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

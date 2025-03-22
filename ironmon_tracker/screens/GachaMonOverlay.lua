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
		-- TODO: Will add in later, on release
		-- Battle = {
		-- 	index = 4,
		-- 	tabKey = "Battle",
		-- 	resourceKey = "TabBattle",
		-- },
		Options = {
			index = 5,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	Data = {},
	GACHAMONS_PER_PAGE = 6,
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

GachaMonOverlay.Tabs.View.Buttons = {
	NameAndOtherInfo = {
		box = { CANVAS.X + 4, CANVAS.Y + 2, 100, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		draw = function(self, shadowcolor)
			local x, y, x2 = self.box[1], self.box[2], self.box[1] + 63
			local color = Theme.COLORS[SCREEN.Colors.text]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			-- NAME & GENDER
			local nameText = Utils.toUpperUTF8(SCREEN.Data.ViewedMon:getName())
			Drawing.drawText(x, y, nameText, highlight, shadowcolor)
			local genderIndex = SCREEN.Data.ViewedMon:getGender()
			local gSymbols = { Constants.PixelImages.MALE_SYMBOL, Constants.PixelImages.FEMALE_SYMBOL }
			if gSymbols[genderIndex] then
				local nameTextW = 8 + Utils.calcWordPixelLength(nameText)
				Drawing.drawImageAsPixels(gSymbols[genderIndex], x + nameTextW, y + 2, highlight, shadowcolor)
			end
			y = y + Constants.SCREEN.LINESPACING
			-- LEVEL & NATURE
			local levelText = string.format("%s.%s", Resources.TrackerScreen.LevelAbbreviation, SCREEN.Data.ViewedMon.Level or 0)
			local nature = SCREEN.Data.ViewedMon:getNature()
			local natureText = Resources.Game.NatureNames[nature + 1]
			if natureText then
				Drawing.drawText(x, y, natureText, color, shadowcolor)
			end
			Drawing.drawText(x2, y, levelText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			-- RATING & STARS
			local ratingText = tostring(SCREEN.Data.ViewedMon.RatingScore or 0)
			local ratingTextW = 5 + Utils.calcWordPixelLength(ratingText)
			local stars = tostring(SCREEN.Data.ViewedMon:getStars())
			if tonumber(stars) > 5 then
				stars = "5+"
			end
			local starsText = string.format("(%s stars)", stars)
			Drawing.drawText(x, y, string.format("%s:", "Rating"), color, shadowcolor)
			Drawing.drawText(x2, y, ratingText, color, shadowcolor)
			Drawing.drawText(x2 + ratingTextW, y, starsText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			-- BATTLE POWER
			local powerText = tostring(SCREEN.Data.ViewedMon.BattlePower or 0)
			Drawing.drawText(x, y, string.format("%s:", "Battle Power"), color, shadowcolor)
			Drawing.drawText(x2, y, powerText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			-- COLLECTED ON INFO: DATE, SEED, GAME VERSION
			local dateText = os.date("%x", os.time(SCREEN.Data.ViewedMon:getDateObtainedTable()))
			local seedText = Utils.formatNumberWithCommas(SCREEN.Data.ViewedMon.SeedNumber or 0)
			local versionText = SCREEN.Data.ViewedMon:getGameVersionName()
			Drawing.drawText(x, y, string.format("%s:", "Collected on"), color, shadowcolor)
			Drawing.drawText(x2, y, dateText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			Drawing.drawText(x2, y, string.format("%s # %s", "Seed", seedText), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			Drawing.drawText(x2, y, versionText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
		end,
	},

	Stats = {
		getText = function(self) return string.format("%s", "Stats") end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 3, CANVAS.Y + 69, 44, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			gui.drawLine(x + 1, y + h, x + w, y + h, Theme.COLORS[SCREEN.Colors.border])
			y = y + 2

			local langOffset = (Resources.currentLanguage == Resources.Languages.JAPANESE) and 3 or 0
			local statLabels = {
				Resources.TrackerScreen.StatHP, Resources.TrackerScreen.StatATK, Resources.TrackerScreen.StatDEF,
				Resources.TrackerScreen.StatSPA, Resources.TrackerScreen.StatSPD, Resources.TrackerScreen.StatSPE,
			}
			local stats = SCREEN.Data.ViewedMon:getStats()
			for i, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
				local iy = y + 10 * i
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
				Drawing.drawText(x + 1, iy, statLabels[i], color, shadowcolor)
				if natureSymbol then
					Drawing.drawText(x + 17 + langOffset, iy - 1, natureSymbol, color, nil, 5, Constants.Font.FAMILY)
				end
				-- STAT VALUE
				if not Options["Color stat numbers by nature"] then
					color = Theme.COLORS[SCREEN.Colors.text]
				end
				local statVal = (stats[statKey] or 0) == 0 and Constants.BLANKLINE or stats[statKey]
				Drawing.drawNumber(x + 26, iy, statVal, 3, color, shadowcolor)
			end
		end,
	},

	Moves = {
		getText = function(self) return string.format("%s", Resources.TrackerScreen.HeaderMoves) end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 57, CANVAS.Y + 88, 83, 11, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		onClick = function(self)
			-- local moveIds = SCREEN.Data.ViewedMon:getMoveIds()
			-- if MoveData.isValid(moveIds[1]) then
			-- 	InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, moveIds[1]) -- implied redraw
			-- end
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			gui.drawLine(x + 1, y + h, x + w, y + h, Theme.COLORS[SCREEN.Colors.border])
			y = y + 2

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
				local iy = y + 10 * i
				Drawing.drawText(x + 1, iy, name, color, shadowcolor)
				Drawing.drawNumber(x + 65, iy, power, 3, color, shadowcolor)
			end
			-- local moveColor = Constants.MoveTypeColors[move.type or false] or Theme.COLORS[SCREEN.Colors.text]
		end,
	},

	GachaMonCard = {
		box = { CANVAS.X + CANVAS.W - 77, CANVAS.Y + 1, 76, 76, },
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local border = Theme.COLORS[SCREEN.Colors.border]
			-- Draw containment border
			gui.drawRectangle(x - 1, y - 1, w + 2, h + 2, border, Drawing.Colors.BLACK)
			gui.drawLine(x, y + h + 2, x + w, y + h + 2, shadowcolor)
			-- Draw card
			local card = SCREEN.Data.ViewedMon:getCardDisplayData()
			GachaMonOverlay.drawGachaCard(card, x, y, 4)
			-- Draw card version number
			if SCREEN.Data.ViewedMon.Version or 0 > 0 then
				local color =  Theme.COLORS[SCREEN.Colors.text]
				local versionText = string.format("v%s", SCREEN.Data.ViewedMon.Version)
				local versionTextW = 5 + Utils.calcWordPixelLength(versionText)
				Drawing.drawText(x - versionTextW, y - 1, versionText, color, shadowcolor)
			end
		end,
	},

	ShareCode = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		getText = function(self) return "Share Code" end,
		box = { CANVAS.X + CANVAS.W - 78, CANVAS.Y + 83, 78, 16, },
		noShadowBorder = true,
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		onClick = function(self)
			if not SCREEN.Data.ViewedMon then
				return
			end
			GachaMonOverlay.openShareCodeWindow(SCREEN.Data.ViewedMon)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw single shadow line
			gui.drawLine(x + 1, y + h + 1, x + w - 1, y + h + 1, shadowcolor)
		end,
	},
	Favorite = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.HEART,
		getText = function(self) return "Favorite" end,
		box = { CANVAS.X + CANVAS.W - 78, CANVAS.Y + 103, 78, 16, },
		noShadowBorder = true,
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		updateSelf = function(self)
			local favorite = SCREEN.Data.ViewedMon and SCREEN.Data.ViewedMon.Favorite or 0
			if favorite == 1 then
				self.iconColors = { 0xFFF04037, Drawing.Colors.RED, Drawing.Colors.WHITE }
			else
				self.iconColors = { SCREEN.Colors.text, SCREEN.Colors.boxFill, SCREEN.Colors.boxFill }
			end
		end,
		onClick = function(self)
			if not SCREEN.Data.ViewedMon then
				return
			end
			local isNowFave = SCREEN.Data.ViewedMon.Favorite ~= 1 -- invert
			-- If favorited but not currently in collection, mark to save it in collection
			local alsoSaveInCollection = isNowFave or nil
			GachaMonData.updateGachaMonAndSave(SCREEN.Data.ViewedMon, isNowFave, alsoSaveInCollection)
			self:updateSelf()
			if alsoSaveInCollection then
				GachaMonOverlay.Tabs.View.Buttons.KeepInCollection:updateSelf()
			end
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw single shadow line
			gui.drawLine(x + 1, y + h + 1, x + w - 1, y + h + 1, shadowcolor)
		end,
	},
	KeepInCollection = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CHECKMARK,
		iconColors = { SCREEN.Colors.positive },
		getText = function(self) return "In Collection" end,
		box = { CANVAS.X + CANVAS.W - 78, CANVAS.Y + 123, 78, 16, },
		noShadowBorder = true,
		isVisible = function(self) return SCREEN.Data.ViewedMon ~= nil end,
		updateSelf = function(self)
			local keep = SCREEN.Data.ViewedMon and SCREEN.Data.ViewedMon:getKeep() or 0
			if keep == 1 then
				self.image = Constants.PixelImages.CHECKMARK
				self.iconColors = { SCREEN.Colors.positive }
			else
				self.image = Constants.PixelImages.CROSS
				self.iconColors = { SCREEN.Colors.text }
			end
		end,
		onClick = function(self)
			if not SCREEN.Data.ViewedMon then
				return
			end
			local isNowKeep = SCREEN.Data.ViewedMon:getKeep() ~= 1 -- invert
			if isNowKeep then
				GachaMonData.updateGachaMonAndSave(SCREEN.Data.ViewedMon, nil, true)
			else
				GachaMonData.tryRemoveFromCollection(SCREEN.Data.ViewedMon)
				GachaMonOverlay.Tabs.View.Buttons.Favorite:updateSelf()
			end
			self:updateSelf()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw single shadow line
			gui.drawLine(x + 1, y + h + 1, x + w - 1, y + h + 1, shadowcolor)
		end,
	},
}

GachaMonOverlay.Tabs.Recent.Buttons = {
	-- 6 GachaMon Buttons added during buildData()

	CurrentPage = {
		box = { CANVAS.X + 212, CANVAS.Y + 95, 22, 11, },
		isVisible = function() return SCREEN.Data.Recent and (SCREEN.Data.Recent.totalPages or 0) > 1 end,
		draw = function(self, shadowcolor)
			local R = SCREEN.Data.Recent
			if R.totalPages <= 1 then
				return
			end
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Theme.COLORS[SCREEN.Colors.text]
			-- local pageText = string.format("%s", R.currentPage)
			local pageText = tostring(R.currentPage or 1)
			local pageTextX = Utils.getCenteredTextX(pageText, w)
			Drawing.drawText(x + pageTextX, y, pageText, color, shadowcolor)
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 80, 10, 10, },
		isVisible = function() return SCREEN.Data.Recent and (SCREEN.Data.Recent.totalPages or 0) > 1 end,
		onClick = function(self)
			local R = SCREEN.Data.Recent
			if R.totalPages <= 1 then return end
			R.currentPage = ((R.currentPage - 2 + R.totalPages) % R.totalPages) + 1
			Program.redraw(true)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 112, 10, 10, },
		isVisible = function() return SCREEN.Data.Recent and (SCREEN.Data.Recent.totalPages or 0) > 1 end,
		onClick = function(self)
			local R = SCREEN.Data.Recent
			if R.totalPages <= 1 then return end
			R.currentPage = (R.currentPage % R.totalPages) + 1
			Program.redraw(true)
		end,
	},
}

GachaMonOverlay.Tabs.Collection.Buttons = {
	-- 6 GachaMon Buttons added during buildData()

	CurrentPage = {
		box = { CANVAS.X + 212, CANVAS.Y + 95, 22, 11, },
		isVisible = function() return SCREEN.Data.Collection and (SCREEN.Data.Collection.totalPages or 0) > 1 end,
		draw = function(self, shadowcolor)
			local C = SCREEN.Data.Collection
			if C.totalPages <= 1 then
				return
			end
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Theme.COLORS[SCREEN.Colors.text]
			-- local pageText = string.format("%s", R.currentPage)
			local pageText = tostring(C.currentPage or 1)
			local pageTextX = Utils.getCenteredTextX(pageText, w)
			Drawing.drawText(x + pageTextX, y, pageText, color, shadowcolor)
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 80, 10, 10, },
		isVisible = function() return SCREEN.Data.Collection and (SCREEN.Data.Collection.totalPages or 0) > 1 end,
		onClick = function(self)
			local C = SCREEN.Data.Collection
			if C.totalPages <= 1 then return end
			C.currentPage = ((C.currentPage - 2 + C.totalPages) % C.totalPages) + 1
			Program.redraw(true)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 112, 10, 10, },
		isVisible = function() return SCREEN.Data.Collection and (SCREEN.Data.Collection.totalPages or 0) > 1 end,
		onClick = function(self)
			local C = SCREEN.Data.Collection
			if C.totalPages <= 1 then return end
			C.currentPage = (C.currentPage % C.totalPages) + 1
			Program.redraw(true)
		end,
	},
	LoadingStatus = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		getCustomText = function(self) return string.format("%s...", "Loading Collection" or Resources[SCREEN.Key].Label) end,
		box = { CANVAS.X + 100, CANVAS.Y + CANVAS.H/2 - 1, 12, 12, },
		isVisible = function(self) return not GachaMonData.initialCollectionLoad end,
		draw = function(self, shadowcolor)
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Drawing.Colors.YELLOW
			Drawing.drawText(x + w + 3, y, self:getCustomText(), color, shadowcolor)
		end,
	},
}

-- GachaMonOverlay.Tabs.Battle.Buttons = {

-- }

GachaMonOverlay.Tabs.Options.Buttons = {
	-- list of options populated in createTabs()

	RecentSize = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", "GachaMons caught this seed" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return SCREEN.Data.Recent and (#SCREEN.Data.Recent.OrderedGachaMons) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 20, CANVAS.Y + 60, 140, 11, },
		draw = function(self, shadowcolor)
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local text = self:getValue()
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawNumber(x + w, y, text, 4, color, shadowcolor)
		end,
	},
	CollectionSize = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", "GachaMons in Collection" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return SCREEN.Data.Collection and (#SCREEN.Data.Collection.OrderedGachaMons) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 20, CANVAS.Y + 71, 140, 11, },
		draw = function(self, shadowcolor)
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local text = self:getValue()
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawNumber(x + w, y, text, 4, color, shadowcolor)
		end,
	},

	CleanupCollection = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SPARKLES,
		iconColors = { SCREEN.Colors.text },
		getText = function(self) return "Cleanup Collection" end,
		box = { CANVAS.X + 4, CANVAS.Y + 123, 95, 16, },
		isVisible = function(self) return #GachaMonData.Collection > 0 end,
		onClick = function(self)
			-- TODO: Open popup prompt for cleanup options
		end,
	},
}

local function _getCurrentTabButtons()
	return SCREEN.currentTab and SCREEN.currentTab.Buttons or {}
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

	-- Recent & Collection GachaMon Buttons
	local W, H = 70, 70
	for i = 1, SCREEN.GACHAMONS_PER_PAGE, 1 do
		local btnLabel = string.format("GachaMon%s", i)
		local xOffset = W * ((i - 1) % (SCREEN.GACHAMONS_PER_PAGE / 2))
		local yOffset = (H + 1) * (math.ceil(i / (SCREEN.GACHAMONS_PER_PAGE / 2)) - 1)
		GachaMonOverlay.Tabs.Recent.Buttons[btnLabel] = {
			slotNumber = i,
			box = { CANVAS.X + 1 + xOffset, CANVAS.Y + 1 + yOffset, W, H, },
			isVisible = function(self) return SCREEN.getMonForRecentScreenSlot(self.slotNumber) ~= nil end,
			draw = function(self, shadowcolor)
				local gachamon = SCREEN.getMonForRecentScreenSlot(self.slotNumber)
				if not gachamon then return end
				local x, y = self.box[1], self.box[2]
				local card = gachamon:getCardDisplayData()
				local isFave = gachamon.Favorite == 1
				local inCollection = gachamon:getKeep() == 1
				GachaMonOverlay.drawGachaCard(card, x, y, 1, isFave, inCollection)
			end,
			onClick = function(self)
				SCREEN.Data.ViewedMon = SCREEN.getMonForRecentScreenSlot(self.slotNumber)
				SCREEN.currentTab = SCREEN.Tabs.View
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		GachaMonOverlay.Tabs.Collection.Buttons[btnLabel] = {
			slotNumber = i,
			box = { CANVAS.X + 1 + xOffset, CANVAS.Y + 1 + yOffset, W, H, },
			isVisible = function(self) return SCREEN.getMonForCollectionScreenSlot(self.slotNumber) ~= nil end,
			draw = function(self, shadowcolor)
				local gachamon = SCREEN.getMonForCollectionScreenSlot(self.slotNumber)
				if not gachamon then return end
				local x, y = self.box[1], self.box[2]
				local card = gachamon:getCardDisplayData()
				local isFave = gachamon.Favorite == 1
				GachaMonOverlay.drawGachaCard(card, x, y, 1, isFave)
			end,
			onClick = function(self)
				SCREEN.Data.ViewedMon = SCREEN.getMonForCollectionScreenSlot(self.slotNumber)
				SCREEN.currentTab = SCREEN.Tabs.View
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
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

	-- Recent Tab Data
	SCREEN.Data.Recent = {}
	SCREEN.buildRecentData()

	-- Collection Tab Data
	SCREEN.Data.Collection = {}
	SCREEN.buildCollectionData()

	-- View Tab
	SCREEN.Data.ViewedMon = GachaMonData.newestRecentMon

	-- Create the display card for the lead pokemon
	local leadPokemon = TrackerAPI.getPlayerPokemon(1)
	if not SCREEN.Data.ViewedMon and leadPokemon then
		GachaMonData.tryAddToRecentMons(leadPokemon)
		SCREEN.Data.ViewedMon = GachaMonData.RecentMons[leadPokemon.personality or false]
	end

	if not SCREEN.Data.ViewedMon then
		SCREEN.Data.ViewedMon = SCREEN.Data.Recent.OrderedGachaMons[1]
	end
end

---Builds the data tables necessary for the tabs to diplsay the cards in the Recent caught GachaMons
---@param filterFunc? function Optional, filters out
function GachaMonOverlay.buildRecentData(filterFunc)
	SCREEN.Data.Recent.currentPage = 1
	SCREEN.Data.Recent.OrderedGachaMons = {}
	for _, gachamon in pairs(GachaMonData.RecentMons or {}) do
		table.insert(SCREEN.Data.Recent.OrderedGachaMons, gachamon)
	end
	SCREEN.Data.Recent.totalPages = math.ceil(#SCREEN.Data.Recent.OrderedGachaMons / SCREEN.GACHAMONS_PER_PAGE)
	-- Apply any filters
	if filterFunc then
		-- TODO: somehow filter out stuff quickly
	end
	-- Sort newest first
	table.sort(SCREEN.Data.Recent.OrderedGachaMons,
		function(a,b) return (a.Temp.DateTimeObtained or 0) > (b.Temp.DateTimeObtained or 0) end
	)
end

---Builds the data tables necessary for the tabs to diplsay the cards in the collection
---@param filterFunc? function Optional, filters out
function GachaMonOverlay.buildCollectionData(filterFunc)
	if not SCREEN.Data or not SCREEN.Data.Collection then
		return
	end
	-- Collection Tab Data
	SCREEN.Data.Collection.currentPage = 1
	SCREEN.Data.Collection.OrderedGachaMons = {}
	for i, gachamon in ipairs(GachaMonData.Collection or {}) do
		SCREEN.Data.Collection.OrderedGachaMons[i] = gachamon
	end
	-- Apply any filters
	if filterFunc then
		-- TODO: somehow filter out stuff quickly
	end
	-- Sort favorites, then newest first
	table.sort(SCREEN.Data.Collection.OrderedGachaMons, function(a,b)
		return a.Favorite > b.Favorite
			or (a.Favorite == b.Favorite and (a.C_DateObtained or 0) > (b.C_DateObtained or 0))
	end)
	SCREEN.Data.Collection.totalPages = math.ceil(#SCREEN.Data.Collection.OrderedGachaMons / SCREEN.GACHAMONS_PER_PAGE)

	if not SCREEN.Data.ViewedMon then
		SCREEN.Data.ViewedMon = SCREEN.Data.Collection.OrderedGachaMons[1]
	end
end

function GachaMonOverlay.getMonForRecentScreenSlot(slotNumber)
	local D = SCREEN.Data.Recent or {}
	local pageIndex = (D.currentPage or 0) - 1
	local index = pageIndex * SCREEN.GACHAMONS_PER_PAGE + slotNumber
	return D.OrderedGachaMons and D.OrderedGachaMons[index] or nil
end

function GachaMonOverlay.getMonForCollectionScreenSlot(slotNumber)
	local D = SCREEN.Data.Collection or {}
	local pageIndex = (D.currentPage or 0) - 1
	local index = pageIndex * SCREEN.GACHAMONS_PER_PAGE + slotNumber
	return D.OrderedGachaMons and D.OrderedGachaMons[index] or nil
end

function GachaMonOverlay.tryLoadCollection()
	if GachaMonData.initialCollectionLoad then
		return
	end
	GachaMonData.initialCollectionLoad = true
	GachaMonFileManager.importCollection()
end

function GachaMonOverlay.openShareCodeWindow(gachamon)
	local shareCode = gachamon and GachaMonData.getShareablyCode(gachamon) or "N/A"
	local form = ExternalUI.BizForms.createForm("GachaMon Share Code", 450, 160)
	form:createLabel("Show off your GachaMon by sharing this code.", 19, 10)
	form:createLabel(string.format("%s:", "Copy the shareable code below with Ctrl+C"), 19, 30)
	form:createTextBox(shareCode, 20, 55, 400, 22, nil, false, true)
	form:createButton(Resources.AllScreens.Close, 200, 85, function()
		form:destroy()
	end)
end

---Draws a GachaMon card
---@param card table
---@param borderPadding? number Optional, defaults to 3 pixel border padding
---@param showFavoriteOverride? boolean Optional, displays the heart (empty or full); default: only if actually favorited
---@param showCollectionOverride? boolean Optional, displays the checkmark (empty or full); default: never shows
function GachaMonOverlay.drawGachaCard(card, x, y, borderPadding, showFavoriteOverride, showCollectionOverride)
	if not card then
		return
	end
	borderPadding = borderPadding or 3
	local numStars = card.Stars or 0
	local W, H, TOP_W, TOP_H, BOT_H = 68, 68, 40, 10, 15
	local COLORS = {
		bg = Drawing.Colors.BLACK,
		-- border = Drawing.Colors.WHITE,
		border1 = card.FrameColors and card.FrameColors[1] or Drawing.Colors.WHITE,
		border2 = card.FrameColors and card.FrameColors[2] or Drawing.Colors.WHITE,
		stars = numStars > 5 and Drawing.Colors.YELLOW or Drawing.Colors.WHITE,
		power = Drawing.Colors.WHITE,
		checkmark = Drawing.Colors.GREEN,
		text = Drawing.Colors.YELLOW - Drawing.ColorEffects.DARKEN,
		name = Drawing.Colors.WHITE,
	}

	-- FRAME
	gui.drawRectangle(x, y, W + borderPadding * 2, H + borderPadding * 2, COLORS.bg, COLORS.bg)
	if card.ShinyAnimationFrame then
		-- TODO
	end
	x = x + borderPadding
	y = y + borderPadding
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
	numStars = math.min(numStars, 5) -- max 5
	local needsTwoLines = (numStars == 5)
	local starIcon = Constants.PixelImages.STAR or Constants.PixelImages.PHYSICAL
	local starIconColors = {
		COLORS.stars,
		COLORS.stars - (2 * Drawing.ColorEffects.DARKEN),
		COLORS.stars - (4 * Drawing.ColorEffects.DARKEN),
	}
	local starSize = #starIcon + 1
	for i = 1, numStars, 1 do
		local iX = x + 3 + starSize * (i - 1)
		local iY = y + 3
		-- Normally draw 1 to 4 stars horizontally, unless its a 5-star, then do a 3/2 split
		if i >= 4 and needsTwoLines then
			iX = iX - 3 * starSize
			iY = iY + starSize
		end
		Drawing.drawImageAsPixels(starIcon, iX, iY, starIconColors)
	end
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
		Drawing.drawImageAsPixels(Constants.PixelImages.HEART, x+W-14, y+TOP_H+4, heartFill)
	end
	-- IN COLLECTION ICON (only if requested)
	if showCollectionOverride then
		local checkmarkIcon = Constants.PixelImages.CHECKMARK
		local checkmarkFill = { COLORS.checkmark }
		if not card.InCollection then
			checkmarkIcon = Constants.PixelImages.CROSS
			checkmarkFill = { Drawing.colors.WHITE }
		end
		Drawing.drawImageAsPixels(checkmarkIcon, x+W-14, y+TOP_H+16, checkmarkFill)
	end
	-- ABILITY TEXT
	if AbilityData.isValid(card.AbilityId) then
		local abilityName = AbilityData.Abilities[card.AbilityId].name
		local abilityX = Utils.getCenteredTextX(abilityName, W) - 1
		Drawing.drawText(x + abilityX, y + H - 27, abilityName, COLORS.text)
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
	GachaMonFileManager.trySaveCollectionOnClose()
	if SCREEN.Data then
		SCREEN.Data.ViewedMon = nil
		if SCREEN.Data.Recent then
			SCREEN.Data.Recent.currentPage = 1
		end
		if SCREEN.Data.Collection then
			SCREEN.Data.Collection.currentPage = 1
		end
	end
	-- If the game hasn't started yet
	if not Program.isValidMapLocation() then
		Program.currentScreen = StartupScreen
	else
		Program.currentScreen = TrackerScreen
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

	-- Draw card background
	if SCREEN.currentTab == SCREEN.Tabs.Recent or SCREEN.currentTab == SCREEN.Tabs.Collection then
		gui.drawRectangle(canvas.x + 1, canvas.y + 1, 210, 141, Drawing.Colors.BLACK, Drawing.Colors.BLACK)
		gui.drawLine(canvas.x + 212, canvas.y + 1, canvas.x + 212, canvas.y + 142, canvas.border)
	end

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

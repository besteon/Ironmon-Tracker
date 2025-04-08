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
		View = {
			index = 3,
			tabKey = "View",
			resourceKey = "TabView",
		},
		GachaDex = {
			index = 4,
			tabKey = "GachaDex",
			resourceKey = "TabGachaDex",
		},
		Battle = {
			index = 5,
			tabKey = "Battle",
			resourceKey = "TabBattle",
		},
		Options = {
			index = 6,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
		About = {
			index = 7,
			tabKey = "About",
			resourceKey = "TabAbout",
		},
	},
	Data = {},
	GACHAMONS_PER_PAGE = 6,
	MINIMONS_PER_PAGE = 24,
	hasShinyToDraw = false,
	shinyFrameCounter = 0,
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

GachaMonOverlay.SortFuncs = {
	DefaultRecentSort = function(a, b)
		return (a.Temp.DateTimeObtained or 0) > (b.Temp.DateTimeObtained or 0)
	end,
	DefaultCollectionSort = function(a, b)
		return a.Favorite > b.Favorite
			or (a.Favorite == b.Favorite and (a.C_DateObtained or 0) > (b.C_DateObtained or 0))
	end,
	ByDateDesc = function(a, b)
		return (a.Temp.DateTimeObtained or a.C_DateObtained or 0) > (b.Temp.DateTimeObtained or b.C_DateObtained or 0)
	end,
	ByStarsDesc = function(a, b)
		return (a:getStars() or 0) > (b:getStars() or 0)
	end,
	ByBattlePowerDesc = function(a, b)
		return (a.BattlePower or 0) > (b.BattlePower or 0)
	end,
	ByPokemonIdAsc = function(a, b)
		return (a.PokemonId or 9999) < (b.PokemonId or 9999)
	end,
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

GachaMonOverlay.Tabs.View.Buttons = {
	NameAndOtherInfo = {
		box = { CANVAS.X + 4, CANVAS.Y + 2, 100, 11, },
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil end,
		draw = function(self, shadowcolor)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			local x, y, x2 = self.box[1], self.box[2], self.box[1] + 61
			local color = Theme.COLORS[SCREEN.Colors.text]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			-- NAME & GENDER
			local nameText = Utils.toUpperUTF8(gachamon:getName())
			Drawing.drawText(x, y, nameText, highlight, shadowcolor)
			local genderIndex = gachamon:getGender()
			local gSymbols = { Constants.PixelImages.MALE_SYMBOL, Constants.PixelImages.FEMALE_SYMBOL }
			if gSymbols[genderIndex] then
				local nameTextW = 8 + Utils.calcWordPixelLength(nameText)
				Drawing.drawImageAsPixels(gSymbols[genderIndex], x + nameTextW, y + 2, highlight, shadowcolor)
			end
			y = y + Constants.SCREEN.LINESPACING
			-- LEVEL & NATURE
			local levelText = string.format("%s. %s", Resources.TrackerScreen.LevelAbbreviation, gachamon.Level or 0)
			local nature = gachamon:getNature()
			local natureText = Resources.Game.NatureNames[nature + 1]
			if natureText then
				Drawing.drawText(x, y, natureText, color, shadowcolor)
			end
			Drawing.drawText(x2, y, levelText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			-- RATING & STARS
			local stars = tostring(gachamon:getStars())
			if tonumber(stars) > 5 then
				stars = "5+"
			end
			local ratingText = string.format("%s %s  (%s %s)", gachamon.RatingScore or 0, "points", stars, "stars")
			Drawing.drawText(x, y, string.format("%s:", "Rating"), color, shadowcolor)
			Drawing.drawText(x2, y, ratingText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			-- BATTLE POWER
			local bpText = string.format("%s %s", gachamon.BattlePower or 0, "BP")
			Drawing.drawText(x, y, string.format("%s:", "Battle Power"), color, shadowcolor)
			Drawing.drawText(x2, y, bpText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			-- COLLECTED ON INFO: DATE, SEED, GAME VERSION
			local dateText = os.date("%x", os.time(gachamon:getDateObtainedTable()))
			local seedText = Utils.formatNumberWithCommas(gachamon.SeedNumber or 0)
			local versionText = gachamon:getGameVersionName()
			Drawing.drawText(x, y, string.format("%s:", "Collected on"), color, shadowcolor)
			Drawing.drawText(x2, y, dateText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			Drawing.drawText(x2, y, versionText, color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
			Drawing.drawText(x2, y, string.format("%s %s", "Seed", seedText), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING
		end,
	},
	Stats = {
		getText = function(self) return string.format("%s", "Stats") end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 3, CANVAS.Y + 69, 44, 11, },
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil end,
		draw = function(self, shadowcolor)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			gui.drawLine(x + 1, y + h, x + w, y + h, Theme.COLORS[SCREEN.Colors.border])
			y = y + 2

			local langOffset = (Resources.currentLanguage == Resources.Languages.JAPANESE) and 3 or 0
			local statLabels = {
				Resources.TrackerScreen.StatHP, Resources.TrackerScreen.StatATK, Resources.TrackerScreen.StatDEF,
				Resources.TrackerScreen.StatSPA, Resources.TrackerScreen.StatSPD, Resources.TrackerScreen.StatSPE,
			}
			local stats = gachamon:getStats()
			for i, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
				local iy = y + 10 * i
				local color = Theme.COLORS[SCREEN.Colors.text]
				local natureSymbol
				local natureMultiplier = Utils.getNatureMultiplier(statKey, gachamon:getNature())
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
		box = { CANVAS.X + 55, CANVAS.Y + 88, 83, 11, },
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil end,
		onClick = function(self)
			-- local moveIds = SCREEN.Data.View.GachaMon:getMoveIds()
			-- if MoveData.isValid(moveIds[1]) then
			-- 	InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, moveIds[1]) -- implied redraw
			-- end
		end,
		draw = function(self, shadowcolor)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			gui.drawLine(x + 1, y + h, x + w, y + h, Theme.COLORS[SCREEN.Colors.border])
			y = y + 2

			local moveIds = gachamon:getMoveIds()
			for i, moveId in ipairs(moveIds or {}) do
				local move = MoveData.Moves[moveId] or MoveData.BlankMove
				local name, power = Constants.BLANKLINE, ""
				if MoveData.isValid(moveId) or (GachaMonData.requiresNatDex and moveId > 354) then
					name = move.name
					power = move.power
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
	RecalculateAsTemp = {
		box = { CANVAS.X + 126, CANVAS.Y + 3, 14, 12, },
		tempGachaMon = nil,
		originalGachaMon = nil,
		isVisible = function(self)
			local V = SCREEN.Data.View
			local gachamon = V.OriginalGachaMon or V.GachaMon
			if not gachamon then
				return false
			end
			local pokemon = TrackerAPI.getPlayerPokemon() or {}
			local monMatches = pokemon.personality == gachamon.Personality and pokemon.pokemonID == gachamon.PokemonId
			local diffLevel = pokemon.level ~= gachamon.Level
			return monMatches and diffLevel
		end,
		onClick = function(self)
			local V = SCREEN.Data.View
			local pokemon = TrackerAPI.getPlayerPokemon()
			if V.TemporaryGachaMon then
				V.TemporaryGachaMon = nil
				V.GachaMon = V.OriginalGachaMon
			elseif pokemon then
				V.TemporaryGachaMon = GachaMonData.convertPokemonToGachaMon(pokemon)
				if V.GachaMon:getIsShiny() ~= V.TemporaryGachaMon:getIsShiny() then
					V.TemporaryGachaMon.Temp.IsShiny = V.GachaMon:getIsShiny()
				end
				V.OriginalGachaMon = V.GachaMon
				V.GachaMon = V.TemporaryGachaMon
			end
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local iconColors
			if SCREEN.Data.View.TemporaryGachaMon then
				iconColors = { Theme.COLORS[SCREEN.Colors.highlight] }
			else
				iconColors = { Theme.COLORS[SCREEN.Colors.text] }
			end
			Drawing.drawImageAsPixels(Constants.PixelImages.UP_ARROW, x, y, iconColors, shadowcolor)
			Drawing.drawImageAsPixels(Constants.PixelImages.DOWN_ARROW, x + 6, y + 1, iconColors, shadowcolor)
		end,
	},
	GachaMonCard = {
		box = { CANVAS.X + CANVAS.W - 77, CANVAS.Y + 1, 76, 76, },
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil end,
		draw = function(self, shadowcolor)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local border = Theme.COLORS[SCREEN.Colors.border]
			-- Draw containment border
			gui.drawRectangle(x - 1, y - 1, w + 2, h + 2, border, Drawing.Colors.BLACK)
			gui.drawLine(x, y + h + 2, x + w, y + h + 2, shadowcolor)
			-- Draw card
			local card = gachamon:getCardDisplayData()
			GachaMonOverlay.drawGachaCard(card, x, y, 4)
			-- Draw card version number
			if gachamon.Version or 0 > 0 then
				local color =  Theme.COLORS[SCREEN.Colors.text]
				local versionText = string.format("v%s", gachamon.Version)
				local versionTextW = 5 + Utils.calcWordPixelLength(versionText)
				Drawing.drawText(x - versionTextW, y - 1, versionText, color, shadowcolor)
			end
		end,
	},
	Badges = {
		box = { CANVAS.X + CANVAS.W - 95, CANVAS.Y + 12, 25, 72, },
		badgeImages = {},
		isVisible = function(self)
			-- Only draw the badges if the GachaMon has any (just leave empty otherwise)
			local gachamon = SCREEN.Data.View.GachaMon
			return gachamon and gachamon.Badges > 0
		end,
		updateSelf = function(self)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			-- Setup image paths and kerning for corresponding game badges
			self.badgeImages = {}
			local gameNumber = gachamon:getGameVersionNumber()
			if gameNumber == 4 then
				gameNumber = 1 -- 1:Ruby/Sapphire
			elseif gameNumber == 5 then
				gameNumber = 3 -- 3:FireRed/LeafGreen
			end
			local badgeInfoTable = Constants.Badges[gameNumber] or {}
			local badgePrefix = badgeInfoTable.Prefix or "FRLG" -- just picked a default
			local kerningOffsets = badgeInfoTable.IconOffsets or {}
			for i = 1, 8, 1 do
				local badgeState = Utils.getbits(gachamon.Badges or 0, i - 1, 1)
				local badgeOff = (badgeState == 0 and "_OFF") or ""
				local filename = badgePrefix .. "_badge" .. i .. badgeOff
				self.badgeImages[i] = {
					Path = FileManager.buildImagePath(FileManager.Folders.Badges, filename, FileManager.Extensions.BADGE),
					Kerning = kerningOffsets[i] or 0, -- Not currently used (For FRLG at least)
				}
			end
		end,
		draw = function(self, shadowcolor)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			if not self.badgeImages[1] or not self.badgeImages[1].Path then
				self:updateSelf()
			end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			for i = 1, 8, 1 do
				-- local badgeState = Utils.getbits(gachamon.Badges or 0, i - 1, 1)
				if self.badgeImages[i] and self.badgeImages[i].Path then
					local ix = x
					local iy = y + (i-1) * 16
					Drawing.drawImage(self.badgeImages[i].Path, ix, iy)
				end
			end
		end,
	},
	Battle = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.BATTLE_BALLS,
		iconColors = Constants.PixelImages.BATTLE_BALLS.iconColors,
		getText = function(self) return "Battle" end,
		box = { CANVAS.X + CANVAS.W - 78, CANVAS.Y + 82, 78, 17, },
		noShadowBorder = true,
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil and SCREEN.Data.View.TemporaryGachaMon == nil end,
		onClick = function(self)
			if not SCREEN.Data.View.GachaMon then
				return
			end
			SCREEN.Data.Battle.PlayerMon = SCREEN.Data.View.GachaMon
			SCREEN.currentTab = SCREEN.Tabs.Battle
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw single shadow line
			gui.drawLine(x + 1, y + h + 1, x + w - 1, y + h + 1, shadowcolor)
			-- Redraw box's bottom line because icon too large w/ its shadow
			local border = Theme.COLORS[SCREEN.Colors.border]
			gui.drawLine(x, y + h, x + 17, y + h, border)
		end,
	},
	Favorite = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.HEART,
		getText = function(self) return "Favorite" end,
		box = { CANVAS.X + CANVAS.W - 78, CANVAS.Y + 103, 78, 16, },
		noShadowBorder = true,
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil and SCREEN.Data.View.TemporaryGachaMon == nil end,
		updateSelf = function(self)
			local gachamon = SCREEN.Data.View.GachaMon
			local favorite = gachamon and gachamon.Favorite or 0
			if favorite == 1 then
				self.iconColors = { 0xFFF04037, Drawing.Colors.RED, Drawing.Colors.WHITE }
			else
				self.iconColors = { SCREEN.Colors.text, SCREEN.Colors.boxFill, SCREEN.Colors.boxFill }
			end
		end,
		onClick = function(self)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			local isNowFave = gachamon.Favorite ~= 1 -- invert
			-- If favorited but not currently in collection, mark to save it in collection
			local alsoSaveInCollection = isNowFave or nil
			GachaMonData.updateGachaMonAndSave(gachamon, isNowFave, alsoSaveInCollection)
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
		isVisible = function(self) return SCREEN.Data.View.GachaMon ~= nil and SCREEN.Data.View.TemporaryGachaMon == nil end,
		updateSelf = function(self)
			local gachamon = SCREEN.Data.View.GachaMon
			local keep = gachamon and gachamon:getKeep() or 0
			if keep == 1 then
				self.image = Constants.PixelImages.CHECKMARK
				self.getText = function() return "In Collection" end
			else
				self.image = nil
				self.getText = function() return "" end
			end
		end,
		onClick = function(self)
			local gachamon = SCREEN.Data.View.GachaMon
			if not gachamon then
				return
			end
			local isNowKeep = gachamon:getKeep() ~= 1 -- invert
			if isNowKeep then
				GachaMonData.updateGachaMonAndSave(gachamon, nil, true)
			else
				GachaMonData.tryRemoveFromCollection(gachamon)
				GachaMonOverlay.Tabs.View.Buttons.Favorite:updateSelf()
			end
			self:updateSelf()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local gachamon = SCREEN.Data.View.GachaMon
			local keep = gachamon and gachamon:getKeep() or 0
			if keep ~= 1 then
				local text = "Add to Collection"
				local color = Theme.COLORS[SCREEN.Colors.text]
				Drawing.drawText(x + 4, y + 2, text, color, shadowcolor)
			end
			-- Draw single shadow line
			gui.drawLine(x + 1, y + h + 1, x + w - 1, y + h + 1, shadowcolor)
		end,
	},
}

GachaMonOverlay.Tabs.Recent.Buttons = {
	-- 6 GachaMon Buttons added during buildData()

	EditFilters = {
		image = Constants.PixelImages.FILTER_SETTINGS,
		box = { CANVAS.X + 217, CANVAS.Y + 5, 14, 11, },
		onClick = function(self)
			SCREEN.openFilterSettingsWindow(SCREEN.Tabs.Recent.tabKey)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw a dividing border much further down below
			local border = Theme.COLORS[SCREEN.Colors.border]
			gui.drawLine(CANVAS.X + 213, y + 15, CANVAS.X + CANVAS.W - 1, y + 15, border)
			local color = Theme.COLORS[SCREEN.Colors.text]
			if SCREEN.Data.Recent.FilterFunc then
				color = Theme.COLORS[SCREEN.Colors.highlight]
				gui.drawRectangle(x - 2, y - 2, w + 4, h + 3, color)
			end
			local iconColors = { color, color - Drawing.ColorEffects.DARKEN * 2 }
			Drawing.drawImageAsPixels(self.image, x, y, iconColors, shadowcolor)
		end
	},
	LabelSort = {
		getText = function(self) return string.format("%s:", "Sort") end,
		box = { CANVAS.X + 213, CANVAS.Y + 21, 16, 16, },
		draw = function(self, shadowcolor)
			local y = self.box[2]
			-- Draw a dividing border much further down below
			local border = Theme.COLORS[SCREEN.Colors.border]
			gui.drawLine(CANVAS.X + 213, y + 69, CANVAS.X + CANVAS.W - 1, y + 69, border)
		end,
	},
	SortByStars = {
		image = Constants.PixelImages.STAR,
		box = { CANVAS.X + 216, CANVAS.Y + 32, 16, 16, },
		sortFunc = SCREEN.SortFuncs.ByStarsDesc,
		onClick = function(self)
			if SCREEN.Data.Recent.SortFunc == self.sortFunc then
				SCREEN.Data.Recent.SortFunc = SCREEN.SortFuncs.DefaultRecentSort
			else
				SCREEN.Data.Recent.SortFunc = self.sortFunc
			end
			SCREEN.buildRecentData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			if SCREEN.Data.Recent.SortFunc == self.sortFunc then
				local highlight = Theme.COLORS[SCREEN.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y, w, h, highlight, 1, 5, 1)
			end
			x, y = x + 3, y + 3
			local color = Theme.COLORS[SCREEN.Colors.text]
			local iconColors = {
				color,
				color - Drawing.ColorEffects.DARKEN * 2,
				color,
			}
			Drawing.drawImageAsPixels(self.image, x, y, iconColors, shadowcolor)
		end
	},
	SortByBattlePower = {
		image = Constants.PixelImages.PHYSICAL,
		box = { CANVAS.X + 216, CANVAS.Y + 51, 16, 16, },
		sortFunc = SCREEN.SortFuncs.ByBattlePowerDesc,
		onClick = function(self)
			if SCREEN.Data.Recent.SortFunc == self.sortFunc then
				SCREEN.Data.Recent.SortFunc = SCREEN.SortFuncs.DefaultRecentSort
			else
				SCREEN.Data.Recent.SortFunc = self.sortFunc
			end
			SCREEN.buildRecentData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			if SCREEN.Data.Recent.SortFunc == self.sortFunc then
				local highlight = Theme.COLORS[SCREEN.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y, w, h, highlight, 1, 5, 1)
			end
			x, y = x + 0, y + 0
			local color = Theme.COLORS[SCREEN.Colors.text]
			Drawing.drawText(x + 1, y + 1, "BP", shadowcolor, shadowcolor, 11)
			Drawing.drawText(x, y, "BP", color, shadowcolor, 11)
		end
	},
	SortByDate = {
		image = Constants.PixelImages.CALENDAR,
		box = { CANVAS.X + 216, CANVAS.Y + 70, 16, 16, },
		sortFunc = SCREEN.SortFuncs.ByDateDesc,
		onClick = function(self)
			if SCREEN.Data.Recent.SortFunc == self.sortFunc then
				SCREEN.Data.Recent.SortFunc = SCREEN.SortFuncs.DefaultRecentSort
			else
				SCREEN.Data.Recent.SortFunc = self.sortFunc
			end
			SCREEN.buildRecentData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			if SCREEN.Data.Recent.SortFunc == self.sortFunc then
				local highlight = Theme.COLORS[SCREEN.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y, w, h, highlight, 1, 5, 1)
			end
			x, y = x + 3, y + 2
			Drawing.drawImageAsPixels(self.image, x, y, self.image:getColors(), shadowcolor)
		end
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 96, 10, 10, },
		isVisible = function() return SCREEN.Data.Recent and (SCREEN.Data.Recent.totalPages or 0) > 1 end,
		onClick = function(self)
			local C = SCREEN.Data.Recent
			if C.totalPages <= 1 then return end
			C.currentPage = ((C.currentPage - 2 + C.totalPages) % C.totalPages) + 1
			Program.redraw(true)
		end,
	},
	CurrentPage = {
		box = { CANVAS.X + 212, CANVAS.Y + 110, 22, 11, },
		isVisible = function() return SCREEN.Data.Recent and (SCREEN.Data.Recent.totalPages or 0) > 1 end,
		draw = function(self, shadowcolor)
			local C = SCREEN.Data.Recent
			if C.totalPages <= 1 then
				return
			end
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local pageText = tostring(C.currentPage or 1)
			local pageTextX = Utils.getCenteredTextX(pageText, w)
			Drawing.drawText(x + pageTextX, y, pageText, color, shadowcolor)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 127, 10, 10, },
		isVisible = function() return SCREEN.Data.Recent and (SCREEN.Data.Recent.totalPages or 0) > 1 end,
		onClick = function(self)
			local C = SCREEN.Data.Recent
			if C.totalPages <= 1 then return end
			C.currentPage = (C.currentPage % C.totalPages) + 1
			Program.redraw(true)
		end,
	},
}

GachaMonOverlay.Tabs.Collection.Buttons = {
	-- 6 GachaMon Buttons added during buildData()

	EditFilters = {
		image = Constants.PixelImages.FILTER_SETTINGS,
		box = { CANVAS.X + 217, CANVAS.Y + 5, 14, 11, },
		onClick = function(self)
			SCREEN.openFilterSettingsWindow(SCREEN.Tabs.Collection.tabKey)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local color = Theme.COLORS[SCREEN.Colors.text]
			if SCREEN.Data.Collection.FilterFunc then
				color = Theme.COLORS[SCREEN.Colors.highlight]
				gui.drawRectangle(x - 2, y - 2, w + 4, h + 3, color)
			end
			local iconColors = { color, color - Drawing.ColorEffects.DARKEN * 2 }
			Drawing.drawImageAsPixels(self.image, x, y, iconColors, shadowcolor)
		end
	},
	LabelSort = {
		getText = function(self) return string.format("%s:", "Sort") end,
		box = { CANVAS.X + 213, CANVAS.Y + 21, 16, 16, },
	},
	SortByStars = {
		image = Constants.PixelImages.STAR,
		box = { CANVAS.X + 216, CANVAS.Y + 32, 16, 16, },
		sortFunc = SCREEN.SortFuncs.ByStarsDesc,
		onClick = function(self)
			if SCREEN.Data.Collection.SortFunc == self.sortFunc then
				SCREEN.Data.Collection.SortFunc = SCREEN.SortFuncs.DefaultCollectionSort
			else
				SCREEN.Data.Collection.SortFunc = self.sortFunc
			end
			SCREEN.buildCollectionData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			if SCREEN.Data.Collection.SortFunc == self.sortFunc then
				local highlight = Theme.COLORS[SCREEN.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y, w, h, highlight, 1, 5, 1)
			end
			x, y = x + 3, y + 3
			local color = Theme.COLORS[SCREEN.Colors.text]
			local iconColors = {
				color,
				color - Drawing.ColorEffects.DARKEN * 2,
				color,
			}
			Drawing.drawImageAsPixels(self.image, x, y, iconColors, shadowcolor)
		end
	},
	SortByBattlePower = {
		image = Constants.PixelImages.PHYSICAL,
		box = { CANVAS.X + 216, CANVAS.Y + 51, 16, 16, },
		sortFunc = SCREEN.SortFuncs.ByBattlePowerDesc,
		onClick = function(self)
			if SCREEN.Data.Collection.SortFunc == self.sortFunc then
				SCREEN.Data.Collection.SortFunc = SCREEN.SortFuncs.DefaultCollectionSort
			else
				SCREEN.Data.Collection.SortFunc = self.sortFunc
			end
			SCREEN.buildCollectionData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			if SCREEN.Data.Collection.SortFunc == self.sortFunc then
				local highlight = Theme.COLORS[SCREEN.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y, w, h, highlight, 1, 5, 1)
			end
			x, y = x + 0, y + 0
			local color = Theme.COLORS[SCREEN.Colors.text]
			Drawing.drawText(x + 1, y + 1, "BP", shadowcolor, shadowcolor, 11)
			Drawing.drawText(x, y, "BP", color, shadowcolor, 11)
		end
	},
	SortByDate = {
		image = Constants.PixelImages.CALENDAR,
		box = { CANVAS.X + 216, CANVAS.Y + 70, 16, 16, },
		sortFunc = SCREEN.SortFuncs.ByDateDesc,
		onClick = function(self)
			if SCREEN.Data.Collection.SortFunc == self.sortFunc then
				SCREEN.Data.Collection.SortFunc = SCREEN.SortFuncs.DefaultCollectionSort
			else
				SCREEN.Data.Collection.SortFunc = self.sortFunc
			end
			SCREEN.buildCollectionData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			if SCREEN.Data.Collection.SortFunc == self.sortFunc then
				local highlight = Theme.COLORS[SCREEN.Colors.highlight]
				Drawing.drawSelectionIndicators(x, y, w, h, highlight, 1, 5, 1)
			end
			x, y = x + 3, y + 2
			Drawing.drawImageAsPixels(self.image, x, y, self.image:getColors(), shadowcolor)
		end
	},

	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 96, 10, 10, },
		isVisible = function() return SCREEN.Data.Collection and (SCREEN.Data.Collection.totalPages or 0) > 1 end,
		onClick = function(self)
			local C = SCREEN.Data.Collection
			if C.totalPages <= 1 then return end
			C.currentPage = ((C.currentPage - 2 + C.totalPages) % C.totalPages) + 1
			Program.redraw(true)
		end,
	},
	CurrentPage = {
		box = { CANVAS.X + 212, CANVAS.Y + 110, 22, 11, },
		isVisible = function() return SCREEN.Data.Collection and (SCREEN.Data.Collection.totalPages or 0) > 1 end,
		draw = function(self, shadowcolor)
			local C = SCREEN.Data.Collection
			if C.totalPages <= 1 then
				return
			end
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local pageText = tostring(C.currentPage or 1)
			local pageTextX = Utils.getCenteredTextX(pageText, w)
			Drawing.drawText(x + pageTextX, y, pageText, color, shadowcolor)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 127, 10, 10, },
		isVisible = function() return SCREEN.Data.Collection and (SCREEN.Data.Collection.totalPages or 0) > 1 end,
		onClick = function(self)
			local C = SCREEN.Data.Collection
			if C.totalPages <= 1 then return end
			C.currentPage = (C.currentPage % C.totalPages) + 1
			Program.redraw(true)
		end,
	},
}

GachaMonOverlay.Tabs.GachaDex.Buttons = {
	-- Several Mini-GachaMon Buttons added during buildData()

	ToggleSeenIcons = {
		image = Constants.PixelImages.POKEBALL,
		box = { CANVAS.X + 217, CANVAS.Y + 4, 14, 14, },
		isVisible = function(self) return SCREEN.Data.GachaDex ~= nil end,
		onClick = function(self)
			if SCREEN.Data.GachaDex.ShowAllSeenIcons then
				SCREEN.Data.GachaDex.ShowAllSeenIcons = nil
			else
				SCREEN.Data.GachaDex.ShowAllSeenIcons = true
				SCREEN.Data.GachaDex.TempShowPokemon = nil
			end
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local border = Theme.COLORS[SCREEN.Colors.border]
			gui.drawRectangle(x, y, w + 1, h + 1, border)
			x = x + 2
			y = y + 2
			local iconColors = TrackerScreen.PokeBalls.ColorList
			if SCREEN.Data.GachaDex.ShowAllSeenIcons then
				iconColors = { Theme.COLORS[SCREEN.Colors.text] }
			end
			Drawing.drawImageAsPixels(self.image, x, y, iconColors, shadowcolor)
		end
	},
	LabelPercentage = {
		box = { CANVAS.X + 213, CANVAS.Y + 21, 22, 12, },
		isVisible = function(self) return SCREEN.Data.GachaDex ~= nil end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			local percentage = SCREEN.Data.GachaDex.PercentageComplete or 0
			if percentage >= 100 then
				color = Theme.COLORS[SCREEN.Colors.positive]
				x = x - 1
			end
			local percText = string.format("%s%%", percentage)
			local percentageX = -1 + Utils.getCenteredTextX(percText, w)
			Drawing.drawText(x + percentageX, y, percText, color, shadowcolor)
		end
	},
	LabelCollectionTotals = {
		getText = function(self) return string.format("%s", "Coll.") end,
		box = { CANVAS.X + 214, CANVAS.Y + 36, 22, 16, },
		isVisible = function(self) return SCREEN.Data.GachaDex ~= nil end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			local numCollected = SCREEN.Data.GachaDex.NumCollected or 0
			local total = SCREEN.Data.GachaDex.TotalDex or 0
			if numCollected >= total then
				color = Theme.COLORS[SCREEN.Colors.positive]
			end
			local numCollectedX = -2 + Utils.getCenteredTextX(tostring(numCollected), w)
			Drawing.drawText(x + numCollectedX, y + 10, numCollected, color, shadowcolor)
			gui.drawLine(x + 3, y + 21, x + 18, y + 21, color)
			local totalX = -2 + Utils.getCenteredTextX(tostring(total), w)
			Drawing.drawText(x + totalX, y + 21, total, color, shadowcolor)
		end,
	},
	LabelSeen = {
		getText = function(self) return string.format("%s", "Seen") end,
		box = { CANVAS.X + 212, CANVAS.Y + 68, 22, 16, },
		isVisible = function(self) return SCREEN.Data.GachaDex ~= nil end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local seen = SCREEN.Data.GachaDex.NumSeen or 0
			local seenX = 0 + Utils.getCenteredTextX(tostring(seen), w)
			Drawing.drawText(x + seenX, y + 10, seen, color, shadowcolor)
		end,
	},


	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 96, 10, 10, },
		isVisible = function() return SCREEN.Data.GachaDex and (SCREEN.Data.GachaDex.totalPages or 0) > 1 end,
		onClick = function(self)
			local G = SCREEN.Data.GachaDex
			if G.totalPages <= 1 then return end
			G.currentPage = ((G.currentPage - 2 + G.totalPages) % G.totalPages) + 1
			Program.redraw(true)
		end,
	},
	CurrentPage = {
		box = { CANVAS.X + 212, CANVAS.Y + 110, 22, 11, },
		isVisible = function() return SCREEN.Data.GachaDex and (SCREEN.Data.GachaDex.totalPages or 0) > 1 end,
		draw = function(self, shadowcolor)
			local G = SCREEN.Data.GachaDex
			if G.totalPages <= 1 then
				return
			end
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local pageText = tostring(G.currentPage or 1)
			local pageTextX = Utils.getCenteredTextX(pageText, w)
			Drawing.drawText(x + pageTextX, y, pageText, color, shadowcolor)
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		box = { CANVAS.X + 220, CANVAS.Y + 127, 10, 10, },
		isVisible = function() return SCREEN.Data.GachaDex and (SCREEN.Data.GachaDex.totalPages or 0) > 1 end,
		onClick = function(self)
			local G = SCREEN.Data.GachaDex
			if G.totalPages <= 1 then return end
			G.currentPage = (G.currentPage % G.totalPages) + 1
			Program.redraw(true)
		end,
	},
}

GachaMonOverlay.Tabs.Battle.Buttons = {
	PlayerGachaMonCard = {
		box = { CANVAS.X + 30, CANVAS.Y + 30, 76, 76, },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw card
			local gachamon = SCREEN.Data.Battle and SCREEN.Data.Battle.PlayerMon or nil
			local card = gachamon and gachamon:getCardDisplayData() or {}
			SCREEN.drawGachaCard(card, x, y, 1)
		end,
	},
	-- TODO: Allow clicking on to temporarily view the GachaMon (dont allow favorite/saving)
	OpponentGachaMonCard = {
		box = { CANVAS.X + 130, CANVAS.Y + 30, 76, 76, },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- Draw card
			local gachamon = SCREEN.Data.Battle and SCREEN.Data.Battle.OpponentMon or nil
			local card = gachamon and gachamon:getCardDisplayData() or {}
			SCREEN.drawGachaCard(card, x, y, 1, false, false)
		end,
	},
	ShareCode = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		getText = function(self) return "Share Code" end,
		box = { CANVAS.X + 23, CANVAS.Y + 123, 82, 16, },
		isVisible = function(self) return SCREEN.Data.Battle and SCREEN.Data.Battle.PlayerMon ~= nil end,
		onClick = function(self)
			local gachamon = SCREEN.Data.Battle.PlayerMon
			if not gachamon then
				return
			end
			SCREEN.openShareCodeWindow(gachamon)
		end,
	},
	ChooseFighter = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.BATTLE_BALLS,
		iconColors = Constants.PixelImages.BATTLE_BALLS.iconColors,
		getText = function(self) return "Choose Fighter" end,
		box = { CANVAS.X + 23, CANVAS.Y + 123, 82, 18, },
		isVisible = function(self) return SCREEN.Data.Battle and SCREEN.Data.Battle.PlayerMon == nil end,
		onClick = function(self)
			local gachamon = SCREEN.Data.Battle.PlayerMon
			if gachamon then
				return
			end
			SCREEN.currentTab = SCREEN.Tabs.Collection
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	AddOpponent = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SWORD_ATTACK,
		iconColors = { SCREEN.Colors.highlight },
		getText = function(self) return "Add Opponent" end,
		box = { CANVAS.X + 123, CANVAS.Y + 123, 82, 18, },
		onClick = function(self)
			local _callbackFunc = function(gachamon)
				SCREEN.Data.Battle.OpponentMon = gachamon
				Program.redraw(true)
			end
			SCREEN.openImportCodeWindow(_callbackFunc)
		end,
	},
}

GachaMonOverlay.Tabs.Options.Buttons = {
	-- Option checkboxes are added later in createTabsAndButtons()

	RatingsRuleset = {
		getText = function(self) return string.format("%s:", "Ruleset used for ratings" or Resources[SCREEN.Key].Label) end,
		box = { CANVAS.X + 3, CANVAS.Y + 7, CANVAS.W - 20, 14, },
		-- draw = function(self, shadowcolor)
		-- 	local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
		-- 	local text = self:getValue()
		-- 	local color = Theme.COLORS[SCREEN.Colors.text]
		-- 	Drawing.drawText(x + 135, y, text, color, shadowcolor)
		-- end,
	},
	EditRatingsRuleset = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.TRIANGLE_DOWN,
		getText = function(self)
			local rulesetKey = GachaMonData.rulesetKey or Options["GachaMon Ratings Ruleset"] or false
			local rulesetName = Constants.IronmonRulesetNames[rulesetKey]
			if rulesetName and GachaMonData.rulesetAutoDetected then
				return string.format("%s (%s)", rulesetName, "Auto")
			else
				return rulesetName or Constants.IronmonRulesetNames.Standard
			end
		end,
		box = { CANVAS.X + 131, CANVAS.Y + 5, 100, 16, },
		onClick = function(self)
			GachaMonOverlay.openEditRulesetWindow()
		end,
	},
	RecentSize = {
		getText = function(self) return string.format(" %s", "GachaMons caught this game" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return SCREEN.Data.Recent and (#SCREEN.Data.Recent.OrderedGachaMons) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 10, CANVAS.Y + 85, CANVAS.W - 20, 14, },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local text = self:getValue()
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			local border = Theme.COLORS[SCREEN.Colors.border]
			gui.drawLine(x + w + 1, y, x + w + 1, y + h, shadowcolor) -- right edge shadow
			gui.drawRectangle(x, y - 1, w, h, border)
			gui.drawLine(x + 150, y, x + 150, y + h - 1, border)
			Drawing.drawNumber(x + 170, y, text, 4, color, shadowcolor)
		end,
	},
	CollectionSize = {
		getText = function(self) return string.format(" %s", "Total GachaMons in collection" or Resources[SCREEN.Key].Label) end,
		getValue = function(self)
			return SCREEN.Data.Collection and (#SCREEN.Data.Collection.OrderedGachaMons) or Constants.BLANKLINE
		end,
		box = { CANVAS.X + 10, CANVAS.Y + 99, CANVAS.W - 20, 14, },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local text = self:getValue()
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			local border = Theme.COLORS[SCREEN.Colors.border]
			gui.drawLine(x + 1, y + h, x + 1 + w, y + h, shadowcolor) -- bottom edge shadow
			gui.drawLine(x + w + 1, y, x + w + 1, y + h, shadowcolor) -- right edge shadow
			gui.drawRectangle(x, y - 1, w, h, border)
			gui.drawLine(x + 150, y, x + 150, y + h - 1, border)
			Drawing.drawNumber(x + 170, y, text, 4, color, shadowcolor)
		end,
	},
	CleanupCollection = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.NOTEPAD,
		iconColors = { SCREEN.Colors.text },
		getText = function(self) return "Cleanup Collection" end,
		box = { CANVAS.X + 135, CANVAS.Y + 122, 96, 16, },
		isVisible = function(self) return #GachaMonData.Collection > 0 end,
		onClick = function(self)
			GachaMonOverlay.openCleanupCollectionWindow()
		end,
	},
}

GachaMonOverlay.Tabs.About.Buttons = {
	Header = {
		box = { CANVAS.X + 3, CANVAS.Y + 2, CANVAS.W - 8, 16, },
		draw = function(self, shadowcolor)
			local x, y, w = self.box[1], self.box[2], self.box[3]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			-- NAME & GENDER
			local headerText = "GachaMon  Collectable  Card  Game"
			if Theme.DRAW_TEXT_SHADOWS then
				Drawing.drawText(x + 4 + 1, y + 1, headerText, shadowcolor, nil, 14)
			end
			Drawing.drawText(x + 4, y, headerText, highlight, nil, 14)
			y = y + Constants.SCREEN.LINESPACING + 7
			-- SLOGAN
			local nameText = "Play IronMON,  collect GachaMon cards!"
			local nameTextX = Utils.getCenteredTextX(nameText, w) - 2
			Drawing.drawText(x + nameTextX, y, nameText, color, shadowcolor)
		end,
	},
	HowItWorks = {
		box = { CANVAS.X + 5, CANVAS.Y + 39, 150, 60, },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			local border = Theme.COLORS[SCREEN.Colors.border]
			local headerText = Utils.toUpperUTF8("How it works")
			local headertW = Utils.calcWordPixelLength(headerText)
			Drawing.drawText(x, y, headerText, highlight, shadowcolor)
			gui.drawLine(x, y + 11, x + headertW + 2, y + 11, border)
			y = y + Constants.SCREEN.LINESPACING + 2
			Drawing.drawText(x, y, string.format("1.  %s", "Catch " .. Resources.AllScreens.Pokemon), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING + 1
			Drawing.drawText(x, y, string.format("2.  %s", "Acquire GachaMon cards"), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING + 1
			Drawing.drawText(x, y, string.format("3.  %s", "Keep cards in your Collection"), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING + 1
			Drawing.drawText(x, y, string.format("4.  %s", "Battle!"), color, shadowcolor)
		end,
	},
	WhatsOnCard = {
		box = { CANVAS.X + 5, CANVAS.Y + 103, 150, 40, },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local color = Theme.COLORS[SCREEN.Colors.text]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			local border = Theme.COLORS[SCREEN.Colors.border]
			local headerText = Utils.toUpperUTF8("What's on a Card")
			local headertW = Utils.calcWordPixelLength(headerText)
			Drawing.drawText(x, y, headerText, highlight, shadowcolor)
			gui.drawLine(x, y + 11, x + headertW + 2, y + 11, border)
			y = y + Constants.SCREEN.LINESPACING + 2
			Drawing.drawText(x, y, string.format("%s  %s  %s", "Stars", Constants.BLANKLINE, "The " .. Resources.AllScreens.Pokemon .. "'s rating"), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING + 1
			Drawing.drawText(x, y, string.format("%s  %s  %s", "Battle Power", Constants.BLANKLINE, "The card's strength"), color, shadowcolor)
			y = y + Constants.SCREEN.LINESPACING + 1
		end,
	},
	SampleGachaMonCard = {
		box = { CANVAS.X + CANVAS.W - 77, CANVAS.Y + 45, 76, 76, },
		gachamon = nil,
		randomizeCard = function(self)
			self.gachamon = GachaMonData.createRandomGachaMon()
		end,
		updateSelf = function(self)
			if not self.gachamon then
				self:randomizeCard()
			end
		end,
		onClick = function(self)
			self:randomizeCard()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local border = Theme.COLORS[SCREEN.Colors.border]
			-- Draw containment border
			gui.drawRectangle(x - 1, y - 1, w + 2, h + 2, border, Drawing.Colors.BLACK)
			gui.drawLine(x, y + h + 2, x + w, y + h + 2, shadowcolor)

			-- Draw card
			local card = self.gachamon and self.gachamon:getCardDisplayData() or {}
			GachaMonOverlay.drawGachaCard(card, x, y, 4, false, false)
		end,
	},
}

local function _getCurrentTabButtons()
	return SCREEN.currentTab and SCREEN.currentTab.Buttons or {}
end

function GachaMonOverlay.initialize()
	SCREEN.shinyFrameCounter = 0
	SCREEN.hasShinyToDraw = false
	SCREEN.createTabsAndButtons()
	SCREEN.currentTab = SCREEN.Tabs.Recent

	for _, tab in pairs(SCREEN.Tabs) do
		for _, button in pairs(tab.Buttons or {}) do
			if button.textColor == nil then
				button.textColor = SCREEN.Colors.text
			end
			if button.boxColors == nil then
				button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
			end
		end
	end
end

function GachaMonOverlay.refreshButtons()
	for _, button in pairs(SCREEN.TabButtons) do
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

function GachaMonOverlay.createTabsAndButtons()
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
		local perRow = (SCREEN.GACHAMONS_PER_PAGE / 2)
		local xOffset = W * ((i - 1) % perRow)
		local yOffset = (H + 1) * (math.ceil(i / perRow) - 1)
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
				SCREEN.Data.View.GachaMon = SCREEN.getMonForRecentScreenSlot(self.slotNumber)
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
				SCREEN.Data.View.GachaMon = SCREEN.getMonForCollectionScreenSlot(self.slotNumber)
				SCREEN.currentTab = SCREEN.Tabs.View
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
	end

	-- GachaDex Card Buttons
	W, H = 35, 35
	for i = 1, 24, 1 do
		local btnLabel = string.format("GachaMon%s", i)
		local perRow = SCREEN.MINIMONS_PER_PAGE / 4
		local xOffset = W * ((i - 1) % perRow)
		local yOffset = H * (math.ceil(i / perRow) - 1)
		GachaMonOverlay.Tabs.GachaDex.Buttons[btnLabel] = {
			slotNumber = i,
			box = { CANVAS.X + 2 + xOffset, CANVAS.Y + 2 + yOffset, W, H, },
			isVisible = function(self) return SCREEN.getMonForGachaDexScreenSlot(self.slotNumber) ~= nil end,
			onClick = function(self)
				local dexData = SCREEN.getMonForGachaDexScreenSlot(self.slotNumber)
				if not dexData then return end
				if dexData.collected then
					SCREEN.Data.Collection.FilterFunc = function(gachamon)
						return dexData.pokemonID == gachamon.PokemonId
					end
					SCREEN.Data.Collection.SortFunc = SCREEN.SortFuncs.DefaultCollectionSort
					SCREEN.buildCollectionData()
					SCREEN.currentTab = SCREEN.Tabs.Collection
					SCREEN.refreshButtons()
					Program.redraw(true)
				elseif PokemonData.isValid(dexData.pokemonID) then
					if dexData.seen or dexData.collected or SCREEN.Data.GachaDex.ShowAllSeenIcons then
						SCREEN.Data.GachaDex.TempShowPokemon = nil
					else
						local isSelected = SCREEN.Data.GachaDex.TempShowPokemon and SCREEN.Data.GachaDex.TempShowPokemon == dexData.pokemonID
						if isSelected then
							SCREEN.Data.GachaDex.TempShowPokemon = nil
						else
							SCREEN.Data.GachaDex.TempShowPokemon = dexData.pokemonID
						end
					end
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, dexData.pokemonID)
				end
			end,
			draw = function(self, shadowcolor)
				local dexData = SCREEN.getMonForGachaDexScreenSlot(self.slotNumber)
				if not dexData then return end
				local x, y = self.box[1], self.box[2]
				local isSelected = SCREEN.Data.GachaDex.TempShowPokemon and SCREEN.Data.GachaDex.TempShowPokemon == dexData.pokemonID

				local canSee = dexData.seen or isSelected or SCREEN.Data.GachaDex.ShowAllSeenIcons
				GachaMonOverlay.drawMiniGachaCard(dexData.pokemonID, x, y, dexData.type1, dexData.type2, canSee, dexData.collected)

				-- If not collected or seen (no image), draw the Pokémon species number
				if not SCREEN.Data.GachaDex.ShowAllSeenIcons and not (canSee or dexData.collected) then
					local idText = tostring(dexData.pokemonID or Constants.HIDDEN_INFO)
					local idTextW = -3 + Utils.getCenteredTextX(idText, W)
					Drawing.drawText(x + idTextW, y + 11, idText, Drawing.Colors.WHITE, nil, 11)
				end

				if isSelected then
					local bg = Drawing.Colors.BLACK
					local border = Drawing.Colors.WHITE
					gui.drawRectangle(x + 24, y, 9, 9, bg, bg)
					Drawing.drawSelectionIndicators(x + 1, y + 1, W - 3, H - 3, border, 1, 6, 0)
				end
			end,
		}
	end

	-- CREATE OPTIONS CHECKBOXES
	startX = CANVAS.X + 5
	startY = CANVAS.Y + 30
	local optionKeyMap = {
		{ "Show GachaMon stars on main Tracker Screen", "OptionShowGachaMonStarsOnTracker", },
		{ "Show card pack on screen after capturing a GachaMon", "OptionShowCardPackOnScreen", },
		{ "Animate GachaMon pack opening", "OptionAnimateGachaMonPackOpening", },
		{ "Add GachaMon to collection after defeating a trainer", "OptionAutoAddGachaMonToCollection", },
	}
	for _, optionTuple in ipairs(optionKeyMap) do
		local textWidth = Utils.calcWordPixelLength(" " .. Resources[SCREEN.Key][optionTuple[2]])
		textWidth = math.max(textWidth, 50) -- minimum 50 pixels
		SCREEN.Tabs.Options.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return " " .. Resources[SCREEN.Key][optionTuple[2]] end,
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
	SCREEN.Data = {
		Recent = {},
		Collection = {},
		View = {},
		GachaDex = {},
		Battle = {},
		Options = {},
		About = {},
	}

	SCREEN.buildRecentData()
	SCREEN.buildCollectionData()
	SCREEN.buildGachaDexData()
	-- TODO: build battle

	SCREEN.Data.View.GachaMon = GachaMonData.newestRecentMon

	-- Create the display card for the lead pokemon
	if not SCREEN.Data.View.GachaMon then
		local leadPokemon = TrackerAPI.getPlayerPokemon(1)
		if leadPokemon and GachaMonData.tryAddToRecentMons(leadPokemon) then
			SCREEN.Data.View.GachaMon = GachaMonData.getAssociatedRecentMon(leadPokemon)
		end
	end

	if not SCREEN.Data.View.GachaMon then
		SCREEN.Data.View.GachaMon = SCREEN.Data.Recent.OrderedGachaMons[1]
	end

	SCREEN.Tabs.About.Buttons.SampleGachaMonCard:randomizeCard()
end

---Builds the data tables necessary for the tabs to diplsay the cards in the Recent caught GachaMons
function GachaMonOverlay.buildRecentData()
	if not SCREEN.Data or not SCREEN.Data.Recent then
		return
	end
	local filterFunc = type(SCREEN.Data.Recent.FilterFunc) == "function" and SCREEN.Data.Recent.FilterFunc or nil
	local sortFunc = type(SCREEN.Data.Recent.SortFunc) == "function" and SCREEN.Data.Recent.SortFunc
		or SCREEN.SortFuncs.DefaultRecentSort

	SCREEN.Data.Recent.OrderedGachaMons = {}
	for _, gachamon in pairs(GachaMonData.RecentMons or {}) do
		if filterFunc == nil or filterFunc(gachamon) then
			table.insert(SCREEN.Data.Recent.OrderedGachaMons, gachamon)
		end
	end

	table.sort(SCREEN.Data.Recent.OrderedGachaMons, sortFunc)
	SCREEN.Data.Recent.currentPage = 1
	SCREEN.Data.Recent.totalPages = math.ceil(#SCREEN.Data.Recent.OrderedGachaMons / SCREEN.GACHAMONS_PER_PAGE)
end

---Builds the data tables necessary for the tabs to diplsay the cards in the collection
function GachaMonOverlay.buildCollectionData()
	if not SCREEN.Data or not SCREEN.Data.Collection then
		return
	end
	local filterFunc = type(SCREEN.Data.Collection.FilterFunc) == "function" and SCREEN.Data.Collection.FilterFunc or nil
	local sortFunc = type(SCREEN.Data.Collection.SortFunc) == "function" and SCREEN.Data.Collection.SortFunc
		or SCREEN.SortFuncs.DefaultCollectionSort

	SCREEN.Data.Collection.OrderedGachaMons = {}
	for _, gachamon in ipairs(GachaMonData.Collection or {}) do
		if filterFunc == nil or filterFunc(gachamon) then
			table.insert(SCREEN.Data.Collection.OrderedGachaMons, gachamon)
		end
	end

	table.sort(SCREEN.Data.Collection.OrderedGachaMons, sortFunc)
	SCREEN.Data.Collection.currentPage = 1
	SCREEN.Data.Collection.totalPages = math.ceil(#SCREEN.Data.Collection.OrderedGachaMons / SCREEN.GACHAMONS_PER_PAGE)

	if not SCREEN.Data.View.GachaMon then
		SCREEN.Data.View.GachaMon = SCREEN.Data.Collection.OrderedGachaMons[1]
	end
end

function GachaMonOverlay.buildGachaDexData()
	if not SCREEN.Data or not SCREEN.Data.GachaDex then
		return
	end

	SCREEN.Data.GachaDex.ShowAllSeenIcons = nil
	SCREEN.Data.GachaDex.TempShowPokemon = nil

	-- local filterFunc = type(SCREEN.Data.GachaDex.FilterFunc) == "function" and SCREEN.Data.GachaDex.FilterFunc or nil
	-- local sortFunc = type(SCREEN.Data.GachaDex.SortFunc) == "function" and SCREEN.Data.GachaDex.SortFunc
	-- 	or SCREEN.SortFuncs.DefaultGachaDexSort

	local _createDexData = function(id)
		local pokemonInternal = PokemonData.Pokemon[id] or PokemonData.BlankPokemon
		local pokemonTypes = pokemonInternal.types or {}
		local hasSeen = GachaMonData.DexData.SeenMons[id]
		local dexData = {
			pokemonID = id,
			seen = hasSeen,
			collected = false,
			type1 = pokemonTypes[1],
			type2 = pokemonTypes[2],
		}
		return dexData
	end

	SCREEN.Data.GachaDex.OrderedDexMons = {}
	SCREEN.Data.GachaDex.NumSeen = 0
	for id = 1, PokemonData.getTotal(), 1 do
		local validId = (id < 252 or id > 276)
		if validId then
			local dexData = _createDexData(id)
			if dexData.seen then
				SCREEN.Data.GachaDex.NumSeen = SCREEN.Data.GachaDex.NumSeen + 1
			end
			table.insert(SCREEN.Data.GachaDex.OrderedDexMons, dexData)
		end
	end

	SCREEN.Data.GachaDex.NumCollected = 0
	for _, gachamon in ipairs(GachaMonData.Collection or {}) do
		local index = gachamon.PokemonId > 276 and gachamon.PokemonId - 25 or gachamon.PokemonId
		local dexData = SCREEN.Data.GachaDex.OrderedDexMons[index]
		if dexData then
			if not dexData.collected then
				dexData.collected = true
				SCREEN.Data.GachaDex.NumCollected = SCREEN.Data.GachaDex.NumCollected + 1
			end
			if not dexData.seen then
				dexData.seen = true
				SCREEN.Data.GachaDex.NumSeen = SCREEN.Data.GachaDex.NumSeen + 1
				if not GachaMonData.DexData.SeenMons[gachamon.PokemonId] then
					GachaMonData.DexData.SeenMons[gachamon.PokemonId] = true
				end
			end
		end
	end
	-- Check through Recent Mons for those flagged to be added to collection
	for _, gachamon in pairs(GachaMonData.RecentMons or {}) do
		local index = gachamon.PokemonId > 276 and gachamon.PokemonId - 25 or gachamon.PokemonId
		local dexData = SCREEN.Data.GachaDex.OrderedDexMons[index]
		if dexData and gachamon:getKeep() == 1 then
			if not dexData.collected then
				dexData.collected = true
				SCREEN.Data.GachaDex.NumCollected = SCREEN.Data.GachaDex.NumCollected + 1
			end
			if not dexData.seen then
				dexData.seen = true
				SCREEN.Data.GachaDex.NumSeen = SCREEN.Data.GachaDex.NumSeen + 1
				if not GachaMonData.DexData.SeenMons[gachamon.PokemonId] then
					GachaMonData.DexData.SeenMons[gachamon.PokemonId] = true
				end
			end
		end
	end

	-- table.sort(SCREEN.Data.GachaDex.OrderedDexMons, sortFunc)
	SCREEN.Data.GachaDex.PercentageComplete = 0
	SCREEN.Data.GachaDex.TotalDex = PokemonData.getTotal() - 25 -- exclude the 25 fake mons for percentage calcs

	if SCREEN.Data.GachaDex.TotalDex > 0 then
		local percentage = math.floor(SCREEN.Data.GachaDex.NumCollected / SCREEN.Data.GachaDex.TotalDex * 100)
		SCREEN.Data.GachaDex.PercentageComplete = math.min(percentage, 100) -- max
	end

	-- Update GachaDex info and stats, then save
	GachaMonData.DexData.NumCollected = SCREEN.Data.GachaDex.NumCollected
	GachaMonData.DexData.NumSeen = SCREEN.Data.GachaDex.NumSeen
	GachaMonData.DexData.PercentageComplete = SCREEN.Data.GachaDex.PercentageComplete
	GachaMonFileManager.saveGachaDexInfoToFile()

	SCREEN.Data.GachaDex.currentPage = 1
	SCREEN.Data.GachaDex.totalPages = math.ceil(SCREEN.Data.GachaDex.TotalDex / SCREEN.MINIMONS_PER_PAGE)
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

function GachaMonOverlay.getMonForGachaDexScreenSlot(slotNumber)
	local D = SCREEN.Data.GachaDex or {}
	local pageIndex = (D.currentPage or 0) - 1
	local index = pageIndex * SCREEN.MINIMONS_PER_PAGE + slotNumber
	-- local pokemonID = index > 276 and (index - 25) or index
	return D.OrderedDexMons and D.OrderedDexMons[index] or nil
end

function GachaMonOverlay.tryLoadCollection()
	if GachaMonData.initialCollectionLoaded then
		return
	end
	GachaMonData.initialCollectionLoaded = true
	GachaMonFileManager.importCollection()
	GachaMonData.checkForNatDexRequirement()
end

---Opens a form popup displaying a Gachamon's shareable code (base-64 string)
---@param gachamon IGachaMon
function GachaMonOverlay.openShareCodeWindow(gachamon)
	local shareCode = gachamon and GachaMonData.getShareablyCode(gachamon) or "N/A"
	local form = ExternalUI.BizForms.createForm("GachaMon Share Code", 450, 160)
	form:createLabel("Show off your GachaMon by sharing this code.", 19, 10)
	form:createLabel(string.format("%s:", "Copy the shareable code below with Ctrl+C"), 19, 30)
	form:createTextBox(shareCode, 20, 55, 400, 22, nil, false, true)
	form:createButton(Resources.AllScreens.Close, 200, 85, function()
		form:destroy()
	end, 80, 25)
end

-- TODO: Merge the above into this popup, similar to Randomizer's Setting Strings
---Opens a form popup for importing a Gachamon's shareable code (base-64 string)
---@param onImportFunc? function
function GachaMonOverlay.openImportCodeWindow(onImportFunc)
	local form = ExternalUI.BizForms.createForm("GachaMon Import Code", 450, 160)
	form:createLabel("Battle against someone else's GachaMon by importing its Share Code here.", 19, 10)
	form:createLabel(string.format("%s:", "Paste the code below Ctrl+V"), 19, 30)
	form.Controls.code = form:createTextBox("", 20, 55, 400, 22, nil, false, true)
	form:createButton(Resources.AllScreens.Import, 80, 85, function()
		local b64string = ExternalUI.BizForms.getText(form.Controls.code) or ""
		-- Trim whitespace
		b64string = b64string:match("^%s*(.-)%s*$") or ""
		local gachamon = GachaMonData.transformCodeIntoGachaMon(b64string)
		if gachamon then
			gachamon.Favorite = 0
			-- TODO: remove attributes like "Favorite"
		end
		if type(onImportFunc) == "function" then
			onImportFunc(gachamon)
		end
		form:destroy()
	end, 80, 25)
	form:createButton(Resources.AllScreens.Close, 200, 85, function()
		form:destroy()
	end, 80, 25)
end

function GachaMonOverlay.openEditRulesetWindow()
	local form = ExternalUI.BizForms.createForm("Ratings Ruleset for GachaMon", 345, 170)
	local x = 15
	local iY = 15

	local rulesetNamesOrdered = {
		Constants.IronmonRulesetNames.Standard,
		Constants.IronmonRulesetNames.Ultimate,
		Constants.IronmonRulesetNames.Kaizo,
		Constants.IronmonRulesetNames.Survival,
		Constants.IronmonRulesetNames.SuperKaizo,
		Constants.IronmonRulesetNames.Subpar,
	}
	if CustomCode.RomHacks.isPlayingNatDex() then
		table.insert(rulesetNamesOrdered, Constants.IronmonRulesetNames.Ascension1)
		table.insert(rulesetNamesOrdered, Constants.IronmonRulesetNames.Ascension2)
		table.insert(rulesetNamesOrdered, Constants.IronmonRulesetNames.Ascension3)
	end

	local _refreshAutoDetect = function()
		local isChecked = form.Controls.checkboxAutoDetect and ExternalUI.BizForms.isChecked(form.Controls.checkboxAutoDetect) or false
		if form.Controls.dropdownRulesetNames then
			ExternalUI.BizForms.setProperty(form.Controls.dropdownRulesetNames, ExternalUI.BizForms.Properties.ENABLED, isChecked == false)
		end
	end

	form:createLabel("Select which ruleset is used for calculating ratings/stars:", x, iY)
	iY = iY + 22
	local startChecked = GachaMonData.rulesetAutoDetected == true
	form.Controls.checkboxAutoDetect = form:createCheckbox("Auto-detect ruleset from New Run profile settings", x + 16, iY, _refreshAutoDetect, startChecked)
	iY = iY + 25
	form:createLabel("Ruleset options:", x + 14, iY + 3)
	local startingRulesetName = Constants.IronmonRulesetNames[Options["GachaMon Ratings Ruleset"] or false]
	if not startingRulesetName or startingRulesetName == "AutoDetect" then
		startingRulesetName = rulesetNamesOrdered[1]
	end
	form.Controls.dropdownRulesetNames = form:createDropdown(rulesetNamesOrdered, x + 116, iY, 150, 30, startingRulesetName or "", false)
	_refreshAutoDetect()
	iY = iY + 35

	form:createButton(Resources.AllScreens.Save, 70, iY, function()
		GachaMonData.rulesetAutoDetected = ExternalUI.BizForms.isChecked(form.Controls.checkboxAutoDetect)
		if GachaMonData.rulesetAutoDetected then
			Options["GachaMon Ratings Ruleset"] = "AutoDetect"
			GachaMonData.autoDetermineIronmonRuleset()
		else
			local selectedRulesetName = ExternalUI.BizForms.getText(form.Controls.dropdownRulesetNames)
			local rulesetKey = nil
			-- Search for a matching ruleset key based on dropdown selection
			for key, name in pairs(Constants.IronmonRulesetNames or {}) do
				if name == selectedRulesetName then
					rulesetKey = key
					break
				end
			end
			if not Utils.isNilOrEmpty(rulesetKey) then
				Options["GachaMon Ratings Ruleset"] = rulesetKey
				GachaMonData.rulesetKey = rulesetKey
			end
		end
		Main.SaveSettings(true)
		Program.redraw(true)
		form:destroy()
	end, 80, 25)
	form:createButton(Resources.AllScreens.Cancel, 180, iY, function()
		form:destroy()
	end, 80, 25)
end

---Draws GachaMon stars at the specified location. Use `initialStars` to show growth/decay of a change in star count
---@param numStars number
---@param x number
---@param y number
---@param initialStars? number The original amount of stars to compare to the new star value. New stars have a different color, missing stars are hollow
function GachaMonOverlay.drawStarsOfGachaMon(numStars, x, y, initialStars)
	if numStars < 1 then
		return
	end
	if initialStars and initialStars < 1 then
		initialStars = nil
	end
	local numToDraw = math.max(initialStars or 0, numStars) -- use whichever is larger
	local needsTwoLines = (numToDraw >= 5)
	local icon = Constants.PixelImages.STAR
	local iconColors = icon:getColors() -- yellow
	local newStarColors = icon:getNewStarColors() -- orange (new)
	local emptyStarColors = icon:getEmptyStarColors() -- faded (missing)
	local iconSize = 9
	-- Use Platinum colors for highest rarity (5+ stars)
	if numToDraw > 5 then
		iconColors[1] = 0xFFEEEEEE
		iconColors[2] = 0xFFCCCCCC
		numToDraw = 5
	end
	if numToDraw == 5 then
		iconSize = iconSize + 1
	end
	if needsTwoLines then
		x = x + 3
	end
	-- Draw the stars
	for i = 1, numToDraw, 1 do
		local iX = x + 1 + iconSize * (i - 1)
		local iY = y + 1
		local colors = iconColors
		if initialStars then
			-- Gained these new stars
			if i > initialStars and i <= numStars then
				colors = newStarColors
			-- Lost some stars
			elseif i > numStars and i <= initialStars then
				colors = emptyStarColors
			end
		end
		-- Normally draw 1 to 4 stars horizontally, unless its a 5-star, then do a 3/2 split
		if i >= 4 and needsTwoLines then
			iX = iX + 5 - 3 * iconSize
			iY = iY + iconSize - 4
		end
		Drawing.drawImageAsPixels(icon, iX, iY, colors)
	end
end

---Draws the card representing a GachaMon, including any speciel effects like shiny sparkles.
---@param card table
---@param borderPadding? number Optional, defaults to 3 pixel border padding
---@param showFavoriteOverride? boolean Optional, displays the heart (empty or full); default: only if actually favorited
---@param showCollectionOverride? boolean Optional, displays the checkmark (empty or full); default: never shows
function GachaMonOverlay.drawGachaCard(card, x, y, borderPadding, showFavoriteOverride, showCollectionOverride)
	card = card or {}
	borderPadding = borderPadding or 3
	local numStars = card.Stars or 0
	local W, H, TOP_W, TOP_H, BOT_H = 68, 68, 40, 10, 15
	local COLORS = {
		bg = Drawing.Colors.BLACK,
		-- border = Drawing.Colors.WHITE,
		border1 = card.FrameColors and card.FrameColors[1] or Drawing.Colors.WHITE,
		border2 = card.FrameColors and card.FrameColors[2] or Drawing.Colors.WHITE,
		shiny = Drawing.Colors.WHITE - Drawing.ColorEffects.DARKEN,
		shiny2 = Drawing.Colors.WHITE - (Drawing.ColorEffects.DARKEN * 3),
		shiny3 = Drawing.Colors.WHITE - (Drawing.ColorEffects.DARKEN * 5),
		power = Drawing.Colors.WHITE,
		checkmark = Drawing.Colors.GREEN,
		text = 0xFFFCED86 or Drawing.Colors.YELLOW - Drawing.ColorEffects.DARKEN,
		name = Drawing.Colors.WHITE,
		shadow = Drawing.ColorEffects.DARKEN * 3,
	}
	COLORS.bg1 = COLORS.border1 - 0xD0000000
	COLORS.bg2 = COLORS.border2 - 0xD0000000
	COLORS.bg1bot = COLORS.border1 - 0xB9000000
	COLORS.bg2bot = COLORS.border2 - 0xB9000000

	-- BLACK BACKGROUND
	gui.drawRectangle(x, y, W + borderPadding * 2, H + borderPadding * 2, COLORS.bg, COLORS.bg)
	x = x + borderPadding
	y = y + borderPadding

	-- CARD BACKGROUND
	-- This is the "im mad and just want it to work, sorry future me/ anyone else" section of the code
	gui.drawRectangle(x+1, y+1, W/2-1, H-2-BOT_H, COLORS.bg1, COLORS.bg1)
	gui.drawRectangle(x+1+W/2, y+2, 7, 8, COLORS.bg2, COLORS.bg2)
	gui.drawRectangle(x+1+W/2, y+1+TOP_H, W/2-2, H-TOP_H-2-BOT_H, COLORS.bg2, COLORS.bg2)
	gui.drawPixel(x+W/2+8, y+2, COLORS.bg)
	gui.drawPixel(x+W/2+9, y+TOP_H, COLORS.bg2)
	gui.drawRectangle(x+1, y+1+H-BOT_H, W/2-1, BOT_H-2, COLORS.bg1bot, COLORS.bg1bot)
	gui.drawRectangle(x+1+W/2, y+1+H-BOT_H, W/2-2, BOT_H-2, COLORS.bg2bot, COLORS.bg2bot)

	-- STARS
	GachaMonOverlay.drawStarsOfGachaMon(numStars, x, y)

	-- CARD FRAME
	-- left-half
	gui.drawLine(x+1, y+1, x+1+TOP_W-7, y+1, COLORS.border1)
	gui.drawLine(x+1, y+1, x+1, y+H-1, COLORS.border1)
	gui.drawLine(x+1, y+H-1, x+W/2, y+H-1, COLORS.border1)
	local botBarY = y+H-BOT_H
	local angleW = 4
	gui.drawLine(x+1, botBarY, x+W/2, botBarY, COLORS.border1)
	gui.drawLine(x+W/2+1, botBarY, x+W-1, botBarY, COLORS.border2)
	gui.drawLine(x+TOP_W, y+1, x+TOP_W+angleW, y+1+TOP_H, COLORS.border2)
	gui.drawLine(x+TOP_W+1, y+1, x+TOP_W+1+angleW, y+1+TOP_H, COLORS.border2)
	-- right-half
	gui.drawLine(x+1+TOP_W-6, y+1, x+1+TOP_W, y+1, COLORS.border2)
	gui.drawLine(x+1+TOP_W+angleW, y+1+TOP_H, x+W-1, y+1+TOP_H, COLORS.border2)
	gui.drawLine(x+W-1, y+H-1, x+W-1, y+1+TOP_H, COLORS.border2)
	gui.drawLine(x+W/2+1, y+H-1, x+W-1, y+H-1, COLORS.border2)

	-- POWER
	if card.BattlePower and card.BattlePower >= 0 then
		local powerRightAlign = 3 + Utils.calcWordPixelLength(tostring(card.BattlePower))
		if card.BattlePower > 9999 then
			powerRightAlign = powerRightAlign - 1
		end
		Drawing.drawText(x + W - powerRightAlign, y, card.BattlePower or Constants.BLANKLINE, COLORS.power)
	end

	-- POKEMON ICON
	local pX, pY = (x + W / 2 - 16), (y + 8)
	GachaMonOverlay.drawPokemonIcon(card.PokemonId, pX, pY)

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
	local abilityName = Constants.BLANKLINE
	if AbilityData.isValid(card.AbilityId) then
		abilityName = AbilityData.Abilities[card.AbilityId].name
	end
	local abilityX = Utils.getCenteredTextX(abilityName, W) - 1
	Drawing.drawText(x + abilityX + 1, y + H - 26, abilityName, COLORS.shadow)
	Drawing.drawText(x + abilityX, y + H - 27, abilityName, COLORS.text)

	-- NAME TEXT
	local monName = Constants.BLANKLINE
	if PokemonData.isValid(card.PokemonId) or (GachaMonData.requiresNatDex and (card.PokemonId or 0) > 412) then
		monName = PokemonData.Pokemon[card.PokemonId].name
	end
	local monX = Utils.getCenteredTextX(monName, W) - 1
	Drawing.drawText(x + monX + 1, y + H - 13, monName, COLORS.shadow)
	Drawing.drawText(x + monX, y + H - 14, monName, COLORS.name)

	-- STAT BARS
	if type(card.StatBars) == "table" then
		for i, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local statY = botBarY + 2 * i
			local statW = card.StatBars[statKey] or 0
			gui.drawLine(x+1, statY, x+1+statW, statY, COLORS.border1)
			gui.drawLine(x+W-1-statW, statY, x+W-1, statY, COLORS.border2)
		end
	end

	-- SHINY
	if card.IsShiny then
		if not card.ShinyAnimations then
			card.ShinyAnimations = AnimationManager.createGachaMonShinySparkles(x, y, 15)
		end
		for _, shinyAnim in pairs(card.ShinyAnimations or {}) do
			-- Since it still needs to be drawn, reactivate the animation if it became inactive
			if not shinyAnim.IsActive then
				AnimationManager.tryAddAnimationToActive(shinyAnim)
			end
			-- If the card moved around, update it's associated animation locations
			if shinyAnim.X ~= x or shinyAnim.Y ~= y then
				shinyAnim.X = x
				shinyAnim.Y = y
			end
			AnimationManager.drawAnimation(shinyAnim)
		end
	end
end

---Draws a miniature card representing a GachaMon.
---@param pokemonID number
---@param x number
---@param y number
---@param type1 string
---@param type2 string
---@param seen boolean
---@param collected boolean
function GachaMonOverlay.drawMiniGachaCard(pokemonID, x, y, type1, type2, seen, collected)
	type1 = type1 or PokemonData.Types.UNKNOWN
	type2 = type2 or type1

	local W, H, TOP_W, TOP_H = 34, 34, 23, 5
	local frameColor1 = Constants.MoveTypeColors[type1] or Constants.MoveTypeColors.unknown
	local frameColor2 = Constants.MoveTypeColors[type2 or false] or frameColor1

	local COLORS = {
		bg = Drawing.Colors.BLACK,
		border1 = frameColor1 or Drawing.Colors.WHITE,
		border2 = frameColor2 or Drawing.Colors.WHITE,
		darken = Drawing.ColorEffects.DARKEN * 3,
	}

	-- BLACK BACKGROUND
	gui.drawRectangle(x, y, W, H, COLORS.bg, COLORS.bg)

	-- CARD FRAME
	if not seen or collected then
		-- left-half
		gui.drawLine(x+1, y+1, x+1+TOP_W-7, y+1, COLORS.border1)
		gui.drawLine(x+1, y+1, x+1, y+H-1, COLORS.border1)
		gui.drawLine(x+1, y+H-1, x+W/2, y+H-1, COLORS.border1)
		-- local botBarY = y+H-BOT_H
		local angleW = 2 or 4
		gui.drawLine(x+TOP_W, y+1, x+TOP_W+angleW, y+1+TOP_H, COLORS.border2)
		gui.drawLine(x+TOP_W+1, y+1, x+TOP_W+1+angleW, y+1+TOP_H, COLORS.border2)
		-- right-half
		gui.drawLine(x+1+TOP_W-6, y+1, x+1+TOP_W, y+1, COLORS.border2)
		gui.drawLine(x+1+TOP_W+angleW, y+1+TOP_H, x+W-1, y+1+TOP_H, COLORS.border2)
		gui.drawLine(x+W-1, y+H-1, x+W-1, y+1+TOP_H, COLORS.border2)
		gui.drawLine(x+W/2+1, y+H-1, x+W-1, y+H-1, COLORS.border2)
	end

	-- TINY POKEBALL
	local bIcon = Constants.PixelImages.POKEBALL_SMALL
	local bX, bY = x + 25, y
	if collected then
		gui.drawRectangle(bX - 1, bY, 9, 9, COLORS.bg, COLORS.bg)
		gui.drawPixel(bX - 2, bY + 2, COLORS.bg)
		local bColors = TrackerScreen.PokeBalls.ColorList
		Drawing.drawImageAsPixels(bIcon, bX, bY, bColors)
	elseif seen and not collected then
		local bColors = { Drawing.Colors.WHITE }
		bY = bY + 1
		Drawing.drawImageAsPixels(bIcon, bX, bY, bColors)
	end

	-- POKEMON ICON (ALWAYS GEN7+ ICONSET)
	if seen or collected then
		local pX, pY = x + 1, y + 1
		local pW, pH = 32, 32
		local pokemonImageId = pokemonID
		local imagePath = Drawing.getImagePath("GachaDexPokemonIcon", tostring(pokemonImageId))
		-- If not a valid image id and also not a nat dex id, use question mark image
		if GachaMonData.requiresNatDex and (pokemonID or 0) >= 412 then
			imagePath = Drawing.getImagePath("PokemonIcon", tostring(pokemonImageId))
		elseif not PokemonData.isImageIDValid(pokemonImageId) then
			-- Question mark icon
			pokemonImageId = 252
		end
		if imagePath then
			Drawing.drawImage(imagePath, pX, pY, pW, pH)
		end
	end

	-- FADE EFFECT
	if seen and not collected then
		gui.drawRectangle(x, y, W, H, COLORS.darken, COLORS.darken)
	end

	-- SHINY
	-- if card.IsShiny then
	-- end
end

---Draw's the appropriate Pokémon Image Icon, using Nat Dex icon if necessary
---@param pokemonID number
---@param pX number
---@param pY number
---@param useNatDexIcon? boolean Optional, if true will always use the Nat. Dex icon set
function GachaMonOverlay.drawPokemonIcon(pokemonID, pX, pY, useNatDexIcon)
	local pW, pH = 32, 32
	local pokemonImageId = pokemonID
	local animationOn = true -- If left nil, will use default animation sprite; just turn it off for Nat. Dex
	-- If drawing a Nat. Dex. Pokémon and not using the IconSet used by Nat. Dex., then adjust the x/y offsets
	if useNatDexIcon or (GachaMonData.requiresNatDex and (pokemonID or 0) >= 412) then
		animationOn = false
		local iconset = Options.getIconSet()
		local natdexIconSet = Options.IconSetMap[3]
		if iconset and iconset ~= natdexIconSet then
			pX = pX - (iconset.xOffset or 0) + (natdexIconSet.xOffset or 0)
			pY = pY - (iconset.yOffset or 0) + (natdexIconSet.yOffset or 0)
		end
	elseif not PokemonData.isImageIDValid(pokemonImageId) then
		-- Question mark icon
		pokemonImageId = 252
	end
	-- Duplicate draw pokemon icon code to bypass limitations for drawing Nat. Dex mons
	local iconset = Options.getIconSet()
	pX = pX + (iconset.xOffset or 0)
	pY = pY + (iconset.yOffset or 0)
	if iconset.isAnimated and animationOn then
		Drawing.drawSpriteIcon(pX, pY, pokemonImageId, SpriteData.Types.Idle)
	else
		local imagePath = Drawing.getImagePath("PokemonIcon", tostring(pokemonImageId))
		if imagePath then
			Drawing.drawImage(imagePath, pX, pY, pW, pH)
		end
	end
end

-- OVERLAY OPEN
function GachaMonOverlay.open()
	SCREEN.hasShinyToDraw = false
	SCREEN.shinyFrameCounter = 0
	LogSearchScreen.clearSearch()
	SCREEN.tryLoadCollection()
	SCREEN.buildData()
	if SCREEN.Data.Recent.totalPages == 0 and SCREEN.Data.Collection.totalPages == 0 then
		SCREEN.currentTab = SCREEN.Tabs.About
	else
		SCREEN.currentTab = SCREEN.Tabs.Recent
	end
	SCREEN.refreshButtons()
end

-- OVERLAY CLOSE
function GachaMonOverlay.close()
	SCREEN.hasShinyToDraw = false
	LogSearchScreen.clearSearch()
	GachaMonFileManager.trySaveCollectionOnClose()
	if SCREEN.Data then
		SCREEN.Data.View.GachaMon = nil
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
	elseif Program.currentScreen == InfoScreen then
		Program.currentScreen = TrackerScreen
	end
end

-- USER INPUT FUNCTIONS
function SCREEN.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.TabButtons)
	Input.checkButtonsClicked(xmouse, ymouse, _getCurrentTabButtons())
end

function SCREEN.checkWheelInput(wheelChange)
	local buttons = _getCurrentTabButtons() or {}
	if buttons.NextPage and wheelChange <= -Input.MOUSE_SCROLL_THRESHOLD then
		buttons.NextPage:onClick()
	elseif buttons.PrevPage and wheelChange > Input.MOUSE_SCROLL_THRESHOLD then
		buttons.PrevPage:onClick()
	end
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

	if SCREEN.currentTab == SCREEN.Tabs.Recent or SCREEN.currentTab == SCREEN.Tabs.Collection then
		-- Draw solid black background for all the cards to be layed out on to
		gui.drawRectangle(canvas.x + 1, canvas.y + 1, 210, 141, Drawing.Colors.BLACK, Drawing.Colors.BLACK)
		gui.drawLine(canvas.x + 212, canvas.y + 1, canvas.x + 212, canvas.y + 142, canvas.border)
		gui.drawLine(canvas.x + 213, canvas.y + 20, canvas.x + canvas.width - 1, canvas.y + 20, canvas.border)
		gui.drawLine(canvas.x + 213, canvas.y + 90, canvas.x + canvas.width - 1, canvas.y + 90, canvas.border)
	elseif SCREEN.currentTab == SCREEN.Tabs.GachaDex then
		-- Draw solid black background for all the cards to be layed out on to
		gui.drawRectangle(canvas.x + 1, canvas.y + 1, 210, 141, Drawing.Colors.BLACK, Drawing.Colors.BLACK)
		gui.drawLine(canvas.x + 212, canvas.y + 1, canvas.x + 212, canvas.y + 142, canvas.border)
		gui.drawLine(canvas.x + 213, canvas.y + 35, canvas.x + canvas.width - 1, canvas.y + 35, canvas.border)
		gui.drawLine(canvas.x + 213, canvas.y + 90, canvas.x + canvas.width - 1, canvas.y + 90, canvas.border)

	elseif SCREEN.currentTab == SCREEN.Tabs.Battle then
		-- Draw battleground background
		gui.drawRectangle(canvas.x + 20, canvas.y + 20, 198, 98, canvas.border, Drawing.Colors.BLACK)
		-- TODO: Draw a divider and center ball
	end

	-- Draw all buttons
	for _, button in pairs(SCREEN.TabButtons) do
		if button ~= SCREEN.TabButtons.XIcon then
			Drawing.drawButton(button, canvas.shadow)
		end
	end
	for _, button in pairs(_getCurrentTabButtons()) do
		Drawing.drawButton(button, canvas.shadow)
	end

end

-- FILTER / CLEANUP

GachaMonOverlay.FilterOptions = {
	Stars1 = { id = "stars1", getLabel = function() return "1 Star" end, value = 1, },
	Stars2 = { id = "stars2", getLabel = function() return "2 Stars" end, value = 2, },
	Stars3 = { id = "stars3", getLabel = function() return "3 Stars" end, value = 3, },
	Stars4 = { id = "stars4", getLabel = function() return "4 Stars" end, value = 4, },
	Stars5 = { id = "stars5", getLabel = function() return "5 Stars" end, value = 5, },
	Stars6 = { id = "stars6", getLabel = function() return "5+ Stars" end, value = 6, },
	BattlePowerLess = { id = "bpless", getLabel = function() return "Less than" end, value = 0, },
	BattlePowerLessText = { id = "bplesstext", getLabel = function() return "0" end, value = 0, },
	BattlePowerGreater = { id = "bpgreater", getLabel = function() return "Greater than" end, value = 0, },
	BattlePowerGreaterText = { id = "bpgreatertext", getLabel = function() return "99999" end, value = 0, },
	VersionFireRed = { id = "versionFR", getLabel = function() return "Fire Red" end, value = 3, },
	VersionLeafGreen = { id = "versionLG", getLabel = function() return "Leaf Green" end, value = 5, },
	VersionEmerald = { id = "versionE", getLabel = function() return "Emerald" end, value = 2, },
	VersionRuby = { id = "versionR", getLabel = function() return "Ruby" end, value = 1, },
	VersionSapphire = { id = "versionS", getLabel = function() return "Sapphire" end, value = 4, },
	ShowFavorites = { id = "favorites", getLabel = function() return "Favorites" end, value = 1, },
	ShowNonFavorites = { id = "nonfavorites", getLabel = function() return "Non-Favorites" end, value = 0, },
	ShowShiny = { id = "shiny", getLabel = function() return "Shiny" end, value = 1, },
	ShowNonShiny = { id = "nonshiny", getLabel = function() return "Non-Shiny" end, value = 0, },
	ByPokemon = {
		id = "bypokemon",
		getLabel = function() return string.format("%s %s:", "By", Resources.AllScreens.Pokemon) end,
		getDropdown = function()
			local pokemonNames = PokemonData.namesToList()
			table.insert(pokemonNames, 1, Constants.BLANKLINE)
			return pokemonNames
		end,
		selectionToId = function(pokemonName)
			return PokemonData.getIdFromName(pokemonName or "")
		end,
	},
}

---Creates common filter option controls for various popup windows (for display or cleanup)
---@param form IBizhawkForm
---@param x number
---@param y number
---@param allChecked? boolean Optional
---@param allClickFunc? function Optional
---@return number nextLineY
local function _createFilterControls(form, x, y, allChecked, allClickFunc)
	allChecked = (allChecked == true)
	local X_COL1, X_COL2, X_COL3 = x + 8, x + 118, x + 238
	local nextLineY = y
	local FO = GachaMonOverlay.FilterOptions

	form:createLabel(string.format("%s:", "Stars"), X_COL1 - 8, nextLineY)
	form:createLabel(string.format("%s:", "Game Version"), X_COL2 - 8, nextLineY)
	form:createLabel(string.format("%s %s:", "Favorite / Shiny", Resources.AllScreens.Pokemon), X_COL3 - 8, nextLineY)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars1.id] = form:createCheckbox(FO.Stars1.getLabel(), X_COL1, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.VersionFireRed.id] = form:createCheckbox(FO.VersionFireRed.getLabel(), X_COL2, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.ShowFavorites.id] = form:createCheckbox(FO.ShowFavorites.getLabel(), X_COL3, nextLineY, allClickFunc, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars2.id] = form:createCheckbox(FO.Stars2.getLabel(), X_COL1, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.VersionLeafGreen.id] = form:createCheckbox(FO.VersionLeafGreen.getLabel(), X_COL2, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.ShowNonFavorites.id] = form:createCheckbox(FO.ShowNonFavorites.getLabel(), X_COL3, nextLineY, allClickFunc, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars3.id] = form:createCheckbox(FO.Stars3.getLabel(), X_COL1, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.VersionEmerald.id] = form:createCheckbox(FO.VersionEmerald.getLabel(), X_COL2, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.ShowShiny.id] = form:createCheckbox(FO.ShowShiny.getLabel(), X_COL3, nextLineY, allClickFunc, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars4.id] = form:createCheckbox(FO.Stars4.getLabel(), X_COL1, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.VersionRuby.id] = form:createCheckbox(FO.VersionRuby.getLabel(), X_COL2, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.ShowNonShiny.id] = form:createCheckbox(FO.ShowNonShiny.getLabel(), X_COL3, nextLineY, allClickFunc, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars5.id] = form:createCheckbox(FO.Stars5.getLabel(), X_COL1, nextLineY, allClickFunc, allChecked)
	form.Controls[FO.VersionSapphire.id] = form:createCheckbox(FO.VersionSapphire.getLabel(), X_COL2, nextLineY, allClickFunc, allChecked)
	nextLineY = nextLineY + 33
	form:createLabel(FO.ByPokemon.getLabel(), X_COL1 - 8, nextLineY)
	form.Controls[FO.ByPokemon.id] = form:createDropdown(FO.ByPokemon.getDropdown(), X_COL2 - 20, nextLineY - 3, 130, 30, nil, nil, allClickFunc)
	nextLineY = nextLineY + 25
	form.Controls.labelWarning = form:createLabel("", x+30, nextLineY)
	ExternalUI.BizForms.setProperty(form.Controls.labelWarning, ExternalUI.BizForms.Properties.FORE_COLOR, "red")
	nextLineY = nextLineY + 28
	return nextLineY
end

---Creates a common filter function, to apply to a list of GachaMons to filter them out
---@param form IBizhawkForm
---@return function
local function _buildFilterFunc(form)
	local FO = GachaMonOverlay.FilterOptions
	local BF = ExternalUI.BizForms
	local matchStars = {
		[FO.Stars1.value] = BF.isChecked(form.Controls[FO.Stars1.id]),
		[FO.Stars2.value] = BF.isChecked(form.Controls[FO.Stars2.id]),
		[FO.Stars3.value] = BF.isChecked(form.Controls[FO.Stars3.id]),
		[FO.Stars4.value] = BF.isChecked(form.Controls[FO.Stars4.id]),
		[FO.Stars5.value] = BF.isChecked(form.Controls[FO.Stars5.id]),
		[FO.Stars6.value] = BF.isChecked(form.Controls[FO.Stars6.id]),
	}
	local matchVersion = {
		[FO.VersionRuby.value] = BF.isChecked(form.Controls[FO.VersionRuby.id]),
		[FO.VersionEmerald.value] = BF.isChecked(form.Controls[FO.VersionEmerald.id]),
		[FO.VersionFireRed.value] = BF.isChecked(form.Controls[FO.VersionFireRed.id]),
		[FO.VersionSapphire.value] = BF.isChecked(form.Controls[FO.VersionSapphire.id]),
		[FO.VersionLeafGreen.value] = BF.isChecked(form.Controls[FO.VersionLeafGreen.id]),
	}
	local matchFavorites = {
		[FO.ShowFavorites.value] = BF.isChecked(form.Controls[FO.ShowFavorites.id]),
		[FO.ShowNonFavorites.value] = BF.isChecked(form.Controls[FO.ShowNonFavorites.id]),
	}
	local matchShiny = {
		[FO.ShowShiny.value] = BF.isChecked(form.Controls[FO.ShowShiny.id]),
		[FO.ShowNonShiny.value] = BF.isChecked(form.Controls[FO.ShowNonShiny.id]),
	}
	local pokemonName = BF.getText(form.Controls[FO.ByPokemon.id])
	local pokemonID = (pokemonName ~= Constants.BLANKLINE) and FO.ByPokemon.selectionToId(pokemonName) or nil

	return function(gachamon)
		local stars = gachamon:getStars() or -1
		local version = gachamon:getGameVersionNumber() or -1
		local favorite = gachamon.Favorite or -1
		local shiny = gachamon:getIsShiny()
		local matchId = pokemonID == nil or pokemonID == gachamon.PokemonId
		return matchStars[stars] and matchVersion[version] and matchFavorites[favorite] and matchShiny[shiny] and matchId
	end
end

---Creates a removal-only filter function, to apply to a GachaMon collection for permanent deletion
---@param form IBizhawkForm
---@return function
local function _buildRemovalFilterFunc(form)
	local FO = GachaMonOverlay.FilterOptions
	local BF = ExternalUI.BizForms
	local matchStars = {
		[FO.Stars1.value] = BF.isChecked(form.Controls[FO.Stars1.id]),
		[FO.Stars2.value] = BF.isChecked(form.Controls[FO.Stars2.id]),
		[FO.Stars3.value] = BF.isChecked(form.Controls[FO.Stars3.id]),
		[FO.Stars4.value] = BF.isChecked(form.Controls[FO.Stars4.id]),
		[FO.Stars5.value] = BF.isChecked(form.Controls[FO.Stars5.id]),
		-- [FO.Stars6.value] = BF.isChecked(form.Controls[FO.Stars6.id]),
	}
	-- If nothing checked in this category, don't use or filter by this category
	if not (matchStars[FO.Stars1.value] or matchStars[FO.Stars2.value] or matchStars[FO.Stars3.value] or matchStars[FO.Stars4.value] or matchStars[FO.Stars5.value]) then
		matchStars = nil
	end

	local matchFavorites = {
		[FO.ShowNonFavorites.value] = BF.isChecked(form.Controls[FO.ShowNonFavorites.id]),
	}
	-- If nothing checked in this category, don't use or filter by this category
	if not (matchFavorites[FO.ShowNonFavorites.value]) then
		matchFavorites = nil
	end

	local matchShiny = {
		[FO.ShowShiny.value] = BF.isChecked(form.Controls[FO.ShowShiny.id]),
		[FO.ShowNonShiny.value] = BF.isChecked(form.Controls[FO.ShowNonShiny.id]),
	}
	-- If nothing checked in this category, don't use or filter by this category
	if not (matchShiny[FO.ShowShiny.value] or matchShiny[FO.ShowNonShiny.value]) then
		matchShiny = nil
	end

	local compareBPLess, compareBPGreater
	if BF.isChecked(form.Controls[FO.BattlePowerLess.id]) then
		local val = tonumber(BF.getText(form.Controls[FO.BattlePowerLessText.id]) or "")
		if val then
			compareBPLess = function(bp) return bp < val end
		end
	end
	if BF.isChecked(form.Controls[FO.BattlePowerGreater.id]) then
		local val = tonumber(BF.getText(form.Controls[FO.BattlePowerGreaterText.id]) or "")
		if val then
			compareBPGreater = function(bp) return bp > val end
		end
	end
	local checkBP
	-- Only use this category if at least one option is checked
	if compareBPLess or compareBPGreater then
		checkBP = function(bp)
			return (not compareBPLess or compareBPLess(bp)) and (not compareBPGreater or compareBPGreater(bp))
		end
	end

	-- If nothing checked at all, don't use any filters or return any matched results
	if matchStars == nil and matchFavorites == nil and matchShiny == nil and checkBP == nil then
		return function(gachamon) return false end
	end

	return function(gachamon)
		local stars = gachamon:getStars() or -1
		local favorite = gachamon.Favorite or -1
		local shiny = gachamon:getIsShiny()
		local useStars = matchStars == nil or matchStars[stars]
		local useFaves = matchFavorites == nil or matchFavorites[favorite]
		local useShiny = matchShiny == nil or matchShiny[shiny]
		local useBP = checkBP == nil or checkBP(gachamon.BattlePower or 0)
		return useStars and useFaves and useShiny and useBP
	end
end

function GachaMonOverlay.openFilterSettingsWindow(tabKey)
	local formTitle = string.format("%s: %s", "Filter GachaMon", tostring(tabKey))
	local form = ExternalUI.BizForms.createForm(formTitle, 430, 320)
	local nextLineY = 15

	form:createLabel("Filter to show GachaMon cards with these qualities:", 20, nextLineY)
	nextLineY = nextLineY + 28
	nextLineY = _createFilterControls(form, 20, nextLineY, true)

	form.Controls.btnApplyFilter = form:createButton("Apply Filters", 40, nextLineY, function()
		SCREEN.Data[tabKey].FilterFunc = _buildFilterFunc(form)
		if tabKey == "Recent" then
			SCREEN.buildRecentData()
		elseif tabKey == "Collection" then
			SCREEN.buildCollectionData()
		end
		SCREEN.refreshButtons()
		Program.redraw(true)
		form:destroy()
	end, 110, 25)
	form.Controls.btnResetFilter = form:createButton("( Reset )", 175, nextLineY, function()
		if SCREEN.Data[tabKey].FilterFunc ~= nil then
			SCREEN.Data[tabKey].FilterFunc = nil
			if tabKey == "Recent" then
				SCREEN.buildRecentData()
			elseif tabKey == "Collection" then
				SCREEN.buildCollectionData()
			end
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
		form:destroy()
	end, 80, 25)
	form.Controls.btnClose = form:createButton(Resources.AllScreens.Cancel, 280, nextLineY, function()
		form:destroy()
	end, 80, 25)
end

function GachaMonOverlay.openCleanupCollectionWindow()
	local form = ExternalUI.BizForms.createForm("Cleanup Collection", 430, 305)
	local nextLineY = 15

	local gachamonsToRemove = {}
	local prevBPLess, prevBPGreater = -1, -1

	local _anyClicked = function()
		-- Reset the filtered Gachamons to be removed
		if #gachamonsToRemove > 0 then
			gachamonsToRemove = {}
		end
		-- Clear out the warning label
		if form.Controls.labelWarning then
			ExternalUI.BizForms.setText(form.Controls.labelWarning, "")
		end
	end

	form:createLabel("Choose what GachaMon cards to permanently REMOVE from your collection:", 20, nextLineY)
	nextLineY = nextLineY + 21
	form:createLabel("Note: Favorite GachaMon are safe and will never be removed by cleanup.", 20, nextLineY)
	nextLineY = nextLineY + 28
	local allChecked = false
	local X_COL1, X_COL2, X_COL3 = 20 + 8, 20 + 118, 20 + 238
	local FO = GachaMonOverlay.FilterOptions

	form:createLabel(string.format("%s:", "Stars"), X_COL1 - 8, nextLineY)
	form:createLabel(string.format("%s:", "Battle Power"), X_COL2 - 8, nextLineY)
	form:createLabel(string.format("%s %s:", "Favorite / Shiny", Resources.AllScreens.Pokemon), X_COL3 - 8, nextLineY)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars1.id] = form:createCheckbox(FO.Stars1.getLabel(), X_COL1, nextLineY, _anyClicked, allChecked)
	form.Controls[FO.BattlePowerLess.id] = form:createCheckbox(FO.BattlePowerLess.getLabel(), X_COL2, nextLineY, _anyClicked, allChecked)
	form.Controls[FO.ShowFavorites.id] = form:createCheckbox(FO.ShowFavorites.getLabel(), X_COL3, nextLineY, _anyClicked, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars2.id] = form:createCheckbox(FO.Stars2.getLabel(), X_COL1, nextLineY, _anyClicked, allChecked)
	form.Controls[FO.BattlePowerLessText.id] = form:createTextBox(FO.BattlePowerLessText.getLabel(), X_COL2, nextLineY, 90, 22, "UNSIGNED", false, true, nil, _anyClicked)
	form.Controls[FO.ShowNonFavorites.id] = form:createCheckbox(FO.ShowNonFavorites.getLabel(), X_COL3, nextLineY, _anyClicked, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars3.id] = form:createCheckbox(FO.Stars3.getLabel(), X_COL1, nextLineY, _anyClicked, allChecked)
	form.Controls[FO.ShowShiny.id] = form:createCheckbox(FO.ShowShiny.getLabel(), X_COL3, nextLineY, _anyClicked, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars4.id] = form:createCheckbox(FO.Stars4.getLabel(), X_COL1, nextLineY, _anyClicked, allChecked)
	form.Controls[FO.BattlePowerGreater.id] = form:createCheckbox(FO.BattlePowerGreater.getLabel(), X_COL2, nextLineY - 3, _anyClicked, allChecked)
	form.Controls[FO.ShowNonShiny.id] = form:createCheckbox(FO.ShowNonShiny.getLabel(), X_COL3, nextLineY, _anyClicked, allChecked)
	nextLineY = nextLineY + 21
	form.Controls[FO.Stars5.id] = form:createCheckbox(FO.Stars5.getLabel(), X_COL1, nextLineY, _anyClicked, allChecked)
	form.Controls[FO.BattlePowerGreaterText.id] = form:createTextBox(FO.BattlePowerGreaterText.getLabel(), X_COL2, nextLineY - 3, 90, 22, "UNSIGNED", false, true, nil, _anyClicked)
	nextLineY = nextLineY + 33
	form.Controls.labelWarning = form:createLabel("", 50, nextLineY)
	ExternalUI.BizForms.setProperty(form.Controls.labelWarning, ExternalUI.BizForms.Properties.FORE_COLOR, "red")
	nextLineY = nextLineY + 28

	-- Favorites should never be removed
	ExternalUI.BizForms.setProperty(form.Controls[FO.ShowFavorites.id], ExternalUI.BizForms.Properties.ENABLED, false)

	form.Controls.btnApplyFilter = form:createButton("Apply Cleanup", 70, nextLineY, function()
		local currentBPLess = tonumber(ExternalUI.BizForms.getText(form.Controls[FO.BattlePowerLessText.id]) or "") or -1
		local currentBPGreater = tonumber(ExternalUI.BizForms.getText(form.Controls[FO.BattlePowerGreaterText.id]) or "") or -1
		local textBoxesChanged = currentBPLess ~= prevBPLess or currentBPGreater ~= prevBPGreater
		prevBPLess = currentBPLess
		prevBPGreater = currentBPGreater
		-- First check how many GachaMons will be removed and alert the user for confirmation
		if #gachamonsToRemove == 0 or textBoxesChanged then
			local filterFunc = _buildRemovalFilterFunc(form)
			for _, gachamon in ipairs(GachaMonData.Collection or {}) do
				if filterFunc(gachamon) then
					table.insert(gachamonsToRemove, gachamon)
				end
			end
			local removalMsg
			if #gachamonsToRemove == 0 then
				removalMsg = "No GachaMons found in your collection matching the above criteria."
			else
				removalMsg = string.format("%s of %s GachaMons in your collection will be removed. Continue?",
					#gachamonsToRemove,
					#GachaMonData.Collection
				)
			end
			ExternalUI.BizForms.setText(form.Controls.labelWarning, removalMsg)
			ExternalUI.BizForms.setProperty(form.Controls.labelWarning, ExternalUI.BizForms.Properties.FORE_COLOR, "red")
		else
			-- Perform removal
			local numRemoved = 0
			for _, gachamon in ipairs(gachamonsToRemove or {}) do
				local index = GachaMonData.findInCollection(gachamon)
				if index ~= -1 then
					numRemoved = numRemoved + 1
					table.remove(GachaMonData.Collection, index)
				end
			end
			gachamonsToRemove = {}
			if numRemoved > 0 then
				GachaMonData.collectionRequiresSaving = true
				SCREEN.buildCollectionData()
			end
			local removalMsg = string.format("%s GachaMons were removed from your collection.", numRemoved)
			ExternalUI.BizForms.setText(form.Controls.labelWarning, removalMsg)
			ExternalUI.BizForms.setProperty(form.Controls.labelWarning, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
		end
	end, 130, 25)
	form.Controls.btnCancel = form:createButton(Resources.AllScreens.Cancel, 240, nextLineY, function()
		form:destroy()
	end, 80, 25)
end
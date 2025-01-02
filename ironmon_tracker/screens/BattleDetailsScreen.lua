BattleDetailsScreen = {
	Key = "BattleDetailsScreen",
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Data = {
		-- The Resource key representing the current terrain used for the battle
		TerrainKey = "",
		-- The Resource key representing the current active weather in the battle (if any)
		WeatherKey = "",
		-- A short one/two word summary of top-most battle detail for each battler (index: 0-3)
		DetailsSummary = {},
		-- All known battle details affecting the entire battle field
		FieldDetails = {},
		-- All known battle details affecting each side, for ally or enemy (index: 0-1)
		PerSideDetails = {},
		-- All known battle details for each battler (index: 0-3)
		PerMonDetails = {},
	},
	Addresses = {
		offsetBattleMonsStatus2 = 0x50, -- gBattleMons
		offsetBattleStructWrappedBy = 0x14,
		sizeofStatus3 = 0x4,
		sizeofSideStatuses = 0x2,
		sizeofSideTimers = 0xC,
		sizeofDisableStruct = 0x1C,
		offsetTimerReflect = 0x0,
		offsetTimerLightScreen = 0x2,
		offsetTimerSpikes = 0xA,
		offsetTimerSafeguard = 0x6,
		offsetTimerMist = 0x4,
		offsetWishStructFutureCounter = 0x0,
		offsetWishStructFutureSource = 0x4,
		offsetWishStructWishCounter = 0x20,
		offsetWishStructWishSource = 0x24,
		offsetWishStructKnockOff = 0x29,
	},
	viewingIndividualStatuses = true,
	viewingSideStauses = false,
	viewedMonIndex = 0,
	viewedSideIndex = 0,
}
local SCREEN = BattleDetailsScreen
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
}

-- Holds functions that read in battle details from game data
SCREEN.GameFuncs = {}

-- Map number values from game data to names (Resource keys)
SCREEN.Maps = {
	WeatherToNameKey = {
		[0] = "WeatherRain", -- Temporary
		[1] = "WeatherRain", -- Downpour
		[2] = "WeatherRain", -- Permanent
		[3] = "WeatherSandstorm", -- Temporary
		[4] = "WeatherSandstorm", -- Permanent
		[5] = "WeatherSunlight", -- Temporary
		[6] = "WeatherSunlight", -- Permanent
		[7] = "WeatherHail", -- Temporary
		["default"] = "WeatherDefault",
	},
	TerrainToNameKey = {
		[0] = "TerrainGrass",
		[1] = "TerrainKey", -- Long Grass
		[2] = "TerrainSand",
		[3] = "TerrainUnderwater",
		[4] = "TerrainWater",
		[5] = "TerrainPond",
		[6] = "TerrainMountain",
		[7] = "TerrainCave",
		["default"] = "TerrainDefault",
	},
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end, -- Order by appearance
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local buffer = Utils.inlineIf(self.currentPage > 9, "", " ") .. Utils.inlineIf(self.totalPages > 9, "", " ")
		return buffer .. string.format("%s/%s", self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
}

SCREEN.Buttons = {
	LabelTerrain = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local value = SCREEN.Data.isReady and Resources[SCREEN.Key][SCREEN.Data.TerrainKey] or Constants.BLANKLINE
			return string.format("%s: %s", Resources[SCREEN.Key].TextTerrain, value)
		end,
		box = {	CANVAS.X + 1, CANVAS.Y + 18, 60, 11 },
	},
	LabelWeather = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local value = SCREEN.Data.isReady and Resources[SCREEN.Key][SCREEN.Data.WeatherKey] or Constants.BLANKLINE
			return string.format("%s: %s", Resources[SCREEN.Key].TextWeather, value)
		end,
		box = {	CANVAS.X + 1, CANVAS.Y + 29, 60, 11 },
	},
	LabelTurnCount = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local value = SCREEN.Data.isReady and ((Battle.turnCount or 0) + 1) or Constants.BLANKLINE
			return string.format("%s: %s", Resources[SCREEN.Key].TextTurn, value)
		end,
		box = {	CANVAS.X + 1, CANVAS.Y + 40, 60, 11 },
	},
	ViewedDetailsHeader = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			if SCREEN.viewingIndividualStatuses then
				if SCREEN.viewedMonIndex % 2 == 0 then
					return string.format("%s %s", Resources[SCREEN.Key].TextAllied, Resources.AllScreens.Pokemon)
				else
					return string.format("%s %s", Resources[SCREEN.Key].TextEnemy, Resources.AllScreens.Pokemon)
				end
			elseif SCREEN.viewingSideStauses then
				if SCREEN.viewedSideIndex % 2 == 0 then
					return string.format("%s %s", Resources[SCREEN.Key].TextAllied, Resources[SCREEN.Key].TextTeam)
				else
					return string.format("%s %s", Resources[SCREEN.Key].TextEnemy, Resources[SCREEN.Key].TextTeam)
				end
			else
				return Resources[SCREEN.Key].TextField
			end
		end,
		textColor = SCREEN.Colors.highlight,
		box = {	CANVAS.X + 2, CANVAS.Y + 53, 60, 11 },
		isVisible = function(self) return SCREEN.Data.isReady end,
		updateSelf = function(self)
			-- Update width as text changes
			self.box[3] = 4 + Utils.calcWordPixelLength(self:getText())
		end,
		draw = function(self, shadowcolor)
			Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
		end,
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { CANVAS.X + 56, CANVAS.Y + 135, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { CANVAS.X + 46, CANVAS.Y + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { CANVAS.X + 86, CANVAS.Y + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or TrackerScreen)
		SCREEN.previousScreen = nil
	end),
}

SCREEN.TeamBallBox = {
	FieldView = {
		index = 1,
		type = Constants.ButtonTypes.NO_BORDER,
		image = Constants.PixelImages.RIGHT_TRIANGLE,
		clickableArea = { CANVAS.X + 91, CANVAS.Y + 19, 9, 30 },
		box = { CANVAS.X + 91, CANVAS.Y + 19, 44, 30},
		isVisible = function() return SCREEN.Data.isReady end,
		isSelected = function() return not SCREEN.viewingSideStauses and not SCREEN.viewingIndividualStatuses end,
		updateSelf = function(self)
			if self:isSelected() then
				self.index = 999
				self.textColor = SCREEN.Colors.highlight
				self.boxColors[1] = SCREEN.Colors.highlight
			else
				self.index = 1
				self.textColor = SCREEN.Colors.text
				self.boxColors[1] = SCREEN.Colors.border
			end
		end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = false
			SCREEN.viewedSideIndex = 0
			SCREEN.viewedMonIndex = 0
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local iconColor = Theme.COLORS[self.textColor]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			-- Draw right/bottom shadows
			gui.drawLine(x + 1, y + h + 1, x + w + 1, y + h + 1, shadowcolor)
			gui.drawLine(x + w + 1, y + 1, x + w + 1, y + h + 1, shadowcolor)
			-- Draw full border rectangle
			gui.drawRectangle(x, y, w, h, borderColor)
			Drawing.drawImageAsPixels(self.image, x + 2, y + 11, iconColor, shadowcolor)
		end,
	},
	EnemyTeam = {
		index = 2,
		type = Constants.ButtonTypes.NO_BORDER,
		image = Constants.PixelImages.RIGHT_TRIANGLE,
		clickableArea = { CANVAS.X + 100, CANVAS.Y + 19, 6, 15 },
		box = { CANVAS.X + 100, CANVAS.Y + 19, 35, 15 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			-- Increase clickable area for team boxes in single battles to include the unused pokeballs
			local clickBox = self.clickableArea
			if Battle.numBattlers == 2 then
				clickBox[3] = 20
			else
				clickBox[3] = 6
			end
			if self:isSelected() then
				self.index = 999
				self.textColor = SCREEN.Colors.highlight
				self.boxColors[1] = SCREEN.Colors.highlight
			else
				self.index = 2
				self.textColor = SCREEN.Colors.text
				self.boxColors[1] = SCREEN.Colors.border
			end
		end,
		isSelected = function() return SCREEN.viewingSideStauses and SCREEN.viewedSideIndex == 1 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = true
			SCREEN.viewedSideIndex = 1
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local iconColor = Theme.COLORS[self.textColor]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			gui.drawRectangle(x, y, w, h, borderColor)
			Drawing.drawImageAsPixels(self.image, x + 2, y + 3, iconColor, shadowcolor)
		end,
	},
	AllyTeam = {
		index = 3,
		type = Constants.ButtonTypes.NO_BORDER,
		image = Constants.PixelImages.LEFT_TRIANGLE,
		clickableArea = { CANVAS.X + 114, CANVAS.Y + 34, 20, 15 },
		box = { CANVAS.X + 100, CANVAS.Y + 34, 35, 15 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			-- Increase clickable area for team boxes in single battles to include the unused pokeballs
			local clickBox = self.clickableArea
			if Battle.numBattlers == 2 then
				clickBox[1] = CANVAS.X + 114
				clickBox[3] = 20
			else
				clickBox[1] = CANVAS.X + 129
				clickBox[3] = 6
			end
			if self:isSelected() then
				self.index = 999
				self.textColor = SCREEN.Colors.highlight
				self.boxColors[1] = SCREEN.Colors.highlight
			else
				self.index = 3
				self.textColor = SCREEN.Colors.text
				self.boxColors[1] = SCREEN.Colors.border
			end
		end,
		isSelected = function() return SCREEN.viewingSideStauses and SCREEN.viewedSideIndex == 0 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = true
			SCREEN.viewedSideIndex = 0
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local iconColor = Theme.COLORS[self.textColor]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			gui.drawRectangle(x, y, w, h, borderColor)
			Drawing.drawImageAsPixels(self.image, x + 29, y + 3, iconColor, shadowcolor)
		end,
	},
	LeftOther = {
		index = 4,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 122, CANVAS.Y + 21, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 1 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 1
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
	RightOther = {
		index = 5,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 109, CANVAS.Y + 21, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			if Battle.numBattlers == 4 then
				self.iconColors = TrackerScreen.PokeBalls.ColorList
			else
				self.iconColors = { 0xFF000000, 0xFFB3B3B3, 0xFFFFFFFF, }
			end
		end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 3 end,
		onClick = function(self)
			if self:isSelected() or Battle.numBattlers < 4 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 3
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
	LeftOwn = {
		index = 6,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 102, CANVAS.Y + 36, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 0 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 0
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
	RightOwn = {
		index = 7,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 115, CANVAS.Y + 36, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			if Battle.numBattlers == 4 then
				self.iconColors = TrackerScreen.PokeBalls.ColorList
			else
				self.iconColors = { 0xFF000000, 0xFFB3B3B3, 0xFFFFFFFF, }
			end
		end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 2 end,
		onClick = function(self)
			if self:isSelected() or Battle.numBattlers < 4 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 2
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
}

function SCREEN.initialize()
	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
	for _, button in pairs(SCREEN.TeamBallBox) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
	SCREEN.clearBuiltData()
end

function SCREEN.hasDetails()
	local viewIndex = Battle.getViewedIndex() or 0
	return not Utils.isNilOrEmpty(SCREEN.Data.DetailsSummary[viewIndex])
end

function SCREEN.updateData(buildPagedButtons)
	if not Battle.inActiveBattle() then
		if SCREEN.Data.isReady then
			SCREEN.clearBuiltData()
		end
		return
	end

	-- TEMPORARY TODO: Don't calc data for some Rom Hacks, as they're missing game addresses
	if CustomCode.RomHacks.isPlayingMoveExpansion() then
		return
	end

	SCREEN.clearBuiltData()

	-- Read in battle details data from the game
	SCREEN.GameFuncs.readFieldEffects()
	for i = 0, Battle.numBattlers - 1, 1 do
		-- SCREEN.GameFuncs.readOther(i) -- info not currently recorded
		SCREEN.GameFuncs.readStatus2(i)
		SCREEN.GameFuncs.readStatus3(i)
		SCREEN.GameFuncs.readSideStatuses(i)
		SCREEN.GameFuncs.readDisableStruct(i)
		SCREEN.GameFuncs.readWishStruct(i)
		SCREEN.summarizeDetails(i)
	end

	SCREEN.Data.isReady = true

	-- If viewing this screen, build pager buttons to display known battle details
	if buildPagedButtons or Program.currentScreen == SCREEN then
		SCREEN.buildPagedButtons()
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.summarizeDetails(index)
	if not index or index < 0 or index > 3 then
		return
	end
	local sideIndex = index % 2

	-- Summarize battle details by getting the first relevant item
	local firstDetail = SCREEN.Data.PerMonDetails[index][1]
		or SCREEN.Data.PerSideDetails[sideIndex][1]
		or SCREEN.Data.FieldDetails[1]

	if firstDetail and type(firstDetail.getText) == "function" then
		local summaryText = firstDetail:getText()
		-- Trim whitespace
		summaryText = summaryText:match("^%s*(.-)%s*$") or ""
		-- Shorten to fit on screen
		summaryText = Utils.shortenText(summaryText, 123, true)
		SCREEN.Data.DetailsSummary[index] = summaryText
	else
		SCREEN.Data.DetailsSummary[index] = ""
	end
end

function SCREEN.buildPagedButtons()
	if not SCREEN.Data.isReady then
		return
	end

	local detailsToUse = {}
	if SCREEN.viewingIndividualStatuses then
		for _, v in ipairs(SCREEN.Data.PerMonDetails[SCREEN.viewedMonIndex] or {}) do
			table.insert(detailsToUse, v)
		end
	end
	if SCREEN.viewingSideStauses then
		for _, v in ipairs(SCREEN.Data.PerSideDetails[SCREEN.viewedSideIndex] or {}) do
			table.insert(detailsToUse, v)
		end
	end
	for _, v in ipairs(SCREEN.Data.FieldDetails or {}) do
		table.insert(detailsToUse, v)
	end

	SCREEN.Pager.Buttons = {}
	for i, detail in ipairs(detailsToUse) do
		local button = {
			index = i,
			detail = detail,
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return string.format("- %s", detail:getText()) end,
			textColor = SCREEN.Colors.text,
			dimensions = { width = 100, height = 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return self.pageVisible == SCREEN.Pager.currentPage end,
			-- updateSelf = function(self)
			-- end,
			onClick = function(self)
				-- TODO: consider checking left/right halves of the button for multiple clickable ids
				if MoveData.isValid(detail.MoveId) then
					InfoScreen.previousScreenFinal = SCREEN
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, detail.MoveId)
				elseif PokemonData.isValid(detail.PokemonId) then
					InfoScreen.previousScreenFinal = SCREEN
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, detail.PokemonId)
				elseif AbilityData.isValid(detail.AbilityId) then
					InfoScreen.previousScreenFinal = SCREEN
					InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, detail.AbilityId)
				end
			end,
			-- draw = function(self, shadowcolor)
			-- 	local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- end,
		}
		table.insert(SCREEN.Pager.Buttons, button)
	end

	local detailsHeaderBtn = SCREEN.Buttons.ViewedDetailsHeader
	local X = CANVAS.X
	local Y = detailsHeaderBtn.box[2] + detailsHeaderBtn.box[4] + 1
	SCREEN.Pager:realignButtonsToGrid(X, Y, 20, 0)

	SCREEN.refreshButtons()
end

function SCREEN.clearBuiltData(clearViewIndex)
	SCREEN.Data = {
		isReady = false,
		TerrainKey = SCREEN.Maps.TerrainToNameKey["default"],
		WeatherKey = SCREEN.Maps.WeatherToNameKey["default"],

		DetailsSummary = {
			[0] = "",
			[1] = "",
			[2] = "",
			[3] = "",
		},

		-- List of IBattleDetail; details about the battle field itself (i.e. Pay Day, Mud Sport)
		FieldDetails = {},

		-- List of IBattleDetail; details per each side (ally / enemy)
		PerSideDetails = {
			[0] = {},
			[1] = {},
		},

		-- List of IBattleDetail; details per individual Pokémon (of the 4 total in battle)
		PerMonDetails = {
			[0] = {},
			[1] = {},
			[2] = {},
			[3] = {},
		},
	}

	SCREEN.Pager.Buttons = {}
	SCREEN.Pager.currentPage = 1
	SCREEN.Pager.totalPages = 1

	-- Only reset viewing index if not viewing this screen already
	if clearViewIndex or Program.currentScreen ~= SCREEN then
		SCREEN.resetViewIndex()
	end
end

function SCREEN.resetViewIndex()
	SCREEN.viewingIndividualStatuses = true
	SCREEN.viewingSideStauses = false
	SCREEN.viewedMonIndex = Battle.getViewedIndex() -- [Index: 0-3]
	SCREEN.viewedSideIndex = SCREEN.viewedMonIndex % 2 -- 0: Ally, 1: Enemy
end

function SCREEN.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.TeamBallBox) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function SCREEN.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.TeamBallBox)
end

function SCREEN.drawScreen()
	Drawing.drawBackgroundAndMargins()

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

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources[SCREEN.Key].Title)
	-- local headerColor = Theme.COLORS["Header text"]
	-- local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	if Theme.DRAW_TEXT_SHADOWS then
		Drawing.drawText(canvas.x + 1, canvas.y + 1, headerText, canvas.shadow, nil, Constants.Font.HEADERSIZE)
	end
	Drawing.drawText(canvas.x, canvas.y, headerText, canvas.text, canvas.shadow, Constants.Font.HEADERSIZE)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	local sortedButtons = Utils.getSortedList(SCREEN.TeamBallBox)
	for _, button in pairs(sortedButtons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

-- Object Prototypes
---@class IBattleDetail
SCREEN.IBattleDetail = {
	-- The associated Resources key for this battle effect
	ResourceKey = "",
	-- The value to store for this battle effect (if any)
	Value = "NO_VALUE",
	-- Optional id of the move, if any is associated with this battle detail
	MoveId = 0,
	-- Optional id of the Pokémon, if any is associated with this battle detail
	PokemonId = 0,
	-- Optional id of the ability, if any is associated with this battle detail
	AbilityId = 0,

	-- Returns this effect's value (if any)
	getValue = function(self)
		if not self.Value or self.Value == "NO_VALUE" then
			return nil
		end
		return self.Value
	end,
	-- Returns this effect's text as it's expected to be formatted
	getText = function(self)
		if self:getValue() then
			return string.format("%s: %s", Resources[SCREEN.Key][self.ResourceKey or ""] or "", self:getValue())
		else
			return Resources[SCREEN.Key][self.ResourceKey or ""] or ""
		end
	end,
}
---Creates and returns a new IBattleDetail object
---@param o? table Optional initial object table
---@return IBattleDetail battleeffect An IBattleDetail object
function SCREEN.IBattleDetail:new(o)
	o = o or {}
	o.ResourceKey = o.ResourceKey or ""
	o.Value = o.Value or -99999
	o.MoveId = o.MoveId or 0
	o.PokemonId = o.PokemonId or 0
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Functions to read in game data
function SCREEN.GameFuncs.readTerrain()
	--[[
		gBattleTerrain
		#define BATTLE_TERRAIN_GRASS        0
		#define BATTLE_TERRAIN_LONG_GRASS   1
		#define BATTLE_TERRAIN_SAND         2
		#define BATTLE_TERRAIN_UNDERWATER   3
		#define BATTLE_TERRAIN_WATER        4
		#define BATTLE_TERRAIN_POND         5
		#define BATTLE_TERRAIN_MOUNTAIN     6
		#define BATTLE_TERRAIN_CAVE         7
		#define BATTLE_TERRAIN_BUILDING     8
	]]
	local battleTerrain = Memory.readbyte(GameSettings.gBattleTerrain)
	SCREEN.Data.TerrainKey = SCREEN.Maps.TerrainToNameKey[battleTerrain] or SCREEN.Maps.TerrainToNameKey["default"]
end

function SCREEN.GameFuncs.readWeather()
	--[[
		gBattleWeather
		#define B_WEATHER_RAIN_TEMPORARY      (1 << 0)
		#define B_WEATHER_RAIN_DOWNPOUR       (1 << 1)
		#define B_WEATHER_RAIN_PERMANENT      (1 << 2)
		#define B_WEATHER_SANDSTORM_TEMPORARY (1 << 3)
		#define B_WEATHER_SANDSTORM_PERMANENT (1 << 4)
		#define B_WEATHER_SUN_TEMPORARY       (1 << 5)
		#define B_WEATHER_SUN_PERMANENT       (1 << 6)
		#define B_WEATHER_HAIL_TEMPORARY      (1 << 7)
	]]
	local weatherByte = Memory.readbyte(GameSettings.gBattleWeather)
	local weatherTurns = Memory.readbyte(GameSettings.gWishFutureKnock + 0x28)

	-- Check if no weather
	if weatherByte == 0 then
		SCREEN.Data.WeatherKey = SCREEN.Maps.WeatherToNameKey["default"]
		SCREEN.Data.WeatherTurns = 0
		return
	end

	local weatherBitIndex = 0
	for i = 1, 99999, 1 do -- Max iterations, just in case
		weatherByte = Utils.bit_rshift(weatherByte, 1)
		weatherBitIndex = weatherBitIndex + 1
		if weatherByte <= 1 then
			break
		end
	end
	SCREEN.Data.WeatherKey = SCREEN.Maps.WeatherToNameKey[weatherBitIndex] or SCREEN.Maps.WeatherToNameKey["default"]

	-- For temporary weather: Weather Turns are not reset to 0 when temporary weather becomes permanent
	if weatherBitIndex == 0 or weatherBitIndex == 3 or weatherBitIndex == 5 or weatherBitIndex == 7 then
		SCREEN.Data.WeatherTurns = weatherTurns
		table.insert(SCREEN.Data.FieldDetails, SCREEN.IBattleDetail:new({
			Value = weatherTurns,
			getText = function(self)
				return string.format("%s %s: %s",
					Resources[SCREEN.Key].TextWeatherTurns,
					Resources[SCREEN.Key].TextTurnsRemaining,
					self.Value
				)
			end,
		}))
	-- For permanent/other weather:
	else
		SCREEN.Data.WeatherTurns = 0
		table.insert(SCREEN.Data.FieldDetails, SCREEN.IBattleDetail:new({
			getText = function(self)
				return string.format("%s: %s",
					Resources[SCREEN.Key].TextWeather,
					Resources[SCREEN.Key][SCREEN.Data.WeatherKey] or Constants.BLANKLINE
				)
			end,
		}))
	end
end

function SCREEN.GameFuncs.readFieldEffects()
	SCREEN.GameFuncs.readTerrain()
	SCREEN.GameFuncs.readWeather()

	-- Pay Day
	local paydayMoney = Memory.readword(GameSettings.gPaydayMoney)
	if paydayMoney ~= 0 then
		table.insert(SCREEN.Data.FieldDetails, SCREEN.IBattleDetail:new({
			Value = paydayMoney,
			MoveId = MoveData.Values.PayDayId or 6,
			getText = function(self)
				return string.format("%s (%s)",
					Resources.Game.MoveNames[MoveData.Values.PayDayId or 6] or Constants.BLANKLINE,
					self.Value
				)
			end,
		}))
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.GameFuncs.readStatus2(index)
	if not index or index < 0 or index > 3 then
		return
	end
	--[[
		GameSettings.gBattleMons + 0x50
		#define STATUS2_CONFUSION             (1 << 0 | 1 << 1 | 1 << 2)
		#define STATUS2_FLINCHED              (1 << 3)
		#define STATUS2_UPROAR                (1 << 4 | 1 << 5 | 1 << 6)
		#define STATUS2_UNUSED                (1 << 7)
		#define STATUS2_BIDE                  (1 << 8 | 1 << 9)
		#define STATUS2_LOCK_CONFUSE          (1 << 10 | 1 << 11) // e.g. Thrash
		#define STATUS2_MULTIPLETURNS         (1 << 12)
		#define STATUS2_WRAPPED               (1 << 13 | 1 << 14 | 1 << 15)
		#define STATUS2_INFATUATION           (1 << 16 | 1 << 17 | 1 << 18 | 1 << 19)  // 4 bits, one for every battler
		#define STATUS2_FOCUS_ENERGY          (1 << 20)
		#define STATUS2_TRANSFORMED           (1 << 21)
		#define STATUS2_RECHARGE              (1 << 22)
		#define STATUS2_RAGE                  (1 << 23)
		#define STATUS2_SUBSTITUTE            (1 << 24)
		#define STATUS2_DESTINY_BOND          (1 << 25)
		#define STATUS2_ESCAPE_PREVENTION     (1 << 26)
		#define STATUS2_NIGHTMARE             (1 << 27)
		#define STATUS2_CURSED                (1 << 28)
		#define STATUS2_FORESIGHT             (1 << 29)
		#define STATUS2_DEFENSE_CURL          (1 << 30)
		#define STATUS2_TORMENT               (1 << 31)
	]]--

	local MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	if not MON_DETAILS then
		SCREEN.Data.PerMonDetails[index] = {}
		MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	end

	local function _getSourceMon(sourceIndex)
		local sourceMonIndex = Battle.Combatants[Battle.IndexMap[sourceIndex] or -1] or -1
		local sourcePokemon = Tracker.getPokemon(sourceMonIndex, sourceIndex % 2 == 0) or {}
		if not PokemonData.isValid(sourcePokemon.pokemonID) then
			return nil
		end
		return sourcePokemon
	end

	local battleStructAddress
	if GameSettings.gBattleStructPtr ~= nil then -- Pointer unavailable in RS
		battleStructAddress = Memory.readdword(GameSettings.gBattleStructPtr)
	else
		battleStructAddress = 0x02000000 -- gSharedMem
	end

	local monIndexOffset = index * Program.Addresses.sizeofBattlePokemon
	local status2Data = Memory.readdword(GameSettings.gBattleMons + monIndexOffset + SCREEN.Addresses.offsetBattleMonsStatus2)
	local status2Map = Utils.generateBitwiseMap(status2Data, 32)

	-- CONFUSED
	if status2Map[0] or status2Map[1] or status2Map[2] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			getText = function(self)
				return string.format("%s (1- 4 %ss)", Resources[SCREEN.Key].EffectConfused, Resources[SCREEN.Key].TextTurn)
			end,
		}))
	end
	-- UPROAR
	if status2Map[4] or status2Map[5] or status2Map[6] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.UproarId or 253,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.UproarId or 253] or Constants.BLANKLINE
			end,
		}))
	end
	--BIDE
	if status2Map[8] or status2Map[9] then
		local turns = 0
		if status2Map[8] then
			turns = turns + 1
		end
		if status2Map[9] then
			turns = turns + 2
		end
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = turns,
			MoveId = MoveData.Values.BideId or 117,
			getText = function(self)
				return string.format("%s: %s %s%s",
					Resources.Game.MoveNames[MoveData.Values.BideId or 117] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s")
				)
			end,
		}))
	end
	-- MUST ATTACK
	if status2Map[12] and not (status2Map[8] or status2Map[9]) then -- ignore if bide is active
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			getText = function(self)
				return Resources[SCREEN.Key].EffectMustAttack
			end,
		}))
	end
	-- TRAPPED
	if status2Map[13] or status2Map[14] or status2Map[15] then
		local sourceBattlerIndex = Memory.readbyte(battleStructAddress + SCREEN.Addresses.offsetBattleStructWrappedBy + index)
		local sourcePokemon = _getSourceMon(sourceBattlerIndex)
		if sourcePokemon then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				Value = sourcePokemon.pokemonID,
				PokemonId = sourcePokemon.pokemonID,
				getText = function(self)
					return string.format("%s (%s)",
						Resources[SCREEN.Key].EffectTrapped,
						PokemonData.Pokemon[self.Value].name
					)
				end,
			}))
		end
	end
	-- ATTRACT
	if status2Map[16] or status2Map[17] or status2Map[18] or status2Map[19] then
		local infatuationTarget = (status2Map[16] and 0) or (status2Map[17] and 1) or (status2Map[18] and 2) or (status2Map[19] and 3) or 0
		local sourcePokemon = _getSourceMon(infatuationTarget)
		if sourcePokemon then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				Value = sourcePokemon.pokemonID,
				PokemonId = sourcePokemon.pokemonID,
				getText = function(self)
					return string.format("%s (%s)",
					Resources.Game.MoveNames[MoveData.Values.AttactId or 213] or Constants.BLANKLINE,
						PokemonData.Pokemon[self.Value].name
					)
				end,
			}))
		end
	end
	-- FOCUS ENERGY
	if status2Map[20] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.FocusEnergyId or 116,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.FocusEnergyId or 116] or Constants.BLANKLINE
			end,
		}))
	end
	-- TRANSFORM
	if status2Map[21] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.TransformId or 144,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.TransformId or 144] or Constants.BLANKLINE
			end,
		}))
	end
	-- CANNOT ACT
	if status2Map[22] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			getText = function(self)
				return Resources[SCREEN.Key].EffectCannotAct
			end,
		}))
	end
	-- RAGE
	if status2Map[23] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.RageId or 99,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.RageId or 99] or Constants.BLANKLINE
			end,
		}))
	end
	-- SUBSTITUTE: Leaving here since it is technically a battle status even though the player can physically see the substitute in the battle
	if status2Map[24] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.SubstituteId or 164,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.SubstituteId or 164] or Constants.BLANKLINE
			end,
		}))
	end
	-- DESTINY BOND
	if status2Map[25] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.DestinyBondId or 194,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.DestinyBondId or 194] or Constants.BLANKLINE
			end,
		}))
	end
	-- CANNOT ESCAPE
	if status2Map[26] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			getText = function(self)
				return Resources[SCREEN.Key].EffectCannotEscape
			end,
		}))
	end
	-- NIGHTMARE
	if status2Map[27] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.NightmareId or 171,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.NightmareId or 171] or Constants.BLANKLINE
			end,
		}))
	end
	-- CURSE (Ghost version)
	if status2Map[28] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.CurseId or 174,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.CurseId or 174] or Constants.BLANKLINE
			end,
		}))
	end
	-- FORESIGHT
	if status2Map[29] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.ForesightId or 193,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.ForesightId or 193] or Constants.BLANKLINE
			end,
		}))
	end
	-- DEFENSE CURL
	if status2Map[30] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.DefenseCurlId or 111,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.DefenseCurlId or 111] or Constants.BLANKLINE
			end,
		}))
	end
	-- TORMENT
	if status2Map[31] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.TormentId or 259,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.TormentId or 259] or Constants.BLANKLINE
			end,
		}))
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.GameFuncs.readStatus3(index)
	if not index or index < 0 or index > 3 then
		return
	end
	--[[
		gStatuses3
		#define STATUS3_LEECHSEED_BATTLER       (1 << 0 | 1 << 1) // The battler to receive HP from Leech Seed
		#define STATUS3_LEECHSEED               (1 << 2)
		#define STATUS3_ALWAYS_HITS             (1 << 3 | 1 << 4)
		#define STATUS3_PERISH_SONG             (1 << 5)
		#define STATUS3_ON_AIR                  (1 << 6)
		#define STATUS3_UNDERGROUND             (1 << 7)
		#define STATUS3_MINIMIZED               (1 << 8)
		#define STATUS3_CHARGED_UP              (1 << 9)
		#define STATUS3_ROOTED                  (1 << 10)
		#define STATUS3_YAWN                    (1 << 11 | 1 << 12) // Number of turns to sleep
		#define STATUS3_YAWN_TURN(num)          (((num) << 11) & STATUS3_YAWN)
		#define STATUS3_IMPRISONED_OTHERS       (1 << 13)
		#define STATUS3_GRUDGE                  (1 << 14)
		#define STATUS3_CANT_SCORE_A_CRIT       (1 << 15)
		#define STATUS3_MUDSPORT                (1 << 16)
		#define STATUS3_WATERSPORT              (1 << 17)
		#define STATUS3_UNDERWATER              (1 << 18)
		#define STATUS3_TRACE                   (1 << 20)
	]]--

	local MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	if not MON_DETAILS then
		SCREEN.Data.PerMonDetails[index] = {}
		MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	end

	local function _getSourceMon(sourceIndex)
		local sourceMonIndex = Battle.Combatants[Battle.IndexMap[sourceIndex] or -1] or -1
		local sourcePokemon = Tracker.getPokemon(sourceMonIndex, sourceIndex % 2 == 0) or {}
		if not PokemonData.isValid(sourcePokemon.pokemonID) then
			return nil
		end
		return sourcePokemon
	end

	local status3Data = Memory.readdword(GameSettings.gStatuses3 + index * SCREEN.Addresses.sizeofStatus3)
	local status3Map = Utils.generateBitwiseMap(status3Data, 21)

	-- LEECH SEED
	if status3Map[2] then
		local leechSeedSource = 0
		if status3Map[0] then
			leechSeedSource = leechSeedSource + 1
		end
		if status3Map[1] then
			leechSeedSource = leechSeedSource + 2
		end
		local sourcePokemon = _getSourceMon(leechSeedSource)
		if sourcePokemon then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				Value = sourcePokemon.pokemonID,
				MoveId = MoveData.Values.LeechSeedId or 73,
				PokemonId = sourcePokemon.pokemonID,
				getText = function(self)
					return string.format("%s (%s)",
					Resources.Game.MoveNames[MoveData.Values.LeechSeedId or 73] or Constants.BLANKLINE,
						PokemonData.Pokemon[self.Value].name
					)
				end,
			}))
		end
	end
	-- LOCK-ON (processed in a below function)
	if status3Map[3] or status3Map[4] then
		SCREEN.Data.LockOnInEffect = true
	end
	-- PERISH SONG COUNT (processed in a below function)
	if status3Map[5] then
		SCREEN.Data.PerishSongInEffect = true
	end
	-- INVULNERABLE STATE (Fly, Dig, Dive)
	local invulnerableTypeKey = (status3Map[6] and "EffectAirborne") or (status3Map[7] and "EffectUnderground") or (status3Map[18] and "EffectUnderwater") or nil
	if invulnerableTypeKey then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			getText = function(self)
				return Resources[SCREEN.Key][invulnerableTypeKey or "EffectAirborne"] or Constants.BLANKLINE
			end,
		}))
	end
	-- MINIMIZE
	if status3Map[8] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.MinimizeId or 107,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.MinimizeId or 107] or Constants.BLANKLINE
			end,
		}))
	end
	-- CHARGE
	if status3Map[9] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.ChargeId or 268,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.ChargeId or 268] or Constants.BLANKLINE
			end,
		}))
	end
	-- INGRAIN
	if status3Map[10] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.IngrainId or 275,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.IngrainId or 275] or Constants.BLANKLINE
			end,
		}))
	end
	-- DROWSY (Yawn)
	if status3Map[11] or status3Map[12] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.YawnId or 281,
			getText = function(self)
				return Resources[SCREEN.Key].EffectDrowsy
			end,
		}))
	end
	-- IMPRISON
	if status3Map[13] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.ImprisonId or 286,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.ImprisonId or 286] or Constants.BLANKLINE
			end,
		}))
	end
	-- GRUDGE
	if status3Map[14] then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.GrudgeId or 288,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.GrudgeId or 288] or Constants.BLANKLINE
			end,
		}))
	end
	-- MUD SPORT
	if status3Map[16] then
		local sourcePokemon = _getSourceMon(index)
		if sourcePokemon then
			table.insert(SCREEN.Data.FieldDetails, SCREEN.IBattleDetail:new({
				Value = sourcePokemon.pokemonID,
				MoveId = MoveData.Values.MudSportId or 300,
				PokemonId = sourcePokemon.pokemonID,
				getText = function(self)
					return string.format("%s (%s)",
						Resources.Game.MoveNames[MoveData.Values.MudSportId or 300] or Constants.BLANKLINE,
						PokemonData.Pokemon[self.Value].name
					)
				end,
			}))
		end
	end
	-- WATER SPORT
	if status3Map[17] then
		local sourcePokemon = _getSourceMon(index)
		if sourcePokemon then
			table.insert(SCREEN.Data.FieldDetails, SCREEN.IBattleDetail:new({
				Value = sourcePokemon.pokemonID,
				MoveId = MoveData.Values.WaterSportId or 346,
				PokemonId = sourcePokemon.pokemonID,
				getText = function(self)
					return string.format("%s (%s)",
						Resources.Game.MoveNames[MoveData.Values.WaterSportId or 346] or Constants.BLANKLINE,
						PokemonData.Pokemon[self.Value].name
					)
				end,
			}))
		end
	end
end

---@param index number Must be [0-1], inclusively; represent either the allied or enemy team
function SCREEN.GameFuncs.readSideStatuses(index)
	if not index or index < 0 or index > 1 then
		return
	end
	--[[
	gSideStatuses[2] (0x02)

	#define SIDE_STATUS_REFLECT          (1 << 0)
	#define SIDE_STATUS_LIGHTSCREEN      (1 << 1)
	#define SIDE_STATUS_X4               (1 << 2)
	#define SIDE_STATUS_SPIKES           (1 << 4)
	#define SIDE_STATUS_SAFEGUARD        (1 << 5)
	#define SIDE_STATUS_FUTUREATTACK     (1 << 6)
	#define SIDE_STATUS_MIST             (1 << 8) -- Includes Guard Spec.
	#define SIDE_STATUS_SPIKES_DAMAGED   (1 << 9)

	gSideTimers[2] (0x0B)
	{
		/*0x00*/ u8 reflectTimer;
		/*0x01*/ u8 reflectBattlerId;
		/*0x02*/ u8 lightscreenTimer;
		/*0x03*/ u8 lightscreenBattlerId;
		/*0x04*/ u8 mistTimer;
		/*0x05*/ u8 mistBattlerId;
		/*0x06*/ u8 safeguardTimer;
		/*0x07*/ u8 safeguardBattlerId;
		/*0x08*/ u8 followmeTimer;
		/*0x09*/ u8 followmeTarget;
		/*0x0A*/ u8 spikesAmount;
		/*0x0B*/ u8 fieldB;
	};
	]]--

	local SIDE_DETAILS = SCREEN.Data.PerSideDetails[index]
	if not SIDE_DETAILS then
		SCREEN.Data.PerSideDetails[index] = {}
		SIDE_DETAILS = SCREEN.Data.PerSideDetails[index]
	end

	local sideStatuses = Memory.readword(GameSettings.gSideStatuses + (index * SCREEN.Addresses.sizeofSideStatuses))
	local sideTimersBase = GameSettings.gSideTimers + (index * SCREEN.Addresses.sizeofSideTimers)
	local sideStatusMap = Utils.generateBitwiseMap(sideStatuses, 9)

	-- REFLECT
	if sideStatusMap[0] then
		local turnsLeftReflect = Memory.readbyte(sideTimersBase + SCREEN.Addresses.offsetTimerReflect)
		table.insert(SIDE_DETAILS, SCREEN.IBattleDetail:new({
			Value = turnsLeftReflect,
			MoveId = MoveData.Values.ReflectId or 115,
			getText = function(self)
				return string.format("%s: %s %s%s %s",
					Resources.Game.MoveNames[MoveData.Values.ReflectId or 115] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s"),
					Resources[SCREEN.Key].TextTurnsRemaining
				)
			end,
		}))
	end
	-- LIGHT SCREEN
	if sideStatusMap[1] then
		local turnsLeftLightScreen = Memory.readbyte(sideTimersBase + SCREEN.Addresses.offsetTimerLightScreen)
		table.insert(SIDE_DETAILS, SCREEN.IBattleDetail:new({
			Value = turnsLeftLightScreen,
			MoveId = MoveData.Values.LightScreenId or 113,
			getText = function(self)
				return string.format("%s: %s %s%s %s",
					Resources.Game.MoveNames[MoveData.Values.LightScreenId or 113] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s"),
					Resources[SCREEN.Key].TextTurnsRemaining
				)
			end,
		}))
	end
	-- SPIKES
	if sideStatusMap[4] then
		local amountSpikes = Memory.readbyte(sideTimersBase + SCREEN.Addresses.offsetTimerSpikes)
		table.insert(SIDE_DETAILS, SCREEN.IBattleDetail:new({
			Value = amountSpikes,
			MoveId = MoveData.Values.SpikesId or 191,
			getText = function(self)
				return string.format("%s: %s",
					Resources.Game.MoveNames[MoveData.Values.SpikesId or 191] or Constants.BLANKLINE,
					self.Value
				)
			end,
		}))
	end
	-- SAFEGUARD
	if sideStatusMap[5] then
		local turnsLeftSafeguard = Memory.readbyte(sideTimersBase + SCREEN.Addresses.offsetTimerSafeguard)
		table.insert(SIDE_DETAILS, SCREEN.IBattleDetail:new({
			Value = turnsLeftSafeguard,
			MoveId = MoveData.Values.SafeguardId or 219,
			getText = function(self)
				return string.format("%s: %s %s%s %s",
					Resources.Game.MoveNames[MoveData.Values.SafeguardId or 219] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s"),
					Resources[SCREEN.Key].TextTurnsRemaining
				)
			end,
		}))
	end
	-- MIST
	if sideStatusMap[8] then
		local turnsLeftMist = Memory.readbyte(sideTimersBase + SCREEN.Addresses.offsetTimerMist)
		table.insert(SIDE_DETAILS, SCREEN.IBattleDetail:new({
			Value = turnsLeftMist,
			MoveId = MoveData.Values.MistId or 54,
			getText = function(self)
				return string.format("%s: %s %s%s %s",
					Resources.Game.MoveNames[MoveData.Values.MistId or 54] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s"),
					Resources[SCREEN.Key].TextTurnsRemaining
				)
			end,
		}))
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.GameFuncs.readDisableStruct(index)
	if not index or index < 0 or index > 3 then
		return
	end
	--[[
		gDisableStructs
		/*0x00*/ u32 transformedMonPersonality;
		/*0x04*/ u16 disabledMove;
		/*0x06*/ u16 encoredMove;
		/*0x08*/ u8 protectUses;
		/*0x09*/ u8 stockpileCounter;
		/*0x0A*/ u8 substituteHP;
		/*0x0B*/ u8 disableTimer : 4;
		/*0x0B*/ u8 disableTimerStartValue : 4;
		/*0x0C*/ u8 encoredMovePos;
		/*0x0D*/ u8 unkD;
		/*0x0E*/ u8 encoreTimer : 4;
		/*0x0E*/ u8 encoreTimerStartValue : 4;
		/*0x0F*/ u8 perishSongTimer : 4;
		/*0x0F*/ u8 perishSongTimerStartValue : 4;
		/*0x10*/ u8 furyCutterCounter;
		/*0x11*/ u8 rolloutTimer : 4;
		/*0x11*/ u8 rolloutTimerStartValue : 4;
		/*0x12*/ u8 chargeTimer : 4;
		/*0x12*/ u8 chargeTimerStartValue : 4;
		/*0x13*/ u8 tauntTimer:4;
		/*0x13*/ u8 tauntTimer2:4;
		/*0x14*/ u8 battlerPreventingEscape;
		/*0x15*/ u8 battlerWithSureHit;
		/*0x16*/ u8 isFirstTurn;
		/*0x17*/ u8 unk17;
		/*0x18*/ u8 truantCounter : 1;
		/*0x18*/ u8 truantSwitchInHack : 1; // Unused here, but used in pokeemerald
		/*0x18*/ u8 unk18_a_2 : 2;
		/*0x18*/ u8 mimickedMoves : 4;
		/*0x19*/ u8 rechargeTimer;
		/*0x1A*/ u8 unk1A[2];
	]]

	local MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	if not MON_DETAILS then
		SCREEN.Data.PerMonDetails[index] = {}
		MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	end

	local function _getSourceMon(sourceIndex)
		local sourceMonIndex = Battle.Combatants[Battle.IndexMap[sourceIndex] or -1] or -1
		local sourcePokemon = Tracker.getPokemon(sourceMonIndex, sourceIndex % 2 == 0) or {}
		if not PokemonData.isValid(sourcePokemon.pokemonID) then
			return nil
		end
		return sourcePokemon
	end

	local disableStructBase = GameSettings.gDisableStructs + (index * SCREEN.Addresses.sizeofDisableStruct)

	-- DISABLE
	local disabledMove = Memory.readword(disableStructBase + 0x04)
	if disabledMove ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = disabledMove,
			MoveId = MoveData.Values.DisableId or 50,
			getText = function(self)
				return string.format("%s (%s)",
					Resources.Game.MoveNames[MoveData.Values.DisableId or 50] or Constants.BLANKLINE,
					Resources.Game.MoveNames[self.Value] or Constants.BLANKLINE
			)
			end,
		}))
	end
	-- ENCORE
	local encoredMove = Memory.readword(disableStructBase + 0x06)
	if encoredMove ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = encoredMove,
			MoveId = MoveData.Values.EncoreId or 227,
			getText = function(self)
				return string.format("%s (%s)",
					Resources.Game.MoveNames[MoveData.Values.EncoreId or 227] or Constants.BLANKLINE,
					Resources.Game.MoveNames[self.Value] or Constants.BLANKLINE
			)
			end,
		}))
	end
	-- PROTECT (or detect I guess)
	local protectUses = Memory.readbyte(disableStructBase + 0x08)
	if protectUses ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = protectUses,
			MoveId = MoveData.Values.ProtectId or 227,
			getText = function(self)
				return string.format("%s: %s",
					Resources[SCREEN.Key].EffectProtectUses,
					self.Value
				)
			end,
		}))
	end
	-- STOCKPILE COUNT
	local stockpileCount = Memory.readbyte(disableStructBase + 0x09)
	if stockpileCount ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = stockpileCount,
			MoveId = MoveData.Values.StockpileId or 254,
			getText = function(self)
				return string.format("%s: %s",
					Resources.Game.MoveNames[MoveData.Values.StockpileId or 254] or Constants.BLANKLINE,
					self.Value
				)
			end,
		}))
	end
	-- PERISH SONG
	if SCREEN.Data.PerishSongInEffect then
		local perishSongCount = 1 + Utils.getbits(Memory.readword(disableStructBase + 0x0F), 0, 4)
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = perishSongCount,
			MoveId = MoveData.Values.PerishSongId or 195,
			getText = function(self)
				return string.format("%s: %s",
					Resources[SCREEN.Key].EffectPerishCount,
					self.Value
				)
			end,
		}))
	end
	-- FURY CUTTER
	local furyCutterCount = Memory.readbyte(disableStructBase + 0x10)
	if furyCutterCount ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = stockpileCount,
			MoveId = MoveData.Values.FuryCutterId or 210,
			getText = function(self)
				return string.format("%s: %s",
					Resources.Game.MoveNames[MoveData.Values.FuryCutterId or 210] or Constants.BLANKLINE,
					self.Value
				)
			end,
		}))
	end
	-- ROLLOUT
	local rolloutCount = Utils.getbits(Memory.readword(disableStructBase + 0x11), 0, 4)
	if rolloutCount ~= 0 then
		local lockedMove = Memory.readword(GameSettings.gLockedMoves + (index * 0x02))
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = rolloutCount,
			MoveId = MoveData.Values.RolloutId or 205,
			getText = function(self)
				return string.format("%s: %s %s%s %s",
					Resources.Game.MoveNames[lockedMove] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s"),
					Resources[SCREEN.Key].TextTurnsRemaining
				)
			end,
		}))
	end
	-- TAUNT
	local tauntTimer = Utils.getbits(Memory.readword(disableStructBase + 0x13), 0, 4)
	if tauntTimer ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			Value = tauntTimer,
			MoveId = MoveData.Values.TauntId or 269,
			getText = function(self)
				return string.format("%s: %s %s%s %s",
					Resources.Game.MoveNames[MoveData.Values.TauntId or 269] or Constants.BLANKLINE,
					self.Value,
					Resources[SCREEN.Key].TextTurn,
					(self.Value == 1 and "" or "s"),
					Resources[SCREEN.Key].TextTurnsRemaining
				)
			end,
		}))
	end
	-- TRAPPED (REDUNDANT)
	-- local cannotEscapeSource = Memory.readbyte(disableStructBase + 0x14)
	-- if SCREEN.PerMonDetails[index].Trapped then
	-- 	SCREEN.PerMonDetails[index].Trapped.source = cannotEscapeSource
	-- end
	-- LOCKON
	if SCREEN.Data.LockOnInEffect then
		local lockOnSource = Memory.readbyte(disableStructBase + 0x15)
		local sourcePokemon = _getSourceMon(lockOnSource)
		if sourcePokemon then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				Value = sourcePokemon.pokemonID,
				MoveId = MoveData.Values.LockOnId or 199,
				PokemonId = sourcePokemon.pokemonID,
				getText = function(self)
					return string.format("%s (%s)",
						Resources.Game.MoveNames[MoveData.Values.LockOnId or 199] or Constants.BLANKLINE,
						PokemonData.Pokemon[self.Value].name
					)
				end,
			}))
		end
	end
	local truantCheck = Memory.readbyte(disableStructBase + 0x18)
	if truantCheck == 1 then -- "1" means truant turn is active
		local sourcePokemon = _getSourceMon(index) or {}
		local abilities = Tracker.getAbilities(sourcePokemon.pokemonID)
		local isTruantTracked = (abilities[1].id == AbilityData.Values.TruantId) or (abilities[2].id == AbilityData.Values.TruantId)
		-- Only display that the mon is loafing if the ability is already being tracked
		if isTruantTracked then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				AbilityId = AbilityData.Values.TruantId or 54,
				getText = function(self)
					return Resources[SCREEN.Key].EffectTruant
				end,
			}))
		end
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.GameFuncs.readWishStruct(index)
	if not index or index < 0 or index > 3 then
		return
	end
	--[[
		gWishFutureKnock
		struct WishFutureKnock
		{
			u8 futureSightCounter[MAX_BATTLERS_COUNT];
			u8 futureSightAttacker[MAX_BATTLERS_COUNT];
			s32 futureSightDmg[MAX_BATTLERS_COUNT];
			u16 futureSightMove[MAX_BATTLERS_COUNT];
			u8 wishCounter[MAX_BATTLERS_COUNT];
			u8 wishMonId[MAX_BATTLERS_COUNT];
			u8 weatherDuration;
			u8 knockedOffMons[2];
		};
	]]

	local MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	if not MON_DETAILS then
		SCREEN.Data.PerMonDetails[index] = {}
		MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	end

	local function _getSourceMon(sourceIndex)
		local sourceMonIndex = Battle.Combatants[Battle.IndexMap[sourceIndex] or -1] or -1
		local sourcePokemon = Tracker.getPokemon(sourceMonIndex, sourceIndex % 2 == 0) or {}
		if not PokemonData.isValid(sourcePokemon.pokemonID) then
			return nil
		end
		return sourcePokemon
	end

	local wishStructBase = GameSettings.gWishFutureKnock

	-- FUTURE SIGHT
	local futureSightCounter = Memory.readbyte(wishStructBase + SCREEN.Addresses.offsetWishStructFutureCounter + index)
	if futureSightCounter ~= 0 then
		local futureSightSource = Memory.readbyte(wishStructBase + SCREEN.Addresses.offsetWishStructFutureSource + index)
		local sourcePokemon = _getSourceMon(futureSightSource)
		if sourcePokemon then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				Value = {
					futureSightCounter,
					sourcePokemon.pokemonID,
				},
				PokemonId = sourcePokemon.pokemonID,
				-- TODO: Doubt this all fits
				getText = function(self)
					return string.format("%s: %s %s%s %s (%s)",
						Resources[SCREEN.Key].EffectFutureSight,
						self.Value[1],
						Resources[SCREEN.Key].TextTurn,
						(self.Value[1] == 1 and "" or "s"),
						Resources[SCREEN.Key].TextTurnsRemaining,
						PokemonData.Pokemon[self.Value[2]].name
					)
				end,
			}))
		end
	end
	-- WISH
	local wishCounter = Memory.readbyte(wishStructBase + SCREEN.Addresses.offsetWishStructWishCounter + index)
	if wishCounter ~= 0 then
		local wishSource = Memory.readbyte(wishStructBase + SCREEN.Addresses.offsetWishStructWishSource + index)
		local sourcePokemon = _getSourceMon(wishSource)
		if sourcePokemon then
			table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
				Value = {
					futureSightCounter,
					sourcePokemon.pokemonID,
				},
				MoveId = MoveData.Values.WishId or 273,
				PokemonId = sourcePokemon.pokemonID,
				-- TODO: Doubt this all fits
				getText = function(self)
					return string.format("%s: %s %s%s %s (%s)",
						Resources.Game.MoveNames[MoveData.Values.WishId or 273] or Constants.BLANKLINE,
						self.Value[1],
						Resources[SCREEN.Key].TextTurn,
						(self.Value[1] == 1 and "" or "s"),
						Resources[SCREEN.Key].TextTurnsRemaining,
						PokemonData.Pokemon[self.Value[2]].name
					)
				end,
			}))
		end
	end
	-- KNOCK OFF
	local indexOffset = (index < 2 and 0) or 1
	local knockOffCheck = Memory.readbyte(wishStructBase + SCREEN.Addresses.offsetWishStructKnockOff + index + indexOffset)
	if knockOffCheck ~= 0 then
		table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
			MoveId = MoveData.Values.KnockOffId or 282,
			getText = function(self)
				return Resources.Game.MoveNames[MoveData.Values.KnockOffId or 282] or Constants.BLANKLINE
			end,
		}))
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.GameFuncs.readOther(index)
	if not index or index < 0 or index > 3 then
		return
	end
	local MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	if not MON_DETAILS then
		SCREEN.Data.PerMonDetails[index] = {}
		MON_DETAILS = SCREEN.Data.PerMonDetails[index]
	end

	local lastMoveID = -1
	--local lastMoveID = Battle.LastMoves[index] or 0 -- not actually implemented
	--local lastMoveID = Battle.lastEnemyMoveId -- only set if the move dealt damage
	table.insert(MON_DETAILS, SCREEN.IBattleDetail:new({
		Value = lastMoveID,
		MoveId = lastMoveID,
		getText = function(self)
			return string.format("%s: %s",
				Resources[SCREEN.Key].TextLastMove,
				(MoveData.isValid(self.Value) and Resources.Game.MoveNames[self.Value]) or Constants.BLANKLINE
			)
		end,
	}))
end
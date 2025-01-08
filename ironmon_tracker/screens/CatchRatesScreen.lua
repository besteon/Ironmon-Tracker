CatchRatesScreen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
		positive = "Positive text",
		negative = "Negative text",
	},
	Data = {
		pokemon = nil,
		catchRates = {},
	},
}
SCREEN = CatchRatesScreen
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN + 10,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
}
local CELL1_W = 32

local PERCENT_FORMAT = "%s%%"

SCREEN.Buttons = {
	PokemonsName = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return "Pokémon:" end,
		box = { CANVAS.X + 2, CANVAS.Y + 2, CANVAS.W / 2 - 4, 11 },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local text, textColor
			if SCREEN.Data.isReady and SCREEN.Data.pokemon then
				text = PokemonData.Pokemon[SCREEN.Data.pokemon.pokemonID].name
				textColor = Theme.COLORS[SCREEN.Colors.highlight]
			else
				text = Constants.BLANKLINE
				textColor = Theme.COLORS[SCREEN.Colors.text]
			end
			Drawing.drawText(x + w + 1, y, text, textColor, shadowcolor)
		end,
	},
	PokemonsHPPercent = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return string.format("%s:", Resources.CatchRatesScreen.PokemonsHPPercent) end,
		box = { CANVAS.X + 2, CANVAS.Y + 13, CANVAS.W / 2 - 4, 11 },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local text, textColor
			if SCREEN.Data.isReady and SCREEN.Data.hpPercent then
				-- Round to nearest tens place
				local roundedPerc = math.floor(SCREEN.Data.hpPercent / 10 + 0.5) * 10
				text = string.format(PERCENT_FORMAT, roundedPerc)
				textColor = Theme.COLORS[SCREEN.Colors.highlight]
			else
				text = Constants.BLANKLINE
				textColor = Theme.COLORS[SCREEN.Colors.text]
			end
			Drawing.drawText(x + w + 1, y, text, textColor, shadowcolor)
			if (SCREEN.Data.hpAdjust or 0) ~= 0 then
				local textW = Utils.calcWordPixelLength(text)
				local hpAdjust = string.format("%s " .. PERCENT_FORMAT,
					SCREEN.Data.hpAdjust > 0 and "+" or "--",
					math.abs(SCREEN.Data.hpAdjust)
				)
				Drawing.drawText(x + w + textW + 3, y, hpAdjust, Theme.COLORS[SCREEN.Colors.text], shadowcolor)
			end
		end,
	},
	PokemonsStatus = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return string.format("%s:", Resources.CatchRatesScreen.PokemonsStatus) end,
		box = { CANVAS.X + 2, CANVAS.Y + 24, CANVAS.W / 2 - 4, 11 },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local text, textColor
			if SCREEN.Data.isReady and SCREEN.Data.status then
				text = string.format("%s", SCREEN.Data.status)
				textColor = Theme.COLORS[SCREEN.Colors.highlight]
			else
				text = Constants.BLANKLINE
				textColor = Theme.COLORS[SCREEN.Colors.text]
			end
			Drawing.drawText(x + w + 1, y, text, textColor, shadowcolor)
		end,
	},
	HPMinus = {
		type = Constants.ButtonTypes.STAT_STAGE,
		getText = function() return Constants.STAT_STATES[2].text end,
		textColor = Constants.STAT_STATES[2].textColor,
		box = { CANVAS.X + CANVAS.W - 19, CANVAS.Y + 14, 8, 8 },
		onClick = function(self)
			if not SCREEN.Data.isReady then
				return
			end
			SCREEN.Data.hpAdjust = math.max(SCREEN.Data.hpAdjust - 10, -90) -- min of 90
			Program.redraw(true)
		end,
	},
	HPPlus = {
		type = Constants.ButtonTypes.STAT_STAGE,
		getText = function() return Constants.STAT_STATES[1].text end,
		textColor = Constants.STAT_STATES[1].textColor,
		box = { CANVAS.X + CANVAS.W - 11, CANVAS.Y + 14, 8, 8 },
		onClick = function(self)
			if not SCREEN.Data.isReady then
				return
			end
			SCREEN.Data.hpAdjust = math.min(SCREEN.Data.hpAdjust + 10, 90) -- max of 90
			Program.redraw(true)
		end,
	},
	TableHeaders = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return Utils.toUpperUTF8(Resources.CatchRatesScreen.HeaderBall) end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 3, CANVAS.Y + 35, CANVAS.W / 2, 11 },
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local textColor = Theme.COLORS[self.textColor]
			local bagText = Utils.toUpperUTF8(Resources.CatchRatesScreen.HeaderBag)
			local rateText = Utils.toUpperUTF8(Resources.CatchRatesScreen.HeaderRate)
			Drawing.drawText(x + w, y, bagText, textColor, shadowcolor)
			Drawing.drawText(x + w + CELL1_W, y, rateText, textColor, shadowcolor)
		end,
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { CANVAS.X + 56, CANVAS.Y + 126, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { CANVAS.X + 46, CANVAS.Y + 127, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self) SCREEN.Pager:prevPage() end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { CANVAS.X + 86, CANVAS.Y + 127, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self) SCREEN.Pager:nextPage() end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or TrackerScreen)
		SCREEN.previousScreen = nil
	end),
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer, sortFunc)
		table.sort(self.Buttons, sortFunc or self.defaultSort)
		local cutoffX = CANVAS.X + CANVAS.W
		local cutoffY = CANVAS.Y + CANVAS.H - 10
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local text = string.format("%s/%s", self.currentPage, self.totalPages)
		local bufferSize = 5 - text:len()
		return string.rep(" ", bufferSize) .. text
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

function CatchRatesScreen.initialize()
	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
	SCREEN.clearBuiltData()
	SCREEN.refreshButtons()
end

function CatchRatesScreen.buildScreen(pokemon)
	pokemon = pokemon or TrackerAPI.getEnemyPokemon()
	if type(pokemon) ~= "table" or not PokemonData.isValid(pokemon.pokemonID) then
		return false
	end
	SCREEN.clearBuiltData()
	SCREEN.refreshDataValues(pokemon)

	-- Catch Rate table rows
	for ballId, _ in ipairs(MiscData.PokeBalls or {}) do
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function() return Resources.Game.ItemNames[ballId] end,
			textColor = SCREEN.Colors.text,
			ballId = ballId,
			quantity = (Program.GameData.Items.PokeBalls[ballId] or 0),
			hasInBag = (Program.GameData.Items.PokeBalls[ballId] or 0) > 0,
			catchRate = SCREEN.Data.catchRates[ballId],
			dimensions = { width = CANVAS.W / 2, height = 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return self.pageVisible == SCREEN.Pager.currentPage end,
			updateSelf = function(self)
				self.quantity = Program.GameData.Items.PokeBalls[ballId] or 0
				self.hasInBag = self.quantity > 0
				self.catchRate = SCREEN.Data.catchRates[ballId]
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local bagText = self.quantity
				local rateText = string.format(PERCENT_FORMAT, self.catchRate)
				local textColor = Theme.COLORS[self.textColor]
				local rateColor
				local borderColor = Theme.COLORS[self.boxColors[1]]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				if self.quantity == 0 then
					textColor = textColor - 0x60000000
				elseif self.catchRate >= 100 then
					rateColor = Theme.COLORS[SCREEN.Colors.positive]
				end
				-- Draw table row border and dividers
				gui.drawRectangle(x, y - 1, w * 2 - 6, h + 2, borderColor, bgColor)
				gui.drawLine(x + w - 2, y - 1, x + w - 2, y + h + 1, borderColor)
				gui.drawLine(x + w + CELL1_W - 2, y - 1, x + w + CELL1_W - 2, y + h + 1, borderColor)
				-- Draw each cell's text
				Drawing.drawText(x + 2, y, self:getCustomText(), textColor, shadowcolor)
				Drawing.drawNumber(x + w, y, bagText, 5, textColor, shadowcolor)
				Drawing.drawNumber(x + w + CELL1_W, y, rateText, 5, rateColor or textColor, shadowcolor)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, button)
	end

	-- List the balls owned in the player's bag first, ordered by catch rate
	local function sortFunc(a, b)
		return a.hasInBag and not b.hasInBag
			or (a.hasInBag == b.hasInBag and a.catchRate > b.catchRate)
			or (a.hasInBag == b.hasInBag and a.catchRate == b.catchRate and a.ballId < b.ballId)
	end
	local tableHeadersY = SCREEN.Buttons.TableHeaders.box[2]
	SCREEN.Pager:realignButtonsToGrid(CANVAS.X + 3, tableHeadersY + 12, 20, 2, sortFunc)

	SCREEN.Data.isReady = true
	return true
end

function CatchRatesScreen.refreshDataValues(pokemon)
	pokemon = pokemon or TrackerAPI.getEnemyPokemon()
	if not pokemon then
		return
	end
	SCREEN.Data.pokemon = pokemon

	-- POKEMON'S ESTIMATED HP PERCENT
	local hpMax = pokemon.stats.hp
	local hpCurrent = pokemon.curHP
	-- Estimated calculation borrowed from `PokemonData.calcCatchRate()`
	local estimatedCurrHP = math.floor(math.ceil(hpCurrent / hpMax * 10) / 10 * hpMax)
	SCREEN.Data.hpPercent = math.floor(estimatedCurrHP / hpMax * 100)

	-- POKEMON'S STATUS
	if pokemon.status ~= MiscData.StatusType.None then
		SCREEN.Data.status = MiscData.StatusCodeMap[pokemon.status]
	else
		SCREEN.Data.status = nil
	end

	-- ALL CATCH RATES
	SCREEN.Data.catchRates = {}
	local estimatedHP = math.floor(hpMax * (SCREEN.Data.hpPercent + SCREEN.Data.hpAdjust) / 100 + 0.5)
	local terrain = Memory.readword(GameSettings.gBattleTerrain) -- Used for Dive Ball only
	for ballId, _ in ipairs(MiscData.PokeBalls or {}) do
		SCREEN.Data.catchRates[ballId] = PokemonData.calcCatchRate(
			pokemon.pokemonID,
			hpMax,
			estimatedHP,
			pokemon.level,
			pokemon.status,
			ballId,
			terrain,
			Battle.turnCount
		)
	end
end

function CatchRatesScreen.refreshButtons()
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
end

function CatchRatesScreen.clearBuiltData()
	SCREEN.Data = {}
	SCREEN.Data.hpAdjust = 0
	SCREEN.Data.isReady = false
	SCREEN.Pager.Buttons = {}
end

-- USER INPUT FUNCTIONS
function CatchRatesScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function CatchRatesScreen.drawScreen()
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
	local headerText = Utils.toUpperUTF8(Resources.CatchRatesScreen.Title)
	local headerColor = Theme.COLORS["Header text"]
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, headerColor, headerShadow)

	-- Draw all buttons
	SCREEN.refreshDataValues()
	SCREEN.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
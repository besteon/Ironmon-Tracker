TrainersOnRouteScreen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		negative = "Negative text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Data = {
		routeId = nil,
		trainerList = {},
		trainerCount = "",
	},
}
local SCREEN = TrainersOnRouteScreen

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
	RouteName = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		getText = function()
			if SCREEN.Data.isReady then
				local routeName = RouteData.getRouteOrAreaName(SCREEN.Data.routeId, true)
				return string.format("%s  %s", routeName or Constants.BLANKLINE, SCREEN.Data.trainerCount)
			else
				return string.format("%s  %s", string.rep(Constants.HIDDEN_INFO, 3), SCREEN.Data.trainerCount)
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 4, 10, 12 },
		isVisible = function(self) return SCREEN.Data.isReady end,
	},
	TotalPokemonOnTrainers = {
		type = Constants.ButtonTypes.NO_BORDER,
		getCustomText = function()
			if SCREEN.Data.isReady then
				return string.format("%s/%s", SCREEN.Data.pokemonDefeated or 0, SCREEN.Data.pokemonTotal or 0)
			else
				return string.rep(Constants.HIDDEN_INFO, 3)
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 137, 9, 9 },
		isVisible = function(self) return SCREEN.Data.isReady end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local textColor = Theme.COLORS[self.textColor]
			Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL_SMALL, x, y, TrackerScreen.PokeBalls.ColorList, shadowcolor)
			Drawing.drawText(x + w + 1, y - 2, self:getCustomText(), textColor, shadowcolor)
		end,
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 56, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 86, Constants.SCREEN.MARGIN + 136, 10, 10, },
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

function TrainersOnRouteScreen.initialize()
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

---Retrieves and builds the data needed to draw this screen; stored in `TrainersOnRouteScreen.Data`
---@param routeId number
---@return boolean success
function TrainersOnRouteScreen.buildScreen(routeId)
	if not RouteData.hasRoute(routeId) then
		return false
	end
	SCREEN.clearBuiltData()

	-- Internal Tracker data about the route
	local route = RouteData.Info[routeId]
	SCREEN.Data.routeId = routeId
	SCREEN.Data.trainerList = {} -- TODO: Unsure if needed
	SCREEN.Data.pokemonDefeated = 0
	SCREEN.Data.pokemonTotal = 0

	local ROW_START_X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 7
	local ROW_START_Y = Constants.SCREEN.MARGIN + 23
	local ROW_WIDTH = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2 - 8
	local ROW_HEIGHT = 33
	local COL1_X = 0
	local COL2_X = 35

	local routesToUse = {}
	if route.area then
		for _, id in ipairs(route.area) do
			table.insert(routesToUse, id)
		end
	else
		table.insert(routesToUse, routeId)
	end
	local trainersToUse = {}
	for _, subRouteId in ipairs(routesToUse) do
		local subRoute = RouteData.Info[subRouteId] or {}
		for _, trainerId in pairs(subRoute.trainers or {}) do
			if TrainerData.shouldUseTrainer(trainerId) then
				table.insert(trainersToUse, trainerId)
			end
		end
	end

	local trainerCount, trainersDefeated = 0, 0
	for i, trainerId in pairs(trainersToUse) do
		local trainerGame = Program.readTrainerGameData(trainerId)
		local trainerInternal = TrainerData.getTrainerInfo(trainerId)
		table.insert(SCREEN.Data.trainerList, trainerGame)

		trainerCount = trainerCount + 1
		if trainerGame.defeated then
			trainersDefeated = trainersDefeated + 1
			SCREEN.Data.pokemonDefeated = SCREEN.Data.pokemonDefeated + trainerGame.partySize
		end
		SCREEN.Data.pokemonTotal = SCREEN.Data.pokemonTotal + trainerGame.partySize

		local buttonRow = {
			type = Constants.ButtonTypes.NO_BORDER,
			buttonList = {},
			trainer = trainerGame,
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Allow checkboxes to filter defeated trainers or not
				return true
			end,
			onClick = function(self)
				TrainerInfoScreen.previousScreen = SCREEN
				TrainerInfoScreen.buildScreen(trainerId)
				Program.changeScreenView(TrainerInfoScreen)
			end,
			draw = function(self, shadowcolor)
				for _, button in ipairs(self.buttonList or {}) do
					Drawing.drawButton(button, shadowcolor)
				end
			end,
		}
		table.insert(SCREEN.Pager.Buttons, buttonRow)

		-- ICON
		local iconBtn = {
			type = Constants.ButtonTypes.IMAGE,
			image = TrainerData.getPortraitIcon(trainerInternal.class),
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 32, 32 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + COL1_X
				self.box[2] = box[2]
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local borderColor = Theme.COLORS[SCREEN.Colors.border]
				-- Draw an extra border, and shadows, around the image and id label
				gui.drawLine(x + w + 1, y - 1, x + w + 1, y + h + 1, shadowcolor)
				gui.drawLine(x, y + h + 1, x + w, y + h + 1, shadowcolor)
				gui.drawRectangle(x - 1, y - 2, w + 1, h + 2, borderColor)
				-- Darken the icon if trainer is defeated
				if trainerGame.defeated then
					local negativeColor = Theme.COLORS[SCREEN.Colors.negative]
					gui.drawRectangle(x, y - 1, w - 1, h, 0x70000000, 0x70000000)
					gui.drawLine(x, y - 1, x + w - 1, y + h - 1, negativeColor)
					gui.drawLine(x, y, x + w - 1, y + h - 2, negativeColor)
					gui.drawLine(x, y + h - 1, x + w - 1, y - 1, negativeColor)
					gui.drawLine(x, y + h - 2, x + w - 1, y, negativeColor)
				end
			end,
		}
		table.insert(buttonRow.buttonList, iconBtn)

		-- TRAINER CLASS AND NAME
		local trainerName = trainerGame.trainerName
		local trainerClass = trainerGame.trainerClass
		if Utils.isNilOrEmpty(trainerName) then
			trainerName = string.rep(Constants.HIDDEN_INFO, 3)
		end
		if Utils.isNilOrEmpty(trainerClass) then
			trainerClass = string.rep(Constants.HIDDEN_INFO, 3)
		end
		trainerGame.combinedName = Utils.formatSpecialCharacters(string.format("%s %s", trainerClass, trainerName))
		trainerGame.combinedName = Utils.shortenText(trainerGame.combinedName, 92, true)
		local nameBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return trainerGame.combinedName end,
			textColor = SCREEN.Colors.highlight,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 90, 11 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + COL2_X
				self.box[2] = box[2] - 2 + (Constants.SCREEN.LINESPACING * 0)
			end,
		}
		table.insert(buttonRow.buttonList, nameBtn)

		-- LEVEL RANGE
		local minLv, maxLv = 100, 0
		for _, partyMon in ipairs(trainerGame.party) do
			if partyMon.level < minLv then
				minLv = partyMon.level
			end
			if partyMon.level > maxLv then
				maxLv = partyMon.level
			end
		end
		local lvRange
		if minLv == maxLv then
			lvRange = tostring(minLv)
		else
			lvRange = string.format("%s -- %s", minLv, maxLv)
		end
		trainerGame.partyLvRange = string.format("%s.%s", Resources.TrackerScreen.LevelAbbreviation, lvRange )
		local levelRangeBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return trainerGame.partyLvRange end,
			textColor = SCREEN.Colors.text,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 90, 11 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + COL2_X
				self.box[2] = box[2] - 2 + (Constants.SCREEN.LINESPACING * 1)
			end,
		}
		table.insert(buttonRow.buttonList, levelRangeBtn)

		-- PARTY POKEMON AS POKEBALLS
		local partyBallsBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			image = Constants.PixelImages.POKEBALL_SMALL,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 90, 11 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + COL2_X + 2
				self.box[2] = box[2] - 2 + (Constants.SCREEN.LINESPACING * 2) + 1
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local SIZE_OF_BALL = 9
				for j = 0, #trainerGame.party - 1, 1 do
					Drawing.drawImageAsPixels(self.image, x + (j * SIZE_OF_BALL), y, self.iconColors, shadowcolor)
				end
			end,
		}
		if trainerGame.defeated then
			partyBallsBtn.iconColors = TrackerScreen.PokeBalls.ColorListFainted
		elseif TrainerData.isGiovanni(trainerId) then
			partyBallsBtn.image = Constants.PixelImages.MASTERBALL_SMALL
			partyBallsBtn.iconColors = TrackerScreen.PokeBalls.ColorListMasterBall
		else
			partyBallsBtn.iconColors = TrackerScreen.PokeBalls.ColorList
		end
		table.insert(buttonRow.buttonList, partyBallsBtn)

		-- CHECK IF DOUBLES
		if trainerGame.doubleBattle then
			local doubleBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				getText = function(self) return string.format("%s!", Resources.TrainerInfoScreen.LabelDouble) end,
				textColor = SCREEN.Colors.highlight,
				isVisible = function(self) return buttonRow:isVisible() end,
				box = { -1, -1, 90, 11 },
				alignToBox = function(self, box)
					self.box[1] = box[1] + COL2_X + 60
					self.box[2] = box[2] - 2 + Constants.SCREEN.LINESPACING + 4
				end,
			}
			table.insert(buttonRow.buttonList, doubleBtn)
		end
	end

	if trainerCount > 0 then
		SCREEN.Data.trainerCount = string.format("(%s/%s)", trainersDefeated, trainerCount)
	else
		SCREEN.Data.trainerCount = ""
	end

	-- Place button rows into the grid and update each of their contained buttons
	SCREEN.Pager:realignButtonsToGrid(ROW_START_X, ROW_START_Y, 1, 5)
	for _, buttonRow in ipairs(SCREEN.Pager.Buttons) do
		for _, button in ipairs (buttonRow.buttonList or {}) do
			if type(button.alignToBox) == "function" then
				button:alignToBox(buttonRow.box)
			end
		end
	end

	SCREEN.Data.isReady = true

	return true
end

function TrainersOnRouteScreen.refreshButtons()
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

function TrainersOnRouteScreen.clearBuiltData()
	SCREEN.Data.routeId = nil
	SCREEN.Data.trainerList = {}
	SCREEN.Data.trainerCount = ""
	SCREEN.Data.pokemonDefeated = 0
	SCREEN.Data.pokemonTotal = 0
	SCREEN.Data.isReady = false
	SCREEN.Pager.Buttons = {}
end

-- USER INPUT FUNCTIONS
function TrainersOnRouteScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function TrainersOnRouteScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
		text = Theme.COLORS[SCREEN.Colors.text],
		highlight = Theme.COLORS[SCREEN.Colors.highlight],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- TODO: Show something if no trainers on route
	if #TrainersOnRouteScreen.Pager.Buttons == 0 then
		local wrappedDesc = Utils.getWordWrapLines("No trainers on this route", 32) -- TODO: Language
		local textLineY = Constants.SCREEN.MARGIN + 40
		for _, line in pairs(wrappedDesc) do
			local centeredOffset = Utils.getCenteredTextX(line, canvas.width)
			Drawing.drawText(canvas.x + centeredOffset, textLineY, line, canvas.highlight, canvas.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING
		end
	end

	-- Draw all buttons
	SCREEN.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
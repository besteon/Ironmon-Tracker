TrainerInfoScreen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
		goodValue = "Positive text",
		badValue = "Negative text",
	},
	Data = {
		trainerGame = {},
		trainerInternal = {},
	},
}
local SCREEN = TrainerInfoScreen

local function hasData()
	return SCREEN.Data.trainerGame and SCREEN.Data.trainerGame.trainerId ~= nil
end

SCREEN.Buttons = {
	TrainerIcon = {
		type = Constants.ButtonTypes.IMAGE,
		image = nil,
		getText = function(self)
			if hasData() then
				return string.format("# %s", SCREEN.Data.trainerGame.trainerId)
			else
				return Constants.BLANKLINE
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - 33, Constants.SCREEN.MARGIN + 2, 32, 32 },
		isVisible = function(self) return true end,
		onClick = function(self)
			if hasData() then
				local nextTrainerId = math.random(#TrainerData.OrderedIds)
				for i = 1, 50, 1 do
					if SCREEN.buildScreen(nextTrainerId) then
						break
					end
					nextTrainerId = math.random(#TrainerData.OrderedIds)
				end
				Program.redraw(true)
			end
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local textColor = Theme.COLORS[self.textColor]
			local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			-- Draw an extra border around the image and id label
			gui.drawRectangle(x - 1, y - 2, w + 2, h + 2, borderColor)

			local idText = self:getText()
			local centerX = Utils.getCenteredTextX(idText, w) - 1
			Drawing.drawText(x + centerX, y + 32, self:getText(), textColor, shadowcolor)
			if SCREEN.Data.trainerGame.doubleBattle then
				Drawing.drawText(x, y + 44, "Double", highlightColor, shadowcolor) -- TODO: Language
				Drawing.drawText(x, y + 54, "Battle!", highlightColor, shadowcolor) -- TODO: Language
			end
		end,
	},
	TrainerNameAndClass = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			if hasData() then
				return SCREEN.Data.trainerGame.combinedName or Constants.BLANKLINE
			else
				return Constants.BLANKLINE
			end
		end,
		textColor = SCREEN.Colors.highlight,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 2, 90, 11 },
	},
	TrainerRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		getText = function()
			if hasData() then
				return SCREEN.Data.trainerGame.routeName or Constants.BLANKLINE
			else
				return Constants.BLANKLINE
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 15, 10, 12 },
	},
	TrainerPartySummary = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			if hasData() then
				return SCREEN.Data.trainerGame.partySummary
			else
				return Utils.formatSpecialCharacters("0 Pokémon, Lv.0")
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 30, 90, 11 },
	},
	TrainerTeamIVs = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local outputVal = Constants.BLANKLINE
			if hasData() then
				outputVal = tostring(SCREEN.Data.trainerGame.teamIVs)
			end
			return string.format("%s: %s", "Team IVs", outputVal) -- TODO: Language
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 46, 90, 11 },
	},
	TrainerAI = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local outputVal = Constants.BLANKLINE
			if hasData() then
				outputVal = SCREEN.Data.trainerGame.aiLabel or Constants.BLANKLINE
			end
			return string.format("%s: %s", "A I Script", outputVal) -- TODO: Language
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 57, 90, 11 },
	},
	TrainerItems = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			return string.format("%s:", "Usable Items") -- TODO: Language
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 68, 90, 11 },
		isVisible = function(self) return hasData() and SCREEN.Data.trainerGame.itemList end,
		draw = function(self, shadowcolor)
			if not hasData() then
				return
			end
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Colors.goodValue]
			local itemList = SCREEN.Data.trainerGame.itemList or Constants.BLANKLINE
			Drawing.drawText(x + 7, y + 11, itemList, textColor, shadowcolor)
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		SCREEN.clearBuiltData()
		Program.changeScreenView(TrackerScreen)
	end),
}

--[[ PAGER
SCREEN.Pager = {
	-- CurrentPage = {
	-- 	type = Constants.ButtonTypes.NO_BORDER,
	-- 	getText = function(self) return SCREEN.Pager:getPageText() end,
	-- 	box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 135, 50, 10, },
	-- 	isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	-- },
	-- PrevPage = {
	-- 	type = Constants.ButtonTypes.PIXELIMAGE,
	-- 	image = Constants.PixelImages.LEFT_ARROW,
	-- 	box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 136, 10, 10, },
	-- 	isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	-- 	onClick = function(self)
	-- 		SCREEN.Pager:prevPage()
	-- 	end
	-- },
	-- NextPage = {
	-- 	type = Constants.ButtonTypes.PIXELIMAGE,
	-- 	image = Constants.PixelImages.RIGHT_ARROW,
	-- 	box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 136, 10, 10, },
	-- 	isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	-- 	onClick = function(self)
	-- 		SCREEN.Pager:nextPage()
	-- 	end
	-- },

	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	defaultSort = function(a, b) return a.ordinal < b.ordinal end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		return string.format("%s %s/%s", Resources.AllScreens.Page, self.currentPage, self.totalPages)
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
]]

function TrainerInfoScreen.initialize()
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

function TrainerInfoScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
	-- for _, button in pairs(SCREEN.Pager.Buttons) do
	-- 	if button.updateSelf ~= nil then
	-- 		button:updateSelf()
	-- 	end
	-- end
end

---Retrieves and builds the data needed to draw this screen; stored in `TrainerInfoScreen.Data`
---@param trainerId number
---@return boolean success
function TrainerInfoScreen.buildScreen(trainerId)
	-- SCREEN.Pager.Buttons = {}

	-- Internal Tracker data about the trainer
	local trainerInternal = TrainerData.getTrainerInfo(trainerId)
	if not trainerInternal or trainerInternal == TrainerData.BlankTrainer then
		return false
	end

	-- Game data about the trainer
	local trainerGame = Program.readTrainerGameData(trainerId)
	SCREEN.Data.trainerGame = trainerGame
	SCREEN.Data.trainerInternal = trainerInternal
	SCREEN.Buttons.TrainerIcon.image = TrainerData.getPortraitIcon(trainerInternal.class)

	-- Add new data variables to the trainerGame object
	-- COMBINED NAME AND CLASS
	if trainerInternal.class then
		local trainerName = trainerGame.trainerName
		if Utils.isNilOrEmpty(trainerName) then
			trainerName = string.rep(Constants.HIDDEN_INFO, 3)
		end
		local className = Utils.firstToUpperEachWord(Utils.replaceText(trainerInternal.class.filename or "", "-", " "))
		trainerGame.combinedName = string.format("%s, %s", trainerName, className)
		trainerGame.combinedName = Utils.shortenText(trainerGame.combinedName, 99, true)
	end

	-- ROUTE INFO
	if trainerInternal.routeId and RouteData.hasRoute(trainerInternal.routeId) then
		trainerGame.routeName = RouteData.Info[trainerInternal.routeId].name or Constants.BLANKLINE
	else
		trainerGame.routeName = string.rep(Constants.HIDDEN_INFO, 3)
	end

	-- TEAM SIZE AND LEVEL RANGE
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
	trainerGame.partySummary = string.format("%s Pokémon   (%s.%s)",
		trainerGame.partySize,
		Resources.TrackerScreen.LevelAbbreviation,
		lvRange
	)
	trainerGame.partySummary = Utils.formatSpecialCharacters(trainerGame.partySummary)

	-- TEAM IVS
	local ivTotal = 0
	for _, pokemon in ipairs(trainerGame.party) do
		ivTotal = ivTotal + pokemon.ivs
	end
	trainerGame.teamIVs = math.max(math.floor(ivTotal / #trainerGame.party), 0) -- min of 0

	if trainerGame.teamIVs >= 23 then
		trainerGame.teamIVsColor = SCREEN.Colors.goodValue
	elseif trainerGame.teamIVs >= 11 then
		trainerGame.teamIVsColor = SCREEN.Colors.highlight
	else
		trainerGame.teamIVsColor = SCREEN.Colors.text
	end

	-- SCRIPT AI LABEL
	if Utils.getbits(trainerGame.aiFlags, 2, 1) == 1 then -- AI_SCRIPT_TRY_TO_FAINT
		trainerGame.aiLabel = "Smart"
		trainerGame.aiColor = SCREEN.Colors.goodValue
	elseif Utils.getbits(trainerGame.aiFlags, 1, 1) == 1 then -- AI_SCRIPT_CHECK_VIABILITY
		trainerGame.aiLabel = "Semi-Smart"
		trainerGame.aiColor = SCREEN.Colors.goodValue
	elseif Utils.getbits(trainerGame.aiFlags, 0, 1) == 1 then -- AI_SCRIPT_CHECK_BAD_MOVE
		trainerGame.aiLabel = "Normal"
		trainerGame.aiColor = SCREEN.Colors.text
	elseif trainerGame.aiFlags == 0 then
		trainerGame.aiLabel = "Dumb"
		trainerGame.aiColor = SCREEN.Colors.badValue
	else
		trainerGame.aiLabel = "Other"
		trainerGame.aiColor = SCREEN.Colors.text
	end

	-- ITEMS
	local itemCounts = {}
	for _, itemId in ipairs(trainerGame.items) do
		local itemName = Resources.Game.ItemNames[itemId]
		if itemName then
			itemCounts[itemId] = (itemCounts[itemId] or 0) + 1
		end
	end
	local items = {}
	for itemId, count in pairs(itemCounts) do
		if count == 1 then
			table.insert(items, Resources.Game.ItemNames[itemId])
		else
			table.insert(items, string.format("%s %s", count, Resources.Game.ItemNames[itemId]))
		end
	end
	if #items > 0 then
		table.sort(items, function(a,b) return a < b end) -- lazily sort alphabetically
		trainerGame.itemList = table.concat(items, ", ")
	else
		trainerGame.itemList = nil
	end

	-- Items (some have 2 hypers + 1 full heal)
	-- # of pokemon in party and levels of each

	return true
end

function TrainerInfoScreen.clearBuiltData()
	SCREEN.Data.trainerGame = {}
	SCREEN.Data.trainerInternal = {}
	SCREEN.Buttons.TrainerIcon.image = nil
end

-- USER INPUT FUNCTIONS
function TrainerInfoScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function TrainerInfoScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	-- for _, button in pairs(SCREEN.Pager.Buttons) do
	-- 	Drawing.drawButton(button, canvas.shadow)
	-- end
end
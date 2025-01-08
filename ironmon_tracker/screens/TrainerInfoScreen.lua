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
local VALUE_COL_X = 52

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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - 32, Constants.SCREEN.MARGIN + 2, 32, 32 },
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
			gui.drawRectangle(x - 1, y - 2, w + 1, h + 2, borderColor)
			gui.drawLine(x, y + h + 1, x + w - 1, y + h + 1, shadowcolor)

			local text = self:getText()
			local centerX = Utils.getCenteredTextX(text, w) - 1
			Drawing.drawText(x + centerX, y + 32, text, textColor, shadowcolor)
			if SCREEN.Data.trainerGame.doubleBattle then
				Drawing.drawText(x, y + 44, Resources.TrainerInfoScreen.LabelDouble, highlightColor, shadowcolor)
				Drawing.drawText(x, y + 54, Resources.TrainerInfoScreen.LabelBattle, highlightColor, shadowcolor)
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
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 15, 94, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 15, 10, 12 },
		onClick = function(self)
			if SCREEN.Data.trainerInternal and SCREEN.Data.trainerInternal.routeId then
				if TrainersOnRouteScreen.buildScreen(SCREEN.Data.trainerInternal.routeId) then
					Program.changeScreenView(TrainersOnRouteScreen)
					SCREEN.previousScreen = nil
				end
			end
		end,
	},
	TrainerPartySummary = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			if hasData() then
				return string.format("%s:", SCREEN.Data.trainerGame.pokemonWord)
			else
				return Utils.formatSpecialCharacters("Pokémon:")
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 30, 90, 11 },
		draw = function(self, shadowcolor)
			if not hasData() then return end
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Data.trainerGame.partyLvColor]
			local text = string.format("%s  (%s)", SCREEN.Data.trainerGame.partySize, SCREEN.Data.trainerGame.partyLvRange)
			Drawing.drawText(Constants.SCREEN.WIDTH + VALUE_COL_X, y, text, textColor, shadowcolor)
		end,
	},
	TrainerAverageIVs = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			return string.format("%s:", Resources.TrainerInfoScreen.LabelAvgIvs)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 40, 90, 11 },
		draw = function(self, shadowcolor)
			if not hasData() then return end
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Data.trainerGame.avgIVsColor]
			Drawing.drawText(Constants.SCREEN.WIDTH + VALUE_COL_X, y, SCREEN.Data.trainerGame.avgIVs, textColor, shadowcolor)
		end,
	},
	TrainerAI = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			return string.format("%s:", Resources.TrainerInfoScreen.LabelAIScript)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 50, 90, 11 },
		draw = function(self, shadowcolor)
			if not hasData() then return end
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Data.trainerGame.aiColor]
			Drawing.drawText(Constants.SCREEN.WIDTH + VALUE_COL_X, y, SCREEN.Data.trainerGame.aiLabel, textColor, shadowcolor)
		end,
	},
	TrainerItems = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			return string.format("%s:", Resources.TrainerInfoScreen.LabelUsableItems)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 60, 90, 11 },
		isVisible = function(self) return hasData() and SCREEN.Data.trainerGame.itemList end,
		draw = function(self, shadowcolor)
			if not hasData() then return end
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Colors.goodValue]
			local itemList = SCREEN.Data.trainerGame.itemList or Constants.BLANKLINE
			Drawing.drawText(x + 7, y + 10, itemList, textColor, shadowcolor)
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		SCREEN.clearBuiltData()
		Program.changeScreenView(TrainerInfoScreen.previousScreen or TrackerScreen)
		TrainerInfoScreen.previousScreen = nil
	end),
}

SCREEN.TemporaryButtons = {}

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
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

---Retrieves and builds the data needed to draw this screen; stored in `TrainerInfoScreen.Data`
---@param trainerId number
---@return boolean success
function TrainerInfoScreen.buildScreen(trainerId)
	-- Internal Tracker data about the trainer
	local trainerInternal = TrainerData.getTrainerInfo(trainerId)
	if not trainerInternal or trainerInternal == TrainerData.BlankTrainer then
		return false
	end

	SCREEN.clearBuiltData()

	-- Game data about the trainer
	local trainerGame = Program.readTrainerGameData(trainerId)
	SCREEN.Data.trainerGame = trainerGame
	SCREEN.Data.trainerInternal = trainerInternal
	SCREEN.Buttons.TrainerIcon.image = TrainerData.getPortraitIcon(trainerInternal.class)

	-- Add new data variables to the trainerGame object
	-- COMBINED NAME AND CLASS
	local trainerName = trainerGame.trainerName
	local trainerClass = trainerGame.trainerClass
	if Utils.isNilOrEmpty(trainerName) then
		trainerName = string.rep(Constants.HIDDEN_INFO, 3)
	end
	if Utils.isNilOrEmpty(trainerClass) then
		trainerClass = string.rep(Constants.HIDDEN_INFO, 3)
	end
	trainerGame.combinedName = Utils.formatSpecialCharacters(string.format("%s %s", trainerClass, trainerName))
	trainerGame.combinedName = Utils.shortenText(trainerGame.combinedName, 99, true)

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
	trainerGame.pokemonWord = Utils.formatSpecialCharacters("Pokémon")
	trainerGame.partyLvRange = string.format("%s.%s",
		Resources.TrackerScreen.LevelAbbreviation,
		lvRange
	)
	local leadPokemon = Tracker.getPokemon(1)
	if leadPokemon and leadPokemon.level < minLv then
		trainerGame.partyLvColor = SCREEN.Colors.badValue
	else
		trainerGame.partyLvColor = SCREEN.Colors.highlight
	end

	-- TEAM IVS
	local ivTotal = 0
	for _, pokemon in ipairs(trainerGame.party) do
		ivTotal = ivTotal + pokemon.ivs
	end
	trainerGame.avgIVs = math.max(math.floor(ivTotal / #trainerGame.party), 0) -- min of 0

	if trainerGame.avgIVs > 0 then
		trainerGame.avgIVsColor = SCREEN.Colors.highlight
	else
		trainerGame.avgIVsColor = SCREEN.Colors.text
	end

	-- SCRIPT AI LABEL
	-- Note: Original was going to use different colors for higher AI, decided against it; leaving in code though
	if Utils.getbits(trainerGame.aiFlags, 2, 1) == 1 then -- AI_SCRIPT_TRY_TO_FAINT
		trainerGame.aiLabel = "Smart"
		trainerGame.aiColor = SCREEN.Colors.highlight --SCREEN.Colors.goodValue
	elseif Utils.getbits(trainerGame.aiFlags, 1, 1) == 1 then -- AI_SCRIPT_CHECK_VIABILITY
		trainerGame.aiLabel = "Semi-Smart"
		trainerGame.aiColor = SCREEN.Colors.highlight --SCREEN.Colors.goodValue
	elseif Utils.getbits(trainerGame.aiFlags, 0, 1) == 1 then -- AI_SCRIPT_CHECK_BAD_MOVE
		trainerGame.aiLabel = "Normal"
		trainerGame.aiColor = SCREEN.Colors.text
	elseif trainerGame.aiFlags == 0 then
		trainerGame.aiLabel = "Dumb"
		trainerGame.aiColor = SCREEN.Colors.highlight --SCREEN.Colors.badValue
	else
		trainerGame.aiLabel = "Complex"
		trainerGame.aiColor = SCREEN.Colors.highlight --SCREEN.Colors.text
	end

	-- USABLE ITEMS
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

	-- PARTY POKEMON, LEVELS, AND STATUS
	local trainerIdCurrentBattle = TrackerAPI.getOpponentTrainerId()
	SCREEN.TemporaryButtons = {}

	for i, pokemon in ipairs(trainerGame.party) do
		local button = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			-- Only display pokemon icon if trainer is defeated or mon is defeated
			getIconId = function(self)
				if trainerGame.defeated or Options["Open Book Play Mode"] then
					return pokemon.pokemonID
				end
				if trainerId == trainerIdCurrentBattle then
					local enemyMon = Tracker.getPokemon(i, false)
					if enemyMon and enemyMon.curHP <= 0 then
						return pokemon.pokemonID
					end
				end
				return nil
			end,
			image = Constants.PixelImages.POKEBALL,
			iconColors = TrackerScreen.PokeBalls.ColorList,
			getCustomText = function(self)
				return string.format("%s.%s", Resources.TrackerScreen.LevelAbbreviation, pokemon.level)
			end,
			dimensions = { width = 32, height = 32, },
			ordinal = i,
			onClick = function(self)
				if self:getIconId() ~= nil and NotebookPokemonNoteView.buildScreen(pokemon.pokemonID) then
					NotebookPokemonNoteView.previousScreen = SCREEN
					Program.changeScreenView(NotebookPokemonNoteView)
				end
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				y = y + 4 -- offset for icon
				local textColor = Theme.COLORS[SCREEN.Colors.text]
				local borderColor = Theme.COLORS[SCREEN.Colors.border]
				local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
				local text = self:getCustomText()
				local centerX = Utils.getCenteredTextX(text, w) - 1
				-- Draw border box for the Pokémon
				gui.drawRectangle(x - 0, y - 0, w + 0, h + 0, borderColor)
				-- If the Pokémon is not known, draw the pokeball icon
				if self:getIconId() == nil then
					Drawing.drawImageAsPixels(self.image, x + w/2 - 5, y + 7, self.iconColors, shadowcolor)
				end
				-- Draw the Pokémon's level
				Drawing.drawTransparentTextbox(x + centerX, y + h - 10, text, textColor, bgColor, shadowcolor)
				-- Draw a little held item icon if the Pokémon is holding one (don't reveal actual item)
				if pokemon.heldItem ~= 0 then
					Drawing.drawImageAsPixels(Constants.PixelImages.HELD_ITEM, x + w - 6, y + 1)
				end
			end,
		}

		-- Show Master Balls if viewing Giovanni
		if TrainerData.isGiovanni(trainerId) then
			button.image = Constants.PixelImages.MASTERBALL
			button.iconColors = TrackerScreen.PokeBalls.ColorListMasterBall
		end

		SCREEN.TemporaryButtons[i] = button
	end

	-- Align the team party balls in a grid
	table.sort(SCREEN.TemporaryButtons, function(a, b) return a.ordinal < b.ordinal end)
	local gridStartX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 22
	local gridStartY = Constants.SCREEN.MARGIN + 79
	local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - 20
	local cutoffY = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 2
	Utils.gridAlign(SCREEN.TemporaryButtons, gridStartX, gridStartY, 0, 0, false, cutoffX, cutoffY)

	return true
end

function TrainerInfoScreen.clearBuiltData()
	SCREEN.Data.trainerGame = {}
	SCREEN.Data.trainerInternal = {}
	SCREEN.Buttons.TrainerIcon.image = nil
	SCREEN.TemporaryButtons = {}
end

-- USER INPUT FUNCTIONS
function TrainerInfoScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.TemporaryButtons)
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
	SCREEN.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.TemporaryButtons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
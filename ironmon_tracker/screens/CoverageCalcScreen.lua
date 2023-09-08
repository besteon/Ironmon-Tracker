CoverageCalcScreen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Views = { Main = 1, MoveTypes = 2, Pokemon = 3, },
	Tabs = { Immune = 1, Quarter = 2, Half = 3, Neutral = 4, Super = 5, Quad = 6, },
	currentView = 1,
	currentTab = 4,
	leadMovesetIds = {},
	addedTypes = {},
	addedTypesOrdered = {},
}
local SCREEN = CoverageCalcScreen

SCREEN.Buttons = {
	SwitchViewMoveType = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function() return "Add Type" or Resources.CoverageCalcScreen.ButtonAddType end, -- TODO: DEBUG
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 16, Constants.SCREEN.MARGIN + 22, 50, 12 },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		draw = function(self, shadowcolor)
			if #SCREEN.addedTypesOrdered >= 6 then
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				gui.drawLine(x, y, x + w, y + h, Theme.COLORS["Negative text"])
				gui.drawLine(x, y + h, x + w, y, Theme.COLORS["Negative text"])
			end
		end,
		onClick = function(self)
			if #SCREEN.addedTypesOrdered >= 6 then return end
			SCREEN.currentView = SCREEN.Views.MoveTypes
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	ClearMoveTypes = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function() return "Clear All" or Resources.CoverageCalcScreen.ButtonClearTypes end, -- TODO: DEBUG
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 74, Constants.SCREEN.MARGIN + 22, 50, 12 },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		onClick = function(self)
			SCREEN.resetCalc()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	OptionOnlyFullyEvolved = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function() return " Only fully evolved Pokémon" or (" " .. Resources.CoverageCalcScreen.OptionOnlyFullyEvolved) end, -- TODO: DEBUG
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 113, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 113, 8, 8 },
		toggleState = false,
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	SwitchViewPokemon = {
		type = Constants.ButtonTypes.ICON_BORDER,
		getText = function(self) return "View Pokémon" or Resources.CoverageCalcScreen.ButtonViewPokemon end, -- TODO: DEBUG
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 129, 95, 16 },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		onClick = function()
			SCREEN.currentView = SCREEN.Views.Pokemon
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 136, 50, 10, },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Pokemon and SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Pokemon and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Pokemon and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		if SCREEN.currentView ~= SCREEN.Views.Main then
			SCREEN.currentView = SCREEN.Views.Main
			SCREEN.currentTab = SCREEN.Tabs.Neutral
			SCREEN.refreshButtons()
			Program.redraw(true)
		else
			SCREEN.resetCalc()
			SCREEN.refreshButtons()
			Program.changeScreenView(ExtrasScreen)
		end
	end),
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.ordinal < b.ordinal end,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, false, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
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

function CoverageCalcScreen.initialize()
	SCREEN.currentView = 1
	SCREEN.currentTab = 1
	SCREEN.createButtons()

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	SCREEN.resetCalc()
	SCREEN.refreshButtons()
end

function CoverageCalcScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function CoverageCalcScreen.createButtons()
	local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
	local cutoffY = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 5
	local createMoveTypeBtn = function(moveType)
		return {
			type = Constants.ButtonTypes.NO_BORDER,
			moveType = moveType,
			dimensions = { width = 30, height = 12 },
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				gui.drawRectangle(x, y, w + 1, h + 1, shadowcolor)
				gui.drawRectangle(x - 1, y - 1, w + 1, h + 1, Theme.COLORS[self.boxColors[1]], shadowcolor)
				Drawing.drawTypeIcon(self.moveType, x, y)
			end,
		}
	end

	-- MAIN VIEW
	-- Show up to 6 type buttons
	local buttonsToAdd = {}
	for i = 1, 6, 1 do
		local button = createMoveTypeBtn()
		button.updateSelf = function(self) self.moveType = SCREEN.addedTypesOrdered[i] end
		button.isVisible = function(self) return SCREEN.currentView == SCREEN.Views.Main and self.moveType end
		button.onClick = function(self)
			SCREEN.addedTypes[self.moveType] = nil
			table.remove(SCREEN.addedTypesOrdered, i)
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
		table.insert(buttonsToAdd, button)
	end
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 17
	local startY = Constants.SCREEN.MARGIN + 45
	Utils.gridAlign(buttonsToAdd, startX, startY, 8, 8, false, cutoffX, cutoffY)
	for i, button in ipairs(buttonsToAdd) do
		local btnKey = "AddedType" .. i
		SCREEN.Buttons[btnKey] = button
	end

	-- Tabs = { Immune = 1, Quarter = 2, Half = 3, Neutral = 4, Super = 5, Quad = 6, },
	buttonsToAdd = {}
	local effectivenesses = {
		{ "Immune", "0x", "Negative text", },
		{ "Quarter", "1/4x", "Negative text", },
		{ "Half", "1/2x", "Negative text", },
		{ "Neutral", "1x", SCREEN.Colors.text, },
		{ "Super", "2x", "Positive text", },
		{ "Quad", "4x", "Positive text", },
	}
	for _, keys in ipairs(effectivenesses) do
		local tabKey = keys[1]
		local label = keys[2]
		local valueColor = keys[3]
		local labelWidth = Utils.calcWordPixelLength(label)
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return label end,
			textColor = SCREEN.Colors.highlight,
			calcValue = 0,
			tab = SCREEN.Tabs[tabKey],
			dimensions = { width = 20, height = 21 },
			isVisible = function(self) return SCREEN.currentView == SCREEN.Views.Main end,
			updateSelf = function(self)
				self.calcValue = Constants.BLANKLINE -- TODO: Reference the calculated coverage data
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				-- gui.drawLine(x + 2, y + 10, x + labelWidth + 4, y + 10, Theme.COLORS[self.textColor]) -- Underline divider
				local centeredOffsetX = Utils.getCenteredTextX(tostring(self.calcValue), w) - 2
				local colorForValue = valueColor
				if self.calcValue == Constants.BLANKLINE then
					colorForValue = SCREEN.Colors.text
				end
				Drawing.drawText(x + centeredOffsetX, y + 10, self.calcValue, Theme.COLORS[colorForValue], shadowcolor)
			end,
			onClick = function(self)
				SCREEN.currentView = SCREEN.Views.Pokemon
				SCREEN.currentTab = self.tab
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		table.insert(buttonsToAdd, button)
	end
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	startY = Constants.SCREEN.MARGIN + 83
	Utils.gridAlign(buttonsToAdd, startX, startY, 2, 2, false, cutoffX, cutoffY)
	for _, button in ipairs(buttonsToAdd) do
		local btnKey = "Effectiveness" .. button.tab
		SCREEN.Buttons[btnKey] = button
	end

	-- MOVE TYPES VIEW
	buttonsToAdd = {}
	local orderedTypeKeys = {
		"NORMAL", "FIGHTING", "FLYING", "POISON", "GROUND", "ROCK", "BUG", "GHOST", "STEEL",
		"FIRE", "WATER", "GRASS", "ELECTRIC", "PSYCHIC", "ICE", "DRAGON", "DARK",
	}
	for _, typeKey in ipairs(orderedTypeKeys) do
		local moveType = PokemonData.Types[typeKey]
		local button = createMoveTypeBtn(moveType)
		-- Only visible if not already added
		button.isVisible = function(self) return SCREEN.currentView == SCREEN.Views.MoveTypes and not SCREEN.addedTypes[moveType] end
		button.onClick = function(self)
			SCREEN.addedTypes[moveType] = true
			table.insert(SCREEN.addedTypesOrdered, moveType)
			SCREEN.currentView = SCREEN.Views.Main
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
		table.insert(buttonsToAdd, button)
	end
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 17
	startY = Constants.SCREEN.MARGIN + 24
	Utils.gridAlign(buttonsToAdd, startX, startY, 8, 8, false, cutoffX, cutoffY)
	for _, button in ipairs(buttonsToAdd) do
		local btnKey = "MoveType" .. button.moveType
		SCREEN.Buttons[btnKey] = button
	end
end

function CoverageCalcScreen.buildPagedButtons(moveTypes)
	SCREEN.Pager.Buttons = {}

	-- for i, revoInfo in ipairs(revo) do
	-- 	local evoId = revoInfo.id
	-- 	local centeredOffsetX = Utils.getCenteredTextX(evoPercent, 32)
	-- 	local button = {
	-- 		type = Constants.ButtonTypes.POKEMON_ICON,
	-- 		textColor = revoInfo.perc < 0.1 and "Negative text" or SCREEN.Colors.text,
	-- 		id = evoId,
	-- 		ordinal = i,
	-- 		dimensions = { width = 32, height = 32, },
	-- 		boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
	-- 		isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
	-- 		getIconId = function(self) return self.id, SpriteData.Types.Idle end,
	-- 		onClick = function(self)
	-- 			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
	-- 		end,
	-- 		-- Only draw after all the pokemon icons are drawn; executed manually in drawScreen
	-- 		drawAfter = function(self, shadowcolor)
	-- 			local x, y = self.box[1], self.box[2]
	-- 			local textColor = Theme.COLORS[self.textColor]
	-- 			local bgColor = Theme.COLORS[self.boxColors[2]]
	-- 			-- Draw the evo percentage below the icon
	-- 			Drawing.drawTransparentTextbox(x + centeredOffsetX - 1, y + 33, evoPercent, textColor, bgColor, shadowcolor)
	-- 		end,
	-- 	}
	-- 	table.insert(SCREEN.Pager.Buttons, button)
	-- end

	-- local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	-- local y = Constants.SCREEN.MARGIN + Constants.SCREEN.LINESPACING + 2
	-- local colSpacer = 3
	-- local rowSpacer = 7
	-- SCREEN.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

function CoverageCalcScreen.prepopulateMoveTypes()
	SCREEN.resetCalc()

	local leadPokemon = Tracker.getPokemon(1, true)
	if not leadPokemon then
		return
	end

	for _, move in ipairs(leadPokemon.moves or {}) do
		if MoveData.isValid(move.id) then
			table.insert(SCREEN.leadMovesetIds, move.id)

			local moveInternal = MoveData.Moves[move.id]
			if moveInternal.category == MoveData.Categories.PHYSICAL or moveInternal.category == MoveData.Categories.SPECIAL then
				-- TODO: Write exceptions for typeless moves and hidden power
				SCREEN.addedTypes[moveInternal.type] = true
				table.insert(SCREEN.addedTypesOrdered, moveInternal.type)
			end
		end
	end
end

function CoverageCalcScreen.performCalc()
end

function CoverageCalcScreen.resetCalc()
	SCREEN.leadMovesetIds = {}
	SCREEN.addedTypes = {}
	SCREEN.addedTypesOrdered = {}
end

-- USER INPUT FUNCTIONS
function CoverageCalcScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	if SCREEN.currentView == SCREEN.Views.Pokemon then
		Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
	end
end

-- DRAWING FUNCTIONS
function CoverageCalcScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local box = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	if SCREEN.currentView == SCREEN.Views.Main then
		SCREEN.drawMainView(box)
	elseif SCREEN.currentView == SCREEN.Views.MoveTypes then
		SCREEN.drawMoveTypesView(box)
	elseif SCREEN.currentView == SCREEN.Views.Pokemon then
		SCREEN.drawPokemonView(box)
	end

	-- Draw all other buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, box.shadow)
	end
end

function CoverageCalcScreen.drawMainView(box)
	-- Draw top border box
	gui.defaultTextBackground(box.fill)
	gui.drawRectangle(box.x, box.y, box.width, box.height, box.border, box.fill)

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	-- TODO: DEBUG
	Drawing.drawText(box.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8("Coverage Calculator" or Resources.CoverageCalcScreen.Title), Theme.COLORS["Header text"], headerShadow)
end

function CoverageCalcScreen.drawMoveTypesView(box)
	-- Draw top border box
	gui.defaultTextBackground(box.fill)
	gui.drawRectangle(box.x, box.y, box.width, box.height, box.border, box.fill)

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	-- TODO: DEBUG
	Drawing.drawText(box.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8("Add a Move Type" or Resources.CoverageCalcScreen.Title), Theme.COLORS["Header text"], headerShadow)
end

function CoverageCalcScreen.drawPokemonView(box)
	-- Draw top border box
	gui.defaultTextBackground(box.fill)
	gui.drawRectangle(box.x, box.y, box.width, box.height, box.border, box.fill)

	-- Draw each of possibile evolutions Pokemon
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, box.shadow)
	end
	-- Then manually draw all the texts so they properly overlap the icons
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if button:isVisible() and type(button.drawAfter) == "function" then
			button:drawAfter(box.shadow)
		end
	end
end
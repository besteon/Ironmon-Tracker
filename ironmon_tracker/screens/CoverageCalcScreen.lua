CoverageCalcScreen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Views = { Main = 1, MoveTypes = 2, Pokemon = 3, },
	Tabs = { Immune = 0.0, Quarter = 0.25, Half = 0.5, Neutral = 1, Super = 2, Quad = 4, },
	currentView = 1,
	currentTab = 4,
	leadMovesetIds = {}, -- Currently unused
	addedTypes = {},
	addedTypesOrdered = {},
	CoverageData = {}, -- Recalculated each time types or options change
}
local SCREEN = CoverageCalcScreen
local TAB_HEIGHT = 12

SCREEN.Buttons = {
	AddMoveType = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function() return Resources.CoverageCalcScreen.ButtonAddType end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 16, Constants.SCREEN.MARGIN + 22, 50, 12 },
		isDisabled = false,
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		updateSelf = function(self)
			self.isDisabled = #SCREEN.addedTypesOrdered >= 6
		end,
		draw = function(self, shadowcolor)
			if self.isDisabled then
				gui.drawRectangle(self.box[1], self.box[2], self.box[3], self.box[4], Drawing.ColorEffects.DISABLE, Drawing.ColorEffects.DISABLE)
			end
		end,
		onClick = function(self)
			if self.isDisabled then return end
			SCREEN.currentView = SCREEN.Views.MoveTypes
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	ClearMoveTypes = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function() return Resources.CoverageCalcScreen.ButtonClearTypes end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 73, Constants.SCREEN.MARGIN + 22, 50, 12 },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		onClick = function(self)
			SCREEN.resetTypesAndData()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	OptionOnlyFullyEvolved = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function() return " " .. Resources.CoverageCalcScreen.OptionFullyEvolvedOnly end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 113, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 113, 8, 8 },
		toggleState = false,
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			SCREEN.performCalc(self.toggleState)
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	ViewPokemonMatchups = {
		type = Constants.ButtonTypes.ICON_BORDER,
		getText = function(self) return Resources.CoverageCalcScreen.ButtonPokemonMatchups end,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 129, 105, 16 },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Main and #SCREEN.addedTypesOrdered > 0 end,
		onClick = function()
			SCREEN.currentView = SCREEN.Views.Pokemon
			-- Find next available tab to switch to (order checked not guaranteed)
			for _, tab in pairs(SCREEN.Tabs) do
				if #(SCREEN.CoverageData[tab] or {}) > 0 then
					SCREEN.changeTab(tab)
					break
				end
			end
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 69, Constants.SCREEN.MARGIN + 136, 50, 10, },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Pokemon and SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 56, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return SCREEN.currentView == SCREEN.Views.Pokemon and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 137, 10, 10, },
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
			SCREEN.resetTypesAndData()
			SCREEN.refreshButtons()
			Program.changeScreenView(ExtrasScreen)
		end
	end),
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.bst > b.bst or (a.bst == b.bst and a.id < b.id) end,
	realignButtonsToGrid = function(self)
		table.sort(self.Buttons, self.defaultSort)
		local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
		local y = Constants.SCREEN.MARGIN + 17
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 10
		local totalPages = Utils.gridAlign(self.Buttons, x, y, 3, 7, false, cutoffX, cutoffY)
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

	SCREEN.resetTypesAndData()
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
				if self.isDisabled then
					gui.drawRectangle(x - 1, y - 1, w + 1, h + 1, Drawing.ColorEffects.DISABLE, Drawing.ColorEffects.DISABLE)
				end
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
			SCREEN.performCalc()
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
		{ "Immune", "0x", SCREEN.Colors.text, },
		{ "Quarter", "1/4x", SCREEN.Colors.text, },
		{ "Half", "1/2x", SCREEN.Colors.text, },
		{ "Neutral", "1x", SCREEN.Colors.text, },
		{ "Super", "2x", "Positive text", },
		{ "Quad", "4x", "Positive text", },
	}
	for _, keys in ipairs(effectivenesses) do
		local tabKey = keys[1]
		local label = keys[2]
		local valueColor = keys[3]
		local labelCenterX = Utils.getCenteredTextX(label, 20) - 2
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			textColor = SCREEN.Colors.highlight,
			calcValue = 0,
			tab = SCREEN.Tabs[tabKey],
			dimensions = { width = 20, height = 20 },
			isVisible = function(self) return SCREEN.currentView == SCREEN.Views.Main end,
			updateSelf = function(self)
				local effData = SCREEN.CoverageData[self.tab] or {}
				self.calcValue = #SCREEN.addedTypesOrdered > 0 and #effData or 0
			end,
			draw = function(self, shadowcolor)
				-- Manually draw the texts so they're centered
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				Drawing.drawText(x + labelCenterX, y, label, Theme.COLORS[self.textColor], shadowcolor)

				local centeredOffsetX = Utils.getCenteredTextX(tostring(self.calcValue), w) - 2
				local colorForValue = valueColor
				local resultsText
				if self.calcValue > 0 then
					resultsText = tostring(self.calcValue)
				else
					resultsText = Constants.BLANKLINE
					colorForValue = SCREEN.Colors.text
				end
				Drawing.drawText(x + centeredOffsetX, y + 10, resultsText, Theme.COLORS[colorForValue], shadowcolor)
			end,
			onClick = function(self)
				if self.calcValue <= 0 then
					return
				end
				SCREEN.currentView = SCREEN.Views.Pokemon
				SCREEN.changeTab(self.tab)
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
		button.isVisible = function(self) return SCREEN.currentView == SCREEN.Views.MoveTypes end
		button.updateSelf = function(self) self.isDisabled = SCREEN.addedTypes[moveType] end
		button.onClick = function(self)
			if self.isDisabled then return end
			SCREEN.addedTypes[moveType] = true
			table.insert(SCREEN.addedTypesOrdered, moveType)
			SCREEN.performCalc()
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

	-- POKEMON TABS VIEW
	startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	startY = Constants.SCREEN.MARGIN
	local tabPadding = 6

	for _, keys in ipairs(effectivenesses) do
		local tabKey = keys[1]
		local tabText = keys[2]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tabText] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return tabText end,
			tab = SCREEN.Tabs[tabKey],
			isSelected = false,
			box = {	startX, startY, tabWidth, TAB_HEIGHT },
			isVisible = function(self) return SCREEN.currentView == SCREEN.Views.Pokemon and #(SCREEN.CoverageData[self.tab] or {}) > 0 end,
			updateSelf = function(self)
				self.isSelected = (self.tab == SCREEN.currentTab)
				self.textColor = self.isSelected and SCREEN.Colors.highlight or SCREEN.Colors.text
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
				local centeredOffsetX = Utils.getCenteredTextX(self:getText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self) SCREEN.changeTab(self.tab) end,
		}
		startX = startX + tabWidth
	end
end

function CoverageCalcScreen.buildPagedButtons()
	SCREEN.Pager.Buttons = {}

	for _, tab in pairs(SCREEN.Tabs) do
		for _, pokemonID in ipairs(SCREEN.CoverageData[tab] or {}) do
			local bst = tonumber(PokemonData.Pokemon[pokemonID].bst or "") or 0
			local button = {
				type = Constants.ButtonTypes.POKEMON_ICON,
				getIconId = function(self) return self.id, SpriteData.Types.Idle end,
				id = pokemonID,
				bst = bst,
				tab = tab,
				dimensions = { width = 32, height = 32, },
				boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
				isVisible = function(self) return SCREEN.currentView == SCREEN.Views.Pokemon and SCREEN.Pager.currentPage == self.pageVisible end,
				includeInGrid = function(self) return SCREEN.currentTab == self.tab end,
				-- Intentionally don't allow clicking on icons yet, as clicking Back isn't smart enough to return to this screen; might as in later
				-- onClick = function(self)
				-- 	InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
				-- end,
				-- Only draw after all the pokemon icons are drawn; executed manually in drawScreen
				-- drawAfter = function(self, shadowcolor)
				-- 	local x, y = self.box[1], self.box[2]
				-- 	local textColor = Theme.COLORS[self.textColor]
				-- 	local bgColor = Theme.COLORS[self.boxColors[2]]
				-- 	-- Draw the text below the icon
				-- 	Drawing.drawTransparentTextbox(x + centeredOffsetX - 1, y + 33, text, textColor, bgColor, shadowcolor)
				-- end,
			}
			table.insert(SCREEN.Pager.Buttons, button)
		end
	end
end

function CoverageCalcScreen.changeTab(tab)
	SCREEN.currentTab = tab
	SCREEN.Pager:realignButtonsToGrid()
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function CoverageCalcScreen.prepopulateMoveTypes()
	SCREEN.resetTypesAndData()

	local moveTypes, moveIds = CoverageCalcScreen.getPartyPokemonEffectiveMoveTypes(1)
	for _, moveType in ipairs(moveTypes or {}) do
		SCREEN.addedTypes[moveType] = true
	end
	for _, moveId in ipairs(moveIds or {}) do
		table.insert(SCREEN.leadMovesetIds, moveId)
	end
	SCREEN.addedTypesOrdered = moveTypes

	SCREEN.performCalc()
end

--- Returns a list of move types and moveIds, effective for calculating coverage for a Pokémon on the player's team
--- @param slotNumber number The slot number of the Pokémon on the player's team (lead = 1)
--- @return table moveTypes, table moveIds A list of effective move types & moveIds to be used for coverage calculations
function CoverageCalcScreen.getPartyPokemonEffectiveMoveTypes(slotNumber)
	local pokemon = Tracker.getPokemon(slotNumber or 1, true)
	if not pokemon then
		return {}, {}
	end

	local allowedCategories = {
		[MoveData.Categories.PHYSICAL] = true,
		[MoveData.Categories.SPECIAL] = true,
	}
	-- These shouldn't be counted automatically as "coverage" since they don't have a damage multiplier
	-- Unfortunately this excludes Night Shade when caring about Shedinja, but don't have a good solution otherwise
	local excludedMoveIds = {
		[12] = true, -- Guillotine
		[32] = true, -- Horn Drill
		[49] = true, -- SonicBoom
		[68] = true, -- Counter
		[69] = true, -- Seismic Toss
		[82] = true, -- Dragon Rage
		[90] = true, -- Fissure
		[101] = true, -- Night Shade
		[117] = true, -- Bide
		[149] = true, -- Psywave
		[162] = true, -- Super Fang
		[165] = true, -- Struggle (I guess)
		[237] = true, -- Hidden Power -- Allowed later, but only if it's type is tracked
		[243] = true, -- Mirror Coat
		[248] = true, -- Future Sight
		[251] = true, -- Beat Up
		[283] = true, -- Endeavor
		[329] = true, -- Sheer Cold
		[353] = true, -- Doom Desire
	}

	local alreadyAddedTypes = {}
	local moveTypes = {}
	local moveIds = {}
	for _, move in ipairs(pokemon.moves or {}) do
		if MoveData.isValid(move.id) then
			-- TODO: Might use current moveset to help calc stricter coverage later (e.g. Night Shade, Will-O-Wisp)
			table.insert(moveIds, move.id)

			local moveInternal = MoveData.Moves[move.id]
			local typeToAdd
			if allowedCategories[moveInternal.category] and not excludedMoveIds[move.id] then
				typeToAdd = moveInternal.type
			elseif move.id == 237 then -- 237 = Hidden Power, but only use if it's type is set/tracked
				local hiddenPowerType = Tracker.getHiddenPowerType(pokemon)
				if hiddenPowerType ~= MoveData.HIDDEN_POWER_NOT_SET then
					typeToAdd = hiddenPowerType
				end
			end
			if typeToAdd and not alreadyAddedTypes[typeToAdd] then
				alreadyAddedTypes[typeToAdd] = true
				table.insert(moveTypes, typeToAdd)
			end
		end
	end
	return moveTypes, moveIds
end

--- Updates the SCREEN.CoverageData table with information for the chosen coverage
--- @param onlyFullyEvolved boolean? (Optional) If true, only check against fully evolved Pokémon; default=true
function CoverageCalcScreen.performCalc(onlyFullyEvolved)
	onlyFullyEvolved = onlyFullyEvolved or SCREEN.Buttons.OptionOnlyFullyEvolved.toggleState
	SCREEN.CoverageData = CoverageCalcScreen.calculateCoverageTable(SCREEN.addedTypesOrdered, onlyFullyEvolved)
	SCREEN.buildPagedButtons()
end

--- Returns a CoverageData table with information for the chosen coverage
--- @param moveTypes table A list of move types (PokemonData.Types)
--- @param onlyFullyEvolved boolean? (Optional) If true, only check against fully evolved Pokémon; default=false
--- @return table CoverageData A table of [Effectiveness] = { pokemonIDs... }
function CoverageCalcScreen.calculateCoverageTable(moveTypes, onlyFullyEvolved)
	local coverageData = {
		[SCREEN.Tabs.Immune] = {},
		[SCREEN.Tabs.Quarter] = {},
		[SCREEN.Tabs.Half] = {},
		[SCREEN.Tabs.Neutral] = {},
		[SCREEN.Tabs.Super] = {},
		[SCREEN.Tabs.Quad] = {},
	}
	-- Helper functions
	local shouldCheckPokemon = function(pokemonID)
		-- Skip the empty/placeholder Pokemon
		if not PokemonData.isValid(pokemonID) or (pokemonID > 251 and pokemonID < 277) then
			return false
		end
		if onlyFullyEvolved and PokemonData.Pokemon[pokemonID].evolution ~= PokemonData.Evolutions.NONE then
			return false
		end
		return true
	end
	local calcHighestEffectiveness = function(type1, type2)
		local highestEff = 0
		for _, moveType in ipairs(moveTypes or {}) do
			local eff = MoveData.TypeToEffectiveness[moveType] or {}
			local moveEff = 1
			moveEff = moveEff * (eff[type1] or 1)
			moveEff = moveEff * (eff[type2] or 1)
			if moveEff > highestEff then
				highestEff = moveEff
			end
		end
		return highestEff
	end
	-- Check all pokemon for highest effectiveness, and categorize them
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		if shouldCheckPokemon(id) then
			local highestEff = calcHighestEffectiveness(pokemon.types[1], pokemon.types[2])
			-- For Shedinja, only count types that are super effective or better
			if id == 303 and highestEff < 2 then
				highestEff = 0
			end
			if coverageData[highestEff] then
				table.insert(coverageData[highestEff], id)
			end
		end
	end
	return coverageData
end

function CoverageCalcScreen.resetTypesAndData()
	SCREEN.leadMovesetIds = {}
	SCREEN.addedTypes = {}
	SCREEN.addedTypesOrdered = {}
	SCREEN.CoverageData = {}
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

	local canvas = {
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
		SCREEN.drawMainView(canvas)
	elseif SCREEN.currentView == SCREEN.Views.MoveTypes then
		SCREEN.drawMoveTypesView(canvas)
	elseif SCREEN.currentView == SCREEN.Views.Pokemon then
		SCREEN.drawPokemonView(canvas)
	end

	-- Draw all other buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

function CoverageCalcScreen.drawMainView(canvas)
	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.CoverageCalcScreen.Title), Theme.COLORS["Header text"], headerShadow)
end

function CoverageCalcScreen.drawMoveTypesView(canvas)
	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.CoverageCalcScreen.TitleAddMoveType), Theme.COLORS["Header text"], headerShadow)
end

function CoverageCalcScreen.drawPokemonView(canvas)
	canvas.y = Constants.SCREEN.MARGIN + TAB_HEIGHT
	canvas.height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - TAB_HEIGHT

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw each of possibile evolutions Pokemon
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end

	local totalCount = #(SCREEN.CoverageData[SCREEN.currentTab] or {})
	if totalCount > 0 then
		local totalText = string.format("%s: %s", Resources.CoverageCalcScreen.LabelTotal, totalCount)
		Drawing.drawTransparentTextbox(canvas.x + 3, canvas.y + 124, totalText, canvas.text, canvas.fill, canvas.shadow)
	end
end
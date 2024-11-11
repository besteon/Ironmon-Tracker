HealsInBagScreen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Tabs = {
		All = {
			index = 1,
			tabKey = "All",
			resourceKey = "TabAll",
		},
		HP = {
			index = 2,
			tabKey = "HP",
			resourceKey = "TabHP",
		},
		PP = {
			index = 3,
			tabKey = "PP",
			resourceKey = "TabPP",
		},
		Status = {
			index = 4,
			tabKey = "Status",
			resourceKey = "TabStatus",
		},
		Battle = {
			index = 5,
			tabKey = "Battle",
			resourceKey = "TabBattle",
		},
	},
	currentView = 1,
	currentTab = nil,
}
local SCREEN = HealsInBagScreen
local TAB_HEIGHT = 12

SCREEN.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 56, Constants.SCREEN.MARGIN + 136, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 44, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 87, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(TrackerScreen)
	end),
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return (a.sortValue or 0) > (b.sortValue or 0) or (a.sortValue == b.sortValue and a.id < b.id) end,
	realignButtonsToGrid = function(self)
		table.sort(self.Buttons, self.defaultSort)
		local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 38
		local y = Constants.SCREEN.MARGIN + 17
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 12
		local totalPages = Utils.gridAlign(self.Buttons, x, y, 2, 4, true, cutoffX, cutoffY)
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

function HealsInBagScreen.initialize()
	SCREEN.currentView = 1
	SCREEN.currentTab = SCREEN.Tabs.All
	SCREEN.createButtons()

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	SCREEN.refreshButtons()
end

function HealsInBagScreen.refreshButtons()
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

function HealsInBagScreen.createButtons()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local startY = Constants.SCREEN.MARGIN
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources.HealsInBagScreen[tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return tabText end,
			tab = SCREEN.Tabs[tab.tabKey],
			isSelected = false,
			box = {	startX, startY, tabWidth, TAB_HEIGHT },
			-- isVisible = function(self) return true end,
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
				local centeredOffsetX = Utils.getCenteredTextX(self:getCustomText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getCustomText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self) SCREEN.changeTab(self.tab) end,
		}
		startX = startX + tabWidth
	end
end

function HealsInBagScreen.buildPagedButtons(tab)
	tab = tab or SCREEN.currentTab
	SCREEN.Pager.Buttons = {}

	-- Calculate a sorting value for a given item based on the amount it "heals"
	local function calcSortValue(itemID)
		local value = 0
		local itemData = MiscData.HealingItems[itemID] or MiscData.PPItems[itemID] or MiscData.StatusItems[itemID] or {}
		if MiscData.HealingItems[itemID] then
			value = 50000
		elseif MiscData.StatusItems[itemID] then
			value = 40000
		elseif MiscData.PPItems[itemID] then
			value = 30000
		elseif MiscData.BattleItems[itemID] then
			value = 20000
		end
		if itemData.type == MiscData.HealingType.Percentage then
			value = value + (itemData.amount or 0) + 1000
		elseif itemData.type == MiscData.HealingType.Constant then
			value = value + (itemData.amount or 0)
		elseif itemData.type == MiscData.StatusType.All then -- The really good status items
			value = value + 2
		elseif MiscData.StatusItems[itemID] then -- All other status items
			value = value + 1
		end
		return value
	end

	local pokemon = Battle.getViewedPokemon(true) or {}
	local maxHP, monMissingHP, monStatus, monPPEmpty
	if PokemonData.isValid(pokemon.pokemonID) then
		maxHP = pokemon.stats.hp
		monMissingHP = math.max(maxHP - pokemon.curHP, 0) -- min 0
		monStatus = pokemon.status or 0
		if monStatus == MiscData.StatusType.Toxic then
			monStatus = MiscData.StatusType.Poison
		end
		for _, move in pairs(pokemon.moves or {}) do
			if move.pp <= 1 and tonumber(move.id) ~= 166 then -- 166: Sketch
				monPPEmpty = true
				break
			end
		end
	end
	monStatus = monStatus or MiscData.StatusType.None

	local tabContents = {}
	if tab == SCREEN.Tabs.HP then
		for itemID, _ in pairs(Program.GameData.Items.HPHeals or {}) do
			local sortValue = calcSortValue(itemID)
			local item = MiscData.HealingItems[itemID]
			local healAmt = 0
			if item.type == MiscData.HealingType.Constant then
				healAmt = item.amount
			elseif item.type == MiscData.HealingType.Percentage and maxHP then
				healAmt = math.floor(maxHP * item.amount / 100)
			end
			-- Consider the healing item helpful/efficient if 66% of its healing restores the mon's HP
			local isHelpful
			if maxHP and monMissingHP and (healAmt * 2/3) <= monMissingHP then
				isHelpful = true
			end
			table.insert(tabContents, { id = itemID, bagKey = "HPHeals", sortValue = sortValue, isHelpful = isHelpful })
		end
	elseif tab == SCREEN.Tabs.PP then
		for itemID, _ in pairs(Program.GameData.Items.PPHeals or {}) do
			local sortValue = calcSortValue(itemID)
			table.insert(tabContents, { id = itemID, bagKey = "PPHeals", sortValue = sortValue, isHelpful = monPPEmpty })
		end
	elseif tab == SCREEN.Tabs.Status then
		for itemID, _ in pairs(Program.GameData.Items.StatusHeals or {}) do
			local sortValue = calcSortValue(itemID)
			local statusType = MiscData.StatusItems[itemID].type or MiscData.StatusType.None
			-- Helpful if it can fix the status condition (revive/faint not checked)
			local isHelpful
			if monStatus == statusType and monStatus > MiscData.StatusType.None then
				isHelpful = true
			elseif monStatus > MiscData.StatusType.None and monStatus < MiscData.StatusType.Faint and statusType == MiscData.StatusType.All then
				isHelpful = true
			end
			table.insert(tabContents, { id = itemID, bagKey = "StatusHeals", sortValue = sortValue, isHelpful = isHelpful })
		end
	elseif tab == SCREEN.Tabs.Battle then
		for itemID, _ in pairs(Program.GameData.Items.Other or {}) do
			if MiscData.BattleItems[itemID] then
				table.insert(tabContents, { id = itemID, bagKey = "Other", sortValue = 20000 })
			end
		end
	elseif tab == SCREEN.Tabs.All then
		local addedIds = {} -- prevent duplicate items from appearing
		for bagKey, itemGroup in pairs(Program.GameData.Items) do
			if type(itemGroup) == "table" then
				for itemID, _ in pairs(itemGroup) do
					if not addedIds[itemID] then
						local sortValue = calcSortValue(itemID)
						table.insert(tabContents, { id = itemID, bagKey = bagKey, sortValue = sortValue })
						addedIds[itemID] = true
					end
				end
			end
		end
	end

	for _, item in ipairs(tabContents) do
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return MiscData.Items[item.id] or Constants.BLANKLINE end,
			image = MiscData.getItemIcon(item.id),
			tab = tab,
			id = item.id,
			sortValue = item.sortValue,
			dimensions = { width = 80, height = 11, },
			textColor = item.isHelpful and "Positive text" or SCREEN.Colors.text,
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self) return SCREEN.currentTab == self.tab end,
			-- onClick = function(self)
			-- 	InfoScreen.changeScreenView(InfoScreen.Screens.ITEM_INFO, self.id) -- implied redraw
			-- end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local textColor = Theme.COLORS[self.textColor]
				local bag = Program.GameData.Items[item.bagKey] or {}
				local quantity = bag[item.id] or 0
				if quantity == 69 then -- Nice
					textColor = Theme.COLORS["Positive text"]
				end
				-- Draw the image icon off to the left
				if self.image then
					Drawing.drawImage(self.image, x - 20, y)
				end
				-- Draw the quantity off to the right
				local quantityText = string.format("%s", quantity)
				local extraWidth = Utils.calcWordPixelLength(quantityText)
				local offsetX = x + w - extraWidth
				Drawing.drawText(offsetX, y, quantityText, textColor, shadowcolor)
				gui.drawLine(offsetX - 2, y + 5, offsetX, y + 8, textColor)
				gui.drawLine(offsetX - 2, y + 8, offsetX, y + 5, textColor)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, button)
	end
	SCREEN.Pager:realignButtonsToGrid()
end

function HealsInBagScreen.changeTab(tab)
	SCREEN.currentTab = tab
	SCREEN.buildPagedButtons(tab)
	SCREEN.refreshButtons()
	Program.redraw(true)
end

-- USER INPUT FUNCTIONS
function HealsInBagScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function HealsInBagScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + TAB_HEIGHT,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - TAB_HEIGHT,
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
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
PreviousEncountersScreen = {
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
		Wild = {
			index = 2,
			tabKey = "Wild",
			resourceKey = "TabWild",
		},
		Trainer = {
			index = 3,
			tabKey = "Trainer",
			resourceKey = "TabTrainer",
		},
	},
	currentView = 1,
	currentTab = nil,
	currentPokemonID = nil,
}

local SCREEN = PreviousEncountersScreen
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
	-- TODO: should date be separated out to a header when it changes? if so should be inserting a fake button
	--		for each different day, and adjust sort here to account for it (since os.time() gives int to the second
	--		might be fine to
	--		hack with setting time of 23:59:59.5 for that day?)
	defaultSort = function(a, b) return (a.sortValue or 0) > (b.sortValue or 0) or (a.sortValue == b.sortValue and a.id < b.id) end,
	realignButtonsToGrid = function(self)
		table.sort(self.Buttons, self.defaultSort)
		local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6
		local y = Constants.SCREEN.MARGIN + 17
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 10
		local totalPages = Utils.gridAlign(self.Buttons, x, y, 2, 2, true, cutoffX, cutoffY)
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

function PreviousEncountersScreen.initialize()
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


function PreviousEncountersScreen.refreshButtons()
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

function PreviousEncountersScreen.createButtons()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local startY = Constants.SCREEN.MARGIN
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources.PreviousEncountersScreen[tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return tabText end,
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
				local centeredOffsetX = Utils.getCenteredTextX(self:getText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self) SCREEN.changeTab(self.tab) end,
		}
		startX = startX + tabWidth
	end
end

function PreviousEncountersScreen.buildPagedButtons(tab)
	tab = tab or SCREEN.currentTab
	SCREEN.Pager.Buttons = {}

	local tabContents = {}

	local encounters = Tracker.getEncounterData(SCREEN.currentPokemonID)
	if tab == SCREEN.Tabs.Wild then
		for _, wildEncounter in ipairs(encounters.wild) do
			table.insert(tabContents, wildEncounter)
		end
	elseif tab == SCREEN.Tabs.Trainer then
		for _, trainerEncounter in ipairs(encounters.trainer) do
			table.insert(tabContents, trainerEncounter)
		end
	elseif tab == SCREEN.Tabs.All then
		for bagKey, itemGroup in pairs(encounters) do
			if type(itemGroup) == "table" then
				for _, encounter in pairs(itemGroup) do
					table.insert(tabContents, encounter)
				end
			end
		end
	end

	for _, encounter in ipairs(tabContents) do
		local encounterText =  "Lv." .. encounter.level .. "    " .. os.date("%Y-%m-%d  %H:%M:%S", encounter.timestamp)
		-- TODO: am/pm a little prettier but long. Maybe swap to it if date extracted to header
		-- local encounterText =  "Lv." .. encounter.level .. "    " .. os.date("%I:%M:%S%p", encounter.timestamp)
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			-- getText = function(self) return os.date("%Y-%m-%d %H:%M:%S", encounter.timestamp) or Constants.BLANKLINE end,
			getText = function(self) return encounterText end,
			tab = tab,
			id = encounter.timestamp,
			sortValue = encounter.timestamp,
			dimensions = { width = Utils.calcWordPixelLength(encounterText), height = 11, },
			textColor = SCREEN.Colors.text,
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self) return SCREEN.currentTab == self.tab end,
			-- onClick = function(self)
			--  -- TODO if we append more info on tracked data can render state of mon at that time
			-- 	InfoScreen.changeScreenView(InfoScreen.Screens.ITEM_INFO, self.id) -- implied redraw
			-- end,
			draw = function(self, shadowcolor)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, button)
	end
	SCREEN.Pager:realignButtonsToGrid()
end

function PreviousEncountersScreen.changeTab(tab)
	SCREEN.currentTab = tab
	SCREEN.buildPagedButtons(tab)
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function PreviousEncountersScreen.changePokemonID(pokemonID)
	SCREEN.currentPokemonID = pokemonID
	SCREEN.buildPagedButtons(tab)
	SCREEN.refreshButtons()
	Program.redraw(true)
end

-- USER INPUT FUNCTIONS
function PreviousEncountersScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function PreviousEncountersScreen.drawScreen()
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
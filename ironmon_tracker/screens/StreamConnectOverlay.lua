StreamConnectOverlay = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Tabs = {
		Commands = {
			index = 2,
			tabKey = "Commands",
			resourceKey = "TabCommands",
		},
		Rewards = {
			index = 3,
			tabKey = "Rewards",
			resourceKey = "TabRewards",
		},
		Queue = {
			index = 4,
			tabKey = "Queue",
			resourceKey = "TabQueue",
		},
		Settings = {
			index = 5,
			tabKey = "Settings",
			resourceKey = "TabSettings",
		},
	},
	currentTab = nil,
	isDisplayed = false,
}
local SCREEN = StreamConnectOverlay
local MARGIN = 2
local TAB_HEIGHT = 12

-- Dimensions of the screen space occupied by the current visible Tab
SCREEN.Canvas = {
	x = MARGIN,
	y = TAB_HEIGHT,
	w = Constants.SCREEN.WIDTH - (MARGIN * 2),
	h = Constants.SCREEN.HEIGHT - TAB_HEIGHT - MARGIN - 1,
}

local _pagerOffsetX, _pagerOffsetY = SCREEN.Canvas.x + 100, SCREEN.Canvas.y + SCREEN.Canvas.h - 12
SCREEN.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { _pagerOffsetX, _pagerOffsetY, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { _pagerOffsetX - 12, _pagerOffsetY, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self) SCREEN.Pager:prevPage() end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { _pagerOffsetX + 31, _pagerOffsetY, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self) SCREEN.Pager:nextPage() end
	},
	Back = Drawing.createUIElementBackButton(function()
		SCREEN.close()
	end),
}
-- Move the auto-generated Back button to the main game screen
SCREEN.Buttons.Back.clickableArea[1] = SCREEN.Buttons.Back.clickableArea[1] - Constants.SCREEN.RIGHT_GAP + 3
SCREEN.Buttons.Back.clickableArea[2] = SCREEN.Buttons.Back.clickableArea[2] + 3
SCREEN.Buttons.Back.box[1] = SCREEN.Buttons.Back.box[1] - Constants.SCREEN.RIGHT_GAP + 3
SCREEN.Buttons.Back.box[2] = SCREEN.Buttons.Back.box[2] + 3

SCREEN.Pager = {
	ButtonRows = {},
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end,
	realignButtonsToGrid = function(self, x, y)
		table.sort(self.ButtonRows, self.defaultSort)
		x = x or SCREEN.Canvas.x + 5
		y = y or SCREEN.Canvas.y + 20
		local cutoffX = SCREEN.Canvas.w - MARGIN
		local cutoffY = _pagerOffsetY
		local totalPages = Utils.gridAlign(self.ButtonRows, x, y, 0, 0, true, cutoffX, cutoffY)
		for _, button in pairs(self.Buttons) do
			if button.updateSelf ~= nil then button:updateSelf() end
		end
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

function StreamConnectOverlay.initialize()
	SCREEN.currentTab = SCREEN.Tabs.Queue
	SCREEN.isDisplayed = false
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

function StreamConnectOverlay.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if button.updateSelf ~= nil then button:updateSelf() end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if button.updateSelf ~= nil then button:updateSelf() end
	end
end

function StreamConnectOverlay.createButtons()
	local startX = SCREEN.Canvas.x
	local startY = SCREEN.Canvas.y - TAB_HEIGHT
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = tab.tabKey or Resources.StreamConnectOverlay[tab.resourceKey] -- TODO: Add language texts
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return tabText end,
			tab = SCREEN.Tabs[tab.tabKey],
			isSelected = false,
			box = {	startX, startY, tabWidth, TAB_HEIGHT },
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

	-- SETTINGS TAB
	startX = SCREEN.Canvas.x + 4
	startY = SCREEN.Canvas.y + 8
	local function nextLineY(extraOffset)
		startY = startY + Constants.SCREEN.LINESPACING + 8 + (extraOffset or 0)
		return startY
	end

	SCREEN.Buttons.SettingsLabelIsConnected = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "Connected:" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	startX, startY, 50, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings end,
	}
	SCREEN.Buttons.SettingsIconIsConnected = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CROSS,
		box = {	startX + 90, startY - 1, 11, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings end,
		updateSelf = function(self)
			self.image = Network.isConnected() and Constants.PixelImages.CHECKMARK or Constants.PixelImages.CROSS
			self.textColor = Network.isConnected() and "Positive text" or "Negative text"
		end,
	}
	SCREEN.Buttons.SettingsBtnConnect = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			-- TODO: Language
			if Network.isConnected() then
				return "Disconnect" or Resources.StreamConnectOverlay.LabelOrButton
			else
				return "Connect" or Resources.StreamConnectOverlay.LabelOrButton
			end
		end,
		box = {	startX + 150, startY, 50, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings end,
		onClick = function(self)
			if Network.isConnected() then
				Network.closeConnections()
			else
				Network.tryConnect()
			end
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	}
	nextLineY()


	SCREEN.Buttons.SettingsAutoConnectStartup = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return " " .. "Auto-Connect on Startup" or " " .. Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = { startX + 90, startY, 8, 8 },
		boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
		toggleState = Network.Options["AutoConnectStartup"],
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings end,
		updateSelf = function(self)
			self.toggleState = Network.Options["AutoConnectStartup"]
		end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			Network.Options["AutoConnectStartup"] = (self.toggleState == true)
			Main.SaveSettings(true)
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	}
	nextLineY()


	SCREEN.Buttons.SettingsLabelConnType = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "Connection Type:" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	startX, startY, 50, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings end,
	}
	local connOffsetX = startX + 90
	for _, connType in ipairs(Network.getSupportedConnectionTypes() or {}) do
		local text = connType or Resources.StreamConnectOverlay.LabelOrButton -- TODO: Language
		local width = Utils.calcWordPixelLength(text)
		SCREEN.Buttons["SettingsConnType" .. connType] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return text end,
			isSelected = false,
			box = {	connOffsetX, startY, width + 4, 11 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings end,
			updateSelf = function(self)
				self.isSelected = Network.CurrentConnection.Type == connType
			end,
			draw = function(self, shadowcolor)
				if self.isSelected then
					local color = Theme.COLORS[SCREEN.Colors.highlight]
					Drawing.drawSelectionIndicators(self.box[1], self.box[2], self.box[3] + 1, self.box[4], color, 1, 4, 1)
				end
			end,
			onClick = function(self)
				Network.changeConnection(connType)
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		connOffsetX = connOffsetX + width + 10
	end
	nextLineY()

	SCREEN.Buttons.SettingsDataFolder = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Change" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	startX + 150, startY, 35, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings and Network.CurrentConnection.Type == Network.ConnectionTypes.Text end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "Connection Folder:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
			local folder = FileManager.extractFolderNameFromPath(Network.Options["DataFolder"] or "")
			Drawing.drawText(startX + 90, y, folder, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
		end,
		onClick = function(self)
			-- TODO: Implement prompt
			print("Button pressed: Change Connection Folder")
		end,
	}
	-- SCREEN.Buttons.SettingsSocketIP = {
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
	-- 	box = {	startX + 80, startY, 15, 11 },
	-- 	isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings and Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets end,
	-- 	draw = function(self, shadowcolor)
	-- 		local x, y = self.box[1], self.box[2]
	-- 		Drawing.drawText(startX, y, "Server IP:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
	-- 		local val = Network.Options["WebSocketIP"] or "0.0.0.0"
	-- 		Drawing.drawText(x - 30, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
	-- 	end,
	-- 	onClick = function(self)
	-- 		-- TODO: Implement prompt
	-- 	end,
	-- }
	-- SCREEN.Buttons.SettingsSocketPort = {
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
	-- 	box = {	startX + 170, startY, 15, 11 },
	-- 	isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings and Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets end,
	-- 	draw = function(self, shadowcolor)
	-- 		local x, y = self.box[1], self.box[2]
	-- 		Drawing.drawText(x - 80 + 1, y, "Port:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
	-- 		local val = Network.Options["WebSocketPort"] or "0000"
	-- 		Drawing.drawText(x - 30, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
	-- 	end,
	-- 	onClick = function(self)
	-- 		-- TODO: Implement prompt
	-- 	end,
	-- }
	-- SCREEN.Buttons.SettingsHTTPGet = {
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
	-- 	box = {	startX + 80, startY, 15, 11 },
	-- 	isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings and Network.CurrentConnection.Type == Network.ConnectionTypes.Http end,
	-- 	draw = function(self, shadowcolor)
	-- 		local x, y = self.box[1], self.box[2]
	-- 		Drawing.drawText(startX, y, "Http GET:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
	-- 		local val = Network.Options["HttpGet"] or "/Get"
	-- 		Drawing.drawText(x - 30, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
	-- 	end,
	-- 	onClick = function(self)
	-- 		-- TODO: Implement prompt
	-- 	end,
	-- }
	-- SCREEN.Buttons.SettingsHTTPPost = {
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
	-- 	box = {	startX + 170, startY, 15, 11 },
	-- 	isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Settings and Network.CurrentConnection.Type == Network.ConnectionTypes.Http end,
	-- 	draw = function(self, shadowcolor)
	-- 		local x, y = self.box[1], self.box[2]
	-- 		Drawing.drawText(x - 80 + 1, y, "Http POST:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
	-- 		local val = Network.Options["HttpPost"] or "/Post"
	-- 		Drawing.drawText(x - 30, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
	-- 	end,
	-- 	onClick = function(self)
	-- 		-- TODO: Implement prompt
	-- 	end,
	-- }
end

local ROW_MARGIN, ROW_PADDING = 5, 2
local ROW_WIDTH, ROW_HEIGHT = (SCREEN.Canvas.w - ROW_MARGIN * 2), (11 + ROW_PADDING * 2)
local _leftEdgeX, _rightEdgeX
local function resetButtonRow(width, height)
	_leftEdgeX = width or SCREEN.Canvas.x + ROW_MARGIN
	_rightEdgeX = height or SCREEN.Canvas.x + SCREEN.Canvas.w - ROW_MARGIN
end
local function addLeftAligned(button)
	button.box[1] = _leftEdgeX + ROW_PADDING
	_leftEdgeX = button.box[1] + button.box[3] + ROW_PADDING
end
local function addRightAligned(button)
	button.box[1] = _rightEdgeX - ROW_PADDING - button.box[3]
	_rightEdgeX = button.box[1] - ROW_PADDING
end
resetButtonRow()

local function buildCommandsTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}

	local tabContents = {}
	for _, event in pairs(RequestHandler.Events) do
		if not event.Exclude and event.Command then
			table.insert(tabContents, event)
		end
	end
	table.sort(tabContents, function(a,b) return a.Command < b.Command end)

	for i, event in ipairs(tabContents) do
		resetButtonRow()
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Allow checkboxes to filter enabled, disabled, etc
				return true
			end,
		}
		table.insert(SCREEN.Pager.ButtonRows, buttonRow)

		local btnEnabled = {
			type = Constants.ButtonTypes.CHECKBOX,
			box = { -1, -1, 8, 8 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			toggleState = event.IsEnabled,
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.toggleState = event.IsEnabled
				self.box[2] = buttonRow.box[2] + ROW_PADDING + 1
			end,
			onClick = function(self)
				self.toggleState = not self.toggleState
				event.IsEnabled = (self.toggleState == true)
				RequestHandler.saveEventSetting(event, "IsEnabled")
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnEnabled)
		addLeftAligned(btnEnabled)

		local btnWidth = Utils.calcWordPixelLength(event.Command) + 5
		local btnName = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return event.Command end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
				self.textColor = btnEnabled.toggleState and SCREEN.Colors.text or "Negative text"
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnName)
		addLeftAligned(btnName)

		-- Add buttons to row from right-to-left
		btnWidth = Utils.calcWordPixelLength("Roles" or Resources.StreamConnectOverlay.X) + 5 -- TODO: Language
		local btnRoles = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return "Roles" or Resources.StreamConnectOverlay.X end, -- TODO: Language
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
			end,
			onClick = function(self) StreamConnectOverlay.openCommandRolesPrompt(event) end,
		}
		table.insert(SCREEN.Pager.Buttons, btnRoles)
		addRightAligned(btnRoles)

		btnWidth = Utils.calcWordPixelLength("Rename" or Resources.StreamConnectOverlay.X) + 5 -- TODO: Language
		local btnRename = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return "Rename" or Resources.StreamConnectOverlay.X end, -- TODO: Language
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
			end,
			onClick = function(self) SCREEN.openCommandRenamePrompt(event) end,
		}
		table.insert(SCREEN.Pager.Buttons, btnRename)
		addRightAligned(btnRename)
	end
	SCREEN.Pager:realignButtonsToGrid(SCREEN.Canvas.x + ROW_MARGIN, SCREEN.Canvas.y + ROW_MARGIN)
end

local function buildRewardsTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}
	local columnsW = {
		enabled = 14,
		name = -1,
		rename = 30,
		roles = 30,
	}
	columnsW.name = ROW_WIDTH - columnsW.enabled - columnsW.rename - columnsW.roles
	local tabContents = {}
	for _, event in pairs(RequestHandler.Events) do
		if not event.Exclude and not event.Command then -- TODO: Fix later after adding proper event Rewards
			table.insert(tabContents, event)
		end
	end
	table.sort(tabContents, function(a,b) return a.Key < b.Key end) -- TODO: Fix later
	for i, event in ipairs(tabContents) do
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Allow checkboxes to show enabled, show disabled, etc
				return true
			end,
		}
		table.insert(SCREEN.Pager.ButtonRows, buttonRow)
	end
	SCREEN.Pager:realignButtonsToGrid()
end

local function buildQueueTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}
	local columnsW = {
		enabled = 14,
		name = -1,
		rename = 30,
		roles = 30,
	}
	columnsW.name = ROW_WIDTH - columnsW.enabled - columnsW.rename - columnsW.roles
	local tabContents = {}
	for _, request in pairs(RequestHandler.Requests) do
		table.insert(tabContents, request)
	end
	table.sort(tabContents, function(a,b) return a.CreatedAt < b.CreatedAt end)
	for i, event in ipairs(tabContents) do
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Allow checkboxes to show enabled, show disabled, etc
				return true
			end,
		}
		table.insert(SCREEN.Pager.ButtonRows, buttonRow)
	end
	SCREEN.Pager:realignButtonsToGrid()
end

function StreamConnectOverlay.buildPagedButtons(tab)
	tab = tab or SCREEN.currentTab
	if tab == SCREEN.Tabs.Commands then
		buildCommandsTab()
	elseif tab == SCREEN.Tabs.Rewards then
		buildRewardsTab()
	elseif tab == SCREEN.Tabs.Queue then
		buildQueueTab()
	else
		SCREEN.Pager.ButtonRows = {}
		SCREEN.Pager.Buttons = {}
		SCREEN.Pager:realignButtonsToGrid()
	end
end

-- Rebuilds the buttons for the currently displayed screen. Useful when the Tracker's display language changes
function StreamConnectOverlay.rebuildScreen()
	if not SCREEN.isDisplayed then return end
	SCREEN.createButtons()
	SCREEN.buildPagedButtons(SCREEN.currentTab)
	SCREEN.refreshButtons()
end

function StreamConnectOverlay.open()
	if SCREEN.isDisplayed then return end
	SCREEN.isDisplayed = true
	local tabToOpen = Network.isConnected() and Utils.getSortedList(SCREEN.Tabs)[1] or SCREEN.Tabs.Settings
	SCREEN.changeTab(tabToOpen)
end

function StreamConnectOverlay.close()
	if not SCREEN.isDisplayed then return end
	SCREEN.isDisplayed = false
	Program.redraw(true)
end

function StreamConnectOverlay.changeTab(tab)
	if not SCREEN.isDisplayed then return end
	SCREEN.currentTab = tab
	SCREEN.buildPagedButtons(tab)
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function StreamConnectOverlay.openCommandRenamePrompt(event)
	local form = Utils.createBizhawkForm("Edit Command Name", 320, 130, 100, 50) -- TODO: Language
	forms.label(form, "Command:", 28, 20, 110, 20) -- TODO: Language

	local textbox = forms.textbox(form, event.Command, 134, 20, nil, 150, 18)

	forms.button(form, Resources.AllScreens.Save, function()
		local text = forms.gettext(textbox) or ""
		if #text > 2 and text:sub(1,1) == "!" then -- Command requirements
			event.Command = Utils.toLowerUTF8(text)
			RequestHandler.saveEventSetting(event, "Command")
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
		client.unpause()
		forms.destroy(form)
	end, 30, 50)
	forms.button(form, "(Default)", function() -- TODO: Language
		local defaultEvent = RequestHandler.DefaultEvents[event.Key]
		if defaultEvent then
			forms.settext(textbox, defaultEvent.Command)
		end
	end, 120, 50)
	forms.button(form, Resources.AllScreens.Cancel, function()
		client.unpause()
		forms.destroy(form)
	end, 210, 50)
end

function StreamConnectOverlay.openCommandRolesPrompt(event)
	local form = Utils.createBizhawkForm("Edit Command Roles", 320, 130, 100, 50) -- TODO: Language
	local commandLabel = string.format("Change allowed roles for command: %s", event.Command) -- TODO: Language
	forms.label(form, commandLabel, 28, 20, 250, 20)

	-- TODO: Implement this

	forms.button(form, Resources.AllScreens.Save, function()
		-- RequestHandler.saveEventSetting(event, "Roles")
		SCREEN.refreshButtons()
		Program.redraw(true)
		client.unpause()
		forms.destroy(form)
	end, 30, 50)
	forms.button(form, "(Default)", function() -- TODO: Language
		local defaultEvent = RequestHandler.DefaultEvents[event.Key]
		if defaultEvent then
			-- defaultEvent.Roles
		end
	end, 120, 50)
	forms.button(form, Resources.AllScreens.Cancel, function()
		client.unpause()
		forms.destroy(form)
	end, 210, 50)
end

-- USER INPUT FUNCTIONS
function StreamConnectOverlay.checkInput(xmouse, ymouse)
	if not SCREEN.isDisplayed then return end
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function StreamConnectOverlay.drawScreen()
	if not SCREEN.isDisplayed then return end

	local canvas = {
		x = SCREEN.Canvas.x,
		y = SCREEN.Canvas.y,
		width = SCREEN.Canvas.w,
		height = SCREEN.Canvas.h,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)
	-- Draw canvas box
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

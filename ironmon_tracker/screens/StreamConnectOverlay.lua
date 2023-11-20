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
		Game = {
			index = 5,
			tabKey = "Game",
			resourceKey = "TabGame",
		},
		Status = {
			index = 6,
			tabKey = "Status",
			resourceKey = "TabStatus",
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
	y = TAB_HEIGHT + MARGIN,
	w = Constants.SCREEN.WIDTH - (MARGIN * 2),
	h = Constants.SCREEN.HEIGHT - TAB_HEIGHT - (MARGIN * 2) - 1,
}

local _pagerOffsetX, _pagerOffsetY = SCREEN.Canvas.x + 100, SCREEN.Canvas.y + SCREEN.Canvas.h - 14
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
		local totalPages = Utils.gridAlign(self.ButtonRows, x, y, 0, 3, true, cutoffX, cutoffY)
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
	SCREEN.createTabButtons()
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

local ROW_MARGIN, ROW_PADDING = 5, 2
local ROW_WIDTH, ROW_HEIGHT = (SCREEN.Canvas.w - ROW_MARGIN * 2), ((Constants.SCREEN.LINESPACING + ROW_PADDING) * 2)
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

function StreamConnectOverlay.createTabButtons()
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
end

local function buildCommandsTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}

	SCREEN.Pager.Buttons.CommandsRoles = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Role Permissions" or Resources.StreamConnectOverlay.X end, -- TODO: Language
		textColor = SCREEN.Colors.text,
		box = {	SCREEN.Canvas.x + 4, SCREEN.Canvas.y + SCREEN.Canvas.h - 15, Utils.calcWordPixelLength("Role Permissions") + 5, 11 },
		boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Commands end,
		onClick = function(self) StreamConnectOverlay.openCommandRolesPrompt() end,
	}

	local tabContents = {}
	for _, event in pairs(EventHandler.Events) do
		if event.Type == EventHandler.EventTypes.Command and not event.Exclude then
			table.insert(tabContents, event)
		end
	end
	table.sort(tabContents, function(a,b) return a.IsEnabled and not b.IsEnabled or (a.IsEnabled == b.IsEnabled and a.Name < b.Name) end)

	for i, event in ipairs(tabContents) do
		resetButtonRow()
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible and SCREEN.currentTab == SCREEN.Tabs.Commands end,
			includeInGrid = function(self)
				-- Allow checkboxes to filter enabled, disabled, etc
				return true
			end,
		}
		table.insert(SCREEN.Pager.ButtonRows, buttonRow)

		-- TODO: Have a help/info button to hide the row and reveal help text for the command

		local btnEnabled = {
			type = Constants.ButtonTypes.CHECKBOX,
			box = { -1, -1, 8, 8 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			toggleState = event.IsEnabled,
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.toggleState = event.IsEnabled
				self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 - ROW_PADDING
			end,
			onClick = function(self)
				self.toggleState = not self.toggleState
				event.IsEnabled = (self.toggleState == true)
				EventHandler.saveEventSetting(event, "IsEnabled")
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnEnabled)
		addLeftAligned(btnEnabled)

		local btnWidth = Utils.calcWordPixelLength(event.Name) + 5
		local btnName = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return event.Name end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
				self.textColor = btnEnabled.toggleState and SCREEN.Colors.text or "Negative text"
			end,
			draw = function(self, shadowcolor)
				Drawing.drawUnderline(self)
				local x, y = self.box[1], self.box[2]
				Drawing.drawText(x + 1, y + Constants.SCREEN.LINESPACING + ROW_PADDING, event.Command, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnName)
		addLeftAligned(btnName)

		-- Add buttons to row from right-to-left
		btnWidth = Utils.calcWordPixelLength("Rename" or Resources.StreamConnectOverlay.X) + 5 -- TODO: Language
		local btnRename = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return "Rename" or Resources.StreamConnectOverlay.X end, -- TODO: Language
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 - ROW_PADDING - 3
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

	-- Unsure if I want to use this or not
	-- local refreshWidth = Utils.calcWordPixelLength("Refresh" or Resources.StreamConnectOverlay.LabelOrButton) + 6 -- TODO: Language
	-- SCREEN.Pager.Buttons.RewardsRefresh = {
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "Refresh" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
	-- 	box = {	SCREEN.Canvas.x + 4, SCREEN.Canvas.y + SCREEN.Canvas.h - 15, refreshWidth, 11 },
	-- 	isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Rewards end,
	-- 	onClick = function(self)
	-- 		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
	-- 			EventKey = EventHandler.CoreEventTypes.GetRewards,
	-- 			Args = { Received = "No" }
	-- 		}))
	-- 	end,
	-- }

	local tabContents = {}
	for _, event in pairs(EventHandler.Events) do
		if event.Type == EventHandler.EventTypes.Reward and not event.Exclude then
			table.insert(tabContents, event)
		end
	end
	table.sort(tabContents, function(a,b) return a.IsEnabled and not b.IsEnabled or (a.IsEnabled == b.IsEnabled and a.Name < b.Name) end)

	local NOT_ASSIGNED = ""
	local ASSIGNED_UNKNOWN = "(Waiting for connection...)" -- TODO: Language

	for i, event in ipairs(tabContents) do
		resetButtonRow()
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible and SCREEN.currentTab == SCREEN.Tabs.Rewards end,
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
				self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 - ROW_PADDING
			end,
			onClick = function(self)
				self.toggleState = not self.toggleState
				event.IsEnabled = (self.toggleState == true)
				EventHandler.saveEventSetting(event, "IsEnabled")
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnEnabled)
		addLeftAligned(btnEnabled)

		local eventName = Utils.formatSpecialCharacters(event.Name)
		local btnWidth = Utils.calcWordPixelLength(eventName) + 5
		local btnName = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return eventName end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
				self.textColor = btnEnabled.toggleState and SCREEN.Colors.text or "Negative text"
			end,
			draw = function(self, shadowcolor)
				Drawing.drawUnderline(self)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnName)

		local btnAssociatedReward = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.REFERENCE_UP,
			getText = function(self)
				local externalTitle
				if Utils.isNilOrEmpty(event.RewardId) then
					externalTitle = NOT_ASSIGNED
				else
					externalTitle = ASSIGNED_UNKNOWN
					if not Utils.isNilOrEmpty(EventHandler.RewardsExternal[event.RewardId]) then
						externalTitle = EventHandler.RewardsExternal[event.RewardId]
						externalTitle = Utils.formatSpecialCharacters(externalTitle)
						externalTitle = Utils.shortenText(externalTitle, 156, true)
					end
				end
				return externalTitle
			end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, 11, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = btnName.box[2] + ROW_HEIGHT / 2
				if self:getText() == NOT_ASSIGNED then
					self.textColor = SCREEN.Colors.highlight
				else
					self.textColor = SCREEN.Colors.text
				end
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnAssociatedReward)
		btnName.box[1] = _leftEdgeX + ROW_PADDING
		btnAssociatedReward.box[1] = _leftEdgeX + ROW_PADDING + 2
		_leftEdgeX = btnName.box[1] + btnWidth + ROW_PADDING

		-- Add buttons to row from right-to-left
		btnWidth = Utils.calcWordPixelLength("Options" or Resources.StreamConnectOverlay.X) + 5 -- TODO: Language
		local btnOptions = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return "Options" or Resources.StreamConnectOverlay.X end, -- TODO: Language
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() and event.Options and #event.Options > 0 end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
			end,
			onClick = function(self) StreamConnectOverlay.openEventOptionsPrompt(event) end,
		}
		table.insert(SCREEN.Pager.Buttons, btnOptions)

		local btnAddChange = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self)
				-- TODO: Language
				if btnAssociatedReward:getText() == NOT_ASSIGNED then
					return "Add" or Resources.StreamConnectOverlay.X
				else
					return "Change" or Resources.StreamConnectOverlay.X
				end
			end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, -1, 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = btnOptions.box[2] + ROW_HEIGHT / 2
				self.box[3] = Utils.calcWordPixelLength(self:getText()) + 5 -- Auto resize
				if btnAssociatedReward:getText() == NOT_ASSIGNED then
					self.textColor = SCREEN.Colors.highlight
				else
					self.textColor = SCREEN.Colors.text
				end
			end,
			onClick = function(self) StreamConnectOverlay.openRewardListPrompt(event) end,
		}
		btnAddChange:updateSelf()
		table.insert(SCREEN.Pager.Buttons, btnAddChange)
		btnOptions.box[1] = _rightEdgeX - ROW_PADDING - btnOptions.box[3]
		btnAddChange.box[1] = _rightEdgeX - ROW_PADDING - btnOptions.box[3]
		_rightEdgeX = btnOptions.box[1] - ROW_PADDING
	end
	SCREEN.Pager:realignButtonsToGrid(SCREEN.Canvas.x + ROW_MARGIN, SCREEN.Canvas.y + ROW_MARGIN)
end

local function buildQueueTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}

	local tabContents = {}
	for key, queue in pairs(EventHandler.Queues) do
		-- Put the active item at the front
		if queue.ActiveRequest then
			table.insert(tabContents, { QueueName = key, Request = queue.ActiveRequest })
		end
		-- Then sort the rest and add them in
		local requests = {}
		for _, request in pairs(queue.Requests) do
			if request ~= queue.ActiveRequest then
				table.insert(requests, request)
			end
		end
		table.sort(requests, queue.Sort or function(a,b) return a.CreatedAt < b.CreatedAt end)
		for _, request in ipairs(requests) do
			table.insert(tabContents, { QueueName = key, Request = request })
		end
	end
	-- TODO: Might do other group-sorting here later

	SCREEN.Pager.Buttons.NoContents = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOCK,
		iconColors = { SCREEN.Colors.highlight },
		getText = function(self) return "No Rewards have been queued up." end, -- TODO: Language
		box = { SCREEN.Canvas.x + 20, SCREEN.Canvas.y + SCREEN.Canvas.h / 2 - 28, 12, 11, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Queue and #tabContents == 0 end,
	}

	SCREEN.Pager.Buttons.QueueClear = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if self.confirmReset then
				return string.format("%s", "Are you sure?") -- TODO: Language
			else
				return string.format("%s", "Clear Queue") -- TODO: Language
			end
		end,
		textColor = SCREEN.Colors.text,
		confirmReset = false,
		box = {	SCREEN.Canvas.x + 4, SCREEN.Canvas.y + SCREEN.Canvas.h - 15, 58, 11 },
		boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Queue and #tabContents > 0 end,
		updateSelf = function(self)
			if self.confirmReset then
				self.textColor = "Negative text"
			else
				self.textColor = SCREEN.Colors.text
			end
		end,
		onClick = function(self)
			if self.confirmReset then
				self.confirmReset = false
				EventHandler.cancelAllQueues()
				buildQueueTab()
			else
				self.confirmReset = true
			end
			self:updateSelf()
			Program.redraw(true)
		end,
	}

	for i, item in ipairs(tabContents) do
		local Q = EventHandler.Queues[item.QueueName]
		local event = EventHandler.Events[item.Request.EventKey] or EventHandler.Events.None

		resetButtonRow()
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible and SCREEN.currentTab == SCREEN.Tabs.Queue end,
			includeInGrid = function(self)
				-- Allow checkboxes to filter enabled, disabled, etc
				return true
			end,
		}
		table.insert(SCREEN.Pager.ButtonRows, buttonRow)

		local rowHeaderText = string.format("%s. %s", i, event.Name)
		local btnWidth = Utils.calcWordPixelLength(rowHeaderText) + 5
		local btnRequestName = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self)
				-- local minutesAgo = math.ceil((os.time() - item.Request.CreatedAt) / 60)
				-- local timestampText -- TODO: Language
				-- if minutesAgo == 1 then
				-- 	timestampText = "1 min"
				-- else
				-- 	timestampText = string.format("%s mins", minutesAgo)
				-- end
				-- local time = os.date("%M:%S", item.Request.CreatedAt)
				-- return string.format("%s %s", rowHeaderText, timestampText)
				return rowHeaderText
			end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_PADDING
				self.textColor = item.Request == Q.ActiveRequest and "Positive text" or SCREEN.Colors.text
			end,
			draw = function(self, shadowcolor)
				Drawing.drawUnderline(self)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnRequestName)
		local btnUsernameInfo = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self)
				local subHeaderText = string.format("%s: %s", item.Request.Username, item.Request.SanitizedInput)
				return Utils.shortenText(subHeaderText, 219, true)
			end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 + 2
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnUsernameInfo)
		btnRequestName.box[1] = _leftEdgeX + ROW_PADDING
		btnUsernameInfo.box[1] = _leftEdgeX + ROW_PADDING
		_leftEdgeX = btnRequestName.box[1] + btnWidth + ROW_PADDING

		-- Add buttons to row from right-to-left
		btnWidth = Utils.calcWordPixelLength("Confirm?") + 6 -- TODO: Language
		local btnCancel = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self)
				if self.confirmReset then
					return string.format("%s", "Confirm?") -- TODO: Language
				else
					return string.format("%s", "Cancel") -- TODO: Language
				end
			end,
			textColor = SCREEN.Colors.text,
			confirmReset = false,
			box = { -1, -1, btnWidth, 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + 2
				self.textColor = self.confirmReset and "Negative text" or SCREEN.Colors.text
			end,
			onClick = function(self)
				if self.confirmReset then
					if Q.ActiveRequest == item.Request then
						Q.ActiveRequest = nil
					end
					Q.Requests[item.Request.GUID] = nil
					item.Request.IsCancelled = true
						buildQueueTab()
				else
					self.confirmReset = true
				end
				self:updateSelf()
				Program.redraw(true)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnCancel)
		addRightAligned(btnCancel)
	end
	SCREEN.Pager:realignButtonsToGrid(SCREEN.Canvas.x + ROW_MARGIN, SCREEN.Canvas.y + ROW_MARGIN)
end

local function buildGameTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}

	local tabContents = {}
	for _, event in pairs(EventHandler.Events) do
		if event.Type == EventHandler.EventTypes.Game and not event.Exclude then
			table.insert(tabContents, event)
		end
	end
	table.sort(tabContents, function(a,b) return a.IsEnabled and not b.IsEnabled or (a.IsEnabled == b.IsEnabled and a.Name < b.Name) end)

	SCREEN.Pager.Buttons.NoContents = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.EXTENSIONS,
		iconColors = { SCREEN.Colors.highlight },
		getText = function(self) return "No Game event triggers have been added." end, -- TODO: Language
		box = { SCREEN.Canvas.x + 20, SCREEN.Canvas.y + SCREEN.Canvas.h / 2 - 28, 12, 12, },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Game and #tabContents == 0 end,
		draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				y = y + Constants.SCREEN.LINESPACING * 2
				local wrappedDesc = Utils.getWordWrapLines("You can add new Game event triggers through custom Tracker extensions.", 50) -- TODO: Language
				for _, line in pairs(wrappedDesc) do
					local centeredOffset = Utils.getCenteredTextX(line, SCREEN.Canvas.w)
					Drawing.drawText(SCREEN.Canvas.x + centeredOffset, y, line, Theme.COLORS[SCREEN.Colors.text], shadowcolor)
					y = y + Constants.SCREEN.LINESPACING
				end
		end,
	}

	for i, event in ipairs(tabContents) do
		resetButtonRow()
		local buttonRow = {
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible and SCREEN.currentTab == SCREEN.Tabs.Game end,
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
				self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 - ROW_PADDING
			end,
			onClick = function(self)
				self.toggleState = not self.toggleState
				event.IsEnabled = (self.toggleState == true)
				EventHandler.saveEventSetting(event, "IsEnabled")
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		table.insert(SCREEN.Pager.Buttons, btnEnabled)
		addLeftAligned(btnEnabled)

		local btnWidth = Utils.calcWordPixelLength(event.Name) + 5
		local btnName = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return event.Name end,
			textColor = SCREEN.Colors.text,
			box = { -1, -1, btnWidth, 11 },
			isVisible = function(self) return buttonRow:isVisible() end,
			updateSelf = function(self)
				self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 - ROW_PADDING - 2
				self.textColor = btnEnabled.toggleState and SCREEN.Colors.text or "Negative text"
			end,
			-- draw = function(self, shadowcolor)
			-- 	Drawing.drawUnderline(self)
			-- 	local x, y = self.box[1], self.box[2]
			-- 	Drawing.drawText(x + 1, y + Constants.SCREEN.LINESPACING + ROW_PADDING, Constants.BLANKLINE, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
			-- end,
		}
		table.insert(SCREEN.Pager.Buttons, btnName)
		addLeftAligned(btnName)

		-- -- Add buttons to row from right-to-left
		-- btnWidth = Utils.calcWordPixelLength("Rename" or Resources.StreamConnectOverlay.X) + 5 -- TODO: Language
		-- local btnRename = {
		-- 	type = Constants.ButtonTypes.FULL_BORDER,
		-- 	getText = function(self) return "Rename" or Resources.StreamConnectOverlay.X end, -- TODO: Language
		-- 	textColor = SCREEN.Colors.text,
		-- 	box = { -1, -1, btnWidth, 11 },
		-- 	boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
		-- 	isVisible = function(self) return buttonRow:isVisible() end,
		-- 	updateSelf = function(self)
		-- 		self.box[2] = buttonRow.box[2] + ROW_HEIGHT / 2 - ROW_PADDING - 3
		-- 	end,
		-- 	onClick = function(self) SCREEN.openCommandRenamePrompt(event) end,
		-- }
		-- table.insert(SCREEN.Pager.Buttons, btnRename)
		-- addRightAligned(btnRename)
	end
	SCREEN.Pager:realignButtonsToGrid(SCREEN.Canvas.x + ROW_MARGIN, SCREEN.Canvas.y + ROW_MARGIN)
end

local function buildStatusTab()
	SCREEN.Pager.ButtonRows = {}
	SCREEN.Pager.Buttons = {}

	local startX = SCREEN.Canvas.x + 4
	local startY = SCREEN.Canvas.y + 3
	local function nextLineY(extraOffset)
		startY = startY + Constants.SCREEN.LINESPACING + 2 + (extraOffset or 0)
		return startY
	end

	SCREEN.Pager.Buttons.StatusHeaderConnectionStatus = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "Connection Status" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		textColor = SCREEN.Colors.highlight,
		box = {	startX, startY, Utils.calcWordPixelLength("Connection Status" or Resources.StreamConnectOverlay.LabelOrButton) + 5, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
		draw = function(self, shadowcolor)
			Drawing.drawUnderline(self)
		end,
	}
	local versionWidth = Utils.calcWordPixelLength("v" .. Network.STREAMERBOT_VERSION) + 5
	SCREEN.Pager.Buttons.StatusHeaderVersion = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "v" .. Network.STREAMERBOT_VERSION end,
		box = {	SCREEN.Canvas.w - versionWidth - MARGIN, startY, versionWidth, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
	}
	nextLineY(3)


	SCREEN.Pager.Buttons.StatusConnectionInfo = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CROSS,
		getText = function(self)
			if Network.CurrentConnection.State == Network.ConnectionState.Established then
				return "Online: Connection established." -- TODO: Language
			elseif Network.CurrentConnection.State == Network.ConnectionState.Listen then
				return "Online: Waiting for connection..." -- TODO: Language
			elseif Network.CurrentConnection.State == Network.ConnectionState.Closed then
				return "Offline." -- TODO: Language
			end
		end,
		box = {	startX + 3, startY, 13, 13 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
		updateSelf = function(self)
			if Network.CurrentConnection.State == Network.ConnectionState.Established then
				self.image = Constants.PixelImages.CHECKMARK
				self.iconColors = { "Positive text" }
			elseif Network.CurrentConnection.State == Network.ConnectionState.Listen then
				self.image = Constants.PixelImages.CLOCK
				self.iconColors = { SCREEN.Colors.highlight }
			elseif Network.CurrentConnection.State == Network.ConnectionState.Closed then
				self.image = Constants.PixelImages.CROSS
				self.iconColors = { "Negative text" }
			end
		end,
	}
	SCREEN.Pager.Buttons.StatusBtnConnect = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			-- TODO: Language
			if Network.isConnected() then
				return "Disconnect" or Resources.StreamConnectOverlay.LabelOrButton
			else
				return "Connect" or Resources.StreamConnectOverlay.LabelOrButton
			end
		end,
		box = {	startX + 150, startY - 1, 50, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
		updateSelf = function(self)
			-- Update width and box location depending on it's size
			self.box[3] = Utils.calcWordPixelLength(self:getText()) + 5
			self.box[1] = SCREEN.Canvas.x + SCREEN.Canvas.w - ROW_MARGIN - ROW_PADDING - self.box[3]
		end,
		onClick = function(self)
			if Network.isConnected() then
				Network.closeConnections()
			else
				Network.tryConnect()
			end
			StreamerScreen.refreshButtons()
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	}
	nextLineY(3)


	SCREEN.Pager.Buttons.StatusHeaderSettings = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "Settings" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		textColor = SCREEN.Colors.highlight,
		box = {	startX, startY, Utils.calcWordPixelLength("Settings" or Resources.StreamConnectOverlay.LabelOrButton) + 5, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
		draw = function(self, shadowcolor)
			Drawing.drawUnderline(self)
		end,
	}
	nextLineY(3)


	SCREEN.Pager.Buttons.StatusAutoConnectStartup = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return " " .. "Auto-connect on startup" or " " .. Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		clickableArea = { startX + 3, startY, 8 + Utils.calcWordPixelLength(" " .. "Auto-connect on startup"), 8 },
		box = { startX + 3, startY, 8, 8 },
		boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
		toggleState = Network.Options["AutoConnectStartup"],
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
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
	nextLineY(1)


	local rightColOffset = 90
	SCREEN.Pager.Buttons.StatusLabelConnType = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "Connection Mode:" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	startX, startY, 50, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
	}
	local connOffsetX = startX + rightColOffset - 2
	local connectionModes = Network.getSupportedConnectionTypes() or {}
	for _, connType in ipairs(connectionModes) do
		local text = connType or Resources.StreamConnectOverlay.LabelOrButton -- TODO: Language
		local width = Utils.calcWordPixelLength(text)
		SCREEN.Pager.Buttons["StatusConnType" .. connType] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return text end,
			isSelected = false,
			box = {	connOffsetX, startY, width + 4, 11 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
			updateSelf = function(self)
				self.isSelected = Network.CurrentConnection.Type == connType
			end,
			draw = function(self, shadowcolor)
				if self.isSelected and #connectionModes > 1 then
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
	nextLineY(1)


	local setButtonOffsetX = SCREEN.Canvas.x + SCREEN.Canvas.w - ROW_MARGIN - ROW_PADDING - 18
	SCREEN.Pager.Buttons.StatusDataFolder = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	setButtonOffsetX, startY, 18, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status and Network.CurrentConnection.Type == Network.ConnectionTypes.Text end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "Connection Folder:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
			local folder = FileManager.extractFolderNameFromPath(Network.Options["DataFolder"] or "") or ""
			if Utils.isNilOrEmpty(folder) then
				folder = "/"
			end
			Drawing.drawText(startX + rightColOffset - 1, y, folder, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
		end,
		onClick = function(self) StreamConnectOverlay.openNetworkFolderPrompt("DataFolder") end,
	}
	SCREEN.Pager.Buttons.StatusSocketIP = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	setButtonOffsetX, startY, 18, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status and Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "Server IP:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
			local val = Network.Options["WebSocketIP"] or "0.0.0.0"
			Drawing.drawText(startX + 50, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
		end,
		onClick = function(self) StreamConnectOverlay.openNetworkOptionPrompt("WebSocketIP") end,
	}
	SCREEN.Pager.Buttons.StatusHTTPGet = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	setButtonOffsetX, startY, 18, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status and Network.CurrentConnection.Type == Network.ConnectionTypes.Http end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "GET:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
			local val = Network.Options["HttpGet"] or "/"
			Drawing.drawText(startX + 35, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
		end,
		onClick = function(self) StreamConnectOverlay.openNetworkOptionPrompt("HttpGet") end,
	}
	nextLineY(1)


	SCREEN.Pager.Buttons.StatusGetCode = {
		type = Constants.ButtonTypes.FULL_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		getText = function(self) return "Get Streamerbot Code" end, -- TODO: Language
		-- textColor = SCREEN.Colors.highlight,
		box = { startX + rightColOffset, startY, Utils.calcWordPixelLength("Get Streamerbot Code") + 5, 11 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Status and Network.CurrentConnection.Type == Network.ConnectionTypes.Text end,
		onClick = function(self) StreamConnectOverlay.openGetCodeWindow() end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "Import Code:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
		end,
	}
	SCREEN.Pager.Buttons.StatusSocketPort = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	setButtonOffsetX, startY, 18, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status and Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "Port:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
			local val = Network.Options["WebSocketPort"] or "0"
			Drawing.drawText(startX + 50, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
		end,
		onClick = function(self) StreamConnectOverlay.openNetworkOptionPrompt("WebSocketPort") end,
	}
	SCREEN.Pager.Buttons.StatusHTTPPost = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Set" or Resources.StreamConnectOverlay.LabelOrButton end, -- TODO: Language
		box = {	setButtonOffsetX, startY, 18, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status and Network.CurrentConnection.Type == Network.ConnectionTypes.Http end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(startX + 1, y, "POST:", Theme.COLORS[SCREEN.Colors.text], shadowcolor) -- TODO: Language
			local val = Network.Options["HttpPost"] or "/"
			Drawing.drawText(startX + 35, y, val, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
		end,
		onClick = function(self) StreamConnectOverlay.openNetworkOptionPrompt("HttpPost") end,
	}
	nextLineY(3)


	SCREEN.Pager.Buttons.StatusUnsupportedModeWarning = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.WARNING,
		iconColors = { "Negative text" },
		getText = function(self)
			if Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets or Network.CurrentConnection.Type == Network.ConnectionTypes.Http then
				return "This mode not yet supported by Bizhawk." -- TODO: Language
			elseif Network.CurrentConnection.Type == Network.ConnectionTypes.Text then
				return "Setup: Import code then set connection folder." -- TODO: Language
			else
				return ""
			end
		end,
		box = {	startX + 3, startY, 10, 10 },
		isVisible = function(self)
			if SCREEN.currentTab ~= SCREEN.Tabs.Status then
				return false
			end
			if Network.CurrentConnection.Type == Network.ConnectionTypes.Text then
				return Utils.isNilOrEmpty(Network.Options["DataFolder"])
			elseif Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets then
				return true
			elseif Network.CurrentConnection.Type == Network.ConnectionTypes.Http then
				return true
			else
				return false
			end
		end,
		updateSelf = function(self)
			if Network.CurrentConnection.Type == Network.ConnectionTypes.WebSockets or Network.CurrentConnection.Type == Network.ConnectionTypes.Http then
				self.iconColors = { "Negative text" }
			else
				self.iconColors = { SCREEN.Colors.highlight }
			end
		end,
	}
	nextLineY(4)


	local bottomRowY = SCREEN.Canvas.y + SCREEN.Canvas.h - 15
	SCREEN.Pager.Buttons.StatusHelp = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return "Help" or Resources.StreamConnectOverlay.X end, -- TODO: Language
		textColor = SCREEN.Colors.text,
		box = {	SCREEN.Canvas.x + 4, bottomRowY, Utils.calcWordPixelLength("Help") + 5, 11 },
		boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Status end,
		onClick = function(self) Utils.openBrowserWindow(FileManager.Urls.STREAM_CONNECT) end,
	}


	SCREEN.Pager:realignButtonsToGrid(SCREEN.Canvas.x + ROW_MARGIN, SCREEN.Canvas.y + ROW_MARGIN)
end

function StreamConnectOverlay.buildPagedButtons(tab)
	tab = tab or SCREEN.currentTab
	local tabBuilderFuncs = {
		[SCREEN.Tabs.Commands] = buildCommandsTab,
		[SCREEN.Tabs.Rewards] = buildRewardsTab,
		[SCREEN.Tabs.Queue] = buildQueueTab,
		[SCREEN.Tabs.Game] = buildGameTab,
		[SCREEN.Tabs.Status] = buildStatusTab,
	}
	if tabBuilderFuncs[tab] then
		tabBuilderFuncs[tab]()
	else
		SCREEN.Pager.ButtonRows = {}
		SCREEN.Pager.Buttons = {}
		SCREEN.Pager:realignButtonsToGrid()
	end
end

-- Rebuilds the buttons for the currently displayed screen. Useful when the Tracker's display language changes
function StreamConnectOverlay.rebuildScreen()
	if not SCREEN.isDisplayed then return end
	SCREEN.createTabButtons()
	SCREEN.buildPagedButtons(SCREEN.currentTab)
	SCREEN.refreshButtons()
end

function StreamConnectOverlay.open()
	if SCREEN.isDisplayed then return end
	SCREEN.isDisplayed = true
	if Network.isConnected() and Network.CurrentConnection.State >= Network.ConnectionState.Established then
		local firstTab = Utils.getSortedList(SCREEN.Tabs)[1]
		SCREEN.changeTab(firstTab)
	else
		SCREEN.changeTab(SCREEN.Tabs.Status)
	end
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
	local form = Utils.createBizhawkForm("Edit Command", 320, 140, 100, 50)
	local x, y, lineHeight = 30, 15, 20

	forms.label(form, string.format("Command: %s", event.Name), x - 1, y, 300, y)
	y = y + lineHeight
	local textbox = forms.textbox(form, event.Command, 120, lineHeight, nil, x + 1, y)
	y = y + lineHeight

	y = y + 15
	forms.button(form, Resources.AllScreens.Save, function()
		local text = forms.gettext(textbox) or ""
		if #text > 2 and text:sub(1,1) == "!" then -- Command requirements
			event.Command = Utils.toLowerUTF8(text)
			EventHandler.saveEventSetting(event, "Command")
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
		Utils.closeBizhawkForm(form)
	end, 30, y)
	forms.button(form, "(Default)", function() -- TODO: Language
		local defaultEvent = EventHandler.DefaultEvents[event.Key]
		if defaultEvent then
			forms.settext(textbox, defaultEvent.Command)
		end
	end, 120, y)
	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 210, y)
end

function StreamConnectOverlay.openCommandRolesPrompt()
	local form = Utils.createBizhawkForm("Edit Command Roles", 320, 255, 100, 40) -- TODO: Language

	local x, y = 20, 15
	local lineHeight = 21
	local commandLabel = string.format("Select user roles that can use Tracker chat commands:") -- TODO: Language
	forms.label(form, commandLabel, x - 1, y, 300, 20)
	y = y + lineHeight

	-- Current role options, from the user settings
	local currentRoles = {}
	for _, roleKey in pairs(Utils.split(Network.Options["CommandRoles"], ",", true) or {}) do
		currentRoles[roleKey] = true
	end
	-- All available role options, in a predefined order
	local orderedRoles = { "Broadcaster", "Moderator", "Vip", "Subscriber", --[["Custom",]] "Everyone" }
	local roleCheckboxes = {}
	local customRoleTextbox

	for i, roleKey in ipairs(orderedRoles) do
		local roleLabel = roleKey
		if roleKey == "Custom" then
			roleLabel = "Custom Role:"
			customRoleTextbox = forms.textbox(form, Network.Options["CustomCommandRole"], 120, 19, nil, x + 143, y + lineHeight * (i - 1))
		end
		roleCheckboxes[roleKey] = forms.checkbox(form, roleLabel, x, y + lineHeight * (i - 1)) -- TODO: Language
		local roleAllowed = currentRoles["Everyone"] ~= nil or currentRoles[roleKey] ~= nil
		forms.setproperty(roleCheckboxes[roleKey], "Checked", roleAllowed)
	end
	forms.setproperty(roleCheckboxes["Broadcaster"], "Checked", true)
	forms.setproperty(roleCheckboxes["Broadcaster"], "Enabled", false)

	-- Enable or Disable all non-Everyone roles based on the state of Everyone role being allowed
	local function enableDisableAll()
		local allowEveryone = forms.ischecked(roleCheckboxes["Everyone"])
		for _, roleKey in ipairs(orderedRoles) do
			if roleKey ~= "Everyone" and roleKey ~= "Broadcaster" then
				forms.setproperty(roleCheckboxes[roleKey], "Enabled", not allowEveryone)
			end
		end
		if customRoleTextbox then
			forms.setproperty(customRoleTextbox, "Enabled", not allowEveryone)
		end
	end
	forms.addclick(roleCheckboxes["Everyone"], enableDisableAll)
	enableDisableAll()

	local buttonRowY = y + lineHeight * #orderedRoles + 15
	forms.button(form, Resources.AllScreens.Save, function()
		if forms.ischecked(roleCheckboxes["Everyone"]) then
			Network.Options["CommandRoles"] = EventHandler.CommandRoles.Everyone
		else
			if forms.ischecked(roleCheckboxes["Custom"]) and customRoleTextbox then
				Network.Options["CustomCommandRole"] = forms.gettext(customRoleTextbox) or ""
			else
				Network.Options["CustomCommandRole"] = ""
			end
			local allowedRoles = {}
			for _, roleKey in ipairs(orderedRoles) do
				if forms.ischecked(roleCheckboxes[roleKey]) then
					if roleKey == "Custom" then
						if not Utils.isNilOrEmpty(Network.Options["CustomCommandRole"]) then
							table.insert(allowedRoles, Network.Options["CustomCommandRole"])
						end
					else
						table.insert(allowedRoles, EventHandler.CommandRoles[roleKey])
					end
				end
			end
			Network.Options["CommandRoles"] = table.concat(allowedRoles, ",")
		end
		Main.SaveSettings(true)
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			EventKey = EventHandler.CoreEventKeys.UpdateEvents,
		}))
		SCREEN.refreshButtons()
		Program.redraw(true)
		Utils.closeBizhawkForm(form)
	end, 30, buttonRowY)
	forms.button(form, "(Default)", function() -- TODO: Language
		for _, roleKey in ipairs(orderedRoles) do
			forms.setproperty(roleCheckboxes[roleKey], "Checked", true)
		end
		forms.settext(customRoleTextbox, "")
		enableDisableAll()
	end, 120, buttonRowY)
	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 210, buttonRowY)
end

function StreamConnectOverlay.openEventOptionsPrompt(event)
	local x, y, lineHeight = 20, 15, 20
	local form = Utils.createBizhawkForm("Edit Reward Options", 320, 130 + (#event.Options * lineHeight), 100, 50) -- TODO: Language

	forms.label(form, event.Name, x, y, 300, lineHeight)
	y = y + lineHeight + 5

	local rightColOffset = 180
	local optionsInForm = {}
	for _, optionKey in ipairs(event.Options) do
		local currentValue = event[optionKey]
		if type(currentValue) == "boolean" then
			local optionText = Resources.StreamConnectOverlay[optionKey] or optionKey or Constants.BLANKLINE
			forms.label(form, optionText .. ":", x, y, rightColOffset - 2, lineHeight)
			optionsInForm[optionKey] = forms.checkbox(form, "", x + rightColOffset, y - 4)
			forms.setproperty(optionsInForm[optionKey], "Checked", currentValue)
			y = y + lineHeight
		elseif type(currentValue) == "string" or type(currentValue) == "number" then
			local optionText = Resources.StreamConnectOverlay[optionKey] or optionKey or Constants.BLANKLINE
			forms.label(form, optionText .. ":", x, y, rightColOffset - 2, lineHeight)
			optionsInForm[optionKey] = forms.textbox(form, tostring(currentValue), 92, 19, nil, x + rightColOffset, y)
			y = y + lineHeight
		end
	end

	local buttonRowY = y + 15
	forms.button(form, Resources.AllScreens.Save, function()
		for optionKey, formHandle in pairs(optionsInForm) do
			local currentValue = event[optionKey]
			local newValue
			if type(currentValue) == "boolean" then
				newValue = forms.ischecked(formHandle)
			elseif type(currentValue) == "string" or type(currentValue) == "number" then
				newValue = forms.gettext(formHandle) or ""
			elseif type(currentValue) == "number" then
				newValue = forms.gettext(formHandle) or ""
				-- newValue = tonumber(forms.gettext(formHandle) or "") or "" -- numbers not yet supported
			end
			-- Save only new changes
			if newValue ~= nil and newValue ~= currentValue then
				event[optionKey] = newValue
				EventHandler.saveEventSetting(event, optionKey)
			end
		end
		SCREEN.refreshButtons()
		Program.redraw(true)
		Utils.closeBizhawkForm(form)
	end, 30, buttonRowY)
	forms.button(form, "(Default)", function() -- TODO: Language
		local defaultEvent = EventHandler.DefaultEvents[event.Key]
		if not defaultEvent then
			return
		end
		for optionKey, formHandle in pairs(optionsInForm) do
			local defaultValue = defaultEvent[optionKey]
			if defaultValue ~= nil then
				local currentValue = event[optionKey]
				if type(currentValue) == "boolean" then
					forms.setproperty(formHandle, "Checked", defaultValue)
				elseif type(currentValue) == "string" or type(currentValue) == "number" then
					forms.settext(formHandle, defaultValue)
				end
			end
		end
	end, 120, buttonRowY)
	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 210, buttonRowY)
end

function StreamConnectOverlay.openRewardListPrompt(event)
	local form = Utils.createBizhawkForm("Edit Reward Association", 320, 170, 100, 50) -- TODO: Language
	local rewardEventText = string.format("Tracker Reward: %s", event.Name) -- TODO: Language
	forms.label(form, rewardEventText, 28, 10, 300, 20)
	local rewardTriggerTxt = "Triggered by Twitch Reward:" -- TODO: Language
	forms.label(form, rewardTriggerTxt, 28, 35, 250, 20)

	local CHOICE_NONE = "(None)" -- TODO: Language
	local rewardsList = { CHOICE_NONE }
	for _, rewardTitle in pairs(EventHandler.RewardsExternal) do
		table.insert(rewardsList, rewardTitle)
	end

	local dropdown = forms.dropdown(form, {["Init"]="Loading Rewards"}, 33, 60, 230, 30)
	forms.setdropdownitems(dropdown, rewardsList, true) -- true = alphabetize the list
	forms.setproperty(dropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(dropdown, "AutoCompleteMode", "Append")
	if not Utils.isNilOrEmpty(EventHandler.RewardsExternal[event.RewardId]) then
		forms.settext(dropdown, EventHandler.RewardsExternal[event.RewardId])
	end

	forms.button(form, Resources.AllScreens.Save, function()
		local optionSelected = forms.gettext(dropdown)
		if not optionSelected or optionSelected == CHOICE_NONE then
			event.RewardId = ""
		else
			for rewardId, rewardTitle in pairs(EventHandler.RewardsExternal) do
				if optionSelected == rewardTitle then
					event.RewardId = rewardId
					break
				end
			end
		end
		event.IsEnabled = not Utils.isNilOrEmpty(event.RewardId)
		EventHandler.saveEventSetting(event, "RewardId")
		SCREEN.refreshButtons()
		Program.redraw(true)
		Utils.closeBizhawkForm(form)
	end, 30, 100)
	forms.button(form, Resources.AllScreens.Clear, function()
		forms.settext(dropdown, CHOICE_NONE)
	end, 120, 100)
	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 210, 100)
end

function StreamConnectOverlay.openNetworkOptionPrompt(modeKey)
	local form = Utils.createBizhawkForm(string.format("Edit %s", modeKey), 320, 130, 100, 50) -- TODO: Language
	forms.label(form, string.format("%s:", modeKey), 28, 20, 110, 20) -- TODO: Language

	local textbox = forms.textbox(form, Network.Options[modeKey] or "", 134, 20, nil, 150, 18)

	forms.button(form, Resources.AllScreens.Save, function()
		local text = forms.gettext(textbox) or ""
		if #text ~= 0 then
			Network.closeConnections()
			Network.Options[modeKey] = text
			Main.SaveSettings(true)
			SCREEN.refreshButtons()
			Program.redraw(true)
		end
		Utils.closeBizhawkForm(form)
	end, 30, 50)
	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 210, 50)
end

function StreamConnectOverlay.openNetworkFolderPrompt(modeKey)
	local path = Network.Options[modeKey] or ""
	local filterOptions = "Json File (*.JSON)|*.json|All files (*.*)|*.*"
	Utils.tempDisableBizhawkSound()
	local filepath = forms.openfile("SELECT ANY JSON FILE", path, filterOptions)
	if not Utils.isNilOrEmpty(filepath) then
		-- Since the user had to pick a file, strip out the file name to just get the folder path
		local pattern = "^.*()" .. FileManager.slash
		filepath = filepath:sub(0, (filepath:match(pattern) or 1) - 1)

		-- If the file path changes
		if not Utils.containsText(Network.Options[modeKey], filepath) then
			Network.closeConnections()
		end
		if Utils.isNilOrEmpty(filepath) then
			Network.Options[modeKey] = ""
		else
			Network.Options[modeKey] = filepath
		end
		Main.SaveSettings(true)
	end
	Utils.tempEnableBizhawkSound()
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function StreamConnectOverlay.openGetCodeWindow()
	local form = Utils.createBizhawkForm("Import to Streamerbot", 800, 600) -- TODO: Language
	local x, y, lineHeight = 20, 15, 20
	local codeText = Network.getStreamerbotCode()

	forms.label(form, '1. On Streamerbot, click the IMPORT button at the top.', x, y, 495, lineHeight)
	y = y + lineHeight
	forms.label(form, '2. Copy/paste the below code into the top textbox. Click "Import" and "OK".', x, y, 495, lineHeight)
	y = y + lineHeight
	forms.label(form, '3. Restart Streamerbot.', x, y, 495, lineHeight)
	y = y + lineHeight
	forms.textbox(form, codeText, 763, 442, nil, x - 1, y, true, true, "Vertical")

	forms.label(form, string.format("Streamerbot Code Version: %s", Network.STREAMERBOT_VERSION), x, 530, 250, lineHeight)
	forms.button(form, Resources.AllScreens.Close, function()
		Utils.closeBizhawkForm(form)
	end, 350, 530)
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

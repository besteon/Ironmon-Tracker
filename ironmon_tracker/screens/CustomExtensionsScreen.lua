CustomExtensionsScreen = {
	Key = "CustomExtensionsScreen",
	Colors = {
		text = "Lower box text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Tabs = {
		General = {
			index = 1,
			tabKey = "General",
			resourceKey = "TabGeneral",
		},
		Extensions = {
			index = 2,
			tabKey = "Extensions",
			resourceKey = "TabExtensions",
		},
		Options = {
			index = 3,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	currentTab = nil,
}
local SCREEN = CustomExtensionsScreen
local TAB_HEIGHT = 12
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN + 10 + TAB_HEIGHT,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10 - TAB_HEIGHT,
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a:getText() < b:getText() end, -- Order ascending by name
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer, sortFunc)
		table.sort(self.Buttons, sortFunc or self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local text = string.format("%s/%s", self.currentPage, self.totalPages)
		local bufferSize = 7 - text:len()
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

SCREEN.Buttons = {
	-- GENERAL TAB
	LabelNumberEnabled = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources[SCREEN.Key].LabelExtensionsEnabled) end,
		box = { CANVAS.X + 9, CANVAS.Y + 5, 120, 11 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.General end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local count = #CustomCode.EnabledExtensions
			local color = Theme.COLORS[SCREEN.Colors.positive]
			Drawing.drawRightJustifiedNumber(x + w - 15, y, count, 3, color, shadowcolor)
		end,
	},
	LabelNumberInstalled = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources[SCREEN.Key].LabelTotalInstalled) end,
		box = { CANVAS.X + 9, CANVAS.Y + 16, 120, 11 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.General end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local count = CustomCode.ExtensionCount or 0
			local color = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawRightJustifiedNumber(x + w - 15, y, count, 3, color, shadowcolor)
		end,
	},
	UpdateAllExtensions = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SPARKLES,
		iconColors = { SCREEN.Colors.highlight },
		getText = function(self) return Resources[SCREEN.Key].ButtonUpdateAllExtensions end,
		box = { CANVAS.X + 10, CANVAS.Y + 33, 120, 16 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.General and CustomCode.ExtensionCount > 0 end,
		onClick = function(self)
			-- TODO: Popup box prompt for confimation and status
		end,
	},
	FindMoreExtensions = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAP_PINDROP,
		getText = function(self) return Resources[SCREEN.Key].ButtonFindMoreExtensions end,
		box = { CANVAS.X + 10, CANVAS.Y + 57, 120, 16 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.EXTENSIONS)
		end,
	},
	InstallFromUrl = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		getText = function(self) return Resources[SCREEN.Key].ButtonInstallFromUrl end,
		box = { CANVAS.X + 10, CANVAS.Y + 76, 120, 16 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function(self)
			-- TODO: Popup box prompt
		end,
	},
	InstallFromFolder = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		getText = function(self) return Resources[SCREEN.Key].ButtonInstallFromFolder end,
		box = { CANVAS.X + 10, CANVAS.Y + 95, 120, 16 },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function(self)
			-- TODO: Popup box prompt if no changes
			CustomCode.refreshExtensionList()
			SCREEN.buildOutPagedButtons()
			Program.redraw(true)
		end,
	},

	-- EXTENSIONS TAB
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { CANVAS.X + 50, CANVAS.Y + 114, 50, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Extensions and SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { CANVAS.X + 43, CANVAS.Y + 115, 10, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Extensions and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { CANVAS.X + 87, CANVAS.Y + 115, 10, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Extensions and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end,
	},

	-- OPTIONS TAB
	EnableCustomExtensions = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Enable custom extensions",
		getText = function(self) return Resources[SCREEN.Key].OptionAllowCustomCode end,
		clickableArea = { CANVAS.X + 4, CANVAS.Y + 4, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	CANVAS.X + 4, CANVAS.Y + 4, 8, 8 },
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Options end,
		onClick = function(self)
			-- If the option was ON and will become OFF...
			if Options[self.optionKey] then
				-- Then first deactivate paged buttons and run unload(), then stop custom code from running
				SCREEN.togglePagedButtons(false)
				self.toggleState = Options.toggleSetting(self.optionKey)
			else
				-- Otherwise, first allow for custom code to be run, then activate paged buttons and run startup()
				self.toggleState = Options.toggleSetting(self.optionKey)
				SCREEN.togglePagedButtons(true)
			end
			Program.redraw(true)
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		SCREEN.refreshButtons()
		Program.changeScreenView(NavigationMenu)
	end),
}

function SCREEN.initialize()
	SCREEN.currentTab = SCREEN.Tabs.General
	SCREEN.Pager.Buttons = {}
	SCREEN.createTabs()

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

function SCREEN.createTabs()
	local startX = CANVAS.X
	local startY = CANVAS.Y - TAB_HEIGHT
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources[SCREEN.Key][tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return tabText end,
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
				local centeredOffsetX = Utils.getCenteredTextX(self:getCustomText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getCustomText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self)
				SCREEN.currentTab = self.tab
				SCREEN.Pager.currentPage = 1
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end

function SCREEN.buildOutPagedButtons()
	SCREEN.Pager.Buttons = {}

	for extensionKey, extension in pairs(CustomCode.ExtensionLibrary) do
		-- If the button itself is disabled and not active
		local isBtnDisabled = not Options["Enable custom extensions"]

		local button = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = nil, -- Updated later
			getText = function(self) return extension.selfObject.name or Constants.BLANKLINE end,
			textColor = SCREEN.Colors.text, -- Updated later
			iconColors = { SCREEN.Colors.positive }, -- Updated later
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill, },
			extension = extension,
			extensionKey = extensionKey,
			dimensions = { width = 132, height = 16, },
			disabled = isBtnDisabled,
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Extensions and SCREEN.Pager.currentPage == self.pageVisible end,
			updateSelf = function(self)
				-- Check if the extension itself is enabled, and update the icon accordingly
				if self.extension.isEnabled then
					self.image = Constants.PixelImages.CHECKMARK
					self.iconColors = { SCREEN.Colors.positive }
				else
					self.image = Constants.PixelImages.CROSS
					self.iconColors = { SCREEN.Colors.negative }
				end
				-- Check if the button is disabled, and update text color accordingly
				if self.disabled then
					self.textColor = SCREEN.Colors.negative
				else
					self.textColor = SCREEN.Colors.text
				end
			end,
			onClick = function(self)
				SingleExtensionScreen.setupScreenWithInfo(self.extensionKey, self.extension)
				Program.changeScreenView(SingleExtensionScreen)
			end,
		}
		button:updateSelf()
		table.insert(SCREEN.Pager.Buttons, button)
	end

	local x = CANVAS.X + 4
	local y = CANVAS.Y + 5
	local colSpacer = 0
	local rowSpacer = 2
	-- Order to show enabled extensions first, then alphabetically
	local sortFunc = function(a, b)
		return a.extension.isEnabled and not b.extension.isEnabled
			or (a.extension.isEnabled == b.extension.isEnabled and a:getText() < b:getText())
	end
	SCREEN.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer, sortFunc)

	return true
end

-- Turns all of the paged buttons ON (makeActive = true) or OFF (makeActive = false), calling startup/unload appropriately
-- If they are OFF, they cannot be pressed and have "Negative text" color
function SCREEN.togglePagedButtons(makeActive)
	for _, button in ipairs(SCREEN.Pager.Buttons) do
		button.disabled = not makeActive
	end
	if makeActive then
		CustomCode.startup()
	else
		CustomCode.unload()
	end
	SCREEN.refreshButtons()
end

function SCREEN.refreshButtons()
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

-- USER INPUT FUNCTIONS
function SCREEN.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function SCREEN.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SCREEN.Colors.boxFill])

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
	local headerText = Utils.toUpperUTF8(Resources[SCREEN.Key].Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

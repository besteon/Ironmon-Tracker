-- TODO: Redo this whole file to match Drawing.drawTeamDisplay()

TeamViewArea = {
	Labels = {
		header = "Team View",
		pageFormat = "Pg. %s/%s", -- e.g. Pg. 1/3
		noExtensions = "You currently don't have any custom extensions installed.",
	},
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

TeamViewArea.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.extension.selfObject.name < b.extension.selfObject.name end, -- Order ascending by extension name
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
		TeamViewArea.Buttons.CurrentPage:updateText()
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return "Page" end
		local buffer = Utils.inlineIf(self.currentPage > 9, "", " ") .. Utils.inlineIf(self.totalPages > 9, "", " ")
		return buffer .. string.format(TeamViewArea.Labels.pageFormat, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
}

TeamViewArea.Buttons = {
	GetExtensionsSmall = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "(Get more)",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 93, Constants.SCREEN.MARGIN - 2, 47, 12 },
		isVisible = function() return #TeamViewArea.Pager.Buttons > 0 end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.EXTENSIONS)
		end
	},
	EnableCustomExtensions = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = " Allow custom code to run", -- offset with a space for appearance
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 8, 8 },
		toggleState = true, -- update later in initialize
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState

			if self.toggleState then
				-- First allow for custom code to be run, then activate paged buttons and run startup()
				Options.updateSetting("Enable custom extensions", self.toggleState)
				TeamViewArea.togglePagedButtons(self.toggleState)
			else
				-- First deactivate paged buttons and run unload(), then stop custom code from running
				TeamViewArea.togglePagedButtons(self.toggleState)
				Options.updateSetting("Enable custom extensions", self.toggleState)
			end
			Options.forceSave()
		end
	},
	GetExtensions = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		text = "Get Extensions",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 28, Constants.SCREEN.MARGIN + 70, 80, 16 },
		isVisible = function() return #TeamViewArea.Pager.Buttons == 0 end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.EXTENSIONS)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 55, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return TeamViewArea.Pager.totalPages > 1 end,
		updateText = function(self)
			self.text = TeamViewArea.Pager:getPageText()
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 44, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return TeamViewArea.Pager.totalPages > 1 end,
		onClick = function(self)
			TeamViewArea.Pager:prevPage()
			TeamViewArea.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return TeamViewArea.Pager.totalPages > 1 end,
		onClick = function(self)
			TeamViewArea.Pager:nextPage()
			TeamViewArea.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	RefreshExtensionList = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Refresh",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 35, 11 },
		onClick = function(self)
			CustomCode.refreshExtensionList()
			TeamViewArea.buildOutPagedButtons()
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			TeamViewArea.refreshButtons()
			Program.changeScreenView(NavigationMenu)
		end
	},
}

function TeamViewArea.initialize()
	for _, button in pairs(TeamViewArea.Buttons) do
		if button.textColor == nil then
			button.textColor = TeamViewArea.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { TeamViewArea.Colors.border, TeamViewArea.Colors.boxFill }
		end
	end
	TeamViewArea.Buttons.EnableCustomExtensions.toggleState = Options["Enable custom extensions"]
	TeamViewArea.Buttons.CurrentPage:updateText()
end

function TeamViewArea.buildOutPagedButtons()
	TeamViewArea.Pager.Buttons = {}

	for extensionKey, extension in pairs(CustomCode.ExtensionLibrary) do
		local image = Utils.inlineIf(extension.isEnabled, Constants.PixelImages.CHECKMARK, Constants.PixelImages.CROSS)
		local iconColors = Utils.inlineIf(extension.isEnabled, { "Positive text", }, { "Negative text", })

		-- If the button itself is disabled and not active
		local isBtnDisabled = not Options["Enable custom extensions"]
		local textColor = Utils.inlineIf(isBtnDisabled, "Negative text", TeamViewArea.Colors.text)

		local button = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = image,
			text = extension.selfObject.name or Constants.BLANKLINE,
			textColor = textColor,
			iconColors = iconColors,
			boxColors = { TeamViewArea.Colors.border, TeamViewArea.Colors.boxFill, },
			extension = extension,
			extensionKey = extensionKey,
			dimensions = { width = 132, height = 16, },
			disabled = isBtnDisabled,
			isVisible = function(self) return TeamViewArea.Pager.currentPage == self.pageVisible end,
			updateText = function(self)
				-- Check if the extension itself is enabled, and update the icon accordingly
				if self.extension.isEnabled then
					self.image = Constants.PixelImages.CHECKMARK
					self.iconColors = { "Positive text", }
				else
					self.image = Constants.PixelImages.CROSS
					self.iconColors = { "Negative text", }
				end

				-- Check if the button is disabled, and update text color accordingly
				if self.disabled then
					self.textColor = "Negative text"
				else
					self.textColor = TeamViewArea.Colors.text
				end
			end,
			onClick = function(self)
				SingleExtensionScreen.setupScreenWithInfo(self.extensionKey, self.extension)
				Program.changeScreenView(SingleExtensionScreen)
			end,
		}
		table.insert(TeamViewArea.Pager.Buttons, button)
	end

	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local y = Constants.SCREEN.MARGIN + 29
	local colSpacer = 1
	local rowSpacer = 5
	TeamViewArea.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

function TeamViewArea.refreshButtons()
	for _, button in pairs(TeamViewArea.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
	for _, button in pairs(TeamViewArea.Pager.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

-- Turns all of the paged buttons ON (makeActive = true) or OFF (makeActive = false), calling startup/unload appropriately
-- If they are OFF, they cannot be pressed and have "Negative text" color
function TeamViewArea.togglePagedButtons(makeActive)
	for _, button in ipairs(TeamViewArea.Pager.Buttons) do
		button.disabled = not makeActive
		button:updateText()
	end
end

-- USER INPUT FUNCTIONS
function TeamViewArea.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, TeamViewArea.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, TeamViewArea.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function TeamViewArea.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[TeamViewArea.Colors.boxFill])

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[TeamViewArea.Colors.text],
		border = Theme.COLORS[TeamViewArea.Colors.border],
		fill = Theme.COLORS[TeamViewArea.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[TeamViewArea.Colors.boxFill]),
	}
	local headerText = TeamViewArea.Labels.header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x - 1, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)
	local textLineY = topBox.y + Constants.SCREEN.LINESPACING + 3 -- make room for first checkbox

	if #TeamViewArea.Pager.Buttons == 0 then
		local wrappedDesc = Utils.getWordWrapLines(TeamViewArea.Labels.noExtensions, 32)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
		for _, line in pairs(wrappedDesc) do
			local centeredOffset = Utils.getCenteredTextX(line, topBox.width)
			Drawing.drawText(topBox.x + centeredOffset, textLineY, line, Theme.COLORS["Intermediate text"], topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING
		end
	end

	-- Draw all buttons
	for _, button in pairs(TeamViewArea.Buttons) do
		if button == TeamViewArea.Buttons.GetExtensionsSmall then
			Drawing.drawButton(button, nil)
		else
			Drawing.drawButton(button, topBox.shadow)
		end
	end
	for _, button in pairs(TeamViewArea.Pager.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

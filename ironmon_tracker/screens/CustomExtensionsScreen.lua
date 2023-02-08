CustomExtensionsScreen = {
	Labels = {
		header = "Custom Extensions",
		pageFormat = "Page %s/%s", -- e.g. Page 1/3
		noExtensions = "No Extensions Found",
	},
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
}

CustomExtensionsScreen.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.name > b.name end,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
		CustomExtensionsScreen.Buttons.CurrentPage:updateText()
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return "Page" end
		return string.format(CustomExtensionsScreen.Labels.pageFormat, self.currentPage, self.totalPages)
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

CustomExtensionsScreen.Buttons = {
	EnableCustomExtensions = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = " Enable custom extensions", -- offset with a space for appearance
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 8, 8 },
		toggleState = true, -- update later in initialize
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting("Enable custom extensions", self.toggleState)
			Options.forceSave()
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
		updateText = function(self)
			self.text = CustomExtensionsScreen.Pager:getPageText()
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 39, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			CustomExtensionsScreen.Pager:prevPage()
			CustomExtensionsScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			CustomExtensionsScreen.Pager:nextPage()
			CustomExtensionsScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	RefreshExtensionList = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Refresh",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 31, 11 },
		onClick = function(self)
			CustomExtensionsScreen.refreshExtensionList()
			CustomExtensionsScreen.buildOutPagedButtons()
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			CustomExtensionsScreen.resetButtons()
			Program.changeScreenView(Program.Screens.SETUP)
		end
	},
}

function CustomExtensionsScreen.initialize()
	for _, button in pairs(CustomExtensionsScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = CustomExtensionsScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { CustomExtensionsScreen.Colors.border, CustomExtensionsScreen.Colors.boxFill }
		end
	end
	CustomExtensionsScreen.Buttons.EnableCustomExtensions.toggleState = Options["Enable custom extensions"]
	CustomExtensionsScreen.Buttons.CurrentPage:updateText()
end

function CustomExtensionsScreen.refreshExtensionList()
	local customFolderPath = FileManager.getCustomFolderPath()
	local customFiles = FileManager.getFilesFromDirectory(customFolderPath)
	for _, filename in pairs(customFiles) do
		local name = FileManager.extractFileNameFromPath(filename) or ""
		local ext = FileManager.extractFileExtensionFromPath(filename) or ""
		Utils.printDebug("name: %s, ext: %s", name, ext)
	end
end

function CustomExtensionsScreen.buildOutPagedButtons()
	CustomExtensionsScreen.Pager.Buttons = {}

	for _, extension in pairs(CustomCode.ExtensionLibrary) do
		local button = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = Constants.PixelImages.CHECKMARK,
			text = extension.name or Constants.BLANKLINE,
			textColor = CustomExtensionsScreen.Colors.text,
			iconColors = Utils.inlineIf(extension.isEnabled, { "Positive text", }, { "Negative text", }),
			extension = extension,
			dimensions = { width = 124, height = 16, },
			isVisible = function(self) return CustomExtensionsScreen.Pager.currentPage == self.pageVisible end,
			updateText = function(self)
				if self.extension.isEnabled then
					self.iconColors = { "Positive text", }
				else
					self.iconColors = { "Negative text", }
				end
			end,
			-- draw = function(self, shadowcolor)
			-- 	local minutesAgo = math.ceil((os.time() - restorePoint.timestamp) / 60)
			-- 	local includeS = Utils.inlineIf(minutesAgo ~= 1, "s", "")
			-- 	local timestampText = string.format(CustomExtensionsScreen.Labels.restoreTimeFormat, minutesAgo, includeS)
			-- 	local rightAlignOffset = self.box[3] - Utils.calcWordPixelLength(timestampText) - 2
			-- 	Drawing.drawText(self.box[1] + rightAlignOffset, self.box[2] + self.box[4] + 1, timestampText, Theme.COLORS[CustomExtensionsScreen.Colors.text], shadowcolor)
			-- end,
			onClick = function(self)
				-- TODO: Navigate to single screen to show enable/disable options; for now, toggle it
				self.extension.isEnabled = not self.extension.isEnabled
				self:updateText()
			end,
		}
		table.insert(CustomExtensionsScreen.Pager.Buttons, button)
	end

	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8
	local y = Constants.SCREEN.MARGIN + 48
	local colSpacer = 1
	local rowSpacer = Constants.SCREEN.LINESPACING + 7
	CustomExtensionsScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

function CustomExtensionsScreen.resetButtons()
	for _, button in pairs(CustomExtensionsScreen.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
	for _, button in pairs(CustomExtensionsScreen.Pager.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

-- DRAWING FUNCTIONS
function CustomExtensionsScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[CustomExtensionsScreen.Colors.boxFill])

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[CustomExtensionsScreen.Colors.text],
		border = Theme.COLORS[CustomExtensionsScreen.Colors.border],
		fill = Theme.COLORS[CustomExtensionsScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[CustomExtensionsScreen.Colors.boxFill]),
	}
	local headerText = CustomExtensionsScreen.Labels.header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local offsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + offsetX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)
	local textLineY = topBox.y + Constants.SCREEN.LINESPACING + 3 -- make room for first checkbox

	-- local wrappedDesc = Utils.getWordWrapLines(CustomExtensionsScreen.Labels.description, 32)
	-- for _, line in pairs(wrappedDesc) do
	-- 	Drawing.drawText(topBox.x + 3, textLineY, line, topBox.text, topBox.shadow)
	-- 	textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
	-- end

	if #CustomExtensionsScreen.Pager.Buttons == 0 then
		local wrappedDesc = Utils.getWordWrapLines(CustomExtensionsScreen.Labels.noExtensions, 32)
		textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		for _, line in pairs(wrappedDesc) do
			Drawing.drawText(topBox.x + 3, textLineY, line, Theme.COLORS["Negative text"], topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
	end

	-- Draw all buttons
	for _, button in pairs(CustomExtensionsScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
	for _, button in pairs(CustomExtensionsScreen.Pager.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

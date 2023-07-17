CustomExtensionsScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

CustomExtensionsScreen.Pager = {
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

CustomExtensionsScreen.Buttons = {
	GetExtensionsSmall = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.CustomExtensionsScreen.ButtonGetMore end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 93, Constants.SCREEN.MARGIN - 2, 47, 12 },
		isVisible = function() return #CustomExtensionsScreen.Pager.Buttons > 0 end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.EXTENSIONS)
		end
	},
	EnableCustomExtensions = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Enable custom extensions",
		getText = function(self) return Resources.CustomExtensionsScreen.OptionAllowCustomCode end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 8, 8 },
		toggleState = true,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			-- If the option was ON and will become OFF...
			if Options[self.optionKey] then
				-- Then first deactivate paged buttons and run unload(), then stop custom code from running
				CustomExtensionsScreen.togglePagedButtons(false)
				self.toggleState = Options.toggleSetting(self.optionKey)
			else
				-- Otherwise, first allow for custom code to be run, then activate paged buttons and run startup()
				self.toggleState = Options.toggleSetting(self.optionKey)
				CustomExtensionsScreen.togglePagedButtons(true)
			end
			Program.redraw(true)
		end
	},
	GetExtensions = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		getText = function(self) return Resources.CustomExtensionsScreen.ButtonGetExtensions end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 28, Constants.SCREEN.MARGIN + 70, 80, 16 },
		isVisible = function() return #CustomExtensionsScreen.Pager.Buttons == 0 end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.EXTENSIONS)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return CustomExtensionsScreen.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 66, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 56, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			CustomExtensionsScreen.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 96, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			CustomExtensionsScreen.Pager:nextPage()
		end
	},
	InstallNewExtensions = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.CustomExtensionsScreen.ButtonInstallNew end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 47, 11 },
		onClick = function(self)
			CustomCode.refreshExtensionList()
			CustomExtensionsScreen.buildOutPagedButtons()
			Program.redraw(true)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		CustomExtensionsScreen.refreshButtons()
		Program.changeScreenView(NavigationMenu)
	end),
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

	CustomExtensionsScreen.refreshButtons()
end

function CustomExtensionsScreen.buildOutPagedButtons()
	CustomExtensionsScreen.Pager.Buttons = {}

	for extensionKey, extension in pairs(CustomCode.ExtensionLibrary) do
		local image = Utils.inlineIf(extension.isEnabled, Constants.PixelImages.CHECKMARK, Constants.PixelImages.CROSS)
		local iconColors = Utils.inlineIf(extension.isEnabled, { "Positive text", }, { "Negative text", })

		-- If the button itself is disabled and not active
		local isBtnDisabled = not Options["Enable custom extensions"]
		local textColor = Utils.inlineIf(isBtnDisabled, "Negative text", CustomExtensionsScreen.Colors.text)

		local button = {
			type = Constants.ButtonTypes.ICON_BORDER,
			image = image,
			getText = function(self) return extension.selfObject.name or Constants.BLANKLINE end,
			textColor = textColor,
			iconColors = iconColors,
			boxColors = { CustomExtensionsScreen.Colors.border, CustomExtensionsScreen.Colors.boxFill, },
			extension = extension,
			extensionKey = extensionKey,
			dimensions = { width = 132, height = 16, },
			disabled = isBtnDisabled,
			isVisible = function(self) return CustomExtensionsScreen.Pager.currentPage == self.pageVisible end,
			updateSelf = function(self)
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
					self.textColor = CustomExtensionsScreen.Colors.text
				end
			end,
			onClick = function(self)
				SingleExtensionScreen.setupScreenWithInfo(self.extensionKey, self.extension)
				Program.changeScreenView(SingleExtensionScreen)
			end,
		}
		table.insert(CustomExtensionsScreen.Pager.Buttons, button)
	end

	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local y = Constants.SCREEN.MARGIN + 29
	local colSpacer = 1
	local rowSpacer = 5
	CustomExtensionsScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

function CustomExtensionsScreen.refreshButtons()
	for _, button in pairs(CustomExtensionsScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
	for _, button in pairs(CustomExtensionsScreen.Pager.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

-- Turns all of the paged buttons ON (makeActive = true) or OFF (makeActive = false), calling startup/unload appropriately
-- If they are OFF, they cannot be pressed and have "Negative text" color
function CustomExtensionsScreen.togglePagedButtons(makeActive)
	for _, button in ipairs(CustomExtensionsScreen.Pager.Buttons) do
		button.disabled = not makeActive
	end
	if makeActive then
		CustomCode.startup()
	else
		CustomCode.unload()
	end
	CustomExtensionsScreen.refreshButtons()
end

-- USER INPUT FUNCTIONS
function CustomExtensionsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, CustomExtensionsScreen.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, CustomExtensionsScreen.Pager.Buttons)
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
	local headerText = Utils.toUpperUTF8(Resources.CustomExtensionsScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)
	local textLineY = topBox.y + Constants.SCREEN.LINESPACING + 3 -- make room for first checkbox

	if #CustomExtensionsScreen.Pager.Buttons == 0 then
		local wrappedDesc = Utils.getWordWrapLines(Resources.CustomExtensionsScreen.LabelNoExtensions, 32)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
		for _, line in pairs(wrappedDesc) do
			local centeredOffset = Utils.getCenteredTextX(line, topBox.width)
			Drawing.drawText(topBox.x + centeredOffset, textLineY, line, Theme.COLORS["Intermediate text"], topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING
		end
	end

	-- Draw all buttons
	for _, button in pairs(CustomExtensionsScreen.Buttons) do
		if button == CustomExtensionsScreen.Buttons.GetExtensionsSmall then
			Drawing.drawButton(button, nil)
		else
			Drawing.drawButton(button, topBox.shadow)
		end
	end
	for _, button in pairs(CustomExtensionsScreen.Pager.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

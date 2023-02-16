CustomExtensionsScreen = {
	Labels = {
		header = "Custom Extensions",
		pageFormat = "Pg. %s/%s", -- e.g. Pg. 1/3
		noExtensions = "You currently don't have any custom extensions installed.",
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
	defaultSort = function(a, b) return a.extension.selfObject.name < b.extension.selfObject.name end, -- Order ascending by extension name
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
		local buffer = Utils.inlineIf(self.currentPage > 9, "", " ") .. Utils.inlineIf(self.totalPages > 9, "", " ")
		return buffer .. string.format(CustomExtensionsScreen.Labels.pageFormat, self.currentPage, self.totalPages)
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
				CustomExtensionsScreen.togglePagedButtons(self.toggleState)
			else
				-- First deactivate paged buttons and run unload(), then stop custom code from running
				CustomExtensionsScreen.togglePagedButtons(self.toggleState)
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
		isVisible = function() return #CustomExtensionsScreen.Pager.Buttons == 0 end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.EXTENSIONS)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 55, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return CustomExtensionsScreen.Pager.totalPages > 1 end,
		updateText = function(self)
			self.text = CustomExtensionsScreen.Pager:getPageText()
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 44, Constants.SCREEN.MARGIN + 136, 10, 10, },
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 35, 11 },
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
			Program.changeScreenView(Program.Screens.NAVIGATION)
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
	-- Used to help remove any inactive or missing extension files
	local activeExtensions = {}

	local customFolderPath = FileManager.getCustomFolderPath()
	local customFiles = FileManager.getFilesFromDirectory(customFolderPath)
	for _, filename in pairs(customFiles) do
		local name = FileManager.extractFileNameFromPath(filename) or ""
		local ext = FileManager.extractFileExtensionFromPath(filename) or ""
		ext = "." .. ext

		-- Load any new Lua code files, but only if they don't already exist
		if ext == FileManager.Extensions.LUA_CODE then
			if CustomCode.ExtensionLibrary[name] == nil then
				CustomCode.loadExtension(name)
			end
			activeExtensions[name] = true
		end
	end

	for extensionKey, _ in pairs(CustomCode.ExtensionLibrary) do
		if not activeExtensions[extensionKey] then
			CustomCode.disableExtension(extensionKey)
			CustomCode.ExtensionLibrary[extensionKey] = nil
			Main.RemoveMetaSetting("extensions", extensionKey)
		end
	end

	Main.SaveSettings(true)
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
			text = extension.selfObject.name or Constants.BLANKLINE,
			textColor = textColor,
			iconColors = iconColors,
			extension = extension,
			extensionKey = extensionKey,
			dimensions = { width = 132, height = 16, },
			disabled = isBtnDisabled,
			isVisible = function(self) return CustomExtensionsScreen.Pager.currentPage == self.pageVisible end,
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
					self.textColor = CustomExtensionsScreen.Colors.text
				end
			end,
			onClick = function(self)
				-- TODO: Later want to navigate to single screen to show options: enable/disable, configure, remove, etc.
				if self.extension.isEnabled then
					CustomCode.disableExtension(self.extensionKey)
				else
					CustomCode.enableExtension(self.extensionKey)
				end
				self:updateText()
				Main.SaveSettings(true)
				Program.redraw(true)
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

-- Turns all of the paged buttons ON (makeActive = true) or OFF (makeActive = false), calling startup/unload appropriately
-- If they are OFF, they cannot be pressed and have "Negative text" color
function CustomExtensionsScreen.togglePagedButtons(makeActive)
	for _, button in ipairs(CustomExtensionsScreen.Pager.Buttons) do
		button.disabled = not makeActive
		button:updateText()
	end
	if makeActive then
		CustomCode.startup()
	else
		CustomCode.unload()
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

	if #CustomExtensionsScreen.Pager.Buttons == 0 then
		local wrappedDesc = Utils.getWordWrapLines(CustomExtensionsScreen.Labels.noExtensions, 32)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
		for _, line in pairs(wrappedDesc) do
			local centeredOffset = Utils.getCenteredTextX(line, topBox.width)
			Drawing.drawText(topBox.x + centeredOffset, textLineY, line, Theme.COLORS["Intermediate text"], topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING
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

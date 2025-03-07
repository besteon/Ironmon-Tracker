SingleExtensionScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	column2offsetX = 50,
	extension = nil,
	extensionKey = nil,
}

SingleExtensionScreen.Buttons = {
	EnableOnOff = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self)
			if SingleExtensionScreen.extension.isEnabled then
				return " " .. Resources.SingleExtensionScreen.EnabledOn
			else
				return " " .. Resources.SingleExtensionScreen.EnabledOff
			end
		end,
		toggleState = false,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + SingleExtensionScreen.column2offsetX, Constants.SCREEN.MARGIN + 39, 34, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + SingleExtensionScreen.column2offsetX, Constants.SCREEN.MARGIN + 39, 8, 8 },
		updateSelf = function(self)
			if SingleExtensionScreen.extension == nil then return end
			if SingleExtensionScreen.extension.isEnabled == true then
				self.toggleState = true
				self.textColor = "Positive text"
			else
				self.toggleState = false
				self.textColor = "Negative text"
			end
		end,
		onClick = function(self)
			if SingleExtensionScreen.extension == nil or SingleExtensionScreen.extensionKey == nil then return end

			if SingleExtensionScreen.extension.isEnabled then
				CustomCode.disableExtension(SingleExtensionScreen.extensionKey)
			else
				-- Reload the extension first in case it was updated or changed
				CustomCode.loadExtension(SingleExtensionScreen.extensionKey)
				CustomCode.enableExtension(SingleExtensionScreen.extensionKey)
			end
			self:updateSelf()
			Main.SaveSettings(true)
			Program.redraw(true)
		end,
	},
	CheckForUpdates = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if self.updateStatus == "Available" then
				return Resources.SingleExtensionScreen.ButtonUpdateAvailable
			elseif self.updateStatus == "No Update" then
				return Resources.SingleExtensionScreen.ButtonNoUpdateFound
			elseif self.updateStatus == "Unchecked" then
				return Resources.SingleExtensionScreen.ButtonCheckForUpdates
			else
				return self.updateStatus
			end
		end,
		updateStatus = "Unchecked", -- checked later when clicked
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 120, 76, 11 },
		isVisible = function(self)
			return SingleExtensionScreen.extension ~= nil and SingleExtensionScreen.extension.selfObject.checkForUpdates ~= nil
		end,
		reset = function(self)
			self.updateStatus = "Unchecked"
			self.textColor = SingleExtensionScreen.Colors.text
		end,
		onClick = function(self)
			local extUpdateFunc = SingleExtensionScreen.extension.selfObject.checkForUpdates
			if type(extUpdateFunc) ~= "function" then
				return
			end
			local isUpdateAvailable, updateUrl = extUpdateFunc()
			if isUpdateAvailable then
				SingleExtensionScreen.updateConfirmationPrompt(self, updateUrl)
			else
				self.updateStatus = "No Update"
				self.textColor = SingleExtensionScreen.Colors.text
			end
			Program.redraw(true)
		end,
	},
	ViewOnline = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.SingleExtensionScreen.ButtonViewOnline end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 51, 11 },
		isVisible = function(self)
			return SingleExtensionScreen.extension ~= nil and SingleExtensionScreen.extension.selfObject.url ~= nil
		end,
		onClick = function(self)
			if SingleExtensionScreen.extension.selfObject.url ~= nil then
				Utils.openBrowserWindow(SingleExtensionScreen.extension.selfObject.url)
			end
		end,
	},
	Options = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.SingleExtensionScreen.ButtonOptions end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 59, Constants.SCREEN.MARGIN + 135, 35, 11 },
		isVisible = function(self)
			return SingleExtensionScreen.extension ~= nil and type(SingleExtensionScreen.extension.selfObject.configureOptions) == "function"
		end,
		onClick = function(self)
			local configFunc = SingleExtensionScreen.extension.selfObject.configureOptions
			if type(configFunc) == "function" then
				configFunc()
			end
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		SingleExtensionScreen.Buttons.CheckForUpdates:reset()
		CustomExtensionsScreen.refreshButtons()
		Program.changeScreenView(CustomExtensionsScreen)
	end),
}

function SingleExtensionScreen.initialize()
	for _, button in pairs(SingleExtensionScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = SingleExtensionScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SingleExtensionScreen.Colors.border, SingleExtensionScreen.Colors.boxFill }
		end
	end
end

function SingleExtensionScreen.refreshButtons()
	for _, button in pairs(SingleExtensionScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function SingleExtensionScreen.setupScreenWithInfo(extensionKey, extension)
	SingleExtensionScreen.extensionKey = extensionKey
	SingleExtensionScreen.extension = extension
	SingleExtensionScreen.refreshButtons()
end

function SingleExtensionScreen.updateConfirmationPrompt(button, releaseUrl)
	button = button or {}

	local form = ExternalUI.BizForms.createForm("Update Extension?", 330, 150)
	local X = 15
	local lineY = 10
	form.Controls.labelDescription = form:createLabel(string.format("An update is available, would you like to update now?"), X, lineY)
	lineY = lineY + 25
	local extension = SingleExtensionScreen.extension or SingleExtensionScreen.getEmptyExtension()
	local extName = extension.selfObject.name or "???"
	form.Controls.labelProfileName = form:createLabel(string.format("Extension:  %s", extName), X, lineY)
	lineY = lineY + 35

	-- YES / RELEASE NOTES / CANCEL
	form.Controls.buttonYes = form:createButton(Resources.AllScreens.Yes, X + 5, lineY, function()
		form:destroy()
		button.updateStatus = "Updating..."
		button.textColor = "Intermediate text"
		Program.redraw(true)
		-- Delay the update a few frames to redraw screen to show update in progress
		Program.addFrameCounter("SingleExtensionScreen:UpdateExtension", 4, function()
			local success = CustomCode.updateExtension(SingleExtensionScreen.extensionKey)
			if success then
				button.updateStatus = "Updated!"
				button.textColor = "Positive text"
			else
				button.updateStatus = "Manual Download"
				button.textColor = "Intermediate text"
			end
			Program.redraw(true)
		end, 1)
	end, 60, 25)
	if releaseUrl ~= nil then
		form.Controls.buttonViewReleaseNotes = form:createButton("View Release Notes", X + 75, lineY, function()
			Utils.openBrowserWindow(releaseUrl)
		end, 125, 25)
	end
	form.Controls.buttonCancel = form:createButton(Resources.AllScreens.Cancel, X + 210, lineY, function()
		form:destroy()
	end, 60, 25)
end

function SingleExtensionScreen.getEmptyExtension()
	return {
		isEnabled = false,
		selfObject = {
			name = "Unknown Extension",
			author = "N/A",
			version = "N/A",
			description = "(Description not available)",
		},
	}
end

-- USER INPUT FUNCTIONS
function SingleExtensionScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SingleExtensionScreen.Buttons)
end

-- DRAWING FUNCTIONS
function SingleExtensionScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SingleExtensionScreen.Colors.boxFill])

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
		text = Theme.COLORS[SingleExtensionScreen.Colors.text],
		border = Theme.COLORS[SingleExtensionScreen.Colors.border],
		fill = Theme.COLORS[SingleExtensionScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SingleExtensionScreen.Colors.boxFill]),
	}
	local textLineY = topBox.y + 2

	local extension = SingleExtensionScreen.extension or SingleExtensionScreen.getEmptyExtension()

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Extension Information
	-- Name
	Drawing.drawText(topBox.x + 2, textLineY, extension.selfObject.name, Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1
	-- Author
	Drawing.drawText(topBox.x + 2, textLineY, Resources.SingleExtensionScreen.LabelAuthorBy .. ":", topBox.text, topBox.shadow)
	Drawing.drawText(topBox.x + SingleExtensionScreen.column2offsetX, textLineY, extension.selfObject.author, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1
	-- Version
	Drawing.drawText(topBox.x + 2, textLineY, Resources.SingleExtensionScreen.LabelVersion .. ":", topBox.text, topBox.shadow)
	Drawing.drawText(topBox.x + SingleExtensionScreen.column2offsetX, textLineY, extension.selfObject.version, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1
	-- Enabled
	Drawing.drawText(topBox.x + 2, textLineY, Resources.SingleExtensionScreen.LabelEnabled .. ":", topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Description
	textLineY = textLineY + 2
	local wrappedDesc = Utils.getWordWrapLines(extension.selfObject.description, 32)
	-- There is only room for 6 or 7 total lines to be shown for the short description
	local linesShown = 0
	local totalLinesCanShow = Utils.inlineIf(SingleExtensionScreen.Buttons.CheckForUpdates:isVisible(), 6, 7)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 2, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING

		linesShown = linesShown + 1
		if linesShown >= totalLinesCanShow then
			break
		end
	end

	-- Draw all buttons
	for _, button in pairs(SingleExtensionScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

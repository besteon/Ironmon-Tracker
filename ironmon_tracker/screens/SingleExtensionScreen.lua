SingleExtensionScreen = {
	Labels = {
		authorBy = "By:",
		version = "Version:",
		enabled = "Enabled:",
		enabledOn = "ON",
		enabledOff = "OFF",
		viewOnline = "View Online",
		options = "Options",
	},
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	column2offsetX = 50,
	extension = nil,
	extensionKey = nil,
}

-- TODO: Might add a "Reload Extension" and a "Remove" option later, uncertain yet
SingleExtensionScreen.Buttons = {
	EnableOnOff = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = "", -- Set later in initialize()
		toggleState = false,
		toggleColor = "Positive text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + SingleExtensionScreen.column2offsetX, Constants.SCREEN.MARGIN + 39, 34, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + SingleExtensionScreen.column2offsetX, Constants.SCREEN.MARGIN + 39, 8, 8 },
		updateSelf = function(self)
			if SingleExtensionScreen.extension == nil then return end

			self.toggleState = (SingleExtensionScreen.extension.isEnabled == true)

			-- Check if the extension itself is enabled, and update the button accordingly
			if SingleExtensionScreen.extension.isEnabled then
				self.text = " " .. SingleExtensionScreen.Labels.enabledOn
				self.textColor = "Positive text"
			else
				self.text = " " .. SingleExtensionScreen.Labels.enabledOff
				self.textColor = "Negative text"
			end
		end,
		onClick = function(self)
			if SingleExtensionScreen.extension == nil or SingleExtensionScreen.extensionKey == nil then return end

			if SingleExtensionScreen.extension.isEnabled then
				CustomCode.disableExtension(SingleExtensionScreen.extensionKey)
			else
				CustomCode.enableExtension(SingleExtensionScreen.extensionKey)
			end
			self:updateSelf()
			Main.SaveSettings(true)
			Program.redraw(true)
		end,
	},
	ViewOnline = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = SingleExtensionScreen.Labels.viewOnline,
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
		text = SingleExtensionScreen.Labels.options,
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
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			CustomExtensionsScreen.refreshButtons()
			Program.changeScreenView(Program.Screens.EXTENSIONS)
		end,
	},
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
	SingleExtensionScreen.Buttons.EnableOnOff:updateSelf()
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
	Drawing.drawText(topBox.x + 2, textLineY, SingleExtensionScreen.Labels.authorBy, topBox.text, topBox.shadow)
	Drawing.drawText(topBox.x + SingleExtensionScreen.column2offsetX, textLineY, extension.selfObject.author, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1
	-- Version
	Drawing.drawText(topBox.x + 2, textLineY, SingleExtensionScreen.Labels.version, topBox.text, topBox.shadow)
	Drawing.drawText(topBox.x + SingleExtensionScreen.column2offsetX, textLineY, extension.selfObject.version, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1
	-- Enabled
	Drawing.drawText(topBox.x + 2, textLineY, SingleExtensionScreen.Labels.enabled, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Description
	textLineY = textLineY + 8
	local wrappedDesc = Utils.getWordWrapLines(extension.selfObject.description, 32)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 2, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
	end

	-- Draw all buttons
	for _, button in pairs(SingleExtensionScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

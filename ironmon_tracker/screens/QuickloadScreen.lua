QuickloadScreen = {
	headerText = "Quickload Setup",
	textColor = "Default text",
	borderColor = "Upper box border",
	boxFillColor = "Upper box background",
}

QuickloadScreen.OptionKeys = {
	"Use premade ROMs",
	"Generate ROM each time",
}

QuickloadScreen.SetButtonSetup = {
	["ROMs Folder"] = {
		offsetY = Constants.SCREEN.MARGIN + 47,
	},
	["Randomizer JAR"] = {
		offsetY = Constants.SCREEN.MARGIN + 86,
	},
	["Source ROM"] = {
		offsetY = Constants.SCREEN.MARGIN + 100,
	},
	["Custom Settings"] = {
		offsetY = Constants.SCREEN.MARGIN + 114,
	},
}

QuickloadScreen.Buttons = {
	ButtonCombo = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "Button Combo:",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 16, 130, 11 },
		updateText = function(self)
			self.text = "Button Combo:  " .. Options.CONTROLS["Load next seed"]
		end,
		onClick = function() SetupScreen.openEditControlsWindow() end
	},
	PremadeRoms = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = QuickloadScreen.OptionKeys[1],
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 35, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 35, 8, 8 },
		toggleState = false,
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting(self.text, self.toggleState)

			-- Only one of these options can be active at any given moment
			if self.toggleState then
				QuickloadScreen.Buttons.GenerateRom.toggleState = false
				Options.updateSetting(QuickloadScreen.Buttons.GenerateRom.text, false)
			end
			Options.forceSave()
		end
	},
	GenerateRom = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = QuickloadScreen.OptionKeys[2],
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 74, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 74, 8, 8 },
		toggleState = false,
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting(self.text, self.toggleState)

			-- Only one of these options can be active at any given moment
			if self.toggleState then
				QuickloadScreen.Buttons.PremadeRoms.toggleState = false
				Options.updateSetting(QuickloadScreen.Buttons.PremadeRoms.text, false)
			end
			Options.forceSave()
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the Tracker Setup screen
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.SETUP)
		end
	},
}

function QuickloadScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 106

	for setKey, setValue in pairs(QuickloadScreen.SetButtonSetup) do
		QuickloadScreen.Buttons[setKey] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = Utils.inlineIf(Options.FILES[setKey] ~= "", "Clear", " SET"),
			labelText = setKey,
			isSet = (Options.FILES[setKey] ~= ""),
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 106, setValue.offsetY, 24, 11 },
			onClick = function(self)
				if self.isSet then
					QuickloadScreen.clearButton(self)
				else
					self:clickFunction()
				end
			end,
			clickFunction = nil,
		}
	end
	QuickloadScreen.Buttons["ROMs Folder"].clickFunction = QuickloadScreen.handleSetRomFolder
	QuickloadScreen.Buttons["Randomizer JAR"].clickFunction = QuickloadScreen.handleSetRandomizerJar
	QuickloadScreen.Buttons["Source ROM"].clickFunction = QuickloadScreen.handleSetSourceRom
	QuickloadScreen.Buttons["Custom Settings"].clickFunction = QuickloadScreen.handleSetCustomSettings

	for _, button in pairs(QuickloadScreen.Buttons) do
		button.textColor = QuickloadScreen.textColor
		button.boxColors = { QuickloadScreen.borderColor, QuickloadScreen.boxFillColor }
	end

	QuickloadScreen.Buttons.ButtonCombo:updateText()
	QuickloadScreen.Buttons.PremadeRoms.toggleState = Options[QuickloadScreen.OptionKeys[1]]
	QuickloadScreen.Buttons.GenerateRom.toggleState = Options[QuickloadScreen.OptionKeys[2]]

	-- If both premade seeds and generate ROM each time are enabled, turn one off
	if Options[QuickloadScreen.OptionKeys[1]] and Options[QuickloadScreen.OptionKeys[2]] then
		QuickloadScreen.Buttons.GenerateRom:onClick()
	end
end

function QuickloadScreen.handleSetRomFolder(button)
	local path = Options.FILES[button.labelText]
	local filterOptions = "ROM File (*.GBA)|*.GBA|All files (*.*)|*.*"

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if file ~= "" then
		-- Since the user had to pick a file, strip out the file name to just get the folder.
		file = file:sub(0, file:match("^.*()\\") - 1)

		if file == nil then
			Options.FILES[button.labelText] = ""
			button.isSet = false
			button.text = " SET"
		else
			Options.FILES[button.labelText] = file
			button.isSet = true
			button.text = "Clear"
		end

		Options.forceSave()
	end
end

function QuickloadScreen.handleSetRandomizerJar(button)
	local path = Options.FILES[button.labelText]
	local filterOptions = "JAR File (*.JAR)|*.JAR|All files (*.*)|*.*"

	local file = forms.openfile("SELECT JAR", path, filterOptions)
	if file ~= "" then
		-- TODO: Maybe have a check to verify a JAR file was actually selected?
		Options.FILES[button.labelText] = file
		button.isSet = true
		button.text = "Clear"
		Options.forceSave()
	end
end

function QuickloadScreen.handleSetSourceRom(button)
	local path = Options.FILES[button.labelText]
	local filterOptions = "GBA File (*.GBA)|*.GBA|All files (*.*)|*.*"

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if file ~= "" then
		-- TODO: Maybe have a check to verify a GBA file was actually selected?
		Options.FILES[button.labelText] = file
		button.isSet = true
		button.text = "Clear"

		-- Save these changes to the file to avoid case where user resets before clicking the Back button
		Options.forceSave()
	end
end

function QuickloadScreen.handleSetCustomSettings(button)
	local path = Options.FILES[button.labelText]
	local filterOptions = "RNQS File (*.RNQS)|*.RNQS|All files (*.*)|*.*"

	local file = forms.openfile("SELECT RNQS", path, filterOptions)
	if file ~= "" then
		-- TODO: Maybe have a check to verify a RNQS file was actually selected?
		Options.FILES[button.labelText] = file
		button.isSet = true
		button.text = "Clear"

		-- Save these changes to the file to avoid case where user resets before clicking the Back button
		Options.forceSave()
	end
end

function QuickloadScreen.clearButton(button)
	button.isSet = false
	button.text = " SET"
	Options.FILES[button.labelText] = ""
	Options.forceSave()
end

-- DRAWING FUNCTIONS
function QuickloadScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[QuickloadScreen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[QuickloadScreen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	-- Draw header text
	Drawing.drawText(topboxX + 33, topboxY + 2, QuickloadScreen.headerText:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- Draw all buttons
	for _, button in pairs(QuickloadScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	local checkmarkOffset = -20
	for setKey, _ in pairs(QuickloadScreen.SetButtonSetup) do
		local button = QuickloadScreen.Buttons[setKey]
		Drawing.drawText(topboxX + 7, button.box[2], button.labelText, Theme.COLORS[button.textColor], shadowcolor)
		if button.isSet then
			Drawing.drawImageAsPixels(Constants.PixelImages.CHECKMARK, button.box[1] + checkmarkOffset, button.box[2], Theme.COLORS["Positive text"], shadowcolor)
		else
			Drawing.drawImageAsPixels(Constants.PixelImages.CROSS, button.box[1] + checkmarkOffset, button.box[2], Theme.COLORS["Negative text"], shadowcolor)
		end
	end
end
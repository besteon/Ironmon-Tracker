QuickloadScreen = {
	headerText = "Quickload Setup",
	textColor = "Default text",
	borderColor = "Upper box border",
	boxFillColor = "Upper box background",
}

QuickloadScreen.OptionKeys = {
	"Use premade ROMs", -- Keep as first item in this list [1]
	"Generate ROM each time", -- Keep as second item in this list [2]
}

QuickloadScreen.SetButtonSetup = {
	["ROMs Folder"] = {
		offsetY = Constants.SCREEN.MARGIN + 54,
	},
	["Randomizer JAR"] = {
		offsetY = Constants.SCREEN.MARGIN + 88,
	},
	["Source ROM"] = {
		offsetY = Constants.SCREEN.MARGIN + 102,
	},
	["Settings File"] = {
		offsetY = Constants.SCREEN.MARGIN + 116,
	},
}

QuickloadScreen.Buttons = {
	ButtonCombo = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "Buttons:",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 12, 130, 11 },
		updateText = function(self)
			local comboFormatted = Options.CONTROLS["Load next seed"]:gsub(" ", ""):gsub(",", " + ")
			self.text = "Buttons:  " .. comboFormatted
		end,
		onClick = function() SetupScreen.openEditControlsWindow() end
	},
	PremadeRoms = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = QuickloadScreen.OptionKeys[1],
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 44, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 44, 8, 8 },
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
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 77, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 77, 8, 8 },
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
	for setKey, setValue in pairs(QuickloadScreen.SetButtonSetup) do
		local isSetCorrectly = (setKey == "ROMs Folder" and Options.FILES[setKey] ~= "") or Main.FileExists(Options.FILES[setKey])
		QuickloadScreen.Buttons[setKey] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = Utils.inlineIf(isSetCorrectly, "Clear", " SET"),
			labelText = setKey,
			isSet = isSetCorrectly,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, setValue.offsetY, 24, 11 },
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
	QuickloadScreen.Buttons["Settings File"].clickFunction = QuickloadScreen.handleSetCustomSettings

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
	local filterOptions = "ROM File (*.GBA)|*.gba|All files (*.*)|*.*"

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if file ~= "" then
		-- Since the user had to pick a file, strip out the file name to just get the folder path
		local slashpattern = Utils.inlineIf(Main.OS == "Windows", "^.*()\\", "^.*()/")
		file = file:sub(0, file:match(slashpattern) - 1)

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
	local filterOptions = "JAR File (*.JAR)|*.jar|All files (*.*)|*.*"

	local file = forms.openfile("SELECT JAR", path, filterOptions)
	if file ~= "" then
		local extension = Utils.extractFileExtensionFromPath(file)
		if extension == "jar" then
			Options.FILES[button.labelText] = file
			button.isSet = true
			button.text = "Clear"
			Options.forceSave()
		else
			Main.DisplayError("The file selected is not the Randomizer JAR file.\n\nPlease select the JAR file in the Randomizer ZX folder.")
		end
	end
end

function QuickloadScreen.handleSetSourceRom(button)
	local path = Options.FILES[button.labelText]
	local filterOptions = "GBA File (*.GBA)|*.gba|All files (*.*)|*.*"

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if file ~= "" then
		local extension = Utils.extractFileExtensionFromPath(file)
		if extension == "gba" then
			Options.FILES[button.labelText] = file
			button.isSet = true
			button.text = "Clear"
			Options.forceSave()
		else
			Main.DisplayError("The file selected is not a GBA ROM file.\n\nPlease select a GBA file: has the file extension \".gba\"")
		end
	end
end

function QuickloadScreen.handleSetCustomSettings(button)
	local path = Options.FILES[button.labelText]
	local filterOptions = "RNQS File (*.RNQS)|*.rnqs|All files (*.*)|*.*"

	-- If the custom settings file hasn't ever been set, show the folder containing preloaded setting files
	if path == "" or not Main.FileExists(path) then
		path = Utils.getWorkingDirectory() .. Main.DataFolder .. "/RandomizerSettings/"
		path = path:gsub("/", "\\")
		if not Main.FileExists(path .. "FRLG Survival.rnqs") then -- TODO: Probably find a better way to test a folder exists
			path = path:gsub("\\", "/")
		end
	end

	local file = forms.openfile("SELECT RNQS", path, filterOptions)
	if file ~= "" then
		local extension = Utils.extractFileExtensionFromPath(file)
		if extension == "rnqs" then
			Options.FILES[button.labelText] = file
			button.isSet = true
			button.text = "Clear"
			Options.forceSave()
		else
			Main.DisplayError("The file selected is not a Randomizer Settings file.\n\nPlease select an RNQS file: has the file extension \".rnqs\"")
		end
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
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 33, Constants.SCREEN.MARGIN - 2, QuickloadScreen.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	-- Draw text to explain a choice should be made
	Drawing.drawText(topboxX + 2, topboxY + 17, "Choose a quickload option:", Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	gui.drawRectangle(topboxX + 4 + 1, topboxY + 30 + 1, topboxWidth - 8, 29, shadowcolor)
	gui.drawRectangle(topboxX + 4, topboxY + 30, topboxWidth - 8, 29, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])
	gui.drawRectangle(topboxX + 4 + 1, topboxY + 63 + 1, topboxWidth - 8, 58, shadowcolor)
	gui.drawRectangle(topboxX + 4, topboxY + 63, topboxWidth - 8, 58, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	-- Draw what settings are currently loaded
	if QuickloadScreen.Buttons.PremadeRoms.toggleState then
		local foldername = ""
		if QuickloadScreen.Buttons["ROMs Folder"].isSet then
			foldername = Utils.extractFolderNameFromPath(Options.FILES["ROMs Folder"])
		end
		Drawing.drawText(topboxX + 2, topboxY + 125, "Folder: " .. foldername, Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	elseif QuickloadScreen.Buttons.GenerateRom.toggleState then
		local filename = ""
		if QuickloadScreen.Buttons["Settings File"].isSet then
			filename = Utils.extractFileNameFromPath(Options.FILES["Settings File"])
		end
		if filename:len() < 18 then
			filename = "Settings: " .. filename
		end
		Drawing.drawText(topboxX + 2, topboxY + 125, filename, Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	end

	-- Draw all buttons
	for _, button in pairs(QuickloadScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	local imageOffset = -20
	for setKey, _ in pairs(QuickloadScreen.SetButtonSetup) do
		local button = QuickloadScreen.Buttons[setKey]
		Drawing.drawText(topboxX + 6, button.box[2], button.labelText, Theme.COLORS[button.textColor], shadowcolor)

		local image
		local imageColor
		if button.isSet then
			image = Constants.PixelImages.CHECKMARK
			imageColor = Theme.COLORS["Positive text"]
		else
			image = Constants.PixelImages.CROSS
			imageColor = Theme.COLORS["Negative text"]
		end
		Drawing.drawImageAsPixels(image, button.box[1] + imageOffset, button.box[2], { imageColor }, shadowcolor)
	end
end
QuickloadScreen = {
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

QuickloadScreen.SetButtonSetup = {
	["ROMs Folder"] = {
		resourceKey = "OptionRomsFolder",
		offsetY = Constants.SCREEN.MARGIN + 54,
	},
	["Randomizer JAR"] = {
		resourceKey = "OptionRandomizerJar",
		offsetY = Constants.SCREEN.MARGIN + 88,
	},
	["Source ROM"] = {
		resourceKey = "OptionSourceRom",
		offsetY = Constants.SCREEN.MARGIN + 102,
	},
	["Settings File"] = {
		resourceKey = "OptionSettingsFile",
		offsetY = Constants.SCREEN.MARGIN + 116,
	},
}

QuickloadScreen.Buttons = {
	ButtonCombo = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local comboFormatted = Options.CONTROLS["Load next seed"]:gsub(" ", ""):gsub(",", " + ")
			return string.format("%s: %s", Resources.QuickloadScreen.ButtonCombo, comboFormatted)
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 12, 130, 11 },
		onClick = function() SetupScreen.openEditControlsWindow() end
	},
	PremadeRoms = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Use premade ROMs",
		getText = function(self) return Resources.QuickloadScreen.OptionPremadeRoms end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 44, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 44, 8, 8 },
		toggleState = false,
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting(self.optionKey, self.toggleState)

			-- Only one of these options can be active at any given moment
			if self.toggleState then
				QuickloadScreen.Buttons.GenerateRom.toggleState = false
				Options.updateSetting(QuickloadScreen.Buttons.GenerateRom.optionKey, false)
			end

			QuickloadScreen.verifyOptions()
			QuickloadScreen.refreshButtons()
			NavigationMenu.refreshButtons()
			Options.forceSave()
		end
	},
	GenerateRom = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Generate ROM each time",
		getText = function(self) return Resources.QuickloadScreen.OptionGenerateRom end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 77, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, Constants.SCREEN.MARGIN + 77, 8, 8 },
		toggleState = false,
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting(self.optionKey, self.toggleState)

			-- Only one of these options can be active at any given moment
			if self.toggleState then
				QuickloadScreen.Buttons.PremadeRoms.toggleState = false
				Options.updateSetting(QuickloadScreen.Buttons.PremadeRoms.optionKey, false)
			end

			QuickloadScreen.verifyOptions()
			QuickloadScreen.refreshButtons()
			NavigationMenu.refreshButtons()
			Options.forceSave()
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Back end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the Tracker Setup screen
			Main.SaveSettings()
			Program.changeScreenView(NavigationMenu)
		end
	},
}

function QuickloadScreen.initialize()
	QuickloadScreen.createButtons()

	local romfolderBtn = QuickloadScreen.Buttons["ROMs Folder"]
	local jarBtn = QuickloadScreen.Buttons["Randomizer JAR"]
	local gbaBtn = QuickloadScreen.Buttons["Source ROM"]
	local rnqsBtn = QuickloadScreen.Buttons["Settings File"]

	romfolderBtn.clickFunction = QuickloadScreen.handleSetRomFolder
	jarBtn.clickFunction = QuickloadScreen.handleSetRandomizerJar
	gbaBtn.clickFunction = QuickloadScreen.handleSetSourceRom
	rnqsBtn.clickFunction = QuickloadScreen.handleSetCustomSettings

	for _, button in pairs(QuickloadScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = QuickloadScreen.textColor
		end
		if button.boxColors == nil then
			button.boxColors = { QuickloadScreen.borderColor, QuickloadScreen.boxFillColor }
		end
	end

	QuickloadScreen.verifyOptions()

	local optionPremade = QuickloadScreen.Buttons.PremadeRoms.optionKey
	local optionGenerate = QuickloadScreen.Buttons.GenerateRom.optionKey

	-- If neither premade seeds nor generate ROM each time are enabled, try turning one on if files are setup already
	if not Options[optionPremade] and not Options[optionGenerate] then
		if jarBtn.isSet and gbaBtn.isSet and rnqsBtn.isSet then
			Options[optionGenerate] = true
			Options.settingsUpdated = true
		elseif romfolderBtn.isSet then
			Options[optionPremade] = true
			Options.settingsUpdated = true
		end
	elseif Options[optionPremade] and Options[optionGenerate] then
		-- If both premade seeds and generate ROM each time are enabled, turn one off
		Options[optionGenerate] = false
		Options.settingsUpdated = true
	end
	Main.SaveSettings() -- save settings if any of them changed

	QuickloadScreen.Buttons.PremadeRoms.toggleState = Options[optionPremade]
	QuickloadScreen.Buttons.GenerateRom.toggleState = Options[optionGenerate]
	NavigationMenu.refreshButtons()
end

function QuickloadScreen.createButtons()
	for optionKey, optionObj in pairs(QuickloadScreen.SetButtonSetup) do
		QuickloadScreen.Buttons[optionKey] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self)
				if self.isSet then
					return Resources.QuickloadScreen.ButtonClear
				else
					return " " .. Resources.QuickloadScreen.ButtonSet
				end
			end,
			optionKey = optionKey,
			isSet = false,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, optionObj.offsetY, 24, 11 },
			draw = function(self, shadowcolor)
				local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
				local labelText = Resources.QuickloadScreen[optionObj.resourceKey]
				Drawing.drawText(topboxX + 6, self.box[2], labelText, Theme.COLORS[self.textColor], shadowcolor)

				local image, imageColor
				if self.isSet then
					image = Constants.PixelImages.CHECKMARK
					imageColor = Theme.COLORS["Positive text"]
				else
					image = Constants.PixelImages.CROSS
					imageColor = Theme.COLORS["Negative text"]
				end
				Drawing.drawImageAsPixels(image, self.box[1] - 20, self.box[2], { imageColor }, shadowcolor)
			end,
			onClick = function(self)
				if self.isSet then
					Options.FILES[self.optionKey] = ""
					self.isSet = false
					Options.forceSave()
				else
					if type(self.clickFunction) == "function" then
						self:clickFunction()
					end
				end
			end,
			clickFunction = nil,
		}
	end
end

function QuickloadScreen.refreshButtons()
	for _, button in pairs(QuickloadScreen.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function QuickloadScreen.verifyOptions()
	local romfolderBtn = QuickloadScreen.Buttons["ROMs Folder"]
	local jarBtn = QuickloadScreen.Buttons["Randomizer JAR"]
	local gbaBtn = QuickloadScreen.Buttons["Source ROM"]
	local rnqsBtn = QuickloadScreen.Buttons["Settings File"]

	-- Determine if the files are setup properly based on Settings.ini filepaths or files found in [quickload] folder
	local quickloadFiles = Main.tempQuickloadFiles or Main.GetQuickloadFiles()
	romfolderBtn.isSet = (#quickloadFiles.romList > 1) -- ROMs correct if two or more roms found in 'quickloadPath' folder
	jarBtn.isSet = (#quickloadFiles.jarList == 1) -- JAR correct if exactly one file
	gbaBtn.isSet = (#quickloadFiles.romList == 1) -- GBA correct if exactly one file
	rnqsBtn.isSet = (#quickloadFiles.settingsList == 1) -- RNQS correct if exactly one file
end

function QuickloadScreen.handleSetRomFolder(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "ROM File (*.GBA)|*.gba|All files (*.*)|*.*"

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if file ~= "" then
		-- Since the user had to pick a file, strip out the file name to just get the folder path
		local pattern = "^.*()" .. FileManager.slash
		file = file:sub(0, (file:match(pattern) or 1) - 1)

		if file == nil or file == "" then
			Options.FILES[button.optionKey] = ""
			button.isSet = false
		else
			Options.FILES[button.optionKey] = file
			button.isSet = true
		end

		Options.forceSave()
	end

	Utils.tempEnableBizhawkSound()
end

function QuickloadScreen.handleSetRandomizerJar(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "JAR File (*.JAR)|*.jar|All files (*.*)|*.*"

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT JAR", path, filterOptions)
	if file ~= "" then
		local extension = FileManager.extractFileExtensionFromPath(file)
		if extension == "jar" then
			Options.FILES[button.optionKey] = file
			button.isSet = true
			Options.forceSave()
		else
			Main.DisplayError("The file selected is not the Randomizer JAR file.\n\nPlease select the JAR file in the Randomizer ZX folder.")
		end
	end

	Utils.tempEnableBizhawkSound()
end

function QuickloadScreen.handleSetSourceRom(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "GBA File (*.GBA)|*.gba|All files (*.*)|*.*"

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if file ~= "" then
		local extension = FileManager.extractFileExtensionFromPath(file)
		if extension == "gba" then
			Options.FILES[button.optionKey] = file
			button.isSet = true
			Options.forceSave()
		else
			Main.DisplayError("The file selected is not a GBA ROM file.\n\nPlease select a GBA file: has the file extension \".gba\"")
		end
	end

	Utils.tempEnableBizhawkSound()
end

function QuickloadScreen.handleSetCustomSettings(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "RNQS File (*.RNQS)|*.rnqs|All files (*.*)|*.*"

	-- If the custom settings file hasn't ever been set, show the folder containing preloaded setting files
	if path == "" or not FileManager.fileExists(path) then
		path = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.RandomizerSettings .. FileManager.slash)
		-- if not FileManager.fileExists(path .. "FRLG Survival.rnqs") then -- TODO: Probably find a better way to test a folder exists
		-- end
	end

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT RNQS", path, filterOptions)
	if file ~= "" then
		local extension = FileManager.extractFileExtensionFromPath(file)
		if extension == "rnqs" then
			Options.FILES[button.optionKey] = file
			button.isSet = true
			Options.forceSave()
		else
			Main.DisplayError("The file selected is not a Randomizer Settings file.\n\nPlease select an RNQS file: has the file extension \".rnqs\"")
		end
	end

	Utils.tempEnableBizhawkSound()
end

-- USER INPUT FUNCTIONS
function QuickloadScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, QuickloadScreen.Buttons)
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
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, Resources.QuickloadScreen.Title:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	-- Draw text to explain a choice should be made
	local chooseText = string.format("%s:", Resources.QuickloadScreen.ChoiceHeader)
	Drawing.drawText(topboxX + 2, topboxY + 17, chooseText, Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	gui.drawRectangle(topboxX + 4 + 1, topboxY + 30 + 1, topboxWidth - 8, 29, shadowcolor)
	gui.drawRectangle(topboxX + 4, topboxY + 30, topboxWidth - 8, 29, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])
	gui.drawRectangle(topboxX + 4 + 1, topboxY + 63 + 1, topboxWidth - 8, 58, shadowcolor)
	gui.drawRectangle(topboxX + 4, topboxY + 63, topboxWidth - 8, 58, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	-- Draw near the bottom of the screen showing what settings are currently loaded
	local labelInfo
	if QuickloadScreen.Buttons.PremadeRoms.toggleState then
		if QuickloadScreen.Buttons["ROMs Folder"].isSet then
			local foldername = FileManager.extractFolderNameFromPath(Options.FILES["ROMs Folder"])
			if foldername ~= "" then
				if foldername:len() < 18 then
					labelInfo = string.format("%s: %s", Resources.QuickloadScreen.LabelFolder, foldername)
				else
					labelInfo = foldername
				end
			end
		end
	elseif QuickloadScreen.Buttons.GenerateRom.toggleState then
		if QuickloadScreen.Buttons["Settings File"].isSet then
			local filename = FileManager.extractFileNameFromPath(Options.FILES["Settings File"])
			if filename ~= "" then
				if filename:len() < 18 then
					labelInfo = string.format("%s: %s", Resources.QuickloadScreen.LabelSettings, filename)
				else
					labelInfo = filename
				end
			end
		end
	end
	if labelInfo ~= nil then
		Drawing.drawText(topboxX + 2, topboxY + 125, labelInfo, Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	end

	-- Draw all buttons
	for _, button in pairs(QuickloadScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
QuickloadScreen = {
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

QuickloadScreen.SetButtonSetup = {
	["ROMs Folder"] = {
		resourceKey = "OptionRomsFolder",
		offsetY = Constants.SCREEN.MARGIN + 55,
		statusIconVisible = function(self) return Options["Use premade ROMs"] end,
	},
	["Randomizer JAR"] = {
		resourceKey = "OptionRandomizerJar",
		offsetY = Constants.SCREEN.MARGIN + 87,
		statusIconVisible = function(self) return Options["Generate ROM each time"] end,
	},
	["Source ROM"] = {
		resourceKey = "OptionSourceRom",
		offsetY = Constants.SCREEN.MARGIN + 101,
		statusIconVisible = function(self) return Options["Generate ROM each time"] end,
	},
	["Settings File"] = {
		resourceKey = "OptionSettingsFile",
		offsetY = Constants.SCREEN.MARGIN + 115,
		statusIconVisible = function(self) return Options["Generate ROM each time"] end,
	},
}

QuickloadScreen.Buttons = {
	ButtonCombo = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return Resources.QuickloadScreen.ButtonCombo .. ":" end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 12, 130, 11 },
		draw = function(self, shadowcolor)
			local offsetX = Utils.calcWordPixelLength(self:getText())
			local comboRaw = Options.CONTROLS["Load next seed"] or Constants.BLANKLINE
			local comboFormatted = comboRaw:gsub(" ", ""):gsub(",", " + ")
			Drawing.drawText(self.box[1] + offsetX + 5, self.box[2], comboFormatted, Theme.COLORS["Intermediate text"], shadowcolor)
		end,
		onClick = function() SetupScreen.openEditControlsWindow() end
	},
	PremadeRoms = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Use premade ROMs",
		getText = function(self) return Resources.QuickloadScreen.OptionPremadeRoms end,
		clickableArea = { Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 44, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 44, 8, 8 },
		toggleState = false,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			-- Only one can be enabled at a time
			Options["Generate ROM each time"] = false
			self.toggleState = Options.toggleSetting(self.optionKey)

			-- If turned on initially, automatically locate the loaded rom path
			if self.toggleState and Main.IsOnBizhawk() and (Options.FILES["ROMs Folder"] or "") == "" then
				local luaconsole = client.gettool("luaconsole")
				local luaImp = luaconsole and luaconsole.get_LuaImp()
				local currentRomPath = luaImp and luaImp.PathEntries.LastRomPath or ""
				if currentRomPath ~= "" then
					Options.FILES["ROMs Folder"] = currentRomPath
					Main.SaveSettings(true)
				end
			end

			-- After changing the setup, read-in any existing attempts counter for the new quickload choice
			Main.ReadAttemptsCount()
			QuickloadScreen.verifyOptions()
			QuickloadScreen.refreshButtons()
			NavigationMenu.refreshButtons()
			Program.redraw(true)
		end
	},
	GenerateRom = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Generate ROM each time",
		getText = function(self) return Resources.QuickloadScreen.OptionGenerateRom end,
		clickableArea = { Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 74, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 74, 8, 8 },
		toggleState = false,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			-- Only one can be enabled at a time
			Options["Use premade ROMs"] = false
			self.toggleState = Options.toggleSetting(self.optionKey)

			-- After changing the setup, read-in any existing attempts counter for the new quickload choice
			Main.ReadAttemptsCount()
			QuickloadScreen.verifyOptions()
			QuickloadScreen.refreshButtons()
			NavigationMenu.refreshButtons()
			Program.redraw(true)
		end
	},
	RefocusEmulator = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Refocus emulator after load",
		getText = function(self) return Resources.QuickloadScreen.OptionRefocusEmulator end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 137, 110, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 137, 8, 8 },
		toggleState = false,
		isVisible = function(self) return Main.emulator ~= Main.EMU.BIZHAWK28 end, -- Option not needed nor used for Bizhawk 2.8
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end
	},
	Back = Drawing.createUIElementBackButton(function() Program.changeScreenView(NavigationMenu) end),
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
	local settingsChanged = false
	if not Options[optionPremade] and not Options[optionGenerate] then
		if jarBtn.isSet and gbaBtn.isSet and rnqsBtn.isSet then
			Options[optionGenerate] = true
			settingsChanged = true
		elseif romfolderBtn.isSet then
			Options[optionPremade] = true
			settingsChanged = true
		end
	elseif Options[optionPremade] and Options[optionGenerate] then
		-- If both premade seeds and generate ROM each time are enabled, turn one off
		Options[optionGenerate] = false
		settingsChanged = true
	end
	if settingsChanged then
		Main.SaveSettings(true)
	end

	QuickloadScreen.Buttons.PremadeRoms.toggleState = Options[optionPremade]
	QuickloadScreen.Buttons.GenerateRom.toggleState = Options[optionGenerate]
	NavigationMenu.refreshButtons()
	QuickloadScreen.refreshButtons()
end

function QuickloadScreen.createButtons()
	local filenameCutoff = 98
	for optionKey, optionObj in pairs(QuickloadScreen.SetButtonSetup) do
		QuickloadScreen.Buttons[optionKey] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self)
				if not self:statusIconVisible() then
					return "   " .. Constants.BLANKLINE
				elseif self.isSet then
					return Resources.QuickloadScreen.ButtonClear
				else
					return " " .. Resources.QuickloadScreen.ButtonSet
				end
			end,
			filename = "",
			optionKey = optionKey,
			isSet = false,
			statusIconVisible = optionObj.statusIconVisible,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, optionObj.offsetY, 24, 11 },
			updateSelf = function(self)
				if not self.isSet then
					self.filename = ""
				elseif Utils.isNilOrEmpty(self.filename) then
					if optionKey == "ROMs Folder" then
						self.filename = FileManager.extractFolderNameFromPath(Options.FILES[optionKey] or "") or ""
						local endChar = self.filename ~= "" and self.filename:sub(-1) or ""
						if endChar == FileManager.slash or endChar == "/" then
							endChar = "..."
						else
							endChar = "/..."
						end
						self.filename = self.filename .. endChar
					else
						self.filename = FileManager.extractFileNameFromPath(Options.FILES[optionKey] or "", true) or ""
					end
					self.filename = Utils.formatSpecialCharacters(self.filename)
					self.filename = Utils.shortenText(self.filename, filenameCutoff, true)
				end
			end,
			draw = function(self, shadowcolor)
				local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
				local labelText = Resources.QuickloadScreen[optionObj.resourceKey]
				local labelColor = Theme.COLORS[self.textColor]
				-- If a file is set, use its name instead of the label
				if self.isSet and not Utils.isNilOrEmpty(self.filename) then
					labelText = self.filename
					labelColor = Theme.COLORS["Positive text"]
				end
				Drawing.drawText(topboxX + 6, self.box[2], labelText, labelColor, shadowcolor)

				if not self.isSet and self:statusIconVisible() then
					Drawing.drawImageAsPixels(Constants.PixelImages.CROSS, self.box[1] - 20, self.box[2], { Theme.COLORS["Negative text"] }, shadowcolor)
				end
			end,
			onClick = function(self)
				if not self:statusIconVisible() then return end
				if self.isSet then
					Options.FILES[self.optionKey] = ""
					self.isSet = false
					Main.SaveSettings(true)
					QuickloadScreen.refreshButtons()
					Program.redraw(true)
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
	if not Utils.isNilOrEmpty(file) then
		-- Since the user had to pick a file, strip out the file name to just get the folder path
		local pattern = "^.*()" .. FileManager.slash
		file = file:sub(0, (file:match(pattern) or 1) - 1)

		if Utils.isNilOrEmpty(file) then
			Options.FILES[button.optionKey] = ""
			button.isSet = false
		else
			Options.FILES[button.optionKey] = file
			button.isSet = true
			-- After changing the setup, read-in any existing attempts counter for the new quickload choice
			Main.ReadAttemptsCount()
		end

		Main.SaveSettings(true)
	end

	QuickloadScreen.refreshButtons()
	Program.redraw(true)
	Utils.tempEnableBizhawkSound()
end

function QuickloadScreen.handleSetRandomizerJar(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "JAR File (*.JAR)|*.jar|All files (*.*)|*.*"

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT JAR", path, filterOptions)
	if not Utils.isNilOrEmpty(file) then
		local extension = FileManager.extractFileExtensionFromPath(file)
		if extension == "jar" then
			Options.FILES[button.optionKey] = file
			button.isSet = true
			Main.SaveSettings(true)
		else
			Main.DisplayError("The file selected is not the Randomizer JAR file.\n\nPlease select the JAR file in the Randomizer ZX folder.")
		end
	end

	QuickloadScreen.refreshButtons()
	Program.redraw(true)
	Utils.tempEnableBizhawkSound()
end

function QuickloadScreen.handleSetSourceRom(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "GBA File (*.GBA)|*.gba|All files (*.*)|*.*"

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT A ROM", path, filterOptions)
	if not Utils.isNilOrEmpty(file) then
		local extension = FileManager.extractFileExtensionFromPath(file)
		if extension == "gba" then
			Options.FILES[button.optionKey] = file
			button.isSet = true
			Main.SaveSettings(true)
		else
			Main.DisplayError("The file selected is not a GBA ROM file.\n\nPlease select a GBA file: has the file extension \".gba\"")
		end
	end

	QuickloadScreen.refreshButtons()
	Program.redraw(true)
	Utils.tempEnableBizhawkSound()
end

function QuickloadScreen.handleSetCustomSettings(button)
	local path = Options.FILES[button.optionKey]
	local filterOptions = "RNQS File (*.RNQS)|*.rnqs|All files (*.*)|*.*"

	-- If the custom settings file hasn't ever been set, show the folder containing preloaded setting files
	if Utils.isNilOrEmpty(path) or not FileManager.fileExists(path) then
		path = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.RandomizerSettings .. FileManager.slash)
	end

	Utils.tempDisableBizhawkSound()

	local file = forms.openfile("SELECT RNQS", path, filterOptions)
	if not Utils.isNilOrEmpty(file) then
		local extension = FileManager.extractFileExtensionFromPath(file)
		if extension == "rnqs" then
			Options.FILES[button.optionKey] = file
			button.isSet = true
			-- After changing the setup, read-in any existing attempts counter for the new quickload choice or force-create a new one if it doesn't exist
			Main.ReadAttemptsCount(true)
			Main.SaveSettings(true)
		else
			Main.DisplayError("The file selected is not a Randomizer Settings file.\n\nPlease select an RNQS file: has the file extension \".rnqs\"")
		end
	end

	QuickloadScreen.refreshButtons()
	Program.redraw(true)
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
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.QuickloadScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	local offsetY = topboxY

	-- Draw text to explain a choice should be made
	offsetY = offsetY + 18
	local chooseText = string.format("%s:", Resources.QuickloadScreen.ChoiceHeader)
	Drawing.drawText(topboxX + 2, offsetY, chooseText, Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	offsetY = offsetY + Constants.SCREEN.LINESPACING + 1

	local boxes = {
		{ x = topboxX + 4, y = offsetY, w = topboxWidth - 8, h = 30, },
		{ x = topboxX + 4, y = offsetY + 30, w = topboxWidth - 8, h = 60, },
	}
	for _, box in ipairs(boxes) do
		gui.drawRectangle(box.x + 1, box.y + 1, box.w, box.h, shadowcolor)
		gui.drawRectangle(box.x, box.y, box.w, box.h, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])
	end

	-- Removing for now, might add in later if quickload setup gets redone
	-- Draw near the bottom of the screen showing what settings are currently loaded
	-- local labelInfo
	-- if QuickloadScreen.Buttons.PremadeRoms.toggleState then
	-- 	gui.drawRectangle(boxes[1].x, boxes[1].y, boxes[1].w, boxes[1].h, Theme.COLORS["Intermediate text"])
	-- 	if QuickloadScreen.Buttons["ROMs Folder"].isSet then
	-- 		local foldername = FileManager.extractFolderNameFromPath(Options.FILES["ROMs Folder"])
	-- 		if not Utils.isNilOrEmpty(foldername) then
	-- 			if foldername:len() < 18 then
	-- 				labelInfo = string.format("%s: %s", Resources.QuickloadScreen.LabelFolder, foldername)
	-- 			else
	-- 				labelInfo = foldername
	-- 			end
	-- 		end
	-- 	end
	-- elseif QuickloadScreen.Buttons.GenerateRom.toggleState then
	-- 	gui.drawRectangle(boxes[2].x, boxes[2].y, boxes[2].w, boxes[2].h, Theme.COLORS["Intermediate text"])
	-- 	if QuickloadScreen.Buttons["Settings File"].isSet then
	-- 		local filename = FileManager.extractFileNameFromPath(Options.FILES["Settings File"])
	-- 		if not Utils.isNilOrEmpty(filename) then
	-- 			if filename:len() < 18 then
	-- 				labelInfo = string.format("%s: %s", Resources.QuickloadScreen.LabelSettings, filename)
	-- 			else
	-- 				labelInfo = filename
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- if labelInfo ~= nil then
	-- 	Drawing.drawText(topboxX + 2, topboxY + 126, labelInfo, Theme.COLORS[QuickloadScreen.textColor], shadowcolor)
	-- end

	-- Draw all buttons
	for _, button in pairs(QuickloadScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
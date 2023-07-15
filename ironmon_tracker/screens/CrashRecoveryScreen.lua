CrashRecoveryScreen = {
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	backupSaveFrequency = 60 * 3, -- number of seconds to wait between backing up a save-state
	started = false, -- Started later, only after the player begins the game
	lastSaveBackupTime = 0,
}

local columnOffsetX = 73
CrashRecoveryScreen.Buttons = {
	StatusYesCrash = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.WARNING,
		iconColors = { "Negative text" },
		getText = function(self) return Resources.CrashRecoveryScreen.StatusMessageCrash end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 15, 11, 12 },
		isVisible = function(self) return Main.CrashReport.crashedOccurred end,
	},
	StatusNoCrash = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CHECKMARK,
		iconColors = { "Positive text" },
		getText = function(self) return Resources.CrashRecoveryScreen.StatusMessageNoCrash end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 24, Constants.SCREEN.MARGIN + 15, 13, 12 },
		isVisible = function(self) return not Main.CrashReport.crashedOccurred end,
	},
	RecoverSave = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SPARKLES,
		getText = function(self) return Resources.CrashRecoveryScreen.ButtonRecoverSave end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 53, 90, 16 },
		updateSelf = function(self)
			self.disabled = Options["Enable crash recovery"] ~= true
			self.textColor = Utils.inlineIf(self.disabled, "Negative text", CrashRecoveryScreen.Colors.text)
		end,
		onClick = function(self)
			if self.disabled then return end
			CrashRecoveryScreen.recoverSave()
		end,
	},
	Dismiss = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CLOSE,
		getText = function(self) return Resources.CrashRecoveryScreen.ButtonDismiss end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 75, 90, 16 },
		updateSelf = function(self)
			self.disabled = Options["Enable crash recovery"] ~= true
			self.textColor = Utils.inlineIf(self.disabled, "Negative text", CrashRecoveryScreen.Colors.text)
		end,
		onClick = function(self)
			if self.disabled then return end
			Program.changeScreenView(CrashRecoveryScreen.previousScreen or ExtrasScreen)
			CrashRecoveryScreen.previousScreen = nil
		end,
	},
	EnableCrashRecovery = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Enable crash recovery",
		getText = function() return " " .. Resources.CrashRecoveryScreen.OptionEnableCrashRecovery end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 102, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 102, 8, 8 },
		toggleState = true, -- update later in initialize
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			-- If the setting is turned ON, restart the count for creating a backup save
			if Options[self.optionKey] then
				CrashRecoveryScreen.lastSaveBackupTime = os.time()
			end
			CrashRecoveryScreen.refreshButtons()
			Program.redraw(true)
		end,
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Back end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self) Program.changeScreenView(ExtrasScreen) end
	},
}

-- Initialize the screen
function CrashRecoveryScreen.initialize()
	-- Set default colors for buttons
	for _, button in pairs(CrashRecoveryScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = CrashRecoveryScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { CrashRecoveryScreen.Colors.border, CrashRecoveryScreen.Colors.boxFill }
		end
	end

	CrashRecoveryScreen.backupFolder = FileManager.prependDir(FileManager.Folders.BackupSaves)
	if Options["Enable crash recovery"] and not FileManager.folderExists(CrashRecoveryScreen.backupFolder) then
		FileManager.createFolder(CrashRecoveryScreen.backupFolder)
	end

	CrashRecoveryScreen.started = false
	CrashRecoveryScreen.lastSaveBackupTime = os.time()

	CrashRecoveryScreen.refreshButtons()
end

function CrashRecoveryScreen.refreshButtons()
	for _, button in pairs(CrashRecoveryScreen.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function CrashRecoveryScreen.readCrashReport()
	-- Likely can work on non-Bizhawk emulators, but not implemented for now
	if not Main.IsOnBizhawk() or not Options["Enable crash recovery"] then
		return
	end

	local crashReport = FileManager.readTableFromFile(FileManager.Files.CRASH_REPORT) or {}
	crashReport.crashedOccurred = (crashReport.crashedOccurred == true) -- convert possible nil to a boolean
	return crashReport
end

function CrashRecoveryScreen.logCrashReport(crashedOccurred)
	-- Likely can work on non-Bizhawk emulators, but not implemented for now
	if not Main.IsOnBizhawk() or not Options["Enable crash recovery"] then
		return
	end

	local crashReport = {
		crashedOccurred = (crashedOccurred == true),
		gameName = GameSettings.versioncolor,
		romName = GameSettings.getRomName(),
	}
	FileManager.writeTableToFile(crashReport, FileManager.Files.CRASH_REPORT)
end

function CrashRecoveryScreen.safelyCloseWithoutCrash()
	-- Likely can work on non-Bizhawk emulators, but not implemented for now
	if not Main.IsOnBizhawk() or not Options["Enable crash recovery"] then
		return
	end
	-- Safely closed; no crash
	CrashRecoveryScreen.logCrashReport(false)
end

function CrashRecoveryScreen.startSavingBackups()
	CrashRecoveryScreen.started = true
	CrashRecoveryScreen.lastSaveBackupTime = os.time()
end

function CrashRecoveryScreen.trySaveBackup()
	if not CrashRecoveryScreen.started then
		return
	end

	if Main.IsOnBizhawk() then
		local timeElapsed = os.time() - CrashRecoveryScreen.lastSaveBackupTime
		if timeElapsed >= CrashRecoveryScreen.backupSaveFrequency then
			local filepath = CrashRecoveryScreen.getBackupFilepath()
			---@diagnostic disable-next-line: undefined-global
			savestate.save(filepath, true) -- true: supresses the on-screen display message
			CrashRecoveryScreen.lastSaveBackupTime = os.time()
		end
	end
end

-- Returns the filepath to the save-state file, with the file extension
function CrashRecoveryScreen.getBackupFilepath()
	local gamename = GameSettings.versioncolor or "UnknownGame"
	local filename = string.format("%s%s%s", gamename, FileManager.PostFixes.BACKUPSAVE, FileManager.Extensions.SAVESTATE)
	return CrashRecoveryScreen.backupFolder .. FileManager.slash .. filename
end

function CrashRecoveryScreen.recoverSave()
	if Main.IsOnBizhawk() then
		local filepath = CrashRecoveryScreen.getBackupFilepath()
		if FileManager.fileExists(filepath) then
			---@diagnostic disable-next-line: undefined-global
			savestate.load(filepath, false) -- false: will show the on-screen display message
		end
	end
end

-- Check if any buttons were clicked
function CrashRecoveryScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, CrashRecoveryScreen.Buttons)
end

-- Draw the screen
function CrashRecoveryScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[CrashRecoveryScreen.Colors.boxFill])
	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[CrashRecoveryScreen.Colors.text],
		border = Theme.COLORS[CrashRecoveryScreen.Colors.border],
		fill = Theme.COLORS[CrashRecoveryScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[CrashRecoveryScreen.Colors.boxFill]),
	}

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.CrashRecoveryScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	local textLineY = topBox.y + 3

	-- Skip past the crash status message
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 10

	local gameName = Main.CrashReport.gameName or Resources.CrashRecoveryScreen.GameNotAvailable
	local gameFromReport = string.format("%s:  %s", Resources.CrashRecoveryScreen.LastPlayedGame, gameName)
	Drawing.drawText(topBox.x + 3, textLineY, gameFromReport, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw buttons
	for _, button in pairs(CrashRecoveryScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

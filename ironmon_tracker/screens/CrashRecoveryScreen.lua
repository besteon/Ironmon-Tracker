CrashRecoveryScreen = {
	Colors = {
		header = "Intermediate text",
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	backupSaveFrequency = 60 * 3, -- number of seconds to wait between backing up a save-state
	started = false, -- Started later, only after the player begins the game
	undoTempSaveState = nil, -- Once a save is recovered, this holds a save state at the point in time right before that
	lastSaveBackupTime = 0,
}

CrashRecoveryScreen.Buttons = {
	StatusYesCrash = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.WARNING,
		textColor = CrashRecoveryScreen.Colors.header,
		iconColors = { "Negative text" },
		getText = function(self) return Resources.CrashRecoveryScreen.StatusMessageCrash end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 15, 11, 12 },
		isVisible = function(self) return Main.CrashReport.crashedOccurred end,
	},
	StatusNoCrash = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = CrashRecoveryScreen.Colors.header,
		getText = function(self) return Resources.CrashRecoveryScreen.StatusMessageNoCrash end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 24, Constants.SCREEN.MARGIN + 15, 13, 12 },
		isVisible = function(self) return not Main.CrashReport.crashedOccurred end,
	},
	RecoverSave = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.SPARKLES,
		getText = function(self) return Resources.CrashRecoveryScreen.ButtonRecoverSave end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 80, 90, 16 },
		isVisible = function(self) return CrashRecoveryScreen.undoSaveRestorePoint == nil end,
		updateSelf = function(self)
			self.disabled = not CrashRecoveryScreen.isEnabled()
			self.textColor = Utils.inlineIf(self.disabled, "Negative text", CrashRecoveryScreen.Colors.text)
		end,
		onClick = function(self)
			if self.disabled then return end
			CrashRecoveryScreen.recoverSave()
			Program.redraw(true)
		end,
	},
	UndoRecoverSave = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CLOCK,
		getText = function(self) return string.format("(%s)", Resources.CrashRecoveryScreen.ButtonUndoRecovery) end,
		isVisible = function(self) return CrashRecoveryScreen.undoSaveRestorePoint ~= nil end,
		onClick = function(self)
			CrashRecoveryScreen.undoRecoverSave()
			Program.redraw(true)
		end,
	},
	Dismiss = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CLOSE,
		getText = function(self) return Resources.CrashRecoveryScreen.ButtonDismiss end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 101, 90, 16 },
		updateSelf = function(self)
			self.disabled = not CrashRecoveryScreen.isEnabled()
			self.textColor = Utils.inlineIf(self.disabled, "Negative text", CrashRecoveryScreen.Colors.text)
		end,
		onClick = function(self)
			if self.disabled then return end
			CrashRecoveryScreen.goBack()
		end,
	},
	EnableCrashRecovery = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Enable crash recovery",
		getText = function() return " " .. Resources.CrashRecoveryScreen.OptionEnableCrashRecovery end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 124, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 124, 8, 8 },
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
	Back = Drawing.createUIElementBackButton(function() CrashRecoveryScreen.goBack() end),
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
	-- These buttons share the same space, but visible at different times
	CrashRecoveryScreen.Buttons.UndoRecoverSave.box = CrashRecoveryScreen.Buttons.RecoverSave.box

	-- Make sure the backup save folder exists before using it later
	CrashRecoveryScreen.backupFolder = FileManager.prependDir(FileManager.Folders.BackupSaves)
	if CrashRecoveryScreen.isEnabled() and not FileManager.folderExists(CrashRecoveryScreen.backupFolder) then
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

function CrashRecoveryScreen.isEnabled()
	return (Options["Enable crash recovery"] == true) -- convert possible nil to a boolean
end

function CrashRecoveryScreen.goBack()
	Program.changeScreenView(CrashRecoveryScreen.previousScreen or ExtrasScreen)
	CrashRecoveryScreen.previousScreen = nil
	CrashRecoveryScreen.undoSaveRestorePoint = nil
end

function CrashRecoveryScreen.readCrashReport()
	if CrashRecoveryScreen.isEnabled() then
		local crashReport = FileManager.readTableFromFile(FileManager.Files.CRASH_REPORT) or {}
		crashReport.crashedOccurred = (crashReport.crashedOccurred == true) -- convert possible nil to a boolean
		return crashReport
	else
		return {
			crashedOccurred = false,
			gameName = GameSettings.fullVersionName,
			romHash = GameSettings.getRomHash(),
		}
	end
end

function CrashRecoveryScreen.logCrashReport(crashedOccurred)
	if not CrashRecoveryScreen.isEnabled() then return end

	local crashReport = {
		crashedOccurred = (crashedOccurred == true),
		gameName = GameSettings.fullVersionName,
		romHash = GameSettings.getRomHash(),
	}
	local filepath = FileManager.prependDir(FileManager.Files.CRASH_REPORT)
	FileManager.writeTableToFile(crashReport, filepath)
end

function CrashRecoveryScreen.startSavingBackups()
	CrashRecoveryScreen.started = true
	CrashRecoveryScreen.lastSaveBackupTime = os.time()
end

function CrashRecoveryScreen.trySaveBackup()
	if not CrashRecoveryScreen.started then
		return
	end

	local filepath = CrashRecoveryScreen.getBackupFilepath()
	local timeElapsed = os.time() - CrashRecoveryScreen.lastSaveBackupTime
	if timeElapsed >= CrashRecoveryScreen.backupSaveFrequency then
		CrashRecoveryScreen.lastSaveBackupTime = os.time()
		if Main.IsOnBizhawk() then
			savestate.save(filepath, true) -- true: suppresses the on-screen display message
		else
			---@diagnostic disable-next-line: undefined-global
			emu:saveStateFile(filepath, C.SAVESTATE.ALL)
		end
	end
end

-- Returns the filepath to the save-state file, with the file extension
function CrashRecoveryScreen.getBackupFilepath()
	local gamename = GameSettings.versioncolor or "UnknownGame"
	local filename = string.format("%s%s", gamename, FileManager.PostFixes.BACKUPSAVE)
	local extension = Utils.inlineIf(Main.IsOnBizhawk(), FileManager.Extensions.BIZHAWK_SAVESTATE, FileManager.Extensions.MGBA_SAVESTATE)
	return CrashRecoveryScreen.backupFolder .. FileManager.slash .. filename .. extension
end

function CrashRecoveryScreen.recoverSave()
	local filepath = CrashRecoveryScreen.getBackupFilepath()
	if not FileManager.fileExists(filepath) then
		return
	end

	if Main.IsOnBizhawk() then
		-- First create a temporary save state as a way to undo
		CrashRecoveryScreen.undoSaveRestorePoint = {
			id = memorysavestate.savecorestate(),
			label = Resources.CrashRecoveryScreen.ButtonUndoRecovery,
			timestamp = os.time(),
			playtime = Tracker.Data.playtime
		}

		savestate.load(filepath, false) -- false: will show the on-screen display message

		-- Once loaded, store a second copy of the backed up save in the Time Machine
		TimeMachineScreen.createRestorePoint()
	else
		-- Not sure the best way to create a temp undo save state for mGBA
		CrashRecoveryScreen.undoSaveRestorePoint = nil
		---@diagnostic disable-next-line: undefined-global
		emu:loadStateFile(filepath, C.SAVESTATE.ALL)
	end
end

function CrashRecoveryScreen.undoRecoverSave()
	local restorePoint = CrashRecoveryScreen.undoSaveRestorePoint
	if not restorePoint then return end

	if Main.IsOnBizhawk() then
		if restorePoint.id then
			memorysavestate.loadcorestate(restorePoint.id)
			Tracker.Data.playtime = restorePoint.playtime
			Program.updateDataNextFrame()
		end
		CrashRecoveryScreen.undoSaveRestorePoint = nil
	else
		-- For other emulators. To be implemented later.
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
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 4

	-- Game Info
	local gameName = Main.CrashReport.gameName or Resources.CrashRecoveryScreen.NotAvailable
	gameName = Utils.formatSpecialCharacters(gameName)
	Drawing.drawText(topBox.x + 3, textLineY, Resources.CrashRecoveryScreen.LastPlayedGame .. ":", topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1
	local centerOffsetX = Utils.getCenteredTextX(gameName, topBox.width) - 1
	Drawing.drawText(topBox.x + centerOffsetX, textLineY, gameName, topBox.text, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1

	-- Games Match Info
	local columnOffsetX = 122
	local gamesMatch = Main.CrashReport.gameName ~= nil and Main.CrashReport.gameName == GameSettings.fullVersionName
	local gameMatchIcon, gameMatchIconColor
	if gamesMatch then
		gameMatchIcon = Constants.PixelImages.CHECKMARK
		gameMatchIconColor = Theme.COLORS["Positive text"]
	else
		gameMatchIcon = Constants.PixelImages.CROSS
		gameMatchIconColor = Theme.COLORS["Negative text"]
	end
	Drawing.drawText(topBox.x + 3, textLineY, Resources.CrashRecoveryScreen.SameGameAsLast .. ":", topBox.text, topBox.shadow)
	Drawing.drawImageAsPixels(gameMatchIcon, topBox.x + columnOffsetX, textLineY, gameMatchIconColor, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1

	-- Roms Match Info
	local romsMatch = Main.CrashReport.romHash ~= nil and Main.CrashReport.romHash == GameSettings.getRomHash()
	local romsMatchIcon, romsMatchColor
	if romsMatch then
		romsMatchIcon = Constants.PixelImages.CHECKMARK
		romsMatchColor = Theme.COLORS["Positive text"]
	else
		romsMatchIcon = Constants.PixelImages.CROSS
		romsMatchColor = Theme.COLORS["Negative text"]
	end
	Drawing.drawText(topBox.x + 3, textLineY, Resources.CrashRecoveryScreen.SameRomAsLast .. ":", topBox.text, topBox.shadow)
	Drawing.drawImageAsPixels(romsMatchIcon, topBox.x + columnOffsetX, textLineY, romsMatchColor, topBox.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1

	-- Draw buttons
	for _, button in pairs(CrashRecoveryScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

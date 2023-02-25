UpdateScreen = {
	Labels = {
		title = "Tracker Update Available",
		titleCheck = "Tracker Update Check",
		currentVersion = "Current version:",
		newVersion = "New version available:",
		questionHeader = "What would you like to do?",
		updatePrepareText = "Prepare for update",
		updateNowText = "Update now",
		updateDownloadText = "Open download link",
		remindMeText = "Remind me tomorrow",
		ignoreUpdateText = "( Skip this update )",
		releaseNotesText = "View release notes",
		reloadTrackerText = "Restart Tracker",
		manualDownloadText = "Manual Download",

		inProgressMsg = "Check external Window for status.",
		afterRestartMsg = "Please close and reopen Bizhawk",
		safeReloadMsg = "You can safely reload the Tracker:",
		errorOccurredMsg = string.format("Then load:  %s", FileManager.Files.UPDATE_OR_INSTALL),
		releaseNotesErrMsg = "Check the Lua Console for a link to the Tracker's Release Notes."
	},
	States = {
		NEEDS_CHECK = "Already on the latest version.", -- Not displayed anywhere visually
		NOT_UPDATED = "Update not yet started.", -- Not displayed anywhere visually
		AFTER_RESTART = "Update is ready when you restart.",
		IN_PROGRESS = "Update in progress,  please wait...",
		SUCCESS = "The auto-update was successful.",
		ERROR = "ERROR: Please restart Bizhawk...",
	},
}

UpdateScreen.Buttons = {
	DevOptIn = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = " Dev branch updates",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 33, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 33, 8, 8 },
		textColor = "Default text",
		boxColors = { "Upper box border", "Upper box background" },
		toggleState = false, -- update later in initialize
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			UpdateOrInstall.Dev.enabled = self.toggleState

			if UpdateOrInstall.Dev.enabled or not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				UpdateScreen.currentState = UpdateScreen.States.NEEDS_CHECK
			end

			Options.updateSetting(self.text, self.toggleState)
			Options.forceSave()
		end
	},
	CheckForUpdates = {
		text = "Check for Updates", -- Can also be "No Updates Available"
		image = Constants.PixelImages.INSTALL_BOX,
		type = Constants.ButtonTypes.ICON_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15, Constants.SCREEN.MARGIN + 112, 110, 15 },
		isVisible = function(self) return UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK end,
		onClick = function(self)
			-- Don't check for updates if they've already been checked since on this screen (resets after clicking Back)
			if self.text == "Check for Updates" then
				Main.CheckForVersionUpdate(true)
				NavigationMenu.Buttons.CheckForUpdates:updateText()
			end

			if not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				self.text = "No Updates Available"
			end
			Program.redraw(true)
		end
	},
	UpdateNow = {
		text = UpdateScreen.Labels.updatePrepareText,
		image = Constants.PixelImages.INSTALL_BOX,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
		updateSelf = function(self)
			-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
			if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
				self.text = UpdateScreen.Labels.updateDownloadText
				return
			end
			if Main.Version.updateAfterRestart then
				self.text = UpdateScreen.Labels.updateNowText
			else
				self.text = UpdateScreen.Labels.updatePrepareText
			end
		end,
		onClick = function(self)
			-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
			if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
				-- In such a case, open a browser window with a link for manual download...
				UpdateScreen.openReleaseNotesWindow()
				-- ... and swap back to main Tracker screen. Implied to remind later if they forget to manually update.
				UpdateScreen.remindMeLater()
			else
				if Main.Version.updateAfterRestart then
					UpdateScreen.performAutoUpdate()
				else
					UpdateScreen.prepareForUpdateAfterRestart()
					self:updateSelf()
				end
			end
		end
	},
	RemindMeLater = {
		text = UpdateScreen.Labels.remindMeText,
		image = Constants.PixelImages.CLOCK,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED or UpdateScreen.currentState == UpdateScreen.States.AFTER_RESTART end,
		onClick = function() UpdateScreen.remindMeLater() end
	},
	IgnoreUpdate = {
		text = UpdateScreen.Labels.ignoreUpdateText,
		image = Constants.PixelImages.BLANK,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED or UpdateScreen.currentState == UpdateScreen.States.ERROR end,
		onClick = function() UpdateScreen.ignoreTheUpdate() end
	},
	ViewReleaseNotes = {
		text = UpdateScreen.Labels.releaseNotesText,
		image = Constants.PixelImages.NOTEPAD,
		isVisible = function() return UpdateScreen.currentState ~= UpdateScreen.States.NEEDS_CHECK end,
		onClick = function() UpdateScreen.openReleaseNotesWindow() end
	},
	ReloadTracker = {
		text = UpdateScreen.Labels.reloadTrackerText,
		image = Constants.PixelImages.INSTALL_BOX,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.SUCCESS end,
		onClick = function() IronmonTracker.startTracker() end
	},
	ManualDownload = {
		text = UpdateScreen.Labels.manualDownloadText,
		image = Constants.PixelImages.INSTALL_BOX,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.ERROR end,
		onClick = function()
			-- Open a browser window with a link for manual download
			UpdateScreen.openReleaseNotesWindow()
			-- Swap back to main Tracker screen. Implied to remind later if they forget to manually update.
			UpdateScreen.remindMeLater()
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK end,
		onClick = function(self)
			-- Reset the CheckForUpdates button text
			UpdateScreen.Buttons.CheckForUpdates.text = "Check for Updates"
			Program.changeScreenView(NavigationMenu)
		end
	},
}

UpdateScreen.OrderedMenuList = {
	UpdateScreen.Buttons.UpdateNow,
	UpdateScreen.Buttons.RemindMeLater,
	UpdateScreen.Buttons.IgnoreUpdate,
	UpdateScreen.Buttons.ViewReleaseNotes,
}

function UpdateScreen.initialize()
	UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15
	local startY = Constants.SCREEN.MARGIN + 65
	for _, button in ipairs(UpdateScreen.OrderedMenuList) do
		button.box = { startX, startY, 110, 16 }
		startY = startY + 21
	end

	for _, button in pairs(UpdateScreen.Buttons) do
		if button.type == nil then
			button.type = Constants.ButtonTypes.ICON_BORDER
		end
		if button.textColor == nil then
			button.textColor = "Lower box text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Lower box border", "Lower box background" }
		end
	end

	UpdateScreen.Buttons.DevOptIn.toggleState = Options["Dev branch updates"] or false

	-- These buttons share a location, but visiable at different times based on Update Status
	UpdateScreen.Buttons.CheckForUpdates.box = UpdateScreen.Buttons.UpdateNow.box
	UpdateScreen.Buttons.ReloadTracker.box = UpdateScreen.Buttons.RemindMeLater.box
	UpdateScreen.Buttons.ManualDownload.box = UpdateScreen.Buttons.RemindMeLater.box

	UpdateScreen.refreshButtons()
end

function UpdateScreen.refreshButtons()
	for _, button in pairs(UpdateScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function UpdateScreen.prepareForUpdateAfterRestart()
	UpdateScreen.currentState = UpdateScreen.States.AFTER_RESTART
	Main.Version.updateAfterRestart = true
	Main.SaveSettings(true)
	Program.redraw(true)
end

function UpdateScreen.performAutoUpdate()
	UpdateScreen.currentState = UpdateScreen.States.IN_PROGRESS
	Program.redraw(true)

	Utils.tempDisableBizhawkSound()

	if Main.IsOnBizhawk() then
		gui.clearImageCache() -- Required to make Bizhawk release images so that they can be replaced
		Main.frameAdvance() -- Required to allow the redraw to occur before batch commands begin
	end

	-- Don't bother saving tracked data if the player doesn't have a Pokemon yet
	if Options["Auto save tracked game data"] and Tracker.getPokemon(1, true) ~= nil then
		Tracker.saveData()
	end

	if UpdateOrInstall.performParallelUpdate() then
		UpdateScreen.currentState = UpdateScreen.States.SUCCESS
		Main.Version.showUpdate = false
		Main.Version.updateAfterRestart = false
		Main.SaveSettings(true)
	else
		UpdateScreen.currentState = UpdateScreen.States.ERROR
	end

	Utils.tempEnableBizhawkSound()

	-- With the changes to parallel updates only working after a restart, if the update is successful, simply restart the Tracker scripts
	if UpdateScreen.currentState == UpdateScreen.States.SUCCESS then
		IronmonTracker.startTracker()
	else
		Program.redraw(true)
	end
end

function UpdateScreen.remindMeLater()
	Main.Version.remindMe = true
	Main.Version.showUpdate = false
	Main.Version.updateAfterRestart = false
	Main.SaveSettings(true)
	local screenToShow = Utils.inlineIf(Program.isValidMapLocation(), TrackerScreen, StartupScreen)
	Program.changeScreenView(screenToShow)
end

function UpdateScreen.ignoreTheUpdate()
	Main.Version.remindMe = false
	Main.Version.showUpdate = false
	Main.Version.updateAfterRestart = false
	Main.SaveSettings(true)
	local screenToShow = Utils.inlineIf(Program.isValidMapLocation(), TrackerScreen, StartupScreen)
	Program.changeScreenView(screenToShow)
end

function UpdateScreen.openReleaseNotesWindow()
	Utils.openBrowserWindow(FileManager.Urls.DOWNLOAD, UpdateScreen.Labels.releaseNotesErrMsg)
end

-- USER INPUT FUNCTIONS
function UpdateScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, UpdateScreen.Buttons)
end

-- DRAWING FUNCTIONS
function UpdateScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = 45,
		text = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height + 13,
		width = topBox.width,
		height = 92,
		text = Theme.COLORS["Lower box text"],
		border = Theme.COLORS["Lower box border"],
		fill = Theme.COLORS["Lower box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"]),
	}
	local topcolX = topBox.x + 109
	local textLineY = topBox.y + 2
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- TOP BORDER BOX
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	local titleText
	if UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK then
		titleText = UpdateScreen.Labels.titleCheck:upper()
	else
		titleText = UpdateScreen.Labels.title:upper()
	end
	local offsetX = Utils.getCenteredTextX(titleText, topBox.width)
	Drawing.drawText(topBox.x + offsetX, textLineY, titleText:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing + 5

	if Main.isOnLatestVersion() then
		Drawing.drawText(topBox.x + 8, textLineY, UpdateScreen.Labels.currentVersion, topBox.text, topBox.shadow)
		Drawing.drawText(topcolX, textLineY, Main.TrackerVersion, topBox.text, topBox.shadow)
		textLineY = textLineY + linespacing
	else
		Drawing.drawText(topBox.x + 8, textLineY, UpdateScreen.Labels.newVersion, topBox.text, topBox.shadow)
		Drawing.drawText(topcolX, textLineY, Main.Version.latestAvailable, Theme.COLORS["Positive text"], topBox.shadow)
		textLineY = textLineY + linespacing
	end

	-- HEADER DIVIDER
	local bgShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local headerText
	if UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED then
		headerText = UpdateScreen.Labels.questionHeader
	elseif UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK then
		headerText = "Manually check for updates below:"
	else
		headerText = "Update Status:"
	end
	Drawing.drawText(botBox.x + 1, botBox.y - 11, headerText, Theme.COLORS["Header text"], bgShadow)

	-- BOTTOM BORDER BOX
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)
	textLineY = botBox.y + 2

	local updateStatusColor
	local updateStatusMsg
	if UpdateScreen.currentState == UpdateScreen.States.IN_PROGRESS then
		updateStatusColor = Theme.COLORS["Intermediate text"]
		updateStatusMsg = UpdateScreen.Labels.inProgressMsg
	elseif UpdateScreen.currentState == UpdateScreen.States.AFTER_RESTART then
		updateStatusColor = Theme.COLORS["Intermediate text"]
		updateStatusMsg = UpdateScreen.Labels.afterRestartMsg
	elseif UpdateScreen.currentState == UpdateScreen.States.SUCCESS then
		updateStatusColor = Theme.COLORS["Positive text"]
		updateStatusMsg = UpdateScreen.Labels.safeReloadMsg
	elseif UpdateScreen.currentState == UpdateScreen.States.ERROR then
		updateStatusColor = Theme.COLORS["Negative text"]
		updateStatusMsg = UpdateScreen.Labels.errorOccurredMsg
	end

	if UpdateScreen.currentState ~= UpdateScreen.States.NOT_UPDATED and UpdateScreen.currentState ~= UpdateScreen.States.NEEDS_CHECK then
		Drawing.drawText(botBox.x + 3, textLineY, UpdateScreen.currentState or "", updateStatusColor, botBox.shadow)
		textLineY = textLineY + linespacing
		Drawing.drawText(botBox.x + 3, textLineY, updateStatusMsg or "", botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing
	end

	-- Draw all buttons, manually
	for _, button in pairs(UpdateScreen.Buttons) do
		if button.isVisible == nil or button:isVisible() then
			if button.boxColors ~= nil and button.boxColors[2] == "Upper box background" then
				Drawing.drawButton(button, topBox.shadow)
			else
				Drawing.drawButton(button, botBox.shadow)
			end
		end
	end
end
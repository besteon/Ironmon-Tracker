UpdateScreen = {
	Labels = {
		-- TODO: replace this with the ones from Resources
		inProgressMsg = "Check external Window for status.",
		afterRestartMsg = "Please close and reopen Bizhawk",
		safeReloadMsg = "You can safely reload the Tracker:",
		errorOccurredMsg = string.format("Then load:  %s", FileManager.Files.UPDATE_OR_INSTALL),
		releaseNotesErrMsg = "Check the Lua Console for a link to the Tracker's Release Notes."
	},
	States = {
		NEEDS_CHECK = 1, -- "Already on the latest version.", -- Not displayed anywhere visually
		NOT_UPDATED = 2, -- "Update not yet started.", -- Not displayed anywhere visually
		AFTER_RESTART = 3, -- "Restart the emulator to update.",
		IN_PROGRESS = 4, -- "Update in progress, please wait.",
		SUCCESS = 5, -- "Update successful.",
		ERROR = 6, -- "Update failed.",
	},
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

UpdateScreen.Buttons = {
	CurrentVersion = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.UpdateScreen.VersionCurrent .. ":" end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, Constants.SCREEN.MARGIN + 13, 50, 11 },
		draw = function(self, shadowcolor)
			local offsetX = self.box[1] + 72
			Drawing.drawText(offsetX, self.box[2], Main.TrackerVersion, Theme.COLORS[self.textColor], shadowcolor)
		end,
	},
	LatestVersion = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.UpdateScreen.VersionLatest .. ":" end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, Constants.SCREEN.MARGIN + 26, 50, 11 },
		draw = function(self, shadowcolor)
			local offsetX = self.box[1] + 72
			Drawing.drawText(offsetX, self.box[2], Main.Version.latestAvailable, Theme.COLORS[self.textColor], shadowcolor)

			if not Main.isOnLatestVersion() then -- TODO: remove true
				local newText = string.format("(%s)", Resources.UpdateScreen.VersionNew)
				Drawing.drawText(offsetX + 30, self.box[2], newText, Theme.COLORS["Positive text"], shadowcolor)
			end
		end,
	},
	ReleaseNotesLabel = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.UpdateScreen.LabelRelease .. ":" end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, Constants.SCREEN.MARGIN + 39, 50, 11 },
	},
	ShowHideReleaseNotes = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if self.showNotes then
				return Resources.UpdateScreen.ButtonHide
			else
				return Resources.UpdateScreen.ButtonShow
			end
		end,
		showNotes = false,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 75, Constants.SCREEN.MARGIN + 40, 28, 11 },
		onClick = function(self)
			self.showNotes = not self.showNotes
			-- TODO: if notes are shown, overlay them on top of the main game screen (use some light transperency)
			-- Also, if no notes exist then pull them in; #Main.Version.releaseNotes == 0
			Program.redraw(true)
		end
	},
	CheckForUpdates = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self)
			if self.updateStatus == "Unchecked" then
				return Resources.UpdateScreen.ButtonCheckForUpdates
			else
				return Resources.UpdateScreen.ButtonNoUpdates
			end
		end,
		updateStatus = "Unchecked", -- checked later when clicked
		reset = function(self)
			self.updateStatus = "Unchecked"
			self.textColor = UpdateScreen.Colors.text
			self.image = Constants.PixelImages.TRIANGLE_DOWN
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 20, Constants.SCREEN.MARGIN + 83, 100, 16 },
		isVisible = function(self) return UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK end,
		onClick = function(self)
			-- Don't check for updates if they've already been checked while on this screen (resets after clicking Back)
			if self.updateStatus == "Unchecked" then
				Main.CheckForVersionUpdate(true)
			end

			if not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				self.updateStatus = "Unavailable"
				self.textColor = "Intermediate text"
				self.image = Constants.PixelImages.CROSS
			end
			Program.redraw(true)
		end
	},
	InstallUpdate = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.INSTALL_BOX,
		getText = function(self)
			-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
			if not UpdateScreen.isUpdateSupported() then
				return Resources.UpdateScreen.ButtonOpenDownload
			elseif Main.Version.updateAfterRestart then
				return Resources.UpdateScreen.ButtonInstallNow
			elseif UpdateOrInstall.Dev.enabled then
				return Resources.UpdateScreen.ButtonBeginInstall
			else
				return Resources.UpdateScreen.ButtonBeginInstall
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 73, 90, 16 },
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
		onClick = function(self)
			if not UpdateScreen.isUpdateSupported() then
				-- In such a case, open a browser window with a link for manual download...
				UpdateScreen.openReleaseNotesWindow()
				-- ... and swap back to main Tracker screen. Default to remind later if they forget to manually update.
				Main.Version.remindMe = true
				UpdateScreen.exitScreen()
			else
				if Main.Version.updateAfterRestart then
					-- Instructs Main to perform the update after the current emulation frame loop finishes
					Main.updateRequested = true
				else
					UpdateScreen.prepareForUpdateAfterRestart()
				end
			end
		end
	},
	IgnoreUpdate = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CROSS,
		getText = function(self) return Resources.UpdateScreen.ButtonIgnoreUpdate end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 95, 90, 16 },
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
		onClick = function() UpdateScreen.exitScreenAndRemindMe(false) end
	},
	DevOptIn = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return " " .. Resources.UpdateScreen.CheckboxDevBranch end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 137, 98, 10 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 137, 8, 8 },
		toggleState = (Options["Dev branch updates"] == true), -- update later in initialize
		toggleColor = "Positive text",
		updateSelf = function(self)
			self.toggleState = (Options["Dev branch updates"] == true)
		end,
		onClick = function(self)
			Options["Dev branch updates"] = not (Options["Dev branch updates"] == true)
			UpdateOrInstall.Dev.enabled = Options["Dev branch updates"]

			-- If an update is available or if dev branch enabled (always allow for updates)
			if UpdateOrInstall.Dev.enabled or not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				UpdateScreen.currentState = UpdateScreen.States.NEEDS_CHECK
			end
			self:updateSelf()
			Main.SaveSettings(true)
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Back end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self) UpdateScreen.exitScreenAndRemindMe(true) end
	},
}

function UpdateScreen.initialize()
	for _, button in pairs(UpdateScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = UpdateScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { UpdateScreen.Colors.border, UpdateScreen.Colors.boxFill }
		end
	end

	UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
	UpdateScreen.refreshButtons()
end

function UpdateScreen.refreshButtons()
	for _, button in pairs(UpdateScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

-- Auto-update not supported on Linux Bizhawk 2.8 (Lua 5.1)
function UpdateScreen.isUpdateSupported()
	return Main.OS == "Windows" or Main.emulator ~= Main.EMU.BIZHAWK28
end

function UpdateScreen.exitScreenAndRemindMe(shouldRemindMe)
	Main.Version.remindMe = shouldRemindMe
	Main.Version.showUpdate = false
	Main.Version.updateAfterRestart = false
	Main.SaveSettings(true)
	UpdateScreen.Buttons.CheckForUpdates:reset()
	Program.changeScreenView(NavigationMenu)
end

function UpdateScreen.prepareForUpdateAfterRestart()
	UpdateScreen.currentState = UpdateScreen.States.AFTER_RESTART
	Main.Version.updateAfterRestart = true
	Main.SaveSettings(true)
	Program.redraw(true)
end

function UpdateScreen.performAutoUpdate()
	Main.updateRequested = false
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
	gui.defaultTextBackground(Theme.COLORS[UpdateScreen.Colors.boxFill])

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[UpdateScreen.Colors.text],
		border = Theme.COLORS[UpdateScreen.Colors.border],
		fill = Theme.COLORS[UpdateScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[UpdateScreen.Colors.boxFill]),
	}
	local textLineY = topBox.y + 2
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, Resources.UpdateScreen.Title:upper(), Theme.COLORS["Header text"], headerShadow)

	-- TOP BORDER BOX
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- HEADER DIVIDER
	-- local headerText
	-- if UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED then
	-- 	headerText = UpdateScreen.Labels.questionHeader
	-- elseif UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK then
	-- 	headerText = "Manually check for updates below:"
	-- else
	-- 	headerText = "Update Status:"
	-- end
	-- Drawing.drawText(topBox.x + 1, topBox.y - 11, headerText, Theme.COLORS["Header text"], bgShadow)

	-- TODO, find a way to display this information, and clean up the UpdateScreen.States list
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

	-- if UpdateScreen.currentState ~= UpdateScreen.States.NOT_UPDATED and UpdateScreen.currentState ~= UpdateScreen.States.NEEDS_CHECK then
	-- 	Drawing.drawText(topBox.x + 3, textLineY, UpdateScreen.currentState or "", updateStatusColor, topBox.shadow)
	-- 	textLineY = textLineY + linespacing
	-- 	Drawing.drawText(topBox.x + 3, textLineY, updateStatusMsg or "", topBox.text, topBox.shadow)
	-- 	textLineY = textLineY + linespacing
	-- end

	-- Draw all buttons
	for _, button in pairs(UpdateScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end
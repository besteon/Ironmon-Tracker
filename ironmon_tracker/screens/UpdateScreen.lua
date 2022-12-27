UpdateScreen = {
	Labels = {
		title = "Tracker Update Available",
		currentVersion = "Current version:",
		newVersion = "New version available:",
		questionHeader = "What would you like to do?",
		updateAutoText = "Update automatically",
		remindMeText = "Remind me tomorrow",
		ignoreUpdateText = "( Skip this update )",
		releaseNotesText = "View release notes",
		reloadTrackerText = "Restart Tracker",
		manualDownloadText = "Manual Download",

		inProgressMsg = "Check external Window for status.",
		safeReloadMsg = "You can safely reload the Tracker:",
		errorOccurredMsg = "Please try updating manually:",
	},
	States = {
		NEEDS_CHECK = "Already on the latest version.", -- Not displayed anywhere visually
		NOT_UPDATED = "Update not yet started.", -- Not displayed anywhere visually
		IN_PROGRESS = "Update in progress,  please wait...",
		SUCCESS = "The auto-update was successful.",
		ERROR = "Error with auto-updater.",
	},
}

UpdateScreen.Buttons = {
	DevOptIn = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = " Dev branch updates",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 33, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 33, 8, 8 },
		toggleState = false, -- update later in initialize
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			UpdateOrInstall.Dev.enabled = self.toggleState

			if UpdateOrInstall.Dev.enabled then
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
		type = Constants.ButtonTypes.FULL_BORDER,
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
		text = UpdateScreen.Labels.updateAutoText,
		image = Constants.PixelImages.INSTALL_BOX,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
		onClick = function()
			-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
			if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
				-- In such a case, open a browser window with a link for manual download...
				UpdateScreen.openReleaseNotesWindow()
				-- ... and swap back to main Tracker screen. Implied to remind later if they forget to manually update.
				UpdateScreen.remindMeLater()
			else
				UpdateScreen.performAutoUpdate()
			end
		end
	},
	RemindMeLater = {
		text = UpdateScreen.Labels.remindMeText,
		image = Constants.PixelImages.CLOCK,
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
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
			Program.changeScreenView(Program.Screens.NAVIGATION)
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
			button.type = Constants.ButtonTypes.FULL_BORDER
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

	-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
		UpdateScreen.Buttons.UpdateNow.text = "Open download link"
	end
end

function UpdateScreen.performAutoUpdate()
	UpdateScreen.currentState = UpdateScreen.States.IN_PROGRESS
	Program.redraw(true)

	local wasSoundOn
	if Main.IsOnBizhawk() then
		-- Disable Bizhawk sound while the update is in process
		wasSoundOn = client.GetSoundOn()
		client.SetSoundOn(false)
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
		Main.SaveSettings(true)
	else
		UpdateScreen.currentState = UpdateScreen.States.ERROR
	end

	if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
		client.SetSoundOn(wasSoundOn)
	end

	Program.redraw(true)
end

function UpdateScreen.remindMeLater()
	Main.Version.remindMe = true
	Main.Version.showUpdate = false
	Main.SaveSettings(true)
	local screenToShow = Utils.inlineIf(Program.isValidMapLocation(), Program.Screens.TRACKER, Program.Screens.STARTUP)
	Program.changeScreenView(screenToShow)
end

function UpdateScreen.ignoreTheUpdate()
	Main.Version.remindMe = false
	Main.Version.showUpdate = false
	Main.SaveSettings(true)
	local screenToShow = Utils.inlineIf(Program.isValidMapLocation(), Program.Screens.TRACKER, Program.Screens.STARTUP)
	Program.changeScreenView(screenToShow)
end

function UpdateScreen.openReleaseNotesWindow()
	local wasSoundOn
	if Main.IsOnBizhawk() then
		wasSoundOn = client.GetSoundOn()
		client.SetSoundOn(false)
	end

	if Main.OS == "Windows" then
		-- The first parameter is the title of the window, the second is the url
		os.execute(string.format('start "" "%s"', FileManager.Urls.DOWNLOAD))
	else
		-- TODO: Currently don't have a good way to differentiate between the two Unix systems
		local success = os.execute(string.format('open "%s"', FileManager.Urls.DOWNLOAD)) -- Mac OSX
		if not success then
			success = os.execute(string.format('xdg-open "%s"', FileManager.Urls.DOWNLOAD)) -- Linux
			if not success then
				Main.DisplayError("Check the Lua Console for a link to the Tracker's Release Notes.")
				print(string.format("> Release Notes: %s", FileManager.Urls.DOWNLOAD))
			end
		end
	end

	if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
		client.SetSoundOn(wasSoundOn)
	end
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
		titleText = "Tracker Update Check?"
	else
		titleText = UpdateScreen.Labels.title
	end
	Drawing.drawText(topBox.x + 12, textLineY, titleText:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
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
			if button.image ~= nil then
				local x = button.box[1]
				local y = button.box[2]
				local holdText = button.text

				button.text = ""
				Drawing.drawButton(button, botBox.shadow)
				button.text = holdText
				Drawing.drawText(x + 17, y + 2, button.text, Theme.COLORS[button.textColor], botBox.shadow)

				-- TODO: Eventually make the Draw Button more flexible for centering its contents
				if button.image == Constants.PixelImages.INSTALL_BOX then
					y = y + 2
					x = x + 1
				elseif button.image == Constants.PixelImages.CLOCK then
					y = y + 1
					x = x + 1
				end
				Drawing.drawImageAsPixels(button.image, x + 4, y + 2, { Theme.COLORS[button.boxColors[1]] }, botBox.shadow)
			else
				Drawing.drawButton(button, botBox.shadow)
			end
		end
	end
end
UpdateScreen = {
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

local columnOffsetX = 73
UpdateScreen.Buttons = {
	CurrentVersion = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.UpdateScreen.VersionCurrent .. ":" end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, Constants.SCREEN.MARGIN + 13, 50, 11 },
		draw = function(self, shadowcolor)
			local offsetX = self.box[1] + columnOffsetX
			Drawing.drawText(offsetX, self.box[2], Main.TrackerVersion, Theme.COLORS[self.textColor], shadowcolor)
		end,
	},
	LatestVersion = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.UpdateScreen.VersionLatest .. ":" end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, Constants.SCREEN.MARGIN + 25, 50, 11 },
		draw = function(self, shadowcolor)
			local offsetX = self.box[1] + columnOffsetX
			Drawing.drawText(offsetX, self.box[2], Main.Version.latestAvailable, Theme.COLORS[self.textColor], shadowcolor)

			if not Main.isOnLatestVersion() then
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
			if UpdateScreen.showNotes then
				return Resources.UpdateScreen.ButtonHide
			else
				return Resources.UpdateScreen.ButtonShow
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + columnOffsetX + 2, Constants.SCREEN.MARGIN + 39, 28, 11 },
		onClick = function(self)
			UpdateScreen.showNotes = not UpdateScreen.showNotes
			if UpdateScreen.showNotes and #UpdateScreen.Pager.Notes == 0 then
				UpdateScreen.buildOutPagedButtons()
			end
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
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15, Constants.SCREEN.MARGIN + 60, 110, 16 },
		isVisible = function(self) return UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK end,
		onClick = function(self)
			-- Don't check for updates if they've already been checked while on this screen (resets after clicking Back)
			if self.updateStatus == "Unchecked" then
				Main.CheckForVersionUpdate(true)
				StartupScreen.refreshButtons()
			end

			if not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				self.updateStatus = "Unavailable"
				self.textColor = "Intermediate text"
				self.image = Constants.PixelImages.CLOSE
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
			elseif Options["Dev branch updates"] then
				return Resources.UpdateScreen.ButtonInstallFromDev
			else
				return Resources.UpdateScreen.ButtonInstallNow
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 73, 90, 16 },
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
		onClick = function(self)
			if not UpdateScreen.isUpdateSupported() then
				-- In such a case, open a browser window with a link for manual download...
				Utils.openBrowserWindow(FileManager.Urls.DOWNLOAD, Resources.UpdateScreen.MessageCheckConsole)
				-- ... and swap back to main Tracker screen. Default to remind later if they forget to manually update.
				-- Main.Version.remindMe = true -- Temporarily disabled
				UpdateScreen.exitScreen()
			else
				UpdateScreen.beginAutoUpdate()
			end
		end
	},
	IgnoreUpdate = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.CLOSE,
		getText = function(self) return Resources.UpdateScreen.ButtonIgnoreUpdate end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 25, Constants.SCREEN.MARGIN + 95, 90, 16 },
		isVisible = function() return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED end,
		onClick = function() UpdateScreen.exitScreenAndRemindMe(false) end
	},
	DevOptIn = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Dev branch updates",
		getText = function(self) return " " .. Resources.UpdateScreen.CheckboxDevBranch end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 137, 98, 10 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 137, 8, 8 },
		toggleState = false, -- update later in initialize
		isVisible = function(self) return UpdateScreen.currentState == UpdateScreen.States.NOT_UPDATED or UpdateScreen.currentState == UpdateScreen.States.NEEDS_CHECK end,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			UpdateOrInstall.Dev.enabled = Options[self.optionKey]
			-- If option changes from OFF to ON (always allow updates for dev) or an update is available
			if self.toggleState or not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				UpdateScreen.currentState = UpdateScreen.States.NEEDS_CHECK
			end
			Program.redraw(true)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		-- Don't allow navigating off of this page if an update is in progress
		if not Drawing.allowCachedImages then return end
		UpdateScreen.exitScreenAndRemindMe(true)
	end),
}

UpdateScreen.Pager = {
	Notes = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.ordinal < b.ordinal end,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Notes, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 10 -- 20px for buttons
		local totalPages = Utils.gridAlign(self.Notes, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local buffer = Utils.inlineIf(self.currentPage > 9, "", " ") .. Utils.inlineIf(self.totalPages > 9, "", " ")
		return buffer .. string.format("%s %s/%s", Resources.AllScreens.Page, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
}
UpdateScreen.Pager.Buttons = {
	OverlayViewOnline = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.UpdateScreen.ButtonViewOnline end,
		box = { 3, Constants.SCREEN.HEIGHT - 15, 55, 11, },
		isVisible = function() return UpdateScreen.showNotes end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.DOWNLOAD, Resources.UpdateScreen.MessageCheckConsole)
		end
	},
	OverlayCurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return UpdateScreen.Pager:getPageText() end,
		box = { 98, Constants.SCREEN.HEIGHT - 14, 50, 10, },
		isVisible = function() return UpdateScreen.showNotes and UpdateScreen.Pager.totalPages > 1 end,
	},
	OverlayPrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { 88, Constants.SCREEN.HEIGHT - 13, 10, 10, },
		isVisible = function() return UpdateScreen.showNotes and UpdateScreen.Pager.totalPages > 1 end,
		onClick = function(self) UpdateScreen.Pager:prevPage() end
	},
	OverlayNextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { 148, Constants.SCREEN.HEIGHT - 13, 10, 10, },
		isVisible = function() return UpdateScreen.showNotes and UpdateScreen.Pager.totalPages > 1 end,
		onClick = function(self) UpdateScreen.Pager:nextPage() end
	},
	OverlayClose = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.AllScreens.Close end,
		box = { 206, Constants.SCREEN.HEIGHT - 15, 30, 11, },
		isVisible = function() return UpdateScreen.showNotes end,
		onClick = function(self)
			UpdateScreen.Pager.currentPage = 1
			UpdateScreen.showNotes = false
			Program.redraw(true)
		end
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
	-- Main.Version.remindMe = shouldRemindMe -- Temporarily disabled
	Main.Version.showUpdate = false
	-- Main.Version.updateAfterRestart = false -- Currently unused
	Main.SaveSettings(true)
	UpdateScreen.Buttons.CheckForUpdates:reset()
	UpdateScreen.showNotes = false
	UpdateScreen.Pager.currentPage = 1
	Program.changeScreenView(NavigationMenu)
end

-- These buttons are only displayed when 'showNotes' is enabled, and input checks are performed separately
function UpdateScreen.buildOutPagedButtons()
	if #Main.Version.releaseNotes == 0 then
		Main.updateReleaseNotes()
	end

	UpdateScreen.Pager.Notes = {}
	for i, note in ipairs(Main.Version.releaseNotes) do
		local wrappedNote = Utils.getWordWrapLines(note, 56)
		local noteHeight = #wrappedNote * Constants.SCREEN.LINESPACING

		local noteBox = {
			type = Constants.ButtonTypes.NO_BORDER,
			textColor = "Default text",
			notelines = wrappedNote,
			ordinal = i,
			dimensions = { width = Constants.SCREEN.WIDTH - 20, height = noteHeight, },
			isVisible = function(self) return UpdateScreen.Pager.currentPage == self.pageVisible end,
			draw = function(self, shadowcolor)
				local yOffset = 0
				for _, line in pairs(wrappedNote) do
					Drawing.drawText(self.box[1], self.box[2] + yOffset, line, Theme.COLORS[self.textColor], shadowcolor)
					yOffset = yOffset + Constants.SCREEN.LINESPACING
				end
			end,
		}
		table.insert(UpdateScreen.Pager.Notes, noteBox)
	end

	local x = 4
	local y = 18
	local colSpacer = 1
	local rowSpacer = 4
	UpdateScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)
	return true
end

-- Currently unused
-- function UpdateScreen.prepareForUpdateAfterRestart()
-- 	UpdateScreen.currentState = UpdateScreen.States.AFTER_RESTART
-- 	Main.Version.updateAfterRestart = true
-- 	Main.SaveSettings(true)
-- 	Program.redraw(true)
-- end

function UpdateScreen.beginAutoUpdate()
	local imageCacheClearDelay = 60 -- 1 seconds
	local updateStartDelay = 60 * 5 + 2 -- about 5 seconds
	UpdateScreen.currentState = UpdateScreen.States.IN_PROGRESS
	Program.redraw(true)

	-- Don't bother saving tracked data if the player doesn't have a Pokemon yet
	if Options["Auto save tracked game data"] and Tracker.getPokemon(1, true) ~= nil then
		Tracker.saveData()
	end

	if Main.IsOnBizhawk() then
		-- Required to make Bizhawk release images so that they can be replaced
		Drawing.allowCachedImages = false
		Drawing.clearImageCache(imageCacheClearDelay)
	else
		updateStartDelay = 15
	end
	-- After a small delay, then continue on with the rest of the update. During this time, images can't be drawn on the Tracker to prevent them from re-caching
	Program.addFrameCounter("PerformUpdate", updateStartDelay, function()
		if Main.IsOnBizhawk() then
			Drawing.clearImageCache() -- doing this an extra time to be safe
		end
		Main.updateRequested = true
	end, 1, true)
end

-- Don't call this function inside of the Main loop's xpcall. Must do it outside.
function UpdateScreen.performUpdate()
	Main.updateRequested = nil
	Utils.tempDisableBizhawkSound()

	if UpdateOrInstall.performParallelUpdate() then
		UpdateScreen.currentState = UpdateScreen.States.SUCCESS
		Main.Version.showUpdate = false
		-- Main.Version.updateAfterRestart = false -- Currently unused
		Main.Version.showReleaseNotes = true
		Main.SaveSettings(true)
		Main.ExitSafely(false)
	else
		UpdateScreen.currentState = UpdateScreen.States.ERROR
	end

	Drawing.allowCachedImages = true
	Utils.tempEnableBizhawkSound()

	-- With the changes to parallel updates only working after a restart, if the update is successful, simply restart the Tracker scripts
	if UpdateScreen.currentState == UpdateScreen.States.SUCCESS then
		-- Close any open pop-up forms
		Program.destroyActiveForm()
		Drawing.AnimatedPokemon:destroy()
		-- Restart the Tracker code
		IronmonTracker.startTracker()
	else
		Program.redraw(true)
	end
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

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.UpdateScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- TOP BORDER BOX
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	local updateStatusMsg
	if UpdateScreen.currentState == UpdateScreen.States.IN_PROGRESS then
		updateStatusMsg = Resources.UpdateScreen.MessageInProgress
	elseif UpdateScreen.currentState == UpdateScreen.States.AFTER_RESTART then
		updateStatusMsg = Resources.UpdateScreen.MessageRequireRestart
	elseif UpdateScreen.currentState == UpdateScreen.States.SUCCESS then
		updateStatusMsg = ""
	elseif UpdateScreen.currentState == UpdateScreen.States.ERROR then
		updateStatusMsg = (Resources.UpdateScreen.MessageError or "") .. ":"
	end

	-- If an update was attempted, show status messages about it
	textLineY = textLineY + 52
	if UpdateScreen.currentState ~= UpdateScreen.States.NOT_UPDATED and UpdateScreen.currentState ~= UpdateScreen.States.NEEDS_CHECK then
		local wrappedDesc = Utils.getWordWrapLines(updateStatusMsg or "", 31)
		for _, line in pairs(wrappedDesc) do
			Drawing.drawText(topBox.x + 4, textLineY, line, Theme.COLORS["Intermediate text"], topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING
		end
		if UpdateScreen.currentState == UpdateScreen.States.ERROR then
			textLineY = textLineY + 2
			Drawing.drawText(topBox.x + 24, textLineY, FileManager.Files.UPDATE_OR_INSTALL or "", topBox.text, topBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING
		end
	end

	-- Draw all buttons
	for _, button in pairs(UpdateScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

function UpdateScreen.drawReleaseNotesOverlay()
	local overlay = {
		x = 0,
		y = 0,
		width = Constants.SCREEN.WIDTH - 1,
		height = Constants.SCREEN.HEIGHT - 1,
		textColor = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}

	-- Draw the main border and background
	gui.drawRectangle(overlay.x, overlay.y, overlay.width, overlay.height, overlay.border, overlay.fill)

	-- Draw header text
	local headerText = string.format("%s  v%s", Utils.toUpperUTF8(Resources.UpdateScreen.LabelRelease), Main.Version.latestAvailable)
	Drawing.drawHeader(overlay.x + 1, overlay.y, headerText, Theme.COLORS["Intermediate text"], overlay.shadow)

	-- Draw all release notes
	for _, note in pairs(UpdateScreen.Pager.Notes) do
		Drawing.drawButton(note, overlay.shadow)
	end
	-- Draw all buttons
	for _, button in pairs(UpdateScreen.Pager.Buttons) do
		Drawing.drawButton(button, overlay.shadow)
	end
end
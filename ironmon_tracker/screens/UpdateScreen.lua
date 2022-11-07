UpdateScreen = {
	Labels = {
		title = "Tracker Update Available!",
		currentVersion = "Current version:",
		newVersion = "New version available:",
		questionHeader = "What would you like to do?",
		updateAutoText = "Update automatically",
		releaseNotesText = "View release notes",
		remindMeText = "Remind me later",
		ignoreUpdateText = "Ignore this update",
	},
}

UpdateScreen.Buttons = {
	UpdateNow = {
		text = UpdateScreen.Labels.updateAutoText,
		onClick = function() UpdateScreen.performAutoUpdate() end
	},
	ViewReleaseNotes = {
		text = UpdateScreen.Labels.releaseNotesText,
		onClick = function() UpdateScreen.openReleaseNotesWindow() end
	},
	RemindMeLater = {
		text = UpdateScreen.Labels.remindMeText,
		onClick = function() UpdateScreen.remindMeLater() end
	},
	IgnoreUpdate = {
		text = UpdateScreen.Labels.ignoreUpdateText,
		onClick = function() UpdateScreen.ignoreTheUpdate() end
	},
}

UpdateScreen.OrderedMenuList = {
	UpdateScreen.Buttons.UpdateNow,
	UpdateScreen.Buttons.ViewReleaseNotes,
	UpdateScreen.Buttons.RemindMeLater,
	UpdateScreen.Buttons.IgnoreUpdate,
}

function UpdateScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15
	local startY = Constants.SCREEN.MARGIN + 60
	for _, button in ipairs(UpdateScreen.OrderedMenuList) do
		button.type = Constants.ButtonTypes.FULL_BORDER
		button.box = { startX, startY, 110, 16 }
		button.textColor = "Lower box text"
		button.boxColors = { "Lower box border", "Lower box background" }
		startY = startY + 21
	end
end

function UpdateScreen.performAutoUpdate()
	-- TODO: Maybe build out the bat file first, write to file, then execute it, then delete the bat file?

	-- Likely turn off the sound during this

	-- os.execute("Update Tracker -Forced.bat")
	print("> Updating now...")

	-- Then somehow reload the tracker script
end

function UpdateScreen.openReleaseNotesWindow()
	if Main.OS == "Windows" then
		os.execute("start " .. Constants.Release.DOWNLOAD_URL)
	end
end

function UpdateScreen.remindMeLater()
	Main.Version.remindMe = true
	Main.SaveSettings(true)
	Program.changeScreenView(Program.Screens.STARTUP)
end

function UpdateScreen.ignoreTheUpdate()
	Main.Version.remindMe = false
	Main.SaveSettings(true)
	Program.changeScreenView(Program.Screens.STARTUP)
end

-- DRAWING FUNCTIONS
function UpdateScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = 62,
		text = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height + 13,
		width = topBox.width,
		height = 75,
		text = Theme.COLORS["Lower box text"],
		border = Theme.COLORS["Lower box border"],
		fill = Theme.COLORS["Lower box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"]),
	}
	local topcolX = topBox.x + 60
	local textLineY = topBox.y + 1
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- TOP BORDER BOX
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	Drawing.drawText(topBox.x + 2, textLineY, UpdateScreen.Labels.title:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing

	Drawing.drawText(topBox.x + 2, textLineY, UpdateScreen.Labels.currentVersion, topBox.text, topBox.shadow)
	Drawing.drawText(topcolX, textLineY, Main.TrackerVersion, topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	Drawing.drawText(topBox.x + 2, textLineY, UpdateScreen.Labels.newVersion, topBox.text, topBox.shadow)
	Drawing.drawText(topcolX, textLineY, Main.Version.latestAvailable, Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing

	-- HEADER DIVIDER
	local bgShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(botBox.x + 1, botBox.y - 11, UpdateScreen.Labels.questionHeader, Theme.COLORS["Header text"], bgShadow)

	-- BOTTOM BORDER BOX
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)
	textLineY = botBox.y + 1

	for _, button in ipairs(UpdateScreen.OrderedMenuList) do
		Drawing.drawButton(button, botBox.shadow)
	end
end
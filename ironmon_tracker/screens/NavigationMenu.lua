NavigationMenu = {
	headerText = "Tracker Settings",
	textColor = "Default text",
	borderColor = "Upper box border",
	boxFillColor = "Upper box background",
	showCredits = false,
}

NavigationMenu.Buttons = {
	VersionInfo = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "v" .. tostring(Main.TrackerVersion),
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN - 2, 22, 10 },
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function(self) UpdateScreen.openReleaseNotesWindow() end
	},
	SetupAndOptions = {
		text = "Setup",
		image = Constants.PixelImages.NOTEPAD,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.SETUP) end
	},
	Extras = {
		text = "Extras",
		image = Constants.PixelImages.POKEBALL,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.EXTRAS) end
	},
	GameplaySettings = {
		text = "Gameplay",
		image = Constants.PixelImages.PHYSICAL,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.GAME_SETTINGS) end
	},
	QuickloadSettings = {
		text = "Quickload",
		image = Constants.PixelImages.CLOCK,
		isVisible = function() return not NavigationMenu.showCredits end,
		updateText = function (self)
			if Options[QuickloadScreen.OptionKeys[1]] or Options[QuickloadScreen.OptionKeys[2]] then
				self.textColor = NavigationMenu.textColor
			else
				-- If neither quickload option is enabled, then highlight it to draw user's attention
				self.textColor = "Intermediate text"
			end
		end,
		onClick = function() Program.changeScreenView(Program.Screens.QUICKLOAD) end
	},
	ThemeCustomization = {
		text = "Theme",
		image = Constants.PixelImages.NOTEPAD,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function()
			Theme.refreshThemePreview()
			Program.changeScreenView(Program.Screens.THEME)
		end
	},
	ManageTrackedData = {
		text = "Data",
		image = Constants.PixelImages.GEAR,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.MANAGE_DATA) end
	},
	CheckForUpdates = {
		text = "Update",
		image = Constants.PixelImages.INSTALL_BOX,
		isVisible = function(self) return not NavigationMenu.showCredits end,
		updateText = function(self)
			if Main.isOnLatestVersion() then
				self.textColor = NavigationMenu.textColor
			else
				self.textColor = "Positive text"
			end
		end,
		onClick = function(self)
			if Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NEEDS_CHECK
			else
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			end
			Program.changeScreenView(Program.Screens.UPDATE)
		end
	},
	ViewStats = {
		text = "Stats",
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.STATS) end
	},
	MirageButton = {
		text = "It's a secret...",
		image = Constants.PixelImages.POKEBALL,
		type = Constants.ButtonTypes.FULL_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15, Constants.SCREEN.MARGIN + 110, 110, 15 },
		timesClicked = 0,
		canBeSeenToday = false,
		isVisible = function(self) return self.canBeSeenToday and self.timesClicked <= 3 and not NavigationMenu.showCredits end,
		onClick = function(self)
			-- A non-functional button only appears very rarely, and will disappear after it's clicked a few times
			self.timesClicked = self.timesClicked + 1
			self.textColor = Utils.inlineIf(self.timesClicked % 2 == 0, NavigationMenu.textColor, "Intermediate text")
			Program.redraw(true)
		end
	},
	Credits = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Credits",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 32, 11 },
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function(self)
			NavigationMenu.showCredits = true
			Program.redraw(true)
		end
	},
	Help = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Help",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 41, Constants.SCREEN.MARGIN + 135, 23, 11 },
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function(self) NavigationMenu.openWikiBrowserWindow() end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			if NavigationMenu.showCredits then
				NavigationMenu.showCredits = false
				Program.redraw(true)
			else
				if Program.isValidMapLocation() then
					Program.changeScreenView(Program.Screens.TRACKER)
				else
					Program.changeScreenView(Program.Screens.STARTUP)
				end
			end
		end
	},
}

NavigationMenu.OrderedMenuList = {
	NavigationMenu.Buttons.SetupAndOptions,
	NavigationMenu.Buttons.Extras,
	NavigationMenu.Buttons.GameplaySettings,
	NavigationMenu.Buttons.QuickloadSettings,
	NavigationMenu.Buttons.ThemeCustomization,
	NavigationMenu.Buttons.ManageTrackedData,
	NavigationMenu.Buttons.ViewStats,
	NavigationMenu.Buttons.CheckForUpdates,
}

function NavigationMenu.initialize()
	local btnWidth = 63
	local btnHeight = 15
	local spacer = 6
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 16 + spacer
	local leftCol = true
	for _, button in ipairs(NavigationMenu.OrderedMenuList) do
		button.type = Constants.ButtonTypes.FULL_BORDER
		button.box = { startX, startY, btnWidth, btnHeight }

		if leftCol then
			startX = startX + btnWidth + spacer
		else
			startY = startY + btnHeight + spacer
			startX = startX - btnWidth - spacer
		end
		leftCol = not leftCol
	end

	table.insert(NavigationMenu.OrderedMenuList, NavigationMenu.Buttons.MirageButton)

	for _, button in pairs(NavigationMenu.Buttons) do
		button.textColor = NavigationMenu.textColor
		button.boxColors = { NavigationMenu.borderColor, NavigationMenu.boxFillColor }
	end

	NavigationMenu.Buttons.VersionInfo.textColor = "Header text"
	if string.len(NavigationMenu.Buttons.VersionInfo.text or "") > 6 then
		NavigationMenu.Buttons.VersionInfo.box[1] = NavigationMenu.Buttons.VersionInfo.box[1] - 4
	end
	NavigationMenu.Buttons.QuickloadSettings:updateText()
	NavigationMenu.Buttons.CheckForUpdates:updateText()

	-- Yet another fun Easter Egg that shows up only once in a while
	if math.random(256) == 1 then
		NavigationMenu.Buttons.MirageButton.text = Utils.inlineIf(GameSettings.game == 3, "Reveal Mew by Truck", "Mirage Island Portal")
		NavigationMenu.Buttons.MirageButton.canBeSeenToday = true
	end
end

function NavigationMenu.openWikiBrowserWindow()
	local wasSoundOn
	if Main.IsOnBizhawk() then
		wasSoundOn = client.GetSoundOn()
		client.SetSoundOn(false)
	end

	if Main.OS == "Windows" then
		-- The first parameter is the title of the window, the second is the url
		os.execute(string.format('start "" "%s"', FileManager.Urls.WIKI))
	else
		-- TODO: Currently don't have a good way to differentiate between the two Unix systems
		local success = os.execute(string.format('open "%s"', FileManager.Urls.WIKI)) -- Mac OSX
		if not success then
			success = os.execute(string.format('xdg-open "%s"', FileManager.Urls.WIKI)) -- Linux
			if not success then
				Main.DisplayError("Check the Lua Console for a link to the Tracker's Help Wiki.")
				print(string.format("> Github Wiki: %s", FileManager.Urls.WIKI))
			end
		end
	end

	if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
		client.SetSoundOn(wasSoundOn)
	end
end

-- DRAWING FUNCTIONS
function NavigationMenu.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[NavigationMenu.boxFillColor])

	if NavigationMenu.showCredits then
		NavigationMenu.drawCredits()
		return
	end

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[NavigationMenu.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, NavigationMenu.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[NavigationMenu.borderColor], Theme.COLORS[NavigationMenu.boxFillColor])

	-- Draw all buttons, manually
	for _, button in pairs(NavigationMenu.Buttons) do
		if button.isVisible == nil or button:isVisible() then
			if button.image ~= nil then
				local x = button.box[1]
				local y = button.box[2]
				local holdText = button.text

				button.text = ""
				Drawing.drawButton(button, shadowcolor)
				button.text = holdText
				Drawing.drawText(x + 16, y + 2, button.text, Theme.COLORS[button.textColor], shadowcolor)

				-- TODO: Eventually make the Draw Button more flexible for centering its contents
				if button.image == Constants.PixelImages.GEAR then
					y = y + 2
					x = x + 1
				elseif button.image == Constants.PixelImages.PHYSICAL then
					y = y + 3
					x = x + 1
				elseif button.image == Constants.PixelImages.MAGNIFYING_GLASS then
					y = y + 1
				elseif button.image == Constants.PixelImages.INSTALL_BOX then
					y = y + 2
					x = x + 1
				elseif button.image == Constants.PixelImages.POKEBALL then
					x = x - 1
				elseif button.image == Constants.PixelImages.CLOCK then
					y = y + 1
				end
				Drawing.drawImageAsPixels(button.image, x + 4, y + 2, { Theme.COLORS[NavigationMenu.borderColor], Theme.COLORS[NavigationMenu.boxFillColor], Theme.COLORS[NavigationMenu.boxFillColor] }, shadowcolor)
			else
				Drawing.drawButton(button, shadowcolor)
			end
		end
	end
end

function NavigationMenu.drawCredits()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[NavigationMenu.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxColX = topboxX + 58
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- Draw header text
	local creditsHeader = "Ironmon Tracker"
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 29, Constants.SCREEN.MARGIN - 2, creditsHeader:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[NavigationMenu.borderColor], Theme.COLORS[NavigationMenu.boxFillColor])

	local offsetX = topboxX + 2
	local offsetY = topboxY + 8

	Drawing.drawText(offsetX, offsetY, "Created by:", Theme.COLORS[NavigationMenu.textColor], shadowcolor)
	Drawing.drawText(topboxColX, offsetY, Main.CreditsList.CreatedBy, Theme.COLORS[NavigationMenu.textColor], shadowcolor)
	local espeonImage = FileManager.buildImagePath(Options.IconSetMap["1"].folder, "196", Options.IconSetMap["1"].extension)
	gui.drawImage(espeonImage, topboxColX + 40, offsetY - 13, 32, 32)
	offsetY = offsetY + linespacing + 10

	Drawing.drawText(offsetX, offsetY, "Contributors: ", Theme.COLORS[NavigationMenu.textColor], shadowcolor)
	offsetY = offsetY + linespacing + 1

	-- Draw Contributors List
	offsetX = offsetX + 4
	topboxColX = topboxColX
	for i=1, #Main.CreditsList.Contributors, 2 do
		Drawing.drawText(offsetX, offsetY, Main.CreditsList.Contributors[i], Theme.COLORS[NavigationMenu.textColor], shadowcolor)
		if Main.CreditsList.Contributors[i + 1] ~= nil then
			Drawing.drawText(topboxColX, offsetY, Main.CreditsList.Contributors[i + 1], Theme.COLORS[NavigationMenu.textColor], shadowcolor)
		end
		offsetY = offsetY + linespacing
	end

	Drawing.drawButton(NavigationMenu.Buttons.Back, shadowcolor)
end
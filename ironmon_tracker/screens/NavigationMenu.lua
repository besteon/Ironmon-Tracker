NavigationMenu = {
	Colors = {
		textColor = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	showCredits = false,
}

NavigationMenu.Buttons = {
	VersionInfo = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "v" .. tostring(Main.TrackerVersion) end,
		textColor = "Header text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN - 2, 22, 10 },
		isVisible = function() return not NavigationMenu.showCredits end,
		updateSelf = function(self)
			local width = Utils.calcWordPixelLength(self:getText())
			self.box[1] = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - width - 3
		end,
	},
	SetupAndOptions = {
		getText = function(self) return Resources.NavigationMenu.ButtonSetup end,
		image = Constants.PixelImages.NOTEPAD,
		index = 1,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(SetupScreen) end
	},
	Extras = {
		getText = function(self) return Resources.NavigationMenu.ButtonExtras end,
		image = Constants.PixelImages.POKEBALL,
		index = 2,
		iconColors = { NavigationMenu.Colors.textColor, NavigationMenu.Colors.boxFill, NavigationMenu.Colors.boxFill, },
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(ExtrasScreen) end
	},
	GameplaySettings = {
		getText = function(self) return Resources.NavigationMenu.ButtonGameplay end,
		image = Constants.PixelImages.PHYSICAL,
		index = 3,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(GameOptionsScreen) end
	},
	QuickloadSettings = {
		getText = function(self) return Resources.NavigationMenu.ButtonQuickload end,
		image = Constants.PixelImages.CLOCK,
		index = 4,
		isVisible = function() return not NavigationMenu.showCredits end,
		updateSelf = function (self)
			if Options["Use premade ROMs"] or Options["Generate ROM each time"] then
				self.textColor = NavigationMenu.Colors.textColor
			else
				-- If neither quickload option is enabled, then highlight it to draw user's attention
				self.textColor = "Intermediate text"
			end
		end,
		onClick = function() Program.changeScreenView(QuickloadScreen) end
	},
	ThemeCustomization = {
		getText = function(self) return Resources.NavigationMenu.ButtonTheme end,
		image = Constants.PixelImages.SPARKLES,
		index = 5,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function()
			Theme.refreshThemePreview()
			Program.changeScreenView(Theme)
		end
	},
	LanguageSettings = {
		getText = function(self) return Resources.NavigationMenu.ButtonLanguage end,
		image = Constants.PixelImages.LANGUAGE_LETTERS,
		index = 6,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(LanguageScreen) end
	},
	CheckForUpdates = {
		getText = function(self)
			if Main.isOnLatestVersion() then
				return Resources.NavigationMenu.ButtonUpdate
			else
				return string.format("%s *", Resources.NavigationMenu.ButtonUpdate)
			end
		end,
		image = Constants.PixelImages.INSTALL_BOX,
		index = 7,
		isVisible = function(self) return not NavigationMenu.showCredits end,
		updateSelf = function(self)
			if Main.isOnLatestVersion() then
				self.textColor = NavigationMenu.Colors.textColor
			else
				self.textColor = "Positive text"
			end
		end,
		onClick = function(self)
			-- Always show the update menu if using a dev build, to allow updating from dev branch
			if UpdateOrInstall.Dev.enabled or not Main.isOnLatestVersion() then
				UpdateScreen.currentState = UpdateScreen.States.NOT_UPDATED
			else
				UpdateScreen.currentState = UpdateScreen.States.NEEDS_CHECK
			end
			Program.changeScreenView(UpdateScreen)
		end
	},
	StreamerTools = {
		getText = function(self) return Resources.NavigationMenu.ButtonStreaming end,
		image = Constants.PixelImages.SPECIAL,
		index = 8,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(StreamerScreen) end
	},
	Extensions = {
		getText = function(self) return Resources.NavigationMenu.ButtonExtensions end,
		image = Constants.PixelImages.EXTENSIONS,
		index = 9,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function()
			CustomExtensionsScreen.buildOutPagedButtons()
			Program.changeScreenView(CustomExtensionsScreen)
		end
	},
	MirageButton = {
		getText = function(self)
			if GameSettings.game == 3 then
				return "Reveal Mew by Truck"
			else
				return "Mirage Island Portal"
			end
		end,
		image = Constants.PixelImages.POKEBALL,
		type = Constants.ButtonTypes.ICON_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15, Constants.SCREEN.MARGIN + 110, 110, 15 },
		timesClicked = 0,
		canBeSeenToday = false,
		isVisible = function(self) return self.canBeSeenToday and self.timesClicked <= 3 and not NavigationMenu.showCredits end,
		onClick = function(self)
			-- A non-functional button only appears very rarely, and will disappear after it's clicked a few times
			self.timesClicked = self.timesClicked + 1
			self.textColor = Utils.inlineIf(self.timesClicked % 2 == 0, NavigationMenu.Colors.textColor, "Intermediate text")
			Program.redraw(true)
		end
	},
	Credits = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.NavigationMenu.ButtonCredits end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 32, 11 },
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function(self)
			NavigationMenu.showCredits = true
			Program.redraw(true)
		end
	},
	Help = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.NavigationMenu.ButtonHelp end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 41, Constants.SCREEN.MARGIN + 135, 23, 11 },
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function(self)
			Utils.openBrowserWindow(FileManager.Urls.WIKI, Resources.NavigationMenu.MessageCheckConsole)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		if NavigationMenu.showCredits then
			NavigationMenu.showCredits = false
			Program.redraw(true)
		else
			if Program.isValidMapLocation() then
				Program.changeScreenView(TrackerScreen)
			else
				Program.changeScreenView(StartupScreen)
			end
		end
	end),
}

function NavigationMenu.initialize()
	NavigationMenu.showCredits = false

	local btnWidth = 63
	local btnHeight = 16
	local spacer = 6
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 12 + spacer
	for i, button in ipairs(Utils.getSortedList(NavigationMenu.Buttons)) do
		button.type = Constants.ButtonTypes.ICON_BORDER
		button.box = { startX, startY, btnWidth, btnHeight }

		if i % 2 == 1 then -- left column
			startX = startX + btnWidth + spacer
		else -- right column
			startY = startY + btnHeight + spacer
			startX = startX - btnWidth - spacer
		end
	end

	for _, button in pairs(NavigationMenu.Buttons) do
		if button.textColor == nil then
			button.textColor = NavigationMenu.Colors.textColor
		end
		if button.boxColors == nil then
			button.boxColors = { NavigationMenu.Colors.border, NavigationMenu.Colors.boxFill }
		end
	end

	-- Yet another fun Easter Egg that shows up only once in a while
	if math.random(256) == 1 then
		NavigationMenu.Buttons.MirageButton.canBeSeenToday = true
		-- Disabling to allow room for more buttons
		NavigationMenu.Buttons.MirageButton.canBeSeenToday = false
	end

	NavigationMenu.refreshButtons()
end

function NavigationMenu.refreshButtons()
	for _, button in pairs(NavigationMenu.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

-- USER INPUT FUNCTIONS
function NavigationMenu.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, NavigationMenu.Buttons)
end

-- DRAWING FUNCTIONS
function NavigationMenu.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[NavigationMenu.Colors.boxFill])

	if NavigationMenu.showCredits then
		NavigationMenu.drawCredits()
		return
	end

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[NavigationMenu.Colors.boxFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.NavigationMenu.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[NavigationMenu.Colors.border], Theme.COLORS[NavigationMenu.Colors.boxFill])

	-- Draw all buttons, manually
	for _, button in pairs(NavigationMenu.Buttons) do
		if button == NavigationMenu.Buttons.VersionInfo then
			Drawing.drawButton(button, headerShadow)
		else
			Drawing.drawButton(button, shadowcolor)
		end
	end
end

function NavigationMenu.drawCredits()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[NavigationMenu.Colors.boxFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxColX = topboxX + 57
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- Draw header text
	local creditsHeader = Utils.toUpperUTF8(Resources.StartupScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 29, Constants.SCREEN.MARGIN - 2, creditsHeader, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[NavigationMenu.Colors.border], Theme.COLORS[NavigationMenu.Colors.boxFill])

	local offsetX = topboxX + 2
	local offsetY = topboxY + 8

	local createdByText = string.format("%s:", Resources.NavigationMenu.CreditsCreatedBy)
	Drawing.drawText(offsetX, offsetY, createdByText, Theme.COLORS[NavigationMenu.Colors.textColor], shadowcolor)
	Drawing.drawText(topboxColX, offsetY, Main.CreditsList.CreatedBy, Theme.COLORS[NavigationMenu.Colors.textColor], shadowcolor)

	local espeonImage = FileManager.buildImagePath(Options.IconSetMap["1"].folder, "196", Options.IconSetMap["1"].extension)
	gui.drawImage(espeonImage, topboxColX + 41, offsetY - 13, 32, 32)
	offsetY = offsetY + linespacing + 10

	local contributorText = string.format("%s:", Resources.NavigationMenu.CreditsContributors)
	Drawing.drawText(offsetX, offsetY, contributorText, Theme.COLORS[NavigationMenu.Colors.textColor], shadowcolor)
	offsetY = offsetY + linespacing + 1

	-- Draw Contributors List
	offsetX = offsetX + 4
	for i=1, #Main.CreditsList.Contributors, 2 do
		Drawing.drawText(offsetX, offsetY, Main.CreditsList.Contributors[i], Theme.COLORS[NavigationMenu.Colors.textColor], shadowcolor)
		if Main.CreditsList.Contributors[i + 1] ~= nil then
			Drawing.drawText(topboxColX, offsetY, Main.CreditsList.Contributors[i + 1], Theme.COLORS[NavigationMenu.Colors.textColor], shadowcolor)
		end
		offsetY = offsetY + linespacing
	end

	Drawing.drawButton(NavigationMenu.Buttons.Back, shadowcolor)
end
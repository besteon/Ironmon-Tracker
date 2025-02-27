NavigationMenu = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
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
		image = Constants.PixelImages.GEAR,
		index = 1,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(SetupScreen) end
	},
	Extras = {
		getText = function(self) return Resources.NavigationMenu.ButtonExtras end,
		image = Constants.PixelImages.POKEBALL,
		index = 2,
		iconColors = { NavigationMenu.Colors.text, NavigationMenu.Colors.boxFill, NavigationMenu.Colors.boxFill, },
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
				self.textColor = NavigationMenu.Colors.text
			else
				-- If neither quickload option is enabled, then highlight it to draw user's attention
				self.textColor = NavigationMenu.Colors.highlight
			end
		end,
		onClick = function()
			QuickloadScreen.currentTab = QuickloadScreen.Tabs.General
			QuickloadScreen.refreshButtons()
			Program.changeScreenView(QuickloadScreen)
		end
	},
	Notebook = {
		getText = function(self) return Resources.NavigationMenu.ButtonNotebook end,
		image = Constants.PixelImages.NOTEPAD,
		index = 5,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function()
			NotebookIndexScreen.buildScreen()
			Program.changeScreenView(NotebookIndexScreen)
		end
	},
	ThemeCustomization = {
		getText = function(self) return Resources.NavigationMenu.ButtonTheme end,
		image = Constants.PixelImages.SPARKLES,
		index = 6,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function()
			Theme.refreshThemePreview()
			Program.changeScreenView(Theme)
		end
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
				self.textColor = NavigationMenu.Colors.text
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
			-- Change the landing page if there are already some extensions installed, for easier access
			if CustomCode.ExtensionCount > 0 then
				CustomExtensionsScreen.currentTab = CustomExtensionsScreen.Tabs.Extensions
			else
				CustomExtensionsScreen.currentTab = CustomExtensionsScreen.Tabs.General
			end
			Program.changeScreenView(CustomExtensionsScreen)
		end
	},
	LanguageSettings = {
		getText = function(self) return Resources.NavigationMenu.ButtonLanguage end,
		image = Constants.PixelImages.LANGUAGE_LETTERS,
		index = 10,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(LanguageScreen) end
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
			self.textColor = Utils.inlineIf(self.timesClicked % 2 == 0, NavigationMenu.Colors.text, NavigationMenu.Colors.highlight)
			Program.redraw(true)
		end
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 104, Constants.SCREEN.MARGIN + 10, 32, 32 },
		isVisible = function() return NavigationMenu.showCredits end,
		pokemonID = 196, -- Espeon
		getIconId = function(self) return self.pokemonID, SpriteData.Types.Walk end,
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

	-- Draw a helpful reminder on how to use the universal "back" button
	NavigationMenu.Buttons.Back.draw = function(self, shadowcolor)
		local x, y = self.box[1], self.box[2]
		local text = string.format("(%s + %s)", Options.CONTROLS["Previous page"] or "L", Options.CONTROLS["Next page"] or "R")
		local textWidth = Utils.calcWordPixelLength(text)
		local color = Theme.COLORS[self.textColor] - (Drawing.ColorEffects.DARKEN * 2)
		Drawing.drawText(x - textWidth - 1, y - 1, text, color, shadowcolor)
	end

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
			button.textColor = NavigationMenu.Colors.text
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
	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		w = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		h = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[NavigationMenu.Colors.text],
		border = Theme.COLORS[NavigationMenu.Colors.border],
		fill = Theme.COLORS[NavigationMenu.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[NavigationMenu.Colors.boxFill]),
	}

	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(canvas.fill)

	if NavigationMenu.showCredits then
		NavigationMenu.drawCredits(canvas)
		return
	end

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.NavigationMenu.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(canvas.x, canvas.y, canvas.w, canvas.h, canvas.border, canvas.fill)

	-- Draw all buttons, manually
	for _, button in pairs(NavigationMenu.Buttons) do
		if button == NavigationMenu.Buttons.VersionInfo then
			Drawing.drawButton(button, headerShadow)
		else
			Drawing.drawButton(button, canvas.shadow)
		end
	end
end

function NavigationMenu.drawCredits(canvas)
	-- Draw header text
	local creditsHeader = Utils.toUpperUTF8(Resources.StartupScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x + 29, canvas.y - 12, creditsHeader, Theme.COLORS["Header text"], headerShadow)

	-- Draw box
	gui.drawRectangle(canvas.x, canvas.y, canvas.w, canvas.h, Theme.COLORS[NavigationMenu.Colors.border], Theme.COLORS[NavigationMenu.Colors.boxFill])

	Drawing.drawButton(NavigationMenu.Buttons.PokemonIcon, canvas.shadow)

	local textLineY = canvas.y + 4
	local createdByText = string.format("%s:", Resources.NavigationMenu.CreditsCreatedBy)
	Drawing.drawText(canvas.x + 3, textLineY, createdByText, Theme.COLORS[NavigationMenu.Colors.highlight], canvas.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	local colOffsetX = -8 + Utils.getCenteredTextX(Main.CreditsList.CreatedBy, canvas.w)
	Drawing.drawText(canvas.x + colOffsetX, textLineY, Main.CreditsList.CreatedBy, canvas.text, canvas.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 3

	local contributorText = string.format("%s:", Resources.NavigationMenu.CreditsContributors)
	Drawing.drawText(canvas.x + 3, textLineY, contributorText, Theme.COLORS[NavigationMenu.Colors.highlight], canvas.shadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING + 1

	-- Draw Contributors List
	local wrappedDesc = Utils.getWordWrapLines(table.concat(Main.CreditsList.Contributors, ", "), 32)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(canvas.x + 5, textLineY, line, canvas.text, canvas.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING
	end

	Drawing.drawButton(NavigationMenu.Buttons.Back, canvas.shadow)
end
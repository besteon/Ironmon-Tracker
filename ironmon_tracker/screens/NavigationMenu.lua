NavigationMenu = {
	headerText = "Navigation Menu",
	textColor = "Default text",
	borderColor = "Upper box border",
	boxFillColor = "Upper box background",
	showCredits = false,
}

NavigationMenu.Buttons = {
	SetupAndOptions = {
		text = "Tracker Setup",
		image = Constants.PixelImages.NOTEPAD,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.SETUP) end
	},
	GameplaySettings = {
		text = "Gameplay Options",
		image = Constants.PixelImages.PHYSICAL,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.GAME_SETTINGS) end
	},
	ThemeCustomization = {
		text = "Customize Theme",
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.THEME) end
	},
	ManageTrackedData = {
		text = "Manage Tracked Data",
		image = Constants.PixelImages.GEAR,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function() Program.changeScreenView(Program.Screens.MANAGE_DATA) end
	},
	MirageButton = {
		text = "It's a secret...",
		image = Constants.PixelImages.MAP_PINDROP,
		timesClicked = 0,
		canBeSeenToday = false,
		isVisible = function(self) return self.canBeSeenToday and self.timesClicked <= 3 and not NavigationMenu.showCredits end,
		onClick = function(self)
			if not self:isVisible() then return end
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
	VersionInfo = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "Tracker v" .. Main.TrackerVersion,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 43, Constants.SCREEN.MARGIN + 135, 56, 10 },
		timesClicked = 0,
		isVisible = function() return not NavigationMenu.showCredits end,
		onClick = function(self)
			self.timesClicked = self.timesClicked + 1
			if self.timesClicked % 2 == 0 then
				self.textColor = NavigationMenu.textColor
			elseif self.timesClicked % 21 == 0 then
				self.textColor = "Positive text"
			else
				self.textColor = "Intermediate text"
			end
			Program.redraw(true)
		end
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
				NavigationMenu.Buttons.VersionInfo.timesClicked = 0
				NavigationMenu.Buttons.VersionInfo.textColor = NavigationMenu.textColor
				if Program.isInValidMapLocation() then
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
	NavigationMenu.Buttons.GameplaySettings,
	NavigationMenu.Buttons.ThemeCustomization,
	NavigationMenu.Buttons.ManageTrackedData,
	NavigationMenu.Buttons.MirageButton,
}

function NavigationMenu.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15
	local startY = Constants.SCREEN.MARGIN + 22
	for _, button in ipairs(NavigationMenu.OrderedMenuList) do
		button.type = Constants.ButtonTypes.FULL_BORDER
		button.box = { startX, startY, 110, 16 }
		startY = startY + 21
	end

	for _, button in pairs(NavigationMenu.Buttons) do
		button.textColor = NavigationMenu.textColor
		button.boxColors = { NavigationMenu.borderColor, NavigationMenu.boxFillColor }
	end

	-- Yet another fun Easter Egg that shows up only once in a while
	if math.random(256) == 1 then
		NavigationMenu.Buttons.MirageButton.text = Utils.inlineIf(GameSettings.game == 3, "Reveal Mew by Truck", "Mirage Island Portal")
		NavigationMenu.Buttons.MirageButton.canBeSeenToday = true
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
	Drawing.drawText(topboxX + 32, Constants.SCREEN.MARGIN - 2, NavigationMenu.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[NavigationMenu.borderColor], Theme.COLORS[NavigationMenu.boxFillColor])

	-- Draw all buttons, manually
	for index, button in ipairs(NavigationMenu.OrderedMenuList) do
		if button.isVisible == nil or button:isVisible() then
			local x = button.box[1]
			local y = button.box[2]
			local holdText = button.text

			button.text = ""
			Drawing.drawButton(button, shadowcolor)
			button.text = holdText
			Drawing.drawText(x + 17, y + 3, button.text, Theme.COLORS[button.textColor], shadowcolor)

			-- TODO: Eventually make the Draw Button more flexible for centering its contents
			if button.image == Constants.PixelImages.GEAR then
				y = y + 2
				x = x + 1
			elseif button.image == Constants.PixelImages.PHYSICAL then
				y = y + 3
				x = x + 1
			elseif button.image == Constants.PixelImages.MAGNIFYING_GLASS then
				y = y + 1
			elseif button.image == Constants.PixelImages.MAP_PINDROP then
				x = x + 1
			end
			Drawing.drawImageAsPixels(button.image, x + 4, y + 2, { Theme.COLORS[NavigationMenu.borderColor] }, shadowcolor)
		end
	end

	Drawing.drawButton(NavigationMenu.Buttons.Credits, shadowcolor)
	Drawing.drawButton(NavigationMenu.Buttons.VersionInfo, shadowcolor)
	Drawing.drawButton(NavigationMenu.Buttons.Back, shadowcolor)
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
	gui.drawImage(Main.DataFolder .. "/images/pokemon/196.gif", topboxColX + 40, offsetY - 13, 32, 32) -- Espeon
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
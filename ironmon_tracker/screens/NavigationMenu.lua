--[[
- Setup & Options
- Gameplay Settings
- Theme Customization
- Manage Tracked Data
- Credits // Version Info // Back
]]

NavigationMenu = {
	headerText = "Navigation Menu",
	textColor = "Default text",
	borderColor = "Upper box border",
	borderFill = "Upper box background",
}

NavigationMenu.Buttons = {
	SetupAndOptions = {
		text = "Tracker Setup",
		image = Constants.PixelImages.NOTEPAD,
		onClick = function() Program.changeScreenView(Program.Screens.SETUP) end
	},
	GameplaySettings = {
		text = "Gameplay Options",
		image = Constants.PixelImages.PHYSICAL,
		onClick = function() Program.changeScreenView(Program.Screens.GAME_SETTINGS) end
	},
	ThemeCustomization = {
		text = "Customize Theme",
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		onClick = function() Program.changeScreenView(Program.Screens.THEME) end
	},
	ManageTrackedData = {
		text = "Manage Tracked Data",
		image = Constants.PixelImages.GEAR,
		onClick = function() Program.changeScreenView(Program.Screens.MANAGE_DATA) end
	},
	MirageButton = {
		text = "It's a secret...",
		image = Constants.PixelImages.MAP_PINDROP,
		timesClicked = 0,
		canBeSeenToday = false,
		isVisible = function(self) return self.canBeSeenToday and self.timesClicked <= 3 end,
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
		isVisible = function() return true end, -- TODO: Implement a way to show credits
		onClick = function(self) end
	},
	VersionInfo = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "Tracker v" .. Main.TrackerVersion,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 44, Constants.SCREEN.MARGIN + 135, 20, 10 },
		timesClicked = 0,
		onClick = function(self)
			self.timesClicked = self.timesClicked + 1
			self.textColor = Utils.inlineIf(self.timesClicked % 2 == 0, NavigationMenu.textColor, "Intermediate text")
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			NavigationMenu.Buttons.VersionInfo.timesClicked = 0
			Program.changeScreenView(Program.Screens.TRACKER)
		end
	},
}

NavigationMenu.OrderedButtonList = {
	NavigationMenu.Buttons.SetupAndOptions,
	NavigationMenu.Buttons.GameplaySettings,
	NavigationMenu.Buttons.ThemeCustomization,
	NavigationMenu.Buttons.ManageTrackedData,
	NavigationMenu.Buttons.MirageButton,
}

function NavigationMenu.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15
	local startY = Constants.SCREEN.MARGIN + 22
	for _, button in ipairs(NavigationMenu.OrderedButtonList) do
		button.type = Constants.ButtonTypes.FULL_BORDER
		button.box = { startX, startY, 110, 16 }
		startY = startY + 21
	end

	for _, button in pairs(NavigationMenu.Buttons) do
		button.textColor = NavigationMenu.textColor
		button.boxColors = { NavigationMenu.borderColor, NavigationMenu.borderFill }
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
	gui.defaultTextBackground(Theme.COLORS[NavigationMenu.borderFill])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[NavigationMenu.borderFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[NavigationMenu.borderColor], Theme.COLORS[NavigationMenu.borderFill])

	-- Draw header text
	Drawing.drawText(topboxX + 32, topboxY + 2, NavigationMenu.headerText:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- Draw all buttons, manually
	local buttonTexts = {}
	for index, button in ipairs(NavigationMenu.OrderedButtonList) do
		if button.isVisible == nil or button:isVisible() then
			local x = button.box[1]
			local y = button.box[2]
			local holdText = button.text

			button.text = ""
			Drawing.drawButton(button, shadowcolor)
			button.text = holdText
			Drawing.drawText(x + 17, y + 3, button.text, Theme.COLORS[button.textColor], shadowcolor)

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
			Drawing.drawImageAsPixels(button.image, x + 4, y + 2, Theme.COLORS[NavigationMenu.borderColor], shadowcolor)
		end
	end

	Drawing.drawButton(NavigationMenu.Buttons.Credits, shadowcolor)
	Drawing.drawButton(NavigationMenu.Buttons.VersionInfo, shadowcolor)
	Drawing.drawButton(NavigationMenu.Buttons.Back, shadowcolor)
end
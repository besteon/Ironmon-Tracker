SetupScreen = {
	headerText = "Tracker Setup",
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
	iconChangeInterval = 10,
}

SetupScreen.OptionKeys = {
	"Right justified numbers",
	"Disable mainscreen carousel",
	"Track PC Heals",
	"PC heals count downward", -- Text referenced in initialize()
	"Display repel usage",
	"Animated Pokemon popout", -- Text referenced in initialize()
}

SetupScreen.Buttons = {
	ChoosePortrait = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[Options["Pokemon icon set"]].name,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 12, 65, 11 },
	},
	PortraitAuthor = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "Added by:  " .. Options.IconSetMap[Options["Pokemon icon set"]].author,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 22, 65, 11 },
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 27, 32, 32 },
		pokemonID = 1,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. self.pokemonID .. iconset.extension
			return imagepath
		end,
		onClick = function(self)
			self.pokemonID = Utils.randomPokemonID()
			SetupScreen.iconChangeInterval = 10
			Program.redraw(true)
		end
	},
	CycleIconForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 94, Constants.SCREEN.MARGIN + 42, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"])
			local nextSet = tostring((currIndex % Options.IconSetMap.totalCount) + 1)
			SetupScreen.Buttons.ChoosePortrait.text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[nextSet].name
			SetupScreen.Buttons.PortraitAuthor.text = "Added by:  " .. Options.IconSetMap[nextSet].author
			SetupScreen.iconChangeInterval = 10
			Options.updateSetting("Pokemon icon set", nextSet)
		end
	},
	CycleIconBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 34, Constants.SCREEN.MARGIN + 42, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"])
			local prevSet = tostring((currIndex - 2 ) % Options.IconSetMap.totalCount + 1)
			SetupScreen.Buttons.ChoosePortrait.text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[prevSet].name
			SetupScreen.Buttons.PortraitAuthor.text = "Added by:  " .. Options.IconSetMap[prevSet].author
			SetupScreen.iconChangeInterval = 10
			Options.updateSetting("Pokemon icon set", prevSet)
		end
	},
	EditControls = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Edit Controls",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 53, 11 },
		onClick = function() SetupScreen.openEditControlsWindow() end
	},
	QuickLoad = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Quick- load",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 60, Constants.SCREEN.MARGIN + 135, 49, 11 },
		onClick = function()
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.QUICKLOAD)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
}

function SetupScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 63
	local linespacing = Constants.SCREEN.LINESPACING + 1

	for _, optionKey in ipairs(SetupScreen.OptionKeys) do
		SetupScreen.Buttons[optionKey] = {
			type = Constants.ButtonTypes.CHECKBOX,
			text = optionKey,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionKey],
			toggleColor = "Positive text",
			onClick = function(self)
				-- Toggle the setting and store the change to be saved later in Settings.ini
				self.toggleState = not self.toggleState
				Options.updateSetting(self.text, self.toggleState)

				-- If PC Heal tracking switched, invert the count
				if self.text == "PC heals count downward" then
					Tracker.Data.centerHeals = math.max(10 - Tracker.Data.centerHeals, 0)
				end

				-- If Animated Pokemon popout is turned on, create the popup form, or destroy it.
				if self.text == "Animated Pokemon popout" then
					if self.toggleState then
						Drawing.AnimatedPokemon:create()
					else
						Drawing.AnimatedPokemon:destroy()
					end
				end
			end
		}
		startY = startY + linespacing
	end

	for _, button in pairs(SetupScreen.Buttons) do
		button.textColor = SetupScreen.textColor
		button.boxColors = { SetupScreen.borderColor, SetupScreen.boxFillColor }
	end

	SetupScreen.Buttons.ChoosePortrait.text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[Options["Pokemon icon set"]].name
	SetupScreen.Buttons.PortraitAuthor.text = "Added by:  " .. Options.IconSetMap[Options["Pokemon icon set"]].author
	-- Randomize what Pokemon icon is shown
	SetupScreen.Buttons.PokemonIcon.pokemonID = Utils.randomPokemonID()

	-- If neither quickload option is enabled (somehow), then highlight it to draw user's attention
	if not Options[QuickloadScreen.OptionKeys[1]] and not Options[QuickloadScreen.OptionKeys[2]] then
		SetupScreen.Buttons.QuickLoad.textColor = "Intermediate text"
	end

	local animatedAddonInstalled = Main.FileExists(Utils.getWorkingDirectory() .. Main.DataFolder .. "/images/pokemonAnimated/abra.gif")
	local animatedBtnOption = SetupScreen.Buttons["Animated Pokemon popout"]
	if not animatedAddonInstalled and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

function SetupScreen.openEditControlsWindow()
	Program.destroyActiveForm()
	local form = forms.newform(445, 215, "Controller Inputs", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	forms.label(form, "Edit GBA buttons for the Tracker, available buttons: A, B, L, R, Start, Select", 39, 10, 410, 20)

	local inputTextboxes = {}
	local offsetX = 90
	local offsetY = 35

	local index = 1
	for _, controlKey in ipairs(Constants.OrderedLists.CONTROLS) do
		forms.label(form, controlKey .. ":", offsetX, offsetY, 105, 20)
		inputTextboxes[index] = forms.textbox(form, Options.CONTROLS[controlKey], 140, 21, nil, offsetX + 110, offsetY - 2)

		index = index + 1
		offsetY = offsetY + 24
	end

	-- 'Save & Close' and 'Cancel' buttons
	forms.button(form,"Save && Close", function()
		index = 1
		for _, controlKey in ipairs(Constants.OrderedLists.CONTROLS) do
			local controlCombination = ""
			for txtInput in string.gmatch(forms.gettext(inputTextboxes[index]), '([^,%s]+)') do
				-- Format "START" as "Start"
				controlCombination = controlCombination .. txtInput:sub(1,1):upper() .. txtInput:sub(2):lower() .. ", "
			end
			controlCombination = controlCombination:sub(1, -3)

			if controlCombination ~= nil and controlCombination ~= "" then
				Options.CONTROLS[controlKey] = controlCombination
			end
			index = index + 1
		end

		QuickloadScreen.Buttons.ButtonCombo:updateText()
		Options.forceSave()

		client.unpause()
		forms.destroy(form)
	end, 120, offsetY + 5, 95, 30)

	forms.button(form,"Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 230, offsetY + 5, 65, 30)
end

-- DRAWING FUNCTIONS
function SetupScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SetupScreen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[SetupScreen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 37, Constants.SCREEN.MARGIN - 2, SetupScreen.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[SetupScreen.borderColor], Theme.COLORS[SetupScreen.boxFillColor])

	-- Draw all buttons
	for _, button in pairs(SetupScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Randomize the pokemon shown every iconChangeInterval
	-- Tracker screen redraw occurs every Program.Frames.waitToDraw frames,
	-- so overall interval is effectively iconChangeInterval * Program.Frames.waitToDraw frames
	if SetupScreen.iconChangeInterval == 0 then
		SetupScreen.Buttons.PokemonIcon.pokemonID = Utils.randomPokemonID()
	end

	SetupScreen.iconChangeInterval = (SetupScreen.iconChangeInterval - 1) % 10
end
SetupScreen = {
	headerText = "Tracker Setup",
	textColor = "Default text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

SetupScreen.OptionKeys = {
	"Show tips on startup",
	"Right justified numbers",
	"Track PC Heals",
	"PC heals count downward",
	"Animated Pokemon popout",
}

SetupScreen.Buttons = {
	ChoosePortrait = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[Options["Pokemon icon set"]].name,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 13, 65, 11 },
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 52, Constants.SCREEN.MARGIN + 19, 32, 32 },
		pokemonID = 1,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. self.pokemonID .. iconset.extension
			return imagepath
		end,
		onClick = function(self)
			self.pokemonID = math.random(#PokemonData.Pokemon - 25)
			if self.pokemonID > 251 then
				self.pokemonID = self.pokemonID + 25
			end
			Program.redraw(true)
		end
	},
	CycleIconForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 94, Constants.SCREEN.MARGIN + 33, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"])
			local nextSet = tostring((currIndex % Options.IconSetMap.totalCount) + 1)
			SetupScreen.Buttons.ChoosePortrait.text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[nextSet].name
			Options.updateSetting("Pokemon icon set", nextSet)
		end
	},
	CycleIconBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 34, Constants.SCREEN.MARGIN + 33, 10, 10, },
		onClick = function(self)
			local currIndex = tonumber(Options["Pokemon icon set"])
			local prevSet = tostring((currIndex - 2 ) % Options.IconSetMap.totalCount + 1)
			SetupScreen.Buttons.ChoosePortrait.text = Constants.Words.POKEMON .. " icon set:  " .. Options.IconSetMap[prevSet].name
			Options.updateSetting("Pokemon icon set", prevSet)
		end
	},
	RomsFolder = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "ROMs Folder",
		folderText = "Set for Quick- load",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 60, 55, 11 },
		onClick = function() SetupScreen.openRomPickerWindow() end
	},
	EditControls = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Edit Controls",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 53, 11 },
		onClick = function() SetupScreen.openEditControlsWindow() end
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
	local startY = Constants.SCREEN.MARGIN + 75
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
				if self.text == SetupScreen.OptionKeys[4] then
					Tracker.Data.centerHeals = math.max(10 - Tracker.Data.centerHeals, 0)
				end

				-- If Animated Pokemon popout is turned on, create the popup form, or destroy it.
				if self.text == SetupScreen.OptionKeys[5] then
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
	SetupScreen.Buttons.PokemonIcon:onClick() -- Randomize what Pokemon icon is shown

	if Options.ROMS_FOLDER ~= nil and Options.ROMS_FOLDER ~= "" then
		SetupScreen.Buttons.RomsFolder.folderText = Utils.truncateRomsFolder(Options.ROMS_FOLDER)
	end

	local animatedAddonInstalled = Main.FileExists(Utils.getWorkingDirectory() .. Main.DataFolder .. "/images/pokemonAnimated/abra.gif")
	local animatedBtnOption = SetupScreen.Buttons["Animated Pokemon popout"]
	if not animatedAddonInstalled and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

function SetupScreen.openRomPickerWindow()
	-- Use the standard file open dialog to get the roms folder
	local filterOptions = "ROM File (*.GBA)|*.GBA|All files (*.*)|*.*"
	local file = forms.openfile("SELECT A ROM", Options.ROMS_FOLDER, filterOptions)
	if file ~= "" then
		-- Since the user had to pick a file, strip out the file name to just get the folder.
		Options.ROMS_FOLDER = string.sub(file, 0, string.match(file, "^.*()\\") - 1)
		if Options.ROMS_FOLDER == nil then
			Options.ROMS_FOLDER = ""
		end
		SetupScreen.Buttons.RomsFolder.folderText = Utils.truncateRomsFolder(Options.ROMS_FOLDER)
		Options.settingsUpdated = true

		-- Save these changes to the file to avoid case where user resets before clicking the Close button
		Main.SaveSettings()

		Program.redraw(true)
	end
end

function SetupScreen.openEditControlsWindow()
	Program.destroyActiveForm()
	local form = forms.newform(445, 215, "Controller Inputs", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	forms.label(form, "Edit controller inputs for the tracker. Available inputs: A, B, L, R, Start, Select", 39, 10, 410, 20)

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

			Options.CONTROLS[controlKey] = controlCombination
			Options.settingsUpdated = true
			index = index + 1
		end

		Main.SaveSettings() -- Save these changes to the file to avoid case where user resets before clicking the Close button
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
	local topboxY = Constants.SCREEN.MARGIN
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[SetupScreen.borderColor], Theme.COLORS[SetupScreen.boxFillColor])

	-- Draw header text
	Drawing.drawText(topboxX + 37, topboxY + 2, SetupScreen.headerText:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- Draw all buttons
	for _, button in pairs(SetupScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	local romsButton = SetupScreen.Buttons.RomsFolder
	Drawing.drawText(romsButton.box[1] + romsButton.box[3] + 2, romsButton.box[2], romsButton.folderText, Theme.COLORS[romsButton.textColor], shadowcolor)
end
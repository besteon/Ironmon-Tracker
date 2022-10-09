Theme = {
	-- Tracks if any theme elements were modified so we know if we need to save them to the Settings.ini file
	settingsUpdated = false,

	-- 'Default' Theme, but will get replaced by what's in Settings.ini
	COLORS = {
		["Default text"] = 0xFFFFFFFF,
		["Lower box text"] = 0xFFFFFFFF,
		["Positive text"] = 0xFF00FF00,
		["Negative text"] = 0xFFFF0000,
		["Intermediate text"] = 0xFFFFFF00,
		["Header text"] = 0xFFFFFFFF,
		["Upper box border"] = 0xFFAAAAAA,
		["Upper box background"] = 0xFF222222,
		["Lower box border"] = 0xFFAAAAAA,
		["Lower box background"] = 0xFF222222,
		["Main background"] = 0xFF000000,
	},
	-- If move types are enabled then the Move Names themselves will be drawn with a color representing their type.
	MOVE_TYPES_ENABLED = true,
}

Theme.PresetStrings = {
	-- [Default] [L.Box Text] [Positive] [Negative] [Intermediate] [Header] [U.Border] [U.Fill] [L.Border] [L.Fill] [Main Background] [0/1: movetypes?]
	["Default Theme"] = "FFFFFF FFFFFF 00FF00 FF0000 FFFF00 FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1",
}
Theme.PresetsOrdered = {
	"Default Theme",
}

Theme.Screen = {
	headerText = "Customize Theme",
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

Theme.Buttons = {
	ImportTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Import",
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 135, 31, 11 },
		onClick = function() Theme.openImportWindow() end
	},
	ExportTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Export",
		box = { Constants.SCREEN.WIDTH + 44, Constants.SCREEN.MARGIN + 135, 31, 11 },
		onClick = function() Theme.openExportWindow() end
	},
	Presets = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Presets",
		box = { Constants.SCREEN.WIDTH + 79, Constants.SCREEN.MARGIN + 135, 34, 11 },
		onClick = function() Theme.openPresetsWindow() end
	},
	MoveTypeEnabled = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = "Show color bar for move types",
		clickableArea = { Constants.SCREEN.WIDTH + 9, 125, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		box = { Constants.SCREEN.WIDTH + 9, 125, 8, 8 },
		toggleState = not Theme.MOVE_TYPES_ENABLED, -- Show the opposite of the Setting, can't change existing theme strings
		toggleColor = "Positive text",
		onClick = function(self)
			self.toggleState = not self.toggleState -- toggle the setting
			Theme.MOVE_TYPES_ENABLED = not Theme.MOVE_TYPES_ENABLED
			Theme.settingsUpdated = true
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			TrackerScreen.getNextMoveLevelHighlight(false) -- Update the next move level highlight color
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
}

function Theme.initialize()
	local startY = Constants.SCREEN.MARGIN + 13

	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do
		Theme.Buttons[colorkey] = {
			type = Constants.ButtonTypes.COLORPICKER,
			text = colorkey,
			clickableArea = { Constants.SCREEN.WIDTH + 9, startY, Constants.SCREEN.RIGHT_GAP - 12, 10 },
			box = { Constants.SCREEN.WIDTH + 9, startY, 8, 8 },
			themeColor = colorkey,
			onClick = function() Theme.openColorPickerWindow(colorkey) end
		}

		startY = startY + 10
	end

	for _, button in pairs(Theme.Buttons) do
		button.textColor = Theme.Screen.textColor
		button.boxColors = { Theme.Screen.borderColor, Theme.Screen.boxFillColor }
	end

	-- Adjust the extra options positions based on the verical space left
	Theme.Buttons.MoveTypeEnabled.clickableArea[2] = startY
	Theme.Buttons.MoveTypeEnabled.box[2] = startY

	Theme.loadPresets(Constants.Files.THEME_PRESETS)
end

function Theme.loadPresets(filename)
	if not Main.FileExists(filename) then return end

	for index, line in ipairs(Utils.readLinesFromFile(filename)) do
		local firstHexIndex = line:find("%x%x%x%x%x%x")
		if firstHexIndex ~= nil then
			local themeString = line:sub(firstHexIndex)
			local themeName
			if firstHexIndex <= 2 then
				themeName = "Untitled " .. index
			else
				themeName = line:sub(1, firstHexIndex - 2)
			end

			Theme.PresetStrings[themeName] = themeString
			table.insert(Theme.PresetsOrdered, themeName)
		end
	end
end

-- Imports a theme config string into the Tracker, reloads all Tracker visuals, and flags to update Settings.ini
-- returns true if successful; false otherwise.
function Theme.importThemeFromText(theme_config)
	if theme_config == nil or theme_config == "" then
		return false
	end

	-- If the theme config string is old, duplicate the 'Default text' color hex code as 'Lower box text'
	if Theme.isOldThemeString(theme_config) then
		local firstHexCode = theme_config:sub(1, 7) -- includes the trailing space
		theme_config = firstHexCode .. theme_config
	end

	-- A valid string has at minimum N total hex codes (7 chars each including spaces) and a single bit for move types
	local totalHexCodes = 11
	if string.len(theme_config) < (totalHexCodes * 7 + 1) then
		return false
	end

	-- Verify the theme config is correct and can be parsed (each entry should be a numerical value)
	local numHexCodes = 0
	local theme_colors = {}
	for color_text in string.gmatch(theme_config, "[^%s]+") do
		if color_text ~= nil and string.len(color_text) == 6 then
			local color = tonumber(color_text, 16)
			if color == nil or color < 0x000000 or color > 0xFFFFFF then
				return false
			end

			numHexCodes = numHexCodes + 1
			theme_colors[numHexCodes] = color_text
		end
	end

	-- Apply as much of the imported theme config to our Theme as possible (must remain compatible with gen4/gen5 Tracker), then load it
	local index = 1
	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do -- Only use the first 10 hex codes
		if theme_colors[index] ~= nil then
			Theme.COLORS[colorkey] = 0xFF000000 + tonumber(theme_colors[index], 16)
		end
		index = index + 1
	end

	local enableMoveTypes = not (string.sub(theme_config, numHexCodes * 7 + 1, numHexCodes * 7 + 1) == "0")
	Theme.MOVE_TYPES_ENABLED = enableMoveTypes
	Theme.Buttons.MoveTypeEnabled.toggleState = not enableMoveTypes -- Show the opposite of the Setting, can't change existing theme strings

	Theme.settingsUpdated = true
	Program.redraw(true)

	return true
end

-- A simple way to check if user imports an old theme config string
function Theme.isOldThemeString(theme_config)
	if theme_config == nil or theme_config == "" then return false end

	local oldHexCountGBA = 10 -- version 0.6.2 and below
	local oldHexCountNDS = 13 -- version 0.3.31 and below

	local numHexCodes = 0
	for hexCode in string.gmatch(theme_config, "[0-9a-fA-F]+") do
		if #hexCode > 1 then
			numHexCodes = numHexCodes + 1
		end
	end

	return numHexCodes == oldHexCountGBA or numHexCodes == oldHexCountNDS
end

-- Exports the theme options that can be customized into a string that can be shared and imported
function Theme.exportThemeToText()
	-- Build base theme config string
	local exportedTheme = ""
	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do
		-- Format each color code as "AABBCC", instead of "0xAABBCC" or "0xFFAABBCC"
		exportedTheme = exportedTheme .. string.sub(string.format("%#x", Theme.COLORS[colorkey]), 5) .. " "
	end

	-- Append other theme config options at the end
	exportedTheme = exportedTheme .. Utils.inlineIf(Theme.MOVE_TYPES_ENABLED, 1, 0)

	return string.upper(exportedTheme)
end

function Theme.openColorPickerWindow(colorkey)
	local picker = ColorPicker.new(colorkey)
	Input.currentColorPicker = picker
	picker:show()
end

function Theme.openImportWindow()
	Program.destroyActiveForm()
	local form = forms.newform(515, 125, "Theme Import", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	forms.label(form, "Enter a theme configuration string to import (Ctrl+V to paste):", 9, 10, 300, 20)
	local importTextBox = forms.textbox(form, "", 480, 20, nil, 10, 30)
	forms.button(form, "Import", function()
		local formInput = forms.gettext(importTextBox)
		if formInput ~= nil then
			-- Check if the import was successful
			if not Theme.importThemeFromText(formInput) then
				print("Error importing Theme Config string:")
				print(">> " .. formInput)
				Main.DisplayError("The theme config string you entered is invalid.\n\nPlease enter a valid theme config string.")
			end
		end
		forms.destroy(form)
	end, 212, 55)
end

function Theme.openExportWindow()
	Program.destroyActiveForm()
	local form = forms.newform(515, 125, "Theme Export", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	local theme_config = Theme.exportThemeToText()
	forms.label(form, "Copy the theme configuration string below (Ctrl + A --> Ctrl+C):", 9, 10, 300, 20)
	forms.textbox(form, theme_config, 480, 20, nil, 10, 30)
	forms.button(form, "Close", function()
		forms.destroy(form)
	end, 212, 55)
end

function Theme.openPresetsWindow()
	Program.destroyActiveForm()
	local presetsForm = forms.newform(360, 105, "Theme Presets", function() client.unpause() end)
	Program.activeFormId = presetsForm
	Utils.setFormLocation(presetsForm, 100, 50)

	forms.label(presetsForm, "Select a predefined theme to use:", 49, 10, 250, 20)
	local presetDropdown = forms.dropdown(presetsForm, {["Init"]="Loading Presets"}, 50, 30, 145, 30)
	forms.setdropdownitems(presetDropdown, Theme.PresetsOrdered, false) -- Required to prevent alphabetizing the list
	forms.setproperty(presetDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(presetDropdown, "AutoCompleteMode", "Append")

	forms.button(presetsForm, "Load", function()
		Theme.importThemeFromText(Theme.PresetStrings[forms.gettext(presetDropdown)])
		client.unpause()
		forms.destroy(presetsForm)
	end, 212, 29)
end

-- DRAWING FUNCTIONS
function Theme.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[Theme.Screen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[Theme.Screen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 32, Constants.SCREEN.MARGIN - 2, Theme.Screen.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw Theme screen view box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[Theme.Screen.borderColor], Theme.COLORS[Theme.Screen.boxFillColor])

	-- Draw all buttons
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
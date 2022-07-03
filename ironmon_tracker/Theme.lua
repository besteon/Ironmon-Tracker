Theme = {}

-- Update drawing the theme page if true
Theme.redraw = true

-- Tracks if any theme elements were modified so we know if we need to update Settings.ini or not.
Theme.updated = false

Theme.Presets = {
	PresetNames = {
		"Default Theme",
		"Fire Red",
		"Leaf Green",
		"Beach Getaway",
		"Blue Da Ba Dee",
		"Calico Cat",
		"Cotton Candy",
		"Neon",
		"USS Galactic",
	},
	-- [Default] [Positive] [Negative] [Intermediate] [Header] [U.Border] [U.Background] [L.Border] [L.Background] [Main Background] [0/1: movetypes?]
	PresetConfigStrings = {
		["Default Theme"] = "FFFFFF 00FF00 FF0000 FFFF00 FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1",
		["Fire Red"] = "FFFFFF 55CB6B 62C7FE FEFA69 FEFA69 FF1920 81000E FF1920 81000E 58050D 0",
		["Leaf Green"] = "FFFFFF 62C7FE FE7573 FEFA69 FEFA69 55CB6B 006200 55CB6B 006200 053A04 0",
		["Beach Getaway"] = "222222 5463FF E78EA9 A581E6 444444 E78EA9 B9F8D3 E78EA9 FFFBE7 40DFEF 0",
		["Blue Da Ba Dee"] = "FFFFFF 2EB5FF E04DBA FEFA69 55CB6B 198BFF 004881 198BFF 004881 072557 1",
		["Calico Cat"] = "4A3432 E07E3D 8A9298 E07E3D FCFCF0 8A9298 FCFCF0 E07E3D FBCA8C 0F0601 0",
		["Cotton Candy"] = "000000 1A85FF D41159 9155D9 EEEEEE D35FB7 FFCBF3 1A85FF A0D3FF 5D3A9B 0",
		["Neon"] = "FFFFFF 38FF12 FF00E3 FFF100 FFFFFF 00F5FB 000000 001EFF 000000 000000 1",
		["USS Galactic"] = "EEEEEE 00ADB5 DFBB9D B6C8EF 00ADB5 222831 393E46 222831 393E46 000000 1",
	}
}

Theme.importThemeButton = {
	text = "Import",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + 10, 8, 34, 11},
	boxColors = { "Lower box border", "Lower box background" },
	onClick = function() Theme.openImportWindow() end
}

Theme.exportThemeButton = {
	text = "Export",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + 57, 8, 33, 11},
	boxColors = { "Lower box border", "Lower box background" },
	onClick = function() Theme.openExportWindow() end
}

Theme.presetsButton = {
	text = "Presets",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + 103, 8, 37, 11},
	boxColors = { "Lower box border", "Lower box background" },
	onClick = function() Theme.openPresetsWindow() end
}

-- A button to navigate to the Theme menu for customizing the Tracker's look and feel
Theme.restoreDefaultsButton = {
	text = "Restore Defaults",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + 10, GraphicConstants.SCREEN_HEIGHT - 20, 73, 11},
	boxColors = { "Lower box border", "Lower box background" },
	confirmReset = false,
	onClick = function() Theme.tryRestoreDefaultTheme() end
}

-- A button to close the settings page and save the settings if any changes occurred
Theme.closeButton = {
	text = "Close",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 39, GraphicConstants.SCREEN_HEIGHT - 20, 29, 11},
	boxColors = { "Lower box border", "Lower box background" },
	onClick = function() Theme.closeMenuAndSave() end
}

Theme.moveTypeEnableButton = {
	text = "Color move names by type",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + 9, 125, 8, 8},
	boxColors = { "Lower box border", "Lower box background" },
	togglecolor = "Positive text",
	onClick = function()
		Settings.theme["MOVE_TYPES_ENABLED"] = not Settings.theme["MOVE_TYPES_ENABLED"]-- toggle the setting
		GraphicConstants.MOVE_TYPES_ENABLED = Settings.theme["MOVE_TYPES_ENABLED"]
		Theme.redraw = true
		Theme.updated = true
	end
}

-- Stores the theme elements in the Settings.ini file into configurable toggles in the Tracker
Theme.themeButtons = {}

function Theme.buildTrackerThemeButtons()
	local index = 1
	local heightOffset = 25
	local button = {}

	for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
		button = {
			text = colorkey,
			box = {GraphicConstants.SCREEN_WIDTH + 10, heightOffset, 8, 8},
			textColor = "Default text",
			themeColor = colorkey,
			onClick = function() Theme.openColorPickerWindow(colorkey) end
		}

		table.insert(Theme.themeButtons, button)
		index = index + 1
		heightOffset = heightOffset + 10
	end

	-- Adjust the extra options positions based on the verical space left
	Theme.moveTypeEnableButton.box[2] = heightOffset
end

-- Loads the theme defined in Settings into the Tracker's constants
function Theme.loadTheme()
	for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
		local color_hexval = Settings.theme[string.gsub(colorkey, " ", "_")]

		-- If no theme is found, assign it based on the defaults
		if color_hexval == nil then
			Settings.theme[string.gsub(colorkey, " ", "_")] = string.upper(string.sub(string.format("%#x", GraphicConstants.THEMECOLORS[colorkey]), 5))
			Theme.updated = true
		else -- Otherwise update the theme that is in use with the one from Settings.ini
			GraphicConstants.THEMECOLORS[colorkey] = tonumber(color_hexval, 16) + 0xFF000000
		end
	end

	if Settings.theme["MOVE_TYPES_ENABLED"] == nil then
		Settings.theme["MOVE_TYPES_ENABLED"] = GraphicConstants.MOVE_TYPES_ENABLED
		Theme.updated = true
	else
		GraphicConstants.MOVE_TYPES_ENABLED = Settings.theme["MOVE_TYPES_ENABLED"]
	end

	Theme.redraw = true
end

-- Imports a theme config string into the Tracker, reloads all Tracker visuals, and flags to update Settings.ini
-- returns true if successful; false otherwise.
function Theme.importThemeFromText(theme_config)
	-- A valid string has at minimum (7 x 10) hex codes (w/ spaces) and a single bit for move types
	if theme_config == nil then
		return false
	elseif string.len(theme_config) < 71 then
		return false
	end

	-- Verify the theme config is correct and can be parsed (each entry should be a numerical value)
	local numHexCodes = 0
	local theme_colors = {}
	for color_text in string.gmatch(theme_config, "[^%s]+") do
		if string.len(color_text) == 6 then
			local color = tonumber(color_text, 16)
			if color < 0x000000 or color > 0xFFFFFF then
				return false
			end
	
			numHexCodes = numHexCodes + 1
			theme_colors[numHexCodes] = color_text
		end
	end

	-- Apply as much of the imported theme config to our Settings as possible (must remain compatible with gen4/gen5 Tracker), then load it
	local index = 1
	for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do -- Only use the first 10 hex codes
		Settings.theme[string.gsub(colorkey, " ", "_")] = theme_colors[index]
		index = index + 1
	end
	Settings.theme["MOVE_TYPES_ENABLED"] = Utils.inlineIf(string.sub(theme_config, numHexCodes * 7 + 1, numHexCodes * 7 + 1) == "0", false, true)

	Theme.updated = true
	Theme.loadTheme()

	return true
end

-- Exports the theme options that can be customized into a string that can be shared and imported
function Theme.exportThemeToText()
	-- Build base theme config string
	local exportedTheme = ""
	for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
		-- Format each color code as "AABBCC", instead of "0xAABBCC" or "0xFFAABBCC"
		exportedTheme = exportedTheme .. string.sub(string.format("%#x", GraphicConstants.THEMECOLORS[colorkey]), 5) .. " "
	end

	-- Append other theme config options at the end
	exportedTheme = exportedTheme .. Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, 1, 0)

	return string.upper(exportedTheme)
end

function Theme.openColorPickerWindow(colorkey)
	local picker = ColorPicker.new(colorkey)
	Input.currentColorPicker = picker
	picker:show()
end

function Theme.openImportWindow()
	local form = forms.newform(465, 125, "Theme Import", function() return end)
	forms.label(form, "Enter a theme configuration string to import (Ctrl+V to paste):", 9, 10, 300, 20)
	local importTextBox = forms.textbox(form, "", 430, 20, nil, 10, 30)
	forms.button(form, "Import", function()
		local formInput = forms.gettext(importTextBox)
		if formInput ~= nil then
			-- Check if the import was successful
			if not Theme.importThemeFromText(formInput) then
				print("Error importing Theme Config string:")
				print(">> " .. formInput)
			end
		end
		forms.destroy(form)
	end, 187, 55)
end

function Theme.openExportWindow()
	local theme_config = Theme.exportThemeToText()

	local form = forms.newform(465, 125, "Theme Export", function() return end)
	forms.label(form, "Copy the theme configuration string below (Ctrl + A --> Ctrl+C):", 9, 10, 300, 20)
	local exportTextBox = forms.textbox(form, theme_config, 430, 20, nil, 10, 30)
	forms.button(form, "Close", function()
		forms.destroy(form)
	end, 187, 55)
end

function Theme.openPresetsWindow()
	local presetsForm = forms.newform(360, 105, "Theme Presets", function() return nil end)
	
	forms.label(presetsForm, "Select a predefined theme to use:", 49, 10, 250, 20)
	local presetDropdown = forms.dropdown(presetsForm, {["Init"]="Loading Presets"}, 50, 30, 145, 30)
	forms.setdropdownitems(presetDropdown, Theme.Presets.PresetNames, false) -- Required to prevent alphabetizing the list

	forms.button(presetsForm, "Load", function()
		Theme.importThemeFromText(Theme.Presets.PresetConfigStrings[forms.gettext(presetDropdown)])
		Theme.updated = true
		Theme.loadTheme()
		forms.destroy(presetsForm)
	end, 212, 29)
end

-- Restores the Theme customizations to the default look-and-feel, or prompts for confirmation
-- A follow through onclick would be required to reset to default
function Theme.tryRestoreDefaultTheme()
	if Theme.restoreDefaultsButton.confirmReset then
		Theme.restoreDefaultsButton.text = "Restore Defaults"
		Theme.restoreDefaultsButton.textColor = "Default text"
		Theme.restoreDefaultsButton.confirmReset = false

		Theme.importThemeFromText(Theme.Presets.PresetConfigStrings["Default Theme"])
	else
		Theme.restoreDefaultsButton.text = "   Are you sure?"
		Theme.restoreDefaultsButton.textColor = "Negative text"
		Theme.restoreDefaultsButton.confirmReset = true

		Theme.redraw = true
	end
end

function Theme.closeMenuAndSave()
	-- Revert the Restore Defaults button (ideally this would be automatic, on a timer that reverts after 4 seconds)
	if Theme.restoreDefaultsButton.confirmReset then
		Theme.restoreDefaultsButton.text = "Restore Defaults"
		Theme.restoreDefaultsButton.textColor = "Default text"
		Theme.restoreDefaultsButton.confirmReset = false
	end

	-- Inform the Tracker Program to load the Options screen
	Options.redraw = true
	Program.state = State.SETTINGS
end
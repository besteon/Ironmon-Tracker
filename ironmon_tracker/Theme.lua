Theme = {
	-- Tracks if any theme elements were modified so we know if we need to save them to the Settings.ini file
	settingsUpdated = false,

	-- 'Default' Theme, but will get replaced by what's in Settings.ini
	COLORS = {
		["Default text"] = 0xFFFFFFFF,
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

	-- [Default] [Positive] [Negative] [Intermediate] [Header] [U.Border] [U.Background] [L.Border] [L.Background] [Main Background] [0/1: movetypes?]
	PRESET_STRINGS = {
		["Default Theme"] = "FFFFFF 00FF00 FF0000 FFFF00 FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1",
		["Fire Red"] = "FFFFFF 55CB6B 62C7FE FEFA69 FEFA69 FF1920 81000E FF1920 81000E 58050D 0",
		["Leaf Green"] = "FFFFFF 62C7FE FE7573 FEFA69 FEFA69 55CB6B 006200 55CB6B 006200 053A04 0",
		["Beach Getaway"] = "222222 5463FF E78EA9 A581E6 444444 E78EA9 B9F8D3 E78EA9 FFFBE7 40DFEF 0",
		["Blue Da Ba Dee"] = "FFFFFF 2EB5FF E04DBA FEFA69 55CB6B 198BFF 004881 198BFF 004881 072557 1",
		["Calico Cat"] = "4A3432 E07E3D 8A9298 E07E3D FCFCF0 8A9298 FCFCF0 E07E3D FBCA8C 0F0601 0",
		["Cotton Candy"] = "000000 1A85FF D41159 9155D9 EEEEEE D35FB7 FFCBF3 1A85FF A0D3FF 5D3A9B 0",
		["USS Galactic"] = "EEEEEE 00ADB5 DFBB9D B6C8EF 00ADB5 222831 393E46 222831 393E46 000000 1",
		["Simple Monotone"] = "222222 01B910 FE5958 555555 FFFFFF 000000 FFFFFF 000000 FFFFFF 555555 0",
		["Neon Lights"] = "FFFFFF 38FF12 FF00E3 FFF100 FFFFFF 00F5FB 000000 001EFF 000000 000000 1",
	},
}

Theme.Screen = {
	headerText = "Customize Theme",
	textColor = "Default text",
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
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
}

function Theme.initialize()
	local startY = Constants.SCREEN.MARGIN + 16

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
		button.textColor = "Default text"
		button.boxColors = { "Lower box border", "Lower box background" }
	end

	-- Adjust the extra options positions based on the verical space left
	Theme.Buttons.MoveTypeEnabled.clickableArea[2] = startY + 4
	Theme.Buttons.MoveTypeEnabled.box[2] = startY + 4
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

	-- Apply as much of the imported theme config to our Theme as possible (must remain compatible with gen4/gen5 Tracker), then load it
	local index = 1
	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do -- Only use the first 10 hex codes
		Theme.COLORS[colorkey] = 0xFF000000 + tonumber(theme_colors[index], 16)
		index = index + 1
	end

	local enableMoveTypes = not (string.sub(theme_config, numHexCodes * 7 + 1, numHexCodes * 7 + 1) == "0")
	Theme.MOVE_TYPES_ENABLED = enableMoveTypes
	Theme.Buttons.MoveTypeEnabled.toggleState = not enableMoveTypes -- Show the opposite of the Setting, can't change existing theme strings

	Theme.settingsUpdated = true
	Program.redraw(true)

	return true
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
	forms.destroyall()
	-- client.pause() -- Removing for now as a full game pause can be a bit distracting

	local form = forms.newform(465, 125, "Theme Import", function() client.unpause() end)
	Utils.setFormLocation(form, 100, 50)
	forms.label(form, "Enter a theme configuration string to import (Ctrl+V to paste):", 9, 10, 300, 20)
	local importTextBox = forms.textbox(form, "", 430, 20, nil, 10, 30)
	forms.button(form, "Import", function()
		local formInput = forms.gettext(importTextBox)
		if formInput ~= nil then
			-- Check if the import was successful
			if not Theme.importThemeFromText(formInput) then
				print("Error importing Theme Config string:")
				print(">> " .. formInput)
				Main.DisplayError("The config string you entered is invalid.\n\nPlease enter a valid config string.")
			end
		end
		forms.destroy(form)
	end, 187, 55)
end

function Theme.openExportWindow()
	forms.destroyall()
	-- client.pause() -- Removing for now as a full game pause can be a bit distracting

	local theme_config = Theme.exportThemeToText()

	local form = forms.newform(465, 125, "Theme Export", function() client.unpause() end)
	Utils.setFormLocation(form, 100, 50)
	forms.label(form, "Copy the theme configuration string below (Ctrl + A --> Ctrl+C):", 9, 10, 300, 20)
	forms.textbox(form, theme_config, 430, 20, nil, 10, 30)
	forms.button(form, "Close", function()
		forms.destroy(form)
	end, 187, 55)
end

function Theme.openPresetsWindow()
	forms.destroyall()
	-- client.pause() -- Removing for now as a full game pause can be a bit distracting

	local presetsForm = forms.newform(360, 105, "Theme Presets", function() client.unpause() end)
	Utils.setFormLocation(presetsForm, 100, 50)
	forms.label(presetsForm, "Select a predefined theme to use:", 49, 10, 250, 20)
	local presetDropdown = forms.dropdown(presetsForm, {["Init"]="Loading Presets"}, 50, 30, 145, 30)
	forms.setdropdownitems(presetDropdown, Constants.OrderedLists.THEMEPRESETS, false) -- Required to prevent alphabetizing the list
	forms.setproperty(presetDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(presetDropdown, "AutoCompleteMode", "Append")

	forms.button(presetsForm, "Load", function()
		Theme.importThemeFromText(Theme.PRESET_STRINGS[forms.gettext(presetDropdown)])
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
	local topboxY = Constants.SCREEN.MARGIN
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2)

	-- Draw Theme screen view box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[Theme.Screen.borderColor], Theme.COLORS[Theme.Screen.boxFillColor])

	-- Draw header text
	Drawing.drawText(topboxX + 32, topboxY + 2, Theme.Screen.headerText:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- Draw all buttons
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
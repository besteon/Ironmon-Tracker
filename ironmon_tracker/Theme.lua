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
	-- Determines if text shadows are drawn
	DRAW_TEXT_SHADOWS = true,
}

Theme.PresetStrings = {
	-- [Default] [L.Box Text] [Positive] [Negative] [Intermediate] [Header] [U.Border] [U.Fill] [L.Border] [L.Fill] [Main Background]
	-- ... [0/1: color moves by their type] [0/1: text shadows]
	["Default Theme"] = "FFFFFF FFFFFF 00FF00 FF0000 FFFF00 FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1 1",
}
Theme.PresetsOrdered = {
	"Default Theme",
}
Theme.PresetPreviewColors = {
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
	MOVE_TYPES_ENABLED = true,
	DRAW_TEXT_SHADOWS = true,
}

Theme.Screen = {
	headerText = "Customize Theme",
	moreOptionsText = "More Theme Options",
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
	showMoreOptions = false,
	currentPreset = 1,
}

Theme.Buttons = {
	ImportTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Import theme",
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 14, 59, 11 },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function() Theme.openImportWindow() end
	},
	ExportTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Export theme",
		box = { Constants.SCREEN.WIDTH + 83, Constants.SCREEN.MARGIN + 14, 58, 11 },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function() Theme.openExportWindow() end
	},
	MoveTypeEnabled = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = "Show color bar for move types",
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 31, 8, 8 },
		clickableArea = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 26, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		toggleState = not Theme.MOVE_TYPES_ENABLED, -- Show the opposite of the Setting, can't change existing theme strings
		toggleColor = "Positive text",
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			Theme.MOVE_TYPES_ENABLED = not Theme.MOVE_TYPES_ENABLED
			Theme.settingsUpdated = true
			Program.redraw(true)
		end
	},
	DrawTextShadows = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = "Text shadows",
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 42, 8, 8 },
		clickableArea = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 38, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		toggleState = Theme.DRAW_TEXT_SHADOWS,
		toggleColor = "Positive text",
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			Theme.DRAW_TEXT_SHADOWS = not Theme.DRAW_TEXT_SHADOWS
			Theme.settingsUpdated = true
			Program.redraw(true)
		end
	},
	CyclePresetBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 26, Constants.SCREEN.MARGIN + 85, 10, 10, },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			Theme.Screen.currentPreset = (Theme.Screen.currentPreset - 2 ) % #Theme.PresetsOrdered + 1
			local theme_config = Theme.PresetStrings[Theme.PresetsOrdered[Theme.Screen.currentPreset or 1]]
			Theme.importThemeFromText(theme_config, false)
		end
	},
	CyclePresetForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 104, Constants.SCREEN.MARGIN + 85, 10, 10, },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			Theme.Screen.currentPreset = (Theme.Screen.currentPreset % #Theme.PresetsOrdered) + 1
			local theme_config = Theme.PresetStrings[Theme.PresetsOrdered[Theme.Screen.currentPreset or 1]]
			Theme.importThemeFromText(theme_config, false)
		end
	},
	LoadPreset = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Load...",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 103, Constants.SCREEN.MARGIN + 102, 30, 11 },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function()
			for colorKey, colorValue in pairs(Theme.PresetPreviewColors) do
				-- Update the Theme settings only if those settings exist and the color is valid
				if Theme.COLORS[colorKey] ~= nil and type(colorValue) == "number" then
					Theme.COLORS[colorKey] = colorValue
				end
			end

			Theme.MOVE_TYPES_ENABLED = Theme.PresetPreviewColors.MOVE_TYPES_ENABLED
			Theme.Buttons.MoveTypeEnabled.toggleState = not Theme.MOVE_TYPES_ENABLED -- Show the opposite of the Setting, can't change existing theme strings
			Theme.DRAW_TEXT_SHADOWS = Theme.PresetPreviewColors.DRAW_TEXT_SHADOWS
			Theme.Buttons.DrawTextShadows.toggleState = Theme.DRAW_TEXT_SHADOWS

			Theme.settingsUpdated = true
			Program.redraw(true)
		end
	},
	MoreOptions = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "More Options",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 57, 11 },
		isVisible = function() return not Theme.Screen.showMoreOptions end,
		onClick = function(self)
			Theme.Screen.showMoreOptions = true
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			TrackerScreen.getNextMoveLevelHighlight(false) -- Update the next move level highlight color
			Main.SaveSettings() -- Always save all of the Options to the Settings.ini file

			if Theme.Screen.showMoreOptions then
				Theme.Screen.showMoreOptions = false
				Program.redraw(true)
			else
				Program.changeScreenView(Program.Screens.NAVIGATION)
			end
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
			isVisible = function() return not Theme.Screen.showMoreOptions end,
			onClick = function() Theme.openColorPickerWindow(colorkey) end
		}

		startY = startY + Constants.SCREEN.LINESPACING
	end

	for _, button in pairs(Theme.Buttons) do
		button.textColor = Theme.Screen.textColor
		button.boxColors = { Theme.Screen.borderColor, Theme.Screen.boxFillColor }
	end

	Theme.loadPresets(Constants.Files.THEME_PRESETS)

	-- Load the default theme as the first displayed preset preview
	Theme.importThemeFromText(Theme.PresetStrings[Theme.PresetsOrdered[Theme.Screen.currentPreset or 1]], false)
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
-- applyTheme: if false, this won't replace current theme, but set it as the preview for the mini tracker preview
function Theme.importThemeFromText(theme_config, applyTheme)
	if theme_config == nil or theme_config == "" then
		return false
	end

	-- A valid string has at minimum N total hex codes (7 chars each including spaces) and a two bits for boolean options
	local totalHexCodes = 11

	-- If the theme config string is old, duplicate the 'Default text' color hex code as 'Lower box text'
	if Theme.isOldThemeString(theme_config) then
		local firstHexCode = theme_config:sub(1, 7) -- includes the trailing space
		theme_config = firstHexCode .. theme_config
	end

	local themeConfigLen = string.len(theme_config)
	if themeConfigLen < (totalHexCodes * 7) then
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
	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do -- Only use the first [totalHexCodes] hex codes
		if theme_colors[index] ~= nil then
			local colorValue = 0xFF000000 + tonumber(theme_colors[index], 16)
			if applyTheme then
				Theme.COLORS[colorkey] = colorValue
			else
				Theme.PresetPreviewColors[colorkey] = colorValue
			end
		end
		index = index + 1
	end

	-- Apply as many boolean options as possible, if they're available
	if themeConfigLen >= numHexCodes * 7 + 1 then
		local enableMoveTypes = not (string.sub(theme_config, numHexCodes * 7 + 1, numHexCodes * 7 + 1) == "0")
		if applyTheme then
			Theme.MOVE_TYPES_ENABLED = enableMoveTypes
			Theme.Buttons.MoveTypeEnabled.toggleState = not enableMoveTypes -- Show the opposite of the Setting, can't change existing theme strings
		else
			Theme.PresetPreviewColors.MOVE_TYPES_ENABLED = enableMoveTypes
		end
	end

	if themeConfigLen >= numHexCodes * 7 + 3 then
		local enableTextShadows = not (string.sub(theme_config, numHexCodes * 7 + 3, numHexCodes * 7 + 3) == "0")
		if applyTheme then
			Theme.DRAW_TEXT_SHADOWS = enableTextShadows
			Theme.Buttons.DrawTextShadows.toggleState = enableTextShadows
		else
			Theme.PresetPreviewColors.DRAW_TEXT_SHADOWS = enableTextShadows
		end
	end

	Theme.settingsUpdated = applyTheme -- only update the Settings.ini if the theme was actually applied
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

	-- Append other theme config boolean options at the end
	exportedTheme = exportedTheme .. Utils.inlineIf(Theme.MOVE_TYPES_ENABLED, "1", "0") .. " " .. Utils.inlineIf(Theme.DRAW_TEXT_SHADOWS, "1", "0")

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
			if not Theme.importThemeFromText(formInput, true) then
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

-- Currently unused
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
		Theme.importThemeFromText(Theme.PresetStrings[forms.gettext(presetDropdown)], true)
		client.unpause()
		forms.destroy(presetsForm)
	end, 212, 29)
end

-- DRAWING FUNCTIONS
function Theme.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[Theme.Screen.boxFillColor])

	if Theme.Screen.showMoreOptions then
		Theme.drawMoreOptions()
		return
	end

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

function Theme.drawMoreOptions()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[Theme.Screen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX + 24, Constants.SCREEN.MARGIN - 2, Theme.Screen.moreOptionsText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw Theme screen view box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[Theme.Screen.borderColor], Theme.COLORS[Theme.Screen.boxFillColor])

	Drawing.drawText(Constants.SCREEN.WIDTH + 8, Constants.SCREEN.MARGIN + 55, "Preset:", Theme.COLORS[Theme.Screen.textColor], shadowcolor)
	Drawing.drawText(Constants.SCREEN.WIDTH + 38, Constants.SCREEN.MARGIN + 55, Theme.PresetsOrdered[Theme.Screen.currentPreset] or "", Theme.COLORS[Theme.Screen.textColor], shadowcolor)

	-- Draw a mini tracker to show different theme presets
	local mini = {
		x = topboxX + 45,
		y = topboxY + 61,
		width = 50,
		height = 50,
	}
	local fontSize = Constants.Font.SIZE - 3

	gui.drawRectangle(mini.x - 2, mini.y - 2, mini.width + 4, mini.height + 4, Theme.PresetPreviewColors["Main background"], Theme.PresetPreviewColors["Main background"])

	gui.drawRectangle(mini.x, mini.y, mini.width, 23, Theme.PresetPreviewColors["Upper box border"], Theme.PresetPreviewColors["Upper box background"])
	gui.drawRectangle(mini.x, mini.y, 35, 23, Theme.PresetPreviewColors["Upper box border"]) -- Top box's top left area
	gui.drawRectangle(mini.x, mini.y + 17, 35, 6, Theme.PresetPreviewColors["Upper box border"]) -- Top box's bottom left area
	gui.drawText(mini.x + 10, mini.y + 0, "------------", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 30, mini.y + 0, "=", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 10, mini.y + 3, "--- ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 10, mini.y + 6, "--- ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 10, mini.y + 9, "--- ------", Theme.PresetPreviewColors["Intermediate text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 10, mini.y + 12, "------ ------", Theme.PresetPreviewColors["Intermediate text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 1, mini.y + 16, "------ ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 1, mini.y + 18, "--- ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)

	gui.drawText(mini.x + 36, mini.y + 0, "---   ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 36, mini.y + 3, "---   ---", Theme.PresetPreviewColors["Positive text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 36, mini.y + 6, "---   ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 36, mini.y + 9, "---   ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 36, mini.y + 12, "---   ---", Theme.PresetPreviewColors["Negative text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 36, mini.y + 15, "---   ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 36, mini.y + 18, "---   ---", Theme.PresetPreviewColors["Default text"], nil, fontSize, Constants.Font.FAMILY)

	gui.drawText(mini.x, mini.y + 23, "------- --- ---     ---  ----  ----", Theme.PresetPreviewColors["Header text"], nil, fontSize, Constants.Font.FAMILY)

	gui.drawRectangle(mini.x, mini.y + 28, mini.width, 22, Theme.PresetPreviewColors["Lower box border"], Theme.PresetPreviewColors["Lower box background"])
	gui.drawRectangle(mini.x, mini.y + 46, mini.width, 4, Theme.PresetPreviewColors["Lower box border"])

	local moveCategory = Utils.inlineIf(Options["Show physical special icons"], "=", "")
	local moveBar = Utils.inlineIf(not Theme.PresetPreviewColors.MOVE_TYPES_ENABLED, ":", "")
	local moveText = string.format("%s%s %s", moveCategory, moveBar, "----------")
	if not Options["Show physical special icons"] then
		moveText = moveText .. "  "
	end
	if Theme.PresetPreviewColors.MOVE_TYPES_ENABLED then
		moveText = moveText:sub(1, -2) .. " "
	end
	gui.drawText(mini.x + 1, mini.y + 28, moveText .. "     ---  ----  ----", Theme.PresetPreviewColors["Lower box text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 1, mini.y + 32, moveText .. "     ---  ----  ----", Theme.PresetPreviewColors["Lower box text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 1, mini.y + 36, moveText .. "     ---  ----  ----", Theme.PresetPreviewColors["Lower box text"], nil, fontSize, Constants.Font.FAMILY)
	gui.drawText(mini.x + 1, mini.y + 40, moveText .. "     ---  ----  ----", Theme.PresetPreviewColors["Lower box text"], nil, fontSize, Constants.Font.FAMILY)

	for i=0, 7, 1 do
		gui.drawText(mini.x + 2 + (i*6), mini.y + 45, "--", Theme.PresetPreviewColors["Lower box text"], nil, fontSize, Constants.Font.FAMILY)
	end

	-- Draw all buttons
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
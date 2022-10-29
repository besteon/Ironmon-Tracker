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
	"Current Theme (Custom)", -- to be added to 'PresetStrings' later, and updated often
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
	currentPreview = 1, -- current custom theme
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
		clickableArea = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 31, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		toggleState = not Theme.MOVE_TYPES_ENABLED, -- Show the opposite of the Setting, can't change existing theme strings
		toggleColor = "Positive text",
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			Theme.MOVE_TYPES_ENABLED = not Theme.MOVE_TYPES_ENABLED
			Theme.settingsUpdated = true
			Theme.loadCurrentThemeAsPreview()
		end
	},
	DrawTextShadows = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = "Text shadows",
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 42, 8, 8 },
		clickableArea = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 42, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		toggleState = Theme.DRAW_TEXT_SHADOWS,
		toggleColor = "Positive text",
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			Theme.DRAW_TEXT_SHADOWS = not Theme.DRAW_TEXT_SHADOWS
			Theme.settingsUpdated = true
			Theme.loadCurrentThemeAsPreview()
		end
	},
	CyclePresetBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 17, Constants.SCREEN.MARGIN + 125, 10, 10, },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			Theme.Screen.currentPreview = (Theme.Screen.currentPreview - 2 ) % #Theme.PresetsOrdered + 1
			local themeCode = Theme.PresetStrings[Theme.PresetsOrdered[Theme.Screen.currentPreview or 1]]
			Theme.Buttons.SaveOrLoadPreviewedTheme:updateState()
			Theme.importThemeFromText(themeCode, false)
		end
	},
	CyclePresetForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 60, Constants.SCREEN.MARGIN + 125, 10, 10, },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		onClick = function(self)
			Theme.Screen.currentPreview = (Theme.Screen.currentPreview % #Theme.PresetsOrdered) + 1
			local themeCode = Theme.PresetStrings[Theme.PresetsOrdered[Theme.Screen.currentPreview or 1]]
			Theme.Buttons.SaveOrLoadPreviewedTheme:updateState()
			Theme.importThemeFromText(themeCode, false)
		end
	},
	SaveOrLoadPreviewedTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Save New",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 84, Constants.SCREEN.MARGIN + 69, 42, 11 },
		isVisible = function() return Theme.Screen.showMoreOptions end,
		updateState = function(self)
			if Theme.Screen.currentPreview == 1 then
				self.text = "Save New"
			else
				self.text = "   Load..."
			end
		end,
		onClick = function()
			if Theme.Screen.currentPreview == 1 then -- Save New
				Theme.openSaveCurrentThemeWindow()
			else -- Load
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
				Theme.loadCurrentThemeAsPreview()
			end
		end
	},
	MoreOptions = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "More Options",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 57, 11 },
		isVisible = function() return not Theme.Screen.showMoreOptions end,
		onClick = function(self)
			Theme.Screen.showMoreOptions = true
			Theme.loadCurrentThemeAsPreview() -- also performs a screen redraw
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

	Theme.loadPresets()

	Theme.loadCurrentThemeAsPreview()
end

function Theme.loadPresets()
	if not Main.FileExists(Constants.Files.THEME_PRESETS) then return end

	for index, line in ipairs(Utils.readLinesFromFile(Constants.Files.THEME_PRESETS)) do
		local firstHexIndex = line:find("%x%x%x%x%x%x")
		if firstHexIndex ~= nil then
			local themeString = line:sub(firstHexIndex)
			local themeName
			if firstHexIndex <= 2 then
				themeName = "Untitled " .. index
			else
				themeName = line:sub(1, firstHexIndex - 2)
			end

			if themeName ~= Theme.PresetsOrdered[1] then -- don't allow importing "Current Theme (Custom)" as that is reserved
				Theme.PresetStrings[themeName] = themeString
				table.insert(Theme.PresetsOrdered, themeName)
			end
		end
	end
end

-- Load the current theme as the displayed Theme preview, typically after any change to a Theme is made, then redraws the screen
function Theme.loadCurrentThemeAsPreview()
	-- If changes were made to the current theme, store those changes
	local currentTheme = Theme.exportThemeToText()
	Theme.PresetStrings[Theme.PresetsOrdered[1]] = currentTheme

	-- Check if the current Theme is one of the saved ones
	Theme.Screen.currentPreview = 1
	for index, themeName in ipairs(Theme.PresetsOrdered) do
		local themeCode = Theme.PresetStrings[themeName]
		if index ~= 1 and themeCode == currentTheme then
			Theme.Screen.currentPreview = index
			-- print(string.format("Theme: %s, at index: %s", themeName, index))
			break
		end
	end

	Theme.Buttons.SaveOrLoadPreviewedTheme:updateState()
	Theme.importThemeFromText(currentTheme, false)
end

-- Imports a theme config string into the Tracker, reloads all Tracker visuals, and flags to update Settings.ini
-- returns true if successful; false otherwise.
-- applyTheme: if false, this won't replace current theme, but set it as the preview for the mini tracker preview
function Theme.importThemeFromText(themeCode, applyTheme)
	if themeCode == nil or themeCode == "" then
		return false
	end

	-- A valid string has at minimum N total hex codes (7 chars each including spaces) and a two bits for boolean options
	local totalHexCodes = 11

	-- If the theme config string is old, duplicate the 'Default text' color hex code as 'Lower box text'
	if Theme.isOldThemeString(themeCode) then
		local firstHexCode = themeCode:sub(1, 7) -- includes the trailing space
		themeCode = firstHexCode .. themeCode
	end

	local themeCodeLen = string.len(themeCode)
	if themeCodeLen < (totalHexCodes * 7) then
		return false
	end

	-- Verify the theme config is correct and can be parsed (each entry should be a numerical value)
	local numHexCodes = 0
	local theme_colors = {}
	for color_text in string.gmatch(themeCode, "[^%s]+") do
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
	if themeCodeLen >= numHexCodes * 7 + 1 then
		local enableMoveTypes = not (string.sub(themeCode, numHexCodes * 7 + 1, numHexCodes * 7 + 1) == "0")
		if applyTheme then
			Theme.MOVE_TYPES_ENABLED = enableMoveTypes
			Theme.Buttons.MoveTypeEnabled.toggleState = not enableMoveTypes -- Show the opposite of the Setting, can't change existing theme strings
		else
			Theme.PresetPreviewColors.MOVE_TYPES_ENABLED = enableMoveTypes
		end
	end

	if themeCodeLen >= numHexCodes * 7 + 3 then
		local enableTextShadows = not (string.sub(themeCode, numHexCodes * 7 + 3, numHexCodes * 7 + 3) == "0")
		if applyTheme then
			Theme.DRAW_TEXT_SHADOWS = enableTextShadows
			Theme.Buttons.DrawTextShadows.toggleState = enableTextShadows
		else
			Theme.PresetPreviewColors.DRAW_TEXT_SHADOWS = enableTextShadows
		end
	end

	-- Flag to update the Settings.ini only if the Theme was actually applied
	if applyTheme then
		Theme.settingsUpdated = true
	end
	Program.redraw(true)

	return true
end

-- A simple way to check if user imports an old theme config string
function Theme.isOldThemeString(themeCode)
	if themeCode == nil or themeCode == "" then return false end

	local oldHexCountGBA = 10 -- version 0.6.2 and below
	local oldHexCountNDS = 13 -- version 0.3.31 and below

	local numHexCodes = 0
	for hexCode in string.gmatch(themeCode, "[0-9a-fA-F]+") do
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
			local success = Theme.importThemeFromText(formInput, true)
			if success then
				Theme.loadCurrentThemeAsPreview()
			else
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

function Theme.openSaveCurrentThemeWindow()
	Program.destroyActiveForm()
	local form = forms.newform(290, 130, "Save Theme As...", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	forms.label(form, "Enter a name for this Theme:", 18, 10, 300, 20)
	local saveTextBox = forms.textbox(form, "", 200, 30, nil, 20, 30)
	forms.button(form, "Save Theme", function()
		local formInput = forms.gettext(saveTextBox)
		-- don't allow importing "Current Theme (Custom)" as that is reserved
		if formInput ~= nil and formInput ~= "" and formInput ~= Theme.PresetsOrdered[1] then
			local themeName = formInput
			local themeCode = Theme.exportThemeToText()

			Utils.addCustomThemeToFile(themeName, themeCode)
			Theme.PresetStrings[themeName] = themeCode
			table.insert(Theme.PresetsOrdered, themeName)
			Theme.loadCurrentThemeAsPreview()

			client.unpause()
			forms.destroy(form)
		end
	end, 55, 60)
	forms.button(form, "Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 140, 60)
end

-- Available Theme Presets are populated exactly once, when the Tracker is first loaded
function Theme.populateThemePresets()
	-- Don't add preloaded Theme presets if a file already exists that contains custom ones
	if Main.FileExists(Constants.Files.THEME_PRESETS) then
		return
	end

	Utils.addCustomThemeToFile("Fire Red", "FFFFFF FFFFFF 55CB6B 62C7FE FEFA69 FEFA69 FF1920 81000E FF1920 81000E 58050D 0 1")
	Utils.addCustomThemeToFile("Leaf Green", "FFFFFF FFFFFF 62C7FE FE7573 FEFA69 FEFA69 55CB6B 006200 55CB6B 006200 053A04 0 1")
	Utils.addCustomThemeToFile("Beach Getaway", "222222 222222 5463FF E78EA9 A581E6 444444 E78EA9 B9F8D3 E78EA9 FFFBE7 40DFEF 0 0")
	Utils.addCustomThemeToFile("Blue Da Ba Dee", "FFFFFF FFFFFF 2EB5FF E04DBA FEFA69 55CB6B 198BFF 004881 198BFF 004881 072557 1 1")
	Utils.addCustomThemeToFile("Calico Cat", "4A3432 4A3432 E07E3D 8A9298 E07E3D FCFCF0 8A9298 FCFCF0 E07E3D FBCA8C 0F0601 0 0")
	Utils.addCustomThemeToFile("Calico Cat v2", "4A3432 4A3432 E07E3D 8A9298 E07E3D FCFCF0 FCFCF0 FCFCF0 FBCA8C FBCA8C E07E3D 0 0")
	Utils.addCustomThemeToFile("Cotton Candy", "000000 000000 1A85FF D41159 9155D9 EEEEEE D35FB7 FFCBF3 1A85FF A0D3FF 5D3A9B 0 0")
	Utils.addCustomThemeToFile("GameCube", "C8C8C8 C8C8C8 2ACA38 FE4A4A EBE31A CBCCC4 000000 342A54 000000 342A54 000000 1 1")
	Utils.addCustomThemeToFile("Item Bag", "636363 636363 017BC4 DF2800 DE8C4A 636363 D7B452 FEFFCF D7B452 FEFFCF F6CF73 0 0")
	Utils.addCustomThemeToFile("Neon Lights", "FFFFFF FFFFFF 38FF12 FF00E3 FFF100 FFFFFF 00F5FB 000000 001EFF 000000 000000 1 1")
	Utils.addCustomThemeToFile("Simple Monotone", "222222 222222 01B910 FE5958 555555 FFFFFF 000000 FFFFFF 000000 FFFFFF 555555 0 0")
	Utils.addCustomThemeToFile("Team Rocket", "EEF5FE EEF5FE 8F7DEB D6335E F4E7BA F4E7BA 8F7DEB 333333 D6335E 333333 333333 1 1")
	Utils.addCustomThemeToFile("USS Galactic", "EEEEEE EEEEEE 00ADB5 DFBB9D B6C8EF 00ADB5 222831 393E46 222831 393E46 000000 1 1")
	Utils.addCustomThemeToFile("Cozy Fall Leaves", "2C432C 2C432C FA8223 9C7456 307940 307940 7D5D1E 9ED4B0 7D5D1E 9ED4B0 9ED4B0 0 0")
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

	local themeName = Theme.PresetsOrdered[Theme.Screen.currentPreview] or "Unknown Theme*"
	Drawing.drawText(topboxX + 14, Constants.SCREEN.MARGIN + 55, themeName, Theme.COLORS[Theme.Screen.textColor], shadowcolor)

	local showColorBars = not Theme.PresetPreviewColors.MOVE_TYPES_ENABLED
	Drawing.drawTrackerThemePreview(topboxX + 18, topboxY + 60, Theme.PresetPreviewColors, showColorBars)

	-- Draw all buttons
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
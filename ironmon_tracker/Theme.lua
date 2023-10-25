Theme = {
	-- Tracks if any theme elements were modified so we know if we need to save them to the Settings.ini file
	settingsUpdated = false,
	headerHighlightKey = "Intermediate text",

	-- 'Default' Theme, but will get replaced by what's in Settings.ini
	COLORS = {
		["Default text"] = Drawing.Colors.WHITE,
		["Lower box text"] = Drawing.Colors.WHITE,
		["Positive text"] = Drawing.Colors.GREEN,
		["Negative text"] = Drawing.Colors.RED,
		["Intermediate text"] = Drawing.Colors.YELLOW,
		["Header text"] = Drawing.Colors.WHITE,
		["Upper box border"] = Drawing.Colors.GRAY,
		["Upper box background"] = Drawing.Colors.DARKGRAY,
		["Lower box border"] = Drawing.Colors.GRAY,
		["Lower box background"] = Drawing.Colors.DARKGRAY,
		["Main background"] = Drawing.Colors.BLACK,
	},
	-- If move types are enabled then the Move Names themselves will be drawn with a color representing their type.
	MOVE_TYPES_ENABLED = true,
	-- Determines if text shadows are drawn
	DRAW_TEXT_SHADOWS = true,
}

-- Example Theme Code String
-- FFFFFF FFFFFF 00FF00 FF0000 FFFF00 FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1 1
-- [Default/Upper Box Text] [L.Box Text] [Positive] [Negative] [Intermediate] [Header] [U.Border] [U.Fill] [L.Border] [L.Fill] [Main Background]
-- ... [0/1: color moves by their type] [0/1: text shadows]

Theme.PresetsIndex = {
	ACTIVE = 1,
	DEFAULT = 2,
}
Theme.Presets = {}

Theme.PresetPreviewColors = {}
for k, v in pairs(Theme.COLORS) do
	Theme.PresetPreviewColors[k] = v
end
Theme.PresetPreviewColors.MOVE_TYPES_ENABLED = Theme.MOVE_TYPES_ENABLED
Theme.PresetPreviewColors.DRAW_TEXT_SHADOWS = Theme.DRAW_TEXT_SHADOWS

Theme.Screen = {
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
	displayingThemeManager = true,
	currentPreviewIndex = 1, -- current custom theme
}

-- Used to hold onto form handles while a pop-up form window is active
Theme.Manager = {
	SaveNewWarning = nil,
	SaveNewConfirm = nil,
}

Theme.Buttons = {
	MoveTypeEnabled = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return Resources.ThemeScreen.OptionColorBar end,
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 109, 8, 8 },
		clickableArea = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 109, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		toggleState = not Theme.MOVE_TYPES_ENABLED, -- Show the opposite of the Setting, can't change existing theme strings
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		updateSelf = function(self)
			 -- If "move types" enabled, then "show color bars" are disabled
			self.toggleState = not Theme.MOVE_TYPES_ENABLED
		end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			Theme.MOVE_TYPES_ENABLED = not Theme.MOVE_TYPES_ENABLED
			Theme.settingsUpdated = true
			Theme.refreshThemePreview()
		end
	},
	DrawTextShadows = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return Resources.ThemeScreen.OptionTextShadows end,
		box = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 120, 8, 8 },
		clickableArea = { Constants.SCREEN.WIDTH + 9, Constants.SCREEN.MARGIN + 120, Constants.SCREEN.RIGHT_GAP - 12, 10 },
		toggleState = Theme.DRAW_TEXT_SHADOWS,
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		updateSelf = function(self) self.toggleState = Theme.DRAW_TEXT_SHADOWS end,
		onClick = function(self)
			Theme.DRAW_TEXT_SHADOWS = not Theme.DRAW_TEXT_SHADOWS
			Theme.settingsUpdated = true
			Theme.refreshThemePreview()
		end
	},
	CyclePresetBackward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 12, Constants.SCREEN.MARGIN + 81, 10, 10, },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function(self)
			Theme.Screen.currentPreviewIndex = (Theme.Screen.currentPreviewIndex - 2) % #Theme.Presets + 1
			local themePreset = Theme.Presets[Theme.Screen.currentPreviewIndex or Theme.PresetsIndex.ACTIVE]
			Theme.refreshButtons()
			Theme.Buttons.RemoveTheme:resetButtonToDefault()
			Theme.importThemeFromText(themePreset.code, false)
		end
	},
	CyclePresetForward = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 55, Constants.SCREEN.MARGIN + 81, 10, 10, },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function(self)
			Theme.Screen.currentPreviewIndex = (Theme.Screen.currentPreviewIndex % #Theme.Presets) + 1
			local themePreset = Theme.Presets[Theme.Screen.currentPreviewIndex or Theme.PresetsIndex.ACTIVE]
			Theme.refreshButtons()
			Theme.Buttons.RemoveTheme:resetButtonToDefault()
			Theme.importThemeFromText(themePreset.code, false)
		end
	},
	LookupPreset = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 34, Constants.SCREEN.MARGIN + 81, 10, 10, },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function() Theme.openPresetsWindow() end
	},
	ApplyOrLoadTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if Theme.Screen.currentPreviewIndex == Theme.PresetsIndex.ACTIVE then
				return Resources.ThemeScreen.ButtonSaveAsNew
			else
				return Resources.ThemeScreen.ButtonApplyTheme
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 76, Constants.SCREEN.MARGIN + 24, 59, 11 },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function()
			if Theme.Screen.currentPreviewIndex == Theme.PresetsIndex.ACTIVE then -- Save New
				Theme.openSaveCurrentThemeWindow()
			else -- Apply theme
				for colorKey, colorValue in pairs(Theme.PresetPreviewColors) do
					-- Update the Theme settings only if those settings exist and the color is valid
					if Theme.COLORS[colorKey] ~= nil and type(colorValue) == "number" then
						Theme.COLORS[colorKey] = colorValue
					end
				end
				Theme.MOVE_TYPES_ENABLED = Theme.PresetPreviewColors.MOVE_TYPES_ENABLED
				Theme.DRAW_TEXT_SHADOWS = Theme.PresetPreviewColors.DRAW_TEXT_SHADOWS

				Theme.setNextMoveLevelHighlight(true)
				Main.SaveSettings(true)
				Theme.refreshThemePreview()
			end
		end
	},
	RemoveTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if self.confirmRemove then
				return Resources.ThemeScreen.ButtonRemoveConfirm
			else
				return Resources.ThemeScreen.ButtonRemove
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 76, Constants.SCREEN.MARGIN + 41, 59, 11 },
		confirmRemove = false,
		resetButtonToDefault = function(self)
			self.textColor = Theme.Screen.textColor
			self.confirmRemove = false
		end,
		isVisible = function()
			local isReservedTheme = Theme.Screen.currentPreviewIndex == Theme.PresetsIndex.ACTIVE or Theme.Screen.currentPreviewIndex == Theme.PresetsIndex.DEFAULT
			return Theme.Screen.displayingThemeManager and not isReservedTheme
		end, -- Hide for Custom & Default
		onClick = function(self)
			if self.confirmRemove then
				self:resetButtonToDefault()
				Theme.removeThemePreset()
			else
				self.textColor = "Negative text"
				self.confirmRemove = true
			end
			Program.redraw(true)
		end
	},
	ImportTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ThemeScreen.ButtonImport end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 76, Constants.SCREEN.MARGIN + 58, 59, 11 },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function() Theme.openImportWindow() end
	},
	ExportTheme = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ThemeScreen.ButtonExport end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 76, Constants.SCREEN.MARGIN + 75, 59, 11 },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function() Theme.openExportWindow() end
	},
	EditColors = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ThemeScreen.ButtonEditColors end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 74, 11 },
		isVisible = function() return Theme.Screen.displayingThemeManager end,
		onClick = function(self)
			Theme.Screen.displayingThemeManager = false
			Drawing.AnimatedPokemon:destroy() -- animated gif spazzes out, temporarily remove it while editing colors
			Theme.refreshThemePreview() -- also performs a screen redraw
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Theme.setNextMoveLevelHighlight(false) -- Update the next move level highlight color
		Main.SaveSettings() -- Always save all of the Options to the Settings.ini file

		if Theme.Screen.displayingThemeManager then
			Program.changeScreenView(NavigationMenu)
		else
			Theme.Screen.displayingThemeManager = true
			Drawing.AnimatedPokemon:create() -- restore the animated gif
			Theme.refreshThemePreview() -- also performs a screen redraw
		end
	end),
}

function Theme.initialize()
	Theme.createButtons()

	for _, button in pairs(Theme.Buttons) do
		button.textColor = Theme.Screen.textColor
		button.boxColors = { Theme.Screen.borderColor, Theme.Screen.boxFillColor }
	end

	Theme.resetPresets()
	Theme.populateThemePresets()
	Theme.loadPresets()
	Theme.refreshThemePreview()
end

function Theme.createButtons()
	local optionKeyMap = {
		{ "Default text", "ColorDefaultText", },
		{ "Lower box text", "ColorLowerBoxText", },
		{ "Positive text", "ColorPositiveText", },
		{ "Negative text", "ColorNegativeText", },
		{ "Intermediate text", "ColorIntermediateText", },
		{ "Header text", "ColorHeaderText", },
		{ "Upper box border", "ColorUpperBoxBorder", },
		{ "Upper box background", "ColorUpperBoxBackground", },
		{ "Lower box border", "ColorLowerBoxBorder", },
		{ "Lower box background", "ColorLowerBoxBackground", },
		{ "Main background", "ColorMainBackground", },
	}

	local startX = Constants.SCREEN.WIDTH + 9
	local startY = Constants.SCREEN.MARGIN + 13

	for _, optionTuple in ipairs(optionKeyMap) do
		Theme.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.COLORPICKER,
			getText = function(self) return Resources.ThemeScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 10 },
			box = { startX, startY, 8, 8 },
			themeColor = optionTuple[1],
			isVisible = function() return not Theme.Screen.displayingThemeManager end,
			onClick = function() Theme.openColorPickerWindow(optionTuple[1]) end
		}
		startY = startY + Constants.SCREEN.LINESPACING
	end
end

function Theme.refreshButtons()
	for _, button in pairs(Theme.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function Theme.resetPresets()
	Theme.Presets = {
		{
			getText = function(self) return Resources.ThemeScreen.LabelActiveCustomTheme or "Active Theme (Custom)" end,
			code = "", -- updated later in refreshThemePreview()
		},
		{
			getText = function(self) return Resources.ThemeScreen.LabelDefaultTheme or "Default Theme" end,
			code = "FFFFFF FFFFFF 00FF00 FF0000 FFFF00 FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1 1",
		},
	}
end

function Theme.loadPresets()
	if not FileManager.fileExists(FileManager.Files.THEME_PRESETS) then return end

	for index, line in ipairs(FileManager.readLinesFromFile(FileManager.Files.THEME_PRESETS)) do
		local firstHexIndex = line:find("%x%x%x%x%x%x")
		if firstHexIndex ~= nil then
			local themeCode = line:sub(firstHexIndex)
			local themeName
			if firstHexIndex <= 2 then
				themeName = "Untitled " .. index
			else
				themeName = line:sub(1, firstHexIndex - 2)
			end

			-- Don't allow importing "Active Theme (Custom)" as that is reserved
			if themeName ~= Theme.Presets[Theme.PresetsIndex.ACTIVE]:getText() then
				local themePreset = {
					getText = function(self) return themeName end,
					code = Theme.formatAsProperThemeCode(themeCode)
				}
				table.insert(Theme.Presets, themePreset)
			end
		end
	end
end

-- Calculates a color for the next move level highlighting based off contrast ratios of chosen theme colors
function Theme.setNextMoveLevelHighlight(forced)
	if not forced and not Theme.settingsUpdated then return end
	local mainBGColor = Theme.COLORS["Main background"]
	local maxContrast = 0
	local colorKey = ""
	for key, color in pairs(Theme.COLORS) do
		if color ~= mainBGColor and color ~= Theme.COLORS["Header text"] and color ~= Theme.COLORS["Default text"] then
			local bgContrast = Utils.calculateContrastRatio(color, mainBGColor)
			if bgContrast > maxContrast then
				maxContrast = bgContrast
				colorKey = key
			end
		end
	end
	Theme.headerHighlightKey = colorKey

	-- Update any buttons with new color
	TrackerScreen.Buttons.MovesHistory.textColor = colorKey
	LogOverlay.refreshButtons()
end

-- Attempts to fill in missing theme code information for old theme codes
function Theme.formatAsProperThemeCode(themeCode)
	-- The first time theme codes were changed was to add "Lower box text" hex code in the second slot
	if Theme.isOldThemeString(themeCode) then
		local firstHexCode = themeCode:sub(1, 7) -- includes the trailing space
		themeCode = firstHexCode .. themeCode -- duplicate "Default text" to fill in
	end

	-- The second time theme codes were changed was to add "Text shadows" as a boolean option at the end
	if string.len(themeCode) < 80 then
		themeCode = themeCode .. " 1" -- Text shadows were enabled by default on all old themes
	end

	return themeCode
end

-- Refreshes the Theme preview thumbnail to show a matching Theme code, or custom, then redraws the screen
function Theme.refreshThemePreview()
	-- If changes were made to the current Tracker Theme, store those changes as "Active Theme (Custom)"
	local currentThemeCode = Theme.exportThemeToText()
	Theme.Presets[Theme.PresetsIndex.ACTIVE].code = currentThemeCode

	-- Check if the current Theme is one of the saved ones, otherwise display the custom theme
	Theme.Screen.currentPreviewIndex = 1
	for index, themePreset in ipairs(Theme.Presets) do
		if index ~= Theme.PresetsIndex.ACTIVE and themePreset.code == currentThemeCode then
			Theme.Screen.currentPreviewIndex = index
			break
		end
	end

	Theme.Buttons.RemoveTheme:resetButtonToDefault()
	Theme.refreshButtons()
	Theme.importThemeFromText(currentThemeCode, false)
end

-- Imports a theme config string into the Tracker, reloads all Tracker visuals, and flags to update Settings.ini
-- returns true if successful; false otherwise.
-- applyTheme: if false, this won't replace current theme, but set it as the preview for the mini tracker preview
function Theme.importThemeFromText(themeCode, applyTheme)
	if Utils.isNilOrEmpty(themeCode) then
		return false
	end

	themeCode = Theme.formatAsProperThemeCode(themeCode)

	-- A valid string has at minimum N total hex codes (7 chars each including spaces) and a two bits for boolean options
	local totalHexCodes = 11

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
	if Program.currentScreen == Theme then
		Program.redraw(true)
	end

	return true
end

-- A simple way to check if user imports an old theme config string
function Theme.isOldThemeString(themeCode)
	if Utils.isNilOrEmpty(themeCode) then return false end

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

-- Exports the current Theme as a string code that can be shared and imported by others
function Theme.exportThemeToText()
	-- Build base theme config string
	local themeCode = ""
	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do
		-- Format each color code as "AABBCC", instead of "0xAABBCC" or "0xFFAABBCC"
		themeCode = themeCode .. string.sub(string.format("%#x", Theme.COLORS[colorkey]), 5) .. " "
	end

	-- Append other theme config boolean options at the end
	themeCode = themeCode .. Utils.inlineIf(Theme.MOVE_TYPES_ENABLED, "1", "0") .. " " .. Utils.inlineIf(Theme.DRAW_TEXT_SHADOWS, "1", "0")

	return string.upper(themeCode)
end

---Returns a the name of a theme if it exist in the theme library; if it doesn't, returns "Custom"
---@param themeCode string
---@return string
function Theme.getThemeNameFromCode(themeCode)
	themeCode = Theme.formatAsProperThemeCode(themeCode)
	for i, themePair in ipairs(Theme.Presets or {}) do
		if themeCode == themePair.code and i ~= 1 then -- skip "Active theme"
			return themePair:getText()
		end
	end
	return "Custom"
end

function Theme.openColorPickerWindow(colorkey)
	local picker = ColorPicker.new(colorkey)
	Input.currentColorPicker = picker
	picker:show()
end

function Theme.openImportWindow()
	local form = Utils.createBizhawkForm(Resources.ThemeScreen.ButtonImport, 515, 125)

	forms.label(form, Resources.ThemeScreen.PromptEnterThemeCode .. ":", 9, 10, 300, 20)
	local importTextBox = forms.textbox(form, "", 480, 20, nil, 10, 30)
	forms.button(form, Resources.AllScreens.Import, function()
		local formInput = forms.gettext(importTextBox)
		if formInput ~= nil then
			-- Check if the import was successful
			local success = Theme.importThemeFromText(formInput, true)
			if success then
				Theme.refreshThemePreview()
			else
				print("Error importing Theme Config string:")
				print(">> " .. formInput)
				Main.DisplayError("The theme config string you entered is invalid.\n\nPlease enter a valid theme config string.")
			end
		end
		Utils.closeBizhawkForm(form)
	end, 212, 55)
end

function Theme.openExportWindow()
	local form = Utils.createBizhawkForm(Resources.ThemeScreen.ButtonExport, 515, 150)

	local themePreset = Theme.Presets[Theme.Screen.currentPreviewIndex]

	local themeLabel = string.format("%s: %s", Resources.ThemeScreen.PromptThemeFor, themePreset:getText())
	forms.label(form, themeLabel, 9, 10, 300, 20)
	forms.label(form, Resources.ThemeScreen.PromptCopyThemeCode .. ":", 9, 30, 300, 20)
	forms.textbox(form, themePreset.code or "", 480, 20, nil, 10, 55)
	forms.button(form, Resources.AllScreens.Close, function()
		Utils.closeBizhawkForm(form)
	end, 212, 80)
end

function Theme.openPresetsWindow()
	local form = Utils.createBizhawkForm(Resources.ThemeScreen.Title, 360, 105)

	local themeNameList = {}
	for _, themePreset in ipairs(Theme.Presets) do
		table.insert(themeNameList, themePreset:getText())
	end

	forms.label(form, Resources.ThemeScreen.PromptSelectPreset .. ":", 49, 10, 250, 20)
	local presetDropdown = forms.dropdown(form, {["Init"]="Loading Presets"}, 50, 30, 145, 30)
	forms.setdropdownitems(presetDropdown, themeNameList, false) -- Required to prevent alphabetizing the list
	forms.setproperty(presetDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(presetDropdown, "AutoCompleteMode", "Append")

	forms.button(form, Resources.AllScreens.Preview, function()
		local themeName = forms.gettext(presetDropdown)

		for index, themePreset in ipairs(Theme.Presets) do
			if themePreset:getText() == themeName then
				Theme.Screen.currentPreviewIndex = index
				break
			end
		end

		local themePreset = Theme.Presets[Theme.Screen.currentPreviewIndex or Theme.PresetsIndex.ACTIVE]
		Theme.refreshButtons()
		Theme.Buttons.RemoveTheme:resetButtonToDefault()
		Theme.importThemeFromText(themePreset.code, false)

		Utils.closeBizhawkForm(form)
	end, 212, 29)
end

function Theme.openSaveCurrentThemeWindow()
	local form = Utils.createBizhawkForm(Resources.ThemeScreen.PromptSaveAsTitle, 350, 145)

	forms.label(form, Resources.ThemeScreen.PromptEnterNameForTheme .. ":", 18, 10, 330, 20)
	local saveTextBox = forms.textbox(form, "", 290, 30, nil, 20, 30)
	forms.setproperty(saveTextBox, "MaxLength", 80)

	Theme.Manager.SaveNewWarning = forms.label(form, "", 18, 55, 330, 20)
	forms.setproperty(Theme.Manager.SaveNewWarning, "ForeColor", "Red")

	Theme.Manager.SaveNewConfirm = forms.button(form, Resources.AllScreens.Save, function()
		-- Clear out warning texts
		forms.settext(Theme.Manager.SaveNewWarning, "")

		local themeName = forms.gettext(saveTextBox)
		if Utils.isNilOrEmpty(themeName) then
			return
		end

		local existingPreset = nil
		local existingPresetIndex = nil
		for index, themePreset in ipairs(Theme.Presets) do
			if themePreset:getText() == themeName then
				existingPreset = themePreset
				existingPresetIndex = index
				break
			end
		end

		-- Check a few conditions that would prevent the user from using a particular Theme name
		if existingPresetIndex == Theme.PresetsIndex.ACTIVE or existingPresetIndex == Theme.PresetsIndex.DEFAULT then
			-- Don't allow importing "Active Theme (Custom)" or "Default Theme" as that is reserved
			forms.settext(Theme.Manager.SaveNewWarning, "Cannot use a reserved Theme name")
			forms.settext(Theme.Manager.SaveNewConfirm, Resources.AllScreens.Save)
			return
		elseif themeName:find("%x%x%x%x%x%x") then
			-- Don't allow six consectuive hexcode characters, as this screws with parsing it later
			forms.settext(Theme.Manager.SaveNewWarning, "Name cannot have 6 consectuive hexcode characters (0-9A-F)")
			forms.settext(Theme.Manager.SaveNewConfirm, Resources.AllScreens.Save)
			return
		elseif existingPreset ~= nil and forms.gettext(Theme.Manager.SaveNewConfirm) ~= Resources.AllScreens.Yes then
			-- If the Theme name is already in use, warn the user first
			forms.settext(Theme.Manager.SaveNewWarning, "A Theme with that name already exists. Overwrite?")
			forms.settext(Theme.Manager.SaveNewConfirm, Resources.AllScreens.Yes)
			return
		end
		Theme.Manager.SaveNewWarning = nil
		Theme.Manager.SaveNewConfirm = nil

		local themeCode = Theme.exportThemeToText()

		-- If a theme with that name already exists, replace it; otherwise add a reference for it
		if existingPreset ~= nil then
			-- Remove the old theme from the presets file
			FileManager.removeCustomThemeFromFile(themeName, existingPreset.code)
			-- Update the old theme with the new code
			existingPreset.code = themeCode
		else
			-- Create the new theme and add it to the library list
			existingPreset = {
				getText = function(self) return themeName end,
				code = themeCode
			}
			table.insert(Theme.Presets, existingPreset)
		end

		-- Add the saved theme to the presets file and refresh
		FileManager.addCustomThemeToFile(themeName, themeCode)
		Theme.refreshThemePreview()

		Utils.closeBizhawkForm(form)
	end, 91, 75)
	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 176, 75)
end

-- Preloaded Theme Presets are added to the Theme Presets file only if that file doesn't already exist
function Theme.populateThemePresets()
	if FileManager.fileExists(FileManager.Files.THEME_PRESETS) then
		return
	end

	-- Add in the preloaded themes in a predefined order (important to show "Theme" vs. "Theme v2" naming)
	for _, themeName in ipairs(Constants.OrderedLists.PRELOADED_THEMES) do
		local themeCode = Constants.PreloadedThemes[themeName]
		FileManager.addCustomThemeToFile(themeName, themeCode)
	end
end

function Theme.removeThemePreset()
	-- Cannot remove "Custom" or Default themes
	if Theme.Screen.currentPreviewIndex == 1 and Theme.Screen.currentPreviewIndex == 2 then
		return
	end

	-- Remove the Theme from the ThemePresets.txt file, and each Preset table
	local themePresetToRemove = Theme.Presets[Theme.Screen.currentPreviewIndex]
	FileManager.removeCustomThemeFromFile(themePresetToRemove:getText(), themePresetToRemove.code)
	table.remove(Theme.Presets, Theme.Screen.currentPreviewIndex)

	-- Show the Theme preview next in line
	Theme.Screen.currentPreviewIndex = (Theme.Screen.currentPreviewIndex - 1) % #Theme.Presets + 1
	local themePreset = Theme.Presets[Theme.Screen.currentPreviewIndex or Theme.PresetsIndex.ACTIVE]
	Theme.importThemeFromText(themePreset.code, false)
	Theme.refreshButtons()
end

-- USER INPUT FUNCTIONS
function Theme.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, Theme.Buttons)
end

-- DRAWING FUNCTIONS
function Theme.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[Theme.Screen.boxFillColor])

	if Theme.Screen.displayingThemeManager then
		Theme.drawThemeLibrary()
	else
		Theme.drawEditThemeColors()
	end
end

function Theme.drawThemeLibrary()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[Theme.Screen.boxFillColor])
	local topbox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = 82,
	}
	local botbox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = topbox.y + topbox.height + 13,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = 45,
	}

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.ThemeScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topbox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top Theme screen view box
	gui.drawRectangle(topbox.x, topbox.y, topbox.width, topbox.height, Theme.COLORS[Theme.Screen.borderColor], Theme.COLORS[Theme.Screen.boxFillColor])

	local themePreset = Theme.Presets[Theme.Screen.currentPreviewIndex]
	Drawing.drawText(topbox.x + 3, Constants.SCREEN.MARGIN + 12, themePreset:getText(), Theme.COLORS[Theme.Screen.textColor], shadowcolor)

	local showColorBars = not Theme.PresetPreviewColors.MOVE_TYPES_ENABLED
	Drawing.drawTrackerThemePreview(topbox.x + 13, topbox.y + 16, Theme.PresetPreviewColors, showColorBars)

	-- Draw bottom Theme screen view box and its header
	gui.drawRectangle(botbox.x, botbox.y, botbox.width, botbox.height, Theme.COLORS[Theme.Screen.borderColor], Theme.COLORS[Theme.Screen.boxFillColor])
	Drawing.drawText(botbox.x + 0, botbox.y - 11, Resources.ThemeScreen.HeaderActiveThemeOptions .. ":", Theme.COLORS["Header text"], headerShadow)

	-- Draw all buttons
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

function Theme.drawEditThemeColors()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[Theme.Screen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.ThemeScreen.TitleEditingActiveTheme)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw Theme screen view box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[Theme.Screen.borderColor], Theme.COLORS[Theme.Screen.boxFillColor])

	-- Draw all buttons
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
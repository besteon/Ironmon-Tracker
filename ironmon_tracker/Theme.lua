Theme = {}

-- Update drawing the theme page if true
Theme.redraw = true

-- Tracks if any theme elements were modified so we know if we need to update Settings.ini or not.
Theme.updated = false

-- Sample Themes: https://colorhunt.co/palettes/popular
Theme.Presets = {
    PresetNames = {
        "Default",
        "Cotton Candy",
        "Spaceship",
    },
    PresetConfigStrings = {
        ["Default"] = "FFFFFF 00FF00 FF0000 FFC20A FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1",
        ["Cotton Candy"] = "000000 1A85FF D41159 994F00 C0C0C0 D35FB7 FFCBF3 1A85FF A0D3FF 5D3A9B 0",
        ["Spaceship"] = "222831 00ADB5 393E46 00ADB5 393E46 EEEEEE EEEEEE 00ADB5 7F8487 F73D93 1", -- TODO: Update/Replace this
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
	box = {GraphicConstants.SCREEN_WIDTH + 10, GraphicConstants.SCREEN_HEIGHT - 20, 74, 11},
    boxColors = { "Lower box border", "Lower box background" },
    confirmReset = false,
	onClick = function() Theme.tryRestoreDefaultTheme() end
}

-- A button to close the settings page and save the settings if any changes occurred
Theme.closeButton = {
	text = "Close",
	textColor = "Default text",
	box = {GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 40, GraphicConstants.SCREEN_HEIGHT - 20, 30, 11},
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
        Settings.theme["MOVE_TYPES_ENABLED"] = Utils.inlineIf(Settings.theme["MOVE_TYPES_ENABLED"], false, true) -- toggle the setting
        GraphicConstants.MOVE_TYPES_ENABLED = Settings.theme["MOVE_TYPES_ENABLED"]
        Theme.redraw = true
        Theme.updated = true
    end
}

-- Stores the theme elements in the Settings.ini file into configurable toggles in the Tracker
Theme.themeButtons = {}

function Theme.buildTrackerThemeButtons()
    local index = 1
    local heightOffset = 15 + index * 10
    local button = {}

    for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
        button = {
            text = colorkey,
            box = {GraphicConstants.SCREEN_WIDTH + 10, heightOffset, 8, 8},
            textColor = "Default text",
            themeColor = colorkey,
            onClick = function() Theme.requestNewColorFromUser(colorkey) end
        }

        table.insert(Theme.themeButtons, button)
        index = index + 1
        heightOffset = 15 + index * 10
    end

    -- Adjust the extra options positions based on the verical space left
    Theme.moveTypeEnableButton.box[2] = heightOffset
end

-- Loads the theme defined in Settings into the Tracker's contants
function Theme.loadTheme()
    -- Load the Theme as defined in the Settings
    for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
        GraphicConstants.THEMECOLORS[colorkey] = tonumber(Settings.theme[string.gsub(colorkey, " ", "_")], 16) + 0xFF000000
    end

    GraphicConstants.MOVE_TYPES_ENABLED = Settings.theme["MOVE_TYPES_ENABLED"]

    Theme.redraw = true
end

-- Imports a theme config string into the Tracker, reloads all Tracker visuals, and flags to update Settings.ini
-- returns true if successful; false otherwise.
function Theme.importThemeFromText(theme_config)
    if theme_config == nil then
        return false
    elseif string.len(theme_config) < 71 then -- ten total color hex codes is 70 characters, plus 1 additional for move typing
        return false
    end

    -- Verify the theme config is correct and can be parsed
    local theme_colors = {}
    for color_text in string.gmatch(string.sub(theme_config, 1, 69), "[^%s]+") do
        if string.len(color_text) ~= 6 then
            return false
        end
        local color = tonumber(color_text, 16)
        if color < 0x000000 or color > 0xFFFFFF then
            return false
        end

        theme_colors[#theme_colors + 1] = color_text
    end

    -- Apply the imported theme config to our Settings, then load it
    local index = 1
    for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
        Settings.theme[string.gsub(colorkey, " ", "_")] = theme_colors[index]
        index = index + 1
    end
    Settings.theme["MOVE_TYPES_ENABLED"] = Utils.inlineIf(string.sub(theme_config, 71, 71) == "0", false, true)

    Theme.updated = true
    Theme.loadTheme()

    return true
end

-- Exports the theme options that can be customized into a string that can be shared and imported
-- Example string (default theme): "FFFFFF 00FF00 FF0000 FFC20A FFFFFF AAAAAA 222222 AAAAAA 222222 000000 1"
function Theme.exportThemeToText()
    local exportedTheme = ""

    -- Build base theme config string
    for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
        -- Format each color code as "AABBCC", instead of "0xAABBCC" or "0xFFAABBCC"
        exportedTheme = exportedTheme .. string.sub(string.format("%#x", GraphicConstants.THEMECOLORS[colorkey]), 5) .. " "
    end

    -- Append other theme config options at the end
    exportedTheme = exportedTheme .. Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, 1, 0)

    return string.upper(exportedTheme)
end

function Theme.requestNewColorFromUser(colorkey)
    local colorForm = forms.newform(290, 100, "Enter a new color...", function() return nil end)
    forms.label(colorForm, colorkey .. " color:", 5, 5)
    local textBox = forms.textbox(colorForm, string.sub(string.format("%#x", GraphicConstants.THEMECOLORS[colorkey]), 5), 60, 35, "HEX", 5, 30)

    forms.button(colorForm, "Save", function()
        local textValue = forms.gettext(textBox)
        if textValue == nil then
            print("Unable to set color. The inputted color is nil.")
            return
        end
    
        Settings.theme[string.gsub(colorkey, " ", "_")] = textValue
        Theme.updated = true
        Theme.loadTheme()
        forms.destroy(colorForm)
    end, 100, 30)
end

function Theme.openImportWindow()
    local themeImportForm = forms.newform(490, 70, "Enter a Theme configuration string to import:", function() return end)
    local themeImportTextBox = forms.textbox(themeImportForm, "[Ctrl+V to Paste here]", 400, 20, 5, 5)
    forms.button(themeImportForm, "Import", function()
        local formInput = forms.gettext(themeImportTextBox)
        if formInput ~= nil then
            -- Check if the import was successful
            if not Theme.importThemeFromText(formInput) then
                print("Error importing Theme Config string:")
                print(">> " .. formInput)
            end
        end
        forms.destroy(themeImportForm)
    end, 400, 5)
end

function Theme.openExportWindow()
    local themeExportForm = forms.newform(470, 70, "Copy (Ctrl+C) your Theme configuration below:", function() return end)
    forms.textbox(themeExportForm, Theme.exportThemeToText(), 430, 20, 5, 5)
end

function Theme.openPresetsWindow()
    local presetsForm = forms.newform(350, 100, "Choose a preset...", function() return nil end)
    forms.label(presetsForm, "Select a theme preset to use:", 5, 5)
    local presetDropdown = forms.dropdown(presetsForm, {["Init"]="Loading Presets"}, 5, 30, 160, 30)
    forms.setdropdownitems(presetDropdown, Theme.Presets.PresetNames, false) -- Required to prevent alphabetizing the list

    forms.button(presetsForm, "Load", function()
        Theme.importThemeFromText(Theme.Presets.PresetConfigStrings[forms.gettext(presetDropdown)])
        Theme.updated = true
        Theme.loadTheme()
        forms.destroy(presetsForm)
    end, 185, 30)
end

-- Restores the Theme customizations to the default look-and-feel, or prompts for confirmation
-- A follow through onclick would be required to reset to default
function Theme.tryRestoreDefaultTheme()
    if Theme.restoreDefaultsButton.confirmReset then
        Theme.restoreDefaultsButton.text = "Restore Defaults"
        Theme.restoreDefaultsButton.textColor = "Default text"
        Theme.restoreDefaultsButton.confirmReset = false

        Theme.importThemeFromText(Theme.Presets.PresetConfigStrings["Default"])
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

    -- Save the Settings.ini file if any changes were made
    if Theme.updated then
        print("Saving Theme configuration to Settings.ini, this takes a few seconds.")
        INI.save("Settings.ini", Settings)
        Theme.updated = false
    end

    -- Inform the Tracker Program to load the Options screen
    Options.redraw = true
    Program.state = State.SETTINGS
end
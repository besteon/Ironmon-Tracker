Theme = {}

-- Update drawing the theme page if true
Theme.redraw = true

-- Tracks if any theme elements were modified so we know if we need to update Settings.ini or not.
Theme.updated = false

Theme.importThemeButton = {
	text = "Import",
	box = {
		GraphicConstants.SCREEN_WIDTH + 10,
		8,
		34,
		11,
	},
    backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL },
	textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
	-- onClick = function(): currently handled in the Input object
}

Theme.exportThemeButton = {
	text = "Export",
	box = {
		GraphicConstants.SCREEN_WIDTH + 10 + 30 + 10,
		8,
		34,
		11,
	},
    backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL },
	textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
	-- onClick = function(): currently handled in the Input object
}

-- A button to navigate to the Theme menu for customizing the Tracker's look and feel
Theme.restoreDefaultsButton = {
	text = "Restore Defaults",
	box = {
		GraphicConstants.SCREEN_WIDTH + 10,
		GraphicConstants.SCREEN_HEIGHT - 20,
		74,
		11,
	},
	backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL },
	textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
	-- onClick = function(): currently handled in the Input object
}

-- A button to close the settings page and save the settings if any changes occurred
Theme.closeButton = {
	text = "Close",
	box = {
		GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 40,
		GraphicConstants.SCREEN_HEIGHT - 20,
		30,
		11,
	},
	backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL },
	textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
	-- onClick = function(): currently handled in the Input object
}

-- Stores the theme elements in the Settings.ini file into configurable toggles in the Tracker
-- Manually listed all the buttons here to preserve the order that they are displayed in the menu
Theme.themeButtons = {
	{ -- BACKGROUND_COLOR button
        text = "Main background",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 25, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "BACKGROUND_COLOR",
        themeColor = GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR,
        onClick = function() Theme.updateThemeColor("BACKGROUND_COLOR", "Main background") end
	},
	{ -- BOX_TOP_FILL button
        text = "Upper-box fill",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 35, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "BOX_TOP_FILL",
        themeColor = GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL,
        onClick = function() Theme.updateThemeColor("BOX_TOP_FILL", "Upper-box fill") end
	},
	{ -- BOX_TOP_BORDER button
        text = "Upper-box border",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 45, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "BOX_TOP_BORDER",
        themeColor = GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER,
        onClick = function() Theme.updateThemeColor("BOX_TOP_BORDER", "Upper-box border") end
	},
	{ -- BOX_BOTTOM_FILL button
        text = "Lower-box fill",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 55, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "BOX_BOTTOM_FILL",
        themeColor = GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL,
        onClick = function() Theme.updateThemeColor("BOX_BOTTOM_FILL", "Lower-box fill") end
	},
	{ -- BOX_BOTTOM_BORDER button
        text = "Lower-box border",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 65, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "BOX_BOTTOM_BORDER",
        themeColor = GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER,
        onClick = function() Theme.updateThemeColor("BOX_BOTTOM_BORDER", "Lower-box border") end
	},
	{ -- TEXT_DEFAULT button
        text = "Default text",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 75, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "TEXT_DEFAULT",
        themeColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        onClick = function() Theme.updateThemeColor("TEXT_DEFAULT", "Default text") end
	},
	{ -- TEXT_HEADER button
        text = "Header text",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 85, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "TEXT_HEADER",
        themeColor = GraphicConstants.LAYOUTCOLORS.TEXT_HEADER,
        onClick = function() Theme.updateThemeColor("TEXT_HEADER", "Header text") end
	},
	{ -- TEXT_POSITIVE button
        text = "Positive text",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 95, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "TEXT_POSITIVE",
        themeColor = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE,
        onClick = function() Theme.updateThemeColor("TEXT_POSITIVE", "Positive text") end
	},
	{ -- TEXT_MIDDLE_VALUE button
        text = "Neutral text",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 105, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "TEXT_MIDDLE_VALUE",
        themeColor = GraphicConstants.LAYOUTCOLORS.TEXT_MIDDLE_VALUE,
        onClick = function() Theme.updateThemeColor("TEXT_MIDDLE_VALUE", "Neutral text") end
	},
	{ -- TEXT_NEGATIVE button
        text = "Negative text",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 115, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "TEXT_NEGATIVE",
        themeColor = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE,
        onClick = function() Theme.updateThemeColor("TEXT_NEGATIVE", "Negative text") end
	},
	{ -- MOVE_TYPES_ENABLED button
        text = "Enable move-type colors",
        box = {GraphicConstants.SCREEN_WIDTH + 5 + 3, 125, 8, 8},
        textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
        themeKey = "MOVE_TYPES_ENABLED",
        backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOT_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOT_FILL },
        optionColor = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE,
        onClick = function()
            Settings.theme["MOVE_TYPES_ENABLED"] = Utils.inlineIf(Settings.theme["MOVE_TYPES_ENABLED"], false, true) -- toggle the setting
            GraphicConstants.MOVE_TYPES_ENABLED = Settings.theme["MOVE_TYPES_ENABLED"]
            Theme.updated = true
            return Settings.theme["MOVE_TYPES_ENABLED"]
        end
	},
}

-- Loads the theme defined in Settings into the Tracker's contants
function Theme.loadTheme()
    -- First load the theme from Settings
    for _, button in pairs(Theme.themeButtons) do
        if button.themeKey == "MOVE_TYPES_ENABLED" then
            GraphicConstants.MOVE_TYPES_ENABLED = Settings.theme[button.themeKey]
        else
            GraphicConstants.LAYOUTCOLORS[button.themeKey] = tonumber(Settings.theme[button.themeKey], 16) + 0xFF000000
        end
    end

    -- Apply the theme to the buttons on the Tracker
    for i = 1, 6, 1 do
        Buttons[i].backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL }
		Buttons[i].textcolor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
    end
    PCHealTrackingButton.backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL }
	PCHealTrackingButton.textcolor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
	PCHealTrackingButton.togglecolor = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
    Buttons[9].textcolor = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
    Buttons[10].textcolor = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE

    -- Apply the theme to the buttons in the Options Menu
    for _, button in pairs(Options.optionsButtons) do
        button.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL }
        button.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
        button.optionColor = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
    end
    Options.closeButton.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL }
	Options.closeButton.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
    Options.themeButton.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL }
	Options.themeButton.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT

    -- Apply the theme to the buttons in the Theme menu
    for _, button in pairs(Theme.themeButtons) do
        if button.themeKey == "MOVE_TYPES_ENABLED" then
            button.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL }
            button.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
            button.optionColor = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
        else
            button.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
            button.themeColor = GraphicConstants.LAYOUTCOLORS[button.themeKey]
        end
    end
    Theme.importThemeButton.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL }
	Theme.importThemeButton.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
    Theme.exportThemeButton.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL }
	Theme.exportThemeButton.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
    Theme.restoreDefaultsButton.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL }
	Theme.restoreDefaultsButton.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
    Theme.closeButton.backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL }
	Theme.closeButton.textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT

    Theme.redraw = true
end

function Theme.updateThemeColor(key, element_label, color_text)
    local newThemeColor = Theme.requestNewColorFromUser(element_label)

    if newThemeColor ~= nil then
        -- Save the new theme element color both to the Settings.ini and to the current graphic contants used to draw the Tracker
        print("Color picked: " .. key .. ": " .. newThemeColor)
        Settings.theme[key] = newThemeColor
        GraphicConstants.LAYOUTCOLORS[key] = tonumber(newThemeColor, 16) + 0xFF000000
    end
    Theme.updated = true

    return newThemeColor -- is this needed?
end

-- TODO: This doesnt appear to work either.
function Theme.requestNewColorFromUser(element_label, color_text)
    local themeColor = nil

    local colorForm = forms.newform(290, 120, "Enter a new color...", function() return nil end)
    forms.label(colorForm, element_label, 5, 5)
    local textBox = forms.textbox(colorForm, color_text, 75, 35, "HEX", 5, 5)
    forms.button(colorForm, "Save", function()
        local colorFormText = forms.gettext(textBox)
        if colorFormText ~= nil then
            -- only parse the last 6 characters of the string, if less then just return nil
            local len = string.len(colorFormText)
            if len >= 6 then
                themeColor = string.sub(colorFormText, len - 5)
            end
        end
        forms.destroy(colorForm)
    end, 110, 20)

    print(Utils.inlineIf(themeColor ~= nil, themeColor, "Empty-Hex"))

    return themeColor
end

-- Imports a theme config string into the Tracker, reloads all Tracker visuals, and flags to update Settings.ini
-- returns true if successful; false otherwise.
function Theme.importThemeFromText(theme_config)
    if theme_config == nil then
        return false
    elseif string.len(theme_config) ~= 71 then -- ten total color hex codes is 70 characters, plus 1 additional for move typing
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
    for _, button in pairs(Theme.themeButtons) do
        if button.themeKey == "MOVE_TYPES_ENABLED" then
            Settings.theme[button.themeKey] = Utils.inlineIf(string.sub(theme_config, -1, -1) == "0", false, true)
        else
            Settings.theme[button.themeKey] = theme_colors[index]
        end
        index = index + 1
    end

    Theme.updated = true
    Theme.loadTheme()

    return true
end

-- Exports the theme options that can be customized into a string that can be shared and imported
-- Example string (default theme): "000000 222222 AAAAAA 222222 AAAAAA FFFFFF FFFFFF 00FF00 FFC20A FF0000 1"
function Theme.exportThemeToText()
    local exportedTheme = ""

    -- Build base theme config string
    for _, button in ipairs(Theme.themeButtons) do
        local text_to_append = "ERROR!"

        -- Don't parse color codes from boolean toggle buttons
        if button.optionColor == nil then
            -- Format each color code as "AABBCC" instead of "0xAABBCC"
            text_to_append = string.sub(string.format("%#x", button.themeColor), 5)
        elseif button.themeKey ~= nil then
            text_to_append = Utils.inlineIf(GraphicConstants[button.themeKey], 1, 0)
        end
        exportedTheme = exportedTheme .. text_to_append .. " "
    end

    return string.upper(string.sub(exportedTheme, 1, -2)) -- Further formatting, and remove trailing whitespace
end

-- Restores the Theme customizations to the default look-and-feel. Confirmation from user is recommended.
function Theme.restoreDefaultTheme()
    Settings.theme["MOVE_TYPES_ENABLED"] = true

    Settings.theme["BACKGROUND_COLOR"] = "000000"
    Settings.theme["BOX_TOP_FILL"] = "222222"
    Settings.theme["BOX_TOP_BORDER"] = "AAAAAA"
    Settings.theme["BOX_BOTTOM_FILL"] = "222222"
    Settings.theme["BOX_BOTTOM_BORDER"] = "AAAAAA"

    Settings.theme["TEXT_DEFAULT"] = "FFFFFF"
    Settings.theme["TEXT_HEADER"] = "FFFFFF"
    Settings.theme["TEXT_POSITIVE"] = "00FF00"
    Settings.theme["TEXT_MIDDLE_VALUE"] = "FFC20A"
    Settings.theme["TEXT_NEGATIVE"] = "FF0000"

    Theme.updated = true
    Theme.loadTheme()
end
Theme = {}

-- Update drawing the theme page if true
Theme.redraw = true

-- Tracks if any theme elements were modified so we know if we need to update Settings.ini or not.
Theme.updated = false

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
}

-- Stores the theme elements in the Settings.ini file into configurable toggles in the Tracker
Theme.themeButtons = {}

function Theme.buildTrackerThemeButtons()
    Theme.themeButtons = {}

	local borderMargin = 5
	local themeHeightStart = 25
	for key, value in pairs(Settings.theme) do
        if value == nil then
            value = "000000"
        end
        local element_label = string.sub(key, 1, 1) .. string.sub(string.lower(string.gsub(key, "_", " ")), 2)
        local button = {
            text = element_label,
            box = {
                GraphicConstants.SCREEN_WIDTH + borderMargin + 3,
                themeHeightStart,
                8,
                8,
            },
            textColor = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT,
            themeKey = key,
            themeColor = value,
            onClick = function() -- return the updated value to be saved into this button's themeColor value
                local newThemeColor = Theme.requestNewColor(element_label)

                if newThemeColor ~= nil then
                    -- Save the new theme element color both to the Settings.ini and to the current graphic contants used to draw the Tracker
                    print(key .. ": " .. newThemeColor)
                    Settings.theme[key] = newThemeColor
                    --Theme.setThemeElement(key, newThemeColor)
                    -- Convert color hex value so it matches all other values used in GraphicConstants
                    GraphicConstants.LAYOUTCOLORS[key] = tonumber(color_text, 16) + 0xFF000000
                end
                -- Theme.updated = true -- Temporarily disabled so my settings file doesnt get wiped

                return newThemeColor
            end
        }
        table.insert(Theme.themeButtons, button)
        themeHeightStart = themeHeightStart + 10
	end
end

-- TODO: This doesnt appear to work either.
function Theme.requestNewColor(element_label, color_text)
    local themeColor = nil

    local colorForm = forms.newform(290, 70, "Enter a new color for " .. element_label .. ":", function() return nil end)
    local textBox = forms.textbox(colorForm, color_text, 200, 20, 5, 5)
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
    end, 200, 5)

    return themeColor
end

-- TODO: UNUSED, but leaving for now until I test everything else
-- Sets the GraphicConstants theme layout color to the new color
function Theme.setThemeElement(element, color_text)
    -- Convert color hex value to match all other values used in graphic constants
    local layoutcolor = tonumber(color_text, 16) + 0xFF000000

    if element == "BACKGROUND_COLOR" then
        GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR = layoutcolor
    elseif element == "BOX_TOP_FILL" then
        GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL = layoutcolor
    elseif element == "BOX_TOP_BORDER" then
        GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER = layoutcolor
    elseif element == "BOX_BOTTOM_FILL" then
        GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL = layoutcolor
    elseif element == "BOX_BOTTOM_BORDER" then
        GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER = layoutcolor
    elseif element == "TEXT_DEFAULT" then
        GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT = layoutcolor
    elseif element == "TEXT_HEADER" then
        GraphicConstants.LAYOUTCOLORS.TEXT_HEADER = layoutcolor
    elseif element == "TEXT_POSITIVE" then
        GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE = layoutcolor
    elseif element == "TEXT_MIDDLE_VALUE" then
        GraphicConstants.LAYOUTCOLORS.TEXT_MIDDLE_VALUE = layoutcolor
    elseif element == "TEXT_NEGATIVE" then
        GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE = layoutcolor
    end
end

function Theme.importThemeFromText(theme_config)
    -- TODO: Rewrite using this example: 0x5d3a9b 0x1a85ff 0x994f00 0xffcbf3 0 0xffc20a 0xd35fb7 0xd41159 0xfefe62 0x1a85ff 0xa0d3ff 
    if theme_config == nil then
        return
    elseif string.len(theme_config) ~= 89 then -- ten total color hex codes is 90 characters, ignore trailing space
        return
    end

    -- Verify the theme config is correct and can be parsed
    local theme_colors = {}
    for color_text in string.gmatch(theme_config, "[^%s]+") do
        if string.len(color_text) ~= 8 then
            return
        end
        local color = tonumber(color_text)
        if color < 0x000000 or color > 0xFFFFFF then
            return
        end

        theme_colors[#theme_colors + 1] = color_text
    end

    -- Import each of the colors to the GraphicConstants, the Settings to be saved later, and update the Tracker's buttons
    -- TODO: This currently assumes the order of imported colors will match the order I've written here
    GraphicConstants.LAYOUTCOLORS = {
		BACKGROUND_COLOR = tonumber(theme_colors[1]),
		BOX_TOP_FILL = tonumber(theme_colors[2]),
		BOX_TOP_BORDER = tonumber(theme_colors[3]),
		BOX_BOTTOM_FILL = tonumber(theme_colors[4]),
		BOX_BOTTOM_BORDER = tonumber(theme_colors[5]),
		TEXT_DEFAULT = tonumber(theme_colors[6]),
		TEXT_HEADER = tonumber(theme_colors[7]),
		TEXT_POSITIVE = tonumber(theme_colors[8]),
		TEXT_MIDDLE_VALUE = tonumber(theme_colors[9]),
		TEXT_NEGATIVE = tonumber(theme_colors[10]),
		INPUT_HIGHLIGHT = 0xFFFFC20A, -- Currently not high priority to be customizeable
	}

    -- local index = 1
    for key, _ in pairs(Settings.theme) do
        print("Saving " .. key .. " with value: " .. GraphicConstants.LAYOUTCOLORS[key])
        Settings[key] = GraphicConstants.LAYOUTCOLORS[key]
        -- Settings[key] = theme_colors[index]
        -- index = index + 1
    end

    -- Theme.buildTrackerThemeButtons()
    -- Options.buildTrackerOptionsButtons()
    -- Buttons.refreshTheme() -- Likely want one of these for everything... but unsure if needed cause cant reach this point in the code yet

    Theme.redraw = true
    -- Theme.updated = true -- Temporarily disabled so my settings file doesnt get wiped
end

-- TODO: Currently order appears random, or based on something else, make sure its in the order your want.
function Theme.exportThemeToText()
    local exportedTheme = ""

    for _, value in pairs(GraphicConstants.LAYOUTCOLORS) do
        if value == nil or value == 0 then
            value = 0xFF000000
        end
        local color_text = string.format("%#x", value - 0xFF000000)
        exportedTheme = exportedTheme .. color_text .. " "
    end

    return exportedTheme
end

-- TODO: Add a restore to defaults button
function Theme.restoreDefaultTheme()
    
end
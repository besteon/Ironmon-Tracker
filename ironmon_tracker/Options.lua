Options = {}

-- Update drawing the settings page if true
Options.redraw = true

-- Tracks if settings were modified so we know if we need to update Settings.ini or not.
Options.updated = false

-- A button to close the settings page and save the settings if any changes occurred
Options.closeButton = {
	text = "Close",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 40,
		GraphicConstants.SCREEN_HEIGHT - 20,
		30,
		11,
	},
	boxColors = { "Upper box border", "Upper box background" },
	-- onClick = function(): currently handled in the Input object
}

-- Not a visible button, but is used by the Input script to see if clicks occurred on the setting
Options.romsFolderOption = {
	text = "Roms folder: ",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + 6, -- 6 = borderMargin + 1
		8, -- 8 = borderMargin + 3
		8,
		8,
	},
}

-- A button to navigate to the Theme menu for customizing the Tracker's look and feel
Options.themeButton = {
	text = "Customize",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + 10,
		GraphicConstants.SCREEN_HEIGHT - 20,
		50,
		11,
	},
	boxColors = { "Upper box border", "Upper box background" },
	-- onClick = function(): currently handled in the Input object
}

-- Stores the options in the Settings.ini file into configurable toggles in the Tracker
Options.optionsButtons = {}

--[[]]
function Options.buildTrackerOptionsButtons()
	local borderMargin = 5
	local index = 1
    local heightOffset = 10 + index * 10

	for key, value in pairs(Settings.tracker) do
		-- All options in Settings.tracker SHOULD be boolean, but we'll verify here for now.
		-- Eventually I want to expand this so that we can do more than just toggles, but let's get this out the door first.
		if value == true or value == false then
			local button = {
				text = string.sub(key, 1, 1) .. string.sub(string.lower(string.gsub(key, "_", " ")), 2),
				textColor = "Default text",
				box = {	GraphicConstants.SCREEN_WIDTH + borderMargin + 3, heightOffset, 8, 8 },
				boxColors = { "Upper box border", "Upper box background" },
				optionColor = "Positive text",
				optionState = value,
				-- TODO: Need a better way to internally update the optionState member rather than depending on the caller to save it...
				onClick = function()
					-- Toggle the setting
					Settings.tracker[key] = Utils.inlineIf(Settings.tracker[key], false, true)
					Options.redraw = true
					Options.updated = true

					-- return the updated value to be saved into this button's optionState value
					return Settings.tracker[key]
				end
			}
			table.insert(Options.optionsButtons, button)
			index = index + 1
			heightOffset = 10 + index * 10
		end
	end
end

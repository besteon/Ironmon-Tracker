Options = {}

-- Update drawing the settings page if true
Options.redraw = true

-- Tracks if settings were modified so we know if we need to update Settings.ini or not.
Options.updated = false

-- A button to close the settings page and save the settings if any changes occurred
Options.closeButton = {
	text = "Close",
	box = {
		GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 40,
		GraphicConstants.SCREEN_HEIGHT - 20,
		30,
		11,
	},
	backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
	textColor = GraphicConstants.LAYOUTCOLORS.NEUTRAL,
	-- onClick = function(): currently handled in the Input object
}

-- Not a visible button, but is used by the Input script to see if clicks occurred on the setting
Options.romsFolderOption = {
	text = "Roms folder: ",
	box = {
		GraphicConstants.SCREEN_WIDTH + 6, -- 6 = borderMargin + 1
		8, -- 8 = borderMargin + 3
		8,
		8,
	},
	textColor = GraphicConstants.LAYOUTCOLORS.NEUTRAL,
}

-- Stores the options in the Settings.ini file into configurable toggles in the Tracker
Options.optionsButtons = {}

--[[]]
function Options.buildTrackerOptionsButtons()
	local borderMargin = 5
	-- Used for the position offests.
	local optionIndex = 1
	for key, value in pairs(Settings.tracker) do
		-- All options in Settings.tracker SHOULD be boolean, but we'll verify here for now.
		-- Eventually I want to expand this so that we can do more than just toggles, but let's get this out the door first.
		if value == true or value == false then
			optionIndex = optionIndex + 1
			local button = {
				text = string.sub(key, 1, 1) .. string.sub(string.lower(string.gsub(key, "_", " ")), 2),
				box = {
					GraphicConstants.SCREEN_WIDTH + borderMargin + 3,
					(optionIndex * 10),
					8,
					8,
				},
				backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
				textColor = GraphicConstants.LAYOUTCOLORS.NEUTRAL,
				optionColor = GraphicConstants.LAYOUTCOLORS.INCREASE,
				optionState = value,
				-- TODO: Need a better way to internally update the optionState member rather than depending on the caller to save it...
				onClick = function() -- return the updated value to be saved into this button's optionState value
					-- I learned a lot about Lua today... You can't just use `not` to toggle a boolean state. You HAVE to do this if-else block... WTF...
					if Settings.tracker[key] == true then
						Settings.tracker[key] = false
					else
						Settings.tracker[key] = true
					end
					if not Options.updated then
						Options.updated = true
					end
					return Settings.tracker[key]
				end
			}
			table.insert(Options.optionsButtons, button)
		end
	end
end

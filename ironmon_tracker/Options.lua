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
function Options.buildOptionsButtons()
	local borderMargin = 5
	-- Used for the position offests. This assumes that there is only one option in the `config` category!
	local optionIndex = 1
	for _, category in pairs(Settings) do
		for key, value in pairs(category) do
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
					onClick = function()
						value = not value
						print(" value is now " .. Utils.inlineIf(value, "true", "false"))
						if not Options.updated then
							Options.updated = true
						end
					end
				}
				table.insert(Options.optionsButtons, button)
			end
		end
	end
end

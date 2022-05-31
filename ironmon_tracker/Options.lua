Options = {}

Options.cancelButton = {
	text = "Cancel",
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
					end
				}
				table.insert(Options.optionsButtons, button)
			end
		end
	end
end

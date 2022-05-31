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
	print("Building options from Settings.ini...")
	-- Used for the position offests. This assumes that there is only one option in the `config` category!
	local optionIndex = 1
	for _, category in pairs(Settings) do
		print(category)
		for key, value in pairs(category) do
			print("key: " .. key .. "; value: " .. value)
			optionIndex = optionIndex + 1
			local button = {
				text = key,
				box = {
					GraphicConstants.SCREEN_WIDTH + borderMargin + 3,
					borderMargin + (optionIndex * 10),
					8,
					8,
				},
				backgroundColor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
				textColor = GraphicConstants.LAYOUTCOLORS.NEUTRAL,
				optionColor = GraphicConstants.LAYOUTCOLORS.INCREASE,
				optionState = value,
				onClick = function()
					if value == true then
						value = false
					elseif value == false then
						value = true
					end
				end
			}
			-- table.insert(Settings.optionsButtons, button)
		end
	end
end

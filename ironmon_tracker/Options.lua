Options = {
	-- Tracks if any option elements were modified so we know if we need to save them to the Settings.ini file
	settingsUpdated = false,

	FIRST_RUN = true,
	ROMS_FOLDER = "",

	-- 'Default' set of Options, but will get replaced by what's in Settings.ini
	["Show tips on startup"] = true,
	["Auto swap to enemy"] = true,
	["Hide stats until summary shown"] = false,
	["Right justified numbers"] = false,
	["Show physical special icons"] = true,
	["Show move effectiveness"] = true,
	["Calculate variable damage"] = true,
	["Count enemy PP usage"] = true,
	["Track PC Heals"] = false,
	["PC heals count downward"] = true,
	["Auto save tracked game data"] = true,
	["Pokemon icon set"] = "1", -- Original icon set
	["Show last damage calcs"] = true,
	["Reveal info if randomized"] = true,
	["Animated Pokemon popout"] = false,

	CONTROLS = {
		["Load next seed"] = "A, B, Start, Select",
		["Toggle view"] = "Start",
		["Cycle through stats"] = "L",
		["Mark stat"] = "R",
	},
}

Options.IconSetMap = {
	totalCount = 3,
	["1"] = {
		name = "Original",
		folder = "pokemon",
		extension = ".gif",
	},
	["2"] = {
		name = "Stadium",
		folder = "pokemonStadium",
		extension = ".png",
	},
	["3"] = {
		name = "Gen 7+",
		folder = "pokemonUpdated",
		extension = ".png",
	},
}

function Options.initialize()
	-- Check if the Toggle View controller button is not default, and update the tip message if so.
	local toggleViewValue = Options.CONTROLS["Toggle view"]
	if toggleViewValue ~= "Start" then
		Constants.OrderedLists.TIPS[3] = Constants.OrderedLists.TIPS[3]:gsub("Start", toggleViewValue)
	end

	Drawing.AnimatedPokemon:create()
end

function Options.updateSetting(optionKey, value)
	Options[optionKey] = value
	Options.settingsUpdated = true
	Program.redraw(true)
end
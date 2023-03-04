Options = {
	-- Tracks if any option elements were modified so we know if we need to save them to the Settings.ini file
	settingsUpdated = false,

	FIRST_RUN = true,

	FILES = {
		["ROMs Folder"] = "",
		["Randomizer JAR"] = "",
		["Source ROM"] = "",
		["Settings File"] = "",
	},

	-- 'Default' set of Options, but will get replaced by what's in Settings.ini
	["Disable mainscreen carousel"] = false,
	["Auto swap to enemy"] = true,
	["Show random ball picker"] = true,
	["Hide stats until summary shown"] = false,
	["Right justified numbers"] = false,
	["Show physical special icons"] = true,
	["Show move effectiveness"] = true,
	["Calculate variable damage"] = true,
	["Determine friendship readiness"] = true,
	["Count enemy PP usage"] = true,
	["Track PC Heals"] = false,
	["PC heals count downward"] = true,
	["Auto save tracked game data"] = true,
	["Pokemon icon set"] = "1", -- Original icon set
	["Show last damage calcs"] = true,
	["Reveal info if randomized"] = true,
	["Show experience points bar"] = false,
	["Animated Pokemon popout"] = false,
	["Use premade ROMs"] = false,
	["Generate ROM each time"] = false,
	["Display repel usage"] = false,
	["Display pedometer"] = false,
	["Dev branch updates"] = false,
	["Welcome message"] = "", -- Default is empty, which will display the GBA Controls
	["Startup favorites"] = "1,4,7",
	["Show on new game screen"] = false,
	["Enable restore points"] = true,
	["Enable custom extensions"] = false,
	["Show Team View"] = false,

	CONTROLS = {
		["Load next seed"] = "A, B, Start",
		["Toggle view"] = "Start",
		["Cycle through stats"] = "L",
		["Mark stat"] = "R",
	},
}

Options.IconSetMap = {
	totalCount = 5,
	["1"] = {
		name = "Original", -- The name of the icon set which is displayed on the Tracker Setup screen
		folder = "pokemon", -- The folder within the tracker files where each icon is stored, expected to be in /ironmon-tracker/images/
		extension = ".gif", -- The file extension for each icon, expected that all icons use the same file extension
		yOffset = 0, -- A number of pixels to shift the drawing of the icon downward
		adjustQuestionMark = true, -- If true, will shift the question mark icon on the RouteInfo screen downward `yOffset` pixels
		author = "Besteon", -- The name of the creator of the icon set which is displayed on the Tracker Setup screen
	},
	["2"] = {
		name = "Stadium",
		folder = "pokemonStadium",
		extension = ".png",
		yOffset = 4,
		adjustQuestionMark = false,
		author = "AmberCyprian",
	},
	["3"] = {
		name = "Gen 7+",
		folder = "pokemonUpdated",
		extension = ".png",
		yOffset = 2,
		adjustQuestionMark = true,
		author = "kittenchilly",
	},
	["4"] = {
		name = "Explorers",
		folder = "pokemonMysteryDungeon",
		extension = ".png",
		yOffset = 4,
		adjustQuestionMark = false,
		author = "Fellshadow",
	},
	["5"] = {
		name = "Virtual Pet",
		folder = "pokemonVPet",
		extension = ".png",
		yOffset = 2,
		adjustQuestionMark = false,
		author = "Ryastoise",
	},
}

-- This determines what icon to show on each Startup Screen
-- random: changes randomly each seed
-- attempts: shows a Pokemon based on the attempt count, eg. "attempt 25" would show Pikachu
-- [ID_NUM]: shows the same Pokemon every time, eg. "set as 213" would always show Shuckle
Options.StartupIcon = {
	random = "Random",
	attempts = "Attempts",
	none = "None",
}

Options["Startup Pokemon displayed"] = Options.StartupIcon.attempts

function Options.initialize()
	Drawing.AnimatedPokemon:create()
end

function Options.updateSetting(optionKey, value)
	Options[optionKey] = value
	Options.settingsUpdated = true
	Program.redraw(true)
end

function Options.forceSave()
	Options.settingsUpdated = true
	Main.SaveSettings()
	Program.redraw(true)
end
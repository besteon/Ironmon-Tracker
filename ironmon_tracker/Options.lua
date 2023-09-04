Options = {
	FIRST_RUN = true,
	FILES = {
		["ROMs Folder"] = "",
		["Randomizer JAR"] = "",
		["Source ROM"] = "",
		["Settings File"] = "",
	},
	-- 'Default' set of Options, but will get replaced by what's in Settings.ini
	["Language"] = Resources.Default.Language.Key,
	["Autodetect language from game"] = true,
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
	["Pokemon icon set"] = "1",
	["Show last damage calcs"] = true,
	["Reveal info if randomized"] = true,
	["Show experience points bar"] = false,
	["Animated Pokemon popout"] = false,
	["Refocus emulator after load"] = true,
	["Use premade ROMs"] = false,
	["Generate ROM each time"] = false,
	["Display repel usage"] = false,
	["Display pedometer"] = false,
	["Display play time"] = false,
	["Game timer location"] = "LowerRight",
	["Dev branch updates"] = false,
	["Welcome message"] = "", -- Default is empty, which will display the GBA Controls
	["Startup favorites"] = "1,4,7",
	["Show on new game screen"] = false,
	["Enable restore points"] = true,
	["Enable crash recovery"] = true,
	["Enable custom extensions"] = false,
	["Show Team View"] = false,
	["Show Pre Evolutions"] = false,
	["Use Custom Trainer Names"] = false,
	["Open Book Play Mode"] = false,
	["Allow sprites to walk"] = true,
	CONTROLS = {
		["Load next seed"] = "A, B, Start",
		["Toggle view"] = "Start",
		["Cycle through stats"] = "L",
		["Mark stat"] = "R",
	},
}

-- The order of these iconsets cannot change, as user Settings reference them by their index number
Options.IconSetMap = {
	{
		name = "Original", -- The name of the icon set which is displayed on the Tracker Setup screen
		author = "Besteon", -- The name of the creator of the icon set which is displayed on the Tracker Setup screen
		folder = "pokemon", -- The folder within the tracker files where each icon is stored, expected to be in /ironmon-tracker/images/
		extension = ".gif", -- The file extension for each icon, expected that all icons use the same file extension
		yOffset = 0, -- A number of pixels to shift the drawing of the icon downward
		adjustQuestionMark = true, -- If true, will shift the question mark icon on the RouteInfo screen downward `yOffset` pixels
	},
	{
		name = "Stadium",
		author = "AmberCyprian",
		folder = "pokemonStadium",
		extension = ".png",
		yOffset = 4,
	},
	{
		name = "Gen 7+",
		author = "kittenchilly",
		folder = "pokemonUpdated",
		extension = ".png",
		yOffset = 2,
		adjustQuestionMark = true,
		-- source = "https://msikma.github.io/pokesprite/index.html",
	},
	{
		name = "Explorers",
		author = "Fellshadow",
		folder = "pokemonMysteryDungeon",
		extension = ".png",
		yOffset = 4,
		-- source = "https://sprites.pmdcollab.org/",
	},
	{
		name = "Virtual Pet",
		author = "Ryastoise",
		folder = "pokemonVPet",
		extension = ".png",
		yOffset = 2,
	},
	{
		name = "Walking Pals",
		author = "UTDZac",
		folder = "spritesWalkingPals",
		extension = ".png",
		isAnimated = true,
		iconKey = "WalkingPals",
		-- source = "https://sprites.pmdcollab.org/",
	},
}
-- Setup references for extensions that still use the deprecated key
for i, _ in ipairs(Options.IconSetMap) do
	Options.IconSetMap[tostring(i)] = Options.IconSetMap[i]
end

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

local defaultOptions = {}
FileManager.copyTable(Options, defaultOptions)
defaultOptions.IconSetMap = nil
defaultOptions.StartupIcon = nil
Options.Defaults = defaultOptions

function Options.initialize()
	Drawing.AnimatedPokemon:create()
end

-- Toggles the boolean setting (optionKey) and returns the resulting value
function Options.toggleSetting(optionKey)
	if optionKey == nil then return end
	if type(Options[optionKey]) == "boolean" then
		Options.addUpdateSetting(optionKey, not Options[optionKey])
	end
	return Options[optionKey]
end

-- Updates the setting (optionKey) or if it doesn't exist, adds it. Then saves the change to the Settings.ini file
function Options.addUpdateSetting(optionKey, value)
	if optionKey == nil then return end
	Options[optionKey] = value
	Main.SaveSettings(true)
end

function Options.getIconSet()
	local iconSetIndex = tonumber(Options["Pokemon icon set"]) or 1
	return Options.IconSetMap[iconSetIndex] or Options.IconSetMap[1]
end

Options = {
	-- 'Default' set of Options, but will get replaced by what's in Settings.ini
	["Language"] = Resources and Resources.Default.Language.Key or "ENGLISH",
	["Autodetect language from game"] = true,
	["Allow carousel rotation"] = true,
	["CarouselItems"] = "Badges,Notes,RouteInfo,Trainers,LastAttack,BattleDetails,Pedometer,GachaMon",
	["CarouselSpeed"] = "1",
	["Auto swap to enemy"] = true,
	["Show random ball picker"] = true,
	["Show heals as whole number"] = false,
	["Show Poke Ball catch rate"] = true,
	["Show starter ball info"] = false,
	["Hide stats until summary shown"] = false,
	["Right justified numbers"] = false,
	["Show physical special icons"] = true,
	["Show move effectiveness"] = true,
	["Calculate variable damage"] = true,
	["Determine friendship readiness"] = true,
	["Count enemy PP usage"] = true,
	["Show nicknames"] = false,
	["Track PC Heals"] = false,
	["PC heals count downward"] = true,
	["Auto save tracked game data"] = true,
	["Pokemon icon set"] = "1",
	["Override Button Mode to LR"] = true,
	["Show last damage calcs"] = true,
	["Reveal info if randomized"] = true,
	["Game Over condition"] = "LeadPokemonFaints",
	["Show experience points bar"] = false,
	["Animated Pokemon popout"] = false,
	["Refocus emulator after load"] = true,
	["Use premade ROMs"] = false,
	["Generate ROM each time"] = false,
	["Display repel usage"] = false,
	["Display pedometer"] = false,
	["Display play time"] = false,
	["Display gender"] = false,
	["Game timer location"] = "LowerRight",
	["Color stat numbers by nature"] = false,
	["Dev branch updates"] = false,
	["Welcome message"] = "", -- Default is empty, which will display the GBA Controls
	["Startup favorites"] = "1,4,7",
	["Show on new game screen"] = false,
	["Enable restore points"] = true,
	["Enable crash recovery"] = true,
	["Enable custom extensions"] = true,
	["Show Team View"] = false,
	["Show unlearnable Gym TMs"] = true,
	["Show Pre Evolutions"] = false,
	["Use Custom Trainer Names"] = false,
	["Open Book Play Mode"] = false,
	["Allow sprites to walk"] = true,
	["Active Profile"] = "",

	["GachaMon Ratings Ruleset"] = "AutoDetect",
	["Add GachaMon to collection if its new"] = false,
	["Add GachaMon to collection after defeating a trainer"] = true,
	["Show GachaMon stars on main Tracker Screen"] = true,
	["Show card pack on screen after capturing a GachaMon"] = false,
	["Animate GachaMon pack opening"] = true,

	-- Internal Tracker settings
	["Has checked carousel battle details"] = false,
	["Has checked carousel GachaMon"] = false,

	-- In rare situations, new options get added that the user should be informed about (true: requires alerting, set to false after)
	["AlertNewOptionLR"] = true, -- This is for the "Override Button Mode to LR" setting; allowing Tracker to change data in game

	-- (Currently unused) Determines whether this is the first time the Tracker is opened/used
	FIRST_RUN = true,
}

-- Controller inputs
Options.CONTROLS = {
	["Load next seed"] = "A, B, Start",
	["Toggle view"] = "Start",
	["Info shortcut"] = "R",
	["Cycle through stats"] = "L",
	["Mark stat"] = "R",
	["Next page"] = "R",
	["Previous page"] = "L",
}

-- User-specified file/folder locations
Options.FILES = {
	["ROMs Folder"] = "",
	["Randomizer JAR"] = "",
	["Source ROM"] = "",
	["Settings File"] = "",
}

-- Execution paths
Options.PATHS = {
	["Java Path"] = "java",
}

-- Folder path overrides (must exclude actual filename) for files generated by the Tracker at runtime
-- If empty, will default to their normal location, e.g. @ /.. (the working directory)
Options.Overrides = {
	["Animated Pokemon"] = "", -- GIF file used for MGBA; @ /..
	["Attempt Counts"] = "", -- Seed counts per game mode; @ /..
	["Backup Saves"] = "", -- Gameover game saves; @ /saved_games/..
	["Network Requests"] = "", -- Saved requests between sessions; @ /ironmon_tracker/network/..
	["Randomizer Error Log"] = "", -- Log output from java Randomizer; @ /..
	["ROMs and Logs"] = "", -- Generated from New Runs (Quickload); @ /..
	["Theme Presets"] = "", -- All preloaded & user theme codes; @ /..
	["Tracker Data"] = "", -- Auto saved .TDAT files; @ /..
	["GachaMon Collection"] = "", -- The GachaMon card collection files; @ /gachamon/..
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

-- Multiplier as applied to "total # frames to show", so half-speed = twice as many frames to show
Options.CarouselSpeedMap = {
	["1/2"] = {
		optionKey = "1/2",
		multiplier = 2,
		index = 2,
	},
	["1"] = {
		optionKey = "1",
		multiplier = 1,
		index = 3,
	},
	["2"] = {
		optionKey = "2",
		multiplier = 1/2,
		index = 4,
	},
	["3"] = {
		optionKey = "3",
		multiplier = 1/3,
		index = 5,
	},
	["4"] = {
		optionKey = "4",
		multiplier = 1/4,
		index = 6,
	},
}

local defaultOptions = {}
FileManager.copyTable(Options, defaultOptions)
defaultOptions.IconSetMap = nil
defaultOptions.StartupIcon = nil
defaultOptions.CarouselSpeedMap = nil
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

local function alertPopupForLR()
	local headerMsg = "Important Notice!"
	local notificationMsg1 = "To allow for new controller bindings, 'L' and 'R', the Tracker will automatically change an in-game option."
	local notificationMsg2 = 'The change: START > OPTIONS > Button Mode from "HELP" to "LR"'
	local notificationMsg3 = string.format(
		"If this disrupts your normal gameplay, you can revert this automatic override in Setup > Controls > [X] %s.",
		Resources.SetupScreen.OptionOverrideButtonModeLR
	)

	-- Print instructions if on MGBA
	if not Main.IsOnBizhawk() then
		print(string.rep("- ", 20))
		print(headerMsg)
		print(notificationMsg1)
		print(" - " .. notificationMsg2)
		print(notificationMsg3)
		return
	end
	local form = ExternalUI.BizForms.createForm(headerMsg, 400, 210)

	form:createLabel(notificationMsg1, 20, 20, 360, 40)
	form:createLabel(notificationMsg2, 20, 65, 360, 20)
	form:createLabel(notificationMsg3, 20, 95, 360, 40)

	form:createButton(Resources.AllScreens.OK, 85, 135, function()
		form:destroy()
	end)
	form:createButton("View Controller Settings", 180, 135, function()
		SetupScreen.currentTab = SetupScreen.Tabs.Controls
		if Program.currentScreen ~= SetupScreen then
			SetupScreen.previousScreen = Program.currentScreen
		end
		Program.changeScreenView(SetupScreen)
		form:destroy()
	end)
end

function Options.alertImportantChanges()
	if Options["AlertNewOptionLR"] then
		Options["AlertNewOptionLR"] = false
		Main.SaveSettings(true)
		alertPopupForLR()
	end
end
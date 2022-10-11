Main = {}

-- The latest version of the tracker. Should be updated with each PR.
Main.Version = { major = "6", minor = "4", patch = "1" }

Main.CreditsList = { -- based on the PokemonBizhawkLua project by MKDasher
	CreatedBy = "Besteon",
	Contributors = { "UTDZac", "Fellshadow", "bdjeffyp", "OnlySpaghettiCode", "thisisatest", "Amber Cyprian", "ninjafriend", "kittenchilly", "AKD", "davidhouweling", "rcj001", "GB127", },
}

-- Returns false if an error occurs that completely prevents the Tracker from functioning; otherwise, returns true
function Main.Initialize()
	Main.TrackerVersion = string.format("%s.%s.%s", Main.Version.major, Main.Version.minor, Main.Version.patch)
	Main.Version.remindMe = true
	Main.Version.latestAvailable = Main.TrackerVersion
	Main.Version.dateChecked = ""

	Main.OS = "Windows" -- required if user doesn't restart during a First Run
	Main.DataFolder = "ironmon_tracker" -- Root folder for the project data and sub scripts
	Main.MetaSettings = {}
	Main.currentSeed = 1
	Main.loadNextSeed = false
	Main.TrackerFiles = { -- All of the files required by the tracker
		"/Inifile.lua",
		"/Constants.lua",
		"/data/PokemonData.lua",
		"/data/MoveData.lua",
		"/data/AbilityData.lua",
		"/data/MiscData.lua",
		"/data/RouteData.lua",
		"/Memory.lua",
		"/GameSettings.lua",
		"/screens/InfoScreen.lua",
		"/Options.lua",
		"/Theme.lua",
		"/ColorPicker.lua",
		"/Utils.lua",
		"/screens/TrackerScreen.lua",
		"/screens/NavigationMenu.lua",
		"/screens/StartupScreen.lua",
		"/screens/SetupScreen.lua",
		"/screens/QuickloadScreen.lua",
		"/screens/GameOptionsScreen.lua",
		"/screens/TrackedDataScreen.lua",
		"/Input.lua",
		"/Drawing.lua",
		"/Program.lua",
		"/Battle.lua",
		"/Pickle.lua",
		"/Tracker.lua",
	}

	console.clear() -- Clearing the console for each new game helps with troubleshooting issues
	print("\nIronmon-Tracker (Gen 3): v" .. Main.TrackerVersion)

	-- Check the version of BizHawk that is running
	if not Main.SupportedBizhawkVersion() then
		print("This version of BizHawk is not supported for use with the Tracker.\nPlease update to version 2.8 or higher.")
		Main.DisplayError("This version of BizHawk is not supported for use with the Tracker.\n\nPlease update to version 2.8 or higher.")
		return false
	end

	-- Set seed based on epoch seconds; required for other features
	math.randomseed(os.time() % 100000 * 17) -- seed was acting wonky (read as: predictable), so made it wonkier
	math.random() -- required first call, for some reason

	-- Attempt to load the required tracker files
	for _, file in ipairs(Main.TrackerFiles) do
		local path = Main.DataFolder .. file
		if Main.FileExists(path) then
			dofile(path)
		else
			print("Unable to load " .. path .. "\nMake sure all of the downloaded Tracker's files are still together.")
			Main.DisplayError("Unable to load " .. path .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
			return false
		end
	end

	Main.LoadSettings()
	Main.ReadAttemptsCounter()

	if Options.FIRST_RUN then
		Options.FIRST_RUN = false
		Main.SaveSettings(true)

		local firstRunErrMsg = "It looks like this is your first time using the Tracker. If so, please close and re-open Bizhawk before continuing."
		firstRunErrMsg = firstRunErrMsg .. "\n\nOtherwise, be sure to overwrite your old Tracker files for new releases."
		print(firstRunErrMsg)
		Main.DisplayError(firstRunErrMsg)
		--return false -- Let the program keep running
	else
		-- Working directory, used for absolute paths
		local function exeCD() return io.popen("cd") end
		local success, ret, err = xpcall(exeCD, debug.traceback)
		if success then
			Main.OS = "Windows"
			Main.Directory = ret:read()
		else
			Main.OS = "Linux"
			Main.Directory = nil -- will return "" from Utils function
			print(err)
		end

		Main.CheckForVersionUpdate()
	end

	print("Successfully loaded required tracker files")
	return true
end

-- Checks if Bizhawk version is 2.8 or later
function Main.SupportedBizhawkVersion()
	-- Significantly older Bizhawk versions don't have a client.getversion function
	if client.getversion == nil then return false end

	-- Check the major and minor version numbers separately, to account for versions such as "2.10"
	local major, minor = string.match(client.getversion(), "(%d+)%.(%d+)")
	if major ~= nil then
		local majorNumber = tonumber(major)
		if majorNumber > 2 then
			-- Will allow anything v3.0 and upwards
			return true
		elseif majorNumber == 2 then
			-- Is v2.x, check minor version number
			if minor ~= nil then
				return tonumber(minor) >= 8
			end
		end
	end

	return false
end

-- Checks if a file exists
function Main.FileExists(path)
	local file = io.open(path,"r")
	if file ~= nil then
		io.close(file)
		return true
	else
		return false
	end
end

-- Displays a given error message in a pop-up dialogue box
function Main.DisplayError(errMessage)
	client.pause()

	local form = forms.newform(400, 150, "[v" .. Main.TrackerVersion .. "] Woops, there's been an issue!", function() client.unpause() end)

	local actualLocation = client.transformPoint(100, 50)
	forms.setproperty(form, "Left", client.xpos() + actualLocation['x'] )
	forms.setproperty(form, "Top", client.ypos() + actualLocation['y'] + 64) -- so we are below the ribbon menu

	forms.label(form, errMessage, 18, 10, 350, 65)
	forms.button(form, "Close", function()
		client.unpause()
		forms.destroy(form)
	end, 155, 80)
end

-- Main loop
function Main.Run()
	if gameinfo.getromname() == "Null" then
		print("Waiting for a game ROM to be loaded... (File -> Open ROM)")
	end
	local romLoaded = false
	while not romLoaded do
		if gameinfo.getromname() ~= "Null" then romLoaded = true end
		emu.frameadvance()
	end

	GameSettings.initialize()

	-- If the loaded game is unsupported, remove the Tracker padding but continue to let the game play.
	if GameSettings.game == 0 then
		client.SetGameExtraPadding(0, 0, 0, 0)
		while true do
			emu.frameadvance()
		end
	else
		-- Initialize everything in the proper order
		Program.initialize()
		Options.initialize()
		Theme.initialize()
		Tracker.initialize()

		TrackerScreen.initialize()
		NavigationMenu.initialize()
		StartupScreen.initialize()
		SetupScreen.initialize()
		QuickloadScreen.initialize()
		GameOptionsScreen.initialize()
		TrackedDataScreen.initialize()

		client.SetGameExtraPadding(0, Constants.SCREEN.UP_GAP, Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.DOWN_GAP)
		gui.defaultTextBackground(0)

		event.onexit(Program.HandleExit, "HandleExit")

		while Main.loadNextSeed == false do
			Program.mainLoop()
			emu.frameadvance()
		end

		Main.LoadNextRom()
	end
end

-- Determines if there is an update to the current Tracker version
-- Intentionally will only check against Major and Minor version updates,
-- allowing patches to seamlessly update without bothering every end-user
function Main.CheckForVersionUpdate()
	if Main.OS ~= "Windows" then
		return
	end

	-- %x - Date representation for current locale (Standard date string), eg. "25/04/07"
	local todaysDate = os.date("%x")

	-- Only notify about updates once per day
	if todaysDate ~= Main.Version.dateChecked then
		local pipe = io.popen("curl " .. Constants.Release.VERSION_URL) or ""
		if pipe ~= "" then
			local response = pipe:read("*all") or ""

			-- Get version number formatted as [major].[minor].[patch]
			local _, _, major, minor, patch = string.match(response, '"tag_name":(%s+)"(%w+)(%d+)%.(%d+)%.(%d+)"')
			major = major or Main.Version.major
			minor = minor or Main.Version.minor
			patch = patch or Main.Version.patch

			local latestVersion = major .. "." .. minor .. "." .. patch
			local newVersionAvailable = Main.Version.major ~= major or Main.Version.minor ~= minor
			local shouldNotify = Main.Version.remindMe or Main.Version.latestAvailable ~= latestVersion

			-- Determine if a major version update is available and notify the user accordingly
			if newVersionAvailable and shouldNotify then
				Main.Version.remindMe = false
				Main.NotifyUpdatePopUp(latestVersion)
			end

			-- Track that an update was checked today, so no additional api calls are performed today
			Main.Version.dateChecked = todaysDate
			-- Track the latest available version, for determining whether to show silent updates below
			Main.Version.latestAvailable = latestVersion
		end
	end

	-- Always show the version update silently through the Lua Console
	if Main.TrackerVersion ~= Main.Version.latestAvailable then
		print("[Version Update] New Tracker version available for download: v" .. Main.Version.latestAvailable)
		print(Constants.Release.DOWNLOAD_URL)
	end

	Main.SaveSettings(true)
end

function Main.NotifyUpdatePopUp(latestVersion)
	local form = forms.newform(355, 180, "New Version Available", function() client.unpause() end)
	local actualLocation = client.transformPoint(100, 50)
	forms.setproperty(form, "Left", client.xpos() + actualLocation['x'] )
	forms.setproperty(form, "Top", client.ypos() + actualLocation['y'] + 64) -- so we are below the ribbon menu

	forms.label(form, "New Tracker Version Available!", 89, 15, 255, 20)
	forms.label(form, "New version: v" .. latestVersion, 89, 42, 255, 20)
	forms.label(form, "Current version: v" .. Main.TrackerVersion, 89, 60, 255, 20)

	local offsetY = 85

	forms.button(form, "Visit Download Page", function()
		if Main.OS == "Windows" then
			os.execute("start " .. Constants.Release.DOWNLOAD_URL)
		end
		client.unpause()
		forms.destroy(form)
	end, 15, offsetY + 5, 120, 30)

	forms.button(form, "Remind Me Later", function()
		Main.Version.remindMe = true
		Main.SaveSettings(true)
		client.unpause()
		forms.destroy(form)
	end, 140, offsetY + 5, 110, 30)

	forms.button(form, "Dismiss", function()
		client.unpause()
		forms.destroy(form)
	end, 255, offsetY + 5, 65, 30)
end

function Main.LoadNextRom()
	console.clear() -- Clearing the console for each new game helps with troubleshooting issues

	local wasSoundOn = client.GetSoundOn()

	local nextRom
	if Options["Use premade ROMs"] then
		client.SetSoundOn(false)
		nextRom = Main.GetNextRomFromFolder()
	elseif Options["Generate ROM each time"] then
		client.SetSoundOn(false)
		nextRom = Main.GenerateNextRom()
	else
		print("ERROR: The Quick-load feature is currently disabled.")
		Main.DisplayError("The Quick-load feature is currently disabled.\n\nEnable this at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
	end

	if nextRom ~= nil then
		Tracker.resetData()
		print("New ROM \"" .. nextRom.name .. "\" is ready to load. Tracker data has been reset.")
		if client.getversion() ~= "2.9" then
			client.closerom() -- This appears to not be needed for Bizhawk 2.9+
		end
		client.openrom(nextRom.path)
	else
		print("\n--- Unable to Quick-load a new ROM, reloading previous ROM.")
	end

	if client.GetSoundOn() ~= wasSoundOn then
		client.SetSoundOn(wasSoundOn)
	end

	Main.loadNextSeed = false
	Main.Run()
end

function Main.GetNextRomFromFolder()
	print("Attempting to load next ROM in sequence from ROMs Folder...")

	if Options.FILES["ROMs Folder"] == nil or Options.FILES["ROMs Folder"] == "" then
		print("ERROR: Either the ROMs Folder is incorrect, or current loaded ROM is not in that folder.\n")
		Main.DisplayError("Either the ROMs Folder is incorrect, or current loaded ROM is not in that folder.\n\nFix this at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
		return nil
	end

	local romname = gameinfo.getromname()

	-- Split the ROM name into its prefix and numerical values
	local romprefix = string.match(romname, '[^0-9]+') or ""
	local romnumber = string.match(romname, '[0-9]+') or "0"

	local attemptsfile = string.format("%s %s", romprefix, Constants.Files.PostFixes.ATTEMPTS_FILE)
	Main.IncrementAttemptsCounter(attemptsfile, romnumber)

	-- Increment to the next ROM and determine its full file path
	local nextromname = string.format(romprefix .. "%0" .. string.len(romnumber) .. "d", romnumber + 1)
	local nextrompath = string.format("%s/%s%s", Options.FILES["ROMs Folder"], nextromname, Constants.Files.Extensions.GBA_ROM)

	-- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
	if not Main.FileExists(nextrompath) then
		-- File doesn't exist, try again with underscores instead of spaces
		nextromname = nextromname:gsub(" ", "_")
		nextrompath = string.format("%s/%s%s", Options.FILES["ROMs Folder"], nextromname, Constants.Files.Extensions.GBA_ROM)
		if not Main.FileExists(nextrompath) then
			-- This means there doesn't exist a ROM file with spaces or underscores
			print("Unable to find next ROM: " .. nextromname .. Constants.Files.Extensions.GBA_ROM .. "\n")
			Main.DisplayError("Unable to find next ROM: " .. nextromname .. Constants.Files.Extensions.GBA_ROM .. "\n\nMake sure your ROMs are numbered and the ROMs folder is correct.")
			return nil
		end
	end

	return {
		name = nextromname,
		path = nextrompath,
	}
end

function Main.GenerateNextRom()
	if Main.OS ~= "Windows" then
		print("The auto-generate a new ROM feature is currently not supported on non-Windows OS.")
		Main.DisplayError("The auto-generate a new ROM feature is currently not supported on non-Windows OS.\n\nPlease use the other Quick-load option: From a ROMs Folder.")
		return nil
	end

	if not (Main.FileExists(Options.FILES["Randomizer JAR"]) and Main.FileExists(Options.FILES["Settings File"]) and Main.FileExists(Options.FILES["Source ROM"])) then
		print("Files missing that are required for Quick-load to generate a new ROM.")
		Main.DisplayError("Files missing that are required for Quick-load to generate a new ROM.\n\nFix these at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
		return nil
	end

	local filename = Utils.extractFileNameFromPath(Options.FILES["Settings File"])
	local attemptsfile = string.format("%s %s", filename, Constants.Files.PostFixes.ATTEMPTS_FILE)
	local nextromname = string.format("%s %s%s", filename, Constants.Files.PostFixes.AUTORANDOMIZED, Constants.Files.Extensions.GBA_ROM)
	local nextrompath = Utils.getWorkingDirectory() .. nextromname

	Main.IncrementAttemptsCounter(attemptsfile, 1)

	local javacommand = string.format(
		'java -Xmx4608M -jar "%s" cli -s "%s" -i "%s" -o "%s" -l',
		Options.FILES["Randomizer JAR"],
		Options.FILES["Settings File"],
		Options.FILES["Source ROM"],
		nextrompath
	)

	print("Generating next ROM: " .. nextromname)
	local pipe = io.popen(string.format("%s 2>%s", javacommand, Constants.Files.RANDOMIZER_ERROR_LOG))
	if pipe ~= nil then
		local output = pipe:read("*all")
		print("> " .. output)
	end

	-- If something went wrong and the ROM wasn't generated to the ROM path
	if not Main.FileExists(nextrompath) then
		print("The Randomizer ZX program failed to generate a ROM. Check the generated " .. Constants.Files.RANDOMIZER_ERROR_LOG .. " file for errors.")
		Main.DisplayError("The Randomizer ZX program failed to generate a ROM.\n\nCheck the " .. Constants.Files.RANDOMIZER_ERROR_LOG .. " file in the tracker folder for errors.")
		return nil
	end

	return {
	 	name = nextromname,
	 	path = nextrompath,
	}
end

-- Increment the attempts counter through a .txt file
function Main.IncrementAttemptsCounter(filename, defaultStart)
	if Main.FileExists(filename) then
		local attemptsRead = io.open(filename, "r")
		if attemptsRead ~= nil then
			local attemptsText = attemptsRead:read("*a")
			attemptsRead:close()
			if attemptsText ~= nil and tonumber(attemptsText) ~= nil then
				Main.currentSeed = tonumber(attemptsText)
			end
		end
	elseif defaultStart ~= nil then
		Main.currentSeed = defaultStart
	end

	Main.currentSeed = Main.currentSeed + 1
	Main.WriteAttemptsCounter(filename, Main.currentSeed)
end

function Main.ReadAttemptsCounter()
	local filename = Main.GetAttemptsFile()

	if filename ~= nil then
		local attemptsRead = io.open(filename, "r")
		if attemptsRead ~= nil then
			local attemptsText = attemptsRead:read("*a")
			attemptsRead:close()
			if attemptsText ~= nil and tonumber(attemptsText) ~= nil then
				Main.currentSeed = tonumber(attemptsText)
			end
		end
	else
		-- Otherwise, check the ROM name for an attempt count, eg "Fire Red 213"
		local romname = gameinfo.getromname()
		local romnumber = string.match(romname, '[0-9]+') or "1"
		if romnumber ~= "1" then
			Main.currentSeed = tonumber(romnumber)
		end
	end
end

function Main.WriteAttemptsCounter(filename, attemptsCount)
	attemptsCount = attemptsCount or Main.currentSeed

	local attemptsWrite = io.open(filename, "w")
	if attemptsWrite ~= nil then
		attemptsWrite:write(attemptsCount)
		attemptsWrite:close()
	end
end

function Main.GetAttemptsFile()
	local romname = gameinfo.getromname()
	local romprefix = string.match(romname, '[^0-9]+') or "" -- remove numbers
	romprefix = romprefix:gsub(" " .. Constants.Files.PostFixes.AUTORANDOMIZED, "") -- remove quickload post-fix

	-- Check first if an attempts file exists based on the rom file name (w/o numbers)
	local filename = string.format("%s %s", romprefix, Constants.Files.PostFixes.ATTEMPTS_FILE)
	if not Main.FileExists(filename) then
		-- Otherwise, try using a filename based on the Quickload settings file name
		local settingsfile = Utils.extractFileNameFromPath(Options.FILES["Settings File"]) or ""
		filename = string.format("%s %s", settingsfile, Constants.Files.PostFixes.ATTEMPTS_FILE)
	end

	if Main.FileExists(filename) then
		return filename
	else
		return nil
	end
end

-- Get the user settings saved on disk and create the base Settings object; returns true if successfully reads in file
function Main.LoadSettings()
	local settings = nil

	-- Need to manually read the file to work around a bug in the ini parser, which
	-- does not correctly handle that the last iteration over lines() returns nil
	local file = io.open(Constants.Files.SETTINGS)
	if file ~= nil then
		settings = Inifile.parse(file:read("*a"), "memory")
		io.close(file)
	end

	if settings == nil then
		return false
	end

	-- Keep the meta data for saving settings later in a specified order
	Main.MetaSettings = settings

	-- [CONFIG]
	if settings.config ~= nil then
		if settings.config.FIRST_RUN ~= nil then
			Options.FIRST_RUN = settings.config.FIRST_RUN
		end
		if settings.config.RemindMeLater ~= nil then
			Main.Version.remindMe = settings.config.RemindMeLater
		end
		if settings.config.LatestAvailableVersion ~= nil then
			Main.Version.latestAvailable = settings.config.LatestAvailableVersion
		end
		if settings.config.DateLastChecked ~= nil then
			Main.Version.dateChecked = settings.config.DateLastChecked
		end

		for configKey, _ in pairs(Options.FILES) do
			local configValue = settings.config[string.gsub(configKey, " ", "_")]
			if configValue ~= nil then
				Options.FILES[configKey] = configValue
			end
		end
	end

	-- [TRACKER]
	if settings.tracker ~= nil then
		for _, optionKey in ipairs(Constants.OrderedLists.OPTIONS) do
			local optionValue = settings.tracker[string.gsub(optionKey, " ", "_")]
			if optionValue ~= nil then
				Options[optionKey] = optionValue
			end
		end
	end

	-- [CONTROLS]
	if settings.controls ~= nil then
		for controlKey, _ in pairs(Options.CONTROLS) do
			local controlValue = settings.controls[string.gsub(controlKey, " ", "_")]
			if controlValue ~= nil then
				Options.CONTROLS[controlKey] = controlValue
			end
		end
	end

	-- [THEME]
	if settings.theme ~= nil then
		for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do
			local color_hexval = settings.theme[string.gsub(colorkey, " ", "_")]
			if color_hexval ~= nil then
				Theme.COLORS[colorkey] = 0xFF000000 + tonumber(color_hexval, 16)
			end
		end

		local enableMoveTypes = settings.theme.MOVE_TYPES_ENABLED
		if enableMoveTypes ~= nil then
			Theme.MOVE_TYPES_ENABLED = enableMoveTypes
			Theme.Buttons.MoveTypeEnabled.toggleState = not enableMoveTypes -- Show the opposite of the Setting, can't change existing theme strings
		end
	end

	return true
end

-- Saves the user settings on to disk
function Main.SaveSettings(forced)
	-- Don't bother saving to a file if nothing has changed
	if not forced and not Options.settingsUpdated and not Theme.settingsUpdated then
		return
	end

	local settings = Main.MetaSettings

	if settings == nil then settings = {} end
	if settings.config == nil then settings.config = {} end
	if settings.tracker == nil then settings.tracker = {} end
	if settings.controls == nil then settings.controls = {} end
	if settings.theme == nil then settings.theme = {} end

	-- [CONFIG]
	settings.config.FIRST_RUN = Options.FIRST_RUN
	settings.config.RemindMeLater = Main.Version.remindMe
	settings.config.LatestAvailableVersion = Main.Version.latestAvailable
	settings.config.DateLastChecked = Main.Version.dateChecked

	for configKey, _ in pairs(Options.FILES) do
		local encodedKey = string.gsub(configKey, " ", "_")
		settings.config[encodedKey] = Options.FILES[configKey]
	end

	-- [TRACKER]
	for _, optionKey in ipairs(Constants.OrderedLists.OPTIONS) do
		local encodedKey = string.gsub(optionKey, " ", "_")
		settings.tracker[encodedKey] = Options[optionKey]
	end

	-- [CONTROLS]
	for _, controlKey in ipairs(Constants.OrderedLists.CONTROLS) do
		local encodedKey = string.gsub(controlKey, " ", "_")
		settings.controls[encodedKey] = Options.CONTROLS[controlKey]
	end

	-- [THEME]
	for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do
		local encodedKey = string.gsub(colorkey, " ", "_")
		settings.theme[encodedKey] = string.upper(string.sub(string.format("%#x", Theme.COLORS[colorkey]), 5))
	end
	settings.theme["MOVE_TYPES_ENABLED"] = Theme.MOVE_TYPES_ENABLED

	Inifile.save(Constants.Files.SETTINGS, settings)
	Options.settingsUpdated = false
	Theme.settingsUpdated = false
end

if Main.Initialize() then
	Main.Run()
end
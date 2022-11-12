Main = {}

-- The latest version of the tracker. Should be updated with each PR.
Main.Version = { major = "7", minor = "0", patch = "0" }

Main.CreditsList = { -- based on the PokemonBizhawkLua project by MKDasher
	CreatedBy = "Besteon",
	Contributors = { "UTDZac", "Fellshadow", "bdjeffyp", "OnlySpaghettiCode", "thisisatest", "Amber Cyprian", "ninjafriend", "kittenchilly", "Kurumas", "davidhouweling", "AKD", "rcj001", "GB127", },
}

-- Returns false if an error occurs that completely prevents the Tracker from functioning; otherwise, returns true
function Main.Initialize()
	Main.TrackerVersion = string.format("%s.%s.%s", Main.Version.major, Main.Version.minor, Main.Version.patch)
	Main.Version.remindMe = true
	Main.Version.latestAvailable = Main.TrackerVersion
	Main.Version.dateChecked = ""
	Main.Version.showUpdate = false

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
		"/screens/UpdateScreen.lua",
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
			print("Error attempting to use 'io.popen(\"cd\")':")
			print(err)
			print("Lua Engine: " .. client.get_lua_engine())
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
	if GameSettings.gamename == "Unsupported Game" then
		print("Unsupported Game detected, please load a supported game ROM")
		print("Check the README.txt file in the tracker folder for supported games")
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
		UpdateScreen.initialize()
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
-- forcedCheck: if true, will force an update check (please use sparingly)
function Main.CheckForVersionUpdate(forcedCheck)
	if Main.OS ~= "Windows" then
		return
	end

	-- %x - Date representation for current locale (Standard date string), eg. "25/04/07"
	local todaysDate = os.date("%x")

	-- Only notify about updates once per day
	if forcedCheck or todaysDate ~= Main.Version.dateChecked then
		local update_cmd = string.format('curl "%s" --ssl-no-revoke', Constants.Release.VERSION_URL)
		local pipe = io.popen(update_cmd) or ""
		if pipe ~= "" then
			local response = pipe:read("*all") or ""

			-- Get version number formatted as [major].[minor].[patch]
			local _, _, major, minor, patch = string.match(response, '"tag_name":(%s+)"(%w+)(%d+)%.(%d+)%.(%d+)"')
			major = major or Main.Version.major
			minor = minor or Main.Version.minor
			patch = patch or Main.Version.patch

			local latestReleasedVersion = string.format("%s.%s.%s", major, minor, patch)

			-- Ignore patch numbers when checking to notify for a new release
			local newVersionAvailable = not Main.isOnLatestVersion(string.format("%s.%s.0", major, minor))

			-- Other than choosing to be reminded, only notify when a release comes out that is different than the last recorded newest release
			local shouldNotify = Main.Version.remindMe or Main.Version.latestAvailable ~= latestReleasedVersion

			-- Determine if a major version update is available and notify the user accordingly
			if newVersionAvailable and shouldNotify then
				Main.Version.showUpdate = true
			end

			-- Track that an update was checked today, so no additional api calls are performed today
			Main.Version.dateChecked = todaysDate
			-- Track the latest available version
			Main.Version.latestAvailable = latestReleasedVersion
		end
	end

	Main.SaveSettings(true)
end

-- Checks the current version of the Tracker against the version of the latest release, true if greater/equal; false otherwise.
-- 'versionToCheck': optional, if provided the version check will compare current version against the one provided.
function Main.isOnLatestVersion(versionToCheck)
	versionToCheck = versionToCheck or Main.Version.latestAvailable

	if Main.TrackerVersion == versionToCheck then
		return true
	end

	local currMajor, currMinor, currPatch = string.match(Main.TrackerVersion, "(%d+)%.(%d+)%.(%d+)")
	local latestMajor, latestMinor, latestPatch = string.match(versionToCheck, "(%d+)%.(%d+)%.(%d+)")

	-- Attempt to prove that the current loaded version is greater than the latest available version
	if (tonumber(currMajor) or 0) > (tonumber(latestMajor) or 0) then
		return true
	end
	if (tonumber(currMinor) or 0) > (tonumber(latestMinor) or 0) then
		return true
	end
	if (tonumber(currPatch) or 0) > (tonumber(latestPatch) or 0) then
		return true
	end

	return false
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

	Main.SaveCurrentRom(nextromname)

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

-- Creates a backup copy of a ROM 'filename' and its log file, labeling them as "PreviousAttempt"
function Main.SaveCurrentRom(filename)
	if filename == nil then
		return
	end

	local filenameCopy = filename:gsub(Constants.Files.PostFixes.AUTORANDOMIZED, Constants.Files.PostFixes.PREVIOUSATTEMPT)
	if Main.CopyFile(filename, filenameCopy, "overwrite") then
		local logFilename = string.format("%s.log", filename)
		local logFilenameCopy = string.format("%s.log", filenameCopy)
		Main.CopyFile(logFilename, logFilenameCopy, "overwrite")
	end
end

-- Copies 'filename' to 'nameOfCopy' with option to overwrite the file if it exists, or append to it
-- overwriteOrAppend: 'overwrite' replaces any existing file, 'append' adds to it instead, otherwise no change if file already exists
function Main.CopyFile(filename, nameOfCopy, overwriteOrAppend)
	if filename == nil or filename == "" then
		return false
	end

	local originalFile = io.open(filename, "rb")
	if originalFile == nil then
		-- The originalFile to copy doesn't exist, simply do nothing and don't copy
		return false
	end

	nameOfCopy = nameOfCopy or (filename .. " (Copy)")

	-- If the file exists but the option to overwrite/append was not specified, avoid altering the file
	if Main.FileExists(nameOfCopy) and not (overwriteOrAppend == "overwrite" or overwriteOrAppend == "append") then
		print(string.format('Error: Unable to modify file "%s", no overwrite/append option specified.'), nameOfCopy or "N/A")
		return false
	end

	local copyOfFile
	if overwriteOrAppend == "append" then
		copyOfFile = io.open(nameOfCopy, "ab")
	else
		-- Default to overwriting the file even if no option specified
		copyOfFile = io.open(nameOfCopy, "wb")
	end

	if copyOfFile == nil then
		print(string.format('Error: Failed to write to file "%s"'), nameOfCopy or "N/A")
		return false
	end

	if overwriteOrAppend == "append" then
		copyOfFile:seek("end")
	end

	local nextBlock = originalFile:read(2^13)
	while nextBlock ~= nil do
		copyOfFile:write(nextBlock)
		nextBlock = originalFile:read(2^13)
	end

	originalFile:close()
	copyOfFile:close()

	return true
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
		if settings.config.ShowUpdateNotification ~= nil then
			Main.Version.showUpdate = settings.config.ShowUpdateNotification
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

		local enableTextShadows = settings.theme.DRAW_TEXT_SHADOWS
		if enableTextShadows ~= nil then
			Theme.DRAW_TEXT_SHADOWS = enableTextShadows
			Theme.Buttons.DrawTextShadows.toggleState = enableTextShadows
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
	settings.config.ShowUpdateNotification = Main.Version.showUpdate

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
	settings.theme["DRAW_TEXT_SHADOWS"] = Theme.DRAW_TEXT_SHADOWS

	Inifile.save(Constants.Files.SETTINGS, settings)
	Options.settingsUpdated = false
	Theme.settingsUpdated = false
end
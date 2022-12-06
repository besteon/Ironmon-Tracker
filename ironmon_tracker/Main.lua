Main = {}

-- The latest version of the tracker. Should be updated with each PR.
Main.Version = { major = "7", minor = "1", patch = "0" }

Main.CreditsList = { -- based on the PokemonBizhawkLua project by MKDasher
	CreatedBy = "Besteon",
	Contributors = { "UTDZac", "Fellshadow", "ninjafriend", "OnlySpaghettiCode", "bdjeffyp", "Amber Cyprian", "thisisatest", "kittenchilly", "Kurumas", "davidhouweling", "AKD", "rcj001", "GB127", },
}

Main.EMU = {
	MGBA = "mGBA",
	BIZHAWK = "Bizhawk",
}

-- Returns false if an error occurs that completely prevents the Tracker from functioning; otherwise, returns true
function Main.Initialize()
	Main.TrackerVersion = string.format("%s.%s.%s", Main.Version.major, Main.Version.minor, Main.Version.patch)
	Main.Version.remindMe = true
	Main.Version.latestAvailable = Main.TrackerVersion
	Main.Version.dateChecked = ""
	Main.Version.showUpdate = false

	Main.MetaSettings = {}
	Main.currentSeed = 1
	Main.loadNextSeed = false

	-- Set seed based on epoch seconds; required for other features
	math.randomseed(os.time() % 100000 * 17) -- seed was acting wonky (read as: predictable), so made it wonkier
	math.random() -- required first call, for some reason

	Main.SetupEmulatorInfo()

	 -- Clearing the console for each new game helps with troubleshooting issues
	-- if Main.IsOnBizhawk() then -- currently being done in IronmonTracker.lua instead
	-- 	console.clear()
	-- end

	-- Check the version of BizHawk that is running
	if Main.IsOnBizhawk() and not Main.SupportedBizhawkVersion() then
		print("This version of BizHawk is not supported for use with the Tracker.\nPlease update to version 2.8 or higher.")
		Main.DisplayError("This version of BizHawk is not supported for use with the Tracker.\n\nPlease update to version 2.8 or higher.")
		return false
	end

	if not Main.LoadFileManager() then
		return false
	end

	local onWindows = FileManager.setupWorkingDirectory()
	Main.OS = onWindows and "Windows" or "Linux"

	if not FileManager.loadTrackerFiles() then
		return false
	end

	-- Create the Settings file if it doesn't exist
	if not Main.LoadSettings() then
		Main.SaveSettings(true)

		-- No Settings file means this is the first time the tracker has run, so bounce out for Bizhawk to force a restart
		if Main.IsOnBizhawk() then -- Likely no longer need this: "and Options.FIRST_RUN"
			-- Options.FIRST_RUN = false
			-- Main.SaveSettings(true)
			print("ATTENTION: Please close and re-open Bizhawk to enable the Tracker.")
			Main.DisplayError("ATTENTION: Please close and re-open Bizhawk to enable the Tracker.")
			return false
		end
	end

	Main.ReadAttemptsCounter()
	Main.CheckForVersionUpdate()

	print(string.format(">> Ironmon Tracker v%s successfully loaded", Main.TrackerVersion))
	return true
end

-- Waits for game to be loaded, then begins the Main loop
function Main.Run()
	if GameSettings.getRomName() == "Null" then
		print("Waiting for a game ROM to be loaded... (File -> Open ROM)")
	end
	local romLoaded = false
	while not romLoaded do
		if GameSettings.getRomName() ~= "Null" then romLoaded = true end
		Main.frameAdvance()
	end

	Main.InitializeAllTrackerFiles()

	-- If the loaded game is unsupported, remove the Tracker padding but continue to let the game play.
	if GameSettings.gamename == "Unsupported Game" then
		print("Unsupported Game detected, please load a supported game ROM")
		print("Check the README.txt file in the tracker folder for supported games")
		if Main.IsOnBizhawk() then
			---@diagnostic disable-next-line: undefined-global
			client.SetGameExtraPadding(0, 0, 0, 0)
			while true do
				Main.frameAdvance()
			end
		end
		return
	end

	if Main.IsOnBizhawk() then
		---@diagnostic disable-next-line: undefined-global
		event.onexit(Program.HandleExit, "HandleExit")

		while Main.loadNextSeed == false do
			Program.mainLoop()
			Main.frameAdvance()
		end

		Main.LoadNextRom()
	else -- mGBA specific loops
		MGBA.printStartupInstructions()
		---@diagnostic disable-next-line: undefined-global
		Main.frameCallbackId = callbacks:add("frame", Program.mainLoop)
		---@diagnostic disable-next-line: undefined-global
		Main.keysreadCallbackId = callbacks:add("keysRead", Input.checkJoypadInput)
	end
end

-- Check which emulator is in use
function Main.SetupEmulatorInfo()
	local frameAdvanceFunc
	-- This function 'createBuffer' only exists on mGBA
	if console.createBuffer == nil then
		Main.Emulator = Main.EMU.BIZHAWK
		frameAdvanceFunc = function()
			---@diagnostic disable-next-line: undefined-global
			emu.frameadvance()
		end
	else
		Main.Emulator = Main.EMU.MGBA
		frameAdvanceFunc = function()
			-- ---@diagnostic disable-next-line: undefined-global
			-- emu:runFrame() -- don't use this, use callbacks:add("frame", func) instead
		end
	end
	Main.frameAdvance = frameAdvanceFunc
end

function Main.IsOnBizhawk()
	return Main.Emulator == Main.EMU.BIZHAWK
end

-- Checks if Bizhawk version is 2.8 or later
function Main.SupportedBizhawkVersion()
	-- Significantly older Bizhawk versions don't have a client.getversion function
	if client == nil or client.getversion == nil then return false end

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

function Main.LoadFileManager()
	local slash = package.config:sub(1,1) or "\\" -- Windows is \ and Linux is /
	local fileManagerPath = "ironmon_tracker" .. slash .. "FileManager.lua"

	local fileManagerFile = io.open(fileManagerPath, "r")
	if fileManagerFile == nil then
		fileManagerPath = IronmonTracker.workingDir .. fileManagerPath
		fileManagerFile = io.open(fileManagerPath, "r")
		if fileManagerFile == nil then
			print("Unable to load " .. fileManagerPath .. "\nMake sure all of the downloaded Tracker's files are still together.")
			Main.DisplayError("Unable to load " .. fileManagerPath .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
			return false
		end
	end
	io.close(fileManagerFile)
	dofile(fileManagerPath)

	return true
end

-- Displays a given error message in a pop-up dialogue box
function Main.DisplayError(errMessage)
	if not Main.IsOnBizhawk() then return end

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

function Main.InitializeAllTrackerFiles()
	-- Initialize everything in the proper order
	Memory.initialize()
	GameSettings.initialize()
	PokemonData.initialize()
	MoveData.initialize()
	RouteData.initialize()

	Program.initialize()
	Drawing.initialize()
	Options.initialize()
	Theme.initialize()
	Tracker.initialize()

	if not Main.IsOnBizhawk() then
		MGBA.initialize()
		MGBADisplay.initialize()
	end

	TrackerScreen.initialize()
	NavigationMenu.initialize()
	StartupScreen.initialize()
	UpdateScreen.initialize()
	SetupScreen.initialize()
	ExtrasScreen.initialize()
	QuickloadScreen.initialize()
	GameOptionsScreen.initialize()
	TrackedDataScreen.initialize()
	StatsScreen.initialize()
end

-- Determines if there is an update to the current Tracker version
-- Intentionally will only check against Major and Minor version updates,
-- allowing patches to seamlessly update without bothering every end-user
-- forcedCheck: if true, will force an update check (please use sparingly)
function Main.CheckForVersionUpdate(forcedCheck)
	if Main.OS ~= "Windows" then
		-- io.popen only works on Windows
		return
	end

	-- %x - Date representation for current locale (Standard date string), eg. "25/04/07"
	local todaysDate = os.date("%x")

	-- Only notify about updates once per day
	if forcedCheck or todaysDate ~= Main.Version.dateChecked then
		local update_cmd = string.format('curl "%s" --ssl-no-revoke', FileManager.URLS.VERSION)
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

	currMajor, currMinor, currPatch = (tonumber(currMajor) or 0), (tonumber(currMinor) or 0), (tonumber(currPatch) or 0)
	latestMajor, latestMinor, latestPatch = (tonumber(latestMajor) or 0), (tonumber(latestMinor) or 0), (tonumber(latestPatch) or 0)

	if currMajor > latestMajor then
		return true
	elseif currMajor == latestMajor then
		if currMinor > latestMinor then
			return true
		elseif currMinor == latestMinor then
			if currPatch > latestPatch then
				return true
			end
		end
	end

	return false
end

function Main.LoadNextRom()
	local wasSoundOn
	if Main.IsOnBizhawk() then
		wasSoundOn = client.GetSoundOn()
		client.SetSoundOn(false)
		console.clear() -- Clearing the console for each new game helps with troubleshooting issues
	else
		MGBA.clearConsole()
	end

	local nextRom
	if Options["Use premade ROMs"] then
		nextRom = Main.GetNextRomFromFolder()
	elseif Options["Generate ROM each time"] then
		nextRom = Main.GenerateNextRom()
	else
		print("ERROR: The Quick-load feature is currently disabled.")
		Main.DisplayError("The Quick-load feature is currently disabled.\n\nEnable this at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
	end

	if nextRom ~= nil then
		Tracker.resetData()
		print("New ROM \"" .. nextRom.name .. "\" is being loaded. Tracker data from previous game has been reset.")
		if Main.IsOnBizhawk() then
			if client.getversion() ~= "2.9" then
				client.closerom() -- This appears to not be needed for Bizhawk 2.9+
			end
			client.openrom(nextRom.path)
		else
			---@diagnostic disable-next-line: undefined-global
			local success = emu:loadFile(nextRom.path)
			if success then
				---@diagnostic disable-next-line: undefined-global
				emu:reset()
			else
				print("ERROR: Unable to automatically load newly generated ROM: " .. nextRom.name)
			end
		end
	else
		print("\n--- Unable to Quick-load a new ROM, reloading previous ROM.")
	end

	if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
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

	local romname = GameSettings.getRomName()

	-- Split the ROM name into its prefix and numerical values
	local romprefix = string.match(romname, '[^0-9]+') or ""
	local romnumber = string.match(romname, '[0-9]+') or "0"

	-- Increment to the next ROM and determine its full file path
	local nextromname = string.format(romprefix .. "%0" .. string.len(romnumber) .. "d", romnumber + 1)
	local nextrompath = string.format("%s%s%s%s", Options.FILES["ROMs Folder"], FileManager.slash, nextromname, FileManager.Extensions.GBA_ROM)

	-- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
	if not FileManager.fileExists(nextrompath) then
		-- File doesn't exist, try again with underscores instead of spaces
		nextromname = nextromname:gsub(" ", "_")
		nextrompath = string.format("%s%s%s%s", Options.FILES["ROMs Folder"], FileManager.slash, nextromname, FileManager.Extensions.GBA_ROM)
		if not FileManager.fileExists(nextrompath) then
			-- This means there doesn't exist a ROM file with spaces or underscores
			print("Unable to find next ROM: " .. nextromname .. FileManager.Extensions.GBA_ROM .. "\n")
			Main.DisplayError("Unable to find next ROM: " .. nextromname .. FileManager.Extensions.GBA_ROM .. "\n\nMake sure your ROMs are numbered and the ROMs folder is correct.")
			return nil
		end
	end

	-- After successfully locating the next ROM to load, increment the attempts counter
	local attemptsfilename = string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	Main.IncrementAttemptsCounter(attemptsfilename, romnumber)

	return {
		name = nextromname,
		path = nextrompath,
	}
end

function Main.GenerateNextRom()
	if Main.OS ~= "Windows" then
		print("The auto-generate a new ROM feature is only supported on Windows OS.")
		Main.DisplayError("The auto-generate a new ROM feature is only supported on Windows OS.\n\nPlease use the other Quickload option: From a ROMs Folder.")
		return nil
	end

	if not (FileManager.fileExists(Options.FILES["Randomizer JAR"]) and FileManager.fileExists(Options.FILES["Settings File"]) and FileManager.fileExists(Options.FILES["Source ROM"])) then
		print("Files missing that are required for Quick-load to generate a new ROM.")
		Main.DisplayError("Files missing that are required for Quick-load to generate a new ROM.\n\nFix these at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
		return nil
	end

	local filename = FileManager.extractFileNameFromPath(Options.FILES["Settings File"])
	local attemptsfilename = string.format("%s %s%s", filename, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	local nextromname = string.format("%s %s%s", filename, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
	local nextrompath = FileManager.getAbsPath(nextromname)

	local previousRomName = Main.SaveCurrentRom(nextromname)

	-- mGBA only, need to unload current ROM but loading another temp ROM
	if previousRomName ~= nil and not Main.IsOnBizhawk() then
		---@diagnostic disable-next-line: undefined-global
		emu:loadFile(FileManager.getAbsPath(previousRomName))
	end

	local javacommand = string.format(
		'java -Xmx4608M -jar "%s" cli -s "%s" -i "%s" -o "%s" -l',
		Options.FILES["Randomizer JAR"],
		Options.FILES["Settings File"],
		Options.FILES["Source ROM"],
		nextrompath
	)

	local pipe = io.popen(string.format("%s 2>%s", javacommand, FileManager.getAbsPath(FileManager.Files.RANDOMIZER_ERROR_LOG)))
	if pipe ~= nil then
		local output = pipe:read("*all")
		print("> " .. output)
	end

	-- If something went wrong and the ROM wasn't generated to the ROM path
	if not FileManager.fileExists(nextrompath) then
		print("The Randomizer ZX program failed to generate a ROM. Check the generated " .. FileManager.Files.RANDOMIZER_ERROR_LOG .. " file for errors.")
		Main.DisplayError("The Randomizer ZX program failed to generate a ROM.\n\nCheck the " .. FileManager.Files.RANDOMIZER_ERROR_LOG .. " file in the tracker folder for errors.")
		return nil
	end

	-- After successfully generating the next ROM to load, increment the attempts counter
	Main.IncrementAttemptsCounter(attemptsfilename, 1)

	return {
	 	name = nextromname,
	 	path = nextrompath,
	}
end

-- Creates a backup copy of a ROM 'filename' and its log file, labeling them as "PreviousAttempt"
-- returns the name of the newly created file, if any
function Main.SaveCurrentRom(filename)
	if filename == nil then
		return nil
	end

	local filenameCopy = filename:gsub(FileManager.PostFixes.AUTORANDOMIZED, FileManager.PostFixes.PREVIOUSATTEMPT)
	if Main.CopyFile(filename, filenameCopy, "overwrite") then
		local logFilename = filename .. FileManager.Extensions.RANDOMIZER_LOGFILE
		local logFilenameCopy = filenameCopy .. FileManager.Extensions.RANDOMIZER_LOGFILE
		Main.CopyFile(logFilename, logFilenameCopy, "overwrite")

		return filenameCopy
	end
	return nil
end

-- Copies 'filename' to 'nameOfCopy' with option to overwrite the file if it exists, or append to it
-- overwriteOrAppend: 'overwrite' replaces any existing file, 'append' adds to it instead, otherwise no change if file already exists
function Main.CopyFile(filename, nameOfCopy, overwriteOrAppend)
	if filename == nil or filename == "" then
		return false
	end

	local originalFile = io.open(FileManager.getAbsPath(filename), "rb")
	if originalFile == nil then
		-- The originalFile to copy doesn't exist, simply do nothing and don't copy
		return false
	end

	nameOfCopy = nameOfCopy or (filename .. " (Copy)")
	local filepathCopy = FileManager.getAbsPath(nameOfCopy)

	-- If the file exists but the option to overwrite/append was not specified, avoid altering the file
	if FileManager.fileExists(filepathCopy) and not (overwriteOrAppend == "overwrite" or overwriteOrAppend == "append") then
		print(string.format('Error: Unable to modify file "%s", no overwrite/append option specified.', nameOfCopy))
		return false
	end

	local copyOfFile
	if overwriteOrAppend == "append" then
		copyOfFile = io.open(filepathCopy, "ab")
	else
		-- Default to overwriting the file even if no option specified
		copyOfFile = io.open(filepathCopy, "wb")
	end

	if copyOfFile == nil then
		print(string.format('Error: Failed to write to file "%s"', nameOfCopy))
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
	local filepath = FileManager.getPathIfExists(filename)
	if filepath ~= nil then
		local attemptsRead = io.open(filepath, "r")
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
	local filepath = Main.GetAttemptsFile()

	if filepath ~= nil then
		local attemptsRead = io.open(filepath, "r")
		if attemptsRead ~= nil then
			local attemptsText = attemptsRead:read("*a")
			attemptsRead:close()
			if attemptsText ~= nil and tonumber(attemptsText) ~= nil then
				Main.currentSeed = tonumber(attemptsText)
			end
		end
	else
		-- Otherwise, check the ROM name for an attempt count, eg "Fire Red 213"
		local romname = GameSettings.getRomName()
		local romnumber = string.match(romname, '[0-9]+') or "1"
		if romnumber ~= "1" then
			Main.currentSeed = tonumber(romnumber)
		end
	end
end

function Main.WriteAttemptsCounter(filename, attemptsCount)
	attemptsCount = attemptsCount or Main.currentSeed

	local attemptsWrite = io.open(FileManager.getAbsPath(filename), "w")
	if attemptsWrite ~= nil then
		attemptsWrite:write(attemptsCount)
		attemptsWrite:close()
	end
end

function Main.GetAttemptsFile()
	local romname = GameSettings.getRomName()
	local romprefix = string.match(romname, '[^0-9]+') or "" -- remove numbers
	romprefix = romprefix:gsub(" " .. FileManager.PostFixes.AUTORANDOMIZED, "") -- remove quickload post-fix

	-- Check first if an attempts file exists based on the rom file name (w/o numbers)
	local filename = string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	local filepath = FileManager.getPathIfExists(filename)
	if filepath == nil then
		-- Otherwise, try using a filename based on the Quickload settings file name
		local settingsfile = FileManager.extractFileNameFromPath(Options.FILES["Settings File"]) or ""
		filename = string.format("%s %s%s", settingsfile, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
		filepath = FileManager.getPathIfExists(filename)
	end

	return filepath
end

-- Get the user settings saved on disk and create the base Settings object; returns true if successfully reads in file
function Main.LoadSettings()
	local settings = nil

	local file = io.open(FileManager.getAbsPath(FileManager.Files.SETTINGS))
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

	Inifile.save(FileManager.getAbsPath(FileManager.Files.SETTINGS), settings)
	Options.settingsUpdated = false
	Theme.settingsUpdated = false
end
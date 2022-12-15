Main = {}

-- The latest version of the tracker. Should be updated with each PR.
Main.Version = { major = "7", minor = "0", patch = "13" }

Main.CreditsList = { -- based on the PokemonBizhawkLua project by MKDasher
	CreatedBy = "Besteon",
	Contributors = { "UTDZac", "Fellshadow", "ninjafriend", "OnlySpaghettiCode", "bdjeffyp", "Amber Cyprian", "thisisatest", "kittenchilly", "Kurumas", "davidhouweling", "AKD", "rcj001", "GB127", },
}

Main.EMU = {
	MGBA = "mGBA", -- Lua 5.4
	BIZHAWK_OLD = "Bizhawk Old", -- Non-compatible Bizhawk version
	BIZHAWK28 = "Bizhawk 2.8", -- Lua 5.1
	BIZHAWK29 = "Bizhawk 2.9", -- Lua 5.3+?
	BIZHAWK_FUTURE = "Bizhawk Future", -- Lua 5.3+?
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

	-- Check the version of BizHawk that is running
	if Main.emulator == Main.EMU.BIZHAWK_OLD then
		print("This version of BizHawk is not supported for use with the Tracker.\nPlease update to version 2.8 or higher.")
		Main.DisplayError("This version of BizHawk is not supported for use with the Tracker.\n\nPlease update to version 2.8 or higher.")
		return false
	end

	if not Main.SetupFileManager() then
		return false
	end

	if FileManager.slash == "\\" then
		Main.OS = "Windows"
	else
		Main.OS = "Linux"
		if Main.IsOnBizhawk() then -- for now assume special characters render fine on Linux
			Main.supportsSpecialChars = true
		end
	end

	for _, filename in ipairs(FileManager.Files.LuaCode) do
		if not FileManager.loadLuaFile(filename) then
			return false
		end
	end
	if not FileManager.loadLuaFile(FileManager.Files.AUTOUPDATER) then
		return false
	end

	-- Create the Settings file if it doesn't exist
	if not Main.LoadSettings() then
		Main.SaveSettings(true)

		-- No Settings file means this is the first time the tracker has run, so bounce out for Bizhawk to force a restart
		if Main.IsOnBizhawk() then
			print("ATTENTION: Please close and re-open Bizhawk to enable the Tracker.")
			Main.DisplayError("ATTENTION: Please close and re-open Bizhawk to enable the Tracker.")
			---@diagnostic disable-next-line: undefined-global
			client.SetGameExtraPadding(0, 0, 0, 0)
			return false
		end
	end

	Main.ReadAttemptsCount()
	Main.CheckForVersionUpdate()

	print(string.format("> Ironmon Tracker v%s successfully loaded", Main.TrackerVersion))
	return true
end

-- Waits for game to be loaded, then begins the Main loop. From here after, do NOT trust values from IronmonTracker.lua
function Main.Run()
	if Main.IsOnBizhawk() then
		-- mGBA hates infinite loops. This "wait for startup" is handled differently
		if GameSettings.getRomName() == nil or GameSettings.getRomName() == "Null" then
			print("> Waiting for a game ROM to be loaded... (File -> Open ROM)")
		end
		local romLoaded = false
		while not romLoaded do
			if GameSettings.getRomName() ~= nil and GameSettings.getRomName() ~= "Null" then
				romLoaded = true
			end
			Main.frameAdvance()
		end
	else
		-- mGBA specific loops
		if Main.startCallbackId == nil then
			---@diagnostic disable-next-line: undefined-global
			Main.startCallbackId = callbacks:add("start", Main.Run)
		end
		if Main.resetCallbackId == nil then
			---@diagnostic disable-next-line: undefined-global
			Main.resetCallbackId = callbacks:add("reset", Main.Run) -- start doesn't get trigged on-reset
		end
		if Main.stopCallbackId == nil then
			---@diagnostic disable-next-line: undefined-global
			Main.stopCallbackId = callbacks:add("stop", MGBA.stopRunLoops)
		end
		if Main.shutdownCallbackId == nil then
			---@diagnostic disable-next-line: undefined-global
			Main.shutdownCallbackId = callbacks:add("shutdown", MGBA.stopRunLoops)
		end

		---@diagnostic disable-next-line: undefined-global
		if emu == nil then
			print("> Waiting for a game ROM to be loaded... (mGBA Emulator -> File -> Load ROM...)")
			return
		else
			MGBA.startRunLoops()
		end
	end

	Memory.initialize()
	GameSettings.initialize()

	-- If the loaded game is unsupported, remove the Tracker padding but continue to let the game play.
	if GameSettings.gamename == nil or GameSettings.gamename == "Unsupported Game" then
		print("> Unsupported Game detected, please load a supported game ROM")
		print("> Check the README.txt file in the tracker folder for supported games")
		if Main.IsOnBizhawk() then
			---@diagnostic disable-next-line: undefined-global
			client.SetGameExtraPadding(0, 0, 0, 0)
		end
		return
	end

	-- After a game is successfully loaded, then initialize the remaining Tracker files
	Main.InitializeAllTrackerFiles()

	if Main.IsOnBizhawk() then
		---@diagnostic disable-next-line: undefined-global
		event.onexit(Program.HandleExit, "HandleExit")

		while Main.loadNextSeed == false do
			Program.mainLoop()
			Main.frameAdvance()
		end

		Main.LoadNextRom()
	else
		MGBA.printStartupInstructions()
	end
end

-- Check which emulator is in use
function Main.SetupEmulatorInfo()
	local frameAdvanceFunc
	if console.createBuffer == nil then -- This function doesn't exist in Bizhawk, only mGBA
		Main.emulator = Main.GetBizhawkVersion()
		Main.supportsSpecialChars = (Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE)
		frameAdvanceFunc = function()
			---@diagnostic disable-next-line: undefined-global
			emu.frameadvance()
		end
	else
		Main.emulator = Main.EMU.MGBA
		Main.supportsSpecialChars = true
		frameAdvanceFunc = function()
			-- ---@diagnostic disable-next-line: undefined-global
			-- emu:runFrame() -- don't use this, use callbacks:add("frame", func) instead
		end
	end
	Main.frameAdvance = frameAdvanceFunc
end

function Main.IsOnBizhawk()
	return Main.emulator == Main.EMU.BIZHAWK28 or Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE
end

-- Checks if Bizhawk version is 2.8 or later
function Main.GetBizhawkVersion()
	-- Significantly older Bizhawk versions don't have a client.getversion function
	if client == nil or client.getversion == nil then return false end

	-- Check the major and minor version numbers separately, to account for versions such as "2.10"
	local major, minor = string.match(client.getversion(), "(%d+)%.(%d+)")

	local majorNumber = tonumber(tostring(major)) or 0 -- tostring first allows nil input
	local minorNumber = tonumber(tostring(minor)) or 0

	if majorNumber >= 3 then
		-- Versions 3.0 or higher (not yet released)
		return Main.EMU.BIZHAWK_FUTURE
	elseif majorNumber < 2 or minorNumber < 8 then
		-- Versions 2.7 or lower (old, incompatible releases)
		return Main.EMU.BIZHAWK_OLD
	elseif minorNumber == 8 then
		return Main.EMU.BIZHAWK28
	elseif minorNumber == 9 then
		return Main.EMU.BIZHAWK29
	else
		-- Versions 2.10+
		return Main.EMU.BIZHAWK_FUTURE
	end
end

function Main.SetupFileManager()
	local slash = package.config:sub(1,1) or "\\" -- Windows is \ and Linux is /
	local fileManagerPath = "ironmon_tracker" .. slash .. "FileManager.lua"

	local fileManagerFile = io.open(fileManagerPath, "r")
	if fileManagerFile == nil then
		fileManagerPath = (IronmonTracker.workingDir or "") .. fileManagerPath
		fileManagerFile = io.open(fileManagerPath, "r")
		if fileManagerFile == nil then
			print("Unable to load " .. fileManagerPath .. "\nMake sure all of the downloaded Tracker's files are still together.")
			Main.DisplayError("Unable to load " .. fileManagerPath .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
			return false
		end
	end
	io.close(fileManagerFile)

	dofile(fileManagerPath)
	FileManager.setupWorkingDirectory()

	return true
end

-- Displays a given error message in a pop-up dialogue box
function Main.DisplayError(errMessage)
	if not Main.IsOnBizhawk() then return end -- Only Bizhawk allows popup form windows

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
	-- Update check not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
		return
	end

	-- %x - Date representation for current locale (Standard date string), eg. "25/04/07"
	local todaysDate = os.date("%x")

	-- Only notify about updates once per day
	if forcedCheck or todaysDate ~= Main.Version.dateChecked then
		local wasSoundOn
		if Main.IsOnBizhawk() then
			-- Disable Bizhawk sound while the update check is in process
			wasSoundOn = client.GetSoundOn()
			client.SetSoundOn(false)
		end

		local update_cmd = string.format('curl "%s" --ssl-no-revoke', FileManager.Urls.VERSION)
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

		if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
			client.SetSoundOn(wasSoundOn)
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
	Main.loadNextSeed = false

	local wasSoundOn
	if Main.IsOnBizhawk() then
		wasSoundOn = client.GetSoundOn()
		client.SetSoundOn(false)
		console.clear() -- Clearing the console for each new game helps with troubleshooting issues
	else
		MGBA.clearConsole()
	end

	local nextRomInfo
	if Options["Use premade ROMs"] then
		nextRomInfo = Main.GetNextRomFromFolder()
	elseif Options["Generate ROM each time"] then
		nextRomInfo = Main.GenerateNextRom()
	else
		print("> ERROR: The Quick-load feature is currently disabled.")
		Main.DisplayError("The Quick-load feature is currently disabled.\n\nEnable this at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
	end

	if nextRomInfo ~= nil then
		-- After successfully generating the next ROM to load, increment the attempts counter
		Main.currentSeed = Main.currentSeed + 1
		Main.WriteAttemptsCountToFile(nextRomInfo.attemptsFilePath)

		Tracker.resetData()
		if Main.IsOnBizhawk() then
			if Main.emulator == Main.EMU.BIZHAWK28 then
				client.closerom() -- This appears to not be needed for Bizhawk 2.9+
			end
			if Options["Use premade ROMs"] then
				print("> New ROM \"" .. nextRomInfo.fileName .. "\" is being loaded.")
			end
			client.openrom(nextRomInfo.filePath)
		else
			---@diagnostic disable-next-line: undefined-global
			local success = emu:loadFile(nextRomInfo.filePath)
			if success then
				if Options["Use premade ROMs"] then
					print("> New ROM \"" .. nextRomInfo.fileName .. "\" is being loaded.")
				end
				---@diagnostic disable-next-line: undefined-global
				emu:reset()
				return
			else
				print("> ERROR: Unable to Quickload next ROM: " .. nextRomInfo.fileName)
			end
		end
	else
		print("> Unable to Quickload a new ROM, reloading previous ROM.")
	end

	if Main.IsOnBizhawk() and client.GetSoundOn() ~= wasSoundOn then
		client.SetSoundOn(wasSoundOn)
	end

	Main.Run()
end

function Main.GetNextRomFromFolder()
	print("> Attempting to load next ROM in sequence.")

	local files = Main.GetQuickloadFiles()

	if #files.romList == 0 then
		print("> ERROR: Either the \"ROMs Folder\" setting is incorrect, or ROM files are missing from the quickload folder.\n")
		Main.DisplayError("Either the \"ROMs Folder\" setting is incorrect, or ROM files are missing from the quickload folder.\n\nFix this at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
		return nil
	end

	-- Options.FILES["ROMs Folder"] == nil or Options.FILES["ROMs Folder"] == ""

	local nextSeed = Main.currentSeed + 1
	local filenameFromFolder
	for _, filename in ipairs(files.romList) do
		local seedNumberText = string.match(filename, '[0-9]+')
		if seedNumberText ~= nil then
			local seedNumber = tonumber(seedNumberText)
			if seedNumber ~= nil and seedNumber == nextSeed then
				filenameFromFolder = filename
			end
		end
	end

	if not FileManager.fileExists((files.quickloadPath or "") .. filenameFromFolder) then
		local romName = filenameFromFolder or (GameSettings.getRomName() or "UNNAMED") .. FileManager.Extensions.GBA_ROM
		print(string.format("> Unable to find next ROM to load. Currently loaded ROM: %s", romName))
		Main.DisplayError(string.format("Unable to find next ROM to load. Currently loaded ROM: %s", romName) .. "\n\nMake sure your ROMs are numbered sequentially and the ROMs folder is correct.")
		return nil
	end

	-- local romname = GameSettings.getRomName() or ""

	-- Split the ROM name into its prefix and numerical values
	-- local romprefix = string.match(romname, '[^0-9]+') or ""
	-- local romnumber = string.match(romname, '[0-9]+') or "0"

	-- Increment to the next ROM and determine its full file path
	-- local nextromname = string.format(romprefix .. "%0" .. string.len(romnumber) .. "d", romnumber + 1)
	-- local nextrompath = string.format("%s%s%s%s", Options.FILES["ROMs Folder"], FileManager.slash, nextromname, FileManager.Extensions.GBA_ROM)

	-- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
	-- if not FileManager.fileExists(nextrompath) then
	-- 	-- File doesn't exist, try again with underscores instead of spaces
	-- 	nextromname = nextromname:gsub(" ", "_")
	-- 	nextrompath = string.format("%s%s%s%s", Options.FILES["ROMs Folder"], FileManager.slash, nextromname, FileManager.Extensions.GBA_ROM)
	-- 	if not FileManager.fileExists(nextrompath) then
	-- 		-- This means there doesn't exist a ROM file with spaces or underscores
	-- 		print("Unable to find next ROM: " .. nextromname .. FileManager.Extensions.GBA_ROM .. "\n")
	-- 		Main.DisplayError("Unable to find next ROM: " .. nextromname .. FileManager.Extensions.GBA_ROM .. "\n\nMake sure your ROMs are numbered and the ROMs folder is correct.")
	-- 		return nil
	-- 	end
	-- end

	-- After successfully locating the next ROM to load, increment the attempts counter
	local romprefix = string.match(filenameFromFolder, '[^0-9]+') or ""
	local attemptsFileName = string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)

	return {
		fileName = filenameFromFolder,
		filePath = (files.quickloadPath or "") .. filenameFromFolder,
		attemptsFilePath = FileManager.prependDir(attemptsFileName),
	}
end

function Main.GenerateNextRom()
	-- Auto-generate ROM not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
		print("The auto-generate a new ROM feature is only supported on Windows OS or Bizhawk 2.9+.")
		Main.DisplayError("The auto-generate a new ROM feature is only supported on Windows OS or Bizhawk 2.9+.\n\nPlease use the other Quickload option: From a ROMs Folder.")
		return nil
	end

	local files = Main.GetQuickloadFiles()

	if #files.jarList == 0 or #files.settingsList == 0 or #files.romList == 0 then
		print("> Files missing that are required for Quick-load to generate a new ROM.")
		Main.DisplayError("Files missing that are required for Quick-load to generate a new ROM.\n\nFix these at: Tracker Settings (gear icon) -> Tracker Setup -> Quick-load")
		return nil
	elseif #files.jarList > 1 or #files.settingsList > 1 or #files.romList > 1 then
		local msg1 = string.format("[Quickload ERROR] Too many GBA/JAR/RNQS files found in the quickload folder.")
		local msg2 = string.format("Please remove all-but-one of each these types of files from the folder.")
		print("> " .. msg1)
		print("> " .. msg2)
		Main.DisplayError(msg1 .. "\n" .. msg2)
		return nil
	end

	local jarPath = (files.quickloadPath or "") .. files.jarList[1]
	local settingsPath = (files.quickloadPath or "") .. files.settingsList[1]
	local romPath = (files.quickloadPath or "") .. files.romList[1]

	-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
	local filename = FileManager.extractFileNameFromPath(files.settingsList[1])
	local attemptsFileName = string.format("%s %s%s", filename, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	local nextRomName = string.format("%s %s%s", filename, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
	local nextRomPath = FileManager.prependDir(nextRomName)

	local previousRomName = Main.SaveCurrentRom(nextRomName)

	-- mGBA only, need to unload current ROM but loading another temp ROM
	if previousRomName ~= nil and not Main.IsOnBizhawk() then
		---@diagnostic disable-next-line: undefined-global
		emu:loadFile(FileManager.prependDir(previousRomName))
	end

	local javacommand = string.format(
		'java -Xmx4608M -jar "%s" cli -s "%s" -i "%s" -o "%s" -l',
		jarPath,
		settingsPath,
		romPath,
		nextRomPath
	)

	local success = false
	local pipe = io.popen(string.format('%s 2>"%s"', javacommand, FileManager.prependDir(FileManager.Files.RANDOMIZER_ERROR_LOG)))
	if pipe ~= nil then
		local output = pipe:read("*all")
		success = (output:find("Randomized successfully!", 1, true) ~= nil) -- It's possible this message changes in the future?
		if not success and output ~= "" then -- only print if something went wrong
			print("> " .. output)
		end
	end

	-- If something went wrong and the ROM wasn't generated to the ROM path
	if not success or not FileManager.fileExists(nextRomPath) then
		print("> The Randomizer ZX program failed to generate a ROM. Check the generated " .. FileManager.Files.RANDOMIZER_ERROR_LOG .. " file for errors.")
		Main.DisplayError("The Randomizer ZX program failed to generate a ROM.\n\nCheck the " .. FileManager.Files.RANDOMIZER_ERROR_LOG .. " file in the tracker folder for errors.")
		return nil
	end

	return {
		fileName = nextRomName,
		filePath = nextRomPath,
		attemptsFilePath = FileManager.prependDir(attemptsFileName),
	}
end

-- Returns a table containing [jars, settings, roms, quickloadPath] either from Settings.ini or from the Quickload folder
function Main.GetQuickloadFiles()
	local fileLists = {
		jarList = {},
		settingsList = {},
		romList = {},
		quickloadPath = nil,
	}

	-- If all three supplied exists, use those over anything else
	if Options["Generate ROM each time"] and FileManager.fileExists(Options.FILES["Randomizer JAR"]) and FileManager.fileExists(Options.FILES["Settings File"]) and FileManager.fileExists(Options.FILES["Source ROM"]) then
		table.insert(fileLists.jarList, Options.FILES["Randomizer JAR"])
		table.insert(fileLists.settingsList, Options.FILES["Settings File"])
		table.insert(fileLists.romList, Options.FILES["Source ROM"])
		return fileLists
	end

	local listsByExtension = {
		["jar"] = fileLists.jarList,
		["rnqs"] = fileLists.settingsList,
		["gba"] = fileLists.romList,
	}

	-- Search the quickload folder for compatible files used for quickload
	if Options["Use premade ROMs"] and Options["ROMs Folder"] ~= nil and Options["ROMs Folder"] ~= "" then
		-- First make sure the ROMs Folder ends with a slash
		if Options["ROMs Folder"]:sub(-1) ~= FileManager.slash then
			Options["ROMs Folder"] = Options["ROMs Folder"] .. FileManager.slash
		end
		fileLists.quickloadPath = Options["ROMs Folder"] -- Assumes absolute path
	else
		fileLists.quickloadPath = FileManager.prependDir(FileManager.Folders.Quickload .. FileManager.slash)
	end
	local quickloadFileNames = FileManager.getFilesFromDirectory(fileLists.quickloadPath)
	for _, filename in pairs(quickloadFileNames) do
		local ext = FileManager.extractFileExtensionFromPath(filename) or ""
		if listsByExtension[ext] ~= nil then
			table.insert(listsByExtension[ext], filename)
		end
	end

	return fileLists
end

-- Returns the smalls seed number from among files found in the quickload folder
function Main.FindSmallestSeedFromQuickloadFiles()
	local smallestSeed
	local quickloadFiles = Main.GetQuickloadFiles()
	for _, filename in ipairs(quickloadFiles.romList) do
		local seedNumberText = string.match(filename, '[0-9]+')
		if seedNumberText ~= nil then
			local seedNumber = tonumber(seedNumberText)
			if smallestSeed == nil or seedNumber < smallestSeed then
				smallestSeed = seedNumber
			end
		end
	end
	return smallestSeed or -1
end

-- Creates a backup copy of a ROM 'filename' and its log file, labeling them as "PreviousAttempt"
-- returns the name of the newly created file, if any
function Main.SaveCurrentRom(filename)
	if filename == nil then
		return nil
	end

	local filenameCopy = filename:gsub(FileManager.PostFixes.AUTORANDOMIZED, FileManager.PostFixes.PREVIOUSATTEMPT)
	local filepath = FileManager.prependDir(filename)
	local filepathCopy = FileManager.prependDir(filenameCopy)

	if FileManager.CopyFile(filepath, filepathCopy, "overwrite") then
		local logFilename = filename .. FileManager.Extensions.RANDOMIZER_LOGFILE
		local logFilenameCopy = filenameCopy .. FileManager.Extensions.RANDOMIZER_LOGFILE
		local logpath = FileManager.prependDir(logFilename)
		local logpathCopy = FileManager.prependDir(logFilenameCopy)

		FileManager.CopyFile(logpath, logpathCopy, "overwrite")

		return filenameCopy
	end

	return nil
end

function Main.GetAttemptsFile()
	local loadedRomName = GameSettings.getRomName() or ""
	local romprefix = string.match(loadedRomName, '[^0-9]+') or "" -- remove numbers
	romprefix = romprefix:gsub(" " .. FileManager.PostFixes.AUTORANDOMIZED, "") -- remove quickload post-fix

	-- First, try using a filename based on the Quickload settings file name
	local filename, filepath, settingsFileName
	if Options.FILES["Settings File"] ~= nil and Options.FILES["Settings File"] ~= "" then
		settingsFileName = FileManager.extractFileNameFromPath(Options.FILES["Settings File"])
	else
		local quickloadFiles = Main.GetQuickloadFiles()
		if #quickloadFiles.settingsList > 0 then
			settingsFileName = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1])
		end
	end
	if settingsFileName ~= nil then
		filename = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
		filepath = FileManager.getPathIfExists(filename)
	end

	-- Otherwise, check if an attempts file exists based on the ROM file name (w/o numbers)
	if filepath == nil then
		filename = string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
		filepath = FileManager.getPathIfExists(filename)
	end

	-- Otherwise, use the name used by the emulator itself
	if filepath == nil then
		filepath = FileManager.prependDir(string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS))
	end

	return filepath
end

-- Determines what attempts # the play session is on, either from pre-existing file or from Bizhawk's ROM Name
function Main.ReadAttemptsCount()
	local filepath = Main.GetAttemptsFile()
	local attemptsRead = io.open(filepath, "r")

	-- First check if a matching "attempts file" already exists, if so read from that
	if attemptsRead ~= nil then
		local attemptsText = attemptsRead:read("*a")
		attemptsRead:close()
		if attemptsText ~= nil and tonumber(attemptsText) ~= nil then
			Main.currentSeed = tonumber(attemptsText)
		end
	elseif Options["Use premade ROMs"] and (Options.FILES["ROMs Folder"] == nil or Options.FILES["ROMs Folder"] == "") then -- mostly for mGBA
		local smallestSeedNumber = Main.FindSmallestSeedFromQuickloadFiles()
		if smallestSeedNumber ~= -1 then
			Main.currentSeed = smallestSeedNumber
		end
	else -- mostly for Bizhawk
		local romname = GameSettings.getRomName() or ""
		local romnumber = string.match(romname, '[0-9]+') or "1"
		if romnumber ~= "1" then
			Main.currentSeed = tonumber(romnumber)
		end
	end
	-- Otherwise, leave the attempts count at default, which is 1
end

function Main.WriteAttemptsCountToFile(filepath, attemptsCount)
	attemptsCount = attemptsCount or Main.currentSeed

	local attemptsWrite = io.open(filepath, "w")
	if attemptsWrite ~= nil then
		attemptsWrite:write(attemptsCount)
		attemptsWrite:close()
	end
end

-- Get the user settings saved on disk and create the base Settings object; returns true if successfully reads in file
function Main.LoadSettings()
	local settings = nil

	local file = io.open(FileManager.prependDir(FileManager.Files.SETTINGS))
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

	Inifile.save(FileManager.prependDir(FileManager.Files.SETTINGS), settings)
	Options.settingsUpdated = false
	Theme.settingsUpdated = false
end
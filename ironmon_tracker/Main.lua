Main = {}

-- The latest version of the tracker. Should be updated with each PR.
Main.Version = { major = "9", minor = "2", patch = "3" }

Main.CreditsList = { -- based on the PokemonBizhawkLua project by MKDasher
	CreatedBy = "Besteon",
	Contributors = { "UTDZac", "Fellshadow", "ninjafriend", "OnlySpaghettiCode", "Aeiry", "Amber Cyprian", "bdjeffyp", "thisisatest", "kittenchilly", "IMTYP0", "brdy", "Harkenn", "TheRealTaintedWolf", "eusebyo", "Kurumas", "davidhouweling", "AKD", "rcj001", "GB127", },
}

Main.EMU = {
	MGBA = "mGBA", -- Lua 5.4
	BIZHAWK_OLD = "Bizhawk Old", -- Non-compatible Bizhawk version
	BIZHAWK28 = "Bizhawk 2.8", -- Lua 5.1
	BIZHAWK29 = "Bizhawk 2.9", -- Lua 5.4
	BIZHAWK_FUTURE = "Bizhawk Future", -- Lua 5.4
}

-- Returns false if an error occurs that completely prevents the Tracker from functioning; otherwise, returns true
function Main.Initialize()
	Main.TrackerVersion = string.format("%s.%s.%s", Main.Version.major, Main.Version.minor, Main.Version.patch)
	Main.Version.latestAvailable = Main.TrackerVersion
	Main.Version.releaseNotes = {}
	Main.Version.dateChecked = ""
	Main.Version.showUpdate = false
	Main.Version.showReleaseNotes = false

	Main.MetaSettings = {}
	Main.CrashReport = {
		crashedOccurred = false,
	}
	Main.currentSeed = 1
	Main.hasRunOnce = false

	-- Game loop control variables
	Main.loadNextSeed = false -- When enabled, exits the game loop to safely load a new game rom
	Main.updateRequested = false -- When enabled, exits the game loop to safely shut down and self-update the Tracker
	Main.forceRestart = false -- When enabled, exits the game loop to refresh and reload all Tracker scripts
	Main.loadDifferentRom = nil -- Holds a filepath to a different rom to load up; loaded immediately on the next frame

	-- Set seed based on epoch seconds; required for other features
	math.randomseed(os.time() % 100000 * 17) -- seed was acting wonky (read as: predictable), so made it wonkier
	math.random() -- required first call, for some reason

	Main.SetupEmulatorInfo()

	-- Check the version of BizHawk that is running
	if Main.emulator == Main.EMU.BIZHAWK_OLD then
		print("> ERROR: This version of BizHawk is not supported for use with the Tracker.")
		print("> Please update to version 2.8 or higher.")
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
	end

	-- Check if the Tracker was previously running; used to prevent self-update until a full restart
	if Program ~= nil then
		Main.hasRunOnce = (Program.hasRunOnce == true)
	end

	FileManager.setupJsonLibrary()
	for _, luafile in ipairs(FileManager.LuaCode) do
		if not FileManager.loadLuaFile(luafile.filepath) then
			return false
		end
	end
	if not FileManager.loadLuaFile(FileManager.Files.UPDATE_OR_INSTALL) then
		return false
	end

	FileManager.setupFolders()
	Main.LoadSettings()
	Resources.initialize()

	print(string.format("Ironmon Tracker v%s successfully loaded", Main.TrackerVersion))

	-- Get the quickload files just once to be used in several places during start-up, removed later
	Main.tempQuickloadFiles = Main.GetQuickloadFiles()
	Main.CheckForVersionUpdate()

	return true
end

-- Waits for game to be loaded, then begins the Main loop. From here after, do NOT trust values from IronmonTracker.lua
function Main.Run()
	if Main.IsOnBizhawk() then
		-- mGBA hates infinite loops. This "wait for startup" is handled differently
		if GameSettings.getRomName() == "" or GameSettings.getRomName() == "Null" then
			print("> Waiting for a game ROM to be loaded... (File -> Open ROM)")
		end
		local romLoaded = false
		while not romLoaded do
			if GameSettings.getRomName() ~= "" and GameSettings.getRomName() ~= "Null" then
				romLoaded = true
			end
			Main.frameAdvance()
		end
	else
		-- mGBA specific callbacks
		if Main.startCallbackId == nil then
			Main.startCallbackId = callbacks:add("start", Main.Run)
		end
		if Main.resetCallbackId == nil then
			 -- start doesn't get trigged on-reset
			Main.resetCallbackId = callbacks:add("reset", function()
				Main.ExitSafely(false)
				Main.Run()
			end)
		end
		if Main.stopCallbackId == nil then
			Main.stopCallbackId = callbacks:add("stop", function()
				Main.ExitSafely(false)
				MGBA.removeActiveRunCallbacks()
			end)
		end
		if Main.shutdownCallbackId == nil then
			Main.shutdownCallbackId = callbacks:add("shutdown", function()
				Main.ExitSafely(false)
				MGBA.removeActiveRunCallbacks()
			end)
		end
		if Main.crashedCallbackId == nil then
			Main.crashedCallbackId = callbacks:add("crashed", function()
				Main.ExitSafely(true)
				MGBA.removeActiveRunCallbacks()
			end)
		end

		if emu == nil then
			print("> Waiting for a game ROM to be loaded... (mGBA Emulator -> File -> Load ROM...)")
			return
		else
			MGBA.setupActiveRunCallbacks()
		end
	end

	-- Verify that at least one of the Tracker files on the filesystem are accessible (no diacritics/accented characters in the absolute path to the file)
	local verificationPath = FileManager.prependDir(FileManager.Files.ADDRESS_OVERRIDES)
	if not FileManager.fileExists(verificationPath) then
		Main.DisplayError("The Tracker cannot access its files: Issue with folder's location.\n\nCheck that there are no diacritics/accented characters in the full folder path to your Tracker folder. For example: é ñ ü")
		print("> [ERROR] Unable to access file path to:")
		print(string.format("> %s", verificationPath))
		return
	end

	Memory.initialize()
	GameSettings.initialize()
	Resources.autoDetectForeignLanguage()

	-- If the loaded game is unsupported, remove the Tracker padding but continue to let the game play.
	if GameSettings.gamename == nil or GameSettings.gamename == "Unsupported Game" then
		print("> Unsupported Game detected, please load a supported game ROM")
		print("> Check the README.txt file in the tracker folder for supported games")
		if Main.IsOnBizhawk() then
			client.SetGameExtraPadding(0, 0, 0, 0)
		end
		return
	end

	-- After a game is successfully loaded, then initialize the remaining Tracker files
	FileManager.setupErrorLog()
	Main.ReadAttemptsCount() -- re-check attempts count if different game is loaded
	FileManager.executeEachFile("initialize") -- initialize all tracker files
	CustomCode.startup()
	CustomCode.checkForRomHacks()
	Main.tempQuickloadFiles = nil -- From now on, quickload files should be re-checked

	-- Final garbage collection prior to game loops beginning
	collectgarbage()

	Main.CrashReport = CrashRecoveryScreen.readCrashReport()
	-- After crash report is read in, establish a new crash report; treat as "crashed" until emulator safely exits
	CrashRecoveryScreen.logCrashReport(true)

	if Main.IsOnBizhawk() then
		event.onexit(Program.HandleExit, "HandleExit")
		event.onconsoleclose(function() Main.ExitSafely(false) end, "SafelyCloseWithoutCrash")

		-- Bizhawk 2.9+ doesn't properly refocus onto the emulator window after Quickload
		if Options["Refocus emulator after load"] and Main.emulator ~= Main.EMU.BIZHAWK28 and not Drawing.AnimatedPokemon:isVisible() then
			Program.focusBizhawkWindow()
		end

		Main.AfterStartupScreenRedirect()
		Main.hasRunOnce = true
		Program.hasRunOnce = true

		-- Allow emulation frame after frame until a new seed is quickloaded or a tracker update is requested
		while not (Main.loadNextSeed or Main.updateRequested or Main.forceRestart or Main.loadDifferentRom) do
			xpcall(function() Program.mainLoop() end, FileManager.logError)
			Main.frameAdvance()
		end

		if Main.loadNextSeed then
			Main.LoadNextRom()
		elseif Main.updateRequested then
			UpdateScreen.performUpdate()
		elseif Main.forceRestart then
			Main.ExitSafely(false)
			IronmonTracker.startTracker()
		elseif Main.loadDifferentRom then
			Main.ExitSafely(false)
			Main.LoadRom(Main.loadDifferentRom)
			IronmonTracker.startTracker()
		end
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
			emu.frameadvance()
		end
	else
		Main.emulator = Main.EMU.MGBA
		Main.supportsSpecialChars = true
		frameAdvanceFunc = function()
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
	if client == nil or client.getversion == nil then return Main.EMU.BIZHAWK_OLD end

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
			local err1 = string.format("Unable to load a Tracker code file: %s", fileManagerPath)
			local err2 = "Make sure all of the Tracker's code files are still together."
			print("> " .. err1)
			print("> " .. err2)
			Main.DisplayError(err1 .. "\n\n" .. err2)
			return false
		end
	end
	io.close(fileManagerFile)

	dofile(fileManagerPath)
	FileManager.setupWorkingDirectory()

	-- Confirm the working directory was setup properly. Currently a necessary check for accented characters in Windows username.
	if not FileManager.fileExists(FileManager.Files.TRACKER_CORE) then
		local err1 = "Error locating Tracker files. Can't find path:"
		local err2 = FileManager.dir or ""
		print("> " .. err1)
		print("> " .. err2)
		local url = "https://github.com/besteon/Ironmon-Tracker/wiki/FAQ-&-Troubleshooting#folderpermission-issues"
		print(string.format("More Info: %s", url))
		Main.DisplayError(err1 .. "\n\n" .. err2, "More Info", function()
			local result = os.execute(string.format('start "" "%s"', url)) -- Windows
			if result ~= true and result ~= 0 then -- Failed to execute
				result = os.execute(string.format('open "%s"', url)) -- Mac OSX
				if result ~= true and result ~= 0 then -- Failed to execute
					result = os.execute(string.format('xdg-open "%s"', url)) -- Linux
				end
			end
		end)
		return false
	end

	return true
end

---Displays a given error message in a pop-up dialogue box
---@param errMessage string
---@param moreInfoBtnLabel string? Optional label for a "More Info" button
---@param moreInfoFunc function? Optional function to execute for "More Info" button
---@return number? formId The id of the form handle that is created
function Main.DisplayError(errMessage, moreInfoBtnLabel, moreInfoFunc)
	if not Main.IsOnBizhawk() then return nil end -- Only Bizhawk allows popup form windows

	client.pause()
	local formTitle = string.format("[v%s] Woops, there's been an issue!", Main.TrackerVersion)
	-- Create the form directly through Bizhawk and not ExternalUI, as it's possible that UI has not been loaded yet
	local form = forms.newform(400, 150, formTitle, function() client.unpause() end)
	local actualLocation = client.transformPoint(100, 50)
	forms.setproperty(form, "Left", client.xpos() + actualLocation['x'] )
	forms.setproperty(form, "Top", client.ypos() + actualLocation['y'] + 64) -- so we are below the ribbon menu

	forms.label(form, errMessage or "", 18, 10, 350, 65)
	forms.button(form, "Close", function()
		client.unpause()
		forms.destroy(form)
	end, 155, 80)

	-- Optional additional info button and event function
	if type(moreInfoFunc) == "function" then
		forms.button(form, moreInfoBtnLabel or "(?)", moreInfoFunc, 20, 80, 110, 22)
	end
	return form
end

function Main.AfterStartupScreenRedirect()
	if not Main.IsOnBizhawk() then
		return
	end

	if CrashRecoveryScreen.isEnabled() and Main.CrashReport and Main.CrashReport.crashedOccurred then
		CrashRecoveryScreen.previousScreen = Program.currentScreen
		Program.changeScreenView(CrashRecoveryScreen)
		return
	end

	if Main.Version.showReleaseNotes then
		Program.openOverlayScreen(UpdateScreen.Overlay)
		Main.Version.showReleaseNotes = false
		UpdateScreen.refreshButtons()
		Main.SaveSettings(true)
	end
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

	-- Only notify about updates once per day. Note: 1st run of bizhawk results in date being an integer not a string
	if forcedCheck or tostring(todaysDate) ~= tostring(Main.Version.dateChecked) then
		-- Track that an update was checked today, so no additional api calls are performed today
		Main.Version.dateChecked = todaysDate

		Utils.tempDisableBizhawkSound()

		local updatecheckCommand = string.format('curl "%s" --ssl-no-revoke', FileManager.Urls.VERSION)
		local success, fileLines = FileManager.tryOsExecute(updatecheckCommand)
		if success then
			local response = table.concat(fileLines, "\n")

			if response then
				Main.updateReleaseNotes(response)
			end

			-- Get version number formatted as [major].[minor].[patch]
			local major, minor, patch = string.match(response or "", '"tag_name":%s+"%w+(%d+)%.(%d+)%.(%d+)"')
			major = major or Main.Version.major
			minor = minor or Main.Version.minor
			patch = patch or Main.Version.patch

			local latestReleasedVersion = string.format("%s.%s.%s", major, minor, patch)

			-- Ignore patch numbers when checking to notify for a new release
			local newVersionAvailable = not Main.isOnLatestVersion(string.format("%s.%s.0", major, minor))

			-- Only notify when a release comes out that is different than the last recorded newest release
			local shouldNotify = Main.Version.latestAvailable ~= latestReleasedVersion

			-- Determine if a major version update is available and notify the user accordingly
			if newVersionAvailable and shouldNotify then
				Main.Version.showUpdate = true
			end

			-- Track the latest available version
			Main.Version.latestAvailable = latestReleasedVersion
		end

		Utils.tempEnableBizhawkSound()
	end

	Main.SaveSettings(true)
end

-- If not release notes have been retrieved yet (update check was skipped), then get those and parse them
-- Searches a response body for the "# Release Notes" area, and gets a list of changes
function Main.updateReleaseNotes(response)
	if not response then
		Utils.tempDisableBizhawkSound()
		local updatecheckCommand = string.format('curl "%s" --ssl-no-revoke', FileManager.Urls.VERSION)
		local success, fileLines = FileManager.tryOsExecute(updatecheckCommand)
		if success then
			response = table.concat(fileLines, "\n")
		end
		Utils.tempEnableBizhawkSound()
	end

	-- Parse the release notes
	Main.Version.releaseNotes = {}

	-- The body of the release post is contained between 'body' and 'mentions_count'
	local body = string.match(response or "", '"body":%s+"(.+)".-"mentions_count"')
	if body == nil then
		return
	end
	body = Utils.formatSpecialCharacters(body)

	local formatInput = function(str)
		-- Remove hyperlinks, format: [text](url) -> [text]
		str = str:gsub("%[([^%]]-)%]%(.-%)", "%1")
		-- Remove bold, format: **text** -> text
		str = str:gsub("%*%*(.-)%*%*", "%1")
		-- Fix double-quotes, format: \"text\" -> "text"
		str = str:gsub('\\"(.-)\\"', '"%1"')
		return str
	end

	local notesFound = false
	for line in string.gmatch(body .. '\\r\\n', '(.-)\\r\\n') do
		if notesFound then
			-- Include all release notes up until the mention of "version changelog"
			if line:lower():find("version.changelog") then -- . being a wild card match
				break
			end
			table.insert(Main.Version.releaseNotes, formatInput(line))
		elseif line:lower():find("# release notes") then
			notesFound = true
		end
	end
end

--- Checks the current version of the Tracker against the version of the latest release.
--- @param versionToCheck string? (optional) Version number to check the current tracker version against.
--- @return boolean isOnLatestVersion Returns true if current tracker version is newer/equal to the version to check.
function Main.isOnLatestVersion(versionToCheck)
	versionToCheck = versionToCheck or Main.Version.latestAvailable
	-- If versionToCheck is not newer than the current version, then current version is the latest version
	return not Utils.isNewerVersion(versionToCheck, Main.TrackerVersion)
end

--- Performs any final processes before emulator closes or restarts
---@param crashed boolean|nil (Optional) If true, log that a crash occurred; for next Tracker startup
function Main.ExitSafely(crashed)
	Network.closeConnections()
	CrashRecoveryScreen.logCrashReport(crashed == true)
	GachaMonFileManager.trySaveCollectionOnClose()
end

---Loads a ROM file into the emulator
---@param filepath string
---@return boolean success
function Main.LoadRom(filepath)
	if (filepath or "") == "" then
		return false
	end

	-- Always save a backup save-state for the current rom, just in case the ROM load was an accident
	local backupFolder = FileManager.getPathOverride("Backup Saves") or FileManager.prependDir(FileManager.Folders.BackupSaves, true)
	local backupFilename = string.format("%s %s %s", GameSettings.versioncolor or "", FileManager.PostFixes.PREVIOUSATTEMPT, FileManager.PostFixes.BACKUPSAVE)
	local backupFilepath = backupFolder .. backupFilename

	Tracker.resetData()

	if Main.IsOnBizhawk() then
		savestate.save(backupFilepath .. FileManager.Extensions.BIZHAWK_SAVESTATE, true) -- true: suppresses the on-screen display message
		GameOverScreen.clearTempSaveStates()
		TimeMachineScreen.cleanupOldRestorePoints(true)
		if Main.emulator == Main.EMU.BIZHAWK28 then
			-- Bizhawk 2.8 requires closing the rom before opening a new one
			client.closerom()
		end
		client.openrom(filepath)
		return true
	else
		---@diagnostic disable-next-line: undefined-global
		emu:saveStateFile(backupFilepath .. FileManager.Extensions.MGBA_SAVESTATE, C.SAVESTATE.ALL)
		local success = emu:loadFile(filepath)
		if success then
			MGBA.hasPrintedInstructions = false
			emu:reset()
		end
		return success
	end
end

function Main.LoadNextRom()
	Main.loadNextSeed = false
	Program.GameTimer:reset()

	Utils.tempDisableBizhawkSound()

	if Main.IsOnBizhawk() then
		Drawing.clearImageCache()
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
		print("> ERROR: No New Run method has been chosen yet.")
		Main.DisplayError("No New Run method has been chosen yet.\n\nEnable this at: Tracker Settings (gear icon) -> New Run")
	end

	Main.ExitSafely(false)

	if nextRomInfo ~= nil then
		Main.currentSeed = Main.currentSeed + 1
		Main.WriteAttemptsCountToFile(nextRomInfo.attemptsFilePath)
		QuickloadScreen.afterNewRunProfileCheckup(nextRomInfo.filePath)
		Tracker.clearTrackerNotesAndFile()

		local success = Main.LoadRom(nextRomInfo.filePath)
		if success then
			if Options["Use premade ROMs"] then
				print(string.format('> Loading next ROM: %s', nextRomInfo.fileName or "N/A"))
			end
			if not Main.IsOnBizhawk() then
				-- MGBA is ready to restart, no other code needs to run
				return
			end
		else
			print(string.format('> ERROR: Unable to load next ROM: %s', nextRomInfo.fileName or "N/A"))
		end
	elseif Options["Use premade ROMs"] or Options["Generate ROM each time"] then
		local quickloadVerb = Utils.inlineIf(Options["Use premade ROMs"], "find", "create")
		print(string.format("> Unable to load next ROM; couldn't %s one.", quickloadVerb))
	end

	Utils.tempEnableBizhawkSound()

	Main.Run()
end

function Main.GetNextRomFromFolder()
	print("> Attempting to load next ROM in sequence.")

	local nextRomName, nextRomPath = Main.GetNextBizhawkRomInfoLegacy()
	local quickloadFiles
	if nextRomName == nil or nextRomPath == nil then
		quickloadFiles = Main.GetQuickloadFiles()
	else
		quickloadFiles = {}
	end

	-- Check if any quickload information is available at all
	if nextRomName == nil and nextRomPath == nil and #quickloadFiles.romList == 0 then
		print('> ERROR: New Run "ROMs Folder" setting is incorrect, or ROM files are missing from the quickload folder.')
		Main.DisplayError('New Run "ROMs Folder" setting is incorrect, or ROM files are missing from the quickload folder.\n\nFix this at: Tracker Settings (gear icon) -> New Run')
		return nil
	end

	-- If the legacy next rom method worked, use that. Otherwise, lookup info by current attempt count
	if nextRomName == nil then
		local nextSeed = Main.currentSeed + 1
		for _, filename in ipairs(quickloadFiles.romList) do
			local seedNumberText = string.match(filename, '[0-9]+')
			if seedNumberText ~= nil then
				local seedNumber = tonumber(seedNumberText)
				if seedNumber ~= nil and seedNumber == nextSeed then
					nextRomName = filename
					break
				end
			end
		end
	end
	if nextRomPath == nil and quickloadFiles.quickloadPath ~= nil then
		nextRomPath = quickloadFiles.quickloadPath .. (nextRomName or "")
	end

	if nextRomName == nil or not FileManager.fileExists(nextRomPath) then
		nextRomName = nextRomName or GameSettings.getRomName() .. FileManager.Extensions.GBA_ROM
		print(string.format("> ERROR: Unable to find next ROM to load: %s", nextRomName))
		Main.DisplayError(string.format("Unable to find next ROM to load: %s", nextRomName) .. "\n\nMake sure your ROMs are numbered sequentially and the ROMs folder is correct.")
		return nil
	end

	-- The Attempts filename for premade roms folders is based on the prefix of the rom: e.g. "FireRedKaizo" from "FireRedKaizo42.gba"
	local romprefix = string.match(nextRomName, '[^0-9]+') or ""
	local attemptsFileName = string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	local attemptsFolder = FileManager.getPathOverride("Attempt Counts") or FileManager.dir

	return {
		fileName = nextRomName,
		filePath = nextRomPath,
		attemptsFilePath = attemptsFolder .. attemptsFileName,
	}
end

function Main.GenerateNextRom()
	local files = Main.GetQuickloadFiles()

	if #files.jarList == 0 or #files.settingsList == 0 or #files.romList == 0 then
		print("> ERROR: Files missing that are required for New Run to generate a new ROM.")
		Main.DisplayError("Files missing that are required for New Run to generate a new ROM.\n\nFix these at: Tracker Settings (gear icon) -> New Run")
		return nil
	elseif #files.jarList > 1 or #files.settingsList > 1 or #files.romList > 1 then
		local msg1 = string.format("ERROR: Too many GBA/JAR/RNQS files found in the quickload folder.")
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
	local settingsFileName = FileManager.extractFileNameFromPath(files.settingsList[1])
	local attemptsFileName = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	local attemptsFolder = FileManager.getPathOverride("Attempt Counts") or FileManager.dir

	local nextRomName = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
	local nextRomFolder = FileManager.getPathOverride("ROMs and Logs") or FileManager.dir
	local nextRomPath = nextRomFolder .. nextRomName

	local previousRomName = Main.SaveCurrentRom(nextRomName)

	-- mGBA only, need to unload current ROM but loading another temp ROM
	if previousRomName ~= nil and not Main.IsOnBizhawk() then
		emu:loadFile(nextRomFolder .. previousRomName)
	end

	local javaPath = Options.PATHS["Java Path"]
	if Utils.isNilOrEmpty(javaPath) then
		javaPath = "java" -- Default for most operating systems
	end

	local javacommand = string.format(
		'%s -Xmx4608M -jar "%s" cli -s "%s" -i "%s" -o "%s" -l',
		javaPath,
		jarPath,
		settingsPath,
		romPath,
		nextRomPath
	)

	local errorFolderpath = FileManager.getPathOverride("Randomizer Error Log") or FileManager.dir
	local errorLogFilepath = errorFolderpath .. FileManager.Files.RANDOMIZER_ERROR_LOG
	local success, fileLines = FileManager.tryOsExecute(javacommand, errorLogFilepath)

	if success then
		local output = table.concat(fileLines, "\n")
		-- It's possible this message changes in the future?
		---@diagnostic disable-next-line: cast-local-type
		success = (output:find("Randomized successfully!", 1, true) ~= nil)
		if not success and not Utils.isNilOrEmpty(output) then -- only print if something went wrong
			print("> ERROR: " .. output)
		end
	end

	-- If something went wrong and the ROM wasn't generated to the ROM path
	if not success or not FileManager.fileExists(nextRomPath) then
		local output = table.concat(FileManager.readLinesFromFile(errorLogFilepath), "\n")
		local missingJava = Utils.containsText(output, "'java' is not recognized", true)
		local missing64bit = Utils.containsText(output, "Invalid maximum heap size", true)
		local err1
		local moreInfoLabel, moreinfoUrl
		if missingJava then
			err1 = string.format('ERROR: Java not installed. Please install "Java 64-bit Offline."')
			moreInfoLabel = "Get Java"
			moreinfoUrl = "https://www.java.com/en/download/manual.jsp"
		elseif missing64bit then
			err1 = string.format('ERROR: Wrong Java installed. Please install "Java 64-bit Offline."')
			moreInfoLabel = "Get Java"
			moreinfoUrl = "https://www.java.com/en/download/manual.jsp"
		else
			err1 = string.format('ERROR: For more information, open the "%s" found in your Tracker folder.', FileManager.Files.RANDOMIZER_ERROR_LOG)
			moreInfoLabel = "View Error Log"
			moreinfoUrl = errorFolderpath .. FileManager.Files.RANDOMIZER_ERROR_LOG
		end
		local err2 = "~~~ The Randomizer program failed to generate a ROM ~~~"
		print("> " .. err1)
		print("> " .. err2)
		Main.DisplayError(err1 .. "\n\n" .. err2, moreInfoLabel, function() Utils.openBrowserWindow(moreinfoUrl) end)
		return nil
	end

	return {
		fileName = nextRomName,
		filePath = nextRomPath,
		attemptsFilePath = attemptsFolder .. attemptsFileName,
	}
end

-- Returns a table containing [jars, settings, roms, quickloadPath] either from Settings.ini or from the Quickload folder
function Main.GetQuickloadFiles()
	-- Each item in the lists is an absolute file path
	local fileLists = {
		jarList = {},
		settingsList = {},
		romList = {},
		quickloadPath = nil,
	}

	-- If all three supplied exists, shortcut to using those over anything else
	if Options["Generate ROM each time"] and FileManager.fileExists(Options.FILES["Randomizer JAR"]) and FileManager.fileExists(Options.FILES["Settings File"]) and FileManager.fileExists(Options.FILES["Source ROM"]) then
		table.insert(fileLists.jarList, Options.FILES["Randomizer JAR"])
		table.insert(fileLists.settingsList, Options.FILES["Settings File"])
		table.insert(fileLists.romList, Options.FILES["Source ROM"])
		return fileLists
	end

	-- Search the quickload folder for compatible files used for quickload
	if Options["Use premade ROMs"] and not Utils.isNilOrEmpty(Options.FILES["ROMs Folder"]) then
		-- First make sure the ROMs Folder ends with a slash
		if Options.FILES["ROMs Folder"]:sub(-1) ~= FileManager.slash then
			Options.FILES["ROMs Folder"] = Options.FILES["ROMs Folder"] .. FileManager.slash
		end
		fileLists.quickloadPath = Options.FILES["ROMs Folder"] -- Assumes absolute path
	else
		fileLists.quickloadPath = FileManager.prependDir(FileManager.Folders.Quickload, true)
	end

	local listsByExtension = {
		["jar"] = fileLists.jarList,
		["rnqs"] = fileLists.settingsList,
		["gba"] = fileLists.romList,
	}

	local quickloadFileNames = FileManager.getFilesFromDirectory(fileLists.quickloadPath)
	for _, filename in pairs(quickloadFileNames) do
		local ext = FileManager.extractFileExtensionFromPath(filename) or ""
		if listsByExtension[ext] ~= nil then
			table.insert(listsByExtension[ext], filename)
		end
	end

	-- If some files were missing from the folder, check again from Options if they were partially added in from Settings.ini
	if Options["Generate ROM each time"] then
		if #fileLists.jarList == 0 and FileManager.fileExists(Options.FILES["Randomizer JAR"]) then
			table.insert(fileLists.jarList, Options.FILES["Randomizer JAR"])
		end
		if #fileLists.settingsList == 0 and FileManager.fileExists(Options.FILES["Settings File"]) then
			table.insert(fileLists.settingsList, Options.FILES["Settings File"])
		end
		if #fileLists.romList == 0 and FileManager.fileExists(Options.FILES["Source ROM"]) then
			table.insert(fileLists.romList, Options.FILES["Source ROM"])
		end
	end

	return fileLists
end

-- Returns two results for the next rom: name and filepath. This is the legacy method prior to mGBA changes.
function Main.GetNextBizhawkRomInfoLegacy()
	if not Main.IsOnBizhawk() or Utils.isNilOrEmpty(Options.FILES["ROMs Folder"]) then
		return nil
	end

	local romsFolderPath = Options.FILES["ROMs Folder"]
	if romsFolderPath:sub(-1) ~= FileManager.slash then
		romsFolderPath = romsFolderPath .. FileManager.slash
	end

	-- Split the ROM name into its prefix and numerical values
	local currentRomName = GameSettings.getRomName()
	local currentRomPrefix = string.match(currentRomName, '[^0-9]+') or ""
	local currentRomNumber = string.match(currentRomName, '[0-9]+') or "0"

	-- Increment to the next ROM and determine its full file path
	local nextRomName = string.format(currentRomPrefix .. "%0" .. string.len(currentRomNumber) .. "d", tonumber(currentRomNumber) + 1)
	local nextRomPath = romsFolderPath .. nextRomName .. FileManager.Extensions.GBA_ROM

	-- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
	if not FileManager.fileExists(nextRomPath) then
		-- File doesn't exist, try again with underscores instead of spaces (awkward Bizhawk issue)
		nextRomName = nextRomName:gsub(" ", "_")
		nextRomPath = romsFolderPath .. nextRomName .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(nextRomPath) then
			-- This means there doesn't exist a ROM file with spaces or underscores
			return nil
		end
	end

	return nextRomName, nextRomPath
end

-- Returns the smallest seed number from among files found in the quickload folder
function Main.FindSmallestSeedFromQuickloadFiles()
	local smallestSeed
	local quickloadFiles = Main.tempQuickloadFiles or Main.GetQuickloadFiles()
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

	local folderpath = FileManager.getPathOverride("ROMs and Logs") or FileManager.dir

	local filenameCopy = filename:gsub(FileManager.PostFixes.AUTORANDOMIZED, FileManager.PostFixes.PREVIOUSATTEMPT)
	local filepath = folderpath .. filename
	local filepathCopy = folderpath .. filenameCopy

	-- If the copy succeeds, also copy the matching log file
	if FileManager.CopyFile(filepath, filepathCopy, "overwrite") then
		local logFilename = filename .. FileManager.Extensions.RANDOMIZER_LOGFILE
		local logFilenameCopy = filenameCopy .. FileManager.Extensions.RANDOMIZER_LOGFILE
		local logpath = folderpath .. logFilename
		local logpathCopy = folderpath .. logFilenameCopy

		FileManager.CopyFile(logpath, logpathCopy, "overwrite")

		return filenameCopy
	end

	return nil
end

--- Attempts to find an attempts file based off of the Quickload settings file, then off of the currently loaded ROM name
--- @param forceUseSettingsFile boolean? Force return of filepath of an attempts file to be created from the Quickload settings file (default: false)
--- @return string attemptsFilePath Filepath to an attempts file
function Main.GetAttemptsFile(forceUseSettingsFile)
	forceUseSettingsFile = forceUseSettingsFile or false

	local attemptsFolder = FileManager.getPathOverride("Attempt Counts") or FileManager.dir

	-- If temp quickload files are available, use those instead of spending resources to look them up
	local quickloadFiles = Main.tempQuickloadFiles

	-- First, try using a filename based on the Quickload settings file name
	-- The case when using Quickload method: auto-generate a ROM
	local attemptsFileName, attemptsFilePath, settingsFileName
	if Options["Generate ROM each time"] and not Utils.isNilOrEmpty(Options.FILES["Settings File"]) then
		settingsFileName = FileManager.extractFileNameFromPath(Options.FILES["Settings File"])
	else
		quickloadFiles = quickloadFiles or Main.GetQuickloadFiles()
		if #quickloadFiles.settingsList > 0 then
			settingsFileName = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1])
		end
	end
	if settingsFileName ~= nil then
		attemptsFileName = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
		attemptsFilePath = FileManager.getPathIfExists(attemptsFolder .. attemptsFileName)

		-- Return early if an attemptsFilePath has been found
		if attemptsFilePath ~= nil then
			return attemptsFilePath
		elseif forceUseSettingsFile then
			-- Force return a filepath to an attempts file to be created based off settings file
			return attemptsFolder .. attemptsFileName
		end
	end

	-- Otherwise, check if an attempts file exists based on the ROM file name (w/o numbers)
	local quickloadRomName
	local romsFolder = FileManager.tryAppendSlash(Options.FILES["ROMs Folder"])

	-- Bizhawk can shortcut check this by getting the loaded rom name, then checking if a file exists with that name in the Roms Folder
	if Main.IsOnBizhawk() and not Utils.isNilOrEmpty(romsFolder) then
		local loadedRomName = GameSettings.getRomName()
		if FileManager.fileExists(romsFolder .. loadedRomName .. FileManager.Extensions.GBA_ROM) then
			quickloadRomName = loadedRomName
		end
	end
	-- For all other cases, retrieve the file list from the Roms Folder and use a rom in there to check attempts count
	if Utils.isNilOrEmpty(quickloadRomName) then
		quickloadFiles = quickloadFiles or Main.GetQuickloadFiles()
		quickloadRomName = quickloadFiles.romList[1] or ""
	end

	local romprefix = string.match(quickloadRomName, '[^0-9]+') or "" -- remove numbers
	romprefix = romprefix:gsub(" " .. FileManager.PostFixes.AUTORANDOMIZED, "") -- remove quickload post-fix

	attemptsFileName = string.format("%s %s%s", romprefix, FileManager.PostFixes.ATTEMPTS_FILE, FileManager.Extensions.ATTEMPTS)
	attemptsFilePath = attemptsFolder .. attemptsFileName

	return attemptsFilePath
end

--- Determines what attempts # the play session is on, either from pre-existing file or from Bizhawk's ROM Name.
--- Resulting attempts # is stored in Main.currentSeed
--- @param forceUseSettingsFile boolean? Force creation of new attempts # for the current Quickload settings file (default: false)
function Main.ReadAttemptsCount(forceUseSettingsFile)
	forceUseSettingsFile = forceUseSettingsFile or false

	local filepath = Main.GetAttemptsFile(forceUseSettingsFile)
	local attemptsRead = io.open(filepath, "r")

	-- First check if a matching "attempts file" already exists, if so read from that
	if attemptsRead ~= nil then
		local attemptsText = attemptsRead:read("*a")
		attemptsRead:close()
		if attemptsText ~= nil and tonumber(attemptsText) ~= nil then
			Main.currentSeed = tonumber(attemptsText)
		end
	elseif Options["Use premade ROMs"] then
		if Main.IsOnBizhawk() then -- mostly for Bizhawk
			local romname = GameSettings.getRomName()
			local romnumber = string.match(romname, '[0-9]+') or "1"
			Main.currentSeed = tonumber(romnumber)
		elseif Utils.isNilOrEmpty(Options.FILES["ROMs Folder"]) then -- mostly for mGBA
			local smallestSeedNumber = Main.FindSmallestSeedFromQuickloadFiles()
			if smallestSeedNumber ~= -1 then
				Main.currentSeed = smallestSeedNumber
			end
		end
	elseif Options["Generate ROM each time"] and forceUseSettingsFile then
		-- Set a new attempts count for newly-set Settings file
		Main.currentSeed = 0 -- 0 so that first quickload results in attempt 1
	else
		-- Otherwise, leave the attempts count as-is
	end
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
		if settings.config.LatestAvailableVersion ~= nil then
			Main.Version.latestAvailable = settings.config.LatestAvailableVersion
		end
		if settings.config.DateLastChecked ~= nil then
			Main.Version.dateChecked = settings.config.DateLastChecked
		end
		if settings.config.ShowUpdateNotification ~= nil then
			Main.Version.showUpdate = settings.config.ShowUpdateNotification
		end
		if settings.config.ShowReleaseNotes ~= nil then
			Main.Version.showReleaseNotes = settings.config.ShowReleaseNotes
		end

		for configKey, _ in pairs(Options.FILES) do
			local configValue = settings.config[string.gsub(configKey, " ", "_")]
			if configValue ~= nil then
				Options.FILES[configKey] = configValue
			end
		end
		for configKey, _ in pairs(Options.PATHS) do
			local configValue = settings.config[string.gsub(configKey, " ", "_")]
			if configValue ~= nil then
				Options.PATHS[configKey] = configValue
			end
		end
	end

	-- [TRACKER]
	if settings.tracker ~= nil then
		-- First, check for deprecated options
		if settings.tracker["Disable_mainscreen_carousel"] ~= nil then
			Options["Allow carousel rotation"] = not settings.tracker["Disable_mainscreen_carousel"]
			settings.tracker["Disable_mainscreen_carousel"] = nil
		end
		for _, optionKey in ipairs(Constants.OrderedLists.OPTIONS) do
			local optionValue = settings.tracker[string.gsub(optionKey, " ", "_")]
			if optionValue ~= nil then
				Options[optionKey] = optionValue
			end
		end
	end
	UpdateOrInstall.Dev.enabled = (Options["Dev branch updates"] == true)

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

	-- [NETWORK]
	if settings.network ~= nil then
		for key, _ in pairs(Network.Options or {}) do
			local optionValue = settings.network[string.gsub(key, " ", "_")]
			if optionValue ~= nil then
				Network.Options[key] = optionValue
			end
		end
	end

	-- [OVERRIDES]
	if settings.overrides ~= nil then
		for key, _ in pairs(Options.Overrides or {}) do
			local optionValue = settings.overrides[string.gsub(key, " ", "_")]
			if optionValue ~= nil then
				Options.Overrides[key] = optionValue
			end
		end
	end

	-- [EXTENSIONS]
	CustomCode.ExtensionLibrary = {}
	if settings.extensions ~= nil then
		for extKey, extValue in pairs(settings.extensions) do
			if extValue ~= nil then
				if CustomCode.ExtensionLibrary[extKey] == nil then
					CustomCode.ExtensionLibrary[extKey] = {
						isEnabled = extValue,
						isLoaded = false,
					}
				else
					CustomCode.ExtensionLibrary[extKey].isEnabled = extValue
				end
			end
		end
	end

	-- [EXTCONFIG]
	if settings.extconfig ~= nil then
		for key, val in pairs(settings.extconfig) do
			if val ~= nil then
				Main.SetMetaSetting("extconfig", key, val)
			end
		end
	end

	return true
end

-- Saves the user settings on to disk
function Main.SaveSettings(forced)
	-- Don't bother saving to a file if nothing has changed
	if not forced and not Theme.settingsUpdated then
		return
	end

	local settings = Main.MetaSettings or {}
	settings.config = settings.config or {}
	settings.tracker = settings.tracker or {}
	settings.controls = settings.controls or {}
	settings.theme = settings.theme or {}
	settings.network = settings.network or {}
	settings.overrides = settings.overrides or {}
	settings.extensions = settings.extensions or {}

	-- [CONFIG]
	settings.config.LatestAvailableVersion = Main.Version.latestAvailable
	settings.config.DateLastChecked = Main.Version.dateChecked
	settings.config.ShowUpdateNotification = Main.Version.showUpdate
	settings.config.ShowReleaseNotes = Main.Version.showReleaseNotes

	for configKey, _ in pairs(Options.FILES) do
		local encodedKey = string.gsub(configKey, " ", "_")
		settings.config[encodedKey] = Options.FILES[configKey]
	end
	for configKey, _ in pairs(Options.PATHS) do
		local encodedKey = string.gsub(configKey, " ", "_")
		settings.config[encodedKey] = Options.PATHS[configKey]
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

	-- [NETWORK]
	for key, val in pairs(Network.Options or {}) do
		local encodedKey = string.gsub(key, " ", "_")
		settings.network[encodedKey] = val
	end

	-- [OVERRIDES]
	for key, val in pairs(Options.Overrides or {}) do
		local encodedKey = string.gsub(key, " ", "_")
		settings.overrides[encodedKey] = val
	end

	-- [EXTENSIONS]
	for extKey, extension in pairs(CustomCode.ExtensionLibrary) do
		settings.extensions[extKey] = extension.isEnabled or false
	end

	-- [EXTCONFIG]
	-- Implied to save all things in settings.extconfig

	Inifile.save(FileManager.prependDir(FileManager.Files.SETTINGS), settings)
	Theme.settingsUpdated = false
end

function Main.SetMetaSetting(section, key, value)
	if Utils.isNilOrEmpty(section) or Utils.isNilOrEmpty(key) or value == nil then return end
	if Main.MetaSettings[section] == nil then
		Main.MetaSettings[section] = {}
	end
	Main.MetaSettings[section][key] = value
end

function Main.RemoveMetaSetting(section, key)
	if Utils.isNilOrEmpty(section) or Utils.isNilOrEmpty(key) then return end
	if Main.MetaSettings[section] ~= nil then
		Main.MetaSettings[section][key] = nil
	end
end

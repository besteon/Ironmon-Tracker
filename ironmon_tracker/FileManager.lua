FileManager = {}

-- Define file separator. Windows is \ and Linux is /
FileManager.slash = package.config:sub(1,1) or "\\"

FileManager.Folders = {
	TrackerCode = "ironmon_tracker",
	Custom = "extensions",
	Quickload = "quickload",
	SavedGames = "saved_games", -- needs to be created first to be used
	BackupSaves = "backup_saves", -- needs to be created first to be used
	DataCode = "data",
	Network = "network",
	ScreensCode = "screens",
	Languages = "Languages",
	RandomizerSettings = "RandomizerSettings",
	Images = "images",
	Trainers = "trainers",
	TrainersPortraits = "trainerPortraits",
	Badges = "badges",
	Icons = "icons",
	AnimatedPokemon = "pokemonAnimated",
}

FileManager.Files = {
	SETTINGS = "Settings.ini",
	THEME_PRESETS = "ThemePresets.txt",
	RANDOMIZER_ERROR_LOG = "RandomizerErrorLog.txt",
	TRACKER_CORE = "Ironmon-Tracker.lua",
	UPDATE_OR_INSTALL = "UpdateOrInstall.lua",
	REQUESTS_DATA = FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Network .. FileManager.slash .. "Requests.json",
	STREAMERBOT_CODE = FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Network .. FileManager.slash .. "StreamerbotCodeImport.txt",
	JSON_LIBRARY = FileManager.Folders.TrackerCode .. FileManager.slash .. "Json.lua",
	OSEXECUTE_OUTPUT = FileManager.Folders.TrackerCode .. FileManager.slash .. "osexecute-output.txt",
	ERROR_LOG = FileManager.Folders.TrackerCode .. FileManager.slash .. "errorlog.txt",
	CRASH_REPORT = FileManager.Folders.TrackerCode .. FileManager.slash .. "crashreport.txt",
	LanguageCode = {
		SpainData = "SpainData.lua",
		ItalyData = "ItalyData.lua",
		FranceData = "FranceData.lua",
		GermanyData = "GermanyData.lua",
		JapanData = "JapanData.lua",
	},
	Other = {
		REPEL = "repelUsage.png",
		ANIMATED_POKEMON = "AnimatedPokemon.gif",
	}
}

FileManager.PostFixes = {
	ATTEMPTS_FILE = "Attempts",
	AUTORANDOMIZED = "AutoRandomized",
	PREVIOUSATTEMPT = "PreviousAttempt",
	AUTOSAVE = "AutoSave",
	BACKUPSAVE = "BackupSave",
}

FileManager.Extensions = {
	GBA_ROM = ".gba",
	RANDOMIZER_LOGFILE = ".log",
	TRACKED_DATA = ".tdat",
	ATTEMPTS = ".txt",
	ANIMATED_POKEMON = ".gif",
	TRAINER = ".png",
	BADGE = ".png",
	BIZHAWK_SAVESTATE = ".State",
	MGBA_SAVESTATE = ".ss0", -- ".ss0" through ".ss9" are okay to use
	LUA_CODE = ".lua",
}

FileManager.Urls = {
	VERSION = "https://api.github.com/repos/besteon/Ironmon-Tracker/releases/latest",
	DOWNLOAD = "https://github.com/besteon/Ironmon-Tracker/releases/latest",
	WIKI = "https://github.com/besteon/Ironmon-Tracker/wiki",
	DISCUSSIONS = "https://github.com/besteon/Ironmon-Tracker/discussions/389", -- Discussion: "Help us translate the Ironmon Tracker"
	EXTENSIONS = "https://github.com/besteon/Ironmon-Tracker/wiki/Tracker-Add-ons#custom-code-extensions",
	STREAM_CONNECT = "https://github.com/besteon/Ironmon-Tracker/wiki/Stream-Connect-Guide",
}

-- All Lua code files used by the Tracker, loaded and initialized in the order listed
FileManager.LuaCode = {
	-- First set of core files
	{ name = "Inifile", filepath = "Inifile.lua", },
	{ name = "Resources", filepath = "Resources.lua", },
	{ name = "Constants", filepath = "Constants.lua", },
	{ name = "TrackerAPI", filepath = "TrackerAPI.lua", },
	{ name = "Utils", filepath = "Utils.lua", },
	{ name = "Memory", filepath = "Memory.lua", },
	{ name = "GameSettings", filepath = "GameSettings.lua", },
	-- Data files
	{ name = "PokemonData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "PokemonData.lua", },
	{ name = "PokemonRevoData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "PokemonRevoData.lua", },
	{ name = "MoveData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "MoveData.lua", },
	{ name = "AbilityData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "AbilityData.lua", },
	{ name = "MiscData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "MiscData.lua", },
	{ name = "RouteData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "RouteData.lua", },
	{ name = "DataHelper", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "DataHelper.lua", },
	{ name = "RandomizerLog", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "RandomizerLog.lua", },
	{ name = "TrainerData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "TrainerData.lua", },
	{ name = "SpriteData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "SpriteData.lua", },
	-- Second set of core files
	{ name = "Options", filepath = "Options.lua", },
	{ name = "Drawing", filepath = "Drawing.lua", },
	{ name = "Theme", filepath = "Theme.lua", },
	{ name = "ColorPicker", filepath = "ColorPicker.lua", },
	{ name = "Input", filepath = "Input.lua", },
	{ name = "Program", filepath = "Program.lua", },
	{ name = "Battle", filepath = "Battle.lua", },
	{ name = "Pickle", filepath = "Pickle.lua", },
	{ name = "Tracker", filepath = "Tracker.lua", },
	{ name = "MGBA", filepath = "MGBA.lua", },
	-- Network files
	{ name = "Network", filepath = FileManager.Folders.Network .. FileManager.slash .. "Network.lua", },
	{ name = "EventHandler", filepath = FileManager.Folders.Network .. FileManager.slash .. "EventHandler.lua", },
	{ name = "RequestHandler", filepath = FileManager.Folders.Network .. FileManager.slash .. "RequestHandler.lua", },
	-- Screen files
	{ name = "MGBADisplay", filepath = "MGBADisplay.lua", },
	{ name = "TrackerScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "TrackerScreen.lua", },
	{ name = "InfoScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "InfoScreen.lua", },
	{ name = "NavigationMenu", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "NavigationMenu.lua", },
	{ name = "StartupScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "StartupScreen.lua", },
	{ name = "UpdateScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "UpdateScreen.lua", },
	{ name = "SetupScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "SetupScreen.lua", },
	{ name = "ExtrasScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "ExtrasScreen.lua", },
	{ name = "QuickloadScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "QuickloadScreen.lua", },
	{ name = "GameOptionsScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "GameOptionsScreen.lua", },
	{ name = "TrackedDataScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "TrackedDataScreen.lua", },
	{ name = "LanguageScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LanguageScreen.lua", },
	{ name = "StatsScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "StatsScreen.lua", },
	{ name = "RandomEvosScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "RandomEvosScreen.lua", },
	{ name = "MoveHistoryScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "MoveHistoryScreen.lua", },
	{ name = "TypeDefensesScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "TypeDefensesScreen.lua", },
	{ name = "HealsInBagScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "HealsInBagScreen.lua", },
	{ name = "GameOverScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "GameOverScreen.lua", },
	{ name = "StreamerScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "StreamerScreen.lua", },
	{ name = "TimeMachineScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "TimeMachineScreen.lua", },
	{ name = "CustomExtensionsScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "CustomExtensionsScreen.lua", },
	{ name = "SingleExtensionScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "SingleExtensionScreen.lua", },
	{ name = "ViewLogWarningScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "ViewLogWarningScreen.lua", },
	{ name = "CrashRecoveryScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "CrashRecoveryScreen.lua"},
	{ name = "CoverageCalcScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "CoverageCalcScreen.lua"},
	{ name = "LogOverlay", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogOverlay.lua", },
	{ name = "LogTabPokemon", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabPokemon.lua", },
	{ name = "LogTabPokemonDetails", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabPokemonDetails.lua", },
	{ name = "LogTabTrainers", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabTrainers.lua", },
	{ name = "LogTabTrainerDetails", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabTrainerDetails.lua", },
	{ name = "LogTabRoutes", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabRoutes.lua", },
	{ name = "LogTabRouteDetails", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabRouteDetails.lua", },
	{ name = "LogTabTMs", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabTMs.lua", },
	{ name = "LogTabMisc", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogTabMisc.lua", },
	{ name = "TeamViewArea", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "TeamViewArea.lua", },
	{ name = "LogSearchScreen", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "LogSearchScreen.lua"},
	{ name = "StreamConnectOverlay", filepath = FileManager.Folders.ScreensCode .. FileManager.slash .. "StreamConnectOverlay.lua", },
	-- Miscellaneous files
	{ name = "CustomCode", filepath = "CustomCode.lua", },
}

-- Returns true if a file exists at its absolute file path; false otherwise
function FileManager.fileExists(filepath)
	return FileManager.getPathIfExists(filepath) ~= nil
end

function FileManager.folderExists(folderpath)
	if folderpath == nil then return false end
	if folderpath:sub(-1) ~= "/" and folderpath:sub(-1) ~= "\\" then
		folderpath = folderpath .. FileManager.slash
	end

	-- Hacky but simply way to check if a folder exists: try to rename it
	-- The "code" return value only exists in Lua 5.2+, but not required to use here
	local exists, err, code = os.rename(folderpath, folderpath)
	-- Code 13 = Permission denied, but it exists
	if exists or (not exists and code == 13) then
		return true
	end

	-- Otherwise check the absolute path of the file
	folderpath = FileManager.prependDir(folderpath)
	exists, err, code = os.rename(folderpath, folderpath)
	if exists or (not exists and code == 13) then
		return true
	end

	return false
end

-- Returns the path that allows opening a file at 'filepath', if one exists and it can be opened; otherwise, returns nil
---@return string|nil filepath
function FileManager.getPathIfExists(filepath)
	filepath = string.match(filepath or "", "^%s*(.-)%s*$") -- remove leading/trailing spaces

	-- Empty filepaths "" can be opened successfully on Linux, as directories are considered files
	if filepath == "" then return nil end

	local file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	-- Otherwise check the absolute path of the file
	filepath = FileManager.prependDir(filepath)
	file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	return nil
end

-- Returns the absolute file path using a local filename/path and the working directory of the Tracker
---@return string filepath
function FileManager.prependDir(filenameOrPath)
	return FileManager.dir .. (filenameOrPath or "")
end

-- An absolute path working directory is required for Bizhawk (Windows or Linux)
function FileManager.setupWorkingDirectory()
	FileManager.dir = IronmonTracker.workingDir or ""

	-- First check if the working directory has been looked up before
	local knownDirPath = FileManager.Folders.TrackerCode .. FileManager.slash .. "knownworkingdir.txt"
	local knownDirFile = io.open(knownDirPath, "r")
	-- If the file doesn't exist, try another path
	if knownDirFile == nil then
		knownDirPath = FileManager.dir .. knownDirPath
		knownDirFile = io.open(knownDirPath, "r")
	end

	-- If the working directory is known (used in the past), then load that instead of running an os execute
	if knownDirFile ~= nil then
		FileManager.dir = knownDirFile:read("*a") or ""
		knownDirFile:close()
		FileManager.dir = FileManager.dir:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
		-- Then verify that this saved working directory is correct and usable (user might have moved files/folders)
		if not FileManager.fileExists(FileManager.prependDir(FileManager.Files.TRACKER_CORE)) then
			FileManager.dir = ""
		end
	end

	-- Properly format the path
	local function formatPath(filepath)
		filepath = FileManager.formatPathForOS(filepath)
		if filepath:sub(-1) ~= FileManager.slash then
			filepath = filepath .. FileManager.slash
		end
		-- Linux Bizhawk 2.8 doesn't support popen or working dir absolute path
		if Main.emulator == Main.EMU.BIZHAWK28 and filepath == FileManager.slash then
			filepath = ""
		end
		return filepath
	end

	-- Otherwise, if no known working directory was found, look it up the hard way
	if knownDirFile == nil or FileManager.dir == "" then
		-- For Bizhawk, use luaconsole script list as a quick backup solution
		if Main.IsOnBizhawk() then
			local pathCheckFile = io.open(FileManager.prependDir(FileManager.Files.TRACKER_CORE), "r")
			if pathCheckFile then
				pathCheckFile:close()
			else
				local luaconsole = client.gettool("luaconsole")
				local luaImp = luaconsole and luaconsole.get_LuaImp()
				local scriptList = luaImp and luaImp.ScriptList or { Count = 0 }
				for i = 0, scriptList.Count - 1, 1 do
					local scriptPath = scriptList[i].Path or scriptList[i].path or ""
					local index = scriptPath:find(FileManager.Files.TRACKER_CORE, 1, true)
					if index then
						FileManager.dir = scriptPath:sub(1, index - 1)
						break
					end
				end
				FileManager.dir = formatPath(FileManager.dir)
			end
		end
		-- If still can't find the filepath, use a command to get it
		if FileManager.dir == "" then
			-- Windows: "cd", Linux: "pwd"
			local getDirCommand = FileManager.slash == "\\" and "cd" or "pwd"
			-- Bizhawk handles current working directory differently, this is the only way to get it
			local success, fileLines = FileManager.tryOsExecute(getDirCommand)
			if success and #fileLines > 0 and Main.IsOnBizhawk() and FileManager.dir == "" then
				FileManager.dir = fileLines[1]
			end
			FileManager.dir = formatPath(FileManager.dir)
		end

		-- Save known working directory to file to load for future startups
		if FileManager.dir ~= "" then
			knownDirFile = io.open(knownDirPath, "w")
			if knownDirFile then
				knownDirFile:write(FileManager.dir)
				knownDirFile:flush()
				knownDirFile:close()
			end
		end
	end

	-- Required so UpdateOrInstall works regardless of standalone execution
	IronmonTracker.workingDir = FileManager.dir
end

-- Attempts to execute the command, returning two results: success, outputTable
function FileManager.tryOsExecute(command, errorFile)
	local tempOutputFile = FileManager.prependDir(FileManager.Files.OSEXECUTE_OUTPUT)
	local commandWithOutput = string.format('%s >"%s"', command, tempOutputFile)
	if errorFile ~= nil then
		commandWithOutput = string.format('%s 2>"%s"', commandWithOutput, errorFile)
	end

	-- An attempted fix to allow non-english characters in paths; but this is only half of it, so it's incomplete.
	-- Leaving this here in case some more research is done to figure out how to work around this.
	-- local foreignCompatibleCommand = "@chcp 65001>nul && " .. commandWithOutput

	local result = os.execute(commandWithOutput)
	local success = (result == true or result == 0) -- 0 = success in some cases
	if not success then
		return success, {}
	end
	return success, FileManager.readLinesFromFile(tempOutputFile)
end

-- Currently unused, use FileManager.tryOsExecute instead.
-- Attempts to execute a popen command, returning two results: success, file. Remember to safely close the file (check for nil twice)
-- function FileManager.tryPOpen(command)
-- 	if command == nil then return false, command end
-- 	local function executeCommand() return io.popen(command) end
-- 	local success, ret, _ = xpcall(executeCommand, debug.traceback) -- 3rd return is error message
-- 	return (success and ret ~= nil), ret
-- end

-- Attempts to load a file as Lua code. Returns true if successful; false otherwise.
function FileManager.loadLuaFile(filename, silenceErrors)
	-- First try and load the file from the folder that contains most/all the Tracker lua code
	local filepath = FileManager.getPathIfExists(FileManager.Folders.TrackerCode .. FileManager.slash .. filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	end

	-- Otherwise, check if the file exists on the root Tracker folder (UpdateOrInstall.lua lives here)
	filepath = FileManager.getPathIfExists(filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	end

	if not silenceErrors then
		print("Unable to load " .. filename .. "\nMake sure all of the downloaded Tracker's files are still together.")
		Main.DisplayError("Unable to load " .. filename .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
	end

	return false
end

-- Executes 'functionName' for all code files loaded in the Tracker, except Main, FileManager, and UpdateOrInstall.
function FileManager.executeEachFile(functionName)
	local globalRef
	if Main.emulator == Main.EMU.BIZHAWK28 then
		globalRef = _G -- Lua 5.1 only
	else
		---@diagnostic disable-next-line: undefined-global
		globalRef = _ENV -- Lua 5.4
	end

	for _, luafile in ipairs(FileManager.LuaCode) do
		local luaObject = globalRef[luafile.name or ""] or {}
		if type(luaObject[functionName]) == "function" then
			luaObject[functionName]()
		end
	end
end

-- Returns a properly formatted path that contains only the correct path-separators based on the OS
function FileManager.formatPathForOS(path)
	path = path or ""
	if FileManager.slash == "/" then
		path = path:gsub("\\", "/")
	else
		path = path:gsub("/", "\\")
	end
	return path
end

-- Returns true if it creates the folder, false if it already exists (I think)
function FileManager.createFolder(folderpath)
	if folderpath == nil then return end
	local command
	if Main.OS == "Windows" then
		command = string.format('mkdir "%s"', folderpath)
	else
		command = string.format('mkdir -p "%s"', folderpath)
	end
	return FileManager.tryOsExecute(command)
end

-- Returns a list of file names found in a given folder
function FileManager.getFilesFromDirectory(folderpath)
	local files = {}

	-- Not supported on Linux Bizhawk 2.8, Lua 5.1
	if folderpath == nil or (Main.OS ~= "Windows" and Main.emulator == Main.EMU.BIZHAWK28) then
		return files
	end

	local scanDirCommand
	if Main.OS == "Windows" then
		scanDirCommand = string.format('dir "%s" /b', folderpath)
	else
		-- Note: "-A" removes "." and ".." from the listing
		scanDirCommand = string.format('ls -A "%s"', folderpath)
	end
	local success, fileLines = FileManager.tryOsExecute(scanDirCommand)
	if success then
		for _, filename in ipairs(fileLines) do
			table.insert(files, filename)
		end
	end

	return files
end

-- Erases the contents of the ERROR_LOG and adds a header for diagnostics
function FileManager.setupErrorLog()
	FileManager.ErrorsLogged = {}

	local file = io.open(FileManager.prependDir(FileManager.Files.ERROR_LOG), "w")
	if file ~= nil then
		-- Diagnostics information
		local version = string.format("Tracker Version: %s", Main.TrackerVersion or "N/A")
		local gamerom = string.format("Rom Name: %s", GameSettings.getRomName() or "N/A")
		local gamename = string.format("Game: %s", GameSettings.gamename or "N/A")
		local date = string.format("Date: %s", os.date())
		local divider = string.rep("-", 30)
		file:write(version .. "\n")
		file:write(gamerom .. "\n")
		file:write(gamename .. "\n")
		file:write(date .. "\n")
		file:write(divider .. "\n\n")

		file:flush()
		file:close()
	end
end

-- Logs a message to the ERROR_LOG file
function FileManager.logError(errorMessage)
	errorMessage = errorMessage or "(No error message.)"
	local fullErrorMsg = string.format("%s\n%s\n\n", errorMessage, debug.traceback() or "Stack Trace N/A")
	if not FileManager.ErrorsLogged[fullErrorMsg] then
		FileManager.ErrorsLogged[fullErrorMsg] = true

		-- Only print to user the first part of the error, that describes what went wrong; less overall clutter
		print(errorMessage)

		-- And print the full error and its stack trace in the log file
		local file = io.open(FileManager.prependDir(FileManager.Files.ERROR_LOG), "a")
		if file ~= nil then
			local currentTime = os.date("[%H:%M]")
			file:write(string.format("%s %s", currentTime, fullErrorMsg))
			file:flush()
			file:close()
		end
	end
end

function FileManager.buildImagePath(imageFolder, imageName, imageExtension)
	local listOfPaths = {
		FileManager.Folders.TrackerCode,
		FileManager.Folders.Images,
		tostring(imageFolder),
		tostring(imageName) .. (imageExtension or "")
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

function FileManager.buildSpritePath(animationType, imageName, imageExtension)
	local imageFolder = Options.getIconSet().folder
	local listOfPaths = {
		FileManager.Folders.TrackerCode,
		FileManager.Folders.Images,
		imageFolder,
		tostring(animationType),
		tostring(imageName) .. (imageExtension or "")
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

-- Returns a properly formatted folder path where custom code files are located; includes trailing slash
function FileManager.getCustomFolderPath()
	local listOfPaths = {
		FileManager.Folders.Custom,
		"", -- Necessary to include a trailing slash, helps with appending a filename
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

function FileManager.extractFolderNameFromPath(path)
	if path == nil or path == "" then return "" end

	if path:sub(-1) == FileManager.slash then
		path = path:sub(1, -2)
	end

	local folderStartIndex = path:match("^.*()[\\/]") -- path to folder
	if folderStartIndex ~= nil then
		local foldername = path:sub(folderStartIndex + 1)
		if foldername ~= nil then
			return foldername
		end
	end

	return ""
end

function FileManager.extractFileNameFromPath(path, includeExtension)
	if path == nil or path == "" then return "" end

	local folder, filename, extension = FileManager.getPathParts(path)
	if includeExtension and filename then
		return filename .. (extension or "")
	else
		return filename or ""
	end
end

function FileManager.extractFileExtensionFromPath(path)
	if path == nil or path == "" then return "" end

	local folder, filename, extension = FileManager.getPathParts(path)
	if extension and #extension > 1 then
		return extension:sub(2) -- remove the leading '.'
	else
		return ""
	end
end

--- Returns the folder, filename, and extension for the given filepath
--- @param filepath string The full file path to split apart
--- @return string folder, string filename, string extension
function FileManager.getPathParts(filepath)
	return string.match(filepath or "", "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

-- Copies file at 'filepath' to 'filecopyPath' with option to overwrite the file if it exists, or append to it
-- overwriteOrAppend: 'overwrite' replaces any existing file, 'append' adds to it instead, otherwise no change if file already exists
function FileManager.CopyFile(filepath, filepathCopy, overwriteOrAppend)
	if filepath == nil or filepath == "" then
		return false
	end

	local originalFile = io.open(filepath, "rb")
	if originalFile == nil then
		-- The originalFile to copy doesn't exist, simply do nothing and don't copy
		return false
	end

	-- filecopyPath = filecopyPath or (filepath .. " (Copy)") -- TODO: Fix this later, currently unused

	-- If the file exists but the option to overwrite/append was not specified, avoid altering the file
	if FileManager.fileExists(filepathCopy) and not (overwriteOrAppend == "overwrite" or overwriteOrAppend == "append") then
		-- print(string.format('Error: Unable to modify file "%s", no overwrite/append option specified.', filepathCopy))
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
		print(string.format('Error: Failed to write to file "%s"', filepathCopy))
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

-- 'filename' is a local name of a file
function FileManager.writeTableToFile(table, filename)
	local filepath = FileManager.prependDir(filename)
	local file = io.open(filepath, "w")

	if file ~= nil then
		local dataString = Pickle.pickle(table)
		--append a trailing \n if one is absent
		if dataString:sub(-1) ~= "\n" then dataString = dataString .. "\n" end
		for dataLine in dataString:gmatch("(.-)\n") do
			file:write(dataLine .. "\n")
		end
		file:flush()
		file:close()
	end
end

-- 'filepath' is must contain the absolute path to the file
function FileManager.readTableFromFile(filepath)
	local tableData = nil
	local file = io.open(filepath, "r")

	if file ~= nil then
		local dataString = file:read("*a")
		if not Utils.isNilOrEmpty(dataString) then
			tableData = Pickle.unpickle(dataString)
		end
		file:close()
	end

	return tableData
end

-- Returns a table that contains an entry for each line from a filename/filepath
function FileManager.readLinesFromFile(filename)
	local lines = {}

	local filepath = FileManager.getPathIfExists(filename)
	if filepath == nil then
		return lines
	end

	local file = io.open(filepath, "r")
	if file == nil then
		return lines
	end

	local fileContents = file:read("*a")
	if not Utils.isNilOrEmpty(fileContents) then
		for line in fileContents:gmatch("([^\r\n]+)[\r\n]*") do
			if line ~= nil then
				table.insert(lines, line)
			end
		end
	end
	file:close()

	return lines
end

--- Returns true if data is written to file, false if resulting json is empty, or nil if no file
---@param filepath string
---@param data table
---@return boolean|nil dataWritten
function FileManager.encodeToJsonFile(filepath, data)
	local file = filepath and io.open(filepath, "w")
	if file then
		-- Empty Json is "[]"
		local output = FileManager.JsonLibrary.encode(data) or "[]"
		file:write(output)
		file:close()
		return (#output > 2)
	end
end

--- Returns a lua table of the decoded json string from a file, or nil if no file
---@param filepath string
---@return table|nil data
function FileManager.decodeJsonFile(filepath)
	local file = filepath and io.open(filepath, "r")
	if file then
		local input = file:read("*a") or ""
		file:close()
		return #input > 0 and FileManager.JsonLibrary.decode(input) or {}
	end
end

function FileManager.addCustomThemeToFile(themeName, themeCode)
	if themeName == nil or themeCode == nil then
		return
	end

	local themeFilePath = FileManager.prependDir(FileManager.Files.THEME_PRESETS)
	local file = io.open(themeFilePath, "a")

	if file ~= nil then
		file:write(string.format("%s %s", themeName, themeCode))
		file:write("\n")
		file:close()
	else
		print(string.format('> ERROR: Unable to save custom Theme "%s" to file: %s', themeName, FileManager.Files.THEME_PRESETS))
	end
end

-- Removes a saved Theme preset by rewriting the file with all presets, but excluding the one that is being removed
function FileManager.removeCustomThemeFromFile(themeName, themeCode)
	local themeFilePath = FileManager.prependDir(FileManager.Files.THEME_PRESETS)

	if themeName == nil or themeCode == nil or not FileManager.fileExists(themeFilePath) then
		return false
	end

	local existingThemePresets = FileManager.readLinesFromFile(FileManager.Files.THEME_PRESETS)

	local file = io.open(themeFilePath, "w")
	if file == nil then
		print(string.format('> ERROR: Unable to remove custom Theme "%s" from file: %s', themeName, FileManager.Files.THEME_PRESETS))
		return false
	end

	for index, line in ipairs(existingThemePresets) do
		local firstHexIndex = line:find("%x%x%x%x%x%x")
		if firstHexIndex ~= nil then
			local themeLineCode = line:sub(firstHexIndex)
			local themeLineName
			if firstHexIndex <= 2 then
				themeLineName = "Untitled " .. index
			else
				themeLineName = line:sub(1, firstHexIndex - 2)
			end

			if themeLineName ~= themeName and themeLineCode ~= themeCode then
				file:write(line)
				file:write("\n")
			end
		end
	end
	file:close()

	return true
end

-- Recursively copies the contents of 'source' table into 'destination' table
function FileManager.copyTable(source, destination)
	for key, val in pairs(source or {}) do
		if type(val) == "table" then
			destination[key] = {}
			FileManager.copyTable(val, destination[key])
		else
			destination[key] = val
		end
	end
end

--- Loads the external Json library into FileManager.JsonLibrary
function FileManager.setupJsonLibrary()
	if type(FileManager.JsonLibrary) == "table" then
		return
	end
	local filepath = FileManager.getPathIfExists(FileManager.Files.JSON_LIBRARY)
	if filepath ~= nil then
		FileManager.JsonLibrary = dofile(filepath)
		if type(FileManager.JsonLibrary) ~= "table" then
			FileManager.JsonLibrary = nil
		end
	end
end
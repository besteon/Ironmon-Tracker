FileManager = {}

-- Define file separator. Windows is \ and Linux is /
FileManager.slash = package.config:sub(1,1) or "\\"

FileManager.Folders = {
	TrackerCode = "ironmon_tracker",
	DataCode = "data",
	ScreensCode = "screens",
	Languages = "Languages",
	RandomizerSettings = "RandomizerSettings",
	Images = "images",
	Badges = "badges",
	Icons = "icons",
	AnimatedPokemon = "pokemonAnimated",
}

FileManager.Files = {
	SETTINGS = "Settings.ini",
	THEME_PRESETS = "ThemePresets.txt",
	RANDOMIZER_ERROR_LOG = "RandomizerErrorLog.txt",

	-- All of the files required by the tracker
	LuaCode = {
		"Inifile.lua",
		"Constants.lua",
		string.format("%s%s%s", FileManager.Folders.DataCode, FileManager.slash, "PokemonData.lua"),
		string.format("%s%s%s", FileManager.Folders.DataCode, FileManager.slash, "MoveData.lua"),
		string.format("%s%s%s", FileManager.Folders.DataCode, FileManager.slash, "AbilityData.lua"),
		string.format("%s%s%s", FileManager.Folders.DataCode, FileManager.slash, "MiscData.lua"),
		string.format("%s%s%s", FileManager.Folders.DataCode, FileManager.slash, "RouteData.lua"),
		string.format("%s%s%s", FileManager.Folders.DataCode, FileManager.slash, "DataHelper.lua"),
		"Memory.lua",
		"GameSettings.lua",
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "InfoScreen.lua"),
		"Options.lua",
		"Theme.lua",
		"ColorPicker.lua",
		"Utils.lua",
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "TrackerScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "NavigationMenu.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "StartupScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "UpdateScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "SetupScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "ExtrasScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "QuickloadScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "GameOptionsScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "TrackedDataScreen.lua"),
		string.format("%s%s%s", FileManager.Folders.ScreensCode, FileManager.slash, "StatsScreen.lua"),
		"Input.lua",
		"Drawing.lua",
		"Program.lua",
		"Battle.lua",
		"Pickle.lua",
		"Tracker.lua",
		"MGBA.lua",
		"MGBADisplay.lua",
	},
	LanguageCode = {
		SpainData = "SpainData.lua",
		ItalyData = "ItalyData.lua",
		FranceData = "FranceData.lua",
		GermanyData = "GermanyData.lua",
	},
	Icons = {
		REPEL = "repelUsage.png",
	}
}

FileManager.PostFixes = {
	ATTEMPTS_FILE = "Attempts",
	AUTORANDOMIZED = "AutoRandomized",
	PREVIOUSATTEMPT = "PreviousAttempt",
	AUTOSAVE = "AutoSave",
}

FileManager.Extensions = {
	GBA_ROM = ".gba",
	RANDOMIZER_LOGFILE = ".log",
	TRACKED_DATA = ".tdat",
	ATTEMPTS = ".txt",
	ANIMATED_POKEMON = ".gif",
	BADGE = ".png",
}

FileManager.URLS = {
	VERSION = "https://api.github.com/repos/besteon/Ironmon-Tracker/releases/latest",
	DOWNLOAD = "https://github.com/besteon/Ironmon-Tracker/releases/latest",
	TAR = "https://github.com/besteon/Ironmon-Tracker/archive/main.tar.gz",
	WIKI = "https://github.com/besteon/Ironmon-Tracker/wiki",
}

-- Returns true if a file exists at its absolute file path; false otherwise
function FileManager.fileExists(filepath)
	return FileManager.getPathIfExists(filepath) ~= nil
end

-- Returns the filepath that allows opening a file at 'filepath', if one exists and it can be opened; otherwise, returns nil
function FileManager.getPathIfExists(filepath)
	if filepath == nil then return nil end

	-- Append the working directory to the start of the filepath, if missing
	-- if string.find(filepath, IronmonTracker.workingDir, 1, true) == nil then -- true = plain text search cause '\'
	-- 	filepath = FileManager.getAbsPath(filepath)
	-- end

	local file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	-- Otherwise check the absolute path of the file
	filepath = FileManager.getAbsPath(filepath)
	file = io.open(filepath, "r")
	if file ~= nil then
		io.close(file)
		return filepath
	end

	return nil
end

-- Returns the absolute file path using a local filename/path and the working directory of the Tracker
function FileManager.getAbsPath(filenameOrPath)
	return IronmonTracker.workingDir .. (filenameOrPath or "")
end

-- Returns true if on Windows. This setup required specifically for Bizhawk on Windows.
function FileManager.setupWorkingDirectory()
	-- Working directory, used for absolute paths
	local function exeCD() return io.popen("cd") end
	local success, ret, err = xpcall(exeCD, debug.traceback)
	if success and Main.IsOnBizhawk() and IronmonTracker.workingDir == "" then
		IronmonTracker.workingDir = ret:read()
	end

	-- Properly format the working directory
	IronmonTracker.workingDir = FileManager.formatPathForOS(IronmonTracker.workingDir)
	if IronmonTracker.workingDir:sub(-1) ~= FileManager.slash then
		IronmonTracker.workingDir = IronmonTracker.workingDir .. FileManager.slash
	end

	return success
end

-- Attempts to load all required tracker files. Returns true if successful; false otherwise.
function FileManager.loadTrackerFiles()
	for _, filename in ipairs(FileManager.Files.LuaCode) do
		local filepath = FileManager.getPathIfExists(FileManager.Folders.TrackerCode .. FileManager.slash .. filename)
		if filepath ~= nil then
			dofile(filepath)
		else
			print("Unable to load " .. filename .. "\nMake sure all of the downloaded Tracker's files are still together.")
			Main.DisplayError("Unable to load " .. filename .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
			return false
		end
	end
	return true
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

-- There is probably a better way to do this
function FileManager.buildImagePath(imageFolder, imageName, imageExtension)
	return IronmonTracker.workingDir .. FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Images .. FileManager.slash ..
	tostring(imageFolder) .. FileManager.slash .. tostring(imageName) .. (imageExtension or "")
end

function FileManager.extractFolderNameFromPath(path)
	if path == nil or path == "" then return "" end

	local folderStartIndex = path:match("^.*()[\\/]") -- path to folder
	if folderStartIndex ~= nil then
		local foldername = path:sub(folderStartIndex + 1)
		if foldername ~= nil then
			return foldername
		end
	end

	return ""
end

function FileManager.extractFileNameFromPath(path)
	if path == nil or path == "" then return "" end

	local nameStartIndex = path:match("^.*()" .. FileManager.slash) -- path to file
	local nameEndIndex = path:match("^.*()%.") -- file extension
	if nameStartIndex ~= nil and nameEndIndex ~= nil then
		local filename = path:sub(nameStartIndex + 1, nameEndIndex - 1)
		if filename ~= nil then
			return filename
		end
	end

	return ""
end

function FileManager.extractFileExtensionFromPath(path)
	if path == nil or path == "" then return "" end

	local extStartIndex = path:match("^.*()%.") -- file extension
	if extStartIndex ~= nil then
		local extension = path:sub(extStartIndex + 1)
		if extension ~= nil then
			return extension:lower()
		end
	end

	return ""
end

-- 'filename' is a local name of a file
function FileManager.writeTableToFile(table, filename)
	local filepath = FileManager.getAbsPath(filename)
	local file = io.open(filepath, "w")

	if file ~= nil then
		local dataString = Pickle.pickle(table)

		--append a trailing \n if one is absent
		if dataString:sub(-1) ~= "\n" then dataString = dataString .. "\n" end
		for dataLine in dataString:gmatch("(.-)\n") do
			file:write(dataLine)
			file:write("\n")
		end
		file:close()
	else
		print("[ERROR] Unable to create auto-save file: " .. filename)
	end
end

-- 'filepath' is must contain the absolute path to the file
function FileManager.readTableFromFile(filepath)
	local tableData = nil
	local file = io.open(filepath, "r")

	if file ~= nil then
		local dataString = file:read("*a")

		if dataString ~= nil and dataString ~= "" then
			tableData = Pickle.unpickle(dataString)
		end
		file:close()
	end

	return tableData
end

-- Returns a table that contains an entry for each line from a file
function FileManager.readLinesFromFile(filename)
	local lines = {}

	local filepath = FileManager.getAbsPath(filename)
	local file = io.open(filepath, "r")
	if file ~= nil then
		local fileContents = file:read("*a")
		if fileContents ~= nil and fileContents ~= "" then
			for line in fileContents:gmatch("([^\r\n]+)\r?\n") do
				if line ~= nil then
					table.insert(lines, line)
				end
			end
		end
		file:close()
	end

	return lines
end

function FileManager.addCustomThemeToFile(themeName, themeCode)
	if themeName == nil or themeCode == nil then
		return
	end

	local themeFilePath = FileManager.getAbsPath(FileManager.Files.THEME_PRESETS)
	local file = io.open(themeFilePath, "a")

	if file ~= nil then
		file:write(string.format("%s %s", themeName, themeCode))
		file:write("\n")
		file:close()
	else
		print(string.format("[ERROR] Unable to save custom Theme \"%s\" to file: %s", themeName, FileManager.Files.THEME_PRESETS))
	end
end

-- Removes a saved Theme preset by rewriting the file with all presets, but excluding the one that is being removed
function FileManager.removeCustomThemeFromFile(themeName, themeCode)
	local themeFilePath = FileManager.getAbsPath(FileManager.Files.THEME_PRESETS)

	if themeName == nil or themeCode == nil or not FileManager.fileExists(themeFilePath) then
		return false
	end

	local existingThemePresets = FileManager.readLinesFromFile(FileManager.Files.THEME_PRESETS)

	local file = io.open(themeFilePath, "w")
	if file == nil then
		print(string.format("[ERROR] Unable to remove custom Theme \"%s\" from file: %s", themeName, FileManager.Files.THEME_PRESETS))
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

FileManager = {}

-- Define file separator. Windows is \ and Linux is /
FileManager.slash = package.config:sub(1,1) or "\\"

FileManager.Folders = {
	TrackerCode = "ironmon_tracker",
	Quickload = "quickload",
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
}

FileManager.Extensions = {
	GBA_ROM = ".gba",
	RANDOMIZER_LOGFILE = ".log",
	TRACKED_DATA = ".tdat",
	ATTEMPTS = ".txt",
	ANIMATED_POKEMON = ".gif",
	BADGE = ".png",
}

FileManager.Urls = {
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
function FileManager.prependDir(filenameOrPath)
	return FileManager.dir .. (filenameOrPath or "")
end

-- Returns true if on Windows. This setup required specifically for Bizhawk on Windows.
function FileManager.setupWorkingDirectory()
	FileManager.dir = IronmonTracker.workingDir or ""
	-- Working directory, used for absolute paths
	local function exeCD() return io.popen("cd") end
	local success, ret, err = xpcall(exeCD, debug.traceback)
	if success and Main.IsOnBizhawk() and FileManager.dir == "" then
		FileManager.dir = ret:read()
	end

	-- Properly format the working directory
	FileManager.dir = FileManager.formatPathForOS(FileManager.dir)
	if FileManager.dir:sub(-1) ~= FileManager.slash then
		FileManager.dir = FileManager.dir .. FileManager.slash
	end
end

-- Attempts to load a file as Lua code. Returns true if successful; false otherwise.
function FileManager.loadLuaFile(filename)
	local filepath = FileManager.getPathIfExists(FileManager.Folders.TrackerCode .. FileManager.slash .. filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	else
		print("Unable to load " .. filename .. "\nMake sure all of the downloaded Tracker's files are still together.")
		Main.DisplayError("Unable to load " .. filename .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
		return false
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

-- Returns a list of file names found in a given folder
function FileManager.getFilesFromDirectory(folderpath)
	local files = {}
	if folderpath == nil or io.popen == nil then return files end

	local scanDirCommand
	if Main.OS == "Windows" then
		scanDirCommand = string.format('dir "%s" /b', folderpath)
	else
		scanDirCommand = string.format('ls -a "%s"', folderpath)
	end
	local pfile = io.popen(scanDirCommand)
	if pfile ~= nil then
		for filename in pfile:lines() do
			table.insert(files, filename)
		end
		pfile:close()
	end

	return files
end

-- There is probably a better way to do this
function FileManager.buildImagePath(imageFolder, imageName, imageExtension)
	return FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Images .. FileManager.slash ..
	tostring(imageFolder) .. FileManager.slash .. tostring(imageName) .. (imageExtension or ""))
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

	local nameStartIndex = path:match("^.*()" .. FileManager.slash) or 0 -- path to file
	local nameEndIndex = path:match("^.*()%.") -- file extension
	if nameEndIndex ~= nil then
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
		print(string.format('Error: Unable to modify file "%s", no overwrite/append option specified.', filepathCopy))
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

	local filepath = FileManager.prependDir(filename)
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

	local themeFilePath = FileManager.prependDir(FileManager.Files.THEME_PRESETS)
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
	local themeFilePath = FileManager.prependDir(FileManager.Files.THEME_PRESETS)

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

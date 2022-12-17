-- This file is NOT automatically loaded on Tracker startup; only loads *after* new update files are downloaded
-- In this way, this file will always be the latest version possible and allow for properly updating files

-- Lots of redundancy here as this file is meant to work as a standalong or as part of the full Tracker script
AutoUpdater = {
	thisFileName = "AutoUpdater.lua",
	trackerFileName = "Ironmon-Tracker.lua",
	slash = package.config:sub(1,1) or "\\", -- Windows is \ and Linux is /
	TAR_URL = "https://github.com/besteon/Ironmon-Tracker/archive/main.tar.gz",
	archiveName = "Ironmon-Tracker-main.tar.gz",
	archiveFolder = "Ironmon-Tracker-main",
	Dev = {
		enabled = true, -- TODO: Change this to false and remove branch-specific references below on release
		TAR_URL = "https://github.com/besteon/Ironmon-Tracker/archive/refs/heads/utdzac/mgba-support-ohmy.tar.gz",
		archiveName = "Ironmon-Tracker-utdzac-mgba-support-ohmy.tar.gz",
		archiveFolder = "Ironmon-Tracker-utdzac-mgba-support-ohmy",
	},
	Messages = {
		step1 = "Step 1: Downloading release and extracting files...",
		step1a = "Step 1: Existing release already downloaded and ready to use.",
		step2 = "Step 2: Updating Tracker files...",
		step3 = "Step 3: Verifying update... Auto-update successful!",
	},
}

-- Allows for loading just this single file manually to try an auto-update again
function AutoUpdater.start()
	-- Do NOT perform the standalone update if this file is loaded alongside the Tracker
	if IronmonTracker ~= nil then
		return
	end

	AutoUpdater.setupEmulatorSpecifics()
	AutoUpdater.performStandaloneUpdate()
end

function AutoUpdater.getTARURL()
	if AutoUpdater.Dev.enabled then return AutoUpdater.Dev.TAR_URL else return AutoUpdater.TAR_URL end
end

function AutoUpdater.getArchiveName()
	if AutoUpdater.Dev.enabled then return AutoUpdater.Dev.archiveName else return AutoUpdater.archiveName end
end

function AutoUpdater.getArchiveFolder()
	if AutoUpdater.Dev.enabled then return AutoUpdater.Dev.archiveFolder else return AutoUpdater.archiveFolder end
end

function AutoUpdater.setupEmulatorSpecifics()
	if IronmonTracker == nil then -- redundant safety check
		IronmonTracker = {}
	end

	-- This function doesn't exist in Bizhawk, only mGBA
	IronmonTracker.isOnBizhawk = (console.createBuffer == nil)

	-- Get the current working directory of the Tracker script, needed for mGBA
	if IronmonTracker.workingDir == nil then -- required to prevent overwrite in rare cases
		local pathLookup = debug.getinfo(2, "S").source:sub(2)
		IronmonTracker.workingDir = pathLookup:match("(.*[/\\])") or ""

		-- Format path for OS
		if AutoUpdater.slash == "/" then
			IronmonTracker.workingDir = IronmonTracker.workingDir:gsub("\\", "/")
		else
			IronmonTracker.workingDir = IronmonTracker.workingDir:gsub("/", "\\")
		end

		-- Add trailing slash if missing
		if IronmonTracker.workingDir ~= "" and IronmonTracker.workingDir:sub(-1) ~= AutoUpdater.slash then
			IronmonTracker.workingDir = IronmonTracker.workingDir .. AutoUpdater.slash
		end
	end

	-- Redefine Lua print function to be compatible with outputting to mGBA's scripting console
	if IronmonTracker.isOnBizhawk then
		print = function(...) console.log(...) end
	else
		print = function(...) console:log(...) end
	end
end

-- The full update process to be run while the Tracker code is active and loaded. Returns [true/false] based on success
function AutoUpdater.performParallelUpdate()
	-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.OS ~= "Windows" and Main.emulator == Main.EMU.BIZHAWK28 then
		return false
	end

	local archiveFolderPath = AutoUpdater.downloadAndExtract()
	if archiveFolderPath == nil then
		return false
	end

	-- Attempt to replace the local AutoUpdater.lua with the newly downloaded one
	FileManager.loadLuaFile(archiveFolderPath .. FileManager.slash .. FileManager.Files.AUTOUPDATER, true)

	local success = AutoUpdater.updateFiles(archiveFolderPath)
	if success then
		print(string.format("> %s", AutoUpdater.Messages.step3))
	end
	return success
end

-- The full update process to be run WITHOUT any other Tracker code loaded. Returns [true/false] based on success
function AutoUpdater.performStandaloneUpdate()
	local releaseFolderPath

	-- Check if the download was completed and extracted, but the update halted before it was removed
	local updaterFilePath = IronmonTracker.workingDir .. AutoUpdater.getArchiveFolder() .. AutoUpdater.slash .. AutoUpdater.thisFileName
	local file = io.open(updaterFilePath, "r")
	if file ~= nil then
		file:close()
		print(string.format("> %s", AutoUpdater.Messages.step1a))
	else
		releaseFolderPath = AutoUpdater.downloadAndExtract()
		if releaseFolderPath == nil then
			return false
		end
	end

	releaseFolderPath = releaseFolderPath or (IronmonTracker.workingDir .. AutoUpdater.getArchiveFolder())

	local success = AutoUpdater.updateFiles(releaseFolderPath)
	if success then
		print(string.format("> %s", AutoUpdater.Messages.step3))
		print("")
		print(string.format('Please restart your emulator and load the main "%s" script.', AutoUpdater.trackerFileName))
	end

	return success
end

-- Returns the folderpath that contains the extracted release files from the downloaded archive 'tarURL'; returns nil if something failed
function AutoUpdater.downloadAndExtract()
	print(string.format("> %s", AutoUpdater.Messages.step1))

	-- Temp Files/Folders used by batch operations
	local tarUrl = AutoUpdater.getTARURL()
	local archiveFilePath = IronmonTracker.workingDir .. AutoUpdater.getArchiveName()
	local extractedFolderPath = IronmonTracker.workingDir .. AutoUpdater.getArchiveFolder()

	local isOnWindows = (AutoUpdater.slash == "\\")
	local command, err1 = AutoUpdater.buildDownloadExtractCommand(tarUrl, archiveFilePath, extractedFolderPath, isOnWindows)

	local result = os.execute(command)
	if not (result == true or result == 0) then -- true / 0 = successful
		print("> ERROR: " .. err1)
		print("> Archive: " .. (tarUrl or "URL N/A"))
		return nil
	end

	return extractedFolderPath
end

-- Copies files from the archive folder to the Tracker folder itself, replacing them
function AutoUpdater.updateFiles(archiveFolderPath)
	-- For cases when the download/extract operation fails, but the client continues to try and update anyway
	if archiveFolderPath == nil then
		return false
	end

	print(string.format("> %s", AutoUpdater.Messages.step2))

	local isOnWindows = (AutoUpdater.slash == "\\")
	local command, err1, err2 = AutoUpdater.buildCopyFilesCommand(archiveFolderPath, isOnWindows)

	local result = os.execute(command)
	if not (result == true or result == 0) then -- true / 0 = successful
		print("> ERROR: " .. err1)
		print("> " .. err2)
		return false
	end

	return true
end

-- Returns a string of batch commands to run based on the operating system, also returns error messages
function AutoUpdater.buildDownloadExtractCommand(tarUrl, archive, extractedFolder, isOnWindows)
	local messages = {
		downloading = "Downloading the latest Ironmon Tracker version.",
		extracting = "Extracting downloaded files.",
		error1 = "Unable to download or extract files from online release archive.",
	}

	local batchCommands = {}
	local pauseCommand

	local foldersToRemove = {
		string.format('%s.vscode', extractedFolder .. AutoUpdater.slash),
		string.format('%sironmon_tracker%sDebug', extractedFolder .. AutoUpdater.slash, AutoUpdater.slash),
	}
	local filesToRemove = {
		string.format('%s.editorconfig', extractedFolder .. AutoUpdater.slash),
		string.format('%s.gitattributes', extractedFolder .. AutoUpdater.slash),
		string.format('%s.gitignore', extractedFolder .. AutoUpdater.slash),
		string.format('%sREADME.md', extractedFolder .. AutoUpdater.slash),
	}

	if isOnWindows then
		batchCommands = {
			string.format('echo %s', messages.downloading),
			string.format('curl -L "%s" -o "%s" --ssl-no-revoke', tarUrl, archive),
			'echo;',
			string.format('echo %s', messages.extracting),
			string.format('cd "%s"', IronmonTracker.workingDir), -- required for mGBA on Windows
			string.format('tar -xzf "%s"', archive),
			string.format('del "%s"', archive),
		}
		for _, folder in ipairs(foldersToRemove) do
			table.insert(batchCommands, string.format('rmdir "%s" /s /q', folder))
		end
		for _, file in ipairs(filesToRemove) do
			table.insert(batchCommands, string.format('del "%s" /q /f', file))
		end
		pauseCommand = string.format("echo; && echo %s && pause && exit /b 6", messages.error1)
	else
		batchCommands = {
			string.format('echo %s', messages.downloading),
			string.format('curl -L "%s" -o "%s" --ssl-no-revoke', tarUrl, archive),
			'echo',
			string.format('echo %s', messages.extracting),
			string.format('mkdir -p "%s"', extractedFolder),
			string.format('tar -xzf "%s" --overwrite -C "%s"', archive, IronmonTracker.workingDir), --extractedFolder), -- unsure which is correct, might be specific to dev
			string.format('rm -rf "%s"', archive),
		}
		for _, folder in ipairs(foldersToRemove) do
			table.insert(batchCommands, string.format('rm -rf "%s"', folder))
		end
		for _, file in ipairs(filesToRemove) do
			table.insert(batchCommands, string.format('rm -f "%s"', file))
		end
		-- Temp removing the "pause" as can't tell if it was causing issues.
		pauseCommand = string.format('echo && echo %s && exit 6', messages.error1)

		-- Print out messages, as a terminal window doesn't always appear to show status
		print(string.format(".. %s", messages.downloading))
		print(string.format(".. %s", messages.extracting))
	end

	-- Pause if any of the commands fail, those grouped between ( )
	local combinedCommand = string.format("(%s) || (%s)", table.concat(batchCommands, ' && '), pauseCommand)

	return combinedCommand, messages.error1
end

-- Returns a string of batch commands to run based on the operating system, also returns error messages
-- TODO: Known issue is XCOPY seems to fail if Tracker is kept on OneDrive or in a secure folder
function AutoUpdater.buildCopyFilesCommand(extractedFolder, isOnWindows)
	local messages = {
		filesready = "New release files downloaded and ready for update.",
		updating = "Applying the update, copying over files.",
		completed = "Version update completed successfully.",
		error1 = "Unable to copy over and update Tracker files.",
		error2 = string.format('Try restarting the emulator and loading ONLY the "%s" script.', AutoUpdater.thisFileName),
	}

	local batchCommands = {}
	local pauseCommand
	local sleepTime = 3

	if isOnWindows then
		batchCommands = {
			string.format('echo %s', messages.filesready),
			string.format('cd "%s"', IronmonTracker.workingDir), -- required for mGBA on Windows
			string.format('echo %s', messages.updating),
			string.format('xcopy "%s" /s /y /q', extractedFolder),
			string.format('rmdir "%s" /s /q', extractedFolder),
			'echo;',
			string.format('echo %s', messages.completed),
			string.format('timeout /t %s', sleepTime),
		}
		pauseCommand = string.format("echo; && echo %s && echo %s && pause && exit /b 6", messages.error1, messages.error2)
	else
		batchCommands = {
			string.format('echo %s', messages.filesready),
			string.format('echo %s', messages.updating),
			string.format('cp -fr "%s" "%s"', extractedFolder .. AutoUpdater.slash .. ".", IronmonTracker.workingDir),
			string.format('rm -rf "%s"', extractedFolder),
			'echo',
			string.format('echo %s', messages.completed),
		}
		-- Temp removing the "pause" as can't tell if it was causing issues.
		pauseCommand = string.format('echo && echo %s && echo %s && exit 6', messages.error1, messages.error2)

		-- Print out messages, as a terminal window doesn't always appear to show status
		print(string.format(".. %s", messages.filesready))
		print(string.format(".. %s", messages.updating))
	end

	-- Pause if any of the commands fail, those grouped between ( )
	local combinedCommand = string.format("(%s) || (%s)", table.concat(batchCommands, ' && '), pauseCommand)

	return combinedCommand, messages.error1, messages.error2
end

AutoUpdater.start()
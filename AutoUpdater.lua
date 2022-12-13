-- This file is NOT automatically loaded on Tracker startup; only loads *after* new update files are downloaded
-- In this way, this file will always be the latest version possible and allow for properly updating files

-- Lots of redundancy here as this file is meant to work as a standalong or as part of the full Tracker script
AutoUpdater = {
	thisFileName = "AutoUpdater.lua",
	trackerFileName = "Ironmon-Tracker.lua",
	slash = package.config:sub(1,1) or "\\", -- Windows is \ and Linux is /
	TAR = "https://github.com/besteon/Ironmon-Tracker/archive/main.tar.gz",
	archiveName = "Ironmon-Tracker-main.tar.gz",
	archiveFolder = "Ironmon-Tracker-main",
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

function AutoUpdater.performStandaloneUpdate()
	local releaseFolderPath

	-- Check if the download was completed and extracted, but the update halted before it was removed
	local updaterFilePath = IronmonTracker.workingDir .. AutoUpdater.archiveFolder .. AutoUpdater.slash .. AutoUpdater.thisFileName
	local file = io.open(updaterFilePath, "r")
	if file == nil then
		releaseFolderPath = AutoUpdater.downloadAndExtract()
		if releaseFolderPath == nil then
			return false
		end
	end
	io.close(file)

	releaseFolderPath = releaseFolderPath or (IronmonTracker.workingDir .. AutoUpdater.archiveFolder)
	local success = AutoUpdater.updateFiles(releaseFolderPath)
	if not success then
		return false
	end

	print("> Version update successful!")
	print("")
	print(string.format('> Please restart your emulator and load the main "%s" script.', AutoUpdater.trackerFileName))
	return true
end

-- Returns the folderpath that contains the extracted release files from the downloaded archive 'tarURL'; returns nil if something failed
function AutoUpdater.downloadAndExtract(tarUrl)
	tarUrl = tarUrl or AutoUpdater.TAR

	print("> Downloading release archive and extracting files.")

	-- Temp Files/Folders used by batch operations
	local archiveFilePath = IronmonTracker.workingDir .. AutoUpdater.archiveName
	local extractedFolderPath = IronmonTracker.workingDir .. AutoUpdater.archiveFolder

	local isOnWindows = (AutoUpdater.slash == "\\")
	local command, err1 = AutoUpdater.buildDownloadExtractCommand(tarUrl, archiveFilePath, extractedFolderPath, isOnWindows)

	local result = os.execute(command)
	if result ~= 0 then -- 0 = successful
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

	local isOnWindows = (AutoUpdater.slash == "\\")
	local command, err1, err2 = AutoUpdater.buildCopyFilesCommand(archiveFolderPath, isOnWindows)

	local result = os.execute(command)
	if result ~= 0 then -- 0 = successful
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
		string.format('%s%s.vscode', extractedFolder, AutoUpdater.slash),
		string.format('%s%sironmon_tracker%sDebug', extractedFolder, AutoUpdater.slash),
	}
	local filesToRemove = {
		string.format('%s%s.editorconfig', extractedFolder, AutoUpdater.slash),
		string.format('%s%s.gitattributes', extractedFolder, AutoUpdater.slash),
		string.format('%s%s.gitignore', extractedFolder, AutoUpdater.slash),
		string.format('%s%sREADME.md', extractedFolder, AutoUpdater.slash),
		string.format('%s%squickload%s.gitignore', extractedFolder, AutoUpdater.slash, AutoUpdater.slash), -- this will error until new release is live
	}

	if isOnWindows then
		batchCommands = {
			string.format('echo %s', messages.downloading),
			string.format('curl -L "%s" -o "%s" --ssl-no-revoke', tarUrl, archive),
			string.format('echo;'),
			string.format('echo %s', messages.extracting),
			string.format('tar -xf "%s" && del "%s"', archive, archive),
		}
		for _, folder in ipairs(foldersToRemove) do
			table.insert(batchCommands, string.format('rmdir "%s" /s /q', folder))
		end
		for _, file in ipairs(filesToRemove) do
			table.insert(batchCommands, string.format('del "%s" /q /f', file))
		end
		pauseCommand = string.format("echo; && echo %s && pause", messages.error1)
	else
		batchCommands = {
			string.format('echo %s', messages.downloading),
			string.format('curl -L "%s" -o "%s" --ssl-no-revoke', tarUrl, archive),
			string.format('echo'),
			string.format('echo %s', messages.extracting),
			string.format('tar -xf "%s" && rm -f "%s"', archive, archive),
		}
		for _, folder in ipairs(foldersToRemove) do
			table.insert(batchCommands, string.format('rm -rf "%s"', folder))
		end
		for _, file in ipairs(filesToRemove) do
			table.insert(batchCommands, string.format('rm -f "%s"', file))
		end
		pauseCommand = string.format('echo && echo %s && read -n1 -rp "Press any key to continue..."', messages.error1)
	end

	-- Pause if any of the commands fail, those grouped between ( )
	local combinedCommand = string.format("(%s) || (%s)", table.concat(batchCommands, ' && '), pauseCommand)

	return combinedCommand, messages.error1
end

-- Returns a string of batch commands to run based on the operating system, also returns error messages
-- Known issue is XCOPY seems to fail if Tracker is kept on OneDrive or in a secure folder
function AutoUpdater.buildCopyFilesCommand(extractedFolder, isOnWindows)
	local messages = {
		filesready = "New release files downloaded and ready for update.",
		updating = "Applying the update; copying over files.",
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
			string.format('echo %s', messages.updating),
			string.format('xcopy "%s" /s /y /q', extractedFolder),
			string.format('rmdir "%s" /s /q', extractedFolder),
			string.format('echo;'),
			string.format('echo %s', messages.completed),
			string.format('timeout /t %s', sleepTime),
		}
		pauseCommand = string.format("echo; && echo %s && echo %s && pause", messages.error1, messages.error2)
	else
		batchCommands = {
			string.format('echo %s', messages.filesready),
			string.format('echo %s', messages.updating),
			string.format('cp -r "%s" "%s"', extractedFolder .. AutoUpdater.slash .. ".", IronmonTracker.workingDir),
			string.format('rm -rf "%s"', extractedFolder),
			string.format('echo'),
			string.format('echo %s', messages.completed),
			string.format('sleep %s', sleepTime),
		}
		pauseCommand = string.format('echo && echo %s && echo %s && read -n1 -rp "Press any key to continue..."', messages.error1, messages.error2)
	end

	-- Pause if any of the commands fail, those grouped between ( )
	local combinedCommand = string.format("(%s) || (%s)", table.concat(batchCommands, ' && '), pauseCommand)

	return combinedCommand, messages.error1, messages.error2
end

AutoUpdater.start()
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

	-- TODO: For non-Windows OS, likely need to use something other than a .bat file

	local batchCommands = {
		-- Download the release archive
		'echo Downloading the latest Ironmon Tracker version.',
		string.format('curl -L "%s" -o "%s" --ssl-no-revoke', tarUrl, archiveFilePath),
		-- Extract the archive
		'echo; && echo Extracting downloaded files.', -- "echo;" prints a new line
		string.format('tar -xf "%s" && del "%s"', archiveFilePath, archiveFilePath),
		-- Remove unneeded files
		string.format('rmdir "%s%s.vscode" /s /q', extractedFolderPath, AutoUpdater.slash),
		string.format('rmdir "%s%sironmon_tracker%sDebug" /s /q', extractedFolderPath, AutoUpdater.slash, AutoUpdater.slash),
	}
	local filesToRemove = {
		string.format('%s%s.editorconfig', extractedFolderPath, AutoUpdater.slash),
		string.format('%s%s.gitattributes', extractedFolderPath, AutoUpdater.slash),
		string.format('%s%s.gitignore', extractedFolderPath, AutoUpdater.slash),
		string.format('%s%sREADME.md', extractedFolderPath, AutoUpdater.slash),
		string.format('%s%squickload%s.gitignore', extractedFolderPath, AutoUpdater.slash, AutoUpdater.slash), -- this will error until new release is live
	}
	for _, file in ipairs(filesToRemove) do
		table.insert(batchCommands, string.format('del "%s" /q /f', file))
	end

	local errorMsg1 = 'Unable to download or extract files from online release archive.'

	-- Pause if any of the commands fail, those grouped between ( )
	local combinedCommand = string.format("(%s) || (echo; && echo %s && pause)",
		table.concat(batchCommands, ' && '),
		errorMsg1)

	local result = os.execute(combinedCommand)
	if result ~= 0 then -- 0 = successful
		print("> ERROR: " .. errorMsg1)
		print("> Archive: " .. (tarUrl or "URL N/A"))
		return nil
	end

	return extractedFolderPath
end

-- Copies files from the archive folder to the Tracker folder itself, replacing them
-- Known issue is XCOPY seems to fail if Tracker is kept on OneDrive or in a secure folder
function AutoUpdater.updateFiles(archiveFolderPath)
	-- For cases when the download/extract operation fails, but the client continues to try and update anyway
	if archiveFolderPath == nil then
		return false
	end

	local batchCommands = {
		'echo; && echo New release files downloaded and ready for update.',
		-- Update and overwrite files
		'echo Applying the update; copying over files.',
		string.format('xcopy "%s" /s /y /q', archiveFolderPath),
		-- Cleanup downloaded archive folder
		string.format('rmdir "%s" /s /q', archiveFolderPath),
		'echo; && echo Version update completed successfully.',
		'timeout /t 3',
	}

	local errorMsg1 = 'Unable to copy over and update Tracker files.'
	local errorMsg2 = string.format('Try restarting the emulator and loading ONLY the "%s" script.', AutoUpdater.thisFileName)

	-- Pause if any of the commands fail, those grouped between ( )
	local combinedCommand = string.format("(%s) || (echo; && echo %s && echo %s && pause)",
		table.concat(batchCommands, ' && '),
		errorMsg1,
		errorMsg2)

	local result = os.execute(combinedCommand)
	if result ~= 0 then -- 0 = successful
		print("> ERROR: " .. errorMsg1)
		print("> " .. errorMsg2)
		return false
	end

	return true
end

AutoUpdater.start()
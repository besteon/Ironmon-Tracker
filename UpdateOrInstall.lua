-- This file is NOT automatically loaded on Tracker startup; only loads *after* new update files are downloaded
-- In this way, this file will always be the latest version possible and allow for properly updating files

-- Lots of redundancy here as this file is meant to work as a standalone or as part of the full Tracker script
UpdateOrInstall = {
	thisFileName = "UpdateOrInstall.lua",
	trackerFileName = "Ironmon-Tracker.lua",
	slash = package.config:sub(1,1) or "\\", -- Windows is \ and Linux is /
	TAR_URL = "https://github.com/besteon/Ironmon-Tracker/archive/main.tar.gz",
	archiveName = "Ironmon-Tracker-main.tar.gz",
	archiveFolder = "Ironmon-Tracker-main",
}

-- Beta testers can have this enabled to receive live updates from STAGING branch
UpdateOrInstall.Dev = {
	enabled = false, -- Verify this remains "false" for main release
	TAR_URL = "https://github.com/besteon/Ironmon-Tracker/archive/refs/heads/beta-test.tar.gz",
	archiveName = "Ironmon-Tracker-beta-test.tar.gz",
	archiveFolder = "Ironmon-Tracker-beta-test",
}

UpdateOrInstall.Messages = {
	updateBegin = " --- Update/Install in progress ---",
	step1 = "Step 1: Downloading release and extracting files...",
	step1a = "Step 1: Existing release already downloaded and ready to use.",
	step2 = "Step 2: Updating Tracker files...",
	step3 = "Step 3: Verifying update... Auto-update successful!",
	confirmFreshInstall = "Would you like to download and INSTALL the Tracker?",
	confirmUpdate = "Would you like to download and UPDATE the Tracker?",
	confirmYesNo = "To confirm, please type YES() or NO() in the scripting box below:",
	closeAndReopen = string.format('Please restart your emulator and load the main "%s" script.', UpdateOrInstall.trackerFileName),
	conflict1 = "The Tracker cannot automatically finish updating due to a conflict.",
	conflict2 = 'Restart the emulator and load the "UpdateOrInstall.lua" file found in your Tracker folder.',
}

-- Allows for loading just this single file manually to try an auto-update again
function UpdateOrInstall.start()
	-- Do NOT perform the standalone update if this file is loaded alongside the Tracker
	if IronmonTracker ~= nil then
		return
	end

	UpdateOrInstall.setupEmulatorSpecifics()
	UpdateOrInstall.popupConfirmationWindow()
end

function UpdateOrInstall.getTARURL()
	if UpdateOrInstall.Dev.enabled then return UpdateOrInstall.Dev.TAR_URL else return UpdateOrInstall.TAR_URL end
end

function UpdateOrInstall.getArchiveName()
	if UpdateOrInstall.Dev.enabled then return UpdateOrInstall.Dev.archiveName else return UpdateOrInstall.archiveName end
end

function UpdateOrInstall.getArchiveFolder()
	if UpdateOrInstall.Dev.enabled then return UpdateOrInstall.Dev.archiveFolder else return UpdateOrInstall.archiveFolder end
end

function UpdateOrInstall.setupEmulatorSpecifics()
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
		if UpdateOrInstall.slash == "/" then
			IronmonTracker.workingDir = IronmonTracker.workingDir:gsub("\\", "/")
		else
			IronmonTracker.workingDir = IronmonTracker.workingDir:gsub("/", "\\")
		end

		-- Add trailing slash if missing
		if IronmonTracker.workingDir ~= "" and IronmonTracker.workingDir:sub(-1) ~= UpdateOrInstall.slash then
			IronmonTracker.workingDir = IronmonTracker.workingDir .. UpdateOrInstall.slash
		end
	end

	-- Redefine Lua print function to be compatible with outputting to mGBA's scripting console
	if IronmonTracker.isOnBizhawk then
		print = function(...) console.log(...) end
	else
		print = function(...) console:log(...) end
	end
end

function UpdateOrInstall.popupConfirmationWindow()
	-- First check if any other tracker files exist to determine if this is a new install (non-functional difference)
	local confirmationMsg, windowTitle
	local trackerFile = io.open(IronmonTracker.workingDir .. UpdateOrInstall.trackerFileName, "r")
	if trackerFile == nil then
		confirmationMsg = UpdateOrInstall.Messages.confirmFreshInstall
		windowTitle = "Installer"
	else
		confirmationMsg = UpdateOrInstall.Messages.confirmUpdate
		windowTitle = "Updater"
		io.close(trackerFile)
	end

	-- Only Bizhawk allows popup form windows
	if IronmonTracker.isOnBizhawk then
		client.pause()
		local form = forms.newform(340, 120, string.format("Ironmon Tracker %s", windowTitle), function() client.unpause() end)
		local actualLocation = client.transformPoint(100, 50)
		forms.setproperty(form, "Left", client.xpos() + actualLocation['x'] )
		forms.setproperty(form, "Top", client.ypos() + actualLocation['y'] + 64) -- so we are below the ribbon menu

		forms.label(form, confirmationMsg, 18, 10, 320, 20)
		forms.button(form, "Yes", function()
			client.unpause()
			forms.destroy(form)
			UpdateOrInstall.performStandaloneUpdate()
		end, 80, 40)
		forms.button(form, "No", function()
			client.unpause()
			forms.destroy(form)
			print(UpdateOrInstall.Messages.closeAndReopen)
		end, 160, 40)
	else
		print(confirmationMsg)
		print(string.format("> %s", UpdateOrInstall.Messages.confirmYesNo))
	end
end

-- Only add in the YES/NO commands if this is a standalone install
if Main == nil then
	function YES(...)
		UpdateOrInstall.performStandaloneUpdate()
	end
	function Yes(...) YES(...) end
	---@diagnostic disable-next-line: lowercase-global
	function yes(...) YES(...) end
	function NO(...)
		print("")
		print(UpdateOrInstall.Messages.closeAndReopen)
	end
	function No(...) NO(...) end
	---@diagnostic disable-next-line: lowercase-global
	function no(...) NO(...) end
end

-- The full update process to be run while the Tracker code is active and loaded. Returns [true/false] based on success
function UpdateOrInstall.performParallelUpdate()
	-- Auto-update not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.OS ~= "Windows" and Main.emulator == Main.EMU.BIZHAWK28 then
		return false
	end

	print(string.format("> %s", UpdateOrInstall.Messages.updateBegin))

	local archiveFolderPath = UpdateOrInstall.downloadAndExtract()
	if archiveFolderPath == nil then
		return false
	end

	-- Attempt to replace the local UpdateOrInstall.lua with the newly downloaded one
	FileManager.loadLuaFile(archiveFolderPath .. FileManager.slash .. FileManager.Files.UPDATE_OR_INSTALL, true)
	-- NOTE: After the new file is loaded, this function still operates exactly as written.
	-- Don't trust new code you put in this function call.
	-- If you want new code from the download to be applied, include it in one of the following function calls: e.g. updateFiles()

	local success = UpdateOrInstall.updateFiles(archiveFolderPath)
	if success then
		print(string.format("> %s", UpdateOrInstall.Messages.step3))
	end
	return success
end

-- The full update process to be run WITHOUT any other Tracker code loaded. Returns [true/false] based on success
function UpdateOrInstall.performStandaloneUpdate()
	print(string.format("> %s", UpdateOrInstall.Messages.updateBegin))
	local releaseFolderPath

	-- Temporarily removing this, as it can potentiall cause issues when a failed update prevents grabbing the actual latest (maybe two weeks has passed)
	-- Check if the download was completed and extracted, but the update halted before it was removed
	-- local updaterFilePath = IronmonTracker.workingDir .. UpdateOrInstall.getArchiveFolder() .. UpdateOrInstall.slash .. UpdateOrInstall.thisFileName
	-- local file = io.open(updaterFilePath, "r")
	-- if file ~= nil then
		-- file:close()
		-- print(string.format("> %s", UpdateOrInstall.Messages.step1a))
	-- else
		releaseFolderPath = UpdateOrInstall.downloadAndExtract()
		if releaseFolderPath == nil then
			return false
		end
	-- end

	releaseFolderPath = releaseFolderPath or (IronmonTracker.workingDir .. UpdateOrInstall.getArchiveFolder())

	local success = UpdateOrInstall.updateFiles(releaseFolderPath)
	if success then
		print(string.format("> %s", UpdateOrInstall.Messages.step3))
		print("")
		print(UpdateOrInstall.Messages.closeAndReopen)
	end

	return success
end

-- Returns the folderpath that contains the extracted release files from the downloaded archive 'tarURL'; returns nil if something failed
function UpdateOrInstall.downloadAndExtract()
	print(string.format("> %s", UpdateOrInstall.Messages.step1))

	-- Temp Files/Folders used by batch operations
	local tarUrl = UpdateOrInstall.getTARURL()
	local archiveFilePath = IronmonTracker.workingDir .. UpdateOrInstall.getArchiveName()
	local extractedFolderPath = IronmonTracker.workingDir .. UpdateOrInstall.getArchiveFolder()

	local isOnWindows = (UpdateOrInstall.slash == "\\")
	local command, err1 = UpdateOrInstall.buildDownloadExtractCommand(tarUrl, archiveFilePath, extractedFolderPath, isOnWindows)

	local result = os.execute(command)
	if not (result == true or result == 0) then -- true / 0 = successful
		print("> ERROR: " .. err1)
		print("> Archive: " .. (tarUrl or "URL N/A"))
		return nil
	end

	return extractedFolderPath
end

-- Copies files from the archive folder to the Tracker folder itself, replacing them
function UpdateOrInstall.updateFiles(archiveFolderPath)
	-- For cases when the download/extract operation fails, but the client continues to try and update anyway
	if archiveFolderPath == nil then
		return false
	end

	print(string.format("> %s", UpdateOrInstall.Messages.step2))

	local isOnWindows = (UpdateOrInstall.slash == "\\")

	local okayToUpdate, reason = UpdateOrInstall.verifyOkayToParallelUpdate(archiveFolderPath, isOnWindows)
	if not okayToUpdate then
		print("")
		print("> ERROR: " .. UpdateOrInstall.Messages.conflict1)
		if reason ~= nil then
			print("> REASON: " .. reason)
		end
		print("> TO FIX: " .. UpdateOrInstall.Messages.conflict2)
		return false
	end

	local command, err1, err2 = UpdateOrInstall.buildCopyFilesCommand(archiveFolderPath, isOnWindows)

	local result = os.execute(command)
	if not (result == true or result == 0) then -- true / 0 = successful
		print("> ERROR: " .. err1)
		print("> " .. err2)
		return false
	end

	return true
end

-- Returns a string of batch commands to run based on the operating system, also returns error messages
function UpdateOrInstall.buildDownloadExtractCommand(tarUrl, archive, extractedFolder, isOnWindows)
	local messages = {
		downloading = "Downloading the latest Ironmon Tracker version.",
		extracting = "Extracting downloaded files.",
		error1 = "Unable to download or extract files from online release archive.",
	}

	local batchCommands = {}
	local pauseCommand

	local foldersToRemove = {
		string.format('%s.vscode', extractedFolder .. UpdateOrInstall.slash),
		string.format('%s.github', extractedFolder .. UpdateOrInstall.slash),
		string.format('%sironmon_tracker%sDebug', extractedFolder .. UpdateOrInstall.slash, UpdateOrInstall.slash),
	}
	local filesToRemove = {
		string.format('%s.editorconfig', extractedFolder .. UpdateOrInstall.slash),
		string.format('%s.gitattributes', extractedFolder .. UpdateOrInstall.slash),
		string.format('%s.gitignore', extractedFolder .. UpdateOrInstall.slash),
		string.format('%sREADME.md', extractedFolder .. UpdateOrInstall.slash),
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
		}
		if IronmonTracker.isOnBizhawk then -- Required because Bizhawk doesn't use absolute paths
			table.insert(batchCommands, string.format('tar -xzf "%s" --overwrite', archive))
		else
			table.insert(batchCommands, string.format('mkdir -p "%s"', extractedFolder))
			local linuxExtract = string.format('tar -xzf "%s" --overwrite -C "%s"', archive, IronmonTracker.workingDir)
			local macExtract = string.format('tar -xzf "%s" -C "%s"', archive, IronmonTracker.workingDir)
			table.insert(batchCommands, string.format("(%s || %s)", linuxExtract, macExtract))
		end
		table.insert(batchCommands, string.format('rm -rf "%s"', archive))

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
function UpdateOrInstall.buildCopyFilesCommand(extractedFolder, isOnWindows)
	local messages = {
		filesready = "New release files downloaded and ready for update.",
		updating = "Applying the update, copying over files.",
		completed = "Version update completed successfully.",
		error1 = "Unable to copy over and update Tracker files.",
		error2 = string.format('Try restarting the emulator and loading ONLY the "%s" script.', UpdateOrInstall.thisFileName),
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
		local destinationFolder
		if IronmonTracker.isOnBizhawk then
			destinationFolder = "." -- current directory
		else
			destinationFolder = IronmonTracker.workingDir
		end
		batchCommands = {
			string.format('echo %s', messages.filesready),
			string.format('echo %s', messages.updating),
			string.format('cp -fr "%s" "%s"', extractedFolder .. UpdateOrInstall.slash .. ".", destinationFolder),
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

-- In some cases, a user's computer setup or environment will prevent them from replacing currently loaded Tracker files
-- These checks must be done *after* the download, since existing old tracker code won't have this function
function UpdateOrInstall.verifyOkayToParallelUpdate(archiveFolderPath, isOnWindows)
	if Main == nil then -- Implies standalone update
		return true
	end

	if isOnWindows then
		-- Temporarily removing this check, as the parallel update is now only allowed after a Bizhawk restart
		-- COMMAND BREAKS: Usually OneDrive breaks this: string.format('xcopy "%s" /s /y /q', extractedFolder)
		-- local onedrivePattern = "([Oo][Nn][Ee][Dd][Rr][Ii][Vv][Ee])"
		-- if string.find(archiveFolderPath, onedrivePattern) ~= nil then
		-- 	return false, "Tracker files are inside a OneDrive folder and cannot be edited while Bizhawk is open."
		-- end

		-- Temporarily removing this check, as I think it's likely okay to allow. Want to do more testing here.
		-- FILEPATH BREAKS: Tracker located on a non-primary harddrive: e.g. D:\ or E:\
		-- local driveLetterPattern = "^(.).*"
		-- if string.match(archiveFolderPath, driveLetterPattern) ~= "C" then
		-- 	return false, "Tracker files are not on the primary harddrive C:\\ and cannot be edited while Bizhawk is open."
		-- end
	end

	return true
end

UpdateOrInstall.start()
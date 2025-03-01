CustomCode = {
	-- The number of currently installed extensions
	ExtensionCount = 0,

	-- When an extension's code errors, that is logged here and then printed.
	-- Future errors of the same message are not printed, to avoid cluttering the Lua Console.
	KnownErrors = {},

	-- Available extensions that are currently known about that are likely present in the 'extensions' folder
	-- Each 'key' is the filename of the extension
	-- Each 'value' contains a 'isEnabled', 'isLoaded', and the 'selfObject' which contains the extension's functions and attributes
	ExtensionLibrary = {},

	-- An ordered list of extensions (references to ExtensionLibrary list items) that are currently enabled
	-- Only extension present in this list are "enabled" and integrated into Tracker code
	EnabledExtensions = {},

	-- Additional helper functions for use with popular custom rom hacks and extensions
	RomHacks = {
		-- Known compatible extensions
		ExtensionKeys = {
			NatDex = "NatDexExtension",
			MoveExpansion = "MoveExpansionExtension", -- Phys/Special split, extra moves
			MAX = "MAXExtension", -- same as above but with extra abilities
		},
	},

	-- When installing/updating extensions, the below files and folders are removed after the release download and before copying over the files/folders
	DefaultFoldersToExclude = {
		-- Note: The download/extract command will fail if it tries to remove a folder that doesn't exist
	},
	DefaultFilenamesToExclude = {
		'.editorconfig',
		'.gitattributes',
		".gitignore",
		"README.md",
		"LICENSE",
	},
	-- The default release branch where extensions install/update from their respective GitHub repositories
	DefaultBranch = "main",
}

-- Returns true if the settings option for custom code extensions is enabled; false otherwise
function CustomCode.isEnabled()
	return Options["Enable custom extensions"]
end

function CustomCode.initialize()
	CustomCode.printedLoadedExts = false
	CustomCode.ExtensionCount = 0
	CustomCode.KnownErrors = {}
	CustomCode.EnabledExtensions = {}
	CustomCode.loadKnownExtensions()
end

-- Loads all installed extensions during Tracker startup. Known extensions are determined by Main.LoadSettings()
function CustomCode.loadKnownExtensions()
	local filesLoaded = {
		successful = {},
		failed = {},
	}

	-- Known extensions are loaded during Main.LoadSettings()
	for extensionKey, _ in pairs(CustomCode.ExtensionLibrary) do
		local loadedExtension = CustomCode.loadExtension(extensionKey)
		if loadedExtension ~= nil then
			-- If already enabled by user Settings.ini, enable it and call startup
			if loadedExtension.isEnabled then
				CustomCode.enableExtension(extensionKey)
			end

			-- An extension is successfully loaded if its 'selfObject' contains its properties and functions
			if loadedExtension.selfObject ~= nil then
				local extensionName = loadedExtension.selfObject.name or extensionKey
				table.insert(filesLoaded.successful, extensionName)
			end
		else
			CustomCode.disableExtension(extensionKey)
			CustomCode.ExtensionLibrary[extensionKey] = nil
			Main.RemoveMetaSetting("extensions", extensionKey)
			table.insert(filesLoaded.failed, extensionKey)
		end
	end

	CustomCode.ExtensionCount = #filesLoaded.successful

	if not Main.IsOnBizhawk() then
		MGBA.buildExtensionOptionMaps()
	end

	if not CustomCode.printedLoadedExts then
		if #filesLoaded.successful > 0 then
			table.sort(filesLoaded.successful, function(a, b) return a < b end)
			local listAsString = table.concat(filesLoaded.successful, ", ")
			print(string.format("> %s: %s", Resources.CustomCode.ExtensionsLoaded, listAsString))
		end
		-- For now, don't display old, uninstalled extension files that failed to load
		-- if #filesLoaded.failed > 0 then
		-- table.sort(filesLoaded.failed, function(a, b) return a < b end)
		-- 	local listAsString = table.concat(filesLoaded.failed, ", ")
		-- 	print(string.format("> %s: %s", Resources.CustomCode.ExtensionsMissing, listAsString))
		-- end
		CustomCode.printedLoadedExts = true
	end
end

-- Loads a single extension based on its key (filename) and returns it. Doesn't enable it by default
function CustomCode.loadExtension(extensionKey)
	if Utils.isNilOrEmpty(extensionKey) then
		return nil
	end

	local customCodeFolder = FileManager.getExtensionsFolderPath()
	local filepath = FileManager.getPathIfExists(customCodeFolder .. extensionKey .. FileManager.Extensions.LUA_CODE)

	if filepath == nil then
		return nil
	end

	-- Load the extension code
	local selfObject
	xpcall(function()
		local extensionReturnObject = dofile(filepath)
		if type(extensionReturnObject) == "function" then
			selfObject = extensionReturnObject() or {}
		elseif type(extensionReturnObject) == "table" then
			selfObject = extensionReturnObject
		end
	end, FileManager.logError)

	if selfObject == nil then
		print(string.format("> Error loading extension: %s, removing it from the extensions list.", extensionKey))
		return nil
	end

	-- Check for required attributes from the extension
	selfObject.name = Utils.formatSpecialCharacters(selfObject.name) or extensionKey
	selfObject.author = Utils.formatSpecialCharacters(selfObject.author) or "Unknown"
	selfObject.description = Utils.formatSpecialCharacters(selfObject.description) or ""
	selfObject.version = Utils.formatSpecialCharacters(selfObject.version) or "0.0"

	-- If the extension is new (not part of Settings.ini), create space for it
	if CustomCode.ExtensionLibrary[extensionKey] == nil then
		CustomCode.ExtensionLibrary[extensionKey] = {}
	end

	-- Keep known attributes of existing extension, replace others with newly loaded pieces
	local loadedExtension = CustomCode.ExtensionLibrary[extensionKey]
	loadedExtension.key = extensionKey
	loadedExtension.isEnabled = loadedExtension.isEnabled or false
	loadedExtension.isLoaded = true
	loadedExtension.selfObject = selfObject

	return loadedExtension
end

-- extensionName: the name of the custom extension found in the ExtensionLibrary
function CustomCode.enableExtension(extensionKey)
	local extension = CustomCode.ExtensionLibrary[extensionKey]
	if extension == nil then
		return
	end

	-- If something went wrong and the extension never properly loaded, disable it
	if extension.selfObject == nil then
		extension.isEnabled = false
		return
	end

	-- Add the extension to the EnabledExtensions list, allowing its functions to integrate into the Tracker
	table.insert(CustomCode.EnabledExtensions, extension)

	-- Enable and startup the extension
	if not extension.isEnabled then
		extension.isEnabled = true
		if CustomCode.isEnabled() and type(extension.selfObject["startup"]) == "function" then
			extension.selfObject.startup()
		end
	end
end

-- extensionName: the name of the custom extension found in the ExtensionLibrary
function CustomCode.disableExtension(extensionKey)
	local extension = CustomCode.ExtensionLibrary[extensionKey]
	if extension == nil then
		return
	end

	-- If something went wrong and the extension never properly loaded, disable it
	if extension.selfObject == nil then
		extension.isEnabled = false
		return
	end

	-- Disable and unload the extension
	if extension.isEnabled then
		extension.isEnabled = false
		if CustomCode.isEnabled() and type(extension.selfObject["unload"]) == "function" then
			extension.selfObject.unload()
		end
	end

	-- Remove the extension from the EnabledExtensions list, preventing its functions from being called
	local indexFound = -1
	for i, ext in ipairs(CustomCode.EnabledExtensions) do
		if ext.key == extensionKey then
			indexFound = i
			break
		end
	end
	if indexFound ~= -1 then
		table.remove(CustomCode.EnabledExtensions, indexFound)
	end
end

---Reloads an extension by turning it off, loading the extension's lua code file, and turning it back on
---@param extensionKey string
function CustomCode.reloadExtension(extensionKey)
	local extension = CustomCode.ExtensionLibrary[extensionKey or false]
	if not extension then
		return
	end
	Utils.tempDisableBizhawkSound()
	local extKey = extension.key
	local requiresReloading = extension.isLoaded
	if requiresReloading then
		if extension.selfObject and type(extension.selfObject["unload"]) == "function" then
			extension.selfObject.unload()
		end
	end
	CustomCode.loadExtension(extKey)
	if requiresReloading then
		local updatedExt = CustomCode.ExtensionLibrary[extKey or false] or {}
		if updatedExt.selfObject and type(updatedExt.selfObject["startup"]) == "function" then
			updatedExt.selfObject.startup()
		end
	end
	Utils.tempEnableBizhawkSound()
end

---Auto-updates the extension by downloading and installing the latest release
---@param extensionKey string The unique extension key, usually the filename of the extension
---@return boolean success
function CustomCode.updateExtension(extensionKey)
	local extension = CustomCode.ExtensionLibrary[extensionKey]
	if extension == nil then
		return false
	end
	local updateFuncOverride = extension.selfObject.downloadAndInstallUpdate
	if type(updateFuncOverride) == "function" then
		return updateFuncOverride()
	else
		return TrackerAPI.updateExtension(extensionKey)
	end
end

function CustomCode.refreshExtensionList()
	-- Used to help remove any inactive or missing extension files
	local installedExtensions = {}

	local customFolderPath = FileManager.getExtensionsFolderPath()
	local customFiles = FileManager.getFilesFromDirectory(customFolderPath)
	for _, filename in pairs(customFiles) do
		local name = FileManager.extractFileNameFromPath(filename) or ""
		local ext = FileManager.extractFileExtensionFromPath(filename) or ""
		ext = "." .. ext

		-- Load any new Lua code files, but only if they don't already exist
		if ext == FileManager.Extensions.LUA_CODE then
			if CustomCode.ExtensionLibrary[name] == nil then
				CustomCode.loadExtension(name)
			end
			installedExtensions[name] = true
		end
	end

	-- Recount the number of installed extensions
	CustomCode.ExtensionCount = 0

	for extensionKey, _ in pairs(CustomCode.ExtensionLibrary) do
		if installedExtensions[extensionKey] then
			CustomCode.ExtensionCount = CustomCode.ExtensionCount + 1
		else
			CustomCode.disableExtension(extensionKey)
			CustomCode.ExtensionLibrary[extensionKey] = nil
			Main.RemoveMetaSetting("extensions", extensionKey)
		end
	end

	collectgarbage()
	Main.SaveSettings(true)
end

---Checks all enabled extensions for version updates
---@return table extensions List of extensions that have an update available
function CustomCode.checkExtensionsForUpdates()
	-- Update check not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
		return {}
	end

	-- Build curl update commands for each enabled extension
	local extensionsToCheck = {}
	local extensionCommandParts = {}
	for _, extension in ipairs(CustomCode.EnabledExtensions) do
		local selfObj = extension.selfObject or {}
		local githubRepo
		if not Utils.isNilOrEmpty(selfObj.github) then
			githubRepo = selfObj.github
		elseif not Utils.isNilOrEmpty(selfObj.url) then
			githubRepo = string.match(selfObj.url, "github%.com%/([^%/]+%/[^%/]+)") -- Format: MyUsername/ExtensionRepo
		end
		if githubRepo then
			githubRepo = FileManager.trimSlash(githubRepo)
			local commandPart = string.format('"https://api.github.com/repos/%s/releases/latest" --ssl-no-revoke', githubRepo)
			table.insert(extensionsToCheck, extension)
			table.insert(extensionCommandParts, commandPart)
		end
	end
	if #extensionsToCheck == 0 then
		return {}
	end

	-- Execute a single curl command to check for updates for all those extensions
	local allCommandParts = table.concat(extensionCommandParts, " -: ")
	local versionCheckCommand = string.format('curl %s', allCommandParts)
	Utils.tempDisableBizhawkSound()
	local success, fileLines = FileManager.tryOsExecute(versionCheckCommand)
	Utils.tempEnableBizhawkSound()
	if not success then
		return {}
	end
	local response = table.concat(fileLines or {}, "\n")

	-- The below section determines which extensions need updating
	local function _formatVersionNumber(version)
		local _, count = string.gsub(version, "%.", "")
		-- Should be at least two period dividers (v1.2.3)
		if (2 - count) > 0 then
			return version .. string.rep(".0", 2 - count)
		end
		return version
	end
	-- Currently assumes the number of tag_names is the same as the number of extensions counted above
	local i = 1
	local extensionsToUpdate = {}
	for version in string.gmatch(response, '"tag_name":%s+"[^%d]+([%d%.]+)"') or {} do
		-- Parse version number from response
		local responseVersion = _formatVersionNumber(version)
		-- Determine version number from loaded extension
		local extension = extensionsToCheck[i] or {}
		local selfObj = extension.selfObject or {}
		if not Utils.isNilOrEmpty(selfObj.version) then
			local extVersion = _formatVersionNumber(selfObj.version)
			local requiresUpdate = Utils.isNewerVersion(responseVersion, extVersion)
			if requiresUpdate then
				table.insert(extensionsToUpdate, extension)
			end
		end
		i = i + 1
	end

	return extensionsToUpdate
end

---Internal code to download extension files from a Github and copy them over to the Tracker's `extensions` folder.
---Developers, refer to TrackerAPI for the supported update or install functions instead of using this one.
---@param githubRepoUrl string The repo url where their extension is hosted
---@param folderNamesToExclude? table Optional, list of downloaded folder names to remove from the release before copying over; default, refer to: CustomCode.DefaultFoldersToExclude
---@param fileNamesToExclude? table Optional, list of downloaded file names to remove from the release before copying over; default, refer to: CustomCode.DefaultFilenamesToExclude
---@param branchName? string Optional, defaults to the `main` branch: CustomCode.DefaultBranch
---@return boolean success
function CustomCode.downloadAndInstallExtensionFiles(githubRepoUrl, folderNamesToExclude, fileNamesToExclude, branchName)
	local tarUrl = FileManager.getTarDownloadUrl(githubRepoUrl, branchName)
	local tarArchiveName = FileManager.getTarDownloadArchiveName(githubRepoUrl, branchName)
	local archiveFolderPath = FileManager.prependDir(tarArchiveName)
	local archiveFilePath = archiveFolderPath .. FileManager.Extensions.TAR_GZ
	local destinationFolder = FileManager.getExtensionsFolderPath()
	local isOnWindows = Main.OS == "Windows"

	Utils.tempDisableBizhawkSound()

	-- Download and Extract the tar.gz release file from Github repo
	local downloadCommand, downloadErr1 = UpdateOrInstall.buildDownloadExtractCommand(
		tarUrl,
		archiveFilePath,
		archiveFolderPath,
		isOnWindows,
		folderNamesToExclude or CustomCode.DefaultFoldersToExclude or {},
		fileNamesToExclude or CustomCode.DefaultFilenamesToExclude or {}
	)
	local downloadResult = os.execute(downloadCommand)
	if not (downloadResult == true or downloadResult == 0) then -- true / 0 = successful
		Utils.tempEnableBizhawkSound()
		print("> ERROR: " .. tostring(downloadErr1))
		print("> URL: " .. tostring(githubRepoUrl))
		return false
	end

	-- Copy over extract files to the Tracker's extension folder
	local copyCommand, copyErr1, copyErr2 = UpdateOrInstall.buildCopyFilesCommand(
		archiveFolderPath,
		isOnWindows,
		destinationFolder
	)
	local copyResult = os.execute(copyCommand)
	if not (copyResult == true or copyResult == 0) then -- true / 0 = successful
		print("> WARNING: " .. tostring(copyErr1))
		print("> " .. tostring(copyErr2))
		-- Always succeed (return true) now that the new XCOPY succeeds regardless of error
	end

	Utils.tempEnableBizhawkSound()

	return true
end

-- Simulates an interface-like function execution for custom code files
function CustomCode.execFunctions(funcLabel, ...)
	if not CustomCode.isEnabled() then return end

	for _, ext in ipairs(CustomCode.EnabledExtensions) do
		local functToExec = ext.selfObject[funcLabel]
		if type(functToExec) == "function" then
			local params = ...
			local funcWithParams = function() functToExec(params) end
			CustomCode.tryExecute(ext.selfObject.name, funcLabel, funcWithParams)
		end
	end
end

function CustomCode.tryExecute(extensionKey, functionLabel, functToExec)
	CustomCode.extBeingExecuted = extensionKey
	CustomCode.funcBeingExecuted = functionLabel
	local result = xpcall(functToExec, CustomCode.logError)
	CustomCode.extBeingExecuted = nil
	CustomCode.funcBeingExecuted = nil
	return result
end

function CustomCode.logError(err)
	err = tostring(err)
	local errorMessage
	if CustomCode.extBeingExecuted ~= nil or CustomCode.funcBeingExecuted ~= nil then
		errorMessage = string.format("[%s:%s] %s", CustomCode.extBeingExecuted or "", CustomCode.funcBeingExecuted or "", err)
	else
		errorMessage = string.format("[ERROR] %s", err)
	end

	if not CustomCode.KnownErrors[errorMessage] then
		CustomCode.KnownErrors[errorMessage] = true
		FileManager.logError(errorMessage)
	end
end

---Checks if the rom loaded is a supported rom hack, and if so loads additional code for it
function CustomCode.checkForRomHacks()
	local GS = GameSettings
	-- For NatDex v1.1.3 and lower, it did not have these addresses for the new Trainers lookup feature
	if CustomCode.RomHacks.isNatDexVersionOrLower("1.1.3") then
		GS.gLevelUpLearnsets = GS.gLevelUpLearnsets_NatDex_113 or GS.gLevelUpLearnsets
		GS.gTrainers = GS.gTrainers_NatDex_113 or GS.gTrainers
		GS.gTrainerClassNames = GS.gTrainerClassNames_NatDex_113 or GS.gTrainerClassNames
		GS.gLockedMoves = GS.gLockedMoves_NatDex_113 or GS.gLockedMoves
		GS.gSideStatuses = GS.gSideStatuses_NatDex_113 or GS.gSideStatuses
		GS.gSideTimers = GS.gSideTimers_NatDex_113 or GS.gSideTimers
		GS.gStatuses3 = GS.gStatuses3_NatDex_113 or GS.gStatuses3
		GS.gDisableStructs = GS.gDisableStructs_NatDex_113 or GS.gDisableStructs
		GS.gPaydayMoney = GS.gPaydayMoney_NatDex_113 or GS.gPaydayMoney
		GS.gWishFutureKnock = GS.gWishFutureKnock_NatDex_113 or GS.gWishFutureKnock
	end
end

---Returns true if the rom loaded is NatDex modified, and the extension is enabled and running
---@return boolean
function CustomCode.RomHacks.isPlayingNatDex()
	local EXT_KEY = CustomCode.RomHacks.ExtensionKeys.NatDex
	if not TrackerAPI.isExtensionEnabled(EXT_KEY) then
		return false
	end
	-- The NatDex extension has a built-in method for checking if it's being used
	local extension = TrackerAPI.getExtensionSelf(EXT_KEY) or {}
	return type(extension.checkIfNatDexROM) == "function" and extension:checkIfNatDexROM()
end

---Returns true if the NatDex rom and extension are of a specific version or lower (for checking compatibility)
---@param version string Example: 1.1.3
---@return boolean
function CustomCode.RomHacks.isNatDexVersionOrLower(version)
	if not CustomCode.RomHacks.isPlayingNatDex() then
		return false
	end
	local EXT_KEY = CustomCode.RomHacks.ExtensionKeys.NatDex
	local extension = TrackerAPI.getExtensionSelf(EXT_KEY) or {}
	return not Utils.isNewerVersion(extension.version or "0.0.0", version)
end

---Returns true if the rom loaded is MoveExpansion modified, and the extension is enabled and running
---@return boolean
function CustomCode.RomHacks.isPlayingMoveExpansion()
	local EXT_KEY = CustomCode.RomHacks.ExtensionKeys.MoveExpansion
	if not TrackerAPI.isExtensionEnabled(EXT_KEY) then
		return false
	end
	-- Have to manually check added data to determine if Move Expansion extension is in use
	return MoveData.Moves[355] ~= nil and MoveData.Moves[356] ~= nil
end

---Returns true if the rom loaded is MAX modified, and the extension is enabled and running
---@return boolean
function CustomCode.RomHacks.isPlayingMAX()
	local EXT_KEY = CustomCode.RomHacks.ExtensionKeys.MAX
	if not TrackerAPI.isExtensionEnabled(EXT_KEY) then
		return false
	end
	-- Have to manually check added data to determine if Move Expansion extension is in use
	return MoveData.Moves[355] ~= nil and MoveData.Moves[356] ~= nil
end

--------------------------------------------------------------------------------------------------
-- Avoid modifying anything below this line if possible, so that extensions remain upgrade safe --
--------------------------------------------------------------------------------------------------

-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
function CustomCode.startup()
	CustomCode.execFunctions("startup")
end

-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
function CustomCode.unload()
	CustomCode.execFunctions("unload")
end

-- [Bizhawk only] Executed each frame (60 frames per second)
-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
function CustomCode.inputCheckBizhawk()
	if not Main.IsOnBizhawk() then return end
	CustomCode.execFunctions("inputCheckBizhawk")
end

-- [MGBA only] Executed each frame (60 frames per second)
-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
function CustomCode.inputCheckMGBA()
	if Main.IsOnBizhawk() then return end
	CustomCode.execFunctions("inputCheckMGBA")
end

-- Executed each frame, after most data from game memory is read in but before any natural redraw events occur
-- CAUTION: Avoid code here if possible, as this can easily affect performance. Most Tracker updates occur at 30-frame intervals, some at 10-frame.
function CustomCode.afterEachFrame()
	CustomCode.execFunctions("afterEachFrame")
end

-- Executed once every 30 frames, after most data from game memory is read in
function CustomCode.afterProgramDataUpdate()
	CustomCode.execFunctions("afterProgramDataUpdate")
end

-- Executed once every 30 frames, after any battle-related data from game memory is read in
function CustomCode.afterBattleDataUpdate()
	CustomCode.execFunctions("afterBattleDataUpdate")
end

-- Executed once every 30 frames or after any redraw event is scheduled (e.g. most button presses)
function CustomCode.afterRedraw()
	CustomCode.execFunctions("afterRedraw")
end

-- Executed after a new battle begins (wild or trainer), and only once per battle
function CustomCode.afterBattleBegins()
	CustomCode.execFunctions("afterBattleBegins")
end

-- Executed after a battle ends, and only once per battle
function CustomCode.afterBattleEnds()
	CustomCode.execFunctions("afterBattleEnds")
end

-- Executed before a button's onClick() is processed, and only once per click per button
-- Param: button: the button object being clicked
function CustomCode.onButtonClicked(button)
	CustomCode.execFunctions("onButtonClicked", button)
end

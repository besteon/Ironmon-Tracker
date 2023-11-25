CustomCode = {
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
}

-- Returns true if the settings option for custom code extensions is enabled; false otherwise
function CustomCode.isEnabled()
	return Options["Enable custom extensions"]
end

function CustomCode.initialize()
	CustomCode.KnownErrors = {}
	CustomCode.EnabledExtensions = {}

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

	if #filesLoaded.successful > 0 then
		local listAsString = table.concat(filesLoaded.successful, ", ")
		print(string.format("%s: %s", Resources.CustomCode.ExtensionsLoaded, listAsString))
	end
	-- For now, don't display old extension files that failed to load
	-- if #filesLoaded.failed > 0 then
	-- 	local listAsString = table.concat(filesLoaded.failed, ", ")
	-- 	print(string.format("%s: %s", Resources.CustomCode.ExtensionsMissing, listAsString))
	-- end
end

-- Loads a single extension based on its key (filename) and returns it. Doesn't enable it by default
function CustomCode.loadExtension(extensionKey)
	if Utils.isNilOrEmpty(extensionKey) then
		return nil
	end

	local customCodeFolder = FileManager.getCustomFolderPath()
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
		if ext.selfObject.name == extension.selfObject.name then
			indexFound = i
			break
		end
	end
	if indexFound ~= -1 then
		table.remove(CustomCode.EnabledExtensions, indexFound)
	end
end

function CustomCode.refreshExtensionList()
	-- Used to help remove any inactive or missing extension files
	local activeExtensions = {}

	local customFolderPath = FileManager.getCustomFolderPath()
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
			activeExtensions[name] = true
		end
	end

	for extensionKey, _ in pairs(CustomCode.ExtensionLibrary) do
		if not activeExtensions[extensionKey] then
			CustomCode.disableExtension(extensionKey)
			CustomCode.ExtensionLibrary[extensionKey] = nil
			Main.RemoveMetaSetting("extensions", extensionKey)
		end
	end
	collectgarbage()

	Main.SaveSettings(true)
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

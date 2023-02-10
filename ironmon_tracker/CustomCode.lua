CustomCode = {
	Labels = {
		filesLoadSuccess = "Extensions Loaded",
		filesLoadFailure = "Extensions Missing",
		unknownAuthor = "Unknown",
	},

	-- Available extensions that are currently known about that are likely present in the 'extensions' folder
	-- Each 'key' is the filename of the extension
	-- Each 'value' contains a 'isEnabled', 'isLoaded', and the 'selfObject' which contains the extension's functions and attributes
	ExtensionLibrary = {},

	-- An ordered list of extensions (references to ExtensionLibrary list items) that are currently enabled
	-- Only extension present in this list are "enabled" and integrated into Tracker code
	EnabledExtensions = {},
}

function CustomCode.initialize()
	local filesLoaded = {
		successful = {},
		failed = {},
	}

	CustomCode.EnabledExtensions = {}
	for extensionKey, _ in pairs(CustomCode.ExtensionLibrary) do
		local loadedExtension = CustomCode.loadExtension(extensionKey)
		if loadedExtension ~= nil then
			if loadedExtension.isEnabled and loadedExtension.selfObject ~= nil then
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
		print(string.format("%s: %s", CustomCode.Labels.filesLoadSuccess, table.concat(filesLoaded.successful, ", ")))
	end
	-- For now, don't display old extension files that failed to load
	-- if #filesLoaded.failed > 0 then
	-- 	print(string.format("%s: %s", CustomCode.Labels.filesLoadFailure, table.concat(filesLoaded.failed, ", ")))
	-- end
end

-- Loads a single extension based on its key (filename) and returns it; if load fails, returns nil
function CustomCode.loadExtension(extensionKey)
	if extensionKey == nil or extensionKey == "" then
		return nil
	end

	local customCodeFolder = FileManager.getCustomFolderPath()
	local filepath = FileManager.getPathIfExists(customCodeFolder .. extensionKey .. FileManager.Extensions.LUA_CODE)

	if filepath == nil then
		return nil
	end

	-- Load the extension code
	local extensionReturnObject = dofile(filepath)
	local selfObject
	if type(extensionReturnObject) == "function" then
		selfObject = extensionReturnObject() or {}
	elseif type(extensionReturnObject) == "table" then
		selfObject = extensionReturnObject
	end

	if selfObject == nil then
		return nil
	end

	-- Check for required attributes from the extension
	selfObject.name = selfObject.name or extensionKey
	selfObject.author = selfObject.author or CustomCode.Labels.unknownAuthor
	selfObject.description = selfObject.description or ""
	selfObject.version = selfObject.version or "0.0"

	-- If the extension is new (not part of Settings.ini), create space for it
	if CustomCode.ExtensionLibrary[extensionKey] == nil then
		CustomCode.ExtensionLibrary[extensionKey] = {}
	end

	-- Keep known attributes of existing extension, replace others with newly loaded pieces
	local extensionToLoad = CustomCode.ExtensionLibrary[extensionKey]
	extensionToLoad.isEnabled = extensionToLoad.isEnabled or false
	extensionToLoad.isLoaded = true
	extensionToLoad.selfObject = selfObject

	-- If already enabled by user Settings.ini, enable it and call startup
	if extensionToLoad.isEnabled then
		CustomCode.enableExtension(extensionKey)
	end

	return extensionToLoad
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

	-- Enable and startup the extension
	if not extension.isEnabled then
		extension.isEnabled = true
		if CustomCode.isEnabled() and type(extension.selfObject["startup"]) == "function" then
			extension.selfObject.startup()
		end
	end

	-- Add the extension to the EnabledExtensions list, allowing its functions to integrate into the Tracker
	table.insert(CustomCode.EnabledExtensions, extension)
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

-- Simulates an interface-like function execution for custom code files
function CustomCode.execFunctions(func, ...)
	for _, ext in ipairs(CustomCode.EnabledExtensions) do
		local functToExec = ext.selfObject[func]
		if type(functToExec) == "function" then
			functToExec(...)
		end
	end
end

-- Returns true if the settings option for custom code extensions is enabled; false otherwise
function CustomCode.isEnabled()
	return Options["Enable custom extensions"]
end

--------------------------------------------------------------------------------------------------
-- Avoid modifying anything below this line if possible, so that extensions remain upgrade safe --
--------------------------------------------------------------------------------------------------

-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
function CustomCode.startup()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("startup")
end

-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
function CustomCode.unload()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("unload")
end

-- [Bizhawk only] Executed each frame (60 frames per second)
-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
function CustomCode.inputCheckBizhawk()
	if not CustomCode.isEnabled() or not Main.IsOnBizhawk() then return end
	CustomCode.execFunctions("inputCheckBizhawk")
end

-- [MGBA only] Executed each frame (60 frames per second)
-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
function CustomCode.inputCheckMGBA()
	if not CustomCode.isEnabled() or Main.IsOnBizhawk() then return end
	CustomCode.execFunctions("inputCheckMGBA")
end

-- Executed each frame, after most data from game memory is read in but before any natural redraw events occur
-- CAUTION: Avoid code here if possible, as this can easily affect performance. Most Tracker updates occur at 30-frame intervals, some at 10-frame.
function CustomCode.afterEachFrame()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("afterEachFrame")
end

-- Executed once every 30 frames, after most data from game memory is read in
function CustomCode.afterProgramDataUpdate()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("afterProgramDataUpdate")
end

-- Executed once every 30 frames, after any battle-related data from game memory is read in
function CustomCode.afterBattleDataUpdate()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("afterBattleDataUpdate")
end

-- Executed once every 30 frames or after any redraw event is scheduled (e.g. most button presses)
function CustomCode.afterRedraw()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("afterRedraw")
end

-- Executed after a new battle begins (wild or trainer), and only once per battle
function CustomCode.afterBattleBegins()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("afterBattleBegins")
end

-- Executed after a battle ends, and only once per battle
function CustomCode.afterBattleEnds()
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("afterBattleEnds")
end

-- Executed before a button's onClick() is processed, and only once per click per button
-- Param: button: the button object being clicked
function CustomCode.onButtonClicked(button)
	if not CustomCode.isEnabled() then return end
	CustomCode.execFunctions("onButtonClicked", button)
end

CustomCode = {
	Labels = {
		filesLoadSuccess = "Extensions Loaded",
		filesLoadFailure = "Extensions Missing",
		unknownAuthor = "Unknown",
	},

	-- Available extensions that are currently known about that are likely present in the 'Custom' folder
	ExtensionLibrary = {
		--[[ -- Example extension entry below, "FileName" omits the file extension ".lua"
			["FileName"] = {
				isEnabled = false, -- If the user has enabled or disabled this extension
				isLoaded = false, -- If the extension file was found and successfully loaded
				name = "My Extension",
				author = "My Username",
				description = "Lorem Ipsum",
			},
		]]
	},

	-- An ordered list of extensions that are currently enabled, with Tracker code integrations
	EnabledExtensions = {},
}

function CustomCode.initialize()
	local filesLoaded = {
		successful = {},
		failed = {},
	}

	CustomCode.EnabledExtensions = {}
	for extensionKey, extension in pairs(CustomCode.ExtensionLibrary) do
		if CustomCode.loadExtension(extensionKey) then
			if extension.isEnabled then
				local extensionName = CustomCode.ExtensionLibrary[extensionKey].name -- loop value changes from the load
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

-- Loads a single extension based on its key (filename)
function CustomCode.loadExtension(extensionKey)
	if extensionKey == nil or extensionKey == "" then return end

	if CustomCode.ExtensionLibrary[extensionKey] == nil then
		CustomCode.ExtensionLibrary[extensionKey] = {}
	end
	local extension = CustomCode.ExtensionLibrary[extensionKey]
	extension.isEnabled = extension.isEnabled or false

	local customCodeFolder = FileManager.getCustomFolderPath()
	local filepath = FileManager.getPathIfExists(customCodeFolder .. extensionKey .. FileManager.Extensions.LUA_CODE)

	if filepath ~= nil then
		local extObj = dofile(filepath)
		local extTable
		if type(extObj) == "function" then
			extTable = extObj() or {}
		elseif type(extObj) == "table" then
			extTable = extObj
		end

		if extTable ~= nil then
			-- Replace any matching extension with the newly loaded one
			extTable.isEnabled = extension.isEnabled
			extTable.isLoaded = true
			extTable.name = extTable.name or extensionKey
			extTable.author = extTable.author or CustomCode.Labels.unknownAuthor
			extTable.description = extTable.description or ""
			CustomCode.ExtensionLibrary[extensionKey] = extTable

			if extTable.isEnabled then -- If already enabled by user Settings.ini, enable it and call startup
				CustomCode.enableExtension(extensionKey)
			end
			return true
		end
	end

	if not extension.isLoaded then
		extension.isLoaded = false
		extension.name = extensionKey
		extension.author = CustomCode.Labels.unknownAuthor
		extension.description = ""
	end

	return extension.isLoaded
end

-- extensionName: the name of the custom extension found in the ExtensionLibrary
function CustomCode.enableExtension(extensionKey)
	local extension = CustomCode.ExtensionLibrary[extensionKey]
	if extension == nil then
		return
	end

	-- Enable and startup the extension
	if not extension.isEnabled then
		extension.isEnabled = true
		if CustomCode.isEnabled() and type(extension["startup"]) == "function" then
			extension.startup()
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

	-- Disable and unload the extension
	if extension.isEnabled then
		extension.isEnabled = false
		if CustomCode.isEnabled() and type(extension["unload"]) == "function" then
			extension.unload()
		end
	end

	-- Remove the extension from the EnabledExtensions list, preventing its functions from being called
	local indexFound = -1
	for i, ext in ipairs(CustomCode.EnabledExtensions) do
		if ext.name == extension.name then
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
	for _, obj in ipairs(CustomCode.EnabledExtensions) do
		local functToExec = obj[func]
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

-- Executed only once: when the Tracker finishes starting up and after it loads all other required files and code
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

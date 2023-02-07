----------------------------------------------------------------------------------------------
-- Avoid modifying this file if at all possible, so that customizations remain upgrade safe --
----------------------------------------------------------------------------------------------
CustomCode = {
	-- To enable custom code to be run by the Tracker, set to 'true'; or set to 'false' to disable all custom code
	enabled = false,
	-- A list of custom code files to load, each should match the Custom Code template and return an object with functions
	filenames = {},

	Labels = {
		filesLoadSuccess = "Custom Code files loaded",
		filesLoadFailure = "Failed to load",
	},
}

function CustomCode.initialize()
	local customCodeFolder = FileManager.getCustomFolderPath()
	local filepath = FileManager.getPathIfExists(customCodeFolder .. FileManager.Files.CUSTOM_CODE_SETTINGS)
	if filepath ~= nil then
		local settingsObj = dofile(filepath)
		local settings = {}
		if type(settingsObj) == "function" then
			settings = settingsObj() or {}
		end

		CustomCode.enabled = (settings.enabled == true)
		CustomCode.filenames = settings.filenames or {}

		if #CustomCode.filenames == 0 then
			CustomCode.enabled = false
		end
	else
		-- Silently fail, as this means the custom code add-on wasn't installed or in use
	end
end

-- Simulates an interface-like function execution for custom code files
function CustomCode.execFunctions(func, ...)
	for _, obj in ipairs(CustomCode.objects) do
		local functToExec = obj[func]
		if type(functToExec) == "function" then
			functToExec(...)
		end
	end
end

-- Executed only once: when the Tracker finishes starting up and after it loads all other required files and code
function CustomCode.startup()
	CustomCode.objects = {}
	local customCodeFolder = FileManager.getCustomFolderPath()
	local filesLoaded = {
		successful = {},
		failed = {},
	}

	for _, filename in ipairs(CustomCode.filenames) do
		local filepath = FileManager.getPathIfExists(customCodeFolder .. filename)
		if filepath ~= nil then
			local customObject = dofile(filepath)
			if type(customObject) == "function" then
				table.insert(CustomCode.objects, customObject() or {})
			elseif type(customObject) == "table" then
				table.insert(CustomCode.objects, customObject)
			end
			table.insert(filesLoaded.successful, filename)
		else
			table.insert(filesLoaded.failed, filename)
		end
	end

	if #filesLoaded.successful > 0 then
		print(string.format("%s: %s", CustomCode.Labels.filesLoadSuccess, table.concat(filesLoaded.successful, ", ")))
	end
	if #filesLoaded.failed > 0 then
		print(string.format("%s: %s", CustomCode.Labels.filesLoadFailure, table.concat(filesLoaded.failed, ", ")))
	end

	CustomCode.execFunctions("startup")
end

-- [Bizhawk only] Executed each frame (60 frames per second)
-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
function CustomCode.inputCheckBizhawk()
	CustomCode.execFunctions("inputCheckBizhawk")
end

-- [MGBA only] Executed each frame (60 frames per second)
-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
function CustomCode.inputCheckMGBA()
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

-- Executed before a button is clicked, and only once per button
-- button: the button object being clicked
function CustomCode.beforeButtonClicked(button)
	CustomCode.execFunctions("beforeButtonClicked", button)
end
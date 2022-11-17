-- This file is the first file loaded by Bizhawk.
-- This file is NOT automatically updated live during Tracker auto-updates; requires Bizhawk restart
-- Ideally this file should be as small as possible, and should not contain important code that requires maintaining
IronmonTracker = {
	folderPath = '',
	mainFile = 'ironmon_tracker/Main.lua',
}

-- Loads/reloads most of the Tracker scripts (except this single script loaded into Bizhawk)
function IronmonTracker.startTracker()
	-- Required garbage collection to release old Tracker files after an auto-update
	collectgarbage()

	-- Redefine Lua print function to be compatible with outputting to mGBA's scripting console
	print = function(...)
		console:log(...)
	end

	-- Only continue with starting up the Tracker if the 'Main' script was able to be loaded
	if IronmonTracker.tryLoad() then
		-- Then verify the remainder of the Tracker files were able to be setup and initialized
		if Main.Initialize() then
			Main.Run()
		end
	end
end

-- Returns true if it's able to successfully load the Main tracker file; false otherwise
function IronmonTracker.tryLoad()
	print("\n----- ----- ----- ----- ----- -----")
	print("\nLoading Ironmon-Tracker (Gen 3)...")

	local file = io.open(IronmonTracker.folderPath .. IronmonTracker.mainFile, "r")
	if file == nil then
		-- Get the current working directory of the Tracker script
		local pathLookup = debug.getinfo(2, "S").source:sub(2)
		IronmonTracker.folderPath = pathLookup:match("(.*[/\\])") or ""

		file = io.open(IronmonTracker.folderPath .. IronmonTracker.mainFile, "r")
		if file == nil then
			print('Error starting up the Tracker: Unable to load all of the required Tracker files.')
			print('> The "Ironmon-Tracker.lua" script file should be in the same folder as the other Tracker files that came with the release download.')
			return false
		end
	end
	io.close(file)

	-- Load the Main Tracker script which will setup all the other files
	dofile(IronmonTracker.folderPath .. IronmonTracker.mainFile)

	return true
end

IronmonTracker.startTracker()
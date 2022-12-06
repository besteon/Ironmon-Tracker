-- This file is the first file loaded by Bizhawk or mGBA.
-- This file is NOT automatically updated live during Tracker auto-updates; requires Bizhawk restart
-- Ideally this file should be as small as possible, and should not contain important code that requires maintaining
IronmonTracker = {
	workingDir = '',
	mainFile = 'ironmon_tracker/Main.lua',
	trackerLabel = '',
}

-- Loads/reloads most of the Tracker scripts (except this single script loaded into Bizhawk)
function IronmonTracker.startTracker()
	-- Required garbage collection to release old Tracker files after an auto-update
	collectgarbage()

	IronmonTracker.setupEmulatorSpecifics()
	IronmonTracker.displayWelcomeMessage()

	-- Only continue with starting up the Tracker if the 'Main' script was able to be loaded
	if IronmonTracker.tryLoad() then
		-- Then verify the remainder of the Tracker files were able to be setup and initialized
		if Main.Initialize() then
			Main.Run()
		end
	end
end

function IronmonTracker.setupEmulatorSpecifics()
	-- Get the current working directory of the Tracker script
	local pathLookup = debug.getinfo(2, "S").source:sub(2)
	IronmonTracker.workingDir = pathLookup:match("(.*[/\\])") or ""

	-- Redefine Lua print function to be compatible with outputting to mGBA's scripting console
	if console.createBuffer == nil then -- This function doesn't exist in Bizhawk, only mGBA
		IronmonTracker.trackerLabel = "Bizhawk (Gen 3)"
		print = function(...) console.log(...) end
		console.clear()
	else
		IronmonTracker.trackerLabel = "mGBA (lite edition)"
		print = function(...) console:log(...) end
		print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") -- This "clears" the Console for mGBA
	end
end

function IronmonTracker.displayWelcomeMessage()
	print(string.format("Loading Ironmon Tracker for %s", IronmonTracker.trackerLabel))
end

-- Returns true if it's able to successfully load the Main tracker file; false otherwise
function IronmonTracker.tryLoad()
	-- Verify the Main.lua Tracker file exists
	local file = io.open(IronmonTracker.workingDir .. IronmonTracker.mainFile, "r")
	if file == nil then
		print('>> Error starting up the Tracker: Unable to load all of the required Tracker files.')
		print('>> The "Ironmon-Tracker.lua" script file should be in the same folder as the other Tracker files that came with the release download.')
		return false
	end
	io.close(file)

	-- Load the Main Tracker script which will setup all the other files
	dofile(IronmonTracker.workingDir .. IronmonTracker.mainFile)
	return true
end

IronmonTracker.startTracker()
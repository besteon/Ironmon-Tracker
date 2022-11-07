-- This file is the first file loaded by Bizhawk.
-- This file is *not* automatically updated live during Tracker auto-updates; requires Bizhawk restart
-- Ideally this file should be as small as possible, and should not contain important code that requires maintaining
IronmonTracker = {}

-- Returns true if it's able to successfully load the Main tracker file; false otherwise
function IronmonTracker.tryLoad()
	-- Clearing the console for each new game helps with troubleshooting issues
	console.clear()
	print("\nLoading Ironmon-Tracker (Gen 3)...")

	local mainFilename = "ironmon_tracker/Main.lua"

	local file = io.open(mainFilename, "r")
	if file == nil then
		print('Error starting up the Tracker: Unable to load all of the required Tracker files.')
		print('> The "Ironmon-Tracker.lua" script file should be in the same folder as the other Tracker files that came with the release download.')
		return false
	end
	io.close(file)

	-- Load the Main Tracker script which will setup all the other files
	dofile(mainFilename)

	return true
end

-- Only continue with starting up the Tracker if the 'Main' script was able to be loaded
if IronmonTracker.tryLoad() then
	-- Then verify the remainder of the Tracker files were able to be setup and initialized
	if Main.Initialize() then
		Main.Run()
	end
end
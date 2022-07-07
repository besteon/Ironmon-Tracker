-- IronMon Tracker
-- Created by besteon, based on the PokemonBizhawkLua project by MKDasher

-- The latest version of the tracker. Should be updated with each PR.
TRACKER_VERSION = "0.4.2d"

-- A frequently used placeholder when a data field is not applicable
PLACEHOLDER = "---" -- TODO: Consider moving into a better global constant location? Placed here for now to ensure it is available to all subscripts.

print("\nIronmon-Tracker v" .. TRACKER_VERSION)

-- Check the version of BizHawk that is running
-- Need to also check that client.getversion is an existing function, older Bizhawk versions don't have it
if client.getversion == nil or (client.getversion() ~= "2.8" and client.getversion() ~= "2.9") then
	print("This version of BizHawk is not supported. Please update to version 2.8 or higher.")
	-- Bounce out... Don't pass Go! Don't collect $200.
	return
end

-- Root folder for the project data and sub scripts
DATA_FOLDER = "ironmon_tracker"

-- Get the user settings saved on disk and create the base Settings object
INI = dofile(DATA_FOLDER .. "/Inifile.lua")
-- Need to manually read the file to work around a bug in the ini parser, which
-- does not correctly handle that the last iteration over lines() returns nil
local file = io.open("Settings.ini")
if file ~= nil then
	Settings = INI.parse(file:read("*a"), "memory")
	io.close(file)
end

-- Import all scripts before starting the main loop
dofile(DATA_FOLDER .. "/PokemonData.lua")
dofile(DATA_FOLDER .. "/MoveData.lua")
dofile(DATA_FOLDER .. "/Data.lua")
dofile(DATA_FOLDER .. "/Memory.lua")
dofile(DATA_FOLDER .. "/GameSettings.lua")
dofile(DATA_FOLDER .. "/GraphicConstants.lua")
dofile(DATA_FOLDER .. "/Options.lua")
dofile(DATA_FOLDER .. "/Theme.lua")
dofile(DATA_FOLDER .. "/ColorPicker.lua")
dofile(DATA_FOLDER .. "/Utils.lua")
dofile(DATA_FOLDER .. "/Buttons.lua")
dofile(DATA_FOLDER .. "/Input.lua")
dofile(DATA_FOLDER .. "/Drawing.lua")
dofile(DATA_FOLDER .. "/Program.lua")
dofile(DATA_FOLDER .. "/Pickle.lua")
dofile(DATA_FOLDER .. "/Tracker.lua")

Main = {}
Main.LoadNextSeed = false

-- Main loop
function Main.Run()
	print("Waiting for ROM to be loaded...")
	local romLoaded = false
	while not romLoaded do
		if gameinfo.getromname() ~= "Null" then romLoaded = true end
		emu.frameadvance()
	end

	-- print("Gamecode: " .. string.format("%x", memory.read_u32_be(0x0000AC, "ROM")) .. ", Game Version: " .. string.format("%x", memory.read_u32_be(0x0000BC, "ROM")))

	Options.buildTrackerOptionsButtons()
	Options.loadOptions()
	Theme.buildTrackerThemeButtons()
	Theme.loadTheme()

	GameSettings.initialize()
	if GameSettings.game == 0 then
		client.SetGameExtraPadding(0, 0, 0, 0)
		while true do
			gui.text(0, 0, "Lua error: " .. GameSettings.gamename)
			emu.frameadvance()
		end
	else
		Tracker.loadData()
		Buttons.initializeBadgeButtons()

		client.SetGameExtraPadding(0, GraphicConstants.UP_GAP, GraphicConstants.RIGHT_GAP, GraphicConstants.DOWN_GAP)
		gui.defaultTextBackground(0)

		event.onloadstate(Tracker.loadData, "OnLoadState")

		-- Removed all event watches to improve performances. Most have workarounds.
		
		event.onexit(Program.HandleExit, "HandleExit")

		while Main.LoadNextSeed == false do
			Program.main()
			emu.frameadvance()
		end

		Main.LoadNext()
	end
end

function Main.LoadNext()
	userdata.clear()
	Tracker.Clear() -- clear tracker data so it doesn't carry over to the next seed
	print("Loading the next ROM. Tracker data has reset.")

	if Settings.config.ROMS_FOLDER == nil or Settings.config.ROMS_FOLDER == "" then
		print("ROMS_FOLDER unspecified. Set this in the Tracker's options menu, or the Settings.ini file, to automatically switch ROM.")
		Main.CloseROM()
	end

	local romname = gameinfo.getromname()
	
	-- Split the ROM name into its prefix and numerical values
	local romprefix = string.match(romname, '[^0-9]+')
	local romnumber = string.match(romname, '[0-9]+')
	if romprefix == nil then romprefix = "" end

	if romnumber == nil then
		print("Unable to load next ROM file: no numbers in current ROM name.\nClosing current ROM: " .. romname)
		Main.CloseROM()
	end

	-- Increment to the next ROM and determine its full file path
	local nextromname = string.format(romprefix .. "%0" .. string.len(romnumber) .. "d", romnumber + 1)
	local nextrompath = Settings.config.ROMS_FOLDER .. "/" .. nextromname .. ".gba"

	-- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
	local filecheck = io.open(nextrompath,"r")
	if filecheck ~= nil then
		-- This means the file exists, so proceed with opening it.
		io.close(filecheck)
	else
		nextromname = nextromname:gsub(" ", "_")
		nextrompath = Settings.config.ROMS_FOLDER .. "/" .. nextromname .. ".gba"
		filecheck = io.open(nextrompath,"r")
		if filecheck == nil then
			-- This means there doesn't exist a ROM file with spaces or underscores
			print("Unable to locate next ROM file to load.\nClosing current ROM: " .. romname)
			Main.CloseROM()
		else
			io.close(filecheck)
		end
	end

	client.SetSoundOn(false)
	if client.getversion() ~= "2.9" then
		client.closerom() -- This appears to not be needed for Bizhawk 2.9+
	end
	print("ROM Loaded: " .. nextromname)
	client.openrom(nextrompath)
	client.SetSoundOn(true)
	Main.LoadNextSeed = false
	Main.Run()
end

function Main.CloseROM()
	if gameinfo.getromname() ~= "Null" then
		client.closerom()
		Main.LoadNextSeed = false
		Main.Run()
	end
end

Main.Run()

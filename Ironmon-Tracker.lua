-- IronMon Tracker
-- Created by besteon, based on the PokemonBizhawkLua project by MKDasher

Main = {
	TrackerVersion = "0.5.4", -- The latest version of the tracker. Should be updated with each PR.
	DataFolder = "ironmon_tracker", -- Root folder for the project data and sub scripts
	SettingsFile = "Settings.ini", -- Location of the Settings file (typically in the root folder)
	MetaSettings = {},
	LoadNextSeed = false,
}

print("\nIronmon-Tracker v" .. Main.TrackerVersion)

-- Check the version of BizHawk that is running
-- Need to also check that client.getversion is an existing function, older Bizhawk versions don't have it
if client.getversion == nil or (client.getversion() ~= "2.8" and client.getversion() ~= "2.9") then
	print("This version of BizHawk is not supported.\nPlease update to version 2.8 or higher.")
	-- Bounce out... Don't pass Go! Don't collect $200.
	return
end

-- Import all scripts before starting the main loop
dofile(Main.DataFolder .. "/Inifile.lua")
dofile(Main.DataFolder .. "/Constants.lua")
dofile(Main.DataFolder .. "/PokemonData.lua")
dofile(Main.DataFolder .. "/MoveData.lua")
dofile(Main.DataFolder .. "/MiscData.lua")
dofile(Main.DataFolder .. "/Memory.lua")
dofile(Main.DataFolder .. "/GameSettings.lua")
dofile(Main.DataFolder .. "/InfoScreen.lua")
dofile(Main.DataFolder .. "/Options.lua")
dofile(Main.DataFolder .. "/Theme.lua")
dofile(Main.DataFolder .. "/ColorPicker.lua")
dofile(Main.DataFolder .. "/Utils.lua")
dofile(Main.DataFolder .. "/TrackerScreen.lua")
dofile(Main.DataFolder .. "/Input.lua")
dofile(Main.DataFolder .. "/Drawing.lua")
dofile(Main.DataFolder .. "/Program.lua")
dofile(Main.DataFolder .. "/Pickle.lua")
dofile(Main.DataFolder .. "/Tracker.lua")

-- Displays a given error message in a pop-up dialogue box
function Main.DisplayError(errMessage)
	client.pause()
	local form = forms.newform(400, 130, "[v" .. Main.TrackerVersion .. "] Woops, there's been an error!", function() return end)
	Utils.setFormLocation(form, 100, 50)
	forms.label(form, errMessage, 18, 10, 400, 50)
	forms.button(form, "Close", function()
		client.unpause()
		forms.destroy(form)
	end, 155, 70)
end

-- Main loop
function Main.Run()
	Main.LoadSettings()

	print("Waiting for ROM to be loaded...")
	local romLoaded = false
	while not romLoaded do
		if gameinfo.getromname() ~= "Null" then romLoaded = true end
		emu.frameadvance()
	end

	GameSettings.initialize()

	if GameSettings.game == 0 then
		client.SetGameExtraPadding(0, 0, 0, 0)
		while true do
			gui.text(0, 0, "Lua error: " .. GameSettings.gamename)
			emu.frameadvance()
		end
	else
		Program.initialize()
		Options.initialize()
		Theme.initialize()
		Tracker.initialize()
		TrackerScreen.initialize()

		client.SetGameExtraPadding(0, Constants.SCREEN.UP_GAP, Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.DOWN_GAP)
		gui.defaultTextBackground(0)

		event.onexit(Program.HandleExit, "HandleExit")

		while Main.LoadNextSeed == false do
			Program.main()
			emu.frameadvance()
		end

		Main.LoadNext()
	end
end

function Main.LoadNext()
	Tracker.resetData()
	print("Tracker data has been reset.\nAttempting to load next ROM...")

	if Options.ROMS_FOLDER == nil or Options.ROMS_FOLDER == "" then
		print("ERROR: ROMS_FOLDER unspecified\n")
		Main.DisplayError("ROMS_FOLDER unspecified.\n\nSet this in the Tracker's options menu, or the Settings.ini file.")
		Main.LoadNextSeed = false
		Main.Run()
	end

	local romname = gameinfo.getromname()

	-- Split the ROM name into its prefix and numerical values
	local romprefix = string.match(romname, '[^0-9]+')
	local romnumber = string.match(romname, '[0-9]+')
	if romprefix == nil then romprefix = "" end
	if romnumber == nil then romnumber = "0" end

	-- Increment to the next ROM and determine its full file path
	local nextromname = string.format(romprefix .. "%0" .. string.len(romnumber) .. "d", romnumber + 1)
	local nextrompath = Options.ROMS_FOLDER .. "/" .. nextromname .. ".gba"

	-- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
	local filecheck = io.open(nextrompath,"r")
	if filecheck ~= nil then
		-- This means the file exists, so proceed with opening it.
		io.close(filecheck)
	else
		nextromname = nextromname:gsub(" ", "_")
		nextrompath = Options.ROMS_FOLDER .. "/" .. nextromname .. ".gba"
		filecheck = io.open(nextrompath,"r")
		if filecheck == nil then
			-- This means there doesn't exist a ROM file with spaces or underscores
			print("ERROR: Next ROM not found\n")
			Main.DisplayError("Unable to find next ROM: " .. nextromname .. ".gba\n\nMake sure your ROMs are numbered and the ROMs folder is correct.")
			Main.LoadNextSeed = false
			Main.Run()
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

-- Get the user settings saved on disk and create the base Settings object; returns true if successfully reads in file
function Main.LoadSettings()
	local settings = nil

	-- Need to manually read the file to work around a bug in the ini parser, which
	-- does not correctly handle that the last iteration over lines() returns nil
	local file = io.open(Main.SettingsFile)
	if file ~= nil then
		settings = Inifile.parse(file:read("*a"), "memory")
		io.close(file)
	end

	if settings == nil then
		return false
	end

	-- Keep the meta data for saving settings later in a specified order
	Main.MetaSettings = settings

	-- [CONFIG]
	if settings.config ~= nil then
		if settings.config.ROMS_FOLDER ~= nil then
			Options.ROMS_FOLDER = settings.config.ROMS_FOLDER
		end
	end

	-- [TRACKER]
	if settings.tracker ~= nil then
		for _, optionKey in ipairs(Constants.ORDERED_LISTS.OPTIONS) do
			if optionKey ~= nil then
				local optionValue = settings.tracker[string.gsub(optionKey, " ", "_")]
				Options[optionKey] = optionValue
			end
		end
	end

	-- [CONTROLS]
	if settings.controls ~= nil then
		for optionKey, _ in pairs(Options.CONTROLS) do
			if optionKey ~= nil then
				local controlValue = settings.controls[string.gsub(optionKey, " ", "_")]
				Options.CONTROLS[optionKey] = controlValue
			end
		end
	end

	-- [THEME]
	if settings.theme ~= nil then
		for _, colorkey in ipairs(Constants.ORDERED_LISTS.THEMECOLORS) do
			if colorkey ~= nil then
				local color_hexval = settings.theme[string.gsub(colorkey, " ", "_")]
				Theme.COLORS[colorkey] = 0xFF000000 + tonumber(color_hexval, 16)
			end
		end

		local enableMoveTypes = settings.theme.MOVE_TYPES_ENABLED
		if enableMoveTypes ~= nil then
			Theme.MOVE_TYPES_ENABLED = enableMoveTypes
			Theme.buttons.moveTypeEnabled.toggleState = not enableMoveTypes -- Show the opposite of the Setting, can't change existing theme strings
		end
	end

	return true
end

-- Saves the user settings on to disk
function Main.SaveSettings()
	-- Don't bother saving to a file if nothing has changed
	if not Options.settingsUpdated and not Theme.settingsUpdated then
		return
	end

	local settings = Main.MetaSettings

	if settings == nil then settings = {} end
	if settings.config == nil then settings.config = {} end
	if settings.tracker == nil then settings.tracker = {} end
	if settings.controls == nil then settings.controls = {} end
	if settings.theme == nil then settings.theme = {} end

	-- [CONFIG]
	settings.config.ROMS_FOLDER = Options.ROMS_FOLDER

	-- [TRACKER]
	for _, optionKey in ipairs(Constants.ORDERED_LISTS.OPTIONS) do
		local encodedKey = string.gsub(optionKey, " ", "_")
		settings.tracker[encodedKey] = Options[optionKey]
	end

	-- [CONTROLS]
	for _, controlKey in ipairs(Constants.ORDERED_LISTS.CONTROLS) do
		local encodedKey = string.gsub(controlKey, " ", "_")
		settings.controls[encodedKey] = Options.CONTROLS[controlKey]
	end

	-- [THEME]
	for _, colorkey in ipairs(Constants.ORDERED_LISTS.THEMECOLORS) do
		local encodedKey = string.gsub(colorkey, " ", "_")
		settings.theme[encodedKey] = string.upper(string.sub(string.format("%#x", Theme.COLORS[colorkey]), 5))
	end
	settings.theme["MOVE_TYPES_ENABLED"] = Theme.MOVE_TYPES_ENABLED

	Inifile.save(Main.SettingsFile, settings)
	Options.settingsUpdated = false
	Theme.settingsUpdated = false
end

Main.Run()
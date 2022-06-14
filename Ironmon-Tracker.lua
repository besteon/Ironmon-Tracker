-- IronMon Tracker
-- Created by besteon, based on the PokemonBizhawkLua project by MKDasher

-- The latest version of the tracker. Should be updated with each PR.
TRACKER_VERSION = "0.3.2"

-- A frequently used placeholder when a data field is not applicable
PLACEHOLDER = "---" -- TODO: Consider moving into a better global constant location? Placed here for now to ensure it is available to all subscripts.

print("\nIronmon-Tracker v" .. TRACKER_VERSION)

-- Check the version of BizHawk that is running
if string.sub(client.getversion(), 1) ~= "2.8" then
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
Settings = INI.parse(io.open("Settings.ini"):read("*a"), "memory")

-- Import all scripts before starting the main loop
dofile(DATA_FOLDER .. "/PokemonData.lua")
dofile(DATA_FOLDER .. "/MoveData.lua")
dofile(DATA_FOLDER .. "/Data.lua")
dofile(DATA_FOLDER .. "/Memory.lua")
dofile(DATA_FOLDER .. "/GameSettings.lua")
dofile(DATA_FOLDER .. "/GraphicConstants.lua")
dofile(DATA_FOLDER .. "/Options.lua")
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
	print("Waiting 5s before loading...")
	local frames = 0
	local waitBeforeHook = 300
	while frames < waitBeforeHook do
		emu.frameadvance()
		frames = frames + 1
	end
	print("Loading...")

	Options.buildTrackerOptionsButtons()
	GameSettings.initialize()

	if GameSettings.game == 0 then
		client.SetGameExtraPadding(0, 0, 0, 0)
		while true do
			gui.text(0, 0, "Lua error: " .. GameSettings.gamename)
			emu.frameadvance()
		end
	else
		Tracker.loadData()

		client.SetGameExtraPadding(0, GraphicConstants.UP_GAP, GraphicConstants.RIGHT_GAP, GraphicConstants.DOWN_GAP)
		gui.defaultTextBackground(0)

		event.onloadstate(Tracker.loadData, "OnLoadState")

		-- Core events
		event.onmemoryexecute(Program.HandleEndBattle, GameSettings.ReturnFromBattleToOverworld, "HandleEndBattle")
		event.onmemoryexecute(Program.HandleMove, GameSettings.ChooseMoveUsedParticle, "HandleMove")
		event.onmemoryexecute(Program.HandleDoPokeballSendOutAnimation, GameSettings.DoPokeballSendOutAnimation, "HandleDoPokeballSendOutAnimation")

		-- Additional events to re-render on
		event.onmemoryexecute(Program.HandleShowSummary, GameSettings.ShowPokemonSummaryScreen, "HandleShowSummary")
		event.onmemoryexecute(Program.HandleCalculateMonStats, GameSettings.CalculateMonStats, "HandleHandleCalculateMonStats")
		event.onmemoryexecute(Program.HandleDisplayMonLearnedMove, GameSettings.DisplayMonLearnedMove, "HandleDisplayMonLearnedMove")
		event.onmemoryexecute(Program.HandleSwitchSelectedMons, GameSettings.SwitchSelectedMons, "HandleSwitchSelectedMons")
		event.onmemoryexecute(Program.HandleUpdatePoisonStepCounter, GameSettings.UpdatePoisonStepCounter, "HandleUpdatePoisonStepCounter")
		event.onmemoryexecute(Program.HandleHealPlayerParty, GameSettings.HealPlayerParty, "HandleHealPlayerParty")

		-- Ability events
		-- event.onmemoryread(Program.HandleBattleScriptDrizzleActivates, GameSettings.BattleScriptDrizzleActivates, "HandleBattleScriptDrizzleActivates")
		-- event.onmemoryread(Program.HandleBattleScriptSpeedBoostActivates, GameSettings.BattleScriptSpeedBoostActivates, "HandleBattleScriptSpeedBoostActivates")
		-- event.onmemoryread(Program.HandleBattleScriptTraceActivates, GameSettings.BattleScriptTraceActivates, "HandleBattleScriptTraceActivates")
		-- event.onmemoryread(Program.HandleBattleScriptRainDishActivates, GameSettings.BattleScriptRainDishActivates, "HandleBattleScriptRainDishActivates")
		-- event.onmemoryread(Program.HandleBattleScriptSandstreamActivates, GameSettings.BattleScriptSandstreamActivates, "HandleBattleScriptSandstreamActivates")
		-- event.onmemoryread(Program.HandleBattleScriptShedSkinActivates, GameSettings.BattleScriptShedSkinActivates, "HandleBattleScriptShedSkinActivates")
		-- event.onmemoryread(Program.HandleBattleScriptIntimidateActivates, GameSettings.BattleScriptIntimidateActivates, "HandleBattleScriptIntimidateActivates")
		-- event.onmemoryread(Program.HandleBattleScriptDroughtActivates, GameSettings.BattleScriptDroughtActivates, "HandleBattleScriptDroughtActivates")
		-- event.onmemoryread(Program.HandleBattleScriptStickyHoldActivates, GameSettings.BattleScriptStickyHoldActivates, "HandleBattleScriptStickyHoldActivates")
		-- event.onmemoryread(Program.HandleBattleScriptColorChangeActivates, GameSettings.BattleScriptColorChangeActivates, "HandleBattleScriptColorChangeActivates")
		-- event.onmemoryread(Program.HandleBattleScriptRoughSkinActivates, GameSettings.BattleScriptRoughSkinActivates, "HandleBattleScriptRoughSkinActivates")
		-- event.onmemoryread(Program.HandleBattleScriptCuteCharmActivates, GameSettings.BattleScriptCuteCharmActivates, "HandleBattleScriptCuteCharmActivates")
		-- event.onmemoryread(Program.HandleBattleScriptSynchronizeActivates, GameSettings.BattleScriptSynchronizeActivates, "HandleBattleScriptSynchronizeActivates")
		--event.onmemoryread(Program.Handle, GameSettings., "")

		-- For some reason if I put this onmemory read before the ability event ones, it doesn't work. No idea why, probably just Bizhawk things.
		-- event.onmemoryread(Program.HandleWeHopeToSeeYouAgain, GameSettings.WeHopeToSeeYouAgain)
		-- event.onmemoryread(Program.HandleTrainerSentOutPkmn, GameSettings.TrainerSentOutPkmn)

		-- Item events

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
	print "Reset tracker"

	if Settings.config.ROMS_FOLDER == nil then
		print("ROMS_FOLDER unspecified. Set this in Settings.ini to automatically switch ROM.")
		Main.LoadNextSeed = false
		Main.Run()
		return
	end

	client.SetSoundOn(false)
	local romname = gameinfo.getromname()
	client.closerom()
  
  -- Split the ROM name into its prefix and numerical values
  local romprefix = string.match(romname, '[^0-9]+')
  local romnumber = string.match(romname, '[0-9]+')
  if romprefix == nil then romprefix = "" end
  
  -- Increment to the next ROM and determine its full file path
  local nextromname = string.format(romprefix .. "%0" .. string.len(romnumber) .. "d", romnumber + 1)
  local nextrompath = Settings.config.ROMS_FOLDER .. "\\" .. nextromname .. ".gba"
  
  -- First try loading the next rom as-is with spaces, otherwise replace spaces with underscores and try again
  local filecheck = io.open(nextrompath,"r")
  if filecheck ~= nil then
    -- This means the file exists, so proceed with opening it.
    io.close(filecheck)
  else
    nextromname = nextromname:gsub(" ", "_")
    nextrompath = Settings.config.ROMS_FOLDER .. "\\" .. nextromname .. ".gba"
    filecheck = io.open(nextrompath,"r")
    if filecheck == nil then
      -- This means there doesn't exist a ROM file with spaces or underscores
      print("Unable to locate next ROM file to load. Current ROM: " .. romname)
      Main.LoadNextSeed = false
      Main.Run()
    else
      io.close(filecheck)
    end
  end
  
  client.openrom(nextrompath)
	client.SetSoundOn(true)

	if gameinfo.getromname() ~= "Null" then
		Main.LoadNextSeed = false
		Main.Run()
	end
end

Main.Run()

-- IRONMON TRACKER v0.1.8

-- Based on Lua Script made by MKDasher, which was based on FractalFusion's VBA-rr scripts.
-- NOTE: On Bizhawk, go to Config / Display... Then uncheck Stretch pixels by integers only.

DATA_FOLDER = "ironmon_tracker"
dofile ("ironmon_settings.lua")
dofile (DATA_FOLDER .. "/Data.lua")
dofile (DATA_FOLDER .. "/Memory.lua")
dofile (DATA_FOLDER .. "/GameSettings.lua")
dofile (DATA_FOLDER .. "/GraphicConstants.lua")
dofile (DATA_FOLDER .. "/Utils.lua")
dofile (DATA_FOLDER .. "/Buttons.lua")
dofile (DATA_FOLDER .. "/Input.lua")
dofile (DATA_FOLDER .. "/Drawing.lua")
dofile (DATA_FOLDER .. "/Program.lua")
dofile (DATA_FOLDER .. "/Pickle.lua")
dofile (DATA_FOLDER .. "/Tracker.lua")

print("Ironmon-Tracker v0.1.8")

Main = {}
Main.LoadNextSeed = false

waitBeforeHook = 300

-- Main loop
function Main.Run()
	print("Waiting 5s before loading...")
	local frames = 0
	while frames < waitBeforeHook do
		emu.frameadvance()
		frames = frames + 1
	end
	print("Loading...")

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
		event.onsavestate(Tracker.saveData, "OnSaveState")
		event.onmemoryexecute(Program.HandleBeginBattle, GameSettings.BeginBattleIntro, "HandleBeginBattle")
		event.onmemoryexecute(Program.HandleEndBattle, GameSettings.ReturnFromBattleToOverworld, "HandleEndBattle")
		event.onmemoryexecute(Program.HandleMove, GameSettings.ChooseMoveUsedParticle, "HandleMove")
		event.onmemoryexecute(Program.HandleShowSummary, GameSettings.ShowPokemonSummaryScreen, "HandleShowSummary")
		event.onmemoryexecute(Program.HandleCalculateMonStats, GameSettings.CalculateMonStats, "HandleHandleCalculateMonStats")
		event.onmemoryexecute(Program.HandleDisplayMonLearnedMove, GameSettings.DisplayMonLearnedMove, "HandleDisplayMonLearnedMove")
		event.onmemoryexecute(Program.HandleSwitchSelectedMons, GameSettings.SwitchSelectedMons, "HandleSwitchSelectedMons")
		event.onexit(Program.HandleExit, "HandleExit")

		while Main.LoadNextSeed == false do
			Program.main()
			emu.frameadvance()
		end
		
		Main.LoadNext()
	end
end

function Main.LoadNext()
	if Settings.ROMS_FOLDER == "" then
		print("Please specify Settings.ROMS_FOLDER in ironmon_settings.lua to use this feature.")
	end

	print("Loading next ROM...")

	local romname = gameinfo.getromname()
	userdata.clear()
	client.closerom()


	local rombasename = string.match(romname, '[%a]+')
	local romnumber = tonumber(string.match(romname, '[0-9]+')) + 1
	local nextromname = Settings.ROMS_FOLDER .. "\\" .. rombasename .. romnumber .. ".gba"

	client.openrom(nextromname)

	if gameinfo.getromname() ~= "Null" then
		Main.LoadNextSeed = false
		Main.Run()
	else
		print("Error loading next ROM: (do your ROM names have leading zeros?")
		print(nextromname)
	end
end

Main.Run()
-- IRONMON TRACKER v0.1.9

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

print("Ironmon-Tracker v0.1.9")

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

		-- Core events
		--event.onmemoryexecute(Program.HandleStartWildBattle, GameSettings.StartWildBattle, "HandleStartWildBattle")
		event.onmemoryexecute(Program.HandleBeginBattle, GameSettings.BeginBattleIntro, "HandleBeginBattle")
		event.onmemoryexecute(Program.HandleEndBattle, GameSettings.ReturnFromBattleToOverworld, "HandleEndBattle")
		event.onmemoryexecute(Program.HandleMove, GameSettings.ChooseMoveUsedParticle, "HandleMove")

		-- Additional events to re-render on
		event.onmemoryexecute(Program.HandleShowSummary, GameSettings.ShowPokemonSummaryScreen, "HandleShowSummary")
		event.onmemoryexecute(Program.HandleCalculateMonStats, GameSettings.CalculateMonStats, "HandleHandleCalculateMonStats")
		event.onmemoryexecute(Program.HandleDisplayMonLearnedMove, GameSettings.DisplayMonLearnedMove, "HandleDisplayMonLearnedMove")
		event.onmemoryexecute(Program.HandleSwitchSelectedMons, GameSettings.SwitchSelectedMons, "HandleSwitchSelectedMons")
		event.onmemoryexecute(Program.HandleUpdatePoisonStepCounter, GameSettings.UpdatePoisonStepCounter, "HandleUpdatePoisonStepCounter")

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
	client.SetSoundOn(false)

	if Settings.ROMS_FOLDER == "" then
		print("Please specify Settings.ROMS_FOLDER in ironmon_settings.lua to use this feature.")
	end

	print("Loading next ROM...")

	local romname = gameinfo.getromname()
	userdata.clear()
	client.closerom()

	local rombasename = string.match(romname, '[^0-9]+')
	local romnumber = tonumber(string.match(romname, '[0-9]+')) + 1
	local nextromname = ""
	if rombasename == nil then
		nextromname = Settings.ROMS_FOLDER .. "\\" .. romnumber .. ".gba"
	else
		rombasename = rombasename:gsub(" ", "_")
		nextromname = Settings.ROMS_FOLDER .. "\\" .. rombasename .. romnumber .. ".gba"
		print(nextromname)
	end

	client.openrom(nextromname)
	client.SetSoundOn(true)

	if gameinfo.getromname() ~= "Null" then
		Main.LoadNextSeed = false
		Main.Run()
	else
		print("Error loading next ROM: (do your ROM names have leading zeros?")
		print(nextromname)
	end
end

Main.Run()
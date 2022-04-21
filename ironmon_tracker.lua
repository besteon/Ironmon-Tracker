-- IRONMON TRACKER v0.1.4

-- Based on Lua Script made by MKDasher
-- Based on FractalFusion's VBA-rr lua scripts, with some extra features.
-- NOTE: On Bizhawk, go to Config / Display... Then uncheck Stretch pixels by integers only.

DATA_FOLDER = "ironmon_tracker"

dofile ("ironmon_settings.lua")

dofile (DATA_FOLDER .. "/Data.lua")
dofile (DATA_FOLDER .. "/Memory.lua")
dofile (DATA_FOLDER .. "/GameSettings.lua")

print("Ironmon-Tracker v0.1.4 loaded.")

-- Initialize Game Settings before loading other files.
GameSettings.initialize()

dofile (DATA_FOLDER .. "/GraphicConstants.lua")
dofile (DATA_FOLDER .. "/Utils.lua")
dofile (DATA_FOLDER .. "/Buttons.lua")
dofile (DATA_FOLDER .. "/Input.lua")
dofile (DATA_FOLDER .. "/Drawing.lua")
dofile (DATA_FOLDER .. "/Program.lua")
dofile (DATA_FOLDER .. "/Pickle.lua")
dofile (DATA_FOLDER .. "/Tracker.lua")

-- Main loop
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
	event.onloadstate(Tracker.loadData)
	event.onsavestate(Tracker.saveData)
	event.onmemoryexecute(Program.HandleWhiteOut, GameSettings.DoWhiteOut)
	event.onmemoryexecute(Program.HandleBeginBattle, GameSettings.BeginBattleIntro)
	event.onmemoryexecute(Program.HandleEndBattle, GameSettings.ReturnFromBattleToOverworld)
	event.onmemoryexecute(Program.HandleMove, GameSettings.ChooseMoveUsedParticle)
	while true do
		collectgarbage()
		Program.main()
		emu.frameadvance()
	end
end


GameSettings = {
	game = 0,
	gamename = "",
	pstats = 0,
	estats = 0,
	version = 0,

	versiongroup = 0,
	StartWildBattle = 0,
	TrainerSentOutPkmn = 0,
	BeginBattleIntro = 0,
	ReturnFromBattleToOverworld = 0,
	ChooseMoveUsedParticle = 0,
	gChosenMove = 0,
	lastusedabilityaddress = 0,
	attackeraddress = 0,
	gBattlerPartyIndexesSelfSlotOne = 0,
	gBattlerPartyIndexesEnemySlotOne = 0,
	gBattlerPartyIndexesSelfSlotTwo = 0,
	gBattlerPartyIndexesEnemySlotTwo = 0,

	ShowPokemonSummaryScreen = 0,
	CalculateMonStats = 0,
	SwitchSelectedMons = 0,
	UpdatePoisonStepCounter = 0,
	WeHopeToSeeYouAgain = 0,

	BattleScriptDrizzleActivates = 0,
	BattleScriptSpeedBoostActivates = 0,
	BattleScriptTraceActivates = 0,
	BattleScriptRainDishActivates = 0,
	BattleScriptSandstreamActivates = 0,
	BattleScriptShedSkinActivates = 0,
	BattleScriptIntimidateActivates = 0,
	BattleScriptDroughtActivates = 0,
	BattleScriptStickyHoldActivates = 0,
	BattleScriptColorChangeActivates = 0,
	BattleScriptRoughSkinActivates = 0,
	BattleScriptCuteCharmActivates = 0,
	BattleScriptSynchronizeActivates = 0,
}
GameSettings.VERSIONS = {
	RS = 1,
	E = 2,
	FRLG = 3
}

function GameSettings.initialize()
	local gamecode = memory.read_u32_be(0x0000AC, "ROM")
	local gameversion = memory.read_u32_be(0x0000BC, "ROM")
	local pstats = {0x3004360, 0x20244EC, 0x2024284, 0x3004290, 0x2024190, 0x20241E4} -- Player stats
	local estats = {0x30045C0, 0x2024744, 0x202402C, 0x30044F0, 0x20243E8, 0x2023F8C} -- Enemy stats
	
	if gamecode == 0x42504545 then
		print("Emerald ROM Detected")
		GameSettings.game = 2
		GameSettings.gamename = "Pokemon Emerald (U)"
		GameSettings.version = GameSettings.VERSIONS.E
		GameSettings.versiongroup = 1

		GameSettings.StartWildBattle = 0x080b0698
		GameSettings.TrainerSentOutPkmn = 0x085cbbe7
		GameSettings.BeginBattleIntro = 0x08039ECC
		GameSettings.ReturnFromBattleToOverworld = 0x0803DF70
		GameSettings.sBattlerAbilities = 0x0203aba4
		GameSettings.ChooseMoveUsedParticle = 0x0814f8f8
		GameSettings.gChosenMove = 0x020241EC
		GameSettings.gBattlerAttacker = 0x0202420B
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x0202406E
		GameSettings.gBattlerPartyIndexesEnemySlotOne = 0x02024070
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = 0x02024072
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = 0x02024074
		GameSettings.gBattleMons = 0x02024084
		GameSettings.ShowPokemonSummaryScreen = 0x081bf8ec
		GameSettings.CalculateMonStats = 0x08068d0c
		GameSettings.DisplayMonLearnedMove = 0x081b7910
		GameSettings.SwitchSelectedMons = 0x081b3938
		GameSettings.UpdatePoisonStepCounter = 0x0809cb94
		GameSettings.WeHopeToSeeYouAgain = 0x082727db

		GameSettings.BattleScriptDrizzleActivates = 0x082db430
		GameSettings.BattleScriptSpeedBoostActivates = 0x082db444
		GameSettings.BattleScriptTraceActivates = 0x082db452
		GameSettings.BattleScriptRainDishActivates = 0x082db45c
		GameSettings.BattleScriptSandstreamActivates = 0x082db470
		GameSettings.BattleScriptShedSkinActivates = 0x082db484
		GameSettings.BattleScriptIntimidateActivates = 0x082db4c1
		GameSettings.BattleScriptDroughtActivates = 0x082db52a
		GameSettings.BattleScriptStickyHoldActivates = 0x082db63f
		GameSettings.BattleScriptColorChangeActivates = 0x082db64d
		GameSettings.BattleScriptRoughSkinActivates = 0x082db654
		GameSettings.BattleScriptCuteCharmActivates = 0x082db66f
		GameSettings.BattleScriptSynchronizeActivates = 0x082db67f
	elseif gamecode == 0x42505245 and gameversion == 0x01670000 then
		print("Firered v1.1 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon FireRed (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2

		GameSettings.StartWildBattle = 0x0807f718
		GameSettings.TrainerSentOutPkmn = 0x083fd421
		GameSettings.BeginBattleIntro = 0x080123d4
		GameSettings.ReturnFromBattleToOverworld = 0x08015b6c
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.ChooseMoveUsedParticle = 0x080d86dc
		GameSettings.gChosenMove = 0x02023d4c
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = 0x02023bd0
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = 0x02023bcd2
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = 0x02023bd4
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.ShowPokemonSummaryScreen = 0x08134570
		GameSettings.CalculateMonStats = 0x0803e490
		GameSettings.DisplayMonLearnedMove = 0x0812687c
		GameSettings.SwitchSelectedMons = 0x08122ed4
		GameSettings.UpdatePoisonStepCounter = 0x0806d7b0
		GameSettings.WeHopeToSeeYouAgain = 0x081a5589

		GameSettings.BattleScriptDrizzleActivates = 0x081d92ef
		GameSettings.BattleScriptSpeedBoostActivates = 0x081d9303
		GameSettings.BattleScriptTraceActivates = 0x081d9311
		GameSettings.BattleScriptRainDishActivates = 0x081d931b
		GameSettings.BattleScriptSandstreamActivates = 0x081d932f
		GameSettings.BattleScriptShedSkinActivates = 0x081d9343
		GameSettings.BattleScriptIntimidateActivates = 0x081d9380
		GameSettings.BattleScriptDroughtActivates = 0x081d93e9
		GameSettings.BattleScriptStickyHoldActivates = 0x081d94fe
		GameSettings.BattleScriptColorChangeActivates = 0x081d950c
		GameSettings.BattleScriptRoughSkinActivates = 0x081d9513
		GameSettings.BattleScriptCuteCharmActivates = 0x081d952e
		GameSettings.BattleScriptSynchronizeActivates = 0x081d953e
	elseif gamecode == 0x42505245 and gameversion == 0x00680000 then
		print("Firered v1.0 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon FireRed (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2

		GameSettings.StartWildBattle = 0x0807f704
		GameSettings.TrainerSentOutPkmn = 0x083fd3b1
		GameSettings.BeginBattleIntro = 0x080123c0
		GameSettings.ReturnFromBattleToOverworld = 0x08015b58
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.ChooseMoveUsedParticle = 0x080d86c8
		GameSettings.gChosenMove = 0x02023d4c
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = 0x02023bd0
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = 0x02023bcd2
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = 0x02023bd4
		GameSettings.ShowPokemonSummaryScreen = 0x081344f8
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.CalculateMonStats = 0x0803e47c
		GameSettings.DisplayMonLearnedMove = 0x08126804
		GameSettings.SwitchSelectedMons = 0x08122e5c
		GameSettings.UpdatePoisonStepCounter = 0x0806d79c
		GameSettings.WeHopeToSeeYouAgain = 0x081a5511

		GameSettings.BattleScriptDrizzleActivates = 0x081d927f
		GameSettings.BattleScriptSpeedBoostActivates = 0x081d9293
		GameSettings.BattleScriptTraceActivates = 0x081d92a1
		GameSettings.BattleScriptRainDishActivates = 0x081d92ab
		GameSettings.BattleScriptSandstreamActivates = 0x081d92bf
		GameSettings.BattleScriptShedSkinActivates = 0x081d92d3
		GameSettings.BattleScriptIntimidateActivates = 0x081d9310
		GameSettings.BattleScriptDroughtActivates = 0x081d9379
		GameSettings.BattleScriptStickyHoldActivates = 0x081d948e
		GameSettings.BattleScriptColorChangeActivates = 0x081d949c
		GameSettings.BattleScriptRoughSkinActivates = 0x081d94a3
		GameSettings.BattleScriptCuteCharmActivates = 0x081d94be
		GameSettings.BattleScriptSynchronizeActivates = 0x081d94ce
	elseif gamecode == 0x42504745 and gameversion == 0x01800000 then
		print("Leaf Green v1.1 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon LeafGreen (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2

		GameSettings.StartWildBattle = 0x0807f6ec
		GameSettings.TrainerSentOutPkmn = 0x083fd25d
		GameSettings.BeginBattleIntro = 0x080123d4
		GameSettings.ReturnFromBattleToOverworld = 0x08015b6c
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.ChooseMoveUsedParticle = 0x080d86b0
		GameSettings.gChosenMove = 0x02023d4c
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = 0x02023bd0
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = 0x02023bcd2
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = 0x02023bd4
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.ShowPokemonSummaryScreen = 0x08134548
		GameSettings.CalculateMonStats = 0x0803e490
		GameSettings.DisplayMonLearnedMove = 0x08126854
		GameSettings.SwitchSelectedMons = 0x08122eac
		GameSettings.UpdatePoisonStepCounter = 0x0806d7b0
		GameSettings.WeHopeToSeeYouAgain = 0x081a5565

		GameSettings.BattleScriptDrizzleActivates = 0x081d92cb
		GameSettings.BattleScriptSpeedBoostActivates = 0x081d92df
		GameSettings.BattleScriptTraceActivates = 0x081d92ed
		GameSettings.BattleScriptRainDishActivates = 0x081d92f7
		GameSettings.BattleScriptSandstreamActivates = 0x081d930b
		GameSettings.BattleScriptShedSkinActivates = 0x081d931f
		GameSettings.BattleScriptIntimidateActivates = 0x081d935c
		GameSettings.BattleScriptDroughtActivates = 0x081d93c5
		GameSettings.BattleScriptStickyHoldActivates = 0x081d94da
		GameSettings.BattleScriptColorChangeActivates = 0x081d94e8
		GameSettings.BattleScriptRoughSkinActivates = 0x081d94ef
		GameSettings.BattleScriptCuteCharmActivates = 0x081d950a
		GameSettings.BattleScriptSynchronizeActivates = 0x081d951a
	elseif gamecode == 0x42504745 and gameversion == 0x00810000 then
		print("Leaf Green v1.0 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon LeafGreen (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2

		GameSettings.StartWildBattle = 0x0807f6d8
		GameSettings.TrainerSentOutPkmn = 0x083fd1ed
		GameSettings.BeginBattleIntro = 0x080123c0
		GameSettings.ReturnFromBattleToOverworld = 0x08015b58
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.ChooseMoveUsedParticle = 0x080d869c
		GameSettings.gChosenMove = 0x02023d4c
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = 0x02023bd0
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = 0x02023bcd2
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = 0x02023bd4
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.ShowPokemonSummaryScreen = 0x081344d0
		GameSettings.CalculateMonStats = 0x0803e47c
		GameSettings.DisplayMonLearnedMove = 0x081267dc
		GameSettings.SwitchSelectedMons = 0x08122e34
		GameSettings.UpdatePoisonStepCounter = 0x0806d79c
		GameSettings.WeHopeToSeeYouAgain = 0x081a54ed

		GameSettings.BattleScriptDrizzleActivates = 0x081d925b
		GameSettings.BattleScriptSpeedBoostActivates = 0x081d926f
		GameSettings.BattleScriptTraceActivates = 0x081d927d
		GameSettings.BattleScriptRainDishActivates = 0x081d9287
		GameSettings.BattleScriptSandstreamActivates = 0x081d929b
		GameSettings.BattleScriptShedSkinActivates = 0x081d92af
		GameSettings.BattleScriptIntimidateActivates = 0x081d92ec
		GameSettings.BattleScriptDroughtActivates = 0x081d9355
		GameSettings.BattleScriptStickyHoldActivates = 0x081d946a
		GameSettings.BattleScriptColorChangeActivates = 0x081d9478
		GameSettings.BattleScriptRoughSkinActivates = 0x081d947f
		GameSettings.BattleScriptCuteCharmActivates = 0x081d949a
		GameSettings.BattleScriptSynchronizeActivates = 0x081d94aa
	else
		GameSettings.game = 0
		GameSettings.gamename = "Unsupported game"
		GameSettings.encountertable = 0
	end
	
	if GameSettings.game > 0 then
		GameSettings.pstats  = pstats[GameSettings.game]
		GameSettings.estats  = estats[GameSettings.game]
	end
end
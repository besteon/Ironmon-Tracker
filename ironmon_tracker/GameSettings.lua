GameSettings = {
	game = 0,
	gamename = "",
	pstats = 0,
	estats = 0,
	version = 0,

	versiongroup = 0,
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
	elseif gamecode == 0x42505245 and gameversion == 0x01670000 then
		print("Firered v1.1 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon FireRed (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2
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
	elseif gamecode == 0x42505245 and gameversion == 0x00680000 then
		print("Firered v1.0 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon FireRed (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2
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
	elseif gamecode == 0x42504745 and gameversion == 0x01800000 then
		print("Leaf Green v1.1 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon LeafGreen (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2
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
	elseif gamecode == 0x42504745 and gameversion == 0x00810000 then
		print("Leaf Green v1.0 ROM Detected")
		GameSettings.game = 3
		GameSettings.gamename = "Pokemon LeafGreen (U)"
		GameSettings.version = GameSettings.VERSIONS.FRLG
		GameSettings.versiongroup = 2
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
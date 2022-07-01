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
	DoPokeballSendOutAnimation = 0,
	HealPlayerParty = 0,

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

	ObtainBadgeOne = 0,
	ObtainBadgeTwo = 0,
	ObtainBadgeThree = 0,
	ObtainBadgeFour = 0,
	ObtainBadgeFive = 0,
	ObtainBadgeSix = 0,
	ObtainBadgeSeven = 0,
	ObtainBadgeEight = 0,

	gSaveBlock1 = 0,
	gSaveBlock2ptr = 0,
	bagEncryptionKeyOffset = 0,
	bagPocket_Items = 0,
	bagPocket_Berries = 0,
	bagPocket_Items_Size = 0,
	bagPocket_Berries_Size = 0,
}
GameSettings.VERSIONS = {
	RS = 1,
	E = 2,
	FRLG = 3
}

function GameSettings.initialize()
	local gamecode = memory.read_u32_be(0x0000AC, "ROM")
	local gameversion = memory.read_u32_be(0x0000BC, "ROM")
	local pstats = { 0x3004360, 0x20244EC, 0x2024284, 0x3004290, 0x2024190, 0x20241E4 } -- Player stats
	local estats = { 0x30045C0, 0x2024744, 0x202402C, 0x30044F0, 0x20243E8, 0x2023F8C } -- Enemy stats

	if gamecode == 0x42504545 then
		print("Emerald ROM Detected")
		BadgeButtons.BADGE_GAME_PREFIX = "RSE"
		BadgeButtons.xOffsets = {1, 1, 0, 0, 1, 1, 1, 1}

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
		GameSettings.DoPokeballSendOutAnimation = 0x080753e8
		GameSettings.HealPlayerParty = 0x080f9180

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

		-- RustboroCity_Gym_EventScript_RoxanneDefeated
		GameSettings.ObtainBadgeOne = 0x08212f66
		-- DewfordTown_Gym_EventScript_BrawlyDefeated
		GameSettings.ObtainBadgeTwo = 0x081fc7f7
		-- MauvilleCity_Gym_EventScript_WattsonDefeated
		GameSettings.ObtainBadgeThree = 0x0820df2b
		-- LavaridgeTown_Gym_1F_EventScript_FlanneryDefeated
		GameSettings.ObtainBadgeFour = 0x081fe7c1
		-- PetalburgCity_Gym_Text_NormanDefeat (unsure about this one)
		GameSettings.ObtainBadgeFive = 0x08206107
		-- FortreeCity_Gym_EventScript_WinonaDefeated
		GameSettings.ObtainBadgeSix = 0x082165fd
		-- MossdeepCity_Gym_EventScript_TateAndLizaDefeated
		GameSettings.ObtainBadgeSeven = 0x082208d1
		-- SootopolisCity_Gym_1F_EventScript_JuanDefeated
		GameSettings.ObtainBadgeEight = 0x08224f82

		GameSettings.gSaveBlock1 = 0x02025a00
		GameSettings.gSaveBlock2ptr = 0x03005d90
		GameSettings.bagEncryptionKeyOffset = 0xAC
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x560
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x790
		GameSettings.bagPocket_Items_Size = 30
		GameSettings.bagPocket_Berries_Size = 46
	elseif gamecode == 0x42505245 and gameversion == 0x01670000 then
		print("Firered v1.1 ROM Detected")
		BadgeButtons.BADGE_GAME_PREFIX = "FRLG"
		BadgeButtons.xOffsets = {0, -2, -2, 0, 1, 1, 0, 1}

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
		GameSettings.UpdatePoisonStepCounter = 0x080a062c
		GameSettings.WeHopeToSeeYouAgain = 0x081a5589
		GameSettings.DoPokeballSendOutAnimation = 0x0804a94c
		GameSettings.HealPlayerParty = 0x080a006c

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

		-- PewterCity_Gym_EventScript_DefeatedBrock
		GameSettings.ObtainBadgeOne = 0x0816a63d
		-- CeruleanCity_Gym_EventScript_MistyDefeated
		GameSettings.ObtainBadgeTwo = 0x0816ab4b
		-- VermilionCity_Gym_EventScript_DefeatedLtSurge
		GameSettings.ObtainBadgeThree = 0x0816b9f4
		-- CeladonCity_Gym_EventScript_DefeatedErika
		GameSettings.ObtainBadgeFour = 0x0816d118
		-- FuchsiaCity_Gym_EventScript_DefeatedKoga
		GameSettings.ObtainBadgeFive = 0x0816d5f8
		-- SaffronCity_Gym_EventScript_DefeatedSabrina
		GameSettings.ObtainBadgeSix = 0x0816ee82
		-- CinnabarIsland_Gym_EventScript_DefeatedBlaine
		GameSettings.ObtainBadgeSeven = 0x0816da7e
		-- ViridianCity_Gym_EventScript_DefeatedGiovanni
		GameSettings.ObtainBadgeEight = 0x08169f7c

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	elseif gamecode == 0x42505245 and gameversion == 0x00680000 then
		print("Firered v1.0 ROM Detected")
		BadgeButtons.BADGE_GAME_PREFIX = "FRLG"
		BadgeButtons.xOffsets = {0, -2, -2, 0, 1, 1, 0, 1}

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
		GameSettings.DoPokeballSendOutAnimation = 0x0804a938
		GameSettings.HealPlayerParty = 0x080a0058

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

		-- PewterCity_Gym_EventScript_DefeatedBrock
		GameSettings.ObtainBadgeOne = 0x0816a5c5
		-- CeruleanCity_Gym_EventScript_MistyDefeated
		GameSettings.ObtainBadgeTwo = 0x0816aad3
		-- VermilionCity_Gym_EventScript_DefeatedLtSurge
		GameSettings.ObtainBadgeThree = 0x0816b97c
		-- CeladonCity_Gym_EventScript_DefeatedErika
		GameSettings.ObtainBadgeFour = 0x0816d0a0
		-- FuchsiaCity_Gym_EventScript_DefeatedKoga
		GameSettings.ObtainBadgeFive = 0x0816d580
		-- SaffronCity_Gym_EventScript_DefeatedSabrina
		GameSettings.ObtainBadgeSix = 0x0816ee0a
		-- CinnabarIsland_Gym_EventScript_DefeatedBlaine
		GameSettings.ObtainBadgeSeven = 0x0816da06
		-- ViridianCity_Gym_EventScript_DefeatedGiovanni
		GameSettings.ObtainBadgeEight = 0x08169f04

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	elseif gamecode == 0x42504745 and gameversion == 0x01800000 then
		print("Leaf Green v1.1 ROM Detected")
		BadgeButtons.BADGE_GAME_PREFIX = "FRLG"
		BadgeButtons.xOffsets = {0, -2, -2, 0, 1, 1, 0, 1}

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
		GameSettings.DoPokeballSendOutAnimation = 0x0804a94c
		GameSettings.HealPlayerParty = 0x080a0040

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

		-- PewterCity_Gym_EventScript_DefeatedBrock
		GameSettings.ObtainBadgeOne = 0x0816a619
		-- CeruleanCity_Gym_EventScript_MistyDefeated
		GameSettings.ObtainBadgeTwo = 0x0816ab27
		-- VermilionCity_Gym_EventScript_DefeatedLtSurge
		GameSettings.ObtainBadgeThree = 0x0816b9d0
		-- CeladonCity_Gym_EventScript_DefeatedErika
		GameSettings.ObtainBadgeFour = 0x0816d0f4
		-- FuchsiaCity_Gym_EventScript_DefeatedKoga
		GameSettings.ObtainBadgeFive = 0x0816d5d4
		-- SaffronCity_Gym_EventScript_DefeatedSabrina
		GameSettings.ObtainBadgeSix = 0x0816ee5e
		-- CinnabarIsland_Gym_EventScript_DefeatedBlaine
		GameSettings.ObtainBadgeSeven = 0x0816da5a
		-- ViridianCity_Gym_EventScript_DefeatedGiovanni
		GameSettings.ObtainBadgeEight = 0x08169f58

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	elseif gamecode == 0x42504745 and gameversion == 0x00810000 then
		print("Leaf Green v1.0 ROM Detected")
		BadgeButtons.BADGE_GAME_PREFIX = "FRLG"
		BadgeButtons.xOffsets = {0, -2, -2, 0, 1, 1, 0, 1}

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
		GameSettings.DoPokeballSendOutAnimation = 0x0804a938
		GameSettings.HealPlayerParty = 0x080a002c

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

		-- PewterCity_Gym_EventScript_DefeatedBrock
		GameSettings.ObtainBadgeOne = 0x0816a5a1
		-- CeruleanCity_Gym_EventScript_MistyDefeated
		GameSettings.ObtainBadgeTwo = 0x0816aaaf
		-- VermilionCity_Gym_EventScript_DefeatedLtSurge
		GameSettings.ObtainBadgeThree = 0x0816b958
		-- CeladonCity_Gym_EventScript_DefeatedErika
		GameSettings.ObtainBadgeFour = 0x0816d07c
		-- FuchsiaCity_Gym_EventScript_DefeatedKoga
		GameSettings.ObtainBadgeFive = 0x0816d55c
		-- SaffronCity_Gym_EventScript_DefeatedSabrina
		GameSettings.ObtainBadgeSix = 0x0816ede6
		-- CinnabarIsland_Gym_EventScript_DefeatedBlaine
		GameSettings.ObtainBadgeSeven = 0x0816d9e2
		-- ViridianCity_Gym_EventScript_DefeatedGiovanni
		GameSettings.ObtainBadgeEight = 0x08169ee0

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	else
		GameSettings.game = 0
		GameSettings.gamename = "Unsupported game"
		GameSettings.encountertable = 0
	end

	if GameSettings.game > 0 then
		GameSettings.pstats = pstats[GameSettings.game]
		GameSettings.estats = estats[GameSettings.game]
	end
end

GameSettings = {
	game = 0,
	gamename = "",
	versiongroup = 0,
	badgePrefix = "",
	badgeXOffsets = { 0, 0, 0, 0, 0, 0, 0, 0 },
	pstats = 0,
	estats = 0,

	sMonSummaryScreen = 0x00000000,
	sSpecialFlags = 0x00000000, -- [3 = In catching tutorial, 0 = Not in catching tutorial]
	sBattlerAbilities = 0x00000000,
	gBattlerAttacker = 0x00000000,
	gBattlerPartyIndexesSelfSlotOne = 0x00000000,
	gBattlerPartyIndexesEnemySlotOne = 0x00000000,
	gBattlerPartyIndexesSelfSlotTwo = 0x00000000,
	gBattlerPartyIndexesEnemySlotTwo = 0x00000000,
	gBattleMons = 0x00000000,
	gBattlescriptCurrInstr = 0x00000000,
	BattleScript_FocusPunchSetUp = 0x00000000,
	BattleScript_LearnMoveLoop = 0x00000000,
	BattleScript_LearnMoveReturn = 0x00000000,
	gMoveToLearn = 0x00000000,
	gBattleOutcome = 0x00000000, -- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]

	gSaveBlock1 = 0x00000000,
	gSaveBlock1ptr = 0x00000000, -- Doesn't exist in Ruby/Sapphire
	gSaveBlock2ptr = 0x00000000, -- Doesn't exist in Ruby/Sapphire
	gameStatsOffset = 0x0,
	EncryptionKeyOffset = 0x00, -- Doesn't exist in Ruby/Sapphire
	badgeOffset = 0x0,
	bagPocket_Items_offset = 0x0,
	bagPocket_Berries_offset = 0x0,
	bagPocket_Items_Size = 0,
	bagPocket_Berries_Size = 0,
}

-- Maps the BattleScript memory addresses to their respective abilityId's, this is set later when game is loaded
GameSettings.ABILITIES = {}

-- Moved the 1st/2nd/3rd values to game info, leaving others here if more games get added
-- local pstats = { 0x3004360, 0x20244EC, 0x2024284, 0x3004290, 0x2024190, 0x20241E4 } -- Player stats
-- local estats = { 0x30045C0, 0x2024744, 0x202402C, 0x30044F0, 0x20243E8, 0x2023F8C } -- Enemy stats

function GameSettings.initialize()
	local gamecode = memory.read_u32_be(0x0000AC, "ROM")
	local gameversion = memory.read_u32_be(0x0000BC, "ROM")

	GameSettings.setGameInfo(gamecode)

	if gamecode == 0x41585645 then
		GameSettings.setGameAsRuby(gameversion)
	elseif gamecode == 0x41585045 then
		GameSettings.setGameAsSapphire(gameversion)
	elseif gamecode == 0x42504545 then
		GameSettings.setGameAsEmerald(gameversion)
	elseif gamecode == 0x42505245 then
		GameSettings.setGameAsFireRed(gameversion)
	elseif gamecode == 0x42505253 then
		GameSettings.setGameAsFireRedSpanish(gameversion)
	elseif gamecode == 0x42504745 then
		GameSettings.setGameAsLeafGreen(gameversion)
	end
end

function GameSettings.setGameInfo(gamecode)
	-- Mapped by key=gamecode
	local games = {
		[0x41585645] = {
			GAME_NUMBER = 1,
			GAME_NAME = "Pokemon Ruby (U)",
			VERSION_GROUP = 1,
			PSTATS = 0x3004360,
			ESTATS = 0x30045C0,
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x41585045] = {
			GAME_NUMBER = 1,
			GAME_NAME = "Pokemon Sapphire (U)",
			VERSION_GROUP = 1,
			PSTATS = 0x3004360,
			ESTATS = 0x30045C0,
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x42504545] = {
			GAME_NUMBER = 2,
			GAME_NAME = "Pokemon Emerald (U)",
			VERSION_GROUP = 1,
			PSTATS = 0x20244EC,
			ESTATS = 0x2024744,
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x42505245] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon FireRed (U)",
			VERSION_GROUP = 2,
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505253] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rojo Fuego (fr spanish)",
			VERSION_GROUP = 2,
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42504745] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon LeafGreen (U)",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			VERSION_GROUP = 2,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
	}

	if games[gamecode] ~= nil then
		GameSettings.game = games[gamecode].GAME_NUMBER
		GameSettings.gamename = games[gamecode].GAME_NAME
		GameSettings.pstats = games[gamecode].PSTATS
		GameSettings.estats = games[gamecode].ESTATS
		GameSettings.versiongroup = games[gamecode].VERSION_GROUP
		GameSettings.badgePrefix = games[gamecode].BADGE_PREFIX
		GameSettings.badgeXOffsets = games[gamecode].BADGE_XOFFSETS
	else
		GameSettings.gamename = "Unsupported game"
		Main.DisplayError("This game is unsupported.\n\nOnly RSE/FRLG English versions are currently supported.")
	end
end

function GameSettings.setGameAsRuby(gameversion)
	-- TODO: Add in ability auto-tracking: https://github.com/pret/pokeruby/tree/symbols
	if gameversion == 0x00410000 then
		print("ROM Detected: Pokemon Ruby v1.0")

		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f0f -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f61
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x01400000 then
		print("ROM Detected: Pokemon Ruby v1.1")

		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f27 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f79
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x023F0000 then
		print("ROM Detected: Pokemon Ruby v1.2")

		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f27 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f79
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	end
end

function GameSettings.setGameAsSapphire(gameversion)
	-- TODO: Add in ability auto-tracking: https://github.com/pret/pokeruby/tree/symbols
	if gameversion == 0x00550000 then
		print("ROM Detected: Pokemon Sapphire v1.0")

		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8e9f -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ef1
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x1540000 then
		print("ROM Detected: Pokemon Sapphire v1.1")

		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8eb7 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f09
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x02530000 then
		print("ROM Detected: Pokemon Sapphire v1.2")

		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8eb7 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f09
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	end
end

function GameSettings.setGameAsEmerald(gameversion)
	print("ROM Detected: Pokemon Emerald")

	GameSettings.sMonSummaryScreen = 0x0203cf1c
	GameSettings.sSpecialFlags = 0x020375fc
	GameSettings.sBattlerAbilities = 0x0203aba4
	GameSettings.gBattlerAttacker = 0x0202420B
	GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x0202406E
	GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
	GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
	GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
	GameSettings.gBattleMons = 0x02024084
	GameSettings.gBattlescriptCurrInstr = 0x02024214
	GameSettings.BattleScript_FocusPunchSetUp = 0x082db1ff + 0x10
	GameSettings.BattleScript_LearnMoveLoop = 0x082dabd9 -- BattleScript_TryLearnMoveLoop
	GameSettings.BattleScript_LearnMoveReturn = 0x082dac2b
	GameSettings.gMoveToLearn = 0x020244e2
	GameSettings.gBattleOutcome = 0x0202433a

	GameSettings.gSaveBlock1 = 0x02025a00
	GameSettings.gSaveBlock1ptr = 0x03005d8c
	GameSettings.gSaveBlock2ptr = 0x03005d90
	GameSettings.gameStatsOffset = 0x159C
	GameSettings.EncryptionKeyOffset = 0xAC
	GameSettings.badgeOffset = 0x1270 + 0x10C -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
	GameSettings.bagPocket_Items_offset = 0x560
	GameSettings.bagPocket_Berries_offset = 0x790
	GameSettings.bagPocket_Items_Size = 30
	GameSettings.bagPocket_Berries_Size = 46

	-- https://raw.githubusercontent.com/pret/pokeemerald/symbols/pokeemerald.sym
	GameSettings.ABILITIES = {
		[0x082db430] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
		[0x082db44b] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
		[0x082db552] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
		[0x082db560] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
		[0x082d9362] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
		[0x082db5f5] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
		[0x082db650] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
		[0x082d8f63] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
		[0x082db5b1] = 18, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
		[0x082db611] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
		[0x082db4be] = 22, -- BattleScript_PauseIntimidateActivates + 0x0 Intimidate
		[0x082db664] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
		[0x082db67f] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
		[0x082db5c7] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
		[0x082db452] = 36, -- BattleScript_TraceActivates + 0x0 Trace
		[0x082db627] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
		[0x082db45f] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
		[0x082db470] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
		[0x082db635] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
		[0x082db6cc] = 54, -- BattleScript_MoveUsedLoafingAroundMsg + 0x5 Truant
		[0x082db678] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
		[0x082db63f] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
		[0x082db487] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
		[0x082db52a] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
		[0x082d8ad7] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
	}
end

function GameSettings.setGameAsFireRed(gameversion)
	if gameversion == 0x01670000 then
		print("ROM Detected: Pokemon Fire Red v1.1")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		GameSettings.ABILITIES = {
			[0x081d92ef] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081d930a] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081d9411] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081d941f] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081d72b5] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			-- [0x00000000] = 9, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Static -- Likely: BattleScript_ApplySecondaryEffect
			-- [0x081d9442] = 10, -- BattleScript_MonMadeMoveUseless - 0xE Volt Absorb 081D9442 and/or 081D942F TODO: these dont work
			-- [0x081d9452] = 11, -- BattleScript_MonMadeMoveUseless + 0x1 Water Absorb 081D9452 and/or 081D9458 TODO: these dont work
			[0x081d94b4] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			-- [0x00000000] = 13, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Cloud Nine
			-- [0x00000000] = 15, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Insomnia
			[0x081d950f] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081d6ebf] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081d9470] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			-- [0x00000000] = 19, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Shield Dust
			[0x081d94d0] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			-- [0x00000000] = 21, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Suction Cups (untested)
			[0x081d937d] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081d9523] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			-- [0x00000000] = 26, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Levitate -- No clean trigger to use
			-- [0x00000000] = 27, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Effect Spore -- Likely: BattleScript_ApplySecondaryEffect
			[0x081d953e] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081d9486] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081d9311] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			-- [0x081d924c] = 38, -- BattleScript_MoveEffectPoison + 0x7 Poison Point 081D9247 and/or 081D924C-- BattleScript_ApplySecondaryEffect
			[0x081D94E6] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081D931E] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081d932f] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			-- [0x00000000] = 49, -- BattleScript_MoveEffectBurn + 0x0 Flame Body 081D9256 and/or 081D925B -- Likely: BattleScript_ApplySecondaryEffect
			-- [0x00000000] = 51, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Keen Eye (untested)
			[0x081D94F4] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081d9567] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081d9537] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081d94fe] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081d9346] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			-- [0x00000000] = 64, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Liquid Ooze (Difficult: multiple addresses)
			[0x081d93e9] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081D6A44] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
			-- [0x00000000] = 73, -- BattleScript_AbilityNoStatLoss + 0x0 White Smoke (Same address as Clear Body)
		}
	elseif gameversion == 0x00680000 then
		print("ROM Detected: Pokemon Fire Red v1.0")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9015 + 0x10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a11
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a63
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered.sym
		GameSettings.ABILITIES = {
			[0x081d927f] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081d929a] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081d93a1] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081d93af] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081d7245] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			[0x081d9444] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			[0x081d949f] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081d6e4f] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081d93f8] = 18, -- BattleScript_FlashFireBoost + 0x1 Flash Fire
			[0x081d9460] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x081d930d] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081d94b3] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x081d94ce] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081d9416] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081d92a1] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			[0x081d9476] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081d92ae] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081d92bf] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x081d9484] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081d94f7] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081d94c7] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081d948e] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081d92d6] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x081d9379] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081d69d4] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
		}
	end
end

function GameSettings.setGameAsFireRedSpanish(gameversion)
	if gameversion == 0x005A0000 then
		print("ROM Detected: Pokemon Rojo Fuego (fr spanish)")
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0 -- not sure if its the real value used for.its used for rse only anyway so not that important
		GameSettings.sBattlerAbilities = 0x02039a30 --not used in tracker so no idea
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4 --not tested
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6 -- not tested
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74 --seems like they are same as fr but not sure
		--this section is not tested but everything was the same so lets hope 
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		--the only diffrance looks like in here gSaveBlock1ptr and gSaveBlock2ptr
		GameSettings.gSaveBlock1ptr = 0x03004F58
		GameSettings.gSaveBlock2ptr = 0x03004F5C
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310 --tested for bag items didnt check for berries should be same though
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		GameSettings.ABILITIES = {
			[0x081d92ef] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081d930a] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081d9411] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081d941f] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081d72b5] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			-- [0x00000000] = 9, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Static -- Likely: BattleScript_ApplySecondaryEffect
			-- [0x081d9442] = 10, -- BattleScript_MonMadeMoveUseless - 0xE Volt Absorb 081D9442 and/or 081D942F TODO: these dont work
			-- [0x081d9452] = 11, -- BattleScript_MonMadeMoveUseless + 0x1 Water Absorb 081D9452 and/or 081D9458 TODO: these dont work
			[0x081d94b4] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			-- [0x00000000] = 13, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Cloud Nine
			-- [0x00000000] = 15, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Insomnia
			[0x081d950f] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081d6ebf] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081d9470] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			-- [0x00000000] = 19, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Shield Dust
			[0x081d94d0] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			-- [0x00000000] = 21, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Suction Cups (untested)
			[0x081d937d] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081d9523] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			-- [0x00000000] = 26, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Levitate -- No clean trigger to use
			-- [0x00000000] = 27, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Effect Spore -- Likely: BattleScript_ApplySecondaryEffect
			[0x081d953e] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081d9486] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081d9311] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			-- [0x081d924c] = 38, -- BattleScript_MoveEffectPoison + 0x7 Poison Point 081D9247 and/or 081D924C-- BattleScript_ApplySecondaryEffect
			[0x081D94E6] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081D931E] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081d932f] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			-- [0x00000000] = 49, -- BattleScript_MoveEffectBurn + 0x0 Flame Body 081D9256 and/or 081D925B -- Likely: BattleScript_ApplySecondaryEffect
			-- [0x00000000] = 51, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Keen Eye (untested)
			[0x081D94F4] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081d9567] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081d9537] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081d94fe] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081d9346] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			-- [0x00000000] = 64, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Liquid Ooze (Difficult: multiple addresses)
			[0x081d93e9] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081D6A44] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
			-- [0x00000000] = 73, -- BattleScript_AbilityNoStatLoss + 0x0 White Smoke (Same address as Clear Body)
		}
	end
end

function GameSettings.setGameAsLeafGreen(gameversion)
	if gameversion == 0x01800000 then
		print("ROM Detected: Pokemon Leaf Green v1.1")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9061 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a5d
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8aaf
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen_rev1.sym
		GameSettings.ABILITIES = {
			[0x081d92cb] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081d92e6] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081d93ed] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081d93fb] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081d7291] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			[0x081d9490] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			[0x081d94eb] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081d6e9b] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081d9446] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			[0x081d94ac] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x081d9359] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081d94ff] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x081d951a] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081d9462] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081d92ed] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			[0x081d94c2] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081d92fa] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081d930b] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x081d94d0] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081d9543] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081d9513] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081d94da] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081d9322] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x081d93c5] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081d6a20] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
		}
	elseif gameversion == 0x00810000 then
		print("ROM Detected: Pokemon Leaf Green v1.0")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d8ff1 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d89ed
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a3f
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen.sym
		GameSettings.ABILITIES = {
			[0x081d925b] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081d9276] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081d937d] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081d938b] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081d7221] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			[0x081d9420] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			[0x081d947b] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081d6e2b] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081d93d6] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			[0x081d943c] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x081d92e9] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081d948f] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x081d94aa] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081d93f2] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081d927d] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			[0x081d9452] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081d928a] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081d929b] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x081d9460] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081d94d3] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081d94a3] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081d946a] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081d92b2] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x081d9355] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081d69b0] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
		}
	end
end

function GameSettings.getTrackerAutoSaveName()
	if GameSettings.gamename == "" then
		return "AutoSave" .. Constants.TRACKER_DATA_EXTENSION
	else
		-- Remove trailing " (U)" from game name
		return GameSettings.gamename:sub(1, -5) .. " AutoSave" .. Constants.TRACKER_DATA_EXTENSION
	end
end
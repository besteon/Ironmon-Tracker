GameSettings = {
	game = 0,
	gamename = "",
	versiongroup = 0,
	badgePrefix = "",
	badgeXOffsets = { 0, 0, 0, 0, 0, 0, 0, 0 },
	pstats = 0,
	estats = 0,

	gBaseStats = 0x00000000,
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
	gBattleResults = 0x00000000,
	BattleScript_FocusPunchSetUp = 0x00000000,
	BattleScript_LearnMoveLoop = 0x00000000,
	BattleScript_LearnMoveReturn = 0x00000000,
	gMoveToLearn = 0x00000000,
	gBattleOutcome = 0x00000000, -- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]

	FriendshipRequiredToEvo = 0x00000000,

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
		GameSettings.setGameAsEmerald()
	elseif gamecode == 0x42505245 then
		GameSettings.setGameAsFireRed(gameversion)
	elseif gamecode == 0x42505249 then
		GameSettings.setGameAsFireRedItaly(gameversion)
	elseif gamecode == 0x42505253 then
		GameSettings.setGameAsFireRedSpanish(gameversion)
	elseif gamecode == 0x42505246 then
		GameSettings.setGameAsFireRedFrench(gameversion)
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
		[0x42505249] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon - Rosso Fuoco (Italy)",
			VERSION_GROUP = 2,
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505253] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rojo Fuego (Spain)",
			VERSION_GROUP = 2,
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505246] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rouge Feu (France)",
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
		Main.DisplayError("This game is unsupported by the Ironmon Tracker.\n\nCheck the tracker's README.txt file for currently supported games.")
	end
end

function GameSettings.setGameAsRuby(gameversion)
	if gameversion == 0x00410000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby.sym
		print("ROM Detected: Pokemon Ruby v1.0")

		GameSettings.gBaseStats = 0x081fec18
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
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f0f -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f61
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x01400000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev1.sym
		print("ROM Detected: Pokemon Ruby v1.1")

		GameSettings.gBaseStats = 0x081fec30
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
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f27 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f79
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x023F0000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev2.sym
		print("ROM Detected: Pokemon Ruby v1.2")

		GameSettings.gBaseStats = 0x081fec30
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
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f27 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f79
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

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
	if gameversion == 0x00550000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire.sym
		print("ROM Detected: Pokemon Sapphire v1.0")

		GameSettings.gBaseStats = 0x081feba8
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
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8e9f -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ef1
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x1540000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev1.sym
		print("ROM Detected: Pokemon Sapphire v1.1")

		GameSettings.gBaseStats = 0x081febc0
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
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8eb7 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f09
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x02530000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev2.sym
		print("ROM Detected: Pokemon Sapphire v1.2")

		GameSettings.gBaseStats = 0x081febc0
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
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8eb7 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f09
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46
	end
end

function GameSettings.setGameAsEmerald()
	-- https://raw.githubusercontent.com/pret/pokeemerald/symbols/pokeemerald.sym
	print("ROM Detected: Pokemon Emerald")

	GameSettings.gBaseStats = 0x083203cc
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
	GameSettings.gBattleResults = 0x03005d10
	GameSettings.BattleScript_FocusPunchSetUp = 0x082db1ff + 0x10
	GameSettings.BattleScript_LearnMoveLoop = 0x082dabd9 -- BattleScript_TryLearnMoveLoop
	GameSettings.BattleScript_LearnMoveReturn = 0x082dac2b
	GameSettings.gMoveToLearn = 0x020244e2
	GameSettings.gBattleOutcome = 0x0202433a
	
	GameSettings.FriendshipRequiredToEvo = 0x0806d098 + 0x13E -- GetEvolutionTargetSpecies

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
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		print("ROM Detected: Pokemon Fire Red v1.1")

		GameSettings.gBaseStats = 0x082547f4
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gCurrentMove = 0x02023d4a

		GameSettings.FriendshipRequiredToEvo = 0x08042ED8 + 0x13E -- GetEvolutionTargetSpecies

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

		GameSettings.ABILITIES = {
			BATTLER = { -- Abilities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d92ef] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d930a] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d93e1] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d93c9] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d9317] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d932f] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d9346] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d93e9] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d948c] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d94f4] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter 
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d93e1] = { -- BattleScript_IntimidateAbilityFail + 0x6 (Intimidate blocked)
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				}, 
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d9417] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d94b4] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d950f] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d9470] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d94d0] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d947e] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d9523] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d69b3] = {[26] = true}, -- BattleScript_HitFromAtkAnimation + 0xF Levitate ; Actually checking gMoveResultFlags during this message
				[0x081d9537] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d94fe] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6aaf] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9442] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP 
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d9458] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d94a4] = { -- BattleScript_PRLZPrevention + 0x8 
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d94b0] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d9498] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6a44] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d931e] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9567] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d6f2a] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d9230] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d9279] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9] = true,  -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d924c] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				}, 
				[0x081d925b] = { --BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d9425] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true,
					scope = "both",
				},
				[0x081d94e6] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true,
					scope = "self",
				}, 
				[0x081d763a] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true,
					scope = "self",
				},
				[0x081d8c07] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true,
					scope = "other",
				}, 
			},
		}
	elseif gameversion == 0x00680000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered.sym
		print("ROM Detected: Pokemon Fire Red v1.0")

		GameSettings.gBaseStats = 0x08254784
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9015 + 0x10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a11
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a63
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gCurrentMove = 0x02023d4a

		GameSettings.FriendshipRequiredToEvo = 0x08042ec4 + 0x13E -- GetEvolutionTargetSpecies

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

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d927f] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d929a] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d9371] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d9359] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d92a7] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d92bf] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d92d6] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d9379] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d941c] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d9484] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye 
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d9371] = { -- BattleScript_IntimidateAbilityFail + 0x6
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d93a7] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d9444] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d949f] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d9400] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d9460] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d940e] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d94b3] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d6943] = {[26] = true}, -- BattleScript_HitFromAtkAnimation + 0xF Levitate ; Actually checking gMoveResultFlags during this message
				[0x081d94c7] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d948e] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6a3f] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d93d2] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d93e8] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9434] = { -- BattleScript_PRLZPrevention + 0x8 
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d9440] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d9428] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d69d4] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d92ae] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d94f7] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d6eba] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d91c0] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d9209] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d91dc] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d91eb] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d93b5] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true,
					scope = "both",
				},
				[0x081d9476] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true,
					scope = "self",
				}, 
				[0x081d75ca] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true,
					scope = "self",
				},
				[0x081d8b97] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true,
					scope = "other",
				}, 
			},
		}
	end
end

function GameSettings.setGameAsFireRedItaly(gameversion)
	if gameversion == 0x00640000 then
		print("ROM Detected: Pokemon - Rosso Fuoco")

		GameSettings.gBaseStats = 0x0824d864
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
		GameSettings.gBattleResults = 0x03004f90 -- TODO: Check what this address actually is
		
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d647f + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d5e7B --those values were tricky to find 
		GameSettings.BattleScript_LearnMoveReturn = 0x081D5ECD -- expect them to not always be right
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		
		GameSettings.FriendshipRequiredToEvo = 0x08042db0 + 0x13E -- GetEvolutionTargetSpecies (untested)
		
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
		--base for abilitys is fire red v1.1 looks like diff between abilitys is same
		--this was not stright forward to get so expect to find errors here 
		GameSettings.ABILITIES = {
			[0x081d66e9] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081d6704] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081d680b] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081d6819] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081d42b3] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			[0x081d68ae] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			[0x081d6909] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			--[0x081d42b3] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested) not working in eng version
			[0x081d686a] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			[0x081d581c] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x081d6777] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081d3ea3] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x081d6938] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081d6880] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081d670b] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			[0x081d68e0] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081d5f23] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081d6729] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x081d68ee] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081d3f32] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081d6931] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081d68f8] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081d430b] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x081d67e3] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081d3e30] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
		}
		dofile(Main.DataFolder .. "/Languages/ItalyData.lua")
		ItalyData.updateToItalyData()
	end
end

function GameSettings.setGameAsFireRedSpanish(gameversion)
	if gameversion == 0x005A0000 then
		print("ROM Detected: Pokemon Rojo Fuego")

		GameSettings.gBaseStats = 0x0824ff4c
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
		GameSettings.gBattleResults = 0x03004f90 -- TODO: Check what this address actually is
		
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d8b47 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081D8543
		GameSettings.BattleScript_LearnMoveReturn = 0x081D8595
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		
		GameSettings.FriendshipRequiredToEvo = 0x08042db0 + 0x13E -- GetEvolutionTargetSpecies (untested)
		
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
		--base for abilitys is fire red v1.1 looks like diff between abilitys is same
		--so take what you get from firered v1.v and find where drizzle is
		GameSettings.ABILITIES = {
			[0x081d8db1] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081D8DCC] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081D8ED3] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081D8EE1] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081D6D77] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			[0x081D8F76] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			[0x081D8FD1] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081D6981] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081D8F32] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			[0x081D8F92] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x081D8E3F] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081D8FE5] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x081D9000] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081D8F48] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081D8DD3] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			[0x081D8FA8] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081D8DE0] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081D8DF1] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x081D8FB6] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081D9029] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081D8FF9] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081D8FC0] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081D8E08] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x081D8EAB] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081D6506] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
		}
		dofile(Main.DataFolder .. "/Languages/SpainData.lua")
		SpainData.updateToSpainData()
	end
end

function GameSettings.setGameAsFireRedFrench(gameversion)
	if gameversion == 0x00670000 then
		print("ROM Detected: Pokemon Rouge Feu")

		GameSettings.gBaseStats = 0x0824ebd4
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
		GameSettings.gBattleResults = 0x03004f90 -- TODO: Check what this address actually is
		
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d77e7 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081D7DEB
		GameSettings.BattleScript_LearnMoveReturn = 0x081D7E3D
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.FriendshipRequiredToEvo = 0x08042d9c + 0x13E -- GetEvolutionTargetSpecies (untested)

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
		--base for abilitys is fire red v1.1 looks like diff between abilitys is same
		--so take what you get from firered v1.v and find where drizzle is
		GameSettings.ABILITIES = {
			[0x081d7a51] = 2, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x081D7A6C] = 3, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x081D7B73] = 5, -- BattleScript_SturdyPreventsOHKO + 0x0 Sturdy
			[0x081D7B81] = 6, -- BattleScript_DampStopsExplosion + 0x0 Damp
			[0x081D5A17] = 7, -- BattleScript_LimberProtected + 0x0 Limber (untested)
			[0x081D7C16] = 12, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious (untested)
			[0x081D7C71] = 16, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x081D5621] = 17, -- BattleScript_ImmunityProtected + 0x0 Immunity (untested)
			[0x081D7BD2] = 18, -- BattleScript_FlashFireBoost + 0x3 Flash Fire
			[0x081D7C32] = 20, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x081D7ADF] = 22, -- BattleScript_DoIntimidateActivationAnim + 0x0 Intimidate
			[0x081D7C85] = 24, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x081D7CA0] = 28, -- BattleScript_SynchronizeActivates + 0x0 Synchronize (untested)
			[0x081D7BE8] = 29, -- BattleScript_AbilityNoStatLoss + 0x0 Clear Body & White Smoke
			[0x081D7A73] = 36, -- BattleScript_TraceActivates + 0x0 Trace
			[0x081D7C48] = 43, -- BattleScript_SoundproofProtected + 0x8 Soundproof
			[0x081D7A80] = 44, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x081D7A91] = 45, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x081D7C56] = 52, -- BattleScript_AbilityNoSpecificStatLoss + 0x6 Hyper Cutter
			[0x081D7CC9] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
			[0x081D7C99] = 56, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x081D7C60] = 60, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x081D7AA8] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x081D7B4B] = 70, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x081D51A6] = 72, -- BattleScript_CantMakeAsleep + 0x8 Vital Spirit
		}
		dofile(Main.DataFolder .. "/Languages/FranceData.lua")
		FranceData.updateToFranceData()
	end
end

function GameSettings.setGameAsLeafGreen(gameversion)
	if gameversion == 0x01800000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen_rev1.sym
		print("ROM Detected: Pokemon Leaf Green v1.1")

		GameSettings.gBaseStats = 0x082547d0
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
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9061 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a5d
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8aaf
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.FriendshipRequiredToEvo = 0x08042ed8 + 0x13E -- GetEvolutionTargetSpecies

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

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d92cb] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d92e6] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d93bd] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d93a5] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d92f3] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d930b] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d9322] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d93c5] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d9468] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d94d0] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye 
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d93bd] = { -- BattleScript_IntimidateAbilityFail + 0x6
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d93f3] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d9490] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d94eb] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d944c] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d94ac] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d945a] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d94ff] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d698f] = {[26] = true}, -- BattleScript_HitFromAtkAnimation + 0xF Levitate ; Actually checking gMoveResultFlags during this message
				[0x081d9513] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d94da] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6a8b] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d941e] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9434] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9480] = { -- BattleScript_PRLZPrevention + 0x8 
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d948c] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d9474] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6a20] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d92fa] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9543] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d6f06] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d920c] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d9255] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d9228] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9237] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d9401] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true,
					scope = "both",
				},
				[0x081d94c2] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true,
					scope = "self",
				}, 
				[0x081d7616] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true,
					scope = "self",
				},
				[0x081d8be3] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true,
					scope = "other",
				}, 
			},
		}
	elseif gameversion == 0x00810000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen.sym
		print("ROM Detected: Pokemon Leaf Green v1.0")

		GameSettings.gBaseStats = 0x08254760
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
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d8ff1 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d89ed
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a3f
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.FriendshipRequiredToEvo = 0x08042ec4 + 0x13E -- GetEvolutionTargetSpecies

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

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d925b] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d9276] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d934d] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d9335] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d9283] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d929b] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d92b2] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d9355] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d93f8] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d9460] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye 
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d934d] = { -- BattleScript_IntimidateAbilityFail + 0x6
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d9383] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d9420] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d947b] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d93dc] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d943c] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d93ea] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d948f] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d691f] = {[26] = true}, -- BattleScript_HitFromAtkAnimation + 0xF Levitate ; Actually checking gMoveResultFlags during this message
				[0x081d94a3] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d946a] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6a1b] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d93ae] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d93c4] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9410] = { -- BattleScript_PRLZPrevention + 0x8 
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d941c] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d9404] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d69b0] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d928a] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d94d3] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d6e96] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d919c] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d91e5] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d91b8] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d91c7] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d9391] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true,
					scope = "both",
				},
				[0x081d9452] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true,
					scope = "self",
				}, 
				[0x081d75a6] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true,
					scope = "self",
				},
				[0x081d8b73] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true,
					scope = "other",
				}, 
			},
		}
	end
end

function GameSettings.getTrackerAutoSaveName()
	local filenameEnding = "AutoSave" .. Constants.Extensions.TRACKED_DATA

	-- Remove trailing " (___)" from game name
	return GameSettings.gamename:gsub("%s%(.*%)", " ") .. filenameEnding
end
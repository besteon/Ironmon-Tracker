GameSettings = {
	game = 0,
	gamename = "",
	versiongroup = 0,
	pstats = 0,
	estats = 0,

	sMonSummaryScreen = 0x00000000,
	sBattlerAbilities = 0x00000000,
	gBattlerAttacker = 0x00000000,
	gBattlerPartyIndexesSelfSlotOne = 0x00000000,
	gBattlerPartyIndexesEnemySlotOne = 0x00000000,
	gBattlerPartyIndexesSelfSlotTwo = 0x00000000,
	gBattlerPartyIndexesEnemySlotTwo = 0x00000000,
	gBattleMons = 0x00000000,
	gBattleOutcome = 0x00000000, -- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]

	gSaveBlock1 = 0x00000000,
	gSaveBlock2ptr = 0x00000000,
	bagEncryptionKeyOffset = 0x00,
	bagPocket_Items = 0x0,
	bagPocket_Berries = 0x0,
	bagPocket_Items_Size = 0,
	bagPocket_Berries_Size = 0,
}

-- Mapped by key=gamecode
GameSettings.GAMES = {
	[0x41585645] = {
		GAME_NUMBER = 1,
		GAME_NAME = "Pokemon Ruby (U)",
		VERSION_GROUP = 1,
		BADGE_PREFIX = "RSE",
		BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
	},
	[0x41585045] = {
		GAME_NUMBER = 1,
		GAME_NAME = "Pokemon Sapphire (U)",
		VERSION_GROUP = 1,
		BADGE_PREFIX = "RSE",
		BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
	},
	[0x42504545] = {
		GAME_NUMBER = 2,
		GAME_NAME = "Pokemon Emerald (U)",
		VERSION_GROUP = 1,
		BADGE_PREFIX = "RSE",
		BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
	},
	[0x42505245] = {
		GAME_NUMBER = 3,
		GAME_NAME = "Pokemon FireRed (U)",
		VERSION_GROUP = 2,
		BADGE_PREFIX = "FRLG",
		BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
	},
	[0x42504745] = {
		GAME_NUMBER = 3,
		GAME_NAME = "Pokemon LeafGreen (U)",
		VERSION_GROUP = 2,
		BADGE_PREFIX = "FRLG",
		BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
	},
}

function GameSettings.initialize()
	local gamecode = memory.read_u32_be(0x0000AC, "ROM")
	local gameversion = memory.read_u32_be(0x0000BC, "ROM")
	local pstats = { 0x3004360, 0x20244EC, 0x2024284, 0x3004290, 0x2024190, 0x20241E4 } -- Player stats
	local estats = { 0x30045C0, 0x2024744, 0x202402C, 0x30044F0, 0x20243E8, 0x2023F8C } -- Enemy stats

	GameSettings.game = GameSettings.GAMES[gamecode].GAME_NUMBER
	GameSettings.gamename = GameSettings.GAMES[gamecode].GAME_NAME
	GameSettings.versiongroup = GameSettings.GAMES[gamecode].VERSION_GROUP
	BadgeButtons.BADGE_GAME_PREFIX = GameSettings.GAMES[gamecode].BADGE_PREFIX
	BadgeButtons.xOffsets = GameSettings.GAMES[gamecode].BADGE_XOFFSETS

	if gamecode == 0x41585645 then
		GameSettings.setGameAsRuby(gameversion)
	elseif gamecode == 0x41585045 then
		GameSettings.setGameAsSapphire(gameversion)
	elseif gamecode == 0x42504545 then
		GameSettings.setGameAsEmerald(gameversion)
	elseif gamecode == 0x42505245 then
		GameSettings.setGameAsFireRed(gameversion)
	elseif gamecode == 0x42504745 then
		GameSettings.setGameAsLeafGreen(gameversion)
	else
		GameSettings.game = 0
		GameSettings.gamename = "Unsupported game, unable to load ROM."
	end

	if GameSettings.game > 0 then
		GameSettings.pstats = pstats[GameSettings.game]
		GameSettings.estats = estats[GameSettings.game]
	end
end

function GameSettings.setGameAsRuby(gameversion)
	if gameversion == 0x00410000 then
		print("ROM Detected: Pokemon Ruby v1.0")

		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gSaveBlock2ptr = 0x00000000
		GameSettings.bagEncryptionKeyOffset = 0x00
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Items_Size = 30 -- TODO: Unsure if these two values are accurate for Ruby/Sapphire
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x023F0000 then
		print("ROM Detected: Pokemon Ruby v1.2")

		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gSaveBlock2ptr = 0x00000000
		GameSettings.bagEncryptionKeyOffset = 0x00
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Items_Size = 30 -- TODO: Unsure if these two values are accurate for Ruby/Sapphire
		GameSettings.bagPocket_Berries_Size = 46
	end
end

function GameSettings.setGameAsSapphire(gameversion)
	if gameversion == 0x00550000 then
		print("ROM Detected: Pokemon Sapphire v1.0")

		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gSaveBlock2ptr = 0x00000000
		GameSettings.bagEncryptionKeyOffset = 0x00
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Items_Size = 30 -- TODO: Unsure if these two values are accurate for Ruby/Sapphire
		GameSettings.bagPocket_Berries_Size = 46
	elseif gameversion == 0x02530000 then
		print("ROM Detected: Pokemon Sapphire v1.2")

		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02024a6a
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattleOutcome = 0x02024d26

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gSaveBlock2ptr = 0x00000000
		GameSettings.bagEncryptionKeyOffset = 0x00
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x000
		GameSettings.bagPocket_Items_Size = 30 -- TODO: Unsure if these two values are accurate for Ruby/Sapphire
		GameSettings.bagPocket_Berries_Size = 46
	end
end

function GameSettings.setGameAsEmerald(gameversion)
	print("ROM Detected: Pokemon Emerald")

	GameSettings.sMonSummaryScreen = 0x0203cf1c
	GameSettings.sBattlerAbilities = 0x0203aba4
	GameSettings.gBattlerAttacker = 0x0202420B
	GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x0202406E
	GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
	GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
	GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
	GameSettings.gBattleMons = 0x02024084
	GameSettings.gBattleOutcome = 0x0202433a

	GameSettings.gSaveBlock1 = 0x02025a00
	GameSettings.gSaveBlock2ptr = 0x03005d90
	GameSettings.bagEncryptionKeyOffset = 0xAC
	GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x560
	GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x790
	GameSettings.bagPocket_Items_Size = 30
	GameSettings.bagPocket_Berries_Size = 46
end

function GameSettings.setGameAsFireRed(gameversion)
	if gameversion == 0x01670000 then
		print("ROM Detected: Pokemon Fire Red v1.1")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	elseif gameversion == 0x00680000 then
		print("ROM Detected: Pokemon Fire Red v1.0")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	end
end

function GameSettings.setGameAsLeafGreen(gameversion)
	if gameversion == 0x01800000 then
		print("ROM Detected: Pokemon Leaf Green v1.1")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	elseif gameversion == 0x00810000 then
		print("ROM Detected: Pokemon Leaf Green v1.0")

		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.bagEncryptionKeyOffset = 0xF20
		GameSettings.bagPocket_Items = GameSettings.gSaveBlock1 + 0x310
		GameSettings.bagPocket_Berries = GameSettings.gSaveBlock1 + 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43
	end
end
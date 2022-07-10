GameSettings = {
	game = 0,
	gamename = "",
	versiongroup = 0,
	pstats = 0,
	estats = 0,

	sMonSummaryScreen = 0x00000000,
	sSpecialFlags = 0x00000000, -- [3 = In catching turtorial, 0 = Not in catching turtorial]
	sBattlerAbilities = 0x00000000,
	gBattlerAttacker = 0x00000000,
	gBattlerPartyIndexesSelfSlotOne = 0x00000000,
	gBattlerPartyIndexesEnemySlotOne = 0x00000000,
	gBattlerPartyIndexesSelfSlotTwo = 0x00000000,
	gBattlerPartyIndexesEnemySlotTwo = 0x00000000,
	gBattleMons = 0x00000000,
	gBattlescriptCurrInstr = 0x00000000,
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

-- Maps the BattleScript memory addresses to their respective abilityId's
-- FIRE RED 1.1
GameSettings.ABILITIES = {
	[0x081d92ef] = 2, -- BattleScript_DrizzleActivates
	[0x081d930a] = 3, -- BattleScript_SpeedBoostActivates + 0x7
	-- [0x00000000] = 5, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Sturdy
	-- [0x00000000] = 6, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Damp
	-- [0x00000000] = 7, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Limber
	-- [0x00000000] = 9, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Static
	-- [0x00000000] = 10, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Volt Absorb
	-- [0x00000000] = 11, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Water Absorb
	-- [0x00000000] = 12, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Oblivious
	-- [0x00000000] = 13, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Cloud Nine
	-- [0x00000000] = 15, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Insomnia
	[0x081d950f] = 16, -- BattleScript_ColorChangeActivates + 0x3
	-- [0x00000000] = 17, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Immunity
	-- [0x00000000] = 18, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Flash Fire
	-- [0x00000000] = 19, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Shield Dust
	-- [0x00000000] = 20, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Own Tempo -- No trigger on your own mon
	-- [0x00000000] = 21, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Suction Cups
	[0x081d937d] = 22, -- BattleScript_DoIntimidateActivationAnim
	[0x081d9523] = 24, -- BattleScript_RoughSkinActivates + 0x10
	-- [0x00000000] = 26, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Levitate
	-- [0x00000000] = 27, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Effect Spore
	-- [0x00000000] = 28, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Synchronize
	-- [0x00000000] = 29, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Clear Body
	[0x081d9311] = 36, -- BattleScript_TraceActivates
	-- [0x081d924c] = 38, -- BattleScript_MoveEffectPoison + 0x7 -- BattleScript_ApplySecondaryEffect
	-- [0x00000000] = 43, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Soundproof
	-- [0x00000000] = 44, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Rain Dish
	[0x081d932f] = 45, -- BattleScript_SandstreamActivates
	-- [0x00000000] = 49, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Flame Body
	-- [0x00000000] = 51, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Keen Eye
	-- [0x00000000] = 52, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Hyper Cutter
	[0x081d9567] = 54, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
	-- [0x00000000] = 56, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Cute Charm
	-- [0x00000000] = 60, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Sticky Hold
	[0x081d9346] = 61, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
	-- [0x00000000] = 64, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Liquid Ooze
	[0x081d93e9] = 70, -- BattleScript_DroughtActivates
	-- [0x00000000] = 72, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 Vital Spirit
	-- [0x00000000] = 73, -- BattleScript_xxxxxxxxxxxxxxxxxxx + 0x0 White Smoke
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

		-- Possible memory addresses for checking if the Pokemon's summary has been viewed by the player
		-- 08089fcc l 00000038 PokemonMenu_Summary
		-- 080954dc l 00000068 Task_ShowSummaryScreen
		-- 0809d8bc g 00000134 ShowPokemonSummaryScreen
		-- 0809d9f0 g 0000002c ShowSelectMovePokemonSummaryScreen
		-- 0809df00 l 00000144 LoadPokemonSummaryScreenGraphics
		-- 0809f678 l 0000003a SummaryScreen_GetPokemon
		-- 08e7274c g 000000fc gMenuSummaryGfx
		-- 08e72848 g 00000018 gMenuSummaryPal
		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
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
	elseif gameversion == 0x01400000 then
		print("ROM Detected: Pokemon Ruby v1.1")

		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
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
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
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
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
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
	elseif gameversion == 0x1540000 then
		print("ROM Detected: Pokemon Sapphire v1.1")

		GameSettings.sMonSummaryScreen = 0x00000000
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
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
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
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
	GameSettings.sSpecialFlags = 0x020375fc
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
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerPartyIndexesSelfSlotOne = 0x02023bce
		GameSettings.gBattlerPartyIndexesEnemySlotOne = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x2
		GameSettings.gBattlerPartyIndexesSelfSlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x4
		GameSettings.gBattlerPartyIndexesEnemySlotTwo = GameSettings.gBattlerPartyIndexesSelfSlotOne + 0x6
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
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
		GameSettings.sSpecialFlags = 0x020370e0
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
		GameSettings.sSpecialFlags = 0x020370e0
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
		GameSettings.sSpecialFlags = 0x020370e0
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
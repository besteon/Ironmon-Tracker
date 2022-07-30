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
	gTakenDmg = 0x00000000,
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

GameSettings.RouteInfo = {}

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

	local routeinfo = { -- key:GAME_NUMBER

		-- https://github.com/pret/pokefirered/blob/918ed2d31eeeb036230d0912cc2527b83788bc85/include/constants/layouts.h
		[3] = { -- key: routeId (mapLayoutId)
			[78] = { -- PALLET TOWN
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[79] = { -- VIRIDIAN CITY
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
				},
			},
			[80] = {}, -- PEWTER CITY
			[81] = { -- CERULEAN CITY
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[82] = {}, -- LAVENDER TOWN
			[83] = { -- VERMILION CITY
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {98,116}, rate = 0.04, minLv = 25, maxLv = 30, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[84] = { -- CELADON CITY
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 0.99, minLv = 5, maxLv = 40, },
					{ pokemonID = 109, rate = 0.01, minLv = 30, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 129, rate = 0.99, minLv = 15, maxLv = 35, },
					{ pokemonID = 88, rate = 0.01, minLv = 30, maxLv = 40, },
				},
			},
			[85] = { -- FUCHSIA CITY
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
				},
			},
			[86] = { -- CINNABAR ISLAND
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[87] = {}, -- INDIGO_PLATEAU_EXTERIOR
			[88] = {}, -- SAFFRON_CITY_CONNECTION
			[89] = { -- ROUTE 1
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 16, rate = 0.50, minLv = 2, maxLv = 5, },
					{ pokemonID = 19, rate = 0.50, minLv = 2, maxLv = 4, },
				},
			},
			[90] = { -- ROUTE 2
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 16, rate = 0.45, minLv = 2, maxLv = 5, },
					{ pokemonID = 19, rate = 0.45, minLv = 2, maxLv = 5, },
					{ pokemonID = 10, rate = 0.05, minLv = 4, maxLv = 5, },
					{ pokemonID = 13, rate = 0.05, minLv = 4, maxLv = 5, },
				},
			},
			[91] = { -- ROUTE 3
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 21, rate = 0.35, minLv = 6, maxLv = 8, },
					{ pokemonID = 16, rate = 0.30, minLv = 6, maxLv = 7, },
					{ pokemonID = {32,29}, rate = 0.14, minLv = 6, maxLv = 7, },
					{ pokemonID = 39, rate = 0.10, minLv = 3, maxLv = 7, },
					{ pokemonID = 56, rate = 0.10, minLv = 7, maxLv = 7, },
					{ pokemonID = {29,32}, rate = 0.01, minLv = 6, maxLv = 6, },
				},
			},
			[92] = { -- ROUTE 4
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 19, rate = 0.35, minLv = 8, maxLv = 12, },
					{ pokemonID = 21, rate = 0.35, minLv = 8, maxLv = 12, },
					{ pokemonID = 23, rate = 0.25, minLv = 6, maxLv = 12, },
					{ pokemonID = 56, rate = 0.05, minLv = 10, maxLv = 12, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[93] = { -- ROUTE 5
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 16, rate = 0.40, minLv = 13, maxLv = 16, },
					{ pokemonID = 52, rate = 0.35, minLv = 10, maxLv = 16, },
					{ pokemonID = {43,69}, rate = 0.25, minLv = 13, maxLv = 16, },
				},
			},
			[94] = { -- ROUTE 6
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 16, rate = 0.40, minLv = 13, maxLv = 16, },
					{ pokemonID = 52, rate = 0.35, minLv = 10, maxLv = 16, },
					{ pokemonID = {43,69}, rate = 0.25, minLv = 13, maxLv = 16, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
				},
			},
			[95] = { -- ROUTE 7
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 52, rate = 0.40, minLv = 17, maxLv = 20, },
					{ pokemonID = 16, rate = 0.30, minLv = 19, maxLv = 22, },
					{ pokemonID = {43,69}, rate = 0.20, minLv = 19, maxLv = 22, },
					{ pokemonID = {58,37}, rate = 0.10, minLv = 18, maxLv = 20, },
				},
			},
			[96] = { -- ROUTE 8
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 16, rate = 0.30, minLv = 18, maxLv = 20, },
					{ pokemonID = 52, rate = 0.30, minLv = 18, maxLv = 20, },
					{ pokemonID = {23,27}, rate = 0.20, minLv = 17, maxLv = 19, },
					{ pokemonID = {58,37}, rate = 0.20, minLv = 15, maxLv = 18, },
				},
			},
			[97] = { -- ROUTE 9
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 19, rate = 0.40, minLv = 14, maxLv = 17, },
					{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
					{ pokemonID = {23,27}, rate = 0.25, minLv = 11, maxLv = 17, },
				},
			},
			[98] = { -- ROUTE 10
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 100, rate = 0.40, minLv = 14, maxLv = 17, },
					{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
					{ pokemonID = {23,27}, rate = 0.25, minLv = 11, maxLv = 17, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[99] = { -- ROUTE 11
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {23,27}, rate = 0.40, minLv = 12, maxLv = 15, },
					{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
					{ pokemonID = 96, rate = 0.25, minLv = 11, maxLv = 15, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[100] = { -- ROUTE 12
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
					{ pokemonID = 16, rate = 0.30, minLv = 23, maxLv = 27, },
					{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
					{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
				[Constants.EncounterTypes.STATIC] = {
					{ pokemonID = 143, rate = 1.00, minLv = 30, maxLv = 30, },
				},
			},
			[101] = { -- ROUTE 13
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
					{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
					{ pokemonID = 16, rate = 0.20, minLv = 25, maxLv = 27, },
					{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
					{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
					{ pokemonID = 132, rate = 0.05, minLv = 25, maxLv = 25, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[102] = { -- ROUTE 14
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
					{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
					{ pokemonID = 132, rate = 0.15, minLv = 23, maxLv = 23, },
					{ pokemonID = 16, rate = 0.10, minLv = 27, maxLv = 27, },
					{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
					{ pokemonID = {44,70}, rate = 0.05, minLv = 30, maxLv = 30, },
				},
			},
			[103] = { -- ROUTE 15
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
					{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
					{ pokemonID = 16, rate = 0.20, minLv = 25, maxLv = 27, },
					{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
					{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
					{ pokemonID = 132, rate = 0.05, minLv = 25, maxLv = 25, },
				},
			},
			[104] = { -- ROUTE 16
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 84, rate = 0.35, minLv = 18, maxLv = 22, },
					{ pokemonID = 19, rate = 0.30, minLv = 18, maxLv = 22, },
					{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
					{ pokemonID = 20, rate = 0.05, minLv = 23, maxLv = 25, },
				},
				[Constants.EncounterTypes.STATIC] = {
					{ pokemonID = 143, rate = 1.00, minLv = 30, maxLv = 30, },
				},
			},
			[105] = { -- ROUTE 17
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
					{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
					{ pokemonID = 20, rate = 0.30, minLv = 25, maxLv = 29, },
					{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
					{ pokemonID = 22, rate = 0.05, minLv = 25, maxLv = 27, },
				},
			},
			[106] = { -- ROUTE 18
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
					{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
					{ pokemonID = 20, rate = 0.15, minLv = 25, maxLv = 29, },
					{ pokemonID = 22, rate = 0.15, minLv = 25, maxLv = 29, },
					{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
				},
			},
			[107] = { -- ROUTE 19
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[108] = { -- ROUTE 20
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[109] = { -- ROUTE 21 (North)
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 114, rate = 1.00, minLv = 17, maxLv = 28, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[110] = { -- ROUTE 22
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 19, rate = 0.45, minLv = 2, maxLv = 5, },
					{ pokemonID = 56, rate = 0.45, minLv = 2, maxLv = 5, },
					{ pokemonID = 21, rate = 0.10, minLv = 3, maxLv = 5, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
				},
			},
			[111] = { -- ROUTE 23
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 56, rate = 0.30, minLv = 32, maxLv = 34, },
					{ pokemonID = 22, rate = 0.25, minLv = 40, maxLv = 44, },
					{ pokemonID = {23,27}, rate = 0.20, minLv = 32, maxLv = 34, },
					{ pokemonID = 21, rate = 0.15, minLv = 32, maxLv = 34, },
					{ pokemonID = {24,28}, rate = 0.05, minLv = 44, maxLv = 44, },
					{ pokemonID = 57, rate = 0.05, minLv = 42, maxLv = 42, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
				},
			},
			[112] = { -- ROUTE 24
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {43,69}, rate = 0.25, minLv = 12, maxLv = 14, },
					{ pokemonID = 10, rate = 0.20, minLv = 7, maxLv = 7, },
					{ pokemonID = 13, rate = 0.20, minLv = 7, maxLv = 7, },
					{ pokemonID = 16, rate = 0.15, minLv = 11, maxLv = 13, },
					{ pokemonID = 63, rate = 0.15, minLv = 8, maxLv = 12, },
					{ pokemonID = {14,11}, rate = 0.04, minLv = 8, maxLv = 8, },
					{ pokemonID = {11,14}, rate = 0.01, minLv = 8, maxLv = 8, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
				},
			},
			[113] = { -- ROUTE 25
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {43,69}, rate = 0.25, minLv = 12, maxLv = 14, },
					{ pokemonID = 10, rate = 0.20, minLv = 8, maxLv = 8, },
					{ pokemonID = 13, rate = 0.20, minLv = 8, maxLv = 8, },
					{ pokemonID = 16, rate = 0.15, minLv = 11, maxLv = 13, },
					{ pokemonID = 63, rate = 0.15, minLv = 9, maxLv = 12, },
					{ pokemonID = {14,11}, rate = 0.04, minLv = 9, maxLv = 9, },
					{ pokemonID = {11,14}, rate = 0.01, minLv = 9, maxLv = 9, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
				},
				[Constants.EncounterTypes.OLDROD] = {
					{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
				},
				[Constants.EncounterTypes.GOODROD] = {
					{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
					{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
					{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
				},
				[Constants.EncounterTypes.SUPERROD] = {
					{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
					{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
					{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
					{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
				},
			},
			[114] = { -- MT MOON 1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 41, rate = 0.69, minLv = 7, maxLv = 10, },
					{ pokemonID = 74, rate = 0.25, minLv = 7, maxLv = 9, },
					{ pokemonID = 46, rate = 0.05, minLv = 8, maxLv = 8, },
					{ pokemonID = 35, rate = 0.01, minLv = 8, maxLv = 8, },
				},
			},
			[115] = { -- MT MOON B1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 46, rate = 1.00, minLv = 5, maxLv = 10, },
				},
			},
			[116] = { -- MT MOON B2F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 41, rate = 0.49, minLv = 8, maxLv = 11, },
					{ pokemonID = 74, rate = 0.30, minLv = 9, maxLv = 10, },
					{ pokemonID = 46, rate = 0.15, minLv = 10, maxLv = 12, },
					{ pokemonID = 35, rate = 0.06, minLv = 10, maxLv = 12, },
				},
			},
			[117] = { -- VIRIDIAN FOREST
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 10, rate = 0.40, minLv = 3, maxLv = 5, },
					{ pokemonID = 13, rate = 0.40, minLv = 3, maxLv = 5, },
					{ pokemonID = {14,11}, rate = 0.10, minLv = 4, maxLv = 6, },
					{ pokemonID = {11,14}, rate = 0.05, minLv = 5, maxLv = 5, },
					{ pokemonID = 25, rate = 0.05, minLv = 3, maxLv = 5, },
				},
			},
			[118] = {}, -- SSANNE EXTERIOR
			[119] = {}, -- SSANNE 1F CORRIDOR
			[120] = {}, -- SSANNE 2F CORRIDOR
			[121] = {}, -- SSANNE 3F CORRIDOR
			[122] = {}, -- SSANNE B1F CORRIDOR
			[123] = {}, -- SSANNE DECK

			[999] = { -- ROUTE
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 00, rate = 0.45, minLv = 00, maxLv = 00, },
				},
			},
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

		GameSettings.RouteInfo = routeinfo[GameSettings.game]
	else
		GameSettings.gamename = "Unsupported game"
		Main.DisplayError("This game is unsupported.\n\nOnly RSE/FRLG English versions are currently supported.")
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
		GameSettings.gTakenDmg = 0x02024bf4
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
		GameSettings.gTakenDmg = 0x02024bf4
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
		GameSettings.gTakenDmg = 0x02024bf4
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
		GameSettings.gTakenDmg = 0x02024bf4
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
		GameSettings.gTakenDmg = 0x02024bf4
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
		GameSettings.gTakenDmg = 0x02024bf4
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
	GameSettings.gTakenDmg = 0x020241f8
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

		GameSettings.gBaseStats = 0x082547f4
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
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

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

		GameSettings.gBaseStats = 0x08254784
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
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9015 + 0x10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a11
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a63
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
		print("ROM Detected: Pokemon Rojo Fuego")
		GameSettings.gBaseStats = 0x082547f4
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
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleResults = 0x03004f90
		--this section is not tested but everything was the same so lets hope 
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.FriendshipRequiredToEvo = 0x08042ED8 + 0x13E -- GetEvolutionTargetSpecies (untested)

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
	end
end

function GameSettings.setGameAsFireRedFrench(gameversion)
	if gameversion == 0x00670000 then
		print("ROM Detected: Pokemon Rouge Feu")
		GameSettings.gBaseStats = 0x082547f4
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
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleResults = 0x03004f90
		--this section is not tested but everything was the same so lets hope 
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a

		GameSettings.FriendshipRequiredToEvo = 0x08042ED8 + 0x13E -- GetEvolutionTargetSpecies (untested)

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
	end
end

function GameSettings.setGameAsLeafGreen(gameversion)
	if gameversion == 0x01800000 then
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
		GameSettings.gTakenDmg = 0x02023d58
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
		GameSettings.gTakenDmg = 0x02023d58
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
	local filenameEnding = "AutoSave" .. Constants.Extensions.TRACKED_DATA

	-- Remove trailing " (___)" from game name
	return GameSettings.gamename:gsub("%s%(.*%)", " ") .. filenameEnding
end

--[[
#define LAYOUT_PALLET_TOWN_PLAYERS_HOUSE_1F 1
#define LAYOUT_PALLET_TOWN_PLAYERS_HOUSE_2F 2
#define LAYOUT_PALLET_TOWN_RIVALS_HOUSE 3
#define LAYOUT_LITTLEROOT_TOWN_MAYS_HOUSE_2F 4
#define LAYOUT_PALLET_TOWN_PROFESSOR_OAKS_LAB 5
#define LAYOUT_HOUSE1 6
#define LAYOUT_HOUSE2 7
#define LAYOUT_POKEMON_CENTER_1F 8
#define LAYOUT_POKEMON_CENTER_2F 9
#define LAYOUT_MART 10
#define LAYOUT_HOUSE3 11
#define LAYOUT_CERULEAN_CITY_GYM 12
#define LAYOUT_HOUSE4 13
#define LAYOUT_LAVARIDGE_TOWN_HERB_SHOP 14
#define LAYOUT_CELADON_CITY_GYM 15
#define LAYOUT_RS_POKEMON_CENTER_1F 16
#define LAYOUT_FIVE_ISLAND_RESORT_GORGEOUS_HOUSE 17
#define LAYOUT_PACIFIDLOG_TOWN_HOUSE1 18
#define LAYOUT_PACIFIDLOG_TOWN_HOUSE2 19
#define LAYOUT_FUCHSIA_CITY_GYM 20
#define LAYOUT_HOUSE5 21
#define LAYOUT_UNUSED1 24
#define LAYOUT_VERMILION_CITY_GYM 25
#define LAYOUT_CERULEAN_CITY_BIKE_SHOP 26
#define LAYOUT_CELADON_CITY_GAME_CORNER 27
#define LAYOUT_PEWTER_CITY_GYM 28
#define LAYOUT_FOUR_ISLAND_LORELEIS_HOUSE 30
#define LAYOUT_THREE_ISLAND_HOUSE1 31
#define LAYOUT_RUSTBORO_CITY_CUTTERS_HOUSE 32
#define LAYOUT_FORTREE_CITY_HOUSE1 33
#define LAYOUT_SAFFRON_CITY_GYM 34
#define LAYOUT_FORTREE_CITY_HOUSE2 35
#define LAYOUT_CINNABAR_ISLAND_GYM 36
#define LAYOUT_VIRIDIAN_CITY_GYM 37
#define LAYOUT_RS_SAFARI_ZONE_ENTRANCE 46
#define LAYOUT_BATTLE_COLOSSEUM_2P 47
#define LAYOUT_TRADE_CENTER 48
#define LAYOUT_RECORD_CORNER 49
#define LAYOUT_BATTLE_COLOSSEUM_4P 50
#define LAYOUT_FUCHSIA_CITY_SAFARI_ZONE_ENTRANCE 51
#define LAYOUT_RS_SAFARI_ZONE_NORTHEAST 52
#define LAYOUT_RS_SAFARI_ZONE_SOUTHWEST 53
#define LAYOUT_RS_SAFARI_ZONE_SOUTHEAST 54
#define LAYOUT_FORTREE_CITY_DECORATION_SHOP 55
#define LAYOUT_RS_BATTLE_TOWER 57
#define LAYOUT_SS_TIDAL_CORRIDOR 62
#define LAYOUT_SS_TIDAL_LOWER_DECK 63
#define LAYOUT_SS_TIDAL_ROOMS 64
#define LAYOUT_RUSTBORO_CITY_FLAT2_1F 65
#define LAYOUT_RUSTBORO_CITY_FLAT2_2F 66
#define LAYOUT_RUSTBORO_CITY_FLAT2_3F 67
#define LAYOUT_EVER_GRANDE_CITY_HALL_OF_FAME 68
#define LAYOUT_MOSSDEEP_CITY_EREADER_TRAINER_HOUSE_1F 69
#define LAYOUT_MOSSDEEP_CITY_EREADER_TRAINER_HOUSE_2F 70
#define LAYOUT_SOOTOPOLIS_CITY_HOUSE1 71
#define LAYOUT_SOOTOPOLIS_CITY_HOUSE2 72
#define LAYOUT_SOOTOPOLIS_CITY_HOUSE3 73
#define LAYOUT_RUSTBORO_CITY_FLAT1_1F 74
#define LAYOUT_RUSTBORO_CITY_FLAT1_2F 75
#define LAYOUT_RS_SAFARI_ZONE_REST_HOUSE 77

#define LAYOUT_DIGLETTS_CAVE_B1F 124
#define LAYOUT_VICTORY_ROAD_1F 125
#define LAYOUT_VICTORY_ROAD_2F 126
#define LAYOUT_VICTORY_ROAD_3F 127
#define LAYOUT_ROCKET_HIDEOUT_B1F 128
#define LAYOUT_ROCKET_HIDEOUT_B2F 129
#define LAYOUT_ROCKET_HIDEOUT_B3F 130
#define LAYOUT_ROCKET_HIDEOUT_B4F 131
#define LAYOUT_SILPH_CO_1F 132
#define LAYOUT_SILPH_CO_2F 133
#define LAYOUT_SILPH_CO_3F 134
#define LAYOUT_SILPH_CO_4F 135
#define LAYOUT_SILPH_CO_5F 136
#define LAYOUT_SILPH_CO_6F 137
#define LAYOUT_SILPH_CO_7F 138
#define LAYOUT_SILPH_CO_8F 139
#define LAYOUT_SILPH_CO_9F 140
#define LAYOUT_SILPH_CO_10F 141
#define LAYOUT_SILPH_CO_11F 142
#define LAYOUT_POKEMON_MANSION_1F 143
#define LAYOUT_POKEMON_MANSION_2F 144
#define LAYOUT_POKEMON_MANSION_3F 145
#define LAYOUT_POKEMON_MANSION_B1F 146
#define LAYOUT_SAFARI_ZONE_CENTER 147
#define LAYOUT_SAFARI_ZONE_EAST 148
#define LAYOUT_SAFARI_ZONE_NORTH 149
#define LAYOUT_SAFARI_ZONE_WEST 150
#define LAYOUT_CERULEAN_CAVE_1F 151
#define LAYOUT_CERULEAN_CAVE_2F 152
#define LAYOUT_CERULEAN_CAVE_B1F 153
#define LAYOUT_ROCK_TUNNEL_1F 154
#define LAYOUT_ROCK_TUNNEL_B1F 155
#define LAYOUT_SEAFOAM_ISLANDS_1F 156
#define LAYOUT_SEAFOAM_ISLANDS_B1F 157
#define LAYOUT_SEAFOAM_ISLANDS_B2F 158
#define LAYOUT_SEAFOAM_ISLANDS_B3F 159
#define LAYOUT_SEAFOAM_ISLANDS_B4F 160
#define LAYOUT_POKEMON_TOWER_1F 161
#define LAYOUT_POKEMON_TOWER_2F 162
#define LAYOUT_POKEMON_TOWER_3F 163
#define LAYOUT_POKEMON_TOWER_4F 164
#define LAYOUT_POKEMON_TOWER_5F 165
#define LAYOUT_POKEMON_TOWER_6F 166
#define LAYOUT_POKEMON_TOWER_7F 167
#define LAYOUT_POWER_PLANT 168
#define LAYOUT_ROUTE25_SEA_COTTAGE 169
#define LAYOUT_SSANNE_KITCHEN 170
#define LAYOUT_SSANNE_CAPTAINS_OFFICE 171
#define LAYOUT_UNDERGROUND_PATH_ENTRANCE 172
#define LAYOUT_UNDERGROUND_PATH_EAST_WEST_TUNNEL 173
#define LAYOUT_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL 174
#define LAYOUT_ROUTE12_NORTH_ENTRANCE_1F 176
#define LAYOUT_SSANNE_ROOM1 177
#define LAYOUT_SSANNE_ROOM2 178
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_ELEVATOR 179
#define LAYOUT_PEWTER_CITY_MUSEUM_1F 180
#define LAYOUT_PEWTER_CITY_MUSEUM_2F 181
#define LAYOUT_CERULEAN_CITY_HOUSE2 182
#define LAYOUT_CERULEAN_CITY_HOUSE1 183
#define LAYOUT_CELADON_CITY_CONDOMINIUMS_1F 184
#define LAYOUT_CELADON_CITY_CONDOMINIUMS_2F 185
#define LAYOUT_CELADON_CITY_CONDOMINIUMS_3F 186
#define LAYOUT_CELADON_CITY_CONDOMINIUMS_ROOF 187
#define LAYOUT_CELADON_CITY_CONDOMINIUMS_ROOF_ROOM 188
#define LAYOUT_CELADON_CITY_GAME_CORNER_PRIZE_ROOM 189
#define LAYOUT_CELADON_CITY_RESTAURANT 190
#define LAYOUT_CELADON_CITY_HOTEL 191
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_1F 192
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_2F 193
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_3F 194
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_4F 195
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_5F 196
#define LAYOUT_CELADON_CITY_DEPARTMENT_STORE_ROOF 197
#define LAYOUT_SAFARI_ZONE_REST_HOUSE 198
#define LAYOUT_SAFARI_ZONE_SECRET_HOUSE 199
#define LAYOUT_FUCHSIA_CITY_SAFARI_ZONE_OFFICE 200
#define LAYOUT_FUCHSIA_CITY_WARDENS_HOUSE 201
#define LAYOUT_FUCHSIA_CITY_HOUSE2 202
#define LAYOUT_CINNABAR_ISLAND_POKEMON_LAB_ENTRANCE 203
#define LAYOUT_CINNABAR_ISLAND_POKEMON_LAB_LOUNGE 204
#define LAYOUT_CINNABAR_ISLAND_POKEMON_LAB_RESEARCH_ROOM 205
#define LAYOUT_CINNABAR_ISLAND_POKEMON_LAB_EXPERIMENT_ROOM 206
#define LAYOUT_SAFFRON_CITY 207
#define LAYOUT_SAFFRON_CITY_NORTH_SOUTH_ENTRANCE 208
#define LAYOUT_SAFFRON_CITY_EAST_WEST_ENTRANCE 209
#define LAYOUT_DIGLETTS_CAVE_NORTH_ENTRANCE 210
#define LAYOUT_DIGLETTS_CAVE_SOUTH_ENTRANCE 211
#define LAYOUT_INDIGO_PLATEAU_POKEMON_CENTER_1F 212
#define LAYOUT_POKEMON_LEAGUE_LORELEIS_ROOM 213
#define LAYOUT_POKEMON_LEAGUE_BRUNOS_ROOM 214
#define LAYOUT_POKEMON_LEAGUE_AGATHAS_ROOM 215
#define LAYOUT_POKEMON_LEAGUE_LANCES_ROOM 216
#define LAYOUT_POKEMON_LEAGUE_CHAMPIONS_ROOM 217
#define LAYOUT_POKEMON_LEAGUE_HALL_OF_FAME 218
#define LAYOUT_ROUTE21_SOUTH 219
#define LAYOUT_ENTRANCE_2F 220
#define LAYOUT_ROUTE2_ENTRANCE 221
#define LAYOUT_ROUTE22_NORTH_ENTRANCE 222
#define LAYOUT_ROUTE16_NORTH_ENTRANCE_1F 223
#define LAYOUT_ENTRANCE_1F 224
#define LAYOUT_ROCKET_HIDEOUT_ELEVATOR 225
#define LAYOUT_SAFFRON_CITY_COPYCATS_HOUSE_1F 226
#define LAYOUT_SAFFRON_CITY_COPYCATS_HOUSE_2F 227
#define LAYOUT_SAFFRON_CITY_DOJO 228
#define LAYOUT_SILPH_CO_ELEVATOR 229
#define LAYOUT_ONE_ISLAND 230
#define LAYOUT_TWO_ISLAND 231
#define LAYOUT_THREE_ISLAND 232
#define LAYOUT_FOUR_ISLAND 233
#define LAYOUT_FIVE_ISLAND 234
#define LAYOUT_SEVEN_ISLAND 235
#define LAYOUT_SIX_ISLAND 236
#define LAYOUT_ONE_ISLAND_KINDLE_ROAD 237
#define LAYOUT_ONE_ISLAND_TREASURE_BEACH 238
#define LAYOUT_TWO_ISLAND_CAPE_BRINK 239
#define LAYOUT_THREE_ISLAND_BOND_BRIDGE 240
#define LAYOUT_THREE_ISLAND_PORT 241
#define LAYOUT_PROTOTYPE_SEVII_ISLE_6 242
#define LAYOUT_PROTOTYPE_SEVII_ISLE_7 243
#define LAYOUT_PROTOTYPE_SEVII_ISLE_8 244
#define LAYOUT_PROTOTYPE_SEVII_ISLE_9 245
#define LAYOUT_FIVE_ISLAND_RESORT_GORGEOUS 246
#define LAYOUT_FIVE_ISLAND_WATER_LABYRINTH 247
#define LAYOUT_FIVE_ISLAND_MEADOW 248
#define LAYOUT_FIVE_ISLAND_MEMORIAL_PILLAR 249
#define LAYOUT_SIX_ISLAND_OUTCAST_ISLAND 250
#define LAYOUT_SIX_ISLAND_GREEN_PATH 251
#define LAYOUT_SIX_ISLAND_WATER_PATH 252
#define LAYOUT_SIX_ISLAND_RUIN_VALLEY 253
#define LAYOUT_SEVEN_ISLAND_TRAINER_TOWER 254
#define LAYOUT_SEVEN_ISLAND_SEVAULT_CANYON_ENTRANCE 255
#define LAYOUT_SEVEN_ISLAND_SEVAULT_CANYON 256
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS 257
#define LAYOUT_PROTOTYPE_SEVII_ISLE_22 258
#define LAYOUT_PROTOTYPE_SEVII_ISLE_23_EAST 259
#define LAYOUT_PROTOTYPE_SEVII_ISLE_23_WEST 260
#define LAYOUT_PROTOTYPE_SEVII_ISLE_24 261
#define LAYOUT_UNION_ROOM 262
#define LAYOUT_SAFFRON_CITY_POKEMON_TRAINER_FAN_CLUB 263
#define LAYOUT_SEVEN_ISLAND_HOUSE_ROOM1_DOOR_OPEN 264
#define LAYOUT_SEVEN_ISLAND_HOUSE_ROOM2 265
#define LAYOUT_VIRIDIAN_CITY_HOUSE2 266
#define LAYOUT_CELADON_CITY_RESTAURANT_DUPLICATE 267
#define LAYOUT_CELADON_CITY_HOTEL_DUPLICATE 268
#define LAYOUT_MT_EMBER_RUBY_PATH_B4F 269
#define LAYOUT_THREE_ISLAND_BERRY_FOREST 270
#define LAYOUT_ONE_ISLAND_POKEMON_CENTER_1F 271
#define LAYOUT_TWO_ISLAND_JOYFUL_GAME_CORNER 272
#define LAYOUT_VERMILION_CITY_POKEMON_FAN_CLUB 273
#define LAYOUT_LAVENDER_TOWN_VOLUNTEER_POKEMON_HOUSE 274
#define LAYOUT_ROUTE5_POKEMON_DAY_CARE 275
#define LAYOUT_VIRIDIAN_CITY_HOUSE1 276
#define LAYOUT_FOUR_ISLAND_POKEMON_DAY_CARE 277
#define LAYOUT_SEAFOAM_ISLANDS_B3F_CURRENT_STOPPED 278
#define LAYOUT_SEAFOAM_ISLANDS_B4F_CURRENT_STOPPED 279
#define LAYOUT_MT_EMBER_EXTERIOR 280
#define LAYOUT_MT_EMBER_SUMMIT 281
#define LAYOUT_MT_EMBER_SUMMIT_PATH_1F 282
#define LAYOUT_MT_EMBER_SUMMIT_PATH_2F 283
#define LAYOUT_MT_EMBER_SUMMIT_PATH_3F 284
#define LAYOUT_MT_EMBER_RUBY_PATH_1F 285
#define LAYOUT_MT_EMBER_RUBY_PATH_B1F 286
#define LAYOUT_MT_EMBER_RUBY_PATH_B2F 287
#define LAYOUT_MT_EMBER_RUBY_PATH_B3F 288
#define LAYOUT_MT_EMBER_RUBY_PATH_B1F_STAIRS 289
#define LAYOUT_MT_EMBER_RUBY_PATH_B2F_STAIRS 290
#define LAYOUT_MT_EMBER_RUBY_PATH_B5F 291
#define LAYOUT_FIVE_ISLAND_ROCKET_WAREHOUSE 292
#define LAYOUT_FOUR_ISLAND_ICEFALL_CAVE_ENTRANCE 293
#define LAYOUT_FOUR_ISLAND_ICEFALL_CAVE_1F 294
#define LAYOUT_FOUR_ISLAND_ICEFALL_CAVE_B1F 295
#define LAYOUT_FOUR_ISLAND_ICEFALL_CAVE_BACK 296
#define LAYOUT_TRAINER_TOWER_LOBBY 297
#define LAYOUT_TRAINER_TOWER_1F 298
#define LAYOUT_TRAINER_TOWER_2F 299
#define LAYOUT_TRAINER_TOWER_3F 300
#define LAYOUT_TRAINER_TOWER_4F 301
#define LAYOUT_TRAINER_TOWER_5F 302
#define LAYOUT_TRAINER_TOWER_6F 303
#define LAYOUT_TRAINER_TOWER_7F 304
#define LAYOUT_TRAINER_TOWER_8F 305
#define LAYOUT_TRAINER_TOWER_ROOF 306
#define LAYOUT_TRAINER_TOWER_ELEVATOR 307
#define LAYOUT_CERULEAN_CITY_HOUSE5 308
#define LAYOUT_SIX_ISLAND_DOTTED_HOLE_1F 309
#define LAYOUT_SIX_ISLAND_DOTTED_HOLE_B1F 310
#define LAYOUT_SIX_ISLAND_DOTTED_HOLE_B2F 311
#define LAYOUT_SIX_ISLAND_DOTTED_HOLE_B3F 312
#define LAYOUT_SIX_ISLAND_DOTTED_HOLE_B4F 313
#define LAYOUT_SIX_ISLAND_DOTTED_HOLE_SAPPHIRE_ROOM 314
#define LAYOUT_ISLAND_HARBOR 315
#define LAYOUT_ONE_ISLAND_POKEMON_CENTER_2F 316
#define LAYOUT_SIX_ISLAND_PATTERN_BUSH 317
#define LAYOUT_THREE_ISLAND_DUNSPARCE_TUNNEL 318
#define LAYOUT_THREE_ISLAND_DUNSPARCE_TUNNEL_DUG_OUT 319
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ENTRANCE 320
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM1 321
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM2 322
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM3 323
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM4 324
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM5 325
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM6 326
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM7 327
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM8 328
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM9 329
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM10 330
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM11 331
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM12 332
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM13 333
#define LAYOUT_FIVE_ISLAND_LOST_CAVE_ROOM14 334
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_MONEAN_CHAMBER 335
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_LIPTOO_CHAMBER 336
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_WEEPTH_CHAMBER 337
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_DILFORD_CHAMBER 338
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_SCUFIB_CHAMBER 339
#define LAYOUT_SIX_ISLAND_ALTERING_CAVE 340
#define LAYOUT_SEVEN_ISLAND_SEVAULT_CANYON_TANOBY_KEY 341
#define LAYOUT_BIRTH_ISLAND_EXTERIOR 342
#define LAYOUT_NAVEL_ROCK_EXTERIOR 343
#define LAYOUT_NAVEL_ROCK_1F 344
#define LAYOUT_NAVEL_ROCK_SUMMIT 345
#define LAYOUT_NAVEL_ROCK_BASE 346
#define LAYOUT_NAVEL_ROCK_SUMMIT_PATH_2F 347
#define LAYOUT_NAVEL_ROCK_SUMMIT_PATH_3F 348
#define LAYOUT_NAVEL_ROCK_SUMMIT_PATH_4F 349
#define LAYOUT_NAVEL_ROCK_SUMMIT_PATH_5F 350
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B1F 351
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B2F 352
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B3F 353
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B4F 354
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B5F 355
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B6F 356
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B7F 357
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B8F 358
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B9F 359
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B10F 360
#define LAYOUT_NAVEL_ROCK_BASE_PATH_B11F 361
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_RIXY_CHAMBER 362
#define LAYOUT_SEVEN_ISLAND_TANOBY_RUINS_VIAPOIS_CHAMBER 363
#define LAYOUT_NAVEL_ROCK_B1F 364
#define LAYOUT_NAVEL_ROCK_FORK 365
#define LAYOUT_TRAINER_TOWER_1F_DOUBLES 366
#define LAYOUT_TRAINER_TOWER_2F_DOUBLES 367
#define LAYOUT_TRAINER_TOWER_3F_DOUBLES 368
#define LAYOUT_TRAINER_TOWER_4F_DOUBLES 369
#define LAYOUT_TRAINER_TOWER_5F_DOUBLES 370
#define LAYOUT_TRAINER_TOWER_6F_DOUBLES 371
#define LAYOUT_TRAINER_TOWER_7F_DOUBLES 372
#define LAYOUT_TRAINER_TOWER_8F_DOUBLES 373
#define LAYOUT_TRAINER_TOWER_1F_KNOCKOUT 374
#define LAYOUT_TRAINER_TOWER_2F_KNOCKOUT 375
#define LAYOUT_TRAINER_TOWER_3F_KNOCKOUT 376
#define LAYOUT_TRAINER_TOWER_4F_KNOCKOUT 377
#define LAYOUT_TRAINER_TOWER_5F_KNOCKOUT 378
#define LAYOUT_TRAINER_TOWER_6F_KNOCKOUT 379
#define LAYOUT_TRAINER_TOWER_7F_KNOCKOUT 380
#define LAYOUT_TRAINER_TOWER_8F_KNOCKOUT 381
#define LAYOUT_SEVEN_ISLAND_HOUSE_ROOM1 382
#define LAYOUT_ONE_ISLAND_KINDLE_ROAD_EMBER_SPA 383


]]
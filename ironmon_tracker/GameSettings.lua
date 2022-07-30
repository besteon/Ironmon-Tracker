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

	local routeinfo = { -- key: GAME_NUMBER
		-- https://github.com/pret/pokefirered/blob/918ed2d31eeeb036230d0912cc2527b83788bc85/include/constants/layouts.h
		-- https://www.serebii.net/pokearth/kanto/3rd/route1.shtml
		[3] = { -- key: routeId (mapLayoutId)
			[12] = {}, -- CERULEAN CITY GYM
			[15] = {}, -- CELADON CITY GYM
			[20] = {}, -- FUCHSIA CITY GYM
			[25] = {}, -- VERMILION CITY GYM
			[28] = {}, -- PEWTER CITY GYM
			[34] = {}, -- SAFFRON CITY GYM
			[36] = {}, -- CINNABAR ISLAND GYM
			[37] = {}, -- VIRIDIAN CITY GYM
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
			[124] = { -- DIGLETTS CAVE B1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 50, rate = 0.95, minLv = 15, maxLv = 22, },
					{ pokemonID = 51, rate = 0.05, minLv = 29, maxLv = 31, },
				},
			},
			[125] = { -- VICTORY ROAD 1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 95, rate = 0.30, minLv = 40, maxLv = 46, },
					{ pokemonID = 66, rate = 0.20, minLv = 32, maxLv = 32, },
					{ pokemonID = 74, rate = 0.20, minLv = 32, maxLv = 32, },
					{ pokemonID = 41, rate = 0.10, minLv = 32, maxLv = 32, },
					{ pokemonID = {24,28}, rate = 0.05, minLv = 44, maxLv = 44, },
					{ pokemonID = 42, rate = 0.05, minLv = 44, maxLv = 44, },
					{ pokemonID = 67, rate = 0.05, minLv = 44, maxLv = 46, },
					{ pokemonID = 105, rate = 0.05, minLv = 44, maxLv = 46, },
				},
			},
			[126] = { -- VICTORY ROAD 2F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 66, rate = 0.20, minLv = 34, maxLv = 34, },
					{ pokemonID = 74, rate = 0.20, minLv = 34, maxLv = 34, },
					{ pokemonID = 95, rate = 0.20, minLv = 45, maxLv = 48, },
					{ pokemonID = 41, rate = 0.10, minLv = 34, maxLv = 34, },
					{ pokemonID = 57, rate = 0.10, minLv = 42, maxLv = 42, },
					{ pokemonID = {24,28}, rate = 0.05, minLv = 46, maxLv = 46, },
					{ pokemonID = 42, rate = 0.05, minLv = 46, maxLv = 48, },
					{ pokemonID = 67, rate = 0.05, minLv = 46, maxLv = 48, },
					{ pokemonID = 105, rate = 0.05, minLv = 46, maxLv = 48, },
				},
			},
			[127] = { -- VICTORY ROAD 3F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 95, rate = 0.30, minLv = 40, maxLv = 46, },
					{ pokemonID = 66, rate = 0.20, minLv = 32, maxLv = 32, },
					{ pokemonID = 74, rate = 0.20, minLv = 32, maxLv = 32, },
					{ pokemonID = 41, rate = 0.10, minLv = 32, maxLv = 32, },
					{ pokemonID = {24,28}, rate = 0.05, minLv = 44, maxLv = 44, },
					{ pokemonID = 42, rate = 0.05, minLv = 44, maxLv = 44, },
					{ pokemonID = 67, rate = 0.05, minLv = 44, maxLv = 46, },
					{ pokemonID = 105, rate = 0.05, minLv = 44, maxLv = 46, },
				},
			},
			[128] = {}, -- LAYOUT_ROCKET_HIDEOUT_B1F
			[132] = {}, -- LAYOUT_SILPH_CO_1F
			[143] = { -- POKEMON MANSION 1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
					{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
					{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
					{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
					{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
					{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
				},
			},
			[144] = { -- POKEMON MANSION 2F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
					{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
					{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
					{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
					{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
					{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
				},
			},
			[145] = { -- POKEMON MANSION 3F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
					{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
					{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
					{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
					{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
					{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
				},
			},
			[146] = { -- POKEMON MANSION B1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 20, rate = 0.30, minLv = 34, maxLv = 38, },
					{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
					{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
					{ pokemonID = 132, rate = 0.10, minLv = 30, maxLv = 30, },
					{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
					{ pokemonID = 19, rate = 0.05, minLv = 26, maxLv = 26, },
					{ pokemonID = {110,89}, rate = 0.05, minLv = 34, maxLv = 34, },
				},
			},
			[147] = {}, -- SAFARI ZONE CENTER
			[148] = {}, -- SAFARI ZONE EAST
			[149] = {}, -- SAFARI ZONE NORTH
			[150] = {}, -- SAFARI ZONE WEST
			[151] = { -- CERULEAN CAVE 1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 47, rate = 0.25, minLv = 49, maxLv = 58, },
					{ pokemonID = 82, rate = 0.20, minLv = 49, maxLv = 49, },
					{ pokemonID = 42, rate = 0.14, minLv = 46, maxLv = 55, },
					{ pokemonID = 57, rate = 0.11, minLv = 52, maxLv = 61, },
					{ pokemonID = 132, rate = 0.11, minLv = 52, maxLv = 61, },
					{ pokemonID = 67, rate = 0.10, minLv = 46, maxLv = 46, },
					{ pokemonID = 101, rate = 0.05, minLv = 58, maxLv = 58, },
					{ pokemonID = 202, rate = 0.04, minLv = 55, maxLv = 55, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 0.65, minLv = 30, maxLv = 50, },
					{ pokemonID = {55,80}, rate = 0.35, minLv = 40, maxLv = 55, },
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
				[Constants.EncounterTypes.ROCKSMASH] = {
					{ pokemonID = 74, rate = 0.65, minLv = 30, maxLv = 50, },
					{ pokemonID = 75, rate = 0.35, minLv = 40, maxLv = 55, },
				},
			},
			[152] = { -- CERULEAN CAVE 2F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 42, rate = 0.25, minLv = 49, maxLv = 58, },
					{ pokemonID = 67, rate = 0.20, minLv = 49, maxLv = 49, },
					{ pokemonID = 47, rate = 0.14, minLv = 52, maxLv = 61, },
					{ pokemonID = 64, rate = 0.11, minLv = 55, maxLv = 64, },
					{ pokemonID = 132, rate = 0.11, minLv = 55, maxLv = 64, },
					{ pokemonID = 82, rate = 0.10, minLv = 52, maxLv = 52, },
					{ pokemonID = 202, rate = 0.05, minLv = 58, maxLv = 58, },
					{ pokemonID = 101, rate = 0.04, minLv = 61, maxLv = 61, },
				},
				[Constants.EncounterTypes.ROCKSMASH] = {
					{ pokemonID = 74, rate = 0.65, minLv = 30, maxLv = 50, },
					{ pokemonID = 75, rate = 0.35, minLv = 40, maxLv = 55, },
				},
			},
			[153] = { -- CERULEAN CAVE B1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 64, rate = 0.25, minLv = 58, maxLv = 67, },
					{ pokemonID = 132, rate = 0.25, minLv = 58, maxLv = 67, },
					{ pokemonID = 47, rate = 0.14, minLv = 55, maxLv = 64, },
					{ pokemonID = 42, rate = 0.11, minLv = 52, maxLv = 61, },
					{ pokemonID = 67, rate = 0.10, minLv = 52, maxLv = 52, },
					{ pokemonID = 82, rate = 0.10, minLv = 55, maxLv = 55, },
					{ pokemonID = 101, rate = 0.04, minLv = 64, maxLv = 64, },
					{ pokemonID = 202, rate = 0.01, minLv = 61, maxLv = 61, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = {54,79}, rate = 0.65, minLv = 30, maxLv = 50, },
					{ pokemonID = {55,80}, rate = 0.35, minLv = 40, maxLv = 55, },
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
				[Constants.EncounterTypes.ROCKSMASH] = {
					{ pokemonID = 74, rate = 0.65, minLv = 30, maxLv = 50, },
					{ pokemonID = 75, rate = 0.35, minLv = 40, maxLv = 55, },
				},
				[Constants.EncounterTypes.STATIC] = {
					{ pokemonID = 150, rate = 1.00, minLv = 70, maxLv = 70, },
				},
			},
			[154] = { -- ROCK TUNNEL 1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 74, rate = 0.35, minLv = 15, maxLv = 17, },
					{ pokemonID = 41, rate = 0.30, minLv = 15, maxLv = 16, },
					{ pokemonID = 56, rate = 0.15, minLv = 16, maxLv = 17, },
					{ pokemonID = 66, rate = 0.15, minLv = 16, maxLv = 17, },
					{ pokemonID = 95, rate = 0.05, minLv = 13, maxLv = 15, },
				},
			},
			[155] = { -- ROCK TUNNEL B1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 74, rate = 0.35, minLv = 15, maxLv = 17, },
					{ pokemonID = 41, rate = 0.30, minLv = 15, maxLv = 16, },
					{ pokemonID = 56, rate = 0.15, minLv = 16, maxLv = 17, },
					{ pokemonID = 66, rate = 0.10, minLv = 17, maxLv = 17, },
					{ pokemonID = 95, rate = 0.10, minLv = 13, maxLv = 17, },
				},
				[Constants.EncounterTypes.ROCKSMASH] = {
					{ pokemonID = 74, rate = 0.95, minLv = 5, maxLv = 30, },
					{ pokemonID = 75, rate = 0.05, minLv = 25, maxLv = 40, },
				},
			},
			[156] = { -- SEAFOAM ISLANDS 1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {54,79}, rate = 0.55, minLv = 26, maxLv = 33, },
					{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
					{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
				},
			},
			[157] = { -- SEAFOAM ISLANDS B1F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {54,79}, rate = 0.40, minLv = 29, maxLv = 31, },
					{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
					{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
					{ pokemonID = 86, rate = 0.10, minLv = 28, maxLv = 28, },
					{ pokemonID = {55,80}, rate = 0.05, minLv = 33, maxLv = 35, },
				},
			},
			[158] = { -- SEAFOAM ISLANDS B2F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = {54,79}, rate = 0.40, minLv = 30, maxLv = 32, },
					{ pokemonID = 41, rate = 0.20, minLv = 22, maxLv = 24, },
					{ pokemonID = 86, rate = 0.20, minLv = 30, maxLv = 32, },
					{ pokemonID = 42, rate = 0.10, minLv = 26, maxLv = 30, },
					{ pokemonID = {55,80}, rate = 0.10, minLv = 32, maxLv = 34, },
				},
			},
			[159] = { -- SEAFOAM ISLANDS B3F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 86, rate = 0.40, minLv = 30, maxLv = 32, },
					{ pokemonID = {54,79}, rate = 0.20, minLv = 30, maxLv = 32, },
					{ pokemonID = {55,80}, rate = 0.15, minLv = 32, maxLv = 34, },
					{ pokemonID = 41, rate = 0.10, minLv = 24, maxLv = 24, },
					{ pokemonID = 42, rate = 0.10, minLv = 26, maxLv = 30, },
					{ pokemonID = 87, rate = 0.05, minLv = 32, maxLv = 34, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 86, rate = 0.60, minLv = 25, maxLv = 35, },
					{ pokemonID = {116,98}, rate = 0.30, minLv = 25, maxLv = 30, },
					{ pokemonID = 87, rate = 0.05, minLv = 35, maxLv = 40, },
					{ pokemonID = {54,79}, rate = 0.04, minLv = 30, maxLv = 40, },
					{ pokemonID = {55,80}, rate = 0.01, minLv = 35, maxLv = 40, },
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
					{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 30, },
					{ pokemonID = 130, rate = 0.16, minLv = 15, maxLv = 35, },
					{ pokemonID = {54,79}, rate = 0.04, minLv = 15, maxLv = 25, },
				},
			},
			[160] = { -- SEAFOAM ISLANDS B4F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 86, rate = 0.50, minLv = 30, maxLv = 34, },
					{ pokemonID = 42, rate = 0.15, minLv = 26, maxLv = 30, },
					{ pokemonID = {55,80}, rate = 0.15, minLv = 32, maxLv = 34, },
					{ pokemonID = {54,79}, rate = 0.10, minLv = 32, maxLv = 32, },
					{ pokemonID = 87, rate = 0.10, minLv = 34, maxLv = 36, },
				},
				[Constants.EncounterTypes.SURFING] = {
					{ pokemonID = 86, rate = 0.60, minLv = 25, maxLv = 35, },
					{ pokemonID = {116,98}, rate = 0.30, minLv = 25, maxLv = 30, },
					{ pokemonID = 87, rate = 0.05, minLv = 35, maxLv = 40, },
					{ pokemonID = {54,79}, rate = 0.04, minLv = 30, maxLv = 40, },
					{ pokemonID = {55,80}, rate = 0.01, minLv = 35, maxLv = 40, },
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
					{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 30, },
					{ pokemonID = 130, rate = 0.16, minLv = 15, maxLv = 35, },
					{ pokemonID = {54,79}, rate = 0.04, minLv = 15, maxLv = 25, },
				},
				[Constants.EncounterTypes.STATIC] = {
					{ pokemonID = 144, rate = 1.00, minLv = 50, maxLv = 50, },
				},
			},
			[161] = {}, -- POKEMON TOWER 1F
			[162] = {}, -- POKEMON TOWER 2F
			[163] = { -- POKEMON TOWER 3F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 92, rate = 0.90, minLv = 13, maxLv = 19, },
					{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
					{ pokemonID = 93, rate = 0.01, minLv = 20, maxLv = 20, },
				},
			},
			[164] = { -- POKEMON TOWER 4F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
					{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
					{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
				},
			},
			[165] = { -- POKEMON TOWER 5F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
					{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
					{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
				},
			},
			[166] = { -- POKEMON TOWER 6F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 92, rate = 0.85, minLv = 17, maxLv = 19, },
					{ pokemonID = 104, rate = 0.09, minLv = 17, maxLv = 19, },
					{ pokemonID = 93, rate = 0.06, minLv = 21, maxLv = 23, },
				},
				[Constants.EncounterTypes.STATIC] = {
					{ pokemonID = 105, rate = 1.00, minLv = 30, maxLv = 30, },
				},
			},
			[167] = { -- POKEMON TOWER 7F
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 92, rate = 0.75, minLv = 15, maxLv = 19, },
					{ pokemonID = 93, rate = 0.15, minLv = 23, maxLv = 25, },
					{ pokemonID = 104, rate = 0.10, minLv = 17, maxLv = 19, },
				},
			},
			[168] = { -- POWER PLANT
				[Constants.EncounterTypes.GRASS] = {
					{ pokemonID = 81, rate = 0.30, minLv = 22, maxLv = 25, },
					{ pokemonID = 100, rate = 0.30, minLv = 22, maxLv = 25, },
					{ pokemonID = 25, rate = 0.25, minLv = 22, maxLv = 26, },
					{ pokemonID = 82, rate = 0.10, minLv = 31, maxLv = 34, },
					{ pokemonID = 125, rate = 0.05, minLv = 32, maxLv = 35, },
				},
				[Constants.EncounterTypes.STATIC] = {
					{ pokemonID = 145, rate = 1.00, minLv = 50, maxLv = 50, },
				},
			},
			[213] = {}, -- LORELEIS ROOM
			[214] = {}, -- BRUNOS ROOM
			[215] = {}, -- AGATHAS ROOM
			[216] = {}, -- LANCES ROOM
			[217] = {}, -- CHAMPIONS ROOM
			[228] = {}, -- SAFFRON CITY DOJO
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
GameSettings = {
	game = 0,
	gamename = "",
	versiongroup = 0,
	versioncolor = "",
	badgePrefix = "",
	badgeXOffsets = { 0, 0, 0, 0, 0, 0, 0, 0 },
	pstats = 0,
	estats = 0,

	gBaseStats = 0x00000000,
	gBattleMoves = 0x00000000,
	sMonSummaryScreen = 0x00000000,
	sStartMenuWindowId = 0x00000000,
	sSpecialFlags = 0x00000000, -- [3 = In catching tutorial, 0 = Not in catching tutorial]
	sBattlerAbilities = 0x00000000,
	gBattlerAttacker = 0x00000000,
	gBattlerTarget = 0x00000000,
	gBattlerPartyIndexes = 0x00000000,
	gBattleMons = 0x00000000,
	gBattlescriptCurrInstr = 0x00000000,
	gTakenDmg = 0x00000000,
	gBattleScriptingBattler = 0x00000000,
	gBattleResults = 0x00000000,
	BattleScript_FocusPunchSetUp = 0x00000000,
	BattleScript_LearnMoveLoop = 0x00000000,
	BattleScript_LearnMoveReturn = 0x00000000,
	gMoveToLearn = 0x00000000,
	gBattleOutcome = 0x00000000, -- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
	gMoveResultFlags = 0x00000000,
	gBattleWeather = 0x00000000,

	gMapHeader = 0x00000000,
	gBattleTerrain = 0x00000000,
	gBattleTypeFlags = 0x00000000,
	FriendshipRequiredToEvo = 0x00000000,

	gSaveBlock1 = 0x00000000,
	gSaveBlock1ptr = 0x00000000, -- Doesn't exist in Ruby/Sapphire
	gSaveBlock2ptr = 0x00000000, -- Doesn't exist in Ruby/Sapphire
	gameStatsOffset = 0x0,
	gameVarsOffset = 0x0, -- SaveBlock1 -> vars[VARS_COUNT]
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
	elseif gamecode == 0x42505244 then
		GameSettings.setGameAsFireRedGermany(gameversion)
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
			VERSION_COLOR = "Ruby",
			PSTATS = 0x3004360,
			ESTATS = 0x30045C0,
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x41585045] = {
			GAME_NUMBER = 1,
			GAME_NAME = "Pokemon Sapphire (U)",
			VERSION_GROUP = 1,
			VERSION_COLOR = "Sapphire",
			PSTATS = 0x3004360,
			ESTATS = 0x30045C0,
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x42504545] = {
			GAME_NUMBER = 2,
			GAME_NAME = "Pokemon Emerald (U)",
			VERSION_GROUP = 1,
			VERSION_COLOR = "Emerald",
			PSTATS = 0x20244EC,
			ESTATS = 0x2024744,
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x42505245] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon FireRed (U)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505249] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon - Rosso Fuoco (Italy)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505253] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rojo Fuego (Spain)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505246] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rouge Feu (France)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505244] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Feuerrote (Germany)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42504745] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon LeafGreen (U)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "LeafGreen",
			PSTATS = 0x2024284,
			ESTATS = 0x202402C,
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
	}

	if games[gamecode] ~= nil then
		GameSettings.game = games[gamecode].GAME_NUMBER
		GameSettings.gamename = games[gamecode].GAME_NAME
		GameSettings.versiongroup = games[gamecode].VERSION_GROUP
		GameSettings.versioncolor = games[gamecode].VERSION_COLOR
		GameSettings.pstats = games[gamecode].PSTATS
		GameSettings.estats = games[gamecode].ESTATS
		GameSettings.badgePrefix = games[gamecode].BADGE_PREFIX
		GameSettings.badgeXOffsets = games[gamecode].BADGE_XOFFSETS

		RouteData.setupRouteInfo(GameSettings.game)
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
		GameSettings.gBattleMoves = 0x081fb12c
		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sEvoInfo = 0x02014800
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerTarget = 0x02024c08
		GameSettings.gBattlerPartyIndexes = 0x02024a6a
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.gTakenDmg = 0x02024bf4
		GameSettings.gBattleScriptingBattler = 0x2000000 + 0x16003 -- gBattleStruct (gSharedMem + 0x0) -> scriptingActive
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.gTasks = 0x03004b20
		GameSettings.Task_EvolutionScene = 0x0811240d --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f0f -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f61
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26
		GameSettings.gMoveResultFlags = 0x02024c68
		GameSettings.gBattleWeather = 0x02024db8
		GameSettings.gBattleCommunication = 0x02024d1e
		GameSettings.gBattlersCount = 0x02024a68
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d9598
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d95a1
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d95d7
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d95fe
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081D9607
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d9548
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d954b
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d954d
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d9557
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d955c
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8e25
		GameSettings.gCurrentTurnActionNumber = 0x02024a7e
		GameSettings.gActionsByTurnOrder = 0x02024a76
		GameSettings.gHitMarker = 0x02024c6c
		GameSettings.gBattleTextBuff1 = 0x030041c0
		GameSettings.gBattleBuffersTransferData = 0x03004040
		GameSettings.gBattleControllerExecFlags = 0x02024a64

		GameSettings.gMapHeader = 0x0202e828
		GameSettings.gBattleTerrain = 0x0300428c
		GameSettings.gBattleTypeFlags = 0x020239f8
		GameSettings.gSpecialVar_ItemId = 0x0203855e -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x0202e8dc -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.gameVarsOffset = 0x1340
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
				[0x081d9704] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d971f] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d97f6] = {[22] = true}, -- BattleScript_1D97F0 + 0x6 Intimidate Fail
				[0x081d97de] = {[22] = true}, -- BattleScript_1D97A1 + 0x3d Intimidate Succeed
				[0x081d972c] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d7e76] = {[43] = true}, -- BattleScript_1D7E73 + 0x3 Soundproof 3 (Perish Song)
				[0x081d9744] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d975b] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d97fe] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d98a1] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d9909] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d97f6] = { -- BattleScript_1D97F0 + 0x6 Intimidate Fail
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d982c] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d98c9] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d9924] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d9885] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d98e5] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d9893] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d9938] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d994c] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d9913] = {[60] = true}, -- BattleScript_NoItemSteal + 0x0 Sticky Hold
				[0x081d7053] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9819] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d9857] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d986d] = { -- BattleScript_MoveHPDrain_FullHP + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d98b9] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d98c5] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d98ad] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6fe8] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081d8839] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d9733] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d997c] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d74ce] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d9645] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d968e] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d9661] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9670] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d983a] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d98fb] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7bde] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d9095] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	elseif gameversion == 0x01400000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev1.sym
		print("ROM Detected: Pokemon Ruby v1.1")

		GameSettings.gBaseStats = 0x081fec30
		GameSettings.gBattleMoves = 0x081fb144
		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sEvoInfo = 0x02014800
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02024a6a
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.gTakenDmg = 0x02024bf4
		GameSettings.gBattleScriptingBattler = 0x2000000 + 0x16003 -- gBattleStruct (gSharedMem + 0x0) -> scriptingActive
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.gTasks = 0x03004b20
		GameSettings.Task_EvolutionScene = 0x0811244d  --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f27 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f79
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26
		GameSettings.gMoveResultFlags = 0x02024c68
		GameSettings.gBattleWeather = 0x02024db8
		GameSettings.gBattleCommunication = 0x02024d1e
		GameSettings.gBattlersCount = 0x02024a68
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d95b0
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d95b9
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d95ef
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d9616
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d961f
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d9560
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d9563
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d9565
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d956f
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d9574
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8e3d
		GameSettings.gCurrentTurnActionNumber = 0x02024a7e
		GameSettings.gActionsByTurnOrder = 0x02024a76
		GameSettings.gHitMarker = 0x02024c6c
		GameSettings.gBattleTextBuff1 = 0x030041c0
		GameSettings.gBattleBuffersTransferData = 0x03004040
		GameSettings.gBattleControllerExecFlags = 0x02024a64

		GameSettings.gMapHeader = 0x0202e828
		GameSettings.gBattleTerrain = 0x0300428c
		GameSettings.gBattleTypeFlags = 0x020239f8
		GameSettings.gSpecialVar_ItemId = 0x0203855e -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x0202e8dc -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.gameVarsOffset = 0x1340
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
				[0x081d971c] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d9737] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d980e] = {[22] = true}, -- BattleScript_1D97F0 + 0x6 Intimidate Fail
				[0x081d97f6] = {[22] = true}, -- BattleScript_1D97A1 + 0x3d Intimidate Succeed
				[0x081d9744] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d7e8e] = {[43] = true}, -- BattleScript_1D7E73 + 0x3 Soundproof 3 (Perish Song)
				[0x081d975c] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d9773] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d9816] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d98b9] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d9921] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d980e] = { -- BattleScript_1D97F0 + 0x6 Intimidate Fail
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d9844] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d98e1] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d993c] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d989d] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d98fd] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d98ab] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d9950] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d9964] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d992b] = {[60] = true}, -- BattleScript_NoItemSteal + 0x0 Sticky Hold
				[0x081d706b] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9831] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d986f] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9885] = { -- BattleScript_MoveHPDrain_FullHP + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d98d1] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d98dd] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d98c5] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d7000] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081d8851] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d974b] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9994] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d74e6] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d965d] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d96a6] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d9679] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9688] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d9852] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d9913] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7bf6] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d90ad] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	elseif gameversion == 0x023F0000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev2.sym
		print("ROM Detected: Pokemon Ruby v1.2")

		GameSettings.gBaseStats = 0x081fec30
		GameSettings.gBattleMoves = 0x081fb144
		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sEvoInfo = 0x02014800
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02024a6a
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.gTakenDmg = 0x02024bf4
		GameSettings.gBattleScriptingBattler = 0x2000000 + 0x16003 -- gBattleStruct (gSharedMem + 0x0) -> scriptingActive
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.gTasks = 0x03004b20
		GameSettings.Task_EvolutionScene = 0x0811242d --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8f27 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f79
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26
		GameSettings.gMoveResultFlags = 0x02024c68
		GameSettings.gBattleWeather = 0x02024db8
		GameSettings.gBattleCommunication = 0x02024d1e
		GameSettings.gBattlersCount = 0x02024a68
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d95b0
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d95b9
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d95ef
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d9616
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d961f
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d9560
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d9563
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d9565
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d956f
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d9574
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8e3d
		GameSettings.gCurrentTurnActionNumber = 0x02024a7e
		GameSettings.gActionsByTurnOrder = 0x02024a76
		GameSettings.gHitMarker = 0x02024c6c
		GameSettings.gBattleTextBuff1 = 0x030041c0
		GameSettings.gBattleBuffersTransferData = 0x03004040
		GameSettings.gBattleControllerExecFlags = 0x02024a64

		GameSettings.gMapHeader = 0x0202e828
		GameSettings.gBattleTerrain = 0x0300428c
		GameSettings.gBattleTypeFlags = 0x020239f8
		GameSettings.gSpecialVar_ItemId = 0x0203855e -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x0202e8dc -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.gameVarsOffset = 0x1340
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
				[0x081d971c] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d9737] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d980e] = {[22] = true}, -- BattleScript_1D97F0 + 0x6 Intimidate Fail
				[0x081d97f6] = {[22] = true}, -- BattleScript_1D97A1 + 0x3d Intimidate Succeed
				[0x081d9744] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d7e8e] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d975c] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d9773] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d9816] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d98b9] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d9921] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d980e] = { -- BattleScript_1D97F0 + 0x6 Intimidate Fail
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d9844] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d98e1] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d993c] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d989d] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d98fd] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d98ab] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d9950] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d9964] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d992b] = {[60] = true}, -- BattleScript_NoItemSteal + 0x0 Sticky Hold
				[0x081d706b] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9831] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d986f] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9885] = { -- BattleScript_MoveHPDrain_FullHP + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d98d1] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d98dd] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d98c5] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d7000] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081d8851] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d974b] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9994] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d74e6] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d965d] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d96a6] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d9679] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9688] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d9852] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d9913] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7bf6] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d90ad] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	end
end

function GameSettings.setGameAsSapphire(gameversion)
	if gameversion == 0x00550000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire.sym
		print("ROM Detected: Pokemon Sapphire v1.0")

		GameSettings.gBaseStats = 0x081feba8
		GameSettings.gBattleMoves = 0x081fb0bc
		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sEvoInfo = 0x02014800
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02024a6a
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.gTakenDmg = 0x02024bf4
		GameSettings.gBattleScriptingBattler = 0x2000000 + 0x16003 -- gBattleStruct (gSharedMem + 0x0) -> scriptingActive
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.gTasks = 0x03004b20
		GameSettings.Task_EvolutionScene = 0x0811240d --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8e9f -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ef1
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26
		GameSettings.gMoveResultFlags = 0x02024c68
		GameSettings.gBattleWeather = 0x02024db8
		GameSettings.gBattleCommunication = 0x02024d1e
		GameSettings.gBattlersCount = 0x02024a68
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d9528
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d9531
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d9567
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d958e
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d9597
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d94d8
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d94db
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d94dd
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d94e7
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d94ec
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8db5
		GameSettings.gCurrentTurnActionNumber = 0x02024a7e
		GameSettings.gActionsByTurnOrder = 0x02024a76
		GameSettings.gHitMarker = 0x02024c6c
		GameSettings.gBattleTextBuff1 = 0x030041c0
		GameSettings.gBattleBuffersTransferData = 0x03004040
		GameSettings.gBattleControllerExecFlags = 0x02024a64

		GameSettings.gMapHeader = 0x0202e828
		GameSettings.gBattleTerrain = 0x0300428c
		GameSettings.gBattleTypeFlags = 0x020239f8
		GameSettings.gSpecialVar_ItemId = 0x0203855e -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x0202e8dc -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.gameVarsOffset = 0x1340
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
				[0x081d9694] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d96af] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d9786] = {[22] = true}, -- BattleScript_1D97F0 + 0x6 Intimidate Fail
				[0x081d976e] = {[22] = true}, -- BattleScript_1D97A1 + 0x3d Intimidate Succeed
				[0x081d96bc] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d7e06] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d96d4] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d96eb] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d978e] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d9831] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d9899] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d9786] = { -- BattleScript_1D97F0 + 0x6 Intimidate Fail
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d97bc] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d9859] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d98b4] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d9815] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d9875] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d9823] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d98c8] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d98dc] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d98a3] = {[60] = true}, -- BattleScript_NoItemSteal + 0x0 Sticky Hold
				[0x081d6fe3] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d97a9] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d97e7] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d97fd] = { -- BattleScript_MoveHPDrain_FullHP + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9849] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d9855] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d983d] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6f78] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081d87c9] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d96c3] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d990c] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d745e] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d95d5] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d961e] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d95f1] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9600] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d97ca] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d988b] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7b6e] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d9025] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	elseif gameversion == 0x1540000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev1.sym
		print("ROM Detected: Pokemon Sapphire v1.1")

		GameSettings.gBaseStats = 0x081febc0
		GameSettings.gBattleMoves = 0x081fb0d4
		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sEvoInfo = 0x02014800
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02024a6a
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.gTakenDmg = 0x02024bf4
		GameSettings.gBattleScriptingBattler = 0x2000000 + 0x16003 -- gBattleStruct (gSharedMem + 0x0) -> scriptingActive
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.gTasks = 0x03004b20
		GameSettings.Task_EvolutionScene = 0x0811242d --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8eb7 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f09
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26
		GameSettings.gMoveResultFlags = 0x02024c68
		GameSettings.gBattleWeather = 0x02024db8
		GameSettings.gBattleCommunication = 0x02024d1e
		GameSettings.gBattlersCount = 0x02024a68
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d9540
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d9549
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d957f
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d95a6
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d95af
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d94f0
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d94f3
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d94f5
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d94ff
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d9504
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8dcd
		GameSettings.gCurrentTurnActionNumber = 0x02024a7e
		GameSettings.gActionsByTurnOrder = 0x02024a76
		GameSettings.gHitMarker = 0x02024c6c
		GameSettings.gBattleTextBuff1 = 0x030041c0
		GameSettings.gBattleBuffersTransferData = 0x03004040
		GameSettings.gBattleControllerExecFlags = 0x02024a64

		GameSettings.gMapHeader = 0x0202e828
		GameSettings.gBattleTerrain = 0x0300428c
		GameSettings.gBattleTypeFlags = 0x020239f8
		GameSettings.gSpecialVar_ItemId = 0x0203855e -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x0202e8dc -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.gameVarsOffset = 0x1340
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
				[0x081d96ac] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d96c7] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d979e] = {[22] = true}, -- BattleScript_1D97F0 + 0x6 Intimidate Fail
				[0x081d9786] = {[22] = true}, -- BattleScript_1D97A1 + 0x3d Intimidate Succeed
				[0x081d96d4] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d7e1e] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d96ec] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d9703] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d97a6] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d9849] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d98b1] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d979e] = { -- BattleScript_1D97F0 + 0x6 Intimidate Fail
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d97d4] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d9871] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d98cc] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d982d] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d988d] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d983b] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d98e0] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d98f4] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d98bb] = {[60] = true}, -- BattleScript_NoItemSteal + 0x0 Sticky Hold
				[0x081d6ffb] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d97c1] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d97ff] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9815] = { -- BattleScript_MoveHPDrain_FullHP + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9861] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d986d] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d9855] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6f90] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081d87e1] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d96db] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9924] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d7476] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d95ed] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d9636] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d9609] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9618] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d97e2] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d98a3] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7b86] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d903d] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	elseif gameversion == 0x02530000 then
		-- https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev2.sym
		print("ROM Detected: Pokemon Sapphire v1.2")

		GameSettings.gBaseStats = 0x081febc0
		GameSettings.gBattleMoves = 0x081fb0d4
		GameSettings.sMonSummaryScreen = 0x02000000 + 0x18000 + 0x76 -- pssData (gSharedMem + 0x18000) + lastpage offset
		GameSettings.sEvoInfo = 0x02014800
		GameSettings.sSpecialFlags = 0x0202e8e2 -- gUnknown_0202E8E2
		GameSettings.sBattlerAbilities = 0x0203926c -- gAbilitiesPerBank
		GameSettings.gBattlerAttacker = 0x02024c07
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02024a6a
		GameSettings.gBattleMons = 0x02024a80
		GameSettings.gBattlescriptCurrInstr = 0x02024c10
		GameSettings.gTakenDmg = 0x02024bf4
		GameSettings.gBattleScriptingBattler = 0x2000000 + 0x16003 -- gBattleStruct (gSharedMem + 0x0) -> scriptingActive
		GameSettings.gBattleResults = 0x030042e0
		GameSettings.gTasks = 0x03004b20
		GameSettings.Task_EvolutionScene = 0x0811242d --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8eb7 -- BattleScript_TryLearnMoveLoop
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8f09
		GameSettings.gMoveToLearn = 0x02024e82
		GameSettings.gBattleOutcome = 0x02024d26
		GameSettings.gMoveResultFlags = 0x02024c68
		GameSettings.gBattleWeather = 0x02024db8
		GameSettings.gBattleCommunication = 0x02024d1e
		GameSettings.gBattlersCount = 0x02024a68
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d9540
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d9549
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d957f
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d95a6
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d95af
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d94f0
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d94f3
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d94f5
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d94ff
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d9504
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8dcd
		GameSettings.gCurrentTurnActionNumber = 0x02024a7e
		GameSettings.gActionsByTurnOrder = 0x02024a76
		GameSettings.gHitMarker = 0x02024c6c
		GameSettings.gBattleTextBuff1 = 0x030041c0
		GameSettings.gBattleBuffersTransferData = 0x03004040
		GameSettings.gBattleControllerExecFlags = 0x02024a64

		GameSettings.gMapHeader = 0x0202e828
		GameSettings.gBattleTerrain = 0x0300428c
		GameSettings.gBattleTypeFlags = 0x020239f8
		GameSettings.gSpecialVar_ItemId = 0x0203855e -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x0202e8dc -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x0803f48c + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x02025734
		GameSettings.gameStatsOffset = 0x1540
		GameSettings.gameVarsOffset = 0x1340
		GameSettings.badgeOffset = 0x1220 + 0x100 -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		GameSettings.bagPocket_Items_offset = 0x560
		GameSettings.bagPocket_Berries_offset = 0x740
		GameSettings.bagPocket_Items_Size = 20
		GameSettings.bagPocket_Berries_Size = 46

		GameSettings.ABILITIES = {
			BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
				[0x081d96ac] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d96c7] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d979e] = {[22] = true}, -- BattleScript_1D97F0 + 0x6 Intimidate Fail
				[0x081d9786] = {[22] = true}, -- BattleScript_1D97A1 + 0x3d Intimidate Succeed
				[0x081d96d4] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081d7e1e] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d96ec] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d9703] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d97a6] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d9849] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d98b1] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d979e] = { -- BattleScript_1D97F0 + 0x6 Intimidate Fail
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d97d4] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d9871] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d98cc] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d982d] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d988d] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d983b] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d98e0] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d98f4] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d98bb] = {[60] = true}, -- BattleScript_NoItemSteal + 0x0 Sticky Hold
				[0x081d6ffb] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d97c1] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d97ff] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9815] = { -- BattleScript_MoveHPDrain_FullHP + 0x7 --> Ability nullifies move
					[10] = true, -- Volt Absorb
					[11] = true, -- Water Absorb
				},
				[0x081d9861] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d986d] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d9855] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6f90] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081d87e1] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d96db] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9924] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d7476] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d95ed] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d9636] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9]  = true, -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d9609] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d9618] = { -- BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d97e2] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d98a3] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7b86] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d903d] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	end
end

function GameSettings.setGameAsEmerald()
	-- https://raw.githubusercontent.com/pret/pokeemerald/symbols/pokeemerald.sym
	print("ROM Detected: Pokemon Emerald")

	GameSettings.gBaseStats = 0x083203cc
	GameSettings.gBattleMoves = 0x0831c898
	GameSettings.sMonSummaryScreen = 0x0203cf1c
	GameSettings.sStartMenuWindowId = 0x0203cd8c
	GameSettings.sSpecialFlags = 0x020375fc
	GameSettings.sBattlerAbilities = 0x0203aba4
	GameSettings.sEvoStructPtr = 0x0203ab80
	GameSettings.gBattlerAttacker = 0x0202420B
	GameSettings.gBattlerTarget = 0x0202420c
	GameSettings.gBattlerPartyIndexes = 0x0202406E
	GameSettings.gBattleMons = 0x02024084
	GameSettings.gBattlescriptCurrInstr = 0x02024214
	GameSettings.gTakenDmg = 0x020241f8
	GameSettings.gBattleScriptingBattler = 0x02024474 + 0x17 -- gBattleScripting.battler
	GameSettings.gBattleResults = 0x03005d10
	GameSettings.gTasks = 0x03005e00
	GameSettings.Task_EvolutionScene = 0x0813e571 --Task_EvolutionScene + 0x1
	GameSettings.BattleScript_FocusPunchSetUp = 0x082db1ff + 0x10
	GameSettings.BattleScript_LearnMoveLoop = 0x082dabd9 -- BattleScript_TryLearnMoveLoop
	GameSettings.BattleScript_LearnMoveReturn = 0x082dac2b
	GameSettings.gMoveToLearn = 0x020244e2
	GameSettings.gBattleOutcome = 0x0202433a
	GameSettings.gMoveResultFlags = 0x0202427c
	GameSettings.gBattleWeather = 0x020243cc
	GameSettings.gBattleCommunication = 0x02024332
	GameSettings.gBattlersCount = 0x0202406c
	GameSettings.BattleScript_MoveUsedIsConfused = 0x082db2c0
	GameSettings.BattleScript_MoveUsedIsConfused2 = 0x082db2c9
	GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x082db303
	GameSettings.BattleScript_MoveUsedIsInLove = 0x082db32a
	GameSettings.BattleScript_MoveUsedIsInLove2 = 0x082db333
	GameSettings.BattleScript_MoveUsedIsFrozen = 0x082db26d
	GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x082db270
	GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x082db272
	GameSettings.BattleScript_MoveUsedUnfroze = 0x082db27c
	GameSettings.BattleScript_MoveUsedUnfroze2 = 0x082db281
	GameSettings.BattleScript_RanAwayUsingMonAbility = 0x082daaec
	GameSettings.gCurrentTurnActionNumber = 0x02024082
	GameSettings.gActionsByTurnOrder = 0x0202407a
	GameSettings.gHitMarker = 0x02024280
	GameSettings.gBattleTextBuff1 = 0x02022f58
	GameSettings.sBattleBuffersTransferData = 0x02022d10
	GameSettings.gBattleControllerExecFlags = 0x02024068

	GameSettings.gMapHeader = 0x02037318
	GameSettings.gBattleTerrain = 0x02022ff0
	GameSettings.gBattleTypeFlags = 0x02022fec
	GameSettings.gSpecialVar_ItemId = 0x0203ce7c -- For fishing rod
	GameSettings.gSpecialVar_Result = 0x020375f0 -- For rock smash
	GameSettings.FriendshipRequiredToEvo = 0x0806d098 + 0x13E -- GetEvolutionTargetSpecies

	GameSettings.gSaveBlock1 = 0x02025a00
	GameSettings.gSaveBlock1ptr = 0x03005d8c
	GameSettings.gSaveBlock2ptr = 0x03005d90
	GameSettings.gameStatsOffset = 0x159C
	GameSettings.gameVarsOffset = 0x139C
	GameSettings.EncryptionKeyOffset = 0xAC
	GameSettings.badgeOffset = 0x1270 + 0x10C -- [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
	GameSettings.bagPocket_Items_offset = 0x560
	GameSettings.bagPocket_Berries_offset = 0x790
	GameSettings.bagPocket_Items_Size = 30
	GameSettings.bagPocket_Berries_Size = 46

	GameSettings.ABILITIES = {
		BATTLER = { -- Abiliities where we can use gBattleScripting.battler to determine enemy/player
			[0x082db430] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
			[0x082db44b] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
			[0x082db522] = {[22] = true}, -- BattleScript_IntimidatePrevented + 0x6 Intimidate Fail
			[0x082db50a] = {[22] = true}, -- BattleScript_IntimidateActivatesLoop + 0x3d Intimidate Succeed
			[0x082db458] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
			[0x082d99af] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
			[0x082db470] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
			[0x082db487] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
			[0x082db52a] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
			[0x082db5cd] = { -- BattleScript_AbilityNoStatLoss + 0x6
				[29] = true, -- Clear Body
				[73] = true, -- White Smoke
			},
			[0x082db635] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
				[51] = true, -- Keen Eye
				[52] = true, -- Hyper Cutter
			},
		},
		REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
			[0x082db522] = { -- BattleScript_IntimidatePrevented + 0x6
				[29] = true, -- Clear Body
				[52] = true, -- Hyper Cutter
				[73] = true, -- White Smoke
			},
		},
		ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
			[0x082db558] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
			[0x082db5f5] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
			[0x082db650] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
			[0x082db5b1] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
			[0x082db611] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
			[0x082db5bf] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
			[0x082db664] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
			[0x082db678] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
			[0x082db63f] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
			[0x082d8b42] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
			[0x082db545] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
			[0x082db583] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
				[10] = true, -- Volt Absorb
				[11] = true, -- Water Absorb
			},
			[0x082db599] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
				[10] = true, -- Volt Absorb
				[11] = true, -- Water Absorb
			},
			[0x082db5e5] = { -- BattleScript_PRLZPrevention + 0x8
				[7]  = true, -- Limber
				[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
			},
			[0x082db5f1] = { -- BattleScript_PSNPrevention + 0x8
				[17] = true, -- Immunity
				[28] = true, -- Synchronize (is unable to inflict poison on other mon)
			},
			[0x082db5d9] = { -- BattleScript_BRNPrevention + 0x8
				[28] = true, -- Synchronize (is unable to inflict burn on other mon)
				[41] = true, -- Water Veil
			},
			[0x082d8ad7] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
				[15] = true, -- Insomnia
				[72] = true, -- Vital Spirit
			},
			[0x082da382] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
		},
		REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
			[0x082db45f] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
			[0x082db6cc] = {[54] = true}, -- BattleScript_MoveUsedLoafingAroundMsg + 0x5 Truant
			[0x082d8fce] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
				[15] = true, -- Insomnia
				[72] = true, -- Vital Spirit
			},
		},
		STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
			[0x082db371] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
			[0x082db3ba] = { -- BattleScript_MoveEffectParalysis + 0x7
				[9]  = true, -- Static
				[27] = true, -- Effect Spore
				[28] = true, -- Synchronize
			},
			[0x082db38d] = { -- BattleScript_MoveEffectPoison + 0x7
				[27] = true, -- Effect Spore
				[28] = true, -- Synchronize
				[38] = true, -- Poison Point
			},
			[0x082db39c] = { -- BattleScript_MoveEffectBurn + 0x7
				[28] = true, -- Synchronize
				[49] = true, -- Flame Body
			},
		},
		BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
			[0x082db566] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
				[6] = true, -- Damp
				scope = "both",
			},
			[0x082db627] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
				[43] = true, -- Soundproof
				scope = "self",
			},
			[0x082d96ea] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
				[43] = true, -- Soundproof
				scope = "self",
			},
			[0x082dad5f] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
				[64] = true, -- Liquid Ooze
				scope = "other",
			},
		},
	}
end

function GameSettings.setGameAsFireRed(gameversion)
	if gameversion == 0x01670000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		print("ROM Detected: Pokemon Fire Red v1.1")

		GameSettings.gBaseStats = 0x082547f4
		GameSettings.gBattleMoves = 0x08250c74
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.gTasks = 0x03005090
		GameSettings.Task_EvolutionScene = 0x080ce8f1 --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9085 + 0x10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a81
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8ad3
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d9146
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d914f
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d9189
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081D91B0
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081D91B9
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081D90F3
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081D90F6
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081D90F8
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081D9102
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081D9107
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8982 -- BattleScript_RanAwayUsingMonAbility + 0x3
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042ED8 + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
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
				[0x081D78FF] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
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
				[0x081d9537] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d94fe] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6aaf] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9404] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
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
				[0x81D82C5] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
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
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d94e6] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d763a] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d8c07] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	elseif gameversion == 0x00680000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered.sym
		print("ROM Detected: Pokemon Fire Red v1.0")

		GameSettings.gBaseStats = 0x08254784
		GameSettings.gBattleMoves = 0x08250c04
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.gTasks = 0x03005090
		GameSettings.Task_EvolutionScene = 0x080ce8dd --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9015 + 0x10
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a11
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a63
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d90d6
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d90df
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d9119
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d9140
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d9149
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d9083
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d9086
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d9088
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d9092
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d9097
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d8912
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042ec4 + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
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
				[0x081d788f] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
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
				[0x081d94c7] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d948e] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6a3f] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9394] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
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
				[0x081d8255] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
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
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d9476] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d75ca] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d8b97] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	end
end

function GameSettings.setGameAsFireRedItaly(gameversion)
	if gameversion == 0x00640000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		print("ROM Detected: Pokemon - Rosso Fuoco")

		GameSettings.gBaseStats = 0x0824d864
		GameSettings.gBattleMoves = 0x08249ce4 -- needs to be tested
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004EE0
		GameSettings.gTasks = 0x03004FE0
		GameSettings.Task_EvolutionScene = 0x080CEA5D --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d647f + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d5e7B --those values were tricky to find
		GameSettings.BattleScript_LearnMoveReturn = 0x081D5ECD -- expect them to not always be right
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081D6540
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081D6549
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081D6583
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081D65AA
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081D65B3
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081D64ED
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081D64F0
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081D64F2
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081D64FC
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081D6501
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081D5D7C -- BattleScript_RanAwayUsingMonAbility + 0x3
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042db0 + 0x13E -- GetEvolutionTargetSpecies (untested)

		--the only diffrance looks like in here gSaveBlock1ptr and gSaveBlock2ptr
		GameSettings.gSaveBlock1ptr = 0x03004F58
		GameSettings.gSaveBlock2ptr = 0x03004F5C
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310 --tested for bag items didnt check for berries should be same though
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- Ability script addresses = FR 1.1 address - 0x2c06
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		GameSettings.ABILITIES = {
			BATTLER = { -- Abilities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d66e9] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d6704] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d67db] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d67c3] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d6711] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081D4CF9] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d6729] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d6740] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d67e3] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d6886] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d68ee] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d67db] = { -- BattleScript_IntimidateAbilityFail + 0x6 (Intimidate blocked)
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d6811] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d68ae] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d6909] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d686a] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d68ca] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d6878] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d691d] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d6931] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d68f8] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d3ea9] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081D67FE] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d683c] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d6852] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d689e] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d68aa] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d6892] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d3e3e] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081D56BF] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d6718] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d6961] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d4324] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d662a] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d6673] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9] = true,  -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d6646] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d6655] = { --BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d681f] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d68e0] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d4a34] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d6001] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}

		dofile(Main.DataFolder .. "/Languages/ItalyData.lua")
		ItalyData.updateToItalyData()
	end
end

function GameSettings.setGameAsFireRedSpanish(gameversion)
	if gameversion == 0x005A0000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		print("ROM Detected: Pokemon Rojo Fuego")

		GameSettings.gBaseStats = 0x0824ff4c
		GameSettings.gBattleMoves = 0x0824c3cc -- needs to be tested
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004EE0
		GameSettings.gTasks = 0x03004FE0
		GameSettings.Task_EvolutionScene = 0x080CEB45 --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d8b47 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081D8543
		GameSettings.BattleScript_LearnMoveReturn = 0x081D8595
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081D8C08
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081D8C11
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081D8C4B
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081D8C72
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081D8C7B
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081D8BB5
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081D8BB8
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081D8BBA
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081D8BC4
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081D8BC9
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081D8444 -- BattleScript_RanAwayUsingMonAbility + 0x3
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042db0 + 0x13E -- GetEvolutionTargetSpecies (untested)

		--the only diffrance looks like in here gSaveBlock1ptr and gSaveBlock2ptr
		GameSettings.gSaveBlock1ptr = 0x03004F58
		GameSettings.gSaveBlock2ptr = 0x03004F5C
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310 --tested for bag items didnt check for berries should be same though
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- Ability script addresses = FR 1.1 address - 0x53e
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		GameSettings.ABILITIES = {
			BATTLER = { -- Abilities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d8db1] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d8dcc] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d8ea3] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d8e8b] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d8dd9] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081D7E3D] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d8df1] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d8e08] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d8eab] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d8f4e] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d8fb6] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d8ea3] = { -- BattleScript_IntimidateAbilityFail + 0x6 (Intimidate blocked)
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d8ed9] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d8f76] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d8fd1] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d8f32] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d8f92] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d8f40] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d8fe5] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d8ff9] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d8fc0] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6571] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081D8EC6] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d8f04] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d8f1a] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d8f66] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d8f72] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d8f5a] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d6506] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081D7D87] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d8de0] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d9029] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d69ec] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d8cf2] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d8d3b] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9] = true,  -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d8d0e] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d8d1d] = { --BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d8ee7] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d8fa8] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d70fc] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d86c9] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}

		dofile(Main.DataFolder .. "/Languages/SpainData.lua")
		SpainData.updateToSpainData()
	end
end

function GameSettings.setGameAsFireRedFrench(gameversion)
	if gameversion == 0x00670000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		print("ROM Detected: Pokemon Rouge Feu")

		GameSettings.gBaseStats = 0x0824ebd4
		GameSettings.gBattleMoves = 0x0824b054 -- needs to be tested
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004EE0
		GameSettings.gTasks = 0x03004FE0
		GameSettings.Task_EvolutionScene = 0x080CEB3D --Task_EvolutionScene + 0x1 (FR1.1 + 24C)
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d77e7 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x0081D71E3
		GameSettings.BattleScript_LearnMoveReturn = 0x081D7235
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081D78A8
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081D78B1
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081D78EB
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081D7912
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081D791B
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081D7855
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081D7858
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081D785A
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081D7864
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081D7869
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081D70E4 -- BattleScript_RanAwayUsingMonAbility + 0x3
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042d9c + 0x13E -- GetEvolutionTargetSpecies (untested)

		--the only diffrance looks like in here gSaveBlock1ptr and gSaveBlock2ptr
		GameSettings.gSaveBlock1ptr = 0x03004F58
		GameSettings.gSaveBlock2ptr = 0x03004F5C
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310 --tested for bag items didnt check for berries should be same though
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- Ability script addresses = FR 1.1 address - 0x189e
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		GameSettings.ABILITIES = {
			BATTLER = { -- Abilities where we can use gBattleScripting.battler to determine enemy/player
				[0x081d7a51] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081d7a6c] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081d7b43] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081d7b2b] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081d7a79] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081D6061] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081d7a91] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081d7aa8] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081d7b4b] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081d7bee] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081d7c56] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081d7b43] = { -- BattleScript_IntimidateAbilityFail + 0x6 (Intimidate blocked)
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081d7b79] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081d7c16] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081d7c71] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081d7bd2] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081d7c32] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081d7be0] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081d7c85] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081d7c99] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d7c60] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d5211] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081D7B66] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081d7ba4] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d7bba] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081d7c06] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081d7c12] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081d7bfa] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081d51a6] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081D6A27] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081d7a80] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081d7cc9] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081d568c] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081d7992] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081d79db] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9] = true,  -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081d79ae] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081d79bd] = { --BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081d7b87] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d7c48] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d5d9c] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7369] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}

		dofile(Main.DataFolder .. "/Languages/FranceData.lua")
		FranceData.updateToFranceData()
	end
end


function GameSettings.setGameAsFireRedGermany(gameversion)
	if gameversion == 0x00690000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		print("ROM Detected: Pokemon Feuerrote")

		GameSettings.gBaseStats = 0x082546a8
		GameSettings.gBattleMoves = 0x08250b28 -- needs to be tested
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004EE0
		GameSettings.gTasks = 0x03004FE0
		GameSettings.Task_EvolutionScene = 0x080CEA7D --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081DD2AB + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081DCCA7 --those values were tricky to find
		GameSettings.BattleScript_LearnMoveReturn = 0x081DCC55 -- expect them to not always be right
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081DD36C
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081DD375
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081DD3AF
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081DD3D6
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081DD3DF
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081D4ECD
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081D4ED0
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081D4ED2
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081D4EDC
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081D4EE1
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081DCBA8 -- BattleScript_RanAwayUsingMonAbility + 0x3
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042DC4 + 0x13E -- GetEvolutionTargetSpecies (untested)

		--the only diffrance looks like in here gSaveBlock1ptr and gSaveBlock2ptr
		GameSettings.gSaveBlock1ptr = 0x03004F58
		GameSettings.gSaveBlock2ptr = 0x03004F5C
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
		GameSettings.EncryptionKeyOffset = 0xF20
		GameSettings.badgeOffset = 0xEE0 + 0x104 -- [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		GameSettings.bagPocket_Items_offset = 0x310 --tested for bag items didnt check for berries should be same though
		GameSettings.bagPocket_Berries_offset = 0x54c
		GameSettings.bagPocket_Items_Size = 42
		GameSettings.bagPocket_Berries_Size = 43

		-- Ability script addresses = FR 1.1 address + 0x4226
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
		GameSettings.ABILITIES = {
			BATTLER = { -- Abilities where we can use gBattleScripting.battler to determine enemy/player
				[0x081DD515] = {[2]  = true}, -- BattleScript_DrizzleActivates + 0x0 Drizzle
				[0x081DD530] = {[3]  = true}, -- BattleScript_SpeedBoostActivates + 0x7 Speed Boost
				[0x081DD607] = {[22] = true}, -- BattleScript_IntimidateAbilityFail + 0x6 Intimidate Fail
				[0x081DD5EF] = {[22] = true}, -- BattleScript_IntimidateActivationAnimLoop + 0x3d Intimidate Succeed
				[0x081DD53D] = {[36] = true}, -- BattleScript_TraceActivates + 0x6 Trace
				[0x081DBB25] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)
				[0x081DD555] = {[45] = true}, -- BattleScript_SandstreamActivates + 0x0 Sand Stream
				[0x081DD56C] = {[61] = true}, -- BattleScript_ShedSkinActivates + 0x3 Shed Skin
				[0x081DD60F] = {[70] = true}, -- BattleScript_DroughtActivates + 0x0 Drought
				[0x081DD6B2] = { -- BattleScript_AbilityNoStatLoss + 0x6
					[29] = true, -- Clear Body
					[73] = true, -- White Smoke
				},
				[0x081DD71A] = { -- BattleScript_AbilityNoSpecificStatLoss + 0x6
					[51] = true, -- Keen Eye
					[52] = true, -- Hyper Cutter
				},
			},
			REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
				[0x081DD607] = { -- BattleScript_IntimidateAbilityFail + 0x6 (Intimidate blocked)
					[29] = true, -- Clear Body
					[52] = true, -- Hyper Cutter
					[73] = true, -- White Smoke
				},
			},
			ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
				[0x081DD63D] = {[5]  = true}, -- BattleScript_SturdyPreventsOHKO + 0x6 Sturdy
				[0x081DD6DA] = {[12] = true}, -- BattleScript_ObliviousPreventsAttraction + 0x0 Oblivious
				[0x081DD735] = {[16] = true}, -- BattleScript_ColorChangeActivates + 0x3 Color Change
				[0x081DD696] = {[18] = true}, -- BattleScript_FlashFireBoost + 0x9 Flash Fire
				[0x081DD6F6] = {[20] = true}, -- BattleScript_OwnTempoPrevents + 0x0 Own Tempo
				[0x081DD6A4] = {[21] = true}, -- BattleScript_AbilityPreventsPhasingOut + 0x6 Suction Cups
				[0x081DD749] = {[24] = true}, -- BattleScript_RoughSkinActivates + 0x10 Rough Skin
				[0x081DD75D] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081DD724] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081DACD5] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081DD62A] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
				[0x081DD668] = { -- BattleScript_MoveHPDrain + 0x14 --> Ability heals HP
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081DD67E] = { -- BattleScript_MonMadeMoveUseless + 0x7 --> Ability nullifies move
					[10] = true, -- Water Absorb
					[11] = true, -- Volt Absorb
				},
				[0x081DD6CA] = { -- BattleScript_PRLZPrevention + 0x8
					[7]  = true, -- Limber
					[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
				},
				[0x081DD6D6] = { -- BattleScript_PSNPrevention + 0x8
					[17] = true, -- Immunity
					[28] = true, -- Synchronize (is unable to inflict poison on other mon)
				},
				[0x081DD6BE] = { -- BattleScript_BRNPrevention + 0x8
					[28] = true, -- Synchronize (is unable to inflict burn on other mon)
					[41] = true, -- Water Veil
				},
				[0x081DAC6A] = { -- BattleScript_CantMakeAsleep + 0x8 --> Ability blocks attacker from inflicting sleep
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
				[0x081DC4EB] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
			},
			REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
				[0x081DD544] = {[44] = true}, -- BattleScript_RainDishActivates + 0x3 Rain Dish
				[0x081DD78D] = {[54] = true}, -- BattleScript_MoveUsedLoafingAround + 0x5 Truant
				[0x081DB150] = { -- BattleScript_RestCantSleep + 0x8 --> Ability blocks mon's own rest attempt
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				},
			},
			STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
				[0x081DD456] = {[27] = true}, -- BattleScript_MoveEffectSleep + 0x7 Effect Spore (Sleep)
				[0x081DD49F] = { -- BattleScript_MoveEffectParalysis + 0x7
					[9] = true,  -- Static
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
				},
				[0x081DD472] = { -- BattleScript_MoveEffectPoison + 0x7
					[27] = true, -- Effect Spore
					[28] = true, -- Synchronize
					[38] = true, -- Poison Point
				},
				[0x081DD481] = { --BattleScript_MoveEffectBurn + 0x7
					[28] = true, -- Synchronize
					[49] = true, -- Flame Body
				},
			},
			BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
				[0x081DD64B] = { -- BattleScript_DampStopsExplosion + 0x6 Damp
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081DD70C] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081DB860] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081DCE2D] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}

		dofile(Main.DataFolder .. "/Languages/GermanyData.lua")
		GermanyData.updateToGermanyData()
	end
end

function GameSettings.setGameAsLeafGreen(gameversion)
	if gameversion == 0x01800000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen_rev1.sym
		print("ROM Detected: Pokemon Leaf Green v1.1")

		GameSettings.gBaseStats = 0x082547d0
		GameSettings.gBattleMoves = 0x08250c50
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.gTasks = 0x03005090
		GameSettings.Task_EvolutionScene = 0x080ce8c5 --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d9061 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d8a5d
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8aaf
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d9122
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d912b
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d9165
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d918c
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d9195
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d90cf
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d90d2
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d90d4
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d90de
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d90e3
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d895e
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042ed8 + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
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
				[0x081d78eb] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)

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
				[0x081d9513] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d94da] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6a8b] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d93e0] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
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
				[0x081d82a1] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
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
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d94c2] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d7616] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d8be3] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	elseif gameversion == 0x00810000 then
		-- https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen.sym
		print("ROM Detected: Pokemon Leaf Green v1.0")

		GameSettings.gBaseStats = 0x08254760
		GameSettings.gBattleMoves = 0x08250be0
		GameSettings.sMonSummaryScreen = 0x0203b140
		GameSettings.sStartMenuWindowId = 0x0203abe0
		GameSettings.sSpecialFlags = 0x020370e0
		GameSettings.sBattlerAbilities = 0x02039a30
		GameSettings.sEvoStructPtr = 0x02039a20
		GameSettings.gBattlerAttacker = 0x02023d6b
		GameSettings.gBattlerTarget = 0x02023d6c
		GameSettings.gBattlerPartyIndexes = 0x02023bce
		GameSettings.gBattleMons = 0x02023be4
		GameSettings.gBattlescriptCurrInstr = 0x02023d74
		GameSettings.gTakenDmg = 0x02023d58
		GameSettings.gBattleScriptingBattler = 0x02023fc4 + 0x17 -- gBattleScripting.battler
		GameSettings.gBattleResults = 0x03004f90
		GameSettings.gTasks = 0x03005090
		GameSettings.Task_EvolutionScene = 0x080ce8b1 --Task_EvolutionScene + 0x1
		GameSettings.BattleScript_FocusPunchSetUp = 0x081d8ff1 + 0x10 -- TODO: offset for this game is untested
		GameSettings.BattleScript_LearnMoveLoop = 0x081d89ed
		GameSettings.BattleScript_LearnMoveReturn = 0x081d8a3f
		GameSettings.gMoveToLearn = 0x02024022
		GameSettings.gBattleOutcome = 0x02023e8a
		GameSettings.gMoveResultFlags = 0x02023dcc
		GameSettings.gBattleWeather = 0x02023f1c
		GameSettings.gBattleCommunication = 0x02023e82
		GameSettings.gBattlersCount = 0x02023bcc
		GameSettings.BattleScript_MoveUsedIsConfused = 0x081d90b2
		GameSettings.BattleScript_MoveUsedIsConfused2 = 0x081d90bb
		GameSettings.BattleScript_MoveUsedIsConfusedNoMore = 0x081d90f5
		GameSettings.BattleScript_MoveUsedIsInLove = 0x081d911c
		GameSettings.BattleScript_MoveUsedIsInLove2 = 0x081d9125
		GameSettings.BattleScript_MoveUsedIsFrozen = 0x081d905f
		GameSettings.BattleScript_MoveUsedIsFrozen2 = 0x081d9062
		GameSettings.BattleScript_MoveUsedIsFrozen3 = 0x081d9064
		GameSettings.BattleScript_MoveUsedUnfroze = 0x081d906e
		GameSettings.BattleScript_MoveUsedUnfroze2 = 0x081d9073
		GameSettings.BattleScript_RanAwayUsingMonAbility = 0x081d88ee
		GameSettings.gCurrentTurnActionNumber = 0x02023be2
		GameSettings.gActionsByTurnOrder = 0x02023bda
		GameSettings.gHitMarker = 0x02023dd0
		GameSettings.gBattleTextBuff1 = 0x02022ab8
		GameSettings.sBattleBuffersTransferData = 0x02022874
		GameSettings.gBattleControllerExecFlags = 0x02023bc8

		GameSettings.gMapHeader = 0x02036dfc
		GameSettings.gBattleTerrain = 0x02022b50
		GameSettings.gBattleTypeFlags = 0x02022b4c
		GameSettings.gSpecialVar_ItemId = 0x0203ad30 -- For fishing rod
		GameSettings.gSpecialVar_Result = 0x020370d0 -- For rock smash
		GameSettings.FriendshipRequiredToEvo = 0x08042ec4 + 0x13E -- GetEvolutionTargetSpecies

		GameSettings.gSaveBlock1 = 0x0202552c
		GameSettings.gSaveBlock1ptr = 0x03005008
		GameSettings.gSaveBlock2ptr = 0x0300500c
		GameSettings.gameStatsOffset = 0x1200
		GameSettings.gameVarsOffset = 0x1000
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
				[0x081d787b] = {[43] = true}, -- BattleScript_PerishSongNotAffected + 0x3 Soundproof 3 (Perish Song)

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
				[0x081d94a3] = {[56] = true}, -- BattleScript_CuteCharmActivates + 0x9 Cute Charm
				[0x081d946a] = {[60] = true}, -- BattleScript_StickyHoldActivates + 0x0 Sticky Hold
				[0x081d6a1b] = {[64] = true}, -- BattleScript_AbsorbUpdateHp + 0x14 Liquid Ooze (Drain Moves)
				[0x081d9370] = {[31] = true}, -- BattleScript_TookAttack + 0x7 LightningRod
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
				[0x081d8231] = { -- BattleScript_PrintAbilityMadeIneffective (Yawn)
					[15] = true, -- Insomnia
					[72] = true, -- Vital Spirit
				}
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
					[6] = true, -- Damp
					scope = "both",
				},
				[0x081d9452] = { -- BattleScript_SoundproofProtected + 0x8 Soundproof 1
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d75a6] = { -- BattleScript_EffectHealBell + 0x29 Soundproof 2 (Enemy uses Heal Bell)
					[43] = true, -- Soundproof
					scope = "self",
				},
				[0x081d8b73] = { -- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12 Liquid Ooze (Leech Seed)
					[64] = true, -- Liquid Ooze
					scope = "other",
				},
			},
		}
	end
end

function GameSettings.getTrackerAutoSaveName()
	local filenameEnding = Constants.Files.PostFixes.AUTOSAVE .. Constants.Files.Extensions.TRACKED_DATA

	-- Remove trailing " (___)" from game name
	return GameSettings.gamename:gsub("%s%(.*%)", " ") .. filenameEnding
end
GameSettings = {}
GameSettings.ABILITIES = {}

-- Moved the 1st/2nd/3rd values to be set alongside other EWRAM/IWRAM addresses. 4th/5th/6th values are supposedly the Japanese addresses (not used right now)
-- local pstats = { 0x3004360, 0x20244EC, 0x2024284, 0x3004290, 0x2024190, 0x20241E4 } -- Player stats
-- local estats = { 0x30045C0, 0x2024744, 0x202402C, 0x30044F0, 0x20243E8, 0x2023F8C } -- Enemy stats

-- Symbols tables references (from the pret decomp work):
-- 	Ruby:
-- 		- 1.0: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby.sym
-- 		- 1.1: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev1.sym
-- 		- 1.2: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev2.sym
-- 	Sapphire:
-- 		- 1.0: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire.sym
-- 		- 1.1: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev1.sym
-- 		- 1.2: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev2.sym
-- 	Emerald:
-- 		- 1.0: https://raw.githubusercontent.com/pret/pokeemerald/symbols/pokeemerald.sym
-- 	FireRed:
-- 		- 1.0: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered.sym
-- 		- 1.1: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
-- 		- Non-English versions are based on 1.1
-- 			- Ability script offsets:
-- 				- Spanish script addresses = English 1.1 address - 0x53e
-- 				- Italian script addresses = English 1.1 address - 0x2c06
-- 				- French script addresses = English 1.1 address - 0x189e
-- 				- German script addresses = English 1.1 address + 0x4226
-- 	LeafGreen:
-- 		- 1.0: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen.sym
-- 		- 1.1: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen_rev1.sym


-- https://github.com/pret/pokefirered/blob/9aaabcc30da51bea0c47d6e5df1dc6f8f534991c/charmap.txt
-- Likely need a second set for Japanese Hiragana, Katakana, and punctuation
GameSettings.GameCharMap = {
	[0x00] = ' ',
	[0x01] = 'À',
	[0x02] = 'Á',
	[0x03] = 'Â',
	[0x04] = 'Ç',
	[0x05] = 'È',
	[0x06] = 'É',
	[0x07] = 'Ê',
	[0x08] = 'Ë',
	[0x09] = 'Ì',
	[0x0B] = 'Î',
	[0x0C] = 'Ï',
	[0x0D] = 'Ò',
	[0x0E] = 'Ó',
	[0x0F] = 'Ô',
	[0x10] = 'Œ',
	[0x11] = 'Ù',
	[0x12] = 'Ú',
	[0x13] = 'Û',
	[0x14] = 'Ñ',
	[0x15] = 'ß',
	[0x16] = 'à',
	[0x17] = 'á',
	[0x19] = 'ç',
	[0x1A] = 'è',
	[0x1B] = 'é',
	[0x1C] = 'ê',
	[0x1D] = 'ë',
	[0x1E] = 'ì',
	[0x20] = 'î',
	[0x21] = 'ï',
	[0x22] = 'ò',
	[0x23] = 'ó',
	[0x24] = 'ô',
	[0x25] = 'œ',
	[0x26] = 'ù',
	[0x27] = 'ú',
	[0x28] = 'û',
	[0x29] = 'ñ',
	[0x2A] = 'º',
	[0x2B] = 'ª',
	[0x2C] = Constants.HIDDEN_INFO or 'SUPER_ER',
	[0x2D] = '&',
	[0x2E] = '+',
	[0x34] = 'LV',
	[0x35] = '=',
	[0x36] = ';',
	[0x51] = '¿',
	[0x52] = '¡',
	[0x53] = 'PK',
	[0x54] = 'MN',
	[0x55] = 'PO',
	[0x56] = 'KE',
	[0x57] = 'BL',
	[0x58] = 'OC',
	[0x59] = 'K',
	[0x5A] = 'Í',
	[0x5B] = '%',
	[0x5C] = '(',
	[0x5D] = ')',
	[0x68] = 'â',
	[0x6F] = 'í',
	[0x79] = Constants.HIDDEN_INFO or 'UP_ARROW',
	[0x7A] = Constants.HIDDEN_INFO or 'DOWN_ARROW',
	[0x7B] = Constants.HIDDEN_INFO or 'LEFT_ARROW',
	[0x7C] = Constants.HIDDEN_INFO or 'RIGHT_ARROW',
	[0x84] = Constants.HIDDEN_INFO or 'SUPER_E',
	[0x85] = '<',
	[0x86] = '>',
	[0xA0] = Constants.HIDDEN_INFO or 'SUPER_RE',
	[0xA1] = '0',
	[0xA2] = '1',
	[0xA3] = '2',
	[0xA4] = '3',
	[0xA5] = '4',
	[0xA6] = '5',
	[0xA7] = '6',
	[0xA8] = '7',
	[0xA9] = '8',
	[0xAA] = '9',
	[0xAB] = '!',
	[0xAC] = '?',
	[0xAD] = '.',
	[0xAE] = '-',
	[0xB0] = '…',
	[0xB1] = '“',
	[0xB2] = '”',
	[0xB3] = '‘',
	[0xB4] = "'",
	[0xB5] = '♂',
	[0xB6] = '♀',
	[0xB7] = '¥',
	[0xB8] = ',',
	[0xB9] = '×',
	[0xBA] = '/',
	[0xBB] = 'A',
	[0xBC] = 'B',
	[0xBD] = 'C',
	[0xBE] = 'D',
	[0xBF] = 'E',
	[0xC0] = 'F',
	[0xC1] = 'G',
	[0xC2] = 'H',
	[0xC3] = 'I',
	[0xC4] = 'J',
	[0xC5] = 'K',
	[0xC6] = 'L',
	[0xC7] = 'M',
	[0xC8] = 'N',
	[0xC9] = 'O',
	[0xCA] = 'P',
	[0xCB] = 'Q',
	[0xCC] = 'R',
	[0xCD] = 'S',
	[0xCE] = 'T',
	[0xCF] = 'U',
	[0xD0] = 'V',
	[0xD1] = 'W',
	[0xD2] = 'X',
	[0xD3] = 'Y',
	[0xD4] = 'Z',
	[0xD5] = 'a',
	[0xD6] = 'b',
	[0xD7] = 'c',
	[0xD8] = 'd',
	[0xD9] = 'e',
	[0xDA] = 'f',
	[0xDB] = 'g',
	[0xDC] = 'h',
	[0xDD] = 'i',
	[0xDE] = 'j',
	[0xDF] = 'k',
	[0xE0] = 'l',
	[0xE1] = 'm',
	[0xE2] = 'n',
	[0xE3] = 'o',
	[0xE4] = 'p',
	[0xE5] = 'q',
	[0xE6] = 'r',
	[0xE7] = 's',
	[0xE8] = 't',
	[0xE9] = 'u',
	[0xEA] = 'v',
	[0xEB] = 'w',
	[0xEC] = 'x',
	[0xED] = 'y',
	[0xEE] = 'z',
	[0xEF] = '?',
	[0xF0] = ':',
	[0xF1] = 'Ä',
	[0xF2] = 'Ö',
	[0xF3] = 'Ü',
	[0xF4] = 'ä',
	[0xF5] = 'ö',
	[0xF6] = 'ü',
	[0xFF] = '$',
}

function GameSettings.initialize()
	local gamecode = Utils.reverseEndian32(Memory.read32(0x080000AC))
	GameSettings.setGameInfo(gamecode)

	-- Skip rest of setup if game not supported
	if GameSettings.gamename == "Unsupported Game" then
		return
	end

	local gameversion = Utils.reverseEndian32(Memory.read32(0x080000BC))
	local gameIndex, versionIndex = GameSettings.setGameVersion(gameversion)

	-- 0x02...
	GameSettings.setEwramAddresses()
	-- 0x03...
	GameSettings.setIwramAddresses()
	-- 0x08...
	GameSettings.setRomAddresses(gameIndex, versionIndex)
	-- Ability auto-tracking scripts
	GameSettings.setAbilityTrackingAddresses(gameIndex, versionIndex)
end

function GameSettings.getRomName()
	if Main.IsOnBizhawk() then
		return gameinfo.getromname() or ""
	else
		if emu == nil then return nil end -- I don't think this is needed anymore, but leaving it in for safety
		return emu:getGameTitle() or ""
	end
end

function GameSettings.getRomHash()
	if Main.IsOnBizhawk() then
		return gameinfo.getromhash() or ""
	else
		---@diagnostic disable-next-line: undefined-global
		return emu:checksum(C.CHECKSUM.CRC32) or ""
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
			LANGUAGE = "English",
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x41585045] = {
			GAME_NUMBER = 1,
			GAME_NAME = "Pokemon Sapphire (U)",
			VERSION_GROUP = 1,
			VERSION_COLOR = "Sapphire",
			LANGUAGE = "English",
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x42504545] = {
			GAME_NUMBER = 2,
			GAME_NAME = "Pokemon Emerald (U)",
			VERSION_GROUP = 1,
			VERSION_COLOR = "Emerald",
			LANGUAGE = "English",
			BADGE_PREFIX = "RSE",
			BADGE_XOFFSETS = { 1, 1, 0, 0, 1, 1, 1, 1 },
		},
		[0x42505245] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon FireRed (U)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			LANGUAGE = "English",
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505253] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rojo Fuego (Spain)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			LANGUAGE = "Spanish",
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505249] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rosso Fuoco (Italy)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			LANGUAGE = "Italian",
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505246] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Rouge Feu (France)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			LANGUAGE = "French",
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42505244] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon Feuerrote (Germany)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "FireRed",
			LANGUAGE = "German",
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
		[0x42504745] = {
			GAME_NUMBER = 3,
			GAME_NAME = "Pokemon LeafGreen (U)",
			VERSION_GROUP = 2,
			VERSION_COLOR = "LeafGreen",
			LANGUAGE = "English",
			BADGE_PREFIX = "FRLG",
			BADGE_XOFFSETS = { 0, -2, -2, 0, 1, 1, 0, 1 },
		},
	}

	local game = games[gamecode]
	if game ~= nil then
		GameSettings.game = game.GAME_NUMBER
		GameSettings.gamename = game.GAME_NAME
		GameSettings.versiongroup = game.VERSION_GROUP
		GameSettings.versioncolor = game.VERSION_COLOR
		GameSettings.language = game.LANGUAGE
		GameSettings.badgePrefix = game.BADGE_PREFIX
		GameSettings.badgeXOffsets = game.BADGE_XOFFSETS
	else
		GameSettings.gamename = "Unsupported Game"
		Main.DisplayError("This game is unsupported by the Ironmon Tracker.\n\nCheck the tracker's README.txt file for currently supported games.")
	end
end

-- Detects which version of each game is present, returns a gameIndex and versionIndex for use later when setting ROM addresses
-- Also loads and sets non-English localisations
function GameSettings.setGameVersion(gameversion)
	-- Mapped by versioncolor, then by gameversion
	local games = {
		["Ruby"] = {
			gameIndex = 1,
			[0x00410000] = { -- English 1.0
				versionName = "Pokemon Ruby v1.0",
				versionIndex = 1,
			},
			[0x01400000] = { -- English 1.1
				versionName = "Pokemon Ruby v1.1",
				versionIndex = 2
			},
			[0x023F0000] = { -- English 1.2
				versionName = "Pokemon Ruby v1.2",
				versionIndex = 3
			},
		},
		["Sapphire"] = {
			gameIndex = 2,
			[0x00550000] = { -- English 1.0
				versionName = "Pokemon Sapphire v1.0",
				versionIndex = 1,
			},
			[0x01540000] = { -- English 1.1
				versionName = "Pokemon Sapphire v1.1",
				versionIndex = 2
			},
			[0x02530000] = { -- English 1.2
				versionName = "Pokemon Sapphire v1.2",
				versionIndex = 3
			},
		},
		["Emerald"] = {
			gameIndex = 3,
			[0x00720000] = { -- English
				versionName = "Pokemon Emerald",
				versionIndex = 1,
			},
		},
		["FireRed"] = {
			gameIndex = 4,
			[0x00680000] = { -- English 1.0
				versionName = "Pokemon FireRed v1.0",
				versionIndex = 1,
			},
			[0x01670000] = { -- English 1.1
				versionName = "Pokemon FireRed v1.1",
				versionIndex = 2
			},
			[0x005A0000] = { -- Spanish
				versionName = "Pokemon Rojo Fuego",
				versionIndex = 3,
			},
			[0x00640000] = { -- Italian
				versionName = "Pokemon Rosso Fuoco",
				versionIndex = 4,
			},
			[0x00670000] = { -- French
				versionName = "Pokemon Rouge Feu",
				versionIndex = 5,
			},
			[0x00690000] = { -- German
				versionName = "Pokemon Feuerrote",
				versionIndex = 6,
			},
		},
		["LeafGreen"] = {
			gameIndex = 5,
			[0x00810000] = { -- English 1.0
				versionName = "Pokemon LeafGreen v1.0",
				versionIndex = 1,
			},
			[0x01800000] = { -- English 1.1
				versionName = "Pokemon LeafGreen v1.1",
				versionIndex = 2
			},
		},
	}

	-- print(string.format("%s %s", "ROM Detected:", games[GameSettings.versioncolor][gameversion].versionName))

	-- Load non-English language data
	local gameLanguage = GameSettings.language
	local langFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
	if gameLanguage == "Spanish" then
		dofile(langFolder .. FileManager.Files.LanguageCode.SpainData)
		SpainData.updateToSpainData()
	elseif gameLanguage == "Italian" then
		dofile(langFolder .. FileManager.Files.LanguageCode.ItalyData)
		ItalyData.updateToItalyData()
	elseif gameLanguage == "French" then
		dofile(langFolder .. FileManager.Files.LanguageCode.FranceData)
		FranceData.updateToFranceData()
	elseif gameLanguage == "German" then
		dofile(langFolder .. FileManager.Files.LanguageCode.GermanyData)
		GermanyData.updateToGermanyData()
	end

	return games[GameSettings.versioncolor].gameIndex, games[GameSettings.versioncolor][gameversion].versionIndex
end

-- EWRAM (02xxxxxx) addresses are the same between all versions of a game
function GameSettings.setEwramAddresses()
	-- Use nil values for non-existant / deliberately omitted addresses, and 0x00000000 for placeholder unknowns
	-- Format: Address = { RS, Emerald, FRLG }
	local addresses = {
		-- Player Stats, exists in IWRAM instead in RS
		pstats = { nil, 0x020244EC, 0x02024284 },
		-- Enemy Stats, exists in IWRAM instead in RS
		estats = { nil, 0x02024744, 0x0202402C },
		-- Player Party Size, exists in IWRAM instead in RS
		gPlayerPartyCount = { nil, 0x020244e9, 0x02024029 },

		-- RS uses this directly (gSharedMem + 0x14800)
		sEvoInfo = { 0x02014800, nil, nil },
		-- Em/FRLG uses this pointer instead
		sEvoStructPtr = { nil, 0x0203ab80, 0x02039a20 },

		-- RS: gBattleStruct (gSharedMem + 0x0) -> scriptingActive, Em/FRLG: gBattleScripting.battler
		gBattleScriptingBattler = { 0x02016003, 0x02024474 + 0x17, 0x02023fc4 + 0x17 },
		-- RS: pssData (gSharedMem + 0x18000) + lastpage offset
		gTrainerBattleOpponent_A = { 0x0202ff5e, 0x02038bca, 0x020386ae },
		gTrainerBattleOpponent_B = { nil, 0x02038bcc, nil }, -- Emerald Only
		sMonSummaryScreen = { 0x02018000 + 0x76, 0x0203cf1c, 0x0203b140 },
		gBattleTypeFlags = { 0x020239f8, 0x02022fec, 0x02022b4c },
		gBattleControllerExecFlags = { 0x02024a64, 0x02024068, 0x02023bc8 },
		gBattlersCount = { 0x02024a68, 0x0202406c, 0x02023bcc },
		gBattlerPartyIndexes = { 0x02024a6a, 0x0202406e, 0x02023bce },
		gActionsByTurnOrder = { 0x02024a76, 0x0202407a, 0x02023bda },
		gCurrentTurnActionNumber = { 0x02024a7e, 0x02024082, 0x02023be2 },
		gBattleMons = { 0x02024a80, 0x02024084, 0x02023be4 },
		gTakenDmg = { 0x02024bf4, 0x020241f8, 0x02023d58 },
		gBattlerAttacker = { 0x02024c07, 0x0202420B, 0x02023d6b },
		gBattlerTarget = { 0x02024c08, 0x0202420c, 0x02023d6c },
		gBattlescriptCurrInstr = { 0x02024c10, 0x02024214, 0x02023d74 },
		gMoveResultFlags = { 0x02024c68, 0x0202427c, 0x02023dcc },
		gHitMarker = { 0x02024c6c, 0x02024280, 0x02023dd0 },
		gBattleCommunication = { 0x02024d1e, 0x02024332, 0x02023e82 },
		gBattleOutcome = { 0x02024d26, 0x0202433a, 0x02023e8a }, -- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
		gBattleStructPtr = { nil, 0x0202449c, 0x02023fe8 },
		gBattleWeather = { 0x02024db8, 0x020243cc, 0x02023f1c },
		gMoveToLearn = { 0x02024e82, 0x020244e2, 0x02024022 },
		gMapHeader = { 0x0202e828, 0x02037318, 0x02036dfc },
		gSpecialVar_Result = { 0x0202e8dc, 0x020375f0, 0x020370d0 },
		-- RS: gUnknown_0202E8E2
		sSpecialFlags = { 0x0202e8e2, 0x020375fc, 0x020370e0 }, -- [3 = In catching tutorial, 0 = Not in catching tutorial]
		gSpecialVar_ItemId = { 0x0203855e, 0x0203ce7c, 0x0203ad30 },
		-- RS: gAbilitiesPerBank
		sBattlerAbilities = { 0x0203926c, 0x0203aba4, 0x02039a30 },

		-- RS uses this directly, Em/FRLG use a pointer in  IWRAM instead, which is set later
		gSaveBlock1 = { 0x02025734, nil, nil },
		gameStatsOffset = { 0x1540, 0x159C, 0x1200 },
		gameVarsOffset = { 0x1340, 0x139C, 0x1000 }, -- SaveBlock1 -> vars[VARS_COUNT]
		-- RS/Em: [SaveBlock1's flags offset] + [Badge flag offset: SYSTEM_FLAGS / 8]
		-- FRLG: [SaveBlock1's flags offset] + [Badge flag offset: (SYSTEM_FLAGS + FLAG_BADGE01_GET) / 8]
		badgeOffset = { 0x1220 + 0x100, 0x1270 + 0x10C, 0xEE0 + 0x104 },
		bagPocket_Items_offset = { 0x560, 0x560, 0x310 },
		bagPocket_Berries_offset = { 0x740, 0x790, 0x54c },
		bagPocket_Items_Size = { 20, 30, 42 },
		bagPocket_Berries_Size = { 46, 46, 43 },
		-- RS don't use an encryption key
		EncryptionKeyOffset = { nil, 0xAC, 0xF20 },

		-- These addresses are in IWRAM instead in RS, will be set later
		sBattleBuffersTransferData = { nil, 0x02022d10, 0x02022874 },
		gBattleTextBuff1 = { nil, 0x02022f58, 0x02022ab8 },
		gBattleTerrain = { nil, 0x02022ff0, 0x02022b50 },
		-- This address doesn't exist at all in RS
		sStartMenuWindowId = { nil, 0x0203cd8c, 0x0203abe0 },
		sSaveDialogDelay = { nil, 0x2037620, nil},
	}

	for key, address in pairs(addresses) do
		local value = address[GameSettings.game]
		if value ~= nil then
			GameSettings[key] = value
		end
	end
end

-- IWRAM (03xxxxxx) addresses are the same between all english versions of a game, and between all non-english versions.
-- However the addresses are different between english and non-english versions of a game, so need to set them separately.
function GameSettings.setIwramAddresses()
	-- Only have non-english FireRed at the moment
	-- Use nil values for non-existant / deliberately omitted addresses, and 0x00000000 for placeholder unknowns
	-- Format: Address = { Ruby/Sapphire { English, Non-English }, Emerald { English, Non-English }, FireRed/LeafGreen { English, Non-English } }
	local addresses = {
		-- Addresses only in IWRAM for RS, but in EWRAM for Em/FRLG (so were already set by this point, omit to avoid overwrite)
		pstats = { { 0x03004360 }, { nil, nil }, { nil, nil } },
		estats = { { 0x030045C0 }, { nil, nil }, { nil, nil } },
                gPlayerPartyCount = { { 0x03004350 }, { nil, nil }, { nil, nil },},
		sBattleBuffersTransferData = { { 0x03004040 }, { nil, nil }, { nil, nil } },
		gBattleTextBuff1 = { { 0x030041c0 }, { nil, nil }, { nil, nil } },
		gBattleTerrain = { { 0x0300428c }, { nil, nil }, { nil, nil } },

		-- Addresses only in Em/FRLG
		gSaveBlock1ptr = { { nil, nil }, { 0x03005d8c }, { 0x03005008, 0x03004f58 } },
		gSaveBlock2ptr = { { nil, nil }, { 0x03005d90 }, { 0x0300500c, 0x03004f5c } },

		-- R/S: making a guess that this is correct for doubles battle move target pokemon selection cursor: 03004344 g 00000004 gUnknown_03004344
		gMultiUsePlayerCursor = { { 0x03004344 }, { 0x03005d74 }, { 0x03004ff4, nil }, },

		-- IWRAM addresses present in all games
		gBattleResults = { { 0x030042e0 }, { 0x03005d10 }, { 0x03004f90, 0x03004ee0 } },
		gTasks = { { 0x03004b20 }, { 0x03005e00 }, { 0x03005090, 0x03004fe0 } },
		sSaveDialogDelay = {{ 0x30006ac}, {nil, nil}, {0x3000fa8, 0x3000fa8,}},
	}

	local languageIndex = Utils.inlineIf(GameSettings.language == "English", 1, 2)
	for key, address in pairs(addresses) do
		local gameValue = address[GameSettings.game]
		if gameValue ~= nil then
			local languageValue = gameValue[languageIndex]
			if languageValue ~= nil then
				GameSettings[key] = languageValue
			end
		end
	end
end

-- ROM (08xxxxxx) addresses are not necessarily the same between different versions of a game, so set those individually
function GameSettings.setRomAddresses(gameIndex, versionIndex)
	if gameIndex == nil or versionIndex == nil then return end
	-- Only have non-english FireRed at the moment
	-- When adding new non-english games, follow a similar formatting and edit the below format note accordingly
	-- Format:
	-- Address = {
	-- 		Ruby { English 1.0, English 1.1, English 1.2 },
	-- 		Sapphire { English 1.0, English 1.1, English 1.2 },
	-- 		Emerald { English },
	-- 		FireRed { English 1.0, English 1.1, Spanish, Italian, French, German },
	-- 		LeafGreen { English 1.0, English 1.1 },
	-- }
	local addresses = {
		gBattleMoves = {
			{ 0x081fb12c, 0x081fb144, 0x081fb144 },
			{ 0x081fb0bc, 0x081fb0d4, 0x081fb0d4 },
			{ 0x0831c898 },
			{ 0x08250c04, 0x08250c74, 0x0824c3cc, 0x08249ce4, 0x0824b054, 0x08250b28 },
			{ 0x08250be0, 0x08250c50 },
		},
		gBaseStats = {
			{ 0x081fec18, 0x081fec30, 0x081fec30 },
			{ 0x081feba8, 0x081febc0, 0x081febc0 },
			{ 0x083203cc },
			{ 0x08254784, 0x082547f4, 0x0824ff4c, 0x0824d864, 0x0824ebd4, 0x082546a8 },
			{ 0x08254760, 0x082547d0 },
		},
		gExperienceTables = {
			{ 0x081fdf78, 0x081fdf90, 0x081fdf90 },
			{ 0x081fdf08, 0x081fdf20, 0x081fdf20 },
			{ 0x0831f72c },
			{ 0x08253ae4, 0x08253b54, 0x0824f2ac, 0x0824cbc4, 0x0824df34, 0x08253a08 },
			{ 0x08253ac0, 0x08253b30 },
		},
		-- GetEvolutionTargetSpecies + 0x13E
		FriendshipRequiredToEvo = {
			{ 0x0803F5CA, 0x0803F5CA, 0x0803F5CA },
			{ 0x0803F5CA, 0x0803F5CA, 0x0803F5CA },
			{ 0x0806D1D6 },
			{ 0x08043002, 0x08043016, 0x08042EEE, 0x08042EEE, 0x08042EDA, 0x08042F02 },
			{ 0x08043002, 0x08043016 },
		},
		--Task_EvolutionScene + 0x1
		Task_EvolutionScene = {
			{ 0x0811240d, 0x0811244d, 0x0811242d },
			{ 0x0811240d, 0x0811242d, 0x0811242d },
			{ 0x0813e571 },
			{ 0x080ce8dd, 0x080ce8f1, 0x080CEB45, 0x080CEA5D, 0x080CEB3D, 0x080CEA7D },
			{ 0x080ce8b1, 0x080ce8c5 },
		},
		-- BattleScript_RanAwayUsingMonAbility + 0x3
		BattleScript_RanAwayUsingMonAbility = {
			{ 0x081d8e25, 0x081d8e3d, 0x081d8e3d },
			{ 0x081d8db5, 0x081d8dcd, 0x081d8dcd },
			{ 0x082daaec },
			{ 0x081d8912, 0x081d8982, 0x081D8444, 0x081D5D7C, 0x081D70E4, 0x081DCBA8 },
			{ 0x081d88ee, 0x081d895e },
		},
		-- BattleScript_FocusPunchSetUp + 0x10
		BattleScript_FocusPunchSetUp = {
			{ 0x081d94ea, 0x081d9502, 0x081d9502 },
			{ 0x081d947a, 0x081d9492, 0x081d9492 },
			{ 0x082db20f },
			{ 0x081d9025, 0x081d9095, 0x081d8b57, 0x081d648f, 0x081d77f7, 0x081DD2BB },
			{ 0x081d9001, 0x081d9071 },
		},
		-- BattleScript_TryLearnMoveLoop
		BattleScript_LearnMoveLoop = {
			{ 0x081d8f0f, 0x081d8f27, 0x081d8f27 },
			{ 0x081d8e9f, 0x081d8eb7, 0x081d8eb7 },
			{ 0x082dabd9 },
			{ 0x081d8a11, 0x081d8a81, 0x081D8543, 0x081d5e7B, 0x0081D71E3, 0x081DCCA7 },
			{ 0x081d89ed, 0x081d8a5d },
		},
		BattleScript_LearnMoveReturn = {
			{ 0x081d8f61, 0x081d8f79, 0x081d8f79 },
			{ 0x081d8ef1, 0x081d8f09, 0x081d8f09 },
			{ 0x082dac2b },
			{ 0x081d8a63, 0x081d8ad3, 0x081D8595, 0x081D5ECD, 0x081D7235, 0x081DCC55 },
			{ 0x081d8a3f, 0x081d8aaf },
		},
		BattleScript_MoveUsedIsFrozen = {
			{ 0x081d9548, 0x081d9560, 0x081d9560 },
			{ 0x081d94d8, 0x081d94f0, 0x081d94f0 },
			{ 0x082db26d },
			{ 0x081d9083, 0x081D90F3, 0x081D8BB5, 0x081D64ED, 0x081D7855, 0x081D4ECD },
			{ 0x081d905f, 0x081d90cf },
		},
		BattleScript_MoveUsedIsFrozen2 = {
			{ 0x081d954b, 0x081d9563, 0x081d9563 },
			{ 0x081d94db, 0x081d94f3, 0x081d94f3 },
			{ 0x082db270 },
			{ 0x081d9086, 0x081D90F6, 0x081D8BB8, 0x081D64F0, 0x081D7858, 0x081D4ED0 },
			{ 0x081d9062, 0x081d90d2 },
		},
		BattleScript_MoveUsedIsFrozen3 = {
			{ 0x081d954d, 0x081d9565, 0x081d9565 },
			{ 0x081d94dd, 0x081d94f5, 0x081d94f5 },
			{ 0x082db272 },
			{ 0x081d9088, 0x081D90F8, 0x081D8BBA, 0x081D64F2, 0x081D785A, 0x081D4ED2 },
			{ 0x081d9064, 0x081d90d4 },
		},
		BattleScript_MoveUsedUnfroze = {
			{ 0x081d9557, 0x081d956f, 0x081d956f },
			{ 0x081d94e7, 0x081d94ff, 0x081d94ff },
			{ 0x082db27c },
			{ 0x081d9092, 0x081D9102, 0x081D8BC4, 0x081D64FC, 0x081D7864, 0x081D4EDC },
			{ 0x081d906e, 0x081d90de },
		},
		BattleScript_MoveUsedUnfroze2 = {
			{ 0x081d955c, 0x081d9574, 0x081d9574 },
			{ 0x081d94ec, 0x081d9504, 0x081d9504 },
			{ 0x082db281 },
			{ 0x081d9097, 0x081D9107, 0x081D8BC9, 0x081D6501, 0x081D7869, 0x081D4EE1 },
			{ 0x081d9073, 0x081d90e3 },
		},
		BattleScript_MoveUsedIsConfused = {
			{ 0x081d9598, 0x081d95b0, 0x081d95b0 },
			{ 0x081d9528, 0x081d9540, 0x081d9540 },
			{ 0x082db2c0 },
			{ 0x081d90d6, 0x081d9146, 0x081D8C08, 0x081D6540, 0x081D78A8, 0x081DD36C },
			{ 0x081d90b2, 0x081d9122 },
		},
		BattleScript_MoveUsedIsConfused2 = {
			{ 0x081d95a1, 0x081d95b9, 0x081d95b9 },
			{ 0x081d9531, 0x081d9549, 0x081d9549 },
			{ 0x082db2c9 },
			{ 0x081d90df, 0x081d914f, 0x081D8C11, 0x081D6549, 0x081D78B1, 0x081DD375 },
			{ 0x081d90bb, 0x081d912b },
		},
		BattleScript_MoveUsedIsConfusedNoMore = {
			{ 0x081d95d7, 0x081d95ef, 0x081d95ef },
			{ 0x081d9567, 0x081d957f, 0x081d957f },
			{ 0x082db303 },
			{ 0x081d9119, 0x081d9189, 0x081D8C4B, 0x081D6583, 0x081D78EB, 0x081DD3AF },
			{ 0x081d90f5, 0x081d9165 },
		},
		BattleScript_MoveUsedIsInLove = {
			{ 0x081d95fe, 0x081d9616, 0x081d9616 },
			{ 0x081d958e, 0x081d95a6, 0x081d95a6 },
			{ 0x082db32a },
			{ 0x081d9140, 0x081D91B0, 0x081D8C72, 0x081D65AA, 0x081D7912, 0x081DD3D6 },
			{ 0x081d911c, 0x081d918c },
		},
		BattleScript_MoveUsedIsInLove2 = {
			{ 0x081d9607, 0x081d961f, 0x081d961f },
			{ 0x081d9597, 0x081d95af, 0x081d95af },
			{ 0x082db333 },
			{ 0x081d9149, 0x081D91B9, 0x081D8C7B, 0x081D65B3, 0x081D791B, 0x081DD3DF },
			{ 0x081d9125, 0x081d9195 },
		},
		BattleScript_SnatchedMove = {
			{ 0x81d9491, 0x81d94a9, 0x81d94a9,},
			{ 0x81d9421, 0x81d9439, 0x81d9439,},
			{ 0x82db1b6,},
			{ 0x81d8fcc, 0x81d903c, 0x81d8afe, 0x81d6436, 0x81d779e, 0x81dd262,},
			{ 0x81d8fa8, 0x81d9018,}
		},
	}

	for key, address in pairs(addresses) do
		local gameValue = address[gameIndex]
		if gameValue ~= nil then
			local versionValue = gameValue[versionIndex]
			if versionValue ~= nil then
				GameSettings[key] = versionValue
			end
		end
	end
end

-- Maps the BattleScript memory addresses to their respective abilityId's for auto-tracking of abilities
function GameSettings.setAbilityTrackingAddresses(gameIndex, versionIndex)
	if gameIndex == nil or versionIndex == nil then return end
	-- Only have non-english FireRed at the moment
	-- When adding new non-english games, follow a similar formatting and edit the below format note accordingly
	-- Format:
	-- Address = {
	-- 		Ruby { English 1.0, English 1.1, English 1.2 },
	-- 		Sapphire { English 1.0, English 1.1, English 1.2 },
	-- 		Emerald { English },
	-- 		FireRed { English 1.0, English 1.1, Spanish, Italian, French, German },
	-- 		LeafGreen { English 1.0, English 1.1 },
	-- }
	local abilityScripts = {
		-- BattleScript_DrizzleActivates + 0x0
		DrizzleActivates = {
			{ 0x081d9704, 0x081d971c, 0x081d971c },
			{ 0x081d9694, 0x081d96ac, 0x081d96ac },
			{ 0x082db430 },
			{ 0x081d927f, 0x081d92ef, 0x081d8db1, 0x081d66e9, 0x081d7a51, 0x081DD515 },
			{ 0x081d925b, 0x081d92cb },
		},
		-- BattleScript_SpeedBoostActivates + 0x7
		SpeedBoostActivates = {
			{ 0x081d971f, 0x081d9737, 0x081d9737 },
			{ 0x081d96af, 0x081d96c7, 0x081d96c7 },
			{ 0x082db44b },
			{ 0x081d929a, 0x081d930a, 0x081d8dcc, 0x081d6704, 0x081d7a6c, 0x081DD530 },
			{ 0x081d9276, 0x081d92e6 },
		},
		-- RS: BattleScript_1D97F0 + 0x6
		-- Em: BattleScript_IntimidatePrevented + 0x6
		-- FRLG: BattleScript_IntimidateAbilityFail + 0x6
		IntimidateAbilityFail = {
			{ 0x081d97f6, 0x081d980e, 0x081d980e },
			{ 0x081d9786, 0x081d979e, 0x081d979e },
			{ 0x082db522 },
			{ 0x081d9371, 0x081d93e1, 0x081d8ea3, 0x081d67db, 0x081d7b43, 0x081DD607 },
			{ 0x081d934d, 0x081d93bd },
		},
		-- RS: BattleScript_1D97A1 + 0x3d
		-- Em: BattleScript_IntimidateActivatesLoop + 0x3d
		-- FRLG: BattleScript_IntimidateActivationAnimLoop + 0x3d
		IntimidateActivationAnimLoop = {
			{ 0x081d97de, 0x081d97f6, 0x081d97f6 },
			{ 0x081d976e, 0x081d9786, 0x081d9786 },
			{ 0x082db50a },
			{ 0x081d9359, 0x081d93c9, 0x081d8e8b, 0x081d67c3, 0x081d7b2b, 0x081DD5EF },
			{ 0x081d9335, 0x081d93a5 },
		},
		-- BattleScript_TraceActivates + 0x6
		TraceActivates = {
			{ 0x081d972c, 0x081d9744, 0x081d9744 },
			{ 0x081d96bc, 0x081d96d4, 0x081d96d4 },
			{ 0x082db458 },
			{ 0x081d92a7, 0x081d9317, 0x081d8dd9, 0x081d6711, 0x081d7a79, 0x081DD53D },
			{ 0x081d9283, 0x081d92f3 },
		},
		-- RS: BattleScript_1D7E73 + 0x3
		-- Em/FRLG: BattleScript_PerishSongNotAffected + 0x3
		PerishSongNotAffected = {
			{ 0x081d7e76, 0x081d7e8e, 0x081d7e8e },
			{ 0x081d7e06, 0x081d7e1e, 0x081d7e1e },
			{ 0x082d99af },
			{ 0x081d788f, 0x081D78FF, 0x081D7E3D, 0x081D4CF9, 0x081D6061, 0x081DBB25 },
			{ 0x081d787b, 0x081d78eb },
		},
		-- BattleScript_SandstreamActivates + 0x0
		SandstreamActivates = {
			{ 0x081d9744, 0x081d975c, 0x081d975c },
			{ 0x081d96d4, 0x081d96ec, 0x081d96ec },
			{ 0x082db470 },
			{ 0x081d92bf, 0x081d932f, 0x081d8df1, 0x081d6729, 0x081d7a91, 0x081DD555 },
			{ 0x081d929b, 0x081d930b },
		},
		-- BattleScript_ShedSkinActivates + 0x3
		ShedSkinActivates = {
			{ 0x081d975b, 0x081d9773, 0x081d9773 },
			{ 0x081d96eb, 0x081d9703, 0x081d9703 },
			{ 0x082db487 },
			{ 0x081d92d6, 0x081d9346, 0x081d8e08, 0x081d6740, 0x081d7aa8, 0x081DD56C },
			{ 0x081d92b2, 0x081d9322 },
		},
		-- BattleScript_DroughtActivates + 0x0
		DroughtActivates = {
			{ 0x081d97fe, 0x081d9816, 0x081d9816 },
			{ 0x081d978e, 0x081d97a6, 0x081d97a6 },
			{ 0x082db52a },
			{ 0x081d9379, 0x081d93e9, 0x081d8eab, 0x081d67e3, 0x081d7b4b, 0x081DD60F },
			{ 0x081d9355, 0x081d93c5 },
		},
		-- BattleScript_AbilityNoStatLoss + 0x6
		AbilityNoStatLoss = {
			{ 0x081d98a1, 0x081d98b9, 0x081d98b9 },
			{ 0x081d9831, 0x081d9849, 0x081d9849 },
			{ 0x082db5cd },
			{ 0x081d941c, 0x081d948c, 0x081d8f4e, 0x081d6886, 0x081d7bee, 0x081DD6B2 },
			{ 0x081d93f8, 0x081d9468 },
		},
		-- BattleScript_AbilityNoSpecificStatLoss + 0x6
		AbilityNoSpecificStatLoss = {
			{ 0x081d9909, 0x081d9921, 0x081d9921 },
			{ 0x081d9899, 0x081d98b1, 0x081d98b1 },
			{ 0x082db635 },
			{ 0x081d9484, 0x081d94f4, 0x081d8fb6, 0x081d68ee, 0x081d7c56, 0x081DD71A },
			{ 0x081d9460, 0x081d94d0 },
		},
		-- BattleScript_SturdyPreventsOHKO + 0x6
		SturdyPreventsOHKO = {
			{ 0x081d982c, 0x081d9844, 0x081d9844 },
			{ 0x081d97bc, 0x081d97d4, 0x081d97d4 },
			{ 0x082db558 },
			{ 0x081d93a7, 0x081d9417, 0x081d8ed9, 0x081d6811, 0x081d7b79, 0x081DD63D },
			{ 0x081d9383, 0x081d93f3 },
		},
		-- BattleScript_ObliviousPreventsAttraction + 0x0
		ObliviousPreventsAttraction = {
			{ 0x081d98c9, 0x081d98e1, 0x081d98e1 },
			{ 0x081d9859, 0x081d9871, 0x081d9871 },
			{ 0x082db5f5 },
			{ 0x081d9444, 0x081d94b4, 0x081d8f76, 0x081d68ae, 0x081d7c16, 0x081DD6DA },
			{ 0x081d9420, 0x081d9490 },
		},
		-- BattleScript_ColorChangeActivates + 0x3
		ColorChangeActivates = {
			{ 0x081d9924, 0x081d993c, 0x081d993c },
			{ 0x081d98b4, 0x081d98cc, 0x081d98cc },
			{ 0x082db650 },
			{ 0x081d949f, 0x081d950f, 0x081d8fd1, 0x081d6909, 0x081d7c71, 0x081DD735 },
			{ 0x081d947b, 0x081d94eb },
		},
		-- BattleScript_FlashFireBoost + 0x9
		FlashFireBoost = {
			{ 0x081d9885, 0x081d989d, 0x081d989d },
			{ 0x081d9815, 0x081d982d, 0x081d982d },
			{ 0x082db5b1 },
			{ 0x081d9400, 0x081d9470, 0x081d8f32, 0x081d686a, 0x081d7bd2, 0x081DD696 },
			{ 0x081d93dc, 0x081d944c },
		},
		-- BattleScript_OwnTempoPrevents + 0x0
		OwnTempoPrevents = {
			{ 0x081d98e5, 0x081d98fd, 0x081d98fd },
			{ 0x081d9875, 0x081d988d, 0x081d988d },
			{ 0x082db611 },
			{ 0x081d9460, 0x081d94d0, 0x081d8f92, 0x081d68ca, 0x081d7c32, 0x081DD6F6 },
			{ 0x081d943c, 0x081d94ac },
		},
		-- BattleScript_AbilityPreventsPhasingOut + 0x6
		AbilityPreventsPhasingOut = {
			{ 0x081d9893, 0x081d98ab, 0x081d98ab },
			{ 0x081d9823, 0x081d983b, 0x081d983b },
			{ 0x082db5bf },
			{ 0x081d940e, 0x081d947e, 0x081d8f40, 0x081d6878, 0x081d7be0, 0x081DD6A4 },
			{ 0x081d93ea, 0x081d945a },
		},
		-- BattleScript_RoughSkinActivates + 0x10
		RoughSkinActivates = {
			{ 0x081d9938, 0x081d9950, 0x081d9950 },
			{ 0x081d98c8, 0x081d98e0, 0x081d98e0 },
			{ 0x082db664 },
			{ 0x081d94b3, 0x081d9523, 0x081d8fe5, 0x081d691d, 0x081d7c85, 0x081DD749 },
			{ 0x081d948f, 0x081d94ff },
		},
		-- BattleScript_CuteCharmActivates + 0x9
		CuteCharmActivates = {
			{ 0x081d994c, 0x081d9964, 0x081d9964 },
			{ 0x081d98dc, 0x081d98f4, 0x081d98f4 },
			{ 0x082db678 },
			{ 0x081d94c7, 0x081d9537, 0x081d8ff9, 0x081d6931, 0x081d7c99, 0x081DD75D },
			{ 0x081d94a3, 0x081d9513 },
		},
		-- RS: BattleScript_NoItemSteal + 0x0
		-- em/FRLG: BattleScript_StickyHoldActivates + 0x0
		StickyHoldActivates = {
			{ 0x081d9913, 0x081d992b, 0x081d992b },
			{ 0x081d98a3, 0x081d98bb, 0x081d98bb },
			{ 0x082db63f },
			{ 0x081d948e, 0x081d94fe, 0x081d8fc0, 0x081d68f8, 0x081d7c60, 0x081DD724 },
			{ 0x081d946a, 0x081d94da },
		},
		-- BattleScript_AbsorbUpdateHp + 0x14
		AbsorbUpdateHp = {
			{ 0x081d7053, 0x081d706b, 0x081d706b },
			{ 0x081d6fe3, 0x081d6ffb, 0x081d6ffb },
			{ 0x082d8b42 },
			{ 0x081d6a3f, 0x081d6aaf, 0x081d6571, 0x081d3ea9, 0x081d5211, 0x081DACD5 },
			{ 0x081d6a1b, 0x081d6a8b },
		},
		-- BattleScript_TookAttack + 0x7
		TookAttack = {
			{ 0x081d9819, 0x081d9831, 0x081d9831 },
			{ 0x081d97a9, 0x081d97c1, 0x081d97c1 },
			{ 0x082db545 },
			{ 0x081d9394, 0x081d9404, 0x081D8EC6, 0x081D67FE, 0x081D7B66, 0x081DD62A },
			{ 0x081d9370, 0x081d93e0 },
		},
		-- BattleScript_MoveHPDrain + 0x14
		MoveHPDrain = {
			{ 0x081d9857, 0x081d986f, 0x081d986f },
			{ 0x081d97e7, 0x081d97ff, 0x081d97ff },
			{ 0x082db583 },
			{ 0x081d93d2, 0x081d9442, 0x081d8f04, 0x081d683c, 0x081d7ba4, 0x081DD668 },
			{ 0x081d93ae, 0x081d941e },
		},
		-- RS: BattleScript_MoveHPDrain_FullHP + 0x7
		-- Em/FRLG: BattleScript_MonMadeMoveUseless + 0x7
		MonMadeMoveUseless = {
			{ 0x081d986d, 0x081d9885, 0x081d9885 },
			{ 0x081d97fd, 0x081d9815, 0x081d9815 },
			{ 0x082db599 },
			{ 0x081d93e8, 0x081d9458, 0x081d8f1a, 0x081d6852, 0x081d7bba, 0x081DD67E },
			{ 0x081d93c4, 0x081d9434 },
		},
		-- BattleScript_PRLZPrevention + 0x8
		PRLZPrevention = {
			{ 0x081d98b9, 0x081d98d1, 0x081d98d1 },
			{ 0x081d9849, 0x081d9861, 0x081d9861 },
			{ 0x082db5e5 },
			{ 0x081d9434, 0x081d94a4, 0x081d8f66, 0x081d689e, 0x081d7c06, 0x081DD6CA },
			{ 0x081d9410, 0x081d9480 },
		},
		-- BattleScript_PSNPrevention + 0x8
		PSNPrevention = {
			{ 0x081d98c5, 0x081d98dd, 0x081d98dd },
			{ 0x081d9855, 0x081d986d, 0x081d986d },
			{ 0x082db5f1 },
			{ 0x081d9440, 0x081d94b0, 0x081d8f72, 0x081d68aa, 0x081d7c12, 0x081DD6D6 },
			{ 0x081d941c, 0x081d948c },
		},
		-- BattleScript_BRNPrevention + 0x8
		BRNPrevention = {
			{ 0x081d98ad, 0x081d98c5, 0x081d98c5 },
			{ 0x081d983d, 0x081d9855, 0x081d9855 },
			{ 0x082db5d9 },
			{ 0x081d9428, 0x081d9498, 0x081d8f5a, 0x081d6892, 0x081d7bfa, 0x081DD6BE },
			{ 0x081d9404, 0x081d9474 },
		},
		--BattleScript_FlinchPrevention + 0x6
		FlinchPrevention = {
			{ 0x81d98dd, 0x81d98f5, 0x81d98f5,},
			{ 0x81d986d, 0x81d9885, 0x81d9885,},
			{ 0x82db609,},
			{ 0x81d9458, 0x81d94c8, 0x81d8f8a, 0x81d68c2, 0x81d7c2a, 0x81dd6ee,},
			{ 0x81d9434, 0x81d94a4,}
		},
		-- BattleScript_CantMakeAsleep + 0x8
		CantMakeAsleep = {
			{ 0x081d6fe8, 0x081d7000, 0x081d7000 },
			{ 0x081d6f78, 0x081d6f90, 0x081d6f90 },
			{ 0x082d8ad7 },
			{ 0x081d69d4, 0x081d6a44, 0x081d6506, 0x081d3e3e, 0x081d51a6, 0x081DAC6A },
			{ 0x081d69b0, 0x081d6a20 },
		},
		-- BattleScript_PrintAbilityMadeIneffective
		PrintAbilityMadeIneffective = {
			{ 0x081d8839, 0x081d8851, 0x081d8851 },
			{ 0x081d87c9, 0x081d87e1, 0x081d87e1 },
			{ 0x082da382 },
			{ 0x081d8255, 0x81D82C5, 0x081D7D87, 0x081D56BF, 0x081D6A27, 0x081DC4EB },
			{ 0x081d8231, 0x081d82a1 },
		},
		-- BattleScript_RainDishActivates + 0x3
		RainDishActivates = {
			{ 0x081d9733, 0x081d974b, 0x081d974b },
			{ 0x081d96c3, 0x081d96db, 0x081d96db },
			{ 0x082db45f },
			{ 0x081d92ae, 0x081d931e, 0x081d8de0, 0x081d6718, 0x081d7a80, 0x081DD544 },
			{ 0x081d928a, 0x081d92fa },
		},
		-- BattleScript_MoveUsedLoafingAround + 0x5
		MoveUsedLoafingAround = {
			{ 0x081d997c, 0x081d9994, 0x081d9994 },
			{ 0x081d990c, 0x081d9924, 0x081d9924 },
			{ 0x082db6cc },
			{ 0x081d94f7, 0x081d9567, 0x081d9029, 0x081d6961, 0x081d7cc9, 0x081DD78D },
			{ 0x081d94d3, 0x081d9543 },
		},
		-- BattleScript_RestCantSleep + 0x8
		RestCantSleep = {
			{ 0x081d74ce, 0x081d74e6, 0x081d74e6 },
			{ 0x081d745e, 0x081d7476, 0x081d7476 },
			{ 0x082d8fce },
			{ 0x081d6eba, 0x081d6f2a, 0x081d69ec, 0x081d4324, 0x081d568c, 0x081DB150 },
			{ 0x081d6e96, 0x081d6f06 },
		},
		-- BattleScript_MoveEffectSleep + 0x7
		MoveEffectSleep = {
			{ 0x081d9645, 0x081d965d, 0x081d965d },
			{ 0x081d95d5, 0x081d95ed, 0x081d95ed },
			{ 0x082db371 },
			{ 0x081d91c0, 0x081d9230, 0x081d8cf2, 0x081d662a, 0x081d7992, 0x081DD456 },
			{ 0x081d919c, 0x081d920c },
		},
		-- BattleScript_MoveEffectParalysis + 0x7
		MoveEffectParalysis = {
			{ 0x081d968e, 0x081d96a6, 0x081d96a6 },
			{ 0x081d961e, 0x081d9636, 0x081d9636 },
			{ 0x082db3ba },
			{ 0x081d9209, 0x081d9279, 0x081d8d3b, 0x081d6673, 0x081d79db, 0x081DD49F },
			{ 0x081d91e5, 0x081d9255 },
		},
		-- BattleScript_MoveEffectPoison + 0x7
		MoveEffectPoison = {
			{ 0x081d9661, 0x081d9679, 0x081d9679 },
			{ 0x081d95f1, 0x081d9609, 0x081d9609 },
			{ 0x082db38d },
			{ 0x081d91dc, 0x081d924c, 0x081d8d0e, 0x081d6646, 0x081d79ae, 0x081DD472 },
			{ 0x081d91b8, 0x081d9228 },
		},
		-- BattleScript_MoveEffectBurn + 0x7
		MoveEffectBurn = {
			{ 0x081d9670, 0x081d9688, 0x081d9688 },
			{ 0x081d9600, 0x081d9618, 0x081d9618 },
			{ 0x082db39c },
			{ 0x081d91eb, 0x081d925b, 0x081d8d1d, 0x081d6655, 0x081d79bd, 0x081DD481 },
			{ 0x081d91c7, 0x081d9237 },
		},
		-- BattleScript_DampStopsExplosion + 0x6
		DampStopsExplosion = {
			{ 0x081d983a, 0x081d9852, 0x081d9852 },
			{ 0x081d97ca, 0x081d97e2, 0x081d97e2 },
			{ 0x082db566 },
			{ 0x081d93b5, 0x081d9425, 0x081d8ee7, 0x081d681f, 0x081d7b87, 0x081DD64B },
			{ 0x081d9391, 0x081d9401 },
		},
		-- BattleScript_SoundproofProtected + 0x8
		SoundproofProtected = {
			{ 0x081d98fb, 0x081d9913, 0x081d9913 },
			{ 0x081d988b, 0x081d98a3, 0x081d98a3 },
			{ 0x082db627 },
			{ 0x081d9476, 0x081d94e6, 0x081d8fa8, 0x081d68e0, 0x081d7c48, 0x081DD70C },
			{ 0x081d9452, 0x081d94c2 },
		},
		-- BattleScript_EffectHealBell + 0x29
		EffectHealBell = {
			{ 0x081d7bde, 0x081d7bf6, 0x081d7bf6 },
			{ 0x081d7b6e, 0x081d7b86, 0x081d7b86 },
			{ 0x082d96ea },
			{ 0x081d75ca, 0x081d763a, 0x081d70fc, 0x081d4a34, 0x081d5d9c, 0x081DB860 },
			{ 0x081d75a6, 0x081d7616 },
		},
		-- BattleScript_LeechSeedTurnPrintAndUpdateHp + 0x12
		LeechSeedTurnPrintAndUpdateHp = {
			{ 0x081d9095, 0x081d90ad, 0x081d90ad },
			{ 0x081d9025, 0x081d903d, 0x081d903d },
			{ 0x082dad5f },
			{ 0x081d8b97, 0x081d8c07, 0x081d86c9, 0x081d6001, 0x081d7369, 0x081DCE2D },
			{ 0x081d8b73, 0x081d8be3 },
		},
	}

	-- Map the BattleScript addresses to the relevant abilityID's for ability tracking
	GameSettings.ABILITIES = {
		BATTLER = { -- Abiliities where we can use gBattleStruct -> scriptingActive to determine enemy/player
			[abilityScripts.DrizzleActivates[gameIndex][versionIndex]] = {[2] = true}, -- Drizzle
			[abilityScripts.SpeedBoostActivates[gameIndex][versionIndex]] = {[3] = true}, -- Speed Boost
			[abilityScripts.IntimidateAbilityFail[gameIndex][versionIndex]] = {[22] = true}, -- Intimidate Fail
			[abilityScripts.IntimidateActivationAnimLoop[gameIndex][versionIndex]] = {[22] = true}, -- Intimidate Succeed
			[abilityScripts.TraceActivates[gameIndex][versionIndex]] = {[36] = true}, -- Trace
			[abilityScripts.PerishSongNotAffected[gameIndex][versionIndex]] = {[43] = true}, -- Soundproof (Perish Song)
			[abilityScripts.SandstreamActivates[gameIndex][versionIndex]] = {[45] = true}, -- Sand Stream
			[abilityScripts.ShedSkinActivates[gameIndex][versionIndex]] = {[61] = true}, -- Shed Skin
			[abilityScripts.DroughtActivates[gameIndex][versionIndex]] = {[70] = true}, -- Drought
			[abilityScripts.AbilityNoStatLoss[gameIndex][versionIndex]] = {
				[29] = true, -- Clear Body
				[73] = true, -- White Smoke
			},
			[abilityScripts.AbilityNoSpecificStatLoss[gameIndex][versionIndex]] = {
				[51] = true, -- Keen Eye
				[52] = true, -- Hyper Cutter
			},
		},
		REVERSE_BATTLER = { -- Abilities like BATTLER, but with logic reversed
			[abilityScripts.IntimidateAbilityFail[gameIndex][versionIndex]] = { -- Intimidate Fail
				[29] = true, -- Clear Body
				[52] = true, -- Hyper Cutter
				[73] = true, -- White Smoke
			},
		},
		ATTACKER = { -- Abilities where we can use gBattlerAttacker to determine enemy/player
			[abilityScripts.SturdyPreventsOHKO[gameIndex][versionIndex]] = {[5] = true}, -- Sturdy
			[abilityScripts.ObliviousPreventsAttraction[gameIndex][versionIndex]] = {[12] = true}, -- Oblivious
			[abilityScripts.ColorChangeActivates[gameIndex][versionIndex]] = {[16] = true}, -- Color Change
			[abilityScripts.FlashFireBoost[gameIndex][versionIndex]] = {[18] = true}, -- Flash Fire
			[abilityScripts.OwnTempoPrevents[gameIndex][versionIndex]] = {[20] = true}, -- Own Tempo
			[abilityScripts.AbilityPreventsPhasingOut[gameIndex][versionIndex]] = {[21] = true}, -- Suction Cups
			[abilityScripts.RoughSkinActivates[gameIndex][versionIndex]] = {[24] = true}, -- Rough Skin
			[abilityScripts.CuteCharmActivates[gameIndex][versionIndex]] = {[56] = true}, -- Cute Charm
			[abilityScripts.StickyHoldActivates[gameIndex][versionIndex]] = {[60] = true}, -- Sticky Hold
			[abilityScripts.AbsorbUpdateHp[gameIndex][versionIndex]] = {[64] = true}, -- Liquid Ooze (Drain Moves)
			[abilityScripts.TookAttack[gameIndex][versionIndex]] = {[31] = true}, -- LightningRod
			[abilityScripts.MoveHPDrain[gameIndex][versionIndex]] = { -- Ability heals HP
				[10] = true, -- Volt Absorb
				[11] = true, -- Water Absorb
			},
			[abilityScripts.MonMadeMoveUseless[gameIndex][versionIndex]] = { -- Ability nullifies move
				[10] = true, -- Volt Absorb
				[11] = true, -- Water Absorb
			},
			[abilityScripts.PRLZPrevention[gameIndex][versionIndex]] = { -- Ability prevents paralysis
				[7] = true, -- Limber
				[28] = true, -- Synchronize (is unable to inflict paralysis on other mon)
			},
			[abilityScripts.PSNPrevention[gameIndex][versionIndex]] = { -- Ability prevents poison
				[17] = true, -- Immunity
				[28] = true, -- Synchronize (is unable to inflict poison on other mon)
			},
			[abilityScripts.BRNPrevention[gameIndex][versionIndex]] = { -- Ability prevents burn
				[28] = true, -- Synchronize (is unable to inflict burn on other mon)
				[41] = true, -- Water Veil
			},
			[abilityScripts.CantMakeAsleep[gameIndex][versionIndex]] = { -- Ability prevents sleep
				[15] = true, -- Insomnia
				[72] = true, -- Vital Spirit
			},
			[abilityScripts.PrintAbilityMadeIneffective[gameIndex][versionIndex]] = { -- Ability prevents sleep (Yawn)
				[15] = true, -- Insomnia
				[72] = true, -- Vital Spirit
			},
			[abilityScripts.FlinchPrevention[gameIndex][versionIndex]] = { -- Ability prevents flinching
				[39] = true, -- Inner Focus
			},
		},
		REVERSE_ATTACKER = { -- Abilities like the above ATTACKER checks, but logic is reversed
			[abilityScripts.RainDishActivates[gameIndex][versionIndex]] = {[44] = true}, -- Rain Dish
			[abilityScripts.MoveUsedLoafingAround[gameIndex][versionIndex]] = {[54] = true}, -- Truant
			[abilityScripts.RestCantSleep[gameIndex][versionIndex]] = { -- Ability prevents sleep (Rest)
				[15] = true, -- Insomnia
				[72] = true, -- Vital Spirit
			},
		},
		STATUS_INFLICT = { -- Abilities which apply a status effect on the opposing mon
			[abilityScripts.MoveEffectSleep[gameIndex][versionIndex]] = {[27] = true}, -- Effect Spore (Sleep)
			[abilityScripts.MoveEffectParalysis[gameIndex][versionIndex]] = { -- Ability inflicts paralysis
				[9] = true, -- Static
				[27] = true, -- Effect Spore
				[28] = true, -- Synchronize
			},
			[abilityScripts.MoveEffectPoison[gameIndex][versionIndex]] = { -- Abulity inflicts poison
				[27] = true, -- Effect Spore
				[28] = true, -- Synchronize
				[38] = true, -- Poison Point
			},
			[abilityScripts.MoveEffectBurn[gameIndex][versionIndex]] = { -- Ability inflicts burn
				[28] = true, -- Synchronize
				[49] = true, -- Flame Body
			},
		},
		BATTLE_TARGET = { -- Abilities where we can use gBattlerTarget to determine enemy/player
			[abilityScripts.DampStopsExplosion[gameIndex][versionIndex]] = { -- Damp
				[6] = true, -- Damp
				scope = "both",
			},
			[abilityScripts.SoundproofProtected[gameIndex][versionIndex]] = { -- Soundproof (General)
				[43] = true, -- Soundproof
				scope = "self",
			},
			[abilityScripts.EffectHealBell[gameIndex][versionIndex]] = { -- Soundproof (Enemy uses Heal Bell)
				[43] = true, -- Soundproof
				scope = "self",
			},
			[abilityScripts.LeechSeedTurnPrintAndUpdateHp[gameIndex][versionIndex]] = { -- Liquid Ooze (Leech Seed)
				[64] = true, -- Liquid Ooze
				scope = "other",
			},
		},
	}
end

function GameSettings.getTrackerAutoSaveName()
	local filenameEnding = FileManager.PostFixes.AUTOSAVE .. FileManager.Extensions.TRACKED_DATA

	-- Remove trailing " (___)" from game name
	return GameSettings.gamename:gsub("%s%(.*%)", " ") .. filenameEnding
end

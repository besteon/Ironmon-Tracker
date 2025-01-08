-- Holds relevant game addresses for game currently being played. On Tracker startup, this will load those addresses from a JSON file in ~\ironmon_tracker\GameAddresses\
GameSettings = {
	RomHeaders = {
		-- Usage: Utils.reverseEndian32(Memory.read32(gameCode))
		GameCode = 0x080000AC,
		-- Usage: Utils.reverseEndian32(Memory.read32(softwareVersion))
		SoftwareVersion = 0x080000BC,
	},
	RomHackSupport = {
		NatDex = true, -- Support for Nat. Dex added as of v8.5.0
		PhysSpecSplit = true, -- Support for Moves having the Physical/Special split
	},
}

-- All supported Pokemon Game ROMs; each entry is a table containg the `name`, `softwareVersion` (RomHeaderSoftwareVersion), and `gameCode` (RomHeaderGameCode)
GameSettings.RomVersions = {
	Ruby_v1_0 = 		{ name = "Pokémon Ruby v1.0", 		softwareVersion = 0x00410000, 	gameCode = 0x41585645 },
	Ruby_v1_1 = 		{ name = "Pokémon Ruby v1.1", 		softwareVersion = 0x01400000, 	gameCode = 0x41585645 },
	Ruby_v1_2 = 		{ name = "Pokémon Ruby v1.2", 		softwareVersion = 0x023F0000, 	gameCode = 0x41585645 },
	Sapphire_v1_0 = 	{ name = "Pokémon Sapphire v1.0", 	softwareVersion = 0x00550000, 	gameCode = 0x41585045 },
	Sapphire_v1_1 = 	{ name = "Pokémon Sapphire v1.1", 	softwareVersion = 0x01540000, 	gameCode = 0x41585045 },
	Sapphire_v1_2 = 	{ name = "Pokémon Sapphire v1.2", 	softwareVersion = 0x02530000, 	gameCode = 0x41585045 },
	Emerald = 			{ name = "Pokémon Emerald", 		softwareVersion = 0x00720000, 	gameCode = 0x42504545 },
	FireRed_v1_0 = 		{ name = "Pokémon FireRed v1.0", 	softwareVersion = 0x00680000, 	gameCode = 0x42505245 },
	FireRed_v1_1 = 		{ name = "Pokémon FireRed v1.1", 	softwareVersion = 0x01670000, 	gameCode = 0x42505245 },
	FireRed_Spanish = 	{ name = "Pokémon Rojo Fuego", 		softwareVersion = 0x005A0000, 	gameCode = 0x42505253 },
	FireRed_Italian = 	{ name = "Pokémon Rosso Fuoco", 	softwareVersion = 0x00640000, 	gameCode = 0x42505249 },
	FireRed_French = 	{ name = "Pokémon Rouge Feu", 		softwareVersion = 0x00670000, 	gameCode = 0x42505246 },
	FireRed_German = 	{ name = "Pokémon Feuerrote", 		softwareVersion = 0x00690000, 	gameCode = 0x42505244 },
	FireRed_Japanese = 	{ name = "Pokémon FireRed J", 		softwareVersion = 0x00630000, 	gameCode = 0x4250524A },
	LeafGreen_v1_0 = 	{ name = "Pokémon LeafGreen v1.0", 	softwareVersion = 0x00810000, 	gameCode = 0x42504745 },
	LeafGreen_v1_1 = 	{ name = "Pokémon LeafGreen v1.1", 	softwareVersion = 0x01800000, 	gameCode = 0x42504745 },
}

--[[ Symbols tables references
Ruby:
	- 1.0: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby.sym
	- 1.1: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev1.sym
	- 1.2: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokeruby_rev2.sym
Sapphire:
	- 1.0: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire.sym
	- 1.1: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev1.sym
	- 1.2: https://raw.githubusercontent.com/pret/pokeruby/symbols/pokesapphire_rev2.sym
Emerald:
	- 1.0: https://raw.githubusercontent.com/pret/pokeemerald/symbols/pokeemerald.sym
FireRed:
	- 1.0: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered.sym
	- 1.1: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokefirered_rev1.sym
	- Non-English versions are based on 1.1
	- Ability script offsets:
		- Spanish script addresses = English 1.1 address - 0x53e
		- Italian script addresses = English 1.1 address - 0x2c06
		- French script addresses = English 1.1 address - 0x189e
		- German script addresses = English 1.1 address + 0x4226
		- Japanese script addresses = English 1.1 address + 0x????
LeafGreen:
	- 1.0: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen.sym
	- 1.1: https://raw.githubusercontent.com/pret/pokefirered/symbols/pokeleafgreen_rev1.sym

General Notes:
	- EWRAM (02xxxxxx) addresses are the same between all versions of a game
	- IWRAM (03xxxxxx) addresses are the same between all english versions of a game, and between all non-english versions.
	- ROM (08xxxxxx) addresses are not necessarily the same between different versions of a game, so set those individually
]]

--[[ JSON File Formats
- NOTE: any "string(hexcode)" will be converted (base 16) and used as a number;
- any "number" value is treated as the regular numerical value (base 10)
- Use https://beautifier.io/ for human readable formatting

Individual Game Version: (i.e. "Pokemon FireRed v1.1.json")
{
	"GameInfo":{
		"GameCode":number,					i.e. 1112560197
		"VersionColor":string,				i.e. "FireRed"
		"Language":string,					i.e. "English"
		"VersionName":string,				i.e. "Pokémon FireRed v1.1"
		"VersionGroup":number,				i.e. 2
		"GameName":string,					i.e. "Pokemon FireRed (U)"
		"GameNumber:number,					i.e. 3
	},
	"Addresses":{
		"NameKey":string(hexcode),			i.e. "gBattleMons":"02024a80", (numerical strings are converted to base 16)
		...
	},
	"AbilityAddresses":{
		"AbilityTriggerNameKey":{			i.e. "MoveEffectParalysis"
			"sourceTrigger":string,			i.e. "STATUS_INFLICT"
			"abilityIds":array(number),		i.e. [9,27,28]
			"address":string(hexcode),		i.e. "81D9279", (numerical strings are converted to base 16)
			"scope":string,					i.e. "self"
		},
		...
	},
}

JSON File Format: Various Tracker Address/Value Overrides:
{
	"FileNameKey":{							i.e. "PokemonData",
		"Addresses":{
			"NameKey":string(hexcode),		i.e. "offsetBaseFriendship":"12", (numerical strings are converted to base 16)
			...
		},
		"Values":{
			"NameKey":number,				i.e. "FriendshipRequiredToEvo":220,
			"NameKey":string(hexcode),
			...
		},
	},
	...
}
]]

GameSettings.ABILITIES = {}

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
	local success = GameSettings.importAddressesFromJson()
	if success then
		success = GameSettings.importTrackerOverridesFromJson()
	end

	if not success then
		GameSettings.gamename = "Unsupported Game"
		Main.DisplayError("This game is unsupported by the Ironmon Tracker.\n\nCheck the Tracker's README.txt file for currently supported games.")
	end
end

-- INTERNAL FUNCTIONS
local function _encodeAddressForJson(address)
	if type(address) == "number" then
		return string.format("%x", address):upper()
	else
		return address
	end
end
local function _decodeAddressFromJson(address)
	if type(address) == "string" then
		address = Utils.replaceText(address, "0x", "") -- remove leading hexcode identifier (if any)
		return tonumber(address, 16) or tonumber(address)
	else
		return address
	end
end

---Imports all necessary ROM addresses and values from the a JSON file for the loaded game
---@param filepath? string Optional, a custom JSON file, usually for rom hacks or unsupported game versions
---@return boolean success
function GameSettings.importAddressesFromJson(filepath)
	filepath = filepath or GameSettings.getRomAddressesFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not (data and data.GameInfo and data.GameInfo.GameName) then
		return false
	end

	xpcall(function()
		-- GameInfo
		GameSettings.gamecode = data.GameInfo.GameCode
		GameSettings.game = data.GameInfo.GameNumber -- 1:Ruby/Sapphire, 2:Emerald, 3:FireRed/LeafGreen
		GameSettings.gamename = data.GameInfo.GameName
		GameSettings.versiongroup = data.GameInfo.VersionGroup -- 1:Ruby/Sapphire/Emerald, 2:FireRed/LeafGreen
		GameSettings.versioncolor = data.GameInfo.VersionColor
		GameSettings.language = data.GameInfo.Language
		GameSettings.fullVersionName = data.GameInfo.VersionName

		-- Addresses
		for key, address in pairs(data.Addresses or {}) do
			local addressAsNumber = _decodeAddressFromJson(address)
			if type(addressAsNumber) == "number" then
				GameSettings[key] = addressAsNumber
			end
		end

		-- AbilityAddresses
		GameSettings.ABILITIES = {}
		for key, abilityInfo in pairs(data.AbilityAddresses or {}) do
			local addressAsNumber = _decodeAddressFromJson(abilityInfo.address)
			if not Utils.isNilOrEmpty(abilityInfo.sourceTrigger) and type(addressAsNumber) == "number" then
				-- Get/Create corresponding ability trigger table
				GameSettings.ABILITIES[abilityInfo.sourceTrigger] = GameSettings.ABILITIES[abilityInfo.sourceTrigger] or {}
				local sourceTable = GameSettings.ABILITIES[abilityInfo.sourceTrigger]
				sourceTable[addressAsNumber] = sourceTable[addressAsNumber] or {}

				-- Add the ability trigger name (the table namekey from the json)
				sourceTable[addressAsNumber].name = key

				-- For each ability id, add it to the ability trigger table
				for _, abilityId in pairs(abilityInfo.abilityIds or {}) do
					sourceTable[addressAsNumber][abilityId] = true
				end

				-- Add the ability trigger's scope, if any
				if not Utils.isNilOrEmpty(abilityInfo.scope) then
					sourceTable[addressAsNumber].scope = abilityInfo.scope
				end
			end
		end
	end, FileManager.logError)

	return true
end

---Imports all necessary Tracker Overrides (various hard-coded values) from the a JSON file for the loaded game
---@param filepath? string Optional, a custom JSON file, usually for rom hacks or unsupported game versions
---@return boolean success
function GameSettings.importTrackerOverridesFromJson(filepath)
	filepath = filepath or FileManager.prependDir(FileManager.Files.ADDRESS_OVERRIDES)
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not data then
		return false
	end

	-- Known screens or Tracker global objects that hold addresses and values
	local trackerGlobals = {
		["Program"] = Program,
		["BattleDetailsScreen"] = BattleDetailsScreen,
		["PokemonData"] = PokemonData,
		["MoveData"] = MoveData,
		["AbilityData"] = AbilityData,
	}

	xpcall(function()
		for globalKey, globalInfo in pairs(data or {}) do
			local globalObj = trackerGlobals[globalKey]
			if globalObj then
				-- Screen's Addresses
				for k, v in pairs(globalInfo.Addresses or {}) do
					local value = _decodeAddressFromJson(v)
					if type(value) == "number" then
						globalObj[k] = value
					end
				end
				-- Screen's Values
				for k, v in pairs(globalInfo.Values or {}) do
					local value = _decodeAddressFromJson(v)
					if type(value) == "number" then
						globalObj[k] = value
					end
				end
			end
		end
	end, FileManager.logError)

	return true
end

---Gets the ROM name as defined by the emulator, or an empty string if not found
---@return string
function GameSettings.getRomName()
	if Main.IsOnBizhawk() then
		return gameinfo.getromname() or ""
	elseif emu ~= nil then
		return emu:getGameTitle() or ""
	end
	return ""
end

---Gets the ROM hash as defined by the emulator, or an empty string if not found
---@return string
function GameSettings.getRomHash()
	if Main.IsOnBizhawk() then
		return gameinfo.getromhash() or ""
	else
		---@diagnostic disable-next-line: undefined-global
		return emu:checksum(C.CHECKSUM.CRC32) or ""
	end
end

---Gets the filepath for the Game ROM addresses JSON
---@param softwareVersion? number Optional, if none provided, will read in the softwareVersion from the game via the emulator
---@return string|nil filepath The matching filepath; or `nil` if none found
function GameSettings.getRomAddressesFilePath(softwareVersion)
	softwareVersion = softwareVersion or Utils.reverseEndian32(Memory.read32(GameSettings.RomHeaders.SoftwareVersion))

	local versionName
	for _, gameRomInfo in pairs(GameSettings.RomVersions) do
		if gameRomInfo.softwareVersion == softwareVersion then
			versionName = Utils.replaceText(gameRomInfo.name, "é", "e")
			break
		end
	end
	if not versionName then
		return nil
	end

	local jsonFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.GameAddresses, true)
	local filepath = string.format("%s%s.json", jsonFolder, versionName)

	return filepath
end

---(Deprecated) Returns a filename for storing tracked data;
---@return string filename
function GameSettings.getTrackerAutoSaveName()
	local filenameEnding = FileManager.PostFixes.AUTOSAVE .. FileManager.Extensions.TRACKED_DATA
	-- Remove trailing " (___)" from game name
	return GameSettings.gamename:gsub("%s%(.*%)", " ") .. filenameEnding
end

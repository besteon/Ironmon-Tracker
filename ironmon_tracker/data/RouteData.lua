RouteData = {}

-- key: mapId (mapLayoutId)
-- value: name = ('string'),
--        encounterArea = ('table')
RouteData.Info = {}

RouteData.AvailableRoutes = {}

RouteData.EncounterArea = {
	LAND = "Walking", -- Max 12 possible
	SURFING = "Surfing", -- Max 5 possible
	UNDERWATER = "Underwater", -- Max 5 possible(?)
	STATIC = "Static",
	ROCKSMASH = "RockSmash", -- Max 5 possible
	SUPERROD = "Super Rod", -- Max 10 possible between all rods
	GOODROD = "Good Rod",
	OLDROD = "Old Rod",
	TRAINER = "Trainer", -- Eventually want to show trainer info/teams per area
}

RouteData.OrderedEncounters = {
	RouteData.EncounterArea.LAND,
	RouteData.EncounterArea.SURFING,
	RouteData.EncounterArea.UNDERWATER,
	RouteData.EncounterArea.STATIC,
	RouteData.EncounterArea.ROCKSMASH,
	RouteData.EncounterArea.SUPERROD,
	RouteData.EncounterArea.GOODROD,
	RouteData.EncounterArea.OLDROD,
	RouteData.EncounterArea.TRAINER,
}

-- Used for looking up the gen3 pokedex number (index) based on the Pokemon's national dex number
RouteData.NatDexToIndex = {
	[252] = 277, [253] = 278, [254] = 279, [255] = 280, [256] = 281, [257] = 282, [258] = 283, [259] = 284,
	[260] = 285, [261] = 286, [262] = 287, [263] = 288, [264] = 289, [265] = 290, [266] = 291, [267] = 292, [268] = 293, [269] = 294,
	[270] = 295, [271] = 296, [272] = 297, [273] = 298, [274] = 299, [275] = 300, [276] = 304, [277] = 305, [278] = 309, [279] = 310,
	[280] = 392, [281] = 393, [282] = 394, [283] = 311, [284] = 312, [285] = 306, [286] = 307, [287] = 364, [288] = 365, [289] = 366,
	[290] = 301, [291] = 302, [292] = 303, [293] = 370, [294] = 371, [295] = 372, [296] = 335, [297] = 336, [298] = 350, [299] = 320,
	[300] = 315, [301] = 316, [302] = 322, [303] = 355, [304] = 382, [305] = 383, [306] = 384, [307] = 356, [308] = 357, [309] = 337,
	[310] = 338, [311] = 353, [312] = 354, [313] = 386, [314] = 387, [315] = 363, [316] = 367, [317] = 368, [318] = 330, [319] = 331,
	[320] = 313, [321] = 314, [322] = 339, [323] = 340, [324] = 321, [325] = 351, [326] = 352, [327] = 308, [328] = 332, [329] = 333,
	[330] = 334, [331] = 344, [332] = 345, [333] = 358, [334] = 359, [335] = 380, [336] = 379, [337] = 348, [338] = 349, [339] = 323,
	[340] = 324, [341] = 326, [342] = 327, [343] = 318, [344] = 319, [345] = 388, [346] = 389, [347] = 390, [348] = 391, [349] = 328,
	[350] = 329, [351] = 385, [352] = 317, [353] = 377, [354] = 378, [355] = 361, [356] = 362, [357] = 369, [358] = 411, [359] = 376,
	[360] = 360, [361] = 346, [362] = 347, [363] = 341, [364] = 342, [365] = 343, [366] = 373, [367] = 374, [368] = 375, [369] = 381,
	[370] = 325, [371] = 395, [372] = 396, [373] = 397, [374] = 398, [375] = 399, [376] = 400, [377] = 401, [378] = 402, [379] = 403,
	[380] = 407, [381] = 408, [382] = 404, [383] = 405, [384] = 406, [385] = 409, [386] = 410,
}

-- Maps the rodId from 'gSpecialVar_ItemId' to encounterArea
RouteData.Rods = {
	[262] = RouteData.EncounterArea.OLDROD,
	[263] = RouteData.EncounterArea.GOODROD,
	[264] = RouteData.EncounterArea.SUPERROD,
}

-- Allows the Tracker to verify if data can be updated based on the location of the player
RouteData.Locations = {
	CanPCHeal = {},
	CanObtainBadge = {}, -- Currently unused for the time being
	IsInLab = {},
}

function RouteData.setupRouteInfo(gameId)
	local maxMapId = 0

	if gameId == 1 or gameId == 2 then
		maxMapId = RouteData.setupRouteInfoAsRSE()
	elseif gameId == 3 then
		maxMapId = RouteData.setupRouteInfoAsFRLG()
	end

	RouteData.populateAvailableRoutes(maxMapId)
end

function RouteData.populateAvailableRoutes(maxMapId)
	maxMapId = maxMapId or 0
	RouteData.AvailableRoutes = {}

	if maxMapId <= 0 then return end

	-- Iterate based on mapId order so the list is somewhat organized
	for mapId=1, maxMapId, 1 do
		local route = RouteData.Info[mapId]
		if route ~= nil and route.name ~= nil then
			for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
				if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
					table.insert(RouteData.AvailableRoutes, route.name)
					break
				end
			end
		end
	end
end

function RouteData.hasRoute(mapId)
	return mapId ~= nil and RouteData.Info[mapId] ~= nil and RouteData.Info[mapId] ~= {}
end

function RouteData.hasRouteEncounterArea(mapId, encounterArea)
	if encounterArea == nil or not RouteData.hasRoute(mapId) then return false end

	return RouteData.Info[mapId][encounterArea] ~= nil and RouteData.Info[mapId][encounterArea] ~= {}
end

function RouteData.verifyPID(pokemonID)
	-- Convert from national dex to gen3 dex (applies to ids > 251)
	if RouteData.NatDexToIndex[pokemonID] ~= nil then
		return RouteData.NatDexToIndex[pokemonID]
	else
		return pokemonID
	end
end

function RouteData.countPokemonInArea(mapId, encounterArea)
	local areaInfo = RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	return #areaInfo
end

function RouteData.isFishingEncounter(encounterArea)
	return encounterArea == RouteData.EncounterArea.OLDROD or encounterArea == RouteData.EncounterArea.GOODROD or encounterArea == RouteData.EncounterArea.SUPERROD
end

function RouteData.getEncounterAreaByTerrain(terrainId, battleFlags)
	if terrainId < 0 or terrainId > 19 then return nil end
	battleFlags = battleFlags or 4
	local isSafariEncounter = Utils.getbits(battleFlags, 7, 1) == 1

	-- Check if a special type of encounter has occurred, see list below
	if battleFlags > 4 and not isSafariEncounter then -- 4 (0b100) is the default base value
		local isFirstEncounter = Utils.getbits(battleFlags, 4, 1) == 1
		local staticFlags = bit.rshift(battleFlags, 10) -- untested but probably accurate, likely separate later
		if Utils.getbits(battleFlags, 3, 1) == 1 then
			return RouteData.EncounterArea.TRAINER
		elseif isFirstEncounter and GameSettings.versiongroup == 1 then -- RSE first battle only
			return RouteData.EncounterArea.STATIC
		elseif staticFlags > 0 then
			return RouteData.EncounterArea.STATIC
		else
			return RouteData.EncounterArea.LAND
		end
	else
		if terrainId == 3 then
			return RouteData.EncounterArea.UNDERWATER
		elseif terrainId == 4 or terrainId == 5 then -- Water, Pond
			return RouteData.EncounterArea.SURFING
		else
			return RouteData.EncounterArea.LAND
		end
	end

	-- Terrain Data, saving here to use later for RSE games and maybe boss trainers
	-- BATTLE_TERRAIN_GRASS        0 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_LONG_GRASS   1 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_SAND         2 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_UNDERWATER   3 -- RouteData.EncounterArea.UNDERWATER
	-- BATTLE_TERRAIN_WATER        4 -- RouteData.EncounterArea.SURFING
	-- BATTLE_TERRAIN_POND         5 -- RouteData.EncounterArea.SURFING
	-- BATTLE_TERRAIN_MOUNTAIN     6 -- RouteData.EncounterArea.LAND ???
	-- BATTLE_TERRAIN_CAVE         7 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_BUILDING     8 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_PLAIN        9 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_LINK        10
	-- BATTLE_TERRAIN_GYM         11 -- returns 8 in Koga's gym
	-- BATTLE_TERRAIN_LEADER      12
	-- BATTLE_TERRAIN_INDOOR_2    13
	-- BATTLE_TERRAIN_INDOOR_1    14
	-- BATTLE_TERRAIN_LORELEI     15
	-- BATTLE_TERRAIN_BRUNO       16
	-- BATTLE_TERRAIN_AGATHA      17
	-- BATTLE_TERRAIN_LANCE       18
	-- BATTLE_TERRAIN_CHAMPION    19

	-- Battle Flags
	-- https://github.com/pret/pokefirered/blob/49ea462d7f421e75a76b25d7e85c92494c0a9798/include/constants/battle.h
	-- BATTLE_TYPE_DOUBLE             (1 << 0)
	-- BATTLE_TYPE_LINK               (1 << 1)
	-- BATTLE_TYPE_IS_MASTER          (1 << 2) // In not-link battles, it's always set.
	-- BATTLE_TYPE_TRAINER            (1 << 3)
	-- BATTLE_TYPE_FIRST_BATTLE       (1 << 4)
	-- BATTLE_TYPE_LINK_IN_BATTLE     (1 << 5) // Set on battle entry, cleared on exit. Checked rarely
	-- BATTLE_TYPE_MULTI              (1 << 6)
	-- BATTLE_TYPE_SAFARI             (1 << 7)
	-- BATTLE_TYPE_BATTLE_TOWER       (1 << 8)
	-- BATTLE_TYPE_OLD_MAN_TUTORIAL   (1 << 9) // Used in pokeemerald as BATTLE_TYPE_WALLY_TUTORIAL.
	-- BATTLE_TYPE_ROAMER             (1 << 10)
	-- BATTLE_TYPE_EREADER_TRAINER    (1 << 11)
	-- BATTLE_TYPE_KYOGRE_GROUDON     (1 << 12)
	-- BATTLE_TYPE_LEGENDARY          (1 << 13)
	-- BATTLE_TYPE_GHOST_UNVEILED     (1 << 13) // Re-use of BATTLE_TYPE_LEGENDARY, when combined with BATTLE_TYPE_GHOST
	-- BATTLE_TYPE_REGI               (1 << 14)
	-- BATTLE_TYPE_GHOST              (1 << 15) // Used in pokeemerald as BATTLE_TYPE_TWO_OPPONENTS.
	-- BATTLE_TYPE_POKEDUDE           (1 << 16) // Used in pokeemerald as BATTLE_TYPE_DOME.
	-- BATTLE_TYPE_WILD_SCRIPTED      (1 << 17) // Used in pokeemerald as BATTLE_TYPE_PALACE.
	-- BATTLE_TYPE_LEGENDARY_FRLG     (1 << 18) // Used in pokeemerald as BATTLE_TYPE_ARENA.
	-- BATTLE_TYPE_TRAINER_TOWER      (1 << 19) // Used in pokeemerald as BATTLE_TYPE_FACTORY.
end

function RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, area in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == area then
			startingIndex = index
			break
		end
	end

	local numEncounters = #RouteData.OrderedEncounters
	local nextIndex = (startingIndex % numEncounters) + 1
	while startingIndex ~= nextIndex do
		encounterArea = RouteData.OrderedEncounters[nextIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		nextIndex = (nextIndex % numEncounters) + 1
	end

	return encounterArea
end

function RouteData.getPreviousAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, area in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == area then
			startingIndex = index
			break
		end
	end

	local numEncounters = #RouteData.OrderedEncounters
	-- This fancy formula is due to indices starting at 1, thanks lua
	local previousIndex = ((startingIndex - 2 + numEncounters) % numEncounters) + 1
	while startingIndex ~= previousIndex do
		encounterArea = RouteData.OrderedEncounters[previousIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		previousIndex = ((previousIndex - 2 + numEncounters) % numEncounters) + 1
	end

	return encounterArea
end

-- Returns a table of all pokemon info in an area, where pokemonID is the key, and encounter rate/levels are the values
function RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local pIndex = RouteData.getIndexForGameVersion()
	local areaInfo = {}
	for _, encounter in pairs(RouteData.Info[mapId][encounterArea]) do
		local pokemonID
		if type(encounter.pokemonID) == "number" then
			pokemonID = encounter.pokemonID
		else -- pokemonID = {ID, ID, ID}
			pokemonID = encounter.pokemonID[pIndex]
		end
		pokemonID = RouteData.verifyPID(pokemonID)

		local rate
		if type(encounter.rate) == "number" then
			rate = encounter.rate
		else -- rate = {val, val, val}
			rate = encounter.rate[pIndex]
		end

		-- Some version have fewer Pokemon than others; if so, the ID will be -1
		if PokemonData.isValid(pokemonID) then
			table.insert(areaInfo, {
				pokemonID = pokemonID,
				rate = rate,
				minLv = encounter.minLv,
				maxLv = encounter.maxLv,
			})
		end
	end
	return areaInfo
end

-- Different game versions have different Pokemon appear in an encounterArea: pokemonID = {ID, ID, ID}
function RouteData.getIndexForGameVersion()
	if GameSettings.versioncolor == "LeafGreen" or GameSettings.versioncolor == "Sapphire" then
		return 2
	elseif GameSettings.versioncolor == "Emerald" then
		return 3
	else
		return 1
	end
end

-- Currently unused, as it only pulls randomized data and not vanilla pokemon data
function RouteData.readWildPokemonInfoFromMemory()
	GameSettings.gWildMonHeaders = 0x083c9d28 -- size:00000a64

	local landCount = 12
	local waterCount = 5
	local rockCount = 5
	local fishCount = 10
	local monInfoSize = 5
	local headerInfoSize = 2 + landCount * monInfoSize + waterCount * monInfoSize + rockCount * monInfoSize + fishCount * monInfoSize
	local numHeaders = 5

	local mapNone = 0x7F7F
	local mapUndefined = 0xFFFF
	local landOffset = 0x02
	local waterOffset = landOffset + landCount * monInfoSize
	local rockOffset = waterOffset + waterCount * monInfoSize
	local fishOffset = rockOffset + rockCount * monInfoSize

	-- struct WildPokemonHeader
	-- {
	-- 	u8 mapGroup;
	-- 	u8 mapNum;
	-- 	const struct WildPokemonInfo *landMonsInfo;
	-- 	const struct WildPokemonInfo *waterMonsInfo;
	-- 	const struct WildPokemonInfo *rockSmashMonsInfo;
	-- 	const struct WildPokemonInfo *fishingMonsInfo;
	-- };

	-- struct WildPokemonInfo
	-- {
	-- 	u8 encounterRate;
	-- 	const struct WildPokemon[] {u8 minLevel, u8 maxLevel, u16 species};
	-- };

	local headerInfo = {}
	for headerIndex = 1, numHeaders, 1 do
		local headerStart = GameSettings.gWildMonHeaders + (headerIndex - 1) * headerInfoSize
		local landStart = headerStart + landOffset
		local waterStart = headerStart + waterOffset
		local rockStart = headerStart + rockOffset
		local fishStart = headerStart + fishOffset

		headerInfo[headerIndex] = {
			mapGroup = Memory.readbyte(headerStart + 0x00),
			mapNum = Memory.readbyte(headerStart + 0x01),
		}

		-- print(headerInfo[headerIndex])

		headerInfo[headerIndex].landMonsInfo = {}
		for monIndex = 1, landCount, 1 do
			local monInfoAddress = landStart + (monIndex - 1) * monInfoSize
			headerInfo[headerIndex].landMonsInfo[monIndex] = {
				pokemonID = Memory.readword(monInfoAddress + 0x3),
				rate = Memory.readbyte(monInfoAddress),
				minLv = Memory.readbyte(monInfoAddress + 0x1),
				maxLv = Memory.readbyte(monInfoAddress + 0x2),
			}
			-- print(headerInfo[headerIndex].landMonsInfo[monIndex])
		end

		headerInfo[headerIndex].waterMonsInfo = {}

		headerInfo[headerIndex].rockMonsInfo = {}

		headerInfo[headerIndex].fishMonsInfo = {}

		-- local headerBytes = {}
		-- print("----- HEADER " .. headerIndex .. " -----")
		-- for i=1, headerInfoSize, 1 do
		-- 	local byte = Memory.readbyte(headerStart + i - 1)
		-- 	headerBytes[i] = byte
		-- end
		-- print(headerBytes)
	end
end

-- https://github.com/pret/pokefirered/blob/918ed2d31eeeb036230d0912cc2527b83788bc85/include/constants/layouts.h
-- https://www.serebii.net/pokearth/kanto/3rd/route1.shtml
function RouteData.setupRouteInfoAsFRLG()
	RouteData.Locations.CanPCHeal = {
		[1] = true, -- Mom's house
		[8] = true, -- Most Pokemon Centers
		[212] = true, -- Indigo Plateau
		[271] = true, -- One Island
	}
	RouteData.Locations.CanObtainBadge = {
		[12] = true,
		[15] = true,
		[20] = true,
		[25] = true,
		[28] = true,
		[34] = true,
		[36] = true,
		[37] = true,
	}
	RouteData.Locations.IsInLab = {
		[5] = true,
	}

	RouteData.Info = {
		[1] = { name = "Mom's House", },
		[5] = { name = "Oak's Lab", },
		[8] = { name = Constants.Words.POKEMON .. " Center", },
		[12] = { name = "Cerulean Gym", },
		[15] = { name = "Celadon Gym", },
		[20] = { name = "Fuchsia Gym", },
		[25] = { name = "Vermilion Gym", },
		[27] = { name = "Game Corner", },
		[28] = { name = "Pewter Gym", },
		[34] = { name = "Saffron Gym", },
		[36] = { name = "Cinnabar Gym", },
		[37] = { name = "Viridian Gym", },
		[78] = { name = "Pallet Town",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[79] = { name = "Viridian City",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[80] = { name = "Pewter City", },
		[81] = { name = "Cerulean City",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[82] = { name = "Lavender Town", },
		[83] = { name = "Vermilion City",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {98,116}, rate = 0.04, minLv = 25, maxLv = 30, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[84] = { name = "Celadon City",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 0.99, minLv = 5, maxLv = 40, },
				{ pokemonID = 109, rate = 0.01, minLv = 30, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 129, rate = 0.99, minLv = 15, maxLv = 35, },
				{ pokemonID = 88, rate = 0.01, minLv = 30, maxLv = 40, },
			},
		},
		[85] = { name = "Fuchsia City",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[86] = { name = "Cinnabar Island",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[87] = { name = "Indigo Plateau", },
		[88] = { name = "Saffron City Conn.", },
		[89] = { name = "Route 1",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.50, minLv = 2, maxLv = 5, },
				{ pokemonID = 19, rate = 0.50, minLv = 2, maxLv = 4, },
			},
		},
		[90] = { name = "Route 2",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 19, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 10, rate = 0.05, minLv = 4, maxLv = 5, },
				{ pokemonID = 13, rate = 0.05, minLv = 4, maxLv = 5, },
			},
		},
		[91] = { name = "Route 3",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 21, rate = 0.35, minLv = 6, maxLv = 8, },
				{ pokemonID = 16, rate = 0.30, minLv = 6, maxLv = 7, },
				{ pokemonID = {32,29}, rate = 0.14, minLv = 6, maxLv = 7, },
				{ pokemonID = 39, rate = 0.10, minLv = 3, maxLv = 7, },
				{ pokemonID = 56, rate = 0.10, minLv = 7, maxLv = 7, },
				{ pokemonID = {29,32}, rate = 0.01, minLv = 6, maxLv = 6, },
			},
		},
		[92] = { name = "Route 4",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 19, rate = 0.35, minLv = 8, maxLv = 12, },
				{ pokemonID = 21, rate = 0.35, minLv = 8, maxLv = 12, },
				{ pokemonID = 23, rate = 0.25, minLv = 6, maxLv = 12, },
				{ pokemonID = 56, rate = 0.05, minLv = 10, maxLv = 12, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[93] = { name = "Route 5",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.40, minLv = 13, maxLv = 16, },
				{ pokemonID = 52, rate = 0.35, minLv = 10, maxLv = 16, },
				{ pokemonID = {43,69}, rate = 0.25, minLv = 13, maxLv = 16, },
			},
		},
		[94] = { name = "Route 6",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.40, minLv = 13, maxLv = 16, },
				{ pokemonID = 52, rate = 0.35, minLv = 10, maxLv = 16, },
				{ pokemonID = {43,69}, rate = 0.25, minLv = 13, maxLv = 16, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[95] = { name = "Route 7",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 52, rate = 0.40, minLv = 17, maxLv = 20, },
				{ pokemonID = 16, rate = 0.30, minLv = 19, maxLv = 22, },
				{ pokemonID = {43,69}, rate = 0.20, minLv = 19, maxLv = 22, },
				{ pokemonID = {58,37}, rate = 0.10, minLv = 18, maxLv = 20, },
			},
		},
		[96] = { name = "Route 8",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.30, minLv = 18, maxLv = 20, },
				{ pokemonID = 52, rate = 0.30, minLv = 18, maxLv = 20, },
				{ pokemonID = {23,27}, rate = 0.20, minLv = 17, maxLv = 19, },
				{ pokemonID = {58,37}, rate = 0.20, minLv = 15, maxLv = 18, },
			},
		},
		[97] = { name = "Route 9",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 19, rate = 0.40, minLv = 14, maxLv = 17, },
				{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
				{ pokemonID = {23,27}, rate = 0.25, minLv = 11, maxLv = 17, },
			},
		},
		[98] = { name = "Route 10",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 100, rate = 0.40, minLv = 14, maxLv = 17, },
				{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
				{ pokemonID = {23,27}, rate = 0.25, minLv = 11, maxLv = 17, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[99] = { name = "Route 11",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {23,27}, rate = 0.40, minLv = 12, maxLv = 15, },
				{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
				{ pokemonID = 96, rate = 0.25, minLv = 11, maxLv = 15, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[100] = { name = "Route 12",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 16, rate = 0.30, minLv = 23, maxLv = 27, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 143, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[101] = { name = "Route 13",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 16, rate = 0.20, minLv = 25, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
				{ pokemonID = 132, rate = 0.05, minLv = 25, maxLv = 25, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[102] = { name = "Route 14",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 132, rate = 0.15, minLv = 23, maxLv = 23, },
				{ pokemonID = 16, rate = 0.10, minLv = 27, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[103] = { name = "Route 15",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 16, rate = 0.20, minLv = 25, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
				{ pokemonID = 132, rate = 0.05, minLv = 25, maxLv = 25, },
			},
		},
		[104] = { name = "Route 16",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 84, rate = 0.35, minLv = 18, maxLv = 22, },
				{ pokemonID = 19, rate = 0.30, minLv = 18, maxLv = 22, },
				{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
				{ pokemonID = 20, rate = 0.05, minLv = 23, maxLv = 25, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 143, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[105] = { name = "Route 17",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
				{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
				{ pokemonID = 20, rate = 0.30, minLv = 25, maxLv = 29, },
				{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
				{ pokemonID = 22, rate = 0.05, minLv = 25, maxLv = 27, },
			},
		},
		[106] = { name = "Route 18",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
				{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
				{ pokemonID = 20, rate = 0.15, minLv = 25, maxLv = 29, },
				{ pokemonID = 22, rate = 0.15, minLv = 25, maxLv = 29, },
				{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[107] = { name = "Route 19",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[108] = { name = "Route 20",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[109] = { name = "Route 21 North",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 114, rate = 1.00, minLv = 17, maxLv = 28, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[110] = { name = "Route 22",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 19, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 56, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 21, rate = 0.10, minLv = 3, maxLv = 5, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[111] = { name = "Route 23",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 56, rate = 0.30, minLv = 32, maxLv = 34, },
				{ pokemonID = 22, rate = 0.25, minLv = 40, maxLv = 44, },
				{ pokemonID = {23,27}, rate = 0.20, minLv = 32, maxLv = 34, },
				{ pokemonID = 21, rate = 0.15, minLv = 32, maxLv = 34, },
				{ pokemonID = {24,28}, rate = 0.05, minLv = 44, maxLv = 44, },
				{ pokemonID = 57, rate = 0.05, minLv = 42, maxLv = 42, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[112] = { name = "Route 24",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.25, minLv = 12, maxLv = 14, },
				{ pokemonID = 10, rate = 0.20, minLv = 7, maxLv = 7, },
				{ pokemonID = 13, rate = 0.20, minLv = 7, maxLv = 7, },
				{ pokemonID = 16, rate = 0.15, minLv = 11, maxLv = 13, },
				{ pokemonID = 63, rate = 0.15, minLv = 8, maxLv = 12, },
				{ pokemonID = {14,11}, rate = 0.04, minLv = 8, maxLv = 8, },
				{ pokemonID = {11,14}, rate = 0.01, minLv = 8, maxLv = 8, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[113] = { name = "Route 25",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.25, minLv = 12, maxLv = 14, },
				{ pokemonID = 10, rate = 0.20, minLv = 8, maxLv = 8, },
				{ pokemonID = 13, rate = 0.20, minLv = 8, maxLv = 8, },
				{ pokemonID = 16, rate = 0.15, minLv = 11, maxLv = 13, },
				{ pokemonID = 63, rate = 0.15, minLv = 9, maxLv = 12, },
				{ pokemonID = {14,11}, rate = 0.04, minLv = 9, maxLv = 9, },
				{ pokemonID = {11,14}, rate = 0.01, minLv = 9, maxLv = 9, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[114] = { name = "Mt. Moon 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.69, minLv = 7, maxLv = 10, },
				{ pokemonID = 74, rate = 0.25, minLv = 7, maxLv = 9, },
				{ pokemonID = 46, rate = 0.05, minLv = 8, maxLv = 8, },
				{ pokemonID = 35, rate = 0.01, minLv = 8, maxLv = 8, },
			},
		},
		[115] = { name = "Mt. Moon B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 46, rate = 1.00, minLv = 5, maxLv = 10, },
			},
		},
		[116] = { name = "Mt. Moon B2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.49, minLv = 8, maxLv = 11, },
				{ pokemonID = 74, rate = 0.30, minLv = 9, maxLv = 10, },
				{ pokemonID = 46, rate = 0.15, minLv = 10, maxLv = 12, },
				{ pokemonID = 35, rate = 0.06, minLv = 10, maxLv = 12, },
			},
		},
		[117] = { name = "Viridian Forest",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 10, rate = 0.40, minLv = 3, maxLv = 5, },
				{ pokemonID = 13, rate = 0.40, minLv = 3, maxLv = 5, },
				{ pokemonID = {14,11}, rate = 0.10, minLv = 4, maxLv = 6, },
				{ pokemonID = {11,14}, rate = 0.05, minLv = 5, maxLv = 5, },
				{ pokemonID = 25, rate = 0.05, minLv = 3, maxLv = 5, },
			},
		},
		[120] = { name = "S.S. Anne 2F", }, -- 2F corridor (Rival Fight)
		[123] = { name = "S.S. Anne Deck", },
		[124] = { name = "Diglett's Cave B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 50, rate = 0.95, minLv = 15, maxLv = 22, },
				{ pokemonID = 51, rate = 0.05, minLv = 29, maxLv = 31, },
			},
		},
		[125] = { name = "Victory Road 1F",
			[RouteData.EncounterArea.LAND] = {
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
		[126] = { name = "Victory Road 2F",
			[RouteData.EncounterArea.LAND] = {
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
		[127] = { name = "Victory Road 3F",
			[RouteData.EncounterArea.LAND] = {
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
		[128] = { name = "Rocket Hideout B1F", },
		[129] = { name = "Rocket Hideout B2F", },
		[130] = { name = "Rocket Hideout B3F", },
		[131] = { name = "Rocket Hideout B4F", },
		[132] = { name = "Silph Co. 1F", },
		[133] = { name = "Silph Co. 2F", },
		[134] = { name = "Silph Co. 3F", },
		[135] = { name = "Silph Co. 4F", },
		[136] = { name = "Silph Co. 5F", },
		[137] = { name = "Silph Co. 6F", },
		[138] = { name = "Silph Co. 7F", },
		[139] = { name = "Silph Co. 8F", },
		[140] = { name = "Silph Co. 9F", },
		[141] = { name = "Silph Co. 10F", },
		[142] = { name = "Silph Co. 11F", },
		[143] = { name = Constants.Words.POKE .. "-- Mansion 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[144] = { name = Constants.Words.POKE .. "-- Mansion 2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[145] = { name = Constants.Words.POKE .. "-- Mansion 3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[146] = { name = Constants.Words.POKE .. "-- Mansion B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 34, maxLv = 38, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = 132, rate = 0.10, minLv = 30, maxLv = 30, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = 19, rate = 0.05, minLv = 26, maxLv = 26, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 34, maxLv = 34, },
			},
		},
		[147] = { name = "Safari Zone Center",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {32, 29}, rate = 0.20, minLv = 22, maxLv = 22, },
				{ pokemonID = 102, rate = 0.20, minLv = 24, maxLv = 25, },
				{ pokemonID = 111, rate = 0.20, minLv = 25, maxLv = 25, },
				{ pokemonID = 48, rate = 0.15, minLv = 22, maxLv = 22, },
				{ pokemonID = {33, 30}, rate = 0.10, minLv = 31, maxLv = 31, },
				{ pokemonID = {30, 33}, rate = 0.05, minLv = 31, maxLv = 31, },
				{ pokemonID = 47, rate = 0.05, minLv = 30, maxLv = 30, },
				{ pokemonID = {123, 127}, rate = 0.04, minLv = 23, maxLv = 23, },
				{ pokemonID = 113, rate = 0.01, minLv = 23, maxLv = 23, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54, 79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 118, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 60, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 147, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54, 79}, rate = 0.04, minLv = 15, maxLv = 35, },
				{ pokemonID = 148, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[148] = { name = "Safari Zone East",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {32, 29}, rate = 0.20, minLv = 24, maxLv = 24, },
				{ pokemonID = 84, rate = 0.20, minLv = 24, maxLv = 25, },
				{ pokemonID = 102, rate = 0.20, minLv = 23, maxLv = 25, },
				{ pokemonID = 46, rate = 0.15, minLv = 22, maxLv = 22, },
				{ pokemonID = {33, 30}, rate = 0.10, minLv = 33, maxLv = 33, },
				{ pokemonID = {29, 32}, rate = 0.05, minLv = 24, maxLv = 24, },
				{ pokemonID = 47, rate = 0.05, minLv = 25, maxLv = 25, },
				{ pokemonID = 115, rate = 0.04, minLv = 25, maxLv = 25, },
				{ pokemonID = {123, 127}, rate = 0.01, minLv = 28, maxLv = 28, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54, 79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 118, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 60, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 147, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54, 79}, rate = 0.04, minLv = 15, maxLv = 35, },
				{ pokemonID = 148, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[149] = { name = "Safari Zone North",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {32, 29}, rate = 0.20, minLv = 30, maxLv = 30, },
				{ pokemonID = 102, rate = 0.20, minLv = 25, maxLv = 27, },
				{ pokemonID = 111, rate = 0.20, minLv = 26, maxLv = 26, },
				{ pokemonID = 46, rate = 0.15, minLv = 23, maxLv = 23, },
				{ pokemonID = {33, 30}, rate = 0.10, minLv = 30, maxLv = 30, },
				{ pokemonID = {30, 33}, rate = 0.05, minLv = 30, maxLv = 30, },
				{ pokemonID = 49, rate = 0.05, minLv = 32, maxLv = 32, },
				{ pokemonID = 113, rate = 0.04, minLv = 26, maxLv = 26, },
				{ pokemonID = 128, rate = 0.01, minLv = 28, maxLv = 28, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54, 79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 118, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 60, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 147, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54, 79}, rate = 0.04, minLv = 15, maxLv = 35, },
				{ pokemonID = 148, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[150] = { name = "Safari Zone West",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {32, 29}, rate = 0.20, minLv = 22, maxLv = 22, },
				{ pokemonID = 84, rate = 0.20, minLv = 26, maxLv = 26, },
				{ pokemonID = 102, rate = 0.20, minLv = 25, maxLv = 27, },
				{ pokemonID = 48, rate = 0.15, minLv = 23, maxLv = 23, },
				{ pokemonID = {33, 30}, rate = 0.10, minLv = 30, maxLv = 30, },
				{ pokemonID = {29, 32}, rate = 0.05, minLv = 30, maxLv = 30, },
				{ pokemonID = 49, rate = 0.05, minLv = 32, maxLv = 32, },
				{ pokemonID = 128, rate = 0.04, minLv = 25, maxLv = 25, },
				{ pokemonID = 115, rate = 0.01, minLv = 28, maxLv = 28, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54, 79}, rate = 1.00, minLv = 20, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 118, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 60, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 147, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54, 79}, rate = 0.04, minLv = 15, maxLv = 35, },
				{ pokemonID = 148, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[151] = { name = "Cerulean Cave 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 47, rate = 0.25, minLv = 49, maxLv = 58, },
				{ pokemonID = 82, rate = 0.20, minLv = 49, maxLv = 49, },
				{ pokemonID = 42, rate = 0.14, minLv = 46, maxLv = 55, },
				{ pokemonID = 57, rate = 0.11, minLv = 52, maxLv = 61, },
				{ pokemonID = 132, rate = 0.11, minLv = 52, maxLv = 61, },
				{ pokemonID = 67, rate = 0.10, minLv = 46, maxLv = 46, },
				{ pokemonID = 101, rate = 0.05, minLv = 58, maxLv = 58, },
				{ pokemonID = 202, rate = 0.04, minLv = 55, maxLv = 55, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 0.65, minLv = 30, maxLv = 50, },
				{ pokemonID = {55,80}, rate = 0.35, minLv = 40, maxLv = 55, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 30, maxLv = 50, },
				{ pokemonID = 75, rate = 0.35, minLv = 40, maxLv = 55, },
			},
		},
		[152] = { name = "Cerulean Cave 2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 42, rate = 0.25, minLv = 49, maxLv = 58, },
				{ pokemonID = 67, rate = 0.20, minLv = 49, maxLv = 49, },
				{ pokemonID = 47, rate = 0.14, minLv = 52, maxLv = 61, },
				{ pokemonID = 64, rate = 0.11, minLv = 55, maxLv = 64, },
				{ pokemonID = 132, rate = 0.11, minLv = 55, maxLv = 64, },
				{ pokemonID = 82, rate = 0.10, minLv = 52, maxLv = 52, },
				{ pokemonID = 202, rate = 0.05, minLv = 58, maxLv = 58, },
				{ pokemonID = 101, rate = 0.04, minLv = 61, maxLv = 61, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 30, maxLv = 50, },
				{ pokemonID = 75, rate = 0.35, minLv = 40, maxLv = 55, },
			},
		},
		[153] = { name = "Cerulean Cave B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 64, rate = 0.25, minLv = 58, maxLv = 67, },
				{ pokemonID = 132, rate = 0.25, minLv = 58, maxLv = 67, },
				{ pokemonID = 47, rate = 0.14, minLv = 55, maxLv = 64, },
				{ pokemonID = 42, rate = 0.11, minLv = 52, maxLv = 61, },
				{ pokemonID = 67, rate = 0.10, minLv = 52, maxLv = 52, },
				{ pokemonID = 82, rate = 0.10, minLv = 55, maxLv = 55, },
				{ pokemonID = 101, rate = 0.04, minLv = 64, maxLv = 64, },
				{ pokemonID = 202, rate = 0.01, minLv = 61, maxLv = 61, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 0.65, minLv = 30, maxLv = 50, },
				{ pokemonID = {55,80}, rate = 0.35, minLv = 40, maxLv = 55, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 30, maxLv = 50, },
				{ pokemonID = 75, rate = 0.35, minLv = 40, maxLv = 55, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 150, rate = 1.00, minLv = 70, maxLv = 70, },
			},
		},
		[154] = { name = "Rock Tunnel 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.35, minLv = 15, maxLv = 17, },
				{ pokemonID = 41, rate = 0.30, minLv = 15, maxLv = 16, },
				{ pokemonID = 56, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 66, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 95, rate = 0.05, minLv = 13, maxLv = 15, },
			},
		},
		[155] = { name = "Rock Tunnel B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.35, minLv = 15, maxLv = 17, },
				{ pokemonID = 41, rate = 0.30, minLv = 15, maxLv = 16, },
				{ pokemonID = 56, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 66, rate = 0.10, minLv = 17, maxLv = 17, },
				{ pokemonID = 95, rate = 0.10, minLv = 13, maxLv = 17, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.95, minLv = 5, maxLv = 30, },
				{ pokemonID = 75, rate = 0.05, minLv = 25, maxLv = 40, },
			},
		},
		[156] = { name = "Seafoam Islands 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {54,79}, rate = 0.55, minLv = 26, maxLv = 33, },
				{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
				{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
			},
		},
		[157] = { name = "Seafoam Islands B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {54,79}, rate = 0.40, minLv = 29, maxLv = 31, },
				{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
				{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
				{ pokemonID = 86, rate = 0.10, minLv = 28, maxLv = 28, },
				{ pokemonID = {55,80}, rate = 0.05, minLv = 33, maxLv = 35, },
			},
		},
		[158] = { name = "Seafoam Islands B2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {54,79}, rate = 0.40, minLv = 30, maxLv = 32, },
				{ pokemonID = 41, rate = 0.20, minLv = 22, maxLv = 24, },
				{ pokemonID = 86, rate = 0.20, minLv = 30, maxLv = 32, },
				{ pokemonID = 42, rate = 0.10, minLv = 26, maxLv = 30, },
				{ pokemonID = {55,80}, rate = 0.10, minLv = 32, maxLv = 34, },
			},
		},
		[159] = { name = "Seafoam Islands B3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 86, rate = 0.40, minLv = 30, maxLv = 32, },
				{ pokemonID = {54,79}, rate = 0.20, minLv = 30, maxLv = 32, },
				{ pokemonID = {55,80}, rate = 0.15, minLv = 32, maxLv = 34, },
				{ pokemonID = 41, rate = 0.10, minLv = 24, maxLv = 24, },
				{ pokemonID = 42, rate = 0.10, minLv = 26, maxLv = 30, },
				{ pokemonID = 87, rate = 0.05, minLv = 32, maxLv = 34, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 86, rate = 0.60, minLv = 25, maxLv = 35, },
				{ pokemonID = {116,98}, rate = 0.30, minLv = 25, maxLv = 30, },
				{ pokemonID = 87, rate = 0.05, minLv = 35, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.04, minLv = 30, maxLv = 40, },
				{ pokemonID = {55,80}, rate = 0.01, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 30, },
				{ pokemonID = 130, rate = 0.16, minLv = 15, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.04, minLv = 15, maxLv = 25, },
			},
		},
		[160] = { name = "Seafoam Islands B4F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 86, rate = 0.50, minLv = 30, maxLv = 34, },
				{ pokemonID = 42, rate = 0.15, minLv = 26, maxLv = 30, },
				{ pokemonID = {55,80}, rate = 0.15, minLv = 32, maxLv = 34, },
				{ pokemonID = {54,79}, rate = 0.10, minLv = 32, maxLv = 32, },
				{ pokemonID = 87, rate = 0.10, minLv = 34, maxLv = 36, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 86, rate = 0.60, minLv = 25, maxLv = 35, },
				{ pokemonID = {116,98}, rate = 0.30, minLv = 25, maxLv = 30, },
				{ pokemonID = 87, rate = 0.05, minLv = 35, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.04, minLv = 30, maxLv = 40, },
				{ pokemonID = {55,80}, rate = 0.01, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 30, },
				{ pokemonID = 130, rate = 0.16, minLv = 15, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.04, minLv = 15, maxLv = 25, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 144, rate = 1.00, minLv = 50, maxLv = 50, },
			},
		},
		[161] = { name = Constants.Words.POKEMON .. " Tower 1F", },
		[162] = { name = Constants.Words.POKEMON .. " Tower 2F", },
		[163] = { name = Constants.Words.POKEMON .. " Tower 3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.90, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.01, minLv = 20, maxLv = 20, },
			},
		},
		[164] = { name = Constants.Words.POKEMON .. " Tower 4F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
			},
		},
		[165] = { name = Constants.Words.POKEMON .. " Tower 5F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
			},
		},
		[166] = { name = Constants.Words.POKEMON .. " Tower 6F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.85, minLv = 17, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 17, maxLv = 19, },
				{ pokemonID = 93, rate = 0.06, minLv = 21, maxLv = 23, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 105, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[167] = { name = Constants.Words.POKEMON .. " Tower 7F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.75, minLv = 15, maxLv = 19, },
				{ pokemonID = 93, rate = 0.15, minLv = 23, maxLv = 25, },
				{ pokemonID = 104, rate = 0.10, minLv = 17, maxLv = 19, },
			},
		},
		[168] = { name = "Power Plant",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 81, rate = 0.30, minLv = 22, maxLv = 25, },
				{ pokemonID = 100, rate = 0.30, minLv = 22, maxLv = 25, },
				{ pokemonID = 25, rate = 0.25, minLv = 22, maxLv = 26, },
				{ pokemonID = {82,82}, rate = {0.10,0.15}, minLv = 31, maxLv = 34, },
				{ pokemonID = {125,-1}, rate = 0.05, minLv = 32, maxLv = 35, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 101, rate = 1.00, minLv = 34, maxLv = 34, },
				{ pokemonID = 145, rate = 1.00, minLv = 50, maxLv = 50, },
			},
		},
		[177] = { name = "S.S. Anne Rooms", },
		[178] = { name = "S.S. Anne Rooms", },
		[212] = { name = "Indigo Plateau PC", },
		[213] = { name = "Lorelei's Room", },
		[214] = { name = "Bruno's Room", },
		[215] = { name = "Agatha's Room", },
		[216] = { name = "Lance's Room", },
		[217] = { name = "Champion's Room", },
		[219] = { name = "Route 21 South",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 1.00, minLv = 5, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = {98,116}, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.84, minLv = 15, maxLv = 35, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[228] = { name = "Saffron City Dojo", },
		-- [[Sevii Isles]]
		[230] = { name = "One Island",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[232] = { name = "Three Island", }, -- Only trainers here
		[233] = { name = "Four Island",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {194,183}, rate = 0.70, minLv = 5, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.30, minLv = 5, maxLv = 35, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[234] = { name = "Five Island",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.65, minLv = 5, maxLv = 40, },
				{ pokemonID = 187, rate = 0.30, minLv = 5, maxLv = 15, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[237] = { name = "Kindle Road",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 77, rate = 0.30, minLv = 31, maxLv = 34, },
				{ pokemonID = 21, rate = 0.25, minLv = 30, maxLv = 32, },
				{ pokemonID = 22, rate = 0.10, minLv = 36, maxLv = 36, },
				{ pokemonID = 52, rate = 0.10, minLv = 31, maxLv = 31, },
				{ pokemonID = 74, rate = 0.10, minLv = 31, maxLv = 31, },
				{ pokemonID = 53, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = 78, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 34, maxLv = 34, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.95, minLv = 5, maxLv = 30, },
				{ pokemonID = 75, rate = 0.05, minLv = 25, maxLv = 40, },
			},
		},
		[238] = { name = "Treasure Beach",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 21, rate = 0.30, minLv = 31, maxLv = 31, },
				{ pokemonID = 114, rate = 0.30, minLv = 33, maxLv = 35, },
				{ pokemonID = 22, rate = 0.20, minLv = 36, maxLv = 40, },
				{ pokemonID = 52, rate = 0.10, minLv = 31, maxLv = 31, },
				{ pokemonID = 53, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 31, maxLv = 31, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[239] = { name = "Cape Brink",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.30, minLv = 30, maxLv = 32, },
				{ pokemonID = 21, rate = 0.20, minLv = 31, maxLv = 31, },
				{ pokemonID = {44,70}, rate = 0.15, minLv = 36, maxLv = 38, },
				{ pokemonID = 22, rate = 0.10, minLv = 36, maxLv = 36, },
				{ pokemonID = 52, rate = 0.10, minLv = 31, maxLv = 31, },
				{ pokemonID = 53, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 31, maxLv = 31, },
				{ pokemonID = {55,80}, rate = 0.05, minLv = 37, maxLv = 40, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = {55,80}, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[240] = { name = "Bond Bridge", -- 007, license to kill your sub-500BST survival run
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.30, minLv = 29, maxLv = 32, },
				{ pokemonID = {43,69}, rate = 0.20, minLv = 31, maxLv = 31, },
				{ pokemonID = 17, rate = 0.15, minLv = 34, maxLv = 40, },
				{ pokemonID = {44,70}, rate = 0.10, minLv = 36, maxLv = 36, },
				{ pokemonID = 52, rate = 0.10, minLv = 31, maxLv = 31, },
				{ pokemonID = 48, rate = 0.05, minLv = 34, maxLv = 34, },
				{ pokemonID = 53, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 31, maxLv = 31, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = nil, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[241] = { name = "Three Isle Port",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 206, rate = 1.00, minLv = 5, maxLv = 35, },
			},
		},
		[246] = { name = "Resort Gorgeous",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.65, minLv = 5, maxLv = 40, },
				{ pokemonID = 187, rate = 0.30, minLv = 5, maxLv = 15, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[247] = { name = "Water Labyrinth",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.65, minLv = 5, maxLv = 40, },
				{ pokemonID = 187, rate = 0.30, minLv = 5, maxLv = 15, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[248] = { name = "Five Isle Meadow",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 161, rate = 0.30, minLv = 10, maxLv = 15, },
				{ pokemonID = 16, rate = 0.20, minLv = 44, maxLv = 44, },
				{ pokemonID = 17, rate = 0.15, minLv = 48, maxLv = 50, },
				{ pokemonID = 187, rate = 0.15, minLv = 10, maxLv = 15, },
				{ pokemonID = 52, rate = 0.10, minLv = 41, maxLv = 41, },
				{ pokemonID = 53, rate = 0.05, minLv = 47, maxLv = 50, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 41, maxLv = 41, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.65, minLv = 5, maxLv = 40, },
				{ pokemonID = 187, rate = 0.30, minLv = 5, maxLv = 15, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[249] = { name = "Memorial Pillar",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 187, rate = 1.00, minLv = 6, maxLv = 16, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.65, minLv = 5, maxLv = 40, },
				{ pokemonID = 187, rate = 0.30, minLv = 5, maxLv = 15, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[250] = { name = "Outcast Island",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[251] = { name = "Green Path",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[252] = { name = "Water Path",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 161, rate = 0.30, minLv = 10, maxLv = 15, },
				{ pokemonID = 21, rate = 0.20, minLv = 44, maxLv = 44, },
				{ pokemonID = 22, rate = 0.15, minLv = 48, maxLv = 50, },
				{ pokemonID = {43,69}, rate = 0.10, minLv = 44, maxLv = 44, },
				{ pokemonID = 52, rate = 0.10, minLv = 41, maxLv = 41, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 48, maxLv = 48, },
				{ pokemonID = 53, rate = 0.05, minLv = 47, maxLv = 50, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 41, maxLv = 41, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[253] = { name = "Ruin Valley",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 177, rate = 0.25, minLv = 15, maxLv = 20, },
				{ pokemonID = 21, rate = 0.20, minLv = 44, maxLv = 44, },
				{ pokemonID = 22, rate = 0.10, minLv = 49, maxLv = 49, },
				{ pokemonID = 52, rate = 0.10, minLv = 43, maxLv = 43, },
				{ pokemonID = 193, rate = 0.10, minLv = 18, maxLv = 18, },
				{ pokemonID = {194,183}, rate = 0.10, minLv = 15, maxLv = 15, },
				{ pokemonID = 53, rate = 0.05, minLv = 49, maxLv = 52, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 41, maxLv = 41, },
				{ pokemonID = 202, rate = 0.05, minLv = 25, maxLv = 25, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {194,183}, rate = 1.00, minLv = 5, maxLv = 25, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[254] = { name = "Trainer Tower",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[255] = { name = "Canyon Entrance",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 161, rate = 0.30, minLv = 10, maxLv = 15, },
				{ pokemonID = 21, rate = 0.20, minLv = 44, maxLv = 44, },
				{ pokemonID = 22, rate = 0.15, minLv = 48, maxLv = 50, },
				{ pokemonID = 231, rate = 0.15, minLv = 10, maxLv = 15, },
				{ pokemonID = 52, rate = 0.10, minLv = 41, maxLv = 41, },
				{ pokemonID = 53, rate = 0.05, minLv = 47, maxLv = 50, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 41, maxLv = 41, },
			},
		},
		[256] = { name = "Sevault Canyon",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.20, minLv = 46, maxLv = 46, },
				{ pokemonID = 231, rate = 0.20, minLv = 20, maxLv = 20, },
				{ pokemonID = 22, rate = {0.10, 0.15}, minLv = 50, maxLv = 50, },
				{ pokemonID = 52, rate = 0.10, minLv = 43, maxLv = 43, },
				{ pokemonID = 104, rate = 0.10, minLv = 46, maxLv = 46, },
				{ pokemonID = 105, rate = 0.10, minLv = 52, maxLv = 52, },
				{ pokemonID = 53, rate = 0.05, minLv = 49, maxLv = 52, },
				{ pokemonID = 95, rate = 0.05, minLv = 54, maxLv = 54, },
				{ pokemonID = {227,-1}, rate = 0.05, minLv = 30, maxLv = 30, },
				{ pokemonID = 246, rate = 0.05, minLv = 15, maxLv = 20, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[257] = { name = "Tanoby Ruins",
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = {0.95, 0.90}, minLv = 5, maxLv = 40, },
				{ pokemonID = 73, rate = 0.05, minLv = 35, maxLv = 40, },
				{ pokemonID = {-1,226}, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {211,223}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[270] = { name = "Berry Forest",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 17, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = {44,70}, rate = 0.20, minLv = 35, maxLv = 35, },
				{ pokemonID = 16, rate = 0.10, minLv = 32, maxLv = 32, },
				{ pokemonID = {43,69}, rate = 0.10, minLv = 30, maxLv = 30, },
				{ pokemonID = 48, rate = 0.10, minLv = 34, maxLv = 34, },
				{ pokemonID = 96, rate = 0.10, minLv = 34, maxLv = 34, },
				{ pokemonID = 49, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 31, maxLv = 31, },
				{ pokemonID = 97, rate = 0.05, minLv = 37, maxLv = 40, },
				{ pokemonID = 102, rate = 0.05, minLv = 35, maxLv = 35, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = {54,79}, rate = 0.95, minLv = 5, maxLv = 40, },
				{ pokemonID = {55,80}, rate = 0.05, minLv = 35, maxLv = 40, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 118, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 60, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 118, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 119, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		-- [[Start]] One Island: Mt. Ember
		-- Serebii's Pokéarth is pretty wrong about this place for some reason, basing off bulbapedia instead which is mostly more accurate
		-- https://bulbapedia.bulbagarden.net/wiki/Mt._Ember#Pok.C3.A9mon
		[271] = { name = "One Island PC", },
		[280] = { name = "Mt. Ember Base",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 77, rate = 0.35, minLv = 30, maxLv = 36, },
				{ pokemonID = 22, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 21, rate = {0.15, 0.10}, minLv = 30, maxLv = 32, },
				{ pokemonID = 66, rate = 0.10, minLv = 35, maxLv = 35, },
				{ pokemonID = 74, rate = 0.10, minLv = 33, maxLv = 33, },
				{ pokemonID = 78, rate = 0.05, minLv = 39, maxLv = 42, },
				{ pokemonID = {-1,126}, rate = 0.05, minLv = 38, maxLv = 40, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.95, minLv = 5, maxLv = 30, },
				{ pokemonID = 75, rate = 0.05, minLv = 25, maxLv = 40, },
			},
		},
		[281] = { name = "Mt. Ember Summit",
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 146, rate = 1.00, minLv = 50, maxLv = 50, },
			},
		},
		[282] = { name = "Summit Path 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 66, rate = 0.50, minLv = 31, maxLv = 39, },
				{ pokemonID = 74, rate = 0.50, minLv = 29, maxLv = 37, },
			},
		},
		[283] = { name = "Summit Path 2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 66, rate = 0.40, minLv = 32, maxLv = 36, },
				{ pokemonID = 74, rate = 0.40, minLv = 30, maxLv = 34, },
				{ pokemonID = 67, rate = 0.20, minLv = 38, maxLv = 40, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.95, minLv = 5, maxLv = 30, },
				{ pokemonID = 75, rate = 0.05, minLv = 25, maxLv = 40, },
			},
		},
		[284] = { name = "Summit Path 3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 66, rate = 0.50, minLv = 31, maxLv = 39, },
				{ pokemonID = 74, rate = 0.50, minLv = 29, maxLv = 37, },
			},
		},
		[285] = { name = "Ruby Path 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.50, minLv = 32, maxLv = 40, },
				{ pokemonID = 66, rate = 0.40, minLv = 34, maxLv = 38, },
				{ pokemonID = 67, rate = 0.10, minLv = 40, maxLv = 42, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[286] = { name = "Ruby Path B1F- a",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.70, minLv = 34, maxLv = 42, },
				{ pokemonID = 218, rate = 0.30, minLv = 24, maxLv = 30, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[287] = { name = "Ruby Path B2F- a",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 218, rate = 0.60, minLv = 22, maxLv = 32, },
				{ pokemonID = 74, rate = 0.40, minLv = 40, maxLv = 44, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[288] = { name = "Ruby Path B3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 218, rate = 1.00, minLv = 18, maxLv = 36, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 218, rate = 0.90, minLv = 15, maxLv = 35, },
				{ pokemonID = 219, rate = 0.10, minLv = 25, maxLv = 45, },
			},
		},
		-- These two are the tiny rooms on the quick way back from B5F
		[289] = { name = "Ruby Path B1F- b",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.70, minLv = 34, maxLv = 42, },
				{ pokemonID = 218, rate = 0.30, minLv = 24, maxLv = 30, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[290] = { name = "Ruby Path B2F- b",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 218, rate = 0.60, minLv = 22, maxLv = 32, },
				{ pokemonID = 74, rate = 0.40, minLv = 40, maxLv = 44, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		-- Bulbapedia says there's encounters for B4F/B5F but includes rock smash encounters
		-- There are no rocks to smash on these floors, and I ran for a good while through both floors, no encounters
		-- [[End]] One Island: Mt. Ember
		[292] = { name = "Rocket Warehouse", }, -- Only trainers here
		[293] = { name = "Icefall Cave Entrance",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 86, rate = 0.40, minLv = 43, maxLv = 47, },
				{ pokemonID = 42, rate = 0.25, minLv = 45, maxLv = 48, },
				{ pokemonID = 87, rate = 0.20, minLv = 49, maxLv = 53, },
				{ pokemonID = 41, rate = 0.10, minLv = 40, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 41, maxLv = 41, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 86, rate = 0.60, minLv = 5, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.30, minLv = 5, maxLv = 35, },
				{ pokemonID = 87, rate = 0.05, minLv = 35, maxLv = 40, },
				{ pokemonID = {194,183}, rate = 0.05, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = 60, rate = 0.60, minLv = 5, maxLv = 15, },
				{ pokemonID = 118, rate = 0.20, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = 60, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 61, rate = 0.40, minLv = 20, maxLv = 30, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 15, maxLv = 35, },
			},
		},
		[294] = { name = "Icefall Cave 1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 220, rate = 0.50, minLv = 23, maxLv = 31, },
				{ pokemonID = 42, rate = 0.25, minLv = 45, maxLv = 48, },
				{ pokemonID = 41, rate = 0.10, minLv = 40, maxLv = 40, },
				{ pokemonID = 86, rate = 0.10, minLv = 45, maxLv = 45, },
				{ pokemonID = {225,215}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[295] = { name = "Icefall Cave B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 220, rate = 0.50, minLv = 23, maxLv = 31, },
				{ pokemonID = 42, rate = 0.25, minLv = 45, maxLv = 48, },
				{ pokemonID = 41, rate = 0.10, minLv = 40, maxLv = 40, },
				{ pokemonID = 86, rate = 0.10, minLv = 45, maxLv = 45, },
				{ pokemonID = {225,215}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[296] = { name = "Icefall Cave Back",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 86, rate = 0.40, minLv = 43, maxLv = 47, },
				{ pokemonID = 42, rate = 0.25, minLv = 45, maxLv = 48, },
				{ pokemonID = 87, rate = 0.20, minLv = 49, maxLv = 53, },
				{ pokemonID = 41, rate = 0.10, minLv = 40, maxLv = 40, },
				{ pokemonID = {54,79}, rate = 0.05, minLv = 41, maxLv = 41, },
			},
			[RouteData.EncounterArea.SURFING] = {
				{ pokemonID = 72, rate = 0.95, minLv = 5, maxLv = 45, },
				{ pokemonID = 73, rate = 0.04, minLv = 35, maxLv = 45, },
				{ pokemonID = 131, rate = 0.01, minLv = 30, maxLv = 45, },
			},
			[RouteData.EncounterArea.OLDROD] = {
				{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 5, },
			},
			[RouteData.EncounterArea.GOODROD] = {
				{ pokemonID = {116,98}, rate = 0.80, minLv = 5, maxLv = 15, },
				{ pokemonID = 129, rate = 0.20, minLv = 5, maxLv = 15, },
			},
			[RouteData.EncounterArea.SUPERROD] = {
				{ pokemonID = {116,98}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {117,99}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[298] = { name = "Trainer Tower 1F", },
		[299] = { name = "Trainer Tower 2F", },
		[300] = { name = "Trainer Tower 3F", },
		[301] = { name = "Trainer Tower 4F", },
		[302] = { name = "Trainer Tower 5F", },
		[303] = { name = "Trainer Tower 6F", },
		[304] = { name = "Trainer Tower 7F", },
		[305] = { name = "Trainer Tower 8F", },
		[317] = { name = "Pattern Bush",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {167,165}, rate = 0.30, minLv = 9, maxLv = 14, },
				{ pokemonID = {14,11}, rate = 0.20, minLv = 9, maxLv = 9, },
				{ pokemonID = 214, rate = 0.20, minLv = 15, maxLv = 30, },
				{ pokemonID = 10, rate = 0.10, minLv = 6, maxLv = 6, },
				{ pokemonID = 13, rate = 0.10, minLv = 6, maxLv = 6, },
				{ pokemonID = {165,167}, rate = 0.05, minLv = 9, maxLv = 14, },
				{ pokemonID = {11,14}, rate = 0.05, minLv = 9, maxLv = 9, },
			},
		},
		[321] = { name = "Lost Cave Room 1",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[322] = { name = "Lost Cave Room 2",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[323] = { name = "Lost Cave Room 3",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[324] = { name = "Lost Cave Room 4",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[325] = { name = "Lost Cave Room 5",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[326] = { name = "Lost Cave Room 6",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[327] = { name = "Lost Cave Room 7",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[328] = { name = "Lost Cave Room 8",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[329] = { name = "Lost Cave Room 9",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[330] = { name = "Lost Cave Room 10",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[331] = { name = "Lost Cave Room 11",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[332] = { name = "Lost Cave Room 12",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[333] = { name = "Lost Cave Room 13",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[334] = { name = "Lost Cave Room 14",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[335] = { name = "Monean Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[336] = { name = "Liptoo Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[337] = { name = "Weepth Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[338] = { name = "Dilford Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[339] = { name = "Scufib Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[340] = { name = "Altering Cave",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 1.00, minLv = 6, maxLv = 16, },
			},
		},
		[342] = { name = "Birth Island",
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 386, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[345] = { name = "Navel Rock Summit",
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 250, rate = 1.00, minLv = 70, maxLv = 70, },
			},
		},
		[346] = { name = "Navel Rock Base",
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 249, rate = 1.00, minLv = 70, maxLv = 70, },
			},
		},
		[362] = { name = "Rixy Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[363] = { name = "Viapois Chamber",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
	}

	return 363 -- max mapId
end

-- https://github.com/pret/pokeemerald/blob/677b4fc394516deab5b5c86c94a2a1443cb52151/include/constants/layouts.h
-- https://www.serebii.net/pokearth/hoenn/3rd/route101.shtml
function RouteData.setupRouteInfoAsRSE()
	-- Ruby/Sapphire has LAYOUT_LILYCOVE_CITY_EMPTY_MAP 108, offset all "mapId > 107" by +1
	local isGameEmerald = GameSettings.versioncolor == "Emerald"
	local offset = Utils.inlineIf(isGameEmerald, 0, 1)

	RouteData.Locations.CanPCHeal = {
		[54] = true, -- Mom's house
		[61] = true, -- Most Pokemon Centers
		[71] = true, -- Lavaridge Town
		[270 + offset] = true, -- Pokemon League
	}
	RouteData.Locations.CanObtainBadge = {
		[65] = true,
		[69] = true,
		[70] = true,
		[79] = true,
		[89] = true,
		[94] = true,
		[100] = true,
		[108] = true,
		[109] = true,
		[110] = true,
	}
	RouteData.Locations.IsInLab = {
		[17] = true, -- Route 101
	}

	RouteData.Info = {}

	RouteData.Info[1] = { name = "Petalburg City",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 1.00, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 341, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 341, rate = 1.00, },
		},
	}
	RouteData.Info[2] = { name = "Slateport City",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[3] = { name = "Mauville City", }
	RouteData.Info[4] = { name = "Rustboro City", }
	RouteData.Info[5] = { name = "Fortree City", }
	RouteData.Info[6] = { name = "Lilycove City",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.85, },
			{ pokemonID = 120, rate = 0.15, },
		},
	}
	RouteData.Info[7] = { name = "Mossdeep City",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[8] = { name = "Sootopolis City",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 129, rate = 1.00, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 1.00, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 129, rate = 0.80, },
			{ pokemonID = 130, rate = 0.20, },
		},
	}
	RouteData.Info[9] = { name = "Ever Grande City",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 320, rate = 0.20, },
			{ pokemonID = 370, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 370, rate = 0.40, },
			{ pokemonID = 222, rate = 0.15, },
		},
	}
	RouteData.Info[10] = { name = "Littleroot Town", }
	RouteData.Info[11] = { name = "Oldale Town", }
	RouteData.Info[12] = { name = "Dewford Town",
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[13] = { name = "Lavaridge Town", }
	RouteData.Info[14] = { name = "Fallarbor Town", }
	RouteData.Info[15] = { name = "Verdanturf City", }
	RouteData.Info[16] = { name = "Pacifidlog Town",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[17] = { name = "Route 101",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,265}, rate = 0.45, },
			{ pokemonID = {265,265,261}, rate = 0.45, },
			{ pokemonID = {261,261,263}, rate = 0.10, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 265, rate = 1.00, },
		},
	}
	RouteData.Info[18] = { name = "Route 102",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,265}, rate = 0.30, },
			{ pokemonID = {265,265,261}, rate = 0.30, },
			{ pokemonID = {273,270,270}, rate = 0.20, },
			{ pokemonID = {261,261,263}, rate = 0.15, },
			{ pokemonID = 280, rate = 0.04, },
			{ pokemonID = {283,283,273}, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, },
			{ pokemonID = {283,283,118}, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 341, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 341, rate = 1.00, },
		},
	}
	RouteData.Info[19] = { name = "Route 103",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.60, },
			{ pokemonID = {261,261,263}, rate = 0.30, },
			{ pokemonID = 278, rate = 0.10, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[20] = { name = "Route 104",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = {0.50,0.50,0.40}, },
			{ pokemonID = {-1,-1,183}, rate = 0.20, },
			{ pokemonID = 265, rate = {0.30,0.30,0.20}, },
			{ pokemonID = 276, rate = 0.10, },
			{ pokemonID = 278, rate = 0.10, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 278, rate = 0.95, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 1.00, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 1.00, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 129, rate = 1.00, },
		},
	}
	RouteData.Info[21] = { name = "Route 105",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 378, rate = 1.00, },
		},
	}
	RouteData.Info[22] = { name = "Route 106",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[23] = { name = "Route 107",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[24] = { name = "Route 108",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[25] = { name = "Route 109",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[26] = { name = "Route 110",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 309, rate = 0.30, },
			{ pokemonID = {263,263,261}, rate = 0.20, },
			{ pokemonID = {312,311,312}, rate = 0.15, },
			{ pokemonID = 316, rate = 0.15, },
			{ pokemonID = 43, rate = 0.10, },
			{ pokemonID = 278, rate = 0.08, },
			{ pokemonID = {311,312,311}, rate = 0.02, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[27] = { name = "Route 111",
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, },
			{ pokemonID = {283,283,118}, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 377, rate = 1.00, },
		},
	}
	RouteData.Info[28] = { name = "Route 112",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.75, },
			{ pokemonID = {66,66,183}, rate = 0.25, },
		},
	}
	RouteData.Info[29] = { name = "Route 113",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 327, rate = 0.70, },
			{ pokemonID = {27,27,218}, rate = 0.25, },
			{ pokemonID = 227, rate = 0.05, },
		},
	}
	RouteData.Info[30] = { name = "Route 114",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 333, rate = 0.40, },
			{ pokemonID = {273,270,270}, rate = 0.30, },
			{ pokemonID = {335,336,271}, rate = {0.19,0.19,0.20}, },
			{ pokemonID = {274,271,336}, rate = {0.10,0.10,0.09}, },
			{ pokemonID = {283,283,274}, rate = 0.01, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, },
			{ pokemonID = {283,283,118}, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, },
		},
	}
	RouteData.Info[31] = { name = "Route 115",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 276, rate = 0.40, },
			{ pokemonID = 333, rate = 0.30, },
			{ pokemonID = 39, rate = 0.10, },
			{ pokemonID = 277, rate = 0.10, },
			{ pokemonID = 278, rate = 0.10, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[32] = { name = "Route 116",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {293,293,261}, rate = {0.30,0.30,0.28}, },
			{ pokemonID = {263,263,293}, rate = {0.28,0.28,0.20}, },
			{ pokemonID = 276, rate = 0.20, },
			{ pokemonID = 290, rate = 0.20, },
			{ pokemonID = {-1,-1,63}, rate = 0.10, },
			{ pokemonID = 300, rate = 0.02, },
		},
	}
	RouteData.Info[33] = { name = "Route 117",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,43}, rate = {0.30,0.30,0.40}, },
			{ pokemonID = {315,315,261}, rate = 0.30, },
			{ pokemonID = {314,313,314}, rate = 0.18, },
			{ pokemonID = {43,43,-1}, rate = 0.10, },
			{ pokemonID = 183, rate = 0.10, },
			{ pokemonID = {313,314,313}, rate = 0.01, },
			{ pokemonID = {283,283,273}, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, },
			{ pokemonID = {283,283,118}, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 341, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 341, rate = 1.00, },
		},
	}
	RouteData.Info[34] = { name = "Route 118",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 263, rate = 0.30, },
			{ pokemonID = 309, rate = 0.30, },
			{ pokemonID = 278, rate = 0.19, },
			{ pokemonID = 264, rate = 0.10, },
			{ pokemonID = 310, rate = 0.10, },
			{ pokemonID = 352, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 318, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 318, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[35] = { name = "Route 119",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, },
			{ pokemonID = 263, rate = 0.30, },
			{ pokemonID = 264, rate = 0.30, },
			{ pokemonID = 357, rate = 0.09, },
			{ pokemonID = 352, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 318, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 318, rate = 1.00, },
			{ pokemonID = 349, rate = 0.00, },
		},
	}
	RouteData.Info[36] = { name = "Route 120",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {264,264,262}, rate = 0.30, },
			{ pokemonID = 43, rate = 0.25, },
			{ pokemonID = {263,263,261}, rate = 0.20, },
			{ pokemonID = 183, rate = 0.15, },
			{ pokemonID = 359, rate = 0.08, },
			{ pokemonID = {283,283,261}, rate = 0.01, },
			{ pokemonID = 352, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, },
			{ pokemonID = {283,283,118}, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 379, rate = 1.00, },
		},
	}
	RouteData.Info[37] = { name = "Route 121",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.30, },
			{ pokemonID = {263,263,261}, rate = 0.20, },
			{ pokemonID = {264,264,262}, rate = 0.20, },
			{ pokemonID = 43, rate = 0.15, },
			{ pokemonID = 278, rate = 0.09, },
			{ pokemonID = 44, rate = 0.05, },
			{ pokemonID = 352, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[38] = { name = "Route 122",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[39] = { name = "Route 123",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.30, },
			{ pokemonID = {263,263,261}, rate = 0.20, },
			{ pokemonID = {264,264,262}, rate = 0.20, },
			{ pokemonID = 43, rate = 0.15, },
			{ pokemonID = 278, rate = 0.09, },
			{ pokemonID = 44, rate = 0.05, },
			{ pokemonID = 352, rate = 0.01, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[40] = { name = "Route 124",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[274] = { name = "Route 124 Water",
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, },
			{ pokemonID = 170, rate = 0.30, },
			{ pokemonID = 369, rate = 0.05, },
		},
	}
	RouteData.Info[41] = { name = "Route 125",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[42] = { name = "Route 126",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[51] = { name = "Route 126 Water",
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, },
			{ pokemonID = 170, rate = 0.30, },
			{ pokemonID = 369, rate = 0.05, },
		},
	}
	RouteData.Info[43] = { name = "Route 127",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[52] = { name = "Route 127 Water",
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, },
			{ pokemonID = 170, rate = 0.30, },
			{ pokemonID = 369, rate = 0.05, },
		},
	}
	RouteData.Info[44] = { name = "Route 128",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 320, rate = 0.20, },
			{ pokemonID = 370, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 370, rate = 0.40, },
			{ pokemonID = 222, rate = 0.15, },
		},
	}
	RouteData.Info[53] = { name = "Route 128 Water",
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, },
			{ pokemonID = 170, rate = 0.30, },
			{ pokemonID = 369, rate = 0.05, },
		},
	}
	RouteData.Info[45] = { name = "Route 129",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.04, },
			{ pokemonID = 321, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[46] = { name = "Route 130", -- Mirage Island?
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 360, rate = 1.00, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[47] = { name = "Route 131",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, },
			{ pokemonID = 319, rate = 0.40, },
		},
	}
	RouteData.Info[48] = { name = "Route 132",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 319, rate = 0.40, },
			{ pokemonID = 116, rate = 0.15, },
		},
	}
	RouteData.Info[49] = { name = "Route 133",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 319, rate = 0.40, },
			{ pokemonID = 116, rate = 0.15, },
		},
	}
	RouteData.Info[50] = { name = "Route 134",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 278, rate = 0.35, },
			{ pokemonID = 279, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, },
			{ pokemonID = 319, rate = 0.40, },
			{ pokemonID = 116, rate = 0.15, },
		},
	}

	RouteData.Info[54] = { name = "Mom's House", }
	RouteData.Info[61] = { name = Constants.Words.POKEMON .. " Center", }
	RouteData.Info[65] = { name = "Dewford Gym", }
	RouteData.Info[69] = { name = "Lavaridge Gym1", }
	RouteData.Info[70] = { name = "Lavaridge Gym2", }
	RouteData.Info[71] = { name = "Lavaridge Town PC", }
	RouteData.Info[79] = { name = "Petalburg Gym", }
	RouteData.Info[89] = { name = "Mauville Gym", }
	RouteData.Info[94] = { name = "Rustboro Gym", }
	RouteData.Info[100] = { name = "Fortree Gym", }
	RouteData.Info[108] = { name = "Mossdeep Gym", }
	RouteData.Info[109] = { name = "Sootopolis Gym1", }
	RouteData.Info[110] = { name = "Sootopolis Gym2", }

	RouteData.Info[125 + offset] = { name = "Meteor Falls 1Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.80, },
			{ pokemonID = {338,337,338}, rate = 0.20, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, },
		},
	}
	RouteData.Info[126 + offset] = { name = "Meteor Falls 1Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.65, },
			{ pokemonID = {338,337,338}, rate = 0.35, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}
	RouteData.Info[127 + offset] = { name = "Meteor Falls 2Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.65, },
			{ pokemonID = {338,337,338}, rate = 0.35, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}
	RouteData.Info[128 + offset] = { name = "Meteor Falls 2Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.50, },
			{ pokemonID = {338,337,338}, rate = 0.25, },
			{ pokemonID = 371, rate = 0.25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, },
			{ pokemonID = {338,337,338}, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}
	if isGameEmerald then
		RouteData.Info[431] = { name = "Meteor Falls 2Fc",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 42, rate = 0.50, },
				{ pokemonID = {338,337,338}, rate = 0.25, },
				{ pokemonID = 371, rate = 0.25, },
			},
		}
	end
	RouteData.Info[129 + offset] = { name = "Rusturf Tunnel",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 293, rate = 1.00, },
		},
	}

	RouteData.Info[132 + offset] = { name = "Granite Cave 1Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 296, rate = 0.50, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 63, rate = 0.10, },
			{ pokemonID = 41, rate = 0.10, },
		},
	}
	RouteData.Info[133 + offset] = { name = "Granite Cave B1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 304, rate = 0.40, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 63, rate = 0.10, },
			{ pokemonID = 296, rate = 0.10, },
			{ pokemonID = {303,302,302}, rate = 0.10, },
		},
	}
	RouteData.Info[134 + offset] = { name = "Granite Cave B2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 304, rate = 0.40, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.20, },
			{ pokemonID = 296, rate = 0.10, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 0.70, },
			{ pokemonID = 299, rate = 0.30, },
		},
	}
	RouteData.Info[288 + offset] = { name = "Granite Cave 1Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 296, rate = 0.50, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 63, rate = 0.10, },
			{ pokemonID = 304, rate = 0.10, },
		},
	}
	RouteData.Info[135 + offset] = { name = "Petalburg Woods",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.30, },
			{ pokemonID = 265, rate = 0.25, },
			{ pokemonID = 285, rate = 0.15, },
			{ pokemonID = 266, rate = 0.10, },
			{ pokemonID = 268, rate = 0.10, },
			{ pokemonID = 276, rate = 0.05, },
			{ pokemonID = 287, rate = 0.05, },
		},
	}
	RouteData.Info[136 + offset] = { name = "Mt. Chimney", }
	RouteData.Info[137 + offset] = { name = "Mt. Pyre 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, },
		},
	}
	RouteData.Info[138 + offset] = { name = "Mt. Pyre 2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, },
		},
	}
	RouteData.Info[139 + offset] = { name = "Mt. Pyre 3F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, },
		},
	}
	RouteData.Info[140 + offset] = { name = "Mt. Pyre 4F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, },
			{ pokemonID = {353,355,355}, rate = 0.10, },
		},
	}
	RouteData.Info[141 + offset] = { name = "Mt. Pyre 5F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, },
			{ pokemonID = {353,355,355}, rate = 0.10, },
		},
	}
	RouteData.Info[142 + offset] = { name = "Mt. Pyre 6F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, },
			{ pokemonID = {353,355,355}, rate = 0.10, },
		},
	}

	RouteData.Info[147 + offset] = { name = "Seafloor Cavern",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, },
			{ pokemonID = 42, rate = 0.10, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.35, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[148 + offset] = { name = "Seafloor Cavern 1", }
	RouteData.Info[149 + offset] = { name = "Seafloor Cavern 2", }
	RouteData.Info[150 + offset] = { name = "Seafloor Cavern 3", }
	RouteData.Info[151 + offset] = { name = "Seafloor Cavern 4", }
	RouteData.Info[152 + offset] = { name = "Seafloor Cavern 5", }
	RouteData.Info[153 + offset] = { name = "Seafloor Cavern 6",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.35, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[154 + offset] = { name = "Seafloor Cavern 7",
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.35, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[155 + offset] = { name = "Seafloor Cavern 8", }
	RouteData.Info[156 + offset] = { name = "Seafloor Cavern 9", }

	RouteData.Info[157 + offset] = { name = "Cave of Origin",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, },
			{ pokemonID = 42, rate = 0.10, },
		},
	}
	RouteData.Info[158 + offset] = { name = "Cave of Origin 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.60, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 42, rate = 0.10, },
		},
	}

	if isGameEmerald then
		RouteData.Info[162] = { name = "Cave of Origin B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {-1,-1,302}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
	else
		RouteData.Info[160] = { name = "Cave of Origin B1F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[161] = { name = "Cave of Origin B2F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[162] = { name = "Cave of Origin B3F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[163] = { name = "Cave of Origin B4F",
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = {383,382,-1}, rate = 1.00, },
			},
		}
	end
	RouteData.Info[163 + offset] = { name = "Victory Road 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.25, },
			{ pokemonID = 297, rate = 0.25, },
			{ pokemonID = 41, rate = 0.10, },
			{ pokemonID = 294, rate = 0.10, },
			{ pokemonID = 296, rate = 0.10, },
			{ pokemonID = 305, rate = 0.10, },
			{ pokemonID = 293, rate = 0.05, },
			{ pokemonID = 304, rate = 0.05, },
		},
	}
	RouteData.Info[164 + offset] = { name = "Shoal Cave Lo-1",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[165 + offset] = { name = "Shoal Cave Lo-2",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[166 + offset] = { name = "Shoal Cave Lo-3",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[167 + offset] = { name = "Shoal Cave Lo-4",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.40, },
			{ pokemonID = 361, rate = 0.10, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[168 + offset] = { name = "Shoal Cave Hi-1",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 363, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[169 + offset] = { name = "Shoal Cave Hi-2",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, },
			{ pokemonID = 41, rate = 0.30, },
			{ pokemonID = 363, rate = 0.10, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 72, rate = 0.20, },
			{ pokemonID = 320, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, },
		},
	}
	RouteData.Info[184 + offset] = { name = "New Mauville 1",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 81, rate = 0.50, },
			{ pokemonID = 100, rate = 0.50, },
		},
	}
	RouteData.Info[185 + offset] = { name = "New Mauville 2",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 81, rate = 0.49, },
			{ pokemonID = 100, rate = 0.49, },
			{ pokemonID = 82, rate = 0.01, },
			{ pokemonID = 101, rate = 0.01, },
		},
	}
	RouteData.Info[238 + offset] = { name = "Safari Zone NW.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, },
			{ pokemonID = 111, rate = 0.30, },
			{ pokemonID = 44, rate = 0.15, },
			{ pokemonID = 84, rate = 0.15, },
			{ pokemonID = 85, rate = 0.05, },
			{ pokemonID = 127, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 54, rate = 0.95, },
			{ pokemonID = 55, rate = 0.05, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.40, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 118, rate = 0.80, },
			{ pokemonID = 119, rate = 0.20, },
		},
	}
	RouteData.Info[239 + offset] = { name = "Safari Zone NE.", -- North in Emerald decomp, as extension is to East
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, },
			{ pokemonID = 231, rate = 0.30, },
			{ pokemonID = 44, rate = 0.15, },
			{ pokemonID = 177, rate = 0.15, },
			{ pokemonID = 178, rate = 0.05, },
			{ pokemonID = 214, rate = 0.05, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, },
		},
	}
	RouteData.Info[240 + offset] = { name = "Safari Zone SW.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.40, },
			{ pokemonID = 203, rate = 0.20, },
			{ pokemonID = 84, rate = 0.10, },
			{ pokemonID = 177, rate = 0.10, },
			{ pokemonID = 202, rate = 0.10, },
			{ pokemonID = 25, rate = 0.05, },
			{ pokemonID = 44, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 54, rate = 1.00, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.40, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 118, rate = 0.80, },
			{ pokemonID = 119, rate = 0.20, },
		},
	}
	RouteData.Info[241 + offset] = { name = "Safari Zone SE.", -- South in Emerald, as extension is to East
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.40, },
			{ pokemonID = 203, rate = 0.20, },
			{ pokemonID = 84, rate = 0.10, },
			{ pokemonID = 177, rate = 0.10, },
			{ pokemonID = 202, rate = 0.10, },
			{ pokemonID = 25, rate = 0.05, },
			{ pokemonID = 44, rate = 0.05, },
		},
	}

	RouteData.Info[270 + offset] = { name = Constants.Words.POKEMON .. " League PC", }
	RouteData.Info[285 + offset] = { name = "Victory Road B1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.35, },
			{ pokemonID = 297, rate = 0.35, },
			{ pokemonID = 305, rate = {0.15,0.15,0.25}, },
			{ pokemonID = {308,308,-1}, rate = 0.10, },
			{ pokemonID = {307,307,303}, rate = 0.05, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 0.70, },
			{ pokemonID = 75, rate = 0.30, },
		},
	}
	RouteData.Info[286 + offset] = { name = "Victory Road B2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.35, },
			{ pokemonID = {303,302,302}, rate = 0.35, },
			{ pokemonID = 305, rate = {0.15,0.15,0.25}, },
			{ pokemonID = {308,308,303}, rate = {0.15,0.15,0.05}, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 1.00, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 339, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, },
			{ pokemonID = 340, rate = 0.20, },
		},
	}

	RouteData.Info[291 + offset] = { name = "Southern Island",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = {380,381,381}, rate = 1.00, },
		},
	}
	RouteData.Info[292 + offset] = { name = "Jagged Pass",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.55, },
			{ pokemonID = 66, rate = 0.25, },
			{ pokemonID = 325, rate = 0.20, },
		},
	}
	RouteData.Info[293 + offset] = { name = "Fiery Path",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.30, },
			{ pokemonID = {109,88,109}, rate = 0.25, },
			{ pokemonID = 324, rate = 0.18, },
			{ pokemonID = 66, rate = 0.15, },
			{ pokemonID = 218, rate = 0.10, },
			{ pokemonID = {88,109,88}, rate = 0.02, },
		},
	}

	RouteData.Info[302 + offset] = { name = "Mt. Pyre Ext.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = {0.40,0.40,0.60}, },
			{ pokemonID = {307,307,-1}, rate = 0.30, },
			{ pokemonID = 37, rate = {0.20,0.20,0.30}, },
			{ pokemonID = 278, rate = 0.10, },
		},
	}
	RouteData.Info[303 + offset] = { name = "Mt. Pyre Summit",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.85, },
			{ pokemonID = {355,353,353}, rate = 0.13, },
			{ pokemonID = 278, rate = 0.02, },
		},
	}

	RouteData.Info[322 + offset] = { name = "Sky Pillar 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.25, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
		},
	}
	RouteData.Info[324 + offset] = { name = "Sky Pillar 3F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.25, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
		},
	}
	RouteData.Info[330 + offset] = { name = "Sky Pillar 5F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.19, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
			{ pokemonID = 334, rate = 0.06, },
		},
	}
	RouteData.Info[331 + offset] = { name = "Sky Pillar 6F",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 384, rate = 1.00, },
		},
	}

	-- Ruby/Sapphire do not have maps beyond this point
	if not isGameEmerald then return 332 end

	RouteData.Info[336] = { name = "Magma Hideout 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[337] = { name = "Magma Hideout 2Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[338] = { name = "Magma Hideout 2Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[339] = { name = "Magma Hideout 3Fa",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[340] = { name = "Magma Hideout 3Fb",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[341] = { name = "Magma Hideout 4F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[345] = { name = "Battle Frontier E.",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 185, rate = 1.00, },
		},
	}
	RouteData.Info[379] = { name = "Magma Hideout 3Fc",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[380] = { name = "Magma Hideout 2Fc",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[381] = { name = "Mirage Tower 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[382] = { name = "Mirage Tower 2F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[383] = { name = "Mirage Tower 3F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[388] = { name = "Mirage Tower 4F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[389] = { name = "Desert Underpass",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 132, rate = 0.50, },
			{ pokemonID = 293, rate = 0.34, },
			{ pokemonID = 294, rate = 0.16, },
		},
	}
	-- Emerald gets two extra safari zones unlocked to the East after Hall of Fame
	RouteData.Info[394] = { name = "Safari Zone N-Ext.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 190, rate = 0.30, },
			{ pokemonID = 216, rate = 0.30, },
			{ pokemonID = 165, rate = 0.10, },
			{ pokemonID = 191, rate = 0.10, },
			{ pokemonID = 163, rate = 0.05, },
			{ pokemonID = 204, rate = 0.05, },
			{ pokemonID = 228, rate = 0.05, },
			{ pokemonID = 241, rate = 0.05, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 213, rate = 1.00, },
		},
	}
	RouteData.Info[395] = { name = "Safari Zone S-Ext.",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 179, rate = 0.30, },
			{ pokemonID = 191, rate = 0.30, },
			{ pokemonID = 167, rate = 0.10, },
			{ pokemonID = 190, rate = 0.10, },
			{ pokemonID = 163, rate = 0.05, },
			{ pokemonID = 207, rate = 0.05, },
			{ pokemonID = 209, rate = 0.05, },
			{ pokemonID = 234, rate = 0.05, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 194, rate = 0.60, },
			{ pokemonID = 183, rate = 0.39, },
			{ pokemonID = 195, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 118, rate = 0.30, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, },
			{ pokemonID = 118, rate = 0.20, },
			{ pokemonID = 223, rate = 0.20, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 223, rate = 0.59, },
			{ pokemonID = 118, rate = 0.40, },
			{ pokemonID = 224, rate = 0.01, },
		},
	}
	RouteData.Info[400] = { name = "Artisan Cave B1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 235, rate = 1.00, },
		},
	}
	RouteData.Info[401] = { name = "Artisan Cave 1F",
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 235, rate = 1.00, },
		},
	}

	RouteData.Info[403] = { name = "Faraway Island",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 151, rate = 1.00, },
		},
	}
	RouteData.Info[404] = { name = "Birth Island",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 386, rate = 1.00, },
		},
	}
	RouteData.Info[409] = { name = "Terra Cave",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 383, rate = 1.00, },
		},
	}
	RouteData.Info[413] = { name = "Marine Cave", -- untested
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 382, rate = 1.00, },
		},
	}
	RouteData.Info[423] = { name = "Navel Rock Top",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 250, rate = 1.00, },
		},
	}
	RouteData.Info[424] = { name = "Navel Rock Bot",
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 249, rate = 1.00, },
		},
	}

	return 424
end
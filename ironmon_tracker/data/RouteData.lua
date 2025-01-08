RouteData = {}

-- key: mapId (mapLayoutId)
-- value: name = ('string'),
--        encounterArea = ('table')
RouteData.Info = {}

-- All route map icons are currently 20x20 pixels
RouteData.Icons = {
	BuildingDoorLarge = { filename = "building-door-large", },
	BuildingDoorSmall = { filename = "building-door-small", },
	CaveEntrance = { filename = "cave-entrance", },
	CityMap = { filename = "city-map", },
	EliteFourStatue = { filename = "elitefour-statue", },
	ForestTree = { filename = "forest-tree", },
	GymBuilding = { filename = "gym-building", },
	MountainTop = { filename = "mountain-top", },
	OceanWaves = { filename = "ocean-waves", },
	RouteSign = { filename = "route-sign", },
	RouteSignWooden = { filename = "route-sign-wooden", },
}
for _, icon in pairs(RouteData.Icons) do
	icon.getIconPath = function(self) return FileManager.buildImagePath("maps", self.filename, ".png") end
end

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

-- [Deprecated] Use PokemonData.dexMapNationalToInternal(id) instead.
RouteData.NatDexToIndex = {}

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
	IsInHallOfFame = {},
	IsInSafariZone = {},
	EarlyGameCity = {},
}
-- Maps a mapId to all its connected other mapIds that make up a complete dungeon (e.g. Pokemon Tower 1F-7F)
RouteData.CombinedAreas = {}

function RouteData.initialize()
	-- Setup references for extensions that still use the deprecated table map
	local mt = {}
	setmetatable(RouteData.NatDexToIndex, mt)
	mt.__index = function(table, key)
		return PokemonData.dexMapNationalToInternal(key)
	end

	local maxMapId = 0
	if GameSettings.game == 1 or GameSettings.game == 2 then
		maxMapId = RouteData.setupRouteInfoAsRSE()
	elseif GameSettings.game == 3 then
		maxMapId = RouteData.setupRouteInfoAsFRLG()
	end

	-- Route names currently aren't translated or part of Resources, thus verify they can be displayed properly
	for _, route in pairs(RouteData.Info or {}) do
		if route.name then
			route.name = Utils.formatSpecialCharacters(route.name)
		end
	end

	RouteData.combineRouteAreas()
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
					table.insert(RouteData.AvailableRoutes, Utils.formatSpecialCharacters(route.name))
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

---@param mapId? number Optional, defaults to current location
---@return boolean
function RouteData.hasRouteTrainers(mapId)
	local route = RouteData.Info[mapId or TrackerAPI.getMapId()]
	return route and route.trainers and #route.trainers > 0
end

function RouteData.countPokemonInArea(mapId, encounterArea)
	local areaInfo = RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	return #areaInfo
end

function RouteData.isFishingEncounter(encounterArea)
	return encounterArea == RouteData.EncounterArea.OLDROD or encounterArea == RouteData.EncounterArea.GOODROD or encounterArea == RouteData.EncounterArea.SUPERROD
end

---Returns an ordered list of routes used for early game pivoting; or safari zones routes if `useSafari` is true
---@param useSafari? boolean Optional, if true will return safari zone routes instead of early game pivots
---@return table routeIds
function RouteData.getPivotOrSafariRouteIds(useSafari)
	if useSafari then
		local routeIds = {}
		for id, _ in pairs(RouteData.Locations.IsInSafariZone or {}) do
			table.insert(routeIds, id)
		end
		table.sort(routeIds, function(a,b) return a < b end)
		return routeIds
	else
		if GameSettings.game == 3 then -- FRLG
			return { 89, 90, 110, 117 } -- Route 1, 2, 22, Viridian Forest
		else -- RSE
			local offset = GameSettings.versioncolor == "Emerald" and 0 or 1 -- offset all "mapId > 107" by +1
			return { 17, 18, 19, 20, 32, 135 + offset } -- Route 101, 102, 103, 104, 116, Petalburg Forest
		end
	end
end

function RouteData.getEncounterAreaByTerrain(terrainId, battleFlags)
	if terrainId < 0 or terrainId > 19 then return nil end
	battleFlags = battleFlags or 4
	local isSafariEncounter = Utils.getbits(battleFlags, 7, 1) == 1

	-- Check if a special type of encounter has occurred, see list below
	if battleFlags > 4 and not isSafariEncounter then -- 4 (0b100) is the default base value
		local isFirstEncounter = Utils.getbits(battleFlags, 4, 1) == 1
		local staticFlags = Utils.bit_rshift(battleFlags, 10) -- untested but probably accurate, likely separate later
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
	-- BATTLE_TERRAIN_GRASS			0 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_LONG_GRASS	1 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_SAND			2 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_UNDERWATER	3 -- RouteData.EncounterArea.UNDERWATER
	-- BATTLE_TERRAIN_WATER			4 -- RouteData.EncounterArea.SURFING
	-- BATTLE_TERRAIN_POND			5 -- RouteData.EncounterArea.SURFING
	-- BATTLE_TERRAIN_MOUNTAIN		6 -- RouteData.EncounterArea.LAND ???
	-- BATTLE_TERRAIN_CAVE			7 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_BUILDING		8 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_PLAIN			9 -- RouteData.EncounterArea.LAND
	-- BATTLE_TERRAIN_LINK			10
	-- BATTLE_TERRAIN_GYM			11 -- returns 8 in Koga's gym
	-- BATTLE_TERRAIN_LEADER		12
	-- BATTLE_TERRAIN_INDOOR_2		13
	-- BATTLE_TERRAIN_INDOOR_1		14
	-- BATTLE_TERRAIN_LORELEI		15
	-- BATTLE_TERRAIN_BRUNO			16
	-- BATTLE_TERRAIN_AGATHA		17
	-- BATTLE_TERRAIN_LANCE			18
	-- BATTLE_TERRAIN_CHAMPION		19

	-- Battle Flags
	-- https://github.com/pret/pokefirered/blob/49ea462d7f421e75a76b25d7e85c92494c0a9798/include/constants/battle.h
	-- BATTLE_TYPE_DOUBLE				(1 << 0)
	-- BATTLE_TYPE_LINK					(1 << 1)
	-- BATTLE_TYPE_IS_MASTER			(1 << 2) // In not-link battles, it's always set.
	-- BATTLE_TYPE_TRAINER				(1 << 3)
	-- BATTLE_TYPE_FIRST_BATTLE			(1 << 4)
	-- BATTLE_TYPE_LINK_IN_BATTLE		(1 << 5) // Set on battle entry, cleared on exit. Checked rarely
	-- BATTLE_TYPE_MULTI				(1 << 6)
	-- BATTLE_TYPE_SAFARI				(1 << 7)
	-- BATTLE_TYPE_BATTLE_TOWER			(1 << 8)
	-- BATTLE_TYPE_OLD_MAN_TUTORIAL		(1 << 9) // Used in pokeemerald as BATTLE_TYPE_WALLY_TUTORIAL.
	-- BATTLE_TYPE_ROAMER				(1 << 10)
	-- BATTLE_TYPE_EREADER_TRAINER		(1 << 11)
	-- BATTLE_TYPE_KYOGRE_GROUDON		(1 << 12)
	-- BATTLE_TYPE_LEGENDARY			(1 << 13)
	-- BATTLE_TYPE_GHOST_UNVEILED		(1 << 13) // Re-use of BATTLE_TYPE_LEGENDARY, when combined with BATTLE_TYPE_GHOST
	-- BATTLE_TYPE_REGI					(1 << 14)
	-- BATTLE_TYPE_GHOST				(1 << 15) // Used in pokeemerald as BATTLE_TYPE_TWO_OPPONENTS.
	-- BATTLE_TYPE_POKEDUDE				(1 << 16) // Used in pokeemerald as BATTLE_TYPE_DOME.
	-- BATTLE_TYPE_WILD_SCRIPTED		(1 << 17) // Used in pokeemerald as BATTLE_TYPE_PALACE.
	-- BATTLE_TYPE_LEGENDARY_FRLG		(1 << 18) // Used in pokeemerald as BATTLE_TYPE_ARENA.
	-- BATTLE_TYPE_TRAINER_TOWER		(1 << 19) // Used in pokeemerald as BATTLE_TYPE_FACTORY.
end

---Returns true if this route has any encounter data (trainers or wild)
---@param mapId number
---@return boolean
function RouteData.hasAnyEncounters(mapId)
	if not RouteData.hasRoute(mapId) then
		return false
	end
	local route = RouteData.Info[mapId] or {}
	if route.trainers ~= nil then
		return true
	end
	for _, encounterArea in pairs(RouteData.EncounterArea or {}) do
		if route[encounterArea] ~= nil then
			return true
		end
	end
	return false
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
	local maxIterations = numEncounters + 1
	while startingIndex ~= nextIndex and maxIterations >= 0 do
		encounterArea = RouteData.OrderedEncounters[nextIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		nextIndex = (nextIndex % numEncounters) + 1
		maxIterations = maxIterations - 1
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
	-- Eventually fix this by more clearly separating a route's name from its encounters. eg. (encounters.wild)
	---@diagnostic disable-next-line: param-type-mismatch
	for _, encounter in pairs(RouteData.Info[mapId][encounterArea]) do
		local info = {
			pokemonID = 0,
			rate = 0,
			minLv = 0,
			maxLv = 0,
		}
		for key, _ in pairs(info) do
			local encVal = encounter[key] or 0
			if type(encVal) == "number" then
				info[key] = encVal
			else -- encVal = {val, val, val}
				info[key] = encVal[pIndex]
			end
		end
		-- the pokedex #s stored in route encounter data are national pokedex #s
		info.pokemonID = PokemonData.dexMapNationalToInternal(info.pokemonID)

		-- Some version have fewer Pokemon than others; if so, the ID will be -1
		if PokemonData.isValid(info.pokemonID) then
			table.insert(areaInfo, {
				pokemonID = info.pokemonID,
				rate = info.rate,
				minLv = info.minLv,
				maxLv = info.maxLv,
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

-- Builds out RouteData.CombinedAreas by grouping multi-floor buildings and caves together for easy look-ups
function RouteData.combineRouteAreas()
	-- Remove any existing mappings, if they exist
	for _, mapIdList in pairs(RouteData.CombinedAreas) do
		local maxIterations = 9999
		while #mapIdList > 0 and maxIterations > 0 do
			table.remove(mapIdList)
			maxIterations = maxIterations - 1
		end
	end
	-- Add in mappings
	for mapId, route in pairs(RouteData.Info) do
		-- The 'area' is the RouteData.CombinedAreas
		if type(route.area) == "table" then
			table.insert(route.area, mapId)
		end
	end
	-- After all mappings have been added, sort them
	for _, mapIdList in pairs(RouteData.CombinedAreas) do
		table.sort(mapIdList, function(a,b) return a < b end)
	end
end

RouteData.BlankRoute = {
	id = 0,
	name = Constants.BLANKLINE,
}

---Returns the name of a route or it's combined area
---@param mapId number
---@param simplifiedName? boolean Optional, if true will simplify the name by removing any parentheses; default false
---@return string
function RouteData.getRouteOrAreaName(mapId, simplifiedName)
	if not RouteData.hasRoute(mapId) then
		return "Unknown Area"
	end
	local route = RouteData.Info[mapId]
	local routeName = route.area and route.area.name or route.name
	if simplifiedName then
		routeName = Utils.replaceText(routeName, "%(.*%)", "")
	end
	return routeName
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
	RouteData.Locations.IsInHallOfFame = {
		[218] = true,
	}
	RouteData.Locations.IsInSafariZone = {
		[147] = true,
		[148] = true,
		[149] = true,
		[150] = true,
	}
	RouteData.Locations.EarlyGameCity = {
		[78] = true, -- Pallet Town
		[79] = true, -- Viridian City
		[80] = true, -- Pewter City
	}

	-- [AreaName] = { combained list of mapIds }
	RouteData.CombinedAreas = {
		MtMoon = { name = "Mt. Moon", dungeon = true },
		SSAnne = { name = "S.S. Anne", dungeon = true },
		RockTunnel = { name = "Rock Tunnel", dungeon = true },
		RocketHideout = { name = "Rocket Hideout", dungeon = true },
		PokemonTower = { name = "Pokémon Tower", dungeon = true },
		CinnabarMansion = { name = "Poké Mansion (Cinnabar)", dungeon = true },
		SilphCo = { name = "Silph Co.", dungeon = true },
		VictoryRoad = { name = "Victory Road", dungeon = true },
		EliteFour = { name = "Elite Four (Indigo Plateau)", dungeon = true },
		SafariZone = { name = "Safari Zone" },
		CeruleanCave = { name = "Cerulean Cave" },
		SeafoamIslands = { name = "Seafoam Islands" },
		SummitPath = { name = "Summit Path" },
		RubyPath = { name = "Ruby Path" },
		IcefallCave = { name = "Icefall Cave", dungeon = true },
		TrainerTower = { name = "Trainer Tower", dungeon = true },
		LostCave = { name = "Lost Cave", dungeon = true },
		TanobyChambers = { name = "Tanoby Chambers" },
	}

	RouteData.Info = {
		[1] = {
			name = "Mom's House",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[2] = {
			name = "Your Room",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[3] = {
			name = "Rival's House",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[4] = {
			name = "Rival's Room",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[5] = {
			name = "Oak's Lab",
			icon = RouteData.Icons.BuildingDoorSmall,
			dungeon = true,
			trainers = { 326, 327, 328 },
		},
		[8] = {
			name = "Pokémon Center",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[9] = {
			name = "Pokémon Center 2F",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[10] = {
			name = "PokéMart",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[12] = {
			name = "Cerulean Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 150, 234, 415 },
		},
		[15] = {
			name = "Celadon Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 132, 133, 160, 265, 266, 267, 402, 417 },
		},
		[20] = {
			name = "Fuchsia Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 294, 295, 288, 289, 292, 293, 418 },
		},
		[25] = {
			name = "Vermilion Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 141, 220, 423, 416 },
		},
		[27] = {
			name = "Game Corner",
			icon = RouteData.Icons.BuildingDoorLarge,
			dungeon = true,
			trainers = { 357 },
		},
		[28] = {
			name = "Pewter Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 142, 414 },
		},
		[34] = {
			name = "Saffron Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 280, 281, 282, 283, 462, 463, 464, 420 },
		},
		[36] = {
			name = "Cinnabar Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 177, 178, 179, 180, 213, 214, 215, 419 },
		},
		[37] = {
			name = "Viridian Gym",
			icon = RouteData.Icons.GymBuilding,
			dungeon = true,
			trainers = { 296, 297, 322, 323, 324, 392, 400, 401, 350 },
		},
		[77] = {
			name = "Safari Rest House",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[78] = {
			name = "Pallet Town",
			icon = RouteData.Icons.CityMap,
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
		[79] = {
			name = "Viridian City",
		icon = RouteData.Icons.CityMap,
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
		[80] = {
			name = "Pewter City",
			icon = RouteData.Icons.CityMap,
		},
		[81] = {
			name = "Cerulean City",
			icon = RouteData.Icons.CityMap,
			trainers = { 332, 333, 334, 355 },
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
		[82] = {
			name = "Lavender Town",
			icon = RouteData.Icons.CityMap,
		},
		[83] = {
			name = "Vermilion City",
			icon = RouteData.Icons.CityMap,
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
				{ pokemonID = {116,98}, rate = {0.44,0.40}, minLv = 15, maxLv = {35,25}, },
				{ pokemonID = {90,120}, rate = 0.40, minLv = 15, maxLv = 25, },
				{ pokemonID = 130, rate = 0.15, minLv = 15, maxLv = 25, },
				{ pokemonID = {-1,116}, rate = 0.04, minLv = 25, maxLv = 35, },
				{ pokemonID = {54,79}, rate = 0.01, minLv = 25, maxLv = 35, },
			},
		},
		[84] = {
			name = "Celadon City",
			icon = RouteData.Icons.CityMap,
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
		[85] = {
			name = "Fuchsia City",
			icon = RouteData.Icons.CityMap,
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
		[86] = {
			name = "Cinnabar Island",
			icon = RouteData.Icons.CityMap,
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
		[87] = {
			name = "Indigo Plateau",
			icon = RouteData.Icons.CityMap,
		},
		[88] = {
			name = "Saffron City Conn.",
			icon = RouteData.Icons.RouteSign,
		},
		[89] = {
			name = "Route 1",
			icon = RouteData.Icons.RouteSignWooden,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.50, minLv = 2, maxLv = 5, },
				{ pokemonID = 19, rate = 0.50, minLv = 2, maxLv = 4, },
			},
		},
		[90] = {
			name = "Route 2",
			icon = RouteData.Icons.RouteSignWooden,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 19, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 10, rate = 0.05, minLv = 4, maxLv = 5, },
				{ pokemonID = 13, rate = 0.05, minLv = 4, maxLv = 5, },
			},
		},
		[91] = {
			name = "Route 3",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 89, 90, 105, 106, 107, 116, 117, 118 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 21, rate = 0.35, minLv = 6, maxLv = 8, },
				{ pokemonID = 16, rate = 0.30, minLv = 6, maxLv = 7, },
				{ pokemonID = {32,29}, rate = 0.14, minLv = 6, maxLv = 7, },
				{ pokemonID = 39, rate = 0.10, minLv = 3, maxLv = 7, },
				{ pokemonID = 56, rate = 0.10, minLv = 7, maxLv = 7, },
				{ pokemonID = {29,32}, rate = 0.01, minLv = 6, maxLv = 6, },
			},
		},
		[92] = {
			name = "Route 4",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 119 },
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
		[93] = {
			name = "Route 5",
			icon = RouteData.Icons.RouteSignWooden,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.40, minLv = 13, maxLv = 16, },
				{ pokemonID = 52, rate = 0.35, minLv = 10, maxLv = 16, },
				{ pokemonID = {43,69}, rate = 0.25, minLv = 13, maxLv = 16, },
			},
		},
		[94] = {
			name = "Route 6",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 111, 112, 145, 146, 151, 152 },
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
		[95] = {
			name = "Route 7",
			icon = RouteData.Icons.RouteSignWooden,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 52, rate = 0.40, minLv = 17, maxLv = 20, },
				{ pokemonID = 16, rate = 0.30, minLv = 19, maxLv = 22, },
				{ pokemonID = {43,69}, rate = 0.20, minLv = 19, maxLv = 22, },
				{ pokemonID = {58,37}, rate = 0.10, minLv = 18, maxLv = 20, },
			},
		},
		[96] = {
			name = "Route 8",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 128, 129, 130, 131, 171, 172, 173, 262, 264, 484, 535, 536 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 16, rate = 0.30, minLv = 18, maxLv = 20, },
				{ pokemonID = 52, rate = 0.30, minLv = 18, maxLv = 20, },
				{ pokemonID = {23,27}, rate = 0.20, minLv = 17, maxLv = 19, },
				{ pokemonID = {58,37}, rate = 0.20, minLv = 15, maxLv = 18, },
			},
		},
		[97] = {
			name = "Route 9",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 114, 115, 148, 149, 154, 155, 185, 186, 465 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 19, rate = 0.40, minLv = 14, maxLv = 17, },
				{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
				{ pokemonID = {23,27}, rate = 0.25, minLv = 11, maxLv = 17, },
			},
		},
		[98] = {
			name = "Route 10",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 156, 157, 162, 163, 187, 188 },
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
		[99] = {
			name = "Route 11",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 97, 98, 99, 100, 221, 222, 258, 259, 260, 261 },
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
		[100] = {
			name = "Route 12",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 225, 226, 227, 228, 233, 285, 477, 486 },
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
		[101] = {
			name = "Route 13",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 195, 268, 269, 300, 301, 302, 466, 467, 468, 469 },
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
		[102] = {
			name = "Route 14",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 196, 207, 208, 209, 303, 304, 313, 314, 315, 316, 487 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 132, rate = 0.15, minLv = 23, maxLv = 23, },
				{ pokemonID = 16, rate = 0.10, minLv = 27, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[103] = {
			name = "Route 15",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 197, 198, 273, 274, 305, 306, 478, 479, 480, 481, 488 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 16, rate = 0.20, minLv = 25, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
				{ pokemonID = 132, rate = 0.05, minLv = 25, maxLv = 25, },
			},
		},
		[104] = {
			name = "Route 16",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 199, 201, 202, 249, 250, 251, 489 },
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
		[105] = {
			name = "Route 17",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 203, 204, 205, 206, 252, 253, 254, 255, 256, 470 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
				{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
				{ pokemonID = 20, rate = 0.30, minLv = 25, maxLv = 29, },
				{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
				{ pokemonID = 22, rate = 0.05, minLv = 25, maxLv = 27, },
			},
		},
		[106] = {
			name = "Route 18",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 307, 308, 309 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
				{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
				{ pokemonID = 20, rate = 0.15, minLv = 25, maxLv = 29, },
				{ pokemonID = 22, rate = 0.15, minLv = 25, maxLv = 29, },
				{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[107] = {
			name = "Route 19",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 235, 236, 237, 238, 239, 240, 241, 276, 277, 278, 490 },
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
		[108] = {
			name = "Route 20",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 242, 243, 244, 270, 271, 272, 279, 310, 472, 473 },
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
		[109] = {
			name = "Route 21 North",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 229, 231, 245, 491 },
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
		[110] = {
			name = "Route 22",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 329, 330, 331, 435, 436, 437 },
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
		[111] = {
			name = "Route 23",
			icon = RouteData.Icons.RouteSignWooden,
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
		[112] = {
			name = "Route 24",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 92, 110, 122, 123, 143, 144, 356 },
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
		[113] = {
			name = "Route 25",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 93, 94, 95, 153, 125, 182, 183, 184, 471 },
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
		[114] = {
			name = "Mt. Moon 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.MtMoon,
			dungeon = true,
			trainers = { 181, 91, 120, 121, 169, 108, 109 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.69, minLv = 7, maxLv = 10, },
				{ pokemonID = 74, rate = 0.25, minLv = 7, maxLv = 9, },
				{ pokemonID = 46, rate = 0.05, minLv = 8, maxLv = 8, },
				{ pokemonID = 35, rate = 0.01, minLv = 8, maxLv = 8, },
			},
		},
		[115] = {
			name = "Mt. Moon B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.MtMoon,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 46, rate = 1.00, minLv = 5, maxLv = 10, },
			},
		},
		[116] = {
			name = "Mt. Moon B2F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.MtMoon,
			dungeon = true,
			trainers = { 170, 351, 352, 353, 354 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.49, minLv = 8, maxLv = 11, },
				{ pokemonID = 74, rate = 0.30, minLv = 9, maxLv = 10, },
				{ pokemonID = 46, rate = 0.15, minLv = 10, maxLv = 12, },
				{ pokemonID = 35, rate = 0.06, minLv = 10, maxLv = 12, },
			},
		},
		[117] = {
			name = "Viridian Forest",
			icon = RouteData.Icons.ForestTree,
			trainers = { 102, 103, 104, 531, 532 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 10, rate = 0.40, minLv = 3, maxLv = 5, },
				{ pokemonID = 13, rate = 0.40, minLv = 3, maxLv = 5, },
				{ pokemonID = {14,11}, rate = 0.10, minLv = 4, maxLv = 6, },
				{ pokemonID = {11,14}, rate = 0.05, minLv = 5, maxLv = 5, },
				{ pokemonID = 25, rate = 0.05, minLv = 3, maxLv = 5, },
			},
		},
		[118] = {
			name = "S.S. Anne Ext.", -- Exterior
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
		},
		[119] = {
			name = "S.S. Anne 1F",
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
		},
		[120] = {
			name = "S.S. Anne 2F", -- 2F corridor (Rival Fight)
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
			trainers = { 426, 427, 428 },
		},
		[121] = {
			name = "S.S. Anne 3F",
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
		},
		[122] = {
			name = "S.S. Anne B1F",
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
		},
		[123] = {
			name = "S.S. Anne Deck",
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
			trainers = { 134, 135 },
		},
		[124] = {
			name = "Diglett's Cave B1F",
			icon = RouteData.Icons.CaveEntrance,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 50, rate = 0.95, minLv = 15, maxLv = 22, },
				{ pokemonID = 51, rate = 0.05, minLv = 29, maxLv = 31, },
			},
		},
		[125] = {
			name = "Victory Road 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.VictoryRoad,
			dungeon = true,
			trainers = { 406, 396 },
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
		[126] = {
			name = "Victory Road 2F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.VictoryRoad,
			dungeon = true,
			trainers = { 167, 325, 287, 290, 298 },
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
		[127] = {
			name = "Victory Road 3F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.VictoryRoad,
			dungeon = true,
			trainers = { 393, 394, 403, 404, 485 },
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
		[128] = {
			name = "Rocket Hideout B1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.RocketHideout,
			dungeon = true,
			trainers = { 358, 359, 360, 361, 362 },
		},
		[129] = {
			name = "Rocket Hideout B2F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.RocketHideout,
			dungeon = true,
			trainers = { 363 },
		},
		[130] = {
			name = "Rocket Hideout B3F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.RocketHideout,
			dungeon = true,
			trainers = { 364, 365 },
		},
		[131] = {
			name = "Rocket Hideout B4F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.RocketHideout,
			dungeon = true,
			trainers = { 348, 368, 366, 367 },
		},
		[132] = {
			name = "Silph Co. 1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
		},
		[133] = {
			name = "Silph Co. 2F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 336, 337, 373, 374 },
		},
		[134] = {
			name = "Silph Co. 3F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 338, 375 },
		},
		[135] = {
			name = "Silph Co. 4F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 339, 376, 377 },
		},
		[136] = {
			name = "Silph Co. 5F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 340, 378, 379, 286 },
		},
		[137] = {
			name = "Silph Co. 6F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 341, 380, 381 },
		},
		[138] = {
			name = "Silph Co. 7F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 342, 383, 384, 385, 432, 433, 434 },
		},
		[139] = {
			name = "Silph Co. 8F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 343, 382, 386 },
		},
		[140] = {
			name = "Silph Co. 9F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 344, 387, 388 },
		},
		[141] = {
			name = "Silph Co. 10F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 345, 389 },
		},
		[142] = {
			name = "Silph Co. 11F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SilphCo,
			dungeon = true,
			trainers = { 349, 390, 391 },
		},
		[143] = {
			name = "Poké Mansion 1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.CinnabarMansion,
			dungeon = true,
			trainers = { 335, 534 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[144] = {
			name = "Poké Mansion 2F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.CinnabarMansion,
			dungeon = true,
			trainers = { 216 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[145] = {
			name = "Poké Mansion 3F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.CinnabarMansion,
			dungeon = true,
			trainers = { 218, 346 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[146] = {
			name = "Poké Mansion B1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.CinnabarMansion,
			dungeon = true,
			trainers = { 219, 347 },
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
		[147] = {
			name = "Safari Zone Center",
			icon = RouteData.Icons.ForestTree,
			area = RouteData.CombinedAreas.SafariZone,
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
		[148] = {
			name = "Safari Zone East",
			icon = RouteData.Icons.ForestTree,
			area = RouteData.CombinedAreas.SafariZone,
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
		[149] = {
			name = "Safari Zone North",
			icon = RouteData.Icons.ForestTree,
			area = RouteData.CombinedAreas.SafariZone,
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
		[150] = {
			name = "Safari Zone West",
			icon = RouteData.Icons.ForestTree,
			area = RouteData.CombinedAreas.SafariZone,
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
		[151] = {
			name = "Cerulean Cave 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CeruleanCave,
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
		[152] = {
			name = "Cerulean Cave 2F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CeruleanCave,
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
		[153] = {
			name = "Cerulean Cave B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CeruleanCave,
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
		[154] = {
			name = "Rock Tunnel 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RockTunnel,
			dungeon = true,
			trainers = { 192, 193, 194, 168, 476, 475, 474 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.35, minLv = 15, maxLv = 17, },
				{ pokemonID = 41, rate = 0.30, minLv = 15, maxLv = 16, },
				{ pokemonID = 56, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 66, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 95, rate = 0.05, minLv = 13, maxLv = 15, },
			},
		},
		[155] = {
			name = "Rock Tunnel B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RockTunnel,
			dungeon = true,
			trainers = { 158, 159, 189, 190, 191, 164, 165, 166 },
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
		[156] = {
			name = "Seafoam Islands 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SeafoamIslands,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {54,79}, rate = 0.55, minLv = 26, maxLv = 33, },
				{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
				{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
			},
		},
		[157] = {
			name = "Seafoam Islands B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SeafoamIslands,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {54,79}, rate = 0.40, minLv = 29, maxLv = 31, },
				{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
				{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
				{ pokemonID = 86, rate = 0.10, minLv = 28, maxLv = 28, },
				{ pokemonID = {55,80}, rate = 0.05, minLv = 33, maxLv = 35, },
			},
		},
		[158] = {
			name = "Seafoam Islands B2F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SeafoamIslands,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = {54,79}, rate = 0.40, minLv = 30, maxLv = 32, },
				{ pokemonID = 41, rate = 0.20, minLv = 22, maxLv = 24, },
				{ pokemonID = 86, rate = 0.20, minLv = 30, maxLv = 32, },
				{ pokemonID = 42, rate = 0.10, minLv = 26, maxLv = 30, },
				{ pokemonID = {55,80}, rate = 0.10, minLv = 32, maxLv = 34, },
			},
		},
		[159] = {
			name = "Seafoam Islands B3F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SeafoamIslands,
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
		[160] = {
			name = "Seafoam Islands B4F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SeafoamIslands,
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
		[161] = {
			name = "Pokémon Tower 1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
		},
		[162] = {
			name = "Pokémon Tower 2F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
			trainers = { 429, 430, 431 },
		},
		[163] = {
			name = "Pokémon Tower 3F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
			trainers = { 441, 442, 443 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.90, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.01, minLv = 20, maxLv = 20, },
			},
		},
		[164] = {
			name = "Pokémon Tower 4F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
			trainers = { 444, 445, 446 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
			},
		},
		[165] = {
			name = "Pokémon Tower 5F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
			trainers = { 447, 448, 449, 450 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
			},
		},
		[166] = {
			name = "Pokémon Tower 6F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
			trainers = { 451, 452, 453 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.85, minLv = 17, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 17, maxLv = 19, },
				{ pokemonID = 93, rate = 0.06, minLv = 21, maxLv = 23, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 105, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[167] = {
			name = "Pokémon Tower 7F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.PokemonTower,
			dungeon = true,
			trainers = { 369, 370, 371 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 92, rate = 0.75, minLv = 15, maxLv = 19, },
				{ pokemonID = 93, rate = 0.15, minLv = 23, maxLv = 25, },
				{ pokemonID = 104, rate = 0.10, minLv = 17, maxLv = 19, },
			},
		},
		[168] = {
			name = "Power Plant",
			icon = RouteData.Icons.BuildingDoorSmall,
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
		[177] = {
			name = "S.S. Anne Rooms",
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
			trainers = { 483, 127, 223, 482, 422, 421, 126, 96 }, -- Untested
		},
		[178] = {
			name = "S.S. Anne Rooms",
			icon = RouteData.Icons.BuildingDoorSmall,
			area = RouteData.CombinedAreas.SSAnne,
			dungeon = true,
			trainers = { 138, 139, 224, 140, 136, 137 }, -- Untested
		},
		[212] = {
			name = "Indigo Plateau PC",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[213] = {
			name = "Lorelei's Room",
			icon = RouteData.Icons.EliteFourStatue,
			area = RouteData.CombinedAreas.EliteFour,
			dungeon = true,
			trainers = { 410 },
		},
		[214] = {
			name = "Bruno's Room",
			icon = RouteData.Icons.EliteFourStatue,
			area = RouteData.CombinedAreas.EliteFour,
			dungeon = true,
			trainers = { 411 },
		},
		[215] = {
			name = "Agatha's Room",
			icon = RouteData.Icons.EliteFourStatue,
			area = RouteData.CombinedAreas.EliteFour,
			dungeon = true,
			trainers = { 412 },
		},
		[216] = {
			name = "Lance's Room",
			icon = RouteData.Icons.EliteFourStatue,
			area = RouteData.CombinedAreas.EliteFour,
			dungeon = true,
			trainers = { 413 },
		},
		[217] = {
			name = "Champion's Room",
			icon = RouteData.Icons.EliteFourStatue,
			area = RouteData.CombinedAreas.EliteFour,
			dungeon = true,
			trainers = { 438, 439, 440 },
		},
		[219] = {
			name = "Route 21 South",
			icon = RouteData.Icons.RouteSignWooden,
			trainers = { 230, 232, 246, 247, 248 },
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
		[228] = {
			name = "Dojo",
			icon = RouteData.Icons.BuildingDoorSmall,
			dungeon = true,
			trainers = { 321, 319, 320, 318, 317 },
		},
		-- [[Sevii Isles]]
		[230] = {
			name = "One Island",
			icon = RouteData.Icons.RouteSign,
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
		[232] = {
			name = "Three Island",
			icon = RouteData.Icons.RouteSign,
			trainers = { 527, 528, 529, 742 },
		},
		[233] = {
			name = "Four Island",
			icon = RouteData.Icons.RouteSign,
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
		[234] = {
			name = "Five Island",
			icon = RouteData.Icons.RouteSign,
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
		[237] = {
			name = "Kindle Road",
			icon = RouteData.Icons.RouteSign,
			trainers = { 547, 548, 549, 550, 551, 518, 552, 553, 554, 555, 556, 557 },
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
		[238] = {
			name = "Treasure Beach",
			icon = RouteData.Icons.RouteSign,
			trainers = { 546 },
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
		[239] = {
			name = "Cape Brink",
			icon = RouteData.Icons.RouteSign,
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
		[240] = {
			name = "Bond Bridge", -- 007, license to kill your sub-500BST survival run
			icon = RouteData.Icons.RouteSign,
			trainers = { 523, 558, 519, 559, 561, 560 },
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
		[241] = {
			name = "Three Isle Port",
			icon = RouteData.Icons.RouteSign,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 206, rate = 1.00, minLv = 5, maxLv = 35, },
			},
		},
		[246] = {
			name = "Resort Gorgeous",
			icon = RouteData.Icons.RouteSign,
			trainers = { 526, 562, 563, 525, 564, 565, 566 },
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
		[247] = {
			name = "Water Labyrinth",
			icon = RouteData.Icons.OceanWaves,
			trainers = { 520 },
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
		[248] = {
			name = "Five Isle Meadow",
			icon = RouteData.Icons.RouteSign,
			trainers = { 567, 568, 569 },
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
		[249] = {
			name = "Memorial Pillar",
			icon = RouteData.Icons.RouteSign,
			trainers = { 570, 571, 572 },
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
		[250] = {
			name = "Outcast Island",
			icon = RouteData.Icons.RouteSign,
			trainers = { 573, 574, 575, 576, 540 },
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
		[251] = {
			name = "Green Path",
			icon = RouteData.Icons.RouteSign,
			trainers = { 517 },
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
		[252] = {
			name = "Water Path",
			icon = RouteData.Icons.RouteSign,
			trainers = { 577, 291, 578, 579, 580, 581 },
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
		[253] = {
			name = "Ruin Valley",
			icon = RouteData.Icons.RouteSign,
			trainers = { 524, 582, 583, 584, 585 },
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
		[254] = {
			name = "Trainer Tower",
			icon = RouteData.Icons.RouteSign,
			trainers = { 586, 587 },
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
		[255] = {
			name = "Canyon Entrance",
			icon = RouteData.Icons.RouteSign,
			trainers = { 588, 589, 590, 521, 522 },
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
		[256] = {
			name = "Sevault Canyon",
			icon = RouteData.Icons.RouteSign,
			trainers = { 591, 593, 596, 598, 599, 600, 601 },
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
		[257] = {
			name = "Tanoby Ruins",
			icon = RouteData.Icons.RouteSign,
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
		[270] = {
			name = "Berry Forest",
			icon = RouteData.Icons.ForestTree,
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
		[271] = {
			name = "One Island PC",
			icon = RouteData.Icons.BuildingDoorSmall,
		},
		[280] = {
			name = "Mt. Ember Base",
			icon = RouteData.Icons.MountainTop,
			trainers = { 537, 538, 595, 597, 592 },
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
		[281] = {
			name = "Mt. Ember Summit",
			icon = RouteData.Icons.MountainTop,
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 146, rate = 1.00, minLv = 50, maxLv = 50, },
			},
		},
		[282] = {
			name = "Summit Path 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SummitPath,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 66, rate = 0.50, minLv = 31, maxLv = 39, },
				{ pokemonID = 74, rate = 0.50, minLv = 29, maxLv = 37, },
			},
		},
		[283] = {
			name = "Summit Path 2F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SummitPath,
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
		[284] = {
			name = "Summit Path 3F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.SummitPath,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 66, rate = 0.50, minLv = 31, maxLv = 39, },
				{ pokemonID = 74, rate = 0.50, minLv = 29, maxLv = 37, },
			},
		},
		[285] = {
			name = "Ruby Path 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RubyPath,
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
		[286] = {
			name = "Ruby Path B1F- a",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RubyPath,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.70, minLv = 34, maxLv = 42, },
				{ pokemonID = 218, rate = 0.30, minLv = 24, maxLv = 30, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[287] = {
			name = "Ruby Path B2F- a",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RubyPath,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 218, rate = 0.60, minLv = 22, maxLv = 32, },
				{ pokemonID = 74, rate = 0.40, minLv = 40, maxLv = 44, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[288] = {
			name = "Ruby Path B3F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RubyPath,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 218, rate = 1.00, minLv = 18, maxLv = 36, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 218, rate = 0.90, minLv = 15, maxLv = 35, },
				{ pokemonID = 219, rate = 0.10, minLv = 25, maxLv = 45, },
			},
		},
		-- These two are the tiny rooms on the quick way back from B5F
		[289] = {
			name = "Ruby Path B1F- b",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RubyPath,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 74, rate = 0.70, minLv = 34, maxLv = 42, },
				{ pokemonID = 218, rate = 0.30, minLv = 24, maxLv = 30, },
			},
			[RouteData.EncounterArea.ROCKSMASH] = {
				{ pokemonID = 74, rate = 0.65, minLv = 25, maxLv = 40, },
				{ pokemonID = 75, rate = 0.35, minLv = 30, maxLv = 50, },
			},
		},
		[290] = {
			name = "Ruby Path B2F- b",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.RubyPath,
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
		[292] = {
			name = "Rocket Warehouse",
			icon = RouteData.Icons.BuildingDoorSmall,
			dungeon = true,
			trainers = { 545, 541, 542, 544, 516, 543 },
		},
		[293] = {
			name = "Icefall Cave Entrance",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.IcefallCave,
			dungeon = true,
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
		[294] = {
			name = "Icefall Cave 1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.IcefallCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 220, rate = 0.50, minLv = 23, maxLv = 31, },
				{ pokemonID = 42, rate = 0.25, minLv = 45, maxLv = 48, },
				{ pokemonID = 41, rate = 0.10, minLv = 40, maxLv = 40, },
				{ pokemonID = 86, rate = 0.10, minLv = 45, maxLv = 45, },
				{ pokemonID = {225,215}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[295] = {
			name = "Icefall Cave B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.IcefallCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 220, rate = 0.50, minLv = 23, maxLv = 31, },
				{ pokemonID = 42, rate = 0.25, minLv = 45, maxLv = 48, },
				{ pokemonID = 41, rate = 0.10, minLv = 40, maxLv = 40, },
				{ pokemonID = 86, rate = 0.10, minLv = 45, maxLv = 45, },
				{ pokemonID = {225,215}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[296] = {
			name = "Icefall Cave Back",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.IcefallCave,
			dungeon = true,
			trainers = { 539 },
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
		[298] = {
			name = "Trainer Tower 1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[299] = {
			name = "Trainer Tower 2F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[300] = {
			name = "Trainer Tower 3F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[301] = {
			name = "Trainer Tower 4F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[302] = {
			name = "Trainer Tower 5F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[303] = {
			name = "Trainer Tower 6F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[304] = {
			name = "Trainer Tower 7F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[305] = {
			name = "Trainer Tower 8F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.TrainerTower,
			dungeon = true,
		},
		[317] = {
			name = "Pattern Bush",
			icon = RouteData.Icons.ForestTree,
			trainers = { 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620 },
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
		[321] = {
			name = "Lost Cave Room 1",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			trainers = { 607 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[322] = {
			name = "Lost Cave Room 2",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[323] = {
			name = "Lost Cave Room 3",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[324] = {
			name = "Lost Cave Room 4",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			trainers = { 608 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[325] = {
			name = "Lost Cave Room 5",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[326] = {
			name = "Lost Cave Room 6",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[327] = {
			name = "Lost Cave Room 7",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[328] = {
			name = "Lost Cave Room 8",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[329] = {
			name = "Lost Cave Room 9",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[330] = {
			name = "Lost Cave Room 10",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			trainers = { 606 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 92, rate = 0.25, minLv = 38, maxLv = 40, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 42, rate = 0.20, minLv = 41, maxLv = 43, },
				{ pokemonID = {198,200}, rate = 0.05, minLv = 22, maxLv = 22, },
			},
		},
		[331] = {
			name = "Lost Cave Room 11",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[332] = {
			name = "Lost Cave Room 12",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[333] = {
			name = "Lost Cave Room 13",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[334] = {
			name = "Lost Cave Room 14",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.LostCave,
			dungeon = true,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 93, rate = 0.30, minLv = 44, maxLv = 52, },
				{ pokemonID = 41, rate = 0.20, minLv = 37, maxLv = 37, },
				{ pokemonID = 92, rate = 0.20, minLv = 40, maxLv = 40, },
				{ pokemonID = {198,200}, rate = 0.20, minLv = 15, maxLv = 22, },
				{ pokemonID = 42, rate = 0.10, minLv = 41, maxLv = 41, },
			},
		},
		[335] = {
			name = "Monean Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[336] = {
			name = "Liptoo Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[337] = {
			name = "Weepth Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[338] = {
			name = "Dilford Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[339] = {
			name = "Scufib Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[340] = {
			name = "Altering Cave",
			icon = RouteData.Icons.CaveEntrance,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 1.00, minLv = 6, maxLv = 16, },
			},
		},
		[342] = {
			name = "Birth Island",
			icon = RouteData.Icons.RouteSign,
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 386, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[345] = {
			name = "Navel Rock Summit",
			icon = RouteData.Icons.MountainTop,
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 250, rate = 1.00, minLv = 70, maxLv = 70, },
			},
		},
		[346] = {
			name = "Navel Rock Base",
			icon = RouteData.Icons.CaveEntrance,
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 249, rate = 1.00, minLv = 70, maxLv = 70, },
			},
		},
		[362] = {
			name = "Rixy Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 201, rate = 1.00, minLv = 25, maxLv = 25, },
			},
		},
		[363] = {
			name = "Viapois Chamber",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.TanobyChambers,
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
	local isGameEmerald = (GameSettings.versioncolor == "Emerald")
	local offset = Utils.inlineIf(isGameEmerald, 0, 1)

	RouteData.Locations.CanPCHeal = {
		[54] = true, -- Brendan's house
		[56] = true, -- May's house
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
	RouteData.Locations.IsInSafariZone = {
		[238 + offset] = true,
		[239 + offset] = true,
		[240 + offset] = true,
		[241 + offset] = true,
	}
	RouteData.Locations.EarlyGameCity = {
		[1] = true, -- Petalburg City
		[4] = true, -- Rustboro City
		[10] = true, -- Littleroot Town
		[11] = true, -- Oldale Town
	}
	if isGameEmerald then
		-- In Emerald, Ironmon ends after Steven battle, not e4.
		RouteData.Locations.IsInHallOfFame = {
			[431] = true,
		}
		-- Two additional Safari Zone areas in Emerald
		RouteData.Locations.IsInSafariZone[394] = true
		RouteData.Locations.IsInSafariZone[395] = true
	else
		RouteData.Locations.IsInHallOfFame = {
			[298 + offset] = true,
		}
	end

	-- [AreaName] = { combained list of mapIds }
	RouteData.CombinedAreas = {
		GraniteCave = { name = "Granite Cave", dungeon = true },
		OceanicMuseum = { name = "Oceanic Museum" },
		TrickHouse = { name = "Trick House", dungeon = true },
		MeteorFalls = { name = "Meteor Falls", dungeon = true },
		LavaridgeGym = { name = "Lavaridge Gym", dungeon = true },
		MirageTower = { name = "Mirage Tower" },
		AbandonedShip = { name = "Abandoned Ship", dungeon = true },
		WeatherInstitute = { name = "Weather Institute", dungeon = true },
		MtPyre = { name = "Mt. Pyre", dungeon = true },
		MagmaHideout = { name = "Magma Hideout", dungeon = true },
		AquaHideout = { name = "Aqua Hideout", dungeon = true },
		SpaceCenter = { name = "Space Center", dungeon = true },
		CaveOrigin = { name = "Cave of Origin" },
		SootopolisGym = { name = "Sootopolis Gym", dungeon = true },
		SkyPillar = { name = "Sky Pillar" },
		VictoryRoad = { name = "Victory Road", dungeon = true },
		EliteFour = { name = "Elite Four (Ever Grande City)", dungeon = true },
		SSTidal = { name = "S.S. Tidal", dungeon = true },
		SeafloorCavern = { name = "Seafloor Cavern", dungeon = true },
		ShoalCave = { name = "Shoal Cave" },
		NewMauville = { name = "New Mauville", dungeon = true },
		SafariZone = { name = "Safari Zone" },
		ArtisanCave = { name = "Artisan Cave" },
		NavelRock = { name = "Navel Rock" },
	}

	RouteData.Info = {}

	RouteData.Info[1] = {
		name = "Petalburg City",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 1.00, minLv = 5, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 341, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 341, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[2] = {
		name = "Slateport City",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[3] = {
		name = "Mauville City",
		icon = RouteData.Icons.CityMap,
		trainers = { 656 },
	}
	RouteData.Info[4] = {
		name = "Rustboro City",
		icon = RouteData.Icons.CityMap,
		trainers = { 592, 593, 599, 600, 768, 769, },
	}
	-- No Rivals in Ruby/Sapphire
	if not isGameEmerald then
		RouteData.Info[4].trainers = nil
	end
	RouteData.Info[5] = {
		name = "Fortree City",
		icon = RouteData.Icons.CityMap,
	}
	RouteData.Info[6] = {
		name = "Lilycove City",
		icon = RouteData.Icons.CityMap,
		trainers = { 661, 662, 663, 664, 665, 666 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.85, minLv = 25, maxLv = 45, },
			{ pokemonID = 120, rate = 0.15, minLv = 25, maxLv = 30, },
		},
	}
	RouteData.Info[7] = {
		name = "Mossdeep City",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[8] = {
		name = "Sootopolis City",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 1.00, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 129, rate = 0.80, minLv = 30, maxLv = 35, },
			{ pokemonID = 130, rate = 0.20, minLv = 5, maxLv = 45, },
		},
	}
	RouteData.Info[9] = {
		name = "Ever Grande City",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 370, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, minLv = 30, maxLv = 45, },
			{ pokemonID = 370, rate = 0.40, minLv = 30, maxLv = 35, },
			{ pokemonID = 222, rate = 0.15, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[10] = {
		name = "Littleroot Town",
		icon = RouteData.Icons.CityMap,
	}
	RouteData.Info[11] = {
		name = "Oldale Town",
		icon = RouteData.Icons.CityMap,
	}
	RouteData.Info[12] = {
		name = "Dewford Town",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[13] = {
		name = "Lavaridge Town",
		icon = RouteData.Icons.CityMap,
	}
	RouteData.Info[14] = {
		name = "Fallarbor Town",
		icon = RouteData.Icons.CityMap,
	}
	RouteData.Info[15] = {
		name = "Verdanturf City",
		icon = RouteData.Icons.CityMap,
	}
	RouteData.Info[16] = {
		name = "Pacifidlog Town",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[17] = {
		name = "Route 101",
		icon = RouteData.Icons.RouteSignWooden,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.45, minLv = 2, maxLv = 3, },
			{ pokemonID = 265, rate = 0.45, minLv = 2, maxLv = 3, },
			{ pokemonID = {261,261,263}, rate = 0.10, minLv = 2, maxLv = 3, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = {261,261,263}, rate = 1.00, minLv = 2, maxLv = 2, },
		},
	}
	RouteData.Info[18] = {
		name = "Route 102",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 318, 615, 333, 603, },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.30, minLv = 3, maxLv = 4, },
			{ pokemonID = 265, rate = 0.30, minLv = 3, maxLv = 4, },
			{ pokemonID = {273,270,270}, rate = 0.20, minLv = 3, maxLv = 4, },
			{ pokemonID = {261,261,263}, rate = 0.15, minLv = 3, maxLv = 4, },
			{ pokemonID = 280, rate = 0.04, minLv = 4, maxLv = 4, },
			{ pokemonID = {283,283,273}, rate = 0.01, minLv = 3, maxLv = 3, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, minLv = 5, maxLv = 35, },
			{ pokemonID = {283,283,118}, rate = 0.01, minLv = 20, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 341, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 341, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[19] = {
		name = "Route 103",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 520, 523, 526, 529, 532, 535, 36, 481, 293, 336, 703, 702, 736, 735 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.60, minLv = 2, maxLv = 4, },
			{ pokemonID = {261,261,263}, rate = {0.30,0.30,0.20}, minLv = {2,2,3}, maxLv = 4, },
			{ pokemonID = 278, rate = {0.10,0.10,0.20}, minLv = 2, maxLv = 4, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[20] = {
		name = "Route 104",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 319, 696, 114, 136, 604, 483, 337 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = {0.50,0.50,0.40}, minLv = 4, maxLv = 5, },
			{ pokemonID = {-1,-1,183}, rate = 0.20, minLv = 4, maxLv = 5, },
			{ pokemonID = 265, rate = {0.30,0.30,0.20}, minLv = 4, maxLv = {5,5,4}, },
			{ pokemonID = 276, rate = 0.10, minLv = 4, maxLv = 5, },
			{ pokemonID = 278, rate = 0.10, minLv = 3, maxLv = 5, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 278, rate = 0.95, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 1.00, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 1.00, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 129, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[21] = {
		name = "Route 105",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 442, 152, 46, 441, 737, 738, 151 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 378, rate = 1.00, minLv = 40, maxLv = 40, },
		},
	}
	RouteData.Info[22] = {
		name = "Route 106",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 340, 339, 153, 443 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[23] = {
		name = "Route 107",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 444, 155, 692, 154, 445, 739 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[24] = {
		name = "Route 108",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 447, 157, 446, 741, 740, 156 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[25] = {
		name = "Route 109",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 490, 491, 697, 64, 57, 698, 58, 59, 158, 448, 345, 742, 680 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[26] = {
		name = "Route 110",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 302, 699, 334, 512, 700, 232, 701, 521, 524, 527, 530, 533, 536, 243, 358, 352, 353, 359, 351 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 309, rate = 0.30, minLv = 12, maxLv = 13, },
			{ pokemonID = {263,263,261}, rate = 0.20, minLv = 12, maxLv = 12, },
			{ pokemonID = {312,311,312}, rate = 0.15, minLv = 13, maxLv = 13, },
			{ pokemonID = 316, rate = 0.15, minLv = 12, maxLv = 13, },
			{ pokemonID = 43, rate = 0.10, minLv = 13, maxLv = 13, },
			{ pokemonID = 278, rate = 0.08, minLv = 12, maxLv = 12, },
			{ pokemonID = {311,312,311}, rate = 0.02, minLv = 12, maxLv = 13, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[27] = {
		name = "Route 111",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 704, 705, 706, 707, 51, 476, 218, 292, 299, 606, 312, 78, 94, 189, 469, 212, 211, 470, 44, 743, 744, 745 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.35, minLv = 19, maxLv = 21, },
			{ pokemonID = 328, rate = 0.35, minLv = 19, maxLv = 21, },
			{ pokemonID = {331,331,343}, rate = {0.20,0.20,0.24}, minLv = 19, maxLv = 21, },
			{ pokemonID = {343,343,331}, rate = {0.10,0.10,0.06}, minLv = 20, maxLv = 22, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, minLv = 5, maxLv = 20, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, minLv = 5, maxLv = 35, },
			{ pokemonID = {283,283,118}, rate = 0.01, minLv = 20, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, minLv = 20, maxLv = 45, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 377, rate = 1.00, minLv = 40, maxLv = 40, },
		},
	}
	RouteData.Info[28] = {
		name = "Route 112",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 213, 471, 627, 626, 746, 747 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.75, minLv = 14, maxLv = 16, },
			{ pokemonID = {66,66,183}, rate = 0.25, minLv = 14, maxLv = 16, },
		},
	}
	RouteData.Info[29] = {
		name = "Route 113",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 326, 710, 420, 711, 434, 677, 419, 327, 708, 709 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 327, rate = 0.70, minLv = 14, maxLv = 16, },
			{ pokemonID = {27,27,218}, rate = 0.25, minLv = 14, maxLv = 16, },
			{ pokemonID = 227, rate = 0.05, minLv = 16, maxLv = 16, },
		},
	}
	RouteData.Info[30] = {
		name = "Route 114",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 342, 714, 713, 338, 472, 679, 214, 143, 206, 629, 712, 628 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 333, rate = 0.40, minLv = 15, maxLv = 17, },
			{ pokemonID = {273,270,270}, rate = 0.30, minLv = 15, maxLv = 16, },
			{ pokemonID = {335,336,271}, rate = {0.19,0.19,0.20}, minLv = {15,15,16}, maxLv = {17,17,18}, },
			{ pokemonID = {274,271,336}, rate = {0.10,0.10,0.09}, minLv = {16,16,15}, maxLv = {18,18,17}, },
			{ pokemonID = {283,283,274}, rate = 0.01, minLv = 15, maxLv = 15, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, minLv = 5, maxLv = 20, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, minLv = 5, maxLv = 35, },
			{ pokemonID = {283,283,118}, rate = 0.01, minLv = 20, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[31] = {
		name = "Route 115",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 183, 513, 752, 427, 749, 307, 748, 182, 751, 750 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 276, rate = 0.40, minLv = 23, maxLv = 25, },
			{ pokemonID = 333, rate = 0.30, minLv = 23, maxLv = 25, },
			{ pokemonID = 39, rate = 0.10, minLv = 24, maxLv = 25, },
			{ pokemonID = 277, rate = 0.10, minLv = 25, maxLv = 25, },
			{ pokemonID = 278, rate = 0.10, minLv = 24, maxLv = 26, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[32] = {
		name = "Route 116",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 617, 322, 280, 631, 754, 753, 695, 694, 273, 605, },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {293,293,261}, rate = {0.30,0.30,0.28}, minLv = {6,6,6}, maxLv = {7,7,8}, },
			{ pokemonID = {263,263,293}, rate = {0.28,0.28,0.20}, minLv = {6,6,6}, maxLv = {8,8,6}, },
			{ pokemonID = 276, rate = 0.20, minLv = 6, maxLv = 8, },
			{ pokemonID = 290, rate = 0.20, minLv = 6, maxLv = 7, },
			{ pokemonID = {-1,-1,63}, rate = 0.10, minLv = {-1,-1,7}, maxLv = {-1,-1,7}, },
			{ pokemonID = 300, rate = 0.02, minLv = 7, maxLv = 8, },
		},
	}
	RouteData.Info[33] = {
		name = "Route 117",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 364, 287, 538, 369, 227, 756, 755, 757, 545 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,43}, rate = {0.30,0.30,0.40}, minLv = 13, maxLv = 14, },
			{ pokemonID = {315,315,261}, rate = 0.30, minLv = 13, maxLv = 14, },
			{ pokemonID = {314,313,314}, rate = 0.18, minLv = 13, maxLv = 14, },
			{ pokemonID = {43,43,-1}, rate = 0.10, minLv = {13,13,-1}, maxLv = {13,13,-1}, },
			{ pokemonID = 183, rate = 0.10, minLv = 13, maxLv = 13, },
			{ pokemonID = {313,314,313}, rate = 0.01, minLv = 13, maxLv = 13, },
			{ pokemonID = {283,283,273}, rate = 0.01, minLv = 13, maxLv = 13, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, minLv = 5, maxLv = 35, },
			{ pokemonID = {283,283,118}, rate = 0.01, minLv = 20, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 341, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 341, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[34] = {
		name = "Route 118",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 37, 715, 344, 196, 52, 343, 408, 398 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 263, rate = 0.30, minLv = 24, maxLv = 26, },
			{ pokemonID = 309, rate = 0.30, minLv = 24, maxLv = 26, },
			{ pokemonID = 278, rate = 0.19, minLv = 25, maxLv = 27, },
			{ pokemonID = 264, rate = 0.10, minLv = 26, maxLv = 26, },
			{ pokemonID = 310, rate = 0.10, minLv = 26, maxLv = 26, },
			{ pokemonID = 352, rate = 0.01, minLv = 25, maxLv = 25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 318, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 318, rate = 0.60, minLv = 20, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[35] = {
		name = "Route 119",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 620, 224, 619, 225, 618, 223, 693, 559, 552, 761, 400, 416, 760, 399, 759, 415, 651, 522, 525, 528, 531, 534, 537 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, minLv = 20, maxLv = 45, },
			{ pokemonID = 263, rate = 0.30, minLv = 20, maxLv = 45, },
			{ pokemonID = 264, rate = 0.30, minLv = 20, maxLv = 45, },
			{ pokemonID = 357, rate = 0.09, minLv = 20, maxLv = 45, },
			{ pokemonID = 352, rate = 0.01, minLv = 20, maxLv = 45, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
			{ pokemonID = 349, rate = 0.00, minLv = 20, maxLv = 25, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 318, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 349, rate = 0.00, minLv = 20, maxLv = 25, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 318, rate = 1.00, minLv = 20, maxLv = 45, },
			{ pokemonID = 349, rate = 0.00, minLv = 20, maxLv = 25, },
		},
	}
	RouteData.Info[36] = {
		name = "Route 120",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 435, 53, 406, 405, 762, 436, 653, 763, 95, 560, 553, 226, 652, 45 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {264,264,262}, rate = 0.30, minLv = 25, maxLv = 27, },
			{ pokemonID = 43, rate = 0.25, minLv = 25, maxLv = 27, },
			{ pokemonID = {263,263,261}, rate = 0.20, minLv = 25, maxLv = 25, },
			{ pokemonID = 183, rate = 0.15, minLv = 25, maxLv = 27, },
			{ pokemonID = 359, rate = 0.08, minLv = 25, maxLv = 27, },
			{ pokemonID = {283,283,273}, rate = 0.01, minLv = 25, maxLv = 25, },
			{ pokemonID = 352, rate = 0.01, minLv = 25, maxLv = 25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 183, rate = 0.99, minLv = 5, maxLv = 35, },
			{ pokemonID = {283,283,118}, rate = 0.01, minLv = 20, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, minLv = 20, maxLv = 45, },
		},
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 379, rate = 1.00, minLv = 40, maxLv = 40, },
		},
	}
	RouteData.Info[37] = {
		name = "Route 121",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 764, 107, 127, 286, 766, 765, 254, 300, 11, 767 } -- E
			or { 764, 107, 127, 286, 766, 765, 254, 300, 767 }, -- RS
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.30, minLv = 26, maxLv = 28, },
			{ pokemonID = {263,263,261}, rate = 0.20, minLv = 26, maxLv = 26, },
			{ pokemonID = {264,264,262}, rate = 0.20, minLv = 26, maxLv = 28, },
			{ pokemonID = 43, rate = 0.15, minLv = 26, maxLv = 28, },
			{ pokemonID = 278, rate = 0.09, minLv = 26, maxLv = 28, },
			{ pokemonID = 44, rate = 0.05, minLv = 28, maxLv = 28, },
			{ pokemonID = 352, rate = 0.01, minLv = 25, maxLv = 25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[38] = {
		name = "Route 122",
		icon = RouteData.Icons.RouteSignWooden,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[39] = {
		name = "Route 123",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 539, 503, 39, 484, 106, 13, 92, 75, 195, 12, 249, 29, 238, 504, 505 }
			or { 39, 484, 106, 92, 75, 195, 249, 238 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.30, minLv = 26, maxLv = 28, },
			{ pokemonID = {263,263,261}, rate = 0.20, minLv = 26, maxLv = 26, },
			{ pokemonID = {264,264,262}, rate = 0.20, minLv = 26, maxLv = 28, },
			{ pokemonID = 43, rate = 0.15, minLv = 26, maxLv = 28, },
			{ pokemonID = 278, rate = 0.09, minLv = 26, maxLv = 28, },
			{ pokemonID = 44, rate = 0.05, minLv = 28, maxLv = 28, },
			{ pokemonID = 352, rate = 0.01, minLv = 25, maxLv = 25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[40] = {
		name = "Route 124",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 450, 15, 687, 159, 449, 174, 595, 160 }
			or { 450, 687, 159, 449, 174, 160 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[274] = {
		name = "Route 124 Water",
		icon = RouteData.Icons.OceanWaves,
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, minLv = 20, maxLv = 35, },
			{ pokemonID = 170, rate = 0.30, minLv = 20, maxLv = 30, },
			{ pokemonID = 369, rate = 0.05, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[41] = {
		name = "Route 125",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 492, 161, 452, 451, 403, 506, 162, 678 }
			or { 492, 161, 452, 451, 403, 162, 678 } ,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[42] = {
		name = "Route 126",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 576, 383, 164, 453, 163, 459, 377, 454 }
			or { 383, 164, 453, 163, 459, 377, 454 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[51] = {
		name = "Route 126 Water",
		icon = RouteData.Icons.OceanWaves,
		[RouteData.EncounterArea.UNDERWATER] = {
			{ pokemonID = 366, rate = 0.65, minLv = 20, maxLv = 35, },
			{ pokemonID = 170, rate = 0.30, minLv = 20, maxLv = 30, },
			{ pokemonID = 369, rate = 0.05, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[43] = {
		name = "Route 127",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 674, 577, 667, 669, 668, 374, 672, 384 }
			or { 674, 667, 669, 668, 374, 672, 384 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[52] = {
		name = "Route 127 Water",
		icon = RouteData.Icons.OceanWaves,
	}
	RouteData.Info[44] = {
		name = "Route 128",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 671, 670, 673, 376, 386, 464, 578 }
			or { 671, 670, 673, 376, 386, 464 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 370, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, minLv = 30, maxLv = 45, },
			{ pokemonID = 370, rate = 0.40, minLv = 30, maxLv = 35, },
			{ pokemonID = 222, rate = 0.15, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[53] = {
		name = "Route 128 Water",
		icon = RouteData.Icons.OceanWaves,
	}
	RouteData.Info[45] = {
		name = "Route 129",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 675, 378, 387, 580, 676 }
			or { 675, 378, 387, 676 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.04, minLv = 25, maxLv = 30, },
			{ pokemonID = 321, rate = 0.01, minLv = {35,25,25}, maxLv = {40,30,30}, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[46] = {
		name = "Route 130", -- Mirage Island?
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 165, 455, 168 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 360, rate = 1.00, minLv = 5, maxLv = 50, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[47] = {
		name = "Route 131",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = { 171, 385, 166, 457, 167, 456, 686 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.60, minLv = 25, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
		},
	}
	RouteData.Info[48] = {
		name = "Route 132",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 169, 458, 350, 181, 594, 733, 758, 598 }
			or { 169, 458, 350, 181 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, minLv = 30, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
			{ pokemonID = 116, rate = 0.15, minLv = 25, maxLv = 30, },
		},
	}
	RouteData.Info[49] = {
		name = "Route 133",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 461, 414, 511, 137, 88, 460, 170 }
			or { 461, 414, 88, 460, 170 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, minLv = 30, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
			{ pokemonID = 116, rate = 0.15, minLv = 25, maxLv = 30, },
		},
	}
	RouteData.Info[50] = {
		name = "Route 134",
		icon = RouteData.Icons.RouteSignWooden,
		trainers = isGameEmerald and { 463, 172, 180, 509, 510, 397, 508, 413, 507 }
			or { 463, 172, 180, 397, 413 },
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 278, rate = 0.35, minLv = 10, maxLv = 30, },
			{ pokemonID = 279, rate = 0.05, minLv = 25, maxLv = 30, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 0.45, minLv = 30, maxLv = 45, },
			{ pokemonID = 319, rate = 0.40, minLv = 30, maxLv = 35, },
			{ pokemonID = 116, rate = 0.15, minLv = 25, maxLv = 30, },
		},
	}

	RouteData.Info[54] = {
		name = "Brendan's House 1F",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[55] = {
		name = "Brendan's House 2F",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[56] = {
		name = "May's House 1F",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[57] = {
		name = "May's House 2F",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[58] = {
		name = "Prof. Birch's Lab",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[61] = {
		name = "Pokémon Center",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[62] = {
		name = "Pokémon Center 2F",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[63] = {
		name = "PokéMart",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[65] = {
		name = "Dewford Gym",
		icon = RouteData.Icons.GymBuilding,
		dungeon = true,
		trainers = { 426, 573, 572, 179, 574, 425, 266 },
	}
	RouteData.Info[69] = {
		name = "Lavaridge Gym 1F",
		icon = RouteData.Icons.GymBuilding,
		area = RouteData.CombinedAreas.LavaridgeGym,
		dungeon = true,
		trainers = { 202, 204, 501, 201, 648, 203, 205, 650, 268 },
	}
	RouteData.Info[70] = {
		name = "Lavaridge Gym B1F",
		icon = RouteData.Icons.GymBuilding,
		area = RouteData.CombinedAreas.LavaridgeGym,
		dungeon = true,
		-- trainers = { }, -- Combine with id=69
	}
	RouteData.Info[71] = {
		name = "Lavaridge Town PC",
		icon = RouteData.Icons.BuildingDoorSmall,
	}
	RouteData.Info[79] = {
		name = "Petalburg Gym",
		icon = RouteData.Icons.GymBuilding,
		dungeon = true,
		trainers = { 71, 89, 72, 90, 73, 91, 74, 269 },
	}
	RouteData.Info[86] = {
		name = "Oceanic Museum 1F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.OceanicMuseum,
	}
	RouteData.Info[87] = {
		name = "Oceanic Museum 2F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.OceanicMuseum,
		trainers = { 20, 21 },
	}
	RouteData.Info[89] = {
		name = "Mauville Gym",
		icon = RouteData.Icons.GymBuilding,
		dungeon = true,
		trainers = { 649, 191, 323, 802, 194, 267 },
	}
	RouteData.Info[94] = {
		name = "Rustboro Gym",
		icon = RouteData.Icons.GymBuilding,
		dungeon = true,
		trainers = { 320, 321, 571, 265 },
	}
	RouteData.Info[100] = {
		name = "Fortree Gym",
		icon = RouteData.Icons.GymBuilding,
		dungeon = true,
		trainers = { 402, 401, 655, 654, 404, 803, 270 },
	}
	RouteData.Info[108] = {
		name = "Mossdeep Gym",
		icon = RouteData.Icons.GymBuilding,
		dungeon = true,
		trainers = { 233, 246, 245, 235, 591, 584, 583, 585, 582, 234, 575, 244, 271 },
	}
	RouteData.Info[109] = {
		name = "Sootopolis Gym 1F",
		icon = RouteData.Icons.GymBuilding,
		area = RouteData.CombinedAreas.SootopolisGym,
		dungeon = true,
		trainers = { 128, 613, 115, 502, 131, 614, 301, 130, 118, 129, 272 },
	}
	RouteData.Info[110] = {
		name = "Sootopolis Gym B1F",
		icon = RouteData.Icons.GymBuilding,
		area = RouteData.CombinedAreas.SootopolisGym,
		dungeon = true,
		-- trainers = { }, -- Combine with id=109
	}
	-- Ruby/Sapphire gyms have different trainers
	if not isGameEmerald then
		RouteData.Info[65].trainers = { 426, 179, 425, 266 } -- Dewford Gym
		RouteData.Info[69].trainers = { 202, 204, 201, 648, 203, 205, 650, 268 } -- Lavaridge Gym 1F
		RouteData.Info[94].trainers = { 320, 321, 265 } -- Rustboro Gym
		RouteData.Info[108].trainers = { 233, 246, 245, 235, 234, 244, 271 } -- Mossdeep Gym
		RouteData.Info[109].trainers = { 128, 613, 115, 131, 614, 301, 130, 118, 129, 272 } -- Sootopolis Gym 1F
	end
	RouteData.Info[111] = {
		name = "Sidney's Room",
		icon = RouteData.Icons.EliteFourStatue,
		area = RouteData.CombinedAreas.EliteFour,
		dungeon = true,
		trainers = { 261 },
	}
	RouteData.Info[112] = {
		name = "Phoebe's Room",
		icon = RouteData.Icons.EliteFourStatue,
		area = RouteData.CombinedAreas.EliteFour,
		dungeon = true,
		trainers = { 262 },
	}
	RouteData.Info[113] = {
		name = "Glacia's Room",
		icon = RouteData.Icons.EliteFourStatue,
		area = RouteData.CombinedAreas.EliteFour,
		dungeon = true,
		trainers = { 263 },
	}
	RouteData.Info[114] = {
		name = "Drake's Room",
		icon = RouteData.Icons.EliteFourStatue,
		area = RouteData.CombinedAreas.EliteFour,
		dungeon = true,
		trainers = { 264 },
	}
	RouteData.Info[115] = {
		name = "Champion's Room",
		icon = RouteData.Icons.EliteFourStatue,
		area = RouteData.CombinedAreas.EliteFour,
		dungeon = true,
		trainers = { 335 },
	}
	RouteData.Info[125 + offset] = {
		name = "Meteor Falls 1F 1R",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MeteorFalls,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.80, minLv = 14, maxLv = 20, },
			{ pokemonID = {338,337,338}, rate = 0.20, minLv = 14, maxLv = 18, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 41, rate = 0.90, minLv = 5, maxLv = 35, },
			{ pokemonID = {338,337,338}, rate = 0.10, minLv = 5, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[126 + offset] = {
		name = "Meteor Falls 1F 2R",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MeteorFalls,
		dungeon = true,
		trainers = { 681, 392 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.65, minLv = 33, maxLv = 40, },
			{ pokemonID = {338,337,338}, rate = 0.35, minLv = 33, maxLv = 39, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, minLv = 30, maxLv = 35, },
			{ pokemonID = {338,337,338}, rate = 0.10, minLv = 5, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, minLv = 25, maxLv = 35, },
			{ pokemonID = 340, rate = 0.20, minLv = 30, maxLv = 45, },
		},
	}
	RouteData.Info[127 + offset] = {
		name = "Meteor Falls B1F 1R",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MeteorFalls,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.65, minLv = 33, maxLv = 40, },
			{ pokemonID = {338,337,338}, rate = 0.35, minLv = 33, maxLv = 39, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, minLv = 30, maxLv = 35, },
			{ pokemonID = {338,337,338}, rate = 0.10, minLv = 5, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, minLv = 25, maxLv = 35, },
			{ pokemonID = 340, rate = 0.20, minLv = 30, maxLv = 45, },
		},
	}
	RouteData.Info[128 + offset] = {
		name = "Meteor Falls B1F 2R",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MeteorFalls,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.50, minLv = 33, maxLv = 40, },
			{ pokemonID = {338,337,338}, rate = 0.25, minLv = 35, maxLv = 39, },
			{ pokemonID = 371, rate = 0.25, minLv = 25, maxLv = 35, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 0.90, minLv = 30, maxLv = 35, },
			{ pokemonID = {338,337,338}, rate = 0.10, minLv = 5, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, minLv = 25, maxLv = 35, },
			{ pokemonID = 340, rate = 0.20, minLv = 30, maxLv = 45, },
		},
	}
	if isGameEmerald then
		RouteData.Info[431] = {
			name = "Meteor Falls Steven",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.MeteorFalls,
			dungeon = true,
			trainers = { 804 },
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 42, rate = 0.65, minLv = 33, maxLv = 40, },
				{ pokemonID = 338, rate = 0.35, minLv = 33, maxLv = 39, },
				},
		}
	end
	RouteData.Info[129 + offset] = {
		name = "Rusturf Tunnel",
		icon = RouteData.Icons.CaveEntrance,
		trainers = { 16, 635 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 293, rate = 1.00, minLv = 5, maxLv = 8, },
		},
	}

	RouteData.Info[132 + offset] = {
		name = "Granite Cave 1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.GraniteCave,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 296, rate = 0.50, minLv = 6, maxLv = 10, },
			{ pokemonID = 41, rate = 0.30, minLv = 7, maxLv = 8, },
			{ pokemonID = 63, rate = 0.10, minLv = 8, maxLv = 8, },
			{ pokemonID = 74, rate = 0.10, minLv = 6, maxLv = 9, },
		},
	}
	RouteData.Info[133 + offset] = {
		name = "Granite Cave B1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.GraniteCave,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 304, rate = 0.40, minLv = 9, maxLv = 11, },
			{ pokemonID = 41, rate = 0.30, minLv = 9, maxLv = 10, },
			{ pokemonID = 63, rate = 0.10, minLv = 9, maxLv = 9, },
			{ pokemonID = 296, rate = 0.10, minLv = 10, maxLv = 11, },
			{ pokemonID = {303,302,302}, rate = 0.10, minLv = 9, maxLv = 11, },
		},
	}
	RouteData.Info[134 + offset] = {
		name = "Granite Cave B2F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.GraniteCave,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 304, rate = 0.40, minLv = 10, maxLv = 12, },
			{ pokemonID = 41, rate = 0.30, minLv = 10, maxLv = 11, },
			{ pokemonID = {303,302,302}, rate = 0.20, minLv = 10, maxLv = 12, },
			{ pokemonID = 296, rate = 0.10, minLv = 10, maxLv = 10, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 0.70, minLv = 5, maxLv = 20, },
			{ pokemonID = 299, rate = 0.30, minLv = 10, maxLv = 20, },
		},
	}
	RouteData.Info[288 + offset] = {
		name = "Granite Cave Steven",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.GraniteCave,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 296, rate = 0.50, minLv = 6, maxLv = 10, },
			{ pokemonID = 41, rate = 0.30, minLv = 7, maxLv = 8, },
			{ pokemonID = 63, rate = 0.10, minLv = 8, maxLv = 8, },
			{ pokemonID = 304, rate = 0.10, minLv = 7, maxLv = 8, },
		},
	}
	RouteData.Info[135 + offset] = {
		name = "Petalburg Woods",
		icon = RouteData.Icons.ForestTree,
		trainers = { 616, 10, 621 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {263,263,261}, rate = 0.30, minLv = 5, maxLv = 6, },
			{ pokemonID = 265, rate = 0.25, minLv = 5, maxLv = 6, },
			{ pokemonID = 285, rate = 0.15, minLv = 5, maxLv = 6, },
			{ pokemonID = 266, rate = 0.10, minLv = 5, maxLv = 5, },
			{ pokemonID = 268, rate = 0.10, minLv = 5, maxLv = 5, },
			{ pokemonID = 276, rate = 0.05, minLv = 5, maxLv = 6, },
			{ pokemonID = 287, rate = 0.05, minLv = 5, maxLv = 6, },
		},
	}
	RouteData.Info[136 + offset] = {
		name = "Mt. Chimney",
		icon = RouteData.Icons.MountainTop,
		trainers = isGameEmerald and { 146, 579, 597, 602, 126, 125, 313, 1, 124 }
			or { 14, 31, 35, 126, 125, 313, 124 },
	}
	RouteData.Info[137 + offset] = {
		name = "Mt. Pyre 1F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, minLv = 22, maxLv = 29, },
		},
	}
	RouteData.Info[138 + offset] = {
		name = "Mt. Pyre 2F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		trainers = isGameEmerald and { 145, 35, 31, 640 }
			or { 145, 640 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, minLv = 22, maxLv = 29, },
		},
	}
	RouteData.Info[139 + offset] = {
		name = "Mt. Pyre 3F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		trainers = isGameEmerald and { 247, 9, 236 }
			or { 247, 236 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 1.00, minLv = 22, maxLv = 29, },
		},
	}
	RouteData.Info[140 + offset] = {
		name = "Mt. Pyre 4F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		trainers = { 109 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, minLv = 22, maxLv = 29, },
			{ pokemonID = {353,355,355}, rate = 0.10, minLv = 25, maxLv = 29, },
		},
	}
	RouteData.Info[141 + offset] = {
		name = "Mt. Pyre 5F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		trainers = { 190 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, minLv = 22, maxLv = 29, },
			{ pokemonID = {353,355,355}, rate = 0.10, minLv = 25, maxLv = 29, },
		},
	}
	RouteData.Info[142 + offset] = {
		name = "Mt. Pyre 6F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		trainers = isGameEmerald and { 108, 475 }
			or { 108 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.90, minLv = 22, maxLv = 29, },
			{ pokemonID = {353,355,355}, rate = 0.10, minLv = 25, maxLv = 29, },
		},
	}
	RouteData.Info[143 + offset] = {
		name = "Aqua Hideout 1F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.AquaHideout,
		dungeon = true,
		trainers = { 2, },
	}
	RouteData.Info[144 + offset] = {
		name = "Aqua Hideout B1F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.AquaHideout,
		dungeon = true,
		trainers = isGameEmerald and { 23, 3, 192, 193 }
			or { 23, 3 },
	}
	RouteData.Info[145 + offset] = {
		name = "Aqua Hideout B2F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.AquaHideout,
		dungeon = true,
		trainers = { 24, 27, 28, 30 },
	}
	RouteData.Info[146 + offset] = {
		name = "Seafloor Cavern U.", -- Underwater
		icon = RouteData.Icons.OceanWaves,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
	}
	RouteData.Info[147 + offset] = {
		name = "Seafloor Cavern", -- Entrance
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		trainers = isGameEmerald and { 6, 7, 8, 14, 567, 33, 34 } -- All caverns combined here
			or { 6, 7, 8, 33, 34 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 41, rate = 0.35, minLv = 5, maxLv = 35, },
			{ pokemonID = 42, rate = 0.05, minLv = 30, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[148 + offset] = {
		name = "Seafloor Cavern 1",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}
	RouteData.Info[149 + offset] = {
		name = "Seafloor Cavern 2",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}
	RouteData.Info[150 + offset] = {
		name = "Seafloor Cavern 3",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}
	RouteData.Info[151 + offset] = {
		name = "Seafloor Cavern 4",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}
	RouteData.Info[152 + offset] = {
		name = "Seafloor Cavern 5",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}
	RouteData.Info[153 + offset] = {
		name = "Seafloor Cavern 6",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 41, rate = 0.35, minLv = 5, maxLv = 35, },
			{ pokemonID = 42, rate = 0.05, minLv = 30, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[154 + offset] = {
		name = "Seafloor Cavern 7",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.60, minLv = 5, maxLv = 35, },
			{ pokemonID = 41, rate = 0.35, minLv = 5, maxLv = 35, },
			{ pokemonID = 42, rate = 0.05, minLv = 30, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 72, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 72, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 320, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 320, rate = 1.00, minLv = 20, maxLv = 45, },
		},
	}
	RouteData.Info[155 + offset] = {
		name = "Seafloor Cavern 8",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
	}
	RouteData.Info[156 + offset] = {
		name = "Seafloor Cavern 9",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SeafloorCavern,
		dungeon = true,
	}
	RouteData.Info[157 + offset] = {
		name = "Cave of Origin",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.CaveOrigin,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.90, minLv = 28, maxLv = 35, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}
	RouteData.Info[158 + offset] = {
		name = "Cave of Origin 1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.CaveOrigin,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 41, rate = 0.60, minLv = 30, maxLv = 34, },
			{ pokemonID = {303,302,302}, rate = 0.30, minLv = 30, maxLv = 34, },
			{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
		},
	}

	if isGameEmerald then
		RouteData.Info[162] = {
			name = "Cave of Origin B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CaveOrigin,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, minLv = 30, maxLv = 34, },
				{ pokemonID = {-1,-1,302}, rate = 0.30, minLv = 30, maxLv = 34, },
				{ pokemonID = 42, rate = 0.10, minLv = 33, maxLv = 36, },
			},
		}
	else
		RouteData.Info[160] = {
			name = "Cave of Origin B1F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CaveOrigin,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[161] = {
			name = "Cave of Origin B2F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CaveOrigin,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[162] = {
			name = "Cave of Origin B3F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CaveOrigin,
			[RouteData.EncounterArea.LAND] = {
				{ pokemonID = 41, rate = 0.60, },
				{ pokemonID = {303,302,-1}, rate = 0.30, },
				{ pokemonID = 42, rate = 0.10, },
			},
		}
		RouteData.Info[163] = {
			name = "Cave of Origin B4F",
			icon = RouteData.Icons.CaveEntrance,
			area = RouteData.CombinedAreas.CaveOrigin,
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
	RouteData.Info[163 + offset] = {
		name = "Victory Road 1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.VictoryRoad,
		dungeon = true,
		trainers = isGameEmerald and { 80, 96, 97, 81, 100, 83, 417, 38, 99, 82, 98, 540, 546, 79, 325, 324, 519 }
			or { 80, 96, 97, 81, 100, 83, 99, 82, 98, 79, 519 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.25, minLv = 38, maxLv = 40, },
			{ pokemonID = 297, rate = 0.25, minLv = 38, maxLv = 40, },
			{ pokemonID = 41, rate = 0.10, minLv = 36, maxLv = 36, },
			{ pokemonID = 296, rate = 0.10, minLv = 36, maxLv = 36, },
			{ pokemonID = 294, rate = 0.10, minLv = 40, maxLv = 40, },
			{ pokemonID = 305, rate = 0.10, minLv = 40, maxLv = 40, },
			{ pokemonID = 293, rate = 0.05, minLv = 36, maxLv = 36, },
			{ pokemonID = 304, rate = 0.05, minLv = 36, maxLv = 36, },
		},
	}
	RouteData.Info[164 + offset] = {
		name = "Shoal Cave Lo-1",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ShoalCave,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[165 + offset] = {
		name = "Shoal Cave Lo-2",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ShoalCave,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[166 + offset] = {
		name = "Shoal Cave Lo-3",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ShoalCave,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.45, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[167 + offset] = {
		name = "Shoal Cave Lo-4",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ShoalCave,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 363, rate = 0.50, },
			{ pokemonID = 41, rate = 0.40, },
			{ pokemonID = 361, rate = 0.10, },
			{ pokemonID = 42, rate = 0.05, },
		},
	}
	RouteData.Info[168 + offset] = {
		name = "Shoal Cave Hi-1",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ShoalCave,
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
	RouteData.Info[169 + offset] = {
		name = "Shoal Cave Hi-2",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ShoalCave,
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
	RouteData.Info[184 + offset] = {
		name = "New Mauville 1",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.NewMauville,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 81, rate = 0.50, },
			{ pokemonID = 100, rate = 0.50, },
		},
	}
	RouteData.Info[185 + offset] = {
		name = "New Mauville 2",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.NewMauville,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 81, rate = 0.49, },
			{ pokemonID = 100, rate = 0.49, },
			{ pokemonID = 82, rate = 0.01, },
			{ pokemonID = 101, rate = 0.01, },
		},
	}
	RouteData.Info[186 + offset] = {
		name = "Abandoned Ship Deck",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[187 + offset] = {
		name = "Abandoned Ship 1F", -- Corridors
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[188 + offset] = {
		name = "Abandoned Ship 1F", -- Rooms
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
		trainers = isGameEmerald and { 144, 375, 66, 547, 418, 642 }
			or { 66, 642 },
	}
	RouteData.Info[189 + offset] = {
		name = "Abandoned Ship B1F", -- Corridors
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 72, rate = 0.99, },
			{ pokemonID = 73, rate = 0.01, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, },
			{ pokemonID = 72, rate = 0.30, },
		},
	}
	RouteData.Info[190 + offset] = {
		name = "Abandoned Ship B1F", -- Rooms
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
		trainers = { 496 },
	}
	RouteData.Info[191 + offset] = {
		name = "Abandoned Ship B1F", -- Rooms
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[192 + offset] = {
		name = "Abandoned Ship Uw1", -- Underwater 1
		icon = RouteData.Icons.OceanWaves,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[193 + offset] = {
		name = "Abandoned Ship B1F", -- Rooms
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[194 + offset] = {
		name = "Abandoned Ship 1F", -- Rooms
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[195 + offset] = {
		name = "Abandoned Ship Cpt", -- Captain's Office
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[196 + offset] = {
		name = "Abandoned Ship Uw2", -- Underwater 2
		icon = RouteData.Icons.OceanWaves,
		area = RouteData.CombinedAreas.AbandonedShip,
		dungeon = true,
	}
	RouteData.Info[238 + offset] = {
		name = "Safari Zone NW.",
		icon = RouteData.Icons.ForestTree,
		area = RouteData.CombinedAreas.SafariZone,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, minLv = 27, maxLv = 29, },
			{ pokemonID = 111, rate = 0.30, minLv = 27, maxLv = 29, },
			{ pokemonID = 44, rate = 0.15, minLv = 29, maxLv = 31, },
			{ pokemonID = 84, rate = 0.15, minLv = 27, maxLv = 29, },
			{ pokemonID = 85, rate = 0.05, minLv = 29, maxLv = 31, },
			{ pokemonID = 127, rate = 0.05, minLv = 27, maxLv = 29, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 54, rate = 0.95, minLv = 20, maxLv = 35, },
			{ pokemonID = 55, rate = 0.05, minLv = 25, maxLv = 40, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.40, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 118, rate = 0.80, minLv = 25, maxLv = 35, },
			{ pokemonID = 119, rate = 0.20, minLv = 25, maxLv = 40, },
		},
	}
	RouteData.Info[239 + offset] = {
		name = "Safari Zone NE.", -- North in Emerald decomp, as extension is to East
		icon = RouteData.Icons.ForestTree,
		area = RouteData.CombinedAreas.SafariZone,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.30, minLv = 27, maxLv = 29, },
			{ pokemonID = 231, rate = 0.30, minLv = 27, maxLv = 29, },
			{ pokemonID = 44, rate = 0.15, minLv = 29, maxLv = 31, },
			{ pokemonID = 177, rate = 0.15, minLv = 27, maxLv = 29, },
			{ pokemonID = 178, rate = 0.05, minLv = 29, maxLv = 31, },
			{ pokemonID = 214, rate = 0.05, minLv = 27, maxLv = 29, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 1.00, minLv = 5, maxLv = 30, },
		},
	}
	RouteData.Info[240 + offset] = {
		name = "Safari Zone SW.",
		icon = RouteData.Icons.ForestTree,
		area = RouteData.CombinedAreas.SafariZone,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.40, minLv = 25, maxLv = 27, },
			{ pokemonID = 203, rate = 0.20, minLv = 25, maxLv = 27, },
			{ pokemonID = 84, rate = 0.10, minLv = 25, maxLv = 25, },
			{ pokemonID = 177, rate = 0.10, minLv = 25, maxLv = 25, },
			{ pokemonID = 202, rate = 0.10, minLv = 27, maxLv = 29, },
			{ pokemonID = 25, rate = 0.05, minLv = 25, maxLv = 27, },
			{ pokemonID = 44, rate = 0.05, minLv = 25, maxLv = 25, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 54, rate = 1.00, minLv = 20, maxLv = 35, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.40, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 118, rate = 0.80, minLv = 25, maxLv = 35, },
			{ pokemonID = 119, rate = 0.20, minLv = 25, maxLv = 40, },
		},
	}
	RouteData.Info[241 + offset] = {
		name = "Safari Zone SE.", -- South in Emerald, as extension is to East
		icon = RouteData.Icons.ForestTree,
		area = RouteData.CombinedAreas.SafariZone,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 43, rate = 0.40, minLv = 25, maxLv = 27, },
			{ pokemonID = 203, rate = 0.20, minLv = 25, maxLv = 27, },
			{ pokemonID = 84, rate = 0.10, minLv = 25, maxLv = 25, },
			{ pokemonID = 177, rate = 0.10, minLv = 25, maxLv = 25, },
			{ pokemonID = 202, rate = 0.10, minLv = 27, maxLv = 29, },
			{ pokemonID = 25, rate = 0.05, minLv = 25, maxLv = 27, },
			{ pokemonID = 44, rate = 0.05, minLv = 25, maxLv = 25, },
		},
	}

	RouteData.Info[243 + offset] = {
		name = "Seashore House",
		icon = RouteData.Icons.BuildingDoorSmall,
		dungeon = true,
		trainers = { 65, 647, 493 },
	}
	RouteData.Info[247 + offset] = {
		name = "Trick House 1",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 611, 612, 332 },
	}
	RouteData.Info[248 + offset] = {
		name = "Trick House 2",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 274, 275, 281 },
	}
	RouteData.Info[249 + offset] = {
		name = "Trick House 3",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 215, 473, 630 },
	}
	RouteData.Info[250 + offset] = {
		name = "Trick House 4",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 188, 428, 429 },
	}
	RouteData.Info[251 + offset] = {
		name = "Trick House 5",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
	}
	RouteData.Info[252 + offset] = {
		name = "Trick House 6",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 561, 554, 407 },
	}
	RouteData.Info[253 + offset] = {
		name = "Trick House 7",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 237, 105, 248, 848, 850, 849 },
	}
	RouteData.Info[254 + offset] = {
		name = "Trick House 8",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.TrickHouse,
		dungeon = true,
		trainers = { 93, 76, 77 },
	}
	RouteData.Info[270 + offset] = {
		name = "Pokémon League PC",
		icon = RouteData.Icons.BuildingDoorLarge,
	}
	RouteData.Info[271 + offset] = {
		name = "Weather Institute 1F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.WeatherInstitute,
		dungeon = true,
		trainers = isGameEmerald and { 26, 17, 596 }
			or { 26, 17 },
	}
	RouteData.Info[272 + offset] = {
		name = "Weather Institute 2F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.WeatherInstitute,
		dungeon = true,
		trainers = { 18, 19, 32 },
	}
	if isGameEmerald then
		RouteData.Info[275 + offset] = {
			name = "City Space Center 1F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SpaceCenter,
			dungeon = true,
			trainers = { 586, 22, 587, 116 },
		}
		RouteData.Info[276 + offset] = {
			name = "City Space Center 2F",
			icon = RouteData.Icons.BuildingDoorLarge,
			area = RouteData.CombinedAreas.SpaceCenter,
			dungeon = true,
			trainers = { 588, 589, 590, 734, 514 },
		}
	end
	RouteData.Info[277 + offset] = {
		name = "S.S. Tidal Hall",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.SSTidal,
		dungeon = true,
	}
	RouteData.Info[278 + offset] = {
		name = "S.S. Tidal Deck",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.SSTidal,
		dungeon = true,
		trainers = { 494, 495 },
	}
	RouteData.Info[279 + offset] = {
		name = "S.S. Tidal Rooms",
		icon = RouteData.Icons.BuildingDoorSmall,
		area = RouteData.CombinedAreas.SSTidal,
		dungeon = true,
		trainers = { 641, 138, 255, 294, 119, 256 },
	}
	RouteData.Info[285 + offset] = {
		name = "Victory Road B1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.VictoryRoad,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.35, minLv = 38, maxLv = 42, },
			{ pokemonID = 297, rate = 0.35, minLv = 38, maxLv = 42, },
			{ pokemonID = 305, rate = {0.15,0.15,0.25}, minLv = 40, maxLv = 42, },
			{ pokemonID = {308,308,-1}, rate = 0.10, minLv = 40, maxLv = 40, },
			{ pokemonID = {307,307,303}, rate = 0.05, minLv = 38, maxLv = 38, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 74, rate = 0.70, minLv = 30, maxLv = 40, },
			{ pokemonID = 75, rate = 0.30, minLv = 30, maxLv = 40, },
		},
	}
	RouteData.Info[286 + offset] = {
		name = "Victory Road B2F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.VictoryRoad,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.35, minLv = 40, maxLv = 44, },
			{ pokemonID = {303,302,302}, rate = 0.35, minLv = 40, maxLv = 44, },
			{ pokemonID = 305, rate = {0.15,0.15,0.25}, minLv = 40, maxLv = 44, },
			{ pokemonID = {308,308,303}, rate = {0.15,0.15,0.05}, minLv = {40,40,42}, maxLv = 44, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 42, rate = 1.00, minLv = 25, maxLv = 40, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 339, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 339, rate = 0.80, minLv = 25, maxLv = 35, },
			{ pokemonID = 340, rate = 0.20, minLv = 30, maxLv = 45, },
		},
	}

	RouteData.Info[291 + offset] = {
		name = "Southern Island",
		icon = RouteData.Icons.ForestTree,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = {380,381,381}, rate = 1.00, minLv = 50, maxLv = 50, },
		},
	}
	RouteData.Info[292 + offset] = {
		name = "Jagged Pass",
		icon = RouteData.Icons.MountainTop,
		trainers = isGameEmerald and { 632, 570, 474, 217, 566, 216 }
			or { 632, 474, 216 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.55, },
			{ pokemonID = 66, rate = 0.25, },
			{ pokemonID = 325, rate = 0.20, },
		},
	}
	RouteData.Info[293 + offset] = {
		name = "Fiery Path",
		icon = RouteData.Icons.CaveEntrance,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 322, rate = 0.30, },
			{ pokemonID = {109,88,109}, rate = 0.25, },
			{ pokemonID = 324, rate = 0.18, },
			{ pokemonID = 66, rate = 0.15, },
			{ pokemonID = 218, rate = 0.10, },
			{ pokemonID = {88,109,88}, rate = 0.02, },
		},
	}

	RouteData.Info[302 + offset] = {
		name = "Mt. Pyre Ext.",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		trainers = isGameEmerald and { 5, 4, 569 } -- instead of 4,5 could be 23,24 or 27,28
			or { 5, 4 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = {0.40,0.40,0.60}, minLv = 27, maxLv = 29, },
			{ pokemonID = {307,307,-1}, rate = 0.30, minLv = 27, maxLv = 29, },
			{ pokemonID = 37, rate = {0.20,0.20,0.30}, minLv = 25, maxLv = 29, },
			{ pokemonID = 278, rate = 0.10, minLv = 26, maxLv = 28, },
		},
	}
	RouteData.Info[303 + offset] = {
		name = "Mt. Pyre Summit",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.MtPyre,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = {355,353,353}, rate = 0.85, minLv = 24, maxLv = 30, },
			{ pokemonID = {355,353,353}, rate = 0.13, minLv = 26, maxLv = 30, },
			{ pokemonID = 278, rate = 0.02, minLv = 28, maxLv = 28, },
		},
	}

	RouteData.Info[322 + offset] = {
		name = "Sky Pillar 1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SkyPillar,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.25, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
		},
	}
	RouteData.Info[324 + offset] = {
		name = "Sky Pillar 3F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SkyPillar,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.25, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
		},
	}
	RouteData.Info[330 + offset] = {
		name = "Sky Pillar 5F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.SkyPillar,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 42, rate = 0.30, },
			{ pokemonID = {303,302,302}, rate = 0.30, },
			{ pokemonID = 344, rate = 0.19, },
			{ pokemonID = {356,354,354}, rate = 0.15, },
			{ pokemonID = 334, rate = 0.06, },
		},
	}
	RouteData.Info[331 + offset] = {
		name = "Sky Pillar 6F",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.SkyPillar,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 384, rate = 1.00, },
		},
	}

	if GameSettings.versioncolor == "Ruby" then
		RouteData.swapRubySapphireTeamTrainers()
	end

	-- Ruby/Sapphire do not have maps beyond this point
	if not isGameEmerald then return 332 end

	RouteData.Info[332] = {
		name = "Battle Dome L.",
		icon = RouteData.Icons.BuildingDoorLarge,
	}
	RouteData.Info[333] = {
		name = "Battle Dome Hall",
		icon = RouteData.Icons.BuildingDoorLarge,
	}
	RouteData.Info[334] = {
		name = "Battle Dome Pre",
		icon = RouteData.Icons.BuildingDoorLarge,
	}
	RouteData.Info[335] = {
		name = "Battle Dome Room",
		icon = RouteData.Icons.BuildingDoorLarge,
		trainers = { 809, 806, 810, 805, 808, 807, 811 }, -- Not really used
	}
	RouteData.Info[336] = {
		name = "Magma Hideout 1F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		trainers = { 717, 716 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[337] = {
		name = "Magma Hideout 2Fa",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		trainers = { 718, 721, 720, 719, 727, 725, 722, 723 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[338] = {
		name = "Magma Hideout 2Fb",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[339] = {
		name = "Magma Hideout 3Fa",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		trainers = { 724, 726, 729 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[340] = {
		name = "Magma Hideout 3Fb",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[341] = {
		name = "Magma Hideout 4F",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		trainers = { 728, 730, 731, 732, 601 },
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[345] = {
		name = "Battle Frontier E.",
		icon = RouteData.Icons.CityMap,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 185, rate = 1.00, },
		},
	}
	RouteData.Info[379] = {
		name = "Magma Hideout 3Fc",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[380] = {
		name = "Magma Hideout 2Fc",
		icon = RouteData.Icons.BuildingDoorLarge,
		area = RouteData.CombinedAreas.MagmaHideout,
		dungeon = true,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 74, rate = 0.55, },
			{ pokemonID = 324, rate = 0.30, },
			{ pokemonID = 75, rate = 0.15, },
		},
	}
	RouteData.Info[381] = {
		name = "Mirage Tower 1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MirageTower,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[382] = {
		name = "Mirage Tower 2F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MirageTower,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[383] = {
		name = "Mirage Tower 3F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MirageTower,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[388] = {
		name = "Mirage Tower 4F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.MirageTower,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 27, rate = 0.50, },
			{ pokemonID = 328, rate = 0.50, },
		},
	}
	RouteData.Info[389] = {
		name = "Desert Underpass",
		icon = RouteData.Icons.CaveEntrance,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 132, rate = 0.50, },
			{ pokemonID = 293, rate = 0.34, },
			{ pokemonID = 294, rate = 0.16, },
		},
	}
	-- Emerald gets two extra safari zones unlocked to the East after Hall of Fame
	RouteData.Info[394] = {
		name = "Safari Zone N-Ext.",
		icon = RouteData.Icons.ForestTree,
		area = RouteData.CombinedAreas.SafariZone,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 190, rate = 0.30, minLv = 33, maxLv = 35, },
			{ pokemonID = 216, rate = 0.30, minLv = 34, maxLv = 36, },
			{ pokemonID = 165, rate = 0.10, minLv = 33, maxLv = 33, },
			{ pokemonID = 191, rate = 0.10, minLv = 34, maxLv = 34, },
			{ pokemonID = 163, rate = 0.05, minLv = 35, maxLv = 35, },
			{ pokemonID = 204, rate = 0.05, minLv = 34, maxLv = 34, },
			{ pokemonID = 228, rate = 0.05, minLv = 36, maxLv = 39, },
			{ pokemonID = 241, rate = 0.05, minLv = 37, maxLv = 40, },
		},
		[RouteData.EncounterArea.ROCKSMASH] = {
			{ pokemonID = 213, rate = 1.00, minLv = 20, maxLv = 40, },
		},
	}
	RouteData.Info[395] = {
		name = "Safari Zone S-Ext.",
		icon = RouteData.Icons.ForestTree,
		area = RouteData.CombinedAreas.SafariZone,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 179, rate = 0.30, minLv = 34, maxLv = 36, },
			{ pokemonID = 191, rate = 0.30, minLv = 33, maxLv = 35, },
			{ pokemonID = 167, rate = 0.10, minLv = 33, maxLv = 33, },
			{ pokemonID = 190, rate = 0.10, minLv = 34, maxLv = 34, },
			{ pokemonID = 163, rate = 0.05, minLv = 35, maxLv = 35, },
			{ pokemonID = 207, rate = 0.05, minLv = 37, maxLv = 40, },
			{ pokemonID = 209, rate = 0.05, minLv = 34, maxLv = 34, },
			{ pokemonID = 234, rate = 0.05, minLv = 36, maxLv = 39, },
		},
		[RouteData.EncounterArea.SURFING] = {
			{ pokemonID = 194, rate = 0.60, minLv = 25, maxLv = 30, },
			{ pokemonID = 183, rate = 0.39, minLv = 25, maxLv = 35, },
			{ pokemonID = 195, rate = 0.01, minLv = 35, maxLv = 40, },
		},
		[RouteData.EncounterArea.OLDROD] = {
			{ pokemonID = 129, rate = 0.70, minLv = 5, maxLv = 10, },
			{ pokemonID = 118, rate = 0.30, minLv = 5, maxLv = 10, },
		},
		[RouteData.EncounterArea.GOODROD] = {
			{ pokemonID = 129, rate = 0.60, minLv = 10, maxLv = 30, },
			{ pokemonID = 118, rate = 0.20, minLv = 10, maxLv = 30, },
			{ pokemonID = 223, rate = 0.20, minLv = 10, maxLv = 30, },
		},
		[RouteData.EncounterArea.SUPERROD] = {
			{ pokemonID = 223, rate = 0.59, minLv = 25, maxLv = 35, },
			{ pokemonID = 118, rate = 0.40, minLv = 25, maxLv = 35, },
			{ pokemonID = 224, rate = 0.01, minLv = 35, maxLv = 40, },
		},
	}
	RouteData.Info[400] = {
		name = "Artisan Cave B1F",
		icon = RouteData.Icons.CaveEntrance,
		area = RouteData.CombinedAreas.ArtisanCave,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 235, rate = 1.00, },
		},
	}
	RouteData.Info[401] = {
		name = "Artisan Cave 1F",
		icon = RouteData.Icons.CaveEntrance,
		[RouteData.EncounterArea.LAND] = {
			{ pokemonID = 235, rate = 1.00, },
		},
	}

	RouteData.Info[403] = {
		name = "Faraway Island",
		icon = RouteData.Icons.RouteSign,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 151, rate = 1.00, },
		},
	}
	RouteData.Info[404] = {
		name = "Birth Island",
		icon = RouteData.Icons.RouteSign,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 386, rate = 1.00, },
		},
	}
	RouteData.Info[409] = {
		name = "Terra Cave",
		icon = RouteData.Icons.CaveEntrance,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 383, rate = 1.00, },
		},
	}
	RouteData.Info[413] = {
		name = "Marine Cave", -- untested
		icon = RouteData.Icons.CaveEntrance,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 382, rate = 1.00, },
		},
	}
	RouteData.Info[423] = {
		name = "Navel Rock Top",
		icon = RouteData.Icons.MountainTop,
		area = RouteData.CombinedAreas.NavelRock,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 250, rate = 1.00, },
		},
	}
	RouteData.Info[424] = {
		name = "Navel Rock Bot",
		icon = RouteData.Icons.CaveEntrance,
		[RouteData.EncounterArea.STATIC] = {
			{ pokemonID = 249, rate = 1.00, },
		},
	}

	return 424
end

-- Swaps trainerIds of all Team Aqua and Team Magma story encounters
function RouteData.swapRubySapphireTeamTrainers()
	-- Trainers in routes defined using Sapphire by default, use this for alt trainer lists
	-- https://www.serebii.net/rubysapphire/teamaquamagma.shtml

	-- Team Aqua/Magma trainerIds are mirror copies of each other, just 565 apart
	local teamDiff = 565

	local teamBossMap = {
		[30] = 596,	[596] = 30, -- Matt 2 / Tabitha 2
		[31] = 597,	[597] = 31, -- Matt 1 / Tabitha 1
		[32] = 599,	[599] = 32, -- Shelly 1 / Courtney 1
		[33] = 600,	[600] = 33, -- Shelly 2 / Courtney 2
		[34] = 601,	[601] = 34, -- Archie 2 / Maxie 2
		[35] = 602,	[602] = 35, -- Archie 1 / Maxie 1
	}
	for _, route in pairs(RouteData.Info or {}) do
		for i, trainerId in ipairs(route.trainers or {}) do
			if trainerId >= 2 and trainerId <= 28 then -- Team Aqua (change to Team Magma)
				route.trainers[i] = trainerId + teamDiff
			elseif trainerId >= 567 and trainerId <= 593 then -- Team Magma (change to Team Aqua)
				route.trainers[i] = trainerId - teamDiff
			elseif teamBossMap[trainerId] then -- Swap Team Boss (admins/leader)
				route.trainers[i] = teamBossMap[trainerId]
			end
		end
	end

	-- Swap Team Hideout names
	local offset = 1 -- If emerald, this is 0. Keep variable for easier code searching
	if RouteData.Info[143 + offset].trainers[1] == 2 then
		RouteData.Info[143 + offset].name = "Aqua Hideout 1F"
		RouteData.Info[144 + offset].name = "Aqua Hideout B1F"
		RouteData.Info[145 + offset].name = "Aqua Hideout B2F"
	else
		RouteData.Info[143 + offset].name = "Magma Hideout 1F"
		RouteData.Info[144 + offset].name = "Magma Hideout B1F"
		RouteData.Info[145 + offset].name = "Magma Hideout B2F"
	end
end
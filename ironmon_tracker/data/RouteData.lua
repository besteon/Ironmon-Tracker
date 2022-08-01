RouteData = {}

-- key: mapId (mapLayoutId)
-- value: name = ('string'),
--        encounterArea = ('table')
RouteData.Info = {}

RouteData.EncounterArea = {
	GRASS = "Walking",
	SURFING = "Surfing",
	STATIC = "Static",
	ROCKSMASH = "RockSmash",
	SUPERROD = "Super Rod",
	GOODROD = "Good Rod",
	OLDROD = "Old Rod",
}

RouteData.OrderedEncounters = {
	RouteData.EncounterArea.GRASS,
	RouteData.EncounterArea.SURFING,
	RouteData.EncounterArea.STATIC,
	RouteData.EncounterArea.ROCKSMASH,
	RouteData.EncounterArea.SUPERROD,
	RouteData.EncounterArea.GOODROD,
	RouteData.EncounterArea.OLDROD,
}

function RouteData.setupRouteInfo(gameId)
	if gameId == 1 then
	elseif gameId == 2 then
	elseif gameId == 3 then
		RouteData.setupRouteInfoAsFRLG()
	end
end

function RouteData.hasRoute(mapId)
	return RouteData.Info[mapId] ~= nil and RouteData.Info[mapId] ~= {}
end

function RouteData.hasRouteEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return false end

	return RouteData.Info[mapId][encounterArea] ~= nil and RouteData.Info[mapId][encounterArea] ~= {}
end

function RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, etype in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == etype then
			startingIndex = index
			break
		end
	end

	local nextIndex = (startingIndex % #RouteData.OrderedEncounters) + 1
	while startingIndex ~= nextIndex do
		encounterArea = RouteData.OrderedEncounters[nextIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		nextIndex = (nextIndex % #RouteData.OrderedEncounters) + 1
	end

	return encounterArea
end

function RouteData.getPokemonForEncounterArea(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local pIndex = RouteData.getIndexForGameVersion()
	local pokemonEncounters = {}
	for _, encounter in pairs(RouteData.Info[mapId][encounterArea]) do
		local pokemonID
		if type(encounter.pokemonID) == "number" then
			pokemonID = encounter.pokemonID
		else -- pokemonID = {ID, ID}
			pokemonID = encounter.pokemonID[pIndex]
		end
		table.insert(pokemonEncounters, pokemonID)
	end
	return pokemonEncounters
end

-- Different game versions have different Pokemon appear in an encounterArea: pokemonID = {ID, ID}
function RouteData.getIndexForGameVersion()
	if GameSettings.versioncolor == "LeafGreen" or GameSettings.versioncolor == "Sapphire" then
		return 2
	else
		return 1
	end
end

-- https://github.com/pret/pokefirered/blob/918ed2d31eeeb036230d0912cc2527b83788bc85/include/constants/layouts.h
-- https://www.serebii.net/pokearth/kanto/3rd/route1.shtml
function RouteData.setupRouteInfoAsFRLG()
	RouteData.Info = {
		[12] = { name = "Cerulean City Gym", }, 
		[15] = { name = "Celadon City Gym", },
		[20] = { name = "Fuchsia City Gym", },
		[25] = { name = "Vermilion City Gym", },
		[28] = { name = "Pewter City Gym", },
		[34] = { name = "Saffron City Gym", },
		[36] = { name = "Cinnabar Island Gym", },
		[37] = { name = "Viridian City Gym", },
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
		[87] = { name = "Indigo Plateau Ext.", },
		[88] = { name = "Saffron City Conn.", },
		[89] = { name = "Route 1",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 16, rate = 0.50, minLv = 2, maxLv = 5, },
				{ pokemonID = 19, rate = 0.50, minLv = 2, maxLv = 4, },
			},
		},
		[90] = { name = "Route 2",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 16, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 19, rate = 0.45, minLv = 2, maxLv = 5, },
				{ pokemonID = 10, rate = 0.05, minLv = 4, maxLv = 5, },
				{ pokemonID = 13, rate = 0.05, minLv = 4, maxLv = 5, },
			},
		},
		[91] = { name = "Route 3",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 21, rate = 0.35, minLv = 6, maxLv = 8, },
				{ pokemonID = 16, rate = 0.30, minLv = 6, maxLv = 7, },
				{ pokemonID = {32,29}, rate = 0.14, minLv = 6, maxLv = 7, },
				{ pokemonID = 39, rate = 0.10, minLv = 3, maxLv = 7, },
				{ pokemonID = 56, rate = 0.10, minLv = 7, maxLv = 7, },
				{ pokemonID = {29,32}, rate = 0.01, minLv = 6, maxLv = 6, },
			},
		},
		[92] = { name = "Route 4",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 16, rate = 0.40, minLv = 13, maxLv = 16, },
				{ pokemonID = 52, rate = 0.35, minLv = 10, maxLv = 16, },
				{ pokemonID = {43,69}, rate = 0.25, minLv = 13, maxLv = 16, },
			},
		},
		[94] = { name = "Route 6",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 52, rate = 0.40, minLv = 17, maxLv = 20, },
				{ pokemonID = 16, rate = 0.30, minLv = 19, maxLv = 22, },
				{ pokemonID = {43,69}, rate = 0.20, minLv = 19, maxLv = 22, },
				{ pokemonID = {58,37}, rate = 0.10, minLv = 18, maxLv = 20, },
			},
		},
		[96] = { name = "Route 8",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 16, rate = 0.30, minLv = 18, maxLv = 20, },
				{ pokemonID = 52, rate = 0.30, minLv = 18, maxLv = 20, },
				{ pokemonID = {23,27}, rate = 0.20, minLv = 17, maxLv = 19, },
				{ pokemonID = {58,37}, rate = 0.20, minLv = 15, maxLv = 18, },
			},
		},
		[97] = { name = "Route 9",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 19, rate = 0.40, minLv = 14, maxLv = 17, },
				{ pokemonID = 21, rate = 0.35, minLv = 13, maxLv = 17, },
				{ pokemonID = {23,27}, rate = 0.25, minLv = 11, maxLv = 17, },
			},
		},
		[98] = { name = "Route 10",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 132, rate = 0.15, minLv = 23, maxLv = 23, },
				{ pokemonID = 16, rate = 0.10, minLv = 27, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 30, maxLv = 30, },
			},
		},
		[103] = { name = "Route 15",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = {43,69}, rate = 0.35, minLv = 22, maxLv = 26, },
				{ pokemonID = 48, rate = 0.30, minLv = 24, maxLv = 26, },
				{ pokemonID = 16, rate = 0.20, minLv = 25, maxLv = 27, },
				{ pokemonID = 17, rate = 0.05, minLv = 29, maxLv = 29, },
				{ pokemonID = {44,70}, rate = 0.05, minLv = 28, maxLv = 30, },
				{ pokemonID = 132, rate = 0.05, minLv = 25, maxLv = 25, },
			},
		},
		[104] = { name = "Route 16",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 84, rate = 0.35, minLv = 24, maxLv = 28, },
				{ pokemonID = 21, rate = 0.30, minLv = 20, maxLv = 22, },
				{ pokemonID = 20, rate = 0.30, minLv = 25, maxLv = 29, },
				{ pokemonID = 19, rate = 0.05, minLv = 22, maxLv = 22, },
				{ pokemonID = 22, rate = 0.05, minLv = 25, maxLv = 27, },
			},
		},
		[106] = { name = "Route 18",
			[RouteData.EncounterArea.GRASS] = {
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
		[109] = { name = "Route 21",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 41, rate = 0.69, minLv = 7, maxLv = 10, },
				{ pokemonID = 74, rate = 0.25, minLv = 7, maxLv = 9, },
				{ pokemonID = 46, rate = 0.05, minLv = 8, maxLv = 8, },
				{ pokemonID = 35, rate = 0.01, minLv = 8, maxLv = 8, },
			},
		},
		[115] = { name = "Mt. Moon B1F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 46, rate = 1.00, minLv = 5, maxLv = 10, },
			},
		},
		[116] = { name = "Mt. Moon B2F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 41, rate = 0.49, minLv = 8, maxLv = 11, },
				{ pokemonID = 74, rate = 0.30, minLv = 9, maxLv = 10, },
				{ pokemonID = 46, rate = 0.15, minLv = 10, maxLv = 12, },
				{ pokemonID = 35, rate = 0.06, minLv = 10, maxLv = 12, },
			},
		},
		[117] = { name = "Viridian Forest",
			[RouteData.EncounterArea.GRASS] = {
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
		[124] = { name = "Diglett's Cave B1F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 50, rate = 0.95, minLv = 15, maxLv = 22, },
				{ pokemonID = 51, rate = 0.05, minLv = 29, maxLv = 31, },
			},
		},
		[125] = { name = "Victory Road 1F",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
		[143] = { name = Constants.Words.POKEMON .. " Mansion 1F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[144] = { name = Constants.Words.POKEMON .. " Mansion 2F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[145] = { name = Constants.Words.POKEMON .. " Mansion 3F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 20, rate = 0.30, minLv = 32, maxLv = 36, },
				{ pokemonID = {109,88}, rate = 0.30, minLv = 28, maxLv = 30, },
				{ pokemonID = 19, rate = 0.15, minLv = 26, maxLv = 28, },
				{ pokemonID = {58,37}, rate = 0.15, minLv = 30, maxLv = 32, },
				{ pokemonID = {88,109}, rate = 0.05, minLv = 28, maxLv = 28, },
				{ pokemonID = {110,89}, rate = 0.05, minLv = 32, maxLv = 32, },
			},
		},
		[146] = { name = Constants.Words.POKEMON .. " Mansion B1F",
			[RouteData.EncounterArea.GRASS] = {
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
		[151] = { name = "Cerulean Cave 1F",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 74, rate = 0.35, minLv = 15, maxLv = 17, },
				{ pokemonID = 41, rate = 0.30, minLv = 15, maxLv = 16, },
				{ pokemonID = 56, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 66, rate = 0.15, minLv = 16, maxLv = 17, },
				{ pokemonID = 95, rate = 0.05, minLv = 13, maxLv = 15, },
			},
		},
		[155] = { name = "Rock Tunnel B1F",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = {54,79}, rate = 0.55, minLv = 26, maxLv = 33, },
				{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
				{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
			},
		},
		[157] = { name = "Seafoam Islands B1F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = {54,79}, rate = 0.40, minLv = 29, maxLv = 31, },
				{ pokemonID = 41, rate = 0.34, minLv = 22, maxLv = 26, },
				{ pokemonID = 42, rate = 0.11, minLv = 26, maxLv = 30, },
				{ pokemonID = 86, rate = 0.10, minLv = 28, maxLv = 28, },
				{ pokemonID = {55,80}, rate = 0.05, minLv = 33, maxLv = 35, },
			},
		},
		[158] = { name = "Seafoam Islands B2F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = {54,79}, rate = 0.40, minLv = 30, maxLv = 32, },
				{ pokemonID = 41, rate = 0.20, minLv = 22, maxLv = 24, },
				{ pokemonID = 86, rate = 0.20, minLv = 30, maxLv = 32, },
				{ pokemonID = 42, rate = 0.10, minLv = 26, maxLv = 30, },
				{ pokemonID = {55,80}, rate = 0.10, minLv = 32, maxLv = 34, },
			},
		},
		[159] = { name = "Seafoam Islands B3F",
			[RouteData.EncounterArea.GRASS] = {
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
			[RouteData.EncounterArea.GRASS] = {
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
		[161] = {}, -- POKEMON TOWER 1F
		[162] = {}, -- POKEMON TOWER 2F
		[163] = { name = Constants.Words.POKEMON .. " Tower 3F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 92, rate = 0.90, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.01, minLv = 20, maxLv = 20, },
			},
		},
		[164] = { name = Constants.Words.POKEMON .. " Tower 4F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
			},
		},
		[165] = { name = Constants.Words.POKEMON .. " Tower 5F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 92, rate = 0.86, minLv = 13, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 15, maxLv = 17, },
				{ pokemonID = 93, rate = 0.05, minLv = 20, maxLv = 20, },
			},
		},
		[166] = { name = Constants.Words.POKEMON .. " Tower 6F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 92, rate = 0.85, minLv = 17, maxLv = 19, },
				{ pokemonID = 104, rate = 0.09, minLv = 17, maxLv = 19, },
				{ pokemonID = 93, rate = 0.06, minLv = 21, maxLv = 23, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 105, rate = 1.00, minLv = 30, maxLv = 30, },
			},
		},
		[167] = { name = Constants.Words.POKEMON .. " Tower 7F",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 92, rate = 0.75, minLv = 15, maxLv = 19, },
				{ pokemonID = 93, rate = 0.15, minLv = 23, maxLv = 25, },
				{ pokemonID = 104, rate = 0.10, minLv = 17, maxLv = 19, },
			},
		},
		[168] = { name = "Power Plant",
			[RouteData.EncounterArea.GRASS] = {
				{ pokemonID = 81, rate = 0.30, minLv = 22, maxLv = 25, },
				{ pokemonID = 100, rate = 0.30, minLv = 22, maxLv = 25, },
				{ pokemonID = 25, rate = 0.25, minLv = 22, maxLv = 26, },
				{ pokemonID = 82, rate = 0.10, minLv = 31, maxLv = 34, },
				{ pokemonID = 125, rate = 0.05, minLv = 32, maxLv = 35, },
			},
			[RouteData.EncounterArea.STATIC] = {
				{ pokemonID = 145, rate = 1.00, minLv = 50, maxLv = 50, },
			},
		},
		[213] = { name = "Lorelei's Room", },
		[214] = { name = "Bruno's Room", },
		[215] = { name = "Agatha's Room", },
		[216] = { name = "Lance's Room", },
		[217] = { name = "Champion's Room", },
		[228] = { name = "Saffron City Dojo", },
	}
end
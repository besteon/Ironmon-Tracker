-- A collection of tools for viewing a Randomized Pokémon game log
RandomizerLog = {}

RandomizerLog.Patterns = {
	RandomizerVersion = "Randomizer Version:%s*([%d%.]+).*$", -- Note: log file line 1 does NOT start with "Rando..."
	RandomizerSeed = "^Random Seed:%s*(%d+)%s*$",
	RandomizerSettings = "^Settings String:%s*(.+)%s*$",
	RandomizerGame = "^Randomization of%s*(.+)%s+completed",
	-- PokemonName = "([%a%d%.]* ?[%a%d%.!'%-♀♂%?]+).-", -- Temporarily removed, using more loose match criteria
	-- MoveName = "([%u%d%.'%-%?]+)", -- might figure out later
	-- ItemName = "([%u%d%.'%-%?]+)", -- might figure out later
	getSectorHeaderPattern = function(sectorName)
		return "^%-?%-?" .. (sectorName or "") .. ":?%-?%-?$"
	end,
}

-- Each Sector has Pattern(s) to match on, and the Sector Start Header LineNumber
RandomizerLog.Sectors = {
	-- First three lines: Randomizer Version, Random Seed, Settings String

	Evolutions = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Randomized Evolutions"),
		-- Matches: pokemon, evos
		PokemonEvosPattern = "^(.-)%s*%->%s*(.*)",
	},
	BaseStatsItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Base Stats & Types"),
		-- Matches: id, pokemon, types, hp, atk, def, spatk, spdef, spd, ability1, ability2, helditems
		PokemonBSTPattern = "^%s*(%d*)|(.-)%s*|(.-)%s*|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|(.-)%s*|(.-)%s*|(.*)",
	},
	MoveSets = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Movesets"),
		-- Matches: pokemon
		NextMonPattern = "^%d+%s(.-)%s*%->",
		-- Matches: level, movename
		MovePattern = "^Level%s(%d+)%s?%s?:%s(.*)",
	},
	TMMoves = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("TM Moves"),
		-- Matches: tmNumber, movename
		TMPattern = "^TM(%d+)%s(.*)",
	},
	-- TODO: If TMs aren't randomized, then we don't store the original TM data, we probably need to do that
	TMCompatibility = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("TM Compatibility"),
		-- Matches: pokemon
		NextMonPattern = "^%s*%d+%s*(.-)%s*|(.*)",
		-- Matches: tmNumber
		TMPattern = "TM(%d+)",
	},
	Trainers = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Trainers Pokemon"),
		-- Matches: trainer_num, trainername, party
		NextTrainerPattern = "^#(%d+)%s%((.+)%s*=>%s*(.+)%)[^%s]*%s%-%s(.*)",
		-- Matches: partypokemon (pokemon name with held item and level info)
		PartyPattern = "([^,]+)",
		-- Matches: pokemon and helditem[optional], level
		PartyPokemonPattern = "%s*(.-)%sLv(%d+)",
	},
	Routes = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Wild Pokemon"),
		-- Matches: route_set_num, name_encounter
		NextRoutePattern = "^Set %#(%d+)%s*%-%s*(.-)%s*%(.*%)",
		-- Matches: pokemon, level_min, level_max, bst_spread (max 12 total lines; the order determines encounter percentage)
		RoutePokemonPattern = "^(.-)%s*Lvs?%s?(%d+)%-?(%d*)%s*(.*)",
	},
	-- Currently unused
	PickupItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pickup Items"),
		LevelPattern = "",
		PercentPattern = "",
		ItemsPattern = "",
	},
	GameInfo = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern(string.rep("%-", 66)),
	},
}

-- https://github.com/pret/pokefirered/blob/master/src/data/wild_encounters.json
local trainerEncAreaKey = "Trainers"
RandomizerLog.EncounterTypes = {
	[trainerEncAreaKey] = {
		-- Not used for wild encounters
	},
	GrassCave = {
		key = "Grass/Cave",
		rates = { 0.20, 0.20, 0.10, 0.10, 0.10, 0.10, 0.05, 0.05, 0.04, 0.04, 0.01, 0.01, }
	},
	Surfing = {
		key = "Surfing",
		rates = { 0.60, 0.30, 0.05, 0.04, 0.01, }
	},
	RockSmash = {
		key = "Rock Smash",
		rates = { 0.60, 0.30, 0.05, 0.04, 0.01, }
	},
	Fishing = { -- Includes all three: Old Rod, Good Rod, and Super Rod (in that order)
		key = "Fishing",
		rates = {
			0.70, 0.30, -- Old Rod
			0.60, 0.20, 0.20, -- Good Rod
			0.40, 0.40, 0.15, 0.04, 0.01, -- Super Rod
		}
	},
}

function RandomizerLog.initialize()
	-- Holds the path of the previously loaded log file. This is used to check if a new file needs to be parsed
	RandomizerLog.loadedLogPath = nil

	-- A table of parsed data from the log file: Settings, Pokemon, TMs, Trainers, PickupItems
	RandomizerLog.Data = {}
end

-- Parses the log file at 'filepath' into the data object RandomizerLog.Data
function RandomizerLog.parseLog(filepath)
	Utils.tempDisableBizhawkSound()
	local logLines = FileManager.readLinesFromFile(filepath)
	if #logLines == 0 then
		Utils.tempEnableBizhawkSound()
		return false
	end

	RandomizerLog.initBlankData()
	RandomizerLog.locateSectorLineStarts(logLines)

	RandomizerLog.setupMappings()
	RandomizerLog.parseRandomizerSettings(logLines)
	RandomizerLog.parseBaseStatsItems(logLines) -- required to parse first
	RandomizerLog.parseEvolutions(logLines)
	RandomizerLog.parseMoveSets(logLines)
	RandomizerLog.parseTMMoves(logLines)
	RandomizerLog.parseTMCompatibility(logLines)
	RandomizerLog.parseTrainers(logLines)
	RandomizerLog.parseRoutes(logLines)
	RandomizerLog.parsePickupItems(logLines)
	RandomizerLog.parseRandomizerGame(logLines)
	RandomizerLog.removeMappings()

	Utils.tempEnableBizhawkSound()
	return true
end

-- Returns sanitized input from the log file to be compatible with the Tracker. Trims spacing.
function RandomizerLog.formatInput(str)
	if str == nil then return nil end
	str = str:match("^%s*(.-)%s*$") or str -- remove leading/trailing spaces

	str = str:gsub("♀", " F")
	str = str:gsub("♂", " M")
	str = str:gsub("%?", "")
	str = str:gsub("’", "'")
	str = str:gsub("%[PK%]%[MN%]", "PKMN")

	str = Utils.toLowerUTF8(str)
	str = Utils.formatSpecialCharacters(str)
	return str
end

RandomizerLog.currentNidoranIsF = true

-- In some cases, the ♀/♂ in nidoran's names are stripped out. This is only way to figure out which is which
function RandomizerLog.alternateNidorans(name)
	if name == nil or name == "" or Utils.toLowerUTF8(name) ~= "nidoran" then return name end

	local correctName
	if RandomizerLog.currentNidoranIsF then
		correctName = name .. " f"
	else
		correctName = name .. " m"
	end
	RandomizerLog.currentNidoranIsF = not RandomizerLog.currentNidoranIsF
	return correctName
end

-- Clears out the parsed data and initializes it for each valid PokemonId
function RandomizerLog.initBlankData()
	RandomizerLog.Data = {
		Settings = {},
		Pokemon = {},
		TMs = {},
		Trainers = {},
		Routes = {},
		PickupItems = {}, -- Currently unused
	}

	for id = 1, PokemonData.totalPokemon, 1 do
		if id <= 251 or id >= 277 then -- celebi / treecko
			RandomizerLog.Data.Pokemon[id] = {
				Types = {},
				Abilities = {},
			}
		end
	end
end

-- Locates the starting line number of each sector
function RandomizerLog.locateSectorLineStarts(logLines)
	if logLines == nil or #logLines == 0 then
		return
	end

	for i, line in ipairs(logLines) do
		-- If the sector hasn't been found yet, and its this line
		for _, sector in pairs(RandomizerLog.Sectors) do
			if sector.LineNumber == nil and string.find(line, sector.HeaderPattern) ~= nil then
				sector.LineNumber = i + 1 -- +1 to skip the header itself
				break -- and continue looking for other sectors
			end
		end
	end
end

function RandomizerLog.parseRandomizerSettings(logLines)
	if #logLines < 3 then return end
	local version = string.match(logLines[1], RandomizerLog.Patterns.RandomizerVersion)
	local randomSeed = string.match(logLines[2], RandomizerLog.Patterns.RandomizerSeed)
	local settingsString = string.match(logLines[3], RandomizerLog.Patterns.RandomizerSettings)
	RandomizerLog.Data.Settings.Version = version
	RandomizerLog.Data.Settings.RandomSeed = randomSeed
	RandomizerLog.Data.Settings.SettingsString = settingsString
end

-- This sector is near the end of the file
function RandomizerLog.parseRandomizerGame(logLines)
	if RandomizerLog.Sectors.GameInfo.LineNumber == nil then
		return
	end

	local game = string.match(logLines[RandomizerLog.Sectors.GameInfo.LineNumber] or "", RandomizerLog.Patterns.RandomizerGame)
	RandomizerLog.Data.Settings.Game = game
end

function RandomizerLog.parseEvolutions(logLines)
	if RandomizerLog.Sectors.Evolutions.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Evolutions.LineNumber
	while index <= #logLines do
		local pokemon, evos = string.match(logLines[index] or "", RandomizerLog.Sectors.Evolutions.PokemonEvosPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or evos == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		RandomizerLog.Data.Pokemon[pokemonId].Evolutions = {}

		-- Replace any "and" to make parsing lowercase-named log files easier.
		evos = evos:gsub(" and ", ", ")
		for _, evo in pairs(Utils.split(evos, ",", true)) do
			local evoToAdd = RandomizerLog.formatInput(evo)
			evoToAdd = RandomizerLog.alternateNidorans(evoToAdd)
			local evoPokemonId = RandomizerLog.PokemonNameToIdMap[evoToAdd]
			if evoPokemonId ~= nil then
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].Evolutions, evoPokemonId)
				-- Add pre-evolutions to the evolved Pokemon
				if RandomizerLog.Data.Pokemon[evoPokemonId].PreEvolutions == nil then
					RandomizerLog.Data.Pokemon[evoPokemonId].PreEvolutions = {}
				end
				table.insert(RandomizerLog.Data.Pokemon[evoPokemonId].PreEvolutions, pokemonId)
			end
		end

		index = index + 1
	end
end

function RandomizerLog.parseBaseStatsItems(logLines)
	if RandomizerLog.Sectors.BaseStatsItems.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.BaseStatsItems.LineNumber + 1 -- remove the first line to skip the table header
	while index <= #logLines do
		local id, pokemon, types, hp, atk, def, spa, spd, spe, ability1, ability2, helditems = string.match(logLines[index] or "", RandomizerLog.Sectors.BaseStatsItems.PokemonBSTPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or spe == nil then
			return
		end

		local pokemonId = RouteData.verifyPID(tonumber(tostring(id)) or 0)
		local pokemonData = RandomizerLog.Data.Pokemon[pokemonId]
		if pokemonData ~= nil then
			-- Setup future lookups to handle custom names
			RandomizerLog.PokemonNameToIdMap[pokemon] = pokemonId

			pokemonData.Name = Utils.firstToUpper(pokemon)

			types = RandomizerLog.formatInput(types) or ""
			local type1, type2 = string.match(types, "([^/]+)/?(.*)")
			pokemonData.Types = {
				PokemonData.Types[string.upper(type1 or "")] or PokemonData.Types.EMPTY,
				PokemonData.Types[string.upper(type2 or "")] or PokemonData.Types.EMPTY,
			}

			pokemonData.BaseStats = {
				hp = tonumber(hp) or 0,
				atk = tonumber(atk) or 0,
				def = tonumber(def) or 0,
				spa = tonumber(spa) or 0,
				spd = tonumber(spd) or 0,
				spe = tonumber(spe) or 0,
			}

			ability1 = RandomizerLog.formatInput(ability1) or ""
			ability2 = RandomizerLog.formatInput(ability2) or "" -- Log shows empty abilities as "-------", which results in nil via lookup
			pokemonData.Abilities = {
				RandomizerLog.AbilityNameToIdMap[ability1] or AbilityData.DefaultAbility.id,
				RandomizerLog.AbilityNameToIdMap[ability2],
			}

			if helditems ~= nil and helditems ~= "" then
				pokemonData.HeldItems = RandomizerLog.formatInput(helditems)
			end
		end
		index = index + 1
	end
end

function RandomizerLog.parseMoveSets(logLines)
	if RandomizerLog.Sectors.MoveSets.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.MoveSets.LineNumber
	while index <= #logLines do
		local pokemon = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.NextMonPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- Search for the next Pokémon's name, or the end of sector
		-- I might fix this whole mess later when I'm awake
		while pokemon == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil do
			if string.find(logLines[index] or "", "^%-%-") ~= nil or index + 1 > #logLines then
				return
			end
			index = index + 1
			pokemon = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.NextMonPattern)
			pokemon = RandomizerLog.formatInput(pokemon)
			pokemon = RandomizerLog.alternateNidorans(pokemon)
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		local pokemonData = RandomizerLog.Data.Pokemon[pokemonId]
		if pokemonData ~= nil then
			pokemonData.MoveSet = {}
			 -- First six lines are redundant Base Sets (also don't trust these will exist), and skip current line
			index = index + 7

			-- Search for each listed level-up move
			local level, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.MovePattern)
			while level ~= nil and movename ~= nil do
				local nextMove = {
					level = tonumber(RandomizerLog.formatInput(level)) or 0,
					moveId = RandomizerLog.MoveNameToIdMap[RandomizerLog.formatInput(movename)] or 0,
					name = movename, -- For custom move names
				}
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].MoveSet, nextMove)

				index = index + 1
				if index > #logLines then
					return
				end
				level, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.MovePattern)
			end
		else
			index = index + 1
		end
	end
end

function RandomizerLog.parseTMMoves(logLines)
	if RandomizerLog.Sectors.TMMoves.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.TMMoves.LineNumber
	while index <= #logLines do
		local tmNumber, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.TMMoves.TMPattern)
		tmNumber = tonumber(RandomizerLog.formatInput(tmNumber) or "") -- nil if not a number

		-- If nothing matches, end of sector
		if tmNumber == nil or RandomizerLog.formatInput(movename) == nil then
			return
		end

		RandomizerLog.Data.TMs[tmNumber] = {
			moveId = RandomizerLog.MoveNameToIdMap[RandomizerLog.formatInput(movename)] or 0,
			name = movename, -- For custom move names
		}

		index = index + 1
	end
end

function RandomizerLog.parseTMCompatibility(logLines)
	if RandomizerLog.Sectors.TMCompatibility.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.TMCompatibility.LineNumber
	while index <= #logLines do
		local pokemon, tms = string.match(logLines[index] or "", RandomizerLog.Sectors.TMCompatibility.NextMonPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or tms == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		RandomizerLog.Data.Pokemon[pokemonId].TMMoves = {}

		for tmNumberStr in string.gmatch(tms, RandomizerLog.Sectors.TMCompatibility.TMPattern) do
			local tmNumber = tonumber(RandomizerLog.formatInput(tmNumberStr) or "") -- nil if not a number
			if tmNumber ~= nil and RandomizerLog.Data.TMs[tmNumber] ~= nil then
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].TMMoves, tmNumber)
			end
		end
		index = index + 1
	end
end

function RandomizerLog.parseTrainers(logLines)
	if RandomizerLog.Sectors.Trainers.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Trainers.LineNumber
	while index <= #logLines do
		local trainer_num, trainername, customname, party = string.match(logLines[index] or "", RandomizerLog.Sectors.Trainers.NextTrainerPattern)
		trainer_num = tonumber(RandomizerLog.formatInput(trainer_num) or "") -- nil if not a number
		trainername = RandomizerLog.formatInput(trainername)
		customname = RandomizerLog.formatInput(customname)

		-- If nothing matches, end of sector
		if trainer_num == nil or trainername == nil or party == nil then
			return
		end

		RandomizerLog.Data.Trainers[trainer_num] = {
			name = trainername, -- likely in the form of TRAINER CLASS + TRAINER NAME
			customname = customname,
			avgTrainerLv = 0, -- Averages the levels of trainer party pokemon, used for searching
			party = {},
		}
		local trainer = RandomizerLog.Data.Trainers[trainer_num]

		for partypokemon in string.gmatch(party, RandomizerLog.Sectors.Trainers.PartyPattern) do
			local pokemonAndItem, level = string.match(partypokemon, RandomizerLog.Sectors.Trainers.PartyPokemonPattern)
			local splitTable = Utils.split(pokemonAndItem, "@", true)
			local pokemon = RandomizerLog.formatInput(splitTable[1] or "")
			pokemon = RandomizerLog.alternateNidorans(pokemon)
			local helditem = RandomizerLog.formatInput(splitTable[2] or "")
			level = tonumber(RandomizerLog.formatInput(level) or "") or 0 -- nil if not a number

			if helditem == "" then
				helditem = nil -- don't waste storage if empty
			end

			if pokemon ~= nil and RandomizerLog.PokemonNameToIdMap[pokemon] ~= nil then
				local partyPokemon = {
					pokemonID = RandomizerLog.PokemonNameToIdMap[pokemon],
					helditem = helditem,
					level = level,
					moveIds = {}, -- Holds the 4 moves this Pokemon has at this current level, needed for searching
				}
				trainer.avgTrainerLv = trainer.avgTrainerLv + level -- (sum for now, average out later)

				local pokemonLog = RandomizerLog.Data.Pokemon[partyPokemon.pokemonID] or {}
				local pokemonMoves = pokemonLog.MoveSet or {}

				-- Pokemon forget moves in order from 1st learned to last, so figure out current moveset by working backwards
				for j = #pokemonMoves, 1, -1 do
					if pokemonMoves[j].level <= partyPokemon.level then
						-- Insert at the front (i=1) to add them in "reverse" or bottom-up
						table.insert(partyPokemon.moveIds, 1, pokemonMoves[j].moveId)

						if #partyPokemon.moveIds >= 4 then
							break
						end
					end
				end

				table.insert(trainer.party, partyPokemon)
			end
		end
		if #trainer.party > 0 then
			trainer.avgTrainerLv = math.floor(trainer.avgTrainerLv / #trainer.party + 0.5)
		end

		if GameSettings.game == 3 and trainer_num <= 88 then -- Exclude dummy trainers from FRLG (exist only in Emerald)
			RandomizerLog.Data.Trainers[trainer_num] = nil
		end
		index = index + 1
	end
end

function RandomizerLog.parseRoutes(logLines)
	if RandomizerLog.Sectors.Routes.LineNumber == nil then
		return
	end

	-- First add in routes that have trainers from Tracker data. The Log only has route info for wild encounters
	for mapId, routeData in pairs(TrainerData.Routes or {}) do
		local routeName = (RouteData.Info[mapId] or {}).name
		RandomizerLog.Data.Routes[mapId] = {
			name = routeName or "Unknown Area",
			avgTrainerLv = 0, -- Averages the levels of trainer party pokemon, used for searching
			avgWildLv = 0, -- Averages the levels of wild pokemon, used for searching
			EncountersAreas = {},
		}
		local route = RandomizerLog.Data.Routes[mapId]
		local trainerIds = routeData.trainers or {}
		route.EncountersAreas[trainerEncAreaKey] = {
			key = trainerEncAreaKey,
			trainers = trainerIds,
		}
		-- Determine average level of the trainers in this area
		if #trainerIds > 0 then
			local avgLevel = 0
			for _, trainerId in ipairs(trainerIds) do
				local trainerData = RandomizerLog.Data.Trainers[trainerId] or {}
				avgLevel = avgLevel + (trainerData.avgTrainerLv or 0)
			end
			route.avgTrainerLv = math.floor(avgLevel / #trainerIds + 0.5)
		end
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Routes.LineNumber
	while index <= #logLines do
		local route_set_num, name_encounter = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.NextRoutePattern)
		route_set_num = tonumber(RandomizerLog.formatInput(route_set_num) or "") -- nil if not a number
		name_encounter = RandomizerLog.formatInput(name_encounter)

		-- Search for the next Route, or the end of sector
		while route_set_num == nil or name_encounter == nil do
			if string.find(logLines[index] or "", "^%-%-") ~= nil or index + 1 > #logLines then
				return
			end
			index = index + 1
			route_set_num, name_encounter = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.NextRoutePattern)
			route_set_num = tonumber(RandomizerLog.formatInput(route_set_num) or "") -- nil if not a number
			name_encounter = RandomizerLog.formatInput(name_encounter)
		end

		local routeName, encounterTypeKey
		for key, encTable in pairs(RandomizerLog.EncounterTypes) do
			local logKey = encTable.key or "NO LOG KEY USED"
			local encIndex = string.find(name_encounter, logKey:lower(), 1, true)
			if encIndex ~= nil then
				routeName = name_encounter:sub(1, encIndex - 2) -- Remove trailing space
				encounterTypeKey = key
				break
			end
		end

		local mapId = RandomizerLog.RouteSetNumToIdMap[route_set_num or 0] or 0
		if mapId ~= 0 and encounterTypeKey ~= nil then
			index = index + 1

			if RandomizerLog.Data.Routes[mapId] == nil then
				-- Create the route information table
				RandomizerLog.Data.Routes[mapId] = {
					name = routeName or "Unknown Area",
					avgTrainerLv = 0, -- Averages the levels of trainer party pokemon, used for searching
					avgWildLv = 0, -- Averages the levels of wild pokemon, used for searching
					EncountersAreas = {},
				}
			end
			local route = RandomizerLog.Data.Routes[mapId]

			-- Condense route data for multiple encounter areas and trainer sets
			route.EncountersAreas[encounterTypeKey] = {
				setNumber = route_set_num,
				key = encounterTypeKey,
				pokemon = {},
			}

			-- Max 12 total wild encounters, the order determines encounter percentage
			local encounterIndex = 1
			local encounterArea = route.EncountersAreas[encounterTypeKey]
			local encouterRates = RandomizerLog.EncounterTypes[encounterTypeKey].rates or {}
			local avgLevel = 0

			-- Search for each listed wild encounter
			local pokemon, level_min, level_max, bst_spread = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.RoutePokemonPattern)
			pokemon = RandomizerLog.formatInput(pokemon)
			pokemon = RandomizerLog.alternateNidorans(pokemon)
			while pokemon ~= nil and level_min ~= nil do
				local pokemonID = RandomizerLog.PokemonNameToIdMap[pokemon]
				if pokemonID ~= nil then
					-- Condense encounter data for multiple listings of the same Pokemon (combine levels & rates)
					if encounterArea.pokemon[pokemonID] == nil then
						encounterArea.pokemon[pokemonID] = {}
					end

					local enc = encounterArea.pokemon[pokemonID]
					enc.index = enc.index or encounterIndex
					enc.levelMin = math.min(enc.levelMin or 100, tonumber(RandomizerLog.formatInput(level_min)) or 0)
					enc.levelMax = math.max(enc.levelMax or 0, tonumber(RandomizerLog.formatInput(level_max)) or enc.levelMin)
					enc.rate = (enc.rate or 0) + (encouterRates[encounterIndex] or 0)

					local avgEncLv = math.floor((enc.levelMin + enc.levelMax) / 2 + 0.5)
					avgLevel = avgLevel + avgEncLv
				end

				index = index + 1
				encounterIndex = encounterIndex + 1
				if index > #logLines then
					break
				end
				pokemon, level_min, level_max, bst_spread = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.RoutePokemonPattern)
			end

			-- If the average level for the route's wild encounters hasn't be calculated yet, do that
			-- Ideally grass/cave encounters are parsed first
			if route.avgWildLv == 0 then
				local totalEnc = 0
				for _, _ in pairs(encounterArea.pokemon or {}) do
					totalEnc = totalEnc + 1
				end
				if totalEnc > 0 then
					route.avgWildLv = math.floor(avgLevel / totalEnc + 0.5)
				end
			end

			if index > #logLines then
				return
			end
		else
			index = index + 1
		end
	end
end

-- Currently unused
function RandomizerLog.parsePickupItems(logLines)
	-- Utils.printDebug("#%s: %s >%s< %s", trainer_num, pokemon or "N/A", helditem or "N/A", level or 0)
end

function RandomizerLog.areLanguagesMismatched()
	return GameSettings.language:upper() ~= Resources.currentLanguage.Key:upper()
end

-- Returns the Pokemon name, either determined from internal Tracker information or from the log itself (for custom names)
function RandomizerLog.getPokemonName(pokemonID)
	if not PokemonData.isValid(pokemonID) then
		return Constants.BLANKLINE
	end

	-- When languages don't match, there's no way to tell if the name in the log is a custom name or not, assume it's not
	if RandomizerLog.areLanguagesMismatched() then
		return PokemonData.Pokemon[pokemonID].name or Constants.BLANKLINE
	else
		return RandomizerLog.Data.Pokemon[pokemonID].Name or PokemonData.Pokemon[pokemonID].name or Constants.BLANKLINE
	end
end

function RandomizerLog.setupMappings()
	local allMovesSource = MoveData.Moves
	local allAbilitiesSource = AbilityData.Abilities

	-- If the game's language and tracker's display language don't match, load relevant Resources using the game language
	if RandomizerLog.areLanguagesMismatched() then
		local languageToLoad = Resources.Languages[GameSettings.language:upper()] or Resources.Default.Language
		local languageGameData = RandomizerLog.loadLanguageMappings(languageToLoad)

		if languageGameData.Game.MoveNames then
			allMovesSource = {}
			for id, name in ipairs(languageGameData.Game.MoveNames) do
				table.insert(allMovesSource, { id = id, name = name, })
			end
		end

		if languageGameData.Game.AbilityNames then
			allAbilitiesSource = {}
			for id, name in ipairs(languageGameData.Game.AbilityNames) do
				table.insert(allAbilitiesSource, { id = id, name = name, })
			end
		end
	end

	-- Pokémon names -> IDs
	RandomizerLog.PokemonNameToIdMap = {} -- setup later while parsing the first important log sector

	-- Move names -> IDs
	RandomizerLog.MoveNameToIdMap = {}
	for _, moveInfo in ipairs(allMovesSource) do
		if moveInfo.id ~= nil and moveInfo.name ~= nil and moveInfo.name ~= "" then
			local formattedName = RandomizerLog.formatInput(moveInfo.name) or ""
			RandomizerLog.MoveNameToIdMap[formattedName] = tonumber(moveInfo.id) or -1
		end
	end

	-- Ability names -> IDs
	RandomizerLog.AbilityNameToIdMap = {}
	for _, abilityInfo in ipairs(allAbilitiesSource) do
		if abilityInfo.id ~= nil and abilityInfo.name ~= nil and abilityInfo.name ~= "" then
			local formattedName = RandomizerLog.formatInput(abilityInfo.name) or ""
			RandomizerLog.AbilityNameToIdMap[formattedName] = abilityInfo.id
		end
	end

	-- TODO: Verify this isn't FRLG dependent. Make sure it works on Emerald and Ruby/Sapphire (check each)
	-- Route Set # -> IDs (can't use names, not unique matches)
	RandomizerLog.RouteSetNumToIdMap = {}
	RandomizerLog.RouteSetNumToIdMap[1] = 335 -- monean chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[2] = 336 -- liptoo chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[3] = 337 -- weepth chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[4] = 338 -- dilford chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[5] = 339 -- scufib chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[6] = 362 -- rixy chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[7] = 363 -- viapois chamber (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[8] = 117 -- viridian forest (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[9] = 114 -- mt. moon (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[10] = 115 -- mt. moon (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[11] = 116 -- mt. moon (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[12] = 000 -- s.s. anne (surfing)
	RandomizerLog.RouteSetNumToIdMap[13] = 000 -- s.s. anne (fishing)
	RandomizerLog.RouteSetNumToIdMap[14] = 124 -- diglett's cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[15] = 125 -- victory road (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[16] = 126 -- victory road (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[17] = 127 -- victory road (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[18] = 143 -- pokémon mansion (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[19] = 144 -- pokémon mansion (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[20] = 145 -- pokémon mansion (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[21] = 146 -- pokémon mansion (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[22] = 147 -- safari zone (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[23] = 147 -- safari zone (surfing)
	RandomizerLog.RouteSetNumToIdMap[24] = 147 -- safari zone (fishing)
	RandomizerLog.RouteSetNumToIdMap[25] = 148 -- safari zone (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[26] = 148 -- safari zone (surfing)
	RandomizerLog.RouteSetNumToIdMap[27] = 148 -- safari zone (fishing)
	RandomizerLog.RouteSetNumToIdMap[28] = 149 -- safari zone (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[29] = 149 -- safari zone (surfing)
	RandomizerLog.RouteSetNumToIdMap[30] = 149 -- safari zone (fishing)
	RandomizerLog.RouteSetNumToIdMap[31] = 150 -- safari zone (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[32] = 150 -- safari zone (surfing)
	RandomizerLog.RouteSetNumToIdMap[33] = 150 -- safari zone (fishing)
	RandomizerLog.RouteSetNumToIdMap[34] = 151 -- cerulean cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[35] = 151 -- cerulean cave (surfing)
	RandomizerLog.RouteSetNumToIdMap[36] = 151 -- cerulean cave (rock smash)
	RandomizerLog.RouteSetNumToIdMap[37] = 151 -- cerulean cave (fishing)
	RandomizerLog.RouteSetNumToIdMap[38] = 152 -- cerulean cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[39] = 152 -- cerulean cave (rock smash)
	RandomizerLog.RouteSetNumToIdMap[40] = 153 -- cerulean cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[41] = 153 -- cerulean cave (surfing)
	RandomizerLog.RouteSetNumToIdMap[42] = 153 -- cerulean cave (rock smash)
	RandomizerLog.RouteSetNumToIdMap[43] = 153 -- cerulean cave (fishing)
	RandomizerLog.RouteSetNumToIdMap[44] = 154 -- rock tunnel (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[45] = 155 -- rock tunnel (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[46] = 155 -- rock tunnel (rock smash)
	RandomizerLog.RouteSetNumToIdMap[47] = 156 -- seafoam islands (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[48] = 157 -- seafoam islands (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[49] = 158 -- seafoam islands (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[50] = 159 -- seafoam islands (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[51] = 159 -- seafoam islands (surfing)
	RandomizerLog.RouteSetNumToIdMap[52] = 159 -- seafoam islands (fishing)
	RandomizerLog.RouteSetNumToIdMap[53] = 160 -- seafoam islands (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[54] = 160 -- seafoam islands (surfing)
	RandomizerLog.RouteSetNumToIdMap[55] = 160 -- seafoam islands (fishing)
	RandomizerLog.RouteSetNumToIdMap[56] = 163 -- pokémon tower (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[57] = 164 -- pokémon tower (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[58] = 165 -- pokémon tower (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[59] = 166 -- pokémon tower (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[60] = 167 -- pokémon tower (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[61] = 168 -- power plant (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[62] = 280 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[63] = 280 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[64] = 282 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[65] = 283 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[66] = 283 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[67] = 284 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[68] = 285 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[69] = 285 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[70] = 286 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[71] = 286 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[72] = 287 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[73] = 287 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[74] = 288 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[75] = 288 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[76] = 289 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[77] = 289 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[78] = 290 -- mt. ember (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[79] = 290 -- mt. ember (rock smash)
	RandomizerLog.RouteSetNumToIdMap[80] = 270 -- berry forest (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[81] = 270 -- berry forest (surfing)
	RandomizerLog.RouteSetNumToIdMap[82] = 270 -- berry forest (fishing)
	RandomizerLog.RouteSetNumToIdMap[83] = 293 -- icefall cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[84] = 293 -- icefall cave (surfing)
	RandomizerLog.RouteSetNumToIdMap[85] = 293 -- icefall cave (fishing)
	RandomizerLog.RouteSetNumToIdMap[86] = 294 -- icefall cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[87] = 295 -- icefall cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[88] = 296 -- icefall cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[89] = 296 -- icefall cave (surfing)
	RandomizerLog.RouteSetNumToIdMap[90] = 296 -- icefall cave (fishing)
	RandomizerLog.RouteSetNumToIdMap[91] = 317 -- pattern bush (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[92] = 321 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[93] = 322 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[94] = 323 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[95] = 324 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[96] = 325 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[97] = 326 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[98] = 327 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[99] = 328 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[100] = 329 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[101] = 330 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[102] = 331 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[103] = 332 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[104] = 333 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[105] = 334 -- lost cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[106] = 237 -- kindle road (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[107] = 237 -- kindle road (surfing)
	RandomizerLog.RouteSetNumToIdMap[108] = 237 -- kindle road (rock smash)
	RandomizerLog.RouteSetNumToIdMap[109] = 237 -- kindle road (fishing)
	RandomizerLog.RouteSetNumToIdMap[110] = 238 -- treasure beach (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[111] = 238 -- treasure beach (surfing)
	RandomizerLog.RouteSetNumToIdMap[112] = 238 -- treasure beach (fishing)
	RandomizerLog.RouteSetNumToIdMap[113] = 239 -- cape brink (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[114] = 239 -- cape brink (surfing)
	RandomizerLog.RouteSetNumToIdMap[115] = 239 -- cape brink (fishing)
	RandomizerLog.RouteSetNumToIdMap[116] = 240 -- bond bridge (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[117] = 240 -- bond bridge (surfing)
	RandomizerLog.RouteSetNumToIdMap[118] = 240 -- bond bridge (fishing)
	RandomizerLog.RouteSetNumToIdMap[119] = 241 -- three isle port (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[120] = 246 -- resort gorgeous (surfing)
	RandomizerLog.RouteSetNumToIdMap[121] = 246 -- resort gorgeous (fishing)
	RandomizerLog.RouteSetNumToIdMap[122] = 247 -- water labyrinth (surfing)
	RandomizerLog.RouteSetNumToIdMap[123] = 247 -- water labyrinth (fishing)
	RandomizerLog.RouteSetNumToIdMap[124] = 248 -- five isle meadow (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[125] = 248 -- five isle meadow (surfing)
	RandomizerLog.RouteSetNumToIdMap[126] = 248 -- five isle meadow (fishing)
	RandomizerLog.RouteSetNumToIdMap[127] = 249 -- memorial pillar (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[128] = 249 -- memorial pillar (surfing)
	RandomizerLog.RouteSetNumToIdMap[129] = 249 -- memorial pillar (fishing)
	RandomizerLog.RouteSetNumToIdMap[130] = 250 -- outcast island (surfing)
	RandomizerLog.RouteSetNumToIdMap[131] = 250 -- outcast island (fishing)
	RandomizerLog.RouteSetNumToIdMap[132] = 251 -- green path (surfing)
	RandomizerLog.RouteSetNumToIdMap[133] = 251 -- green path (fishing)
	RandomizerLog.RouteSetNumToIdMap[134] = 252 -- water path (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[135] = 252 -- water path (surfing)
	RandomizerLog.RouteSetNumToIdMap[136] = 252 -- water path (fishing)
	RandomizerLog.RouteSetNumToIdMap[137] = 253 -- ruin valley (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[138] = 253 -- ruin valley (surfing)
	RandomizerLog.RouteSetNumToIdMap[139] = 253 -- ruin valley (fishing)
	RandomizerLog.RouteSetNumToIdMap[140] = 254 -- trainer tower (surfing)
	RandomizerLog.RouteSetNumToIdMap[141] = 254 -- trainer tower (fishing)
	RandomizerLog.RouteSetNumToIdMap[142] = 255 -- canyon entrance (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[143] = 256 -- sevault canyon (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[144] = 256 -- sevault canyon (rock smash)
	RandomizerLog.RouteSetNumToIdMap[145] = 257 -- tanoby ruins (surfing)
	RandomizerLog.RouteSetNumToIdMap[146] = 257 -- tanoby ruins (fishing)
	RandomizerLog.RouteSetNumToIdMap[147] = 89 -- route 1 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[148] = 90 -- route 2 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[149] = 91 -- route 3 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[150] = 92 -- route 4 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[151] = 92 -- route 4 (surfing)
	RandomizerLog.RouteSetNumToIdMap[152] = 92 -- route 4 (fishing)
	RandomizerLog.RouteSetNumToIdMap[153] = 93 -- route 5 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[154] = 94 -- route 6 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[155] = 94 -- route 6 (surfing)
	RandomizerLog.RouteSetNumToIdMap[156] = 94 -- route 6 (fishing)
	RandomizerLog.RouteSetNumToIdMap[157] = 95 -- route 7 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[158] = 96 -- route 8 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[159] = 97 -- route 9 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[160] = 98 -- route 10 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[161] = 98 -- route 10 (surfing)
	RandomizerLog.RouteSetNumToIdMap[162] = 98 -- route 10 (fishing)
	RandomizerLog.RouteSetNumToIdMap[163] = 99 -- route 11 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[164] = 99 -- route 11 (surfing)
	RandomizerLog.RouteSetNumToIdMap[165] = 99 -- route 11 (fishing)
	RandomizerLog.RouteSetNumToIdMap[166] = 100 -- route 12 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[167] = 100 -- route 12 (surfing)
	RandomizerLog.RouteSetNumToIdMap[168] = 100 -- route 12 (fishing)
	RandomizerLog.RouteSetNumToIdMap[169] = 101 -- route 13 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[170] = 101 -- route 13 (surfing)
	RandomizerLog.RouteSetNumToIdMap[171] = 101 -- route 13 (fishing)
	RandomizerLog.RouteSetNumToIdMap[172] = 102 -- route 14 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[173] = 103 -- route 15 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[174] = 104 -- route 16 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[175] = 105 -- route 17 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[176] = 106 -- route 18 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[177] = 107 -- route 19 (surfing)
	RandomizerLog.RouteSetNumToIdMap[178] = 107 -- route 19 (fishing)
	RandomizerLog.RouteSetNumToIdMap[179] = 108 -- route 20 (surfing)
	RandomizerLog.RouteSetNumToIdMap[180] = 108 -- route 20 (fishing)
	RandomizerLog.RouteSetNumToIdMap[181] = 109 -- route 21 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[182] = 109 -- route 21 (surfing)
	RandomizerLog.RouteSetNumToIdMap[183] = 109 -- route 21 (fishing)
	RandomizerLog.RouteSetNumToIdMap[184] = 219 -- route 21 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[185] = 219 -- route 21 (surfing)
	RandomizerLog.RouteSetNumToIdMap[186] = 219 -- route 21 (fishing)
	RandomizerLog.RouteSetNumToIdMap[187] = 110 -- route 22 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[188] = 110 -- route 22 (surfing)
	RandomizerLog.RouteSetNumToIdMap[189] = 110 -- route 22 (fishing)
	RandomizerLog.RouteSetNumToIdMap[190] = 111 -- route 23 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[191] = 111 -- route 23 (surfing)
	RandomizerLog.RouteSetNumToIdMap[192] = 111 -- route 23 (fishing)
	RandomizerLog.RouteSetNumToIdMap[193] = 112 -- route 24 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[194] = 112 -- route 24 (surfing)
	RandomizerLog.RouteSetNumToIdMap[195] = 112 -- route 24 (fishing)
	RandomizerLog.RouteSetNumToIdMap[196] = 113 -- route 25 (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[197] = 113 -- route 25 (surfing)
	RandomizerLog.RouteSetNumToIdMap[198] = 113 -- route 25 (fishing)
	RandomizerLog.RouteSetNumToIdMap[199] = 78 -- pallet town (surfing)
	RandomizerLog.RouteSetNumToIdMap[200] = 78 -- pallet town (fishing)
	RandomizerLog.RouteSetNumToIdMap[201] = 79 -- viridian city (surfing)
	RandomizerLog.RouteSetNumToIdMap[202] = 79 -- viridian city (fishing)
	RandomizerLog.RouteSetNumToIdMap[203] = 81 -- cerulean city (surfing)
	RandomizerLog.RouteSetNumToIdMap[204] = 81 -- cerulean city (fishing)
	RandomizerLog.RouteSetNumToIdMap[205] = 83 -- vermilion city (surfing)
	RandomizerLog.RouteSetNumToIdMap[206] = 83 -- vermilion city (fishing)
	RandomizerLog.RouteSetNumToIdMap[207] = 84 -- celadon city (surfing)
	RandomizerLog.RouteSetNumToIdMap[208] = 84 -- celadon city (fishing)
	RandomizerLog.RouteSetNumToIdMap[209] = 85 -- fuchsia city (surfing)
	RandomizerLog.RouteSetNumToIdMap[210] = 85 -- fuchsia city (fishing)
	RandomizerLog.RouteSetNumToIdMap[211] = 86 -- cinnabar island (surfing)
	RandomizerLog.RouteSetNumToIdMap[212] = 86 -- cinnabar island (fishing)
	RandomizerLog.RouteSetNumToIdMap[213] = 230 -- one island (surfing)
	RandomizerLog.RouteSetNumToIdMap[214] = 230 -- one island (fishing)
	RandomizerLog.RouteSetNumToIdMap[215] = 233 -- four island (surfing)
	RandomizerLog.RouteSetNumToIdMap[216] = 233 -- four island (fishing)
	RandomizerLog.RouteSetNumToIdMap[217] = 234 -- five island (surfing)
	RandomizerLog.RouteSetNumToIdMap[218] = 234 -- five island (fishing)
	RandomizerLog.RouteSetNumToIdMap[219] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[220] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[221] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[222] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[223] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[224] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[225] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[226] = 340 -- altering cave (grass/cave)
	RandomizerLog.RouteSetNumToIdMap[227] = 340 -- altering cave (grass/cave)
end

function RandomizerLog.removeMappings()
	RandomizerLog.PokemonNameToIdMap = nil
	RandomizerLog.MoveNameToIdMap = nil
	RandomizerLog.AbilityNameToIdMap = nil
	RandomizerLog.RouteSetNumToIdMap = nil
	collectgarbage()
end

function RandomizerLog.loadLanguageMappings(language)
	local gamedata = {}

	-- Sub function used by other resource load functions
	local function dataLoadHelper(asset, data)
		if gamedata[asset] == nil then
			gamedata[asset] = {}
		end
		local assetTable = gamedata[asset]
		for key, val in pairs(data) do
			assetTable[key] = val
		end
	end

	local langFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
	local langFilePath = langFolder .. language.FileName
	if FileManager.fileExists(langFilePath) then
		 -- Temp store the old callback function while reading in some Game Resources
		local originalScreenCallback = ScreenResources
		local originalGameCallback = GameResources
		ScreenResources = function(data) end -- Do nothing, only need Game data
		GameResources = function(data) dataLoadHelper("Game", data) end
		-- Load language resources into gamedata
		dofile(langFilePath)
		Resources.sanitizeTable(gamedata)
		ScreenResources = originalScreenCallback
		GameResources = originalGameCallback
	end

	return gamedata
end
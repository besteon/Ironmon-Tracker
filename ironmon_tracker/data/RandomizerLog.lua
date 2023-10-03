-- A collection of tools for viewing a Randomized Pokémon game log
RandomizerLog = {}

RandomizerLog.Patterns = {
	RandomizerVersion = "Randomizer Version:%s*([^%s]+)%s*$", -- Note: log file line 1 does NOT start with "Rando..."
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
	Moves = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Move Data"),
		-- Matches: moveId, movename, movetype, power, acc, pp
		MovePattern = "^%s*(%d*)|(.-)%s*|(.-)%s*|%s*(%d*)|%s*(%d*)|%s*(%d*)",
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
		NextTrainerPattern = "^#(%d+)%s%(([^=>]+)%s*=?>?%s*(.*)%)[^%s]*%s%-%s(.*)",
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
RandomizerLog.EncounterTypes = {
	-- These keys (not logkeys) should be identical to LogTabRouteDetails.Tabs keys
	Trainers = {
		-- Not used for wild encounters
		logKey = "Trainers",
		internalArea = RouteData.EncounterArea.TRAINER,
		index = 1,
	},
	GrassCave = {
		logKey = "Grass/Cave",
		internalArea = RouteData.EncounterArea.LAND,
		rates = { 0.20, 0.20, 0.10, 0.10, 0.10, 0.10, 0.05, 0.05, 0.04, 0.04, 0.01, 0.01, },
		index = 2,
	},
	Surfing = {
		logKey = "Surfing",
		internalArea = RouteData.EncounterArea.SURFING,
		rates = { 0.60, 0.30, 0.05, 0.04, 0.01, },
		index = 3,
	},
	RockSmash = {
		logKey = "Rock Smash",
		internalArea = RouteData.EncounterArea.ROCKSMASH,
		rates = { 0.60, 0.30, 0.05, 0.04, 0.01, },
		index = 4,
	},
	OldRod = {
		logKey = "Fishing",
		internalArea = RouteData.EncounterArea.OLDROD,
		rates = { 0.70, 0.30, },
		index = 5,
	},
	GoodRod = {
		logKey = "Fishing",
		internalArea = RouteData.EncounterArea.GOODROD,
		rates = { 0.60, 0.20, 0.20, },
		index = 6,
	},
	SuperRod = {
		logKey = "Fishing",
		internalArea = RouteData.EncounterArea.SUPERROD,
		rates = { 0.40, 0.40, 0.15, 0.04, 0.01, },
		index = 7,
	},
}

-- A table of parsed data from the log file: Settings, Pokemon, TMs, Trainers, PickupItems
RandomizerLog.Data = {}

function RandomizerLog.initialize()
	-- Holds the path of the previously loaded log file. This is used to check if a new file needs to be parsed
	RandomizerLog.loadedLogPath = nil

	RandomizerLog.initBlankData()
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
	RandomizerLog.parseMoves(logLines)
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

	str = Utils.formatSpecialCharacters(str)
	str = Utils.toLowerUTF8(str)
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
		Moves = {},
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
		id = tonumber(tostring(id)) or 0
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or spe == nil then
			return
		end

		local pokemonId = PokemonData.dexMapNationalToInternal(id)
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

function RandomizerLog.parseMoves(logLines)
	if RandomizerLog.Sectors.Moves.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Moves.LineNumber + 1 -- remove the first line to skip the table header
	while index <= #logLines do
		local moveId, movename, movetype, power, acc, pp = string.match(logLines[index] or "", RandomizerLog.Sectors.Moves.MovePattern)
		moveId = tonumber(RandomizerLog.formatInput(moveId) or "") -- nil if not a number
		power = tonumber(RandomizerLog.formatInput(power) or "") -- nil if not a number
		acc = tonumber(RandomizerLog.formatInput(acc) or "") -- nil if not a number
		pp = tonumber(RandomizerLog.formatInput(pp) or "") -- nil if not a number

		-- If nothing matches, end of sector
		if moveId == nil or RandomizerLog.formatInput(movename) == nil or movetype == nil then
			return
		end

		RandomizerLog.Data.Moves[moveId] = {
			moveId = moveId,
			name = movename, -- For custom move names
			type = PokemonData.Types[Utils.toUpperUTF8(movetype or "")] or PokemonData.Types.EMPTY,
			power = power,
			acc = acc,
			pp = pp,
		}

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

	local trainersToExclude = TrainerData.getExcludedTrainers()

	-- Parse the sector
	local index = RandomizerLog.Sectors.Trainers.LineNumber
	while index <= #logLines do
		local trainer_num, trainer_fullname, customname_full, party = string.match(logLines[index] or "", RandomizerLog.Sectors.Trainers.NextTrainerPattern)
		trainer_num = tonumber(RandomizerLog.formatInput(trainer_num) or "") -- nil if not a number
		trainer_fullname = RandomizerLog.formatInput(trainer_fullname)
		customname_full = RandomizerLog.formatInput(customname_full)

		-- If nothing matches, end of sector
		if trainer_num == nil or trainer_fullname == nil or party == nil then
			return
		end

		local trainerClass, trainerName = RandomizerLog.splitTrainerClassAndName(trainer_fullname)
		local customClass, customName = RandomizerLog.splitTrainerClassAndName(customname_full)
		RandomizerLog.Data.Trainers[trainer_num] = {
			name = trainerName,
			class = trainerClass,
			fullname = trainer_fullname,
			customClass = customClass,
			customName = customName,
			customFullname = customname_full,
			minlevel = nil,
			maxlevel = nil,
			avgTrainerLv = nil, -- average of all party pokemon levels
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
				if level < (trainer.minlevel or 999) then
					trainer.minlevel = level
				end
				if level > (trainer.maxlevel or 0) then
					trainer.maxlevel = level
				end
				trainer.avgTrainerLv = (trainer.avgTrainerLv or 0) + level

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
			trainer.avgTrainerLv = trainer.avgTrainerLv / #trainer.party
		end
		if trainersToExclude[trainer_num] or not TrainerData.shouldUseTrainer(trainer_num) then
			RandomizerLog.Data.Trainers[trainer_num] = nil
		end
		index = index + 1
	end
end

function RandomizerLog.parseRoutes(logLines)
	if RandomizerLog.Sectors.Routes.LineNumber == nil then
		return
	end

	local trainersToExclude = TrainerData.getExcludedTrainers()

	-- First add in routes that have trainers from Tracker data. The Log only has route info for wild encounters
	for mapId, routeInternal in pairs(RouteData.Info or {}) do
		local routeName = (RouteData.Info[mapId] or {}).name
		RandomizerLog.Data.Routes[mapId] = {
			name = routeName or "Unknown Area",
			numTrainers = 0,
			minTrainerLv = nil,
			maxTrainerLv = nil,
			avgTrainerLv = nil,
			numWilds = 0,
			minWildLv = nil,
			maxWildLv = nil,
			EncountersAreas = {},
		}
		local route = RandomizerLog.Data.Routes[mapId]
		if routeInternal.trainers ~= nil then
			route.EncountersAreas.Trainers = {
				logKey = RandomizerLog.EncounterTypes.Trainers.logKey,
				trainers = {},
			}
			-- Determine average level of the trainers in this area
			if #routeInternal.trainers > 0 then
				local numAdded, avgLevel = 0, 0
				for _, trainerId in ipairs(routeInternal.trainers) do
					-- Don't add in extra rivals if we know to remove them
					if not trainersToExclude[trainerId] and TrainerData.shouldUseTrainer(trainerId) then
						local trainerData = RandomizerLog.Data.Trainers[trainerId] or {}
						numAdded = numAdded + 1
						if (trainerData.minlevel or 999) < (route.minTrainerLv or 999) then
							route.minTrainerLv = trainerData.minlevel
						end
						if (trainerData.maxlevel or -1) > (route.maxTrainerLv or 0) then
							route.maxTrainerLv = trainerData.maxlevel
						end
						avgLevel = avgLevel + (trainerData.avgTrainerLv or 0)
						table.insert(route.EncountersAreas.Trainers.trainers, trainerId)
					end
				end
				if numAdded > 0 and avgLevel > 0 then
					route.numTrainers = numAdded
					route.avgTrainerLv = avgLevel / route.numTrainers
				end
			end
		end
	end

	-- The log combines the 3 different fishing rod encounters into a single encounter table
	local fishingEncs = {
		logKey = RandomizerLog.EncounterTypes.OldRod.logKey,
		rates = {},
	}
	for _, rate in ipairs(RandomizerLog.EncounterTypes.OldRod.rates) do
		table.insert(fishingEncs.rates, rate)
	end
	for _, rate in ipairs(RandomizerLog.EncounterTypes.GoodRod.rates) do
		table.insert(fishingEncs.rates, rate)
	end
	for _, rate in ipairs(RandomizerLog.EncounterTypes.SuperRod.rates) do
		table.insert(fishingEncs.rates, rate)
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

		local routeName, encounterTypeKey, isFishingRoute
		for key, encTable in pairs(RandomizerLog.EncounterTypes) do
			-- Only wild encounter data in this section of the log
			if encTable ~= RandomizerLog.EncounterTypes.Trainers then
				local logKey = encTable.logKey or "NO LOG KEY USED"
				local encIndex = string.find(name_encounter, logKey:lower(), 1, true)
				if encIndex ~= nil then
					routeName = name_encounter:sub(1, encIndex - 2) -- Remove trailing space
					encounterTypeKey = key
					isFishingRoute = (logKey == "Fishing")
					break
				end
			end
		end

		local mapId = RandomizerLog.RouteSetNumToIdMap[route_set_num or 0] or 0
		if mapId ~= 0 and encounterTypeKey ~= nil then
			index = index + 1

			if RandomizerLog.Data.Routes[mapId] == nil then
				-- Create the route information table
				RandomizerLog.Data.Routes[mapId] = {
					name = routeName or "Unknown Area",
					numTrainers = 0,
					minTrainerLv = nil,
					maxTrainerLv = nil,
					avgTrainerLv = nil,
					numWilds = 0,
					minWildLv = nil,
					maxWildLv = nil,
					EncountersAreas = {},
				}
			end
			local route = RandomizerLog.Data.Routes[mapId]

			-- Condense route data for multiple encounter areas and trainer sets
			if isFishingRoute then
				route.EncountersAreas.OldRod = { setNumber = route_set_num, key = "OldRod", pokemon = {}, }
				route.EncountersAreas.GoodRod = { setNumber = route_set_num, key = "GoodRod", pokemon = {}, }
				route.EncountersAreas.SuperRod = { setNumber = route_set_num, key = "SuperRod", pokemon = {}, }
			else
				route.EncountersAreas[encounterTypeKey] = {
					setNumber = route_set_num,
					key = encounterTypeKey,
					pokemon = {},
				}
			end

			-- Max 12 total wild encounters, the order determines encounter percentage
			local encounterIndex = 1
			local encounterArea = route.EncountersAreas[encounterTypeKey]
			local encounterRates = RandomizerLog.EncounterTypes[encounterTypeKey].rates or {}

			if isFishingRoute then
				encounterArea = route.EncountersAreas.OldRod
				encounterRates = fishingEncs.rates
			end

			-- Search for each listed wild encounter
			local pokemon, level_min, level_max, bst_spread = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.RoutePokemonPattern)
			while pokemon ~= nil and level_min ~= nil do
				pokemon = RandomizerLog.formatInput(pokemon)
				local pokemonID = RandomizerLog.PokemonNameToIdMap[pokemon]
				if pokemonID ~= nil then
					if isFishingRoute then
						if encounterIndex <= 2 then
							encounterArea = route.EncountersAreas.OldRod
						elseif encounterIndex >= 3 and encounterIndex <= 5 then
							encounterArea = route.EncountersAreas.GoodRod
						else
							encounterArea = route.EncountersAreas.SuperRod
						end
					end

					-- Condense encounter data for multiple listings of the same Pokemon (combine levels & rates)
					if encounterArea.pokemon[pokemonID] == nil then
						encounterArea.pokemon[pokemonID] = {}
					end

					local enc = encounterArea.pokemon[pokemonID]
					local minLv = tonumber(RandomizerLog.formatInput(level_min)) or 0
					local maxLv = tonumber(RandomizerLog.formatInput(level_max)) or minLv
					enc.index = enc.index or encounterIndex
					enc.levelMin = math.min(enc.levelMin or 100, minLv)
					enc.levelMax = math.max(enc.levelMax or 0, maxLv)
					enc.rate = (enc.rate or 0) + (encounterRates[encounterIndex] or 0)
				end

				index = index + 1
				encounterIndex = encounterIndex + 1
				if index > #logLines then
					break
				end
				pokemon, level_min, level_max, bst_spread = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.RoutePokemonPattern)
			end


			-- If the levels for the route's wild encounters haven't been noted yet, do that
			-- Typically grass/cave encounters are parsed first from the log
			if route.minWildLv == nil or route.maxWildLv == nil then
				for _, p in pairs(encounterArea.pokemon or {}) do
					-- Count the # of unique pokemon in this area
					route.numWilds = route.numWilds + 1
					if (p.levelMin or 999) < (route.minWildLv or 999) then
						route.minWildLv = p.levelMin
					end
					if (p.levelMax or -1) > (route.maxWildLv or 0) then
						route.maxWildLv = p.levelMax
					end
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

-- Returns class, name of the trainer; split from 'fullname'
function RandomizerLog.splitTrainerClassAndName(fullname)
	fullname = fullname or ""
	local pattern = "(.-)%s*(%S+)$"
	if fullname:find("&", 1, true) then -- i.e. (Young Couple) (Gia & Jes)
		pattern = "(.-)%s*(%S+%s*&%s*%S+)$"
	elseif fullname:find("Lt. ", 1, true) then -- i.e. (Leader) (Lt. Surge)
		pattern = "(.-)%s*(%S+%s%S+)$"
	end
	local class, name = fullname:match(pattern)
	if name == nil then
		name = class
		class = nil
	end
	return class or "", name or ""
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

	if GameSettings.game == 1 then
		RandomizerLog.setupRubySappRouteMappings()
	elseif GameSettings.game == 2 then
		RandomizerLog.setupEmeraldRouteMappings()
	elseif GameSettings.game == 3 then
		RandomizerLog.setupFRLGRouteMappings()
	end
end

function RandomizerLog.setupRubySappRouteMappings()
	local isGameEmerald = (GameSettings.versioncolor == "Emerald")
	local offset = Utils.inlineIf(isGameEmerald, 0, 1)

	-- Route Set # -> IDs (can't use names, not unique matches)
	RandomizerLog.RouteSetNumToIdMap = {}
	RandomizerLog.RouteSetNumToIdMap[85] = 17 -- route 101 grass/cave
	RandomizerLog.RouteSetNumToIdMap[86] = 18 -- route 102 grass/cave
	RandomizerLog.RouteSetNumToIdMap[87] = 18 -- route 102 surfing
	RandomizerLog.RouteSetNumToIdMap[88] = 18 -- route 102 fishing
	RandomizerLog.RouteSetNumToIdMap[89] = 19 -- route 103 grass/cave
	RandomizerLog.RouteSetNumToIdMap[90] = 19 -- route 103 surfing
	RandomizerLog.RouteSetNumToIdMap[91] = 19 -- route 103 fishing
	RandomizerLog.RouteSetNumToIdMap[92] = 20 -- route 104 grass/cave
	RandomizerLog.RouteSetNumToIdMap[93] = 20 -- route 104 surfing
	RandomizerLog.RouteSetNumToIdMap[94] = 20 -- route 104 fishing
	RandomizerLog.RouteSetNumToIdMap[95] = 21 -- route 105 surfing
	RandomizerLog.RouteSetNumToIdMap[96] = 21 -- route 105 fishing
	RandomizerLog.RouteSetNumToIdMap[105] = 26 -- route 110 grass/cave
	RandomizerLog.RouteSetNumToIdMap[106] = 26 -- route 110 surfing
	RandomizerLog.RouteSetNumToIdMap[107] = 26 -- route 110 fishing
	RandomizerLog.RouteSetNumToIdMap[108] = 27 -- route 111 grass/cave
	RandomizerLog.RouteSetNumToIdMap[109] = 27 -- route 111 surfing
	RandomizerLog.RouteSetNumToIdMap[110] = 27 -- route 111 rock smash
	RandomizerLog.RouteSetNumToIdMap[111] = 27 -- route 111 fishing
	RandomizerLog.RouteSetNumToIdMap[112] = 28 -- route 112 grass/cave
	RandomizerLog.RouteSetNumToIdMap[113] = 29 -- route 113 grass/cave
	RandomizerLog.RouteSetNumToIdMap[114] = 30 -- route 114 grass/cave
	RandomizerLog.RouteSetNumToIdMap[115] = 30 -- route 114 surfing
	RandomizerLog.RouteSetNumToIdMap[116] = 30 -- route 114 rock smash
	RandomizerLog.RouteSetNumToIdMap[117] = 30 -- route 114 fishing
	RandomizerLog.RouteSetNumToIdMap[121] = 32 -- route 116 grass/cave
	RandomizerLog.RouteSetNumToIdMap[122] = 33 -- route 117 grass/cave
	RandomizerLog.RouteSetNumToIdMap[123] = 33 -- route 117 surfing
	RandomizerLog.RouteSetNumToIdMap[124] = 33 -- route 117 fishing
	RandomizerLog.RouteSetNumToIdMap[125] = 34 -- route 118 grass/cave
	RandomizerLog.RouteSetNumToIdMap[126] = 34 -- route 118 surfing
	RandomizerLog.RouteSetNumToIdMap[127] = 34 -- route 118 fishing
	RandomizerLog.RouteSetNumToIdMap[142] = 40 -- route 124 surfing
	RandomizerLog.RouteSetNumToIdMap[143] = 40 -- route 124 fishing
	RandomizerLog.RouteSetNumToIdMap[31] = 135 + offset -- petalburg woods grass/cave
	RandomizerLog.RouteSetNumToIdMap[25] = 129 + offset -- rusturf tunnel grass/cave
	RandomizerLog.RouteSetNumToIdMap[26] = 132 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[27] = 133 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[34] = 137 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[61] = 163 + offset -- victory road grass/cave
	RandomizerLog.RouteSetNumToIdMap[173] = 241 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[178] = 192 + offset -- underwater surfing
	RandomizerLog.RouteSetNumToIdMap[80] = 189 + offset -- abandoned ship surfing
	RandomizerLog.RouteSetNumToIdMap[81] = 189 + offset -- abandoned ship fishing
	RandomizerLog.RouteSetNumToIdMap[28] = 134 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[29] = 134 + offset -- granite cave rock smash
	RandomizerLog.RouteSetNumToIdMap[33] = 293 + offset -- fiery path grass/cave
	RandomizerLog.RouteSetNumToIdMap[13] = 125 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[14] = 125 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[15] = 125 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[32] = 292 + offset -- jagged pass grass/cave
	RandomizerLog.RouteSetNumToIdMap[97] = 22 -- route 106 surfing
	RandomizerLog.RouteSetNumToIdMap[98] = 22 -- route 106 fishing
	RandomizerLog.RouteSetNumToIdMap[99] = 23 -- route 107 surfing
	RandomizerLog.RouteSetNumToIdMap[100] = 23 -- route 107 fishing
	RandomizerLog.RouteSetNumToIdMap[101] = 24 -- route 108 surfing
	RandomizerLog.RouteSetNumToIdMap[102] = 24 -- route 108 fishing
	RandomizerLog.RouteSetNumToIdMap[103] = 25 -- route 109 surfing
	RandomizerLog.RouteSetNumToIdMap[104] = 25 -- route 109 fishing
	RandomizerLog.RouteSetNumToIdMap[118] = 31 -- route 115 grass/cave
	RandomizerLog.RouteSetNumToIdMap[119] = 31 -- route 115 surfing
	RandomizerLog.RouteSetNumToIdMap[120] = 31 -- route 115 fishing
	RandomizerLog.RouteSetNumToIdMap[77] = 185 + offset -- new mauville grass/cave
	RandomizerLog.RouteSetNumToIdMap[128] = 35 -- route 119 grass/cave
	RandomizerLog.RouteSetNumToIdMap[129] = 35 -- route 119 surfing
	RandomizerLog.RouteSetNumToIdMap[130] = 35 -- route 119 fishing
	RandomizerLog.RouteSetNumToIdMap[131] = 36 -- route 120 grass/cave
	RandomizerLog.RouteSetNumToIdMap[132] = 36 -- route 120 surfing
	RandomizerLog.RouteSetNumToIdMap[133] = 36 -- route 120 fishing
	RandomizerLog.RouteSetNumToIdMap[134] = 37 -- route 121 grass/cave
	RandomizerLog.RouteSetNumToIdMap[135] = 37 -- route 121 surfing
	RandomizerLog.RouteSetNumToIdMap[136] = 37 -- route 121 fishing
	RandomizerLog.RouteSetNumToIdMap[137] = 38 -- route 122 surfing
	RandomizerLog.RouteSetNumToIdMap[138] = 38 -- route 122 fishing
	RandomizerLog.RouteSetNumToIdMap[139] = 39 -- route 123 grass/cave
	RandomizerLog.RouteSetNumToIdMap[140] = 39 -- route 123 surfing
	RandomizerLog.RouteSetNumToIdMap[141] = 39 -- route 123 fishing
	RandomizerLog.RouteSetNumToIdMap[35] = 138 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[36] = 139 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[37] = 140 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[38] = 141 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[39] = 142 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[40] = 302 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[41] = 303 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[30] = 288 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[144] = 41 -- route 125 surfing
	RandomizerLog.RouteSetNumToIdMap[145] = 41 -- route 125 fishing
	RandomizerLog.RouteSetNumToIdMap[146] = 42 -- route 126 surfing
	RandomizerLog.RouteSetNumToIdMap[147] = 42 -- route 126 fishing
	RandomizerLog.RouteSetNumToIdMap[148] = 43 -- route 127 surfing
	RandomizerLog.RouteSetNumToIdMap[149] = 43 -- route 127 fishing
	RandomizerLog.RouteSetNumToIdMap[150] = 44 -- route 128 surfing
	RandomizerLog.RouteSetNumToIdMap[151] = 44 -- route 128 fishing
	RandomizerLog.RouteSetNumToIdMap[152] = 45 -- route 129 surfing
	RandomizerLog.RouteSetNumToIdMap[153] = 45 -- route 129 fishing
	RandomizerLog.RouteSetNumToIdMap[154] = 46 -- route 130 grass/cave
	RandomizerLog.RouteSetNumToIdMap[155] = 46 -- route 130 surfing
	RandomizerLog.RouteSetNumToIdMap[156] = 46 -- route 130 fishing
	RandomizerLog.RouteSetNumToIdMap[157] = 47 -- route 131 surfing
	RandomizerLog.RouteSetNumToIdMap[158] = 47 -- route 131 fishing
	RandomizerLog.RouteSetNumToIdMap[159] = 48 -- route 132 surfing
	RandomizerLog.RouteSetNumToIdMap[160] = 48 -- route 132 fishing
	RandomizerLog.RouteSetNumToIdMap[161] = 49 -- route 133 surfing
	RandomizerLog.RouteSetNumToIdMap[162] = 49 -- route 133 fishing
	RandomizerLog.RouteSetNumToIdMap[163] = 50 -- route 134 surfing
	RandomizerLog.RouteSetNumToIdMap[164] = 50 -- route 134 fishing
	RandomizerLog.RouteSetNumToIdMap[78] = 189 + offset -- abandoned ship surfing
	RandomizerLog.RouteSetNumToIdMap[79] = 189 + offset -- abandoned ship fishing
	RandomizerLog.RouteSetNumToIdMap[45] = 148 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[46] = 149 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[47] = 150 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[48] = 151 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[49] = 152 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[44] = 147 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[42] = 147 + offset -- seafloor cavern surfing
	RandomizerLog.RouteSetNumToIdMap[43] = 147 + offset -- seafloor cavern fishing
	RandomizerLog.RouteSetNumToIdMap[52] = 153 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[50] = 153 + offset -- seafloor cavern surfing
	RandomizerLog.RouteSetNumToIdMap[51] = 153 + offset -- seafloor cavern fishing
	RandomizerLog.RouteSetNumToIdMap[55] = 154 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[53] = 154 + offset -- seafloor cavern surfing
	RandomizerLog.RouteSetNumToIdMap[54] = 154 + offset -- seafloor cavern fishing
	RandomizerLog.RouteSetNumToIdMap[56] = 157 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[57] = 158 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[58] = 159 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[59] = 160 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[60] = 161 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[76] = 184 + offset -- new mauville grass/cave
	RandomizerLog.RouteSetNumToIdMap[165] = 238 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[166] = 238 + offset -- safari zone surfing
	RandomizerLog.RouteSetNumToIdMap[167] = 238 + offset -- safari zone fishing
	RandomizerLog.RouteSetNumToIdMap[168] = 239 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[169] = 239 + offset -- safari zone rock smash
	RandomizerLog.RouteSetNumToIdMap[170] = 240 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[171] = 240 + offset -- safari zone surfing
	RandomizerLog.RouteSetNumToIdMap[172] = 240 + offset -- safari zone fishing
	RandomizerLog.RouteSetNumToIdMap[62] = 285 + offset -- victory road grass/cave
	RandomizerLog.RouteSetNumToIdMap[63] = 285 + offset -- victory road rock smash
	RandomizerLog.RouteSetNumToIdMap[64] = 286 + offset -- victory road grass/cave
	RandomizerLog.RouteSetNumToIdMap[65] = 286 + offset -- victory road surfing
	RandomizerLog.RouteSetNumToIdMap[66] = 286 + offset -- victory road fishing
	RandomizerLog.RouteSetNumToIdMap[16] = 126 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[17] = 126 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[18] = 126 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[19] = 127 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[20] = 127 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[21] = 127 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[22] = 128 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[23] = 128 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[24] = 128 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[73] = 164 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[74] = 165 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[67] = 168 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[68] = 168 + offset -- shoal cave surfing
	RandomizerLog.RouteSetNumToIdMap[69] = 168 + offset -- shoal cave fishing
	RandomizerLog.RouteSetNumToIdMap[70] = 169 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[71] = 169 + offset -- shoal cave surfing
	RandomizerLog.RouteSetNumToIdMap[72] = 169 + offset -- shoal cave fishing
	RandomizerLog.RouteSetNumToIdMap[5] = 6 -- lilycove city surfing
	RandomizerLog.RouteSetNumToIdMap[6] = 6 -- lilycove city fishing
	RandomizerLog.RouteSetNumToIdMap[174] = 12 -- dewford town surfing
	RandomizerLog.RouteSetNumToIdMap[175] = 12 -- dewford town fishing
	RandomizerLog.RouteSetNumToIdMap[3] = 2 -- slateport city surfing
	RandomizerLog.RouteSetNumToIdMap[4] = 2 -- slateport city fishing
	RandomizerLog.RouteSetNumToIdMap[7] = 7 -- mossdeep city surfing
	RandomizerLog.RouteSetNumToIdMap[8] = 7 -- mossdeep city fishing
	RandomizerLog.RouteSetNumToIdMap[176] = 16 -- pacifidlog town surfing
	RandomizerLog.RouteSetNumToIdMap[177] = 16 -- pacifidlog town fishing
	RandomizerLog.RouteSetNumToIdMap[11] = 9 -- ever grande city surfing
	RandomizerLog.RouteSetNumToIdMap[12] = 9 -- ever grande city fishing
	RandomizerLog.RouteSetNumToIdMap[1] = 1 -- petalburg city surfing
	RandomizerLog.RouteSetNumToIdMap[2] = 1 -- petalburg city fishing
	RandomizerLog.RouteSetNumToIdMap[179] = 196 + offset -- underwater surfing
	RandomizerLog.RouteSetNumToIdMap[75] = 167 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[82] = 322 + offset -- sky pillar grass/cave
	RandomizerLog.RouteSetNumToIdMap[9] = 8 -- sootopolis city surfing
	RandomizerLog.RouteSetNumToIdMap[10] = 8 -- sootopolis city fishing
	RandomizerLog.RouteSetNumToIdMap[83] = 324 + offset -- sky pillar grass/cave
	RandomizerLog.RouteSetNumToIdMap[84] = 330 + offset -- sky pillar grass/cave
end

function RandomizerLog.setupEmeraldRouteMappings()
	local isGameEmerald = (GameSettings.versioncolor == "Emerald")
	local offset = Utils.inlineIf(isGameEmerald, 0, 1)

	-- Route Set # -> IDs (can't use names, not unique matches)
	RandomizerLog.RouteSetNumToIdMap = {}
	RandomizerLog.RouteSetNumToIdMap[1] = 17 -- route 101 grass/cave
	RandomizerLog.RouteSetNumToIdMap[2] = 18 -- route 102 grass/cave
	RandomizerLog.RouteSetNumToIdMap[3] = 18 -- route 102 surfing
	RandomizerLog.RouteSetNumToIdMap[4] = 18 -- route 102 fishing
	RandomizerLog.RouteSetNumToIdMap[5] = 19 -- route 103 grass/cave
	RandomizerLog.RouteSetNumToIdMap[6] = 19 -- route 103 surfing
	RandomizerLog.RouteSetNumToIdMap[7] = 19 -- route 103 fishing
	RandomizerLog.RouteSetNumToIdMap[8] = 20 -- route 104 grass/cave
	RandomizerLog.RouteSetNumToIdMap[9] = 20 -- route 104 surfing
	RandomizerLog.RouteSetNumToIdMap[10] = 20 -- route 104 fishing
	RandomizerLog.RouteSetNumToIdMap[11] = 21 -- route 105 surfing
	RandomizerLog.RouteSetNumToIdMap[12] = 21 -- route 105 fishing
	RandomizerLog.RouteSetNumToIdMap[13] = 26 -- route 110 grass/cave
	RandomizerLog.RouteSetNumToIdMap[14] = 26 -- route 110 surfing
	RandomizerLog.RouteSetNumToIdMap[15] = 26 -- route 110 fishing
	RandomizerLog.RouteSetNumToIdMap[16] = 27 -- route 111 grass/cave
	RandomizerLog.RouteSetNumToIdMap[17] = 27 -- route 111 surfing
	RandomizerLog.RouteSetNumToIdMap[18] = 27 -- route 111 rock smash
	RandomizerLog.RouteSetNumToIdMap[19] = 27 -- route 111 fishing
	RandomizerLog.RouteSetNumToIdMap[20] = 28 -- route 112 grass/cave
	RandomizerLog.RouteSetNumToIdMap[21] = 29 -- route 113 grass/cave
	RandomizerLog.RouteSetNumToIdMap[22] = 30 -- route 114 grass/cave
	RandomizerLog.RouteSetNumToIdMap[23] = 30 -- route 114 surfing
	RandomizerLog.RouteSetNumToIdMap[24] = 30 -- route 114 rock smash
	RandomizerLog.RouteSetNumToIdMap[25] = 30 -- route 114 fishing
	RandomizerLog.RouteSetNumToIdMap[26] = 32 -- route 116 grass/cave
	RandomizerLog.RouteSetNumToIdMap[27] = 33 -- route 117 grass/cave
	RandomizerLog.RouteSetNumToIdMap[28] = 33 -- route 117 surfing
	RandomizerLog.RouteSetNumToIdMap[29] = 33 -- route 117 fishing
	RandomizerLog.RouteSetNumToIdMap[30] = 34 -- route 118 grass/cave
	RandomizerLog.RouteSetNumToIdMap[31] = 34 -- route 118 surfing
	RandomizerLog.RouteSetNumToIdMap[32] = 34 -- route 118 fishing
	RandomizerLog.RouteSetNumToIdMap[33] = 40 -- route 124 surfing
	RandomizerLog.RouteSetNumToIdMap[34] = 40 -- route 124 fishing
	RandomizerLog.RouteSetNumToIdMap[35] = 135 + offset -- petalburg woods grass/cave
	RandomizerLog.RouteSetNumToIdMap[36] = 129 + offset -- rusturf tunnel grass/cave
	RandomizerLog.RouteSetNumToIdMap[37] = 132 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[38] = 133 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[39] = 137 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[40] = 163 + offset -- victory road grass/cave
	RandomizerLog.RouteSetNumToIdMap[41] = 241 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[42] = 192 + offset -- underwater surfing
	RandomizerLog.RouteSetNumToIdMap[43] = 189 + offset -- abandoned ship surfing
	RandomizerLog.RouteSetNumToIdMap[44] = 189 + offset -- abandoned ship fishing
	RandomizerLog.RouteSetNumToIdMap[45] = 134 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[46] = 134 + offset -- granite cave rock smash
	RandomizerLog.RouteSetNumToIdMap[47] = 293 + offset -- fiery path grass/cave
	RandomizerLog.RouteSetNumToIdMap[48] = 125 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[49] = 125 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[50] = 125 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[51] = 292 + offset -- jagged pass grass/cave
	RandomizerLog.RouteSetNumToIdMap[52] = 22 -- route 106 surfing
	RandomizerLog.RouteSetNumToIdMap[53] = 22 -- route 106 fishing
	RandomizerLog.RouteSetNumToIdMap[54] = 23 -- route 107 surfing
	RandomizerLog.RouteSetNumToIdMap[55] = 23 -- route 107 fishing
	RandomizerLog.RouteSetNumToIdMap[56] = 24 -- route 108 surfing
	RandomizerLog.RouteSetNumToIdMap[57] = 24 -- route 108 fishing
	RandomizerLog.RouteSetNumToIdMap[58] = 25 -- route 109 surfing
	RandomizerLog.RouteSetNumToIdMap[59] = 25 -- route 109 fishing
	RandomizerLog.RouteSetNumToIdMap[60] = 31 -- route 115 grass/cave
	RandomizerLog.RouteSetNumToIdMap[61] = 31 -- route 115 surfing
	RandomizerLog.RouteSetNumToIdMap[62] = 31 -- route 115 fishing
	RandomizerLog.RouteSetNumToIdMap[63] = 185 + offset -- new mauville grass/cave
	RandomizerLog.RouteSetNumToIdMap[64] = 35 -- route 119 grass/cave
	RandomizerLog.RouteSetNumToIdMap[65] = 35 -- route 119 surfing
	RandomizerLog.RouteSetNumToIdMap[66] = 35 -- route 119 fishing
	RandomizerLog.RouteSetNumToIdMap[67] = 36 -- route 120 grass/cave
	RandomizerLog.RouteSetNumToIdMap[68] = 36 -- route 120 surfing
	RandomizerLog.RouteSetNumToIdMap[69] = 36 -- route 120 fishing
	RandomizerLog.RouteSetNumToIdMap[70] = 37 -- route 121 grass/cave
	RandomizerLog.RouteSetNumToIdMap[71] = 37 -- route 121 surfing
	RandomizerLog.RouteSetNumToIdMap[72] = 37 -- route 121 fishing
	RandomizerLog.RouteSetNumToIdMap[73] = 38 -- route 122 surfing
	RandomizerLog.RouteSetNumToIdMap[74] = 38 -- route 122 fishing
	RandomizerLog.RouteSetNumToIdMap[75] = 39 -- route 123 grass/cave
	RandomizerLog.RouteSetNumToIdMap[76] = 39 -- route 123 surfing
	RandomizerLog.RouteSetNumToIdMap[77] = 39 -- route 123 fishing
	RandomizerLog.RouteSetNumToIdMap[78] = 138 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[79] = 139 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[80] = 140 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[81] = 141 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[82] = 142 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[83] = 302 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[84] = 303 + offset -- mt. pyre grass/cave
	RandomizerLog.RouteSetNumToIdMap[85] = 288 + offset -- granite cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[86] = 41 -- route 125 surfing
	RandomizerLog.RouteSetNumToIdMap[87] = 41 -- route 125 fishing
	RandomizerLog.RouteSetNumToIdMap[88] = 42 -- route 126 surfing
	RandomizerLog.RouteSetNumToIdMap[89] = 42 -- route 126 fishing
	RandomizerLog.RouteSetNumToIdMap[90] = 43 -- route 127 surfing
	RandomizerLog.RouteSetNumToIdMap[91] = 43 -- route 127 fishing
	RandomizerLog.RouteSetNumToIdMap[92] = 44 -- route 128 surfing
	RandomizerLog.RouteSetNumToIdMap[93] = 44 -- route 128 fishing
	RandomizerLog.RouteSetNumToIdMap[94] = 45 -- route 129 surfing
	RandomizerLog.RouteSetNumToIdMap[95] = 45 -- route 129 fishing
	RandomizerLog.RouteSetNumToIdMap[96] = 46 -- route 130 grass/cave
	RandomizerLog.RouteSetNumToIdMap[97] = 46 -- route 130 surfing
	RandomizerLog.RouteSetNumToIdMap[98] = 46 -- route 130 fishing
	RandomizerLog.RouteSetNumToIdMap[99] = 47 -- route 131 surfing
	RandomizerLog.RouteSetNumToIdMap[100] = 47 -- route 131 fishing
	RandomizerLog.RouteSetNumToIdMap[101] = 48 -- route 132 surfing
	RandomizerLog.RouteSetNumToIdMap[102] = 48 -- route 132 fishing
	RandomizerLog.RouteSetNumToIdMap[103] = 49 -- route 133 surfing
	RandomizerLog.RouteSetNumToIdMap[104] = 49 -- route 133 fishing
	RandomizerLog.RouteSetNumToIdMap[105] = 50 -- route 134 surfing
	RandomizerLog.RouteSetNumToIdMap[106] = 50 -- route 134 fishing
	RandomizerLog.RouteSetNumToIdMap[107] = 189 + offset -- abandoned ship surfing
	RandomizerLog.RouteSetNumToIdMap[108] = 189 + offset -- abandoned ship fishing
	RandomizerLog.RouteSetNumToIdMap[109] = 148 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[110] = 149 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[111] = 150 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[112] = 151 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[113] = 152 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[114] = 147 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[115] = 147 + offset -- seafloor cavern surfing
	RandomizerLog.RouteSetNumToIdMap[116] = 147 + offset -- seafloor cavern fishing
	RandomizerLog.RouteSetNumToIdMap[117] = 153 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[118] = 153 + offset -- seafloor cavern surfing
	RandomizerLog.RouteSetNumToIdMap[119] = 153 + offset -- seafloor cavern fishing
	RandomizerLog.RouteSetNumToIdMap[120] = 154 + offset -- seafloor cavern grass/cave
	RandomizerLog.RouteSetNumToIdMap[121] = 154 + offset -- seafloor cavern surfing
	RandomizerLog.RouteSetNumToIdMap[122] = 154 + offset -- seafloor cavern fishing
	RandomizerLog.RouteSetNumToIdMap[123] = 157 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[124] = 158 + offset -- cave of origin grass/cave
	-- Next 3 are in Emerald only
	RandomizerLog.RouteSetNumToIdMap[125] = 162 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[126] = 162 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[127] = 162 + offset -- cave of origin grass/cave
	RandomizerLog.RouteSetNumToIdMap[128] = 184 + offset -- new mauville grass/cave
	RandomizerLog.RouteSetNumToIdMap[129] = 238 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[130] = 238 + offset -- safari zone surfing
	RandomizerLog.RouteSetNumToIdMap[131] = 238 + offset -- safari zone fishing
	RandomizerLog.RouteSetNumToIdMap[132] = 239 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[133] = 239 + offset -- safari zone rock smash
	RandomizerLog.RouteSetNumToIdMap[134] = 240 + offset -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[135] = 240 + offset -- safari zone surfing
	RandomizerLog.RouteSetNumToIdMap[136] = 240 + offset -- safari zone fishing
	RandomizerLog.RouteSetNumToIdMap[137] = 285 + offset -- victory road grass/cave
	RandomizerLog.RouteSetNumToIdMap[138] = 285 + offset -- victory road rock smash
	RandomizerLog.RouteSetNumToIdMap[139] = 286 + offset -- victory road grass/cave
	RandomizerLog.RouteSetNumToIdMap[140] = 286 + offset -- victory road surfing
	RandomizerLog.RouteSetNumToIdMap[141] = 286 + offset -- victory road fishing
	RandomizerLog.RouteSetNumToIdMap[142] = 126 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[143] = 126 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[144] = 126 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[145] = 127 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[146] = 127 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[147] = 127 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[148] = 128 + offset -- meteor falls grass/cave
	RandomizerLog.RouteSetNumToIdMap[149] = 128 + offset -- meteor falls surfing
	RandomizerLog.RouteSetNumToIdMap[150] = 128 + offset -- meteor falls fishing
	RandomizerLog.RouteSetNumToIdMap[151] = 164 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[152] = 165 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[153] = 168 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[154] = 168 + offset -- shoal cave surfing
	RandomizerLog.RouteSetNumToIdMap[155] = 168 + offset -- shoal cave fishing
	RandomizerLog.RouteSetNumToIdMap[156] = 169 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[157] = 169 + offset -- shoal cave surfing
	RandomizerLog.RouteSetNumToIdMap[158] = 169 + offset -- shoal cave fishing
	RandomizerLog.RouteSetNumToIdMap[159] = 6 -- lilycove city surfing
	RandomizerLog.RouteSetNumToIdMap[160] = 6 -- lilycove city fishing
	RandomizerLog.RouteSetNumToIdMap[161] = 12 -- dewford town surfing
	RandomizerLog.RouteSetNumToIdMap[162] = 12 -- dewford town fishing
	RandomizerLog.RouteSetNumToIdMap[163] = 2 -- slateport city surfing
	RandomizerLog.RouteSetNumToIdMap[164] = 2 -- slateport city fishing
	RandomizerLog.RouteSetNumToIdMap[165] = 7 -- mossdeep city surfing
	RandomizerLog.RouteSetNumToIdMap[166] = 7 -- mossdeep city fishing
	RandomizerLog.RouteSetNumToIdMap[167] = 16 -- pacifidlog town surfing
	RandomizerLog.RouteSetNumToIdMap[168] = 16 -- pacifidlog town fishing
	RandomizerLog.RouteSetNumToIdMap[169] = 9 -- ever grande city surfing
	RandomizerLog.RouteSetNumToIdMap[170] = 9 -- ever grande city fishing
	RandomizerLog.RouteSetNumToIdMap[171] = 1 -- petalburg city surfing
	RandomizerLog.RouteSetNumToIdMap[172] = 1 -- petalburg city fishing
	RandomizerLog.RouteSetNumToIdMap[173] = 196 + offset -- underwater surfing
	RandomizerLog.RouteSetNumToIdMap[174] = 167 + offset -- shoal cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[175] = 322 + offset -- sky pillar grass/cave
	RandomizerLog.RouteSetNumToIdMap[176] = 8 -- sootopolis city surfing
	RandomizerLog.RouteSetNumToIdMap[177] = 8 -- sootopolis city fishing
	RandomizerLog.RouteSetNumToIdMap[178] = 324 + offset -- sky pillar grass/cave
	RandomizerLog.RouteSetNumToIdMap[179] = 330 + offset -- sky pillar grass/cave
	-- Emerald Required from here on...
	RandomizerLog.RouteSetNumToIdMap[180] = 395 -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[181] = 395 -- safari zone surfing
	RandomizerLog.RouteSetNumToIdMap[182] = 395 -- safari zone fishing
	RandomizerLog.RouteSetNumToIdMap[183] = 394 -- safari zone grass/cave
	RandomizerLog.RouteSetNumToIdMap[184] = 394 -- safari zone rock smash
	RandomizerLog.RouteSetNumToIdMap[185] = 336 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[186] = 337 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[187] = 338 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[188] = 339 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[189] = 340 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[190] = 341 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[191] = 379 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[192] = 380 -- magma hideout grass/cave
	RandomizerLog.RouteSetNumToIdMap[193] = 381 -- mirage tower grass/cave
	RandomizerLog.RouteSetNumToIdMap[194] = 382 -- mirage tower grass/cave
	RandomizerLog.RouteSetNumToIdMap[195] = 383 -- mirage tower grass/cave
	RandomizerLog.RouteSetNumToIdMap[196] = 388 -- mirage tower grass/cave
	RandomizerLog.RouteSetNumToIdMap[197] = 389 -- desert underpass grass/cave
	RandomizerLog.RouteSetNumToIdMap[198] = 400 -- artisan cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[199] = 401 -- artisan cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[200] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[201] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[202] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[203] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[204] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[205] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[206] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[207] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[208] = 340 -- altering cave grass/cave
	RandomizerLog.RouteSetNumToIdMap[209] = 431 -- meteor falls grass/cave
end

function RandomizerLog.setupFRLGRouteMappings()
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
	RandomizerLog.RouteSetNumToIdMap[12] = 118 -- s.s. anne (surfing)
	RandomizerLog.RouteSetNumToIdMap[13] = 118 -- s.s. anne (fishing)
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
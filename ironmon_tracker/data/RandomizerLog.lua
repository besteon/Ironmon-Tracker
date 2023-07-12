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
		NextTrainerPattern = "^#(%d+)%s%((.+)%s*=>.*%s%-%s(.*)",
		-- Matches: partypokemon (pokemon name with held item and level info)
		PartyPattern = "([^,]+)",
		-- Matches: pokemon and helditem[optional], level
		PartyPokemonPattern = "%s*(.-)%sLv(%d+)",
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
		local trainer_num, trainername, party = string.match(logLines[index] or "", RandomizerLog.Sectors.Trainers.NextTrainerPattern)
		trainer_num = tonumber(RandomizerLog.formatInput(trainer_num) or "") -- nil if not a number
		trainername = RandomizerLog.formatInput(trainername)

		-- If nothing matches, end of sector
		if trainer_num == nil or trainername == nil or party == nil then
			return
		end

		RandomizerLog.Data.Trainers[trainer_num] = {
			name = trainername, -- likely in the form of TRAINER CLASS + TRAINER NAME
			party = {},
		}

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
				}
				table.insert(RandomizerLog.Data.Trainers[trainer_num].party, partyPokemon)
			end
		end
		index = index + 1
	end
end

-- Currently unused
function RandomizerLog.parsePickupItems(logLines)
	-- Utils.printDebug("#%s: %s >%s< %s", trainer_num, pokemon or "N/A", helditem or "N/A", level or 0)
end

function RandomizerLog.setupMappings()
	local allMovesSource = MoveData.Moves
	local allAbilitiesSource = AbilityData.Abilities

	-- If the game's language and tracker's display language don't match, load relevant Resources using the game language
	if GameSettings.language:upper() ~= Resources.currentLanguage.Key:upper() then
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
end

function RandomizerLog.removeMappings()
	RandomizerLog.PokemonNameToIdMap = nil
	RandomizerLog.MoveNameToIdMap = nil
	RandomizerLog.AbilityNameToIdMap = nil
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
		local originalCallback = GameResources -- Temp store the old callback function while reading in some Game Resources
		GameResources = function(data) dataLoadHelper("Game", data) end
		-- Load language resources into gamedata
		dofile(langFilePath)
		Resources.sanitizeTable(gamedata)
		GameResources = originalCallback
	end

	return gamedata
end
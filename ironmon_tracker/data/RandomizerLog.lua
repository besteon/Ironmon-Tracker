-- A collection of tools for viewing a Randomized Pokémon game log
RandomizerLog = {
	loadedLogPath = nil, -- Holds the path of the previously loaded log file. This is used to check if a new file needs to be parsed
}

RandomizerLog.Patterns = {
	RandomizerVersion = "Randomizer Version:%s*([%d%.]+).*$", -- Note: log file line 1 does NOT start with "Rando..."
	RandomizerSeed = "^Random Seed:%s*(%d+)%s*$",
	RandomizerSettings = "^Settings String:%s*(.+)%s*$",
	RandomizerGame = "^Randomization of%s*(.+)%s+completed",
	PokemonName = "([%a%d%.]* ?[%a%d%.!'%-♀♂%?]+).-",
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
		PokemonEvosPattern = "^" .. RandomizerLog.Patterns.PokemonName .. "%s*%->%s*(.*)",
	},
	BaseStatsItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Base Stats & Types"),
		-- Matches: id, pokemon, types, hp, atk, def, spatk, spdef, spd, ability1, ability2, helditems
		PokemonBSTPattern = "^%s*(%d*)|" .. RandomizerLog.Patterns.PokemonName .. "%s*|(.-)%s*|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|(.-)%s*|(.-)%s*|(.*)",
	},
	MoveSets = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Movesets"),
		-- Matches: pokemon
		NextMonPattern = "^%d+%s" .. RandomizerLog.Patterns.PokemonName .. "%s*%->",
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
		NextMonPattern = "^%s*%d+%s*" .. RandomizerLog.Patterns.PokemonName .. "%s*|(.*)",
		-- Matches: tmNumber
		TMPattern = "TM(%d+)",
	},
	Trainers = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Trainers Pokemon"),
		-- Matches: trainer_num, trainername, party
		NextTrainerPattern = "^#(%d+)%s%((.+)%s*=>.*%s%-%s(.*)",
		-- Matches: partypokemon (pokemon name with held item and level info)
		PartyPattern = "([^,]+)",
		-- Matches: pokemon, helditem[optional], level
		PartyPokemonPattern = "%s*" .. RandomizerLog.Patterns.PokemonName .. "@?(.-)%sLv(%d+)",
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

-- A table of parsed data from the log file: Settings, Pokemon, TMs, Trainers, PickupItems
RandomizerLog.Data = {}

-- Parses the log file at 'filepath' into the data object RandomizerLog.Data
function RandomizerLog.parseLog(filepath)
	Utils.tempDisableBizhawkSound()
	local logLines = FileManager.readLinesFromFile(filepath)
	if #logLines == 0 then
		Utils.tempEnableBizhawkSound()
		return false
	end

	RandomizerLog.resetData()
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
	str = str:gsub("♀", " F")
	str = str:gsub("♂", " M")
	str = str:gsub("%?", "")
	str = str:gsub("’", "'")
	str = str:gsub("é", Constants.getC("é"))
	str = str:gsub("%[PK%]%[MN%]", "PKMN")
	str = str:match("^%s*(.-)%s*$") or str -- remove leading/trailing spaces
	return str:lower()
end

RandomizerLog.currentNidoranIsF = true

-- In some cases, the ♀/♂ in nidoran's names are stripped out. This is only way to figure out which is which
function RandomizerLog.alternateNidorans(name)
	if name == nil or name == "" or name:lower() ~= "nidoran" then return name end

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
function RandomizerLog.resetData()
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
		for evo in string.gmatch(evos, RandomizerLog.Patterns.PokemonName) do
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
			local pokemon, helditem, level = string.match(partypokemon, RandomizerLog.Sectors.Trainers.PartyPokemonPattern)
			pokemon = RandomizerLog.formatInput(pokemon)
			pokemon = RandomizerLog.alternateNidorans(pokemon)
			helditem = RandomizerLog.formatInput(helditem)
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

-- DEBUG HELPER, will use later for foreign games
function RandomizerLog.printPokemonIds()
	local count = 0
	local mons = {}
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		if PokemonData.isValid(id) then
			table.insert(mons, string.format('["%s"] = %s,', pokemon.name:lower(), id))
			count = count + 1
		end
		-- Print 20 lines at a time
		if count >= 20 then
			print(table.concat(mons, "\n"))
			mons = {}
			count = count - 20
		end
	end
	if count >= 1 then
		print(table.concat(mons, "\n"))
		mons = {}
	end
end

-- DEBUG HELPER, will use later for foreign games
function RandomizerLog.printMoveIds()
	local count = 0
	local moves = {}
	for id, move in ipairs(MoveData.Moves) do
		if MoveData.isValid(id) then
			table.insert(moves, string.format('["%s"] = %s,', move.name:lower(), id))
			count = count + 1
		end
		-- Print 20 lines at a time
		if count >= 20 then
			print(table.concat(moves, "\n"))
			moves = {}
			count = count - 20
		end
	end
	if count >= 1 then
		print(table.concat(moves, "\n"))
		moves = {}
	end
end

function RandomizerLog.setupMappings()
	RandomizerLog.PokemonNameToIdMap = {} -- setup later while parsing the first important log sector
	RandomizerLog.MoveNameToIdMap = {
		["pound"] = 1,
		["karate chop"] = 2,
		["doubleslap"] = 3,
		["comet punch"] = 4,
		["mega punch"] = 5,
		["pay day"] = 6,
		["fire punch"] = 7,
		["ice punch"] = 8,
		["thunderpunch"] = 9,
		["scratch"] = 10,
		["vicegrip"] = 11,
		["guillotine"] = 12,
		["razor wind"] = 13,
		["swords dance"] = 14,
		["cut"] = 15,
		["gust"] = 16,
		["wing attack"] = 17,
		["whirlwind"] = 18,
		["fly"] = 19,
		["bind"] = 20,
		["slam"] = 21,
		["vine whip"] = 22,
		["stomp"] = 23,
		["double kick"] = 24,
		["mega kick"] = 25,
		["jump kick"] = 26,
		["rolling kick"] = 27,
		["sand-attack"] = 28,
		["headbutt"] = 29,
		["horn attack"] = 30,
		["fury attack"] = 31,
		["horn drill"] = 32,
		["tackle"] = 33,
		["body slam"] = 34,
		["wrap"] = 35,
		["take down"] = 36,
		["thrash"] = 37,
		["double-edge"] = 38,
		["tail whip"] = 39,
		["poison sting"] = 40,
		["twineedle"] = 41,
		["pin missile"] = 42,
		["leer"] = 43,
		["bite"] = 44,
		["growl"] = 45,
		["roar"] = 46,
		["sing"] = 47,
		["supersonic"] = 48,
		["sonicboom"] = 49,
		["disable"] = 50,
		["acid"] = 51,
		["ember"] = 52,
		["flamethrower"] = 53,
		["mist"] = 54,
		["water gun"] = 55,
		["hydro pump"] = 56,
		["surf"] = 57,
		["ice beam"] = 58,
		["blizzard"] = 59,
		["psybeam"] = 60,
		["bubblebeam"] = 61,
		["aurora beam"] = 62,
		["hyper beam"] = 63,
		["peck"] = 64,
		["drill peck"] = 65,
		["submission"] = 66,
		["low kick"] = 67,
		["counter"] = 68,
		["seismic toss"] = 69,
		["strength"] = 70,
		["absorb"] = 71,
		["mega drain"] = 72,
		["leech seed"] = 73,
		["growth"] = 74,
		["razor leaf"] = 75,
		["solarbeam"] = 76,
		["poisonpowder"] = 77,
		["stun spore"] = 78,
		["sleep powder"] = 79,
		["petal dance"] = 80,
		["string shot"] = 81,
		["dragon rage"] = 82,
		["fire spin"] = 83,
		["thundershock"] = 84,
		["thunderbolt"] = 85,
		["thunder wave"] = 86,
		["thunder"] = 87,
		["rock throw"] = 88,
		["earthquake"] = 89,
		["fissure"] = 90,
		["dig"] = 91,
		["toxic"] = 92,
		["confusion"] = 93,
		["psychic"] = 94,
		["hypnosis"] = 95,
		["meditate"] = 96,
		["agility"] = 97,
		["quick attack"] = 98,
		["rage"] = 99,
		["teleport"] = 100,
		["night shade"] = 101,
		["mimic"] = 102,
		["screech"] = 103,
		["double team"] = 104,
		["recover"] = 105,
		["harden"] = 106,
		["minimize"] = 107,
		["smokescreen"] = 108,
		["confuse ray"] = 109,
		["withdraw"] = 110,
		["defense curl"] = 111,
		["barrier"] = 112,
		["light screen"] = 113,
		["haze"] = 114,
		["reflect"] = 115,
		["focus energy"] = 116,
		["bide"] = 117,
		["metronome"] = 118,
		["mirror move"] = 119,
		["selfdestruct"] = 120,
		["egg bomb"] = 121,
		["lick"] = 122,
		["smog"] = 123,
		["sludge"] = 124,
		["bone club"] = 125,
		["fire blast"] = 126,
		["waterfall"] = 127,
		["clamp"] = 128,
		["swift"] = 129,
		["skull bash"] = 130,
		["spike cannon"] = 131,
		["constrict"] = 132,
		["amnesia"] = 133,
		["kinesis"] = 134,
		["softboiled"] = 135,
		["hi jump kick"] = 136,
		["glare"] = 137,
		["dream eater"] = 138,
		["poison gas"] = 139,
		["barrage"] = 140,
		["leech life"] = 141,
		["lovely kiss"] = 142,
		["sky attack"] = 143,
		["transform"] = 144,
		["bubble"] = 145,
		["dizzy punch"] = 146,
		["spore"] = 147,
		["flash"] = 148,
		["psywave"] = 149,
		["splash"] = 150,
		["acid armor"] = 151,
		["crabhammer"] = 152,
		["explosion"] = 153,
		["fury swipes"] = 154,
		["bonemerang"] = 155,
		["rest"] = 156,
		["rock slide"] = 157,
		["hyper fang"] = 158,
		["sharpen"] = 159,
		["conversion"] = 160,
		["tri attack"] = 161,
		["super fang"] = 162,
		["slash"] = 163,
		["substitute"] = 164,
		["struggle"] = 165,
		["sketch"] = 166,
		["triple kick"] = 167,
		["thief"] = 168,
		["spider web"] = 169,
		["mind reader"] = 170,
		["nightmare"] = 171,
		["flame wheel"] = 172,
		["snore"] = 173,
		["curse"] = 174,
		["flail"] = 175,
		["conversion 2"] = 176,
		["aeroblast"] = 177,
		["cotton spore"] = 178,
		["reversal"] = 179,
		["spite"] = 180,
		["powder snow"] = 181,
		["protect"] = 182,
		["mach punch"] = 183,
		["scary face"] = 184,
		["faint attack"] = 185,
		["sweet kiss"] = 186,
		["belly drum"] = 187,
		["sludge bomb"] = 188,
		["mud-slap"] = 189,
		["octazooka"] = 190,
		["spikes"] = 191,
		["zap cannon"] = 192,
		["foresight"] = 193,
		["destiny bond"] = 194,
		["perish song"] = 195,
		["icy wind"] = 196,
		["detect"] = 197,
		["bone rush"] = 198,
		["lock-on"] = 199,
		["outrage"] = 200,
		["sandstorm"] = 201,
		["giga drain"] = 202,
		["endure"] = 203,
		["charm"] = 204,
		["rollout"] = 205,
		["false swipe"] = 206,
		["swagger"] = 207,
		["milk drink"] = 208,
		["spark"] = 209,
		["fury cutter"] = 210,
		["steel wing"] = 211,
		["mean look"] = 212,
		["attract"] = 213,
		["sleep talk"] = 214,
		["heal bell"] = 215,
		["return"] = 216,
		["present"] = 217,
		["frustration"] = 218,
		["safeguard"] = 219,
		["pain split"] = 220,
		["sacred fire"] = 221,
		["magnitude"] = 222,
		["dynamicpunch"] = 223,
		["megahorn"] = 224,
		["dragonbreath"] = 225,
		["baton pass"] = 226,
		["encore"] = 227,
		["pursuit"] = 228,
		["rapid spin"] = 229,
		["sweet scent"] = 230,
		["iron tail"] = 231,
		["metal claw"] = 232,
		["vital throw"] = 233,
		["morning sun"] = 234,
		["synthesis"] = 235,
		["moonlight"] = 236,
		["hidden power"] = 237,
		["cross chop"] = 238,
		["twister"] = 239,
		["rain dance"] = 240,
		["sunny day"] = 241,
		["crunch"] = 242,
		["mirror coat"] = 243,
		["psych up"] = 244,
		["extremespeed"] = 245,
		["ancientpower"] = 246,
		["shadow ball"] = 247,
		["future sight"] = 248,
		["rock smash"] = 249,
		["whirlpool"] = 250,
		["beat up"] = 251,
		["fake out"] = 252,
		["uproar"] = 253,
		["stockpile"] = 254,
		["spit up"] = 255,
		["swallow"] = 256,
		["heat wave"] = 257,
		["hail"] = 258,
		["torment"] = 259,
		["flatter"] = 260,
		["will-o-wisp"] = 261,
		["memento"] = 262,
		["facade"] = 263,
		["focus punch"] = 264,
		["smellingsalt"] = 265,
		["follow me"] = 266,
		["nature power"] = 267,
		["charge"] = 268,
		["taunt"] = 269,
		["helping hand"] = 270,
		["trick"] = 271,
		["role play"] = 272,
		["wish"] = 273,
		["assist"] = 274,
		["ingrain"] = 275,
		["superpower"] = 276,
		["magic coat"] = 277,
		["recycle"] = 278,
		["revenge"] = 279,
		["brick break"] = 280,
		["yawn"] = 281,
		["knock off"] = 282,
		["endeavor"] = 283,
		["eruption"] = 284,
		["skill swap"] = 285,
		["imprison"] = 286,
		["refresh"] = 287,
		["grudge"] = 288,
		["snatch"] = 289,
		["secret power"] = 290,
		["dive"] = 291,
		["arm thrust"] = 292,
		["camouflage"] = 293,
		["tail glow"] = 294,
		["luster purge"] = 295,
		["mist ball"] = 296,
		["featherdance"] = 297,
		["teeter dance"] = 298,
		["blaze kick"] = 299,
		["mud sport"] = 300,
		["ice ball"] = 301,
		["needle arm"] = 302,
		["slack off"] = 303,
		["hyper voice"] = 304,
		["poison fang"] = 305,
		["crush claw"] = 306,
		["blast burn"] = 307,
		["hydro cannon"] = 308,
		["meteor mash"] = 309,
		["astonish"] = 310,
		["weather ball"] = 311,
		["aromatherapy"] = 312,
		["fake tears"] = 313,
		["air cutter"] = 314,
		["overheat"] = 315,
		["odor sleuth"] = 316,
		["rock tomb"] = 317,
		["silver wind"] = 318,
		["metal sound"] = 319,
		["grasswhistle"] = 320,
		["tickle"] = 321,
		["cosmic power"] = 322,
		["water spout"] = 323,
		["signal beam"] = 324,
		["shadow punch"] = 325,
		["extrasensory"] = 326,
		["sky uppercut"] = 327,
		["sand tomb"] = 328,
		["sheer cold"] = 329,
		["muddy water"] = 330,
		["bullet seed"] = 331,
		["aerial ace"] = 332,
		["icicle spear"] = 333,
		["iron defense"] = 334,
		["block"] = 335,
		["howl"] = 336,
		["dragon claw"] = 337,
		["frenzy plant"] = 338,
		["bulk up"] = 339,
		["bounce"] = 340,
		["mud shot"] = 341,
		["poison tail"] = 342,
		["covet"] = 343,
		["volt tackle"] = 344,
		["magical leaf"] = 345,
		["water sport"] = 346,
		["calm mind"] = 347,
		["leaf blade"] = 348,
		["dragon dance"] = 349,
		["rock blast"] = 350,
		["shock wave"] = 351,
		["water pulse"] = 352,
		["doom desire"] = 353,
		["psycho boost"] = 354,
	}
	RandomizerLog.AbilityNameToIdMap = {}
	for _, abilityInfo in ipairs(AbilityData.Abilities) do
		if abilityInfo.id ~= nil and abilityInfo.name ~= nil and abilityInfo.name ~= "" then
			RandomizerLog.AbilityNameToIdMap[abilityInfo.name:lower()] = abilityInfo.id
		end
	end
end

function RandomizerLog.removeMappings()
	RandomizerLog.PokemonNameToIdMap = nil
	RandomizerLog.MoveNameToIdMap = nil
	RandomizerLog.AbilityNameToIdMap = nil
	collectgarbage()
end

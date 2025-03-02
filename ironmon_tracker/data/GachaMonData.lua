GachaMonData = {}
GachaMonData.ShinyOdds = 0.002 -- 1 in 500, similar to Pokémon Go

-- Populated on Tracker startup from the ratings data json file
GachaMonData.RatingsSystem = {}

-- Encoder for shareable GachaMon cards
GachaMonData.DataEncoder = {
	Version = 1,
	Decoders = {},
}

--[[
TODO LIST
- Find an efficient way to store GachaMon(s) per seed, is it really all of them?
- Determine when to use capture a GachaMon, converting it and storing it in collection
- Design UI for viewing a single GachaMon
- Design UI and animation for capturing a new GachaMon
- Add Options for: "Show Opening Animation", ...
]]

function GachaMonData.initialize()
	GachaMonData.importRatingSystemFromJson()

	-- DEBUG
	-- Program.addFrameCounter("GachaMonTest", 60, GachaMonData.test, 1)
	-- GachaMonData.processRawData()
end

function GachaMonData.processRawData()
	local SEPARATOR = "ENDOFKEYS"
	local FOLDER = FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.GachaMon .. FileManager.slash
	local rawDataPath = FileManager.prependDir(FOLDER .. "RawInput.txt")
	local outputPath = FileManager.prependDir(FOLDER .. "RawOutput.json")

	local readingRatings, totalOffset = false, 0
	local data = {}
	local lines = FileManager.readLinesFromFile(rawDataPath)
	for i, line in ipairs(lines or {}) do
		if line == SEPARATOR then
			readingRatings = true
			totalOffset = i
		elseif not readingRatings then
			local id = DataHelper.findAbilityId(line)
			local obj = { id = id }
			table.insert(data, obj)
		else
			local index = i - totalOffset
			local obj = data[index] or {}
			local rating = tonumber(line)
			-- nearest hundreth
			obj.rating = math.floor(rating * 100 + 0.5) / 100
		end
	end
	table.sort(data, function(a,b) return a.id < b.id end)

	local missingIds = {}
	for id, value in ipairs(AbilityData.Abilities) do
		local found = false
		for _, obj in ipairs(data) do
			if obj.id == id then
				found = true
				break
			end
		end
		if not found then
			table.insert(missingIds, value.name)
		end
	end
	Utils.printDebug("Missing: %s", table.concat(missingIds, ", "))

	Utils.printDebug("Data Count: %s", #data)
	local formattedData = {
		Abilities = {}
	}
	for _, obj in ipairs(data) do
		formattedData.Abilities[tostring(obj.id)] = obj.rating
	end
	FileManager.encodeToJsonFile(outputPath, formattedData)
end

function GachaMonData.test()
	print("")
	local pokemon = TrackerAPI.getPlayerPokemon()
	if pokemon then
		local gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
		Utils.printDebug("[GACHAMON] %s >>> Rating: %s | Stars: %s <<<",
			PokemonData.Pokemon[gachamon.PokemonId].name,
			gachamon.RatingScore,
			gachamon.Stars
		)
		local stringpair = GachaMonData.DataEncoder.encodeData(gachamon)
		Utils.printDebug(stringpair)
	else
		Utils.printDebug("[GACHAMON] No Pokémon in party.")
	end
end

---@param pokemonData IPokemon
---@return IGachaMon gachamon
function GachaMonData.convertPokemonToGachaMon(pokemonData)
	local gachamon = GachaMonData.IGachaMon:new({
		PokemonId = pokemonData.pokemonID,
		Gender = pokemonData.gender,
		Nature = pokemonData.nature,
		Level = pokemonData.level,
		IsShiny = pokemonData.isShiny and 1 or 0,
		GameVersion = GameSettings.versioncolor or Constants.HIDDEN_INFO,
		SeedNumber = Main.currentSeed or 0,
	})

	-- Core data copy
	gachamon.AbilityId = PokemonData.getAbilityId(pokemonData.pokemonID, pokemonData.abilityNum)
	for statKey, _ in pairs(pokemonData.stats or {}) do
		gachamon.Stats[statKey] = pokemonData.stats[statKey] or 0
	end
	for _, move in ipairs(pokemonData.moves or {}) do
		if MoveData.isValid(move.id) then
			table.insert(gachamon.Moves, move.id)
		end
	end

	-- Other data calculations
	gachamon.DateObtained = os.time()
	local routeObtained = RouteData.Info[TrackerAPI.getMapId()] or {}
	gachamon.LocationObtained = routeObtained.name or Constants.HIDDEN_INFO
	if not gachamon.IsShiny and math.random() <= GachaMonData.ShinyOdds then -- Reroll shininess chance
		gachamon.IsShiny = 1
	end

	gachamon.RatingScore = GachaMonData.calculateRating(gachamon)
	gachamon.Stars = GachaMonData.getStarsFromRating(gachamon.RatingScore)

	return gachamon
end

---Rate the GachaMon based on its ability, moves, stats, and other factors
---@param gachamon IGachaMon
---@return number rating Value between 0 and 100
function GachaMonData.calculateRating(gachamon)
	local RS = GachaMonData.RatingsSystem
	local ratingTotal = 0

	-- ABILITY
	local abilityRating = RS.Abilities[gachamon.AbilityId or 0] or 0
	ratingTotal = ratingTotal + abilityRating

	-- MOVES
	local moveRating = 0
	for _, id in ipairs(gachamon.Moves or {}) do
		if RS.Moves[id] then
			moveRating = moveRating + RS.Moves[id]
		end
	end
	ratingTotal = ratingTotal + moveRating

	-- STATS
	local pokemonInternal = PokemonData.Pokemon[gachamon.PokemonId] or PokemonData.BlankPokemon
	local bst = math.max(pokemonInternal.bst, 1) -- minimum of 1
	-- Highest Attacking Stat % of BST
	local offensiveStat = gachamon.Stats.atk > gachamon.Stats.spa and gachamon.Stats.atk or gachamon.Stats.spa
	local offensivePercentage = offensiveStat / bst
	local offensiveRating = 0
	for _, ratingPair in ipairs(RS.Stats.Offensive or {}) do
		if offensivePercentage >= (ratingPair.Percentage or 1) and ratingPair.Rating then
			offensiveRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + offensiveRating
	-- Combined Defensive Stats % of BST (HP, Spdef, Def)
	local defensiveStats = gachamon.Stats.hp + gachamon.Stats.def + gachamon.Stats.spd
	local defensivePercentage = defensiveStats / bst
	local defensiveRating = 0
	for _, ratingPair in ipairs(RS.Stats.Defensive or {}) do
		if defensivePercentage >= (ratingPair.Percentage or 1) and ratingPair.Rating then
			defensiveRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + defensiveRating
	-- Speed % of BST
	local speedPercentage = gachamon.Stats.spe / bst
	local speedRating = 0
	for _, ratingPair in ipairs(RS.Stats.Speed or {}) do
		if speedPercentage >= (ratingPair.Percentage or 1) and ratingPair.Rating then
			speedRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + speedRating

	-- OTHER
	-- What else should be considered for stars? STAB? Ruleset?

	Utils.printDebug("[RATINGS] Ability: %s, Moves: %s, Offensive: %s, Defensive: %s, Speed: %s",
		abilityRating, moveRating, offensiveRating, defensiveRating, speedRating)

	return ratingTotal
end

---Use the RatingsSystem to determine the number of stars a given rating is worth
---@param rating number
---@return number stars Value between 0 and 6
function GachaMonData.getStarsFromRating(rating)
	if rating <= 0 then
		return 0
	end
	for _, ratingPair in ipairs(GachaMonData.RatingsSystem.RatingToStars or {}) do
		if rating >= (ratingPair.Rating or 1) and ratingPair.Stars then
			return ratingPair.Stars
		end
	end
	return 0
end

---Imports all GachaMon Ratings data from a JSON file
---@param filepath? string Optional, a custom JSON file
---@return boolean success
function GachaMonData.importRatingSystemFromJson(filepath)
	filepath = filepath or GachaMonData.getRatingSystemFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not (data and data.Abilities and data.Moves and data.Stats and data.RatingToStars) then
		return false
	end

	-- Copy over the imported data to the gachamon ratings system
	GachaMonData.RatingsSystem = {
		Abilities = {},
		Moves = {},
		Stats = {},
		RatingToStars = {},
	}
	for idStr, rating in pairs(data.Abilities or {}) do
		local id = tonumber(idStr)
		if id then
			GachaMonData.RatingsSystem.Abilities[id] = rating
		end
	end
	for idStr, rating in pairs(data.Moves or {}) do
		local id = tonumber(idStr)
		if id then
			GachaMonData.RatingsSystem.Moves[id] = rating
		end
	end
	for statCategory, list in pairs(data.Stats or {}) do
		GachaMonData.RatingsSystem.Stats[statCategory] = {}
		local statTable = GachaMonData.RatingsSystem.Stats[statCategory]
		for _, ratingPair in ipairs(list or {}) do
			table.insert(statTable, ratingPair)
		end
	end
	for _, ratingPair in ipairs(data.RatingToStars or {}) do
		table.insert(GachaMonData.RatingsSystem.RatingToStars, ratingPair)
	end

	return true
end

---Imports all GachaMon Colection data from a JSON file
---@param filepath? string Optional, a custom JSON file
---@return boolean success
function GachaMonData.importCollectionFromJson(filepath)
	filepath = filepath or GachaMonData.getCollectionFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not (data) then
		return false
	end

	-- Copy over the imported data to the gachamon data set

	return true
end

---@return string filepath
function GachaMonData.getRatingSystemFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RATING_SYSTEM)
end

---@return string filepath
function GachaMonData.getCollectionFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_COLLECTION)
end



-- GachaMon object prototypes

---@class IGachaMon
GachaMonData.IGachaMon = {
	-- RAW DATA (Encoded values, shareable data)

	PokemonId = 0,
	RatingScore = 0,
	Stars = 0,
	Gender = 0,
	Nature = 0,
	Level = 0,
	AbilityId = 0,
	IsShiny = 0, -- GachaMons have higher shiny chance
	Stats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	Moves = {}, -- Ordered list of the 4 move ids the mon had when collected

	-- META DATA (Non-encoded values)

	-- Some unique identifier, might not need to be a GUID
	GUID = "",
	-- Which Pokémon game version this mon was collected on
	GameVersion = "",
	-- The seed number at the time this mon was collected
	SeedNumber = 0,
	-- The date time for when this mon was collected
	DateObtained = 0,
	-- Where the mon was collected (route/map name)
	LocationObtained = "",
	-- Where the mon fainted (route/map name)
	LocationDeath = "",
	-- How long this mon survived (gameplay time) between when it was caught and when it fainted
	Lifespan = 0,
}
---Creates and returns a new IGachaMon object
---@param o? table Optional initial object table
---@return IGachaMon profile An IGachaMon object
function GachaMonData.IGachaMon:new(o)
	o = o or {}

	o.PokemonId = o.PokemonId or 0
	o.RatingScore = o.RatingScore or 0
	o.Gender = o.Gender or 0
	o.Nature = o.Nature or 0
	o.Level = o.Level or 0
	o.AbilityId = o.AbilityId or 0
	o.IsShiny = o.IsShiny or 0
	o.Stats = o.Stats or { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	o.Moves = o.Moves or {}

	o.GUID = o.GUID or Utils.newGUID()
	o.GameVersion = o.GameVersion or ""
	o.SeedNumber = o.SeedNumber or 0
	o.DateObtained = o.DateObtained or 0
	o.LocationObtained = o.LocationObtained or ""
	o.LocationDeath = o.LocationDeath or ""
	o.Lifespan = o.Lifespan or 0
	o.Stars = o.Stars or 0

	setmetatable(o, self)
	self.__index = self
	return o
end

---Converts a base10 number to a base16 hexidecimal string
---@param num number
---@param minimumDigits? number
---@return string
local function _numberToHex(num, minimumDigits)
	local format
	if minimumDigits then
		format = "%0" .. minimumDigits .. "x"
	else
		format = "%x"
	end
	return string.format(format, num)
end

---Converts a base16 hexidecimal string to a base10 number
---@param hex string
---@return number
local function _hexToNumber(hex)
	return tonumber(hex, 16)
end

---Encodes GachaMon data into a string-pair (version + b64string), for sharing cool cards
---@param gachamon IGachaMon
---@return string
function GachaMonData.DataEncoder.encodeData(gachamon)
	-- Bit-compress these three values together, format: NNNNNGGS
	local shinyGenderNature = gachamon.IsShiny + Utils.bit_lshift(gachamon.Gender, 1) + Utils.bit_lshift(gachamon.Nature, 3)
	local data = {
		_numberToHex(gachamon.PokemonId, 3),
		_numberToHex(math.floor(gachamon.RatingScore), 2),
		_numberToHex(gachamon.Level, 2),
		_numberToHex(gachamon.AbilityId, 2),
		_numberToHex(shinyGenderNature, 2),
		_numberToHex(gachamon.Stats.hp, 3),
		_numberToHex(gachamon.Stats.atk, 3),
		_numberToHex(gachamon.Stats.def, 3),
		_numberToHex(gachamon.Stats.spa, 3),
		_numberToHex(gachamon.Stats.spd, 3),
		_numberToHex(gachamon.Stats.spe, 3),
		_numberToHex(gachamon.Moves[1] or 0, 3),
		_numberToHex(gachamon.Moves[2] or 0, 3),
		_numberToHex(gachamon.Moves[3] or 0, 3),
		_numberToHex(gachamon.Moves[4] or 0, 3),
	}
	local version = _numberToHex(GachaMonData.DataEncoder.Version, 2)
	local datastring = table.concat(data)
	local b64string = Utils.Base64.encode(datastring)
	local stringpair = string.format("%s%s", version, b64string)
	-- 1st Example: 01MDIyNDAwMDAwMzA0MzA3MjAxMDQxMTMwOTIwNjgwOTkwOTIwMjYwMjgwMjQwMjYwMTAwMDQwODkwMjYzMjYyOTk=
	-- 2nd Example: 01MGUwNDUyYjQ4MTgwNjgwNzEwNWMwNDQwNjMwNWMwNTkwMWExNDYxMmI=
	return stringpair
end

---Decodes a GachaMon string-pair (version + b64string) into an IGachaMon data table; decode function determined by version number
---@param stringpair string A string containing the version number (head) and base-64 string (tail)
---@return IGachaMon|nil gachamon
function GachaMonData.DataEncoder.decodeData(stringpair)
	local version = _hexToNumber(stringpair:sub(1, 2))
	local decoder = GachaMonData.DataEncoder.Decoders[version or false]
	if type(decoder) ~= "function" then
		return nil
	end
	local b64string = stringpair:sub(3)
	local gachamon = decoder(b64string)
	if gachamon.Stars <= 0 then
		gachamon.Stars = GachaMonData.getStarsFromRating(gachamon.RatingScore)
	end
	return gachamon
end

---Version 1 Decoder
---@param b64string string
---@return IGachaMon
GachaMonData.DataEncoder.Decoders[1] = function(b64string)
	local datastring = Utils.Base64.decode(b64string)
	local gachamon = GachaMonData.IGachaMon:new({
		PokemonId = _hexToNumber(datastring:sub(1, 3)),
		RatingScore = _hexToNumber(datastring:sub(4, 5)),
		Level = _hexToNumber(datastring:sub(6, 7)),
		AbilityId = _hexToNumber(datastring:sub(8, 9)),
		Stats = {
			hp = _hexToNumber(datastring:sub(12, 14)),
			atk = _hexToNumber(datastring:sub(15, 17)),
			def = _hexToNumber(datastring:sub(18, 20)),
			spa = _hexToNumber(datastring:sub(21, 23)),
			spd = _hexToNumber(datastring:sub(24, 26)),
			spe = _hexToNumber(datastring:sub(27, 29)),
		},
		Moves = {
			_hexToNumber(datastring:sub(30, 32)),
			_hexToNumber(datastring:sub(33, 35)),
			_hexToNumber(datastring:sub(36, 38)),
			_hexToNumber(datastring:sub(39, 41)),
		}
	})
	-- Bit-compressed these three values together, format: NNNNNGGS
	local shinyGenderNature = _hexToNumber(datastring:sub(10, 11))
	gachamon.IsShiny = Utils.getbits(shinyGenderNature, 0, 1)
	gachamon.Gender = Utils.getbits(shinyGenderNature, 1, 2)
	gachamon.Nature = Utils.getbits(shinyGenderNature, 3, 5)
	return gachamon
end

GachaMonData = {}
GachaMonData.ShinyOdds = 0.002 -- 1 in 500, similar to Pokémon Go

-- Populated on Tracker startup from the ratings data json file
GachaMonData.RatingsSystem = {}

GachaMonData.FileStorage = {
	-- The current version of the process used to store GachaMon data into files as compact binary streams
	Version = 1,
	-- The order and size of all data packed into binary, first byte is always the version number
	PackFormat = "BHBBBBBBBBBHHHH",
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
		-- Test converting 1st mon in party to GachaMon
		local gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
		Utils.printDebug("[GACHAMON] %s >>> Rating: %s | Stars: %s <<<",
			PokemonData.Pokemon[gachamon.PokemonId].name,
			gachamon.RatingScore,
			gachamon.Stars
		)

		-- Test to-and-from binary
		local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
		local mon = GachaMonData.FileStorage.binaryToMon(binaryStream)
		Utils.printDebug("Binary Transform Success: %s - %s", tostring(mon ~= nil), mon ~= nil and mon.PokemonId or "N/A")

		-- Test base-64 encoding of data
		local b64string = GachaMonData.getShareablyCode(gachamon)
		Utils.printDebug("Share Code: %s", b64string)

	else
		Utils.printDebug("[GACHAMON] No Pokémon in party.")
	end
end

---@param pokemonData IPokemon
---@return IGachaMon gachamon
function GachaMonData.convertPokemonToGachaMon(pokemonData)
	local gachamon = GachaMonData.IGachaMon:new({
		PokemonId = pokemonData.pokemonID,
		IsShiny = pokemonData.isShiny and 1 or 0,
		Gender = pokemonData.gender,
		Nature = pokemonData.nature,
		GameVersion = GameSettings.versioncolor or Constants.HIDDEN_INFO,
		SeedNumber = Main.currentSeed or 0,
		Level = pokemonData.level,
	})

	-- Core data copy
	gachamon.AbilityId = PokemonData.getAbilityId(pokemonData.pokemonID, pokemonData.abilityNum)
	local pokemonInternal = PokemonData.Pokemon[gachamon.PokemonId] or PokemonData.BlankPokemon
	for statKey, baseStat in pairs(pokemonInternal.baseStats or {}) do
		gachamon.BaseStats[statKey] = baseStat or 0
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
	local offensiveStat = gachamon.BaseStats.atk > gachamon.BaseStats.spa and gachamon.BaseStats.atk or gachamon.BaseStats.spa
	local offensivePercentage = offensiveStat / bst
	local offensiveRating = 0
	for _, ratingPair in ipairs(RS.BaseStats.Offensive or {}) do
		if offensivePercentage >= (ratingPair.Percentage or 1) and ratingPair.Rating then
			offensiveRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + offensiveRating
	-- Combined Defensive BaseStats % of BST (HP, Spdef, Def)
	local defensiveStats = gachamon.BaseStats.hp + gachamon.BaseStats.def + gachamon.BaseStats.spd
	local defensivePercentage = defensiveStats / bst
	local defensiveRating = 0
	for _, ratingPair in ipairs(RS.BaseStats.Defensive or {}) do
		if defensivePercentage >= (ratingPair.Percentage or 1) and ratingPair.Rating then
			defensiveRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + defensiveRating
	-- Speed % of BST
	local speedPercentage = gachamon.BaseStats.spe / bst
	local speedRating = 0
	for _, ratingPair in ipairs(RS.BaseStats.Speed or {}) do
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

---Transforms the GachaMon data into a sharable base-64 string. Example: AeAANkgYMEQkm38tWQAaAEYBKwE=
---@param gachamon IGachaMon
---@return string b64string
function GachaMonData.getShareablyCode(gachamon)
	local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
	local b64string = StructEncoder.encodeBase64(binaryStream)
	return b64string
end

---Imports all GachaMon Ratings data from a JSON file
---@param filepath? string Optional, a custom JSON file
---@return boolean success
function GachaMonData.importRatingSystemFromJson(filepath)
	filepath = filepath or GachaMonData.FileStorage.getRatingSystemFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not (data and data.Abilities and data.Moves and data.BaseStats and data.RatingToStars) then
		return false
	end

	-- Copy over the imported data to the gachamon ratings system
	GachaMonData.RatingsSystem = {
		Abilities = {},
		Moves = {},
		BaseStats = {},
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
	for statCategory, list in pairs(data.BaseStats or {}) do
		GachaMonData.RatingsSystem.BaseStats[statCategory] = {}
		local statTable = GachaMonData.RatingsSystem.BaseStats[statCategory]
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
	filepath = filepath or GachaMonData.FileStorage.getCollectionFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	-- TODO. This is not how collection data will be stored or retrieved

	local data = FileManager.decodeJsonFile(filepath)
	if not (data) then
		return false
	end

	-- Copy over the imported data to the gachamon data set

	return true
end

-- GachaMon object prototypes

---@class IGachaMon
GachaMonData.IGachaMon = {
	-- RAW DATA (Encoded values, shareable data)

	PokemonId = 0,
	RatingScore = 0,
	AbilityId = 0,
	IsShiny = 0, -- GachaMons have higher shiny chance
	Gender = 0,
	Nature = 0,
	BaseStats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	Moves = {}, -- Ordered list of the 4 move ids the mon had when collected

	-- META DATA (Non-encoded values)

	-- Some unique identifier, might not need to be a GUID
	GUID = "",
	-- Which Pokémon game version this mon was collected on
	GameVersion = "",
	-- The level of the Pokémon when it was caught.
	Level = 0,
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
	-- Simplified 1-to-5 star rating, calculable from the rating value itself
	Stars = 0,
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
	o.AbilityId = o.AbilityId or 0
	o.IsShiny = o.IsShiny or 0
	o.BaseStats = o.BaseStats or { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	o.Moves = o.Moves or {}

	o.GUID = o.GUID or Utils.newGUID()
	o.GameVersion = o.GameVersion or ""
	o.SeedNumber = o.SeedNumber or 0
	o.Level = o.Level or 0
	o.DateObtained = o.DateObtained or 0
	o.LocationObtained = o.LocationObtained or ""
	o.LocationDeath = o.LocationDeath or ""
	o.Lifespan = o.Lifespan or 0
	o.Stars = o.Stars or 0

	setmetatable(o, self)
	self.__index = self
	return o
end


-- A historical record of ALL binary data readers, such that any stream of binary data can be transformed into a GachaMon object
GachaMonData.FileStorage.BinaryStreamReaders = {}

---@return string filepath
function GachaMonData.FileStorage.getRatingSystemFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RATING_SYSTEM)
end

---@return string filepath
function GachaMonData.FileStorage.getCollectionFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_COLLECTION)
end

---Transforms GachaMon data into a compact binary stream of data
---@param gachamon IGachaMon
---@return string binaryStream
function GachaMonData.FileStorage.monToBinary(gachamon)
	-- Bit-compress these three values together, format: NNNNNGGS
	local shinyGenderNature = gachamon.IsShiny + Utils.bit_lshift(gachamon.Gender, 1) + Utils.bit_lshift(gachamon.Nature, 3)
	return StructEncoder.binaryPack(GachaMonData.FileStorage.PackFormat,
		-- Ordered set of data to pack into binary
		GachaMonData.FileStorage.Version,
		gachamon.PokemonId,
		math.floor(gachamon.RatingScore),
		gachamon.AbilityId,
		shinyGenderNature,
		gachamon.BaseStats.hp,
		gachamon.BaseStats.atk,
		gachamon.BaseStats.def,
		gachamon.BaseStats.spa,
		gachamon.BaseStats.spd,
		gachamon.BaseStats.spe,
		gachamon.Moves[1],
		gachamon.Moves[2],
		gachamon.Moves[3],
		gachamon.Moves[4]
	)
end

---Transforms binary data into a GachaMon object; the data transform process is determined by version number
---@param binaryStream string compact binary stream of data
---@return IGachaMon|nil gachamon
function GachaMonData.FileStorage.binaryToMon(binaryStream)
	local version = StructEncoder.binaryUnpack("B", binaryStream)

	local streamReader = GachaMonData.FileStorage.BinaryStreamReaders[version or false]
	if type(streamReader) ~= "function" then
		return nil
	end

	local gachamon = streamReader(binaryStream)
	-- Populate some meta data
	if gachamon.Stars <= 0 then
		gachamon.Stars = GachaMonData.getStarsFromRating(gachamon.RatingScore)
	end
	return gachamon
end

---Version 1 Binary Stream Reader
---@param binaryStream string compact binary stream of data
---@return IGachaMon
GachaMonData.FileStorage.BinaryStreamReaders[1] = function(binaryStream)
	-- Unpack binary data into a table
	local data = { StructEncoder.binaryUnpack(GachaMonData.FileStorage.PackFormat, binaryStream) }
	local gachamon = GachaMonData.IGachaMon:new({
		PokemonId = data[2],
		RatingScore = data[3],
		AbilityId = data[4],
		BaseStats = {
			hp = data[6],
			atk = data[7],
			def = data[8],
			spa = data[9],
			spd = data[10],
			spe = data[11],
		},
		Moves = {
			data[12],
			data[13],
			data[14],
			data[15],
		}
	})
	-- Bit-compressed these three values together, format: NNNNNGGS
	local shinyGenderNature = data[5]
	gachamon.IsShiny = Utils.getbits(shinyGenderNature, 0, 1)
	gachamon.Gender = Utils.getbits(shinyGenderNature, 1, 2)
	gachamon.Nature = Utils.getbits(shinyGenderNature, 3, 5)
	return gachamon
end

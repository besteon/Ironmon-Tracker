GachaMonData = {
	ShinyOdds = 0.002, -- 1 in 500, similar to Pokémon Go

	-- The user's entire GachaMon collection (ordered list). Populated from file only when the user first goes to view the Collection on the Tracker
	Collection = {},

	-- Stores the GachaMons for the current gameplay session only. Table key is the mon's personality value
	RecentMons = {},

	-- Populated on Tracker startup from the ratings data json file
	RatingsSystem = {},

	FileStorage = {
		-- The current version of the PackFormat below. If the format changes, this version must be incremented.
		Version = 1,
		-- The order and sizing of all data per GachaMon packed into binary, first byte is always the version number
		PackFormat = "BIHBBBBBBBBHL",
		-- The number of characters to reserve at the start of RecentMons file for storing the matching game's ROM hash (only needs 40)
		RomHashSize = 64,
	},

	-- Used to determine if the historical collection has been loaded from the file for this play session
	isCollectionLoaded = false,
	-- When a new GachaMon is caught/created, this will temporarily store that mon's data
	newestRecentMon = nil,
}

--[[
TODO LIST
- [Game Trigger] Auto-add to collection any mon used to defeat a trainer in battle (set it's Keep value)
- [Ratings System] Cannot use hidden Base Stat values, most use visible values and new formula somehow
- [UI] Design UI for viewing a single GachaMon
- [UI] Design UI and animation for capturing a new GachaMon (click to open: fade to black, animate pack, animate opening, show mon)
- [Text UI] Create a basic MGBA viewing interface
]]

function GachaMonData.initialize()
	-- Reset data variables
	GachaMonData.RecentMons = {}
	GachaMonData.Collection = {}
	GachaMonData.isCollectionLoaded = false
	GachaMonData.clearNewestMonToShow()
	-- Import universally useful data
	GachaMonData.FileStorage.importRatingSystem()
	GachaMonData.FileStorage.importRecentGachaMons()
end

function GachaMonData.test()
	print("")

	local pokemon = TrackerAPI.getPlayerPokemon()
	if not pokemon then
		Utils.printDebug("[GACHAMON] No Pokémon in party.")
		return
	end

	-- Test converting 1st mon in party to GachaMon
	local gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
	Utils.printDebug("[GACHAMON] %s >>> Rating: %s | Stars: %s <<<",
		PokemonData.Pokemon[gachamon.PokemonId].name,
		gachamon.RatingScore,
		GachaMonData.getStarsFromRating(gachamon.RatingScore)
	)

	-- Test to-and-from binary
	local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
	local mon = GachaMonData.FileStorage.binaryToMon(binaryStream)
	Utils.printDebug("Binary Transform Success: %s - %s", tostring(mon ~= nil), mon ~= nil and mon.PokemonId or "N/A")

	-- Test base-64 encoding of data
	local b64string = GachaMonData.getShareablyCode(gachamon)
	Utils.printDebug("Share Code: %s", b64string)
end

---@param pokemonData IPokemon
---@return IGachaMon gachamon
function GachaMonData.convertPokemonToGachaMon(pokemonData)
	local gachamon = GachaMonData.IGachaMon:new({
		Personality = pokemonData.personality,
		PokemonId = pokemonData.pokemonID,
		SeedNumber = Main.currentSeed or 0,
		Temp = {
			MoveIds = {},
			GameVersion = GameSettings.gameVersionToNumber(GameSettings.versioncolor),
			IsShiny = pokemonData.isShiny and 1 or 0,
			Gender = pokemonData.gender,
			Nature = pokemonData.nature,
			DateTimeObtained = os.time(),
		},

	})

	gachamon.AbilityId = PokemonData.getAbilityId(pokemonData.pokemonID, pokemonData.abilityNum)

	local pokemonInternal = PokemonData.Pokemon[gachamon.PokemonId] or PokemonData.BlankPokemon
	for statKey, baseStat in pairs(pokemonInternal.baseStats or {}) do
		gachamon.BaseStats[statKey] = baseStat or 0
	end

	for _, move in ipairs(pokemonData.moves or {}) do
		if MoveData.isValid(move.id) then
			table.insert(gachamon.Temp.MoveIds, move.id)
		end
	end

	-- Reroll shininess chance
	if gachamon.Temp.IsShiny ~= 1 and math.random() <= GachaMonData.ShinyOdds then
		gachamon.Temp.IsShiny = 1
	end

	gachamon.RatingScore = GachaMonData.calculateRating(gachamon)

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
	for _, id in ipairs(gachamon.Temp.MoveIds or {}) do
		if RS.Moves[id] then
			moveRating = moveRating + RS.Moves[id]
		end
	end
	ratingTotal = ratingTotal + moveRating

	-- STATS
	-- TODO: Cannot use hidden Base Stat values, most use visible values and new formula somehow
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

	return math.floor(ratingTotal + 0.5)
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

---Temporary way to display data until things are more defined.
---@return table
function GachaMonData.getStats()
	local stats = {
		NumGamePack = 0,
		NumCollection = 0,
	}
	if not GachaMonData.isCollectionLoaded then
		return stats
	end
	for _, _ in pairs(GachaMonData.RecentMons or {}) do
		stats.NumGamePack = stats.NumGamePack + 1
	end
	stats.NumCollection = #GachaMonData.Collection
	return stats
end

---Returns true if a new GachaMon is available for viewing on the Tracker
---@return boolean
function GachaMonData.hasNewestMonToShow()
	return GachaMonData.newestRecentMon ~= nil and not Battle.inActiveBattle()
end

---Clears out any new GachaMon temporarily stored for viewing (after its opened or when a new battle starts)
function GachaMonData.clearNewestMonToShow()
	GachaMonData.newestRecentMon = nil
end

---Called when a new Pokémon is viewed on the Tracker, to create a GachaMon from it
---@param pokemon IPokemon
---@return boolean success
function GachaMonData.tryAddToRecentMons(pokemon)
	if GachaMonData.RecentMons[pokemon.personality] then
		return false
	end
	Utils.printDebug("[tryAddToRecentMons] Adding New Mon, Personality: %s", tostring(pokemon.personality))

	-- Create the GachaMon from the IPokemon data, then add it
	local gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
	GachaMonData.RecentMons[pokemon.personality] = gachamon
	GachaMonData.FileStorage.saveRecentMonsToFile()
	GachaMonData.newestRecentMon = gachamon
	return true
end


---@class IGachaMon
GachaMonData.IGachaMon = {
	-- 4 Bytes; the Pokémon game's "unique identifier"
	Personality = 0,
	-- 2 Bytes (11 bits)
	PokemonId = 0,
	-- 1 Byte (7 bits)
	AbilityId = 0,
	-- 6 Bytes (8 bits x6); one byte per base stat
	BaseStats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	-- 1 Byte (7 bits); value rounded up
	RatingScore = 0,
	-- 2 Bytes (16 bits); The seed number at the time this mon was collected
	SeedNumber = 0,
	-- 5 Bytes (9 bits x4, + 3 bits + 1 bit); 4 move ids, game version, and keep permanently; left-most byte as KVVVMMMM
	-- Game Version (3bits) 1:Ruby/4:Sapphire, 2:Emerald, 3:FireRed/5:LeafGreen
	-- Keep set to 1 only for deciding to save a RecentMons into the Collection permanently
	C_MoveIdsGameVersionKeep = 0,
	-- 1 Byte (8 bits); bit-compressed together as: NNNNNGGS
	C_ShinyGenderNature = 0,
	-- 2 Bytes (16 bits); year stored as -2000 actual value (6-7 bits), month (4 bits), day (5 bits) as: YYYYYYYM MMMDDDDD
	C_DateObtained = 0,

	-- Any other data for easy access, but won't be stored in the collection file
	Temp = {},

	-- Helper functions for converting data to proper formats, binary or otherwise

	-- KVVVMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
	compressMoveIdsGameVersionKeep = function(self)
		if self.C_MoveIdsGameVersionKeep == 0 then
			self.C_MoveIdsGameVersionKeep = (self.Temp.MoveIds[1] or 0) -- 9 bits
				+ Utils.bit_lshift((self.Temp.MoveIds[2] or 0), 9) -- 9 bits
				+ Utils.bit_lshift((self.Temp.MoveIds[3] or 0), 18) -- 9 bits
				+ Utils.bit_lshift((self.Temp.MoveIds[4] or 0), 27) -- 9 bits
				+ Utils.bit_lshift((self.Temp.GameVersion or 0), 36) -- 3 bits
				+ Utils.bit_lshift((self.Temp.Keep or 0), 39) -- 1 bit
		end
		return self.C_MoveIdsGameVersionKeep
	end,
	-- NNNNNGGS
	compressShinyGenderNature = function(self)
		if self.C_ShinyGenderNature == 0 then

			self.C_ShinyGenderNature = (self.Temp.IsShiny or 0) -- 1 bit
				+ Utils.bit_lshift((self.Temp.Gender or 0), 1) -- 2 bits
				+ Utils.bit_lshift((self.Temp.Nature or 0), 3) -- 5 bits
		end
		return self.C_ShinyGenderNature
	end,
	-- YYYYYYYM MMMDDDDD
	compressDateObtained = function(self)
		if self.C_DateObtained == 0 then
			local dt = os.date("*t", self.Temp.DateTimeObtained or os.time())
			-- save space by assuming after year 2000
			local year = math.max(dt.year - 2000, 0)
			self.C_DateObtained = dt.day -- 5 bits
				+ Utils.bit_lshift(dt.month, 5) -- 4 bits
				+ Utils.bit_lshift(year, 9) -- 7 bits
		end
		return self.C_DateObtained
	end,
}
---Creates and returns a new IGachaMon object
---@param o? table Optional initial object table
---@return IGachaMon profile An IGachaMon object
function GachaMonData.IGachaMon:new(o)
	o = o or {}
	o.Personality = o.Personality or 0
	o.PokemonId = o.PokemonId or 0
	o.AbilityId = o.AbilityId or 0
	o.BaseStats = o.BaseStats or { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	o.RatingScore = o.RatingScore or 0
	o.SeedNumber = o.SeedNumber or 0
	o.C_MoveIdsGameVersionKeep = o.C_MoveIdsGameVersionKeep or 0
	o.C_ShinyGenderNature = o.C_ShinyGenderNature or 0
	o.C_DateObtained = o.C_DateObtained or 0
	o.Temp = o.Temp or {}
	setmetatable(o, self)
	self.__index = self
	return o
end


-- A historical record of ALL binary data readers and their storage size, such that any stream of binary data can be transformed into a GachaMon object
-- When adding new versions, don't use function shortcuts for binary/data conversion. Each must be written out per-version.
GachaMonData.FileStorage.BinaryStreamReaders = {}

---@return string filepath
function GachaMonData.FileStorage.getRatingSystemFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RATING_SYSTEM)
end
---@return string filepath
function GachaMonData.FileStorage.getRecentGachaMonsFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RECENT)
end
---@return string filepath
function GachaMonData.FileStorage.getCollectionFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_COLLECTION)
end

---Imports all GachaMon Ratings data from a JSON file
---@param filepath? string Optional, a custom JSON file
---@return boolean success
function GachaMonData.FileStorage.importRatingSystem(filepath)
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

---Imports any existing Recent GachaMons (when resuming a game session)
---@param filepathOverride? string
function GachaMonData.FileStorage.importRecentGachaMons(filepathOverride)
	local filepath = filepathOverride or GachaMonData.FileStorage.getRecentGachaMonsFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return
	end
	local importedRomHash = GachaMonData.FileStorage.getRomHashFromFile(filepath)
	if not importedRomHash then
		return
	end

	-- If the RecentMons on file match this ROM, use them
	local recentMonsOrdered = GachaMonData.FileStorage.getCollectionFromFile(filepath, GachaMonData.FileStorage.RomHashSize + 1)
	if importedRomHash == GameSettings.getRomHash() then
		for _, gachamon in ipairs(recentMonsOrdered) do
			GachaMonData.RecentMons[gachamon.Personality] = gachamon
		end
		return
	end

	-- Otherwise, store any RecentMons, which were flagged as "Keep", from the previous rom into the user's Collection
	for _, gachamon in ipairs(recentMonsOrdered or {}) do
		local shouldKeep = Utils.getbits(gachamon.C_MoveIdsGameVersionKeep, 39, 1)
		if shouldKeep == 1 then
			table.insert(GachaMonData.Collection, gachamon)
			GachaMonData.FileStorage.tryAppendToCollection(gachamon)
		end
	end
	-- Empty the file
	local file = io.open(filepath, "w")
	if file then
		file:close()
	end
end

---Imports any existing Collection GachaMons (when resuming a game session)
---@param filepath? string Optional, defaults to the filepath used by GachaMonData
function GachaMonData.FileStorage.importCollection(filepath)
	GachaMonData.isCollectionLoaded = true

	filepath = filepath or GachaMonData.FileStorage.getCollectionFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return
	end

	-- Import any existing data
	GachaMonData.Collection = GachaMonData.FileStorage.getCollectionFromFile(filepath)
end

---Reads the RomHash value from the start of the RecentMons data file
---@param filepathOverride? string
---@return string|nil
function GachaMonData.FileStorage.getRomHashFromFile(filepathOverride)
	local filepath = filepathOverride or GachaMonData.FileStorage.getRecentGachaMonsFilePath()
	if not FileManager.fileExists(filepath) then
		return nil
	end
	local file = io.open(filepath, "rb")
	if not file then
		return nil
	end
	local binaryStream = file:read("*a") or ""
	file:close()
	local packFormat = string.format("c%s", GachaMonData.FileStorage.RomHashSize or 64)
	local romHash = StructEncoder.binaryUnpack(packFormat, binaryStream)
	romHash = romHash:match("^%s*(.-)%s*$") or "" -- trim whitespace
	return romHash
end

---Imports all GachaMon Colection data
---@param filepath string
---@param startPosition? number
---@return table collection A table of IGachaMon
function GachaMonData.FileStorage.getCollectionFromFile(filepath, startPosition)
	startPosition = startPosition or 1
	local collection = {}
	if not FileManager.fileExists(filepath) then
		return collection
	end
	local file = io.open(filepath, "rb")
	if not file then
		return collection
	end

	local binaryStream = file:read("*a") or ""
	file:close()
	-- Utils.printDebug("  [GetCollection] Start Position: %s, Stream Size: %s", tostring(startPosition), tostring(#binaryStream))
	local position = startPosition
	while position <= #binaryStream do
		local gachamon, size = GachaMonData.FileStorage.binaryToMon(binaryStream, position)
		if gachamon and size > 0 then
			table.insert(collection, gachamon)
			position = position + size
		else
			-- If something goes wrong and data can't be read in
			break
		end
	end

	return collection
end

---Saves an entire GachaMon collection table to a file, stored as a binary stream
---@param filepathOverride? string
---@return boolean success
function GachaMonData.FileStorage.saveRecentMonsToFile(filepathOverride)
	local filepath = filepathOverride or GachaMonData.FileStorage.getRecentGachaMonsFilePath()
	if not filepath then
		return false
	end
	local file = io.open(filepath, "wb")
	if not file then
		return false
	end

	local romHash = GameSettings.getRomHash()
	local packFormat = string.format("c%s", GachaMonData.FileStorage.RomHashSize or 64)
	local hashBinaryStream = StructEncoder.binaryPack(packFormat, romHash)
	file:write(hashBinaryStream)

	for _, gachamon in pairs(GachaMonData.RecentMons or {}) do
		local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
		if not Utils.isNilOrEmpty(binaryStream) then
			file:write(binaryStream)
		end
	end
	file:flush()
	file:close()

	return true
end

---Saves an entire GachaMon collection table to a file, stored as a binary stream
---@param collection table
---@param filepathOverride? string
---@return boolean success
function GachaMonData.FileStorage.saveCollectionToFile(collection, filepathOverride)
	local filepath = filepathOverride or GachaMonData.FileStorage.getCollectionFilePath()
	if not collection or not filepath then
		return false
	end
	local file = io.open(filepath, "wb")
	if not file then
		return false
	end

	for _, gachamon in ipairs(collection) do
		local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
		if not Utils.isNilOrEmpty(binaryStream) then
			file:write(binaryStream)
		end
	end
	file:flush()
	file:close()

	return true
end

---Appends GachaMon data to the end of the collection data file
---@param gachamon IGachaMon
---@param filepathOverride? string
---@return boolean success
function GachaMonData.FileStorage.tryAppendToCollection(gachamon, filepathOverride)
	-- TODO: Add additional verification to prevent duplicate append of data

	local filepath = filepathOverride or GachaMonData.FileStorage.getCollectionFilePath()
	if not gachamon or not filepath then
		return false
	end
	local file = io.open(filepath, "ab") -- Append to end of collection
	if not file then
		return false
	end

	local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
	if not Utils.isNilOrEmpty(binaryStream) then
		file:write(binaryStream)
		file:flush()
	end

	file:close()
	return true
end

---Transforms GachaMon data into a compact binary stream of data
---@param gachamon IGachaMon
---@return string binaryStream
function GachaMonData.FileStorage.monToBinary(gachamon)
	-- Shove all the compressed bytes together into a long
	local c1 = gachamon:compressMoveIdsGameVersionKeep() -- 40 bits
	local c2 = gachamon:compressShinyGenderNature() -- 8 bits
	local c3 = gachamon:compressDateObtained() -- 16 bits
	local last8bytes = c1 + Utils.bit_lshift(c2, 40) + Utils.bit_lshift(c3, 56)

	-- B-IHBBBBBBBBHL
	return StructEncoder.binaryPack(GachaMonData.FileStorage.PackFormat,
		-- Ordered set of data to pack into binary
		GachaMonData.FileStorage.Version,
		gachamon.Personality,
		gachamon.PokemonId,
		gachamon.AbilityId,
		gachamon.BaseStats.hp,
		gachamon.BaseStats.atk,
		gachamon.BaseStats.def,
		gachamon.BaseStats.spa,
		gachamon.BaseStats.spd,
		gachamon.BaseStats.spe,
		gachamon.RatingScore,
		gachamon.SeedNumber,
		last8bytes
	)
end

---Transforms binary data into a GachaMon object; the data transform process is determined by version number
---@param binaryStream string compact binary stream of data
---@param position? number starting position
---@return IGachaMon|nil gachamon
---@return number size
function GachaMonData.FileStorage.binaryToMon(binaryStream, position)
	position = position or 1
	local version = StructEncoder.binaryUnpack("B", binaryStream, position)
	-- Utils.printDebug("  [binaryToMon] position: %s, version: %s", tostring(position), tostring(version))
	local streamReader = GachaMonData.FileStorage.BinaryStreamReaders[version or false]
	if type(streamReader) ~= "function" then
		return nil, 0
	end

	local gachamon, size = streamReader(binaryStream, position)
	-- Utils.printDebug("  [binaryToMon] success: %s, size: %s", tostring(gachamon ~= nil), tostring(size))
	if not gachamon or size == 0 then
		return nil, 0
	end
	return gachamon, size
end

---Version 1 Binary Stream Reader & Size
---@param binaryStream string compact binary stream of data
---@return IGachaMon|nil gachamon
---@return number size
GachaMonData.FileStorage.BinaryStreamReaders[1] = function(binaryStream, position)
	if Utils.isNilOrEmpty(binaryStream) then
		return nil, 0
	end
	-- The packing format and total size (in bytes)
	local format = "BIHBBBBBBBBHL"
	local size = 25
	-- Utils.printDebug("  [BSR] starting-position: %s, stream size: %s", tostring(position), tostring(#binaryStream))
	-- Unpack binary data into a table
	local data = { StructEncoder.binaryUnpack(format, binaryStream, position) }
	local gachamon = GachaMonData.IGachaMon:new({
		Personality = data[2],
		PokemonId = data[3],
		AbilityId = data[4],
		BaseStats = {
			hp = data[5],
			atk = data[6],
			def = data[7],
			spa = data[8],
			spd = data[9],
			spe = data[10],
		},
		RatingScore = data[11],
		SeedNumber = data[12],
	})
	local last8bytes = data[13]
	gachamon.C_MoveIdsGameVersionKeep = Utils.getbits(last8bytes, 0, 40)
	gachamon.C_ShinyGenderNature = Utils.getbits(last8bytes, 40, 8)
	gachamon.C_DateObtained = Utils.getbits(last8bytes, 48, 16)
	gachamon.Temp.IsShiny = Utils.getbits(gachamon.C_ShinyGenderNature, 0, 1)

	return gachamon, size
end
GachaMonFileManager = {
	-- The current version of the binary stream transform. If the format changes, this version must be incremented.
	Version = 1,
	-- The number of characters to reserve at the start of RecentMons file for storing the matching game's ROM hash (only needs 40)
	RomHashSize = 64,
}

-- A historical record of ALL binary data readers/writers and their storage size, such that any stream of binary data can be transformed into a GachaMon object
-- When adding new versions, don't use function shortcuts for binary/data conversion. Each must be written out per-version.
GachaMonFileManager.BinaryStreams = {}

---@return string filepath
function GachaMonFileManager.getRatingSystemFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RATING_SYSTEM)
end
---@return string filepath
function GachaMonFileManager.getRecentGachaMonsFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RECENT)
end
---@return string filepath
function GachaMonFileManager.getCollectionFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_COLLECTION)
end

---Imports all GachaMon Ratings data from a JSON file
---@param filepath? string Optional, a custom JSON file
---@return boolean success
function GachaMonFileManager.importRatingSystem(filepath)
	filepath = filepath or GachaMonFileManager.getRatingSystemFilePath() or ""
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
	local RS = GachaMonData.RatingsSystem

	for idStr, rating in pairs(data.Abilities or {}) do
		local id = tonumber(idStr)
		if id then
			RS.Abilities[id] = rating
		end
	end
	for idStr, rating in pairs(data.Moves or {}) do
		local id = tonumber(idStr)
		if id then
			RS.Moves[id] = rating
		end
	end
	for statCategory, list in pairs(data.Stats or {}) do
		RS.Stats[statCategory] = {}
		local statTable = RS.Stats[statCategory]
		for _, ratingPair in ipairs(list or {}) do
			table.insert(statTable, ratingPair)
		end
	end
	for _, ratingPair in ipairs(data.RatingToStars or {}) do
		table.insert(RS.RatingToStars, ratingPair)
	end

	return true
end

---Imports any existing Recent GachaMons (when resuming a game session)
---@param filepathOverride? string
function GachaMonFileManager.importRecentGachaMons(filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getRecentGachaMonsFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return
	end
	local importedRomHash = GachaMonFileManager.getRomHashFromFile(filepath)
	if not importedRomHash then
		return
	end

	-- If the RecentMons on file match this ROM, use them
	local recentMonsOrdered = GachaMonFileManager.getCollectionFromFile(filepath, GachaMonFileManager.RomHashSize + 1)
	if importedRomHash == GameSettings.getRomHash() then
		for _, gachamon in ipairs(recentMonsOrdered) do
			GachaMonData.RecentMons[gachamon.Personality] = gachamon
		end
		return
	end

	-- Otherwise, store any RecentMons, which were flagged as "Keep", from the previous rom into the user's Collection
	for _, gachamon in ipairs(recentMonsOrdered or {}) do
		if gachamon:getKeep() == 1 then
			table.insert(GachaMonData.Collection, gachamon)
			GachaMonFileManager.tryAppendToCollection(gachamon)
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
function GachaMonFileManager.importCollection(filepath)
	filepath = filepath or GachaMonFileManager.getCollectionFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return
	end

	-- Import any existing data
	GachaMonData.Collection = GachaMonFileManager.getCollectionFromFile(filepath)
	GachaMonData.Collection.isLoadedFromFile = true
end

---Reads the RomHash value from the start of the RecentMons data file
---@param filepathOverride? string
---@return string|nil
function GachaMonFileManager.getRomHashFromFile(filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getRecentGachaMonsFilePath()
	if not FileManager.fileExists(filepath) then
		return nil
	end
	local file = io.open(filepath, "rb")
	if not file then
		return nil
	end
	local binaryStream = file:read("*a") or ""
	file:close()
	local packFormat = string.format("c%s", GachaMonFileManager.RomHashSize or 64)
	local romHash = StructEncoder.binaryUnpack(packFormat, binaryStream)
	romHash = romHash:match("^%s*(.-)%s*$") or "" -- trim whitespace
	return romHash
end

---Imports all GachaMon Colection data
---@param filepath string
---@param startPosition? number
---@return table collection A table of IGachaMon
function GachaMonFileManager.getCollectionFromFile(filepath, startPosition)
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
		local gachamon, size = GachaMonFileManager.binaryToMon(binaryStream, position)
		if gachamon and size > 0 then
			table.insert(collection, gachamon)
			position = position + size
		else
			-- If something goes wrong and data can't be read in
			local filename = FileManager.extractFileNameFromPath(filepath)
			print("> [ERROR] Unable to read GachaMon at position %s in file %s", position, filename)
			break
		end
	end

	return collection
end

---Saves an entire GachaMon collection table to a file, stored as a binary stream
---@param filepathOverride? string
---@return boolean success
function GachaMonFileManager.saveRecentMonsToFile(filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getRecentGachaMonsFilePath()
	if not filepath then
		return false
	end
	local file = io.open(filepath, "wb")
	if not file then
		return false
	end

	local romHash = GameSettings.getRomHash()
	local packFormat = string.format("c%s", GachaMonFileManager.RomHashSize or 64)
	local hashBinaryStream = StructEncoder.binaryPack(packFormat, romHash)
	file:write(hashBinaryStream)

	for _, gachamon in pairs(GachaMonData.RecentMons or {}) do
		local binaryStream = GachaMonFileManager.monToBinary(gachamon)
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
function GachaMonFileManager.saveCollectionToFile(collection, filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getCollectionFilePath()
	if not collection or not filepath then
		return false
	end
	local file = io.open(filepath, "wb")
	if not file then
		return false
	end

	for _, gachamon in ipairs(collection) do
		local binaryStream = GachaMonFileManager.monToBinary(gachamon)
		if not Utils.isNilOrEmpty(binaryStream) then
			file:write(binaryStream)
		end
	end
	file:flush()
	file:close()

	return true
end

---Called when the Overlay or Tracker closes and, if applicable, saves the collection to file.
---@param collection? table
---@param filepathOverride? string
---@return boolean success
function GachaMonFileManager.trySaveCollectionOnClose(collection, filepathOverride)
	if not GachaMonData.collectionRequiresSaving then
		return false
	end
	GachaMonData.collectionRequiresSaving = false
	collection = collection or GachaMonData.Collection
	return GachaMonFileManager.saveCollectionToFile(GachaMonData.Collection, filepathOverride)
end

---Appends GachaMon data to the end of the collection data file
---@param gachamon IGachaMon
---@param filepathOverride? string
---@return boolean success
function GachaMonFileManager.tryAppendToCollection(gachamon, filepathOverride)
	-- TODO: Add additional verification to prevent duplicate append of data

	local filepath = filepathOverride or GachaMonFileManager.getCollectionFilePath()
	if not gachamon or not filepath then
		return false
	end
	local file = io.open(filepath, "ab") -- Append to end of collection
	if not file then
		return false
	end

	local binaryStream = GachaMonFileManager.monToBinary(gachamon)
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
function GachaMonFileManager.monToBinary(gachamon)
	local version = gachamon.Version
	local BS = GachaMonFileManager.BinaryStreams[version or false] or {}
	if type(BS.Writer) ~= "function" then
		return ""
	end
	local binaryStream = BS.Writer(gachamon)
	return binaryStream
end

---Transforms binary data into a GachaMon object; the data transform process is determined by version number
---@param binaryStream string compact binary stream of data
---@param position? number starting position
---@return IGachaMon|nil gachamon
---@return number size
function GachaMonFileManager.binaryToMon(binaryStream, position)
	position = position or 1
	local version = StructEncoder.binaryUnpack("B", binaryStream, position)
	-- Utils.printDebug("  [binaryToMon] position: %s, version: %s", tostring(position), tostring(version))
	local BS = GachaMonFileManager.BinaryStreams[version or false] or {}
	if type(BS.Reader) ~= "function" then
		return nil, 0
	end
	local gachamon, size = BS.Reader(binaryStream, position)
	-- Utils.printDebug("  [binaryToMon] success: %s, size: %s", tostring(gachamon ~= nil), tostring(size))
	if not gachamon or size == 0 then
		return nil, 0
	end
	return gachamon, size
end

--Version 1 Binary Stream
GachaMonFileManager.BinaryStreams[1] = {
	Format = "BIHBBBHIIII", -- The packing format (version # always occupies the 1st byte)
	Size = 28, -- Number of bytes per GachaMon stored
}

---@param binaryStream string compact binary stream of data
---@return IGachaMon|nil gachamon
---@return number size
GachaMonFileManager.BinaryStreams[1].Reader = function(binaryStream, position)
	local BS = GachaMonFileManager.BinaryStreams[1]
	if Utils.isNilOrEmpty(binaryStream) then
		return nil, 0
	end
	-- Unpack binary data into a table
	local data = { StructEncoder.binaryUnpack(BS.Format, binaryStream, position) }
	local gachamon = GachaMonData.IGachaMon:new({
		Version = data[1],
		Personality = data[2],
		Level = data[4],
		AbilityId = data[5],
		RatingScore = data[6],
		SeedNumber = data[7],
		C_StatsHpAtkDef = data[8],
		C_StatsSpaSpdSpe = data[9],
	})
	local idPowerFavorite = data[3]
	gachamon.PokemonId = Utils.getbits(idPowerFavorite, 0, 11)
	gachamon.BattlePower = Utils.getbits(idPowerFavorite, 11, 4) * 1000
	gachamon.Favorite = Utils.getbits(idPowerFavorite, 15, 1)
	local movepair1 = data[10]
	local movepair2 = data[11]
	-- Utils.printDebug("Unpack: %x as %s", Utils.getbits(last8bytes, 0, 40), Utils.getbits(Utils.getbits(last8bytes, 0, 40), 0, 9))
	gachamon.C_MoveIdsGameVersionKeep = movepair1 + Utils.bit_lshift(Utils.getbits(movepair2, 0, 8), 32)
	gachamon.C_ShinyGenderNature = Utils.getbits(movepair2, 8, 8)
	gachamon.C_DateObtained = Utils.getbits(movepair2, 16, 16)
	gachamon.Temp.IsShiny = Utils.getbits(gachamon.C_ShinyGenderNature, 0, 1)
	return gachamon, BS.Size
end

---@param gachamon IGachaMon
---@return string binaryStream compact binary stream of data
GachaMonFileManager.BinaryStreams[1].Writer = function(gachamon)
	local BS = GachaMonFileManager.BinaryStreams[1]
	local battlePower = math.floor(gachamon.BattlePower / 1000)
	-- Compress into a 2-byte value
	local idPowerFavorite = gachamon.PokemonId + Utils.bit_lshift(battlePower, 11) + Utils.bit_lshift(gachamon.Favorite, 15)
	-- Compress stats into two 4-byte pairs
	local stats1 = gachamon:compressStatsHpAtkDef()
	local stats2 = gachamon:compressStatsSpaSpdSpe()
	-- Compress various other values together into two 4-byte pairs
	local c1 = gachamon:compressMoveIdsGameVersionKeep() -- 40 bits
	local c2 = gachamon:compressShinyGenderNature() -- 8 bits
	local c3 = gachamon:compressDateObtained() -- 16 bits
	local movepair1 = Utils.getbits(c1, 0, 32)
	local movepair2 = Utils.getbits(c1, 32, 8) + Utils.bit_lshift(c2, 8) + Utils.bit_lshift(c3, 16)
	return StructEncoder.binaryPack(BS.Format,
		-- Ordered set of data to pack into binary
		gachamon.Version,
		gachamon.Personality,
		idPowerFavorite,
		gachamon.Level,
		gachamon.AbilityId,
		gachamon.RatingScore,
		gachamon.SeedNumber,
		stats1,
		stats2,
		movepair1,
		movepair2
	)
end

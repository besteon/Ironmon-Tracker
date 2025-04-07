GachaMonFileManager = {
	-- The current version of the binary stream transform. If the format changes, this version must be incremented. (0-255)
	Version = 1,
	-- The number of characters to reserve at the start of RecentMons file for storing the matching game's ROM hash (only needs 40)
	RomHashSize = 64,
	-- Current number of card pack image files that exist
	NUMBER_CARDPACKS = 10,
}

-- A historical record of ALL binary data readers/writers and their storage size, such that any stream of binary data can be transformed into a GachaMon object
-- When adding new versions, don't use function shortcuts for binary/data conversion. Each must be written out per-version.
GachaMonFileManager.BinaryStreams = {}

-- function GachaMonFileManager.initialize()
	-- Currently unused
-- end

---@return string filepath
function GachaMonFileManager.getRatingSystemFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_RATING_SYSTEM)
end
---@return string filepath
function GachaMonFileManager.getSeenMonsFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_SEEN_MONS)
end
---@return string filepath
function GachaMonFileManager.getRecentMonsFilePath()
	local profile = QuickloadScreen.getActiveProfile()
	if not profile then
		return FileManager.prependDir(FileManager.Files.GACHAMON_RECENT_DEFAULT)
	end
	-- Create path if hasn't been set yet
	if Utils.isNilOrEmpty(profile.Paths.GachaMon) then
		profile.Paths.GachaMon = QuickloadScreen.generateGachaMonFilePath(profile)
	end
	return profile.Paths.GachaMon
end
---@return string filepath
function GachaMonFileManager.getCollectionFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_COLLECTION)
end
---@param packNumberOverride? number Which pack number to get the filepath for, currently packs are numbered 1-10
---@return string filepath
function GachaMonFileManager.getRandomCardPackFilePath(packNumberOverride)
	local packNumber = packNumberOverride or math.random(1, GachaMonFileManager.NUMBER_CARDPACKS)
	local filename = string.format("%s%s", FileManager.PreFixes.CARDPACK, packNumber)
	return FileManager.buildImagePath(FileManager.Folders.GachaMonImages, filename, FileManager.Extensions.PNG)
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
		Natures = {},
		Stats = {},
		CategoryMaximums = {},
		OtherAdjustments = {},
		RatingToStars = {},
		Rulesets = {}
	}
	local RS = GachaMonData.RatingsSystem

	-- Abilities
	for idStr, rating in pairs(data.Abilities or {}) do
		local id = tonumber(idStr)
		if id then
			RS.Abilities[id] = rating
		end
	end
	-- Moves
	for idStr, rating in pairs(data.Moves or {}) do
		local id = tonumber(idStr)
		if id then
			RS.Moves[id] = rating
		end
	end
	-- Natures
	RS.Natures.Beneficial = {}
	RS.Natures.Detrimental = {}
	for _, natureId in ipairs(data.Natures.BeneficialOffensive.NatureIds or {}) do
		RS.Natures.Beneficial[natureId] = data.Natures.BeneficialOffensive.Points
	end
	for _, natureId in ipairs(data.Natures.BeneficialDefensive.NatureIds or {}) do
		RS.Natures.Beneficial[natureId] = data.Natures.BeneficialDefensive.Points
	end
	for _, natureId in ipairs(data.Natures.BeneficialSpeed.NatureIds or {}) do
		RS.Natures.Beneficial[natureId] = data.Natures.BeneficialSpeed.Points
	end
	for _, natureId in ipairs(data.Natures.DetrimentalOffensive.NatureIds or {}) do
		RS.Natures.Detrimental[natureId] = data.Natures.DetrimentalOffensive.Points
	end
	for _, natureId in ipairs(data.Natures.DetrimentalDefensive.NatureIds or {}) do
		RS.Natures.Detrimental[natureId] = data.Natures.DetrimentalDefensive.Points
	end
	for _, natureId in ipairs(data.Natures.DetrimentalSpeed.NatureIds or {}) do
		RS.Natures.Detrimental[natureId] = data.Natures.DetrimentalSpeed.Points
	end
	-- Stats
	for statCategory, list in pairs(data.Stats or {}) do
		RS.Stats[statCategory] = {}
		local statTable = RS.Stats[statCategory]
		for _, ratingPair in ipairs(list or {}) do
			table.insert(statTable, ratingPair)
		end
	end
	-- CategoryMaximums
	for category, maximum in pairs(data.CategoryMaximums or {}) do
		RS.CategoryMaximums[category] = maximum
	end
	-- OtherAdjustments
	for key, val in pairs(data.OtherAdjustments or {}) do
		RS.OtherAdjustments[key] = val
	end
	-- RatingToStars
	for _, ratingPair in ipairs(data.RatingToStars or {}) do
		table.insert(RS.RatingToStars, ratingPair)
	end
	-- Rulesets
	for rulesetName, rulesetData in pairs(data.Rulesets or {}) do
		RS.Rulesets[rulesetName] = {
			BannedAbilities = {},
			BannedAbilityExceptions = {},
			BannedMoves = {},
			AdjustedMoves = {},
		}
		local R = RS.Rulesets[rulesetName]
		for _, id in pairs(rulesetData.BannedAbilities or {}) do
			R.BannedAbilities[id] = true
		end
		for _, id in pairs(rulesetData.BannedMoves or {}) do
			R.BannedMoves[id] = true
		end
		for _, id in pairs(rulesetData.AdjustedMoves or {}) do
			R.AdjustedMoves[id] = true
		end
		for _, exceptionPair in pairs(rulesetData.BannedAbilityExceptions or {}) do
			table.insert(R.BannedAbilityExceptions, exceptionPair)
		end
	end

	return true
end

---Imports all GachaMon Seen data from a JSON file (Dex tracking for which mons were captured but never collected)
---@param filepath? string Optional, a custom JSON file
---@return boolean success
function GachaMonFileManager.importSeenMons(filepath)
	filepath = filepath or GachaMonFileManager.getSeenMonsFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not (data and data.Seen) then
		return false
	end

	-- Copy over the imported data to the gachamon ratings system
	GachaMonData.SeenMons = {}
	local SM = GachaMonData.SeenMons

	for _, id in ipairs(data.Seen or {}) do
		SM[id] = true
	end

	return true
end

---Imports any existing Recent GachaMons (when resuming a game session)
---@param forceImportAndUse? boolean Optional, if true will import any found RecentMons from file regardless of ROM hash mismatch; default: false
---@param filepathOverride? string
function GachaMonFileManager.importRecentMons(forceImportAndUse, filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getRecentMonsFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return
	end
	-- If no ROM hash found, then there is also no RecentMons data to import
	local importedRomHash = GachaMonFileManager.readRomHashFromRecentMonsFile(filepath)
	if not importedRomHash then
		return
	end

	-- If the RecentMons on file match this ROM, use them
	local recentMonsOrdered = GachaMonFileManager.getCollectionFromFile(filepath, GachaMonFileManager.RomHashSize + 1)
	if forceImportAndUse or importedRomHash == GameSettings.getRomHash() then
		for _, gachamon in ipairs(recentMonsOrdered) do
			local pidIndex = gachamon.Personality + gachamon.PokemonId
			GachaMonData.RecentMons[pidIndex] = gachamon
			if not GachaMonData.SeenMons[gachamon.PokemonId] then
				GachaMonData.SeenMons[gachamon.PokemonId] = true
			end
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
function GachaMonFileManager.readRomHashFromRecentMonsFile(filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getRecentMonsFilePath()
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

---Saves a game-specific GachaMon collection table (recent mons captured) to a file, stored as a binary stream, prefixed by the romhash of the game
---@param filepathOverride? string
---@return boolean success
function GachaMonFileManager.saveRecentMonsToFile(filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getRecentMonsFilePath()
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

---Saves the Seen Mons info table to a file, stored as JSON
---@param filepathOverride? string
---@return boolean success
function GachaMonFileManager.saveSeenMonsToFile(filepathOverride)
	local filepath = filepathOverride or GachaMonFileManager.getSeenMonsFilePath()
	if not filepath then
		return false
	end

	local data = {
		Seen = {}
	}
	for id, _ in pairs(GachaMonData.SeenMons or {}) do
		table.insert(data.Seen, id)
	end
	table.sort(data.Seen, function(a, b) return a < b end)
	local success = FileManager.encodeToJsonFile(filepath, data)

	return success == true
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
	Format = "BIHBBBHBBBIIII", -- The packing format (version # always occupies the 1st byte)
	Size = 31, -- Number of bytes per GachaMon stored
}

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
		gachamon.Badges,
		gachamon.Type1,
		gachamon.Type2,
		stats1,
		stats2,
		movepair1,
		movepair2
	)
end

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
		Badges = data[8],
		Type1 = data[9],
		Type2 = data[10],
		C_StatsHpAtkDef = data[11],
		C_StatsSpaSpdSpe = data[12],
	})
	local idPowerFavorite = data[3]
	gachamon.PokemonId = Utils.getbits(idPowerFavorite, 0, 11)
	gachamon.BattlePower = Utils.getbits(idPowerFavorite, 11, 4) * 1000
	gachamon.Favorite = Utils.getbits(idPowerFavorite, 15, 1)
	local movepair1 = data[13]
	local movepair2 = data[14]
	gachamon.C_MoveIdsGameVersionKeep = movepair1 + Utils.bit_lshift(Utils.getbits(movepair2, 0, 8), 32)
	gachamon.C_ShinyGenderNature = Utils.getbits(movepair2, 8, 8)
	gachamon.C_DateObtained = Utils.getbits(movepair2, 16, 16)
	gachamon.Temp.IsShiny = gachamon:getIsShiny()
	return gachamon, BS.Size
end

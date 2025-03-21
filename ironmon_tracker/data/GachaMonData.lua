GachaMonData = {
	MAX_BATTLE_POWER = 15000,
	SHINY_ODDS = 0.002, -- 1 in 500, similar to Pokémon Go
	TRAINERS_TO_DEFEAT = 2, -- The number of trainers a Pokémon needs to defeat to automatically be kept in the player's permanent Collection

	-- The user's entire GachaMon collection (ordered list). Populated from file only when the user first goes to view the Collection on the Tracker
	Collection = {},

	-- Stores the GachaMons for the current gameplay session only. Table key is the Pokémon's personality value
	RecentMons = {},

	-- Populated on Tracker startup from the ratings data json file
	RatingsSystem = {},

	FileStorage = {
		-- The current version of the binary stream transform. If the format changes, this version must be incremented.
		Version = 1,
		-- The number of characters to reserve at the start of RecentMons file for storing the matching game's ROM hash (only needs 40)
		RomHashSize = 64,
	},

	-- A one-time initial collection load when the Collection is first viewed
	initialCollectionLoad = false,
	-- Anytime Collection changes, flag this as true; Collection is saved to file sparingly, typically when the Overlay or Tracker closes
	collectionRequiresSaving = false,
	-- When a new GachaMon is caught/created, this will temporarily store that mon's data
	newestRecentMon = nil,
}

--[[
TODO LIST
- [UI] Collection tab: find a way to display lots of data cleanly. Quick access to favorite button. Add filter options
- [UI] Options: add a "clean up collection" button + prompt to easily delete non-favorite cards with certain criteria
- [UI] Battle: ??? Perhaps draw a Kanto Gym badge/environment to battle on, and have it affect the battle.
- [UI] Design UI and animation for capturing a new GachaMon (click to open: fade to black, animate pack, animate opening, show mon)
- [Text UI] Create a basic MGBA viewing interface
]]

function GachaMonData.initialize()
	-- Reset data variables
	GachaMonData.RecentMons = {}
	GachaMonData.Collection = {}
	GachaMonData.initialCollectionLoad = false
	GachaMonData.collectionRequiresSaving = false
	GachaMonData.clearNewestMonToShow()

	-- Import universally useful data
	GachaMonData.FileStorage.importRatingSystem()
	GachaMonData.FileStorage.importRecentGachaMons()
end

function GachaMonData.test()
	local pokemon = TrackerAPI.getPlayerPokemon()
	-- if not pokemon then
	-- 	Utils.printDebug("[GACHAMON] No Pokémon in party.")
	-- 	return
	-- end

	if pokemon then
		-- Test converting 1st mon in party to GachaMon
		local gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
		Utils.printDebug("[GACHAMON] %s >>> Rating: %s | Stars: %s <<<",
			PokemonData.Pokemon[gachamon.PokemonId].name,
			gachamon.RatingScore,
			gachamon:getStars()
		)

		-- Test to-and-from binary
		local binaryStream = GachaMonData.FileStorage.monToBinary(gachamon)
		local mon = GachaMonData.FileStorage.binaryToMon(binaryStream)
		Utils.printDebug("Binary Transform Success: %s - %s", tostring(mon ~= nil), mon ~= nil and mon.PokemonId or "N/A")

		-- Test base-64 encoding of data
		local b64string = GachaMonData.getShareablyCode(gachamon)
		Utils.printDebug("Share Code: %s", b64string)
	end

	Program.openOverlayScreen(GachaMonOverlay, true)
end

---Helper function to check if the GachaMon belongs to the RecentMons, otherwise it can be assumed it's part of the collection
---@param gachamon IGachaMon
---@return boolean isRecentMon True if belongs to the RecentMons, False if belongs to the collection (or not found)
function GachaMonData.isRecentMon(gachamon)
	local recentMon = GachaMonData.RecentMons[gachamon.Personality] or {}
	local isRecentMon = recentMon.PokemonId == gachamon.PokemonId and recentMon.SeedNumber == gachamon.SeedNumber
	return isRecentMon
end

---Helper function to look up the index of a GachaMon in the collection (returns -1 if not found)
---@param gachamon IGachaMon
---@return number index
function GachaMonData.findInCollection(gachamon)
	for i, mon in ipairs(GachaMonData.Collection or {}) do
		if mon == gachamon then
			return i
		end
	end
	return -1
end

---@param pokemonData IPokemon
---@return IGachaMon gachamon
function GachaMonData.convertPokemonToGachaMon(pokemonData)
	local gachamon = GachaMonData.IGachaMon:new({
		Version = GachaMonData.FileStorage.Version,
		Personality = pokemonData.personality or 0,
		PokemonId = pokemonData.pokemonID or 0,
		Level = pokemonData.level or 0,
		SeedNumber = Main.currentSeed or 0,
		Temp = {
			Stats = {},
			MoveIds = {},
			GameVersion = GameSettings.gameVersionToNumber(GameSettings.versioncolor),
			IsShiny = pokemonData.isShiny and 1 or 0,
			Nature = pokemonData.nature or 0,
			DateTimeObtained = os.time(),
		},
	})

	gachamon.AbilityId = PokemonData.getAbilityId(pokemonData.pokemonID, pokemonData.abilityNum)

	for statKey, statValue in pairs(pokemonData.stats or {}) do
		gachamon.Temp.Stats[statKey] = statValue
	end

	for _, move in ipairs(pokemonData.moves or {}) do
		if MoveData.isValid(move.id) then
			table.insert(gachamon.Temp.MoveIds, move.id)
		end
	end

	if pokemonData.gender == MiscData.Gender.MALE then
		gachamon.Temp.Gender = 1
	elseif pokemonData.gender == MiscData.Gender.FEMALE then
		gachamon.Temp.Gender = 2
	end

	-- Reroll shininess chance
	if gachamon.Temp.IsShiny ~= 1 and math.random() <= GachaMonData.SHINY_ODDS then
		gachamon.Temp.IsShiny = 1
	end

	local pokemonInternal = PokemonData.Pokemon[pokemonData.pokemonID or 0]
	local baseStats = pokemonInternal and pokemonInternal.baseStats or {}

	gachamon.RatingScore = GachaMonData.calculateRatingScore(gachamon, baseStats)
	gachamon.BattlePower = GachaMonData.calculateBattlePower(gachamon)
	gachamon.Temp.Stars = GachaMonData.calculateStars(gachamon)

	return gachamon
end

---Calculates the GachaMon's "Rating Score" based on its ability, moves, stats, and other factors
---@param gachamon IGachaMon
---@param baseStats table
---@return number rating Value between 0 and 100
function GachaMonData.calculateRatingScore(gachamon, baseStats)
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
	-- Offensive Stats (Atk & Spa separately)
	local offensiveAtk = baseStats.atk or 0
	local offensiveSpa = baseStats.spa or 0
	local offensiveRating = 0
	for _, ratingPair in ipairs(RS.Stats.Offensive or {}) do
		if offensiveAtk >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			offensiveRating = offensiveRating + ratingPair.Rating
			offensiveAtk = 0
		end
		if offensiveSpa >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			offensiveRating = offensiveRating + ratingPair.Rating
			offensiveSpa = 0
		end
	end
	ratingTotal = ratingTotal + offensiveRating
	-- Defensives Stat (HP, Def, SpDef)
	local defensiveStats = (baseStats.hp or 0) + (baseStats.def or 0) + (baseStats.spd or 0)
	local defensiveRating = 0
	for _, ratingPair in ipairs(RS.Stats.Defensive or {}) do
		if defensiveStats >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			defensiveRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + defensiveRating
	-- Speed Stat (Spe)
	local speedStat = (baseStats.spe or 0)
	local speedRating = 0
	for _, ratingPair in ipairs(RS.Stats.Speed or {}) do
		if speedStat >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
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

---Calculates the GachaMon's "Battle Power" based on its rating, STAB moves, nature, etc
---@param gachamon IGachaMon
---@return number power Value between 0 and GachaMonData.MAX_BATTLE_POWER (15000)
function GachaMonData.calculateBattlePower(gachamon)
	local power = 0

	-- Add stars/rating bonus
	local starsBonus = (gachamon:getStars() or 0) * 1000
	power = power + starsBonus

	-- Add move power & STAB bonus
	local pokemonInternal = PokemonData.Pokemon[gachamon.PokemonId or false] or PokemonData.BlankPokemon
	local totalMovePower, hasStab = 0, false
	for _, moveId in ipairs(gachamon:getMoveIds() or {}) do
		local move = MoveData.Moves[moveId or false]
		if move then
			totalMovePower = totalMovePower + MoveData.getExpectedPower(moveId)
			if not hasStab and Utils.isSTAB(move, move.type, pokemonInternal.types or {}) then
				hasStab = true
			end
		end
	end
	local movePowerBonus = math.floor(totalMovePower / 150) * 1000
	power = power + movePowerBonus
	if hasStab then
		power = power + 1000
	end

	-- Add matching nature bonus
	local stats = gachamon:getStats()
	local statKey = (stats.atk or 0 > stats.spa or 0) and "atk" or "spa"
	local multiplier = Utils.getNatureMultiplier(statKey, gachamon:getNature())
	local natureBonus = math.floor(multiplier * 10 - 10) * 1000
	power = power + natureBonus

	Utils.printDebug("[BATTLE POWER] Stars: %s, Moves: %s, STAB: %s, Nature: %s",
		starsBonus,
		movePowerBonus,
		hasStab and 1000 or 0,
		natureBonus
	)

	return math.min(math.floor(power), GachaMonData.MAX_BATTLE_POWER)
end

---Calculates the GachaMon's "Stars" based on its rating score
---@param gachamon IGachaMon
---@return number stars Value between 0 and 6 (0: non-existent rating, 6: is the 5+ rating)
function GachaMonData.calculateStars(gachamon)
	if (gachamon.RatingScore or 0) <= 0 then
		return 0
	end
	for _, ratingPair in ipairs(GachaMonData.RatingsSystem.RatingToStars or {}) do
		if gachamon.RatingScore >= (ratingPair.Rating or 1) and ratingPair.Stars then
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

---Called when a Pokémon/GachaMon wins a trainer battle, flagging it to save in the permanent collection
---@param mon IPokemon|IGachaMon It's associated GachaMon from RecentMons will be used
---@return boolean success
function GachaMonData.tryAutoKeepInCollection(mon)
	local gachamon = GachaMonData.RecentMons[mon.personality or mon.Personality or false]
	if not gachamon or gachamon:getKeep() == 1 then
		return false
	end
	-- Only auto-keep the good, successful Pokémon
	gachamon.Temp.TrainersDefeated = (gachamon.Temp.TrainersDefeated or 0) + 1
	if gachamon.Temp.TrainersDefeated < GachaMonData.TRAINERS_TO_DEFEAT then
		return false
	end

	Utils.printDebug("[tryKeepInCollection] Keeping this mon, Personality: %s", tostring(gachamon.Personality))

	-- Flag this GachaMon as something to keep in collection
	GachaMonData.updateGachaMonAndSave(gachamon, nil, true)

	return true
end

---Only a few attributes of a GachaMon are able to be changed once created, such as marking as favorite and/or adding to collection.
---This will make those changes and save to the RecentMons file or Collection file.
---@param gachamon IGachaMon
---@param isFave? boolean
---@param isKeep? boolean
function GachaMonData.updateGachaMonAndSave(gachamon, isFave, isKeep)
	local monHasChanged = false

	if isFave ~= nil then -- if nil, don't make changes
		local changed = gachamon:setFavorite(isFave and 1 or 0)
		monHasChanged = monHasChanged or changed
	end
	if isKeep ~= nil then -- if nil, don't make changes
		local changed = gachamon:setKeep(isKeep and 1 or 0)
		monHasChanged = monHasChanged or changed
	end

	-- If data about the GachaMon has changed, save those changes to file
	if not monHasChanged then
		return
	end

	if GachaMonData.isRecentMon(gachamon) then
		GachaMonData.FileStorage.saveRecentMonsToFile()
	elseif GachaMonData.Collection.isLoadedFromFile then -- this should always be true if editing a collection mon
		GachaMonData.collectionRequiresSaving = true
	end
end

---Tries to permanently remove a GachaMon from the Collection by first prompting the user it's okay to do so.
---@param gachamon IGachaMon
function GachaMonData.tryRemoveFromCollection(gachamon)
	if GachaMonData.isRecentMon(gachamon) then
		GachaMonData.updateGachaMonAndSave(gachamon, nil, false)
		return
	end
	-- If somehow how a GachaMon claims its in a collection that was never loaded
	if not GachaMonData.Collection.isLoadedFromFile then
		return
	end
	-- ... or it just doesn't exist in the collection
	local index = GachaMonData.findInCollection(gachamon)
	if index == -1 then
		return
	end

	-- Assuming it's part of the collection, removal requires confirmation
	GachaMonData.openGachaMonRemovalConfirmation(gachamon, index)
end

---Opens a prompt box to confirm with the user for permanent removal of this GachaMon from collection
---@param gachamon IGachaMon
---@param index? number Optional, the index of this gachamon in the Collection
function GachaMonData.openGachaMonRemovalConfirmation(gachamon, index)
	index = index or GachaMonData.findInCollection(gachamon)
	if index == -1 or GachaMonData.Collection[index] ~= gachamon then
		return
	end
	local name = gachamon:getName()
	local stars = math.min(gachamon:getStars(), 5) -- max of 5
	local power = gachamon.BattlePower or 0

	local form = ExternalUI.BizForms.createForm("Permanently Remove From Collection?", 450, 160)
	form:createLabel("This will permanently remove this GachaMon from your Collection:", 19, 10)
	form:createLabel(string.format("%s  ---  %s %s --- %s %s", name, stars, "Stars", power, "Battle Power"), 19, 30)
	form.Controls.warningLabel = form:createLabel("ARE YOU SURE?", 150, 50)
	ExternalUI.BizForms.setProperty(form.Controls.warningLabel, ExternalUI.BizForms.Properties.FORE_COLOR, "red")

	form:createButton("Yes, Delete Forever!", 30, 85, function()
		table.remove(GachaMonData.Collection, index)
		GachaMonData.collectionRequiresSaving = true
		-- TODO: this probably isnt correct
		if Program.currentOverlay == GachaMonOverlay and GachaMonOverlay.currentTab == GachaMonOverlay.Tabs.View then
			GachaMonOverlay.currentTab = GachaMonOverlay.Tabs.Collection
			GachaMonOverlay.refreshButtons()
			Program.redraw(true)
		end
		form:destroy()
	end)
	form:createButton(Resources.AllScreens.Cancel, 260, 85, function()
		form:destroy()
	end)
end


---@class IGachaMon
GachaMonData.IGachaMon = {
	-- Total size in bytes (including version prefix): 28
	-- 1 Byte; Unchanged once created, unless the GachaMon needs to be updated (not applicable yet)
	Version = 0,
	-- 4 Bytes; the Pokémon game's "unique identifier"
	Personality = 0,
	-- 2 Bytes (11 bits)
	PokemonId = 0,
	-- 1 Byte (7 bits)
	Level = 0,
	-- 1 Byte (7 bits)
	AbilityId = 0,
	-- 1 Byte (7 bits); value rounded up
	RatingScore = 0,
	-- 0 Bytes (4 bits); stored with PokemonId as FBBBBPPP
	BattlePower = 0,
	-- 0 Bytes (1 bit); stored with PokemonId as FBBBBPPP
	Favorite = 0,
	-- 2 Bytes (16 bits); The seed number at the time this mon was collected
	SeedNumber = 0,
	-- 4 Bytes (10 bits x3); Ordered as:
	-- 00DDDDDD DDDDAAAA AAAAAAHH HHHHHHHH
	C_StatsHpAtkDef = 0,
	-- 00SSSSSS SSSSDDDD DDDDDDAA AAAAAAAA
	C_StatsSpaSpdSpe = 0,
	-- 5 Bytes (9 bits x4, + 3 bits + 1 bit); 4 move ids, game version, and keep permanently; left-most byte as KVVVMMMM
	-- Game Version (3bits) 1:Ruby/4:Sapphire, 2:Emerald, 3:FireRed/5:LeafGreen
	-- Keep set to 1 only for deciding to save a RecentMons into the Collection permanently
	C_MoveIdsGameVersionKeep = 0,
	-- 1 Byte (8 bits); bit-compressed together as: NNNNNGGS
	C_ShinyGenderNature = 0,
	-- 2 Bytes (16 bits); year stored as -2000 actual value (7 bits), month (4 bits), day (5 bits) as: YYYYYYYM MMMDDDDD
	C_DateObtained = 0,

	-- Any other data for easy access, but won't be stored in the collection file
	Temp = {},

	-- Helper functions for converting data to proper formats, binary or otherwise

	---Builds the display data needed to show off a GachaMon collectable card
	---@return table
	getCardDisplayData = function(self)
		if self.Temp.Card then
			return self.Temp.Card
		end
		self.Temp.Card = {}
		local C = self.Temp.Card
		local stats = self:getStats()
		local pokemonInternal = PokemonData.Pokemon[self.PokemonId or false] or PokemonData.BlankPokemon

		C.Stars = self:getStars()
		C.Power = self.BattlePower or 0
		C.Favorite = self.Favorite or 0
		C.InCollection = self:getKeep() == 1
		C.PokemonId = self.PokemonId -- Icon
		C.AbilityId = self.AbilityId -- Rules Text
		C.StatBars = {}
		for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local statValue = (stats[statKey] or 0)
			if statKey == "hp" then
				statValue = statValue - 10
			end
			-- Cut off extremely low stat values
			if statValue <= 6 then
				statValue = 0
			end
			C.StatBars[statKey] = math.min(math.floor(statValue / self.Level), 5) -- max of 5
		end
		if self:getIsShiny() == 1 then
			C.ShinyAnimationFrame = math.random(1, 120)
		end
		C.FrameColors = {}
		C.FrameColors[1] = Constants.MoveTypeColors[pokemonInternal.types[1] or PokemonData.Types.UNKNOWN]
		C.FrameColors[2] = Constants.MoveTypeColors[pokemonInternal.types[2] or false] or C.FrameColors[1]
		return C
	end,

	-- 00DDDDDD DDDDAAAA AAAAAAHH HHHHHHHH
	compressStatsHpAtkDef = function(self)
		if self.C_StatsHpAtkDef == 0 and type(self.Temp.Stats) == "table" then
			self.C_StatsHpAtkDef = (self.Temp.Stats.hp or 0) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.atk or 0), 10) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.def or 0), 20) -- 10 bits
		end
		return self.C_StatsHpAtkDef
	end,
	-- 00SSSSSS SSSSDDDD DDDDDDAA AAAAAAAA
	compressStatsSpaSpdSpe = function(self)
		if self.C_StatsSpaSpdSpe == 0 and type(self.Temp.Stats) == "table" then
			self.C_StatsSpaSpdSpe = (self.Temp.Stats.spa or 0) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.spd or 0), 10) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.spe or 0), 20) -- 10 bits
		end
		return self.C_StatsSpaSpdSpe
	end,
	-- KVVVMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
	compressMoveIdsGameVersionKeep = function(self)
		if self.C_MoveIdsGameVersionKeep == 0 and type(self.Temp.MoveIds) == "table" then
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

	---Use `GachaMonData.updateAndSaveGachaMon()` to properly make saved changes to GachaMons
	---@param favoriteBit number
	---@return boolean dataChanged
	setFavorite = function(self, favoriteBit)
		local dataChanged = self.Favorite ~= favoriteBit
		self.Favorite = favoriteBit
		if dataChanged then
			-- TODO: re-save recent mon collection
			self.Temp.Card = nil -- requires rebuilding
		end
		return dataChanged
	end,
	---Use `GachaMonData.updateAndSaveGachaMon()` to properly make saved changes to GachaMons
	---@param keepBit number
	---@return boolean dataChanged
	setKeep = function(self, keepBit)
		local dataChanged = self:getKeep() ~= keepBit
		self.C_MoveIdsGameVersionKeep = Utils.getbits(self.C_MoveIdsGameVersionKeep, 0, 39) + Utils.bit_lshift(keepBit, 39)
		if dataChanged then
			-- TODO: re-save recent mon collection
			self.Temp.Card = nil -- requires rebuilding
		end
		return dataChanged
	end,

	---@return string
	getName = function(self)
		local pokemonInternal = PokemonData.Pokemon[self.PokemonId or false] or PokemonData.BlankPokemon
		return pokemonInternal.name
	end,
	---@return table moveIds
	getStats = function(self)
		if not self.Temp.Stats then
			self.Temp.Stats = {
				hp = Utils.getbits(self.C_StatsHpAtkDef, 0, 10),
				atk = Utils.getbits(self.C_StatsHpAtkDef, 10, 10),
				def = Utils.getbits(self.C_StatsHpAtkDef, 20, 10),
				spa = Utils.getbits(self.C_StatsSpaSpdSpe, 0, 10),
				spd = Utils.getbits(self.C_StatsSpaSpdSpe, 10, 10),
				spe = Utils.getbits(self.C_StatsSpaSpdSpe, 20, 10),
			}
		end
		return self.Temp.Stats
	end,
	---@return number
	getStars = function(self)
		if not self.Temp.Stars then
			self.Temp.Stars = GachaMonData.calculateStars(self)
		end
		return self.Temp.Stars or 0
	end,
	---@return number keep 1 = keep in collection; 0 = don't keep
	getKeep = function(self)
		return Utils.getbits(self.C_MoveIdsGameVersionKeep, 39, 1)
	end,
	---@return string
	getGameVersion = function(self)
		local versionNum = Utils.getbits(self.C_MoveIdsGameVersionKeep, 36, 3)
		return GameSettings.numberToGameVersion(versionNum)
	end,
	---@return table moveIds
	getMoveIds = function(self)
		if not self.Temp.MoveIds then
			self.Temp.MoveIds = {
				Utils.getbits(self.C_MoveIdsGameVersionKeep, 0, 9),
				Utils.getbits(self.C_MoveIdsGameVersionKeep, 9, 9),
				Utils.getbits(self.C_MoveIdsGameVersionKeep, 18, 9),
				Utils.getbits(self.C_MoveIdsGameVersionKeep, 27, 9),
			}
		end
		return self.Temp.MoveIds
	end,
	---@return number isShiny 1 = shiny; 0 = not shiny
	getIsShiny = function(self)
		return Utils.getbits(self.C_ShinyGenderNature, 0, 1)
	end,
	---@return number
	getGender = function(self)
		return Utils.getbits(self.C_ShinyGenderNature, 1, 2)
	end,
	---@return number
	getNature = function(self)
		return Utils.getbits(self.C_ShinyGenderNature, 3, 5)
	end,
	---@return table datetable { year=#, month=#, day=# }
	getDateObtainedTable = function(self)
		return {
			day = Utils.getbits(self.C_DateObtained, 0, 5),
			month = Utils.getbits(self.C_DateObtained, 5, 4),
			year = 2000 + Utils.getbits(self.C_DateObtained, 9, 7),
		}
	end,
}
---Creates and returns a new IGachaMon object
---@param o? table Optional initial object table
---@return IGachaMon profile An IGachaMon object
function GachaMonData.IGachaMon:new(o)
	o = o or {}
	o.Version = o.Version or 0
	o.Personality = o.Personality or 0
	o.PokemonId = o.PokemonId or 0
	o.Level = o.Level or 0
	o.AbilityId = o.AbilityId or 0
	o.RatingScore = o.RatingScore or 0
	o.BattlePower = o.BattlePower or 0
	o.Favorite = o.Favorite or 0
	o.SeedNumber = o.SeedNumber or 0
	o.C_StatsHpAtkDef = o.C_StatsHpAtkDef or 0
	o.C_StatsSpaSpdSpe = o.C_StatsSpaSpdSpe or 0
	o.C_MoveIdsGameVersionKeep = o.C_MoveIdsGameVersionKeep or 0
	o.C_ShinyGenderNature = o.C_ShinyGenderNature or 0
	o.C_DateObtained = o.C_DateObtained or 0
	o.Temp = o.Temp or {}
	setmetatable(o, self)
	self.__index = self
	return o
end


-- A historical record of ALL binary data readers/writers and their storage size, such that any stream of binary data can be transformed into a GachaMon object
-- When adding new versions, don't use function shortcuts for binary/data conversion. Each must be written out per-version.
GachaMonData.FileStorage.BinaryStreams = {}

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
		if gachamon:getKeep() == 1 then
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
	filepath = filepath or GachaMonData.FileStorage.getCollectionFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return
	end

	-- Import any existing data
	GachaMonData.Collection = GachaMonData.FileStorage.getCollectionFromFile(filepath)
	GachaMonData.Collection.isLoadedFromFile = true
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

---Called when the Overlay or Tracker closes and, if applicable, saves the collection to file.
---@param collection? table
---@param filepathOverride? string
---@return boolean success
function GachaMonData.FileStorage.trySaveCollectionOnClose(collection, filepathOverride)
	if not GachaMonData.collectionRequiresSaving then
		return false
	end
	GachaMonData.collectionRequiresSaving = false
	collection = collection or GachaMonData.Collection
	return GachaMonData.FileStorage.saveCollectionToFile(GachaMonData.Collection, filepathOverride)
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
	local version = gachamon.Version
	local BS = GachaMonData.FileStorage.BinaryStreams[version or false] or {}
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
function GachaMonData.FileStorage.binaryToMon(binaryStream, position)
	position = position or 1
	local version = StructEncoder.binaryUnpack("B", binaryStream, position)
	-- Utils.printDebug("  [binaryToMon] position: %s, version: %s", tostring(position), tostring(version))
	local BS = GachaMonData.FileStorage.BinaryStreams[version or false] or {}
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
GachaMonData.FileStorage.BinaryStreams[1] = {
	Format = "BIHBBBHIIII", -- The packing format (version # always occupies the 1st byte)
	Size = 28, -- Number of bytes per GachaMon stored
}

---@param binaryStream string compact binary stream of data
---@return IGachaMon|nil gachamon
---@return number size
GachaMonData.FileStorage.BinaryStreams[1].Reader = function(binaryStream, position)
	local BS = GachaMonData.FileStorage.BinaryStreams[1]
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
GachaMonData.FileStorage.BinaryStreams[1].Writer = function(gachamon)
	local BS = GachaMonData.FileStorage.BinaryStreams[1]
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

--[[
NAT DEX MOVE IDS AND DESCRIPTIONS
355 Disarming Voice (fairy)
	POW 40 PP 15 ACC ---
	"Deals damage and bypasses accuracy checks to always hit, unless the target is in the semi-invulnerable turn of a move such as Dig or Fly. No effect against Soundproof."
356 Draining Kiss (fairy)
	POW 50 PP 10 ACC 100
	"75% of the damage dealt is restored to the user as HP."
357 Play Rough (fairy)
	POW 90 PP 10 ACC 90
	"Deals damage and has a 10% chance of lowering the target's Attack stat by one stage."
358 Fairy Wind (fairy)
	POW 40 PP 30 ACC 100
	"Deals damage and has no secondary effect."
359 Moonblast (fairy)
	POW 95 PP 15 ACC 100
	"Deals damage and has a 30% chance of lowering the target's Special Attack stat by one stage."
360 Dazzling Gleam (fairy)
	POW 80 PP 10 ACC 100
	"Deals damage to all adjacent opponents."
]]
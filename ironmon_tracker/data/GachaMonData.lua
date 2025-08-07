GachaMonData = {
	MIN_RATING = 0, -- Prevent underflow
	MAX_RATING = 255, -- Prevent overflow
	MIN_BATTLE_POWER = 1000,
	MAX_BATTLE_POWER = 15000,
	SHINY_ODDS = 0.004695, -- 1 in 213 odds. (Pokémon Go and Pokémon Sleep use ~1/500)
	TRAINERS_TO_DEFEAT = 2, -- The number of trainers a Pokémon needs to defeat to automatically be kept in the player's permanent Collection

	-- The user's entire GachaMon collection (ordered list). Populated from file only when the user first goes to view the Collection on the Tracker
	Collection = {}, ---@type table<number, IGachaMon>

	-- Stores the GachaMons for the current gameplay session only. Table key is the sum of the Pokémon's personality value & its pokemon id
	RecentMons = {}, ---@type table<number, IGachaMon>

	-- Populated on Tracker startup from the ratings data json file
	RatingsSystem = {}, ---@type table<string, table>

	-- GachaDex tracking various stats and info about the collection status and seen mons
	DexData = {
		NumCollected = 0,
		NumSeen = 0,
		PercentageComplete = 0,
		SeenMons = {}, ---@type table<number, boolean>
	}, ---@type table<string, any>

	-- A one-time initial collection load when the Collection is first viewed
	initialCollectionLoaded = false,
	-- A one-time initial recent mons load when the game starts (player is in game, on the map)
	initialRecentMonsLoaded = false,
	-- Anytime Collection changes, flag this as true; Collection is saved to file sparingly, typically when the Overlay or Tracker closes
	collectionRequiresSaving = false,
	-- When a new GachaMon is caught/created, this will temporarily store that mon's data
	newestRecentMon = nil, ---@type IGachaMon|nil
	-- For recalculating the stars of the viewed Pokémon/GachaMon
	playerViewedMon = nil, ---@type IGachaMon|nil
	-- The initial star rating for the viewed mon (won't change); used to compare to recalculated stars
	playerViewedInitialStars = 0,
	-- If the collection contains Nat. Dex. GachaMons but the current ROM/Tracker can't display them
	requiresNatDex = false,
	-- After a game over, create a prize card from one of the defeated common trainers
	createdTrainerPrizeCard = nil,
	-- The current ruleset being used for the current game. Automatically determined after the New Run profiles are loaded.
	rulesetKey = "Standard",
	-- If the ruleset was automatically determined from the New Run profile settings (mostly used for a UI label in options tab)
	rulesetAutoDetected = false,
}

--[[
TODO LATER:
- [UI] Update filters for new stuff added, like "Game Winners" and "Trainer prize cards"
- [Battle] animation showing them fight. Text appears when move gets used. A vertical "HP bar" depletes. Battle time ~10-15 seconds
   - Perhaps draw a Kanto Gym badge/environment to battle on, and have it affect the battle.
   - Use new terrain sheet. Fight on grass or mountains unless both are flying type "Sky Battle".
   - When battle begins: reveal terrain and hide main tracker window and button clicks from it. offer a skip battle button to exit
   - fade from black to terrain by drawing black ontop of image, fade out from center using vertical lines
   - 1000 vs 4000 is a 4:1 odds
   - Don't allow battling self (check for match)
   - When importing a code, find some what to checksum to confirm the data is correct number of bytes
   - Winner message: (POKEBALL_SMALL) W I N N E R (POKEBALL_SMALL)
- [GachaDex] If dex is complete, color it or something around it "gold" or fancy looking; add a cool medal
- [Text UI] Create a basic MGBA viewing interface
- [UI] Add a special flair for a real shiny, reverse holo? (not stored, but can deduce by isshiny & < 5stars)
   - Careful, multiple shinies right now may lag game
- [UI] log file view mon, show stars if tracker notes know its last-level-seen; CLICK on stars to see the card itself
- [Card] Add Nickname; research how many bytes it takes up
- [Bug] low-prority; If still viewing a card pack opening and swap to a new mon, no new pack is created for it (might be as easy as check if recentMon ~= nil)
]]

-- For now, disable most/all GachaMon features if playing on MGBA emulator (aka. not Bizhawk)
function GachaMonData.isCompatibleWithEmulator()
	return Main.IsOnBizhawk()
end

function GachaMonData.initialize()
	-- Reset data variables
	GachaMonData.RecentMons = {}
	GachaMonData.Collection = {}
	GachaMonData.DexData = {
		NumCollected = 0,
		NumSeen = 0,
		PercentageComplete = 0,
		SeenMons = {},
	}
	GachaMonData.initialCollectionLoaded = false
	GachaMonData.initialRecentMonsLoaded = false
	GachaMonData.collectionRequiresSaving = false
	GachaMonData.requiresNatDex = false
	GachaMonData.createdTrainerPrizeCard = nil
	GachaMonData.playerViewedMon = nil
	GachaMonData.playerViewedInitialStars = 0
	GachaMonData.clearNewestMonToShow()

	-- Note: the active New Run profile will override this if set to AutoDetect
	GachaMonData.rulesetKey = Options["GachaMon Ratings Ruleset"]
	GachaMonData.rulesetAutoDetected = false

	-- Import data from files
	GachaMonFileManager.importRatingSystem()
	GachaMonFileManager.importGachaDexInfo()

	-- RecentMons are imported after Tracker notes data (and New Run profiles) are loaded, for comparing ROM hashes
	-- GachaMonFileManager.importRecentMons()
end

---Using either Pokemon data from the game or GachaMon data, looks up its associated GachaMon object
---@param pokemonOrGachamon IPokemon|IGachaMon
---@return IGachaMon|nil gachamon
---@return number pidIndex The table index used to access the GachaMon
function GachaMonData.getAssociatedRecentMon(pokemonOrGachamon)
	local personality = pokemonOrGachamon.personality or pokemonOrGachamon.Personality or 0
	local id = pokemonOrGachamon.pokemonID or pokemonOrGachamon.PokemonId or 0
	local pidIndex = personality + id
	if pidIndex > 0 then
		return GachaMonData.RecentMons[pidIndex], pidIndex
	end
	return nil, pidIndex
end

---Helper function to check if the GachaMon belongs to the RecentMons, otherwise it can be assumed it's part of the collection
---@param gachamon IGachaMon
---@return boolean isRecentMon True if belongs to the RecentMons, False if belongs to the collection (or not found)
function GachaMonData.isRecentMon(gachamon)
	local recentMon = GachaMonData.getAssociatedRecentMon(gachamon) or {}
	return (recentMon.PokemonId == gachamon.PokemonId) and (recentMon.SeedNumber == gachamon.SeedNumber)
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

---Returns true if no matching Pokémon species for this `gachamon` already exists in the collection; false if matching species found
---@param gachamon IGachaMon|nil
---@return boolean
function GachaMonData.checkIfNewCollectionSpecies(gachamon)
	if not gachamon then
		return false
	end
	-- Temp store this information if previously checked for faster lookup
	if gachamon.Temp.IsNewCollectionSpecies ~= nil then
		return gachamon.Temp.IsNewCollectionSpecies
	end

	-- Requires collection is loaded first
	GachaMonData.tryLoadCollection()

	-- Check Collection actual
	for _, mon in ipairs(GachaMonData.Collection or {}) do
		if mon.PokemonId == gachamon.PokemonId then
			return false
		end
	end
	-- Also check RecentMons flagged to be added to collection
	for _, mon in pairs(GachaMonData.RecentMons or {}) do
		if mon.PokemonId == gachamon.PokemonId and mon:getKeep() == 1 then
			return false
		end
	end

	gachamon.Temp.IsNewCollectionSpecies = true
	return gachamon.Temp.IsNewCollectionSpecies
end

---@param pokemonData IPokemon
---@return IGachaMon gachamon
function GachaMonData.convertPokemonToGachaMon(pokemonData)
	local gachamon = GachaMonData.IGachaMon:new({
		Version = GachaMonFileManager.Version,
		Personality = pokemonData.personality or 0,
		PokemonId = pokemonData.pokemonID or 0,
		Level = pokemonData.level or 0,
		SeedNumber = Main.currentSeed or 0,
		Temp = {
			Stats = {},
			MoveIds = {},
			GameVersion = GachaMonData.gameVersionToNumber(GameSettings.versioncolor),
			IsShiny = pokemonData.isShiny and 1 or 0,
			Nature = pokemonData.nature or 0,
			DateTimeObtained = os.time(),
		},
	})

	local pokemonInternal = PokemonData.getNatDexCompatible(gachamon.PokemonId)

	gachamon.AbilityId = PokemonData.getAbilityId(pokemonData.pokemonID, pokemonData.abilityNum)

	local pokemonTypes = pokemonInternal.types or {}
	gachamon.Type1 = PokemonData.TypeNameToIndexMap[pokemonTypes[1] or PokemonData.Types.UNKNOWN]
	if not gachamon.Type1 then
		gachamon.Type1 = PokemonData.TypeNameToIndexMap[PokemonData.Types.UNKNOWN]
	end
	gachamon.Type2 = PokemonData.TypeNameToIndexMap[pokemonTypes[2] or false] or gachamon.Type1

	for statKey, statValue in pairs(pokemonData.stats or {}) do
		gachamon.Temp.Stats[statKey] = statValue
	end

	for _, move in ipairs(pokemonData.moves or {}) do
		local moveInternal = MoveData.getNatDexCompatible(move.id)
		if moveInternal ~= MoveData.BlankMove then
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
	-- Always keep shinies in collection
	if gachamon.Temp.IsShiny == 1 then
		gachamon.Temp.Keep = 1
	end

	gachamon:compressStatsHpAtkDef(true)
	gachamon:compressStatsSpaSpdSpe(true)
	gachamon:compressMoveIdsGameVersionKeep(true)
	gachamon:compressShinyGenderNature(true)
	gachamon:compressDateObtained(true)

	local baseStats = pokemonInternal and pokemonInternal.baseStats or {}

	gachamon.RatingScore = GachaMonData.calculateRatingScore(gachamon, baseStats)
	gachamon.BattlePower = GachaMonData.calculateBattlePower(gachamon)
	gachamon.Temp.Stars = GachaMonData.calculateStars(gachamon)

	-- Always make 5-star or higher GachaMon's shiny
	if gachamon.Temp.IsShiny ~= 1 and gachamon.Temp.Stars >= 5 then
		gachamon.Temp.IsShiny = 1
		gachamon.Temp.Keep = 1
		gachamon:compressMoveIdsGameVersionKeep(true)
		gachamon:compressShinyGenderNature(true)
	end

	return gachamon
end

---Calculates the GachaMon's "Rating Score" based on its ability, moves, stats, and other factors
---@param gachamon IGachaMon
---@param baseStats table
---@return number rating Value between 0 and 100
function GachaMonData.calculateRatingScore(gachamon, baseStats)
	local RS = GachaMonData.RatingsSystem
	local ratingTotal = 0

	local pokemonInternal = PokemonData.getNatDexCompatible(gachamon.PokemonId)
	local pokemonTypes = pokemonInternal.types or {}

	-- RULESET
	local RulesetChanges = RS.Rulesets[GachaMonData.rulesetKey or false] or RS.Rulesets["Standard"]

	-- ABILITY
	local abilityRating = RS.Abilities[gachamon.AbilityId or 0] or 0
	-- Remove rating if banned ability, unless it qualifies for an exception
	if RulesetChanges.BannedAbilities[gachamon.AbilityId or 0] then
		local bannedAbilityException = false
		for _, bae in pairs(RulesetChanges.BannedAbilityExceptions or {}) do
			local bstOkay = pokemonInternal.bst < (bae.BSTLessThan or 0)
			local evoOkay = not bae.MustEvo or pokemonInternal.evolution ~= PokemonData.Evolutions.NONE
			local natdexOkay = not CustomCode.RomHacks.isPlayingNatDex() or bae.NatDexOnly
			if bstOkay and evoOkay and natdexOkay then
				bannedAbilityException = true
				break
			end
		end
		if not bannedAbilityException then
			abilityRating = 0
		end
	end
	-- Check if the ability helps improves the Pokémon's weakness(es)
	local typeDefensiveAbilities = AbilityData.getTypeDefensiveAbilities()
	local defensiveTypings = typeDefensiveAbilities[gachamon.AbilityId or 0]
	local hasDefensiveAbility = false
	if abilityRating > 0 and defensiveTypings then
		local pokemonDefenses = PokemonData.getEffectiveness(gachamon.PokemonId)
		-- Check if any x2 weaknesses are improved
		for _, monType in pairs(pokemonDefenses[2] or {}) do
			if not hasDefensiveAbility and defensiveTypings[monType] then
				hasDefensiveAbility = true
				break
			end
		end
		-- Check if any x4 weaknesses are improved
		for _, monType in pairs(pokemonDefenses[4] or {}) do
			if not hasDefensiveAbility and defensiveTypings[monType] then
				hasDefensiveAbility = true
				break
			end
		end
	end
	if hasDefensiveAbility then
		abilityRating = abilityRating * RS.OtherAdjustments.BonusAbilityImprovesWeakness
	end
	-- Check specific abilities generic to all rulesets
	if (gachamon.AbilityId or 0) == AbilityData.Values.SandStreamId then
		local safeSandTypes = {
			[PokemonData.Types.GROUND] = true,
			[PokemonData.Types.ROCK] = true,
			[PokemonData.Types.STEEL] = true,
		}
		if safeSandTypes[pokemonTypes[1] or false] or safeSandTypes[pokemonTypes[2] or false] then
			abilityRating = abilityRating + (RS.OtherAdjustments.BonusAbilitySandStreamSafe or 0)
		else
			abilityRating = abilityRating + (RS.OtherAdjustments.PenaltyAbilitySandStreamUnsafe or 0)
		end
	end
	if (gachamon.AbilityId or 0) == AbilityData.Values.ImmunityId then
		local unhelpfulTypes = {
			[PokemonData.Types.POISON] = true,
			[PokemonData.Types.STEEL] = true,
		}
		-- Remove points gained from Immunity (can't be poisoned)
		if unhelpfulTypes[pokemonTypes[1] or false] or unhelpfulTypes[pokemonTypes[2] or false] then
			abilityRating = abilityRating - (RS.Abilities[AbilityData.Values.ImmunityId] or 0)
		end
	end
	if (gachamon.AbilityId or 0) == AbilityData.Values.WaterVeilId then
		local unhelpfulTypes = {
			[PokemonData.Types.FIRE] = true,
		}
		-- Remove points gained from Water Veil (can't be burned)
		if unhelpfulTypes[pokemonTypes[1] or false] or unhelpfulTypes[pokemonTypes[2] or false] then
			abilityRating = abilityRating - (RS.Abilities[AbilityData.Values.WaterVeilId] or 0)
		end
	end
	if (gachamon.AbilityId or 0) == AbilityData.Values.MagmaArmorId then
		local unhelpfulTypes = {
			[PokemonData.Types.ICE] = true,
		}
		-- Remove points gained from Magma Armor (can't be frozen)
		if unhelpfulTypes[pokemonTypes[1] or false] or unhelpfulTypes[pokemonTypes[2] or false] then
			abilityRating = abilityRating - (RS.Abilities[AbilityData.Values.MagmaArmorId] or 0)
		end
	end
	if (gachamon.AbilityId or 0) == AbilityData.Values.LevitateId then
		local unhelpfulTypes = {
			[PokemonData.Types.FLYING] = true,
		}
		-- Remove points gained from Levitate (immune to ground moves)
		if unhelpfulTypes[pokemonTypes[1] or false] or unhelpfulTypes[pokemonTypes[2] or false] then
			abilityRating = abilityRating - (RS.Abilities[AbilityData.Values.LevitateId] or 0)
		end
	end
	abilityRating = math.min(abilityRating, RS.CategoryMaximums.Ability or 999)
	ratingTotal = ratingTotal + abilityRating

	local badWeatherTypes = {}
	if (gachamon.AbilityId or 0) == AbilityData.Values.DrizzleId then
		badWeatherTypes[PokemonData.Types.FIRE] = RS.OtherAdjustments.PenaltyWeatherAbilityWeakensMove
	elseif (gachamon.AbilityId or 0) == AbilityData.Values.DroughtId then
		badWeatherTypes[PokemonData.Types.WATER] = RS.OtherAdjustments.PenaltyWeatherAbilityWeakensMove
	end
	local compoundeyesBonus = nil
	if (gachamon.AbilityId or 0) == AbilityData.Values.CompoundeyesId then
		compoundeyesBonus = RS.OtherAdjustments.BonusAbilityCompoundeyesHelpsMove
	end
	local rockheadBonus = nil
	if (gachamon.AbilityId or 0) == AbilityData.Values.RockHeadId then
		rockheadBonus = RS.OtherAdjustments.BonusAbilityRockHeadHelpsMove
	end

	-- MOVES
	local anyPhysicalDamagingMoves, anySpecialDamaingMoves = false, false
	local iMoves = {}
	for i, id in ipairs(gachamon.Temp.MoveIds or {}) do
		iMoves[i] = {
			id = id,
			move = MoveData.getNatDexCompatible(id),
			ePower = MoveData.getExpectedPower(id),
			rating = RS.Moves[id] or 0,
		}
		-- Remove rating if banned move
		if RulesetChanges.BannedMoves[id or 0] then
			iMoves[i].rating = 0
		-- "Adjusted moves" for now means to reduce rating by 50%
		elseif RulesetChanges.AdjustedMoves[id or 0] then
			iMoves[i].rating = iMoves[i].rating * 0.5
		end
		if iMoves[i].rating ~= 0 then
			if iMoves[i].ePower > 0 then
				if not anyPhysicalDamagingMoves and iMoves[i].move.category == MoveData.Categories.PHYSICAL then
					anyPhysicalDamagingMoves = true
				end
				if not anySpecialDamaingMoves and iMoves[i].move.category == MoveData.Categories.SPECIAL then
					anySpecialDamaingMoves = true
				end
				local moveType = iMoves[i].move.type or PokemonData.Types.UNKNOWN
				if badWeatherTypes[moveType] then
					local badWeatherPenalty = badWeatherTypes[moveType] or 1
					iMoves[i].rating = iMoves[i].rating * badWeatherPenalty
				end
			end
			if compoundeyesBonus and not MoveData.isOHKO(id) then
				-- Check if accuracy of the move benefits from the ability
				local acc = tonumber(iMoves[i].move.accuracy or "") or 0
				if acc > 0 and acc < 100 then
					iMoves[i].rating = iMoves[i].rating * compoundeyesBonus
				end
			end
			if rockheadBonus and MoveData.isRecoil(id) then
				iMoves[i].rating = iMoves[i].rating * rockheadBonus
			end
			if Utils.isSTAB(iMoves[i].move, iMoves[i].move.type, pokemonTypes) then
				iMoves[i].rating = iMoves[i].rating * (RS.OtherAdjustments.BonusMoveIsSTAB or 1)
			end
		end
	end
	local movesRating = 0
	local penaltyRepeatedMove = RS.OtherAdjustments.PenaltyRepeatedMove or 1
	for i, iMove in pairs(iMoves) do
		-- Check for duplicate offensive move types; redundant typing coverage applies penalty to the move with the lower rating
		for _, cMove in pairs(iMoves) do
			-- If this iMoves rating is lower than compared-move, and compared-move matches type, and they both deal damage, adjust the iMove rating
			if cMove and iMove.rating < cMove.rating and cMove.move.type == iMove.move.type and cMove.id ~= iMove.id and cMove.ePower > 0 and iMove.ePower > 0 then
				iMove.rating = iMove.rating * penaltyRepeatedMove
				break
			end
		end
		movesRating = movesRating + iMove.rating
	end
	movesRating = math.min(movesRating, RS.CategoryMaximums.Moves or 999)
	ratingTotal = ratingTotal + movesRating

	-- STATS (OFFENSIVE)
	local checkPoorOffenseMin = RS.OtherAdjustments.CheckPoorOffenseMin or 1
	local penaltyNoMoveInCategory = RS.OtherAdjustments.PenaltyNoMoveInCategory or 1
	local offensiveAtk = baseStats.atk or 0
	local offensiveSpa = baseStats.spa or 0
	local offensiveRating = 0
	if offensiveAtk < checkPoorOffenseMin and offensiveSpa < checkPoorOffenseMin then
		offensiveRating = offensiveRating + (RS.OtherAdjustments.PenaltyPoorOffense or 0)
	else
		for _, ratingPair in ipairs(RS.Stats.Offensive or {}) do
			if offensiveAtk >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
				-- Full rating if it has a move that takes advantage of this stat, otherwise apply a penalty
				local movePenalty = 1
				if not anyPhysicalDamagingMoves then
					movePenalty = penaltyNoMoveInCategory
				end
				offensiveRating = offensiveRating + (ratingPair.Rating * movePenalty)
				-- Rating found, exclude from future threshold checks
				offensiveAtk = 0
			end
			if offensiveSpa >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
				-- Full rating if it has a move that takes advantage of this stat, otherwise apply a penalty
				local movePenalty = 1
				if not anySpecialDamaingMoves then
					movePenalty = penaltyNoMoveInCategory
				end
				offensiveRating = offensiveRating + (ratingPair.Rating * movePenalty)
				-- Rating found, exclude from future threshold checks
				offensiveSpa = 0
			end
		end
	end
	offensiveRating = math.min(offensiveRating, RS.CategoryMaximums.OffensiveStats or 999)
	ratingTotal = ratingTotal + offensiveRating

	-- STATS (DEFENSIVE)
	local checkPoorDefenseMin = RS.OtherAdjustments.CheckPoorDefenseMin or 1
	local penaltyPoorDefense = RS.OtherAdjustments.PenaltyPoorDefense or 0
	local hp = baseStats.hp or 0
	if hp < checkPoorDefenseMin then
		hp = penaltyPoorDefense
	end
	local def = baseStats.def or 0
	if def < checkPoorDefenseMin then
		def = penaltyPoorDefense
	end
	local spd = baseStats.spd or 0
	if spd < checkPoorDefenseMin then
		spd = penaltyPoorDefense
	end
	local defensiveStats = hp + def + spd
	local defensiveRating = 0
	for _, ratingPair in ipairs(RS.Stats.Defensive or {}) do
		if defensiveStats >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			defensiveRating = ratingPair.Rating
			break
		end
	end
	defensiveRating = math.min(defensiveRating, RS.CategoryMaximums.DefensiveStats or 999)
	ratingTotal = ratingTotal + defensiveRating

	-- STATS (SPEED)
	local speedStat = (baseStats.spe or 0)
	local speedRating = 0
	for _, ratingPair in ipairs(RS.Stats.Speed or {}) do
		if speedStat >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			speedRating = ratingPair.Rating
			break
		end
	end
	speedRating = math.min(speedRating, RS.CategoryMaximums.SpeedStats or 999)
	ratingTotal = ratingTotal + speedRating

	-- NATURE
	local natureRating = 0
	local nature = gachamon:getNature()
	local stats = gachamon:getStats()
	-- For now, only apply nature points to the best offensive stat
	local statKey = ((stats.atk or 0) > (stats.spa or 0)) and "atk" or "spa"
	local multiplier = Utils.getNatureMultiplier(statKey, nature)
	if multiplier > 1 then
		natureRating = RS.Natures.Beneficial[nature] or 0
	elseif multiplier < 1 then
		natureRating = RS.Natures.Detrimental[nature] or 0
	end
	natureRating = math.min(natureRating, RS.CategoryMaximums.Nature or 999)
	ratingTotal = ratingTotal + natureRating

	-- Round up
	ratingTotal = math.floor(ratingTotal + 0.5)

	if ratingTotal > GachaMonData.MAX_RATING then
		return GachaMonData.MAX_RATING
	elseif ratingTotal < GachaMonData.MIN_RATING then
		return GachaMonData.MIN_RATING
	else
		return ratingTotal
	end
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
	local pokemonInternal = PokemonData.getNatDexCompatible(gachamon.PokemonId)
	local totalMovePower, hasStab = 0, false
	for _, moveId in ipairs(gachamon:getMoveIds() or {}) do
		local move = MoveData.getNatDexCompatible(moveId)
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
	local statKey = ((stats.atk or 0) > (stats.spa or 0)) and "atk" or "spa"
	local multiplier = Utils.getNatureMultiplier(statKey, gachamon:getNature())
	local natureBonus = math.floor(multiplier * 10 - 10) * 1000
	power = power + natureBonus

	if power > GachaMonData.MAX_BATTLE_POWER then
		return GachaMonData.MAX_BATTLE_POWER
	elseif power < GachaMonData.MIN_BATTLE_POWER then
		return GachaMonData.MIN_BATTLE_POWER
	else
		return math.floor(power)
	end
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

---Creates a fake, random GachaMon; mostly to show what a sample card looks like
---@return IGachaMon gachamon
function GachaMonData.createRandomGachaMon()
	local gachamon = GachaMonData.IGachaMon:new({
		Version = GachaMonFileManager.Version,
		Personality = -1,
		Level = math.random(1, 100),
		AbilityId = math.random(1, AbilityData.getTotal()),
		SeedNumber = math.random(1, 29999),
		Temp = {
			Stats = {},
			MoveIds = {
				math.random(1, MoveData.getTotal()),
				math.random(1, MoveData.getTotal()),
				math.random(1, MoveData.getTotal()),
				math.random(1, MoveData.getTotal()),
			},
			GameVersion = math.random(1, 5),
			IsShiny = 0,
			Gender = math.random(1, 2),
			Nature = math.random(0, 24),
			DateTimeObtained = os.time(),
			PreventSaving = true,
		},
	})

	gachamon.PokemonId = Utils.randomPokemonID()

	local pokemonInternal = PokemonData.getNatDexCompatible(gachamon.PokemonId)
	local pokemonTypes = pokemonInternal.types or {}
	gachamon.Type1 = PokemonData.TypeNameToIndexMap[pokemonTypes[1] or PokemonData.Types.UNKNOWN]
	if not gachamon.Type1 then
		gachamon.Type1 = PokemonData.TypeNameToIndexMap[PokemonData.Types.UNKNOWN]
	end
	gachamon.Type2 = PokemonData.TypeNameToIndexMap[pokemonTypes[2] or false] or gachamon.Type1

	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES or {}) do
		gachamon.Temp.Stats[statKey] = gachamon.Level * math.random(1, 4)
	end

	gachamon:compressStatsHpAtkDef(true)
	gachamon:compressStatsSpaSpdSpe(true)
	gachamon:compressMoveIdsGameVersionKeep(true)
	gachamon:compressShinyGenderNature(true)
	gachamon:compressDateObtained(true)

	gachamon.RatingScore = math.random(1, 71)
	gachamon.Temp.Stars = GachaMonData.calculateStars(gachamon)
	gachamon.BattlePower = (gachamon.Temp.Stars + math.random(0, 3)) * 1000

	return gachamon
end

---Gets a list of all the defeated common trainers for the current game
---@return table<number, number>
function GachaMonData.getDefeatedCommonTrainers()
	-- Check through all common trainers
	local defeatedTrainers = {}
	for _, idList in pairs(TrainerData.getCommonTrainers() or {}) do
		for _, id in ipairs(idList or {}) do
			if TrackerAPI.hasDefeatedTrainer(id) then
				table.insert(defeatedTrainers, id)
			end
		end
	end
	return defeatedTrainers
end

---Create a IPokemon data from a defeated "common trainer" used for GachaMon card creation. Bias towards high BST if able
---@return IPokemon? pokemon
---@return table<string, any>? trainerInfo
function GachaMonData.createPokemonDataFromDefeatedTrainers()
	-- Check through all common trainers
	local defeatedTrainers = GachaMonData.getDefeatedCommonTrainers()
	-- Don't count first rival fight
	if #defeatedTrainers < 2 then
		return nil, nil
	end

	local _getRandomTrainer = function()
		local trainerId = defeatedTrainers[math.random(#defeatedTrainers)]
		local trainerData = Program.readTrainerGameData(trainerId)
		trainerData.party = trainerData.party or {}
		-- Sort their party by BST then level (easier to obtain legendaries/mythical this way)
		table.sort(trainerData.party, function(a, b)
			local pokemonA = PokemonData.getNatDexCompatible(a.pokemonID)
			local pokemonB = PokemonData.getNatDexCompatible(b.pokemonID)
			local bstA = tonumber(pokemonA.bst) or 0
			local bstB = tonumber(pokemonB.bst) or 0
			return bstA > bstB or (bstA == bstB and a.level > b.level)
		end)
		return trainerData
	end

	-- Get two different random defeated trainers (if able) and use the strongest Pokemon from either team
	local trainerData = _getRandomTrainer()
	local differentTrainer
	if #defeatedTrainers > 1 then
		for _ = 1, 69, 1 do -- max 69 attempts to find something different
			local t = _getRandomTrainer()
			if t.trainerId ~= trainerData.trainerId then
				differentTrainer = t
				break
			end
		end
	end
	if differentTrainer then
		local t1mon = trainerData.party[1] or {}
		local t2mon = differentTrainer.party[1] or {}
		local pokemon1 = PokemonData.getNatDexCompatible(t1mon.pokemonID)
		local pokemon2 = PokemonData.getNatDexCompatible(t2mon.pokemonID)
		local bst1 = tonumber(pokemon1.bst) or 0
		local bst2 = tonumber(pokemon2.bst) or 0
		if bst2 > bst1 then
			trainerData = differentTrainer
		end
	end

	local trainerPokemon = trainerData.party[1]
	local pokemonInternal = PokemonData.getNatDexCompatible(trainerPokemon.pokemonID)
	if pokemonInternal == PokemonData.BlankPokemon then
		return nil, nil
	end

	if #(trainerPokemon.moves or {}) < 4 then
		trainerPokemon.moves = {}
		-- Pokemon forget moves in order from 1st learned to last, so figure out current moveset by working backwards
		local learnedMoves = PokemonData.readLevelUpMoves(trainerPokemon.pokemonID) or {}
		for j = #learnedMoves, 1, -1 do
			local learnedMove = learnedMoves[j]
			if learnedMove.level <= trainerPokemon.level then
				-- Insert at the front (i=1) to add them in "reverse" or bottom-up
				table.insert(trainerPokemon.moves, 1, learnedMove.id)
				if #trainerPokemon.moves >= 4 then
					break
				end
			end
		end
	end

	local _estimateStat = function(statKey)
		local level = trainerPokemon.level
		local baseStat = pokemonInternal.baseStats[statKey]
		local ivs = trainerPokemon.ivs
		local additional = statKey == "hp" and (10 + level) or 5
		return math.floor(((ivs + 2 * baseStat) * level / 100) + additional + 0.5)
	end

	-- Build the Pokemon object from all the trainer data
	local pokemonData = Program.DefaultPokemon:new({
		pokemonID = trainerPokemon.pokemonID,
		personality = trainerData.trainerId, -- I don't think these pokemon have personality values that make sense anyway?
		nature = math.random(0, 4) * 6, -- TODO: for now, pick a random neutral nature; don't know how to retreive
		level = trainerPokemon.level,
		abilityNum = 0, -- trainers always use the 1st ability in ironmon
		gender = -1, -- TODO: don't know how to retreive this accurately for a trainer
		stats = {
			hp = _estimateStat("hp"),
			atk = _estimateStat("atk"),
			def = _estimateStat("def"),
			spa = _estimateStat("spa"),
			spd = _estimateStat("spd"),
			spe = _estimateStat("spe"),
		},
		moves = {
			{ id = trainerPokemon.moves[1] or 0 },
			{ id = trainerPokemon.moves[2] or 0 },
			{ id = trainerPokemon.moves[3] or 0 },
			{ id = trainerPokemon.moves[4] or 0 },
		},
	})

	-- Trainer Name & Route Info
	local trainerInternal = TrainerData.getTrainerInfo(trainerData.trainerId)
	local trainerName = trainerData.trainerName
	local trainerClass = trainerData.trainerClass
	if Utils.isNilOrEmpty(trainerName) then
		trainerName = string.rep(Constants.HIDDEN_INFO, 3)
	end
	if Utils.isNilOrEmpty(trainerClass) then
		trainerClass = string.rep(Constants.HIDDEN_INFO, 3)
	end
	trainerData.combinedName = Utils.formatSpecialCharacters(string.format("%s %s", trainerClass, trainerName))
	trainerData.combinedName = Utils.shortenText(trainerData.combinedName, 99, true)
	if trainerInternal.routeId and RouteData.hasRoute(trainerInternal.routeId) then
		trainerData.routeName = RouteData.Info[trainerInternal.routeId].name or Constants.BLANKLINE
	else
		trainerData.routeName = string.rep(Constants.HIDDEN_INFO, 3)
	end
	local trainerImage = TrainerData.getPortraitIcon(trainerInternal.class)

	local trainerInfo = {
		name = trainerData.combinedName,
		routeName = trainerData.routeName,
		image = trainerImage
	}

	return pokemonData, trainerInfo
end

---Transforms the GachaMon data into a shareable base-64 string. Example: AeAANkgYMEQkm38tWQAaAEYBKwE=
---@param gachamon? IGachaMon
---@return string b64string
function GachaMonData.getShareablyCode(gachamon)
	if not gachamon then
		return ""
	end
	local binaryStream = GachaMonFileManager.monToBinary(gachamon)
	local b64string = StructEncoder.encodeBase64(binaryStream or "")
	return b64string
end

---Transforms a base-64 string code back into them GachaMon data it represents.
---@param b64string string
---@return IGachaMon|nil gachamon
function GachaMonData.transformCodeIntoGachaMon(b64string)
	if Utils.isNilOrEmpty(b64string) then
		return nil
	end
	local binaryStream = StructEncoder.decodeBase64(b64string)
	local gachamon = GachaMonFileManager.binaryToMon(binaryStream or "")
	return gachamon
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

---Converts a `gameversion` string (i.e. "FireRed") to a number (i.e. 3) for data storage
---@param gameversion string
---@return number
function GachaMonData.gameVersionToNumber(gameversion)
	local v = { ["Ruby"] = 1, ["Emerald"] = 2, ["FireRed"] = 3, ["Sapphire"] = 4, ["LeafGreen"] = 5 }
	return v[gameversion or false] or 0
end

---Converts a number (i.e. 3) that represents the game version back to its string (i.e. "FireRed")
---@param num number
---@return string
function GachaMonData.numberToGameVersion(num)
	local v = { "Ruby", "Emerald", "FireRed", "Sapphire", "LeafGreen" }
	return v[num or false] or Constants.HIDDEN_INFO
end

function GachaMonData.updateMainScreenViewedGachaMon()
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end

	local viewedPokemon = Battle.getViewedPokemon(true)
	if not viewedPokemon then
		GachaMonData.playerViewedMon = nil
		GachaMonData.playerViewedInitialStars = 0
		return
	end

	local prevMon = GachaMonData.playerViewedMon
	-- If new or different mon or different level, recalc
	local needsRecalculating = not prevMon or (prevMon.PokemonId ~= viewedPokemon.pokemonID) or (prevMon.Level ~= viewedPokemon.level)
	-- Otherwise, check if it learned any new moves
	if not needsRecalculating then
		local prevMoveIds = prevMon and prevMon:getMoveIds() or {}
		local currentMoves = viewedPokemon.moves or {}
		for i = 1, 4, 1 do
			if currentMoves[i] and currentMoves[i].id ~= prevMoveIds[i] then
				needsRecalculating = true
				break
			end
		end
	end

	if needsRecalculating then
		GachaMonData.playerViewedMon = GachaMonData.convertPokemonToGachaMon(viewedPokemon)
		-- Always reset the initial stars to original card; do this every time the mon gets rerolled (in case the mon changes)
		local recentMon = GachaMonData.getAssociatedRecentMon(GachaMonData.playerViewedMon)
		GachaMonData.playerViewedInitialStars = recentMon and recentMon:getStars() or 0
	end
end

---Automatically tries to determine the IronMON ruleset being used for the current game and remembers it. Defaults to Kaizo if no proper match
---@return string rulesetKey A table key for Constants.IronmonRulesets
function GachaMonData.autoDetermineIronmonRuleset()
	-- Ordered list for which ruleset text to check for first; e.g. check "super kaizo" before "kaizo"
	local rulesetsOrdered = {
		{ Key = "Standard", Name = Constants.IronmonRulesetNames.Standard },
		{ Key = "Ultimate", Name = Constants.IronmonRulesetNames.Ultimate },
		{ Key = "Survival", Name = Constants.IronmonRulesetNames.Survival },
		{ Key = "SuperKaizo", Name = Constants.IronmonRulesetNames.SuperKaizo },
		{ Key = "Subpar", Name = Constants.IronmonRulesetNames.Subpar },
	}
	if CustomCode.RomHacks.isPlayingNatDex() then
		table.insert(rulesetsOrdered, { Key = "Ascension1", Name = Constants.IronmonRulesetNames.Ascension1 })
		table.insert(rulesetsOrdered, { Key = "Ascension2", Name = Constants.IronmonRulesetNames.Ascension2 })
		table.insert(rulesetsOrdered, { Key = "Ascension3", Name = Constants.IronmonRulesetNames.Ascension3 })
	end
	-- Check generic "Kaizo" ruleset last
	table.insert(rulesetsOrdered, { Key = "Kaizo", Name = Constants.IronmonRulesetNames.Kaizo })

	-- Remove all spaces and underscores for simplified comparisons
	local _removeSpacesUnderscores = function(str)
		str = (str or ""):gsub(" ", "") or ""
		str = str:gsub("_", "") or ""
		return str or ""
	end

	-- First check if an exact ruleset name exists in the settings file of the New Run profile
	local rulesetKey = nil
	local profile = QuickloadScreen.getActiveProfile()
	if profile then
		local settingsName = FileManager.extractFileNameFromPath(profile.Paths.Settings or "")
		settingsName = _removeSpacesUnderscores(settingsName)
		local profileName = _removeSpacesUnderscores(profile.Name or "")
		for _, ruleset in ipairs(rulesetsOrdered) do
			local rulesetName = _removeSpacesUnderscores(ruleset.Name or "")
			-- Check the settings file used (typically the premade Tracker one), then check the profile name itself
			if Utils.containsText(settingsName, rulesetName, true) then
				rulesetKey = ruleset.Key
				break
			elseif Utils.containsText(profileName, rulesetName, true) then
				rulesetKey = ruleset.Key
				break
			end
		end
	end

	GachaMonData.rulesetKey = rulesetKey or rulesetsOrdered[1].Key
	GachaMonData.rulesetAutoDetected = true

	return GachaMonData.rulesetKey
end

---For each Pokémon in the player's party, mark their corresponding GachaMon card that a badge has been obtained
---@param badgeNumber number The badge number, must be between 1 and 8 inclusive
function GachaMonData.markTeamForGymBadgeObtained(badgeNumber)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	if badgeNumber < 1 or badgeNumber > 8 then
		return
	end
	local badgeBitToSet = Utils.bit_lshift(1, badgeNumber - 1)
	local anyChanged = false
	-- Check each Pokémon in the player's party. For the ones with GachaMon cards, update their badge data
	for i = 1, 6, 1 do
		local pokemon = TrackerAPI.getPlayerPokemon(i) or {}
		local gachamon = GachaMonData.getAssociatedRecentMon(pokemon)
		if gachamon then
			gachamon.Badges = Utils.bit_or(gachamon.Badges or 0, badgeBitToSet)
			anyChanged = true
		end
	end
	if anyChanged then
		GachaMonFileManager.saveRecentMonsToFile()
	end
end

---For each Pokémon in the player's party, mark their corresponding GachaMon card as a game winner
function GachaMonData.markTeamForGameWin()
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	local anyChanged = false
	-- Check each Pokémon in the player's party. For the ones with GachaMon cards, update their game win status
	for i = 1, 6, 1 do
		local pokemon = TrackerAPI.getPlayerPokemon(i) or {}
		local gachamon = GachaMonData.getAssociatedRecentMon(pokemon)
		if gachamon and gachamon.GameWinner ~= 1 then
			gachamon.GameWinner = 1
			anyChanged = true
		end
	end
	if anyChanged then
		GachaMonFileManager.saveRecentMonsToFile()
	end
end

---Only once the Tracker notes are loaded, check for recent GachaMon saved for this exact rom file (rom hash match)
---@param forceImportAndUse? boolean Optional, if true will import any found RecentMons from file regardless of ROM hash mismatch; default: false
function GachaMonData.tryImportMatchingRomRecentMons(forceImportAndUse)
	if GachaMonData.initialRecentMonsLoaded or not GachaMonData.isCompatibleWithEmulator()then
		return
	end

	GachaMonData.initialRecentMonsLoaded = true
	GachaMonFileManager.importRecentMons(forceImportAndUse)
end

---Only once per game, load the collection. Usually occurs when the Overlay is first opened or if a "NEW" GachaMon is captured
function GachaMonData.tryLoadCollection()
	if GachaMonData.initialCollectionLoaded or not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	GachaMonData.initialCollectionLoaded = true
	GachaMonFileManager.importCollection()
	GachaMonData.checkForNatDexRequirement()
end

---Called when a new Pokémon is viewed on the Tracker, to create a GachaMon from it
---@param pokemon IPokemon
---@param fromTrainerPrize? boolean Optional, set to true to indicate this pokemon data was generated from a trainer
---@return boolean success
function GachaMonData.tryAddToRecentMons(pokemon, fromTrainerPrize)
	if not GachaMonData.isCompatibleWithEmulator() then
		return false
	end
	local gachamon, pidIndex = GachaMonData.getAssociatedRecentMon(pokemon)
	-- Don't add if it already exists
	if not GachaMonData.initialRecentMonsLoaded or gachamon then
		return false
	end

	-- Create the GachaMon from the IPokemon data, then add it
	gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
	GachaMonData.RecentMons[pidIndex] = gachamon
	GachaMonData.newestRecentMon = gachamon

	-- Auto-add to collection if its Pokémon species hasn't been collected yet
	if Options["Add GachaMon to collection if its new"] and GachaMonData.checkIfNewCollectionSpecies(gachamon) then
		gachamon:setKeep(1)
	elseif fromTrainerPrize and Options["Add to collection if prize from trainer victory"] then
		gachamon:setKeep(1)
	end

	-- Save changes
	GachaMonFileManager.saveRecentMonsToFile()
	if not GachaMonData.DexData.SeenMons[gachamon.PokemonId] then
		GachaMonData.DexData.SeenMons[gachamon.PokemonId] = true
		GachaMonData.DexData.NumSeen = GachaMonData.DexData.NumSeen + 1
		GachaMonFileManager.saveGachaDexInfoToFile()
	end

	local shareCode = GachaMonData.getShareablyCode(gachamon)
	EventHandler.triggerEvent(EventHandler.DefaultEvents.GE_GachaMonCapture.Key, shareCode)

	return true
end

---Called when a Pokémon/GachaMon wins a trainer battle, flagging it to save in the permanent collection
---@param mon IPokemon|IGachaMon It's associated GachaMon from RecentMons will be used
---@return boolean success
function GachaMonData.tryAutoKeepInCollection(mon)
	if not GachaMonData.isCompatibleWithEmulator() then
		return false
	end
	local gachamon = GachaMonData.getAssociatedRecentMon(mon)
	if not gachamon or gachamon:getKeep() == 1 then
		return false
	end
	-- Only auto-keep the good, successful Pokémon
	gachamon.Temp.TrainersDefeated = (gachamon.Temp.TrainersDefeated or 0) + 1
	if gachamon.Temp.TrainersDefeated < GachaMonData.TRAINERS_TO_DEFEAT then
		return false
	end

	-- Flag this GachaMon as something to keep in collection
	GachaMonData.updateGachaMonAndSave(gachamon, nil, true)

	return true
end

---Only a few attributes of a GachaMon are able to be changed once created, such as marking as favorite and/or adding to collection.
---This will make those changes and save to the RecentMons file or Collection file.
---@param gachamon IGachaMon
---@param isFave? boolean
---@param isKeep? boolean
---@param isWinner? boolean
function GachaMonData.updateGachaMonAndSave(gachamon, isFave, isKeep, isWinner)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	local monHasChanged = false

	if isFave ~= nil then -- if nil, don't make changes
		local changed = gachamon:setFavorite(isFave and 1 or 0)
		monHasChanged = monHasChanged or changed
	end
	if isKeep ~= nil then -- if nil, don't make changes
		local changed = gachamon:setKeep(isKeep and 1 or 0)
		monHasChanged = monHasChanged or changed
	end
	if isWinner ~= nil then -- if nil, don't make changes
		local changed = gachamon:setGameWinner(isWinner and 1 or 0)
		monHasChanged = monHasChanged or changed
	end

	-- If data about the GachaMon has changed, save those changes to file
	if not monHasChanged then
		return
	end

	if GachaMonData.isRecentMon(gachamon) then
		GachaMonFileManager.saveRecentMonsToFile()
	elseif GachaMonData.Collection.isLoadedFromFile then -- this should always be true if editing a collection mon
		GachaMonData.collectionRequiresSaving = true
	end
end

---Tries to permanently remove a GachaMon from the Collection by first prompting the user it's okay to do so.
---@param gachamon IGachaMon
function GachaMonData.tryRemoveFromCollection(gachamon)
	if GachaMonData.isRecentMon(gachamon) then
		-- If not in collection, can't be set as favorite, so remove that as well
		GachaMonData.updateGachaMonAndSave(gachamon, false, false)
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
	local dateText = tostring(os.date("%x", os.time(gachamon:getDateObtainedTable())))
	local seedText = Utils.formatNumberWithCommas(gachamon.SeedNumber or 0)
	local versionText = gachamon:getGameVersionName()

	local form = ExternalUI.BizForms.createForm("Permanently Remove From Collection?", 450, 200)
	form:createLabel("This will permanently remove this GachaMon from your Collection:", 19, 10)
	form:createLabel(name, 90, 30)
	form:createLabel(dateText, 250, 30)
	form:createLabel(string.format("%s %s", stars, "Stars"), 90, 50)
	form:createLabel(string.format("%s: %s", "Seed", seedText), 250, 50)
	form:createLabel(string.format("%s %s", power, "Battle Power"), 90, 70)
	form:createLabel(versionText, 250, 70)
	form.Controls.labelWarning = form:createLabel("ARE YOU SURE?", 160, 100)
	ExternalUI.BizForms.setProperty(form.Controls.labelWarning, ExternalUI.BizForms.Properties.FORE_COLOR, "red")

	form:createButton("Yes, Delete Forever!", 70, 125, function()
		table.remove(GachaMonData.Collection, index)
		GachaMonData.collectionRequiresSaving = true
		if Program.currentOverlay == GachaMonOverlay and GachaMonOverlay.currentTab == GachaMonOverlay.Tabs.View then
			GachaMonOverlay.currentTab = GachaMonOverlay.Tabs.Collection
			GachaMonOverlay.buildCollectionData()
			GachaMonOverlay.refreshButtons()
			Program.redraw(true)
		end
		form:destroy()
	end, 150, 25)
	form:createButton(Resources.AllScreens.Cancel, 260, 125, function()
		form:destroy()
	end, 90, 25)
end

---In some cases, the player's collection might contain Pokémon from a Nat. Dex. game,
---but the current ROM/Tracker settigns wouldn't otherwise be able to display them.
function GachaMonData.checkForNatDexRequirement()
	if not GachaMonData.initialCollectionLoaded then
		return
	end

	local natdexExt = TrackerAPI.getExtensionSelf(CustomCode.RomHacks.ExtensionKeys.NatDex)
	if not natdexExt then
		return
	end

	-- If Nat. Dex is being used, then use its required files when necessary for GachaMon
	if CustomCode.RomHacks.isPlayingNatDex() then
		GachaMonData.requiresNatDex = true
		return
	end

	-- Otherwise, check if any of the Pokémon in the Collection are Nat. Dex. Pokémon
	for _, gachamon in ipairs(GachaMonData.Collection or {}) do
		-- Check if it's a Nat. Dex. Pokémon
		if gachamon.PokemonId > 411 then
			GachaMonData.requiresNatDex = true
			break
		end
	end
	if not GachaMonData.requiresNatDex then
		return
	end

	-- If so, add in necessary data and references
	if type(natdexExt.buildExtensionPaths) == "function" then
		-- Required for retrieving the image paths for nat dex pokemon icons
		natdexExt.buildExtensionPaths()
	end
	if type(natdexExt.addNewSprites) == "function" then
		-- Required for retrieving the image paths for nat dex pokemon icons
		natdexExt.addNewSprites()
	end
	if type(natdexExt.addResources) == "function" then
		natdexExt.addResources()
	end

	-- NOTE: Instead of adding this data in, which affects many other Tracker features, use their corresponding compatibility lookup functions
	-- PokemonData.getNatDexCompatible(pokemonID)
	-- if type(natdexExt.addNewPokemonData) == "function" then
	-- 	natdexExt.addNewPokemonData()
	-- end
	-- MoveData.getNatDexCompatible(moveId)
	-- if type(natdexExt.addNewMoves) == "function" then
	-- 	natdexExt.addNewMoves()
	-- end
end


---@class IGachaMon
GachaMonData.IGachaMon = {
	-- Total size in bytes (including version prefix): 28
	-- 1 Byte; Unchanged once created, unless the GachaMon needs to be updated (not applicable yet)
	Version = 0,
	-- 4 Bytes; the Pokémon game's "unique identifier"
	Personality = 0,
	-- 2 Bytes (11- bits)
	PokemonId = 0,
	-- 1 Byte (7- bits)
	Level = 0,
	-- 1 Byte (7 bits)
	AbilityId = 0,
	-- 1 Byte (7 bits); value rounded up
	RatingScore = 0,
	-- 0 Bytes (4- bits); stored with PokemonId as FBBBBPPP
	BattlePower = 0,
	-- 0 Bytes (1- bit); stored with PokemonId as FBBBBPPP
	Favorite = 0,
	-- 0 Bytes (1- bit); stored with Level as GLLLLLLL
	GameWinner = 0,
	-- 2 Bytes (16 bits); The seed number at the time this mon was collected
	SeedNumber = 0,
	-- 1 Byte (8 bits); which of the 8 badges this Pokémon was involved in helping acquire
	Badges = 0,
	-- 1 Byte (8 bits); the first type of the Pokémon; need to record this for Nat. Dex or random-type randomizer
	Type1 = 0,
	-- 1 Byte (8 bits); the first type of the Pokémon
	Type2 = 0,
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
	Temp = {}, ---@type table<string, any>

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

		C.Stars = self:getStars()
		C.BattlePower = self.BattlePower or 0
		C.Favorite = self.Favorite or 0
		C.IsShiny = self:getIsShiny() == 1
		C.InCollection = self:getKeep() == 1
		C.IsGameWinner = self.GameWinner == 1
		C.BelongsToTrainer = self:getAssociatedTrainerName() ~= nil
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
		C.FrameColors = {}
		-- Always try to use the first type. If the second isn't there, copy the first typing
		local type1 = PokemonData.TypeIndexMap[self.Type1] or PokemonData.Types.UNKNOWN
		local type2 = PokemonData.TypeIndexMap[self.Type2]
		C.FrameColors[1] = Constants.MoveTypeColors[type1]
		C.FrameColors[2] = Constants.MoveTypeColors[type2 or false] or C.FrameColors[1]
		return C
	end,

	-- 00DDDDDD DDDDAAAA AAAAAAHH HHHHHHHH
	compressStatsHpAtkDef = function(self, ignoreCache)
		if (ignoreCache or self.C_StatsHpAtkDef == 0) and type(self.Temp.Stats) == "table" then
			self.C_StatsHpAtkDef = (self.Temp.Stats.hp or 0) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.atk or 0), 10) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.def or 0), 20) -- 10 bits
		end
		return self.C_StatsHpAtkDef
	end,
	-- 00SSSSSS SSSSDDDD DDDDDDAA AAAAAAAA
	compressStatsSpaSpdSpe = function(self, ignoreCache)
		if (ignoreCache or self.C_StatsSpaSpdSpe == 0) and type(self.Temp.Stats) == "table" then
			self.C_StatsSpaSpdSpe = (self.Temp.Stats.spa or 0) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.spd or 0), 10) -- 10 bits
				+ Utils.bit_lshift((self.Temp.Stats.spe or 0), 20) -- 10 bits
		end
		return self.C_StatsSpaSpdSpe
	end,
	-- KVVVMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
	compressMoveIdsGameVersionKeep = function(self, ignoreCache)
		if (ignoreCache or self.C_MoveIdsGameVersionKeep == 0) and type(self.Temp.MoveIds) == "table" then
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
	compressShinyGenderNature = function(self, ignoreCache)
		if ignoreCache or self.C_ShinyGenderNature == 0 then
			self.C_ShinyGenderNature = (self.Temp.IsShiny or 0) -- 1 bit
				+ Utils.bit_lshift((self.Temp.Gender or 0), 1) -- 2 bits
				+ Utils.bit_lshift((self.Temp.Nature or 0), 3) -- 5 bits
		end
		return self.C_ShinyGenderNature
	end,
	-- YYYYYYYM MMMDDDDD
	compressDateObtained = function(self, ignoreCache)
		if ignoreCache or self.C_DateObtained == 0 then
			local dt = os.date("*t", self.Temp.DateTimeObtained or os.time())
			-- save space by assuming after year 2000
			local year = math.max(dt.year - 2000, 0)
			self.C_DateObtained = dt.day -- 5 bits
				+ Utils.bit_lshift(dt.month, 5) -- 4 bits
				+ Utils.bit_lshift(year, 9) -- 7 bits
		end
		return self.C_DateObtained
	end,

	---Use `GachaMonData.updateGachaMonAndSave()` to properly make saved changes to GachaMons
	---@param favoriteBit number
	---@return boolean dataChanged
	setFavorite = function(self, favoriteBit)
		local dataChanged = self.Favorite ~= favoriteBit
		self.Favorite = favoriteBit
		if dataChanged then
			self.Temp.Card = nil -- requires rebuilding
		end
		return dataChanged
	end,
	---Use `GachaMonData.updateGachaMonAndSave()` to properly make saved changes to GachaMons
	---@param keepBit number
	---@return boolean dataChanged
	setKeep = function(self, keepBit)
		local dataChanged = self:getKeep() ~= keepBit
		self.C_MoveIdsGameVersionKeep = Utils.getbits(self.C_MoveIdsGameVersionKeep, 0, 39) + Utils.bit_lshift(keepBit, 39)
		if dataChanged then
			self.Temp.Card = nil -- requires rebuilding
		end
		return dataChanged
	end,
	---Use `GachaMonData.updateGachaMonAndSave()` to properly make saved changes to GachaMons
	---@param winnerBit number
	---@return boolean dataChanged
	setGameWinner = function(self, winnerBit)
		local dataChanged = self.GameWinner ~= winnerBit
		self.GameWinner = (winnerBit == 1) and 1 or 0
		if dataChanged then
			self.Temp.Card = nil -- requires rebuilding
		end
		return dataChanged
	end,

	---@return string
	getName = function(self)
		local pokemonInternal = PokemonData.getNatDexCompatible(self.PokemonId)
		return pokemonInternal.name
	end,
	---@return table<string, number> stats
	getStats = function(self)
		if self.Temp.Stats == nil then
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
		if self.Temp.Stars == nil then
			self.Temp.Stars = GachaMonData.calculateStars(self)
		end
		return self.Temp.Stars or 0
	end,
	---@return number keep 1 = keep in collection; 0 = don't keep
	getKeep = function(self)
		return Utils.getbits(self.C_MoveIdsGameVersionKeep, 39, 1)
	end,
	---@return number
	getGameVersionNumber = function(self)
		if self.Temp.GameVersion == nil then
			local versionNum = Utils.getbits(self.C_MoveIdsGameVersionKeep, 36, 3)
			self.Temp.GameVersion = versionNum
		end
		return self.Temp.GameVersion
	end,
	---@return string
	getGameVersionName = function(self)
		if self.Temp.GameVersionName == nil then
			local versionNum = Utils.getbits(self.C_MoveIdsGameVersionKeep, 36, 3)
			self.Temp.GameVersionName = GachaMonData.numberToGameVersion(versionNum)
		end
		return self.Temp.GameVersionName
	end,
	---@return table<number, number> moveIds
	getMoveIds = function(self)
		if self.Temp.MoveIds == nil then
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
		if self.Temp.IsShiny == nil then
			self.Temp.IsShiny = Utils.getbits(self.C_ShinyGenderNature, 0, 1)
		end
		return self.Temp.IsShiny
	end,
	---@return number
	getGender = function(self)
		if self.Temp.Gender == nil then
			self.Temp.Gender = Utils.getbits(self.C_ShinyGenderNature, 1, 2)
		end
		return self.Temp.Gender
	end,
	---@return number
	getNature = function(self)
		if self.Temp.Nature == nil then
			self.Temp.Nature = Utils.getbits(self.C_ShinyGenderNature, 3, 5)
		end
		return self.Temp.Nature
	end,
	---@return table<string, number> datetable { year=#, month=#, day=# }
	getDateObtainedTable = function(self)
		return {
			day = Utils.getbits(self.C_DateObtained, 0, 5),
			month = Utils.getbits(self.C_DateObtained, 5, 4),
			year = 2000 + Utils.getbits(self.C_DateObtained, 9, 7),
		}
	end,
	---If this GachaMon card was received as a prize card from a trainer, it should have an associated trainer ID as part of its personality value
	---@return string|nil
	getAssociatedTrainerName = function(self)
		local trainerId = self.Personality
		local trainer = TrainerData.Trainers[trainerId or false]
		if not trainer then
			return nil
		end
		local gamenumber = self:getGameVersionNumber()
		local commonName
		for name, idList in pairs(TrainerData.getCommonTrainers(gamenumber) or {}) do
			for _, id in pairs(idList or {}) do
				if id == trainerId then
					commonName = name
					break
				end
			end
			if commonName then
				break
			end
		end
		if not commonName then
			return nil
		end
		-- Some names are multiple words, use those instead of just their first name
		if Utils.containsText(commonName, "Surge") or (Utils.containsText(commonName, "Tate") and Utils.containsText(commonName, "Liza")) then
			return commonName
		else
			return (commonName:match("(%w+).*"))
		end
	end,
}
---Creates and returns a new IGachaMon object
---@param o? table Optional initial object table
---@return IGachaMon gachamon An IGachaMon object
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
	o.GameWinner = o.GameWinner or 0
	o.SeedNumber = o.SeedNumber or 0
	o.Badges = o.Badges or 0
	o.Type1 = o.Type1 or 0
	o.Type2 = o.Type2 or 0
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
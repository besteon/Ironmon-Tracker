GachaMonData = {
	MAX_BATTLE_POWER = 15000,
	SHINY_ODDS = 0.004695, -- 1 in 213 odds. (Pokémon Go and Pokémon Sleep use ~1/500)
	TRAINERS_TO_DEFEAT = 2, -- The number of trainers a Pokémon needs to defeat to automatically be kept in the player's permanent Collection

	-- The user's entire GachaMon collection (ordered list). Populated from file only when the user first goes to view the Collection on the Tracker
	Collection = {}, ---@type table<number, IGachaMon>

	-- Stores the GachaMons for the current gameplay session only. Table key is the Pokémon's personality value
	RecentMons = {}, ---@type table<number, IGachaMon>

	-- Populated on Tracker startup from the ratings data json file
	RatingsSystem = {}, ---@type table<string, table>

	-- A one-time initial collection load when the Collection is first viewed
	initialCollectionLoad = false,
	-- Anytime Collection changes, flag this as true; Collection is saved to file sparingly, typically when the Overlay or Tracker closes
	collectionRequiresSaving = false,
	-- When a new GachaMon is caught/created, this will temporarily store that mon's data
	newestRecentMon = nil,
	-- If the collection contains Nat. Dex. GachaMons but the current ROM/Tracker can't display them
	requiresNatDex = false,
	-- The current ruleset being used for the current game. Automatically determined after the New Run profiles are loaded.
	ruleset = Constants.IronmonRulesets.Kaizo,
}

--[[
TESTING LIST
- [Test] Deleting stuff from collection
- [Test] Nat Dex capture then swap to non-nat dex
- [Test] Evo a GachaMon, does it make a new card? (it shouldnt, i think, j/k it should actually)
]]

--[[
TODO LIST
- [UI] Consider "Rainbow Stars" instead of "Platinum" for shiny
- [Ruleset] Expose option to choose which ruleset to play by ("auto" is an option)
- [Card] Add Nickname; research how many bytes it takes up
- [Card] Evos should roll a new GachaMon card. EVs are okay to use.
- [Stream Connect] Add a !gachamon command to show most recently viewed mon (name, ability, stars, BP, stats, moves, collected on)
- [Animation] Shiny has a rainbow / animated frame border
- [Animation] Battle: animation showing them fight. Text appears when move gets used. A vertical "HP bar" depletes. Battle time ~10-15 seconds
   - Perhaps draw a Kanto Gym badge/environment to battle on, and have it affect the battle.
   - 1000 vs 4000 is a 4:1 odds
- Show collection completion status somehow. The PokeDex!
   - Add a "NEW" flair to mons not in your PokeDex collection.
TODO LATER:
- [Text UI] Create a basic MGBA viewing interface
]]

function GachaMonData.initialize()
	-- Reset data variables
	GachaMonData.RecentMons = {}
	GachaMonData.Collection = {}
	GachaMonData.initialCollectionLoad = false
	GachaMonData.collectionRequiresSaving = false
	GachaMonData.requiresNatDex = false
	GachaMonData.clearNewestMonToShow()
	-- GachaMonData.ruleset = Constants.IronmonRulesets.Kaizo -- Don't actually reset this, since the New Run profile initialize is doing it instead

	-- Import universally useful data
	GachaMonFileManager.importRatingSystem()
	GachaMonFileManager.importRecentGachaMons()
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
		Version = GachaMonFileManager.Version,
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

	gachamon:compressStatsHpAtkDef()
	gachamon:compressStatsSpaSpdSpe()
	gachamon:compressMoveIdsGameVersionKeep()
	gachamon:compressShinyGenderNature()
	gachamon:compressDateObtained()

	local pokemonInternal = PokemonData.Pokemon[pokemonData.pokemonID or 0]
	local baseStats = pokemonInternal and pokemonInternal.baseStats or {}

	gachamon.RatingScore = GachaMonData.calculateRatingScore(gachamon, baseStats)
	gachamon.BattlePower = GachaMonData.calculateBattlePower(gachamon)
	gachamon.Temp.Stars = GachaMonData.calculateStars(gachamon)

	-- Always make 5-star or higher GachaMon's shiny
	if gachamon.Temp.IsShiny ~= 1 and gachamon.Temp.Stars >= 5 then
		gachamon.Temp.IsShiny = 1
		gachamon:compressShinyGenderNature()
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

	local pokemonInternal = PokemonData.Pokemon[gachamon.PokemonId or 0]

	Utils.printDebug("--- %s'S RATING | RULESET: %s ---",
		Utils.toUpperUTF8(pokemonInternal and pokemonInternal.name or "N/A"),
		Utils.toUpperUTF8(GachaMonData.ruleset or "N/A")
	)

	-- RULESET
	local RulesetChanges = RS.Rulesets[GachaMonData.ruleset] or RS.Rulesets[Constants.IronmonRulesets.Standard]

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
	ratingTotal = ratingTotal + math.min(abilityRating, RS.CategoryMaximums.Ability or 999)

	-- MOVES
	local iMoves = {}
	for i, id in ipairs(gachamon.Temp.MoveIds or {}) do
		iMoves[i] = {
			id = id,
			move = MoveData.Moves[id] or MoveData.BlankMove,
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
			if Utils.isSTAB(iMoves[i].move, iMoves[i].move.type, pokemonInternal.types) then
				iMoves[i].rating = iMoves[i].rating * 1.5
			end
		end
	end
	local movesRating = 0
	for i, iMove in pairs(iMoves) do
		local debugPenalty = false -- TODO: Remove
		-- Check for duplicate offensive move types; redundant typing coverage applies penalty to the move with the lower rating
		for _, cMove in pairs(iMoves) do
			-- If this iMoves rating is lower than compared-move, and compared-move matches type, and they both deal damage, adjust the iMove rating
			if cMove and iMove.rating < cMove.rating and cMove.move.type == iMove.move.type and cMove.id ~= iMove.id and cMove.ePower > 0 and iMove.ePower > 0 then
				iMove.rating = iMove.rating * (RS.OtherAdjustments.RepeatedMovePentalty or 1)
				debugPenalty = true
				break
			end
		end
		movesRating = movesRating + iMove.rating
		local extraInfo = string.format("%s%s%s",
			RulesetChanges.BannedMoves[iMove.id] and "(Banned) " or "",
			RulesetChanges.AdjustedMoves[iMove.id] and "(Halved) " or "",
			debugPenalty and "(Penalty: Duplicate) " or ""
		)
		Utils.printDebug("- Move %s: %s %s %s", i, iMove.move.name, iMove.rating, extraInfo)
	end
	ratingTotal = ratingTotal + math.min(movesRating, RS.CategoryMaximums.Moves or 999)

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
	ratingTotal = ratingTotal + math.min(offensiveRating, RS.CategoryMaximums.OffensiveStats or 999)
	-- Defensives Stat (HP, Def, SpDef)
	local defensiveStats = (baseStats.hp or 0) + (baseStats.def or 0) + (baseStats.spd or 0)
	local defensiveRating = 0
	for _, ratingPair in ipairs(RS.Stats.Defensive or {}) do
		if defensiveStats >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			defensiveRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + math.min(defensiveRating, RS.CategoryMaximums.DefensiveStats or 999)
	-- Speed Stat (Spe)
	local speedStat = (baseStats.spe or 0)
	local speedRating = 0
	for _, ratingPair in ipairs(RS.Stats.Speed or {}) do
		if speedStat >= (ratingPair.BaseStat or 1) and ratingPair.Rating then
			speedRating = ratingPair.Rating
			break
		end
	end
	ratingTotal = ratingTotal + math.min(speedRating, RS.CategoryMaximums.SpeedStats or 999)

	-- NATURE
	local natureRating = 0
	local nature = gachamon:getNature()
	local stats = gachamon:getStats()
	-- For now, only apply nature points to the best offensive stat
	local statKey = ((stats.atk or 0) > (stats.spa or 0)) and "atk" or "spa"
	local multiplier = Utils.getNatureMultiplier(statKey, nature)
	-- Utils.printDebug("Nature: %s, Stat: %s, Multiplier: %s", nature, statKey, multiplier)
	if multiplier > 1 then
		natureRating = RS.Natures.Beneficial[nature] or 0
	elseif multiplier < 1 then
		natureRating = RS.Natures.Detrimental[nature] or 0
	end
	ratingTotal = ratingTotal + natureRating

	Utils.printDebug("- [Subtotals] Ability: %s, Moves: %s, Offensive: %s, Defensive: %s, Speed: %s, Nature: %s",
		abilityRating, movesRating, offensiveRating, defensiveRating, speedRating, natureRating)
	Utils.printDebug("- Rating Total: %s", math.floor(ratingTotal + 0.5))

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

	Utils.printDebug("- [Battle Power] Stars: %s, Moves: %s, STAB: %s, Nature: %s, Total: %s",
		starsBonus,
		movePowerBonus,
		hasStab and 1000 or 0,
		natureBonus,
		math.min(math.floor(power), GachaMonData.MAX_BATTLE_POWER)
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

---Creates a fake, random GachaMon; mostly to show what a sample card looks like
---@return IGachaMon gachamon
function GachaMonData.createRandomGachaMon()
	local gachamon = GachaMonData.IGachaMon:new({
		Version = GachaMonFileManager.Version,
		Personality = -1,
		PokemonId = Utils.randomPokemonID(),
		Level = math.random(1, 100),
		AbilityId = math.random(1, #AbilityData.Abilities),
		SeedNumber = math.random(1, 29999),
		Temp = {
			Stats = {},
			MoveIds = {
				math.random(1, #MoveData.Moves),
				math.random(1, #MoveData.Moves),
				math.random(1, #MoveData.Moves),
				math.random(1, #MoveData.Moves),
			},
			GameVersion = math.random(1, 5),
			IsShiny = 0,
			Gender = math.random(1, 2),
			Nature = math.random(0, 24),
			DateTimeObtained = os.time(),
		},
	})

	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES or {}) do
		gachamon.Temp.Stats[statKey] = gachamon.Level * math.random(1, 4)
	end

	gachamon:compressStatsHpAtkDef()
	gachamon:compressStatsSpaSpdSpe()
	gachamon:compressMoveIdsGameVersionKeep()
	gachamon:compressShinyGenderNature()
	gachamon:compressDateObtained()

	gachamon.RatingScore = math.random(1, 71)
	gachamon.Temp.Stars = GachaMonData.calculateStars(gachamon)
	gachamon.BattlePower = (gachamon.Temp.Stars + math.random(0, 3)) * 1000

	return gachamon
end

---Transforms the GachaMon data into a shareable base-64 string. Example: AeAANkgYMEQkm38tWQAaAEYBKwE=
---@param gachamon IGachaMon
---@return string b64string
function GachaMonData.getShareablyCode(gachamon)
	local binaryStream = GachaMonFileManager.monToBinary(gachamon)
	local b64string = StructEncoder.encodeBase64(binaryStream or "")
	return b64string
end

---Transforms a base-64 string code back into them GachaMon data it represents.
---@param b64string string
---@return IGachaMon|nil gachamon
function GachaMonData.transformCodeIntoGachaMon(b64string)
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

---Automatically tries to determine the IronMON ruleset being used for the current game and remembers it. Defaults to Kaizo if no proper match
---@return string ruleset A value from Constants.IronmonRulesets
function GachaMonData.autoDetermineIronmonRuleset()
	local ruleset = nil

	-- Ordered list for which ruleset text to check for first; e.g. check "super kaizo" before "kaizo"
	local rulesetNamesOrdered = {
		Constants.IronmonRulesets.Standard,
		Constants.IronmonRulesets.Ultimate,
		Constants.IronmonRulesets.Survival,
		Constants.IronmonRulesets.SuperKaizo,
		Constants.IronmonRulesets.Kaizo,
	}

	-- First check if an exact ruleset name exists in the settings file of the New Run profile
	local profile = QuickloadScreen.getActiveProfile()
	if not ruleset and profile then
		for _, rulesetName in ipairs(rulesetNamesOrdered) do
			-- Check the settings file used (typically the premade Tracker one), then check the profile name itself
			if Utils.containsText(profile.Paths.Settings or "", rulesetName, true) then
				ruleset = rulesetName
				break
			elseif Utils.containsText(profile.Name or "", rulesetName, true) then
				ruleset = rulesetName
				break
			end
		end
	end

	GachaMonData.ruleset = ruleset or Constants.IronmonRulesets.Kaizo
	return GachaMonData.ruleset
end

function GachaMonData.markTeamForGymBadgeObtained(badgeNumber)
	if badgeNumber < 1 or badgeNumber > 8 then
		return
	end
	local badgeBitToSet = Utils.bit_lshift(1, badgeNumber - 1)
	local anyChanged = false
	-- Check each Pokémon in the player's party. For the ones with GachaMon cards, update their badge data
	for i = 1, 6, 1 do
		local pokemon = TrackerAPI.getPlayerPokemon(i) or {}
		local gachamon = GachaMonData.RecentMons[pokemon.personality or false]
		if gachamon then
			gachamon.Badges = Utils.bit_or(gachamon.Badges or 0, badgeBitToSet)
			anyChanged = true
		end
	end
	if anyChanged then
		GachaMonFileManager.saveRecentMonsToFile()
	end
end

---Called when a new Pokémon is viewed on the Tracker, to create a GachaMon from it
---@param pokemon IPokemon
---@return boolean success
function GachaMonData.tryAddToRecentMons(pokemon)
	if GachaMonData.RecentMons[pokemon.personality] then
		return false
	end

	-- Create the GachaMon from the IPokemon data, then add it
	local gachamon = GachaMonData.convertPokemonToGachaMon(pokemon)
	GachaMonData.RecentMons[pokemon.personality] = gachamon
	GachaMonFileManager.saveRecentMonsToFile()
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
	if not GachaMonData.initialCollectionLoad or CustomCode.RomHacks.isPlayingNatDex() then
		return
	end

	-- Check if any of the Pokémon in the Collection are Nat. Dex. Pokémon
	local natdexExt = TrackerAPI.getExtensionSelf(CustomCode.RomHacks.ExtensionKeys.NatDex)
	for _, gachamon in ipairs(GachaMonData.Collection or {}) do
		-- Check if it's a Nat. Dex. Pokémon
		if gachamon.PokemonId >= 412 then
			GachaMonData.requiresNatDex = true
			break
		end
	end
	if not GachaMonData.requiresNatDex or not natdexExt then
		return
	end

	-- If so, add in necessary data and references
	if type(natdexExt.buildExtensionPaths) == "function" then
		natdexExt.buildExtensionPaths()
	end
	if type(natdexExt.addNewPokemonData) == "function" then
		natdexExt.addNewPokemonData()
	end
	if type(natdexExt.addNewMoves) == "function" then
		natdexExt.addNewMoves()
	end
	if type(natdexExt.addNewSprites) == "function" then
		natdexExt.addNewSprites()
	end
	if type(natdexExt.addResources) == "function" then
		natdexExt.addResources()
	end
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
	-- 1 Byte (7 bits)
	Level = 0,
	-- 1 Byte (7 bits)
	AbilityId = 0,
	-- 1 Byte (7 bits); value rounded up
	RatingScore = 0,
	-- 0 Bytes (4- bits); stored with PokemonId as FBBBBPPP
	BattlePower = 0,
	-- 0 Bytes (1- bit); stored with PokemonId as FBBBBPPP
	Favorite = 0,
	-- 2 Bytes (16 bits); The seed number at the time this mon was collected
	SeedNumber = 0,
	-- 1 Byte (8 bits); which of the 8 badges this Pokémon was involved in helping acquire
	Badges = 0,
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
		local pokemonInternal = PokemonData.Pokemon[self.PokemonId or false] or PokemonData.BlankPokemon

		C.Stars = self:getStars()
		C.BattlePower = self.BattlePower or 0
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

	---Use `GachaMonData.updateGachaMonAndSave()` to properly make saved changes to GachaMons
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
	---Use `GachaMonData.updateGachaMonAndSave()` to properly make saved changes to GachaMons
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
	---@return table stats
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
			self.Temp.GameVersionName = GameSettings.numberToGameVersion(versionNum)
		end
		return self.Temp.GameVersionName
	end,
	---@return table moveIds
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
	o.SeedNumber = o.SeedNumber or 0
	o.Badges = o.Badges or 0
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
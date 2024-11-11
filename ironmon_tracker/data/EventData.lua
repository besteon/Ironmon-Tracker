EventData = {}

-- Used to record information about the current game state with relation to triggering game events
EventData.Vars = {}

function EventData.initialize()
	EventData.Vars = {}
end

-- Internal helper functions

-- The max # of items to show for any commands that output a list of items (try keep chat message output short)
local MAX_ITEMS = 12
local OUTPUT_CHAR = ">"
local DEFAULT_OUTPUT_MSG = "No info found."

---Returns a response message by combining information into a single string
---@param prefix string? [Optional] Prefixes the response with this header as "HEADER RESPONSE"
---@param infoList table|string? [Optional] A string or list of strings to combine
---@param infoDelimeter string? [Optional] Defaults to " | "
---@return string response Example: "Prefix Info Item 1 | Info Item 2 | Info Item 3"
local function buildResponse(prefix, infoList, infoDelimeter)
	prefix = not Utils.isNilOrEmpty(prefix) and (prefix .. " ") or ""
	if not infoList or #infoList == 0 then
		return prefix .. DEFAULT_OUTPUT_MSG
	elseif type(infoList) ~= "table" then
		return prefix .. tostring(infoList)
	else
		return prefix .. table.concat(infoList, infoDelimeter or " | ")
	end
end
local function buildDefaultResponse(input)
	if not Utils.isNilOrEmpty(input, true) then
		return buildResponse()
	else
		return buildResponse(string.format("%s %s", input, OUTPUT_CHAR))
	end
end

local function getPokemonOrDefault(input)
	local id
	if not Utils.isNilOrEmpty(input, true) then
		id = DataHelper.findPokemonId(input)
	else
		local pokemon = Tracker.getPokemon(1, true) or {}
		id = pokemon.pokemonID
	end
	return PokemonData.Pokemon[id or false]
end
local function getMoveOrDefault(input)
	if not Utils.isNilOrEmpty(input, true) then
		return MoveData.Moves[DataHelper.findMoveId(input) or false]
	else
		return nil
	end
end
local function getAbilityOrDefault(input)
	local id
	if not Utils.isNilOrEmpty(input, true) then
		id = DataHelper.findAbilityId(input)
	else
		local pokemon = Tracker.getPokemon(1, true) or {}
		if PokemonData.isValid(pokemon.pokemonID) then
			id = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
		end
	end
	return AbilityData.Abilities[id or false]
end
local function getRouteIdOrDefault(input)
	if not Utils.isNilOrEmpty(input, true) then
		local id = DataHelper.findRouteId(input)
		-- Special check for Route 21 North/South in FRLG
		if not RouteData.Info[id or false] and Utils.containsText(input, "21") then
			-- Okay to default to something in route 21
			return (Utils.containsText(input, "north") and 109) or 219
		else
			return id
		end
	else
		return TrackerAPI.getMapId()
	end
end

-- Event Request calculation and lookup functions

---@param params string?
---@return string response
function EventData.getPokemon(params)
	local pokemon = getPokemonOrDefault(params)
	if not pokemon then
		return buildDefaultResponse(params)
	end

	local info = {}
	local types
	if pokemon.types[2] ~= PokemonData.Types.EMPTY and pokemon.types[2] ~= pokemon.types[1] then
		types = Utils.formatUTF8("%s/%s", PokemonData.getTypeResource(pokemon.types[1]), PokemonData.getTypeResource(pokemon.types[2]))
	else
		types = PokemonData.getTypeResource(pokemon.types[1])
	end
	local coreInfo = string.format("%s #%03d (%s) %s: %s",
		pokemon.name,
		pokemon.pokemonID,
		types,
		Resources.TrackerScreen.StatBST,
		pokemon.bst
	)
	table.insert(info, coreInfo)
	local evos = table.concat(Utils.getDetailedEvolutionsInfo(pokemon.evolution), ", ")
	table.insert(info, string.format("%s: %s", Resources.InfoScreen.LabelEvolution, evos))
	local moves
	if #pokemon.movelvls[GameSettings.versiongroup] > 0 then
		moves = table.concat(pokemon.movelvls[GameSettings.versiongroup], ", ")
	else
		moves = "None."
	end
	table.insert(info, string.format("%s. %s: %s", Resources.TrackerScreen.LevelAbbreviation, Resources.TrackerScreen.HeaderMoves, moves))
	local trackedPokemon = Tracker.Data.allPokemon[pokemon.pokemonID] or {}
	if (trackedPokemon.eT or 0) > 0 then
		table.insert(info, string.format("%s: %s", Resources.TrackerScreen.BattleSeenOnTrainers, trackedPokemon.eT))
	end
	if (trackedPokemon.eW or 0) > 0 then
		table.insert(info, string.format("%s: %s", Resources.TrackerScreen.BattleSeenInTheWild, trackedPokemon.eW))
	end
	return buildResponse(OUTPUT_CHAR, info)
end

---@param params string?
---@return string response
function EventData.getBST(params)
	local pokemon = getPokemonOrDefault(params)
	if not pokemon then
		return buildDefaultResponse(params)
	end

	local info = {}
	table.insert(info, string.format("%s: %s", Resources.TrackerScreen.StatBST, pokemon.bst))
	local prefix = string.format("%s %s", pokemon.name, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getWeak(params)
	local pokemon = getPokemonOrDefault(params)
	if not pokemon then
		return buildDefaultResponse(params)
	end

	local info = {}
	local pokemonDefenses = PokemonData.getEffectiveness(pokemon.pokemonID)
	local weak4x = Utils.firstToUpperEachWord(table.concat(pokemonDefenses[4] or {}, ", "))
	if not Utils.isNilOrEmpty(weak4x) then
		table.insert(info, string.format("[4x] %s", weak4x))
	end
	local weak2x = Utils.firstToUpperEachWord(table.concat(pokemonDefenses[2] or {}, ", "))
	if not Utils.isNilOrEmpty(weak2x) then
		table.insert(info, string.format("[2x] %s", weak2x))
	end
	local weak05x = Utils.firstToUpperEachWord(table.concat(pokemonDefenses[0.5] or {}, ", "))
	if not Utils.isNilOrEmpty(weak05x) then
		table.insert(info, string.format("[x0.5] %s", weak05x))
	end
	local weak025x = Utils.firstToUpperEachWord(table.concat(pokemonDefenses[0.25] or {}, ", "))
	if not Utils.isNilOrEmpty(weak025x) then
		table.insert(info, string.format("[x0.25] %s", weak025x))
	end
	local weak0x = Utils.firstToUpperEachWord(table.concat(pokemonDefenses[0] or {}, ", "))
	if not Utils.isNilOrEmpty(weak0x) then
		table.insert(info, string.format("[x0] %s", weak0x))
	end
	local types
	if pokemon.types[2] ~= PokemonData.Types.EMPTY and pokemon.types[2] ~= pokemon.types[1] then
		types = Utils.formatUTF8("%s/%s", PokemonData.getTypeResource(pokemon.types[1]), PokemonData.getTypeResource(pokemon.types[2]))
	else
		types = PokemonData.getTypeResource(pokemon.types[1])
	end

	if #info == 0 then
		table.insert(info, Resources.InfoScreen.LabelNoWeaknesses)
	end

	local prefix = string.format("%s (%s) %s %s", pokemon.name, types, Resources.TypeDefensesScreen.Weaknesses, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getMove(params)
	local move = getMoveOrDefault(params)
	if not move then
		return buildDefaultResponse(params)
	end

	local info = {}
	table.insert(info, string.format("%s: %s",
		Resources.InfoScreen.LabelContact,
		move.iscontact and Resources.AllScreens.Yes or Resources.AllScreens.No))
	table.insert(info, string.format("%s: %s", Resources.InfoScreen.LabelPP, move.pp or Constants.BLANKLINE))
	table.insert(info, string.format("%s: %s", Resources.InfoScreen.LabelPower, move.power or Constants.BLANKLINE))
	table.insert(info, string.format("%s: %s", Resources.TrackerScreen.HeaderAcc, move.accuracy or Constants.BLANKLINE))
	table.insert(info, string.format("%s: %s", Resources.InfoScreen.LabelMoveSummary, move.summary))
	local prefix = string.format("%s (%s, %s) %s",
		move.name,
		Utils.firstToUpperEachWord(move.type),
		Utils.firstToUpperEachWord(move.category),
		OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getAbility(params)
	local ability = getAbilityOrDefault(params)
	if not ability then
		return buildDefaultResponse(params)
	end

	local info = {}
	table.insert(info, string.format("%s: %s", ability.name, ability.description))
	-- Emerald only
	if GameSettings.game == 2 and ability.descriptionEmerald then
		table.insert(info, string.format("%s: %s", Resources.InfoScreen.LabelEmeraldAbility, ability.descriptionEmerald))
	end
	return buildResponse(OUTPUT_CHAR, info)
end

---@param params string?
---@return string response
function EventData.getRoute(params)
	-- Check for optional parameters
	local paramsLower = Utils.toLowerUTF8(params or "")
	local option
	for key, val in pairs(RouteData.EncounterArea or {}) do
		if Utils.containsText(paramsLower, val, true) then
			paramsLower = Utils.replaceText(paramsLower, Utils.toLowerUTF8(val), "", true)
			option = key
			break
		end
	end
	-- If option keywords were removed, trim any whitespace
	if option then
		-- Removes duplicate, consecutive whitespaces, and leading/trailer whitespaces
		paramsLower = ((paramsLower:gsub("(%s)%s+", "%1")):gsub("^%s*(.-)%s*$", "%1"))
	end

	local routeId = getRouteIdOrDefault(paramsLower)
	local route = RouteData.Info[routeId or false]
	if not route then
		return buildDefaultResponse(params)
	end

	local info = {}
	-- Check for trainers in the route, but only if a specific encounter area wasnt requested
	if not option and route.trainers and #route.trainers > 0 then
		local defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByLocation(routeId)
		table.insert(info, string.format("%s: %s/%s", "Trainers defeated", #defeatedTrainers, totalTrainers))
	end
	-- Check for wilds in the route
	local encounterArea
	if option then
		encounterArea = RouteData.EncounterArea[option] or RouteData.EncounterArea.LAND
	else
		-- Default to the first area type (usually Walking)
		encounterArea = RouteData.getNextAvailableEncounterArea(routeId, RouteData.EncounterArea.TRAINER)
	end
	local wildIds = RouteData.getEncounterAreaPokemon(routeId, encounterArea)
	if #wildIds > 0 then
		local seenIds = Tracker.getRouteEncounters(routeId, encounterArea or RouteData.EncounterArea.LAND)
		local pokemonNames = {}
		for _, pokemonId in ipairs(seenIds) do
			if PokemonData.isValid(pokemonId) then
				table.insert(pokemonNames, PokemonData.Pokemon[pokemonId].name)
			end
		end
		local wildsText = string.format("%s: %s/%s", "Wild Pokémon seen", #seenIds, #wildIds)
		if #seenIds > 0 then
			wildsText = wildsText .. string.format(" (%s)", table.concat(pokemonNames, ", "))
		end
		table.insert(info, wildsText)
	end

	local prefix
	if option then
		prefix = string.format("%s: %s %s", route.name, Utils.firstToUpperEachWord(encounterArea), OUTPUT_CHAR)
	else
		prefix = string.format("%s %s", route.name, OUTPUT_CHAR)
	end
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getTrainer(params)
	local trainerId
	if not Utils.isNilOrEmpty(params) then
		trainerId = tonumber(params or "") or 0
		-- If param is not a number, check if it's a commonly known trainer
		if trainerId == 0 then
			local foundIds
			for trainerName, trainerIds in pairs(TrainerData.CommonTrainers or {}) do
				if Utils.containsText(trainerName, params, true) then
					foundIds = trainerIds
					break
				end
			end
			if type(foundIds) == "number" then
				trainerId = foundIds
			elseif type(foundIds) == "table" then
				for _, id in pairs(foundIds) do
					if TrainerData.shouldUseTrainer(id) then
						trainerId = id
						break
					end
				end
			end
		end
	else
		trainerId = TrackerAPI.getOpponentTrainerId()
	end
	local trainerInternal = TrainerData.getTrainerInfo(trainerId)
	if not trainerInternal or trainerInternal == TrainerData.BlankTrainer then
		return buildDefaultResponse(params)
	end

	local info = {}
	local trainerGame = Program.readTrainerGameData(trainerId)

	-- TRAINER'S TEAM, LEVELS, & IVS
	local team = {}
	local minLv, maxLv, ivTotal = 100, 0, 0
	for _, partyMon in ipairs(trainerGame.party) do
		if trainerGame.defeated then
			local monName = PokemonData.Pokemon[partyMon.pokemonID].name
			table.insert(team, string.format("%s (%s.%s)",
				monName,
				Resources.TrackerScreen.LevelAbbreviation,
				partyMon.level
			))
		else
			if partyMon.level < minLv then
				minLv = partyMon.level
			end
			if partyMon.level > maxLv then
				maxLv = partyMon.level
			end
		end
		ivTotal = ivTotal + partyMon.ivs
	end
	if trainerGame.defeated then
		table.insert(info, (#team > 0 and table.concat(team, ", ")) or Constants.BLANKLINE)
	else
		local lvRange
		if minLv == maxLv then
			lvRange = tostring(minLv)
		else
			lvRange = string.format("%s-%s", minLv, maxLv)
		end
		table.insert(info, string.format("%s Pokémon (%s.%s)",
			trainerGame.partySize,
			Resources.TrackerScreen.LevelAbbreviation,
			lvRange
		))
	end

	local avgIVs = math.max(math.floor(ivTotal / #trainerGame.party), 0) -- min of 0
	table.insert(info, string.format("%s: %s", "IVs", avgIVs))

	-- TRAINER'S AI SCRIPT
	local aiLabel
	if Utils.getbits(trainerGame.aiFlags, 2, 1) == 1 then -- AI_SCRIPT_TRY_TO_FAINT
		aiLabel = "Smart"
	elseif Utils.getbits(trainerGame.aiFlags, 1, 1) == 1 then -- AI_SCRIPT_CHECK_VIABILITY
		aiLabel = "Semi-Smart"
	elseif Utils.getbits(trainerGame.aiFlags, 0, 1) == 1 then -- AI_SCRIPT_CHECK_BAD_MOVE
		aiLabel = "Normal"
	elseif trainerGame.aiFlags == 0 then
		aiLabel = "Dumb"
	else
		aiLabel = "Complex"
	end
	table.insert(info, string.format("%s: %s", "AI Script", aiLabel))

	-- TRAINER'S ITEMS
	local itemCounts = {}
	for _, itemId in ipairs(trainerGame.items) do
		local itemName = Resources.Game.ItemNames[itemId]
		if itemName then
			itemCounts[itemId] = (itemCounts[itemId] or 0) + 1
		end
	end
	local itemNames = {}
	for itemId, count in pairs(itemCounts) do
		if count == 1 then
			table.insert(itemNames, Resources.Game.ItemNames[itemId])
		else
			table.insert(itemNames, string.format("%s %s", count, Resources.Game.ItemNames[itemId]))
		end
	end
	table.sort(itemNames, function(a,b) return a < b end) -- lazily sort alphabetically
	local items = (#itemNames > 0 and table.concat(itemNames, ", ")) or "None"
	table.insert(info, string.format("%s: %s", Resources.TrainerInfoScreen.LabelUsableItems, items))

	-- TRAINER CLASS & NAME
	local trainerName = trainerGame.trainerName
	local trainerClass = trainerGame.trainerClass
	if Utils.isNilOrEmpty(trainerName) then
		trainerName = Constants.BLANKLINE
	end
	if Utils.isNilOrEmpty(trainerClass) then
		trainerClass = Constants.BLANKLINE
	end
	local combinedName = string.format("%s %s", trainerClass, trainerName)

	-- TRAINER'S ROUTE
	local routeName
	if trainerInternal.routeId and RouteData.hasRoute(trainerInternal.routeId) then
		routeName = RouteData.Info[trainerInternal.routeId].name or Constants.BLANKLINE
	else
		routeName = string.format("%s: %s", "Route", Constants.BLANKLINE)
	end

	local prefix = string.format("%s (#%s) %s %s", combinedName, trainerId, routeName, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getDungeon(params)
	local routeId = getRouteIdOrDefault(params)
	local route = RouteData.Info[routeId or false]
	if not route then
		return buildDefaultResponse(params)
	end

	local info = {}
	-- Check for trainers in the area/route
	local defeatedTrainers, totalTrainers
	if route.area ~= nil then
		defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByCombinedArea(route.area)
	elseif route.trainers and #route.trainers > 0 then
		defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByLocation(routeId)
	end
	if defeatedTrainers and totalTrainers then
		local trainersText = string.format("%s: %s/%s", "Trainers defeated", #defeatedTrainers, totalTrainers)
		table.insert(info, trainersText)
	end
	local routeName = RouteData.getRouteOrAreaName(routeId)
	local prefix = string.format("%s %s", routeName, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getUnfoughtTrainers(params)
	local allowPartialDungeons = Utils.containsText(params, "dungeon", true)
	local excludeDoubles = Utils.containsText(params, "nodoubles", true) or Utils.containsText(params, "no doubles", true)
	local includeSevii
	if GameSettings.game == 3 then
		includeSevii = Utils.containsText(params, "sevii", true)
	else
		includeSevii = true -- to allow routes above the sevii route id for RSE
	end

	local MAX_AREAS_TO_CHECK = 9
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local trainersToExclude = TrainerData.getExcludedTrainers()
	local currentRouteId = TrackerAPI.getMapId()

	-- For a given unfought trainer, this function returns unfought trainer counts for its route/area
	local checkedIds = {}
	local function getUnfinishedRouteInfo(trainerId)
		local trainer = TrainerData.Trainers[trainerId] or {}
		local routeId = trainer.routeId or -1
		local route = RouteData.Info[routeId] or {}

		-- If sevii is excluded (default option), skip those routes and non-existent routes
		if routeId == -1 or (routeId >= 230 and not includeSevii) then
			return nil
		end
		-- Skip certain trainers, only checking unfought trainers
		if checkedIds[trainerId] or trainersToExclude[trainerId] or not TrainerData.shouldUseTrainer(trainerId) then
			return nil
		end
		-- Skip trainer if already beaten, or if doubles and the option to exclude doubles is specified
		local trainerGame = Program.readTrainerGameData(trainerId)
		if trainerGame.defeated or (excludeDoubles and trainerGame.doubleBattle) then
			return nil
		end

		-- Check area for defeated trainers and mark each trainer as checked
		local defeatedTrainers = {}
		local totalTrainers = 0
		local ifDungeonAndIncluded = true -- true for non-dungeons, otherwise gets excluded if partially completed
		if route.area and #route.area > 0 then
			defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByCombinedArea(route.area, saveBlock1Addr)
			-- Don't include dungeons that are partially completed unless the player is currently there
			if route.area.dungeon and #defeatedTrainers > 0 then
				local isThere = false
				for _, id in ipairs(route.area or {}) do
					if id == currentRouteId then
						isThere = true
						break
					end
				end
				ifDungeonAndIncluded = isThere or allowPartialDungeons
			end
			for _, areaRouteId in ipairs(route.area) do
				local areaRoute = RouteData.Info[areaRouteId] or {}
				for _, id in ipairs(areaRoute.trainers or {}) do
					checkedIds[id] = true
				end
			end
		elseif route.trainers and #route.trainers > 0 then
			defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByLocation(routeId, saveBlock1Addr)
			-- Don't include dungeons that are partially completed unless the player is currently there
			if route.dungeon and #defeatedTrainers > 0 and currentRouteId ~= routeId then
				ifDungeonAndIncluded = allowPartialDungeons
			end
			for _, id in ipairs(route.trainers) do
				checkedIds[id] = true
			end
		else
			return nil
		end

		-- Add to info if route/area has unfought trainers (not all defeated)
		if #defeatedTrainers < totalTrainers and ifDungeonAndIncluded then
			local routeName = RouteData.getRouteOrAreaName(routeId)
			return string.format("%s (%s/%s)", routeName, #defeatedTrainers, totalTrainers)
		end
	end

	local info = {}
	for _, trainerId in ipairs(TrainerData.OrderedIds or {}) do
		local routeText = getUnfinishedRouteInfo(trainerId)
		if routeText ~= nil then
			table.insert(info, routeText)
		end
		if #info >= MAX_AREAS_TO_CHECK then
			table.insert(info, "...")
			break
		end
	end
	if #info == 0 then
		local reminderText = ""
		if not allowPartialDungeons or not includeSevii then
			reminderText = ' (Use param "dungeon" and/or "sevii" to check partially completed dungeons or Sevii Islands.)'
		end
		table.insert(info, string.format("%s %s", "All available trainers have been defeated!", reminderText))
	end

	local prefix = string.format("%s %s", "Unfought Trainers", OUTPUT_CHAR)
	return buildResponse(prefix, info, ", ")
end

---@param params string?
---@return string response
function EventData.getPivots(params)
	local showSafari = RouteData.Locations.IsInSafariZone[TrackerAPI.getMapId()] or Utils.containsText(params, "safari", true)
	local MAX_MONS_PER_ROUTE = 4 -- for safari, limit # mons shown per route area

	local mapIds = RouteData.getPivotOrSafariRouteIds(showSafari)

	local info = {}
	local function safariSort(a,b) return a.lv > b.lv or (a.lv == b.lv and a.pID < b.pID) end
	for _, mapId in ipairs(mapIds) do
		-- Check for tracked wild encounters in the route
		local namesToShow = {}
		if showSafari then
			local seenIdAndLvs = Tracker.getSafariEncounters(mapId)
			table.sort(seenIdAndLvs, safariSort)
			for _, idAndLv in ipairs(seenIdAndLvs) do
				if #namesToShow < MAX_MONS_PER_ROUTE and PokemonData.isValid(idAndLv.pID) then
					local nameText = string.format("%s (%s%s)",
						PokemonData.Pokemon[idAndLv.pID].name,
						Resources.TrackerScreen.LevelAbbreviation,
						idAndLv.lv)
					table.insert(namesToShow, nameText)
				end
			end
		else
			local seenIds = Tracker.getRouteEncounters(mapId, RouteData.EncounterArea.LAND)
			for _, pokemonId in ipairs(seenIds) do
				if PokemonData.isValid(pokemonId) then
					table.insert(namesToShow, PokemonData.Pokemon[pokemonId].name)
				end
			end
		end
		if #namesToShow > 0 then
			local route = RouteData.Info[mapId or false] or {}
			local routeName = route.name or "Unknown Route"
			if showSafari then
				routeName = Utils.toUpperUTF8(Utils.replaceText(routeName, "Safari Zone ", "")) -- shorten output
			end
			table.insert(info, string.format("%s: %s", routeName, table.concat(namesToShow, ", ")))
		end
	end
	local prefix = string.format("%s %s", "Pivots", OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getRevo(params)
	local pokemonID, targetEvoId
	if not Utils.isNilOrEmpty(params) then
		pokemonID = DataHelper.findPokemonId(params)
		-- If more than one Pokémon name is provided, set the other as the target evo (i.e. "Eevee Vaporeon")
		if pokemonID == 0 then
			local s = Utils.split(params, " ", true)
			pokemonID = DataHelper.findPokemonId(s[1])
			targetEvoId = DataHelper.findPokemonId(s[2])
		end
	else
		local pokemon = Tracker.getPokemon(1, true) or {}
		pokemonID = pokemon.pokemonID
	end
	local revo = PokemonRevoData.getEvoTable(pokemonID, targetEvoId)
	if not revo then
		local pokemon = PokemonData.Pokemon[pokemonID or false] or {}
		if pokemon.evolution == PokemonData.Evolutions.NONE then
			local prefix = string.format("%s %s %s", pokemon.name, "Evos", OUTPUT_CHAR)
			return buildResponse(prefix, "Does not evolve.")
		else
			return buildDefaultResponse(pokemon.name or params)
		end
	end

	local info = {}
	local shortenPerc = function(p)
		if p < 0.01 then return "<0.01%"
		elseif p < 0.1 then return string.format("%.2f%%", p)
		else return string.format("%.1f%%", p) end
	end
	local extraMons = 0
	for _, revoInfo in ipairs(revo or {}) do
		if #info < MAX_ITEMS then
			table.insert(info, string.format("%s %s", PokemonData.Pokemon[revoInfo.id].name, shortenPerc(revoInfo.perc)))
		else
			extraMons = extraMons + 1
		end
	end
	if extraMons > 0 then
		table.insert(info, string.format("(+%s more Pokémon)", extraMons))
	end
	local prefix = string.format("%s %s %s", PokemonData.Pokemon[pokemonID].name, "Evos", OUTPUT_CHAR)
	return buildResponse(prefix, info, ", ")
end

---@param params string?
---@return string response
function EventData.getCoverage(params)
	local calcFromLead = true
	local onlyFullyEvolved = false
	local moveTypes = {}
	if not Utils.isNilOrEmpty(params) then
		params = Utils.replaceText(params or "", ",%s*", " ") -- Remove any list commas
		for _, word in ipairs(Utils.split(params, " ", true) or {}) do
			if Utils.containsText(word, "evolve", true) or Utils.containsText(word, "fully", true) then
				onlyFullyEvolved = true
			else
				local moveType = DataHelper.findPokemonType(word)
				if moveType and moveType ~= "EMPTY" then
					calcFromLead = false
					table.insert(moveTypes, PokemonData.Types[moveType] or moveType)
				end
			end
		end
	end
	if calcFromLead then
		moveTypes = CoverageCalcScreen.getPartyPokemonEffectiveMoveTypes(1) or {}
	end
	if #moveTypes == 0 then
		return buildDefaultResponse(params)
	end

	local info = {}
	local coverageData = CoverageCalcScreen.calculateCoverageTable(moveTypes, onlyFullyEvolved)
	local multipliers = {}
	for _, tab in pairs(CoverageCalcScreen.Tabs) do
		table.insert(multipliers, tab)
	end
	table.sort(multipliers, function(a,b) return a < b end)
	for _, tab in ipairs(multipliers) do
		local mons = coverageData[tab] or {}
		if #mons > 0 then
			local format = "[%0dx] %s"
			if tab == CoverageCalcScreen.Tabs.Half then
				format = "[%0.1fx] %s"
			elseif tab == CoverageCalcScreen.Tabs.Quarter then
				format = "[%0.2fx] %s"
			end
			table.insert(info, string.format(format, tab, #mons))
		end
	end

	local pokemon = Tracker.getPokemon(1, true) or {}
	local typesText = Utils.firstToUpperEachWord(table.concat(moveTypes, ", "))
	local fullyEvoText = onlyFullyEvolved and " Fully Evolved" or ""
	local prefix = string.format("%s (%s)%s %s", "Coverage", typesText, fullyEvoText, OUTPUT_CHAR)
	if calcFromLead and PokemonData.isValid(pokemon.pokemonID) then
		prefix = string.format("%s's %s", PokemonData.Pokemon[pokemon.pokemonID].name, prefix)
	end
	return buildResponse(prefix, info, ", ")
end

---@param params string?
---@return string response
function EventData.getHeals(params)
	local displayHP, displayStatus, displayPP, displayBerries
	if not Utils.isNilOrEmpty(params) then
		local paramToLower = Utils.toLowerUTF8(params)
		displayHP = Utils.containsText(paramToLower, "hp", true)
		displayPP = Utils.containsText(paramToLower, "pp", true)
		displayStatus = Utils.containsText(paramToLower, "status", true)
		displayBerries = Utils.containsText(paramToLower, "berries", true)
	end
	-- Default to showing all (except redundant berries)
	if not (displayHP or displayPP or displayStatus or displayBerries) then
		displayHP = true
		displayPP = true
		displayStatus = true
	end

	local info = {}

	local categories = {
		{
			key = "HP",
			display = function() return displayHP end,
			items = {},
			gameTable = Program.GameData.Items.HPHeals,
			dataTable = MiscData.HealingItems,
		},
		{
			key = "PP",
			display = function() return displayPP end,
			items = {},
			gameTable = Program.GameData.Items.PPHeals,
			dataTable = MiscData.PPItems,
		},
		{
			key = "Status",
			display = function() return displayStatus end,
			items = {},
			gameTable = Program.GameData.Items.StatusHeals,
			dataTable = MiscData.StatusItems,
		},
		{
			key = "Berries",
			display = function() return displayBerries end,
			items = {},
		},
	}
	local BERRIES_INDEX = 4

	-- This helps custom sort items based on their effectiveness; better ones display first
	local function getSortableItem(id, quantity)
		if not MiscData.Items[id or 0] or (quantity or 0) <= 0 then return nil end
		local item = MiscData.HealingItems[id] or MiscData.PPItems[id] or MiscData.StatusItems[id] or {}
		local text = MiscData.Items[item.id]
		if quantity > 1 then
			text = string.format("%s (%s)", text, quantity)
		end
		local value = item.amount or 0
		if item.type == MiscData.HealingType.Percentage then
			value = value + 1000
		elseif item.type == MiscData.StatusType.All then -- The really good status items
			value = value + 2
		elseif MiscData.StatusItems[id] then -- All other status items
			value = value + 1
		end
		return { id = id, text = text, value = value }
	end

	-- Filter all healing related items into different categories
	local addedIds = {} -- prevent duplicate items from appearing in the output
	local function addItemIntoCategory(id, quantity, category)
		if (id or 0) == 0 or (quantity or 0) == 0 or addedIds[id] then
			return
		end
		local itemInfo = getSortableItem(id, quantity)
		if not itemInfo then
			return
		end
		if category.display() then
			table.insert(category.items, itemInfo)
			addedIds[id] = true
		end
		if displayBerries and category.dataTable[id].pocket == MiscData.BagPocket.Berries then
			table.insert(categories[BERRIES_INDEX].items, itemInfo)
			addedIds[id] = true
		end
	end
	for _, category in ipairs(categories) do
		for id, quantity in pairs(category.gameTable or {}) do
			addItemIntoCategory(id, quantity, category)
		end
	end

	-- Sort the items in their respective categories
	local function sortFunc(a,b) return a.value > b.value or (a.value == b.value and a.id < b.id) end
	for _, category in ipairs(categories) do
		if category.display() and #category.items > 0 then
			table.sort(category.items, sortFunc)
			local t = {}
			for _, item in ipairs(category.items) do
				table.insert(t, item.text)
			end
			table.insert(info, string.format("[%s] %s", category.key, table.concat(t, ", ")))
		end
	end

	local prefix = string.format("%s %s", Resources.TrackerScreen.HealsInBag, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getTMsHMs(params)
	local info = {}
	local prefix = string.format("%s %s", "TMs", OUTPUT_CHAR)
	local canSeeTM = Options["Open Book Play Mode"]

	local singleTmLookup
	local displayGym, displayNonGym, displayHM
	if params and not Utils.isNilOrEmpty(params) then
		displayGym = Utils.containsText(params, "gym", true)
		displayHM = Utils.containsText(params, "hm", true)
		singleTmLookup = tonumber(params:match("(%d+)") or "")
	end
	-- Default to showing just tms (gym & other)
	if not displayGym and not displayHM and not singleTmLookup then
		displayGym = true
		displayNonGym = true
	end
	local tms, hms = Program.getTMsHMsBagItems()
	if singleTmLookup then
		if not canSeeTM then
			for _, item in ipairs(tms or {}) do
				local tmInBag = item.id - 289 + 1 -- 289 is the item ID of the first TM
				if singleTmLookup == tmInBag then
					canSeeTM = true
					break
				end
			end
		end
		local moveId = Program.getMoveIdFromTMHMNumber(singleTmLookup)
		local textToAdd
		if canSeeTM and MoveData.isValid(moveId) then
			textToAdd = MoveData.Moves[moveId].name
		else
			textToAdd = string.format("%s %s", Constants.BLANKLINE, "(not acquired yet)")
		end
		return buildResponse(prefix, string.format("%s %02d: %s", "TM", singleTmLookup, textToAdd))
	end
	if displayGym or displayNonGym then
		local isGymTm = {}
		for _, gymInfo in ipairs(TrainerData.GymTMs) do
			if gymInfo.number then
				isGymTm[gymInfo.number] = true
			end
		end
		local tmsObtained = {}
		local otherTMs, gymTMs = {}, {}
		for _, item in ipairs(tms or {}) do
			local tmNumber = item.id - 289 + 1 -- 289 is the item ID of the first TM
			local moveId = Program.getMoveIdFromTMHMNumber(tmNumber)
			if MoveData.isValid(moveId) then
				tmsObtained[tmNumber] = string.format("#%02d %s", tmNumber, MoveData.Moves[moveId].name)
				if not isGymTm[tmNumber] then
					table.insert(otherTMs, tmsObtained[tmNumber])
				end
			end
		end
		if displayGym then
			-- Get them sorted in Gym ordered
			for _, gymInfo in ipairs(TrainerData.GymTMs) do
				if tmsObtained[gymInfo.number] then
					table.insert(gymTMs, tmsObtained[gymInfo.number])
				elseif canSeeTM then
					local moveId = Program.getMoveIdFromTMHMNumber(gymInfo.number)
					table.insert(gymTMs, string.format("#%02d %s", gymInfo.number, MoveData.Moves[moveId].name))
				end
			end
			local textToAdd = #gymTMs > 0 and table.concat(gymTMs, ", ") or "None"
			table.insert(info, string.format("[%s] %s", "Gym", textToAdd))
		end
		if displayNonGym then
			local textToAdd
			if #otherTMs > 0 then
				local otherMax = math.min(#otherTMs, MAX_ITEMS - #gymTMs)
				textToAdd = table.concat(otherTMs, ", ", 1, otherMax)
				if #otherTMs > otherMax then
					textToAdd = string.format("%s, (+%s more TMs)", textToAdd, #otherTMs - otherMax)
				end
			else
				textToAdd = "None"
			end
			table.insert(info, string.format("[%s] %s", "Other", textToAdd))
		end
	end
	if displayHM then
		local hmTexts = {}
		for _, item in ipairs(hms or {}) do
			local hmNumber = item.id - 339 + 1 -- 339 is the item ID of the first HM
			local moveId = Program.getMoveIdFromTMHMNumber(hmNumber, true)
			if MoveData.isValid(moveId) then
				local hmText = string.format("%s (HM%02d)", MoveData.Moves[moveId].name, hmNumber)
				table.insert(hmTexts, hmText)
			end
		end
		local textToAdd = #hmTexts > 0 and table.concat(hmTexts, ", ") or "None"
		table.insert(info, string.format("%s: %s", "HMs", textToAdd))
	end
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getSearch(params)
	local helpResponse = "Search tracked info for a Pokémon, move, or ability."
	if Utils.isNilOrEmpty(params, true) then
		return buildResponse(params, helpResponse)
	end

	-- Determine if the search is for an ability, move, or pokemon
	local function determineSearchMode(input)
		local searchMode, searchId, closestDistance = nil, -1, 9999
		local tempId, tempDist = DataHelper.findAbilityId(input, 4)
		if (tempId or 0) and tempDist < closestDistance then
			searchMode = "ability"
			searchId = tempId
			closestDistance = tempDist
			if closestDistance == 0 then -- exact match
				return searchMode, searchId
			end
		end
		tempId, tempDist = DataHelper.findMoveId(input, 4)
		if (tempId or 0) and tempDist < closestDistance then
			searchMode = "move"
			searchId = tempId
			closestDistance = tempDist
			if closestDistance == 0 then -- exact match
				return searchMode, searchId
			end
		end
		tempId, tempDist = DataHelper.findPokemonId(input, 4)
		if (tempId or 0) and tempDist < closestDistance then
			searchMode = "pokemon"
			searchId = tempId
			closestDistance = tempDist
			if closestDistance == 0 then -- exact match
				return searchMode, searchId
			end
		end
		return searchMode, searchId
	end

	local searchMode, searchId = determineSearchMode(params)
	if not searchMode then
		local prefix = string.format("%s %s", params, OUTPUT_CHAR)
		return buildResponse(prefix, "Can't find a Pokémon, move, or ability with that name.")
	end

	local info = {}
	if searchMode == "pokemon" then
		local pokemon = PokemonData.Pokemon[searchId]
		if not pokemon then
			return buildDefaultResponse(params)
		end
		-- Tracked Abilities
		local trackedAbilities = {}
		for _, ability in ipairs(Tracker.getAbilities(pokemon.pokemonID) or {}) do
			if AbilityData.isValid(ability.id) then
				table.insert(trackedAbilities, AbilityData.Abilities[ability.id].name)
			end
		end
		if #trackedAbilities > 0 then
			table.insert(info, string.format("%s: %s", "Abilities", table.concat(trackedAbilities, ", ")))
		end
		-- Tracked Stat Markings
		local statMarksToAdd = {}
		local trackedStatMarkings = Tracker.getStatMarkings(pokemon.pokemonID) or {}
		for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local markVal = trackedStatMarkings[statKey]
			if markVal ~= 0 then
				local marking = Constants.STAT_STATES[markVal] or {}
				local symbol = string.sub(marking.text or " ", 1, 1) or ""
				table.insert(statMarksToAdd, string.format("%s(%s)", Utils.toUpperUTF8(statKey), symbol))
			end
		end
		if #statMarksToAdd > 0 then
			table.insert(info, string.format("%s: %s", "Stats", table.concat(statMarksToAdd, ", ")))
		end
		-- Tracked Moves
		local extra = 0
		local trackedMoves = {}
		for _, move in ipairs(Tracker.getMoves(pokemon.pokemonID) or {}) do
			if MoveData.isValid(move.id) then
				if #trackedMoves < MAX_ITEMS then
					-- { id = moveId, level = level, minLv = level, maxLv = level, },
					local lvText
					if move.minLv and move.maxLv and move.minLv ~= move.maxLv then
						lvText = string.format(" (%s.%s-%s)", Resources.TrackerScreen.LevelAbbreviation, move.minLv, move.maxLv)
					elseif move.level > 0 then
						lvText = string.format(" (%s.%s)", Resources.TrackerScreen.LevelAbbreviation, move.level)
					end
					table.insert(trackedMoves, string.format("%s%s", MoveData.Moves[move.id].name, lvText or ""))
				else
					extra = extra + 1
				end
			end
		end
		if #trackedMoves > 0 then
			table.insert(info, string.format("%s: %s", "Moves", table.concat(trackedMoves, ", ")))
			if extra > 0 then
				table.insert(info, string.format("(+%s more)", extra))
			end
		end
		-- Tracked Encounters
		local seenInWild = Tracker.getEncounters(pokemon.pokemonID, true)
		local seenOnTrainers = Tracker.getEncounters(pokemon.pokemonID, false)
		local trackedSeen = {}
		if seenInWild > 0 then
			table.insert(trackedSeen, string.format("%s in wild", seenInWild))
		end
		if seenOnTrainers > 0 then
			table.insert(trackedSeen, string.format("%s on trainers", seenOnTrainers))
		end
		if #trackedSeen > 0 then
			table.insert(info, string.format("%s: %s", "Seen", table.concat(trackedSeen, ", ")))
		end
		-- Tracked Notes
		local trackedNote = Tracker.getNote(pokemon.pokemonID)
		if #trackedNote > 0 then
			table.insert(info, string.format("%s: %s", "Note", trackedNote))
		end
		local prefix = string.format("%s %s %s", "Tracked", pokemon.name, OUTPUT_CHAR)
		return buildResponse(prefix, info)
	elseif searchMode == "move" or searchMode == "moves" then
		local move = MoveData.Moves[searchId]
		if not move then
			return buildDefaultResponse(params)
		end
		local moveId = tonumber(move.id) or 0
		local foundMons = {}
		for pokemonID, trackedPokemon in pairs(Tracker.Data.allPokemon or {}) do
			for _, trackedMove in ipairs(trackedPokemon.moves or {}) do
				if trackedMove.id == moveId and trackedMove.level > 0 then
					local lvText = tostring(trackedMove.level)
					if trackedMove.minLv and trackedMove.maxLv and trackedMove.minLv ~= trackedMove.maxLv then
						lvText = string.format("%s-%s", trackedMove.minLv, trackedMove.maxLv)
					end
					local pokemon = PokemonData.Pokemon[pokemonID]
					local notes = string.format("%s (%s.%s)", pokemon.name, Resources.TrackerScreen.LevelAbbreviation, lvText)
					table.insert(foundMons, { id = pokemonID, bst = tonumber(pokemon.bst or "0"), notes = notes})
					break
				end
			end
		end
		table.sort(foundMons, function(a,b) return a.bst > b.bst or (a.bst == b.bst and a.id < b.id) end)
		local extra = 0
		for _, mon in ipairs(foundMons) do
			if #info < MAX_ITEMS then
				table.insert(info, mon.notes)
			else
				extra = extra + 1
			end
		end
		if extra > 0 then
			table.insert(info, string.format("(+%s more Pokémon)", extra))
		end
		local prefix = string.format("%s %s %s Pokémon:", move.name, OUTPUT_CHAR, #foundMons)
		return buildResponse(prefix, info, ", ")
	elseif searchMode == "ability" or searchMode == "abilities" then
		local ability = AbilityData.Abilities[searchId]
		if not ability then
			return buildDefaultResponse(params)
		end
		local foundMons = {}
		for pokemonID, trackedPokemon in pairs(Tracker.Data.allPokemon or {}) do
			for _, trackedAbility in ipairs(trackedPokemon.abilities or {}) do
				if trackedAbility.id == ability.id then
					local pokemon = PokemonData.Pokemon[pokemonID]
					table.insert(foundMons, { id = pokemonID, bst = tonumber(pokemon.bst or "0"), notes = pokemon.name })
					break
				end
			end
		end
		table.sort(foundMons, function(a,b) return a.bst > b.bst or (a.bst == b.bst and a.id < b.id) end)
		local extra = 0
		for _, mon in ipairs(foundMons) do
			if #info < MAX_ITEMS then
				table.insert(info, mon.notes)
			else
				extra = extra + 1
			end
		end
		if extra > 0 then
			table.insert(info, string.format("(+%s more Pokémon)", extra))
		end
		local prefix = string.format("%s %s %s Pokémon:", ability.name, OUTPUT_CHAR, #foundMons)
		return buildResponse(prefix, info, ", ")
	end
	-- Unused
	local prefix = string.format("%s %s", params, OUTPUT_CHAR)
	return buildResponse(prefix, helpResponse)
end

---@param params string?
---@return string response
function EventData.getSearchNotes(params)
	if Utils.isNilOrEmpty(params, true) then
		return buildDefaultResponse(params)
	end

	local info = {}
	local foundMons = {}
	for pokemonID, trackedPokemon in pairs(Tracker.Data.allPokemon or {}) do
		if trackedPokemon.note and Utils.containsText(trackedPokemon.note, params, true) then
			local pokemon = PokemonData.Pokemon[pokemonID]
			table.insert(foundMons, { id = pokemonID, bst = tonumber(pokemon.bst or "0"), notes = pokemon.name })
		end
	end
	table.sort(foundMons, function(a,b) return a.bst > b.bst or (a.bst == b.bst and a.id < b.id) end)
	local extra = 0
	for _, mon in ipairs(foundMons) do
		if #info < MAX_ITEMS then
			table.insert(info, mon.notes)
		else
			extra = extra + 1
		end
	end
	if extra > 0 then
		table.insert(info, string.format("(+%s more Pokémon)", extra))
	end
	local prefix = string.format("%s: \"%s\" %s %s Pokémon:", "Note", params, OUTPUT_CHAR, #foundMons)
	return buildResponse(prefix, info, ", ")
end

---@param params string?
---@return string response
function EventData.getFavorites(params)
	local info = {}
	local faveButtons = {
		StreamerScreen.Buttons.PokemonFavorite1,
		StreamerScreen.Buttons.PokemonFavorite2,
		StreamerScreen.Buttons.PokemonFavorite3,
	}
	local favesList = {}
	for i, button in ipairs(faveButtons or {}) do
		local name
		if PokemonData.isValid(button.pokemonID) then
			name = PokemonData.Pokemon[button.pokemonID].name
		else
			name = Constants.BLANKLINE
		end
		table.insert(favesList, string.format("#%s %s", i, name))
	end
	if #favesList > 0 then
		table.insert(info, table.concat(favesList, ", "))
	end
	local prefix = string.format("%s %s", "Favorites", OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getTheme(params)
	local info = {}
	local themeCode = Theme.exportThemeToText()
	local themeName = Theme.getThemeNameFromCode(themeCode)
	table.insert(info, string.format("%s: %s", themeName, themeCode))
	local prefix = string.format("%s %s", "Theme", OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getGameStats(params)
	local info = {}
	for _, statPair in ipairs(StatsScreen.StatTables or {}) do
		if type(statPair.getText) == "function" and type(statPair.getValue) == "function" then
			local statValue = statPair.getValue() or 0
			if type(statValue) == "number" then
				statValue = Utils.formatNumberWithCommas(statValue)
			end
			table.insert(info, string.format("%s: %s", statPair:getText(), statValue))
		end
	end
	local prefix = string.format("%s %s", Resources.GameOptionsScreen.ButtonGameStats, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getProgress(params)
	local includeSevii = Utils.containsText(params, "sevii", true)
	local info = {}
	local badgesObtained, maxBadges = 0, 8
	for i = 1, maxBadges, 1 do
		local badgeButton = TrackerScreen.Buttons["badge" .. i] or {}
		if (badgeButton.badgeState or 0) ~= 0 then
			badgesObtained = badgesObtained + 1
		end
	end
	table.insert(info, string.format("%s: %s/%s", "Gym badges", badgesObtained, maxBadges))
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local totalDefeated, totalTrainers = 0, 0
	for mapId, route in pairs(RouteData.Info) do
		-- Don't check sevii islands (id = 230+) by default
		if mapId < 230 or includeSevii then
			if route.trainers and #route.trainers > 0 then
				local defeatedTrainers, totalInRoute = Program.getDefeatedTrainersByLocation(mapId, saveBlock1Addr)
				totalDefeated = totalDefeated + #defeatedTrainers
				totalTrainers = totalTrainers + totalInRoute
			end
		end
	end
	table.insert(info, string.format("%s%s: %s/%s (%0.1f%%)",
		"Trainers defeated",
		includeSevii and ", including Sevii" or "",
		totalDefeated,
		totalTrainers,
		totalDefeated / totalTrainers * 100))
	local fullyEvolvedSeen, fullyEvolvedTotal = 0, 0
	-- local legendarySeen, legendaryTotal = 0, 0
	for pokemonID, pokemon in ipairs(PokemonData.Pokemon) do
		if pokemon.evolution == PokemonData.Evolutions.NONE then
			fullyEvolvedTotal = fullyEvolvedTotal + 1
			local trackedPokemon = Tracker.Data.allPokemon[pokemonID] or {}
			if (trackedPokemon.eT or 0) > 0 then
				fullyEvolvedSeen = fullyEvolvedSeen + 1
			end
		end
	end
	table.insert(info, string.format("%s: %s/%s (%0.1f%%)", --, Legendary: %s/%s (%0.1f%%)",
		"Pokémon seen fully evolved",
		fullyEvolvedSeen,
		fullyEvolvedTotal,
		fullyEvolvedSeen / fullyEvolvedTotal * 100))
	local prefix = string.format("%s %s", "Progress", OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getLog(params)
	-- TODO: add "previous" as a parameter; requires storing this information somewhere
	local prefix = string.format("%s %s", "Log", OUTPUT_CHAR)
	local hasParsedThisLog = RandomizerLog.Data.Settings and string.find(RandomizerLog.loadedLogPath or "", FileManager.PostFixes.AUTORANDOMIZED, 1, true)
	if not hasParsedThisLog then
		return buildResponse(prefix, "This game's log file hasn't been opened yet.")
	end

	local info = {}
	for _, button in ipairs(Utils.getSortedList(LogTabMisc.Buttons or {})) do
		table.insert(info, string.format("%s %s", button:getText(), button:getValue()))
	end
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getBallQueue(params)
	local prefix = string.format("%s %s", "BallQueue", OUTPUT_CHAR)

	local info = {}

	local queueSize = 0
	for _, _ in pairs(EventHandler.Queues.BallRedeems.Requests or {}) do
		queueSize = queueSize + 1
	end
	if queueSize == 0 then
		return buildResponse(prefix, "The pick ball queue is empty.")
	end
	local picksInQueueMsg = string.format("ball pick%s in queue", queueSize == 1 and "" or "s")
	table.insert(info, string.format("%s %s", queueSize, picksInQueueMsg))

	local request = EventHandler.Queues.BallRedeems.ActiveRequest
	if request and request.Username then
		table.insert(info, string.format("%s: %s - %s", "Current pick", request.Username, request.SanitizedInput or "N/A"))
	end

	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getAbout(params)
	local info = {}
	table.insert(info, string.format("%s: %s", Resources.StartupScreen.Version, Main.TrackerVersion))
	table.insert(info, string.format("%s: %s", Resources.StartupScreen.Game, GameSettings.gamename))
	table.insert(info, string.format("%s: %s", Resources.StartupScreen.Attempts, Main.currentSeed or 1))
	table.insert(info, string.format("%s: v%s", "Streamerbot Code", Network.currentStreamerbotVersion or "N/A"))
	local prefix = string.format("%s %s", Resources.StartupScreen.Title, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function EventData.getHelp(params)
	local availableCommands = {}
	for _, event in pairs(EventHandler.Events or {}) do
		if event.Type == EventHandler.EventTypes.Command and event.Command and event.IsEnabled then
			availableCommands[event.Command] = event
		end
	end
	local info = {}
	if not Utils.isNilOrEmpty(params) then
		local paramsAsLower = Utils.toLowerUTF8(params)
		if paramsAsLower:sub(1, 1) ~= EventHandler.COMMAND_PREFIX then
			paramsAsLower = EventHandler.COMMAND_PREFIX .. paramsAsLower
		end
		local command = availableCommands[paramsAsLower]
		if not command or Utils.isNilOrEmpty(command.Help, true) then
			return buildDefaultResponse(params)
		end
		table.insert(info, string.format("%s %s", paramsAsLower, command.Help))
	else
		for commandWord, _ in pairs(availableCommands) do
			table.insert(info, commandWord)
		end
		table.sort(info, function(a,b) return a < b end)
	end
	local prefix
	if #info > 1 then
		prefix = string.format("%s %s", "Tracker Commands", OUTPUT_CHAR)
	else
		prefix = string.format("%s %s", "Command:", OUTPUT_CHAR)
	end
	return buildResponse(prefix, info, ", ")
end
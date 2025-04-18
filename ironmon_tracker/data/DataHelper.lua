DataHelper = {}

-- DEPRECATED: Use `EventData` instead
DataHelper.EventRequests = {}

-- Setup references for extensions that still use the deprecated table map
local mt = {}
setmetatable(DataHelper.EventRequests, mt)
mt.__index = function(_, key)
	return EventData[key]
end

---Searches for a Pokémon by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return number pokemonID
---@return number distance The Levenshtein distance between search word and matched word
function DataHelper.findPokemonId(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return PokemonData.BlankPokemon.pokemonID, -1
	end

	-- Format list of Pokemon as id, name pairs
	local pokemonNames = {}
	for id = 1, PokemonData.getTotal(), 1 do
		local pokemon = PokemonData.Pokemon[id] or PokemonData.BlankPokemon
		if (pokemon.bst ~= Constants.BLANKLINE) then
			pokemonNames[id] = Utils.toLowerUTF8(pokemon.name)
		end
	end

	local id, _, distance = Utils.getClosestWord(Utils.toLowerUTF8(name), pokemonNames, threshold)
	return id or PokemonData.BlankPokemon.pokemonID, distance
end

---Searches for a Move by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return number moveId
---@return number distance The Levenshtein distance between search word and matched word
function DataHelper.findMoveId(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return tonumber(MoveData.BlankMove.id) or 0, -1
	end

	-- Format list of Moves as id, name pairs
	local moveNames = {}
	for id = 1, MoveData.getTotal(), 1 do
		local move = MoveData.Moves[id] or MoveData.BlankMove
		moveNames[id] = Utils.toLowerUTF8(move.name)
	end

	local id, _, distance = Utils.getClosestWord(Utils.toLowerUTF8(name), moveNames, threshold)
	return id or tonumber(MoveData.BlankMove.id) or 0, distance
end

---Searches for an Ability by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return number abilityId
---@return number distance The Levenshtein distance between search word and matched word
function DataHelper.findAbilityId(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return AbilityData.DefaultAbility.id, -1
	end

	-- Format list of Abilities as id, name pairs
	local abilityNames = {}
	for id = 1, AbilityData.getTotal(), 1 do
		local ability = AbilityData.Abilities[id] or {}
		abilityNames[id] = Utils.toLowerUTF8(ability.name)
	end

	local id, _, distance = Utils.getClosestWord(Utils.toLowerUTF8(name), abilityNames, threshold)
	return id or AbilityData.DefaultAbility.id, distance
end

---Searches for a Route by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 5!
---@return number mapId
---@return number distance The Levenshtein distance between search word and matched word
function DataHelper.findRouteId(name, threshold)
	threshold = threshold or 5
	if Utils.isNilOrEmpty(name) then
		return RouteData.BlankRoute.id, -1
	end

	-- If the lookup is just a route number, allow it to be searchable
	if tonumber(name) ~= nil then
		name = string.format("route %s", name)
	end

	-- Format list of Routes as id, name pairs
	local routeNames = {}
	for id, route in pairs(RouteData.Info) do
		routeNames[id] = Utils.toLowerUTF8(route.name or "Unnamed Route")
	end

	local id, _, distance = Utils.getClosestWord(Utils.toLowerUTF8(name), routeNames, threshold)
	return id or RouteData.BlankRoute.id, distance
end

---Searches for a Pokémon Type by name, finds the best match; returns nil if no match found
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return string? type PokemonData.Type
---@return number distance The Levenshtein distance between search word and matched word
function DataHelper.findPokemonType(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return nil, -1
	end

	local type, _, distance = Utils.getClosestWord(Utils.toLowerUTF8(name), PokemonData.Types, threshold)
	return type, distance
end

-- Returns a table with all of the important display data safely formatted to draw on screen.
-- forceView: optional, if true forces view as viewingOwn, otherwise forces enemy view
function DataHelper.buildTrackerScreenDisplay(forceView)
	local data = {}
	data.p = {} -- data about the Pokemon itself
	data.m = {} -- data about the Moves of the Pokemon
	data.x = {} -- misc data to display, such as heals, encounters, badges

	data.x.viewingOwn = Battle.isViewingOwn
	if forceView ~= nil then
		data.x.viewingOwn = forceView
	end

	local targetInfo = Battle.getDoublesCursorTargetInfo()
	local viewedPokemon = Battle.getViewedPokemon(data.x.viewingOwn)
	local opposingPokemon = Tracker.getPokemon(targetInfo.slot, targetInfo.isOwner) -- For Low Kick weight calcs and OHKO moves
	local useOpenBookInfo = not data.x.viewingOwn and Options["Open Book Play Mode"]
	local gachaMonViewOverride = (Options["Show card pack on screen after capturing a GachaMon"] and GachaMonData.hasNewestMonToShow())

	if viewedPokemon == nil or viewedPokemon.pokemonID == 0 or not Program.isValidMapLocation() then
		viewedPokemon = Tracker.getDefaultPokemon()
		data.x.infoIsHidden = true
	elseif not Tracker.Data.hasCheckedSummary or gachaMonViewOverride then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = viewedPokemon.pokemonID
		defaultPokemon.level = viewedPokemon.level
		viewedPokemon = defaultPokemon
		data.x.infoIsHidden = true
	end

	local pokemonInternal = PokemonData.Pokemon[viewedPokemon.pokemonID] or PokemonData.BlankPokemon

	local pokemonLog = {}
	if RandomizerLog.Data.Pokemon then
		pokemonLog = RandomizerLog.Data.Pokemon[viewedPokemon.pokemonID] or {}
	end

	-- POKEMON ITSELF (data.p)
	data.p.id = viewedPokemon.pokemonID
	-- If there's a nickname that's different that the original Pokémon name and option is on, use that name
	if Options["Show nicknames"] and not Utils.isNilOrEmpty(viewedPokemon.nickname) and Utils.toLowerUTF8(pokemonInternal.name) ~= Utils.toLowerUTF8(viewedPokemon.nickname) then
		data.p.name = Utils.formatSpecialCharacters(viewedPokemon.nickname)
	elseif viewedPokemon.pokemonID == PokemonData.Values.GhostId then
		data.p.name = viewedPokemon.name or Constants.BLANKLINE
	else
		data.p.name = pokemonInternal.name or viewedPokemon.name or Constants.BLANKLINE
	end
	data.p.curHP = viewedPokemon.curHP or Constants.BLANKLINE
	data.p.level = viewedPokemon.level or Constants.BLANKLINE
	data.p.evo = pokemonInternal.evolution or Constants.BLANKLINE
	data.p.bst = pokemonInternal.bst or Constants.BLANKLINE
	data.p.lastlevel = Tracker.getLastLevelSeen(viewedPokemon.pokemonID) or ""
	data.p.status = MiscData.StatusCodeMap[viewedPokemon.status] or ""
	data.p.curExp = viewedPokemon.currentExp or 0
	data.p.totalExp = viewedPokemon.totalExp or 100
	data.p.friendship = viewedPokemon.friendship or PokemonData.Values.DefaultBaseFriendship -- Current value
	data.p.friendshipBase = pokemonInternal.friendshipBase or PokemonData.Values.DefaultBaseFriendship -- The starting value of the Pokémon

	-- Add: Stats, Stages, and Nature
	data.p.gender = viewedPokemon.gender
	data.p.nature = viewedPokemon.nature
	data.p.positivestat = ""
	data.p.negativestat = ""
	data.p.stages = {}
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		if useOpenBookInfo then
			data.p[statKey] = pokemonLog.BaseStats and pokemonLog.BaseStats[statKey] or Constants.BLANKLINE
		else
			data.p[statKey] = viewedPokemon.stats[statKey] or Constants.BLANKLINE
		end
		data.p.stages[statKey] = viewedPokemon.statStages[statKey] or 6

		local natureMultiplier = Utils.getNatureMultiplier(statKey, data.p.nature)
		if natureMultiplier == 1.1 then
			data.p.positivestat = statKey
		elseif natureMultiplier == 0.9 then
			data.p.negativestat = statKey
		end
	end
	data.p.stages.acc = viewedPokemon.statStages.acc or 6
	data.p.stages.eva = viewedPokemon.statStages.eva or 6

	-- Update: Pokemon Types
	if Battle.inActiveBattle() and (data.x.viewingOwn or not Battle.isGhost) then
		-- Update displayed types as typing changes (i.e. Color Change)
		data.p.types = Program.getPokemonTypes(data.x.viewingOwn, Battle.isViewingLeft)
	else
		data.p.types = { pokemonInternal.types[1], pokemonInternal.types[2], }
	end

	-- Update: Pokemon Evolution
	local isFriendEvoReady = data.p.evo == PokemonData.Evolutions.FRIEND and viewedPokemon.friendship >= Program.GameData.friendshipRequired
	if Options["Determine friendship readiness"] and data.x.viewingOwn and isFriendEvoReady then
		data.p.evo = PokemonData.Evolutions.FRIEND_READY
	end

	-- Update: Held Item and Ability area(s)
	data.p.line1 = Constants.BLANKLINE
	data.p.line2 = Constants.BLANKLINE
	if data.x.viewingOwn then
		if viewedPokemon.heldItem ~= nil and viewedPokemon.heldItem ~= 0 then
			data.p.line1 = MiscData.Items[viewedPokemon.heldItem]
		end
		local abilityId = PokemonData.getAbilityId(viewedPokemon.pokemonID, viewedPokemon.abilityNum)
		if AbilityData.isValid(abilityId) then
			data.p.line2 = AbilityData.Abilities[abilityId].name
		end
	elseif useOpenBookInfo then
		local abilityIds = {
			PokemonData.getAbilityId(viewedPokemon.pokemonID, 0),
			PokemonData.getAbilityId(viewedPokemon.pokemonID, 1),
		}
		if AbilityData.isValid(abilityIds[1]) then
			if abilityIds[2] ~= abilityIds[1] then
				data.p.line1 = AbilityData.Abilities[abilityIds[1]].name .. " /"
				data.p.line2 = AbilityData.Abilities[abilityIds[2]].name
			else
				data.p.line1 = AbilityData.Abilities[abilityIds[1]].name
				data.p.line2 = Constants.BLANKLINE
			end
		end
	else
		local trackedAbilities = Tracker.getAbilities(viewedPokemon.pokemonID)
		if AbilityData.isValid(trackedAbilities[1].id) then
			data.p.line1 = AbilityData.Abilities[trackedAbilities[1].id].name .. " /"
			data.p.line2 = Constants.HIDDEN_INFO
		end
		if AbilityData.isValid(trackedAbilities[2].id) then
			data.p.line2 = AbilityData.Abilities[trackedAbilities[2].id].name
		end
	end

	-- Add: Move Header
	data.m.nextmoveheader, data.m.nextmovelevel, data.m.nextmovespacing = Utils.getMovesLearnedHeader(viewedPokemon.pokemonID, viewedPokemon.level)

	-- MOVES OF POKEMON (data.m)
	data.m.moves = { {}, {}, {}, {}, } -- four empty move placeholders

	local stars
	if data.x.viewingOwn or useOpenBookInfo then
		stars = { "", "", "", "" }
	else
		stars = Utils.calculateMoveStars(viewedPokemon.pokemonID, viewedPokemon.level)
	end

	local trackedMoves = Tracker.getMoves(viewedPokemon.pokemonID, viewedPokemon.level)
	for i = 1, 4, 1 do
		local moveToCopy = MoveData.BlankMove
		if data.x.viewingOwn or useOpenBookInfo then
			local viewedMove = viewedPokemon.moves[i] or {}
			if MoveData.isValid(viewedMove.id) then
				moveToCopy = MoveData.Moves[viewedMove.id]
			end
		else
			-- If the Pokemon doesn't belong to the player, pull move data from tracked data
			local trackedMove = trackedMoves[i] or {}
			if MoveData.isValid(trackedMove.id) then
				moveToCopy = MoveData.Moves[trackedMove.id]
			end
		end

		-- Add in Move data information about the Move
		data.m.moves[i] = {}
		for key, value in pairs(moveToCopy) do
			data.m.moves[i][key] = value
		end

		local move = data.m.moves[i]

		move.id = tonumber(move.id) or 0
		move.starred = not Utils.isNilOrEmpty(stars[i])

		-- Update: Specific Moves
		if move.id == MoveData.Values.HiddenPowerId then
			if data.x.viewingOwn then
				move.type = Tracker.getHiddenPowerType(viewedPokemon)
			else
				move.type = MoveData.HIDDEN_POWER_NOT_SET
			end
			move.category = MoveData.getCategory(move.id, move.type)
		elseif Options["Calculate variable damage"] then
			MoveData.adjustVariableMoveValues(move, viewedPokemon, opposingPokemon)
		end

		-- Update: If STAB
		if Battle.inActiveBattle() then
			local ownTypes = Program.getPokemonTypes(data.x.viewingOwn, Battle.isViewingLeft)
			move.isstab = Utils.isSTAB(move, move.type, ownTypes)
		end

		if move.pp == "0" then
			move.pp = Constants.BLANKLINE
		end
		if move.power == "0" then
			move.power = Constants.BLANKLINE
		end
		if move.accuracy == "0" then
			move.accuracy = Constants.BLANKLINE
		end

		-- Update: Actual PP Values
		if move.name ~= MoveData.BlankMove.name then
			if data.x.viewingOwn or useOpenBookInfo then
				move.pp = viewedPokemon.moves[i].pp
			elseif Options["Count enemy PP usage"] then
				-- Interate over tracked moves, since we don't know the full move list
				for _, actualMove in pairs(viewedPokemon.moves) do
					if tonumber(actualMove.id) == move.id then -- unsure if first tonumber() is needed, not awake enough
						move.pp = actualMove.pp
					end
				end
			end
		end

		-- Update: Check if info should be hidden
		move.showeffective = true
		if Battle.isGhost then
			-- If fighting a ghost, hide effectiveness
			move.showeffective = false
		elseif not Options["Reveal info if randomized"] then
			-- If move info is randomized and the user doesn't want to know about it, hide it
			if data.x.viewingOwn or useOpenBookInfo then
				-- Don't show effectiveness of the player's moves if the enemy types are unknown
				move.showeffective = not PokemonData.IsRand.types
			else
				if MoveData.IsRand.moveType then
					move.type = PokemonData.Types.UNKNOWN
					move.showeffective = false
				end
				if MoveData.IsRand.movePP and move.pp ~= Constants.BLANKLINE then
					move.pp = Constants.HIDDEN_INFO
				end
				if MoveData.IsRand.movePower and move.power ~= Constants.BLANKLINE then
					move.power = Constants.HIDDEN_INFO
				end
				if MoveData.IsRand.moveAccuracy and move.accuracy ~= Constants.BLANKLINE then
					move.accuracy = Constants.HIDDEN_INFO
				end
			end
		end
		move.showeffective = move.showeffective and Options["Show move effectiveness"] and Battle.inActiveBattle()

		-- Update: Calculate move effectiveness
		if move.showeffective then
			local enemyTypes = Program.getPokemonTypes(targetInfo.isOwner, targetInfo.isLeft)
			move.effectiveness = Utils.netEffectiveness(move, move.type, enemyTypes)
		else
			move.effectiveness = 1
		end
	end

	-- MISC DATA (data.x)
	if data.x.infoIsHidden then
		data.x.healperc = 0
		data.x.healvalue = 0
		data.x.healnum = 0
	else
		data.x.healperc = math.min(9999, Program.GameData.Items.healingPercentage or 0) -- Max of 9999
		data.x.healvalue = math.min(99999, Program.GameData.Items.healingValue or 0) -- Max of 99999
		data.x.healnum = math.min(99, Program.GameData.Items.healingTotal or 0) -- Max of 99
	end
	data.x.pcheals = Tracker.Data.centerHeals

	local gachamon = viewedPokemon and GachaMonData.getAssociatedRecentMon(viewedPokemon)
	if gachamon and not data.x.infoIsHidden then
		data.x.gachamonStars = gachamon:getStars()
	else
		data.x.gachamonStars = 0
	end

	data.x.route = Constants.BLANKLINE
	if RouteData.hasRoute(Program.GameData.mapId) then
		data.x.route = RouteData.Info[Program.GameData.mapId].name or Constants.BLANKLINE
		data.x.route = Utils.formatSpecialCharacters(data.x.route)
	end

	if Battle.inActiveBattle() then
		data.x.encounters = math.min(Tracker.getEncounters(viewedPokemon.pokemonID, Battle.isWildEncounter), 999) -- Max 999
	else
		data.x.encounters = 0
	end

	if Options["Show Poke Ball catch rate"] and not data.x.viewingOwn and Battle.isWildEncounter then
		data.x.catchrate = PokemonData.calcCatchRate(viewedPokemon.pokemonID, viewedPokemon.stats.hp, viewedPokemon.curHP, viewedPokemon.level, viewedPokemon.status)
	else
		data.x.catchrate = 0
	end

	data.x.extras = Program.getExtras()

	return data
end

function DataHelper.buildPokemonInfoDisplay(pokemonID)
	local data = {}
	data.p = {} -- data about the Pokemon itself
	data.e = {} -- data about the Type Effectiveness of the Pokemon
	data.x = {} -- misc data to display, such as notes

	local pokemon = PokemonData.isValid(pokemonID) and PokemonData.Pokemon[pokemonID] or PokemonData.BlankPokemon

	-- Your lead Pokémon
	local ownLeadPokemon = Battle.getViewedPokemon(true) or {}

	data.p.id = pokemon.pokemonID or 0
	data.p.name = pokemon.name or Constants.BLANKLINE
	data.p.bst = pokemon.bst or Constants.BLANKLINE
	data.p.weight = pokemon.weight or Constants.BLANKLINE
	data.p.evo = pokemon.evolution or PokemonData.Evolutions.NONE

	-- Hide Pokemon types if player shouldn't know about them
	if pokemon.types and (not PokemonData.IsRand.types or Options["Reveal info if randomized"] or pokemon.pokemonID == ownLeadPokemon.pokemonID) then
		data.p.types = { pokemon.types[1], pokemon.types[2] }
	else
		data.p.types = { PokemonData.Types.UNKNOWN, PokemonData.Types.UNKNOWN }
	end

	data.p.movelvls = {}
	local moveLevelsList = pokemon.movelvls[GameSettings.versiongroup]
	if moveLevelsList ~= nil and #moveLevelsList ~= 0 then
		for _, moveLv in ipairs(moveLevelsList) do
			table.insert(data.p.movelvls, moveLv)
		end
	end

	data.e = PokemonData.getEffectiveness(pokemon.pokemonID)

	data.x.note = Tracker.getNote(pokemon.pokemonID) or ""

	-- Used for highlighting which moves have already been learned, but only for a matching Pokémon in battle
	local matchedPokemon
	if Battle.inActiveBattle() then
		for _, mon in ipairs(TrackerAPI.getActiveBattlePokemon()) do
			if mon.pokemonID and mon.pokemonID == pokemon.pokemonID then
				matchedPokemon = mon
				data.x.viewedPokemonLevel = mon.level or 0
				break
			end
		end
	elseif ownLeadPokemon.pokemonID == pokemon.pokemonID then
		matchedPokemon = ownLeadPokemon
		data.x.viewedPokemonLevel = ownLeadPokemon.level
	end
	if not data.x.viewedPokemonLevel then
		data.x.viewedPokemonLevel = 0
	end

	-- Experience yield
	if matchedPokemon and (matchedPokemon.level or 0) > 0 then
		local yield = PokemonData.Pokemon[matchedPokemon.pokemonID].expYield or 0
		local ratio = Battle.isWildEncounter and (matchedPokemon.level / 7) or (matchedPokemon.level * 3 / 14)
		data.p.expYield = math.floor(yield * ratio)
	else
		data.p.expYield = pokemon.expYield or Constants.BLANKLINE
	end

	return data
end

function DataHelper.buildMoveInfoDisplay(moveId)
	local data = {}
	data.m = {} -- data about the Move itself
	data.x = {} -- misc data to display

	local move = MoveData.isValid(moveId) and MoveData.Moves[moveId] or MoveData.BlankMove

	data.m.id = tonumber(move.id) or 0
	data.m.name = move.name or Constants.BLANKLINE
	data.m.type = move.type or PokemonData.Types.UNKNOWN
	data.m.category = move.category or MoveData.Categories.NONE
	data.m.pp = move.pp or "0"
	data.m.power = move.power or "0"
	data.m.accuracy = move.accuracy or "0"
	data.m.iscontact = move.iscontact or false
	data.m.priority = move.priority or "0"
	data.m.summary = move.summary or Constants.BLANKLINE

	local ownLeadPokemon = Battle.getViewedPokemon(true)
	local hideSomeInfo = not Options["Reveal info if randomized"] and not Utils.pokemonHasMove(ownLeadPokemon, move.id)

	if moveId == MoveData.Values.HiddenPowerId and Utils.pokemonHasMove(ownLeadPokemon, MoveData.Values.HiddenPowerId) then
		data.m.type = Tracker.getHiddenPowerType(ownLeadPokemon)
		data.m.category = MoveData.getCategory(moveId, data.m.type)
		data.x.ownHasHiddenPower = true
	end

	-- Don't reveal randomized move info for moves the player's current pokemon doesn't have
	if hideSomeInfo then
		if MoveData.IsRand.moveType then
			data.m.type = PokemonData.Types.UNKNOWN
			if data.m.category ~= MoveData.Categories.STATUS and not MoveData.IsRand.moveCategory then
				data.m.category = Constants.HIDDEN_INFO
			end
		end
		if MoveData.IsRand.movePP then
			data.m.pp = Constants.HIDDEN_INFO
		end
		if MoveData.IsRand.movePower then
			data.m.power = Constants.HIDDEN_INFO
		end
		if MoveData.IsRand.moveAccuracy then
			data.m.accuracy = Constants.HIDDEN_INFO
		end
	end

	if data.m.pp == "0" then
		data.m.pp = Constants.BLANKLINE
	end
	if data.m.power == "0" then
		data.m.power = Constants.BLANKLINE
	end
	if data.m.accuracy == "0" then
		data.m.accuracy = Constants.BLANKLINE
	end

	return data
end

function DataHelper.buildAbilityInfoDisplay(abilityId)
	local data = {}
	data.a = {} -- data about the Ability itself
	data.x = {} -- misc data to display

	local ability = AbilityData.isValid(abilityId) and AbilityData.Abilities[abilityId] or AbilityData.DefaultAbility

	data.a.id = ability.id or 0
	data.a.name = ability.name or Constants.BLANKLINE
	data.a.description = ability.description or Constants.BLANKLINE
	data.a.descriptionEmerald = ability.descriptionEmerald or Constants.BLANKLINE

	data.x = nil -- Currently unused

	return data
end

function DataHelper.buildRouteInfoDisplay(routeId)
	local data = {}
	data.r = {} -- data about the Route itself
	data.e = {} -- data about each of the Routes encounter areas
	data.x = {} -- misc data to display

	local route = RouteData.hasRoute(routeId) and RouteData.Info[routeId] or RouteData.BlankRoute

	data.r.id = routeId or 0
	data.r.name = Utils.formatSpecialCharacters(route.name) or Constants.BLANKLINE
	data.r.totalTrainerEncounters = 0
	data.r.totalWildEncounters = 0

	for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
		data.e[encounterArea] = {}
		local area = data.e[encounterArea]

		-- Store tracked encounters
		area.trackedIDs = {} -- list of pokemonIDs only; the rates & levels are unknown
		local trackedPokemonIDs = Tracker.getRouteEncounters(routeId, encounterArea)
		for _, pokemonID in ipairs(trackedPokemonIDs) do
			table.insert(area.trackedIDs, pokemonID)
		end

		-- Store actual encounters from the original game
		area.originalPokemon = {} -- table of entries, each containing pokemonID, rate, minLv, maxLv
		local encountersAvailable = RouteData.getEncounterAreaPokemon(routeId, encounterArea)
		if encountersAvailable ~= nil and #encountersAvailable ~= 0 then
			area.originalPokemon = encountersAvailable
		end

		area.totalSeen = #area.trackedIDs
		area.totalPossible = #area.originalPokemon

		if encounterArea == RouteData.EncounterArea.TRAINER then
			-- TODO: This is currently inaccurate but also unused
			data.r.totalTrainerEncounters = data.r.totalTrainerEncounters + area.totalPossible
		else
			data.r.totalWildEncounters = data.r.totalWildEncounters + area.totalPossible
		end
	end

	return data
end

function DataHelper.buildPokemonLogDisplay(pokemonID)
	local data = {}
	data.p = {} -- data about the Pokemon itself
	data.x = {} -- misc data to display, such as notes

	local pokemonInternal
	if not PokemonData.isValid(pokemonID) then
		pokemonInternal = PokemonData.BlankPokemon
		return data -- likely want a safer way
	else
		pokemonInternal = PokemonData.Pokemon[pokemonID]
	end
	local pokemonLog = RandomizerLog.Data.Pokemon[pokemonID]

	data.p.id = pokemonInternal.pokemonID or 0
	data.p.name = RandomizerLog.getPokemonName(pokemonID)
	data.p.bst = pokemonInternal.bstCalculated or pokemonInternal.bst or Constants.BLANKLINE
	data.p.types = {
		pokemonLog.Types[1],
		pokemonLog.Types[2],
	}
	data.p.abilities = {
		pokemonLog.Abilities[1],
		pokemonLog.Abilities[2],
	}

	-- The following are all Randomizer Log information
	data.p.helditems = pokemonLog.HeldItems or Constants.BLANKLINE -- unsure how this is formatted

	-- The Pokemon's randomized base stats
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		if pokemonLog.BaseStats ~= nil then
			data.p[statKey] = pokemonLog.BaseStats[statKey] or 0
		else
			data.p[statKey] = 0
		end
	end

	-- The Pokemon's randomized evolutions
	data.p.evos = {}
	for _, evoId in ipairs(pokemonLog.Evolutions or {}) do
		local evo = {
			id = evoId,
			name = PokemonData.Pokemon[evoId].name,
		}
		table.insert(data.p.evos, evo)
	end

	-- Pre-evolutions
	data.p.prevos = {}
	for _, prevoId in ipairs(pokemonLog.PreEvolutions or {}) do
		local prevo = {
			id = prevoId,
			name = PokemonData.Pokemon[prevoId].name,
		}
		table.insert(data.p.prevos, prevo)
	end


	-- The Pokemon's level-up move list, in order of levels
	data.p.moves = {}
	for _, moveLog in ipairs(pokemonLog.MoveSet or {}) do
		local move = {
			id = moveLog.moveId,
			level = moveLog.level,
		}
		local moveInternal = MoveData.Moves[moveLog.moveId]
		if moveInternal ~= nil then
			move.name = moveInternal.name
			move.isstab = Utils.isSTAB(moveInternal, moveInternal.type, data.p.types)
		else
			move.name = moveLog.name or Constants.BLANKLINE
			move.isstab = false
		end
		table.insert(data.p.moves, move)
	end

	-- Determine gym TMs for the game
	local gymTMs = {}
	for gymNum, gymTM in ipairs(TrainerData.GymTMs) do
		gymTMs[gymTM.number] = gymNum
	end

	-- The Pokemon's TM Move Compatibility, which moves it can learn from TMs
	data.p.tmmoves = {}
	for _, tmNumber in ipairs(pokemonLog.TMMoves or {}) do
		local tmLog = RandomizerLog.Data.TMs[tmNumber]
		local tm = {
			tm = tmNumber,
			moveId = tmLog.moveId,
			gymNum = gymTMs[tmNumber] or 9,
		}
		local moveInternal = MoveData.Moves[tmLog.moveId]
		if moveInternal ~= nil then
			tm.moveName = moveInternal.name
			tm.isstab = Utils.isSTAB(moveInternal, moveInternal.type, data.p.types)
		else
			tm.moveName = tmLog.name or Constants.BLANKLINE
			tm.isstab = false
		end
		table.insert(data.p.tmmoves, tm)
	end

	data.x.extras = Program.getExtras()

	return data
end

function DataHelper.buildTrainerLogDisplay(trainerId)
	local data = {}
	data.t = {} -- data about the Trainer itself
	data.p = {} -- data about each Pokemon in the Trainer's party
	data.x = {} -- misc data to display, such as notes

	if trainerId == nil or RandomizerLog.Data.Trainers[trainerId] == nil then
		return data
	end

	local trainerLog = RandomizerLog.Data.Trainers[trainerId]
	local trainerInternal = TrainerData.getTrainerInfo(trainerId) or {}

	data.t.id = trainerId or 0
	data.t.filename = TrainerData.getFullImage(trainerInternal.class) or Constants.BLANKLINE
	data.t.name = Utils.firstToUpperEachWord(trainerLog.name) or Constants.BLANKLINE
	data.t.class = Utils.firstToUpperEachWord(trainerLog.class) or ""
	data.t.fullname = Utils.firstToUpperEachWord(trainerLog.fullname) or Constants.BLANKLINE
	data.t.customName = Utils.firstToUpperEachWord(trainerLog.customName) or Constants.BLANKLINE
	data.t.customClass = Utils.firstToUpperEachWord(trainerLog.customClass) or Constants.BLANKLINE
	data.t.customFullname = Utils.firstToUpperEachWord(trainerLog.customname) or Constants.BLANKLINE

	for _, partyMon in ipairs(trainerLog.party or {}) do
		local pokemon = {
			id = partyMon.pokemonID or 0,
			name = RandomizerLog.getPokemonName(partyMon.pokemonID),
			level = partyMon.level or 0,
			moves = {},
			helditem = partyMon.helditem,
		}

		local pokemonLog = RandomizerLog.Data.Pokemon[partyMon.pokemonID]
		local pokemonTypes = {
			pokemonLog.Types[1],
			pokemonLog.Types[2],
		}

		for _, moveId in ipairs(partyMon.moveIds) do
			local move = {
				moveId = moveId,
				name = Constants.BLANKLINE,
				isstab = false,
			}

			local moveInternal = MoveData.Moves[moveId]
			if moveInternal ~= nil then
				move.name = moveInternal.name
				move.isstab = Utils.isSTAB(moveInternal, moveInternal.type, pokemonTypes)
			else
				-- Otherwise likely a custom name, look it up from its move list, cannot confirm if STAB
				for _, moveLog in ipairs(pokemonLog.MoveSet or {}) do
					if moveLog.moveId == moveId then
						move.name = moveLog.name or Constants.BLANKLINE
						break
					end
				end
			end
			table.insert(pokemon.moves, move)
		end
		table.insert(data.p, pokemon)
	end

	-- Gym number (if applicable), otherwise nil
	if trainerInternal.group == TrainerData.TrainerGroups.Gym then
		data.x.gymNumber = tonumber(string.match(data.t.filename, "gymleader%-(%d+)"))
	end

	return data
end

function DataHelper.buildRouteLogDisplay(mapId)
	local data = {}
	data.r = {} -- data about the Route itself
	data.e = {} -- data about each trainer or wild encounter area in the Route (list of trainers/areas, each is a list of pokemon)
	data.x = {} -- misc data to display, such as notes

	if mapId == nil or RandomizerLog.Data.Routes[mapId] == nil then
		return data
	end

	local routeLog = RandomizerLog.Data.Routes[mapId]
	local routeInternal = RouteData.Info[mapId] or {}

	data.r.id = mapId or 0
	data.r.name =  Utils.firstToUpper(routeLog.name or routeInternal.name or Constants.BLANKLINE)
	data.r.icon = routeInternal.icon or RouteData.Icons.RouteSign

	for key, _ in pairs(RandomizerLog.EncounterTypes) do
		data.e[key] = {}
	end

	for key, encounterArea in pairs(routeLog.EncountersAreas) do
		if key == "Trainers" then
			for _, trainerId in ipairs(encounterArea.trainers or {}) do
				local trainerInternal = TrainerData.getTrainerInfo(trainerId) or {}
				local trainerLog = RandomizerLog.Data.Trainers[trainerId]
				if trainerLog ~= nil then -- Emerald has more trainers than Ruby/Sapphire; exclude the missing ones
					local trainer = {
						id = trainerId,
						name = Utils.firstToUpperEachWord(trainerLog.name) or Constants.BLANKLINE,
						class = Utils.firstToUpperEachWord(trainerLog.class) or "",
						fullname = Utils.firstToUpperEachWord(trainerLog.fullname) or Constants.BLANKLINE,
						customName = Utils.firstToUpperEachWord(trainerLog.customName) or Constants.BLANKLINE,
						customClass = Utils.firstToUpperEachWord(trainerLog.customClass) or "",
						customFullname = Utils.firstToUpperEachWord(trainerLog.customFullname) or Constants.BLANKLINE,
						filename = TrainerData.getPortraitIcon(trainerInternal.class) or Constants.BLANKLINE,
						maxlevel = trainerLog.maxlevel or 0,
						pokemon = {},
					}

					for _, pokemonLog in ipairs(trainerLog.party or {}) do
						local pokemon = {
							pokemonID = pokemonLog.pokemonID or 0,
							level = pokemonLog.level or 0
						}
						table.insert(trainer.pokemon, pokemon)
					end

					table.insert(data.e[key], trainer)
				end
			end
		else
			for pokemonID, enc in pairs(encounterArea.pokemon or {}) do
				local pokemonEnc = {
					pokemonID = pokemonID,
					levelMin = enc.levelMin or 0,
					levelMax = enc.levelMax or 0,
					rate = enc.rate or 0,
				}
				table.insert(data.e[key], pokemonEnc)
			end
		end
	end

	-- Currently unused
	data.x.avgTrainerLv = routeLog.avgTrainerLv
	data.x.maxWildLv = routeLog.maxWildLv

	return data
end
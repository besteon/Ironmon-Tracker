DataHelper = {}

---Searches for a Pokémon by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return number pokemonID
function DataHelper.findPokemonId(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return PokemonData.BlankPokemon.pokemonID
	end

	-- Format list of Pokemon as id, name pairs
	local pokemonNames = {}
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		if (pokemon.bst ~= Constants.BLANKLINE) then
			pokemonNames[id] = Utils.toLowerUTF8(pokemon.name)
		end
	end

	local id, _ = Utils.getClosestWord(Utils.toLowerUTF8(name), pokemonNames, threshold)
	return id or PokemonData.BlankPokemon.pokemonID
end

---Searches for a Move by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return number moveId
function DataHelper.findMoveId(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return tonumber(MoveData.BlankMove.id) or 0
	end

	-- Format list of Moves as id, name pairs
	local moveNames = {}
	for id, move in ipairs(MoveData.Moves) do
		moveNames[id] = Utils.toLowerUTF8(move.name)
	end

	local id, _ = Utils.getClosestWord(Utils.toLowerUTF8(name), moveNames, threshold)
	return id or tonumber(MoveData.BlankMove.id) or 0
end

---Searches for an Ability by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return number abilityId
function DataHelper.findAbilityId(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return AbilityData.DefaultAbility.id
	end

	-- Format list of Abilities as id, name pairs
	local abilityNames = {}
	for id, ability in ipairs(AbilityData.Abilities) do
		abilityNames[id] = Utils.toLowerUTF8(ability.name)
	end

	local id, _ = Utils.getClosestWord(Utils.toLowerUTF8(name), abilityNames, threshold)
	return id or AbilityData.DefaultAbility.id
end

---Searches for a Route by name, finds the best match; returns 0 if no good match
---@param name string?
---@param threshold number? Default threshold distance of 5!
---@return number mapId
function DataHelper.findRouteId(name, threshold)
	threshold = threshold or 5
	if Utils.isNilOrEmpty(name) then
		return RouteData.BlankRoute.id
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

	local id, _ = Utils.getClosestWord(Utils.toLowerUTF8(name), routeNames, threshold)
	return id or RouteData.BlankRoute.id
end

---Searches for a Pokémon Type by name, finds the best match; returns nil if no match found
---@param name string?
---@param threshold number? Default threshold distance of 3
---@return string? type PokemonData.Type
function DataHelper.findPokemonType(name, threshold)
	threshold = threshold or 3
	if Utils.isNilOrEmpty(name) then
		return nil
	end

	local type, _ = Utils.getClosestWord(Utils.toLowerUTF8(name), PokemonData.Types, threshold)
	return type
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
	local opposingPokemon = Tracker.getPokemon(targetInfo.slot, targetInfo.isOwner) -- currently used exclusively for Low Kick weight calcs
	local useOpenBookInfo = not data.x.viewingOwn and Options["Open Book Play Mode"]

	if viewedPokemon == nil or viewedPokemon.pokemonID == 0 or not Program.isValidMapLocation() then
		viewedPokemon = Tracker.getDefaultPokemon()
	elseif not Tracker.Data.hasCheckedSummary then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = viewedPokemon.pokemonID
		defaultPokemon.level = viewedPokemon.level
		viewedPokemon = defaultPokemon
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
	elseif viewedPokemon.pokemonID == 413 then -- Ghost
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
	data.p.friendship = viewedPokemon.friendship or 70 -- Current value; 70 is default for most Pokémon
	data.p.friendshipBase = pokemonInternal.friendshipBase or 70 -- The starting value of the Pokémon

	-- Add: Stats, Stages, and Nature
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

	local trackedMoves = Tracker.getMoves(viewedPokemon.pokemonID)
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
		if move.id == 237 then -- 237 = Hidden Power
			if data.x.viewingOwn then
				move.type = Tracker.getHiddenPowerType(viewedPokemon)
			else
				move.type = MoveData.HIDDEN_POWER_NOT_SET
			end
			move.category = MoveData.TypeToCategory[move.type]
		elseif Options["Calculate variable damage"] then
			if move.id == 311 then -- 311 = Weather Ball
				move.type, move.power = Utils.calculateWeatherBall(move.type, move.power)
				move.category = MoveData.TypeToCategory[move.type]
			elseif move.id == 67 and Battle.inActiveBattle() and opposingPokemon ~= nil then -- 67 = Low Kick
				local targetWeight
				if opposingPokemon.weight ~= nil then
					targetWeight = opposingPokemon.weight
				elseif PokemonData.Pokemon[opposingPokemon.pokemonID] ~= nil then
					targetWeight = PokemonData.Pokemon[opposingPokemon.pokemonID].weight
				else
					targetWeight = 0
				end
				move.power = Utils.calculateWeightBasedDamage(move.power, targetWeight)
			elseif data.x.viewingOwn then
				if move.id == 175 or move.id == 179 then -- 175 = Flail, 179 = Reversal
					move.power = Utils.calculateLowHPBasedDamage(move.power, viewedPokemon.curHP, viewedPokemon.stats.hp)
				elseif move.id == 284 or move.id == 323 then -- 284 = Eruption, 323 = Water Spout
					move.power = Utils.calculateHighHPBasedDamage(move.power, viewedPokemon.curHP, viewedPokemon.stats.hp)
				elseif move.id == 216 or move.id == 218 then -- 216 = Return, 218 = Frustration
					move.power = Utils.calculateFriendshipBasedDamage(move.power, viewedPokemon.friendship)
				end
			end
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
	data.x.healperc = math.min(9999, Program.GameData.Items.healingPercentage or 0) -- Max of 9999
	data.x.healnum = math.min(99, Program.GameData.Items.healingTotal or 0) -- Max of 99
	data.x.pcheals = Tracker.Data.centerHeals

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
	if not PokemonData.IsRand.types or Options["Reveal info if randomized"] or (pokemon.pokemonID == ownLeadPokemon.pokemonID) then
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

	-- Used for highlighting which moves have already been learned, but only for the Pokémon actively being viewed
	local pokemonViewed = Tracker.getViewedPokemon() or {}
	if pokemonViewed.pokemonID == pokemon.pokemonID then
		data.x.viewedPokemonLevel = pokemonViewed.level or 0
	else
		data.x.viewedPokemonLevel = 0
	end

	-- Experience yield
	if data.x.viewedPokemonLevel ~= 0 then
		local yield = PokemonData.Pokemon[pokemonViewed.pokemonID].expYield or 0
		local ratio = Battle.isWildEncounter and (pokemonViewed.level / 7) or (pokemonViewed.level * 3 / 14)
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

	if moveId == 237 and Utils.pokemonHasMove(ownLeadPokemon, 237) then -- 237 = Hidden Power
		data.m.type = Tracker.getHiddenPowerType(ownLeadPokemon)
		data.m.category = MoveData.TypeToCategory[data.m.type]
		data.x.ownHasHiddenPower = true
	end

	-- Don't reveal randomized move info for moves the player's current pokemon doesn't have
	if hideSomeInfo then
		if MoveData.IsRand.moveType then
			data.m.type = PokemonData.Types.UNKNOWN
			if data.m.category ~= MoveData.Categories.STATUS then
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

DataHelper.EventRequests = {}

---@param params string?
---@return string response
function DataHelper.EventRequests.getPokemon(params)
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
function DataHelper.EventRequests.getBST(params)
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
function DataHelper.EventRequests.getWeak(params)
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
function DataHelper.EventRequests.getMove(params)
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
function DataHelper.EventRequests.getAbility(params)
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
function DataHelper.EventRequests.getRoute(params)
	local routeId = getRouteIdOrDefault(params)
	local route = RouteData.Info[routeId or false]
	if not route then
		return buildDefaultResponse(params)
	end

	local info = {}
	-- Check for trainers in the route
	if route.trainers and #route.trainers > 0 then
		local defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByLocation(routeId)
		table.insert(info, string.format("%s: %s/%s", "Trainers defeated", #defeatedTrainers, totalTrainers))
	end
	-- Check for wilds in the route
	local encounterArea = RouteData.getNextAvailableEncounterArea(routeId, RouteData.EncounterArea.TRAINER) -- for now, default to the first area type (usually Walking)
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

	local prefix = string.format("%s %s", route.name, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function DataHelper.EventRequests.getDungeon(params)
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
	local routeName = route.area and route.area.name or route.name
	local prefix = string.format("%s %s", routeName, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function DataHelper.EventRequests.getPivots(params)
	local info = {}
	local mapIds
	if GameSettings.game == 3 then -- FRLG
		mapIds = { 89, 90, 110, 117 } -- Route 1, 2, 22, Viridian Forest
	else -- RSE
		local offset = GameSettings.versioncolor == "Emerald" and 0 or 1 -- offset all "mapId > 107" by +1
		mapIds = { 17, 18, 19, 20, 32, 135 + offset } -- Route 101, 102, 103, 104, 116, Petalburg Forest
	end
	for _, mapId in ipairs(mapIds) do
		-- Check for tracked wild encounters in the route
		local seenIds = Tracker.getRouteEncounters(mapId, RouteData.EncounterArea.LAND)
		local pokemonNames = {}
		for _, pokemonId in ipairs(seenIds) do
			if PokemonData.isValid(pokemonId) then
				table.insert(pokemonNames, PokemonData.Pokemon[pokemonId].name)
			end
		end
		if #seenIds > 0 then
			local route = RouteData.Info[mapId or false] or {}
			table.insert(info, string.format("%s: %s", route.name or "Unknown Route", table.concat(pokemonNames, ", ")))
		end
	end
	local prefix = string.format("%s %s", "Pivots", OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function DataHelper.EventRequests.getRevo(params)
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
		return buildDefaultResponse(pokemon.name or params)
	end

	local info = {}
	local shortenPerc = function(p)
		if p < 0.01 then return "<0.01%"
		elseif p < 0.1 then return string.format("%.2f%%", p)
		else return string.format("%.1f%%", p) end
	end
	local extraMons = 0
	for _, revoInfo in ipairs(revo) do
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
function DataHelper.EventRequests.getCoverage(params)
	local calcFromLead = true
	local onlyFullyEvolved = false
	local moveTypes = {}
	if not Utils.isNilOrEmpty(params) then
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
function DataHelper.EventRequests.getHeals(params)
	local info = {}

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
	local function sortFunc(a,b) return a.value > b.value or (a.value == b.value and a.id < b.id) end
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
	local function sortAndCombine(label, items)
		table.sort(items, sortFunc)
		local t = {}
		for _, item in ipairs(items) do table.insert(t, item.text) end
		table.insert(info, string.format("[%s] %s", label, table.concat(t, ", ")))
	end
	local healingItems, ppItems, statusItems, berryItems = {}, {}, {}, {}
	for id, quantity in pairs(Program.GameData.Items.HPHeals) do
		local itemInfo = getSortableItem(id, quantity)
		if itemInfo then
			table.insert(healingItems, itemInfo)
			if displayBerries and MiscData.HealingItems[id].pocket == MiscData.BagPocket.Berries then
				table.insert(berryItems, itemInfo)
			end
		end
	end
	for id, quantity in pairs(Program.GameData.Items.PPHeals) do
		local itemInfo = getSortableItem(id, quantity)
		if itemInfo then
			table.insert(ppItems, itemInfo)
			if displayBerries and MiscData.PPItems[id].pocket == MiscData.BagPocket.Berries then
				table.insert(berryItems, itemInfo)
			end
		end
	end
	for id, quantity in pairs(Program.GameData.Items.StatusHeals) do
		local itemInfo = getSortableItem(id, quantity)
		if itemInfo then
			table.insert(statusItems, itemInfo)
			if displayBerries and MiscData.StatusItems[id].pocket == MiscData.BagPocket.Berries then
				table.insert(berryItems, itemInfo)
			end
		end
	end
	if displayHP and #healingItems > 0 then
		sortAndCombine("HP", healingItems)
	end
	if displayPP and #ppItems > 0 then
		sortAndCombine("PP", ppItems)
	end
	if displayStatus and #statusItems > 0 then
		sortAndCombine("Status", statusItems)
	end
	if displayBerries and #berryItems > 0 then
		sortAndCombine("Berries", berryItems)
	end
	local prefix = string.format("%s %s", Resources.TrackerScreen.HealsInBag, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function DataHelper.EventRequests.getTMsHMs(params)
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
			local moveId = Program.getMoveIdFromTMHMNumber(hmNumber)
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
function DataHelper.EventRequests.getSearch(params)
	local helpResponse = "Search tracked info for a Pokémon, move, or ability."
	if Utils.isNilOrEmpty(params, true) then
		return buildResponse(params, helpResponse)
	end
	local function getModeAndId(input, threshold)
		local id = DataHelper.findPokemonId(input, threshold)
		if id ~= 0 then return "pokemon", id end
		id = DataHelper.findMoveId(input, threshold)
		if id ~= 0 then return "move", id end
		id = DataHelper.findAbilityId(input, threshold)
		if id ~= 0 then return "ability", id end
		return nil, 0
	end
	local searchMode, searchId
	for i=1, 4, 1 do
		searchMode, searchId = getModeAndId(params, i)
		if searchMode then
			break
		end
	end
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
function DataHelper.EventRequests.getSearchNotes(params)
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
function DataHelper.EventRequests.getTheme(params)
	local info = {}
	local themeCode = Theme.exportThemeToText()
	local themeName = Theme.getThemeNameFromCode(themeCode)
	table.insert(info, string.format("%s: %s", themeName, themeCode))
	local prefix = string.format("%s %s", "Theme", OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function DataHelper.EventRequests.getGameStats(params)
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
function DataHelper.EventRequests.getProgress(params)
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
function DataHelper.EventRequests.getLog(params)
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
function DataHelper.EventRequests.getAbout(params)
	local info = {}
	table.insert(info, string.format("%s: %s", Resources.StartupScreen.Version, Main.TrackerVersion))
	table.insert(info, string.format("%s: %s", Resources.StartupScreen.Game, GameSettings.gamename))
	table.insert(info, string.format("%s: %s", Resources.StartupScreen.Attempts, Main.currentSeed or 1))
	table.insert(info, string.format("%s: v%s", "Streamerbot Code", Network.currentStreamerbotVersion or "N/A")) -- TODO: Language
	local prefix = string.format("%s %s", Resources.StartupScreen.Title, OUTPUT_CHAR)
	return buildResponse(prefix, info)
end

---@param params string?
---@return string response
function DataHelper.EventRequests.getHelp(params)
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
	local prefix = string.format("%s %s", "Tracker Commands", OUTPUT_CHAR)
	return buildResponse(prefix, info, ", ")
end
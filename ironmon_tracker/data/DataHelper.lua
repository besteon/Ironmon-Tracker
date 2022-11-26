DataHelper = {}

-- Returns a table with all of the important display data safely formatted to draw on screen.
-- forceView: optional, if true forces view as viewingOwn, otherwise forces enemy view
function DataHelper.buildTrackerScreenDisplay(forceView)
	local data = {}
	data.p = {} -- data about the Pokemon itself
	data.m = {} -- data about the Moves of the Pokemon
	data.x = {} -- misc data to display, such as heals, encounters, badges

	data.x.viewingOwn = Tracker.Data.isViewingOwn
	if forceView ~= nil then
		data.x.viewingOwn = forceView
	end

	--Assume we are always looking at the left pokemon on the opposing side for move effectiveness
	local viewedPokemon
	local opposingPokemon -- currently used exclusively for Low Kick weight calcs
	if data.x.viewingOwn then
		viewedPokemon = Battle.getViewedPokemon(true)
		opposingPokemon = Tracker.getPokemon(Battle.Combatants.LeftOther, false)
	else
		viewedPokemon = Battle.getViewedPokemon(false)
		opposingPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn, true)
	end

	if viewedPokemon == nil or viewedPokemon.pokemonID == 0 or not Program.isValidMapLocation() then
		viewedPokemon = Tracker.getDefaultPokemon()
	elseif not Tracker.Data.hasCheckedSummary then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = viewedPokemon.pokemonID
		defaultPokemon.level = viewedPokemon.level
		viewedPokemon = defaultPokemon
	end

	-- Add in Pokedex information about the Pokemon
	if PokemonData.isValid(viewedPokemon.pokemonID) then
		for key, value in pairs(PokemonData.Pokemon[viewedPokemon.pokemonID]) do
			viewedPokemon[key] = value
		end
	end

	-- POKEMON ITSELF (data.p)
	data.p.id = viewedPokemon.pokemonID
	data.p.name = viewedPokemon.name or Constants.BLANKLINE
	data.p.curHP = viewedPokemon.curHP or Constants.BLANKLINE
	data.p.level = viewedPokemon.level or Constants.BLANKLINE
	data.p.evo = viewedPokemon.evolution or Constants.BLANKLINE
	data.p.bst = viewedPokemon.bst or Constants.BLANKLINE
	data.p.lastlevel = Tracker.getLastLevelSeen(viewedPokemon.pokemonID) or ""
	data.p.status = MiscData.StatusCodeMap[viewedPokemon.status] or ""

	-- Add: Stats, Stages, and Nature
	data.p.nature = viewedPokemon.nature
	data.p.positivestat = ""
	data.p.negativestat = ""
	data.p.stages = {}
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		data.p[statKey] = viewedPokemon.stats[statKey] or Constants.BLANKLINE
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
	if Battle.inBattle and (data.x.viewingOwn or not Battle.isGhost) then
		-- Update displayed types as typing changes (i.e. Color Change)
		data.p.types = Program.getPokemonTypes(data.x.viewingOwn, Battle.isViewingLeft)
	else
		data.p.types = { viewedPokemon.types[1], viewedPokemon.types[2], }
	end

	-- Update: Pokemon Evolution
	if data.x.viewingOwn and data.p.evo == PokemonData.Evolutions.FRIEND and viewedPokemon.friendship >= Program.friendshipRequired then
		data.p.evo = "SOON"
	end

	-- Update: Held Item and Ability area(s)
	data.p.line1 = Constants.BLANKLINE
	data.p.line2 = Constants.BLANKLINE
	if data.x.viewingOwn then
		if viewedPokemon.heldItem ~= nil and viewedPokemon.heldItem ~= 0 then
			data.p.line1 = MiscData.Items[viewedPokemon.heldItem]
		end
		local abilityId = PokemonData.getAbilityId(viewedPokemon.pokemonID, viewedPokemon.abilityNum)
		if abilityId ~= nil and abilityId ~= 0 then
			data.p.line2 = AbilityData.Abilities[abilityId].name
		end
	else
		local trackedAbilities = Tracker.getAbilities(viewedPokemon.pokemonID)
		if trackedAbilities[1].id ~= nil and trackedAbilities[1].id ~= 0 then
			data.p.line1 = AbilityData.Abilities[trackedAbilities[1].id].name .. " /"
			data.p.line2 = Constants.HIDDEN_INFO
		end
		if trackedAbilities[2].id ~= nil and trackedAbilities[2].id ~= 0 then
			data.p.line2 = AbilityData.Abilities[trackedAbilities[2].id].name
		end
	end

	-- Add: Move Header
	data.m.nextmoveheader, data.m.nextmovelevel, data.m.nextmovespacing = Utils.getMovesLearnedHeader(viewedPokemon.pokemonID, viewedPokemon.level)

	-- MOVES OF POKEMON (data.m)
	data.m.moves = { {}, {}, {}, {}, } -- four empty move placeholders

	local stars
	if data.x.viewingOwn then
		stars = { "", "", "", "" }
	else
		stars = Utils.calculateMoveStars(viewedPokemon.pokemonID, viewedPokemon.level)
	end

	local trackedMoves = Tracker.getMoves(viewedPokemon.pokemonID)
	for i = 1, 4, 1 do
		local moveToCopy = MoveData.BlankMove
		if data.x.viewingOwn then
			if viewedPokemon.moves[i] ~= nil and viewedPokemon.moves[i].id ~= 0 then
				moveToCopy = MoveData.Moves[viewedPokemon.moves[i].id]
			end
		elseif trackedMoves ~= nil then
			-- If the Pokemon doesn't belong to the player, pull move data from tracked data
			if trackedMoves[i] ~= nil and trackedMoves[i].id ~= 0 then
				moveToCopy = MoveData.Moves[trackedMoves[i].id]
			end
		end

		-- Add in Move data information about the Move
		data.m.moves[i] = {}
		for key, value in pairs(moveToCopy) do
			data.m.moves[i][key] = value
		end

		local move = data.m.moves[i]
		if move.pp == "0" then
			move.pp = Constants.BLANKLINE
		end
		if move.power == "0" then
			move.power = Constants.BLANKLINE
		end
		if move.accuracy == "0" then
			move.accuracy = Constants.BLANKLINE
		end

		move.starred = stars[i] ~= nil and stars[i] ~= ""

		-- Update: Specific Moves
		if move.name == "Hidden Power" and data.x.viewingOwn then
			move.type = Tracker.getHiddenPowerType()
			move.category = MoveData.TypeToCategory[move.type]
		elseif Options["Calculate variable damage"] then
			if move.name == "Weather Ball" then
				move.type, move.power = Utils.calculateWeatherBall(move.type, move.power)
				move.category = MoveData.TypeToCategory[move.type]
			elseif move.name == "Low Kick" and Battle.inBattle and opposingPokemon ~= nil then
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
				if move.name == "Flail" or move.name == "Reversal" then
					move.power = Utils.calculateLowHPBasedDamage(move.power, viewedPokemon.curHP, viewedPokemon.stats.hp)
				elseif move.name == "Eruption" or move.name == "Water Spout" then
					move.power = Utils.calculateHighHPBasedDamage(move.power, viewedPokemon.curHP, viewedPokemon.stats.hp)
				elseif move.name == "Return" or move.name == "Frustration" then
					move.power = Utils.calculateFriendshipBasedDamage(move.power, viewedPokemon.friendship)
				end
			end
		end

		-- Update: Actual PP Values
		if move.name ~= MoveData.BlankMove.name then
			if data.x.viewingOwn then
				move.pp = viewedPokemon.moves[i].pp
			elseif Options["Count enemy PP usage"] then
				-- Interate over tracked moves, since we don't know the full move list
				for _, actualMove in pairs(viewedPokemon.moves) do
					if tonumber(actualMove.id) == tonumber(move.id) then
						move.pp = actualMove.pp
					end
				end
			end
		end

		-- Update: If STAB
		if Battle.inBattle then
			local ownTypes = Program.getPokemonTypes(data.x.viewingOwn, Battle.isViewingLeft)
			move.isstab = Utils.isSTAB(move, move.type, ownTypes)
		end

		-- Update: Check if info should be hidden
		move.showeffective = true
		if Battle.isGhost then
			-- If fighting a ghost, hide effectiveness
			move.showeffective = false
		elseif not Options["Reveal info if randomized"] then
			-- If move info is randomized and the user doesn't want to know about it, hide it
			if data.x.viewingOwn then
				-- Don't show effectiveness of the player's moves if the enemy types are unknown
				move.showeffective = not PokemonData.IsRand.pokemonTypes
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
		move.showeffective = move.showeffective and Options["Show move effectiveness"] and Battle.inBattle

		-- Update: Calculate move effectiveness
		if move.showeffective then
			local enemyTypes = Program.getPokemonTypes(not data.x.viewingOwn, true)
			move.effectiveness = Utils.netEffectiveness(move, move.type, enemyTypes)
		else
			move.effectiveness = 1
		end
	end

	-- MISC DATA (data.x)
	data.x.healperc = math.min(9999, Tracker.Data.healingItems.healing or 0)
	data.x.healnum = math.min(99, Tracker.Data.healingItems.numHeals or 0)
	data.x.pcheals = Tracker.Data.centerHeals

	data.x.route = Constants.BLANKLINE
	if RouteData.hasRoute(Battle.CurrentRoute.mapId) then
		data.x.route = RouteData.Info[Battle.CurrentRoute.mapId].name or Constants.BLANKLINE
	end

	if Battle.inBattle then
		data.x.encounters = Tracker.getEncounters(viewedPokemon.pokemonID, Battle.isWildEncounter)
		if data.x.encounters > 999 then
			data.x.encounters = 999
		end
	else
		data.x.encounters = 0
	end

	return data
end
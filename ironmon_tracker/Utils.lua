Utils = {}

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1, d)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a, 0, 16)
	local c = Utils.getbits(a, 16, 16)
	return b + c
end

-- If the `condition` is true, the value in `T` is returned, else the value in `F` is returned
function Utils.inlineIf(condition, T, F)
	if condition then return T else return F end
end

-- Determine if the tracked Pokémon's moves are old and if so mark with a star
function Utils.calculateMoveStars(pokemonId, level)
	local stars = { "", "", "", "" }

	local pokemon = Tracker.Data.pokemon[pokemonId]
	if pokemon == nil or level == nil then
		return stars
	end

	-- For each move, count how many moves this Pokemon at this 'level' has learned already
	local movesLearnedSince = { 0, 0, 0, 0 }
	local allMoveLevels = PokemonData[pokemonId + 1].movelvls[GameSettings.versiongroup]
	for _, lv in pairs(allMoveLevels) do
		for i = 1, 4, 1 do
			if lv > pokemon.moves[i].level and lv <= level then
				movesLearnedSince[i] = movesLearnedSince[i] + 1
			end
		end
	end

	-- Determine which moves are the oldest, by ranking them against their levels learnt.
	local moveAgeRank = { 1, 1, 1, 1 }
	for moveIndex, move in pairs(pokemon.moves) do
		for moveIndexCompare, moveCompare in pairs(pokemon.moves) do
			if moveIndex ~= moveIndexCompare then
				if move.level > moveCompare.level then
					moveAgeRank[moveIndex] = moveAgeRank[moveIndex] + 1
				end
			end
		end
	end

	-- A move is only star'd if it was possible it has been forgotten
	for i = 1, 4, 1 do
		if pokemon.moves[i].level ~= 1 and movesLearnedSince[i] >= moveAgeRank[i] then
			stars[i] = "*"
		end
	end

	return stars
end

-- Move Header format: C/T (N), where C is moves learned so far, T is total number available to learn, and N is the next level the Pokemon learns a move
-- Example: 4/12 (25)
function Utils.getMovesLearnedHeader(pokemonId, level)
	if pokemonId == nil or level == nil then
		return "0/0 (0)"
	end

	local movesLearned = 0
	local nextMoveLevel = 0
	local foundNextMove = false

	local allMoveLevels = PokemonData[pokemonId + 1].movelvls[GameSettings.versiongroup]
	for _, lv in pairs(allMoveLevels) do
		if lv <= level then
			movesLearned = movesLearned + 1
		elseif not foundNextMove then
			nextMoveLevel = lv
			foundNextMove = true
		end
	end

	local header = movesLearned .. "/" .. table.getn(allMoveLevels)
	if foundNextMove then
		header = header .. " (" .. nextMoveLevel .. ")"
	end

	return header
end

function Utils.netEffectiveness(move, pkmnData)
	local effectiveness = 1.0

	-- TODO: Do we want to handle Hidden Power's varied type in this? We could analyze the IV of the Pokémon and determine the type...

	-- If move has no power, check for ineffectiveness by type first, then return 1.0 if ineffective cases not present
	if move.power == NOPOWER then
		if move.category ~= MoveCategories.STATUS then
			if move.type == PokemonTypes.NORMAL and (pkmnData.type[1] == PokemonTypes.GHOST or pkmnData.type[2] == PokemonTypes.GHOST) then
				return 0.0
			elseif move.type == PokemonTypes.FIGHTING and (pkmnData.type[1] == PokemonTypes.GHOST or pkmnData.type[2] == PokemonTypes.GHOST) then
				return 0.0
			elseif move.type == PokemonTypes.PSYCHIC and (pkmnData.type[1] == PokemonTypes.DARK or pkmnData.type[2] == PokemonTypes.DARK) then
				return 0.0
			elseif move.type == PokemonTypes.GROUND and (pkmnData.type[1] == PokemonTypes.FLYING or pkmnData.type[2] == PokemonTypes.FLYING) then
				return 0.0
			elseif move.type == PokemonTypes.GHOST and (pkmnData.type[1] == PokemonTypes.NORMAL or pkmnData.type[2] == PokemonTypes.NORMAL) then
				return 0.0
			end
		end
		return 1.0
	end

	if move["name"] == "Future Sight" or move["name"] == "Doom Desire" then
		return 1.0
	end

	for _, type in ipairs(pkmnData["type"]) do
		local moveType = move["type"]
		if move["name"] == "Hidden Power" and Tracker.Data.selectedPlayer == 1 then
			moveType = Tracker.Data.currentHiddenPowerType
		end
		if moveType ~= "---" then
			if EffectiveData[moveType][type] ~= nil then
				effectiveness = effectiveness * EffectiveData[moveType][type]
			end
		end
	end
	return effectiveness
end

function Utils.isSTAB(move, pkmnData)
	for _, type in ipairs(pkmnData["type"]) do
		local moveType = move.type
		if move.name == "Hidden Power" and Tracker.Data.selectedPlayer == 1 then
			moveType = Tracker.Data.currentHiddenPowerType
		end
		if moveType == type then
			return true
		end
	end
	return false
end

-- For Low Kick & Grass Knot. Weight in kg. Bounds are inclusive per decompiled code.
function Utils.calculateWeightBasedDamage(weight)
	if weight < 10.0 then
		return "20"
	elseif weight < 25.0 then
		return "40"
	elseif weight < 50.0 then
		return "60"
	elseif weight < 100.0 then
		return "80"
	elseif weight < 200.0 then
		return "100"
	else
		return "120"
	end
end

-- For Flail & Reversal
function Utils.calculateLowHPBasedDamage(currentHP, maxHP)
	local percentHP = (currentHP / maxHP) * 100
	if percentHP < 4.17 then
		return "200"
	elseif percentHP < 10.42 then
		return "150"
	elseif percentHP < 20.83 then
		return "100"
	elseif percentHP < 35.42 then
		return "80"
	elseif percentHP < 68.75 then
		return "40"
	else
		return "20"
	end
end

-- For Water Spout & Eruption
function Utils.calculateHighHPBasedDamage(currentHP, maxHP)
	local basePower = (150 * currentHP) / maxHP
	if basePower < 1 then 
		basePower = 1 
	end
	local roundedPower = math.floor(basePower + 0.5)
	return tostring(roundedPower)
end

function Utils.playerHasMove(moveName)
	local pokemon = Tracker.Data.selectedPokemon 
	local currentMoves = {pokemon["move1"],pokemon["move2"],pokemon["move3"],pokemon["move4"]}
	for index, move in pairs(currentMoves) do
		if MoveData[move+1].name == moveName then
			return true
		end
	end
	return false
end

-- Returns the text color for PC heal tracking
function Utils.getCenterHealColor()
	local currentCount = Tracker.Data.centerHeals
	if Options["PC heals count downward"] then
		-- Counting downwards
		if currentCount < 1 then
			return GraphicConstants.THEMECOLORS["Negative text"]
		elseif currentCount < 6 then
			return GraphicConstants.THEMECOLORS["Intermediate text"]
		else
			return GraphicConstants.THEMECOLORS["Default text"]
		end
	else
		-- Counting upwards
		if currentCount < 5 then
			return GraphicConstants.THEMECOLORS["Default text"]
		elseif currentCount < 10 then
			return GraphicConstants.THEMECOLORS["Intermediate text"]
		else
			return GraphicConstants.THEMECOLORS["Negative text"]
		end
	end
end

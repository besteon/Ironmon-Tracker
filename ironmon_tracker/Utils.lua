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
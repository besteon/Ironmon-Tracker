Scorer = {
	-- Coefficients used to determine a Pokemon's score
	BST_COEFF = 2.0,
	TYPE_COEFF = 1.0,
	MOVE_COEFF = 2.0,
}

--- Get the score of a foe Pokemon mainly from BST, type and moves
--- @param pokeId integer ID of Pokemon
--- @return number score
function Scorer.getFoeScore(pokeId)
	local score = 0
	local pokemon = PokemonData.Pokemon[pokeId]

	-- Get BST score
	local bstScore = (pokemon.bst/680.0)
	print("BST: " .. tostring(bstScore))

	-- Get Type score
	local typeScore = 0.0
	local index = 0
	local effectiveness = PokemonData.getEffectiveness(pokeId)
	for _ in pairs(effectiveness[0]) do
		typeScore = typeScore + 1.0
		index = index + 1
	end
	for _ in pairs(effectiveness[0.25]) do
		typeScore = typeScore + 0.75
		index = index + 1
	end
	for _ in pairs(effectiveness[0.5]) do
		typeScore = typeScore + 0.5
		index = index + 1
	end
	for _ in pairs(effectiveness[2]) do
		typeScore = typeScore + 0.25
		index = index + 1
	end
	for _ in pairs(effectiveness[4]) do
		-- 4x weaknesses are punitive
		typeScore = typeScore - 0.25
		index = index + 1
	end
	if index ~= 0 then
		typeScore = typeScore / index
	end
	print("Type: " .. tostring(typeScore))

	-- Get Move Score
	local moveScore = 0
	local moves = Tracker.getMoves(pokeId)
	local moveIndex = 0
	if type(moves[1]) ~= "table" or not MoveData.isValid(moves[1].id) then
		for _,move in pairs(moves) do
			if move.accuracy == "0" or move.power == "0" then
				local stab = move.type == pokemon.types[1] or move.type == pokemon.types[2]
				local powerVal = tonumber(move.power) * tonumber(move.accuracy) / 10000.0
				if stab then
					powerVal = powerVal * 1.5
				end
				moveScore = moveScore + powerVal
				moveIndex = moveIndex + 1
			end
		end
		if moveIndex > 1 then
			moveScore = moveScore / moveIndex
		end
	end
	print("Move: " .. tostring(moveScore))
	
	-- Compute global score
	score = Scorer.BST_COEFF * bstScore + Scorer.TYPE_COEFF * typeScore + Scorer.MOVE_COEFF * moveScore
	score = score / (Scorer.BST_COEFF + Scorer.TYPE_COEFF + Scorer.MOVE_COEFF)
	print("Global: " .. tostring(score))

	return score
end

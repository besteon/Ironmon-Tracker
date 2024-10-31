Scorer = {
	-- Coefficients used to determine a Pokemon's score
	BST_COEFF = 2.0,

}

--- Get the score of a known Pokemon mainly from BST, stat repartition, type and moves
--- @param pokeId integer ID of Pokemon
--- @return number score
function Scorer.getPokemonScore(pokeId)
	local score = 0
	local pokemon = PokemonData.Pokemon[pokeId]

	-- Get BST score
	local bstScore = (pokemon.bst/680.0)

	-- Get Type score
	PokemonData.getEffectiveness(pokeId)

	-- Compute global score

	return score
end
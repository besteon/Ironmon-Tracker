--- BATTLE SIMULATOR
math.randomseed(os.clock()*100000000000)

-- Init values
local ownLvl = 10
local ownPoke = PokemonData.Pokemon[math.random(1, #PokemonData.Pokemon + 1)]
local ownMoves = {
	MoveData.Moves[math.random(1, #MoveData.Moves + 1)],
	MoveData.Moves[math.random(1, #MoveData.Moves + 1)],
	MoveData.Moves[math.random(1, #MoveData.Moves + 1)],
	MoveData.Moves[math.random(1, #MoveData.Moves + 1)]
}
local ownRandoms = {
	math.random(0, ownPoke.bst),
	math.random(0, ownPoke.bst),
	math.random(0, ownPoke.bst),
	math.random(0, ownPoke.bst),
	math.random(0, ownPoke.bst)
}
table.sort(ownRandoms)
local ownDistrib = {
	ownRandoms[1],
	ownRandoms[2] - ownRandoms[1],
	ownRandoms[3] - ownRandoms[2],
	ownRandoms[4] - ownRandoms[3],
	ownRandoms[5] - ownRandoms[4],
	ownPoke.bst - ownRandoms[5]
}
local ownStats = {
	["hp"] = math.floor(2.0*ownDistrib[1]*ownLvl/100.0 + ownLvl + 10),
	["atk"] = math.floor(2.0*ownDistrib[2]*ownLvl/100.0 + 5),
	["spa"] = math.floor(2.0*ownDistrib[3]*ownLvl/100.0 + 5),
	["def"] = math.floor(2.0*ownDistrib[4]*ownLvl/100.0 + 5),
	["spd"] = math.floor(2.0*ownDistrib[5]*ownLvl/100.0 + 5),
	["spe"] = math.floor(2.0*ownDistrib[6]*ownLvl/100.0 + 5),
}

local foeLvl = 10
local foePoke = PokemonData.Pokemon[math.random(1, #PokemonData.Pokemon + 1)]



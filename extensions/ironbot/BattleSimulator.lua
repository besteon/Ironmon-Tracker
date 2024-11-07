require "ironmon_tracker.Main"
require "ironmon_tracker.Constants"
require "ironmon_tracker.data.PokemonData"
require "ironmon_tracker.data.MoveData"

-------------------------------------------------------------------------------
--- CONSTANTS -----------------------------------------------------------------

-- RNG Seed
math.randomseed(math.floor(os.clock()*1000000000))

-- Pokemon Types Enumeration
local types = {
	-- GEN 1
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON, PokemonData.Types.GROUND},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON, PokemonData.Types.GROUND},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.POISON, PokemonData.Types.FLYING},
	{PokemonData.Types.POISON, PokemonData.Types.FLYING},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.BUG, PokemonData.Types.GRASS},
	{PokemonData.Types.BUG, PokemonData.Types.GRASS},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.FIGHTING},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.WATER, PokemonData.Types.POISON},
	{PokemonData.Types.WATER, PokemonData.Types.POISON},
	{PokemonData.Types.ROCK, PokemonData.Types.GROUND},
	{PokemonData.Types.ROCK, PokemonData.Types.GROUND},
	{PokemonData.Types.ROCK, PokemonData.Types.GROUND},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.WATER, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.WATER, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ELECTRIC, PokemonData.Types.STEEL},
	{PokemonData.Types.ELECTRIC, PokemonData.Types.STEEL},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.ICE},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.ICE},
	{PokemonData.Types.GHOST, PokemonData.Types.POISON},
	{PokemonData.Types.GHOST, PokemonData.Types.POISON},
	{PokemonData.Types.GHOST, PokemonData.Types.POISON},
	{PokemonData.Types.ROCK, PokemonData.Types.GROUND},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.GRASS, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.GRASS, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON},
	{PokemonData.Types.GROUND, PokemonData.Types.ROCK},
	{PokemonData.Types.GROUND, PokemonData.Types.ROCK},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.ICE, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.BUG},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER, PokemonData.Types.ICE},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.ROCK, PokemonData.Types.WATER},
	{PokemonData.Types.ROCK, PokemonData.Types.WATER},
	{PokemonData.Types.ROCK, PokemonData.Types.WATER},
	{PokemonData.Types.ROCK, PokemonData.Types.WATER},
	{PokemonData.Types.ROCK, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.ICE, PokemonData.Types.FLYING},
	{PokemonData.Types.ELECTRIC, PokemonData.Types.FLYING},
	{PokemonData.Types.FIRE, PokemonData.Types.FLYING},
	{PokemonData.Types.DRAGON},
	{PokemonData.Types.DRAGON},
	{PokemonData.Types.DRAGON, PokemonData.Types.FLYING},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	-- GEN 2
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.POISON, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER, PokemonData.Types.ELECTRIC},
	{PokemonData.Types.WATER, PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING},
	{PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.ROCK},
	{PokemonData.Types.WATER},
	{PokemonData.Types.GRASS, PokemonData.Types.FLYING},
	{PokemonData.Types.GRASS, PokemonData.Types.FLYING},
	{PokemonData.Types.GRASS, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER, PokemonData.Types.GROUND},
	{PokemonData.Types.WATER, PokemonData.Types.GROUND},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.DARK},
	{PokemonData.Types.DARK, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.GHOST},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.NORMAL, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG, PokemonData.Types.STEEL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.GROUND, PokemonData.Types.FLYING},
	{PokemonData.Types.STEEL, PokemonData.Types.GROUND},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER, PokemonData.Types.POISON},
	{PokemonData.Types.BUG, PokemonData.Types.STEEL},
	{PokemonData.Types.BUG, PokemonData.Types.ROCK},
	{PokemonData.Types.BUG, PokemonData.Types.FIGHTING},
	{PokemonData.Types.DARK, PokemonData.Types.ICE},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE, PokemonData.Types.ROCK},
	{PokemonData.Types.ICE, PokemonData.Types.GROUND},
	{PokemonData.Types.ICE, PokemonData.Types.GROUND},
	{PokemonData.Types.WATER, PokemonData.Types.ROCK},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.ICE, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER, PokemonData.Types.FLYING},
	{PokemonData.Types.STEEL, PokemonData.Types.ROCK},
	{PokemonData.Types.DARK, PokemonData.Types.FIRE},
	{PokemonData.Types.DARK, PokemonData.Types.FIRE},
	{PokemonData.Types.WATER, PokemonData.Types.DRAGON},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.ICE, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.WATER},
	{PokemonData.Types.ROCK, PokemonData.Types.GROUND},
	{PokemonData.Types.ROCK, PokemonData.Types.GROUND},
	{PokemonData.Types.ROCK, PokemonData.Types.DARK},
	{PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING},
	{PokemonData.Types.FIRE, PokemonData.Types.FLYING},
	{PokemonData.Types.PSYCHIC, PokemonData.Types.GRASS},
	-- Gen 2 to 3 Gap
	{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},
	-- GEN 3
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.FIRE, PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIRE, PokemonData.Types.FIGHTING},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.GROUND},
	{PokemonData.Types.WATER, PokemonData.Types.GROUND},
	{PokemonData.Types.DARK},
	{PokemonData.Types.DARK},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG, PokemonData.Types.POISON},
	{PokemonData.Types.WATER, PokemonData.Types.GRASS},
	{PokemonData.Types.WATER, PokemonData.Types.GRASS},
	{PokemonData.Types.WATER, PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS, PokemonData.Types.DARK},
	{PokemonData.Types.GRASS, PokemonData.Types.DARK},
	{PokemonData.Types.BUG, PokemonData.Types.GROUND},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG, PokemonData.Types.GHOST},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS, PokemonData.Types.FIGHTING},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER, PokemonData.Types.FLYING},
	{PokemonData.Types.BUG, PokemonData.Types.WATER},
	{PokemonData.Types.BUG, PokemonData.Types.FLYING},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.GROUND, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.GROUND, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ROCK},
	{PokemonData.Types.FIRE},
	{PokemonData.Types.GHOST, PokemonData.Types.DARK},
	{PokemonData.Types.WATER, PokemonData.Types.GROUND},
	{PokemonData.Types.WATER, PokemonData.Types.GROUND},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.DARK},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER, PokemonData.Types.DARK},
	{PokemonData.Types.WATER, PokemonData.Types.DARK},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.GROUND, PokemonData.Types.DRAGON},
	{PokemonData.Types.GROUND, PokemonData.Types.DRAGON},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.FIGHTING},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.GROUND, PokemonData.Types.FIRE},
	{PokemonData.Types.GROUND, PokemonData.Types.FIRE},
	{PokemonData.Types.WATER, PokemonData.Types.ICE},
	{PokemonData.Types.WATER, PokemonData.Types.ICE},
	{PokemonData.Types.WATER, PokemonData.Types.ICE},
	{PokemonData.Types.GRASS},
	{PokemonData.Types.GRASS, PokemonData.Types.DARK},
	{PokemonData.Types.ICE},
	{PokemonData.Types.ICE},
	{PokemonData.Types.ROCK, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ROCK, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.ELECTRIC},
	{PokemonData.Types.STEEL},
	{PokemonData.Types.FIGHTING, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.FIGHTING, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.NORMAL, PokemonData.Types.FLYING},
	{PokemonData.Types.DRAGON, PokemonData.Types.FLYING},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.GHOST},
	{PokemonData.Types.GHOST},
	{PokemonData.Types.GRASS, PokemonData.Types.POISON},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.POISON},
	{PokemonData.Types.POISON},
	{PokemonData.Types.GRASS, PokemonData.Types.FLYING},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.WATER},
	{PokemonData.Types.DARK},
	{PokemonData.Types.GHOST},
	{PokemonData.Types.GHOST},
	{PokemonData.Types.POISON},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.WATER, PokemonData.Types.ROCK},
	{PokemonData.Types.ROCK, PokemonData.Types.STEEL},
	{PokemonData.Types.ROCK, PokemonData.Types.STEEL},
	{PokemonData.Types.ROCK, PokemonData.Types.STEEL},
	{PokemonData.Types.NORMAL},
	{PokemonData.Types.BUG},
	{PokemonData.Types.BUG},
	{PokemonData.Types.ROCK, PokemonData.Types.GRASS},
	{PokemonData.Types.ROCK, PokemonData.Types.GRASS},
	{PokemonData.Types.ROCK, PokemonData.Types.BUG},
	{PokemonData.Types.ROCK, PokemonData.Types.BUG},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.DRAGON},
	{PokemonData.Types.DRAGON},
	{PokemonData.Types.DRAGON, PokemonData.Types.FLYING},
	{PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.ROCK},
	{PokemonData.Types.ICE},
	{PokemonData.Types.STEEL},
	{PokemonData.Types.WATER},
	{PokemonData.Types.GROUND},
	{PokemonData.Types.DRAGON, PokemonData.Types.FLYING},
	{PokemonData.Types.DRAGON, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.DRAGON, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
	{PokemonData.Types.PSYCHIC},
}

-- Bot
local bot = require "extensions.IronBot"()

-------------------------------------------------------------------------------
--- FUNCTIONS -----------------------------------------------------------------

--- Returns a randomly generated Pokemon (with random stats)
--- @param lvl integer The level of the Pokemon
--- @return table pokemon
local function getRandomPokemon(lvl)
	local id = math.random(1, #PokemonData.Pokemon + 1)
	local poke = PokemonData.Pokemon[id]
	while poke == nil or poke.name == "none" do
		id = math.random(1, #PokemonData.Pokemon + 1)
		poke = PokemonData.Pokemon[id]
	end
	local randoms = {
		math.random(0, poke.bst),
		math.random(0, poke.bst),
		math.random(0, poke.bst),
		math.random(0, poke.bst),
		math.random(0, poke.bst)
	}
	table.sort(randoms)
	local ownDistrib = {
		randoms[1],
		randoms[2] - randoms[1],
		randoms[3] - randoms[2],
		randoms[4] - randoms[3],
		randoms[5] - randoms[4],
		poke.bst - randoms[5]
	}
	poke["hp"] = math.floor(2.0*ownDistrib[1]*lvl/100.0 + lvl + 10)
	poke["atk"] = math.floor(2.0*ownDistrib[2]*lvl/100.0 + 5)
	poke["spa"] = math.floor(2.0*ownDistrib[3]*lvl/100.0 + 5)
	poke["def"] = math.floor(2.0*ownDistrib[4]*lvl/100.0 + 5)
	poke["spd"] = math.floor(2.0*ownDistrib[5]*lvl/100.0 + 5)
	poke["spe"] = math.floor(2.0*ownDistrib[6]*lvl/100.0 + 5)
	poke.id = id
	poke.types = types[id]
	return poke
end

--- Returns a random moveset of 4 random moves
--- @return table moveset
local function getRandomMoveSet()
	return {
		MoveData.Moves[math.random(1, #MoveData.Moves + 1)],
		MoveData.Moves[math.random(1, #MoveData.Moves + 1)],
		MoveData.Moves[math.random(1, #MoveData.Moves + 1)],
		MoveData.Moves[math.random(1, #MoveData.Moves + 1)]
	}
end

--- Adds space padding to string up to the parametered length
--- @param str string the string to pad
--- @param length integer the length to pad up to
--- @return string paddedStr the padded string
local function padTo(str, length)
	local paddedStr = str
	while string.len(paddedStr) < length do
		paddedStr = paddedStr .. " "
	end
	return paddedStr
end

--- Prints information about a Pokemon
--- @param poke table the pokemon data
--- @param lvl integer the level of the pokemon
local function printPokemonInfo(poke, lvl)
	local typesStr = poke.types[1]
	if #poke.types > 1 then
		typesStr = typesStr .. " " .. poke.types[2]
	end
	print(poke.name .. "(" .. tostring(poke.id) .. ")" .. " lvl" .. tostring(lvl) .. " BST:" .. tostring(poke.bst))
	print("Types: " .. typesStr)
	print("--- STATS -------------")
	print("HP:" .. padTo(poke["hp"],  3) .. "  ATK:" .. padTo(poke["atk"], 3) .. " DEF:" .. padTo(poke["def"], 3))
	print("SPA:" .. padTo(poke["spa"], 3) .. " SPD:" .. padTo(poke["spd"], 3) .. " SPE:" .. padTo(poke["spe"], 3))
end

--- Prints moves and their score against a foe
--- @param ownData table
--- @param foeData table
local function printScoredMoves(ownData, foeData)
	local maxMoveIndex, moveScores = bot.getBestMove(ownData, foeData)
	print("--- MOVES -------------")
	for i=1,#ownData.m.moves do
		print(tostring(i) .. "." .. padTo(ownData.m.moves[i].name, 12) .. "(" .. string.sub(ownData.m.moves[i].category, 0, 1) .. ")" ..
		" POW:" .. padTo(ownData.m.moves[i].power, 3) .. " ACC:" .. padTo(ownData.m.moves[i].accuracy, 3) ..
		" PP:" .. padTo(ownData.m.moves[i].pp, 2) .. " SCORE:" .. tostring(moveScores[i]))
	end
	print("Move chosen: " .. ownData.m.moves[maxMoveIndex].name)
end

-------------------------------------------------------------------------------
--- MAIN ----------------------------------------------------------------------

-- Init values
local ownLvl = 10
local ownPoke = getRandomPokemon(ownLvl)
local ownMoves = getRandomMoveSet()
local foeLvl = 10
local foePoke = getRandomPokemon(foeLvl)
local foeMoves = getRandomMoveSet()
local ownData = {
	m = {
		moves = ownMoves,
	},
	p = ownPoke,
}
local foeData = {
	m = {
		moves = foeMoves,
	},
	p = foePoke,
}

-- Print info
print("----------- OWN -----------")
printPokemonInfo(ownPoke, ownLvl)
printScoredMoves(ownData, foeData)
print()
print("----------- FOE -----------")
printPokemonInfo(foePoke, foeLvl)
print()


PokemonData = {}

-- Enumerated constants that defines the various types a Pokémon and its Moves are
PokemonData.Types = {
		NORMAL = "normal",
		FIGHTING = "fighting",
		FLYING = "flying",
		POISON = "poison",
		GROUND = "ground",
		ROCK = "rock",
		BUG = "bug",
		GHOST = "ghost",
		STEEL = "steel",
		FIRE = "fire",
		WATER = "water",
		GRASS = "grass",
		ELECTRIC = "electric",
		PSYCHIC = "psychic",
		ICE = "ice",
		DRAGON = "dragon",
		DARK = "dark",
		FAIRY = "fairy", -- Expect this to be unused in Gen 1-5
		UNKNOWN = "unknown", -- For the move "Curse" in Gen 2-4
		EMPTY = "", -- No second type for this Pokémon or an empty field
}

-- Enumerated constants that defines various evolution possibilities
-- This enum does NOT include levels for evolution, only stones, friendship, no evolution, etc.
PokemonData.Evolutions = {
	NONE = Constants.BLANKLINE, -- This Pokémon does not evolve.
	FRIEND = "FRND", -- High friendship
	STONES = "STONE", -- Various evolution stone items
	THUNDER = "THNDR", -- Thunder stone item
	FIRE = "FIRE", -- Fire stone item
	WATER = "WATER", -- Water stone item
	MOON = "MOON", -- Moon stone item
	LEAF = "LEAF", -- Leaf stone item
	SUN = "SUN", -- Sun stone item
	LEAF_SUN = "LF/SN", -- Leaf or Sun stone items
}

PokemonData.BlankPokemon = {
	pokemonID = 0,
	name = Constants.BLANKLINE,
	type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
	evolution = PokemonData.Evolutions.NONE,
	bst = Constants.BLANKLINE,
	movelvls = { {}, {} },
	weight = 0.0,
}

--[[
Data for each Pokémon (Gen 3) - Sourced from Bulbapedia
Format for an entry:
	name: string -> Name of the Pokémon as it appears in game
	type: {string, string} -> Each Pokémon can have one or two types, using the PokemonData.Types enum to alias the strings
	evolution: string -> Displays the level, item, or other requirement a Pokémon needs to evolve
	bst: string -> A sum of the base stats of the Pokémon
	movelvls: {{integer list}, {integer list}} -> A pair of tables (1:RSE/2:FRLG) declaring the levels at which a Pokémon learns new moves or an empty list means it learns nothing
	weight: pokemon's weight in kg (mainly used for Low Kick calculations)
]]
PokemonData.Pokemon = {
	{
		name = "Bulbasaur",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "16",
		bst = "318",
		movelvls = { { 7, 10, 15, 15, 20, 25, 32, 39, 46 }, { 7, 10, 15, 15, 20, 25, 32, 39, 46 } },
		weight = 6.9
	},
	{
		name = "Ivysaur",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "32",
		bst = "405",
		movelvls = { { 7, 10, 15, 15, 22, 29, 38, 47, 56 }, { 7, 10, 15, 15, 22, 29, 38, 47, 56 } },
		weight = 13.0
	},
	{
		name = "Venusaur",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 7, 10, 15, 15, 22, 29, 41, 53, 65 }, { 7, 10, 15, 15, 22, 29, 41, 53, 65 } },
		weight = 100.0
	},
	{
		name = "Charmander",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "309",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.5
	},
	{
		name = "Charmeleon",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 7, 13, 20, 27, 34, 41, 48, 55 }, { 7, 13, 20, 27, 34, 41, 48, 55 } },
		weight = 19.0
	},
	{
		name = "Charizard",
		type = { PokemonData.Types.FIRE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "534",
		movelvls = { { 7, 13, 20, 27, 34, 36, 44, 54, 64 }, { 7, 13, 20, 27, 34, 36, 44, 54, 64 } },
		weight = 90.5
	},
	{
		name = "Squirtle",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "314",
		movelvls = { { 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 9.0
	},
	{
		name = "Wartortle",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 7, 10, 13, 19, 25, 31, 37, 45, 53 }, { 7, 10, 13, 19, 25, 31, 37, 45, 53 } },
		weight = 22.5
	},
	{
		name = "Blastoise",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		movelvls = { { 7, 10, 13, 19, 25, 31, 42, 55, 68 }, { 7, 10, 13, 19, 25, 31, 42, 55, 68 } },
		weight = 85.5
	},
	{
		name = "Caterpie",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "7",
		bst = "195",
		movelvls = { {}, {} },
		weight = 2.9
	},
	{
		name = "Metapod",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = 9.9
	},
	{
		name = "Butterfree",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		movelvls = { { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 }, { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 } },
		weight = 32.0
	},
	{
		name = "Weedle",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "7",
		bst = "195",
		movelvls = { {}, {} },
		weight = 3.2
	},
	{
		name = "Kakuna",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beedrill",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45 }, { 10, 15, 20, 25, 30, 35, 40, 45 } },
		weight = 29.5
	},
	{
		name = "Pidgey",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "18",
		bst = "251",
		movelvls = { { 9, 13, 19, 25, 31, 39, 47 }, { 9, 13, 19, 25, 31, 39, 47 } },
		weight = 1.8
	},
	{
		name = "Pidgeotto",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "36",
		bst = "349",
		movelvls = { { 9, 13, 20, 27, 34, 43, 52 }, { 9, 13, 20, 27, 34, 43, 52 } },
		weight = 30.0
	},
	{
		name = "Pidgeot",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "469",
		movelvls = { { 9, 13, 20, 27, 34, 48, 62 }, { 9, 13, 20, 27, 34, 48, 62 } },
		weight = 39.5
	},
	{
		name = "Rattata",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "253",
		movelvls = { { 7, 13, 20, 27, 34, 41 }, { 7, 13, 20, 27, 34, 41 } },
		weight = 3.5
	},
	{
		name = "Raticate",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "413",
		movelvls = { { 7, 13, 20, 30, 40, 50 }, { 7, 13, 20, 30, 40, 50 } },
		weight = 18.5
	},
	{
		name = "Spearow",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "20",
		bst = "262",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.0
	},
	{
		name = "Fearow",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "442",
		movelvls = { { 7, 13, 26, 32, 40, 47 }, { 7, 13, 26, 32, 40, 47 } },
		weight = 38.0
	},
	{
		name = "Ekans",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "22",
		bst = "288",
		movelvls = { { 8, 13, 20, 25, 32, 37, 37, 37, 44 }, { 8, 13, 20, 25, 32, 37, 37, 37, 44 } },
		weight = 6.9
	},
	{
		name = "Arbok",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "438",
		movelvls = { { 8, 13, 20, 28, 38, 46, 46, 46, 56 }, { 8, 13, 20, 28, 38, 46, 46, 46, 56 } },
		weight = 65.0
	},
	{
		name = "Pikachu",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.THUNDER,
		bst = "300",
		movelvls = { { 6, 8, 11, 15, 20, 26, 33, 41, 50 }, { 6, 8, 11, 15, 20, 26, 33, 41, 50 } },
		weight = 6.0
	},
	{
		name = "Raichu",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		movelvls = { {}, {} },
		weight = 30.0
	},
	{
		name = "Sandshrew",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "22",
		bst = "300",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 12.0
	},
	{
		name = "Sandslash",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		movelvls = { { 6, 11, 17, 24, 33, 42, 52, 62 }, { 6, 11, 17, 24, 33, 42, 52, 62 } },
		weight = 29.5
	},
	{
		name = "Nidoran F",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "275",
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 7.0
	},
	{
		name = "Nidorina",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "365",
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 20.0
	},
	{
		name = "Nidoqueen",
		type = { PokemonData.Types.POISON, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 23 }, { 22, 43 } },
		weight = 60.0
	},
	{
		name = "Nidoran M",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "273",
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 9.0
	},
	{
		name = "Nidorino",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "365",
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 19.5
	},
	{
		name = "Nidoking",
		type = { PokemonData.Types.POISON, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 23 }, { 22, 43 } },
		weight = 62.0
	},
	{
		name = "Clefairy",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "323",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 7.5
	},
	{
		name = "Clefable",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "473",
		movelvls = { {}, {} },
		weight = 40.0
	},
	{
		name = "Vulpix",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FIRE,
		bst = "299",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 9.9
	},
	{
		name = "Ninetales",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "505",
		movelvls = { { 45 }, { 45 } },
		weight = 19.9
	},
	{
		name = "Jigglypuff",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "270",
		movelvls = { { 9, 14, 19, 24, 29, 34, 39, 44, 49 }, { 9, 14, 19, 24, 29, 34, 39, 44, 49 } },
		weight = 5.5
	},
	{
		name = "Wigglytuff",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		movelvls = { {}, {} },
		weight = 12.0
	},
	{
		name = "Zubat",
		type = { PokemonData.Types.POISON, PokemonData.Types.FLYING },
		evolution = "22",
		bst = "245",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 7.5
	},
	{
		name = "Golbat",
		type = { PokemonData.Types.POISON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "455",
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 55.0
	},
	{
		name = "Oddish",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "21",
		bst = "320",
		movelvls = { { 7, 14, 16, 18, 23, 32, 39 }, { 7, 14, 16, 18, 23, 32, 39 } },
		weight = 5.4
	},
	{
		name = "Gloom",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.LEAF_SUN,
		bst = "395",
		movelvls = { { 7, 14, 16, 18, 24, 35, 44 }, { 7, 14, 16, 18, 24, 35, 44 } },
		weight = 8.6
	},
	{
		name = "Vileplume",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { { 44 }, { 44 } },
		weight = 18.6
	},
	{
		name = "Paras",
		type = { PokemonData.Types.BUG, PokemonData.Types.GRASS },
		evolution = "24",
		bst = "285",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 5.4
	},
	{
		name = "Parasect",
		type = { PokemonData.Types.BUG, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 29.5
	},
	{
		name = "Venonat",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "31",
		bst = "305",
		movelvls = { { 9, 17, 20, 25, 28, 33, 36, 41 }, { 9, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 30.0
	},
	{
		name = "Venomoth",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		movelvls = { { 9, 17, 20, 25, 28, 31, 36, 42, 52 }, { 9, 17, 20, 25, 28, 31, 36, 42, 52 } },
		weight = 12.5
	},
	{
		name = "Diglett",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "265",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 21, 25, 33, 41, 49 } },
		weight = 0.8
	},
	{
		name = "Dugtrio",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { { 9, 17, 25, 26, 38, 51, 64 }, { 9, 17, 21, 25, 26, 38, 51, 64 } },
		weight = 33.3
	},
	{
		name = "Meowth",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "290",
		movelvls = { { 11, 20, 28, 35, 41, 46, 50 }, { 10, 18, 25, 31, 36, 40, 43, 45 } },
		weight = 4.2
	},
	{
		name = "Persian",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		movelvls = { { 11, 20, 29, 38, 46, 53, 59 }, { 10, 18, 25, 34, 42, 49, 55, 61 } },
		weight = 32.0
	},
	{
		name = "Psyduck",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "33",
		bst = "320",
		movelvls = { { 10, 16, 23, 31, 40, 50 }, { 10, 16, 23, 31, 40, 50 } },
		weight = 19.6
	},
	{
		name = "Golduck",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 10, 16, 23, 31, 44, 58 }, { 10, 16, 23, 31, 44, 58 } },
		weight = 76.6
	},
	{
		name = "Mankey",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "305",
		movelvls = { { 9, 15, 21, 27, 33, 39, 45, 51 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 28.0
	},
	{
		name = "Primeape",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 9, 15, 21, 27, 28, 36, 45, 54, 63 }, { 6, 11, 16, 21, 26, 28, 35, 44, 53, 62 } },
		weight = 32.0
	},
	{
		name = "Growlithe",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FIRE,
		bst = "350",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 19.0
	},
	{
		name = "Arcanine",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "555",
		movelvls = { { 49 }, { 49 } },
		weight = 155.0
	},
	{
		name = "Poliwag",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "25",
		bst = "300",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 12.4
	},
	{
		name = "Poliwhirl",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "37/WTR", -- Level 37 replaces trade evolution for Politoed
		bst = "385",
		movelvls = { { 7, 13, 19, 27, 35, 43, 51 }, { 7, 13, 19, 27, 35, 43, 51 } },
		weight = 20.0
	},
	{
		name = "Poliwrath",
		type = { PokemonData.Types.WATER, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 54.0
	},
	{
		name = "Abra",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { {}, {} },
		weight = 19.5
	},
	{
		name = "Kadabra",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "400",
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 56.5
	},
	{
		name = "Alakazam",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 48.0
	},
	{
		name = "Machop",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "305",
		movelvls = { { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 }, { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 } },
		weight = 19.5
	},
	{
		name = "Machoke",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "405",
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 70.5
	},
	{
		name = "Machamp",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "505",
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 130.0
	},
	{
		name = "Bellsprout",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "21",
		bst = "300",
		movelvls = { { 6, 11, 15, 17, 19, 23, 30, 37, 45 }, { 6, 11, 15, 17, 19, 23, 30, 37, 45 } },
		weight = 4.0
	},
	{
		name = "Weepinbell",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.LEAF,
		bst = "390",
		movelvls = { { 6, 11, 15, 17, 19, 24, 33, 42, 54 }, { 6, 11, 15, 17, 19, 24, 33, 42, 54 } },
		weight = 6.4
	},
	{
		name = "Victreebel",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { {}, {} },
		weight = 15.5
	},
	{
		name = "Tentacool",
		type = { PokemonData.Types.WATER, PokemonData.Types.POISON },
		evolution = "30",
		bst = "335",
		movelvls = { { 6, 12, 19, 25, 30, 36, 43, 49 }, { 6, 12, 19, 25, 30, 36, 43, 49 } },
		weight = 45.5
	},
	{
		name = "Tentacruel",
		type = { PokemonData.Types.WATER, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "515",
		movelvls = { { 6, 12, 19, 25, 30, 38, 47, 55 }, { 6, 12, 19, 25, 30, 38, 47, 55 } },
		weight = 55.0
	},
	{
		name = "Geodude",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "25",
		bst = "300",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 20.0
	},
	{
		name = "Graveler",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "390",
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 105.0
	},
	{
		name = "Golem",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 300.0
	},
	{
		name = "Ponyta",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "40",
		bst = "410",
		movelvls = { { 9, 14, 19, 25, 31, 38, 45, 53 }, { 9, 14, 19, 25, 31, 38, 45, 53 } },
		weight = 30.0
	},
	{
		name = "Rapidash",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 9, 14, 19, 25, 31, 38, 40, 50, 63 }, { 9, 14, 19, 25, 31, 38, 40, 50, 63 } },
		weight = 95.0
	},
	{
		name = "Slowpoke",
		type = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = "37/WTR", -- Water stone replaces trade evolution to Slowking
		bst = "315",
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 36.0
	},
	{
		name = "Slowbro",
		type = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 6, 15, 20, 29, 34, 37, 46, 54 }, { 6, 13, 17, 24, 29, 36, 37, 44, 55 } },
		weight = 78.5
	},
	{
		name = "Magnemite",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.STEEL },
		evolution = "30",
		bst = "325",
		movelvls = { { 6, 11, 16, 21, 26, 32, 38, 44, 50 }, { 6, 11, 16, 21, 26, 32, 38, 44, 50 } },
		weight = 6.0
	},
	{
		name = "Magneton",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.STEEL },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		movelvls = { { 6, 11, 16, 21, 26, 35, 44, 53, 62 }, { 6, 11, 16, 21, 26, 35, 44, 53, 62 } },
		weight = 60.0
	},
	{
		name = "Farfetch'd",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "352",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 15.0
	},
	{
		name = "Doduo",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "31",
		bst = "310",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45 }, { 9, 13, 21, 25, 33, 37, 45 } },
		weight = 39.2
	},
	{
		name = "Dodrio",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 9, 13, 21, 25, 38, 47, 60 }, { 9, 13, 21, 25, 38, 47, 60 } },
		weight = 85.2
	},
	{
		name = "Seel",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "34",
		bst = "325",
		movelvls = { { 9, 17, 21, 29, 37, 41, 49 }, { 9, 17, 21, 29, 37, 41, 49 } },
		weight = 90.0
	},
	{
		name = "Dewgong",
		type = { PokemonData.Types.WATER, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		movelvls = { { 9, 17, 21, 29, 34, 42, 51, 64 }, { 9, 17, 21, 29, 34, 42, 51, 64 } },
		weight = 120.0
	},
	{
		name = "Grimer",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "38",
		bst = "325",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = 30.0
	},
	{
		name = "Muk", -- PUMP SLOP
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 8, 13, 19, 26, 34, 47, 61 }, { 8, 13, 19, 26, 34, 47, 61 } },
		weight = 30.0
	},
	{
		name = "Shellder",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.WATER,
		bst = "305",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 4.0
	},
	{
		name = "Cloyster",
		type = { PokemonData.Types.WATER, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 33, 41 }, { 36, 43 } },
		weight = 132.5
	},
	{
		name = "Gastly",
		type = { PokemonData.Types.GHOST, PokemonData.Types.POISON },
		evolution = "25",
		bst = "310",
		movelvls = { { 8, 13, 16, 21, 28, 33, 36 }, { 8, 13, 16, 21, 28, 33, 36, 41, 48 } },
		weight = 0.1
	},
	{
		name = "Haunter",
		type = { PokemonData.Types.GHOST, PokemonData.Types.POISON },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "405",
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 0.1
	},
	{
		name = "Gengar",
		type = { PokemonData.Types.GHOST, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 40.5
	},
	{
		name = "Onix",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "385",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 210.0
	},
	{
		name = "Drowzee",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "328",
		movelvls = { { 10, 18, 25, 31, 36, 40, 43, 45 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 32.4
	},
	{
		name = "Hypno",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "483",
		movelvls = { { 10, 18, 25, 33, 40, 49, 55, 60 }, { 7, 11, 17, 21, 29, 35, 43, 49, 57 } },
		weight = 75.6
	},
	{
		name = "Krabby",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "325",
		movelvls = { { 12, 16, 23, 27, 34, 41, 45 }, { 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 6.5
	},
	{
		name = "Kingler",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		movelvls = { { 12, 16, 23, 27, 38, 49, 57 }, { 12, 16, 23, 27, 38, 42, 57, 65 } },
		weight = 60.0
	},
	{
		name = "Voltorb",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "330",
		movelvls = { { 8, 15, 21, 27, 32, 37, 42, 46, 49 }, { 8, 15, 21, 27, 32, 37, 42, 46, 49 } },
		weight = 10.4
	},
	{
		name = "Electrode",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { { 8, 15, 21, 27, 34, 41, 48, 54, 59 }, { 8, 15, 21, 27, 34, 41, 48, 54, 59 } },
		weight = 66.6
	},
	{
		name = "Exeggcute",
		type = { PokemonData.Types.GRASS, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.LEAF,
		bst = "325",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Exeggutor",
		type = { PokemonData.Types.GRASS, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "520",
		movelvls = { { 19, 31 }, { 19, 31 } },
		weight = 120.0
	},
	{
		name = "Cubone",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "320",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 6.5
	},
	{
		name = "Marowak",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		movelvls = { { 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 }, { 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 } },
		weight = 45.0
	},
	{
		name = "Hitmonlee",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 }, { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 } },
		weight = 49.8
	},
	{
		name = "Hitmonchan",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 }, { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 } },
		weight = 50.2
	},
	{
		name = "Lickitung",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		movelvls = { { 7, 12, 18, 23, 29, 34, 40, 45, 51 }, { 7, 12, 18, 23, 29, 34, 40, 45, 51 } },
		weight = 65.5
	},
	{
		name = "Koffing",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "35",
		bst = "340",
		movelvls = { { 9, 17, 21, 25, 33, 41, 45, 49 }, { 9, 17, 21, 25, 33, 41, 45, 49 } },
		weight = 1.0
	},
	{
		name = "Weezing",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 9, 17, 21, 25, 33, 44, 51, 58 }, { 9, 17, 21, 25, 33, 44, 51, 58 } },
		weight = 9.5
	},
	{
		name = "Rhyhorn",
		type = { PokemonData.Types.GROUND, PokemonData.Types.ROCK },
		evolution = "42",
		bst = "345",
		movelvls = { { 10, 15, 24, 29, 38, 43, 52, 57 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 115.0
	},
	{
		name = "Rhydon",
		type = { PokemonData.Types.GROUND, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		movelvls = { { 10, 15, 24, 29, 38, 46, 58, 66 }, { 10, 15, 24, 29, 38, 46, 58, 66 } },
		weight = 120.0
	},
	{
		name = "Chansey",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "450",
		movelvls = { { 9, 13, 17, 23, 29, 35, 41, 49, 57 }, { 9, 13, 17, 23, 29, 35, 41, 49, 57 } },
		weight = 34.6
	},
	{
		name = "Tangela",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "435",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 46 }, { 10, 13, 19, 22, 28, 31, 37, 40, 46 } },
		weight = 35.0
	},
	{
		name = "Kangaskhan",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 80.0
	},
	{
		name = "Horsea",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "295",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 8.0
	},
	{
		name = "Seadra",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "40", -- Level 40 replaces trade evolution
		bst = "440",
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 25.0
	},
	{
		name = "Goldeen",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "33",
		bst = "320",
		movelvls = { { 10, 15, 24, 29, 38, 43, 52 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 15.0
	},
	{
		name = "Seaking",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		movelvls = { { 10, 15, 24, 29, 41, 49, 61 }, { 10, 15, 24, 29, 41, 49, 61, 69 } },
		weight = 39.0
	},
	{
		name = "Staryu",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.WATER,
		bst = "340",
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 34.5
	},
	{
		name = "Starmie",
		type = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "520",
		movelvls = { { 33 }, { 33 } },
		weight = 80.0
	},
	{
		name = "Mr. Mime",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 9, 13, 17, 21, 21, 25, 29, 33, 37, 41, 45, 49, 53 }, { 8, 12, 15, 19, 19, 22, 26, 29, 33, 36, 40, 43, 47, 50 } },
		weight = 54.5
	},
	{
		name = "Scyther",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "500",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 56.0
	},
	{
		name = "Jynx",
		type = { PokemonData.Types.ICE, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 9, 13, 21, 25, 35, 41, 51, 57, 67 }, { 9, 13, 21, 25, 35, 41, 51, 57, 67 } },
		weight = 40.6
	},
	{
		name = "Electabuzz",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 9, 17, 25, 36, 47, 58 }, { 9, 17, 25, 36, 47, 58 } },
		weight = 30.0
	},
	{
		name = "Magmar", -- MAMGAR
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 7, 13, 19, 25, 33, 41, 49, 57 }, { 7, 13, 19, 25, 33, 41, 49, 57 } },
		weight = 44.5
	},
	{
		name = "Pinsir",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 55.0
	},
	{
		name = "Tauros",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = 88.4
	},
	{
		name = "Magikarp",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "200",
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 10.0
	},
	{
		name = "Gyarados",
		type = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		movelvls = { { 20, 25, 30, 35, 40, 45, 50, 55 }, { 20, 25, 30, 35, 40, 45, 50, 55 } },
		weight = 235.0
	},
	{
		name = "Lapras",
		type = { PokemonData.Types.WATER, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "535",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 220.0
	},
	{
		name = "Ditto",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "288",
		movelvls = { {}, {} },
		weight = 4.0
	},
	{
		name = "Eevee",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.STONES,
		bst = "325",
		movelvls = { { 8, 16, 23, 30, 36, 42 }, { 8, 16, 23, 30, 36, 42 } },
		weight = 6.5
	},
	{
		name = "Vaporeon",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 29.0
	},
	{
		name = "Jolteon",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 24.5
	},
	{
		name = "Flareon",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 25.0
	},
	{
		name = "Porygon",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "395",
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 36.5
	},
	{
		name = "Omanyte",
		type = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = "40",
		bst = "355",
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 7.5
	},
	{
		name = "Omastar", -- LORD HELIX
		type = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 35.0
	},
	{
		name = "Kabuto",
		type = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = "40",
		bst = "355",
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 11.5
	},
	{
		name = "Kabutops",
		type = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 40.5
	},
	{
		name = "Aerodactyl",
		type = { PokemonData.Types.ROCK, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "515",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 59.0
	},
	{
		name = "Snorlax",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		movelvls = { { 6, 10, 15, 19, 24, 28, 28, 33, 37, 42, 46, 51 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53 } },
		weight = 460.0
	},
	{
		name = "Articuno",
		type = { PokemonData.Types.ICE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 55.4
	},
	{
		name = "Zapdos",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 52.6
	},
	{
		name = "Moltres",
		type = { PokemonData.Types.FIRE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 60.0
	},
	{
		name = "Dratini",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "300",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 3.3
	},
	{
		name = "Dragonair",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "55",
		bst = "420",
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 16.5
	},
	{
		name = "Dragonite",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 8, 15, 22, 29, 38, 47, 55, 61, 75 }, { 8, 15, 22, 29, 38, 47, 55, 61, 75 } },
		weight = 210.0
	},
	{
		name = "Mewtwo",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 122.0
	},
	{
		name = "Mew",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 4.0
	},
	{
		name = "Chikorita",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "318",
		movelvls = { { 8, 12, 15, 22, 29, 36, 43, 50 }, { 8, 12, 15, 22, 29, 36, 43, 50 } },
		weight = 6.4
	},
	{
		name = "Bayleef",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "405",
		movelvls = { { 8, 12, 15, 23, 31, 39, 47, 55 }, { 8, 12, 15, 23, 31, 39, 47, 55 } },
		weight = 15.8
	},
	{
		name = "Meganium",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 8, 12, 15, 23, 31, 41, 51, 61 }, { 8, 12, 15, 23, 31, 41, 51, 61 } },
		weight = 100.5
	},
	{
		name = "Cyndaquil",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "14",
		bst = "309",
		movelvls = { { 6, 12, 19, 27, 36, 46 }, { 6, 12, 19, 27, 36, 46 } },
		weight = 7.9
	},
	{
		name = "Quilava",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 6, 12, 21, 31, 42, 54 }, { 6, 12, 21, 31, 42, 54 } },
		weight = 19.0
	},
	{
		name = "Typhlosion",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "534",
		movelvls = { { 6, 12, 21, 31, 45, 60 }, { 6, 12, 21, 31, 45, 60 } },
		weight = 79.5
	},
	{
		name = "Totodile",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "314",
		movelvls = { { 7, 13, 20, 27, 35, 43, 52 }, { 7, 13, 20, 27, 35, 43, 52 } },
		weight = 9.5
	},
	{
		name = "Croconaw",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "405",
		movelvls = { { 7, 13, 21, 28, 37, 45, 55 }, { 7, 13, 21, 28, 37, 45, 55 } },
		weight = 25.0
	},
	{
		name = "Feraligatr",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		movelvls = { { 7, 13, 21, 28, 38, 47, 58 }, { 7, 13, 21, 28, 38, 47, 58 } },
		weight = 88.8
	},
	{
		name = "Sentret",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "15",
		bst = "215",
		movelvls = { { 7, 12, 17, 24, 31, 40, 49 }, { 7, 12, 17, 24, 31, 40, 49 } },
		weight = 6.0
	},
	{
		name = "Furret",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "415",
		movelvls = { { 7, 12, 19, 28, 37, 48, 59 }, { 7, 12, 19, 28, 37, 48, 59 } },
		weight = 32.5
	},
	{
		name = "Hoothoot",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "20",
		bst = "262",
		movelvls = { { 6, 11, 16, 22, 28, 34, 48 }, { 6, 11, 16, 22, 28, 34, 48 } },
		weight = 21.2
	},
	{
		name = "Noctowl",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "442",
		movelvls = { { 6, 11, 16, 25, 33, 41, 57 }, { 6, 11, 16, 25, 33, 41, 57 } },
		weight = 40.8
	},
	{
		name = "Ledyba",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = "18",
		bst = "265",
		movelvls = { { 8, 15, 22, 22, 22, 29, 36, 43, 50 }, { 8, 15, 22, 22, 22, 29, 36, 43, 50 } },
		weight = 10.8
	},
	{
		name = "Ledian",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "390",
		movelvls = { { 8, 15, 24, 24, 24, 33, 42, 51, 60 }, { 8, 15, 24, 24, 24, 33, 42, 51, 60 } },
		weight = 35.6
	},
	{
		name = "Spinarak",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "22",
		bst = "250",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 8.5
	},
	{
		name = "Ariados",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "390",
		movelvls = { { 6, 11, 17, 25, 34, 43, 53, 63 }, { 6, 11, 17, 25, 34, 43, 53, 63 } },
		weight = 33.5
	},
	{
		name = "Crobat",
		type = { PokemonData.Types.POISON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "535",
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 75.0
	},
	{
		name = "Chinchou",
		type = { PokemonData.Types.WATER, PokemonData.Types.ELECTRIC },
		evolution = "27",
		bst = "330",
		movelvls = { { 13, 17, 25, 29, 37, 41, 49 }, { 13, 17, 25, 29, 37, 41, 49 } },
		weight = 12.0
	},
	{
		name = "Lanturn",
		type = { PokemonData.Types.WATER, PokemonData.Types.ELECTRIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 13, 17, 25, 32, 43, 50, 61 }, { 13, 17, 25, 32, 43, 50, 61 } },
		weight = 22.5
	},
	{
		name = "Pichu",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "205",
		movelvls = { { 6, 8, 11 }, { 6, 8, 11 } },
		weight = 2.0
	},
	{
		name = "Cleffa",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "218",
		movelvls = { { 8, 13 }, { 8, 13, 17 } },
		weight = 3.0
	},
	{
		name = "Igglybuff",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "210",
		movelvls = { { 9, 14 }, { 9, 14 } },
		weight = 1.0
	},
	{
		name = "Togepi",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "245",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 1.5
	},
	{
		name = "Togetic",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 3.2
	},
	{
		name = "Natu",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING },
		evolution = "25",
		bst = "320",
		movelvls = { { 10, 20, 30, 30, 40, 50 }, { 10, 20, 30, 30, 40, 50 } },
		weight = 2.0
	},
	{
		name = "Xatu",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "470",
		movelvls = { { 10, 20, 35, 35, 50, 65 }, { 10, 20, 35, 35, 50, 65 } },
		weight = 15.0
	},
	{
		name = "Mareep",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "15",
		bst = "280",
		movelvls = { { 9, 16, 23, 30, 37 }, { 9, 16, 23, 30, 37 } },
		weight = 7.8
	},
	{
		name = "Flaaffy",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "365",
		movelvls = { { 9, 18, 27, 36, 45 }, { 9, 18, 27, 36, 45 } },
		weight = 13.3
	},
	{
		name = "Ampharos",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 9, 18, 27, 30, 42, 57 }, { 9, 18, 27, 30, 42, 57 } },
		weight = 61.5
	},
	{
		name = "Bellossom",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { { 44, 55 }, { 44, 55 } },
		weight = 5.8
	},
	{
		name = "Marill",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "250",
		movelvls = { { 6, 10, 15, 21, 28, 36, 45 }, { 6, 10, 15, 21, 28, 36, 45 } },
		weight = 8.5
	},
	{
		name = "Azumarill",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		movelvls = { { 6, 10, 15, 24, 34, 45, 57 }, { 6, 10, 15, 24, 34, 45, 57 } },
		weight = 28.5
	},
	{
		name = "Sudowoodo",
		type = { PokemonData.Types.ROCK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = 38.0
	},
	{
		name = "Politoed",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 33.9
	},
	{
		name = "Hoppip",
		type = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = "18",
		bst = "250",
		movelvls = { { 10, 13, 15, 17, 20, 25, 30 }, { 10, 13, 15, 17, 20, 25, 30 } },
		weight = 0.5
	},
	{
		name = "Skiploom",
		type = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = "27",
		bst = "340",
		movelvls = { { 10, 13, 15, 17, 22, 29, 36 }, { 10, 13, 15, 17, 22, 29, 36 } },
		weight = 1.0
	},
	{
		name = "Jumpluff",
		type = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		movelvls = { { 10, 13, 15, 17, 22, 33, 44 }, { 10, 13, 15, 17, 22, 33, 44 } },
		weight = 3.0
	},
	{
		name = "Aipom",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "360",
		movelvls = { { 6, 13, 18, 25, 31, 38, 43, 50 }, { 6, 13, 18, 25, 31, 38, 43, 50 } },
		weight = 11.5
	},
	{
		name = "Sunkern",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.SUN,
		bst = "180",
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = 1.8
	},
	{
		name = "Sunflora",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = 8.5
	},
	{
		name = "Yanma",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "390",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 6, 12, 17, 23, 28, 34, 39, 45, 50 } },
		weight = 38.0
	},
	{
		name = "Wooper",
		type = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = "20",
		bst = "210",
		movelvls = { { 11, 16, 21, 31, 36, 41, 51, 51 }, { 11, 16, 21, 31, 36, 41, 51, 51 } },
		weight = 8.5
	},
	{
		name = "Quagsire",
		type = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		movelvls = { { 11, 16, 23, 35, 42, 49, 61, 61 }, { 11, 16, 23, 35, 42, 49, 61, 61 } },
		weight = 75.0
	},
	{
		name = "Espeon",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 26.5
	},
	{
		name = "Umbreon",
		type = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 27.0
	},
	{
		name = "Murkrow",
		type = { PokemonData.Types.DARK, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { { 9, 14, 22, 27, 35, 40, 48 }, { 9, 14, 22, 27, 35, 40, 48 } },
		weight = 2.1
	},
	{
		name = "Slowking",
		type = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 79.5
	},
	{
		name = "Misdreavus",
		type = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "435",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 1.0
	},
	{
		name = "Unown",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = 5.0
	},
	{
		name = "Wobbuffet",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { {}, {} },
		weight = 28.5
	},
	{
		name = "Girafarig",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 41.5
	},
	{
		name = "Pineco",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "31",
		bst = "290",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 7.2
	},
	{
		name = "Forretress",
		type = { PokemonData.Types.BUG, PokemonData.Types.STEEL },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		movelvls = { { 8, 15, 22, 29, 39, 49, 59 }, { 8, 15, 22, 29, 31, 39, 49, 59 } },
		weight = 125.8
	},
	{
		name = "Dunsparce",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "415",
		movelvls = { { 11, 14, 21, 24, 31, 34, 41 }, { 11, 14, 21, 24, 31, 34, 41, 44, 51 } },
		weight = 14.0
	},
	{
		name = "Gligar",
		type = { PokemonData.Types.GROUND, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		movelvls = { { 6, 13, 20, 28, 36, 44, 52 }, { 6, 13, 20, 28, 36, 44, 52 } },
		weight = 64.8
	},
	{
		name = "Steelix",
		type = { PokemonData.Types.STEEL, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "510",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 400.0
	},
	{
		name = "Snubbull",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "23",
		bst = "300",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = 7.8
	},
	{
		name = "Granbull",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		movelvls = { { 8, 13, 19, 28, 38, 49, 61 }, { 8, 13, 19, 28, 38, 49, 61 } },
		weight = 48.7
	},
	{
		name = "Qwilfish",
		type = { PokemonData.Types.WATER, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		movelvls = { { 10, 10, 19, 28, 37, 46 }, { 9, 9, 13, 21, 25, 33, 37, 45 } },
		weight = 3.9
	},
	{
		name = "Scizor",
		type = { PokemonData.Types.BUG, PokemonData.Types.STEEL },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 118.0
	},
	{
		name = "Shuckle",
		type = { PokemonData.Types.BUG, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "505",
		movelvls = { { 9, 14, 23, 28, 37 }, { 9, 14, 23, 28, 37 } },
		weight = 20.5
	},
	{
		name = "Heracross",
		type = { PokemonData.Types.BUG, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 54.0
	},
	{
		name = "Sneasel",
		type = { PokemonData.Types.DARK, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = 28.0
	},
	{
		name = "Teddiursa",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "330",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.8
	},
	{
		name = "Ursaring",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 125.8
	},
	{
		name = "Slugma",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "38",
		bst = "250",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 35.0
	},
	{
		name = "Magcargo",
		type = { PokemonData.Types.FIRE, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		movelvls = { { 8, 15, 22, 29, 36, 48, 60 }, { 8, 15, 22, 29, 36, 48, 60 } },
		weight = 55.0
	},
	{
		name = "Swinub",
		type = { PokemonData.Types.ICE, PokemonData.Types.GROUND },
		evolution = "33",
		bst = "250",
		movelvls = { { 10, 19, 28, 37, 46, 55 }, { 10, 19, 28, 37, 46, 55 } },
		weight = 6.5
	},
	{
		name = "Piloswine",
		type = { PokemonData.Types.ICE, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		movelvls = { { 10, 19, 28, 33, 42, 56, 70 }, { 10, 19, 28, 33, 42, 56, 70 } },
		weight = 55.8
	},
	{
		name = "Corsola",
		type = { PokemonData.Types.WATER, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		movelvls = { { 6, 12, 17, 17, 23, 28, 34, 39, 45 }, { 6, 12, 17, 17, 23, 28, 34, 39, 45 } },
		weight = 5.0
	},
	{
		name = "Remoraid",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "25",
		bst = "300",
		movelvls = { { 11, 22, 22, 22, 33, 44, 55 }, { 11, 22, 22, 22, 33, 44, 55 } },
		weight = 12.0
	},
	{
		name = "Octillery",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { { 11, 22, 22, 22, 25, 38, 54, 70 }, { 11, 22, 22, 22, 25, 38, 54, 70 } },
		weight = 28.5
	},
	{
		name = "Delibird",
		type = { PokemonData.Types.ICE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "330",
		movelvls = { {}, {} },
		weight = 16.0
	},
	{
		name = "Mantine",
		type = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 220.0
	},
	{
		name = "Skarmory",
		type = { PokemonData.Types.STEEL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		movelvls = { { 10, 13, 16, 26, 29, 32, 42, 45 }, { 10, 13, 16, 26, 29, 32, 42, 45 } },
		weight = 50.5
	},
	{
		name = "Houndour",
		type = { PokemonData.Types.DARK, PokemonData.Types.FIRE },
		evolution = "24",
		bst = "330",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 10.8
	},
	{
		name = "Houndoom",
		type = { PokemonData.Types.DARK, PokemonData.Types.FIRE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 35.0
	},
	{
		name = "Kingdra",
		type = { PokemonData.Types.WATER, PokemonData.Types.DRAGON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 152.0
	},
	{
		name = "Phanpy",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "25",
		bst = "330",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 33.5
	},
	{
		name = "Donphan",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 120.0
	},
	{
		name = "Porygon2",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "515",
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 32.5
	},
	{
		name = "Stantler",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 71.2
	},
	{
		name = "Smeargle",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "250",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81, 91 }, { 11, 21, 31, 41, 51, 61, 71, 81, 91 } },
		weight = 58.0
	},
	{
		name = "Tyrogue",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "210",
		movelvls = { {}, {} },
		weight = 21.0
	},
	{
		name = "Hitmontop",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 7, 13, 19, 20, 25, 31, 37, 43, 49 }, { 7, 13, 19, 20, 25, 31, 37, 43, 49 } },
		weight = 48.0
	},
	{
		name = "Smoochum",
		type = { PokemonData.Types.ICE, PokemonData.Types.PSYCHIC },
		evolution = "30",
		bst = "305",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 9, 13, 21, 25, 33, 37, 45, 49, 57 } },
		weight = 6.0
	},
	{
		name = "Elekid",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "360",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 23.5
	},
	{
		name = "Magby",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "365",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 21.4
	},
	{
		name = "Miltank",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = 75.5
	},
	{
		name = "Blissey",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		movelvls = { { 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 46.8
	},
	{
		name = "Raikou",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 178.0
	},
	{
		name = "Entei",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 198.0
	},
	{
		name = "Suicune",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 187.0
	},
	{
		name = "Larvitar",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "30",
		bst = "300",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 72.0
	},
	{
		name = "Pupitar",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "55",
		bst = "410",
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 152.0
	},
	{
		name = "Tyranitar",
		type = { PokemonData.Types.ROCK, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 8, 15, 22, 29, 38, 47, 61, 75 }, { 8, 15, 22, 29, 38, 47, 61, 75 } },
		weight = 202.0
	},
	{
		name = "Lugia",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 216.0
	},
	{
		name = "Ho-Oh",
		type = { PokemonData.Types.FIRE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 199.0
	},
	{
		name = "Celebi",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 5.0
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		type = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "Treecko",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 5.0
	},
	{
		name = "Grovyle",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 }, { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 } },
		weight = 21.6
	},
	{
		name = "Sceptile",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 }, { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 } },
		weight = 52.2
	},
	{
		name = "Torchic",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Combusken",
		type = { PokemonData.Types.FIRE, PokemonData.Types.FIGHTING },
		evolution = "36",
		bst = "405",
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 }, { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 } },
		weight = 19.5
	},
	{
		name = "Blaziken",
		type = { PokemonData.Types.FIRE, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 }, { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 } },
		weight = 52.0
	},
	{
		name = "Mudkip",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 7.6
	},
	{
		name = "Marshtomp",
		type = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = "36",
		bst = "405",
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 }, { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 } },
		weight = 28.0
	},
	{
		name = "Swampert",
		type = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "535",
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 }, { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 } },
		weight = 81.9
	},
	{
		name = "Poochyena",
		type = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "220",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 13.6
	},
	{
		name = "Mightyena",
		type = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "420",
		movelvls = { { 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 }, { 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 } },
		weight = 37.0
	},
	{
		name = "Zigzagoon",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "240",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 17.5
	},
	{
		name = "Linoone",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "420",
		movelvls = { { 9, 13, 17, 23, 29, 35, 41, 47, 53 }, { 9, 13, 17, 23, 29, 35, 41, 47, 53 } },
		weight = 32.5
	},
	{
		name = "Wurmple",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "7",
		bst = "195",
		movelvls = { {}, {} },
		weight = 3.6
	},
	{
		name = "Silcoon",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beautifly",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = 28.4
	},
	{
		name = "Cascoon",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = 11.5
	},
	{
		name = "Dustox",
		type = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = 31.6
	},
	{
		name = "Lotad",
		type = { PokemonData.Types.WATER, PokemonData.Types.GRASS },
		evolution = "14",
		bst = "220",
		movelvls = { { 7, 13, 21, 31, 43 }, { 7, 13, 21, 31, 43 } },
		weight = 2.6
	},
	{
		name = "Lombre",
		type = { PokemonData.Types.WATER, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.WATER,
		bst = "340",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 32.5
	},
	{
		name = "Ludicolo",
		type = { PokemonData.Types.WATER, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { {}, {} },
		weight = 55.0
	},
	{
		name = "Seedot",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "14",
		bst = "220",
		movelvls = { { 7, 13, 21, 31, 43 }, { 7, 13, 21, 31, 43 } },
		weight = 4.0
	},
	{
		name = "Nuzleaf",
		type = { PokemonData.Types.GRASS, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.LEAF,
		bst = "340",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 28.0
	},
	{
		name = "Shiftry",
		type = { PokemonData.Types.GRASS, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { {}, {} },
		weight = 59.6
	},
	{
		name = "Nincada",
		type = { PokemonData.Types.BUG, PokemonData.Types.GROUND },
		evolution = "20",
		bst = "266",
		movelvls = { { 9, 14, 19, 25, 31, 38, 45 }, { 9, 14, 19, 25, 31, 38, 45 } },
		weight = 5.5
	},
	{
		name = "Ninjask",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "456",
		movelvls = { { 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 }, { 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 } },
		weight = 12.0
	},
	{
		name = "Shedinja",
		type = { PokemonData.Types.BUG, PokemonData.Types.GHOST },
		evolution = PokemonData.Evolutions.NONE,
		bst = "236",
		movelvls = { { 9, 14, 19, 25, 31, 38, 45 }, { 9, 14, 19, 25, 31, 38, 45 } },
		weight = 1.2
	},
	{
		name = "Taillow",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "22",
		bst = "270",
		movelvls = { { 8, 13, 19, 26, 34, 43 }, { 8, 13, 19, 26, 34, 43 } },
		weight = 2.3
	},
	{
		name = "Swellow",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		movelvls = { { 8, 13, 19, 28, 38, 49 }, { 8, 13, 19, 28, 38, 49 } },
		weight = 19.8
	},
	{
		name = "Shroomish",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "23",
		bst = "295",
		movelvls = { { 7, 10, 16, 22, 28, 36, 45, 54 }, { 7, 10, 16, 22, 28, 36, 45, 54 } },
		weight = 4.5
	},
	{
		name = "Breloom",
		type = { PokemonData.Types.GRASS, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 7, 10, 16, 22, 23, 28, 36, 45, 54 }, { 7, 10, 16, 22, 23, 28, 36, 45, 54 } },
		weight = 39.2
	},
	{
		name = "Spinda",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "360",
		movelvls = { { 12, 16, 23, 27, 34, 38, 45, 49, 56 }, { 12, 16, 23, 27, 34, 38, 45, 49, 56 } },
		weight = 5.0
	},
	{
		name = "Wingull",
		type = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = "25",
		bst = "270",
		movelvls = { { 7, 13, 21, 31, 43, 55 }, { 7, 13, 21, 31, 43, 55 } },
		weight = 9.5
	},
	{
		name = "Pelipper",
		type = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		movelvls = { { 7, 13, 21, 25, 33, 33, 47, 61 }, { 7, 13, 21, 25, 33, 33, 47, 61 } },
		weight = 28.0
	},
	{
		name = "Surskit",
		type = { PokemonData.Types.BUG, PokemonData.Types.WATER },
		evolution = "22",
		bst = "269",
		movelvls = { { 7, 13, 19, 25, 31, 37, 37 }, { 7, 13, 19, 25, 31, 37, 37 } },
		weight = 1.7
	},
	{
		name = "Masquerain",
		type = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "414",
		movelvls = { { 7, 13, 19, 26, 33, 40, 47, 53 }, { 7, 13, 19, 26, 33, 40, 47, 53 } },
		weight = 3.6
	},
	{
		name = "Wailmer",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "40",
		bst = "400",
		movelvls = { { 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 }, { 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 } },
		weight = 130.0
	},
	{
		name = "Wailord", -- STONKS
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 }, { 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 } },
		weight = 398.0
	},
	{
		name = "Skitty",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "260",
		movelvls = { { 7, 13, 15, 19, 25, 27, 31, 37, 39 }, { 7, 13, 15, 19, 25, 27, 31, 37, 39 } },
		weight = 11.0
	},
	{
		name = "Delcatty",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		movelvls = { {}, {} },
		weight = 32.6
	},
	{
		name = "Kecleon", -- KEKLEO-N
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		movelvls = { { 7, 12, 17, 24, 31, 40, 49 }, { 7, 12, 17, 24, 31, 40, 49 } },
		weight = 22.0
	},
	{
		name = "Baltoy",
		type = { PokemonData.Types.GROUND, PokemonData.Types.PSYCHIC },
		evolution = "36",
		bst = "300",
		movelvls = { { 7, 11, 15, 19, 25, 31, 37, 45 }, { 7, 11, 15, 19, 25, 31, 37, 45 } },
		weight = 21.5
	},
	{
		name = "Claydol",
		type = { PokemonData.Types.GROUND, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		movelvls = { { 7, 11, 15, 19, 25, 31, 36, 42, 55 }, { 7, 11, 15, 19, 25, 31, 36, 42, 55 } },
		weight = 108.0
	},
	{
		name = "Nosepass",
		type = { PokemonData.Types.ROCK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "375",
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43, 46 }, { 7, 13, 16, 22, 28, 31, 37, 43, 46 } },
		weight = 97.0
	},
	{
		name = "Torkoal",
		type = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "470",
		movelvls = { { 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 }, { 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 } },
		weight = 80.4
	},
	{
		name = "Sableye",
		type = { PokemonData.Types.DARK, PokemonData.Types.GHOST },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 11.0
	},
	{
		name = "Barboach",
		type = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = "30",
		bst = "288",
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 }, { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 } },
		weight = 1.9
	},
	{
		name = "Whiscash",
		type = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "468",
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 }, { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 } },
		weight = 23.6
	},
	{
		name = "Luvdisc",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "330",
		movelvls = { { 12, 16, 24, 28, 36, 40, 48 }, { 12, 16, 24, 28, 36, 40, 48 } },
		weight = 8.7
	},
	{
		name = "Corphish",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "308",
		movelvls = { { 7, 10, 13, 20, 23, 26, 32, 35, 38, 44 }, { 7, 10, 13, 19, 22, 25, 31, 34, 37, 43, 46 } },
		weight = 11.5
	},
	{
		name = "Crawdaunt", -- FRAUD
		type = { PokemonData.Types.WATER, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "468",
		movelvls = { { 7, 10, 13, 20, 23, 26, 34, 39, 44, 52 }, { 7, 10, 13, 19, 22, 25, 33, 38, 43, 51, 56 } },
		weight = 32.8
	},
	{
		name = "Feebas",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "35", -- Level 35 replaces beauty condition
		bst = "200",
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 7.4
	},
	{
		name = "Milotic", -- THICC
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 162.0
	},
	{
		name = "Carvanha",
		type = { PokemonData.Types.WATER, PokemonData.Types.DARK },
		evolution = "30",
		bst = "305",
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43 }, { 7, 13, 16, 22, 28, 31, 37, 43 } },
		weight = 20.8
	},
	{
		name = "Sharpedo",
		type = { PokemonData.Types.WATER, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 }, { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 } },
		weight = 88.8
	},
	{
		name = "Trapinch",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "35",
		bst = "290",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = 15.0
	},
	{
		name = "Vibrava",
		type = { PokemonData.Types.GROUND, PokemonData.Types.DRAGON },
		evolution = "45",
		bst = "340",
		movelvls = { { 9, 17, 25, 33, 35, 41, 49, 57 }, { 9, 17, 25, 33, 35, 41, 49, 57 } },
		weight = 15.3
	},
	{
		name = "Flygon",
		type = { PokemonData.Types.GROUND, PokemonData.Types.DRAGON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "520",
		movelvls = { { 9, 17, 25, 33, 35, 41, 53, 65 }, { 9, 17, 25, 33, 35, 41, 53, 65 } },
		weight = 82.0
	},
	{
		name = "Makuhita",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "24",
		bst = "237",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 }, { 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 } },
		weight = 86.4
	},
	{
		name = "Hariyama",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "474",
		movelvls = { { 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 }, { 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 } },
		weight = 253.8
	},
	{
		name = "Electrike",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "295",
		movelvls = { { 9, 12, 17, 20, 25, 28, 33, 36, 41 }, { 9, 12, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 15.2
	},
	{
		name = "Manectric",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		movelvls = { { 9, 12, 17, 20, 25, 31, 39, 45, 53 }, { 9, 12, 17, 20, 25, 31, 39, 45, 53 } },
		weight = 40.2
	},
	{
		name = "Numel",
		type = { PokemonData.Types.FIRE, PokemonData.Types.GROUND },
		evolution = "33",
		bst = "305",
		movelvls = { { 11, 19, 25, 29, 31, 35, 41, 49 }, { 11, 19, 25, 29, 31, 35, 41, 49 } },
		weight = 24.0
	},
	{
		name = "Camerupt",
		type = { PokemonData.Types.FIRE, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 11, 19, 25, 29, 31, 33, 37, 45, 55 }, { 11, 19, 25, 29, 31, 33, 37, 45, 55 } },
		weight = 220.0
	},
	{
		name = "Spheal",
		type = { PokemonData.Types.ICE, PokemonData.Types.WATER },
		evolution = "32",
		bst = "290",
		movelvls = { { 7, 13, 19, 25, 31, 37, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 37, 43, 49 } },
		weight = 39.5
	},
	{
		name = "Sealeo",
		type = { PokemonData.Types.ICE, PokemonData.Types.WATER },
		evolution = "44",
		bst = "410",
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 47, 55 }, { 7, 13, 19, 25, 31, 39, 39, 47, 55 } },
		weight = 87.6
	},
	{
		name = "Walrein",
		type = { PokemonData.Types.ICE, PokemonData.Types.WATER },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 50, 61 }, { 7, 13, 19, 25, 31, 39, 39, 50, 61 } },
		weight = 150.6
	},
	{
		name = "Cacnea",
		type = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "335",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 } },
		weight = 51.3
	},
	{
		name = "Cacturne",
		type = { PokemonData.Types.GRASS, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		movelvls = { { 9, 13, 17, 21, 25, 29, 35, 41, 47, 53 }, { 9, 13, 17, 21, 25, 29, 35, 41, 47, 53, 59 } },
		weight = 77.4
	},
	{
		name = "Snorunt",
		type = { PokemonData.Types.ICE, PokemonData.Types.EMPTY },
		evolution = "42",
		bst = "300",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 16.8
	},
	{
		name = "Glalie",
		type = { PokemonData.Types.ICE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 }, { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 } },
		weight = 256.5
	},
	{
		name = "Lunatone",
		type = { PokemonData.Types.ROCK, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 168.0
	},
	{
		name = "Solrock",
		type = { PokemonData.Types.ROCK, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 154.0
	},
	{
		name = "Azurill",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "190",
		movelvls = { { 6, 10, 15, 21 }, { 6, 10, 15, 21 } },
		weight = 2.0
	},
	{
		name = "Spoink",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "330",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 } },
		weight = 30.6
	},
	{
		name = "Grumpig",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "470",
		movelvls = { { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 }, { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 } },
		weight = 71.5
	},
	{
		name = "Plusle",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = 4.2
	},
	{
		name = "Minun",
		type = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = 4.2
	},
	{
		name = "Mawile",
		type = { PokemonData.Types.STEEL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 } },
		weight = 11.5
	},
	{
		name = "Meditite",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.PSYCHIC },
		evolution = "37",
		bst = "280",
		movelvls = { { 9, 12, 18, 22, 28, 32, 38, 42, 48 }, { 9, 12, 17, 20, 25, 28, 33, 36, 41, 44 } },
		weight = 11.2
	},
	{
		name = "Medicham",
		type = { PokemonData.Types.FIGHTING, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		movelvls = { { 9, 12, 18, 22, 28, 32, 40, 46, 54 }, { 9, 12, 17, 20, 25, 28, 33, 36, 47, 56 } },
		weight = 31.5
	},
	{
		name = "Swablu",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "35",
		bst = "310",
		movelvls = { { 8, 11, 18, 21, 28, 31, 38, 41, 48 }, { 8, 11, 18, 21, 28, 31, 38, 41, 48 } },
		weight = 1.2
	},
	{
		name = "Altaria",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		movelvls = { { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 }, { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 } },
		weight = 20.6
	},
	{
		name = "Wynaut",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "15",
		bst = "260",
		movelvls = { { 15, 15, 15, 15 }, { 15, 15, 15, 15 } },
		weight = 14.0
	},
	{
		name = "Duskull",
		type = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = "37",
		bst = "295",
		movelvls = { { 12, 16, 23, 27, 34, 38, 45, 49 }, { 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 15.0
	},
	{
		name = "Dusclops",
		type = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 12, 16, 23, 27, 34, 37, 41, 51, 58 }, { 12, 16, 23, 27, 34, 37, 41, 51, 58 } },
		weight = 30.6
	},
	{
		name = "Roselia",
		type = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "400",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 } },
		weight = 2.0
	},
	{
		name = "Slakoth",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "280",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 24.0
	},
	{
		name = "Vigoroth",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "440",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 46.5
	},
	{
		name = "Slaking",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "670",
		movelvls = { { 7, 13, 19, 25, 31, 36, 37, 43 }, { 7, 13, 19, 25, 31, 36, 37, 43 } },
		weight = 130.5
	},
	{
		name = "Gulpin",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "302",
		movelvls = { { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 }, { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 } },
		weight = 10.3
	},
	{
		name = "Swalot",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "467",
		movelvls = { { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 }, { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 } },
		weight = 80.0
	},
	{
		name = "Tropius",
		type = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		movelvls = { { 7, 11, 17, 21, 27, 31, 37, 41, 47 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 100.0
	},
	{
		name = "Whismur",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "240",
		movelvls = { { 11, 15, 21, 25, 31, 35, 41, 41, 45 }, { 11, 15, 21, 25, 31, 35, 41, 41, 45 } },
		weight = 16.3
	},
	{
		name = "Loudred",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "40",
		bst = "360",
		movelvls = { { 11, 15, 23, 29, 37, 43, 51, 51, 57 }, { 11, 15, 23, 29, 37, 43, 51, 51, 57 } },
		weight = 40.5
	},
	{
		name = "Exploud",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		movelvls = { { 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 }, { 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 } },
		weight = 84.0
	},
	{
		name = "Clamperl",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "30/WTR", -- Level 30 and stone replace trade evolution
		bst = "345",
		movelvls = { {}, {} },
		weight = 52.5
	},
	{
		name = "Huntail",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 27.0
	},
	{
		name = "Gorebyss",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 22.6
	},
	{
		name = "Absol",
		type = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		movelvls = { { 9, 13, 17, 21, 26, 31, 36, 41, 46 }, { 9, 13, 17, 21, 26, 31, 36, 41, 46 } },
		weight = 47.0
	},
	{
		name = "Shuppet",
		type = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = "37",
		bst = "295",
		movelvls = { { 8, 13, 20, 25, 32, 37, 44, 49, 56 }, { 8, 13, 20, 25, 32, 37, 44, 49, 56 } },
		weight = 2.3
	},
	{
		name = "Banette",
		type = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		movelvls = { { 8, 13, 20, 25, 32, 39, 48, 55, 64 }, { 8, 13, 20, 25, 32, 39, 48, 55, 64 } },
		weight = 12.5
	},
	{
		name = "Seviper",
		type = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "458",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 52.5
	},
	{
		name = "Zangoose",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "458",
		movelvls = { { 7, 10, 13, 19, 25, 31, 37, 46, 55 }, { 7, 10, 13, 19, 25, 31, 37, 46, 55 } },
		weight = 40.3
	},
	{
		name = "Relicanth",
		type = { PokemonData.Types.WATER, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = 23.4
	},
	{
		name = "Aron",
		type = { PokemonData.Types.STEEL, PokemonData.Types.ROCK },
		evolution = "32",
		bst = "330",
		movelvls = { { 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 }, { 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 } },
		weight = 60.0
	},
	{
		name = "Lairon",
		type = { PokemonData.Types.STEEL, PokemonData.Types.ROCK },
		evolution = "42",
		bst = "430",
		movelvls = { { 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 }, { 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 } },
		weight = 120.0
	},
	{
		name = "Aggron",
		type = { PokemonData.Types.STEEL, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		movelvls = { { 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 }, { 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 } },
		weight = 360.0
	},
	{
		name = "Castform",
		type = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "420",
		movelvls = { { 10, 10, 10, 20, 20, 20, 30 }, { 10, 10, 10, 20, 20, 20, 30 } },
		weight = 0.8
	},
	{
		name = "Volbeat",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "400",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37 }, { 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = 17.7
	},
	{
		name = "Illumise",
		type = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "400",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37 }, { 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = 17.7
	},
	{
		name = "Lileep",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GRASS },
		evolution = "40",
		bst = "355",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 50, 50 }, { 8, 15, 22, 29, 36, 43, 50, 50, 50 } },
		weight = 23.8
	},
	{
		name = "Cradily",
		type = { PokemonData.Types.ROCK, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 8, 15, 22, 29, 36, 48, 60, 60, 60 }, { 8, 15, 22, 29, 36, 48, 60, 60, 60 } },
		weight = 60.4
	},
	{
		name = "Anorith",
		type = { PokemonData.Types.ROCK, PokemonData.Types.BUG },
		evolution = "40",
		bst = "355",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 12.5
	},
	{
		name = "Armaldo",
		type = { PokemonData.Types.ROCK, PokemonData.Types.BUG },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		movelvls = { { 7, 13, 19, 25, 31, 37, 46, 55, 64 }, { 7, 13, 19, 25, 31, 37, 46, 55, 64 } },
		weight = 68.2
	},
	{
		name = "Ralts",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "198",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 6.6
	},
	{
		name = "Kirlia",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "278",
		movelvls = { { 6, 11, 16, 21, 26, 33, 40, 47, 54 }, { 6, 11, 16, 21, 26, 33, 40, 47, 54 } },
		weight = 20.2
	},
	{
		name = "Gardevoir",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "518",
		movelvls = { { 6, 11, 16, 21, 26, 33, 42, 51, 60 }, { 6, 11, 16, 21, 26, 33, 42, 51, 60 } },
		weight = 48.4
	},
	{
		name = "Bagon",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "300",
		movelvls = { { 9, 17, 21, 25, 33, 37, 41, 49, 53 }, { 9, 17, 21, 25, 33, 37, 41, 49, 53 } },
		weight = 42.1
	},
	{
		name = "Shelgon",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "50",
		bst = "420",
		movelvls = { { 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 }, { 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 } },
		weight = 110.5
	},
	{
		name = "Salamence",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 }, { 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 } },
		weight = 102.6
	},
	{
		name = "Beldum",
		type = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = "20",
		bst = "300",
		movelvls = { {}, {} },
		weight = 95.2
	},
	{
		name = "Metang",
		type = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = "45",
		bst = "420",
		movelvls = { { 20, 20, 26, 32, 38, 44, 50, 56, 62 }, { 20, 20, 26, 32, 38, 44, 50, 56, 62 } },
		weight = 202.5
	},
	{
		name = "Metagross",
		type = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 20, 20, 26, 32, 38, 44, 55, 66, 77 }, { 20, 20, 26, 32, 38, 44, 55, 66, 77 } },
		weight = 550.0
	},
	{
		name = "Regirock",
		type = { PokemonData.Types.ROCK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = 230.0
	},
	{
		name = "Regice",
		type = { PokemonData.Types.ICE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = 175.0
	},
	{
		name = "Registeel",
		type = { PokemonData.Types.STEEL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		movelvls = { { 9, 17, 25, 33, 41, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 41, 49, 57, 65 } },
		weight = 205.0
	},
	{
		name = "Kyogre",
		type = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "670",
		movelvls = { { 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 352.0
	},
	{
		name = "Groudon",
		type = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "670",
		movelvls = { { 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 950.0
	},
	{
		name = "Rayquaza",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		movelvls = { { 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 206.5
	},
	{
		name = "Latias",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 40.0
	},
	{
		name = "Latios",
		type = { PokemonData.Types.DRAGON, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 60.0
	},
	{
		name = "Jirachi",
		type = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 1.1
	},
	{
		name = "Deoxys",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 60.8
	},
	{
		name = "Chimecho",
		type = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		movelvls = { { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 }, { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 } },
		weight = 1.0
	},
}

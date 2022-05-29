-- Enumerated constants that defines the various types a Pokémon and its Moves are
PokemonTypes = {
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
EvolutionTypes = {
	NONE = PLACEHOLDER, -- This Pokémon does not evolve.
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

--[[
Data for each Pokémon (Gen 3) - Sourced from Bulbapedia

Format for an entry:

	name: string -> Name of the Pokémon as it appears in game

	type: {string, string} -> Each Pokémon can have one or two types, using the PokemonTypes enum to alias the strings

	evolution: string -> Displays the level, item, or other requirement a Pokémon needs to evolve

	bst: string -> A sum of the base stats of the Pokémon

	movelvls: {{integer list}, {integer list}} -> A pair of tables (1:RSE/2:FRLG) declaring the levels at which a Pokémon learns new moves or an empty list means it learns nothing

	weight: string -> Weight of the Pokémon in lbs for low kick power calculation
]]
PokemonData = {
	{ -- Empty entry for ID 0
		name = "---",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "Bulbasaur",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = "16",
		bst = "318",
		movelvls = { { 7, 10, 15, 15, 20, 25, 32, 39, 46 }, { 7, 10, 15, 15, 20, 25, 32, 39, 46 } },
		weight = "15.2"
	},
	{
		name = "Ivysaur",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = "32",
		bst = "405",
		movelvls = { { 7, 10, 15, 15, 22, 29, 38, 47, 56 }, { 7, 10, 15, 15, 22, 29, 38, 47, 56 } },
		weight = "28.7"
	},
	{
		name = "Venusaur",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 7, 10, 15, 15, 22, 29, 41, 53, 65 }, { 7, 10, 15, 15, 22, 29, 41, 53, 65 } },
		weight = "220.5"
	},
	{
		name = "Charmander",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "309",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "18.7"
	},
	{
		name = "Charmeleon",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 7, 13, 20, 27, 34, 41, 48, 55 }, { 7, 13, 20, 27, 34, 41, 48, 55 } },
		weight = "41.9"
	},
	{
		name = "Charizard",
		type = { PokemonTypes.FIRE, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "534",
		movelvls = { { 7, 13, 20, 27, 34, 36, 44, 54, 64 }, { 7, 13, 20, 27, 34, 36, 44, 54, 64 } },
		weight = "199.5"
	},
	{
		name = "Squirtle",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "314",
		movelvls = { { 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = "19.8"
	},
	{
		name = "Wartortle",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 7, 10, 13, 19, 25, 31, 37, 45, 53 }, { 7, 10, 13, 19, 25, 31, 37, 45, 53 } },
		weight = "49.6"
	},
	{
		name = "Blastoise",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "530",
		movelvls = { { 7, 10, 13, 19, 25, 31, 42, 55, 68 }, { 7, 10, 13, 19, 25, 31, 42, 55, 68 } },
		weight = "188.5"
	},
	{
		name = "Caterpie",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = "7",
		bst = "195",
		movelvls = { {}, {} },
		weight = "6.4"
	},
	{
		name = "Metapod",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = "21.8"
	},
	{
		name = "Butterfree",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "385",
		movelvls = { { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 }, { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 } },
		weight = "70.5"
	},
	{
		name = "Weedle",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = "7",
		bst = "195",
		movelvls = { {}, {} },
		weight = "7.1"
	},
	{
		name = "Kakuna",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = "22.0"
	},
	{
		name = "Beedrill",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "385",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45 }, { 10, 15, 20, 25, 30, 35, 40, 45 } },
		weight = "65.0"
	},
	{
		name = "Pidgey",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "18",
		bst = "251",
		movelvls = { { 9, 13, 19, 25, 31, 39, 47 }, { 9, 13, 19, 25, 31, 39, 47 } },
		weight = "4.0"
	},
	{
		name = "Pidgeotto",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "36",
		bst = "349",
		movelvls = { { 9, 13, 20, 27, 34, 43, 52 }, { 9, 13, 20, 27, 34, 43, 52 } },
		weight = "66.1"
	},
	{
		name = "Pidgeot",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "469",
		movelvls = { { 9, 13, 20, 27, 34, 48, 62 }, { 9, 13, 20, 27, 34, 48, 62 } },
		weight = "87.1"
	},
	{
		name = "Rattata",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "20",
		bst = "253",
		movelvls = { { 7, 13, 20, 27, 34, 41 }, { 7, 13, 20, 27, 34, 41 } },
		weight = "7.7"
	},
	{
		name = "Raticate",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "413",
		movelvls = { { 7, 13, 20, 30, 40, 50 }, { 7, 13, 20, 30, 40, 50 } },
		weight = "40.8"
	},
	{
		name = "Spearow",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "20",
		bst = "262",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = "4.4"
	},
	{
		name = "Fearow",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "442",
		movelvls = { { 7, 13, 26, 32, 40, 47 }, { 7, 13, 26, 32, 40, 47 } },
		weight = "83.8"
	},
	{
		name = "Ekans",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = "22",
		bst = "288",
		movelvls = { { 8, 13, 20, 25, 32, 37, 37, 37, 44 }, { 8, 13, 20, 25, 32, 37, 37, 37, 44 } },
		weight = "15.2"
	},
	{
		name = "Arbok",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "438",
		movelvls = { { 8, 13, 20, 28, 38, 46, 46, 46, 56 }, { 8, 13, 20, 28, 38, 46, 46, 46, 56 } },
		weight = "143.3"
	},
	{
		name = "Pikachu",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.THUNDER,
		bst = "300",
		movelvls = { { 6, 8, 11, 15, 20, 26, 33, 41, 50 }, { 6, 8, 11, 15, 20, 26, 33, 41, 50 } },
		weight = "13.0"
	},
	{
		name = "Raichu",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "475",
		movelvls = { {}, {} },
		weight = "66.0"
	},
	{
		name = "Sandshrew",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = "22",
		bst = "300",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = "26.0"
	},
	{
		name = "Sandslash",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "450",
		movelvls = { { 6, 11, 17, 24, 33, 42, 52, 62 }, { 6, 11, 17, 24, 33, 42, 52, 62 } },
		weight = "65.0"
	},
	{
		name = "Nidoran F",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "275",
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = "15.4"
	},
	{
		name = "Nidorina",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.MOON,
		bst = "365",
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = "44.1"
	},
	{
		name = "Nidoqueen",
		type = { PokemonTypes.POISON, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 23 }, { 22, 43 } },
		weight = "132.3"
	},
	{
		name = "Nidoran M",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "273",
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = "19.8"
	},
	{
		name = "Nidorino",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.MOON,
		bst = "365",
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = "43.0"
	},
	{
		name = "Nidoking",
		type = { PokemonTypes.POISON, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 23 }, { 22, 43 } },
		weight = "136.7"
	},
	{
		name = "Clefairy",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.MOON,
		bst = "323",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = "16.5"
	},
	{
		name = "Clefable",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "473",
		movelvls = { {}, {} },
		weight = "88.2"
	},
	{
		name = "Vulpix",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FIRE,
		bst = "299",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = "22.0"
	},
	{
		name = "Ninetales",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "505",
		movelvls = { { 45 }, { 45 } },
		weight = "44.0"
	},
	{
		name = "Jigglypuff",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.MOON,
		bst = "270",
		movelvls = { { 9, 14, 19, 24, 29, 34, 39, 44, 49 }, { 9, 14, 19, 24, 29, 34, 39, 44, 49 } },
		weight = "12.0"
	},
	{
		name = "Wigglytuff",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "425",
		movelvls = { {}, {} },
		weight = "26.0"
	},
	{
		name = "Zubat",
		type = { PokemonTypes.POISON, PokemonTypes.FLYING },
		evolution = "22",
		bst = "245",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "17.0"
	},
	{
		name = "Golbat",
		type = { PokemonTypes.POISON, PokemonTypes.FLYING },
		evolution = EvolutionTypes.FRIEND,
		bst = "455",
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = "121.0"
	},
	{
		name = "Oddish",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = "21",
		bst = "320",
		movelvls = { { 7, 14, 16, 18, 23, 32, 39 }, { 7, 14, 16, 18, 23, 32, 39 } },
		weight = "12.0"
	},
	{
		name = "Gloom",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = EvolutionTypes.LEAF_SUN,
		bst = "395",
		movelvls = { { 7, 14, 16, 18, 24, 35, 44 }, { 7, 14, 16, 18, 24, 35, 44 } },
		weight = "12.0"
	},
	{
		name = "Vileplume",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { { 44 }, { 44 } },
		weight = "41.0"
	},
	{
		name = "Paras",
		type = { PokemonTypes.BUG, PokemonTypes.GRASS },
		evolution = "24",
		bst = "285",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "11.9"
	},
	{
		name = "Parasect",
		type = { PokemonTypes.BUG, PokemonTypes.GRASS },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = "65.0"
	},
	{
		name = "Venonat",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = "31",
		bst = "305",
		movelvls = { { 9, 17, 20, 25, 28, 33, 36, 41 }, { 9, 17, 20, 25, 28, 33, 36, 41 } },
		weight = "66.1"
	},
	{
		name = "Venomoth",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "450",
		movelvls = { { 9, 17, 20, 25, 28, 31, 36, 42, 52 }, { 9, 17, 20, 25, 28, 31, 36, 42, 52 } },
		weight = "27.6"
	},
	{
		name = "Diglett",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = "26",
		bst = "265",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 21, 25, 33, 41, 49 } },
		weight = "1.8"
	},
	{
		name = "Dugtrio",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { { 9, 17, 25, 26, 38, 51, 64 }, { 9, 17, 21, 25, 26, 38, 51, 64 } },
		weight = "73.4"
	},
	{
		name = "Meowth",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "28",
		bst = "290",
		movelvls = { { 11, 20, 28, 35, 41, 46, 50 }, { 10, 18, 25, 31, 36, 40, 43, 45 } },
		weight = "9.3"
	},
	{
		name = "Persian",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "440",
		movelvls = { { 11, 20, 29, 38, 46, 53, 59 }, { 10, 18, 25, 34, 42, 49, 55, 61 } },
		weight = "70.5"
	},
	{
		name = "Psyduck",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "33",
		bst = "320",
		movelvls = { { 10, 16, 23, 31, 40, 50 }, { 10, 16, 23, 31, 40, 50 } },
		weight = "43.0"
	},
	{
		name = "Golduck",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 10, 16, 23, 31, 44, 58 }, { 10, 16, 23, 31, 44, 58 } },
		weight = "169.0"
	},
	{
		name = "Mankey",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = "28",
		bst = "305",
		movelvls = { { 9, 15, 21, 27, 33, 39, 45, 51 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "61.7"
	},
	{
		name = "Primeape",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 9, 15, 21, 27, 28, 36, 45, 54, 63 }, { 6, 11, 16, 21, 26, 28, 35, 44, 53, 62 } },
		weight = "70.5"
	},
	{
		name = "Growlithe",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FIRE,
		bst = "350",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "41.9"
	},
	{
		name = "Arcanine",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "555",
		movelvls = { { 49 }, { 49 } },
		weight = "341.7"
	},
	{
		name = "Poliwag",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "25",
		bst = "300",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = "27.3"
	},
	{
		name = "Poliwhirl",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "37/WTR", -- Level 37 replaces trade evolution for Politoed
		bst = "385",
		movelvls = { { 7, 13, 19, 27, 35, 43, 51 }, { 7, 13, 19, 27, 35, 43, 51 } },
		weight = "44.1"
	},
	{
		name = "Poliwrath",
		type = { PokemonTypes.WATER, PokemonTypes.FIGHTING },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = "119.0"
	},
	{
		name = "Abra",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { {}, {} },
		weight = "43.0"
	},
	{
		name = "Kadabra",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "400",
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = "125.0"
	},
	{
		name = "Alakazam",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = "106.0"
	},
	{
		name = "Machop",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = "28",
		bst = "305",
		movelvls = { { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 }, { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 } },
		weight = "43.0"
	},
	{
		name = "Machoke",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "405",
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = "155.0"
	},
	{
		name = "Machamp",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "505",
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = "287.0"
	},
	{
		name = "Bellsprout",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = "21",
		bst = "300",
		movelvls = { { 6, 11, 15, 17, 19, 23, 30, 37, 45 }, { 6, 11, 15, 17, 19, 23, 30, 37, 45 } },
		weight = "8.8"
	},
	{
		name = "Weepinbell",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = EvolutionTypes.LEAF,
		bst = "390",
		movelvls = { { 6, 11, 15, 17, 19, 24, 33, 42, 54 }, { 6, 11, 15, 17, 19, 24, 33, 42, 54 } },
		weight = "14.1"
	},
	{
		name = "Victreebel",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { {}, {} },
		weight = "34.2"
	},
	{
		name = "Tentacool",
		type = { PokemonTypes.WATER, PokemonTypes.POISON },
		evolution = "30",
		bst = "335",
		movelvls = { { 6, 12, 19, 25, 30, 36, 43, 49 }, { 6, 12, 19, 25, 30, 36, 43, 49 } },
		weight = "100"
	},
	{
		name = "Tentacruel",
		type = { PokemonTypes.WATER, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "515",
		movelvls = { { 6, 12, 19, 25, 30, 38, 47, 55 }, { 6, 12, 19, 25, 30, 38, 47, 55 } },
		weight = "121"
	},
	{
		name = "Geodude",
		type = { PokemonTypes.ROCK, PokemonTypes.GROUND },
		evolution = "25",
		bst = "300",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "44"
	},
	{
		name = "Graveler",
		type = { PokemonTypes.ROCK, PokemonTypes.GROUND },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "390",
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = "232"
	},
	{
		name = "Golem",
		type = { PokemonTypes.ROCK, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "485",
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = "662"
	},
	{
		name = "Ponyta",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "40",
		bst = "410",
		movelvls = { { 9, 14, 19, 25, 31, 38, 45, 53 }, { 9, 14, 19, 25, 31, 38, 45, 53 } },
		weight = "66.1"
	},
	{
		name = "Rapidash",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 9, 14, 19, 25, 31, 38, 40, 50, 63 }, { 9, 14, 19, 25, 31, 38, 40, 50, 63 } },
		weight = "209.0"
	},
	{
		name = "Slowpoke",
		type = { PokemonTypes.WATER, PokemonTypes.PSYCHIC },
		evolution = "37/WTR", -- Water stone replaces trade evolution to Slowking
		bst = "315",
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = "79.4"
	},
	{
		name = "Slowbro",
		type = { PokemonTypes.WATER, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 6, 15, 20, 29, 34, 37, 46, 54 }, { 6, 13, 17, 24, 29, 36, 37, 44, 55 } },
		weight = "173.0"
	},
	{
		name = "Magnemite",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.STEEL },
		evolution = "30",
		bst = "325",
		movelvls = { { 6, 11, 16, 21, 26, 32, 38, 44, 50 }, { 6, 11, 16, 21, 26, 32, 38, 44, 50 } },
		weight = "13.0"
	},
	{
		name = "Magneton",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.STEEL },
		evolution = EvolutionTypes.NONE,
		bst = "465",
		movelvls = { { 6, 11, 16, 21, 26, 35, 44, 53, 62 }, { 6, 11, 16, 21, 26, 35, 44, 53, 62 } },
		weight = "132.0"
	},
	{
		name = "Farfetch'd",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "352",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "33.1"
	},
	{
		name = "Doduo",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "31",
		bst = "310",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45 }, { 9, 13, 21, 25, 33, 37, 45 } },
		weight = "86.0"
	},
	{
		name = "Dodrio",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 9, 13, 21, 25, 38, 47, 60 }, { 9, 13, 21, 25, 38, 47, 60 } },
		weight = "188.0"
	},
	{
		name = "Seel",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "34",
		bst = "325",
		movelvls = { { 9, 17, 21, 29, 37, 41, 49 }, { 9, 17, 21, 29, 37, 41, 49 } },
		weight = "198.0"
	},
	{
		name = "Dewgong",
		type = { PokemonTypes.WATER, PokemonTypes.ICE },
		evolution = EvolutionTypes.NONE,
		bst = "475",
		movelvls = { { 9, 17, 21, 29, 34, 42, 51, 64 }, { 9, 17, 21, 29, 34, 42, 51, 64 } },
		weight = "265.0"
	},
	{
		name = "Grimer",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = "38",
		bst = "325",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = "66.0"
	},
	{
		name = "Muk", -- PUMP SLOP
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 8, 13, 19, 26, 34, 47, 61 }, { 8, 13, 19, 26, 34, 47, 61 } },
		weight = "66.0"
	},
	{
		name = "Shellder",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.WATER,
		bst = "305",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "8.8"
	},
	{
		name = "Cloyster",
		type = { PokemonTypes.WATER, PokemonTypes.ICE },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 33, 41 }, { 36, 43 } },
		weight = "292.1"
	},
	{
		name = "Gastly",
		type = { PokemonTypes.GHOST, PokemonTypes.POISON },
		evolution = "25",
		bst = "310",
		movelvls = { { 8, 13, 16, 21, 28, 33, 36 }, { 8, 13, 16, 21, 28, 33, 36, 41, 48 } },
		weight = "0.2"
	},
	{
		name = "Haunter",
		type = { PokemonTypes.GHOST, PokemonTypes.POISON },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "405",
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = "0.2"
	},
	{
		name = "Gengar",
		type = { PokemonTypes.GHOST, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = "89.3"
	},
	{
		name = "Onix",
		type = { PokemonTypes.ROCK, PokemonTypes.GROUND },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "385",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = "463.0"
	},
	{
		name = "Drowzee",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "26",
		bst = "328",
		movelvls = { { 10, 18, 25, 31, 36, 40, 43, 45 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = "71.4"
	},
	{
		name = "Hypno",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "483",
		movelvls = { { 10, 18, 25, 33, 40, 49, 55, 60 }, { 7, 11, 17, 21, 29, 35, 43, 49, 57 } },
		weight = "166.7"
	},
	{
		name = "Krabby",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "28",
		bst = "325",
		movelvls = { { 12, 16, 23, 27, 34, 41, 45 }, { 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = "14.3"
	},
	{
		name = "Kingler",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "475",
		movelvls = { { 12, 16, 23, 27, 38, 49, 57 }, { 12, 16, 23, 27, 38, 42, 57, 65 } },
		weight = "132.3"
	},
	{
		name = "Voltorb",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "330",
		movelvls = { { 8, 15, 21, 27, 32, 37, 42, 46, 49 }, { 8, 15, 21, 27, 32, 37, 42, 46, 49 } },
		weight = "23.0"
	},
	{
		name = "Electrode",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { { 8, 15, 21, 27, 34, 41, 48, 54, 59 }, { 8, 15, 21, 27, 34, 41, 48, 54, 59 } },
		weight = "147.0"
	},
	{
		name = "Exeggcute",
		type = { PokemonTypes.GRASS, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.LEAF,
		bst = "325",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = "5.5"
	},
	{
		name = "Exeggutor",
		type = { PokemonTypes.GRASS, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "520",
		movelvls = { { 19, 31 }, { 19, 31 } },
		weight = "264.6"
	},
	{
		name = "Cubone",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = "28",
		bst = "320",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = "14.3"
	},
	{
		name = "Marowak",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "425",
		movelvls = { { 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 }, { 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 } },
		weight = "99.2"
	},
	{
		name = "Hitmonlee",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 }, { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 } },
		weight = "109.8"
	},
	{
		name = "Hitmonchan",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 }, { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 } },
		weight = "110.7"
	},
	{
		name = "Lickitung",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "385",
		movelvls = { { 7, 12, 18, 23, 29, 34, 40, 45, 51 }, { 7, 12, 18, 23, 29, 34, 40, 45, 51 } },
		weight = "144.4"
	},
	{
		name = "Koffing",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = "35",
		bst = "340",
		movelvls = { { 9, 17, 21, 25, 33, 41, 45, 49 }, { 9, 17, 21, 25, 33, 41, 45, 49 } },
		weight = "2.0"
	},
	{
		name = "Weezing",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 9, 17, 21, 25, 33, 44, 51, 58 }, { 9, 17, 21, 25, 33, 44, 51, 58 } },
		weight = "21.0"
	},
	{
		name = "Rhyhorn",
		type = { PokemonTypes.GROUND, PokemonTypes.ROCK },
		evolution = "42",
		bst = "345",
		movelvls = { { 10, 15, 24, 29, 38, 43, 52, 57 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = "254.0"
	},
	{
		name = "Rhydon",
		type = { PokemonTypes.GROUND, PokemonTypes.ROCK },
		evolution = EvolutionTypes.NONE,
		bst = "485",
		movelvls = { { 10, 15, 24, 29, 38, 46, 58, 66 }, { 10, 15, 24, 29, 38, 46, 58, 66 } },
		weight = "265.0"
	},
	{
		name = "Chansey",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FRIEND,
		bst = "450",
		movelvls = { { 9, 13, 17, 23, 29, 35, 41, 49, 57 }, { 9, 13, 17, 23, 29, 35, 41, 49, 57 } },
		weight = "76.3"
	},
	{
		name = "Tangela",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "435",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 46 }, { 10, 13, 19, 22, 28, 31, 37, 40, 46 } },
		weight = "7.2"
	},
	{
		name = "Kangaskhan",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "176.4"
	},
	{
		name = "Horsea",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "32",
		bst = "295",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "18.0"
	},
	{
		name = "Seadra",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "40", -- Level 40 replaces trade evolution
		bst = "440",
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = "55.0"
	},
	{
		name = "Goldeen",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "33",
		bst = "320",
		movelvls = { { 10, 15, 24, 29, 38, 43, 52 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = "33.0"
	},
	{
		name = "Seaking",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "450",
		movelvls = { { 10, 15, 24, 29, 41, 49, 61 }, { 10, 15, 24, 29, 41, 49, 61, 69 } },
		weight = "86.0"
	},
	{
		name = "Staryu",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.WATER,
		bst = "340",
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = "76.0"
	},
	{
		name = "Starmie",
		type = { PokemonTypes.WATER, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "520",
		movelvls = { { 33 }, { 33 } },
		weight = "176.0"
	},
	{
		name = "Mr. Mime",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 9, 13, 17, 21, 21, 25, 29, 33, 37, 41, 45, 49, 53 }, { 8, 12, 15, 19, 19, 22, 26, 29, 33, 36, 40, 43, 47, 50 } },
		weight = "120.1"
	},
	{
		name = "Scyther",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "500",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "123.5"
	},
	{
		name = "Jynx",
		type = { PokemonTypes.ICE, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 9, 13, 21, 25, 35, 41, 51, 57, 67 }, { 9, 13, 21, 25, 35, 41, 51, 57, 67 } },
		weight = "71.4"
	},
	{
		name = "Electabuzz",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 9, 17, 25, 36, 47, 58 }, { 9, 17, 25, 36, 47, 58 } },
		weight = "66.1"
	},
	{
		name = "Magmar", -- MAMGAR
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 7, 13, 19, 25, 33, 41, 49, 57 }, { 7, 13, 19, 25, 33, 41, 49, 57 } },
		weight = "98.1"
	},
	{
		name = "Pinsir",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "121.0"
	},
	{
		name = "Tauros",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = "194.9"
	},
	{
		name = "Magikarp",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "20",
		bst = "200",
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = "22.0"
	},
	{
		name = "Gyarados",
		type = { PokemonTypes.WATER, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "540",
		movelvls = { { 20, 25, 30, 35, 40, 45, 50, 55 }, { 20, 25, 30, 35, 40, 45, 50, 55 } },
		weight = "518.0"
	},
	{
		name = "Lapras",
		type = { PokemonTypes.WATER, PokemonTypes.ICE },
		evolution = EvolutionTypes.NONE,
		bst = "535",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = "48.5"
	},
	{
		name = "Ditto",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "288",
		movelvls = { {}, {} },
		weight = "8.8"
	},
	{
		name = "Eevee",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.STONES,
		bst = "325",
		movelvls = { { 8, 16, 23, 30, 36, 42 }, { 8, 16, 23, 30, 36, 42 } },
		weight = "14.3"
	},
	{
		name = "Vaporeon",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = "63.9"
	},
	{
		name = "Jolteon",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = "54.0"
	},
	{
		name = "Flareon",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = "55.1"
	},
	{
		name = "Porygon",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "395",
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = "80.5"
	},
	{
		name = "Omanyte",
		type = { PokemonTypes.ROCK, PokemonTypes.WATER },
		evolution = "40",
		bst = "355",
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = "16.5"
	},
	{
		name = "Omastar", -- LORD HELIX
		type = { PokemonTypes.ROCK, PokemonTypes.WATER },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = "77.2"
	},
	{
		name = "Kabuto",
		type = { PokemonTypes.ROCK, PokemonTypes.WATER },
		evolution = "40",
		bst = "355",
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = "25.4"
	},
	{
		name = "Kabutops",
		type = { PokemonTypes.ROCK, PokemonTypes.WATER },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = "89.3"
	},
	{
		name = "Aerodactyl",
		type = { PokemonTypes.ROCK, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "515",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "130.1"
	},
	{
		name = "Snorlax",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "540",
		movelvls = { { 6, 10, 15, 19, 24, 28, 28, 33, 37, 42, 46, 51 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53 } },
		weight = "1041.1"
	},
	{
		name = "Articuno",
		type = { PokemonTypes.ICE, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = "122.1"
	},
	{
		name = "Zapdos",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = "116.0"
	},
	{
		name = "Moltres",
		type = { PokemonTypes.FIRE, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = "132.3"
	},
	{
		name = "Dratini",
		type = { PokemonTypes.DRAGON, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "300",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = "7.3"
	},
	{
		name = "Dragonair",
		type = { PokemonTypes.DRAGON, PokemonTypes.EMPTY },
		evolution = "55",
		bst = "420",
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = "36.4"
	},
	{
		name = "Dragonite",
		type = { PokemonTypes.DRAGON, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 8, 15, 22, 29, 38, 47, 55, 61, 75 }, { 8, 15, 22, 29, 38, 47, 55, 61, 75 } },
		weight = "463.0"
	},
	{
		name = "Mewtwo",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "680",
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = "269.0"
	},
	{
		name = "Mew",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = "8.8"
	},
	{
		name = "Chikorita",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "318",
		movelvls = { { 8, 12, 15, 22, 29, 36, 43, 50 }, { 8, 12, 15, 22, 29, 36, 43, 50 } },
		weight = "14.1"
	},
	{
		name = "Bayleef",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "32",
		bst = "405",
		movelvls = { { 8, 12, 15, 23, 31, 39, 47, 55 }, { 8, 12, 15, 23, 31, 39, 47, 55 } },
		weight = "34.8"
	},
	{
		name = "Meganium",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 8, 12, 15, 23, 31, 41, 51, 61 }, { 8, 12, 15, 23, 31, 41, 51, 61 } },
		weight = "221.6"
	},
	{
		name = "Cyndaquil",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "14",
		bst = "309",
		movelvls = { { 6, 12, 19, 27, 36, 46 }, { 6, 12, 19, 27, 36, 46 } },
		weight = "17.4"
	},
	{
		name = "Quilava",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 6, 12, 21, 31, 42, 54 }, { 6, 12, 21, 31, 42, 54 } },
		weight = "41.9"
	},
	{
		name = "Typhlosion",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "534",
		movelvls = { { 6, 12, 21, 31, 45, 60 }, { 6, 12, 21, 31, 45, 60 } },
		weight = "175.3"
	},
	{
		name = "Totodile",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "18",
		bst = "314",
		movelvls = { { 7, 13, 20, 27, 35, 43, 52 }, { 7, 13, 20, 27, 35, 43, 52 } },
		weight = "20.9"
	},
	{
		name = "Croconaw",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "405",
		movelvls = { { 7, 13, 21, 28, 37, 45, 55 }, { 7, 13, 21, 28, 37, 45, 55 } },
		weight = "55.1"
	},
	{
		name = "Feraligatr",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "530",
		movelvls = { { 7, 13, 21, 28, 38, 47, 58 }, { 7, 13, 21, 28, 38, 47, 58 } },
		weight = "195.8"
	},
	{
		name = "Sentret",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "15",
		bst = "215",
		movelvls = { { 7, 12, 17, 24, 31, 40, 49 }, { 7, 12, 17, 24, 31, 40, 49 } },
		weight = "13.2"
	},
	{
		name = "Furret",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "415",
		movelvls = { { 7, 12, 19, 28, 37, 48, 59 }, { 7, 12, 19, 28, 37, 48, 59 } },
		weight = "71.6"
	},
	{
		name = "Hoothoot",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "20",
		bst = "262",
		movelvls = { { 6, 11, 16, 22, 28, 34, 48 }, { 6, 11, 16, 22, 28, 34, 48 } },
		weight = "46.7"
	},
	{
		name = "Noctowl",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "442",
		movelvls = { { 6, 11, 16, 25, 33, 41, 57 }, { 6, 11, 16, 25, 33, 41, 57 } },
		weight = "89.9"
	},
	{
		name = "Ledyba",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = "18",
		bst = "265",
		movelvls = { { 8, 15, 22, 22, 22, 29, 36, 43, 50 }, { 8, 15, 22, 22, 22, 29, 36, 43, 50 } },
		weight = "23.8"
	},
	{
		name = "Ledian",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "390",
		movelvls = { { 8, 15, 24, 24, 24, 33, 42, 51, 60 }, { 8, 15, 24, 24, 24, 33, 42, 51, 60 } },
		weight = "78.5"
	},
	{
		name = "Spinarak",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = "22",
		bst = "250",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = "18.7"
	},
	{
		name = "Ariados",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "390",
		movelvls = { { 6, 11, 17, 25, 34, 43, 53, 63 }, { 6, 11, 17, 25, 34, 43, 53, 63 } },
		weight = "73.9"
	},
	{
		name = "Crobat",
		type = { PokemonTypes.POISON, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "535",
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = "165.3"
	},
	{
		name = "Chinchou",
		type = { PokemonTypes.WATER, PokemonTypes.ELECTRIC },
		evolution = "27",
		bst = "330",
		movelvls = { { 13, 17, 25, 29, 37, 41, 49 }, { 13, 17, 25, 29, 37, 41, 49 } },
		weight = "26.0"
	},
	{
		name = "Lanturn",
		type = { PokemonTypes.WATER, PokemonTypes.ELECTRIC },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 13, 17, 25, 32, 43, 50, 61 }, { 13, 17, 25, 32, 43, 50, 61 } },
		weight = "50.0"
	},
	{
		name = "Pichu",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FRIEND,
		bst = "205",
		movelvls = { { 6, 8, 11 }, { 6, 8, 11 } },
		weight = "4.0"
	},
	{
		name = "Cleffa",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FRIEND,
		bst = "218",
		movelvls = { { 8, 13 }, { 8, 13, 17 } },
		weight = "6.6"
	},
	{
		name = "Igglybuff",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FRIEND,
		bst = "210",
		movelvls = { { 9, 14 }, { 9, 14 } },
		weight = "2.0"
	},
	{
		name = "Togepi",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FRIEND,
		bst = "245",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = "3.3"
	},
	{
		name = "Togetic",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = "7.1"
	},
	{
		name = "Natu",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.FLYING },
		evolution = "25",
		bst = "320",
		movelvls = { { 10, 20, 30, 30, 40, 50 }, { 10, 20, 30, 30, 40, 50 } },
		weight = "4.0"
	},
	{
		name = "Xatu",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "470",
		movelvls = { { 10, 20, 35, 35, 50, 65 }, { 10, 20, 35, 35, 50, 65 } },
		weight = "33.0"
	},
	{
		name = "Mareep",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = "15",
		bst = "280",
		movelvls = { { 9, 16, 23, 30, 37 }, { 9, 16, 23, 30, 37 } },
		weight = "17.2"
	},
	{
		name = "Flaaffy",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "365",
		movelvls = { { 9, 18, 27, 36, 45 }, { 9, 18, 27, 36, 45 } },
		weight = "29.3"
	},
	{
		name = "Ampharos",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 9, 18, 27, 30, 42, 57 }, { 9, 18, 27, 30, 42, 57 } },
		weight = "135.6"
	},
	{
		name = "Bellossom",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { { 44, 55 }, { 44, 55 } },
		weight = "13.0"
	},
	{
		name = "Marill",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "18",
		bst = "250",
		movelvls = { { 6, 10, 15, 21, 28, 36, 45 }, { 6, 10, 15, 21, 28, 36, 45 } },
		weight = "18.0"
	},
	{
		name = "Azumarill",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "410",
		movelvls = { { 6, 10, 15, 24, 34, 45, 57 }, { 6, 10, 15, 24, 34, 45, 57 } },
		weight = "63.0"
	},
	{
		name = "Sudowoodo",
		type = { PokemonTypes.ROCK, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "410",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = "83.8"
	},
	{
		name = "Politoed",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = "74.7"
	},
	{
		name = "Hoppip",
		type = { PokemonTypes.GRASS, PokemonTypes.FLYING },
		evolution = "18",
		bst = "250",
		movelvls = { { 10, 13, 15, 17, 20, 25, 30 }, { 10, 13, 15, 17, 20, 25, 30 } },
		weight = "1.1"
	},
	{
		name = "Skiploom",
		type = { PokemonTypes.GRASS, PokemonTypes.FLYING },
		evolution = "27",
		bst = "340",
		movelvls = { { 10, 13, 15, 17, 22, 29, 36 }, { 10, 13, 15, 17, 22, 29, 36 } },
		weight = "2.2"
	},
	{
		name = "Jumpluff",
		type = { PokemonTypes.GRASS, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "450",
		movelvls = { { 10, 13, 15, 17, 22, 33, 44 }, { 10, 13, 15, 17, 22, 33, 44 } },
		weight = "6.6"
	},
	{
		name = "Aipom",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "360",
		movelvls = { { 6, 13, 18, 25, 31, 38, 43, 50 }, { 6, 13, 18, 25, 31, 38, 43, 50 } },
		weight = "25.4"
	},
	{
		name = "Sunkern",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.SUN,
		bst = "180",
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = "4.0"
	},
	{
		name = "Sunflora",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "425",
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = "18.7"
	},
	{
		name = "Yanma",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "390",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 6, 12, 17, 23, 28, 34, 39, 45, 50 } },
		weight = "83.8"
	},
	{
		name = "Wooper",
		type = { PokemonTypes.WATER, PokemonTypes.GROUND },
		evolution = "20",
		bst = "210",
		movelvls = { { 11, 16, 21, 31, 36, 41, 51, 51 }, { 11, 16, 21, 31, 36, 41, 51, 51 } },
		weight = "18.7"
	},
	{
		name = "Quagsire",
		type = { PokemonTypes.WATER, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "430",
		movelvls = { { 11, 16, 23, 35, 42, 49, 61, 61 }, { 11, 16, 23, 35, 42, 49, 61, 61 } },
		weight = "165.3"
	},
	{
		name = "Espeon",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = "58.4"
	},
	{
		name = "Umbreon",
		type = { PokemonTypes.DARK, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "525",
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = "59.5"
	},
	{
		name = "Murkrow",
		type = { PokemonTypes.DARK, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { { 9, 14, 22, 27, 35, 40, 48 }, { 9, 14, 22, 27, 35, 40, 48 } },
		weight = "4.6"
	},
	{
		name = "Slowking",
		type = { PokemonTypes.WATER, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = "175.3"
	},
	{
		name = "Misdreavus",
		type = { PokemonTypes.GHOST, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "435",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = "2.2"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Wobbuffet",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { {}, {} },
		weight = "63.0"
	},
	{
		name = "Girafarig",
		type = { PokemonTypes.NORMAL, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "91.0"
	},
	{
		name = "Pineco",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = "31",
		bst = "290",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "15.9"
	},
	{
		name = "Forretress",
		type = { PokemonTypes.BUG, PokemonTypes.STEEL },
		evolution = EvolutionTypes.NONE,
		bst = "465",
		movelvls = { { 8, 15, 22, 29, 39, 49, 59 }, { 8, 15, 22, 29, 31, 39, 49, 59 } },
		weight = "277.3"
	},
	{
		name = "Dunsparce",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "415",
		movelvls = { { 11, 14, 21, 24, 31, 34, 41 }, { 11, 14, 21, 24, 31, 34, 41, 44, 51 } },
		weight = "15.9"
	},
	{
		name = "Gligar",
		type = { PokemonTypes.GROUND, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "430",
		movelvls = { { 6, 13, 20, 28, 36, 44, 52 }, { 6, 13, 20, 28, 36, 44, 52 } },
		weight = "142.9"
	},
	{
		name = "Steelix",
		type = { PokemonTypes.STEEL, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "510",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = "881.8"
	},
	{
		name = "Snubbull",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "23",
		bst = "300",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = "17.2"
	},
	{
		name = "Granbull",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "450",
		movelvls = { { 8, 13, 19, 28, 38, 49, 61 }, { 8, 13, 19, 28, 38, 49, 61 } },
		weight = "107.4"
	},
	{
		name = "Qwilfish",
		type = { PokemonTypes.WATER, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "430",
		movelvls = { { 10, 10, 19, 28, 37, 46 }, { 9, 9, 13, 21, 25, 33, 37, 45 } },
		weight = "8.6"
	},
	{
		name = "Scizor",
		type = { PokemonTypes.BUG, PokemonTypes.STEEL },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "260.1"
	},
	{
		name = "Shuckle",
		type = { PokemonTypes.BUG, PokemonTypes.ROCK },
		evolution = EvolutionTypes.NONE,
		bst = "505",
		movelvls = { { 9, 14, 23, 28, 37 }, { 9, 14, 23, 28, 37 } },
		weight = "45.2"
	},
	{
		name = "Heracross",
		type = { PokemonTypes.BUG, PokemonTypes.FIGHTING },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = "120.0"
	},
	{
		name = "Sneasel",
		type = { PokemonTypes.DARK, PokemonTypes.ICE },
		evolution = EvolutionTypes.NONE,
		bst = "430",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = "61.7"
	},
	{
		name = "Teddiursa",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "330",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "19.4"
	},
	{
		name = "Ursaring",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "277.3"
	},
	{
		name = "Slugma",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "38",
		bst = "250",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "77.0"
	},
	{
		name = "Magcargo",
		type = { PokemonTypes.FIRE, PokemonTypes.ROCK },
		evolution = EvolutionTypes.NONE,
		bst = "410",
		movelvls = { { 8, 15, 22, 29, 36, 48, 60 }, { 8, 15, 22, 29, 36, 48, 60 } },
		weight = "121.0"
	},
	{
		name = "Swinub",
		type = { PokemonTypes.ICE, PokemonTypes.GROUND },
		evolution = "33",
		bst = "250",
		movelvls = { { 10, 19, 28, 37, 46, 55 }, { 10, 19, 28, 37, 46, 55 } },
		weight = "14.3"
	},
	{
		name = "Piloswine",
		type = { PokemonTypes.ICE, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "450",
		movelvls = { { 10, 19, 28, 33, 42, 56, 70 }, { 10, 19, 28, 33, 42, 56, 70 } },
		weight = "123.0"
	},
	{
		name = "Corsola",
		type = { PokemonTypes.WATER, PokemonTypes.ROCK },
		evolution = EvolutionTypes.NONE,
		bst = "380",
		movelvls = { { 6, 12, 17, 17, 23, 28, 34, 39, 45 }, { 6, 12, 17, 17, 23, 28, 34, 39, 45 } },
		weight = "11.0"
	},
	{
		name = "Remoraid",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "25",
		bst = "300",
		movelvls = { { 11, 22, 22, 22, 33, 44, 55 }, { 11, 22, 22, 22, 33, 44, 55 } },
		weight = "26.5"
	},
	{
		name = "Octillery",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { { 11, 22, 22, 22, 25, 38, 54, 70 }, { 11, 22, 22, 22, 25, 38, 54, 70 } },
		weight = "62.8"
	},
	{
		name = "Delibird",
		type = { PokemonTypes.ICE, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "330",
		movelvls = { {}, {} },
		weight = "35.3"
	},
	{
		name = "Mantine",
		type = { PokemonTypes.WATER, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "465",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "485.0"
	},
	{
		name = "Skarmory",
		type = { PokemonTypes.STEEL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "465",
		movelvls = { { 10, 13, 16, 26, 29, 32, 42, 45 }, { 10, 13, 16, 26, 29, 32, 42, 45 } },
		weight = "112.0"
	},
	{
		name = "Houndour",
		type = { PokemonTypes.DARK, PokemonTypes.FIRE },
		evolution = "24",
		bst = "330",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "23.8"
	},
	{
		name = "Houndoom",
		type = { PokemonTypes.DARK, PokemonTypes.FIRE },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = "77.2"
	},
	{
		name = "Kingdra",
		type = { PokemonTypes.WATER, PokemonTypes.DRAGON },
		evolution = EvolutionTypes.NONE,
		bst = "540",
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = "336.0"
	},
	{
		name = "Phanpy",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = "25",
		bst = "330",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = "74.0"
	},
	{
		name = "Donphan",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = "265.0"
	},
	{
		name = "Porygon2",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "515",
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = "71.6"
	},
	{
		name = "Stantler",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "465",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = "157.0"
	},
	{
		name = "Smeargle",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "250",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81, 91 }, { 11, 21, 31, 41, 51, 61, 71, 81, 91 } },
		weight = "127.9"
	},
	{
		name = "Tyrogue",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = "20",
		bst = "210",
		movelvls = { {}, {} },
		weight = "16.3"
	},
	{
		name = "Hitmontop",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 7, 13, 19, 20, 25, 31, 37, 43, 49 }, { 7, 13, 19, 20, 25, 31, 37, 43, 49 } },
		weight = "105.8"
	},
	{
		name = "Smoochum",
		type = { PokemonTypes.ICE, PokemonTypes.PSYCHIC },
		evolution = "30",
		bst = "305",
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 9, 13, 21, 25, 33, 37, 45, 49, 57 } },
		weight = "13.2"
	},
	{
		name = "Elekid",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "360",
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = "51.8"
	},
	{
		name = "Magby",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "365",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "47.2"
	},
	{
		name = "Miltank",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 8, 13, 19, 26, 34, 43, 53 }, { 8, 13, 19, 26, 34, 43, 53 } },
		weight = "166.4"
	},
	{
		name = "Blissey",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "540",
		movelvls = { { 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = "103.2"
	},
	{
		name = "Raikou",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = "392.4"
	},
	{
		name = "Entei",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = "436.5"
	},
	{
		name = "Suicune",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = "412.3"
	},
	{
		name = "Larvitar",
		type = { PokemonTypes.ROCK, PokemonTypes.GROUND },
		evolution = "30",
		bst = "300",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = "158.7"
	},
	{
		name = "Pupitar",
		type = { PokemonTypes.ROCK, PokemonTypes.GROUND },
		evolution = "55",
		bst = "410",
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = "335.1"
	},
	{
		name = "Tyranitar",
		type = { PokemonTypes.ROCK, PokemonTypes.DARK },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 8, 15, 22, 29, 38, 47, 61, 75 }, { 8, 15, 22, 29, 38, 47, 61, 75 } },
		weight = "445.3"
	},
	{
		name = "Lugia",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "680",
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = "476.2"
	},
	{
		name = "Ho-Oh",
		type = { PokemonTypes.FIRE, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "680",
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = "138.7"
	},
	{
		name = "Celebi",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.GRASS },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = "11.0"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "none",
		type = { PokemonTypes.EMPTY, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "---",
		movelvls = { {}, {} },
		weight = "---"
	},
	{
		name = "Treecko",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "11.0"
	},
	{
		name = "Grovyle",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "36",
		bst = "405",
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 }, { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 } },
		weight = "47.6"
	},
	{
		name = "Sceptile",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "530",
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 }, { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 } },
		weight = "115.1"
	},
	{
		name = "Torchic",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = "5.5"
	},
	{
		name = "Combusken",
		type = { PokemonTypes.FIRE, PokemonTypes.FIGHTING },
		evolution = "36",
		bst = "405",
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 }, { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 } },
		weight = "43.0"
	},
	{
		name = "Blaziken",
		type = { PokemonTypes.FIRE, PokemonTypes.FIGHTING },
		evolution = EvolutionTypes.NONE,
		bst = "530",
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 }, { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 } },
		weight = "114.6"
	},
	{
		name = "Mudkip",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "16",
		bst = "310",
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = "16.8"
	},
	{
		name = "Marshtomp",
		type = { PokemonTypes.WATER, PokemonTypes.GROUND },
		evolution = "36",
		bst = "405",
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 }, { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 } },
		weight = "61.7"
	},
	{
		name = "Swampert",
		type = { PokemonTypes.WATER, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "535",
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 }, { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 } },
		weight = "180.6"
	},
	{
		name = "Poochyena",
		type = { PokemonTypes.DARK, PokemonTypes.EMPTY },
		evolution = "18",
		bst = "220",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = "30.0"
	},
	{
		name = "Mightyena",
		type = { PokemonTypes.DARK, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "420",
		movelvls = { { 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 }, { 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 } },
		weight = "81.6"
	},
	{
		name = "Zigzagoon",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "20",
		bst = "240",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = "38.6"
	},
	{
		name = "Linoone",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "420",
		movelvls = { { 9, 13, 17, 23, 29, 35, 41, 47, 53 }, { 9, 13, 17, 23, 29, 35, 41, 47, 53 } },
		weight = "71.6"
	},
	{
		name = "Wurmple",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = "7",
		bst = "195",
		movelvls = { {}, {} },
		weight = "7.9"
	},
	{
		name = "Silcoon",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = "22.0"
	},
	{
		name = "Beautifly",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "385",
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = "62.6"
	},
	{
		name = "Cascoon",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = "10",
		bst = "205",
		movelvls = { { 7 }, { 7 } },
		weight = "25.4"
	},
	{
		name = "Dustox",
		type = { PokemonTypes.BUG, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "385",
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = "69.7"
	},
	{
		name = "Lotad",
		type = { PokemonTypes.WATER, PokemonTypes.GRASS },
		evolution = "14",
		bst = "220",
		movelvls = { { 7, 13, 21, 31, 43 }, { 7, 13, 21, 31, 43 } },
		weight = "5.7"
	},
	{
		name = "Lombre",
		type = { PokemonTypes.WATER, PokemonTypes.GRASS },
		evolution = EvolutionTypes.WATER,
		bst = "340",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "71.6"
	},
	{
		name = "Ludicolo",
		type = { PokemonTypes.WATER, PokemonTypes.GRASS },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { {}, {} },
		weight = "121.3"
	},
	{
		name = "Seedot",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "14",
		bst = "220",
		movelvls = { { 7, 13, 21, 31, 43 }, { 7, 13, 21, 31, 43 } },
		weight = "8.8"
	},
	{
		name = "Nuzleaf",
		type = { PokemonTypes.GRASS, PokemonTypes.DARK },
		evolution = EvolutionTypes.LEAF,
		bst = "340",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "61.7"
	},
	{
		name = "Shiftry",
		type = { PokemonTypes.GRASS, PokemonTypes.DARK },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { {}, {} },
		weight = "131.4"
	},
	{
		name = "Nincada",
		type = { PokemonTypes.BUG, PokemonTypes.GROUND },
		evolution = "20",
		bst = "266",
		movelvls = { { 9, 14, 19, 25, 31, 38, 45 }, { 9, 14, 19, 25, 31, 38, 45 } },
		weight = "12.1"
	},
	{
		name = "Ninjask",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "456",
		movelvls = { { 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 }, { 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 } },
		weight = "26.5"
	},
	{
		name = "Shedinja",
		type = { PokemonTypes.BUG, PokemonTypes.GHOST },
		evolution = EvolutionTypes.NONE,
		bst = "236",
		movelvls = { { 9, 14, 19, 25, 31, 38, 45 }, { 9, 14, 19, 25, 31, 38, 45 } },
		weight = "2.6"
	},
	{
		name = "Taillow",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "22",
		bst = "270",
		movelvls = { { 8, 13, 19, 26, 34, 43 }, { 8, 13, 19, 26, 34, 43 } },
		weight = "5.1"
	},
	{
		name = "Swellow",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "430",
		movelvls = { { 8, 13, 19, 28, 38, 49 }, { 8, 13, 19, 28, 38, 49 } },
		weight = "43.7"
	},
	{
		name = "Shroomish",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "23",
		bst = "295",
		movelvls = { { 7, 10, 16, 22, 28, 36, 45, 54 }, { 7, 10, 16, 22, 28, 36, 45, 54 } },
		weight = "9.9"
	},
	{
		name = "Breloom",
		type = { PokemonTypes.GRASS, PokemonTypes.FIGHTING },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 7, 10, 16, 22, 23, 28, 36, 45, 54 }, { 7, 10, 16, 22, 23, 28, 36, 45, 54 } },
		weight = "86.4"
	},
	{
		name = "Spinda",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "360",
		movelvls = { { 12, 16, 23, 27, 34, 38, 45, 49, 56 }, { 12, 16, 23, 27, 34, 38, 45, 49, 56 } },
		weight = "11.0"
	},
	{
		name = "Wingull",
		type = { PokemonTypes.WATER, PokemonTypes.FLYING },
		evolution = "25",
		bst = "270",
		movelvls = { { 7, 13, 21, 31, 43, 55 }, { 7, 13, 21, 31, 43, 55 } },
		weight = "20.9"
	},
	{
		name = "Pelipper",
		type = { PokemonTypes.WATER, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "430",
		movelvls = { { 7, 13, 21, 25, 33, 33, 47, 61 }, { 7, 13, 21, 25, 33, 33, 47, 61 } },
		weight = "61.7"
	},
	{
		name = "Surskit",
		type = { PokemonTypes.BUG, PokemonTypes.WATER },
		evolution = "22",
		bst = "269",
		movelvls = { { 7, 13, 19, 25, 31, 37, 37 }, { 7, 13, 19, 25, 31, 37, 37 } },
		weight = "3.7"
	},
	{
		name = "Masquerain",
		type = { PokemonTypes.BUG, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "414",
		movelvls = { { 7, 13, 19, 26, 33, 40, 47, 53 }, { 7, 13, 19, 26, 33, 40, 47, 53 } },
		weight = "7.9"
	},
	{
		name = "Wailmer",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "40",
		bst = "400",
		movelvls = { { 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 }, { 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 } },
		weight = "286.6"
	},
	{
		name = "Wailord", -- STONKS
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 }, { 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 } },
		weight = "877.4"
	},
	{
		name = "Skitty",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.MOON,
		bst = "260",
		movelvls = { { 7, 13, 15, 19, 25, 27, 31, 37, 39 }, { 7, 13, 15, 19, 25, 27, 31, 37, 39 } },
		weight = "24.3"
	},
	{
		name = "Delcatty",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "380",
		movelvls = { {}, {} },
		weight = "71.9"
	},
	{
		name = "Kecleon", -- KEKLEO-N
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "440",
		movelvls = { { 7, 12, 17, 24, 31, 40, 49 }, { 7, 12, 17, 24, 31, 40, 49 } },
		weight = "48.5"
	},
	{
		name = "Baltoy",
		type = { PokemonTypes.GROUND, PokemonTypes.PSYCHIC },
		evolution = "36",
		bst = "300",
		movelvls = { { 7, 11, 15, 19, 25, 31, 37, 45 }, { 7, 11, 15, 19, 25, 31, 37, 45 } },
		weight = "47.4"
	},
	{
		name = "Claydol",
		type = { PokemonTypes.GROUND, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "500",
		movelvls = { { 7, 11, 15, 19, 25, 31, 36, 42, 55 }, { 7, 11, 15, 19, 25, 31, 36, 42, 55 } },
		weight = "238.1"
	},
	{
		name = "Nosepass",
		type = { PokemonTypes.ROCK, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "375",
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43, 46 }, { 7, 13, 16, 22, 28, 31, 37, 43, 46 } },
		weight = "213.8"
	},
	{
		name = "Torkoal",
		type = { PokemonTypes.FIRE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "470",
		movelvls = { { 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 }, { 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 } },
		weight = "177.2"
	},
	{
		name = "Sableye",
		type = { PokemonTypes.DARK, PokemonTypes.GHOST },
		evolution = EvolutionTypes.NONE,
		bst = "380",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = "24.3"
	},
	{
		name = "Barboach",
		type = { PokemonTypes.WATER, PokemonTypes.GROUND },
		evolution = "30",
		bst = "288",
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 }, { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 } },
		weight = "4.2"
	},
	{
		name = "Whiscash",
		type = { PokemonTypes.WATER, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "468",
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 }, { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 } },
		weight = "52.0"
	},
	{
		name = "Luvdisc",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "330",
		movelvls = { { 12, 16, 24, 28, 36, 40, 48 }, { 12, 16, 24, 28, 36, 40, 48 } },
		weight = "19.2"
	},
	{
		name = "Corphish",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "308",
		movelvls = { { 7, 10, 13, 20, 23, 26, 32, 35, 38, 44 }, { 7, 10, 13, 19, 22, 25, 31, 34, 37, 43, 46 } },
		weight = "25.4"
	},
	{
		name = "Crawdaunt", -- FRAUD
		type = { PokemonTypes.WATER, PokemonTypes.DARK },
		evolution = EvolutionTypes.NONE,
		bst = "468",
		movelvls = { { 7, 10, 13, 20, 23, 26, 34, 39, 44, 52 }, { 7, 10, 13, 19, 22, 25, 33, 38, 43, 51, 56 } },
		weight = "72.3"
	},
	{
		name = "Feebas",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "35", -- Level 35 replaces beauty condition
		bst = "200",
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = "16.3"
	},
	{
		name = "Milotic", -- THICC
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "540",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = "357.1"
	},
	{
		name = "Carvanha",
		type = { PokemonTypes.WATER, PokemonTypes.DARK },
		evolution = "30",
		bst = "305",
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43 }, { 7, 13, 16, 22, 28, 31, 37, 43 } },
		weight = "45.9"
	},
	{
		name = "Sharpedo",
		type = { PokemonTypes.WATER, PokemonTypes.DARK },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 }, { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 } },
		weight = "195.8"
	},
	{
		name = "Trapinch",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = "35",
		bst = "290",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = "33.1"
	},
	{
		name = "Vibrava",
		type = { PokemonTypes.GROUND, PokemonTypes.DRAGON },
		evolution = "45",
		bst = "340",
		movelvls = { { 9, 17, 25, 33, 35, 41, 49, 57 }, { 9, 17, 25, 33, 35, 41, 49, 57 } },
		weight = "33.7"
	},
	{
		name = "Flygon",
		type = { PokemonTypes.GROUND, PokemonTypes.DRAGON },
		evolution = EvolutionTypes.NONE,
		bst = "520",
		movelvls = { { 9, 17, 25, 33, 35, 41, 53, 65 }, { 9, 17, 25, 33, 35, 41, 53, 65 } },
		weight = "180.8"
	},
	{
		name = "Makuhita",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = "24",
		bst = "237",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 }, { 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 } },
		weight = "190.5"
	},
	{
		name = "Hariyama",
		type = { PokemonTypes.FIGHTING, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "474",
		movelvls = { { 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 }, { 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 } },
		weight = "559.5"
	},
	{
		name = "Electrike",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = "26",
		bst = "295",
		movelvls = { { 9, 12, 17, 20, 25, 28, 33, 36, 41 }, { 9, 12, 17, 20, 25, 28, 33, 36, 41 } },
		weight = "33.5"
	},
	{
		name = "Manectric",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "475",
		movelvls = { { 9, 12, 17, 20, 25, 31, 39, 45, 53 }, { 9, 12, 17, 20, 25, 31, 39, 45, 53 } },
		weight = "88.6"
	},
	{
		name = "Numel",
		type = { PokemonTypes.FIRE, PokemonTypes.GROUND },
		evolution = "33",
		bst = "305",
		movelvls = { { 11, 19, 25, 29, 31, 35, 41, 49 }, { 11, 19, 25, 29, 31, 35, 41, 49 } },
		weight = "52.9"
	},
	{
		name = "Camerupt",
		type = { PokemonTypes.FIRE, PokemonTypes.GROUND },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 11, 19, 25, 29, 31, 33, 37, 45, 55 }, { 11, 19, 25, 29, 31, 33, 37, 45, 55 } },
		weight = "485.0"
	},
	{
		name = "Spheal",
		type = { PokemonTypes.ICE, PokemonTypes.WATER },
		evolution = "32",
		bst = "290",
		movelvls = { { 7, 13, 19, 25, 31, 37, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 37, 43, 49 } },
		weight = "87.1"
	},
	{
		name = "Sealeo",
		type = { PokemonTypes.ICE, PokemonTypes.WATER },
		evolution = "44",
		bst = "410",
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 47, 55 }, { 7, 13, 19, 25, 31, 39, 39, 47, 55 } },
		weight = "193.1"
	},
	{
		name = "Walrein",
		type = { PokemonTypes.ICE, PokemonTypes.WATER },
		evolution = EvolutionTypes.NONE,
		bst = "530",
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 50, 61 }, { 7, 13, 19, 25, 31, 39, 39, 50, 61 } },
		weight = "332.0"
	},
	{
		name = "Cacnea",
		type = { PokemonTypes.GRASS, PokemonTypes.EMPTY },
		evolution = "32",
		bst = "335",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 } },
		weight = "113.1"
	},
	{
		name = "Cacturne",
		type = { PokemonTypes.GRASS, PokemonTypes.DARK },
		evolution = EvolutionTypes.NONE,
		bst = "475",
		movelvls = { { 9, 13, 17, 21, 25, 29, 35, 41, 47, 53 }, { 9, 13, 17, 21, 25, 29, 35, 41, 47, 53, 59 } },
		weight = "170.6"
	},
	{
		name = "Snorunt",
		type = { PokemonTypes.ICE, PokemonTypes.EMPTY },
		evolution = "42",
		bst = "300",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = "37.0"
	},
	{
		name = "Glalie",
		type = { PokemonTypes.ICE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 }, { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 } },
		weight = "565.5"
	},
	{
		name = "Lunatone",
		type = { PokemonTypes.ROCK, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "440",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "370.4"
	},
	{
		name = "Solrock",
		type = { PokemonTypes.ROCK, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "440",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "339.5"
	},
	{
		name = "Azurill",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.FRIEND,
		bst = "190",
		movelvls = { { 6, 10, 15, 21 }, { 6, 10, 15, 21 } },
		weight = "4.4"
	},
	{
		name = "Spoink",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "32",
		bst = "330",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 } },
		weight = "67.5"
	},
	{
		name = "Grumpig",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "470",
		movelvls = { { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 }, { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 } },
		weight = "157.6"
	},
	{
		name = "Plusle",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = "9.3"
	},
	{
		name = "Minun",
		type = { PokemonTypes.ELECTRIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "405",
		movelvls = { { 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = "9.3"
	},
	{
		name = "Mawile",
		type = { PokemonTypes.STEEL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "380",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 } },
		weight = "25.4"
	},
	{
		name = "Meditite",
		type = { PokemonTypes.FIGHTING, PokemonTypes.PSYCHIC },
		evolution = "37",
		bst = "280",
		movelvls = { { 9, 12, 18, 22, 28, 32, 38, 42, 48 }, { 9, 12, 17, 20, 25, 28, 33, 36, 41, 44 } },
		weight = "24.7"
	},
	{
		name = "Medicham",
		type = { PokemonTypes.FIGHTING, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "410",
		movelvls = { { 9, 12, 18, 22, 28, 32, 40, 46, 54 }, { 9, 12, 17, 20, 25, 28, 33, 36, 47, 56 } },
		weight = "69.4"
	},
	{
		name = "Swablu",
		type = { PokemonTypes.NORMAL, PokemonTypes.FLYING },
		evolution = "35",
		bst = "310",
		movelvls = { { 8, 11, 18, 21, 28, 31, 38, 41, 48 }, { 8, 11, 18, 21, 28, 31, 38, 41, 48 } },
		weight = "2.6"
	},
	{
		name = "Altaria",
		type = { PokemonTypes.DRAGON, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "490",
		movelvls = { { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 }, { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 } },
		weight = "45.4"
	},
	{
		name = "Wynaut",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "15",
		bst = "260",
		movelvls = { { 15, 15, 15, 15 }, { 15, 15, 15, 15 } },
		weight = "30.9"
	},
	{
		name = "Duskull",
		type = { PokemonTypes.GHOST, PokemonTypes.EMPTY },
		evolution = "37",
		bst = "295",
		movelvls = { { 12, 16, 23, 27, 34, 38, 45, 49 }, { 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = "33.1"
	},
	{
		name = "Dusclops",
		type = { PokemonTypes.GHOST, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 12, 16, 23, 27, 34, 37, 41, 51, 58 }, { 12, 16, 23, 27, 34, 37, 41, 51, 58 } },
		weight = "67.5"
	},
	{
		name = "Roselia",
		type = { PokemonTypes.GRASS, PokemonTypes.POISON },
		evolution = EvolutionTypes.NONE,
		bst = "400",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 }, { 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 } },
		weight = "4.4"
	},
	{
		name = "Slakoth",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "18",
		bst = "280",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = "52.9"
	},
	{
		name = "Vigoroth",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "36",
		bst = "440",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = "102.5"
	},
	{
		name = "Slaking",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "670",
		movelvls = { { 7, 13, 19, 25, 31, 36, 37, 43 }, { 7, 13, 19, 25, 31, 36, 37, 43 } },
		weight = "287.7"
	},
	{
		name = "Gulpin",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = "26",
		bst = "302",
		movelvls = { { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 }, { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 } },
		weight = "22.7"
	},
	{
		name = "Swalot",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "467",
		movelvls = { { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 }, { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 } },
		weight = "176.4"
	},
	{
		name = "Tropius",
		type = { PokemonTypes.GRASS, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "460",
		movelvls = { { 7, 11, 17, 21, 27, 31, 37, 41, 47 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = "220.5"
	},
	{
		name = "Whismur",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "20",
		bst = "240",
		movelvls = { { 11, 15, 21, 25, 31, 35, 41, 41, 45 }, { 11, 15, 21, 25, 31, 35, 41, 41, 45 } },
		weight = "35.9"
	},
	{
		name = "Loudred",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = "40",
		bst = "360",
		movelvls = { { 11, 15, 23, 29, 37, 43, 51, 51, 57 }, { 11, 15, 23, 29, 37, 43, 51, 51, 57 } },
		weight = "89.3"
	},
	{
		name = "Exploud",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "480",
		movelvls = { { 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 }, { 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 } },
		weight = "185.2"
	},
	{
		name = "Clamperl",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = "30/WTR", -- Level 30 and stone replace trade evolution
		bst = "345",
		movelvls = { {}, {} },
		weight = "115.7"
	},
	{
		name = "Huntail",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "485",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "59.5"
	},
	{
		name = "Gorebyss",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "485",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = "49.8"
	},
	{
		name = "Absol",
		type = { PokemonTypes.DARK, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "465",
		movelvls = { { 9, 13, 17, 21, 26, 31, 36, 41, 46 }, { 9, 13, 17, 21, 26, 31, 36, 41, 46 } },
		weight = "103.6"
	},
	{
		name = "Shuppet",
		type = { PokemonTypes.GHOST, PokemonTypes.EMPTY },
		evolution = "37",
		bst = "295",
		movelvls = { { 8, 13, 20, 25, 32, 37, 44, 49, 56 }, { 8, 13, 20, 25, 32, 37, 44, 49, 56 } },
		weight = "5.1"
	},
	{
		name = "Banette",
		type = { PokemonTypes.GHOST, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "455",
		movelvls = { { 8, 13, 20, 25, 32, 39, 48, 55, 64 }, { 8, 13, 20, 25, 32, 39, 48, 55, 64 } },
		weight = "27.6"
	},
	{
		name = "Seviper",
		type = { PokemonTypes.POISON, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "458",
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = "115.7"
	},
	{
		name = "Zangoose",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "458",
		movelvls = { { 7, 10, 13, 19, 25, 31, 37, 46, 55 }, { 7, 10, 13, 19, 25, 31, 37, 46, 55 } },
		weight = "88.8"
	},
	{
		name = "Relicanth",
		type = { PokemonTypes.WATER, PokemonTypes.ROCK },
		evolution = EvolutionTypes.NONE,
		bst = "485",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = "51.6"
	},
	{
		name = "Aron",
		type = { PokemonTypes.STEEL, PokemonTypes.ROCK },
		evolution = "32",
		bst = "330",
		movelvls = { { 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 }, { 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 } },
		weight = "132.3"
	},
	{
		name = "Lairon",
		type = { PokemonTypes.STEEL, PokemonTypes.ROCK },
		evolution = "42",
		bst = "430",
		movelvls = { { 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 }, { 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 } },
		weight = "246.6"
	},
	{
		name = "Aggron",
		type = { PokemonTypes.STEEL, PokemonTypes.ROCK },
		evolution = EvolutionTypes.NONE,
		bst = "530",
		movelvls = { { 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 }, { 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 } },
		weight = "793.7"
	},
	{
		name = "Castform",
		type = { PokemonTypes.NORMAL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "420",
		movelvls = { { 10, 10, 10, 20, 20, 20, 30 }, { 10, 10, 10, 20, 20, 20, 30 } },
		weight = "1.8"
	},
	{
		name = "Volbeat",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "400",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37 }, { 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = "39.0"
	},
	{
		name = "Illumise",
		type = { PokemonTypes.BUG, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "400",
		movelvls = { { 9, 13, 17, 21, 25, 29, 33, 37 }, { 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = "39.0"
	},
	{
		name = "Lileep",
		type = { PokemonTypes.ROCK, PokemonTypes.GRASS },
		evolution = "40",
		bst = "355",
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 50, 50 }, { 8, 15, 22, 29, 36, 43, 50, 50, 50 } },
		weight = "52.5"
	},
	{
		name = "Cradily",
		type = { PokemonTypes.ROCK, PokemonTypes.GRASS },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 8, 15, 22, 29, 36, 48, 60, 60, 60 }, { 8, 15, 22, 29, 36, 48, 60, 60, 60 } },
		weight = "133.2"
	},
	{
		name = "Anorith",
		type = { PokemonTypes.ROCK, PokemonTypes.BUG },
		evolution = "40",
		bst = "355",
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = "27.6"
	},
	{
		name = "Armaldo",
		type = { PokemonTypes.ROCK, PokemonTypes.BUG },
		evolution = EvolutionTypes.NONE,
		bst = "495",
		movelvls = { { 7, 13, 19, 25, 31, 37, 46, 55, 64 }, { 7, 13, 19, 25, 31, 37, 46, 55, 64 } },
		weight = "150.4"
	},
	{
		name = "Ralts",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "20",
		bst = "198",
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = "14.6"
	},
	{
		name = "Kirlia",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "278",
		movelvls = { { 6, 11, 16, 21, 26, 33, 40, 47, 54 }, { 6, 11, 16, 21, 26, 33, 40, 47, 54 } },
		weight = "44.5"
	},
	{
		name = "Gardevoir",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "518",
		movelvls = { { 6, 11, 16, 21, 26, 33, 42, 51, 60 }, { 6, 11, 16, 21, 26, 33, 42, 51, 60 } },
		weight = "106.7"
	},
	{
		name = "Bagon",
		type = { PokemonTypes.DRAGON, PokemonTypes.EMPTY },
		evolution = "30",
		bst = "300",
		movelvls = { { 9, 17, 21, 25, 33, 37, 41, 49, 53 }, { 9, 17, 21, 25, 33, 37, 41, 49, 53 } },
		weight = "92.8"
	},
	{
		name = "Shelgon",
		type = { PokemonTypes.DRAGON, PokemonTypes.EMPTY },
		evolution = "50",
		bst = "420",
		movelvls = { { 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 }, { 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 } },
		weight = "243.6"
	},
	{
		name = "Salamence",
		type = { PokemonTypes.DRAGON, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 }, { 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 } },
		weight = "226.2"
	},
	{
		name = "Beldum",
		type = { PokemonTypes.STEEL, PokemonTypes.PSYCHIC },
		evolution = "20",
		bst = "300",
		movelvls = { {}, {} },
		weight = "209.9"
	},
	{
		name = "Metang",
		type = { PokemonTypes.STEEL, PokemonTypes.PSYCHIC },
		evolution = "45",
		bst = "420",
		movelvls = { { 20, 20, 26, 32, 38, 44, 50, 56, 62 }, { 20, 20, 26, 32, 38, 44, 50, 56, 62 } },
		weight = "446.4"
	},
	{
		name = "Metagross",
		type = { PokemonTypes.STEEL, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 20, 20, 26, 32, 38, 44, 55, 66, 77 }, { 20, 20, 26, 32, 38, 44, 55, 66, 77 } },
		weight = "1212.5"
	},
	{
		name = "Regirock",
		type = { PokemonTypes.ROCK, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = "507.1"
	},
	{
		name = "Regice",
		type = { PokemonTypes.ICE, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = "385.8"
	},
	{
		name = "Registeel",
		type = { PokemonTypes.STEEL, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "580",
		movelvls = { { 9, 17, 25, 33, 41, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 41, 49, 57, 65 } },
		weight = "451.9"
	},
	{
		name = "Kyogre",
		type = { PokemonTypes.WATER, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "670",
		movelvls = { { 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = "776.0"
	},
	{
		name = "Groudon",
		type = { PokemonTypes.GROUND, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "670",
		movelvls = { { 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = "2094.4"
	},
	{
		name = "Rayquaza",
		type = { PokemonTypes.DRAGON, PokemonTypes.FLYING },
		evolution = EvolutionTypes.NONE,
		bst = "680",
		movelvls = { { 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = "455.2"
	},
	{
		name = "Latias",
		type = { PokemonTypes.DRAGON, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = "88.2"
	},
	{
		name = "Latios",
		type = { PokemonTypes.DRAGON, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = "132.3"
	},
	{
		name = "Jirachi",
		type = { PokemonTypes.STEEL, PokemonTypes.PSYCHIC },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = "2.4"
	},
	{
		name = "Deoxys",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "600",
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = "134.0"
	},
	{
		name = "Chimecho",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "425",
		movelvls = { { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 }, { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 } },
		weight = "2.2"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	},
	{
		name = "Unown",
		type = { PokemonTypes.PSYCHIC, PokemonTypes.EMPTY },
		evolution = EvolutionTypes.NONE,
		bst = "336",
		movelvls = { {}, {} },
		weight = "11.0"
	}
}

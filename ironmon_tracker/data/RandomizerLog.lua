-- A collection of tools for viewing a Randomized Pokémon game log
RandomizerLog = {}

RandomizerLog.Sections = {
	Evolutions = {
		Head = "--Randomized Evolutions--",
		Regex = "/(.*) -> (.*)/",
		-- BULBASAUR	-> ARIADOS
	},
	BaseStatsItems = {
		Head = "--Pokemon Base Stats & Types--",
		Regex = "|",
		-- 	NUM	|Name		|TYPE			| HP|ATK|DEF|SATK|SDEF| SPD|ABILITY1	|ABILITY2	|ITEM
		--    1	|BULBASAUR	|GRASS/POISON	| 59| 55| 49|  45|  50|  60|FLAME BODY	|-------	|TM45 (common), TM10 (rare)
	},
	MoveSets = {
		Head = "--Pokemon Movesets--",
		Regex = "/Level (%d{1,3}) ? ?: (.*)/",
		-- 001 BULBASAUR -> ARIADOS
		-- Level 13: DRAGON CLAW
	},
	TMCompatibility = {
		Head = "--TM Compatibility--",
		Regex = "/(T|H)M ?(%d+)(.*)/",
		--   1 BULBASAUR     |TM01 MEDITATE |             - |TM03 DYNAMICPUNCH
	},
	Trainers = {
		Head = "--Trainers Pokemon--",
		Regex = "",
		-- #411 (ELITE FOUR BRUNO => Fisher Stacey)@242B70 - ARTICUNO Lv77, STANTLER Lv80, ARBOK Lv80, ABSOL Lv81, SABLEYE Lv77, REGIROCK@SITRUS BERRY Lv84
	},
	PickupItems = {
		Head = "--Pickup Items--",
		Regex = "",
		-- Level 1-10
		-- 10%: REPEL, TM21, RARE CANDY, TM20, MOOMOO MILK, HP UP
	},
}

RandomizerLog.GymTMs = {
	FRLG = {
		{ leader = "Brock", number = 39, },
		{ leader = "Misty", number = 3, },
		{ leader = "Lt. Surge", number = 34, },
		{ leader = "Erika", number = 19, },
		{ leader = "Koga", number = 6, },
		{ leader = "Sabrina", number = 4, },
		{ leader = "Blaine", number = 38, },
		{ leader = "Giovanni", number = 26, },
	},
	RS = {
		{ leader = "Roxanne", number = 39, },
		{ leader = "Brawly", number = 8, },
		{ leader = "Wattson", number = 34, },
		{ leader = "Flannery", number = 50, },
		{ leader = "Norman", number = 42, },
		{ leader = "Winona", number = 40, },
		{ leader = "Take & Liza", number = 4, },
		{ leader = "Juan", number = 3, },
	},
	E = {
		{ leader = "Roxanne", number = 39, },
		{ leader = "Brawly", number = 8, },
		{ leader = "Wattson", number = 34, },
		{ leader = "Flannery", number = 50, },
		{ leader = "Norman", number = 42, },
		{ leader = "Winona", number = 40, },
		{ leader = "Take & Liza", number = 4, },
		{ leader = "Wallace", number = 3, },
	},
}

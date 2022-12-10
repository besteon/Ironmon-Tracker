Constants = {}

Constants.BLANKLINE = "---"
Constants.HIDDEN_INFO = "?"

Constants.SCREEN = {
	HEIGHT = 160,
	WIDTH = 240,
	UP_GAP = 0,
	DOWN_GAP = 0,
	RIGHT_GAP = 150,
	MARGIN = 5,
	LINESPACING = 11,
}

Constants.Font = {
	SIZE = 9,
	FAMILY = "Franklin Gothic Medium",
	STYLE = "regular", -- Style options are: regular, bold, italic, strikethrough, underline
}

Constants.ButtonTypes = {
	FULL_BORDER = 1,
	NO_BORDER = 2,
	CHECKBOX = 3,
	COLORPICKER = 4,
	IMAGE = 5,
	PIXELIMAGE = 6,
	POKEMON_ICON = 7,
	STAT_STAGE = 8,
}

Constants.STAT_STATES = {
	[0] = { text = " ", textColor = "Default text" },
	[1] = { text = "+", textColor = "Positive text" },
	[2] = { text = "--", textColor = "Negative text" },
}

Constants.MoveTypeColors = {
	normal = 0xFFA8A878,
	fighting = 0xFFC03028,
	flying = 0xFFA890F0,
	poison = 0xFFA040A0,
	ground = 0xFFE0C068,
	rock = 0xFFB8A038,
	bug = 0xFFA8B820,
	ghost = 0xFF705898,
	steel = 0xFFB8B8D0,
	fire = 0xFFF08030,
	water = 0xFF6890F0,
	grass = 0xFF78C850,
	electric = 0xFFF8D030,
	psychic = 0xFFF85888,
	ice = 0xFF98D8D8,
	dragon = 0xFF7038F8,
	dark = 0xFF705848,
	fairy = 0xFFEE99AC,
	unknown = 0xFF68A090, -- For the "Curse" move in Gen 2 - 4
}

Constants.GAME_STATS = { -- Enums for in-game stats
	-- https://github.com/pret/pokefirered/blob/master/include/constants/game_stat.h
	SAVED_GAME = 0, -- Number of times the player saved the game
	STEPS = 5, -- Total number of steps the player has taken
	TOTAL_BATTLES = 7, -- Total battles (trainer + wild), also useful for checking when Battle.inBattle should be true
	WILD_BATTLES = 8, -- Total number of wild encounters
	TRAINER_BATTLES = 9, -- Total number of unique trainer battles
	POKEMON_CAPTURES = 11, -- Total number of Pokemon caught
	FISHING_CAPTURES = 12, -- Deceptive name, gets incremented when fishing encounter happens
	USED_POKECENTER = 15,
	RESTED_AT_HOME = 16,
	USED_ROCK_SMASH = 19,
	USED_STRUGGLE = 27, -- Total number of times the player has had to use Struggle
	SHOPPED = 38, -- Total number of items purchased from a shop
}

Constants.PreloadedThemes = {
	["Fire Red"] = "FFFFFF FFFFFF 55CB6B 62C7FE FEFA69 FEFA69 FF1920 81000E FF1920 81000E 58050D 0 1",
	["Leaf Green"] = "FFFFFF FFFFFF 62C7FE FE7573 FEFA69 FEFA69 55CB6B 006200 55CB6B 006200 053A04 0 1",
	["Beach Getaway"] = "222222 222222 5463FF E78EA9 A581E6 444444 E78EA9 B9F8D3 E78EA9 FFFBE7 40DFEF 0 0",
	["Blue Da Ba Dee"] = "FFFFFF FFFFFF 2EB5FF E04DBA FEFA69 55CB6B 198BFF 004881 198BFF 004881 072557 1 1",
	["Calico Cat"] = "4A3432 4A3432 E07E3D 8A9298 E07E3D FCFCF0 8A9298 FCFCF0 E07E3D FBCA8C 0F0601 0 0",
	["Calico Cat v2"] = "4A3432 4A3432 E07E3D 8A9298 E07E3D FCFCF0 FCFCF0 FCFCF0 FBCA8C FBCA8C E07E3D 0 0",
	["Cotton Candy"] = "000000 000000 1A85FF D41159 9155D9 EEEEEE D35FB7 FFCBF3 1A85FF A0D3FF 5D3A9B 0 0",
	["GameCube"] = "C8C8C8 C8C8C8 2ACA38 FE4A4A EBE31A CBCCC4 000000 342A54 000000 342A54 000000 1 1",
	["Item Bag"] = "636363 636363 017BC4 DF2800 DE8C4A 636363 D7B452 FEFFCF D7B452 FEFFCF F6CF73 0 0",
	["Neon Lights"] = "FFFFFF FFFFFF 38FF12 FF00E3 FFF100 FFFFFF 00F5FB 000000 001EFF 000000 000000 1 1",
	["Simple Monotone"] = "222222 222222 01B910 FE5958 555555 FFFFFF 000000 FFFFFF 000000 FFFFFF 555555 0 0",
	["Team Rocket"] = "EEF5FE EEF5FE 8F7DEB D6335E F4E7BA F4E7BA 8F7DEB 333333 D6335E 333333 333333 1 1",
	["USS Galactic"] = "EEEEEE EEEEEE 00ADB5 DFBB9D B6C8EF 00ADB5 222831 393E46 222831 393E46 000000 1 1",
	["Cozy Fall Leaves"] = "2C432C 2C432C FA8223 9C7456 307940 307940 7D5D1E 9ED4B0 7D5D1E 9ED4B0 9ED4B0 0 0",
}

Constants.OrderedLists = {
	STATSTAGES = {
		"hp",
		"atk",
		"def",
		"spa",
		"spd",
		"spe",
	},
	OPTIONS = {
		"Disable mainscreen carousel",
		"Auto swap to enemy",
		"Show random ball picker",
		"Hide stats until summary shown",
		"Right justified numbers",
		"Show physical special icons",
		"Show move effectiveness",
		"Calculate variable damage",
		"Count enemy PP usage",
		"Track PC Heals",
		"PC heals count downward",
		"Auto save tracked game data",
		"Pokemon icon set",
		"Show last damage calcs",
		"Reveal info if randomized",
		"Animated Pokemon popout",
		"Use premade ROMs",
		"Generate ROM each time",
		"Display repel usage",
		"Startup Pokemon displayed",
		"Display pedometer",
	},
	CONTROLS = {
		"Load next seed",
		"Toggle view",
		"Cycle through stats",
		"Mark stat",
	},
	THEMECOLORS = {
		"Default text",
		"Lower box text",
		"Positive text",
		"Negative text",
		"Intermediate text",
		"Header text",
		"Upper box border",
		"Upper box background",
		"Lower box border",
		"Lower box background",
		"Main background",
	},
	PRELOADED_THEMES = {
		"Fire Red",
		"Leaf Green",
		"Beach Getaway",
		"Blue Da Ba Dee",
		"Calico Cat",
		"Calico Cat v2",
		"Cotton Candy",
		"GameCube",
		"Item Bag",
		"Neon Lights",
		"Simple Monotone",
		"Team Rocket",
		"USS Galactic",
		"Cozy Fall Leaves",
	},
}

Constants.PixelImages = {
	BLANK = { { 0 } }, -- Helpful for padding out certain buttons
	GEAR = {
		{0,0,0,1,1,0,0,0},
		{0,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,0},
		{1,1,1,0,0,1,1,1},
		{1,1,1,0,0,1,1,1},
		{0,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,0},
		{0,0,0,1,1,0,0,0},
	},
	PHYSICAL = {
		{1,0,0,1,0,0,1},
		{0,1,0,1,0,1,0},
		{0,0,1,1,1,0,0},
		{1,1,1,1,1,1,1},
		{0,0,1,1,1,0,0},
		{0,1,0,1,0,1,0},
		{1,0,0,1,0,0,1},
	},
	SPECIAL = {
		{0,0,1,1,1,0,0},
		{0,1,0,0,0,1,0},
		{1,0,0,1,0,0,1},
		{1,0,1,0,1,0,1},
		{1,0,0,1,0,0,1},
		{0,1,0,0,0,1,0},
		{0,0,1,1,1,0,0},
	},
	NOTEPAD = {
		{0,0,0,0,0,0,0,0,0,1,1},
		{0,0,0,0,0,0,0,0,1,0,1},
		{1,1,1,1,1,1,1,1,1,1,0},
		{1,0,0,0,0,0,0,1,1,0,0},
		{1,0,1,1,1,0,1,0,1,0,0},
		{1,0,0,0,0,0,0,0,1,0,0},
		{1,0,1,1,1,1,1,0,1,0,0},
		{1,0,0,0,0,0,0,0,1,0,0},
		{1,0,1,1,1,1,1,0,1,0,0},
		{1,0,0,0,0,0,0,0,1,0,0},
		{1,1,1,1,1,1,1,1,1,0,0},
	},
	MAGNIFYING_GLASS = {
		{0,0,1,1,1,0,0,0,0,0},
		{0,1,0,0,0,1,0,0,0,0},
		{1,0,0,0,0,0,1,0,0,0},
		{1,0,0,0,0,0,1,0,0,0},
		{1,0,0,0,0,0,1,0,0,0},
		{0,1,0,0,0,1,0,0,0,0},
		{0,0,1,1,1,0,1,0,0,0},
		{0,0,0,0,0,0,0,1,1,0},
		{0,0,0,0,0,0,0,1,1,1},
		{0,0,0,0,0,0,0,0,1,1},
	},
	CLOCK = {
		{0,0,1,1,1,1,1,1,0,0},
		{0,1,0,0,0,0,0,0,1,0},
		{1,0,0,0,1,0,0,0,0,1},
		{1,0,0,0,1,0,0,0,0,1},
		{1,0,0,0,1,0,0,0,0,1},
		{1,0,0,0,1,1,1,0,0,1},
		{1,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,1},
		{0,1,0,0,0,0,0,0,1,0},
		{0,0,1,1,1,1,1,1,0,0},
	},
	INSTALL_BOX = {
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,1,0,1,0,1,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{1,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1},
	},
	PREVIOUS_BUTTON = {
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,1,1,0,0,0,0,0},
		{0,0,1,1,0,0,0,0,0,0},
		{0,1,1,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,0},
		{1,1,1,1,1,1,1,1,1,0},
		{0,1,1,0,0,0,0,0,0,0},
		{0,0,1,1,0,0,0,0,0,0},
		{0,0,0,1,1,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0},
	},
	NEXT_BUTTON = {
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,1,1,0,0,0},
		{0,0,0,0,0,0,1,1,0,0},
		{0,0,0,0,0,0,0,1,1,0},
		{0,1,1,1,1,1,1,1,1,1},
		{0,1,1,1,1,1,1,1,1,1},
		{0,0,0,0,0,0,0,1,1,0},
		{0,0,0,0,0,0,1,1,0,0},
		{0,0,0,0,0,1,1,0,0,0},
		{0,0,0,0,0,0,0,0,0,0},
	},
	DOWN_ARROW = {
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,1,1,0,0,0,0},
		{0,0,0,0,1,1,0,0,0,0},
		{0,0,0,0,1,1,0,0,0,0},
		{0,0,0,0,1,1,0,0,0,0},
		{0,1,0,0,1,1,0,0,1,0},
		{0,1,1,0,1,1,0,1,1,0},
		{0,0,1,1,1,1,1,1,0,0},
		{0,0,0,1,1,1,1,0,0,0},
		{0,0,0,0,1,1,0,0,0,0},
	},
	MAP_PINDROP = {
		{0,0,1,1,1,1,0,0},
		{0,1,1,1,1,1,1,0},
		{1,1,1,0,0,1,1,1},
		{1,1,0,0,0,0,1,1},
		{1,1,0,0,0,0,1,1},
		{1,1,1,0,0,1,1,1},
		{0,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,0},
		{0,0,1,1,1,1,0,0},
		{0,0,1,1,1,1,0,0},
		{0,0,0,1,1,0,0,0},
		{0,0,0,1,1,0,0,0},
	},
	SWORD_ATTACK = {
		{0,0,0,0,0,0,0,0,0,0,0,1,1,0},
		{0,0,0,0,0,0,0,0,0,0,1,0,1,0},
		{0,0,0,0,0,0,0,0,0,1,0,1,1,0},
		{0,0,0,0,0,0,0,0,1,0,1,1,0,0},
		{0,0,0,0,0,0,0,1,0,1,1,0,0,0},
		{0,0,0,0,0,0,1,0,1,1,0,0,0,0},
		{1,0,0,0,0,1,0,1,1,0,0,0,0,0},
		{1,1,0,0,1,0,1,1,0,0,0,0,0,0},
		{0,1,1,1,0,1,1,0,0,0,0,0,0,0},
		{0,0,1,1,1,1,0,0,0,0,0,0,0,0},
		{0,1,0,1,1,0,0,0,0,0,0,0,0,0},
		{1,0,1,0,1,1,0,0,0,0,0,0,0,0},
		{1,1,0,0,0,1,1,0,0,0,0,0,0,0},
	},
	CHECKMARK = {
		{0,0,0,0,0,0,0,0,0,0,1,1},
		{0,0,0,0,0,0,0,0,0,1,1,1},
		{0,0,0,0,0,0,0,0,1,1,1,0},
		{0,0,0,0,0,0,0,0,1,1,0,0},
		{0,0,0,0,0,0,0,1,1,1,0,0},
		{0,0,0,0,0,0,1,1,1,0,0,0},
		{1,1,0,0,0,0,1,1,0,0,0,0},
		{1,1,1,0,0,1,1,1,0,0,0,0},
		{0,1,1,1,1,1,1,0,0,0,0,0},
		{0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,1,1,0,0,0,0,0,0,0},
	},
	CROSS = {
		{1,1,0,0,0,0,0,0,0,1,1},
		{1,1,1,0,0,0,0,0,1,1,1},
		{0,1,1,1,0,0,0,1,1,1,0},
		{0,0,1,1,1,0,1,1,1,0,0},
		{0,0,0,1,1,1,1,1,0,0,0},
		{0,0,0,0,1,1,1,0,0,0,0},
		{0,0,0,1,1,1,1,1,0,0,0},
		{0,0,1,1,1,0,1,1,1,0,0},
		{0,1,1,1,0,0,0,1,1,1,0},
		{1,1,1,0,0,0,0,0,1,1,1},
		{1,1,0,0,0,0,0,0,0,1,1},
	},
	POKEBALL = {
		{0,0,0,0,1,1,1,1,0,0,0,0},
		{0,0,1,1,2,2,2,2,1,1,0,0},
		{0,1,2,2,2,3,2,2,2,2,1,0},
		{0,1,2,2,3,2,2,2,2,2,1,0},
		{1,2,2,2,2,2,2,2,2,2,2,1},
		{1,2,2,2,2,1,1,2,2,2,2,1},
		{1,1,2,2,1,3,3,1,2,2,1,1},
		{1,3,1,1,1,3,3,1,1,1,3,1},
		{0,1,3,3,3,1,1,3,3,3,1,0},
		{0,1,3,3,3,3,3,3,3,3,1,0},
		{0,0,1,1,3,3,3,3,1,1,0,0},
		{0,0,0,0,1,1,1,1,0,0,0,0},
	},
	DICE = {
		{0,0,0,0,0,1,1,1,0,0,0,0,0},
		{0,0,0,1,1,0,0,0,1,1,0,0,0},
		{0,1,1,0,0,0,0,0,0,0,1,1,0},
		{1,0,0,0,0,0,1,0,0,0,0,0,1},
		{1,1,1,0,0,0,0,0,0,0,1,1,1},
		{1,0,0,1,1,0,0,0,1,1,0,0,1},
		{1,0,0,0,0,1,1,1,0,0,1,0,1},
		{1,0,1,0,0,0,1,0,0,0,0,0,1},
		{1,0,0,0,0,0,1,0,0,1,0,0,1},
		{1,0,0,0,0,0,1,0,0,0,0,0,1},
		{1,0,0,0,1,0,1,0,1,0,0,0,1},
		{0,1,1,0,0,0,1,0,0,0,1,1,0},
		{0,0,0,1,1,0,1,0,1,1,0,0,0},
		{0,0,0,0,0,1,1,1,0,0,0,0,0},
	},
	GBA = {
		{2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2},
		{2,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,2},
		{1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1},
		{1,1,1,1,1,1,1,2,1,2,1,2,1,2,1,2,1,1,1,1,1,1},
		{1,1,1,2,1,1,2,1,2,1,2,1,2,1,2,1,1,1,1,1,1,1},
		{1,1,2,2,2,1,1,2,1,2,1,2,1,2,1,2,1,1,1,2,2,1},
		{1,1,1,2,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2,1},
		{1,1,1,1,1,1,2,1,2,1,2,1,2,1,2,1,1,2,2,1,1,1},
		{1,1,1,1,2,1,2,2,2,2,2,2,2,2,2,2,1,2,2,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
		{2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2},
		{2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2},
	},
}

Constants.CharMap = {
	["À"] = {
		[Main.EMU.BIZHAWK] = "\192",
		[Main.EMU.MGBA] = "À",
	},
	["Á"] = {
		[Main.EMU.BIZHAWK] = "\193",
		[Main.EMU.MGBA] = "Á",
	},
	["Â"] = {
		[Main.EMU.BIZHAWK] = "\194",
		[Main.EMU.MGBA] = "Â",
	},
	["Ã"] = {
		[Main.EMU.BIZHAWK] = "\195",
		[Main.EMU.MGBA] = "Ã",
	},
	["Ä"] = {
		[Main.EMU.BIZHAWK] = "\196",
		[Main.EMU.MGBA] = "Ä",
	},
	["Å"] = {
		[Main.EMU.BIZHAWK] = "\197",
		[Main.EMU.MGBA] = "Å",
	},
	["Æ"] = {
		[Main.EMU.BIZHAWK] = "\198",
		[Main.EMU.MGBA] = "Æ",
	},
	["Ç"] = {
		[Main.EMU.BIZHAWK] = "\199",
		[Main.EMU.MGBA] = "Ç",
	},
	["È"] = {
		[Main.EMU.BIZHAWK] = "\200",
		[Main.EMU.MGBA] = "È",
	},
	["É"] = {
		[Main.EMU.BIZHAWK] = "\201",
		[Main.EMU.MGBA] = "É",
	},
	["Ê"] = {
		[Main.EMU.BIZHAWK] = "\202",
		[Main.EMU.MGBA] = "Ê",
	},
	["Ë"] = {
		[Main.EMU.BIZHAWK] = "\203",
		[Main.EMU.MGBA] = "Ë",
	},
	["Ì"] = {
		[Main.EMU.BIZHAWK] = "\204",
		[Main.EMU.MGBA] = "Ì",
	},
	["Í"] = {
		[Main.EMU.BIZHAWK] = "\205",
		[Main.EMU.MGBA] = "Í",
	},
	["Î"] = {
		[Main.EMU.BIZHAWK] = "\206",
		[Main.EMU.MGBA] = "Î",
	},
	["Ï"] = {
		[Main.EMU.BIZHAWK] = "\207",
		[Main.EMU.MGBA] = "Ï",
	},
	["Ð"] = {
		[Main.EMU.BIZHAWK] = "\208",
		[Main.EMU.MGBA] = "Ð",
	},
	["Ñ"] = {
		[Main.EMU.BIZHAWK] = "\209",
		[Main.EMU.MGBA] = "Ñ",
	},
	["Ò"] = {
		[Main.EMU.BIZHAWK] = "\210",
		[Main.EMU.MGBA] = "Ò",
	},
	["Ó"] = {
		[Main.EMU.BIZHAWK] = "\211",
		[Main.EMU.MGBA] = "Ó",
	},
	["Ô"] = {
		[Main.EMU.BIZHAWK] = "\212",
		[Main.EMU.MGBA] = "Ô",
	},
	["Õ"] = {
		[Main.EMU.BIZHAWK] = "\213",
		[Main.EMU.MGBA] = "Õ",
	},
	["Ö"] = {
		[Main.EMU.BIZHAWK] = "\214",
		[Main.EMU.MGBA] = "Ö",
	},
	["Ø"] = {
		[Main.EMU.BIZHAWK] = "\216",
		[Main.EMU.MGBA] = "Ø",
	},
	["Ù"] = {
		[Main.EMU.BIZHAWK] = "\217",
		[Main.EMU.MGBA] = "Ù",
	},
	["Ú"] = {
		[Main.EMU.BIZHAWK] = "\218",
		[Main.EMU.MGBA] = "Ú",
	},
	["Û"] = {
		[Main.EMU.BIZHAWK] = "\219",
		[Main.EMU.MGBA] = "Û",
	},
	["Ü"] = {
		[Main.EMU.BIZHAWK] = "\220",
		[Main.EMU.MGBA] = "Ü",
	},
	["Ý"] = {
		[Main.EMU.BIZHAWK] = "\221",
		[Main.EMU.MGBA] = "Ý",
	},
	["Þ"] = {
		[Main.EMU.BIZHAWK] = "\222",
		[Main.EMU.MGBA] = "Þ",
	},
	["ß"] = {
		[Main.EMU.BIZHAWK] = "\223",
		[Main.EMU.MGBA] = "ß",
	},
	["à"] = {
		[Main.EMU.BIZHAWK] = "\224",
		[Main.EMU.MGBA] = "à",
	},
	["á"] = {
		[Main.EMU.BIZHAWK] = "\225",
		[Main.EMU.MGBA] = "á",
	},
	["â"] = {
		[Main.EMU.BIZHAWK] = "\226",
		[Main.EMU.MGBA] = "â",
	},
	["ã"] = {
		[Main.EMU.BIZHAWK] = "\227",
		[Main.EMU.MGBA] = "ã",
	},
	["ä"] = {
		[Main.EMU.BIZHAWK] = "\228",
		[Main.EMU.MGBA] = "ä",
	},
	["å"] = {
		[Main.EMU.BIZHAWK] = "\229",
		[Main.EMU.MGBA] = "å",
	},
	["æ"] = {
		[Main.EMU.BIZHAWK] = "\230",
		[Main.EMU.MGBA] = "æ",
	},
	["ç"] = {
		[Main.EMU.BIZHAWK] = "\231",
		[Main.EMU.MGBA] = "ç",
	},
	["è"] = {
		[Main.EMU.BIZHAWK] = "\232",
		[Main.EMU.MGBA] = "è",
	},
	["é"] = {
		[Main.EMU.BIZHAWK] = "\233",
		[Main.EMU.MGBA] = "é",
	},
	["ê"] = {
		[Main.EMU.BIZHAWK] = "\234",
		[Main.EMU.MGBA] = "ê",
	},
	["ë"] = {
		[Main.EMU.BIZHAWK] = "\235",
		[Main.EMU.MGBA] = "ë",
	},
	["ì "] = {
		[Main.EMU.BIZHAWK] = "\236",
		[Main.EMU.MGBA] = "ì ",
	},
	["í"] = {
		[Main.EMU.BIZHAWK] = "\237",
		[Main.EMU.MGBA] = "í",
	},
	["î"] = {
		[Main.EMU.BIZHAWK] = "\238",
		[Main.EMU.MGBA] = "î",
	},
	["ï"] = {
		[Main.EMU.BIZHAWK] = "\239",
		[Main.EMU.MGBA] = "ï",
	},
	["ð"] = {
		[Main.EMU.BIZHAWK] = "\240",
		[Main.EMU.MGBA] = "ð",
	},
	["ñ"] = {
		[Main.EMU.BIZHAWK] = "\241",
		[Main.EMU.MGBA] = "ñ",
	},
	["ò"] = {
		[Main.EMU.BIZHAWK] = "\242",
		[Main.EMU.MGBA] = "ò",
	},
	["ó"] = {
		[Main.EMU.BIZHAWK] = "\243",
		[Main.EMU.MGBA] = "ó",
	},
	["ô"] = {
		[Main.EMU.BIZHAWK] = "\244",
		[Main.EMU.MGBA] = "ô",
	},
	["õ"] = {
		[Main.EMU.BIZHAWK] = "\245",
		[Main.EMU.MGBA] = "õ",
	},
	["ö"] = {
		[Main.EMU.BIZHAWK] = "\246",
		[Main.EMU.MGBA] = "ö",
	},
	["ø"] = {
		[Main.EMU.BIZHAWK] = "\248",
		[Main.EMU.MGBA] = "ø",
	},
	["ù"] = {
		[Main.EMU.BIZHAWK] = "\249",
		[Main.EMU.MGBA] = "ù",
	},
	["ú"] = {
		[Main.EMU.BIZHAWK] = "\250",
		[Main.EMU.MGBA] = "ú",
	},
	["û"] = {
		[Main.EMU.BIZHAWK] = "\251",
		[Main.EMU.MGBA] = "û",
	},
	["ü"] = {
		[Main.EMU.BIZHAWK] = "\252",
		[Main.EMU.MGBA] = "ü",
	},
	["ý"] = {
		[Main.EMU.BIZHAWK] = "\253",
		[Main.EMU.MGBA] = "ý",
	},
	["þ"] = {
		[Main.EMU.BIZHAWK] = "\254",
		[Main.EMU.MGBA] = "þ",
	},
	["ÿ"] = {
		[Main.EMU.BIZHAWK] = "\255",
		[Main.EMU.MGBA] = "ÿ",
	},
}

-- Returns a renderable character for the appropriate emulator
function Constants.getC(character)
	if Constants.CharMap[character] ~= nil and Constants.CharMap[character][Main.emulator] ~= nil then
		return Constants.CharMap[character][Main.emulator]
	end
	return Constants.HIDDEN_INFO
end

Constants.Words = {
	POKEMON = "Pok" .. Constants.getC("é") .. "mon",
	POKE = "Pok" .. Constants.getC("é"),
}
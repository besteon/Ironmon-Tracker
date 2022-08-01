Constants = {}

Constants.BLANKLINE = "---"
Constants.NO_POWER = Constants.BLANKLINE
Constants.NO_PP = ""

Constants.SCREEN = {
	HEIGHT = 160,
	WIDTH = 240,
	UP_GAP = 0,
	DOWN_GAP = 0,
	RIGHT_GAP = 150,
	MARGIN = 5,
}

Constants.Font = {
	SIZE = 9,
	FAMILY = "Franklin Gothic Medium",
	STYLE = "regular", -- Style options are: regular, bold, italic, strikethrough, underline
}

Constants.Extensions = {
	TRACKED_DATA = ".tdat",
	POKEMON_PIXELED = ".gif",
	POKEMON_STADIUM = ".png",
}

Constants.ButtonTypes = {
	FULL_BORDER = 1,
	NO_BORDER = 2,
	CHECKBOX = 3,
	COLORPICKER = 4,
	IMAGE = 5,
	PIXELIMAGE = 6,
	STAT_STAGE = 7,
}

Constants.STAT_STATES = {
	[0] = { text = "", textColor = "Default text" },
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
		"Auto swap to enemy",
		"Hide stats until summary shown",
		"Right justified numbers",
		"Show physical special icons",
		"Show move effectiveness",
		"Calculate variable damage",
		"Count enemy PP usage",
		"Track PC Heals",
		"PC heals count downward",
		"Pokemon Stadium portraits",
	},
	CONTROLS = {
		"Load next seed",
		"Toggle view",
		"Cycle through stats",
		"Mark stat",
	},
	THEMECOLORS = {
		"Default text",
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
	THEMEPRESETS = {
		"Default Theme",
		"Fire Red",
		"Leaf Green",
		"Beach Getaway",
		"Blue Da Ba Dee",
		"Calico Cat",
		"Cotton Candy",
		"USS Galactic",
		"Simple Monotone",
		"Neon Lights",
	},
}

Constants.PixelImages = {
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
}
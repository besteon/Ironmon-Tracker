MiscData = {}

MiscData.TableData = {
	growth = { 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4 },
	attack = { 2, 2, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3 },
	effort = { 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3, 1, 1, 1, 1, 1, 1, 4, 3, 4, 3, 2, 2 },
	misc   = { 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 1, 1, 1, 1, 1, 1 },
}

MiscData.BagPocket = {
	PC = 0,
	Items = 1,
	KeyItems = 2,
	Pokeballs = 3,
	TMHM = 4,
	Berries = 5,
}

MiscData.HealingType = {
	Constant = 0,
	Percentage = 1,
}

-- Currently unused data
MiscData.StatusType = {
	None = 0,
	Sleep = 1,
	Poison = 2,
	Burn = 3,
	Freeze = 4,
	Paralyze = 5,
	Toxic = 6,
	Faint = 50,
	All = 100,
}

MiscData.StatusCodeMap = {
	[MiscData.StatusType.None] = "",
	[MiscData.StatusType.Burn] = "BRN",
	[MiscData.StatusType.Freeze] = "FRZ",
	[MiscData.StatusType.Paralyze] = "PAR",
	[MiscData.StatusType.Poison] = "PSN",
	[MiscData.StatusType.Toxic] = "PSN",
	[MiscData.StatusType.Sleep] = "SLP",
	[MiscData.StatusType.Faint] = "FNT",
}

-- Currently unused data
MiscData.Natures = {
	"Hardy", "Lonely", "Brave", "Adamant", "Naughty",
	"Bold", "Docile", "Relaxed", "Impish", "Lax",
	"Timid", "Hasty", "Serious", "Jolly", "Naive",
	"Modest", "Mild", "Quiet", "Bashful", "Rash",
	"Calm", "Gentle", "Sassy", "Careful", "Quirky"
}

MiscData.Items = {
	"Master Ball", "Ultra Ball", "Great Ball", "Pok" .. Constants.getC("é") .. " Ball", "Safari Ball", "Net Ball", "Dive Ball", "Nest Ball",
	"Repeat Ball", "Timer Ball", "Luxury Ball", "Premier Ball", "Potion", "Antidote", "Burn Heal", "Ice Heal", "Awakening",
	"Parlyz Heal", "Full Restore", "Max Potion", "Hyper Potion", "Super Potion", "Full Heal", "Revive", "Max Revive", "Fresh Water",
	"Soda Pop", "Lemonade", "Moomoo Milk", "EnergyPowder", "Energy Root", "Heal Powder", "Revival Herb", "Ether", "Max Ether",
	"Elixir", "Max Elixir", "Lava Cookie", "Blue Flute", "Yellow Flute", "Red Flute", "Black Flute", "White Flute", "Berry Juice",
	"Sacred Ash", "Shoal Salt", "Shoal Shell", "Red Shard", "Blue Shard", "Yellow Shard", "Green Shard", "unknown", "unknown",
	"unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "HP Up", "Protein",
	"Iron", "Carbos", "Calcium", "Rare Candy", "PP Up", "Zinc", "PP Max", "unknown", "Guard Spec.", "Dire Hit", "X Attack",
	"X Defend", "X Speed", "X Accuracy", "X Special", "Pok" .. Constants.getC("é") .. " Doll", "Fluffy Tail", "unknown", "Super Repel", "Max Repel",
	"Escape Rope", "Repel", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "Sun Stone", "Moon Stone",
	"Fire Stone", "Thunder Stone", "Water Stone", "Leaf Stone", "unknown", "unknown", "unknown", "unknown", "TinyMushroom",
	"Big Mushroom", "unknown", "Pearl", "Big Pearl", "Stardust", "Star Piece", "Nugget", "Heart Scale", "unknown", "unknown",
	"unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "Orange Mail", "Harbor Mail", "Glitter Mail",
	"Mech Mail", "Wood Mail", "Wave Mail", "Bead Mail", "Shadow Mail", "Tropic Mail", "Dream Mail", "Fab Mail", "Retro Mail",
	"Cheri Berry", "Chesto Berry", "Pecha Berry", "Rawst Berry", "Aspear Berry", "Leppa Berry", "Oran Berry", "Persim Berry",
	"Lum Berry", "Sitrus Berry", "Figy Berry", "Wiki Berry", "Mago Berry", "Aguav Berry", "Iapapa Berry", "Razz Berry", "Bluk Berry",
	"Nanab Berry", "Wepear Berry", "Pinap Berry", "Pomeg Berry", "Kelpsy Berry", "Qualot Berry", "Hondew Berry", "Grepa Berry",
	"Tamato Berry", "Cornn Berry", "Magost Berry", "Rabuta Berry", "Nomel Berry", "Spelon Berry", "Pamtre Berry", "Watmel Berry",
	"Durin Berry", "Belue Berry", "Liechi Berry", "Ganlon Berry", "Salac Berry", "Petaya Berry", "Apicot Berry", "Lansat Berry",
	"Starf Berry", "Enigma Berry", "unknown", "unknown", "unknown", "BrightPowder", "White Herb", "Macho Brace", "Exp. Share",
	"Quick Claw", "Soothe Bell", "Mental Herb", "Choice Band", "King's Rock", "SilverPowder", "Amulet Coin", "Cleanse Tag", "Soul Dew",
	"DeepSeaTooth", "DeepSeaScale", "Smoke Ball", "Everstone", "Focus Band", "Lucky Egg", "Scope Lens", "Metal Coat", "Leftovers",
	"Dragon Scale", "Light Ball", "Soft Sand", "Hard Stone", "Miracle Seed", "BlackGlasses", "Black Belt", "Magnet", "Mystic Water",
	"Sharp Beak", "Poison Barb", "NeverMeltIce", "Spell Tag", "TwistedSpoon", "Charcoal", "Dragon Fang", "Silk Scarf", "Up-Grade",
	"Shell Bell", "Sea Incense", "Lax Incense", "Lucky Punch", "Metal Powder", "Thick Club", "Stick", "unknown", "unknown", "unknown",
	"unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown",
	"unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown", "unknown",
	"unknown", "unknown", "unknown", "Red Scarf", "Blue Scarf", "Pink Scarf", "Green Scarf", "Yellow Scarf", "Mach Bike", "Coin Case",
	"Itemfinder", "Old Rod", "Good Rod", "Super Rod", "S.S. Ticket", "Contest Pass", "unknown", "Wailmer Pail", "Devon Goods",
	"Soot Sack", "Basement Key", "Acro Bike", "Pok" .. Constants.getC("é") .. "block Case", "Letter", "Eon Ticket", "Red Orb", "Blue Orb", "Scanner", "Go-Goggles",
	"Meteorite", "Rm. 1 Key", "Rm. 2 Key", "Rm. 4 Key", "Rm. 6 Key", "Storage Key", "Root Fossil", "Claw Fossil", "Devon Scope",
	"TM01", "TM02", "TM03", "TM04", "TM05", "TM06", "TM07", "TM08", "TM09", "TM10", "TM11", "TM12", "TM13", "TM14", "TM15",
	"TM16", "TM17", "TM18", "TM19", "TM20", "TM21", "TM22", "TM23", "TM24", "TM25", "TM26", "TM27", "TM28", "TM29", "TM30",
	"TM31", "TM32", "TM33", "TM34", "TM35", "TM36", "TM37", "TM38", "TM39", "TM40", "TM41", "TM42", "TM43", "TM44", "TM45",
	"TM46", "TM47", "TM48", "TM49", "TM50", "HM01", "HM02", "HM03", "HM04", "HM05", "HM06", "HM07", "HM08", "unknown", "unknown",
	"Oak's Parcel","Pok" .. Constants.getC("é") .. " Flute", "Secret Key", "Bike Voucher", "Gold Teeth", "Old Amber", "Card Key", "Lift Key", "Helix Fossil", "Dome Fossil", "Silph Scope",
	"Bicycle", "Town Map", "Vs. Seeker", "Fame Checker", "TM Case", "Berry Pouch", "Teachy TV", "Tri-Pass", "Rainbow Pass", "Tea",
	"MysticTicket", "AuroraTicket", "Powder Jar", "Ruby", "Sapphire", "Magma Emblem", "Old Sea Map"
}

MiscData.HealingItems = {
	[13] = {
		id = 13,
		name = "Potion",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[19] = {
		id = 19,
		name = "Full Restore",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[20] = {
		id = 20,
		name = "Max Potion",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[21] = {
		id = 21,
		name = "Hyper Potion",
		amount = 200,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[22] = {
		id = 22,
		name = "Super Potion",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[26] = {
		id = 26,
		name = "Fresh Water",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[27] = {
		id = 27,
		name = "Soda Pop",
		amount = 60,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[28] = {
		id = 28,
		name = "Lemonade",
		amount = 80,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[29] = {
		id = 29,
		name = "Moomoo Milk",
		amount = 100,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[30] = {
		id = 30,
		name = "EnergyPowder",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[31] = {
		id = 31,
		name = "Energy Root",
		amount = 200,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[44] = {
		id = 44,
		name = "Berry Juice",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[139] = {
		id = 139,
		name = "Oran Berry",
		amount = 10,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Berries,
	},
	[142] = {
		id = 142,
		name = "Sitrus Berry",
		amount = 30,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Berries,
	},
	[143] = {
		id = 143,
		name = "Figy Berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[144] = {
		id = 144,
		name = "Wiki Berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[145] = {
		id = 145,
		name = "Mago Berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[146] = {
		id = 146,
		name = "Aguav Berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[147] = {
		id = 147,
		name = "Iapapa Berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[175] = {
		id = 175,
		name = "Enigma Berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
}

MiscData.StatusItems = {
	[14] = {
		id = 14,
		name = "Antidote",
		type = MiscData.StatusType.Poison,
		pocket = MiscData.BagPocket.Items,
	},
	[15] = {
		id = 15,
		name = "Burn Heal",
		type = MiscData.StatusType.Burn,
		pocket = MiscData.BagPocket.Items,
	},
	[16] = {
		id = 16,
		name = "Ice Heal",
		type = MiscData.StatusType.Freeze,
		pocket = MiscData.BagPocket.Items,
	},
	[17] = {
		id = 17,
		name = "Awakening",
		type = MiscData.StatusType.Sleep,
		pocket = MiscData.BagPocket.Items,
	},
	[18] = {
		id = 18,
		name = "Parlyz Heal",
		type = MiscData.StatusType.Paralyze,
		pocket = MiscData.BagPocket.Items,
	},
	[19] = {
		id = 19,
		name = "Full Restore",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[23] = {
		id = 23,
		name = "Full Heal",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[32] = {
		id = 32,
		name = "Heal Powder",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[38] = {
		id = 38,
		name = "Lava Cookie",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[133] = {
		id = 133,
		name = "Cheri Berry",
		type = MiscData.StatusType.Paralyze,
		pocket = MiscData.BagPocket.Berries,
	},
	[134] = {
		id = 134,
		name = "Chesto Berry",
		type = MiscData.StatusType.Sleep,
		pocket = MiscData.BagPocket.Berries,
	},
	[135] = {
		id = 135,
		name = "Pecha Berry",
		type = MiscData.StatusType.Poison,
		pocket = MiscData.BagPocket.Berries,
	},
	[136] = {
		id = 136,
		name = "Rawst Berry",
		type = MiscData.StatusType.Burn,
		pocket = MiscData.BagPocket.Berries,
	},
	[137] = {
		id = 137,
		name = "Aspear Berry",
		type = MiscData.StatusType.Freeze,
		pocket = MiscData.BagPocket.Berries,
	},
	[141] = {
		id = 141,
		name = "Lum Berry",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Berries,
	},
}

MiscData.EvolutionStones = {
	[93] = {
		id = 93,
		name = "Sun Stone",
		evolutions = {PokemonData.Evolutions.SUN, PokemonData.Evolutions.LEAF_SUN, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[94] = {
		id = 94,
		name = "Moon Stone",
		evolutions = {PokemonData.Evolutions.MOON, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[95] = {
		id = 95,
		name = "Fire Stone",
		evolutions = {PokemonData.Evolutions.FIRE, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[96] = {
		id = 96,
		name = "Thunder Stone",
		evolutions = {PokemonData.Evolutions.THUNDER, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[97] = {
		id = 97,
		name = "Water Stone",
		evolutions = {PokemonData.Evolutions.WATER, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[98] = {
		id = 98,
		name = "Leaf Stone",
		evolutions = {PokemonData.Evolutions.LEAF, PokemonData.Evolutions.LEAF_SUN},
		pocket = MiscData.BagPocket.Items,
	},
}
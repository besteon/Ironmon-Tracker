MiscData = {}
-- List of items: https://bulbapedia.bulbagarden.net/wiki/List_of_items_by_index_number_(Generation_III)

MiscData.TableData = {
	growth = { 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4 },
	attack = { 2, 2, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3 },
	effort = { 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3, 1, 1, 1, 1, 1, 1, 4, 3, 4, 3, 2, 2 },
	misc   = { 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 1, 1, 1, 1, 1, 1 },
}

MiscData.Gender = {
	MALE = 0,
	FEMALE = 254,
	UNKNOWN = 255,
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
	Constant = "Constant",
	Percentage = "Percentage",
}

MiscData.StatusType = {
	None = 0,
	Sleep = 1,
	Poison = 2,
	Burn = 3,
	Freeze = 4,
	Paralyze = 5,
	Toxic = 6,
	Confusion = 30,
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

function MiscData.updateResources()
	if Resources.Game.NatureNames and #Resources.Game.NatureNames > 0 then
		MiscData.Natures = Resources.Game.NatureNames
	end
	if Resources.Game.ItemNames and #Resources.Game.ItemNames > 0 then
		MiscData.Items = Resources.Game.ItemNames
	end
	for itemId, item in pairs(MiscData.HealingItems) do
		if Resources.Game.ItemNames[itemId] then
			item.name = Resources.Game.ItemNames[itemId]
		end
	end
	for itemId, item in pairs(MiscData.StatusItems) do
		if Resources.Game.ItemNames[itemId] then
			item.name = Resources.Game.ItemNames[itemId]
		end
	end
	for itemId, item in pairs(MiscData.PPItems) do
		if Resources.Game.ItemNames[itemId] then
			item.name = Resources.Game.ItemNames[itemId]
		end
	end
	for itemId, item in pairs(MiscData.EvolutionStones) do
		if Resources.Game.ItemNames[itemId] then
			item.name = Resources.Game.ItemNames[itemId]
		end
	end
end

-- Returns an absolute filepath to the icon image for the item, or nil if not available
--- @param itemId number
--- @return string? filepath
function MiscData.getItemIcon(itemId)
	itemId = itemId or 0
	local item = MiscData.HealingItems[itemId]
		or MiscData.StatusItems[itemId]
		or MiscData.PPItems[itemId]
		or MiscData.EvolutionStones[itemId]
		or MiscData.BattleItems[itemId]
		or MiscData.OtherItems[itemId] or {}
	if item.icon then
		return FileManager.buildImagePath(FileManager.Folders.Icons, item.icon, ".png")
	else
		return nil
	end
end

---Returns the Gender of a Pokemon based on its personality value.
---@param pokemonID number
---@param personality number
---@return number gender MiscData.Gender
function MiscData.getMonGender(pokemonID, personality)
	if not PokemonData.isValid(pokemonID) then
		return MiscData.Gender.UNKNOWN
	end

	local threshold = Memory.readbyte(GameSettings.gBaseStats + (pokemonID * Program.Addresses.sizeofBaseStatsPokemon) + PokemonData.Addresses.offsetGenderRatio)
	if threshold == MiscData.Gender.MALE then
		return MiscData.Gender.MALE
	elseif threshold == MiscData.Gender.FEMALE then
		return MiscData.Gender.FEMALE
	elseif threshold == MiscData.Gender.UNKNOWN then
		return MiscData.Gender.UNKNOWN
	else
		if personality % 256 >= threshold then
			return MiscData.Gender.MALE
		else
			return MiscData.Gender.FEMALE
		end
	end
end

-- Ordered lists that are populated from Resources
MiscData.Natures = {}
MiscData.Items = {}

MiscData.PokeBalls = {}
MiscData.TMs = {}
MiscData.HMs = {}
for i=1, 12, 1 do
	MiscData.PokeBalls[i] = true
end
for i=289, 338, 1 do
	MiscData.TMs[i] = {
		icon = "tiny-tm",
		pocket = MiscData.BagPocket.TMHM,
	}
end
for i=339, 346, 1 do
	MiscData.HMs[i] = {
		icon = "tiny-tm",
		pocket = MiscData.BagPocket.TMHM,
	}
end

MiscData.HealingItems = {
	[13] = {
		id = 13,
		name = "Potion",
		icon = "potion",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[19] = {
		id = 19,
		name = "Full Restore",
		icon = "full-restore",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[20] = {
		id = 20,
		name = "Max Potion",
		icon = "max-potion",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[21] = {
		id = 21,
		name = "Hyper Potion",
		icon = "hyper-potion",
		amount = 200,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[22] = {
		id = 22,
		name = "Super Potion",
		icon = "super-potion",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[26] = {
		id = 26,
		name = "Fresh Water",
		icon = "fresh-water",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[27] = {
		id = 27,
		name = "Soda Pop",
		icon = "soda-pop",
		amount = 60,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[28] = {
		id = 28,
		name = "Lemonade",
		icon = "lemonade",
		amount = 80,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[29] = {
		id = 29,
		name = "Moomoo Milk",
		icon = "moomoo-milk",
		amount = 100,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[30] = {
		id = 30,
		name = "EnergyPowder",
		icon = "energy-powder",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[31] = {
		id = 31,
		name = "Energy Root",
		icon = "energy-root",
		amount = 200,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[44] = {
		id = 44,
		name = "Berry Juice",
		icon = "berry-juice",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[139] = {
		id = 139,
		name = "Oran Berry",
		icon = "oran-berry",
		amount = 10,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Berries,
	},
	[142] = {
		id = 142,
		name = "Sitrus Berry",
		icon = "sitrus-berry",
		amount = 30,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Berries,
	},
	[143] = {
		id = 143,
		name = "Figy Berry",
		icon = "oran-berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[144] = {
		id = 144,
		name = "Wiki Berry",
		icon = "oran-berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[145] = {
		id = 145,
		name = "Mago Berry",
		icon = "oran-berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[146] = {
		id = 146,
		name = "Aguav Berry",
		icon = "oran-berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[147] = {
		id = 147,
		name = "Iapapa Berry",
		icon = "oran-berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
	[175] = {
		id = 175,
		name = "Enigma Berry",
		icon = "oran-berry",
		amount = 12.5,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Berries,
	},
}

MiscData.StatusItems = {
	[14] = {
		id = 14,
		name = "Antidote",
		icon = "full-heal",
		type = MiscData.StatusType.Poison,
		pocket = MiscData.BagPocket.Items,
	},
	[15] = {
		id = 15,
		name = "Burn Heal",
		icon = "full-heal",
		type = MiscData.StatusType.Burn,
		pocket = MiscData.BagPocket.Items,
	},
	[16] = {
		id = 16,
		name = "Ice Heal",
		icon = "full-heal",
		type = MiscData.StatusType.Freeze,
		pocket = MiscData.BagPocket.Items,
	},
	[17] = {
		id = 17,
		name = "Awakening",
		icon = "full-heal",
		type = MiscData.StatusType.Sleep,
		pocket = MiscData.BagPocket.Items,
	},
	[18] = {
		id = 18,
		name = "Parlyz Heal",
		icon = "full-heal",
		type = MiscData.StatusType.Paralyze,
		pocket = MiscData.BagPocket.Items,
	},
	[19] = {
		id = 19,
		name = "Full Restore",
		icon = "full-restore",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[23] = {
		id = 23,
		name = "Full Heal",
		icon = "full-heal",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[32] = {
		id = 32,
		name = "Heal Powder",
		icon = "heal-powder",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[38] = {
		id = 38,
		name = "Lava Cookie",
		icon = "lava-cookie",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[133] = {
		id = 133,
		name = "Cheri Berry",
		icon = "cheri-berry",
		type = MiscData.StatusType.Paralyze,
		pocket = MiscData.BagPocket.Berries,
	},
	[134] = {
		id = 134,
		name = "Chesto Berry",
		icon = "chesto-berry",
		type = MiscData.StatusType.Sleep,
		pocket = MiscData.BagPocket.Berries,
	},
	[135] = {
		id = 135,
		name = "Pecha Berry",
		icon = "pecha-berry",
		type = MiscData.StatusType.Poison,
		pocket = MiscData.BagPocket.Berries,
	},
	[136] = {
		id = 136,
		name = "Rawst Berry",
		icon = "rawst-berry",
		type = MiscData.StatusType.Burn,
		pocket = MiscData.BagPocket.Berries,
	},
	[137] = {
		id = 137,
		name = "Aspear Berry",
		icon = "aspear-berry",
		type = MiscData.StatusType.Freeze,
		pocket = MiscData.BagPocket.Berries,
	},
	[140] = {
		id = 140,
		name = "Persim Berry",
		icon = "persim-berry",
		type = MiscData.StatusType.Confusion,
		pocket = MiscData.BagPocket.Berries,
	},
	[141] = {
		id = 141,
		name = "Lum Berry",
		icon = "lum-berry",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Berries,
	},
}

MiscData.PPItems = {
	[34] = {
		id = 34,
		name = "Ether",
		icon = "ether",
		amount = 10,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[35] = {
		id = 35,
		name = "Max Ether",
		icon = "ether",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[36] = {
		id = 36,
		name = "Elixir",
		icon = "elixir",
		amount = 10,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[37] = {
		id = 37,
		name = "Max Elixir",
		icon = "elixir",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[138] = {
		id = 138,
		name = "Leppa Berry",
		icon = "leppa-berry",
		amount = 10,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Berries,
	},
}

MiscData.EvolutionStones = {
	[93] = {
		id = 93,
		name = "Sun Stone",
		icon = "sun-stone",
		pocket = MiscData.BagPocket.Items,
	},
	[94] = {
		id = 94,
		name = "Moon Stone",
		icon = "moon-stone",
		pocket = MiscData.BagPocket.Items,
	},
	[95] = {
		id = 95,
		name = "Fire Stone",
		icon = "fire-stone",
		pocket = MiscData.BagPocket.Items,
	},
	[96] = {
		id = 96,
		name = "Thunderstone",
		icon = "thunder-stone",
		pocket = MiscData.BagPocket.Items,
	},
	[97] = {
		id = 97,
		name = "Water Stone",
		icon = "water-stone",
		pocket = MiscData.BagPocket.Items,
	},
	[98] = {
		id = 98,
		name = "Leaf Stone",
		icon = "leaf-stone",
		pocket = MiscData.BagPocket.Items,
	},
}

MiscData.BattleItems = {
	[39] = {
		icon = "blue-flute",
		pocket = MiscData.BagPocket.Items,
	},
	[40] = {
		icon = "yellow-flute",
		pocket = MiscData.BagPocket.Items,
	},
	[41] = {
		icon = "red-flute",
		pocket = MiscData.BagPocket.Items,
	},
}
for i=73, 79, 1 do -- X Items, Dire Hit, Guard Spec.
	MiscData.BattleItems[i] = {
		icon = "x-item",
		pocket = MiscData.BagPocket.Items,
	}
end

MiscData.OtherItems = {}
for i=63, 71, 1 do -- Vitamins and Candies
	MiscData.OtherItems[i] = {
		icon = i == 68 and "candy" or "vitamin",
		pocket = MiscData.BagPocket.Items,
	}
end
MiscData.OtherItems[83] = { -- Super Repel
	icon = "repel",
	pocket = MiscData.BagPocket.Items,
}
MiscData.OtherItems[84] = { -- Max Repel
	icon = "repel",
	pocket = MiscData.BagPocket.Items,
}
MiscData.OtherItems[86] = { -- Repel
	icon = "repel",
	pocket = MiscData.BagPocket.Items,
}
MiscData.OtherItems[180] = { -- White Herb
	icon = "white-herb",
	pocket = MiscData.BagPocket.Items,
}
MiscData.OtherItems[185] = { -- Mental Herb
	icon = "mental-herb",
	pocket = MiscData.BagPocket.Items,
}
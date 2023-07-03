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
	for itemId, item in pairs(MiscData.EvolutionStones) do
		if Resources.Game.ItemNames[itemId] then
			item.name = Resources.Game.ItemNames[itemId]
		end
	end
end

-- Ordered lists that are populated from Resources
MiscData.Natures = {}
MiscData.Items = {}

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
		pocket = MiscData.BagPocket.Items,
	},
	[94] = {
		id = 94,
		name = "Moon Stone",
		pocket = MiscData.BagPocket.Items,
	},
	[95] = {
		id = 95,
		name = "Fire Stone",
		pocket = MiscData.BagPocket.Items,
	},
	[96] = {
		id = 96,
		name = "Thunder Stone",
		pocket = MiscData.BagPocket.Items,
	},
	[97] = {
		id = 97,
		name = "Water Stone",
		pocket = MiscData.BagPocket.Items,
	},
	[98] = {
		id = 98,
		name = "Leaf Stone",
		pocket = MiscData.BagPocket.Items,
	},
}
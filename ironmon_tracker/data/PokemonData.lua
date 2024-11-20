PokemonData = {}

PokemonData.Values = {
	EggId = 412,
	GhostId = 413, -- Pokémon Tower's Silph Scope Ghost
	DefaultBaseFriendship = 70,
	FriendshipRequiredToEvo = 220,
}

-- https://github.com/pret/pokefirered/blob/0c17a3b041a56f176f23145e4a4c0ae758f8d720/include/pokemon.h#L208-L236
PokemonData.Addresses = {
	offsetBaseStats = 0x0,
	offsetTypes = 0x6,
	offsetCatchRate = 0x8,
	offsetExpYield = 0x9,
	offsetGenderRatio = 0x10,
	offsetBaseFriendship = 0x12,
	offsetAbilities = 0x16,

	sizeofExpYield = 1,
}

PokemonData.IsRand = {
	types = false,
	abilities = false,
	friendshipBase = false,
	expYield = false
}

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
	-- FAIRY = "fairy", -- Currently unused. Expect this to be unused in Gen 1-5
	UNKNOWN = "unknown", -- For the move "Curse" in Gen 2-4
	EMPTY = "", -- No second type for this Pokémon or an empty field
}

-- Enumerated constants that defines various evolution possibilities
-- This enum does NOT include levels for evolution, only stones, friendship, no evolution, etc.
PokemonData.Evolutions = {
	-- This Pokémon does not evolve.
	NONE = {
		abbreviation = Constants.BLANKLINE,
		short = { Constants.BLANKLINE, },
		detailed = { Constants.BLANKLINE, },
	},
	-- Unused directly, necessary as an info index
	LEVEL = {
		abbreviation = "LEVEL",
		short = { "Lv.%s", }, -- requires level parameter
		detailed = { "Level %s", }, -- requires level value
	},
	-- High friendship
	FRIEND = {
		abbreviation = "FRIEND",
		short = { "Friend", },
		detailed = { "%s Friendship", }, -- requires friendship value
	},
	-- High friendship, Pokémon has enough friendship to evolve
	FRIEND_READY = {
		abbreviation = "READY",
	},
	-- Various evolution stone items
	EEVEE_STONES = {
		abbreviation = "STONE",
		short = { "Thunder", "Water", "Fire", "Sun", "Moon", },
		detailed = { "5 Diff. Stones", },
		evoItemIds = { 93, 94, 95, 96, 97 },
	},
	-- Thunderstone item
	THUNDER = {
		abbreviation = "THUNDER",
		short = { "Thunder", },
		detailed = { "Thunderstone", },
		evoItemIds = { 96 },
	},
	-- Fire stone item
	FIRE = {
		abbreviation = "FIRE",
		short = { "Fire", },
		detailed = { "Fire Stone", },
		evoItemIds = { 95 },
	},
	-- Water stone item
	WATER = {
		abbreviation = "WATER",
		short = { "Water", },
		detailed = { "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Moon stone item
	MOON = {
		abbreviation = "MOON",
		short = { "Moon", },
		detailed = { "Moon Stone", },
		evoItemIds = { 94 },
	},
	-- Leaf stone item
	LEAF = {
		abbreviation = "LEAF",
		short = { "Leaf", },
		detailed = { "Leaf Stone", },
		evoItemIds = { 98 },
	},
	-- Sun stone item
	SUN = {
		abbreviation = "SUN",
		short = { "Sun", },
		detailed = { "Sun Stone", },
		evoItemIds = { 93 },
	},
	-- Leaf or Sun stone items
	LEAF_SUN = {
		abbreviation = "LF/SN",
		short = { "Leaf", "Sun", },
		detailed = { "Leaf Stone", "Sun Stone", },
		evoItemIds = { 93, 98, },
	},
	-- Water stone item or at level 30
	WATER30 = {
		abbreviation = "30/WTR",
		short = { "Lv.30", "Water", },
		detailed = { "Level 30", "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Water stone item or at level 37
	WATER37 = {
		abbreviation = "37/WTR",
		short = { "Lv.37", "Water", },
		detailed = { "Level 37", "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Water stone item or at level 37 (reverse order)
	WATER37_REV = {
		abbreviation = "WTR/37",
		short = { "Water", "Lv.37", },
		detailed = { "Water Stone", "Level 37", },
		evoItemIds = { 97 },
	},
}

function PokemonData.initialize()
	PokemonData.buildData()
	PokemonData.checkIfDataIsRandomized()
end

function PokemonData.updateResources()
	for i, val in ipairs(PokemonData.Pokemon) do
		if Resources.Game.PokemonNames[i] then
			val.name = Resources.Game.PokemonNames[i]
		end
	end

	-- Manually add in each evolution translation, as each has different formatting
	local PE = PokemonData.Evolutions
	local RPED = Resources.PokemonEvolutionDetails
	-- PE.LEVEL.abbreviation = RPED.LEVEL.abbreviation -- Doesn't need translation; not displayed
	PE.LEVEL.short = { RPED.LEVEL.short .. "%s" }
	PE.LEVEL.detailed = { RPED.LEVEL.detailed .. " %s" }
	PE.FRIEND.abbreviation = RPED.FRIEND.abbreviation
	PE.FRIEND.short = { RPED.FRIEND.short }
	PE.FRIEND.detailed = { "%s " .. RPED.FRIEND.detailed }
	PE.FRIEND_READY.abbreviation = RPED.FRIEND_READY.abbreviation
	PE.EEVEE_STONES.abbreviation = RPED.EEVEE_STONES.abbreviation
	PE.EEVEE_STONES.short = { RPED.THUNDER.short, RPED.WATER.short, RPED.FIRE.short, RPED.SUN.short, RPED.MOON.short, }
	PE.EEVEE_STONES.detailed = { RPED.EEVEE_STONES.detailed, }
	PE.THUNDER.abbreviation = RPED.THUNDER.abbreviation
	PE.THUNDER.short = { RPED.THUNDER.short }
	PE.THUNDER.detailed = { RPED.THUNDER.detailed }
	PE.FIRE.abbreviation = RPED.FIRE.abbreviation
	PE.FIRE.short = { RPED.FIRE.short }
	PE.FIRE.detailed = { RPED.FIRE.detailed }
	PE.WATER.abbreviation = RPED.WATER.abbreviation
	PE.WATER.short = { RPED.WATER.short }
	PE.WATER.detailed = { RPED.WATER.detailed }
	PE.MOON.abbreviation = RPED.MOON.abbreviation
	PE.MOON.short = { RPED.MOON.short }
	PE.MOON.detailed = { RPED.MOON.detailed }
	PE.LEAF.abbreviation = RPED.LEAF.abbreviation
	PE.LEAF.short = { RPED.LEAF.short }
	PE.LEAF.detailed = { RPED.LEAF.detailed }
	PE.SUN.abbreviation = RPED.SUN.abbreviation
	PE.SUN.short = { RPED.SUN.short }
	PE.SUN.detailed = { RPED.SUN.detailed }
	PE.LEAF_SUN.abbreviation = RPED.LEAF_SUN.abbreviation
	PE.LEAF_SUN.short = { RPED.LEAF.short, RPED.SUN.short, }
	PE.LEAF_SUN.detailed = { RPED.LEAF.detailed, RPED.SUN.detailed, }
	PE.WATER30.abbreviation = RPED.WATER30.abbreviation
	PE.WATER30.short = { RPED.LEVEL.short .. "30", RPED.WATER.short, }
	PE.WATER30.detailed = { RPED.LEVEL.detailed .. " 30", RPED.WATER.detailed, }
	PE.WATER37.abbreviation = RPED.WATER37.abbreviation
	PE.WATER37.short = { RPED.LEVEL.short .. "37", RPED.WATER.short, }
	PE.WATER37.detailed = { RPED.LEVEL.detailed .. " 37", RPED.WATER.detailed, }
	PE.WATER37_REV.abbreviation = RPED.WATER37_REV.abbreviation
	PE.WATER37_REV.short = { RPED.WATER.short, RPED.LEVEL.short .. "37", }
	PE.WATER37_REV.detailed = { RPED.WATER.detailed, RPED.LEVEL.detailed .. " 37", }
end

---Read in PokemonData from game memory: https://github.com/pret/pokefirered/blob/master/include/pokemon.h#L208
---@param forced boolean? Optional, forces the data to be read in from the game
function PokemonData.buildData(forced)
	-- if not forced or someNonExistentCondition then -- Currently Unused/unneeded
	-- 	return
	-- end
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		pokemon.pokemonID = id

		if id < 252 or id > 276 then -- Skip fake Pokemon
			local addrOffset = GameSettings.gBaseStats + (id * Program.Addresses.sizeofBaseStatsPokemon)

			-- BST (6 bytes)
			local baseHPAttack = Memory.readword(addrOffset + PokemonData.Addresses.offsetBaseStats)
			local baseDefenseSpeed = Memory.readword(addrOffset + PokemonData.Addresses.offsetBaseStats + 2)
			local baseSpASpD = Memory.readword(addrOffset + PokemonData.Addresses.offsetBaseStats + 4)
			pokemon.baseStats = {
				hp = Utils.getbits(baseHPAttack, 0, 8),
				atk = Utils.getbits(baseHPAttack, 8, 8),
				def = Utils.getbits(baseDefenseSpeed, 0, 8),
				spe = Utils.getbits(baseDefenseSpeed, 8, 8),
				spa = Utils.getbits(baseSpASpD, 0, 8),
				spd = Utils.getbits(baseSpASpD, 8, 8)
			}
			pokemon.bstCalculated = 0
			for _, baseStat in pairs(pokemon.baseStats) do
				pokemon.bstCalculated = pokemon.bstCalculated + baseStat
			end

			-- Types (2 bytes)
			local typesData = Memory.readword(addrOffset + PokemonData.Addresses.offsetTypes)
			local typeOne = Utils.getbits(typesData, 0, 8)
			local typeTwo = Utils.getbits(typesData, 8, 8)
			pokemon.types = {
				PokemonData.TypeIndexMap[typeOne],
				typeOne ~= typeTwo and PokemonData.TypeIndexMap[typeTwo] or PokemonData.Types.EMPTY,
			}

			--Catch Rate (1 byte)
			pokemon.catchRate = Memory.readbyte(addrOffset + PokemonData.Addresses.offsetCatchRate)

			-- Exp Yield
			if PokemonData.Addresses.sizeofExpYield == 2 then
				pokemon.expYield = Memory.readword(addrOffset + PokemonData.Addresses.offsetExpYield)
			else
				pokemon.expYield = Memory.readbyte(addrOffset + PokemonData.Addresses.offsetExpYield)
			end

			-- Base Friendship (1 byte)
			pokemon.friendshipBase = Memory.readbyte(addrOffset + PokemonData.Addresses.offsetBaseFriendship)

			-- Abilities (2 bytes)
			local abilitiesData = Memory.readword(addrOffset + PokemonData.Addresses.offsetAbilities)
			pokemon.abilities = {
				Utils.getbits(abilitiesData, 0, 8),
				Utils.getbits(abilitiesData, 8, 8),
			}
		end
	end
end

--- Compare data from game memory with original game data to determine what's been randomized
function PokemonData.checkIfDataIsRandomized()
	PokemonData.IsRand.types = false
	PokemonData.IsRand.abilities = false
	PokemonData.IsRand.friendshipBase = false
	PokemonData.IsRand.expYield = false

	-- Arbitrarilty check two different pokemon for randomized information
	local bulbasaur = PokemonData.Pokemon[1]
	local lapras = PokemonData.Pokemon[131]

	if bulbasaur.types[1] ~= PokemonData.Types.GRASS or bulbasaur.types[2] ~= PokemonData.Types.POISON then
		PokemonData.IsRand.types = true
	elseif lapras.types[1] ~= PokemonData.Types.WATER or lapras.types[2] ~= PokemonData.Types.ICE then
		PokemonData.IsRand.types = true
	end
	if bulbasaur.abilities[1] ~= 65 or bulbasaur.abilities[2] ~= 65 then -- 65 = Overgrow
		PokemonData.IsRand.abilities = true
	elseif lapras.abilities[1] ~= 11 or lapras.abilities[2] ~= 75 then -- 11 = Water Absorb, 75 = Shell Armor
		PokemonData.IsRand.abilities = true
	end
	if bulbasaur.friendshipBase ~= PokemonData.Values.DefaultBaseFriendship or lapras.friendshipBase ~= PokemonData.Values.DefaultBaseFriendship then
		PokemonData.IsRand.friendshipBase = true
	end
	if bulbasaur.expYield ~= 64 or lapras.expYield ~= 219 then
		PokemonData.IsRand.expYield = true
	end
end

function PokemonData.getTypeResource(typename)
	typename = typename or "unknown"
	return Resources.Game.PokemonTypes[typename] or Resources.Game.PokemonTypes.unknown
end

---@param pokemonID number
---@param abilityIndex number Specify 0 for the first ability or 1 for the second ability
---@return integer abilityId The abilityId of the Pokémon, or 0 if it doesn't exist
function PokemonData.getAbilityId(pokemonID, abilityIndex)
	if abilityIndex == nil or not PokemonData.isValid(pokemonID) then
		return 0
	end
	local pokemon = PokemonData.Pokemon[pokemonID]
	return pokemon.abilities[abilityIndex + 1] or 0 -- abilityNum stored from memory as [0 or 1]
end

---Returns true if the pokemonId is a valid, existing id of a pokemon in PokemonData.Pokemon
---@param pokemonID number
---@return boolean
function PokemonData.isValid(pokemonID)
	return pokemonID ~= nil and pokemonID >= 1 and pokemonID <= #PokemonData.Pokemon
end

---Returns true if the pokemonId is a valid id of a pokemon that can be drawn, usually from an image file
---@param pokemonID number
---@return boolean
function PokemonData.isImageIDValid(pokemonID)
	-- 0 is a valid placeholder id
	return PokemonData.isValid(pokemonID) or pokemonID == PokemonData.Values.EggId or pokemonID == PokemonData.Values.GhostId or pokemonID == 0
end

local idInternalToNat = {
	[277] = 252, [278] = 253, [279] = 254, [280] = 255, [281] = 256, [282] = 257, [283] = 258, [284] = 259,
	[285] = 260, [286] = 261, [287] = 262, [288] = 263, [289] = 264, [290] = 265, [291] = 266, [292] = 267, [293] = 268, [294] = 269,
	[295] = 270, [296] = 271, [297] = 272, [298] = 273, [299] = 274, [300] = 275, [304] = 276, [305] = 277, [309] = 278, [310] = 279,
	[392] = 280, [393] = 281, [394] = 282, [311] = 283, [312] = 284, [306] = 285, [307] = 286, [364] = 287, [365] = 288, [366] = 289,
	[301] = 290, [302] = 291, [303] = 292, [370] = 293, [371] = 294, [372] = 295, [335] = 296, [336] = 297, [350] = 298, [320] = 299,
	[315] = 300, [316] = 301, [322] = 302, [355] = 303, [382] = 304, [383] = 305, [384] = 306, [356] = 307, [357] = 308, [337] = 309,
	[338] = 310, [353] = 311, [354] = 312, [386] = 313, [387] = 314, [363] = 315, [367] = 316, [368] = 317, [330] = 318, [331] = 319,
	[313] = 320, [314] = 321, [339] = 322, [340] = 323, [321] = 324, [351] = 325, [352] = 326, [308] = 327, [332] = 328, [333] = 329,
	[334] = 330, [344] = 331, [345] = 332, [358] = 333, [359] = 334, [380] = 335, [379] = 336, [348] = 337, [349] = 338, [323] = 339,
	[324] = 340, [326] = 341, [327] = 342, [318] = 343, [319] = 344, [388] = 345, [389] = 346, [390] = 347, [391] = 348, [328] = 349,
	[329] = 350, [385] = 351, [317] = 352, [377] = 353, [378] = 354, [361] = 355, [362] = 356, [369] = 357, [411] = 358, [376] = 359,
	[360] = 360, [346] = 361, [347] = 362, [341] = 363, [342] = 364, [343] = 365, [373] = 366, [374] = 367, [375] = 368, [381] = 369,
	[325] = 370, [395] = 371, [396] = 372, [397] = 373, [398] = 374, [399] = 375, [400] = 376, [401] = 377, [402] = 378, [403] = 379,
	[407] = 380, [408] = 381, [404] = 382, [405] = 383, [406] = 384, [409] = 385, [410] = 386,
}
local idNatToInternal = {
	[252] = 277, [253] = 278, [254] = 279, [255] = 280, [256] = 281, [257] = 282, [258] = 283, [259] = 284,
	[260] = 285, [261] = 286, [262] = 287, [263] = 288, [264] = 289, [265] = 290, [266] = 291, [267] = 292, [268] = 293, [269] = 294,
	[270] = 295, [271] = 296, [272] = 297, [273] = 298, [274] = 299, [275] = 300, [276] = 304, [277] = 305, [278] = 309, [279] = 310,
	[280] = 392, [281] = 393, [282] = 394, [283] = 311, [284] = 312, [285] = 306, [286] = 307, [287] = 364, [288] = 365, [289] = 366,
	[290] = 301, [291] = 302, [292] = 303, [293] = 370, [294] = 371, [295] = 372, [296] = 335, [297] = 336, [298] = 350, [299] = 320,
	[300] = 315, [301] = 316, [302] = 322, [303] = 355, [304] = 382, [305] = 383, [306] = 384, [307] = 356, [308] = 357, [309] = 337,
	[310] = 338, [311] = 353, [312] = 354, [313] = 386, [314] = 387, [315] = 363, [316] = 367, [317] = 368, [318] = 330, [319] = 331,
	[320] = 313, [321] = 314, [322] = 339, [323] = 340, [324] = 321, [325] = 351, [326] = 352, [327] = 308, [328] = 332, [329] = 333,
	[330] = 334, [331] = 344, [332] = 345, [333] = 358, [334] = 359, [335] = 380, [336] = 379, [337] = 348, [338] = 349, [339] = 323,
	[340] = 324, [341] = 326, [342] = 327, [343] = 318, [344] = 319, [345] = 388, [346] = 389, [347] = 390, [348] = 391, [349] = 328,
	[350] = 329, [351] = 385, [352] = 317, [353] = 377, [354] = 378, [355] = 361, [356] = 362, [357] = 369, [358] = 411, [359] = 376,
	[360] = 360, [361] = 346, [362] = 347, [363] = 341, [364] = 342, [365] = 343, [366] = 373, [367] = 374, [368] = 375, [369] = 381,
	[370] = 325, [371] = 395, [372] = 396, [373] = 397, [374] = 398, [375] = 399, [376] = 400, [377] = 401, [378] = 402, [379] = 403,
	[380] = 407, [381] = 408, [382] = 404, [383] = 405, [384] = 406, [385] = 409, [386] = 410,
}

--- Converts a Gen 3 Internal Dex # to its matching National Pokédex #
--- @param pokemonID integer The Pokémon ID to convert (Gen 3 internal Pokédex #)
--- @return integer
function PokemonData.dexMapInternalToNational(pokemonID)
	return idInternalToNat[pokemonID or 0] or pokemonID
end

--- Converts a National Pokédex # to its matching Gen 3 Internal Dex #
--- @param pokemonID integer The Pokémon ID to convert (National Pokédex #)
--- @return integer
function PokemonData.dexMapNationalToInternal(pokemonID)
	return idNatToInternal[pokemonID or 0] or pokemonID
end

function PokemonData.getIdFromName(pokemonName)
	for id, pokemon in pairs(PokemonData.Pokemon) do
		if pokemon.name == pokemonName then
			return id
		end
	end

	return nil
end

function PokemonData.namesToList()
	local pokemonNames = {}
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		if id < 252 or id > 276 then -- Skip fake Pokemon
			table.insert(pokemonNames, pokemon.name)
		end
	end
	return pokemonNames
end

-- Returns a table that contains the type weaknesses, resistances, and immunities for a Pokémon, listed as type-strings
function PokemonData.getEffectiveness(pokemonID)
	local effectiveness = {
		[0] = {},
		[0.25] = {},
		[0.5] = {},
		[1] = {},
		[2] = {},
		[4] = {},
	}

	if not PokemonData.isValid(pokemonID) then
		return effectiveness
	end

	local pokemon = PokemonData.Pokemon[pokemonID]

	for moveType, typeMultiplier in pairs(MoveData.TypeToEffectiveness) do
		local total = 1
		if typeMultiplier[pokemon.types[1]] ~= nil then
			total = total * typeMultiplier[pokemon.types[1]]
		end
		if pokemon.types[2] ~= pokemon.types[1] and typeMultiplier[pokemon.types[2]] ~= nil then
			total = total * typeMultiplier[pokemon.types[2]]
		end
		if effectiveness[total] ~= nil then
			table.insert(effectiveness[total], moveType)
		end
	end

	return effectiveness
end

---Returns whole number between 0 and 100 representing the percent likelihood to catch a pokemon
---@param pokemonID number
---@param hpMax number
---@param hpCurrent number
---@param level number? Optional, the Pokémon level, used only for Nest Ball; defaults to 5
---@param status number? Optional, defaults to "None"
---@param ball number? Optional, defaults to Poké Ball (item id = 4)
---@param terrain number? Optional, defaults to 0 (no terrain); use 3 for UNDERWATER
---@param battleTurn number? Optional, defaults to 0; first turn of a battle
---@return number
function PokemonData.calcCatchRate(pokemonID, hpMax, hpCurrent, level, status, ball, terrain, battleTurn)
	if not PokemonData.isValid(pokemonID) or hpMax <= 0 or hpCurrent <= 0 then
		return 0
	end
	level = level or 5
	status = status or MiscData.StatusType.None
	ball = ball or 4
	terrain = terrain or 0
	battleTurn = battleTurn or 0

	-- Calculations based off of: https://bulbapedia.bulbagarden.net/wiki/Catch_rate#Capture_method_(Generation_III-IV)

	-- Estimate wild Pokémon's HP percent; round to nearest 10th
	local estimatedCurrHP = math.floor(math.ceil(hpCurrent / hpMax * 10) / 10 * hpMax)

	-- Changing to more closely resemble the actual in-game formula
	local hpMultiplier = (hpMax * 3 - estimatedCurrHP * 2) / (hpMax * 3)

	-- Determine base catch rate
	local pokemon = PokemonData.Pokemon[pokemonID]
	local baseCatchRate = pokemon.catchRate or 0

	-- Determine ball type bonus multiplier
	local ballBonusMap = {
		[1] = 255, -- Master Ball
		[2] = 20, -- Ultra Ball
		[3] = 15, -- Great Ball
		[4] = 10, -- Poke Ball
		[5] = 15, -- Safari Ball
		[6] = 30, -- Net Ball; only for WATER or BUG types
		[7] = 35, -- Dive Ball; only when map type is UNDERWATER
		[8] = 40, -- Nest Ball; subtract level of enemy, floor is 10
		[9] = 30, -- Repeat Ball; only if pokemon is flagged as caught already
		[10] = 10, -- Timer Ball; add turn counter, caps at 40
		[11] = 10, -- Luxury Ball
		[12] = 10, -- Premier Ball
	}
	local ballBonus
	if ball <= 5 or ball >= 11 then
		ballBonus = ballBonusMap[ball] or 10 -- default: poké ball
	elseif ball == 6 and (pokemon.types[1] == PokemonData.Types.WATER or pokemon.types[2] == PokemonData.Types.WATER or pokemon.types[1] == PokemonData.Types.BUG or pokemon.types[2] == PokemonData.Types.BUG) then
		ballBonus = ballBonusMap[ball]
	elseif ball == 7 and terrain == 3 then -- terrain 3: UNDERWATER
		ballBonus = ballBonusMap[ball]
	elseif ball == 8 then
		ballBonus = math.max(10, 40 - level)
	elseif ball == 9 then
		local dexAddr = Utils.getSaveBlock2Addr() + Program.Addresses.offsetPokedex + Program.Addresses.offsetPokedexOwned
		local bitIndex = math.floor((pokemonID - 1) / 8)
		local bitRemainder = (pokemonID - 1) % 8
		local dexValue = Memory.readbyte(dexAddr + bitIndex)
		if Utils.getbits(dexValue, bitRemainder, 1) == 1 then -- if 1, has caught the mon previously
			ballBonus = ballBonusMap[ball]
		end
	elseif ball == 10 then
		ballBonus = math.min(10 + battleTurn, 40)
	end
	ballBonus = (ballBonus or 10) / 10

	-- Determine status bonus multiplier
	local statusBonusMap = {
		[MiscData.StatusType.None] = 1,
		[MiscData.StatusType.Burn] = 1.5,
		[MiscData.StatusType.Freeze] = 2,
		[MiscData.StatusType.Paralyze] = 1.5,
		[MiscData.StatusType.Poison] = 1.5,
		[MiscData.StatusType.Toxic] = 1.5,
		[MiscData.StatusType.Sleep] = 2,
	}
	local statusBonus
	-- Note: In R/S, toxic does not increase catch rate
	if status == MiscData.StatusType.Toxic and (GameSettings.game == 1 or GameSettings.game == 2) then
		statusBonus = 1
	else
		statusBonus = statusBonusMap[status] or 1 -- default: none
	end

	--Number between 0 and a lot; 255+ means guaranteed catch
	local rawCatchRate = math.floor(math.floor(baseCatchRate * ballBonus * hpMultiplier) * statusBonus)
	local processedCatchRate = 0
	local percentage = 0
	if rawCatchRate <=0 then
		percentage = 0
	elseif rawCatchRate > 254 then
		percentage = 100
	else
		--Process rate is between 0 and 65535, represents chance of a 'ball shake'
		processedCatchRate = math.floor(1048560 / math.floor(math.sqrt(math.floor(math.sqrt(math.floor(16711680/rawCatchRate))))))
		processedCatchRate = math.floor(processedCatchRate / 65535 * 100) / 100
		--4 Ball shakes to catch. Technically comes out to dividing the original rate by 255, but using this formula to keep the cacluation consistent with the actual game's method
		percentage = math.floor(processedCatchRate * processedCatchRate * processedCatchRate * processedCatchRate * 100)
	end
	if percentage < 0 then
		return 0
	elseif percentage > 100 then
		return 100
	else
		return percentage
	end
end

---Reads from the game data all of the level-up moves learned by a Pokémon species
---@param pokemonID number
---@return table learnedMoves A list moves, each entry as a table: { id = number, level = number }
function PokemonData.readLevelUpMoves(pokemonID)
	local learnedMoves = {}
	if not PokemonData.isValid(pokemonID) then
		return learnedMoves
	end
	-- https://github.com/pret/pokefirered/blob/d2c592030d78d1a46df1cba562a3c7af677dbf21/src/data/pokemon/level_up_learnsets.h
	local LEVEL_UP_END = 0xFFFF
	-- gLevelUpLearnsets is an array of addresses for all Pokémon species; each entry is a 4 byte address
	local levelUpLearnsetPtr = Memory.readdword(GameSettings.gLevelUpLearnsets + (pokemonID * 4))
	for i=0, 50, 1 do -- MAX of 51 iterations, as a failsafe
		-- Each entry is 2 bytes formatted as: #define LEVEL_UP_MOVE(lvl, move) ((lvl << 9) | move)
		local levelUpMove = Memory.readword(levelUpLearnsetPtr + (i * 2))
		if levelUpMove == LEVEL_UP_END then
			break
		end
		local moveId = Utils.getbits(levelUpMove, 0, 9)
		local level = Utils.getbits(levelUpMove, 9, 7)
		table.insert(learnedMoves, { id = moveId, level = level })
	end
	return learnedMoves
end

PokemonData.TypeIndexMap = {
	[0x00] = PokemonData.Types.NORMAL,
	[0x01] = PokemonData.Types.FIGHTING,
	[0x02] = PokemonData.Types.FLYING,
	[0x03] = PokemonData.Types.POISON,
	[0x04] = PokemonData.Types.GROUND,
	[0x05] = PokemonData.Types.ROCK,
	[0x06] = PokemonData.Types.BUG,
	[0x07] = PokemonData.Types.GHOST,
	[0x08] = PokemonData.Types.STEEL,
	[0x09] = PokemonData.Types.UNKNOWN, -- MYSTERY
	[0x0A] = PokemonData.Types.FIRE,
	[0x0B] = PokemonData.Types.WATER,
	[0x0C] = PokemonData.Types.GRASS,
	[0x0D] = PokemonData.Types.ELECTRIC,
	[0x0E] = PokemonData.Types.PSYCHIC,
	[0x0F] = PokemonData.Types.ICE,
	[0x10] = PokemonData.Types.DRAGON,
	[0x11] = PokemonData.Types.DARK,
}

PokemonData.BlankPokemon = {
	pokemonID = 0,
	name = Constants.BLANKLINE,
	types = { PokemonData.Types.UNKNOWN, PokemonData.Types.EMPTY },
	abilities = { 0, 0 },
	evolution = PokemonData.Evolutions.NONE,
	bst = Constants.BLANKLINE,
	expYield = 0,
	movelvls = { {}, {} },
	weight = 0.0,
	friendshipBase = 0,
}

--[[
Data for each Pokémon (Gen 3) - Sourced from Bulbapedia
Format for an entry:
	pokemonID: integer -> The gen 3 pokedex id number for this Pokémon; automatically populated
	name: string -> Name of the Pokémon as it appears in game
	types: {string, string} -> Each Pokémon can have one or two types, using the PokemonData.Types enum to alias the strings; automatically populated from game memory
	evolution: string -> Displays the level, item, or other requirement a Pokémon needs to evolve
	bst: integer -> A sum of the base stats of the Pokémon
	expYield: integer -> Base experience yield of the Pokémon; automatically populated from game memory
	movelvls: {{integer list}, {integer list}} -> A pair of tables (1:RSE/2:FRLG) declaring the levels at which a Pokémon learns new moves or an empty list means it learns nothing
	weight: number -> pokemon's weight in kg (mainly used for Low Kick calculations)
]]
PokemonData.Pokemon = {
	{
		name = "Bulbasaur",
		evolution = "16",
		bst = 318,
		movelvls = { { 4, 7, 10, 15, 15, 20, 25, 32, 39, 46 }, { 4, 7, 10, 15, 15, 20, 25, 32, 39, 46 } },
		weight = 6.9
	},
	{
		name = "Ivysaur",
		evolution = "32",
		bst = 405,
		movelvls = { { 4, 7, 10, 15, 15, 22, 29, 38, 47, 56 }, { 4, 7, 10, 15, 15, 22, 29, 38, 47, 56 } },
		weight = 13.0
	},
	{
		name = "Venusaur",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 4, 7, 10, 15, 15, 22, 29, 41, 53, 65 }, { 4, 7, 10, 15, 15, 22, 29, 41, 53, 65 } },
		weight = 100.0
	},
	{
		name = "Charmander",
		evolution = "16",
		bst = 309,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.5
	},
	{
		name = "Charmeleon",
		evolution = "36",
		bst = 405,
		movelvls = { { 7, 13, 20, 27, 34, 41, 48, 55 }, { 7, 13, 20, 27, 34, 41, 48, 55 } },
		weight = 19.0
	},
	{
		name = "Charizard",
		evolution = PokemonData.Evolutions.NONE,
		bst = 534,
		movelvls = { { 7, 13, 20, 27, 34, 36, 44, 54, 64 }, { 7, 13, 20, 27, 34, 36, 44, 54, 64 } },
		weight = 90.5
	},
	{
		name = "Squirtle",
		evolution = "16",
		bst = 314,
		movelvls = { { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 9.0
	},
	{
		name = "Wartortle",
		evolution = "36",
		bst = 405,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 37, 45, 53 }, { 4, 7, 10, 13, 19, 25, 31, 37, 45, 53 } },
		weight = 22.5
	},
	{
		name = "Blastoise",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 42, 55, 68 }, { 4, 7, 10, 13, 19, 25, 31, 42, 55, 68 } },
		weight = 85.5
	},
	{
		name = "Caterpie",
		evolution = "7",
		bst = 195,
		movelvls = { {}, {} },
		weight = 2.9
	},
	{
		name = "Metapod",
		evolution = "10",
		bst = 205,
		movelvls = { { 7 }, { 7 } },
		weight = 9.9
	},
	{
		name = "Butterfree",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 }, { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 } },
		weight = 32.0
	},
	{
		name = "Weedle",
		evolution = "7",
		bst = 195,
		movelvls = { {}, {} },
		weight = 3.2
	},
	{
		name = "Kakuna",
		evolution = "10",
		bst = 205,
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beedrill",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45 }, { 10, 15, 20, 25, 30, 35, 40, 45 } },
		weight = 29.5
	},
	{
		name = "Pidgey",
		evolution = "18",
		bst = 251,
		movelvls = { { 5, 9, 13, 19, 25, 31, 39, 47 }, { 5, 9, 13, 19, 25, 31, 39, 47 } },
		weight = 1.8
	},
	{
		name = "Pidgeotto",
		evolution = "36",
		bst = 349,
		movelvls = { { 5, 9, 13, 20, 27, 34, 43, 52 }, { 5, 9, 13, 20, 27, 34, 43, 52 } },
		weight = 30.0
	},
	{
		name = "Pidgeot",
		evolution = PokemonData.Evolutions.NONE,
		bst = 469,
		movelvls = { { 5, 9, 13, 20, 27, 34, 48, 62 }, { 5, 9, 13, 20, 27, 34, 48, 62 } },
		weight = 39.5
	},
	{
		name = "Rattata",
		evolution = "20",
		bst = 253,
		movelvls = { { 7, 13, 20, 27, 34, 41 }, { 7, 13, 20, 27, 34, 41 } },
		weight = 3.5
	},
	{
		name = "Raticate",
		evolution = PokemonData.Evolutions.NONE,
		bst = 413,
		movelvls = { { 7, 13, 20, 30, 40, 50 }, { 7, 13, 20, 30, 40, 50 } },
		weight = 18.5
	},
	{
		name = "Spearow",
		evolution = "20",
		bst = 262,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.0
	},
	{
		name = "Fearow",
		evolution = PokemonData.Evolutions.NONE,
		bst = 442,
		movelvls = { { 7, 13, 26, 32, 40, 47 }, { 7, 13, 26, 32, 40, 47 } },
		weight = 38.0
	},
	{
		name = "Ekans",
		evolution = "22",
		bst = 288,
		movelvls = { { 8, 13, 20, 25, 32, 37, 37, 37, 44 }, { 8, 13, 20, 25, 32, 37, 37, 37, 44 } },
		weight = 6.9
	},
	{
		name = "Arbok",
		evolution = PokemonData.Evolutions.NONE,
		bst = 438,
		movelvls = { { 8, 13, 20, 28, 38, 46, 46, 46, 56 }, { 8, 13, 20, 28, 38, 46, 46, 46, 56 } },
		weight = 65.0
	},
	{
		name = "Pikachu",
		evolution = PokemonData.Evolutions.THUNDER,
		bst = 300,
		movelvls = { { 6, 8, 11, 15, 20, 26, 33, 41, 50 }, { 6, 8, 11, 15, 20, 26, 33, 41, 50 } },
		weight = 6.0
	},
	{
		name = "Raichu",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { {}, {} },
		weight = 30.0
	},
	{
		name = "Sandshrew",
		evolution = "22",
		bst = 300,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 12.0
	},
	{
		name = "Sandslash",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 6, 11, 17, 24, 33, 42, 52, 62 }, { 6, 11, 17, 24, 33, 42, 52, 62 } },
		weight = 29.5
	},
	{
		name = "Nidoran F",
		evolution = "16",
		bst = 275,
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 7.0
	},
	{
		name = "Nidorina",
		evolution = PokemonData.Evolutions.MOON,
		bst = 365,
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 20.0
	},
	{
		name = "Nidoqueen",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 23 }, { 22, 43 } },
		weight = 60.0
	},
	{
		name = "Nidoran M",
		evolution = "16",
		bst = 273,
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 9.0
	},
	{
		name = "Nidorino",
		evolution = PokemonData.Evolutions.MOON,
		bst = 365,
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 19.5
	},
	{
		name = "Nidoking",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 23 }, { 22, 43 } },
		weight = 62.0
	},
	{
		name = "Clefairy",
		evolution = PokemonData.Evolutions.MOON,
		bst = 323,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 7.5,
		friendshipBase = 140
	},
	{
		name = "Clefable",
		evolution = PokemonData.Evolutions.NONE,
		bst = 473,
		movelvls = { {}, {} },
		weight = 40.0,
		friendshipBase = 140
	},
	{
		name = "Vulpix",
		evolution = PokemonData.Evolutions.FIRE,
		bst = 299,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 9.9
	},
	{
		name = "Ninetales",
		evolution = PokemonData.Evolutions.NONE,
		bst = 505,
		movelvls = { { 45 }, { 45 } },
		weight = 19.9
	},
	{
		name = "Jigglypuff",
		evolution = PokemonData.Evolutions.MOON,
		bst = 270,
		movelvls = { { 4, 9, 14, 19, 24, 29, 34, 39, 44, 49 }, { 4, 9, 14, 19, 24, 29, 34, 39, 44, 49 } },
		weight = 5.5
	},
	{
		name = "Wigglytuff",
		evolution = PokemonData.Evolutions.NONE,
		bst = 425,
		movelvls = { {}, {} },
		weight = 12.0
	},
	{
		name = "Zubat",
		evolution = "22",
		bst = 245,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 7.5
	},
	{
		name = "Golbat",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 455,
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 55.0
	},
	{
		name = "Oddish",
		evolution = "21",
		bst = 320,
		movelvls = { { 7, 14, 16, 18, 23, 32, 39 }, { 7, 14, 16, 18, 23, 32, 39 } },
		weight = 5.4
	},
	{
		name = "Gloom",
		evolution = PokemonData.Evolutions.LEAF_SUN,
		bst = 395,
		movelvls = { { 7, 14, 16, 18, 24, 35, 44 }, { 7, 14, 16, 18, 24, 35, 44 } },
		weight = 8.6
	},
	{
		name = "Vileplume",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 44 }, { 44 } },
		weight = 18.6
	},
	{
		name = "Paras",
		evolution = "24",
		bst = 285,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 5.4
	},
	{
		name = "Parasect",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 29.5
	},
	{
		name = "Venonat",
		evolution = "31",
		bst = 305,
		movelvls = { { 9, 17, 20, 25, 28, 33, 36, 41 }, { 9, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 30.0
	},
	{
		name = "Venomoth",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 9, 17, 20, 25, 28, 31, 36, 42, 52 }, { 9, 17, 20, 25, 28, 31, 36, 42, 52 } },
		weight = 12.5
	},
	{
		name = "Diglett",
		evolution = "26",
		bst = 265,
		movelvls = { { 5, 9, 17, 25, 33, 41, 49 }, { 5, 9, 17, 21, 25, 33, 41, 49 } },
		weight = 0.8
	},
	{
		name = "Dugtrio",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 5, 9, 17, 25, 26, 38, 51, 64 }, { 5, 9, 17, 21, 25, 26, 38, 51, 64 } },
		weight = 33.3
	},
	{
		name = "Meowth",
		evolution = "28",
		bst = 290,
		movelvls = { { 11, 20, 28, 35, 41, 46, 50 }, { 10, 18, 25, 31, 36, 40, 43, 45 } },
		weight = 4.2
	},
	{
		name = "Persian",
		evolution = PokemonData.Evolutions.NONE,
		bst = 440,
		movelvls = { { 11, 20, 29, 38, 46, 53, 59 }, { 10, 18, 25, 34, 42, 49, 55, 61 } },
		weight = 32.0
	},
	{
		name = "Psyduck",
		evolution = "33",
		bst = 320,
		movelvls = { { 5, 10, 16, 23, 31, 40, 50 }, { 5, 10, 16, 23, 31, 40, 50 } },
		weight = 19.6
	},
	{
		name = "Golduck",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 5, 10, 16, 23, 31, 44, 58 }, { 5, 10, 16, 23, 31, 44, 58 } },
		weight = 76.6
	},
	{
		name = "Mankey",
		evolution = "28",
		bst = 305,
		movelvls = { { 9, 15, 21, 27, 33, 39, 45, 51 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 28.0
	},
	{
		name = "Primeape",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 9, 15, 21, 27, 28, 36, 45, 54, 63 }, { 6, 11, 16, 21, 26, 28, 35, 44, 53, 62 } },
		weight = 32.0
	},
	{
		name = "Growlithe",
		evolution = PokemonData.Evolutions.FIRE,
		bst = 350,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 19.0
	},
	{
		name = "Arcanine",
		evolution = PokemonData.Evolutions.NONE,
		bst = 555,
		movelvls = { { 49 }, { 49 } },
		weight = 155.0
	},
	{
		name = "Poliwag",
		evolution = "25",
		bst = 300,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 12.4
	},
	{
		name = "Poliwhirl",
		evolution = PokemonData.Evolutions.WATER37_REV, -- Level 37 replaces trade evolution for Politoed
		bst = 385,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51 }, { 7, 13, 19, 27, 35, 43, 51 } },
		weight = 20.0
	},
	{
		name = "Poliwrath",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 54.0
	},
	{
		name = "Abra",
		evolution = "16",
		bst = 310,
		movelvls = { {}, {} },
		weight = 19.5
	},
	{
		name = "Kadabra",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 400,
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 56.5
	},
	{
		name = "Alakazam",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 48.0
	},
	{
		name = "Machop",
		evolution = "28",
		bst = 305,
		movelvls = { { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 }, { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 } },
		weight = 19.5
	},
	{
		name = "Machoke",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 405,
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 70.5
	},
	{
		name = "Machamp",
		evolution = PokemonData.Evolutions.NONE,
		bst = 505,
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 130.0
	},
	{
		name = "Bellsprout",
		evolution = "21",
		bst = 300,
		movelvls = { { 6, 11, 15, 17, 19, 23, 30, 37, 45 }, { 6, 11, 15, 17, 19, 23, 30, 37, 45 } },
		weight = 4.0
	},
	{
		name = "Weepinbell",
		evolution = PokemonData.Evolutions.LEAF,
		bst = 390,
		movelvls = { { 6, 11, 15, 17, 19, 24, 33, 42, 54 }, { 6, 11, 15, 17, 19, 24, 33, 42, 54 } },
		weight = 6.4
	},
	{
		name = "Victreebel",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { {}, {} },
		weight = 15.5
	},
	{
		name = "Tentacool",
		evolution = "30",
		bst = 335,
		movelvls = { { 6, 12, 19, 25, 30, 36, 43, 49 }, { 6, 12, 19, 25, 30, 36, 43, 49 } },
		weight = 45.5
	},
	{
		name = "Tentacruel",
		evolution = PokemonData.Evolutions.NONE,
		bst = 515,
		movelvls = { { 6, 12, 19, 25, 30, 38, 47, 55 }, { 6, 12, 19, 25, 30, 38, 47, 55 } },
		weight = 55.0
	},
	{
		name = "Geodude",
		evolution = "25",
		bst = 300,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 20.0
	},
	{
		name = "Graveler",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 390,
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 105.0
	},
	{
		name = "Golem",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 300.0
	},
	{
		name = "Ponyta",
		evolution = "40",
		bst = 410,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45, 53 }, { 5, 9, 14, 19, 25, 31, 38, 45, 53 } },
		weight = 30.0
	},
	{
		name = "Rapidash",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 40, 50, 63 }, { 5, 9, 14, 19, 25, 31, 38, 40, 50, 63 } },
		weight = 95.0
	},
	{
		name = "Slowpoke",
		evolution = PokemonData.Evolutions.WATER37, -- Water stone replaces trade evolution to Slowking
		bst = 315,
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 36.0
	},
	{
		name = "Slowbro",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 6, 15, 20, 29, 34, 37, 46, 54 }, { 6, 13, 17, 24, 29, 36, 37, 44, 55 } },
		weight = 78.5
	},
	{
		name = "Magnemite",
		evolution = "30",
		bst = 325,
		movelvls = { { 6, 11, 16, 21, 26, 32, 38, 44, 50 }, { 6, 11, 16, 21, 26, 32, 38, 44, 50 } },
		weight = 6.0
	},
	{
		name = "Magneton",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 6, 11, 16, 21, 26, 35, 44, 53, 62 }, { 6, 11, 16, 21, 26, 35, 44, 53, 62 } },
		weight = 60.0
	},
	{
		name = "Farfetch'd",
		evolution = PokemonData.Evolutions.NONE,
		bst = 352,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 15.0
	},
	{
		name = "Doduo",
		evolution = "31",
		bst = 310,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45 }, { 9, 13, 21, 25, 33, 37, 45 } },
		weight = 39.2
	},
	{
		name = "Dodrio",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 9, 13, 21, 25, 38, 47, 60 }, { 9, 13, 21, 25, 38, 47, 60 } },
		weight = 85.2
	},
	{
		name = "Seel",
		evolution = "34",
		bst = 325,
		movelvls = { { 9, 17, 21, 29, 37, 41, 49 }, { 9, 17, 21, 29, 37, 41, 49 } },
		weight = 90.0
	},
	{
		name = "Dewgong",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { { 9, 17, 21, 29, 34, 42, 51, 64 }, { 9, 17, 21, 29, 34, 42, 51, 64 } },
		weight = 120.0
	},
	{
		name = "Grimer",
		evolution = "38",
		bst = 325,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 30.0
	},
	{
		name = "Muk", -- PUMP SLOP
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 4, 8, 13, 19, 26, 34, 47, 61 }, { 4, 8, 13, 19, 26, 34, 47, 61 } },
		weight = 30.0
	},
	{
		name = "Shellder",
		evolution = PokemonData.Evolutions.WATER,
		bst = 305,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 4.0
	},
	{
		name = "Cloyster",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 33, 41 }, { 36, 43 } },
		weight = 132.5
	},
	{
		name = "Gastly",
		evolution = "25",
		bst = 310,
		movelvls = { { 8, 13, 16, 21, 28, 33, 36 }, { 8, 13, 16, 21, 28, 33, 36, 41, 48 } },
		weight = 0.1
	},
	{
		name = "Haunter",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 405,
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 0.1
	},
	{
		name = "Gengar",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 40.5
	},
	{
		name = "Onix",
		evolution = "30", -- Level 30 replaces trade evolution
		bst = 385,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 210.0
	},
	{
		name = "Drowzee",
		evolution = "26",
		bst = 328,
		movelvls = { { 10, 18, 25, 31, 36, 40, 43, 45 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 32.4
	},
	{
		name = "Hypno",
		evolution = PokemonData.Evolutions.NONE,
		bst = 483,
		movelvls = { { 10, 18, 25, 33, 40, 49, 55, 60 }, { 7, 11, 17, 21, 29, 35, 43, 49, 57 } },
		weight = 75.6
	},
	{
		name = "Krabby",
		evolution = "28",
		bst = 325,
		movelvls = { { 5, 12, 16, 23, 27, 34, 41, 45 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 6.5
	},
	{
		name = "Kingler",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { { 5, 12, 16, 23, 27, 38, 49, 57 }, { 5, 12, 16, 23, 27, 38, 42, 57, 65 } },
		weight = 60.0
	},
	{
		name = "Voltorb",
		evolution = "30",
		bst = 330,
		movelvls = { { 8, 15, 21, 27, 32, 37, 42, 46, 49 }, { 8, 15, 21, 27, 32, 37, 42, 46, 49 } },
		weight = 10.4
	},
	{
		name = "Electrode",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 8, 15, 21, 27, 34, 41, 48, 54, 59 }, { 8, 15, 21, 27, 34, 41, 48, 54, 59 } },
		weight = 66.6
	},
	{
		name = "Exeggcute",
		evolution = PokemonData.Evolutions.LEAF,
		bst = 325,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Exeggutor",
		evolution = PokemonData.Evolutions.NONE,
		bst = 520,
		movelvls = { { 19, 31 }, { 19, 31 } },
		weight = 120.0
	},
	{
		name = "Cubone",
		evolution = "28",
		bst = 320,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 6.5
	},
	{
		name = "Marowak",
		evolution = PokemonData.Evolutions.NONE,
		bst = 425,
		movelvls = { { 5, 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 }, { 5, 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 } },
		weight = 45.0
	},
	{
		name = "Hitmonlee",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 }, { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 } },
		weight = 49.8
	},
	{
		name = "Hitmonchan",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 }, { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 } },
		weight = 50.2
	},
	{
		name = "Lickitung",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 7, 12, 18, 23, 29, 34, 40, 45, 51 }, { 7, 12, 18, 23, 29, 34, 40, 45, 51 } },
		weight = 65.5
	},
	{
		name = "Koffing",
		evolution = "35",
		bst = 340,
		movelvls = { { 9, 17, 21, 25, 33, 41, 45, 49 }, { 9, 17, 21, 25, 33, 41, 45, 49 } },
		weight = 1.0
	},
	{
		name = "Weezing",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 9, 17, 21, 25, 33, 44, 51, 58 }, { 9, 17, 21, 25, 33, 44, 51, 58 } },
		weight = 9.5
	},
	{
		name = "Rhyhorn",
		evolution = "42",
		bst = 345,
		movelvls = { { 10, 15, 24, 29, 38, 43, 52, 57 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 115.0
	},
	{
		name = "Rhydon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 10, 15, 24, 29, 38, 46, 58, 66 }, { 10, 15, 24, 29, 38, 46, 58, 66 } },
		weight = 120.0
	},
	{
		name = "Chansey",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 450,
		movelvls = { { 5, 9, 13, 17, 23, 29, 35, 41, 49, 57 }, { 5, 9, 13, 17, 23, 29, 35, 41, 49, 57 } },
		weight = 34.6,
		friendshipBase = 140
	},
	{
		name = "Tangela",
		evolution = PokemonData.Evolutions.NONE,
		bst = 435,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46 } },
		weight = 35.0
	},
	{
		name = "Kangaskhan",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 80.0
	},
	{
		name = "Horsea",
		evolution = "32",
		bst = 295,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 8.0
	},
	{
		name = "Seadra",
		evolution = "40", -- Level 40 replaces trade evolution
		bst = 440,
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 25.0
	},
	{
		name = "Goldeen",
		evolution = "33",
		bst = 320,
		movelvls = { { 10, 15, 24, 29, 38, 43, 52 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 15.0
	},
	{
		name = "Seaking",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 10, 15, 24, 29, 41, 49, 61 }, { 10, 15, 24, 29, 41, 49, 61, 69 } },
		weight = 39.0
	},
	{
		name = "Staryu",
		evolution = PokemonData.Evolutions.WATER,
		bst = 340,
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 34.5
	},
	{
		name = "Starmie",
		evolution = PokemonData.Evolutions.NONE,
		bst = 520,
		movelvls = { { 33 }, { 33 } },
		weight = 80.0
	},
	{
		name = "Mr. Mime",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 5, 9, 13, 17, 21, 21, 25, 29, 33, 37, 41, 45, 49, 53 }, { 5, 8, 12, 15, 19, 19, 22, 26, 29, 33, 36, 40, 43, 47, 50 } },
		weight = 54.5
	},
	{
		name = "Scyther",
		evolution = "30", -- Level 30 replaces trade evolution
		bst = 500,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 56.0
	},
	{
		name = "Jynx",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 9, 13, 21, 25, 35, 41, 51, 57, 67 }, { 9, 13, 21, 25, 35, 41, 51, 57, 67 } },
		weight = 40.6
	},
	{
		name = "Electabuzz",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 9, 17, 25, 36, 47, 58 }, { 9, 17, 25, 36, 47, 58 } },
		weight = 30.0
	},
	{
		name = "Magmar", -- MAMGAR
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 7, 13, 19, 25, 33, 41, 49, 57 }, { 7, 13, 19, 25, 33, 41, 49, 57 } },
		weight = 44.5
	},
	{
		name = "Pinsir",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 55.0
	},
	{
		name = "Tauros",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 88.4
	},
	{
		name = "Magikarp",
		evolution = "20",
		bst = 200,
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 10.0
	},
	{
		name = "Gyarados",
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 20, 25, 30, 35, 40, 45, 50, 55 }, { 20, 25, 30, 35, 40, 45, 50, 55 } },
		weight = 235.0
	},
	{
		name = "Lapras",
		evolution = PokemonData.Evolutions.NONE,
		bst = 535,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 220.0
	},
	{
		name = "Ditto",
		evolution = PokemonData.Evolutions.NONE,
		bst = 288,
		movelvls = { {}, {} },
		weight = 4.0
	},
	{
		name = "Eevee",
		evolution = PokemonData.Evolutions.EEVEE_STONES,
		bst = 325,
		movelvls = { { 8, 16, 23, 30, 36, 42 }, { 8, 16, 23, 30, 36, 42 } },
		weight = 6.5
	},
	{
		name = "Vaporeon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 29.0
	},
	{
		name = "Jolteon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 24.5
	},
	{
		name = "Flareon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 25.0
	},
	{
		name = "Porygon",
		evolution = "30", -- Level 30 replaces trade evolution
		bst = 395,
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 36.5
	},
	{
		name = "Omanyte",
		evolution = "40",
		bst = 355,
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 7.5
	},
	{
		name = "Omastar", -- LORD HELIX
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 35.0
	},
	{
		name = "Kabuto",
		evolution = "40",
		bst = 355,
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 11.5
	},
	{
		name = "Kabutops",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 40.5
	},
	{
		name = "Aerodactyl",
		evolution = PokemonData.Evolutions.NONE,
		bst = 515,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 59.0
	},
	{
		name = "Snorlax",
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 6, 10, 15, 19, 24, 28, 28, 33, 37, 42, 46, 51 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53 } },
		weight = 460.0
	},
	{
		name = "Articuno",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 55.4,
		friendshipBase = 35
	},
	{
		name = "Zapdos",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 52.6,
		friendshipBase = 35
	},
	{
		name = "Moltres",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 60.0,
		friendshipBase = 35
	},
	{
		name = "Dratini",
		evolution = "30",
		bst = 300,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 3.3,
		friendshipBase = 35
	},
	{
		name = "Dragonair",
		evolution = "55",
		bst = 420,
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 16.5,
		friendshipBase = 35
	},
	{
		name = "Dragonite",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 8, 15, 22, 29, 38, 47, 55, 61, 75 }, { 8, 15, 22, 29, 38, 47, 55, 61, 75 } },
		weight = 210.0,
		friendshipBase = 35
	},
	{
		name = "Mewtwo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 680,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 122.0,
		friendshipBase = 0
	},
	{
		name = "Mew",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 4.0,
		friendshipBase = 100
	},
	{
		name = "Chikorita",
		evolution = "16",
		bst = 318,
		movelvls = { { 8, 12, 15, 22, 29, 36, 43, 50 }, { 8, 12, 15, 22, 29, 36, 43, 50 } },
		weight = 6.4
	},
	{
		name = "Bayleef",
		evolution = "32",
		bst = 405,
		movelvls = { { 8, 12, 15, 23, 31, 39, 47, 55 }, { 8, 12, 15, 23, 31, 39, 47, 55 } },
		weight = 15.8
	},
	{
		name = "Meganium",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 12, 15, 23, 31, 41, 51, 61 }, { 8, 12, 15, 23, 31, 41, 51, 61 } },
		weight = 100.5
	},
	{
		name = "Cyndaquil",
		evolution = "14",
		bst = 309,
		movelvls = { { 6, 12, 19, 27, 36, 46 }, { 6, 12, 19, 27, 36, 46 } },
		weight = 7.9
	},
	{
		name = "Quilava",
		evolution = "36",
		bst = 405,
		movelvls = { { 6, 12, 21, 31, 42, 54 }, { 6, 12, 21, 31, 42, 54 } },
		weight = 19.0
	},
	{
		name = "Typhlosion",
		evolution = PokemonData.Evolutions.NONE,
		bst = 534,
		movelvls = { { 6, 12, 21, 31, 45, 60 }, { 6, 12, 21, 31, 45, 60 } },
		weight = 79.5
	},
	{
		name = "Totodile",
		evolution = "18",
		bst = 314,
		movelvls = { { 7, 13, 20, 27, 35, 43, 52 }, { 7, 13, 20, 27, 35, 43, 52 } },
		weight = 9.5
	},
	{
		name = "Croconaw",
		evolution = "30",
		bst = 405,
		movelvls = { { 7, 13, 21, 28, 37, 45, 55 }, { 7, 13, 21, 28, 37, 45, 55 } },
		weight = 25.0
	},
	{
		name = "Feraligatr",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 7, 13, 21, 28, 38, 47, 58 }, { 7, 13, 21, 28, 38, 47, 58 } },
		weight = 88.8
	},
	{
		name = "Sentret",
		evolution = "15",
		bst = 215,
		movelvls = { { 4, 7, 12, 17, 24, 31, 40, 49 }, { 4, 7, 12, 17, 24, 31, 40, 49 } },
		weight = 6.0
	},
	{
		name = "Furret",
		evolution = PokemonData.Evolutions.NONE,
		bst = 415,
		movelvls = { { 4, 7, 12, 19, 28, 37, 48, 59 }, { 4, 7, 12, 19, 28, 37, 48, 59 } },
		weight = 32.5
	},
	{
		name = "Hoothoot",
		evolution = "20",
		bst = 262,
		movelvls = { { 6, 11, 16, 22, 28, 34, 48 }, { 6, 11, 16, 22, 28, 34, 48 } },
		weight = 21.2
	},
	{
		name = "Noctowl",
		evolution = PokemonData.Evolutions.NONE,
		bst = 442,
		movelvls = { { 6, 11, 16, 25, 33, 41, 57 }, { 6, 11, 16, 25, 33, 41, 57 } },
		weight = 40.8
	},
	{
		name = "Ledyba",
		evolution = "18",
		bst = 265,
		movelvls = { { 8, 15, 22, 22, 22, 29, 36, 43, 50 }, { 8, 15, 22, 22, 22, 29, 36, 43, 50 } },
		weight = 10.8
	},
	{
		name = "Ledian",
		evolution = PokemonData.Evolutions.NONE,
		bst = 390,
		movelvls = { { 8, 15, 24, 24, 24, 33, 42, 51, 60 }, { 8, 15, 24, 24, 24, 33, 42, 51, 60 } },
		weight = 35.6
	},
	{
		name = "Spinarak",
		evolution = "22",
		bst = 250,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 8.5
	},
	{
		name = "Ariados",
		evolution = PokemonData.Evolutions.NONE,
		bst = 390,
		movelvls = { { 6, 11, 17, 25, 34, 43, 53, 63 }, { 6, 11, 17, 25, 34, 43, 53, 63 } },
		weight = 33.5
	},
	{
		name = "Crobat",
		evolution = PokemonData.Evolutions.NONE,
		bst = 535,
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 75.0
	},
	{
		name = "Chinchou",
		evolution = "27",
		bst = 330,
		movelvls = { { 5, 13, 17, 25, 29, 37, 41, 49 }, { 5, 13, 17, 25, 29, 37, 41, 49 } },
		weight = 12.0
	},
	{
		name = "Lanturn",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 5, 13, 17, 25, 32, 43, 50, 61 }, { 5, 13, 17, 25, 32, 43, 50, 61 } },
		weight = 22.5
	},
	{
		name = "Pichu",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 205,
		movelvls = { { 6, 8, 11 }, { 6, 8, 11 } },
		weight = 2.0
	},
	{
		name = "Cleffa",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 218,
		movelvls = { { 4, 8, 13 }, { 4, 8, 13, 17 } },
		weight = 3.0,
		friendshipBase = 140
	},
	{
		name = "Igglybuff",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 210,
		movelvls = { { 4, 9, 14 }, { 4, 9, 14 } },
		weight = 1.0
	},
	{
		name = "Togepi",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 245,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 4, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 1.5
	},
	{
		name = "Togetic",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 4, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 3.2
	},
	{
		name = "Natu",
		evolution = "25",
		bst = 320,
		movelvls = { { 10, 20, 30, 30, 40, 50 }, { 10, 20, 30, 30, 40, 50 } },
		weight = 2.0
	},
	{
		name = "Xatu",
		evolution = PokemonData.Evolutions.NONE,
		bst = 470,
		movelvls = { { 10, 20, 35, 35, 50, 65 }, { 10, 20, 35, 35, 50, 65 } },
		weight = 15.0
	},
	{
		name = "Mareep",
		evolution = "15",
		bst = 280,
		movelvls = { { 9, 16, 23, 30, 37 }, { 9, 16, 23, 30, 37 } },
		weight = 7.8
	},
	{
		name = "Flaaffy",
		evolution = "30",
		bst = 365,
		movelvls = { { 9, 18, 27, 36, 45 }, { 9, 18, 27, 36, 45 } },
		weight = 13.3
	},
	{
		name = "Ampharos",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 9, 18, 27, 30, 42, 57 }, { 9, 18, 27, 30, 42, 57 } },
		weight = 61.5
	},
	{
		name = "Bellossom",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 44, 55 }, { 44, 55 } },
		weight = 5.8
	},
	{
		name = "Marill",
		evolution = "18",
		bst = 250,
		movelvls = { { 3, 6, 10, 15, 21, 28, 36, 45 }, { 3, 6, 10, 15, 21, 28, 36, 45 } },
		weight = 8.5
	},
	{
		name = "Azumarill",
		evolution = PokemonData.Evolutions.NONE,
		bst = 410,
		movelvls = { { 3, 6, 10, 15, 24, 34, 45, 57 }, { 3, 6, 10, 15, 24, 34, 45, 57 } },
		weight = 28.5
	},
	{
		name = "Sudowoodo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 410,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = 38.0
	},
	{
		name = "Politoed",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 33.9
	},
	{
		name = "Hoppip",
		evolution = "18",
		bst = 250,
		movelvls = { { 5, 5, 10, 13, 15, 17, 20, 25, 30 }, { 5, 5, 10, 13, 15, 17, 20, 25, 30 } },
		weight = 0.5
	},
	{
		name = "Skiploom",
		evolution = "27",
		bst = 340,
		movelvls = { { 5, 5, 10, 13, 15, 17, 22, 29, 36 }, { 5, 5, 10, 13, 15, 17, 22, 29, 36 } },
		weight = 1.0
	},
	{
		name = "Jumpluff",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 5, 5, 10, 13, 15, 17, 22, 33, 44 }, { 5, 5, 10, 13, 15, 17, 22, 33, 44 } },
		weight = 3.0
	},
	{
		name = "Aipom",
		evolution = PokemonData.Evolutions.NONE,
		bst = 360,
		movelvls = { { 6, 13, 18, 25, 31, 38, 43, 50 }, { 6, 13, 18, 25, 31, 38, 43, 50 } },
		weight = 11.5
	},
	{
		name = "Sunkern",
		evolution = PokemonData.Evolutions.SUN,
		bst = 180,
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = 1.8
	},
	{
		name = "Sunflora",
		evolution = PokemonData.Evolutions.NONE,
		bst = 425,
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = 8.5
	},
	{
		name = "Yanma",
		evolution = PokemonData.Evolutions.NONE,
		bst = 390,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 6, 12, 17, 23, 28, 34, 39, 45, 50 } },
		weight = 38.0
	},
	{
		name = "Wooper",
		evolution = "20",
		bst = 210,
		movelvls = { { 11, 16, 21, 31, 36, 41, 51, 51 }, { 11, 16, 21, 31, 36, 41, 51, 51 } },
		weight = 8.5
	},
	{
		name = "Quagsire",
		evolution = PokemonData.Evolutions.NONE,
		bst = 430,
		movelvls = { { 11, 16, 23, 35, 42, 49, 61, 61 }, { 11, 16, 23, 35, 42, 49, 61, 61 } },
		weight = 75.0
	},
	{
		name = "Espeon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 26.5
	},
	{
		name = "Umbreon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 27.0,
		friendshipBase = 35
	},
	{
		name = "Murkrow",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 9, 14, 22, 27, 35, 40, 48 }, { 9, 14, 22, 27, 35, 40, 48 } },
		weight = 2.1,
		friendshipBase = 35
	},
	{
		name = "Slowking",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 79.5
	},
	{
		name = "Misdreavus",
		evolution = PokemonData.Evolutions.NONE,
		bst = 435,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 1.0,
		friendshipBase = 35
	},
	{
		name = "Unown",
		evolution = PokemonData.Evolutions.NONE,
		bst = 336,
		movelvls = { {}, {} },
		weight = 5.0
	},
	{
		name = "Wobbuffet",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { {}, {} },
		weight = 28.5
	},
	{
		name = "Girafarig",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 41.5
	},
	{
		name = "Pineco",
		evolution = "31",
		bst = 290,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 7.2
	},
	{
		name = "Forretress",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 8, 15, 22, 29, 39, 49, 59 }, { 8, 15, 22, 29, 31, 39, 49, 59 } },
		weight = 125.8
	},
	{
		name = "Dunsparce",
		evolution = PokemonData.Evolutions.NONE,
		bst = 415,
		movelvls = { { 4, 11, 14, 21, 24, 31, 34, 41 }, { 4, 11, 14, 21, 24, 31, 34, 41, 44, 51 } },
		weight = 14.0
	},
	{
		name = "Gligar",
		evolution = PokemonData.Evolutions.NONE,
		bst = 430,
		movelvls = { { 6, 13, 20, 28, 36, 44, 52 }, { 6, 13, 20, 28, 36, 44, 52 } },
		weight = 64.8
	},
	{
		name = "Steelix",
		evolution = PokemonData.Evolutions.NONE,
		bst = 510,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 400.0
	},
	{
		name = "Snubbull",
		evolution = "23",
		bst = 300,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 7.8
	},
	{
		name = "Granbull",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 4, 8, 13, 19, 28, 38, 49, 61 }, { 4, 8, 13, 19, 28, 38, 49, 61 } },
		weight = 48.7
	},
	{
		name = "Qwilfish",
		evolution = PokemonData.Evolutions.NONE,
		bst = 430,
		movelvls = { { 10, 10, 19, 28, 37, 46 }, { 9, 9, 13, 21, 25, 33, 37, 45 } },
		weight = 3.9
	},
	{
		name = "Scizor",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 118.0
	},
	{
		name = "Shuckle",
		evolution = PokemonData.Evolutions.NONE,
		bst = 505,
		movelvls = { { 9, 14, 23, 28, 37 }, { 9, 14, 23, 28, 37 } },
		weight = 20.5
	},
	{
		name = "Heracross",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 54.0
	},
	{
		name = "Sneasel",
		evolution = PokemonData.Evolutions.NONE,
		bst = 430,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = 28.0,
		friendshipBase = 35
	},
	{
		name = "Teddiursa",
		evolution = "30",
		bst = 330,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.8
	},
	{
		name = "Ursaring",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 125.8
	},
	{
		name = "Slugma",
		evolution = "38",
		bst = 250,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 35.0
	},
	{
		name = "Magcargo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 410,
		movelvls = { { 8, 15, 22, 29, 36, 48, 60 }, { 8, 15, 22, 29, 36, 48, 60 } },
		weight = 55.0
	},
	{
		name = "Swinub",
		evolution = "33",
		bst = 250,
		movelvls = { { 10, 19, 28, 37, 46, 55 }, { 10, 19, 28, 37, 46, 55 } },
		weight = 6.5
	},
	{
		name = "Piloswine",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 10, 19, 28, 33, 42, 56, 70 }, { 10, 19, 28, 33, 42, 56, 70 } },
		weight = 55.8
	},
	{
		name = "Corsola",
		evolution = PokemonData.Evolutions.NONE,
		bst = 380,
		movelvls = { { 6, 12, 17, 17, 23, 28, 34, 39, 45 }, { 6, 12, 17, 17, 23, 28, 34, 39, 45 } },
		weight = 5.0
	},
	{
		name = "Remoraid",
		evolution = "25",
		bst = 300,
		movelvls = { { 11, 22, 22, 22, 33, 44, 55 }, { 11, 22, 22, 22, 33, 44, 55 } },
		weight = 12.0
	},
	{
		name = "Octillery",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 11, 22, 22, 22, 25, 38, 54, 70 }, { 11, 22, 22, 22, 25, 38, 54, 70 } },
		weight = 28.5
	},
	{
		name = "Delibird",
		evolution = PokemonData.Evolutions.NONE,
		bst = 330,
		movelvls = { {}, {} },
		weight = 16.0
	},
	{
		name = "Mantine",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 220.0
	},
	{
		name = "Skarmory",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 10, 13, 16, 26, 29, 32, 42, 45 }, { 10, 13, 16, 26, 29, 32, 42, 45 } },
		weight = 50.5
	},
	{
		name = "Houndour",
		evolution = "24",
		bst = 330,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 10.8,
		friendshipBase = 35
	},
	{
		name = "Houndoom",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 35.0,
		friendshipBase = 35
	},
	{
		name = "Kingdra",
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 152.0
	},
	{
		name = "Phanpy",
		evolution = "25",
		bst = 330,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 33.5
	},
	{
		name = "Donphan",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 120.0
	},
	{
		name = "Porygon2",
		evolution = PokemonData.Evolutions.NONE,
		bst = 515,
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 32.5
	},
	{
		name = "Stantler",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 71.2
	},
	{
		name = "Smeargle",
		evolution = PokemonData.Evolutions.NONE,
		bst = 250,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81, 91 }, { 11, 21, 31, 41, 51, 61, 71, 81, 91 } },
		weight = 58.0
	},
	{
		name = "Tyrogue",
		evolution = "20",
		bst = 210,
		movelvls = { {}, {} },
		weight = 21.0
	},
	{
		name = "Hitmontop",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 7, 13, 19, 20, 25, 31, 37, 43, 49 }, { 7, 13, 19, 20, 25, 31, 37, 43, 49 } },
		weight = 48.0
	},
	{
		name = "Smoochum",
		evolution = "30",
		bst = 305,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 9, 13, 21, 25, 33, 37, 45, 49, 57 } },
		weight = 6.0
	},
	{
		name = "Elekid",
		evolution = "30",
		bst = 360,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 23.5
	},
	{
		name = "Magby",
		evolution = "30",
		bst = 365,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 21.4
	},
	{
		name = "Miltank",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 75.5
	},
	{
		name = "Blissey",
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 46.8,
		friendshipBase = 140
	},
	{
		name = "Raikou",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 178.0,
		friendshipBase = 35
	},
	{
		name = "Entei",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 198.0,
		friendshipBase = 35
	},
	{
		name = "Suicune",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 187.0,
		friendshipBase = 35
	},
	{
		name = "Larvitar",
		evolution = "30",
		bst = 300,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 72.0,
		friendshipBase = 35
	},
	{
		name = "Pupitar",
		evolution = "55",
		bst = 410,
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 152.0,
		friendshipBase = 35
	},
	{
		name = "Tyranitar",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 8, 15, 22, 29, 38, 47, 61, 75 }, { 8, 15, 22, 29, 38, 47, 61, 75 } },
		weight = 202.0,
		friendshipBase = 35
	},
	{
		name = "Lugia",
		evolution = PokemonData.Evolutions.NONE,
		bst = 680,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 216.0,
		friendshipBase = 0
	},
	{
		name = "Ho-Oh",
		evolution = PokemonData.Evolutions.NONE,
		bst = 680,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 199.0,
		friendshipBase = 0
	},
	{
		name = "Celebi",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 5.0,
		friendshipBase = 100
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "Treecko",
		evolution = "16",
		bst = 310,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 5.0
	},
	{
		name = "Grovyle",
		evolution = "36",
		bst = 405,
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 }, { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 } },
		weight = 21.6
	},
	{
		name = "Sceptile",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 }, { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 } },
		weight = 52.2
	},
	{
		name = "Torchic",
		evolution = "16",
		bst = 310,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Combusken",
		evolution = "36",
		bst = 405,
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 }, { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 } },
		weight = 19.5
	},
	{
		name = "Blaziken",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 }, { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 } },
		weight = 52.0
	},
	{
		name = "Mudkip",
		evolution = "16",
		bst = 310,
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 7.6
	},
	{
		name = "Marshtomp",
		evolution = "36",
		bst = 405,
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 }, { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 } },
		weight = 28.0
	},
	{
		name = "Swampert",
		evolution = PokemonData.Evolutions.NONE,
		bst = 535,
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 }, { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 } },
		weight = 81.9
	},
	{
		name = "Poochyena",
		evolution = "18",
		bst = 220,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 13.6
	},
	{
		name = "Mightyena",
		evolution = PokemonData.Evolutions.NONE,
		bst = 420,
		movelvls = { { 5, 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 }, { 5, 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 } },
		weight = 37.0
	},
	{
		name = "Zigzagoon",
		evolution = "20",
		bst = 240,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 17.5
	},
	{
		name = "Linoone",
		evolution = PokemonData.Evolutions.NONE,
		bst = 420,
		movelvls = { { 5, 9, 13, 17, 23, 29, 35, 41, 47, 53 }, { 5, 9, 13, 17, 23, 29, 35, 41, 47, 53 } },
		weight = 32.5
	},
	{
		name = "Wurmple",
		evolution = "7",
		bst = 195,
		movelvls = { { 5 }, { 5 } },
		weight = 3.6
	},
	{
		name = "Silcoon",
		evolution = "10",
		bst = 205,
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beautifly",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = 28.4
	},
	{
		name = "Cascoon",
		evolution = "10",
		bst = 205,
		movelvls = { { 7 }, { 7 } },
		weight = 11.5
	},
	{
		name = "Dustox",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = 31.6
	},
	{
		name = "Lotad",
		evolution = "14",
		bst = 220,
		movelvls = { { 3, 7, 13, 21, 31, 43 }, { 3, 7, 13, 21, 31, 43 } },
		weight = 2.6
	},
	{
		name = "Lombre",
		evolution = PokemonData.Evolutions.WATER,
		bst = 340,
		movelvls = { { 3, 7, 13, 19, 25, 31, 37, 43, 49 }, { 3, 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 32.5
	},
	{
		name = "Ludicolo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { {}, {} },
		weight = 55.0
	},
	{
		name = "Seedot",
		evolution = "14",
		bst = 220,
		movelvls = { { 3, 7, 13, 21, 31, 43 }, { 3, 7, 13, 21, 31, 43 } },
		weight = 4.0
	},
	{
		name = "Nuzleaf",
		evolution = PokemonData.Evolutions.LEAF,
		bst = 340,
		movelvls = { { 3, 7, 13, 19, 25, 31, 37, 43, 49 }, { 3, 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 28.0
	},
	{
		name = "Shiftry",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { {}, {} },
		weight = 59.6
	},
	{
		name = "Nincada",
		evolution = "20",
		bst = 266,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45 }, { 5, 9, 14, 19, 25, 31, 38, 45 } },
		weight = 5.5
	},
	{
		name = "Ninjask",
		evolution = PokemonData.Evolutions.NONE,
		bst = 456,
		movelvls = { { 5, 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 }, { 5, 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 } },
		weight = 12.0
	},
	{
		name = "Shedinja",
		evolution = PokemonData.Evolutions.NONE,
		bst = 236,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45 }, { 5, 9, 14, 19, 25, 31, 38, 45 } },
		weight = 1.2
	},
	{
		name = "Taillow",
		evolution = "22",
		bst = 270,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43 }, { 4, 8, 13, 19, 26, 34, 43 } },
		weight = 2.3
	},
	{
		name = "Swellow",
		evolution = PokemonData.Evolutions.NONE,
		bst = 430,
		movelvls = { { 4, 8, 13, 19, 28, 38, 49 }, { 4, 8, 13, 19, 28, 38, 49 } },
		weight = 19.8
	},
	{
		name = "Shroomish",
		evolution = "23",
		bst = 295,
		movelvls = { { 4, 7, 10, 16, 22, 28, 36, 45, 54 }, { 4, 7, 10, 16, 22, 28, 36, 45, 54 } },
		weight = 4.5
	},
	{
		name = "Breloom",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 4, 7, 10, 16, 22, 23, 28, 36, 45, 54 }, { 4, 7, 10, 16, 22, 23, 28, 36, 45, 54 } },
		weight = 39.2
	},
	{
		name = "Spinda",
		evolution = PokemonData.Evolutions.NONE,
		bst = 360,
		movelvls = { { 5, 12, 16, 23, 27, 34, 38, 45, 49, 56 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49, 56 } },
		weight = 5.0
	},
	{
		name = "Wingull",
		evolution = "25",
		bst = 270,
		movelvls = { { 7, 13, 21, 31, 43, 55 }, { 7, 13, 21, 31, 43, 55 } },
		weight = 9.5
	},
	{
		name = "Pelipper",
		evolution = PokemonData.Evolutions.NONE,
		bst = 430,
		movelvls = { { 3, 7, 13, 21, 25, 33, 33, 47, 61 }, { 3, 7, 13, 21, 25, 33, 33, 47, 61 } },
		weight = 28.0
	},
	{
		name = "Surskit",
		evolution = "22",
		bst = 269,
		movelvls = { { 7, 13, 19, 25, 31, 37, 37 }, { 7, 13, 19, 25, 31, 37, 37 } },
		weight = 1.7
	},
	{
		name = "Masquerain",
		evolution = PokemonData.Evolutions.NONE,
		bst = 414,
		movelvls = { { 7, 13, 19, 26, 33, 40, 47, 53 }, { 7, 13, 19, 26, 33, 40, 47, 53 } },
		weight = 3.6
	},
	{
		name = "Wailmer",
		evolution = "40",
		bst = 400,
		movelvls = { { 5, 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 }, { 5, 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 } },
		weight = 130.0
	},
	{
		name = "Wailord", -- STONKS
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 5, 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 }, { 5, 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 } },
		weight = 398.0
	},
	{
		name = "Skitty",
		evolution = PokemonData.Evolutions.MOON,
		bst = 260,
		movelvls = { { 3, 7, 13, 15, 19, 25, 27, 31, 37, 39 }, { 3, 7, 13, 15, 19, 25, 27, 31, 37, 39 } },
		weight = 11.0
	},
	{
		name = "Delcatty",
		evolution = PokemonData.Evolutions.NONE,
		bst = 380,
		movelvls = { {}, {} },
		weight = 32.6
	},
	{
		name = "Kecleon", -- KEKLEO-N
		evolution = PokemonData.Evolutions.NONE,
		bst = 440,
		movelvls = { { 4, 7, 12, 17, 24, 31, 40, 49 }, { 4, 7, 12, 17, 24, 31, 40, 49 } },
		weight = 22.0
	},
	{
		name = "Baltoy",
		evolution = "36",
		bst = 300,
		movelvls = { { 3, 5, 7, 11, 15, 19, 25, 31, 37, 45 }, { 3, 5, 7, 11, 15, 19, 25, 31, 37, 45 } },
		weight = 21.5
	},
	{
		name = "Claydol",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 3, 5, 7, 11, 15, 19, 25, 31, 36, 42, 55 }, { 3, 5, 7, 11, 15, 19, 25, 31, 36, 42, 55 } },
		weight = 108.0
	},
	{
		name = "Nosepass",
		evolution = PokemonData.Evolutions.NONE,
		bst = 375,
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43, 46 }, { 7, 13, 16, 22, 28, 31, 37, 43, 46 } },
		weight = 97.0
	},
	{
		name = "Torkoal",
		evolution = PokemonData.Evolutions.NONE,
		bst = 470,
		movelvls = { { 4, 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 }, { 4, 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 } },
		weight = 80.4
	},
	{
		name = "Sableye",
		evolution = PokemonData.Evolutions.NONE,
		bst = 380,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 11.0,
		friendshipBase = 35
	},
	{
		name = "Barboach",
		evolution = "30",
		bst = 288,
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 }, { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 } },
		weight = 1.9
	},
	{
		name = "Whiscash",
		evolution = PokemonData.Evolutions.NONE,
		bst = 468,
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 }, { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 } },
		weight = 23.6
	},
	{
		name = "Luvdisc",
		evolution = PokemonData.Evolutions.NONE,
		bst = 330,
		movelvls = { { 4, 12, 16, 24, 28, 36, 40, 48 }, { 4, 12, 16, 24, 28, 36, 40, 48 } },
		weight = 8.7
	},
	{
		name = "Corphish",
		evolution = "30",
		bst = 308,
		movelvls = { { 7, 10, 13, 20, 23, 26, 32, 35, 38, 44 }, { 7, 10, 13, 19, 22, 25, 31, 34, 37, 43, 46 } },
		weight = 11.5
	},
	{
		name = "Crawdaunt", -- FRAUD
		evolution = PokemonData.Evolutions.NONE,
		bst = 468,
		movelvls = { { 7, 10, 13, 20, 23, 26, 34, 39, 44, 52 }, { 7, 10, 13, 19, 22, 25, 33, 38, 43, 51, 56 } },
		weight = 32.8
	},
	{
		name = "Feebas",
		evolution = "35", -- Level 35 replaces beauty condition
		bst = 200,
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 7.4
	},
	{
		name = "Milotic", -- THICC
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 162.0
	},
	{
		name = "Carvanha",
		evolution = "30",
		bst = 305,
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43 }, { 7, 13, 16, 22, 28, 31, 37, 43 } },
		weight = 20.8,
		friendshipBase = 35
	},
	{
		name = "Sharpedo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 }, { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 } },
		weight = 88.8,
		friendshipBase = 35
	},
	{
		name = "Trapinch",
		evolution = "35",
		bst = 290,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = 15.0
	},
	{
		name = "Vibrava",
		evolution = "45",
		bst = 340,
		movelvls = { { 9, 17, 25, 33, 35, 41, 49, 57 }, { 9, 17, 25, 33, 35, 41, 49, 57 } },
		weight = 15.3
	},
	{
		name = "Flygon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 520,
		movelvls = { { 9, 17, 25, 33, 35, 41, 53, 65 }, { 9, 17, 25, 33, 35, 41, 53, 65 } },
		weight = 82.0
	},
	{
		name = "Makuhita",
		evolution = "24",
		bst = 237,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 } },
		weight = 86.4
	},
	{
		name = "Hariyama",
		evolution = PokemonData.Evolutions.NONE,
		bst = 474,
		movelvls = { { 4, 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 }, { 4, 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 } },
		weight = 253.8
	},
	{
		name = "Electrike",
		evolution = "26",
		bst = 295,
		movelvls = { { 4, 9, 12, 17, 20, 25, 28, 33, 36, 41 }, { 4, 9, 12, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 15.2
	},
	{
		name = "Manectric",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { { 4, 9, 12, 17, 20, 25, 31, 39, 45, 53 }, { 4, 9, 12, 17, 20, 25, 31, 39, 45, 53 } },
		weight = 40.2
	},
	{
		name = "Numel",
		evolution = "33",
		bst = 305,
		movelvls = { { 11, 19, 25, 29, 31, 35, 41, 49 }, { 11, 19, 25, 29, 31, 35, 41, 49 } },
		weight = 24.0
	},
	{
		name = "Camerupt",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 11, 19, 25, 29, 31, 33, 37, 45, 55 }, { 11, 19, 25, 29, 31, 33, 37, 45, 55 } },
		weight = 220.0
	},
	{
		name = "Spheal",
		evolution = "32",
		bst = 290,
		movelvls = { { 7, 13, 19, 25, 31, 37, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 37, 43, 49 } },
		weight = 39.5
	},
	{
		name = "Sealeo",
		evolution = "44",
		bst = 410,
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 47, 55 }, { 7, 13, 19, 25, 31, 39, 39, 47, 55 } },
		weight = 87.6
	},
	{
		name = "Walrein",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 50, 61 }, { 7, 13, 19, 25, 31, 39, 39, 50, 61 } },
		weight = 150.6
	},
	{
		name = "Cacnea",
		evolution = "32",
		bst = 335,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 } },
		weight = 51.3,
		friendshipBase = 35
	},
	{
		name = "Cacturne",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 35, 41, 47, 53 }, { 5, 9, 13, 17, 21, 25, 29, 35, 41, 47, 53, 59 } },
		weight = 77.4,
		friendshipBase = 35
	},
	{
		name = "Snorunt",
		evolution = "42",
		bst = 300,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 16.8
	},
	{
		name = "Glalie",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 }, { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 } },
		weight = 256.5
	},
	{
		name = "Lunatone",
		evolution = PokemonData.Evolutions.NONE,
		bst = 440,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 168.0
	},
	{
		name = "Solrock",
		evolution = PokemonData.Evolutions.NONE,
		bst = 440,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 154.0
	},
	{
		name = "Azurill",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 190,
		movelvls = { { 3, 6, 10, 15, 21 }, { 3, 6, 10, 15, 21 } },
		weight = 2.0
	},
	{
		name = "Spoink",
		evolution = "32",
		bst = 330,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 } },
		weight = 30.6
	},
	{
		name = "Grumpig",
		evolution = PokemonData.Evolutions.NONE,
		bst = 470,
		movelvls = { { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 }, { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 } },
		weight = 71.5
	},
	{
		name = "Plusle",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = 4.2
	},
	{
		name = "Minun",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = 4.2
	},
	{
		name = "Mawile",
		evolution = PokemonData.Evolutions.NONE,
		bst = 380,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 } },
		weight = 11.5
	},
	{
		name = "Meditite",
		evolution = "37",
		bst = 280,
		movelvls = { { 4, 9, 12, 18, 22, 28, 32, 38, 42, 48 }, { 4, 9, 12, 17, 20, 25, 28, 33, 36, 41, 44 } },
		weight = 11.2
	},
	{
		name = "Medicham",
		evolution = PokemonData.Evolutions.NONE,
		bst = 410,
		movelvls = { { 4, 9, 12, 18, 22, 28, 32, 40, 46, 54 }, { 4, 9, 12, 17, 20, 25, 28, 33, 36, 47, 56 } },
		weight = 31.5
	},
	{
		name = "Swablu",
		evolution = "35",
		bst = 310,
		movelvls = { { 8, 11, 18, 21, 28, 31, 38, 41, 48 }, { 8, 11, 18, 21, 28, 31, 38, 41, 48 } },
		weight = 1.2
	},
	{
		name = "Altaria",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 }, { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 } },
		weight = 20.6
	},
	{
		name = "Wynaut",
		evolution = "15",
		bst = 260,
		movelvls = { { 15, 15, 15, 15 }, { 15, 15, 15, 15 } },
		weight = 14.0
	},
	{
		name = "Duskull",
		evolution = "37",
		bst = 295,
		movelvls = { { 5, 12, 16, 23, 27, 34, 38, 45, 49 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 15.0,
		friendshipBase = 35
	},
	{
		name = "Dusclops",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 5, 12, 16, 23, 27, 34, 37, 41, 51, 58 }, { 5, 12, 16, 23, 27, 34, 37, 41, 51, 58 } },
		weight = 30.6,
		friendshipBase = 35
	},
	{
		name = "Roselia",
		evolution = PokemonData.Evolutions.NONE,
		bst = 400,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 } },
		weight = 2.0
	},
	{
		name = "Slakoth",
		evolution = "18",
		bst = 280,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 24.0
	},
	{
		name = "Vigoroth",
		evolution = "36",
		bst = 440,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 46.5
	},
	{
		name = "Slaking",
		evolution = PokemonData.Evolutions.NONE,
		bst = 670,
		movelvls = { { 7, 13, 19, 25, 31, 36, 37, 43 }, { 7, 13, 19, 25, 31, 36, 37, 43 } },
		weight = 130.5
	},
	{
		name = "Gulpin",
		evolution = "26",
		bst = 302,
		movelvls = { { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 }, { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 } },
		weight = 10.3
	},
	{
		name = "Swalot",
		evolution = PokemonData.Evolutions.NONE,
		bst = 467,
		movelvls = { { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 }, { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 } },
		weight = 80.0
	},
	{
		name = "Tropius",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 7, 11, 17, 21, 27, 31, 37, 41, 47 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 100.0
	},
	{
		name = "Whismur",
		evolution = "20",
		bst = 240,
		movelvls = { { 5, 11, 15, 21, 25, 31, 35, 41, 41, 45 }, { 5, 11, 15, 21, 25, 31, 35, 41, 41, 45 } },
		weight = 16.3
	},
	{
		name = "Loudred",
		evolution = "40",
		bst = 360,
		movelvls = { { 5, 11, 15, 23, 29, 37, 43, 51, 51, 57 }, { 5, 11, 15, 23, 29, 37, 43, 51, 51, 57 } },
		weight = 40.5
	},
	{
		name = "Exploud",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 5, 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 }, { 5, 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 } },
		weight = 84.0
	},
	{
		name = "Clamperl",
		evolution = PokemonData.Evolutions.WATER30, -- Level 30 and stone replace trade evolution
		bst = 345,
		movelvls = { {}, {} },
		weight = 52.5
	},
	{
		name = "Huntail",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 27.0
	},
	{
		name = "Gorebyss",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 22.6
	},
	{
		name = "Absol",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 5, 9, 13, 17, 21, 26, 31, 36, 41, 46 }, { 5, 9, 13, 17, 21, 26, 31, 36, 41, 46 } },
		weight = 47.0,
		friendshipBase = 35
	},
	{
		name = "Shuppet",
		evolution = "37",
		bst = 295,
		movelvls = { { 8, 13, 20, 25, 32, 37, 44, 49, 56 }, { 8, 13, 20, 25, 32, 37, 44, 49, 56 } },
		weight = 2.3,
		friendshipBase = 35
	},
	{
		name = "Banette",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 8, 13, 20, 25, 32, 39, 48, 55, 64 }, { 8, 13, 20, 25, 32, 39, 48, 55, 64 } },
		weight = 12.5,
		friendshipBase = 35
	},
	{
		name = "Seviper",
		evolution = PokemonData.Evolutions.NONE,
		bst = 458,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 52.5
	},
	{
		name = "Zangoose",
		evolution = PokemonData.Evolutions.NONE,
		bst = 458,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 37, 46, 55 }, { 4, 7, 10, 13, 19, 25, 31, 37, 46, 55 } },
		weight = 40.3
	},
	{
		name = "Relicanth",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = 23.4
	},
	{
		name = "Aron",
		evolution = "32",
		bst = 330,
		movelvls = { { 4, 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 }, { 4, 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 } },
		weight = 60.0,
		friendshipBase = 35
	},
	{
		name = "Lairon",
		evolution = "42",
		bst = 430,
		movelvls = { { 4, 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 }, { 4, 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 } },
		weight = 120.0,
		friendshipBase = 35
	},
	{
		name = "Aggron",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 4, 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 }, { 4, 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 } },
		weight = 360.0,
		friendshipBase = 35
	},
	{
		name = "Castform",
		evolution = PokemonData.Evolutions.NONE,
		bst = 420,
		movelvls = { { 10, 10, 10, 20, 20, 20, 30 }, { 10, 10, 10, 20, 20, 20, 30 } },
		weight = 0.8
	},
	{
		name = "Volbeat",
		evolution = PokemonData.Evolutions.NONE,
		bst = 400,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = 17.7
	},
	{
		name = "Illumise",
		evolution = PokemonData.Evolutions.NONE,
		bst = 400,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = 17.7
	},
	{
		name = "Lileep",
		evolution = "40",
		bst = 355,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 50, 50 }, { 8, 15, 22, 29, 36, 43, 50, 50, 50 } },
		weight = 23.8
	},
	{
		name = "Cradily",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 8, 15, 22, 29, 36, 48, 60, 60, 60 }, { 8, 15, 22, 29, 36, 48, 60, 60, 60 } },
		weight = 60.4
	},
	{
		name = "Anorith",
		evolution = "40",
		bst = 355,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 12.5
	},
	{
		name = "Armaldo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 7, 13, 19, 25, 31, 37, 46, 55, 64 }, { 7, 13, 19, 25, 31, 37, 46, 55, 64 } },
		weight = 68.2
	},
	{
		name = "Ralts",
		evolution = "20",
		bst = 198,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 6.6,
		friendshipBase = 35
	},
	{
		name = "Kirlia",
		evolution = "30",
		bst = 278,
		movelvls = { { 6, 11, 16, 21, 26, 33, 40, 47, 54 }, { 6, 11, 16, 21, 26, 33, 40, 47, 54 } },
		weight = 20.2,
		friendshipBase = 35
	},
	{
		name = "Gardevoir",
		evolution = PokemonData.Evolutions.NONE,
		bst = 518,
		movelvls = { { 6, 11, 16, 21, 26, 33, 42, 51, 60 }, { 6, 11, 16, 21, 26, 33, 42, 51, 60 } },
		weight = 48.4,
		friendshipBase = 35
	},
	{
		name = "Bagon",
		evolution = "30",
		bst = 300,
		movelvls = { { 5, 9, 17, 21, 25, 33, 37, 41, 49, 53 }, { 5, 9, 17, 21, 25, 33, 37, 41, 49, 53 } },
		weight = 42.1,
		friendshipBase = 35
	},
	{
		name = "Shelgon",
		evolution = "50",
		bst = 420,
		movelvls = { { 5, 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 }, { 5, 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 } },
		weight = 110.5,
		friendshipBase = 35
	},
	{
		name = "Salamence",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 5, 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 }, { 5, 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 } },
		weight = 102.6,
		friendshipBase = 35
	},
	{
		name = "Beldum",
		evolution = "20",
		bst = 300,
		movelvls = { {}, {} },
		weight = 95.2,
		friendshipBase = 35
	},
	{
		name = "Metang",
		evolution = "45",
		bst = 420,
		movelvls = { { 20, 20, 26, 32, 38, 44, 50, 56, 62 }, { 20, 20, 26, 32, 38, 44, 50, 56, 62 } },
		weight = 202.5,
		friendshipBase = 35
	},
	{
		name = "Metagross",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 20, 20, 26, 32, 38, 44, 55, 66, 77 }, { 20, 20, 26, 32, 38, 44, 55, 66, 77 } },
		weight = 550.0,
		friendshipBase = 35
	},
	{
		name = "Regirock",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = 230.0,
		friendshipBase = 35
	},
	{
		name = "Regice",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = 175.0,
		friendshipBase = 35
	},
	{
		name = "Registeel",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 9, 17, 25, 33, 41, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 41, 49, 57, 65 } },
		weight = 205.0,
		friendshipBase = 35
	},
	{
		name = "Kyogre",
		evolution = PokemonData.Evolutions.NONE,
		bst = 670,
		movelvls = { { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 352.0,
		friendshipBase = 0
	},
	{
		name = "Groudon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 670,
		movelvls = { { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 950.0,
		friendshipBase = 0
	},
	{
		name = "Rayquaza",
		evolution = PokemonData.Evolutions.NONE,
		bst = 680,
		movelvls = { { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 206.5,
		friendshipBase = 0
	},
	{
		name = "Latias",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 40.0,
		friendshipBase = 90
	},
	{
		name = "Latios",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 60.0,
		friendshipBase = 90
	},
	{
		name = "Jirachi",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 1.1,
		friendshipBase = 100
	},
	{
		name = "Deoxys",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 60.8,
		friendshipBase = 0
	},
	{
		name = "Chimecho",
		evolution = PokemonData.Evolutions.NONE,
		bst = 425,
		movelvls = { { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 }, { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 } },
		weight = 1.0
	},
}

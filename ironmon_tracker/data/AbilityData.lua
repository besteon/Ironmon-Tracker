AbilityData = {}

AbilityData.Values = {
	CacophonyId = 76,
}

function AbilityData.initialize()
	AbilityData.buildData()
end

function AbilityData.updateResources()
	for i, val in ipairs(AbilityData.Abilities) do
		if Resources.Game.AbilityNames[i] then
			val.name = Resources.Game.AbilityNames[i]
		end

		local descTable = Resources.Game.AbilityDescriptions[i] or {}
		if descTable.Description then
			val.description = descTable.Description
		end
		if descTable.DescriptionEmerald then
			val.descriptionEmerald = descTable.DescriptionEmerald
		end
	end
end

---Currently unused; builds the AbilityData from game memory.
---@param forced boolean? Optional, forces the data to be read in from the game
function AbilityData.buildData(forced)
	-- if not forced or someNonExistentCondition then -- Currently Unused/unneeded
	-- 	return
	-- end

	-- Not currently necessary, as this data doesn't really change.
end

---Returns true if the abilityId is a valid, existing id of an ability in AbilityData.Abilities
---@param abilityId number
---@return boolean
function AbilityData.isValid(abilityId)
	return abilityId ~= nil and abilityId >= 1 and abilityId <= #AbilityData.Abilities
end

function AbilityData.populateAbilityDropdown(abilityList)
	for _, ability in ipairs(AbilityData.Abilities) do
		if ability.id ~= AbilityData.Values.CacophonyId then
			table.insert(abilityList, ability.name)
		end
	end
	return abilityList
end

AbilityData.DefaultAbility = {
	id = 0,
	name = "Ability Info",
	description = "Click the magnifying glass to look up an ability!",
}

-- This list and each name are now populated by its respective language Resource file (e.g. English.lua)
AbilityData.Abilities = {
	{
		id = 1,
		name = "Stench",
	},
	{
		id = 2,
		name = "Drizzle",
	},
	{
		id = 3,
		name = "Speed Boost",
	},
	{
		id = 4,
		name = "Battle Armor",
	},
	{
		id = 5,
		name = "Sturdy",
	},
	{
		id = 6,
		name = "Damp",
	},
	{
		id = 7,
		name = "Limber",
	},
	{
		id = 8,
		name = "Sand Veil",
	},
	{
		id = 9,
		name = "Static",
	},
	{
		id = 10,
		name = "Volt Absorb",
	},
	{
		id = 11,
		name = "Water Absorb",
	},
	{
		id = 12,
		name = "Oblivious",
	},
	{
		id = 13,
		name = "Cloud Nine",
	},
	{
		id = 14,
		name = "Compoundeyes",
	},
	{
		id = 15,
		name = "Insomnia",
	},
	{
		id = 16,
		name = "Color Change",
	},
	{
		id = 17,
		name = "Immunity",
	},
	{
		id = 18,
		name = "Flash Fire",
	},
	{
		id = 19,
		name = "Shield Dust",
	},
	{
		id = 20,
		name = "Own Tempo",
	},
	{
		id = 21,
		name = "Suction Cups",
	},
	{
		id = 22,
		name = "Intimidate",
	},
	{
		id = 23,
		name = "Shadow Tag",
	},
	{
		id = 24,
		name = "Rough Skin",
	},
	{
		id = 25,
		name = "Wonder Guard",
	},
	{
		id = 26,
		name = "Levitate",
	},
	{
		id = 27,
		name = "Effect Spore",
	},
	{
		id = 28,
		name = "Synchronize",
	},
	{
		id = 29,
		name = "Clear Body",
	},
	{
		id = 30,
		name = "Natural Cure",
	},
	{
		id = 31,
		name = "Lightningrod",
	},
	{
		id = 32,
		name = "Serene Grace",
	},
	{
		id = 33,
		name = "Swift Swim",
	},
	{
		id = 34,
		name = "Chlorophyll",
	},
	{
		id = 35,
		name = "Illuminate",
	},
	{
		id = 36,
		name = "Trace",
	},
	{
		id = 37,
		name = "Huge Power",
	},
	{
		id = 38,
		name = "Poison Point",
	},
	{
		id = 39,
		name = "Inner Focus",
	},
	{
		id = 40,
		name = "Magma Armor",
	},
	{
		id = 41,
		name = "Water Veil",
	},
	{
		id = 42,
		name = "Magnet Pull",
	},
	{
		id = 43,
		name = "Soundproof",
	},
	{
		id = 44,
		name = "Rain Dish",
	},
	{
		id = 45,
		name = "Sand Stream",
	},
	{
		id = 46,
		name = "Pressure",
	},
	{
		id = 47,
		name = "Thick Fat",
	},
	{
		id = 48,
		name = "Early Bird",
	},
	{
		id = 49,
		name = "Flame Body",
	},
	{
		id = 50,
		name = "Run Away",
	},
	{
		id = 51,
		name = "Keen Eye",
	},
	{
		id = 52,
		name = "Hyper Cutter",
	},
	{
		id = 53,
		name = "Pickup",

	},
	{
		id = 54,
		name = "Truant",
	},
	{
		id = 55,
		name = "Hustle",
	},
	{
		id = 56,
		name = "Cute Charm",
	},
	{
		id = 57,
		name = "Plus",
	},
	{
		id = 58,
		name = "Minus",
	},
	{
		id = 59,
		name = "Forecast",
	},
	{
		id = 60,
		name = "Sticky Hold",
	},
	{
		id = 61,
		name = "Shed Skin",
	},
	{
		id = 62,
		name = "Guts",
	},
	{
		id = 63,
		name = "Marvel Scale",
	},
	{
		id = 64,
		name = "Liquid Ooze",
	},
	{
		id = 65,
		name = "Overgrow",
	},
	{
		id = 66,
		name = "Blaze",
	},
	{
		id = 67,
		name = "Torrent",
	},
	{
		id = 68,
		name = "Swarm",
	},
	{
		id = 69,
		name = "Rock Head",
	},
	{
		id = 70,
		name = "Drought",
	},
	{
		id = 71,
		name = "Arena Trap",
	},
	{
		id = 72,
		name = "Vital Spirit",
	},
	{
		id = 73,
		name = "White Smoke",
	},
	{
		id = 74,
		name = "Pure Power",
	},
	{
		id = 75,
		name = "Shell Armor",
	},
	{
		id = 76,
		name = "Cacophony", -- Unused in game but still takes this slot
	},
	{
		id = 77,
		name =	"Air Lock",
	},
}
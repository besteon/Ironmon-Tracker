AbilityData = {}

function AbilityData.updateResources()
	for i, val in ipairs(AbilityData.Abilities) do
		if Resources.Game.AbilityNames[i] then
			val.name = Resources.Game.AbilityNames[i]
		end

		local descData = Resources.Game.AbilityDescriptions[i] or {}
		if descData.description then
			val.description = descData.description
		end
		if descData.descriptionEmerald then
			val.descriptionEmerald = descData.descriptionEmerald
		end
	end
end

function AbilityData.isValid(abilityId)
	return abilityId ~= nil and abilityId >= 1 and abilityId <= #AbilityData.Abilities -- and abilityId ~= 76 -- Allow Cacophony to be looked up
end

function AbilityData.populateAbilityDropdown(abilityList)
	for _, ability in ipairs(AbilityData.Abilities) do
		if ability.id ~= 76 then -- Skip Cacophony
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

AbilityData.Abilities = {
	{
		id = 1,
		name = "Stench",
		description = "While at the head of the party, decreases the wild encounter rate by 50%.",
		descriptionEmerald = "In the Battle Pyramid, the wild encounter rate is only decreased by 25%.",
	},
	{
		id = 2,
		name = "Drizzle",
		description = "Changes weather to rain when switched in. In rain, Water moves have 50% increased power and Fire moves have 50% decreased power. Thunder will always hit, Solarbeam deals 50% reduced damage, and Moonlight, Synthesis, and Morning Sun heal for 1/4 max HP",
	},
	{
		id = 3,
		name = "Speed Boost",
		description = "At the end of each turn, raises Speed stat by one stage.",
	},
	{
		id = 4,
		name = "Battle Armor",
		description = "Prevents this " .. Constants.Words.POKEMON .. " from receiving critical hits.",
	},
	{
		id = 5,
		name = "Sturdy",
		description = "Cannot be hit by one-hit KO moves (Fissure, Horn Drill, Guillotine, Sheer Cold).",
	},
	{
		id = 6,
		name = "Damp",
		description = "Prevents allied and opposing " .. Constants.Words.POKEMON .. " from using self-destructing moves (Self-Destruct, Explosion).",
	},
	{
		id = 7,
		name = "Limber",
		description = "Cannot be paralyzed. Gaining this Ability, like through Skill Swap, will cure Paralysis.",
	},
	{
		id = 8,
		name = "Sand Veil",
		description = "Increases Evasion by 20% in a sandstorm, and this " .. Constants.Words.POKEMON .. " takes no end of turn damage in a sandstorm.",
		descriptionEmerald = "While at the head of the party, decreases the wild encounter rate by 50% in a sandstorm.",
	},
	{
		id = 9,
		name = "Static",
		description = "When hit by a contact move, 1/3 chance to paralyze the attacker.",
		descriptionEmerald = "While at the head of the party, wild encounters have a 50% chance of being against an Electric " .. Constants.Words.POKEMON .. ", if possible.",
	},
	{
		id = 10,
		name = "Volt Absorb",
		description = "Restores 25% max HP instead of taking damage if hit by a damaging Electric move.",
	},
	{
		id = 11,
		name = "Water Absorb",
		description = "Restores 25% max HP instead of taking damage if hit by a damaging Water move.",
	},
	{
		id = 12,
		name = "Oblivious",
		description = "Cannot be infatuated. Gaining this Ability, like through Skill Swap, will cure infatuation.",
	},
	{
		id = 13,
		name = "Cloud Nine",
		description = "Negates all effects of weather, but does not end the weather.",
	},
	{
		id = 14,
		name = "Compoundeyes",
		description = "Increases the Accuracy of moves by 30% (i.e. Thunder has an Accuracy of 70%. With this ability, it would instead have 70% x 1.3 = 91% Accuracy).",
		descriptionEmerald = "Increases the chance of finding a wild " .. Constants.Words.POKEMON .. " holding an item.",
	},
	{
		id = 15,
		name = "Insomnia",
		description = "Cannot be put to sleep. If this " .. Constants.Words.POKEMON .. " uses Rest, it will fail. Gaining this Ability, like through Skill Swap, will cure Sleep.",
	},
	{
		id = 16,
		name = "Color Change",
		description = "When hit by a damaging move, changes this " .. Constants.Words.POKEMON .. "'s type to match the move's type.",
	},
	{
		id = 17,
		name = "Immunity",
		description = "Cannot be inflicted with Poison. Gaining this Ability, like through Skill Swap, will cure Poison.",
	},
	{
		id = 18,
		name = "Flash Fire",
		description = "Immune to Fire moves. The first time this " .. Constants.Words.POKEMON .. " is hit by a Fire move, its own Fire moves gain 50% power.",
	},
	{
		id = 19,
		name = "Shield Dust",
		description = "Unaffected by secondary effects of damaging moves.",
	},
	{
		id = 20,
		name = "Own Tempo",
		description = "Cannot be confused. Gaining this Ability, like through Skill Swap, will cure confusion.",
	},
	{
		id = 21,
		name = "Suction Cups",
		description = "Prevents this " .. Constants.Words.POKEMON .. " from being forced to switch out.",
		descriptionEmerald = "Increases the chance of getting bites while fishing.",
	},
	{
		id = 22,
		name = "Intimidate",
		description = "Lowers all opposing " .. Constants.Words.POKEMON ..	"s' Attack stats by one stage when this " .. Constants.Words.POKEMON .. " enters battle.",
		descriptionEmerald = "While at the head of the party, 50% chance to prevent a wild encounter that would have been with a " .. Constants.Words.POKEMON .. " 5 or more levels lower than this " .. Constants.Words.POKEMON .. ".",
	},
	{
		id = 23,
		name = "Shadow Tag",
		description = "Prevents opposing " .. Constants.Words.POKEMON .. " from switching out or fleeing.",
	},
	{
		id = 24,
		name = "Rough Skin",
		description = "When hit by a contact move, the attacker takes 1/16 of their max HP as damage.",
	},
	{
		id = 25,
		name = "Wonder Guard",
		description = "Immune to all damaging moves that are not super effective, except for Struggle, Beat Up, Future Sight, and Doom Desire. Cannot be copied by Role Play or swapped by Skill Swap.",
	},
	{
		id = 26,
		name = "Levitate",
		description = "Immune to Ground moves. This immunity is lost if this " .. Constants.Words.POKEMON .. " uses Ingrain.",
	},
	{
		id = 27,
		name = "Effect Spore",
		description = "When hit by a contact move, 10% chance for the attacker to become afflicted with Poison, Paralysis, or Sleep; with an equal chance of each. It's possible the random status won't affect the attacker, in the case that it is immune to that status.",
	},
	{
		id = 28,
		name = "Synchronize",
		description = "When a " .. Constants.Words.POKEMON .. " inflicts Poison, Paralysis, or Burn on this " .. Constants.Words.POKEMON .. ", that " .. Constants.Words.POKEMON .. " will be inflicted with the same status condition, if possible.",
		descriptionEmerald = "While at the head of the party, there is a 50% chance that a wild encounter " .. Constants.Words.POKEMON .. " will have the same nature as this " .. Constants.Words.POKEMON .. ".",
	},
	{
		id = 29,
		name = "Clear Body",
		description = "Prevents stat reductions caused by opposing " .. Constants.Words.POKEMON .. "s' moves and abilities.",
	},
	{
		id = 30,
		name = "Natural Cure",
		description = "Heals any status conditions on switching out.",
	},
	{
		id = 31,
		name = "Lightningrod",
		description = "All single-target Electric moves used by opposing " .. Constants.Words.POKEMON .. " are redirected to this " .. Constants.Words.POKEMON .. ".",
		descriptionEmerald = "While at the head of the party, Trainers registered with the " .. Constants.Words.POKE .. "Nav's Match Call feature will call twice as often.",
	},
	{
		id = 32,
		name = "Serene Grace",
		description = "Doubles the chance of secondary effects from this " .. Constants.Words.POKEMON .. "'s moves.",
	},
	{
		id = 33,
		name = "Swift Swim",
		description = "Doubles Speed stat during rain.",
	},
	{
		id = 34,
		name = "Chlorophyll",
		description = "Doubles Speed stat when the weather is sunny.",
	},
	{
		id = 35,
		name = "Illuminate",
		description = "Increases the wild encounter rate by 100%.",
	},
	{
		id = 36,
		name = "Trace",
		description = "Copies a random opposing " .. Constants.Words.POKEMON .. "'s Ability when this " .. Constants.Words.POKEMON .. " enters battle.",
	},
	{
		id = 37,
		name = "Huge Power",
		description = "Doubles this " .. Constants.Words.POKEMON .. "'s Attack stat.",
	},
	{
		id = 38,
		name = "Poison Point",
		description = "When hit by a contact move, 1/3 chance to inflict Poison on the attacker.",
	},
	{
		id = 39,
		name = "Inner Focus",
		description = "Prevents flinching.",
	},
	{
		id = 40,
		name = "Magma Armor",
		description = "Cannot be frozen. Gaining this Ability, like through Skill Swap, will cure Freeze.",
		descriptionEmerald = "Decreases the time needed to hatch an Egg by half."
	},
	{
		id = 41,
		name = "Water Veil",
		description = "Cannot be burned. Gaining this Ability, like through Skill Swap, will cure a Burn.",
	},
	{
		id = 42,
		name = "Magnet Pull",
		description = "Prevents allied and opposing Steel " .. Constants.Words.POKEMON .. " from switching out.",
		descriptionEmerald = "While at the head of the party, wild encounters have a 50% chance of being against a Steel " .. Constants.Words.POKEMON ..	", if possible.",
	},
	{
		id = 43,
		name = "Soundproof",
		description = "Immune to sound-based moves. These moves are:\nGrassWhistle, Growl, Heal Bell, Hyper Voice, Metal Sound, Perish Song, Roar, Screech, Sing, Snore, Supersonic, Uproar",
	},
	{
		id = 44,
		name = "Rain Dish",
		description = "Heals this " .. Constants.Words.POKEMON .. " for 1/16 max HP after each turn during rain.",
	},
	{
		id = 45,
		name = "Sand Stream",
		description = "Changes weather to a sandstorm when switched in. After each turn during a sandstorm, each " .. Constants.Words.POKEMON .. " takes 1/16 max HP damage, unless they are Rock, Ground, or Steel.",
	},
	{
		id = 46,
		name = "Pressure",
		description = "When a moves targets this " .. Constants.Words.POKEMON .. ", one additional PP is deducted. A " .. Constants.Words.POKEMON .. " can still target this " .. Constants.Words.POKEMON .. " with a move if it only has 1 PP remaining for it.",
		descriptionEmerald = "While at the head of the party, 50% chance that a wild encounter " .. Constants.Words.POKEMON .. " will be the highest level it could appear."
	},
	{
		id = 47,
		name = "Thick Fat",
		description = "Damage received from Ice or Fire moves is halved.",
	},
	{
		id = 48,
		name = "Early Bird",
		description = "Spends half as many turns asleep, rounded down.",
	},
	{
		id = 49,
		name = "Flame Body",
		description = "When hit by a contact move, 1/3 chance to burn the attacker.",
		descriptionEmerald = "Decreases the time needed to hatch an Egg by half."
	},
	{
		id = 50,
		name = "Run Away",
		description = "Running away from wild encounters always succeeds.",
	},
	{
		id = 51,
		name = "Keen Eye",
		description = "This " .. Constants.Words.POKEMON .. "'s Accuracy cannot be lowered.",
		descriptionEmerald = "While at the head of the party, 50% chance to prevent a wild encounter that would have been with a " .. Constants.Words.POKEMON .. " 5 or more levels lower than this " .. Constants.Words.POKEMON .. ".",
	},
	{
		id = 52,
		name = "Hyper Cutter",
		description = "This " .. Constants.Words.POKEMON .. "'s Attack stat cannot be lowered by other " .. Constants.Words.POKEMON .. ".",
		descriptionEmerald = "If this " .. Constants.Words.POKEMON .. " uses Cut in the overworld, the radius of the Cut tall grass is increased by one.",
	},
	{
		id = 53,
		name = "Pickup",
		description = "After winning a battle, there is a 10% chance that this " .. Constants.Words.POKEMON .. " will be holding an item, if it was not already holding one.",
		descriptionEmerald = "The types of items obtained vary according to this " .. Constants.Words.POKEMON .. "'s level, or the current level of the Battle Pyramid.",

	},
	{
		id = 54,
		name = "Truant",
		description = "Every other turn using a move in battle, this " .. Constants.Words.POKEMON .. " instead loafs around and does nothing.",
	},
	{
		id = 55,
		name = "Hustle",
		description = "Increases Attack stat by 50%, but decreases the Accuracy of physical moves by 20%.",
		descriptionEmerald = "While at the head of the party, 50% chance that a wild encounter " .. Constants.Words.POKEMON .. " will be the highest level it could appear."
	},
	{
		id = 56,
		name = "Cute Charm",
		description = "When hit by a contact move, 1/3 chance to inflict infatuation on the attacker. Has no effect if this " .. Constants.Words.POKEMON .. " is genderless, or the same gender as the attacker.",
		descriptionEmerald = "While at the head of the party, 2/3 chance that a wild encounter will be forced to the opposite gender of this " .. Constants.Words.POKEMON .. ", if possible."
	},
	{
		id = 57,
		name = "Plus",
		description = "When in a Double Battle where another allied " .. Constants.Words.POKEMON .. " has the Ability Minus, this " .. Constants.Words.POKEMON .. "'s Special Attack stat increases by 50%.",
	},
	{
		id = 58,
		name = "Minus",
		description = "When in a Double Battle where another allied " .. Constants.Words.POKEMON .. " has the Ability Plus, this " .. Constants.Words.POKEMON .. "'s Special Attack stat increases by 50%.",
	},
	{
		id = 59,
		name = "Forecast",
		description = "Castform's type changes with the weather. Fire while sunny, Water while raining, or Ice while hailing. Cloud Nine and Air Lock disable this effect. This ability has no effect if a " .. Constants.Words.POKEMON .. " other than Castform obtains this ability.",
	},
	{
		id = 60,
		name = "Sticky Hold",
		description = "This " .. Constants.Words.POKEMON .. "'s held item cannot be taken or removed.",
		descriptionEmerald = "Increases the chance of getting bites while fishing.",
	},
	{
		id = 61,
		name = "Shed Skin",
		description = "1/3 chance at the end of every turn to cure major status conditions (Burn, Poison, Paralysis, Freeze, Sleep).",
	},
	{
		id = 62,
		name = "Guts",
		description = "Increases this " .. Constants.Words.POKEMON .. "'s Attack stat by 50% when affected by a major status condition (Burn, Poison, Paralysis, Freeze, Sleep), and ignores the Attack reduction of Burn.",
	},
	{
		id = 63,
		name = "Marvel Scale",
		description = "Increases this " .. Constants.Words.POKEMON .. "'s Defense stat by 50% when affected by a major status condition (Burn, Poison, Paralysis, Freeze, Sleep).",
	},
	{
		id = 64,
		name = "Liquid Ooze",
		description = "HP draining moves used against this " .. Constants.Words.POKEMON .. " cause the attacker to instead lose the HP they would have healed.",
	},
	{
		id = 65,
		name = "Overgrow",
		description = "If this " .. Constants.Words.POKEMON .. " is at or below 1/3 of its max HP, the power of their Grass moves is increased by 50%.",
	},
	{
		id = 66,
		name = "Blaze",
		description = "If this " .. Constants.Words.POKEMON .. " is at or below 1/3 of its max HP, the power of their Fire moves is increased by 50%.",
	},
	{
		id = 67,
		name = "Torrent",
		description = "If this " .. Constants.Words.POKEMON .. " is at or below 1/3 of its max HP, the power of their Water moves is increased by 50%.",
	},
	{
		id = 68,
		name = "Swarm",
		description = "If this " .. Constants.Words.POKEMON .. " is at or below 1/3 of its max HP, the power of their Bug moves is increased by 50%.",
		descriptionEmerald = "Increases the frequency at which wild " .. Constants.Words.POKEMON .. "s' cries are heard in the overworld.",
	},
	{
		id = 69,
		name = "Rock Head",
		description = "Prevents recoil damage from moves, except for Struggle.",
	},
	{
		id = 70,
		name = "Drought",
		description = "Changes weather to sunny when switched in. In sun, Fire moves have 50% increased power and Water moves have 50% decreased power. Removes the charging turn for Solarbeam, lowers the Accuracy of Thunder to 50%, and causes Moonlight, Synthesis, and Morning Sun to heal 2/3 max HP.",
	},
	{
		id = 71,
		name = "Arena Trap",
		description = "Prevents opposing " .. Constants.Words.POKEMON .. " from switching out or fleeing, except Flying-types and " .. Constants.Words.POKEMON .. " with Levitate.",
		descriptionEmerald = "Increases the wild encounter rate by 100%.",
	},
	{
		id = 72,
		name = "Vital Spirit",
		description = "Cannot be put to sleep. If this " .. Constants.Words.POKEMON .. " tries to use Rest, it will fail. Gaining this Ability, like through Skill Swap, will cure Sleep.",
		descriptionEmerald = "While at the head of the party, 50% chance that a wild encounter will be at the highest possible level that " .. Constants.Words.POKEMON .. " could appear."
	},
	{
		id = 73,
		name = "White Smoke",
		description = "Prevents stat reductions caused by opposing " .. Constants.Words.POKEMON .. "s' moves and abilities.",
		descriptionEmerald = "While at the head of the party, decreases the wild encounter rate by 50%.",
	},
	{
		id = 74,
		name = "Pure Power",
		description = "Doubles this " .. Constants.Words.POKEMON .. "'s Attack stat.",
	},
	{
		id = 75,
		name = "Shell Armor",
		description = "Prevents this " .. Constants.Words.POKEMON .. " from receiving critical hits.",
	},
	{
		id = 76,
		name = "Cacophony", -- Unused in game but still takes this slot
		description = "Immune to sound-based moves. These moves are:\nGrassWhistle, Growl, Heal Bell, Hyper Voice, Metal Sound, Perish Song, Roar, Screech, Sing, Snore, Supersonic, Uproar.",
	},
	{
		id = 77,
		name =	"Air Lock",
		description = "Negates all effects of weather, but does not end the weather.",
	},
}
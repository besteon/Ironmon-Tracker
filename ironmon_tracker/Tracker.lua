Tracker = {}

Tracker.userDataKey = "ironmon_tracker_data"

Tracker.redraw = true
Tracker.waitFrames = 0

Tracker.controller = {
	statIndex = 1,
	framesSinceInput = 120,
	boxVisibleFrames = 120,
}

Tracker.Data = {}

--[[Example 'pokemon' = {
	213 = {-- Shuckle
		abilities = {
			{ id = 3, revealed = false }, -- Drizzle
			{ id = 6, revealed = false }, -- Sturdy
		},
		statmarkings = { hp = 1, att = 1, def = 1, spa = 1, spd = 1, spe = 1 },
		moves = {
			{ id = 7, level = 13 }, -- Fire Punch
			{ id = 10, level = 1 }, -- Scratch
			{ id = 16, level = 1 }, -- Gust
			{ id = 32, level = 5 }, -- Horn Drill
		},
		encounters = 1, -- Number of times this Pokemon has been encountered throughout the entire game
		note = "very fast shuckle",
	},
}
]]--

-- an ordered list of Pokemon that are owned by the player, either in their team or in PC
ownPokemon = {
	{
		pkmID = 213,
		otID = 12345, -- 0 - 65535
		personality = 00000000+00000000+00000000+00000000, --https://bulbapedia.bulbagarden.net/wiki/Personality_value
		curHP = 20
		--maxHP derived from stats.hp
		level = 20,
		heldItem = 5,
		ability = { abilityId = 3, revealed = true }, -- Drizzle
		nature = 13, -- Serious, calculated by [p mod 25 + 1]
		stats = { hp = 100, att = 25, def = 50, spa = 15, spd = 45, spe = 80 },
		statStages = { hp = 6, att = 6, def = 6, spa = 6, spd = 6, spe = 6 },
		moves = { -- moveid gets data about move name, level is the randomizer level learned, and pp is current available pp
			{ id = 7, level = 13, pp = 3 }, -- Fire Punch
			{ id = 10, level = 1, pp = 30 }, -- Scratch
			{ id = 16, level = 1, pp = 21 }, -- Gust
			{ id = 32, level = 5, pp = 2 }, -- Horn Drill
		},
	},
}

-- Used as a pointer to tell the tracker what prokemon to show information for, pulled from the 'ownPokemon' list if 'isViewingOwn' = true
-- Was the selectedPlayer variable
-- compareindex represents the selected pokemon being fought. This is the "relative enemy" of the pokemon being viewed. Used for move effectiveness
pokemonViewIndex = 1
isViewingOwn = true
compareViewIndex = 1

-- TODO: Create a struct to keep tracked information about your full pokemon team (and pc pokemon?)
-- ^ Use personality trait for track uniqueness? v
-- TODO: Create a struct to store info for last seen pokemon (targeted)

function Tracker.InitTrackerData()
	local trackerData = {
		pokemon = {},  -- Used to track information about all pokemon seen thus far
		ownPokemon = {},
		otherPokemon = {}, -- Only tracks the current Pokemon you are fighting, up to two in a doubles battle.
		ownMainIndex = 1, -- Used to point to which 'ownPokemon' is currently set to your main
		pokemonViewIndex = 1, -- Used to point to which ownPokemon/otherPokemon is currently being drawn
		compareViewIndex = 1, -- Used to point to which otherPokemon/ownPokemon that the drawn pokemon is being compared to, for calculations
		isViewingOwn = true,
		
		inBattle = 0,
		needCheckSummary = Utils.inlineIf(Options["Hide stats until summary shown"], 1, 0),

		selectedPokemon = {},
		targetedPokemon = {},

		selectedPlayer = 1,
		selectedSlot = 1,
		targetPlayer = 2,
		targetSlot = 1,

		selfSlotOne = 1, -- Are these four used for your main/doubles partner mons, and for enemy mons?
		selfSlotTwo = 1,
		enemySlotOne = 1,
		enemySlotTwo = 1,

		items = {}, -- Currently unused
		healingItems = {
			healing = 0,
			numHeals = 0,
		},
		centerHeals = Utils.inlineIf(Options["PC heals count downward"], 10, 0),
		badges = {0,0,0,0,0,0,0,0},
		currentHiddenPowerType = PokemonTypes.NORMAL,
		romHash = nil,
	}
	return trackerData
end

function Tracker.Clear()
	if userdata.containskey(Tracker.userDataKey) then
		userdata.remove(Tracker.userDataKey)
	end
	Tracker.Data = Tracker.InitTrackerData()
end

function Tracker.addOwnPokemon(pokemonData, isNewMain)
	if pokemonData == nil then
		return
	end

	table.insert(pokemonData, Tracker.Data.ownPokemon)

	if isNewMain then
		Tracker.Data.ownMainIndex = table.getn(Tracker.Data.ownPokemon)
		if Tracker.Data.isViewingOwn then
			Tracker.Data.pokemonViewIndex = Tracker.Data.ownMainIndex
		else
			Tracker.Data.compareViewIndex = Tracker.Data.ownMainIndex
		end
	end
end

function Tracker.addOtherPokemon(pokemonData, isDoublesPartner)
	if pokemonData == nil then
		return
	end

	if Tracker.Data.otherPokemon == nil then
		Tracker.Data.otherPokemon = {}
	end

	if not isDoublesPartner then
		Tracker.Data.otherPokemon[1] = pokemonData
	else
		Tracker.Data.otherPokemon[2] = pokemonData
	end
end

function Tracker.swapViews()
	local tempViewIndex = Tracker.Data.pokemonViewIndex
	Tracker.Data.pokemonViewIndex = Tracker.Data.compareViewIndex
	Tracker.Data.compareViewIndex = tempViewIndex
	Tracker.Data.isViewingOwn = not isViewingOwn
end

-- Currently unused
function Tracker.TrackItem(pokemonId, itemId)
	-- if Tracker.Data.pokemon[pokemonId] == nil then
	-- 	Tracker.Data.pokemon[pokemonId] = {}
	-- end
end

-- Adds the Pokemon's ability to the tracked data if it doesn't exist, otherwise updates it.
-- isRevealed: set to true only when the player is supposed to know the ability exists for that Pokemon
function Tracker.TrackAbility(pokemonId, abilityId, isRevealed)
	if Tracker.Data.pokemon[pokemonId] == nil then
		Tracker.Data.pokemon[pokemonId] = {}
	end

	-- If no ability is being tracked for this Pokemon, add it as the first ability
	if Tracker.Data.pokemon[pokemonId].abilities == nil then
		Tracker.Data.pokemon[pokemonId].abilities = {
			{
				id = abilityId,
				revealed = isRevealed
			}
		}
	-- If exactly one ability is being tracked and its 'abilityId'
	elseif Tracker.Data.pokemon[pokemonId].abilities[1].id == abilityId then
		-- Don't overwrite known ability information with isRevealed=false
		if isRevealed then
			Tracker.Data.pokemon[pokemonId].abilities[1].revealed = true
		end
	elseif Tracker.Data.pokemon[pokemonId].abilities[2] == nil then
		Tracker.Data.pokemon[pokemonId].abilities[2] = {
			id = abilityId,
			revealed = isRevealed
		}
	elseif Tracker.Data.pokemon[pokemonId].abilities[2].id == abilityId then
		-- Don't overwrite known ability information with isRevealed=false
		if isRevealed then
			Tracker.Data.pokemon[pokemonId].abilities[2].revealed = true
		end
	end
end

function Tracker.TrackStatMarkings(pokemonId, statmarkings)
	if Tracker.Data.pokemon[pokemonId] == nil then
		Tracker.Data.pokemon[pokemonId] = {}
	end

	Tracker.Data.pokemon[pokemonId].statmarkings = statmarkings
end

-- Adds the Pokemon's move to the tracked data if it doesn't exist, otherwise updates it.
function Tracker.TrackMove(pokemonId, moveId, level)
	if Tracker.Data.pokemon[pokemonId] == nil then
		Tracker.Data.pokemon[pokemonId] = {}
	end

	-- If no move data exist, set this as the first move
	if Tracker.Data.pokemon[pokemonId].moves == nil then
		Tracker.Data.pokemon[pokemonId].moves = {
			{ id = moveId, level = level },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
		}
	else
		-- First check if the move has been seen before
		local moveSeen = false
		local moveCount = 0
		local whichMove = 0
		for key, value in pairs(Tracker.Data.pokemon[pokemonId].moves) do
			moveCount = moveCount + 1
			if value.id == moveId then
				moveSeen = true
				whichMove = key
			end
		end

		-- If the move has already been seen, update its level (do we even need this?)
		if moveSeen then
			Tracker.Data.pokemon[pokemonId].moves[whichMove] = {
				id = moveId,
				level = level
			}
		-- Otherwise, shift all the moves down and get rid of the fourth move
		else
			Tracker.Data.pokemon[pokemonId].moves[4] = Tracker.Data.pokemon[pokemonId].moves[3]
			Tracker.Data.pokemon[pokemonId].moves[3] = Tracker.Data.pokemon[pokemonId].moves[2]
			Tracker.Data.pokemon[pokemonId].moves[2] = Tracker.Data.pokemon[pokemonId].moves[1]
			Tracker.Data.pokemon[pokemonId].moves[1] = {
				id = moveId,
				level = level
			}

			-- if moveCount == 1 then
			-- 	Tracker.Data.moves[pokemonId].second = {
			-- 		move = moveId,
			-- 		level = level
			-- 	}
			-- elseif moveCount == 2 then
			-- 	Tracker.Data.moves[pokemonId].third = {
			-- 		move = moveId,
			-- 		level = level
			-- 	}
			-- elseif moveCount == 3 then
			-- 	Tracker.Data.moves[pokemonId].fourth = {
			-- 		move = moveId,
			-- 		level = level
			-- 	}
			-- elseif moveCount == 4 then
				-- replace with above uncommented code
			-- end
		end
	end
end

-- numEncounters: (optional) used to overwrite the number of encounters
function Tracker.TrackEncounter(pokemonId, numEncounters)
	if Tracker.Data.pokemon[pokemonId] == nil then
		Tracker.Data.pokemon[pokemonId] = {}
	end

	if Tracker.Data.pokemon[pokemonId].encounters == nil then
		Tracker.Data.pokemon[pokemonId].encounters = 1
	elseif numEncounters ~= nil then
		Tracker.Data.pokemon[pokemonId].encounters = numEncounters
	else
		Tracker.Data.pokemon[pokemonId].encounters = Tracker.Data.pokemon[pokemonId].encounters + 1
	end
end

function Tracker.TrackNote(pokemonId, note)
	if note == nil then
		return
	elseif string.len(note) > 70 then
		print("Pokemon's note truncated to 70 characters.")
		note = string.sub(note, 1, 70)
	end

	if Tracker.Data.pokemon[pokemonId] == nil then
		Tracker.Data.pokemon[pokemonId] = {}
	end
		
	Tracker.Data.pokemon[pokemonId].note = note
end

-- If the Pokemon is being tracked, return information on moves; otherwise default move values = 1
function Tracker.getMoves(pokemonId)
	if pokemonId == nil or Tracker.Data.pokemon[pokemonId] == nil or Tracker.Data.pokemon[pokemonId].moves == nil then
		return {
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
		}
	else
		return Tracker.Data.pokemon[pokemonId].moves
	end
end

-- If the Pokemon is being tracked, return information on abilities; otherwise a default ability value = 1 & false
function Tracker.getAbilities(pokemonId)
	if pokemonId == nil or Tracker.Data.pokemon[pokemonId] == nil or Tracker.Data.pokemon[pokemonId].abilities == nil then
		return {
			{ id = 1, revealed = false },
		}
	else
		return Tracker.Data.pokemon[pokemonId].abilities
	end
end

-- If the Pokemon is being tracked, return information on statmarkings; otherwise default stat values = 1
function Tracker.getStatMarkings(pokemonId)
	if pokemonId == nil or Tracker.Data.pokemon[pokemonId] == nil or Tracker.Data.pokemon[pokemonId].statmarkings == nil then
		return { hp = 1, att = 1, def = 1, spa = 1, spd = 1, spe = 1 }
	else
		return Tracker.Data.pokemon[pokemonId].statmarkings
	end
end

-- If the Pokemon is being tracked, return its note; otherwise default note value = ""
function Tracker.getNote(pokemonId)
	if pokemonId == nil or Tracker.Data.pokemon[pokemonId] == nil or Tracker.Data.pokemon[pokemonId].note == nil then
		return ""
	else
		return Tracker.Data.pokemon[pokemonId].note
	end
end


function Tracker.saveData()
	local dataString = pickle(Tracker.Data)
	userdata.set(Tracker.userDataKey, dataString)
end

function Tracker.loadData()
	if userdata.containskey(Tracker.userDataKey) then
		local serializedTable = userdata.get(Tracker.userDataKey)
		local trackerData = unpickle(serializedTable)
		Tracker.Data = Tracker.InitTrackerData()
		for k, v in pairs(trackerData) do
			Tracker.Data[k] = v
		end

		if Tracker.Data.romHash then
			if gameinfo.getromhash() == Tracker.Data.romHash then
				Buttons.updateBadges()
				print("Loaded tracker data")
			else
				print("New ROM detected, resetting tracker data")
				Tracker.Data = Tracker.InitTrackerData()
			end
		end
	else
		Tracker.Data = Tracker.InitTrackerData()
	end

	Tracker.Data.romHash = gameinfo.getromhash()
	Tracker.redraw = true
end

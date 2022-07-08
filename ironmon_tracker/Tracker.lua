Tracker = {}

Tracker.userDataKey = "ironmon_tracker_data"

Tracker.controller = {
	statIndex = 1,
	framesSinceInput = 120,
	boxVisibleFrames = 120,
}

Tracker.Data = {}

function Tracker.InitTrackerData()
	local trackerData = {
		trainerID = 0,
		allPokemon = {},  -- Used to track information about all pokemon seen thus far
		ownPokemon = {}, -- a set of Pokemon that are owned by the player, either in their team or in PC, stored uniquely by the pokemon's personality value
		otherPokemon = {}, -- Only tracks the current Pokemon you are fighting, up to two in a doubles battle.

		ownTeam = { 0, 0, 0, 0, 0, 0 }, -- Holds six reference personality ids for which 'ownPokemon' are on your team currently, 1st slot = lead pokemon
		otherTeam = { 0, 0, 0, 0, 0, 0 },
		ownViewSlot = 1, -- During battle, this references which of your own six pokemon [1-6] are being used
		otherViewSlot = 1, -- During battle, this references which of the other six pokemon [1-6] are being used
		isViewingOwn = true,
		inBattle = false,

		hasCheckedSummary = not Options["Hide stats until summary shown"],
		centerHeals = Utils.inlineIf(Options["PC heals count downward"], 10, 0),
		-- items = {}, -- Currently unused. If plans to use, this would instead be stored under allPokemon tracked data
		healingItems = {
			healing = 0,
			numHeals = 0,
		},
		badges = {0,0,0,0,0,0,0,0},
		currentHiddenPowerType = PokemonTypes.NORMAL,
		romHash = nil,
	}
	return trackerData
end

-- Either adds this pokemon to storage if it doesn't exist, or updates it if it's already there
function Tracker.addUpdatePokemon(pokemonData, personality, isOwn)
	if pokemonData == nil or personality == nil then return end
	if isOwn == nil then isOwn = true end

	if isOwn and Tracker.Data.ownPokemon == nil then
		Tracker.Data.ownPokemon = {}
	elseif not isOwn and Tracker.Data.otherPokemon == nil then
		Tracker.Data.otherPokemon = {}
	end

	local pokemon = nil
	if isOwn then
		pokemon = Tracker.Data.ownPokemon[personality]
	else
		pokemon = Tracker.Data.otherPokemon[personality]
	end

	-- If the Pokemon already exists, update the parts of it that you can; otherwise add it.
	if pokemon ~= nil then
		-- If the Pokemon evolved (or otherwise changed), clear it's ability; to be updated later in battle
		if pokemonData.pokemonID ~= pokemon.pokemonID then
			pokemonData.ability = nil
			pokemon.ability = nil
		end

		-- Update each pokemon key if it exists between both Pokemon
		for k, v in pairs(pokemonData) do
			if pokemonData[k] ~= nil and pokemon[k] ~= nil then
				pokemon[k] = pokemonData[k]
			end
		end
	else
		if isOwn then
			Tracker.Data.ownPokemon[personality] = pokemonData
		else
			Tracker.Data.otherPokemon[personality] = pokemonData
		end
	end
end

function Tracker.getPokemon(slotNumber, isOwn)
	if slotNumber == nil then return nil end
	if isOwn == nil then isOwn = true end

	local personality = Utils.inlineIf(isOwn, Tracker.Data.ownTeam[slotNumber], Tracker.Data.otherTeam[slotNumber])
	if personality == nil or personality == 0 then return nil end

	if isOwn then
		return Tracker.Data.ownPokemon[personality]
	else
		return Tracker.Data.otherPokemon[personality]
	end
end

-- Currently unused
function Tracker.TrackItem(pokemonID, itemId)
	-- if Tracker.Data.allPokemon[pokemonID] == nil then
	-- 	Tracker.Data.allPokemon[pokemonID] = {}
	-- end

	-- local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	-- Implement later if this information ends up mattering
end

-- Adds the Pokemon's ability to the tracked data if it doesn't exist, otherwise updates it.
-- isRevealed: set to true only when the player is supposed to know the ability exists for that Pokemon
function Tracker.TrackAbility(pokemonID, abilityId, isRevealed)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end
	if isRevealed == nil then isRevealed = false end

	-- If no ability is being tracked for this Pokemon, add it as the first ability
	local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if trackedPokemon.abilities == nil then
		trackedPokemon.abilities = {
			{
				id = abilityId,
				revealed = isRevealed
			}
		}
	-- If exactly one ability is being tracked and its 'abilityId'
	elseif trackedPokemon.abilities[1].id == abilityId then
		-- Don't overwrite known ability information with isRevealed=false
		if isRevealed then
			trackedPokemon.abilities[1].revealed = true
		end
	elseif trackedPokemon.abilities[2] == nil then
		trackedPokemon.abilities[2] = {
			id = abilityId,
			revealed = isRevealed
		}
	elseif trackedPokemon.abilities[2].id == abilityId then
		-- Don't overwrite known ability information with isRevealed=false
		if isRevealed then
			trackedPokemon.abilities[2].revealed = true
		end
	end
end

function Tracker.TrackStatMarkings(pokemonID, statmarkings)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	trackedPokemon.statmarkings = statmarkings
end

-- Adds the Pokemon's move to the tracked data if it doesn't exist, otherwise updates it.
function Tracker.TrackMove(pokemonID, moveId, level)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	-- If no move data exist, set this as the first move
	local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if trackedPokemon.moves == nil then
		trackedPokemon.moves = {
			{ id = moveId, level = level },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
		}
	else
		-- First check if the move has been seen before
		local moveIndexSeen = 0
		for key, value in pairs(trackedPokemon.moves) do
			if value.id == moveId then
				moveIndexSeen = key
			end
		end

		-- If the move has already been seen, update its level (do we even need this?)
		if moveIndexSeen ~= 0 then
			-- TODO: Maybe we only update if the information on the level at which the Pokemon knows the move is more helpful
			-- For example, if the new level is lower than the current known level? Unsure if this breaks anything
			trackedPokemon.moves[moveIndexSeen] = {
				id = moveId,
				level = level
			}
		-- Otherwise it's a new move, shift all the moves down and get rid of the fourth move
		else
			trackedPokemon.moves[4] = trackedPokemon.moves[3]
			trackedPokemon.moves[3] = trackedPokemon.moves[2]
			trackedPokemon.moves[2] = trackedPokemon.moves[1]
			trackedPokemon.moves[1] = {
				id = moveId,
				level = level
			}
		end
	end
end

-- isTrainerPokemon: If trainerIDs are equal, then its a wild pokemon; otherwise Pokemon belongs to a Foe trainer
function Tracker.TrackEncounter(pokemonID, isTrainerPokemon)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if trackedPokemon.encounters == nil then
		trackedPokemon.encounters = { wild = 0, trainer = 0 }
	end

	if isTrainerPokemon then
		trackedPokemon.encounters.trainer = trackedPokemon.encounters.trainer + 1
	else
		trackedPokemon.encounters.wild = trackedPokemon.encounters.wild + 1
	end
end

function Tracker.TrackNote(pokemonID, note)
	if note == nil then
		return
	elseif string.len(note) > 70 then
		print("Pokemon's note truncated to 70 characters.")
		note = string.sub(note, 1, 70)
	end

	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end
	
	local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	trackedPokemon.note = note
end

function Tracker.isTrackingMove(pokemonID, moveId, level)
	local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if trackedPokemon == nil or trackedPokemon.moves == nil then return false end

	for _, move in pairs(trackedPokemon.moves) do
		if move.id == moveId and move.level == level then
			return true
		end
	end

	return false
end

-- If the Pokemon is being tracked, return information on moves; otherwise default move values = 1
function Tracker.getMoves(pokemonID)
	if pokemonID == nil or Tracker.Data.allPokemon[pokemonID] == nil or Tracker.Data.allPokemon[pokemonID].moves == nil then
		return {
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
			{ id = 1, level = 1 },
		}
	else
		return Tracker.Data.allPokemon[pokemonID].moves
	end
end

-- Currently unused, but likely going to want to use it via ability-note-taking
-- If the Pokemon is being tracked, return information on abilities; otherwise a default ability value = 1 & false
function Tracker.getAbilities(pokemonID)
	if pokemonID == nil or Tracker.Data.allPokemon[pokemonID] == nil or Tracker.Data.allPokemon[pokemonID].abilities == nil then
		return {
			{ id = 0, revealed = false },
		}
	else
		return Tracker.Data.allPokemon[pokemonID].abilities
	end
end

-- If the Pokemon is being tracked, return information on statmarkings; otherwise default stat values = 1
function Tracker.getStatMarkings(pokemonID)
	if pokemonID == nil or Tracker.Data.allPokemon[pokemonID] == nil or Tracker.Data.allPokemon[pokemonID].statmarkings == nil then
		return { hp = 1, atk = 1, def = 1, spa = 1, spd = 1, spe = 1 }
	else
		return Tracker.Data.allPokemon[pokemonID].statmarkings
	end
end

-- If the Pokemon is being tracked, return its encounter count; otherwise default encounter values = 0
function Tracker.getEncounters(pokemonID, isTrainerPokemon)
	if pokemonID == nil or Tracker.Data.allPokemon[pokemonID] == nil or Tracker.Data.allPokemon[pokemonID].encounters == nil then
		return 0
	elseif isTrainerPokemon then
		return Tracker.Data.allPokemon[pokemonID].encounters.trainer
	else
		return Tracker.Data.allPokemon[pokemonID].encounters.wild
	end
end

-- If the Pokemon is being tracked, return its note; otherwise default note value = ""
function Tracker.getNote(pokemonID)
	if pokemonID == nil or Tracker.Data.allPokemon[pokemonID] == nil or Tracker.Data.allPokemon[pokemonID].note == nil then
		return ""
	else
		return Tracker.Data.allPokemon[pokemonID].note
	end
end

function Tracker.getDefaultPokemon()
	local blankPokemon = {
		pokemonID = 0,
		friendship = 0,
		heldItem = 0,
		level = 0,
		nature = 0, 
		ability = nil, -- Must be nil and not { id = 0, revealed = false }
		status = 0,
		sleep_turns = 0,
		curHP = 0,
		stats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
		statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
		moves = {
			{ id = 1, level = 1, pp = 0 },
			{ id = 1, level = 1, pp = 0 },
			{ id = 1, level = 1, pp = 0 },
			{ id = 1, level = 1, pp = 0 },
		},
	}

	return blankPokemon
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
	Program.waitToDrawFrames = 0
end

function Tracker.Clear()
	if userdata.containskey(Tracker.userDataKey) then
		userdata.remove(Tracker.userDataKey)
	end
	Tracker.Data = Tracker.InitTrackerData()
end
Tracker = {}

Tracker.userDataKey = "ironmon_tracker_data"

Tracker.waitFrames = 0

Tracker.controller = {
	statIndex = 1,
	framesSinceInput = 120,
	boxVisibleFrames = 120,
}

Tracker.Data = {}

--[[Tracked Pokemon Example: allPokemon = {
	213 = {-- Shuckle
		abilities = {
			{ id = 3, revealed = false }, -- Drizzle
			{ id = 6, revealed = false }, -- Sturdy
		},
		statmarkings = { hp = 1, atk = 1, def = 1, spa = 1, spd = 1, spe = 1 },
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

-- a list of Pokemon that are owned by the player, either in their team or in PC, stored uniquely by the pokemon's personality value
-- A second set is temporarily stored for "otherPokemon" which belong to trainers or wilds
--[[Storage Pokemon Example: ownPokemon = {
	["12345678123456781234567812345678"(personality)] = {
		pokemonID = Utils.getbits(growth1, 0, 16),
		friendship = Utils.getbits(growth3, 72, 8),
		heldItem = Utils.getbits(growth1, 16, 16),
		level = Memory.readbyte(startAddress + 84),
		nature = personality % 25,
		ability = { id = 3, revealed = true }, -- Drizzle
		status = status_result,
		sleep_turns = sleep_turns_result,
		curHP = Memory.readword(startAddress + 86),
		stats = {
			hp = Memory.readword(startAddress + 88), -- aka, maxHP
			atk = Memory.readword(startAddress + 90),
			def = Memory.readword(startAddress + 92),
			spa = Memory.readword(startAddress + 96),
			spd = Memory.readword(startAddress + 98),
			spe = Memory.readword(startAddress + 94),
		},
		statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
		moves = {
			{ id = Utils.getbits(attack1, 0, 16) + 1, level = 1, pp = Utils.getbits(attack3, 0, 8) },
			{ id = Utils.getbits(attack1, 16, 16) + 1, level = 1, pp = Utils.getbits(attack3, 8, 8) },
			{ id = Utils.getbits(attack2, 0, 16) + 1, level = 1, pp = Utils.getbits(attack3, 16, 8) },
			{ id = Utils.getbits(attack2, 16, 16) + 1, level = 1, pp = Utils.getbits(attack3, 24, 8) },
		},
	},
}]]--

function Tracker.InitTrackerData()
	local trackerData = {
		allPokemon = {},  -- Used to track information about all pokemon seen thus far
		ownPokemon = {},
		otherPokemon = {}, -- Only tracks the current Pokemon you are fighting, up to two in a doubles battle.

		ownTeam = { 0, 0, 0, 0, 0, 0 }, -- Holds six reference personality ids for which 'ownPokemon' are on your team currently, 1st slot = lead pokemon
		otherTeam = { 0, 0, 0, 0, 0, 0 },
		ownViewSlot = 1, -- During battle, this references which of your own six pokemon are being used
		otherViewSlot = 1, -- During battle, this references which of the other six pokemon are being used
		isViewingOwn = true,
		
		inBattle = false,
		needCheckSummary = Utils.inlineIf(Options["Hide stats until summary shown"], 1, 0),

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

-- Either adds this pokemon to storage if it doesn't exist, or updates it if it's already there
function Tracker.addUpdatePokemon(pokemonData, personality, isOwn)
	if pokemonData == nil or personality == nil then return end
	if isOwn == nil then isOwn = true end

	if isOwn and Tracker.Data.ownPokemon == nil then
		Tracker.Data.ownPokemon = {}
	elseif not isOwn and Tracker.Data.otherPokemon == nil then
		Tracker.Data.otherPokemon = {}
	end

	-- If the Pokemon already exists, update the parts of it that you can; otherwise add it.
	local pokemon = nil
	if isOwn then
		pokemon = Tracker.Data.ownPokemon[personality]
	else
		pokemon = Tracker.Data.otherPokemon[personality]
	end

	if pokemon ~= nil then
		for k, v in pairs(pokemonData) do
			-- Update each pokemon key if it exists between both Pokemon
			-- TODO: This double-check required to prevent encounter flag from being added, unsure if it screws up anything
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

	return Utils.inlineIf(isOwn, Tracker.Data.ownPokemon[personality], Tracker.Data.otherPokemon[personality])
end

-- Currently unused
function Tracker.TrackItem(pokemonID, itemId)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	local tackedPokemon = Tracker.Data.allPokemon[pokemonID]
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
	local tackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if tackedPokemon.abilities == nil then
		tackedPokemon.abilities = {
			{
				id = abilityId,
				revealed = isRevealed
			}
		}
	-- If exactly one ability is being tracked and its 'abilityId'
	elseif tackedPokemon.abilities[1].id == abilityId then
		-- Don't overwrite known ability information with isRevealed=false
		if isRevealed then
			tackedPokemon.abilities[1].revealed = true
		end
	elseif tackedPokemon.abilities[2] == nil then
		tackedPokemon.abilities[2] = {
			id = abilityId,
			revealed = isRevealed
		}
	elseif tackedPokemon.abilities[2].id == abilityId then
		-- Don't overwrite known ability information with isRevealed=false
		if isRevealed then
			tackedPokemon.abilities[2].revealed = true
		end
	end
end

function Tracker.TrackStatMarkings(pokemonID, statmarkings)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	local tackedPokemon = Tracker.Data.allPokemon[pokemonID]
	tackedPokemon.statmarkings = statmarkings
end

-- Adds the Pokemon's move to the tracked data if it doesn't exist, otherwise updates it.
function Tracker.TrackMove(pokemonID, moveId, level)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	-- If no move data exist, set this as the first move
	local tackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if tackedPokemon.moves == nil then
		tackedPokemon.moves = {
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
		for key, value in pairs(tackedPokemon.moves) do
			moveCount = moveCount + 1
			if value.id == moveId then
				moveSeen = true
				whichMove = key
			end
		end

		-- If the move has already been seen, update its level (do we even need this?)
		if moveSeen then
			tackedPokemon.moves[whichMove] = {
				id = moveId,
				level = level
			}
		-- Otherwise it's a new move, shift all the moves down and get rid of the fourth move
		else
			tackedPokemon.moves[4] = tackedPokemon.moves[3]
			tackedPokemon.moves[3] = tackedPokemon.moves[2]
			tackedPokemon.moves[2] = tackedPokemon.moves[1]
			tackedPokemon.moves[1] = {
				id = moveId,
				level = level
			}
		end
	end
end

-- numEncounters: (optional) used to overwrite the number of encounters
function Tracker.TrackEncounter(pokemonID, numEncounters)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	local tackedPokemon = Tracker.Data.allPokemon[pokemonID]
	if tackedPokemon.encounters == nil then
		tackedPokemon.encounters = 1
	elseif numEncounters ~= nil then
		tackedPokemon.encounters = numEncounters
	else
		tackedPokemon.encounters = tackedPokemon.encounters + 1
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
	
	local tackedPokemon = Tracker.Data.allPokemon[pokemonID]
	tackedPokemon.note = note
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
			{ id = 1, revealed = false },
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

-- If the Pokemon is being tracked, return its encounter count; otherwise default encounter value = 0
function Tracker.getEncounters(pokemonID)
	if pokemonID == nil or Tracker.Data.allPokemon[pokemonID] == nil or Tracker.Data.allPokemon[pokemonID].encounters == nil then
		return 0
	else
		return Tracker.Data.allPokemon[pokemonID].encounters
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
	Program.waitFrames = 0
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
		statStages = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0, acc = 0, eva = 0 },
		moves = {
			{ id = 0, level = 0, pp = 0 },
			{ id = 0, level = 0, pp = 0 },
			{ id = 0, level = 0, pp = 0 },
			{ id = 0, level = 0, pp = 0 },
		},
	}

	return blankPokemon
end
Tracker = {}
Tracker.Data = {}

function Tracker.initialize()
	local filepath = GameSettings.getTrackerAutoSaveName()
	Tracker.loadData(filepath)
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

	local pokemon
	if isOwn then
		pokemon = Tracker.Data.ownPokemon[personality]
	else
		pokemon = Tracker.Data.otherPokemon[personality]
	end

	-- If the Pokemon already exists, update the parts of it that you can; otherwise add it.
	if pokemon ~= nil then
		-- If the Pokemon evolved (or otherwise changed), clear it's ability; to be updated later in battle
		if pokemonData.pokemonID ~= pokemon.pokemonID then
			pokemonData.abilityId = nil
			pokemon.abilityId = nil
		end

		-- Update each pokemon key if it exists between both Pokemon
		for key, _ in pairs(pokemonData) do
			if pokemonData[key] ~= nil and pokemon[key] ~= nil then
				pokemon[key] = pokemonData[key]
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

function Tracker.getOrCreateTrackedPokemon(pokemonID)
	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end
	return Tracker.Data.allPokemon[pokemonID]
end

-- Adds the Pokemon's ability to the tracked data if it doesn't exist, otherwise updates it.
function Tracker.TrackAbility(pokemonID, abilityId)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)

	if trackedPokemon.abilities == nil then
		trackedPokemon.abilities = {
			{ id = 0 },
			{ id = 0 },
		}
	end

	-- Only add as second ability if it's different than the first ability
	if trackedPokemon.abilities[1].id == 0 then
		trackedPokemon.abilities[1].id = abilityId
	elseif trackedPokemon.abilities[2].id == 0 and trackedPokemon.abilities[1].id ~= abilityId then
		trackedPokemon.abilities[2].id = abilityId
	end
	-- If this pokemon already has two abilities being tracked, simply do nothing.
end

function Tracker.TrackStatMarking(pokemonID, statStage, statState)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)

	if trackedPokemon.statmarkings == nil then
		trackedPokemon.statmarkings = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	end

	if trackedPokemon.statmarkings[statStage] ~= nil then
		trackedPokemon.statmarkings[statStage] = statState
	else
		print("[ERROR] stat stage does not exist: " .. statStage)
	end
end

-- Adds the Pokemon's move to the tracked data if it doesn't exist, otherwise updates it.
function Tracker.TrackMove(pokemonID, moveId, level)
	-- If no move data exist, set this as the first move
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.moves == nil then
		trackedPokemon.moves = {
			{ id = moveId, level = level },
			{ id = 0, level = 1 },
			{ id = 0, level = 1 },
			{ id = 0, level = 1 },
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

-- isWild: If trainerIDs are equal, then its a wild pokemon; otherwise Pokemon belongs to a Foe trainer
function Tracker.TrackEncounter(pokemonID, isWild)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.encounters == nil then
		trackedPokemon.encounters = { wild = 0, trainer = 0 }
	end

	if isWild then
		trackedPokemon.encounters.wild = trackedPokemon.encounters.wild + 1
	else
		trackedPokemon.encounters.trainer = trackedPokemon.encounters.trainer + 1
	end
end

function Tracker.TrackNote(pokemonID, note)
	if note == nil then return end

	if string.len(note) > 70 then
		print("Pokemon's note truncated to 70 characters.")
		note = string.sub(note, 1, 70)
	end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	trackedPokemon.note = note
end

function Tracker.TrackHiddenPowerType(moveType)
	if moveType == nil then return end

	local viewedPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)

	if viewedPokemon.personality ~= 0 then
		Tracker.Data.hiddenPowers[viewedPokemon.personality] = moveType
	end
end

function Tracker.isTrackingMove(pokemonID, moveId, level)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.moves == nil then
		return false
	end

	for _, move in pairs(trackedPokemon.moves) do
		if move.id == moveId and move.level == level then
			return true
		end
	end

	return false
end

-- If the Pokemon is being tracked, return information on moves; otherwise default move values = 1
function Tracker.getMoves(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.moves == nil then
		return {
			{ id = 0, level = 1, pp = 0 },
			{ id = 0, level = 1, pp = 0 },
			{ id = 0, level = 1, pp = 0 },
			{ id = 0, level = 1, pp = 0 },
		}
	else
		return trackedPokemon.moves
	end
end

-- If the Pokemon is being tracked, return information on abilities; otherwise a default ability values = 0
function Tracker.getAbilities(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.abilities == nil then
		return {
			{ id = 0 },
			{ id = 0 },
		}
	else
		return trackedPokemon.abilities
	end
end

-- If the Pokemon is being tracked, return information on statmarkings; otherwise default stat values = 1
function Tracker.getStatMarkings(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.statmarkings == nil then
		return { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	else
		return trackedPokemon.statmarkings
	end
end

-- If the Pokemon is being tracked, return its encounter count; otherwise default encounter values = 0
function Tracker.getEncounters(pokemonID, isWild)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.encounters == nil then
		return 0
	elseif isWild then
		return trackedPokemon.encounters.wild
	else
		return trackedPokemon.encounters.trainer
	end
end

-- If the Pokemon is being tracked, return its note; otherwise default note value = ""
function Tracker.getNote(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.note == nil then
		return ""
	else
		return trackedPokemon.note
	end
end

-- If the viewed Pokemon has the move "Hidden Power", return it's tracked type; otherwise default type value = NORMAL
function Tracker.getHiddenPowerType()
	local viewedPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
	local hiddenPowerType = Tracker.Data.hiddenPowers[viewedPokemon.personality]

	if hiddenPowerType ~= nil then
		return hiddenPowerType
	else
		return PokemonData.Types.NORMAL
	end
end

function Tracker.getDefaultPokemon()
	return {
		pokemonID = 0,
		personality = 0,
		friendship = 0,
		heldItem = 0,
		level = 0,
		nature = 0,
		abilityId = 0,
		status = 0,
		sleep_turns = 0,
		curHP = 0,
		stats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
		statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
		moves = {
			{ id = 0, level = 1, pp = 0 },
			{ id = 0, level = 1, pp = 0 },
			{ id = 0, level = 1, pp = 0 },
			{ id = 0, level = 1, pp = 0 },
		},
	}
end

function Tracker.resetData()
	Tracker.Data = {
		version = Main.TrackerVersion,
		romHash = nil,

		trainerID = 0,
		allPokemon = {}, -- Used to track information about all pokemon seen thus far
		ownPokemon = {}, -- a set of Pokemon that are owned by the player, either in their team or in PC, stored uniquely by the pokemon's personality value
		otherPokemon = {}, -- Only tracks the current Pokemon you are fighting, up to two in a doubles battle.

		ownTeam = { 0, 0, 0, 0, 0, 0 }, -- Holds six reference personality ids for which 'ownPokemon' are on your team currently, 1st slot = lead pokemon
		otherTeam = { 0, 0, 0, 0, 0, 0 },
		ownViewSlot = 1, -- During battle, this references which of your own six pokemon [1-6] are being used
		otherViewSlot = 1, -- During battle, this references which of the other six pokemon [1-6] are being used
		isViewingOwn = true,
		inBattle = false,

		hasCheckedSummary = not Options["Hide stats until summary shown"],
		gameStatsHeals = 0, -- Tally of auto-tracked heals, separate to allow manual adjusting of centerHeals
		centerHeals = Utils.inlineIf(Options["PC heals count downward"], 10, 0),
		-- items = {}, -- Currently unused. If plans to use, this would instead be stored under allPokemon tracked data
		healingItems = {
			healing = 0,
			numHeals = 0,
		},
		hiddenPowers = { -- Track hidden power types for each of your own Pokemon [personality] = [type]
			[0] = PokemonData.Types.NORMAL,
		},
	}
end

function Tracker.saveData(filepath)
	filepath = filepath or GameSettings.getTrackerAutoSaveName()
	Utils.writeTableToFile(Tracker.Data, filepath)
end

function Tracker.loadData(filepath)
	filepath = filepath or GameSettings.getTrackerAutoSaveName()

	-- Initialize empty Tracker data, to potentially populate with data from .TDAT save file
	Tracker.resetData()
	Tracker.Data.romHash = gameinfo.getromhash()

	-- Loose safety check to ensure a valid data file is loaded
	local fileData = nil
	if filepath:sub(-5):lower() ~= Constants.TRACKER_DATA_EXTENSION then
		print("[ERROR] Unable to load Tracker data from selected file: " .. filepath)
		Main.DisplayError("Invalid file selected.\n\nPlease select a TDAT file to load tracker data.")
	else
		fileData = Utils.readTableFromFile(filepath)
	end

	-- If the loaded data's romHash matches this current game exactly, use it; otherwise use the empty data
	if fileData ~= nil and fileData.romHash ~= nil and fileData.romHash == Tracker.Data.romHash then
		for k, v in pairs(fileData) do
			-- Only add data elements if the current Tracker data schema uses it
			if Tracker.Data[k] ~= nil then
				Tracker.Data[k] = v
			end
		end
		local fileNameIndex = string.match(filepath, "^.*()\\")
		local filename = string.sub(filepath, Utils.inlineIf(fileNameIndex ~= nil, fileNameIndex, 0) + 1)

		print("Tracker data loaded from file: " .. filename)
	else
		print("No Tracker data found for this ROM. Initializing new data.")
	end
end

Tracker = {}
Tracker.Data = {}
Tracker.DataMessage = "" -- Used for StartupScreen to display info about tracked data loaded

-- When Tracker data changes between versions, this will force new data into the tracker
-- Tracker.ForceUpdateData[source][key], such that it references Tracker.Data[source][key], using 'source' loosely, based on implementation
Tracker.ForceUpdateData = {
	pokemonData = {
		abilityNum = true,
		experience = true,
		currentExp = true,
		totalExp = true,
	},
}

Tracker.LoadStatusMessages = {
	newGame = "" or "New game successfully loaded and new Tracker data is being set up", -- leaving this blank for now to not alarm anyone
	fromFile = "Previously saved Tracker data for this game has been loaded",
	autoDisabled = "Tracker's auto-save is disabled, new Tracker data is being set up",
	unableLoadFile = "Unable to load Tracker data from selected file",
}

function Tracker.initialize()
	-- First create a default, non-nil Tracker Data
	Tracker.resetData()

	-- Then attempt to load in data from autosave TDAT file
	if Options["Auto save tracked game data"] then
		local filepath = FileManager.prependDir(GameSettings.getTrackerAutoSaveName())
		local success, err = Tracker.loadData(filepath)
		if not success and err ~= nil and string.find(err, Tracker.LoadStatusMessages.unableLoadFile, 1, true) == nil then
			-- Print any error that isn't "missing autosave tdat file"
			print("> " .. err)
		end
	else
		Tracker.DataMessage = Tracker.LoadStatusMessages.autoDisabled
	end
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
		-- Update each pokemon key if it exists between both Pokemon
		for key, _ in pairs(pokemonData) do
			if (pokemonData[key] ~= nil and pokemon[key] ~= nil) or Tracker.ForceUpdateData.pokemonData[key] then
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
	if personality == nil then
		return nil
	end

	-- Personality of 0 is okay for some real trainers, usually occurs in Battle
	local pokemonInSlot = Utils.inlineIf(isOwn, Tracker.Data.ownPokemon[personality], Tracker.Data.otherPokemon[personality])
	if pokemonInSlot == nil or (personality == 0 and (pokemonInSlot.trainerID == nil or pokemonInSlot.trainerID == 0)) then
		return nil
	end

	if isOwn then
		local isEggPokemon = Tracker.Data.ownPokemon[personality].isEgg == 1
		if isEggPokemon then
			-- Currently viewed pokemon is still an egg
			local nextSlot = slotNumber
			local numPokemon = #Tracker.Data.ownTeam
			repeat
				-- Cycle to the next non-egg party member (you're required at least one non-egg in the party)
				nextSlot = (nextSlot % numPokemon) + 1
				personality = Tracker.Data.ownTeam[nextSlot]
				if personality ~= nil and personality ~= 0 then
					isEggPokemon = Tracker.Data.ownPokemon[personality].isEgg == 1
				end
			until not isEggPokemon or nextSlot == slotNumber
		end
		return Tracker.Data.ownPokemon[personality]
	elseif Battle.isGhost then
		-- Return Ghost dummy instead of showing the hidden mon's data, but keep the level
		local retPokemon = Tracker.getGhostPokemon()
		retPokemon.level = Tracker.Data.otherPokemon[personality].level
		return retPokemon
	end
	return Tracker.Data.otherPokemon[personality]
end

function Tracker.getViewedPokemon()
	if not Program.isValidMapLocation() then return nil end

	local viewSlot
	if Tracker.Data.isViewingOwn then
		viewSlot = Utils.inlineIf(Battle.isViewingLeft, Battle.Combatants.LeftOwn, Battle.Combatants.RightOwn)
	else
		viewSlot = Utils.inlineIf(Battle.isViewingLeft, Battle.Combatants.LeftOther, Battle.Combatants.RightOther)
	end

	return Tracker.getPokemon(viewSlot, Tracker.Data.isViewingOwn)
end

function Tracker.getOrCreateTrackedPokemon(pokemonID)
	if not PokemonData.isValid(pokemonID) then return {} end -- Don't store tracked data for a non-existent pokemon data

	if Tracker.Data.allPokemon[pokemonID] == nil then
		Tracker.Data.allPokemon[pokemonID] = {}
	end

	return Tracker.Data.allPokemon[pokemonID]
end

-- Adds the Pokemon's ability to the tracked data if it doesn't exist, otherwise updates it.
function Tracker.TrackAbility(pokemonID, abilityId)
	if pokemonID == nil or abilityId == nil then return end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)

	if trackedPokemon.abilities == nil then
		trackedPokemon.abilities = {
			{ id = 0 },
			{ id = 0 },
		}
	end

	-- Only add as second ability if it's different than the first ability
	if trackedPokemon.abilities[1].id == nil or trackedPokemon.abilities[1].id == 0 then
		trackedPokemon.abilities[1].id = abilityId
	elseif (trackedPokemon.abilities[2].id == nil or trackedPokemon.abilities[2].id == 0) and trackedPokemon.abilities[1].id ~= abilityId then
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
		print(string.format("> ERROR: The stat stage %s does not exist.", statStage))
	end
end

-- Adds the Pokemon's move to the tracked data if it doesn't exist, otherwise updates it.
-- Also tracks the minimum and maximum level of the Pokemon that used the move
function Tracker.TrackMove(pokemonID, moveId, level)
	if not MoveData.isValid(moveId) or moveId == 165 then -- 165 = Struggle
		return
	end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)

	-- If no move data exist, set this as the first move
	if trackedPokemon.moves == nil then
		trackedPokemon.moves = {
			{ id = moveId, level = level, minLv = level, maxLv = level, },
			{ id = 0, level = 1 },
			{ id = 0, level = 1 },
			{ id = 0, level = 1 },
		}
		return
	end

	-- First check if the move has been seen before
	local moveIndexSeen = 0
	for key, value in pairs(trackedPokemon.moves) do
		if value.id == moveId then
			moveIndexSeen = key
			break
		end
	end

	-- If the move hasn't been seen or tracked yet, add it
	local moveSeen = trackedPokemon.moves[moveIndexSeen]
	if moveSeen == nil then
		-- If the oldest tracked move is a placeholder, remove it
		if trackedPokemon.moves[4].id == 0 then
			trackedPokemon.moves[4] = nil
		end
		table.insert(trackedPokemon.moves, 1, { id = moveId, level = level, minLv = level, maxLv = level, })
		return
	end

	-- Otherwise, update the existing move's level information
	moveSeen.level = level
	if moveSeen.minLv == nil or level < moveSeen.minLv then
		moveSeen.minLv = level
	end
	if moveSeen.maxLv == nil or level > moveSeen.maxLv then
		moveSeen.maxLv = level
	end
	-- If the move isn't on the list of top 4 moves, move it to the front
	if moveIndexSeen > 4 then
		for j = moveIndexSeen, 2, -1 do
			trackedPokemon.moves[j] = trackedPokemon.moves[j - 1]
		end
		trackedPokemon.moves[1] = moveSeen
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

-- encounterArea: RouteData.EncounterArea
function Tracker.TrackRouteEncounter(mapId, encounterArea, pokemonID)
	if Tracker.Data.encounterTable[mapId] == nil then
		Tracker.Data.encounterTable[mapId] = {}
	end

	if Tracker.Data.encounterTable[mapId][encounterArea] == nil then
		Tracker.Data.encounterTable[mapId][encounterArea] = { pokemonID }
	else
		local hasEncounteredBefore = false
		for _, encounterID in pairs(Tracker.Data.encounterTable[mapId][encounterArea]) do
			if pokemonID == encounterID then
				hasEncounteredBefore = true
				break
			end
		end
		if not hasEncounteredBefore then
			table.insert(Tracker.Data.encounterTable[mapId][encounterArea], pokemonID)
		end
	end
end

function Tracker.TrackNote(pokemonID, note)
	if note == nil then return end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	trackedPokemon.note = note
end

function Tracker.TrackHiddenPowerType(personality, moveType)
	if personality == nil or moveType == nil or personality == 0 then return end

	Tracker.Data.hiddenPowers[personality] = moveType
end

function Tracker.isTrackingMove(pokemonID, moveId, level)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.moves == nil then
		return false
	end

	for _, move in ipairs(trackedPokemon.moves) do -- intentionall check ALL tracked moves
		-- If the move doesn't provide any new information, consider it tracked
		if moveId == move.id and level >= move.level then
			return true
		end
	end

	return false
end

function Tracker.tryTrackWhichRival(trainerId)
	if trainerId == nil or trainerId == 0 or Tracker.Data.whichRival ~= nil then return end

	local trainer = TrainerData.getTrainerInfo(trainerId)
	if trainer ~= nil and trainer.whichRival ~= nil then -- verify this trainer is a rival trainer
		Tracker.Data.whichRival = trainer.whichRival
	end
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

function Tracker.setAbilities(pokemonID, abilityOneText, abilityTwoText)
	abilityOneText = abilityOneText or Constants.BLANKLINE
	abilityTwoText = abilityTwoText or Constants.BLANKLINE
	local abilityOneId = 0
	local abilityTwoId = 0

	-- If only one ability was entered in
	if abilityOneText == Constants.BLANKLINE then
		abilityOneText = abilityTwoText
		abilityTwoText = Constants.BLANKLINE
	end

	-- Lookup ability id's from the master list of ability pokemon data
	for id, ability in pairs(AbilityData.Abilities) do
		if abilityOneText == ability.name then
			abilityOneId = id
		elseif abilityTwoText == ability.name then
			abilityTwoId = id
		end
	end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	trackedPokemon.abilities = {
		{ id = abilityOneId },
		{ id = abilityTwoId },
	}
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

function Tracker.getRouteEncounters(mapId, encounterArea)
	if mapId == 0 or Tracker.Data.encounterTable[mapId] == nil then
		return {}
	elseif encounterArea == nil or Tracker.Data.encounterTable[mapId][encounterArea] == nil then
		return {}
	else
		return Tracker.Data.encounterTable[mapId][encounterArea]
	end
end

-- If the Pokemon is being tracked, return its note; otherwise default note value = ""
function Tracker.getNote(pokemonID)
	if pokemonID == 413 then -- Ghost
		return "Spoooky!"
	end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.note == nil then
		return ""
	else
		return trackedPokemon.note
	end
end

-- If the viewed Pokemon has the move "Hidden Power" (id=237), return it's tracked type; otherwise default type value = NORMAL
function Tracker.getHiddenPowerType()
	local viewedPokemon = Battle.getViewedPokemon(true)

	if viewedPokemon ~= nil and Tracker.Data.hiddenPowers[viewedPokemon.personality] ~= nil then
		return Tracker.Data.hiddenPowers[viewedPokemon.personality]
	else
		return MoveData.HiddenPowerTypeList[1]
	end
end

-- Note the last level seen of each Pokemon on the enemy team
function Tracker.recordLastLevelsSeen()
	for _, pokemon in pairs(Tracker.Data.otherPokemon) do
		if pokemon ~= nil and pokemon.level ~= nil and pokemon.level > 0 and pokemon.level <= 100 then
			local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemon.pokemonID)

			if trackedPokemon.encounters == nil then
				trackedPokemon.encounters = { wild = 0, trainer = 0 }
			end

			trackedPokemon.encounters.lastlevel = pokemon.level
		end
	end
end

-- Returns the level of the Pokemon last time it was seen; returns nil if never seen before
function Tracker.getLastLevelSeen(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.encounters == nil then
		return nil
	else
		return trackedPokemon.encounters.lastlevel
	end
end

function Tracker.getDefaultPokemon()
	return {
		pokemonID = 0,
		name = Constants.BLANKLINE,
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		abilities = { 0, 0 },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		movelvls = { {}, {} },
		weight = 0.0,
		personality = 0,
		experience = 0,
		currentExp = 0,
		totalExp = 100,
		friendship = 0,
		heldItem = 0,
		level = 0,
		nature = 0,
		abilityNum = nil, -- This will result in an abilityId of 0, or a BLANKLINE
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

function Tracker.getGhostPokemon()
	local defaultPokemon = Tracker.getDefaultPokemon()
	defaultPokemon.pokemonID = 413
	defaultPokemon.name = "Ghost"
	defaultPokemon.types = { PokemonData.Types.UNKNOWN, PokemonData.Types.UNKNOWN }
	return defaultPokemon
end

function Tracker.resetData()
	-- If adding new data fields to this object, always append to the end; allows TDAT files to be upgrade-safe
	Tracker.Data = {
		version = Main.TrackerVersion,
		romHash = GameSettings.getRomHash(),

		trainerID = 0,
		allPokemon = {}, -- Used to track information about all pokemon seen thus far
		ownPokemon = {}, -- a set of Pokemon that are owned by the player, either in their team or in PC, stored uniquely by the pokemon's personality value
		otherPokemon = {}, -- Only tracks the current Pokemon you are fighting, up to two in a doubles battle.

		ownTeam = { 0, 0, 0, 0, 0, 0 }, -- Holds six reference personality ids for which 'ownPokemon' are on your team currently, 1st slot = lead pokemon
		otherTeam = { 0, 0, 0, 0, 0, 0 },
		ownViewSlot = 1, -- During battle, this references which of your own six pokemon [1-6] are being used
		otherViewSlot = 1, -- During battle, this references which of the other six pokemon [1-6] are being used
		isViewingOwn = true,
		inBattle = false, -- No longer used, doubt it's safe to remove, haven't tested

		hasCheckedSummary = not Options["Hide stats until summary shown"],
		gameStatsHeals = 0, -- Tally of auto-tracked heals, separate to allow manual adjusting of centerHeals
		centerHeals = Utils.inlineIf(Options["PC heals count downward"], 10, 0),
		-- items = {}, -- Currently unused. If plans to use, this would instead be stored under allPokemon tracked data
		healingItems = {
			healing = 0,
			numHeals = 0,
		},
		hiddenPowers = { -- Track hidden power types for each of your own Pokemon [personality] = [type]
			[0] = MoveData.HiddenPowerTypeList[1],
		},
		encounterTable = { -- key: mapId, value: lookup table with key for terrain type and value of unique pokemonIDs
		},
		gameStatsFishing = Utils.getGameStat(Constants.GAME_STATS.FISHING_CAPTURES), -- Tally of fishing encounters, to track when one occurs
		gameStatsRockSmash = Utils.getGameStat(Constants.GAME_STATS.USED_ROCK_SMASH), -- Tally of rock smash uses, to track encounters
		isNewGame = true, -- Flag for new game, to check if stored trainerID is correct
		whichRival = nil, -- To determine which rival the player will fight through the entire game, based on starter ball selection
	}
end

function Tracker.saveData(filename)
	filename = filename or GameSettings.getTrackerAutoSaveName()
	FileManager.writeTableToFile(Tracker.Data, filename)
end

-- Attempts to load Tracked data from the file 'filepath', returns true if successful or no matching data found (resets tracked data)
-- If forced=true, it forcibly applies the Tracked data even if the game it was saved for doesn't match the game being played (rarely, if ever, use this)
function Tracker.loadData(filepath, forced)
	-- Loose safety check to ensure a valid data file is loaded
	filepath = filepath or GameSettings.getTrackerAutoSaveName()
	if filepath:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
		Main.DisplayError("Invalid file selected.\n\nPlease select a TDAT file to load tracker data.")
		return false, string.format("ERROR: TDAT file, %s: %s", Tracker.LoadStatusMessages.unableLoadFile, filepath)
	end

	local fileData = FileManager.readTableFromFile(filepath)
	if fileData == nil then
		return false, string.format("ERROR: %s: %s", Tracker.LoadStatusMessages.unableLoadFile, filepath)
	end

	-- Initialize empty Tracker data, to potentially populate with data from .TDAT save file
	Tracker.resetData()

	-- If the loaded data's romHash doesn't match this current game exactly, use the empty data; otherwise use the loaded data
	if not forced and (fileData.romHash == nil or fileData.romHash ~= Tracker.Data.romHash) then
		Tracker.DataMessage = Tracker.LoadStatusMessages.newGame
		return true, Tracker.DataMessage
	end

	for k, v in pairs(fileData) do
		-- Only add data elements if the current Tracker data schema uses it
		if Tracker.Data[k] ~= nil then
			Tracker.Data[k] = v
		end
	end

	-- Removing for now as the name wasn't really helpful and I wanted a more clear message
	-- local fileNameIndex = string.match(filepath, "^.*()" .. FileManager.slash)
	-- local newFilename = string.sub(filepath, (fileNameIndex or 0) + 1) or ""
	Tracker.DataMessage = Tracker.LoadStatusMessages.fromFile --.. Utils.inlineIf(newFilename ~= "", ": " .. newFilename, "")
	return true, Tracker.DataMessage
end

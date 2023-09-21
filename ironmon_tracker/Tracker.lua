Tracker = {}
Tracker.Data = {}
Tracker.DataMessage = "" -- Used for StartupScreen to display info about tracked data loaded

-- Dual-purpose enum to determine the status of the tracked data loaded on startup and refernece the relevant Resource key
Tracker.LoadStatusKeys = {
	NEW_GAME = "TrackedDataMsgNewGame",
	LOAD_SUCCESS = "TrackedDataMsgLoadSuccess",
	AUTO_DISABLED = "TrackedDataMsgAutoDisabled",
	ERROR = "TrackedDataMsgError",
}
Tracker.LoadStatus = nil

function Tracker.initialize()
	-- First create a default, non-nil Tracker Data
	Tracker.resetData()

	-- Then attempt to load in data from autosave TDAT file
	if Options["Auto save tracked game data"] then
		local filepath = FileManager.prependDir(GameSettings.getTrackerAutoSaveName())
		local loadStatus = Tracker.loadData(filepath)

		-- If the autosave file doesn't exist, then this is a new game
		if loadStatus == Tracker.LoadStatusKeys.ERROR then
			Tracker.LoadStatus = Tracker.LoadStatusKeys.NEW_GAME
		end
	else
		Tracker.LoadStatus = Tracker.LoadStatusKeys.AUTO_DISABLED
	end
end

function Tracker.getPokemon(slotNumber, isOwn, excludeEggs)
	slotNumber = slotNumber or 1
	isOwn = isOwn ~= false -- default to true
	excludeEggs = excludeEggs ~= false -- default to true

	local team = isOwn and Program.GameData.PlayerTeam or Program.GameData.EnemyTeam
	local pokemon = team[slotNumber]
	if pokemon == nil then
		return nil
	end
	-- Personality of 0 is okay for some real trainers, usually occurs in Battle
	if pokemon.personality == 0 and (pokemon.trainerID or 0) == 0 then
		return nil
	end

	-- Return Ghost dummy instead of showing the hidden mon's data, but still show its level
	if not isOwn and Battle.isGhost then
		local retPokemon = Tracker.getGhostPokemon()
		retPokemon.level = pokemon.level
		return retPokemon
	end

	-- Try and find another Pokemon on the team that isn't an egg
	if isOwn and excludeEggs and pokemon.isEgg == 1 then
		local nextSlot = (slotNumber % 6) + 1
		for _ = 1, 6, 1 do
			pokemon = team[nextSlot]
			if pokemon and pokemon.personality ~= 0 and pokemon.isEgg ~= 1 then
				return pokemon
			end
			nextSlot = (nextSlot % 6) + 1
		end
	end

	return pokemon
end

function Tracker.getViewedPokemon()
	if not Program.isValidMapLocation() then return nil end

	local mustViewOwn = Battle.isViewingOwn or not Battle.canViewEnemy()
	local viewSlot
	if mustViewOwn then
		viewSlot = Utils.inlineIf(Battle.isViewingLeft, Battle.Combatants.LeftOwn, Battle.Combatants.RightOwn)
	else
		viewSlot = Utils.inlineIf(Battle.isViewingLeft, Battle.Combatants.LeftOther, Battle.Combatants.RightOther)
	end

	return Tracker.getPokemon(viewSlot, mustViewOwn)
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
		trackedPokemon.statmarkings = {}
	end
	trackedPokemon.statmarkings[statStage] = statState
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
	local route = Tracker.Data.encounterTable[mapId]

	if route[encounterArea] == nil then
		route[encounterArea] = { pokemonID }
	else
		-- Don't insert into tracked mons if it's already there
		for _, encounterID in pairs(route[encounterArea]) do
			if pokemonID == encounterID then
				return
			end
		end
		table.insert(route[encounterArea], pokemonID)
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

-- Currently unused
function Tracker.isTrackingMove(pokemonID, moveId, level)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	for _, move in ipairs(trackedPokemon.moves or {}) do -- intentionally check ALL tracked moves
		-- If the move doesn't provide any new information, consider it tracked
		if moveId == move.id and level >= move.level then
			return true
		end
	end
	return false
end

--- @param trainerId number The trainerId to check if it's a rival
function Tracker.tryTrackWhichRival(trainerId)
	if trainerId == 0 or Tracker.Data.whichRival ~= nil then return end

	local trainerData = TrainerData.getTrainerInfo(trainerId) or {}
	if trainerData.whichRival ~= nil then -- verify this trainer is a rival trainer
		Tracker.Data.whichRival = trainerData.whichRival
	end
end

-- If the Pokemon is being tracked, return information on moves; otherwise default move values = 1
function Tracker.getMoves(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	return trackedPokemon.moves or {
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
	}
end

-- If the Pokemon is being tracked, return information on abilities; otherwise a default ability values = 0
function Tracker.getAbilities(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	return trackedPokemon.abilities or {
		{ id = 0 },
		{ id = 0 },
	}
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
	local markings = trackedPokemon.statmarkings or {}
	return {
		hp = markings.hp or 0,
		atk = markings.atk or 0,
		def = markings.def or 0,
		spa = markings.spa or 0,
		spd = markings.spd or 0,
		spe = markings.spe or 0,
	}
end

-- If the Pokemon is being tracked, return its encounter count; otherwise default encounter values = 0
function Tracker.getEncounters(pokemonID, isWild)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	local encounters = trackedPokemon.encounters or {}
	if isWild then
		return encounters.wild or 0
	else
		return encounters.trainer or 0
	end
end

function Tracker.getRouteEncounters(mapId, encounterArea)
	local location = Tracker.Data.encounterTable[mapId or false] or {}
	return location[encounterArea or false] or {}
end

-- If the Pokemon is being tracked, return its note; otherwise default note value = ""
function Tracker.getNote(pokemonID)
	if pokemonID == 413 then -- Ghost
		return "Spoooky!"
	end
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	return trackedPokemon.note or ""
end

-- If the viewed Pokemon has the move "Hidden Power" (id=237), return it's tracked type; otherwise default type value = NORMAL
function Tracker.getHiddenPowerType()
	local viewedPokemon = Battle.getViewedPokemon(true) or Tracker.getDefaultPokemon()
	return Tracker.Data.hiddenPowers[viewedPokemon.personality or 0] or MoveData.HiddenPowerTypeList[1]
end

-- Note the last level seen of each Pokemon on the enemy team
function Tracker.recordLastLevelsSeen()
	for _, pokemon in pairs(Program.GameData.EnemyTeam) do
		if pokemon.level > 0 and pokemon.level <= 100 then
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
	local encounters = trackedPokemon.encounters or {}
	return encounters.lastlevel
end

function Tracker.getDefaultPokemon()
	return {
		pokemonID = 0,
		name = Constants.BLANKLINE,
		nickname = Constants.BLANKLINE,
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
	Tracker.Data = {
		version = Main.TrackerVersion,
		romHash = GameSettings.getRomHash(),
		-- The player's visible trainerID
		trainerID = 0,
		-- Used to track information about all pokemon seen thus far
		allPokemon = {},
		hasCheckedSummary = not Options["Hide stats until summary shown"],
		-- Tally of auto-tracked heals, separate to allow manual adjusting of centerHeals
		gameStatsHeals = 0,
		centerHeals = Utils.inlineIf(Options["PC heals count downward"], 10, 0),
		-- Track hidden power types for each of your own Pokemon [personality] = [type]
		hiddenPowers = {
			[0] = MoveData.HiddenPowerTypeList[1],
		},
		-- [mapId:number] = encounterArea:table (lookup table with key for terrain type and a list of unique pokemonIDs)
		encounterTable = {},
		-- Tally of fishing encounters, to track when one occurs
		gameStatsFishing = Utils.getGameStat(Constants.GAME_STATS.FISHING_CAPTURES),
		-- Tally of rock smash uses, to track encounters
		gameStatsRockSmash = Utils.getGameStat(Constants.GAME_STATS.USED_ROCK_SMASH),
		-- Flag for new game, to check if stored trainerID is correct
		isNewGame = true,
		-- To determine which rival the player will fight through the entire game, based on starter ball selection
		whichRival = nil,
		-- Number of seconds
		playtime = 0,
	}
end

function Tracker.saveData(filename)
	filename = filename or GameSettings.getTrackerAutoSaveName()
	FileManager.writeTableToFile(Tracker.Data, filename)
end

-- Attempts to load Tracked data from the file 'filepath', sets and returns 'Tracker.LoadStatus' to a status from 'Tracker.LoadStatusKeys'
-- If forced=true, it forcibly applies the Tracked data even if the game it was saved for doesn't match the game being played (rarely, if ever, use this)
function Tracker.loadData(filepath, forced)
	-- Loose safety check to ensure a valid data file is loaded
	filepath = filepath or GameSettings.getTrackerAutoSaveName()
	if filepath:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
		Tracker.LoadStatus = Tracker.LoadStatusKeys.ERROR
		Main.DisplayError("Invalid file selected.\n\nPlease select a TDAT file to load tracker data.")
		return Tracker.LoadStatus
	end

	local fileData = FileManager.readTableFromFile(filepath)
	if fileData == nil then
		Tracker.LoadStatus = Tracker.LoadStatusKeys.ERROR
		return Tracker.LoadStatus
	end

	-- Initialize empty Tracker data, to potentially populate with data from .TDAT save file
	Tracker.resetData()

	-- If the loaded data's romHash doesn't match this current game exactly, use the empty data; otherwise use the loaded data
	if not forced and (fileData.romHash == nil or fileData.romHash ~= Tracker.Data.romHash) then
		Tracker.LoadStatus = Tracker.LoadStatusKeys.NEW_GAME
		return Tracker.LoadStatus
	end

	-- Don't replace some data
	local dontOverwrite = {
		version = true,
		romHash = true,
		trainerID = true,
	}
	for k, v in pairs(fileData) do
		-- Only add data elements if the current Tracker data schema uses it
		if Tracker.Data[k] ~= nil and not dontOverwrite[k] then
			Tracker.Data[k] = v
		end
	end

	Tracker.LoadStatus = Tracker.LoadStatusKeys.LOAD_SUCCESS
	return Tracker.LoadStatus
end

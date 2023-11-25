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

Tracker.DefaultData = {
	-- NOTE: These root attributes cannot be nil, or they won't be loaded from the TDAT file
	-- The version number of the Ironmon Tracker
	version = "1.0.0",
	-- The ROM Hash is used to uniquely identify this game from others
	romHash = "",
	-- The player's visible trainerID
	trainerID = 0,
	-- Flag for new game, to check if stored trainerID is correct
	isNewGame = true,
	-- Track if the player has checked the Summary for their active Pokémon
	hasCheckedSummary = true,
	-- To determine which rival the player will fight through the entire game, based on starter ball selection
	whichRival = "",
	-- Number of seconds of playtime for this play session
	playtime = 0,
	-- Used to track information about all Pokémon seen thus far
	allPokemon = {},
	-- [mapId:number] = encounterArea:table (lookup table with key for terrain type and a list of unique pokemonIDs)
	encounterTable = {},
	-- Track Hidden Power types for each of the player's own Pokémon [personality] = [movetype]
	hiddenPowers = {},
	-- Track the PC Heals shown on screen (manually set or automated)
	centerHeals = 0,
	-- Tally of auto-tracked heals, separate to allow manual adjusting of centerHeals
	gameStatsHeals = 0,
	-- Tally of fishing encounters, to track when one occurs
	gameStatsFishing = 0,
	-- Tally of rock smash uses, to track encounters
	gameStatsRockSmash = 0,
}

function Tracker.DefaultData:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Add compatibility for deprecated attributes
local mt = {}
setmetatable(Tracker.DefaultData, mt)
mt.__index = function(_, key)
	if key == "isViewingOwn" then
		return Battle.isViewingOwn
	end
end

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

--- @param slotNumber number Which party slot (1-6) to get
--- @param isOwn boolean True for the Player's team, false for the Enemy Trainer's team
--- @param excludeEggs boolean? (Optional) If true, avoid Pokémon that are eggs; default=true
--- @return table? pokemon All of the game data known about this Pokémon; nil if it doesn't exist
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

	local mustViewOwn = Battle.isViewingOwn or not Battle.inActiveBattle()
	local viewSlot
	if mustViewOwn then
		viewSlot = Utils.inlineIf(Battle.isViewingLeft, Battle.Combatants.LeftOwn, Battle.Combatants.RightOwn)
	else
		viewSlot = Utils.inlineIf(Battle.isViewingLeft, Battle.Combatants.LeftOther, Battle.Combatants.RightOther)
	end

	return Tracker.getPokemon(viewSlot, mustViewOwn)
end

--- @param pokemonID number
--- @param createIfDoesntExist boolean? (Optional) If true, will create a tracked Pokémon data entry (default=true)
--- @return table trackedPokemon A table containing information about this tracked Pokémon (empty if it's not being tracked)
function Tracker.getOrCreateTrackedPokemon(pokemonID, createIfDoesntExist)
	if not PokemonData.isValid(pokemonID) then return {} end -- Don't store tracked data for a non-existent pokemon data
	if Tracker.Data.allPokemon[pokemonID] == nil and createIfDoesntExist ~= false then
		Tracker.Data.allPokemon[pokemonID] = {}
	end
	return Tracker.Data.allPokemon[pokemonID] or {}
end

--- Adds the Pokemon's ability to the tracked data if it doesn't exist, otherwise updates it.
--- @param pokemonID number
--- @param abilityId number
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
	if (trackedPokemon.abilities[1].id or 0) == 0 then
		trackedPokemon.abilities[1].id = abilityId
	elseif ((trackedPokemon.abilities[2].id or 0) == 0) and trackedPokemon.abilities[1].id ~= abilityId then
		trackedPokemon.abilities[2].id = abilityId
	end
	-- If this pokemon already has two abilities being tracked, simply do nothing.
end

--- @param pokemonID number
--- @param statStage string One of the six stats
--- @param statState number The marking for this stat
function Tracker.TrackStatMarking(pokemonID, statStage, statState)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if trackedPokemon.sm == nil then
		trackedPokemon.sm = {}
	end
	trackedPokemon.sm[statStage] = statState
end

--- Adds the Pokemon's move to the tracked data if it doesn't exist, otherwise updates it.
--- Also tracks the minimum and maximum level of the Pokemon that used the move
--- @param pokemonID number
--- @param moveId number
--- @param level number
function Tracker.TrackMove(pokemonID, moveId, level)
	if not MoveData.isValid(moveId) or moveId == 165 then -- 165 = Struggle
		return
	end

	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)

	-- If no move data exist, set this as the first move
	if trackedPokemon.moves == nil then
		trackedPokemon.moves = {
			{ id = moveId, level = level, minLv = level, maxLv = level, },
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
	if not moveSeen then
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

--- @param pokemonID number
--- @param isWild boolean
function Tracker.TrackEncounter(pokemonID, isWild)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if isWild then
		trackedPokemon.eW = (trackedPokemon.eW or 0) + 1
	else
		trackedPokemon.eT = (trackedPokemon.eT or 0) + 1
	end
end

--- @param mapId number
--- @param encounterArea string The RouteData.EncounterArea
--- @param pokemonID number
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

--- @param pokemonID number
--- @param note string
function Tracker.TrackNote(pokemonID, note)
	if note == nil then return end
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	trackedPokemon.note = note
end

--- @param personality number
--- @param moveType string A move type from MoveData.HiddenPowerTypeList
function Tracker.TrackHiddenPowerType(personality, moveType)
	if personality == nil or moveType == nil or personality == 0 then return end
	Tracker.Data.hiddenPowers[personality] = moveType
end

-- Currently unused
function Tracker.isTrackingMove(pokemonID, moveId, level)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
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
	-- Skip setting the rival info if it's already set
	if trainerId == 0 or Tracker.getWhichRival() ~= nil then return end

	local trainerData = TrainerData.getTrainerInfo(trainerId) or {}
	if trainerData.whichRival ~= nil then -- verify this trainer is a rival trainer
		Tracker.Data.whichRival = trainerData.whichRival
	end
end

--- Returns info on which Rival the player is fighting throughout the game. If not set, returns nil
--- @return string? nameAndDirection FRLG: "Left/Middle/Right", RSE: "TrainerName Left/Middle/Right"
function Tracker.getWhichRival()
	if Utils.isNilOrEmpty(Tracker.Data.whichRival) then
		return nil
	else
		return Tracker.Data.whichRival
	end
end

-- If the Pokemon is being tracked, return information on moves; otherwise default move values = 1
--- @param pokemonID number
--- @return table moves A table of moves for the Pokémon; each has an id, level, and pp value
function Tracker.getMoves(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	return trackedPokemon.moves or {}
end

-- If the Pokemon is being tracked, return information on abilities; otherwise a default ability values = 0
--- @param pokemonID number
--- @return table abilities
function Tracker.getAbilities(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	return trackedPokemon.abilities or {
		{ id = 0 },
		{ id = 0 },
	}
end

--- @param pokemonID number
--- @param abilityOneText string
--- @param abilityTwoText string
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

--- If the Pokemon is being tracked, return information on statmarkings; otherwise default stat values = 1
--- @param pokemonID number
--- @return table statMarkings A table containing markings for all six stats
function Tracker.getStatMarkings(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	local markings = trackedPokemon.sm or {}
	return {
		hp = markings.hp or 0,
		atk = markings.atk or 0,
		def = markings.def or 0,
		spa = markings.spa or 0,
		spd = markings.spd or 0,
		spe = markings.spe or 0,
	}
end

--- If the Pokemon is being tracked, return its encounter count; otherwise default encounter values = 0
--- @param pokemonID number
--- @param isWild boolean
--- @return number
function Tracker.getEncounters(pokemonID, isWild)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	if isWild then
		return trackedPokemon.eW or 0
	else
		return trackedPokemon.eT or 0
	end
end

--- @param mapId number
--- @param encounterArea string The RouteData.EncounterArea
--- @return table
function Tracker.getRouteEncounters(mapId, encounterArea)
	local location = Tracker.Data.encounterTable[mapId or false] or {}
	return location[encounterArea or false] or {}
end

--- If the Pokemon is being tracked, return its note; otherwise default note value = ""
--- @param pokemonID number
--- @return string
function Tracker.getNote(pokemonID)
	if pokemonID == 413 then -- Ghost
		return "Spoooky!"
	end
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	return trackedPokemon.note or ""
end

--- If the Pokemon has the move "Hidden Power" (id=237), return it's tracked type (if set); otherwise default type value = unknown
--- @param pokemon table? (Optional) The Pokemon data object to use for checking if hidden power type is tracked; default: currently viewed mon
--- @return string
function Tracker.getHiddenPowerType(pokemon)
	pokemon = pokemon or Battle.getViewedPokemon(true) or {}
	if (pokemon.personality or 0) == 0 then
		return MoveData.HIDDEN_POWER_NOT_SET
	end
	return Tracker.Data.hiddenPowers[pokemon.personality] or MoveData.HIDDEN_POWER_NOT_SET
end

--- Note the last level seen of each Pokemon on the enemy team
function Tracker.recordLastLevelsSeen()
	for _, pokemon in pairs(Program.GameData.EnemyTeam) do
		if pokemon.level > 0 and pokemon.level <= 100 then
			local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemon.pokemonID)
			trackedPokemon.eL = pokemon.level
		end
	end
end

--- Returns the level of the Pokemon last time it was seen; returns nil if never seen before
--- @param pokemonID number
--- @return number?
function Tracker.getLastLevelSeen(pokemonID)
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	return trackedPokemon.eL
end

--- @return table pokemon An empty set of Pokémon game data merged with internal blank PokemonData
function Tracker.getDefaultPokemon()
	return Program.DefaultPokemon:new({
		name = PokemonData.BlankPokemon.name,
		nickname = PokemonData.BlankPokemon.name,
		types = { PokemonData.BlankPokemon.types[1], PokemonData.BlankPokemon.types[2] },
		abilities = { PokemonData.BlankPokemon.abilities[1], PokemonData.BlankPokemon.abilities[2] },
		evolution = PokemonData.BlankPokemon.evolution,
		bst = PokemonData.BlankPokemon.bst,
		movelvls = { {}, {} },
		weight = PokemonData.BlankPokemon.weight,
	})
end

--- @return table pokemon A mostly empty set of Pokémon game data, with some info hidden because it's the story ghost encounter
function Tracker.getGhostPokemon()
	local defaultPokemon = Tracker.getDefaultPokemon()
	defaultPokemon.pokemonID = 413
	defaultPokemon.name = Resources.TrackerScreen.UnidentifiedGhost or "Ghost"
	defaultPokemon.types = { PokemonData.Types.UNKNOWN, PokemonData.Types.UNKNOWN }
	return defaultPokemon
end

function Tracker.resetData()
	Tracker.Data = Tracker.DefaultData:new({
		version = Main.TrackerVersion,
		romHash = GameSettings.getRomHash(),
		allPokemon = {},
		encounterTable = {},
		hiddenPowers = {},
		hasCheckedSummary = not Options["Hide stats until summary shown"],
		centerHeals = Options["PC heals count downward"] and 10 or 0,
		gameStatsFishing = Utils.getGameStat(Constants.GAME_STATS.FISHING_CAPTURES),
		gameStatsRockSmash = Utils.getGameStat(Constants.GAME_STATS.USED_ROCK_SMASH),
	})
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
		isViewingOwn = true,
	}
	for k, v in pairs(fileData) do
		-- Only add data elements if the current Tracker data schema uses it
		if Tracker.Data[k] ~= nil and not dontOverwrite[k] then
			Tracker.Data[k] = v
		end
	end
	Tracker.checkForLegacyTrackedData(fileData)

	Tracker.LoadStatus = Tracker.LoadStatusKeys.LOAD_SUCCESS
	return Tracker.LoadStatus
end

--- Verifies the current Tracker.Data is accurate for this current game, based on the player's in-game TrainerID
--- @param playerTrainerId number The game's trainerID assigned to the player
function Tracker.verifyDataForPlayer(playerTrainerId)
	-- The player won't have a trainerID until they get their first Pokmon
	if not Tracker.Data.isNewGame or (playerTrainerId or 0) == 0 then
		return
	end
	-- Unset the new game flag
	Tracker.Data.isNewGame = false
	if Tracker.Data.trainerID == nil or Tracker.Data.trainerID == 0 then
		Tracker.Data.trainerID = playerTrainerId
	elseif Tracker.Data.trainerID ~= playerTrainerId then
		-- Reset the tracker data as old data was loaded and we have a different trainerID now
		print("Old/Incorrect data was detected for this ROM. Initializing new data.")
		local playtime = Tracker.Data.playtime
		Tracker.resetData()
		Tracker.Data.trainerID = playerTrainerId
		Tracker.Data.playtime = playtime
	end
end

-- If the Tracker version of the imported data is older, check for legacy data and properly import it
function Tracker.checkForLegacyTrackedData(data)
	if not Utils.isNewerVersion(Main.TrackerVersion, data.version) then
		return
	end

	-- [v8.3.0-] Changes to tracked pokemon info
	for pokemonID, info in pairs(data.allPokemon or {}) do
		local pokemonInternal = Tracker.Data.allPokemon[pokemonID]
		-- The 'encounters' table has been unpacked into individual values
		if type(info.encounters) == "table" then
			pokemonInternal.eW = info.encounters.wild or 0
			pokemonInternal.eT = info.encounters.trainer or 0
			pokemonInternal.eL = info.encounters.lastlevel or 0
			pokemonInternal.encounters = nil
			-- Old data stored 0's when it was just wasted storage space
			if pokemonInternal.eW == 0 then
				pokemonInternal.eW = nil
			end
			if pokemonInternal.eT == 0 then
				pokemonInternal.eT = nil
			end
			if pokemonInternal.eL == 0 then
				pokemonInternal.eL = nil
			end
		end
		-- 'statmarkings' renamed to 'sm'
		if type(info.statmarkings) == "table" then
			pokemonInternal.sm = info.statmarkings
			pokemonInternal.statmarkings = nil
		end
		-- Remove any empty tracked move entries (id = 0)
		if type(pokemonInternal.moves) == "table" then
			for j = #pokemonInternal.moves, 1, -1 do
				local move = pokemonInternal.moves[j] or {}
				if not MoveData.isValid(move.id) then
					table.remove(pokemonInternal.moves, j)
				end
			end
		end
	end
end
Tracker = {}

-- Dual-purpose enum to determine the status of the tracked data loaded on startup and refernece the relevant Resource key
Tracker.LoadStatusKeys = {
	NEW_GAME = "TrackedDataMsgNewGame",
	LOAD_SUCCESS = "TrackedDataMsgLoadSuccess",
	AUTO_DISABLED = "TrackedDataMsgAutoDisabled",
	ERROR = "TrackedDataMsgError",
}
Tracker.LoadStatus = Tracker.LoadStatusKeys.NEW_GAME

-- Holds temporary notes for the current battle only
Tracker.BattleNotes = {
	MovesByPokemonAndLevel = {
		-- [number: an id & level pair] = { [number:moveId1] = {}, [number:moveId2] = {}, ... }
	},
	FourMovesIfAllKnown = {
		-- [number: an id & level pair] = {list of all four known moves}
	},
}

---@class ITrackedData
Tracker.DefaultData = {
	-- NOTE: These root attributes cannot be nil, or they won't be loaded from the TDAT file
	-- The version number of the Ironmon Tracker
	version = "0.0.0",
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
	allPokemon = {
		-- moves = {}, -- table: Moves (size N)
		-- abilities = {}, -- table: Abilities (size 2)
		-- sm = {}, -- table: Stat Markings (size 6)
		-- eW = 0, -- number: Wild Encounter count
		-- eT = 0, -- number: Trainer Encounters count
		-- eL = 0, -- number: Last level seen
		-- note = "", -- string: A note written by the user
	},
	-- [mapId:number] = encounterArea:table (lookup table with key for terrain type and a list of unique pokemonIDs)
	encounterTable = {},
	-- [mapId] = {{pID=#, lv=#}, ...} List of pokemon encounters for the whole area; stores both pokemonIDs & highest level encountered
	safariEncounters = {},
	-- Track Hidden Power types for each of the player's own Pokémon [personality] = [movetype]
	hiddenPowers = {},
	-- performs a 1-time automatic tracking of active pokemon used in trainer battles; [personality] = true
	initialMoveset = {},
	-- Track the PC Heals shown on screen (manually set or automated)
	centerHeals = 0,
	-- Tally of auto-tracked heals, separate to allow manual adjusting of centerHeals
	gameStatsHeals = 0,
	-- Tally of fishing encounters, to track when one occurs
	gameStatsFishing = 0,
	-- Tally of rock smash uses, to track encounters
	gameStatsRockSmash = 0,
}

---Returns a new instance of `ITrackedData`
---@param o? table
---@return ITrackedData
function Tracker.DefaultData:new(o)
	o = o or {}
	o.allPokemon = o.allPokemon or {}
	o.encounterTable = o.encounterTable or {}
	o.safariEncounters = o.safariEncounters or {}
	o.hiddenPowers = o.hiddenPowers or {}
	o.initialMoveset = o.initialMoveset or {}
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

Tracker.Data = Tracker.DefaultData:new()
Tracker.DataMessage = "" -- Used for StartupScreen to display info about tracked data loaded

function Tracker.initialize()
	Tracker.resetData()
	Tracker.resetBattleNotes()
	Tracker.AutoSave.reset()
end

--- @param slotNumber number Which party slot (1-6) to get
--- @param isOwn boolean? (Optional) True for the Player's team, false for the Enemy Trainer's team; default=true
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

---Returns the currently viewed Pokémon (what's displayed on the Tracker Screen)
---@return table|nil pokemon A `Program.DefaultPokemon` data object
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

--- @param mapId number
--- @param pokemonID number
--- @param level number
function Tracker.TrackSafariEncounter(mapId, pokemonID, level)
	if Tracker.Data.safariEncounters[mapId] == nil then
		Tracker.Data.safariEncounters[mapId] = {}
	end
	local route = Tracker.Data.safariEncounters[mapId]
	local foundIndex
	for i, idAndLevelPair in ipairs(route) do
		if idAndLevelPair.pID == pokemonID then
			foundIndex = i
			break
		end
	end
	-- Add to route if new, otherwise check if level is higher
	if not foundIndex then
		table.insert(route, { pID = pokemonID, lv = level })
	else
		if level > route[foundIndex].lv then
			route[foundIndex].lv = level
		end
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

--- Performs a 1-time tracking of the pokemon's current movesset, and of the pokemon's level-up moves
--- @param pokemon table -- a `Program.DefaultPokemon` object
function Tracker.tryTrackInitialMoveset(pokemon)
	if (pokemon.personality or 0) == 0 or Tracker.Data.initialMoveset[pokemon.personality] then
		return
	end
	Tracker.Data.initialMoveset[pokemon.personality] = true

	-- Only track a pokemon's move if it could have naturally learned it
	local learnedMoves = PokemonData.readLevelUpMoves(pokemon.pokemonID)
	for _, move in ipairs(pokemon.moves or {}) do
		for _, learnedMove in ipairs(learnedMoves or {}) do
			if move.id and move.id == learnedMove.id and learnedMove.level <= pokemon.level then
				Tracker.TrackMove(pokemon.pokemonID, learnedMove.id, learnedMove.level)
				break
			end
		end
	end
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
--- @param level? number Optional, if level is provided and ALL 4 moves of an enemy Pokémon were used in battle, return those moves
--- @return table moves A table of moves for the Pokémon; each has an id, level, and pp value
function Tracker.getMoves(pokemonID, level)
	-- Show all four known moves if they were all used in the current battle, instead of the loose tracked list of moves that are out of order
	if level and Battle.inActiveBattle() and not Battle.isViewingOwn then
		local monLvIndex = pokemonID * 1000 + level
		if Tracker.BattleNotes.FourMovesIfAllKnown[monLvIndex] then
			return Tracker.BattleNotes.FourMovesIfAllKnown[monLvIndex]
		end
	end
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

--- @param mapId number
--- @return table
function Tracker.getSafariEncounters(mapId)
	return Tracker.Data.safariEncounters[mapId or false] or {}
end

--- If the Pokemon is being tracked, return its note; otherwise default note value = ""
--- @param pokemonID number
--- @return string
function Tracker.getNote(pokemonID)
	if pokemonID == PokemonData.Values.GhostId then
		return "Spoooky!"
	end
	local trackedPokemon = Tracker.getOrCreateTrackedPokemon(pokemonID, false)
	return trackedPokemon.note or ""
end

--- If the Pokemon has the move "Hidden Power", return it's tracked type (if set); otherwise default type value = unknown
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
	defaultPokemon.pokemonID = PokemonData.Values.GhostId
	defaultPokemon.name = Resources.TrackerScreen.UnidentifiedGhost or "Ghost"
	defaultPokemon.types = { PokemonData.Types.UNKNOWN, PokemonData.Types.UNKNOWN }
	return defaultPokemon
end

function Tracker.resetData()
	Tracker.Data = Tracker.DefaultData:new({
		version = Main.TrackerVersion,
		romHash = GameSettings.getRomHash(),
		hasCheckedSummary = not Options["Hide stats until summary shown"],
		centerHeals = Options["PC heals count downward"] and 10 or 0,
		gameStatsFishing = Utils.getGameStat(Constants.GAME_STATS.FISHING_CAPTURES),
		gameStatsRockSmash = Utils.getGameStat(Constants.GAME_STATS.USED_ROCK_SMASH),
	})
	Tracker.LoadStatus = Tracker.LoadStatusKeys.NEW_GAME
end

---Resets any recorded information that is temporarily noted for the current battle
function Tracker.resetBattleNotes()
	Tracker.BattleNotes = {
		MovesByPokemonAndLevel = {},
		FourMovesIfAllKnown = {},
	}
end

---Records/saves info about a move used by an [enemy] pokemon in battle, temporarily, for the current battle.
---@param pokemonID any
---@param moveId any
---@param level any
function Tracker.recordBattleMoveByPokemonLevel(pokemonID, moveId, level)
	if not PokemonData.isValid(pokemonID) or not MoveData.isValid(moveId) or type(level) ~= "number" or not Battle.inActiveBattle() then
		return
	end
	-- Store known/used moves with a key formed by the id & level pair
	local monLvIndex = pokemonID * 1000 + level
	local _moves = Tracker.BattleNotes.MovesByPokemonAndLevel
	if not _moves[monLvIndex] then
		_moves[monLvIndex] = {}
	end
	-- Check if already noted
	if _moves[monLvIndex][moveId] or Tracker.BattleNotes.FourMovesIfAllKnown[monLvIndex] then
		return
	end

	-- Record the known move in the notes
	_moves[monLvIndex][moveId] = { id = moveId, level = level, minLv = level, maxLv = level, }

	local knownMoves = {}
	for _, move in pairs(_moves[monLvIndex]) do
		table.insert(knownMoves, move)
	end
	if #knownMoves == 4 then
		Tracker.BattleNotes.FourMovesIfAllKnown[monLvIndex] = knownMoves
	end
end

---Saves the Tracker Data (TDAT) to a file
---@param filepath? string Optional, the filepath that the TDAT file will be saved to; defaults to selected New Run game profile
function Tracker.saveData(filepath)
	filepath = filepath or QuickloadScreen.getGameProfileTdatPath()
	FileManager.writeTableToFile(Tracker.Data, filepath)
end

---Saves the Tracker Data (TDAT) to a file specified by `filepath`
---@param filename string The filename that the TDAT file will be saved-as
function Tracker.saveDataAsCopy(filename)
	if Utils.isNilOrEmpty(filename) then
		return
	end
	local path = FileManager.getTdatFolderPath() .. filename
	FileManager.writeTableToFile(Tracker.Data, path)
end

---Loads the Tracker Data (TDAT) from a file specified by `filepath`, with option to `overwrite`
---@param filepath? string Optional, the filepath that the TDAT file will be loaded from; defaults to selected New Run game profile
---@param overwrite? boolean Optional, if true will forcibly overwrite currently loaded data with new data; default: false
---@return string loadStatus The `Tracker.LoadStatus` string, respresenting one of `Tracker.LoadStatusKeys`
function Tracker.loadData(filepath, overwrite)
	filepath = filepath or QuickloadScreen.getGameProfileTdatPath()
	overwrite = overwrite == true -- Defaults to false

	-- Loose safety check to ensure a valid data file is loaded
	local fileExtension = FileManager.extractFileExtensionFromPath(filepath):lower()
	if fileExtension ~= FileManager.Extensions.TRACKED_DATA:sub(2) then -- ignore leading period
		Tracker.LoadStatus = Tracker.LoadStatusKeys.ERROR
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
	local isDifferentRom = Utils.isNilOrEmpty(fileData.romHash) or fileData.romHash ~= GameSettings.getRomHash()
	if not overwrite and isDifferentRom then
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

-- Information about the auto-save data loaded in from the TDAT file
Tracker.AutoSave = {
	-- The filepath location of the TDAT file that is used for auto loading/saving
	Tdat = "",
}

function Tracker.AutoSave.reset()
	Tracker.AutoSave.Tdat = ""
end

function Tracker.AutoSave.isEnabled()
	return Options["Auto save tracked game data"] == true
end

---Automatically saves Tracker data (TDAT); triggers every few minutes and only if game is being played
function Tracker.AutoSave.saveToFile()
	-- Also don't auto save if the game hasn't started being played; nothing to save
	if not Tracker.AutoSave.isEnabled() or TrackerAPI.getPlayerPokemon() == nil then
		return
	end
	if not Utils.isNilOrEmpty(Tracker.AutoSave.Tdat) then
		Tracker.saveData(Tracker.AutoSave.Tdat)
	else
		Tracker.saveData()
	end
end

---Automatically loads Tracker data (TDAT); triggers on startup
function Tracker.AutoSave.loadFromFile()
	if not Tracker.AutoSave.isEnabled() then
		Tracker.LoadStatus = Tracker.LoadStatusKeys.AUTO_DISABLED
		return
	end

	-- TODO: solve issue if no profile exists, user doesnt use New Run (TODO: Test this)

	Tracker.AutoSave.Tdat = QuickloadScreen.getGameProfileTdatPath()
	local fileToLoad = Tracker.AutoSave.Tdat

	-- Fallback to old method of storing TDAT if file isn't there for new method
	local shouldCreateProfileTDAT = false
	if not FileManager.fileExists(fileToLoad) then
		fileToLoad = (FileManager.getPathOverride("Tracker Data") or FileManager.dir) .. GameSettings.getTrackerAutoSaveName()
		-- Require updating the TDAT filename to new method if a profile exists for it
		shouldCreateProfileTDAT = QuickloadScreen.getActiveProfile() ~= nil
	end

	Tracker.loadData(fileToLoad)

	-- If no autosave file could be loaded, then treat this as a new game
	if Tracker.LoadStatus == Tracker.LoadStatusKeys.ERROR then
		Tracker.LoadStatus = Tracker.LoadStatusKeys.NEW_GAME
	end

	-- After the data is loaded, rename the TDAT file if necessary
	if shouldCreateProfileTDAT and FileManager.fileExists(fileToLoad) then
		FileManager.CopyFile(fileToLoad, Tracker.AutoSave.Tdat)
		FileManager.deleteFile(fileToLoad)
	end
end

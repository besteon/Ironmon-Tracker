Tracker = {}

Tracker.userDataKey = "ironmon_tracker_data"

Tracker.controller = {
    statIndex = 1,
    framesSinceInput = 120,
    boxVisibleFrames = 120,
}

-- Data
    -- main
        -- ability
    -- inBattle
    -- currentlyTrackedPokemonMoves
    -- player
    -- slot
    -- moves
        -- pokemon
            -- first
            -- second
            -- third
            -- fourth
    -- stats
        -- pokemon
            -- hp
            -- att
            -- def
            -- spa
            -- spd
            -- spe
Tracker.Data = {}

function Tracker.InitTrackerData()
    local trackerData = {
        selectedPokemon = {},
        main = {
            ability = 0
        },
        inBattle = 0,
        currentlyTrackedPokemonMoves = {
            first = 1,
            second = 1,
            third = 1,
            fouth = 1
        },
        player = 1,
        slot = 1,
        selfSlotOne = 1,
        selfSlotTwo = 1,
        enemySlotOne = 1,
        enemySlotTwo = 1,
        moves = {},
        stats = {}
    }
    return trackerData
end

function Tracker.Clear()
    if userdata.containskey(Tracker.userDataKey) then
        userdata.remove(Tracker.userDataKey)
    end
    Tracker.Data = Tracker.InitTrackerData()
end

function Tracker.TrackMove(pokemonId, moveId)
    local currentMoves = Tracker.Data.moves[pokemonId]
    if currentMoves == nil then
        Tracker.Data.moves[pokemonId] = {}
        Tracker.Data.moves[pokemonId].first = moveId
        Tracker.Data.moves[pokemonId].second = 1
        Tracker.Data.moves[pokemonId].third = 1
        Tracker.Data.moves[pokemonId].fourth = 1
    else
        local moveSeen = false
        local moveCount = 0
        for key, value in pairs(currentMoves) do
            moveCount = moveCount + 1
            if value == moveId then
                moveSeen = true
            end
        end

        if moveSeen == false then
            if moveCount == 1 then
                Tracker.Data.moves[pokemonId].second = moveId
            elseif moveCount == 2 then
                Tracker.Data.moves[pokemonId].third = moveId
            elseif moveCount == 3 then
                Tracker.Data.moves[pokemonId].fourth = moveId
            elseif moveCount == 4 then
                Tracker.Data.moves[pokemonId].fourth = Tracker.Data.moves[pokemonId].third
                Tracker.Data.moves[pokemonId].third = Tracker.Data.moves[pokemonId].second
                Tracker.Data.moves[pokemonId].second = Tracker.Data.moves[pokemonId].first
                Tracker.Data.moves[pokemonId].first = moveId
            end
        end
    end
end

function Tracker.getMoves(pokemonId)
    if Tracker.Data.moves[pokemonId] == nil then
        return {
            first = 1,
            second = 1,
            third = 1,
            fourth = 1
        }
    else
        return Tracker.Data.moves[pokemonId]
    end
end

function Tracker.TrackStatPrediction(pokemonId, stats)
    Tracker.Data.stats[pokemonId] = {}
    Tracker.Data.stats[pokemonId].stats = stats
end

function Tracker.getButtonState()
    if Tracker.Data.stats[Tracker.Data.selectedPokemon.pokemonID] == nil then
        return {
            hp = 1,
            att = 1,
            def = 1,
            spa = 1,
            spd = 1,
            spe = 1
        }
    else
        return Tracker.Data.stats[Tracker.Data.selectedPokemon.pokemonID].stats
    end
end

function Tracker.saveData()
    local dataString = pickle(Tracker.Data)
    userdata.set(Tracker.userDataKey, dataString)
end

-- Data
    -- main
        -- ability
    -- inBattle
    -- currentlyTrackedPokemonMoves
    -- player
    -- slot
    -- moves
        -- pokemon
            -- first
            -- second
            -- third
            -- fourth
    -- stats
        -- pokemon
            -- hp
            -- att
            -- def
            -- spa
            -- spd
            -- spe
function Tracker.loadData()

    if userdata.containskey(Tracker.userDataKey) then
        local serializedTable = userdata.get(Tracker.userDataKey)
        local trackerData = unpickle(serializedTable)
        Tracker.Data = trackerData
    else
        Tracker.Data = Tracker.InitTrackerData()
    end
end
Tracker = {}

Tracker.SQL = {
    DB_FILE = gameinfo.getromname() .. "_ironmon_tracker.db",
    CREATE_MOVES_TABLE = "CREATE TABLE IF NOT EXISTS moves (id INTEGER PRIMARY KEY, pokemon INTEGER NOT NULL, move INTEGER NOT NULL, time INTEGER NOT NULL, UNIQUE(pokemon, move));",
    CREATE_STATS_TABLE = "CREATE TABLE IF NOT EXISTS stats (id INTEGER PRIMARY KEY, pokemon INTEGER NOT NULL, hp INTEGER NOT NULL, att INTEGER NOT NULL, def INTEGER NOT NULL, spa INTEGER NOT NULL, spd INTEGER NOT NULL, spe INTEGER NOT NULL, UNIQUE(pokemon));"
}

function Tracker.initialize()
    SQL.opendatabase(Tracker.SQL.DB_FILE)
    SQL.writecommand(Tracker.SQL.CREATE_MOVES_TABLE)
    SQL.writecommand(Tracker.SQL.CREATE_STATS_TABLE)
end

function Tracker.Clear()
    local clearMoves = "DELETE FROM moves"
    local clearStats = "DELETE FROM stats"
    SQL.writecommand(clearMoves)
    SQL.writecommand(clearStats)
end

function Tracker.TrackMove(pokemonId, moveId)
    local moves = "SELECT move FROM moves WHERE pokemon = " .. pokemonId .. ";"
    if type(moves) == "table" then
        local movesSeen = 0
        for _ in pairs(moves) do movesSeen = movesSeen + 1 end
        if movesSeen > 4 then
            local tryUpdate = "UPDATE moves SET pokemon = " .. pokemonId .. ", move = " .. moveId .. ", time = strftime('%s', 'now') WHERE pokemon = " .. pokemonId .. " AND move = " .. moveId .. ";"
            local update = SQL.writecommand(tryUpdate)
        end
    end

    -- This won't do anything if the move has already been seen due to the UNIQUE constraint
    local cmd = "INSERT INTO moves (pokemon, move, time) VALUES(" .. pokemonId .. "," .. moveId .. ",strftime('%s', 'now'));"
    SQL.writecommand(cmd)
end

function Tracker.GetMoves(pokemonId)
    local cmd = "SELECT move FROM moves WHERE pokemon = " .. pokemonId .. " ORDER BY time DESC LIMIT 4;"
    local moves = SQL.readcommand(cmd)
    return moves
end

function Tracker.UpdateStatButtonState(pokemonId, stats)
    local insertOrReplace = "INSERT OR REPLACE INTO stats (pokemon, hp, att, def, spa, spd, spe) VALUES(" .. pokemonId .. "," .. stats.hp .. "," .. stats.att .. "," .. stats.def .. "," .. stats.spa .. "," .. stats.spd .. "," .. stats.spe .. ");"
    SQL.writecommand(insertOrReplace)
end

function Tracker.getButtonState()
    local cmd = "SELECT hp, att, def, spa, spd, spe FROM stats WHERE pokemon = " .. Program.selectedPokemon.pokemonID .. " LIMIT 1;"
    local stats = SQL.readcommand(cmd)
    if type(stats) == "table" then
        local newStats = {
            hp = stats["hp 0"],
            att = stats["att 0"],
            def = stats["def 0"],
            spa = stats["spa 0"],
            spd = stats["spd 0"],
            spe = stats["spe 0"]
        }
        return newStats
    else
        local defaultStats = {
            hp = 1,
            att = 1,
            def = 1,
            spa = 1,
            spd = 1,
            spe = 1
        }
        return defaultStats
    end
end
BattleManager = {}

BattleManager.Actions = {
	Attack = "Attack",
	Bag = "Bag",
	Switch = "Switch",
	Run = "Run",
}

BattleManager.Strategies = {
	Kill = "Kill",
	Run = "Run",
	Capture = "Capture",
}

--- Analyzes damage taken and inflicted to analyze foe stats
--- @return table stats
function BattleManager.estimateFoeStats()
	local stats = {
		["atk"] = nil,
		["def"] = nil,
		["spa"] = nil,
		["spd"] = nil,
	}
	if not Battle.inActiveBattle() then
		return stats
	end
	local ownPokemon = Battle.getViewedPokemon(true)
	-- Check enemy atk/spa
	if MoveData.isValid(Battle.lastEnemyMoveId) then
		local moveInfo = MoveData.Moves[Battle.lastEnemyMoveId] or MoveData.BlankMove
		print(moveInfo.name)
	end
	-- Check enemy def/spd
	if not Battle.damageReceived then
		
	end
	return stats
end

--- Analyzes the Pokemon Data to score the encountered wild Pokemon
--- @return number score
function BattleManager.estimateFoeScore()
--- @TODO
end

--- Returns the best Action to do on the current battle turn
--- @param strategy table from BattleManager.Strategies
--- @return table? action from BattleManager.Actions, nil if not in battle
function BattleManager.getBestAction(strategy)
	-- Check if player is not in battle
	if TrackerAPI.inActiveBattle() == false then
		return nil
	end
	-- Kill Strategy
	if strategy == BattleManager.Strategies.Kill then
		
	end
end

--- Returns true if a Pokemon has already been caught on the route the player is on, false otherwise
--- @return boolean alreadyCaughtOnRoute
function BattleManager.alreadyCaughtOnRoute()
--- @TODO
end

BattleManager = {}

BattleManager.Actions = {
	Attack = {},
	Bag = {},
	Switch = {},
	Run = {},
}

BattleManager.Strategies = {
	Kill = {},
	Run = {},
	Capture = {},
}

--- Analyzes the Pokemon Data to score the encountered wild Pokemon
--- @return number score
function BattleManager.estimateFoeScore()

end

--- Returns the best Action to do on the current battle turn
--- @return table? action from BattleManager.Actions
function BattleManager.getBestAction()
	-- Check if player is not in battle
	if TrackerAPI.inActiveBattle() == false then
		return nil
	end
	if Battle.isWildEncounter() then

	end
end

--- Returns true if a Pokemon has already been caught on the route the player is on, false otherwise
--- @return boolean alreadyCaughtOnRoute
function BattleManager.alreadyCaughtOnRoute()
--- @TODO
end

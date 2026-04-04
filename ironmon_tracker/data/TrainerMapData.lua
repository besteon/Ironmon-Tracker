TrainerMapData = {
	LuaDataKey = "TrainerRoutes"
}

-- The key is the mapId, the value is a list of tile-tables (x, y, id)
TrainerMapData.Routes = {}

function TrainerMapData.initialize()
	-- Don't bother building data for MGBA emulator, as it doesn't accept mouse clicks on screen
	if Main.IsOnBizhawk() then
		TrainerMapData.buildData()
	end
end

function TrainerMapData.buildData()
	local routeData = FileManager.loadLuaData(GameSettings.versioncolor, TrainerMapData.LuaDataKey)
	if type(routeData) == "table" then
		TrainerMapData.Routes = routeData
	else
		TrainerMapData.Routes = {}
	end
end

---Returns the trainer id of the trainer located at the clicked tile coordinates of the current map; returns nil if no trainer found.
---@param tileX number
---@param tileY number
---@return number|nil trainerId
function TrainerMapData.getTrainerIdFromMapTile(tileX, tileY)
	local mapId = TrackerAPI.getMapId()
	local routeData = TrainerMapData.Routes[mapId]
	if not routeData then
		return nil
	end

	for _, tile in pairs(routeData) do
		if tileX == tile.x and tileY == tile.y then
			return tile.id
		end
	end

	return nil
end

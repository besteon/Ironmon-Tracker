TrainerPathing = {}

-- Overlay drawing state
TrainerPathing.IsOverlayVisible = false

local TILE_SIZE = 16

-- Per-trainer color palette (ARGB). Alpha kept low so the map is still readable.
local PALETTE_FILL = {
	0x38FF4040, -- red
	0x384080FF, -- blue
	0x3840DD40, -- green
	0x38DDDD30, -- yellow
	0x38FF40FF, -- magenta
	0x3840DDDD, -- cyan
	0x38FF9020, -- orange
	0x38A060FF, -- purple
	0x38FF80A0, -- pink
	0x3880FF80, -- lime
}
local PALETTE_BORDER = {
	0x70FF4040,
	0x704080FF,
	0x7040DD40,
	0x70DDDD30,
	0x70FF40FF,
	0x7040DDDD,
	0x70FF9020,
	0x70A060FF,
	0x70FF80A0,
	0x7080FF80,
}

---Enable the tile overlay (debug visualization of trainer movement ranges).
function TrainerPathing.show()
	TrainerPathing.IsOverlayVisible = true
end

---Disable the tile overlay.
function TrainerPathing.hide()
	TrainerPathing.IsOverlayVisible = false
end

---Draws colored tile overlays for all trainers on the current map.
---Call from a drawing hook (e.g. after the main screen draw).
function TrainerPathing.drawOverlay()
	if not TrainerPathing.IsOverlayVisible or not Program.isValidMapLocation() then
		return
	end

	-- gBattleMainFunc is non-zero for the entire duration of battle, including the fade-out transition
	-- if Memory.readdword(GameSettings.gBattleMainFunc) ~= 0 then return end
	if Battle.inActiveBattle() or Program.isInStartMenu() or Program.isScreenOverlayOpen() then
		return
	end

	local mapId = TrackerAPI.getMapId()
	local routeData = TrainerMapData.Routes[mapId]
	if not routeData then
		return
	end

	local playerTile = Program.getPlayerMapTile()
	local screenTileSize = TILE_SIZE - 1

	for _, tile in ipairs(routeData) do
		-- Player is at screen tile (7, 5); offset map tile relative to player
		local screenX = (tile.x - playerTile.x + 7) * TILE_SIZE
		local screenY = (tile.y - playerTile.y + 5) * TILE_SIZE - 8

		-- Cull off-screen tiles
		if screenX > -TILE_SIZE and screenX < Constants.SCREEN.WIDTH
			and screenY > -TILE_SIZE and screenY < Constants.SCREEN.HEIGHT then
			local borderColor, fillColor = TrainerPathing.getTrainerColors(tile.id)
			gui.drawRectangle(screenX, screenY, screenTileSize, screenTileSize, borderColor, fillColor)
		end
	end
end

---Get the border and fill colors for a trainer.
---@param trainerId number
---@return number border
---@return number fill
function TrainerPathing.getTrainerColors(trainerId)
	local borderColor = PALETTE_BORDER[trainerId % #PALETTE_BORDER + 1]
	local fillColor = PALETTE_FILL[trainerId % #PALETTE_FILL + 1]
	return borderColor, fillColor
end

if Program then
	TrainerPathing.show()
	Program.addDebugDrawing("TrainerPathing", TrainerPathing.drawOverlay)
end
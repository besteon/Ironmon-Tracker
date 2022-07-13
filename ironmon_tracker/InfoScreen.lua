InfoScreen = {}

-- Update drawing the info screen if true
InfoScreen.redraw = true

InfoScreen.SCREENS = {
    POKEMON_INFO = "PokemonInfo",
	MOVE_INFO = "MoveInfo",
}

InfoScreen.viewScreen = nil
InfoScreen.infoLookup = 0 -- Either a PokemonID or a MoveID

-- A button to close the info screen
InfoScreen.closeButton = {
	text = "Close",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 38,
		GraphicConstants.SCREEN_HEIGHT - 19,
		29,
		11,
	},
	boxColors = { "Lower box border", "Lower box background" },
	onClick = function()
		Program.state = State.TRACKER
		Program.waitToDrawFrames = 0
	end
}
-- InfoScreen.closeButton = {
-- 	text = "X",
-- 	textColor = "Default text",
-- 	box = {
-- 		GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 18,
-- 		8,
-- 		9,
-- 		11,
-- 	},
-- 	boxColors = { "Upper box border", "Upper box background" },
-- 	onClick = function()
-- 		Program.state = State.TRACKER
-- 		Program.waitToDrawFrames = 0
-- 	end
-- }
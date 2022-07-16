InfoScreen = {}

-- Update drawing the info screen if true
InfoScreen.redraw = true

InfoScreen.SCREENS = {
    POKEMON_INFO = "PokemonInfo",
	MOVE_INFO = "MoveInfo",
}

InfoScreen.viewScreen = nil
InfoScreen.infoLookup = 0 -- Either a PokemonID or a MoveID

-- A button to navigate to the next Pokemon being viewed on the info screen
InfoScreen.nextButton = {
	text = ">",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 98, 20, 10, 10, },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		InfoScreen.showNextPokemon()
	end
}
-- A button to navigate to the previous Pokemon being viewed on the info screen
InfoScreen.prevButton = {
	text = "<",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 86, 20, 10, 10, },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		InfoScreen.showNextPokemon(-1)
	end
}
-- A button to close the info screen
InfoScreen.closeButton = {
	text = "Close",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 38, GraphicConstants.SCREEN_HEIGHT - 19, 29, 11, },
	boxColors = { "Lower box border", "Lower box background" },
	onClick = function()
		Program.state = State.TRACKER
		Program.frames.waitToDraw = 0
	end
}

-- Display a Pokemon that is 'N' entries ahead of the currently shown Pokemon; N can be negative
function InfoScreen.showNextPokemon(delta)
	delta = delta or 1 -- default to just showing the next pokemon
	local nextPokemonId = InfoScreen.infoLookup + delta

	if nextPokemonId < 1 then 
		nextPokemonId = 411
	elseif nextPokemonId > 251 and nextPokemonId < 277 then
		nextPokemonId = Utils.inlineIf(delta > 0, 277, 251)
	elseif nextPokemonId > 411 then
		nextPokemonId = 1
	end

	InfoScreen.infoLookup = nextPokemonId
	InfoScreen.redraw = true
end
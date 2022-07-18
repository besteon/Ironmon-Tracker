InfoScreen = {}

-- Update drawing the info screen if true
InfoScreen.redraw = true

InfoScreen.SCREENS = {
    POKEMON_INFO = "PokemonInfo",
	MOVE_INFO = "MoveInfo",
}

InfoScreen.viewScreen = nil
InfoScreen.infoLookup = 0 -- Either a PokemonID or a MoveID

-- A button to choose any Move from the full move list to be viewed on the info screen
InfoScreen.lookupMoveButton = {
	text = "?",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 98, 20, 10, 10, },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		InfoScreen.openMoveInfoWindow()
	end
}

-- A button to choose any Pokemon from the Pokedex to be viewed on the info screen
InfoScreen.lookupPokemonButton = {
	text = "?",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 92, 9, 10, 10, },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		InfoScreen.openPokemonInfoWindow()
	end
}

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

function InfoScreen.openMoveInfoWindow()
	local moveName = MoveData[InfoScreen.infoLookup].name -- infoLookup = moveId
	local allmovesData = {}
	for id, data in pairs(MoveData) do
		if data.name ~= "---" then
			table.insert(allmovesData, data.name)
		end
	end

	local moveLookup = forms.newform(360, 105, "Move Look up", function() return nil end)
	Utils.setFormLocation(moveLookup, 100, 50)
	forms.label(moveLookup, "Choose a Pokemon Move to look up:", 49, 10, 250, 20)
	local moveDropdown = forms.dropdown(moveLookup, {["Init"]="Loading Move Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(moveDropdown, allmovesData, true) -- true = alphabetize the list
	forms.settext(moveDropdown, moveName)

	forms.button(moveLookup, "Look up", function()
		local moveName = forms.gettext(moveDropdown)
		local moveId

		for id, data in pairs(MoveData) do
			if data.name == moveName then
				moveId = id - 0 -- subtract 1 because MoveData's first element is blank data
			end
		end

		if moveId ~= nil and moveId ~= 0 then
			InfoScreen.infoLookup = moveId
			InfoScreen.redraw = true
		end
		client.unpause()
		forms.destroy(moveLookup)
	end, 212, 29)

end

function InfoScreen.openPokemonInfoWindow()
	local pokemonName = PokemonData[InfoScreen.infoLookup + 1].name -- infoLookup = pokemonID
	local pokedexData = {}
	for id, data in pairs(PokemonData) do
		if data.bst ~= "---" then
			table.insert(pokedexData, data.name)
		end
	end

	local pokedexLookup = forms.newform(360, 105, "Pokedex Look up", function() return nil end)
	Utils.setFormLocation(pokedexLookup, 100, 50)
	forms.label(pokedexLookup, "Choose a Pokemon to look up:", 49, 10, 250, 20)
	local pokedexDropdown = forms.dropdown(pokedexLookup, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, pokedexData, true) -- true = alphabetize the list
	forms.settext(pokedexDropdown, pokemonName)

	forms.button(pokedexLookup, "Look up", function()
		local pokemonName = forms.gettext(pokedexDropdown)
		local pokemonId

		for id, data in pairs(PokemonData) do
			if data.name == pokemonName then
				pokemonId = id - 1 -- subtract 1 because PokemonData's first element is blank data
			end
		end

		if pokemonId ~= nil and pokemonId ~= 0 then
			InfoScreen.infoLookup = pokemonId
			InfoScreen.redraw = true
		end
		client.unpause()
		forms.destroy(pokedexLookup)
	end, 212, 29)
end
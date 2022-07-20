InfoScreen = {}

-- Update drawing the info screen if true
InfoScreen.redraw = true

InfoScreen.SCREENS = {
    POKEMON_INFO = "PokemonInfo",
	MOVE_INFO = "MoveInfo",
}

InfoScreen.viewScreen = nil
InfoScreen.infoLookup = 0 -- Either a PokemonID or a MoveID

InfoScreen.buttons = {
	lookupMove = {
		type = Constants.BUTTON_TYPES.IMAGE,
		image = Constants.PIXEL_IMAGES.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 98, 20, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.MOVE_INFO end,
		onClick = function(self)
			if self:isVisible() then
				InfoScreen.openMoveInfoWindow()
			end
		end
	},
	lookupPokemon = {
		type = Constants.BUTTON_TYPES.IMAGE,
		image = Constants.PIXEL_IMAGES.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 9, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO end,
		onClick = function(self)
			if self:isVisible() then
				InfoScreen.openPokemonInfoWindow()
			end
		end
	},
	nextPokemon = {
		type = Constants.BUTTON_TYPES.IMAGE,
		image = Constants.PIXEL_IMAGES.NEXT_BUTTON,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 98, 20, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO end,
		onClick = function(self)
			if self:isVisible() then
				InfoScreen.showNextPokemon()
			end
		end
	},
	previousPokemon = {
		type = Constants.BUTTON_TYPES.IMAGE,
		image = Constants.PIXEL_IMAGES.PREVIOUS_BUTTON,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 86, 20, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO end,
		onClick = function(self)
			if self:isVisible() then
				InfoScreen.showNextPokemon(-1)
			end
		end
	},
	close = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Close",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 116, 141, 25, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		onClick = function(self)
			Program.state = State.TRACKER
			Program.frames.waitToDraw = 0
		end
	},
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
	local moveName = MoveData.Moves[InfoScreen.infoLookup].name -- infoLookup = moveId
	local allmovesData = {}
	for id, data in pairs(MoveData.Moves) do
		if data.name ~= Constants.BLANKLINE then
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

		for id, data in pairs(MoveData.Moves) do
			if data.name == moveName then
				moveId = id
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
	local pokemonName = PokemonData.Pokemon[InfoScreen.infoLookup].name -- infoLookup = pokemonID
	local pokedexData = {}
	for id, data in pairs(PokemonData.Pokemon) do
		if data.bst ~= Constants.BLANKLINE then
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

		for id, data in pairs(PokemonData.Pokemon) do
			if data.name == pokemonName then
				pokemonId = id
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
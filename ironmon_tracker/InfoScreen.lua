InfoScreen = {
	viewScreen = 1,
	infoLookup = 0 -- Either a PokemonID or a MoveID
}

InfoScreen.SCREENS = {
    POKEMON_INFO = 1,
	MOVE_INFO = 2,
}

InfoScreen.buttons = {
	lookupMove = {
		type = Constants.BUTTON_TYPES.PIXELIMAGE,
		image = Constants.PIXEL_IMAGES.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 90, 20, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.MOVE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.openMoveInfoWindow()
		end
	},
	lookupPokemon = {
		type = Constants.BUTTON_TYPES.PIXELIMAGE,
		image = Constants.PIXEL_IMAGES.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 9, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.openPokemonInfoWindow()
		end
	},
	nextPokemon = {
		type = Constants.BUTTON_TYPES.PIXELIMAGE,
		image = Constants.PIXEL_IMAGES.NEXT_BUTTON,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 98, 20, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.showNextPokemon()
		end
	},
	previousPokemon = {
		type = Constants.BUTTON_TYPES.PIXELIMAGE,
		image = Constants.PIXEL_IMAGES.PREVIOUS_BUTTON,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 86, 20, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.showNextPokemon(-1)
		end
	},
	close = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Close",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 116, 141, 25, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		onClick = function()
			Program.changeScreenView(Program.SCREENS.TRACKER)
		end
	},
	HiddenPower = {
		type = Constants.BUTTON_TYPES.NO_BORDER,
		clickableArea = { Constants.SCREEN.WIDTH + 111, 8, 31, 13 },
		box = { Constants.SCREEN.WIDTH + 111, 8, 31, 13 },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.SCREENS.MOVE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end

			-- If the player's lead pokemon has Hidden Power, lookup that tracked typing
			local pokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
			if Utils.pokemonHasMove(pokemon, "Hidden Power") then

				-- Locate current Hidden Power type index value (requires looking up each time if player's Pokemon changes)
				local oldType = Tracker.getHiddenPowerType()
				local typeId = 0
				if oldType ~= nil then
					for index, hptype in ipairs(MoveData.HiddenPowerTypeList) do
						if hptype == oldType then
							typeId = index
							break
						end
					end
				end

				-- Then use the next index in sequence [1 -> 2], [2 -> 3], ... [N -> 1]
				typeId = (typeId % #MoveData.HiddenPowerTypeList) + 1
				Tracker.TrackHiddenPowerType(MoveData.HiddenPowerTypeList[typeId])
				Program.redraw(true)
			end
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
	Program.redraw(true)
end

function InfoScreen.openMoveInfoWindow()
	local moveName = MoveData.Moves[InfoScreen.infoLookup].name -- infoLookup = moveId
	local allmovesData = {}
	for _, data in pairs(MoveData.Moves) do
		if data.name ~= Constants.BLANKLINE then
			table.insert(allmovesData, data.name)
		end
	end

	local moveLookup = forms.newform(360, 105, "Move Look up", function() return nil end)
	Utils.setFormLocation(moveLookup, 100, 50)
	forms.label(moveLookup, "Choose a Pokemon Move to look up:", 49, 10, 250, 20)
	local moveDropdown = forms.dropdown(moveLookup, {["Init"]="Loading Move Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(moveDropdown, allmovesData, true) -- true = alphabetize the list
	forms.setproperty(moveDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(moveDropdown, "AutoCompleteMode", "Append")
	forms.settext(moveDropdown, moveName)

	forms.button(moveLookup, "Look up", function()
		local moveNameFromForm = forms.gettext(moveDropdown)
		local moveId

		for id, data in pairs(MoveData.Moves) do
			if data.name == moveNameFromForm then
				moveId = id
			end
		end

		if moveId ~= nil and moveId ~= 0 then
			InfoScreen.infoLookup = moveId
			Program.redraw(true)
		end
		client.unpause()
		forms.destroy(moveLookup)
	end, 212, 29)

end

function InfoScreen.openPokemonInfoWindow()
	local pokemonName = PokemonData.Pokemon[InfoScreen.infoLookup].name -- infoLookup = pokemonID
	local pokedexData = {}
	for _, data in pairs(PokemonData.Pokemon) do
		if data.bst ~= Constants.BLANKLINE then
			table.insert(pokedexData, data.name)
		end
	end

	local pokedexLookup = forms.newform(360, 105, "Pokedex Look up", function() return nil end)
	Utils.setFormLocation(pokedexLookup, 100, 50)
	forms.label(pokedexLookup, "Choose a Pokemon to look up:", 49, 10, 250, 20)
	local pokedexDropdown = forms.dropdown(pokedexLookup, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, pokedexData, true) -- true = alphabetize the list
	forms.setproperty(pokedexDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(pokedexDropdown, "AutoCompleteMode", "Append")
	forms.settext(pokedexDropdown, pokemonName)

	forms.button(pokedexLookup, "Look up", function()
		local pokemonNameFromForm = forms.gettext(pokedexDropdown)
		local pokemonId

		for id, data in pairs(PokemonData.Pokemon) do
			if data.name == pokemonNameFromForm then
				pokemonId = id
			end
		end

		if pokemonId ~= nil and pokemonId ~= 0 then
			InfoScreen.infoLookup = pokemonId
			Program.redraw(true)
		end
		client.unpause()
		forms.destroy(pokedexLookup)
	end, 212, 29)
end
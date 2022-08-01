InfoScreen = {
	viewScreen = 0,
	prevScreen = 0,
	infoLookup = 0, -- Possibilities: 'pokemonID', 'moveId', 'abilityId', or '{mapId, encounterArea}'
	prevScreenInfo = 0,
	revealOriginalRoute = false,
}

InfoScreen.Screens = {
    POKEMON_INFO = 1, -- TODO: Find a way to show a weakness is x4, helpful for newer players, and immune with the arrows
	MOVE_INFO = 2,
	ABILITY_INFO = 3, -- TODO: Implement this, helpful for newer players
	ROUTE_INFO = 4,
}

InfoScreen.Buttons = {
	lookupMove = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 133, 60, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.MOVE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.openMoveInfoWindow()
		end
	},
	lookupPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 9, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.openPokemonInfoWindow()
		end
	},
	nextPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 99, 23, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.showNextPokemon()
		end
	},
	previousPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 85, 23, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.showNextPokemon(-1)
		end
	},
	lookupRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 132, 9, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.openRouteInfoWindow()
		end
	},
	showOriginalRoute = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Show Original Route Info",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 20, Constants.SCREEN.MARGIN + 16, 100, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO and not InfoScreen.revealOriginalRoute end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.revealOriginalRoute = true
			Program.redraw(true)
		end
	},
	showMoreRouteEncounters = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "More...",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 83, 141, 30, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			local mapId = InfoScreen.infoLookup.mapId
			local encounterArea = InfoScreen.infoLookup.encounterArea
			InfoScreen.infoLookup.encounterArea = RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
			Program.redraw(true)
		end
	},
	close = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 117, 141, 24, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return true end,
		onClick = function(self)
			InfoScreen.viewScreen = 0
			InfoScreen.infoLookup = 0
			if InfoScreen.prevScreen > 0 then
				InfoScreen.changeScreenView(InfoScreen.prevScreen, InfoScreen.prevScreenInfo)
			else
				InfoScreen.revealOriginalRoute = false
				Program.changeScreenView(Program.Screens.TRACKER)
			end
		end
	},
	HiddenPower = {
		type = Constants.ButtonTypes.NO_BORDER,
		clickableArea = { Constants.SCREEN.WIDTH + 111, 8, 31, 13 },
		box = { Constants.SCREEN.WIDTH + 111, 8, 31, 13 },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.MOVE_INFO end,
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

InfoScreen.TemporaryButtons = {}

function InfoScreen.changeScreenView(screen, info)
	InfoScreen.prevScreen = InfoScreen.viewScreen
	InfoScreen.prevScreenInfo = InfoScreen.infoLookup
	InfoScreen.viewScreen = screen
	InfoScreen.infoLookup = info
	Program.changeScreenView(Program.Screens.INFO)
end

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

	forms.destroyall()
	client.pause()

	local moveLookup = forms.newform(360, 105, "Move Look up", function() client.unpause() end)
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

	forms.destroyall()
	client.pause()

	local pokedexLookup = forms.newform(360, 105, "Pokedex Look up", function() client.unpause() end)
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

function InfoScreen.openRouteInfoWindow()
	print("TODO: replace this with prompt for map id")
	-- if changing route views, then
	InfoScreen.revealOriginalRoute = false
end

function InfoScreen.getPokemonButtonsForEncounterArea(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local routeInfo = RouteData.Info[mapId]
	local totalPossible = #routeInfo[encounterArea]

	local routeEncounters
	if InfoScreen.revealOriginalRoute then
		routeEncounters = RouteData.getPokemonForEncounterArea(mapId, encounterArea)
	else
		routeEncounters = Tracker.getRouteEncounters(mapId, encounterArea)
	end

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
	local startY = Constants.SCREEN.MARGIN + 45
	local offsetX = 0
	local offsetY = 0
	local iconWidth = 32

	local iconButtons = {}
	for index=1, totalPossible, 1 do
		local pokemonID = 252  -- Question mark icon
		if routeEncounters ~= nil and routeEncounters[index] ~= nil then
			pokemonID = routeEncounters[index]
		end

		local x = startX + offsetX
		local y = startY + offsetY
		if Options["Pokemon Stadium portraits"] then
			y = y - 4 -- Don't really understand why it's different here vs main screen
		end

		iconButtons[index] = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getIconPath = function(self)
				local folderToUse = "pokemon"
				local extension = Constants.Extensions.POKEMON_PIXELED
				if Options["Pokemon Stadium portraits"] then
					folderToUse = "pokemonStadium"
					extension = Constants.Extensions.POKEMON_STADIUM
				end
				return Main.DataFolder .. "/images/" .. folderToUse .. "/" .. self.pokemonID .. extension
			end,
			pokemonID = pokemonID,
			box = { x, y, iconWidth, iconWidth },
			isVisible = function() return true end,
			onClick = function(self)
				if not self:isVisible() then return end
				if self.pokemonID ~= 252 then
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
				end
			end
		}

		offsetX = offsetX + iconWidth + 2
		if (startX + offsetX) > Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - iconWidth then
			offsetX = 0
			offsetY = offsetY + iconWidth + 2
		end
	end

	return iconButtons
end
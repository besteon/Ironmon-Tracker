InfoScreen = {
	viewScreen = 0,
	prevScreen = 0,
	infoLookup = 0, -- Possibilities: 'pokemonID', 'moveId', 'abilityId', or '{mapId, encounterArea}'
	prevScreenInfo = 0,
}

InfoScreen.Screens = {
    POKEMON_INFO = 1,
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
	lookupAbility = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 133, 60, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ABILITY_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.openAbilityInfoWindow()
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
		type = Constants.ButtonTypes.CHECKBOX,
		text = "Show original route data",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 17, 104, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 14, Constants.SCREEN.MARGIN + 18, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		toggleState = false, -- When true, the original game data for the route is revealed
		toggleColor = "Positive text",
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			self.toggleState = not self.toggleState
			Program.redraw(true)
		end
	},
	previousRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.PREVIOUS_BUTTON,
		textColor = "Header text",
		box = { Constants.SCREEN.WIDTH + 6, 37, 10, 10, },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			local mapId = InfoScreen.infoLookup.mapId
			local encounterArea = InfoScreen.infoLookup.encounterArea
			InfoScreen.infoLookup.encounterArea = RouteData.getPreviousAvailableEncounterArea(mapId, encounterArea)
			Program.redraw(true)
		end
	},
	nextRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NEXT_BUTTON,
		textColor = "Header text",
		box = { Constants.SCREEN.WIDTH + 136, 37, 10, 10, },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			local mapId = InfoScreen.infoLookup.mapId
			local encounterArea = InfoScreen.infoLookup.encounterArea
			InfoScreen.infoLookup.encounterArea = RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
			Program.redraw(true)
		end
	},
	back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + 117, 141, 24, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return true end,
		onClick = function(self)
			InfoScreen.viewScreen = 0
			InfoScreen.infoLookup = 0
			if InfoScreen.prevScreen > 0 then
				InfoScreen.changeScreenView(InfoScreen.prevScreen, InfoScreen.prevScreenInfo)
			else
				InfoScreen.clearScreenData()
				Program.changeScreenView(Program.Screens.TRACKER)
			end
		end
	},
	backTop = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 117, 141, 24, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return true end,
		onClick = function(self)
			InfoScreen.viewScreen = 0
			InfoScreen.infoLookup = 0
			if InfoScreen.prevScreen > 0 then
				InfoScreen.changeScreenView(InfoScreen.prevScreen, InfoScreen.prevScreenInfo)
			else
				InfoScreen.clearScreenData()
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
			local pokemon = Battle.getViewedPokemon(true)
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
	NotepadTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		getContentList = function(pokemonId)
			local noteText = Tracker.getNote(pokemonId)
			if noteText ~= nil and noteText ~= "" then
				return noteText
			else
				return "(Leave a note)"
			end
		end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 142, 110, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 142, 11, 11 },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			TrackerScreen.openNotePadWindow(InfoScreen.infoLookup)
		end,
	}
}

InfoScreen.TemporaryButtons = {}

function InfoScreen.changeScreenView(screen, info)
	InfoScreen.prevScreen = InfoScreen.viewScreen
	InfoScreen.prevScreenInfo = InfoScreen.infoLookup
	InfoScreen.viewScreen = screen
	InfoScreen.infoLookup = info
	Program.changeScreenView(Program.Screens.INFO)
end

function InfoScreen.clearScreenData()
	InfoScreen.viewScreen = 0
	InfoScreen.prevScreen = 0
	InfoScreen.infoLookup = 0
	InfoScreen.prevScreenInfo = 0
	InfoScreen.Buttons.showOriginalRoute.toggleState = false
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
	Program.destroyActiveForm()
	local moveLookup = forms.newform(360, 105, "Move Look up", function() client.unpause() end)
	Program.activeFormId = moveLookup
	Utils.setFormLocation(moveLookup, 100, 50)

	local moveName = MoveData.Moves[InfoScreen.infoLookup].name -- infoLookup = moveId
	local allmovesData = {}
	for _, data in pairs(MoveData.Moves) do
		if data.name ~= Constants.BLANKLINE then
			table.insert(allmovesData, data.name)
		end
	end

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
				break
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

function InfoScreen.openAbilityInfoWindow()
	Program.destroyActiveForm()
	local abilityLookup = forms.newform(360, 105, "Ability Look up", function() client.unpause() end)
	Program.activeFormId = abilityLookup
	Utils.setFormLocation(abilityLookup, 100, 50)
	local abilityName
	if not AbilityData.isValid(InfoScreen.infoLookup) then -- infoLookup = abilityId
		abilityName = AbilityData.DefaultAbility.name
	else
		abilityName = AbilityData.Abilities[InfoScreen.infoLookup].name
	end
	local allAbilitiesData = {}
	allAbilitiesData = AbilityData.populateAbilityDropdown(allAbilitiesData)

	forms.label(abilityLookup, "Choose a Pokemon Ability to look up:", 49, 10, 250, 20)
	local abilityDropdown = forms.dropdown(abilityLookup, {["Init"]="Loading Ability Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(abilityDropdown, allAbilitiesData, true) -- true = alphabetize the list
	forms.setproperty(abilityDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(abilityDropdown, "AutoCompleteMode", "Append")
	forms.settext(abilityDropdown, abilityName)

	forms.button(abilityLookup, "Look up", function()
		local abilityNameFromForm = forms.gettext(abilityDropdown)
		local abilityId

		for id, data in pairs(AbilityData.Abilities) do
			if data.name == abilityNameFromForm then
				abilityId = id
				break
			end
		end

		if abilityId ~= nil and abilityId ~= 0 then
			InfoScreen.infoLookup = abilityId
			Program.redraw(true)
		end
		client.unpause()
		forms.destroy(abilityLookup)
	end, 212, 29)
end

function InfoScreen.openPokemonInfoWindow()
	Program.destroyActiveForm()
	local pokedexLookup = forms.newform(360, 105, "Pokedex Look up", function() client.unpause() end)
	Program.activeFormId = pokedexLookup
	Utils.setFormLocation(pokedexLookup, 100, 50)

	local pokemonName = PokemonData.Pokemon[InfoScreen.infoLookup].name -- infoLookup = pokemonID
	local pokedexData = PokemonData.toList()

	forms.label(pokedexLookup, "Choose a Pokemon to look up:", 49, 10, 250, 20)
	local pokedexDropdown = forms.dropdown(pokedexLookup, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, pokedexData, true) -- true = alphabetize the list
	forms.setproperty(pokedexDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(pokedexDropdown, "AutoCompleteMode", "Append")
	forms.settext(pokedexDropdown, pokemonName)

	forms.button(pokedexLookup, "Look up", function()
		local pokemonNameFromForm = forms.gettext(pokedexDropdown)
		local pokemonId = PokemonData.getIdFromName(pokemonNameFromForm)

		if pokemonId ~= nil and pokemonId ~= 0 then
			InfoScreen.infoLookup = pokemonId
			Program.redraw(true)
		end
		client.unpause()
		forms.destroy(pokedexLookup)
	end, 212, 29)
end

function InfoScreen.openRouteInfoWindow()
	Program.destroyActiveForm()
	local routeLookup = forms.newform(360, 105, "Route Look up", function() client.unpause() end)
	Program.activeFormId = routeLookup
	Utils.setFormLocation(routeLookup, 100, 50)

	local routeName = RouteData.Info[InfoScreen.infoLookup.mapId].name -- infoLookup = {mapId, encounterArea}

	forms.label(routeLookup, "Choose a Route to look up:", 49, 10, 250, 20)
	local routeDropdown = forms.dropdown(routeLookup, {["Init"]="Loading Route Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(routeDropdown, RouteData.AvailableRoutes, false) -- true = alphabetize the list
	forms.setproperty(routeDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(routeDropdown, "AutoCompleteMode", "Append")
	forms.settext(routeDropdown, routeName)

	forms.button(routeLookup, "Look up", function()
		local routeNameFromForm = forms.gettext(routeDropdown)
		local mapId

		for id, data in pairs(RouteData.Info) do
			if data.name == routeNameFromForm then
				mapId = id
				break
			end
		end

		if mapId ~= nil and mapId ~= 0 then
			local encounterArea = RouteData.EncounterArea.LAND
			if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then
				encounterArea = RouteData.getNextAvailableEncounterArea(mapId, encounterArea) or RouteData.EncounterArea.LAND
			end

			InfoScreen.infoLookup.mapId = mapId
			InfoScreen.infoLookup.encounterArea = encounterArea
			InfoScreen.Buttons.showOriginalRoute.toggleState = false
			Program.redraw(true)
		end
		client.unpause()
		forms.destroy(routeLookup)
	end, 212, 29)
end

function InfoScreen.getPokemonButtonsForEncounterArea(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local routeInfo = RouteData.Info[mapId]
	local totalPossible = RouteData.countPokemonInArea(mapId, encounterArea)

	local areaInfo
	if InfoScreen.Buttons.showOriginalRoute.toggleState then
		areaInfo = RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	else
		local trackedPokemonIDs = Tracker.getRouteEncounters(mapId, encounterArea)
		areaInfo = {}
		for _, id in ipairs(trackedPokemonIDs) do
			table.insert(areaInfo, {
				pokemonID = id,
				rate = nil,
			})
		end
	end

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
	local startY = Constants.SCREEN.MARGIN + 50
	local offsetX = 0
	local offsetY = 0
	local iconWidth = 32

	local iconButtons = {}
	for index=1, totalPossible, 1 do
		local pokemonID = 252 -- Question mark icon
		local rate = nil
		if areaInfo ~= nil and areaInfo[index] ~= nil then
			pokemonID = areaInfo[index].pokemonID
			rate = areaInfo[index].rate
		end

		local x = startX + offsetX
		local y = startY + offsetY - Options.IconSetMap[Options["Pokemon icon set"]].yOffset

		iconButtons[index] = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. self.pokemonID .. iconset.extension
				return imagepath
			end,
			pokemonID = pokemonID,
			rate = rate,
			box = { x, y, iconWidth, iconWidth },
			isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
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

-- DRAWING FUNCTIONS
function InfoScreen.drawScreen()
	if InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO then
		local pokemonID = InfoScreen.infoLookup
		-- Only draw valid pokemon data, pokemonID = 0 is blank move data
		if not PokemonData.isValid(pokemonID) then
			Program.changeScreenView(Program.Screens.TRACKER)
		else
			InfoScreen.drawPokemonInfoScreen(pokemonID)
		end
	elseif InfoScreen.viewScreen == InfoScreen.Screens.MOVE_INFO then
		local moveId = InfoScreen.infoLookup
		-- Only draw valid move data, moveId = 0 is blank move data
		if not MoveData.isValid(moveId) then
			Program.changeScreenView(Program.Screens.TRACKER)
		else
			InfoScreen.drawMoveInfoScreen(moveId)
		end
	elseif InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO then
		-- Only draw valid route data
		local mapId = InfoScreen.infoLookup.mapId
		if not RouteData.hasRoute(mapId) then
			Program.changeScreenView(Program.Screens.TRACKER)
		else
			local encounterArea = InfoScreen.infoLookup.encounterArea or RouteData.EncounterArea.LAND
			if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then
				---@diagnostic disable-next-line: cast-local-type
				encounterArea = RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
			end
			InfoScreen.TemporaryButtons = InfoScreen.getPokemonButtonsForEncounterArea(mapId, encounterArea)
			InfoScreen.drawRouteInfoScreen(mapId, encounterArea)
		end
	elseif (InfoScreen.viewScreen == InfoScreen.Screens.ABILITY_INFO) then
		local abilityId = InfoScreen.infoLookup
		InfoScreen.drawAbilityInfoScreen(abilityId)
	end
end

function InfoScreen.drawPokemonInfoScreen(pokemonID)
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)

	-- set the color for text/number shadows for the top boxes
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxInfoBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local offsetColumnX = offsetX + 43
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local botOffsetY = offsetY + (linespacing * 6) - 2 + 9

	local pokemon = PokemonData.Pokemon[pokemonID]
	local pokemonViewed = Tracker.getViewedPokemon() or Tracker.getDefaultPokemon()
	local isTargetTheViewedPokemonn = pokemonViewed.pokemonID == pokemonID
	local ownPokemonId = Battle.getViewedPokemon(true).pokemonID

	local typeOne = pokemon.types[1]
	local typeTwo = pokemon.types[2]
	if not Options["Reveal info if randomized"] and PokemonData.IsRand.pokemonTypes and pokemonID ~= ownPokemonId then
		-- Don't reveal randomized Pokemon types for Pokedex entries
		typeOne = PokemonData.Types.UNKNOWN
		typeTwo = PokemonData.Types.UNKNOWN
	end

	Drawing.drawBackgroundAndMargins()

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 8, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON NAME
	offsetY = offsetY - 3
	local pokemonName = pokemon.name:upper()
	gui.drawText(offsetX + 1 - 1, offsetY + 1, pokemonName, boxInfoTopShadow, nil, 12, Constants.Font.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY, pokemonName, Theme.COLORS["Default text"], nil, 12, Constants.Font.FAMILY, "bold")

	-- POKEMON ICON & TYPES
	offsetY = offsetY - 7
	gui.drawRectangle(offsetX + 106, offsetY + 37, 31, 13, boxInfoTopShadow, boxInfoTopShadow)
	gui.drawRectangle(offsetX + 105, offsetY + 36, 31, 13, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	if typeTwo ~= typeOne and typeTwo ~= PokemonData.Types.EMPTY then
		gui.drawRectangle(offsetX + 106, offsetY + 50, 31, 12, boxInfoTopShadow, boxInfoTopShadow)
		gui.drawRectangle(offsetX + 105, offsetY + 49, 31, 12, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	end
	Drawing.drawPokemonIcon(pokemonID, offsetX + 105, offsetY + 2)
	Drawing.drawTypeIcon(typeOne, offsetX + 106, offsetY + 37)
	if typeTwo ~= typeOne then
		Drawing.drawTypeIcon(typeTwo, offsetX + 106, offsetY + 49)
	end
	offsetY = offsetY + 11 + linespacing

	-- BST
	Drawing.drawText(offsetX, offsetY, "BST:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, pokemon.bst, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- WEIGHT
	local weightInfo = pokemon.weight .. " kg"
	Drawing.drawText(offsetX, offsetY, "Weight:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, weightInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- EVOLUTION
	local possibleEvolutions = Utils.getDetailedEvolutionsInfo(pokemon.evolution)
	Drawing.drawText(offsetX, offsetY, "Evolution:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, possibleEvolutions[1], Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing
	if possibleEvolutions[2] ~= nil then
		Drawing.drawText(offsetColumnX, offsetY, possibleEvolutions[2], Theme.COLORS["Default text"], boxInfoTopShadow)
	end
	if pokemonID == 96 and Options.IconSetMap[Options["Pokemon icon set"]].name == "Explorers" then
		-- Pokémon Mystery Dungeon Drowzee easter egg
		Drawing.drawText(offsetX, offsetY, "This was all a trick. I deceived you.", Theme.COLORS["Default text"], boxInfoTopShadow)
	end
	offsetY = offsetY + linespacing

	-- Draw bottom view box and header
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	botOffsetY = offsetY + 3
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, botOffsetY, rightEdge, bottomEdge - botOffsetY + 5, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	botOffsetY = botOffsetY + 1

	-- MOVES LEVEL BOXES
	Drawing.drawText(offsetX, botOffsetY, "Learns a move at level:", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	botOffsetY = botOffsetY + linespacing + 1
	local boxWidth = 16
	local boxHeight = 13
	if #pokemon.movelvls[GameSettings.versiongroup] == 0 then -- If the Pokemon learns no moves at all
		Drawing.drawText(offsetX + 6, botOffsetY, "Does not learn any moves", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	end
	for i, moveLvl in ipairs(pokemon.movelvls[GameSettings.versiongroup]) do -- 14 is the greatest number of moves a gen3 Pokemon can learn
		local nextBoxX = ((i - 1) % 8) * boxWidth-- 8 possible columns
		local nextBoxY = Utils.inlineIf(i <= 8, 0, 1) * boxHeight -- 2 possible rows
		local lvlSpacing = (2 - string.len(tostring(moveLvl))) * 3

		gui.drawRectangle(offsetX + nextBoxX + 5 + 1, botOffsetY + nextBoxY + 2, boxWidth, boxHeight, boxInfoBotShadow, boxInfoBotShadow)
		gui.drawRectangle(offsetX + nextBoxX + 5, botOffsetY + nextBoxY + 1, boxWidth, boxHeight, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

		-- Indicate which moves have already been learned if the pokemon being viewed is one of the ones in battle (yours/enemy)
		local nextBoxTextColor
		if not isTargetTheViewedPokemonn then
			nextBoxTextColor = Theme.COLORS["Lower box text"]
		elseif moveLvl <= pokemonViewed.level then
			nextBoxTextColor = Theme.COLORS["Negative text"]
		else
			nextBoxTextColor = Theme.COLORS["Positive text"]
		end

		Drawing.drawText(offsetX + nextBoxX + 7 + lvlSpacing, botOffsetY + nextBoxY + 2, moveLvl, nextBoxTextColor, boxInfoBotShadow)
	end
	botOffsetY = botOffsetY + (linespacing * 3) - 2

	-- If the moves-to-learn only takes up one row, move up the weakness data
	if #pokemon.movelvls[GameSettings.versiongroup] <= 8 then
		botOffsetY = botOffsetY - linespacing
	end

	-- WEAK TO
	local weaknesses = {}
	local hasSevereWeakness = false
	for moveType, typeEffectiveness in pairs(MoveData.TypeToEffectiveness) do
		local effectiveness = 1
		if typeEffectiveness[typeOne] ~= nil then
			effectiveness = effectiveness * typeEffectiveness[typeOne]
		end
		if typeTwo ~= typeOne and typeEffectiveness[typeTwo] ~= nil then
			effectiveness = effectiveness * typeEffectiveness[typeTwo]
		end
		if effectiveness > 1 then
			weaknesses[moveType] = effectiveness
			if effectiveness > 2 then
				hasSevereWeakness = true
			end
		end
	end
	Drawing.drawText(offsetX, botOffsetY, "Weak to:", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	if hasSevereWeakness then
		Drawing.drawText(offsetColumnX, botOffsetY, "(white bars = x4 weak)", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	end
	botOffsetY = botOffsetY + linespacing + 3

	if weaknesses == {} then -- If the Pokemon has no weakness, like Sableye
		Drawing.drawText(offsetX + 6, botOffsetY, "Has no weaknesses", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	end

	local typeOffsetX = offsetX + 6
	for weakType, effectiveness in pairs(weaknesses) do
		gui.drawRectangle(typeOffsetX, botOffsetY, 31, 13, boxInfoBotShadow)
		gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Lower box border"])
		Drawing.drawTypeIcon(weakType, typeOffsetX, botOffsetY)

		if effectiveness > 2 then
			-- gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Negative text"])
			local barColor = 0xFFFFFFFF
			gui.drawLine(typeOffsetX, botOffsetY, typeOffsetX + 29, botOffsetY, barColor)
			gui.drawLine(typeOffsetX, botOffsetY + 1, typeOffsetX + 29, botOffsetY + 1, barColor)
			gui.drawLine(typeOffsetX, botOffsetY + 10, typeOffsetX + 29, botOffsetY + 10, barColor)
			gui.drawLine(typeOffsetX, botOffsetY + 11, typeOffsetX + 29, botOffsetY + 11, barColor)

			-- gui.drawRectangle(typeOffsetX, botOffsetY, 29, 1, Theme.COLORS["Negative text"])
			-- gui.drawRectangle(typeOffsetX, botOffsetY + 10, 29, 1, Theme.COLORS["Negative text"])
		end

		typeOffsetX = typeOffsetX + 31
		if typeOffsetX > Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - 30 then
			typeOffsetX = offsetX + 6
			botOffsetY = botOffsetY + 13
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.lookupPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.nextPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.previousPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.back, boxInfoBotShadow)
	InfoScreen.drawNotepadArea()
	Drawing.drawButton(InfoScreen.Buttons.NotepadTracking, boxInfoBotShadow)

end

function InfoScreen.drawMoveInfoScreen(moveId)
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)

	-- set the color for text/number shadows for the top boxes
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxInfoBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local offsetColumnX = offsetX + 45
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local botOffsetY = offsetY + (linespacing * 7) + 7

	local move = MoveData.Moves[moveId]
	local moveType = move.type
	local moveCat = move.category
	local movePPText = move.pp
	local movePower = move.power
	local moveAccuracy = move.accuracy

	-- Don't reveal randomized move info for moves the player's current pokemon doesn't have
	local ownPokemon = Battle.getViewedPokemon(true)
	local hideInfo = not Options["Reveal info if randomized"] and not Utils.pokemonHasMove(ownPokemon, move.name)

	-- Before drawing view boxes, check if extra space is needed for 'Priority' information
	if move.priority ~= nil and move.priority ~= "0" then
		botOffsetY = botOffsetY + linespacing
	end

	Drawing.drawBackgroundAndMargins()

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 8, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- MOVE NAME
	local moveName = move.name:upper()
	gui.drawText(offsetX + 1 - 1, offsetY + 1 - 3, moveName, boxInfoTopShadow, nil, 12, Constants.Font.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY - 3, moveName, Theme.COLORS["Default text"], nil, 12, Constants.Font.FAMILY, "bold")

	-- If the move is Hidden Power and the lead pokemon has that move, use its tracked type/category instead
	if moveId == 237 then -- 237 = Hidden Power
		local pokemon = Battle.getViewedPokemon(true)
		if Utils.pokemonHasMove(pokemon, "Hidden Power") then
			moveType = Tracker.getHiddenPowerType()
			moveCat = MoveData.TypeToCategory[moveType]
			Drawing.drawText(offsetX + 96, offsetY + linespacing * 2 - 4, "Set type ^", Theme.COLORS["Positive text"], boxInfoTopShadow)
		end
	end

	-- TYPE ICON
	if hideInfo and MoveData.IsRand.moveType then
		moveType = PokemonData.Types.UNKNOWN
	end
	offsetY = offsetY + 1
	gui.drawRectangle(offsetX + 106, offsetY + 1, 31, 13, boxInfoTopShadow, boxInfoTopShadow)
	gui.drawRectangle(offsetX + 105, offsetY, 31, 13, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	Drawing.drawTypeIcon(moveType, offsetX + 106, offsetY + 1)
	offsetY = offsetY + linespacing

	-- CATEGORY
	local categoryInfo
	if moveCat == MoveData.Categories.STATUS then
		categoryInfo = "Status"
	elseif hideInfo and MoveData.IsRand.moveType then
		categoryInfo = Constants.HIDDEN_INFO
	elseif moveCat == MoveData.Categories.PHYSICAL then
		categoryInfo = "Physical"
		Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, offsetColumnX + 36, offsetY + 2, { Theme.COLORS["Default text"] }, boxInfoTopShadow)
	elseif moveCat == MoveData.Categories.SPECIAL then
		categoryInfo = "Special"
		Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, offsetColumnX + 33, offsetY + 2, { Theme.COLORS["Default text"] }, boxInfoTopShadow)
	else
		categoryInfo = Constants.BLANKLINE
	end
	Drawing.drawText(offsetX, offsetY, "Category:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, categoryInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- CONTACT
	local contactInfo = Utils.inlineIf(move.iscontact ~= nil and move.iscontact, "Yes", "No")
	Drawing.drawText(offsetX, offsetY, "Contact:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, contactInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- PP
	if movePPText == "0" then
		movePPText = Constants.BLANKLINE
	elseif hideInfo and MoveData.IsRand.movePP then
		movePPText = Constants.HIDDEN_INFO
	end
	Drawing.drawText(offsetX, offsetY, "PP:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, movePPText, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- POWER
	if movePower == "0" then
		movePower = Constants.BLANKLINE
	elseif hideInfo and MoveData.IsRand.movePower then
		movePower = Constants.HIDDEN_INFO
	end
	Drawing.drawText(offsetX, offsetY, "Power:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, movePower, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- ACCURACY
	if moveAccuracy == "0" then
		moveAccuracy = Constants.BLANKLINE
	else
		if hideInfo and MoveData.IsRand.moveAccuracy then
			moveAccuracy = Constants.HIDDEN_INFO
		else
			moveAccuracy = moveAccuracy .. "%"
		end
	end
	Drawing.drawText(offsetX, offsetY, "Accuracy:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, moveAccuracy, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- PRIORITY: Only take up a line on the screen if priority information is helpful (exists and is non-zero)
	if move.priority ~= nil and move.priority ~= "0" then
		Drawing.drawText(offsetX, offsetY, "Priority:", Theme.COLORS["Default text"], boxInfoTopShadow)
		Drawing.drawText(offsetColumnX, offsetY, move.priority, Theme.COLORS["Default text"], boxInfoTopShadow)
	end

	-- Draw bottom view box and header
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	Drawing.drawText(offsetX - 3, botOffsetY - linespacing - 1, "Summary:", Theme.COLORS["Header text"], bgHeaderShadow)
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, botOffsetY, rightEdge, bottomEdge - botOffsetY + 5, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	botOffsetY = botOffsetY + 1
	linespacing = linespacing + 1

	-- SUMMARY
	if move.summary ~= nil then
		local wrappedSummary = Utils.getWordWrapLines(move.summary, 31)

		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, botOffsetY, line, Theme.COLORS["Lower box text"], boxInfoBotShadow)
			botOffsetY = botOffsetY + linespacing
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.lookupMove, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.back, boxInfoBotShadow)

	-- Easter egg
	if moveId == 150 then -- 150 = Splash
		Drawing.drawPokemonIcon(129, offsetX + 16, botOffsetY + 8)
		Drawing.drawPokemonIcon(129, offsetX + 40, botOffsetY - 8)
		Drawing.drawPokemonIcon(129, offsetX + 75, botOffsetY + 2)
		Drawing.drawPokemonIcon(129, offsetX + 99, botOffsetY - 16)
	end
end

function InfoScreen.drawAbilityInfoScreen(abilityId)
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)

	-- set the color for text/number shadows for the top boxes
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local offsetColumnX = offsetX + 45
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local botOffsetY = offsetY + (linespacing * 7) + 7

	local ability
	if not AbilityData.isValid(abilityId) then
		ability = AbilityData.DefaultAbility
	else
		ability = AbilityData.Abilities[abilityId]
	end

	Drawing.drawBackgroundAndMargins()
	-- Draw one big rectangle
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, bottomEdge, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Ability NAME
	local abilityName = ability.name:upper():gsub(" ", "  ")
	gui.drawText(offsetX - 1 + 1, offsetY + 1 - 3, abilityName, boxInfoTopShadow, nil, 12, Constants.Font.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY - 3, abilityName, Theme.COLORS["Default text"], nil, 12, Constants.Font.FAMILY, "bold")

	--SEARCH ICON
	local lookupAbility = InfoScreen.Buttons.lookupAbility
	lookupAbility.box = {Constants.SCREEN.WIDTH + 133, offsetY, 10, 10,}
	Drawing.drawButton(lookupAbility, boxInfoTopShadow)
	offsetY = offsetY + linespacing * 2 - 5

	-- DESCRIPTION
	if ability.description ~= nil then
		local wrappedSummary = Utils.getWordWrapLines(ability.description, 30)

		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, offsetY, line, Theme.COLORS["Default text"], boxInfoTopShadow)
			offsetY = offsetY + linespacing
		end
	end
	offsetY = offsetY + 6

	-- EMERALD DESCRIPTION
	if ability.descriptionEmerald ~= nil then
		Drawing.drawText(offsetX, offsetY, "Emerald:", Theme.COLORS["Default text"], boxInfoTopShadow, "italics")
		offsetY = offsetY + linespacing + 1
		local wrappedSummary = Utils.getWordWrapLines(ability.descriptionEmerald, 31)

		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, offsetY, line, Theme.COLORS["Default text"], boxInfoTopShadow)
			offsetY = offsetY + linespacing
		end
	end

	Drawing.drawButton(InfoScreen.Buttons.backTop, boxInfoTopShadow)
end

function InfoScreen.drawRouteInfoScreen(mapId, encounterArea)
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])
	local boxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local boxWidth = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local boxTopY = Constants.SCREEN.MARGIN
	local boxTopHeight = 30
	local botBoxY = boxTopY + boxTopHeight + 13
	local botBoxHeight = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - botBoxY

	Drawing.drawBackgroundAndMargins()

	-- TOP BOX VIEW
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(boxX, boxTopY, boxWidth, boxTopHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- ROUTE NAME
	local routeName = RouteData.Info[mapId].name or Constants.BLANKLINE
	Drawing.drawImageAsPixels(Constants.PixelImages.MAP_PINDROP, boxX + 3, boxTopY + 3, { Theme.COLORS["Default text"] }, boxTopShadow)
	Drawing.drawText(boxX + 13, boxTopY + 2, routeName, Theme.COLORS["Default text"], boxTopShadow)

	Drawing.drawButton(InfoScreen.Buttons.showOriginalRoute, boxTopShadow)

	-- BOT BOX VIEW
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	local encounterHeaderText = Constants.Words.POKEMON .. " seen by " .. encounterArea
	if encounterArea == RouteData.EncounterArea.STATIC then
		encounterHeaderText = encounterArea .. " " .. Constants.Words.POKEMON .. " encounters"
	end
	Drawing.drawText(boxX + 10, botBoxY - 11, encounterHeaderText, Theme.COLORS["Header text"], bgHeaderShadow)
	gui.drawRectangle(boxX, botBoxY, boxWidth, botBoxHeight, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	if not InfoScreen.Buttons.showOriginalRoute.toggleState then
		Drawing.drawText(boxX + 2, botBoxY, "In order of appearance:", Theme.COLORS["Lower box text"], boxBotShadow)
	end

	-- POKEMON SEEN

	for _, iconButton in pairs(InfoScreen.TemporaryButtons) do
		if iconButton.pokemonID == 252--[[ Question mark icon]] and Options.IconSetMap[Options["Pokemon icon set"]].adjustQuestionMark then
			iconButton.box[2] = iconButton.box[2] + Options.IconSetMap[Options["Pokemon icon set"]].yOffset
		end

		local x = iconButton.box[1]
		local y = iconButton.box[2]
		Drawing.drawButton(iconButton, boxBotShadow)

		if iconButton.rate ~= nil then
			local rateText = (iconButton.rate * 100) .. "%"
			local rateOffset = Utils.inlineIf(iconButton.rate == 1.00, 5, Utils.inlineIf(iconButton.rate >= 0.1, 7, 9)) -- centering
			gui.drawRectangle(x + 1, y, 30, 8, Theme.COLORS["Lower box background"], Theme.COLORS["Lower box background"])
			Drawing.drawText(x + rateOffset, y - 1, rateText, Theme.COLORS["Lower box text"], boxBotShadow)
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.lookupRoute, boxTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.nextRoute, bgHeaderShadow)
	Drawing.drawButton(InfoScreen.Buttons.previousRoute, bgHeaderShadow)
	Drawing.drawButton(InfoScreen.Buttons.back, boxBotShadow)
end

function InfoScreen.drawNotepadArea()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])
	local noteText = InfoScreen.Buttons.NotepadTracking.getContentList(InfoScreen.infoLookup)
	--23 will fit, but cut to 22 if we need to show the ellipses
	if #noteText > 23 then
		local	textTest = Utils.getWordWrapLines(noteText, 22)
		textTest[1] = textTest[1] .. " ..."
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 16, 142, textTest[1], Theme.COLORS["Lower box text"], shadowcolor)
	else
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 16, 142, noteText, Theme.COLORS["Lower box text"], shadowcolor)
	end
	gui.drawLine(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 155, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN, 155, Theme.COLORS["Lower box border"])
	gui.drawLine(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 156, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN, 156, Theme.COLORS["Main background"])
	--blank out the part past the button, in case there are too many 'big' letters that bleed past the Back button
	--and also the part past the box edge
	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
	local y = 141
	gui.drawRectangle(x + 1 , 141, 12, 14, Theme.COLORS["Main background"], Theme.COLORS["Main background"])
	--gui.drawRectangle(Constants.SCREEN.WIDTH + 117 - 1, y, 28, 13, Theme.COLORS["Lower box background"], Theme.COLORS["Lower box background"])
	gui.drawLine(x, y, x, y + 13, Theme.COLORS["Lower box border"])
end
InfoScreen = {
	viewScreen = 0,
	prevScreen = 0,
	infoLookup = 0, -- Possibilities: 'pokemonID', 'moveId', 'abilityId', or '{mapId, encounterArea}'
	prevScreenInfo = 0,
}

InfoScreen.Screens = {
	POKEMON_INFO = 1,
	MOVE_INFO = 2,
	ABILITY_INFO = 3,
	ROUTE_INFO = 4,
}

InfoScreen.Buttons = {
	LookupMove = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 133, 60, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.MOVE_INFO end,
		onClick = function(self) InfoScreen.openMoveInfoWindow() end
	},
	LookupAbility = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 133, 60, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ABILITY_INFO end,
		onClick = function(self) InfoScreen.openAbilityInfoWindow() end
	},
	LookupPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 93, 21, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self) InfoScreen.openPokemonInfoWindow() end
	},
	NextPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 100, 31, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self) InfoScreen.showNextPokemon() end
	},
	PreviousPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 87, 31, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self) InfoScreen.showNextPokemon(-1) end
	},
	PokemonInfoIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconId = function(self)
			local pokemonID = InfoScreen.infoLookup
			-- Safety check to make sure this icon has the requested sprite animation type
			if SpriteData.canDrawPokemonIcon(pokemonID) and not SpriteData.IconData[pokemonID][self.animType] then
				self.animType = SpriteData.getNextAnimType(pokemonID, self.animType)
			end
			-- If the log viewer is open, use its animation type
			local animType = LogOverlay.isDisplayed and SpriteData.Types.Idle or self.animType
			return pokemonID, self.animType or animType
		end,
		animType = SpriteData.Types.Idle,
		clickableArea = { Constants.SCREEN.WIDTH + 112, 5, 32, 27 },
		box = { Constants.SCREEN.WIDTH + 112, 0, 32, 32 },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self)
			if SpriteData.canDrawPokemonIcon(InfoScreen.infoLookup) and not LogOverlay.isDisplayed then
				self.animType = SpriteData.getNextAnimType(InfoScreen.infoLookup, self.animType)
				Program.redraw(true)
			end
		end
	},
	ViewRandomEvos = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.InfoScreen.ButtonViewEvos end,
		textColor = "Intermediate text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 46, 31, 10 },
		boxColors = { "Upper box border", "Upper box background" },
		shouldShow = false, -- for now, need to update this during the legacy drawScreen method
		isVisible = function(self) return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO and self.shouldShow end,
		onClick = function (self)
			if RandomEvosScreen.buildPagedButtons(InfoScreen.infoLookup) then
				Program.changeScreenView(RandomEvosScreen)
			end
		end,
	},
	MoveHistory = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.InfoScreen.ButtonHistory end,
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, Constants.SCREEN.MARGIN + 70, 28, 10, },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		draw = function(self)
			local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] + 1
			local y1, y2 = self.box[2] + self.box[4], self.box[2] + self.box[4]
			gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
		end,
		onClick = function (self)
			if MoveHistoryScreen.buildOutHistory(InfoScreen.infoLookup) then
				Program.changeScreenView(MoveHistoryScreen)
			end
		end,
	},
	TypeDefenses = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.InfoScreen.ButtonResistances end,
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 68, Constants.SCREEN.MARGIN + 97, 68, 10, },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		draw = function(self)
			local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] + 1
			local y1, y2 = self.box[2] + self.box[4], self.box[2] + self.box[4]
			gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
		end,
		onClick = function (self)
			TypeDefensesScreen.buildOutPagedButtons(InfoScreen.infoLookup)
			Program.changeScreenView(TypeDefensesScreen)
		end,
	},
	LookupRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 132, 9, 10, 10, },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self) InfoScreen.openRouteInfoWindow() end
	},
	ShowRoutePercentages = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return Resources.InfoScreen.CheckboxPercentages end,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15, Constants.SCREEN.MARGIN + 17, 61, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 15, Constants.SCREEN.MARGIN + 18, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		toggleState = false, -- When true, the original game percentage rates for the route are revealed
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			InfoScreen.Buttons.ShowRouteLevels.toggleState = false
			Program.redraw(true)
		end
	},
	ShowRouteLevels = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return Resources.InfoScreen.CheckboxLevels end,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 88, Constants.SCREEN.MARGIN + 17, 36, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 88, Constants.SCREEN.MARGIN + 18, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		toggleState = false, -- When true, the original game Pokemon levels for the route are revealed
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			self.toggleState = not self.toggleState
			InfoScreen.Buttons.ShowRoutePercentages.toggleState = false
			Program.redraw(true)
		end
	},
	PreviousRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		textColor = "Header text",
		box = { Constants.SCREEN.WIDTH + 6, 37, 10, 10, },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			local mapId = InfoScreen.infoLookup.mapId
			local encounterArea = InfoScreen.infoLookup.encounterArea
			InfoScreen.infoLookup.encounterArea = RouteData.getPreviousAvailableEncounterArea(mapId, encounterArea)
			Program.redraw(true)
		end
	},
	NextRoute = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		textColor = "Header text",
		box = { Constants.SCREEN.WIDTH + 136, 37, 10, 10, },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
		onClick = function(self)
			local mapId = InfoScreen.infoLookup.mapId
			local encounterArea = InfoScreen.infoLookup.encounterArea
			InfoScreen.infoLookup.encounterArea = RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
			Program.redraw(true)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		InfoScreen.viewScreen = 0
		InfoScreen.infoLookup = 0
		if InfoScreen.prevScreen > 0 then
			InfoScreen.changeScreenView(InfoScreen.prevScreen, InfoScreen.prevScreenInfo)
		else
			InfoScreen.clearScreenData()
			if Program.isValidMapLocation() then
				Program.changeScreenView(TrackerScreen)
			else
				Program.changeScreenView(StartupScreen)
			end
		end
	end, "Lower box text"),
	BackTop = Drawing.createUIElementBackButton(function()
		InfoScreen.Buttons.Back:onClick()
	end, "Default text"),
	HiddenPowerPrev = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 113, Constants.SCREEN.MARGIN + 40, 10, 10 },
		isVisible = function()
			if InfoScreen.viewScreen ~= InfoScreen.Screens.MOVE_INFO or InfoScreen.infoLookup ~= 237 then return false end
			-- Only reveal the HP set arrows if the player's active Pokemon has the move
			local pokemon = Battle.getViewedPokemon(true) or {}
			return PokemonData.isValid(pokemon.pokemonID) and Utils.pokemonHasMove(pokemon, 237) -- 237 = Hidden Power
		end,
		onClick = function(self)
			-- If the player's lead pokemon has Hidden Power, lookup that tracked typing
			local pokemon = Battle.getViewedPokemon(true) or {}
			if PokemonData.isValid(pokemon.pokemonID) and Utils.pokemonHasMove(pokemon, 237) then -- 237 = Hidden Power
				-- Locate current Hidden Power type index value (requires looking up each time if player's Pokemon changes)
				local oldType = Tracker.getHiddenPowerType(pokemon)
				local typeId = 0
				if oldType ~= nil then
					for index, hptype in ipairs(MoveData.HiddenPowerTypeList) do
						if hptype == oldType then
							typeId = index
							break
						end
					end
				end
				-- Then use the previous index in sequence [2 -> 1], [1 -> N], ... [N -> N-1]
				typeId = ((typeId - 2 + #MoveData.HiddenPowerTypeList) % #MoveData.HiddenPowerTypeList) + 1
				Tracker.TrackHiddenPowerType(pokemon.personality, MoveData.HiddenPowerTypeList[typeId])
				Program.redraw(true)
			end
		end
	},
	HiddenPowerNext = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 130, Constants.SCREEN.MARGIN + 40, 10, 10 },
		isVisible = function() return InfoScreen.Buttons.HiddenPowerPrev:isVisible() end,
		onClick = function(self)
			-- If the player's lead pokemon has Hidden Power, lookup that tracked typing
			local pokemon = Battle.getViewedPokemon(true) or {}
			if PokemonData.isValid(pokemon.pokemonID) and Utils.pokemonHasMove(pokemon, 237) then -- 237 = Hidden Power
				-- Locate current Hidden Power type index value (requires looking up each time if player's Pokemon changes)
				local oldType = Tracker.getHiddenPowerType(pokemon)
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
				Tracker.TrackHiddenPowerType(pokemon.personality, MoveData.HiddenPowerTypeList[typeId])
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
				return string.format("(%s)", Resources.TrackerScreen.LeaveANote)
			end
		end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 142, 110, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 142, 11, 11 },
		isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO end,
		onClick = function(self) TrackerScreen.openNotePadWindow(InfoScreen.infoLookup) end,
	}
}

InfoScreen.TemporaryButtons = {}

function InfoScreen.changeScreenView(screen, info)
	InfoScreen.prevScreen = InfoScreen.viewScreen
	InfoScreen.prevScreenInfo = InfoScreen.infoLookup
	InfoScreen.viewScreen = screen
	InfoScreen.infoLookup = info
	if screen == InfoScreen.Screens.ROUTE_INFO then
		InfoScreen.Buttons.ShowRoutePercentages.toggleState = false
		InfoScreen.Buttons.ShowRouteLevels.toggleState = (Options["Open Book Play Mode"] or LogOverlay.isDisplayed)
	end
	Program.changeScreenView(InfoScreen)
end

function InfoScreen.clearScreenData()
	InfoScreen.viewScreen = 0
	InfoScreen.prevScreen = 0
	InfoScreen.infoLookup = 0
	InfoScreen.prevScreenInfo = 0
	InfoScreen.Buttons.ShowRoutePercentages.toggleState = false
	InfoScreen.Buttons.ShowRouteLevels.toggleState = false
	InfoScreen.Buttons.PokemonInfoIcon.spriteType = SpriteData.Types.Idle
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
	local form = Utils.createBizhawkForm(Resources.AllScreens.Lookup, 360, 105)

	local moveName = MoveData.Moves[InfoScreen.infoLookup].name -- infoLookup = moveId
	local allmovesData = {}
	for _, data in pairs(MoveData.Moves) do
		if data.name ~= Constants.BLANKLINE then
			table.insert(allmovesData, data.name)
		end
	end

	forms.label(form, Resources.InfoScreen.PromptLookupMove .. ":", 49, 10, 250, 20)
	local moveDropdown = forms.dropdown(form, {["Init"]="Loading Move Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(moveDropdown, allmovesData, true) -- true = alphabetize the list
	forms.setproperty(moveDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(moveDropdown, "AutoCompleteMode", "Append")
	forms.settext(moveDropdown, moveName)

	forms.button(form, Resources.AllScreens.Lookup, function()
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
		Utils.closeBizhawkForm(form)
	end, 212, 29)
end

function InfoScreen.openAbilityInfoWindow()
	local form = Utils.createBizhawkForm(Resources.AllScreens.Lookup, 360, 105)

	local abilityName
	if not AbilityData.isValid(InfoScreen.infoLookup) then -- infoLookup = abilityId
		abilityName = AbilityData.DefaultAbility.name
	else
		abilityName = AbilityData.Abilities[InfoScreen.infoLookup].name
	end
	local allAbilitiesData = {}
	allAbilitiesData = AbilityData.populateAbilityDropdown(allAbilitiesData)

	forms.label(form, Resources.InfoScreen.PromptLookupAbility .. ":", 49, 10, 250, 20)
	local abilityDropdown = forms.dropdown(form, {["Init"]="Loading Ability Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(abilityDropdown, allAbilitiesData, true) -- true = alphabetize the list
	forms.setproperty(abilityDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(abilityDropdown, "AutoCompleteMode", "Append")
	forms.settext(abilityDropdown, abilityName)

	forms.button(form, Resources.AllScreens.Lookup, function()
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
		Utils.closeBizhawkForm(form)
	end, 212, 29)
end

function InfoScreen.openPokemonInfoWindow()
	local form = Utils.createBizhawkForm(Resources.AllScreens.Lookup, 360, 105)

	local pokemonName
	if PokemonData.isValid(InfoScreen.infoLookup) then -- infoLookup = pokemonID
		pokemonName = PokemonData.Pokemon[InfoScreen.infoLookup].name
	else
		pokemonName = ""
	end
	local pokedexData = PokemonData.namesToList()

	forms.label(form, Resources.InfoScreen.PromptLookupPokemon .. ":", 49, 10, 250, 20)
	local pokedexDropdown = forms.dropdown(form, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, pokedexData, true) -- true = alphabetize the list
	forms.setproperty(pokedexDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(pokedexDropdown, "AutoCompleteMode", "Append")
	forms.settext(pokedexDropdown, pokemonName)

	forms.button(form, Resources.AllScreens.Lookup, function()
		local pokemonNameFromForm = forms.gettext(pokedexDropdown)
		local pokemonId = PokemonData.getIdFromName(pokemonNameFromForm)

		if pokemonId ~= nil and pokemonId ~= 0 then
			InfoScreen.infoLookup = pokemonId
			Program.redraw(true)
		end
		Utils.closeBizhawkForm(form)
	end, 212, 29)
end

function InfoScreen.openRouteInfoWindow()
	local form = Utils.createBizhawkForm(Resources.AllScreens.Lookup, 360, 105)

	local routeName = RouteData.Info[InfoScreen.infoLookup.mapId].name -- infoLookup = {mapId, encounterArea}
	routeName = Utils.formatSpecialCharacters(routeName)

	forms.label(form, Resources.InfoScreen.PromptLookupRoute .. ":", 49, 10, 250, 20)
	local routeDropdown = forms.dropdown(form, {["Init"]="Loading Route Data"}, 50, 30, 145, 30)
	forms.setdropdownitems(routeDropdown, RouteData.AvailableRoutes, false) -- true = alphabetize the list
	forms.setproperty(routeDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(routeDropdown, "AutoCompleteMode", "Append")
	forms.settext(routeDropdown, routeName)

	forms.button(form, Resources.AllScreens.Lookup, function()
		local dropdownSelection = forms.gettext(routeDropdown)
		local mapId

		for id, data in pairs(RouteData.Info) do
			local nameToMatch = Utils.formatSpecialCharacters(data.name)
			if nameToMatch == dropdownSelection then
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
			InfoScreen.Buttons.ShowRoutePercentages.toggleState = false
			InfoScreen.Buttons.ShowRouteLevels.toggleState = (Options["Open Book Play Mode"] or LogOverlay.isDisplayed)
			Program.redraw(true)
		end
		Utils.closeBizhawkForm(form)
	end, 212, 29)
end

function InfoScreen.getPokemonButtonsForEncounterArea(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local areaInfo
	local totalPossible = 0
	if Options["Open Book Play Mode"] or LogOverlay.isDisplayed then
		areaInfo = {}
		local selectedEncKey
		for key, val in pairs(RandomizerLog.EncounterTypes) do
			if val.internalArea == encounterArea then
				selectedEncKey = key
				break
			end
		end
		local routeLog = RandomizerLog.Data.Routes[mapId] or {}
		local routeAreas = routeLog.EncountersAreas or {}
		local encArea = routeAreas[selectedEncKey or false] or {}
		for id, pokemon in pairs(encArea.pokemon or {}) do
			table.insert(areaInfo, {
				pokemonID = id,
				minLv = pokemon.levelMin,
				maxLv = pokemon.levelMax,
				rate = pokemon.rate,
			})
		end
		table.sort(areaInfo, function(a,b)
			return (a.rate or 0) > (b.rate or 0) or (a.rate == b.rate and a.pokemonID < b.pokemonID)
		end)
		totalPossible = #areaInfo
	end
	-- If log info isn't available, revert back to using normal route display
	if totalPossible == 0 then
		if InfoScreen.Buttons.ShowRoutePercentages.toggleState or InfoScreen.Buttons.ShowRouteLevels.toggleState then
			areaInfo = RouteData.getEncounterAreaPokemon(mapId, encounterArea)
			totalPossible = #areaInfo
		else
			local trackedPokemonIDs = Tracker.getRouteEncounters(mapId, encounterArea)
			areaInfo = {}
			for _, id in ipairs(trackedPokemonIDs) do
				table.insert(areaInfo, {
					pokemonID = id,
					rate = nil,
				})
			end
			totalPossible = RouteData.countPokemonInArea(mapId, encounterArea)
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
		local minLv, maxLv = nil, nil
		if areaInfo ~= nil and areaInfo[index] ~= nil then
			pokemonID = areaInfo[index].pokemonID
			rate = areaInfo[index].rate
			minLv = areaInfo[index].minLv
			maxLv = areaInfo[index].maxLv
		end

		local iconset = Options.getIconSet()
		local x = startX + offsetX - (iconset.xOffset or 0)
		local y = startY + offsetY - (iconset.yOffset or 0)

		iconButtons[index] = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getIconId = function(self) return self.pokemonID, SpriteData.Types.Walk end,
			pokemonID = pokemonID,
			rate = rate,
			minLv = minLv,
			maxLv = maxLv,
			box = { x, y, iconWidth, iconWidth },
			isVisible = function() return InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO end,
			onClick = function(self)
				if not self:isVisible() or self.pokemonID == 252 then
					return
				end
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
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

-- USER INPUT FUNCTIONS
function InfoScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, InfoScreen.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, InfoScreen.TemporaryButtons)

	-- Check if mouse clicked on the game screen: on a new move learned, show info
	local gameFooterHeight = 45
	if Input.isMouseInArea(xmouse, ymouse, 0, Constants.SCREEN.HEIGHT - gameFooterHeight, Constants.SCREEN.WIDTH, gameFooterHeight) then
		local learnedInfoTable = Program.getLearnedMoveInfoTable()
		if learnedInfoTable.moveId ~= nil then
			InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, learnedInfoTable.moveId)
		end
	end
end

-- DRAWING FUNCTIONS
function InfoScreen.drawScreen()
	if InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO then
		local pokemonID = InfoScreen.infoLookup
		-- Only draw valid pokemon data, pokemonID = 0 is blank move data
		if not PokemonData.isValid(pokemonID) then
			Program.changeScreenView(TrackerScreen)
		else
			InfoScreen.drawPokemonInfoScreen(pokemonID)
		end
	elseif InfoScreen.viewScreen == InfoScreen.Screens.MOVE_INFO then
		local moveId = InfoScreen.infoLookup
		-- Only draw valid move data, moveId = 0 is blank move data
		if not MoveData.isValid(moveId) then
			Program.changeScreenView(TrackerScreen)
		else
			InfoScreen.drawMoveInfoScreen(moveId)
		end
	elseif InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO then
		-- Only draw valid route data
		local mapId = InfoScreen.infoLookup.mapId
		if not RouteData.hasRoute(mapId) then
			Program.changeScreenView(TrackerScreen)
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

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local offsetColumnX = offsetX + 42
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local botOffsetY = offsetY + (linespacing * 6) - 2 + 9

	local data = DataHelper.buildPokemonInfoDisplay(pokemonID)

	Drawing.drawBackgroundAndMargins()

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 7, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON NAME
	offsetY = offsetY - 3
	local pokemonName = Utils.toUpperUTF8(data.p.name)
	Drawing.drawHeader(offsetX - 2, offsetY - 1, pokemonName, Theme.COLORS["Default text"], boxInfoTopShadow)

	-- POKEMON TYPES
	local type1, type2 = data.p.types[1], data.p.types[2]
	if LogOverlay.isDisplayed and RandomizerLog.Data.Pokemon[pokemonID] then
		type1 = RandomizerLog.Data.Pokemon[pokemonID].Types[1] or PokemonData.Types.EMPTY
		type2 = RandomizerLog.Data.Pokemon[pokemonID].Types[2] or PokemonData.Types.EMPTY
	end
	offsetY = offsetY - 7
	gui.drawRectangle(offsetX + 106, offsetY + 37, 31, 13, boxInfoTopShadow, boxInfoTopShadow)
	gui.drawRectangle(offsetX + 105, offsetY + 36, 31, 13, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	if type2 ~= type1 and type2 ~= PokemonData.Types.EMPTY then
		gui.drawRectangle(offsetX + 106, offsetY + 50, 31, 12, boxInfoTopShadow, boxInfoTopShadow)
		gui.drawRectangle(offsetX + 105, offsetY + 49, 31, 12, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	end
	Drawing.drawTypeIcon(type1, offsetX + 106, offsetY + 37)
	if type2 ~= type1 then
		Drawing.drawTypeIcon(type2, offsetX + 106, offsetY + 49)
	end
	offsetY = offsetY + 12 + linespacing

	-- BST
	Drawing.drawText(offsetX, offsetY, Resources.TrackerScreen.StatBST .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, data.p.bst, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- WEIGHT
	local weightInfo = string.format("%s %s", data.p.weight, Resources.InfoScreen.KilogramAbbreviation)
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelWeight .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, weightInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- EVOLUTION
	local evoDetails = Utils.getDetailedEvolutionsInfo(data.p.evo)
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelEvolution .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, evoDetails[1], Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing
	if evoDetails[2] ~= nil then
		Drawing.drawText(offsetColumnX, offsetY, evoDetails[2], Theme.COLORS["Default text"], boxInfoTopShadow)
	end
	InfoScreen.Buttons.ViewRandomEvos.shouldShow = (evoDetails[1] ~= Constants.BLANKLINE)
	-- Removing this easter egg for now, since Drowzee has an evo
	-- if data.p.id == 96 and Options.getIconSet().name == "Explorers" then
	-- 	-- Pokémon Mystery Dungeon Drowzee easter egg
	-- 	Drawing.drawText(offsetX, offsetY, "This was all a trick. I deceived you.", Theme.COLORS["Default text"], boxInfoTopShadow)
	-- end
	offsetY = offsetY + linespacing

	-- Draw bottom view box and header
	offsetX = offsetX - 1
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	botOffsetY = offsetY + 3
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, botOffsetY, rightEdge, bottomEdge - botOffsetY + 5, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	botOffsetY = botOffsetY + 1

	-- MOVES LEVEL BOXES
	if InfoScreen.Buttons.MoveHistory.box[2] ~= botOffsetY then
		InfoScreen.Buttons.MoveHistory.box[2] = botOffsetY
	end
	Drawing.drawText(offsetX, botOffsetY, Resources.InfoScreen.LabelLearnMove .. ":", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	botOffsetY = botOffsetY + linespacing + 1
	local boxWidth = 16
	local boxHeight = 13
	if #data.p.movelvls == 0 then -- If the Pokemon learns no moves at all
		Drawing.drawText(offsetX + 6, botOffsetY, Resources.InfoScreen.LabelNoMoves, Theme.COLORS["Lower box text"], boxInfoBotShadow)
	end
	for i, moveLvl in ipairs(data.p.movelvls) do -- 14 is the greatest number of moves a gen3 Pokemon can learn
		local nextBoxX = ((i - 1) % 8) * boxWidth -- 8 possible columns
		local nextBoxY = Utils.inlineIf(i <= 8, 0, 1) * boxHeight -- 2 possible rows
		local lvlSpacing = (2 - string.len(tostring(moveLvl))) * 3

		gui.drawRectangle(offsetX + nextBoxX + 5 + 1, botOffsetY + nextBoxY + 2, boxWidth, boxHeight, boxInfoBotShadow, boxInfoBotShadow)
		gui.drawRectangle(offsetX + nextBoxX + 5, botOffsetY + nextBoxY + 1, boxWidth, boxHeight, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

		-- Indicate which moves have already been learned if the Pokemon being viewed is one of the ones in battle (yours/enemy)
		local nextBoxTextColor
		if data.x.viewedPokemonLevel == 0 then
			nextBoxTextColor = Theme.COLORS["Lower box text"]
		elseif moveLvl <= data.x.viewedPokemonLevel then
			nextBoxTextColor = Theme.COLORS["Negative text"]
		else
			nextBoxTextColor = Theme.COLORS["Positive text"]
		end

		Drawing.drawText(offsetX + nextBoxX + 7 + lvlSpacing, botOffsetY + nextBoxY + 2, moveLvl, nextBoxTextColor, boxInfoBotShadow)
	end
	botOffsetY = botOffsetY + (linespacing * 3) - 2

	-- If the moves-to-learn only takes up one row, move up the weakness data
	if #data.p.movelvls <= 8 then
		botOffsetY = botOffsetY - linespacing
	end

	-- WEAK TO
	if InfoScreen.Buttons.TypeDefenses.box[2] ~= botOffsetY then
		InfoScreen.Buttons.TypeDefenses.box[2] = botOffsetY
	end
	Drawing.drawText(offsetX, botOffsetY, Resources.InfoScreen.LabelWeakTo .. ":", Theme.COLORS["Lower box text"], boxInfoBotShadow)
	botOffsetY = botOffsetY + linespacing + 3

	-- Temporarily storing things as a single set of weaknesses, filtered out later, but ideally we display all type-effectiveness
	local weaknesses = {}
	for _, weakType in pairs(data.e[2]) do
		weaknesses[weakType] = 2
	end
	for _, weakType in pairs(data.e[4]) do
		weaknesses[weakType] = 4
	end

	if #data.e[2] == 0 and #data.e[4] == 0 then -- If the Pokemon has no weakness, like Sableye
		Drawing.drawText(offsetX + 6, botOffsetY, Resources.InfoScreen.LabelNoWeaknesses, Theme.COLORS["Lower box text"], boxInfoBotShadow)
	end

	local typeOffsetX = offsetX + 6
	for weakType, effectiveness in pairs(weaknesses) do
		gui.drawRectangle(typeOffsetX, botOffsetY, 31, 13, boxInfoBotShadow)
		gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Lower box border"])
		Drawing.drawTypeIcon(weakType, typeOffsetX, botOffsetY)

		if effectiveness > 2 then
			-- gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Negative text"])
			local barColor = Drawing.Colors.WHITE
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
	Drawing.drawButton(InfoScreen.Buttons.LookupPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.NextPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.PreviousPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.PokemonInfoIcon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.ViewRandomEvos, boxInfoTopShadow)

	Drawing.drawButton(InfoScreen.Buttons.MoveHistory, boxInfoBotShadow)
	Drawing.drawButton(InfoScreen.Buttons.TypeDefenses, boxInfoBotShadow)
	Drawing.drawButton(InfoScreen.Buttons.Back, boxInfoBotShadow)
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

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local offsetColumnX = offsetX + 44
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local botOffsetY = offsetY + (linespacing * 7) + 7

	local data = DataHelper.buildMoveInfoDisplay(moveId)

	-- Before drawing view boxes, check if extra space is needed for 'Priority' information
	if data.m.priority ~= "0" then
		botOffsetY = botOffsetY + linespacing
	end

	Drawing.drawBackgroundAndMargins()

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 8, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	local moveType = data.m.type
	local moveCategory = data.m.category
	local movePP = data.m.pp
	local movePower = data.m.power
	local moveAcc = data.m.accuracy
	if LogOverlay.isDisplayed and RandomizerLog.Data.Moves[moveId] then
		local moveLog = RandomizerLog.Data.Moves[moveId]
		moveType = moveLog.type or PokemonData.Types.EMPTY
		moveCategory = MoveData.TypeToCategory[moveType] or MoveData.Categories.NONE
		movePP = moveLog.pp ~= 0 and moveLog.pp or Constants.BLANKLINE
		movePower = moveLog.power ~= 0 and moveLog.power or Constants.BLANKLINE
		moveAcc = moveLog.acc ~= 0 and moveLog.acc or Constants.BLANKLINE
	end

	-- MOVE NAME
	data.m.name = Utils.toUpperUTF8(data.m.name)
	Drawing.drawHeader(offsetX - 2, offsetY - 4, data.m.name, Theme.COLORS["Default text"], boxInfoTopShadow)

	-- TYPE ICON
	offsetY = offsetY + linespacing + 4
	gui.drawRectangle(offsetX + 106, offsetY + 1, 31, 13, boxInfoTopShadow, boxInfoTopShadow)
	gui.drawRectangle(offsetX + 105, offsetY, 31, 13, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	Drawing.drawTypeIcon(moveType, offsetX + 106, offsetY + 1)
	offsetY = offsetY - 2

	if data.x.ownHasHiddenPower then
		Drawing.drawText(offsetX + 103, offsetY + linespacing * 2 - 6, Resources.InfoScreen.SetHiddenPowerType, Theme.COLORS["Positive text"], boxInfoTopShadow)
	end

	-- CATEGORY
	if moveCategory == MoveData.Categories.PHYSICAL then
		Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, offsetColumnX + 36, offsetY + 2, { Theme.COLORS["Default text"] }, boxInfoTopShadow)
	elseif moveCategory == MoveData.Categories.SPECIAL then
		Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, offsetColumnX + 33, offsetY + 2, { Theme.COLORS["Default text"] }, boxInfoTopShadow)
	end
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelCategory .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, moveCategory, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- CONTACT
	data.m.iscontact = Utils.inlineIf(data.m.iscontact, Resources.AllScreens.Yes, Resources.AllScreens.No)
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelContact .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, data.m.iscontact, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- PP
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelPP .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, movePP, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- POWER
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelPower .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, movePower, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- ACCURACY
	if tonumber(moveAcc) ~= nil then
		moveAcc = moveAcc .. "%"
	end
	Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelAccuracy .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, moveAcc, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- PRIORITY: Only take up a line on the screen if priority information is helpful (exists and is non-zero)
	if data.m.priority ~= "0" then
		Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelPriority .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
		Drawing.drawText(offsetColumnX, offsetY, data.m.priority, Theme.COLORS["Default text"], boxInfoTopShadow)
	end

	-- Draw bottom view box and header
	offsetX = offsetX - 1
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	Drawing.drawText(offsetX - 1, botOffsetY - linespacing - 1, Resources.InfoScreen.LabelMoveSummary .. ":", Theme.COLORS["Header text"], bgHeaderShadow)
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, botOffsetY, rightEdge, bottomEdge - botOffsetY + 5, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	botOffsetY = botOffsetY + 1
	linespacing = linespacing + 1

	-- SUMMARY
	if data.m.summary ~= Constants.BLANKLINE then
		local wrappedSummary = Utils.getWordWrapLines(data.m.summary, 31)

		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, botOffsetY, line, Theme.COLORS["Lower box text"], boxInfoBotShadow)
			botOffsetY = botOffsetY + linespacing
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.HiddenPowerPrev, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.HiddenPowerNext, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.LookupMove, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.Back, boxInfoBotShadow)

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
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local offsetColumnX = offsetX + 45
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = Constants.SCREEN.LINESPACING - 1

	local data = DataHelper.buildAbilityInfoDisplay(abilityId)

	Drawing.drawBackgroundAndMargins()
	-- Draw one big rectangle
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, bottomEdge, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Ability NAME
	data.a.name = Utils.toUpperUTF8(data.a.name)
	Drawing.drawHeader(offsetX - 2, offsetY - 4, data.a.name, Theme.COLORS["Default text"], boxInfoTopShadow)

	--SEARCH ICON
	local lookupAbility = InfoScreen.Buttons.LookupAbility
	lookupAbility.box = {Constants.SCREEN.WIDTH + 133, offsetY, 10, 10,}
	Drawing.drawButton(lookupAbility, boxInfoTopShadow)
	offsetY = offsetY + linespacing * 2 - 5

	-- DESCRIPTION
	if data.a.description ~= nil then
		local wrappedSummary = Utils.getWordWrapLines(data.a.description, 30)

		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, offsetY, line, Theme.COLORS["Default text"], boxInfoTopShadow)
			offsetY = offsetY + linespacing
		end
	end
	offsetY = offsetY + 6

	-- EMERALD DESCRIPTION
	if data.a.descriptionEmerald ~= nil and data.a.descriptionEmerald ~= Constants.BLANKLINE then
		Drawing.drawText(offsetX, offsetY, Resources.InfoScreen.LabelEmeraldAbility .. ":", Theme.COLORS["Default text"], boxInfoTopShadow)
		offsetY = offsetY + linespacing + 1
		local wrappedSummary = Utils.getWordWrapLines(data.a.descriptionEmerald, 31)

		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, offsetY, line, Theme.COLORS["Default text"], boxInfoTopShadow)
			offsetY = offsetY + linespacing
		end
	end

	Drawing.drawButton(InfoScreen.Buttons.BackTop, boxInfoTopShadow)
end

function InfoScreen.drawRouteInfoScreen(mapId, encounterArea)
	local botBoxTextColor = Theme.COLORS["Lower box text"]
	local botBoxBGColor = Theme.COLORS["Lower box background"]
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxBotShadow = Utils.calcShadowColor(botBoxBGColor)
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
	routeName = Utils.formatSpecialCharacters(routeName)
	Drawing.drawImageAsPixels(Constants.PixelImages.MAP_PINDROP, boxX + 3, boxTopY + 3, { Theme.COLORS["Default text"] }, boxTopShadow)
	Drawing.drawText(boxX + 13, boxTopY + 2, routeName, Theme.COLORS["Default text"], boxTopShadow)

	Drawing.drawButton(InfoScreen.Buttons.ShowRoutePercentages, boxTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.ShowRouteLevels, boxTopShadow)

	-- BOT BOX VIEW
	gui.defaultTextBackground(botBoxBGColor)
	local encounterHeaderText
	if encounterArea == RouteData.EncounterArea.STATIC then
		encounterHeaderText = string.format("%s %s", encounterArea, Resources.InfoScreen.LabelSeenEncounters)
	else
		encounterHeaderText = string.format("%s %s", Resources.InfoScreen.LabelSeenBy, encounterArea)
	end
	Drawing.drawText(boxX + 10, botBoxY - 11, encounterHeaderText, Theme.COLORS["Header text"], bgHeaderShadow)
	gui.drawRectangle(boxX, botBoxY, boxWidth, botBoxHeight, Theme.COLORS["Lower box border"], botBoxBGColor)

	local showPercents = InfoScreen.Buttons.ShowRoutePercentages.toggleState
	local showLevels = InfoScreen.Buttons.ShowRouteLevels.toggleState
	-- Don't clarify the pokemon are shown "in order of appearence" if the order is known
	if not (Options["Open Book Play Mode"] or LogOverlay.isDisplayed or showPercents or showLevels) then
		Drawing.drawText(boxX + 2, botBoxY, Resources.InfoScreen.LabelOrderAppearance .. ":", botBoxTextColor, boxBotShadow)
	end

	-- POKEMON SEEN
	local iconset = Options.getIconSet()
	for _, iconButton in pairs(InfoScreen.TemporaryButtons) do
		-- id 252 is the question mark icon
		if iconButton.pokemonID == 252 and iconset.adjustQuestionMark then
			iconButton.box[2] = iconButton.box[2] + (iconset.yOffset or 0)
		end

		local x = iconButton.box[1]
		local y = iconButton.box[2]
		Drawing.drawButton(iconButton, boxBotShadow)

		local iconInfoText = nil
		if showPercents and iconButton.rate ~= nil then
			iconInfoText = math.floor(iconButton.rate * 100) .. "%"
		elseif showLevels and iconButton.minLv ~= nil and iconButton.maxLv ~= nil then
			if iconButton.minLv == 0 and iconButton.maxLv == 0 then
				iconInfoText = Constants.HIDDEN_INFO
			else
				iconInfoText = string.format("%s - %s", math.floor(iconButton.minLv), math.floor(iconButton.maxLv))
			end
		end
		if iconInfoText ~= nil then
			local infoWidth = Utils.calcWordPixelLength(iconInfoText)
			local offsetX = math.floor((32 - infoWidth) / 2) - 2 -- center the text
			Drawing.drawTransparentTextbox(x + offsetX, y - 1, iconInfoText, botBoxTextColor, botBoxBGColor, boxBotShadow)
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.LookupRoute, boxTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.NextRoute, bgHeaderShadow)
	Drawing.drawButton(InfoScreen.Buttons.PreviousRoute, bgHeaderShadow)
	Drawing.drawButton(InfoScreen.Buttons.Back, boxBotShadow)
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
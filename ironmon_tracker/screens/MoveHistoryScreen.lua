MoveHistoryScreen = {
	Labels = {
		headerMoves = "Moves",
		headerMin = "Min Lv",
		headerMax = "Max Lv",
	},
	Colors = {
		text = "Lower box text",
		headerMoves = "Intermediate text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	pokemonID = nil,
}

MoveHistoryScreen.Buttons = {
	LookupPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 127, Constants.SCREEN.MARGIN + 3, 10, 10, },
		onClick = function(self)
			MoveHistoryScreen.openPokemonInfoWindow()
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			Program.changeScreenView(Program.Screens.TRACKER)
		end
	},
}

MoveHistoryScreen.TemporaryButtons = {}

function MoveHistoryScreen.initialize()
	for _, button in pairs(MoveHistoryScreen.Buttons) do
		button.textColor = MoveHistoryScreen.Colors.text
		button.boxColors = { MoveHistoryScreen.Colors.border, MoveHistoryScreen.Colors.boxFill }
	end
end

-- Lists out all known tracked moves for the Pokemon provided. If too many tracked moves, trims based on [startingLevel:optional]
function MoveHistoryScreen.buildOutHistory(pokemonID, startingLevel)
	if not PokemonData.isValid(pokemonID) then return false end

	MoveHistoryScreen.pokemonID = pokemonID
	startingLevel = startingLevel or 1
	MoveHistoryScreen.TemporaryButtons = {}

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local startY = Constants.SCREEN.MARGIN + 20
	local linespacing = Constants.SCREEN.LINESPACING + 0

	local trackedMoves = Tracker.getMoves(pokemonID)
	for _, tMove in ipairs(trackedMoves) do
		if MoveData.isValid(tMove.id) then -- Don't add in the placeholder moves
			local moveButton = {
				type = Constants.ButtonTypes.NO_BORDER,
				text = MoveData.Moves[tMove.id].name,
				textColor = MoveHistoryScreen.Colors.text,
				trackedMove = tMove,
				isVisible = function() return true end,
				onClick = function(self)
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, tMove.id)
				end
			}
			table.insert(MoveHistoryScreen.TemporaryButtons, moveButton)
		end
	end

	-- Sort based on min level seen, or last level seen, in descending order
	local sortFunc = function(a, b)
		if a.trackedMove.minLv ~= nil and b.trackedMove.minLv ~= nil then
			return a.trackedMove.minLv > b.trackedMove.minLv
		else
			return a.trackedMove.level > b.trackedMove.level
		end
	end
	table.sort(MoveHistoryScreen.TemporaryButtons, sortFunc)

	-- For now, only show 10 most relevant moves. Later figure it out based on startingLevel
	while #MoveHistoryScreen.TemporaryButtons > 10 do
		table.remove(MoveHistoryScreen.TemporaryButtons)
	end

	for _, button in ipairs(MoveHistoryScreen.TemporaryButtons) do
		button.box = { startX, startY, 80, 10 }
		startY = startY + linespacing
	end

	return true
end

function MoveHistoryScreen.openPokemonInfoWindow()
	Program.destroyActiveForm()
	local pokedexLookup = forms.newform(360, 105, "Pokedex Look up", function() client.unpause() end)
	Program.activeFormId = pokedexLookup
	Utils.setFormLocation(pokedexLookup, 100, 50)

	local pokemonName
	if PokemonData.isValid(MoveHistoryScreen.pokemonID) then
		pokemonName = PokemonData.Pokemon[MoveHistoryScreen.pokemonID].name
	else
		pokemonName = ""
	end
	local pokedexData = PokemonData.namesToList()

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
			if MoveHistoryScreen.buildOutHistory(pokemonId) then
				Program.redraw(true)
			end
		end
		client.unpause()
		forms.destroy(pokedexLookup)
	end, 212, 29)
end

-- DRAWING FUNCTIONS
function MoveHistoryScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[MoveHistoryScreen.Colors.boxFill])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[MoveHistoryScreen.Colors.boxFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2)

	if not PokemonData.isValid(MoveHistoryScreen.pokemonID) then
		for _, button in pairs(MoveHistoryScreen.Buttons) do
			Drawing.drawButton(button, shadowcolor)
		end
		return
	end

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[MoveHistoryScreen.Colors.border], Theme.COLORS[MoveHistoryScreen.Colors.boxFill])

	-- Draw header text
	local pokemonName = PokemonData.Pokemon[MoveHistoryScreen.pokemonID].name:upper()
	if Theme.DRAW_TEXT_SHADOWS then
		Drawing.drawText(topboxX + 2, topboxY + 2, pokemonName, shadowcolor, nil, 12, Constants.Font.FAMILY, "bold")
	end
	Drawing.drawText(topboxX + 1, topboxY + 1, pokemonName, Theme.COLORS[MoveHistoryScreen.Colors.text], nil, 12, Constants.Font.FAMILY, "bold")
	topboxY = topboxY + Constants.SCREEN.LINESPACING + 4

	-- Draw all moves in the tracked move history
	local moveOffset = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local minOffset = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 80
	local maxOffset = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 110

	Drawing.drawText(moveOffset, topboxY, MoveHistoryScreen.Labels.headerMoves, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(minOffset - 5, topboxY, MoveHistoryScreen.Labels.headerMin, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(maxOffset - 5, topboxY, MoveHistoryScreen.Labels.headerMax, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	topboxY = topboxY + Constants.SCREEN.LINESPACING

	for _, button in pairs(MoveHistoryScreen.TemporaryButtons) do
		Drawing.drawText(moveOffset, topboxY, button.text, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
		Drawing.drawNumber(minOffset, topboxY, button.trackedMove.minLv or button.trackedMove.level, 3, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
		Drawing.drawNumber(maxOffset, topboxY, button.trackedMove.maxLv or button.trackedMove.level, 3, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
		topboxY = topboxY + Constants.SCREEN.LINESPACING
	end

	-- Draw all buttons
	for _, button in pairs(MoveHistoryScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
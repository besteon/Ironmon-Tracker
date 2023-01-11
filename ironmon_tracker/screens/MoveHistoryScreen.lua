MoveHistoryScreen = {
	Labels = {
		headerMoves = "Move seen at level:",
		headerMin = "Min",
		headerMax = "Max",
		noTrackedMoves = "(No tracked move data yet)",
		pageFormat = "Page %s/%s" -- e.g. Page 1/3
	},
	Colors = {
		text = "Lower box text",
		headerMoves = "Intermediate text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	pokemonID = nil,
}

MoveHistoryScreen.Pagination = {
	currentPage = 0,
	totalPages = 0,
	itemsPerPage = 7,
	getPageText = function(self)
		if self.totalPages <= 1 then return "Page" end
		return string.format(MoveHistoryScreen.Labels.pageFormat, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
}

MoveHistoryScreen.Buttons = {
	LookupPokemon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 127, Constants.SCREEN.MARGIN + 4, 10, 10, },
		onClick = function(self)
			MoveHistoryScreen.openPokemonInfoWindow()
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return MoveHistoryScreen.Pagination.totalPages > 1 end,
		updateText = function(self)
			self.text = MoveHistoryScreen.Pagination:getPageText()
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return MoveHistoryScreen.Pagination.totalPages > 1 end,
		onClick = function(self)
			MoveHistoryScreen.Pagination:prevPage()
			MoveHistoryScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return MoveHistoryScreen.Pagination.totalPages > 1 end,
		onClick = function(self)
			MoveHistoryScreen.Pagination:nextPage()
			MoveHistoryScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 136, 24, 11 },
		onClick = function(self)
			if InfoScreen.infoLookup == nil or InfoScreen.infoLookup == 0 then
				Program.changeScreenView(Program.Screens.TRACKER)
			else
				Program.changeScreenView(Program.Screens.INFO)
			end
		end
	},
}

MoveHistoryScreen.TemporaryButtons = {}

function MoveHistoryScreen.initialize()
	for _, button in pairs(MoveHistoryScreen.Buttons) do
		button.textColor = MoveHistoryScreen.Colors.text
		button.boxColors = { MoveHistoryScreen.Colors.border, MoveHistoryScreen.Colors.boxFill }
	end
	MoveHistoryScreen.Buttons.CurrentPage:updateText()
end

-- Lists out all known tracked moves for the Pokemon provided. If too many tracked moves, trims based on [startingLevel:optional]
function MoveHistoryScreen.buildOutHistory(pokemonID, startingLevel)
	if not PokemonData.isValid(pokemonID) then return false end

	MoveHistoryScreen.pokemonID = pokemonID
	startingLevel = startingLevel or 1
	MoveHistoryScreen.TemporaryButtons = {}

	local trackedMoves = Tracker.getMoves(pokemonID)
	for _, tMove in ipairs(trackedMoves) do
		if MoveData.isValid(tMove.id) then -- Don't add in the placeholder moves
			local moveButton = {
				type = Constants.ButtonTypes.NO_BORDER,
				text = MoveData.Moves[tMove.id].name,
				textColor = MoveHistoryScreen.Colors.text,
				trackedMove = tMove,
				isVisible = function(self) return self.pageVisible == MoveHistoryScreen.Pagination.currentPage end,
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

	-- After sorting the moves, determine which are visible on which page, and where on the page vertically
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 12
	local startY = Constants.SCREEN.MARGIN + 55
	local linespacing = Constants.SCREEN.LINESPACING + 0

	for index, button in ipairs(MoveHistoryScreen.TemporaryButtons) do
		local pageItemIndex = ((index - 1) % MoveHistoryScreen.Pagination.itemsPerPage) + 1
		button.box = { startX, startY + (pageItemIndex - 1) * linespacing, 80, 10 }
		button.pageVisible = math.ceil(index / MoveHistoryScreen.Pagination.itemsPerPage)
	end

	MoveHistoryScreen.Pagination.currentPage = 1
	MoveHistoryScreen.Pagination.totalPages = math.ceil(#MoveHistoryScreen.TemporaryButtons / MoveHistoryScreen.Pagination.itemsPerPage)
	MoveHistoryScreen.Buttons.CurrentPage:updateText()

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

	MoveHistoryScreen.drawMovesLearnedBoxes(topboxX + 1, topboxY + 1)
	topboxY = topboxY + Constants.SCREEN.LINESPACING * 2 + 8

	-- Draw all moves in the tracked move history
	local offsetX = topboxX + 13
	local minColX, maxColX = 74, 99
	Drawing.drawText(offsetX - 8, topboxY, MoveHistoryScreen.Labels.headerMoves, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(offsetX + minColX, topboxY, MoveHistoryScreen.Labels.headerMin, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(offsetX + maxColX, topboxY, MoveHistoryScreen.Labels.headerMax, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	topboxY = topboxY + Constants.SCREEN.LINESPACING

	for _, button in ipairs(MoveHistoryScreen.TemporaryButtons) do
		if button:isVisible() then
			local minLvTxt = button.trackedMove.minLv or button.trackedMove.level
			local maxLvTxt = button.trackedMove.maxLv or button.trackedMove.level
			Drawing.drawText(button.box[1], button.box[2], button.text, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
			Drawing.drawNumber(button.box[1] + minColX + 3, button.box[2], minLvTxt, 2, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
			Drawing.drawNumber(button.box[1] + maxColX + 3, button.box[2], maxLvTxt, 2, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
		end
	end

	if #MoveHistoryScreen.TemporaryButtons == 0 then
		Drawing.drawText(offsetX, topboxY + 5, MoveHistoryScreen.Labels.noTrackedMoves, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
	end

	-- Draw all buttons
	for _, button in pairs(MoveHistoryScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

function MoveHistoryScreen.drawMovesLearnedBoxes(offsetX, offsetY)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[MoveHistoryScreen.Colors.boxFill])

	local pokemon = PokemonData.Pokemon[MoveHistoryScreen.pokemonID]
	local movelvls = pokemon.movelvls[GameSettings.versiongroup]

	-- Used for highlighting which moves have already been learned, but only for the Pokémon actively being viewed
	local pokemonViewed = Tracker.getViewedPokemon() or Tracker.getDefaultPokemon()
	local viewedPokemonLevel
	if pokemonViewed.pokemonID == pokemon.pokemonID then
		viewedPokemonLevel = pokemonViewed.level
	else
		viewedPokemonLevel = 0
	end

	local boxWidth = 16
	local boxHeight = 13
	if #movelvls == 0 then -- If the Pokemon learns no moves at all
		Drawing.drawText(offsetX + 6, offsetY, "Does not learn any moves", Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
	end
	for i, moveLvl in ipairs(movelvls) do -- 14 is the greatest number of moves a gen3 Pokemon can learn
		local nextBoxX = ((i - 1) % 8) * boxWidth -- 8 possible columns
		local nextBoxY = Utils.inlineIf(i <= 8, 0, 1) * boxHeight -- 2 possible rows
		local lvlSpacing = (2 - string.len(tostring(moveLvl))) * 3

		-- Draw the level box
		gui.drawRectangle(offsetX + nextBoxX + 5 + 1, offsetY + nextBoxY + 2, boxWidth, boxHeight, shadowcolor, shadowcolor)
		gui.drawRectangle(offsetX + nextBoxX + 5, offsetY + nextBoxY + 1, boxWidth, boxHeight, Theme.COLORS[MoveHistoryScreen.Colors.border], Theme.COLORS[MoveHistoryScreen.Colors.boxFill])

		-- Indicate which moves have already been learned if the Pokemon being viewed is one of the ones in battle (yours/enemy)
		local nextBoxTextColor
		if viewedPokemonLevel == 0 then
			nextBoxTextColor = Theme.COLORS[MoveHistoryScreen.Colors.text]
		elseif moveLvl <= viewedPokemonLevel then
			nextBoxTextColor = Theme.COLORS["Negative text"]
		else
			nextBoxTextColor = Theme.COLORS["Positive text"]
		end

		-- Draw the level inside the box
		Drawing.drawText(offsetX + nextBoxX + 7 + lvlSpacing, offsetY + nextBoxY + 2, moveLvl, nextBoxTextColor, shadowcolor)
	end

	return Utils.inlineIf(#movelvls <= 8, 1, 2) -- return number of lines drawn
end
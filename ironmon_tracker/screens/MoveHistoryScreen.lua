MoveHistoryScreen = {
	Labels = {
		headerMoves = "Moves used",
		headerLevelSeen = "Level seen:",
		headerMin = "Min",
		headerMax = "Max",
		pageFormat = "Page %s/%s" -- Page 1/3
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
	itemsPerPage = 9,
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
		image = Constants.PixelImages.PREVIOUS_BUTTON,
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
		image = Constants.PixelImages.NEXT_BUTTON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return MoveHistoryScreen.Pagination.totalPages > 1 end,
		onClick = function(self)
			MoveHistoryScreen.Pagination:prevPage()
			MoveHistoryScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
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
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 13
	local startY = Constants.SCREEN.MARGIN + 33
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
	topboxY = topboxY + Constants.SCREEN.LINESPACING + 11

	-- Draw all moves in the tracked move history
	local offsetX = topboxX + 13
	Drawing.drawText(offsetX + 71, topboxY - 9, MoveHistoryScreen.Labels.headerLevelSeen, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(offsetX, topboxY, MoveHistoryScreen.Labels.headerMoves, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(offsetX + 71, topboxY, MoveHistoryScreen.Labels.headerMin, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	Drawing.drawText(offsetX + 97, topboxY, MoveHistoryScreen.Labels.headerMax, Theme.COLORS[MoveHistoryScreen.Colors.headerMoves], shadowcolor)
	topboxY = topboxY + Constants.SCREEN.LINESPACING

	for _, button in pairs(MoveHistoryScreen.TemporaryButtons) do
		if button:isVisible() then
			local minLvTxt = button.trackedMove.minLv or button.trackedMove.level
			local maxLvTxt = button.trackedMove.maxLv or button.trackedMove.level
			Drawing.drawText(button.box[1], button.box[2], button.text, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
			Drawing.drawNumber(button.box[1] + 71, button.box[2], minLvTxt, 2, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
			Drawing.drawNumber(button.box[1] + 97, button.box[2], maxLvTxt, 2, Theme.COLORS[MoveHistoryScreen.Colors.text], shadowcolor)
		end
	end

	-- Draw all buttons
	for _, button in pairs(MoveHistoryScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
LogTabPokemon = {
	TitleResourceKey = "HeaderTabPokemon", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	TabIcons = {
		NidoranM = {
			image = FileManager.buildImagePath("icons", "tiny-nidoranm", ".png"),
			x = 1, y = 0,
			w = 12, h = 14,
		},
		NidoranF = {
			image = FileManager.buildImagePath("icons", "tiny-nidoranf", ".png"),
			x = 1, y = 0,
			w = 12, h = 14,
		},
		Pidgey = {
			image = FileManager.buildImagePath("icons", "tiny-pidgey", ".png"),
			x = 0, y = 0,
			w = 16, h = 12,
		},
		Spearow = {
			image = FileManager.buildImagePath("icons", "tiny-spearow", ".png"),
			x = 0, y = 0,
			w = 16, h = 12,
		},
		Jigglypuff = {
			image = FileManager.buildImagePath("icons", "tiny-jigglypuff", ".png"),
			x = 1, y = 0,
			w = 11, h = 12,
		},
		Clefairy = {
			image = FileManager.buildImagePath("icons", "tiny-clefairy", ".png"),
			x = 0, y = 0,
			w = 14, h = 13,
		},
		Omanyte = {
			image = FileManager.buildImagePath("icons", "tiny-omanyte", ".png"),
			x = 0, y = 0,
			w = 13, h = 14,
		},
		Kabuto = {
			image = FileManager.buildImagePath("icons", "tiny-kabuto", ".png"),
			x = 0, y = 0,
			w = 14, h = 13,
		},
		chosenIcon = nil, -- references the 1st chosen icon used
	},
	defaultIconCount = 2,
	defaultSortKey = "PokedexNum",
	defaultFilterKey = "PokemonName",
}

LogTabPokemon.PagedButtons = {}

function LogTabPokemon.initialize()

end

function LogTabPokemon.refreshButtons()
	for _, button in pairs(LogTabPokemon.PagedButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabPokemon.rebuild()
	LogTabPokemon.realignGrid()
end

-- Returns N=amount randomly choosen unique icons for this tab
function LogTabPokemon.getTabIcons(amount)
	amount = math.max(amount or LogTabPokemon.defaultIconCount or 1, 1)
	local icons = {}
	for _, icon in pairs(LogTabPokemon.TabIcons or {}) do
		icon.randomizedIndex = math.random(16000)
		table.insert(icons, icon)
	end
	if (#icons - amount) <= 1 then
		return icons
	end
	-- Remove all but N items at random
	for i=1, (#icons - amount), 1 do
		table.remove(icons, math.random(#icons))
	end
	return Utils.getSortedList(icons, "randomizedIndex")
end

function LogTabPokemon.buildPagedButtons()
	LogTabPokemon.PagedButtons = {}

	for id, pokemon in pairs(RandomizerLog.Data.Pokemon) do
		local button = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			id = id,
			getText = function(self) return RandomizerLog.getPokemonName(id) end,
			textColor = LogTabPokemon.Colors.text,
			boxColors = { LogTabPokemon.Colors.border, LogTabPokemon.Colors.boxFill },
			dimensions = { width = 32, height = 32, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- If no search text entered, show all
				if Utils.isNilOrEmpty(LogSearchScreen.searchText) then
					return true
				end

				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
					if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
						return true
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
					for _, abilityId in pairs(pokemon.Abilities) do
						local abilityText = AbilityData.Abilities[abilityId].name
						if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
							return true
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
					for _, move in pairs(pokemon.MoveSet) do
						local moveText = move.name -- potentially a custom move name
						if MoveData.isValid(move.moveId) then
							moveText = MoveData.Moves[move.moveId].name
						end
						if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
							return true
						end
					end
				end

				return false
			end,
			getIconId = function(self) return self.id, SpriteData.Types.Idle end,
			onClick = function(self)
				LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.id)
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local textColor = Theme.COLORS[self.textColor]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				-- Draw the Pokemon's name above the icon
				local pokemonName = self:getText() or ""
				local nameWidth = Utils.calcWordPixelLength(pokemonName)
				local offsetX = math.floor((self.box[3] - nameWidth) / 2) - 2
				Drawing.drawTransparentTextbox(x + offsetX, y - 2, pokemonName, textColor, bgColor, shadowcolor)
			end,
		}
		table.insert(LogTabPokemon.PagedButtons, button)
	end

	-- First main page viewed by default is the Pokemon Window, so set that up now
	if LogOverlay.isDisplayed then
		LogTabPokemon.realignGrid()
	end
end

function LogTabPokemon.realignGrid(gridFilter, sortFunc, startingPage)
	-- Default grid to Pokédex number
	gridFilter = gridFilter or "#"
	startingPage = startingPage or 1

	if sortFunc or LogSearchScreen.currentSortOrder then
		sortFunc = sortFunc or LogSearchScreen.currentSortOrder.sortFunc --pokedexNumber
		table.sort(LogTabPokemon.PagedButtons, sortFunc)
	end

	local x = LogOverlay.TabBox.x + 19
	local y = LogOverlay.TabBox.y + 2
	local colSpacer = 23
	local rowSpacer = 4
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = Utils.gridAlign(LogTabPokemon.PagedButtons, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabPokemon.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabPokemon.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabPokemon.PagedButtons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabPokemon.drawTab()
	local textColor = Theme.COLORS[LogTabPokemon.Colors.text]
	local borderColor = Theme.COLORS[LogTabPokemon.Colors.border]
	local fillColor = Theme.COLORS[LogTabPokemon.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw the paged items
	local atLeastOne = false
	for _, button in pairs(LogTabPokemon.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
		if not atLeastOne and button:isVisible() then
			atLeastOne = true
		end
	end

	if not atLeastOne then
		LogSearchScreen.drawNoSearchResults(textColor, shadowcolor)
	end
end

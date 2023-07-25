LogTabPokemon = {
	TitleResourceKey = "HeaderTabPokemon", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	}
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

function LogTabPokemon.buildPagedButtons()
	LogTabPokemon.PagedButtons = {}

	for id, pokemon in pairs(RandomizerLog.Data.Pokemon) do
		local button = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			id = id,
			getText = function(self)
				-- When languages don't match, there's no way to tell if the name in the log is a custom name or not, assume it's not
				if RandomizerLog.areLanguagesMismatched() then
					return PokemonData.Pokemon[id].name or Constants.BLANKLINE
				else
					return pokemon.Name or PokemonData.Pokemon[id].name or Constants.BLANKLINE
				end
			end,
			textColor = LogTabPokemon.Colors.text,
			boxColors = { LogTabPokemon.Colors.border, LogTabPokemon.Colors.boxFill },
			dimensions = { width = 32, height = 32, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- If no search text entered, show all
				if LogSearchScreen.searchText == "" then
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
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.id), iconset.extension)
			end,
			onClick = function(self)
				LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.id)
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
			end,
			draw = function(self, shadowcolor)
				-- Draw the Pokemon's name above the icon
				gui.drawRectangle(self.box[1], self.box[2] + 1 - 1, 32, 8, Theme.COLORS[self.boxColors[2]], Theme.COLORS[self.boxColors[2]])
				Drawing.drawText(self.box[1] - 5, self.box[2] - 1, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
		}
		table.insert(LogTabPokemon.PagedButtons, button)
	end

	-- First main page viewed by default is the Pokemon Window, so set that up now
	LogTabPokemon.realignGrid()
end

function LogTabPokemon.realignGrid(gridFilter, sortFunc, startingPage)
	-- Default grid to Pokédex number
	gridFilter = gridFilter or "#"
	sortFunc = sortFunc or LogSearchScreen.currentSortOrder.sortFunc --pokedexNumber
	startingPage = startingPage or 1

	table.sort(LogTabPokemon.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 19
	local y = LogOverlay.TabBox.y + 1
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
	local borderColor = Theme.COLORS[LogTabPokemon.Colors.border]
	local fillColor = Theme.COLORS[LogTabPokemon.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw the paged items
	for _, button in pairs(LogTabPokemon.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

LogTabRoutes = {
	TitleResourceKey = "HeaderTabRoutes", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		hightlight = "Intermediate text",
	},
	defaultSortKey = "TrainerLevel",
	defaultFilterKey = "RouteName",
}

LogTabRoutes.PagedButtons = {}

function LogTabRoutes.initialize()

end

function LogTabRoutes.refreshButtons()
	for _, button in pairs(LogTabRoutes.PagedButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabRoutes.rebuild()
	LogTabRoutes.realignGrid(LogOverlay.Windower.filterGrid)
end

function LogTabRoutes.buildPagedButtons()
	LogTabRoutes.PagedButtons = {}

	for mapId, route in pairs(RandomizerLog.Data.Routes) do
		local routeInfo = RouteData.Info[mapId] or {}
		local routeName = routeInfo.name or Utils.firstToUpper(route.name)
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return routeName end,
			id = mapId,
			avgTrainerLv = route.avgTrainerLv,
			avgWildLv = route.avgWildLv,
			filename = routeInfo.filename,
			dimensions = { width = 90, height = 20, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Exclude routes without trainers/wilds if a sort using those is selected
				if LogSearchScreen.currentSortOrder == LogSearchScreen.SortBy.TrainerLevel and self.avgTrainerLv == 0 then
					return false
				elseif LogSearchScreen.currentSortOrder == LogSearchScreen.SortBy.WildPokemonLevel and self.avgWildLv == 0 then
					return false
				end

				-- If no search text entered, check any filter groups
				if LogSearchScreen.searchText == "" then
					-- TODO: Optional nav filters; currently none available, therefore show all
					return true
				end

				local trainersInArea = (route.EncountersAreas["Trainers"] or {}).trainers or {}
				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.RouteName then
					if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
						return true
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.TrainerName then
					for _, trainerId in ipairs(trainersInArea) do
						local trainer = RandomizerLog.Data.Trainers[trainerId] or {}
						if Utils.containsText(trainer.name, LogSearchScreen.searchText, true) then
							return true
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
					-- First check if any trainers have a Pokemon with this name
					for _, trainerId in ipairs(trainersInArea) do
						local trainer = RandomizerLog.Data.Trainers[trainerId] or {}
						for _, partyMon in ipairs(trainer.party or {}) do
							local pokemonName = RandomizerLog.getPokemonName(partyMon.pokemonID)
							if Utils.containsText(pokemonName, LogSearchScreen.searchText, true) then
								return true
							end
						end
					end
					-- Then check any wild encounters
					for _, encArea in pairs(route.EncountersAreas or {}) do
						for pokemonID, _ in pairs(encArea.pokemon or {}) do
							local pokemonName = RandomizerLog.getPokemonName(pokemonID)
							if Utils.containsText(pokemonName, LogSearchScreen.searchText, true) then
								return true
							end
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
					-- Only check trainers in this area for a searched ability
					for _, trainerId in ipairs(trainersInArea) do
						local trainer = RandomizerLog.Data.Trainers[trainerId] or {}
						for _, partyMon in ipairs(trainer.party or {}) do
							for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
								local abilityText = AbilityData.Abilities[abilityId].name
								if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
									return true
								end
							end
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
					-- Only check trainers in this area for a searched move
					for _, trainerId in ipairs(trainersInArea) do
						local trainer = RandomizerLog.Data.Trainers[trainerId] or {}
						for _, partyMon in ipairs(trainer.party or {}) do
							for _, moveId in ipairs(partyMon.moveIds or {}) do
								local moveText = MoveData.Moves[moveId].name
								if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
									return true
								end
							end
						end
					end
				end

				return false
			end,
			onClick = function(self)
				LogOverlay.Windower:changeTab(LogTabRouteDetails, 1, 1, self.id)
				Program.redraw(true)
			end,
			draw = function(self, shadowcolor)
				-- -- Draw a centered box for the Trainer's name
				-- local nameWidth = Utils.calcWordPixelLength(self:getText())
				-- local bottomPadding = 9
				-- local offsetX = self.box[1] + self.box[3] / 2 - nameWidth / 2
				-- local offsetY = self.box[2] + TrainerData.FileInfo.maxHeight - bottomPadding - (self.dimensions.extraY or 0)
				-- gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabRoutes.Colors.border], Theme.COLORS[LogTabRoutes.Colors.boxFill])
				-- Drawing.drawText(offsetX, offsetY, self:getText(), Theme.COLORS[LogTabRoutes.Colors.text], shadowcolor)
				-- gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabRoutes.Colors.border]) -- to cutoff the shadows
			end,
		}

		table.insert(LogTabRoutes.PagedButtons, button)
	end
end

function LogTabRoutes.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or ""
	sortFunc = sortFunc or LogSearchScreen.SortBy.Alphabetical.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabRoutes.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 15
	local y = LogOverlay.TabBox.y + 5
	local colSpacer = 12
	local rowSpacer = 4
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = Utils.gridAlign(LogTabRoutes.PagedButtons, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabRoutes.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabRoutes.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRoutes.PagedButtons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabRoutes.drawTab()
	local textColor = Theme.COLORS[LogTabRoutes.Colors.text]
	local borderColor = Theme.COLORS[LogTabRoutes.Colors.border]
	local fillColor = Theme.COLORS[LogTabRoutes.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw the paged items
	for _, button in pairs(LogTabRoutes.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

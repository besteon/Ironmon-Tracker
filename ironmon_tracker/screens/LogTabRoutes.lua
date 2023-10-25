LogTabRoutes = {
	TitleResourceKey = "HeaderTabRoutes", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		highlight = "Intermediate text",
	},
	TabIcons = {
		Kanto = {
			image = FileManager.buildImagePath("icons", "tiny-map-kanto", ".png"),
			x = 1, w = 15, h = 11,
		},
		Hoenn = {
			image = FileManager.buildImagePath("icons", "tiny-map-hoenn", ".png"),
			x = 1, w = 15, h = 11,
		},
	},
	chosenIcon = nil,
	defaultSortKey = "WildPokemonLevel",
	defaultFilterKey = "RouteName",
	levelRangeSpacer = "--",
}

LogTabRoutes.TemporaryButtons = {}
LogTabRoutes.PagedButtons = {}

function LogTabRoutes.initialize()

end

function LogTabRoutes.refreshButtons()
	for _, button in pairs(LogTabRoutes.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabRoutes.PagedButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

-- Returns the Hoenn(i=1) or Kanto(i=3) map icon
function LogTabRoutes.getTabIcons(gameIndex)
	gameIndex = gameIndex or GameSettings.game
	if gameIndex == 1 or gameIndex == 2 then
		return { LogTabRoutes.TabIcons.Hoenn }
	else
		return { LogTabRoutes.TabIcons.Kanto }
	end
end

function LogTabRoutes.rebuild()
	LogTabRoutes.realignGrid(LogOverlay.Windower.filterGrid)
end

function LogTabRoutes.buildPagedButtons()
	LogTabRoutes.TemporaryButtons = {}
	LogTabRoutes.PagedButtons = {}

	-- Header label buttons for the route bars
	local rightOffsetX = 0
	local routeBar = {
		width = 230,
		height = 21,
		cols = {
			{
				w = 21,
			},
			{
				getText = function() return Utils.toUpperUTF8(Resources.LogOverlay.LabelLocation) end,
				w = 105
			},
			{
				icon = LogTabPokemon.TabIcons.NidoranM,
				w = 18,
				textColor = "Lower box text",
				boxFill = "Lower box background",
			},
			{
				getText = function() return Utils.toUpperUTF8(Resources.TrackerScreen.LevelAbbreviation .. ".") end,
				w = 34,
				textColor = "Lower box text",
				boxFill = "Lower box background",
			},
			{
				icon = LogTabTrainers.chosenIcon or LogTabTrainers.TabIcons.BoyFRLG,
				w = 18,
			},
			{
				getText = function() return Utils.toUpperUTF8(Resources.TrackerScreen.LevelAbbreviation .. ".") end,
				w = 34,
			},
		},
	}
	-- Build the column positions from right-to-left
	for i = #routeBar.cols, 1, -1 do
		rightOffsetX = rightOffsetX + routeBar.cols[i].w
		routeBar.cols[i].x = routeBar.width - rightOffsetX
	end

	-- Build grid header icons/labels
	for i, col in ipairs(routeBar.cols) do
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			textColor = LogTabRoutes.Colors.highlight,
			box = { LogOverlay.TabBox.x + col.x + 3, LogOverlay.TabBox.y + 1, 16, 16 },
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				if col.icon then
					local adjustedX = x + (w - (col.icon.w or 0)) / 2 + 1
					local adjustedY = y + (col.icon.y or 0) + (h - (col.icon.h or 12)) - 1
					Drawing.drawImage(col.icon.image, adjustedX, adjustedY)
					-- local centeredX = (w - (col.icon.w or 0)) / 2 + 2
					-- Drawing.drawImage(col.icon.image, x + centeredX, y + 1)
				end
				if type(col.getText) == "function" then
					local adjustedX = x + 3
					if i > 2 then -- for "LVs"
						adjustedX = x + Utils.getCenteredTextX(col:getText(), col.w) - 1
					end
					Drawing.drawText(adjustedX, y + 4, col:getText(), Theme.COLORS[self.textColor], shadowcolor)
				end
			end,
		}
		table.insert(LogTabRoutes.TemporaryButtons, button)
	end

	-- Each route is bar of information
	for mapId, route in pairs(RandomizerLog.Data.Routes) do
		local routeInternal = RouteData.Info[mapId] or {}
		local routeName =  Utils.firstToUpperEachWord(route.name or routeInternal.name)
		local routeIcon = routeInternal.icon or RouteData.Icons.RouteSign

		local rowButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return routeName end,
			id = mapId,
			numTrainers = route.numTrainers,
			minTrainerLv = route.minTrainerLv,
			maxTrainerLv = route.maxTrainerLv,
			avgTrainerLv = route.avgTrainerLv,
			numWilds = route.numWilds,
			minWildLv = route.minWildLv,
			maxWildLv = route.maxWildLv,
			filename = routeInternal.filename,
			dimensions = { width = routeBar.width, height = routeBar.height, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			updateSelf = function(self)
				if not self.box then return end
				-- Make the clickable area just a tad smaller to prevent overlappying clicks
				self.clickableArea = { self.box[1], self.box[2] + 1, self.box[3], self.box[4] - 2, }
			end,
			includeInGrid = function(self)
				-- If no search text entered, check any filter groups and/or show all results
				if Utils.isNilOrEmpty(LogSearchScreen.searchText) then
					-- (Optional nav filters would go here)
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
						if Utils.containsText(trainer.fullname, LogSearchScreen.searchText, true) then
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
				-- Find first available enoucnter area
				local encounterArea
				for _, encType in ipairs(Utils.getSortedList(RandomizerLog.EncounterTypes)) do
					if encType.logKey ~= RandomizerLog.EncounterTypes.Trainers.logKey then
						encounterArea = encType.internalArea
						break
					end
				end
				if route.numWilds > 0 and RouteData.hasRouteEncounterArea(self.id, encounterArea) then
					local routeInfo = {
						mapId = self.id,
						encounterArea = encounterArea,
					}
					InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
				else
					Program.redraw(true)
				end

			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local centeredY = (h - Constants.Font.SIZE) / 2
				local textColor = Theme.COLORS[LogTabRoutes.Colors.text]

				-- Row boxes / dividers
				for _, col in ipairs(routeBar.cols) do
					local borderColor = Theme.COLORS[LogTabRoutes.Colors.border]
					local fillColor = Theme.COLORS[col.boxFill or false] or Theme.COLORS[LogTabRoutes.Colors.boxFill]
					gui.drawRectangle(x + col.x, y, col.w, h, borderColor, fillColor)
				end

				-- Icon
				if routeIcon then
					local adjustedX = x + routeBar.cols[1].x + 1 + (routeIcon.x or 0)
					local adjustedY = y + 1 + (routeIcon.y or 0)
					Drawing.drawImage(routeIcon:getIconPath(), adjustedX, adjustedY)
				end

				-- Route Name
				textColor = Theme.COLORS[routeBar.cols[2].textColor or false] or Theme.COLORS[LogTabRoutes.Colors.text]
				Drawing.drawText(x + routeBar.cols[2].x + 3, y + centeredY, self:getText(), textColor, shadowcolor)

				local col, text, centeredX
				-- # Wilds and levels
				if (self.numWilds or 0) > 0 then
					col = routeBar.cols[3]
					textColor = Theme.COLORS[col.textColor or false] or Theme.COLORS[LogTabRoutes.Colors.text]
					local shadowcolor2 = Utils.calcShadowColor(Theme.COLORS[col.boxFill or false] or Theme.COLORS[LogTabRoutes.Colors.boxFill])
					text = tostring(self.numWilds or 0)
					centeredX = Utils.getCenteredTextX(text, col.w) - 1
					Drawing.drawText(x + col.x + centeredX, y + centeredY, text, textColor, shadowcolor2)
					col = routeBar.cols[4]
					textColor = Theme.COLORS[col.textColor or false] or Theme.COLORS[LogTabRoutes.Colors.text]
					shadowcolor2 = Utils.calcShadowColor(Theme.COLORS[col.boxFill or false] or Theme.COLORS[LogTabRoutes.Colors.boxFill])
					text = string.format("%s %s %s", self.minWildLv, LogTabRoutes.levelRangeSpacer, self.maxWildLv)
					centeredX = Utils.getCenteredTextX(text, col.w)
					Drawing.drawText(x + col.x + centeredX, y + centeredY, text, textColor, shadowcolor2)
				end
				-- # Trainers and levels
				if (self.numTrainers or 0) > 0 then
					col = routeBar.cols[5]
					textColor = Theme.COLORS[col.textColor or false] or Theme.COLORS[LogTabRoutes.Colors.text]
					text = tostring(self.numTrainers or 0)
					centeredX = Utils.getCenteredTextX(text, col.w) - 1
					Drawing.drawText(x + col.x + centeredX, y + centeredY, text, textColor, shadowcolor)
					col = routeBar.cols[6]
					textColor = Theme.COLORS[col.textColor or false] or Theme.COLORS[LogTabRoutes.Colors.text]
					text = string.format("%s %s %s", self.minTrainerLv, LogTabRoutes.levelRangeSpacer, self.maxTrainerLv)
					centeredX = Utils.getCenteredTextX(text, col.w)
					Drawing.drawText(x + col.x + centeredX, y + centeredY, text, textColor, shadowcolor)
				end
			end,
		}

		-- Only show routes that have encounters
		if (route.avgTrainerLv or 0) ~= 0 or (route.maxWildLv or 0) ~= 0 then
			table.insert(LogTabRoutes.PagedButtons, rowButton)
		end
	end
end

function LogTabRoutes.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or ""
	sortFunc = sortFunc or LogSearchScreen.currentSortOrder.sortFunc or LogSearchScreen.SortBy.TrainerLevel.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabRoutes.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 3
	local y = LogOverlay.TabBox.y + 17
	local colSpacer = 999
	local rowSpacer = 0
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = Utils.gridAlign(LogTabRoutes.PagedButtons, x, y, colSpacer, rowSpacer, true, maxWidth, maxHeight)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabRoutes.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabRoutes.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabRoutes.TemporaryButtons)
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

	-- Draw all buttons
	for _, button in pairs(LogTabRoutes.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	local atLeastOne = false
	for _, button in pairs(LogTabRoutes.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
		if not atLeastOne and button:isVisible() then
			atLeastOne = true
		end
	end

	if not atLeastOne then
		LogSearchScreen.drawNoSearchResults(textColor, shadowcolor)
	end
end

LogTabRoutes = {
	TitleResourceKey = "HeaderTabRoutes", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		hightlight = "Intermediate text",
	}
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

	for mapId, routeData in pairs(RandomizerLog.Data.Routes) do
		local routeInfo = RouteData.Info[mapId] or {}
		local routeName = routeInfo.name or Utils.firstToUpper(routeData.name)
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return routeName end,
			id = mapId,
			filename = routeInfo.filename,
			dimensions = { width = 90, height = 20, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- If no search text entered, check any filter groups
				if LogSearchScreen.searchText == "" then
					-- TODO: Optional nav filters; currently none available
				end

				-- if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.TrainerName then
				-- 	if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
				-- 		return true
				-- 	end
				-- elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
				-- 	for _, partyMon in ipairs(trainerData.party or {}) do
				-- 		local name
				-- 		-- When languages don't match, there's no way to tell if the name in the log is a custom name or not, assume it's not
				-- 		if RandomizerLog.areLanguagesMismatched() then
				-- 			name = PokemonData.Pokemon[partyMon.pokemonID].name or Constants.BLANKLINE
				-- 		else
				-- 			name = RandomizerLog.Data.Pokemon[partyMon.pokemonID].Name or PokemonData.Pokemon[partyMon.pokemonID].name or Constants.BLANKLINE
				-- 		end
				-- 		if Utils.containsText(name, LogSearchScreen.searchText, true) then
				-- 			return true
				-- 		end
				-- 	end
				-- elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
				-- 	for _, partyMon in ipairs(trainerData.party or {}) do
				-- 		for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
				-- 			local abilityText = AbilityData.Abilities[abilityId].name
				-- 			if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
				-- 				return true
				-- 			end
				-- 		end
				-- 	end
				-- end

				return true

				-- TODO: Uncomment after adding in search filters above
				-- return false
			end,
			onClick = function(self)
				-- TODO: Uncomment after creating this log viewer screen file
				-- LogOverlay.Windower:changeTab(LogTabRouteDetails, 1, 1, self.id)
				InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, {
					mapId = self.id,
					encounterArea = RouteData.getNextAvailableEncounterArea(self.id),
				})
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

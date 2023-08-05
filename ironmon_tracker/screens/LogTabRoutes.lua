LogTabRoutes = {
	TitleResourceKey = "HeaderTabRoutes", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		hightlight = "Intermediate text",
	},
	TabIcons = {
		{
			x = 1, w = 15, h = 11,
			image = FileManager.buildImagePath("icons", "tiny-map-hoenn", ".png"),
		},
	},
	defaultSortKey = "TrainerLevel",
	defaultFilterKey = "RouteName",
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

function LogTabRoutes.rebuild()
	LogTabRoutes.realignGrid(LogOverlay.Windower.filterGrid)
end

function LogTabRoutes.buildPagedButtons()
	LogTabRoutes.TemporaryButtons = {}
	LogTabRoutes.PagedButtons = {}

	-- Header label buttons for the route bars
	local routeBar = { width = 224, height = 20, }
	routeBar.cols = {
		{
			x = 0,
		},
		{
			x = 20,
			-- TODO: Update resources
			getText = function() return Utils.toUpperUTF8("Location" or Resources.LogOverlay.X) end,
		},
		{
			x = routeBar.width - (20 * 4),
			w = 16,
			imageType = Constants.ButtonTypes.IMAGE,
			image = LogOverlay.getPlayerIconHead(),
		},
		{
			x = routeBar.width - (20 * 3),
			getText = function() return Utils.toUpperUTF8(Resources.TrackerScreen.LevelAbbreviation .. ".") end,
		},
		{
			x = routeBar.width - (20 * 2),
			w = 12,
			imageType = Constants.ButtonTypes.IMAGE,
			image = FileManager.buildImagePath("icons", "tiny-nidoranm", ".png"),
		},
		{
			x = routeBar.width - (20 * 1),
			getText = function() return Utils.toUpperUTF8(Resources.TrackerScreen.LevelAbbreviation .. ".") end,
		},
	}
	for _, headerLabel in ipairs(routeBar.cols) do
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			textColor = LogTabRoutes.Colors.hightlight,
			box = { LogOverlay.TabBox.x + 6 + headerLabel.x, LogOverlay.TabBox.y + 3, 16, 16 },
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				if headerLabel.image then
					if headerLabel.imageType == Constants.ButtonTypes.IMAGE then
						local centeredX = (self.box[3] - headerLabel.w) / 2 + 2
						gui.drawImage(headerLabel.image, x + centeredX, y + 1)
					elseif headerLabel.imageType == Constants.ButtonTypes.PIXELIMAGE then
						Drawing.drawImageAsPixels(headerLabel.image, x + 3, y, headerLabel.iconColors, shadowcolor)
					end
				end
				if type(headerLabel.getText) == "function" then
					Drawing.drawText(x + 3, self.box[2] + 4, headerLabel:getText(), Theme.COLORS[self.textColor], shadowcolor)
				end
			end,
		}
		table.insert(LogTabRoutes.TemporaryButtons, button)
	end

	-- Each route is bar of information
	for mapId, route in pairs(RandomizerLog.Data.Routes) do
		local routeInternal = RouteData.Info[mapId] or {}
		local routeName =  Utils.firstToUpperEachWord(route.name or routeInternal.name)
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return routeName end,
			id = mapId,
			numTrainers = route.numTrainers,
			avgTrainerLv = route.avgTrainerLv,
			numWilds = route.numWilds,
			maxWildLv = route.maxWildLv,
			filename = routeInternal.filename,
			dimensions = { width = routeBar.width, height = routeBar.height, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
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
				Program.redraw(true)
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local centeredY = (h - Constants.Font.SIZE) / 2

				-- Row boxes
				gui.drawRectangle(x, y, w, h, Theme.COLORS[LogTabRoutes.Colors.border], Theme.COLORS[LogTabRoutes.Colors.boxFill])
				for _, col in ipairs(routeBar.cols) do
					gui.drawLine(x + col.x, y, x + col.x, y + h, Theme.COLORS[LogTabRoutes.Colors.border])
				end
				-- Icon
				local tempIcon = FileManager.buildImagePath("maps", "icon-route-sign", ".png")
				gui.drawImage(tempIcon, x + 1, y + 1)
				-- Route Name
				Drawing.drawText(x + routeBar.cols[2].x + 3, y + centeredY, self:getText(), Theme.COLORS[LogTabRoutes.Colors.text], shadowcolor)
				-- Number of Trainers
				local text = tostring(self.numTrainers or 0)
				local centeredX = Utils.getCenteredTextX(text, 20) - 1
				if text ~= "0" then
					Drawing.drawText(x + routeBar.cols[3].x + centeredX, y + centeredY, text, Theme.COLORS[LogTabRoutes.Colors.text], shadowcolor)
				end
				-- Avg Trainer Level
				text = tostring(math.floor((self.avgTrainerLv or 0) + 0.5))
				if text ~= "0" then
					centeredX = Utils.getCenteredTextX(text, 20) - 1
					Drawing.drawText(x + routeBar.cols[4].x + centeredX, y + centeredY, text, Theme.COLORS[LogTabRoutes.Colors.text], shadowcolor)
				end
				-- Number of Wilds
				text = tostring(self.numWilds or 0)
				if text ~= "0" then
					centeredX = Utils.getCenteredTextX(text, 20) - 1
					Drawing.drawText(x + routeBar.cols[5].x + centeredX, y + centeredY, text, Theme.COLORS[LogTabRoutes.Colors.text], shadowcolor)
				end
				-- Max Wild Level
				text = tostring(math.floor((self.maxWildLv or 0) + 0.5))
				if text ~= "0" then
					centeredX = Utils.getCenteredTextX(text, 20) - 1
					Drawing.drawText(x + routeBar.cols[6].x + centeredX, y + centeredY, text, Theme.COLORS[LogTabRoutes.Colors.text], shadowcolor)
				end
			end,
		}

		-- Only show routes that have encounters
		if (route.avgTrainerLv or 0) ~= 0 or (route.maxWildLv or 0) ~= 0 then
			table.insert(LogTabRoutes.PagedButtons, button)
		end
	end
end

function LogTabRoutes.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or ""
	sortFunc = sortFunc or LogSearchScreen.currentSortOrder.sortFunc or LogSearchScreen.SortBy.TrainerLevel.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabRoutes.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 6
	local y = LogOverlay.TabBox.y + 19
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
	for _, button in pairs(LogTabRoutes.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

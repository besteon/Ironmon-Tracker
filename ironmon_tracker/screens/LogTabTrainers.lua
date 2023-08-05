LogTabTrainers = {
	TitleResourceKey = "HeaderTabTrainers", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		hightlight = "Intermediate text",
	},
	defaultSortKey = "Alphabetical",
	defaultFilterKey = "TrainerName",
}

LogTabTrainers.PagedButtons = {}
LogTabTrainers.NavFilterButtons = {}

function LogTabTrainers.initialize()
	LogTabTrainers.buildNavigation()
end

function LogTabTrainers.refreshButtons()
	for _, button in pairs(LogTabTrainers.NavFilterButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabTrainers.PagedButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabTrainers.rebuild()
	LogTabTrainers.realignGrid(LogOverlay.Windower.filterGrid)
end

function LogTabTrainers.buildNavigation()
	local navHeaderX = LogOverlay.TabBox.x + 2
	local navHeaderY = LogOverlay.TabBox.y + 1
	local navItemSpacer = 6
	local filterLabelSize = Utils.calcWordPixelLength(Resources.LogOverlay.LabelFilterBy)
	local nextNavX = navHeaderX + filterLabelSize + navItemSpacer

	LogTabTrainers.NavFilterButtons = {}
	for _, navFilter in ipairs(Utils.getSortedList(LogOverlay.NavFilters.Trainers)) do
		local navLabelWidth = Utils.calcWordPixelLength(navFilter:getText()) + 4
		local navButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return navFilter:getText() end,
			textColor = LogTabTrainers.Colors.text,
			isSelected = false,
			box = { LogOverlay.TabBox.x + nextNavX, navHeaderY, navLabelWidth, 11 },
			updateSelf = function(self)
				if navFilter.group == TrainerData.TrainerGroups.All and LogSearchScreen.searchText ~= "" then
					self.isSelected = true
					self.textColor = LogTabTrainers.Colors.hightlight
				elseif navFilter.group == LogOverlay.Windower.filterGrid and LogSearchScreen.searchText == "" then
					self.isSelected = true
					self.textColor = LogTabTrainers.Colors.hightlight
				else
					self.isSelected = false
					self.textColor = LogTabTrainers.Colors.text
				end
			end,
			draw = function(self)
				if self.isSelected then
					Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
				end
			end,
			onClick = function(self)
				LogSearchScreen.clearSearch()
				LogTabTrainers.realignGrid(navFilter.group, navFilter.sortFunc)
				Program.redraw(true)
			end,
		}
		table.insert(LogTabTrainers.NavFilterButtons, navButton)
		nextNavX = nextNavX + navLabelWidth + navItemSpacer
	end
end

-- Returns gymTMs table, which holds gym trainers info from the log
function LogTabTrainers.buildPagedButtons()
	LogTabTrainers.PagedButtons = {}

	-- Determine gym TMs for the game, they'll be highlighted
	local gymTMs = {}
	for i, gymTM in ipairs(TrainerData.GymTMs) do
		gymTMs[gymTM.number] = {
			leader = gymTM.leader,
			gymNumber = i,
			trainerId = nil, -- this gets added in later
		}
	end

	-- Build Trainer buttons
	for id, trainerLog in pairs(RandomizerLog.Data.Trainers) do
		local trainerInternal = TrainerData.getTrainerInfo(id)
		local fullname = Utils.firstToUpperEachWord(trainerLog.fullname)
		local button = {
			type = Constants.ButtonTypes.IMAGE,
			image = TrainerData.getPortraitIcon(trainerInternal.class),
			getText = function(self) return fullname end,
			textColor = LogTabTrainers.Colors.text,
			id = id,
			class = Utils.firstToUpperEachWord(trainerLog.class),
			name = Utils.firstToUpperEachWord(trainerLog.name),
			customname = trainerLog.customname,
			maxlevel = trainerLog.maxlevel or 0,
			dimensions = { width = 32, height = 32, },
			group = trainerInternal.group or TrainerData.TrainerGroups.Other,
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- If no search text entered, check any filter groups
				if LogSearchScreen.searchText == "" then
					if LogOverlay.Windower.filterGrid == self.group then
						return true
					elseif LogOverlay.Windower.filterGrid == TrainerData.TrainerGroups.All then
						return true
					end
					return false
				end

				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.TrainerName then
					if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
						return true
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
					for _, partyMon in ipairs(trainerLog.party or {}) do
						local pokemonName = RandomizerLog.getPokemonName(partyMon.pokemonID)
						if Utils.containsText(pokemonName, LogSearchScreen.searchText, true) then
							return true
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
					for _, partyMon in ipairs(trainerLog.party or {}) do
						for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
							local abilityText = AbilityData.Abilities[abilityId].name
							if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
								return true
							end
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
					for _, partyMon in ipairs(trainerLog.party or {}) do
						for _, moveId in ipairs(partyMon.moveIds or {}) do
							local moveText = MoveData.Moves[moveId].name
							if Utils.containsText(moveText, LogSearchScreen.searchText, true) then
								return true
							end
						end
					end
				end

				return false
			end,
			onClick = function(self)
				LogOverlay.Windower:changeTab(LogTabTrainerDetails, 1, 1, self.id)
				Program.redraw(true)
				-- InfoScreen.changeScreenView(InfoScreen.Screens.TRAINER_INFO, self.id) -- TODO: (future feature) implied redraw
			end,
			draw = function(self, shadowcolor)
				LogTabTrainers.drawTrainerPortraitInfo(self, shadowcolor)
			end,
		}

		if trainerInternal ~= nil and trainerInternal.group == TrainerData.TrainerGroups.Gym then
			local gymNumber = tonumber(string.match(trainerInternal.class.filename, "gymleader%-(%d+)"))
			if gymNumber ~= nil then
				-- Find the gym leader's TM and add it's trainer id to that tm info
				for _, gymTMInfo in pairs(gymTMs) do
					if gymTMInfo.gymNumber == gymNumber then
						gymTMInfo.trainerId = id
						break
					end
				end
			end
		end

		table.insert(LogTabTrainers.PagedButtons, button)
	end

	return gymTMs
end

-- Draw pokeballs for each pokemon on their team
function LogTabTrainers.drawTrainerPortraitInfo(button, shadowcolor)
	-- Draw the name above the trainer icon
	local x = button.box[1] - 3
	local y = button.box[2] - Constants.SCREEN.LINESPACING
	local textColor = Theme.COLORS[button.textColor]
	local nameText = button.name
	if TrainerData.shouldUseClassName(button.id) then
		nameText = button.class
	end
	Drawing.drawText(x, y, nameText, textColor, shadowcolor)

	-- Draw pokeballs for each Pokemon on the trainer's team below the trainer icon
	y = button.box[2] + button.box[4] + 2
	local image = Constants.PixelImages.POKEBALL_SMALL
	local colorList = TrackerScreen.PokeBalls.ColorList
	local trainerLog = RandomizerLog.Data.Trainers[button.id] or {}
	if #(trainerLog.party or {}) == 0 then
		return
	end
	-- Easter egg for Giovanni, use masterballs
	if GameSettings.game == 3 and 348 <= button.id and button.id <= 350 then
		image = Constants.PixelImages.MASTERBALL_SMALL
		colorList = { Drawing.Colors.BLACK, 0xFFA040B8, Drawing.Colors.WHITE, 0xFFF86088, }
	end
	if #trainerLog.party <= 3 then
		x = x + 8
	end
	for _ = 1, #trainerLog.party, 1 do
		Drawing.drawImageAsPixels(image, x, y, colorList, shadowcolor)
		x = x + 8
	end
end

function LogTabTrainers.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or TrainerData.TrainerGroups.Gym
	sortFunc = sortFunc or LogOverlay.NavFilters.Trainers.All.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabTrainers.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 15
	local y = LogOverlay.TabBox.y + 30
	local colSpacer = 24
	local rowSpacer = 28
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = Utils.gridAlign(LogTabTrainers.PagedButtons, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabTrainers.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabTrainers.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTrainers.NavFilterButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTrainers.PagedButtons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabTrainers.drawTab()
	local textColor = Theme.COLORS[LogTabTrainers.Colors.text]
	local borderColor = Theme.COLORS[LogTabTrainers.Colors.border]
	local fillColor = Theme.COLORS[LogTabTrainers.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw group filters Label
	local filterByText = Resources.LogOverlay.LabelFilterBy .. ":"
	Drawing.drawText(LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 1, filterByText, textColor, shadowcolor)

	-- Draw the navigation
	for _, button in pairs(LogTabTrainers.NavFilterButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Draw the paged items
	for _, button in pairs(LogTabTrainers.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

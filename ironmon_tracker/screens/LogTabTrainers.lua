LogTabTrainers = {
	TitleResourceKey = "HeaderTabTrainers", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		hightlight = "Intermediate text",
	}
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
	for id, trainerData in pairs(RandomizerLog.Data.Trainers) do
		local trainerInfo = TrainerData.getTrainerInfo(id)
		local trainerName = Utils.inlineIf(trainerInfo.name ~= "Unknown", trainerInfo.name, trainerData.name)
		local fileInfo = TrainerData.FileInfo[trainerInfo.filename] or { width = 40, height = 40 }
		local button = {
			type = Constants.ButtonTypes.IMAGE,
			image = FileManager.buildImagePath(FileManager.Folders.Trainers, trainerInfo.filename, FileManager.Extensions.TRAINER),
			getText = function(self) return trainerName end,
			id = id,
			customname = trainerData.customname,
			filename = trainerInfo.filename, -- helpful for sorting later
			dimensions = { width = fileInfo.width, height = fileInfo.height, extraX = fileInfo.offsetX, extraY = fileInfo.offsetY, },
			group = trainerInfo.group,
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Always exclude extra rivals
				if trainerInfo.whichRival ~= nil and Tracker.Data.whichRival ~= nil and Tracker.Data.whichRival ~= trainerInfo.whichRival then
					return false
				end

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
					for _, partyMon in ipairs(trainerData.party or {}) do
						local name
						-- When languages don't match, there's no way to tell if the name in the log is a custom name or not, assume it's not
						if RandomizerLog.areLanguagesMismatched() then
							name = PokemonData.Pokemon[partyMon.pokemonID].name or Constants.BLANKLINE
						else
							name = RandomizerLog.Data.Pokemon[partyMon.pokemonID].Name or PokemonData.Pokemon[partyMon.pokemonID].name or Constants.BLANKLINE
						end
						if Utils.containsText(name, LogSearchScreen.searchText, true) then
							return true
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
					for _, partyMon in ipairs(trainerData.party or {}) do
						for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
							local abilityText = AbilityData.Abilities[abilityId].name
							if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
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
				-- Draw a centered box for the Trainer's name
				local nameWidth = Utils.calcWordPixelLength(self:getText())
				local bottomPadding = 9
				local offsetX = self.box[1] + self.box[3] / 2 - nameWidth / 2
				local offsetY = self.box[2] + TrainerData.FileInfo.maxHeight - bottomPadding - (self.dimensions.extraY or 0)
				gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabTrainers.Colors.border], Theme.COLORS[LogTabTrainers.Colors.boxFill])
				Drawing.drawText(offsetX, offsetY, self:getText(), Theme.COLORS[LogTabTrainers.Colors.text], shadowcolor)
				gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabTrainers.Colors.border]) -- to cutoff the shadows
			end,
		}

		if trainerInfo ~= nil and trainerInfo.group == TrainerData.TrainerGroups.Gym then
			local gymNumber = tonumber(trainerInfo.filename:sub(-1)) -- e.g. "frlg-gymleader-1"
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

function LogTabTrainers.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or TrainerData.TrainerGroups.Gym
	sortFunc = sortFunc or LogOverlay.NavFilters.Trainers.All.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabTrainers.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 17
	local y = LogOverlay.TabBox.y + 11
	local colSpacer = 10
	local rowSpacer = 5
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

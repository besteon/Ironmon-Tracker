LogTabTMs = {
	TitleResourceKey = "HeaderTabTMs", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		highlight = "Intermediate text",
	},
	TabIcons = {
		TM1 = {
			x = 1, y = 1, w = 14, h = 14,
			image = FileManager.buildImagePath("icons", "tiny-tm", ".png"),
		},
	},
}

LogTabTMs.PagedButtons = {}
LogTabTMs.NavFilterButtons = {}
LogTabTMs.GymLabelButtons = {}

function LogTabTMs.initialize()
	LogTabTMs.buildNavigation()
end

function LogTabTMs.refreshButtons()
	for _, button in pairs(LogTabTMs.NavFilterButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabTMs.GymLabelButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabTMs.PagedButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabTMs.getTabIcons()
	return { LogTabTMs.TabIcons.TM1 }
end

function LogTabTMs.rebuild()
	LogTabTMs.realignGrid(LogOverlay.Windower.filterGrid)
end

function LogTabTMs.buildNavigation()
	local navHeaderX = LogOverlay.TabBox.x + 2
	local navHeaderY = LogOverlay.TabBox.y + 1
	local navItemSpacer = 6
	local filterLabelSize = Utils.calcWordPixelLength(Resources.LogOverlay.LabelFilterBy)
	local nextNavX = navHeaderX + filterLabelSize + navItemSpacer

	LogTabTMs.NavFilterButtons = {}
	for _, navFilter in ipairs(Utils.getSortedList(LogOverlay.NavFilters.TMs)) do
		local navLabelWidth = Utils.calcWordPixelLength(navFilter:getText()) + 4
		local navButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return navFilter:getText() end,
			textColor = LogTabTMs.Colors.text,
			isSelected = false,
			box = { LogOverlay.TabBox.x + nextNavX, navHeaderY, navLabelWidth, 11 },
			updateSelf = function(self)
				self.isSelected = (LogOverlay.Windower.filterGrid == navFilter.group and Utils.isNilOrEmpty(LogSearchScreen.searchText))
				self.textColor = Utils.inlineIf(self.isSelected, LogTabTMs.Colors.highlight, LogTabTMs.Colors.text)
			end,
			draw = function(self)
				if self.isSelected then
					Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
				end
			end,
			onClick = function(self)
				LogTabTMs.realignGrid(navFilter.group, navFilter.sortFunc)
				Program.redraw(true)
			end,
		}
		table.insert(LogTabTMs.NavFilterButtons, navButton)
		nextNavX = nextNavX + navLabelWidth + navItemSpacer
	end
end

-- Requires gymTMs are passed in, which has info about the gym (leader, gymNumber, trainerId)
function LogTabTMs.buildPagedButtons(gymTMs)
	LogTabTMs.PagedButtons = {}

	for tmNumber, tm in pairs(RandomizerLog.Data.TMs) do
		local gymNumber, trainerId, filterGroup
		if gymTMs[tmNumber] ~= nil then
			gymNumber = gymTMs[tmNumber].gymNumber
			trainerId = gymTMs[tmNumber].trainerId
			filterGroup = "Gym TMs"
		else
			gymNumber = 0
			-- if not a gym TM, then it doesn't have a trainerId or filterGroup
		end

		local moveName = tm.name
		if MoveData.isValid(tm.moveId) then
			moveName = MoveData.Moves[tm.moveId].name
		end

		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return string.format("TM%02d  %s", tmNumber, moveName) end,
			textColor = LogTabTMs.Colors.text,
			tmNumber = tmNumber,
			moveId = tm.moveId,
			gymNumber = gymNumber,
			trainerId = trainerId,
			group = filterGroup,
			dimensions = { width = 80, height = 11, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				local shouldInclude = LogOverlay.Windower.filterGrid == LogOverlay.NavFilters.TMs.TMNumber.group or LogOverlay.Windower.filterGrid == self.group
				local shouldExclude = nil
				return shouldInclude and not shouldExclude
			end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogTabTMs.PagedButtons, button)
	end

	LogTabTMs.buildGymTMButtons()
end

function LogTabTMs.buildGymTMButtons()
	LogTabTMs.GymLabelButtons = {}
	local gymTMNav = LogOverlay.NavFilters.TMs.GymTMs
	LogTabTMs.realignGrid(gymTMNav.group, gymTMNav.sortFunc)

	local gymColOffsetX = 80 + 17
	for _, tmButton in pairs(LogTabTMs.PagedButtons) do
		local trainerLog = RandomizerLog.Data.Trainers[tmButton.trainerId or -1] or {}

		if tmButton.group == "Gym TMs" then
			local badgeName = GameSettings.badgePrefix .. "_badge" .. tmButton.gymNumber
			local badgeImage = FileManager.buildImagePath(FileManager.Folders.Badges, badgeName, FileManager.Extensions.BADGE)
			local gymLabel = string.format("%s %s", Resources.LogOverlay.FilterGym, tmButton.gymNumber or 0)

			local gymButton = {
				type = Constants.ButtonTypes.NO_BORDER,
				getText = function(self)
					if Options["Use Custom Trainer Names"] then
						return Utils.firstToUpperEachWord(trainerLog.customName)
					else
						return Utils.firstToUpperEachWord(trainerLog.name)
					end
				end,
				textColor = tmButton.textColor,
				trainerId = tmButton.trainerId,
				group = tmButton.group,
				box = { tmButton.box[1] + gymColOffsetX, tmButton.box[2], 90, 11 },
				isVisible = function(self) return LogOverlay.Windower.filterGrid == self.group end,
				draw = function(self, shadowcolor)
					-- Draw badge icon to the left of the TM move
					Drawing.drawImage(badgeImage, tmButton.box[1] - 18, tmButton.box[2] - 2)
					-- Draw the gym leader name and gym # to the right of the TM move
					Drawing.drawText(self.box[1] + 55, self.box[2], gymLabel, Theme.COLORS[self.textColor], shadowcolor)
				end,
				onClick = function(self)
					LogOverlay.Windower:changeTab(LogTabTrainerDetails, 1, 1, self.trainerId)
					Program.redraw(true)
					-- InfoScreen.changeScreenView(InfoScreen.Screens.TRAINER_INFO, self.trainerId) -- TODO: (future feature) implied redraw
				end,
			}
			table.insert(LogTabTMs.GymLabelButtons, gymButton)
		end
	end
end

function LogTabTMs.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or "Gym TMs"
	sortFunc = sortFunc or LogOverlay.NavFilters.TMs.GymTMs.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabTMs.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 25
	local y = LogOverlay.TabBox.y + 14
	local colSpacer = 17
	local rowSpacer = 2
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	-- Single column for fancy Gym TM display
	if gridFilter == "Gym TMs" then
		x = x + 12
		y = y + 2
		colSpacer = 200
		rowSpacer = 5
	end

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = Utils.gridAlign(LogTabTMs.PagedButtons, x, y, colSpacer, rowSpacer, true, maxWidth, maxHeight)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabTMs.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabTMs.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.NavFilterButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.GymLabelButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.PagedButtons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabTMs.drawTab()
	local textColor = Theme.COLORS[LogTabTMs.Colors.text]
	local borderColor = Theme.COLORS[LogTabTMs.Colors.border]
	local fillColor = Theme.COLORS[LogTabTMs.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw group filters Label
	local filterByText = Resources.LogOverlay.LabelFilterBy .. ":"
	Drawing.drawText(LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 1, filterByText, textColor, shadowcolor)

	-- Draw the navigation
	for _, button in pairs(LogTabTMs.NavFilterButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabTMs.GymLabelButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Draw the paged items
	for _, button in pairs(LogTabTMs.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

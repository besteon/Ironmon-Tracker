LogTabTMs = {
	TitleResourceKey = "HeaderTabTMs", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		hightlight = "Intermediate text",
	}
}

LogTabTMs.PagedButtons = {}
LogTabTMs.NavFilterButtons = {}

function LogTabTMs.initialize()
	LogTabTMs.buildNavigation()
end

function LogTabTMs.refreshButtons()
	for _, button in pairs(LogTabTMs.NavFilterButtons) do
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

function LogTabTMs.buildNavigation()
	local navHeaderX = 4
	local navHeaderY = LogOverlay.tabHeight + 1
	local navItemSpacer = 8
	local filterLabelSize = Utils.calcWordPixelLength(Resources.LogOverlay.LabelFilterBy)
	local nextNavX = navHeaderX + filterLabelSize + navItemSpacer

	LogTabTMs.NavFilterButtons = {}
	for _, navFilter in ipairs(Utils.getSortedList(LogOverlay.NavFilters.TMs)) do
		local navLabelWidth = Utils.calcWordPixelLength(navFilter:getText()) + 2
		local navButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return navFilter:getText() end,
			textColor = LogTabTMs.Colors.text,
			box = { LogOverlay.margin + nextNavX, navHeaderY, navLabelWidth, 11 },
			updateSelf = function(self)
				if LogOverlay.Windower.filterGrid == navFilter.group and LogSearchScreen.searchText == "" then
					self.textColor = LogTabTMs.Colors.hightlight
				else
					self.textColor = LogTabTMs.Colors.text
				end
			end,
			draw = function(self)
				-- Draw an underline if selected
				if self.textColor == LogTabTMs.Colors.hightlight then
					local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] + 1
					local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
					gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
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
		local gymLeader, gymNumber, trainerId, filterGroup
		if gymTMs[tmNumber] ~= nil then
			gymLeader = gymTMs[tmNumber].leader
			gymNumber = gymTMs[tmNumber].gymNumber
			trainerId = gymTMs[tmNumber].trainerId
			filterGroup = "Gym TMs"
		else
			gymLeader = "None"
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
			gymLeader = gymLeader,
			gymNumber = gymNumber,
			trainerId = trainerId,
			group = filterGroup,
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
	local gymTMNav = LogOverlay.NavFilters.TMs.GymTMs
	LogTabTMs.realignGrid(gymTMNav.group, gymTMNav.sortFunc)

	local gymColOffsetX = 80 + 17
	for _, tmButton in pairs(LogTabTMs.PagedButtons) do
		if tmButton.group == "Gym TMs" then
			local badgeName = GameSettings.badgePrefix .. "_badge" .. tmButton.gymNumber
			local badgeImage = FileManager.buildImagePath(FileManager.Folders.Badges, badgeName, FileManager.Extensions.BADGE)
			local gymLabel = string.format("%s %s", Resources.LogOverlay.FilterGym, tmButton.gymNumber or 0)

			local gymButton = {
				type = Constants.ButtonTypes.NO_BORDER,
				getText = function(self) return tmButton.gymLeader end,
				textColor = tmButton.textColor,
				trainerId = tmButton.trainerId,
				group = tmButton.group,
				box = { tmButton.box[1] + gymColOffsetX, tmButton.box[2], 90, 11 },
				isVisible = function(self) return LogOverlay.Windower.filterGrid == self.group end,
				draw = function(self, shadowcolor)
					-- Draw badge icon to the left of the TM move
					gui.drawImage(badgeImage, tmButton.box[1] - 18, tmButton.box[2] - 2)
					-- Draw the gym leader name and gym # to the right of the TM move
					Drawing.drawText(self.box[1] + 55, self.box[2], gymLabel, Theme.COLORS[self.textColor], shadowcolor)
				end,
				onClick = function(self)
					LogOverlay.Windower:changeTab(LogOverlay.Tabs.TRAINER_ZOOM, 1, 1, self.trainerId)
					Program.redraw(true)
					-- InfoScreen.changeScreenView(InfoScreen.Screens.TRAINER_INFO, self.trainerId) -- TODO: (future feature) implied redraw
				end,
			}
			table.insert(LogTabTMs.NavFilterButtons, gymButton)
		end
	end
end

function LogTabTMs.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or "Gym TMs"
	sortFunc = sortFunc or LogOverlay.NavFilters.TMs.GymTMs.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabTMs.PagedButtons, sortFunc)

	local x = LogOverlay.margin + 25
	local y = LogOverlay.tabHeight + 14
	local itemWidth = 80
	local itemHeight = 11
	local horizontalSpacer = 17
	local verticalSpacer = 2
	if gridFilter == "Gym TMs" then
		x = x + 12
		y = y + 2
		verticalSpacer = 5
	end

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = LogOverlay.gridAlign(LogTabTMs.PagedButtons, x, y, itemWidth, itemHeight, horizontalSpacer, verticalSpacer)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabTMs.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabTMs.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.NavFilterButtons)
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
	Drawing.drawText(LogOverlay.margin + 2, LogOverlay.tabHeight + 1, filterByText, textColor, shadowcolor)

	-- Draw the navigation
	for _, button in pairs(LogTabTMs.NavFilterButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Draw the paged items
	for _, button in pairs(LogTabTMs.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

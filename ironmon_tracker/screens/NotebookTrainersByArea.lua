NotebookTrainersByArea = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Data = {
		areas = {},
	},
}
local SCREEN = NotebookTrainersByArea

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end, -- Order by appearance
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP + 1
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
		-- Snap each individual button to their respective button rows
		for _, buttonRow in ipairs(SCREEN.Pager.Buttons) do
			for _, button in ipairs (buttonRow.buttonList or {}) do
				if type(button.alignToBox) == "function" then
					button:alignToBox(buttonRow.box)
				end
			end
		end
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local buffer = Utils.inlineIf(self.currentPage > 9, "", " ") .. Utils.inlineIf(self.totalPages > 9, "", " ")
		return buffer .. string.format("%s/%s", self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
}

SCREEN.Buttons = {
	CheckboxShowCompleted = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return string.format(" %s", Resources.NotebookTrainersByArea.CheckboxShowCompleted) end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 77, 10 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 8, 8 },
		toggleState = false,
		onClick = function(self)
			self.toggleState = not self.toggleState
			SCREEN.buildScreen()
			Program.redraw(true)
		end
	},
	CheckboxSevii = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return string.format(" %s", Resources.NotebookTrainersByArea.CheckboxSevii) end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 105, Constants.SCREEN.MARGIN + 14, 31, 10 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 105, Constants.SCREEN.MARGIN + 14, 8, 8 },
		isVisible = function() return GameSettings.game == 3 end, -- Only available in FRLG
		toggleState = false,
		onClick = function(self)
			self.toggleState = not self.toggleState
			SCREEN.buildScreen()
			NotebookIndexScreen.buildScreen() -- recount total trainers
			Program.redraw(true)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 56, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 86, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or TrackerScreen)
		SCREEN.previousScreen = nil
	end),
}

function NotebookTrainersByArea.initialize()
	SCREEN.Buttons.CheckboxShowCompleted.toggleState = false
	SCREEN.Buttons.CheckboxSevii.toggleState = false

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	SCREEN.clearBuiltData()
	SCREEN.refreshButtons()
end

---Retrieves and builds the data needed to draw this screen; stored in `NotebookTrainersByArea.Data`
function NotebookTrainersByArea.buildScreen()
	SCREEN.clearBuiltData()

	local ROW_START_X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local ROW_START_Y = Constants.SCREEN.MARGIN + 28
	local ROW_WIDTH = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2 - 2
	local ROW_HEIGHT = 21
	local COLUMNS_X = { 0, 21, 110 }

	local includeCompletedAreas = SCREEN.Buttons.CheckboxShowCompleted.toggleState
	local includeSevii
	if GameSettings.game == 3 then
		includeSevii = SCREEN.Buttons.CheckboxSevii.toggleState
	else
		includeSevii = true -- to allow routes above the sevii route id for RSE
	end

	-- For a given trainer, this function returns info about its route/area and other trainer counts on it
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local trainersToExclude = TrainerData.getExcludedTrainers()
	local checkedIds = {}
	local function getTrainerAreaInfo(trainerId)
		local trainer = TrainerData.Trainers[trainerId] or {}
		local routeId = trainer.routeId or -1
		local route = RouteData.Info[routeId] or {}

		-- If sevii is excluded (default option), skip those routes and non-existent routes
		if routeId == -1 or (routeId >= 230 and not includeSevii) then
			return nil
		end
		-- Skip certain trainers
		if checkedIds[trainerId] or trainersToExclude[trainerId] or not TrainerData.shouldUseTrainer(trainerId) then
			return nil
		end
		-- Skip trainer if already beaten and the option to show completed areas is disabled
		if not includeCompletedAreas and Program.hasDefeatedTrainer(trainerId, saveBlock1Addr) then
			return nil
		end

		-- Check area for defeated trainers and mark each trainer as checked
		local defeatedTrainers = {}
		local totalTrainers = 0
		if route.area and #route.area > 0 then
			defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByCombinedArea(route.area, saveBlock1Addr)
			for _, areaRouteId in ipairs(route.area) do
				local areaRoute = RouteData.Info[areaRouteId] or {}
				for _, id in ipairs(areaRoute.trainers or {}) do
					checkedIds[id] = true
				end
			end
		elseif route.trainers and #route.trainers > 0 then
			defeatedTrainers, totalTrainers = Program.getDefeatedTrainersByLocation(routeId, saveBlock1Addr)
			for _, id in ipairs(route.trainers) do
				checkedIds[id] = true
			end
		else
			return nil
		end

		-- Skip using this area if it's complete the option to show completed areas is disabled
		if not includeCompletedAreas and #defeatedTrainers == totalTrainers then
			return nil
		end

		return {
			routeId = routeId,
			name = route.area and route.area.name or route.name,
			icon = route.icon or RouteData.Icons.RouteSignWooden,
			trainersDefeated = #defeatedTrainers,
			trainersTotal = totalTrainers,
		}
	end

	SCREEN.Data.areas = {}
	for _, trainerId in ipairs(TrainerData.OrderedIds or {}) do
		local areaInfo = getTrainerAreaInfo(trainerId)
		if areaInfo ~= nil then
			table.insert(SCREEN.Data.areas, areaInfo)
		end
	end

	for i, areaInfo in ipairs(SCREEN.Data.areas) do
		local buttonRow = {
			type = Constants.ButtonTypes.NO_BORDER,
			buttonList = {},
			area = areaInfo,
			index = i,
			dimensions = { width = ROW_WIDTH, height = ROW_HEIGHT, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Allow checkboxes to filter completed areas or not
				return true
			end,
			onClick = function(self)
				TrainersOnRouteScreen.previousScreen = SCREEN
				TrainersOnRouteScreen.buildScreen(areaInfo.routeId)
				Program.changeScreenView(TrainersOnRouteScreen)
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local borderColor = Theme.COLORS[SCREEN.Colors.border]
				-- Surround the row with a border
				gui.drawRectangle(x - 1, y - 1, ROW_WIDTH + 2, ROW_HEIGHT, borderColor)
				for _, colX in ipairs(COLUMNS_X) do
					gui.drawLine(x + colX - 1, y, x + colX - 1, y + h - 1, borderColor)
				end
				for _, button in ipairs(self.buttonList or {}) do
					Drawing.drawButton(button, shadowcolor)
				end
			end,
		}
		table.insert(SCREEN.Pager.Buttons, buttonRow)

		-- ICON
		local iconBtn = {
			type = Constants.ButtonTypes.IMAGE,
			image = areaInfo.icon:getIconPath(),
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 20, 20 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + COLUMNS_X[1]
				self.box[2] = box[2]
			end,
		}
		table.insert(buttonRow.buttonList, iconBtn)

		-- AREA NAME
		local areaName = RouteData.getRouteOrAreaName(areaInfo.routeId, true)
		areaName = Utils.shortenText(areaName, 90, true)
		local areaColor = SCREEN.Colors.text
		local currentMapId = TrackerAPI.getMapId()
		if areaInfo.routeId == currentMapId then
			areaColor = SCREEN.Colors.highlight
		else
			local route = RouteData.Info[areaInfo.routeId] or {}
			for _, areaRouteId in ipairs(route.area or {}) do
				if areaRouteId == currentMapId then
					areaColor = SCREEN.Colors.highlight
					break
				end
			end
		end
		local nameBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return areaName end,
			textColor = areaColor,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 90, 11 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + COLUMNS_X[2] + 2
				self.box[2] = box[2] + (ROW_HEIGHT / 2) - (Constants.SCREEN.LINESPACING / 2) - 1
			end,
		}
		table.insert(buttonRow.buttonList, nameBtn)

		-- AREA TRAINER COUNT
		local trainerCountTxt, trainerCountColor
		if areaInfo.trainersDefeated > 0 then
			trainerCountTxt = string.format("%s/%s", areaInfo.trainersDefeated, areaInfo.trainersTotal)
		else
			trainerCountTxt = tostring(areaInfo.trainersTotal)
		end
		if areaInfo.trainersDefeated == areaInfo.trainersTotal then
			trainerCountColor = SCREEN.Colors.positive
		else
			trainerCountColor = SCREEN.Colors.text
		end
		local trainerCountBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return trainerCountTxt end,
			textColor = trainerCountColor,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 25, 11 },
			alignToBox = function(self, box)
				local offsetX = Utils.getCenteredTextX(self:getText() or "", self.box[3])
				self.box[1] = box[1] + COLUMNS_X[3] + offsetX
				self.box[2] = box[2] + (ROW_HEIGHT / 2) - (Constants.SCREEN.LINESPACING / 2) - 1
			end,
		}
		table.insert(buttonRow.buttonList, trainerCountBtn)
	end

	-- Place button rows into the grid and update each of their contained buttons
	SCREEN.Pager:realignButtonsToGrid(ROW_START_X, ROW_START_Y, 0, 0)
end

function NotebookTrainersByArea.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function NotebookTrainersByArea.clearBuiltData()
	SCREEN.Data.areas = {}
	SCREEN.Pager.Buttons = {}
end

-- USER INPUT FUNCTIONS
function NotebookTrainersByArea.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function NotebookTrainersByArea.drawScreen()
	Drawing.drawBackgroundAndMargins()
	SCREEN.refreshButtons()

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[SCREEN.Colors.text],
		highlight = Theme.COLORS[SCREEN.Colors.highlight],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)
	-- Header
	local headerText = Utils.toUpperUTF8(Resources.NotebookTrainersByArea.Title)
	local headerColor = Theme.COLORS["Header text"]
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, headerColor, headerShadow)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
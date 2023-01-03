TimeMachineScreen = {
	Labels = {
		header = "Time Machine",
		description = "Restore points are created automatically as you play. Select one to go back in time.",
		pageFormat = "Page %s/%s", -- e.g. Page 1/3
		restoreTimeFormat = "%2s minute%s ago", -- e.g. 5 minutes ago
	},
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	rpCount = 0,
	maxRestorePoints = 10,
}

-- A collection of temporary save states created in memory through Bizhawk
TimeMachineScreen.RestorePoints = {}

TimeMachineScreen.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 75
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
		TimeMachineScreen.Buttons.CurrentPage:updateText()
	end,
	defaultSort = function(a, b) return a.timestamp > b.timestamp end, -- sorts newest to oldest
	getPageText = function(self)
		if self.totalPages <= 1 then return "Page" end
		return string.format(TimeMachineScreen.Labels.pageFormat, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
}

TimeMachineScreen.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateText()
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return TimeMachineScreen.Pager.totalPages > 1 end,
		updateText = function(self)
			self.text = TimeMachineScreen.Pager:getPageText()
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return TimeMachineScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			TimeMachineScreen.Pager:prevPage()
			TimeMachineScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return TimeMachineScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			TimeMachineScreen.Pager:nextPage()
			TimeMachineScreen.Buttons.CurrentPage:updateText()
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			TimeMachineScreen.resetButtons()
			Program.changeScreenView(Program.Screens.EXTRAS)
		end
	},
}

function TimeMachineScreen.initialize()
	for _, button in pairs(TimeMachineScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = TimeMachineScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { TimeMachineScreen.Colors.border, TimeMachineScreen.Colors.boxFill }
		end
	end
	TimeMachineScreen.Buttons.CurrentPage:updateText()
end

-- Creates a temporary save state in memory with an associated label(optional)
function TimeMachineScreen.createRestorePoint(label)
	if not Main.IsOnBizhawk() then return end

	local restorePointId = memorysavestate.savecorestate()
	TimeMachineScreen.rpCount = TimeMachineScreen.rpCount + 1
	label = label or string.format("# %s", TimeMachineScreen.rpCount)
	local restorePoint = {
		id = restorePointId,
		label = label,
		timestamp = os.time(),
	}
	table.insert(TimeMachineScreen.RestorePoints, restorePoint)

	TimeMachineScreen.cleanupOldRestorePoints()
end

function TimeMachineScreen.loadRestorePoint(restorePointId)
	if not Main.IsOnBizhawk() or restorePointId == nil then return end
	memorysavestate.loadcorestate(restorePointId)
	Program.Frames.restorePoint = -1
	-- Battle.resetBattle()
end

function TimeMachineScreen.cleanupOldRestorePoints(forceRemoveAll)
	if forceRemoveAll then
		for _, rp in pairs(TimeMachineScreen.RestorePoints) do
			if rp.id ~= nil then
				memorysavestate.removestate(rp.id)
			end
		end
		TimeMachineScreen.RestorePoints = {}
		return
	elseif #TimeMachineScreen.RestorePoints <= TimeMachineScreen.maxRestorePoints then
		return
	end

	-- Otherwise, keep removing excess restore points until under the max
	table.sort(TimeMachineScreen.RestorePoints, TimeMachineScreen.Pager.defaultSort)
	while #TimeMachineScreen.RestorePoints > TimeMachineScreen.maxRestorePoints do
		local rp = table.remove(TimeMachineScreen.RestorePoints, TimeMachineScreen.maxRestorePoints + 1)
		if rp ~= nil and rp.id ~= nil then
			memorysavestate.removestate(rp.id)
		end
	end
end

function TimeMachineScreen.buildOutPagedButtons()
	TimeMachineScreen.Pager.Buttons = {}

	for _, restorePoint in pairs(TimeMachineScreen.RestorePoints) do
		local rpLabel = restorePoint.label
		local button = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = rpLabel,
			textColor = TimeMachineScreen.Colors.text,
			restorePointId = restorePoint.id or 0,
			restorePointLabel = restorePoint.label,
			timestamp = restorePoint.timestamp or os.time(),
			confirmedRestore = false,
			dimensions = { width = 40, height = 11, },
			isVisible = function(self) return TimeMachineScreen.Pager.currentPage == self.pageVisible end,
			updateText = function(self)
				if self.confirmedRestore then
					self.text = "Confirm?"
					self.textColor = "Negative text"
				else
					self.text = self.restorePointLabel
					self.textColor = TimeMachineScreen.Colors.text
				end
			end,
			draw = function(self, shadowcolor)
				local timestampOffsetX = 60
				local minutesAgo = math.ceil((os.time() - restorePoint.timestamp) / 60)
				local includeS = Utils.inlineIf(minutesAgo ~= 1, "s", "")
				local timestampText = string.format(TimeMachineScreen.Labels.restoreTimeFormat, minutesAgo, includeS)
				Drawing.drawText(self.box[1] + timestampOffsetX, self.box[2], timestampText, Theme.COLORS[TimeMachineScreen.Colors.text], shadowcolor)
			end,
			onClick = function(self)
				if self.confirmedRestore then
					TimeMachineScreen.createRestorePoint("~Original")
					TimeMachineScreen.loadRestorePoint(self.id)
					self.confirmedRestore = false
				else
					self.confirmedRestore = true
				end
				self:updateText()
				Program.redraw(true)
			end,
		}
		table.insert(TimeMachineScreen.Pager.Buttons, button)
	end

	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8
	local y = Constants.SCREEN.MARGIN + 45
	local colSpacer = 2
	local rowSpacer = 2
	TimeMachineScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

function TimeMachineScreen.resetButtons()
	for _, button in pairs(TimeMachineScreen.Buttons) do
		if button.updateText ~= nil then
			button:updateText()
		end
	end
	for _, button in pairs(TimeMachineScreen.Pager.Buttons) do
		if button.confirmedRestore then
			button.confirmedRestore = false
		end
		if button.updateText ~= nil then
			button:updateText()
		end
	end
end

-- DRAWING FUNCTIONS
function TimeMachineScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[TimeMachineScreen.Colors.boxFill])

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[TimeMachineScreen.Colors.text],
		border = Theme.COLORS[TimeMachineScreen.Colors.border],
		fill = Theme.COLORS[TimeMachineScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[TimeMachineScreen.Colors.boxFill]),
	}
	local textLineY = topBox.y + 2

	local headerText = TimeMachineScreen.Labels.header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local offsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + offsetX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	local wrappedDesc = Utils.getWordWrapLines(TimeMachineScreen.Labels.description, 31)
	for _, line in pairs(wrappedDesc) do
		Drawing.drawText(topBox.x + 3, textLineY, line, topBox.text, topBox.shadow)
		textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
	end

	-- Draw all buttons
	for _, button in pairs(TimeMachineScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
	for _, button in pairs(TimeMachineScreen.Pager.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

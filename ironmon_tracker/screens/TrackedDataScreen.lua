 TrackedDataScreen = {
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

TrackedDataScreen.Buttons = {
	SaveData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.TrackedDataScreen.ButtonSaveData end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 19, Constants.SCREEN.MARGIN + 117, 44, 11 },
		onClick = function() TrackedDataScreen.openSaveDataPrompt() end
	},
	LoadData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.TrackedDataScreen.ButtonLoadData end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 75, Constants.SCREEN.MARGIN + 117, 44, 11 },
		onClick = function() TrackedDataScreen.openLoadDataPrompt() end
	},
	ClearData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			if self.dataCleared then
				return Resources.TrackedDataScreen.ButtonClearSuccess
			elseif self.confirmReset then
				return Resources.TrackedDataScreen.ButtonClearConfirm
			else
				return string.format(" * %s * ", Resources.TrackedDataScreen.ButtonClearData)
			end
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 63, 11 },
		confirmReset = false,
		dataCleared = false,
		updateSelf = function(self)
			if self.dataCleared then
				self.textColor = "Positive text"
			elseif self.confirmReset then
				self.textColor = "Negative text"
			else
				self.textColor = TrackedDataScreen.textColor
			end
		end,
		onClick = function(self)
			if self.confirmReset then
				self.confirmReset = false
				self.dataCleared = true
				local playtime = Tracker.Data.playtime
				Tracker.resetData()
				Tracker.Data.playtime = playtime
			else
				self.confirmReset = true
			end
			self:updateSelf()
			Program.redraw(true)
		end,
		reset = function(self)
			self.confirmReset = false
			self.dataCleared = false
			self:updateSelf()
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		TrackedDataScreen.Buttons.ClearData:reset()
		Program.changeScreenView(SetupScreen)
	end),
}

function TrackedDataScreen.initialize()
	TrackedDataScreen.createButtons()

	for _, button in pairs(TrackedDataScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = TrackedDataScreen.textColor
		end
		if button.boxColors == nil then
			button.boxColors = { TrackedDataScreen.borderColor, TrackedDataScreen.boxFillColor }
		end
	end

	TrackedDataScreen.refreshButtons()
end

function TrackedDataScreen.createButtons()
	local optionKeyMap = {
		{ "Auto save tracked game data", "OptionAutoSaveData", },
	}

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8
	local startY = Constants.SCREEN.MARGIN + 52

	for _, optionTuple in ipairs(optionKeyMap) do
		TrackedDataScreen.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function() return Resources.TrackedDataScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)
				Program.redraw(true)
			end,
		}
		startY = startY + 10
	end
end

function TrackedDataScreen.refreshButtons()
	for _, button in pairs(TrackedDataScreen.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function TrackedDataScreen.openSaveDataPrompt()
	local form = ExternalUI.BizForms.createForm(Resources.TrackedDataScreen.PromptHeaderSave, 290, 130)
	local suggestedFileName = GameSettings.getRomName()
	local enterFilename = string.format("%s:", Resources.TrackedDataScreen.PromptEnterFilename)
	form:createLabel(enterFilename, 18, 10)
	local nameTextbox = form:createTextBox(suggestedFileName, 20, 30, 200, 30)
	form:createLabel(".TDAT", 219, 32)
	form:createButton(Resources.TrackedDataScreen.ButtonSaveData, 55, 60, function()
		local formInput = ExternalUI.BizForms.getText(nameTextbox)
		if not Utils.isNilOrEmpty(formInput) then
			if formInput:sub(-5):lower() ~= FileManager.Extensions.TRACKED_DATA then
				formInput = formInput .. FileManager.Extensions.TRACKED_DATA
			end
			Tracker.saveDataAsCopy(formInput)
		end
		form:destroy()
	end)
	form:createButton(Resources.AllScreens.Cancel, 140, 60, function()
		form:destroy()
	end)
end

function TrackedDataScreen.openLoadDataPrompt()
	local suggestedFileName = GameSettings.getRomName() .. FileManager.Extensions.TRACKED_DATA
	local filterOptions = "Tracker Data (*.TDAT)|*.tdat|All files (*.*)|*.*"

	local workingDir = FileManager.dir
	if not Utils.isNilOrEmpty(workingDir) then
		workingDir = workingDir:sub(1, -2) -- remove trailing slash
	end

	local filepath, success = ExternalUI.BizForms.openFilePrompt(suggestedFileName, workingDir, filterOptions)
	if success then
		local playtime = Tracker.Data.playtime
		local loadStatus = Tracker.loadData(filepath, true)
		Tracker.Data.playtime = playtime
		if loadStatus == Tracker.LoadStatusKeys.LOAD_SUCCESS then
			Tracker.saveData()
		elseif loadStatus == Tracker.LoadStatusKeys.ERROR then
			Main.DisplayError("Invalid file selected.\n\nPlease select a valid TDAT file to load tracker data.")
		end

		local loadStatusMessage = Resources.StartupScreen[loadStatus or -1]
		if loadStatusMessage then
			print(string.format("> %s: %s", Resources.StartupScreen.TrackedDataMsgLabel, loadStatusMessage))
		end
		if loadStatus == Tracker.LoadStatusKeys.ERROR and filepath ~= nil then
			print("> " .. filepath)
		end
	end
end

-- USER INPUT FUNCTIONS
function TrackedDataScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, TrackedDataScreen.Buttons)
end

-- DRAWING FUNCTIONS
function TrackedDataScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[TrackedDataScreen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[TrackedDataScreen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.TrackedDataScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[TrackedDataScreen.borderColor], Theme.COLORS[TrackedDataScreen.boxFillColor])

	local offsetX = topboxX + 2
	local offsetY = topboxY + 5

	local wrappedSummary = Utils.getWordWrapLines(Resources.TrackedDataScreen.DescAutoSave, 35)
	for _, line in pairs(wrappedSummary) do
		Drawing.drawText(offsetX, offsetY, line, Theme.COLORS[TrackedDataScreen.textColor], shadowcolor)
		offsetY = offsetY + 11
	end
	offsetY = offsetY + 22

	-- Draw small divider line
	local dividerLine = string.rep(Constants.BLANKLINE, 3)
	Drawing.drawText(offsetX + Utils.centerTextOffset(dividerLine) + 3, offsetY - 10, dividerLine, Theme.COLORS[TrackedDataScreen.textColor], shadowcolor)

	wrappedSummary = Utils.getWordWrapLines(Resources.TrackedDataScreen.DescManualSave, 32)
	for _, line in pairs(wrappedSummary) do
		Drawing.drawText(offsetX, offsetY, line, Theme.COLORS[TrackedDataScreen.textColor], shadowcolor)
		offsetY = offsetY + 11
	end

	-- Draw all buttons
	for _, button in pairs(TrackedDataScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
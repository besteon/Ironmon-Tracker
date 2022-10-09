 TrackedDataScreen = {
	headerText = "Manage Tracked Data",
	textColor = "Lower box text",
	borderColor = "Lower box border",
	boxFillColor = "Lower box background",
}

TrackedDataScreen.Descriptions = {
	autosave = "All of the data that is tracked while you play is auto saved after each battle, stored as a .TDAT file",
	manualsave = "Old auto saved data will be lost if you start a new game on the same " .. Constants.Words.POKEMON .. " version. If you want to keep it, use Save Data",
}

TrackedDataScreen.OptionKeys = {
	"Auto save tracked game data",
}

TrackedDataScreen.Buttons = {
	SaveData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Save Data",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 19, Constants.SCREEN.MARGIN + 117, 44, 11 },
		onClick = function() TrackedDataScreen.openSaveDataPrompt() end
	},
	LoadData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Load Data",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 75, Constants.SCREEN.MARGIN + 117, 44, 11 },
		onClick = function() TrackedDataScreen.openLoadDataPrompt() end
	},
	ClearData = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = " * Clear Data *",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 63, 11 },
		confirmReset = false,
		onClick = function() TrackedDataScreen.tryClearData() end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Revert the Clear Data button
			TrackedDataScreen.Buttons.ClearData.text = " * Clear Data *"
			TrackedDataScreen.Buttons.ClearData.textColor = TrackedDataScreen.textColor
			TrackedDataScreen.Buttons.ClearData.confirmReset = false

			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
}

function TrackedDataScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8
	local startY = Constants.SCREEN.MARGIN + 52

	for _, optionKey in ipairs(TrackedDataScreen.OptionKeys) do
		TrackedDataScreen.Buttons[optionKey] = {
			type = Constants.ButtonTypes.CHECKBOX,
			text = optionKey,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionKey],
			toggleColor = "Positive text",
			onClick = function(self)
				-- Toggle the setting and store the change to be saved later in Settings.ini
				self.toggleState = not self.toggleState
				Options.updateSetting(self.text, self.toggleState)
			end
		}
		startY = startY + 10
	end

	for _, button in pairs(TrackedDataScreen.Buttons) do
		button.textColor = TrackedDataScreen.textColor
		button.boxColors = { TrackedDataScreen.borderColor, TrackedDataScreen.boxFillColor }
	end
end

function TrackedDataScreen.openSaveDataPrompt()
	Program.destroyActiveForm()
	local form = forms.newform(290, 130, "Save Tracker Data", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	local suggestedFileName = gameinfo.getromname()

	forms.label(form, "Enter a filename to save Tracker data to:", 18, 10, 300, 20)
	local saveTextBox = forms.textbox(form, suggestedFileName, 200, 30, nil, 20, 30)
	forms.label(form, ".TDAT", 219, 32, 45, 20)
	forms.button(form, "Save Data", function()
		local formInput = forms.gettext(saveTextBox)
		if formInput ~= nil and formInput ~= "" then
			if formInput:sub(-5):lower() ~= Constants.Files.Extensions.TRACKED_DATA then
				formInput = formInput .. Constants.Files.Extensions.TRACKED_DATA
			end
			Tracker.saveData(formInput)
		end
		client.unpause()
		forms.destroy(form)
	end, 55, 60)
	forms.button(form, "Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 140, 60)
end

function TrackedDataScreen.openLoadDataPrompt()
	local suggestedFileName = gameinfo.getromname() .. Constants.Files.Extensions.TRACKED_DATA
	local filterOptions = "Tracker Data (*.TDAT)|*.tdat|All files (*.*)|*.*"

	local workingDir = Utils.getWorkingDirectory()
	if workingDir ~= "" then
		workingDir = workingDir:sub(1, -2) -- remove trailing "/"
	end

	local filepath = forms.openfile(suggestedFileName, workingDir, filterOptions)
	if filepath ~= "" then
		Tracker.loadData(filepath)
	end
end

function TrackedDataScreen.tryClearData()
	local clearBtn = TrackedDataScreen.Buttons.ClearData
	if clearBtn.confirmReset then
		clearBtn.text = " Data Cleared!"
		clearBtn.textColor = "Positive text"
		clearBtn.confirmReset = false

		Tracker.resetData()
		Program.redraw(true)
	else
		clearBtn.text = " Are you sure?"
		clearBtn.textColor = "Negative text"
		clearBtn.confirmReset = true

		Program.redraw(true)
	end
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
	Drawing.drawText(topboxX + 20, Constants.SCREEN.MARGIN - 2, TrackedDataScreen.headerText:upper(), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[TrackedDataScreen.borderColor], Theme.COLORS[TrackedDataScreen.boxFillColor])

	local offsetX = topboxX + 2
	local offsetY = topboxY + 5

	local wrappedSummary = Utils.getWordWrapLines(TrackedDataScreen.Descriptions.autosave, 35)
	for _, line in pairs(wrappedSummary) do
		Drawing.drawText(offsetX, offsetY, line, Theme.COLORS[TrackedDataScreen.textColor], shadowcolor)
		offsetY = offsetY + 11
	end

	-- Draw all buttons
	for _, button in pairs(TrackedDataScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	offsetY = offsetY + 22

	-- Draw small divider line
	local dividerLine = Constants.BLANKLINE .. "" .. Constants.BLANKLINE .. "" .. Constants.BLANKLINE
	Drawing.drawText(offsetX + Utils.centerTextOffset(dividerLine) + 3, offsetY - 10, dividerLine, Theme.COLORS[TrackedDataScreen.textColor], shadowcolor)

	wrappedSummary = Utils.getWordWrapLines(TrackedDataScreen.Descriptions.manualsave, 32)
	for _, line in pairs(wrappedSummary) do
		Drawing.drawText(offsetX, offsetY, line, Theme.COLORS[TrackedDataScreen.textColor], shadowcolor)
		offsetY = offsetY + 11
	end
end
LogTabMisc = {
	TitleResourceKey = "HeaderTabMisc", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		highlight = "Intermediate text",
	},
	TabIcons = {
		PC = {
			x = 1, w = 12, h = 12,
			image = FileManager.buildImagePath("icons", "tiny-pc", ".png"),
		},
	},
}

local columnOffsetX = 100
LogTabMisc.Buttons = {
	UnlearnableTMsSettingButton = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Show unlearnable Gym TMs",
		getText = function(self) return Resources.LogOverlay.CheckboxShowUnlearnableGymTMs end,
		clickableArea = { LogOverlay.TabBox.x + 5, LogOverlay.TabBox.y + 5, 90, 10, },
		box = { LogOverlay.TabBox.x + 5, LogOverlay.TabBox.y + 5, 8, 8, },
		toggleState = Options["Show unlearnable Gym TMs"],
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end,
	},
	PreEvoSettingButton = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Show Pre Evolutions",
		getText = function(self) return Resources.LogOverlay.CheckboxShowPreEvolutions end,
		clickableArea = { LogOverlay.TabBox.x + 5, LogOverlay.TabBox.y + 17, 90, 10, },
		box = { LogOverlay.TabBox.x + 5, LogOverlay.TabBox.y + 17, 8, 8, },
		toggleState = Options["Show Pre Evolutions"],
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end,
	},
	CustomTrainerNames = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Use Custom Trainer Names",
		getText = function(self) return Resources.LogOverlay.CheckboxCustomTrainerNames end,
		clickableArea = { LogOverlay.TabBox.x + 5, LogOverlay.TabBox.y + 29, 90, 10, },
		box = { LogOverlay.TabBox.x + 5, LogOverlay.TabBox.y + 29, 8, 8, },
		toggleState = Options["Use Custom Trainer Names"],
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end,
	},
	ShareRandomizer = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.LogOverlay.ButtonShareSeed end,
		box = { Constants.SCREEN.WIDTH - LogOverlay.TabBox.x - 56, LogOverlay.TabBox.y + 4, 52, 11 },
		onClick = function(self) LogTabMisc.openRandomizerShareWindow() end,
	},
	PokemonGame = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.LabelPokemonGame .. ":" end,
		getValue = function(self) return RandomizerLog.Data.Settings.Game or Constants.BLANKLINE end,
		index = 1,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 55, 100, 11 },
		draw = function(self, shadowcolor)
			Drawing.drawText(self.box[1] + columnOffsetX, self.box[2], self:getValue(), Theme.COLORS[self.textColor], shadowcolor)
		end,
	},
	RandomizerVersion = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.LabelRandomizerVersion .. ":" end,
		getValue = function(self) return RandomizerLog.Data.Settings.Version or Constants.BLANKLINE end,
		index = 2,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 67, 100, 11 },
		draw = function(self, shadowcolor)
			Drawing.drawText(self.box[1] + columnOffsetX, self.box[2], self:getValue(), Theme.COLORS[self.textColor], shadowcolor)
		end,
	},
	RandomSeed = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.LabelRandomSeed .. ":" end,
		getValue = function(self) return RandomizerLog.Data.Settings.RandomSeed or Constants.BLANKLINE end,
		index = 3,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 79, 100, 11 },
		draw = function(self, shadowcolor)
			Drawing.drawText(self.box[1] + columnOffsetX, self.box[2], self:getValue(), Theme.COLORS[self.textColor], shadowcolor)
		end,
	},
	SettingsString = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.LabelSettingsString .. ":" end,
		getValue = function(self) return RandomizerLog.Data.Settings.SettingsString or Constants.BLANKLINE end,
		index = 4,
		box = { LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 91, 100, 11 },
		draw = function(self, shadowcolor)
			local settingsString = self:getValue()
			local offsetY = self.box[2] + Constants.SCREEN.LINESPACING
			local segmentWidth = 38
			for i = 1, 999, (segmentWidth + 1) do
				local settingsSegment = settingsString:sub(i, i + segmentWidth)
				if Utils.isNilOrEmpty(settingsSegment) then
					break
				end
				Drawing.drawText(self.box[1] + 8, offsetY, settingsSegment, Theme.COLORS[self.textColor], shadowcolor)
				offsetY = offsetY + Constants.SCREEN.LINESPACING
			end
		end,
	},
}

function LogTabMisc.initialize()
	for _, button in pairs(LogTabMisc.Buttons) do
		if button.textColor == nil then
			button.textColor = LogTabMisc.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { LogTabMisc.Colors.border, LogTabMisc.Colors.boxFill }
		end
	end

	LogTabMisc.refreshButtons()
end

function LogTabMisc.getTabIcons()
	return { LogTabMisc.TabIcons.PC }
end

function LogTabMisc.refreshButtons()
	for _, button in pairs(LogTabMisc.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabMisc.openRandomizerShareWindow()
	local form = ExternalUI.BizForms.createForm(Resources.LogOverlay.PromptShareSeedTitle, 515, 235)
	local newline = "\r\n"
	local shareExport = {}
	for _, button in ipairs(Utils.getSortedList(LogTabMisc.Buttons)) do
		local infoString = string.format("%s %s", button:getText(), button:getValue())
		if button == LogTabMisc.Buttons.SettingsString then
			infoString = newline .. infoString
		end
		table.insert(shareExport, infoString)
	end
	local multilineOutput = table.concat(shareExport, " " .. newline)

	form:createLabel(Resources.LogOverlay.PromptShareSeedDesc, 9, 10)
	form:createTextBox(multilineOutput, 10, 35, 480, 120, "", true, false, "Vertical")
	form:createButton(Resources.AllScreens.Close, 212, 165, function()
		form:destroy()
	end)
end

-- USER INPUT FUNCTIONS
function LogTabMisc.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabMisc.Buttons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabMisc.drawTab()
	local borderColor = Theme.COLORS[LogTabMisc.Colors.border]
	local fillColor = Theme.COLORS[LogTabMisc.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw all buttons
	for _, button in pairs(LogTabMisc.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

ExtrasScreen = {
	Colors = {
		text = "Lower box text",
		highlight = "Intermediate text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Tabs = {
		Tools = 1,
		Options = 2,
	},
	currentTab = 1,
}

-- Holds all the buttons for the screen
-- Buttons are created in CreateButtons()
ExtrasScreen.Buttons = {
	ViewLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self) return Resources.ExtrasScreen.ButtonViewLogs end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 27, 130, 16 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Tools end,
		onClick = function(self)
			Program.changeScreenView(ViewLogWarningScreen)
		end,
	},
	CoverageCalculator = {
		type = Constants.ButtonTypes.ICON_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonCoverageCalculator end,
		image = Constants.PixelImages.SWORD_ATTACK,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 47, 130, 16 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Tools end,
		onClick = function(self)
			CoverageCalcScreen.prepopulateMoveTypes()
			Program.changeScreenView(CoverageCalcScreen)
		end
	},
	TimeMachine = {
		type = Constants.ButtonTypes.ICON_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonTimeMachine end,
		image = Constants.PixelImages.CLOCK,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 67, 130, 16 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Tools end,
		onClick = function()
			TimeMachineScreen.buildOutPagedButtons()
			Program.changeScreenView(TimeMachineScreen)
		end
	},
	CrashRecovery = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.WARNING,
		getText = function(self) return Resources.ExtrasScreen.ButtonCrashRecovery end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 87, 130, 16 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Tools end,
		onClick = function(self)
			Program.changeScreenView(CrashRecoveryScreen)
		end
	},
	EstimateIVs = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getCustomText = function(self)
			if not Utils.isNilOrEmpty(self.ivText) then
				return self.ivText
			else
				return Resources.ExtrasScreen.ButtonEstimatePokemonIVs
			end
		end,
		ivText = "",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 107, 130, 16 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Tools end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(x + 1, y + 2, self:getCustomText(), Theme.COLORS[self.textColor or ExtrasScreen.Colors.text], shadowcolor)
		end,
		onClick = function(self)
			self.ivText = ExtrasScreen.getJudgeMessage()
			Program.redraw(true)
		end,
	},
	TimerEdit = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonEditTime end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5, Constants.SCREEN.MARGIN + 99, 24, 11 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Options and Options["Display play time"] end,
		draw = function(self, shadowcolor)
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
			Drawing.drawText(x, self.box[2] - 12, Resources.ExtrasScreen.LabelTimer .. ":", Theme.COLORS[self.textColor], shadowcolor)
		end,
		onClick = function(self) ExtrasScreen.openEditTimerPrompt() end,
	},
	TimerRelocate = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonRelocateTime end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 60, Constants.SCREEN.MARGIN + 99, 44, 11 },
		isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Options and Options["Display play time"] end,
		onClick = function(self)
			ExtrasScreen.relocateTimer()
			Program.redraw(true)
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		ExtrasScreen.currentTab = ExtrasScreen.Tabs.Tools
		ExtrasScreen.Buttons.EstimateIVs.ivText = "" -- keep hidden
		ExtrasScreen.refreshButtons()
		Program.changeScreenView(NavigationMenu)
	end),
}

function ExtrasScreen.initialize()
	ExtrasScreen.createTabs()
	ExtrasScreen.createButtons()

	for _, button in pairs(ExtrasScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = ExtrasScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { ExtrasScreen.Colors.border, ExtrasScreen.Colors.boxFill }
		end
	end

	ExtrasScreen.currentTab = ExtrasScreen.Tabs.Tools

	local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
	local animatedBtnOption = ExtrasScreen.Buttons["Animated Pokemon popout"]
	if not FileManager.fileExists(abraGif) and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
	end
end

function ExtrasScreen.refreshButtons()
	for _, button in pairs(ExtrasScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function ExtrasScreen.createTabs()
	-- { TabKey, ResourceKey }
	local tabs = {
		{ "Tools", "TabTools", },
		{ "Options", "TabOptions", },
	}

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local startY = Constants.SCREEN.MARGIN + 10
	local tabHeight = 12
	local tabPadding = 6

	for _, tuple in ipairs(tabs) do
		local tabText = Resources.ExtrasScreen[tuple[2]]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		ExtrasScreen.Buttons["Tab" .. tuple[1]] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return tabText end,
			tab = ExtrasScreen.Tabs[tuple[1]],
			isSelected = false,
			box = {	startX, startY, tabWidth, tabHeight },
			updateSelf = function(self)
				self.isSelected = (self.tab == ExtrasScreen.currentTab)
				self.textColor = self.isSelected and ExtrasScreen.Colors.highlight or ExtrasScreen.Colors.text
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local color = Theme.COLORS[self.boxColors[1]]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, bgColor, bgColor) -- Box fill
				if not self.isSelected then
					gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, Drawing.ColorEffects.DARKEN, Drawing.ColorEffects.DARKEN)
				end
				gui.drawLine(x + 1, y, x + w - 1, y, color) -- Top edge
				gui.drawLine(x, y + 1, x, y + h - 1, color) -- Left edge
				gui.drawLine(x + w, y + 1, x + w, y + h - 1, color) -- Right edge
				if self.isSelected then
					gui.drawLine(x + 1, y + h, x + w - 1, y + h, bgColor) -- Remove bottom edge
				end
				local centeredOffsetX = Utils.getCenteredTextX(self:getText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self)
				ExtrasScreen.currentTab = self.tab
				ExtrasScreen.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end

function ExtrasScreen.createButtons()
	local optionKeyMap = {
		{"Show random ball picker", "OptionShowRandomBallPicker", },
		{"Display repel usage", "OptionDisplayRepelUsage", },
		{"Display pedometer", "OptionDisplayPedometer", },
		{"Display play time", "OptionDisplayPlayTime", },
		{"Animated Pokemon popout", "OptionAnimatedPokemonPopout", },
	}

	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5
	local startY = Constants.SCREEN.MARGIN + 27
	local linespacing = Constants.SCREEN.LINESPACING + 1

	for _, optionTuple in ipairs(optionKeyMap) do
		ExtrasScreen.Buttons[optionTuple[1]] = {
			type = Constants.ButtonTypes.CHECKBOX,
			optionKey = optionTuple[1],
			getText = function(self) return Resources.ExtrasScreen[optionTuple[2]] end,
			clickableArea = { startX, startY, Constants.SCREEN.RIGHT_GAP - 12, 8 },
			box = {	startX, startY, 8, 8 },
			toggleState = Options[optionTuple[1]],
			updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
			isVisible = function(self) return ExtrasScreen.currentTab == ExtrasScreen.Tabs.Options end,
			onClick = function(self)
				self.toggleState = Options.toggleSetting(self.optionKey)

				-- If Animated Pokemon popout is turned on, create the popup form, or destroy it.
				if self.optionKey == "Animated Pokemon popout" then
					if self.toggleState == true then
						Drawing.AnimatedPokemon:create()
					else
						Drawing.AnimatedPokemon:destroy()
					end
				elseif self.optionKey == "Display play time" and self.toggleState then
					-- Show help tip for pausing (4 seconds)
					Program.GameTimer.showPauseTipUntil = os.time() + 4
				end
				Program.redraw(true)
			end
		}
		startY = startY + linespacing
	end
end

function ExtrasScreen.getJudgeMessage()
	local leadPokemon = Battle.getViewedPokemon(true) or {}
	if not PokemonData.isValid(leadPokemon.pokemonID) then
		return Resources.ExtrasScreen.EstimateResultUnavailable or ""
	end
	-- Source: https://bulbapedia.bulbagarden.net/wiki/Stats_judge
	local resultKey
	local ivEstimate = Utils.estimateIVs(leadPokemon) * 186
	if ivEstimate >= 151 then
		resultKey = Resources.ExtrasScreen.EstimateResultOutstanding
	elseif ivEstimate >= 121 and ivEstimate <= 150 then
		resultKey = Resources.ExtrasScreen.EstimateResultQuiteImpressive
	elseif ivEstimate >= 91 and ivEstimate <= 120 then
		resultKey = Resources.ExtrasScreen.EstimateResultAboveAverage
	else
		resultKey = Resources.ExtrasScreen.EstimateResultDecent
	end

	local pokemonName = PokemonData.Pokemon[leadPokemon.pokemonID].name
	return string.format("%s: %s", pokemonName, resultKey)

	-- Joey's Rattata meme (saving for later)
	-- local topPercentile = math.max(100 - 100 * Utils.estimateIVs(leadPokemon), 1)
	-- local percentText = string.format("%g", string.format("%d", topPercentile)) .. "%" -- %g removes insignificant 0's
	-- message = "In the top " .. percentText .. " of  " .. PokemonData.Pokemon[leadPokemon.pokemonID].name
end

function ExtrasScreen.openEditTimerPrompt()
	-- Pause the timer while editing if it wasn't already paused
	local wasPaused = Program.GameTimer.isPaused
	if not wasPaused then
		Program.GameTimer:pause()
	end
	local closeAndUnpauseTimer = function()
		if not wasPaused then
			Program.GameTimer:unpause()
		end
		Utils.closeBizhawkForm()
	end
	Input.allowMouse = false

	local form = Utils.createBizhawkForm(Resources.ExtrasScreen.LabelTimer, 320, 130, nil, nil, closeAndUnpauseTimer)

	local hour = math.floor(Tracker.Data.playtime / 3600) % 10000
	local min = math.floor(Tracker.Data.playtime / 60) % 60
	local sec = Tracker.Data.playtime % 60
	forms.label(form, "H", 60, 10, 15, 18)
	forms.label(form, "M", 130, 10, 15, 18)
	forms.label(form, "S", 200, 10, 15, 18)
	local hourBox = forms.textbox(form, hour, 40, 30, "SIGNED", 50, 30)
	local minBox = forms.textbox(form, min, 40, 30, "SIGNED", 120, 30)
	local secBox = forms.textbox(form, sec, 40, 30, "SIGNED", 190, 30)
	forms.button(form, Resources.AllScreens.Save, function()
		hour = tonumber(forms.gettext(hourBox) or "") or 0
		min = tonumber(forms.gettext(minBox) or "") or 0
		sec = tonumber(forms.gettext(secBox) or "") or 0
		-- Update total play time
		Tracker.Data.playtime = hour * 3600 + min * 60 + sec
		Program.GameTimer:update()
		closeAndUnpauseTimer()
		Program.redraw(true)
	end, 72, 60)
	forms.button(form, Resources.AllScreens.Cancel, function()
		closeAndUnpauseTimer()
	end, 157, 60)
end

function ExtrasScreen.relocateTimer()
	local nextLocationMap = {
		["UpperLeft"] = "UpperCenter",
		["UpperCenter"] = "UpperRight",
		["UpperRight"] = "LowerRight",
		["LowerRight"] = "LowerCenter",
		["LowerCenter"] = "LowerLeft",
		["LowerLeft"] = "UpperLeft",
	}
	Program.GameTimer.location = nextLocationMap[Program.GameTimer.location or ""] or "LowerRight"
	Program.GameTimer:updateLocationCoords()
	Options["Game timer location"] = Program.GameTimer.location
	Main.SaveSettings(true)
end

-- USER INPUT FUNCTIONS
function ExtrasScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, ExtrasScreen.Buttons)
end

-- DRAWING FUNCTIONS
function ExtrasScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[ExtrasScreen.Colors.boxFill])

	local tabHeight = 12
	local box = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[ExtrasScreen.Colors.text],
		border = Theme.COLORS[ExtrasScreen.Colors.border],
		fill = Theme.COLORS[ExtrasScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[ExtrasScreen.Colors.boxFill]),
	}

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(box.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.ExtrasScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(box.x, box.y + tabHeight, box.width, box.height - tabHeight, box.border, box.fill)
	-- Draw bottom edge for the window tab bars
	gui.drawLine(box.x, box.y + tabHeight, box.x + box.width, box.y + tabHeight, box.border)

	-- Draw all buttons
	for _, button in pairs(ExtrasScreen.Buttons) do
		Drawing.drawButton(button, box.shadow)
	end
end


ExtrasScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

-- Holds all the buttons for the screen
-- Buttons are created in CreateButtons()
ExtrasScreen.Buttons = {
	ViewLogFile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self) return Resources.ExtrasScreen.ButtonViewLogs end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 14, 52, 16 },
		onClick = function(self)
			Program.changeScreenView(ViewLogWarningScreen)
		end,
	},
	TimeMachine = {
		type = Constants.ButtonTypes.ICON_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonTimeMachine end,
		image = Constants.PixelImages.CLOCK,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 60, Constants.SCREEN.MARGIN + 14, 76, 16 },
		onClick = function()
			TimeMachineScreen.buildOutPagedButtons()
			Program.changeScreenView(TimeMachineScreen)
		end
	},
	TimerEdit = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonEditTime end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 64, Constants.SCREEN.MARGIN + 95, 24, 11 },
		isVisible = function(self) return Options["Display play time"] end,
		draw = function(self, shadowcolor)
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
			Drawing.drawText(x, self.box[2], Resources.ExtrasScreen.LabelTimer .. ":", Theme.COLORS[self.textColor], shadowcolor)
		end,
		onClick = function(self) ExtrasScreen.openEditTimerPrompt() end,
	},
	TimerRelocate = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.ExtrasScreen.ButtonRelocateTime end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 92, Constants.SCREEN.MARGIN + 95, 44, 11 },
		isVisible = function(self) return Options["Display play time"] end,
		onClick = function(self)
			ExtrasScreen.relocateTimer()
			Program.redraw(true)
		end,
	},
	EstimateIVs = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getCustomText = function(self)
			if self.ivText ~= nil and self.ivText ~= "" then
				return self.ivText
			else
				return Resources.ExtrasScreen.ButtonEstimatePokemonIVs
			end
		end,
		ivText = "",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 112, 132, 13 },
		draw = function(self, shadowcolor)
			-- Override drawing the button's text such that it's 1 pixel lower than normal
			local x, y = self.box[1], self.box[2]
			Drawing.drawText(x + 1, y + 1, self:getCustomText(), Theme.COLORS[self.textColor or ExtrasScreen.Colors.text], shadowcolor)
		end,
		onClick = function(self)
			self.ivText = ExtrasScreen.getJudgeMessage()
			Program.redraw(true)
		end,
	},
	CrashRecovery = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.WARNING,
		getText = function(self) return Resources.ExtrasScreen.ButtonCrashRecovery end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 130, 85, 16 },
		onClick = function(self)
			Program.changeScreenView(CrashRecoveryScreen)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		ExtrasScreen.Buttons.EstimateIVs.ivText = "" -- keep hidden
		Program.changeScreenView(NavigationMenu)
	end),
}

function ExtrasScreen.initialize()
	ExtrasScreen.createButtons()

	for _, button in pairs(ExtrasScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = ExtrasScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { ExtrasScreen.Colors.border, ExtrasScreen.Colors.boxFill }
		end
	end

	local abraGif = FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, "abra", FileManager.Extensions.ANIMATED_POKEMON)
	local animatedBtnOption = ExtrasScreen.Buttons["Animated Pokemon popout"]
	if not FileManager.fileExists(abraGif) and animatedBtnOption ~= nil then
		animatedBtnOption.disabled = true
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
	local startY = ExtrasScreen.Buttons.ViewLogFile.box[2] + ExtrasScreen.Buttons.ViewLogFile.box[4] + 5
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
	local leadPokemon = Battle.getViewedPokemon(true) or Tracker.getDefaultPokemon()
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

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[ExtrasScreen.Colors.boxFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.ExtrasScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[ExtrasScreen.Colors.border], Theme.COLORS[ExtrasScreen.Colors.boxFill])

	-- Draw all buttons
	for _, button in pairs(ExtrasScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end


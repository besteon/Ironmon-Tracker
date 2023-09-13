StartupScreen = {}

StartupScreen.Buttons = {
	SettingsGear = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 130, 8, 7, 7 },
		onClick = function(self) Program.changeScreenView(NavigationMenu) end
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 14, 31, 28 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 10, 32, 32 },
		pokemonID = 0,
		getIconId = function(self) return self.pokemonID, SpriteData.Types.Walk end,
		onClick = function(self) StartupScreen.openChoosePokemonWindow() end
	},
	UpdateAvailable = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Utils.inlineIf(self.newVersionAvailable, "*", "") end,
		textColor = "Positive text",
		newVersionAvailable = false,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 54, Constants.SCREEN.MARGIN + 12, 30, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 54, Constants.SCREEN.MARGIN + 12, 10, 10 },
		isVisible = function(self) return self.newVersionAvailable end,
		updateSelf = function(self)
			self.newVersionAvailable = not Main.isOnLatestVersion()
			if self.newVersionAvailable then
				local offsetX = Utils.calcWordPixelLength(Main.TrackerVersion .. " ")
				self.box[1] = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 54 + offsetX
			end
		end,
		onClick = function(self) Program.changeScreenView(UpdateScreen) end
	},
	AttemptsCount = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return tostring(Main.currentSeed) or Constants.BLANKLINE end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 54, Constants.SCREEN.MARGIN + 37, 33, 11 },
		isVisible = function() return Main.currentSeed > 1 end,
		onClick = function(self) StreamerScreen.openEditAttemptsWindow() end
	},
	NotesAreaEdit = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		textColor = "Lower box text",
		boxColors = { "Lower box border", "Lower box background" },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 128, Constants.SCREEN.MARGIN + 137, 10, 10 },
		isVisible = function() return not Options["Show on new game screen"] and Options["Welcome message"] == "" end,
		onClick = function(self) Program.changeScreenView(StreamerScreen) end
	},
	-- EraseGame = { -- Currently unused
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "< Press" end,
	-- 	textColor = "Lower box text",
	-- 	boxColors = { "Lower box border", "Lower box background" },
	-- 	box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 103, Constants.SCREEN.MARGIN + 135, 33, 11 },
	-- 	isVisible = function() return false and Options["Welcome message"] == "" end, -- TODO: For now, we aren't using this button
	-- 	onClick = function(self)
	-- 		if Main.IsOnBizhawk() then
	-- 			local joypadButtons = {
	-- 				Up = true,
	-- 				B = true,
	-- 				Select = true,
	-- 			}
	-- 			joypad.set(joypadButtons)
	-- 			Main.frameAdvance()
	-- 			joypad.set(joypadButtons)
	-- 		end
	-- 	end
	-- },
	PokemonFavorite1 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, 90, 32, 44 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, 86, 32, 32 },
		isVisible = function(self) return Options["Show on new game screen"] end,
		getIconId = function(self) return StreamerScreen.Buttons.PokemonFavorite1:getIconId() end,
		onClick = function(self) StreamerScreen.Buttons.PokemonFavorite1:onClick() end,
	},
	PokemonFavorite2 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, 90, 32, 44 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, 86, 32, 32 },
		isVisible = function(self) return Options["Show on new game screen"] end,
		getIconId = function(self) return StreamerScreen.Buttons.PokemonFavorite2:getIconId() end,
		onClick = function(self) StreamerScreen.Buttons.PokemonFavorite2:onClick() end,
	},
	PokemonFavorite3 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, 90, 32, 44 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, 86, 32, 32 },
		isVisible = function(self) return Options["Show on new game screen"] end,
		getIconId = function(self) return StreamerScreen.Buttons.PokemonFavorite3:getIconId() end,
		onClick = function(self) StreamerScreen.Buttons.PokemonFavorite3:onClick() end,
	},
}

function StartupScreen.initialize()
	StartupScreen.setPokemonIcon(Options["Startup Pokemon displayed"])

	for _, button in pairs(StartupScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = "Default text"
		end
		if button.boxColors == nil then
			button.boxColors = { "Upper box border", "Upper box background" }
		end
	end

	StartupScreen.refreshButtons()

	-- Output to console the Tracker data load status to help with troubleshooting
	if Tracker.LoadStatus ~= nil then
		local loadStatusMessage = Resources.StartupScreen[Tracker.LoadStatus]
		if loadStatusMessage then
			print(string.format("> %s: %s", Resources.StartupScreen.TrackedDataMsgLabel, loadStatusMessage))
		end
	end
end

function StartupScreen.refreshButtons()
	for _, button in pairs(StartupScreen.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function StartupScreen.setPokemonIcon(displayOption)
	local pokemonID = Utils.randomPokemonID()

	if displayOption == Options.StartupIcon.random then
		pokemonID = Utils.randomPokemonID()
		Options["Startup Pokemon displayed"] = Options.StartupIcon.random
	elseif displayOption == Options.StartupIcon.attempts then
		-- Show a Pokemon with a Gen 3 Pokedex number equal to the Attempts count
		pokemonID = (Main.currentSeed - 1) % (PokemonData.totalPokemon - 25) + 1
		if pokemonID > 251 then
			pokemonID = pokemonID + 25
		end
		Options["Startup Pokemon displayed"] = Options.StartupIcon.attempts
	elseif displayOption == Options.StartupIcon.none then
		pokemonID = 0
		Options["Startup Pokemon displayed"] = Options.StartupIcon.none
	else
		-- The option is a pokemonID already
		local id = tonumber(displayOption) or -1
		if PokemonData.isImageIDValid(id) then
			pokemonID = id
			Options["Startup Pokemon displayed"] = pokemonID
		end
	end

	if pokemonID ~= nil then
		StartupScreen.Buttons.PokemonIcon.pokemonID = pokemonID
	end
end

function StartupScreen.openChoosePokemonWindow()
	local form = Utils.createBizhawkForm(Resources.StartupScreen.PromptChooseAPokemonTitle, 330, 145)

	local dropdownOptions = {
		string.format("-- %s", Resources.StartupScreen.PromptChooseAPokemonByAttempt),
		string.format("-- %s", Resources.StartupScreen.PromptChooseAPokemonByRandom),
		string.format("-- %s", Resources.StartupScreen.PromptChooseAPokemonNone),
	}

	local allPokemon = PokemonData.namesToList()
	for _, opt in ipairs(dropdownOptions) do
		table.insert(allPokemon, opt)
	end
	table.insert(allPokemon, "...................................") -- A spacer to separate special options

	forms.label(form,Resources.StartupScreen.PromptChooseAPokemonDesc, 49, 10, 250, 20)
	local pokedexDropdown = forms.dropdown(form, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, allPokemon, true) -- true = alphabetize the list
	forms.setproperty(pokedexDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(pokedexDropdown, "AutoCompleteMode", "Append")

	local initialChoice
	if Options["Startup Pokemon displayed"] == Options.StartupIcon.attempts then
		initialChoice = dropdownOptions[1]
	elseif Options["Startup Pokemon displayed"] == Options.StartupIcon.random then
		initialChoice = dropdownOptions[2]
	elseif Options["Startup Pokemon displayed"] == Options.StartupIcon.none then
		initialChoice = dropdownOptions[3]
	else
		initialChoice = PokemonData.Pokemon[Options["Startup Pokemon displayed"] or "1"].name
	end
	forms.settext(pokedexDropdown, initialChoice)

	forms.button(form, Resources.AllScreens.Save, function()
		local optionSelected = forms.gettext(pokedexDropdown)

		if optionSelected == dropdownOptions[1] then
			optionSelected = Options.StartupIcon.attempts
		elseif optionSelected == dropdownOptions[2] then
			optionSelected = Options.StartupIcon.random
		elseif optionSelected == dropdownOptions[3] then
			optionSelected = Options.StartupIcon.none
		elseif optionSelected ~= "..................................." then
			-- The option is a Pokemon's name and needs to be convered to an ID
			optionSelected = PokemonData.getIdFromName(optionSelected) or -1
		end

		StartupScreen.setPokemonIcon(optionSelected)
		Program.redraw(true)
		Main.SaveSettings(true)

		Utils.closeBizhawkForm(form)
	end, 200, 29)

	forms.button(form, Resources.AllScreens.Cancel, function()
		Utils.closeBizhawkForm(form)
	end, 120, 69)
end

-- USER INPUT FUNCTIONS
function StartupScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, StartupScreen.Buttons)
end

-- DRAWING FUNCTIONS
function StartupScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = 72,
		text = Theme.COLORS["Default text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height + 12,
		width = topBox.width,
		height = Constants.SCREEN.HEIGHT - topBox.height - 22,
		text = Theme.COLORS["Lower box text"],
		border = Theme.COLORS["Lower box border"],
		fill = Theme.COLORS["Lower box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"]),
	}
	local topcolX = topBox.x + 55
	local textLineY = topBox.y + 1
	local linespacing = Constants.SCREEN.LINESPACING + 1

	-- TOP BORDER BOX
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	Drawing.drawText(topBox.x + 2, textLineY, Utils.toUpperUTF8(Resources.StartupScreen.Title), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing

	Drawing.drawText(topBox.x + 2, textLineY, Resources.StartupScreen.Version .. ":", topBox.text, topBox.shadow)
	Drawing.drawText(topcolX, textLineY, Main.TrackerVersion, topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	Drawing.drawText(topBox.x + 2, textLineY, Resources.StartupScreen.Game .. ":", topBox.text, topBox.shadow)
	Drawing.drawText(topcolX, textLineY, GameSettings.versioncolor, topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	if StartupScreen.Buttons.AttemptsCount.isVisible() then
		Drawing.drawText(topBox.x + 2, textLineY, Resources.StartupScreen.Attempts .. ":", topBox.text, topBox.shadow)
	end
	textLineY = textLineY + linespacing

	-- Display info about the tracked data notes, except when starting a new game (keep it clean)
	if Tracker.LoadStatus and Tracker.LoadStatus ~= Tracker.LoadStatusKeys.NEW_GAME then
		local messageColor
		if Tracker.LoadStatus == Tracker.LoadStatusKeys.LOAD_SUCCESS then
			messageColor = Theme.COLORS["Positive text"]
		elseif Tracker.LoadStatus == Tracker.LoadStatusKeys.ERROR then
			messageColor = Theme.COLORS["Negative text"]
		else
			messageColor = topBox.text
		end

		local trackerNotesLabel = string.format("%s:", Resources.StartupScreen.TrackedDataMsgLabel or "")
		Drawing.drawText(topBox.x + 2, textLineY, trackerNotesLabel, topBox.text, topBox.shadow)
		textLineY = textLineY + linespacing - 2
		Drawing.drawText(topBox.x + 2, textLineY, Resources.StartupScreen[Tracker.LoadStatus] or "", messageColor, topBox.shadow)
	end

	-- If Favorites are selected to be shown and no custom welcome message has been written, show game controls by default
	local showCustomWelcome = Options["Show on new game screen"] or Options["Welcome message"] ~= ""

	-- HEADER DIVIDER
	if showCustomWelcome then
		if Options["Show on new game screen"] then
			local bgShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
			Drawing.drawText(botBox.x + 1, botBox.y - 11, Resources.StartupScreen.HeaderFavorites, Theme.COLORS["Header text"], bgShadow)
		end
	else
		local bgShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
		Drawing.drawText(botBox.x + 1, botBox.y - 11, Resources.StartupScreen.HeaderControls, Theme.COLORS["Header text"], bgShadow)
	end

	-- BOTTOM BORDER BOX
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)
	textLineY = botBox.y + 1

	if showCustomWelcome then
		textLineY = textLineY + 1
		if Options["Show on new game screen"] then
			textLineY = textLineY + 30
		end

		-- Draw the customized welcome message (editable through the StreamerScreen)
		local welcomeMsg = Utils.formatSpecialCharacters(Options["Welcome message"])
		welcomeMsg = Utils.encodeDecodeForSettingsIni(welcomeMsg, false)
		local lines = {}
		for line in welcomeMsg:gmatch("[^\r\n]+") do
			table.insert(lines, line)
			Drawing.drawText(botBox.x + 2, textLineY, line, botBox.text, botBox.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
		-- Redraw main background on the right to cut-off excess text overflow
		gui.drawLine(botBox.x + botBox.width, botBox.y, botBox.x + botBox.width, botBox.y + botBox.height, botBox.border)
		gui.drawRectangle(botBox.x + botBox.width + 1, botBox.y, Constants.SCREEN.MARGIN, botBox.height, Theme.COLORS["Main background"], Theme.COLORS["Main background"])
	else
		-- Draw the GBA pixel image as a black icon against white background
		local gbaX = botBox.x + 117
		local gbaY = botBox.y + 2
		gui.drawRectangle(gbaX - 2, gbaY - 2, 25, 16, botBox.border, Drawing.Colors.WHITE)
		Drawing.drawImageAsPixels(Constants.PixelImages.GBA, gbaX, gbaY, { Drawing.Colors.BLACK, Drawing.Colors.WHITE })

		local indentChars = "    "
		local swapFormatted = indentChars .. Options.CONTROLS["Toggle view"]:upper()
		Drawing.drawText(botBox.x + 2, textLineY, Resources.StartupScreen.ControlsSwapView .. ":", botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing - 2
		Drawing.drawText(botBox.x + 2, textLineY, swapFormatted, botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing - 1

		local comboFormatted = indentChars .. Options.CONTROLS["Load next seed"]:upper():gsub(" ", ""):gsub(",", " + ")
		Drawing.drawText(botBox.x + 2, textLineY, Resources.StartupScreen.ControlsQuickload .. ":", botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing - 2
		Drawing.drawText(botBox.x + 2, textLineY, comboFormatted, botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing - 1

		local clearFormatted = indentChars .. "UP + B + SELECT"
		Drawing.drawText(botBox.x + 2, textLineY, Resources.StartupScreen.ControlsEraseGameSave .. ":", botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing - 2
		Drawing.drawText(botBox.x + 2, textLineY, clearFormatted, botBox.text, botBox.shadow)
		textLineY = textLineY + linespacing - 1
	end

	-- Temporarily vertically center-align the Favorite Pokemon icons if no welcome message
	local prevYs = {}
	if Options["Show on new game screen"] and Options["Welcome message"] == "" then
		prevYs = {
			StartupScreen.Buttons.PokemonFavorite1.box[2],
			StartupScreen.Buttons.PokemonFavorite2.box[2],
			StartupScreen.Buttons.PokemonFavorite3.box[2],
		}
		StartupScreen.Buttons.PokemonFavorite1.box[2] = prevYs[1] + 15
		StartupScreen.Buttons.PokemonFavorite2.box[2] = prevYs[2] + 15
		StartupScreen.Buttons.PokemonFavorite3.box[2] = prevYs[3] + 15
	end

	-- Draw all buttons
	for _, button in pairs(StartupScreen.Buttons) do
		local buttonShadow = Utils.inlineIf(button.boxColors[2] == "Upper box background", topBox.shadow, botBox.shadow)
		Drawing.drawButton(button, buttonShadow)
	end

	if Options["Show on new game screen"] and Options["Welcome message"] == "" then
		StartupScreen.Buttons.PokemonFavorite1.box[2] = prevYs[1]
		StartupScreen.Buttons.PokemonFavorite2.box[2] = prevYs[2]
		StartupScreen.Buttons.PokemonFavorite3.box[2] = prevYs[3]
	end
end
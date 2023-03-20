StreamerScreen = {
	Labels = {
		header = "Streamer Tools",
		attemptsCount = "Attempts Count:",
		welcomeMessage = "Welcome Message:",
		editButton = " Edit",
		favorites = "Favorite " .. Constants.Words.POKEMON .. ":",
	},
	Colors = {
		upperText = "Default text",
		upperBorder = "Upper box border",
		upperBoxFill = "Upper box background",
		lowerText = "Lower box text",
		lowerBorder = "Lower box border",
		lowerBoxFill = "Lower box background",
	},
}

StreamerScreen.Buttons = {
	AttemptsCountEdit = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = StreamerScreen.Labels.editButton,
		label = StreamerScreen.Labels.attemptsCount,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 14, 23, 11 },
		draw = function(self, shadowcolor)
			-- Draw the Label text to its left
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
			local y = self.box[2]
			Drawing.drawText(x, y, self.label, Theme.COLORS[self.textColor], shadowcolor)
		end,
		onClick = function(self) StartupScreen.openEditAttemptsWindow() end,
	},
	WelcomeMessageEdit = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = StreamerScreen.Labels.editButton,
		label = StreamerScreen.Labels.welcomeMessage,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 29, 23, 11 },
		draw = function(self, shadowcolor)
			-- Draw the Label text to its left
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
			local y = self.box[2]
			Drawing.drawText(x, y, self.label, Theme.COLORS[self.textColor], shadowcolor)
		end,
		onClick = function(self) StreamerScreen.openEditWelcomeMessageWindow() end,
	},
	ShowFavorites = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = " Show on new game screen", -- offset with a space for appearance
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 64, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 64, 8, 8 },
		toggleState = false, -- update later in initialize
		toggleColor = "Positive text",
		onClick = function(self)
			-- Toggle the setting and store the change to be saved later in Settings.ini
			self.toggleState = not self.toggleState
			Options.updateSetting("Show on new game screen", self.toggleState)
			Options.forceSave()
		end
	},
	PokemonFavorite1 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, 79, 32, 29 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, 75, 32, 32 },
		pokemonID = 1,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			StreamerScreen.openPokemonPickerWindow(self, self.pokemonID)
			Program.redraw(true)
		end,
	},
	PokemonFavorite2 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, 79, 32, 29 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, 75, 32, 32 },
		pokemonID = 4,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			StreamerScreen.openPokemonPickerWindow(self, self.pokemonID)
			Program.redraw(true)
		end,
	},
	PokemonFavorite3 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, 79, 32, 29 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, 75, 32, 32 },
		pokemonID = 7,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			StreamerScreen.openPokemonPickerWindow(self, self.pokemonID)
			Program.redraw(true)
		end,
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		-- boxColors = { "Lower box border", "Lower box background" }, -- leave for when adding in second box later
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			Program.changeScreenView(NavigationMenu)
		end
	},
}

function StreamerScreen.initialize()
	for _, button in pairs(StreamerScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = StreamerScreen.Colors.upperText
		end
		if button.boxColors == nil then
			button.boxColors = { StreamerScreen.Colors.upperBorder, StreamerScreen.Colors.upperBoxFill }
		end
	end

	StreamerScreen.Buttons.ShowFavorites.toggleState = Options["Show on new game screen"] or false

	StreamerScreen.loadFavorites()
end

function StreamerScreen.openEditWelcomeMessageWindow()
	Program.destroyActiveForm()
	local form = forms.newform(515, 235, "Edit Welcome Message", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		forms.setproperty(form, "BlocksInputWhenFocused", true)
	end

	local welcomeMsg = Utils.formatSpecialCharacters(Options["Welcome message"])
	welcomeMsg = Utils.encodeDecodeForSettingsIni(welcomeMsg, false)

	forms.label(form, "Edit the welcome message box on the Tracker, shown each time a new game begins.", 9, 10, 495, 20)
	local welcomeTextBox = forms.textbox(form, welcomeMsg, 480, 120, nil, 10, 35, true, false, "Vertical")
	forms.button(form, "Save", function()
		local newMessage = Utils.formatSpecialCharacters(forms.gettext(welcomeTextBox))
		newMessage = Utils.encodeDecodeForSettingsIni(newMessage, true)
		Options["Welcome message"] = newMessage
		Main.SaveSettings(true)

		client.unpause()
		forms.destroy(form)
	end, 120, 165)

	forms.button(form, "Clear", function()
		forms.settext(welcomeTextBox, "")
	end, 205, 165)

	forms.button(form, "Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 290, 165)
end

function StreamerScreen.openPokemonPickerWindow(iconButton, initPokemonID)
	if iconButton == nil then return end
	if not PokemonData.isValid(initPokemonID) then
		initPokemonID = Utils.randomPokemonID()
	end

	Program.destroyActiveForm()
	local form = forms.newform(330, 145, "Choose a Favorite", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		forms.setproperty(form, "BlocksInputWhenFocused", true)
	end

	local allPokemon = PokemonData.namesToList()

	forms.label(form, "Favorite Pokemon are shown as a new game begins.", 24, 10, 300, 20)
	local pokedexDropdown = forms.dropdown(form, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, allPokemon, true) -- true = alphabetize the list
	forms.setproperty(pokedexDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(pokedexDropdown, "AutoCompleteMode", "Append")
	forms.settext(pokedexDropdown, PokemonData.Pokemon[initPokemonID].name)

	forms.button(form, "Save", function()
		local optionSelected = forms.gettext(pokedexDropdown)
		iconButton.pokemonID = PokemonData.getIdFromName(optionSelected) or 0

		StreamerScreen.saveFavorites()
		Program.redraw(true)

		client.unpause()
		forms.destroy(form)
	end, 200, 29)

	forms.button(form,"Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 120, 69)
end

function StreamerScreen.loadFavorites()
	local favorites = Options["Startup favorites"] or "1,4,7" -- Default bulbasaur, charmander, squirtle
	local first, second, third = string.match(favorites, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
	first = first or "1"
	second = second or "4"
	third = third or "7"
	StreamerScreen.Buttons.PokemonFavorite1.pokemonID = tonumber(first) or 1
	StreamerScreen.Buttons.PokemonFavorite2.pokemonID = tonumber(second) or 4
	StreamerScreen.Buttons.PokemonFavorite3.pokemonID = tonumber(third) or 7
end

function StreamerScreen.saveFavorites()
	local favoriteIds = {
		StreamerScreen.Buttons.PokemonFavorite1.pokemonID or 0,
		StreamerScreen.Buttons.PokemonFavorite2.pokemonID or 0,
		StreamerScreen.Buttons.PokemonFavorite3.pokemonID or 0,
	}
	Options["Startup favorites"] = table.concat(favoriteIds, ",")
	Main.SaveSettings(true)
end

-- USER INPUT FUNCTIONS
function StreamerScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, StreamerScreen.Buttons)
end

-- DRAWING FUNCTIONS
function StreamerScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[StreamerScreen.Colors.upperText],
		border = Theme.COLORS[StreamerScreen.Colors.upperBorder],
		fill = Theme.COLORS[StreamerScreen.Colors.upperBoxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[StreamerScreen.Colors.upperBoxFill]),
	}
	-- Will use the bottom-box later for OAuth Twitch stuff
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height + 5,
		width = topBox.width,
		height = Constants.SCREEN.HEIGHT - topBox.height - 15,
		text = Theme.COLORS[StreamerScreen.Colors.lowerText],
		border = Theme.COLORS[StreamerScreen.Colors.lowerBorder],
		fill = Theme.COLORS[StreamerScreen.Colors.lowerBoxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[StreamerScreen.Colors.lowerBoxFill]),
	}
	local textLineY = topBox.y + 2

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	local headerText = StreamerScreen.Labels.header:upper()
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local offsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + offsetX, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw Favorites Label
	Drawing.drawText(topBox.x + 3, topBox.y + 40, StreamerScreen.Labels.favorites, topBox.text, topBox.shadow)

	-- Draw bottom border box
	-- gui.defaultTextBackground(botBox.fill)
	-- gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)

	-- Draw all buttons
	for _, button in pairs(StreamerScreen.Buttons) do
		local buttonShadow
		if button.boxColors[2] == StreamerScreen.Colors.upperBoxFill then
			buttonShadow = topBox.shadow
		else
			buttonShadow = botBox.shadow
		end
		Drawing.drawButton(button, buttonShadow)
	end
end
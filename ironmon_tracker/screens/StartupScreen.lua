StartupScreen = {
	Labels = {
		title = "Ironmon Tracker",
		version = "Version:",
		game = "Game:",
		attempts = "Attempts:",
		controls = "GBA Controls:",
		swapView = "Swap viewed " .. Constants.Words.POKEMON .. ":",
		quickload = "Quick- load next ROM:",
		eraseSave = "Erase game save data:",
	},
}

StartupScreen.Buttons = {
	SettingsGear = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 130, 8, 7, 7 },
		onClick = function(self)
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 10, 32, 32 },
		pokemonID = 0,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. self.pokemonID .. iconset.extension
			return imagepath
		end,
		onClick = function(self)
			StartupScreen.openChoosePokemonWindow()
		end
	},
	AttemptsCount = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = Constants.BLANKLINE,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 54, Constants.SCREEN.MARGIN + 37, 33, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		isVisible = function() return Main.currentSeed > 1 end,
		onClick = function(self)
			StartupScreen.openEditAttemptsWindow()
		end
	},
	EraseGame = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "< Press",
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 103, Constants.SCREEN.MARGIN + 135, 33, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return false end, -- TODO: For now, we aren't using this button
		onClick = function(self)
			local joypadButtons = {
				Up = true,
				B = true,
				Select = true,
			}
			joypad.set(joypadButtons)
			emu.frameadvance()
			joypad.set(joypadButtons)
		end
	},
}

function StartupScreen.initialize()
	StartupScreen.setPokemonIcon(Options["Startup Pokemon displayed"])

	StartupScreen.Buttons.AttemptsCount.text = tostring(Main.currentSeed)
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
	Program.destroyActiveForm()
	local form = forms.newform(330, 145, "Choose a Pokemon", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	local allPokemon = PokemonData.toList()
	table.insert(allPokemon, "-- Based on attempt #")
	table.insert(allPokemon, "-- Random each time")
	table.insert(allPokemon, "...................................") -- A spacer to separate special options

	forms.label(form, "Choose a Pokemon to show during startup:", 49, 10, 250, 20)
	local pokedexDropdown = forms.dropdown(form, {["Init"]="Loading Pokedex"}, 50, 30, 145, 30)
	forms.setdropdownitems(pokedexDropdown, allPokemon, true) -- true = alphabetize the list
	forms.setproperty(pokedexDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(pokedexDropdown, "AutoCompleteMode", "Append")
	forms.settext(pokedexDropdown, "-- Based on attempt #")

	forms.button(form, "Save", function()
		local optionSelected = forms.gettext(pokedexDropdown)

		if optionSelected == "-- Based on attempt #" then
			optionSelected = Options.StartupIcon.attempts
		elseif optionSelected == "-- Random each time" then
			optionSelected = Options.StartupIcon.random
		elseif optionSelected ~= "..................................." then
			-- The option is a Pokemon's name and needs to be convered to an ID
			optionSelected = PokemonData.getIdFromName(optionSelected) or -1
		end

		StartupScreen.setPokemonIcon(optionSelected)
		Program.redraw(true)
		Main.SaveSettings(true)

		client.unpause()
		forms.destroy(form)
	end, 200, 29)

	forms.button(form,"Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 120, 69)
end

function StartupScreen.openEditAttemptsWindow()
	Program.destroyActiveForm()
	local form = forms.newform(320, 130, "Edit Attempts Counter", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	forms.label(form, "Enter the number of attempts:", 48, 10, 300, 20)
	local textBox = forms.textbox(form, Main.currentSeed, 200, 30, "UNSIGNED", 50, 30)
	forms.button(form, "Save", function()
		local formInput = forms.gettext(textBox)
		if formInput ~= nil and formInput ~= "" then
			local newAttemptsCount = tonumber(formInput)
			if newAttemptsCount ~= nil then
				Main.currentSeed = newAttemptsCount
				StartupScreen.Buttons.AttemptsCount.text = newAttemptsCount

				local filename = Main.GetAttemptsFile()
				if filename ~= nil then
					Main.WriteAttemptsCounter(filename, newAttemptsCount)
				end

				Program.redraw(true)
			end
		end
		client.unpause()
		forms.destroy(form)
	end, 72, 60)
	forms.button(form, "Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 157, 60)
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
		y = topBox.y + topBox.height + 13,
		width = topBox.width,
		height = 65,
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

	Drawing.drawText(topBox.x + 2, textLineY, StartupScreen.Labels.title:upper(), Theme.COLORS["Intermediate text"], topBox.shadow)
	textLineY = textLineY + linespacing

	Drawing.drawText(topBox.x + 2, textLineY, StartupScreen.Labels.version, topBox.text, topBox.shadow)
	Drawing.drawText(topcolX, textLineY, Main.TrackerVersion, topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	Drawing.drawText(topBox.x + 2, textLineY, StartupScreen.Labels.game, topBox.text, topBox.shadow)
	Drawing.drawText(topcolX, textLineY, GameSettings.versioncolor, topBox.text, topBox.shadow)
	textLineY = textLineY + linespacing

	if StartupScreen.Buttons.AttemptsCount.isVisible() then
		Drawing.drawText(topBox.x + 2, textLineY, StartupScreen.Labels.attempts, topBox.text, topBox.shadow)
		Drawing.drawButton(StartupScreen.Buttons.AttemptsCount, topBox.shadow)
	end
	textLineY = textLineY + linespacing

	local successfulData = Tracker.DataMessage:find(Tracker.LoadStatusMessages.fromFile) ~= nil
	local dataColor = Utils.inlineIf(successfulData, Theme.COLORS["Positive text"], topBox.text)
	local wrappedText = Utils.getWordWrapLines(Tracker.DataMessage, 32)
	if #wrappedText == 1 then
		Drawing.drawText(topBox.x + 2, textLineY, wrappedText[1], dataColor, topBox.shadow)
	elseif #wrappedText >= 2 then
		Drawing.drawText(topBox.x + 2, textLineY, wrappedText[1], dataColor, topBox.shadow)
		textLineY = textLineY + linespacing - 2
		Drawing.drawText(topBox.x + 2, textLineY, wrappedText[2], dataColor, topBox.shadow)
	end

	-- HEADER DIVIDER
	local bgShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(botBox.x + 1, botBox.y - 11, StartupScreen.Labels.controls, Theme.COLORS["Header text"], bgShadow)

	-- BOTTOM BORDER BOX
	gui.defaultTextBackground(botBox.fill)
	gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)
	textLineY = botBox.y + 1

	-- Draw the GBA pixel image as a black icon against white background
	local gbaX = botBox.x + 117
	local gbaY = botBox.y + 2
	gui.drawRectangle(gbaX - 2, gbaY - 2, 25, 16, botBox.border, 0xFFFFFFFF)
	Drawing.drawImageAsPixels(Constants.PixelImages.GBA, gbaX, gbaY, { 0xFF000000, 0xFFFFFFFF })

	local indentChars = "    "
	local swapFormatted = indentChars .. Options.CONTROLS["Toggle view"]:upper()
	Drawing.drawText(botBox.x + 2, textLineY, StartupScreen.Labels.swapView, botBox.text, botBox.shadow)
	textLineY = textLineY + linespacing - 2
	Drawing.drawText(botBox.x + 2, textLineY, swapFormatted, botBox.text, botBox.shadow)
	textLineY = textLineY + linespacing - 1

	local comboFormatted = indentChars .. Options.CONTROLS["Load next seed"]:upper():gsub(" ", ""):gsub(",", " + ")
	Drawing.drawText(botBox.x + 2, textLineY, StartupScreen.Labels.quickload, botBox.text, botBox.shadow)
	textLineY = textLineY + linespacing - 2
	Drawing.drawText(botBox.x + 2, textLineY, comboFormatted, botBox.text, botBox.shadow)
	textLineY = textLineY + linespacing - 1

	local clearFormatted = indentChars .. "UP + B + SELECT"
	Drawing.drawText(botBox.x + 2, textLineY, StartupScreen.Labels.eraseSave, botBox.text, botBox.shadow)
	textLineY = textLineY + linespacing - 2
	Drawing.drawText(botBox.x + 2, textLineY, clearFormatted, botBox.text, botBox.shadow)
	textLineY = textLineY + linespacing - 1

	Drawing.drawButton(StartupScreen.Buttons.SettingsGear, topBox.shadow)
	Drawing.drawButton(StartupScreen.Buttons.PokemonIcon, topBox.shadow)
	Drawing.drawButton(StartupScreen.Buttons.EraseGame, botBox.shadow)
end
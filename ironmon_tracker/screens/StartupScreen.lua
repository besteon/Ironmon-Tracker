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
		pokemonID = 1,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. self.pokemonID .. iconset.extension
			return imagepath
		end,
		onClick = function(self)
			self.pokemonID = Utils.randomPokemonID()
			Program.redraw(true)
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
	-- Show a Pokemon with a Gen 3 Pokedex number equal to the Attempts count
	local pokemonID = (Main.currentSeed - 1) % (PokemonData.totalPokemon - 25) + 1
	if pokemonID > 251 then
		pokemonID = pokemonID + 25
	end
	StartupScreen.Buttons.PokemonIcon.pokemonID = pokemonID
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

	if Main.currentSeed > 1 then
		Drawing.drawText(topBox.x + 2, textLineY, StartupScreen.Labels.attempts, topBox.text, topBox.shadow)
		Drawing.drawText(topcolX, textLineY, Main.currentSeed, topBox.text, topBox.shadow)
	else
		Drawing.drawText(topBox.x + 2, textLineY, Constants.BLANKLINE, topBox.text, topBox.shadow)
	end
	textLineY = textLineY + linespacing

	local successfulData = Tracker.DataMessage:find("^Tracker data loaded from file") ~= nil
	local dataColor = Utils.inlineIf(successfulData, Theme.COLORS["Positive text"], topBox.text)
	local wrappedText = Utils.getWordWrapLines(Tracker.DataMessage, 34) -- was 31
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
	Drawing.drawImageAsPixels(Constants.PixelImages.GBA, gbaX, gbaY, 0xFF000000, 0xFFFFFFFF)

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
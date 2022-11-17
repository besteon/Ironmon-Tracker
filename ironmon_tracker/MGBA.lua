MGBA = {
	-- TextBuffer screens
	Screens = {
	},
}

function MGBA.initialize()
	-- Currently unused
end

function MGBA.createBuffers()
	local screens = { "Main Screen" } -- , "Enemy Screen"
	for _, screen in ipairs(screens) do
		MGBA.Screens[screen] = console:createBuffer(screen)
	end
end

function MGBA.drawScreen()
	local screen = MGBA.Screens["Main Screen"]

	local pokemon = Battle.getViewedPokemon(true) or Tracker.getDefaultPokemon()
	local abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)

	-- console:log(PokemonData.Pokemon[pokemon.pokemonID].name)

	local bar = "%-15s %-4s%3s"
	local lines = {
		string.format(bar, PokemonData.Pokemon[pokemon.pokemonID].name, "HP", pokemon.stats.hp),
		string.format(bar, string.format("HP: %s/%s", pokemon.curHP, pokemon.stats.hp), "ATK", pokemon.stats.atk),
		string.format(bar, string.format("Lv.%s (%s)", pokemon.level, pokemon.evolution or Constants.BLANKLINE), "DEF", pokemon.stats.def),
		string.format(bar, string.format("%s", MiscData.Items[pokemon.heldItem] or Constants.BLANKLINE), "SPA", pokemon.stats.spa),
		string.format(bar, string.format("%s", AbilityData.Abilities[abilityId].name), "SPD", pokemon.stats.spd),
		string.format(bar, string.format("%s", Constants.BLANKLINE), "SPE", pokemon.stats.spe),
	}

	screen:clear()
	-- screen:moveCursor(0, 0)
	for _, line in ipairs(lines) do
		screen:print(line)
		screen:print('\n')
	end
end

function MGBA.drawPokemonIcon(pokemonID, x, y)
	if not PokemonData.isImageIDValid(pokemonID) then
		pokemonID = 0 -- Blank Pokemon data/icon
	end

	local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
	local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. pokemonID .. iconset.extension

	-- gui.drawImage(imagepath, x, y + iconset.yOffset, 32, 32)
end

function MGBA.drawTypeIcon(type, x, y)
	if type == nil or type == "" then return end

	-- gui.drawImage(Main.DataFolder .. "/images/types/" .. type .. ".png", x, y, 30, 12)
end

function MGBA.drawStatusIcon(status, x, y)
	if status == nil or status == "" then return end

	-- gui.drawImage(Main.DataFolder .. "/images/status/" .. status .. ".png", x, y, 16, 8)
end

function MGBA.drawText(x, y, text, color, shadowcolor, style)
	-- if Theme.DRAW_TEXT_SHADOWS then
	-- 	gui.drawText(x + 1, y + 1, text, shadowcolor, nil, Constants.Font.SIZE, Constants.Font.FAMILY, style)
	-- end
	-- gui.drawText(x, y, text, color, nil, Constants.Font.SIZE, Constants.Font.FAMILY, style)
end

function MGBA.drawNumber(x, y, number, spacing, color, shadowcolor, style)
	-- if Options["Right justified numbers"] then
	-- 	MGBA.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, style)
	-- else
	-- 	MGBA.drawText(x, y, number, color, shadowcolor, style)
	-- end
end

function MGBA.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, style)
	local new_spacing = (spacing - string.len(tostring(number))) * 5
	if number == Constants.BLANKLINE then new_spacing = 8 end
	-- MGBA.drawText(x + new_spacing, y, number, color, shadowcolor, style)
end

function MGBA.drawChevron(x, y, width, height, thickness, direction, hasColor)
	local color = Theme.COLORS["Default text"]
	local i = 0
	if direction == "up" then
		if hasColor then
			color = Theme.COLORS["Positive text"]
		end
		y = y + height + thickness + 1
		while i < thickness do
			-- gui.drawLine(x, y - i, x + (width / 2), y - i - height, color)
			-- gui.drawLine(x + (width / 2), y - i - height, x + width, y - i, color)
			i = i + 1
		end
	elseif direction == "down" then
		if hasColor then
			color = Theme.COLORS["Negative text"]
		end
		y = y + thickness + 2
		while i < thickness do
			-- gui.drawLine(x, y + i, x + (width / 2), y + i + height, color)
			-- gui.drawLine(x + (width / 2), y + i + height, x + width, y + i, color)
			i = i + 1
		end
	end
end

-- draws chevrons bottom-up, coloring them if 'intensity' is a value beyond 'max'
-- 'intensity' ranges from -N to +N, where N is twice 'max'; negative intensity are drawn downward
function MGBA.drawChevrons(x, y, intensity, max)
	if intensity == 0 then return end

	local weight = math.abs(intensity)
	local spacing = 2

	for index = 0, max - 1, 1 do
		if weight > index then
			local hasColor = weight > max + index
			MGBA.drawChevron(x, y, 4, 2, 1, Utils.inlineIf(intensity > 0, "up", "down"), hasColor)
			y = y - spacing
		end
	end
end

function MGBA.drawMoveEffectiveness(x, y, value)
	if value == 2 then
		MGBA.drawChevron(x, y + 4, 4, 2, 1, "up", true)
	elseif value == 4 then
		MGBA.drawChevron(x, y + 4, 4, 2, 1, "up", true)
		MGBA.drawChevron(x, y + 2, 4, 2, 1, "up", true)
	elseif value == 0.5 then
		MGBA.drawChevron(x, y, 4, 2, 1, "down", true)
	elseif value == 0.25 then
		MGBA.drawChevron(x, y, 4, 2, 1, "down", true)
		MGBA.drawChevron(x, y + 2, 4, 2, 1, "down", true)
	end
end

function MGBA.drawButton(button, shadowcolor)
	if true then return end
	if button == nil or button.box == nil then return end

	-- Don't draw the button if it's currently not visible
	if button.isVisible ~= nil and not button:isVisible() then
		return
	end

	local x = button.box[1]
	local y = button.box[2]
	local width = button.box[3]
	local height = button.box[4]

	-- First draw a box if
	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.CHECKBOX or button.type == Constants.ButtonTypes.STAT_STAGE then
		local bordercolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[1]], Theme.COLORS["Upper box border"])
		local fillcolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[2]], Theme.COLORS["Upper box background"])

		-- Draw the box's shadow and the box border
		if shadowcolor ~= nil then
			gui.drawRectangle(x + 1, y + 1, width, height, shadowcolor, fillcolor)
		end
		gui.drawRectangle(x, y, width, height, bordercolor, fillcolor)
	end

	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.NO_BORDER then
		if button.text ~= nil and button.text ~= "" then
			MGBA.drawText(x + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.CHECKBOX then
		if button.text ~= nil and button.text ~= "" then
			local textColor = Utils.inlineIf(button.disabled, "Negative text", button.textColor)
			MGBA.drawText(x + width + 1, y - 2, button.text, Theme.COLORS[textColor], shadowcolor)
		end

		-- Draw a mark if the checkbox button is toggled on
		if button.toggleState ~= nil and button.toggleState then
			local toggleColor = Utils.inlineIf(button.disabled, "Negative text", button.toggleColor)
			gui.drawLine(x + 1, y + 1, x + width - 1, y + height - 1, Theme.COLORS[toggleColor])
			gui.drawLine(x + 1, y + height - 1, x + width - 1, y + 1, Theme.COLORS[toggleColor])
		end
	elseif button.type == Constants.ButtonTypes.COLORPICKER then
		if button.themeColor ~= nil then
			local hexCodeText = string.upper(string.sub(string.format("%#x", Theme.COLORS[button.themeColor]), 5))
			-- Draw a colored circle with a black border
			gui.drawEllipse(x - 1, y, width, height, 0xFF000000, Theme.COLORS[button.themeColor])
			-- Draw the hex code to the side, and the text label for it
			MGBA.drawText(x + width + 1, y - 2, hexCodeText, Theme.COLORS[button.textColor], shadowcolor)
			MGBA.drawText(x + width + 37, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.IMAGE then
		if button.image ~= nil then
			gui.drawImage(button.image, x, y)
		end
	elseif button.type == Constants.ButtonTypes.PIXELIMAGE then
		if button.image ~= nil then
			MGBA.drawImageAsPixels(button.image, x, y, { Theme.COLORS[button.textColor] }, shadowcolor)
		end
		if button.text ~= nil and button.text ~= "" then
			MGBA.drawText(x + width + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.POKEMON_ICON then
		local imagePath = button:getIconPath()
		if imagePath ~= nil then
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			gui.drawImage(imagePath, x, y + iconset.yOffset, width, height)
		end
	elseif button.type == Constants.ButtonTypes.STAT_STAGE then
		if button.text ~= nil and button.text ~= "" then
			if button.text == Constants.STAT_STATES[2].text then
				y = y - 1 -- Move up the negative stat mark 1px
			end
			MGBA.drawText(x, y - 1, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	end
end

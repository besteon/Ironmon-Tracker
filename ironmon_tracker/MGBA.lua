MGBA = {
	-- TextBuffer screens
	Screens = {
	},
}

function MGBA.initialize()
	-- Currently unused
	MGBA.debugMoveIds = { math.random(354), math.random(354), math.random(354), math.random(354), }
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
	local data = MGBA.buildPokemonDisplayObj(pokemon)
	MGBA.formatPokemonDisplayObj(data)

	-- %-#s means to left-align, padding out the right-part of the string with spaces
	local justify2, justify3
	if Options["Right justified numbers"] then
		justify2, justify3 = "%2s", "%3s"
	else
		justify2, justify3 = "%-2s", "%-3s"
	end

	local topheader = "%-20s %-5s" .. justify3
	local topbar = "%-20s %-5s" .. justify3
	local botheader = "%-17s %-2s  %-3s %-3s"
	local botbar = "%-17s " .. justify3 .. " " .. justify3 .. " " .. justify3
	local lines = {
		string.format(topheader, string.format("%-13s", data.p.name), "BST", data.p.bst),
		string.format("-------%-20s--", data.p.types):gsub(" ", "-"),
		string.format(topbar, string.format("HP: %s/%s   %s", data.p.curHP, data.p.maxHP, data.p.status), "HP", data.p.maxHP),
		string.format(topbar, string.format("Lv.%s (%s)", data.p.level, data.p.evo), "ATK", data.p.atk),
		string.format(topbar, string.format("%s", data.p.line1), "DEF", data.p.def),
		string.format(topbar, string.format("%s", data.p.line2), "SPA", data.p.spa),
		string.format(topbar, "", "SPD", data.p.spd),
		string.format(topbar, string.format("Heals: %.0f%% (%s)", data.x.healperc, data.x.healnum), "SPE", data.p.spe),
		"-----------------------------",
		string.format(botheader, data.m.nextmoves, "PP", "Pow", "Acc"),
	}
	for i, move in ipairs(data.m.moves) do
		-- Primary move data to display
		table.insert(lines, string.format(botbar, move.name, move.pp, move.power, move.accuracy))

		-- Extra move info, unsure if wanted, can't use colors or symbols
		-- table.insert(lines, string.format(" ┗%s %s %s", move.iscontact, move.type, move.category))
	end

	screen:clear()
	-- screen:moveCursor(0, 0) -- not sure when/how to use this yet
	for _, line in ipairs(lines) do
		screen:print(line)
		screen:print('\n')
	end
end

-- Returns a table with all of the important pokemon data safely formatted to display on screen
function MGBA.buildPokemonDisplayObj(pokemon)
	local data = {}
	data.p = {} -- data about the Pokemon itself
	data.m = {} -- data about the Moves of the Pokemon
	data.x = {} -- misc data to display, such as heals or encounters

	-- POKEMON ITSELF (data.p)
	local pokedexInfo = PokemonData.Pokemon[pokemon.pokemonID]
	local abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
	local movesLearnedHeader, _, _ = Utils.getMovesLearnedHeader(pokemon.pokemonID, pokemon.level)

	data.p.name = pokedexInfo.name or Constants.BLANKLINE
	data.p.status = MiscData.StatusCodeMap[pokemon.status] or ""
	data.p.types = pokedexInfo.types or { Constants.BLANKLINE, Constants.BLANKLINE }
	data.p.curHP = pokemon.curHP or Constants.BLANKLINE
	data.p.maxHP = pokemon.stats.hp or Constants.BLANKLINE
	data.p.level = pokemon.level or Constants.BLANKLINE
	data.p.evo = pokemon.evolution or Constants.BLANKLINE
	data.p.line1 = MiscData.Items[pokemon.heldItem] or Constants.BLANKLINE
	data.p.line2 = AbilityData.Abilities[abilityId].name

	data.p.atk = pokemon.stats.atk or Constants.BLANKLINE
	data.p.def = pokemon.stats.def or Constants.BLANKLINE
	data.p.spa = pokemon.stats.spa or Constants.BLANKLINE
	data.p.spd = pokemon.stats.spd or Constants.BLANKLINE
	data.p.spe = pokemon.stats.spe or Constants.BLANKLINE
	data.p.bst = pokedexInfo.bst or Constants.BLANKLINE

	-- MOVES OF POKEMON (data.m)
	data.m.nextmoves = movesLearnedHeader
	data.m.moves = { {}, {}, {}, {} }
	for i, move in ipairs(data.m.moves) do
		local moveInfo = MoveData.Moves[MGBA.debugMoveIds[i]]
		move.id = moveInfo.id or Constants.BLANKLINE
		move.name = moveInfo.name or Constants.BLANKLINE
		move.pp = moveInfo.pp or Constants.BLANKLINE
		move.power = moveInfo.power or Constants.BLANKLINE
		move.accuracy = moveInfo.accuracy or Constants.BLANKLINE
		move.type = moveInfo.type or PokemonData.Types.UNKNOWN
		move.category = moveInfo.category or MoveData.Categories.NONE
		move.iscontact = moveInfo.iscontact or false
	end

	-- MISC DATA (data.x)
	data.x.healperc = math.min(9999, Tracker.Data.healingItems.healing or 0)
	data.x.healnum = math.min(99, Tracker.Data.healingItems.numHeals or 0)

	return data
end

function MGBA.formatPokemonDisplayObj(data)
	data.p.name = data.p.name:upper()

	if data.p.status ~= "" then
		data.p.status = string.format("[%s]", data.p.status)
	end

	-- Format type as "Normal" or "Flying/Normal"
	if data.p.types[2] ~= data.p.types[1] and data.p.types[2] ~= nil then
		data.p.types = string.format("(%s/%s)", Utils.firstToUpper(data.p.types[1]), Utils.firstToUpper(data.p.types[2]))
	else
		data.p.types = Utils.firstToUpper(data.p.types[1] or Constants.BLANKLINE)
	end

	for i, move in ipairs(data.m.moves) do
		if move.pp == "0" then
			move.pp = Constants.BLANKLINE
		end
		if move.power == "0" then
			move.power = Constants.BLANKLINE
		end
		if move.accuracy == "0" then
			move.accuracy = Constants.BLANKLINE
		end
		move.type = Utils.firstToUpper(move.type)
		move.category = Utils.inlineIf(move.category == MoveData.Categories.STATUS, "", "(" .. move.category:sub(1, 1) .. ")") -- "(P)" or "(S)"
		move.iscontact = Utils.inlineIf(move.iscontact, "@", "")
	end
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

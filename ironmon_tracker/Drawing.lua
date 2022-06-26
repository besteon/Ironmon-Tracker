Drawing = {}

function Drawing.clearGUI()
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, 0xFF000000, 0xFF000000)
end

function Drawing.drawPokemonIcon(id, x, y)
	if id < 0 or id > 412 then
		id = 0
	end

	gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. id .. ".gif", x, y - 6, 32, 32)

	if PokemonData[id + 1].type[1] ~= "" then
		gui.drawImage(DATA_FOLDER .. "/images/types/" .. PokemonData[id + 1].type[1] .. ".png", x + 1, y + 28, 30, 12)
	end
	if PokemonData[id + 1].type[2] ~= "" then
		gui.drawImage(DATA_FOLDER .. "/images/types/" .. PokemonData[id + 1].type[2] .. ".png", x + 1, y + 40, 30, 12)
	end
end

--[[
Draws text for the tracker on screen with a shadow effect. Uses the Franklin Gothic Medium family with a 9 point size.

	x, y: integer -> pixel position for the text

	text: string -> the text to output to the screen

	color: string or integer -> the color for the text

	shadowcolor: string or integer -> the color for the shadow effect drawn behind the text

	style: string -> optional; can be regular, bold, italic, underline, or strikethrough
]]
function Drawing.drawText(x, y, text, color, shadowcolor, style)
	gui.drawText(x + 1, y + 1, text, shadowcolor, nil, 9, "Franklin Gothic Medium", style)
	gui.drawText(x, y, text, color, nil, 9, "Franklin Gothic Medium", style)
end

--[[
Function that will add a space to a number so that the all the hundreds, tens and ones units are aligned if used
with the RIGHT_JUSTIFIED_NUMBERS setting.

	x, y: integer -> pixel position for the text

	number: string | number -> number to draw (stats, move power, pp...)

	spacing: number -> the number of digits the number can hold max; e.g. use 3 for a number that can be up to 3 digits.
		Move power, accuracy, and stats should have a 3 for `spacing`.
		PP should have 2 for `spacing`.
]]
function Drawing.drawNumber(x, y, number, spacing, color, shadowcolor, style)
	local new_spacing = 0

	if Settings.tracker.RIGHT_JUSTIFIED_NUMBERS then
		new_spacing = (spacing - string.len(tostring(number))) * 5
	end

	Drawing.drawText(x + new_spacing, y, number, color, shadowcolor, style)
end

function Drawing.drawTriangleRight(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({ { 4 + x, 4 + y }, { 4 + x, y + size - 4 }, { x + size - 4, y + size / 2 } }, color, color)
end

function Drawing.drawTriangleLeft(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({ { x + size - 4, 4 + y }, { x + size - 4, y + size - 4 }, { 4 + x, y + size / 2 } }, color, color)
end

function Drawing.drawChevronUp(x, y, width, height, thickness, color)
	local i = 0
	y = y + height + thickness + 1
	while i < thickness do
		gui.drawLine(x, y - i, x + (width / 2), y - i - height, color)
		gui.drawLine(x + (width / 2), y - i - height, x + width, y - i, color)
		i = i + 1
	end
end

function Drawing.drawChevronDown(x, y, width, height, thickness, color)
	local i = 0
	y = y + thickness + 2
	while i < thickness do
		gui.drawLine(x, y + i, x + (width / 2), y + i + height, color)
		gui.drawLine(x + (width / 2), y + i + height, x + width, y + i, color)
		i = i + 1
	end
end

function Drawing.moveToColor(move)
	return GraphicConstants.TYPECOLORS[move["type"]]
end

function Drawing.getNatureColor(stat, nature)
	local color = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
	if not Settings.tracker.NATURE_WITH_FONT_STYLE then
		if nature % 6 == 0 then
			color = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
		elseif stat == "atk" then
			if nature < 5 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
			elseif nature % 5 == 0 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE
			end
		elseif stat == "def" then
			if nature > 4 and nature < 10 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
			elseif nature % 5 == 1 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE
			end
		elseif stat == "spe" then
			if nature > 9 and nature < 15 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
			elseif nature % 5 == 2 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE
			end
		elseif stat == "spa" then
			if nature > 14 and nature < 20 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
			elseif nature % 5 == 3 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE
			end
		elseif stat == "spd" then
			if nature > 19 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE
			elseif nature % 5 == 4 then
				color = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE
			end
		end
	end
	return color
end

function Drawing.getNatureStyle(monIsEnemy, stat, nature)
	local style = "regular"
	if Settings.tracker.NATURE_WITH_FONT_STYLE and not monIsEnemy then
		if nature % 6 == 0 then
			style = "regular"
		elseif stat == "atk" then
			if nature < 5 then
				style = "bold"
			elseif nature % 5 == 0 then
				style = "italic"
			end
		elseif stat == "def" then
			if nature > 4 and nature < 10 then
				style = "bold"
			elseif nature % 5 == 1 then
				style = "italic"
			end
		elseif stat == "spe" then
			if nature > 9 and nature < 15 then
				style = "bold"
			elseif nature % 5 == 2 then
				style = "italic"
			end
		elseif stat == "spa" then
			if nature > 14 and nature < 20 then
				style = "bold"
			elseif nature % 5 == 3 then
				style = "italic"
			end
		elseif stat == "spd" then
			if nature > 19 then
				style = "bold"
			elseif nature % 5 == 4 then
				style = "italic"
			end
		end
	end
	return style
end

function Drawing.drawStatusLevel(x, y, value)
	if value == 0 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
	elseif value == 1 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 2 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 3 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 4 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 7 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 8 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 9 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
	elseif value == 10 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
	elseif value == 11 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
	elseif value == 12 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
	end
end

function Drawing.drawMoveEffectiveness(x, y, value)
	if value == 2 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
	elseif value == 4 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE)
	elseif value == 0.5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
	elseif value == 0.25 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE)
	end
end

function Drawing.drawInputOverlay()
	if (Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames) and (Tracker.Data.selectedPlayer == 2) then
		local i = Tracker.controller.statIndex
		gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], GraphicConstants.LAYOUTCOLORS.INPUT_HIGHLIGHT, 0x000000)
	end
end

-- Returns a slightly darkened color
function Drawing.calcShadowColor(color)
	local color_hexval = (color - 0xFF000000)

	-- get the RGB values of the color 
	local r = bit.rshift(color_hexval, 16)
	local g = bit.rshift(bit.band(color_hexval, 0x00FF00), 8)
	local b = bit.band(color_hexval, 0x0000FF)

	-- scale RGB values down to make them darker
	local scale = 0x10 -- read as: 6.25%
	r = r - r * scale / 0x100
	g = g - g * scale / 0x100
	b = b - b * scale / 0x100

	-- build color with new hex values
	color_hexval = bit.lshift(r, 16) + bit.lshift(g, 8) + b 
	return (0xFF000000 + color_hexval)
end

function Drawing.DrawTracker(monToDraw, monIsEnemy, targetMon)
	-- Fill background and margins
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR)

	local borderMargin = 5
	local statBoxWidth = 101
	local statBoxHeight = 52

	-- Draw top box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, statBoxWidth - borderMargin, statBoxHeight, GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL)

	Drawing.drawPokemonIcon(monToDraw["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)

	local colorbar = GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT
	if monToDraw["curHP"] / monToDraw["maxHP"] <= 0.2 then
		colorbar = GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE
	elseif monToDraw["curHP"] / monToDraw["maxHP"] <= 0.5 then
		-- was "yellow" but that may be colorblind unsafe, might need to create a new layoutcolor option
		colorbar = GraphicConstants.LAYOUTCOLORS.TEXT_MIDDLE_VALUE
	end

	-- calculate shadows based on the location of the text (top or bot box)
	local bgHeaderShadow = Drawing.calcShadowColor(GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR)
	local boxTopShadow = Drawing.calcShadowColor(GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL)
	local boxBotShadow = Drawing.calcShadowColor(GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL)

	local currentHP = Utils.inlineIf(monIsEnemy, "?", monToDraw["curHP"])
	local maxHP = Utils.inlineIf(monIsEnemy, "?", monToDraw["maxHP"])

	local pkmnStatOffsetX = 36
	local pkmnStatStartY = 5
	local pkmnStatOffsetY = 10
	-- Base Pokémon details
	-- Pokémon name
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY, PokemonData[monToDraw["pokemonID"] + 1].name, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
	-- Settings gear
	gui.drawImage(DATA_FOLDER .. "/images/icons/gear.png", GraphicConstants.SCREEN_WIDTH + statBoxWidth - 8, 7)
	-- HP
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 1), "HP:", GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 52, pkmnStatStartY + (pkmnStatOffsetY * 1), currentHP .. "/" .. maxHP, colorbar, boxTopShadow)
	-- Level and evolution
	local levelDetails = "Lv." .. monToDraw.level
	local evolutionDetails = " (" .. PokemonData[monToDraw["pokemonID"] + 1].evolution .. ")"
	if Tracker.Data.selectedPokemon.friendship >= 220 and PokemonData[monToDraw["pokemonID"] + 1].evolution == EvolutionTypes.FRIEND then
		-- Let the player know that evolution is right around the corner!
		evolutionDetails = " (SOON)"
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 2), levelDetails .. evolutionDetails, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)

	-- draw heal-info box
	local infoBoxHeight = 23
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin + statBoxHeight, statBoxWidth - borderMargin, infoBoxHeight, GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL)

	-- Heals in bag/PokéCenter heals
	if monIsEnemy == false then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Heals in Bag:", GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, string.format("%.0f%%", Tracker.Data.healingItems.healing) .. " HP (" .. Tracker.Data.healingItems.numHeals .. ")", GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
		
		if (Settings.tracker.SURVIVAL_RULESET) then
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 57, "PC Heals:", GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
			-- Right-align the PC Heals number
			local healNumberSpacing = (2 - string.len(tostring(Tracker.Data.centerHeals))) * 5 + 75
			local healNumberColor = Utils.inlineIf(Tracker.Data.centerHeals < 5, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE, Utils.inlineIf(Tracker.Data.centerHeals < 10, GraphicConstants.LAYOUTCOLORS.TEXT_MIDDLE_VALUE, GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE))
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + healNumberSpacing, 67, Tracker.Data.centerHeals, healNumberColor, boxTopShadow)
			
			-- Draw the '+'', '-'', and toggle buttons for PC heal tracking
			Drawing.drawText(Buttons[9].box[1], Buttons[9].box[2] + (Buttons[9].box[4] - 12) / 2 + 1, Buttons[9].text, Buttons[9].textcolor, boxTopShadow)
			Drawing.drawText(Buttons[10].box[1], Buttons[10].box[2] + (Buttons[10].box[4] - 12) / 2 + 1, Buttons[10].text, Buttons[10].textcolor, boxTopShadow)
			gui.drawRectangle(PCHealTrackingButton.box[1], PCHealTrackingButton.box[2], PCHealTrackingButton.box[3], PCHealTrackingButton.box[4], PCHealTrackingButton.backgroundcolor[1], PCHealTrackingButton.backgroundcolor[2])
			-- Draw a mark if the feature is on
			if Program.PCHealTrackingButtonState then
				gui.drawLine(PCHealTrackingButton.box[1], PCHealTrackingButton.box[2], PCHealTrackingButton.box[1] + PCHealTrackingButton.box[3], PCHealTrackingButton.box[2] + PCHealTrackingButton.box[4], PCHealTrackingButton.togglecolor)
				gui.drawLine(PCHealTrackingButton.box[1], PCHealTrackingButton.box[2] + PCHealTrackingButton.box[4], PCHealTrackingButton.box[1] + PCHealTrackingButton.box[3], PCHealTrackingButton.box[2], PCHealTrackingButton.togglecolor)
			end
		end
	end

	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 35, 67, "4", GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
	-- local statusItems = Program.getBagStatusItems()
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 57, statusItems.poison, 0xFFFF00FF, boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 57, statusItems.burn, 0xFFFF0000, boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 57, statusItems.freeze, 0xFF0000FF, boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 67, statusItems.sleep, "white", boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 67, statusItems.paralyze, "yellow", boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 67, statusItems.all, 0xFFFF00FF, boxTopShadow)

	local abilityString = Utils.inlineIf(monIsEnemy, "---", MiscData.ability[monToDraw["ability"] + 1])
	if monIsEnemy then
		for k, v in pairs(Tracker.Data.selectedPokemon.abilities) do
			if v == monToDraw["ability"] then
				local abilityId = monToDraw["ability"] + 1
				abilityString = MiscData.ability[abilityId]
			end
		end
	end

	-- Held item & ability
	if monIsEnemy == false then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 3), MiscData.item[monToDraw["heldItem"] + 1], GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), abilityString, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
	end

	local statBoxY = 5
	local statOffsetX = statBoxWidth + 1
	local statValueOffsetX = statBoxWidth + 26
	local statInc = 10
	local statusLevelOffset = 5
	local hpY = 7
	local attY = hpY + statInc
	local defY = attY + statInc
	local spaY = defY + statInc
	local spdY = spaY + statInc
	local speY = spdY + statInc
	local bstY = speY + statInc

	-- draw stat box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxWidth, statBoxY, GraphicConstants.RIGHT_GAP - statBoxWidth - borderMargin, 75, GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, hpY, " HP", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, Drawing.getNatureColor("hp", monToDraw["nature"])), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "hp", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATK", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, Drawing.getNatureColor("atk", monToDraw["nature"])), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "atk", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, Drawing.getNatureColor("def", monToDraw["nature"])), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "def", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, Drawing.getNatureColor("spa", monToDraw["nature"])), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "spa", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, Drawing.getNatureColor("spd", monToDraw["nature"])), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "spd", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, Drawing.getNatureColor("spe", monToDraw["nature"])), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "spe", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST", GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData[monToDraw["pokemonID"] + 1].bst, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxTopShadow)

	-- draw Pokemon's statis but only if it's yours
	if monIsEnemy == false then
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, hpY, monToDraw["maxHP"], 3, Drawing.getNatureColor("hp", monToDraw["nature"]), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "hp", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, attY, monToDraw["atk"], 3, Drawing.getNatureColor("atk", monToDraw["nature"]), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "atk", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, defY, monToDraw["def"], 3, Drawing.getNatureColor("def", monToDraw["nature"]), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "def", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spaY, monToDraw["spa"], 3, Drawing.getNatureColor("spa", monToDraw["nature"]), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "spa", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spdY, monToDraw["spd"], 3, Drawing.getNatureColor("spd", monToDraw["nature"]), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "spd", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, speY, monToDraw["spe"], 3, Drawing.getNatureColor("spe", monToDraw["nature"]), boxTopShadow, Drawing.getNatureStyle(monIsEnemy, "spe", monToDraw.nature))
	else -- otherwise draw stat info buttons
		for i = 1, 6, 1 do
			if Buttons[i].visible() and Buttons[i].type == ButtonType.singleButton then -- HP stat
				gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], Buttons[i].backgroundcolor[1], Buttons[i].backgroundcolor[2])
				Drawing.drawText(Buttons[i].box[1], Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + Utils.inlineIf(Buttons[i].text == "--", 0, 1), Buttons[i].text, Buttons[i].textcolor, boxTopShadow)
			end
		end
	end

	-- Stat stages -6 -> +6
	if Tracker.Data.inBattle == 1 then
		Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, hpY, monToDraw.statStages["HP"])
		Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, attY, monToDraw.statStages["ATK"])
		Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, defY, monToDraw.statStages["DEF"])
		Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, spaY, monToDraw.statStages["SPATK"])
		Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, spdY, monToDraw.statStages["SPDEF"])
		Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, speY, monToDraw.statStages["SPEED"])
	end

	-- Drawing moves
	local movesBoxStartY = 94
	-- draw moves box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY, GraphicConstants.RIGHT_GAP - (2 * borderMargin), 46, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL)
	local moveStartY = movesBoxStartY + 3

	local monLevel = monToDraw["level"]
	local monData = PokemonData[monToDraw["pokemonID"] + 1]
	local moveLevels = monData.movelvls[GameSettings.versiongroup]

	-- Determine if the opponent Pokémon's moves are old and mark with a star
	local movesLearnedSinceFirst = 0
	local movesLearnedSinceSecond = 0
	local movesLearnedSinceThird = 0
	local movesLearnedSinceFourth = 0

	for k, v in pairs(moveLevels) do
		if v > Tracker.Data.selectedPokemon.moves.first.level and v <= monLevel then
			movesLearnedSinceFirst = movesLearnedSinceFirst + 1
		end
		if v > Tracker.Data.selectedPokemon.moves.second.level and v <= monLevel then
			movesLearnedSinceSecond = movesLearnedSinceSecond + 1
		end
		if v > Tracker.Data.selectedPokemon.moves.third.level and v <= monLevel then
			movesLearnedSinceThird = movesLearnedSinceThird + 1
		end
		if v > Tracker.Data.selectedPokemon.moves.fourth.level and v <= monLevel then
			movesLearnedSinceFourth = movesLearnedSinceFourth + 1
		end
	end

	local moveAgeRank = {
		first = 1,
		second = 1,
		third = 1,
		fourth = 1
	}
	for k, v in pairs(Tracker.Data.selectedPokemon.moves) do
		for k2, v2 in pairs(Tracker.Data.selectedPokemon.moves) do
			if k ~= k2 then
				if v.level > v2.level then
					moveAgeRank[k] = moveAgeRank[k] + 1
				end
			end
		end
	end

	local stars = {
		(monIsEnemy == true and Tracker.Data.selectedPokemon.moves.first.level ~= 1 and movesLearnedSinceFirst >= moveAgeRank.first) and "*" or "",
		(monIsEnemy == true and Tracker.Data.selectedPokemon.moves.second.level ~= 1 and movesLearnedSinceSecond >= moveAgeRank.second) and "*" or "",
		(monIsEnemy == true and Tracker.Data.selectedPokemon.moves.third.level ~= 1 and movesLearnedSinceThird >= moveAgeRank.third) and "*" or "",
		(monIsEnemy == true and Tracker.Data.selectedPokemon.moves.fourth.level ~= 1 and movesLearnedSinceFourth >= moveAgeRank.fourth) and "*" or "",
	}

	-- Determine which moves to show based on if the tracker is showing the enemy Pokémon or the player's.
	local moves = {
		Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.first.move], MoveData[monToDraw["move1"] + 1]),
		Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.second.move], MoveData[monToDraw["move2"] + 1]),
		Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.third.move], MoveData[monToDraw["move3"] + 1]),
		Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.fourth.move], MoveData[monToDraw["move4"] + 1]),
	}

	local distanceBetweenMoves = 10

	local movelevellist = PokemonData[monToDraw["pokemonID"] + 1].movelvls -- pokemonID
	local moveCount = 0
	local movesLearned = 0
	local nextMove = 0
	local foundNextMove = false

	for k, v in pairs(movelevellist[GameSettings.versiongroup]) do -- game
		moveCount = moveCount + 1
		if v <= monToDraw["level"] then
			movesLearned = movesLearned + 1
		else
			if foundNextMove == false then
				nextMove = v
				foundNextMove = true
			end
		end
	end

	local moveTableHeaderHeightDiff = 15

	local movesString = "Move ~  "
	movesString = movesString .. movesLearned .. "/" .. moveCount
	if nextMove ~= 0 then
		movesString = movesString .. " (" .. nextMove .. ")"
	end

	-- Draw moves
	local moveColors = {}
	for moveIndex = 1, 4, 1 do
		table.insert(moveColors, Drawing.moveToColor(moves[moveIndex]))
	end

	local stabColors = {}
	for moveIndex = 1, 4, 1 do
		table.insert(stabColors, Utils.inlineIf(Utils.isSTAB(moves[moveIndex], PokemonData[monToDraw["pokemonID"] + 1]) and Tracker.Data.inBattle == 1 and moves[moveIndex].power ~= NOPOWER, GraphicConstants.LAYOUTCOLORS.TEXT_POSITIVE, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT))
	end

	-- Move category: physical, special, or status effect
	local moveOffset = 7
	local physicalCatLocation = DATA_FOLDER .. "/images/icons/physical.png"
	local specialCatLocation = DATA_FOLDER .. "/images/icons/special.png"
	local isStatusMove = {}
	for moveIndex = 1, 4, 1 do
		table.insert(isStatusMove, Utils.inlineIf(moves[moveIndex].category == MoveCategories.PHYSICAL or moves[moveIndex].category == MoveCategories.SPECIAL, false, true))
	end
	local categories = {}
	for moveIndex = 1, 4, 1 do
		local currentHiddenPowerCat = MoveTypeCategories[Tracker.Data.currentHiddenPowerType]
		local category = Utils.inlineIf(moves[moveIndex].name == "Hidden Power", currentHiddenPowerCat, moves[moveIndex].category)
		table.insert(categories, Utils.inlineIf(category == MoveCategories.PHYSICAL, physicalCatLocation, Utils.inlineIf(category == MoveCategories.SPECIAL, specialCatLocation, "")))
	end
	if Settings.tracker.SHOW_MOVE_CATEGORIES then
		for catIndex = 0, 3, 1 do
			if not isStatusMove[catIndex + 1] then
				gui.drawImage(categories[catIndex + 1], GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + 2 + (distanceBetweenMoves * catIndex))
			end
		end
	end

	-- Move names (longest name is 12 characters?)
	local nameOffset = Utils.inlineIf(Settings.tracker.SHOW_MOVE_CATEGORIES, 14, moveOffset - 1)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset - 2, moveStartY - moveTableHeaderHeightDiff, movesString, GraphicConstants.LAYOUTCOLORS.TEXT_HEADER, bgHeaderShadow)
	for moveIndex = 1, 4, 1 do
		if moves[moveIndex].name == "Hidden Power" and not monIsEnemy then
			HiddenPowerButton.box[1] = GraphicConstants.SCREEN_WIDTH + nameOffset
			HiddenPowerButton.box[2] = moveStartY + (distanceBetweenMoves * (moveIndex - 1))
			Drawing.drawText(HiddenPowerButton.box[1], HiddenPowerButton.box[2] + (HiddenPowerButton.box[4] - 12) / 2 + 1, HiddenPowerButton.text, Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, HiddenPowerButton.textcolor, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT), boxBotShadow)
		else
			-- TODO: put the move colors back DONE??)
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + nameOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].name .. stars[moveIndex], Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, moveColors[moveIndex], GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT), boxBotShadow)
			-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + nameOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].name .. stars[moveIndex], moveColors[moveIndex], boxBotShadow)
		end
	end

	-- Move power points
	local ppOffset = 82
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY - moveTableHeaderHeightDiff, "PP", GraphicConstants.LAYOUTCOLORS.TEXT_HEADER, bgHeaderShadow)
	for moveIndex = 1, 4, 1 do
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), Utils.inlineIf(monIsEnemy or moves[moveIndex].pp == NOPP, moves[moveIndex].pp, Utils.getbits(monToDraw.pp, (moveIndex - 1) * 8, 8)), 2, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxBotShadow)
	end

	-- Move attack power
	local powerOffset = 102
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY - moveTableHeaderHeightDiff, "Pow", GraphicConstants.LAYOUTCOLORS.TEXT_HEADER, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR)
	for moveIndex = 1, 4, 1 do
		local movePower = moves[moveIndex].power
		if Settings.tracker.CALCULATE_VARIABLE_DAMAGE == true then
			local newPower = movePower
			if movePower == "WT" and Tracker.Data.inBattle == 1 then
				-- Calculate the power of weight moves in battle
				local targetWeight = PokemonData[targetMon["pokemonID"] + 1].weight
				newPower = Utils.calculateWeightBasedDamage(targetWeight)
			elseif movePower == "<HP" and not monIsEnemy then
				-- Calculate the power of flail & reversal moves for player only
				newPower = Utils.calculateLowHPBasedDamage(currentHP, maxHP)
			elseif movePower == ">HP" and not monIsEnemy then
				-- Calculate the power of water spout & eruption moves for the player only
				newPower = Utils.calculateHighHPBasedDamage(currentHP, maxHP)
			else
				newPower = movePower
			end
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), newPower, stabColors[moveIndex], boxBotShadow)
		else
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), movePower, stabColors[moveIndex], boxBotShadow)
		end
	end

	-- Move accuracy
	local accOffset = 126
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY - moveTableHeaderHeightDiff, "Acc", GraphicConstants.LAYOUTCOLORS.TEXT_HEADER, bgHeaderShadow)
	for moveIndex = 1, 4, 1 do
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].accuracy, 3, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxBotShadow)
	end

	-- Move effectiveness against the opponent
	if Settings.tracker.SHOW_MOVE_EFFECTIVENESS and Tracker.Data.inBattle == 1 then
		if targetMon ~= nil then
			for moveIndex = 1, 4, 1 do
				local effectiveness = Utils.netEffectiveness(moves[moveIndex], PokemonData[targetMon.pokemonID + 1])
				if effectiveness == 0 then
					Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), "X", GraphicConstants.LAYOUTCOLORS.TEXT_NEGATIVE, boxBotShadow)
				else
					Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), effectiveness)
				end
			end
		end
	end

	Drawing.drawInputOverlay()

	-- draw badge/note box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, 140, GraphicConstants.RIGHT_GAP - (2 * borderMargin), 14, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL)

	local note = Tracker.GetNote()
	if note == '' then
		gui.drawImage(DATA_FOLDER .. "/images/icons/editnote.png", GraphicConstants.SCREEN_WIDTH + borderMargin + 2, movesBoxStartY + 48, 11, 11)
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY + 47, note, GraphicConstants.LAYOUTCOLORS.TEXT_DEFAULT, boxBotShadow)
		--work around limitation of drawText not having width limit: paint over any spillover
		local x = GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 5
		local y = 141
		gui.drawLine(x, 141, x, y + 12, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER)
		gui.drawRectangle(x + 1, y, 12, 12, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR)
	end
end

function Drawing.drawSettingStateButton(index, state)
	-- for i = 1, table.getn(Buttons), 1 do
	-- 	if Buttons[i].visible() then
	-- 		if Buttons[i].type == ButtonType.singleButton then
	-- 			gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], Buttons[i].backgroundcolor[1], Buttons[i].backgroundcolor[2])
	-- 			local extraY = 1
	-- 			if Buttons[i].text == "--" then extraY = 0 end
	-- 			Drawing.drawText(Buttons[i].box[1], Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + extraY, Buttons[i].text, Buttons[i].textcolor)
	-- 		end
	-- 	end
	-- end
	-- gui.drawRectangle()
end

function Drawing.truncateRomsFolder(folder)
	if folder then
		if string.len(folder) > 10 then
			return "..." .. string.sub(folder, string.len(folder) - 10)
		else
			return folder
		end
	else
		return ""
	end
end

function Drawing.drawSettings()
	-- Fill background and margins
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR)

	local borderMargin = 5
	local rightEdge = GraphicConstants.RIGHT_GAP - (2 * borderMargin)
	local bottomEdge = GraphicConstants.SCREEN_HEIGHT - (2 * borderMargin)

	-- set the color for text/number shadows for the top boxes
	local boxSettingsShadow = Drawing.calcShadowColor(GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL)

	-- Settings view box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, rightEdge, bottomEdge, GraphicConstants.LAYOUTCOLORS.BOX_TOP_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_TOP_FILL)

	-- Cancel/close button
	gui.drawRectangle(Options.closeButton.box[1], Options.closeButton.box[2], Options.closeButton.box[3], Options.closeButton.box[4], Options.closeButton.backgroundColor[1], Options.closeButton.backgroundColor[2])
	Drawing.drawText(Options.closeButton.box[1] + 3, Options.closeButton.box[2], Options.closeButton.text, Options.closeButton.textColor, boxSettingsShadow)

	-- Roms folder setting
	local folder = Drawing.truncateRomsFolder(Settings.config.ROMS_FOLDER)
	Drawing.drawText(Options.romsFolderOption.box[1], Options.romsFolderOption.box[2], Options.romsFolderOption.text .. folder, Options.romsFolderOption.textColor, boxSettingsShadow)
	if folder == "" then
		gui.drawImage(DATA_FOLDER .. "/images/icons/editnote.png", GraphicConstants.SCREEN_WIDTH + 60, borderMargin + 2)
	end

	-- Customize button
	gui.drawRectangle(Options.themeButton.box[1], Options.themeButton.box[2], Options.themeButton.box[3], Options.themeButton.box[4], Options.themeButton.backgroundColor[1], Options.themeButton.backgroundColor[2])
	Drawing.drawText(Options.themeButton.box[1] + 3, Options.themeButton.box[2], Options.themeButton.text, Options.themeButton.textColor, boxSettingsShadow)

	-- Draw toggleable settings
	for _, button in pairs(Options.optionsButtons) do
		gui.drawRectangle(button.box[1], button.box[2], button.box[3], button.box[4], button.backgroundColor[1], button.backgroundColor[2])
		Drawing.drawText(button.box[1] + button.box[3] + 1, button.box[2] - 1, button.text, button.textColor, boxSettingsShadow)
		-- Draw a mark if the feature is on
		if button.optionState then
			gui.drawLine(button.box[1], button.box[2], button.box[1] + button.box[3], button.box[2] + button.box[4], button.optionColor)
			gui.drawLine(button.box[1], button.box[2] + button.box[4], button.box[1] + button.box[3], button.box[2], button.optionColor)
		end
	end
end

function Drawing.drawThemeMenu()
	-- Fill background and margins
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR, GraphicConstants.LAYOUTCOLORS.BACKGROUND_COLOR)
	
	local borderMargin = 5
	local rightEdge = GraphicConstants.RIGHT_GAP - (2 * borderMargin)
	local bottomEdge = GraphicConstants.SCREEN_HEIGHT - (2 * borderMargin)

	-- set the color for text/number shadows for the bottom box values
	local boxThemeShadow = Drawing.calcShadowColor(GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL)

	-- Draw Theme menu view box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, rightEdge, bottomEdge, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_BORDER, GraphicConstants.LAYOUTCOLORS.BOX_BOTTOM_FILL)

	-- Draw Import, Export, Presets buttons
	gui.drawRectangle(Theme.importThemeButton.box[1], Theme.importThemeButton.box[2], Theme.importThemeButton.box[3], Theme.importThemeButton.box[4], Theme.importThemeButton.backgroundColor[1], Theme.importThemeButton.backgroundColor[2])
	Drawing.drawText(Theme.importThemeButton.box[1] + 3, Theme.importThemeButton.box[2], Theme.importThemeButton.text, Theme.importThemeButton.textColor, boxThemeShadow)
	gui.drawRectangle(Theme.exportThemeButton.box[1], Theme.exportThemeButton.box[2], Theme.exportThemeButton.box[3], Theme.exportThemeButton.box[4], Theme.exportThemeButton.backgroundColor[1], Theme.exportThemeButton.backgroundColor[2])
	Drawing.drawText(Theme.exportThemeButton.box[1] + 3, Theme.exportThemeButton.box[2], Theme.exportThemeButton.text, Theme.exportThemeButton.textColor, boxThemeShadow)
	gui.drawRectangle(Theme.presetsButton.box[1], Theme.presetsButton.box[2], Theme.presetsButton.box[3], Theme.presetsButton.box[4], Theme.presetsButton.backgroundColor[1], Theme.presetsButton.backgroundColor[2])
	Drawing.drawText(Theme.presetsButton.box[1] + 3, Theme.presetsButton.box[2], Theme.presetsButton.text, Theme.presetsButton.textColor, boxThemeShadow)

	-- Draw each theme element and its color picker
	for _, button in pairs(Theme.themeButtons) do
		if button.themeColor ~= nil then
			-- fill in the box with the current defined color
			gui.drawEllipse(button.box[1], button.box[2], button.box[3], button.box[4], 0xFF000000, button.themeColor) -- black border
			-- Draw the hex code to the side 
			Drawing.drawText(button.box[1] + button.box[3] + 1, button.box[2] - 2, string.upper(string.sub(string.format("%#x", button.themeColor), 5)), button.textColor, boxThemeShadow)
			Drawing.drawText(button.box[1] + button.box[3] + 1 + 35, button.box[2] - 2, "~   " .. button.text, button.textColor, boxThemeShadow)
		else
			gui.drawRectangle(button.box[1], button.box[2], button.box[3], button.box[4], button.backgroundColor[1], button.backgroundColor[2])
			-- Draw a mark if the feature is on
			if GraphicConstants[button.themeKey] then
				gui.drawLine(button.box[1], button.box[2], button.box[1] + button.box[3], button.box[2] + button.box[4], button.optionColor)
				gui.drawLine(button.box[1], button.box[2] + button.box[4], button.box[1] + button.box[3], button.box[2], button.optionColor)
			end
			Drawing.drawText(button.box[1] + button.box[3] + 1, button.box[2] - 2, button.text, button.textColor, boxThemeShadow)
		end
	end

	-- Draw Restore Defaults button
	gui.drawRectangle(Theme.restoreDefaultsButton.box[1], Theme.restoreDefaultsButton.box[2], Theme.restoreDefaultsButton.box[3], Theme.restoreDefaultsButton.box[4], Theme.restoreDefaultsButton.backgroundColor[1], Theme.restoreDefaultsButton.backgroundColor[2])
	Drawing.drawText(Theme.restoreDefaultsButton.box[1] + 3, Theme.restoreDefaultsButton.box[2], Theme.restoreDefaultsButton.text, Theme.restoreDefaultsButton.textColor, boxThemeShadow)
	
	-- Draw Close button
	gui.drawRectangle(Theme.closeButton.box[1], Theme.closeButton.box[2], Theme.closeButton.box[3], Theme.closeButton.box[4], Theme.closeButton.backgroundColor[1], Theme.closeButton.backgroundColor[2])
	Drawing.drawText(Theme.closeButton.box[1] + 3, Theme.closeButton.box[2], Theme.closeButton.text, Theme.closeButton.textColor, boxThemeShadow)
	
end
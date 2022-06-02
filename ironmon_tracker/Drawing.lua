Drawing = {}






local function calculate_opponent_attack(damage, crit)
    -- The idea behind this function is to automate the mathematics that
    -- you can do in theory with all the infos provided. The pokemon games's damage formula
    -- has been cracked down and you can find it on the web. This suggestion will display the range of
    -- possible stats.
    
    -- The intended use:
        --> Somewhere in the main loop which I have no clue how to implement, check if attacked and HP changed.
        --> If HP changed, call this function and display the result (Currently in the plain middle of the game screen.)
        --> Perhaps add an option to choose from the boxes notes or automated calculation? Or add a small section somewhere?

    -- Arguments:
        --damage (int)
        -- crit (bool) (NOT IMPLEMENTED YET)
    --Returns : Both extreme possibles of the the stats.


    -- Section where we should be Fetching data from game data.

        -- Since this is a proof of concept, I fixed the datas from 
        -- https://aminoapps.com/c/nintendo_gen7/page/blog/pokemon-damage-formula-part-2/wK7D_bdWfoup5WBvzB7qg4WR7Ve3nWE1EblCw
    
    -- Mismagius
        -- Has 303 special defense
        -- Gets attacked by a water gun  (move power = 40) from a wailmer lvl 100
            -- STAB boost!
        -- Recieves 29 damage (loses 29 HP)
        
    --With these infos, we can calculate the RANGE of special attack possibles.
            
    local level --level : Level of the opponent Monster.
    level = 100

    local defense -- defense : Defense of the attacked pokemon.
    defense = 303

    local move_power  -- Move's Power.
    move_power = 40

    local STAB  -- STAB
    STAB = 1.5  -- Wailmer used the move.

    local resistance --Resistance or weaknesses multiplier
        -- Should be 0.25, 0.5, 1, 2 or 4.
    resistance = 1

    -- Could reduce amount of variables... Or perhaps use a loop? Lua is not my forte, so...:
    -- For x in [0.85, 1] do ...
    local level_modifier = (2*level + 10) / 250

    local min_atk = (damage / STAB * resistance * 0.85 - 2) / move_power / level_modifier * defense
    local max_atk = (damage / STAB * resistance * 1 - 2) / move_power / level_modifier * defense
    return {math.floor(min_atk), math.floor(max_atk)}
end









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

	color: string or integer -> the color for the text; the shadow effect will be black

	style: string -> optional; can be regular, bold, italic, underline, or strikethrough
]]
function Drawing.drawText(x, y, text, color, style)
	gui.drawText(x + 1, y + 1, text, "black", nil, 9, "Franklin Gothic Medium", style)
	gui.drawText(x, y, text, color, nil, 9, "Franklin Gothic Medium", style)
end

--[[
Function that will add a space to a number so that the all the hundreds, tens and ones units are aligned if used
with the JUSTIFIED_NUMBERS setting.

	x, y: integer -> pixel position for the text

	number: string | number -> number to draw (stats, move power, pp...)

	spacing: number -> the number of digits the number can hold max; e.g. use 3 for a number that can be up to 3 digits.
		Move power, accuracy, and stats should have a 3 for `spacing`.
		PP should have 2 for `spacing`.
]]
function Drawing.drawNumber(x, y, number, spacing, color, style)
	local new_spacing
	new_spacing = 0

	if Settings.tracker.JUSTIFIED_NUMBERS then
		new_spacing = (spacing - string.len(tostring(number))) * 5
	end

	gui.drawText(x + 1 + new_spacing, y + 1, number, "black", nil, 9, "Franklin Gothic Medium", style)
	gui.drawText(x + new_spacing, y, number, color, nil, 9, "Franklin Gothic Medium", style)
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
	local color = GraphicConstants.LAYOUTCOLORS.NEUTRAL
	if not Settings.tracker.NATURE_WITH_FONT_STYLE then
		if nature % 6 == 0 then
			color = GraphicConstants.LAYOUTCOLORS.NEUTRAL
		elseif stat == "atk" then
			if nature < 5 then
				color = GraphicConstants.LAYOUTCOLORS.INCREASE
			elseif nature % 5 == 0 then
				color = GraphicConstants.LAYOUTCOLORS.DECREASE
			end
		elseif stat == "def" then
			if nature > 4 and nature < 10 then
				color = GraphicConstants.LAYOUTCOLORS.INCREASE
			elseif nature % 5 == 1 then
				color = GraphicConstants.LAYOUTCOLORS.DECREASE
			end
		elseif stat == "spe" then
			if nature > 9 and nature < 15 then
				color = GraphicConstants.LAYOUTCOLORS.INCREASE
			elseif nature % 5 == 2 then
				color = GraphicConstants.LAYOUTCOLORS.DECREASE
			end
		elseif stat == "spa" then
			if nature > 14 and nature < 20 then
				color = GraphicConstants.LAYOUTCOLORS.INCREASE
			elseif nature % 5 == 3 then
				color = GraphicConstants.LAYOUTCOLORS.DECREASE
			end
		elseif stat == "spd" then
			if nature > 19 then
				color = GraphicConstants.LAYOUTCOLORS.INCREASE
			elseif nature % 5 == 4 then
				color = GraphicConstants.LAYOUTCOLORS.DECREASE
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
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
	elseif value == 1 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 2 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 3 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 4 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 7 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 8 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 9 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	elseif value == 10 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
	elseif value == 11 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
	elseif value == 12 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
	end
end

function Drawing.drawMoveEffectiveness(x, y, value)
	if value == 2 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
	elseif value == 4 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.INCREASE)
	elseif value == 0.5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
	elseif value == 0.25 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.LAYOUTCOLORS.DECREASE)
	elseif value == 0 then
		Drawing.drawText(x, y, "X", GraphicConstants.LAYOUTCOLORS.DECREASE)
	end
end

function Drawing.drawButtons()
	---@diagnostic disable-next-line: deprecated
	for i = 1, table.getn(Buttons), 1 do
		if Buttons[i].visible() then
			if Buttons[i].type == ButtonType.singleButton then
				gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], Buttons[i].backgroundcolor[1], Buttons[i].backgroundcolor[2])
				local extraY = 1
				if Buttons[i].text == "--" then extraY = 0 end
				Drawing.drawText(Buttons[i].box[1], Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + extraY, Buttons[i].text, Buttons[i].textcolor)
			end
		end
	end
end

function Drawing.drawInputOverlay()
	if (Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames) and (Tracker.Data.selectedPlayer == 2) then
		gui.drawRectangle(Buttons[Tracker.controller.statIndex].box[1], Buttons[Tracker.controller.statIndex].box[2], Buttons[Tracker.controller.statIndex].box[3], Buttons[Tracker.controller.statIndex].box[4], "yellow", 0x000000)
	end
end

function Drawing.DrawTracker(monToDraw, monIsEnemy, targetMon)
	local borderMargin = 5
	local statBoxWidth = 101
	local statBoxHeight = 52

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, statBoxWidth - borderMargin, statBoxHeight, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)

	Drawing.drawPokemonIcon(monToDraw["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)

	local colorbar = GraphicConstants.LAYOUTCOLORS.NEUTRAL
	if monToDraw["curHP"] / monToDraw["maxHP"] <= 0.2 then
		colorbar = GraphicConstants.LAYOUTCOLORS.DECREASE
	elseif monToDraw["curHP"] / monToDraw["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end


	local currentHP = Utils.inlineIf(monIsEnemy, "?", monToDraw["curHP"])
	local maxHP = Utils.inlineIf(monIsEnemy, "?", monToDraw["maxHP"])

	local pkmnStatOffsetX = 36
	local pkmnStatStartY = 5
	local pkmnStatOffsetY = 10
	-- Base Pokémon details
	-- Pokémon name
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY, PokemonData[monToDraw["pokemonID"] + 1].name)
	-- HP
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 1), "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 52, pkmnStatStartY + (pkmnStatOffsetY * 1), currentHP .. "/" .. maxHP, colorbar)
	-- Level and evolution
	local levelDetails = "Lv." .. monToDraw.level
	local evolutionDetails = " (" .. PokemonData[monToDraw["pokemonID"] + 1].evolution .. ")"
	if Tracker.Data.selectedPokemon.friendship >= 220 and PokemonData[monToDraw["pokemonID"] + 1].evolution == EvolutionTypes.FRIEND then
		-- Let the player know that evolution is right around the corner!
		evolutionDetails = " (SOON)"
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 2), levelDetails .. evolutionDetails)

	local infoBoxHeight = 23
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin + statBoxHeight, statBoxWidth - borderMargin, infoBoxHeight, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)

	if monIsEnemy == false then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Heals in Bag:", GraphicConstants.LAYOUTCOLORS.INCREASE)
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, string.format("%.0f%%", Tracker.Data.healingItems.healing) .. " HP (" .. Tracker.Data.healingItems.numHeals .. ")", GraphicConstants.LAYOUTCOLORS.INCREASE)
	end

	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 35, 67, "4", GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	-- local statusItems = Program.getBagStatusItems()
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 57, statusItems.poison, 0xFFFF00FF)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 57, statusItems.burn, 0xFFFF0000)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 57, statusItems.freeze, 0xFF0000FF)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 67, statusItems.sleep, "white")
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 67, statusItems.paralyze, "yellow")
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 67, statusItems.all, 0xFFFF00FF)

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
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 3), MiscData.item[monToDraw["heldItem"] + 1], GraphicConstants.LAYOUTCOLORS.HIGHLIGHT)
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), abilityString, GraphicConstants.LAYOUTCOLORS.HIGHLIGHT)
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
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxWidth, statBoxY, GraphicConstants.RIGHT_GAP - statBoxWidth - borderMargin, 75, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, hpY, " HP", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("hp", monToDraw["nature"])), Drawing.getNatureStyle(monIsEnemy, "hp", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATK", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("atk", monToDraw["nature"])), Drawing.getNatureStyle(monIsEnemy, "atk", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("def", monToDraw["nature"])), Drawing.getNatureStyle(monIsEnemy, "def", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("spa", monToDraw["nature"])), Drawing.getNatureStyle(monIsEnemy, "spa", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("spd", monToDraw["nature"])), Drawing.getNatureStyle(monIsEnemy, "spd", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("spe", monToDraw["nature"])), Drawing.getNatureStyle(monIsEnemy, "spe", monToDraw.nature))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST", GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData[monToDraw["pokemonID"] + 1].bst, GraphicConstants.LAYOUTCOLORS.NEUTRAL)

	if monIsEnemy == false then
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, hpY, monToDraw["maxHP"], 3, Drawing.getNatureColor("hp", monToDraw["nature"]), Drawing.getNatureStyle(monIsEnemy, "hp", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, attY, monToDraw["atk"], 3, Drawing.getNatureColor("atk", monToDraw["nature"]), Drawing.getNatureStyle(monIsEnemy, "atk", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, defY, monToDraw["def"], 3, Drawing.getNatureColor("def", monToDraw["nature"]), Drawing.getNatureStyle(monIsEnemy, "def", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spaY, monToDraw["spa"], 3, Drawing.getNatureColor("spa", monToDraw["nature"]), Drawing.getNatureStyle(monIsEnemy, "spa", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spdY, monToDraw["spd"], 3, Drawing.getNatureColor("spd", monToDraw["nature"]), Drawing.getNatureStyle(monIsEnemy, "spd", monToDraw.nature))
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, speY, monToDraw["spe"], 3, Drawing.getNatureColor("spe", monToDraw["nature"]), Drawing.getNatureStyle(monIsEnemy, "spe", monToDraw.nature))
	end
    for k, v in pairs(calculate_opponent_attack(100, false)) do
        Drawing.drawNumber(30,30 + 10 * k,v, 10)
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

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY, GraphicConstants.RIGHT_GAP - (2 * borderMargin), 46, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)
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

	-- Moves Learned
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, 140, GraphicConstants.RIGHT_GAP - (2 * borderMargin), 14, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)
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

	local moveTableHeaderHeightDiff = 14

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
		table.insert(stabColors, Utils.inlineIf(Utils.isSTAB(moves[moveIndex], PokemonData[monToDraw["pokemonID"] + 1]) and Tracker.Data.inBattle == 1 and moves[moveIndex].power ~= NOPOWER, GraphicConstants.LAYOUTCOLORS.INCREASE, GraphicConstants.LAYOUTCOLORS.NEUTRAL))
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
		table.insert(categories, Utils.inlineIf(moves[moveIndex].category == MoveCategories.PHYSICAL, physicalCatLocation, Utils.inlineIf(moves[moveIndex].category == MoveCategories.SPECIAL, specialCatLocation, "")))
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset - 2, moveStartY - moveTableHeaderHeightDiff, movesString)
	for moveIndex = 1, 4, 1 do
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + nameOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].name .. stars[moveIndex], moveColors[moveIndex])
	end

	-- Move power points
	local ppOffset = 82
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY - moveTableHeaderHeightDiff, "PP")
	for moveIndex = 1, 4, 1 do
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), Utils.inlineIf(monIsEnemy or moves[moveIndex].pp == NOPP, moves[moveIndex].pp, Utils.getbits(monToDraw.pp, (moveIndex - 1) * 8, 8)), 2)
	end

	-- Move attack power
	local powerOffset = 102
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY - moveTableHeaderHeightDiff, "Pow")
	for moveIndex = 1, 4, 1 do
		if moves[moveIndex].power == "WT" and Settings.tracker.CALCULATE_WEIGHT_BASED_DAMAGE == true and Tracker.Data.inBattle == 1 then
			-- Calculate the power of weight moves to show in battle
			local targetWeight = PokemonData[targetMon["pokemonID"] + 1].weight
			local newPower = Utils.calculateWeightBasedDamage(targetWeight)
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), newPower, stabColors[moveIndex])
		else
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].power, stabColors[moveIndex])
		end
	end

	-- Move accuracy
	local accOffset = 126
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY - moveTableHeaderHeightDiff, "Acc")
	for moveIndex = 1, 4, 1 do
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].accuracy, 3)
	end

    
	-- Move effectiveness against the opponent
	if Settings.tracker.SHOW_MOVE_EFFECTIVENESS and Tracker.Data.inBattle == 1 then
		if targetMon ~= nil then
			for moveIndex = 1, 4, 1 do
				local effectiveness = Utils.netEffectiveness(moves[moveIndex], PokemonData[targetMon.pokemonID + 1])
				Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), effectiveness)
			end
		end
	end

	Drawing.drawButtons()
	Drawing.drawInputOverlay()

	-- draw note box
	local note = Tracker.GetNote()
	if note == '' then
		gui.drawImage(DATA_FOLDER .. "/images/icons/editnote.png", GraphicConstants.SCREEN_WIDTH + borderMargin + 2, movesBoxStartY + 48, 11, 11)
	else
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY + 47, note)
		--work around limitation of drawText not having width limit: paint over any spillover
		local x = GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 5
		local y = 141
		gui.drawLine(x, 141, x, y + 12, GraphicConstants.LAYOUTCOLORS.BOXBORDER)
		gui.drawRectangle(x + 1, y, 12, 12, 0xFF000000, 0xFF000000)
	end
end
















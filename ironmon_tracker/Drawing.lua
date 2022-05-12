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

function Drawing.drawText(x, y, text, color)
	gui.drawText(x+1, y+1, text, "black", nil, 9, "Franklin Gothic Medium")
	gui.drawText(x, y, text, color, nil, 9, "Franklin Gothic Medium")
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
	return color
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY, PokemonData[monToDraw["pokemonID"] + 1].name)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 1), "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 52, pkmnStatStartY + (pkmnStatOffsetY * 1), currentHP .. "/" .. maxHP, colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 2), "Lv." .. monToDraw["level"] .. " (" .. PokemonData[monToDraw["pokemonID"] + 1].evolution .. ")")

	local infoBoxHeight = 23
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin + statBoxHeight, statBoxWidth - borderMargin, infoBoxHeight, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Heals in Bag:", GraphicConstants.LAYOUTCOLORS.INCREASE)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 35, 57, "235% HP", GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, string.format("%.0f%%", Tracker.Data.healingItems.healing) .. " HP (" .. Tracker.Data.healingItems.numHeals .. ")", GraphicConstants.LAYOUTCOLORS.INCREASE)
	
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

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 3), MiscData.item[monToDraw["heldItem"] + 1], GraphicConstants.LAYOUTCOLORS.HIGHLIGHT)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), abilityString, GraphicConstants.LAYOUTCOLORS.HIGHLIGHT)

	local statBoxY = 5
	local statOffsetX = statBoxWidth + 1
	local statValueOffsetX = statBoxWidth + 26
	local statInc = 10
	local hpY = 7
	local attY = hpY + statInc
	local defY = attY + statInc
	local spaY = defY + statInc
	local spdY = spaY + statInc
	local speY = spdY + statInc
	local bstY = speY + statInc
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxWidth, statBoxY, GraphicConstants.RIGHT_GAP - statBoxWidth - borderMargin, 75, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, hpY, " HP", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("hp", monToDraw["nature"])))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATK", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("atk", monToDraw["nature"])))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("def", monToDraw["nature"])))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("spa", monToDraw["nature"])))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("spd", monToDraw["nature"])))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", Utils.inlineIf(monIsEnemy, GraphicConstants.LAYOUTCOLORS.NEUTRAL, Drawing.getNatureColor("spe", monToDraw["nature"])))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST", GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData[monToDraw["pokemonID"] + 1].bst, GraphicConstants.LAYOUTCOLORS.NEUTRAL)

	if monIsEnemy == false then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, hpY, monToDraw["maxHP"], Drawing.getNatureColor("hp", monToDraw["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, attY, monToDraw["atk"], Drawing.getNatureColor("atk", monToDraw["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, defY, monToDraw["def"], Drawing.getNatureColor("def", monToDraw["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spaY, monToDraw["spa"], Drawing.getNatureColor("spa", monToDraw["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spdY, monToDraw["spd"], Drawing.getNatureColor("spd", monToDraw["nature"]))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, speY, monToDraw["spe"], Drawing.getNatureColor("spe", monToDraw["nature"]))
	end

	local statusLevelOffset = 5
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, hpY, monToDraw.statStages["HP"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, attY, monToDraw.statStages["ATK"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, defY, monToDraw.statStages["DEF"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, spaY, monToDraw.statStages["SPATK"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, spdY, monToDraw.statStages["SPDEF"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - statusLevelOffset, speY, monToDraw.statStages["SPEED"])

	-- Drawing moves
	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY, GraphicConstants.RIGHT_GAP - (2*borderMargin), 46, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)
	local moveStartY = movesBoxStartY + 3

	local monLevel = monToDraw["level"]
	local monData = PokemonData[monToDraw["pokemonID"] + 1]
	local moveLevels = monData.movelvls[GameSettings.versiongroup]

	local movesLearnedSinceFirst = 0
	local movesLearnedSinceSecond = 0
	local movesLearnedSinceThird = 0
	local movesLearnedSinceFouth = 0

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
			movesLearnedSinceFouth = movesLearnedSinceFouth + 1
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

	local firstStar = (monIsEnemy == true and Tracker.Data.selectedPokemon.moves.first.level ~= 1 and movesLearnedSinceFirst >= moveAgeRank.first) and "*" or ""
	local secondStar = (monIsEnemy == true and Tracker.Data.selectedPokemon.moves.second.level ~= 1 and movesLearnedSinceSecond >= moveAgeRank.second) and "*" or ""
	local thirdStar = (monIsEnemy == true and Tracker.Data.selectedPokemon.moves.third.level ~= 1 and movesLearnedSinceThird >= moveAgeRank.third) and "*" or ""
	local fourthStar = (monIsEnemy == true and Tracker.Data.selectedPokemon.moves.fourth.level ~= 1 and movesLearnedSinceFouth >= moveAgeRank.fourth) and "*" or ""

	local moveOne = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.first.move], MoveData[monToDraw["move1"] + 1])
	local moveTwo = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.second.move], MoveData[monToDraw["move2"] + 1])
	local moveThree = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.third.move], MoveData[monToDraw["move3"] + 1])
	local moveFour = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.selectedPokemon.moves.fourth.move], MoveData[monToDraw["move4"] + 1])

	local distanceBetweenMoves = 10

	local moveOffset = 6
	local movesString = "Move ~  "

	-- Moves Learned
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, 140, GraphicConstants.RIGHT_GAP - (2*borderMargin), 14, GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL)
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

	movesString = movesString .. movesLearned .. "/" .. moveCount
	if nextMove ~= 0 then
		movesString = movesString .. " (" .. nextMove .. ")"
	end

	-- Draw moves
	local moveColorOne = Drawing.moveToColor(moveOne)
	local moveColorTwo = Drawing.moveToColor(moveTwo)
	local moveColorThree = Drawing.moveToColor(moveThree)
	local moveColorFour = Drawing.moveToColor(moveFour)

	local stabColorOne = Utils.inlineIf(Utils.isSTAB(moveOne, PokemonData[monToDraw["pokemonID"] + 1]) and Tracker.Data.inBattle == 1 and moveOne["power"] ~= NOPOWER, GraphicConstants.LAYOUTCOLORS.INCREASE, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	local stabColorTwo = Utils.inlineIf(Utils.isSTAB(moveTwo, PokemonData[monToDraw["pokemonID"] + 1]) and Tracker.Data.inBattle == 1  and moveTwo["power"] ~= NOPOWER, GraphicConstants.LAYOUTCOLORS.INCREASE, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	local stabColorThree = Utils.inlineIf(Utils.isSTAB(moveThree, PokemonData[monToDraw["pokemonID"] + 1]) and Tracker.Data.inBattle == 1 and moveThree["power"] ~= NOPOWER, GraphicConstants.LAYOUTCOLORS.INCREASE, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
	local stabColorFour = Utils.inlineIf(Utils.isSTAB(moveFour, PokemonData[monToDraw["pokemonID"] + 1]) and Tracker.Data.inBattle == 1 and moveFour["power"] ~= NOPOWER, GraphicConstants.LAYOUTCOLORS.INCREASE, GraphicConstants.LAYOUTCOLORS.NEUTRAL)

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset - 1, moveStartY - moveTableHeaderHeightDiff, movesString)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY, moveOne["name"] .. firstStar, moveColorOne)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + (distanceBetweenMoves * 1), moveTwo["name"] .. secondStar, moveColorTwo)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + (distanceBetweenMoves * 2), moveThree["name"] .. thirdStar, moveColorThree)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + (distanceBetweenMoves * 3), moveFour["name"] .. fourthStar, moveColorFour)

	local ppOffset = 82
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY - moveTableHeaderHeightDiff, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY, Utils.inlineIf(monIsEnemy or moveOne["pp"] == NOPP, moveOne["pp"], Utils.getbits(monToDraw["pp"], 0, 8)))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * 1), Utils.inlineIf(monIsEnemy or moveTwo["pp"] == NOPP, moveTwo["pp"], Utils.getbits(monToDraw["pp"], 8, 8)))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * 2), Utils.inlineIf(monIsEnemy or moveThree["pp"] == NOPP, moveThree["pp"], Utils.getbits(monToDraw["pp"], 16, 8)))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * 3), Utils.inlineIf(monIsEnemy or moveFour["pp"] == NOPP, moveFour["pp"], Utils.getbits(monToDraw["pp"], 24, 8)))

	-- gui.drawImage(DATA_FOLDER .. "/images/icons/special6" .. ".png", GraphicConstants.SCREEN_WIDTH + ppOffset - 9, moveStartY + (distanceBetweenMoves * 1) + 2, 7, 7)
	-- gui.drawImage(DATA_FOLDER .. "/images/icons/physical9" .. ".png", GraphicConstants.SCREEN_WIDTH + ppOffset - 9, moveStartY + (distanceBetweenMoves * 2) + 2, 7, 7)

	local powerOffset = 102
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY - moveTableHeaderHeightDiff, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY, moveOne["power"], stabColorOne)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * 1), moveTwo["power"], stabColorTwo)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * 2), moveThree["power"], stabColorThree)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * 3), moveFour["power"], stabColorFour)

	local accOffset = 126
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY - moveTableHeaderHeightDiff, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY, moveOne["accuracy"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * 1), moveTwo["accuracy"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * 2), moveThree["accuracy"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * 3), moveFour["accuracy"])

	if targetMon ~= nil then
		local firstEffectiveness = Utils.netEffectiveness(moveOne, PokemonData[targetMon["pokemonID"] + 1])
		local secondEffectiveness = Utils.netEffectiveness(moveTwo, PokemonData[targetMon["pokemonID"] + 1])
		local thirdEffectiveness = Utils.netEffectiveness(moveThree, PokemonData[targetMon["pokemonID"] + 1])
		local fourthEffectivness = Utils.netEffectiveness(moveFour, PokemonData[targetMon["pokemonID"] + 1])

		Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY, firstEffectiveness)
		Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY + (distanceBetweenMoves * 1), secondEffectiveness)
		Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY + (distanceBetweenMoves * 2), thirdEffectiveness)
		Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - statusLevelOffset, moveStartY + (distanceBetweenMoves * 3), fourthEffectivness)
	end

	Drawing.drawButtons()
	Drawing.drawInputOverlay()
end

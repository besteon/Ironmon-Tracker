Drawing = {}

function Drawing.clearGUI()
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, 0xFF000000, 0xFF000000)
end

function Drawing.drawPokemonIcon(id, x, y, selectedPokemon)
	if id < 0 or id > 412 then
		id = 0
	end

	gui.drawRectangle(x, y, GraphicConstants.RIGHT_GAP - 64, 50, GraphicConstants.LAYOUTCOLORS.BOXFILL, GraphicConstants.LAYOUTCOLORS.BOXBORDER)

	if PokemonData[id + 1].type[1] ~= "" then
		gui.drawImage(DATA_FOLDER .. "/images/types/" .. PokemonData[id + 1].type[1] .. ".png", x + 1, y + 26, 32, 12)
	end
	if PokemonData[id + 1].type[2] ~= "" then
		gui.drawImage(DATA_FOLDER .. "/images/types/" .. PokemonData[id + 1].type[2] .. ".png", x + 1, y + 38, 32, 12)
	end

	gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. id .. ".gif", x, y - 7, 32, 32)

end

function Drawing.drawText(x, y, text, color)
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
	if (Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames) and (Tracker.Data.player == 2) then
		gui.drawRectangle(Buttons[Tracker.controller.statIndex].box[1], Buttons[Tracker.controller.statIndex].box[2], Buttons[Tracker.controller.statIndex].box[3], Buttons[Tracker.controller.statIndex].box[4], "yellow", 0x000000)
	end
end

function Drawing.DrawTracker(monToDraw, monIsEnemy)
	Drawing.drawPokemonIcon(monToDraw["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)

	local colorbar = GraphicConstants.LAYOUTCOLORS.NEUTRAL
	if monToDraw["curHP"] / monToDraw["maxHP"] <= 0.2 then
		colorbar = GraphicConstants.LAYOUTCOLORS.DECREASE
	elseif monToDraw["curHP"] / monToDraw["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end

	local currentHP = Utils.inlineIf(monIsEnemy, "?", monToDraw["curHP"])
	local maxHP = Utils.inlineIf(monIsEnemy, "?", monToDraw["maxHP"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 7, PokemonData[monToDraw["pokemonID"] + 1].name)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53, 17, currentHP .. "/" .. maxHP, colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 31, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 58, 31, monToDraw["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 43, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 58, 43, PokemonData[monToDraw["pokemonID"] + 1].evolution)

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25, GraphicConstants.LAYOUTCOLORS.BOXFILL, GraphicConstants.LAYOUTCOLORS.BOXBORDER)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 28, 57, MiscData.item[monToDraw["heldItem"] + 1], GraphicConstants.LAYOUTCOLORS.HIGHLIGHT)

	local abilityString = Utils.inlineIf(monIsEnemy, "---", MiscData.ability[monToDraw["ability"]])
	if monIsEnemy then
		for k, v in pairs(Tracker.Data.currentlyTrackedPokemonAbilities) do
			if v == monToDraw["ability"] then
				local abilityId = monToDraw["ability"] + 1
				abilityString = MiscData.ability[abilityId]
			end
		end
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, "Ablty:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 28, 67, abilityString, GraphicConstants.LAYOUTCOLORS.HIGHLIGHT)

	local statBoxX = 95
	local statBoxY = 5
	local statOffsetX = statBoxX + 3
	local statValueOffsetX = statBoxX + 28
	local statInc = 10
	local hpY = 7
	local attY = hpY + statInc
	local defY = attY + statInc
	local spaY = defY + statInc
	local spdY = spaY + statInc
	local speY = spdY + statInc
	local bstY = speY + statInc
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxX, statBoxY, GraphicConstants.RIGHT_GAP - 101, 75, GraphicConstants.LAYOUTCOLORS.BOXFILL, GraphicConstants.LAYOUTCOLORS.BOXBORDER)
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

	-- Drawing moves
	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46, GraphicConstants.LAYOUTCOLORS.BOXFILL, GraphicConstants.LAYOUTCOLORS.BOXBORDER)
	local moveStartY = movesBoxStartY + 3

	local monLevel = monToDraw["level"]
	local monData = PokemonData[monToDraw["pokemonID"] + 1]
	local moveLevels = monData.movelvls[GameSettings.versiongroup]

	local movesLearnedSinceFirst = 0
	local movesLearnedSinceSecond = 0
	local movesLearnedSinceThird = 0
	local movesLearnedSinceFouth = 0

	for k, v in pairs(moveLevels) do
		if v > Tracker.Data.currentlyTrackedPokemonMoves.first.level and v <= monLevel then
			movesLearnedSinceFirst = movesLearnedSinceFirst + 1
		end
		if v > Tracker.Data.currentlyTrackedPokemonMoves.second.level and v <= monLevel then
			movesLearnedSinceSecond = movesLearnedSinceSecond + 1
		end
		if v > Tracker.Data.currentlyTrackedPokemonMoves.third.level and v <= monLevel then
			movesLearnedSinceThird = movesLearnedSinceThird + 1
		end
		if v > Tracker.Data.currentlyTrackedPokemonMoves.fourth.level and v <= monLevel then
			movesLearnedSinceFouth = movesLearnedSinceFouth + 1
		end
	end

	local moveAgeRank = {
		first = 1,
		second = 1,
		third = 1,
		fourth = 1
	}
	for k, v in pairs(Tracker.Data.currentlyTrackedPokemonMoves) do
		for k2, v2 in pairs(Tracker.Data.currentlyTrackedPokemonMoves) do
			if k ~= k2 then
				if v.level > v2.level then
					moveAgeRank[k] = moveAgeRank[k] + 1
				end
			end
		end
	end

	local firstStar = (monIsEnemy == true and Tracker.Data.currentlyTrackedPokemonMoves.first.level ~= 1 and movesLearnedSinceFirst >= moveAgeRank.first) and "*" or ""
	local secondStar = (monIsEnemy == true and Tracker.Data.currentlyTrackedPokemonMoves.second.level ~= 1 and movesLearnedSinceSecond >= moveAgeRank.second) and "*" or ""
	local thirdStar = (monIsEnemy == true and Tracker.Data.currentlyTrackedPokemonMoves.third.level ~= 1 and movesLearnedSinceThird >= moveAgeRank.third) and "*" or ""
	local fourthStar = (monIsEnemy == true and Tracker.Data.currentlyTrackedPokemonMoves.fourth.level ~= 1 and movesLearnedSinceFouth >= moveAgeRank.fourth) and "*" or ""

	local moveOne = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.first.move], MoveData[monToDraw["move1"] + 1])
	local moveTwo = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.second.move], MoveData[monToDraw["move2"] + 1])
	local moveThree = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.third.move], MoveData[monToDraw["move3"] + 1])
	local moveFour = Utils.inlineIf(monIsEnemy, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.fourth.move], MoveData[monToDraw["move4"] + 1])

	local distanceBetweenMoves = 10

	local moveOffset = 6
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY, moveOne["name"] .. firstStar, Drawing.moveToColor(moveOne))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + (distanceBetweenMoves * 1), moveTwo["name"] .. secondStar, Drawing.moveToColor(moveTwo))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + (distanceBetweenMoves * 2), moveThree["name"] .. thirdStar, Drawing.moveToColor(moveThree))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + (distanceBetweenMoves * 3), moveFour["name"] .. fourthStar, Drawing.moveToColor(moveFour))

	local ppOffset = 70
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY, Utils.inlineIf(monIsEnemy, moveOne["pp"], Utils.getbits(monToDraw["pp"], 0, 8)))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * 1), Utils.inlineIf(monIsEnemy, moveTwo["pp"], Utils.getbits(monToDraw["pp"], 8, 8)))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * 2), Utils.inlineIf(monIsEnemy, moveThree["pp"], Utils.getbits(monToDraw["pp"], 16, 8)))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * 3), Utils.inlineIf(monIsEnemy, moveFour["pp"], Utils.getbits(monToDraw["pp"], 24, 8)))

	local powerOffset = 95
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY, moveOne["power"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * 1), moveTwo["power"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * 2), moveThree["power"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * 3), moveFour["power"])

	local accOffset = 120
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY - 13, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY, moveOne["accuracy"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * 1), moveTwo["accuracy"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * 2), moveThree["accuracy"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * 3), moveFour["accuracy"])

	-- Moves Learned
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14, GraphicConstants.LAYOUTCOLORS.BOXFILL, GraphicConstants.LAYOUTCOLORS.BOXBORDER)
	local learnedRowHeight = 141
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

	local levelString = "Level"
	if nextMove == 0 then
		nextMove = ""
		levelString = "n/a"
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, learnedRowHeight, "Learned:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 43, learnedRowHeight, movesLearned)

	local movesLearnedOffest = 0
	if movesLearned > 9 then
		movesLearnedOffest = 5
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 48 + movesLearnedOffest, learnedRowHeight, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53 + movesLearnedOffest, learnedRowHeight, moveCount)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, learnedRowHeight, "Next:")

	local nextMoveColor = GraphicConstants.LAYOUTCOLORS.NEUTRAL
	if monIsEnemy == false and nextMove - 1 == monToDraw["level"] then
		nextMoveColor = GraphicConstants.LAYOUTCOLORS.INCREASE
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, learnedRowHeight, levelString, nextMoveColor)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, learnedRowHeight, nextMove, nextMoveColor)

	Drawing.drawButtons()
	Drawing.drawInputOverlay()
end

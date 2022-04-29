Drawing = {}

function Drawing.clearGUI()
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH,0,GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP,GraphicConstants.SCREEN_HEIGHT, 0xFF000000, 0xFF000000)
end

function Drawing.drawPokemonIcon(id, x, y, selectedPokemon)
    if id < 0 or id > 412 then
        id = 0
    end
    if selectedPokemon then
        gui.drawRectangle(x,y,GraphicConstants.RIGHT_GAP - 64,50, GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
    else
        gui.drawRectangle(x,y,GraphicConstants.RIGHT_GAP - 64,50, GraphicConstants.NONSELECTEDCOLOR, 0xFF222222)
    end

	if PokemonData[id + 1].type[1] ~= "" then
        gui.drawImage(DATA_FOLDER .. "/images/types/" .. PokemonData[id + 1].type[1] .. ".png", x+1, y+26, 32, 12)
    end
    if PokemonData[id + 1].type[2] ~= "" then
        gui.drawImage(DATA_FOLDER .. "/images/types/" .. PokemonData[id + 1].type[2] .. ".png", x+1, y+38, 32, 12)
    end

	gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. id .. ".gif", x, y-7, 32, 32)

end

function Drawing.drawText(x, y, text, color)
	gui.drawText( x, y, text, color, null, 9, "Franklin Gothic Medium")
end

function Drawing.drawTriangleRight(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({{4+x,4+y},{4+x,y+size-4},{x+size-4,y+size/2}}, color, color)
end
function Drawing.drawTriangleLeft(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({{x+size-4,4+y},{x+size-4,y+size-4},{4+x,y+size/2}}, color, color)
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

function Drawing.moveToColor(moveId)
	local type = MoveData[moveId].type
	if type == "normal" then
		return GraphicConstants.TYPECOLORS.NORMAL
	elseif type == "fighting" then
		return GraphicConstants.TYPECOLORS.FIGHTING
	elseif type == "flying" then
		return GraphicConstants.TYPECOLORS.FLYING
	elseif type == "poison" then
		return GraphicConstants.TYPECOLORS.POISON
	elseif type == "ground" then
		return GraphicConstants.TYPECOLORS.GROUND
	elseif type == "rock" then
		return GraphicConstants.TYPECOLORS.ROCK
	elseif type == "bug" then
		return GraphicConstants.TYPECOLORS.BUG
	elseif type == "ghost" then
		return GraphicConstants.TYPECOLORS.GHOST
	elseif type == "steel" then
		return GraphicConstants.TYPECOLORS.STEEL
	elseif type == "fire" then
		return GraphicConstants.TYPECOLORS.FIRE
	elseif type == "water" then
		return GraphicConstants.TYPECOLORS.WATER
	elseif type == "grass" then
		return GraphicConstants.TYPECOLORS.GRASS
	elseif type == "electric" then
		return GraphicConstants.TYPECOLORS.ELECTRIC
	elseif type == "psychic" then
		return GraphicConstants.TYPECOLORS.PSYCHIC
	elseif type == "ice" then
		return GraphicConstants.TYPECOLORS.ICE
	elseif type == "dragon" then
		return GraphicConstants.TYPECOLORS.DRAGON
	elseif type == "dark" then
		return GraphicConstants.TYPECOLORS.DARK
	end

	return 0xFFFFFFFF
end

function Drawing.drawStatusLevel(x, y, value)
	if value == 0 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, 0xFFFF00000)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, 0xFFFF00000)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, 0xFFFF00000)
	elseif value == 1 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, 0xFFFF00000)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, 0xFFFF00000)
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, "white")
	elseif value == 2 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, 0xFFFF00000)
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, "white")
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, "white")
	elseif value == 3 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, "white")
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, "white")
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, "white")
	elseif value == 4 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, "white")
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, "white")
	elseif value == 5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, "white")
	elseif value == 7 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, "white")
	elseif value == 8 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, "white")
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, "white")
	elseif value == 9 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, "white")
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, "white")
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, "white")
	elseif value == 10 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, "white")
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, "white")
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, 0xFF00FF00)
	elseif value == 11 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, "white")
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, 0xFF00FF00)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, 0xFF00FF00)
	elseif value == 12 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, 0xFF00FF00)
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, 0xFF00FF00)
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, 0xFF00FF00)
	end
end

function Drawing.drawPokemonView()
	Drawing.drawPokemonIcon(Tracker.Data.selectedPokemon["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)
	local colorbar = "white"

	if Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 7, PokemonData[Tracker.Data.selectedPokemon["pokemonID"] + 1].name)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53, 17, Tracker.Data.selectedPokemon["curHP"] .. "/" .. Tracker.Data.selectedPokemon["maxHP"], colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 31, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 58, 31, Tracker.Data.selectedPokemon["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 43, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 58, 43, PokemonData[Tracker.Data.selectedPokemon["pokemonID"] + 1].evolution)
	

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 28, 57, MiscData.item[Tracker.Data.selectedPokemon["heldItem"] + 1], "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, "Ablty:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 28, 67, MiscData.ability[Tracker.Data.main.ability], "yellow")

	
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
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxX, statBoxY, GraphicConstants.RIGHT_GAP - 101, 75,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, hpY, " HP", Utils.getNatureColor("hp", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATK", Utils.getNatureColor("atk", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", Utils.getNatureColor("def", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", Utils.getNatureColor("spa", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", Utils.getNatureColor("spd", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", Utils.getNatureColor("spe", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST")

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, hpY, Tracker.Data.selectedPokemon["maxHP"], Utils.getNatureColor("hp", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, attY, Tracker.Data.selectedPokemon["atk"], Utils.getNatureColor("atk", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, defY, Tracker.Data.selectedPokemon["def"], Utils.getNatureColor("def", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spaY, Tracker.Data.selectedPokemon["spa"], Utils.getNatureColor("spa", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spdY, Tracker.Data.selectedPokemon["spd"], Utils.getNatureColor("spd", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, speY, Tracker.Data.selectedPokemon["spe"], Utils.getNatureColor("spe", Tracker.Data.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData[Tracker.Data.selectedPokemon.pokemonID + 1].bst)

	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, hpY, Tracker.Data.selectedPokemon.statStages["HP"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, attY, Tracker.Data.selectedPokemon.statStages["ATK"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, defY, Tracker.Data.selectedPokemon.statStages["DEF"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, spaY, Tracker.Data.selectedPokemon.statStages["SPATK"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, spdY, Tracker.Data.selectedPokemon.statStages["SPDEF"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, speY, Tracker.Data.selectedPokemon.statStages["SPEED"])

	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46,0xFFAAAAAA, 0xFF222222)
	local moveStartY = movesBoxStartY + 3

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY, MoveData[Tracker.Data.selectedPokemon["move1"] + 1].name, Drawing.moveToColor(Tracker.Data.selectedPokemon["move1"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 10, MoveData[Tracker.Data.selectedPokemon["move2"] + 1].name, Drawing.moveToColor(Tracker.Data.selectedPokemon["move2"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 20, MoveData[Tracker.Data.selectedPokemon["move3"] + 1].name, Drawing.moveToColor(Tracker.Data.selectedPokemon["move3"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 30, MoveData[Tracker.Data.selectedPokemon["move4"] + 1].name, Drawing.moveToColor(Tracker.Data.selectedPokemon["move4"] + 1))
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 0, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 10, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 8, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 20, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 16, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 30, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 24, 8))

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY, MoveData[Tracker.Data.selectedPokemon["move1"] + 1].power)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 10, MoveData[Tracker.Data.selectedPokemon["move2"] + 1].power)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 20, MoveData[Tracker.Data.selectedPokemon["move3"] + 1].power)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 30, MoveData[Tracker.Data.selectedPokemon["move4"] + 1].power)
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY - 13, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY, MoveData[Tracker.Data.selectedPokemon["move1"] + 1].accuracy)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 10, MoveData[Tracker.Data.selectedPokemon["move2"] + 1].accuracy)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 20, MoveData[Tracker.Data.selectedPokemon["move3"] + 1].accuracy)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 30, MoveData[Tracker.Data.selectedPokemon["move4"] + 1].accuracy)

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14,0xFFAAAAAA, 0xFF222222)
	local movelevellist = PokemonData[Tracker.Data.selectedPokemon.pokemonID + 1].movelvls -- pokemonID
	local moveCount = 0
	local movesLearned = 0
	local nextMove = 0
	local foundNextMove = false

	for k, v in pairs(movelevellist[GameSettings.versiongroup]) do -- game
		moveCount = moveCount + 1
		if v <= Tracker.Data.selectedPokemon["level"] then
			movesLearned = movesLearned + 1
		else
			if foundNextMove == false then
				nextMove = v
				foundNextMove = true
			end
		end
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 141, "Learned:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 43, 141, movesLearned)

	local movesLearnedOffest = 0
	if movesLearned > 9 then
		movesLearnedOffest = 5
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 48 + movesLearnedOffest, 141, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53 + movesLearnedOffest, 141, moveCount)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 141, "Next:")
	local nextMoveColor = "white"
	if nextMove - 1 == Tracker.Data.selectedPokemon["level"] then
		nextMoveColor = 0xFF00FF00
	end
	if nextMove == 0 then
		nextMove = "n/a"
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, 141, "Level", nextMoveColor)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 141, nextMove, nextMoveColor)
end

function Drawing.drawTrackerView()
	Drawing.drawPokemonIcon(Tracker.Data.selectedPokemon["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)
	local colorbar = "white"

	if Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 7, PokemonData[Tracker.Data.selectedPokemon["pokemonID"] + 1].name)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53, 17, "?/?", colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 31, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 58, 31, Tracker.Data.selectedPokemon["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 38, 43, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 58, 43, PokemonData[Tracker.Data.selectedPokemon["pokemonID"] + 1].evolution)
	
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 28, 57, "---", "yellow")

	local abilityString = "---"
	for k, v in pairs(Tracker.Data.currentlyTrackedPokemonAbilities) do
		if v == Tracker.Data.selectedPokemon["ability"] then
			local abilityId = Tracker.Data.selectedPokemon["ability"] + 1
			abilityString = MiscData.ability[abilityId]
		end
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, "Ablty:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 28, 67, abilityString, "yellow")

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
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxX, statBoxY, GraphicConstants.RIGHT_GAP - 101, 75,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, hpY, " HP", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATK", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST", "white")

	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, hpY, Tracker.Data.selectedPokemon.statStages["HP"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, attY, Tracker.Data.selectedPokemon.statStages["ATK"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, defY, Tracker.Data.selectedPokemon.statStages["DEF"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, spaY, Tracker.Data.selectedPokemon.statStages["SPATK"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, spdY, Tracker.Data.selectedPokemon.statStages["SPDEF"])
	Drawing.drawStatusLevel(GraphicConstants.SCREEN_WIDTH + statValueOffsetX - 5, speY, Tracker.Data.selectedPokemon.statStages["SPEED"])

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData[Tracker.Data.selectedPokemon.pokemonID + 1].bst)

	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46,0xFFAAAAAA, 0xFF222222)
	local moveStartY = movesBoxStartY + 3

	local monLevel = Tracker.Data.selectedPokemon.level
	local monData = PokemonData[Tracker.Data.selectedPokemon.pokemonID + 1]
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

	moveAgeRank = {
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

	local firstStar = (Tracker.Data.currentlyTrackedPokemonMoves.first.level ~= 1 and movesLearnedSinceFirst >= moveAgeRank.first) and "*" or ""
	local secondStar = (Tracker.Data.currentlyTrackedPokemonMoves.second.level ~= 1 and movesLearnedSinceSecond >= moveAgeRank.second) and "*" or ""
	local thirdStar = (Tracker.Data.currentlyTrackedPokemonMoves.third.level ~= 1 and movesLearnedSinceThird >= moveAgeRank.third) and "*" or ""
	local fouthStar = (Tracker.Data.currentlyTrackedPokemonMoves.fourth.level ~= 1 and movesLearnedSinceFouth >= moveAgeRank.fourth) and "*" or ""

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.first.move].name .. firstStar, Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.first.move))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 10, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.second.move].name .. secondStar, Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.second.move))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 20, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.third.move].name .. thirdStar, Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.third.move))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 30, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.fourth.move].name .. fouthStar, Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.fourth.move))
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.first.move].pp)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 10, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.second.move].pp)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 20, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.third.move].pp)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 30, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.fourth.move].pp)

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.first.move].power)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 10, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.second.move].power)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 20, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.third.move].power)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 30, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.fourth.move].power)
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY - 13, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.first.move].accuracy)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 10, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.second.move].accuracy)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 20, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.third.move].accuracy)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 30, MoveData[Tracker.Data.currentlyTrackedPokemonMoves.fourth.move].accuracy)

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14,0xFFAAAAAA, 0xFF222222)
	local movelevellist = PokemonData[Tracker.Data.selectedPokemon.pokemonID + 1].movelvls -- pokemonID
	local moveCount = 0
	local movesLearned = 0
	local nextMove = 0
	local foundNextMove = false

	for k, v in pairs(movelevellist[GameSettings.versiongroup]) do -- game
		moveCount = moveCount + 1
		if v <= Tracker.Data.selectedPokemon["level"] then
			movesLearned = movesLearned + 1
		else
			if foundNextMove == false then
				nextMove = v
				foundNextMove = true
			end
		end
	end
	if nextMove == 0 then
		nextMove = "n/a"
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 141, "Learned:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 43, 141, movesLearned)

	local movesLearnedOffest = 0
	if movesLearned > 9 then
		movesLearnedOffest = 5
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 48 + movesLearnedOffest, 141, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53 + movesLearnedOffest, 141, moveCount)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 141, "Next:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, 141, "Level")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 141, nextMove)
end

function Drawing.drawButtons()
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
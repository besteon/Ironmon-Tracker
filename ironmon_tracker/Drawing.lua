Drawing = {}

function Drawing.drawLayout()
	-- gui.drawRectangle(
	-- 	GraphicConstants.SCREEN_WIDTH,
	-- 	0,
	-- 	GraphicConstants.RIGHT_GAP - 1,
	-- 	GraphicConstants.UP_GAP +  GraphicConstants.DOWN_GAP + GraphicConstants.SCREEN_HEIGHT - 1,
	-- 	GameSettings.gamecolor,
	-- 	0x00000000
	-- )
end

function Drawing.drawPokemonIcon(id, x, y, selectedPokemon)
	if id < 0 or id > 412 then
		id = 0
	end
	if selectedPokemon then
		gui.drawRectangle(x,y,GraphicConstants.RIGHT_GAP - 64,46, GraphicConstants.SELECTEDCOLOR[1], GraphicConstants.SELECTEDCOLOR[2])
	else
		gui.drawRectangle(x,y,GraphicConstants.RIGHT_GAP - 64,46, GraphicConstants.NONSELECTEDCOLOR, 0xFF222222)
	end
	gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. id .. ".gif", x+2, y+2, 32, 32)
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

function Drawing.moveToColor(moveId)
	local type = PokemonData.movetype[moveId]
	if type == "Normal" then
		return GraphicConstants.TYPECOLORS.NORMAL
	elseif type == "Fighting" then
		return GraphicConstants.TYPECOLORS.FIGHTING
	elseif type == "Flying" then
		return GraphicConstants.TYPECOLORS.FLYING
	elseif type == "Poison" then
		return GraphicConstants.TYPECOLORS.POISON
	elseif type == "Ground" then
		return GraphicConstants.TYPECOLORS.GROUND
	elseif type == "Rock" then
		return GraphicConstants.TYPECOLORS.ROCK
	elseif type == "Bug" then
		return GraphicConstants.TYPECOLORS.BUG
	elseif type == "Ghost" then
		return GraphicConstants.TYPECOLORS.GHOST
	elseif type == "Steel" then
		return GraphicConstants.TYPECOLORS.STEEL
	elseif type == "Fire" then
		return GraphicConstants.TYPECOLORS.FIRE
	elseif type == "Water" then
		return GraphicConstants.TYPECOLORS.WATER
	elseif type == "Grass" then
		return GraphicConstants.TYPECOLORS.GRASS
	elseif type == "Electric" then
		return GraphicConstants.TYPECOLORS.ELECTRIC
	elseif type == "Psychic" then
		return GraphicConstants.TYPECOLORS.PSYCHIC
	elseif type == "Ice" then
		return GraphicConstants.TYPECOLORS.ICE
	elseif type == "Dragon" then
		return GraphicConstants.TYPECOLORS.DRAGON
	elseif type == "Dark" then
		return GraphicConstants.TYPECOLORS.DARK
	end

	return 0xFFFFFFFF
end

function Drawing.drawPokemonView()
	Drawing.drawPokemonIcon(Tracker.Data.selectedPokemon["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)
	local colorbar = "white"

	if LayoutSettings.easterEggs == true then
		local easterEgg = PokemonData.name[Tracker.Data.selectedPokemon["pokemonID"] + 1]
		if easterEgg == "Magikarp" then
			gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. 129 .. ".gif", GraphicConstants.SCREEN_WIDTH / 2 - 16, GraphicConstants.SCREEN_HEIGHT / 2 - 28, 32, 32)
		end
	end

	if Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 7, PokemonData.name[Tracker.Data.selectedPokemon["pokemonID"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 55, 17, Tracker.Data.selectedPokemon["curHP"] .. "/" .. Tracker.Data.selectedPokemon["maxHP"], colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 27, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 27, Tracker.Data.selectedPokemon["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 37, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 37, PokemonData.evolution[Tracker.Data.selectedPokemon["pokemonID"] + 1])
	

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 33, 57, PokemonData.item[Tracker.Data.selectedPokemon["heldItem"] + 1], "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, "Ability:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 33, 67, PokemonData.ability[Tracker.Data.main.ability], "yellow")

	
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATT", Utils.getNatureColor("atk", Tracker.Data.selectedPokemon["nature"]))
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData.bst[Tracker.Data.selectedPokemon.pokemonID + 1])

	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46,0xFFAAAAAA, 0xFF222222)
	local moveStartY = movesBoxStartY + 3

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY, PokemonData.move[Tracker.Data.currentlyTrackedPokemonMoves.first + 1], Drawing.moveToColor(Tracker.Data.selectedPokemon["move1"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 10, PokemonData.move[Tracker.Data.selectedPokemon["move2"] + 1], Drawing.moveToColor(Tracker.Data.selectedPokemon["move2"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 20, PokemonData.move[Tracker.Data.selectedPokemon["move3"] + 1], Drawing.moveToColor(Tracker.Data.selectedPokemon["move3"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 30, PokemonData.move[Tracker.Data.selectedPokemon["move4"] + 1], Drawing.moveToColor(Tracker.Data.selectedPokemon["move4"] + 1))
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 0, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 10, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 8, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 20, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 16, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 30, Utils.getbits(Tracker.Data.selectedPokemon["pp"], 24, 8))

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY, PokemonData.power[Tracker.Data.selectedPokemon["move1"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 10, PokemonData.power[Tracker.Data.selectedPokemon["move2"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 20, PokemonData.power[Tracker.Data.selectedPokemon["move3"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 30, PokemonData.power[Tracker.Data.selectedPokemon["move4"] + 1])
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY - 13, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY, PokemonData.accuracy[Tracker.Data.selectedPokemon["move1"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 10, PokemonData.accuracy[Tracker.Data.selectedPokemon["move2"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 20, PokemonData.accuracy[Tracker.Data.selectedPokemon["move3"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 30, PokemonData.accuracy[Tracker.Data.selectedPokemon["move4"] + 1])

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14,0xFFAAAAAA, 0xFF222222)
	local movelevellist = PokemonData.movelearnedlevels[Tracker.Data.selectedPokemon.pokemonID + 1] -- pokemonID
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 48, 141, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53, 141, moveCount)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 141, "Next:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, 141, "Level", 0xFF00FF00)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 141, nextMove, 0xFF00FF00)
end

function Drawing.drawTrackerView()
	Drawing.drawPokemonIcon(Tracker.Data.selectedPokemon["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)
	local colorbar = "white"

	if Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Tracker.Data.selectedPokemon["curHP"] / Tracker.Data.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 7, PokemonData.name[Tracker.Data.selectedPokemon["pokemonID"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 55, 17, "?/?", colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 27, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 27, Tracker.Data.selectedPokemon["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 37, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 37, PokemonData.evolution[Tracker.Data.selectedPokemon["pokemonID"] + 1])

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 33, 57, "---", "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, "Ability:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 33, 67, "---", "yellow")

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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATT", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST", "white")

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData.bst[Tracker.Data.selectedPokemon.pokemonID + 1])

	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46,0xFFAAAAAA, 0xFF222222)
	local moveStartY = movesBoxStartY + 3

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY, PokemonData.move[Tracker.Data.currentlyTrackedPokemonMoves.first], Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.first))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 10, PokemonData.move[Tracker.Data.currentlyTrackedPokemonMoves.second], Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.second))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 20, PokemonData.move[Tracker.Data.currentlyTrackedPokemonMoves.third], Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.third))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, moveStartY + 30, PokemonData.move[Tracker.Data.currentlyTrackedPokemonMoves.fourth], Drawing.moveToColor(Tracker.Data.currentlyTrackedPokemonMoves.fourth))
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY, PokemonData.maxpp[Tracker.Data.currentlyTrackedPokemonMoves.first])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 10, PokemonData.maxpp[Tracker.Data.currentlyTrackedPokemonMoves.second])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 20, PokemonData.maxpp[Tracker.Data.currentlyTrackedPokemonMoves.third])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 30, PokemonData.maxpp[Tracker.Data.currentlyTrackedPokemonMoves.fourth])

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY, PokemonData.power[Tracker.Data.currentlyTrackedPokemonMoves.first])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 10, PokemonData.power[Tracker.Data.currentlyTrackedPokemonMoves.second])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 20, PokemonData.power[Tracker.Data.currentlyTrackedPokemonMoves.third])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 30, PokemonData.power[Tracker.Data.currentlyTrackedPokemonMoves.fourth])
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY - 13, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY, PokemonData.accuracy[Tracker.Data.currentlyTrackedPokemonMoves.first])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 10, PokemonData.accuracy[Tracker.Data.currentlyTrackedPokemonMoves.second])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 20, PokemonData.accuracy[Tracker.Data.currentlyTrackedPokemonMoves.third])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 30, PokemonData.accuracy[Tracker.Data.currentlyTrackedPokemonMoves.fourth])

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14,0xFFAAAAAA, 0xFF222222)
	local movelevellist = PokemonData.movelearnedlevels[Tracker.Data.selectedPokemon.pokemonID + 1] -- pokemonID
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 48, 141, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 53, 141, moveCount)
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
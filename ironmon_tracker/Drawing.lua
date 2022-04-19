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
	Drawing.drawPokemonIcon(Program.selectedPokemon["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)
	local colorbar = "white"

	if LayoutSettings.easterEggs == true then
		local easterEgg = PokemonData.name[Program.selectedPokemon["pokemonID"] + 1]
		if easterEgg == "Magikarp" then
			gui.drawImage(DATA_FOLDER .. "/images/pokemon/" .. 129 .. ".gif", GraphicConstants.SCREEN_WIDTH / 2 - 16, GraphicConstants.SCREEN_HEIGHT / 2 - 28, 32, 32)
		end
	end

	if Program.selectedPokemon["curHP"] / Program.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Program.selectedPokemon["curHP"] / Program.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 7, PokemonData.name[Program.selectedPokemon["pokemonID"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 55, 17, Program.selectedPokemon["curHP"] .. "/" .. Program.selectedPokemon["maxHP"], colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 27, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 27, Program.selectedPokemon["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 37, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 37, PokemonData.evolution[Program.selectedPokemon["pokemonID"] + 1])
	

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 8, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 35, 57, PokemonData.item[Program.selectedPokemon["heldItem"] + 1], "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 8, 67, "Ability:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 35, 67, PokemonData.ability[Program.tracker.main.ability], "yellow")

	
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
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, hpY, " HP", Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, attY, "ATT", Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, defY, "DEF", Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spaY, "SPA", Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, spdY, "SPD", Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, speY, "SPE", Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statOffsetX, bstY, "BST")

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, hpY, Program.selectedPokemon["maxHP"], Utils.getNatureColor("hp", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, attY, Program.selectedPokemon["atk"], Utils.getNatureColor("atk", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, defY, Program.selectedPokemon["def"], Utils.getNatureColor("def", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spaY, Program.selectedPokemon["spa"], Utils.getNatureColor("spa", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spdY, Program.selectedPokemon["spd"], Utils.getNatureColor("spd", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, speY, Program.selectedPokemon["spe"], Utils.getNatureColor("spe", Program.selectedPokemon["nature"]))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData.bst[Program.selectedPokemon.pokemonID + 1])

	local movesBoxStartY = 94
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46,0xFFAAAAAA, 0xFF222222)
	local moveStartY = movesBoxStartY + 3

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, moveStartY, PokemonData.move[Program.selectedPokemon["move1"] + 1], Drawing.moveToColor(Program.selectedPokemon["move1"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, moveStartY + 10, PokemonData.move[Program.selectedPokemon["move2"] + 1], Drawing.moveToColor(Program.selectedPokemon["move2"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, moveStartY + 20, PokemonData.move[Program.selectedPokemon["move3"] + 1], Drawing.moveToColor(Program.selectedPokemon["move3"] + 1))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, moveStartY + 30, PokemonData.move[Program.selectedPokemon["move4"] + 1], Drawing.moveToColor(Program.selectedPokemon["move4"] + 1))
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY, Utils.getbits(Program.selectedPokemon["pp"], 0, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 10, Utils.getbits(Program.selectedPokemon["pp"], 8, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 20, Utils.getbits(Program.selectedPokemon["pp"], 16, 8))
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY + 30, Utils.getbits(Program.selectedPokemon["pp"], 24, 8))

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY, PokemonData.power[Program.selectedPokemon["move1"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 10, PokemonData.power[Program.selectedPokemon["move2"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 20, PokemonData.power[Program.selectedPokemon["move3"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY + 30, PokemonData.power[Program.selectedPokemon["move4"] + 1])
	
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY - 13, "Acc")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY, PokemonData.accuracy[Program.selectedPokemon["move1"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 10, PokemonData.accuracy[Program.selectedPokemon["move2"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 20, PokemonData.accuracy[Program.selectedPokemon["move3"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY + 30, PokemonData.accuracy[Program.selectedPokemon["move4"] + 1])

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14,0xFFAAAAAA, 0xFF222222)
	local movelevellist = PokemonData.movelearnedlevels[Program.selectedPokemon.pokemonID + 1] -- pokemonID
	local moveCount = 0
	local movesLearned = 0
	local nextMove = 0
	local foundNextMove = false

	for k, v in pairs(movelevellist[GameSettings.versiongroup]) do -- game
		moveCount = moveCount + 1
		if v <= Program.selectedPokemon["level"] then
			movesLearned = movesLearned + 1
		else
			if foundNextMove == false then
				nextMove = v
				foundNextMove = true
			end
		end
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 141, "Learned:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 47, 141, movesLearned)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 52, 141, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 57, 141, moveCount)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 141, "Next:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, 141, "Level", 0xFF00FF00)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, 141, nextMove, 0xFF00FF00)
end

function Drawing.drawTrackerView()
	Drawing.drawPokemonIcon(Program.selectedPokemon["pokemonID"], GraphicConstants.SCREEN_WIDTH + 5, 5)
	local colorbar = "white"

	if Program.selectedPokemon["curHP"] / Program.selectedPokemon["maxHP"] <= 0.2 then
		colorbar = "red"
	elseif Program.selectedPokemon["curHP"] / Program.selectedPokemon["maxHP"] <= 0.5 then
		colorbar = "yellow"
	end

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 7, PokemonData.name[Program.selectedPokemon["pokemonID"] + 1])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 17, "HP:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 55, 17, "?/???", colorbar)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 27, "LVL:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 27, Program.selectedPokemon["level"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 37, "EVO:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 37, PokemonData.evolution[Program.selectedPokemon["pokemonID"] + 1])

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 55, GraphicConstants.RIGHT_GAP - 64, 25,0xFFAAAAAA, 0xFF222222)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 8, 57, "Item:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 57, "???", "yellow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 8, 67, "Ability:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 40, 67, "???", "yellow")

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

	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, hpY, "?", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, attY, "?", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, defY, "?", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spaY, "?", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, spdY, "?", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, speY, "?", "white")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + statValueOffsetX, bstY, PokemonData.bst[Program.selectedPokemon.pokemonID + 1])

	local movesBoxStartY = 94
	local moveStartY = movesBoxStartY + 3
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, moveStartY - 13, "Move")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, moveStartY - 13, "PP")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, moveStartY - 13, "Pow")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, moveStartY - 13, "Acc")

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, movesBoxStartY, GraphicConstants.RIGHT_GAP - 11, 46,0xFFAAAAAA, 0xFF222222)

	local movesStartY = movesBoxStartY + 3
	for k, v in pairs(Program.tracker.currentlyTrackedPokemonMoves) do 
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, movesStartY, PokemonData.move[v], Drawing.moveToColor(v))
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, movesStartY, PokemonData.maxpp[v])
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 95, movesStartY, PokemonData.power[v])
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 120, movesStartY, PokemonData.accuracy[v])
		movesStartY = movesStartY + 10
	end

	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + 5, 140, GraphicConstants.RIGHT_GAP - 11, 14,0xFFAAAAAA, 0xFF222222)
	local movelevellist = PokemonData.movelearnedlevels[Program.selectedPokemon.pokemonID + 1] -- pokemonID
	local moveCount = 0
	local movesLearned = 0
	local nextMove = 0
	local foundNextMove = false

	for k, v in pairs(movelevellist[GameSettings.versiongroup]) do -- game
		moveCount = moveCount + 1
		if v <= Program.selectedPokemon["level"] then
			movesLearned = movesLearned + 1
		else
			if foundNextMove == false then
				nextMove = v
				foundNextMove = true
			end
		end
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 10, 141, "Learned:")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 47, 141, movesLearned)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 52, 141, "/")
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 57, 141, moveCount)
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


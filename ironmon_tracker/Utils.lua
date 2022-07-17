Utils = {}

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1, d)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a, 0, 16)
	local c = Utils.getbits(a, 16, 16)
	return b + c
end

-- If the `condition` is true, the value in `T` is returned, else the value in `F` is returned
function Utils.inlineIf(condition, T, F)
	if condition then return T else return F end
end

-- Determine if the tracked Pokémon's moves are old and if so mark with a star
function Utils.calculateMoveStars(pokemonID, level)
	local stars = { "", "", "", "" }

	if pokemonID == nil or pokemonID == 0 or level == nil or level == 1 then
		return stars
	end

	-- If nothing has been tracked thus far for this Pokemon, return no stars
	local pokemon = Tracker.getOrCreateTrackedPokemon(pokemonID)
	if pokemon.moves == nil then
		return stars
	end

	-- For each move, count how many moves this Pokemon at this 'level' has learned already
	local movesLearnedSince = { 0, 0, 0, 0 }
	local allMoveLevels = PokemonData[pokemonID + 1].movelvls[GameSettings.versiongroup]
	for _, lv in pairs(allMoveLevels) do
		for moveIndex, move in pairs(pokemon.moves) do
			if lv > move.level and lv <= level then
				movesLearnedSince[moveIndex] = movesLearnedSince[moveIndex] + 1
			end
		end
	end

	-- Determine which moves are the oldest, by ranking them against their levels learnt.
	local moveAgeRank = { 1, 1, 1, 1 }
	for moveIndex, move in pairs(pokemon.moves) do
		for moveIndexCompare, moveCompare in pairs(pokemon.moves) do
			if moveIndex ~= moveIndexCompare then
				if move.level > moveCompare.level then
					moveAgeRank[moveIndex] = moveAgeRank[moveIndex] + 1
				end
			end
		end
	end

	-- A move is only star'd if it was possible it has been forgotten
	for moveIndex, move in pairs(pokemon.moves) do
		if move.level ~= 1 and movesLearnedSince[moveIndex] >= moveAgeRank[moveIndex] then
			stars[moveIndex] = "*"
		end
	end

	return stars
end

-- Move Header format: C/T (N), where C is moves learned so far, T is total number available to learn, and N is the next level the Pokemon learns a move
-- Example: 4/12 (25)
function Utils.getMovesLearnedHeader(pokemonID, level)
	if pokemonID == nil or pokemonID == 0 or level == nil then
		return "0/0 (0)"
	end

	local movesLearned = 0
	local nextMoveLevel = 0
	local foundNextMove = false

	local allMoveLevels = PokemonData[pokemonID + 1].movelvls[GameSettings.versiongroup]
	for _, lv in pairs(allMoveLevels) do
		if lv <= level then
			movesLearned = movesLearned + 1
		elseif not foundNextMove then
			nextMoveLevel = lv
			foundNextMove = true
		end
	end

	local header = movesLearned .. "/" .. table.getn(allMoveLevels)
	if foundNextMove then
		header = header .. " (" .. nextMoveLevel .. ")"
	end

	return header
end

function Utils.getDetailedEvolutionsInfo(evoMethod)
	if evoMethod == nil or evoMethod == EvolutionTypes.NONE then
		return { "---" }
	end

	if evoMethod == EvolutionTypes.FRIEND then
		return { "220 Friendship" }
	elseif evoMethod == EvolutionTypes.STONES then
		return { "5 Diff. Stones" }
	elseif evoMethod == EvolutionTypes.THUNDER then
		return { "Thunder Stone" }
	elseif evoMethod == EvolutionTypes.FIRE then
		return { "Fire Stone" }
	elseif evoMethod == EvolutionTypes.WATER then
		return { "Water Stone" }
	elseif evoMethod == EvolutionTypes.MOON then
		return { "Moon Stone" }
	elseif evoMethod == EvolutionTypes.LEAF then
		return { "Leaf Stone" }
	elseif evoMethod == EvolutionTypes.SUN then
		return { "Sun Stone" }
	elseif evoMethod == EvolutionTypes.LEAF_SUN then
		return {
			"Leaf Stone or",
			"Sun Stone",
		}
	elseif evoMethod == "37/WTR" then
		return {
			"Level 37 or",
			"Water Stone",
		}
	elseif evoMethod == "30/WTR" then
		return {
			"Level 30 or",
			"Water Stone",
		}
	else -- Otherwise, the evo is just a level
		return { "Level " .. evoMethod }
	end
end

function Utils.netEffectiveness(move, types)
	local effectiveness = 1.0

	-- TODO: Do we want to handle Hidden Power's varied type in this? We could analyze the IV of the Pokémon and determine the type...

	-- If move has no power, check for ineffectiveness by type first, then return 1.0 if ineffective cases not present
	if move.power == NOPOWER then
		if move.category ~= MoveCategories.STATUS then
			if move.type == PokemonTypes.NORMAL and (types[1] == PokemonTypes.GHOST or types[2] == PokemonTypes.GHOST) then
				return 0.0
			elseif move.type == PokemonTypes.FIGHTING and (types[1] == PokemonTypes.GHOST or types[2] == PokemonTypes.GHOST) then
				return 0.0
			elseif move.type == PokemonTypes.PSYCHIC and (types[1] == PokemonTypes.DARK or types[2] == PokemonTypes.DARK) then
				return 0.0
			elseif move.type == PokemonTypes.GROUND and (types[1] == PokemonTypes.FLYING or types[2] == PokemonTypes.FLYING) then
				return 0.0
			elseif move.type == PokemonTypes.GHOST and (types[1] == PokemonTypes.NORMAL or types[2] == PokemonTypes.NORMAL) then
				return 0.0
			end
		end
		return 1.0
	end

	local moveType = move.type
	if move.name == "Future Sight" or move.name == "Doom Desire" or moveType == PokemonTypes.UNKNOWN then
		return 1.0
	end

	for _, type in ipairs(types) do
		if move.name == "Hidden Power" and Tracker.Data.isViewingOwn then
			moveType = Tracker.Data.currentHiddenPowerType
		end
		if moveType ~= "---" then
			if EffectiveData[moveType][type] ~= nil then
				effectiveness = effectiveness * EffectiveData[moveType][type]
			end
		end
	end
	return effectiveness
end

function Utils.isSTAB(move, types)
	if move == nil or types == nil or move.power == NOPOWER then return false end

	local moveType = move.type
	if move.name == "Hidden Power" and Tracker.Data.isViewingOwn then
		moveType = Tracker.Data.currentHiddenPowerType
	end

	-- Check if the move's type matches any of the 'types' provided
	for _, type in ipairs(types) do
		if moveType == type then
			return true
		end
	end
	return false
end

-- For Low Kick & Grass Knot. Weight in kg. Bounds are inclusive per decompiled code.
function Utils.calculateWeightBasedDamage(weight)
	if weight < 10.0 then
		return "20"
	elseif weight < 25.0 then
		return "40"
	elseif weight < 50.0 then
		return "60"
	elseif weight < 100.0 then
		return "80"
	elseif weight < 200.0 then
		return "100"
	else
		return "120"
	end
end

-- For Flail & Reversal
function Utils.calculateLowHPBasedDamage(currentHP, maxHP)
	local percentHP = (currentHP / maxHP) * 100
	if percentHP < 4.17 then
		return "200"
	elseif percentHP < 10.42 then
		return "150"
	elseif percentHP < 20.83 then
		return "100"
	elseif percentHP < 35.42 then
		return "80"
	elseif percentHP < 68.75 then
		return "40"
	else
		return "20"
	end
end

-- For Water Spout & Eruption
function Utils.calculateHighHPBasedDamage(currentHP, maxHP)
	local basePower = (150 * currentHP) / maxHP
	if basePower < 1 then 
		basePower = 1 
	end
	local roundedPower = math.floor(basePower + 0.5)
	return tostring(roundedPower)
end

function Utils.pokemonHasMove(pokemon, moveName)
	if pokemon == nil or moveName == nil then return false end

	for _, move in pairs(pokemon.moves) do
		if moveName == MoveData[move.id].name then
			return true
		end
	end
	return false
end

-- Checks if the pokemon is ready to evolve based on level only
function Utils.isReadyToEvolveByLevel(pokemon)
	local evoMethod = PokemonData[pokemon.pokemonID + 1].evolution

	if evoMethod == EvolutionTypes.NONE then
		return false
	end

	evoMethod = string.match(evoMethod, "(.-)/") -- Handle condition of "37/WTR" with regex
	evoMethod = tonumber(evoMethod, 10) -- becomes nil if not a decimal number

	return evoMethod ~= nil and (pokemon.level + 1) >= evoMethod
end

-- Returns the text color for PC heal tracking
function Utils.getCenterHealColor()
	local currentCount = Tracker.Data.centerHeals
	if Options["PC heals count downward"] then
		-- Counting downwards
		if currentCount < 1 then
			return GraphicConstants.THEMECOLORS["Negative text"]
		elseif currentCount < 6 then
			return GraphicConstants.THEMECOLORS["Intermediate text"]
		else
			return GraphicConstants.THEMECOLORS["Default text"]
		end
	else
		-- Counting upwards
		if currentCount < 5 then
			return GraphicConstants.THEMECOLORS["Default text"]
		elseif currentCount < 10 then
			return GraphicConstants.THEMECOLORS["Intermediate text"]
		else
			return GraphicConstants.THEMECOLORS["Negative text"]
		end
	end
end

function Utils.truncateRomsFolder(folder)
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

function Utils.getWordWrapLines(str, limit)
	if str == nil or str == "" then return {} end
	
	local lines, here, limit = {}, 1, limit or 72
	lines[1] = string.sub(str, 1, str:find("(%s+)()(%S+)()")-1)  -- Put the first word of the string in the first index of the table.
	
	str:gsub("(%s+)()(%S+)()",
		function(sp, st, word, fi) -- Function gets called once for every space found.
			-- If at the end of a line, start a new table index
			if fi-here > limit then
				here = st
				lines[#lines + 1] = word
			else -- otherwise add to the current table index.
				lines[#lines] = lines[#lines] .. " " .. word
			end
		end)
	
	return lines
end

function Utils.writeTableToFile(table, filename)
	local file = io.open(filename, "w")

	if file ~= nil then
		local dataString = pickle(Tracker.Data)

		if dataString:sub(-1) ~= "\n" then dataString = dataString .. "\n" end --append a trailing \n if one is absent
		for dataLine in dataString:gmatch("(.-)\n") do
			file:write(dataLine)
		end
		file:close()
	else
		print("[ERROR] Unable to create auto-save file: " .. filename)
	end
end

function Utils.readTableFromFile(filename)	
	local tableData = nil
	local file = io.open(filename, "r")

	if file ~= nil then
		local dataString = file:read("*a")

		if dataString ~= nil and dataString ~= "" then
			tableData = unpickle(dataString)
		end
		file:close()
	end

	return tableData
end

--sets the form location relative to the game window
--this function does what the built in forms.setlocation function supposed to do
--currently that function is bugged and should be fixed in 2.9
function Utils.setFormLocation(handle,x,y)
	local ribbonHight = 64 -- so we are below the ribbon menu 
	local actualLocation = client.transformPoint(x,y)
	forms.setproperty(handle, "Left", client.xpos() + actualLocation['x'] )
	forms.setproperty(handle, "Top", client.ypos() + actualLocation['y'] + ribbonHight)
end

function Utils.getSaveBlock1Addr()
	if GameSettings.game == 1 then -- Ruby/Sapphire dont have ptr
		return GameSettings.gSaveBlock1
	end
	return Memory.readdword(GameSettings.gSaveBlock1ptr)
end
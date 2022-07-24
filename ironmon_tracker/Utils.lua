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


-- Returns '0' if neutral nature, '-1' if negative nature, and '1' if positive nature
function Utils.calcNatureBonus(stat, nature)
	if nature % 6 == 0 then
		return 0
	elseif stat == "atk" then
		if nature < 5 then
			return 1
		elseif nature % 5 == 0 then
			return -1
		end
	elseif stat == "def" then
		if nature > 4 and nature < 10 then
			return 1
		elseif nature % 5 == 1 then
			return -1
		end
	elseif stat == "spe" then
		if nature > 9 and nature < 15 then
			return 1
		elseif nature % 5 == 2 then
			return -1
		end
	elseif stat == "spa" then
		if nature > 14 and nature < 20 then
			return 1
		elseif nature % 5 == 3 then
			return -1
		end
	elseif stat == "spd" then
		if nature > 19 then
			return 1
		elseif nature % 5 == 4 then
			return -1
		end
	else
		return 0
	end
end

-- Returns a slightly darkened color
function Utils.calcShadowColor(color, scale)
	scale = scale or 0.92
	local color_hexval = (color - 0xFF000000)

	-- get the RGB values of the color 
	local r = bit.rshift(color_hexval, 16)
	local g = bit.rshift(bit.band(color_hexval, 0x00FF00), 8)
	local b = bit.band(color_hexval, 0x0000FF)

	--[[
	local scale = 0x10 -- read as: 6.25%
	local isDarkBG = (1 - (0.299 * r + 0.587 * g + 0.114 * b) / 255) >= 0.5;
	if isDarkBG then
		scale = 0x90 -- read as: 56.25%
	end
	-- scale RGB values down to make them darker
	r = r - r * scale / 0x100
	g = g - g * scale / 0x100
	b = b - b * scale / 0x100
	]]--

	r = math.max(r * scale, 0)
	g = math.max(g * scale, 0)
	b = math.max(b * scale, 0)

	-- build color with new hex values
	color_hexval = bit.lshift(r, 16) + bit.lshift(g, 8) + b 
	return (0xFF000000 + color_hexval)
end

-- scale is a value between 0 and 1; 0 doesn't alter the color at all, and 1 is pure grayscale (no saturation)
function Utils.calcGrayscale(color, scale)
	scale = scale or 0.80
	local color_hexval = (color - 0xFF000000)
	local r = bit.rshift(color_hexval, 16)
	local g = bit.rshift(bit.band(color_hexval, 0x00FF00), 8)
	local b = bit.band(color_hexval, 0x0000FF)
	local gray = 0.2989 * r + 0.5870 * g + 0.1140 * b -- CCIR 601 spec weights

	r = math.max(gray * scale + r * (1 - scale), 0)
	g = math.max(gray * scale + g * (1 - scale), 0)
	b = math.max(gray * scale + b * (1 - scale), 0)

	color_hexval = bit.lshift(r, 16) + bit.lshift(g, 8) + b 
	return (0xFF000000 + color_hexval)
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
	local allMoveLevels = PokemonData.Pokemon[pokemonID].movelvls[GameSettings.versiongroup]
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

	local allMoveLevels = PokemonData.Pokemon[pokemonID].movelvls[GameSettings.versiongroup]
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
	if evoMethod == nil or evoMethod == PokemonData.Evolutions.NONE then
		return { Constants.BLANKLINE }
	end

	if evoMethod == PokemonData.Evolutions.FRIEND then
		return { "220 Friendship" }
	elseif evoMethod == PokemonData.Evolutions.STONES then
		return { "5 Diff. Stones" }
	elseif evoMethod == PokemonData.Evolutions.THUNDER then
		return { "Thunder Stone" }
	elseif evoMethod == PokemonData.Evolutions.FIRE then
		return { "Fire Stone" }
	elseif evoMethod == PokemonData.Evolutions.WATER then
		return { "Water Stone" }
	elseif evoMethod == PokemonData.Evolutions.MOON then
		return { "Moon Stone" }
	elseif evoMethod == PokemonData.Evolutions.LEAF then
		return { "Leaf Stone" }
	elseif evoMethod == PokemonData.Evolutions.SUN then
		return { "Sun Stone" }
	elseif evoMethod == PokemonData.Evolutions.LEAF_SUN then
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

-- moveType required for Hidden Power tracked type
function Utils.netEffectiveness(move, moveType, comparedTypes)
	local effectiveness = 1.0

	-- If type is unknown or typeless
	if move.name == "Future Sight" or move.name == "Doom Desire" or moveType == PokemonData.Types.UNKNOWN or moveType == Constants.BLANKLINE then
		return 1.0
	end

	-- If move has no power, check for ineffectiveness by type first, then return 1.0 if ineffective cases not present
	if move.power == Constants.NO_POWER then
		if move.category ~= MoveData.Categories.STATUS then
			if moveType == PokemonData.Types.NORMAL and (comparedTypes[1] == PokemonData.Types.GHOST or comparedTypes[2] == PokemonData.Types.GHOST) then
				return 0.0
			elseif moveType == PokemonData.Types.FIGHTING and (comparedTypes[1] == PokemonData.Types.GHOST or comparedTypes[2] == PokemonData.Types.GHOST) then
				return 0.0
			elseif moveType == PokemonData.Types.PSYCHIC and (comparedTypes[1] == PokemonData.Types.DARK or comparedTypes[2] == PokemonData.Types.DARK) then
				return 0.0
			elseif moveType == PokemonData.Types.GROUND and (comparedTypes[1] == PokemonData.Types.FLYING or comparedTypes[2] == PokemonData.Types.FLYING) then
				return 0.0
			elseif moveType == PokemonData.Types.GHOST and (comparedTypes[1] == PokemonData.Types.NORMAL or comparedTypes[2] == PokemonData.Types.NORMAL) then
				return 0.0
			end
		end
		return 1.0
	end

	-- Check effectiveness against each opposing type
	for _, type in ipairs(comparedTypes) do
		local effectiveValue = MoveData.TypeToEffectiveness[moveType][type]
		if effectiveValue ~= nil then
			effectiveness = effectiveness * effectiveValue
		end
	end

	return effectiveness
end

-- moveType required for Hidden Power tracked type
function Utils.isSTAB(move, moveType, comparedTypes)
	if move == nil or comparedTypes == nil or move.power == Constants.NO_POWER then
		return false
	end

	-- Check if the move's type matches any of the 'types' provided
	for _, type in ipairs(comparedTypes) do
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
		if move.id ~= 0 and moveName == MoveData.Moves[move.id].name then
			return true
		end
	end
	return false
end

-- Checks if the pokemon is ready to evolve based on level only
function Utils.isReadyToEvolveByLevel(evoMethod, level)
	evoMethod = evoMethod or PokemonData.Evolutions.NONE

	if evoMethod == PokemonData.Evolutions.NONE then
		return false
	end

	evoMethod = string.match(evoMethod, "(.-)/") -- Handle condition of "37/WTR" with regex
	evoMethod = tonumber(evoMethod, 10) -- becomes nil if not a decimal number

	return evoMethod ~= nil and (level + 1) >= evoMethod
end

-- Returns the text color for PC heal tracking
function Utils.getCenterHealColor()
	local currentCount = Tracker.Data.centerHeals
	if Options["PC heals count downward"] then
		-- Counting downwards
		if currentCount < 1 then
			return Theme.COLORS["Negative text"]
		elseif currentCount < 6 then
			return Theme.COLORS["Intermediate text"]
		else
			return Theme.COLORS["Default text"]
		end
	else
		-- Counting upwards
		if currentCount < 5 then
			return Theme.COLORS["Default text"]
		elseif currentCount < 10 then
			return Theme.COLORS["Intermediate text"]
		else
			return Theme.COLORS["Negative text"]
		end
	end
end

function Utils.truncateRomsFolder(folder)
	if folder then
		if string.len(folder) > 12 then
			return "..." .. string.sub(folder, string.len(folder) - 12)
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
	if GameSettings.game == 1 then -- Ruby/Sapphire don't have ptr
		return GameSettings.gSaveBlock1
	end
	return Memory.readdword(GameSettings.gSaveBlock1ptr)
end

function Utils.getEncryptionKey(size)
	-- Gets the current game's encryption key
	-- Size is the number of bytes to return an encryption key of
	if GameSettings.game == 1 then -- Ruby/Sapphire don't have an encryption key
		return nil
	end
	local saveBlock2addr = Memory.readdword(GameSettings.gSaveBlock2ptr)
	return Memory.read(saveBlock2addr + GameSettings.EncryptionKeyOffset, size)
end

function Utils.fileExists(path)
	local file = io.open(path,"r")
	if file ~= nil then io.close(file) return true else return false end
end

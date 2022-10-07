Utils = {}

-- gets bits from least significant to most
function Utils.getbits(value, startIndex, numBits)
	return bit.rshift(value, startIndex) % bit.lshift(1, numBits)
end

function Utils.addhalves(value)
	local b = Utils.getbits(value, 0, 16)
	local c = Utils.getbits(value, 16, 16)
	return b + c
end

-- If the `condition` is true, the value in `T` is returned, else the value in `F` is returned
function Utils.inlineIf(condition, T, F)
	if condition then return T else return F end
end

function Utils.printDebug(message)
	if message ~= Utils.prevMessage then
		print(message)
		Utils.prevMessage = message
	end
end

function Utils.centerTextOffset(text, charSize, width)
	charSize = charSize or 4
	width = width or (Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2))
	return (width - (charSize * text:len())) / 2
end

function Utils.randomPokemonID()
	local pokemonID = math.random(PokemonData.totalPokemon - 25)
	if pokemonID > 251 then
		pokemonID = pokemonID + 25
	end
	return pokemonID
end

-- Returns '1.1' if positive nature, '0.9' if negative nature, and '1' otherwise (if neutral nature)
function Utils.getNatureMultiplier(stat, nature)
	if nature % 6 == 0 then return 1 end

	if stat == "atk" then
		if nature < 5 then return 1.1 end
		if nature % 5 == 0 then return 0.9 end
	end
	if stat == "def" then
		if nature > 4 and nature < 10 then return 1.1 end
		if nature % 5 == 1 then return 0.9 end
	end
	if stat == "spe" then
		if nature > 9 and nature < 15 then return 1.1 end
		if nature % 5 == 2 then return 0.9 end
	end
	if stat == "spa" then
		if nature > 14 and nature < 20 then return 1.1 end
		if nature % 5 == 3 then return 0.9 end
	end
	if stat == "spd" then
		if nature > 19 then return 1.1 end
		if nature % 5 == 4 then return 0.9 end
	end

	return 1
end

-- Returns a slightly darkened color
function Utils.calcShadowColor(color, scale)
	scale = scale or 0.92
	local color_hexval = (color - 0xFF000000)

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

-- Calculates the contrast ratio of two colors using the procedure defined in the W3C specification
-- https://www.w3.org/WAI/WCAG21/Techniques/general/G18.html#tests
function Utils.calculateContrastRatio(color1, color2)
	local function getRelativeLuminance(color)
		-- Convert the 8-digit hex to sRGB
		local hex = string.sub(string.format("%#x", color), 5)
		local sR = tonumber(hex:sub(1,2), 16) / 255
		local sG = tonumber(hex:sub(3,4), 16) / 255
		local sB = tonumber(hex:sub(5,6), 16) / 255

		-- Obtain the luminances from sRGB values
		local lR = Utils.inlineIf(sR <= 0.04045, sR / 12.92, math.pow((sR + 0.055) / 1.055, 2.4))
		local lG = Utils.inlineIf(sG <= 0.04045, sG / 12.92, math.pow((sG + 0.055) / 1.055, 2.4))
		local lB = Utils.inlineIf(sB <= 0.04045, sB / 12.92, math.pow((sB + 0.055) / 1.055, 2.4))

		return 0.2126 * lR + 0.7152 * lG + 0.0722 * lB
	end

	local L1 = getRelativeLuminance(color1)
	local L2 = getRelativeLuminance(color2)

	if L1 > L2 then
		return (L1 + 0.05) / (L2 + 0.05)
	else
		return (L2 + 0.05) / (L1 + 0.05)
	end
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
	if not PokemonData.isValid(pokemonID) or level == nil then
		return "Moves", nil, nil
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

	local header = "Moves " .. movesLearned .. "/" .. #allMoveLevels
	if foundNextMove then
		local nextMoveSpacing = 13 + string.len(header) * 4 + string.len(tostring(movesLearned)) + string.len(tostring(#allMoveLevels))
		header = header .. " (" .. nextMoveLevel .. ")"
		return header, nextMoveLevel, nextMoveSpacing
	else
		return header, nil, nil
	end
end

function Utils.getDetailedEvolutionsInfo(evoMethod)
	if evoMethod == nil or evoMethod == PokemonData.Evolutions.NONE then
		return { Constants.BLANKLINE }
	end

	if evoMethod == PokemonData.Evolutions.FRIEND then
		if Program.friendshipRequired ~= nil and Program.friendshipRequired > 1 then
			return { Program.friendshipRequired .. " Friendship" }
		else
			return { "220 Friendship" }
		end
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
	if moveType == nil or comparedTypes == nil or comparedTypes == {} then
		return 1.0
	end

	-- If the move type is typeless or unknown, effectiveness check is ignored
	if MoveData.IsTypelessMove[move.id] or moveType == PokemonData.Types.UNKNOWN or moveType == Constants.BLANKLINE then
		return 1.0
	end

	-- Most status moves also ignore type effectiveness. Examples: Growl, Confuse Ray, Sand-Attack
	if move.category == MoveData.Categories.STATUS then
		-- Some status moves care about immunities. Examples: Toxic, Thunder Wave, Leech Seed
		if MoveData.StatusMovesWillFail[move.id] ~= nil and (MoveData.StatusMovesWillFail[move.id][comparedTypes[1]] or MoveData.StatusMovesWillFail[move.id][comparedTypes[2]]) then
			return 0.0
		else
			return 1.0
		end
	end

	-- Check effectiveness against each opposing type
	local total = 1.0
	local effectiveValue = MoveData.TypeToEffectiveness[moveType][comparedTypes[1]]
	if effectiveValue ~= nil then
		total = total * effectiveValue
	end
	if comparedTypes[2] ~= comparedTypes[1] then
		effectiveValue = MoveData.TypeToEffectiveness[moveType][comparedTypes[2]]
		if effectiveValue ~= nil then
			total = total * effectiveValue
		end
	end

	-- Moves that calculate specific damage amounts still check immunities, but otherwise ignore type-effectiveness
	-- Examples: Fissure, Mirror Coat, Dragon Rage, Bide, Endeavor
	if move.power == "0" and total ~= 0.0 then
		return 1.0
	else
		return total
	end
end

-- moveType required for Hidden Power tracked type
function Utils.isSTAB(move, moveType, comparedTypes)
	if move == nil or comparedTypes == nil or move.power == "0" then
		return false
	end

	-- If type is unknown or typeless
	if MoveData.IsTypelessMove[move.id] or moveType == PokemonData.Types.UNKNOWN then
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
function Utils.calculateWeightBasedDamage(movePower, weight)
	-- For randomized move powers, unsure what these two moves get changed to
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

-- For Flail & Reversal. Decompiled code scales fraction to 48, which is why its used here.
function Utils.calculateLowHPBasedDamage(movePower, currentHP, maxHP)
	-- For randomized move powers, unsure what these two moves get changed to
	local fractionHP = currentHP * 48 / maxHP

	if fractionHP <= 1 then
		return "200"
	elseif fractionHP <= 4 then
		return "150"
	elseif fractionHP <= 9 then
		return "100"
	elseif fractionHP <= 16 then
		return "80"
	elseif fractionHP <= 32 then
		return "40"
	else
		return "20"
	end
end

-- For Water Spout & Eruption
function Utils.calculateHighHPBasedDamage(movePower, currentHP, maxHP)
	if movePower == ">HP" then
		movePower = "150"
	end
	local basePower = math.max(tonumber(movePower) * currentHP / maxHP, 1)
	local roundedPower = math.floor(basePower + 0.5)
	return tostring(roundedPower)
end

-- For Return & Frustration
-- Only shows if close to max strength; won't return exact values to avoid revealing friendship amount
function Utils.calculateFriendshipBasedDamage(movePower, friendship)
	if movePower ~= ">FR" and movePower ~= "<FR" then
		return movePower
	end

	if friendship == nil or friendship < 0 then
		friendship = 0
	elseif friendship > 255 then
		friendship = 255
	end

	-- Invert if based on unhappiness
	if movePower == "<FR" then
		friendship = 255 - friendship
	end

	local basePower = math.max(friendship / 2.5, 1) -- minimum of 1

	-- Don't reveal calculated power if not near max power (100-102)
	if basePower < 100 then
		return movePower
	else
		return tostring(math.floor(basePower)) -- remove decimals
	end
end

function Utils.calculateWeatherBall(moveType, movePower)
	if not Battle.inBattle then
		return moveType, movePower
	end

	local weatherIds = {
		[1] = "Rain", [5] = "Rain",
		[8] = "Sandstorm", [24] = "Sandstorm",
		[32] = "Harsh sunlight", [96] = "Harsh sunlight",
		[128] = "Hail"
	}
	local battleWeather = Memory.readword(GameSettings.gBattleWeather)
	local currentWeather = weatherIds[battleWeather]

	if currentWeather ~= nil then
		if currentWeather == "Rain" then
			moveType = PokemonData.Types.WATER
		elseif currentWeather == "Sandstorm" then
			moveType = PokemonData.Types.ROCK
		elseif currentWeather == "Harsh sunlight" then
			moveType = PokemonData.Types.FIRE
		elseif currentWeather == "Hail" then
			moveType = PokemonData.Types.ICE
		end
		movePower = tonumber(movePower) * 2
	end

	return moveType, tostring(movePower)
end

-- Returns a number between 0 and 1, where 1 is best possible IVs and 0 is no IVs
function Utils.estimateIVs(pokemon)
	if pokemon == nil or pokemon.pokemonID == 0 then
		return 0
	end

	local atk = pokemon.stats.atk * Utils.getNatureMultiplier("atk", pokemon.nature)
	local def = pokemon.stats.def * Utils.getNatureMultiplier("def", pokemon.nature)
	local spa = pokemon.stats.spa * Utils.getNatureMultiplier("spa", pokemon.nature)
	local spd = pokemon.stats.spd * Utils.getNatureMultiplier("spd", pokemon.nature)
	local spe = pokemon.stats.spe * Utils.getNatureMultiplier("spe", pokemon.nature)

	local sumStats = pokemon.stats.hp + atk + def + spa + spd + spe - pokemon.level - 35

	-- Result is between 0 and 96, with 48 being average (effectively identical to its BST), and 96 being best possible result
	local ivGuess = (sumStats * 50 / pokemon.level) - PokemonData.Pokemon[pokemon.pokemonID].bst
	local percentageResult = ivGuess / 96

	if percentageResult < 0 then
		return 0
	elseif percentageResult > 1 then
		return 1
	else
		return percentageResult
	end
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

	evoMethod = tonumber(evoMethod:match("%d+")) -- Becomes nil if there's no numbers found

	return evoMethod ~= nil and (level + 1) >= evoMethod
end

-- Checks if the player has a usable stone in their bag to evolve the pokémon
function Utils.isReadyToEvolveByStone(evoMethod)
	evoMethod = evoMethod or PokemonData.Evolutions.NONE

	if evoMethod == PokemonData.Evolutions.NONE then
		return false
	end

	for itemID, quantity in pairs(Program.GameData.evolutionStones) do
		-- Check through the possible evolutions with the stones available
		if quantity > 0 then
			-- Special check for the level/water stone evos
			if itemID == 97 and evoMethod:match("(WTR)") ~= nil then
				return true
			end
			for _, possibleEvolution in pairs(MiscData.EvolutionStones[itemID].evolutions) do
				if possibleEvolution == evoMethod then
					return true
				end
			end
		end
	end

	return false
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

function Utils.getWordWrapLines(str, limit)
	if str == nil or str == "" then return {} end
	limit = limit or 72

	local firstSpace = str:find("(%s+)()(%S+)()")
	if firstSpace == nil then return { str } end

	local lines = {}
	local here = 1
	lines[1] = string.sub(str, 1, firstSpace - 1)  -- Put the first word of the string in the first index of the table.

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
		local dataString = Pickle.pickle(table)

		--append a trailing \n if one is absent
		if dataString:sub(-1) ~= "\n" then dataString = dataString .. "\n" end
		for dataLine in dataString:gmatch("(.-)\n") do
			file:write(dataLine)
			file:write("\n")
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
			tableData = Pickle.unpickle(dataString)
		end
		file:close()
	end

	return tableData
end

-- Returns a table that contains an entry for each line from a file
function Utils.readLinesFromFile(filename)
	local lines = {}

	local file = io.open(filename, "r")
	if file ~= nil then
		local fileContents = file:read("*a")
		if fileContents ~= nil and fileContents ~= "" then
			for line in fileContents:gmatch("([^\r\n]+)\r?\n") do
				if line ~= nil then
					table.insert(lines, line)
				end
			end
		end
		file:close()
	end

	return lines
end

--sets the form location relative to the game window
--this function does what the built in forms.setlocation function supposed to do
--currently that function is bugged and should be fixed in 2.9
function Utils.setFormLocation(handle, x, y)
	if handle == nil then return end
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

function Utils.getGameStat(statIndex)
	-- Reads the game stat stored at statIndex in memory
	-- https://github.com/pret/pokefirered/blob/master/include/constants/game_stat.h
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local gameStatsAddr = saveBlock1Addr + GameSettings.gameStatsOffset

	local gameStatValue = Memory.readdword(gameStatsAddr + statIndex * 0x4)

	local key = Utils.getEncryptionKey(4) -- Want a 32-bit key
	if key ~= nil then
		gameStatValue = bit.bxor(gameStatValue, key)
	end

	return gameStatValue
end

function Utils.getWorkingDirectory()
	if Main.Directory ~= nil then
		return Main.Directory .. "/"
	else
		return ""
	end
end

function Utils.extractFolderNameFromPath(path)
	if path == nil or path == "" then return "" end

	local folderStartIndex = path:match("^.*()[\\/]") -- path to folder
	if folderStartIndex ~= nil then
		local foldername = path:sub(folderStartIndex + 1)
		if foldername ~= nil then
			return foldername
		end
	end

	return ""
end

function Utils.extractFileNameFromPath(path)
	if path == nil or path == "" then return "" end

	local slashpattern = Utils.inlineIf(Main.OS == "Windows", "^.*()\\", "^.*()/")
	local nameStartIndex = path:match(slashpattern) -- path to file
	local nameEndIndex = path:match("^.*()%.") -- file extension
	if nameStartIndex ~= nil and nameEndIndex ~= nil then
		local filename = path:sub(nameStartIndex + 1, nameEndIndex - 1)
		if filename ~= nil then
			return filename
		end
	end

	return ""
end

function Utils.extractFileExtensionFromPath(path)
	if path == nil or path == "" then return "" end

	local extStartIndex = path:match("^.*()%.") -- file extension
	if extStartIndex ~= nil then
		local extension = path:sub(extStartIndex + 1)
		if extension ~= nil then
			return extension:lower()
		end
	end

	return ""
end

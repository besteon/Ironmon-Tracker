Utils = {}

-- Bitwise AND operation
function Utils.bit_and(value1, value2)
	return Utils.bit_oper(value1, value2, 4)
end

-- Bitwise OR operation
function Utils.bit_or(value1, value2)
	return Utils.bit_oper(value1, value2, 1)
end

-- Bitwise XOR operation
function Utils.bit_xor(value1, value2)
	return Utils.bit_oper(value1, value2, 3)
end

-- operand: 1 = OR, 3 = XOR, 4 = AND
function Utils.bit_oper(a, b, operand)
	local r, m, s = 0, 2^31, nil
	repeat
		s,a,b = a+b+m, a%m, b%m
		r,m = r + m*operand%(s-a-b), m/2
	until m < 1
	return math.floor(r)
end

-- Shifts bits of 'value', 'n' bits to the left
function Utils.bit_lshift(value, n)
	return math.floor(value) * (2 ^ n)
end

-- Shifts bits of 'value', 'n' bits to the right
function Utils.bit_rshift(value, n)
	return math.floor(value / (2 ^ n))
end

-- gets bits from least significant to most
function Utils.getbits(value, startIndex, numBits)
	return math.floor(Utils.bit_rshift(value, startIndex) % Utils.bit_lshift(1, numBits))
end

function Utils.generatebitwisemap(value, size)
	local map = {}
	for i=0,size-1, 1 do
		if value % 2 == 1 then
			map[i] = true
		else
			map[i] = false
		end
		if value > 0 then
			value = Utils.bit_rshift(value, 1)
		end
	end
	return map
end

function Utils.addhalves(value)
	local b = Utils.getbits(value, 0, 16)
	local c = Utils.getbits(value, 16, 16)
	return b + c
end

-- Goal is to change from little to big endian, or vice-versa. Likely a better way to do this
function Utils.reverseEndian32(value)
	local a = Utils.bit_and(value, 0xFF000000)
	local b = Utils.bit_and(value, 0x00FF0000)
	local c = Utils.bit_and(value, 0x0000FF00)
	local d = Utils.bit_and(value, 0x000000FF)
	return Utils.bit_lshift(d, 24) + Utils.bit_lshift(c, 8) + Utils.bit_rshift(b, 8) + Utils.bit_rshift(a, 24)
end

-- If the `condition` is true, the value in `T` is returned, else the value in `F` is returned
function Utils.inlineIf(condition, T, F)
	if condition then return T else return F end
end

function Utils.printDebug(message, ...)
	if ... ~= nil then
		message = string.format(message, ...)
	end
	if message ~= Utils.prevMessage then
		print(message)
		Utils.prevMessage = message
	end
end

-- Alters the string by changing the first character to uppercase
function Utils.firstToUpper(str)
	if str == nil or str == "" then return str end
	str = str:gsub("^%l", Utils.toUpperUTF8)
	return str
end

-- Alters the string by changing the first character of each word to uppercase
function Utils.firstToUpperEachWord(str)
	if str == nil or str == "" then return str end
	str = string.gsub(" " .. str, "[%s%.%-]%l", Utils.toUpperUTF8):sub(2)
	return str
end

function Utils.split(s, delimiter, trimWhitespace)
	local result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		if trimWhitespace then
			match = match:gsub("^%s*(.-)%s*$", "%1")
		end
		table.insert(result, match)
	end
	return result
end

-- Format "START" as "Start", and "a" as "A"
function Utils.formatControls(gbaButtons)
	local controlCombination = ""
	for txtInput in string.gmatch(gbaButtons or "", '([^,%s]+)') do
		controlCombination = controlCombination .. txtInput:sub(1,1):upper() .. txtInput:sub(2):lower() .. ", "
	end
	return controlCombination:sub(1, -3) or ""
end

function Utils.formatTime(numSeconds)
	local sec = numSeconds % 60
	local min = math.floor(numSeconds / 60) % 60
	local hour = math.floor(numSeconds / 3600) % 10000 -- Cutoff of 10000 to handle glitches with time diffs (if any)
	if hour > 0 then
		return string.format("%d:%02d:%02d", hour, min, sec)
	else
		return string.format("%02d:%02d", min, sec)
	end
end

-- Returns an offset that will center-align the given text based on a specified area's width
function Utils.getCenteredTextX(text, areaWidth)
	areaWidth = areaWidth or Constants.SCREEN.RIGHT_GAP
	local textSize = Utils.calcWordPixelLength(text or "")
	return math.floor(math.max((areaWidth - textSize) / 2, 0))
end

function Utils.centerTextOffset(text, charSize, width)
	charSize = charSize or 4
	width = width or (Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2))
	return (width - (charSize * text:len())) / 2
end

function Utils.calcWordPixelLength(text)
	if text == nil or text == "" or Utils.startsWithJapaneseChineseChar(text) then return 0 end
	local pattern = "."
	if Main.supportsSpecialChars then
		---@diagnostic disable-next-line: undefined-global, undefined-field
		pattern = utf8.charpattern
	end
	local totalLength = 0
	for c in text:gmatch(pattern) do
		totalLength = totalLength + Constants.charWidth(c) + 1
	end
	return totalLength - 1 -- remove trailing space-pixel
end

-- Accepts a number, positive or negative and with/without fractions, and returns a string formatted as "12,345.6789"
function Utils.formatNumberWithCommas(number)
	local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

	-- reverse the int-string and append a comma to all blocks of 3 digits
	int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

-- Replacement for string.format() that works with UTF8 special characters
function Utils.formatUTF8(format, ...)
	if Main.emulator == Main.EMU.BIZHAWK28 then
		-- Doesn't work in Lua 5.1
		return string.format(format, ...)
	end
	local args, strings, pos = {...}, {}, 0
	for spec in format:gmatch'%%.-([%a%%])' do
		pos = pos + 1
		local s = args[pos]
		if spec == 's' and type(s) == 'string' and s ~= '' then
			table.insert(strings, s)
			---@diagnostic disable-next-line: undefined-global
			args[pos] = '\1'..('\2'):rep(utf8.len(s)-1) -- utf8.len required to properly size utf-8 chars
		end
	end
	return (
		---@diagnostic disable-next-line: deprecated
		format:format(table.unpack(args))
			:gsub('\1\2*', function() return table.remove(strings, 1) end)
	)
end

-- Safely formats the text and encodes any special characters (if incompatible with the emulator)
function Utils.formatSpecialCharacters(text)
	if text == nil or text == "" then return "" end

	-- For each known special character, attempt to replace it
	for _, c in pairs(Constants.CharCategories.Special) do
		if string.find(text, c, 1, true) ~= nil then
			text = text:gsub(c, Constants.getC(c))
		end
	end

	return text
end

function Utils.toUpperUTF8(str)
	local toUpperPattern = string.format("[%s]*", table.concat(Constants.CharCategories.ToUpper))
	str = str or ""
	str = str:upper():gsub(toUpperPattern, function(c) return Constants.charToCategory(c, "upper") end)
	return str
end

function Utils.toLowerUTF8(str)
	local toLowerPattern = string.format("[%s]*", table.concat(Constants.CharCategories.ToLower))
	str = str or ""
	str = str:lower():gsub(toLowerPattern, function(c) return Constants.charToCategory(c, "lower") end)
	return str
end

function Utils.containsText(text, searchString, ignoreAccentedChars)
	if text == nil or text == "" or searchString == nil then
		return false
	end
	text = Utils.toLowerUTF8(text)
	searchString = Utils.toLowerUTF8(searchString)

	if ignoreAccentedChars then
		local plainPattern = string.format("[%s]*", table.concat(Constants.CharCategories.Plain))
		text = text:gsub(plainPattern, function(c) return Constants.charToCategory(c, "plain") end)
		searchString = searchString:gsub(plainPattern, function(c) return Constants.charToCategory(c, "plain") end)
	end

	-- Check whole word for matches, not just the start
	return text:find(searchString, 1, true) ~= nil
end

-- Checks if the text starts with a Japanese or Chinese character. Only works on Lua 5.4+
function Utils.startsWithJapaneseChineseChar(text)
	if text == nil or not Main.supportsSpecialChars then
		return false
	end

	---@diagnostic disable-next-line: err-esc
	local pattern = "^[\u{3040}-\u{30ff}\u{3400}-\u{4dbf}\u{4e00}-\u{9fff}\u{f900}-\u{faff}\u{ff66}-\u{ff9f}]"
	return string.match(text, pattern) ~= nil
end

-- Encodes texts so that it's safe for the Settings.ini file (new lines, etc). encode = true, or false for decode
function Utils.encodeDecodeForSettingsIni(text, doEncode)
	if text == nil or text == "" then return "" end

	local charsToEncode = {
		{ raw = "\n", encoded = "\\n", },
		{ raw = "\r", encoded = "\\r", },
	}

	for _, char in pairs(charsToEncode) do
		if doEncode then
			text = text:gsub(char.raw, char.encoded)
		else
			text = text:gsub(char.encoded, char.raw)
		end
	end

	return text
end

--- Shortens text by removing characters from the end until its no more than pixelWidth in size
--- @param text string The text to be shortened (if able)
--- @param pixelWidth number The maximum width in pixels the text can be
--- @param appendEllipsis boolean? If true and text gets shortened, ellipsis will be added to the end
--- @return string
function Utils.shortenText(text, pixelWidth, appendEllipsis)
	local size = Utils.calcWordPixelLength(text)
	if size <= pixelWidth then
		return text
	end
	local ellipsis = "..."
	if appendEllipsis then
		pixelWidth = pixelWidth - Utils.calcWordPixelLength(ellipsis)
	end
	-- Remove one character at a time
	local maxIteration = 9999
	while size > pixelWidth and maxIteration > 0 do
		text = text:sub(1, -2)
		size = Utils.calcWordPixelLength(text)
		maxIteration = maxIteration - 1 -- Safety precaution to prevent infinite loops / freezing
	end
	if appendEllipsis then
		text = text .. ellipsis
	end
	return text
end

-- Searches `wordlist` for the closest matching `word` based on Levenshtein distance. Returns: key, result
-- If the minimum distance is greater than the `threshold`, the original 'word' is returned and key is nil
-- https://stackoverflow.com/questions/42681501/how-do-you-make-a-string-dictionary-function-in-lua
function Utils.getClosestWord(word, wordlist, threshold)
	if word == nil or word == "" then return word end
	threshold = threshold or 3
	local function min(a, b, c) return math.min(math.min(a, b), c) end
	local function matrix(row, col)
		local m = {}
		for i = 1,row do
			m[i] = {}
			for j = 1,col do m[i][j] = 0 end
		end
		return m
	end
	local function lev(strA, strB)
		local M = matrix(#strA + 1, #strB + 1)
		local cost
		local row, col = #M, #M[1]
		for i = 1, row do M[i][1] = i - 1 end
		for j = 1, col do M[1][j] = j - 1 end
		for i = 2, row do
			for j = 2, col do
				if (strA:sub(i-1, i-1) == strB:sub(j-1, j-1)) then cost = 0
				else cost = 1
				end
				M[i][j] = min(M[i-1][j] + 1, M[i][j-1] + 1, M[i-1][j-1] + cost)
			end
		end
		return M[row][col]
	end
	local closestDistance = -1
	local closestWordKey
	for key, val in pairs(wordlist) do
		local levRes = lev(word, val)
		if levRes < closestDistance or closestDistance == -1 then
			closestDistance = levRes
			closestWordKey = key
		end
	end
	if closestDistance <= threshold then return closestWordKey, wordlist[closestWordKey]
	else return nil, word
	end
end

-- Creates a popup Bizhawk form at optional relative location (x,y); returns the created form handle id
function Utils.createBizhawkForm(title, width, height, x, y, onCloseFunc, blockInput)
	title = title or "Form"
	width = width or 600
	height = height or 600
	x = x or 100
	y = y or 50
	blockInput = (blockInput == nil) or (blockInput == true) -- default to true

	-- By default, disable mouse inputs and resume them when the prompt closes
	-- If a close func is provided, the caller needs to manage disabling/enabling mouse inputs instead
	if onCloseFunc == nil then
		Input.allowMouse = false
		onCloseFunc = Utils.closeBizhawkForm
	end

	Program.destroyActiveForm()
	Input.resumeMouse = false -- closing any active form resumes inputs, which we don't want yet
	local form = forms.newform(width, height, title, onCloseFunc)
	Program.activeFormId = form
	Utils.setFormLocation(form, x, y)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local property = "BlocksInputWhenFocused"
		if (forms.getproperty(form, property) or "") ~= "" then
			forms.setproperty(form, property, blockInput)
		end
	end

	return form
end

function Utils.closeBizhawkForm(form)
	form = form or Program.activeFormId
	client.unpause()
	forms.destroy(form)
	Program.activeFormId = 0
	Input.resumeMouse = true
end

function Utils.randomPokemonID()
	local pokemonID = math.random(PokemonData.totalPokemon - 25)
	if pokemonID > 251 then
		pokemonID = pokemonID + 25
	end
	return pokemonID
end

-- Estimated total number of trainers (ids) found from log files
function Utils.randomTrainerID()
	if GameSettings.game == 1 then -- Game #: Ruby / Sapphire
		return math.random(693)
	elseif GameSettings.game == 2 then -- Game #: Emerald
		return math.random(854)
	elseif GameSettings.game == 3 then -- Game #: Fire Red / Leaf Green
		return math.random(742)
	end
	return 0
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

	local r = Utils.bit_rshift(color_hexval, 16)
	local g = Utils.bit_rshift(Utils.bit_and(color_hexval, 0x00FF00), 8)
	local b = Utils.bit_and(color_hexval, 0x0000FF)

	r = math.max(r * scale, 0)
	g = math.max(g * scale, 0)
	b = math.max(b * scale, 0)

	-- build color with new hex values
	color_hexval = Utils.bit_lshift(r, 16) + Utils.bit_lshift(g, 8) + b
	return (0xFF000000 + color_hexval)
end

-- scale is a value between 0 and 1; 0 doesn't alter the color at all, and 1 is pure grayscale (no saturation)
function Utils.calcGrayscale(color, scale)
	scale = scale or 0.80
	local color_hexval = (color - 0xFF000000)
	local r = Utils.bit_rshift(color_hexval, 16)
	local g = Utils.bit_rshift(Utils.bit_and(color_hexval, 0x00FF00), 8)
	local b = Utils.bit_and(color_hexval, 0x0000FF)
	local gray = 0.2989 * r + 0.5870 * g + 0.1140 * b -- CCIR 601 spec weights

	r = math.max(gray * scale + r * (1 - scale), 0)
	g = math.max(gray * scale + g * (1 - scale), 0)
	b = math.max(gray * scale + b * (1 - scale), 0)

	color_hexval = Utils.bit_lshift(r, 16) + Utils.bit_lshift(g, 8) + b
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
		local lR = Utils.inlineIf(sR <= 0.04045, sR / 12.92, ((sR + 0.055) / 1.055) ^ 2.4)
		local lG = Utils.inlineIf(sG <= 0.04045, sG / 12.92, ((sG + 0.055) / 1.055) ^ 2.4)
		local lB = Utils.inlineIf(sB <= 0.04045, sB / 12.92, ((sB + 0.055) / 1.055) ^ 2.4)

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

	if not PokemonData.isValid(pokemonID) or level == nil or level == 1 then
		return stars
	end

	-- If nothing has been tracked thus far for this Pokemon, return no stars
	local trackedMoves = Tracker.getMoves(pokemonID)
	if type(trackedMoves[1]) ~= "table" or not MoveData.isValid(trackedMoves[1].id) then
		return stars
	end

	-- For each move, count how many moves this Pokemon at this 'level' has learned already
	local movesLearnedSince = { 0, 0, 0, 0 }
	local allMoveLevels = PokemonData.Pokemon[pokemonID].movelvls[GameSettings.versiongroup]
	for _, lv in pairs(allMoveLevels) do
		for i = 1, 4, 1 do
			local move = trackedMoves[i] or {}
			if lv > (move.level or 1) and lv <= level then
				movesLearnedSince[i] = movesLearnedSince[i] + 1
			end
		end
	end

	-- Determine which moves are the oldest, by ranking them against their levels learnt.
	local moveAgeRank = { 1, 1, 1, 1 }
	for i = 1, 4, 1 do
		local move = trackedMoves[i] or {}
		for moveIndexCompare, moveCompare in pairs(trackedMoves) do
			if i ~= moveIndexCompare then
				if (move.level or 1) > (moveCompare.level or 1) then
					moveAgeRank[i] = moveAgeRank[i] + 1
				end
			end
		end
	end

	-- A move is only star'd if it was possible it has been forgotten
	for i = 1, 4, 1 do
		local move = trackedMoves[i] or {}
		if (move.level or 1) ~= 1 and movesLearnedSince[i] >= moveAgeRank[i] then
			stars[i] = "*"
		end
	end

	return stars
end

-- Move Header format: C/T (N), where C is moves learned so far, T is total number available to learn, and N is the next level the Pokemon learns a move
-- Example: 4/12 (25)
function Utils.getMovesLearnedHeader(pokemonID, level)
	if not PokemonData.isValid(pokemonID) or level == nil then
		return Resources.TrackerScreen.HeaderMoves, nil, nil
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

	local movesText = Resources.TrackerScreen.HeaderMoves
	-- Don't show the asterisk on your own Pokemon
	if not Battle.isViewingOwn and #Tracker.getMoves(pokemonID) > 4 then
		movesText = movesText .. "*"
	end

	local header = string.format("%s %s/%s", movesText, movesLearned, #allMoveLevels)
	if foundNextMove then
		header = header .. " ("
		local nextMoveSpacing = Utils.calcWordPixelLength(header)
		header = header .. nextMoveLevel .. ")"
		return header, nextMoveLevel, nextMoveSpacing
	else
		return header, nil, nil
	end
end

-- Returns a list of evolution details for each possible evo
function Utils.getDetailedEvolutionsInfo(evoMethod)
	evoMethod = evoMethod or PokemonData.Evolutions.NONE

	-- Evolves only by leveling up
	if type(evoMethod) == "string" or type(evoMethod) == "number" then
		local levelFormat = PokemonData.Evolutions.LEVEL.detailed[1]
		return { string.format(levelFormat, evoMethod) }
	end

	if evoMethod == PokemonData.Evolutions.FRIEND then
		local friendFormat = evoMethod.detailed[1]
		local amt
		if Program.GameData.friendshipRequired ~= nil and Program.GameData.friendshipRequired > 1 then
			amt = Program.GameData.friendshipRequired
		else
			amt = 220
		end
		return { string.format(friendFormat, amt) }
	end

	return evoMethod.detailed
end

-- Returns a list of evolution details (shortened text) for a given Pokemon's evolution
function Utils.getShortenedEvolutionsInfo(evoMethod)
	evoMethod = evoMethod or PokemonData.Evolutions.NONE

	-- Evolves only by leveling up
	if type(evoMethod) == "string" or type(evoMethod) == "number" then
		local levelFormat = PokemonData.Evolutions.LEVEL.short[1]
		return { string.format(levelFormat, evoMethod) }
	end

	return evoMethod.short
end

-- Returns the abbreviation (string) for a given Pokemon's evolution
function Utils.getEvoAbbreviation(evoMethod)
	evoMethod = evoMethod or PokemonData.Evolutions.NONE

	-- Evolves only by leveling up, no abbreviation needed
	if type(evoMethod) == "string" or type(evoMethod) == "number" then
		return tostring(evoMethod)
	end

	return evoMethod.abbreviation
end

-- moveType required for Hidden Power tracked type
function Utils.netEffectiveness(move, moveType, comparedTypes)
	if moveType == nil or comparedTypes == nil or comparedTypes == {} then
		return 1.0
	end

	local id = tostring(move.id)

	-- If the move type is typeless or unknown, effectiveness check is ignored
	if MoveData.IsTypelessMove[id] or moveType == PokemonData.Types.UNKNOWN or moveType == Constants.BLANKLINE then
		return 1.0
	end

	-- Most status moves also ignore type effectiveness. Examples: Growl, Confuse Ray, Sand-Attack
	if move.category == MoveData.Categories.STATUS then
		-- Some status moves care about immunities. Examples: Toxic, Thunder Wave, Leech Seed
		if MoveData.StatusMovesWillFail[id] ~= nil and (MoveData.StatusMovesWillFail[id][comparedTypes[1]] or MoveData.StatusMovesWillFail[id][comparedTypes[2]]) then
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
	if (move.power == "0" or move.power == Constants.BLANKLINE) and total ~= 0.0 then
		return 1.0
	else
		return total
	end
end

-- moveType required for Hidden Power tracked type
function Utils.isSTAB(move, moveType, comparedTypes)
	if move == nil or comparedTypes == nil or moveType == PokemonData.Types.UNKNOWN then
		return false
	end

	local id = tostring(move.id)

	-- If move type is typeless or otherwise can't be stab
	if MoveData.IsTypelessMove[id] or move.category == MoveData.Categories.STATUS or move.power == "0" or move.power == Constants.BLANKLINE then
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
	-- For unknown Pokemon such as unidentified ghost pokemon (e.g. Silph Scope required)
	if weight == 0.0 then
		return "0"
	end

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
-- Note: For randomized move powers, unsure what these two moves get changed to
function Utils.calculateLowHPBasedDamage(movePower, currentHP, maxHP)
	 -- Actual game code doesn't use decimals, uses s32
	local fractionHP = math.floor(currentHP * 48 / maxHP)

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
	if not Options["Determine friendship readiness"] or (movePower ~= ">FR" and movePower ~= "<FR") then
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
	if not Battle.inActiveBattle() then
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
	if pokemon == nil or not PokemonData.isValid(pokemon.pokemonID) then
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

function Utils.pokemonHasMove(pokemon, moveId)
	if pokemon == nil or moveId == nil then return false end

	moveId = tonumber(moveId) -- requires moveId is a number, unsure how often it gets sent as a string
	if moveId == nil then return false end

	for _, move in pairs(pokemon.moves) do
		if move.id ~= 0 and move.id ~= nil and moveId == move.id then
			return true
		end
	end
	return false
end

-- Checks if the pokemon is ready to evolve based on level only
function Utils.isReadyToEvolveByLevel(evoMethod, level)
	if type(evoMethod) ~= "string" and type(evoMethod) ~= "number" then
		return false
	end

	if type(evoMethod) ~= "number" then
		evoMethod = tonumber(evoMethod:match("%d+")) -- Becomes nil if there's no numbers found
	end

	return evoMethod ~= nil and (level + 1) >= evoMethod
end

-- Checks if the player has a usable stone in their bag to evolve the pokémon
function Utils.isReadyToEvolveByStone(evoMethod)
	evoMethod = evoMethod or PokemonData.Evolutions.NONE
	-- Check through the possible evolutions with the stones available
	for _, itemID in pairs(evoMethod.evoItemIds or {}) do
		if Program.GameData.Items.EvoStones[itemID] then
			return true
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

-- Gets the current game's encryption key
-- Size is the number of bytes (1/2/4) to return an encryption key of
function Utils.getEncryptionKey(size)
	if GameSettings.game == 1 then -- Ruby/Sapphire don't have an encryption key
		return nil
	end
	local saveBlock2addr = Memory.readdword(GameSettings.gSaveBlock2ptr)
	local address = saveBlock2addr + GameSettings.EncryptionKeyOffset
	if size == 1 then
		return Memory.read8(address)
	elseif size == 2 then
		return Memory.read16(address)
	else
		return Memory.read32(address)
	end
end

-- Reads the game stat stored at statIndex in memory
-- https://github.com/pret/pokefirered/blob/master/include/constants/game_stat.h
function Utils.getGameStat(statIndex)
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local gameStatsAddr = saveBlock1Addr + GameSettings.gameStatsOffset

	local gameStatValue = Memory.readdword(gameStatsAddr + statIndex * 0x4)

	local key = Utils.getEncryptionKey(4) -- Want a 32-bit key
	if key ~= nil then
		gameStatValue = Utils.bit_xor(gameStatValue, key)
	end

	return math.floor(gameStatValue)
end

-- Returns a new list, sorted by their indexKey number (default: 'index' attribute)
function Utils.getSortedList(unorderedList, indexKey)
	indexKey = indexKey or "index"
	local list = {}
	for _, v in pairs(unorderedList) do
		if type(v[indexKey]) == "number" then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a, b) return a[indexKey] < b[indexKey] end)
	return list
end

-- Organizes a list of ordered objects in a row-by-column fashion based on (x,y,w,h) and what page they should display on.
-- Returns total pages
function Utils.gridAlign(orderedList, startX, startY, colSpacer, rowSpacer, listVerticallyFirst, cutoffX, cutoffY)
	listVerticallyFirst = (listVerticallyFirst == true)
	cutoffX = cutoffX or Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
	cutoffY = cutoffY or Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN

	local offsetX, offsetY = 0, 0
	local maxItemSize = 0 -- Used to determine how much space is needed for the next new column or row added

	local currentPage = 1
	local currentPageItems = 0

	for _, button in ipairs(orderedList) do
		if button.includeInGrid == nil or button:includeInGrid() then
			button.dimensions = button.dimensions or {}

			local w, h, extraX, extraY
			w = button.dimensions.width or 40
			h = button.dimensions.height or 40
			extraX = button.dimensions.extraX or 0
			extraY = button.dimensions.extraY or 0

			-- Before adding an item to a page, verify it can fit somewhere; otherwise start a new page
			if listVerticallyFirst then
				-- Check if new height requires starting a new column
				if (startY + offsetY + h) > cutoffY then
					offsetX = offsetX + maxItemSize + colSpacer
					offsetY = 0
					maxItemSize = 0
				end
				-- Check if new width requires starting a new page
				if (startX + offsetX + w) > cutoffX then
					offsetX, offsetY, maxItemSize = 0, 0, 0
					-- Start a new page but only if the current page has items on it
					if currentPageItems ~= 0 then
						currentPage = currentPage + 1
						currentPageItems = 0
					end
				end
			else
				-- Check if new width requires starting a new row
				if (startX + offsetX + w) > cutoffX then
					offsetX = 0
					offsetY = offsetY + maxItemSize + rowSpacer
					maxItemSize = 0
				end
				-- Check if new height requires starting a new page
				if (startY + offsetY + h) > cutoffY then
					offsetX, offsetY, maxItemSize = 0, 0, 0
					-- Start a new page but only if the current page has items on it
					if currentPageItems ~= 0 then
						currentPage = currentPage + 1
						currentPageItems = 0
					end
				end
			end

			-- Only add item to the page if it can fit somewhere; if it can't fit anywhere, exclude it entirely
			if (startY + offsetY + h) <= cutoffY and (startX + offsetX + w) <= cutoffX then
				currentPageItems = currentPageItems + 1

				local x = startX + offsetX + extraX
				local y = startY + offsetY + extraY
				if button.type == Constants.ButtonTypes.POKEMON_ICON then
					button.clickableArea = { x, y + 4, w, h - 4 }
				end
				button.box = { x, y, w, h }
				button.pageVisible = currentPage

				if listVerticallyFirst then
					if w > maxItemSize then
						maxItemSize = w
					end
					offsetY = offsetY + h + rowSpacer
				else
					if h > maxItemSize then
						maxItemSize = h
					end
					offsetX = offsetX + w + colSpacer
				end
			else
				button.pageVisible = -1
			end
		else
			button.pageVisible = -1
		end
	end

	-- Return total pages, but don't include the final page if its empty
	if currentPageItems == 0 and currentPage > 1 then
		return currentPage - 1
	else
		return currentPage
	end
end

function Utils.openBrowserWindow(url, notifyMessage)
	if url == nil or url == "" then return end

	notifyMessage = notifyMessage or "Unable to open browser window. Check Lua Console for link."

	Utils.tempDisableBizhawkSound()

	if Main.OS == "Windows" then
		-- The first parameter is the title of the window, the second is the url
		FileManager.tryOsExecute(string.format('start "" "%s"', url))
	else
		-- TODO: Currently don't have a good way to differentiate between the two Unix systems
		local success = FileManager.tryOsExecute(string.format('open "%s"', url)) -- Mac OSX
		if not success then
			success = FileManager.tryOsExecute(string.format('xdg-open "%s"', url)) -- Linux
			if not success then
				Main.DisplayError(notifyMessage)
				print(string.format("> %s", url))
			end
		end
	end

	Utils.tempEnableBizhawkSound()
end

-- Remembers the setting if Bizhawk sound was enabled/disabled, then turns off Bizhawk sound.
-- Useful anytime a pop-up or prompt appears via Bizhawk, causes loud stuttering noises
function Utils.tempDisableBizhawkSound()
	if not Main.IsOnBizhawk() then return end
	Utils.wasSoundOn = client.GetSoundOn()
	client.SetSoundOn(false)
end

-- Restores the sound setting remembered from tempDisableBizhawkSound()
function Utils.tempEnableBizhawkSound()
	if not Main.IsOnBizhawk() then return end
	if client.GetSoundOn() ~= Utils.wasSoundOn and Utils.wasSoundOn ~= nil then
		client.SetSoundOn(Utils.wasSoundOn)
	end
end

-- Returns true if an update is available (checked via compareFunc (optional), or default); otherwise returns false
function Utils.checkForVersionUpdate(url, currentVersion, versionResponsePattern, compareFunc)
	if url == nil or url == "" or currentVersion == nil or currentVersion == "" or versionResponsePattern == nil or versionResponsePattern == "" then
		return false
	end

	-- Update check not supported on Linux Bizhawk 2.8, Lua 5.1
	if Main.emulator == Main.EMU.BIZHAWK28 and Main.OS ~= "Windows" then
		return false
	end

	local isUpdateAvailable = false

	-- If no comparison function provided, default to a strict not-equals comparison
	if type(compareFunc) ~= "function" then
		compareFunc = function(a, b) return a ~= b end
	end

	Utils.tempDisableBizhawkSound()

	local updatecheckCommand = string.format('curl "%s" --ssl-no-revoke', url)
	local success, responseLines = FileManager.tryOsExecute(updatecheckCommand)
	if success then
		local response = table.concat(responseLines, "\n")

		-- Get version number formatted as [major].[minor]
		local latestVersion = string.match(response or "", versionResponsePattern) or "0"

		if compareFunc(currentVersion, latestVersion) then
			isUpdateAvailable = true
		end
	end

	Utils.tempEnableBizhawkSound()

	return isUpdateAvailable
end

--- Compare two version numbers against each other, checking if the first is newer than the second (version1 > version2)
--- @param version1 string A version number in the format: #.#.#
--- @param version2 string A version number in the format: #.#.#
--- @return boolean isNewer Returns true if version1 is newer (greater) than version2; false otherwise
function Utils.isNewerVersion(version1, version2)
	-- Quickly check the most common outcome
	if version1 == version2 then
		return false
	end

	-- Get the major/minor/patch version numbers
	local major1, minor1, patch1 = string.match(version1, "(%d+)%.(%d+)%.?(%d*)")
	local major2, minor2, patch2 = string.match(version2, "(%d+)%.(%d+)%.?(%d*)")

	-- Convert to numbers such that "05" is less than "8"
	major1 = tonumber(major1 or "") or 0
	minor1 = tonumber(minor1 or "") or 0
	patch1 = tonumber(patch1 or "") or 0
	major2 = tonumber(major2 or "") or 0
	minor2 = tonumber(minor2 or "") or 0
	patch2 = tonumber(patch2 or "") or 0

	-- Major version number has priority over the others, then Minor version number after that
	if major1 > major2 then
		return true
	elseif major1 == major2 then
		if minor1 > minor2 then
			return true
		elseif minor1 == minor2 and patch1 > patch2 then
			return true
		end
	end
	return false
end
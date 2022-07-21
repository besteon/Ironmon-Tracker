Drawing = {}

function Drawing.clearGUI()
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, 0xFF000000, 0xFF000000)
end

function Drawing.drawPokemonIcon(id, x, y)
	id = id or 0
	if id < 0 or id > #PokemonData.Pokemon then
		id = 0 -- Blank Pokemon data/icon
	end

	local extension = ".gif"
	local folderToUse = "pokemon"

	if Options["Pokemon Stadium portraits"] then
		folderToUse = "pokemonStadium"
		y = y + 4
	end

	extension = Constants.PORTAIT_FOLDER_EXTENSIONS[folderToUse]

	gui.drawImage(DATA_FOLDER .. "/images/"..folderToUse.."/" .. id .. extension, x, y, 32, 32)
end

function Drawing.drawTypeIcon(type, x, y)
	if type == nil or type == "" then return end

	gui.drawImage(DATA_FOLDER .. "/images/types/" .. type .. ".png", x, y, 30, 12)
end

--[[
Draws text for the tracker on screen with a shadow effect. Uses the Franklin Gothic Medium family with a 9 point size.
	x, y: integer -> pixel position for the text
	text: string -> the text to output to the screen
	color: string or integer -> the color for the text
	shadowcolor: string or integer -> the color for the shadow effect drawn behind the text
	style: string -> optional; can be regular, bold, italic, underline, or strikethrough
]]
function Drawing.drawText(x, y, text, color, shadowcolor, style)
	gui.drawText(x + 1, y + 1, text, shadowcolor, nil, Constants.FONT.SIZE, Constants.FONT.FAMILY, style)
	gui.drawText(x, y, text, color, nil, Constants.FONT.SIZE, Constants.FONT.FAMILY, style)
end

--[[
Function that will add a space to a number so that the all the hundreds, tens and ones units are aligned if used
with the RIGHT_JUSTIFIED_NUMBERS setting.
	x, y: integer -> pixel position for the text
	number: string | number -> number to draw (stats, move power, pp...)
	spacing: number -> the number of digits the number can hold max; e.g. use 3 for a number that can be up to 3 digits.
		Move power, accuracy, and stats should have a 3 for `spacing`.
		PP should have 2 for `spacing`.
]]
function Drawing.drawNumber(x, y, number, spacing, color, shadowcolor, style)
	local new_spacing = 0

	if Options["Right justified numbers"] then
		new_spacing = (spacing - string.len(tostring(number))) * 5
		if number == Constants.BLANKLINE then new_spacing = 8 end
	end

	Drawing.drawText(x + new_spacing, y, number, color, shadowcolor, style)
end

-- Currently unused
function Drawing.drawTriangleRight(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({ { 4 + x, 4 + y }, { 4 + x, y + size - 4 }, { x + size - 4, y + size / 2 } }, color, color)
end

-- Currently unused
function Drawing.drawTriangleLeft(x, y, size, color)
	gui.drawRectangle(x, y, size, size, color)
	gui.drawPolygon({ { x + size - 4, 4 + y }, { x + size - 4, y + size - 4 }, { 4 + x, y + size / 2 } }, color, color)
end

function Drawing.drawChevron(x, y, width, height, thickness, direction, hasColor)
	color = Theme.COLORS["Default text"]
	local i = 0
	if direction == "up" then
		if hasColor then
			color = Theme.COLORS["Positive text"]
		end
		y = y + height + thickness + 1
		while i < thickness do
			gui.drawLine(x, y - i, x + (width / 2), y - i - height, color)
			gui.drawLine(x + (width / 2), y - i - height, x + width, y - i, color)
			i = i + 1
		end
	elseif direction == "down" then
		if hasColor then
			color = Theme.COLORS["Negative text"]
		end
		y = y + thickness + 2
		while i < thickness do
			gui.drawLine(x, y + i, x + (width / 2), y + i + height, color)
			gui.drawLine(x + (width / 2), y + i + height, x + width, y + i, color)
			i = i + 1
		end
	end
end

-- draws chevrons bottom-up, coloring them if 'intensity' is a value beyond 'max'
-- 'intensity' ranges from -N to +N, where N is twice 'max'; negative intensity are drawn downward
function Drawing.drawChevrons(x, y, intensity, max)
	if intensity == 0 then return end

	local weight = math.abs(intensity)
	local spacing = 2

	for index = 0, max - 1, 1 do
		if weight > index then
			local hasColor = weight > max + index
			Drawing.drawChevron(x, y, 4, 2, 1, Utils.inlineIf(intensity > 0, "up", "down"), hasColor)
			y = y - spacing
		end
	end
end

function Drawing.drawMoveEffectiveness(x, y, value)
	if value == 2 then
		Drawing.drawChevron(x, y + 4, 4, 2, 1, "up", true)
	elseif value == 4 then
		Drawing.drawChevron(x, y + 4, 4, 2, 1, "up", true)
		Drawing.drawChevron(x, y + 2, 4, 2, 1, "up", true)
	elseif value == 0.5 then
		Drawing.drawChevron(x, y, 4, 2, 1, "down", true)
	elseif value == 0.25 then
		Drawing.drawChevron(x, y, 4, 2, 1, "down", true)
		Drawing.drawChevron(x, y + 2, 4, 2, 1, "down", true)
	end
end

function Drawing.drawInputOverlay()
	if not Tracker.Data.isViewingOwn and Input.controller.framesSinceInput < Input.controller.boxVisibleFrames then
		local statKey = Constants.ORDERED_LISTS.STATSTAGES[Input.controller.statIndex]
		local statButton = TrackerScreen.buttons[statKey]
		gui.drawRectangle(statButton.box[1], statButton.box[2], statButton.box[3], statButton.box[4], Theme.COLORS["Intermediate text"], 0x000000)
	end
end

function Drawing.drawButton(button, shadowcolor)
	if button == nil or button.box == nil then return end

	-- Don't draw the button if it's currently not visible
	if button.isVisible ~= nil and not button:isVisible() then
		return
	end

	local x = button.box[1]
	local y = button.box[2]
	local width = button.box[3]
	local height = button.box[4]

	-- First draw a box if
	if button.type == Constants.BUTTON_TYPES.FULL_BORDER or button.type == Constants.BUTTON_TYPES.CHECKBOX or button.type == Constants.BUTTON_TYPES.STAT_STAGE then
		local bordercolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[1]], Theme.COLORS["Upper box border"])
		local fillcolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[2]], Theme.COLORS["Upper box background"])

		-- Draw the box's shadow and the box border
		if shadowcolor ~= nil then
			gui.drawRectangle(x + 1, y + 1, width, height, shadowcolor, fillcolor)
		end
		gui.drawRectangle(x, y, width, height, bordercolor, fillcolor)
	end

	if button.type == Constants.BUTTON_TYPES.FULL_BORDER or button.type == Constants.BUTTON_TYPES.NO_BORDER then
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.BUTTON_TYPES.CHECKBOX then
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + width + 1, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end

		-- Draw a mark if the checkbox button is toggled on
		if button.toggleState ~= nil and button.toggleState then
			gui.drawLine(x + 1, y + 1, x + width - 1, y + height - 1, Theme.COLORS[button.toggleColor])
			gui.drawLine(x + 1, y + height - 1, x + width - 1, y + 1, Theme.COLORS[button.toggleColor])
		end
	elseif button.type == Constants.BUTTON_TYPES.COLORPICKER then
		if button.themeColor ~= nil then
			local hexCodeText = string.upper(string.sub(string.format("%#x", Theme.COLORS[button.themeColor]), 5))
			-- Draw a colored circle with a black border
			gui.drawEllipse(x - 1, y, width, height, 0xFF000000, Theme.COLORS[button.themeColor])
			-- Draw the hex code to the side, and the text label for it
			Drawing.drawText(x + width + 1, y - 2, hexCodeText, Theme.COLORS[button.textColor], shadowcolor)
			Drawing.drawText(x + width + 37, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.BUTTON_TYPES.IMAGE then
		if button.image ~= nil then
			gui.drawImage(button.image, x, y)
		end
	elseif button.type == Constants.BUTTON_TYPES.PIXELIMAGE then
		if button.image ~= nil then
			Drawing.drawImageAsPixels(button.image, x, y, shadowcolor)
		end
	elseif button.type == Constants.BUTTON_TYPES.STAT_STAGE then
		if button.text ~= nil and button.text ~= "" then
			if button.text == Constants.STAT_STATES[2].text then
				y = y - 1 -- Move up the negative stat mark 1px
			end
			Drawing.drawText(x, y - 1, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	end
end

function Drawing.drawPokemonView(pokemon, opposingPokemon)
	if pokemon == nil or pokemon.pokemonID == 0 then
		pokemon = Tracker.getDefaultPokemon()
	elseif not Tracker.Data.hasCheckedSummary then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = pokemon.pokemonID
		defaultPokemon.level = pokemon.level
		pokemon = defaultPokemon
	end

	local pokemonInfo
	if pokemon.pokemonID ~= 0 then
		pokemonInfo = PokemonData.Pokemon[pokemon.pokemonID]
	else
		pokemonInfo = PokemonData.BlankPokemon
	end

	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	local boxHeight = 52

	-- Draw top box
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, 96, boxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])

	Drawing.drawPokemonIcon(pokemon.pokemonID, Constants.SCREEN.WIDTH + 5, -1)
	Drawing.drawTypeIcon(pokemonInfo.type[1], Constants.SCREEN.WIDTH + 6, 33)
	Drawing.drawTypeIcon(pokemonInfo.type[2], Constants.SCREEN.WIDTH + 6, 45)

	local colorbar = Theme.COLORS["Default text"]
	if pokemon.stats.hp == 0 then
		colorbar = Theme.COLORS["Default text"]
	elseif pokemon.curHP / pokemon.stats.hp <= 0.2 then
		colorbar = Theme.COLORS["Negative text"]
	elseif pokemon.curHP / pokemon.stats.hp <= 0.5 then
		colorbar = Theme.COLORS["Intermediate text"]
	end

	-- calculate shadows based on the location of the text (top or bot box)
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	-- Don't show hp values if the pokemon doesn't belong to the player, or if it doesn't exist
	local currentHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, "?", pokemon.curHP)
	local maxHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, "?", pokemon.stats.hp)

	local pkmnStatOffsetX = 36
	local pkmnStatStartY = 5
	local pkmnStatOffsetY = 10
	-- Base Pokémon details
	-- Pokémon name
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY, pokemonInfo.name, Theme.COLORS["Default text"], boxTopShadow)
	-- Settings gear
	Drawing.drawImageAsPixels(Constants.PIXEL_IMAGES.GEAR, Constants.SCREEN.WIDTH + 92, 7, boxTopShadow)
	-- HP
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 1), "HP:", Theme.COLORS["Default text"], boxTopShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + 52, pkmnStatStartY + (pkmnStatOffsetY * 1), currentHP .. "/" .. maxHP, colorbar, boxTopShadow)
	-- Level and evolution
	local levelDetails = "Lv." .. pokemon.level
	local evolutionDetails = " (" .. pokemonInfo.evolution .. ")"
	local evoTextColor = Theme.COLORS["Default text"]

	-- If the evolution is happening soon (next level or friendship is ready, change font color)
	if Tracker.Data.isViewingOwn and Utils.isReadyToEvolveByLevel(pokemonInfo.evolution, pokemon.level) then
		evoTextColor = Theme.COLORS["Positive text"]
	elseif pokemon.friendship >= 220 and pokemonInfo.evolution == PokemonData.Evolutions.FRIEND then
		evolutionDetails = " (SOON)"
		evoTextColor = Theme.COLORS["Positive text"]
	end
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 2), levelDetails .. evolutionDetails, evoTextColor, boxTopShadow)

	-- draw heal-info box
	local infoBoxHeight = 23
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + boxHeight, 96, infoBoxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- If viewing own pokemon, Heals in bag/PokéCenter heals
	if Tracker.Data.isViewingOwn then
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 57, "Heals in Bag:", Theme.COLORS["Default text"], boxTopShadow)
		local healPercentage = math.min(9999, Tracker.Data.healingItems.healing)
		local healCount = math.min(99, Tracker.Data.healingItems.numHeals)
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 67, string.format("%.0f%%", healPercentage) .. " HP (" .. healCount .. ")", Theme.COLORS["Default text"], boxTopShadow)
		
		if (Options["Track PC Heals"]) then
			Drawing.drawText(Constants.SCREEN.WIDTH + 60, 57, "PC Heals:", Theme.COLORS["Default text"], boxTopShadow)
			-- Right-align the PC Heals number
			local healNumberSpacing = (2 - string.len(tostring(Tracker.Data.centerHeals))) * 5 + 75
			Drawing.drawText(Constants.SCREEN.WIDTH + healNumberSpacing, 67, Tracker.Data.centerHeals, Utils.getCenterHealColor(), boxTopShadow)
			
			-- Draw the '+'', '-'', and toggle button for auto PC tracking
			local incBtn = TrackerScreen.buttons.PCHealIncrement
			local decBtn = TrackerScreen.buttons.PCHealDecrement
			gui.drawText(incBtn.box[1] + 1, incBtn.box[2] + 1, incBtn.text, boxTopShadow, nil, 5, Constants.FONT.FAMILY)
			gui.drawText(incBtn.box[1], incBtn.box[2], incBtn.text, Theme.COLORS[incBtn.textColor], nil, 5, Constants.FONT.FAMILY)
			gui.drawText(decBtn.box[1] + 1, decBtn.box[2] + 1, decBtn.text, boxTopShadow, nil, 5, Constants.FONT.FAMILY)
			gui.drawText(decBtn.box[1], decBtn.box[2], decBtn.text, Theme.COLORS[decBtn.textColor], nil, 5, Constants.FONT.FAMILY)

			-- Auto-tracking PC Heals button
			Drawing.drawButton(TrackerScreen.buttons.PCHealAutoTracking, boxTopShadow)
		end
	else
		if Tracker.Data.trainerID ~= nil and pokemon.trainerID ~= nil then
			-- Check if trainer encounter or wild pokemon encounter (trainerID's will match if its a wild pokemon)
			local isWild = Tracker.Data.trainerID == pokemon.trainerID
			local encounterText = Tracker.getEncounters(pokemon.pokemonID, isWild)
			if encounterText > 9999 then encounterText = 9999 end
			if isWild then
				encounterText = "Seen in the wild: " .. encounterText
			else
				encounterText = "Seen on trainers: " .. encounterText
			end
			Drawing.drawText(Constants.SCREEN.WIDTH + 6, 57, encounterText, Theme.COLORS["Default text"], boxTopShadow)
		end
	end

	-- Draw Pokemon's held item and ability
	local abilityStringTop = Constants.BLANKLINE
	local abilityStringBot = Constants.BLANKLINE
	local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)

	if Tracker.Data.isViewingOwn then
		if pokemon.heldItem ~= nil and pokemon.heldItem ~= 0 then
			abilityStringTop = MiscData.Items[pokemon.heldItem]
		end
		if pokemon.abilityId ~= nil and pokemon.abilityId ~= 0 then
			abilityStringBot = MiscData.Abilities[pokemon.abilityId]
		end
	else
		if trackedAbilities[1].id ~= 0 then
			abilityStringTop = MiscData.Abilities[trackedAbilities[1].id] .. " /"
			abilityStringBot = "?"
		end
		if trackedAbilities[2].id ~= 0 then
			abilityStringBot = MiscData.Abilities[trackedAbilities[2].id]
		end
	end
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 3), abilityStringTop, Theme.COLORS["Intermediate text"], boxTopShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), abilityStringBot, Theme.COLORS["Intermediate text"], boxTopShadow)

	-- Draw notepad icon near abilities area, for manually tracking the abilities
	if Tracker.Data.inBattle and not Tracker.Data.isViewingOwn then
		if trackedAbilities[1].id == 0 and trackedAbilities[2].id == 0 then
			Drawing.drawButton(TrackerScreen.buttons.AbilityTracking, boxTopShadow)
		end
	end

	-- draw stat box
	Drawing.drawStatsArea(pokemon, boxTopShadow)

	local movesString = "Move ~  " .. Utils.getMovesLearnedHeader(pokemon.pokemonID, pokemon.level)

	local moveTableHeaderHeightDiff = 13
	local movesBoxStartY = 92
	local moveStartY = movesBoxStartY + 2
	local distanceBetweenMoves = 10
	local moveOffset = 7
	local ppOffset = 82
	local powerOffset = 102
	local accOffset = 126

	-- Draw move headers
	gui.defaultTextBackground(Theme.COLORS["Main background"])
	Drawing.drawText(Constants.SCREEN.WIDTH + moveOffset - 2, moveStartY - moveTableHeaderHeightDiff, movesString, Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + ppOffset, moveStartY - moveTableHeaderHeightDiff, "PP", Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + powerOffset, moveStartY - moveTableHeaderHeightDiff, "Pow", Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + accOffset, moveStartY - moveTableHeaderHeightDiff, "Acc", Theme.COLORS["Header text"], bgHeaderShadow)

	-- Drawing moves
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	-- draw moves box
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, movesBoxStartY, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 46, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	local stars = { "", "", "", "" }
	if not Tracker.Data.isViewingOwn then
		stars = Utils.calculateMoveStars(pokemon.pokemonID, pokemon.level)
	end

	-- Determine which moves to show based on if the tracker is showing the enemy Pokémon or the player's.
	-- If the Pokemon doesn't belong to the player, pull move data from tracked data
	local trackedMoves = Tracker.getMoves(pokemon.pokemonID)
	local moves = {
		MoveData.BlankMove,
		MoveData.BlankMove,
		MoveData.BlankMove,
		MoveData.BlankMove,
	}
	for moveIndex = 1, 4, 1 do
		if Tracker.Data.isViewingOwn then
			if pokemon.moves[moveIndex] ~= nil and pokemon.moves[moveIndex].id ~= 0 then
				moves[moveIndex] = MoveData.Moves[pokemon.moves[moveIndex].id]
			end
		elseif trackedMoves ~= nil then
			 if trackedMoves[moveIndex] ~= nil and trackedMoves[moveIndex].id ~= 0 then
				moves[moveIndex] = MoveData.Moves[trackedMoves[moveIndex].id]
			end
		end
	end

	-- Draw Moves categories, names, and other information
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])

		-- Move category: physical, special, or status effect (and type color?)
	for moveIndex = 1, 4, 1 do
		local currentHiddenPowerCat = MoveData.TypeToCategory[Tracker.Data.currentHiddenPowerType]
		local category = Utils.inlineIf(moves[moveIndex].name == "Hidden Power", currentHiddenPowerCat, moves[moveIndex].category)

		if Options["Show physical special icons"] and category == MoveData.Categories.PHYSICAL then
			Drawing.drawImageAsPixels(Constants.PIXEL_IMAGES.PHYSICAL, Constants.SCREEN.WIDTH + moveOffset, moveStartY + 2 + (distanceBetweenMoves * (moveIndex - 1)), boxBotShadow)
		elseif Options["Show physical special icons"] and category == MoveData.Categories.SPECIAL then
			Drawing.drawImageAsPixels(Constants.PIXEL_IMAGES.SPECIAL, Constants.SCREEN.WIDTH + moveOffset, moveStartY + 2 + (distanceBetweenMoves * (moveIndex - 1)), boxBotShadow)
		end
	end

	-- Move names (longest name is 12 characters?)
	local nameOffset = Utils.inlineIf(Options["Show physical special icons"], 14, moveOffset - 1)
	nameOffset = nameOffset + Utils.inlineIf(Theme.MOVE_TYPES_ENABLED, 0, 5)
	local moveColors = {}
	for moveIndex = 1, 4, 1 do
		table.insert(moveColors, Constants.COLORS.MOVETYPE[moves[moveIndex].type])
	end
	for moveIndex = 1, 4, 1 do
		if moves[moveIndex].name == "Hidden Power" and Tracker.Data.isViewingOwn then
			local hpBtn = TrackerScreen.buttons.HiddenPower
			hpBtn.box[1] = Constants.SCREEN.WIDTH + nameOffset
			hpBtn.box[2] = moveStartY + (distanceBetweenMoves * (moveIndex - 1))
			if not Theme.MOVE_TYPES_ENABLED then
				gui.drawRectangle(hpBtn.box[1] - 3, hpBtn.box[2] + 2, 2, 7, hpBtn.textColor, hpBtn.textColor)
			end
			Drawing.drawText(hpBtn.box[1], hpBtn.box[2] + (hpBtn.box[4] - 12) / 2 + 1, hpBtn.text, Utils.inlineIf(Theme.MOVE_TYPES_ENABLED, hpBtn.textColor, Theme.COLORS["Default text"]), boxBotShadow)
		else
			-- Draw a small colored rectangle showing the color of the move type instead of painting over the text
			if not Theme.MOVE_TYPES_ENABLED and moves[moveIndex].name ~= Constants.BLANKLINE then
				gui.drawRectangle(Constants.SCREEN.WIDTH + nameOffset - 3, moveStartY + 2 + (distanceBetweenMoves * (moveIndex - 1)), 2, 7, moveColors[moveIndex], moveColors[moveIndex])
			end
			Drawing.drawText(Constants.SCREEN.WIDTH + nameOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].name .. stars[moveIndex], Utils.inlineIf(Theme.MOVE_TYPES_ENABLED, moveColors[moveIndex], Theme.COLORS["Default text"]), boxBotShadow)
		end
	end

	-- Move power points
	for moveIndex = 1, 4, 1 do
		local ppText = moves[moveIndex].pp -- Set to move's max PP value
		-- check if any pp has been used and it should be revealed
		if moves[moveIndex].pp ~= Constants.NO_PP then
			if Tracker.Data.isViewingOwn then
				ppText = pokemon.moves[moveIndex].pp
			elseif Options["Count enemy PP usage"] then
				for _, move in pairs(pokemon.moves) do
					if tonumber(move.id) == tonumber(moves[moveIndex].id) then
						ppText = move.pp
					end
				end
			end
		end
		Drawing.drawNumber(Constants.SCREEN.WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), ppText, 2, Theme.COLORS["Default text"], boxBotShadow)
	end

	-- Move attack power
	local stabColors = {}
	for moveIndex = 1, 4, 1 do
		local showStabColor = Tracker.Data.inBattle and Utils.isSTAB(moves[moveIndex], pokemonInfo.type)
		table.insert(stabColors, Utils.inlineIf(showStabColor, Theme.COLORS["Positive text"], Theme.COLORS["Default text"]))
	end
	for moveIndex = 1, 4, 1 do
		local movePower = moves[moveIndex].power
		if Options["Calculate variable damage"] then
			local newPower = movePower
			if movePower == "WT" and Tracker.Data.inBattle and opposingPokemon ~= nil then
				-- Calculate the power of weight moves in battle
				local targetWeight = PokemonData.Pokemon[opposingPokemon.pokemonID].weight
				newPower = Utils.calculateWeightBasedDamage(targetWeight)
			elseif movePower == "<HP" and Tracker.Data.isViewingOwn then
				-- Calculate the power of flail & reversal moves for player only
				newPower = Utils.calculateLowHPBasedDamage(currentHP, maxHP)
			elseif movePower == ">HP" and Tracker.Data.isViewingOwn then
				-- Calculate the power of water spout & eruption moves for the player only
				newPower = Utils.calculateHighHPBasedDamage(currentHP, maxHP)
			else
				newPower = movePower
			end
			Drawing.drawNumber(Constants.SCREEN.WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), newPower, 3, stabColors[moveIndex], boxBotShadow)
		else
			Drawing.drawNumber(Constants.SCREEN.WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), movePower, 3, stabColors[moveIndex], boxBotShadow)
		end
	end

	-- Move accuracy
	for moveIndex = 1, 4, 1 do
		Drawing.drawNumber(Constants.SCREEN.WIDTH + accOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].accuracy, 3, Theme.COLORS["Default text"], boxBotShadow)
	end

	-- Move effectiveness against the opponent
	if Options["Show move effectiveness"] and Tracker.Data.inBattle and opposingPokemon ~= nil then
		for moveIndex = 1, 4, 1 do
			local effectiveness = Utils.netEffectiveness(moves[moveIndex], PokemonData.Pokemon[opposingPokemon.pokemonID].type)
			if effectiveness == 0 then
				Drawing.drawText(Constants.SCREEN.WIDTH + powerOffset - 7, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), "X", Theme.COLORS["Negative text"], boxBotShadow)
			else
				Drawing.drawMoveEffectiveness(Constants.SCREEN.WIDTH + powerOffset - 5, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), effectiveness)
			end
		end
	end

	Drawing.drawBadgeNoteArea(pokemon, boxBotShadow)
end

function Drawing.drawStatsArea(pokemon, shadowcolor)
	local statBoxWidth = 101
	local statOffsetX = Constants.SCREEN.WIDTH + statBoxWidth + 1
	local statOffsetY = 7

	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + statBoxWidth, 5, Constants.SCREEN.RIGHT_GAP - statBoxWidth - 5, 75, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Draw the six primary stats
	for _, statKey in ipairs(Constants.ORDERED_LISTS.STATSTAGES) do
		local natureType = Utils.calcNatureBonus(statKey, pokemon.nature)
		local textColor = Theme.COLORS["Default text"]
		local natureSymbol = ""

		if Tracker.Data.isViewingOwn and natureType == 1 then
			textColor = Theme.COLORS["Positive text"]
			natureSymbol = "+"
		elseif Tracker.Data.isViewingOwn and natureType == -1 then
			textColor = Theme.COLORS["Negative text"]
			natureSymbol = Constants.BLANKLINE
		end

		-- Draw stat label and nature symbol next to it
		Drawing.drawText(statOffsetX, statOffsetY, statKey:upper(), textColor, shadowcolor)
		gui.drawText(statOffsetX + 16, statOffsetY - 1, natureSymbol, textColor, nil, 5, Constants.FONT.FAMILY)

		-- Draw stat battle increases/decreases, stages range from -6 to +6
		if Tracker.Data.inBattle then
			local statStageIntensity = pokemon.statStages[statKey] - 6 -- between [0 and 12], convert to [-6 and 6]
			Drawing.drawChevrons(statOffsetX + 20, statOffsetY + 4, statStageIntensity, 3)
		end

		-- Draw stat value, or the stat tracking box if enemy Pokemon
		if Tracker.Data.isViewingOwn then
			local statValueText = Utils.inlineIf(pokemon.stats[statKey] == 0, Constants.BLANKLINE, pokemon.stats[statKey])
			Drawing.drawNumber(statOffsetX + 25, statOffsetY, statValueText, 3, textColor, shadowcolor)
		else
			Drawing.drawButton(TrackerScreen.buttons[statKey], shadowcolor)
		end
		statOffsetY = statOffsetY + 10
	end

	-- Draw BST
	local bstText = PokemonData.BlankPokemon.bst
	if pokemon.pokemonID ~= 0 then
		bstText = PokemonData.Pokemon[pokemon.pokemonID].bst
	end
	Drawing.drawText(statOffsetX, statOffsetY, "BST", Theme.COLORS["Default text"], shadowcolor)
	Drawing.drawText(statOffsetX + 25, statOffsetY, bstText, Theme.COLORS["Default text"], shadowcolor)

	Drawing.drawInputOverlay()
end

function Drawing.drawBadgeNoteArea(pokemon, shadowcolor)
	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 136, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 19, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	
	for index = 1, 8, 1 do
		local badgeName = "badge" .. index
		local badgeButton = TrackerScreen.buttons[badgeName]
		Drawing.drawButton(badgeButton, shadowcolor)
	end

	-- Draw note boxes, but only for enemy pokemon
	if Tracker.Data.inBattle and not Tracker.Data.isViewingOwn then
		-- Draw original notepad icon at the bottom for taking written notes
		local noteText = Tracker.getNote(pokemon.pokemonID)
		if noteText == "" then
			Drawing.drawButton(TrackerScreen.buttons.NotepadTracking, shadowcolor)
		else
			Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 141, noteText, Theme.COLORS["Default text"], shadowcolor)
			--work around limitation of drawText not having width limit: paint over any spillover
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
			local y = 137
			gui.drawLine(x, y, x, y + 14, Theme.COLORS["Lower box border"])
			gui.drawRectangle(x + 1, y, 12, 14, Theme.COLORS["Main background"], Theme.COLORS["Main background"])
		end
	end
end

function Drawing.drawOptionsScreen()
	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw Settings screen view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + 5, 5, Constants.SCREEN.RIGHT_GAP - 10, Constants.SCREEN.HEIGHT - 10, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Draw all buttons
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	for _, button in pairs(Options.buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
	
	-- Draw Roms folder location, or the notepad icon if it's not set
	local folderText = Utils.truncateRomsFolder(Settings.config.ROMS_FOLDER)
	if folderText ~= "" then
		Drawing.drawText(Options.buttons.romsFolder.box[1] + 54, Options.buttons.romsFolder.box[2], folderText, Theme.COLORS[Options.buttons.romsFolder.textColor], shadowcolor)
	else
		Drawing.drawImageAsPixels(Constants.PIXEL_IMAGES.NOTEPAD, Constants.SCREEN.WIDTH + 60, 7, shadowcolor)
		Drawing.drawText(Options.buttons.romsFolder.box[1] + 65, Options.buttons.romsFolder.box[2], "(Click a file to set)", Theme.COLORS[Options.buttons.romsFolder.textColor], shadowcolor)
	end
end

function Drawing.drawThemeScreen()
	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw Theme screen view box
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + 5, 5, Constants.SCREEN.RIGHT_GAP - 10, Constants.SCREEN.HEIGHT - 10, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	-- Draw all buttons
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])
	for name, button in pairs(Theme.buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

function Drawing.drawInfoScreen()
	if InfoScreen.viewScreen == InfoScreen.SCREENS.POKEMON_INFO then
		-- Only draw valid pokemon data
		local pokemonID = InfoScreen.infoLookup -- pokemonID = 0 is blank move data
		if pokemonID < 1 or pokemonID > #PokemonData.Pokemon then
			Program.state = State.TRACKER
			Program.waitToDrawFrames = 0
			return
		end

		Drawing.drawPokemonInfoScreen(pokemonID)
	elseif InfoScreen.viewScreen == InfoScreen.SCREENS.MOVE_INFO then
		-- Only draw valid move data
		local moveId = InfoScreen.infoLookup -- moveId = 0 is blank move data
		if moveId < 1 or moveId > #MoveData.Moves then
			Program.state = State.TRACKER
			Program.waitToDrawFrames = 0
			return
		end

		Drawing.drawMoveInfoScreen(moveId)
	end
end

function Drawing.drawPokemonInfoScreen(pokemonID)
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)

	-- set the color for text/number shadows for the top boxes
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxInfoBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local offsetColumnX = offsetX + 43
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = 10
	local botOffsetY = offsetY + (linespacing * 6) - 2 + 9

	local pokemon = PokemonData.Pokemon[pokemonID]
	local pokemonViewed = Tracker.getPokemon(Utils.inlineIf(Tracker.Data.isViewingOwn, Tracker.Data.ownViewSlot, Tracker.Data.otherViewSlot), Tracker.Data.isViewingOwn)
	local isTargetTheViewedPokemonn = pokemonViewed.pokemonID == pokemonID

	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 8, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON NAME
	offsetY = offsetY - 3
	local pokemonName = pokemon.name:upper()
	gui.drawText(offsetX + 1 - 1, offsetY + 1, pokemonName, boxInfoTopShadow, nil, 12, Constants.FONT.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY, pokemonName, Theme.COLORS["Default text"], nil, 12, Constants.FONT.FAMILY, "bold")

	-- POKEMON ICON & TYPES
	offsetY = offsetY - 7
	gui.drawRectangle(offsetX + 106, offsetY + 37, 31, 13, boxInfoTopShadow, boxInfoTopShadow)
	gui.drawRectangle(offsetX + 105, offsetY + 36, 31, 13, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	if pokemon.type[2] ~= PokemonData.Types.EMPTY then
		gui.drawRectangle(offsetX + 106, offsetY + 50, 31, 12, boxInfoTopShadow, boxInfoTopShadow)
		gui.drawRectangle(offsetX + 105, offsetY + 49, 31, 12, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	end
	Drawing.drawPokemonIcon(pokemonID, offsetX + 105, offsetY + 2)
	Drawing.drawTypeIcon(pokemon.type[1], offsetX + 106, offsetY + 37)
	Drawing.drawTypeIcon(pokemon.type[2], offsetX + 106, offsetY + 49)
	offsetY = offsetY + 11 + linespacing

	-- BST
	Drawing.drawText(offsetX, offsetY, "BST:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, pokemon.bst, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- WEIGHT
	local weightInfo = pokemon.weight .. " kg"
	Drawing.drawText(offsetX, offsetY, "Weight:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, weightInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- EVOLUTION
	local possibleEvolutions = Utils.getDetailedEvolutionsInfo(pokemon.evolution)
	Drawing.drawText(offsetX, offsetY, "Evolution:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, possibleEvolutions[1], Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing
	if possibleEvolutions[2] ~= nil then
		Drawing.drawText(offsetColumnX, offsetY, possibleEvolutions[2], Theme.COLORS["Default text"], boxInfoTopShadow)
	end
	offsetY = offsetY + linespacing

	-- Draw bottom view box and header
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	botOffsetY = offsetY + 3
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, botOffsetY, rightEdge, bottomEdge - botOffsetY + 5, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	botOffsetY = botOffsetY + 1

	-- MOVES LEVEL BOXES
	Drawing.drawText(offsetX, botOffsetY, "New Move Levels:", Theme.COLORS["Default text"], boxInfoBotShadow)
	botOffsetY = botOffsetY + linespacing + 1
	local boxWidth = 16
	local boxHeight = 13
	for i, moveLvl in ipairs(pokemon.movelvls[GameSettings.versiongroup]) do -- 14 is the greatest number of moves a gen3 Pokemon can learn
		local nextBoxX = ((i - 1) % 8) * boxWidth-- 8 possible columns
		local nextBoxY = Utils.inlineIf(i <= 8, 0, 1) * boxHeight -- 2 possible rows
		local lvlSpacing = (2 - string.len(tostring(moveLvl))) * 3

		gui.drawRectangle(offsetX + nextBoxX + 5 + 1, botOffsetY + nextBoxY + 2, boxWidth, boxHeight, boxInfoBotShadow, boxInfoBotShadow)
		gui.drawRectangle(offsetX + nextBoxX + 5, botOffsetY + nextBoxY + 1, boxWidth, boxHeight, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

		-- Indicate which moves have already been learned if the pokemon being viewed is one of the ones in battle (yours/enemy)
		local nextBoxTextColor
		if not isTargetTheViewedPokemonn then
			nextBoxTextColor = Theme.COLORS["Default text"]
		elseif moveLvl <= pokemonViewed.level then
			nextBoxTextColor = Theme.COLORS["Negative text"]
		else
			nextBoxTextColor = Theme.COLORS["Positive text"]
		end

		Drawing.drawText(offsetX + nextBoxX + 7 + lvlSpacing, botOffsetY + nextBoxY + 2, moveLvl, nextBoxTextColor, boxInfoBotShadow)
	end
	botOffsetY = botOffsetY + (linespacing * 3)

	-- If the moves-to-learn only takes up one row, move up the weakness data
	if #pokemon.movelvls[GameSettings.versiongroup] <= 8 then
		botOffsetY = botOffsetY - linespacing
	end

	-- WEAK TO
	local weaknesses = {}
	for moveType, typeEffectiveness in pairs(MoveData.TypeToEffectiveness) do
		local effectiveness = 1
		if pokemon.type[1] ~= PokemonData.Types.EMPTY and typeEffectiveness[pokemon.type[1]] ~= nil then
			effectiveness = effectiveness * typeEffectiveness[pokemon.type[1]]
		end
		if pokemon.type[2] ~= PokemonData.Types.EMPTY and typeEffectiveness[pokemon.type[2]] ~= nil then
			effectiveness = effectiveness * typeEffectiveness[pokemon.type[2]]
		end
		if effectiveness > 1 then
			table.insert(weaknesses, moveType)
		end
	end
	Drawing.drawText(offsetX, botOffsetY, "Weak to:", Theme.COLORS["Default text"], boxInfoBotShadow)
	botOffsetY = botOffsetY + linespacing + 3

	if #weaknesses == 0 then -- If the Pokemon has no weakness, like Sableye
		table.insert(weaknesses, PokemonData.Types.UNKNOWN)
	end

	local typeOffsetX = offsetX + 6
	for _, weakType in pairs(weaknesses) do
		gui.drawRectangle(typeOffsetX, botOffsetY, 31, 13, boxInfoBotShadow, boxInfoBotShadow)
		gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box border"])
		Drawing.drawTypeIcon(weakType, typeOffsetX, botOffsetY)
		typeOffsetX = typeOffsetX + 31
		if typeOffsetX > Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - 30 then
			typeOffsetX = offsetX + 6
			botOffsetY = botOffsetY + 13
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.buttons.lookupPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.buttons.nextPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.buttons.previousPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.buttons.close, boxInfoBotShadow)
end

function Drawing.drawMoveInfoScreen(moveId)
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)

	-- set the color for text/number shadows for the top boxes
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxInfoBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local offsetColumnX = offsetX + 45
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = 10
	local botOffsetY = offsetY + (linespacing * 7) - 2 + 9

	local move = MoveData.Moves[moveId]
	local moveType = move.type
	local moveCat = move.category

	-- Before drawing view boxes, check if extra space is needed for 'Priority' information
	if move.priority ~= nil and move.priority ~= "0" then
		botOffsetY = botOffsetY + linespacing
	end

	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 8, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- MOVE NAME
	local moveName = move.name:upper()
	gui.drawText(offsetX + 1 - 1, offsetY + 1 - 3, moveName, boxInfoTopShadow, nil, 12, Constants.FONT.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY - 3, moveName, Theme.COLORS["Default text"], nil, 12, Constants.FONT.FAMILY, "bold")

	-- If the move is Hidden Power, use its tracked type/category instead
	if moveId == 237 and TrackerScreen.buttons.HiddenPower:isVisible() then -- 237 = Hidden Power
		moveType = Tracker.Data.currentHiddenPowerType
		moveCat = MoveData.TypeToCategory[moveType]
		Drawing.drawText(offsetX + 96, offsetY + linespacing * 2 - 4, "Set type ^", Theme.COLORS["Positive text"], boxInfoTopShadow)
	end
	
	-- TYPE ICON
	offsetY = offsetY + 1
	gui.drawRectangle(offsetX + 106, offsetY + 1, 31, 13, boxInfoTopShadow, boxInfoTopShadow)
	gui.drawRectangle(offsetX + 105, offsetY, 31, 13, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box border"])
	Drawing.drawTypeIcon(moveType, offsetX + 106, offsetY + 1)
	offsetY = offsetY + linespacing

	-- CATEGORY
	local categoryInfo = ""
	if moveCat == MoveData.Categories.PHYSICAL then
		categoryInfo = categoryInfo .. "Physical"
		Drawing.drawImageAsPixels(Constants.PIXEL_IMAGES.PHYSICAL, offsetX + 130, botOffsetY - linespacing - 13, boxInfoTopShadow)
	elseif moveCat == MoveData.Categories.SPECIAL then
		categoryInfo = categoryInfo .. "Special"
		Drawing.drawImageAsPixels(Constants.PIXEL_IMAGES.SPECIAL, offsetX + 130, botOffsetY - linespacing - 13, boxInfoTopShadow)
	elseif moveCat == MoveData.Categories.STATUS then
		categoryInfo = categoryInfo .. "Status"
	else categoryInfo = categoryInfo .. Constants.BLANKLINE end
	Drawing.drawText(offsetX, offsetY, "Category:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, categoryInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- CONTACT
	local contactInfo = Utils.inlineIf(move.iscontact ~= nil and move.iscontact, "Yes", "No")
	Drawing.drawText(offsetX, offsetY, "Contact:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, contactInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- PP
	local ppInfo = Utils.inlineIf(move.pp == Constants.NO_PP, Constants.BLANKLINE, move.pp)
	Drawing.drawText(offsetX, offsetY, "PP:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, ppInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- POWER
	-- local isStab = Utils.isSTAB(move, PokemonData.Pokemon[pokemonViewed.pokemonID].type)
	local powerInfo = move.power
	if move.power == Constants.NO_POWER then
		powerInfo = Constants.BLANKLINE
	-- elseif isStab then
	-- 	Drawing.drawText(offsetColumnX + 20, offsetY, "(" .. (tonumber(move.power) * 1.5) .. ")", Theme.COLORS["Positive text"], boxInfoTopShadow)
	end
	Drawing.drawText(offsetX, offsetY, "Power:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, powerInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- ACCURACY
	local accuracyInfo = move.accuracy .. Utils.inlineIf(move.accuracy ~= Constants.BLANKLINE, "%", "")
	Drawing.drawText(offsetX, offsetY, "Accuracy:", Theme.COLORS["Default text"], boxInfoTopShadow)
	Drawing.drawText(offsetColumnX, offsetY, accuracyInfo, Theme.COLORS["Default text"], boxInfoTopShadow)
	offsetY = offsetY + linespacing

	-- PRIORITY: Only take up a line on the screen if priority information is helpful (exists and is non-zero)
	if move.priority ~= nil and move.priority ~= "0" then
		Drawing.drawText(offsetX, offsetY, "Priority:", Theme.COLORS["Default text"], boxInfoTopShadow)
		Drawing.drawText(offsetColumnX, offsetY, move.priority, Theme.COLORS["Default text"], boxInfoTopShadow)
		offsetY = offsetY + linespacing
	end

	-- Draw bottom view box and header
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	Drawing.drawText(offsetX - 3, botOffsetY - linespacing - 1, "Summary:", Theme.COLORS["Header text"], bgHeaderShadow)
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, botOffsetY, rightEdge, bottomEdge - botOffsetY + 5, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])
	botOffsetY = botOffsetY + 1
	linespacing = linespacing + 1

	-- SUMMARY
	if move.summary ~= nil then
		local wrappedSummary = Utils.getWordWrapLines(move.summary, 31)
		
		for _, line in pairs(wrappedSummary) do
			Drawing.drawText(offsetX, botOffsetY, line, Theme.COLORS["Default text"], boxInfoBotShadow)
			botOffsetY = botOffsetY + linespacing
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.buttons.lookupMove, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.buttons.close, boxInfoBotShadow)
	
	-- Easter egg
	if moveId == 150 then -- 150 = Splash
		Drawing.drawPokemonIcon(129, offsetX + 16, botOffsetY + 8)
		Drawing.drawPokemonIcon(129, offsetX + 40, botOffsetY - 8)
		Drawing.drawPokemonIcon(129, offsetX + 75, botOffsetY + 2)
		Drawing.drawPokemonIcon(129, offsetX + 99, botOffsetY - 16)
	end
end

function Drawing.drawImageAsPixels(imageArray, x, y, imageShadow)
	for rowIndex = 1, #imageArray, 1 do
		for colIndex = 1, #(imageArray[1]) do
			local offsetX = colIndex - 1
			local offsetY = rowIndex - 1
			
			if imageArray[rowIndex][colIndex] ~= 0 then
				if imageShadow ~= nil then
					gui.drawPixel(x + offsetX + 1, y + offsetY + 1, imageShadow)
				end
				gui.drawPixel(x + offsetX, y + offsetY, Theme.COLORS["Default text"])
			end
		end
	end
end

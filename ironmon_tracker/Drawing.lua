Drawing = {}

ImageTypes = {
	GEAR = "gear",
	PHYSICAL = "physical",
	SPECIAL = "special",
	NOTEPAD = "notepad",
}

NatureTypes = {
	POSITIVE = 1,
	NEGATIVE = -1,
	NEUTRAL = 0,
}

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

--[[
Draws text for the tracker on screen with a shadow effect. Uses the Franklin Gothic Medium family with a 9 point size.

	x, y: integer -> pixel position for the text

	text: string -> the text to output to the screen

	color: string or integer -> the color for the text

	shadowcolor: string or integer -> the color for the shadow effect drawn behind the text

	style: string -> optional; can be regular, bold, italic, underline, or strikethrough
]]
-- TODO: Look into Libre Franklin and Public Sans are free fonts based on Franklin Gothic
function Drawing.drawText(x, y, text, color, shadowcolor, style)
	gui.drawText(x + 1, y + 1, text, shadowcolor, nil, 9, "Franklin Gothic Medium", style)
	gui.drawText(x, y, text, color, nil, 9, "Franklin Gothic Medium", style)
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
		if number == "---" then new_spacing = 8 end
	end

	Drawing.drawText(x + new_spacing, y, number, color, shadowcolor, style)
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

function Drawing.calcNatureBonus(stat, nature)
	local natureType = NatureTypes.NEUTRAL

	if nature % 6 == 0 then
		natureType = NatureTypes.NEUTRAL
	elseif stat == "atk" then
		if nature < 5 then
			natureType = NatureTypes.POSITIVE
		elseif nature % 5 == 0 then
			natureType = NatureTypes.NEGATIVE
		end
	elseif stat == "def" then
		if nature > 4 and nature < 10 then
			natureType = NatureTypes.POSITIVE
		elseif nature % 5 == 1 then
			natureType = NatureTypes.NEGATIVE
		end
	elseif stat == "spe" then
		if nature > 9 and nature < 15 then
			natureType = NatureTypes.POSITIVE
		elseif nature % 5 == 2 then
			natureType = NatureTypes.NEGATIVE
		end
	elseif stat == "spa" then
		if nature > 14 and nature < 20 then
			natureType = NatureTypes.POSITIVE
		elseif nature % 5 == 3 then
			natureType = NatureTypes.NEGATIVE
		end
	elseif stat == "spd" then
		if nature > 19 then
			natureType = NatureTypes.POSITIVE
		elseif nature % 5 == 4 then
			natureType = NatureTypes.NEGATIVE
		end
	else
		natureType = NatureTypes.NEUTRAL
	end

	return natureType
end	

function Drawing.drawStatusLevel(x, y, value)
	if value == 0 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
	elseif value == 1 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 2 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 3 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronDown(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 4 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 7 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 8 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 9 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
	elseif value == 10 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
	elseif value == 11 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Default text"])
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
	elseif value == 12 then
		Drawing.drawChevronUp(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
	end
end

function Drawing.drawMoveEffectiveness(x, y, value)
	if value == 2 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
	elseif value == 4 then
		Drawing.drawChevronUp(x, y + 4, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
		Drawing.drawChevronUp(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Positive text"])
	elseif value == 0.5 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
	elseif value == 0.25 then
		Drawing.drawChevronDown(x, y, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
		Drawing.drawChevronDown(x, y + 2, 4, 2, 1, GraphicConstants.THEMECOLORS["Negative text"])
	end

	for index, button in pairs(BadgeButtons.badgeButtons) do
		if button.visible() then
			local addForOff = ""
			if button.state == 0 then addForOff = "_OFF" end
			local path = DATA_FOLDER .. "/images/badges/" .. BadgeButtons.BADGE_GAME_PREFIX .. "_badge"..index..addForOff..".png"
			gui.drawImage(path,button.box[1], button.box[2])
		end
	end	
end

function Drawing.drawInputOverlay()
	if (Tracker.controller.framesSinceInput < Tracker.controller.boxVisibleFrames) and not Tracker.Data.isViewingOwn then
		local i = Tracker.controller.statIndex
		gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], GraphicConstants.THEMECOLORS["Intermediate text"], 0x000000)
	end
end

-- Returns a slightly darkened color
function Drawing.calcShadowColor(color)
	local color_hexval = (color - 0xFF000000)

	-- get the RGB values of the color 
	local r = bit.rshift(color_hexval, 16)
	local g = bit.rshift(bit.band(color_hexval, 0x00FF00), 8)
	local b = bit.band(color_hexval, 0x0000FF)

	local scale = 0x10 -- read as: 6.25%
	local isDarkBG = (1 - (0.299 * r + 0.587 * g + 0.114 * b) / 255) >= 0.5;
	if isDarkBG then
		scale = 0xB0 -- read as: 69%
	end
	-- scale RGB values down to make them darker
	r = r - r * scale / 0x100
	g = g - g * scale / 0x100
	b = b - b * scale / 0x100

	-- build color with new hex values
	color_hexval = bit.lshift(r, 16) + bit.lshift(g, 8) + b 
	return (0xFF000000 + color_hexval)
end

function Drawing.drawButtonBox(button, shadowcolor)
	local bordercolor = Utils.inlineIf(button.boxColors ~= nil, GraphicConstants.THEMECOLORS[button.boxColors[1]], GraphicConstants.THEMECOLORS["Upper box border"])
	local fillcolor = Utils.inlineIf(button.boxColors ~= nil, GraphicConstants.THEMECOLORS[button.boxColors[2]], GraphicConstants.THEMECOLORS["Upper box background"])

	if shadowcolor ~= nil then
		gui.drawRectangle(button.box[1] + 1, button.box[2] + 1, button.box[3], button.box[4], shadowcolor, fillcolor)
	end
	gui.drawRectangle(button.box[1], button.box[2], button.box[3], button.box[4], bordercolor, fillcolor)
end

function Drawing.drawPokemonView(pokemon, opposingPokemon)
	if pokemon == nil or not Tracker.Data.hasCheckedSummary then
		pokemon = Tracker.getDefaultPokemon()
	end
	-- Ability data currently isn't known until the pokemon enters its first battle
	if pokemon.ability == nil then
		pokemon.ability = { id = 0, revealed = false }
	end

	-- Fill background and margins
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, GraphicConstants.THEMECOLORS["Main background"], GraphicConstants.THEMECOLORS["Main background"])

	local borderMargin = 5
	local statBoxWidth = 101
	local statBoxHeight = 52

	-- Draw top box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, statBoxWidth - borderMargin, statBoxHeight, GraphicConstants.THEMECOLORS["Upper box border"], GraphicConstants.THEMECOLORS["Upper box background"])
	gui.defaultTextBackground(GraphicConstants.THEMECOLORS["Upper box background"])

	Drawing.drawPokemonIcon(pokemon.pokemonID, GraphicConstants.SCREEN_WIDTH + 5, 5)

	local colorbar = GraphicConstants.THEMECOLORS["Default text"]
	if pokemon.stats.hp == 0 then
		colorbar = GraphicConstants.THEMECOLORS["Default text"]
	elseif pokemon.curHP / pokemon.stats.hp <= 0.2 then
		colorbar = GraphicConstants.THEMECOLORS["Negative text"]
	elseif pokemon.curHP / pokemon.stats.hp <= 0.5 then
		colorbar = GraphicConstants.THEMECOLORS["Intermediate text"]
	end

	-- calculate shadows based on the location of the text (top or bot box)
	local bgHeaderShadow = Drawing.calcShadowColor(GraphicConstants.THEMECOLORS["Main background"])
	local boxTopShadow = Drawing.calcShadowColor(GraphicConstants.THEMECOLORS["Upper box background"])
	local boxBotShadow = Drawing.calcShadowColor(GraphicConstants.THEMECOLORS["Lower box background"])

	-- Don't show hp values if the pokemon doesn't belong to the player, or if it doesn't exist
	local currentHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, "?", pokemon.curHP)
	local maxHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, "?", pokemon.stats.hp)

	local pkmnStatOffsetX = 36
	local pkmnStatStartY = 5
	local pkmnStatOffsetY = 10
	-- Base Pokémon details
	-- Pokémon name
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY, PokemonData[pokemon.pokemonID + 1].name, GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
	-- Settings gear
	Drawing.drawImageAsPixels(ImageTypes.GEAR, GraphicConstants.SCREEN_WIDTH + statBoxWidth - 9, 7, boxTopShadow)
	-- HP
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 1), "HP:", GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 52, pkmnStatStartY + (pkmnStatOffsetY * 1), currentHP .. "/" .. maxHP, colorbar, boxTopShadow)
	-- Level and evolution
	local levelDetails = "Lv." .. pokemon.level
	local evolutionDetails = " (" .. PokemonData[pokemon.pokemonID + 1].evolution .. ")"
	local evoTextColor = GraphicConstants.THEMECOLORS["Default text"]

	-- If the evolution is happening soon (next level or friendship is ready, change font color)
	if Tracker.Data.isViewingOwn and string.format("%d", pokemon.level + 1) == PokemonData[pokemon.pokemonID + 1].evolution then
		evoTextColor = GraphicConstants.THEMECOLORS["Positive text"]
	elseif pokemon.friendship >= 220 and PokemonData[pokemon.pokemonID + 1].evolution == EvolutionTypes.FRIEND then
		evolutionDetails = " (SOON)"
		evoTextColor = GraphicConstants.THEMECOLORS["Positive text"]
	end
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 2), levelDetails .. evolutionDetails, evoTextColor, boxTopShadow)

	-- draw heal-info box
	local infoBoxHeight = 23
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin + statBoxHeight, statBoxWidth - borderMargin, infoBoxHeight, GraphicConstants.THEMECOLORS["Upper box border"], GraphicConstants.THEMECOLORS["Upper box background"])

	-- If viewing own pokemon, Heals in bag/PokéCenter heals
	if Tracker.Data.isViewingOwn then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, "Heals in Bag:", GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
		local healPercentage = math.min(9999, Tracker.Data.healingItems.healing)
		local healCount = math.min(99, Tracker.Data.healingItems.numHeals)
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 67, string.format("%.0f%%", healPercentage) .. " HP (" .. healCount .. ")", GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
		
		if (Options["Track PC Heals"]) then
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 57, "PC Heals:", GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
			-- Right-align the PC Heals number
			local healNumberSpacing = (2 - string.len(tostring(Tracker.Data.centerHeals))) * 5 + 75
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + healNumberSpacing, 67, Tracker.Data.centerHeals, Utils.getCenterHealColor(), boxTopShadow)
			
			-- Draw the '+'', '-'', and toggle button for auto PC tracking
			gui.drawText(Buttons[9].box[1] + 1, Buttons[9].box[2] + 1, Buttons[9].text, boxTopShadow, nil, 5, "Franklin Gothic Medium")
			gui.drawText(Buttons[9].box[1], Buttons[9].box[2], Buttons[9].text, GraphicConstants.THEMECOLORS[Buttons[9].textcolor], nil, 5, "Franklin Gothic Medium")
			gui.drawText(Buttons[10].box[1] + 1, Buttons[10].box[2] + 1, Buttons[10].text, boxTopShadow, nil, 5, "Franklin Gothic Medium")
			gui.drawText(Buttons[10].box[1], Buttons[10].box[2], Buttons[10].text, GraphicConstants.THEMECOLORS[Buttons[10].textcolor], nil, 5, "Franklin Gothic Medium")
			Drawing.drawButtonBox(PCHealTrackingButton, boxTopShadow)

			-- Draw a mark if the feature is on
			if Program.PCHealTrackingButtonState then
				gui.drawLine(PCHealTrackingButton.box[1] + 1, PCHealTrackingButton.box[2] + 1, PCHealTrackingButton.box[1] + PCHealTrackingButton.box[3] - 1, PCHealTrackingButton.box[2] + PCHealTrackingButton.box[4] - 1, GraphicConstants.THEMECOLORS[PCHealTrackingButton.togglecolor])
				gui.drawLine(PCHealTrackingButton.box[1] + 1, PCHealTrackingButton.box[2] + PCHealTrackingButton.box[4] - 1, PCHealTrackingButton.box[1] + PCHealTrackingButton.box[3] - 1, PCHealTrackingButton.box[2] + 1, GraphicConstants.THEMECOLORS[PCHealTrackingButton.togglecolor])
			end
		end
	else
		if Tracker.Data.trainerID ~= nil and pokemon.trainerID ~= nil then
			-- Check if trainer encounter or wild pokemon encounter (trainerID's will match if its a wild pokemon)
			local encounterText = Tracker.getEncounters(pokemon.pokemonID, Tracker.Data.trainerID ~= pokemon.trainerID)
			if encounterText > 9999 then encounterText = 9999 end
			if Tracker.Data.trainerID ~= pokemon.trainerID then
				encounterText = "Seen on trainers: " .. encounterText
			else
				encounterText = "Seen in wild: " .. encounterText
			end
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 6, 57, encounterText, GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
		end
	end

	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 35, 67, "4", GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
	-- local statusItems = Program.getBagStatusItems()
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 57, statusItems.poison, 0xFFFF00FF, boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 57, statusItems.burn, 0xFFFF0000, boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 57, statusItems.freeze, 0xFF0000FF, boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 60, 67, statusItems.sleep, "white", boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 70, 67, statusItems.paralyze, "yellow", boxTopShadow)
	-- Drawing.drawText(GraphicConstants.SCREEN_WIDTH + 80, 67, statusItems.all, 0xFFFF00FF, boxTopShadow)

	-- Draw Pokemon's held item and ability but only for your own Pokemon
	local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)
	if Tracker.Data.isViewingOwn then
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 3), MiscData.item[pokemon.heldItem + 1], GraphicConstants.THEMECOLORS["Intermediate text"], boxTopShadow)
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), MiscData.ability[pokemon.ability.id + 1], GraphicConstants.THEMECOLORS["Intermediate text"], boxTopShadow)
	elseif pokemon.ability.revealed then
		-- If the ability exists on the current pokemon data, and is known to the player, then draw it
		-- TODO: Eventually, this area somehow needs to function to allow users to click on the ability text and set ability, similar to "Notes"; can use the Item line for 2nd ability
		Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), MiscData.ability[pokemon.ability.id + 1], GraphicConstants.THEMECOLORS["Intermediate text"], boxTopShadow)
	else
		-- Otherwise, check if any / how many of the tracked abilities are known about this pokemon
		local bothRevealed = trackedAbilities[1].revealed and (trackedAbilities[2] ~= nil and trackedAbilities[2].revealed)
		local abilityOffsetY = pkmnStatStartY + (pkmnStatOffsetY * 4)
		if not bothRevealed then
			for _, trackedAbility in pairs(trackedAbilities) do
				-- When drawing an ability, if both aren't revealed, mark the one with a '?' to indicate uncertainty
				if trackedAbility.revealed then
					Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, abilityOffsetY, MiscData.ability[trackedAbility.id + 1] .. "?", GraphicConstants.THEMECOLORS["Intermediate text"], boxTopShadow)
				end
			end
		else
			for _, trackedAbility in pairs(trackedAbilities) do
				Drawing.drawText(GraphicConstants.SCREEN_WIDTH + pkmnStatOffsetX, abilityOffsetY, MiscData.ability[trackedAbility.id + 1], GraphicConstants.THEMECOLORS["Intermediate text"], boxTopShadow)
				abilityOffsetY = abilityOffsetY - pkmnStatOffsetY -- For now, draw the second ability above the first, in the held item slot
			end
		end
	end

	-- draw stat box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + statBoxWidth, 5, GraphicConstants.RIGHT_GAP - statBoxWidth - borderMargin, 75, GraphicConstants.THEMECOLORS["Upper box border"], GraphicConstants.THEMECOLORS["Upper box background"])
	local statLabels = {"hp", "atk", "def", "spa", "spd", "spe"}
	local statOffsetX = GraphicConstants.SCREEN_WIDTH + statBoxWidth + 1
	local statOffsetY = 7

	for i = 1, #statLabels, 1 do
		local natureType = Drawing.calcNatureBonus(statLabels[i], pokemon.nature)
		local textColor = GraphicConstants.THEMECOLORS["Default text"]
		local natureSymbol = ""
		if Tracker.Data.isViewingOwn and natureType == NatureTypes.POSITIVE then
			textColor = GraphicConstants.THEMECOLORS["Positive text"]
			natureSymbol = "+"
		elseif Tracker.Data.isViewingOwn and natureType == NatureTypes.NEGATIVE then
			textColor = GraphicConstants.THEMECOLORS["Negative text"]
			natureSymbol = "---"
		end

		-- Draw stat label and nature symbol next to it
		Drawing.drawText(statOffsetX, statOffsetY, statLabels[i]:upper(), textColor, boxTopShadow)
		gui.drawText(statOffsetX + 25 - 10 + 1, statOffsetY - 1, natureSymbol, textColor, nil, 5, "Franklin Gothic Medium")

		-- Draw stat battle increases/decreases, stages range from -6 to +6
		if Tracker.Data.inBattle then
			Drawing.drawStatusLevel(statOffsetX + 25 - 5, statOffsetY, pokemon.statStages[statLabels[i]:upper()])
		end

		-- Draw stat value, or the stat tracking box if enemy Pokemon
		if Tracker.Data.isViewingOwn then
			Drawing.drawNumber(statOffsetX + 25, statOffsetY, Utils.inlineIf(pokemon.stats[statLabels[i]] == 0, "---", pokemon.stats[statLabels[i]]), 3, textColor, boxTopShadow)
		else
			if Buttons[i].visible() and Buttons[i].type == ButtonType.singleButton then
				Drawing.drawButtonBox(Buttons[i], boxTopShadow)
				Drawing.drawText(Buttons[i].box[1], Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + Utils.inlineIf(Buttons[i].text == "--", 0, 1), Buttons[i].text, GraphicConstants.THEMECOLORS[Buttons[i].textcolor], boxTopShadow)
			end
		end
		statOffsetY = statOffsetY + 10
	end

	Drawing.drawText(statOffsetX, statOffsetY, "BST", GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)
	Drawing.drawText(statOffsetX + 25, statOffsetY, PokemonData[pokemon.pokemonID + 1].bst, GraphicConstants.THEMECOLORS["Default text"], boxTopShadow)

	-- Drawing moves
	gui.defaultTextBackground(GraphicConstants.THEMECOLORS["Lower box background"])
	local movesBoxStartY = 92
	-- draw moves box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY, GraphicConstants.RIGHT_GAP - (2 * borderMargin), 46, GraphicConstants.THEMECOLORS["Lower box border"], GraphicConstants.THEMECOLORS["Lower box background"])
	local moveStartY = movesBoxStartY + 2

	local stars = { "", "", "", "" }
	if not Tracker.Data.isViewingOwn then
		stars = Utils.calculateMoveStars(pokemon.pokemonID, pokemon.level)
	end

	-- Determine which moves to show based on if the tracker is showing the enemy Pokémon or the player's.
	-- If the Pokemon doesn't belong to the player, pull move data from tracked data
	local trackedMoves = Tracker.getMoves(pokemon.pokemonID)
	local moves = {}
	for moveIndex = 1, 4, 1 do
		if Tracker.Data.isViewingOwn then
			moves[moveIndex] = MoveData[pokemon.moves[moveIndex].id]
		else
			if trackedMoves ~= nil and trackedMoves[moveIndex] ~= nil then
				moves[moveIndex] = MoveData[trackedMoves[moveIndex].id]
			else
				moves[moveIndex] = MoveData[1]
			end
		end
	end	

	local movesString = "Move ~  " .. Utils.getMovesLearnedHeader(pokemon.pokemonID, pokemon.level)

	local moveTableHeaderHeightDiff = 14
	local distanceBetweenMoves = 10
	local moveOffset = 7
	local ppOffset = 82
	local powerOffset = 102
	local accOffset = 126

	-- Draw move headers
	gui.defaultTextBackground(GraphicConstants.THEMECOLORS["Main background"])
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + moveOffset - 2, moveStartY - moveTableHeaderHeightDiff, movesString, GraphicConstants.THEMECOLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY - moveTableHeaderHeightDiff, "PP", GraphicConstants.THEMECOLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY - moveTableHeaderHeightDiff, "Pow", GraphicConstants.THEMECOLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY - moveTableHeaderHeightDiff, "Acc", GraphicConstants.THEMECOLORS["Header text"], bgHeaderShadow)

	-- Draw Moves categories, names, and other information
	gui.defaultTextBackground(GraphicConstants.THEMECOLORS["Lower box background"])

		-- Move category: physical, special, or status effect (and type color?)
	for moveIndex = 1, 4, 1 do
		local currentHiddenPowerCat = MoveTypeCategories[Tracker.Data.currentHiddenPowerType]
		local category = Utils.inlineIf(moves[moveIndex].name == "Hidden Power", currentHiddenPowerCat, moves[moveIndex].category)

		if Options["Show physical special icons"] and category == MoveCategories.PHYSICAL then
			Drawing.drawImageAsPixels(ImageTypes.PHYSICAL, GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + 2 + (distanceBetweenMoves * (moveIndex - 1)), boxBotShadow)
		elseif Options["Show physical special icons"] and category == MoveCategories.SPECIAL then
			Drawing.drawImageAsPixels(ImageTypes.SPECIAL, GraphicConstants.SCREEN_WIDTH + moveOffset, moveStartY + 2 + (distanceBetweenMoves * (moveIndex - 1)), boxBotShadow)
		end
	end

	-- Move names (longest name is 12 characters?)
	local nameOffset = Utils.inlineIf(Options["Show physical special icons"], 14, moveOffset - 1)
	nameOffset = nameOffset + Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, 0, 5)
	local moveColors = {}
	for moveIndex = 1, 4, 1 do
		table.insert(moveColors, Drawing.moveToColor(moves[moveIndex]))
	end
	for moveIndex = 1, 4, 1 do
		if moves[moveIndex].name == "Hidden Power" and Tracker.Data.isViewingOwn then
			HiddenPowerButton.box[1] = GraphicConstants.SCREEN_WIDTH + nameOffset
			HiddenPowerButton.box[2] = moveStartY + (distanceBetweenMoves * (moveIndex - 1))
			if not GraphicConstants.MOVE_TYPES_ENABLED then
				gui.drawRectangle(HiddenPowerButton.box[1] - 3, HiddenPowerButton.box[2] + 2, 2, 7, HiddenPowerButton.textcolor, HiddenPowerButton.textcolor)
			end
			Drawing.drawText(HiddenPowerButton.box[1], HiddenPowerButton.box[2] + (HiddenPowerButton.box[4] - 12) / 2 + 1, HiddenPowerButton.text, Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, HiddenPowerButton.textcolor, GraphicConstants.THEMECOLORS["Default text"]), boxBotShadow)
		else
			-- Draw a small colored rectangle showing the color of the move type instead of painting over the text
			if not GraphicConstants.MOVE_TYPES_ENABLED and moves[moveIndex].name ~= "---" then
				gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + nameOffset - 3, moveStartY + 2 + (distanceBetweenMoves * (moveIndex - 1)), 2, 7, moveColors[moveIndex], moveColors[moveIndex])
			end
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + nameOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].name .. stars[moveIndex], Utils.inlineIf(GraphicConstants.MOVE_TYPES_ENABLED, moveColors[moveIndex], GraphicConstants.THEMECOLORS["Default text"]), boxBotShadow)
		end
	end

	-- Move power points
	for moveIndex = 1, 4, 1 do
		local ppText = moves[moveIndex].pp -- Set to move's max PP value
		-- check if any pp has been used and it should be revealed
		if moves[moveIndex].pp ~= NOPP then
			if Tracker.Data.isViewingOwn then
				ppText = pokemon.moves[moveIndex].pp
			elseif Options["Track enemy PP usage"] then
				for _, move in pairs(pokemon.moves) do
					if (tonumber(move.id) - 1) == tonumber(moves[moveIndex].id) then
						ppText = move.pp
					end
				end
			end
		end
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + ppOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), ppText, 2, GraphicConstants.THEMECOLORS["Default text"], boxBotShadow)
	end

	-- Move attack power
	local stabColors = {}
	for moveIndex = 1, 4, 1 do
		local showStabColor = Tracker.Data.inBattle and moves[moveIndex].power ~= NOPOWER and Utils.isSTAB(moves[moveIndex], PokemonData[pokemon.pokemonID + 1])
		table.insert(stabColors, Utils.inlineIf(showStabColor, GraphicConstants.THEMECOLORS["Positive text"], GraphicConstants.THEMECOLORS["Default text"]))
	end
	for moveIndex = 1, 4, 1 do
		local movePower = moves[moveIndex].power
		if Options["Calculate variable damage"] then
			local newPower = movePower
			if movePower == "WT" and Tracker.Data.inBattle and opposingPokemon ~= nil then
				-- Calculate the power of weight moves in battle
				local targetWeight = PokemonData[opposingPokemon.pokemonID + 1].weight
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
			Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), newPower, 3, stabColors[moveIndex], boxBotShadow)
		else
			Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + powerOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), movePower, 3, stabColors[moveIndex], boxBotShadow)
		end
	end

	-- Move accuracy
	for moveIndex = 1, 4, 1 do
		Drawing.drawNumber(GraphicConstants.SCREEN_WIDTH + accOffset, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), moves[moveIndex].accuracy, 3, GraphicConstants.THEMECOLORS["Default text"], boxBotShadow)
	end

	-- Move effectiveness against the opponent
	if Options["Show move effectiveness"] and Tracker.Data.inBattle and opposingPokemon ~= nil then
		for moveIndex = 1, 4, 1 do
			local effectiveness = Utils.netEffectiveness(moves[moveIndex], PokemonData[opposingPokemon.pokemonID + 1])
			if effectiveness == 0 then
				Drawing.drawText(GraphicConstants.SCREEN_WIDTH + powerOffset - 5, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), "X", GraphicConstants.THEMECOLORS["Negative text"], boxBotShadow)
			else
				Drawing.drawMoveEffectiveness(GraphicConstants.SCREEN_WIDTH + powerOffset - 5, moveStartY + (distanceBetweenMoves * (moveIndex - 1)), effectiveness)
			end
		end
	end

	Drawing.drawInputOverlay()

	-- Draw badge/note box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY + 44, GraphicConstants.RIGHT_GAP - (2 * borderMargin), 19, GraphicConstants.THEMECOLORS["Lower box border"], GraphicConstants.THEMECOLORS["Lower box background"])
	for index, button in pairs(BadgeButtons.badgeButtons) do
		if button.visible() then
			local addForOff = ""
			if button.state == 0 then addForOff = "_OFF" end
			local path = DATA_FOLDER .. "/images/badges/" .. BadgeButtons.BADGE_GAME_PREFIX .. "_badge" .. index .. addForOff .. ".png"
			gui.drawImage(path, button.box[1], button.box[2])
		end
	end	

	-- Draw note box, but only for enemy pokemon
	if Tracker.Data.inBattle and not Tracker.Data.isViewingOwn then
		local noteText = Tracker.getNote(pokemon.pokemonID)
		if noteText == "" then
			Drawing.drawImageAsPixels(ImageTypes.NOTEPAD, GraphicConstants.SCREEN_WIDTH + borderMargin + 3, movesBoxStartY + 47, boxBotShadow)
		else
			Drawing.drawText(GraphicConstants.SCREEN_WIDTH + borderMargin, movesBoxStartY + 48, noteText, GraphicConstants.THEMECOLORS["Default text"], boxBotShadow)
			--work around limitation of drawText not having width limit: paint over any spillover
			local x = GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 5
			local y = movesBoxStartY + 44
			gui.drawLine(x, y, x, y + 14, GraphicConstants.THEMECOLORS["Lower box border"])
			gui.drawRectangle(x + 1, y, 12, 14, GraphicConstants.THEMECOLORS["Main background"], GraphicConstants.THEMECOLORS["Main background"])
		end
	end
end

function Drawing.drawSettingStateButton(index, state)
	-- for i = 1, table.getn(Buttons), 1 do
	-- 	if Buttons[i].visible() then
	-- 		if Buttons[i].type == ButtonType.singleButton then
	-- 			gui.drawRectangle(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], Buttons[i].backgroundcolor[1], Buttons[i].backgroundcolor[2])
	-- 			local extraY = 1
	-- 			if Buttons[i].text == "--" then extraY = 0 end
	-- 			Drawing.drawText(Buttons[i].box[1], Buttons[i].box[2] + (Buttons[i].box[4] - 12) / 2 + extraY, Buttons[i].text, Buttons[i].textcolor)
	-- 		end
	-- 	end
	-- end
	-- gui.drawRectangle()
end

function Drawing.drawSettings()
	-- Fill background and margins
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, GraphicConstants.THEMECOLORS["Main background"], GraphicConstants.THEMECOLORS["Main background"])
	gui.defaultTextBackground(GraphicConstants.THEMECOLORS["Upper box background"])

	local borderMargin = 5
	local rightEdge = GraphicConstants.RIGHT_GAP - (2 * borderMargin)
	local bottomEdge = GraphicConstants.SCREEN_HEIGHT - (2 * borderMargin)

	-- set the color for text/number shadows for the top boxes
	local boxSettingsShadow = Drawing.calcShadowColor(GraphicConstants.THEMECOLORS["Upper box background"])

	-- Settings view box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, rightEdge, bottomEdge, GraphicConstants.THEMECOLORS["Upper box border"], GraphicConstants.THEMECOLORS["Upper box background"])

	-- Cancel/close button
	Drawing.drawButtonBox(Options.closeButton, boxSettingsShadow)
	Drawing.drawText(Options.closeButton.box[1] + 3, Options.closeButton.box[2], Options.closeButton.text, GraphicConstants.THEMECOLORS[Options.closeButton.textColor], boxSettingsShadow)

	-- Roms folder setting
	local folderText = Utils.truncateRomsFolder(Settings.config.ROMS_FOLDER)
	Drawing.drawText(Options.romsFolderOption.box[1], Options.romsFolderOption.box[2], Options.romsFolderOption.text .. folderText, GraphicConstants.THEMECOLORS[Options.romsFolderOption.textColor], boxSettingsShadow)
	if folderText == "" then
		Drawing.drawImageAsPixels(ImageTypes.NOTEPAD, GraphicConstants.SCREEN_WIDTH + 60, borderMargin + 2, boxSettingsShadow)
		Drawing.drawText(Options.romsFolderOption.box[1] + 65, Options.romsFolderOption.box[2], '(Click to set)', GraphicConstants.THEMECOLORS[Options.romsFolderOption.textColor], boxSettingsShadow)
	end

	-- Edit controls button
	Drawing.drawButtonBox(Options.controlsButton, boxSettingsShadow)
	Drawing.drawText(Options.controlsButton.box[1] + 3, Options.controlsButton.box[2], Options.controlsButton.text, GraphicConstants.THEMECOLORS[Options.controlsButton.textColor], boxSettingsShadow)

	-- Customize button
	Drawing.drawButtonBox(Options.themeButton, boxSettingsShadow)
	Drawing.drawText(Options.themeButton.box[1] + 3, Options.themeButton.box[2], Options.themeButton.text, GraphicConstants.THEMECOLORS[Options.themeButton.textColor], boxSettingsShadow)

	-- Draw toggleable settings
	for _, button in pairs(Options.optionsButtons) do
		Drawing.drawButtonBox(button, boxSettingsShadow)
		Drawing.drawText(button.box[1] + button.box[3] + 1, button.box[2] - 1, button.text, GraphicConstants.THEMECOLORS[button.textColor], boxSettingsShadow)
		-- Draw a mark if the feature is on
		if Options[button.text] then
			gui.drawLine(button.box[1] + 1, button.box[2] + 1, button.box[1] + button.box[3] - 1, button.box[2] + button.box[4] - 1, GraphicConstants.THEMECOLORS[button.togglecolor])
			gui.drawLine(button.box[1] + 1, button.box[2] + button.box[4] - 1, button.box[1] + button.box[3] - 1, button.box[2] + 1, GraphicConstants.THEMECOLORS[button.togglecolor])
		end
	end
end

function Drawing.drawThemeMenu()
	-- Fill background and margins
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH, 0, GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP, GraphicConstants.SCREEN_HEIGHT, GraphicConstants.THEMECOLORS["Main background"], GraphicConstants.THEMECOLORS["Main background"])
	gui.defaultTextBackground(GraphicConstants.THEMECOLORS["Lower box background"])

	local borderMargin = 5
	local rightEdge = GraphicConstants.RIGHT_GAP - (2 * borderMargin)
	local bottomEdge = GraphicConstants.SCREEN_HEIGHT - (2 * borderMargin)

	-- set the color for text/number shadows for the bottom box values
	local boxThemeShadow = Drawing.calcShadowColor(GraphicConstants.THEMECOLORS["Lower box background"])

	-- Draw Theme menu view box
	gui.drawRectangle(GraphicConstants.SCREEN_WIDTH + borderMargin, borderMargin, rightEdge, bottomEdge, GraphicConstants.THEMECOLORS["Lower box border"], GraphicConstants.THEMECOLORS["Lower box background"])

	-- Draw Import, Export, Presets buttons
	Drawing.drawButtonBox(Theme.importThemeButton, boxThemeShadow)
	Drawing.drawText(Theme.importThemeButton.box[1] + 3, Theme.importThemeButton.box[2], Theme.importThemeButton.text, GraphicConstants.THEMECOLORS[Theme.importThemeButton.textColor], boxThemeShadow)
	Drawing.drawButtonBox(Theme.exportThemeButton, boxThemeShadow)
	Drawing.drawText(Theme.exportThemeButton.box[1] + 3, Theme.exportThemeButton.box[2], Theme.exportThemeButton.text, GraphicConstants.THEMECOLORS[Theme.exportThemeButton.textColor], boxThemeShadow)
	Drawing.drawButtonBox(Theme.presetsButton, boxThemeShadow)
	Drawing.drawText(Theme.presetsButton.box[1] + 3, Theme.presetsButton.box[2], Theme.presetsButton.text, GraphicConstants.THEMECOLORS[Theme.presetsButton.textColor], boxThemeShadow)

	-- Draw each theme element and its color picker
	local textPadding = 1
	for _, button in pairs(Theme.themeButtons) do
		if button.themeColor ~= nil then
			-- fill in the box with the current defined color
			gui.drawEllipse(button.box[1] - 1, button.box[2], button.box[3], button.box[4], 0xFF000000, GraphicConstants.THEMECOLORS[button.themeColor]) -- black border
			-- Draw the hex code to the side 
			Drawing.drawText(button.box[1] + button.box[3] + textPadding, button.box[2] - 2, string.upper(string.sub(string.format("%#x", GraphicConstants.THEMECOLORS[button.themeColor]), 5)), GraphicConstants.THEMECOLORS[button.textColor], boxThemeShadow)
			Drawing.drawText(button.box[1] + button.box[3] + textPadding + 36, button.box[2] - 2, button.text, GraphicConstants.THEMECOLORS[button.textColor], boxThemeShadow)
		else
		end
	end
	Drawing.drawButtonBox(Theme.moveTypeEnableButton, boxThemeShadow)
	-- Draw a mark if the feature is on
	if GraphicConstants.MOVE_TYPES_ENABLED then
		gui.drawLine(Theme.moveTypeEnableButton.box[1] + 1, Theme.moveTypeEnableButton.box[2] + 1, Theme.moveTypeEnableButton.box[1] + Theme.moveTypeEnableButton.box[3] - 1, Theme.moveTypeEnableButton.box[2] + Theme.moveTypeEnableButton.box[4] - 1, GraphicConstants.THEMECOLORS[Theme.moveTypeEnableButton.togglecolor])
		gui.drawLine(Theme.moveTypeEnableButton.box[1] + 1, Theme.moveTypeEnableButton.box[2] + Theme.moveTypeEnableButton.box[4] - 1, Theme.moveTypeEnableButton.box[1] + Theme.moveTypeEnableButton.box[3] - 1, Theme.moveTypeEnableButton.box[2] + 1, GraphicConstants.THEMECOLORS[Theme.moveTypeEnableButton.togglecolor])
	end
	Drawing.drawText(Theme.moveTypeEnableButton.box[1] + Theme.moveTypeEnableButton.box[3] + 1 + textPadding, Theme.moveTypeEnableButton.box[2] - 2, Theme.moveTypeEnableButton.text, GraphicConstants.THEMECOLORS[Theme.moveTypeEnableButton.textColor], boxThemeShadow)

	-- Draw Restore Defaults button
	Drawing.drawButtonBox(Theme.restoreDefaultsButton, boxThemeShadow)
	Drawing.drawText(Theme.restoreDefaultsButton.box[1] + 3, Theme.restoreDefaultsButton.box[2], Theme.restoreDefaultsButton.text, GraphicConstants.THEMECOLORS[Theme.restoreDefaultsButton.textColor], boxThemeShadow)
	
	-- Draw Close button
	Drawing.drawButtonBox(Theme.closeButton, boxThemeShadow)
	Drawing.drawText(Theme.closeButton.box[1] + 3, Theme.closeButton.box[2], Theme.closeButton.text, GraphicConstants.THEMECOLORS[Theme.closeButton.textColor], boxThemeShadow)
	
end

function Drawing.drawImageAsPixels(imageType, x, y, imageShadow)
	local imageArray = {}
	local c = GraphicConstants.THEMECOLORS["Default text"] -- a colored pixel
	local e = -1 -- an empty pixel

	if imageType == ImageTypes.GEAR then
		c = GraphicConstants.THEMECOLORS["Default text"]
		imageArray = {
			{e,e,e,c,c,e,e,e},
			{e,c,c,c,c,c,c,e},
			{e,c,c,c,c,c,c,e},
			{c,c,c,e,e,c,c,c},
			{c,c,c,e,e,c,c,c},
			{e,c,c,c,c,c,c,e},
			{e,c,c,c,c,c,c,e},
			{e,e,e,c,c,e,e,e}
		}
	elseif imageType == ImageTypes.PHYSICAL then
		c = GraphicConstants.THEMECOLORS["Default text"]
		imageArray = {
			{c,e,e,c,e,e,c},
			{e,c,e,c,e,c,e},
			{e,e,c,c,c,e,e},
			{c,c,c,c,c,c,c},
			{e,e,c,c,c,e,e},
			{e,c,e,c,e,c,e},
			{c,e,e,c,e,e,c}
		}
	elseif imageType == ImageTypes.SPECIAL then
		c = GraphicConstants.THEMECOLORS["Default text"]
		imageArray = {
			{e,e,c,c,c,e,e},
			{e,c,e,e,e,c,e},
			{c,e,e,c,e,e,c},
			{c,e,c,e,c,e,c},
			{c,e,e,c,e,e,c},
			{e,c,e,e,e,c,e},
			{e,e,c,c,c,e,e}
		}
	elseif imageType == ImageTypes.NOTEPAD then
		c = GraphicConstants.THEMECOLORS["Default text"]
		imageArray = {
			{e,e,e,e,e,e,e,e,e,c,c},
			{e,e,e,e,e,e,e,e,c,e,c},
			{c,c,c,c,c,c,c,c,c,c,e},
			{c,e,e,e,e,e,e,c,c,e,e},
			{c,e,c,c,c,e,c,e,c,e,e},
			{c,e,e,e,e,e,e,e,c,e,e},
			{c,e,c,c,c,c,c,e,c,e,e},
			{c,e,e,e,e,e,e,e,c,e,e},
			{c,e,c,c,c,c,c,e,c,e,e},
			{c,e,e,e,e,e,e,e,c,e,e},
			{c,c,c,c,c,c,c,c,c,e,e},
		}
	end

	for rowIndex = 1, #imageArray, 1 do
		for colIndex = 1, #(imageArray[1]) do
			local offsetX = colIndex - 1
			local offsetY = rowIndex - 1
			local color = imageArray[rowIndex][colIndex]
			if color ~= -1 then
				if imageShadow ~= nil then
					gui.drawPixel(x + offsetX + 1, y + offsetY + 1, imageShadow)
				end
				gui.drawPixel(x + offsetX, y + offsetY, color)
			end
		end
	end
end
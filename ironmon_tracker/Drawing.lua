Drawing = {}

function Drawing.clearGUI()
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, 0xFF000000, 0xFF000000)
end

function Drawing.drawPokemonIcon(id, x, y)
	id = id or 0
	if id < 0 or id > #PokemonData.Pokemon then
		id = 0 -- Blank Pokemon data/icon
	end

	local folderToUse = "pokemon"
	local extension = Constants.Extensions.POKEMON_PIXELED
	if Options["Pokemon Stadium portraits"] then
		folderToUse = "pokemonStadium"
		extension = Constants.Extensions.POKEMON_STADIUM
		y = y + 4
	end

	gui.drawImage(Main.DataFolder .. "/images/" .. folderToUse .. "/" .. id .. extension, x, y, 32, 32)
end

function Drawing.drawTypeIcon(type, x, y)
	if type == nil or type == "" then return end

	gui.drawImage(Main.DataFolder .. "/images/types/" .. type .. ".png", x, y, 30, 12)
end

function Drawing.drawStatusIcon(status, x, y)
	if status == nil or status == "" then return end

	gui.drawImage(Main.DataFolder .. "/images/status/" .. status .. ".png", x, y, 16, 8)
end

function Drawing.drawText(x, y, text, color, shadowcolor, style)
	gui.drawText(x + 1, y + 1, text, shadowcolor, nil, Constants.Font.SIZE, Constants.Font.FAMILY, style)
	gui.drawText(x, y, text, color, nil, Constants.Font.SIZE, Constants.Font.FAMILY, style)
end

function Drawing.drawNumber(x, y, number, spacing, color, shadowcolor, style)
	if Options["Right justified numbers"] then
		Drawing.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, style)
	else
		Drawing.drawText(x, y, number, color, shadowcolor, style)
	end
end

function Drawing.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, style)
	local new_spacing = (spacing - string.len(tostring(number))) * 5
	if number == Constants.BLANKLINE then new_spacing = 8 end
	Drawing.drawText(x + new_spacing, y, number, color, shadowcolor, style)
end

function Drawing.drawChevron(x, y, width, height, thickness, direction, hasColor)
	local color = Theme.COLORS["Default text"]
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
		local statKey = Constants.OrderedLists.STATSTAGES[Input.controller.statIndex]
		local statButton = TrackerScreen.Buttons[statKey]
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
	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.CHECKBOX or button.type == Constants.ButtonTypes.STAT_STAGE then
		local bordercolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[1]], Theme.COLORS["Upper box border"])
		local fillcolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[2]], Theme.COLORS["Upper box background"])

		-- Draw the box's shadow and the box border
		if shadowcolor ~= nil then
			gui.drawRectangle(x + 1, y + 1, width, height, shadowcolor, fillcolor)
		end
		gui.drawRectangle(x, y, width, height, bordercolor, fillcolor)
	end

	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.NO_BORDER then
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.CHECKBOX then
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + width + 1, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end

		-- Draw a mark if the checkbox button is toggled on
		if button.toggleState ~= nil and button.toggleState then
			gui.drawLine(x + 1, y + 1, x + width - 1, y + height - 1, Theme.COLORS[button.toggleColor])
			gui.drawLine(x + 1, y + height - 1, x + width - 1, y + 1, Theme.COLORS[button.toggleColor])
		end
	elseif button.type == Constants.ButtonTypes.COLORPICKER then
		if button.themeColor ~= nil then
			local hexCodeText = string.upper(string.sub(string.format("%#x", Theme.COLORS[button.themeColor]), 5))
			-- Draw a colored circle with a black border
			gui.drawEllipse(x - 1, y, width, height, 0xFF000000, Theme.COLORS[button.themeColor])
			-- Draw the hex code to the side, and the text label for it
			Drawing.drawText(x + width + 1, y - 2, hexCodeText, Theme.COLORS[button.textColor], shadowcolor)
			Drawing.drawText(x + width + 37, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.IMAGE then
		if button.image ~= nil then
			gui.drawImage(button.image, x, y)
		end
	elseif button.type == Constants.ButtonTypes.PIXELIMAGE then
		if button.image ~= nil then
			Drawing.drawImageAsPixels(button.image, x, y, Theme.COLORS["Default text"], shadowcolor)
		end
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + width + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.POKEMON_ICON then
		local imagePath = button:getIconPath()
		if imagePath ~= nil then
			if Options["Pokemon Stadium portraits"] then
				y = y + 4
			end
			gui.drawImage(imagePath, x, y, width, height)
		end
	elseif button.type == Constants.ButtonTypes.STAT_STAGE then
		if button.text ~= nil and button.text ~= "" then
			if button.text == Constants.STAT_STATES[2].text then
				y = y - 1 -- Move up the negative stat mark 1px
			end
			Drawing.drawText(x, y - 1, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	end
end

function Drawing.drawMainTrackerScreen(pokemon, opposingPokemon)
	if pokemon == nil or pokemon.pokemonID == 0 then
		pokemon = Tracker.getDefaultPokemon()
	elseif not Tracker.Data.hasCheckedSummary then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = pokemon.pokemonID
		defaultPokemon.level = pokemon.level
		pokemon = defaultPokemon
	end

	-- Add in Pokedex information about the Pokemon
	local pokedexInfo = Utils.inlineIf(pokemon.pokemonID ~= 0, PokemonData.Pokemon[pokemon.pokemonID], PokemonData.BlankPokemon)
	for key, value in pairs(pokedexInfo) do
		pokemon[key] = value
	end

	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	Drawing.drawPokemonInfoArea(pokemon)
	Drawing.drawStatsArea(pokemon)
	Drawing.drawMovesArea(pokemon, opposingPokemon)
	Drawing.drawCarouselArea(pokemon)
end

function Drawing.drawPokemonInfoArea(pokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	-- Draw top box view
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, 96, 52, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON ICON & TYPES
	Drawing.drawButton(TrackerScreen.Buttons.PokemonIcon, shadowcolor)
	Drawing.drawTypeIcon(pokemon.type[1], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
	Drawing.drawTypeIcon(pokemon.type[2], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 45)

	-- SETTINGS GEAR
	Drawing.drawButton(TrackerScreen.Buttons.SettingsGear, shadowcolor)

	-- POKEMON INFORMATION
	local pkmnStatOffsetX = 36
	local pkmnStatStartY = 5
	local pkmnStatOffsetY = 10

	-- Don't show hp values if the pokemon doesn't belong to the player, or if it doesn't exist
	local currentHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, "?", pokemon.curHP)
	local maxHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, "?", pokemon.stats.hp)
	local hpText = currentHP .. "/" .. maxHP
	local hpTextColor = Theme.COLORS["Default text"]
	if pokemon.stats.hp == 0 then
		hpTextColor = Theme.COLORS["Default text"]
	elseif pokemon.curHP / pokemon.stats.hp <= 0.2 then
		hpTextColor = Theme.COLORS["Negative text"]
	elseif pokemon.curHP / pokemon.stats.hp <= 0.5 then
		hpTextColor = Theme.COLORS["Intermediate text"]
	end

	-- If the evolution is happening soon (next level or friendship is ready, change font color)
	local evoDetails = "(" .. pokemon.evolution .. ")"
	local levelEvoTextColor = Theme.COLORS["Default text"]
	if Tracker.Data.isViewingOwn and Utils.isReadyToEvolveByLevel(pokemon.evolution, pokemon.level) then
		levelEvoTextColor = Theme.COLORS["Positive text"]
	elseif pokemon.friendship >= Program.friendshipRequired and pokemon.evolution == PokemonData.Evolutions.FRIEND then
		evoDetails = "(SOON)"
		levelEvoTextColor = Theme.COLORS["Positive text"]
	end
	local levelEvoText = "Lv." .. pokemon.level .. " " .. evoDetails

	-- DRAW POKEMON INFO
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY, pokemon.name, Theme.COLORS["Default text"], shadowcolor)
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 1), "HP:", Theme.COLORS["Default text"], shadowcolor)
	Drawing.drawText(Constants.SCREEN.WIDTH + 52, pkmnStatStartY + (pkmnStatOffsetY * 1), hpText, hpTextColor, shadowcolor)
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 2), levelEvoText, levelEvoTextColor, shadowcolor)

	if Tracker.Data.isViewingOwn and Tracker.Data.inBattle == false and pokemon.status ~= MiscData.StatusType.None then
		Drawing.drawStatusIcon(MiscData.StatusCodeMap[pokemon.status], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 30 - 16 + 1, Constants.SCREEN.MARGIN + 1)
	end

	-- HELD ITEM AND ABILITIES
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
		if trackedAbilities[1].id ~= nil and trackedAbilities[1].id ~= 0 then
			abilityStringTop = MiscData.Abilities[trackedAbilities[1].id] .. " /"
			abilityStringBot = "?"
		end
		if trackedAbilities[2].id ~= nil and trackedAbilities[2].id ~= 0 then
			abilityStringBot = MiscData.Abilities[trackedAbilities[2].id]
		end
	end

	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 3), abilityStringTop, Theme.COLORS["Intermediate text"], shadowcolor)
	Drawing.drawText(Constants.SCREEN.WIDTH + pkmnStatOffsetX, pkmnStatStartY + (pkmnStatOffsetY * 4), abilityStringBot, Theme.COLORS["Intermediate text"], shadowcolor)

	-- Draw notepad icon near abilities area, for manually tracking the abilities
	if Tracker.Data.inBattle and not Tracker.Data.isViewingOwn then
		if trackedAbilities[1].id == 0 and trackedAbilities[2].id == 0 then
			Drawing.drawButton(TrackerScreen.Buttons.AbilityTracking, shadowcolor)
		end
	end

	-- HEALS INFO / ENCOUNTER INFO
	local infoBoxHeight = 23
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 52, 96, infoBoxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	if Tracker.Data.isViewingOwn then
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 57, "Heals in Bag:", Theme.COLORS["Default text"], shadowcolor)
		local healPercentage = math.min(9999, Tracker.Data.healingItems.healing)
		local healCount = math.min(99, Tracker.Data.healingItems.numHeals)
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 67, string.format("%.0f%%", healPercentage) .. " HP (" .. healCount .. ")", Theme.COLORS["Default text"], shadowcolor)

		if (Options["Track PC Heals"]) then
			Drawing.drawText(Constants.SCREEN.WIDTH + 60, 57, "PC Heals:", Theme.COLORS["Default text"], shadowcolor)
			-- Right-align the PC Heals number
			local healNumberSpacing = (2 - string.len(tostring(Tracker.Data.centerHeals))) * 5 + 75
			Drawing.drawText(Constants.SCREEN.WIDTH + healNumberSpacing, 67, Tracker.Data.centerHeals, Utils.getCenterHealColor(), shadowcolor)

			-- Draw the '+'', '-'', and toggle button for auto PC tracking
			local incBtn = TrackerScreen.Buttons.PCHealIncrement
			local decBtn = TrackerScreen.Buttons.PCHealDecrement
			gui.drawText(incBtn.box[1] + 1, incBtn.box[2] + 1, incBtn.text, shadowcolor, nil, 5, Constants.Font.FAMILY)
			gui.drawText(incBtn.box[1], incBtn.box[2], incBtn.text, Theme.COLORS[incBtn.textColor], nil, 5, Constants.Font.FAMILY)
			gui.drawText(decBtn.box[1] + 1, decBtn.box[2] + 1, decBtn.text, shadowcolor, nil, 5, Constants.Font.FAMILY)
			gui.drawText(decBtn.box[1], decBtn.box[2], decBtn.text, Theme.COLORS[decBtn.textColor], nil, 5, Constants.Font.FAMILY)

			-- Auto-tracking PC Heals button
			Drawing.drawButton(TrackerScreen.Buttons.PCHealAutoTracking, shadowcolor)
		end
	else
		if Tracker.Data.trainerID ~= nil and pokemon.trainerID ~= nil then
			local routeName = Constants.BLANKLINE
			if RouteData.hasRoute(Program.CurrentRoute.mapId) then
				routeName = RouteData.Info[Program.CurrentRoute.mapId].name or Constants.BLANKLINE
			end
			-- Check if trainer encounter or wild pokemon encounter (trainerID's will match if its a wild pokemon)
			local isWild = Tracker.Data.trainerID == pokemon.trainerID
			local encounterText = Tracker.getEncounters(pokemon.pokemonID, isWild)
			if encounterText > 999 then encounterText = 999 end
			if isWild then
				encounterText = "Seen in the wild: " .. encounterText
			else
				encounterText = "Seen on trainers: " .. encounterText
			end

			Drawing.drawButton(TrackerScreen.Buttons.RouteDetails, shadowcolor)
			Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11, Constants.SCREEN.MARGIN + 53, encounterText, Theme.COLORS["Default text"], shadowcolor)
			Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11, Constants.SCREEN.MARGIN + 63, routeName, Theme.COLORS["Default text"], shadowcolor)
		end
	end
end

function Drawing.drawStatsArea(pokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local statBoxWidth = 101
	local statOffsetX = Constants.SCREEN.WIDTH + statBoxWidth + 1
	local statOffsetY = 7

	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + statBoxWidth, 5, Constants.SCREEN.RIGHT_GAP - statBoxWidth - 5, 75, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Draw the six primary stats
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
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
		gui.drawText(statOffsetX + 16, statOffsetY - 1, natureSymbol, textColor, nil, 5, Constants.Font.FAMILY)

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
			Drawing.drawButton(TrackerScreen.Buttons[statKey], shadowcolor)
		end
		statOffsetY = statOffsetY + 10
	end

	-- Draw BST
	Drawing.drawText(statOffsetX, statOffsetY, "BST", Theme.COLORS["Default text"], shadowcolor)
	Drawing.drawText(statOffsetX + 25, statOffsetY, pokemon.bst, Theme.COLORS["Default text"], shadowcolor)

	-- If controller is in use and highlighting any stats, draw that
	Drawing.drawInputOverlay()
end

function Drawing.drawMovesArea(pokemon, opposingPokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local movesLearnedHeader = "Move ~  " .. Utils.getMovesLearnedHeader(pokemon.pokemonID, pokemon.level)
	local moveTableHeaderHeightDiff = 13
	local moveOffsetY = 94

	local moveCatOffset = 7
	local moveNameOffset = 6 -- Move names (longest name is 12 characters?)
	local movePPOffset = 82
	local movePowerOffset = 102
	local moveAccOffset = 126

	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])

	-- Draw move headers
	gui.defaultTextBackground(Theme.COLORS["Main background"])
	Drawing.drawText(Constants.SCREEN.WIDTH + moveNameOffset - 1, moveOffsetY - moveTableHeaderHeightDiff, movesLearnedHeader, Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + movePPOffset, moveOffsetY - moveTableHeaderHeightDiff, "PP", Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + movePowerOffset, moveOffsetY - moveTableHeaderHeightDiff, "Pow", Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + moveAccOffset, moveOffsetY - moveTableHeaderHeightDiff, "Acc", Theme.COLORS["Header text"], bgHeaderShadow)

	-- Draw the Moves view box
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, moveOffsetY - 2, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 46, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	if Options["Show physical special icons"] then -- Check if move categories will be drawn
		moveNameOffset = moveNameOffset + 8
	end
	if not Theme.MOVE_TYPES_ENABLED then -- Check if move type will be drawn as a rectangle
		moveNameOffset = moveNameOffset + 5
	end

	local stars = { "", "", "", "" }
	if not Tracker.Data.isViewingOwn then
		stars = Utils.calculateMoveStars(pokemon.pokemonID, pokemon.level)
	end
	local trackedMoves = Tracker.getMoves(pokemon.pokemonID)

	-- Draw all four moves
	for moveIndex = 1, 4, 1 do
		-- If the Pokemon doesn't belong to the player, pull move data from tracked data
		local moveData = MoveData.BlankMove
		if Tracker.Data.isViewingOwn then
			if pokemon.moves[moveIndex] ~= nil and pokemon.moves[moveIndex].id ~= 0 then
				moveData = MoveData.Moves[pokemon.moves[moveIndex].id]
			end
		elseif trackedMoves ~= nil then
			 if trackedMoves[moveIndex] ~= nil and trackedMoves[moveIndex].id ~= 0 then
				moveData = MoveData.Moves[trackedMoves[moveIndex].id]
			end
		end

		-- Base move data to draw, but much of it will be updated
		local moveName = moveData.name .. stars[moveIndex]
		local moveType = moveData.type
		local moveTypeColor = Constants.MoveTypeColors[moveType]
		local moveCategory = moveData.category
		local movePPText = moveData.pp
		local movePower = moveData.power
		local movePowerColor = Theme.COLORS["Default text"]

		-- HIDDEN POWER TYPE UPDATE
		if Tracker.Data.isViewingOwn and moveData.name == "Hidden Power" then
			moveType = Tracker.getHiddenPowerType()
			moveTypeColor = Utils.inlineIf(moveType == PokemonData.Types.UNKNOWN, Theme.COLORS["Default text"], Constants.MoveTypeColors[moveType])
			moveCategory = MoveData.TypeToCategory[moveType]
		end

		-- MOVE CATEGORY
		if Options["Show physical special icons"] then
			if moveCategory == MoveData.Categories.PHYSICAL then
				Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, Constants.SCREEN.WIDTH + moveCatOffset, moveOffsetY + 2, Theme.COLORS["Default text"], shadowcolor)
			elseif moveCategory == MoveData.Categories.SPECIAL then
				Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, Constants.SCREEN.WIDTH + moveCatOffset, moveOffsetY + 2, Theme.COLORS["Default text"], shadowcolor)
			end
		end

		-- MOVE TYPE COLORED RECTANGLE
		if not Theme.MOVE_TYPES_ENABLED and moveData.name ~= Constants.BLANKLINE then
			gui.drawRectangle(Constants.SCREEN.WIDTH + moveNameOffset - 3, moveOffsetY + 2, 2, 7, moveTypeColor, moveTypeColor)
			moveTypeColor = Theme.COLORS["Default text"]
		end

		-- MOVE PP
		if moveData.pp ~= Constants.NO_PP then
			if Tracker.Data.isViewingOwn then
				movePPText = pokemon.moves[moveIndex].pp
			elseif Options["Count enemy PP usage"] then
				-- Interate over tracked moves, since we don't know the full move list
				for _, move in pairs(pokemon.moves) do
					if tonumber(move.id) == tonumber(moveData.id) then
						movePPText = move.pp
					end
				end
			end
		end

		-- MOVE POWER
		if Tracker.Data.inBattle and Utils.isSTAB(moveData, moveType, pokemon.type) then
			movePowerColor = Theme.COLORS["Positive text"]
		end

		if Options["Calculate variable damage"] then
			if movePower == "WT" and Tracker.Data.inBattle and opposingPokemon ~= nil then
				-- Calculate the power of weight moves in battle
				local targetWeight = PokemonData.Pokemon[opposingPokemon.pokemonID].weight
				movePower = Utils.calculateWeightBasedDamage(targetWeight)
			elseif movePower == "<HP" and Tracker.Data.isViewingOwn then
				-- Calculate the power of flail & reversal moves for player only
				movePower = Utils.calculateLowHPBasedDamage(pokemon.curHP, pokemon.stats.hp)
			elseif movePower == ">HP" and Tracker.Data.isViewingOwn then
				-- Calculate the power of water spout & eruption moves for the player only
				movePower = Utils.calculateHighHPBasedDamage(pokemon.curHP, pokemon.stats.hp)
			end
		end

		-- DRAW MOVE EFFECTIVENESS
		if Options["Show move effectiveness"] and Tracker.Data.inBattle and opposingPokemon ~= nil then
			local effectiveness = Utils.netEffectiveness(moveData, moveType, PokemonData.Pokemon[opposingPokemon.pokemonID].type)
			if effectiveness == 0 then
				Drawing.drawText(Constants.SCREEN.WIDTH + movePowerOffset - 7, moveOffsetY, "X", Theme.COLORS["Negative text"], shadowcolor)
			else
				Drawing.drawMoveEffectiveness(Constants.SCREEN.WIDTH + movePowerOffset - 5, moveOffsetY, effectiveness)
			end
		end

		-- DRAW ALL THE MOVE INFORMATION
		Drawing.drawText(Constants.SCREEN.WIDTH + moveNameOffset, moveOffsetY, moveName, moveTypeColor, shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + movePPOffset, moveOffsetY, movePPText, 2, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + movePowerOffset, moveOffsetY, movePower, 3, movePowerColor, shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + moveAccOffset, moveOffsetY, moveData.accuracy, 3, Theme.COLORS["Default text"], shadowcolor)

		moveOffsetY = moveOffsetY + 10 -- linespacing
	end
end

function Drawing.drawCarouselArea(pokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 136, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 19, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	local carousel = TrackerScreen.getCurrentCarouselItem()
	for _, content in pairs(carousel.getContentList(pokemon)) do
		if content.type == Constants.ButtonTypes.IMAGE or content.type == Constants.ButtonTypes.PIXELIMAGE then
			Drawing.drawButton(content, shadowcolor)
		elseif type(content) == "string" then
			local wrappedText = Utils.getWordWrapLines(content, 34) -- was 31

			if #wrappedText == 1 then
				Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, wrappedText[1], Theme.COLORS["Default text"], shadowcolor)
			elseif #wrappedText >= 2 then
				Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 136, wrappedText[1], Theme.COLORS["Default text"], shadowcolor)
				Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 145, wrappedText[2], Theme.COLORS["Default text"], shadowcolor)
				gui.drawLine(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 155, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN, 155, Theme.COLORS["Lower box border"])
				gui.drawLine(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 156, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN, 156, Theme.COLORS["Main background"])
			end
		end
	end

	--work around limitation of drawText not having width limit: paint over any spillover
	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
	local y = 137
	gui.drawLine(x, y, x, y + 14, Theme.COLORS["Lower box border"])
	gui.drawRectangle(x + 1, y, 12, 14, Theme.COLORS["Main background"], Theme.COLORS["Main background"])
end

function Drawing.drawOptionsScreen()
	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw Settings screen view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + 5, 5, Constants.SCREEN.RIGHT_GAP - 10, Constants.SCREEN.HEIGHT - 10, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Draw all buttons
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	for _, button in pairs(Options.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Draw Roms folder location, or the notepad icon if it's not set
	local romsButton = Options.Buttons.romsFolder
	local folderText = Utils.truncateRomsFolder(Options.ROMS_FOLDER)
	if folderText ~= "" then
		Drawing.drawText(romsButton.box[1] + 54, romsButton.box[2], folderText, Theme.COLORS[romsButton.textColor], shadowcolor)
	else
		Drawing.drawImageAsPixels(Constants.PixelImages.NOTEPAD, Constants.SCREEN.WIDTH + 60, 7, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(romsButton.box[1] + 65, romsButton.box[2], "(Click a file to set)", Theme.COLORS["Intermediate text"], shadowcolor)
	end

	-- Draw version number, TODO: Someone add a fun easter egg for clicking on it multiple times
	Drawing.drawText(Constants.SCREEN.WIDTH + 87, 142, "v" .. Main.TrackerVersion, Theme.COLORS["Default text"], shadowcolor)
end

function Drawing.drawThemeScreen()
	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw Theme screen view box
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + 5, 5, Constants.SCREEN.RIGHT_GAP - 10, Constants.SCREEN.HEIGHT - 10, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	-- Draw all buttons
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])
	for _, button in pairs(Theme.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

function Drawing.drawInfoScreen()
	if InfoScreen.viewScreen == InfoScreen.Screens.POKEMON_INFO then
		local pokemonID = InfoScreen.infoLookup
		-- Only draw valid pokemon data, pokemonID = 0 is blank move data
		if pokemonID < 1 or pokemonID > #PokemonData.Pokemon then
			Program.changeScreenView(Program.Screens.TRACKER)
		else
			Drawing.drawPokemonInfoScreen(pokemonID)
		end
	elseif InfoScreen.viewScreen == InfoScreen.Screens.MOVE_INFO then
		local moveId = InfoScreen.infoLookup
		-- Only draw valid move data, moveId = 0 is blank move data
		if moveId < 1 or moveId > #MoveData.Moves then
			Program.changeScreenView(Program.Screens.TRACKER)
		else
			Drawing.drawMoveInfoScreen(moveId)
		end
	elseif InfoScreen.viewScreen == InfoScreen.Screens.ROUTE_INFO then
		-- Only draw valid route data
		local mapId = InfoScreen.infoLookup.mapId
		if not RouteData.hasRoute(mapId) then
			Program.changeScreenView(Program.Screens.TRACKER)
		else
			local encounterArea = InfoScreen.infoLookup.encounterArea or RouteData.EncounterArea.LAND
			if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then
				encounterArea = RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
			end
			InfoScreen.TemporaryButtons = InfoScreen.getPokemonButtonsForEncounterArea(mapId, encounterArea)
			Drawing.drawRouteInfoScreen(mapId, encounterArea)
		end
	end
end

function Drawing.drawPokemonInfoScreen(pokemonID)
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)

	-- set the color for text/number shadows for the top boxes
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxInfoBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local offsetColumnX = offsetX + 43
	local offsetY = 0 + Constants.SCREEN.MARGIN + 3
	local linespacing = 10
	local botOffsetY = offsetY + (linespacing * 6) - 2 + 9

	local pokemon = PokemonData.Pokemon[pokemonID]
	local pokemonViewed = Tracker.getViewedPokemon()
	local isTargetTheViewedPokemonn = pokemonViewed.pokemonID == pokemonID

	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- Draw top view box
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, botOffsetY - linespacing - 8, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON NAME
	offsetY = offsetY - 3
	local pokemonName = pokemon.name:upper()
	gui.drawText(offsetX + 1 - 1, offsetY + 1, pokemonName, boxInfoTopShadow, nil, 12, Constants.Font.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY, pokemonName, Theme.COLORS["Default text"], nil, 12, Constants.Font.FAMILY, "bold")

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
	Drawing.drawText(offsetX, botOffsetY, "Learns a move at level:", Theme.COLORS["Default text"], boxInfoBotShadow)
	botOffsetY = botOffsetY + linespacing + 1
	local boxWidth = 16
	local boxHeight = 13
	if #pokemon.movelvls[GameSettings.versiongroup] == 0 then -- If the Pokemon learns no moves at all
		Drawing.drawText(offsetX + 6, botOffsetY, "Does not learn any moves", Theme.COLORS["Default text"], boxInfoBotShadow)
	end
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
	local hasSevereWeakness = false
	for moveType, typeEffectiveness in pairs(MoveData.TypeToEffectiveness) do
		local effectiveness = 1
		if pokemon.type[1] ~= PokemonData.Types.EMPTY and typeEffectiveness[pokemon.type[1]] ~= nil then
			effectiveness = effectiveness * typeEffectiveness[pokemon.type[1]]
		end
		if pokemon.type[2] ~= PokemonData.Types.EMPTY and typeEffectiveness[pokemon.type[2]] ~= nil then
			effectiveness = effectiveness * typeEffectiveness[pokemon.type[2]]
		end
		if effectiveness > 1 then
			weaknesses[moveType] = effectiveness
			if effectiveness > 2 then
				hasSevereWeakness = true
			end
		end
	end
	Drawing.drawText(offsetX, botOffsetY, "Weak to:", Theme.COLORS["Default text"], boxInfoBotShadow)
	if hasSevereWeakness then
		Drawing.drawText(offsetColumnX, botOffsetY, "(white bars = x4 weak)", Theme.COLORS["Default text"], boxInfoBotShadow)
	end
	botOffsetY = botOffsetY + linespacing + 3

	if weaknesses == {} then -- If the Pokemon has no weakness, like Sableye
		Drawing.drawText(offsetX + 6, botOffsetY, "Has no weaknesses", Theme.COLORS["Default text"], boxInfoBotShadow)
	end

	local typeOffsetX = offsetX + 6
	for weakType, effectiveness in pairs(weaknesses) do
		gui.drawRectangle(typeOffsetX, botOffsetY, 31, 13, boxInfoBotShadow)
		gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Lower box border"])
		Drawing.drawTypeIcon(weakType, typeOffsetX, botOffsetY)

		if effectiveness > 2 then
			-- gui.drawRectangle(typeOffsetX - 1, botOffsetY - 1, 31, 13, Theme.COLORS["Negative text"])
			local barColor = 0xFFFFFFFF
			gui.drawLine(typeOffsetX, botOffsetY, typeOffsetX + 29, botOffsetY, barColor)
			gui.drawLine(typeOffsetX, botOffsetY + 1, typeOffsetX + 29, botOffsetY + 1, barColor)
			gui.drawLine(typeOffsetX, botOffsetY + 10, typeOffsetX + 29, botOffsetY + 10, barColor)
			gui.drawLine(typeOffsetX, botOffsetY + 11, typeOffsetX + 29, botOffsetY + 11, barColor)

			-- gui.drawRectangle(typeOffsetX, botOffsetY, 29, 1, Theme.COLORS["Negative text"])
			-- gui.drawRectangle(typeOffsetX, botOffsetY + 10, 29, 1, Theme.COLORS["Negative text"])
		end

		typeOffsetX = typeOffsetX + 31
		if typeOffsetX > Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - 30 then
			typeOffsetX = offsetX + 6
			botOffsetY = botOffsetY + 13
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.lookupPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.nextPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.previousPokemon, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.close, boxInfoBotShadow)
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
	local botOffsetY = offsetY + (linespacing * 7) + 7

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
	gui.drawText(offsetX + 1 - 1, offsetY + 1 - 3, moveName, boxInfoTopShadow, nil, 12, Constants.Font.FAMILY, "bold")
	gui.drawText(offsetX - 1, offsetY - 3, moveName, Theme.COLORS["Default text"], nil, 12, Constants.Font.FAMILY, "bold")

	-- If the move is Hidden Power and the lead pokemon has that move, use its tracked type/category instead
	if moveId == 237 then -- 237 = Hidden Power
		local pokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
		if Utils.pokemonHasMove(pokemon, "Hidden Power") then
			moveType = Tracker.getHiddenPowerType()
			moveCat = MoveData.TypeToCategory[moveType]
			Drawing.drawText(offsetX + 96, offsetY + linespacing * 2 - 4, "Set type ^", Theme.COLORS["Positive text"], boxInfoTopShadow)
		end
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
		Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, offsetColumnX + 36, offsetY + 2, Theme.COLORS["Default text"], boxInfoTopShadow)
	elseif moveCat == MoveData.Categories.SPECIAL then
		categoryInfo = categoryInfo .. "Special"
		Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, offsetColumnX + 33, offsetY + 2, Theme.COLORS["Default text"], boxInfoTopShadow)
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
	local powerInfo = move.power
	if move.power == Constants.NO_POWER then
		powerInfo = Constants.BLANKLINE
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
	Drawing.drawButton(InfoScreen.Buttons.lookupMove, boxInfoTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.close, boxInfoBotShadow)

	-- Easter egg
	if moveId == 150 then -- 150 = Splash
		Drawing.drawPokemonIcon(129, offsetX + 16, botOffsetY + 8)
		Drawing.drawPokemonIcon(129, offsetX + 40, botOffsetY - 8)
		Drawing.drawPokemonIcon(129, offsetX + 75, botOffsetY + 2)
		Drawing.drawPokemonIcon(129, offsetX + 99, botOffsetY - 16)
	end
end

function Drawing.drawRouteInfoScreen(mapId, encounterArea)
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local boxTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local boxBotShadow = Utils.calcShadowColor(Theme.COLORS["Lower box background"])
	local boxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local boxWidth = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local boxTopY = Constants.SCREEN.MARGIN
	local boxTopHeight = 30
	local botBoxY = boxTopY + boxTopHeight + 12
	local botBoxHeight = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - botBoxY

	-- Fill background and margins
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Theme.COLORS["Main background"], Theme.COLORS["Main background"])

	-- TOP BOX VIEW
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(boxX, boxTopY, boxWidth, boxTopHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- ROUTE NAME
	local routeName = RouteData.Info[mapId].name or Constants.BLANKLINE
	Drawing.drawImageAsPixels(Constants.PixelImages.MAP_PINDROP, boxX + 3, boxTopY + 3, Theme.COLORS["Default text"], boxTopShadow)
	Drawing.drawText(boxX + 13, boxTopY + 2, routeName, Theme.COLORS["Default text"], boxTopShadow)

	if InfoScreen.revealOriginalRoute then
		local originalShownText = "Showing original " .. Constants.Words.POKEMON .. " data"
		Drawing.drawText(boxX + 6, boxTopY + 16, originalShownText, Theme.COLORS["Positive text"], boxTopShadow)
	else
		Drawing.drawButton(InfoScreen.Buttons.showOriginalRoute, boxTopShadow)
	end

	-- BOT BOX VIEW
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	local encounterHeaderText = Constants.Words.POKEMON .. " seen by " .. encounterArea
	if encounterArea == RouteData.EncounterArea.STATIC then
		encounterHeaderText = encounterHeaderText .. " encounters"
	end
	Drawing.drawText(boxX - 1, botBoxY - 11, encounterHeaderText, Theme.COLORS["Header text"], bgHeaderShadow)
	gui.drawRectangle(boxX, botBoxY, boxWidth, botBoxHeight, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	-- POKEMON SEEN
	local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
	for _, iconButton in pairs(InfoScreen.TemporaryButtons) do
		if iconButton.pokemonID == 252 and not Options["Pokemon Stadium portraits"] then -- Question mark icon
			iconButton.box[2] = iconButton.box[2] + 4
		end

		local x = iconButton.box[1]
		local y = iconButton.box[2]
		Drawing.drawButton(iconButton, boxBotShadow)

		if iconButton.rate ~= nil then -- Typically rates aren't known unless 'InfoScreen.revealOriginalRoute'
			local rateText = (iconButton.rate * 100) .. "%"
			local rateOffset = Utils.inlineIf(iconButton.rate == 1.00, 5, Utils.inlineIf(iconButton.rate >= 0.1, 7, 9)) -- centering
			gui.drawRectangle(x + 1, y, 30, 8, Theme.COLORS["Lower box background"], Theme.COLORS["Lower box background"])
			Drawing.drawText(x + rateOffset, y - 1, rateText, Theme.COLORS["Default text"], boxBotShadow)
		end
	end

	-- Draw all buttons
	Drawing.drawButton(InfoScreen.Buttons.lookupRoute, boxTopShadow)
	Drawing.drawButton(InfoScreen.Buttons.showMoreRouteEncounters, boxBotShadow)
	Drawing.drawButton(InfoScreen.Buttons.close, boxBotShadow)
end

function Drawing.drawImageAsPixels(imageArray, x, y, color, shadowcolor)
	for rowIndex = 1, #imageArray, 1 do
		for colIndex = 1, #(imageArray[1]) do
			if imageArray[rowIndex][colIndex] ~= 0 then
				local offsetX = colIndex - 1
				local offsetY = rowIndex - 1

				if shadowcolor ~= nil then
					gui.drawPixel(x + offsetX + 1, y + offsetY + 1, shadowcolor)
				end
				gui.drawPixel(x + offsetX, y + offsetY, color)
			end
		end
	end
end

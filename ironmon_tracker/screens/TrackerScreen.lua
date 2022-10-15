TrackerScreen = {}

TrackerScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconPath = function(self)
			local pokemonID = 0
			local pokemon = Tracker.getViewedPokemon()
			--Don't want to consider Ghost a valid pokemon, but do want to use its ID (413) for the image name
			if pokemon ~= nil and (PokemonData.isImageIDValid(pokemon.pokemonID)) then
				pokemonID = pokemon.pokemonID
			end
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. pokemonID .. iconset.extension
			return imagepath
		end,
		clickableArea = { Constants.SCREEN.WIDTH + 5, 5, 32, 29 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, -1, 32, 32 },
		isVisible = function() return true end,
		onClick = function(self)
			if not self:isVisible() then return end
			local pokemon = Tracker.getViewedPokemon()
			local pokemonID = 0
			if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
				pokemonID = pokemon.pokemonID
			end
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemonID)
		end
	},
	SettingsGear = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 7, 7, 7 },
		isVisible = function() return true end,
		onClick = function(self)
			if not self:isVisible() then return end
			Program.changeScreenView(Program.Screens.NAVIGATION)
		end
	},
	RerollBallPicker = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DICE,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, Constants.SCREEN.MARGIN + 36, 13, 14 },
		isVisible = function() return TrackerScreen.canShowBallPicker() end,
		onClick = function(self)
			TrackerScreen.PokeBalls.chosenBall = -1
			Program.redraw(true)
			TrackerScreen.randomlyChooseBall()
		end
	},
	PCHealAutoTracking = {
		type = Constants.ButtonTypes.CHECKBOX,
		text = "",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 89, 68, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		toggleState = false,
		toggleColor = "Positive text",
		isVisible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			if not self:isVisible() then return end

			self.toggleState = not self.toggleState
			Program.redraw(true)
		end
	},
	PCHealIncrement = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "+",
		textColor = "Positive text",
		box = { Constants.SCREEN.WIDTH + 70, 67, 8, 4 },
		isVisible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			if not self:isVisible() then return end

			Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
			-- Prevent triple digit values (shouldn't go anywhere near this in survival)
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			Program.redraw(true)
		end
	},
	PCHealDecrement = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = Constants.BLANKLINE,
		textColor = "Negative text",
		box = { Constants.SCREEN.WIDTH + 70, 73, 7, 4 },
		isVisible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			if not self:isVisible() then return end

			Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
			-- Prevent negative values
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			Program.redraw(true)
		end
	},
	RouteDetails = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		text = "",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 57, 96, 23 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 63, 8, 12 },
		isVisible = function() return not Tracker.Data.isViewingOwn end,
		onClick = function(self)
			if not self:isVisible() then return end
			if not RouteData.hasRouteEncounterArea(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea) then return end

			local routeInfo = {
				mapId = Battle.CurrentRoute.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	},
	AbilityUpper = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + 37, 35, 63, 11},
		box = { Constants.SCREEN.WIDTH + 88, 43, 11, 11 },
		isVisible = function() return not Tracker.Data.isViewingOwn end,
		onClick = function(self)
			if not self:isVisible() then return end
			local pokemon = Tracker.getViewedPokemon()
			if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
				local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, trackedAbilities[1].id)
			end
		end
	},
	AbilityLower = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + 37, 46, 63, 11},
		box = { Constants.SCREEN.WIDTH + 88, 43, 11, 11 },
		isVisible = function() return true end,
		onClick = function(self)
			if not self:isVisible() then return end
			local pokemon = Tracker.getViewedPokemon()
			if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
				local abilityId
				if Tracker.Data.isViewingOwn then
					abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
				else
					local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)
					abilityId = trackedAbilities[2].id
				end
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, abilityId)
			end
		end
	},
	NotepadTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		text = "(Leave a note)",
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 11, 11 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES end,
		onClick = function(self)
			if not self:isVisible() then return end
			local pokemon = Tracker.getViewedPokemon()
			if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
				TrackerScreen.openNotePadWindow(pokemon.pokemonID)
			end
		end
	},
	LastAttackSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SWORD_ATTACK,
		text = "",
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 140, 13, 13 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.LAST_ATTACK end,
		onClick = function(self)
			if not self:isVisible() then return end
			-- Eventually clicking this will show a Move History screen
		end
	},
	RouteSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		text = "",
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 8, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			local routeInfo = {
				mapId = Battle.CurrentRoute.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	},
}

TrackerScreen.CarouselTypes = {
    BADGES = 1, -- Outside of battle
	LAST_ATTACK = 2, -- During battle, only between turns
	ROUTE_INFO = 3, -- During battle, only if encounter is a wild pokemon
	NOTES = 4, -- During new game intro or inside of battle
}

TrackerScreen.carouselIndex = 1
TrackerScreen.tipMessageIndex = 0
TrackerScreen.CarouselItems = {}
TrackerScreen.nextMoveLevelHighlight = 0xFFFFFF00

TrackerScreen.PokeBalls = {
	chosenBall = -1,
	ColorList = { 0xFF000000, 0xFFF04037, 0xFFFFFFFF, }, -- Colors used to draw all Pokeballs
	ColorListGray = { 0xFF000000, Utils.calcGrayscale(0xFFF04037, 0.6), 0xFFFFFFFF, },
	Labels = {
		[1] = "Left",
		[2] = "Middle",
		[3] = "Right",
	},
	Left = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 17,
		y = Constants.SCREEN.MARGIN + 18,
	},
	Middle = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 40,
		y = Constants.SCREEN.MARGIN + 26,
	},
	Right = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 63,
		y = Constants.SCREEN.MARGIN + 18,
	},
}

function TrackerScreen.initialize()
	-- Buttons for stat markings tracked by the user
	local heightOffset = 9
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		TrackerScreen.Buttons[statKey] = {
			type = Constants.ButtonTypes.STAT_STAGE,
			text = "",
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + 129, heightOffset, 8, 8 },
			boxColors = { "Upper box border", "Upper box background" },
			statStage = statKey,
			statState = 0,
			isVisible = function() return Battle.inBattle and not Tracker.Data.isViewingOwn end,
			onClick = function(self)
				if not self:isVisible() then return end

				self.statState = ((self.statState + 1) % 3)
				self.text = Constants.STAT_STATES[self.statState].text
				self.textColor = Constants.STAT_STATES[self.statState].textColor

				local pokemon = Battle.getViewedPokemon(false)
				if pokemon ~= nil then
					Tracker.TrackStatMarking(pokemon.pokemonID, self.statStage, self.statState)
				end
				Program.redraw(true)
			end
		}

		heightOffset = heightOffset + 10
	end

	-- Buttons for each badge
	local badgeWidth = 16
	for index = 1, 8, 1 do
		local badgeName = "badge" .. index
		local xOffset = Constants.SCREEN.WIDTH + 7 + ((index-1) * (badgeWidth + 1)) + GameSettings.badgeXOffsets[index]

		TrackerScreen.Buttons[badgeName] = {
			type = Constants.ButtonTypes.IMAGE,
			image = Main.DataFolder .. "/images/badges/" .. GameSettings.badgePrefix .. "_badge" .. index .. "_OFF.png",
			box = { xOffset, 138, badgeWidth, badgeWidth },
			badgeIndex = index,
			badgeState = 0,
			isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.BADGES end,
			updateState = function(self, state)
				-- Update image path if the state has changed
				if self.badgeState ~= state then
					self.badgeState = state
					local badgeOffText = Utils.inlineIf(self.badgeState == 0, "_OFF", "")
					self.image = Main.DataFolder .. "/images/badges/" .. GameSettings.badgePrefix .. "_badge" .. self.badgeIndex .. badgeOffText .. ".png"
				end
			end
		}
	end

	-- Set the color for next move level highlighting for the current theme now, instead of constantly re-calculating it
	TrackerScreen.getNextMoveLevelHighlight(true)
	TrackerScreen.buildCarousel()

	TrackerScreen.randomlyChooseBall()
end

-- Calculates a color for the next move level highlighting based off contrast ratios of chosen theme colors
function TrackerScreen.getNextMoveLevelHighlight(forced)
	if not forced and not Theme.settingsUpdated then return end
	local mainBGColor = Theme.COLORS["Main background"]
	local maxContrast = 0
	local colorKey = ""
	for key, color in pairs(Theme.COLORS) do
		if color ~= mainBGColor and color ~= Theme.COLORS["Header text"] and color ~= Theme.COLORS["Default text"] then
			local bgContrast = Utils.calculateContrastRatio(color, mainBGColor)
			if bgContrast > maxContrast then
				maxContrast = bgContrast
				colorKey = key
			end
		end
	end
	TrackerScreen.nextMoveLevelHighlight =  Theme.COLORS[colorKey]
end

-- Define each Carousel Item, must will have blank data that will be populated later with contextual data
function TrackerScreen.buildCarousel()
	--  BADGE
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.BADGES] = {
		type = TrackerScreen.CarouselTypes.BADGES,
		isVisible = function() return Tracker.Data.isViewingOwn end,
		framesToShow = 210,
		getContentList = function()
			local badgeButtons = {}
			for index = 1, 8, 1 do
				local badgeName = "badge" .. index
				table.insert(badgeButtons, TrackerScreen.Buttons[badgeName])
			end
			return badgeButtons
		end,
	}

	-- NOTES
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.NOTES] = {
		type = TrackerScreen.CarouselTypes.NOTES,
		isVisible = function() return not Tracker.Data.isViewingOwn end,
		framesToShow = 180,
		getContentList = function(pokemon)
			-- If the player doesn't have a Pokemon, display something else useful instead
			if pokemon.pokemonID == 0 then
				return { Constants.OrderedLists.TIPS[TrackerScreen.tipMessageIndex] }
			end
			if pokemon.pokemonID == 413 then
				return {"Spoooky!"}
			end
			local noteText = Tracker.getNote(pokemon.pokemonID)
			if noteText ~= nil and noteText ~= "" then
				return { noteText }
			else
				return { TrackerScreen.Buttons.NotepadTracking }
			end
		end,
	}

	-- LAST ATTACK
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.LAST_ATTACK] = {
		type = TrackerScreen.CarouselTypes.LAST_ATTACK,
		-- Don't show the last attack information while the enemy is attacking, or it spoils the move & damage
		isVisible = function() return (not Tracker.Data.isViewingOwn or not Options["Disable mainscreen carousel"]) and Options["Show last damage calcs"] and Battle.inBattle and not Battle.enemyHasAttacked and Battle.lastEnemyMoveId ~= 0 end,
		framesToShow = 180,
		getContentList = function()
			local lastAttackMsg
			-- Currently this only records last move used for damaging moves
			if MoveData.isValid(Battle.lastEnemyMoveId) then
				local moveInfo = MoveData.Moves[Battle.lastEnemyMoveId]
				if Battle.damageReceived > 0 then
					lastAttackMsg = moveInfo.name .. ": " .. Battle.damageReceived .. " damage"
					local ownPokemon = Battle.getViewedPokemon(true)
					if ownPokemon ~= nil and Battle.damageReceived >= ownPokemon.curHP then
						-- Warn user that the damage taken is potentially lethal
						TrackerScreen.Buttons.LastAttackSummary.textColor = "Negative text"
					else
						TrackerScreen.Buttons.LastAttackSummary.textColor = "Lower box text"
					end
				else
					lastAttackMsg = "Last move: " .. moveInfo.name
				end
			else
				lastAttackMsg = "Waiting for a new move..."
			end

			TrackerScreen.Buttons.LastAttackSummary.text = lastAttackMsg
			return { TrackerScreen.Buttons.LastAttackSummary }
		end,
	}

	-- ROUTE INFO
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.ROUTE_INFO] = {
		type = TrackerScreen.CarouselTypes.ROUTE_INFO,
		isVisible = function() return (not Tracker.Data.isViewingOwn or not Options["Disable mainscreen carousel"]) and Battle.inBattle and Battle.CurrentRoute.hasInfo end,
		framesToShow = 180,
		getContentList = function(pokemon)
			local routeInfo = RouteData.Info[Battle.CurrentRoute.mapId]
			local totalPossible = RouteData.countPokemonInArea(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea)
			local routeEncounters = Tracker.getRouteEncounters(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea)
			local totalSeen = #routeEncounters

			if Battle.CurrentRoute.encounterArea == RouteData.EncounterArea.ROCKSMASH then
				TrackerScreen.Buttons.RouteSummary.text = "Rock Smash: " .. totalSeen .. "/" .. totalPossible .. " " .. Constants.Words.POKEMON
			else
				TrackerScreen.Buttons.RouteSummary.text = Battle.CurrentRoute.encounterArea .. ": Seen " .. totalSeen .. "/" .. totalPossible .. " " .. Constants.Words.POKEMON
			end

			return { TrackerScreen.Buttons.RouteSummary }
		end,
	}
end

-- Returns the current visible carousel. If unavailable, looks up the next visible carousel
function TrackerScreen.getCurrentCarouselItem()
	local carousel = TrackerScreen.CarouselItems[TrackerScreen.carouselIndex]

	-- Adjust rotation delay check for carousel based on the speed of emulation
	local fpsMultiplier = math.max(client.get_approx_framerate() / 60, 1) -- minimum of 1
	local adjustedVisibilityFrames = carousel.framesToShow * fpsMultiplier

	-- Check if the current carousel's time has expired, or if it shouldn't be shown
	if carousel == nil or not carousel.isVisible() or Program.Frames.carouselActive > adjustedVisibilityFrames then
		local nextCarousel = TrackerScreen.getNextVisibleCarouselItem(TrackerScreen.carouselIndex)
		TrackerScreen.carouselIndex = nextCarousel.type
		Program.Frames.carouselActive = 0

		-- When carousel switches to the Notes display, prepare the next tip message to display
		if false and nextCarousel ~= carousel and TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES then -- currently disabled, will use later
			local numTips = #Constants.OrderedLists.TIPS
			if TrackerScreen.tipMessageIndex == numTips then
				TrackerScreen.tipMessageIndex = 2 -- Skip "helpful tip" message if that's next up
			else
				TrackerScreen.tipMessageIndex = (TrackerScreen.tipMessageIndex % numTips) + 1
			end
		end

		return nextCarousel
	end

	return carousel
end

function TrackerScreen.getNextVisibleCarouselItem(startIndex)
	local numItems = #TrackerScreen.CarouselItems
	local nextIndex = (startIndex % numItems) + 1
	local carousel = TrackerScreen.CarouselItems[nextIndex]

	while (nextIndex ~= startIndex and not carousel.isVisible()) do
		nextIndex = (nextIndex % numItems) + 1
		carousel = TrackerScreen.CarouselItems[nextIndex]
	end

	return carousel
end

function TrackerScreen.updateButtonStates()
	local opposingPokemon = Battle.getViewedPokemon(false)
	if opposingPokemon ~= nil then
		local statMarkings = Tracker.getStatMarkings(opposingPokemon.pokemonID)

		for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local button = TrackerScreen.Buttons[statKey]
			local statValue = statMarkings[statKey]

			button.statState = statValue
			button.text = Constants.STAT_STATES[statValue].text
			button.textColor = Constants.STAT_STATES[statValue].textColor
		end
	end
end

function TrackerScreen.openNotePadWindow(pokemonId)
	if pokemonId == nil or pokemonId == 0 then return end

	Program.destroyActiveForm()
	local noteForm = forms.newform(465, 220, "Leave a Note", function() client.unpause() end)
	Program.activeFormId = noteForm
	Utils.setFormLocation(noteForm, 100, 50)

	forms.label(noteForm, "Enter a note for " .. PokemonData.Pokemon[pokemonId].name .. " (70 char. max):", 9, 10, 300, 20)
	local noteTextBox = forms.textbox(noteForm, Tracker.getNote(pokemonId), 430, 20, nil, 10, 30)

	local abilityList = {}
	table.insert(abilityList, Constants.BLANKLINE)
	abilityList = AbilityData.populateAbilityDropdown(abilityList)

	local trackedAbilities = Tracker.getAbilities(pokemonId)

	forms.label(noteForm, "Select one or both abilities for " .. PokemonData.Pokemon[pokemonId].name .. ":", 9, 60, 220, 20)
	local abilityOneDropdown = forms.dropdown(noteForm, {["Init"]="Loading Ability1"}, 10, 80, 145, 30)
	forms.setdropdownitems(abilityOneDropdown, abilityList, true) -- true = alphabetize list
	forms.setproperty(abilityOneDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(abilityOneDropdown, "AutoCompleteMode", "Append")
	local abilityTwoDropdown = forms.dropdown(noteForm, {["Init"]="Loading Ability2"}, 10, 110, 145, 30)
	forms.setdropdownitems(abilityTwoDropdown, abilityList, true) -- true = alphabetize list
	forms.setproperty(abilityTwoDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(abilityTwoDropdown, "AutoCompleteMode", "Append")

	if trackedAbilities[1].id ~= 0 then
		forms.settext(abilityOneDropdown, AbilityData.Abilities[trackedAbilities[1].id].name)
	end
	if trackedAbilities[2].id ~= 0 then
		forms.settext(abilityTwoDropdown, AbilityData.Abilities[trackedAbilities[2].id].name)
	end

	forms.button(noteForm, "Save && Close", function()

		local formInput = forms.gettext(noteTextBox)
		local abilityOneText = forms.gettext(abilityOneDropdown)
		local abilityTwoText = forms.gettext(abilityTwoDropdown)
		--local pokemonViewed = Tracker.getViewedPokemon()
		if formInput ~= nil then
			Tracker.TrackNote(pokemonId, formInput)
			Tracker.setAbilities(pokemonId, abilityOneText, abilityTwoText)
			Program.redraw(true)
		end
		forms.destroy(noteForm)
		client.unpause()
		Program.redraw(true)
		forms.destroy(noteForm)
	end, 85, 145, 85, 25)
	forms.button(noteForm, "Clear Abilities", function()
		forms.settext(abilityOneDropdown, Constants.BLANKLINE)
		forms.settext(abilityTwoDropdown, Constants.BLANKLINE)
	end, 180, 145, 105, 25)
	forms.button(noteForm, "Cancel", function()
		client.unpause()
		forms.destroy(noteForm)
	end, 295, 145, 55, 25)
end

function TrackerScreen.randomlyChooseBall()
	TrackerScreen.PokeBalls.chosenBall = math.random(3)
end

function TrackerScreen.canShowBallPicker()
	-- If the player is in the lab without any Pokemon
	return Options["Show random ball picker"] and RouteData.Locations.IsInLab[Battle.CurrentRoute.mapId] and Tracker.getPokemon(1, true) == nil
end

-- DRAWING FUNCTIONS
function TrackerScreen.drawScreen()
	TrackerScreen.updateButtonStates()

	--Assume we are always looking at the left pokemon on the opposing side for move effectiveness
	local viewedPokemon
	local opposingPokemon
	if Tracker.Data.isViewingOwn then
		viewedPokemon = Battle.getViewedPokemon(true)
		opposingPokemon = Tracker.getPokemon(Battle.Combatants.LeftOther, false)
	else
		viewedPokemon = Battle.getViewedPokemon(false)
		opposingPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn, true)
	end

	if viewedPokemon == nil or viewedPokemon.pokemonID == 0 or not Program.isInValidMapLocation() then
		viewedPokemon = Tracker.getDefaultPokemon()
	elseif not Tracker.Data.hasCheckedSummary then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = viewedPokemon.pokemonID
		defaultPokemon.level = viewedPokemon.level
		viewedPokemon = defaultPokemon
	end

	-- Add in Pokedex information about the Pokemon
	if PokemonData.isValid(viewedPokemon.pokemonID) then
		local pokedexInfo = PokemonData.Pokemon[viewedPokemon.pokemonID]
		for key, value in pairs(pokedexInfo) do
			viewedPokemon[key] = value
		end
	end

	Drawing.drawBackgroundAndMargins()

	if TrackerScreen.canShowBallPicker() then
		TrackerScreen.drawBallPicker()
	else
		TrackerScreen.drawPokemonInfoArea(viewedPokemon)
	end
	TrackerScreen.drawStatsArea(viewedPokemon)
	TrackerScreen.drawMovesArea(viewedPokemon, opposingPokemon)
	TrackerScreen.drawCarouselArea(viewedPokemon)
end

function TrackerScreen.drawPokemonInfoArea(pokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	-- Draw top box view
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, 96, 52, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])
	local typesData = {
		pokemon.types[1],
		pokemon.types[2],
	}
	if Battle.inBattle and (Tracker.Data.isViewingOwn or not Battle.isGhost) then
		--update displayed types as typing changes (i.e. Color Change)
		typesData = Program.getPokemonTypes(Tracker.Data.isViewingOwn, Battle.isViewingLeft)
	end
	-- POKEMON ICON & TYPES
	Drawing.drawButton(TrackerScreen.Buttons.PokemonIcon, shadowcolor)
	if not Options["Reveal info if randomized"] and not Tracker.Data.isViewingOwn and PokemonData.IsRand.pokemonTypes then
		-- Don't reveal randomized Pokemon types for enemies
		Drawing.drawTypeIcon(PokemonData.Types.UNKNOWN, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
	else
		Drawing.drawTypeIcon(typesData[1], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
		if typesData[2] ~= typesData[1] then
			Drawing.drawTypeIcon(typesData[2], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 45)
		end
	end

	-- SETTINGS GEAR
	Drawing.drawButton(TrackerScreen.Buttons.SettingsGear, shadowcolor)

	-- POKEMON INFORMATION
	local offsetX = 36
	local offsetY = 5
	local linespacing = Constants.SCREEN.LINESPACING - 1

	local extraInfoText
	local extraInfoColor

	if Tracker.Data.isViewingOwn then
		if pokemon.stats.hp <= 0 then
			extraInfoText = string.format("%s/%s", Constants.HIDDEN_INFO, Constants.HIDDEN_INFO)
			extraInfoColor = Theme.COLORS["Default text"]
		else
			extraInfoText = string.format("%s/%s", pokemon.curHP, pokemon.stats.hp)

			local hpPercentage = pokemon.curHP / pokemon.stats.hp
			if hpPercentage <= 0.2 then
				extraInfoColor = Theme.COLORS["Negative text"]
			elseif hpPercentage <= 0.5 then
				extraInfoColor = Theme.COLORS["Intermediate text"]
			else
				extraInfoColor = Theme.COLORS["Default text"]
			end
		end
	else
		local lastLevel = Tracker.getLastLevelSeen(pokemon.pokemonID)
		if lastLevel ~= nil then
			extraInfoText = string.format("Last seen Lv.%s", lastLevel)
		else
			extraInfoText = Constants.BLANKLINE
		end
		extraInfoColor = Theme.COLORS["Intermediate text"]
	end

	local levelEvoText = "Lv." .. pokemon.level .. " ("
	local evoDetails = pokemon.evolution
	local evoSpacing = offsetX + string.len(levelEvoText) * 3 + string.len(pokemon.level) * 2

	-- Determine if evolution is possible/soon for own pokemon
	local evoTextColor = Theme.COLORS["Default text"]
	if Tracker.Data.isViewingOwn then
		if Utils.isReadyToEvolveByLevel(evoDetails, pokemon.level) or Utils.isReadyToEvolveByStone(evoDetails) then
			evoTextColor = Theme.COLORS["Positive text"]
		elseif pokemon.friendship >= Program.friendshipRequired and evoDetails == PokemonData.Evolutions.FRIEND then
			evoDetails = "SOON"
			evoTextColor = Theme.COLORS["Positive text"]
		elseif evoDetails ~= Constants.BLANKLINE then
			evoTextColor = Theme.COLORS["Intermediate text"]
		end
	end
	levelEvoText = levelEvoText .. evoDetails .. ")"

	-- POKEMON NAME
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, pokemon.name, Theme.COLORS["Default text"], shadowcolor)
	offsetY = offsetY + linespacing

	-- POKEMON HP, LEVEL, & EVOLUTION INFO
	if Tracker.Data.isViewingOwn then
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, "HP:", Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX + 16, offsetY, extraInfoText, extraInfoColor, shadowcolor)
		offsetY = offsetY + linespacing

		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, levelEvoText, Theme.COLORS["Default text"], shadowcolor)
		if evoDetails ~= Constants.BLANKLINE then
			-- Draw over the evo method in the new color to reflect if evo is possible/soon
			Drawing.drawText(Constants.SCREEN.WIDTH + evoSpacing, offsetY, evoDetails, evoTextColor, shadowcolor)
		end
		offsetY = offsetY + linespacing
	else
		-- Swaps the display order, Level/Evo first, then Last Level Seen.
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, levelEvoText, Theme.COLORS["Default text"], shadowcolor)
		offsetY = offsetY + linespacing
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, extraInfoText, extraInfoColor, shadowcolor)
		offsetY = offsetY + linespacing
	end

	-- Tracker.Data.isViewingOwn and
	if pokemon.status ~= MiscData.StatusType.None then
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
		local abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
		if abilityId ~= nil and abilityId ~= 0 then
			abilityStringBot = AbilityData.Abilities[abilityId].name
		end
	else
		if trackedAbilities[1].id ~= nil and trackedAbilities[1].id ~= 0 then
			abilityStringTop = AbilityData.Abilities[trackedAbilities[1].id].name .. " /"
			abilityStringBot = Constants.HIDDEN_INFO
		end
		if trackedAbilities[2].id ~= nil and trackedAbilities[2].id ~= 0 then
			abilityStringBot = AbilityData.Abilities[trackedAbilities[2].id].name
		end
	end

	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, abilityStringTop, Theme.COLORS["Intermediate text"], shadowcolor)
	offsetY = offsetY + linespacing
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, abilityStringBot, Theme.COLORS["Intermediate text"], shadowcolor)
	offsetY = offsetY + linespacing

	-- HEALS INFO / ENCOUNTER INFO
	local infoBoxHeight = 23
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 52, 96, infoBoxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	if Tracker.Data.isViewingOwn and pokemon.pokemonID ~= 0 then
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
	elseif Battle.inBattle then
		-- For now, only show route info while in Battle; later find a way to alway show
		local routeName = Constants.BLANKLINE
		if RouteData.hasRoute(Battle.CurrentRoute.mapId) then
			routeName = RouteData.Info[Battle.CurrentRoute.mapId].name or Constants.BLANKLINE
		end
		local encounterText = Tracker.getEncounters(pokemon.pokemonID, Battle.isWildEncounter)
		if encounterText > 999 then encounterText = 999 end
		if Battle.isWildEncounter then
			encounterText = "Seen in the wild: " .. encounterText
		else
			encounterText = "Seen on trainers: " .. encounterText
		end

		Drawing.drawButton(TrackerScreen.Buttons.RouteDetails, shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11, Constants.SCREEN.MARGIN + 53, encounterText, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11, Constants.SCREEN.MARGIN + 63, routeName, Theme.COLORS["Default text"], shadowcolor)
	end
end

function TrackerScreen.drawStatsArea(pokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local statBoxWidth = 101
	local statOffsetX = Constants.SCREEN.WIDTH + statBoxWidth + 1
	local statOffsetY = 7

	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + statBoxWidth, 5, Constants.SCREEN.RIGHT_GAP - statBoxWidth - 5, 75, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Draw the six primary stats
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		local natureMultiplier = Utils.getNatureMultiplier(statKey, pokemon.nature)
		local textColor = Theme.COLORS["Default text"]
		local natureSymbol = ""

		if Tracker.Data.isViewingOwn and natureMultiplier == 1.1 then
			textColor = Theme.COLORS["Positive text"]
			natureSymbol = "+"
		elseif Tracker.Data.isViewingOwn and natureMultiplier == 0.9 then
			textColor = Theme.COLORS["Negative text"]
			natureSymbol = Constants.BLANKLINE
		end

		-- Draw stat label and nature symbol next to it
		Drawing.drawText(statOffsetX, statOffsetY, statKey:upper(), textColor, shadowcolor)
		gui.drawText(statOffsetX + 16, statOffsetY - 1, natureSymbol, textColor, nil, 5, Constants.Font.FAMILY)

		-- Draw stat battle increases/decreases, stages range from -6 to +6
		if Battle.inBattle then
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
	Drawing.drawNumber(statOffsetX + 25, statOffsetY, pokemon.bst, 3, Theme.COLORS["Default text"], shadowcolor)

	-- If controller is in use and highlighting any stats, draw that
	Drawing.drawInputOverlay()
end

function TrackerScreen.drawMovesArea(pokemon, opposingPokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	local movesLearnedHeader, nextMoveLevel, nextMoveSpacing = Utils.getMovesLearnedHeader(pokemon.pokemonID, pokemon.level)
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

	-- Redraw next move level in the header with a different color if close to learning new move
	if nextMoveLevel ~= nil and nextMoveSpacing ~= nil and Tracker.Data.isViewingOwn and pokemon.level + 1 >= nextMoveLevel then
		Drawing.drawText(Constants.SCREEN.WIDTH + nextMoveSpacing, moveOffsetY - moveTableHeaderHeightDiff, nextMoveLevel, TrackerScreen.nextMoveLevelHighlight, bgHeaderShadow)
	end

	-- Draw the Moves view box
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, moveOffsetY - 2, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 46, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	if Options["Show physical special icons"] then -- Check if move categories will be drawn
		moveNameOffset = moveNameOffset + 8
	end
	if not Theme.MOVE_TYPES_ENABLED then -- Check if move type will be drawn as a rectangle
		moveNameOffset = moveNameOffset + 5
	end

	local movesToDraw = {
		MoveData.BlankMove,
		MoveData.BlankMove,
		MoveData.BlankMove,
		MoveData.BlankMove,
	}
	local trackedMoves = Tracker.getMoves(pokemon.pokemonID)
	for moveIndex = 1, 4, 1 do
		if Tracker.Data.isViewingOwn then
			if pokemon.moves[moveIndex] ~= nil and pokemon.moves[moveIndex].id ~= 0 then
				movesToDraw[moveIndex] = MoveData.Moves[pokemon.moves[moveIndex].id]
			end
		elseif trackedMoves ~= nil then
			-- If the Pokemon doesn't belong to the player, pull move data from tracked data
			if trackedMoves[moveIndex] ~= nil and trackedMoves[moveIndex].id ~= 0 then
				movesToDraw[moveIndex] = MoveData.Moves[trackedMoves[moveIndex].id]
			end
		end
	end

	local stars = { "", "", "", "" }
	if not Tracker.Data.isViewingOwn then
		stars = Utils.calculateMoveStars(pokemon.pokemonID, pokemon.level)
	end

	-- Draw all four moves
	for moveIndex, moveData in ipairs(movesToDraw) do
		-- Base move data to draw, but much of it will be updated
		local moveName = moveData.name .. stars[moveIndex]
		local moveType = moveData.type
		local moveTypeColor = Utils.inlineIf(moveData.name == MoveData.BlankMove.name, Theme.COLORS["Lower box text"], Constants.MoveTypeColors[moveType])
		local moveCategory = moveData.category
		local movePPText = Utils.inlineIf(moveData.pp == "0", Constants.BLANKLINE, moveData.pp)
		local movePower = Utils.inlineIf(moveData.power == "0", Constants.BLANKLINE, moveData.power)
		local movePowerColor = Theme.COLORS["Lower box text"]
		local moveAccuracy = Utils.inlineIf(moveData.accuracy == "0", Constants.BLANKLINE, moveData.accuracy)

		-- HIDDEN POWER TYPE UPDATE
		if Tracker.Data.isViewingOwn and moveData.name == "Hidden Power" then
			moveType = Tracker.getHiddenPowerType()
			moveTypeColor = Utils.inlineIf(moveType == PokemonData.Types.UNKNOWN, Theme.COLORS["Lower box text"], Constants.MoveTypeColors[moveType])
			moveCategory = MoveData.TypeToCategory[moveType]
		end

		-- WEATHER BALL MOVE UPDATE
		if Options["Calculate variable damage"] and moveData.name == "Weather Ball" then
			moveType, movePower = Utils.calculateWeatherBall(moveType, movePower)
			moveCategory = MoveData.TypeToCategory[moveType]
			moveTypeColor = Constants.MoveTypeColors[moveType]
		end

		-- MOVE CATEGORY
		if Options["Show physical special icons"] and (Tracker.Data.isViewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType) then
			if moveCategory == MoveData.Categories.PHYSICAL then
				Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, Constants.SCREEN.WIDTH + moveCatOffset, moveOffsetY + 2, { Theme.COLORS["Lower box text"] }, shadowcolor)
			elseif moveCategory == MoveData.Categories.SPECIAL then
				Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, Constants.SCREEN.WIDTH + moveCatOffset, moveOffsetY + 2, { Theme.COLORS["Lower box text"] }, shadowcolor)
			end
		end

		-- MOVE TYPE COLORED RECTANGLE
		if not Theme.MOVE_TYPES_ENABLED and moveData.name ~= Constants.BLANKLINE then
			gui.drawRectangle(Constants.SCREEN.WIDTH + moveNameOffset - 3, moveOffsetY + 2, 2, 7, moveTypeColor, moveTypeColor)
			moveTypeColor = Theme.COLORS["Lower box text"]
		end

		-- MOVE PP
		if moveData.name ~= MoveData.BlankMove.name then
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
		if Battle.inBattle then
			local ownTypes = Program.getPokemonTypes(Tracker.Data.isViewingOwn, Battle.isViewingLeft)
			if Utils.isSTAB(moveData, moveType, ownTypes) then
				movePowerColor = Theme.COLORS["Positive text"]
			end
		end

		if Options["Calculate variable damage"] then
			if moveData.id == "67" and Battle.inBattle and opposingPokemon ~= nil then
				-- Calculate the power of Low Kick (weight-based moves) in battle
				local targetWeight = PokemonData.Pokemon[opposingPokemon.pokemonID].weight
				movePower = Utils.calculateWeightBasedDamage(movePower, targetWeight)
			elseif Tracker.Data.isViewingOwn then
				if moveData.id == "175" or moveData.id == "179" then
					-- Calculate the power of Flail & Reversal moves for player only
					movePower = Utils.calculateLowHPBasedDamage(movePower, pokemon.curHP, pokemon.stats.hp)
				elseif moveData.id == "284" or moveData.id == "323" then
					-- Calculate the power of Eruption & Water Spout moves for the player only
					movePower = Utils.calculateHighHPBasedDamage(movePower, pokemon.curHP, pokemon.stats.hp)
				elseif moveData.id == "216" or moveData.id == "218" then
					-- Calculate the power of Return & Frustration moves for the player only
					movePower = Utils.calculateFriendshipBasedDamage(movePower, pokemon.friendship)
				end
			end
		end

		-- If move info is randomized and the user doesn't want to know about it, hide it
		-- If fighting a ghost, hide effectiveness
		local showEffectiveness = true
		if Battle.isGhost then
			showEffectiveness = false
		elseif not Options["Reveal info if randomized"] then
			if Tracker.Data.isViewingOwn then
				-- Don't show effectiveness of the player's moves if the enemy types are unknown
				showEffectiveness = not PokemonData.IsRand.pokemonTypes
			else
				if MoveData.IsRand.moveType then
					moveType = PokemonData.Types.UNKNOWN
					moveTypeColor = Theme.COLORS["Lower box text"]
					movePowerColor = Theme.COLORS["Lower box text"]
					showEffectiveness = false
				end
				if MoveData.IsRand.movePP and movePPText ~= Constants.BLANKLINE then
					movePPText = Constants.HIDDEN_INFO
				end
				if MoveData.IsRand.movePower and movePower ~= Constants.BLANKLINE then
					movePower = Constants.HIDDEN_INFO
				end
				if MoveData.IsRand.moveAccuracy and moveAccuracy ~= Constants.BLANKLINE then
					moveAccuracy = Constants.HIDDEN_INFO
				end
			end
		end

		-- DRAW MOVE EFFECTIVENESS
		if Options["Show move effectiveness"] and Battle.inBattle and showEffectiveness then
			local enemyTypes = Program.getPokemonTypes(not Tracker.Data.isViewingOwn, true)
			local effectiveness = Utils.netEffectiveness(moveData, moveType, enemyTypes)
			if effectiveness == 0 then
				Drawing.drawText(Constants.SCREEN.WIDTH + movePowerOffset - 7, moveOffsetY, "X", Theme.COLORS["Negative text"], shadowcolor)
			else
				Drawing.drawMoveEffectiveness(Constants.SCREEN.WIDTH + movePowerOffset - 5, moveOffsetY, effectiveness)
			end
		end

		-- DRAW ALL THE MOVE INFORMATION
		Drawing.drawText(Constants.SCREEN.WIDTH + moveNameOffset, moveOffsetY, moveName, moveTypeColor, shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + movePPOffset, moveOffsetY, movePPText, 2, Theme.COLORS["Lower box text"], shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + movePowerOffset, moveOffsetY, movePower, 3, movePowerColor, shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + moveAccOffset, moveOffsetY, moveAccuracy, 3, Theme.COLORS["Lower box text"], shadowcolor)

		moveOffsetY = moveOffsetY + 10 -- linespacing
	end
end

function TrackerScreen.drawCarouselArea(pokemon)
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
				Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, wrappedText[1], Theme.COLORS["Lower box text"], shadowcolor)
			elseif #wrappedText >= 2 then
				Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 136, wrappedText[1], Theme.COLORS["Lower box text"], shadowcolor)
				Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 145, wrappedText[2], Theme.COLORS["Lower box text"], shadowcolor)
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

function TrackerScreen.drawBallPicker()
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	-- Draw top box view
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, 96, 52, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	local ballsToDraw = {
		TrackerScreen.PokeBalls.Left,
		TrackerScreen.PokeBalls.Middle,
		TrackerScreen.PokeBalls.Right,
	}
	for index, pokeball in ipairs(ballsToDraw) do
		local colorList = TrackerScreen.PokeBalls.ColorList
		if index == TrackerScreen.PokeBalls.chosenBall then
			Drawing.drawImageAsPixels(Constants.PixelImages.DOWN_ARROW, pokeball.x + 1, pokeball.y - 13, { Theme.COLORS["Default text"] }, shadowcolor)
		elseif TrackerScreen.PokeBalls.chosenBall ~= -1 then
			-- If not the chosen ball and not in the process of re-rolling
			colorList = TrackerScreen.PokeBalls.ColorListGray
		end
		Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, pokeball.x, pokeball.y, colorList, shadowcolor)
	end

	-- SETTINGS GEAR & DICE BUTTONS
	Drawing.drawButton(TrackerScreen.Buttons.SettingsGear, shadowcolor)
	Drawing.drawButton(TrackerScreen.Buttons.RerollBallPicker, shadowcolor)

	local infoBoxHeight = 23
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 52, 96, infoBoxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	local chosenBallText = TrackerScreen.PokeBalls.Labels[TrackerScreen.PokeBalls.chosenBall] or Constants.BLANKLINE
	Drawing.drawText(Constants.SCREEN.WIDTH + 8, 57, "Randomly chosen ball:", Theme.COLORS["Default text"], shadowcolor)
	Drawing.drawText(Constants.SCREEN.WIDTH + 4 + Utils.centerTextOffset(chosenBallText, 4, 96), 68, chosenBallText, Theme.COLORS["Intermediate text"], shadowcolor)
end
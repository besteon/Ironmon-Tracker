TrackerScreen = {}

TrackerScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconPath = function(self)
			local pokemonID = 0
			local pokemon = Tracker.getViewedPokemon()
			if pokemon ~= nil and pokemon.pokemonID > 0 and pokemon.pokemonID <= #PokemonData.Pokemon then
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
			if pokemon ~= nil then
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
			if not RouteData.hasRouteEncounterArea(Program.CurrentRoute.mapId, Program.CurrentRoute.encounterArea) then return end

			local routeInfo = { 
				mapId = Program.CurrentRoute.mapId,
				encounterArea = Program.CurrentRoute.encounterArea,
			}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	},
	AbilityTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + 37, 35, 63, 22 },
		box = { Constants.SCREEN.WIDTH + 88, 43, 11, 11 },
		isVisible = function() return not Tracker.Data.isViewingOwn end,
		onClick = function(self)
			if not self:isVisible() then return end
			TrackerScreen.openAbilityNoteWindow()
		end
	},
	NotepadTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		text = "(Leave a note)",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 11, 11 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES end,
		onClick = function(self)
			if not self:isVisible() then return end
			TrackerScreen.openNotePadWindow()
		end
	},
	LastAttackSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SWORD_ATTACK,
		text = "",
		textColor = "Default text",
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
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 8, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			local routeInfo = { 
				mapId = Program.CurrentRoute.mapId,
				encounterArea = Program.CurrentRoute.encounterArea,
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
			isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
			onClick = function(self)
				if not self:isVisible() then return end

				self.statState = ((self.statState + 1) % 3)
				self.text = Constants.STAT_STATES[self.statState].text
				self.textColor = Constants.STAT_STATES[self.statState].textColor

				local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
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

	TrackerScreen.buildCarousel()
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
		isVisible = function() return not Tracker.Data.isViewingOwn or (Options["Show tips on startup"] and Tracker.getPokemon(1, true) == nil) end,
		framesToShow = 180,
		getContentList = function(pokemon)
			-- If the player doesn't have a Pokemon, display something else useful instead
			if pokemon.pokemonID == 0 then
				return { Constants.OrderedLists.TIPS[TrackerScreen.tipMessageIndex] }
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
		isVisible = function() return Options["Show last damage calcs"] and Tracker.Data.inBattle and not Program.BattleTurn.enemyIsAttacking and Program.BattleTurn.lastMoveId ~= 0 end,
		framesToShow = 180,
		getContentList = function()
			local lastAttackMsg
			-- Currently this only records last move used for damaging moves
			if Program.BattleTurn.lastMoveId > 0 and Program.BattleTurn.lastMoveId <= #MoveData.Moves then
				local moveInfo = MoveData.Moves[Program.BattleTurn.lastMoveId]
				if Program.BattleTurn.damageReceived > 0 then
					lastAttackMsg = moveInfo.name .. ": " .. Program.BattleTurn.damageReceived .. " damage"
					local ownPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
					if Program.BattleTurn.damageReceived > ownPokemon.curHP then
						-- Warn user that the damage taken is potentially lethal
						TrackerScreen.Buttons.LastAttackSummary.textColor = "Negative text"
					else
						TrackerScreen.Buttons.LastAttackSummary.textColor = "Default text"
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
		isVisible = function() return Tracker.Data.inBattle and Program.CurrentRoute.hasInfo end,
		framesToShow = 180,
		getContentList = function(pokemon)
			local routeInfo = RouteData.Info[Program.CurrentRoute.mapId]
			local totalPossible = RouteData.countPokemonInArea(Program.CurrentRoute.mapId, Program.CurrentRoute.encounterArea)
			local routeEncounters = Tracker.getRouteEncounters(Program.CurrentRoute.mapId, Program.CurrentRoute.encounterArea)
			local totalSeen = #routeEncounters

			TrackerScreen.Buttons.RouteSummary.text = Program.CurrentRoute.encounterArea .. ": Seen " .. totalSeen .. "/" .. totalPossible .. " " .. Constants.Words.POKEMON

			return { TrackerScreen.Buttons.RouteSummary } 
		end,
	}

	-- Easter Egg for the "-69th" seed
	if Options["Show tips on startup"] then
		local romnumber = string.match(gameinfo.getromname(), '[0-9]+')
		if romnumber ~= nil and romnumber ~= "" and romnumber:sub(-2) == "69" then
			table.insert(Constants.OrderedLists.TIPS, "This seed ends in 69. Nice.")
		end
	end
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
		if nextCarousel ~= carousel and TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES and Options["Show tips on startup"] then
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
	local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
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

function TrackerScreen.openAbilityNoteWindow()
	local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
	if pokemon == nil then return end

	local abilityList = {}
	table.insert(abilityList, Constants.BLANKLINE)
	for _, abilityName in pairs(MiscData.Abilities) do
		table.insert(abilityList, abilityName)
	end

	local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)

	local abilityForm = forms.newform(360, 170, "Track Ability", function() client.unpause() end)
	Utils.setFormLocation(abilityForm, 100, 50)

	forms.label(abilityForm, "Select one or both abilities for " .. PokemonData.Pokemon[pokemon.pokemonID].name .. ":", 64, 10, 220, 20)
	local abilityOneDropdown = forms.dropdown(abilityForm, {["Init"]="Loading Ability1"}, 95, 30, 145, 30)
	forms.setdropdownitems(abilityOneDropdown, abilityList, true) -- true = alphabetize list
	forms.setproperty(abilityOneDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(abilityOneDropdown, "AutoCompleteMode", "Append")
	local abilityTwoDropdown = forms.dropdown(abilityForm, {["Init"]="Loading Ability2"}, 95, 60, 145, 30)
	forms.setdropdownitems(abilityTwoDropdown, abilityList, true) -- true = alphabetize list
	forms.setproperty(abilityTwoDropdown, "AutoCompleteSource", "ListItems")
	forms.setproperty(abilityTwoDropdown, "AutoCompleteMode", "Append")

	if trackedAbilities[1].id ~= 0 then
		forms.settext(abilityOneDropdown, MiscData.Abilities[trackedAbilities[1].id])
	end
	if trackedAbilities[2].id ~= 0 then
		forms.settext(abilityTwoDropdown, MiscData.Abilities[trackedAbilities[2].id])
	end

	forms.button(abilityForm, "Save && Close", function()
		local pokemonViewed = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
		if pokemonViewed ~= nil then
			local abilityOneText = forms.gettext(abilityOneDropdown)
			local abilityTwoText = forms.gettext(abilityTwoDropdown)

			Tracker.setAbilities(pokemonViewed.pokemonID, abilityOneText, abilityTwoText)
		end

		client.unpause()
		Program.redraw(true)
		forms.destroy(abilityForm)
	end, 65, 95, 85, 25)
	forms.button(abilityForm, "Clear", function()
		forms.settext(abilityOneDropdown, Constants.BLANKLINE)
		forms.settext(abilityTwoDropdown, Constants.BLANKLINE)
	end, 160, 95, 55, 25)
	forms.button(abilityForm, "Cancel", function()
		client.unpause()
		forms.destroy(abilityForm)
	end, 225, 95, 55, 25)
end

function TrackerScreen.openNotePadWindow()
	local pokemon = Tracker.getViewedPokemon()
	if pokemon == nil then return end

	Program.destroyActiveForm()
	local noteForm = forms.newform(465, 125, "Leave a Note", function() client.unpause() end)
	Program.activeFormId = noteForm
	Utils.setFormLocation(noteForm, 100, 50)

	forms.label(noteForm, "Enter a note for " .. PokemonData.Pokemon[pokemon.pokemonID].name .. " (70 char. max):", 9, 10, 300, 20)
	local noteTextBox = forms.textbox(noteForm, Tracker.getNote(pokemon.pokemonID), 430, 20, nil, 10, 30)

	forms.button(noteForm, "Save", function()
		local formInput = forms.gettext(noteTextBox)
		local pokemonViewed = Tracker.getViewedPokemon()
		if formInput ~= nil and pokemonViewed ~= nil then
			Tracker.TrackNote(pokemonViewed.pokemonID, formInput)
			Program.redraw(true)
		end
		forms.destroy(noteForm)
		client.unpause()
	end, 187, 55)
end

-- DRAWING FUNCTIONS
function TrackerScreen.drawScreen()
	TrackerScreen.updateButtonStates()

	local viewedPokemon = Tracker.getPokemon(Tracker.Data.ownViewSlot, true)
	local opposingPokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)

	-- Depending on which pokemon is being viewed, draw it using the other pokemon's info for calculations (effectiveness/weight)
	if not Tracker.Data.isViewingOwn then
		local tempPokemon = viewedPokemon
		viewedPokemon = opposingPokemon
		opposingPokemon = tempPokemon
	end

	if viewedPokemon == nil or viewedPokemon.pokemonID == 0 then
		viewedPokemon = Tracker.getDefaultPokemon()
	elseif not Tracker.Data.hasCheckedSummary then
		-- Don't display any spoilers about the stats/moves, but still show the pokemon icon, name, and level
		local defaultPokemon = Tracker.getDefaultPokemon()
		defaultPokemon.pokemonID = viewedPokemon.pokemonID
		defaultPokemon.level = viewedPokemon.level
		viewedPokemon = defaultPokemon
	end

	-- Add in Pokedex information about the Pokemon
	local pokedexInfo = Utils.inlineIf(viewedPokemon.pokemonID ~= 0, PokemonData.Pokemon[viewedPokemon.pokemonID], PokemonData.BlankPokemon)
	for key, value in pairs(pokedexInfo) do
		viewedPokemon[key] = value
	end

	Drawing.drawBackgroundAndMargins()

	TrackerScreen.drawPokemonInfoArea(viewedPokemon)
	TrackerScreen.drawStatsArea(viewedPokemon)
	TrackerScreen.drawMovesArea(viewedPokemon, opposingPokemon)
	TrackerScreen.drawCarouselArea(viewedPokemon)
end

function TrackerScreen.drawPokemonInfoArea(pokemon)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	-- Draw top box view
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, 96, 52, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON ICON & TYPES
	Drawing.drawButton(TrackerScreen.Buttons.PokemonIcon, shadowcolor)
	if not Options["Reveal info if randomized"] and not Tracker.Data.isViewingOwn and PokemonData.IsRand.pokemonTypes then
		-- Don't reveal randomized Pokemon types for enemies
		Drawing.drawTypeIcon(PokemonData.Types.UNKNOWN, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
	else
		Drawing.drawTypeIcon(pokemon.types[1], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
		if pokemon.types[2] ~= pokemon.types[1] then
			Drawing.drawTypeIcon(pokemon.types[2], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 45)
		end
	end

	-- SETTINGS GEAR
	Drawing.drawButton(TrackerScreen.Buttons.SettingsGear, shadowcolor)

	-- POKEMON INFORMATION
	local pkmnStatOffsetX = 36
	local pkmnStatStartY = 5
	local pkmnStatOffsetY = 10

	-- Don't show hp values if the pokemon doesn't belong to the player, or if it doesn't exist
	local currentHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, Constants.HIDDEN_INFO, pokemon.curHP)
	local maxHP = Utils.inlineIf(not Tracker.Data.isViewingOwn or pokemon.stats.hp == 0, Constants.HIDDEN_INFO, pokemon.stats.hp)
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
			abilityStringBot = MiscData.Abilities[abilityId]
		end
	else
		if trackedAbilities[1].id ~= nil and trackedAbilities[1].id ~= 0 then
			abilityStringTop = MiscData.Abilities[trackedAbilities[1].id] .. " /"
			abilityStringBot = Constants.HIDDEN_INFO
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
	Drawing.drawNumber(statOffsetX + 25, statOffsetY, pokemon.bst, 3, Theme.COLORS["Default text"], shadowcolor)

	-- If controller is in use and highlighting any stats, draw that
	Drawing.drawInputOverlay()
end

function TrackerScreen.drawMovesArea(pokemon, opposingPokemon)
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
		local movePPText = Utils.inlineIf(moveData.pp == "0", Constants.BLANKLINE, moveData.pp)
		local movePower = Utils.inlineIf(moveData.power == "0", Constants.BLANKLINE, moveData.power)
		local movePowerColor = Theme.COLORS["Default text"]
		local moveAccuracy = Utils.inlineIf(moveData.accuracy == "0", Constants.BLANKLINE, moveData.accuracy)

		-- HIDDEN POWER TYPE UPDATE
		if Tracker.Data.isViewingOwn and moveData.name == "Hidden Power" then
			moveType = Tracker.getHiddenPowerType()
			moveTypeColor = Utils.inlineIf(moveType == PokemonData.Types.UNKNOWN, Theme.COLORS["Default text"], Constants.MoveTypeColors[moveType])
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
		if moveData.pp ~= Constants.BLANKLINE then
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
		if Tracker.Data.inBattle and Utils.isSTAB(moveData, moveType, pokemon.types) then
			movePowerColor = Theme.COLORS["Positive text"]
		end

		if Options["Calculate variable damage"] then
			if moveData.id == "67" and Tracker.Data.inBattle and opposingPokemon ~= nil then
				-- Calculate the power of Low Kick (weight-based moves) in battle
				local targetWeight = PokemonData.Pokemon[opposingPokemon.pokemonID].weight
				movePower = Utils.calculateWeightBasedDamage(movePower, targetWeight)
			elseif Tracker.Data.isViewingOwn and (moveData.id == "175" or moveData.id == "179") then
				-- Calculate the power of Flail & Reversal moves for player only
				movePower = Utils.calculateLowHPBasedDamage(movePower, pokemon.curHP, pokemon.stats.hp)
			elseif Tracker.Data.isViewingOwn and (moveData.id == "284" or moveData.id == "323") then
				-- Calculate the power of Eruption & Water Spout moves for the player only
				movePower = Utils.calculateHighHPBasedDamage(movePower, pokemon.curHP, pokemon.stats.hp)
			end
		end

		-- If move info is randomized and the user doesn't want to know about it, hide it
		local showEffectiveness = true
		if not Options["Reveal info if randomized"] then
			if Tracker.Data.isViewingOwn then
				-- Don't show effectiveness of the player's moves if the enemy types are unknown
				showEffectiveness = not PokemonData.IsRand.pokemonTypes
			else
				if MoveData.IsRand.moveType then
					moveType = PokemonData.Types.UNKNOWN
					moveTypeColor = Theme.COLORS["Default text"]
					movePowerColor = Theme.COLORS["Default text"]
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
		if Options["Show move effectiveness"] and Tracker.Data.inBattle and opposingPokemon ~= nil and showEffectiveness then
			local typesData = Memory.readword(GameSettings.gBattleMons + ((Tracker.Data.isViewingOwn and 0x58) or 0x0) + 0x21)
			local types = {
				PokemonData.TypeIndexMap[Utils.getbits(typesData, 0, 8)],
				PokemonData.TypeIndexMap[Utils.getbits(typesData, 8, 8)],
			}
			local effectiveness = Utils.netEffectiveness(moveData, moveType, types)
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
		Drawing.drawNumber(Constants.SCREEN.WIDTH + moveAccOffset, moveOffsetY, moveAccuracy, 3, Theme.COLORS["Default text"], shadowcolor)

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
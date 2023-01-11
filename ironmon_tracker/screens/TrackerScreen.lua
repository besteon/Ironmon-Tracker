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
			return FileManager.buildImagePath(iconset.folder, tostring(pokemonID), iconset.extension)
		end,
		clickableArea = { Constants.SCREEN.WIDTH + 5, 5, 32, 27 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, -1, 32, 32 },
		isVisible = function() return true end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon()
			local pokemonID = 0
			if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
				pokemonID = pokemon.pokemonID
			end
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemonID)
		end
	},
	TypeDefenses = {
		-- Invisible button area for the type defenses boxes
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 27, 30, 24, },
		isVisible = function()
			local pokemon = Tracker.getViewedPokemon() or Tracker.getDefaultPokemon()
			return PokemonData.isValid(pokemon.pokemonID)
		end,
		onClick = function (self)
			local pokemon = Tracker.getViewedPokemon() or Tracker.getDefaultPokemon()
			TypeDefensesScreen.buildOutPagedButtons(pokemon.pokemonID)
			Program.changeScreenView(Program.Screens.TYPE_DEFENSES)
		end,
	},
	SettingsGear = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 7, 7, 7 },
		isVisible = function() return true end,
		onClick = function(self)
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
	MovesHistory = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		text = "",
		textColor = "Intermediate text", -- set later after highlight color is calculated
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 81, 77, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 69, 81, 10, 10 },
		boxColors = { "Header text", "Main background" },
		isVisible = function()
			local viewedPokemon = Tracker.getViewedPokemon()
			return viewedPokemon ~= nil and PokemonData.isValid(viewedPokemon.pokemonID)
		end,
		onClick = function(self)
			local viewedPokemon = Tracker.getViewedPokemon()
			if viewedPokemon ~= nil and MoveHistoryScreen.buildOutHistory(viewedPokemon.pokemonID, viewedPokemon.level) then
				Program.changeScreenView(Program.Screens.MOVE_HISTORY)
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
			local routeInfo = {
				mapId = Battle.CurrentRoute.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	},
	PedometerStepText = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOCK,
		text = "Steps: ##,###", -- Placeholder template, see updateText() below
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 141, 10, 10 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateText = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			if stepCount > 999999 then -- 1,000,000 is the arbitrary cutoff
				stepCount = 999999
			end
			if Program.Pedometer.goalSteps ~= 0 and stepCount >= Program.Pedometer.goalSteps then
				self.textColor = "Positive text"
			else
				self.textColor = "Default text"
			end
			local formattedStepCount = Utils.formatNumberWithCommas(stepCount)
			self.text = string.format("Steps: %s", formattedStepCount)
		end,
	},
	PedometerGoal = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Goal",
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, 140, 23, 11 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, 140, 23, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateText = function(self)
			if Program.Pedometer.goalSteps == 0 then
				self.textColor = "Lower box text"
			else
				self.textColor = "Intermediate text"
			end
		end,
		onClick = function(self) TrackerScreen.openEditStepGoalWindow() end
	},
	PedometerReset = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Reset",
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, 140, 28, 11 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, 140, 28, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateText = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			self.text = Utils.inlineIf(stepCount <= 0, " Total", "Reset")
		end,
		onClick = function(self)
			if self.text == "Reset" then
				Program.Pedometer.lastResetCount = Program.Pedometer.totalSteps
			elseif self.text == " Total" then
				Program.Pedometer.lastResetCount = 0
			end
			Program.redraw(true)
		end
	},
}

TrackerScreen.CarouselTypes = {
    BADGES = 1, -- Outside of battle
	LAST_ATTACK = 2, -- During battle, only between turns
	ROUTE_INFO = 3, -- During battle, only if encounter is a wild pokemon
	NOTES = 4, -- During new game intro or inside of battle
    PEDOMETER = 5, -- Outside of battle
}

TrackerScreen.carouselIndex = 1
TrackerScreen.tipMessageIndex = 0
TrackerScreen.CarouselItems = {}

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

				self.statState = ((self.statState + 1) % 4) -- 4 total possible markings for a stat state
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
			image = FileManager.buildImagePath(FileManager.Folders.Badges, GameSettings.badgePrefix .. "_" .. badgeName .. "_OFF", FileManager.Extensions.BADGE),
			box = { xOffset, 138, badgeWidth, badgeWidth },
			badgeIndex = index,
			badgeState = 0,
			isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.BADGES end,
			updateState = function(self, state)
				-- Update image path if the state has changed
				if self.badgeState ~= state then
					self.badgeState = state
					local badgeOffText = Utils.inlineIf(self.badgeState == 0, "_OFF", "")
					local name = GameSettings.badgePrefix .. "_badge" .. self.badgeIndex .. badgeOffText
					self.image = FileManager.buildImagePath(FileManager.Folders.Badges, name, FileManager.Extensions.BADGE)
				end
			end
		}
	end

	-- Set the color for next move level highlighting for the current theme now, instead of constantly re-calculating it
	Theme.setNextMoveLevelHighlight(true)
	TrackerScreen.buildCarousel()

	TrackerScreen.randomlyChooseBall()
end

-- Define each Carousel Item, must will have blank data that will be populated later with contextual data
function TrackerScreen.buildCarousel()
	--  BADGE
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.BADGES] = {
		type = TrackerScreen.CarouselTypes.BADGES,
		isVisible = function() return Tracker.Data.isViewingOwn and not (Options["Disable mainscreen carousel"] and Program.Pedometer:isInUse()) end,
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
		getContentList = function(pokemonID)
			local noteText = Tracker.getNote(pokemonID)
			if Main.IsOnBizhawk() then
				if noteText ~= nil and noteText ~= "" then
					return { noteText }
				else
					return { TrackerScreen.Buttons.NotepadTracking }
				end
			else
				return noteText or ""
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
					lastAttackMsg = string.format("%s: %d damage", moveInfo.name, math.floor(Battle.damageReceived))
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
			if Main.IsOnBizhawk() then
				return { TrackerScreen.Buttons.LastAttackSummary }
			else
				return lastAttackMsg or ""
			end
		end,
	}

	-- ROUTE INFO
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.ROUTE_INFO] = {
		type = TrackerScreen.CarouselTypes.ROUTE_INFO,
		isVisible = function() return (not Tracker.Data.isViewingOwn or not Options["Disable mainscreen carousel"]) and Battle.inBattle and Battle.CurrentRoute.hasInfo end,
		framesToShow = 180,
		getContentList = function()
			-- local routeInfo = RouteData.Info[Battle.CurrentRoute.mapId]
			local totalPossible = RouteData.countPokemonInArea(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea)
			local routeEncounters = Tracker.getRouteEncounters(Battle.CurrentRoute.mapId, Battle.CurrentRoute.encounterArea)
			local totalSeen = #routeEncounters

			if Battle.CurrentRoute.encounterArea == RouteData.EncounterArea.ROCKSMASH then
				TrackerScreen.Buttons.RouteSummary.text = "Rock Smash: " .. totalSeen .. "/" .. totalPossible .. " " .. Constants.Words.POKEMON
			else
				TrackerScreen.Buttons.RouteSummary.text = Battle.CurrentRoute.encounterArea .. ": Seen " .. totalSeen .. "/" .. totalPossible .. " " .. Constants.Words.POKEMON
			end

			if Main.IsOnBizhawk() then
				return { TrackerScreen.Buttons.RouteSummary }
			else
				return TrackerScreen.Buttons.RouteSummary.text or ""
			end
		end,
	}

	--  PEDOMETER
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.PEDOMETER] = {
		type = TrackerScreen.CarouselTypes.PEDOMETER,
		isVisible = function() return Tracker.Data.isViewingOwn and Program.Pedometer:isInUse() end,
		framesToShow = 210,
		getContentList = function()
			TrackerScreen.Buttons.PedometerStepText:updateText()
			TrackerScreen.Buttons.PedometerGoal:updateText()
			TrackerScreen.Buttons.PedometerReset:updateText()
			if Main.IsOnBizhawk() then
				return {
					TrackerScreen.Buttons.PedometerStepText,
					TrackerScreen.Buttons.PedometerGoal,
					TrackerScreen.Buttons.PedometerReset,
				}
			else
				return TrackerScreen.Buttons.PedometerStepText.text or ""
			end
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
	if not PokemonData.isValid(pokemonId) then return end

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

function TrackerScreen.openEditStepGoalWindow()
	Program.destroyActiveForm()
	local form = forms.newform(320, 170, "Choose a Step Goal", function() client.unpause() end)
	Program.activeFormId = form
	Utils.setFormLocation(form, 100, 50)

	forms.label(form, "Pedometer will change color when goal is reached.", 26, 10, 300, 20)
	forms.label(form, "(Set to 0 to turn-off)", 100, 28, 300, 20)
	forms.label(form, "Enter a step goal:", 48, 50, 300, 20)
	local textBox = forms.textbox(form, (Program.Pedometer.goalSteps or 0), 200, 30, "UNSIGNED", 50, 70)
	forms.button(form, "Save", function()
		local formInput = forms.gettext(textBox)
		if formInput ~= nil and formInput ~= "" then
			local newStepGoal = tonumber(formInput)
			if newStepGoal ~= nil then
				Program.Pedometer.goalSteps = newStepGoal
				Program.redraw(true)
			end
		end
		client.unpause()
		forms.destroy(form)
	end, 72, 100)
	forms.button(form, "Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 157, 100)
end

function TrackerScreen.randomlyChooseBall()
	TrackerScreen.PokeBalls.chosenBall = math.random(3)
	return TrackerScreen.PokeBalls.chosenBall
end

function TrackerScreen.canShowBallPicker()
	-- If the player is in the lab without any Pokemon
	return Options["Show random ball picker"] and RouteData.Locations.IsInLab[Battle.CurrentRoute.mapId] and Tracker.getPokemon(1, true) == nil
end

-- DRAWING FUNCTIONS
function TrackerScreen.drawScreen()
	TrackerScreen.updateButtonStates()

	Drawing.drawBackgroundAndMargins()

	local displayData = DataHelper.buildTrackerScreenDisplay()

	if TrackerScreen.canShowBallPicker() then
		TrackerScreen.drawBallPicker()
	else
		TrackerScreen.drawPokemonInfoArea(displayData)
	end
	TrackerScreen.drawStatsArea(displayData)
	TrackerScreen.drawMovesArea(displayData)
	TrackerScreen.drawCarouselArea(displayData)
end

function TrackerScreen.drawPokemonInfoArea(data)
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
		Drawing.drawTypeIcon(data.p.types[1], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
		if data.p.types[2] ~= data.p.types[1] then
			Drawing.drawTypeIcon(data.p.types[2], Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 45)
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
		if data.p.hp <= 0 then
			extraInfoText = string.format("%s/%s", Constants.HIDDEN_INFO, Constants.HIDDEN_INFO)
			extraInfoColor = Theme.COLORS["Default text"]
		else
			extraInfoText = string.format("%s/%s", data.p.curHP, data.p.hp)

			local hpPercentage = data.p.curHP / data.p.hp
			if hpPercentage <= 0.2 then
				extraInfoColor = Theme.COLORS["Negative text"]
			elseif hpPercentage <= 0.5 then
				extraInfoColor = Theme.COLORS["Intermediate text"]
			else
				extraInfoColor = Theme.COLORS["Default text"]
			end
		end
	else
		if data.p.lastlevel ~= nil and data.p.lastlevel ~= "" then
			extraInfoText = string.format("Last seen Lv.%s", data.p.lastlevel)
		else
			extraInfoText = "New encounter!"
		end
		extraInfoColor = Theme.COLORS["Intermediate text"]
	end

	local levelEvoText = "Lv." .. data.p.level .. " ("
	local evoSpacing = offsetX + string.len(levelEvoText) * 3 + string.len(data.p.level) * 2
	levelEvoText = levelEvoText .. data.p.evo .. ")"

	-- POKEMON NAME
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, data.p.name, Theme.COLORS["Default text"], shadowcolor)
	offsetY = offsetY + linespacing

	-- POKEMON HP, LEVEL, & EVOLUTION INFO
	if Tracker.Data.isViewingOwn then
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, "HP:", Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX + 16, offsetY, extraInfoText, extraInfoColor, shadowcolor)
		offsetY = offsetY + linespacing

		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, levelEvoText, Theme.COLORS["Default text"], shadowcolor)
		if data.p.evo ~= Constants.BLANKLINE then
			-- Draw over the evo method in the new color to reflect if evo is possible/soon
			local evoTextColor = Theme.COLORS["Default text"]
			if Tracker.Data.isViewingOwn then
				if data.p.evo == "SOON" or Utils.isReadyToEvolveByLevel(data.p.evo, data.p.level) or Utils.isReadyToEvolveByStone(data.p.evo) then
					evoTextColor = Theme.COLORS["Positive text"]
				elseif data.p.evo ~= Constants.BLANKLINE then
					evoTextColor = Theme.COLORS["Intermediate text"]
				end
			end
			Drawing.drawText(Constants.SCREEN.WIDTH + evoSpacing, offsetY, data.p.evo, evoTextColor, shadowcolor)
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
	if data.p.status ~= MiscData.StatusCodeMap[MiscData.StatusType.None] then
		Drawing.drawStatusIcon(data.p.status, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 30 - 16 + 1, Constants.SCREEN.MARGIN + 1)
	end

	-- HELD ITEM AND ABILITIES
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, data.p.line1, Theme.COLORS["Intermediate text"], shadowcolor)
	offsetY = offsetY + linespacing
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, data.p.line2, Theme.COLORS["Intermediate text"], shadowcolor)
	offsetY = offsetY + linespacing

	-- HEALS INFO / ENCOUNTER INFO
	local infoBoxHeight = 23
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 52, 96, infoBoxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	if Tracker.Data.isViewingOwn and data.p.id ~= 0 then
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 57, "Heals in Bag:", Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 67, string.format("%.0f%%", data.x.healperc) .. " HP (" .. data.x.healnum .. ")", Theme.COLORS["Default text"], shadowcolor)

		if Options["Track PC Heals"] then
			Drawing.drawText(Constants.SCREEN.WIDTH + 60, 57, "PC Heals:", Theme.COLORS["Default text"], shadowcolor)
			-- Right-align the PC Heals number
			local healNumberSpacing = (2 - string.len(tostring(data.x.pcheals))) * 5 + 75
			Drawing.drawText(Constants.SCREEN.WIDTH + healNumberSpacing, 67, data.x.pcheals, Utils.getCenterHealColor(), shadowcolor)

			-- Draw the '+'', '-'', and toggle button for auto PC tracking
			local incBtn = TrackerScreen.Buttons.PCHealIncrement
			local decBtn = TrackerScreen.Buttons.PCHealDecrement
			if Theme.DRAW_TEXT_SHADOWS then
				Drawing.drawText(incBtn.box[1] + 1, incBtn.box[2] + 1, incBtn.text, shadowcolor, nil, 5, Constants.Font.FAMILY)
				Drawing.drawText(decBtn.box[1] + 1, decBtn.box[2] + 1, decBtn.text, shadowcolor, nil, 5, Constants.Font.FAMILY)
			end
			Drawing.drawText(incBtn.box[1], incBtn.box[2], incBtn.text, Theme.COLORS[incBtn.textColor], nil, 5, Constants.Font.FAMILY)
			Drawing.drawText(decBtn.box[1], decBtn.box[2], decBtn.text, Theme.COLORS[decBtn.textColor], nil, 5, Constants.Font.FAMILY)

			-- Auto-tracking PC Heals button
			Drawing.drawButton(TrackerScreen.Buttons.PCHealAutoTracking, shadowcolor)
		end
	elseif Battle.inBattle then
		local encounterText
		if Battle.isWildEncounter then
			encounterText = "Seen in the wild: " .. data.x.encounters
		else
			encounterText = "Seen on trainers: " .. data.x.encounters
		end

		Drawing.drawButton(TrackerScreen.Buttons.RouteDetails, shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11, Constants.SCREEN.MARGIN + 53, encounterText, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11, Constants.SCREEN.MARGIN + 63, data.x.route, Theme.COLORS["Default text"], shadowcolor)
	end
end

function TrackerScreen.drawStatsArea(data)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
	local statBoxWidth = 101
	local statOffsetX = Constants.SCREEN.WIDTH + statBoxWidth + 1
	local statOffsetY = 7

	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + statBoxWidth, 5, Constants.SCREEN.RIGHT_GAP - statBoxWidth - 5, 75, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- Draw the six primary stats
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		local textColor = Theme.COLORS["Default text"]
		local natureSymbol = ""

		if Tracker.Data.isViewingOwn then
			if statKey == data.p.positivestat then
				textColor = Theme.COLORS["Positive text"]
				natureSymbol = "+"
			elseif statKey == data.p.negativestat then
				textColor = Theme.COLORS["Negative text"]
				natureSymbol = Constants.BLANKLINE
			end
		end

		-- Draw stat label and nature symbol next to it
		Drawing.drawText(statOffsetX, statOffsetY, statKey:upper(), textColor, shadowcolor)
		Drawing.drawText(statOffsetX + 16, statOffsetY - 1, natureSymbol, textColor, nil, 5, Constants.Font.FAMILY)

		-- Draw stat battle increases/decreases, stages range from -6 to +6
		if Battle.inBattle then
			local statStageIntensity = data.p.stages[statKey] - 6 -- between [0 and 12], convert to [-6 and 6]
			Drawing.drawChevrons(statOffsetX + 20, statOffsetY + 4, statStageIntensity, 3)
		end

		-- Draw stat value, or the stat tracking box if enemy Pokemon
		if Tracker.Data.isViewingOwn then
			local statValueText = Utils.inlineIf(data.p[statKey] == 0, Constants.BLANKLINE, data.p[statKey])
			Drawing.drawNumber(statOffsetX + 25, statOffsetY, statValueText, 3, textColor, shadowcolor)
		else
			Drawing.drawButton(TrackerScreen.Buttons[statKey], shadowcolor)
		end
		statOffsetY = statOffsetY + 10
	end

	-- Draw BST or ACC/EVA
	-- The "ACC" and "EVA" stats occupy the same space as the "BST". Prioritize showing ACC/EVA if either has changed during battle (6 is neutral)
	local useAccEvaInstead = Battle.inBattle and (data.p.stages.acc ~= 6 or data.p.stages.eva ~= 6)
	if useAccEvaInstead then
		Drawing.drawText(statOffsetX - 1, statOffsetY + 1, "Acc", Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(statOffsetX + 27, statOffsetY + 1, "Eva", Theme.COLORS["Default text"], shadowcolor)
		local accIntensity = data.p.stages.acc - 6
		local evaIntensity = data.p.stages.eva - 6
		Drawing.drawChevrons(statOffsetX + 15, statOffsetY + 5, accIntensity, 3)
		Drawing.drawChevrons(statOffsetX + 22, statOffsetY + 5, evaIntensity, 3)
	else
		Drawing.drawText(statOffsetX, statOffsetY, "BST", Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawNumber(statOffsetX + 25, statOffsetY, data.p.bst, 3, Theme.COLORS["Default text"], shadowcolor)
	end

	-- If controller is in use and highlighting any stats, draw that
	Drawing.drawInputOverlay()
end

function TrackerScreen.drawMovesArea(data)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])
	local bgHeaderShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])

	local moveTableHeaderHeightDiff = 13
	local moveOffsetY = 94
	local moveCatOffset = 7
	local moveNameOffset = 6 -- Move names (longest name is 12 characters?)
	local movePPOffset = 82
	local movePowerOffset = 102
	local moveAccOffset = 126

	-- Used to determine if the information about the move should be revealed to the player,
	-- or not, possibly because its randomized further and its requested to remain hidden
	local allowHiddenMoveInfo = Tracker.Data.isViewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType

	-- Draw move headers
	gui.defaultTextBackground(Theme.COLORS["Main background"])
	Drawing.drawText(Constants.SCREEN.WIDTH + moveNameOffset - 1, moveOffsetY - moveTableHeaderHeightDiff, data.m.nextmoveheader, Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + movePPOffset, moveOffsetY - moveTableHeaderHeightDiff, "PP", Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + movePowerOffset, moveOffsetY - moveTableHeaderHeightDiff, "Pow", Theme.COLORS["Header text"], bgHeaderShadow)
	Drawing.drawText(Constants.SCREEN.WIDTH + moveAccOffset, moveOffsetY - moveTableHeaderHeightDiff, "Acc", Theme.COLORS["Header text"], bgHeaderShadow)

	-- Redraw next move level in the header with a different color if close to learning new move
	if not Tracker.Data.isViewingOwn and #Tracker.getMoves(data.p.id) > 4 then
		Drawing.drawText(Constants.SCREEN.WIDTH + 30, moveOffsetY - moveTableHeaderHeightDiff, "*", Theme.COLORS[Theme.headerHighlightKey], bgHeaderShadow)
	end

	-- Redraw next move level in the header with a different color if close to learning new move
	if data.m.nextmovelevel ~= nil and data.m.nextmovespacing ~= nil and Tracker.Data.isViewingOwn and data.p.level + 1 >= data.m.nextmovelevel then
		Drawing.drawText(Constants.SCREEN.WIDTH + data.m.nextmovespacing, moveOffsetY - moveTableHeaderHeightDiff, data.m.nextmovelevel, Theme.COLORS[Theme.headerHighlightKey], bgHeaderShadow)
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

	-- Draw all four moves
	for i, move in ipairs(data.m.moves) do
		local moveTypeColor = Utils.inlineIf(move.name == MoveData.BlankMove.name, Theme.COLORS["Lower box text"], Constants.MoveTypeColors[move.type])
		local movePowerColor = Theme.COLORS["Lower box text"]

		if move.id == 237 and Tracker.Data.isViewingOwn then -- 237 = Hidden Power
			moveTypeColor = Utils.inlineIf(move.type == PokemonData.Types.UNKNOWN, Theme.COLORS["Lower box text"], Constants.MoveTypeColors[move.type])
		elseif move.id == 67 and Options["Calculate variable damage"] then -- 67 = Weather Ball
			moveTypeColor = Constants.MoveTypeColors[move.type]
		end

		-- MOVE CATEGORY
		if Options["Show physical special icons"] and allowHiddenMoveInfo then
			if move.category == MoveData.Categories.PHYSICAL then
				Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, Constants.SCREEN.WIDTH + moveCatOffset, moveOffsetY + 2, { Theme.COLORS["Lower box text"] }, shadowcolor)
			elseif move.category == MoveData.Categories.SPECIAL then
				Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, Constants.SCREEN.WIDTH + moveCatOffset, moveOffsetY + 2, { Theme.COLORS["Lower box text"] }, shadowcolor)
			end
		end

		-- MOVE TYPE COLORED RECTANGLE
		if not Theme.MOVE_TYPES_ENABLED and move.name ~= Constants.BLANKLINE and allowHiddenMoveInfo then
			gui.drawRectangle(Constants.SCREEN.WIDTH + moveNameOffset - 3, moveOffsetY + 2, 2, 7, moveTypeColor, moveTypeColor)
			moveTypeColor = Theme.COLORS["Lower box text"]
		end

		if move.isstab then
			movePowerColor = Theme.COLORS["Positive text"]
		end

		if not allowHiddenMoveInfo and not Battle.isGhost then
			moveTypeColor = Theme.COLORS["Lower box text"]
			movePowerColor = Theme.COLORS["Lower box text"]
		end

		-- DRAW MOVE EFFECTIVENESS
		if move.showeffective then
			if move.effectiveness == 0 then
				Drawing.drawText(Constants.SCREEN.WIDTH + movePowerOffset - 7, moveOffsetY, "X", Theme.COLORS["Negative text"], shadowcolor)
			else
				Drawing.drawMoveEffectiveness(Constants.SCREEN.WIDTH + movePowerOffset - 5, moveOffsetY, move.effectiveness)
			end
		end

		local moveName = move.name .. Utils.inlineIf(move.starred, "*", "")

		-- DRAW ALL THE MOVE INFORMATION
		Drawing.drawText(Constants.SCREEN.WIDTH + moveNameOffset, moveOffsetY, moveName, moveTypeColor, shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + movePPOffset, moveOffsetY, move.pp, 2, Theme.COLORS["Lower box text"], shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + movePowerOffset, moveOffsetY, move.power, 3, movePowerColor, shadowcolor)
		Drawing.drawNumber(Constants.SCREEN.WIDTH + moveAccOffset, moveOffsetY, move.accuracy, 3, Theme.COLORS["Lower box text"], shadowcolor)

		moveOffsetY = moveOffsetY + 10 -- linespacing
	end
end

function TrackerScreen.drawCarouselArea(data)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Lower box background"])

	-- Draw the border box for the Stats area
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, 136, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 19, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	local carousel = TrackerScreen.getCurrentCarouselItem()
	for _, content in pairs(carousel.getContentList(data.p.id)) do
		if content.type == Constants.ButtonTypes.IMAGE or content.type == Constants.ButtonTypes.PIXELIMAGE or content.type == Constants.ButtonTypes.FULL_BORDER then
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
TrackerScreen = {}

TrackerScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconId = function(self)
			local pokemon = Tracker.getViewedPokemon() or Tracker.getDefaultPokemon()
			-- Don't return a SpriteData.Type with this, as the animation is allowed to change here
			return pokemon.pokemonID
		end,
		clickableArea = { Constants.SCREEN.WIDTH + 5, 5, 32, 27 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, -1, 32, 32 },
		isVisible = function() return true end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			if Options["Open Book Play Mode"] then
				LogOverlay.Windower:changeTab(LogTabPokemon)
				LogSearchScreen.resetSearchSortFilter()
				LogOverlay.refreshActiveTabGrid()
				LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, pokemon.pokemonID)
			end
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.pokemonID)
		end
	},
	ShinyEffect = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SPARKLES,
		iconColors = { "Intermediate text" },
		isHighlighted = true,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 84, Constants.SCREEN.MARGIN + 10, 12, 12 },
		isVisible = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			return pokemon.isShiny or (pokemon.hasPokerus and Battle.isViewingOwn)
		end,
		updateSelf = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if pokemon.isShiny and self.image ~= Constants.PixelImages.SPARKLES then
				self.image = Constants.PixelImages.SPARKLES
			elseif pokemon.hasPokerus and self.image ~= Constants.PixelImages.VIRUS then
				self.image = Constants.PixelImages.VIRUS
			end
			self.iconColors[1] = self.isHighlighted and "Intermediate text" or "Default text"
		end,
		onClick = function(self)
			if self.image == Constants.PixelImages.SPARKLES then
				self:activatePulsing()
			end
		end,
		pulse = function(self)
			self.isHighlighted = not self.isHighlighted
			self:updateSelf()
			Program.redraw(true)
		end,
		activatePulsing = function(self)
			-- Reset the shiny pulse effect, lasts 15 seconds
			Program.removeFrameCounter("ShinyPulse")
			Program.addFrameCounter("ShinyPulse", 45, function()
				self:pulse()
			end, 19, true)
			self:pulse()
		end,
	},
	TypeDefenses = {
		-- Invisible button area for the type defenses boxes
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 27, 30, 24, },
		isVisible = function()
			local pokemon = Tracker.getViewedPokemon() or {}
			return PokemonData.isValid(pokemon.pokemonID)
		end,
		onClick = function (self)
			local pokemon = Tracker.getViewedPokemon() or {}
			TypeDefensesScreen.buildOutPagedButtons(pokemon.pokemonID or 0)
			Program.changeScreenView(TypeDefensesScreen)
		end,
	},
	SettingsGear = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 7, 7, 7 },
		isVisible = function() return true end,
		onClick = function(self)
			Program.changeScreenView(NavigationMenu)
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
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.HEART,
		textColor = "Default text",
		iconColors = { "Default text", "Upper box background", "Upper box background" },
		box = { Constants.SCREEN.WIDTH + 87, 59, 10, 8 },
		isVisible = function() return Battle.isViewingOwn and Options["Track PC Heals"] end,
		toggleState = false,
		onClick = function(self)
			self.toggleState = not self.toggleState
			if self.toggleState then
				-- self.iconColors = { "Default text", "Positive text", "Intermediate text" }
				self.iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF }
			else
				self.iconColors = { "Default text", "Upper box background", "Upper box background" }
			end
			Program.redraw(true)
		end
	},
	PCHealIncrement = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "+" end,
		textColor = "Positive text",
		box = { Constants.SCREEN.WIDTH + 83, 69, 5, 5 },
		isVisible = function() return Battle.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
			-- Prevent triple digit values (shouldn't go anywhere near this in survival)
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			Program.redraw(true)
		end
	},
	PCHealDecrement = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Constants.BLANKLINE end,
		textColor = "Negative text",
		box = { Constants.SCREEN.WIDTH + 83, 73, 5, 5 },
		isVisible = function() return Battle.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
			-- Prevent negative values
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			Program.redraw(true)
		end
	},
	LogViewerQuickAccess = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Intermediate text",
		box = { Constants.SCREEN.WIDTH + 84, 64, 10, 10 },
		isVisible = function() return Battle.isViewingOwn and Options["Open Book Play Mode"] and not Options["Track PC Heals"] end,
		onClick = function(self)
			-- Default to pulling up the Routes info screen
			LogOverlay.Windower:changeTab(LogTabRoutes)
			LogSearchScreen.resetSearchSortFilter()
			LogOverlay.refreshActiveTabGrid()
			-- If a route is available, show that one specifically
			local mapId = TrackerAPI.getMapId()
			if RouteData.hasAnyEncounters(mapId) then
				LogOverlay.Windower:changeTab(LogTabRouteDetails, 1, 1, mapId)
			end
			Program.redraw(true)
		end
	},
	InvisibleStatsArea = {
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + 103, Constants.SCREEN.MARGIN, 44, 75 },
		isVisible = function() return Options["Open Book Play Mode"] and not Battle.isViewingOwn end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			LogOverlay.Windower:changeTab(LogTabPokemon)
			LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, pokemon.pokemonID)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.pokemonID)
		end,
	},
	RouteDetails = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 57, 96, 23 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 63, 8, 12 },
		isVisible = function() return not Battle.isViewingOwn end,
		onClick = function(self)
			-- Only activate for wild encounter battles
			if not Battle.isWildEncounter then
				return
			end
			if not RouteData.hasRouteEncounterArea(Program.GameData.mapId, Battle.CurrentRoute.encounterArea) then
				return
			end
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, {
				mapId = Program.GameData.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			})
		end,
	},
	TrainerDetails = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.BATTLE_BALLS,
		iconColors = Constants.PixelImages.BATTLE_BALLS.iconColors,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 57, 96, 23 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 78, 61, 16, 16 },
		isVisible = function() return not Battle.isViewingOwn end,
		onClick = function(self)
			-- Only activate for trainer battles
			if Battle.isWildEncounter then
				return
			end
			local trainerId = TrackerAPI.getOpponentTrainerId()
			if TrainerInfoScreen.buildScreen(trainerId) then
				Program.changeScreenView(TrainerInfoScreen)
			end
		end,
	},
	AbilityUpper = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + 37, 35, 63, 11},
		box = { Constants.SCREEN.WIDTH + 88, 43, 11, 11 },
		isVisible = function() return not Battle.isViewingOwn end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			local abilityId
			if Options["Open Book Play Mode"] then
				abilityId = PokemonData.getAbilityId(pokemon.pokemonID, 0) -- 0 is the first ability
			else
				local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID) or {}
				abilityId = trackedAbilities[1].id or 0
			end
			if AbilityData.isValid(abilityId) then
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, abilityId)
			else
				TrackerScreen.openNotePadWindow(pokemon.pokemonID)
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
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			local abilityId
			if Battle.isViewingOwn then
				abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
			elseif Options["Open Book Play Mode"] then
				abilityId = PokemonData.getAbilityId(pokemon.pokemonID, 1) -- 1 is the second ability
			else
				local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)
				abilityId = trackedAbilities[2].id
			end
			if AbilityData.isValid(abilityId) then
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, abilityId)
			else
				TrackerScreen.openNotePadWindow(pokemon.pokemonID)
			end
		end
	},
	HealsInBag = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 54, 55, 21 },
		isVisible = function() return Battle.isViewingOwn end,
		onClick = function(self)
			HealsInBagScreen.changeTab(HealsInBagScreen.Tabs.All)
			Program.changeScreenView(HealsInBagScreen)
		end
	},
	MovesHistory = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		textColor = "Header text", -- set later after highlight color is calculated
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 81, 75, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 81, 75, 10 },
		boxColors = { "Header text", "Main background" },
		isVisible = function()
			local pokemon = Tracker.getViewedPokemon() or {}
			return PokemonData.isValid(pokemon.pokemonID)
		end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			local hasMoves = MoveHistoryScreen.buildOutHistory(pokemon.pokemonID, pokemon.level)
			if hasMoves then
				Program.changeScreenView(MoveHistoryScreen)
			end
		end,
	},
	CatchRates = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		textColor = "Header text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 77, 81, 50, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 77, 81, 50, 10 },
		boxColors = { "Header text", "Main background" },
		isVisible = function()
			return Options["Show Poke Ball catch rate"] and not Battle.isViewingOwn and Battle.isWildEncounter
		end,
		onClick = function(self)
			local pokemon = TrackerAPI.getEnemyPokemon()
			if CatchRatesScreen.buildScreen(pokemon) then
				CatchRatesScreen.previousScreen = TrackerScreen
				Program.changeScreenView(CatchRatesScreen)
			end
		end,
	},
	NotepadTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		getText = function(self) return string.format("(%s)", Resources.TrackerScreen.LeaveANote) end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 11, 11 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES and not Battle.isViewingOwn end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			TrackerScreen.openNotePadWindow(pokemon.pokemonID)
		end
	},
	LastAttackSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SWORD_ATTACK,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		iconColors = { "Lower box text" },
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 140, 13, 13 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.LAST_ATTACK end,
		onClick = function(self)
			-- Eventually clicking this will show a Move History screen
		end
	},
	BattleDetailsSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SPARKLES,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 140, 12, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.BATTLE_DETAILS end,
		onClick = function(self)
			BattleDetailsScreen.updateData(true)
			Program.changeScreenView(BattleDetailsScreen)
		end,
	},
	RouteSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 8, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.ROUTE_INFO end,
		onClick = function(self)
			local routeInfo = {
				mapId = Program.GameData.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	},
	PedometerStepText = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOCK,
		getText = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			local formattedStepCount = Utils.formatNumberWithCommas(stepCount)
			return string.format("%s: %s", Resources.TrackerScreen.PedometerSteps, formattedStepCount)
		end,
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 141, 10, 10 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateSelf = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			if stepCount > 999999 then -- 1,000,000 is the arbitrary cutoff
				stepCount = 999999
			end
			if Program.Pedometer.goalSteps ~= 0 and stepCount >= Program.Pedometer.goalSteps then
				self.textColor = "Positive text"
			else
				self.textColor = "Lower box text"
			end
		end,
	},
	PedometerGoal = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.TrackerScreen.PedometerGoal end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, 140, 23, 11 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, 140, 23, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateSelf = function(self)
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
		getText = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			if stepCount <= 0 then
				return Resources.TrackerScreen.PedometerTotal
			else
				return Resources.TrackerScreen.PedometerReset
			end
		end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, 140, 28, 11 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, 140, 28, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		onClick = function(self)
			if self:getText() == Resources.TrackerScreen.PedometerReset then
				Program.Pedometer.lastResetCount = Program.Pedometer.totalSteps
			elseif self:getText() == Resources.TrackerScreen.PedometerTotal then
				Program.Pedometer.lastResetCount = 0
			end
			Program.redraw(true)
		end
	},
	TrainerSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SWORD_ATTACK,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		iconColors = { "Positive text" },
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 13, 13 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.TRAINERS end,
		onClick = function(self)
			if TrainersOnRouteScreen.buildScreen(TrackerAPI.getMapId()) then
				Program.changeScreenView(TrainersOnRouteScreen)
			end
		end
	},
}

-- This is also a priority list, lower the number has more priority of showing up before the others; must be sequential
TrackerScreen.CarouselTypes = {
	BADGES = 1, -- Outside of battle
	TRAINERS = 2, -- Immediately after a battle
	LAST_ATTACK = 3, -- During battle, only between turns
	ROUTE_INFO = 4, -- During battle, only if encounter is a wild pokemon
	NOTES = 5, -- During battle
	BATTLE_DETAILS = 6, -- During battle
	PEDOMETER = 7, -- Outside of battle
}

TrackerScreen.carouselIndex = 1
TrackerScreen.tipMessageIndex = 0
TrackerScreen.CarouselItems = {}

TrackerScreen.PokeBalls = {
	chosenBall = -1,
	ColorList = { Drawing.Colors.BLACK, 0xFFF04037, Drawing.Colors.WHITE, }, -- Colors used to draw all Pokeballs
	ColorListGray = { Drawing.Colors.BLACK, Utils.calcGrayscale(0xFFF04037, 0.6), Drawing.Colors.WHITE, },
	ColorListFainted = { Drawing.Colors.BLACK, 0x22F04037, 0x44FFFFFF, },
	ColorListMasterBall = { Drawing.Colors.BLACK, 0xFFA040B8, Drawing.Colors.WHITE, 0xFFF86088, 0xFFCB5C95 },
	getLabel = function(ballIndex)
		if ballIndex == 1 then
			return Resources.TrackerScreen.RandomBallLeft
		elseif ballIndex == 2 then
			return Resources.TrackerScreen.RandomBallMiddle
		elseif ballIndex == 3 then
			return Resources.TrackerScreen.RandomBallRight
		else
			return Constants.BLANKLINE
		end
	end,
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
			getText = function(self) return Constants.STAT_STATES[self.statState].text end,
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + 129, heightOffset, 8, 8 },
			boxColors = { "Upper box border", "Upper box background" },
			statStage = statKey,
			statState = 0,
			isVisible = function() return Battle.inActiveBattle() and not Battle.isViewingOwn and not Options["Open Book Play Mode"] end,
			onClick = function(self)
				self.statState = ((self.statState + 1) % 4) -- 4 total possible markings for a stat state
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
	local badgeInfoTable = Constants.Badges[GameSettings.game] or {}
	local badgePrefix = badgeInfoTable.Prefix or "FRLG" -- just picked a default
	local kerningOffsets = badgeInfoTable.IconOffsets or {}
	for index = 1, 8, 1 do
		local badgeName = "badge" .. index
		local xOffset = Constants.SCREEN.WIDTH + 7 + ((index-1) * (badgeWidth + 1)) + (kerningOffsets[index] or 0)

		TrackerScreen.Buttons[badgeName] = {
			type = Constants.ButtonTypes.IMAGE,
			image = FileManager.buildImagePath(FileManager.Folders.Badges, badgePrefix .. "_" .. badgeName .. "_OFF", FileManager.Extensions.BADGE),
			box = { xOffset, 138, badgeWidth, badgeWidth },
			badgeIndex = index,
			badgeState = 0,
			isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.BADGES end,
			updateState = function(self, state)
				-- Update image path if the state has changed
				if self.badgeState ~= state then
					self.badgeState = state
					local badgeOff = Utils.inlineIf(self.badgeState == 0, "_OFF", "")
					local name = badgePrefix .. "_badge" .. self.badgeIndex .. badgeOff
					self.image = FileManager.buildImagePath(FileManager.Folders.Badges, name, FileManager.Extensions.BADGE)
				end
			end
		}
	end

	-- Set the color for next move level highlighting for the current theme now, instead of constantly re-calculating it
	Theme.setNextMoveLevelHighlight(true)
	TrackerScreen.buildCarousel()
	TrackerScreen.randomlyChooseBall()
	TrackerScreen.refreshButtons()
end

function TrackerScreen.refreshButtons()
	for _, button in pairs(TrackerScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

-- Define each Carousel Item, must will have blank data that will be populated later with contextual data
function TrackerScreen.buildCarousel()
	-- Helper functions
	-- Checks if the early game conditions are correct to show route encounter info instead of the normal carousel item
	local function showEarlyRouteEncounters()
		-- In trainer battle
		if Battle.inActiveBattle() and not Battle.isWildEncounter then
			return false
		end
		-- Pokemon high enough level
		local pokemon = Tracker.getPokemon(1, true) or {}
		if (pokemon.level or 0) >= 13 then
			return false
		end
		-- No wild grass encounters available
		if not RouteData.hasRouteEncounterArea(TrackerAPI.getMapId(), RouteData.EncounterArea.LAND) then
			return false
		end
		return true
	end

	--  BADGE
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.BADGES] = {
		type = TrackerScreen.CarouselTypes.BADGES,
		framesToShow = 210,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselBadges.toggleState then
				return false
			end
			-- Pedometer overrides badges if no carousel rotation
			if not Options["Allow carousel rotation"] and TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.PEDOMETER]:canShow() then
				return false
			end
			return Battle.isViewingOwn and not showEarlyRouteEncounters()
		end,
		getContentList = function(self)
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
		framesToShow = 180,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselNotes.toggleState then
				return false
			end
			return not Battle.isViewingOwn
		end,
		getContentList = function(self, pokemonID)
			local noteText = Tracker.getNote(pokemonID)
			if Main.IsOnBizhawk() then
				if not Utils.isNilOrEmpty(noteText) then
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
		framesToShow = 180,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselLastAttack.toggleState then
				return false
			end
			-- Don't show the last attack information while the enemy is attacking, or it spoils the move & damage
			local properBattleTiming = Battle.inActiveBattle() and not Battle.enemyHasAttacked and Battle.lastEnemyMoveId ~= 0
			return Options["Show last damage calcs"] and properBattleTiming
		end,
		getContentList = function(self)
			local lastAttackMsg
			-- Currently this only records last move used for damaging moves
			if MoveData.isValid(Battle.lastEnemyMoveId) then
				local moveInfo = MoveData.Moves[Battle.lastEnemyMoveId] or MoveData.BlankMove
				if Battle.damageReceived > 0 then
					local damageLabel = Utils.inlineIf(Battle.numBattlers > 2, Resources.TrackerScreen.DamageTakenInTeams, moveInfo.name)
					lastAttackMsg = string.format("%s: %d %s", damageLabel, math.floor(Battle.damageReceived), Resources.TrackerScreen.DamageTaken)
					local ownPokemon = Battle.getViewedPokemon(true)
					if ownPokemon ~= nil and Battle.damageReceived >= ownPokemon.curHP then
						-- Change the icon color to warn user that the damage taken is potentially lethal
						TrackerScreen.Buttons.LastAttackSummary.iconColors = { "Negative text" }
					else
						TrackerScreen.Buttons.LastAttackSummary.iconColors = { "Lower box text" }
					end
				else
					-- Unused
					lastAttackMsg = "Last move: " .. moveInfo.name
				end
			else
				-- Unused
				lastAttackMsg = "Waiting for a new move..."
			end

			TrackerScreen.Buttons.LastAttackSummary.updatedText = lastAttackMsg
			if Main.IsOnBizhawk() then
				return { TrackerScreen.Buttons.LastAttackSummary }
			else
				return lastAttackMsg or ""
			end
		end,
	}

	-- BATTLE DETAILS
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.BATTLE_DETAILS] = {
		type = TrackerScreen.CarouselTypes.BATTLE_DETAILS,
		framesToShow = 180,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselBattleDetails.toggleState then
				return false
			end
			return Battle.inActiveBattle() and BattleDetailsScreen.hasDetails()
		end,
		getContentList = function(self)
			local viewIndex = Battle.getViewedIndex()
			local summaryText = BattleDetailsScreen.Data.DetailsSummary[viewIndex] or ""
			TrackerScreen.Buttons.BattleDetailsSummary.updatedText = summaryText
			if Main.IsOnBizhawk() then
				return { TrackerScreen.Buttons.BattleDetailsSummary }
			else
				return summaryText
			end
		end,
	}

	-- ROUTE INFO
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.ROUTE_INFO] = {
		type = TrackerScreen.CarouselTypes.ROUTE_INFO,
		framesToShow = 180,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselRouteInfo.toggleState then
				return false
			end
			if showEarlyRouteEncounters() then
				Battle.CurrentRoute.encounterArea = RouteData.EncounterArea.LAND
				return true
			else
				return Battle.inActiveBattle() and Battle.CurrentRoute.hasInfo
			end
		end,
		getContentList = function(self)
			local totalPossible = RouteData.countPokemonInArea(Program.GameData.mapId, Battle.CurrentRoute.encounterArea)
			local routeEncounters = Tracker.getRouteEncounters(Program.GameData.mapId, Battle.CurrentRoute.encounterArea)
			local totalSeen = #routeEncounters

			local ratioText
			-- For randomizer settings that have more Pokemon in a route than normal
			if totalSeen > totalPossible then
				ratioText = tostring(totalSeen)
			else
				ratioText = string.format("%s/%s", totalSeen, totalPossible)
			end

			local encounterAreaLabels = {
				[RouteData.EncounterArea.LAND] = Resources.TrackerScreen.EncounterWalking,
				[RouteData.EncounterArea.SURFING] = Resources.TrackerScreen.EncounterSurfing,
				[RouteData.EncounterArea.UNDERWATER] = Resources.TrackerScreen.EncounterUnderwater,
				[RouteData.EncounterArea.STATIC] = Resources.TrackerScreen.EncounterStatic,
				[RouteData.EncounterArea.ROCKSMASH] = Resources.TrackerScreen.EncounterRockSmash,
				[RouteData.EncounterArea.SUPERROD] = Resources.TrackerScreen.EncounterSuperRod,
				[RouteData.EncounterArea.GOODROD] = Resources.TrackerScreen.EncounterGoodRod,
				[RouteData.EncounterArea.OLDROD] = Resources.TrackerScreen.EncounterOldRod,
			}

			local encounterAreaText = encounterAreaLabels[Battle.CurrentRoute.encounterArea]
			local routeSummaryText = string.format("%s: %s %s", encounterAreaText, ratioText, Resources.TrackerScreen.EncounterSeenPokemon)
			TrackerScreen.Buttons.RouteSummary.updatedText = routeSummaryText

			if Main.IsOnBizhawk() then
				return { TrackerScreen.Buttons.RouteSummary }
			else
				return TrackerScreen.Buttons.RouteSummary.updatedText or ""
			end
		end,
	}

	--  PEDOMETER
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.PEDOMETER] = {
		type = TrackerScreen.CarouselTypes.PEDOMETER,
		framesToShow = 210,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselPedometer.toggleState then
				return false
			end
			return Battle.isViewingOwn and Program.Pedometer:isInUse()
		end,
		getContentList = function(self)
			TrackerScreen.Buttons.PedometerStepText:updateSelf()
			TrackerScreen.Buttons.PedometerGoal:updateSelf()
			if Main.IsOnBizhawk() then
				return {
					TrackerScreen.Buttons.PedometerStepText,
					TrackerScreen.Buttons.PedometerGoal,
					TrackerScreen.Buttons.PedometerReset,
				}
			else
				return TrackerScreen.Buttons.PedometerStepText:getText() or ""
			end
		end,
	}

	-- TRAINERS
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.TRAINERS] = {
		type = TrackerScreen.CarouselTypes.TRAINERS,
		framesToShow = 420,
		lockedSpeed = true,
		canShow = function(self)
			if not SetupScreen.Buttons.CarouselTrainers.toggleState then
				return false
			end
			local battleJustEnded = Program.Frames.Others["TrainerBattleEnded"] ~= nil
			return not Battle.inActiveBattle() and battleJustEnded and RouteData.hasRouteTrainers()
		end,
		getContentList = function(self)
			if RouteData.hasRouteTrainers() then
				local routeId = TrackerAPI.getMapId()
				local route = RouteData.Info[routeId]
				local routeName = RouteData.getRouteOrAreaName(routeId)
				local defeatedTrainersList, totalInArea
				if route.area ~= nil then
					defeatedTrainersList, totalInArea = Program.getDefeatedTrainersByCombinedArea(route.area)
				elseif route.trainers and #route.trainers > 0 then
					defeatedTrainersList, totalInArea = Program.getDefeatedTrainersByLocation(routeId)
				end
				local text
				if defeatedTrainersList and totalInArea then
					text = string.format("%s: %s/%s", "Trainers defeated", #defeatedTrainersList, totalInArea)
				else
					text = string.format("%s: %s", routeName, "N/A")
				end
				TrackerScreen.Buttons.TrainerSummary.updatedText = text
			else
				TrackerScreen.Buttons.TrainerSummary.updatedText = "No Trainers in this area."
			end

			if Main.IsOnBizhawk() then
				return { TrackerScreen.Buttons.TrainerSummary }
			else
				return TrackerScreen.Buttons.TrainerSummary.updatedText or ""
			end
		end,
	}

	-- A default carousel item if none of the others can be shown (perhaps all are disabled)
	TrackerScreen.CarouselItems[0] = {
		type = 0,
		framesToShow = 60,
		canShow = function(self) return true end,
		getContentList = function(self)
			local text = "" or string.format("%s: v%s", Resources.StartupScreen.Title, Main.TrackerVersion)
			return Main.IsOnBizhawk() and { text } or text
		end,
	}
end

---Returns the active carousel item, or if expired/unable to show, the next available carousel item
---@return table carouselItem
function TrackerScreen.getCurrentCarouselItem()
	local function rotateToNextItem()
		for _ = 1, #TrackerScreen.CarouselItems, 1 do
			TrackerScreen.carouselIndex = (TrackerScreen.carouselIndex % #TrackerScreen.CarouselItems) + 1
			if TrackerScreen.CarouselItems[TrackerScreen.carouselIndex]:canShow() then
				break
			end
		end
		Program.Frames.carouselActive = 0
	end

	local carousel = TrackerScreen.CarouselItems[TrackerScreen.carouselIndex]
	if not carousel or not carousel:canShow() then
		rotateToNextItem()
	elseif Options["Allow carousel rotation"] then
		-- Adjust rotation delay check for carousel based on the speed of emulation
		local adjustedVisibilityFrames = (carousel.framesToShow or 0) * Program.clientFpsMultiplier
		-- Adjust based on speed setting
		if not carousel.lockedSpeed and Options["CarouselSpeed"] ~= "1" then
			local speedOption = Options.CarouselSpeedMap[Options["CarouselSpeed"] or "1"]
			local multiplier = speedOption and speedOption.multiplier or 1
			adjustedVisibilityFrames = adjustedVisibilityFrames * multiplier
		end
		if Program.Frames.carouselActive > adjustedVisibilityFrames then
			rotateToNextItem()
		end
	end

	if TrackerScreen.CarouselItems[TrackerScreen.carouselIndex]:canShow() then
		return TrackerScreen.CarouselItems[TrackerScreen.carouselIndex]
	else
		return TrackerScreen.CarouselItems[0] -- Default carousel item
	end
end

function TrackerScreen.updateButtonStates()
	local opposingPokemon = Battle.getViewedPokemon(false)
	if opposingPokemon ~= nil then
		local statMarkings = Tracker.getStatMarkings(opposingPokemon.pokemonID)

		for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
			local button = TrackerScreen.Buttons[statKey]
			local statValue = statMarkings[statKey]

			button.statState = statValue
			button.textColor = Constants.STAT_STATES[statValue].textColor
		end
	end
end

function TrackerScreen.openNotePadWindow(pokemonId, onCloseFunc)
	if not PokemonData.isValid(pokemonId) then return end

	local BLANK = Constants.BLANKLINE
	local pokemonName = PokemonData.Pokemon[pokemonId].name
	local form = ExternalUI.BizForms.createForm(
		string.format("%s (%s)", Resources.TrackerScreen.LeaveANote, pokemonName),
		465, 220, nil, nil, onCloseFunc)

	form:createLabel(string.format("%s %s:", Resources.TrackerScreen.PromptNoteDesc, pokemonName), 9, 10)
	local noteTextBox = form:createTextBox(Tracker.getNote(pokemonId), 10, 30, 430, 20)
	form:createLabel(string.format("%s %s:", Resources.TrackerScreen.PromptNoteAbilityDesc, pokemonName), 9, 60)

	local abilityList = {}
	table.insert(abilityList, BLANK)
	abilityList = AbilityData.populateAbilityDropdown(abilityList)

	local trackedAbilities = Tracker.getAbilities(pokemonId)
	local trackedAbility1 = BLANK
	local trackedAbility2 = BLANK
	if AbilityData.isValid(trackedAbilities[1].id) then
		trackedAbility1 = AbilityData.Abilities[trackedAbilities[1].id].name
	end
	if AbilityData.isValid(trackedAbilities[2].id) then
		trackedAbility2 = AbilityData.Abilities[trackedAbilities[2].id].name
	end
	local abilityOneDropdown = form:createDropdown(abilityList, 10, 80, 145, 30, trackedAbility1)
	local abilityTwoDropdown = form:createDropdown(abilityList, 10, 110, 145, 30, trackedAbility2)

	local saveAndClose = string.format("%s && %s", Resources.AllScreens.Save, Resources.AllScreens.Close)
	form:createButton(saveAndClose, 80, 145, function()
		local formInput = ExternalUI.BizForms.getText(noteTextBox)
		if formInput ~= nil then
			local abilityOneText = ExternalUI.BizForms.getText(abilityOneDropdown)
			local abilityTwoText = ExternalUI.BizForms.getText(abilityTwoDropdown)
			Tracker.TrackNote(pokemonId, formInput)
			Tracker.setAbilities(pokemonId, abilityOneText, abilityTwoText)
			Program.redraw(true)
		end
		form:destroy()
	end)
	form:createButton(Resources.TrackerScreen.PromptNoteClearAbilities, 195, 145, function()
		ExternalUI.BizForms.setText(abilityOneDropdown, BLANK)
		ExternalUI.BizForms.setText(abilityTwoDropdown, BLANK)
	end)
	form:createButton(Resources.AllScreens.Cancel, 310, 145, function()
		form:destroy()
	end)
end

function TrackerScreen.openEditStepGoalWindow()
	local form = ExternalUI.BizForms.createForm(Resources.TrackerScreen.PromptStepsTitle, 350, 170)
	local currentSteps = tostring(Program.Pedometer.goalSteps or 0)

	form:createLabel(Resources.TrackerScreen.PromptStepsDesc1, 36, 10)
	form:createLabel(string.format("[%s]", Resources.TrackerScreen.PromptStepsDesc2), 110, 28)
	form:createLabel(Resources.TrackerScreen.PromptStepsEnterGoal, 58, 50)
	local textBox = form:createTextBox(currentSteps, 60, 70, 200, 30, "UNSIGNED", false, true)
	form:createButton(Resources.AllScreens.Save, 82, 100, function()
		local formInput = ExternalUI.BizForms.getText(textBox)
		if not Utils.isNilOrEmpty(formInput) then
			local newStepGoal = tonumber(formInput)
			if newStepGoal ~= nil then
				Program.Pedometer.goalSteps = newStepGoal
				Program.redraw(true)
			end
		end
		form:destroy()
	end)
	form:createButton(Resources.AllScreens.Cancel, 167, 100, function()
		form:destroy()
	end)
end

function TrackerScreen.randomlyChooseBall()
	TrackerScreen.PokeBalls.chosenBall = math.random(3)
	return TrackerScreen.PokeBalls.chosenBall
end

function TrackerScreen.canShowBallPicker()
	-- If the player is in the lab without any Pokemon
	return Options["Show random ball picker"] and RouteData.Locations.IsInLab[Program.GameData.mapId] and Tracker.getPokemon(1, true) == nil
end

-- USER INPUT FUNCTIONS
function TrackerScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, TrackerScreen.Buttons)
	Input.checkAnyMovesClicked(xmouse, ymouse)

	-- Check if mouse clicked on the game screen: on a new move learned, show info
	local gameFooterHeight = 45
	if Input.isMouseInArea(xmouse, ymouse, 0, Constants.SCREEN.HEIGHT - gameFooterHeight, Constants.SCREEN.WIDTH, gameFooterHeight) then
		local learnedInfoTable = Program.getLearnedMoveInfoTable()
		if learnedInfoTable.moveId ~= nil then
			InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, learnedInfoTable.moveId)
		end
	end
end

-- DRAWING FUNCTIONS
function TrackerScreen.drawScreen()
	TrackerScreen.updateButtonStates()

	Drawing.drawBackgroundAndMargins()

	local mustViewOwn = not Battle.inActiveBattle() or nil
	local displayData = DataHelper.buildTrackerScreenDisplay(mustViewOwn)

	-- Upper boxes
	if TrackerScreen.canShowBallPicker() then
		TrackerScreen.drawBallPicker()
	else
		TrackerScreen.drawPokemonInfoArea(displayData)
	end
	TrackerScreen.drawStatsArea(displayData)

	-- Lower boxes
	TrackerScreen.drawCarouselArea(displayData)
	if Tracker.getPokemon(1, true) == nil and Options["Show on new game screen"] then -- show favorites
		TrackerScreen.drawFavorites()
	else
		TrackerScreen.drawMovesArea(displayData)
	end
end

function TrackerScreen.drawPokemonInfoArea(data)
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	-- Draw top box view
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, 96, 52, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	-- POKEMON TYPES
	if not Options["Reveal info if randomized"] and not Battle.isViewingOwn and PokemonData.IsRand.types then
		-- Don't reveal randomized Pokemon types for enemies
		Drawing.drawTypeIcon(PokemonData.Types.UNKNOWN, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 33)
	elseif data.p.types[1] ~= PokemonData.Types.UNKNOWN then
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

	if Battle.isViewingOwn then
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
		if not Utils.isNilOrEmpty(data.p.lastlevel) then
			extraInfoText = string.format("%s %s.%s", Resources.TrackerScreen.BattleLastSeen, Resources.TrackerScreen.LevelAbbreviation, data.p.lastlevel)
		else
			extraInfoText = Resources.TrackerScreen.BattleNewEncounter
		end
		-- Prioritize showing open book stuff with highlight color
		if Options["Open Book Play Mode"] then
			extraInfoColor = Theme.COLORS["Default text"]
		else
			extraInfoColor = Theme.COLORS["Intermediate text"]
		end
	end

	local levelEvoText = string.format("%s.%s", Resources.TrackerScreen.LevelAbbreviation, data.p.level)
	local abbreviationText = Utils.getEvoAbbreviation(data.p.evo)
	local evoSpacing
	if data.p.evo ~= PokemonData.Evolutions.NONE then
		levelEvoText = levelEvoText .. " ("
		evoSpacing = 1 + Utils.calcWordPixelLength(levelEvoText)
		levelEvoText = levelEvoText .. abbreviationText .. ")"
	end

	-- Squeeze text together a bit to show the exp bar
	if Options["Show experience points bar"] and Battle.isViewingOwn then
		linespacing = linespacing - 1
	end

	-- POKEMON NAME
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, data.p.name, Theme.COLORS["Default text"], shadowcolor)
	offsetY = offsetY + linespacing

	-- POKEMON HP, LEVEL, & EVOLUTION INFO
	if Battle.isViewingOwn then
		local hpText = string.format("%s:", Resources.TrackerScreen.HPAbbreviation)
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, hpText, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX + 16, offsetY, extraInfoText, extraInfoColor, shadowcolor)
		offsetY = offsetY + linespacing

		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, levelEvoText, Theme.COLORS["Default text"], shadowcolor)
		if data.p.evo ~= PokemonData.Evolutions.NONE and evoSpacing ~= nil then
			-- Draw over the evo method in the new color to reflect if evo is possible/ready
			local evoReadyFriendship = (Options["Determine friendship readiness"] and data.p.evo == PokemonData.Evolutions.FRIEND_READY)
			local evoReadyLevel = Utils.isReadyToEvolveByLevel(data.p.evo, data.p.level)
			local evoReadyStone = Utils.isReadyToEvolveByStone(data.p.evo)
			local evoTextColor
			if evoReadyFriendship or evoReadyLevel or evoReadyStone then
				evoTextColor = Theme.COLORS["Positive text"]
			else
				evoTextColor = Theme.COLORS["Intermediate text"]
			end
			-- Highlight some % of the evo text based on progress towards friendship requirement
			if (data.p.evo == PokemonData.Evolutions.FRIEND) and Options["Determine friendship readiness"] and Battle.isViewingOwn then
				local percentFill = (data.p.friendship - data.p.friendshipBase) / (Program.GameData.friendshipRequired - data.p.friendshipBase)
				local numHighlightedChars = math.floor(abbreviationText:len() * percentFill)
				local highlightedEvo = abbreviationText:sub(1, numHighlightedChars)
				Drawing.drawText(Constants.SCREEN.WIDTH + offsetX + evoSpacing, offsetY, highlightedEvo, Theme.COLORS["Positive text"], shadowcolor)
			else
				Drawing.drawText(Constants.SCREEN.WIDTH + offsetX + evoSpacing, offsetY, abbreviationText, evoTextColor, shadowcolor)
			end
		end
		offsetY = offsetY + linespacing
	else
		-- Swaps the display order, Level/Evo first, then Last Level Seen.
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, levelEvoText, Theme.COLORS["Default text"], shadowcolor)
		offsetY = offsetY + linespacing
		Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, extraInfoText, extraInfoColor, shadowcolor)
		offsetY = offsetY + linespacing
	end

	if Options["Show experience points bar"] and Battle.isViewingOwn then
		local expPercentage = data.p.curExp / data.p.totalExp
		Drawing.drawPercentageBar(Constants.SCREEN.WIDTH + offsetX + 2, offsetY + 2, 60, 3, expPercentage)
		offsetY = offsetY + 5
	end

	-- HELD ITEM AND ABILITIES
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, data.p.line1, Theme.COLORS["Intermediate text"], shadowcolor)
	offsetY = offsetY + linespacing
	Drawing.drawText(Constants.SCREEN.WIDTH + offsetX, offsetY, data.p.line2, Theme.COLORS["Intermediate text"], shadowcolor)
	offsetY = offsetY + linespacing

	-- Unsqueeze the text
	if Options["Show experience points bar"] and Battle.isViewingOwn then
		linespacing = linespacing + 1
	end

	-- HEALS INFO / ENCOUNTER INFO
	local infoBoxHeight = 23
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 52, 96, infoBoxHeight, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	if Battle.isViewingOwn and data.p.id ~= 0 then
		local healsInBagText = string.format("%s:", Resources.TrackerScreen.HealsInBag)
		local healsValueText
		if Options["Show heals as whole number"] then
			healsValueText = string.format("%.0f %s (%s)", data.x.healvalue, Resources.TrackerScreen.HPAbbreviation, data.x.healnum)
		else
			healsValueText = string.format("%.0f%% %s (%s)", data.x.healperc, Resources.TrackerScreen.HPAbbreviation, data.x.healnum)
		end
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 57, healsInBagText, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(Constants.SCREEN.WIDTH + 6, 68, healsValueText, Theme.COLORS["Default text"], shadowcolor)

		if Options["Track PC Heals"] then
			-- Auto-tracking PC Heals button
			Drawing.drawButton(TrackerScreen.Buttons.PCHealAutoTracking, shadowcolor)

			-- Right-align the PC Heals number
			local healNumberSpacing = (2 - string.len(tostring(data.x.pcheals))) * 5 + 87
			Drawing.drawText(Constants.SCREEN.WIDTH + healNumberSpacing, 68, data.x.pcheals, Utils.getCenterHealColor(), shadowcolor)

			-- Draw the '+' and '-' for incrementing/decrementing heal count
			local incBtn = TrackerScreen.Buttons.PCHealIncrement
			local decBtn = TrackerScreen.Buttons.PCHealDecrement
			if Theme.DRAW_TEXT_SHADOWS then
				Drawing.drawText(incBtn.box[1] + 1, incBtn.box[2] + 1, incBtn:getText(), shadowcolor, nil, 5, Constants.Font.FAMILY)
				Drawing.drawText(decBtn.box[1] + 1, decBtn.box[2] + 1, decBtn:getText(), shadowcolor, nil, 5, Constants.Font.FAMILY)
			end
			Drawing.drawText(incBtn.box[1], incBtn.box[2], incBtn:getText(), Theme.COLORS[incBtn.textColor], nil, 5, Constants.Font.FAMILY)
			Drawing.drawText(decBtn.box[1], decBtn.box[2], decBtn:getText(), Theme.COLORS[decBtn.textColor], nil, 5, Constants.Font.FAMILY)
		else
			Drawing.drawButton(TrackerScreen.Buttons.LogViewerQuickAccess, shadowcolor)
		end
	elseif Battle.inActiveBattle() then
		local encounterText, routeText, routeInfoX
		if Battle.isWildEncounter then
			encounterText = string.format("%s: %s", Resources.TrackerScreen.BattleSeenInTheWild, data.x.encounters)
			routeText = data.x.route
			routeInfoX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 11
			Drawing.drawButton(TrackerScreen.Buttons.RouteDetails, shadowcolor)
		else
			encounterText = string.format("%s: %s", Resources.TrackerScreen.BattleSeenOnTrainers, data.x.encounters)
			routeText = "" -- string.format("%s:", Resources.TrackerScreen.BattleTeam) -- Remove word "Team" as there's no space
			routeInfoX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
			Drawing.drawButton(TrackerScreen.Buttons.TrainerDetails, shadowcolor)
			Drawing.drawTrainerTeamPokeballs(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2, Constants.SCREEN.MARGIN + 65, shadowcolor)
		end

		Drawing.drawText(routeInfoX, Constants.SCREEN.MARGIN + 53, encounterText, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(routeInfoX, Constants.SCREEN.MARGIN + 63, routeText, Theme.COLORS["Default text"], shadowcolor)
	end

	-- POKEMON ICON (draw last to overlap anything else, if necessary)
	SpriteData.checkForFaintingStatus(data.p.id, data.p.curHP <= 0)
	SpriteData.checkForSleepingStatus(data.p.id, data.p.status)
	Drawing.drawButton(TrackerScreen.Buttons.PokemonIcon, shadowcolor)

	-- Temporary process to refresh the icon before it's first drawn
	if TrackerScreen.Buttons.ShinyEffect:isVisible() then
		TrackerScreen.Buttons.ShinyEffect:updateSelf()
		Drawing.drawButton(TrackerScreen.Buttons.ShinyEffect, shadowcolor)
	end

	-- STATUS ICON
	if data.p.status ~= MiscData.StatusCodeMap[MiscData.StatusType.None] then
		Drawing.drawStatusIcon(data.p.status, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 30 - 16 + 1, Constants.SCREEN.MARGIN + 1)
	end

	-- GENDER ICON
	if Options["Display gender"] and PokemonData.isValid(data.p.id) and data.p.gender ~= MiscData.Gender.UNKNOWN then
		local gSymbol
		if data.p.gender == MiscData.Gender.MALE then
			gSymbol = Constants.PixelImages.MALE_SYMBOL
		else
			gSymbol = Constants.PixelImages.FEMALE_SYMBOL
		end
		local nameWidth = Utils.calcWordPixelLength(data.p.name)
		local gX, gY, gShadow
		local gColors = { Theme.COLORS["Default text"] }
		-- Check if there's room to draw the symbol next to the name, otherwise overlay on the Pokemon icon
		if nameWidth < 45 then
			gX = Constants.SCREEN.WIDTH + 36 + nameWidth + 4
			gY = Constants.SCREEN.MARGIN + 2
			gShadow = shadowcolor
		else
			gX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 23
			gY = Constants.SCREEN.MARGIN + 20
			if gSymbol == Constants.PixelImages.FEMALE_SYMBOL then
				gX = gX + 3
			end
			table.insert(gColors, Theme.COLORS["Upper box background"] - 0x40000000) -- semi-transparent
		end
		Drawing.drawImageAsPixels(gSymbol, gX, gY, gColors, gShadow)
	end
end

function TrackerScreen.drawStatsArea(data)
	local borderColor = Theme.COLORS["Upper box border"]
	local bgColor = Theme.COLORS["Upper box background"]
	local shadowcolor = Utils.calcShadowColor(bgColor)
	local mainBoxWidth = 101
	local statOffsetX = Constants.SCREEN.WIDTH + mainBoxWidth + 1
	local statOffsetY = 7

	-- Draw the border box for the Stats area
	local x, y = Constants.SCREEN.WIDTH + mainBoxWidth, 5
	local w, h = Constants.SCREEN.RIGHT_GAP - mainBoxWidth - 5, 75
	gui.drawRectangle(x, y, w, h, borderColor, bgColor)
	if RouteData.Locations.CanPCHeal[TrackerAPI.getMapId()] then
		if data.x.extras.upperleft then gui.drawPixel(x + 1, y + 1, borderColor) end
		if data.x.extras.upperright then gui.drawPixel(x + w - 1, y + 1, borderColor) end
		if data.x.extras.lowerleft then gui.drawPixel(x + 1, y + h - 1, borderColor) end
		if data.x.extras.lowerright then gui.drawPixel(x + w - 1, y + h - 1, borderColor) end
	end

	-- Draw the six primary stats
	local statLabels = {
		["HP"] = Resources.TrackerScreen.StatHP,
		["ATK"] = Resources.TrackerScreen.StatATK,
		["DEF"] = Resources.TrackerScreen.StatDEF,
		["SPA"] = Resources.TrackerScreen.StatSPA,
		["SPD"] = Resources.TrackerScreen.StatSPD,
		["SPE"] = Resources.TrackerScreen.StatSPE,
	}
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		local textColor = Theme.COLORS["Default text"]
		local natureSymbol = ""

		if Battle.isViewingOwn then
			if statKey == data.p.positivestat then
				textColor = Theme.COLORS["Positive text"]
				natureSymbol = "+"
			elseif statKey == data.p.negativestat then
				textColor = Theme.COLORS["Negative text"]
				natureSymbol = Constants.BLANKLINE
			end
		end

		local langOffset = 0
		if Resources.currentLanguage == Resources.Languages.JAPANESE then
			langOffset = 3
		end

		-- Draw stat label and nature symbol next to it
		Drawing.drawText(statOffsetX, statOffsetY, statLabels[statKey:upper()], textColor, shadowcolor)
		Drawing.drawText(statOffsetX + 16 + langOffset, statOffsetY - 1, natureSymbol, textColor, nil, 5, Constants.Font.FAMILY)

		-- Draw stat battle increases/decreases, stages range from -6 to +6
		if Battle.inActiveBattle() then
			local statStageIntensity = data.p.stages[statKey] - 6 -- between [0 and 12], convert to [-6 and 6]
			Drawing.drawChevronsVerticalIntensity(statOffsetX + 20, statOffsetY + 4, statStageIntensity, 3,4,2,1,2)
		end

		-- Draw stat value, or the stat tracking box if enemy Pokemon
		if Battle.isViewingOwn then
			local statValueText = Utils.inlineIf(data.p[statKey] == 0, Constants.BLANKLINE, data.p[statKey])
			if not Options["Color stat numbers by nature"] then
				textColor = Theme.COLORS["Default text"]
			end
			Drawing.drawNumber(statOffsetX + 25, statOffsetY, statValueText, 3, textColor, shadowcolor)
		else
			if Options["Open Book Play Mode"] then
				local bstSpread = Utils.inlineIf(data.p[statKey] == 0, Constants.BLANKLINE, data.p[statKey])
				Drawing.drawNumber(statOffsetX + 25, statOffsetY, bstSpread, 3, Theme.COLORS["Intermediate text"], shadowcolor)
			else
				Drawing.drawButton(TrackerScreen.Buttons[statKey], shadowcolor)
			end
		end
		statOffsetY = statOffsetY + 10
	end

	-- Draw BST or ACC/EVA
	-- The "ACC" and "EVA" stats occupy the same space as the "BST". Prioritize showing ACC/EVA if either has changed during battle (6 is neutral)
	local useAccEvaInstead = Battle.inActiveBattle() and (data.p.stages.acc ~= 6 or data.p.stages.eva ~= 6)
	if useAccEvaInstead then
		Drawing.drawText(statOffsetX - 1, statOffsetY + 1, Resources.TrackerScreen.StatAccuracy, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawText(statOffsetX + 27, statOffsetY + 1, Resources.TrackerScreen.StatEvasion, Theme.COLORS["Default text"], shadowcolor)
		local accIntensity = data.p.stages.acc - 6
		local evaIntensity = data.p.stages.eva - 6
		Drawing.drawChevronsVerticalIntensity(statOffsetX + 15, statOffsetY + 5, accIntensity, 3,4,2,1,2)
		Drawing.drawChevronsVerticalIntensity(statOffsetX + 22, statOffsetY + 5, evaIntensity, 3,4,2,1,2)
	else
		Drawing.drawText(statOffsetX, statOffsetY, Resources.TrackerScreen.StatBST, Theme.COLORS["Default text"], shadowcolor)
		Drawing.drawNumber(statOffsetX + 25, statOffsetY, data.p.bst, 3, Theme.COLORS["Default text"], shadowcolor)
	end

	-- If controller is in use and highlighting any stats, draw that
	Drawing.drawInputOverlay()
end

function TrackerScreen.drawMovesArea(data)
	local headerColor = Theme.COLORS["Header text"]
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
	local allowHiddenMoveInfo = Battle.isViewingOwn or Options["Reveal info if randomized"] or not MoveData.IsRand.moveType

	-- Draw move headers
	gui.defaultTextBackground(Theme.COLORS["Main background"])
	local headerY = moveOffsetY - moveTableHeaderHeightDiff
	Drawing.drawText(Constants.SCREEN.WIDTH + moveNameOffset - 1, headerY, data.m.nextmoveheader, headerColor, bgHeaderShadow)
	-- Check if ball catch rate should be displayed instead of other header labels
	if TrackerScreen.Buttons.CatchRates:isVisible() then
		local catchText = string.format("~ %.0f%%  %s", data.x.catchrate, Resources.TrackerScreen.ToCatch)
		local rightOffset = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - Utils.calcWordPixelLength(catchText) - 2
		Drawing.drawText(Constants.SCREEN.WIDTH + rightOffset, headerY, catchText, headerColor, bgHeaderShadow)
	else
		Drawing.drawText(Constants.SCREEN.WIDTH + movePPOffset, headerY, Resources.TrackerScreen.HeaderPP, headerColor, bgHeaderShadow)
		Drawing.drawText(Constants.SCREEN.WIDTH + movePowerOffset, headerY, Resources.TrackerScreen.HeaderPow, headerColor, bgHeaderShadow)
		Drawing.drawText(Constants.SCREEN.WIDTH + moveAccOffset, headerY, Resources.TrackerScreen.HeaderAcc, headerColor, bgHeaderShadow)
	end

	-- Inidicate there are more moves being tracked than can fit on screen
	if not Battle.isViewingOwn and #Tracker.getMoves(data.p.id) > 4 then
		local movesAsterisk = 1 + Utils.calcWordPixelLength(Resources.TrackerScreen.HeaderMoves)
		Drawing.drawText(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + movesAsterisk, headerY, "*", Theme.COLORS[Theme.headerHighlightKey], bgHeaderShadow)
	end

	-- Redraw next move level in the header with a different color if close to learning new move
	if data.m.nextmovelevel ~= nil and data.m.nextmovespacing ~= nil and Battle.isViewingOwn and data.p.level + 1 >= data.m.nextmovelevel then
		local headerLevelHighlightX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + data.m.nextmovespacing
		Drawing.drawText(headerLevelHighlightX, headerY, data.m.nextmovelevel, Theme.COLORS[Theme.headerHighlightKey], bgHeaderShadow)
	end

	-- Draw the Moves view box
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, moveOffsetY - 2, Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN), 44, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

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

		if move.id == MoveData.Values.HiddenPowerId and Battle.isViewingOwn then
			moveTypeColor = Utils.inlineIf(move.type == PokemonData.Types.UNKNOWN, Theme.COLORS["Lower box text"], Constants.MoveTypeColors[move.type])
		elseif move.id == MoveData.Values.WeatherBallId and Options["Calculate variable damage"] then
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
	for _, content in pairs(carousel:getContentList(data.p.id)) do
		if content.type == Constants.ButtonTypes.IMAGE or content.type == Constants.ButtonTypes.PIXELIMAGE or content.type == Constants.ButtonTypes.FULL_BORDER then
			Drawing.drawButton(content, shadowcolor)
		elseif type(content) == "string" then
			local wrappedText = Utils.getWordWrapLines(content, 34)
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
	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y1 = Constants.SCREEN.MARGIN,
		y2 = Constants.SCREEN.MARGIN + 52,
		w = 96,
		h1 = 52,
		h2 = 23,
		text = Theme.COLORS["Default text"],
		highlight = Theme.COLORS["Intermediate text"],
		border = Theme.COLORS["Upper box border"],
		fill = Theme.COLORS["Upper box background"],
		shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"]),
	}

	-- Draw top box view
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y1, canvas.w, canvas.h1, canvas.border, canvas.fill)

	local ballsToDraw = { TrackerScreen.PokeBalls.Left, TrackerScreen.PokeBalls.Middle, TrackerScreen.PokeBalls.Right }
	for index, pokeball in ipairs(ballsToDraw) do
		local colorList = TrackerScreen.PokeBalls.ColorList
		if index == TrackerScreen.PokeBalls.chosenBall then
			Drawing.drawImageAsPixels(Constants.PixelImages.DOWN_ARROW, pokeball.x + 1, pokeball.y - 13, { canvas.text }, canvas.shadow)
		elseif TrackerScreen.PokeBalls.chosenBall ~= -1 then
			-- If not the chosen ball and not in the process of re-rolling
			colorList = TrackerScreen.PokeBalls.ColorListGray
		end
		Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, pokeball.x, pokeball.y, colorList, canvas.shadow)
	end

	-- SETTINGS GEAR & DICE BUTTONS
	Drawing.drawButton(TrackerScreen.Buttons.SettingsGear, canvas.shadow)
	Drawing.drawButton(TrackerScreen.Buttons.RerollBallPicker, canvas.shadow)

	local botText = TrackerScreen.PokeBalls.getLabel(TrackerScreen.PokeBalls.chosenBall)
	local topText, botColor
	if EventHandler.Queues.BallRedeems.HasPickedBall then
		local username = EventHandler.Queues.BallRedeems.ChosenUsername or ""
		local direction = EventHandler.Queues.BallRedeems.ChosenDirection or ""
		if not Utils.isNilOrEmpty(username) then
			topText = string.format("%s %s:", username, Resources.TrackerScreen.RandomBallUserPicks)
		else
			topText = string.format("%s:", Resources.TrackerScreen.RandomBallUserChosen)
		end

		local event = EventHandler.Events["CR_PickBallOnce"] or {}
		local wordForRandom = tostring(event["O_WordForRandom"] or "Random")
		if Utils.containsText(direction, wordForRandom, true) then
			botText = botText .. string.format(" (%s)", Resources.TrackerScreen.RandomBallRandom)
		end
		botColor = Theme.COLORS["Positive text"]
	else
		topText = string.format("%s:", Resources.TrackerScreen.RandomBallChosen)
		botColor = canvas.highlight
	end

	local topCenterX = math.max(Utils.getCenteredTextX(topText, canvas.w) - 1, 1) -- Minimum of 1
	local botCenterX = math.max(Utils.getCenteredTextX(botText, canvas.w) - 1, 1) -- Minimum of 1

	gui.drawRectangle(canvas.x, canvas.y2, canvas.w, canvas.h2, canvas.border, canvas.fill)
	Drawing.drawText(canvas.x + topCenterX, canvas.y2 + 1, topText, canvas.text, canvas.shadow)
	Drawing.drawText(canvas.x + botCenterX, canvas.y2 + Constants.SCREEN.LINESPACING, botText, botColor, canvas.shadow)
end

function TrackerScreen.drawFavorites()
	-- Draw header
	gui.defaultTextBackground(Theme.COLORS["Main background"])
	local headerX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local headerY = Constants.SCREEN.MARGIN + 76
	local bgShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(headerX, headerY, Resources.StartupScreen.HeaderFavorites, Theme.COLORS["Header text"], bgShadow)

	-- Draw lower box & favorites
	gui.defaultTextBackground(Theme.COLORS["Lower box background"])
	local boxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local boxY = 92
	local width = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local height = 44
	gui.drawRectangle(boxX, boxY, width, height, Theme.COLORS["Lower box border"], Theme.COLORS["Lower box background"])

	local favoritesButtons = {
		StartupScreen.Buttons.PokemonFavorite1,
		StartupScreen.Buttons.PokemonFavorite2,
		StartupScreen.Buttons.PokemonFavorite3,
	}
	-- Temporarily adjust the button's vertical location
	local shiftY = 8
	for _, button in ipairs(favoritesButtons) do
		local prevY = button.box[2]
		button.box[2] = button.box[2] + shiftY
		Drawing.drawButton(button)
		button.box[2] = prevY
	end
end

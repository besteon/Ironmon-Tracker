TrackerScreen = {}

TrackerScreen.Buttons = {
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
		text = "Click to leave a note",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 11, 11 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES end,
		onClick = function(self)
			if not self:isVisible() then return end
			TrackerScreen.openNotePadWindow()
		end
	},
	RouteInfo = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		text = "",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 8, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.ROUTE_INFO end,
		onClick = function(self)
			if not self:isVisible() then return end
			InfoScreen.infoLookup = Program.CurrentRoute.mapId
			InfoScreen.viewScreen = InfoScreen.Screens.ROUTE_INFO
			Program.changeScreenView(Program.Screens.INFO)
		end
	},
}

TrackerScreen.CarouselTypes = {
    BADGES = 1, -- Outside of battle
	NOTES = 2, -- During new game intro or inside of battle
	LAST_ATTACK = 3, -- During battle, only between turns
	ROUTE_INFO = 4, -- During battle, only if encounter is a wild pokemon
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
		isVisible = function() return not Tracker.Data.inBattle end,
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
		isVisible = function() return Tracker.Data.inBattle or Tracker.getPokemon(1, true) == nil end,
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
		isVisible = function() return Tracker.Data.inBattle and (not Program.BattleTurn.enemyIsAttacking) and Program.BattleTurn.lastMoveId ~= 0 end,
		framesToShow = 180,
		getContentList = function()
			-- TODO: Currently this only records last move used for damaging moves
			if Program.BattleTurn.lastMoveId > 0 and Program.BattleTurn.lastMoveId <= #MoveData.Moves then
				local moveInfo = MoveData.Moves[Program.BattleTurn.lastMoveId]
				if Program.BattleTurn.damageReceived > 0 then
					return { moveInfo.name .. ": " .. Program.BattleTurn.damageReceived .. " damage" }
				else
					return { "Last move: " .. moveInfo.name }
				end
			else
				return { "Waiting for a new move to be used." }
			end
		end,
	}

	-- ROUTE INFO
	-- TODO: If against wild pokemon, reveal route table; otherwise show total # trainers in route
	TrackerScreen.CarouselItems[TrackerScreen.CarouselTypes.ROUTE_INFO] = {
		type = TrackerScreen.CarouselTypes.ROUTE_INFO,
		isVisible = function() return Tracker.Data.inBattle and Program.CurrentRoute.hasInfo end,
		framesToShow = 210,
		getContentList = function(pokemon)
			local routeInfo = GameSettings.RouteInfo[Program.CurrentRoute.mapId]
			local seenEncounters = Tracker.getEncounters(pokemon.pokemonID, Program.CurrentRoute.mapId, true)
			local totalPossible = #routeInfo[Constants.EncounterTypes.GRASS]
			TrackerScreen.Buttons.RouteInfo.text = "Seen " .. seenEncounters .. "/" .. totalPossible .. " unique Pokemon"

			return { TrackerScreen.Buttons.RouteInfo } 
		end,
	}

	-- Easter Egg for the "-69th" seed
	local romnumber = string.match(gameinfo.getromname(), '[0-9]+')
	if romnumber ~= nil and romnumber ~= "" and romnumber:sub(-2) == "69" then
		table.insert(Constants.OrderedLists.TIPS, "This seed ends in 69. Nice.")
	end
end

-- Returns the current visible carousel. If unavailable, looks up the next visible carousel
function TrackerScreen.getCurrentCarouselItem()
	local carousel = TrackerScreen.CarouselItems[TrackerScreen.carouselIndex]

	-- Check if the current carousel's time has expired, or if it shouldn't be shown
	if carousel == nil or not carousel.isVisible() or Program.Frames.carouselActive > carousel.framesToShow then
		local nextCarousel = TrackerScreen.getNextVisibleCarouselItem(TrackerScreen.carouselIndex)
		TrackerScreen.carouselIndex = nextCarousel.type
		Program.Frames.carouselActive = 0

		-- When carousel switches to the Notes display, prepare the next tip message to display
		if nextCarousel ~= carousel and TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES then
			local numTips = #Constants.OrderedLists.TIPS
			if TrackerScreen.tipMessageIndex == numTips then
				TrackerScreen.tipMessageIndex = 2 -- Skip "helpful tip" message if that's next up
			else
				TrackerScreen.tipMessageIndex = (TrackerScreen.tipMessageIndex % #Constants.OrderedLists.TIPS) + 1
			end
		end

		return nextCarousel
	end

	return carousel
end

function TrackerScreen.getNextVisibleCarouselItem(startIndex)
	local nextIndex = (startIndex % #TrackerScreen.CarouselItems) + 1
	local carousel = TrackerScreen.CarouselItems[nextIndex]

	while (nextIndex ~= startIndex and not carousel.isVisible()) do
		nextIndex = (nextIndex % #TrackerScreen.CarouselItems) + 1
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

	forms.destroyall()
	client.pause()

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
			local abilityOneId = 0
			local abilityTwoId = 0

			-- If only one ability was entered in
			if abilityOneText == Constants.BLANKLINE then
				abilityOneText = abilityTwoText
				abilityTwoText = Constants.BLANKLINE
			end

			-- TODO: Eventually put all this code in as a Tracker function()
			-- Lookup ability id's from the master list of ability pokemon data
			for id, abilityName in pairs(MiscData.Abilities) do
				if abilityOneText == abilityName then
					abilityOneId = id
				elseif abilityTwoText == abilityName then
					abilityTwoId = id
				end
			end

			local trackedPokemon = Tracker.Data.allPokemon[pokemonViewed.pokemonID]
			trackedPokemon.abilities = {
				{ id = abilityOneId },
				{ id = abilityTwoId },
			}
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
	local pokemon = Tracker.getPokemon(Utils.inlineIf(Tracker.Data.isViewingOwn, Tracker.Data.ownViewSlot, Tracker.Data.otherViewSlot), Tracker.Data.isViewingOwn)
	if pokemon == nil then return end

	forms.destroyall()
	client.pause()

	local noteForm = forms.newform(465, 125, "Leave a Note", function() client.unpause() end)
	Utils.setFormLocation(noteForm, 100, 50)
	forms.label(noteForm, "Enter a note for " .. PokemonData.Pokemon[pokemon.pokemonID].name .. " (70 char. max):", 9, 10, 300, 20)
	local noteTextBox = forms.textbox(noteForm, Tracker.getNote(pokemon.pokemonID), 430, 20, nil, 10, 30)

	forms.button(noteForm, "Save", function()
		local formInput = forms.gettext(noteTextBox)
		local pokemonViewed = Tracker.getPokemon(Utils.inlineIf(Tracker.Data.isViewingOwn, Tracker.Data.ownViewSlot, Tracker.Data.otherViewSlot), Tracker.Data.isViewingOwn)
		if formInput ~= nil and pokemonViewed ~= nil then
			Tracker.TrackNote(pokemonViewed.pokemonID, formInput)
			Program.redraw(true)
		end
		forms.destroy(noteForm)
		client.unpause()
	end, 187, 55)
end
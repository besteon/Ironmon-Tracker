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
		text = "",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + 37, 35, 63, 22 },
		box = { Constants.SCREEN.WIDTH + 88, 43, 16, 16 },
		isVisible = function() return not Tracker.Data.isViewingOwn end,
		onClick = function(self)
			if not self:isVisible() then return end
			TrackerScreen.openAbilityNoteWindow()
		end
	},
	NotepadTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		text = "",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 141, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 141, 16, 16 },
		isVisible = function() return not Tracker.Data.isViewingOwn end,
		onClick = function(self)
			if not self:isVisible() then return end
			TrackerScreen.openNotePadWindow()
		end
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
			isVisible = function() return Tracker.Data.isViewingOwn end,
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
	local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
	if pokemon == nil then return end

	forms.destroyall()
	client.pause()

	local noteForm = forms.newform(465, 125, "Leave a Note", function() client.unpause() end)
	Utils.setFormLocation(noteForm, 100, 50)
	forms.label(noteForm, "Enter a note for " .. PokemonData.Pokemon[pokemon.pokemonID].name .. " (70 char. max):", 9, 10, 300, 20)
	local noteTextBox = forms.textbox(noteForm, Tracker.getNote(pokemon.pokemonID), 430, 20, nil, 10, 30)

	forms.button(noteForm, "Save", function()
		local formInput = forms.gettext(noteTextBox)
		local pokemonViewed = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
		if formInput ~= nil and pokemonViewed ~= nil then
			Tracker.TrackNote(pokemonViewed.pokemonID, formInput)
			Program.redraw(true)
		end
		forms.destroy(noteForm)
		client.unpause()
	end, 187, 55)
end
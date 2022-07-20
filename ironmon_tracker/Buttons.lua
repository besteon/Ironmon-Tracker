-- Button attributes:
-- type : button Type
-- isVisible() : when the button is visible / active on screen

ButtonType = {
	singleButton = 0,
	-- text : button text
	-- box : total size of the button
	-- backgroundcolor : {1,2} background color
	-- textcolor : text color
	-- onclick : function triggered when the button is clicked.

	badgeButton = 0,
	--visible : condition on when button should be visible
	--box : defines button dimensions
	--state : on or off
	--onclick : function triggered when badge button is clicked
}

StatButtonStates = {
	"",
	"--",
	"+"
}

StatButtonColors = {
	"Default text",
	"Negative text",
	"Positive text"
}

BadgeButtons = {
	BADGE_GAME_PREFIX = "",
	badgeButtons = {},
	xOffsets = {0, 0, 0, 0, 0, 0, 0, 0},
}

local buttonXOffset = 129

local HiddenPowerState = 0

HiddenPowerButton = {
	type = ButtonType.singleButton,
	text = "Hidden Power",
	textcolor = Constants.COLORS.MOVETYPE[MoveData.HiddenPowerTypeList[HiddenPowerState + 1]],
	box = { Constants.SCREEN.WIDTH + 111, 8, 31, 13 },
	isVisible = function() return Tracker.Data.isViewingOwn and Tracker.Data.hasCheckedSummary and Utils.pokemonHasMove(Tracker.getPokemon(Tracker.Data.ownViewSlot, true), "Hidden Power") end,
	onclick = function(self)
		HiddenPowerState = (HiddenPowerState + 1) % #MoveData.HiddenPowerTypeList
		local newType = MoveData.HiddenPowerTypeList[HiddenPowerState + 1]
		HiddenPowerButton.textcolor = Constants.COLORS.MOVETYPE[newType]
		Tracker.Data.currentHiddenPowerType = newType
		InfoScreen.redraw = true
	end
}

PCHealTrackingButton = {
	type = ButtonType.singleButton,
	text = "",
	textcolor = "Default text",
	box = { Constants.SCREEN.WIDTH + 89, 68, 8, 8 },
	boxColors = { "Upper box border", "Upper box background" },
	togglecolor = "Positive text",
	isVisible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
	onclick = function(self) 
		Program.PCHealTrackingButtonState = not Program.PCHealTrackingButtonState
	end
}

AbilityTrackingButton = {
	type = ButtonType.singleButton,
	text = "",
	textcolor = "Default text",
	box = { Constants.SCREEN.WIDTH + 88, 43, 16, 16 },
	onclick = function() 
		Buttons.openAbilityNoteWindow()
	end
}

NotepadTrackingButton = {
	type = ButtonType.singleButton,
	text = "",
	textcolor = "Default text",
	box = { Constants.SCREEN.WIDTH + 6, 141, 16, 16 },
	onclick = function() 
		Buttons.openNotePadWindow()
	end
}

Buttons = {
	{ -- HP button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { Constants.SCREEN.WIDTH + buttonXOffset, 9, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		onclick = function()
			Program.StatButtonState.hp = ((Program.StatButtonState.hp + 1) % 3) + 1
			Buttons[1].text = StatButtonStates[Program.StatButtonState.hp]
			Buttons[1].textcolor = StatButtonColors[Program.StatButtonState.hp]
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
			end
		end
	},
	{ -- ATK button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { Constants.SCREEN.WIDTH + buttonXOffset, 19, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		onclick = function()
			Program.StatButtonState.atk = ((Program.StatButtonState.atk + 1) % 3) + 1
			Buttons[2].text = StatButtonStates[Program.StatButtonState.atk]
			Buttons[2].textcolor = StatButtonColors[Program.StatButtonState.atk]
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
			end
		end
	},
	{ -- DEF button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { Constants.SCREEN.WIDTH + buttonXOffset, 29, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		onclick = function()
			Program.StatButtonState.def = ((Program.StatButtonState.def + 1) % 3) + 1
			Buttons[3].text = StatButtonStates[Program.StatButtonState.def]
			Buttons[3].textcolor = StatButtonColors[Program.StatButtonState.def]
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
			end
		end
	},
	{ -- SPA button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { Constants.SCREEN.WIDTH + buttonXOffset, 39, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		onclick = function()
			Program.StatButtonState.spa = ((Program.StatButtonState.spa + 1) % 3) + 1
			Buttons[4].text = StatButtonStates[Program.StatButtonState.spa]
			Buttons[4].textcolor = StatButtonColors[Program.StatButtonState.spa]
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
			end
		end
	},
	{ -- SPD button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { Constants.SCREEN.WIDTH + buttonXOffset, 49, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		onclick = function()
			Program.StatButtonState.spd = ((Program.StatButtonState.spd + 1) % 3) + 1
			Buttons[5].text = StatButtonStates[Program.StatButtonState.spd]
			Buttons[5].textcolor = StatButtonColors[Program.StatButtonState.spd]
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
			end
		end
	},
	{ -- SPE button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { Constants.SCREEN.WIDTH + buttonXOffset, 59, 8, 8 },
		boxColors = { "Upper box border", "Upper box background" },
		onclick = function()
			Program.StatButtonState.spe = ((Program.StatButtonState.spe + 1) % 3) + 1
			Buttons[6].text = StatButtonStates[Program.StatButtonState.spe]
			Buttons[6].textcolor = StatButtonColors[Program.StatButtonState.spe]
			local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
			if pokemon ~= nil then
				Tracker.TrackStatMarkings(pokemon.pokemonID, Program.StatButtonState)
			end
		end
	},
	HiddenPowerButton,
	PCHealTrackingButton,
	{ -- PC Heal Increment Button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		text = "+",
		textcolor = "Positive text",
		box = { Constants.SCREEN.WIDTH + 70, 67, 8, 4 },
		onclick = function() 
			Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
			-- Prevent triple digit values (shouldn't go anywhere near this in survival)
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
		end
	},
	{ -- PC Heal Decrement Button
		type = ButtonType.singleButton,
		isVisible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		text = Constants.BLANKLINE,
		textcolor = "Negative text",
		box = { Constants.SCREEN.WIDTH + 70, 73, 7, 4 },
		onclick = function() 
			Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
			-- Prevent negative values
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
		end
	}
}

function Buttons.initializeBadgeButtons()
	BadgeButtons.badgeButtons = {}
	for i = 1,8,1 do
		local badgeButton = {
			type = ButtonType.badgeButton,
			isVisible = function() return Tracker.Data.isViewingOwn end,
			box = {
				Constants.SCREEN.BADGE_X_POS + ((i-1) * (Constants.SCREEN.BADGE_WIDTH + 1)) + BadgeButtons.xOffsets[i],
				Constants.SCREEN.BADGE_Y_POS,
				Constants.SCREEN.BADGE_WIDTH,
				Constants.SCREEN.BADGE_WIDTH
			},
			badgeIndex = i,
			state = Tracker.Data.badges[i],
			onclick = function(self)
				-- When badge is clicked, toggle it on/off
				Tracker.Data.badges[self.badgeIndex] = (Tracker.Data.badges[self.badgeIndex] + 1) % 2
				self:updateState()
			end,
			updateState = function(self)
				self.state = Tracker.Data.badges[self.badgeIndex]
			end
		}
		table.insert(BadgeButtons.badgeButtons,badgeButton)
	end
end

-- Updates the states of the buttons to match those in the Tracker
function Buttons.updateBadges()
	for i, button in pairs(BadgeButtons.badgeButtons) do
		button:updateState()
	end
end

function Buttons.openAbilityNoteWindow()
	local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
	if pokemon == nil then return end

	local abilityList = {}
	table.insert(abilityList, Constants.BLANKLINE)
	for _, abilityName in pairs(MiscData.Abilities) do
		table.insert(abilityList, abilityName)
	end

	local trackedAbilities = Tracker.getAbilities(pokemon.pokemonID)

	local abilityForm = forms.newform(360, 170, "Track Ability", function() return nil end)
	Utils.setFormLocation(abilityForm, 100, 50)
	
	forms.label(abilityForm, "Select one or both abilities for " .. PokemonData.Pokemon[pokemon.pokemonID].name .. ":", 64, 10, 220, 20)
	local abilityOneDropdown = forms.dropdown(abilityForm, {["Init"]="Loading Ability1"}, 95, 30, 145, 30)
	forms.setdropdownitems(abilityOneDropdown, abilityList, true) -- true = alphabetize list
	local abilityTwoDropdown = forms.dropdown(abilityForm, {["Init"]="Loading Ability2"}, 95, 60, 145, 30)
	forms.setdropdownitems(abilityTwoDropdown, abilityList, true) -- true = alphabetize list

	if trackedAbilities[1].id ~= 0 then
		forms.settext(abilityOneDropdown, MiscData.Abilities[trackedAbilities[1].id])
	end
	if trackedAbilities[2].id ~= 0 then
		forms.settext(abilityTwoDropdown, MiscData.Abilities[trackedAbilities[2].id])
	end

	forms.button(abilityForm, "Save && Close", function()
		local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
		if pokemon ~= nil then
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

			local trackedPokemon = Tracker.Data.allPokemon[pokemon.pokemonID]
			trackedPokemon.abilities = {
				{ id = abilityOneId },
				{ id = abilityTwoId },
			}
		end

		client.unpause()
		Program.frames.waitToDraw = 0
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

function Buttons.openNotePadWindow()
	local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
	if pokemon == nil then return end

	local noteForm = forms.newform(465, 125, "Leave a Note", function() return end)
	Utils.setFormLocation(noteForm, 100, 50)
	forms.label(noteForm, "Enter a note for " .. PokemonData.Pokemon[pokemon.pokemonID].name .. " (70 char. max):", 9, 10, 300, 20)
	local noteTextBox = forms.textbox(noteForm, Tracker.getNote(pokemon.pokemonID), 430, 20, nil, 10, 30)
	
	local saveButton = forms.button(noteForm, "Save", function()
		local formInput = forms.gettext(noteTextBox)
		local pokemon = Tracker.getPokemon(Tracker.Data.otherViewSlot, false)
		if formInput ~= nil and pokemon ~= nil then
			Tracker.TrackNote(pokemon.pokemonID, formInput)
			Program.frames.waitToDraw = 0
		end
		forms.destroy(noteForm)
		client.unpause()
	end, 187, 55)
end
-- Button attributes:
-- type : button Type
-- visible() : when the button is visible / active on screen

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
	BADGE_X_POS_START = 247,
	BADGE_Y_POS = 138,
	BADGE_WIDTH_LENGTH = 16,
	badgeButtons = {},
	xOffsets = {0, 0, 0, 0, 0, 0, 0, 0},
}

BadgeButtons = {
	BADGE_GAME_PREFIX = "",
	BADGE_X_POS_START = 247,
	BADGE_Y_POS = 139,
	BADGE_WIDTH_LENGTH = 16,
	badgeButtons = {}
}

local buttonXOffset = 129

local HiddenPowerState = 0

HiddenPowerButton = {
	type = ButtonType.singleButton,
	visible = function() return Tracker.Data.isViewingOwn and Tracker.Data.hasCheckedSummary and Utils.pokemonHasMove(Tracker.getPokemon(Tracker.Data.ownViewSlot, true), "Hidden Power") end,
	text = "Hidden Power",
	textcolor = GraphicConstants.TYPECOLORS[HiddenPowerTypeList[HiddenPowerState+1]],
	box = { 0, 0, 65, 10 },
	onclick = function()
		HiddenPowerState = (HiddenPowerState + 1) % #HiddenPowerTypeList
		local newType = HiddenPowerTypeList[HiddenPowerState + 1]
		HiddenPowerButton.textcolor = GraphicConstants.TYPECOLORS[newType]
		Tracker.Data.currentHiddenPowerType = newType
	end
}

PCHealTrackingButton = {
	type = ButtonType.singleButton,
	visible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
	text = "",
	textcolor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 89, 68, 8, 8 },
	boxColors = { "Upper box border", "Upper box background" },
	togglecolor = "Positive text",
	onclick = function() 
		Program.PCHealTrackingButtonState = not Program.PCHealTrackingButtonState 
	end
}

Buttons = {
	{ -- HP button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { GraphicConstants.SCREEN_WIDTH + buttonXOffset, 9, 8, 8 },
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
		visible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { GraphicConstants.SCREEN_WIDTH + buttonXOffset, 19, 8, 8 },
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
		visible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { GraphicConstants.SCREEN_WIDTH + buttonXOffset, 29, 8, 8 },
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
		visible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { GraphicConstants.SCREEN_WIDTH + buttonXOffset, 39, 8, 8 },
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
		visible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { GraphicConstants.SCREEN_WIDTH + buttonXOffset, 49, 8, 8 },
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
		visible = function() return Tracker.Data.inBattle and not Tracker.Data.isViewingOwn end,
		text = "",
		textcolor = "Default text",
		box = { GraphicConstants.SCREEN_WIDTH + buttonXOffset, 59, 8, 8 },
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
		visible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		text = "+",
		textcolor = "Positive text",
		box = { GraphicConstants.SCREEN_WIDTH + 70, 67, 8, 4 },
		onclick = function() 
			Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
			-- Prevent triple digit values (shouldn't go anywhere near this in survival)
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
		end
	},
	{ -- PC Heal Decrement Button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.isViewingOwn and Options["Track PC Heals"] end,
		text = "---",
		textcolor = "Negative text",
		box = { GraphicConstants.SCREEN_WIDTH + 70, 73, 7, 4 },
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
			visible = function() return Tracker.Data.isViewingOwn end,
			box = {
				BadgeButtons.BADGE_X_POS_START + ((i-1) * (BadgeButtons.BADGE_WIDTH_LENGTH + 1)) + BadgeButtons.xOffsets[i],
				BadgeButtons.BADGE_Y_POS,
				BadgeButtons.BADGE_WIDTH_LENGTH,
				BadgeButtons.BADGE_WIDTH_LENGTH
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

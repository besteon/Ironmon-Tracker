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
}

StatButtonStates = {
	"",
	"--",
	"+"
}

StatButtonColors = {
	GraphicConstants.LAYOUTCOLORS.NEUTRAL,
	GraphicConstants.LAYOUTCOLORS.DECREASE,
	GraphicConstants.LAYOUTCOLORS.INCREASE
}

local buttonXOffset = 129

local HiddenPowerState = 0

HiddenPowerButton = {
	type = ButtonType.singleButton,
	visible = function() return Tracker.Data.selectedPlayer == 1 and Utils.playerHasMove("Hidden Power") end,
	text = "Hidden Power",
	box = {
		0,
		0,
		65,
		10
	},
	textcolor = GraphicConstants.TYPECOLORS[HiddenPowerTypeList[HiddenPowerState+1]],
	onclick = function()
		HiddenPowerState = (HiddenPowerState + 1) % #HiddenPowerTypeList
		local newType = HiddenPowerTypeList[HiddenPowerState + 1]
		HiddenPowerButton.textcolor = GraphicConstants.TYPECOLORS[newType]
		Tracker.Data.currentHiddenPowerType = newType
	end
}

PCHealTrackingButton = {
	type = ButtonType.singleButton,
	visible = function() return Tracker.Data.selectedPlayer == 1 and Settings.tracker.SURVIVAL_RULESET end,
	text = "",
	box = {
		GraphicConstants.SCREEN_WIDTH + 89,
		68,
		8,
		8
	},
	backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
	textcolor = 0xFF00AAFF,
	togglecolor = GraphicConstants.LAYOUTCOLORS.INCREASE,
	onclick = function() 
		Program.PCHealTrackingButtonState = not Program.PCHealTrackingButtonState 
	end
}

Buttons = {
	{ -- HP button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle == 1 and Tracker.Data.selectedPlayer == 2 end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + buttonXOffset,
			9,
			8,
			8
		},
		backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
		textcolor = 0xFF00AAFF,
		onclick = function()
			Program.StatButtonState.hp = ((Program.StatButtonState.hp + 1) % 3) + 1
			Buttons[1].text = StatButtonStates[Program.StatButtonState.hp]
			Buttons[1].textcolor = StatButtonColors[Program.StatButtonState.hp]
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	},
	{ -- ATT button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle == 1 and Tracker.Data.selectedPlayer == 2 end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + buttonXOffset,
			19,
			8,
			8
		},
		backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
		textcolor = 0xFF00AAFF,
		onclick = function()
			Program.StatButtonState.att = ((Program.StatButtonState.att + 1) % 3) + 1
			Buttons[2].text = StatButtonStates[Program.StatButtonState.att]
			Buttons[2].textcolor = StatButtonColors[Program.StatButtonState.att]
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	},
	{ -- DEF button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle == 1 and Tracker.Data.selectedPlayer == 2 end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + buttonXOffset,
			29,
			8,
			8
		},
		backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
		textcolor = 0xFF00AAFF,
		onclick = function()
			Program.StatButtonState.def = ((Program.StatButtonState.def + 1) % 3) + 1
			Buttons[3].text = StatButtonStates[Program.StatButtonState.def]
			Buttons[3].textcolor = StatButtonColors[Program.StatButtonState.def]
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	},
	{ -- SPA button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle == 1 and Tracker.Data.selectedPlayer == 2 end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + buttonXOffset,
			39,
			8,
			8
		},
		backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
		textcolor = 0xFF00AAFF,
		onclick = function()
			Program.StatButtonState.spa = ((Program.StatButtonState.spa + 1) % 3) + 1
			Buttons[4].text = StatButtonStates[Program.StatButtonState.spa]
			Buttons[4].textcolor = StatButtonColors[Program.StatButtonState.spa]
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	},
	{ -- SPD button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle == 1 and Tracker.Data.selectedPlayer == 2 end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + buttonXOffset,
			49,
			8,
			8
		},
		backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
		textcolor = 0xFF00AAFF,
		onclick = function()
			Program.StatButtonState.spd = ((Program.StatButtonState.spd + 1) % 3) + 1
			Buttons[5].text = StatButtonStates[Program.StatButtonState.spd]
			Buttons[5].textcolor = StatButtonColors[Program.StatButtonState.spd]
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	},
	{ -- SPE button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.inBattle == 1 and Tracker.Data.selectedPlayer == 2 end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + buttonXOffset,
			59,
			8,
			8
		},
		backgroundcolor = { GraphicConstants.LAYOUTCOLORS.BOXBORDER, GraphicConstants.LAYOUTCOLORS.BOXFILL },
		textcolor = 0xFF00AAFF,
		onclick = function()
			Program.StatButtonState.spe = ((Program.StatButtonState.spe + 1) % 3) + 1
			Buttons[6].text = StatButtonStates[Program.StatButtonState.spe]
			Buttons[6].textcolor = StatButtonColors[Program.StatButtonState.spe]
			Tracker.TrackStatPrediction(Tracker.Data.selectedPokemon.pokemonID, Program.StatButtonState)
		end
	},
	HiddenPowerButton,
	PCHealTrackingButton,
	{ -- PC Heal Increment Button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.selectedPlayer == 1 and Settings.tracker.SURVIVAL_RULESET end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + 67,
			67,
			6,
			4
		},
		drawChevron = function(x, y, w, h, t) 
			Drawing.drawChevronUp(x, y - 1, w, h, t, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		end,
		onclick = function() 
			Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
		end
	},
	{ -- PC Heal Decrement Button
		type = ButtonType.singleButton,
		visible = function() return Tracker.Data.selectedPlayer == 1 and Settings.tracker.SURVIVAL_RULESET end,
		text = "",
		box = {
			GraphicConstants.SCREEN_WIDTH + 67,
			73,
			6,
			4
		},
		drawChevron = function(x, y, w, h, t) 
			return Drawing.drawChevronDown(x, y - 3, w, h, t, GraphicConstants.LAYOUTCOLORS.NEUTRAL)
		end,
		onclick = function() 
			Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
		end
	}
}

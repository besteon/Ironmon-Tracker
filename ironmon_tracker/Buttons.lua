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
	}
}

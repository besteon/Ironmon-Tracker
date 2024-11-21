NotebookPokemonNoteView = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Upper box border",
		boxFill = "Upper box background",
		header = "Header text",
		bottomText = "Lower box text",
		bottomBorder = "Lower box border",
		bottomFill = "Lower box background",
	},
	Data = {},
}
local SCREEN = NotebookPokemonNoteView
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
}

SCREEN.Buttons = {
	-- UPPER LEFT BOX
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconId = function(self) return SCREEN.Data.pokemonID or 0 end,
		clickableArea = { CANVAS.X, CANVAS.Y, 32, 27 },
		box = { CANVAS.X, CANVAS.Y - 6, 32, 32 },
		location = "top",
		isVisible = function(self) return SCREEN.Data.isReady end,
		onClick = function(self)
			if not PokemonData.isValid(SCREEN.Data.pokemonID) then return end
			InfoScreen.previousScreenFinal = SCREEN
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, SCREEN.Data.pokemonID)
		end,
	},
	Type1 = {
		type = Constants.ButtonTypes.IMAGE,
		box = { CANVAS.X + 1, CANVAS.Y + 28, 30, 12 },
		location = "top",
		isVisible = function(self) return SCREEN.Data.isReady and not Utils.isNilOrEmpty(self.image) end,
		onClick = function (self)
			TypeDefensesScreen.previousScreen = SCREEN
			TypeDefensesScreen.buildOutPagedButtons(SCREEN.Data.pokemonID)
			Program.changeScreenView(TypeDefensesScreen)
		end,
	},
	Type2 = {
		type = Constants.ButtonTypes.IMAGE,
		box = { CANVAS.X + 1, CANVAS.Y + 40, 30, 12 },
		location = "top",
		isVisible = function(self) return SCREEN.Data.isReady and not Utils.isNilOrEmpty(self.image) end,
		onClick = function (self) SCREEN.Buttons.Type1:onClick() end,
	},
	PokemonName = {
		type = Constants.ButtonTypes.NO_BORDER,
		getCustomText = function(self) return SCREEN.Data.pokemonName or Constants.BLANKLINE end,
		box = { CANVAS.X + 30, CANVAS.Y + 1, 63, Constants.SCREEN.LINESPACING },
		location = "top",
		isVisible = function() return SCREEN.Data.isReady end,
		onClick = function (self) SCREEN.Buttons.PokemonIcon:onClick() end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
			Drawing.drawTransparentTextbox(x + 1, y + 1, self:getCustomText(), textColor, bgColor, shadowcolor)
		end,
	},
	LastSeenLv = {
		type = Constants.ButtonTypes.NO_BORDER,
		getCustomText = function(self)
			if SCREEN.Data.lastLevel > 0 then
				return string.format("%s %s.%s", Resources.TrackerScreen.BattleLastSeen, Resources.TrackerScreen.LevelAbbreviation, SCREEN.Data.lastLevel)
			else
				return ""
			end
		end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 30, CANVAS.Y + 20, 63, Constants.SCREEN.LINESPACING },
		location = "top",
		isVisible = function() return SCREEN.Data.isReady end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
			Drawing.drawTransparentTextbox(x + 1, y + 1, self:getCustomText(), textColor, bgColor, shadowcolor)
		end,
	},
	AbilityLine1 = {
		type = Constants.ButtonTypes.NO_BORDER,
		getCustomText = function(self) return SCREEN.Data.abilityName1 or Constants.BLANKLINE end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 30, CANVAS.Y + 30, 63, Constants.SCREEN.LINESPACING },
		location = "top",
		isVisible = function() return SCREEN.Data.isReady end,
		onClick = function(self)
			if AbilityData.isValid(SCREEN.Data.abilityId1) then
				InfoScreen.previousScreenFinal = SCREEN
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, SCREEN.Data.abilityId1)
			else
				TrackerScreen.openNotePadWindow(SCREEN.Data.pokemonID, SCREEN.rebuildData)
			end
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
			Drawing.drawTransparentTextbox(x + 1, y + 1, self:getCustomText(), textColor, bgColor, shadowcolor)
		end,
	},
	AbilityLine2 = {
		type = Constants.ButtonTypes.NO_BORDER,
		getCustomText = function(self) return SCREEN.Data.abilityName2 or Constants.BLANKLINE end,
		textColor = SCREEN.Colors.highlight,
		box = { CANVAS.X + 30, CANVAS.Y + 40, 63, Constants.SCREEN.LINESPACING },
		location = "top",
		isVisible = function() return SCREEN.Data.isReady end,
		onClick = function(self)
			if AbilityData.isValid(SCREEN.Data.abilityId2) then
				InfoScreen.previousScreenFinal = SCREEN
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, SCREEN.Data.abilityId2)
			else
				TrackerScreen.openNotePadWindow(SCREEN.Data.pokemonID, SCREEN.rebuildData)
			end
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
			Drawing.drawTransparentTextbox(x + 1, y + 1, self:getCustomText(), textColor, bgColor, shadowcolor)
		end,
	},
	SeenTrainersWilds = {
		type = Constants.ButtonTypes.NO_BORDER,
		box = { CANVAS.X + 1, CANVAS.Y + 52, 95, 22 },
		location = "top",
		isVisible = function() return SCREEN.Data.isReady end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Colors.text]
			local textTrainer = string.format("%s: %s",
				Resources.TrackerScreen.BattleSeenOnTrainers,
				SCREEN.Data.seenOnTrainers or Constants.BLANKLINE)
			local textWild = string.format("%s: %s",
				Resources.TrackerScreen.BattleSeenInTheWild,
				SCREEN.Data.seenInWild or Constants.BLANKLINE)
			Drawing.drawText(x, y, textTrainer, textColor, shadowcolor)
			Drawing.drawText(x, y + Constants.SCREEN.LINESPACING, textWild, textColor, shadowcolor)
		end,
	},

	-- STATS BOX
	-- Other stat boxes created during buildScreen()
	StatBST = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			if Options["Open Book Play Mode"] then
				local pokemon = PokemonData.Pokemon[SCREEN.Data.pokemonID] or {}
				return pokemon.bstCalculated or Constants.BLANKLINE
			else
				return SCREEN.Data.bst
			end
		end,
		box = { CANVAS.X + 121, CANVAS.Y + 62, 20, 10 },
		location = "top",
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			if Options["Open Book Play Mode"] then
				self.textColor = SCREEN.Colors.highlight
			else
				self.textColor = SCREEN.Colors.text
			end
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[SCREEN.Colors.text]
			Drawing.drawNumber(x - 23, y, Resources.TrackerScreen.StatBST, 3, textColor, shadowcolor)
		end,
	},

	-- MOVES BOX
	MovesLabel = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self)
			return string.format("%s (%s/%s)", Resources.NotebookPokemonNoteView.HeaderMoveHistory, SCREEN.Data.movesSeen, SCREEN.Data.movesTotal)
		end,
		textColor = SCREEN.Colors.header,
		location = "header",
		box = { CANVAS.X, CANVAS.Y + 76, CANVAS.W, 11 },
		isVisible = function() return SCREEN.Data.isReady end,
		onClick = function(self)
			MoveHistoryScreen.previousScreen = SCREEN
			MoveHistoryScreen.buildOutHistory(SCREEN.Data.pokemonID)
			Program.changeScreenView(MoveHistoryScreen)
		end,
	},
	-- NOTES BOX
	Note = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		getText = function(self)
			if not Utils.isNilOrEmpty(SCREEN.Data.note) then
				return SCREEN.Data.note
			else
				return string.format("(%s)", Resources.TrackerScreen.LeaveANote)
			end
		end,
		textColor = SCREEN.Colors.bottomText,
		clickableArea = { CANVAS.X + 4, CANVAS.Y + 135, CANVAS.W - 30, 11 },
		box = { CANVAS.X + 4, CANVAS.Y + 135, 11, 11 },
		location = "bottom",
		isVisible = function() return SCREEN.Data.isReady end,
		onClick = function(self)
			TrackerScreen.openNotePadWindow(SCREEN.Data.pokemonID, SCREEN.rebuildData)
		end,
	},

	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or NotebookPokemonSeen)
		SCREEN.previousScreen = nil
	end, SCREEN.Colors.bottomText),
}

function NotebookPokemonNoteView.initialize()
	SCREEN.Buttons.Back.location = "bottom"

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	SCREEN.clearBuiltData()
	SCREEN.refreshButtons()
end

---Retrieves and builds the data needed to draw this screen; stored in `NotebookPokemonNoteView.Data`
---@param pokemonID number
---@return boolean success
function NotebookPokemonNoteView.buildScreen(pokemonID)
	if not PokemonData.isValid(pokemonID) then
		return false
	end

	SCREEN.clearBuiltData()
	SCREEN.Data.pokemonID = pokemonID

	local pokemonInternal = PokemonData.Pokemon[pokemonID]
	local trackedPokemon = Tracker.Data.allPokemon[pokemonID] or {}

	SCREEN.Data.pokemonName = pokemonInternal.name
	SCREEN.Data.bst = pokemonInternal.bst

	-- POKEMON TYPES
	if not Options["Reveal info if randomized"] and PokemonData.IsRand.types then
		SCREEN.Buttons.Type1.image = Drawing.getImagePath("PokemonType", PokemonData.Types.UNKNOWN)
		SCREEN.Buttons.Type2.image = nil
	elseif pokemonInternal.types[1] ~= PokemonData.Types.UNKNOWN and pokemonInternal.types[1] ~= PokemonData.Types.EMPTY then
		SCREEN.Buttons.Type1.image = Drawing.getImagePath("PokemonType", pokemonInternal.types[1])
		if pokemonInternal.types[2] ~= pokemonInternal.types[1] and pokemonInternal.types[2] ~= PokemonData.Types.EMPTY then
			SCREEN.Buttons.Type2.image = Drawing.getImagePath("PokemonType", pokemonInternal.types[2])
		end
	end

	-- LAST LEVEL
	SCREEN.Data.lastLevel = trackedPokemon.eL or 0

	-- ABILITIES
	SCREEN.Data.abilityName1 = Constants.BLANKLINE
	SCREEN.Data.abilityName2 = Constants.BLANKLINE
	if Options["Open Book Play Mode"] then
		SCREEN.Data.abilityId1 = PokemonData.getAbilityId(pokemonID, 0) or 0
		SCREEN.Data.abilityId2 = PokemonData.getAbilityId(pokemonID, 1) or 0
		if AbilityData.isValid(SCREEN.Data.abilityId1) then
			if SCREEN.Data.abilityId2 ~= SCREEN.Data.abilityId1 and AbilityData.isValid(SCREEN.Data.abilityId2) then
				SCREEN.Data.abilityName1 = AbilityData.Abilities[SCREEN.Data.abilityId1].name .. " /"
				SCREEN.Data.abilityName2 = AbilityData.Abilities[SCREEN.Data.abilityId2].name
			else
				SCREEN.Data.abilityName1 = AbilityData.Abilities[SCREEN.Data.abilityId1].name
				SCREEN.Data.abilityId2 = 0
			end
		end
	elseif trackedPokemon.abilities then
		SCREEN.Data.abilityId1 = trackedPokemon.abilities[1].id or 0
		SCREEN.Data.abilityId2 = trackedPokemon.abilities[2].id or 0
		if AbilityData.isValid(SCREEN.Data.abilityId1) then
			SCREEN.Data.abilityName1 = AbilityData.Abilities[SCREEN.Data.abilityId1].name .. " /"
			SCREEN.Data.abilityName2 = Constants.HIDDEN_INFO
		end
		if AbilityData.isValid(SCREEN.Data.abilityId2) then
			SCREEN.Data.abilityName2 = AbilityData.Abilities[SCREEN.Data.abilityId2].name
		end
	end

	-- SEEN ENCOUNTERS
	SCREEN.Data.seenOnTrainers = trackedPokemon.eT or 0
	SCREEN.Data.seenInWild = trackedPokemon.eW or 0

	-- STAT BOXES
	local statLabels = {
		["hp"] = Resources.TrackerScreen.StatHP,
		["atk"] = Resources.TrackerScreen.StatATK,
		["def"] = Resources.TrackerScreen.StatDEF,
		["spa"] = Resources.TrackerScreen.StatSPA,
		["spd"] = Resources.TrackerScreen.StatSPD,
		["spe"] = Resources.TrackerScreen.StatSPE,
	}
	-- The box is replaced with the real base stat if playing Open Book Play Mode
	local statMarkings = trackedPokemon.sm or {}
	for i, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		local initialState = statMarkings[statKey] or 0
		SCREEN.Buttons["Stat" .. statKey] = {
			type = Constants.ButtonTypes.STAT_STAGE,
			getText = function(self)
				if Options["Open Book Play Mode"] then
					return ""
				else
					return Constants.STAT_STATES[self.statState].text
				end
			end,
			textColor = Constants.STAT_STATES[initialState].textColor,
			box = { CANVAS.X + 124, CANVAS.Y + 4 + (i - 1) * 10, 8, 8 },
			statState = initialState,
			location = "top",
			isVisible = function() return SCREEN.Data.isReady end,
			updateSelf = function(self)
				if Options["Open Book Play Mode"] then
					self.type = Constants.ButtonTypes.NO_BORDER
				else
					self.type = Constants.ButtonTypes.STAT_STAGE
				end
			end,
			onClick = function(self)
				if Options["Open Book Play Mode"] then
					return
				end
				self.statState = ((self.statState + 1) % 4) -- 4 total possible markings for a stat state
				self.textColor = Constants.STAT_STATES[self.statState].textColor
				Tracker.TrackStatMarking(SCREEN.Data.pokemonID, statKey, self.statState)
				Program.redraw(true)
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local textColor = Theme.COLORS[SCREEN.Colors.text]
				Drawing.drawText(x - 26, y - 2, statLabels[statKey], textColor, shadowcolor)
				if Options["Open Book Play Mode"] then
					local highlight = Theme.COLORS[SCREEN.Colors.highlight]
					local pokemon = PokemonData.Pokemon[SCREEN.Data.pokemonID] or {}
					local baseStat = (pokemon.baseStats or {})[statKey]
					Drawing.drawNumber(x - 2, y - 2, baseStat or Constants.BLANKLINE, 3, highlight, shadowcolor)
				end
			end,
		}
	end

	-- MOVES
	-- Sort based on min level seen, or last level seen, in descending order
	local trackedMoves = {}
	for _, move in pairs(trackedPokemon.moves or {}) do
		table.insert(trackedMoves, { id = move.id, level = move.minLv or move.level })
	end
	table.sort(trackedMoves, function(a,b)
		return a.level > b.level or (a.level == b.level and a.id < b.id)
	end)

	local NUM_MOVES = 8
	local allowHiddenMoveInfo = Options["Reveal info if randomized"] or not MoveData.IsRand.moveType
	SCREEN.Data.movesSeen = #trackedMoves
	SCREEN.Data.movesTotal = #pokemonInternal.movelvls[GameSettings.versiongroup] + 4 -- four additional level 1 moves
	SCREEN.Data.topMoves = {}
	for i = 1, NUM_MOVES, 1 do
		local move = trackedMoves[i] or {}
		local validMove = MoveData.isValid(move.id)
		local canShowTypeColor = validMove and allowHiddenMoveInfo
		if validMove then
			SCREEN.Data.topMoves[i] = {
				id = move.id,
				name = MoveData.Moves[move.id].name,
				level = move.level,
				color = Constants.MoveTypeColors[MoveData.Moves[move.id].type]
			}
		end
		local topMove = SCREEN.Data.topMoves[i] or {}
		local moveColor
		if Theme.MOVE_TYPES_ENABLED and canShowTypeColor and topMove.color then
			moveColor = topMove.color
		else
			moveColor = SCREEN.Colors.bottomText
		end
		local moveWidth = CANVAS.W / 2 - 2
		local moveHeight = Constants.SCREEN.LINESPACING - 1
		local moveX = CANVAS.X + 5 + (i % 2 == 0 and moveWidth or 0)
		local moveY = CANVAS.Y + 89 + (math.floor((i - 1) / 2) * moveHeight)
		SCREEN.Buttons["Move" .. i] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return topMove.name or Constants.BLANKLINE end,
			textColor = moveColor,
			box = { moveX, moveY, moveWidth, moveHeight },
			location = "bottom",
			isVisible = function() return SCREEN.Data.isReady end,
			onClick = function(self)
				if not validMove then return end
				InfoScreen.previousScreenFinal = SCREEN
				InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, topMove.id)
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				if not Theme.MOVE_TYPES_ENABLED and canShowTypeColor and topMove.color then
					gui.drawRectangle(x - 2, y + 2, 2, 7, topMove.color, topMove.color)
				end
			end,
		}
	end

	-- NOTE
	SCREEN.Data.note = Utils.shortenText(trackedPokemon.note, CANVAS.W - 32, true)

	SCREEN.Data.isReady = true
	return true
end

function NotebookPokemonNoteView.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function NotebookPokemonNoteView.clearBuiltData()
	SCREEN.Data = {}
	SCREEN.Data.isReady = false
	SCREEN.Buttons.Type1.image = nil
	SCREEN.Buttons.Type2.image = nil
end

function NotebookPokemonNoteView.rebuildData()
	NotebookPokemonNoteView.buildScreen(SCREEN.Data.pokemonID)
	Program.redraw()
end

---@param button table
function NotebookPokemonNoteView.clickStatButton(button)
	button.statState = ((button.statState + 1) % 4) -- 4 total possible markings for a stat state
	button.textColor = Constants.STAT_STATES[button.statState].textColor
	Tracker.TrackStatMarking(SCREEN.Data.pokemonID, button.statKey, button.statState)
	Program.redraw(true)
end

-- USER INPUT FUNCTIONS
function NotebookPokemonNoteView.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function NotebookPokemonNoteView.drawScreen()
	Drawing.drawBackgroundAndMargins()
	SCREEN.refreshButtons()

	local canvas = {
		x = CANVAS.X,
		y = CANVAS.Y,
		width = CANVAS.W,
		height = 75,
		text = Theme.COLORS[SCREEN.Colors.text],
		highlight = Theme.COLORS[SCREEN.Colors.highlight],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}
	local botCanvas = {
		x = canvas.x,
		y = canvas.y + canvas.height + 12,
		width = canvas.width,
		height = 63,
		text = Theme.COLORS[SCREEN.Colors.bottomText],
		highlight = Theme.COLORS[SCREEN.Colors.highlight],
		border = Theme.COLORS[SCREEN.Colors.bottomBorder],
		fill = Theme.COLORS[SCREEN.Colors.bottomFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.bottomFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw other boxes
	gui.drawRectangle(canvas.x, canvas.y + 52, 96, 23, canvas.border, canvas.fill) -- seen #'s
	gui.drawRectangle(canvas.x + 96, canvas.y, 44, canvas.height, canvas.border, canvas.fill) -- stats

	-- Draw all top buttons
	for _, button in pairs(SCREEN.Buttons) do
		if button.location == "top" then
			Drawing.drawButton(button, canvas.shadow)
		end
	end
	-- Draw last to properly overlap large animated icons
	Drawing.drawButton(SCREEN.Buttons.PokemonName, canvas.shadow)
	Drawing.drawButton(SCREEN.Buttons.LastSeenLv, canvas.shadow)
	Drawing.drawButton(SCREEN.Buttons.AbilityLine1, canvas.shadow)
	Drawing.drawButton(SCREEN.Buttons.AbilityLine2, canvas.shadow)

	NotebookPokemonNoteView.drawBottomScreen(canvas)
end

function NotebookPokemonNoteView.drawBottomScreen(canvas)
	local botCanvas = {
		x = canvas.x,
		y = canvas.y + canvas.height + 12,
		width = canvas.width,
		height = 63,
		text = Theme.COLORS[SCREEN.Colors.bottomText],
		highlight = Theme.COLORS[SCREEN.Colors.highlight],
		border = Theme.COLORS[SCREEN.Colors.bottomBorder],
		fill = Theme.COLORS[SCREEN.Colors.bottomFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.bottomFill]),
	}

	-- Draw header: move history label
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawButton(SCREEN.Buttons.MovesLabel, headerShadow)

	-- Draw bottom border box
	gui.defaultTextBackground(botCanvas.fill)
	gui.drawRectangle(botCanvas.x, botCanvas.y, botCanvas.width, botCanvas.height, botCanvas.border, botCanvas.fill) -- moves
	gui.drawRectangle(botCanvas.x, botCanvas.y + 44, botCanvas.width, botCanvas.height - 44, botCanvas.border, botCanvas.fill) -- note

	-- Draw all bottom buttons (lazily determine which buttons are on the bottom part)
	for _, button in pairs(SCREEN.Buttons) do
		if button.location == "bottom" then
			Drawing.drawButton(button, botCanvas.shadow)
		end
	end
end
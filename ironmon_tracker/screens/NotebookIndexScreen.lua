NotebookIndexScreen = {
	Colors = {
		text = "Lower box text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Data = {
	},
}
local SCREEN = NotebookIndexScreen
local ROW_WIDTH = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2 - 11
local ROW_HEIGHT = 32

SCREEN.Buttons = {
	NotebookDescription = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.NotebookIndexScreen.LabelReviewDescription) end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, Constants.SCREEN.MARGIN + 13, ROW_WIDTH, 11 },
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconId = function(self)
			return SCREEN.Data.isReady and SCREEN.Data.lastPokemonSeen or 1 -- 1:Bulbasaur
		end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6, Constants.SCREEN.MARGIN + 37, ROW_HEIGHT, ROW_HEIGHT },
		updateSelf = function(self)
			local iconset = Options.getIconSet()
			self.box[1] = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6 + (iconset.xOffset or 0)
			self.box[2] = Constants.SCREEN.MARGIN + 37 + (iconset.yOffset or 0)
		end,
	},
	PokemonIconRow = {
		type = Constants.ButtonTypes.NO_BORDER,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6, Constants.SCREEN.MARGIN + 39, ROW_WIDTH, ROW_HEIGHT },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6, Constants.SCREEN.MARGIN + 39, ROW_HEIGHT, ROW_HEIGHT },
		onClick = function(self)
			NotebookPokemonSeen.previousScreen = SCREEN
			NotebookPokemonSeen.buildScreen()
			Program.changeScreenView(NotebookPokemonSeen)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			y = y + 4 -- icons are drawn a bit lower
			local textColor = Theme.COLORS[self.textColor]
			local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
			local borderColor = Theme.COLORS[self.boxColors[1]]

			-- Draw row container box
			gui.drawLine(x, y + h + 1, x + ROW_WIDTH, y + h + 1, shadowcolor)
			gui.drawLine(x + ROW_WIDTH + 1, y - 1, x + ROW_WIDTH + 1, y + h + 1, shadowcolor)
			gui.drawRectangle(x - 1, y - 2, ROW_WIDTH + 1, h + 2, borderColor)
			gui.drawLine(x + w, y - 1, x + w, y + h, borderColor)

			-- Draw contained text
			local textX = x + w + 4
			local text
			if SCREEN.Data.isReady then
				text = string.format("%s / %s", SCREEN.Data.pokemonSeen, SCREEN.Data.totalPokemon)
			else
				text = string.format("%s / %s", Constants.BLANKLINE, Constants.BLANKLINE)
			end
			Drawing.drawText(textX, y + 3, Resources.NotebookIndexScreen.LabelPokemonSeen, highlightColor, shadowcolor)
			Drawing.drawText(textX, y + 14, text, textColor, shadowcolor)

			Drawing.drawImageAsPixels(Constants.PixelImages.NOTEBOOK, x + ROW_WIDTH - 20, y + ROW_HEIGHT / 2 - 6, nil, shadowcolor)
		end,
	},
	TrainerIcon = {
		type = Constants.ButtonTypes.IMAGE,
		image = nil,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6, Constants.SCREEN.MARGIN + 87, ROW_WIDTH, ROW_HEIGHT },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 6, Constants.SCREEN.MARGIN + 87, ROW_HEIGHT, ROW_HEIGHT },
		onClick = function(self)
			NotebookTrainersByArea.previousScreen = SCREEN
			NotebookTrainersByArea.buildScreen()
			Program.changeScreenView(NotebookTrainersByArea)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local textColor = Theme.COLORS[self.textColor]
			local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
			local borderColor = Theme.COLORS[self.boxColors[1]]

			-- Draw row container box
			gui.drawLine(x, y + h + 1, x + ROW_WIDTH, y + h + 1, shadowcolor)
			gui.drawLine(x + ROW_WIDTH + 1, y - 1, x + ROW_WIDTH + 1, y + h + 1, shadowcolor)
			gui.drawRectangle(x - 1, y - 2, ROW_WIDTH + 1, h + 2, borderColor)
			gui.drawLine(x + w, y - 1, x + w, y + h, borderColor)

			-- Draw contained text
			local textX = x + w + 4
			local text
			if SCREEN.Data.isReady then
				text = string.format("%s / %s", SCREEN.Data.trainersDefeated, SCREEN.Data.totalTrainers)
			else
				text = string.format("%s / %s", Constants.BLANKLINE, Constants.BLANKLINE)
			end
			Drawing.drawText(textX, y + 3, Resources.NotebookIndexScreen.LabelTrainersFought, highlightColor, shadowcolor)
			Drawing.drawText(textX, y + 14, text, textColor, shadowcolor)

			Drawing.drawImageAsPixels(Constants.PixelImages.BATTLE_BALLS, x + ROW_WIDTH - 20, y + ROW_HEIGHT / 2 - 8, nil, shadowcolor)
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or NavigationMenu)
		SCREEN.previousScreen = nil
	end),
}

function NotebookIndexScreen.initialize()
	SCREEN.Buttons.TrainerIcon.image = TrainerData.getPortraitIcon(TrainerData.Classes.BugCatcher)

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

---Retrieves and builds the data needed to draw this screen; stored in `NotebookIndexScreen.Data`
function NotebookIndexScreen.buildScreen()
	SCREEN.clearBuiltData()

	-- Update the last seen pokemon in battle
	if PokemonData.isValid(Battle.lastPokemonSeen) then
		SCREEN.Data.lastPokemonSeen = Battle.lastPokemonSeen
	else
		SCREEN.Data.lastPokemonSeen = Utils.randomPokemonID()
	end

	-- Recount pokemon seen in tracker notes
	SCREEN.Data.pokemonSeen = 0
	SCREEN.Data.totalPokemon = 0
	-- SCREEN.Data.pokemonSeenEvolved = 0
	-- SCREEN.Data.totalPokemonEvolved = 0
	for pokemonID, pokemon in ipairs(PokemonData.Pokemon) do
		if pokemonID < 252 or pokemonID > 276 then -- Skip fake Pokemon
			SCREEN.Data.totalPokemon = SCREEN.Data.totalPokemon + 1
			local trackedPokemon = Tracker.Data.allPokemon[pokemonID]
			-- Count it if seen as a wild or on a trainer
			-- local hasSeen = (trackedPokemon.eW or 0) > 0 or (trackedPokemon.eT or 0) > 0
			if trackedPokemon ~= nil then
				SCREEN.Data.pokemonSeen = SCREEN.Data.pokemonSeen + 1
			end
			-- if pokemon.evolution == PokemonData.Evolutions.NONE then
			-- 	SCREEN.Data.totalPokemonEvolved = SCREEN.Data.totalPokemonEvolved + 1
			-- 	if hasSeen then
			-- 		SCREEN.Data.pokemonSeenEvolved = SCREEN.Data.pokemonSeenEvolved + 1
			-- 	end
			-- end
		end
	end

	-- Update the last trainer fought icon
	SCREEN.Data.lastTrainerFought = TrackerAPI.getOpponentTrainerId()
	local lastTrainer = TrainerData.getTrainerInfo(SCREEN.Data.lastTrainerFought)
	if lastTrainer ~= TrainerData.BlankTrainer then
		SCREEN.Buttons.TrainerIcon.image = TrainerData.getPortraitIcon(lastTrainer.class)
	end

	-- Recount trainers fought and defeated
	SCREEN.Data.trainersDefeated = 0
	SCREEN.Data.totalTrainers = 0
	local trainersToExclude = TrainerData.getExcludedTrainers()
	local includeSevii = GameSettings.game ~= 3 or NotebookTrainersByArea.Buttons.CheckboxSevii.toggleState -- get option from other screen
	for _, trainerId in ipairs(TrainerData.OrderedIds or {}) do
		if TrainerData.shouldUseTrainer(trainerId) and not trainersToExclude[trainerId] then
			local trainerInternal = TrainerData.getTrainerInfo(trainerId)
			-- Only count trainer if it's not on Sevii or otherwise included due to game version / checkbox
			if includeSevii or trainerInternal.routeId < 230 then
				SCREEN.Data.totalTrainers = SCREEN.Data.totalTrainers + 1
				if TrackerAPI.hasDefeatedTrainer(trainerId) then
					SCREEN.Data.trainersDefeated = SCREEN.Data.trainersDefeated + 1
				end
			end
		end
	end

	SCREEN.Data.isReady = true
end

function NotebookIndexScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function NotebookIndexScreen.clearBuiltData()
	SCREEN.Data = {}
	SCREEN.Data.isReady = false
end

-- USER INPUT FUNCTIONS
function NotebookIndexScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

-- DRAWING FUNCTIONS
function NotebookIndexScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	SCREEN.refreshButtons()

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[SCREEN.Colors.text],
		highlight = Theme.COLORS[SCREEN.Colors.highlight],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)
	-- Header
	local headerText = Utils.toUpperUTF8(Resources.NotebookIndexScreen.Title)
	local headerColor = Theme.COLORS["Header text"]
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, headerColor, headerShadow)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		if button ~= SCREEN.Buttons.PokemonIcon then
			Drawing.drawButton(button, canvas.shadow)
		end
	end
	-- Draw this last such that larger icons overlap the box properly
	Drawing.drawButton(SCREEN.Buttons.PokemonIcon)
end
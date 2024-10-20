NotebookPokemonSeen = {
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Data = {},
}
local SCREEN = NotebookPokemonSeen

local GRIDROW = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1,
	Y = Constants.SCREEN.MARGIN + 36,
	W = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2 - 2,
	H = 32,
	COLS_X = { 0, 33 }
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end, -- Order by index (Pokémon ID)
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer, sortFunc)
		table.sort(self.Buttons, sortFunc or self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP + 1
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
		-- Snap each individual button to their respective button rows
		for _, buttonRow in ipairs(self.Buttons) do
			for _, button in ipairs (buttonRow.buttonList or {}) do
				if type(button.alignToBox) == "function" then
					button:alignToBox(buttonRow.box)
				end
			end
		end
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local text = string.format("%s/%s", self.currentPage, self.totalPages)
		local bufferSize = 7 - text:len()
		return string.rep(" ", bufferSize) .. text
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
}

SCREEN.Buttons = {
	CheckboxIncludeUnseen = {
		type = Constants.ButtonTypes.CHECKBOX,
		getText = function(self) return string.format(" %s", Resources.NotebookPokemonSeen.LabelAll) end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 137, 25, 10 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 137, 8, 8 },
		toggleState = false,
		onClick = function(self)
			self.toggleState = not self.toggleState
			-- Only reuse the nav filter if adding more pokemon data, otherwise clear it out
			if self.toggleState then
				SCREEN.buildScreen(SCREEN.Data.navFilter)
			else
				SCREEN.buildScreen()
			end
			Program.redraw(true)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 54, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 42, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 96, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or NotebookIndexScreen)
		SCREEN.previousScreen = nil
	end),
}

function NotebookPokemonSeen.initialize()
	SCREEN.Buttons.CheckboxIncludeUnseen.toggleState = false
	SCREEN.createNavFilters()

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

function NotebookPokemonSeen.createNavFilters()
	SCREEN.NavButtons = {}
	local navLabels = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
	for _, letter in ipairs(navLabels) do
		local letterWidth = 5 + Utils.calcWordPixelLength(letter) -- add more width for easier clicking
		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return letter end,
			dimensions = { width = letterWidth, height = Constants.Font.SIZE },
			updateSelf = function(self)
				if SCREEN.Data.navFilter == letter then
					self.textColor = SCREEN.Colors.highlight
				else
					self.textColor = SCREEN.Colors.text
				end
			end,
			draw = function(self)
				-- Draw an underline if selected
				if SCREEN.Data.navFilter == letter then
					local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
					gui.drawLine(x + 1, y + h + 1, x + w - 1, y + h + 1, Theme.COLORS[SCREEN.Colors.highlight])
				end
			end,
			onClick = function(self)
				SCREEN.Data.navFilter = letter
				SCREEN.Pager:realignButtonsToGrid(GRIDROW.X, GRIDROW.Y, 0, 0)
				Program.redraw(true)
			end,
		}
		table.insert(SCREEN.NavButtons, button)
	end
	local NAV_GRID = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2,
		y = Constants.SCREEN.MARGIN + 12,
		cutoffx = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - 2,
		cutoffy = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 20,
	}
	Utils.gridAlign(SCREEN.NavButtons, NAV_GRID.x, NAV_GRID.y, 1, 2, false, NAV_GRID.cutoffx, NAV_GRID.cutoffy)
end

---Retrieves and builds the data needed to draw this screen; stored in `NotebookPokemonSeen.Data`
---@param navFilter? string Optional, the starting name filter to apply to the data
function NotebookPokemonSeen.buildScreen(navFilter)
	SCREEN.clearBuiltData()

	local includeUnseen = SCREEN.Buttons.CheckboxIncludeUnseen.toggleState

	-- Add to list all pokemon with tracked notes, and optionally all other pokemon as well
	SCREEN.Data.pokemon = {}
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		local trackedPokemon = Tracker.Data.allPokemon[id]
		local validPokemon = id < 252 or id > 276
		if trackedPokemon ~= nil or (includeUnseen and validPokemon) then
			local pokemonInfo = {
				id = id,
				name = pokemon.name,
			}
			table.insert(SCREEN.Data.pokemon, pokemonInfo)
		end
	end

	for _, pokemonInfo in ipairs(SCREEN.Data.pokemon) do
		local trackedPokemon = Tracker.Data.allPokemon[pokemonInfo.id] or {}

		local buttonRow = {
			type = Constants.ButtonTypes.NO_BORDER,
			buttonList = {},
			pokemon = pokemonInfo,
			index = pokemonInfo.id, -- Used for sorting after a filter is selected
			name = pokemonInfo.name, -- Used for default, unfiltered sorting
			dimensions = { width = GRIDROW.W, height = GRIDROW.H, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				if SCREEN.Data.navFilter == nil then
					return true
				end
				local letter = SCREEN.Data.navFilter
				local name = PokemonData.Pokemon[pokemonInfo.id].name
				return Utils.containsText(name:sub(1,1), letter, true)
			end,
			onClick = function(self)
				if NotebookPokemonNoteView.buildScreen(pokemonInfo.id) then
					NotebookPokemonNoteView.previousScreen = SCREEN
					Program.changeScreenView(NotebookPokemonNoteView)
				end
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local borderColor = Theme.COLORS[SCREEN.Colors.border]
				-- Surround the row with a border
				gui.drawRectangle(x - 1, y - 1, GRIDROW.W + 2, GRIDROW.H, borderColor)
				for _, colX in ipairs(GRIDROW.COLS_X) do
					gui.drawLine(x + colX - 1, y, x + colX - 1, y + h - 1, borderColor)
				end
				for _, button in ipairs(self.buttonList or {}) do
					Drawing.drawButton(button, shadowcolor)
				end
			end,
		}
		table.insert(SCREEN.Pager.Buttons, buttonRow)

		-- POKEMON ICON
		local iconBtn = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getIconId = function(self) return pokemonInfo.id end,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, GRIDROW.H, GRIDROW.H },
			alignToBox = function(self, box)
				self.box[1] = box[1] + GRIDROW.COLS_X[1]
				self.box[2] = box[2] - 4
			end,
		}
		table.insert(buttonRow.buttonList, iconBtn)

		-- POKEMON NAME AND SEEN COUNT
		local seenText = Resources.NotebookPokemonSeen.LabelSeen
		local encountersTrainer = trackedPokemon.eT or 0
		local encountersWild = trackedPokemon.eW or 0
		if encountersTrainer > 0 and encountersWild > 0 then
			seenText = string.format("%s: %s(T) + %s(W)", seenText, encountersTrainer, encountersWild)
		else
			-- In some cases, the pokemon is being tracked but was never encountered
			local seenTotal = encountersTrainer + encountersWild
			seenText = string.format("%s: %s", seenText, seenTotal)
		end
		local nameBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return pokemonInfo.name end,
			textColor = SCREEN.Colors.highlight,
			isVisible = function(self) return buttonRow:isVisible() end,
			box = { -1, -1, 90, 11 },
			alignToBox = function(self, box)
				self.box[1] = box[1] + GRIDROW.COLS_X[2] + 2
				self.box[2] = box[2] + (GRIDROW.H / 2) - Constants.SCREEN.LINESPACING - 2
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local highlight = Theme.COLORS[self.textColor]
				local textColor = Theme.COLORS[SCREEN.Colors.text]
				local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
				Drawing.drawTransparentTextbox(x, y + 2, self:getCustomText(), highlight, bgColor, shadowcolor)
				Drawing.drawTransparentTextbox(x, y + Constants.SCREEN.LINESPACING + 2, seenText, textColor, bgColor, shadowcolor)
			end,
		}
		table.insert(buttonRow.buttonList, nameBtn)

		-- MAJORITY STAT SYMBOL
		if type(trackedPokemon.sm) == "table" then
			local statMajority = 0 -- A loose average of the '+', '-', and '='
			for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
				local statValue = trackedPokemon.sm[statKey] or 0
				if statValue == 1 then -- +
					statMajority = statMajority + 1
				elseif statValue == 2 then -- -
					statMajority = statMajority - 1
				end
			end

			local statState
			if statMajority > 0 then
				statState = Constants.STAT_STATES[1] -- +
			elseif statMajority < 0 then
				statState = Constants.STAT_STATES[2] -- -
			else
				statState = Constants.STAT_STATES[3] -- =
			end

			local statsBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				isVisible = function(self) return buttonRow:isVisible() end,
				box = { -1, -1, 5, 5 },
				alignToBox = function(self, box)
					self.box[1] = box[1] + GRIDROW.W - 8
					self.box[2] = box[2] - 1
				end,
				draw = function(self, shadowcolor)
					local x, y = self.box[1], self.box[2]
					Drawing.drawText(x, y, statState.text, Theme.COLORS[statState.textColor], shadowcolor)
				end,
			}
			table.insert(buttonRow.buttonList, statsBtn)
		end
	end

	-- Place button rows into the grid and update each of their contained buttons
	local alphaSort = function(a, b) return a.name < b.name end
	SCREEN.Pager:realignButtonsToGrid(GRIDROW.X, GRIDROW.Y, 0, 0, alphaSort)

	-- If a nav filter was previously used, switch to that (but only after the prior grid alignment)
	if type(navFilter) == "string" then
		SCREEN.Data.navFilter = Utils.toUpperUTF8(navFilter)
		SCREEN.Pager:realignButtonsToGrid(GRIDROW.X, GRIDROW.Y, 0, 0)
	end
end

function NotebookPokemonSeen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.NavButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function NotebookPokemonSeen.clearBuiltData()
	SCREEN.Data = {}
	SCREEN.Pager.Buttons = {}
end

-- USER INPUT FUNCTIONS
function NotebookPokemonSeen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.NavButtons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function NotebookPokemonSeen.drawScreen()
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
	local headerText = Utils.toUpperUTF8(Resources.NotebookPokemonSeen.Title)
	local headerColor = Theme.COLORS["Header text"]
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, headerColor, headerShadow)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.NavButtons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
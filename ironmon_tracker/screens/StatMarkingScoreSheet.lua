StatMarkingScoreSheet = {
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
local SCREEN = StatMarkingScoreSheet

SCREEN.StatMarkingRanges = {
	MarginOfError = 25,
	[Constants.STAT_STATES[1].text] = { min = 115, max = 255, }, -- [+] positive
	[Constants.STAT_STATES[2].text] = { min = 11, max = 70, }, -- [-] negative
	[Constants.STAT_STATES[3].text] = { min = 70, max = 115, }, -- [=] equal
}

SCREEN.PixelImages = {
	SMALL_X = {
		{1,0,0,0,1},
		{0,1,0,1,0},
		{0,0,1,0,0},
		{0,1,0,1,0},
		{1,0,0,0,1},
	},
	SMALL_CHECK = {
		{0,0,0,0,1},
		{0,0,0,1,0},
		{1,0,1,0,0},
		{0,1,0,0,0},
		{0,0,0,0,0},
	},
	GRADE_A = {
		{0,0,0,0,1,1,1,1,1,1,0,0,0,0},
		{0,0,0,0,1,1,1,1,1,1,0,0,0,0},
		{0,0,1,1,1,1,0,0,1,1,1,1,0,0},
		{0,0,1,1,1,1,0,0,1,1,1,1,0,0},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
	},
	GRADE_B = {
		{1,1,1,1,1,1,1,1,1,1,1,1,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,0,0},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,0,0},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,0,0},
	},
	GRADE_C = {
		{0,0,0,0,1,1,1,1,1,1,1,1,0,0},
		{0,0,0,0,1,1,1,1,1,1,1,1,0,0},
		{0,0,1,1,1,1,0,0,0,0,1,1,1,1},
		{0,0,1,1,1,1,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,0,0,0,0,0,0,0,0,0,0},
		{0,0,1,1,1,1,0,0,0,0,1,1,1,1},
		{0,0,1,1,1,1,0,0,0,0,1,1,1,1},
		{0,0,0,0,1,1,1,1,1,1,1,1,0,0},
		{0,0,0,0,1,1,1,1,1,1,1,1,0,0},
	},
	GRADE_D = {
		{1,1,1,1,1,1,1,1,1,1,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,0,0,0,0},
		{1,1,1,1,0,0,0,0,1,1,1,1,0,0},
		{1,1,1,1,0,0,0,0,1,1,1,1,0,0},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,0,0,1,1,1,1},
		{1,1,1,1,0,0,0,0,1,1,1,1,0,0},
		{1,1,1,1,0,0,0,0,1,1,1,1,0,0},
		{1,1,1,1,1,1,1,1,1,1,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,0,0,0,0},
	},
	PLUS_SIGN = {
		{0,0,1,1,0,0},
		{0,0,1,1,0,0},
		{1,1,1,1,1,1},
		{1,1,1,1,1,1},
		{0,0,1,1,0,0},
		{0,0,1,1,0,0},
	},
}

local SUMMARY_COL2_X = 53
local LETTER_GRADE_X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108
local GRIDROW = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1,
	Y = Constants.SCREEN.MARGIN + 68,
	W = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2 - 2,
	H = 32,
	CELL_W = 21,
	COLS_X = { 1, 35, 56, 77, 98, 119 }
}

local STATS_ORDERED = { "hp", "atk", "def", "spa", "spd" } -- speed is excluded due to notetaking

local function hasMarkings()
	return (SCREEN.Data.totalMarkings or 0) > 0
end

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.score < b.score or (a.score == b.score and a.index < b.index) end, -- Order by least accurate score first
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
	LabelGreat = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.StatMarkingScoreSheet.LabelGreatMarks) end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 11, 8, 8 },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local value = SCREEN.Data.greatMarkings or Constants.BLANKLINE
			local color = Theme.COLORS[SCREEN.Colors.positive]
			Drawing.drawRightJustifiedNumber(x + SUMMARY_COL2_X, y, value, 4, color, shadowcolor)
			Drawing.drawImageAsPixels(SCREEN.PixelImages.SMALL_CHECK, x + SUMMARY_COL2_X + 25, y + 4, color, shadowcolor)
		end,
	},
	LabelPoor = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.StatMarkingScoreSheet.LabelPoorMarks) end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 21, 8, 8 },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local value = SCREEN.Data.poorMarkings or Constants.BLANKLINE
			local color = Theme.COLORS[SCREEN.Colors.negative]
			Drawing.drawRightJustifiedNumber(x + SUMMARY_COL2_X, y, value, 4, color, shadowcolor)
			Drawing.drawImageAsPixels(SCREEN.PixelImages.SMALL_X, x + SUMMARY_COL2_X + 25, y + 3, color, shadowcolor)
		end,
	},
	LabelTotalNotes = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.StatMarkingScoreSheet.LabelTotal) end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 31, 8, 8 },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local value = SCREEN.Data.totalMarkings or Constants.BLANKLINE
			Drawing.drawRightJustifiedNumber(x + SUMMARY_COL2_X, y, value, 4, Theme.COLORS[SCREEN.Colors.text], shadowcolor)
		end,
	},
	LabelGradeScore = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return string.format("%s:", Resources.StatMarkingScoreSheet.LabelPercentage) end,
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, Constants.SCREEN.MARGIN + 41, 8, 8 },
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local value = SCREEN.Data.percentageScore or Constants.BLANKLINE
			local color = Theme.COLORS[SCREEN.Colors.text]
			local rightAlignX = 19 - Utils.calcWordPixelLength(value)
			Drawing.drawText(x + SUMMARY_COL2_X + rightAlignX, y, value, color, shadowcolor)
			Drawing.drawText(x + SUMMARY_COL2_X + 22, y, "%", color, shadowcolor)
		end,
	},
	LetterGradeImage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = nil,
		iconColors = { SCREEN.Colors.highlight },
		circleColor = SCREEN.Colors.highlight,
		box = {	LETTER_GRADE_X, Constants.SCREEN.MARGIN + 26, 14, 14 },
		isVisible = function(self) return self.image ~= nil and hasMarkings() end,
		updateSelf = function(self)
			if self.image ~= SCREEN.Data.gradeLetter then
				self.image = SCREEN.Data.gradeLetter
			end
			-- Reposition the icon for A+
			if SCREEN.Data.percentageScore == "100" and self.box[1] == LETTER_GRADE_X then
				self.box[1] = LETTER_GRADE_X - 3
			elseif SCREEN.Data.percentageScore ~= "100" and self.box[1] ~= LETTER_GRADE_X then
				self.box[1] = LETTER_GRADE_X
			end
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local color = Theme.COLORS[self.iconColors[1]]
			local circleX, circleY, circleW, circleH = x - 9, y - 9, 30, 30
			if SCREEN.Data.percentageScore == "100" then
				circleX = circleX + 3
				Drawing.drawImageAsPixels(SCREEN.PixelImages.PLUS_SIGN, x + w + 2, y + 5, color, shadowcolor)
			end
			if Theme.DRAW_TEXT_SHADOWS then
				gui.drawEllipse(circleX + 1, circleY + 2, circleW, circleH, shadowcolor)
				gui.drawEllipse(circleX + 2, circleY + 2, circleW, circleH, shadowcolor)
			end
			gui.drawEllipse(circleX, circleY, circleW, circleH, color)
			gui.drawEllipse(circleX, circleY + 1, circleW, circleH, color)
			gui.drawEllipse(circleX + 1, circleY, circleW, circleH, color - (Drawing.ColorEffects.DARKEN * 2))
			gui.drawEllipse(circleX + 1, circleY + 1, circleW, circleH, color - (Drawing.ColorEffects.DARKEN * 2))
		end,
	},
	-- Consider having a way to adjust the acceptable ranges for high/medium/low markings, as well as margin of error
	-- EditOptions = {
	-- 	type = Constants.ButtonTypes.FULL_BORDER,
	-- 	getText = function(self) return "Options" or Resources.ExtrasScreen.ButtonEditTime end,
	-- 	box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 135, 35, 11 },
	-- 	onClick = function(self) ExtrasScreen.openEditTimerPrompt() end,
	-- },
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 51, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 39, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 93, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or TrackerScreen)
		SCREEN.previousScreen = nil
	end),
}

function StatMarkingScoreSheet.initialize()
	StatMarkingScoreSheet.createHeader()

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

function StatMarkingScoreSheet.createHeader()
	SCREEN.NavButtons = {}

	for i, statKey in ipairs(STATS_ORDERED) do
		local statText = Utils.toUpperUTF8(statKey)
		SCREEN.NavButtons[statKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			textColor = SCREEN.Colors.text,
			box = { GRIDROW.X + GRIDROW.COLS_X[i + 1], GRIDROW.Y - Constants.SCREEN.LINESPACING - 3, GRIDROW.CELL_W, 10 },
			isVisible = function(self) return hasMarkings() end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local textColor = Theme.COLORS[self.textColor]
				local borderColor = Theme.COLORS[SCREEN.Colors.border]
				local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
				local centerOffset = Utils.getCenteredTextX(statText, GRIDROW.CELL_W) - 2
				-- Draw vertical dotted line
				for offsetY = 1, GRIDROW.H - 1, 2 do
					gui.drawPixel(x - 1, y + 2 + offsetY, borderColor)
				end
				Drawing.drawTransparentTextbox(x + centerOffset, y + 2, statText, textColor, bgColor, shadowcolor)
			end,
		}
	end
end

---Retrieves and builds the data needed to draw this screen; stored in `StatMarkingScoreSheet.Data`
function StatMarkingScoreSheet.buildScreen()
	SCREEN.clearBuiltData()

	SCREEN.Data.greatMarkings = 0
	SCREEN.Data.poorMarkings = 0
	SCREEN.Data.totalMarkings = 0
	SCREEN.Data.gradeLetter = nil

	-- Add to list all pokemon with tracked stat markings
	SCREEN.Data.pokemon = {}
	for id, trackedPokemon in pairs(Tracker.Data.allPokemon or {}) do
		-- Only review pokemon who have at least 1 stat marking
		if trackedPokemon.sm then
			local nonSpeedMarked = false
			for _, statKey in ipairs(STATS_ORDERED) do
				if (trackedPokemon.sm[statKey] or 0) > 0 then
					nonSpeedMarked = true
					break
				end
			end
			if nonSpeedMarked then
				-- Certain abilities modify how impactful the stats can be
				local firstAbilityId = PokemonData.getAbilityId(id, 0)
				local pokemonInfo = {
					id = id,
					abilityId = firstAbilityId,
					statMarkings = trackedPokemon.sm,
				}
				table.insert(SCREEN.Data.pokemon, pokemonInfo)
			end
		end
	end

	for _, pokemonInfo in ipairs(SCREEN.Data.pokemon) do
		local pokemonInternal = PokemonData.Pokemon[pokemonInfo.id] or PokemonData.BlankPokemon

		local buttonRow = {
			type = Constants.ButtonTypes.NO_BORDER,
			buttonList = {},
			pokemon = pokemonInfo,
			index = pokemonInfo.id, -- Used for sorting after a filter is selected
			dimensions = { width = GRIDROW.W, height = GRIDROW.H, },
			isVisible = function(self) return SCREEN.Pager.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				return true
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
				-- Draw vertical dotted lines
				for i, colX in ipairs(GRIDROW.COLS_X) do
					if i ~= 1 then -- skip the left-most vertical divider line
						for offsetY = 1, GRIDROW.H - 1, 2 do
							gui.drawPixel(x + colX - 1, y + offsetY, borderColor)
						end
					end
				end
				-- Draw horizontal dotted lines
				for offsetX = GRIDROW.COLS_X[2] + 1, GRIDROW.W, 2 do
					gui.drawPixel(x + offsetX, y + 15, borderColor)
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

		-- POKEMON BASE STATS AND MARKINGS
		local gradeScore = 0 -- +1 for correct markings, -10 for incorrect
		local baseStats = pokemonInternal.baseStats or {}
		for i, statKey in ipairs(STATS_ORDERED) do
			local baseStatText = tostring(baseStats[statKey] or 0)
			local statMarking
			if (pokemonInfo.statMarkings[statKey] or 0) > 0 then
				local statState = Constants.STAT_STATES[pokemonInfo.statMarkings[statKey]] or {}
				statMarking = statState.text
				SCREEN.Data.totalMarkings = SCREEN.Data.totalMarkings + 1
			end
			local gradeColor, gradeSymbol
			if not statMarking then
				gradeColor = SCREEN.Colors.text
			elseif SCREEN.isMarkingAccurate(statMarking, baseStats[statKey], statKey, pokemonInfo.abilityId) then
				gradeScore = gradeScore + 1
				gradeColor = SCREEN.Colors.positive
				gradeSymbol = SCREEN.PixelImages.SMALL_CHECK
				SCREEN.Data.greatMarkings = SCREEN.Data.greatMarkings + 1
			else
				gradeScore = gradeScore - 10
				gradeColor = SCREEN.Colors.negative
				gradeSymbol = SCREEN.PixelImages.SMALL_X
				SCREEN.Data.poorMarkings = SCREEN.Data.poorMarkings + 1
			end

			local statBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				isVisible = function(self) return buttonRow:isVisible() end,
				box = { -1, -1, GRIDROW.CELL_W, GRIDROW.H / 2 },
				alignToBox = function(self, box)
					self.box[1] = box[1] + GRIDROW.COLS_X[i + 1]
					self.box[2] = box[2] + (GRIDROW.H / 2) + 2
				end,
				draw = function(self, shadowcolor)
					local x, y, w = self.box[1], self.box[2], self.box[3]
					local textColor = Theme.COLORS[SCREEN.Colors.text]
					local bgColor = Theme.COLORS[SCREEN.Colors.boxFill]
					if statMarking then
						local centerOffset = Utils.getCenteredTextX(statMarking, GRIDROW.CELL_W) - 2
						Drawing.drawTransparentTextbox(x + centerOffset, y - 16, statMarking, textColor, bgColor, shadowcolor)
						if gradeSymbol then
							Drawing.drawImageAsPixels(gradeSymbol, x + w - 7, y - 17, Theme.COLORS[gradeColor], shadowcolor)
						end
					end
					local centerOffset = Utils.getCenteredTextX(baseStatText, GRIDROW.CELL_W) - 2
					Drawing.drawTransparentTextbox(x + centerOffset, y, baseStatText, textColor, bgColor, shadowcolor)
					-- Draw an indicator that this stat is being influenced by the Pokémon's ability
					if SCREEN.checkAbilityException(statKey, pokemonInfo.abilityId) ~= nil then
						Drawing.drawChevronsVerticalIntensity(x + 1, y - 3, 1, 1, 4, 2, 1, 2)
					end
				end,
			}
			table.insert(buttonRow.buttonList, statBtn)
		end
		buttonRow.score = gradeScore
	end

	-- Place button rows into the grid and update each of their contained buttons
	SCREEN.Pager:realignButtonsToGrid(GRIDROW.X, GRIDROW.Y, 0, 0)

	if SCREEN.Data.totalMarkings > 0 then
		if SCREEN.Data.greatMarkings == SCREEN.Data.totalMarkings then
			SCREEN.Data.percentageScore = "100"
		else
			local percentile = SCREEN.Data.greatMarkings * 100 / SCREEN.Data.totalMarkings
			SCREEN.Data.percentageScore = string.format("%.1f", percentile)
		end
	else
		SCREEN.Data.percentageScore = Constants.BLANKLINE
	end

	local percentile = tonumber(SCREEN.Data.percentageScore) or 0
	SCREEN.Data.gradeLetter = SCREEN.getGradePixelImage(percentile)
end

function StatMarkingScoreSheet.checkAbilityException(statKey, abilityId)
	if statKey == "atk" and (abilityId == AbilityData.Values.HugePowerId or abilityId == AbilityData.Values.PurePowerId) then
		return "HugePower"
	elseif statKey == "atk" and abilityId == AbilityData.Values.HustleId then
		return "Hustle"
	elseif statKey == "spd" and abilityId == AbilityData.Values.ThickFatId then
		return "ThickFat"
	end
	return nil
end

---Returns true if the `statMarking` for a given `baseStat` value is within its range [and margin of error], inclusive
---@param statMarking string
---@param baseStat number
---@param statKey? string Optional, pair with `abilityId` to check for abilities that would affect the marking accuracy
---@param abilityId? number Optional
---@return boolean
function StatMarkingScoreSheet.isMarkingAccurate(statMarking, baseStat, statKey, abilityId)
	local range = SCREEN.StatMarkingRanges[statMarking or false]
	if not range then
		return false
	end
	local minAllowed = range.min - SCREEN.StatMarkingRanges.MarginOfError
	local maxAllowed = range.max + SCREEN.StatMarkingRanges.MarginOfError

	local alternativeSuccess = false
	if SCREEN.checkAbilityException(statKey, abilityId) == "HugePower" then
		baseStat = math.min(baseStat * 2, 255) -- treat it as though it's doubled, max 255
	elseif SCREEN.checkAbilityException(statKey, abilityId) == "Hustle" then
		baseStat = math.min(baseStat * 1.5, 255) -- treat it as though it's boosted, max 255
	elseif SCREEN.checkAbilityException(statKey, abilityId) == "ThickFat" then
		local altBaseStat = math.min(baseStat * 2, 255) -- treat it as though it's doubled, max 255
		alternativeSuccess = (altBaseStat >= minAllowed) and (altBaseStat <= maxAllowed)
	end

	return (baseStat >= minAllowed) and (baseStat <= maxAllowed) or alternativeSuccess
end

---Returns a pixel-image table that represents a letter grade from A to D.
---@param percentile number
---@return table pixelImage
function StatMarkingScoreSheet.getGradePixelImage(percentile)
	percentile = percentile or 0
	if percentile == 100 then
		return SCREEN.PixelImages.GRADE_A
	elseif percentile >= 90 then
		return SCREEN.PixelImages.GRADE_A
	elseif percentile >= 80 then
		return SCREEN.PixelImages.GRADE_B
	elseif percentile >= 70 then
		return SCREEN.PixelImages.GRADE_C
	else
		return SCREEN.PixelImages.GRADE_D
	end
end

function StatMarkingScoreSheet.refreshButtons()
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

function StatMarkingScoreSheet.clearBuiltData()
	SCREEN.Data = {}
	SCREEN.Pager.Buttons = {}
end

-- USER INPUT FUNCTIONS
function StatMarkingScoreSheet.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.NavButtons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function StatMarkingScoreSheet.drawScreen()
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
	local headerText = Utils.toUpperUTF8(Resources.StatMarkingScoreSheet.Title)
	local headerColor = Theme.COLORS["Header text"]
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, headerColor, headerShadow)

	-- If no stat marking notes were taken, draw a message about that
	if not hasMarkings() then
		local msgToDisplay = Resources.StatMarkingScoreSheet.MessageTakeNotesByMarking
		local wrappedQuotes = Utils.getWordWrapLines(msgToDisplay, 29)
		local textLineY = GRIDROW.Y + Constants.SCREEN.LINESPACING
		for _, line in pairs(wrappedQuotes or {}) do
			local centerOffsetX = Utils.getCenteredTextX(line, canvas.width) - 1
			Drawing.drawText(canvas.x + centerOffsetX, textLineY, line, canvas.text, canvas.shadow)
			textLineY = textLineY + Constants.SCREEN.LINESPACING - 1
		end
	end

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.NavButtons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end
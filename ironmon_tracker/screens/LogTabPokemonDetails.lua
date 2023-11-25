LogTabPokemonDetails = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		highlight = "Intermediate text",
	},
	Tabs = {
		LevelMoves = 1,
		TmMoves = 2,
	},
	infoId = -1,
	dataSet = nil,
	currentPreEvoSet = 1,
	currentEvoSet = 1,
	prevEvosPerSet = 1,
	evosPerSet = 3,
}

LogTabPokemonDetails.TemporaryButtons = {}

LogTabPokemonDetails.Pager = {
	Buttons = {},
	currentPage = 0,
	currentTab = 0,
	totalPages = 0,
	movesPerPage = 8,
	totalLearnedMoves = 0, -- set each time new pokemon zoom is built
	totalTMMoves = 0, -- set each time new pokemon zoom is built
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
	changeTab = function(self, newTab)
		self.currentTab = newTab
		self.currentPage = 1

		if newTab == LogTabPokemonDetails.Tabs.LevelMoves then
			self.totalPages = math.ceil(self.totalLearnedMoves / self.movesPerPage)
		elseif newTab == LogTabPokemonDetails.Tabs.TmMoves then
			self.totalPages = math.ceil(self.totalTMMoves / self.movesPerPage)
		else -- Currently unused
			self.totalPages = 1
		end
		LogTabPokemonDetails.refreshButtons()
	end,
}

function LogTabPokemonDetails.initialize()
	LogTabPokemonDetails.infoId = -1
	LogTabPokemonDetails.dataSet = nil
	LogTabPokemonDetails.currentPreEvoSet = 1
	LogTabPokemonDetails.currentEvoSet = 1
	LogTabPokemonDetails.prevEvosPerSet = 1
	LogTabPokemonDetails.evosPerSet = 3
end

function LogTabPokemonDetails.refreshButtons()
	for _, button in pairs(LogTabPokemonDetails.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabPokemonDetails.Pager.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabPokemonDetails.rebuild()
	LogTabPokemonDetails.buildZoomButtons()
end

function LogTabPokemonDetails.buildZoomButtons(pokemonID)
	pokemonID = pokemonID or LogTabPokemonDetails.infoId or -1
	local data = DataHelper.buildPokemonLogDisplay(pokemonID)
	LogTabPokemonDetails.infoId = pokemonID
	LogTabPokemonDetails.dataSet = data

	LogTabPokemonDetails.TemporaryButtons = {}
	LogTabPokemonDetails.Pager.Buttons = {}

	LogTabPokemonDetails.currentPreEvoSet = 1
	LogTabPokemonDetails.currentEvoSet = 1

	if data.p.abilities[1] == data.p.abilities[2] then
		data.p.abilities[2] = nil
	end

	local abilityButtonArea ={
		x = LogOverlay.TabBox.x + 1,
		y = LogOverlay.TabBox.y + 13,
		w = 60,
		h = Constants.SCREEN.LINESPACING * 2
	}

	-- ABILITIES
	local offsetY = 0
	for i, abilityId in ipairs(data.p.abilities) do
		local abilityBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self)
				if AbilityData.isValid(abilityId) then
					return string.format("%s: %s", i, AbilityData.Abilities[abilityId].name)
				else
					return Constants.BLANKLINE
				end
			end,
			textColor = LogTabPokemonDetails.Colors.text,
			abilityId = abilityId,
			box = { abilityButtonArea.x, abilityButtonArea.y + offsetY, 60, Constants.SCREEN.LINESPACING },
			updateSelf = function(self)
				self.textColor = LogTabPokemonDetails.Colors.text
				if Utils.isNilOrEmpty(LogSearchScreen.searchText) or not AbilityData.isValid(abilityId) then
					return
				end
				local abilityName = AbilityData.Abilities[abilityId].name
				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
					if Utils.containsText(abilityName, LogSearchScreen.searchText, true) then
						self.textColor = LogTabPokemonDetails.Colors.highlight
					end
				end
			end,
			onClick = function(self)
				if AbilityData.isValid(abilityId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, self.abilityId) -- implied redraw
				end
			end,
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, abilityBtn)
		offsetY = offsetY + abilityBtn.box[4]
	end

	local evoMethods = Utils.getShortenedEvolutionsInfo(PokemonData.Pokemon[data.p.id].evolution) or {}

	local hasPrevEvo = Options["Show Pre Evolutions"] and (#data.p.prevos > 0)
	local hasEvo = hasPrevEvo or (#data.p.evos > 0)

	local preEvoList = {}
	if hasPrevEvo then
		for _, prev in ipairs(data.p.prevos) do
			table.insert(preEvoList, {
				name = PokemonData.Pokemon[prev.id].name,
				id = prev.id
			})
		end
	end

	local evoList = {}
	if hasEvo then
		for i, evoInfo in ipairs(data.p.evos) do
			table.insert(evoList,
				{
					name = PokemonData.Pokemon[evoInfo.id].name,
					id = evoInfo.id,
					method = evoMethods[i]
				})
		end
	end

	-- Pre-evos
	local pokemonIconSize = 32
	local pokemonIconSpacing = 4
	local evoLabelTextHeight = 7
	local evoArrowSize = 10

	local pokemonIconRange = {
		x = LogOverlay.TabBox.x + 75,
		y = LogOverlay.TabBox.y - 2,
		w = function(self) return Constants.SCREEN.WIDTH - self.x - LogOverlay.TabBox.x - 1 end,
		h = pokemonIconSize + evoLabelTextHeight,
	}

	for i, preEvo in ipairs(preEvoList) do
		local evoText = ""
		-- Get pre-evos list of evos
		local preEvoEvoMethodList = Utils.getShortenedEvolutionsInfo(PokemonData.Pokemon[preEvo.id].evolution)
		local preEvoEvoMonList = RandomizerLog.Data.Pokemon[preEvo.id].Evolutions

		-- Find the evo that matches the current pokemon
		for j, evo in ipairs(preEvoEvoMonList) do
			if evo == data.p.id then
				evoText = preEvoEvoMethodList[j]
			end
		end
		-- If no match, use the first evo method
		if not evoText then
			evoText = preEvoEvoMethodList[1]
		end
		local x = pokemonIconRange.x
		local y = pokemonIconRange.y
		local preEvoButton = {
			textColor = LogTabPokemonDetails.Colors.text,
			getText = function(self) return evoText end,
			type = Constants.ButtonTypes.POKEMON_ICON,
			pokemonID = preEvo.id,
			clickableArea = { x, y, pokemonIconSize, pokemonIconSize + evoLabelTextHeight },
			box = { x, y, pokemonIconSize, pokemonIconSize },
			preEvoSet = i,
			isVisible = function(self) return self.preEvoSet == LogTabPokemonDetails.currentPreEvoSet end,
			getIconId = function(self) return self.pokemonID, SpriteData.Types.Idle end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
				end
			end,
			draw = function(self, shadowcolor)
				local evoTextSize = Utils.calcWordPixelLength(self:getText() or "")
				-- Center text
				local offsetX = math.max((self.box[3] - evoTextSize) / 2, 0)
				local textX = self.box[1] + offsetX + pokemonIconSize + pokemonIconSpacing + evoArrowSize
				local textY = self.box[2] + self.box[4] + 2
				local textColor = Theme.COLORS[self.textColor]
				local bgColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
				Drawing.drawTransparentTextbox(textX, textY, self:getText(), textColor, bgColor, shadowcolor)
			end
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, preEvoButton)
	end

	-- Main pokemon icon
	local pokeIcon = {
		pokemonIconRange.x,
		pokemonIconRange.y,
		pokemonIconSize,
		pokemonIconSize,
	}
	if hasPrevEvo then
		pokeIcon[1] = pokeIcon[1] + pokemonIconSize + pokemonIconSpacing + evoArrowSize
		LogTabPokemonDetails.evosPerSet = 2
	else
		LogTabPokemonDetails.evosPerSet = 3
	end
	local viewedPokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		pokemonID = data.p.id,
		box = pokeIcon,
		clickableArea = { pokeIcon[1], pokeIcon[2], pokeIcon[3], pokeIcon[4] + evoLabelTextHeight },
		getIconId = function(self) return self.pokemonID, SpriteData.Types.Idle end,
		onClick = function(self)
			if PokemonData.isValid(self.pokemonID) then
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
			end
		end,
		draw = function(self, shadowcolor)
			if Options["Show Pre Evolutions"] and hasEvo then
				local color = Theme.COLORS[LogTabPokemonDetails.Colors.highlight]
				local w, h = pokemonIconSize - 1, pokemonIconSize - 4
				Drawing.drawSelectionIndicators(self.box[1], self.box[2] + evoLabelTextHeight - 1, w, h, color, 1, 5, 1)
			end
		end
	}
	table.insert(LogTabPokemonDetails.TemporaryButtons, viewedPokemonIcon)

	-- Evo icons
	local evoSet = 1
	local xOffset = evoArrowSize
	for i, evo in ipairs(evoList) do
		local evoBox = {
			xOffset + viewedPokemonIcon.box[1] + pokemonIconSize + pokemonIconSpacing,
			pokemonIconRange.y,
			pokemonIconSize,
			pokemonIconSize,
		}
		-- If no evo method is given, use the first one
		if not evo.method then
			evo.method = evoList[1].method
		end
		local evoButton = {
			textColor = LogTabPokemonDetails.Colors.text,
			getText = function(self) return evo.method end,
			type = Constants.ButtonTypes.POKEMON_ICON,
			pokemonID = evo.id,
			clickableArea = { evoBox[1], evoBox[2], evoBox[3], evoBox[4] + evoLabelTextHeight },
			box = evoBox,
			evoSet = evoSet,
			isVisible = function(self) return self.evoSet == LogTabPokemonDetails.currentEvoSet end,
			getIconId = function(self) return self.pokemonID, SpriteData.Types.Idle end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
				end
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local textColor = Theme.COLORS[self.textColor]
				local bgColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
				local evoText = self:getText() or ""
				local evoTextSize = Utils.calcWordPixelLength(evoText)
				local offsetX = math.max((self.box[3] - evoTextSize) / 2, 0)
				Drawing.drawTransparentTextbox(x + offsetX, y + self.box[4] + 2, evoText, textColor, bgColor, shadowcolor)
			end
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, evoButton)
		if i % LogTabPokemonDetails.evosPerSet == 0 then
			evoSet = evoSet + 1
			xOffset = evoArrowSize
		else
			xOffset = xOffset + pokemonIconSize + (pokemonIconSpacing / 2)
		end
	end

	-- EVOLUTION ARROW
	local evoArrowX = viewedPokemonIcon.box[1] + pokemonIconSpacing / 2 + pokemonIconSize
	if hasEvo then
		local evoArrow = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.RIGHT_ARROW,
			textColor = LogTabPokemonDetails.Colors.text,
			box = {
				evoArrowX,
				pokemonIconRange.y + (pokemonIconRange.h / 2) - 3,
				evoArrowSize,
				evoArrowSize
			},
			isVisible = function() return #data.p.evos > 0 end,
			onClick = function(self)
				LogTabPokemonDetails.currentEvoSet = LogTabPokemonDetails.currentEvoSet % math.ceil(#data.p.evos / LogTabPokemonDetails.evosPerSet) + 1
				Program.redraw(true)
			end,
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, evoArrow)
	end

	-- PREV EVOLUTION ARROW
	local prevEvoArrowX = viewedPokemonIcon.box[1] - pokemonIconSpacing / 2 - evoArrowSize
	if hasPrevEvo then
		local prevEvoArrow = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.RIGHT_ARROW,
			textColor = "Lower box text",
			box = {
				prevEvoArrowX,
				pokemonIconRange.y + (pokemonIconRange.h / 2) - 3,
				evoArrowSize,
				evoArrowSize
			},
			isVisible = function() return #data.p.prevos > 0 end,
			onClick = function(self)
				LogTabPokemonDetails.currentPreEvoSet = LogTabPokemonDetails.currentPreEvoSet - 1
				if LogTabPokemonDetails.currentPreEvoSet <= 0 then
					LogTabPokemonDetails.currentPreEvoSet = math.ceil(#data.p.prevos / LogTabPokemonDetails.prevEvosPerSet)
				end
				Program.redraw(true)
			end,
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, prevEvoArrow)
	end

	-- Chevrons to indicate current evoset and prevo set
	local chevronSizeX = 2
	local chevronSizeY = 4
	local chevronSpacing = 0
	local chevronThickness = 2

	if #evoList > LogTabPokemonDetails.evosPerSet then
		local evosets = math.ceil(#evoList / LogTabPokemonDetails.evosPerSet)
		local chevronsTotalWidth = (chevronSizeX + chevronThickness + chevronSpacing + 1) * evosets - chevronSpacing

		local centerX = evoArrowX + evoArrowSize / 2 - 1 -- -1 to center it better
		local startX = centerX - (chevronsTotalWidth / 2)

		local chevronBox = {
			startX,
			viewedPokemonIcon.box[2] + pokemonIconSize + Constants.Font.SIZE - ((chevronSizeY + 1) / 2),
			chevronsTotalWidth,
			chevronSizeY
		}

		local chevronButton = {
			type = Constants.ButtonTypes.NORMAL,
			box = chevronBox,
			clickableArea = {
				startX - (chevronSpacing + 1),
				chevronBox[2] - (chevronSpacing + 1),
				chevronsTotalWidth + (chevronSpacing + 1) * 2,
				chevronSizeY + (chevronSpacing + 1) * 2
			},
			color = function(i)
				if i == LogTabPokemonDetails.currentEvoSet then
					return Theme.COLORS["Positive text"]
				end
				return Theme.COLORS["Lower box text"]
			end,
			isVisible = function() return #data.p.evos > LogTabPokemonDetails.evosPerSet end,
			draw = function(self)
				for i = 1, evosets do
					Drawing.drawChevron(
						startX + ((i - 1) * (chevronSizeX + chevronSpacing + chevronThickness)),
						self.box[2],
						chevronSizeX,
						chevronSizeY,
						chevronThickness,
						"right",
						self.color(i)
					)
				end
			end,
			onClick = function(self)
				LogTabPokemonDetails.currentEvoSet = LogTabPokemonDetails.currentEvoSet + 1
				if LogTabPokemonDetails.currentEvoSet > evosets then
					LogTabPokemonDetails.currentEvoSet = 1
				end
				Program.redraw(true)
			end
		}

		table.insert(LogTabPokemonDetails.TemporaryButtons, chevronButton)
	end

	if #preEvoList > LogTabPokemonDetails.prevEvosPerSet then
		local prevosets = math.ceil(#preEvoList / LogTabPokemonDetails.prevEvosPerSet)
		local chevronsTotalWidth = (chevronSizeX + chevronThickness + chevronSpacing + 1) * prevosets - chevronSpacing

		local centerX = prevEvoArrowX + evoArrowSize / 2 - 2 -- -2 to center it better for some reason
		local startX = centerX - (chevronsTotalWidth / 2)

		local chevronBox = {
			startX,
			viewedPokemonIcon.box[2] + pokemonIconSize + Constants.Font.SIZE - ((chevronSizeY + 1) / 2),
			chevronsTotalWidth,
			chevronSizeY
		}

		local chevronButton = {
			type = Constants.ButtonTypes.NORMAL,
			box = chevronBox,
			clickableArea = {
				startX - (chevronSpacing + 1),
				chevronBox[2] - (chevronSpacing + 1),
				chevronsTotalWidth + (chevronSpacing + 1) * 2,
				chevronSizeY + (chevronSpacing + 1) * 2
			},
			color = function(i)
				if i == LogTabPokemonDetails.currentPreEvoSet then
					return Theme.COLORS["Positive text"]
				end
				return Theme.COLORS["Lower box text"]
			end,
			isVisible = function() return #data.p.prevos > LogTabPokemonDetails.prevEvosPerSet end,
			draw = function(self)
				for i = 1, prevosets do
					Drawing.drawChevron(
						startX + ((i - 1) * (chevronSizeX + chevronSpacing + chevronThickness)),
						self.box[2],
						chevronSizeX,
						chevronSizeY,
						chevronThickness,
						"right",
						self.color(i)
					)
				end
			end,
			onClick = function(self)
				LogTabPokemonDetails.currentPreEvoSet = LogTabPokemonDetails.currentPreEvoSet + 1
				if LogTabPokemonDetails.currentPreEvoSet > prevosets then
					LogTabPokemonDetails.currentPreEvoSet = 1
				end
				Program.redraw(true)
			end
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, chevronButton)
	end

	local movesColX = LogOverlay.TabBox.x + 118
	local movesRowY = LogOverlay.TabBox.y + Utils.inlineIf(hasEvo, 42, 0)
	LogTabPokemonDetails.Pager.movesPerPage = Utils.inlineIf(hasEvo, 8, 12)

	local levelupMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.ButtonLevelupMoves end,
		textColor = LogTabPokemonDetails.Colors.text,
		tab = LogTabPokemonDetails.Tabs.LevelMoves,
		isSelected = false,
		box = { movesColX, movesRowY, 60, 11 },
		updateSelf = function(self)
			self.isSelected = (LogTabPokemonDetails.Pager.currentTab == self.tab)
			self.textColor = Utils.inlineIf(self.isSelected, LogTabPokemonDetails.Colors.highlight, LogTabPokemonDetails.Colors.text)
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
			Drawing.drawTransparentTextbox(x + 1, y, self:getText(), textColor, bgColor, shadowcolor)
			if self.isSelected then
				Drawing.drawUnderline(self, textColor)
			end
		end,
		onClick = function(self)
			if self.isSelected then return end -- Don't change if already on this tab
			LogTabPokemonDetails.Pager:changeTab(self.tab)
			Program.redraw(true)
		end,
	}
	local tmMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.ButtonTMMoves end,
		textColor = LogTabPokemonDetails.Colors.text,
		tab = LogTabPokemonDetails.Tabs.TmMoves,
		isSelected = false,
		box = { movesColX + 70, movesRowY, 41, 11 },
		updateSelf = function(self)
			self.isSelected = (LogTabPokemonDetails.Pager.currentTab == self.tab)
			self.textColor = Utils.inlineIf(self.isSelected, LogTabPokemonDetails.Colors.highlight, LogTabPokemonDetails.Colors.text)
		end,
		draw = function(self, shadowcolor)
			local x, y = self.box[1], self.box[2]
			local textColor = Theme.COLORS[self.textColor]
			local bgColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
			Drawing.drawTransparentTextbox(x + 1, y, self:getText(), textColor, bgColor, shadowcolor)
			if self.isSelected then
				Drawing.drawUnderline(self, textColor)
			end
		end,
		onClick = function(self)
			if self.isSelected then return end -- Don't change if already on this tab
			LogTabPokemonDetails.Pager:changeTab(self.tab)
			Program.redraw(true)
		end,
	}
	table.insert(LogTabPokemonDetails.TemporaryButtons, levelupMovesTab)
	table.insert(LogTabPokemonDetails.TemporaryButtons, tmMovesTab)

	local moveCategoryOffset = 90

	-- LEARNABLE MOVES
	offsetY = 0
	for i, moveInfo in ipairs(data.p.moves) do
		local moveColor = Utils.inlineIf(moveInfo.isstab, "Positive text", LogTabPokemonDetails.Colors.text)
		local moveBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return string.format("%02d  %s", moveInfo.level, moveInfo.name) end,
			textColor = moveColor,
			moveId = moveInfo.id,
			tab = LogTabPokemonDetails.Tabs.LevelMoves,
			pageVisible = math.ceil(i / LogTabPokemonDetails.Pager.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY + Utils.inlineIf(hasEvo, 0, -2), 80, 11 },
			isVisible = function(self) return LogTabPokemonDetails.Pager.currentTab == self.tab and LogTabPokemonDetails.Pager.currentPage == self.pageVisible end,
			updateSelf = function(self)
				self.textColor = moveColor
				if Utils.isNilOrEmpty(LogSearchScreen.searchText) then
					return
				end
				-- Highlight moves that are found by the search
				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove then
					if Utils.containsText(moveInfo.name, LogSearchScreen.searchText, true) then
						self.textColor = LogTabPokemonDetails.Colors.highlight
					end
				end
			end,
			draw = function (self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local textColor = Theme.COLORS[self.textColor]
				local bgColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
				Drawing.drawTransparentTextbox(x + 1, y, self:getText(), textColor, bgColor, shadowcolor)

				if Options["Show physical special icons"] and MoveData.isValid(self.moveId) then
					local move = MoveData.Moves[self.moveId]
					local image
					if move.category == MoveData.Categories.PHYSICAL then
						image = Constants.PixelImages.PHYSICAL
					elseif move.category == MoveData.Categories.SPECIAL then
						image = Constants.PixelImages.SPECIAL
					end
					if image then
						Drawing.drawImageAsPixels(image, x + moveCategoryOffset, y + 2, { textColor }, shadowcolor)
					end
				end
			end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogTabPokemonDetails.Pager.Buttons, moveBtn)
		if i % LogTabPokemonDetails.Pager.movesPerPage == 0 then
			offsetY = 0
		else
			offsetY = offsetY + Constants.SCREEN.LINESPACING
		end
	end

	-- LEARNABLE TMS
	local sortGymsFirst = function(a, b) return (a.gymNum * 1000 + a.tm) < (b.gymNum * 1000 + b.tm) end
	table.sort(data.p.tmmoves, sortGymsFirst)

	-- Add a spacer to separate Gym TMs from regular TMs
	for i, tmInfo in ipairs(data.p.tmmoves) do
		if tmInfo.gymNum > 8 then
			if i ~= 1 then
				table.insert(data.p.tmmoves, i, { label = Resources.LogOverlay.LabelOtherTMs})
				table.insert(data.p.tmmoves, 1, { label = Resources.LogOverlay.LabelGymTMs})
				break
			else
				table.insert(data.p.tmmoves, 1, { label = Resources.LogOverlay.LabelOtherTMs})
				break
			end
		end
	end

	offsetY = 0
	for i, tmInfo in ipairs(data.p.tmmoves) do
		local moveText, moveColor
		if tmInfo.label ~= nil then
			moveText = tmInfo.label
			moveColor = LogTabPokemonDetails.Colors.highlight
		else
			moveText = string.format("TM%02d  %s", tmInfo.tm, tmInfo.moveName)
			if tmInfo.isstab then
				moveColor = "Positive text"
			else
				moveColor = LogTabPokemonDetails.Colors.text
			end
		end
		local moveBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return moveText end,
			textColor = moveColor,
			moveId = tmInfo.moveId,
			tab = LogTabPokemonDetails.Tabs.TmMoves,
			pageVisible = math.ceil(i / LogTabPokemonDetails.Pager.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY + Utils.inlineIf(hasEvo, 0, -2), 80, 11 },
			isVisible = function(self) return LogTabPokemonDetails.Pager.currentTab == self.tab and LogTabPokemonDetails.Pager.currentPage == self.pageVisible end,
			draw = function (self, shadowcolor)
				if Options["Show physical special icons"] and MoveData.isValid(self.moveId) then
					local move = MoveData.Moves[self.moveId]
					local image
					if move.category == MoveData.Categories.PHYSICAL then
						image = Constants.PixelImages.PHYSICAL
					elseif move.category == MoveData.Categories.SPECIAL then
						image = Constants.PixelImages.SPECIAL
					end
					if image then
						Drawing.drawImageAsPixels(image, self.box[1] + moveCategoryOffset, self.box[2] + 2, { Theme.COLORS[self.textColor] }, shadowcolor)
					end
				end
			end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogTabPokemonDetails.Pager.Buttons, moveBtn)
		if i % LogTabPokemonDetails.Pager.movesPerPage == 0 then
			offsetY = 0
		else
			offsetY = offsetY + Constants.SCREEN.LINESPACING
		end
	end

	-- UP/DOWN PAGING ARROWS
	local upArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.UP_ARROW,
		textColor = LogTabPokemonDetails.Colors.text,
		box = { movesColX + 107, movesRowY + 24 + Utils.inlineIf(hasEvo, 0, 10), 10, 10 },
		isVisible = function() return LogTabPokemonDetails.Pager.totalPages > 1 end,
		onClick = function(self) LogTabPokemonDetails.Pager:prevPage() end,
	}
	local downArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		textColor = LogTabPokemonDetails.Colors.text,
		box = { movesColX + 107, movesRowY + 81 + Utils.inlineIf(hasEvo, 0, 30), 10, 10 },
		isVisible = function() return LogTabPokemonDetails.Pager.totalPages > 1 end,
		onClick = function(self) LogTabPokemonDetails.Pager:nextPage() end,
	}
	table.insert(LogTabPokemonDetails.TemporaryButtons, upArrow)
	table.insert(LogTabPokemonDetails.TemporaryButtons, downArrow)

	LogTabPokemonDetails.Pager.totalLearnedMoves = #data.p.moves
	LogTabPokemonDetails.Pager.totalTMMoves = #data.p.tmmoves
	LogTabPokemonDetails.Pager:changeTab(LogTabPokemonDetails.Tabs.LevelMoves)
end

-- USER INPUT FUNCTIONS
function LogTabPokemonDetails.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabPokemonDetails.TemporaryButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabPokemonDetails.Pager.Buttons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabPokemonDetails.drawTab()
	local textColor = Theme.COLORS[LogTabPokemonDetails.Colors.text]
	local highlightColor = Theme.COLORS[LogTabPokemonDetails.Colors.highlight]
	local borderColor = Theme.COLORS[LogTabPokemonDetails.Colors.border]
	local fillColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	if not PokemonData.isValid(LogTabPokemonDetails.infoId or -1) then
		return
	end

	-- Ideally this is done only once on tab change
	local data = LogTabPokemonDetails.dataSet
	if data == nil then
		data = DataHelper.buildPokemonLogDisplay(LogTabPokemonDetails.infoId)
		LogTabPokemonDetails.dataSet = data
	end

	-- Draw all buttons
	for _, button in pairs(LogTabPokemonDetails.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabPokemonDetails.Pager.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Draw Pokemon name
	local nameText = Utils.toUpperUTF8(data.p.name)
	Drawing.drawTransparentTextbox(LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 2, nameText, highlightColor, fillColor, shadowcolor)

	-- data.p.helditems -- unused

	LogTabPokemonDetails.drawStatGraph(data, shadowcolor)
end

function LogTabPokemonDetails.drawStatGraph(data, shadowcolor)
	local textColor = Theme.COLORS[LogTabPokemonDetails.Colors.text]
	local borderColor = Theme.COLORS[LogTabPokemonDetails.Colors.border]
	local fillColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]

	local statBox = {
		x = LogOverlay.TabBox.x + 6,
		y = LogOverlay.TabBox.y + 53,
		width = 103,
		height = 68,
		barW = 8,
		labelW = 17,
	}

	-- Draw header for stat box
	local bstTotal = string.format("%s: %s", Resources.LogOverlay.LabelBSTTotal, data.p.bst)
	Drawing.drawTransparentTextbox(statBox.x, statBox.y - 11, Resources.LogOverlay.LabelBaseStats, textColor, fillColor, shadowcolor)
	Drawing.drawTransparentTextbox(statBox.x + statBox.width - 39, statBox.y - 11, bstTotal, textColor, fillColor, shadowcolor)

	-- Draw stat box
	gui.drawRectangle(statBox.x, statBox.y, statBox.width, statBox.height, borderColor, fillColor)
	local quarterMark = statBox.height/4
	gui.drawLine(statBox.x - 2, statBox.y, statBox.x, statBox.y, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y, statBox.x + statBox.width + 2, statBox.y, borderColor)
	gui.drawLine(statBox.x - 1, statBox.y + quarterMark * 1, statBox.x, statBox.y + quarterMark * 1, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + quarterMark * 1, statBox.x + statBox.width + 1, statBox.y + quarterMark * 1, borderColor)
	gui.drawLine(statBox.x - 2, statBox.y + quarterMark * 2, statBox.x, statBox.y + quarterMark * 2, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + quarterMark * 2, statBox.x + statBox.width + 2, statBox.y + quarterMark * 2, borderColor)
	gui.drawLine(statBox.x - 1, statBox.y + quarterMark * 3, statBox.x, statBox.y + quarterMark * 3, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + quarterMark * 3, statBox.x + statBox.width + 1, statBox.y + quarterMark * 3, borderColor)
	gui.drawLine(statBox.x - 2, statBox.y + statBox.height, statBox.x, statBox.y + statBox.height, borderColor)
	gui.drawLine(statBox.x + statBox.width, statBox.y + statBox.height, statBox.x + statBox.width + 2, statBox.y + statBox.height, borderColor)

	local statX = statBox.x + 1
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		-- Draw the vertical bar
		local barH = math.floor(data.p[statKey] / 255 * (statBox.height - 2) + 0.5)
		local barY = statBox.y + statBox.height - barH - 1 -- -1/-2 for box pixel border margin
		local barColor
		if data.p[statKey] >= 180 then -- top ~70%
			barColor = Theme.COLORS["Positive text"]
		elseif data.p[statKey] <= 40 then -- bottom ~15%
			barColor = Theme.COLORS["Negative text"]
		else
			barColor = textColor
		end
		gui.drawRectangle(statX + (statBox.labelW - statBox.barW) / 2, barY, statBox.barW, barH, barColor, barColor)
		if data.x.extras.bumps[statKey] then
			gui.drawPixel(statX + statBox.labelW / 2, statBox.y + statBox.height + 1, borderColor)
		end

		-- Draw the bar's label
		local statLabelOffsetX = (3 - string.len(statKey)) * 2
		local statValueOffsetX = (3 - string.len(tostring(data.p[statKey]))) * 2
		Drawing.drawText(statX + statLabelOffsetX, statBox.y + statBox.height + 1, Utils.firstToUpper(statKey), textColor, shadowcolor)
		Drawing.drawText(statX + statValueOffsetX, statBox.y + statBox.height + 11, data.p[statKey], barColor, shadowcolor)
		statX = statX + statBox.labelW
	end
end
LogTabPokemonDetails = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		hightlight = "Intermediate text",
	},
	Tabs = {
		LevelMoves = 1,
		TmMoves = 2,
	},
	currentPreEvoSet = 1,
	currentEvoSet = 1, -- Ideally move this somewhere else
	prevEvosPerSet = 1,
	evosPerSet = 3, -- Ideally move this somewhere else
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

		if newTab == LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES then
			self.totalPages = math.ceil(self.totalLearnedMoves / self.movesPerPage)
		elseif newTab == LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES then
			self.totalPages = math.ceil(self.totalTMMoves / self.movesPerPage)
		else -- Currently unused
			self.totalPages = 1
		end
		LogOverlay.refreshInnerButtons()
	end,
}

function LogTabPokemonDetails.initialize()
	LogTabPokemonDetails.currentPreEvoSet = 1
	LogTabPokemonDetails.currentEvoSet = 1 -- Ideally move this somewhere else
	LogTabPokemonDetails.prevEvosPerSet = 1
	LogTabPokemonDetails.evosPerSet = 3 -- Ideally move this somewhere else

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

function LogTabPokemonDetails.buildPagedButtons()
	LogTabPokemonDetails.PagedButtons = {}

	-- Determine gym TMs for the game, they'll be highlighted
	local gymTMs = {}
	for i, gymTM in ipairs(TrainerData.GymTMs) do
		gymTMs[gymTM.number] = {
			leader = gymTM.leader,
			gymNumber = i,
			trainerId = nil, -- this gets added in later
		}
	end

	-- Build Trainer buttons
	for id, trainerData in pairs(RandomizerLog.Data.Trainers) do
		local trainerInfo = TrainerData.getTrainerInfo(id)
		local trainerName = Utils.inlineIf(trainerInfo.name ~= "Unknown", trainerInfo.name, trainerData.name)
		local fileInfo = TrainerData.FileInfo[trainerInfo.filename] or { width = 40, height = 40 }
		local button = {
			type = Constants.ButtonTypes.IMAGE,
			image = FileManager.buildImagePath(FileManager.Folders.Trainers, trainerInfo.filename, FileManager.Extensions.TRAINER),
			getText = function(self) return trainerName end,
			id = id,
			customname = trainerData.customname,
			filename = trainerInfo.filename, -- helpful for sorting later
			dimensions = { width = fileInfo.width, height = fileInfo.height, extraX = fileInfo.offsetX, extraY = fileInfo.offsetY, },
			group = trainerInfo.group,
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				-- Always exclude extra rivals
				if trainerInfo.whichRival ~= nil and Tracker.Data.whichRival ~= nil and Tracker.Data.whichRival ~= trainerInfo.whichRival then
					return false
				end

				-- If no search text entered, check any filter groups
				if LogSearchScreen.searchText == "" then
					if LogOverlay.Windower.filterGrid == self.group then
						return true
					elseif LogOverlay.Windower.filterGrid == TrainerData.TrainerGroups.All then
						return true
					end
					return false
				end

				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.TrainerName then
					if Utils.containsText(self:getText(), LogSearchScreen.searchText, true) then
						return true
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName then
					for _, partyMon in ipairs(trainerData.party or {}) do
						local name
						-- When languages don't match, there's no way to tell if the name in the log is a custom name or not, assume it's not
						if RandomizerLog.areLanguagesMismatched() then
							name = PokemonData.Pokemon[partyMon.pokemonID].name or Constants.BLANKLINE
						else
							name = RandomizerLog.Data.Pokemon[partyMon.pokemonID].Name or PokemonData.Pokemon[partyMon.pokemonID].name or Constants.BLANKLINE
						end
						if Utils.containsText(name, LogSearchScreen.searchText, true) then
							return true
						end
					end
				elseif LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonAbility then
					for _, partyMon in ipairs(trainerData.party or {}) do
						for _, abilityId in pairs(RandomizerLog.Data.Pokemon[partyMon.pokemonID].Abilities or {}) do
							local abilityText = AbilityData.Abilities[abilityId].name
							if Utils.containsText(abilityText, LogSearchScreen.searchText, true) then
								return true
							end
						end
					end
				end

				return false
			end,
			onClick = function(self)
				LogOverlay.Windower:changeTab(LogOverlay.Tabs.TRAINER_ZOOM, 1, 1, self.id)
				Program.redraw(true)
				-- InfoScreen.changeScreenView(InfoScreen.Screens.TRAINER_INFO, self.id) -- TODO: (future feature) implied redraw
			end,
			draw = function(self, shadowcolor)
				-- Draw a centered box for the Trainer's name
				local nameWidth = Utils.calcWordPixelLength(self:getText())
				local bottomPadding = 9
				local offsetX = self.box[1] + self.box[3] / 2 - nameWidth / 2
				local offsetY = self.box[2] + TrainerData.FileInfo.maxHeight - bottomPadding - (self.dimensions.extraY or 0)
				gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabPokemonDetails.Colors.border], Theme.COLORS[LogTabPokemonDetails.Colors.boxFill])
				Drawing.drawText(offsetX, offsetY, self:getText(), Theme.COLORS[LogTabPokemonDetails.Colors.text], shadowcolor)
				gui.drawRectangle(offsetX - 1, offsetY, nameWidth + 5, bottomPadding + 2, Theme.COLORS[LogTabPokemonDetails.Colors.border]) -- to cutoff the shadows
			end,
		}

		if trainerInfo ~= nil and trainerInfo.group == TrainerData.TrainerGroups.Gym then
			local gymNumber = tonumber(trainerInfo.filename:sub(-1)) -- e.g. "frlg-gymleader-1"
			if gymNumber ~= nil then
				-- Find the gym leader's TM and add it's trainer id to that tm info
				for _, gymTMInfo in pairs(gymTMs) do
					if gymTMInfo.gymNumber == gymNumber then
						gymTMInfo.trainerId = id
						break
					end
				end
			end
		end

		table.insert(LogTabPokemonDetails.PagedButtons, button)
	end

	return gymTMs
end

function LogTabPokemonDetails.buildZoomButtons(data)
	LogTabPokemonDetails.TemporaryButtons = {}
	LogTabPokemonDetails.Pager.Buttons = {}

	LogTabPokemonDetails.currentPreEvoSet = 1
	LogTabPokemonDetails.currentEvoSet = 1

	if data.p.abilities[1] == data.p.abilities[2] then
		data.p.abilities[2] = nil
	end

	local abilityButtonArea ={
		x = LogOverlay.margin + 1,
		y = LogOverlay.tabHeight + 13,
		w = 60,
		h = Constants.SCREEN.LINESPACING*2
	}

	-- ABILITIES
	local offsetY = 0
	for i, abilityId in ipairs(data.p.abilities) do
		local btnText
		if AbilityData.isValid(abilityId) then
			btnText = string.format("%s: %s", i, AbilityData.Abilities[abilityId].name)
		else
			btnText = Constants.BLANKLINE
		end
		local abilityBtn = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return btnText end,
			textColor = LogTabPokemonDetails.Colors.text,
			abilityId = abilityId,
			box = { abilityButtonArea.x, abilityButtonArea.y + offsetY, 60, 11 },
			onClick = function(self)
				if AbilityData.isValid(abilityId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, self.abilityId) -- implied redraw
				end
			end,
		}
		table.insert(LogTabPokemonDetails.TemporaryButtons, abilityBtn)
		offsetY = offsetY + Constants.SCREEN.LINESPACING
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
		x = LogOverlay.margin + 75,
		y = LogOverlay.tabHeight - 2,
		w = function(self) return Constants.SCREEN.WIDTH - self.x - LogOverlay.margin - 1 end,
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
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
			end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
				end
			end,
			draw = function(self, shadowcolor)
				local evoTextSize = Utils.calcWordPixelLength(evoText or "")
				-- Center text
				local centeringOffsetX = math.max(self.box[3] / 2 - evoTextSize / 2, 0)
				local textX = self.box[1] + centeringOffsetX + pokemonIconSize + pokemonIconSpacing + evoArrowSize
				local textY = self.box[2] + self.box[4] + 2
				Drawing.drawText(textX, textY, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
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
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		onClick = function(self)
			if PokemonData.isValid(self.pokemonID) then
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
			end
		end,
		draw = function(self)
			if Options["Show Pre Evolutions"] and hasEvo then
				Drawing.drawSelectionIndicators(
					self.box[1],
					self.box[2] - 1 + evoLabelTextHeight,
					pokemonIconSize - 1,
					pokemonIconSize - 4,
					Theme.COLORS[LogTabPokemonDetails.Colors.hightlight],
					1,
					5,
					1
				)
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
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
			end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogOverlay.Tabs.POKEMON_ZOOM, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
				end
			end,
			draw = function(self, shadowcolor)
				local evoTextSize = Utils.calcWordPixelLength(evo.method or "")
				-- Center text
				local centeringOffsetX = math.max(self.box[3] / 2 - evoTextSize / 2, 0)
				Drawing.drawText(self.box[1] + centeringOffsetX, self.box[2] + self.box[4] + 2, self:getText(),
					Theme.COLORS[self.textColor], shadowcolor)
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

	local movesColX = LogOverlay.margin + 118
	local movesRowY = LogOverlay.tabHeight + Utils.inlineIf(hasEvo, 42, 0)
	LogTabPokemonDetails.Pager.movesPerPage = Utils.inlineIf(hasEvo, 8, 12)

	local levelupMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.ButtonLevelupMoves end,
		textColor = LogTabPokemonDetails.Colors.text,
		tab = LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
		box = { movesColX, movesRowY, 60, 11 },
		updateSelf = function(self)
			if LogTabPokemonDetails.Pager.currentTab == self.tab then
				self.textColor = LogTabPokemonDetails.Colors.hightlight
			else
				self.textColor = LogTabPokemonDetails.Colors.text
			end
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == LogTabPokemonDetails.Colors.hightlight then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogTabPokemonDetails.Pager.currentTab ~= self.tab then
				LogTabPokemonDetails.Pager:changeTab(self.tab)
				Program.redraw(true)
			end
		end,
	}
	local tmMovesTab = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Resources.LogOverlay.ButtonTMMoves end,
		textColor = LogTabPokemonDetails.Colors.text,
		tab = LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
		box = { movesColX + 70, movesRowY, 41, 11 },
		updateSelf = function(self)
			if LogTabPokemonDetails.Pager.currentTab == self.tab then
				self.textColor = LogTabPokemonDetails.Colors.hightlight
			else
				self.textColor = LogTabPokemonDetails.Colors.text
			end
		end,
		draw = function(self)
			-- Draw an underline if selected
			if self.textColor == LogTabPokemonDetails.Colors.hightlight then
				local x1, x2 = self.box[1] + 2, self.box[1] + self.box[3] - 1
				local y1, y2 = self.box[2] + self.box[4] - 1, self.box[2] + self.box[4] - 1
				gui.drawLine(x1, y1, x2, y2, Theme.COLORS[self.textColor])
			end
		end,
		onClick = function(self)
			if LogTabPokemonDetails.Pager.currentTab ~= self.tab then
				LogTabPokemonDetails.Pager:changeTab(self.tab)
				Program.redraw(true)
			end
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
			tab = LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES,
			pageVisible = math.ceil(i / LogTabPokemonDetails.Pager.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY + Utils.inlineIf(hasEvo, 0, -2), 80, 11 },
			isVisible = function(self) return LogTabPokemonDetails.Pager.currentTab == self.tab and LogTabPokemonDetails.Pager.currentPage == self.pageVisible end,
			updateSelf = function(self)
				self.textColor = moveColor
				-- Highlight moves that are found by the search
				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove and LogSearchScreen.searchText ~= "" then
					if Utils.containsText(moveInfo.name, LogSearchScreen.searchText, true) then
						self.textColor = LogTabPokemonDetails.Colors.hightlight
					end
				end
			end,
			draw = function (self, shadowcolor)
				if Options["Show physical special icons"] and MoveData.isValid(self.moveId) then
					local move = MoveData.Moves[self.moveId]
					local categoryImage
					if move.category == MoveData.Categories.PHYSICAL then
						categoryImage = Constants.PixelImages.PHYSICAL
					elseif move.category == MoveData.Categories.SPECIAL then
						categoryImage = Constants.PixelImages.SPECIAL
					end
					if categoryImage then
						Drawing.drawImageAsPixels(categoryImage, self.box[1] + moveCategoryOffset, self.box[2] + 2, { Theme.COLORS[self.textColor] }, shadowcolor)
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
			moveColor = LogTabPokemonDetails.Colors.hightlight
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
			tab = LogOverlay.Tabs.POKEMON_ZOOM_TMMOVES,
			pageVisible = math.ceil(i / LogTabPokemonDetails.Pager.movesPerPage),
			box = { movesColX, movesRowY + 13 + offsetY + Utils.inlineIf(hasEvo, 0, -2), 80, 11 },
			isVisible = function(self) return LogTabPokemonDetails.Pager.currentTab == self.tab and LogTabPokemonDetails.Pager.currentPage == self.pageVisible end,
			draw = function (self, shadowcolor)
				if Options["Show physical special icons"] and MoveData.isValid(self.moveId) then
					local move = MoveData.Moves[self.moveId]
					if move.category == MoveData.Categories.PHYSICAL then
						Drawing.drawImageAsPixels(Constants.PixelImages.PHYSICAL, self.box[1] + moveCategoryOffset, self.box[2] + 2, { Theme.COLORS[self.textColor] }, shadowcolor)
					elseif move.category == MoveData.Categories.SPECIAL then
						Drawing.drawImageAsPixels(Constants.PixelImages.SPECIAL, self.box[1] + moveCategoryOffset, self.box[2] + 2, { Theme.COLORS[self.textColor] }, shadowcolor)
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
		textColor = "Lower box text",
		box = { movesColX + 107, movesRowY + 24 + Utils.inlineIf(hasEvo, 0, 10), 10, 10 },
		isVisible = function() return LogTabPokemonDetails.Pager.totalPages > 1 end,
		onClick = function(self)
			LogTabPokemonDetails.Pager:prevPage()
			Program.redraw(true)
		end,
	}
	local downArrow = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DOWN_ARROW,
		textColor = "Lower box text",
		box = { movesColX + 107, movesRowY + 81 + Utils.inlineIf(hasEvo, 0, 30), 10, 10 },
		isVisible = function() return LogTabPokemonDetails.Pager.totalPages > 1 end,
		onClick = function(self)
			LogTabPokemonDetails.Pager:nextPage()
			Program.redraw(true)
		end,
	}
	table.insert(LogTabPokemonDetails.TemporaryButtons, upArrow)
	table.insert(LogTabPokemonDetails.TemporaryButtons, downArrow)

	LogTabPokemonDetails.Pager.totalLearnedMoves = #data.p.moves
	LogTabPokemonDetails.Pager.totalTMMoves = #data.p.tmmoves
	LogTabPokemonDetails.Pager:changeTab(LogOverlay.Tabs.POKEMON_ZOOM_LEVELMOVES)
end

-- USER INPUT FUNCTIONS
function LogTabPokemonDetails.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabPokemonDetails.TemporaryButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabPokemonDetails.Pager.Buttons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabPokemonDetails.drawTab()
	local textColor = Theme.COLORS[LogTabPokemonDetails.Colors.text]
	local highlightColor = Theme.COLORS[LogTabPokemonDetails.Colors.hightlight]
	local borderColor = Theme.COLORS[LogTabPokemonDetails.Colors.border]
	local fillColor = Theme.COLORS[LogTabPokemonDetails.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	local pokemonID = LogOverlay.currentTabInfoId
	if not PokemonData.isValid(pokemonID) then
		return
	end

	-- Ideally this is done only once on tab change
	if LogOverlay.currentTabData == nil then
		LogOverlay.currentTabData = DataHelper.buildPokemonLogDisplay(pokemonID)
	end
	local data = LogOverlay.currentTabData

	-- Draw Pokemon name
	local nameText = Utils.toUpperUTF8(data.p.name)
	Drawing.drawText(LogOverlay.TabBox.x + 3, LogOverlay.TabBox.y + 2, nameText, highlightColor, shadowcolor)

	-- data.p.helditems -- unused

	LogTabPokemonDetails.drawStatGraph(data.p, shadowcolor)

	-- Draw all buttons
	for _, button in pairs(LogTabPokemonDetails.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabPokemonDetails.Pager.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end

function LogTabPokemonDetails.drawStatGraph(pokemonData, shadowcolor)
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
	local bstTotal = string.format("%s: %s", Resources.LogOverlay.LabelBSTTotal, pokemonData.bst)
	Drawing.drawText(statBox.x, statBox.y - 11, Resources.LogOverlay.LabelBaseStats, textColor, shadowcolor)
	Drawing.drawText(statBox.x + statBox.width - 39, statBox.y - 11, bstTotal, textColor, shadowcolor)

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
		local barH = math.floor(pokemonData[statKey] / 255 * (statBox.height - 2) + 0.5)
		local barY = statBox.y + statBox.height - barH - 1 -- -1/-2 for box pixel border margin
		local barColor
		if pokemonData[statKey] >= 180 then -- top ~70%
			barColor = Theme.COLORS["Positive text"]
		elseif pokemonData[statKey] <= 40 then -- bottom ~15%
			barColor = Theme.COLORS["Negative text"]
		else
			barColor = textColor
		end
		gui.drawRectangle(statX + (statBox.labelW - statBox.barW) / 2, barY, statBox.barW, barH, barColor, barColor)

		-- Draw the bar's label
		local statLabelOffsetX = (3 - string.len(statKey)) * 2
		local statValueOffsetX = (3 - string.len(tostring(pokemonData[statKey]))) * 2
		Drawing.drawText(statX + statLabelOffsetX, statBox.y + statBox.height + 1, Utils.firstToUpper(statKey), textColor, shadowcolor)
		Drawing.drawText(statX + statValueOffsetX, statBox.y + statBox.height + 11, pokemonData[statKey], barColor, shadowcolor)
		statX = statX + statBox.labelW
	end
end
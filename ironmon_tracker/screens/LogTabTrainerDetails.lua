LogTabTrainerDetails = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		hightlight = "Intermediate text",
	},
	infoId = -1,
	dataSet = nil,
}

LogTabTrainerDetails.TemporaryButtons = {}

function LogTabTrainerDetails.initialize()

end

function LogTabTrainerDetails.refreshButtons()
	for _, button in pairs(LogTabTrainerDetails.TemporaryButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabTrainerDetails.rebuild()
	LogTabTrainerDetails.buildZoomButtons()
end

function LogTabTrainerDetails.buildZoomButtons(trainerId)
	trainerId = trainerId or LogTabTrainerDetails.infoId or -1
	local data = DataHelper.buildTrainerLogDisplay(trainerId)
	LogTabTrainerDetails.infoId = trainerId
	LogTabTrainerDetails.dataSet = data

	LogTabTrainerDetails.TemporaryButtons = {}

	local partyListX, partyListY = LogOverlay.TabBox.x + 1, LogOverlay.TabBox.y + 82
	local startX, startY = LogOverlay.TabBox.x + 60, LogOverlay.TabBox.y + 2
	local offsetX, offsetY = 0, 0
	local colOffset, rowOffset = 86, 49 -- 2nd column, and 2nd/3rd rows

	for i, partyPokemon in ipairs(data.p or {}) do
		-- PARTY POKEMON
		local pokemonNameButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return string.format("%s. %s", i, partyPokemon.name) end, -- e.g. "1. Shuckle"
			textColor = LogTabTrainerDetails.Colors.text,
			pokemonID = partyPokemon.id,
			box = { partyListX, partyListY, 60, 11 },
			updateSelf = function(self)
				self.textColor = LogTabTrainerDetails.Colors.text
				-- Highlight moves that are found by the search
				if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonName and LogSearchScreen.searchText ~= "" then
					if Utils.containsText(partyPokemon.name, LogSearchScreen.searchText, true) then
						self.textColor = LogTabTrainerDetails.Colors.hightlight
					end
				end
			end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end
			end,
		}
		partyListY = partyListY + Constants.SCREEN.LINESPACING - 1

		local pokemonIconButton = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getText = function(self) return string.format("%s.%s", Resources.TrackerScreen.LevelAbbreviation, partyPokemon.level) end,
			pokemonID = partyPokemon.id,
			textColor = LogTabTrainerDetails.Colors.text,
			clickableArea = { startX + offsetX, startY + offsetY, 32, 29, },
			box = { startX + offsetX, startY + offsetY - 4, 32, 32, },
			getIconPath = function(self)
				local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
				return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
			end,
			onClick = function(self)
				if PokemonData.isValid(self.pokemonID) then
					LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, self.pokemonID)
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID) -- implied redraw
				end
			end,
			draw = function(self, shadowcolor)
				-- Draw the Pokemon's level below the icon
				local levelOffsetX = self.box[1] + 5
				local levelOffsetY = self.box[2] + self.box[4] + 2
				Drawing.drawText(levelOffsetX, levelOffsetY, self:getText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
		}
		table.insert(LogTabTrainerDetails.TemporaryButtons, pokemonNameButton)
		table.insert(LogTabTrainerDetails.TemporaryButtons, pokemonIconButton)

		-- helditem = partyMon.helditem ???

		-- PARTY POKEMON's MOVES
		local moveOffsetX = startX + offsetX + 30
		local moveOffsetY = startY + offsetY
		for _, moveInfo in ipairs(partyPokemon.moves or {}) do
			local moveColor = Utils.inlineIf(moveInfo.isstab, "Positive text", LogTabTrainerDetails.Colors.text)
			local moveBtn = {
				type = Constants.ButtonTypes.NO_BORDER,
				getText = function(self) return moveInfo.name end,
				textColor = moveColor,
				moveId = moveInfo.moveId,
				box = { moveOffsetX, moveOffsetY, 60, 11 },
				updateSelf = function(self)
					self.textColor = moveColor
					-- Highlight moves that are found by the search
					if LogSearchScreen.currentFilter == LogSearchScreen.FilterBy.PokemonMove and LogSearchScreen.searchText ~= "" then
						if Utils.containsText(moveInfo.name, LogSearchScreen.searchText, true) then
							self.textColor = LogTabTrainerDetails.Colors.hightlight
						end
					end
				end,
				onClick = function(self)
					if MoveData.isValid(self.moveId) then
						InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
					end
				end,
			}
			table.insert(LogTabTrainerDetails.TemporaryButtons, moveBtn)
			moveOffsetY = moveOffsetY + Constants.SCREEN.LINESPACING - 1
		end

		if i % 2 == 1 then
			offsetX = offsetX + colOffset
		else
			offsetX = 0
			offsetY = offsetY + rowOffset
		end
	end

	LogTabTrainerDetails.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabTrainerDetails.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTrainerDetails.TemporaryButtons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabTrainerDetails.drawTab()
	local textColor = Theme.COLORS[LogTabTrainerDetails.Colors.text]
	local highlightColor = Theme.COLORS[LogTabTrainerDetails.Colors.hightlight]
	local borderColor = Theme.COLORS[LogTabTrainerDetails.Colors.border]
	local fillColor = Theme.COLORS[LogTabTrainerDetails.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	if RandomizerLog.Data.Trainers[LogTabTrainerDetails.infoId or -1] == nil then
		return
	end

	-- Ideally this is done only once on tab change
	local data = LogTabTrainerDetails.dataSet
	if data == nil then
		data = DataHelper.buildTrainerLogDisplay(LogTabTrainerDetails.infoId)
		LogTabTrainerDetails.dataSet = data
	end

	-- GYM LEADER BADGE
	if data.x.gymNumber ~= nil then
		local badgeName = GameSettings.badgePrefix .. "_badge" .. data.x.gymNumber
		local badgeImage = FileManager.buildImagePath(FileManager.Folders.Badges, badgeName, FileManager.Extensions.BADGE)
		gui.drawImage(badgeImage, LogOverlay.TabBox.x + 44, LogOverlay.TabBox.y + 2)
	end

	-- TRAINER NAME & ICON
	gui.drawImage(data.t.filename, LogOverlay.TabBox.x, LogOverlay.TabBox.y + 20)
	Drawing.drawText(LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 1, Utils.toUpperUTF8(data.t.class), highlightColor, shadowcolor)
	Drawing.drawText(LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 10, Utils.toUpperUTF8(data.t.name), highlightColor, shadowcolor)

	-- Draw all buttons
	for _, button in pairs(LogTabTrainerDetails.TemporaryButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
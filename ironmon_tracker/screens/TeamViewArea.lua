-- Displays the player's full team of six Pokémon below the gameplay/Tracker screen, in an expanded drawing space
TeamViewArea = {
	Labels = {},
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Canvas = {
		x = 0,
		y = Constants.SCREEN.HEIGHT,
		width = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP,
		height = Constants.SCREEN.BOTTOM_AREA,
		margin = 2, -- Currently unused
		fill = Theme.COLORS["Main background"],
	},
}

-- Created later in TeamViewArea.buildOutButtons()
TeamViewArea.PartyPokemon = {}

function TeamViewArea.initialize()
	TeamViewArea.refreshDisplayPadding()
end

function TeamViewArea.isDisplayed()
	return Options["Show Team View"]
end

function TeamViewArea.refreshDisplayPadding()
	if not Main.IsOnBizhawk() then return end
	local bottomAreaPadding = Utils.inlineIf(TeamViewArea.isDisplayed(), Constants.SCREEN.BOTTOM_AREA, Constants.SCREEN.DOWN_GAP)
	client.SetGameExtraPadding(0, Constants.SCREEN.UP_GAP, Constants.SCREEN.RIGHT_GAP, bottomAreaPadding)
end

function TeamViewArea.buildOutPartyScreen()
	if not TeamViewArea.isDisplayed() then return end

	TeamViewArea.PartyPokemon = {}

	local nextBoxX = TeamViewArea.Canvas.x
	local nextBoxY = TeamViewArea.Canvas.y
	local boxWidth = math.floor(TeamViewArea.Canvas.width / 6)
	local boxHeight = TeamViewArea.Canvas.height - 1
	for i=1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, true)
		if pokemon ~= nil and PokemonData.isValid(pokemon.pokemonID) then
			local partyMember = TeamViewArea.createPartyMemberBox(pokemon, nextBoxX, nextBoxY, boxWidth, boxHeight)
			if partyMember ~= nil then
				table.insert(TeamViewArea.PartyPokemon, partyMember)
				nextBoxX = nextBoxX + partyMember.width
			end
		end
	end
end

function TeamViewArea.createPartyMemberBox(pokemon, x, y, width, height)
	local barHeight = 3
	local colOffset = 34
	local finalboxOffset = Utils.inlineIf(x + width == Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, -1, 0)

	local partyMember = {
		x = x,
		y = y,
		width = width,
		height = height,
		Buttons = {},
		updateSelf = function(self)
			-- Update colors
			self.text = Theme.COLORS["Default text"]
			self.border = Theme.COLORS["Upper box border"]
			self.fill = Theme.COLORS["Upper box background"]
			self.shadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
			for _, button in pairs(self.Buttons) do
				button.textColor = "Default text"
				button.boxColors = { "Upper box border", "Upper box background" }
			end
		end,
		draw = function(self)
			self:updateSelf()
			gui.drawRectangle(self.x, self.y, self.width + finalboxOffset, self.height, self.border, self.fill)
			local yOffset = self.y

			-- Draw all the clickable buttons
			for _, button in pairs(self.Buttons) do
				Drawing.drawButton(button, self.shadow)
			end

			-- Pokemon's Nickname
			Drawing.drawText(self.x + 1, yOffset, pokemon.nickname, self.text, self.shadow)
			yOffset = yOffset + Constants.SCREEN.LINESPACING - 1

			-- Pokemon's Status (if any)
			local status = MiscData.StatusCodeMap[pokemon.status] or ""
			if pokemon.curHP <= 0 then
				Drawing.drawStatusIcon(MiscData.StatusCodeMap[MiscData.StatusType.Faint], self.x + 16, yOffset + 1)
			elseif status ~= MiscData.StatusCodeMap[MiscData.StatusType.None] then
				Drawing.drawStatusIcon(status, self.x + 16, yOffset + 1)
			end

			-- Pokemon Types
			yOffset = yOffset + 2
			local types = PokemonData.Pokemon[pokemon.pokemonID].types
			Drawing.drawTypeIcon(types[1], self.x + colOffset, yOffset)
			yOffset = yOffset + 12
			if types[2] ~= types[1] then
				Drawing.drawTypeIcon(types[2], self.x + colOffset, yOffset)
			end
			yOffset = yOffset + 13

			-- Pokemon LevelPattern
			local levelText = string.format("Lv.%s", pokemon.level or 0)
			Drawing.drawText(self.x + 1, yOffset, levelText, self.text, self.shadow)
			yOffset = yOffset + 2

			-- Pokemon HP Bar
			local hpPercentage = (pokemon.curHP or 0) / (pokemon.stats.hp or 100)
			local hpBarColors = { Theme.COLORS["Positive text"], self.border, self.fill }
			if hpPercentage >= 0.50 then
				hpBarColors[1] = Theme.COLORS["Positive text"]
			elseif hpPercentage >= 0.20 then
				hpBarColors[1] = Theme.COLORS["Intermediate text"]
			else
				hpBarColors[1] = Theme.COLORS["Negative text"]
			end
			Drawing.drawPercentageBar(self.x + colOffset, yOffset, self.width - colOffset - 2, barHeight, hpPercentage, hpBarColors)
			yOffset = yOffset + barHeight + 0

			-- Pokemon EXP Bar
			local expPercentage = (pokemon.currentExp or 0) / (pokemon.totalExp or 100)
			local expBarColors = { self.text, self.border, self.fill }
			Drawing.drawPercentageBar(self.x + colOffset, yOffset, self.width - colOffset - 2, barHeight, expPercentage, expBarColors)
			yOffset = yOffset + barHeight + 2
		end,
	}

	local yOffset = y + Constants.SCREEN.LINESPACING
	local iconBtn = {
		pokemonID = pokemon.pokemonID,
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconPath = function(self)
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			return FileManager.buildImagePath(iconset.folder, tostring(self.pokemonID), iconset.extension)
		end,
		clickableArea = { x + 1, yOffset, 32, 27 },
		box = { x + 1, yOffset - 7, 32, 32 },
		onClick = function(self)
			if PokemonData.isValid(self.pokemonID) then
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.pokemonID)
			end
		end
	}
	table.insert(partyMember.Buttons, iconBtn)

	local typeDefensesBtn = {
		-- Invisible button area for the type defenses boxes
		pokemonID = pokemon.pokemonID,
		type = Constants.ButtonTypes.NO_BORDER,
		box = { x + colOffset, yOffset, 30, 24, },
		onClick = function (self)
			if PokemonData.isValid(self.pokemonID) then
				TypeDefensesScreen.buildOutPagedButtons(self.pokemonID)
				Program.changeScreenView(TypeDefensesScreen)
			end
		end,
	}
	table.insert(partyMember.Buttons, typeDefensesBtn)

	-- Pokemon Item
	yOffset = yOffset + Constants.SCREEN.LINESPACING + 25
	local itemBtn = {
		text = MiscData.Items[pokemon.heldItem or 0] or Constants.BLANKLINE,
		itemId = pokemon.heldItem or 0,
		type = Constants.ButtonTypes.NO_BORDER,
		box = { x, yOffset, partyMember.width - 2, Constants.SCREEN.LINESPACING, },
		onClick = function (self)
			-- Implement sometime in the future
			-- if self.itemId ~= nil and self.itemId ~= 0 then
			-- 	InfoScreen.changeScreenView(InfoScreen.Screens.ITEM_INFO, self.itemId)
			-- end
		end,
	}
	table.insert(partyMember.Buttons, itemBtn)

	-- Pokemon Ability
	yOffset = yOffset + Constants.SCREEN.LINESPACING - 1
	local abilityText
	local abilityId = PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
	if abilityId ~= nil and abilityId ~= 0 then
		abilityText = AbilityData.Abilities[abilityId].name
	else
		abilityText = Constants.BLANKLINE
	end
	local abilityBtn = {
		text = abilityText,
		abilityId = abilityId,
		type = Constants.ButtonTypes.NO_BORDER,
		box = { x, yOffset, partyMember.width - 2, Constants.SCREEN.LINESPACING, },
		onClick = function (self)
			if self.abilityId ~= nil and self.abilityId ~= 0 then
				InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, self.abilityId)
			end
		end,
	}
	table.insert(partyMember.Buttons, abilityBtn)

	return partyMember
end

-- USER INPUT FUNCTIONS
function TeamViewArea.checkInput(xmouse, ymouse)
	if not TeamViewArea.isDisplayed() then return end

	for _, partyMember in ipairs(TeamViewArea.PartyPokemon) do
		if partyMember.Buttons ~= nil then
			Input.checkButtonsClicked(xmouse, ymouse, partyMember.Buttons)
		end
	end
end

-- DRAWING FUNCTIONS
function TeamViewArea.drawScreen()
	if not TeamViewArea.isDisplayed() then return end

	gui.drawRectangle(TeamViewArea.Canvas.x, TeamViewArea.Canvas.y, TeamViewArea.Canvas.width, TeamViewArea.Canvas.height, TeamViewArea.Canvas.fill, TeamViewArea.Canvas.fill)

	for _, partyMember in ipairs(TeamViewArea.PartyPokemon) do
		if type(partyMember.draw) == "function" then
			partyMember:draw()
		end
	end
end

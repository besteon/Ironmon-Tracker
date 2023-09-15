RandomEvosScreen = {
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	pokemonID = nil,
	evoOptions = {},
	evoOptionIndex = 1,
}

RandomEvosScreen.Buttons = {
	PreviousEvoOption = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 18, Constants.SCREEN.MARGIN + 4, 10, 10, },
		isVisible = function() return #(RandomEvosScreen.evoOptions or {}) > 0 end,
		onClick = function(self)
			local total = #RandomEvosScreen.evoOptions
			RandomEvosScreen.evoOptionIndex = ((RandomEvosScreen.evoOptionIndex - 2 + total) % total) + 1
			RandomEvosScreen.buildPagedButtons(RandomEvosScreen.pokemonID, RandomEvosScreen.evoOptionIndex)
			Program.redraw(true)
		end
	},
	NextEvoOption = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 4, 10, 10, },
		isVisible = function() return #(RandomEvosScreen.evoOptions or {}) > 0 end,
		onClick = function(self)
			local total = #RandomEvosScreen.evoOptions
			RandomEvosScreen.evoOptionIndex = (RandomEvosScreen.evoOptionIndex % total) + 1
			RandomEvosScreen.buildPagedButtons(RandomEvosScreen.pokemonID, RandomEvosScreen.evoOptionIndex)
			Program.redraw(true)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return RandomEvosScreen.Pager:getPageText() end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 136, 50, 10, },
		isVisible = function() return RandomEvosScreen.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return RandomEvosScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			RandomEvosScreen.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 137, 10, 10, },
		isVisible = function() return RandomEvosScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			RandomEvosScreen.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		RandomEvosScreen.pokemonID = nil
		if InfoScreen.infoLookup == nil or InfoScreen.infoLookup == 0 then
			Program.changeScreenView(TrackerScreen)
		else
			Program.changeScreenView(InfoScreen)
		end
	end),
}

RandomEvosScreen.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.ordinal < b.ordinal end,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, false, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		return string.format("%s %s/%s", Resources.AllScreens.Page, self.currentPage, self.totalPages)
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

function RandomEvosScreen.initialize()
	for _, button in pairs(RandomEvosScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = RandomEvosScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { RandomEvosScreen.Colors.border, RandomEvosScreen.Colors.boxFill }
		end
	end
	RandomEvosScreen.refreshButtons()
end

function RandomEvosScreen.refreshButtons()
	for _, button in pairs(RandomEvosScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
	for _, button in pairs(RandomEvosScreen.Pager.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function RandomEvosScreen.buildPagedButtons(pokemonID, evoOptionIndex)
	evoOptionIndex = evoOptionIndex or 1
	RandomEvosScreen.pokemonID = pokemonID
	RandomEvosScreen.evoOptions = PokemonRevoData.getEvoOptions(pokemonID) or {}
	RandomEvosScreen.evoOptionIndex = evoOptionIndex
	RandomEvosScreen.Pager.Buttons = {}
	local targetEvoId = RandomEvosScreen.evoOptions[evoOptionIndex]
	local revo = PokemonRevoData.getEvoTable(pokemonID, targetEvoId)
	if not revo then
		return false
	end

	local formatPercantage = function(evoPercentage)
		if evoPercentage < 0.1 then
			return "< 0.1%"
		else
			return string.format("%.2f%%", evoPercentage)
		end
	end

	for i, revoInfo in ipairs(revo) do
		local evoId = revoInfo.id
		local evoPercent = formatPercantage(revoInfo.perc)
		local centeredOffsetX = Utils.getCenteredTextX(evoPercent, 32)
		local button = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			textColor = revoInfo.perc < 0.1 and "Negative text" or RandomEvosScreen.Colors.text,
			id = evoId,
			ordinal = i,
			dimensions = { width = 32, height = 32, },
			boxColors = { RandomEvosScreen.Colors.border, RandomEvosScreen.Colors.boxFill },
			isVisible = function(self) return RandomEvosScreen.Pager.currentPage == self.pageVisible end,
			getIconId = function(self) return self.id, SpriteData.Types.Idle end,
			onClick = function(self)
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, self.id) -- implied redraw
			end,
			-- Only draw after all the pokemon icons are drawn; executed manually in drawScreen
			drawAfter = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local textColor = Theme.COLORS[self.textColor]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				-- Draw the evo percentage below the icon
				Drawing.drawTransparentTextbox(x + centeredOffsetX - 1, y + 33, evoPercent, textColor, bgColor, shadowcolor)
			end,
		}
		table.insert(RandomEvosScreen.Pager.Buttons, button)
	end

	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	local y = Constants.SCREEN.MARGIN + Constants.SCREEN.LINESPACING + 2
	local colSpacer = 3
	local rowSpacer = 7
	RandomEvosScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

-- USER INPUT FUNCTIONS
function RandomEvosScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, RandomEvosScreen.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, RandomEvosScreen.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function RandomEvosScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local canvas = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
		text = Theme.COLORS[RandomEvosScreen.Colors.text],
		border = Theme.COLORS[RandomEvosScreen.Colors.border],
		fill = Theme.COLORS[RandomEvosScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[RandomEvosScreen.Colors.boxFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	if not PokemonData.isValid(RandomEvosScreen.pokemonID) then
		Drawing.drawButton(RandomEvosScreen.Buttons.Back, canvas.shadow)
		return
	end

	-- Draw each of the possible Pokémon evolutions
	for _, button in pairs(RandomEvosScreen.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	-- Then manually draw all the texts so they properly overlap the icons
	for _, button in pairs(RandomEvosScreen.Pager.Buttons) do
		if button:isVisible() and type(button.drawAfter) == "function" then
			button:drawAfter(canvas.shadow)
		end
	end

	-- Draw header text
	local headerText
	local hasEvoOptions = #(RandomEvosScreen.evoOptions or {}) > 0
	if hasEvoOptions then
		local targetEvoId = RandomEvosScreen.evoOptions[RandomEvosScreen.evoOptionIndex] or 0
		local evoPokemon = PokemonData.Pokemon[targetEvoId] or PokemonData.BlankPokemon
		headerText = string.format("%s %s: %s", Resources.RandomEvosScreen.LabelEvoShort, RandomEvosScreen.evoOptionIndex, evoPokemon.name)
	else
		local pokemon = PokemonData.Pokemon[RandomEvosScreen.pokemonID] or PokemonData.BlankPokemon
		headerText = string.format("%s (%s)", Resources.RandomEvosScreen.LabelRandomEvos, pokemon.name)
	end
	local centeredX = Utils.getCenteredTextX(headerText, canvas.width)
	Drawing.drawTransparentTextbox(canvas.x + centeredX, canvas.y + 3, headerText, Theme.COLORS[RandomEvosScreen.Colors.text], canvas.fill, canvas.shadow)

	-- Draw all other buttons
	for _, button in pairs(RandomEvosScreen.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

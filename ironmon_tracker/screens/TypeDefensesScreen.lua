TypeDefensesScreen = {
	Labels = {
		headerFormat = "%s's Type Defenses", -- e.g. Shuckle's Type Defenses
		pageFormat = "Page %s/%s", -- e.g. Page 1/3
		immunities = "Immunities",
		resistances = "Resistances",
		weaknesses = "Weaknesses",
	},
	Colors = {
		text = "Lower box text",
		header = "Intermediate text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	pokemonID = nil,
}

TypeDefensesScreen.Buttons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		text = "", -- Set later via updateSelf()
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 46, Constants.SCREEN.MARGIN + 135, 50, 10, },
		isVisible = function() return TypeDefensesScreen.Pager.totalPages > 1 end,
		updateSelf = function(self)
			self.text = TypeDefensesScreen.Pager:getPageText()
		end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 32, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return TypeDefensesScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			TypeDefensesScreen.Pager:prevPage()
			TypeDefensesScreen.Buttons.CurrentPage:updateSelf()
			Program.redraw(true)
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 136, 10, 10, },
		isVisible = function() return TypeDefensesScreen.Pager.totalPages > 1 end,
		onClick = function(self)
			TypeDefensesScreen.Pager:nextPage()
			TypeDefensesScreen.Buttons.CurrentPage:updateSelf()
			Program.redraw(true)
		end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 136, 24, 11 },
		onClick = function(self)
			TypeDefensesScreen.pokemonID = nil
			if InfoScreen.infoLookup == nil or InfoScreen.infoLookup == 0 then
				Program.changeScreenView(Program.Screens.TRACKER)
			else
				Program.changeScreenView(Program.Screens.INFO)
			end
		end
	},
}

TypeDefensesScreen.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
		TypeDefensesScreen.Buttons.CurrentPage:updateSelf()
	end,
	defaultSort = function(a, b) return a.ordinal < b.ordinal end,
	getPageText = function(self)
		if self.totalPages <= 1 then return "Page" end
		return string.format(TypeDefensesScreen.Labels.pageFormat, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
	end,
}

function TypeDefensesScreen.initialize()
	for _, button in pairs(TypeDefensesScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = TypeDefensesScreen.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { TypeDefensesScreen.Colors.border, TypeDefensesScreen.Colors.boxFill }
		end
	end
	TypeDefensesScreen.refresh()
end

function TypeDefensesScreen.refresh()
	for _, button in pairs(TypeDefensesScreen.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
	for _, button in pairs(TypeDefensesScreen.Pager.Buttons) do
		if button.updateSelf ~= nil then
			button:updateSelf()
		end
	end
end

function TypeDefensesScreen.buildOutPagedButtons(pokemonID)
	TypeDefensesScreen.Pager.Buttons = {}

	if not PokemonData.isValid(pokemonID) then
		return
	end
	TypeDefensesScreen.pokemonID = pokemonID -- Used for displaying the Pokemon's name in the header

	local typesPerLine = 4
	local pokemonDefenses = PokemonData.getEffectiveness(pokemonID)
	local defenseLayout = {
		{ prefix = "0x",	label = TypeDefensesScreen.Labels.immunities,	types = pokemonDefenses[0], },
		{ prefix = "1/4x",	label = TypeDefensesScreen.Labels.resistances,	types = pokemonDefenses[0.25], },
		{ prefix = "1/2x",	label = TypeDefensesScreen.Labels.resistances,	types = pokemonDefenses[0.5], },
		{ prefix = "2x",	label = TypeDefensesScreen.Labels.weaknesses,	types = pokemonDefenses[2], },
		{ prefix = "4x",	label = TypeDefensesScreen.Labels.weaknesses,	types = pokemonDefenses[4], },
	}

	for i, defenseInfo in pairs(defenseLayout) do
		if #defenseInfo.types > 0 then
			local labelText = string.format("%s %s", defenseInfo.prefix, defenseInfo.label)
			local btnHeight = Constants.SCREEN.LINESPACING + 2 + math.ceil(#defenseInfo.types / typesPerLine) * 13
			local button = {
				type = Constants.ButtonTypes.NO_BORDER,
				text = labelText,
				textColor = TypeDefensesScreen.Colors.text,
				dimensions = { width = 130, height = btnHeight, },
				ordinal = i,
				isVisible = function(self) return TypeDefensesScreen.Pager.currentPage == self.pageVisible end,
				draw = function(self, shadowcolor)
					local borderColor = Theme.COLORS[TypeDefensesScreen.Colors.border]
					TypeDefensesScreen.drawTypeBoxes(self.box[1] - 4, self.box[2] + Constants.SCREEN.LINESPACING + 2, defenseInfo.types, borderColor, shadowcolor)
				end,
			}
			table.insert(TypeDefensesScreen.Pager.Buttons, button)
		end
	end

	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 5
	local y = Constants.SCREEN.MARGIN + Constants.SCREEN.LINESPACING + 2
	local colSpacer = 1
	local rowSpacer = 3
	TypeDefensesScreen.Pager:realignButtonsToGrid(x, y, colSpacer, rowSpacer)

	return true
end

-- DRAWING FUNCTIONS
function TypeDefensesScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
		text = Theme.COLORS[TypeDefensesScreen.Colors.text],
		border = Theme.COLORS[TypeDefensesScreen.Colors.border],
		fill = Theme.COLORS[TypeDefensesScreen.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[TypeDefensesScreen.Colors.boxFill]),
	}
	local lineY = topBox.y + 1

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw all buttons
	for _, button in pairs(TypeDefensesScreen.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end

	if not PokemonData.isValid(TypeDefensesScreen.pokemonID) then
		return
	end

	-- Draw header text
	local pokemonName = PokemonData.Pokemon[TypeDefensesScreen.pokemonID].name
	local headerText = string.format(TypeDefensesScreen.Labels.headerFormat, pokemonName)
	local centerOffsetX = Utils.getCenteredTextX(headerText, topBox.width)
	Drawing.drawText(topBox.x + centerOffsetX, lineY, headerText, Theme.COLORS[TypeDefensesScreen.Colors.header], topBox.shadow)
	lineY = lineY + Constants.SCREEN.LINESPACING + 2

	-- Draw each of the type defenses for the Pokemon
	for _, button in pairs(TypeDefensesScreen.Pager.Buttons) do
		Drawing.drawButton(button, topBox.shadow)
	end
end

function TypeDefensesScreen.drawTypeBoxes(x, y, types, borderColor, shadowcolor)
	if #types == 0 then
		return
	end

	local paddingLeft = 8
	local offsetX, offsetY = paddingLeft, 0
	local boxW, boxH = 31, 13

	for i, defType in ipairs(types) do
		gui.drawRectangle(x + offsetX, y + offsetY, boxW, boxH, shadowcolor)
		gui.drawRectangle(x + offsetX - 1, y + offsetY - 1, boxW, boxH, borderColor)
		Drawing.drawTypeIcon(defType, x + offsetX, y + offsetY)

		-- Begin a new line of boxes
		offsetX = offsetX + boxW
		if x + offsetX + boxW > Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN then
			offsetX = paddingLeft
			offsetY = offsetY + boxH
		end
	end
end
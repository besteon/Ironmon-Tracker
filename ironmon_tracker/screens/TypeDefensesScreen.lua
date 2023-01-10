TypeDefensesScreen = {
	Labels = {
		headerFormat = "%s's Type Defenses", -- e.g. Shuckle's Type Defenses
		immunities = "Immunities",
		resistsBig = "Resistances",
		resistsSmall = "Resistances",
		weakSmall = "Weaknesses",
		weakBig = "Weaknesses",
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
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 136, 24, 11 },
		onClick = function(self)
			TypeDefensesScreen.pokemonID = nil
			Program.changeScreenView(Program.Screens.INFO)
		end
	},
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
	local lineY = topBox.y

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
	local pokemonDefenses = PokemonData.getEffectiveness(TypeDefensesScreen.pokemonID)
	local defenseLayout = {
		{ prefix = "0x",	label = TypeDefensesScreen.Labels.immunities, 	types = pokemonDefenses[0], },
		{ prefix = "1/4x",	label = TypeDefensesScreen.Labels.resistsBig, 	types = pokemonDefenses[0.25], },
		{ prefix = "1/2x",	label = TypeDefensesScreen.Labels.resistsSmall, types = pokemonDefenses[0.5], },
		{ prefix = "2x",	label = TypeDefensesScreen.Labels.weakSmall, 	types = pokemonDefenses[2], },
		{ prefix = "4x",	label = TypeDefensesScreen.Labels.weakBig, 		types = pokemonDefenses[4], },
	}
	for _, defenseInfo in ipairs(defenseLayout) do
		local linesUsed = TypeDefensesScreen.drawTypeBoxes(topBox.x + 1, lineY + Constants.SCREEN.LINESPACING + 2, defenseInfo.types, topBox.border, topBox.shadow)
		if linesUsed > 0 then
			local labelText = string.format("%s %s", defenseInfo.prefix, defenseInfo.label)
			Drawing.drawText(topBox.x + 6, lineY, labelText, topBox.text, topBox.shadow)
			lineY = lineY + Constants.SCREEN.LINESPACING + 13 * linesUsed + 4
		end
	end
end

function TypeDefensesScreen.drawTypeBoxes(x, y, types, borderColor, shadowcolor)
	if #types == 0 then
		return 0
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

	return math.ceil(#types / 4) -- 4 boxes per line
end
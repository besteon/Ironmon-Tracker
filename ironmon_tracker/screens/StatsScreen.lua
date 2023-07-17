StatsScreen = {
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
}

StatsScreen.StatTables = {
	{
		getText = function() return Resources.StatsScreen.StatPlayTime end,
		getValue = function() return Program.GameTimer:getText() end,
	},
	{
		getText = function() return Resources.StatsScreen.StatTotalAttempts end,
		getValue = function() return Main.currentSeed or 1 end,
	},
	{
		getText = function() return Resources.StatsScreen.StatPCsUsed end,
		getValue = function()
			local gameStat_UsedPokecenter = Utils.getGameStat(Constants.GAME_STATS.USED_POKECENTER) or 0
			local gameStat_RestedAtHome = Utils.getGameStat(Constants.GAME_STATS.RESTED_AT_HOME) or 0
			local totalHeals = gameStat_UsedPokecenter + gameStat_RestedAtHome
			return totalHeals
		end,
	},
	{
		getText = function() return Resources.StatsScreen.StatTrainerBattles end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.TRAINER_BATTLES) or 0 end,
	},
	{
		getText = function() return Resources.StatsScreen.StatWildEncounters end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.WILD_BATTLES) or 0 end,
	},
	{
		getText = function() return Resources.StatsScreen.StatPokemonCaught end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.POKEMON_CAPTURES) or 0 end,
	},
	{ -- Temporarily adding this back in: it's not # items bought but rather # of bulk purchases
		getText = function() return Resources.StatsScreen.StatShopPurchases end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.SHOPPED) or 0 end,
	},
	{
		getText = function() return Resources.StatsScreen.StatGameSaves end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.SAVED_GAME) or 0 end,
	},
	{
		getText = function() return Resources.StatsScreen.StatTotalSteps end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.STEPS) or 0 end,
	},
	{
		getText = function() return Resources.StatsScreen.StatStrugglesUsed end,
		getValue = function() return Utils.getGameStat(Constants.GAME_STATS.USED_STRUGGLE) or 0 end,
	},
}

StatsScreen.Buttons = {
	Back = Drawing.createUIElementBackButton(function() Program.changeScreenView(GameOptionsScreen) end),
}

function StatsScreen.initialize()
	local startX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4
	local startY = Constants.SCREEN.MARGIN + 14
	local linespacing = Constants.SCREEN.LINESPACING + 1

	for _, statTable in ipairs(StatsScreen.StatTables) do
		statTable.x = startX
		statTable.y = startY
		statTable.textColor = StatsScreen.Colors.text
		startY = startY + linespacing
	end

	for _, button in pairs(StatsScreen.Buttons) do
		button.textColor = StatsScreen.Colors.text
		button.boxColors = { StatsScreen.Colors.border, StatsScreen.Colors.boxFill }
	end
end

-- USER INPUT FUNCTIONS
function StatsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, StatsScreen.Buttons)
end

-- DRAWING FUNCTIONS
function StatsScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[StatsScreen.Colors.boxFill])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[StatsScreen.Colors.boxFill])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN + 10
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topboxX, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.StatsScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[StatsScreen.Colors.border], Theme.COLORS[StatsScreen.Colors.boxFill])

	-- Draw all stat tables
	local colXOffset = 90
	for _, statTable in ipairs(StatsScreen.StatTables) do
		local statValue = statTable.getValue() or 0
		if type(statValue) == "number" then
			statValue = Utils.formatNumberWithCommas(statValue)
		end
		Drawing.drawText(statTable.x, statTable.y, statTable:getText(), Theme.COLORS[statTable.textColor], shadowcolor)
		Drawing.drawText(statTable.x + colXOffset, statTable.y, statValue, Theme.COLORS[statTable.textColor], shadowcolor)
	end

	-- Draw all buttons
	for _, button in pairs(StatsScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
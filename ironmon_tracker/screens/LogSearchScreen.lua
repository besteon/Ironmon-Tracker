LogSearchScreen = {
	Buttons = {},
	searchText = "",
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background"
	},
	topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10
	},
	screenMargin = 2
}

--- Initializes the LogSearchScreen
--- @return nil
function LogSearchScreen.initialize()
	local keyboardSize = {
		width = LogSearchScreen.topBox.width - (LogSearchScreen.screenMargin * 2),
		height = nil -- Nil to have the keyboard auto size and have square keys
	}
	local keyboardPosition = {
		-- Center the keyboard horizontally
		x = LogSearchScreen.topBox.x + (LogSearchScreen.topBox.width / 2) - (keyboardSize.width / 2),
		y = LogSearchScreen.topBox.y + LogSearchScreen.screenMargin
	}

	LogSearchScreen.keyboardBox = {
		x = keyboardPosition.x,
		y = keyboardPosition.y,
		width = keyboardSize.width,
		height = keyboardSize.height
	}
	LogSearchScreen.Buttons.keyboard =
		LogSearchScreen.buildKeyboardButtons(
			LogSearchScreen.keyboardBox.x,
			LogSearchScreen.keyboardBox.y,
			LogSearchScreen.keyboardBox.width,
			LogSearchScreen.keyboardBox.height
		)
end

--- Builds a set of keyboard buttons in qwerty layout
--- @param keyboardX integer|nil The x position of the keyboard
--- @param keyboardY integer|nil The y position of the keyboard
--- @param keyboardWidth integer|nil The width of the keyboard
--- @param keyboardHeight integer|nil The height of the keyboard
--- @param keySpacing integer|nil The spacing between each key
--- @return table <string,table> A table of keyboard buttons
function LogSearchScreen.buildKeyboardButtons(keyboardX, keyboardY, keyboardWidth, keyboardHeight, keySpacing)
	local keyWidth = 0
	local keyHeight = 0
	local keyboard = {}
	--- @type table <integer,table <integer,string>>
	local keyRows = {
		{ "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
		{ "a", "s", "d", "f", "g", "h", "j", "k", "l" },
		{ "z", "x", "c", "v", "b", "n", "m" }
	}
	keySpacing = keySpacing or 2
	-- Default keyboard width and height
	keyboardWidth = math.floor(keyboardWidth or Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2))
	-- set default height so that the buttons are square
	keyboardHeight = keyboardHeight or ((keyboardWidth / #keyRows[1]) * #keyRows) + (keySpacing * (#keyRows - 1))

	-- Store values in LogSearchScreen.keyboardBox
	LogSearchScreen.keyboardBox.width = keyboardWidth
	LogSearchScreen.keyboardBox.height = keyboardHeight
	-- determine keyWidth and keyHeight based on keyboardWidth and keyboardHeight
	if keyboardWidth ~= nil and keyboardHeight ~= nil then
		keyWidth = math.floor((keyboardWidth - (keySpacing * (#keyRows[1] - 1))) / #keyRows[1])
		keyHeight = math.floor((keyboardHeight - (keySpacing * (#keyRows - 1))) / #keyRows)
	end

	-- Center the keyboard horizontally using any extra space
	local extraSpace = keyboardWidth - ((keyWidth * #keyRows[1]) + (keySpacing * (#keyRows[1] - 1)))
	keyboardX = keyboardX + math.floor(extraSpace / 2)

	local keyRowY = keyboardY or 0
	local keyRowX = keyboardX or 0
	keyWidth = keyWidth or 20
	keyHeight = keyHeight or 20

	for index, keyRow in ipairs(keyRows) do
		local rowOffset = math.floor((index - 1) * (0.5 * keyWidth) + 0.5)
		keyRowX = keyboardX or 0
		keyRowX = keyRowX + rowOffset
		for _, key in ipairs(keyRow) do
			local button = {
				type = Constants.ButtonTypes.FULL_BORDER,
				box = { keyRowX, keyRowY, keyWidth, keyHeight },
				clickableArea = { keyRowX, keyRowY, keyWidth, keyHeight },
				text = key,
				x = keyRowX,
				y = keyRowY,
				width = keyWidth,
				height = keyHeight,
				onClick = function(self)
					LogSearchScreen.searchText = LogSearchScreen.searchText .. self.text
					LogSearchScreen.Buttons.Search:updateSelf()
					print(self.text)
				end
			}
			keyboard[key] = button
			keyRowX = keyRowX + keyWidth + keySpacing
		end
		keyRowY = keyRowY + keyHeight + keySpacing
	end

	return keyboard
end
--- Draws the LogSearchScreen, automatically called by the main draw loop if this screen is active
--- @return nil
function LogSearchScreen.drawScreen()
	-- Draw the screen background
	Drawing.drawBackgroundAndMargins()
	-- Draw the search box
	gui.defaultTextBackground(Theme.COLORS[ExtrasScreen.Colors.boxFill])
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[ExtrasScreen.Colors.boxFill])
	-- Draw top border box
	gui.drawRectangle(
		LogSearchScreen.topBox.x,
		LogSearchScreen.topBox.y,
		LogSearchScreen.topBox.width,
		LogSearchScreen.topBox.height,
		Theme.COLORS[LogSearchScreen.Colors.border],
		Theme.COLORS[LogSearchScreen.Colors.boxFill]
	)
	-- Draw the keyboard
	for _, key in pairs(LogSearchScreen.Buttons.keyboard) do
		Drawing.drawButton(key)
	end
end

function LogSearchScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.Buttons)
end

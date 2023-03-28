LogSearchScreen = {
	searchText = "",
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
	},
	screenMargin = 2,
	name = "LogSearchScreen",
	Buttons = {},
}

LogSearchScreen.Buttons = {
	SearchText = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = LogSearchScreen.searchText,
		box = {
			LogSearchScreen.topBox.x + LogSearchScreen.screenMargin,
			LogSearchScreen.topBox.y + LogSearchScreen.screenMargin,
			LogSearchScreen.topBox.width - (LogSearchScreen.screenMargin * 2),
			11,
		},
		boxColors = { LogSearchScreen.Colors.border, LogSearchScreen.Colors.boxFill },
		textColor = LogSearchScreen.Colors.text,
		onClick = function(self)
			print("Click!")
		end,
	},
}
--- Initializes the LogSearchScreen
--- @return nil
function LogSearchScreen.initialize()
	local keyboardSize = {
		width = LogSearchScreen.topBox.width - (LogSearchScreen.screenMargin * 2),
		height = nil, -- Nil to have the keyboard auto size and have square keys
	}
	local keyboardPosition = {
		-- Center the keyboard horizontally
		x = LogSearchScreen.topBox.x + (LogSearchScreen.topBox.width / 2) - (keyboardSize.width / 2),
		y = LogSearchScreen.Buttons.SearchText.box[2] + LogSearchScreen.Buttons.SearchText.box[4] + 1,
	}

	LogSearchScreen.keyboardBox = {
		x = keyboardPosition.x,
		y = keyboardPosition.y,
		width = keyboardSize.width,
		height = keyboardSize.height,
	}
	--- @type table <string,table <string,any>>
	LogSearchScreen.Buttons.Keyboard = LogSearchScreen.buildKeyboardButtons(
		LogSearchScreen.keyboardBox.x,
		LogSearchScreen.keyboardBox.y,
		LogSearchScreen.keyboardBox.width,
		LogSearchScreen.keyboardBox.height
	)
end

--- Builds a set of keyboard buttons in qwerty layout, the buttons are stored in LogSearchScreen.Buttons
--- @param keyboardX integer|nil The x position of the keyboard. Defaults to 0
--- @param keyboardY integer|nil The y position of the keyboard. Defaults to 0
--- @param keyboardWidth integer|nil The width of the keyboard.
--- @param keyboardHeight integer|nil The height of the keyboard. If nil will be calculated to fit all keys with uniform height
--- @param keyPaddingX integer|nil The padding between keys on the x axis (defaults to 1)
--- @param keyPaddingY integer|nil The padding between keys on the y axis (defaults to 1)
--- @param keyboardPadding integer|nil The padding between the keyboard keys and box drawn around it (defaults to 1)
--- @return table <string,table <string,any>>  keyboard buttons
function LogSearchScreen.buildKeyboardButtons(
	keyboardX,
	keyboardY,
	keyboardWidth,
	keyboardHeight,
	keyPaddingX,
	keyPaddingY,
	keyboardPadding
)
	local keyWidth = 0
	local keyHeight = 0
	--- @type table <string,table <string,any>>
	local keyboard = {}
	local keyRows = {
		{ "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" },
		{ "a", "s", "d", "f", "g", "h", "j", "k", "l" },
		{ "z", "x", "c", "v", "b", "n", "m" },
	}

	-- Default values for parameters
	keyboardX = keyboardX or 0
	keyboardY = keyboardY or 0

	keyPaddingX = keyPaddingX or 1
	keyPaddingY = keyPaddingY or 1
	keyboardPadding = keyboardPadding or 1

	keyPaddingX = keyPaddingX * 2
	keyPaddingY = keyPaddingY * 2

	keyboardPadding = keyboardPadding * 2

	keyboardWidth = keyboardWidth or 150
	keyboardHeight = keyboardHeight or
		(((keyboardWidth / #keyRows[1]) * #keyRows) + (keyPaddingY * (#keyRows - 1))) -- Calculate the height to fit all keys with uniform height/width

	keyWidth = keyWidth or 20
	keyHeight = keyHeight or 20

	-- The area that the keys can be drawn in, this is smaller than the keyboard box to allow for padding
	local keyboardKeyArea = {
		x = keyboardX + keyboardPadding / 2,
		y = keyboardY + keyboardPadding / 2,
		width = keyboardWidth - keyboardPadding,
		height = keyboardHeight - keyboardPadding,
	}

	-- Integer height and width for the keys to fit in the keyboard box with the padding
	keyWidth = math.floor((keyboardKeyArea.width - (keyPaddingX * (#keyRows[1] - 1))) / #keyRows[1])
	keyHeight = math.floor((keyboardKeyArea.height - (keyPaddingY * (#keyRows - 1))) / #keyRows)

	-- Update the keyboard box in global scope to the actual size of the keyboard
	LogSearchScreen.keyboardBox.width, LogSearchScreen.keyboardBox.height = keyboardWidth, keyboardHeight

	-- Calculate the x and y position of the first key
	-- Center the keys horizontally and vertically

	local keyRowXOffset =
		math.floor((keyboardWidth - ((keyWidth * #keyRows[1]) + (keyPaddingX * (#keyRows[1] - 1)))) / 2)
	local keyRowYOffset = math.floor((keyboardHeight - ((keyHeight * #keyRows) + (keyPaddingY * (#keyRows - 1)))) / 2)

	local keyRowX = keyboardX + keyRowXOffset
	local keyRowY = keyboardY + keyRowYOffset
	for index, keyRow in ipairs(keyRows) do
		local rowOffset = math.floor((index - 1) * (0.5 * keyWidth) + 0.5)
		keyRowX = keyboardX + keyRowXOffset + rowOffset
		for _, key in ipairs(keyRow) do
			local button = {
				type = Constants.ButtonTypes.FULL_BORDER,
				text = key,
				box = { keyRowX, keyRowY, keyWidth, keyHeight },
				boxColors = { "Lower box border", "Lower box background" },
				textColor = "Lower box text",
				onClick = function(self)
					LogSearchScreen.searchText = LogSearchScreen.searchText .. self.text
				end,
			}
			keyboard[key] = button
			keyRowX = keyRowX + keyWidth + keyPaddingX
		end
		keyRowY = keyRowY + keyHeight + keyPaddingY
	end

	return keyboard
end

function LogSearchScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.Buttons.Keyboard)
end

--- Draws the LogSearchScreen, automatically called by the main draw loop if this screen is active
--- @return nil
function LogSearchScreen.drawScreen()
	-- Draw the screen background
	Drawing.drawBackgroundAndMargins()
	-- Draw the search box
	gui.defaultTextBackground(Theme.COLORS[LogSearchScreen.Colors.boxFill])
	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[LogSearchScreen.Colors.boxFill])
	-- Draw top border box
	gui.drawRectangle(
		LogSearchScreen.topBox.x,
		LogSearchScreen.topBox.y,
		LogSearchScreen.topBox.width,
		LogSearchScreen.topBox.height,
		Theme.COLORS[LogSearchScreen.Colors.border],
		Theme.COLORS[LogSearchScreen.Colors.boxFill]
	)
	-- Draw box underneath keyboard
	gui.drawRectangle(
		LogSearchScreen.keyboardBox.x,
		LogSearchScreen.keyboardBox.y,
		LogSearchScreen.keyboardBox.width,
		LogSearchScreen.keyboardBox.height,
		Theme.COLORS["Upper box border"],
		Theme.COLORS["Upper box background"]
	)

	-- Draw buttons
	for name, button in pairs(LogSearchScreen.Buttons) do
		-- don't draw the keyboard buttons, they are drawn below
		if name ~= "Keyboard" then
			Drawing.drawButton(button, shadowcolor)
		else
			for letter, key in pairs(button) do
				Drawing.drawButton(key, shadowcolor)
			end
		end
	end
end

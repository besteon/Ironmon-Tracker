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
	SortingFunctions = {
		alphabetical = function(a, b) return a.pokemonName < b.pokemonName end
	},
	maxLetters = 10,
}

--- Initializes the LogSearchScreen
--- @return nil
function LogSearchScreen.initialize()
	LogSearchScreen.createButtons()
end

function LogSearchScreen.createButtons()
	local keyboardSize = {
		width = LogSearchScreen.topBox.width,
		height = 50, -- Nil to have the keyboard auto size and have square keys
	}

	LogSearchScreen.keyboardBox = {
		x = LogSearchScreen.topBox.x + (LogSearchScreen.topBox.width / 2) - (keyboardSize.width / 2),
		y = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - keyboardSize.height,
		width = keyboardSize.width,
		height = keyboardSize.height,
	}
	--- @type table <string,table <string,any>>
	LogSearchScreen.Buttons.Keyboard = LogSearchScreen.buildKeyboardButtons(
		LogSearchScreen.keyboardBox.x,
		LogSearchScreen.keyboardBox.y,
		LogSearchScreen.keyboardBox.width,
		LogSearchScreen.keyboardBox.height,
		0,
		0,
		2
	)

	LogSearchScreen.Buttons.SearchText = {
		maxLetters = 10,
		letterSize = 7,
		type = Constants.ButtonTypes.FULL_BORDER,
		searchText = {},
		box = {
			LogSearchScreen.topBox.x + LogSearchScreen.screenMargin * 4,
			LogSearchScreen.topBox.y + LogSearchScreen.screenMargin,
			LogSearchScreen.topBox.width - (LogSearchScreen.screenMargin * 6),
			13,
		},
		boxColors = { LogSearchScreen.Colors.border, LogSearchScreen.Colors.boxFill },
		textColor = LogSearchScreen.Colors.text,
		draw = function(self)
			-- Split searchText into an array of characters
			for i = 1, #LogSearchScreen.searchText do
				self.searchText[i] = LogSearchScreen.searchText:sub(i, i)
			end

			-- Custom draw function to draw the text
			-- Draw horizontal lines equal to maxLetters to indicate the max length of the text
			for i = 1, self.maxLetters do
				local x = self.box[1] + (i - 1) * (self.letterSize + 3) + 2
				local y = self.box[2] + self.box[4] - 2
				if i <= #self.searchText then
					y = y - self.letterSize - 3
					Drawing.drawText(x, y, self.searchText[i], Theme.COLORS[self.textColor])
				else
					local lineColor = Theme.COLORS[LogSearchScreen.Colors.text]
					gui.drawLine(x, y, x + self.letterSize, y, lineColor)
				end
			end
		end,
	}
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
	-- Set default values for parameters
	local keyboardX, keyboardY, keyPaddingX, keyPaddingY, keyboardPadding =
		keyboardX or 0, keyboardY or 0, (keyPaddingX or 1) * 2, (keyPaddingY or 1) * 2, (keyboardPadding or 1) * 2

	-- Define keyboard layout
	local keyboardLayout = {}

	-- Define keys per row
	local keysPerRow = {
		{ "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
		{ "A", "S", "D", "F", "G", "H", "J", "K", "L" },
		{ "Z", "X", "C", "V", "B", "N", "M" },
	}

	-- Calculate key and keyboard dimensions
	keyboardWidth = keyboardWidth or 150

	-- Calculate key size to fit within the keyboard with padding between keys and the keyboard border
	local keyWidth =
		math.floor((keyboardWidth - (keyPaddingX * (#keysPerRow[1] - 1) + keyboardPadding * 2)) / #keysPerRow[1])

	-- Calculate keyboard height to fit all keys with uniform height
	keyboardHeight = keyboardHeight or (keyPaddingY * (#keysPerRow - 1) + keyboardPadding * 2 + keyWidth * #keysPerRow)

	-- Calculate key height to fit within the keyboard with padding between keys and the keyboard border
	local keyHeight =
		math.floor((keyboardHeight - (keyPaddingY * (#keysPerRow - 1) + keyboardPadding * 2)) / #keysPerRow)

	-- Update the keyboard box in global scope to the actual size of the keyboard
	LogSearchScreen.keyboardBox.width, LogSearchScreen.keyboardBox.height = keyboardWidth, keyboardHeight

	local keyRowX = keyboardX
		+ math.floor((keyboardWidth - (keyWidth * #keysPerRow[1] + keyPaddingX * (#keysPerRow[1] - 1))) / 2)
	local keyRowY = keyboardY
		+ math.floor((keyboardHeight - (keyHeight * #keysPerRow + keyPaddingY * (#keysPerRow - 1))) / 2)

	for index, keyRow in ipairs(keysPerRow) do
		local rowOffset = math.floor((index - 1) * (0.5 * keyWidth) + 0.5)
		local keyX = keyRowX + rowOffset
		for _, key in ipairs(keyRow) do
			local button = {
				type = Constants.ButtonTypes.FULL_BORDER,
				text = key,
				box = { keyX, keyRowY, keyWidth, keyHeight },
				boxColors = { "Lower box border", "Lower box background" },
				textColor = "Lower box text",
				onClick = function(self)
					-- Append the text of the button to the search text if the search text is not full
					if LogSearchScreen.searchText and #LogSearchScreen.searchText < LogSearchScreen.maxLetters then
						LogSearchScreen.searchText = LogSearchScreen.searchText .. self.text
					end
					print("Search text: " .. LogSearchScreen.searchText)
					LogOverlay.realignPokemonGrid(LogSearchScreen.searchText, LogSearchScreen.SortingFunctions.alphabetical)
					LogOverlay.refreshInnerButtons()
					Program.redraw(true)
				end,
			}
			keyboardLayout[key] = button
			keyX = keyX + keyWidth + keyPaddingX
		end
		keyRowY = keyRowY + keyHeight + keyPaddingY
	end

	return keyboardLayout
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
			local keyShadowColor = Utils.calcShadowColor(Theme.COLORS["Upper box background"])
			for letter, key in pairs(button) do
				Drawing.drawButton(
					key
				--, keyShadowColor
				)
			end
		end
	end
end

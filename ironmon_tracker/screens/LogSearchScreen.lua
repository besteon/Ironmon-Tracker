LogSearchScreen = {
	searchText = "",
	Colors = {
		text = "Lower box text",
		border = "Lower box border",
		boxFill = "Lower box background",
		headerText = "Header text",
	},
	topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
	},
	screenMargin = 2,
	name = "LogSearchScreen",
	header = "Search the log",
	Buttons = {},
	SortingFunctions = {
		alphabetical = function(a, b)
			return a.pokemonName < b.pokemonName
		end,
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
		1,
		1,
		2
	)
	-- Backspace
	local arrow_size = #Constants.PixelImages.LEFT_ARROW
	LogSearchScreen.Buttons.Backspace = {
		type = Constants.ButtonTypes.PIXELIMAGE_BORDER,
		image = Constants.PixelImages.LEFT_ARROW,
		padding = 2,
		box = {
			LogSearchScreen.keyboardBox.x
				+ LogSearchScreen.keyboardBox.width
				- arrow_size
				- LogSearchScreen.screenMargin * 2
				- 1,
			LogSearchScreen.keyboardBox.y - arrow_size - LogSearchScreen.screenMargin * 2 - 1,
			arrow_size + LogSearchScreen.screenMargin + 1,
			arrow_size + LogSearchScreen.screenMargin + 1,
		},
		boxColors = {
			LogSearchScreen.Colors.border,
			LogSearchScreen.Colors.boxFill,
		},
		textColor = LogSearchScreen.Colors.text,
		onClick = function(self)
			if #LogSearchScreen.searchText > 0 then
				LogSearchScreen.searchText = LogSearchScreen.searchText:sub(1, #LogSearchScreen.searchText - 1)
				LogSearchScreen.UpdateSearch()
			end
		end,
	}

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
		boxColors = {
			LogSearchScreen.Colors.border,
			LogSearchScreen.Colors.boxFill,
		},
		textColor = LogSearchScreen.Colors.text,
		blink = 0,
		draw = function(self, shadowcolor) -- Split searchText into an array of characters
			for i = 1, #LogSearchScreen.searchText do
				self.searchText[i] = LogSearchScreen.searchText:sub(i, i)
			end
			-- Clear the rest of the array
			for i = #LogSearchScreen.searchText + 1, self.maxLetters do
				self.searchText[i] = nil
			end
			-- Custom draw function to draw the text
			-- Draw horizontal lines equal to maxLetters to indicate the max length of the text
			for i = 1, self.maxLetters do
				local x = self.box[1] + (i - 1) * (self.letterSize + 3) + 2
				-- center
				x = x + (self.box[3] / 2) - (self.maxLetters * (self.letterSize + 3)) / 2
				local y = self.box[2] + self.box[4] - 2
				if i <= #self.searchText then
					y = y - self.letterSize - 3
					Drawing.drawText(x, y, self.searchText[i], Theme.COLORS[self.textColor], shadowcolor)
				else
					local lineColor = 0
					-- If the current line is the first empty line, blink it
					if i == #self.searchText + 1 and self.blink > 0 then
						lineColor = Theme.COLORS["Intermediate text"]
					else
						lineColor = Theme.COLORS[LogSearchScreen.Colors.text]
					end
					gui.drawLine(x, y, x + self.letterSize, y, lineColor)
				end
			end
			self.blink = self.blink - 1
			if self.blink < -2 then
				self.blink = 3
			end
		end,
	}
end

function LogSearchScreen.UpdateSearch()
	LogOverlay.realignPokemonGrid(LogSearchScreen.searchText, LogSearchScreen.SortingFunctions.alphabetical)
	LogOverlay.refreshInnerButtons()
	Program.redraw(true)
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
) -- Set default values for parameters
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

	--[[ local keysPerRow = {
    {"q" , "w" , "e" , "r" , "t" , "y" , "u" , "i" , "o" , "p" },
    {"a" , "s" , "d" , "f" , "g" , "h" , "j" , "k" , "l" },
    {"z" , "x" , "c" , "v" , "b" , "n" , "m" }

    } ]]
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
				type = Constants.ButtonTypes.KEYBOARD_KEY,
				text = key,
				-- 1 pixel smaller to account for the border
				clickableArea = {
					keyX + 1,
					keyRowY + 1,
					keyWidth - 2,
					keyHeight - 2,
				},
				box = { keyX, keyRowY, keyWidth, keyHeight },
				boxColors = { "Lower box border", "Lower box background" },
				textColor = "Lower box text",
				clicked = 0,
				keyPressedShadow = LogSearchScreen.Colors.keyPressedShadow,
				onClick = function(self) -- Append the text of the button to the search text if the search text is not full
					if LogSearchScreen.searchText and #LogSearchScreen.searchText < LogSearchScreen.maxLetters then
						LogSearchScreen.searchText = LogSearchScreen.searchText .. self.text
					end
					self.clicked = 2
					LogSearchScreen.UpdateSearch()
				end,
				draw = function(self)
					if self.clicked > 0 then
						self.clicked = self.clicked - 1
						-- Draw shadows to make the button look pressed
						gui.drawLine(
							self.box[1] + 1,
							self.box[2] + 1,
							self.box[1] + self.box[3] - 1,
							self.box[2] + 1,
							LogSearchScreen.Colors.keyPressedShadow
						)
						gui.drawLine(
							self.box[1] + 1,
							self.box[2] + 1,
							self.box[1] + 1,
							self.box[2] + self.box[4] - 1,
							LogSearchScreen.Colors.keyPressedShadow
						)
					end
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
	LogSearchScreen.Colors.lowerShadowcolor = Utils.calcShadowColor(Theme.COLORS[LogSearchScreen.Colors.boxFill])
	LogSearchScreen.Colors.headerShadowColor = Utils.calcShadowColor(Theme.COLORS["Main background"])

	LogSearchScreen.Colors.keyPressedShadow = Utils.calcShadowColor(Theme.COLORS[LogSearchScreen.Colors.boxFill], 0.9)
	 -- Draw the screen background
	Drawing.drawBackgroundAndMargins() -- Draw the search box
	gui.defaultTextBackground(Theme.COLORS[LogSearchScreen.Colors.boxFill])
	-- Draw top border box
	gui.drawRectangle(
		LogSearchScreen.topBox.x,
		LogSearchScreen.topBox.y,
		LogSearchScreen.topBox.width,
		LogSearchScreen.topBox.height,
		Theme.COLORS[LogSearchScreen.Colors.border],
		Theme.COLORS[LogSearchScreen.Colors.boxFill]
	)
	-- Draw header
	Drawing.drawHeader(
		LogSearchScreen.topBox.x + 15,
		-4,
		LogSearchScreen.header,
		Theme.COLORS[LogSearchScreen.Colors.headerText] -- ,LogSearchScreen.Colors.headerShadowColor
	)
	-- Draw box underneath keyboard
	gui.drawRectangle(
		LogSearchScreen.keyboardBox.x,
		LogSearchScreen.keyboardBox.y,
		LogSearchScreen.keyboardBox.width,
		LogSearchScreen.keyboardBox.height,
		Theme.COLORS["Upper box border"],
		Theme.COLORS["Upper box background"]
	) -- Draw buttons
	for name, button in pairs(LogSearchScreen.Buttons) do
		-- don't draw the keyboard buttons, they are drawn below
		if name ~= "Keyboard" then
			Drawing.drawButton(button, LogSearchScreen.Colors.lowerShadowcolor)
		else
			for letter, key in pairs(button) do
				Drawing.drawButton(key, LogSearchScreen.Colors.lowerShadowcolor)
			end
		end
	end
end

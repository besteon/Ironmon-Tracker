LogSearchScreen = {
	searchText = "",
	filterLabelText = "Filter:",
	Colors = {
		lowerBoxText = "Lower box text",
		lowerBoxBorder = "Lower box border",
		lowerBoxBG = "Lower box background",
		upperBoxText = "Upper box text",
		upperBoxBorder = "Upper box border",
		upperBoxBG = "Upper box background",
		headerText = "Header text",
	},
	topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
	},
	paddingConst = 2,
	name = "LogSearchScreen",
	--- @type table<string, table<string,integer|string>>
	labels = {},
	Buttons = {},
	SortingFunctions = {
		alphabetical = function(a, b)
			return a.pokemonName < b.pokemonName
		end,
	},
	maxLetters = 10,
	filters = {
		"Pokemon Name",
		"Ability",
		"Learnable Move",
	},
	filterDropDownOpen = false,
}
--- Initializes the LogSearchScreen
--- @return nil
function LogSearchScreen.initialize()
	-- Create the buttons
	LogSearchScreen.createButtons()

	-- =====LABELS=====
	LogSearchScreen.labels.header = {
		x = LogSearchScreen.topBox.x + 15,
		y = -4,
		text = "Search the Log",
		color = LogSearchScreen.Colors.headerText,
	}

	LogSearchScreen.labels.filterLabel = {
		x = LogSearchScreen.Buttons.searchText.box[1],
		y = LogSearchScreen.Buttons.searchText.box[2] - Constants.SCREEN.LINESPACING - LogSearchScreen.paddingConst * 2,
		text = LogSearchScreen.filterLabelText,
		color = LogSearchScreen.Colors.lowerBoxText,
	}
end

function LogSearchScreen.createButtons()
	local LSS = LogSearchScreen
	local topBox = LSS.topBox

	-- =====KEYBOARD BUTTONS=====
	local keyboardSize = {
		width = topBox.width,
		height = 50, -- Nil to have the keyboard auto size and have square keys
	}
	LSS.keyboardBox = {
		x = topBox.x + (topBox.width / 2) - (keyboardSize.width / 2),
		y = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - keyboardSize.height,
		width = keyboardSize.width,
		height = keyboardSize.height,
	}
	LSS.Buttons.Keyboard = LSS.buildKeyboardButtons(
		LSS.keyboardBox.x,
		LSS.keyboardBox.y,
		LSS.keyboardBox.width,
		LSS.keyboardBox.height,
		1,
		1,
		2
	)

	-- =====BACKSPACE BUTTON=====
	local arrowImage = Constants.PixelImages.LEFT_ARROW
	local arrow_size = #arrowImage
	LSS.Buttons.Backspace = {
		type = Constants.ButtonTypes.PIXELIMAGE_BORDER,
		image = arrowImage,
		padding = 2,
		clicked = 0,
		box = {
			LSS.keyboardBox.x + LSS.keyboardBox.width - arrow_size - LSS.paddingConst * 3,
			LSS.keyboardBox.y - arrow_size - LSS.paddingConst * 3,
			arrow_size + LSS.paddingConst + 1,
			arrow_size + LSS.paddingConst + 1,
		},
		boxColors = {
			LSS.Colors.lowerBoxBorder,
			LSS.Colors.lowerBoxBG,
		},
		textColor = LSS.Colors.lowerBoxText,
		onClick = function(self)
			if #LSS.searchText > 0 and not LSS.filterDropDownOpen then
				self.clicked = 2
				LSS.searchText = LSS.searchText:sub(1, #LSS.searchText - 1)
				LSS.UpdateSearch()
			end
		end,
	}

	-- =====SEARCH TEXT DISPLAY BUTTON=====
	LSS.Buttons.searchText = {
		maxLetters = 10,
		letterSize = 7,
		type = Constants.ButtonTypes.FULL_BORDER,
		searchText = {},
		box = {
			topBox.x + LSS.paddingConst + 1,
			LSS.Buttons.Backspace.box[2],
			LSS.Buttons.Backspace.box[1] - LSS.paddingConst * 3 - topBox.x,
			LSS.Buttons.Backspace.box[4],
		},
		boxColors = {
			LSS.Colors.lowerBoxBorder,
			LSS.Colors.lowerBoxBG,
		},
		textColor = LSS.Colors.lowerBoxText,
		blink = 0,
		draw = function(self, shadowcolor)
			-- Split searchText into an array of characters
			for i = 1, #LSS.searchText do
				self.searchText[i] = LSS.searchText:sub(i, i)
			end
			-- Clear the rest of the array
			for i = #LSS.searchText + 1, self.maxLetters do
				self.searchText[i] = nil
			end
			-- Custom draw function to draw the text
			-- Draw horizontal lines equal to maxLetters to indicate the max length of the text
			for i = 1, self.maxLetters do
				local x = self.box[1] + (i - 1) * (self.letterSize + 3) + 2
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
						lineColor = Theme.COLORS[LSS.Colors.lowerBoxText]
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

	-- =====FILTER DROPDOWN BUTTON=====
	LSS.Buttons.filterDropDown = {
		type = Constants.ButtonTypes.FULL_BORDER,
		box = {
			topBox.x + Utils.calcWordPixelLength(LSS.filterLabelText .. " ") + LSS.paddingConst * 3,
			LSS.Buttons.searchText.box[2] - Constants.SCREEN.LINESPACING - LSS.paddingConst * 2,
			-- End at end of search text
			LSS.Buttons.searchText.box[3]
				- Utils.calcWordPixelLength(LSS.filterLabelText .. " ")
				- LSS.paddingConst * 2
				+ 1,
			Constants.SCREEN.LINESPACING + 1,
		},
		boxColors = {
			LSS.Colors.upperBoxBorder,
			LSS.Colors.upperBoxBG,
		},
		clicked = 0,
		onClick = function(self)
			self.clicked = 2
			LSS.filterDropDownOpen = not LSS.filterDropDownOpen
		end,
		draw = function(self, shadowcolor)
			-- Draw text, not using the default draw function because it can only draw the shadow color of the box itself
			local text = LSS.filters[1]
			local textColor = LSS.Colors.lowerBoxText
			Drawing.drawText(self.box[1] + 1, self.box[2], text, Theme.COLORS[textColor], self.shadowcolor)
			-- Draw triangle for dropdown
			local triangleImage = Constants.PixelImages.TRIANGLE_DOWN
			Drawing.drawImageAsPixels(
				triangleImage,
				self.box[1] + self.box[3] - #triangleImage - LogSearchScreen.paddingConst + 1,
				self.box[2] + 1,
				Theme.COLORS[textColor],
				self.shadowcolor
			)
			-- Vertical line
			gui.drawLine(
				self.box[1] + self.box[3] - #triangleImage - LogSearchScreen.paddingConst - 1,
				self.box[2] + 1,
				self.box[1] + self.box[3] - #triangleImage - LogSearchScreen.paddingConst - 1,
				self.box[2] + self.box[4] - 1,
				Theme.COLORS[self.boxColors[1]]
			)
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

	-- ==================== Build keyboard buttons ====================
	for index, keyRow in ipairs(keysPerRow) do
		local rowOffset = math.floor((index - 1) * (0.5 * keyWidth) + 0.5)
		local keyX = keyRowX + rowOffset
		for _, key in ipairs(keyRow) do
			-- ===== KEYS =====
			local button = {
				type = Constants.ButtonTypes.FULL_BORDER,
				text = key,
				textOffsetX = -1, -- Really gotta squish the text in there
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
				onClick = function(self)
					if not LogSearchScreen.filterDropDownOpen then -- Append the text of the button to the search text if the search text is not full
						self.clicked = 2
						if LogSearchScreen.searchText and #LogSearchScreen.searchText < LogSearchScreen.maxLetters then
							LogSearchScreen.searchText = LogSearchScreen.searchText .. self.text
						end
						LogSearchScreen.UpdateSearch()
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
	local LSS = LogSearchScreen
	local topBox = LSS.topBox
	LSS.Colors.lowerShadowcolor = Utils.calcShadowColor(Theme.COLORS[LSS.Colors.lowerBoxBG])
	LSS.Colors.upperShadowcolor = Utils.calcShadowColor(Theme.COLORS[LSS.Colors.upperBoxBG])
	LSS.Colors.headerShadowColor = Utils.calcShadowColor(Theme.COLORS["Main background"])
	-- Draw the screen background
	Drawing.drawBackgroundAndMargins() -- Draw the search box
	gui.defaultTextBackground(Theme.COLORS[LSS.Colors.lowerBoxBG])
	-- Draw top border box
	gui.drawRectangle(
		topBox.x,
		topBox.y,
		topBox.width,
		topBox.height,
		Theme.COLORS[LSS.Colors.lowerBoxBorder],
		Theme.COLORS[LSS.Colors.lowerBoxBG]
	)
	-- Draw header
	local header = LSS.labels.header
	Drawing.drawHeader(header.x, header.y, header.text, Theme.COLORS[header.color])

	local labels = LSS.labels
	-- Draw non-header labels
	for name, label in pairs(labels) do
		if name ~= "header" then
			Drawing.drawText(label.x, label.y, label.text, Theme.COLORS[label.color], LSS.Colors.lowerShadowcolor)
		end
	end

	-- Draw box underneath keyboard
	gui.drawRectangle(
		LSS.keyboardBox.x,
		LSS.keyboardBox.y,
		LSS.keyboardBox.width,
		LSS.keyboardBox.height,
		Theme.COLORS["Upper box border"],
		Theme.COLORS["Upper box background"]
	) -- Draw buttons
	for name, button in pairs(LSS.Buttons) do
		-- don't draw the keyboard buttons, they are drawn below
		local shadowcolor = button.shadowcolor or LSS.Colors.lowerShadowcolor
		if name == "Keyboard" then
			shadowcolor = { LSS.Colors.upperShadowcolor, shadowcolor }
			for letter, key in pairs(button) do
				Drawing.drawButton(key, shadowcolor)
			end
		elseif name == "filterDropDown" then
			Drawing.drawButton(button, { shadowcolor, LSS.Colors.upperShadowcolor })
		else
			Drawing.drawButton(button, shadowcolor)
		end
	end
end

LogSearchScreen = {
	searchText = "",
	currentSortOrder = "alphabetical",
	filterLabelText = "Filter:",
	sortLabelText = "Sort by:",
	Colors = {
		defaultText = "Default text",
		lowerBoxText = "Lower box text",
		lowerBoxBorder = "Lower box border",
		lowerBoxBG = "Lower box background",
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
	sortDropDownButtons = {},
	filterDropDownButtons = {},
	--- @type table<string, string>
	sortingKeysLabels = {
		alphabetical = "Alphabetical",
		pokedexNumber = Constants.Words.POKE .. "dex Number",
		bst = "BST",
		hp = "HP",
		atk = "Attack",
		def = "Defense",
		spa = "Sp. Atk",
		spd = "Sp. Def",
		spe = "Speed",
	},
	sortingKeys = { "alphabetical", "pokedexNumber", "bst", "hp", "atk", "def", "spa", "spd", "spe" },
	--- @type table<string, function>
	sortingFunctions = {
		-- When sorted values are the same, default to sorting by pokedexNumber (avoids unintentional reorderings)
		alphabetical = function(a, b)
			return a.pokemonName < b.pokemonName or (a.pokemonName == b.pokemonName and a.pokemonID < b.pokemonID)
		end,
		pokedexNumber = function(a, b)
			return a.pokemonID < b.pokemonID
		end,
		bst = function(a, b)
			return PokemonData.Pokemon[a.pokemonID].bst > PokemonData.Pokemon[b.pokemonID].bst or
				(PokemonData.Pokemon[a.pokemonID].bst == PokemonData.Pokemon[b.pokemonID].bst and a.pokemonID < b.pokemonID)
		end,
		hp = function(a, b)
			local p1, p2 = RandomizerLog.Data.Pokemon[a.pokemonID].BaseStats["hp"],
				RandomizerLog.Data.Pokemon[b.pokemonID].BaseStats["hp"]
			return p1 > p2 or (p1 == p2 and a.pokemonID < b.pokemonID)
		end,
		atk = function(a, b)
			local p1, p2 = RandomizerLog.Data.Pokemon[a.pokemonID].BaseStats["atk"],
				RandomizerLog.Data.Pokemon[b.pokemonID].BaseStats["atk"]
			return p1 > p2 or (p1 == p2 and a.pokemonID < b.pokemonID)
		end,
		def = function(a, b)
			local p1, p2 = RandomizerLog.Data.Pokemon[a.pokemonID].BaseStats["def"],
				RandomizerLog.Data.Pokemon[b.pokemonID].BaseStats["def"]
			return p1 > p2 or (p1 == p2 and a.pokemonID < b.pokemonID)
		end,
		spa = function(a, b)
			local p1, p2 = RandomizerLog.Data.Pokemon[a.pokemonID].BaseStats["spa"],
				RandomizerLog.Data.Pokemon[b.pokemonID].BaseStats["spa"]
			return p1 > p2 or (p1 == p2 and a.pokemonID < b.pokemonID)
		end,
		spd = function(a, b)
			local p1, p2 = RandomizerLog.Data.Pokemon[a.pokemonID].BaseStats["spd"],
				RandomizerLog.Data.Pokemon[b.pokemonID].BaseStats["spd"]
			return p1 > p2 or (p1 == p2 and a.pokemonID < b.pokemonID)
		end,
		spe = function(a, b)
			local p1, p2 = RandomizerLog.Data.Pokemon[a.pokemonID].BaseStats["spe"],
				RandomizerLog.Data.Pokemon[b.pokemonID].BaseStats["spe"]
			return p1 > p2 or (p1 == p2 and a.pokemonID < b.pokemonID)
		end,
	},
	maxLetters = 10,
	filterKeys = {
		Constants.Words.POKEMON .. " Name",
		"Ability",
		"Levelup Move",
	},
	filterDropDownOpen = false,
	sortDropDownOpen = false,
	currentFilter = Constants.Words.POKEMON .. " Name",
	--activeFilters = {},
}
--- Initializes the LogSearchScreen
--- @return nil
function LogSearchScreen.initialize()
	local LSS = LogSearchScreen
	-- Create the buttons
	LSS.createButtons()

	-- =====LABELS=====
	LSS.labels.header = {
		x = LSS.topBox.x + 15,
		y = -3,
		text = "Search the Log",
		color = LSS.Colors.headerText,
	}

	LSS.labels.filterLabel = {
		x = LSS.Buttons.searchText.box[1],
		y = LSS.Buttons.searchText.box[2] - Constants.SCREEN.LINESPACING - LSS.paddingConst * 2 ,
		text = LSS.filterLabelText,
		color = LSS.Colors.lowerBoxText,
	}

	LSS.labels.sortLabel = {
		x = LSS.Buttons.searchText.box[1],
		y = LSS.topBox.y + LSS.paddingConst + LSS.paddingConst,
		text = LSS.sortLabelText,
		color = LSS.Colors.lowerBoxText,
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
	LSS.KeyboardButtons = LSS.buildKeyboardButtons(
		LSS.keyboardBox.x,
		LSS.keyboardBox.y,
		LSS.keyboardBox.width,
		LSS.keyboardBox.height,
		1,
		1,
		2
	)

	-- =====CLEAR SEARCH BUTTON=====
	local small_button_size = #Constants.PixelImages.CLOSE
	-- To the right of the backspace button
	LSS.Buttons.clearSearch = {
		type = Constants.ButtonTypes.FULL_BORDER,
		image = Constants.PixelImages.CLOSE,
		padding = 2,
		clicked = 0,
		box = {
			LSS.keyboardBox.x + LSS.keyboardBox.width - small_button_size - LSS.paddingConst * 3,
			LSS.keyboardBox.y - small_button_size - LSS.paddingConst * 3,
			small_button_size + LSS.paddingConst + 1,
			small_button_size + LSS.paddingConst + 1,
		},
		boxColors = {
			LSS.Colors.lowerBoxBorder,
			LSS.Colors.lowerBoxBG,
		},
		textColor = LSS.Colors.lowerBoxText,
		onClick = function(self)
			if #LSS.searchText > 0 and not LSS.filterDropDownOpen then
				self.clicked = 2
				LSS.searchText = ""
				LSS.UpdateSearch()
			end
		end,
		draw = function(self)
			Drawing.drawImageAsPixels(self.image, self.box[1] + self.padding, self.box[2] + self.padding,
				Theme.COLORS[self.textColor], LSS.Colors.lowerShadowcolor)
			self.clicked = LSS.reactOnClick(self.clicked, self.box,
				{ LSS.Colors.lowerShadowcolor, LSS.Colors.lowerShadowcolor, })
		end

	}

	-- =====BACKSPACE BUTTON=====
	LSS.Buttons.Backspace = {
		type = Constants.ButtonTypes.FULL_BORDER,
		image = Constants.PixelImages.LEFT_ARROW,
		padding = 2,
		clicked = 0,
		-- To the left of the clear search button
		box = {
			LSS.Buttons.clearSearch.box[1] - LSS.Buttons.clearSearch.box[3] - LSS.paddingConst - 1,
			LSS.Buttons.clearSearch.box[2],
			LSS.Buttons.clearSearch.box[3],
			LSS.Buttons.clearSearch.box[4],
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
		draw = function(self)
			Drawing.drawImageAsPixels(self.image, self.box[1] + self.padding, self.box[2] + self.padding - 1,
				Theme.COLORS[self.textColor], LSS.Colors.lowerShadowcolor)
			self.clicked = LSS.reactOnClick(self.clicked, self.box,
				{ LSS.Colors.lowerShadowcolor, LSS.Colors.lowerShadowcolor, })
		end
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
		-- TODO: @Aeiry Make blinking work properly, adjusting for speed-ups
		--blink = 0,
		draw = function(self)
			self.shadowcolor = LSS.Colors.lowerShadowcolor
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
					-- Center the character
					local textOffsetX = Utils.centerTextOffset(self.searchText[i],
						Constants.CharWidths[self.searchText[i]], 10) - 3
					y = y - self.letterSize - 3
					Drawing.drawText(x + textOffsetX, y, self.searchText[i], Theme.COLORS[self.textColor],
						LSS.Colors.lowerTextShadow)
				else
					--[[local lineColor = 0
					-- If the current line is the first empty line, blink it
					if i == #self.searchText + 1 and self.blink > 0 then
						lineColor = Theme.COLORS["Intermediate text"]
					else
						lineColor = Theme.COLORS[LSS.Colors.lowerBoxText]
					end]]
					gui.drawLine(x, y, x + self.letterSize, y, Theme.COLORS[self.textColor])
				end
			end
			--[[self.blink = self.blink - 1
			if self.blink < -2 then
				self.blink = 3
			end ]]
		end,
	}

	-- =====FILTER DROPDOWN BUTTONS=====
	LSS.createUpdateFilterDropdown()
	-- ===== SORT ORDER DROPDOWN BUTTONS=====
	LSS.createUpdateSortOrderDropdown()
end

function LogSearchScreen.createUpdateSortOrderDropdown()
	local buttonNum = 0
	local LSS = LogSearchScreen
	local topBox = LSS.topBox

	local initialBox = {
		topBox.x + Utils.calcWordPixelLength(LSS.sortLabelText .. " ") + LSS.paddingConst * 3,
		topBox.y + LSS.paddingConst + 1,
		-- End at end of search text
		LSS.Buttons.searchText.box[3] + LSS.Buttons.Backspace.box[3]
		- Utils.calcWordPixelLength(LSS.sortLabelText .. " "),
		Constants.SCREEN.LINESPACING + 2,
	}

	-- Create the dropdown buttons, first is the label/top level button. This will be the only one visible when the dropdown is closed
	LSS.Buttons.sortOrderTop = {
		image = Constants.PixelImages.TRIANGLE_DOWN,
		type = Constants.ButtonTypes.FULL_BORDER,
		name = LSS.currentSortOrder,
		box = initialBox,
		boxColors = {
			LSS.Colors.upperBoxBorder,
			LSS.Colors.upperBoxBG,
		},
		textColor = LSS.Colors.defaultText,
		onClick = function(self)
			-- Don't expand this dropdown menu if another one is open
			if not LSS.filterDropDownOpen then
				LSS.sortDropDownOpen = not LSS.sortDropDownOpen
				Program.redraw(true)
			end
		end,
		draw = function(self)
			Drawing.drawImageAsPixels(
				self.image,
				self.box[1] + self.box[3] - #self.image - LSS.paddingConst + 1,
				self.box[2] + 1,
				Theme.COLORS[LSS.Colors.defaultText],
				LSS.Colors.upperShadowcolor
			)
			-- Vertical line
			gui.drawLine(
				self.box[1] + self.box[3] - #self.image - LSS.paddingConst - 1,
				self.box[2] + 1,
				self.box[1] + self.box[3] - #self.image - LSS.paddingConst - 1,
				self.box[2] + self.box[4] - 1,
				Theme.COLORS[self.boxColors[1]]
			)

			-- Individual draw function to draw text shadows but not a shadow for the whole box
			Drawing.drawText(self.box[1] + 1, self.box[2] + 1, LSS.sortingKeysLabels[LSS.currentSortOrder],
				Theme.COLORS[self.textColor],
				LSS.Colors.upperTextShadow)
		end
	}
	local sortDropDownButtons = {}
	-- Rest of the buttons are hidden until the dropdown is opened
	for _, sortKey in ipairs(LSS.sortingKeys) do
		local sortLabel = LSS.sortingKeysLabels[sortKey]

		sortDropDownButtons[sortKey] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			name = sortKey,
			box = {
				initialBox[1],
				initialBox[2] + (initialBox[4] * (buttonNum + 1)),
				initialBox[3],
				initialBox[4],
			},
			boxColors = {
				LSS.Colors.lowerBoxBorder,
				LSS.Colors.lowerBoxBG,
			},
			textColor = LSS.Colors.lowerBoxText,
			onClick = function(self)
				LSS.sortDropDownOpen = not LSS.sortDropDownOpen

				LSS.currentSortOrder = self.name

				LSS.createUpdateSortOrderDropdown()
				LSS.UpdateSearch()
			end,
			isVisible = function(self)
				return LSS.sortDropDownOpen
			end,
			draw = function(self)
				-- Individual draw function to draw text shadows but not a shadow for the whole box
				Drawing.drawText(self.box[1] + 1, self.box[2] + 1, sortLabel, Theme.COLORS[self.textColor],
					LSS.Colors.lowerTextShadow)
			end
		}
		buttonNum = buttonNum + 1
	end
	LSS.sortDropDownButtons = sortDropDownButtons
end

--- Updates the filter dropdown buttons
function LogSearchScreen.createUpdateFilterDropdown()
	local buttonNum = 0
	local LSS = LogSearchScreen
	local topBox = LSS.topBox
	local initialBox = {
		topBox.x + Utils.calcWordPixelLength(LSS.filterLabelText .. " ") + LSS.paddingConst * 3,
		LSS.Buttons.searchText.box[2] - Constants.SCREEN.LINESPACING - LSS.paddingConst * 2 - 1,
		-- End at end of search text
		LSS.Buttons.searchText.box[3] + LSS.Buttons.Backspace.box[3]
		- Utils.calcWordPixelLength(LSS.filterLabelText .. " "),
		Constants.SCREEN.LINESPACING + 2,
	}

	-- Create the dropdown buttons, first is the label/top level button.
	LSS.Buttons.filterTop = {
		image = Constants.PixelImages.TRIANGLE_DOWN,
		type = Constants.ButtonTypes.FULL_BORDER,
		box = initialBox,
		boxColors = {
			LSS.Colors.upperBoxBorder,
			LSS.Colors.upperBoxBG,
		},
		textColor = LSS.Colors.defaultText,
		onClick = function(self)
			-- Don't expand this dropdown menu if another one is open
			if not LSS.sortDropDownOpen then
				LSS.filterDropDownOpen = not LSS.filterDropDownOpen
				Program.redraw(true)
			end
		end,
		draw = function(self)
			Drawing.drawImageAsPixels(
				self.image,
				self.box[1] + self.box[3] - #self.image - LSS.paddingConst + 1,
				self.box[2] + 1,
				Theme.COLORS[LSS.Colors.defaultText],
				LSS.Colors.upperShadowcolor
			)
			-- Vertical line
			gui.drawLine(
				self.box[1] + self.box[3] - #self.image - LSS.paddingConst - 1,
				self.box[2] + 1,
				self.box[1] + self.box[3] - #self.image - LSS.paddingConst - 1,
				self.box[2] + self.box[4] - 1,
				Theme.COLORS[self.boxColors[1]]
			)

			-- Individual draw function to draw text shadows but not a shadow for the whole box
			Drawing.drawText(self.box[1] + 1, self.box[2] + 1, LSS.currentFilter, Theme.COLORS[self.textColor],
				LSS.Colors.upperTextShadow)
		end
	}

	local filterDropDownButtons = {}
	-- Rest of the buttons are hidden until the dropdown is opened

	for i, filter in ipairs(LSS.filterKeys) do
		filterDropDownButtons[filter] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			box = {
				initialBox[1],
				initialBox[2] + (initialBox[4] * (buttonNum + 1)),
				initialBox[3],
				initialBox[4],
			},
			boxColors = {
				LSS.Colors.lowerBoxBorder,
				LSS.Colors.lowerBoxBG,
			},
			onClick = function(self)
				LSS.currentFilter = filter
				LSS.filterDropDownOpen = not LSS.filterDropDownOpen
				LSS.createUpdateFilterDropdown()
				LSS.UpdateSearch()
			end,
			isVisible = function(self)
				return LSS.filterDropDownOpen
			end,
			textColor = LSS.Colors.lowerBoxText,
			draw = function(self)
				-- Individual draw function to draw text shadows but not a shadow for the whole box
				Drawing.drawText(self.box[1] + 1, self.box[2] + 1, filter, Theme.COLORS[self.textColor],
					LSS.Colors.lowerTextShadow)
			end
		}
		buttonNum = buttonNum + 1
	end
	LSS.filterDropDownButtons = filterDropDownButtons
end

function LogSearchScreen.UpdateSearch()
	LogOverlay.realignPokemonGrid(
		LogSearchScreen.searchText,
		LogSearchScreen.sortingFunctions[LogSearchScreen.sortOrder]
	)
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
	keyboardX = keyboardX or 0
	keyboardY = keyboardY or 0
	keyPaddingX = (keyPaddingX or 1) * 2
	keyPaddingY = (keyPaddingY or 1) * 2
	keyboardPadding = (keyboardPadding or 1) * 2
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

	-- ==================== Build keyboard buttons ====================
	for index, keyRow in ipairs(keysPerRow) do
		local rowOffset = math.floor((index - 1) * (0.5 * keyWidth) + 0.5)
		local keyX = keyRowX + rowOffset
		for _, key in ipairs(keyRow) do
			-- ===== KEYS =====
			-- Center the character in the box
			local textOffsetX = Utils.centerTextOffset(key, Constants.CharWidths[key], 10) - 2
			local button = {
				type = Constants.ButtonTypes.FULL_BORDER,
				keyText = key,
				textOffsetX = textOffsetX,
				-- 1 pixel smaller to account for the border
				clickableArea = {
					keyX + 1,
					keyRowY + 1,
					keyWidth - 2,
					keyHeight - 2,
				},
				box = { keyX, keyRowY, keyWidth, keyHeight },
				boxColors = { "Lower box border", "Lower box background" },
				keyTextColor = "Lower box text",
				clicked = 0,
				onClick = function(self)
					-- Don't accept keyboard button input while another dropdown is open
					if LogSearchScreen.filterDropDownOpen or LogSearchScreen.sortDropDownOpen then
						return
					end

					self.clicked = 2
					-- Append the text of the button to the search text if the search text is not full
					if LogSearchScreen.searchText and #LogSearchScreen.searchText < LogSearchScreen.maxLetters then
						LogSearchScreen.searchText = LogSearchScreen.searchText .. self.keyText
					end
					LogSearchScreen.UpdateSearch()
				end,
				draw = function(self)
					Drawing.drawText(self.box[1] + self.textOffsetX + 1, self.box[2], self.keyText,
						Theme.COLORS[self.keyTextColor], LogSearchScreen.Colors.lowerShadowcolor)
					self.clicked = LogSearchScreen.reactOnClick(self.clicked, self.box,
						{ LogSearchScreen.Colors.lowerShadowcolor, LogSearchScreen.Colors.upperShadowcolor })
				end,
			}
			keyboardLayout[key] = button
			keyX = keyX + keyWidth + keyPaddingX
		end
		keyRowY = keyRowY + keyHeight + keyPaddingY
	end

	-- Special case for the space key
	-- create a copy of the box table for the last key in the last row
	local spaceKeyBox = {}
	for i, v in ipairs(keyboardLayout["M"].box) do
		spaceKeyBox[i] = v
	end
	-- modify the copy
	spaceKeyBox[3] = (spaceKeyBox[3] * 2) + (keyPaddingX)
	spaceKeyBox[1] = spaceKeyBox[1] + keyWidth + keyPaddingX

	local spaceKeyTextOffset = Utils.getCenteredTextX("_", spaceKeyBox[3]) - 2

	keyboardLayout["_"] = {
		type = Constants.ButtonTypes.FULL_BORDER,
		keyText = "_",
		textOffsetX = spaceKeyTextOffset,
		-- 1 pixel smaller to account for the border
		clickableArea = {
			spaceKeyBox[1] + 1,
			spaceKeyBox[2] + 1,
			spaceKeyBox[3] - 2,
			spaceKeyBox[4] - 2,
		},
		box = spaceKeyBox,
		boxColors = { "Lower box border", "Lower box background" },
		keyTextColor = "Lower box text",
		clicked = 0,
		onClick = function(self)
			-- Don't accept keyboard button input while another dropdown is open
			if LogSearchScreen.filterDropDownOpen or LogSearchScreen.sortDropDownOpen then
				return
			end

			self.clicked = 2
			-- Append the text of the button to the search text if the search text is not full
			if LogSearchScreen.searchText and #LogSearchScreen.searchText < LogSearchScreen.maxLetters then
				LogSearchScreen.searchText = LogSearchScreen.searchText .. " "
			end
			LogSearchScreen.UpdateSearch()
		end,
		draw = function(self)
			Drawing.drawText(self.box[1] + self.textOffsetX + 1, self.box[2], self.keyText,
				Theme.COLORS[self.keyTextColor], LogSearchScreen.Colors.lowerShadowcolor)
			self.clicked = LogSearchScreen.reactOnClick(self.clicked, self.box,
				{ LogSearchScreen.Colors.lowerShadowcolor, LogSearchScreen.Colors.upperShadowcolor })
		end,
	}
	return keyboardLayout
end

function LogSearchScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.KeyboardButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.filterDropDownButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogSearchScreen.sortDropDownButtons)
end

--- Draws the LogSearchScreen, automatically called by the main draw loop if this screen is active
--- @return nil
function LogSearchScreen.drawScreen()
	local LSS = LogSearchScreen
	local topBox = LSS.topBox
	LSS.Colors.lowerShadowcolor = Utils.calcShadowColor(Theme.COLORS[LSS.Colors.lowerBoxBG])
	LSS.Colors.upperShadowcolor = Utils.calcShadowColor(Theme.COLORS[LSS.Colors.upperBoxBG])
	LSS.Colors.headerShadowColor = Utils.calcShadowColor(Theme.COLORS["Main background"])

	if Theme.DRAW_TEXT_SHADOWS then
		LSS.Colors.lowerTextShadow = LSS.Colors.lowerShadowcolor
		LSS.Colors.upperTextShadow = LSS.Colors.upperShadowcolor
	else
		LSS.Colors.lowerTextShadow = nil
		LSS.Colors.upperTextShadow = nil
	end

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
	)
	-- Draw buttons. These include text labels, backspace, and top level dropdown buttons
	for _, button in pairs(LSS.Buttons) do
		-- Each of these buttons appear in the areas that use lower box background
		Drawing.drawButton(button, LSS.Colors.lowerShadowcolor)
	end
	-- Draw keyboard
	for key, button in pairs(LSS.KeyboardButtons) do
		Drawing.drawButton(button)
	end
	-- Draw dropdowns last so they are on top of everything else
	for _, dropwdown in pairs(LSS.sortDropDownButtons) do
		Drawing.drawButton(dropwdown)
	end

	for _, dropwdown in pairs(LSS.filterDropDownButtons) do
		Drawing.drawButton(dropwdown)
	end
end

--- Draws a shadow on the edges of the given rectangle, either inside or outside
--- @param box table<integer,integer,integer,integer> Table containing the x, y, width, and height of the rectangle
--- @param shadowcolor integer Color of the shadow, current theme colors can be accessed via Theme.COLORS
--- @param edges table<string> Table containing the edges to draw the shadow on, can contain any of the following values: "top", "bottom", "left", "right"
--- @param inside boolean Whether to draw the shadow inside the rectangle or outside, defaults to false
--- @return nil
function LogSearchScreen.drawShadow(box, shadowcolor, edges, inside)
	inside = inside or false

	-- Determine the coordinates of lines to draw
	local cornerX, cornerY, lengthX, lengthY = box[1], box[2], box[3], box[4]

	if inside then
		cornerX = cornerX + 1
		cornerY = cornerY + 1
		lengthX = lengthX - 2
		lengthY = lengthY - 2
	end

	-- Find the edges to draw the shadow on
	local top, bottom, left, right = false, false, false, false
	for _, edge in ipairs(edges) do
		if edge == "top" then
			top = true
		elseif edge == "bottom" then
			bottom = true
		elseif edge == "left" then
			left = true
		elseif edge == "right" then
			right = true
		end
	end

	-- Draw the shadow
	if top then
		gui.drawLine(cornerX, cornerY, cornerX + lengthX, cornerY, shadowcolor)
	end

	if left then
		gui.drawLine(cornerX, cornerY, cornerX, cornerY + lengthY, shadowcolor)
	end

	if bottom then
		gui.drawLine(cornerX + 1, cornerY + 1 + lengthY, cornerX + 1 + lengthX, cornerY + 1 + lengthY, shadowcolor)
	end

	if right then
		gui.drawLine(cornerX + 1 + lengthX, cornerY + 1, cornerX + 1 + lengthX, cornerY + 1 + lengthY, shadowcolor)
	end
end

--- Helper function for .draw functions on buttons so they can react when clicked
--- @param clickedTimer integer Timer that is used to determine if the button was clicked recently
--- @param box table<integer,integer,integer,integer> Table containing the x, y, width, and height of the button
--- @param shadowcolors table<integer,integer> Table containing the colors of the shadows of the button, current theme colors can be accessed via Theme.COLORS
--- @return nil
function LogSearchScreen.reactOnClick(clickedTimer, box, shadowcolors)
	if clickedTimer ~= nil and clickedTimer > 0 then
		LogSearchScreen.drawShadow(box, shadowcolors[1], { "top", "left" }, true)
		clickedTimer = clickedTimer - 1
	else
		LogSearchScreen.drawShadow(box, shadowcolors[2], { "bottom", "right" }, false)
	end
	return clickedTimer
end

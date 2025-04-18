Drawing = {
	Colors = {
		RED = 0xFFFF0000, BLUE = 0xFF0000FF, GREEN = 0xFF00FF00, YELLOW = 0xFFFFFF00, MAGENTA = 0xFFFF00FF, CYAN = 0xFF00FFFF,
		BLACK = 0xFF000000, WHITE = 0xFFFFFFFF, GRAY = 0xFFAAAAAA, DARKGRAY = 0xFF222222,
	},
	ColorEffects = {
		DARKEN = 0x20000000,
		DISABLE = 0xB0000000,
	},
	allowCachedImages = true,
}

Drawing.AnimatedPokemon = {
	TRANSPARENCY_COLOR = "Magenta",
	POPUP_WIDTH = 250,
	POPUP_HEIGHT = 250,
	show = function(self) ExternalUI.BizForms.setProperty(self.pictureBox, ExternalUI.BizForms.Properties.VISIBLE, true) end,
	hide = function(self) ExternalUI.BizForms.setProperty(self.pictureBox, ExternalUI.BizForms.Properties.VISIBLE, false) end,
	create = function(self) Drawing.setupAnimatedPictureBox() end,
	destroy = function(self)
		if self.formWindow then
			self.formWindow:destroy()
		end
	end,
	setPokemon = function(self, pokemonID) Drawing.setAnimatedPokemon(pokemonID) end,
	relocatePokemon = function(self) Drawing.relocateAnimatedPokemon() end,
	isVisible = function(self) return self.formWindow ~= nil end,
	formWindow = nil,
	pictureBox = 0,
	addonMissing = 0,
	pokemonID = 0,
	requiresRelocating = false,
}

---Each different type of image that could be drawn. An optional override check & path can be defined, which will be used instead
---getOverridePath: If specified, will *always* use this override path instead of the default
---shouldUseOverride: If specified, will *only* use the override path if the condition defined in this function is met
Drawing.ImagePaths = {
	PokemonIcon = {
		getDefaultPath = function(self, value)
			local iconset = Options.getIconSet()
			return FileManager.buildImagePath(iconset.folder, tostring(value), iconset.extension)
		end,
		-- shouldUseOverride = function(self, value) return false end,
		-- getOverridePath = function(self, value) return "" end,
	},
	PokemonType = {
		getDefaultPath = function(self, value)
			return FileManager.buildImagePath("types", value, ".png")
		end,
		-- shouldUseOverride = function(self, value) return false end,
		-- getOverridePath = function(self, value) return "" end,
	},
	PokemonStatus = {
		getDefaultPath = function(self, value)
			return FileManager.buildImagePath("status", value, ".png")
		end,
		-- shouldUseOverride = function(self, value) return false end,
		-- getOverridePath = function(self, value) return "" end,
	},
	AnimatedPokemon = {
		getDefaultPath = function(self, value)
			return FileManager.buildImagePath(FileManager.Folders.AnimatedPokemon, value, FileManager.Extensions.ANIMATED_POKEMON)
		end,
		-- shouldUseOverride = function(self, value) return false end,
		-- getOverridePath = function(self, value) return "" end,
	},
	Repel = {
		getDefaultPath = function(self, value)
			return FileManager.buildImagePath(FileManager.Folders.Icons, FileManager.Files.Other.REPEL)
		end,
		-- shouldUseOverride = function(self, value) return false end,
		-- getOverridePath = function(self, value) return "" end,
	},
	GachaDexPokemonIcon = {
		getDefaultPath = function(self, value)
			local iconset = Options.IconSetMap[3]
			return FileManager.buildImagePath(iconset.folder, tostring(value), iconset.extension)
		end,
		-- shouldUseOverride = function(self, value) return false end,
		-- getOverridePath = function(self, value) return "" end,
	},
}

function Drawing.initialize()
	Drawing.allowCachedImages = true
	if Main.IsOnBizhawk() then
		client.SetGameExtraPadding(0, Constants.SCREEN.UP_GAP, Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.DOWN_GAP)
		gui.defaultTextBackground(0)
	end
end

function Drawing.clearGUI()
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, Drawing.Colors.BLACK, Drawing.Colors.BLACK)
end

---@param waitFramesBeforeClearing number? [Optional] Will wait N frames before clearing the cache, useful for allowing any final image draws
---@param scaleWithSpeedup boolean? [Optional] If true, will sync the counter to real time instead of the client's frame rate, ignoring speedup
function Drawing.clearImageCache(waitFramesBeforeClearing, scaleWithSpeedup)
	if not Main.IsOnBizhawk() then return end
	local function clearCacheAndForceDraw()
		gui.clearImageCache()
		gui.drawPixel(Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP + 1, 1, 0x01000000)
	end
	if type(waitFramesBeforeClearing) == "number" and waitFramesBeforeClearing > 0 then
		Program.addFrameCounter("ClearImageCache", waitFramesBeforeClearing, clearCacheAndForceDraw, 1, scaleWithSpeedup)
	else
		clearCacheAndForceDraw()
	end
end

function Drawing.drawBackgroundAndMargins(x, y, width, height, bgcolor)
	x = x or Constants.SCREEN.WIDTH
	y = y or 0
	width = width or Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP
	height = height or Constants.SCREEN.HEIGHT
	bgcolor = bgcolor or Theme.COLORS["Main background"]
	gui.drawRectangle(x, y, width, height, bgcolor, bgcolor)
end

---@param filepath string The absolute filepath to the image file; see FileManager.buildImagePath()
---@param x number The x-coordinate on the game screen canvas to draw the image
---@param y number The y-coordinate on the game screen canvas to draw the image
---@param width number? [Optional] If specified and the image is larger, will resize accordingly
---@param height number? [Optional] If specified and the image is larger, will resize accordingly
function Drawing.drawImage(filepath, x, y, width, height)
	if not Drawing.allowCachedImages or Utils.isNilOrEmpty(filepath) then return end
	if width ~= nil and height ~= nil then
		gui.drawImage(filepath, x, y, width, height)
	else
		gui.drawImage(filepath, x, y)
	end
end

---Draws part of the image file (source parameters) to a destination location on screen (desttination parameters)
---@param filepath string The absolute filepath to the image file; see FileManager.buildImagePath()
---@param sourceX number The x-coordinate from the source image file
---@param sourceY number The y-coordinate from the source image file
---@param sourceW number The width to draw from the source image file
---@param sourceH number The height to draw from the source image file
---@param destX number The x-coordinate on the game screen canvas to draw the image
---@param destY number The y-coordinate on the game screen canvas to draw the image
---@param destW number? [Optional] If specified and the image is larger, will resize accordingly
---@param destH number? [Optional] If specified and the image is larger, will resize accordingly
function Drawing.drawImageRegion(filepath, sourceX, sourceY, sourceW, sourceH, destX, destY, destW, destH)
	if not Drawing.allowCachedImages or Utils.isNilOrEmpty(filepath) then return end
	if destW ~= nil and destH ~= nil then
		gui.drawImageRegion(filepath, sourceX, sourceY, sourceW, sourceH, destX, destY, destW, destH)
	else
		gui.drawImageRegion(filepath, sourceX, sourceY, sourceW, sourceH, destX, destY)
	end
end

---@param animTypeOverride? string Optional, a `SpriteData.Types` value. Use this to override the animation of this icon to something else, leave `nil` to keep as is, or set to "None" to disable the animation on-draw
function Drawing.drawPokemonIcon(pokemonID, x, y, width, height, animTypeOverride)
	if not PokemonData.isImageIDValid(pokemonID) then
		return
	end
	local iconset = Options.getIconSet()
	x = x + (iconset.xOffset or 0)
	y = y + (iconset.yOffset or 0)
	width = width or 32
	height = height or 32

	if iconset.isAnimated and animTypeOverride ~= "None" then
		Drawing.drawSpriteIcon(x, y, pokemonID, animTypeOverride)
	else
		local imagePath = Drawing.getImagePath("PokemonIcon", tostring(pokemonID))
		if imagePath then
			Drawing.drawImage(imagePath, x, y, width, height)
		end
	end
end

---@param type string
---@param x number
---@param y number
function Drawing.drawTypeIcon(type, x, y)
	if Utils.isNilOrEmpty(type) then return end

	local imagePath = Drawing.getImagePath("PokemonType", type)
	if imagePath then
		Drawing.drawImage(imagePath, x, y, 30, 12)
	end
end

---@param status string
---@param x number
---@param y number
function Drawing.drawStatusIcon(status, x, y)
	if Utils.isNilOrEmpty(status) then return end

	local imagePath = Drawing.getImagePath("PokemonStatus", status)
	if imagePath then
		Drawing.drawImage(imagePath, x, y, 16, 8)
	end
end

function Drawing.drawText(x, y, text, color, shadowcolor, size, family, style)
	if Utils.isNilOrEmpty(text) then return end

	-- For some reason on Linux the text is offset by 1 pixel (tested on Bizhawk 2.9)
	if Main.OS == "Linux" then
		x = x + 1
		y = y - 1
	end

	-- Need a bit more space when drawing larger characters
	if GameSettings.language == "Japanese" and Utils.startsWithJapaneseChineseChar(text) then
		y = y + 1
	end

	-- For now, don't draw shadows for smaller-than-normal text (old behavior)
	if Theme.DRAW_TEXT_SHADOWS and shadowcolor ~= nil and size == nil then
		gui.drawText(x + 1, y + 1, text, shadowcolor, nil, size or Constants.Font.SIZE, family or Constants.Font.FAMILY, style)
	end
	-- void gui.drawText(x, y, message, forecolor, backcolor, fontsize, fontfamily, fontstyle, horizalign, vertalign, surfacename)
	gui.drawText(x, y, text, color, nil, size or Constants.Font.SIZE, family or Constants.Font.FAMILY, style)
end

function Drawing.drawHeader(x, y, text, color, shadowcolor, size, family, style)
	-- Need even more space when drawing larger characters in the header
	if GameSettings.language == "Japanese" and Utils.startsWithJapaneseChineseChar(text) then
		y = y + 1
	end
	Drawing.drawText(x, y, text, color, shadowcolor, size or Constants.Font.HEADERSIZE, family, style)
end

function Drawing.drawNumber(x, y, number, spacing, color, shadowcolor, size, family, style)
	if Options["Right justified numbers"] then
		Drawing.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, size, family, style)
	else
		Drawing.drawText(x, y, number, color, shadowcolor, size, family, style)
	end
end

function Drawing.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, size, family, style)
	local new_spacing = (spacing - string.len(tostring(number))) * 5
	if number == Constants.BLANKLINE then new_spacing = 8 end
	Drawing.drawText(x + new_spacing, y, number, color, shadowcolor, size, family, style)
end
--- Draws a chevron on the screen
---@param x integer @The x coordinate of the top left corner of the chevron
---@param y integer @The y coordinate of the top left corner of the chevron
---@param width integer @The width of the chevron
---@param height integer @The height of the chevron
---@param thickness integer @The thickness of the chevron
---@param direction string @The direction the chevron is facing (up, down, left, right)
---@param color integer @The color of the chevron. Likely a hex value from Theme.COLORS
---@return nil
function Drawing.drawChevron(x, y, width, height, thickness, direction, color)
	-- Set default values for width, height, and thickness
	width = width or 4
	height = height or 3
	thickness = thickness or 1
	-- Use the default text color if no color is specified
	color = color or Theme.COLORS["Default text"]
	-- Draw the chevron
	local i = 0
	if direction == "up" then
		y = y + height + thickness + 1
		while i < thickness do
			gui.drawLine(x, y - i, x + (width / 2), y - i - height, color)
			gui.drawLine(x + (width / 2), y - i - height, x + width, y - i, color)
			i = i + 1
		end
	elseif direction == "down" then
		y = y + thickness + 2
		while i < thickness do
			gui.drawLine(x, y + i, x + (width / 2), y + i + height, color)
			gui.drawLine(x + (width / 2), y + i + height, x + width, y + i, color)
			i = i + 1
		end
	elseif direction == "left" then
		x = x + width + thickness + 1
		while i < thickness do
			gui.drawLine(x - i, y, x - i - width, y + (height / 2), color)
			gui.drawLine(x - i - width, y + (height / 2), x - i, y + height, color)
			i = i + 1
		end
	elseif direction == "right" then
		x = x + thickness + 2
		while i < thickness do
			gui.drawLine(x + i, y, x + i + width, y + (height / 2), color)
			gui.drawLine(x + i + width, y + (height / 2), x + i, y + height, color)
			i = i + 1
		end
	end
end
--- Draws chevrons bottom-up, coloring them if 'intensity' is a value beyond 'max'
--- 'intensity' ranges from -N to +N, where N is twice 'max'; negative intensity are drawn downward
--- After 'max' chevrons are drawn, additional chevrons are colored with Positive text color for up, Negative text color for down
---@param x integer @The x coordinate of the top left corner of the chevron
---@param y integer @The y coordinate of the top left corner of the chevron
---@param intensity integer @The intensity of the chevrons
---@param max integer @The maximum intensity of the chevrons (the number of chevrons drawn)
---@param width integer @The width of each chevron
---@param height integer @The height of each chevron
---@param thickness integer @The thickness of each chevron
---@param spacing integer @The spacing between chevrons
function Drawing.drawChevronsVerticalIntensity(x, y, intensity, max, width, height, thickness, spacing)
	if intensity == 0 then return end

	local direction = "up"
	if intensity < 0 then
		direction = "down"
	end
	-- Absolute value of intensity
	local weight = math.abs(intensity)

	for index = 0, max - 1, 1 do
		local color = Theme.COLORS["Default text"]
		if weight > index then
			local hasColor = weight > max + index
			if hasColor then
				color = Utils.inlineIf(intensity > 0, Theme.COLORS["Positive text"], Theme.COLORS["Negative text"])
			end
			Drawing.drawChevron(x, y, width, height, thickness, direction, color)
			y = y - spacing
		end
	end
end

-- Draws a semi-transparent rectangle box behind the text
function Drawing.drawTransparentTextbox(x, y, text, textColor, bgColor, shadowcolor)
	if Utils.isNilOrEmpty(text) then return end
	textColor = textColor or Theme.COLORS["Default text"]
	bgColor = bgColor or Theme.COLORS["Upper box background"]
	shadowcolor = shadowcolor or Utils.calcShadowColor(bgColor)

	local rectWidth = 1 + Utils.calcWordPixelLength(text)
	bgColor = math.max(bgColor - 0x40000000, 0x00000000) -- minimum 0
	gui.drawRectangle(x + 1, y + 1, rectWidth, Constants.Font.SIZE - 1, bgColor, bgColor)
	Drawing.drawText(x, y, text, textColor, shadowcolor)
end

function Drawing.drawUnderline(button, color)
	if button == nil or button.box == nil then return end
	color = color or Theme.COLORS[button.textColor or ""] or Theme.COLORS["Default text"]
	local x1, x2 = button.box[1] + 2, button.box[1] + button.box[3] - 1
	local y1, y2 = button.box[2] + button.box[4] - 1, button.box[2] + button.box[4] - 1
	gui.drawLine(x1, y1, x2, y2, color)
end

function Drawing.drawMoveEffectiveness(x, y, value)
	local color = Theme.COLORS["Default text"]
	if value == 2 then
		color = Theme.COLORS["Positive text"]
		Drawing.drawChevron(x, y + 4, 4, 2, 1, "up", color)
	elseif value == 4 then
		color = Theme.COLORS["Positive text"]
		Drawing.drawChevron(x, y + 4, 4, 2, 1, "up", color)
		Drawing.drawChevron(x, y + 2, 4, 2, 1, "up", color)
	elseif value == 0.5 then
		color = Theme.COLORS["Negative text"]
		Drawing.drawChevron(x, y, 4, 2, 1, "down", color)
	elseif value == 0.25 then
		color = Theme.COLORS["Negative text"]
		Drawing.drawChevron(x, y, 4, 2, 1, "down", color)
		Drawing.drawChevron(x, y + 2, 4, 2, 1, "down", color)
	end
end

function Drawing.drawInputOverlay()
	if Input.StatHighlighter:shouldDisplay() then
		local statKey = Input.StatHighlighter:getSelectedStat()
		local statButton = TrackerScreen.Buttons[statKey or false]
		if statButton and statButton.box then
			gui.drawRectangle(statButton.box[1], statButton.box[2], statButton.box[3], statButton.box[4], Theme.COLORS["Intermediate text"])
		end
	end
end

function Drawing.drawButton(button, shadowcolor)
	if button == nil or button.box == nil then return end

	-- Don't draw the button if it's currently not visible
	if button.isVisible ~= nil and not button:isVisible() then
		return
	end

	local x = button.box[1]
	local y = button.box[2]
	local width = button.box[3]
	local height = button.box[4]
	local bordercolor
	local fillcolor
	if button.boxColors ~= nil then
		bordercolor = Theme.COLORS[button.boxColors[1]]
		fillcolor = Theme.COLORS[button.boxColors[2]]
	else
		bordercolor = Theme.COLORS["Upper box border"]
		fillcolor = Theme.COLORS["Upper box background"]
	end

	local text
	if type(button.getText) == "function" then
		text = button:getText() or ""
	else
		text = button.text or ""
	end
	local textColor
	if type(button.textColor) == "number" then
		textColor = button.textColor
	else
		textColor = Theme.COLORS[button.textColor or false] or Theme.COLORS["Default text"]
	end

	local iconColors = {}
	for _, colorKey in ipairs(button.iconColors or {}) do
		if type(colorKey) == "number" then
			table.insert(iconColors, colorKey)
		else
			table.insert(iconColors, Theme.COLORS[colorKey] or textColor)
		end
	end
	if #iconColors == 0 then -- default to using the same text color
		table.insert(iconColors, textColor)
	end

	-- First draw a box if
	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.CHECKBOX or button.type == Constants.ButtonTypes.STAT_STAGE or button.type == Constants.ButtonTypes.ICON_BORDER then
		-- Draw the box's shadow and the box border
		if shadowcolor ~= nil and not button.noShadowBorder then
			gui.drawRectangle(x + 1, y + 1, width, height, shadowcolor, fillcolor)
		end
		gui.drawRectangle(x, y, width, height, bordercolor, fillcolor)
	end

	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.NO_BORDER or (button.type == nil and text ~= "") then
		Drawing.drawText(x + 1, y, text, textColor, shadowcolor)
	elseif button.type == Constants.ButtonTypes.CHECKBOX then
		if button.disabled then
			textColor = Theme.COLORS["Negative text"]
		end
		Drawing.drawText(x + width + 1, y - 2, text, textColor, shadowcolor)

		-- Draw a mark if the checkbox button is toggled on
		if button.toggleState then
			local toggleColor = (button.disabled and "Negative text") or button.toggleColor or "Positive text"
			gui.drawLine(x + 1, y + 1, x + width - 1, y + height - 1, Theme.COLORS[toggleColor])
			gui.drawLine(x + 1, y + height - 1, x + width - 1, y + 1, Theme.COLORS[toggleColor])
		end
	elseif button.type == Constants.ButtonTypes.COLORPICKER then
		if button.themeColor ~= nil then
			local hexCodeText = string.upper(string.sub(string.format("%#x", Theme.COLORS[button.themeColor]), 5))
			-- Draw a colored circle with a black border
			gui.drawEllipse(x - 1, y, width, height, Drawing.Colors.BLACK, Theme.COLORS[button.themeColor])
			-- Draw the hex code to the side, and the text label for it
			Drawing.drawText(x + width + 1, y - 2, hexCodeText, textColor, shadowcolor)
			Drawing.drawText(x + width + 37, y - 2, text, textColor, shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.IMAGE then
		if button.image ~= nil then
			Drawing.drawImage(button.image, x, y)
		end
	elseif button.type == Constants.ButtonTypes.PIXELIMAGE then
		Drawing.drawImageAsPixels(button.image, x, y, iconColors, shadowcolor)
		Drawing.drawText(x + width + 1, y, text, textColor, shadowcolor)
	elseif button.type == Constants.ButtonTypes.POKEMON_ICON then
		local pokemonID, animType = button:getIconId()
		if PokemonData.isImageIDValid(pokemonID) then
			local iconset = Options.getIconSet()
			if iconset.isAnimated then
				Drawing.drawSpriteIcon(x + (iconset.xOffset or 0), y + (iconset.yOffset or 0), pokemonID, animType)
			else
				local imagePath = Drawing.getImagePath("PokemonIcon", tostring(pokemonID))
				if imagePath then
					Drawing.drawImage(imagePath, x + (iconset.xOffset or 0), y + (iconset.yOffset or 0), width, height)
				end
			end
		end
	elseif button.type == Constants.ButtonTypes.STAT_STAGE then
		if text == Constants.STAT_STATES[2].text or text == Constants.STAT_STATES[3].text then
			y = y - 1 -- Move up the negative/neutral stat mark 1px
		end
		Drawing.drawText(x, y - 1, text, textColor, shadowcolor)
	elseif button.type == Constants.ButtonTypes.CIRCLE then
		-- Draw the circle's shadow and the circle border
		if shadowcolor ~= nil then
			gui.drawEllipse(x + 1, y + 1, width, height, shadowcolor, fillcolor)
		end
		gui.drawEllipse(x, y, width, height, bordercolor, fillcolor)
		if width < 10 or y < 10 then
			x = x - 1
			y = y - 1
		end
		Drawing.drawText(x + 1, y, text, textColor, shadowcolor)
	elseif button.type == Constants.ButtonTypes.ICON_BORDER then
		local offsetX = 17
		local offsetY = math.max(math.floor((height - Constants.SCREEN.LINESPACING) / 2), 0)
		Drawing.drawText(x + offsetX, y + offsetY, text, textColor, shadowcolor)
		if button.image ~= nil then
			local imageWidth = #button.image[1]
			local imageHeight = #button.image
			offsetX = math.max(math.floor((16 - imageWidth) / 2), 0) + 1
			offsetY = math.max(math.floor((16 - imageHeight) / 2), 0) + 1
			Drawing.drawImageAsPixels(button.image, x + offsetX, y + offsetY, iconColors, shadowcolor)
		end
	end

	-- Draw anything extra that the button defines
	if button.draw ~= nil then
		button:draw(shadowcolor)
	end
end

function Drawing.drawImageAsPixels(imageMatrix, x, y, colorList, shadowcolor)
	if imageMatrix == nil then return end
	-- Determine a valid color list to use
	if not colorList then
		if type(imageMatrix.getColors) == "function" then
			colorList = imageMatrix:getColors()
		elseif imageMatrix.iconColors then
			colorList = imageMatrix.iconColors
		end
		colorList = colorList or Theme.COLORS["Default text"]
	end

	-- Convert to a list if only a single color is supplied
	if type(colorList) == "number" then
		colorList = { colorList }
	end

	for rowIndex = 1, #imageMatrix, 1 do
		for colIndex = 1, #(imageMatrix[rowIndex]) do
			local colorIndex = imageMatrix[rowIndex][colIndex]
			if colorList[colorIndex] then
				local offsetX = colIndex - 1
				local offsetY = rowIndex - 1
				if shadowcolor ~= nil and Theme.DRAW_TEXT_SHADOWS then
					gui.drawPixel(x + offsetX + 1, y + offsetY + 1, shadowcolor)
				end
				gui.drawPixel(x + offsetX, y + offsetY, colorList[colorIndex])
			end
		end
	end
end

-- Draws an experience bar (partially filled based on exp needed to level); width/height is just the size of the bar fill, does not include border
function Drawing.drawPercentageBar(x, y, width, height, percentFill, barColors, rightToLeft)
	if not Main.IsOnBizhawk() then return end

	-- Define default colors, to be safe
	if barColors == nil then barColors = {} end
	if barColors[1] == nil then barColors[1] = Theme.COLORS["Default text"] end
	if barColors[2] == nil then barColors[2] = Theme.COLORS["Upper box border"] end
	if barColors[3] == nil then barColors[3] = Theme.COLORS["Upper box background"] end

	local remainingWidth = math.min(math.floor(width * percentFill + 0.5), width) -- math.min to prevent drawing out-of-bounds
	local rightAlignedOffset = Utils.inlineIf(rightToLeft == true, width - remainingWidth, 0)

	-- Draw outer border bar, a rounded rectangle
	gui.drawLine(x + 1, y, x + width - 1, y, barColors[2])
	gui.drawLine(x + 1, y + height, x + width - 1, y + height, barColors[2])
	gui.drawLine(x, y + 1, x, y + height - 1, barColors[2])
	gui.drawLine(x + width, y + 1, x + width, y + height - 1, barColors[2])
	-- Draw inner colored bar for the percentage filled
	gui.drawRectangle(x + rightAlignedOffset, y, remainingWidth, height, 0x00000000, barColors[1])
end

function Drawing.drawTrainerTeamPokeballs(x, y, shadowcolor)
	local image
	local againstGiovanni = TrainerData.isGiovanni(Battle.opposingTrainerId)
	if againstGiovanni then
		image = Constants.PixelImages.MASTERBALL_SMALL
	else
		image = Constants.PixelImages.POKEBALL_SMALL
	end

	local drawnFirstBall = false
	local offsetX = 0
	for i=6, 1, -1 do -- Reverse order to match in-game team display
		local pokemon = Tracker.getPokemon(i, false) or {}
		if PokemonData.isValid(pokemon.pokemonID) then
			local colorList
			if pokemon.curHP > 0 then
				if againstGiovanni then
					-- Master Ball colors
					colorList = TrackerScreen.PokeBalls.ColorListMasterBall
				else
					colorList = TrackerScreen.PokeBalls.ColorList
				end
			else
				colorList = TrackerScreen.PokeBalls.ColorListFainted
			end
			Drawing.drawImageAsPixels(image, x + offsetX, y, colorList, shadowcolor)
			drawnFirstBall = true
		end
		-- Used to left-align the pokeballs, but allows for leaving spaces for doubles battles
		-- In-game it's displayed as "_00_00" but this will now show "00_00" instead of "0000"
		if drawnFirstBall then
			offsetX = offsetX + 9
		end
	end
end

-- Draws a tiny Tracker (50x50) on screen for purposes of previewing a Theme
function Drawing.drawTrackerThemePreview(x, y, themeColors, displayColorBars)
	local width = 50
	local height = 50
	local fontSize = Constants.Font.SIZE - 3
	local fontFamily = Constants.Font.FAMILY

	gui.drawRectangle(x - 2, y - 2, width + 4, height + 4, themeColors["Main background"], themeColors["Main background"])

	gui.drawRectangle(x, y, width, 23, themeColors["Upper box border"], themeColors["Upper box background"]) -- Top box
	gui.drawRectangle(x, y, 35, 23, themeColors["Upper box border"]) -- Top box's Pokemon info area
	gui.drawRectangle(x, y + 17, 35, 6, themeColors["Upper box border"]) -- Top box's Heals in Bag area
	gui.drawRectangle(x, y + 28, width, 22, themeColors["Lower box border"], themeColors["Lower box background"]) -- Bottom box
	gui.drawRectangle(x, y + 46, width, 4, themeColors["Lower box border"]) -- Bottom box's badge area

	-- For some reason on Linux the tiny text is offset by an additional 1 pixel (tested on Bizhawk 2.9)
	if Main.OS == "Linux" then
		x = x - 1
		y = y - 1
	end

	-- Draw the "Pokemon info"
	Drawing.drawText(x + 10, y + 0, "------------", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 30, y + 0, "=", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 10, y + 3, "--- ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 10, y + 6, "--- ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 10, y + 9, "--- ------", themeColors["Intermediate text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 10, y + 12, "------ ------", themeColors["Intermediate text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 1, y + 16, "------ ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 1, y + 18, "--- ---", themeColors["Default text"], nil, fontSize, fontFamily)

	-- Draw the "stats"
	Drawing.drawText(x + 36, y + 0, "---   ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 36, y + 3, "---   ---", themeColors["Positive text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 36, y + 6, "---   ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 36, y + 9, "---   ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 36, y + 12, "---   ---", themeColors["Negative text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 36, y + 15, "---   ---", themeColors["Default text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 36, y + 18, "---   ---", themeColors["Default text"], nil, fontSize, fontFamily)

	if not Options["Color stat numbers by nature"] then
		Drawing.drawText(x + 45, y + 3, "---", themeColors["Default text"], nil, fontSize, fontFamily)
		Drawing.drawText(x + 45, y + 12, "---", themeColors["Default text"], nil, fontSize, fontFamily)
	end

	-- Draw "header"
	Drawing.drawText(x, y + 23, "------- --- ---     ---  ----  ----", themeColors["Header text"], nil, fontSize, fontFamily)

	-- Draw the "moves"
	local moveCategory = Utils.inlineIf(Options["Show physical special icons"], "=", "")
	local moveBar = Utils.inlineIf(displayColorBars, ":", "")
	local moveText = string.format("%s%s %s", moveCategory, moveBar, "----------")
	if not Options["Show physical special icons"] then
		moveText = moveText .. "  "
	end
	if not displayColorBars then
		moveText = moveText:sub(1, -2) .. " "
	end
	Drawing.drawText(x + 1, y + 28, moveText .. "     ---  ----  ----", themeColors["Lower box text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 1, y + 32, moveText .. "     ---  ----  ----", themeColors["Lower box text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 1, y + 36, moveText .. "     ---  ----  ----", themeColors["Lower box text"], nil, fontSize, fontFamily)
	Drawing.drawText(x + 1, y + 40, moveText .. "     ---  ----  ----", themeColors["Lower box text"], nil, fontSize, fontFamily)

	-- Draw the "badges"
	for i=0, 7, 1 do
		Drawing.drawText(x + 2 + (i*6), y + 45, "--", themeColors["Lower box text"], nil, fontSize, fontFamily)
	end
end

function Drawing.drawSpriteIcon(x, y, pokemonID, requiredAnimType)
	if not SpriteData.canDrawIcon(pokemonID) then
		return
	end

	local activeIcon = SpriteData.getOrAddActiveIcon(pokemonID, requiredAnimType)
	if not activeIcon then
		return
	end

	-- If a required animation type is being requested, change to that (if able)
	if requiredAnimType and activeIcon.animationType ~= requiredAnimType and not activeIcon.inUse then
		SpriteData.changeActiveIcon(pokemonID, requiredAnimType)
	end

	local icon = SpriteData.IconData[pokemonID][activeIcon.animationType]
	if not icon then
		return
	end

	-- Mark that this sprite animation is being used
	activeIcon.inUse = true

	-- Determine source index frame to draw
	local imagePath = FileManager.buildSpritePath(activeIcon.animationType, tostring(pokemonID), ".png")
	local indexFrame = activeIcon.indexFrame or 1
	local facingFrame = Input.getSpriteFacingDirection(activeIcon.animationType)
	local sourceX = icon.w * (indexFrame - 1)
	local sourceY = icon.h * (facingFrame - 1)
	x = x + (icon.x or 0)
	y = y + (icon.y or 0)
	Drawing.drawImageRegion(imagePath, sourceX, sourceY, icon.w, icon.h, x, y)
end

function Drawing.setupAnimatedPictureBox()
	if not Options["Animated Pokemon popout"] or not Main.IsOnBizhawk() then return end

	Drawing.AnimatedPokemon:destroy()

	local bottomAreaPadding = Utils.inlineIf(TeamViewArea.isDisplayed(), Constants.SCREEN.BOTTOM_AREA, Constants.SCREEN.DOWN_GAP)

	local form = ExternalUI.IBizhawkForm:new({
		Title = "Animated Pokemon",
		Width = Drawing.AnimatedPokemon.POPUP_WIDTH,
		Height = Drawing.AnimatedPokemon.POPUP_HEIGHT,
		X = 1,
		Y = Constants.SCREEN.HEIGHT + bottomAreaPadding,
		BlockInput = false,
	})
	-- Create the form directly through Bizhawk and not ExternalUI, to allow it as an additional popup window
	form.ControlId = forms.newform(form.Width, form.Height, form.Title)
	ExternalUI.BizForms.setWindowLocation(form, form.X, form.Y)

	ExternalUI.BizForms.setProperty(form.ControlId, ExternalUI.BizForms.Properties.ALLOW_TRANSPARENCY, true)
	ExternalUI.BizForms.setProperty(form.ControlId, ExternalUI.BizForms.Properties.BACK_COLOR, Drawing.AnimatedPokemon.TRANSPARENCY_COLOR)
	ExternalUI.BizForms.setProperty(form.ControlId, ExternalUI.BizForms.Properties.TRANSPARENCY_KEY, Drawing.AnimatedPokemon.TRANSPARENCY_COLOR)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local property = ExternalUI.BizForms.Properties.BLOCK_INPUT
		if not Utils.isNilOrEmpty(ExternalUI.BizForms.getProperty(form.ControlId, property)) then
			ExternalUI.BizForms.setProperty(form.ControlId, property, form.BlockInput)
		end
	end

	-- This gets resized later
	local pictureBox = form:createPictureBox(1, 1, 1, 1)
	-- The PictureBox is sized equal to the size of the image that it contains.
	ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.AUTO_SIZE, 2)
	ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.VISIBLE, false)

	local addonText = "\nPOKEMON IMAGE IS MISSING... \n\nAdd-on requires separate installation. \n\nSee the Tracker Wiki for more info."
	local addonMissing = form:createLabel(addonText, 25, 55, 185, 90)
	ExternalUI.BizForms.setProperty(addonMissing, ExternalUI.BizForms.Properties.BACK_COLOR, "White")
	ExternalUI.BizForms.setProperty(addonMissing, ExternalUI.BizForms.Properties.VISIBLE, false)

	Drawing.AnimatedPokemon.formWindow = form
	Drawing.AnimatedPokemon.pictureBox = pictureBox
	Drawing.AnimatedPokemon.addonMissing = addonMissing
	Drawing.AnimatedPokemon.pokemonID = 0
	Drawing.AnimatedPokemon.requiresRelocating = true

	Program.focusBizhawkWindow()
end

function Drawing.setAnimatedPokemon(pokemonID)
	if not Options["Animated Pokemon popout"] or pokemonID == nil or pokemonID == 0 then
		return
	end

	-- Skip setting a new animated image if it's still the same Pokemon
	if pokemonID == Drawing.AnimatedPokemon.pokemonID then
		return
	end

	-- Verify this pokemon's name exists, otherwise skip it
	local lowerPokemonName = Utils.toLowerUTF8(Resources.Default.Game.PokemonNames[pokemonID])
	if Utils.isNilOrEmpty(lowerPokemonName) then
		return
	end

	-- Record this ID so we don't have to re-set it again later if it remains unchanged
	Drawing.AnimatedPokemon.pokemonID = pokemonID

	local imagePath = Drawing.getImagePath("AnimatedPokemon", lowerPokemonName)
	local fileExists = imagePath and FileManager.fileExists(imagePath)

	if Main.IsOnBizhawk() then
		if fileExists then
			-- Reset any previous Picture Box so that the new image will "AutoSize" and expand it
			local pictureBox = Drawing.AnimatedPokemon.pictureBox
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.VISIBLE, false)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.IMAGE_LOCATION, "")
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.LEFT, 1)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.TOP, 1)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.WIDTH, 1)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.HEIGHT, 1)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.IMAGE_LOCATION, imagePath)
			Drawing.AnimatedPokemon.requiresRelocating = true
		end
		ExternalUI.BizForms.setProperty(Drawing.AnimatedPokemon.addonMissing, ExternalUI.BizForms.Properties.VISIBLE, not fileExists)
	elseif fileExists then
		-- For mGBA, duplicate the image file so it can be rendered by external programs
		local folderpath = FileManager.getPathOverride("Animated Pokemon") or FileManager.dir
		local filepath = folderpath .. FileManager.Files.Other.ANIMATED_POKEMON
		FileManager.CopyFile(imagePath, filepath, "overwrite")
	end
end

-- When the image is first set, the image size (width/height) is unknown. It requires a few frames before it can be updated
function Drawing.relocateAnimatedPokemon()
	if not Options["Animated Pokemon popout"] or not Main.IsOnBizhawk() then return end

	local pictureBox = Drawing.AnimatedPokemon.pictureBox

	-- If the image is the same, then attempt to relocate it based on it's height
	local imageY = tonumber(ExternalUI.BizForms.getProperty(pictureBox, ExternalUI.BizForms.Properties.TOP))
	local imageHeight = tonumber(ExternalUI.BizForms.getProperty(pictureBox, ExternalUI.BizForms.Properties.HEIGHT))
	local imageWidth = tonumber(ExternalUI.BizForms.getProperty(pictureBox, ExternalUI.BizForms.Properties.WIDTH))

	-- Only relocate exactly once, 1=starting height of the box
	if imageY ~= nil and imageHeight ~= nil then
		local bottomUpY = Drawing.AnimatedPokemon.POPUP_HEIGHT - imageHeight - 40
		local leftRightX = (Drawing.AnimatedPokemon.POPUP_WIDTH - imageWidth) / 2

		-- If picture box hasn't been relocated yet, move it such that it's drawn from the bottom up
		if bottomUpY ~= imageY then
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.TOP, bottomUpY)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.LEFT, leftRightX)
			ExternalUI.BizForms.setProperty(pictureBox, ExternalUI.BizForms.Properties.VISIBLE, true)
			Drawing.AnimatedPokemon.requiresRelocating = (imageHeight == 1) -- Keep updating until the height is known
		end
	end
end

---Returns the proper full image path to an asset, while checking if any overrides are necessary; or returns nil if none exists
---@param imagePathType string A valid image path type key, as defined in Drawing.ImagePaths
---@param value any? Optional, a value to be used to build the image file (such as a pokemonID)
---@return string|nil
function Drawing.getImagePath(imagePathType, value)
	local imagePathObj = Drawing.ImagePaths[imagePathType or false]
	if not imagePathObj then
		return nil
	end

	-- If an override is provided for this path, use that
	if type(imagePathObj.getOverridePath) == "function" then
		-- If no condition is required, just use the path; otherwise first check the use-condition
		if imagePathObj.shouldUseOverride == nil or (type(imagePathObj.shouldUseOverride) == "function" and imagePathObj:shouldUseOverride(value)) then
			local overridePath = imagePathObj:getOverridePath(value)
			if not Utils.isNilOrEmpty(overridePath) then
				return overridePath
			end
		end
	end

	-- Otherwise, return the default image path
	return imagePathObj:getDefaultPath(value)
end

-- If a repel is currently active, draws an icon with a bar indicating remaining repel usage
function Drawing.drawRepelUsage()
	if not Main.IsOnBizhawk() then return end

	local xOffset = Constants.SCREEN.WIDTH - 24
	local yOffset = 0
	if Options["Display play time"] and Program.GameTimer.location == "UpperRight" then
		yOffset = (Program.GameTimer.box.height or 9) + (Program.GameTimer.margin or 0) + 1
	end
	-- Draw repel item icon
	local repelImage = Drawing.getImagePath("Repel")
	if repelImage then
		Drawing.drawImage(repelImage, xOffset, yOffset)
	end
	xOffset = xOffset + 18

	local repelBarHeight = 21
	local remainingFraction = Program.ActiveRepel.stepCount / Program.ActiveRepel.duration
	local remainingHeight = math.floor((repelBarHeight * remainingFraction) + 0.5)

	-- Determine the color of the bar based off remaining usage
	local barColor = Theme.COLORS["Positive text"]
	if remainingFraction <= 0.25 then
		barColor = Theme.COLORS["Negative text"]
	elseif remainingFraction <= 0.5 then
		barColor = Theme.COLORS["Intermediate text"]
	end

	-- Draw outer bar (black outline with semi-transparent background)
	gui.drawRectangle(xOffset, yOffset + 1, 4, repelBarHeight, Drawing.Colors.BLACK, Theme.COLORS["Upper box background"] - 0xAA000000)
	-- Draw colored bar for remaining usage
	gui.drawRectangle(xOffset, yOffset + 1 + (repelBarHeight - remainingHeight), 4, remainingHeight, 0x00000000, barColor)
end

--- Draws an "L" shape at the given coordinates
--- x and y correspond to the joint of the "L" shape
--- @param x integer X coordinate of the "L" shape
--- @param y integer Y coordinate of the "L" shape
--- @param rotation integer Rotation of the "L" shape, 0 = 0 degrees, 1 = 90 degrees, 2 = 180 degrees, 3 = 270 degrees. At 0 degrees, the "L" shape points to the right and down
--- @param color integer Color of the "L" shape, current theme colors can be accessed via Theme.COLORS
--- @param thickness integer Thickness of the "L" shape
--- @param length integer Length of the "L" shape
--- @return nil
function Drawing.drawLShape(x, y, rotation, color, thickness, length)
	thickness = thickness - 1
	length = length - 1
	if rotation == 0 then
		-- Draw the horizontal line
		gui.drawRectangle(x, y, length, thickness, color, color)
		-- Draw the vertical line
		gui.drawRectangle(x, y, thickness, length, color, color)
	elseif rotation == 1 then
		-- Draw the horizontal line
		gui.drawRectangle(x - length, y, length, thickness, color, color)
		-- Draw the vertical line
		gui.drawRectangle(x - thickness, y, thickness, length, color, color)
	elseif rotation == 2 then
		-- Draw the horizontal line
		gui.drawRectangle(x - length, y- thickness, length, thickness, color, color)
		-- Draw the vertical line
		gui.drawRectangle(x - thickness, y - length, thickness, length, color, color)
	elseif rotation == 3 then
		-- Draw the horizontal line
		gui.drawRectangle(x, y - thickness, length, thickness, color, color)
		-- Draw the vertical line
		gui.drawRectangle(x, y - length, thickness, length, color, color)
	end
end

--- Draws "L" shaped selection indicators at the corners of the given rectangle
--- @param x integer X coordinate of the top left corner of the rectangle
--- @param y integer Y coordinate of the top left corner of the rectangle
--- @param width integer Width of the rectangle
--- @param height integer Height of the rectangle
--- @param color integer Color of the selection indicators, current theme colors can be accessed via Theme.COLORS
--- @param thickness integer Thickness of the selection indicators
--- @param segmentLength integer Length of the selection indicators
--- @param segmentPadding integer Offset of the selection indicators from the corners of the rectangle
--- @return nil
function Drawing.drawSelectionIndicators(x, y, width, height, color, thickness, segmentLength, segmentPadding)

	segmentPadding = segmentPadding + thickness -1

	-- Top left
	Drawing.drawLShape(x - segmentPadding, y - segmentPadding, 0, color, thickness, segmentLength)

	-- Top right
	Drawing.drawLShape(x + width + segmentPadding, y - segmentPadding, 1, color, thickness, segmentLength)

	-- Bottom right
	Drawing.drawLShape(x + width + segmentPadding, y + height + segmentPadding, 2, color, thickness, segmentLength)

	-- Bottom left
	Drawing.drawLShape(x - segmentPadding, y + height + segmentPadding, 3, color, thickness, segmentLength)
end

-- WIP: Beginning of some UI element creation util functions. Likely want to use this system for creating most UI elements in the future
function Drawing.createUIElementBackButton(clickFunc, colorKey)
	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 124
	local y = Constants.SCREEN.MARGIN + 137
	local width = 12
	local height = 12
	return {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.BACK_ARROW,
		textColor = colorKey,
		clickableArea = {x - 2 , y , width + 4, height }, -- slightly wider
		box = { x, y, width, height },
		onClick = clickFunc,
	}
end
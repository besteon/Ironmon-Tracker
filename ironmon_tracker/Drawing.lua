Drawing = {}

Drawing.AnimatedPokemon = {
	TRANSPARENCY_COLOR = "Magenta",
	POPUP_WIDTH = 250,
	POPUP_HEIGHT = 250,
	show = function(self) forms.setproperty(self.pictureBox, "Visible", true) end,
	hide = function(self) forms.setproperty(self.pictureBox, "Visible", false) end,
	create = function(self) Drawing.setupAnimatedPictureBox() end,
	destroy = function(self) forms.destroy(self.formWindow) end,
	setPokemon = function(self, pokemonID) Drawing.setAnimatedPokemon(pokemonID) end,
	relocatePokemon = function(self) Drawing.relocateAnimatedPokemon() end,
	formWindow = 0,
	pictureBox = 0,
	addonMissing = 0,
	pokemonID = 0,
	requiresRelocating = false,
}

function Drawing.clearGUI()
	gui.drawRectangle(Constants.SCREEN.WIDTH, 0, Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP, Constants.SCREEN.HEIGHT, 0xFF000000, 0xFF000000)
end

function Drawing.drawBackgroundAndMargins(x, y, width, height)
	x = x or Constants.SCREEN.WIDTH
	y = y or 0
	width = width or Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP
	height = height or Constants.SCREEN.HEIGHT
	gui.drawRectangle(x, y, width, height, Theme.COLORS["Main background"], Theme.COLORS["Main background"])
end

function Drawing.drawPokemonIcon(pokemonID, x, y)
	if not PokemonData.isImageIDValid(pokemonID) then
		pokemonID = 0 -- Blank Pokemon data/icon
	end

	local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
	local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. pokemonID .. iconset.extension

	gui.drawImage(imagepath, x, y + iconset.yOffset, 32, 32)
end

function Drawing.drawTypeIcon(type, x, y)
	if type == nil or type == "" then return end

	gui.drawImage(Main.DataFolder .. "/images/types/" .. type .. ".png", x, y, 30, 12)
end

function Drawing.drawStatusIcon(status, x, y)
	if status == nil or status == "" then return end

	gui.drawImage(Main.DataFolder .. "/images/status/" .. status .. ".png", x, y, 16, 8)
end

function Drawing.drawText(x, y, text, color, shadowcolor, style)
	gui.drawText(x + 1, y + 1, text, shadowcolor, nil, Constants.Font.SIZE, Constants.Font.FAMILY, style)
	gui.drawText(x, y, text, color, nil, Constants.Font.SIZE, Constants.Font.FAMILY, style)
end

function Drawing.drawNumber(x, y, number, spacing, color, shadowcolor, style)
	if Options["Right justified numbers"] then
		Drawing.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, style)
	else
		Drawing.drawText(x, y, number, color, shadowcolor, style)
	end
end

function Drawing.drawRightJustifiedNumber(x, y, number, spacing, color, shadowcolor, style)
	local new_spacing = (spacing - string.len(tostring(number))) * 5
	if number == Constants.BLANKLINE then new_spacing = 8 end
	Drawing.drawText(x + new_spacing, y, number, color, shadowcolor, style)
end

function Drawing.drawChevron(x, y, width, height, thickness, direction, hasColor)
	local color = Theme.COLORS["Default text"]
	local i = 0
	if direction == "up" then
		if hasColor then
			color = Theme.COLORS["Positive text"]
		end
		y = y + height + thickness + 1
		while i < thickness do
			gui.drawLine(x, y - i, x + (width / 2), y - i - height, color)
			gui.drawLine(x + (width / 2), y - i - height, x + width, y - i, color)
			i = i + 1
		end
	elseif direction == "down" then
		if hasColor then
			color = Theme.COLORS["Negative text"]
		end
		y = y + thickness + 2
		while i < thickness do
			gui.drawLine(x, y + i, x + (width / 2), y + i + height, color)
			gui.drawLine(x + (width / 2), y + i + height, x + width, y + i, color)
			i = i + 1
		end
	end
end

-- draws chevrons bottom-up, coloring them if 'intensity' is a value beyond 'max'
-- 'intensity' ranges from -N to +N, where N is twice 'max'; negative intensity are drawn downward
function Drawing.drawChevrons(x, y, intensity, max)
	if intensity == 0 then return end

	local weight = math.abs(intensity)
	local spacing = 2

	for index = 0, max - 1, 1 do
		if weight > index then
			local hasColor = weight > max + index
			Drawing.drawChevron(x, y, 4, 2, 1, Utils.inlineIf(intensity > 0, "up", "down"), hasColor)
			y = y - spacing
		end
	end
end

function Drawing.drawMoveEffectiveness(x, y, value)
	if value == 2 then
		Drawing.drawChevron(x, y + 4, 4, 2, 1, "up", true)
	elseif value == 4 then
		Drawing.drawChevron(x, y + 4, 4, 2, 1, "up", true)
		Drawing.drawChevron(x, y + 2, 4, 2, 1, "up", true)
	elseif value == 0.5 then
		Drawing.drawChevron(x, y, 4, 2, 1, "down", true)
	elseif value == 0.25 then
		Drawing.drawChevron(x, y, 4, 2, 1, "down", true)
		Drawing.drawChevron(x, y + 2, 4, 2, 1, "down", true)
	end
end

function Drawing.drawInputOverlay()
	if not Tracker.Data.isViewingOwn and Input.controller.framesSinceInput < Input.controller.boxVisibleFrames then
		if Input.controller.statIndex < 1 then Input.controller.statIndex = 1 end
		if Input.controller.statIndex > 6 then Input.controller.statIndex = 6 end

		local statKey = Constants.OrderedLists.STATSTAGES[Input.controller.statIndex]
		local statButton = TrackerScreen.Buttons[statKey]
		if statButton ~= nil then
			gui.drawRectangle(statButton.box[1], statButton.box[2], statButton.box[3], statButton.box[4], Theme.COLORS["Intermediate text"], 0x000000)
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

	-- First draw a box if
	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.CHECKBOX or button.type == Constants.ButtonTypes.STAT_STAGE then
		local bordercolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[1]], Theme.COLORS["Upper box border"])
		local fillcolor = Utils.inlineIf(button.boxColors ~= nil, Theme.COLORS[button.boxColors[2]], Theme.COLORS["Upper box background"])

		-- Draw the box's shadow and the box border
		if shadowcolor ~= nil then
			gui.drawRectangle(x + 1, y + 1, width, height, shadowcolor, fillcolor)
		end
		gui.drawRectangle(x, y, width, height, bordercolor, fillcolor)
	end

	if button.type == Constants.ButtonTypes.FULL_BORDER or button.type == Constants.ButtonTypes.NO_BORDER then
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.CHECKBOX then
		if button.text ~= nil and button.text ~= "" then
			local textColor = Utils.inlineIf(button.disabled, "Negative text", button.textColor)
			Drawing.drawText(x + width + 1, y - 2, button.text, Theme.COLORS[textColor], shadowcolor)
		end

		-- Draw a mark if the checkbox button is toggled on
		if button.toggleState ~= nil and button.toggleState then
			local toggleColor = Utils.inlineIf(button.disabled, "Negative text", button.toggleColor)
			gui.drawLine(x + 1, y + 1, x + width - 1, y + height - 1, Theme.COLORS[toggleColor])
			gui.drawLine(x + 1, y + height - 1, x + width - 1, y + 1, Theme.COLORS[toggleColor])
		end
	elseif button.type == Constants.ButtonTypes.COLORPICKER then
		if button.themeColor ~= nil then
			local hexCodeText = string.upper(string.sub(string.format("%#x", Theme.COLORS[button.themeColor]), 5))
			-- Draw a colored circle with a black border
			gui.drawEllipse(x - 1, y, width, height, 0xFF000000, Theme.COLORS[button.themeColor])
			-- Draw the hex code to the side, and the text label for it
			Drawing.drawText(x + width + 1, y - 2, hexCodeText, Theme.COLORS[button.textColor], shadowcolor)
			Drawing.drawText(x + width + 37, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.IMAGE then
		if button.image ~= nil then
			gui.drawImage(button.image, x, y)
		end
	elseif button.type == Constants.ButtonTypes.PIXELIMAGE then
		if button.image ~= nil then
			Drawing.drawImageAsPixels(button.image, x, y, { Theme.COLORS[button.textColor] }, shadowcolor)
		end
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + width + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.POKEMON_ICON then
		local imagePath = button:getIconPath()
		if imagePath ~= nil then
			local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
			gui.drawImage(imagePath, x, y + iconset.yOffset, width, height)
		end
	elseif button.type == Constants.ButtonTypes.STAT_STAGE then
		if button.text ~= nil and button.text ~= "" then
			if button.text == Constants.STAT_STATES[2].text then
				y = y - 1 -- Move up the negative stat mark 1px
			end
			Drawing.drawText(x, y - 1, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	end
end

function Drawing.drawScreen(screenFunc)
	if screenFunc ~= nil and type(screenFunc) == "function" then
		screenFunc()
	end
	-- Draw the repel icon here so that it's drawn regardless of what tracker screen is displayed
	if Options["Display repel usage"] and Program.ActiveRepel.inUse and not Battle.inBattle and not Program.inStartMenu then
		Drawing.drawRepelUsage()
	end
end

function Drawing.drawImageAsPixels(imageMatrix, x, y, colorList, shadowcolor)
	-- Convert to a list if only a single color is supplied
	if type(colorList) == "number" then
		colorList = { colorList }
	end

	for rowIndex = 1, #imageMatrix, 1 do
		for colIndex = 1, #(imageMatrix[rowIndex]) do
			local colorIndex = imageMatrix[rowIndex][colIndex]
			if colorIndex > 0 then
				local offsetX = colIndex - 1
				local offsetY = rowIndex - 1

				if shadowcolor ~= nil then
					gui.drawPixel(x + offsetX + 1, y + offsetY + 1, shadowcolor)
				end
				gui.drawPixel(x + offsetX, y + offsetY, colorList[colorIndex])
			end
		end
	end
end

function Drawing.setupAnimatedPictureBox()
	if not Options["Animated Pokemon popout"] then return end

	Drawing.AnimatedPokemon:destroy()

	local formWindow = forms.newform(Drawing.AnimatedPokemon.POPUP_WIDTH, Drawing.AnimatedPokemon.POPUP_HEIGHT, "Animated Pokemon", function() client.unpause() end)
	forms.setproperty(formWindow, "AllowTransparency", true)
	forms.setproperty(formWindow, "BackColor", Drawing.AnimatedPokemon.TRANSPARENCY_COLOR)
	forms.setproperty(formWindow, "TransparencyKey", Drawing.AnimatedPokemon.TRANSPARENCY_COLOR)
	Utils.setFormLocation(formWindow, 1, Constants.SCREEN.HEIGHT)

	local pictureBox = forms.pictureBox(formWindow, 1, 1, 1, 1) -- This gets resized later
	forms.setproperty(pictureBox, "AutoSize", 2) -- The PictureBox is sized equal to the size of the image that it contains.
	forms.setproperty(pictureBox, "Visible", false)

	local addonMissing = forms.label(formWindow, "\nPOKEMON IMAGE IS MISSING... \n\nAdd-on requires separate installation. \n\nSee the Tracker Wiki for more info.", 25, 55, 185, 90)
	forms.setproperty(addonMissing, "BackColor", "White")
	forms.setproperty(addonMissing, "Visible", false)

	Drawing.AnimatedPokemon.formWindow = formWindow
	Drawing.AnimatedPokemon.pictureBox = pictureBox
	Drawing.AnimatedPokemon.addonMissing = addonMissing
	Drawing.AnimatedPokemon.pokemonID = 0
	Drawing.AnimatedPokemon.requiresRelocating = true

	-- Return focus back to Bizhawk, using the name of the rom as the name of the Bizhawk window
	os.execute("AppActivate(" .. gameinfo.getromname() .. ")")
end

function Drawing.setAnimatedPokemon(pokemonID)
	if pokemonID == nil or pokemonID == 0 then return end

	local pictureBox = Drawing.AnimatedPokemon.pictureBox


	if pokemonID ~= Drawing.AnimatedPokemon.pokemonID then
		local pokemonData = PokemonData.Pokemon[pokemonID]
		if pokemonData ~= nil then
			-- Track this ID so we don't have to preform as many checks later
			Drawing.AnimatedPokemon.pokemonID = pokemonID

			local lowerPokemonName = pokemonData.name:lower()
			local imagepath = Utils.getWorkingDirectory() .. Main.DataFolder .. "/images/pokemonAnimated/" .. lowerPokemonName .. ".gif"
			if Main.FileExists(imagepath) then
				-- Reset any previous Picture Box so that the new image will "AutoSize" and expand it
				forms.setproperty(pictureBox, "Visible", false)
				forms.setproperty(pictureBox, "ImageLocation", "")
				forms.setproperty(pictureBox, "Left", 1)
				forms.setproperty(pictureBox, "Top", 1)
				forms.setproperty(pictureBox, "Width", 1)
				forms.setproperty(pictureBox, "Height", 1)
				forms.setproperty(pictureBox, "ImageLocation", imagepath)
				Drawing.AnimatedPokemon.requiresRelocating = true

				forms.setproperty(Drawing.AnimatedPokemon.addonMissing, "Visible", false)
			else
				forms.setproperty(Drawing.AnimatedPokemon.addonMissing, "Visible", true)
			end
		end
	end
end

-- When the image is first set, the image size (width/height) is unknown. It requires a few frames before it can be updated
function Drawing.relocateAnimatedPokemon()
	local pictureBox = Drawing.AnimatedPokemon.pictureBox

	-- If the image is the same, then attempt to relocate it based on it's height
	local imageY = tonumber(forms.getproperty(pictureBox, "Top"))
	local imageHeight = tonumber(forms.getproperty(pictureBox, "Height"))
	local imageWidth = tonumber(forms.getproperty(pictureBox, "Width"))

	-- Only relocate exactly once, 1=starting height of the box
	if imageY ~= nil and imageHeight ~= nil then
		local bottomUpY = Drawing.AnimatedPokemon.POPUP_HEIGHT - imageHeight - 40
		local leftRightX = (Drawing.AnimatedPokemon.POPUP_WIDTH - imageWidth) / 2

		-- If picture box hasn't been relocated yet, move it such that it's drawn from the bottom up
		if bottomUpY ~= imageY then
			forms.setproperty(pictureBox, "Top", bottomUpY)
			forms.setproperty(pictureBox, "Left", leftRightX)
			forms.setproperty(pictureBox, "Visible", true)
			Drawing.AnimatedPokemon.requiresRelocating = (imageHeight == 1) -- Keep updating until the height is known
		end
	end
end

-- If a repel is currently active, draws an icon with a bar indicating remaining repel usage
function Drawing.drawRepelUsage()
	local xOffset = Constants.SCREEN.WIDTH - 24
	-- Draw repel item icon
	gui.drawImage(Main.DataFolder .. "/images/icons/repelUsage.png", xOffset, 0)
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
	gui.drawRectangle(xOffset, 1, 4, repelBarHeight, 0xFF000000, Theme.COLORS["Upper box background"] - 0xAA000000)
	-- Draw colored bar for remaining usage
	gui.drawRectangle(xOffset, 1 + (repelBarHeight - remainingHeight), 4, remainingHeight, 0x00000000, barColor)
end
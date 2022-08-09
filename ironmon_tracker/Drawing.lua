Drawing = {}

Drawing.AnimatedPokemon = {
	formWindow = 0, -- form id to draw the animated Pokemon image
	pictureBox = 0,
	pokemonID = 0,
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

function Drawing.drawPokemonIcon(id, x, y)
	id = id or 0
	if id < 0 or id > #PokemonData.Pokemon then
		id = 0 -- Blank Pokemon data/icon
	end

	local iconset = Options.IconSetMap[Options["Pokemon icon set"]]
	local imagepath = Main.DataFolder .. "/images/" .. iconset.folder .. "/" .. id .. iconset.extension

	if iconset.name == "Stadium" then
		y = y + 4
	elseif iconset.name == "Gen 7+" then
		y = y + 2
	end

	gui.drawImage(imagepath, x, y, 32, 32)
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
			Drawing.drawText(x + width + 1, y - 2, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end

		-- Draw a mark if the checkbox button is toggled on
		if button.toggleState ~= nil and button.toggleState then
			gui.drawLine(x + 1, y + 1, x + width - 1, y + height - 1, Theme.COLORS[button.toggleColor])
			gui.drawLine(x + 1, y + height - 1, x + width - 1, y + 1, Theme.COLORS[button.toggleColor])
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
			Drawing.drawImageAsPixels(button.image, x, y, Theme.COLORS[button.textColor], shadowcolor)
		end
		if button.text ~= nil and button.text ~= "" then
			Drawing.drawText(x + width + 1, y, button.text, Theme.COLORS[button.textColor], shadowcolor)
		end
	elseif button.type == Constants.ButtonTypes.POKEMON_ICON then
		local imagePath = button:getIconPath()
		if imagePath ~= nil then
			if Options.IconSetMap[Options["Pokemon icon set"]].name == "Stadium" then
				y = y + 4
			elseif Options.IconSetMap[Options["Pokemon icon set"]].name == "Gen 7+" then
				y = y + 2
			end
			gui.drawImage(imagePath, x, y, width, height)
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
end

function Drawing.drawImageAsPixels(imageArray, x, y, color, shadowcolor)
	for rowIndex = 1, #imageArray, 1 do
		for colIndex = 1, #(imageArray[1]) do
			if imageArray[rowIndex][colIndex] ~= 0 then
				local offsetX = colIndex - 1
				local offsetY = rowIndex - 1

				if shadowcolor ~= nil then
					gui.drawPixel(x + offsetX + 1, y + offsetY + 1, shadowcolor)
				end
				gui.drawPixel(x + offsetX, y + offsetY, color)
			end
		end
	end
end

function Drawing.setupAnimatedPictureBox()
	Drawing.destroyAnimatedPictureBox()

	local formWindow = forms.newform(250, 250, "Animated Pokemon", function() client.unpause() end)
	Utils.setFormLocation(formWindow, 150, 50)

	local pictureBox = forms.pictureBox(formWindow, 70, 20, 120, 120)
	forms.setproperty(formWindow, "BackColor", 0xFF000000)

	Drawing.AnimatedPokemon.formWindow = formWindow
	Drawing.AnimatedPokemon.pictureBox = pictureBox
	Drawing.AnimatedPokemon.pokemonID = 0
end

function Drawing.setAnimatedPokemon(pokemonID)
	if pokemonID ~= Drawing.AnimatedPokemon.pokemonID then
		local imagepath = Main.DataFolder .. "/images/pokemonAnimated/" .. pokemonID .. ".gif"
		forms.setproperty(Drawing.AnimatedPokemon.pictureBox, "ImageLocation", imagepath)
		Drawing.AnimatedPokemon.pokemonID = pokemonID
	end
end

function Drawing.destroyAnimatedPictureBox()
	if Drawing.AnimatedPokemon.formWindow ~= nil and Drawing.AnimatedPokemon.formWindow ~= 0 then
		forms.destroy(Drawing.AnimatedPokemon.formWindow)
	end
end
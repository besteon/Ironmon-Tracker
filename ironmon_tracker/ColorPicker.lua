ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(colorkey)
	local self = setmetatable({},ColorPicker)

	self.width = 220
	self.height = 330

	self.xPos = client.xpos() + client.screenwidth() / 2 - self.width / 2
	self.yPos = client.ypos() + client.screenheight() / 2 - self.height / 2

	self.circleRadius = 75
	self.circleCenter = {85,85}

	self.hue = 0
	self.sat = 0
	self.val = 100

	self.red = 0
	self.green = 0
	self.blue = 0

	self.mainForm = nil
	self.mainCanvas = nil
	self.colorTextBox = nil
	self.saveButton = nil
	self.cancelButton = nil

	self.valueSliderY = 10
	self.ellipsesPos = {85,85}

	self.circlePreview = nil
	self.colorDisplay = nil

	self.colorkey = colorkey

	self.color = string.format("%X", Theme.COLORS[colorkey])
	self.originalColor  = "0x"..string.format("%X",Theme.COLORS[colorkey])

	self.draggingColor = false
	self.draggingValueSlider = false

	self.constants = {
		SLIDER_X_POS = 180,
		SLIDER_Y_POS = 10,
		SLIDER_WIDTH = 10,
		SLIDER_HEIGHT = 150,
	}

	return self
end

function ColorPicker:initializeColorWheelSlider()
	local colorText = self.color
	self.color = "0x"..colorText
	self:HEX_to_RGB(colorText)
	self:RGB_to_HSL()
	self:convertHSVtoColorPicker()
	forms.settext(self.colorTextBox,string.sub(colorText,3))
end

function ColorPicker:setColor()
	self:HSV_to_RGB()
	self.color = self:RGB_to_Hex()
	self.color = "0xFF"..self.color
	Theme.COLORS[self.colorkey] = tonumber(self.color)
	Theme.settingsUpdated = true
	Program.redraw(true)
end

function ColorPicker:RGB_to_Hex()
	--%02x: 0 means replace " "s with "0"s, 2 is width, x means hex
	return string.format("%02x%02x%02x",
		self.red,
		self.green,
		self.blue)
end

function ColorPicker:updateCirclePreview()
	local circleCenter = self.circleCenter
	local clickPos = {forms.getMouseX(self.mainCanvas),forms.getMouseY(self.mainCanvas)}
	local x,y = clickPos[1],clickPos[2]
	local distanceToRadius = ColorPicker.distance(clickPos,circleCenter)
	if distanceToRadius > self.circleRadius then
		local ratio = distanceToRadius/self.circleRadius
		x = (x-85)/ratio
		x = 85 + x
		y = (y-85)/ratio
		y = 85 + y
	end
	local relativeX = x - circleCenter[1]
	local relativeY = -1*(y - circleCenter[2])
	local radians = 2 * math.atan(relativeY/(relativeX+(math.sqrt(relativeX^2+relativeY^2))))
	local degrees = math.deg(radians)
	--Check for NaN.
	if degrees == degrees then
		if degrees < 0 then degrees = (180-math.abs(degrees))+180 end
		self.hue = 360 - degrees + 0.5
		self.sat = math.min(100,distanceToRadius/self.circleRadius * 100 + 0.5)
		if self.val < 2 or self.val > 98 then
			self.valueSliderY = 85
			self.val = 50
		end
		self:setColor()
		forms.settext(self.colorTextBox,string.sub(self.color,5))
		self.ellipsesPos = {x,y}
		self:drawMainCanvas()
	end
end

function ColorPicker:updateVSlider()
	local clickPos = {forms.getMouseX(self.mainCanvas),forms.getMouseY(self.mainCanvas)}
	local y = clickPos[2]
	y = math.min(160,y)
	y = math.max(10,y)
	self.valueSliderY = y
	local val = 100-((y-10)/150 * 100)
	self.val = val
	self:setColor()
	forms.settext(self.colorTextBox,string.sub(self.color,5))
	self:drawMainCanvas()
end

function ColorPicker:drawMainCanvas()
	forms.clear(self.mainCanvas,0x00000000)
	local wheelPath = Main.DataFolder.."/images//colorPicker/HSVwheel3.png"
	local gradientPath = Main.DataFolder.."/images//colorPicker/HSVgradient.png"
	forms.drawRectangle(self.mainCanvas,0,0,250,300,nil,0xFF404040)
	forms.drawImage(self.mainCanvas,wheelPath,10,10,150,150)
	forms.drawImage(self.mainCanvas,gradientPath,self.constants.SLIDER_X_POS,self.constants.SLIDER_Y_POS,self.constants.SLIDER_WIDTH,self.constants.SLIDER_HEIGHT)
	forms.drawEllipse(self.mainCanvas,self.ellipsesPos[1]-3,self.ellipsesPos[2]-3,6,6,nil,tonumber(self.color))
	local sliderX = 178
	local sliderY = self.valueSliderY
	forms.drawRectangle(self.mainCanvas,sliderX,sliderY,14,4,nil,nil)

	forms.drawRectangle(self.mainCanvas,15,173,30,30,nil,tonumber(self.color))
	forms.drawText(self.mainCanvas,50,179,self.colorkey,0xFFFFFFFF,0x00000000,14,"Arial")
	forms.drawText(self.mainCanvas,14,221,"Hex Color:",0xFFFFFFFF,0x00000000,14,"Arial")

	forms.refresh(self.mainCanvas)
end

function ColorPicker:show()
	if self.colorkey == nil then return end

	Program.destroyActiveForm()
	Drawing.AnimatedPokemon:destroy() -- animated gif spazzes out, temporarily destroy it
	self.mainForm = forms.newform(self.width,self.height,"Color Picker", function() self:onClose() end)
	Program.activeFormId = self.mainForm
	self.colorTextBox = forms.textbox(self.mainForm,"",65,10,"HEX",90,218)

	self.saveButton = forms.button(self.mainForm,"Save && Close", function() self:onSave() end,15,250,95,30)
	self.cancelButton = forms.button(self.mainForm,"Cancel", function() self:onClose() end,125,250,65,30)

	forms.setlocation(self.mainForm,self.xPos,self.yPos)
	self.mainCanvas = forms.pictureBox(self.mainForm,0,0,250,300)
	self:initializeColorWheelSlider()
	self:drawMainCanvas()

	-- Required when Bizhawk configuration is set to pause the game when any menu opens, blocks mouse inputs
	client.unpause()

	-- Changes the tracker screen back to the main screen so you can see theme updates live
	Program.changeScreenView(Program.Screens.TRACKER)
end

function ColorPicker:onClick()
	self:updateCirclePreview()
end

function ColorPicker:onSave()
	-- Save the color from the colorpicker over the theme's original color, then close then window
	self.originalColor = self.color
	self:onClose()
end

function ColorPicker:onClose()
	Theme.COLORS[self.colorkey] = tonumber(self.originalColor)
	Theme.settingsUpdated = true
	Program.changeScreenView(Program.Screens.THEME)
	Input.currentColorPicker = nil
	forms.destroy(self.mainForm)
	Drawing.AnimatedPokemon:create()
	client.unpause()
end

function ColorPicker:handleInput()
	if not self.draggingColor and not self.draggingValueSlider then
		local colorText = forms.gettext(self.colorTextBox)
		if #colorText == 6 then
			self.color = "0xFF"..colorText
			self:HEX_to_RGB(colorText)
			self:RGB_to_HSL()
			self:convertHSVtoColorPicker()
		end
	end
	local mouse = input.getmouse()
	local leftPress = mouse["Left"]
	if leftPress then
		if self.draggingColor then
			self:updateCirclePreview()
		elseif self.draggingValueSlider then
			self:updateVSlider()
		else
			local clickPos = {forms.getMouseX(self.mainCanvas),forms.getMouseY(self.mainCanvas)}
			if not self.draggingColor then
				local distanceToCenter = ColorPicker.distance(clickPos,self.circleCenter)
				if distanceToCenter >= 0 and distanceToCenter <= self.circleRadius then
					self.draggingColor = true
					self:updateCirclePreview()
				end
			end
			if not self.draggingValueSlider then
				local sliderPos = {self.constants.SLIDER_X_POS,self.constants.SLIDER_Y_POS}
				local sliderSize = {self.constants.SLIDER_WIDTH,self.constants.SLIDER_HEIGHT}
				if self:mouseInRange(sliderPos,sliderSize) then
				   self.draggingValueSlider = true
				end
			end
		end
	else
		self.draggingValueSlider = false
		self.draggingColor = false
	end
end

function ColorPicker:mouseInRange(pos,size)
	local x = forms.getMouseX(self.mainCanvas)
	local y = forms.getMouseY(self.mainCanvas)
	local width = size[1]
	local height = size[2]
	return
	x >= pos[1] and x < pos[1] + width and y >= pos[2] and y < pos[2] + height
end

function ColorPicker.distance(point1, point2)
	local x1 = point1[1]
	local y1 = point1[2]
	local x2 = point2[1]
	local y2 = point2[2]

	local dist = math.sqrt( ((x2-x1)^2) + ((y2-y1)^2) )
	return dist
end

function ColorPicker:pointInRange(point)
	local distanceToRadius = ColorPicker.distance(point,self.circleRadiusPosition)
	if distanceToRadius <= self.radius then
		return true
	else
		return false
	end
end

function ColorPicker:convertHSVtoColorPicker()
	self.valueSliderY = 10+((100-self.val)/100*150)
	local sat = self.sat / 100
	local angle = self.hue
	angle = math.rad(angle)
	local relativeX = math.cos(angle) * (self.circleRadius)*sat
	local relativeY = math.sin(angle) * (self.circleRadius)*sat
	self.ellipsesPos = {relativeX+self.circleCenter[1],relativeY+self.circleCenter[2]}
	self:drawMainCanvas()
	Theme.COLORS[self.colorkey] = tonumber(self.color)
	Theme.settingsUpdated = true
	Program.redraw(true)
end

function ColorPicker:HSV_to_RGB()
	local hue = self.hue / 360
	local sat = self.sat / 100
	local val = self.val / 100

	if sat == 0 then
		self.red, self.green, self.blue = val, val, val; -- achromatic
	else
		local function hue2rgb(p, q, t)
			if t < 0 then t = t + 1 end
			if t > 1 then t = t - 1 end
			if t < 1 / 6 then return p + (q - p) * 6 * t end
			if t < 1 / 2 then return q end
			if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
			return p;
		end

		local q = val < 0.5 and val * (1 + sat) or val + sat - val * sat;
		local p = 2 * val - q;
		self.red = hue2rgb(p, q, hue + 1 / 3);
		self.green = hue2rgb(p, q, hue);
		self.blue = hue2rgb(p, q, hue - 1 / 3);
	end

	self.red, self.green, self.blue =  self.red * 255, self.green * 255, self.blue * 255
end

function ColorPicker:HEX_to_RGB (hex)
	if hex:len() == 3 then
	  self.red, self.green, self.blue = (tonumber("0x"..hex:sub(1,1))*17), (tonumber("0x"..hex:sub(2,2))*17), (tonumber("0x"..hex:sub(3,3))*17)
	else
	  self.red, self.green, self.blue = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	end
end

function ColorPicker:RGB_to_HSL()
	local r,g,b = self.red,self.green,self.blue

	local R, G, B = r / 255, g / 255, b / 255
	local max, min = math.max(R, G, B), math.min(R, G, B)
	local l, s, h


	-- Get luminance
	l = (max + min) / 2

	-- short circuit saturation and hue if it's grey to prevent divide by 0
	if max == min then
		self.hue, self.sat, self.val = 0, 0, l*100
		return
	end

	-- Get saturation
	if l <= 0.5 then s = (max - min) / (max + min)
	else s = (max - min) / (2 - max - min)
	end

	-- Get hue
	if max == R then h = (G - B) / (max - min) * 60
	elseif max == G then h = (2.0 + (B - R) / (max - min)) * 60
	else h = (4.0 + (R - G) / (max - min)) * 60
	end

	-- Make sure it goes around if it's negative (hue is a circle)
	if h ~= 360 then h = h % 360 end
	self.hue, self.sat, self.val = h,s*100,l*100
end
AnimationManager = {
	-- A key-value table of all active IAnimation objects
	---@type table<string, IAnimation>
	ActiveAnimations = {},
}

function AnimationManager.initialize()
	AnimationManager.ActiveAnimations = {}
end

-- Helper Functions

local _coverScreenInDarkness = function()
	local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local y = Constants.SCREEN.MARGIN
	local w = Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2
	local h = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN * 2
	local border = Theme.COLORS["Upper box border"]
	local color = 0xF0000000
	gui.drawRectangle(x, y, w, h, border, color)
end

---Creates a new IAnimation for a GachaMon Pack Opening
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param gachamon IGachaMon The GachaMon data used to display the card
---@return IAnimation
function AnimationManager.createGachaMonPackOpening(x, y, gachamon)
	local cardOffsetX, cardOffsetY = -6, 4

	local animation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		KeyFrames = {},
		OnExpire = function(self)
			self:stop()
			TrackerScreen.Animations.GachaMonPackOpening = nil
			TrackerScreen.Animations.GachaMonCardDisplay = AnimationManager.createGachaMonCardDisplay(
				self.X + cardOffsetX,
				self.Y + cardOffsetY,
				self.Temp.GachaMon
			)
		end,
		Temp = {
			GachaMon = gachamon,
		},
	})

	-- Gachamon Card Display Data
	local cardpackFilePath = GachaMonFileManager.getCardPackFilePath()
	local cardpackW, cardpackH = 64, 96

	local drawCardObfuscationBg = function(_x, _y)
		local color = 0xFF000000
		gui.drawRectangle(_x - 5, _y - 5, cardpackW + 10, cardpackH + 10, color, color)
	end
	local drawPack = function(_x, _y)
		Drawing.drawImage(cardpackFilePath, _x, _y)
	end

	-- Initial drawing, showing the unopened pack; a still image until its clicked on to be animated
	animation.KeyFrames[1] = AnimationManager.IKeyFrame:new({
		Duration = 6,
		Draw = function(self, _x, _y)
			_coverScreenInDarkness()
			drawPack(_x, _y)
		end,
	})

	local numKeyFramesToDrop = 60
	for i = 2, numKeyFramesToDrop, 1 do
		animation.KeyFrames[i] = AnimationManager.IKeyFrame:new({
			Duration = 3,
			Draw = function(self, _x, _y)
				_coverScreenInDarkness()
				local card = gachamon:getCardDisplayData()
				GachaMonOverlay.drawGachaCard(card, _x + cardOffsetX, _y + cardOffsetY, 4, false, false)
				local iY = _y + (i-1) * 2
				drawCardObfuscationBg(_x, iY)
				drawPack(_x, iY)
			end,
		})
	end

	animation:buildAnimation()

	return animation
end

---Creates a new IAnimation for a GachaMon Pack Opening
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param gachamon IGachaMon The GachaMon data used to display the card
---@return IAnimation
function AnimationManager.createGachaMonCardDisplay(x, y, gachamon)
	local animation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		ShouldLoop = true,
		KeyFrames = {
			AnimationManager.IKeyFrame:new({
				Duration = 600,
				Draw = function(self, _x, _y)
					_coverScreenInDarkness()
					local card = gachamon:getCardDisplayData()
					GachaMonOverlay.drawGachaCard(card, _x, _y, 4, false, false)
				end,
			})
		},
		OnExpire = function(self)
			self:stop()
			TrackerScreen.Animations.GachaMonCardDisplay = nil
			GachaMonData.clearNewestMonToShow()
			Program.redraw(true)
		end,
		Temp = {
			GachaMon = gachamon,
		},
	})

	return animation
end

---Checks if there are any active animations in need of animating
---@return boolean
function AnimationManager.anyActive()
	return next(AnimationManager.ActiveAnimations) ~= nil
end

---"Animates" the active animations by incrementing their frame counters
function AnimationManager.stepFrames()
	if not AnimationManager.anyActive() then
		return
	end
	local toRemove = {}
	for guid, animation in pairs(AnimationManager.ActiveAnimations or {}) do
		animation:stepFrame()
		if not animation.IsActive then
			table.insert(toRemove, guid)
		end
	end
	for _, guid in ipairs(toRemove) do
		AnimationManager.ActiveAnimations[guid] = nil
	end
end

---Adds an IAnimation to the list of ActiveAnimations; starts the animation if not already active
---@param animation IAnimation
---@return boolean success
function AnimationManager.tryAddAnimationToActive(animation)
	if AnimationManager.ActiveAnimations[animation.GUID] then
		return false
	end
	if not animation.IsActive then
		animation:start()
	end
	if animation.IsActive then
		AnimationManager.ActiveAnimations[animation.GUID] = animation
		return true
	end
	return false
end

---Draws a specific animation
---@param animation? IAnimation
function AnimationManager.drawAnimation(animation)
	if animation and animation:IsVisible() then
		animation:draw()
	end
end

---Draws all visible ActiveAnimations
function AnimationManager.drawActiveAnimations()
	for _, animation in pairs(AnimationManager.ActiveAnimations or {}) do
		AnimationManager.drawAnimation(animation)
	end
end

---@class IAnimation
AnimationManager.IAnimation = {
	-- A unique-identifier that is automatically generated
	GUID = "",
	-- The X-coordinate used for the drawing animation
	X = 0,
	-- The Y-coordinate used for the drawing animation
	Y = 0,
	-- When a new keyframe is reached, use the new drawing method and request a draw action by the Tracker (outside normal 30 fps cadence)
	KeyFrames = {}, ---@type table<number, IKeyFrame>
	-- The current key frame index this animation is on (dictates what is drawn)
	CurrentKeyFrameIndex = 0,
	-- To determine if animation frames need to be calculated
	IsActive = false,
	-- Should the animation loop indefinitely; default; false
	ShouldLoop = false,
	-- For some animations, it should only animate if the animation would actually be visible (on appropriate screen or tab)
	IsVisible = function(self) return true end,
	-- An optional function to call when this animation fully ends (won't apply if looping)
	OnExpire = function(self) end,
	-- Temporary data
	Temp = {},

	-- Internal attributes

	-- Internal tracking for counting animation frames
	_FramesElapsed = 0, ---@protected
	-- Internal tracking for total animation frames
	_TotalDuration = 0, ---@protected
	-- Internal index reference to determine which keyframe is currently being drawn
	_KeyFrameIndexes = {}, ---@protected

	-- Functions

	-- Calculates the values and indexes needed for a proper animation; call after all KeyFrames are added
	buildAnimation = function(self)
		-- Assign each active frame to its corresponding sprite index (which image from left-to-right to draw)
		for keyFrameIndex, keyframe in ipairs(self.KeyFrames) do
			for i = 0, (keyframe.Duration or 0) - 1, 1 do
				self._KeyFrameIndexes[self._TotalDuration + i] = keyFrameIndex
			end
			self._TotalDuration = self._TotalDuration + (keyframe.Duration or 0)
		end
		self.CurrentKeyFrameIndex = self._KeyFrameIndexes[0]
	end,
	start = function(self)
		self.IsActive = true
	end,
	stop = function(self)
		self.IsActive = false
	end,
	stepFrame = function(self)
		if not self.IsActive or not self:IsVisible() then
			return
		end
		-- Sync with client frame rate (turbo/unthrottle)
		local delta = 1.0 / Program.clientFpsMultiplier
		local prevFramesElapsed = self._FramesElapsed
		self._FramesElapsed = (self._FramesElapsed + delta) % self._TotalDuration
		-- If exceeded total duration
		if not self.ShouldLoop and self._FramesElapsed < prevFramesElapsed then
			local keyframe = self.KeyFrames[self.CurrentKeyFrameIndex or false]
			if keyframe then
				keyframe:OnExpire()
			end
			self:OnExpire()
			self:stop()
			return
		end
		-- Check if key frame index has changed. If so, trigger a screen redraw
		local prevIndex = self.CurrentKeyFrameIndex
		self.CurrentKeyFrameIndex = self._KeyFrameIndexes[math.floor(self._FramesElapsed)] or 1
		if self.CurrentKeyFrameIndex ~= prevIndex then
			local keyframe = self.KeyFrames[prevIndex]
			if keyframe then
				keyframe:OnExpire()
			end
			Program.Frames.waitToDraw = 0
		end
	end,
	draw = function(self)
		local keyframe = self.KeyFrames[self.CurrentKeyFrameIndex or false]
		if keyframe and type(keyframe.Draw) == "function" then
			keyframe:Draw(self.X, self.Y)
		end
	end,
}
---Creates and returns a new IAnimation object
---@param o? table Optional initial object table
---@return IAnimation animation An IAnimation object
function AnimationManager.IAnimation:new(o)
	o = o or {}
	o.GUID = o.GUID or Utils.newGUID()
	o.X = o.X or 0
	o.Y = o.Y or 0
	o.KeyFrames = o.KeyFrames or {} ---@type table<number, IKeyFrame>
	o.CurrentKeyFrameIndex = 0
	o.ShouldLoop = (o.ShouldLoop == true)
	o.IsVisible = o.IsVisible or function() return true end
	o.OnExpire = o.OnExpire or function() return true end
	o.Temp = o.Temp or {}

	o.IsActive = false
	o._FramesElapsed = 0
	o._TotalDuration = 0
	o._KeyFrameIndexes = {}

	if #o.KeyFrames > 0 then
		AnimationManager.IAnimation.buildAnimation(o)
	end

	setmetatable(o, self)
	self.__index = self
	return o
end

---@class IKeyFrame
AnimationManager.IKeyFrame = {
	-- Number of frames this key frame animation segment is active for
	Duration = 0,
	-- The draw function to perform during this key frame animation segment
	Draw = function(self, x, y) end,
	-- An optional function to call when this frame expires (completes its duration)
	OnExpire = function(self) end,
}
---Creates and returns a new IKeyFrame object
---@param o? table Optional initial object table
---@return IKeyFrame keyframe An IKeyFrame object
function AnimationManager.IKeyFrame:new(o)
	o = o or {}
	o.Duration = o.Duration or 0
	o.Draw = o.Draw or function(this, x, y) end
	o.OnExpire = o.OnExpire or function(this) end
	setmetatable(o, self)
	self.__index = self
	return o
end

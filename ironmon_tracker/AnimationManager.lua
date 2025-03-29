AnimationManager = {
	-- A key-value table of all active IAnimation objects
	---@type table<string, IAnimation>
	ActiveAnimations = {},
}

function AnimationManager.initialize()
	AnimationManager.ActiveAnimations = {}
end

---Creates a new IAnimation for a GachaMon Pack Opening
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param gachamon IGachaMon The GachaMon data used to display the card
---@return IAnimation
function AnimationManager.createGachaMonPackOpening(x, y, gachamon)
	local animation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		KeyFrames = {},
	})

	-- Initial drawing, showing the unopened pack; a still image until its clicked on to be animated
	animation.KeyFrames[1] = AnimationManager.IKeyFrame:new({
		Duration = 5,
		Draw = function(self)
			-- TODO
		end,
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
---@param animation IAnimation
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
	-- To determine if animation frames need to be calculated
	IsActive = false,
	-- Should the animation loop indefinitely; default; false
	ShouldLoop = false,
	-- For some animations, it should only animate if the animation would actually be visible (on appropriate screen or tab)
	IsVisible = function(self) return true end,

	-- Internal attributes

	-- Internal tracking for counting animation frames
	_FramesElapsed = 0, ---@protected
	-- Internal tracking for total animation frames
	_TotalDuration = 0, ---@protected
	-- Internal, the current key frame index this animation is on (dictates what is drawn)
	_CurrentKeyFrameIndex = 0, ---@protected
	-- Internal index reference to determine which keyframe is currently being drawn
	_KeyFrameIndexes = {}, ---@protected

	-- Functions

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
			self:stop()
			return
		end
		-- Check if key frame index has changed. If so, trigger a screen redraw
		local prevIndex = self._CurrentKeyFrameIndex
		self._CurrentKeyFrameIndex = self._KeyFrameIndexes[math.floor(self._FramesElapsed)] or 1
		if self._CurrentKeyFrameIndex ~= prevIndex then
			Program.Frames.waitToDraw = 0
		end
	end,
	draw = function(self)
		local keyframe = self.KeyFrames[self.__CurrentKeyFrameIndex or false]
		if keyframe and type(keyframe.Draw) == "function" then
			keyframe:Draw()
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
	o.KeyFrames = o.KeyFrames or {}
	o.ShouldLoop = (o.ShouldLoop == true)
	o.IsVisible = o.IsVisible or function() return true end

	o.IsActive = false
	o._FramesElapsed = 0
	o._TotalDuration = 0
	o._CurrentKeyFrameIndex = 0
	o._KeyFrameIndexes = {}

	-- Assign each active frame to its corresponding sprite index (which image from left-to-right to draw)
	for keyFrameIndex, keyframe in ipairs(o.KeyFrames) do
		for i = 0, (keyframe.Duration or 0) - 1, 1 do
			o._KeyFrameIndexes[o._TotalDuration + i] = keyFrameIndex
		end
		o._TotalDuration = o._TotalDuration + (keyframe.Duration or 0)
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
	Draw = function(self) end,
}
---Creates and returns a new IKeyFrame object
---@param o? table Optional initial object table
---@return IKeyFrame keyframe An IKeyFrame object
function AnimationManager.IKeyFrame:new(o)
	o = o or {}
	o.Duration = o.Duration or 0
	o.Draw = o.Draw or function() end
	setmetatable(o, self)
	self.__index = self
	return o
end

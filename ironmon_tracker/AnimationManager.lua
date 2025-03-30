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

	Utils.printDebug("--- Animation Created: %s", animation.GUID)

	-- Gachamon Card Display Data
	local card = gachamon:getCardDisplayData()

	-- Pack Dimensions
	local PACK = { w = 100, h = 200, top_h = 10, bot_h = 10 }
	-- All Colors
	local COLORS = {
		blackBG = 0xE0000000,
		bg1 = Drawing.Colors.DARKGRAY,
		bg2 = Drawing.Colors.MAGENTA,
		border = Drawing.Colors.WHITE,
		tearLine = Drawing.Colors.CYAN,
		brighten = 0x40FFFFFF,
		darken = 0x40000000,
	}

	-- [Animation] Design UI and animation for capturing a new GachaMon
	-- (click to open: fade to black, animate pack, animate opening, show mon)

	local drawPack = function(x2, y2)
		local PAD, DENT = 4, 4
		x2 = x2 + PAD
		y2 = y2 + PAD
		-- Backgrounds
		gui.drawRectangle(x2 - PAD, y2 - PAD, PACK.w + PAD * 2, PACK.h + PAD * 2, COLORS.blackBG, COLORS.blackBG)
		gui.drawRectangle(x2, y2, PACK.w, PACK.top_h, COLORS.bg2, COLORS.bg2)
		gui.drawRectangle(x2, y2 + PACK.top_h, PACK.w, DENT, COLORS.bg1, COLORS.bg1)
		gui.drawRectangle(x2 + 1, y2 + PACK.top_h + DENT, PACK.w - 2, PACK.h - PACK.top_h - PACK.bot_h - (DENT * 2), COLORS.bg1, COLORS.bg1)
		-- Curved edges
		gui.drawRectangle(x2 + 1, y2 + PACK.top_h + DENT, DENT, PACK.h - PACK.top_h - PACK.bot_h - (DENT * 2), COLORS.brighten, COLORS.brighten)
		gui.drawRectangle(x2 + PACK.w - DENT - 2, y2 + PACK.top_h + DENT, DENT, PACK.h - PACK.top_h - PACK.bot_h - (DENT * 2), COLORS.darken, COLORS.darken)
		-- gui.drawRectangle(x2, y2 + PACK.h - PACK.bot_h - DENT, PACK.w, DENT, COLORS.bg1, COLORS.bg1)
		-- Top line
		gui.drawLine(x2, y2, x2 + PACK.w, y2, COLORS.border)
		-- Top tear line
		gui.drawLine(x2, y2 + PACK.top_h, x2 + PACK.w, y2 + PACK.top_h, COLORS.tearLine)
		-- Top left/right line
		gui.drawLine(x2, y2, x2, y2 + PACK.top_h + DENT, COLORS.border)
		gui.drawLine(x2 + PACK.w, y2, x2 + PACK.w, y2 + PACK.top_h + DENT, COLORS.border)
		-- Left/Right dented line
		gui.drawLine(x2 + 1, y2 + PACK.top_h + DENT, x2 + 1, y2 + PACK.h - PACK.bot_h - DENT, COLORS.border)
		gui.drawLine(x2 + PACK.w - 1, y2 + PACK.top_h + DENT, x2 + PACK.w - 1, y2 + PACK.h - PACK.bot_h - DENT, COLORS.border)
		-- Bot left/right line
		-- gui.drawLine(x2, y2 + PACK.h, x2, y2 + PACK.h - PACK.bot_h - DENT, COLORS.border)
		-- gui.drawLine(x2 + PACK.w, y2 + PACK.h, x2 + PACK.w, y2 + PACK.h - PACK.bot_h - DENT, COLORS.border)

		-- TODO: Draw large logo
	end

	-- Initial drawing, showing the unopened pack; a still image until its clicked on to be animated
	animation.KeyFrames[1] = AnimationManager.IKeyFrame:new({
		Duration = 2,
		Draw = function(self, animationX, animationY)
			drawPack(animationX, animationY)
		end,
	})

	animation:buildAnimation()

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

	-- Calculates the values and indexes needed for a proper animation; call after all KeyFrames are added
	buildAnimation = function(self)
		-- Assign each active frame to its corresponding sprite index (which image from left-to-right to draw)
		for keyFrameIndex, keyframe in ipairs(self.KeyFrames) do
			for i = 0, (keyframe.Duration or 0) - 1, 1 do
				self._KeyFrameIndexes[self._TotalDuration + i] = keyFrameIndex
			end
			self._TotalDuration = self._TotalDuration + (keyframe.Duration or 0)
		end
		self._CurrentKeyFrameIndex = self._KeyFrameIndexes[0]
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
		local keyframe = self.KeyFrames[self._CurrentKeyFrameIndex or false]
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
	o.ShouldLoop = (o.ShouldLoop == true)
	o.IsVisible = o.IsVisible or function() return true end

	o.IsActive = false
	o._FramesElapsed = 0
	o._TotalDuration = 0
	o._CurrentKeyFrameIndex = 0
	o._KeyFrameIndexes = {}

	if #o.KeyFrames > 0 then
		o:buildAnimation()
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
}
---Creates and returns a new IKeyFrame object
---@param o? table Optional initial object table
---@return IKeyFrame keyframe An IKeyFrame object
function AnimationManager.IKeyFrame:new(o)
	o = o or {}
	o.Duration = o.Duration or 0
	o.Draw = o.Draw or function(this, x, y) end
	setmetatable(o, self)
	self.__index = self
	return o
end

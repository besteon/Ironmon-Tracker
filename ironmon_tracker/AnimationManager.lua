AnimationManager = {
	---A key-value table of all active IAnimation objects
	---@type table<string, IAnimation>
	ActiveAnimations = {},

	---Named animation objects used for various GachaMon releated features
	---@type table<string, IAnimation>
	GachaMonAnims = {}
}

-- NOTE: For now, most/all animation functions are disabled for MGBA; GachaMonData.isCompatibleWithEmulator()

function AnimationManager.initialize()
	AnimationManager.ActiveAnimations = {}
	AnimationManager.GachaMonAnims = {}
end

function AnimationManager.drawGachaMonAnims()
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	local AMG = AnimationManager.GachaMonAnims
	-- Draw in a specific order
	if AMG.PackOpening then
		AnimationManager.drawAnimation(AMG.PackOpening)
		AnimationManager.drawAnimation(AMG.PackHelpText)
	elseif AMG.CardDisplay then
		AnimationManager.drawAnimation(AMG.CardDisplay)
	end
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

local _drawTrainerInfo = function(x, y, trainerInfo)
	if not (trainerInfo and trainerInfo.name and trainerInfo.routeName) then
		return
	end
	x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 2
	y = Constants.SCREEN.MARGIN + 2
	if not Utils.isNilOrEmpty(trainerInfo.image) then
		local imageX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN - 32
		local imageY = Constants.SCREEN.MARGIN + 2
		Drawing.drawImage(trainerInfo.image, imageX, imageY)
	end
	-- Header
	local headerText = string.format("%s:", Resources.GachaMonAnimations.LabelPrizeCardFromTrainer)
	Drawing.drawText(x, y, headerText, 0xFFFCED86)
	-- Trainer Name & Class
	Drawing.drawText(x, y + 10, trainerInfo.name, Drawing.Colors.WHITE)
	-- Route
	local routeColor = Drawing.Colors.WHITE - Drawing.ColorEffects.DARKEN
	local routeText = trainerInfo.routeName
	Drawing.drawImageAsPixels(Constants.PixelImages.MAP_PINDROP, x + 2, y + 23, routeColor)
	Drawing.drawText(x + 13, y + 22, routeText, routeColor)
end

local _drawNewLabel = function(x, y)
	local LABEL_NEW = Resources.GachaMonAnimations.LabelTabNEW
	local NEW_W, NEW_H = 28, 14
	local border, bg = 0xFFFD7DFF, 0xFFE849A2
	local text, shadow = Drawing.Colors.WHITE, (Drawing.ColorEffects.DARKEN * 2)
		-- fill + 4 borders
	gui.drawRectangle(x + 1, y + 1, NEW_W - 2, NEW_H - 2, bg, bg)
	gui.drawLine(x + 1, y, x + NEW_W - 1, y, border)
	gui.drawLine(x + 1, y + NEW_H, x + NEW_W - 1, y + NEW_H, border)
	gui.drawLine(x, y + 1, x, y + NEW_H - 1, border)
	gui.drawLine(x + NEW_W, y + 1, x + NEW_W, y + NEW_H - 1, border)
	-- inner text
	gui.drawText(x + 2, y, LABEL_NEW, shadow, nil, 11, Constants.Font.FAMILY)
	gui.drawText(x + 1, y - 1, LABEL_NEW, text, nil, 11, Constants.Font.FAMILY)
end

---Creates a new IAnimation for a GachaMon card shiny / holographic foil by drawing an image sprite sheet instead of Bizhawk `gui`
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param timeToExpire number Number of seconds before this animation expires
---@param startFrameIndex? number Optional starting frame index (1-50) to sync up animations; default random
---@return IAnimation? animation
function AnimationManager.createGachaMonShinySparklesImage(x, y, timeToExpire, startFrameIndex)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	local W, H = 48, 48
	-- TODO: Update this to a formal location if this function gets used
	local SPRITE_SHEET = FileManager.buildImagePath(FileManager.Folders.GachaMonImages, "shiny-sparkles", FileManager.Extensions.PNG)
	local NUM_FRAMES = 50
	local FRAME_DURATION = 8
	local EMPTY_FRAMES = { [49] = true, [50] = true }

	startFrameIndex = startFrameIndex or math.random(NUM_FRAMES)

	local animation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		ShouldLoop = true,
		KeyFrames = {},
		Temp = {
			StartTime = os.time(),
			EndTime = os.time() + (timeToExpire or 0),
		}
	})

	for i = startFrameIndex, startFrameIndex + NUM_FRAMES, 1 do
		if EMPTY_FRAMES[i] then
			-- Add an empty animation keyframe for sparkle cooldown
			animation:addKeyFrame(FRAME_DURATION * 2)
		else
			local col = i % 10
			local row = math.floor(i / 10) % 5
			local sourceX = col * W
			local sourceY = row * H
			animation:addKeyFrame(FRAME_DURATION, function(self, _x, _y)
				Drawing.drawImageRegion(SPRITE_SHEET, sourceX, sourceY, W, H, _x, _y)
			end, function(self)
				if os.time() >= animation.Temp.EndTime then
					animation:stop()
				end
			end)
		end
	end

	animation:buildAnimation()

	return animation
end

---Creates new IAnimations for a GachaMon card shiny / holographic foil (paired sparkle animations)
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param timeToExpire number Number of seconds before this animation expires
---@return table<number, IAnimation>? animations
function AnimationManager.createGachaMonShinySparkles(x, y, timeToExpire)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	-- TODO: consider different types of shiny animation or holographic foil

	local animations = {
		AnimationManager.IAnimation:new({
			X = x,
			Y = y,
			ShouldLoop = true,
			KeyFrames = {},
			Temp = {
				StartTime = os.time(),
				EndTime = os.time() + (timeToExpire or 0)
			}
		}),
		AnimationManager.IAnimation:new({
			X = x,
			Y = y,
			ShouldLoop = true,
			KeyFrames = {},
			Temp = {
				StartTime = os.time(),
				EndTime = os.time() + (timeToExpire or 0)
			}
		}),
	}

	local SPARKLE_ICON = Constants.PixelImages.SPARKLES
	local W, H = 68, 68
	local COLORS = {
		fade1 = 0x44FFFFFF,
		fade2 = 0x88FFFFFF,
		full = 0xFFFFFFFF,
	}

	-- Creation functions
	local createKeyFrame = function(_anim, xOffset, yOffset, duration, color)
		return AnimationManager.IKeyFrame:new({
			Duration = duration,
			Draw = function(self, _x, _y)
				Drawing.drawImageAsPixels(SPARKLE_ICON, _x + xOffset, _y + yOffset, color)
			end,
			OnExpire = function(self)
				if os.time() >= _anim.Temp.EndTime then
					_anim:stop()
				end
			end,
		})
	end

	local createSparkle = function(_anim, delayFrames)
		local xOffset, yOffset = math.random(-1, W - 10), math.random(-1, H - 10)
		-- Startup Delay
		table.insert(_anim.KeyFrames, AnimationManager.IKeyFrame:new({ Duration = delayFrames }))
		-- Startup sparkle
		table.insert(_anim.KeyFrames, createKeyFrame(_anim, xOffset, yOffset, 10, COLORS.fade1))
		table.insert(_anim.KeyFrames, createKeyFrame(_anim, xOffset, yOffset, 10, COLORS.fade2))
		-- Bright sparkle
		table.insert(_anim.KeyFrames, createKeyFrame(_anim, xOffset, yOffset, 30, COLORS.full))
		-- Fade sparkle
		table.insert(_anim.KeyFrames, createKeyFrame(_anim, xOffset, yOffset, 10, COLORS.fade2))
		table.insert(_anim.KeyFrames, createKeyFrame(_anim, xOffset, yOffset, 10, COLORS.fade1))
	end

	-- Creation N different sparkles, sometimes with a paired sparkle
	local numSparklePairs = math.random(8, 12)
	local delayFrames = 0
	for _ = 1, numSparklePairs, 1 do
		createSparkle(animations[1], delayFrames)
		if math.random(3) == 1 then
			createSparkle(animations[2], delayFrames + 25)
		end
		delayFrames = 4 * math.random(0, 4)
	end

	for _, animation in pairs(animations) do
		animation:buildAnimation()
	end

	return animations
end

---Creates a new IAnimation for a GachaMon Pack Opening
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param gachamon IGachaMon The GachaMon data used to display the card
---@param trainerInfo? table<string, any> Optional, if this card was obtained as a prize from a trainer victory, use that to display data
---@return IAnimation?
function AnimationManager.createGachaMonPackOpening(x, y, gachamon, trainerInfo)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end

	local SHOW_HELP_FRAME_DELAY = 210
	local cardOffsetX, cardOffsetY = -1, 13

	local packAnimation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		KeyFrames = {},
		OnExpire = function(self)
			self:stop()
			AnimationManager.GachaMonAnims.PackOpening = nil
			AnimationManager.GachaMonAnims.CardDisplay = AnimationManager.createGachaMonCardDisplay(
				self.X + cardOffsetX,
				self.Y + cardOffsetY,
				self.Temp.GachaMon,
				trainerInfo
			)
			Program.Frames.waitToDraw = 0
		end,
		Temp = {
			GachaMon = gachamon,
		},
	})

	local rightEdgeCutoff = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
	local bottomEdgeCutoff = Constants.SCREEN.HEIGHT - Constants.SCREEN.MARGIN - 1

	-- Gachamon Card Display Data
	local cardpackFilePath = GachaMonFileManager.getRandomCardPackFilePath()
	local cardpackW, cardpackH = 64, 96
	local colorPopOpen = 0xFFFFFFFF
	local colorObfuscation = 0xFF000000

	local _createHelpTextAnimation = function()
		local openButton = Options.CONTROLS["Next page"] or "R"
		if openButton == Input.NO_KEY_MAPPING then
			openButton = Constants.BLANKLINE
		end

		local helpTextFormat = string.format("--  %s  --", Resources.GachaMonAnimations.LabelPressBUTTONtoOpen)
		local helpText = string.format(helpTextFormat, openButton)
		local helpTextX = Utils.getCenteredTextX(helpText, Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN * 2)
		local helpTextY = trainerInfo ~= nil and (y + cardpackH + 1) or (y + cardpackH + 7)
		local helpTextAnimation = AnimationManager.IAnimation:new({
			X = x + helpTextX - 38,
			Y = helpTextY,
			ShouldLoop = true,
			KeyFrames = {},
			IsVisible = function(self)
				return not packAnimation.IsActive and packAnimation:IsVisible()
			end,
		})
		local _onExpireHelpText = function(self)
			if packAnimation.IsActive or not packAnimation:IsVisible() then
				helpTextAnimation:stop()
				AnimationManager.GachaMonAnims.PackHelpText = nil
			end
		end
		for i=1, 160, 4 do
			-- color fade in/out
			local opacity = 0
			if i < 50 then
				opacity = 1 - math.abs(i - 50) / 50
			elseif i >= 50 and i <= 100 then
				opacity = 1
			elseif i > 100 then
				opacity = 1 - math.min(math.abs(i - 100) / 50, 1) -- max
			end
			local opacityFill = math.min(math.floor(0xFF * opacity), 0xFF) -- max
			local helpTextColor = (0x01000000 * opacityFill) + 0xFFFFFF
			helpTextAnimation:addKeyFrame(5, function(self, _x, _y)
				Drawing.drawText(_x, _y, helpText, helpTextColor)
			end, _onExpireHelpText)
		end
		helpTextAnimation:buildAnimation()
		-- If somehow an old help text for a regular card pack opening is still active, disable it
		if AnimationManager.GachaMonAnims.PackHelpText then
			AnimationManager.GachaMonAnims.PackHelpText:stop()
		end
		AnimationManager.tryAddAnimationToActive(helpTextAnimation)
		AnimationManager.GachaMonAnims.PackHelpText = helpTextAnimation
	end

	-- Add another animation to show help text on how to open packs
	Program.addFrameCounter("AnimationManager:PackOpeningHelpText", SHOW_HELP_FRAME_DELAY, _createHelpTextAnimation, 1, true)

	local drawPack = function(_x, _y)
		Drawing.drawImage(cardpackFilePath, _x, _y)
	end
	local drawCardObfuscationBg = function(_x, _y)
		_x = _x - 2
		_y = _y + 16
		local botH = cardpackH - 6
		if _y + botH >= bottomEdgeCutoff then
			botH = bottomEdgeCutoff - _y
		end
		if botH > 0 then
			gui.drawRectangle(_x, _y, cardpackW + 4, botH, colorObfuscation, colorObfuscation)
		end
	end
	local drawPackTopPiece = function(_x, _y)
		local topW = cardpackW
		if _x + topW >= rightEdgeCutoff then
			topW = rightEdgeCutoff - _x
		end
		if topW > 0 then
			Drawing.drawImageRegion(cardpackFilePath, 0, 0, topW, 14, _x, _y)
		end
	end
	local drawPackCutPiece = function(_x, _y, _cutW)
		local uncutW = cardpackW - _cutW
		if uncutW > 0 then
			-- _x = _x + _chunkW
			_y = _y + 14
			Drawing.drawImageRegion(cardpackFilePath, 0, 14, uncutW, 3, _x, _y)
		end
	end
	local drawPackBottomPiece = function(_x, _y)
		local botH = 79
		_y = _y + 17
		if _y + botH >= bottomEdgeCutoff then
			botH = bottomEdgeCutoff - _y
		end
		if botH > 0 then
			Drawing.drawImageRegion(cardpackFilePath, 0, 17, cardpackW, botH, _x, _y)
		end
	end

	-- TODO: special animation if card stars are 5+

	-- Initial drawing, showing the unopened pack; a still image until its clicked on to be animated
	packAnimation:addKeyFrame(1, function(self, _x, _y)
		_coverScreenInDarkness()
		_drawTrainerInfo(_x, _y, trainerInfo)
		drawPack(_x, _y)
	end)

	local cutSpeed = 4
	local numKeyFramesToCutOpen = cardpackW / cutSpeed
	for i = 1, numKeyFramesToCutOpen - 1, 1 do
		packAnimation:addKeyFrame(1, function(self, _x, _y)
			_coverScreenInDarkness()
			_drawTrainerInfo(_x, _y, trainerInfo)
			drawPackTopPiece(_x, _y)
			local cutW = i * cutSpeed
			drawPackCutPiece(_x, _y, cutW)
			drawPackBottomPiece(_x, _y)
		end)
	end

	-- Frame: Pop off the top of the pack
	packAnimation:addKeyFrame(15, function(self, _x, _y)
		_coverScreenInDarkness()
		_drawTrainerInfo(_x, _y, trainerInfo)
		drawPackTopPiece(_x, _y)
		drawPackBottomPiece(_x, _y)
		-- top right
		_x = _x + cardpackW
		gui.drawLine(_x - 1, _y - 2, _x + 1, _y - 6, colorPopOpen)
		gui.drawLine(_x - 4, _y - 2, _x - 6, _y - 6, colorPopOpen)
		gui.drawLine(_x + 1, _y + 0, _x + 5, _y - 2, colorPopOpen)
		gui.drawLine(_x + 1, _y + 3, _x + 5, _y + 5, colorPopOpen)
	end)

	-- If want slower, set to: frames 32 and speed 3
	local numKeyFramesToSlideAway = 24
	for i = 1, numKeyFramesToSlideAway, 1 do
		packAnimation:addKeyFrame(1, function(self, _x, _y)
			_coverScreenInDarkness()
			_drawTrainerInfo(_x, _y, trainerInfo)
			local iX = _x + (i-1) * 4
			drawPackTopPiece(iX, _y)
			drawPackBottomPiece(_x, _y)
		end)
	end

	packAnimation:addKeyFrame(8, function(self, _x, _y)
		_coverScreenInDarkness()
		_drawTrainerInfo(_x, _y, trainerInfo)
		drawPackBottomPiece(_x, _y)
	end)

	local numKeyFramesToDropDown = 111
	if trainerInfo ~= nil then
		numKeyFramesToDropDown = numKeyFramesToDropDown - 15
	end
	for i = 1, numKeyFramesToDropDown, 1 do
		packAnimation:addKeyFrame(1, function(self, _x, _y)
			_coverScreenInDarkness()
			_drawTrainerInfo(_x, _y, trainerInfo)
			local card = gachamon:getCardDisplayData()
			GachaMonOverlay.drawGachaCard(card, _x + cardOffsetX, _y + cardOffsetY, 0, false, false)
			local iY = _y + (i-1) * 1
			drawCardObfuscationBg(_x, iY)
			drawPackBottomPiece(_x, iY)
		end)
	end

	packAnimation:buildAnimation()

	return packAnimation
end

---Creates a new IAnimation for a GachaMon Pack Opening
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param gachamon IGachaMon The GachaMon data used to display the card
---@param trainerInfo? table<string, any> Optional, if this card was obtained as a prize from a trainer victory, use that to display data
---@return IAnimation?
function AnimationManager.createGachaMonCardDisplay(x, y, gachamon, trainerInfo)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end

	local isNewSpecies = GachaMonData.checkIfNewCollectionSpecies(gachamon)

	local animation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		ShouldLoop = true,
		KeyFrames = {
			AnimationManager.IKeyFrame:new({
				Duration = 600,
				Draw = function(self, _x, _y)
					_coverScreenInDarkness()
					_drawTrainerInfo(_x, _y, trainerInfo)
					local card = gachamon:getCardDisplayData()
					GachaMonOverlay.drawGachaCard(card, _x, _y, 0, false, false)
					if isNewSpecies then
						_drawNewLabel(_x + 21, _y + 75)
					end
				end,
			})
		},
		OnExpire = function(self)
			self:stop()
			AnimationManager.GachaMonAnims.CardDisplay = nil
			GachaMonData.clearNewestMonToShow()
			-- If this was a prize card from the trainer, view it right away
			if GachaMonData.createdTrainerPrizeCard then
				-- If a different overlay is open, close that first
				if Program.currentOverlay ~= GachaMonOverlay then
					Program.closeScreenOverlay()
				end
				Program.openOverlayScreen(GachaMonOverlay)
				GachaMonOverlay.currentTab = GachaMonOverlay.Tabs.View
				GachaMonOverlay.Data.View.GachaMon = GachaMonData.createdTrainerPrizeCard
				GachaMonOverlay.refreshButtons()
			end
			Program.redraw(true)
		end,
		Temp = {
			GachaMon = gachamon,
		},
	})

	return animation
end

---Creates a new IAnimation for display the battlefield used for GachaMon card battles
---@param x number Location of the animation to be drawn
---@param y number Location of the animation to be drawn
---@param gachamon1? IGachaMon
---@param gachamon2? IGachaMon
---@return IAnimation? animation
function AnimationManager.createBattlefieldImageReveal(x, y, gachamon1, gachamon2)
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end

	local W, H = 235, 142
	local FRAME_DURATION = 3
	local TERRAINS = {
		Sky = {
			key = "Sky",
			getImage = function() return FileManager.buildImagePath(FileManager.Folders.GachaMonImages, "battle-terrain", FileManager.Extensions.PNG) end,
			sourceX = 1,
			sourceY = 85,
		},
		Mountains = { -- Not currently used
			key = "Mountains",
			getImage = function() return FileManager.buildImagePath(FileManager.Folders.GachaMonImages, "battle-terrain", FileManager.Extensions.PNG) end,
			sourceX = 1,
			sourceY = 250,
		},
		Grass = {
			key = "Grass",
			getImage = function() return FileManager.buildImagePath(FileManager.Folders.GachaMonImages, "battle-terrain", FileManager.Extensions.PNG) end,
			sourceX = 1,
			sourceY = 400,
		},
	}

	-- Determine a random battlefield terrain, or use sky battles for flying Pokémon
	local terrain
	if gachamon1 and gachamon2 then
		local PDTIP, FLYING = PokemonData.TypeIndexMap, PokemonData.Types.FLYING
		local g1Flies = PDTIP[gachamon1.Type1] == FLYING or PDTIP[gachamon1.Type2] == FLYING
		local g2Flies = PDTIP[gachamon2.Type1] == FLYING or PDTIP[gachamon2.Type2] == FLYING
		if g1Flies and g2Flies then
			terrain = TERRAINS.Sky
		end
	end
	-- Consider other terrain options here to just randomly pick one of them
	if not terrain then
		terrain = TERRAINS.Grass
	end
	terrain.image = terrain:getImage()
	terrain.w = W
	terrain.h = H

	local animation = AnimationManager.IAnimation:new({
		X = x,
		Y = y,
		KeyFrames = {},
		OnExpire = function(self)
			GachaMonOverlay.Data.Battle.BattlefieldTerrain = terrain
			Program.Frames.waitToDraw = 0
		end,
	})

	-- TODO: Consider a "BATTLE START!" animation first, put it here

	local totalFrames = 20
	local sourceX, sourceY = terrain.sourceX, terrain.sourceY
	for i = 1, totalFrames, 1 do
		local opacity = 1 - (i / totalFrames)
		local opacityFill = math.min(math.floor(0xFF * opacity), 0xFF) -- max
		local bgColor = 0x01000000 * opacityFill
		animation:addKeyFrame(FRAME_DURATION, function(self, _x, _y)
			-- Start by drawing the background underneath a solid black screen, then reveal piece by piece
			Drawing.drawImageRegion(terrain.image, sourceX, sourceY, W, H, _x, _y)
			gui.drawRectangle(_x, _y, W - 1, H - 1, bgColor, bgColor)
		end)
	end

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
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
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
	if not GachaMonData.isCompatibleWithEmulator() then
		return false
	end
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
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
	if animation and animation:IsVisible() then
		animation:draw()
	end
end

---Draws all visible ActiveAnimations
function AnimationManager.drawActiveAnimations()
	if not GachaMonData.isCompatibleWithEmulator() then
		return
	end
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

	---comment
	---@param duration number
	---@param drawFunc? function
	---@param onExpireFunc? function
	addKeyFrame = function(self, duration, drawFunc, onExpireFunc)
		table.insert(self.KeyFrames, AnimationManager.IKeyFrame:new({
			Duration = duration,
			Draw = drawFunc,
			OnExpire = onExpireFunc,
		}))
	end,
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
		if not self.IsActive then
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

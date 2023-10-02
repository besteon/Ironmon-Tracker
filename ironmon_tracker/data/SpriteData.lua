SpriteData = {
	idleTimeUntilSleep = 55, -- Number of seconds of idle time allowed before all sprites start to sleep
	spritesAfkSleeping = false, -- Internal tracking variable to determine if the Tracker screen mon should be asleep
}

-- Holds list of animation frame data for all Pokémon for the active iconset, uses metatables
SpriteData.IconData = {}
-- Holds a list of icons currently being animated on screen, as only those need to be updated with new animations
SpriteData.ActiveIcons = {}

SpriteData.Types = {
	Idle = "idle",
	Walk = "walk",
	Sleep = "sleep",
	Faint = "faint",
}

SpriteData.DefaultIconSetIndex = 6
SpriteData.DefaultType = SpriteData.Types.Idle

function SpriteData.initialize()
	SpriteData.spritesAfkSleeping = false
	SpriteData.IconData = {}
	SpriteData.ActiveIcons = {}

	local iconset = Options.getIconSet()
	if iconset.isAnimated then
		SpriteData.changeIconSet(iconset)
	else
		SpriteData.changeIconSet(Options.IconSetMap[SpriteData.DefaultIconSetIndex])
	end
end

-- Updates metatable references for SpriteData.IconData to refer to the provided 'iconset'
function SpriteData.changeIconSet(iconset)
	iconset = iconset or {}
	local iconKey = iconset.iconKey or false
	if not iconset.isAnimated or not SpriteData[iconKey] then return end
	local mt = {}
	setmetatable(SpriteData.IconData, mt)
	mt.__index = SpriteData[iconKey]
end

function SpriteData.animationAllowed()
	return Main.IsOnBizhawk() and Options.getIconSet().isAnimated
end

function SpriteData.canDrawPokemonIcon(pokemonID)
	return SpriteData.animationAllowed() and PokemonData.isImageIDValid(pokemonID) and SpriteData.IconData[pokemonID] ~= nil
end

function SpriteData.screenCanControlWalking(screen)
	local allowedScreens = {
		[TrackerScreen] = Tracker.getPokemon(1, true) ~= nil, -- only allow walking if player has a pokemon
	}
	return Options["Allow sprites to walk"] and allowedScreens[screen or false]
end

-- Returns the active icon w/ its current animation type, or adds it with the provided animation type
function SpriteData.getOrAddActiveIcon(pokemonID, animationType)
	if not SpriteData.canDrawPokemonIcon(pokemonID) then
		return
	end
	return SpriteData.ActiveIcons[pokemonID] or SpriteData.createActiveIcon(pokemonID, animationType)
end

function SpriteData.createActiveIcon(pokemonID, animationType, startIndexFrame, framesElapsed)
	animationType = animationType or SpriteData.DefaultType
	startIndexFrame = startIndexFrame or 1
	framesElapsed = framesElapsed or 0.0
	if not Options["Allow sprites to walk"] and animationType == SpriteData.Types.Walk then
		animationType = SpriteData.DefaultType
	end

	local icon = SpriteData.IconData[pokemonID][animationType] or SpriteData.IconData[pokemonID][SpriteData.DefaultType]
	if not icon or not icon.durations or #icon.durations == 0 then
		return nil
	end

	-- Assign each active frame to its corresponding sprite index (which image from left-to-right to draw)
	local totalDuration = 0
	local frameToIndex = {}
	for spriteIndex, duration in ipairs(icon.durations) do
		for i = 0, duration - 1, 1 do
			frameToIndex[totalDuration + i] = spriteIndex
		end
		totalDuration = totalDuration + duration
	end
	if totalDuration <= 0 then
		return nil
	end

	local activeIcon = {
		pokemonID = pokemonID,
		animationType = animationType,
		indexFrame = startIndexFrame,
		framesElapsed = framesElapsed,
		totalDuration = totalDuration,
		canLoop = animationType ~= SpriteData.Types.Faint,
		inUse = true,
		step = function(self)
			-- Sync with client frame rate (turbo/unthrottle)
			local delta = 1.0 / Program.clientFpsMultiplier
			self.framesElapsed = (self.framesElapsed + delta) % self.totalDuration
			if not self.canLoop and self.indexFrame >= #icon.durations then
				return
			end
			-- Check if sprite index frame has changed. If so, trigger a screen redraw
			local prevIndex = self.indexFrame
			self.indexFrame = frameToIndex[math.floor(self.framesElapsed)] or 1
			if self.indexFrame ~= prevIndex then
				Program.Frames.waitToDraw = 0
			end
		end
	}
	SpriteData.ActiveIcons[pokemonID] = activeIcon
	return activeIcon
end

function SpriteData.changeActiveIcon(pokemonID, animationType, startIndexFrame, framesElapsed)
	if not SpriteData.canDrawPokemonIcon(pokemonID) then
		return
	end
	animationType = animationType or SpriteData.DefaultType
	if not Options["Allow sprites to walk"] and animationType == SpriteData.Types.Walk then
		animationType = SpriteData.DefaultType
	end

	-- Don't "change" if the active icon already exists with that animation type, or that animation type doesn't exist
	local activeIcon = SpriteData.ActiveIcons[pokemonID]
	if not activeIcon or activeIcon.animationType == animationType or not SpriteData.IconData[pokemonID][animationType] then
		return
	end

	-- Create a new or replacement active icon with the updated animationType
	return SpriteData.createActiveIcon(pokemonID, animationType, startIndexFrame, framesElapsed)
end

-- Changes all active icons to 'animationType' (if able)
function SpriteData.changeAllActiveIcons(animationType)
	for _, activeIcon in pairs(SpriteData.ActiveIcons or {}) do
		SpriteData.changeActiveIcon(activeIcon.pokemonID, animationType)
	end
end

function SpriteData.updateActiveIcons()
	if not SpriteData.animationAllowed() then
		return
	end

	local joypad = Input.getJoypadInputFormatted()
	local canWalk = joypad["Left"] or joypad["Right"] or joypad["Up"] or joypad["Down"]
	local walkableAllowed = SpriteData.screenCanControlWalking(Program.currentScreen)
		and not (Battle.inBattle or Battle.battleStarted or Program.inStartMenu or LogOverlay.isGameOver or LogOverlay.isDisplayed)

	for _, activeIcon in pairs(SpriteData.ActiveIcons or {}) do
		-- Check if the walk/idle animation needs to be updated, reusing frame info
		if walkableAllowed then
			if canWalk and activeIcon.animationType == SpriteData.Types.Idle then
				SpriteData.changeActiveIcon(activeIcon.pokemonID, SpriteData.Types.Walk, activeIcon.indexFrame, activeIcon.framesElapsed)
			elseif not canWalk and activeIcon.animationType == SpriteData.Types.Walk then
				SpriteData.changeActiveIcon(activeIcon.pokemonID, SpriteData.Types.Idle, activeIcon.indexFrame, activeIcon.framesElapsed)
			end
		end

		if type(activeIcon.step) == "function" then
			activeIcon:step()
		end
	end
end

function SpriteData.checkForFaintingStatus(pokemonID, isZeroHP)
	if not SpriteData.canDrawPokemonIcon(pokemonID) or LogOverlay.isDisplayed or SpriteData.spritesAfkSleeping then
		return
	end
	local activeIcon = SpriteData.ActiveIcons[pokemonID]
	if not activeIcon then
		return
	end
	if isZeroHP and activeIcon.animationType ~= SpriteData.Types.Faint then
		SpriteData.changeActiveIcon(pokemonID, SpriteData.Types.Faint)
	elseif not isZeroHP and activeIcon.animationType == SpriteData.Types.Faint then
		SpriteData.changeActiveIcon(pokemonID, SpriteData.DefaultType)
	end
end

function SpriteData.checkForSleepingStatus(pokemonID, status)
	if not SpriteData.canDrawPokemonIcon(pokemonID) or LogOverlay.isDisplayed or SpriteData.spritesAfkSleeping then
		return
	end
	local activeIcon = SpriteData.ActiveIcons[pokemonID]
	if not activeIcon then
		return
	end
	local isAsleep = status == MiscData.StatusCodeMap[MiscData.StatusType.Sleep]
	if isAsleep and activeIcon.animationType ~= SpriteData.Types.Sleep then
		SpriteData.changeActiveIcon(pokemonID, SpriteData.Types.Sleep)
	elseif not isAsleep and activeIcon.animationType == SpriteData.Types.Sleep then
		SpriteData.changeActiveIcon(pokemonID, SpriteData.DefaultType)
	end
end

function SpriteData.checkForIdleSleeping(idleSeconds)
	if not SpriteData.animationAllowed() or LogOverlay.isDisplayed then
		return
	end
	idleSeconds = idleSeconds or 0
	-- Check if the player has returned from being afk and if needed wake up animated sprites
	if SpriteData.spritesAfkSleeping and idleSeconds < SpriteData.idleTimeUntilSleep then
		SpriteData.changeAllActiveIcons(SpriteData.DefaultType)
		SpriteData.spritesAfkSleeping = false
	-- Check if the player has been afk long enough to put animated sprites to sleep
	elseif not SpriteData.spritesAfkSleeping and idleSeconds >= SpriteData.idleTimeUntilSleep then
		SpriteData.changeAllActiveIcons(SpriteData.Types.Sleep)
		SpriteData.spritesAfkSleeping = true
	end
end

-- If an animated icon sprite is no longer being drawn, remove it from the animation frame counters
function SpriteData.cleanupActiveIcons()
	if not SpriteData.animationAllowed() then
		return
	end

	local keysToRemove = {}
	for key, activeIcon in pairs(SpriteData.ActiveIcons or {}) do
		if not activeIcon.inUse then
			table.insert(keysToRemove, key)
		else
			activeIcon.inUse = false
		end
	end
	for _, key in ipairs(keysToRemove) do
		SpriteData.ActiveIcons[key] = nil
	end
end

function SpriteData.getNextAnimType(pokemonID, currentType)
	if not SpriteData.canDrawPokemonIcon(pokemonID) or not currentType then
		return currentType or SpriteData.DefaultType
	end
	local icon = SpriteData.IconData[pokemonID]
	local orderedTypes = {
		SpriteData.Types.Idle,
		Options["Allow sprites to walk"] and SpriteData.Types.Walk or nil, -- exclude from list if not enabled
		SpriteData.Types.Sleep,
		SpriteData.Types.Faint,
	}
	local returnNextType = false
	for _, animType in ipairs(orderedTypes) do
		if returnNextType and icon[animType] then
			return animType
		elseif currentType == animType then
			returnNextType = true
		end
	end
	return SpriteData.DefaultType
end

-- These Sprites were taken from https://sprites.pmdcollab.org/#/
SpriteData.WalkingPals = {
	[1] = {
		[SpriteData.Types.Faint] = { w = 32, h = 24, x = 5, y = 12, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 4, durations = { 40, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 4, durations = { 4, 4, 4, 4, 4, 4 } },
	},
	[2] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 7, durations = { 40, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[3] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 7, durations = { 30, 16, 12, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 8, 16, 8, 16 } },
	},
	[4] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 1, y = 6, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 12, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 8, durations = { 6, 8, 6, 8 } },
	},
	[5] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 0, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = -1, durations = { 40, 2, 3, 3, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[6] = {
		[SpriteData.Types.Faint] = { w = 48, h = 48, x = -3, y = 2, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = -1, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 2, durations = { 15, 15, 15, 15 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[7] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 0, y = 6, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 9, durations = { 30, 2, 2, 4, 4, 4, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 9, durations = { 12, 8, 12, 8 } },
	},
	[8] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 5, durations = { 40, 2, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[9] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 1, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 7, durations = { 32, 12, 4, 4, 4, 4, 4, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 14, 8, 14 } },
	},
	[10] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 8, durations = { 8, 8, 8, 8, 8, 8, 8, 4, 10, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 10, 10, 10 } },
	},
	[11] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 2, durations = { 10, 14, 10, 14 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 1, durations = { 4, 2, 2, 2, 2, 4, 4, 4, 4, 4 } },
	},
	[12] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 8, durations = { 35, 30 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 4, durations = { 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 3, durations = { 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[13] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 6, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 40, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 10, 8 } },
	},
	[14] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 7, durations = { 40, 1, 1, 4, 1, 1 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 7, durations = { 8, 4, 4, 4, 10 } },
	},
	[15] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 56, x = 3, y = 4, durations = { 16, 8, 16, 16, 8, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 4, durations = { 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 4, durations = { 4, 4, 4, 4 } },
	},
	[16] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 16, x = 5, y = 14, durations = { 35, 30 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 3, durations = { 30, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 6, durations = { 6, 4, 4, 4, 4 } },
	},
	[17] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 2, durations = { 40, 2, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 6, 10, 6, 10 } },
	},
	[18] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 2, durations = { 40, 2, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 12, 8, 12 } },
	},
	[19] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 8, durations = { 40, 2, 2, 2, 4, 2, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 48, h = 40, x = -7, y = 2, durations = { 6, 4, 4, 4, 4, 4, 4 } },
	},
	[20] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 35, 30 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 0, durations = { 30, 6, 3, 4, 3, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 2, durations = { 4, 6, 4, 4, 4, 4 } },
	},
	[21] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 4, durations = { 40, 2, 3, 4, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 6, 4, 4, 4, 4 } },
	},
	[22] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 72, x = -3, y = -8, durations = { 40, 20, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -3, y = -1, durations = { 4, 5, 6, 4, 5, 6 } },
	},
	[23] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 1, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 1, durations = { 6, 6, 6, 6, 6, 6 } },
	},
	[24] = {
		[SpriteData.Types.Faint] = { w = 32, h = 48, x = 0, y = 0, durations = { 6, 6, 6 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 2, y = 0, durations = { 32, 14 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -2, y = -1, durations = { 6, 6, 8, 6, 6, 6 } },
	},
	[25] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = -1, y = 3, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -2, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = -1, durations = { 40, 2, 3, 3, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[26] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -2, y = 0, durations = { 40, 2, 4, 4, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -2, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[27] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 40, 2, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 8, durations = { 6, 10, 6, 10 } },
	},
	[28] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 2, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 4, durations = { 25, 10, 25, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[29] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 4, durations = { 24, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = -1, durations = { 6, 4, 4, 4, 4, 4, 4 } },
	},
	[30] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 4, durations = { 40, 2, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 7, durations = { 6, 8, 6, 8 } },
	},
	[31] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 20, 6, 6, 6, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[32] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 0, durations = { 30, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = -2, durations = { 6, 6, 5, 6, 6, 4 } },
	},
	[33] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 2, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 4, durations = { 40, 10, 2, 2, 2, 2, 2, 2, 2, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 4, durations = { 6, 12, 6, 12 } },
	},
	[34] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 1, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 4, durations = { 35, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 3, durations = { 8, 14, 8, 14 } },
	},
	[35] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 4, durations = { 30, 3, 4, 5, 4, 3 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 5, durations = { 8, 4, 8, 4, 8, 4, 8, 4 } },
	},
	[36] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 2, durations = { 30, 6, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 2, durations = { 8, 6, 6, 6, 8, 6, 6, 6 } },
	},
	[37] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 4, y = 6, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 6, durations = { 40, 12, 20, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 6, 4, 4, 4, 6 } },
	},
	[38] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 0, y = 6, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 4, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[39] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 10, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 7, durations = { 25, 8, 15, 8, 15 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 6, 4, 4, 4, 6 } },
	},
	[40] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 11, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 2, durations = { 40, 4, 6, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[41] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 1, durations = { 10, 6, 6, 6, 6, 6, 6, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 3, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[42] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 3, durations = { 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -4, y = 0, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[43] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 5, durations = { 30, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 5, durations = { 8, 4, 8, 6, 8, 4, 8, 6 } },
	},
	[44] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 8, durations = { 6, 8, 6, 8 } },
	},
	[45] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 8, durations = { 35, 30 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 30, 3, 3, 8, 3, 3, 30, 3, 3, 8, 3, 3 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[46] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 4, y = 8, durations = { 24, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 24, x = 0, y = 8, durations = { 6, 8, 6, 8 } },
	},
	[47] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 7, durations = { 40, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[48] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 5, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 6, 6, 6, 8 } },
	},
	[49] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 2, y = 4, durations = { 30, 8, 8, 30, 8, 8 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 2, durations = { 12, 12, 12, 12, 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 4, durations = { 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[50] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 5, y = 8, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 1, durations = { 8, 8, 8 } },
	},
	[51] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 4, durations = { 12, 16 } },
		[SpriteData.Types.Walk] = { w = 56, h = 48, x = -9, y = -2, durations = { 8, 8, 8 } },
	},
	[52] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 1, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 9, durations = { 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 9, durations = { 6, 10, 6, 10 } },
	},
	[53] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 16, x = -1, y = 14, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 1, durations = { 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[54] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 5, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 5, durations = { 16, 20, 16, 20 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 5, durations = { 8, 12, 8, 12 } },
	},
	[55] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 4, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 40, 20, 40, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 12, 8, 12 } },
	},
	[56] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -1, durations = { 40, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = -2, durations = { 8, 4, 4, 4, 8, 4, 4, 4 } },
	},
	[57] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -2, durations = { 22, 4, 6, 4, 22, 4, 6, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 6, 8, 6, 8 } },
	},
	[58] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 3, durations = { 40, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 6, 8, 6, 8 } },
	},
	[59] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 4, durations = { 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[60] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -1, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 3, durations = { 30, 8, 6, 6, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 6, 6, 6, 6 } },
	},
	[61] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 40, 2, 4, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[62] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 2, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[63] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 3, y = 5, durations = { 24, 8, 8, 24, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 5, durations = { 8, 10, 8, 10, 8, 10, 8, 10 } },
	},
	[64] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 6, durations = { 4, 4, 6, 6, 6, 6, 6, 6, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 6, durations = { 8, 12, 8, 12 } },
	},
	[65] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 5, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 12, 8, 12 } },
	},
	[66] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 4, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 5, durations = { 40, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 8, durations = { 8, 8, 8, 8 } },
	},
	[67] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 3, durations = { 40, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[68] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 1, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 4, durations = { 40, 2, 2, 2, 2, 2, 2, 2, 2, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[69] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 13, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 20, 22 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[70] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 12, 10, 12, 12, 10, 12 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 7, durations = { 16, 8, 16, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[71] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 35, 3, 3, 5, 5, 5, 3, 3, 3 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 2, durations = { 6, 8, 6, 8 } },
	},
	[72] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 6, durations = { 4, 8, 8, 4, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[73] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 5, durations = { 6, 10, 10, 6, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[74] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 9, 8, 20, 9, 8, 20 } },
		[SpriteData.Types.Idle] = { w = 32, h = 24, x = 0, y = 11, durations = { 8, 12, 8, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[75] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 1, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 6, 10, 6, 10 } },
	},
	[76] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 30, 25 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 8, 12, 8, 12 } },
	},
	[77] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[78] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = -2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -4, y = -1, durations = { 8, 10, 8, 10 } },
	},
	[79] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 16, x = 0, y = 13, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 6, durations = { 40, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[80] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -4, y = 4, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 8, 12, 8, 12 } },
	},
	[81] = {
		[SpriteData.Types.Faint] = { w = 24, h = 24, x = 5, y = 8, durations = { 8, 2, 2, 2, 1, 2, 1, 4 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 9, durations = { 20, 8, 8, 20, 8, 8 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 8, durations = { 10, 14, 10, 14 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 8, durations = { 8, 6, 6, 8, 6, 6 } },
	},
	[82] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 4, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 7, durations = { 14, 10, 14, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 4, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[83] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 12, 30, 12 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 7, durations = { 6, 12, 6, 12 } },
	},
	[84] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 4, durations = { 40, 6, 12, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 8, 12, 8, 12 } },
	},
	[85] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 2, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 3, durations = { 40, 10, 16, 10, 16, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[86] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 9, durations = { 30, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 3, durations = { 8, 6, 8, 10, 6, 6, 6 } },
	},
	[87] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 40, x = -7, y = 6, durations = { 30, 12, 8, 12, 8, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 0, durations = { 8, 6, 6, 6, 10, 8, 8 } },
	},
	[88] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 7, durations = { 40, 8, 30, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[89] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -4, y = 5, durations = { 40, 8, 30, 8 } },
		[SpriteData.Types.Walk] = { w = 48, h = 40, x = -8, y = 5, durations = { 10, 8, 6, 10, 8 } },
	},
	[90] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 10, durations = { 24, 10, 10, 24, 10, 10 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 8, durations = { 14, 40, 14, 30 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 8, durations = { 10, 6, 10, 10, 6, 10 } },
	},
	[91] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 5, y = 6, durations = { 22, 15, 10, 22, 15, 10 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 2, durations = { 12, 12, 12, 14, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 8, 8, 8, 10, 8, 8 } },
	},
	[92] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 56, x = 4, y = 3, durations = { 6, 6, 6, 16, 6, 6, 6, 16 } },
		[SpriteData.Types.Idle] = { w = 48, h = 56, x = -8, y = 2, durations = { 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 48, h = 64, x = -8, y = -3, durations = { 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[93] = {
		[SpriteData.Types.Faint] = { w = 40, h = 56, x = -4, y = -4, durations = { 4, 3, 16, 3, 1, 3, 3, 2, 2, 6, 2, 4 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 56, x = 2, y = 2, durations = { 8, 8, 20, 8, 8, 20 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 14, 8, 14, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 0, durations = { 6, 6, 6, 10, 6, 6, 6, 6, 10, 6 } },
	},
	[94] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 2, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 40, 4, 3, 3, 3, 3, 3, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[95] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 64, x = -5, y = -6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 96, h = 104, x = -32, y = -8, durations = { 16, 16, 16, 16 } },
		[SpriteData.Types.Walk] = { w = 88, h = 112, x = -28, y = -8, durations = { 10, 14, 10, 14 } },
	},
	[96] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 1, y = -5, durations = { 2, 2, 2, 2, 4, 2, 2, 2, 2 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 2, y = 8, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 40, 10, 6, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 12, 8, 12 } },
	},
	[97] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -4, y = 9, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 3, durations = { 30, 1, 2, 3, 3, 3, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[98] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 16, x = 3, y = 13, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 3, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[99] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 0, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[100] = {
		[SpriteData.Types.Faint] = { w = 32, h = 24, x = 3, y = 11, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 7, durations = { 22, 6, 2, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 6, 6, 10, 4, 4, 4, 6, 8 } },
	},
	[101] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 10, 18, 10, 18 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 3, durations = { 4, 4, 6, 8, 6, 4, 10 } },
	},
	[102] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = -1, y = 2, durations = { 30, 2, 4, 4, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = -1, y = 6, durations = { 6, 8, 6, 8 } },
	},
	[103] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 0, durations = { 40, 12, 8, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 4, durations = { 8, 12, 8, 12 } },
	},
	[104] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 1, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 4, durations = { 40, 1, 2, 3, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[105] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 2, durations = { 40, 6, 16, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[106] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 2, durations = { 40, 20 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 2, durations = { 10, 12, 10, 12 } },
	},
	[107] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 56, x = -7, y = 0, durations = { 30, 6, 8, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[108] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 48, x = -8, y = 2, durations = { 36, 12, 10, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = -1, y = 6, durations = { 10, 14, 10, 14 } },
	},
	[109] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 9, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 2, durations = { 10, 10, 8, 10, 10, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 2, durations = { 6, 6, 6, 6, 8, 6, 6, 6, 6, 8 } },
	},
	[110] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 0, y = 4, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 0, y = 0, durations = { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 4, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[111] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 32, x = -4, y = 7, durations = { 40, 20, 15 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[112] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = -1, y = 2, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 48, x = -7, y = 3, durations = { 40, 26 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[113] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 7, durations = { 35, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 5, durations = { 40, 2, 3, 4, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[114] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 2, durations = { 34, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 2, durations = { 8, 6, 6, 6, 6, 6 } },
	},
	[115] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 1, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = 0, durations = { 30, 3, 4, 3, 20 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = 0, durations = { 16, 10, 16, 10 } },
	},
	[116] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 2, y = 6, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 6, durations = { 8, 16, 8, 16 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 4, y = 6, durations = { 8, 12, 8, 12 } },
	},
	[117] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 56, x = -1, y = 5, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 1, y = 1, durations = { 12, 12, 12, 12, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = 3, durations = { 8, 8, 10, 8, 10 } },
	},
	[118] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 16, 10, 16, 10, 16, 10, 16, 2, 4, 4, 4, 12, 10, 16, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 10, 10, 10, 10, 10, 10, 10, 10 } },
	},
	[119] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = -1, y = 5, durations = { 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 5, durations = { 16, 10, 16, 10, 16, 10, 16, 2, 4, 4, 4, 12, 10, 16, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 10, 8, 10, 8 } },
	},
	[120] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 36, 10, 6, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[121] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 60, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[122] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 2, durations = { 20, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 2, durations = { 8, 12, 8, 12 } },
	},
	[123] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -5, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 10, 14, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[124] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 30, 14, 30, 14 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 12, 8, 12 } },
	},
	[125] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 0, durations = { 28, 18, 28, 18 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -4, y = 0, durations = { 8, 10, 8, 10 } },
	},
	[126] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 6, 12, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[127] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 3, durations = { 40, 2, 6, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[128] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = -2, durations = { 40, 3, 6, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = -2, durations = { 8, 6, 6, 6, 6, 6, 6 } },
	},
	[129] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = -1, y = 4, durations = { 8, 10, 10, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = -1, y = 4, durations = { 6, 2, 4, 6, 4, 2, 6 } },
	},
	[130] = {
		[SpriteData.Types.Sleep] = { w = 72, h = 112, x = -12, y = -8, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 72, h = 128, x = -20, y = -12, durations = { 18, 8, 18, 8 } },
		[SpriteData.Types.Walk] = { w = 88, h = 128, x = -28, y = -12, durations = { 10, 14, 10, 14 } },
	},
	[131] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 32, x = -4, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 56, x = -7, y = -1, durations = { 40, 12, 16, 12 } },
		[SpriteData.Types.Walk] = { w = 48, h = 56, x = -7, y = -1, durations = { 10, 12, 10, 12 } },
	},
	[132] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 16, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 6, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 4, durations = { 10, 8, 10, 8, 8 } },
	},
	[133] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = -1, y = 9, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -2, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 1, durations = { 4, 4, 4, 4, 6, 2, 2 } },
	},
	[134] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 2, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = -3, durations = { 60, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[135] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 2, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 60, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[136] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 12, 16, 12, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 5, durations = { 8, 8, 8, 8 } },
	},
	[137] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 16, 8, 16, 16, 8, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 12, 8, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 10, 10, 10, 10 } },
	},
	[138] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 7, durations = { 30, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 8, 8, 8, 8 } },
	},
	[139] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 30, 20 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 5, durations = { 8, 8, 8, 8 } },
	},
	[140] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 16, x = 5, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 4, y = 9, durations = { 40, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 4, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[141] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 3, durations = { 20, 10, 20, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 2, durations = { 6, 4, 8, 4, 6, 4, 8, 4 } },
	},
	[142] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 64, x = -4, y = -4, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -4, y = -2, durations = { 8, 8, 8, 8 } },
	},
	[143] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 24, x = -4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 0, y = -4, durations = { 40, 1, 3, 4, 3, 1 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[144] = {
		[SpriteData.Types.Sleep] = { w = 56, h = 48, x = -15, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 88, h = 88, x = -28, y = -12, durations = { 8, 10, 8, 16 } },
		[SpriteData.Types.Walk] = { w = 88, h = 88, x = -28, y = -12, durations = { 8, 10, 8, 10 } },
	},
	[145] = {
		[SpriteData.Types.Sleep] = { w = 56, h = 48, x = -11, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 56, h = 96, x = -12, y = -9, durations = { 8, 10, 8, 10 } },
		[SpriteData.Types.Walk] = { w = 56, h = 96, x = -12, y = -9, durations = { 6, 6, 6, 6 } },
	},
	[146] = {
		[SpriteData.Types.Sleep] = { w = 48, h = 64, x = -4, y = -5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 80, h = 96, x = -23, y = -9, durations = { 8, 12, 8, 12 } },
		[SpriteData.Types.Walk] = { w = 80, h = 96, x = -23, y = -9, durations = { 8, 10, 8, 10 } },
	},
	[147] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 4, durations = { 10, 20, 10, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 10, 8, 8, 8, 8 } },
	},
	[148] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 1, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 56, x = -8, y = -3, durations = { 8, 6, 6, 8, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 48, h = 56, x = -8, y = -3, durations = { 8, 6, 6, 8, 6, 6, 6 } },
	},
	[149] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 64, x = -3, y = -2, durations = { 40, 2, 2, 3, 3, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = 1, durations = { 8, 12, 8, 12 } },
	},
	[150] = {
		[SpriteData.Types.Faint] = { w = 40, h = 48, x = -2, y = -1, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 1, y = -3, durations = { 40, 2, 4, 6, 8, 6, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 48, h = 56, x = -7, y = 0, durations = { 12, 6, 6, 12, 6, 6 } },
	},
	[151] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 56, x = 5, y = 2, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 3, durations = { 12, 8, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -4, y = -3, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[152] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 3, y = 9, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 3, y = 2, durations = { 40, 2, 4, 3, 1, 1 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 3, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[153] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = -1, durations = { 40, 14, 20, 14 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = -1, durations = { 8, 10, 8, 10 } },
	},
	[154] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 40, 14, 20, 14 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 0, durations = { 10, 14, 10, 14 } },
	},
	[155] = {
		[SpriteData.Types.Faint] = { w = 32, h = 24, x = 4, y = 10, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 40, 16 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 6, 8, 6, 8 } },
	},
	[156] = {
		[SpriteData.Types.Faint] = { w = 32, h = 16, x = 3, y = 14, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 24, x = 0, y = 8, durations = { 30, 8, 4, 8, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 24, x = 0, y = 8, durations = { 6, 10, 6, 10 } },
	},
	[157] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 0, y = 2, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 30, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 7, durations = { 8, 12, 8, 12 } },
	},
	[158] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 0, y = 7, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 0, durations = { 30, 4, 2, 6, 3, 2, 3 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[159] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 25 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 12, 10, 12, 10 } },
	},
	[160] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 0, durations = { 36, 2, 4, 2, 2, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[161] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 72, x = 4, y = -2, durations = { 30, 10, 2, 2, 3, 3, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[162] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -4, y = 7, durations = { 40, 12, 4, 12, 4, 12 } },
		[SpriteData.Types.Walk] = { w = 56, h = 64, x = -10, y = -6, durations = { 6, 4, 4, 4, 4, 4, 4, 6 } },
	},
	[163] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 13, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 48, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 10, 6, 6, 6, 8 } },
	},
	[164] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 64, x = -3, y = -4, durations = { 40, 2, 2, 6, 1, 2, 3, 6, 3, 2, 2, 2, 3, 3, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 8, 8, 8, 8 } },
	},
	[165] = {
		[SpriteData.Types.Faint] = { w = 40, h = 48, x = 0, y = 0, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 1, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 6, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 6, durations = { 4, 4, 4, 4, 4, 4 } },
	},
	[166] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 4, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 4, durations = { 4, 4, 4, 4, 4, 4 } },
	},
	[167] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 4, y = 8, durations = { 40, 2, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 24, x = 0, y = 8, durations = { 10, 10, 10 } },
	},
	[168] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 4, durations = { 40, 12, 2, 2, 2, 2, 2, 2, 2, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 8, 8, 8, 8 } },
	},
	[169] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = 2, durations = { 12, 12, 12, 12, 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = 2, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[170] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 2, y = 6, durations = { 16, 8, 8, 16, 8, 8, 8 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 14, 10, 12, 12, 14 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 10, 4, 6, 8, 8, 8, 10 } },
	},
	[171] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 1, y = 6, durations = { 20, 14, 14, 20, 14, 14 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 20, 6, 6, 6, 8, 8, 20, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 8, 8, 8, 8 } },
	},
	[172] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 4, y = 4, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 2, durations = { 32, 4, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[173] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 8, durations = { 36, 18 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 8, durations = { 8, 6, 6, 6, 8, 6, 6, 6 } },
	},
	[174] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 5, y = 10, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 7, durations = { 8, 4, 4, 4, 8 } },
	},
	[175] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 8, 10, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 6, 8, 8, 6, 8 } },
	},
	[176] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 5, y = 9, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 5, y = 2, durations = { 30, 4, 3, 3, 3, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[177] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 7, durations = { 8, 4, 8, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 5, y = 10, durations = { 8, 10, 8, 10 } },
	},
	[178] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 7, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[179] = {
		[SpriteData.Types.Faint] = { w = 32, h = 24, x = 2, y = 10, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 30, 4, 3, 3, 3, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[180] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = 0, y = 3, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 3, durations = { 30, 4, 3, 3, 3, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[181] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 1, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 1, y = -2, durations = { 8, 8, 4, 6, 4, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 1, durations = { 8, 10, 8, 10 } },
	},
	[182] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 8, durations = { 30, 8, 4, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[183] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 24, x = -6, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 26, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 10, 8, 10, 8 } },
	},
	[184] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 30, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[185] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 16, x = 0, y = 13, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 6, durations = { 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[186] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 0, y = -4, durations = { 40, 3, 5, 3, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 72, x = -4, y = -8, durations = { 4, 4, 4, 4, 4, 4, 10 } },
	},
	[187] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 0, durations = { 60, 10, 8, 10, 8, 6, 4, 2, 8, 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 3, durations = { 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[188] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 20, 20 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[189] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 10, durations = { 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 5, y = 6, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[190] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = 0, y = 1, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 8, durations = { 30, 18 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 2, durations = { 8, 4, 6, 4, 8, 4, 6, 4 } },
	},
	[191] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 10, durations = { 26, 18 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 7, durations = { 4, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[192] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 40, 1, 2, 3, 4, 3, 2, 1, 4, 1, 2, 3, 4, 3, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 14, 8, 14 } },
	},
	[193] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 8, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 6, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[194] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 2, y = 13, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 8, durations = { 24, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 6, 6, 6, 8, 6, 6, 6 } },
	},
	[195] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 56, x = -8, y = 0, durations = { 36, 4, 6, 8, 6, 4, 36 } },
		[SpriteData.Types.Walk] = { w = 48, h = 40, x = -8, y = 7, durations = { 10, 12, 10, 12 } },
	},
	[196] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[197] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 1, y = 4, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -2, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 8, 8, 8, 8 } },
	},
	[198] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 2, y = 7, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 5, durations = { 46, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 4, 4, 8, 4, 4, 8 } },
	},
	[199] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 5, y = 3, durations = { 20, 8, 12, 12, 8, 20, 8, 12, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 5, y = 3, durations = { 10, 12, 10, 12 } },
	},
	[200] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 4, y = 4, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 4, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 4, durations = { 10, 10, 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 4, y = 4, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[201] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 7, durations = { 30, 4, 35, 4 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 8, durations = { 20, 8, 20, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 7, durations = { 6, 6, 5, 5, 6, 6, 6, 5, 5, 6 } },
	},
	[202] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 6, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 6, durations = { 40, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[203] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 30, 12, 4, 4, 4, 4, 4, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[204] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 26, 22 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 7, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[205] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 8, durations = { 40, 8, 20, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 8, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[206] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -1, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 24, x = 0, y = 8, durations = { 36, 19 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 3, durations = { 8, 6, 6, 6, 6 } },
	},
	[207] = {
		[SpriteData.Types.Faint] = { w = 40, h = 56, x = -2, y = -5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 3, durations = { 8, 10, 8, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 64, x = 1, y = 0, durations = { 6, 4, 4, 4, 8, 4, 4, 4 } },
	},
	[208] = {
		[SpriteData.Types.Sleep] = { w = 48, h = 48, x = -10, y = 1, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 64, h = 112, x = -16, y = -6, durations = { 18, 8, 18, 8 } },
		[SpriteData.Types.Walk] = { w = 72, h = 112, x = -20, y = -6, durations = { 10, 14, 10, 14 } },
	},
	[209] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 6, durations = { 30, 2, 3, 4, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 9, durations = { 6, 8, 6, 8 } },
	},
	[210] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 40, 30 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 6, durations = { 8, 12, 8, 12 } },
	},
	[211] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 7, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 7, durations = { 12, 10, 10, 10, 12, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 10, durations = { 8, 8, 8, 8 } },
	},
	[212] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -5, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 2, y = -6, durations = { 30, 2, 3, 3, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[213] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 4, durations = { 40, 14, 20, 14 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 4, durations = { 14, 8, 14, 8 } },
	},
	[214] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 24, x = -3, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 1, durations = { 30, 8, 4, 8, 4, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 1, durations = { 8, 12, 8, 12 } },
	},
	[215] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = -1, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 0, durations = { 40, 1, 2, 4, 2, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[216] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 40, 12, 8, 12, 8, 20 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[217] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = 0, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[218] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 3, durations = { 10, 6, 34, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 3, durations = { 14, 8, 16, 8 } },
	},
	[219] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 3, durations = { 30, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[220] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 6, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 4, y = 11, durations = { 36, 6, 6, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 4, y = 11, durations = { 8, 8, 8, 12 } },
	},
	[221] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 9, durations = { 40, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[222] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 9, durations = { 52, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[223] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 14, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 8, durations = { 8, 8, 10, 10, 8, 8, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 6, durations = { 8, 8, 8, 8 } },
	},
	[224] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = -2, y = 5, durations = { 10, 8, 20, 4, 12 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 6, durations = { 24, 20 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 2, durations = { 10, 12, 8, 16, 8 } },
	},
	[225] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[226] = {
		[SpriteData.Types.Sleep] = { w = 48, h = 48, x = -8, y = 5, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 64, h = 72, x = -16, y = -8, durations = { 12, 12, 12, 12, 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 64, h = 72, x = -16, y = -8, durations = { 6, 6, 8, 8, 6, 6, 6, 8, 8, 6 } },
	},
	[227] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = -2, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 64, x = -4, y = -2, durations = { 40, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 72, x = -4, y = -2, durations = { 4, 4, 4, 4, 8, 8, 8, 8, 8 } },
	},
	[228] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 1, y = 6, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 2, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 0, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[229] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 64, x = -3, y = -6, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -3, y = -3, durations = { 8, 12, 8, 12 } },
	},
	[230] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 64, x = 4, y = 3, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 40, h = 72, x = -4, y = -3, durations = { 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -4, y = 0, durations = { 8, 10, 8, 10 } },
	},
	[231] = {
		[SpriteData.Types.Faint] = { w = 40, h = 24, x = 0, y = 12, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 3, durations = { 40, 8, 20, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 8, durations = { 6, 8, 6, 8 } },
	},
	[232] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 1, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -5, y = -3, durations = { 40, 8, 20, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 32, x = -4, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[233] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 7, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 12, 8, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 4, durations = { 10, 10, 10, 10 } },
	},
	[234] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 1, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -3, y = -6, durations = { 6, 6, 6, 6, 6, 6 } },
	},
	[235] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = 0, y = 3, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 36, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 8, 8, 8 } },
	},
	[236] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 3, durations = { 30, 1, 2, 4, 4, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[237] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 4, y = -1, durations = { 30, 2, 2, 2, 2, 2, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[238] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 6, durations = { 40, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[239] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 30, 4, 6, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 4, durations = { 6, 10, 6, 10 } },
	},
	[240] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = 1, y = 4, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 3, y = 3, durations = { 30, 2, 3, 4, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 3, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[241] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 8, 3, 5, 3, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[242] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 7, durations = { 30, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[243] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 56, h = 48, x = -13, y = 2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -5, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[244] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 56, x = -8, y = -1, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -4, y = -1, durations = { 10, 12, 10, 12 } },
	},
	[245] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 48, x = -8, y = 2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 2, durations = { 10, 12, 10, 12 } },
	},
	[246] = {
		[SpriteData.Types.Faint] = { w = 32, h = 24, x = 3, y = 10, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 2, durations = { 30, 1, 2, 4, 2, 1, 16, 1, 2, 4, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 9, durations = { 6, 8, 6, 8 } },
	},
	[247] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 2, y = 7, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 5, y = 2, durations = { 4, 4, 4, 12, 6, 4, 4, 36 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 0, durations = { 6, 6, 6, 6, 6 } },
	},
	[248] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 3, durations = { 14, 24, 14, 24 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 10, 16, 10, 16 } },
	},
	[249] = {
		[SpriteData.Types.Sleep] = { w = 56, h = 80, x = -13, y = -1, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 72, h = 96, x = -20, y = -3, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 80, h = 96, x = -24, y = -9, durations = { 4, 4 } },
	},
	[250] = {
		[SpriteData.Types.Sleep] = { w = 56, h = 56, x = -6, y = 0, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 72, h = 112, x = -20, y = -16, durations = { 12, 10, 12, 10, 12 } },
		[SpriteData.Types.Walk] = { w = 72, h = 112, x = -20, y = -16, durations = { 8, 6, 8, 6, 8 } },
	},
	[251] = {
		[SpriteData.Types.Faint] = { w = 32, h = 48, x = 3, y = 0, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 56, x = 2, y = 4, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 5, y = 4, durations = { 8, 7, 6, 6, 6, 7 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 5, y = 6, durations = { 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	-- 252-276 are unused slots in gen 3, 252 is the "missing pokemon" icon
	[252] = {
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 0, durations = { 60 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 0, durations = { 60 } },
	},
	[277] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 3, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -2, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 40, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 6, 10, 6, 10 } },
	},
	[278] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 18, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 0, durations = { 8, 6, 6, 6, 8 } },
	},
	[279] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -2, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -5, y = 6, durations = { 40, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = -1, y = 2, durations = { 10, 8, 10, 8 } },
	},
	[280] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 3, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 5, durations = { 30, 3, 4, 3, 3 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 8, 8, 8 } },
	},
	[281] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -2, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 4, durations = { 40, 4, 6, 6, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 4, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[282] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 32, x = -6, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 0, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 0, durations = { 8, 10, 8, 10 } },
	},
	[283] = {
		[SpriteData.Types.Faint] = { w = 32, h = 32, x = 3, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 5, durations = { 38, 2, 2, 5, 3, 3, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 4, 6, 4, 6, 6, 4 } },
	},
	[284] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 16, x = 4, y = 15, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 36, 16, 36, 16 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[285] = {
		[SpriteData.Types.Faint] = { w = 40, h = 48, x = 0, y = 0, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 0, y = -4, durations = { 40, 1, 2, 4, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[286] = {
		[SpriteData.Types.Faint] = { w = 32, h = 48, x = 4, y = -1, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 5, durations = { 40, 8, 5, 8, 5, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 1, durations = { 4, 4, 4, 4, 4 } },
	},
	[287] = {
		[SpriteData.Types.Faint] = { w = 48, h = 48, x = 0, y = 1, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 48, x = -8, y = 1, durations = { 40, 8, 5, 8, 5, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 10, 10, 10, 10 } },
	},
	[288] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 3, durations = { 40, 2, 4, 4, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 2, durations = { 6, 4, 4, 2, 4, 4, 4 } },
	},
	[289] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 40, x = -7, y = 0, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 2, durations = { 8, 6, 6, 6, 6, 6 } },
	},
	[290] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 6, durations = { 30, 12, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 2, durations = { 8, 2, 4, 6, 4, 2 } },
	},
	[291] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 2, 2, 120 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 2, 2, 120 } },
	},
	[292] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 64, x = -3, y = 0, durations = { 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -3, y = 0, durations = { 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[293] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 7, durations = { 2, 2, 120 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 7, durations = { 2, 2, 120 } },
	},
	[294] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = 3, durations = { 6, 4, 4, 6, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 3, durations = { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 } },
	},
	[295] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 16, x = 5, y = 14, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 5, y = 10, durations = { 24, 18, 24, 18 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 5, y = 10, durations = { 8, 10, 8, 10 } },
	},
	[296] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 1, 2, 3, 4, 2, 1, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 6, 10, 6, 10 } },
	},
	[297] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[298] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 36, 18 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 7, durations = { 8, 4, 6, 4, 8, 4, 6, 4 } },
	},
	[299] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 6, 10, 6, 10 } },
	},
	[300] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -3, y = -2, durations = { 24, 4, 4, 4, 24, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 2, durations = { 8, 4, 4, 4, 8, 4, 4, 4 } },
	},
	[301] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 4, y = 8, durations = { 40, 4, 2, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 4, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[302] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 1, y = 4, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 4, durations = { 8, 8, 8, 9 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 4, durations = { 4, 4, 4, 4 } },
	},
	[303] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 3, y = 8, durations = { 12, 12, 16, 12, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 4, y = 5, durations = { 8, 4, 4, 4, 4, 8, 8, 4, 4, 4, 4, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 56, x = 4, y = 5, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[304] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 16, x = 4, y = 14, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 6, durations = { 30, 4, 6, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 6, durations = { 6, 4, 4, 4, 4 } },
	},
	[305] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 1, y = -8, durations = { 40, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 6, 10, 6, 10 } },
	},
	[306] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 24, x = 4, y = 10, durations = { 40, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 4, y = 10, durations = { 8, 10, 8, 10 } },
	},
	[307] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 4, durations = { 8, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[308] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 0, y = 0, durations = { 10, 2, 6, 4, 2, 1, 3, 4, 4 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -2, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 3, durations = { 4, 8, 14, 4, 5, 6, 8, 14, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 10, 10, 12, 14, 12, 10, 10, 12, 14, 12, 10 } },
	},
	[309] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 5, durations = { 6, 8, 6, 8, 6, 8, 6, 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[310] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 8, durations = { 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 8, durations = { 10, 4, 8, 10, 4, 8 } },
	},
	[311] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 5, durations = { 8, 16, 8, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 5, durations = { 6, 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[312] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 3, durations = { 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[313] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 8, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 16, 10, 16, 16, 10, 10, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 6, 6, 8, 6, 6, 6 } },
	},
	[314] = {
		[SpriteData.Types.Sleep] = { w = 72, h = 80, x = -8, y = -2, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 72, h = 104, x = -20, y = -16, durations = { 24, 12, 12, 24, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 72, h = 104, x = -20, y = -16, durations = { 10, 8, 6, 6, 8, 8, 10, 8, 6, 6, 6, 8 } },
	},
	[315] = {
		[SpriteData.Types.Faint] = { w = 32, h = 40, x = 2, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 40, 8, 6, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 2, durations = { 4, 5, 6, 6, 6, 5, 4 } },
	},
	[316] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = -2, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 3, durations = { 60, 10, 5, 5, 5, 5, 5, 5, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[317] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -2, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 40, 2, 6, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[318] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 3, durations = { 8, 8, 16, 8, 8, 8, 8, 16, 8, 8 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 8, durations = { 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 4, durations = { 6, 6, 6, 4, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6 } },
	},
	[319] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 6, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 7, durations = { 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 4, y = 7, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[320] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -2, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -2, durations = { 30, 6, 4, 4, 4, 4, 4, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[321] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 3, durations = { 40, 20, 20, 20 } },
		[SpriteData.Types.Walk] = { w = 40, h = 32, x = -3, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[322] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 40, 12 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 5, durations = { 6, 8, 6, 8 } },
	},
	[323] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 7, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 6, durations = { 12, 10, 10, 12, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 6, durations = { 8, 6, 6, 8, 6, 6 } },
	},
	[324] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 0, y = 4, durations = { 20, 12, 12, 20, 12, 12 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 4, durations = { 10, 10, 10, 10, 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 4, durations = { 8, 6, 6, 6, 8, 8, 6, 8, 8 } },
	},
	[325] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 11, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 9, durations = { 34, 8, 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 9, durations = { 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[326] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 7, durations = { 24, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[327] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 4, durations = { 24, 12, 24, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[328] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 1, y = 6, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 7, durations = { 12, 14, 12, 14 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 5, durations = { 8, 10, 8, 10, 8, 10, 8, 10 } },
	},
	[329] = {
		[SpriteData.Types.Sleep] = { w = 48, h = 72, x = -4, y = 0, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 72, h = 80, x = -17, y = -5, durations = { 40, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 72, h = 80, x = -17, y = -5, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[330] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 0, y = 4, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 4, durations = { 8, 26, 8, 36 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 4, durations = { 6, 6, 6, 6 } },
	},
	[331] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = -1, y = 5, durations = { 8, 8, 26, 8, 8, 26 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 6, durations = { 16, 16, 16, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 3, durations = { 10, 8, 8, 8, 10, 8, 8, 8 } },
	},
	[332] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 2, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 8, durations = { 40, 8, 10, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[333] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 1, durations = { 40, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 4, durations = { 4, 6, 6, 6, 4, 6, 6, 6 } },
	},
	[334] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 64, x = 0, y = 2, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 72, x = 1, y = -2, durations = { 8, 9, 8, 8, 11, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 64, x = 1, y = 0, durations = { 8, 8, 8, 8 } },
	},
	[335] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 2, 2, 2, 2, 20, 4, 4, 4, 2, 2, 2, 2, 20, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[336] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -2, y = -1, durations = { 26, 2, 4, 4, 2, 1, 26, 1, 4, 4, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -2, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[337] = {
		[SpriteData.Types.Faint] = { w = 40, h = 24, x = 0, y = 10, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 4, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[338] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 6, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[339] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 3, durations = { 40, 8, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[340] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 5, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 0, durations = { 8, 20, 8, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[341] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 3, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 8, durations = { 16, 6, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 8, durations = { 6, 6, 6, 6, 6, 6 } },
	},
	[342] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 24, x = -4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 4, durations = { 40, 14, 18, 14 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 4, durations = { 6, 6, 8, 6, 6 } },
	},
	[343] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 3, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 0, durations = { 40, 2, 8, 8, 8, 8, 8, 4 } },
		[SpriteData.Types.Walk] = { w = 48, h = 56, x = -7, y = -4, durations = { 8, 6, 6, 6, 6, 6, 6 } },
	},
	[344] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 8, durations = { 40, 10, 16, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 1, y = 7, durations = { 8, 10, 8, 10 } },
	},
	[345] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 32, x = -7, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 1, y = -3, durations = { 40, 2, 4, 4, 4, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 0, durations = { 8, 10, 8, 10 } },
	},
	[346] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 5, durations = { 40, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[347] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 0, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 0, y = 0, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 64, x = 0, y = 0, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[348] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 7, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 5, y = 7, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 5, y = 7, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[349] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 2, y = 6, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 6, durations = { 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 6, durations = { 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[350] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -2, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 5, y = 9, durations = { 16, 10, 16, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 4, durations = { 6, 6, 6, 6, 6, 6, 6 } },
	},
	[351] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 5, y = 4, durations = { 40, 30 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 5, y = 0, durations = { 30, 4, 4, 8, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 64, x = 0, y = 0, durations = { 4, 6, 4, 6, 4, 4, 4, 6, 4, 6, 4, 4 } },
	},
	[352] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = -1, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 3, durations = { 40, 12, 8, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[353] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 10, 6, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 7, durations = { 6, 4, 8, 4, 6, 4, 8, 4 } },
	},
	[354] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 10, 6, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 7, durations = { 6, 4, 8, 4, 6, 4, 8, 4 } },
	},
	[355] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 32, x = -6, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 56, h = 48, x = -12, y = 2, durations = { 40, 2, 2, 2, 4, 6, 4, 6, 4, 2, 2, 2, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 5, durations = { 8, 10, 8, 10 } },
	},
	[356] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 3, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 8, 16, 8, 16 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 7, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[357] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 4, y = 0, durations = { 40, 2, 2, 3, 4, 3, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 24, h = 56, x = 4, y = 0, durations = { 10, 6, 6, 6, 10, 6, 6, 6 } },
	},
	[358] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 7, durations = { 4, 4, 4, 4, 6, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 6, 6, 8, 6, 6 } },
	},
	[359] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 64, x = -7, y = -3, durations = { 60, 6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 48, h = 56, x = -7, y = 1, durations = { 8, 10, 8, 10 } },
	},
	[360] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 6, durations = { 40, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 6, durations = { 8, 2, 10, 2, 8, 2, 10, 2 } },
	},
	[361] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 4, y = 6, durations = { 8, 8, 16, 8, 8, 8, 16, 8 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 2, durations = { 24, 8, 8, 24, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 5, y = 3, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[362] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 3, durations = { 40, 8, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[363] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 2, y = 7, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -1, y = 11, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 8, durations = { 6, 6, 6, 6, 6, 6, 6, 6, 40 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 8, durations = { 8, 12, 8, 12 } },
	},
	[364] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 1, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 32, x = -3, y = 4, durations = { 60, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 32, x = -3, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[365] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 1, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -2, durations = { 40, 2, 2, 6, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 0, durations = { 8, 10, 8, 10 } },
	},
	[366] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 0, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 0, y = 3, durations = { 50, 6, 2, 6, 4, 2, 2 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 10, 16, 10, 16 } },
	},
	[367] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 5, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 6, durations = { 20, 30 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 6, durations = { 8, 8, 10, 8, 8, 10 } },
	},
	[368] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 5, durations = { 16, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 10, 8, 10, 8, 8, 8 } },
	},
	[369] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 24, x = -2, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 72, x = -7, y = -9, durations = { 30, 3, 5, 4, 5, 4, 5, 4, 5, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 48, h = 56, x = -7, y = -3, durations = { 10, 14, 10, 14 } },
	},
	[370] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = -1, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -2, durations = { 40, 1, 1, 4, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 5, durations = { 6, 8, 6, 8 } },
	},
	[371] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 3, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -2, durations = { 40, 1, 1, 4, 4, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 5, durations = { 6, 10, 6, 10 } },
	},
	[372] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -7, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 5, durations = { 40, 10, 8, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 5, durations = { 8, 12, 8, 12 } },
	},
	[373] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 9, durations = { 40, 6, 8, 6 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 10, 10, 6, 6, 6, 8 } },
	},
	[374] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = 0, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 56, x = -4, y = 0, durations = { 10, 10, 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 56, x = -4, y = 0, durations = { 8, 8, 8, 8 } },
	},
	[375] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 56, x = 0, y = 4, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 48, h = 72, x = -8, y = -4, durations = { 16, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 48, h = 64, x = -8, y = -2, durations = { 14, 6, 8, 8, 8, 8, 6, 6, 6 } },
	},
	[376] = {
		[SpriteData.Types.Faint] = { w = 40, h = 48, x = -1, y = 1, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -5, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 1, durations = { 30, 30 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 2, durations = { 8, 10, 8, 10 } },
	},
	[377] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 9, durations = { 10, 10, 18, 10, 10, 18 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 5, y = 5, durations = { 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 48, x = 5, y = 5, durations = { 6, 6, 6, 6, 6, 6 } },
	},
	[378] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 56, x = 4, y = 2, durations = { 40, 1, 2, 4, 4, 4, 4, 2, 1 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[379] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 2, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 2, durations = { 14, 18, 14, 18 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 2, durations = { 8, 8, 8, 8 } },
	},
	[380] = {
		[SpriteData.Types.Faint] = { w = 48, h = 48, x = -1, y = 1, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 32, h = 24, x = -1, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 4, durations = { 30, 4, 4, 4, 4, 4 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -4, y = 4, durations = { 8, 10, 8, 10 } },
	},
	[381] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 48, x = 1, y = 5, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 1, y = 2, durations = { 30, 6, 4, 6, 4, 14, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 4, durations = { 10, 10, 10, 10 } },
	},
	[382] = {
		[SpriteData.Types.Faint] = { w = 32, h = 24, x = 5, y = 11, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 10, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 8, durations = { 34, 12, 8, 12 } },
		[SpriteData.Types.Walk] = { w = 24, h = 24, x = 4, y = 11, durations = { 6, 8, 6, 8 } },
	},
	[383] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 32, x = 1, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 4, durations = { 40, 16, 8, 16 } },
		[SpriteData.Types.Walk] = { w = 32, h = 32, x = 0, y = 8, durations = { 8, 10, 8, 10 } },
	},
	[384] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -3, y = 7, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 3, durations = { 40, 6, 2, 6, 2, 6 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 3, durations = { 8, 12, 8, 12 } },
	},
	[385] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 13, durations = { 35, 30 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 8, durations = { 8, 6, 6, 6, 6, 8 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 5, y = 8, durations = { 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[386] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 30, 8, 4, 8, 4, 8, 4, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 1, durations = { 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[387] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 6, durations = { 30, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 1, durations = { 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[388] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 32, x = 4, y = 9, durations = { 8, 10, 8, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 4, y = 9, durations = { 8, 10, 8, 10 } },
	},
	[389] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 40, x = 4, y = 6, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 48, x = -8, y = 3, durations = { 40, 4, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 3, durations = { 8, 10, 8, 10 } },
	},
	[390] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 5, y = 5, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 1, durations = { 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 2, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[391] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -4, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 48, x = -7, y = 4, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 48, h = 48, x = -7, y = 2, durations = { 8, 12, 8, 12 } },
	},
	[392] = {
		[SpriteData.Types.Faint] = { w = 40, h = 32, x = 2, y = 8, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 24, x = 4, y = 12, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 1, y = 9, durations = { 40, 25 } },
		[SpriteData.Types.Walk] = { w = 24, h = 32, x = 5, y = 9, durations = { 10, 8, 10, 8 } },
	},
	[393] = {
		[SpriteData.Types.Faint] = { w = 40, h = 40, x = 3, y = 5, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 5, y = 6, durations = { 60, 4, 4, 4, 4, 4, 4, 6, 24 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 1, durations = { 1, 2, 3, 3, 1, 4, 2, 2, 2, 2, 2, 2, 2 } },
	},
	[394] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 9, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 6, durations = { 6, 12, 6, 12 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 1, y = 6, durations = { 8, 12, 8, 12 } },
	},
	[395] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 24, h = 40, x = 4, y = 6, durations = { 40, 10, 14, 10 } },
		[SpriteData.Types.Walk] = { w = 24, h = 40, x = 4, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[396] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 0, y = 6, durations = { 18, 20, 18, 20 } },
		[SpriteData.Types.Walk] = { w = 32, h = 40, x = 0, y = 6, durations = { 8, 10, 8, 10 } },
	},
	[397] = {
		[SpriteData.Types.Faint] = { w = 56, h = 48, x = -4, y = 0, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 48, h = 48, x = -7, y = 1, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 56, h = 56, x = -11, y = -2, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 56, h = 80, x = -11, y = -8, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[398] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 32, x = 4, y = 8, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 32, h = 40, x = 1, y = 8, durations = { 10, 10, 10, 10, 10, 10, 10, 10 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 1, y = 6, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[399] = {
		[SpriteData.Types.Sleep] = { w = 40, h = 40, x = -3, y = 5, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -3, y = 5, durations = { 12, 12, 12, 12, 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -3, y = 5, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[400] = {
		[SpriteData.Types.Sleep] = { w = 48, h = 32, x = -7, y = 8, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 5, durations = { 40, 20 } },
		[SpriteData.Types.Walk] = { w = 48, h = 40, x = -7, y = 6, durations = { 8, 14, 8, 14 } },
	},
	[401] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 56, x = 0, y = -1, durations = { 40, 1, 4, 2, 3, 4, 3 } },
		[SpriteData.Types.Walk] = { w = 32, h = 48, x = 0, y = 2, durations = { 8, 18, 8, 18 } },
	},
	[402] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 48, x = 1, y = 4, durations = { 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 1, y = 3, durations = { 8, 8, 8, 8, 8, 8 } },
	},
	[403] = {
		[SpriteData.Types.Sleep] = { w = 32, h = 40, x = 0, y = 5, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 40, h = 40, x = -3, y = 7, durations = { 40, 40 } },
		[SpriteData.Types.Walk] = { w = 40, h = 40, x = -3, y = 7, durations = { 10, 10, 10, 10 } },
	},
	[404] = {
		[SpriteData.Types.Sleep] = { w = 64, h = 72, x = -15, y = -6, durations = { 16, 12, 16, 16, 12, 16 } },
		[SpriteData.Types.Idle] = { w = 64, h = 72, x = -15, y = -7, durations = { 10, 14, 14, 14, 14, 10, 14, 14, 14, 14 } },
		[SpriteData.Types.Walk] = { w = 64, h = 72, x = -15, y = -7, durations = { 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[405] = {
		[SpriteData.Types.Faint] = { w = 56, h = 80, x = -8, y = -12, durations = { 10, 2, 2, 2, 2, 2, 10, 4, 2, 2, 2, 2, 16, 8, 6, 5, 3, 1, 2, 4, 2, 1, 20 } },
		[SpriteData.Types.Sleep] = { w = 56, h = 56, x = -10, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 64, h = 80, x = -15, y = -4, durations = { 60, 10, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10 } },
		[SpriteData.Types.Walk] = { w = 64, h = 88, x = -15, y = -8, durations = { 10, 12, 10, 12 } },
	},
	[406] = {
		[SpriteData.Types.Sleep] = { w = 72, h = 96, x = -18, y = -4, durations = { 10, 10, 10, 30, 10, 10, 10, 30 } },
		[SpriteData.Types.Idle] = { w = 80, h = 120, x = -18, y = -10, durations = { 14, 10, 14, 10 } },
		[SpriteData.Types.Walk] = { w = 80, h = 128, x = -18, y = -12, durations = { 8, 8, 6, 4, 4, 4, 8, 8, 6, 6, 6, 6 } },
	},
	[407] = {
		[SpriteData.Types.Faint] = { w = 56, h = 64, x = -4, y = -9, durations = { 8, 12, 4, 10 } },
		[SpriteData.Types.Sleep] = { w = 40, h = 32, x = -2, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 48, h = 64, x = -7, y = -4, durations = { 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 48, h = 64, x = -7, y = -4, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[408] = {
		[SpriteData.Types.Faint] = { w = 56, h = 80, x = -11, y = -20, durations = { 10, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 1, 6, 3, 10 } },
		[SpriteData.Types.Sleep] = { w = 48, h = 32, x = -6, y = 4, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 64, h = 80, x = -16, y = -4, durations = { 8, 8, 8, 8, 8, 8 } },
		[SpriteData.Types.Walk] = { w = 64, h = 80, x = -16, y = -4, durations = { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 } },
	},
	[409] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 48, x = 3, y = 7, durations = { 8, 8, 8, 24, 8, 8, 8, 24 } },
		[SpriteData.Types.Idle] = { w = 40, h = 48, x = -4, y = 6, durations = { 12, 8, 12, 8 } },
		[SpriteData.Types.Walk] = { w = 40, h = 48, x = -4, y = 6, durations = { 6, 6, 6, 6, 6, 6, 6, 6, 6 } },
	},
	[410] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 56, x = 5, y = 3, durations = { 30, 35 } },
		[SpriteData.Types.Idle] = { w = 32, h = 64, x = 0, y = 3, durations = { 12, 12, 12, 12, 12, 12, 12, 12 } },
		[SpriteData.Types.Walk] = { w = 40, h = 64, x = -4, y = 3, durations = { 8, 8, 8, 8, 8, 8, 8, 8 } },
	},
	[411] = {
		[SpriteData.Types.Sleep] = { w = 24, h = 56, x = 4, y = 5, durations = { 28, 10, 10, 28, 10, 10 } },
		[SpriteData.Types.Idle] = { w = 24, h = 48, x = 4, y = 8, durations = { 18, 8, 18, 8 } },
		[SpriteData.Types.Walk] = { w = 32, h = 56, x = 0, y = 4, durations = { 4, 4, 6, 6, 4, 4, 4, 4, 6, 6, 4, 4 } },
	},
	-- Egg
	[412] = {
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 1, durations = { 48, 8, 8, 8 } },
	},
	-- Pokémon Tower Ghost
	[413] = {
		[SpriteData.Types.Idle] = { w = 32, h = 32, x = 0, y = 2, durations = { 48, 8, 44, 8 } },
	},
}
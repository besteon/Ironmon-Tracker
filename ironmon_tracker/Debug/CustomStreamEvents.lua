local function CustomStreamEvents()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {}
	self.version = "1.0"
	self.name = "Custom In-Game Events"
	self.author = "Example"
	self.description = "Sends info to Streamerbot when certain in-game events trigger."
	-- self.github = "MyUsername/ExtensionRepo" -- Replace "MyUsername" and "ExtensionRepo" to match your GitHub repo url, if any
	-- self.url = string.format("https://github.com/%s", self.github or "") -- Remove this attribute if no host website available for this extension

	-- The extension will notify Streamerbot to update global vars with these names
	-- If you want to change them, only change the value, the string part on the right-half
	local GLOBAL_VARS = {
		FullRestores = "FullRestores",
		MaxPotions = "MaxPotions",
		RareCandies = "RareCandies",
		EnteredViridianForest = "EnteredViridianForest",
		DefeatedBrock = "DefeatedBrock",
	}

	-- Define event information: a unique key, a descriptive name, and how to fulfill any request that triggers it
	local EVENT_KEY = "G_CustomStreamEvents"
	local EVENT_NAME = "My Custom In-Game Events"
	local EVENT_FULFILL_FUNC = function(thisEvent, request)
		local response = {
			Message = "", -- An optional message to send to stream chat, leave empty for no message
		}
		-- If somehow no global variable was included, send nothing with this event trigger
		if Utils.isNilOrEmpty(request.SanitizedInput) then
			return response
		end
		-- Send to the Tracker Network a response with a named global variable for what changed
		-- The global variable's name was sent to this event through the input field of the created request
		local globalVarName = request.SanitizedInput
		local globalVarValue = self.PerSeedVars[globalVarName] or "Updated!"
		response.GlobalVars = {
			[globalVarName] = globalVarValue
		}
		return response
	end

	-- Game IDs for various things
	-- Many IDs can be found in the /ironmon_tracker/data/ folder
	-- Item IDs are not explicitly listed, but can be inferred from the item list in a resource file: /ironmon_tracker/Languages/English.lua
	local GAME_IDS = {
		FullRestore = 19,
		MaxPotion = 20,
		RareCandy = 68,
		LocationForest = 117,
		TrainerForest1 = 102,
		TrainerBrock = 414,
	}

	-- These variables are what are tracked, saved and reset for each new game
	-- Use these to detect a change, and trigger an event accordingly
	self.PerSeedVars = {
		FullRestores = 0,
		MaxPotions = 0,
		RareCandies = 0,
		EnteredViridianForest = false,
		DefeatedBrock = false,
	}

	-- To properly determine when new items are acquired, need to load them in first at least once
	local loadedVarsThisSeed

	-- Helper functions
	function self.isPlayingFRLG()
		-- 1:Ruby/Sapphire, 2:Emerald, 3:FireRed/LeafGreen
		return GameSettings.game == 3
	end
	function self.resetSeedVars()
		local V = self.PerSeedVars
		V.FullRestores = self.getItemQuantity(GAME_IDS.FullRestore)
		V.MaxPotions = self.getItemQuantity(GAME_IDS.MaxPotion)
		V.RareCandies = self.getItemQuantity(GAME_IDS.RareCandy)
		if self.isPlayingFRLG() then
			V.EnteredViridianForest = self.hasEnteredViridianForest()
			V.DefeatedBrock = Program.hasDefeatedTrainer(GAME_IDS.TrainerBrock)
		else
			-- Code to check for Ruby/Sapphire/Emerald
		end
	end
	function self.hasEnteredViridianForest()
		local inForest = TrackerAPI.getMapId() == GAME_IDS.LocationForest
		local defeatedTrainer = Program.hasDefeatedTrainer(GAME_IDS.TrainerForest1)
		return self.isPlayingFRLG() and inForest and not defeatedTrainer
	end
	function self.getItemQuantity(itemId)
		-- Check each known item category table if the item is there in some quantity
		for _, category in pairs(Program.GameData.Items or {}) do
			if type(category) == "table" and category[itemId] then
				return category[itemId]
			end
		end
		return 0
	end
	function self.checkForChangesAndNotify()
		local V = self.PerSeedVars

		local prevCount = V.FullRestores
		V.FullRestores = self.getItemQuantity(GAME_IDS.FullRestore)
		if V.FullRestores > prevCount then
			EventHandler.triggerEvent(EVENT_KEY, GLOBAL_VARS.FullRestores)
		end

		prevCount = V.MaxPotions
		V.MaxPotions = self.getItemQuantity(GAME_IDS.MaxPotion)
		if V.MaxPotions > prevCount then
			EventHandler.triggerEvent(EVENT_KEY, GLOBAL_VARS.MaxPotions)
		end

		prevCount = V.RareCandies
		V.RareCandies = self.getItemQuantity(GAME_IDS.RareCandy)
		if V.RareCandies > prevCount then
			EventHandler.triggerEvent(EVENT_KEY, GLOBAL_VARS.RareCandies)
		end

		if self.isPlayingFRLG() then
			if not V.EnteredViridianForest and self.hasEnteredViridianForest() then
				V.EnteredViridianForest = true
				EventHandler.triggerEvent(EVENT_KEY, GLOBAL_VARS.EnteredViridianForest)
			end

			if not V.DefeatedBrock and Program.hasDefeatedTrainer(GAME_IDS.TrainerBrock) then
				V.DefeatedBrock = true
				EventHandler.triggerEvent(EVENT_KEY, GLOBAL_VARS.DefeatedBrock)
			end
		else
			-- Code to check for Ruby/Sapphire/Emerald
		end
	end

	-- Tracker specific functions, can't rename these functions
	-- Executed only once: when the Tracker finishes starting up and after it loads all other required files and code
	function self.startup()
		loadedVarsThisSeed = false
		EventHandler.addNewGameEvent(EVENT_KEY, EVENT_FULFILL_FUNC, EVENT_NAME)
	end

	-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		EventHandler.removeEvent(EVENT_KEY)
	end

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate()
		-- Once per seed, when the player is able to move their character, initialize the seed variables
		if not Program.isValidMapLocation() then
			return
		end
		if not loadedVarsThisSeed then
			self.resetSeedVars()
			loadedVarsThisSeed = true
		end

		self.checkForChangesAndNotify()
	end

	return self
end
return CustomStreamEvents
local function CustomStreamEvents()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {}
	self.version = "1.0"
	self.name = "Custom In-Game Events"
	self.author = "Example"
	self.description = "Sends info to Streamerbot when certain in-game events trigger."
	-- self.github = "MyUsername/ExtensionRepo" -- Replace "MyUsername" and "ExtensionRepo" to match your GitHub repo url, if any
	-- self.url = string.format("https://github.com/%s", self.github or "") -- Remove this attribute if no host website available for this extension

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
		local globalVarValue = self.GlobalVars[globalVarName]
		if globalVarValue == nil then
			globalVarValue = "Updated!"
		end
		response.GlobalVars = {
			[globalVarName] = globalVarValue
		}
		return response
	end

	-- These variables are what are tracked, saved and reset for each new game
	-- Use these to detect a change, and trigger an event accordingly
	self.GlobalVars = {
		FullRestore = 0,
		MaxPotion = 0,
		RareCandy = 0,
		BigMushroom = 0,
		EnteredViridianForest = false, -- FRLG
		DefeatedBrock = false, -- FRLG
		DefeatedRoxanne = false, -- RSE
	}

	-- Game IDs for various things
	-- Many IDs can be found in the /ironmon_tracker/data/ folder
	-- Item IDs are not explicitly listed, but can be inferred from the item list in a resource file: /ironmon_tracker/Languages/English.lua
	local GAME_IDS = {
		FullRestore = 19,
		MaxPotion = 20,
		RareCandy = 68,
		BigMushroom = 104,
		LocationForest = 117,
		TrainerForest1 = 102, -- FRLG
		TrainerBrock = 414, -- FRLG
		TrainerRoxanne = 265, -- RSE
	}

	-- To properly determine when new items are acquired, need to load them in first at least once
	local loadedVarsThisSeed

	-- Helper functions
	function self.isPlayingFRLG()
		-- 1:Ruby/Sapphire, 2:Emerald, 3:FireRed/LeafGreen
		return GameSettings.game == 3
	end
	function self.updateGlobalVars()
		local V = self.GlobalVars
		V.FullRestore = self.getItemQuantity(GAME_IDS.FullRestore)
		V.MaxPotion = self.getItemQuantity(GAME_IDS.MaxPotion)
		V.RareCandy = self.getItemQuantity(GAME_IDS.RareCandy)
		V.BigMushroom = self.getItemQuantity(GAME_IDS.BigMushroom)
		if self.isPlayingFRLG() then
			V.EnteredViridianForest = self.hasEnteredViridianForest()
			V.DefeatedBrock = Program.hasDefeatedTrainer(GAME_IDS.TrainerBrock)
		else
			V.DefeatedRoxanne = Program.hasDefeatedTrainer(GAME_IDS.TrainerRoxanne)
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
		local V = self.GlobalVars

		if self.getItemQuantity(GAME_IDS.FullRestore) > V.FullRestore then
			EventHandler.triggerEvent(EVENT_KEY, "FullRestore")
		end
		if self.getItemQuantity(GAME_IDS.MaxPotion) > V.MaxPotion then
			EventHandler.triggerEvent(EVENT_KEY, "MaxPotion")
		end
		if self.getItemQuantity(GAME_IDS.RareCandy) > V.RareCandy then
			EventHandler.triggerEvent(EVENT_KEY, "RareCandy")
		end
		if self.getItemQuantity(GAME_IDS.BigMushroom) > V.BigMushroom then
			EventHandler.triggerEvent(EVENT_KEY, "BigMushroom")
		end

		if self.isPlayingFRLG() then
			if not V.EnteredViridianForest and self.hasEnteredViridianForest() then
				EventHandler.triggerEvent(EVENT_KEY, "EnteredViridianForest")
			end
			if not V.DefeatedBrock and Program.hasDefeatedTrainer(GAME_IDS.TrainerBrock) then
				EventHandler.triggerEvent(EVENT_KEY, "DefeatedBrock")
			end
		else
			if not V.DefeatedRoxanne and Program.hasDefeatedTrainer(GAME_IDS.TrainerRoxanne) then
				EventHandler.triggerEvent(EVENT_KEY, "DefeatedRoxanne")
			end
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
			self.updateGlobalVars()
			loadedVarsThisSeed = true
		end

		self.checkForChangesAndNotify()
		self.updateGlobalVars()
	end

	return self
end
return CustomStreamEvents
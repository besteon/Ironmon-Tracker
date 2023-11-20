EventHandler = {
	RewardsExternal = {}, -- A list of external rewards
	Queues = {}, -- A table of lists for each set of processed requests that still need to be fulfilled
	EVENT_SETTINGS_FORMAT = "Event__%s__%s",
	DUPLICATE_COMMAND_COOLDOWN = 6, -- # of seconds

	-- Shared values between server and client
	COMMAND_PREFIX = "!",

	-- TODO: CUSTOM OPTIONS FOR TESTING
	OutputToFileRewardUsername = true,
	OutputToFileRewardDirection = true,
	RedemptionUsernameOutput = "RedemptionUser.txt",
	RedemptionDirectionOutput = "RedemptionDirection.txt",
}

EventHandler.EventTypes = {
	None = "None",
	Command = "Command", -- For chat commands
	Reward = "Reward", -- For channel rewards (channel point redeem)
	Tracker = "Tracker", -- Trigger off of a change to the Tracker itself
	Game = "Game", -- Trigger off of something in the actual game
}

EventHandler.CoreEventKeys = {
	Start = "TS_Start",
	Stop = "TS_Stop",
	GetRewards = "TS_GetRewardsList",
	UpdateEvents = "TS_UpdateEvents",
}

EventHandler.Events = {
	None = { Key = "None", Type = EventHandler.EventTypes.None, Exclude = true },
}

EventHandler.CommandRoles = {
	Broadcaster = "Broadcaster", -- Allow the one user who is the Broadcaster (always allowed)
	Everyone = "Everyone", -- Allow all users, regardless of other roles selected
	Moderator = "Moderator", -- Allow users that are Moderators
	Vip = "Vip", -- Allow users with VIP
	Subscriber = "Subscriber", -- Allow users that are Subscribers
	Custom = "Custom", -- Allow users that belong to a custom-defined role
	Viewer = "Viewer", -- Unused
}

---Clears out existing event info; similar to initialize(), but managed by Network
function EventHandler.reset()
	EventHandler.RewardsExternal = {}
	EventHandler.Queues = {
		BallRedeems = { Requests = {}, },
	}
end

---Checks if the event is of a known event type
---@param event table IEvent
---@return boolean
function EventHandler.isValidEvent(event)
	if not event then return false end
	return EventHandler.Events[event.Key or false] and event.Key ~= EventHandler.Events.None.Key
end

--- Adds an IEvent to the events list; returns true if successful
---@param event table IEvent object (requires: Key, Process, Fulfill)
---@return boolean success
function EventHandler.addNewEvent(event)
	-- Only add new, properly structured  events
	if Utils.isNilOrEmpty(event.Key) or EventHandler.Events[event.Key] then
		return false
	end
	-- Attempt to auto-detect the event type, based on other properties
	if Utils.isNilOrEmpty(event.Type) or event.Type == EventHandler.EventTypes.None then
		if event.Command and not event.RewardId then
			event.Type = EventHandler.EventTypes.Command
		elseif event.RewardId and not event.Command then
			event.Type = EventHandler.EventTypes.Reward
		else
			event.Type = EventHandler.EventTypes.None
		end
	end
	EventHandler.Events[event.Key] = event
	EventHandler.loadEventSettings(event)
	return true
end

--- Adds an IEvent to the events list; returns true if successful
---@param eventKey string IEvent.Key
---@param fulfillFunc function Must return a string or a partial Response table { Message="", GlobalVars={} }
---@param name? string (Optional) A descriptive name for the event
---@return boolean success
function EventHandler.addNewGameEvent(eventKey, fulfillFunc, name)
	if Utils.isNilOrEmpty(eventKey) or type(fulfillFunc) ~= "function" then
		return false
	end
	return EventHandler.addNewEvent(EventHandler.IEvent:new({
		Key = eventKey,
		Type = EventHandler.EventTypes.Game,
		Name = name or eventKey,
		Fulfill = fulfillFunc,
	}))
end

---Internally triggers an event by creating a new Request for it
---@param eventKey string IEvent.Key
---@param input? string
function EventHandler.triggerEvent(eventKey, input)
	local event = EventHandler.Events[eventKey or false]
	if not EventHandler.isValidEvent(event) then
		return
	end
	RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
		EventKey = eventKey,
		Args = { Input = input },
	}))
end

--- Removes an IEvent from the events list; returns true if successful
---@param eventKey string IEvent.Key
---@return boolean success
function EventHandler.removeEvent(eventKey)
	if not EventHandler.Events[eventKey] then
		return false
	end
	EventHandler.Events[eventKey] = nil
	return true
end

---Returns the IEvent for a given command; or nil if not found
---@param command string Example: !testcommand
---@return table events List of events with matching commands
function EventHandler.getEventsForCommand(command)
	local events = {}
	if Utils.isNilOrEmpty(command) then
		return events
	end
	if command:sub(1,1) ~= EventHandler.COMMAND_PREFIX then
		command = EventHandler.COMMAND_PREFIX .. command
	end
	command = Utils.toLowerUTF8(command)
	for _, event in pairs(EventHandler.Events) do
		if event.Command == command then
			table.insert(events, event)
		end
	end
	return events
end

---Returns the IEvent for a given rewardId; or nil if not found
---@param rewardId string
---@return table events List of events with matching rewards
function EventHandler.getEventsForReward(rewardId)
	local events = {}
	if Utils.isNilOrEmpty(rewardId) then
		return events
	end
	for _, event in pairs(EventHandler.Events) do
		if event.RewardId == rewardId then
			table.insert(events, event)
		end
	end
	return events
end

---Updates internal Reward events with associated RewardIds and RewardTitles
---@param rewards table
function EventHandler.updateRewardList(rewards)
	-- Unsure if this clear out is necessary yet
	if #rewards > 0 then
		EventHandler.RewardsExternal = {}
	end

	for _, reward in pairs(rewards or {}) do
		if not Utils.isNilOrEmpty(reward.Id) and reward.Title then
			EventHandler.RewardsExternal[reward.Id] = reward.Title
		end
	end
	-- Temp disable any Reward events without matching reward ids
	for _, event in pairs(EventHandler.Events) do
		if event.Type == EventHandler.EventTypes.Reward and event.IsEnabled and event.RewardId and not EventHandler.RewardsExternal[event.RewardId] then
			event.IsEnabled = false
		end
	end
end

---Saves a configurable settings attribute for an event to the Settings.ini file
---@param event table IEvent
---@param attribute string The IEvent attribute being saved
function EventHandler.saveEventSetting(event, attribute)
	if not EventHandler.isValidEvent(event) or not attribute then
		return
	end
	local defaultEvent = EventHandler.DefaultEvents[event.Key] or {}
	local key = string.format(EventHandler.EVENT_SETTINGS_FORMAT, event.Key, attribute)
	local value = event[attribute]
	-- Only save if the value isn't empty and it's not the known default value (keep Settings file a bit cleaner)
	if value ~= nil and value ~= defaultEvent[attribute] then
		Main.SetMetaSetting("network", key, value)
	else
		Main.RemoveMetaSetting("network", key)
	end
	Main.SaveSettings(true)
	event.ConfigurationUpdated = true
end

---Loads all configurable settings for an event from the Settings.ini file
---@param event table IEvent
function EventHandler.loadEventSettings(event)
	if not EventHandler.isValidEvent(event) then
		return false
	end
	local anyLoaded = false
	for attribute, existingValue in pairs(event) do
		local key = string.format(EventHandler.EVENT_SETTINGS_FORMAT, event.Key, attribute)
		local value = Main.MetaSettings.network[key]
		if value ~= nil and value ~= existingValue then
			event[attribute] = value
			anyLoaded = true
		end
	end
	-- Disable any rewards without associations defined
	if event.Type == EventHandler.EventTypes.Reward and event.IsEnabled and event.RewardId and event.RewardId == "" then
		event.IsEnabled = false
	end
	event.ConfigurationUpdated = anyLoaded or nil
end

---Checks if any event settings have been modified, and if so notify the external application of the changes
function EventHandler.checkForConfigChanges()
	local modifiedEvents = {}
	for _, event in pairs(EventHandler.Events) do
		if event.ConfigurationUpdated then
			table.insert(modifiedEvents, event)
			event.ConfigurationUpdated = nil
		end
	end
	if #modifiedEvents > 0 then
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			EventKey = EventHandler.CoreEventKeys.UpdateEvents,
			Args = modifiedEvents
		}))
	end
end

---Queues up a request to be processed at a later time (not immediate), determined by the event
---@param queueKey string The event queue this request will belong to
---@param request table IRequest
---@return boolean success
function EventHandler.queueRequestForLater(queueKey, request)
	local Q = EventHandler.Queues[queueKey]
	if not Q or Q.Requests[request.GUID] then
		return false
	end
	Q.Requests[request.GUID] = request
	-- Refresh the queue if it's open on the screen
	if StreamConnectOverlay.isDisplayed and StreamConnectOverlay.currentTab == StreamConnectOverlay.Tabs.Queue then
		StreamConnectOverlay.buildPagedButtons()
	end
	return true
end

---Cancels and removes all active Requests from the requests queue; returns number that were cancelled
---@return number numCancelled
function EventHandler.cancelAllQueues()
	local count = 0
	for _, queue in pairs(EventHandler.Queues or {}) do
		for _, request in pairs(queue.Requests or {}) do
			request.IsCancelled = true
			count = count + 1
		end
		queue.ActiveRequest = nil
		queue.Requests = {}
	end
	return count
end

function EventHandler.addDefaultEvents()
	-- Add these events directly, as they aren't modifiable by the user
	for key, event in pairs(EventHandler.CoreEvents) do
		event.IsEnabled = true
		event.Key = key
		EventHandler.addNewEvent(event)
	end

	-- Make a copy of each default event, such that they can still be referenced without being changed.
	for key, event in pairs(EventHandler.DefaultEvents) do
		event.IsEnabled = true
		event.Key = key
		local eventCopy = EventHandler.IEvent:new()
		FileManager.copyTable(event, eventCopy)
		EventHandler.addNewEvent(eventCopy)
	end
end

function EventHandler.isDuplicateCommandRequest(event, request)
	if event.Type ~= EventHandler.EventTypes.Command then
		return false
	end
	if not request.SanitizedInput then
		RequestHandler.sanitizeInput(request)
	end
	if not event.RecentRequests then
		event.RecentRequests = {}
	elseif event.RecentRequests[request.SanitizedInput] then
		return true
	end
	event.RecentRequests[request.SanitizedInput] = os.time() + EventHandler.DUPLICATE_COMMAND_COOLDOWN
	return false
end

function EventHandler.cleanupDuplicateCommandRequests()
	local currentTime = os.time()
	for _, event in pairs(EventHandler.Events) do
		if event.Type == EventHandler.EventTypes.Command and event.RecentRequests then
			for requestInput, timestamp in pairs(event.RecentRequests) do
				if currentTime > timestamp then
					event.RecentRequests[requestInput] = nil
				end
			end
		end
	end
end

-- Helper functions; likely move these elsewhere
local function parseBallChoice(input)
	if input == "l" or Utils.containsText(input, "left") then
		return "Left", 1
	elseif input == "r" or Utils.containsText(input, "right") then
		return "Right", 3
	elseif input == "m" or Utils.containsText(input, "mid") then
		return "Middle", 2
	else
		return "Random", TrackerScreen.randomlyChooseBall() or math.random(3)
	end
end

local function changeStarterFavorite(pokemonName, slotNumber)
	-- Slot must be between 1 and 3, inclusive
	slotNumber = math.max(math.min(tonumber(slotNumber or "") or 1, 3), 1)
	local pokemonID = pokemonName and DataHelper.findPokemonId(pokemonName) or 0
	if not PokemonData.isValid(pokemonID) then
		return nil
	end

	local faveButtons = {
		StreamerScreen.Buttons.PokemonFavorite1,
		StreamerScreen.Buttons.PokemonFavorite2,
		StreamerScreen.Buttons.PokemonFavorite3,
	}
	local originalFaveId = faveButtons[slotNumber].pokemonID
	local originalFaveName = PokemonData.isValid(originalFaveId) and PokemonData.Pokemon[originalFaveId].name or Constants.BLANKLINE
	faveButtons[slotNumber].pokemonID = pokemonID
	StreamerScreen.saveFavorites()

	return string.format("Favorite #%s changed from %s to %s.",
		slotNumber,
		originalFaveName,
		PokemonData.Pokemon[pokemonID].name)
end

EventHandler.CoreEvents = {
	-- TS_: Tracker Server (Core events that shouldn't be modified)
	[EventHandler.CoreEventKeys.Start] = {
		Type = EventHandler.EventTypes.Tracker,
		Exclude = true,
		Process = function(self, request)
			-- Wait to hear from Streamerbot before fulfilling this request
			return request.Args.Source == RequestHandler.SOURCE_STREAMERBOT
		end,
		Fulfill = function(self, request)
			Network.updateConnectionState(Network.ConnectionState.Established)
			Network.checkVersion(request.Args and request.Args.Version or "")
			RequestHandler.removedExcludedRequests()
			StreamerScreen.refreshButtons()
			StreamConnectOverlay.refreshButtons()
			return RequestHandler.REQUEST_COMPLETE
		end,
	},
	[EventHandler.CoreEventKeys.Stop] = {
		Type = EventHandler.EventTypes.Tracker,
		Exclude = true,
		Process = function(self, request)
			local ableToStop = Network.CurrentConnection.State >= Network.ConnectionState.Established
			-- Wait to hear from Streamerbot before fulfilling this request
			return ableToStop and request.Args.Source == RequestHandler.SOURCE_STREAMERBOT
		end,
		Fulfill = function(self, request)
			Network.updateConnectionState(Network.ConnectionState.Listen)
			RequestHandler.removedExcludedRequests()
			StreamerScreen.refreshButtons()
			StreamConnectOverlay.refreshButtons()
			return RequestHandler.REQUEST_COMPLETE
		end,
	},
	[EventHandler.CoreEventKeys.GetRewards] = {
		Type = EventHandler.EventTypes.Tracker,
		Exclude = true,
		Process = function(self, request)
			-- Wait to hear from Streamerbot before fulfilling this request
			return request.Args.Source == RequestHandler.SOURCE_STREAMERBOT
		end,
		Fulfill = function(self, request)
			EventHandler.updateRewardList(request.Args.Rewards)
			return RequestHandler.REQUEST_COMPLETE
		end,
	},
	[EventHandler.CoreEventKeys.UpdateEvents] = {
		Type = EventHandler.EventTypes.Tracker,
		Exclude = true,
		Fulfill = function(self, request)
			local allowedEvents = {}
			for _, event in pairs(EventHandler.Events) do
				if event.IsEnabled and not event.Exclude then
					if event.Type == EventHandler.EventTypes.Command then
						table.insert(allowedEvents, event.Command:sub(2))
					elseif event.Type == EventHandler.EventTypes.Reward then
						table.insert(allowedEvents, event.RewardId)
					end
				end
			end
			return {
				AdditionalInfo = {
					AllowedEvents = table.concat(allowedEvents, ","),
					CommandRoles = Network.Options["CommandRoles"] or EventHandler.CommandRoles.Everyone,
				},
			}
		end,
	}
}

EventHandler.DefaultEvents = {
	-- CMD_: Chat Commands
	CMD_Pokemon = {
		Type = EventHandler.EventTypes.Command,
		Name = "Pokémon Info", -- TODO: Language
		Command = "!pokemon",
		Help = "name > Displays useful game info for a Pokémon.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.SanitizedInput) end,
	},
	CMD_BST = {
		Type = EventHandler.EventTypes.Command,
		Name = "Pokémon BST", -- TODO: Language
		Command = "!bst",
		Help = "name > Displays the base stat total (BST) for a Pokémon.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.SanitizedInput) end,
	},
	CMD_Weak = {
		Type = EventHandler.EventTypes.Command,
		Name = "Pokémon Weaknesses", -- TODO: Language
		Command = "!weak",
		Help = "name > Displays the weaknesses for a Pokémon.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.SanitizedInput) end,
	},
	CMD_Move = {
		Type = EventHandler.EventTypes.Command,
		Name = "Move Info", -- TODO: Language
		Command = "!move",
		Help = "name > Displays game info for a move.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.SanitizedInput) end,
	},
	CMD_Ability = {
		Type = EventHandler.EventTypes.Command,
		Name = "Ability Info", -- TODO: Language
		Command = "!ability",
		Help = "name > Displays game info for a Pokémon's ability.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.SanitizedInput) end,
	},
	CMD_Route = {
		Type = EventHandler.EventTypes.Command,
		Name = "Route Info", -- TODO: Language
		Command = "!route",
		Help = "name > Displays trainer and wild encounter info for a route or area.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.SanitizedInput) end,
	},
	CMD_Dungeon = {
		Type = EventHandler.EventTypes.Command,
		Name = "Dungeon Info", -- TODO: Language
		Command = "!dungeon",
		Help = "name > Displays info about which trainers have been defeated for an area.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.SanitizedInput) end,
	},
	CMD_Pivots = {
		Type = EventHandler.EventTypes.Command,
		Name = "Pivots Seen", -- TODO: Language
		Command = "!pivots",
		Help = "name > Displays known early game wild encounters for an area.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.SanitizedInput) end,
	},
	CMD_Revo = {
		Type = EventHandler.EventTypes.Command,
		Name = "Pokémon Random Evolutions", -- TODO: Language
		Command = "!revo",
		Help = "name [target-evo] > Displays randomized evolution possibilities for a Pokémon, and it's [target-evo] if more than one available.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.SanitizedInput) end,
	},
	CMD_Coverage = {
		Type = EventHandler.EventTypes.Command,
		Name = "Move Coverage Effectiveness", -- TODO: Language
		Command = "!coverage",
		Help = "types [fully evolved] > For a list of move types, checks all Pokémon matchups (or only [fully evolved]) for effectiveness.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.SanitizedInput) end,
	},
	CMD_Heals = {
		Type = EventHandler.EventTypes.Command,
		Name = "Heals in Bag", -- TODO: Language
		Command = "!heals",
		Help = "[hp pp status berries] > Displays all healing items in the bag, or only those for a specified [category].",
		Fulfill = function(self, request) return DataHelper.EventRequests.getHeals(request.SanitizedInput) end,
	},
	CMD_TMs = {
		Type = EventHandler.EventTypes.Command,
		Name = "TM Lookup", -- TODO: Language
		Command = "!tms",
		Help = "[gym hm #] > Displays all TMs in the bag, or only those for a specified [category] or TM #.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getTMsHMs(request.SanitizedInput) end,
	},
	CMD_Search = {
		Type = EventHandler.EventTypes.Command,
		Name = "Search Tracked Info", -- TODO: Language
		Command = "!search",
		Help = "searchterms > Search tracked info for a Pokémon, move, or ability.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearch(request.SanitizedInput) end,
	},
	CMD_SearchNotes = {
		Type = EventHandler.EventTypes.Command,
		Name = "Search Notes on Pokémon", -- TODO: Language
		Command = "!searchnotes",
		Help = "notes > Displays a list of Pokémon with any matching notes.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearchNotes(request.SanitizedInput) end,
	},
	CMD_Theme = {
		Type = EventHandler.EventTypes.Command,
		Name = "Theme Export", -- TODO: Language
		Command = "!theme",
		Help = "name > Displays the name and code string for a Tracker theme.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getTheme(request.SanitizedInput) end,
	},
	CMD_GameStats = {
		Type = EventHandler.EventTypes.Command,
		Name = "Game Stats", -- TODO: Language
		Command = "!gamestats",
		Help = "> Displays fun stats for the current game.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getGameStats(request.SanitizedInput) end,
	},
	CMD_Progress = {
		Type = EventHandler.EventTypes.Command,
		Name = "Game Progress", -- TODO: Language
		Command = "!progress",
		Help = "> Displays fun progress percentages for the current game.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getProgress(request.SanitizedInput) end,
	},
	CMD_Log = {
		Type = EventHandler.EventTypes.Command,
		Name = "Log Randomizer Settings", -- TODO: Language
		Command = "!log",
		Help = "> If the log has been opened, displays shareable randomizer settings from the log for current game.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getLog(request.SanitizedInput) end,
	},
	CMD_About = {
		Type = EventHandler.EventTypes.Command,
		Name = "About the Tracker", -- TODO: Language
		Command = "!about",
		Help = "> Displays info about the Ironmon Tracker and game being played.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbout(request.SanitizedInput) end,
	},
	CMD_Help = {
		Type = EventHandler.EventTypes.Command,
		Name = "Command Help", -- TODO: Language
		Command = "!help",
		Help = "[command] > Displays a list of all commands, or help info for a specified [command].",
		Fulfill = function(self, request) return DataHelper.EventRequests.getHelp(request.SanitizedInput) end,
	},

	-- CR_: Channel Rewards (Point Redeems)
	CR_PickBallOnce = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Pick Starter Ball (One Try)",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", "O_RequireChosenMon" },
		O_SendMessage = true,
		O_AutoComplete = true,
		O_RequireChosenMon = true,
		Process = function(self, request)
			EventHandler.queueRequestForLater("BallRedeems", request)
			if EventHandler.Queues.BallRedeems.CannotRedeemThisSeed then
				return false
			elseif not EventHandler.Queues.BallRedeems.ActiveRequest then
				EventHandler.Queues.BallRedeems.ActiveRequest = request
			elseif EventHandler.Queues.BallRedeems.ActiveRequest ~= request then
				return false
			end

			if not Program.isValidMapLocation() then
				return false
			end

			local pokemon = Tracker.getPokemon(1, true) or {}
			local hasPokemon = PokemonData.isValid(pokemon.pokemonID)

			-- Check first if this seed is ineligible for a ball redeem (game is already in progress)
			if not EventHandler.Queues.BallRedeems.HasPickedBall and hasPokemon then
				EventHandler.Queues.BallRedeems.CannotRedeemThisSeed = true
				return false
			end
			-- Then pick the ball (if not already picked)
			if not EventHandler.Queues.BallRedeems.HasPickedBall then
				-- Parse user input or the reward name to determine the chosen ball direction; default random
				local input = Utils.toLowerUTF8(request.SanitizedInput)
				if Utils.isNilOrEmpty(input) then
					input = Utils.toLowerUTF8((request.Args or {}).RewardName or "")
				end
				local direction, ballNumber = parseBallChoice(input)

				TrackerScreen.PokeBalls.chosenBall = ballNumber
				EventHandler.Queues.BallRedeems.ChosenUsername = request.Username
				EventHandler.Queues.BallRedeems.ChosenDirection = direction
				EventHandler.Queues.BallRedeems.HasPickedBall = true
			end
			-- Finally, wait until the player has a Pokemon before completing the redeem request
			if not hasPokemon then
				return false
			end

			local chosenCorrectly = true
			if self.O_RequireChosenMon then
				chosenCorrectly = Utils.getStarterMonChoice() == TrackerScreen.PokeBalls.chosenBall
			end

			-- This condition is complete when the player has a Pokémon in their party while in the Lab, but haven't fought the Rival yet
			local stillInLab = RouteData.Locations.IsInLab[TrackerAPI.getMapId()]
			local hasFoughtRival = Tracker.getWhichRival() ~= nil
			return stillInLab and not hasFoughtRival and chosenCorrectly
		end,
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			EventHandler.Queues.BallRedeems.CannotRedeemThisSeed = true
			local pokemon = Tracker.getPokemon(1, true) or {}
			local pokemonName = PokemonData.Pokemon[pokemon.pokemonID or false].name or "N/A"
			if self.O_SendMessage then
				response.Message = string.format("%s's ball pick redeem complete (one try): %s is the chosen starter Pokémon!", request.Username, pokemonName)
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_PickBallUntilOut = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Pick Starter Ball (Until Out)",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", "O_RequireChosenMon" },
		O_SendMessage = true,
		O_AutoComplete = true,
		O_RequireChosenMon = true,
		Process = function(self, request)
			EventHandler.queueRequestForLater("BallRedeems", request)
			if EventHandler.Queues.BallRedeems.CannotRedeemThisSeed then
				return false
			elseif not EventHandler.Queues.BallRedeems.ActiveRequest then
				EventHandler.Queues.BallRedeems.ActiveRequest = request
			elseif EventHandler.Queues.BallRedeems.ActiveRequest ~= request then
				return false
			end

			if not Program.isValidMapLocation() then
				return false
			end

			local pokemon = Tracker.getPokemon(1, true) or {}
			local hasPokemon = PokemonData.isValid(pokemon.pokemonID)

			-- Check first if this seed is ineligible for a ball redeem (game is already in progress)
			if not EventHandler.Queues.BallRedeems.HasPickedBall and hasPokemon then
				EventHandler.Queues.BallRedeems.CannotRedeemThisSeed = true
				return false
			end
			-- Then pick the ball (if not already picked)
			if not EventHandler.Queues.BallRedeems.HasPickedBall then
				-- Parse user input or the reward name to determine the chosen ball direction; default random
				local input = Utils.toLowerUTF8(request.SanitizedInput)
				if Utils.isNilOrEmpty(input) then
					input = Utils.toLowerUTF8((request.Args or {}).RewardName or "")
				end
				local direction, ballNumber = parseBallChoice(input)

				TrackerScreen.PokeBalls.chosenBall = ballNumber
				EventHandler.Queues.BallRedeems.ChosenUsername = request.Username
				EventHandler.Queues.BallRedeems.ChosenDirection = direction
				EventHandler.Queues.BallRedeems.HasPickedBall = true
			end
			-- Finally, wait until the player has a Pokemon before completing the redeem request
			if not hasPokemon then
				return false
			end

			local chosenCorrectly = true
			if self.O_RequireChosenMon then
				chosenCorrectly = Utils.getStarterMonChoice() == TrackerScreen.PokeBalls.chosenBall
			end

			-- This condition is complete when the player has a Pokémon in their party and they've just beaten the Lab Rival
			local lastBattleStatus = Memory.readbyte(GameSettings.gBattleOutcome) -- [0 = In battle, 1 = Won the match, 2 = Lost the match, 4 = Fled, 7 = Caught]
			local lastFoughtTrainerId = Memory.readword(GameSettings.gTrainerBattleOpponent_A)
			local rivalIds
			if GameSettings.game == 3 then -- FRLG
				rivalIds = { [326] = true, [327] = true, [328] = true }
			else -- RSE
				rivalIds = { [520] = true, [523] = true, [526] = true, [529] = true, [532] = true, [535] = true }
			end
			-- Won the battle against the first rival
			return lastBattleStatus == 1 and rivalIds[lastFoughtTrainerId] ~= nil and chosenCorrectly
		end,
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			EventHandler.Queues.BallRedeems.CannotRedeemThisSeed = true
			local pokemon = Tracker.getPokemon(1, true) or {}
			local pokemonName = PokemonData.Pokemon[pokemon.pokemonID or false].name or "N/A"
			if self.O_SendMessage then
				response.Message = string.format("%s's ball pick redeem complete (until out): The chosen starter %s gets out!", request.Username, pokemonName)
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_ChangeFavorite = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Change Starter Favorite: # NAME",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", },
		O_SendMessage = true,
		O_AutoComplete = true,
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			if Utils.isNilOrEmpty(request.SanitizedInput) then
				response.Message = string.format("> Unable to change a favorite, please enter a number (1, 2, or 3) followed by a Pokémon name.")
				return response
			end
			local slotNumber, pokemonName = request.SanitizedInput:match("^#?(%d*)%s*(%D.+)")
			local successMsg = changeStarterFavorite(pokemonName, slotNumber)
			if not successMsg then
				response.Message = string.format("%s > Unable to change a favorite, please enter a number (1, 2, or 3) followed by a Pokémon name.", request.SanitizedInput)
				return response
			end
			if self.O_SendMessage then
				response.Message = successMsg
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_ChangeFavoriteOne = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Change Starter Favorite: #1",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", },
		O_SendMessage = true,
		O_AutoComplete = true,
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			if Utils.isNilOrEmpty(request.SanitizedInput) then
				response.Message = string.format("> Unable to change favorite #1, please enter a valid Pokémon name.")
				return response
			end
			local successMsg = changeStarterFavorite(request.SanitizedInput, 1)
			if not successMsg then
				response.Message = string.format("%s > Unable to change favorite #1, please enter a valid Pokémon name.", request.SanitizedInput)
				return response
			end
			if self.O_SendMessage then
				response.Message = successMsg
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_ChangeFavoriteTwo = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Change Starter Favorite: #2",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", },
		O_SendMessage = true,
		O_AutoComplete = true,
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			if Utils.isNilOrEmpty(request.SanitizedInput) then
				response.Message = string.format("> Unable to change favorite #2, please enter a valid Pokémon name.")
				return response
			end
			local successMsg = changeStarterFavorite(request.SanitizedInput, 2)
			if not successMsg then
				response.Message = string.format("%s > Unable to change favorite #2, please enter a valid Pokémon name.", request.SanitizedInput)
				return response
			end
			if self.O_SendMessage then
				response.Message = successMsg
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_ChangeFavoriteThree = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Change Starter Favorite: #3",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", },
		O_SendMessage = true,
		O_AutoComplete = true,
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			if Utils.isNilOrEmpty(request.SanitizedInput) then
				response.Message = string.format("> Unable to change favorite #3, please enter a valid Pokémon name.")
				return response
			end
			local successMsg = changeStarterFavorite(request.SanitizedInput, 3)
			if not successMsg then
				response.Message = string.format("%s > Unable to change favorite #3, please enter a valid Pokémon name.", request.SanitizedInput)
				return response
			end
			if self.O_SendMessage then
				response.Message = successMsg
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_ChangeTheme = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Change Tracker Theme",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", "O_Duration", },
		O_SendMessage = true,
		O_AutoComplete = true,
		-- O_Duration = tostring(10 * 60), -- # of seconds
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			if Utils.isNilOrEmpty(request.SanitizedInput) then
				response.Message = string.format("> Unable to change Tracker Theme, please enter a valid theme code or name.")
				return response
			end
			local themeName
			-- Check if the input a theme code
			if Theme.importThemeFromText(request.SanitizedInput, true) then
				themeName = "Custom"
				for i, themePair in ipairs(Theme.Presets or {}) do
					-- Skip the "Active Theme"
					if i ~= 1 and themePair.code == request.SanitizedInput then
						themeName = themePair:getText()
						break
					end
				end
			else -- Otherwise, check if the input is a theme name
				local inputAsLower = Utils.toLowerUTF8(request.SanitizedInput)
				local themeNames = {}
				for i, themePair in ipairs(Theme.Presets or {}) do
					-- Skip the "Active Theme"
					if i ~= 1 then
						themeNames[i] = Utils.toLowerUTF8(themePair:getText())
					end
				end
				local foundThemeKey = Utils.getClosestWord(inputAsLower, themeNames, 3)
				if foundThemeKey then
					local themePair = Theme.Presets[foundThemeKey]
					if Theme.importThemeFromText(themePair.code, true) then
						themeName = themePair:getText()
					end
				end
			end

			if not themeName then
				response.Message = string.format("%s > Unable to change Tracker Theme, please enter a valid theme code or name.", request.SanitizedInput)
				return response
			end

			Theme.setNextMoveLevelHighlight(true)
			if self.O_SendMessage then
				response.Message = string.format("> Tracker Theme changed to %s.", themeName)
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
	CR_ChangeLanguage = {
		Type = EventHandler.EventTypes.Reward,
		Name = "Change Tracker Language",
		RewardId = "",
		Options = { "O_SendMessage", "O_AutoComplete", },
		O_SendMessage = true,
		O_AutoComplete = true,
		-- O_Duration = tostring(10 * 60), -- # of seconds
		Fulfill = function(self, request)
			local response = { AdditionalInfo = { AutoComplete = false } }
			if Utils.isNilOrEmpty(request.SanitizedInput) then
				response.Message = string.format("> Unable to change Tracker language, please enter a valid language name.")
				return response
			end

			-- Search both the language keys (English names) and their display names
			local langKeys, langDisplays = {}, {}
			for key, lang in pairs(Resources.Languages or {}) do
				if not lang.ExcludeFromSettings then
					langKeys[key] = Utils.toLowerUTF8(key)
					langDisplays[key] = Utils.toLowerUTF8(lang.DisplayName)
				end
			end
			local inputAsLower = Utils.toLowerUTF8(request.SanitizedInput)
			local foundKey = Utils.getClosestWord(inputAsLower, langKeys, 3)
			if not foundKey then
				foundKey = Utils.getClosestWord(inputAsLower, langDisplays, 3)
			end
			local language = Resources.Languages[foundKey or false]

			if not language then
				response.Message = string.format("%s > Unable to change Tracker language, please enter a valid language name.", request.SanitizedInput)
				return response
			end

			if Options["Autodetect language from game"] then
				Options["Autodetect language from game"] = false
				Main.SaveSettings(true)
			end
			local prevLangName = Resources.currentLanguage.DisplayName
			Resources.loadAndApplyLanguage(language)

			if self.O_SendMessage then
				response.Message = string.format("> Tracker Language changed from %s to %s.", prevLangName, language.DisplayName)
			end
			response.AdditionalInfo.AutoComplete = self.O_AutoComplete
			return response
		end,
	},
}

-- Event object prototypes

EventHandler.IEvent = {
	-- Required unique key
	Key = EventHandler.Events.None.Key,
	-- Required type
	Type = EventHandler.EventTypes.None,
	-- Required display name of the event
	Name = "",
	-- Enable/Disable from triggering
	IsEnabled = true,
	-- Determine what to do with the IRequest, return true if ready to fulfill
	Process = function(self, request) return true end,
	-- Only after fully processed and ready, finish completing the request and return a response message or partial response table
	Fulfill = function(self, request) return "" end,
}
---Creates and returns a new IEvent object
---@param o? table Optional initial object table
---@return table event An IEvent object
function EventHandler.IEvent:new(o)
	o = o or {}
	o.Key = o.Key or EventHandler.Events.None.Key
	o.Type = o.Type or EventHandler.EventTypes.None
	o.IsEnabled = o.IsEnabled ~= nil and o.IsEnabled or true
	setmetatable(o, self)
	self.__index = self
	return o
end
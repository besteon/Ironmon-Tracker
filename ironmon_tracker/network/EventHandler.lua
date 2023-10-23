EventHandler = {
	RewardsExternal = {}, -- A list of external rewards
	Queues = {}, -- A table of lists for each set of processed requests that still need to be fulfilled
	EVENT_SETTINGS_FORMAT = "Event__%s__%s",

	-- Shared values between server and client
	COMMAND_PREFIX = "!",

	-- TODO: CUSTOM OPTIONS FOR TESTING
	OutputToFileRewardUsername = true,
	OutputToFileRewardDirection = true,
	RedemptionUsernameOutput = "RedemptionUser.txt",
	RedemptionDirectionOutput = "RedemptionDirection.txt",
}

EventHandler.CoreEventTypes = {
	Start = "TS_Start",
	Stop = "TS_Stop",
	GetRewards = "TS_GetRewardsList",
	UpdateEvents = "TS_UpdateEvents",
}

EventHandler.Events = {
	None = { Key = "None", Exclude = true },
}

EventHandler.EventRoles = {
	Everyone = "Everyone", -- Allow all users, regardless of other roles selected
	Broadcaster = "Broadcaster", -- Allow the one user who is the Broadcaster
	Mods = "Mods", -- Allow users that are Moderators
	VIPs = "VIPs", -- Allow users with VIP
	Subs = "Subs", -- Allow users that are Subscribers
	Custom = "Custom", -- Allow users that belong to a custom-defined role
}

function EventHandler.reset()
	EventHandler.RewardsExternal = {}
	EventHandler.Queues = {
		BallRedeems = { Requests = {}, },
		-- ThemeChanges = { Requests = {}, },
		-- LanguageChanges = { Requests = {}, },
	}
	EventHandler.outputCurrentRedemption()
end

---Checks if the event is of a known event type
---@param eventType string IEvent.Type
---@return boolean
function EventHandler.isValidEvent(eventType)
	return EventHandler.Events[eventType or false] and eventType ~= EventHandler.Events.None.Key
end

--- Adds an IEvent to the events list; returns true if successful
---@param event table IEvent object (requires: Key, Process, Fulfill)
---@return boolean success
function EventHandler.addNewEvent(event)
	-- Only add new, properly structured  events
	if EventHandler.Events[event.Key or false] then
		return false
	end
	if type(event.Process) ~= "function" or type(event.Fulfill) ~= "function" then
		return false
	end
	EventHandler.Events[event.Key] = event
	EventHandler.loadEventSettings(event)
	return true
end

--- Removes an IEvent from the events list; returns true if successful
---@param eventKey string IEvent.KEY
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
---@return table? event
function EventHandler.getEventForCommand(command)
	if (command or "") == "" then
		return nil
	end
	if command:sub(1,1) ~= EventHandler.COMMAND_PREFIX then
		command = EventHandler.COMMAND_PREFIX .. command
	end
	command = Utils.toLowerUTF8(command)
	for _, event in pairs(EventHandler.Events) do
		if event.Command == command then
			return event
		end
	end
end

---Returns the IEvent for a given rewardId; or nil if not found
---@param rewardId string
---@return table? event
function EventHandler.getEventForReward(rewardId)
	if (rewardId or "") == "" then
		return nil
	end
	for _, event in pairs(EventHandler.Events) do
		if event.RewardId == rewardId then
			return event
		end
	end
end

---Updates internal Reward events with associated RewardIds and RewardTitles
---@param rewards table
function EventHandler.updateRewardList(rewards)
	-- Unsure if this clear out is necessary yet
	if #rewards > 0 then
		EventHandler.RewardsExternal = {}
	end

	for _, reward in pairs(rewards or {}) do
		if reward.Id and reward.Title and reward.Id ~= "" then
			EventHandler.RewardsExternal[reward.Id] = reward.Title
		end
	end
	-- Temp disable any Reward events without matching reward ids
	for _, event in pairs(EventHandler.Events) do
		if event.IsEnabled and event.RewardId and not EventHandler.RewardsExternal[event.RewardId] then
			event.IsEnabled = false
		end
	end
end

---Saves a configurable settings attribute for an event to the Settings.ini file
---@param event table IEvent
---@param attribute string The IEvent attribute being saved
function EventHandler.saveEventSetting(event, attribute)
	if not EventHandler.isValidEvent(event.Key) or not attribute then
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
	if not EventHandler.isValidEvent(event.Key) then
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
	if event.IsEnabled and event.RewardId == "" then
		event.IsEnabled = false
	end
	event.ConfigurationUpdated = anyLoaded or nil
end

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
			EventType = EventHandler.Events[EventHandler.CoreEventTypes.UpdateEvents].Key,
			Args = modifiedEvents
		}))
	end
end

function EventHandler.queueNewRequest(queueKey, request)
	local Q = EventHandler.Queues[queueKey]
	if not Q or Q.Requests[request.GUID] then
		return false
	end
	Q.Requests[request.GUID] = request
	return true
end

---Cancels and removes all active Requests from the requests queue; returns number that were cancelled
---@return number numCancelled
function EventHandler.cancelAllQueues()
	local count = 0
	for _, queue in pairs(EventHandler.Queues) do
		for _, request in pairs(queue.Requests) do
			request.IsCancelled = true
			count = count + 1
		end
		queue.ActiveRequest = nil
		queue.Requests = {}
	end
	return count
end

function EventHandler.addDefaultEvents()
	-- TS_: Tracker Server (Core events that shouldn't be modified)
	EventHandler.addNewEvent(EventHandler.IEvent:new({
		Key = EventHandler.CoreEventTypes.Start,
		Exclude = true,
		Process = function(self, request)
			-- Wait to hear from Streamerbot before fulfilling this request
			return request.Args.Source == RequestHandler.SOURCE_STREAMERBOT
		end,
		Fulfill = function(self, request)
			Network.updateConnectionState(Network.ConnectionState.Established)
			RequestHandler.removedExcludedRequests()
			StreamConnectOverlay.refreshButtons()
			return RequestHandler.REQUEST_COMPLETE
		end,
	}))
	EventHandler.addNewEvent(EventHandler.IEvent:new({
		Key = EventHandler.CoreEventTypes.Stop,
		Exclude = true,
		Process = function(self, request)
			local ableToStop = Network.CurrentConnection.State >= Network.ConnectionState.Established
			-- Wait to hear from Streamerbot before fulfilling this request
			return ableToStop and request.Args.Source == RequestHandler.SOURCE_STREAMERBOT
		end,
		Fulfill = function(self, request)
			Network.updateConnectionState(Network.ConnectionState.Listen)
			RequestHandler.removedExcludedRequests()
			StreamConnectOverlay.refreshButtons()
			return RequestHandler.REQUEST_COMPLETE
		end,
	}))
	EventHandler.addNewEvent(EventHandler.IEvent:new({
		Key = EventHandler.CoreEventTypes.GetRewards,
		Exclude = true,
		Process = function(self, request)
			-- Wait to hear from Streamerbot before fulfilling this request
			return request.Args.Source == RequestHandler.SOURCE_STREAMERBOT
		end,
		Fulfill = function(self, request)
			EventHandler.updateRewardList(request.Args.Rewards)
			return RequestHandler.REQUEST_COMPLETE
		end,
	}))
	EventHandler.addNewEvent(EventHandler.IEvent:new({
		Key = EventHandler.CoreEventTypes.UpdateEvents,
		Exclude = true,
		Fulfill = function(self, request)
			local allowedEvents = {}
			for _, event in pairs(EventHandler.Events) do
				if event.IsEnabled and not event.Exclude then
					if event.Command and event.Command ~= "" then
						table.insert(allowedEvents, event.Command:sub(2))
					elseif event.RewardId and event.RewardId ~= "" then
						table.insert(allowedEvents, event.RewardId)
					end
				end
			end
			return #allowedEvents > 0 and table.concat(allowedEvents, ",") or ""
		end,
	}))

	-- Make a copy of each default event, such that they can still be referenced without being changed.
	for key, event in pairs(EventHandler.DefaultEvents) do
		event.IsEnabled = true
		local eventToAdd = EventHandler.IEvent:new({
			Key = key,
			Name = event.Name,
			Process = event.Process,
			Fulfill = event.Fulfill,
		})
		if event.Command then
			eventToAdd.Command = event.Command
			eventToAdd.Help = event.Help
			eventToAdd.Roles = {}
			FileManager.copyTable(event.Roles, eventToAdd.Roles)
		elseif event.RewardId then
			eventToAdd.RewardId = event.RewardId
			if event.Options then
				eventToAdd.Options = {}
				FileManager.copyTable(event.Options, eventToAdd.Options)
			end
		end
		EventHandler.addNewEvent(eventToAdd)
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

-- Temporary
function EventHandler.outputCurrentRedemption()
	if EventHandler.OutputToFileRewardUsername then
		local filename = EventHandler.RedemptionUsernameOutput or "RedemptionUsernameOutput.txt"
		local file = io.open(FileManager.getCustomFolderPath() .. filename, "w")
		if file then
			local username = EventHandler.Queues.BallRedeems.ChosenUsername or ""
			file:write(username ~= "" and username or Constants.BLANKLINE)
			file:close()
		end
	end
	if EventHandler.OutputToFileRewardDirection then
		local filename = EventHandler.RedemptionDirectionOutput or "RedemptionDirectionOutput.txt"
		local file = io.open(FileManager.getCustomFolderPath() .. filename, "w")
		if file then
			local direction = EventHandler.Queues.BallRedeems.ChosenDirection or Constants.BLANKLINE
			file:write(direction)
			file:close()
		end
	end
end

EventHandler.DefaultEvents = {
	-- CMD_: Chat Commands
	CMD_Pokemon = {
		Name = "Pokémon Info", -- TODO: Language
		Command = "!pokemon",
		Help = "name > Displays useful game info for a Pokémon.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.Args) end,
	},
	CMD_BST = {
		Name = "Pokémon BST", -- TODO: Language
		Command = "!bst",
		Help = "name > Displays the base stat total (BST) for a Pokémon.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.Args) end,
	},
	CMD_Weak = {
		Name = "Pokémon Weaknesses", -- TODO: Language
		Command = "!weak",
		Help = "name > Displays the weaknesses for a Pokémon.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.Args) end,
	},
	CMD_Move = {
		Name = "Move Info", -- TODO: Language
		Command = "!move",
		Help = "name > Displays game info for a move.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.Args) end,
	},
	CMD_Ability = {
		Name = "Ability Info", -- TODO: Language
		Command = "!ability",
		Help = "name > Displays game info for a Pokémon's ability.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.Args) end,
	},
	CMD_Route = {
		Name = "Route Info", -- TODO: Language
		Command = "!route",
		Help = "name > Displays trainer and wild encounter info for a route or area.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.Args) end,
	},
	CMD_Dungeon = {
		Name = "Dungeon Info", -- TODO: Language
		Command = "!dungeon",
		Help = "name > Displays info about which trainers have been defeated for an area.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.Args) end,
	},
	CMD_Pivots = {
		Name = "Pivots Seen", -- TODO: Language
		Command = "!pivots",
		Help = "name > Displays known early game wild encounters for an area.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.Args) end,
	},
	CMD_Revo = {
		Name = "Pokémon Random Evolutions", -- TODO: Language
		Command = "!revo",
		Help = "name [target-evo] > Displays randomized evolution possibilities for a Pokémon, and it's [target-evo] if more than one available.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.Args) end,
	},
	CMD_Coverage = {
		Name = "Move Coverage Effectiveness", -- TODO: Language
		Command = "!coverage",
		Help = "types [fully evolved] > For a list of move types, checks all Pokémon matchups (or only [fully evolved]) for effectiveness.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.Args) end,
	},
	CMD_Heals = {
		Name = "Heals in Bag", -- TODO: Language
		Command = "!heals",
		Help = "[hp pp status berries] > Displays all healing items in the bag, or only those for a specified [category].",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getHeals(request.Args) end,
	},
	CMD_TMs = {
		Name = "TM Lookup", -- TODO: Language
		Command = "!tms",
		Help = "[gym hm #] > Displays all TMs in the bag, or only those for a specified [category] or TM #.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getTMsHMs(request.Args) end,
	},
	CMD_Search = {
		Name = "Search Tracked Info", -- TODO: Language
		Command = "!search",
		Help = "searchterms > Search tracked info for a Pokémon, move, or ability.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearch(request.Args) end,
	},
	CMD_SearchNotes = {
		Name = "Search Notes on Pokémon", -- TODO: Language
		Command = "!searchnotes",
		Help = "notes > Displays a list of Pokémon with any matching notes.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearchNotes(request.Args) end,
	},
	CMD_Theme = {
		Name = "Theme Export", -- TODO: Language
		Command = "!theme",
		Help = "name > Displays the name and code string for a Tracker theme.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getTheme(request.Args) end,
	},
	CMD_GameStats = {
		Name = "Game Stats", -- TODO: Language
		Command = "!gamestats",
		Help = "> Displays fun stats for the current game.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getGameStats(request.Args) end,
	},
	CMD_Progress = {
		Name = "Game Progress", -- TODO: Language
		Command = "!progress",
		Help = "> Displays fun progress percentages for the current game.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getProgress(request.Args) end,
	},
	CMD_Log = {
		Name = "Log Randomizer Settings", -- TODO: Language
		Command = "!log",
		Help = "> If the log has been opened, displays shareable randomizer settings from the log for current game.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getLog(request.Args) end,
	},
	CMD_About = {
		Name = "About the Tracker", -- TODO: Language
		Command = "!about",
		Help = "> Displays info about the Ironmon Tracker and game being played.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbout(request.Args) end,
	},
	CMD_Help = {
		Name = "Command Help", -- TODO: Language
		Command = "!help",
		Help = "[command] > Displays a list of all commands, or help info for a specified [command].",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getHelp(request.Args) end,
	},

	-- CR_: Channel Rewards (Point Redeems)
	CR_PickBallOnce = {
		Name = "Pick Starter Ball (One Try)",
		RewardId = "",
		Process = function(self, request)
			EventHandler.queueNewRequest("BallRedeems", request)
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
				local args = request.Args or {}
				local input = Utils.toLowerUTF8(args.Input or "")
				if input == "" then
					input = Utils.toLowerUTF8(args.RewardName or "")
				end
				local direction, ballNumber = parseBallChoice(input)

				TrackerScreen.PokeBalls.chosenBall = ballNumber
				EventHandler.Queues.BallRedeems.ChosenUsername = request.Username
				EventHandler.Queues.BallRedeems.ChosenDirection = direction
				EventHandler.Queues.BallRedeems.HasPickedBall = true
				EventHandler.outputCurrentRedemption() -- TODO: For Maple, remove later
			end
			-- Finally, wait until the player has a Pokemon before completing the redeem request
			if not hasPokemon then
				return false
			end

			-- This condition is complete when the player has a Pokémon in their party while in the Lab, but haven't fought the Rival yet
			local stillInLab = RouteData.Locations.IsInLab[TrackerAPI.getMapId()]
			local hasFoughtRival = Tracker.getWhichRival() ~= nil
			return stillInLab and not hasFoughtRival
		end,
		Fulfill = function(self, request)
			EventHandler.Queues.BallRedeems.CannotRedeemThisSeed = true
			local pokemon = Tracker.getPokemon(1, true) or {}
			local pokemonName = PokemonData.Pokemon[pokemon.pokemonID or false].name or "N/A"
			return string.format("%s's ball pick redeem complete (one try): %s is the chosen starter Pokémon!", request.Username, pokemonName)
		end,
	},
	CR_PickBallUntilOut = {
		Name = "Pick Starter Ball (Until Out)",
		RewardId = "",
		Process = function(self, request)
			EventHandler.queueNewRequest("BallRedeems", request)
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
				local args = request.Args or {}
				local input = Utils.toLowerUTF8(args.Input or "")
				if input == "" then
					input = Utils.toLowerUTF8(args.RewardName or "")
				end
				local direction, ballNumber = parseBallChoice(input)

				TrackerScreen.PokeBalls.chosenBall = ballNumber
				EventHandler.Queues.BallRedeems.ChosenUsername = request.Username
				EventHandler.Queues.BallRedeems.ChosenDirection = direction
				EventHandler.Queues.BallRedeems.HasPickedBall = true
				EventHandler.outputCurrentRedemption() -- TODO: For Maple, remove later
			end
			-- Finally, wait until the player has a Pokemon before completing the redeem request
			if not hasPokemon then
				return false
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
			return lastBattleStatus == 1 and rivalIds[lastFoughtTrainerId] ~= nil -- Won the battle against the first rival
		end,
		Fulfill = function(self, request)
			EventHandler.Queues.BallRedeems.CannotRedeemThisSeed = true
			local pokemon = Tracker.getPokemon(1, true) or {}
			local pokemonName = PokemonData.Pokemon[pokemon.pokemonID or false].name or "N/A"
			return string.format("%s's ball pick redeem complete (until out): The chosen starter %s gets out!", request.Username, pokemonName)
		end,
	},
	-- CR_ChangeFavorite = {
	-- 	Name = "Change Favorite Pokémon",
	-- 	RewardId = "",
	-- 	Options = {
	-- 		Duration = 10 * 60, -- # of seconds
	-- 	},
	-- 	Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
	-- 		return request.IsReady
	-- 	end,
	-- 	Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	-- },
	CR_ChangeTheme = {
		Name = "Change Tracker Theme (DON'T USE)",
		RewardId = "",
		Options = {
			Duration = 10 * 60, -- # of seconds
		},
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	-- CR_ChangeLanguage = {
	-- 	Name = "Change Tracker Language",
	-- 	RewardId = "",
	-- 	Options = {
	-- 		Duration = 10 * 60, -- # of seconds
	-- 	},
	-- 	Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
	-- 		return request.IsReady
	-- 	end,
	-- 	Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	-- },
}

-- Event object prototypes

EventHandler.IEvent = {
	-- Required unique key
	Key = EventHandler.Events.None.Key,
	-- Required display name of the event
	Name = "",
	-- Enable/Disable from triggering
	IsEnabled = true,
	-- Determine what to do with the IRequest, return true if ready to fulfill (IRequest.IsReady = true)
	Process = function(self, request) return true end,
	-- Only after fully processed and ready, finish completing the request and return a response message
	Fulfill = function(self, request) return "" end,
}
function EventHandler.IEvent:new(o)
	o = o or {}
	o.Key = o.Key or EventHandler.Events.None.Key
	o.IsEnabled = o.IsEnabled ~= nil and o.IsEnabled or true
	setmetatable(o, self)
	self.__index = self
	return o
end
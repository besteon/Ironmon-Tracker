EventHandler = {
	RewardsExternal = {}, -- A list of external rewards
	EVENT_SETTINGS_FORMAT = "Event__%s__%s",

	-- Shared values between server and client
	COMMAND_PREFIX = "!",
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
---@return table|nil event
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
---@return table|nil event
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
			-- TODO: Don't have a good way to send back all of the changed event information. Unsure if embedded JSON is allowed
			return "Server events were updated but their information isn't available. Reason: not implemented."
		end,
	}))

	-- Make a copy of each default event, such that they can still be referenced without being changed.
	for key, event in pairs(EventHandler.DefaultEvents) do
		event.IsEnabled = true
		local eventToAdd = EventHandler.IEvent:new({
			Key = key,
			Process = event.Process,
			Fulfill = event.Fulfill,
		})
		if event.Command then
			eventToAdd.Command = event.Command
			eventToAdd.Help = event.Help
			eventToAdd.Roles = {}
			FileManager.copyTable(event.Roles, eventToAdd.Roles)
		elseif event.RewardName then
			eventToAdd.RewardName = event.RewardName
			eventToAdd.RewardId = event.RewardId
			if event.Options then
				eventToAdd.Options = {}
				FileManager.copyTable(event.Options, eventToAdd.Options)
			end
		end
		EventHandler.addNewEvent(eventToAdd)
	end
end

EventHandler.DefaultEvents = {
	-- CMD_: Chat Commands
	CMD_Pokemon = {
		Command = "!pokemon",
		Help = "name > Displays useful game info for a Pokémon.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.Args) end,
	},
	CMD_BST = {
		Command = "!bst",
		Help = "name > Displays the base stat total (BST) for a Pokémon.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.Args) end,
	},
	CMD_Weak = {
		Command = "!weak",
		Help = "name > Displays the weaknesses for a Pokémon.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.Args) end,
	},
	CMD_Move = {
		Command = "!move",
		Help = "name > Displays game info for a move.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.Args) end,
	},
	CMD_Ability = {
		Command = "!ability",
		Help = "name > Displays game info for a Pokémon's ability.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.Args) end,
	},
	CMD_Route = {
		Command = "!route",
		Help = "name > Displays trainer and wild encounter info for a route or area.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.Args) end,
	},
	CMD_Dungeon = {
		Command = "!dungeon",
		Help = "name > Displays info about which trainers have been defeated for an area.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.Args) end,
	},
	CMD_Pivots = {
		Command = "!pivots",
		Help = "name > Displays known early game wild encounters for an area.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.Args) end,
	},
	CMD_Revo = {
		Command = "!revo",
		Help = "name [target-evo] > Displays randomized evolution possibilities for a Pokémon, and it's [target-evo] if more than one available.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.Args) end,
	},
	CMD_Coverage = {
		Command = "!coverage",
		Help = "types [fully evolved] > For a list of move types, checks all Pokémon matchups (or only [fully evolved]) for effectiveness.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.Args) end,
	},
	CMD_Heals = {
		Command = "!heals",
		Help = "[hp pp status berries] > Displays all healing items in the bag, or only those for a specified [category].",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getHeals(request.Args) end,
	},
	CMD_TMs = {
		Command = "!tms",
		Help = "[gym hm #] > Displays all TMs in the bag, or only those for a specified [category] or TM #.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getTMsHMs(request.Args) end,
	},
	CMD_Search = {
		Command = "!search",
		Help = "[mode] [terms] > Search for a [Pokémon/Move/Ability/Note] followed by the search [terms].",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearch(request.Args) end,
	},
	CMD_Theme = {
		Command = "!theme",
		Help = "> Displays the name and code string for the current Tracker theme.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getTheme(request.Args) end,
	},
	CMD_GameStats = {
		Command = "!gamestats",
		Help = "> Displays fun stats for the current game.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getGameStats(request.Args) end,
	},
	CMD_Progress = {
		Command = "!progress",
		Help = "> Displays fun progress percentages for the current game.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getProgress(request.Args) end,
	},
	CMD_Log = {
		Command = "!log",
		Help = "> If the log has been opened, displays shareable randomizer settings from the log for current game.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getLog(request.Args) end,
	},
	CMD_About = {
		Command = "!about",
		Help = "> Displays info about the Ironmon Tracker and game being played.",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbout(request.Args) end,
	},
	CMD_Help = {
		Command = "!help",
		Help = "[command] > Displays a list of all commands, or help info for a specified [command].",
		Roles = { EventHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getHelp(request.Args) end,
	},

	-- CR_: Channel Rewards (Point Redeems)
	CR_PickBallOnce = {
		RewardName = "Pick Starter Ball (One Try)",
		RewardId = "",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_PickBallUntilOut = {
		RewardName = "Pick Starter Ball (Until Out)",
		RewardId = "",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_ChangeFavorite = {
		RewardName = "Change Favorite Pokémon",
		RewardId = "",
		Options = {
			Duration = 10 * 60, -- # of seconds
		},
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_ChangeTheme = {
		RewardName = "Change Tracker Theme",
		RewardId = "",
		Options = {
			Duration = 10 * 60, -- # of seconds
		},
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_ChangeLanguage = {
		RewardName = "Change Tracker Language",
		RewardId = "",
		Options = {
			Duration = 10 * 60, -- # of seconds
		},
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
}

-- Event object prototypes

EventHandler.IEvent = {
	-- Required unique key
	Key = EventHandler.Events.None.Key,
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
RequestHandler = {
	Requests = {}, -- A list of all known requests that still need to be processed
	Responses = {}, -- A list of all responses ready to be sent
	lastSaveTime = 0,
	SAVE_FREQUENCY = 60, -- Number of seconds to wait before saving Requests data to file
	COMMAND_PREFIX = "!",
	EVENT_SETTINGS_FORMAT = "Event__%s__%s",
	AUTO_DETECT_COMMAND = "CMD_AutoDetect",
}

-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
RequestHandler.StatusCodes = {
	PROCESSING = 102, -- The server (Tracker) has received and is processing the request, but no response is available yet
	SUCCESS = 200, -- The request succeeded and a response message is available
	ALREADY_REPORTED = 208, -- The request is a duplicate of another recent request, no additional response message will be sent
	FAIL = 400, -- The server (Tracker) won't process, likely due to a client error with formatting the request
	NOT_FOUND = 404, -- The server (Tracker) cannot find the requested resource or event
	UNAVAILABLE = 503, -- The server (Tracker) is not able to handle the request, usually because its event hook disabled
}

RequestHandler.Events = {
	None = { Key = "None", Exclude = true },
}

RequestHandler.EventRoles = {
	Everyone = "Everyone", -- Allow all users, regardless of other roles selected
	Broadcaster = "Broadcaster", -- Allow the one user who is the Broadcaster
	Mods = "Mods", -- Allow users that are Moderators
	VIPs = "VIPs", -- Allow users with VIP
	Subs = "Subs", -- Allow users that are Subscribers
	Custom = "Custom", -- Allow users that belong to a custom-defined role
}

function RequestHandler.initialize()
	RequestHandler.Requests = {}
	RequestHandler.Responses = {}
	RequestHandler.lastSaveTime = os.time()
	RequestHandler.addDefaultEvents()
	RequestHandler.loadRequestsData()
	RequestHandler.removeServerSideRequests()
end

--- Adds a IRequest to the requests queue; returns true if successful
---@param request table IRequest object
---@return boolean success
function RequestHandler.addNewRequest(request)
	-- Only add requests if they're new and match an existing event type
	if RequestHandler.Requests[request.GUID] or request.EventType == RequestHandler.Events.None.Key then
		return false
	end
	RequestHandler.Requests[request.GUID] = request
	return true
end

--- Removes a IRequest from the requests queue; returns true if successful
---@param requestGUID string IRequest.GUID
---@return boolean success
function RequestHandler.removeRequest(requestGUID)
	if not RequestHandler.Requests[requestGUID] then
		return false
	end
	RequestHandler.Requests[requestGUID] = nil
	return true
end

--- Adds a IResponse to the responses list, or updates an existing matching response; returns true if successful
---@param response table IResponse object
---@return boolean success
function RequestHandler.addUpdateResponse(response)
	RequestHandler.Responses[response.GUID] = response
	return true
end

--- Adds an IEvent to the events list; returns true if successful
---@param event table IEvent object (requires: Key, Process, Fulfill)
---@return boolean success
function RequestHandler.addNewEvent(event)
	-- Only add new, properly structured  events
	if RequestHandler.Events[event.Key] then
		return false
	end
	if type(event.Process) ~= "function" or type(event.Fulfill) ~= "function" then
		return false
	end
	RequestHandler.Events[event.Key] = event
	RequestHandler.loadEventSettings(event)
	return true
end

--- Removes an IEvent from the events list; returns true if successful
---@param eventKey string IEvent.KEY
---@return boolean success
function RequestHandler.removeEvent(eventKey)
	if not RequestHandler.Events[eventKey] then
		return false
	end
	RequestHandler.Events[eventKey] = nil
	return true
end

---Removes any existing requests that shouldn't be in the queue, usually a stop connection request immediately after starting up
function RequestHandler.removeServerSideRequests()
	local toRemove = {}
	for _, request in pairs(RequestHandler.Requests or {}) do
		local event = RequestHandler.Events[request.EventType] or RequestHandler.Events.None
		if event.Exclude then
			table.insert(toRemove, request)
		end
	end
	for _, request in pairs(toRemove) do
		RequestHandler.removeRequest(request.GUID)
	end
end

---Receives requests as json and converts them into IRequests
---@param jsonTable table|nil
function RequestHandler.receiveJsonRequests(jsonTable)
	for _, request in pairs(jsonTable or {}) do
		-- Update the event type if auto-detect required
		if request.EventType == RequestHandler.AUTO_DETECT_COMMAND then
			local event = RequestHandler.getEventForCommand(request.Args.Command)
			request.EventType = event and event.Key or request.EventType
		end
		-- Then add to the Requests queue
		RequestHandler.addNewRequest(RequestHandler.IRequest:new({
			GUID = request.GUID,
			EventType = request.EventType,
			CreatedAt = request.CreatedAt,
			Username = request.Username,
			Args = request.Args,
		}))
	end
end

---Returns the IEvent for a given command; or nil if not found
---@param command string Example: !testcommand
---@return table|nil event
function RequestHandler.getEventForCommand(command)
	if not command or command == "" then
		return nil
	end
	if command:sub(1,1) ~= RequestHandler.COMMAND_PREFIX then
		command = RequestHandler.COMMAND_PREFIX .. command
	end
	command = Utils.toLowerUTF8(command)
	for _, event in pairs(RequestHandler.Events) do
		if event.Command and event.Command == command then
			return event
		end
	end
end

--- Processes all IRequests (if able), adding them to the Responses
function RequestHandler.processAllRequests()
	-- Filter out unknown requests
	local toProcess, toRemove = {}, {}
	for _, request in pairs(RequestHandler.Requests) do
		local event = RequestHandler.Events[request.EventType] or RequestHandler.Events.None
		if event ~= RequestHandler.Events.None then
			table.insert(toProcess, request)
		else
			RequestHandler.addUpdateResponse(RequestHandler.IResponse:new({
				GUID = request.GUID,
				EventType = request.EventType,
				StatusCode = RequestHandler.StatusCodes.NOT_FOUND,
			}))
			table.insert(toRemove, request)
		end
	end

	-- TODO: Implement better, dont process if something ahead of it in queue of same event type (if that matters), somehow avoid duplicate requests
	table.sort(toProcess, function(a,b) return a.CreatedAt < b.CreatedAt end)

	for i, request in ipairs(toProcess) do
		local event = RequestHandler.Events[request.EventType]
		local response = RequestHandler.IResponse:new({
			GUID = request.GUID,
			EventType = request.EventType,
			StatusCode = RequestHandler.StatusCodes.FAIL,
		})
		if not event.IsEnabled then
			response.StatusCode = RequestHandler.StatusCodes.UNAVAILABLE
		elseif type(event.Process) == "function" and type(event.Fulfill) == "function" then
			response.StatusCode = RequestHandler.StatusCodes.PROCESSING
			if request.IsReady or event:Process(request) then
				-- TODO: Check if the request is a recent duplicate: StatusCodes.ALREADY_REPORTED
				response.StatusCode = RequestHandler.StatusCodes.SUCCESS
				response.Message = event:Fulfill(request)
				request.SentResponse = false
			end
		end
		if not request.SentResponse then
			RequestHandler.addUpdateResponse(response)
			request.SentResponse = true
		end
		if response.StatusCode ~= RequestHandler.StatusCodes.PROCESSING then
			table.insert(toRemove, request)
		end
	end

	for _, request in pairs(toRemove) do
		RequestHandler.removeRequest(request.GUID)
	end
end

---Returns a list of IResponses
---@return table responses
function RequestHandler.getResponses()
	local responses = {}
	for _, response in pairs(RequestHandler.Responses) do
		table.insert(responses, response)
	end
	return responses
end

function RequestHandler.clearResponses()
	RequestHandler.Responses = {}
end

--- If enough time has elapsed since the last auto-save, will save the Requests data
function RequestHandler.saveRequestsDataOnSchedule()
	if (os.time() - RequestHandler.lastSaveTime) >= RequestHandler.SAVE_FREQUENCY then
		RequestHandler.saveRequestsData()
	end
end

--- Returns a list of IRequests from a data file
---@return boolean success
function RequestHandler.loadRequestsData()
	local requests = FileManager.decodeJsonFile(FileManager.Files.REQUESTS_DATA)
	if requests then
		RequestHandler.Requests = requests
		return true
	else
		return false
	end
end

--- Saves the list of Requests to a data file
---@return boolean success
function RequestHandler.saveRequestsData()
	RequestHandler.removeServerSideRequests()
	local success = FileManager.encodeToJsonFile(FileManager.Files.REQUESTS_DATA, RequestHandler.Requests)
	RequestHandler.lastSaveTime = os.time()
	return (success == true)
end

---Saves a configurable settings attribute for an event to the Settings.ini file
---@param event table IEvent
---@param attribute string The IEvent attribute being saved
function RequestHandler.saveEventSetting(event, attribute)
	if not event or not event.Key or not attribute then
		return
	end
	local defaultEvent = RequestHandler.DefaultEvents[event.Key] or {}
	local key = string.format(RequestHandler.EVENT_SETTINGS_FORMAT, event.Key, attribute)
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
function RequestHandler.loadEventSettings(event)
	if not event or not event.Key then
		return false
	end
	local anyLoaded = false
	for attribute, existingValue in pairs(event) do
		local key = string.format(RequestHandler.EVENT_SETTINGS_FORMAT, event.Key, attribute)
		local value = Main.MetaSettings.network[key]
		if value ~= nil and value ~= existingValue then
			event[attribute] = value
			anyLoaded = true
		end
	end
	event.ConfigurationUpdated = anyLoaded or nil
end

function RequestHandler.checkForConfigChanges()
	local modifiedEvents = {}
	for _, event in pairs(RequestHandler.Events) do
		if event.ConfigurationUpdated then
			table.insert(modifiedEvents, event)
			event.ConfigurationUpdated = nil
		end
	end
	if #modifiedEvents > 0 then
		RequestHandler.addNewRequest(RequestHandler.IRequest:new({
			EventType = RequestHandler.Events["TS_UpdateEvents"].Key,
			Args = modifiedEvents
		}))
	end
end

function RequestHandler.addDefaultEvents()
	-- TS_: Tracker Server (Core events that shouldn't be modified)
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "TS_Start",
		Exclude = true,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "TS_UpdateEvents",
		Exclude = true,
		Fulfill = function(self, request)
			-- TODO: Don't have a good way to send back all of the changed event information. Unsure if embedded JSON is allowed
			return "Server events were updated but their information isn't available. Reason: not implemented."
		end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "TS_Stop",
		Exclude = true,
	}))

	-- Make a copy of each default event, such that they can still be referenced without being changed.
	for key, event in pairs(RequestHandler.DefaultEvents) do
		event.IsEnabled = true
		local eventToAdd = RequestHandler.IEvent:new({
			Key = key,
			Process = event.Process,
			Fulfill = event.Fulfill,
		})
		if event.Command then
			eventToAdd.Command = event.Command
			eventToAdd.Help = event.Help
			eventToAdd.Roles = {}
			FileManager.copyTable(event.Roles, eventToAdd.Roles)
		elseif event.Reward then -- TODO: Implement
		end
		RequestHandler.addNewEvent(eventToAdd)
	end
end

RequestHandler.DefaultEvents = {
	-- CMD_: Chat Commands
	-- CMD_AutoDetect = {}, -- Reserved interally, do not define this event
	CMD_Pokemon = {
		Command = "!pokemon",
		Help = "name > Displays useful game info for a Pokémon.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.Args) end,
	},
	CMD_BST = {
		Command = "!bst",
		Help = "name > Displays the base stat total (BST) for a Pokémon.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.Args) end,
	},
	CMD_Weak = {
		Command = "!weak",
		Help = "name > Displays the weaknesses for a Pokémon.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.Args) end,
	},
	CMD_Move = {
		Command = "!move",
		Help = "name > Displays game info for a move.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.Args) end,
	},
	CMD_Ability = {
		Command = "!ability",
		Help = "name > Displays game info for a Pokémon's ability.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.Args) end,
	},
	CMD_Route = {
		Command = "!route",
		Help = "name > Displays trainer and wild encounter info for a route or area.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.Args) end,
	},
	CMD_Dungeon = {
		Command = "!dungeon",
		Help = "name > Displays info about which trainers have been defeated for an area.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.Args) end,
	},
	CMD_Pivots = {
		Command = "!pivots",
		Help = "name > Displays known early game wild encounters for an area.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.Args) end,
	},
	CMD_Revo = {
		Command = "!revo",
		Help = "name [target-evo] > Displays randomized evolution possibilities for a Pokémon, and it's [target-evo] if more than one available.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.Args) end,
	},
	CMD_Coverage = {
		Command = "!coverage",
		Help = "types [fully evolved] > For a list of move types, checks all Pokémon matchups (or only [fully evolved]) for effectiveness.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.Args) end,
	},
	CMD_Heals = {
		Command = "!heals",
		Help = "[hp pp status berries] > Displays all healing items in the bag, or only those for a specified [category].",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getHeals(request.Args) end,
	},
	CMD_TMs = {
		Command = "!tms",
		Help = "[gym hm #] > Displays all TMs in the bag, or only those for a specified [category] or TM #.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getTMsHMs(request.Args) end,
	},
	CMD_Search = {
		Command = "!search",
		Help = "[mode] [terms] > Search for a [Pokémon/Move/Ability/Note] followed by the search [terms].",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearch(request.Args) end,
	},
	CMD_Theme = {
		Command = "!theme",
		Help = "> Displays the name and code string for the current Tracker theme.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getTheme(request.Args) end,
	},
	CMD_GameStats = {
		Command = "!gamestats",
		Help = "> Displays fun stats for the current game.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getGameStats(request.Args) end,
	},
	CMD_Progress = {
		Command = "!progress",
		Help = "> Displays fun progress percentages for the current game.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getProgress(request.Args) end,
	},
	CMD_Log = {
		Command = "!log",
		Help = "> If the log has been opened, displays shareable randomizer settings from the log for current game.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getLog(request.Args) end,
	},
	CMD_About = {
		Command = "!about",
		Help = "> Displays info about the Ironmon Tracker and game being played.",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbout(request.Args) end,
	},
	CMD_Help = {
		Command = "!help",
		Help = "[command] > Displays a list of all commands, or help info for a specified [command].",
		Roles = { RequestHandler.EventRoles.Everyone, },
		Fulfill = function(self, request) return DataHelper.EventRequests.getHelp(request.Args) end,
	},

	-- CR_: Channel Rewards (Point Redeems)
	CR_PickBallOnce = {
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_PickBallUntilOut = {
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_ChangeFavorite = {
		Duration = 10 * 60,
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_ChangeTheme = {
		Duration = 10 * 60,
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
	CR_ChangeLanguage = {
		Duration = 10 * 60,
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	},
}

-- Request/Response/Event object prototypes

RequestHandler.IRequest = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventType = RequestHandler.Events.None.Key,
	-- Number of seconds, representing time the originating request was created
	CreatedAt = -1,
	-- A Request should always send a response (at least once) when received
	SentResponse = false,
	-- If the request is ready to fulfill
	IsReady = false,
	-- Username of the user creating the request
	Username = "",
	-- Optional arguments included with the request
	Args = {},
}
function RequestHandler.IRequest:new(o)
	o = o or {}
	o.GUID = o.GUID or Utils.newGUID()
	o.EventType = o.EventType or RequestHandler.Events.None.Key
	o.CreatedAt = o.CreatedAt or os.time()
	setmetatable(o, self)
	self.__index = self
	return o
end

RequestHandler.IResponse = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventType = RequestHandler.Events.None.Key,
	-- Number of seconds, representing time the request was processed into a response
	CreatedAt = -1,
	StatusCode = RequestHandler.StatusCodes.NOT_FOUND,
	-- The informative response message to send back to the client
	Message = "",
}
function RequestHandler.IResponse:new(o)
	o = o or {}
	o.GUID = o.GUID or Utils.newGUID()
	o.CreatedAt = o.CreatedAt or os.time()
	o.StatusCode = o.StatusCode or RequestHandler.StatusCodes.NOT_FOUND
	o.Message = o.Message or ""
	setmetatable(o, self)
	self.__index = self
	return o
end

RequestHandler.IEvent = {
	-- Required unique key
	Key = RequestHandler.Events.None.Key,
	-- Enable/Disable from triggering
	IsEnabled = true,
	-- Determine what to do with the IRequest, return true if ready to fulfill (IRequest.IsReady = true)
	Process = function(self, request) return true end,
	-- Only after fully processed and ready, finish completing the request and return a response message
	Fulfill = function(self, request) return "" end,
}
function RequestHandler.IEvent:new(o)
	o = o or {}
	o.Key = o.Key or RequestHandler.Events.None.Key
	o.IsEnabled = o.IsEnabled ~= nil and o.IsEnabled or true
	setmetatable(o, self)
	self.__index = self
	return o
end
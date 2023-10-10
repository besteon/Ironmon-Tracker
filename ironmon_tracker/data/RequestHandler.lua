RequestHandler = {
	Requests = {}, -- A list of all known requests that still need to be processed
	Responses = {}, -- A list of all responses ready to be sent
	lastSaveTime = 0,
	SAVE_FREQUENCY = 60, -- Number of seconds to wait before saving Requests data to file
}

-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
RequestHandler.StatusCodes = {
	PROCESSING = 102, -- The server (Tracker) has received and is processing the request, but no response is available yet
	SUCCESS = 200, -- The request succeeded and a response message is available
	ALREADY_REPORTED = 208, -- The request is a duplicate of another recent request, no additional response message will be sent
	FAIL = 400, -- The server (Tracker) won't process, likely due to a client error with formatting the request
	NOT_FOUND = 404, -- The server (Tracker) cannot find the requested resource or event
}

RequestHandler.Events = {
	None = { Key = "None" },
}

function RequestHandler.initialize()
	RequestHandler.Requests = {}
	RequestHandler.Responses = {}
	RequestHandler.lastSaveTime = os.time()
	RequestHandler.loadCoreEvents()
	RequestHandler.loadData()
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

	for _, request in ipairs(toProcess) do
		local event = RequestHandler.Events[request.EventType]
		local response = RequestHandler.IResponse:new({
			GUID = request.GUID,
			EventType = request.EventType,
			StatusCode = RequestHandler.StatusCodes.FAIL,
			Message = ""
		})
		-- Only process properly formatted events
		if type(event.Process) == "function" and type(event.Fulfill) == "function" then
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
function RequestHandler.trySaveData()
	if (os.time() - RequestHandler.lastSaveTime) >= RequestHandler.SAVE_FREQUENCY then
		RequestHandler.saveData()
		RequestHandler.lastSaveTime = os.time()
	end
end

--- Returns a list of IRequests from a data file
---@return boolean success
function RequestHandler.loadData()
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
function RequestHandler.saveData()
	local success = FileManager.encodeToJsonFile(FileManager.Files.REQUESTS_DATA, RequestHandler.Requests)
	return (success == true)
end

function RequestHandler.loadCoreEvents()
	-- TODO: Need a communication event to occur after load to inform the client of changes to events

	-- CMD_: Chat Commands
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Pokemon",
		Command = "!pokemon",
		Help = "name > Displays useful game info for a Pokémon.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_BST",
		Command = "!bst",
		Help = "name > Displays the base stat total (BST) for a Pokémon.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Weak",
		Command = "!weak",
		Help = "name > Displays the weaknesses for a Pokémon.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Move",
		Command = "!move",
		Help = "name > Displays game info for a move.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Ability",
		Command = "!ability",
		Help = "name > Displays game info for a Pokémon's ability.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Route",
		Command = "!route",
		Help = "name > Displays trainer and wild encounter info for a route or area.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Dungeon",
		Command = "!dungeon",
		Help = "name > Displays info about which trainers have been defeated for an area.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Pivots",
		Command = "!pivots",
		Help = "name > Displays known early game wild encounters for an area.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Revo",
		Command = "!revo",
		Help = "name [target-evo] > Displays randomized evolution possibilities for a Pokémon, and it's [target-evo] if more than one available.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Coverage",
		Command = "!coverage",
		Help = "types [fully evolved] > For a list of move types, checks all Pokémon matchups (or only [fully evolved]) for effectiveness.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Heals",
		Command = "!heals",
		Help = "[hp pp status berries] > Displays all healing items in the bag, or only those for a specified [category].",
		Fulfill = function(self, request) return DataHelper.EventRequests.getHeals(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_TMs",
		Command = "!tms",
		Help = "[gym hm #] > Displays all TMs in the bag, or only those for a specified [category] or TM #.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getTMsHMs(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Search",
		Command = "!search",
		Help = "[mode] [terms] > Search for a [Pokémon/Move/Ability/Note] followed by the search [terms].",
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearch(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Theme",
		Command = "!theme",
		Help = "> Displays the name and code string for the current Tracker theme.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getTheme(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_GameStats",
		Command = "!gamestats",
		Help = "> Displays fun stats for the current game.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getGameStats(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Progress",
		Command = "!progress",
		Help = "> Displays fun progress percentages for current game.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getProgress(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Log",
		Command = "!log",
		Help = "> If the log has been opened, displays shareable randomizer settings from the log for current game.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getLog(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_About",
		Command = "!about",
		Help = "> Displays info about the Ironmon Tracker and game being played.",
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbout(request.Args) end,
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CMD_Help",
		Command = "!help",
		Help = "[command] > Displays a list of all commands, or help info for a specified [command].",
		Fulfill = function(self, request) return DataHelper.EventRequests.getHelp(request.Args) end,
	}))

	-- CR_: Channel Rewards (Point Redeems)
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CR_PickBallOnce",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CR_PickBallUntilOut",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CR_ChangeFavorite",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CR_ChangeTheme",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestHandler.addNewEvent(RequestHandler.IEvent:new({
		Key = "CR_ChangeLanguage",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
end

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
	-- Optional arguments passed with the request
	Args = {},
}
function RequestHandler.IRequest:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	if o.GUID == "" then
		o.GUID = Utils.newGUID()
	end
	if o.CreatedAt == -1 then
		o.CreatedAt = os.time()
	end
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
	setmetatable(o, self)
	self.__index = self
	if o.GUID == "" then
		o.GUID = Utils.newGUID()
	end
	if o.CreatedAt == -1 then
		o.CreatedAt = os.time()
	end
	return o
end

RequestHandler.IEvent = {
	-- Required unique key
	Key = RequestHandler.Events.None.Key,
	-- Determine what to do with the IRequest, return true if ready to fulfill (IRequest.IsReady = true)
	Process = function(self, request) return true end,
	-- Only after fully processed and ready, finish completing the request and return a response message
	Fulfill = function(self, request) return "" end,
}
function RequestHandler.IEvent:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
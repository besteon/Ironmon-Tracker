RequestsHandler = {
	Requests = {}, -- A list of all known requests that still need to be processed
	Responses = {}, -- A list of all responses ready to be sent
	lastSaveTime = 0,
	SAVE_FREQUENCY = 60, -- Number of seconds to wait before saving Requests data to file
}

-- https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
RequestsHandler.StatusCodes = {
	PROCESSING = 102, -- The server (Tracker) has received and is processing the request, but no response is available yet
	SUCCESS = 200, -- The request succeeded and a response message is available
	ALREADY_REPORTED = 208, -- The request is a duplicate of another recent request, no additional response message will be sent
	FAIL = 400, -- The server (Tracker) won't process, likely due to a client error with formatting the request
	NOT_FOUND = 404, -- The server (Tracker) cannot find the requested resource or event
}

RequestsHandler.Events = {
	None = { Key = "None" },
}

function RequestsHandler.initialize()
	RequestsHandler.Requests = {}
	RequestsHandler.Responses = {}
	RequestsHandler.lastSaveTime = os.time()
	RequestsHandler.loadCoreEvents()
	RequestsHandler.loadData()
end

--- Adds a IRequest to the requests queue; returns true if successful
---@param request table IRequest object
---@return boolean success
function RequestsHandler.addNewRequest(request)
	-- Only add requests if they're new and match an existing event type
	if RequestsHandler.Requests[request.GUID] or request.EventType == RequestsHandler.Events.None.Key then
		return false
	end
	RequestsHandler.Requests[request.GUID] = request
	return true
end

--- Removes a IRequest from the requests queue; returns true if successful
---@param requestGUID string IRequest.GUID
---@return boolean success
function RequestsHandler.removeRequest(requestGUID)
	if not RequestsHandler.Requests[requestGUID] then
		return false
	end
	RequestsHandler.Requests[requestGUID] = nil
	return true
end

--- Adds a IResponse to the responses list, or updates an existing matching response; returns true if successful
---@param response table IResponse object
---@return boolean success
function RequestsHandler.addUpdateResponse(response)
	RequestsHandler.Responses[response.GUID] = response
	return true
end

--- Adds an IEvent to the events list; returns true if successful
---@param event table IEvent object (requires: Key, Process, Fulfill)
---@return boolean success
function RequestsHandler.addNewEvent(event)
	-- Only add new, properly structured  events
	if RequestsHandler.Events[event.Key] then
		return false
	end
	if type(event.Process) ~= "function" or type(event.Fulfill) ~= "function" then
		return false
	end
	RequestsHandler.Events[event.Key] = event
	return true
end

--- Removes an IEvent from the events list; returns true if successful
---@param eventKey string IEvent.KEY
---@return boolean success
function RequestsHandler.removeEvent(eventKey)
	if not RequestsHandler.Events[eventKey] then
		return false
	end
	RequestsHandler.Events[eventKey] = nil
	return true
end

--- Processes all IRequests (if able), adding them to the RequestsHandler.Responses
function RequestsHandler.processAllRequests()
	-- Filter out unknown requests
	local toProcess, toRemove = {}, {}
	for _, request in pairs(RequestsHandler.Requests) do
		local event = RequestsHandler.Events[request.EventType] or RequestsHandler.Events.None
		if event ~= RequestsHandler.Events.None then
			table.insert(toProcess, request)
		else
			RequestsHandler.addUpdateResponse(RequestsHandler.IResponse:new({
				GUID = request.GUID,
				EventType = request.EventType,
				StatusCode = RequestsHandler.StatusCodes.NOT_FOUND,
			}))
			table.insert(toRemove, request)
		end
	end

	-- TODO: Implement better, dont process if something ahead of it in queue of same event type (if that matters), somehow avoid duplicate requests
	table.sort(toProcess, function(a,b) return a.CreatedAt < b.CreatedAt end)

	for _, request in ipairs(toProcess) do
		local event = RequestsHandler.Events[request.EventType]
		local response = RequestsHandler.IResponse:new({
			GUID = request.GUID,
			EventType = request.EventType,
			StatusCode = RequestsHandler.StatusCodes.FAIL,
			Message = ""
		})
		-- Only process properly formatted events
		if type(event.Process) == "function" and type(event.Fulfill) == "function" then
			response.StatusCode = RequestsHandler.StatusCodes.PROCESSING
			if request.IsReady or event:Process(request) then
				-- TODO: Check if the request is a recent duplicate: StatusCodes.ALREADY_REPORTED
				response.StatusCode = RequestsHandler.StatusCodes.SUCCESS
				response.Message = event:Fulfill(request)
				request.SentResponse = false
			end
		end
		if not request.SentResponse then
			RequestsHandler.addUpdateResponse(response)
			request.SentResponse = true
		end
		if response.StatusCode ~= RequestsHandler.StatusCodes.PROCESSING then
			table.insert(toRemove, request)
		end
	end

	for _, request in pairs(toRemove) do
		RequestsHandler.removeRequest(request.GUID)
	end
end

---Returns a list of IResponses
---@return table responses
function RequestsHandler.getResponses()
	local responses = {}
	for _, response in pairs(RequestsHandler.Responses) do
		table.insert(responses, response)
	end
	return responses
end

function RequestsHandler.clearResponses()
	RequestsHandler.Responses = {}
end

--- If enough time has elapsed since the last auto-save, will save the Requests data
function RequestsHandler.trySaveData()
	if (os.time() - RequestsHandler.lastSaveTime) >= RequestsHandler.SAVE_FREQUENCY then
		RequestsHandler.saveData()
		RequestsHandler.lastSaveTime = os.time()
	end
end

--- Returns a list of IRequests from a data file
---@return boolean success
function RequestsHandler.loadData()
	local requests = FileManager.decodeJsonFile(FileManager.Files.REQUESTS_DATA)
	if requests then
		RequestsHandler.Requests = requests
		return true
	else
		return false
	end
end

--- Saves the list of RequestsHandler.Requests to a data file
---@return boolean success
function RequestsHandler.saveData()
	local success = FileManager.encodeToJsonFile(FileManager.Files.REQUESTS_DATA, RequestsHandler.Requests)
	return (success == true)
end

function RequestsHandler.loadCoreEvents()
	-- TODO: Need a communication event to occur afterwards to inform the client of changes to events

	-- CMD_: Chat Commands
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Pokemon",
		Command = "!pokemon",
		Fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_BST",
		Command = "!bst",
		Fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Weak",
		Command = "!weak",
		Fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Move",
		Command = "!move",
		Fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Ability",
		Command = "!ability",
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Route",
		Command = "!route",
		Fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Dungeon",
		Command = "!dungeon",
		Fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Pivots",
		Command = "!pivots",
		Fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Revo",
		Command = "!revo",
		Fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Coverage",
		Command = "!coverage",
		Fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Notes",
		Command = "!notes",
		Fulfill = function(self, request) return DataHelper.EventRequests.getNotes(request.Args) end,
	}))

	-- TODO: Still need to map this properly
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Heals",
		Command = "!heals",
		Fulfill = function(self, request) return DataHelper.EventRequests.getHeals(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_TMs",
		Command = "!tms",
		Fulfill = function(self, request) return DataHelper.EventRequests.getTMs(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_SearchNotes",
		Command = "!searchnotes",
		-- TODO: Implement this from scratch; should replace !notes
		Fulfill = function(self, request) return DataHelper.EventRequests.getSearchNotes(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Theme",
		Command = "!theme",
		-- TODO: Implement this from scratch
		Fulfill = function(self, request) return DataHelper.EventRequests.getTheme(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_GameStats",
		Command = "!gamestats",
		Fulfill = function(self, request) return DataHelper.EventRequests.getGameStats(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Progress",
		Command = "!progress",
		Fulfill = function(self, request) return DataHelper.EventRequests.getProgress(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Log",
		Command = "!log",
		Fulfill = function(self, request) return DataHelper.EventRequests.getLog(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_About",
		Command = "!about",
		Fulfill = function(self, request) return DataHelper.EventRequests.getAbout(request.Args) end,
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CMD_Help",
		Command = "!help",
		Fulfill = function(self, request) return DataHelper.EventRequests.getHelp(request.Args) end,
	}))

	-- CR_: Channel Rewards (Point Redeems)
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CR_PickBallOnce",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CR_PickBallUntilOut",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CR_ChangeFavorite",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CR_ChangeTheme",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
	RequestsHandler.addNewEvent(RequestsHandler.IEvent:new({
		Key = "CR_ChangeLanguage",
		Process = function(self, request) -- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		Fulfill = function(self, request) return "" end, -- TODO: build a response to send
	}))
end

-- Request/Response/Event object prototypes

RequestsHandler.IRequest = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventType = RequestsHandler.Events.None.Key,
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
function RequestsHandler.IRequest:new(o)
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

RequestsHandler.IResponse = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventType = RequestsHandler.Events.None.Key,
	-- Number of seconds, representing time the request was processed into a response
	CreatedAt = -1,
	StatusCode = RequestsHandler.StatusCodes.NOT_FOUND,
	-- The informative response message to send back to the client
	Message = "",
}
function RequestsHandler.IResponse:new(o)
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

RequestsHandler.IEvent = {
	-- Required unique key
	Key = RequestsHandler.Events.None.Key,
	-- Determine what to do with the IRequest, return true if ready to fulfill (IRequest.IsReady = true)
	Process = function(self, request) return true end,
	-- Only after fully processed and ready, finish completing the request and return a response message
	Fulfill = function(self, request) return "" end,
}
function RequestsHandler.IEvent:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
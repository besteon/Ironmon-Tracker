RequestsManager = {
	Requests = {}, -- A list of all known requests that still need to be processed
	Responses = {}, -- A list of all responses ready to be sent
	lastSaveTime = 0,
	SAVE_FREQUENCY = 60, -- Number of seconds to wait before saving Requests data to file
}

RequestsManager.StatusCodes = {
	PROCESSING = 102, -- The server (Tracker) has received and is processing the request, but no response is available yet
	SUCCESS = 200, -- The request succeeded and a response message is available
	FAIL = 400, -- The server (Tracker) won't process, likely due to a client error with formatting the request
	NOT_FOUND = 404, -- The server (Tracker) cannot find the requested resource or event
}

function RequestsManager.initialize()
	RequestsManager.Requests = {}
	RequestsManager.Responses = {}
	RequestsManager.lastSaveTime = os.time()
	RequestsManager.loadData()
end

--- Adds an IRequest to the requests queue; returns true if successful
---@param request table IRequest object
---@return boolean success
function RequestsManager.addNewRequest(request)
	-- Only add *new* requests with known event categories and types
	if RequestsManager.Requests[request.GUID] or request.EventType == RequestsManager.Events.None.key then
		return false
	end
	RequestsManager.Requests[request.GUID] = request
	return true
end

--- Adds an IResponse to the responses list, or updates an existing matching response; returns true if successful
---@param response table IResponse object
---@return boolean success
function RequestsManager.addUpdateResponse(response)
	RequestsManager.Responses[response.GUID] = response
	return true
end

--- Processes all IRequests (if able), adding them to the RequestsManager.Responses
function RequestsManager.processAllRequests()
	-- Filter out unknown requests
	local requestsToProcess = {}
	for _, request in pairs(RequestsManager.Requests) do
		local event = RequestsManager.Events[request.EventType] or RequestsManager.Events.None
		if event ~= RequestsManager.Events.None then
			table.insert(requestsToProcess, request)
		else
			RequestsManager.addUpdateResponse(RequestsManager.IResponse:new({
				GUID = request.GUID,
				EventType = request.EventType,
				StatusCode = RequestsManager.StatusCodes.NOT_FOUND,
			}))
		end
	end

	-- TODO: Implement better, dont process if something ahead of it in queue of same event type (if that matters), somehow avoid duplicate requests
	table.sort(requestsToProcess, function(a,b) return a.CreatedAt < b.CreatedAt end)

	for _, request in ipairs(requestsToProcess) do
		local event = RequestsManager.Events[request.EventType]
		local response = RequestsManager.IResponse:new({
			GUID = request.GUID,
			EventType = request.EventType,
			StatusCode = RequestsManager.StatusCodes.FAIL,
			Message = ""
		})
		-- Only process properly formatted events
		if type(event.process) == "function" and type(event.fulfill) == "function" then
			response.StatusCode = RequestsManager.StatusCodes.PROCESSING
			if request.IsReady or event:process(request) then
				response.StatusCode = RequestsManager.StatusCodes.SUCCESS
				response.Message = event:fulfill(request)
			end
		end
		RequestsManager.addUpdateResponse(response)
	end
end

---Returns a list of IResponses
---@return table responses
function RequestsManager.getResponses()
	local responses = {}
	for _, response in pairs(RequestsManager.Responses) do
		table.insert(responses, response)
	end
	return responses
end

function RequestsManager.clearResponses()
	RequestsManager.Responses = {}
end

--- If enough time has elapsed since the last auto-save, will save the Requests data
function RequestsManager.trySaveData()
	if (os.time() - RequestsManager.lastSaveTime) >= RequestsManager.SAVE_FREQUENCY then
		RequestsManager.saveData()
		RequestsManager.lastSaveTime = os.time()
	end
end

--- Returns a list of IRequests from a data file
---@return boolean success
function RequestsManager.loadData()
	local requests = FileManager.decodeJsonFile(FileManager.Files.REQUESTS_DATA)
	if requests then
		RequestsManager.Requests = requests
		return true
	else
		return false
	end
end

--- Saves the list of RequestsManager.Requests to a data file
---@return boolean success
function RequestsManager.saveData()
	local success = FileManager.encodeToJsonFile(FileManager.Files.REQUESTS_DATA, RequestsManager.Requests)
	return (success == true)
end

-- TODO: Each individual event likely has other conditions about when it can be processed or fulfilled
--- CR: Channel Rewards (Point Redeems), CMD: Channel Commands (!test)
--- process: Determine what to do with the IRequest, return true if ready to fulfill (IRequest.IsReady = true)
--- fulfill: Only after fully processed and ready, finish completing the request and return a response message
RequestsManager.Events = {
	CR_PickBallOnce = {
		process = function(self, request)
			request.IsReady = false
			-- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		fulfill = function(self, request)
			return ""
		end,
	},
	CR_PickBallUntilOut = {
		process = function(self, request)
			request.IsReady = false
			-- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		fulfill = function(self, request)
			return ""
		end,
	},
	CR_ChangeTheme = {
		process = function(self, request)
			request.IsReady = false
			-- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		fulfill = function(self, request)
			return ""
		end,
	},
	CR_ChangeFavorite = {
		process = function(self, request)
			request.IsReady = false
			-- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		fulfill = function(self, request)
			return "" -- TODO: Requirements implementation from scratch
		end,
	},
	CR_ChangeLanguage = {
		process = function(self, request)
			request.IsReady = false
			-- TODO: insert into Tracker code where it needs to be
			return request.IsReady
		end,
		fulfill = function(self, request)
			return "" -- TODO: Requirements implementation from scratch
		end,
	},
	CMD_Pokemon = {
		fulfill = function(self, request) return DataHelper.EventRequests.getPokemon(request.Args) end,
	},
	CMD_BST = {
		fulfill = function(self, request) return DataHelper.EventRequests.getBST(request.Args) end,
	},
	CMD_Weak = {
		fulfill = function(self, request) return DataHelper.EventRequests.getWeak(request.Args) end,
	},
	CMD_Move = {
		fulfill = function(self, request) return DataHelper.EventRequests.getMove(request.Args) end,
	},
	CMD_Ability = {
		fulfill = function(self, request) return DataHelper.EventRequests.getAbility(request.Args) end,
	},
	CMD_Route = {
		fulfill = function(self, request) return DataHelper.EventRequests.getRoute(request.Args) end,
	},
	CMD_Dungeon = {
		fulfill = function(self, request) return DataHelper.EventRequests.getDungeon(request.Args) end,
	},
	CMD_Pivots = {
		fulfill = function(self, request) return DataHelper.EventRequests.getPivots(request.Args) end,
	},
	CMD_Revo = {
		fulfill = function(self, request) return DataHelper.EventRequests.getRevo(request.Args) end,
	},
	CMD_Coverage = {
		fulfill = function(self, request) return DataHelper.EventRequests.getCoverage(request.Args) end,
	},
	CMD_Notes = {
		fulfill = function(self, request) return DataHelper.EventRequests.getNotes(request.Args) end,
	},
	CMD_Heals = {
		fulfill = function(self, request) return nil end,
	},
	CMD_TMs = {
		fulfill = function(self, request) return nil end,
	},
	CMD_MonsWithMove = {
		fulfill = function(self, request) return nil end,
	},
	CMD_MonsWithAbility = {
		fulfill = function(self, request) return nil end,
	},
	CMD_Theme = {
		fulfill = function(self, request) return nil end, -- TODO: Implement this from scratch
	},
	CMD_GameStats = {
		fulfill = function(self, request) return nil end,
	},
	CMD_Progress = {
		fulfill = function(self, request) return nil end,
	},
	CMD_Log = {
		fulfill = function(self, request) return nil end,
	},
	CMD_About = {
		fulfill = function(self, request) return nil end,
	},
	CMD_Help = {
		fulfill = function(self, request) return nil end,
	},
	None = {},
}
for key, val in pairs(RequestsManager.Events) do
	val.key = key
	-- By default, if nothing necessary to process then the Request is ready (true)
	if type(val.process) ~= "function" then
		val.process = function(self, request) return true end
	end
end

-- Request/Response object prototypes

RequestsManager.IRequest = {
	GUID = "",
	EventType = RequestsManager.Events.None.key,
	CreatedAt = -1, -- Number of seconds, representing time the originating request was created
	Username = "", -- Username of the user creating the request
	Args = {}, -- Optional arguments passed with the request
}
function RequestsManager.IRequest:new(o)
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

RequestsManager.IResponse = {
	GUID = "",
	EventType = RequestsManager.Events.None.key,
	CreatedAt = -1, -- Number of seconds, representing time the request was processed into a response
	StatusCode = RequestsManager.StatusCodes.NOT_FOUND,
	Message = "", -- The informative response message to send
}
function RequestsManager.IResponse:new(o)
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
RequestHandler = {
	Requests = {}, -- A list of all known requests that still need to be processed
	Responses = {}, -- A list of all responses ready to be sent
	lastSaveTime = 0,
	SAVE_FREQUENCY = 60, -- Number of seconds to wait before saving Requests data to file
	REQUIRES_MESSAGE_CAP = true, -- If true, shortens outgoing responses to message cap
	MESSAGE_CAP = 499, -- Maximum # of characters allow for a given response

	-- Shared values between server and client
	SOURCE_STREAMERBOT = "Streamerbot",
	REQUEST_COMPLETE = "Complete",
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

function RequestHandler.reset()
	RequestHandler.Requests = {}
	RequestHandler.Responses = {}
	RequestHandler.lastSaveTime = os.time()
end

--- Adds a IRequest to the requests queue, or updates an existing matching request; returns true if successful
---@param request table IRequest object
---@return boolean success
function RequestHandler.addUpdateRequest(request)
	-- Only add requests if they match an existing event type
	if not request or request.EventType == EventHandler.Events.None.Key then
		return false
	end
	if RequestHandler.Requests[request.GUID] then
		FileManager.copyTable(request, RequestHandler.Requests[request.GUID])
	else
		RequestHandler.Requests[request.GUID] = request
	end
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
	if not response then
		return false
	end
	if RequestHandler.Responses[response.GUID] then
		FileManager.copyTable(response, RequestHandler.Responses[response.GUID])
	else
		RequestHandler.Responses[response.GUID] = response
	end
	return true
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

---Removes all responses
function RequestHandler.clearResponses()
	RequestHandler.Responses = {}
end

---Removes any requests that should not be saved/loaded (e.g. core start and stop requests)
function RequestHandler.removedExcludedRequests()
	local toRemove = {}
	for _, request in pairs(RequestHandler.Requests or {}) do
		local event = EventHandler.Events[request.EventType] or EventHandler.Events.None
		if event.Exclude then
			table.insert(toRemove, request)
		end
	end
	for _, request in pairs(toRemove) do
		RequestHandler.removeRequest(request.GUID)
	end
end

---Receives [external] requests as Json and converts them into IRequests
---@param jsonTable table?
function RequestHandler.receiveJsonRequests(jsonTable)
	for _, request in pairs(jsonTable or {}) do
		-- If missing, try and automatically detect the event type based on provided args
		if not EventHandler.Events[request.EventType] then
			if request.Args.Command then
				local event = EventHandler.getEventForCommand(request.Args.Command)
				request.EventType = event and event.Key or request.EventType
			elseif request.Args.RewardId then
				local event = EventHandler.getEventForReward(request.Args.RewardId)
				request.EventType = event and event.Key or request.EventType
			end
		end
		-- Then add to the Requests queue
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			GUID = request.GUID,
			EventType = request.EventType,
			CreatedAt = request.CreatedAt,
			Username = request.Username,
			Args = request.Args,
		}))
	end
end

--- Processes all IRequests (if able), adding them to the Responses
function RequestHandler.processAllRequests()
	-- Filter out unknown requests
	local toProcess, toRemove = {}, {}
	for _, request in pairs(RequestHandler.Requests) do
		local event = EventHandler.Events[request.EventType] or EventHandler.Events.None
		if event ~= EventHandler.Events.None then
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
		local event = EventHandler.Events[request.EventType]
		local response = RequestHandler.IResponse:new({
			GUID = request.GUID,
			EventType = request.EventType,
			StatusCode = RequestHandler.StatusCodes.FAIL,
		})
		if not event.IsEnabled then
			response.StatusCode = RequestHandler.StatusCodes.UNAVAILABLE
		elseif request.IsCancelled then
			request.Message = "Cancelled."
			request.SentResponse = false
		elseif type(event.Process) == "function" and type(event.Fulfill) == "function" then
			response.StatusCode = RequestHandler.StatusCodes.PROCESSING
			if request.IsReady or event:Process(request) then
				-- TODO: Check if the request is a recent duplicate: StatusCodes.ALREADY_REPORTED
				response.StatusCode = RequestHandler.StatusCodes.SUCCESS
				response.Message = RequestHandler.validateMessage(event:Fulfill(request))
				request.SentResponse = false
			end
		end
		if not request.SentResponse then
			-- If this request is a channel point redeem, send back info to complete/cancel it
			if (event.RewardId or "") ~= "" then
				response.AdditionalInfo = response.AdditionalInfo or {}
				response.AdditionalInfo["RewardId"] = request.Args["RewardId"]
				response.AdditionalInfo["RedemptionId"] = request.Args["RedemptionId"]
			end
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

---Ensures the 'msg' is valid for sending (doesn't exceed the MESSAGE_CAP)
---@param msg string
---@return string
function RequestHandler.validateMessage(msg)
	msg = msg or ""
	if not RequestHandler.REQUIRES_MESSAGE_CAP or #msg <= RequestHandler.MESSAGE_CAP then
		return msg
	end
	return msg:sub(1, RequestHandler.MESSAGE_CAP - 4) .. "..."
end

--- Saves the list of Requests to a data file
---@return boolean success
function RequestHandler.saveRequestsData()
	RequestHandler.removedExcludedRequests()
	local success = FileManager.encodeToJsonFile(FileManager.Files.REQUESTS_DATA, RequestHandler.Requests)
	RequestHandler.lastSaveTime = os.time()
	return (success == true)
end

--- Imports a list of IRequests from a data file; returns true if successful
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

--- If enough time has elapsed since the last auto-save, will save the Requests data
function RequestHandler.saveRequestsDataOnSchedule()
	if (os.time() - RequestHandler.lastSaveTime) >= RequestHandler.SAVE_FREQUENCY then
		RequestHandler.saveRequestsData()
	end
end

-- Request/Response object prototypes

RequestHandler.IRequest = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventType = EventHandler.Events.None.Key,
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
	o.EventType = o.EventType or EventHandler.Events.None.Key
	o.CreatedAt = o.CreatedAt or os.time()
	setmetatable(o, self)
	self.__index = self
	return o
end

RequestHandler.IResponse = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventType = EventHandler.Events.None.Key,
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
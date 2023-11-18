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

---Clears out existing request info; similar to initialize(), but managed by Network
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
	if not request or request.EventKey == EventHandler.Events.None.Key then
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
function RequestHandler.clearAllResponses()
	RequestHandler.Responses = {}
end

---Removes any requests that should not be saved/loaded (e.g. core start and stop requests)
function RequestHandler.removedExcludedRequests()
	local toRemove = {}
	for _, request in pairs(RequestHandler.Requests or {}) do
		local event = EventHandler.Events[request.EventKey] or EventHandler.Events.None
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
		local eventKeys = {}

		-- If missing, try and automatically detect the event type based on provided args
		if not EventHandler.Events[request.EventKey] then
			if request.Args.Command then
				local events = EventHandler.getEventsForCommand(request.Args.Command)
				for _, event in pairs(events) do
					table.insert(eventKeys, event.Key)
				end
			elseif request.Args.RewardId then
				local events = EventHandler.getEventsForReward(request.Args.RewardId)
				for _, event in pairs(events) do
					table.insert(eventKeys, event.Key)
				end
			end
		end
		if #eventKeys == 0 then
			table.insert(eventKeys, request.EventKey)
		end

		-- Then add to the Requests queue
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			GUID = request.GUID,
			EventKey = table.concat(eventKeys, ","),
			CreatedAt = request.CreatedAt,
			Username = request.Username,
			Args = request.Args,
		}))
	end
end

---Checks if the request includes an input string, and if so get it ready to be processed
---@param request table IRequest object
---@return string sanitizedInput
function RequestHandler.sanitizeInput(request)
	if request.SanitizedInput then
		return request.SanitizedInput
	end
	if type(request.Args) == "table" and request.Args.Input ~= nil then
		local input = tostring(request.Args.Input)
		request.SanitizedInput = input:match("^%s*(.-)%s*$") or ""
	else
		request.SanitizedInput = ""
	end
	return request.SanitizedInput
end

--- Processes all IRequests (if able), adding them to the Responses
function RequestHandler.processAllRequests()
	-- Clear out expired cooldowns for recent commands
	EventHandler.cleanupDuplicateCommandRequests()

	-- Sort requests by time created
	local toProcess = {}
	for _, request in pairs(RequestHandler.Requests) do
		table.insert(toProcess, request)
	end
	table.sort(toProcess, function(a,b) return a.CreatedAt < b.CreatedAt end)

	for _, request in ipairs(toProcess) do
		for _, eventKey in pairs(Utils.split(request.EventKey, ",", true) or {}) do
			local event = EventHandler.Events[eventKey]
			local response = RequestHandler.processAndBuildResponse(request, event)
			if not request.SentResponse then
				RequestHandler.addUpdateResponse(response)
				request.SentResponse = true
			end
			if response.StatusCode ~= RequestHandler.StatusCodes.PROCESSING then
				RequestHandler.removeRequest(request.GUID)
			end
		end
	end
end

---Processes the Request as much as it can, returning a Response with a proper StatusCode
---@param request table IRequest
---@param event? table IEvent
---@return table response IResponse
function RequestHandler.processAndBuildResponse(request, event)
	event = event or EventHandler.Events[request.EventKey] or EventHandler.Events.None
	local response = RequestHandler.IResponse:new({
		GUID = request.GUID,
		EventKey = event.Key,
	})
	if event.Type == EventHandler.EventTypes.Reward then
		response.AdditionalInfo = {
			RewardId = request.Args and request.Args["RewardId"] or nil,
			RedemptionId = request.Args and request.Args["RedemptionId"] or nil,
			AutoComplete = true, -- TODO: Expose option to enable/disable this
		}
	end

	-- Check if the event is valid and the request is okay to process
	if not EventHandler.isValidEvent(event) then
		response.StatusCode = RequestHandler.StatusCodes.NOT_FOUND
		return response
	end
	if not event.IsEnabled then
		response.StatusCode = RequestHandler.StatusCodes.UNAVAILABLE
		return response
	end
	if request.IsCancelled then
		response.StatusCode = RequestHandler.StatusCodes.FAIL
		request.Message = "Cancelled."
		request.SentResponse = false
		return response
	end

	RequestHandler.sanitizeInput(request)

	-- Don't process recent similar command requests
	if EventHandler.isDuplicateCommandRequest(event, request) then
		response.StatusCode = RequestHandler.StatusCodes.ALREADY_REPORTED
		return response
	end

	-- Process the request and see if it's ready to be fulfilled
	local readyToFulfill = not event.Process or event:Process(request)
	if not readyToFulfill then
		response.StatusCode = RequestHandler.StatusCodes.PROCESSING
		return response
	end

	-- Complete the request and determine the output information to send back
	local result = event.Fulfill and event:Fulfill(request) or ""
	if type(result) == "string" then
		response.Message = RequestHandler.validateMessage(result)
	elseif type(result) == "table" then
		response.Message = RequestHandler.validateMessage(result.Message)
		if type(result.AdditionalInfo) == "table" then
			response.AdditionalInfo = response.AdditionalInfo or {}
			for k, v in pairs(result.AdditionalInfo) do
				response.AdditionalInfo[k] = v
			end
		end
		if type(result.GlobalVars) == "table" then
			response.GlobalVars = response.GlobalVars or {}
			for k, v in pairs(result.GlobalVars) do
				response.GlobalVars[k] = v
			end
		end
	end

	response.StatusCode = RequestHandler.StatusCodes.SUCCESS
	request.SentResponse = false

	return response
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
	-- A comma-separate list of event keys; must match one or more existing Events
	EventKey = EventHandler.Events.None.Key,
	-- Number of seconds, representing time the originating request was created
	CreatedAt = -1,
	-- A Request should always send a response (at least once) when received
	SentResponse = false,
	-- Username of the user creating the request
	Username = "",
	-- Optional arguments included with the request
	Args = {},
}
---Creates and returns a new IRequest object
---@param o? table Optional initial object table
---@return table request An IRequest object
function RequestHandler.IRequest:new(o)
	o = o or {}
	o.GUID = o.GUID or Utils.newGUID()
	o.EventKey = o.EventKey or EventHandler.Events.None.Key
	o.CreatedAt = o.CreatedAt or os.time()
	setmetatable(o, self)
	self.__index = self
	return o
end

RequestHandler.IResponse = {
	-- Required unique GUID, for syncing request/responses with the client
	GUID = "",
	-- Must match an existing Event
	EventKey = EventHandler.Events.None.Key,
	-- Number of seconds, representing time the request was processed into a response
	CreatedAt = -1,
	StatusCode = RequestHandler.StatusCodes.NOT_FOUND,
	-- The informative response message to send back to the client
	Message = "",
}
---Creates and returns a new IResponse object
---@param o? table Optional initial object table
---@return table response An IResponse object
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
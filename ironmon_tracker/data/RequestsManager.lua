RequestsManager = {
	Requests = {}, -- A list of all known requests that still need to be processed
	lastSaveTime = 0,
	SAVE_FREQUENCY = 60, -- Number of seconds to wait before saving Requests data to file
}

-- TODO: Will likely move this elsewhere as each of these gets built out
-- CR: Channel Rewards (Point Redeems), CMD: Channel Commands (!test)
RequestsManager.EventTypes = {
	CR_PickBallOnce = "pick_ball_once",
	CR_PickBallUntilOut = "pick_ball_until_out",
	CR_ChangeTheme = "change_theme",
	CR_ChangeFavorite = "change_favorite",
	CMD_Revo = "revo",
	CMD_Pokemon = "pokemon",
	CMD_Notes = "notes",
	CMD_Move = "move",
	CMD_Ability = "ability",
	CMD_Weak = "weak",
	CMD_BST = "BST",
	CMD_Route = "route",
	CMD_MonsWithMove = "mons_with_move",
	CMD_MonsWithAbility = "mons_with_ability",
	CMD_Pivots = "pivots",
	CMD_Dungeon = "dungeon",
	CMD_Theme = "theme",
	CMD_Coverage = "coverage",
	CMD_Heals = "heals",
	CMD_TMs = "tms",
	CMD_GAMESTATS = "gamestats",
	CMD_PROGRESS = "progress",
	CMD_LOG = "log",
	CMD_ABOUT = "about",
	CMD_HELP = "help",
	None = "None",
}

RequestsManager.StatusCodes = {
	SUCCESS = 200,
	FAIL = 400,
	NOT_FOUND = 404,
}

local ALLOWED_EVENTTYPES = {}
for _, val in pairs(RequestsManager.EventTypes) do
	ALLOWED_EVENTTYPES[val] = true
end
ALLOWED_EVENTTYPES[RequestsManager.EventTypes.None] = nil

function RequestsManager.initialize()
	RequestsManager.Requests = {}
	RequestsManager.lastSaveTime = os.time()
	RequestsManager.loadData()
end

--- Adds an IRequest to the requests queue; returns true if successful
---@param request table IRequest object
---@return boolean success
function RequestsManager.addRequest(request)
	-- Only add *new* requests with known event categories and types
	if RequestsManager.Requests[request.GUID] or request.EventType == RequestsManager.EventTypes.None then
		return false
	end

	RequestsManager.Requests[request.GUID] = request
	return true
end

--- Processes all IRequests (if able)
---@return table responses
function RequestsManager.processAllRequests()
	local responses = {}

	-- TODO: Implement better, sort by time, dont process if something ahead of it in queue of same event type (if that matters), avoid duplicate requests
	local requestsToProcess = {}
	for _, request in pairs(RequestsManager.Requests) do
		if ALLOWED_EVENTTYPES[request.EventType] then
			table.insert(requestsToProcess, request)
		else
			table.insert(responses, RequestsManager.IResponse:new({
				GUID = request.GUID,
				EventType = request.EventType,
				StatusCode = RequestsManager.StatusCodes.NOT_FOUND,
			}))
		end
	end

	return responses
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

-- Request/Response object prototypes

RequestsManager.IRequest = {
	GUID = "",
	EventType = RequestsManager.EventTypes.None,
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
	EventType = RequestsManager.EventTypes.None,
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
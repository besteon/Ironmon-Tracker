Network = {
	CurrentConnection = {},
	lastUpdateTime = 0,
	TEXT_UPDATE_FREQUENCY = 3, -- # of seconds
	TEXT_INBOUND_FILE = "Inbound-Tracker.txt", -- The CLIENT's inbound data file; Tracker is the "Server" and will write responses to this file
	TEXT_OUTBOUND_FILE = "Outbound-Tracker.txt", -- The CLIENT's outbound data file; Tracker is the "Server" and will read requests from this file
	-- WEBSOCKET_SERVER_IP = "127.0.0.1", -- Not supported
	-- WEBSOCKET_SERVER_PORT = "8080", -- Not supported
}

Network.ConnectionTypes = {
	TextFiles = "Text",
	WebSockets = "WebSockets", -- Not supported
	Http = "Http", -- Not supported
	None = "None",
}

Network.Options = {
	["ConnectionType"] = Network.ConnectionTypes.None,
	["DataFolder"] = "",
	["WebSocketIP"] = nil, -- Not supported
	["WebSocketPort"] = nil, -- Not supported
	["HttpGet"] = nil, -- Not supported
	["HttpPost"] = nil, -- Not supported
}

function Network.initialize()
	Network.loadConnectionSettings()
	Network.lastUpdateTime = 0
end

function Network.isConnected()
	return Network.CurrentConnection and Network.CurrentConnection.IsConnected ~= false
end

function Network.loadConnectionSettings()
	local connectionType = Network.Options["ConnectionType"] or Network.ConnectionTypes.None
	Network.CurrentConnection = nil
	Network.tryConnect(connectionType)
end

function Network.tryConnect(connectionType)
	if Network.isConnected() or not connectionType then
		return
	end
	Network.CurrentConnection = Network.IConnection:new({ Type = connectionType })
	local C = Network.CurrentConnection
	if connectionType == Network.ConnectionTypes.WebSockets then
		-- Not supported
		-- local SOCKET_SERVER_NOT_FOUND = "Socket server was not initialized"
		-- local serverInfo = comm.socketServerGetInfo() or SOCKET_SERVER_NOT_FOUND
		-- C.IsConnected = Utils.containsText(serverInfo, SOCKET_SERVER_NOT_FOUND)
	elseif connectionType == Network.ConnectionTypes.Http then
		-- Not supported
	elseif connectionType == Network.ConnectionTypes.TextFiles then
		C.UpdateFrequency = Network.TEXT_UPDATE_FREQUENCY
		C.UpdateFunction = Network.updateByText
		local folder = Network.Options["DataFolder"] or ""
		C.InboundFile = folder .. FileManager.slash .. Network.TEXT_INBOUND_FILE
		C.OutboundFile = folder .. FileManager.slash .. Network.TEXT_OUTBOUND_FILE
		C.IsConnected = (folder ~= "") and FileManager.folderExists(folder)
	end
end

--- Closes any active connections and saves outstanding Requests
function Network.closeConnections()
	if Network.isConnected() then
		Network.CurrentConnection.IsConnected = false
	end
	RequestHandler.saveData()
end

function Network.update()
	-- Only check for possible update once every 10 frames
	if Program.Frames.highAccuracyUpdate ~= 0 or not Network.isConnected() then
		return
	end

	-- Check for any new requests from the server, process them accordingly, and send back responses
	-- Server Requests should a one-time use only; once accepted, the server shouldn't send the same request again
	Network.CurrentConnection:TryUpdate()

	RequestHandler.trySaveData()
end

--- The update function used by the "TextFiles" Network connection type
function Network.updateByText()
	local C = Network.CurrentConnection
	if not C.OutboundFile or not C.InboundFile or not FileManager.JsonLibrary then
		return
	end

	-- Part 1: Read new requests from the other application's outbound text file
	local newRequests = FileManager.decodeJsonFile(C.OutboundFile)
	for _, request in pairs(newRequests or {}) do
		RequestHandler.addNewRequest(RequestHandler.IRequest:new({
			GUID = request.GUID,
			EventType = request.EventType,
			CreatedAt = request.CreatedAt,
			Username = request.Username,
			Args = request.Args,
		}))
	end

	-- Part 2: Process the requests
	RequestHandler.processAllRequests()

	-- Part 3: Send responses to the other application's inbound text file
	local responses = RequestHandler.getResponses()
	-- Prevent consecutive "empty" file writes
	if #responses > 0 or not C.InboundWasEmpty then
		local success = FileManager.encodeToJsonFile(C.InboundFile, responses)
		C.InboundWasEmpty = (success == false) -- false if no resulting json data
		RequestHandler.clearResponses()
	end
end

-- Connection object prototype
Network.IConnection = {
	Type = Network.ConnectionTypes.None,
	IsConnected = false,
	UpdateFrequency = -1, -- Number of seconds; 0 or less will prevent updates
	UpdateFunction = function(self) end,
	-- Don't override the follow functions
	TryUpdate = function(self, updateFunc)
		if (self.UpdateFrequency or 0) > 0 and (os.time() - Network.lastUpdateTime) >= self.UpdateFrequency then
			updateFunc = updateFunc or self.UpdateFunction
			if type(updateFunc) == "function" then
				updateFunc(self)
			end
			Network.lastUpdateTime = os.time()
		end
	end,
}
function Network.IConnection:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Not supported

-- [Web Sockets] Streamer.bot Docs
-- https://wiki.streamer.bot/en/Servers-Clients
-- https://wiki.streamer.bot/en/Servers-Clients/WebSocket-Server
-- https://wiki.streamer.bot/en/Servers-Clients/WebSocket-Server/Requests
-- https://wiki.streamer.bot/en/Servers-Clients/WebSocket-Server/Events
-- [Web Sockets] Bizhawk Docs
-- string comm.socketServerGetInfo 		-- returns the IP and port of the Lua socket server
-- bool comm.socketServerIsConnected 	-- socketServerIsConnected
-- string comm.socketServerResponse 	-- Receives a message from the Socket server. Formatted with msg length at start, e.g. "3 ABC"
-- int comm.socketServerSend 			-- sends a string to the Socket server
-- void comm.socketServerSetTimeout 	-- sets the timeout in milliseconds for receiving messages
-- bool comm.socketServerSuccessful 	-- returns the status of the last Socket server action

-- --- Registering an event is required to enable you to listen to events emitted by Streamer.bot:
-- --- https://wiki.streamer.bot/en/Servers-Clients/WebSocket-Server/Events
-- ---@param requestId string Example: "123"
-- ---@param eventSource string Example: "Command"
-- ---@param eventTypes table Example: { "Message", "Whisper" }
-- function Network.registerWebSocketEvent(requestId, eventSource, eventTypes)
-- 	local registerFormat = [[{"request":"Subscribe","id":"%s","events":{"%s":[%s]}}]]
-- 	local requestStr = string.format(registerFormat, requestId, eventSource, table.concat(eventTypes, ","))
-- 	local response = comm.socketServerSend(requestStr)
-- 	-- -1 = failed ?
-- end
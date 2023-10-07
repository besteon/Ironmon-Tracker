local DEBUG = true

Network = {
	CurrentConnection = {},
	lastUpdateTime = 0,
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
	if DEBUG then
		connectionType = Network.ConnectionTypes.TextFiles
	end
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
		C.UpdateFrequency = 3
		C.UpdateFunction = Network.updateByText
		local folder = Network.Options["DataFolder"] or ""
		if DEBUG then
			folder = [[C:\Users\shado\Dropbox\Stream Stuff\Streamer.bot-x64-0.1.19\data]]
		end
		C.InboundFile = folder .. FileManager.slash .. "Inbound-Tracker.txt"
		C.OutboundFile = folder .. FileManager.slash .. "Outbound-Tracker.txt"
		C.IsConnected = (folder ~= "") and FileManager.folderExists(folder)
	end
end

function Network.update()
	-- Only check for possible update once every 10 frames
	if Program.Frames.highAccuracyUpdate ~= 0 or not Network.isConnected() then
		return
	end
	Network.CurrentConnection:TryUpdate()
end

--- The update function used by the "TextFiles" Network connection type
function Network.updateByText()
	local C = Network.CurrentConnection
	if not C.OutboundFile or not C.InboundFile or not FileManager.JsonLibrary then
		return
	end

	-- Read new requests from the other application's outbound text file
	local requests
	local outboundFile = io.open(C.OutboundFile, "r")
	if outboundFile then
		local inputStr = outboundFile:read("*a") or ""
		if #inputStr > 0 then
			requests = FileManager.JsonLibrary.decode(inputStr)
		end
	end

	-- Process the requests
	local responses = {}
	for key, request in pairs(requests or {}) do
		-- TODO: implement, likely not as simple as doing them all. Need a RequestManager
	end

	-- Send responses to the other application's inbound text file
	if #responses == 0 and C.InboundWasEmpty then
		-- Prevent consecutive empty file writes
		return
	end
	local inboundFile = io.open(C.InboundFile, "w")
	if inboundFile then
		local outputStr = ""
		if #responses > 0 then
			outputStr = FileManager.JsonLibrary.encode(responses)
		end
		inboundFile:write(outputStr)
		inboundFile:close()
		C.InboundWasEmpty = (#outputStr == 0)
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
		local currentTime = os.time()
		if (self.UpdateFrequency or 0) > 0 and (currentTime - Network.lastUpdateTime) >= self.UpdateFrequency then
			updateFunc = updateFunc or self.UpdateFunction
			if type(updateFunc) == "function" then
				updateFunc(self)
			end
			Network.lastUpdateTime = currentTime
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
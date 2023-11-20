Network = {
	CurrentConnection = {},
	lastUpdateTime = 0,
	STREAMERBOT_VERSION = "1.0.4", -- Known streamerbot version. Update this value to inform user to update streamerbot code
	TEXT_UPDATE_FREQUENCY = 2, -- # of seconds
	SOCKET_UPDATE_FREQUENCY = 2, -- # of seconds
	HTTP_UPDATE_FREQUENCY = 2, -- # of seconds
	TEXT_INBOUND_FILE = "Tracker-Requests.json", -- The CLIENT's outbound data file; Tracker is the "Server" and will read requests from this file
	TEXT_OUTBOUND_FILE = "Tracker-Responses.json", -- The CLIENT's inbound data file; Tracker is the "Server" and will write responses to this file
	SOCKET_SERVER_NOT_FOUND = "Socket server was not initialized",
}

Network.ConnectionTypes = {
	None = "None",
	Text = "Text",

	-- WebSockets WARNING: Bizhawk must be started with command line arguments to enable connections
	-- It must also be a custom/new build of Bizhawk that actually supports asynchronous web sockets (not released yet)
	WebSockets = "WebSockets",

	-- Http WARNING: If Bizhawk is not started with command line arguments to enable connections
	-- Then an internal Bizhawk error will crash the tracker. This cannot be bypassed with pcall() or other exception handling
	-- Consider turning off "AutoConnectStartup" if exploring Http
	Http = "Http",
}

Network.ConnectionState = {
	Closed = 0, -- The server (Tracker) is not currently connected nor trying to connect
	Listen = 1, -- The server (Tracker) is online and trying to connect, waiting for response from a client
	Established = 9, -- Both the server (Tracker) and client are connected; communication is open
}

Network.Options = {
	["AutoConnectStartup"] = true,
	["ConnectionType"] = Network.ConnectionTypes.Text,
	["DataFolder"] = "",
	["WebSocketIP"] = "0.0.0.0", -- 127.0.0.1
	["WebSocketPort"] = "8080",
	["HttpGet"] = "",
	["HttpPost"] = "",
	["CommandRoles"] = "Everyone", -- A comma-separated list of allowed roles for command events
	["CustomCommandRole"] = "", -- Currently unused, not supported
}

function Network.initialize()
	-- Clear and reload Event and Request information
	EventHandler.reset()
	RequestHandler.reset()
	EventHandler.addDefaultEvents()
	RequestHandler.loadRequestsData()
	RequestHandler.removedExcludedRequests()

	Network.requiresUpdating = false
	Network.lastUpdateTime = 0
	Network.loadConnectionSettings()
	if Network.Options["AutoConnectStartup"] then
		Network.tryConnect()
	end
end

---Checks current version of the Tracker's Network code against the Streamerbot code version
---@param version string
function Network.checkVersion(version)
	Network.currentStreamerbotVersion = version
	Network.requiresUpdating = Utils.isNewerVersion(Network.STREAMERBOT_VERSION, version)
	if Network.requiresUpdating then
		Network.openUpdateRequiredPrompt()
	end
end

---@return boolean
function Network.isConnected()
	return Network.CurrentConnection.State > Network.ConnectionState.Closed
end

---@return table supportedTypes
function Network.getSupportedConnectionTypes()
	local supportedTypes = {
		Network.ConnectionTypes.Text,
		-- Network.ConnectionTypes.WebSockets, -- Not fully supported
		-- Network.ConnectionTypes.Http, -- Not fully supported
	}
	return supportedTypes
end

function Network.loadConnectionSettings()
	Network.CurrentConnection = Network.IConnection:new()
	if not Utils.isNilOrEmpty(Network.Options["ConnectionType"]) then
		Network.changeConnection(Network.Options["ConnectionType"])
	end
end

---Changes the current connection type
---@param connectionType string A Network.ConnectionTypes enum
function Network.changeConnection(connectionType)
	connectionType = connectionType or Network.ConnectionTypes.None
	-- Create or swap to a new connection
	if Network.CurrentConnection.Type ~= connectionType then
		if Network.isConnected() then
			Network.closeConnections()
		end
		Network.CurrentConnection = Network.IConnection:new({ Type = connectionType })
		Network.Options["ConnectionType"] = connectionType
		Main.SaveSettings(true)
	end
end

---Attempts to connect to the network using the current connection
---@return number connectionState The resulting Network.ConnectionState
function Network.tryConnect()
	local C = Network.CurrentConnection or {}
	-- Create or swap to a new connection
	if not C.Type then
		Network.changeConnection(Network.ConnectionTypes.None)
		C = Network.CurrentConnection
	end
	-- Don't try to connect if connection is fully established
	if C.State >= Network.ConnectionState.Established then
		return C.State
	end
	if C.Type == Network.ConnectionTypes.WebSockets then
		if true then return Network.ConnectionState.Closed end -- Not fully supported
		C.UpdateFrequency = Network.SOCKET_UPDATE_FREQUENCY
		C.SendReceive = Network.updateBySocket
		C.SocketIP = Network.Options["WebSocketIP"] or "0.0.0.0"
		C.SocketPort = tonumber(Network.Options["WebSocketPort"] or "") or 0
		local serverInfo
		if C.SocketIP ~= "0.0.0.0" and C.SocketPort ~= 0 then
			comm.socketServerSetIp(C.SocketIP)
			comm.socketServerSetPort(C.SocketPort)
			serverInfo = comm.socketServerGetInfo() or Network.SOCKET_SERVER_NOT_FOUND
			-- TODO: Might also test/try 'bool comm.socketServerIsConnected()'
		end
		local ableToConnect = serverInfo and Utils.containsText(serverInfo, Network.SOCKET_SERVER_NOT_FOUND)
		if ableToConnect then
			C.State = Network.ConnectionState.Listen
			comm.socketServerSetTimeout(500) -- # of milliseconds
		end
	elseif C.Type == Network.ConnectionTypes.Http then
		if true then return Network.ConnectionState.Closed end -- Not fully supported
		C.UpdateFrequency = Network.HTTP_UPDATE_FREQUENCY
		C.SendReceive = Network.updateByHttp
		C.HttpGetUrl = Network.Options["HttpGet"] or ""
		C.HttpPostUrl = Network.Options["HttpPost"] or ""
		if not Utils.isNilOrEmpty(C.HttpGetUrl) then
			-- Necessary for comm.httpTest()
			comm.httpSetGetUrl(C.HttpGetUrl)
		end
		if not Utils.isNilOrEmpty(C.HttpPostUrl) then
			-- Necessary for comm.httpTest()
			comm.httpSetPostUrl(C.HttpPostUrl)
		end
		local result
		if not Utils.isNilOrEmpty(C.HttpGetUrl) and C.HttpPostUrl then
			-- See HTTP WARNING at the top of this file
			pcall(function() result = comm.httpTest() or "N/A" end)
		end
		local ableToConnect = result and Utils.containsText(result, "done testing")
		if ableToConnect then
			C.State = Network.ConnectionState.Listen
			comm.httpSetTimeout(500) -- # of milliseconds
		end
	elseif C.Type == Network.ConnectionTypes.Text then
		C.UpdateFrequency = Network.TEXT_UPDATE_FREQUENCY
		C.SendReceive = Network.updateByText
		local folder = Network.Options["DataFolder"] or ""
		C.InboundFile = folder .. FileManager.slash .. Network.TEXT_INBOUND_FILE
		C.OutboundFile = folder .. FileManager.slash .. Network.TEXT_OUTBOUND_FILE
		local ableToConnect = not Utils.isNilOrEmpty(folder) and FileManager.folderExists(folder)
		if ableToConnect then
			C.State = Network.ConnectionState.Listen
		end
	end
	if C.State == Network.ConnectionState.Listen then
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			EventKey = EventHandler.CoreEventKeys.Start,
		}))
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			EventKey = EventHandler.CoreEventKeys.GetRewards,
		}))
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			EventKey = EventHandler.CoreEventKeys.UpdateEvents,
		}))
	end
	return C.State
end

---Updates the current connection state to the one provided
---@param connectionState number a Network.ConnectionState
function Network.updateConnectionState(connectionState)
	Network.CurrentConnection.State = connectionState
end

--- Closes any active connections and saves outstanding Requests
function Network.closeConnections()
	if Network.isConnected() then
		RequestHandler.addUpdateRequest(RequestHandler.IRequest:new({
			EventKey = EventHandler.CoreEventKeys.Stop,
		}))
		Network.CurrentConnection:SendReceive()
		Network.updateConnectionState(Network.ConnectionState.Closed)
	end
	RequestHandler.saveRequestsData()
end

--- Attempts to perform the scheduled network data update
function Network.update()
	-- Only check for possible update once every 10 frames
	if Program.Frames.highAccuracyUpdate ~= 0 or not Network.isConnected() then
		return
	end
	Network.CurrentConnection:SendReceiveOnSchedule()
	RequestHandler.saveRequestsDataOnSchedule()
end

--- The update function used by the "Text" Network connection type
function Network.updateByText()
	local C = Network.CurrentConnection
	if not C.InboundFile or not C.OutboundFile or not FileManager.JsonLibrary then
		return
	end

	EventHandler.checkForConfigChanges()
	local requestsAsJson = FileManager.decodeJsonFile(C.InboundFile)
	RequestHandler.receiveJsonRequests(requestsAsJson)
	RequestHandler.processAllRequests()
	local responses = RequestHandler.getResponses()
	-- Prevent consecutive "empty" file writes
	if #responses > 0 or not C.InboundWasEmpty then
		local success = FileManager.encodeToJsonFile(C.OutboundFile, responses)
		C.InboundWasEmpty = (success == false) -- false if no resulting json data
		RequestHandler.clearAllResponses()
	end
end

--- The update function used by the "Socket" Network connection type
function Network.updateBySocket()
	local C = Network.CurrentConnection
	if C.SocketIP == "0.0.0.0" or C.SocketPort == 0 or not FileManager.JsonLibrary then
		return
	end
	-- TODO: Not implemented. Requires asynchronous compatibility
	if true then
		return
	end

	EventHandler.checkForConfigChanges()
	local input = ""
	local requestsAsJson = FileManager.JsonLibrary.decode(input) or {}
	RequestHandler.receiveJsonRequests(requestsAsJson)
	RequestHandler.processAllRequests()
	local responses = RequestHandler.getResponses()
	if #responses > 0 then
		local output = FileManager.JsonLibrary.encode(responses) or "[]"
		RequestHandler.clearAllResponses()
	end
end

--- The update function used by the "Http" Network connection type
function Network.updateByHttp()
	local C = Network.CurrentConnection
	if Utils.isNilOrEmpty(C.HttpGetUrl) or Utils.isNilOrEmpty(C.HttpPostUrl) or not FileManager.JsonLibrary then
		return
	end
	-- TODO: Not implemented. Requires asynchronous compatibility
	if true then
		return
	end

	EventHandler.checkForConfigChanges()
	local resultGet = comm.httpGet(C.HttpGetUrl) or ""
	local requestsAsJson = FileManager.JsonLibrary.decode(resultGet) or {}
	RequestHandler.receiveJsonRequests(requestsAsJson)
	RequestHandler.processAllRequests()
	local responses = RequestHandler.getResponses()
	if #responses > 0 then
		local payload = FileManager.JsonLibrary.encode(responses) or "[]"
		local resultPost = comm.httpPost(C.HttpPostUrl, payload)
		-- Utils.printDebug("POST Response Code: %s", resultPost or "N/A")
		RequestHandler.clearAllResponses()
	end
end

-- Connection object prototype
Network.IConnection = {
	Type = Network.ConnectionTypes.None,
	State = Network.ConnectionState.Closed,
	UpdateFrequency = -1, -- Number of seconds; 0 or less will prevent scheduled updates
	SendReceive = function(self) end,
	-- Don't override the follow functions
	SendReceiveOnSchedule = function(self, updateFunc)
		if (self.UpdateFrequency or 0) > 0 and (os.time() - Network.lastUpdateTime) >= self.UpdateFrequency then
			updateFunc = updateFunc or self.SendReceive
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

function Network.getStreamerbotCode()
	local filepath = FileManager.prependDir(FileManager.Files.STREAMERBOT_CODE)
	return FileManager.readLinesFromFile(filepath)[1] or ""
end

function Network.openUpdateRequiredPrompt()
	local form = Utils.createBizhawkForm("Streamerbot Update Required", 350, 150, 100, 50)
	local x, y, lineHeight = 20, 20, 20
	forms.label(form, string.format("Streamerbot Tracker Integration code requires an update."), x, y, 330, 20)
	y = y + lineHeight
	forms.label(form, string.format("You must re-import the code to continue using Stream Connect."), x, y, 330, 20)
	y = y + lineHeight
	-- Bottom row buttons
	y = y + 10
	forms.button(form, "Show Me", function() -- TODO: Language
		Utils.closeBizhawkForm(form)
		StreamConnectOverlay.openGetCodeWindow()
	end, 40, y, 80, lineHeight + 5)
	forms.button(form, "Turn Off Stream Connect", function() -- TODO: Language
		Network.Options["AutoConnectStartup"] = false
		Main.SaveSettings(true)
		Network.closeConnections()
		Utils.closeBizhawkForm(form)
	end, 150, y, 150, lineHeight + 5)
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
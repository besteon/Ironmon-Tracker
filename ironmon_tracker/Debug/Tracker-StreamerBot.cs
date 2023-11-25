using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Serialization.Json;
using Newtonsoft.Json;

public class CPHInline
{
	// Internal Streamerbot Properties
	private const string VERSION = "1.0.4"; // Used to compare against known version # in Tracker code, to check if this code needs updating
	private const bool DEBUG_LOG_EVENTS = false;
	private const string GVAR_ConnectionDataFolder = "connectionDataFolder"; // "data" folder override global variable; define is Streamerbot
	private const string DATA_FOLDER = @"data"; // Located at ~/Streamer.bot/data/
	private const string INBOUND_FILENAME = @"Tracker-Responses.json"; // Located inside the DATA_FOLDER
	private const string OUTBOUND_FILENAME = @"Tracker-Requests.json"; // Located inside the DATA_FOLDER
	private const int TEXT_UPDATE_FREQUENCY = 1; // # of seconds
	private const string COMMAND_ACTION_ID = "0f58bcaf-4a93-442b-b66d-774ee5ba954d";
	private const string COMMAND_REGEX = @"^!([A-Za-z0-9\-\.]+)\s*(.*)";
	private const string INVISIBLE_CHAR = "󠀀"; // U+E0000 (this is *not* an empty string)
	private const string SOURCE_STREAMERBOT = "Streamerbot";
	private const string REQUEST_COMPLETE = "Complete";

	// Internal Streamerbot Data Variables
	private bool _isConnected { get; set; }
	private string _inboundFile { get; set; }
	private string _outboundFile { get; set; }
	private Dictionary<string,bool> _allowedEvents { get; set; }
	private Dictionary<string,bool> _commandRoles { get; set; }
	private List<Request> _requests { get; set; }
	private List<Response> _responses { get; set; }
	private List<Request> _offlineRequests { get; set; }
	private Dictionary<string,int> _receivedResponses { get; set; }
	private Vars VARS { get; set; }

	// Required Streamerbot Method: Run when application starts up
	public void Init()
	{
		try
		{
			_isConnected = false;
			_allowedEvents = new Dictionary<string,bool>();
			_commandRoles = new Dictionary<string,bool>()
			{
				{ "Broadcaster", true }, // For now, this is always available
				{ "Everyone", true },
				{ "Moderator", false },
				{ "Vip", false },
				{ "Subscriber", false }
			};
			_requests = new List<Request>();
			_responses = new List<Response>();
			_offlineRequests = new List<Request>();
			_receivedResponses = new Dictionary<string,int>();

			VerifyOrCreateDataFiles();

			// By default, newly imported commands are disabled; this force enables them for convenience
			CPH.EnableCommand(COMMAND_ACTION_ID);

			if (!_isConnected)
			{
				SendStreamerbotStart();
				SendRewardsList();
			}
			else
			{
				CPH.LogInfo($"START: Already connected to the Tracker.");
			}

			CreateReoccuringFileReader();
		} catch (Exception e) {}
	}

	// Required Streamerbot Method: Run when the application shuts down
	public void Dispose()
	{
		try
		{
			SendStreamerbotStop();
			CancelReoccuringFileReader();
		} catch (Exception e) {}
	}

	// Required Streamerbot Method: Run when the action is triggered
	public bool Execute()
	{
		// While the Tracker is offline, don't queue up any new requests
		if (!_isConnected)
			return true;

		VARS = new Vars(args);

		try
		{
			// Determine what type of event was triggered
			if (!string.IsNullOrEmpty(VARS.CommandId))
				ProcessCommandEvent();
			else if (!string.IsNullOrEmpty(VARS.RewardId))
				ProcessChannelRedeemEvent();
		} catch (Exception e) {}

		return true; // Required
	}

	// https://wiki.streamer.bot/en/Commands
	public void ProcessCommandEvent()
	{
		Match matchesCommand = Regex.Match(VARS.RawInput.ToLower(), COMMAND_REGEX, RegexOptions.IgnoreCase);
		if (!matchesCommand.Success)
			return;

		// Only process allowed commands (allowed list received on server startup)
		var command = matchesCommand.Groups[1].Value.ToLower();
		if (!_allowedEvents.ContainsKey(command))
			return;

		// Check if this user has role permissions to use Tracker commands
		if (!_commandRoles["Everyone"])
		{
			bool allowBroadcaster = _commandRoles["Broadcaster"] && VARS.BroadcastUserId.Equals(VARS.UserId);
			bool allowModerator = _commandRoles["Moderator"] && VARS.IsModerator;
			bool allowVip = _commandRoles["Vip"] && VARS.IsVip;
			bool allowSubscriber = _commandRoles["Subscriber"] && VARS.IsSubscribed;
			if (!allowBroadcaster && !allowModerator && !allowVip && !allowSubscriber)
				return;
		}

		var input = matchesCommand.Groups[2].Value ?? string.Empty;
		// Fix to stop 7TV spam prevention character
		input = Regex.Replace(input, INVISIBLE_CHAR, string.Empty);

		var request = new Request()
		{
			GUID = Guid.NewGuid().ToString(),
			EventKey = string.Empty, // Lazily ask the server to automatically figure out which command event is triggering
			CreatedAt = GetTime(),
			Username = VARS.User,
			Args = new Dictionary<string, object>()
		};
		request.Args.Add("Command", command);
		request.Args.Add("Input", input);
		request.Args.Add("Counter", VARS.Counter);
		AddNewRequestAndSend(request);
	}

	// https://wiki.streamer.bot/en/Platforms/Twitch/Channel-Point-Rewards
	public void ProcessChannelRedeemEvent()
	{
		// Only process allowed channel redeems (allowed list received on server startup)
		var rewardId = VARS.RewardId ?? string.Empty;
		if (!_allowedEvents.ContainsKey(rewardId))
			return;

		var request = new Request()
		{
			GUID = Guid.NewGuid().ToString(),
			EventKey = string.Empty, // Lazily ask the server to automatically figure out which channel reward is triggering
			CreatedAt = GetTime(),
			Username = VARS.User,
			Args = new Dictionary<string, object>()
		};
		request.Args.Add("RewardName", VARS.RewardName);
		request.Args.Add("RewardId", rewardId);
		request.Args.Add("RedemptionId", VARS.RedemptionId); // Required for fulfilling/cancelling the twitch reward later
		request.Args.Add("Input", VARS.RawInput);
		request.Args.Add("Counter", VARS.Counter);
		AddNewRequestAndSend(request);
	}

	private void SetOptionalGlobalVariables(Response response)
	{
		if (response == null || response.GlobalVars == null)
			return;

		try
		{
			foreach(var globalVar in response.GlobalVars)
			{
				CPH.SetGlobalVar(globalVar.Key, globalVar.Value.ToString());
			}
		} catch (Exception e) {}
	}

	private void CompleteIfChannelRedeem(Response response, bool cancelInstead = false)
	{
		if (response == null || response.AdditionalInfo == null || !response.AdditionalInfo.ContainsKey("RewardId") || !response.AdditionalInfo.ContainsKey("RedemptionId"))
			return;

		var rewardId = response.AdditionalInfo["RewardId"].ToString();
		var redemptionId = response.AdditionalInfo["RedemptionId"].ToString();
		var shouldComplete = true;
		if (response.AdditionalInfo.ContainsKey("AutoComplete"))
			shouldComplete = (response.AdditionalInfo["AutoComplete"] as bool?) ?? true;

		if (!shouldComplete || string.IsNullOrEmpty(rewardId) || string.IsNullOrEmpty(redemptionId))
			return;

		try
		{
			if (cancelInstead)
			{
				//CPH.UpdateRewardCooldown(rewardId, (long)1); // This permanently changes the cooldown, not what I want
				CPH.TwitchRedemptionCancel(rewardId, redemptionId);
			}
			else
			{
				CPH.TwitchRedemptionFulfill(rewardId, redemptionId);
			}
		} catch (Exception e) {}
	}

	private void AddNewRequestAndSend(Request request)
	{
		if (_isConnected)
		{
			_requests.Add(request);
			WriteRequestsToOutbound();
		}
		else
		{
			_offlineRequests.Add(request);
		}
	}

	public void WriteRequestsToOutbound()
	{
		try
		{
			using (StreamWriter file = File.CreateText(_outboundFile)) // Tracker-Requests
			{
				JsonSerializer serializer = new JsonSerializer();
				if (_requests == null)
					serializer.Serialize(file, new List<Request>());
				else
					serializer.Serialize(file, _requests);
			}
		} catch (Exception e) {}
	}

	// https://wiki.streamer.bot/en/Settings/File-Folder-Watcher
	public void ReadResponsesFromInbound()
	{
		try {
			_responses = null;
			using (StreamReader file = new StreamReader(_inboundFile)) // Tracker-Responses
			{
				string json = file.ReadToEnd();
				_responses = JsonConvert.DeserializeObject<List<Response>>(json);
			}
			if (_responses == null)
				_responses = new List<Response>();

			ProcessResponses();
			CleanupOldResponses();
		} catch (Exception e) {}
	}

	public void ProcessResponses()
	{
		if (_responses == null || !_responses.Any())
			return;

		int timeNow = GetTime();
		bool updatedRequests = false;
		foreach (var response in _responses)
		{
			if (_receivedResponses.ContainsKey(response.GUID + response.StatusCode))
				continue;

			bool specialResponse = CheckSpecialServerEvent(response);

			switch(response.StatusCode)
			{
				// PROCESSING = 102, -- The server (Tracker) has received and is processing the request, but no response is available yet
				case 102:
					break;
				// SUCCESS = 200, -- The request succeeded and a response message is available
				case 200:
					if (!specialResponse)
					{
						SetOptionalGlobalVariables(response);
						CompleteIfChannelRedeem(response);
						if (!string.IsNullOrEmpty(response.Message))
							CPH.SendMessage(response.Message, true);
					}
					break;
				// ALREADY_REPORTED = 208, -- The request is a duplicate of another recent request, no additional response message will be sent
				case 208:
					break;
				// FAIL = 400, -- The server (Tracker) won't process, likely due to a client error with formatting the request
				case 400:
				// NOT_FOUND = 404, -- The server (Tracker) cannot find the requested resource or event
				case 404:
				// UNAVAILABLE = 503, -- The server (Tracker) is not able to handle the request, usually because its event hook disabled
				case 503:
				default:
					CompleteIfChannelRedeem(response, true); // Don't cancel non-tracker rewards
					break;
			}

			_receivedResponses.Add(response.GUID + response.StatusCode, timeNow);
			if (DEBUG_LOG_EVENTS && !string.IsNullOrEmpty(response.EventKey))
				CPH.LogInfo($"Tracker Event: {response.EventKey} [{response.StatusCode}] GUID:{response.GUID}, Message:'{response.Message}'");

			// Don't remove special response/requests that are still processing
			if (response.StatusCode != 102 || !specialResponse)
			{
				int numRemoved = _requests.RemoveAll(r => r.GUID.Equals(response.GUID));
				if (numRemoved > 0)
					updatedRequests = true;
			}
		}

		if (updatedRequests)
			WriteRequestsToOutbound();
	}

	private bool CheckSpecialServerEvent(Response response)
	{
		if (response.EventKey.Equals("TS_Start"))
		{
			if (!_isConnected)
			{
				_isConnected = true;
				// Other on-start code here
				CPH.LogInfo($"START: Successfully connected to the Tracker!");
			}
			if (!response.Message.Contains(REQUEST_COMPLETE))
			{
				SendStreamerbotStart(response.GUID);
			}
			return true;
		}
		else if (response.EventKey.Equals("TS_Stop"))
		{
			if (_isConnected)
			{
				_isConnected = false;
				// Other on-stop code here
				CPH.LogInfo($"STOP: Disconnected from the Tracker.");
			}
			return true;
		}
		else if (response.EventKey.Equals("TS_GetRewardsList"))
		{
			if (!response.Message.Contains(REQUEST_COMPLETE))
			{
				SendRewardsList(response.GUID);
			}
			return true;
		}
		else if (response.EventKey.Equals("TS_UpdateEvents"))
		{
			ReceiveAllowedEvents(response);
			return true;
		}
		return false;
	}

	private void SendStreamerbotStart(string guid = "")
	{
		CPH.LogInfo($"START: Starting Tracker communication. Connecting...");
		// Don't send if already sent for this request/response(guid)
		if (!string.IsNullOrEmpty(guid) && _requests.Any(r => r.GUID.Equals(guid)))
			return;

		int now = GetTime();
		var requestStart = new Request()
		{
			GUID = string.IsNullOrEmpty(guid) ? Guid.NewGuid().ToString() : guid,
			EventKey = "TS_Start",
			CreatedAt = now - 1, // Prioritize resolving this request before any others made at this point in time
			Username = "Streamer.bot Internal",
			Args = new Dictionary<string, object>()
		};
		requestStart.Args.Add("Source", SOURCE_STREAMERBOT);
		requestStart.Args.Add("Version", VERSION);
		_requests.Add(requestStart);

		var requestEvents = new Request()
		{
			GUID = Guid.NewGuid().ToString(),
			EventKey = "TS_UpdateEvents",
			CreatedAt = now,
			Username = "Streamer.bot Internal",
			Args = new Dictionary<string, object>()
		};
		requestEvents.Args.Add("Source", SOURCE_STREAMERBOT);
		_requests.Add(requestEvents);

		WriteRequestsToOutbound();
	}

	private void SendStreamerbotStop(string guid = "")
	{
		CPH.LogInfo($"STOP: Stopping Tracker communication. Disconnected.");
		// Don't send if already sent for this request/response(guid)
		if (!string.IsNullOrEmpty(guid) && _requests.Any(r => r.GUID.Equals(guid)))
			return;

		var request = new Request()
		{
			GUID = string.IsNullOrEmpty(guid) ? Guid.NewGuid().ToString() : guid,
			EventKey = "TS_Stop",
			CreatedAt = GetTime() + 1, // Delay to resolve this request after any others made at this point in time
			Username = "Streamer.bot Internal",
			Args = new Dictionary<string, object>()
		};
		request.Args.Add("Source", SOURCE_STREAMERBOT);
		_requests.Add(request);
		WriteRequestsToOutbound();
	}

	private void SendRewardsList(string guid = "")
	{
		// Don't send if already sent for this request/response(guid)
		if (!string.IsNullOrEmpty(guid) && _requests.Any(r => r.GUID.Equals(guid)))
			return;

		// Get the current list of rewards from Twitch
		var rewardsInternal = CPH.TwitchGetRewards();
		var rewards = new List<TwitchReward>();
		foreach(var reward in rewardsInternal)
		{
			rewards.Add(new TwitchReward(){
				Id = reward.Id,
				Title = reward.Title,
			});
		}

		var request = new Request()
		{
			GUID = string.IsNullOrEmpty(guid) ? Guid.NewGuid().ToString() : guid,
			EventKey = "TS_GetRewardsList",
			CreatedAt = GetTime(),
			Username = "Streamer.bot Internal",
			Args = new Dictionary<string, object>()
		};
		request.Args.Add("Source", SOURCE_STREAMERBOT);
		request.Args.Add("Rewards", rewards);
		_requests.Add(request);
		WriteRequestsToOutbound();
	}

	private void ReceiveAllowedEvents(Response response)
	{
		if (response == null || response.AdditionalInfo == null)
			return;

		if (response.AdditionalInfo.ContainsKey("AllowedEvents"))
		{
			_allowedEvents = new Dictionary<string, bool>();
			var commaSeparatedEvents = response.AdditionalInfo["AllowedEvents"].ToString();
			if (!string.IsNullOrEmpty(commaSeparatedEvents))
			{
				foreach (var eventKey in commaSeparatedEvents.Split(',').ToList())
				{
					var key = eventKey.Trim();
					if (!_allowedEvents.ContainsKey(key))
						_allowedEvents.Add(key, true);
				}
			}
		}
		if (response.AdditionalInfo.ContainsKey("CommandRoles"))
		{
			// Start with default values, then update accordingly
			_commandRoles["Broadcaster"] = true;
			_commandRoles["Everyone"] = true;
			_commandRoles["Moderator"] = false;
			_commandRoles["Vip"] = false;
			_commandRoles["Subscriber"] = false;

			// Check if commands are limited to specific roles instead of allowing "Everyone"
			var commaSeparatedRoles = response.AdditionalInfo["CommandRoles"].ToString();
			if (!string.IsNullOrEmpty(commaSeparatedRoles) && !commaSeparatedRoles.Contains("Everyone"))
			{
				_commandRoles["Everyone"] = false;
				foreach (var roleKey in commaSeparatedRoles.Split(',').ToList())
				{
					var role = roleKey.Trim();
					if (_commandRoles.ContainsKey(role))
						_commandRoles[role] = true;
				}
			}
		}
	}

	private void VerifyOrCreateDataFiles()
	{
		try
		{
			string dataDirectory = System.IO.Directory.GetCurrentDirectory(); // was Environment.CurrentDirectory

			// Workaround if running as administrator
			if (dataDirectory.ToLower().Contains("windows") && dataDirectory.ToLower().Contains("system32"))
				dataDirectory = System.AppDomain.CurrentDomain.BaseDirectory;

			// Check first if the user has defined alternative data folder
			var directoryOverride = CPH.GetGlobalVar<string>(GVAR_ConnectionDataFolder, true);
			if (!string.IsNullOrEmpty(directoryOverride) && !directoryOverride.Equals("NONE") && Directory.Exists(directoryOverride))
				dataDirectory = directoryOverride;

			// Create required inbound/outbound files
			_inboundFile = Path.Combine(dataDirectory, DATA_FOLDER, INBOUND_FILENAME); // Responses (incoming)
			_outboundFile = Path.Combine(dataDirectory, DATA_FOLDER, OUTBOUND_FILENAME); // Requests (outgoing)
			using(StreamWriter sw = File.AppendText(_inboundFile)){};
			using(StreamWriter sw = File.AppendText(_outboundFile)){};
		} catch (Exception e) {}
	}

	private void CleanupOldResponses()
	{
		const int EXPIRE_TIME = 10 * 60; // recorded responses are kept for 10 minutes max
		int timeNow = GetTime();
		foreach(var item in _receivedResponses.Where(kvp => (timeNow - kvp.Value) >= EXPIRE_TIME).ToList())
		{
			_receivedResponses.Remove(item.Key);
		}
	}

	private int GetTime()
	{
		// Calculate current time
		TimeSpan t = (DateTime.UtcNow - new DateTime(1970, 1, 1));
		return (int)t.TotalSeconds;
	}

	private CancellationTokenSource _reoccuringTokenSrc { get; set; }
	private void CreateReoccuringFileReader()
	{
		_reoccuringTokenSrc = new CancellationTokenSource();
		Task.Run(async () => {
			while (_reoccuringTokenSrc != null && !_reoccuringTokenSrc.Token.IsCancellationRequested)
			{
				try
				{
					ReadResponsesFromInbound();
				} catch (Exception e) {}
				await Task.Delay(TimeSpan.FromSeconds(TEXT_UPDATE_FREQUENCY), _reoccuringTokenSrc.Token);
			}
			if (_reoccuringTokenSrc != null)
				_reoccuringTokenSrc.Dispose();
		}, _reoccuringTokenSrc.Token);
	}
	private void CancelReoccuringFileReader()
	{
		if (_reoccuringTokenSrc != null)
			_reoccuringTokenSrc.Cancel();
	}

	public class Request
	{
		public string GUID { get; set; }
		public string EventKey { get; set; }
		public int CreatedAt { get; set; }
		public string Username { get; set; }
		public Dictionary<string,object> Args { get; set; }
	}

	public class Response
	{
		public string GUID { get; set; }
		public string EventKey { get; set; }
		public int CreatedAt { get; set; }
		public int StatusCode { get; set; }
		public string Message { get; set; }
		public Dictionary<string,object>? AdditionalInfo { get; set; }
		public Dictionary<string,object>? GlobalVars { get; set; }
	}

	public class TwitchReward
	{
		public string Id { get; set; }
		public string Title { get; set; }

		// public string? Prompt { get; set; }
		// public int? Cost { get; set; }
		// public bool? InputRequired { get; set; }
		// public string? BackgroundColor { get; set; }
		// public bool? Paused { get; set; }
		// public bool? Enabled { get; set; }
		// public bool? IsOurs { get; set; } // Created through Streamer.bot
	}

	public class Vars
	{
		private const string TRUE_VALUE = "True";

		public Vars(Dictionary<string,object> args)
		{
			this.Args = args;
		}

		private Dictionary<string,object> Args
		{
			get; set;
		}

		private string getValue(string key)
		{
			if (!string.IsNullOrEmpty(key) && Args.ContainsKey(key))
				return Args[key].ToString();
			else
				return string.Empty;
		}

		// Broadcaster Variables
		public string BroadcastUser
		{
			get { return getValue("broadcastUser"); }
		}
		public string BroadcastUserName
		{
			get { return getValue("broadcastUserName"); }
		}
		public string BroadcastUserId
		{
			get { return getValue("broadcastUserId"); }
		}
		public bool BroadcastIsAffiliate
		{
			get { return getValue("broadcastIsAffiliate").Equals(TRUE_VALUE); }
		}
		public bool BroadcastIsPartner
		{
			get { return getValue("broadcastIsPartner").Equals(TRUE_VALUE); }
		}


		// Commands - https://wiki.streamer.bot/en/Triggers/Core/Commands/Command-Triggered
		// The command that was used
		public string Command
		{
			get { return getValue("command"); }
		}
		// The ID of the command
		public string CommandId
		{
			get { return getValue("commandId"); }
		}
		// The message entered, if the command/redeem was a Starts With, this will be removed
		public string RawInput
		{
			get { return getValue("rawInput"); }
		}
		// The message escaped
		public string RawInputEscaped
		{
			get { return getValue("rawInputEscaped"); }
		}
		// The message URL encoded
		public string RawInputUrlEncoded
		{
			get { return getValue("rawInputUrlEncoded"); }
		}
		// What role the user has (1-4); This doesn't appear to return anything other than an empty string
		// public string Role
		// {
		// 	get { return getValue("role"); }
		// }


		// Channel Point Rewards
		// String identifier for this redemption (used to refund reward) 4d9f236b-7486-481a-89af-1d03676d5275
		public string RedemptionId
		{
			get { return getValue("redemptionId"); }
		}
		// String identifier for this reward 44e86f71-8ace-4739-a123-3ff095489343
		public string RewardId
		{
			get { return getValue("rewardId"); }
		}
		// Name of the reward
		public string RewardName
		{
			get { return getValue("rewardName"); }
		}
		// The verbiage shown on the channel point description
		public string RewardPrompt
		{
			get { return getValue("rewardPrompt"); }
		}
		// The channel point cost of the redeemed reward
		public string RewardCost
		{
			get { return getValue("rewardCost"); }
		}
		// The user that had redeemed the channel point
		public string User
		{
			get { return getValue("user"); }
		}
		// User login name, e.g. on Twitch this is the username in all lowercase, useful for comparison
		public string UserName
		{
			get { return getValue("userName"); }
		}
		// Unique user identifier
		public string UserId
		{
			get { return getValue("userId"); }
		}
		// Specifies which streaming service the triggering user is coming from: twitch or youtube
		public string UserType
		{
			get { return getValue("userType"); }
		}
		// Boolean value indicating the sender's subscription status
		public bool IsSubscribed
		{
			get { return getValue("isSubscribed").Equals(TRUE_VALUE); }
		}
		// Boolean value indicating the sender's moderator status
		public bool IsModerator
		{
			get { return getValue("isModerator").Equals(TRUE_VALUE); }
		}
		// Boolean value indicating the sender's VIP status
		public bool IsVip
		{
			get { return getValue("isVip").Equals(TRUE_VALUE); }
		}
		// A running total of how many times a command/redeem has been run since application launch (if Persisted is checked, the total will be saved to settings.dat and read in at launch)
		public string Counter
		{
			get { return getValue("counter"); }
		}
		// A running total of how many times a command/redeem has been run by this chat user since application launch (if UserPersisted is checked, the total will be saved to settings.dat and read in at launch)
		public string UserCounter
		{
			get { return getValue("userCounter"); }
		}
	}
}
BattleStatusScreen = {

	viewingGeneralBattleInfo = false,
	viewingIndividualStatuses = false,
	viewingSideStauses = false,
	viewedMonIndex = 0,
	effectMonIndex = -1,
	viewedSideIndex = 0,
	currentPage = 1,
	numPages = 1,
	pageSize = 7,
	testing = true,

	BattleDetails = {
		Weather = "None",
		Terrain = "Building",
	},
	PerSideDetails = {
		[0] = {},
		[1] = {},
	},
	PerMonDetails = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	},
	TerrainNameMap = {
		[0] = "Grass",
		[1] = "Long Grass",
		[2] = "Sand",
		[3] = "Underwater",
		[4] = "Water",
		[5] = "Pond",
		[6] = "Mountain",
		[7] = "Cave",
		["default"] = "Building"
	},
	WeatherNameMap = {
		[0] = "Rain",
		[1] = "Rain",
		[2] = "Rain",
		[3] = "Sandstorm",
		[4] = "Sandstorm",
		[5] = "Sunlight",
		[6] = "Sunlight",
		[7] = "Hail",
		["default"] = "None"
	},
	PerMonNameMap = {

	},
	PerSideNameMap = {

	},
	Buttons = {
		[1] = { --LeftOwn
			type = Constants.ButtonTypes.NO_BORDER,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102, Constants.SCREEN.MARGIN + 37, 11, 11 },
			boxColors = {"Upper box border", "Upper box background"},
			isVisible = function() return true end,
			onClick = function(self)
				if BattleStatusScreen.viewingIndividualStatuses and BattleStatusScreen.viewedMonIndex == 0 then return end
				BattleStatusScreen.viewingIndividualStatuses = true
				BattleStatusScreen.viewingSideStauses = false
				BattleStatusScreen.viewedMonIndex = 0
				Program.redraw(true)
			end
		},
		[2] = { --LeftOther
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 123, Constants.SCREEN.MARGIN + 22, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				if BattleStatusScreen.viewingIndividualStatuses and BattleStatusScreen.viewedMonIndex == 1 then return end
				BattleStatusScreen.viewingIndividualStatuses = true
				BattleStatusScreen.viewingSideStauses = false
				BattleStatusScreen.viewedMonIndex = 1
				Program.redraw(true)
			end
		},
		[3] = { --RightOwn
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 37, 11, 11 },
			isVisible = function() return Battle.numBattlers == 4 end,
			onClick = function(self)
				if BattleStatusScreen.viewingIndividualStatuses and BattleStatusScreen.viewedMonIndex == 2 then return end
				BattleStatusScreen.viewingIndividualStatuses = true
				BattleStatusScreen.viewingSideStauses = false
				BattleStatusScreen.viewedMonIndex = 2
				Program.redraw(true)
			end
		},
		[4] = { --RightOther
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 110, Constants.SCREEN.MARGIN + 22, 11, 11 },
			isVisible = function() return Battle.numBattlers == 4 end,
			onClick = function(self)
				if BattleStatusScreen.viewingIndividualStatuses and BattleStatusScreen.viewedMonIndex == 3 then return end
				BattleStatusScreen.viewingIndividualStatuses = true
				BattleStatusScreen.viewingSideStauses = false
				BattleStatusScreen.viewedMonIndex = 3
				Program.redraw(true)
			end
		},
		[5] = { --Ally Team
			type = Constants.ButtonTypes.FULL_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 35, 36, 15 },
			isVisible = function() return true end,
			onClick = function(self)
				if BattleStatusScreen.viewingSideStauses and BattleStatusScreen.viewedSideIndex == 0 then return end
				BattleStatusScreen.viewingIndividualStatuses = false
				BattleStatusScreen.viewingSideStauses = true
				BattleStatusScreen.viewedSideIndex = 0
				Program.redraw(true)
			end
		},
		[6] = { -- Enemy Team
			type = Constants.ButtonTypes.FULL_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 20, 36, 15 },
			isVisible = function() return true end,
			onClick = function(self)
				if BattleStatusScreen.viewingSideStauses and BattleStatusScreen.viewedSideIndex == 1 then return end
				BattleStatusScreen.viewingIndividualStatuses = false
				BattleStatusScreen.viewingSideStauses = true
				BattleStatusScreen.viewedSideIndex = 1
				Program.redraw(true)
			end
		},
		[7] = { -- Entire Battle
			type = Constants.ButtonTypes.FULL_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 90, Constants.SCREEN.MARGIN + 20, 46, 30},
			isVisible = function() return true end,
			onClick = function(self)
				if not BattleStatusScreen.viewingSideStauses and not BattleStatusScreen.viewingIndividualStatuses then return end
				BattleStatusScreen.viewingIndividualStatuses = false
				BattleStatusScreen.viewingSideStauses = false
				BattleStatusScreen.viewedSideIndex = 0
				BattleStatusScreen.viewedMonIndex = 0
				Program.redraw(true)
			end
		},
		[8] = { --PageLeft
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 37, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				BattleStatusScreen.currentPage = BattleStatusScreen.currentPage - 1
				Program.redraw(true)
			end
		},
		[9] = { --PageRight
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 37, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				BattleStatusScreen.currentPage = BattleStatusScreen.currentPage + 1
				Program.redraw(true)
			end
		},
		[10] = { --Back
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Back",
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				Program.changeScreenView(TrackerScreen)
			end
		},
	},
	Constants = {
	}
}

function loadTerrain()
	--[[
		gBattleTerrain
		#define BATTLE_TERRAIN_GRASS        0
		#define BATTLE_TERRAIN_LONG_GRASS   1
		#define BATTLE_TERRAIN_SAND         2
		#define BATTLE_TERRAIN_UNDERWATER   3
		#define BATTLE_TERRAIN_WATER        4
		#define BATTLE_TERRAIN_POND         5
		#define BATTLE_TERRAIN_MOUNTAIN     6
		#define BATTLE_TERRAIN_CAVE         7
		#define BATTLE_TERRAIN_BUILDING     8
	]]
	local battleTerrain = Memory.readbyte(0x02022ff0)
	local terrainText = BattleStatusScreen.TerrainNameMap[battleTerrain]
	BattleStatusScreen.BattleDetails.Terrain = Utils.inlineIf(terrainText ~= nil,terrainText, BattleStatusScreen.TerrainNameMap["default"])
end

function loadWeather()
	--[[
		gBattleWeather
		#define B_WEATHER_RAIN_TEMPORARY      (1 << 0)
		#define B_WEATHER_RAIN_DOWNPOUR       (1 << 1)
		#define B_WEATHER_RAIN_PERMANENT      (1 << 2)
		#define B_WEATHER_SANDSTORM_TEMPORARY (1 << 3)
		#define B_WEATHER_SANDSTORM_PERMANENT (1 << 4)
		#define B_WEATHER_SUN_TEMPORARY       (1 << 5)
		#define B_WEATHER_SUN_PERMANENT       (1 << 6)
		#define B_WEATHER_HAIL_TEMPORARY      (1 << 7)
	]]
	local weatherByte = Memory.readbyte(0x020243cc)
	local weatherTurns = Memory.readbyte(0x020242bc + 0x28)

	if weatherByte == 0 then
		BattleStatusScreen.BattleDetails.Weather = BattleStatusScreen.WeatherNameMap["default"]
		BattleStatusScreen.BattleDetails.WeatherTurns = nil
	else
		local weatherBitIndex = 0
		while weatherByte > 1 do
			weatherByte = Utils.bit_rshift(weatherByte, 1)
			weatherBitIndex = weatherBitIndex + 1
		end
		local weatherText = BattleStatusScreen.WeatherNameMap[weatherBitIndex]
		BattleStatusScreen.BattleDetails.Weather = Utils.inlineIf(weatherText ~= nil,weatherText, BattleStatusScreen.WeatherNameMap["default"])
		BattleStatusScreen.BattleDetails.WeatherTurns = weatherTurns
	end
end

function loadStatus2(index)
	--[[
		GameSettings.gBattleMons + 0x50
		#define STATUS2_CONFUSION             (1 << 0 | 1 << 1 | 1 << 2)
		#define STATUS2_FLINCHED              (1 << 3)
		#define STATUS2_UPROAR                (1 << 4 | 1 << 5 | 1 << 6)
		#define STATUS2_UNUSED                (1 << 7)
		#define STATUS2_BIDE                  (1 << 8 | 1 << 9)
		#define STATUS2_LOCK_CONFUSE          (1 << 10 | 1 << 11) // e.g. Thrash
		#define STATUS2_MULTIPLETURNS         (1 << 12)
		#define STATUS2_WRAPPED               (1 << 13 | 1 << 14 | 1 << 15)
		#define STATUS2_INFATUATION           (1 << 16 | 1 << 17 | 1 << 18 | 1 << 19)  // 4 bits, one for every battler
		#define STATUS2_FOCUS_ENERGY          (1 << 20)
		#define STATUS2_TRANSFORMED           (1 << 21)
		#define STATUS2_RECHARGE              (1 << 22)
		#define STATUS2_RAGE                  (1 << 23)
		#define STATUS2_SUBSTITUTE            (1 << 24)
		#define STATUS2_DESTINY_BOND          (1 << 25)
		#define STATUS2_ESCAPE_PREVENTION     (1 << 26)
		#define STATUS2_NIGHTMARE             (1 << 27)
		#define STATUS2_CURSED                (1 << 28)
		#define STATUS2_FORESIGHT             (1 << 29)
		#define STATUS2_DEFENSE_CURL          (1 << 30)
		#define STATUS2_TORMENT               (1 << 31)
	]]--
	if index == nil or index < 0 or index > 3 then
		return
	end
	local status2Data = Memory.readdword(GameSettings.gBattleMons + (index * 0x58) +0x50)
	local status2Map = Utils.generatebitwisemap(status2Data, 32)
	if status2Map[0] or status2Map[1] or status2Map[2] then
		if BattleStatusScreen.PerMonDetails[index]["Confused"] then
			BattleStatusScreen.PerMonDetails[index]["Confused"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Confused"] = {active=true}
		end
	end
	if status2Map[4] or status2Map[5] or status2Map[6] then
		if BattleStatusScreen.PerMonDetails[index]["Uproar"] then
			BattleStatusScreen.PerMonDetails[index]["Uproar"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Uproar"] = {active=true}
		end
	end
	if status2Map[8] or status2Map[9] then
		local remainingTurnsBide = (Utils.inlineIf(status2Map[8],1,0) + Utils.inlineIf(status2Map[9],2,0))
		if BattleStatusScreen.PerMonDetails[index]["Bide"] then
			BattleStatusScreen.PerMonDetails[index]["Bide"].active=true
			BattleStatusScreen.PerMonDetails[index]["Bide"].remainingTurns=remainingTurnsBide
		else
			BattleStatusScreen.PerMonDetails[index]["Bide"] = {active=true, remainingTurns=remainingTurnsBide}
		end
	end
	if status2Map[12] then
		if BattleStatusScreen.PerMonDetails[index]["Locked Into Attack"] then
			BattleStatusScreen.PerMonDetails[index]["Locked Into Attack"].active=true
			BattleStatusScreen.PerMonDetails[index]["Locked Into Attack"].remainingTurns=1
		else
			BattleStatusScreen.PerMonDetails[index]["Locked Into Attack"] = {active=true, remainingTurns=1}
		end
	end
	if status2Map[13] or status2Map[14] or status2Map[15] then
		if BattleStatusScreen.PerMonDetails[index]["Trapping Move"] then
			BattleStatusScreen.PerMonDetails[index]["Trapping Move"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Trapping Move"] = {active=true}
		end
	end
	if status2Map[16] or status2Map[17] or status2Map[18] or status2Map[19] then
		local infatuationTarget = Utils.inlineIf(status2Map[16],0,nil) or Utils.inlineIf(status2Map[17],1,nil) or Utils.inlineIf(status2Map[18],2,nil) or Utils.inlineIf(status2Map[19],3,0)
		if BattleStatusScreen.PerMonDetails[index]["Attract"] then
			BattleStatusScreen.PerMonDetails[index]["Attract"].active=true
			BattleStatusScreen.PerMonDetails[index]["Attract"].source=infatuationTarget
		else
			BattleStatusScreen.PerMonDetails[index]["Attract"] = {active=true, source=infatuationTarget}
		end
	end
	if status2Map[20] then
		if BattleStatusScreen.PerMonDetails[index]["Focus Energy"] then
			BattleStatusScreen.PerMonDetails[index]["Focus Energy"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Focus Energy"] = {active=true}
		end
	end
	if status2Map[21] then
		if BattleStatusScreen.PerMonDetails[index]["Transform"] then
			BattleStatusScreen.PerMonDetails[index]["Transform"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Transform"] = {active=true}
		end
	end
	if status2Map[22] then
		if BattleStatusScreen.PerMonDetails[index]["Charge Move Cooldown"] then
			BattleStatusScreen.PerMonDetails[index]["Charge Move Cooldown"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Charge Move Cooldown"] = {active=true}
		end
	end
	if status2Map[23] then
		if BattleStatusScreen.PerMonDetails[index]["Rage"] then
			BattleStatusScreen.PerMonDetails[index]["Rage"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Rage"] = {active=true}
		end
	end
	if status2Map[24] then
		if BattleStatusScreen.PerMonDetails[index]["Substitute"] then
			BattleStatusScreen.PerMonDetails[index]["Substitute"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Substitute"] = {active=true}
		end
	end
	if status2Map[25] then
		if BattleStatusScreen.PerMonDetails[index]["Destiny Bond"] then
			BattleStatusScreen.PerMonDetails[index]["Destiny Bond"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Destiny Bond"] = {active=true}
		end
	end
	if status2Map[26] then
		if BattleStatusScreen.PerMonDetails[index]["Cannot Escape"] then
			BattleStatusScreen.PerMonDetails[index]["Cannot Escape"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Cannot Escape"] = {active=true}
		end
	end
	if status2Map[27] then
		if BattleStatusScreen.PerMonDetails[index]["Nightmare"] then
			BattleStatusScreen.PerMonDetails[index]["Nightmare"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Nightmare"] = {active=true}
		end
	end
	if status2Map[28] then
		if BattleStatusScreen.PerMonDetails[index]["Curse"] then
			BattleStatusScreen.PerMonDetails[index]["Curse"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Curse"] = {active=true}
		end
	end
	if status2Map[29] then
		if BattleStatusScreen.PerMonDetails[index]["Foresight"] then
			BattleStatusScreen.PerMonDetails[index]["Foresight"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Foresight"] = {active=true}
		end
	end
	if status2Map[30] then
		if BattleStatusScreen.PerMonDetails[index]["Defense Curl"] then
			BattleStatusScreen.PerMonDetails[index]["Defense Curl"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Defense Curl"] = {active=true}
		end
	end
	if status2Map[31] then
		if BattleStatusScreen.PerMonDetails[index]["Torment"] then
			BattleStatusScreen.PerMonDetails[index]["Torment"].active=true
		else
			BattleStatusScreen.PerMonDetails[index]["Torment"] = {active=true}
		end
	end
end

function loadStatus3(index)
	--[[
		gStatuses3
		#define STATUS3_LEECHSEED_BATTLER       (1 << 0 | 1 << 1) // The battler to receive HP from Leech Seed
		#define STATUS3_LEECHSEED               (1 << 2)
		#define STATUS3_ALWAYS_HITS             (1 << 3 | 1 << 4)
		#define STATUS3_PERISH_SONG             (1 << 5)
		#define STATUS3_ON_AIR                  (1 << 6)
		#define STATUS3_UNDERGROUND             (1 << 7)
		#define STATUS3_MINIMIZED               (1 << 8)
		#define STATUS3_CHARGED_UP              (1 << 9)
		#define STATUS3_ROOTED                  (1 << 10)
		#define STATUS3_YAWN                    (1 << 11 | 1 << 12) // Number of turns to sleep
		#define STATUS3_YAWN_TURN(num)          (((num) << 11) & STATUS3_YAWN)
		#define STATUS3_IMPRISONED_OTHERS       (1 << 13)
		#define STATUS3_GRUDGE                  (1 << 14)
		#define STATUS3_CANT_SCORE_A_CRIT       (1 << 15)
		#define STATUS3_MUDSPORT                (1 << 16)
		#define STATUS3_WATERSPORT              (1 << 17)
		#define STATUS3_UNDERWATER              (1 << 18)
		#define STATUS3_TRACE                   (1 << 20)
	]]--
	if index == nil or index < 0 or index > 3 then
		return
	end
	local status3Data = Memory.readdword(0x020242ac + index * (0x04))
	local status3Map = Utils.generatebitwisemap(status3Data, 21)
	if status3Map[2] then
		local leechSeedSource = (Utils.inlineIf(status3Map[0],1,0) + Utils.inlineIf(status3Map[1],2,0))
		if BattleStatusScreen.PerMonDetails[index]["Leech Seed"] then
			BattleStatusScreen.PerMonDetails[index]["Leech Seed"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Leech Seed"] = {active=true}
		end
	end
	if status3Map[3] or status3Map[4] then
		if BattleStatusScreen.PerMonDetails[index]["Lock On"] then
			BattleStatusScreen.PerMonDetails[index]["Lock On"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Lock On"] = {active=true}
		end
	end
	--[[if status3Map[5] then
		if BattleStatusScreen.PerMonDetails[index]["Perish Song"] then
			BattleStatusScreen.PerMonDetails[index]["Perish Song"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Perish Song"] = {active=true}
		end
	end]]--
	if status3Map[6] or status3Map[7] or status3Map[18] then
		local invulnerableType = Utils.inlineIf(status3Map[6],"Airborne",nil) or Utils.inlineIf(status3Map[7],"Underground",nil) or Utils.inlineIf(status3Map[18],"Underwater","")
		print (invulnerableType)
		if BattleStatusScreen.PerMonDetails[index]["Semi Invulnerable"] then
			BattleStatusScreen.PerMonDetails[index]["Semi Invulnerable"].active = true
			BattleStatusScreen.PerMonDetails[index]["Semi Invulnerable"].type = invulnerableType
		else
			BattleStatusScreen.PerMonDetails[index]["Semi Invulnerable"] = {active=true, type = invulnerableType}
		end
	end
	if status3Map[8] then
		if BattleStatusScreen.PerMonDetails[index]["Minimize"] then
			BattleStatusScreen.PerMonDetails[index]["Minimize"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Minimize"] = {active=true}
		end
	end
	if status3Map[9] then
		if BattleStatusScreen.PerMonDetails[index]["Charge"] then
			BattleStatusScreen.PerMonDetails[index]["Charge"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Charge"] = {active=true}
		end
	end
	if status3Map[10] then
		if BattleStatusScreen.PerMonDetails[index]["Ingrain"] then
			BattleStatusScreen.PerMonDetails[index]["Ingrain"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Ingrain"] = {active=true}
		end
	end
	if status3Map[11] or status3Map[12] then
		if BattleStatusScreen.PerMonDetails[index]["Drowsy"] then
			BattleStatusScreen.PerMonDetails[index]["Drowsy"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Drowsy"] = {active=true}
		end
	end
	if status3Map[13] then
		if BattleStatusScreen.PerMonDetails[index]["Imprison"] then
			BattleStatusScreen.PerMonDetails[index]["Imprison"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Imprison"] = {active=true}
		end
	end
	if status3Map[14] then
		if BattleStatusScreen.PerMonDetails[index]["Grudge"] then
			BattleStatusScreen.PerMonDetails[index]["Grudge"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Grudge"] = {active=true}
		end
	end
	if status3Map[16] then
		if BattleStatusScreen.BattleDetails["Mud Sport"] then
			BattleStatusScreen.BattleDetails["Mud Sport"].active = true
		else
			BattleStatusScreen.BattleDetails["Mud Sport"] = {active=true}
		end
		local sources = BattleStatusScreen.BattleDetails["Mud Sport"].sources
		if sources then
			sources[index] = true
		else
			sources = {index = true}
		end
	end
	if status3Map[17] then
		if BattleStatusScreen.BattleDetails["Water Sport"] then
			BattleStatusScreen.BattleDetails["Water Sport"].active = true
		else
			BattleStatusScreen.BattleDetails["Water Sport"] = {active=true}
		end
		local sources = BattleStatusScreen.BattleDetails["Water Sport"].sources
		if sources then
			sources[index] = true
		else
			sources = {index = true}
		end
	end
end

function loadSideStatuses(index)
	--[[
	gSideStatuses[2] (0x02)

	#define SIDE_STATUS_REFLECT          (1 << 0)
	#define SIDE_STATUS_LIGHTSCREEN      (1 << 1)
	#define SIDE_STATUS_X4               (1 << 2)
	#define SIDE_STATUS_SPIKES           (1 << 4)
	#define SIDE_STATUS_SAFEGUARD        (1 << 5)
	#define SIDE_STATUS_FUTUREATTACK     (1 << 6)
	#define SIDE_STATUS_MIST             (1 << 8)
	#define SIDE_STATUS_SPIKES_DAMAGED   (1 << 9)

	gSideTimers[2] (0x0B)
	{
		/*0x00*/ u8 reflectTimer;
		/*0x01*/ u8 reflectBattlerId;
		/*0x02*/ u8 lightscreenTimer;
		/*0x03*/ u8 lightscreenBattlerId;
		/*0x04*/ u8 mistTimer;
		/*0x05*/ u8 mistBattlerId;
		/*0x06*/ u8 safeguardTimer;
		/*0x07*/ u8 safeguardBattlerId;
		/*0x08*/ u8 followmeTimer;
		/*0x09*/ u8 followmeTarget;
		/*0x0A*/ u8 spikesAmount;
		/*0x0B*/ u8 fieldB;
	};
	]]--
	if index == nil or index < 0 or index > 1 then
		return
	end
	--local sideStatuses = Memory.readword(0x0202428e + (index * 0x02))
	local sideStatuses = 65535
	local sideTimersBase = 0x02024294 + (index * 0x0C)
	local sideStatusMap = Utils.generatebitwisemap(sideStatuses, 8)
	if sideStatusMap[0] then
		local turnsLeftReflect = Memory.readbyte(sideTimersBase)
		BattleStatusScreen.PerSideDetails[0]["Reflect"] = {active = true,turnsLeft = turnsLeftReflect}
	end
	if sideStatusMap[1] then
		local turnsLeftLightScreen = Memory.readbyte(sideTimersBase + 0x02)
		BattleStatusScreen.PerSideDetails[0]["Light Screen"] = {active = true,turnsLeft = turnsLeftLightScreen}
	end
	if sideStatusMap[4] then
		local amountSpikes = Memory.readbyte(sideTimersBase + 0x0A)
		BattleStatusScreen.PerSideDetails[0]["Spikes"] = {active = true,count = amountSpikes}
	end
	if sideStatusMap[5] then
		local turnsLeftSafeguard = Memory.readbyte(sideTimersBase + 0x06)
		BattleStatusScreen.PerSideDetails[0]["Safeguard"] = {active = true,turnsLeft = turnsLeftSafeguard}
	end
	if sideStatusMap[8] then
		local turnsLeftMist = Memory.readbyte(sideTimersBase + 0x04)
		BattleStatusScreen.PerSideDetails[0]["Mist"] = {active = true,turnsLeft = turnsLeftMist}
	end
end

function loadDisableStruct(index)
	--[[
		gDisableStructs
		/*0x00*/ u32 transformedMonPersonality;
		/*0x04*/ u16 disabledMove;
		/*0x06*/ u16 encoredMove;
		/*0x08*/ u8 protectUses;
		/*0x09*/ u8 stockpileCounter;
		/*0x0A*/ u8 substituteHP;
		/*0x0B*/ u8 disableTimer : 4;
		/*0x0B*/ u8 disableTimerStartValue : 4;
		/*0x0C*/ u8 encoredMovePos;
		/*0x0D*/ u8 unkD;
		/*0x0E*/ u8 encoreTimer : 4;
		/*0x0E*/ u8 encoreTimerStartValue : 4;
		/*0x0F*/ u8 perishSongTimer : 4;
		/*0x0F*/ u8 perishSongTimerStartValue : 4;
		/*0x10*/ u8 furyCutterCounter;
		/*0x11*/ u8 rolloutTimer : 4;
		/*0x11*/ u8 rolloutTimerStartValue : 4;
		/*0x12*/ u8 chargeTimer : 4;
		/*0x12*/ u8 chargeTimerStartValue : 4;
		/*0x13*/ u8 tauntTimer:4;
		/*0x13*/ u8 tauntTimer2:4;
		/*0x14*/ u8 battlerPreventingEscape;
		/*0x15*/ u8 battlerWithSureHit;
		/*0x16*/ u8 isFirstTurn;
		/*0x17*/ u8 unk17;
		/*0x18*/ u8 truantCounter : 1;
		/*0x18*/ u8 truantSwitchInHack : 1; // Unused here, but used in pokeemerald
		/*0x18*/ u8 unk18_a_2 : 2;
		/*0x18*/ u8 mimickedMoves : 4;
		/*0x19*/ u8 rechargeTimer;
		/*0x1A*/ u8 unk1A[2];
	]]
	if index == nil or index < 0 or index > 3 then
		return
	end
	local disableStructBase = 0x020242bc + (index * 0x1B)
	local disabledMove = Memory.readword(disableStructBase + 0x04)
	if disabledMove ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Disable"] then
			BattleStatusScreen.PerMonDetails[index]["Disable"].active = true
			BattleStatusScreen.PerMonDetails[index]["Disable"].move = disabledMove
		else
			BattleStatusScreen.PerMonDetails[index]["Disable"] = {active = true, move = disabledMove}
		end
	end
	local encoredMove = Memory.readword(disableStructBase + 0x06)
	if encoredMove ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Encore"] then
			BattleStatusScreen.PerMonDetails[index]["Encore"].active = true
			BattleStatusScreen.PerMonDetails[index]["Encore"].move = encoredMove
		else
			BattleStatusScreen.PerMonDetails[index]["Encore"] = {active = true, move = encoredMove}
		end
	end
	local protectUses = Memory.readbyte(disableStructBase + 0x08)
	if protectUses ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Protect Uses"] then
			BattleStatusScreen.PerMonDetails[index]["Protect Uses"].active = true
			BattleStatusScreen.PerMonDetails[index]["Protect Uses"].count = protectUses
		else
			BattleStatusScreen.PerMonDetails[index]["Protect Uses"] = {active = true, count = protectUses}
		end
	end
	local stockpileCount = Memory.readbyte(disableStructBase + 0x09)
	if stockpileCount ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Stockpile"] then
			BattleStatusScreen.PerMonDetails[index]["Stockpile"].active = true
			BattleStatusScreen.PerMonDetails[index]["Stockpile"].count = stockpileCount
		else
			BattleStatusScreen.PerMonDetails[index]["Stockpile"] = {active = true, count = stockpileCount}
		end
	end
	local perishSongCount = Utils.getbits(Memory.readword(disableStructBase + 0x0F),0,4)
	if perishSongCount ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Perish Song"] then
			BattleStatusScreen.PerMonDetails[index]["Perish Song"].active = true
			BattleStatusScreen.PerMonDetails[index]["Perish Song"].count = perishSongCount
		else
			BattleStatusScreen.PerMonDetails[index]["Perish Song"] = {active = true, count = perishSongCount}
		end
	end
	local furyCutterCount = Memory.readword(disableStructBase + 0x10)
	if furyCutterCount ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Fury Cutter"] then
			BattleStatusScreen.PerMonDetails[index]["Fury Cutter"].active = true
			BattleStatusScreen.PerMonDetails[index]["Fury Cutter"].count = furyCutterCount
		else
			BattleStatusScreen.PerMonDetails[index]["Fury Cutter"] = {active = true, count = furyCutterCount}
		end
	end
	local rolloutCount = Utils.getbits(Memory.readword(disableStructBase + 0x11),0,4)
	if rolloutCount ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Rollout"] then
			BattleStatusScreen.PerMonDetails[index]["Rollout"].active = true
			BattleStatusScreen.PerMonDetails[index]["Rollout"].count = rolloutCount
		else
			BattleStatusScreen.PerMonDetails[index]["Rollout"] = {active = true, count = rolloutCount}
		end
	end
	local tauntTimer = Utils.getbits(Memory.readword(disableStructBase + 0x13),0,4)
	if tauntTimer ~= 0 then
		if BattleStatusScreen.PerMonDetails[index]["Taunt"] then
			BattleStatusScreen.PerMonDetails[index]["Taunt"].active = true
			BattleStatusScreen.PerMonDetails[index]["Taunt"].remainingTurns = tauntTimer
		else
			BattleStatusScreen.PerMonDetails[index]["Taunt"] = {active = true, remainingTurns = tauntTimer}
		end
	end
	local cannotEscapeSource = Memory.readbyte(disableStructBase + 0x14)
	if BattleStatusScreen.PerMonDetails[index]["Cannot Escape"] then
		BattleStatusScreen.PerMonDetails[index]["Cannot Escape"].source = cannotEscapeSource
	end
	local lockOnSource = Memory.readbyte(disableStructBase + 0x15)
	if BattleStatusScreen.PerMonDetails[index]["Lock On"] then
		BattleStatusScreen.PerMonDetails[index]["Lock On"].source = lockOnSource
	end
	local truantCheck = Memory.readbyte(disableStructBase + 0x18)
	if truantCheck % 1 == 1 then
		if BattleStatusScreen.PerMonDetails[index]["Loafing"] then
			BattleStatusScreen.PerMonDetails[index]["Loafing"].active = true
		else
			BattleStatusScreen.PerMonDetails[index]["Loafing"] = {active = true}
		end
	end
end

function loadWishStruct(index)
	--[[
		gWishFutureKnock
		struct WishFutureKnock
		{
			u8 futureSightCounter[MAX_BATTLERS_COUNT];
			u8 futureSightAttacker[MAX_BATTLERS_COUNT];
			s32 futureSightDmg[MAX_BATTLERS_COUNT];
			u16 futureSightMove[MAX_BATTLERS_COUNT];
			u8 wishCounter[MAX_BATTLERS_COUNT];
			u8 wishMonId[MAX_BATTLERS_COUNT];
			u8 weatherDuration;
			u8 knockedOffMons[2];
		};
	]]
	if index == nil or index < 0 or index > 3 then
		return
	end
	local wishStructBase = 0x020242bc
	local futureSightCounter = Memory.readbyte(wishStructBase + (index * 0x1))
	if futureSightCounter ~= 0 then
		local futureSightSource = Memory.readbyte(wishStructBase + 0x04 + (index * 0x1))
		if BattleStatusScreen.PerMonDetails[index]["Future Sight"] then
			BattleStatusScreen.PerMonDetails[index]["Future Sight"].source = futureSightSource
			BattleStatusScreen.PerMonDetails[index]["Future Sight"].remainingTurns = futureSightCounter
		else
			BattleStatusScreen.PerMonDetails[index]["Future Sight"] = {source = futureSightSource, remainingTurns = futureSightCounter}
		end
	end
	local wishCounter = Memory.readbyte(wishStructBase + 0x20 + (index * 0x1))
	if wishCounter ~= 0 then
		local wishSource = Memory.readbyte(wishStructBase + 0x24 + (index * 0x1))
		if BattleStatusScreen.PerMonDetails[index]["Wish"] then
			BattleStatusScreen.PerMonDetails[index]["Wish"].source = wishSource
			BattleStatusScreen.PerMonDetails[index]["Wish"].remainingTurns = wishCounter
		else
			BattleStatusScreen.PerMonDetails[index]["Wish"] = {source = wishSource, remainingTurns = wishCounter}
		end
	end
end

function BattleStatusScreen.loadData()
	print("loading battle effects")
	BattleStatusScreen.resetBattleDetails()
	loadTerrain()
	loadWeather()
	for i=0,Battle.numBattlers,1 do
		loadStatus2(i)
		loadStatus3(i)
		loadSideStatuses(i)
		loadDisableStruct(i)
		loadWishStruct(i)
	end
end

function BattleStatusScreen.resetBattleDetails()
	BattleStatusScreen.BattleDetails = {
		Weather = "None",
		Terrain = "Building",
	}
	BattleStatusScreen.PerSideDetails = {
		[0] = {},
		[1] = {},
	}
	BattleStatusScreen.PerMonDetails = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	}
	BattleStatusScreen.viewedMonIndex = 0
	BattleStatusScreen.viewedSideIndex = 0
	BattleStatusScreen.effectMonIndex = -1
	BattleStatusScreen.viewingIndividualStatuses = true
	BattleStatusScreen.viewingSideStauses = false
	BattleStatusScreen.viewingGeneralBattleInfo = false

	BattleStatusScreen.currentPage = 1
	BattleStatusScreen.numPages = 1
end

function drawTitle()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local offsetY = Constants.SCREEN.MARGIN
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS["Default text"]
	local defaultArrowColorList = {Theme.COLORS["Default text"]}
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS["Upper box background"])

	local screenTitle = "BATTLE EFFECTS"

	--Background
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, bottomEdge, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	--Header
	Drawing.drawText(offsetX, offsetY, screenTitle, textColor, nil, 15, Constants.Font.FAMILY)
	offsetY = offsetY + 15
	offsetX = offsetX + 2

	--Battle scope details
	Drawing.drawText(offsetX,offsetY, "Terrain: " .. BattleStatusScreen.BattleDetails.Terrain, textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing
	Drawing.drawText(offsetX,offsetY, "Weather: " .. BattleStatusScreen.BattleDetails.Weather, textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY - linespacing - linespacing + 33

	local prefix = "Allied"
	local suffix = "Team"
	if BattleStatusScreen.viewingIndividualStatuses then
		if BattleStatusScreen.viewedMonIndex % 2 == 1 then
			prefix = "Enemy"
		end
		suffix = "Mon"
	elseif not BattleStatusScreen.viewingSideStauses then
	 	prefix = "Field"
		suffix = ""
	elseif BattleStatusScreen.viewedSideIndex % 2 == 1 then
		prefix = "Enemy"
	end
	Drawing.drawText(offsetX,offsetY, prefix .. " " .. suffix, textColor, nil, 12, Constants.Font.FAMILY, "bold")
end

function drawBattleDetailsUI()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 50
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS["Default text"]
	local linesOnPage = 0

	local Xdelta = 2
	local allBattleStatuses = BattleStatusScreen.BattleDetails
	for key, value in pairs(allBattleStatuses) do
		if key ~= "Weather" and key ~= "Terrain" and key ~= "WeatherTurns" and value.active then
			Drawing.drawText(offsetX,offsetY, key, textColor, nil, linespacing, Constants.Font.FAMILY)
			offsetY = offsetY + linespacing + 1
			linesOnPage = linesOnPage + 1
		end
		if linesOnPage == BattleStatusScreen.pageSize then break end
	end
end

function drawPerSideUI()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 50
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS["Default text"]

	local allSideStatuses = BattleStatusScreen.PerSideDetails[BattleStatusScreen.viewedSideIndex]

	local Xdelta = 2
	if BattleStatusScreen.testing == true then
		allSideStatuses = {}
	else
		for key, value in pairs(allSideStatuses) do
			local text = "- " .. key
			if value.active then
				if value.type then
					text = text .. " (" .. value.type .. ")"
				elseif value.move and MoveData.isValid(value.move) then
					text = text .. " (" .. MoveData.Moves[value.move] .. ")"
				elseif value.count then
					text = text .. ": " .. value.count
				elseif value.remainingTurns then
					text = text .. ": Turn " .. value.remainingTurns
				end
				Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
				Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
				offsetY = offsetY + linespacing + 1
				linesOnPage = linesOnPage + 1
			end
			if linesOnPage == BattleStatusScreen.pageSize then break end
		end
	end
end

function drawPerMonUI()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 50
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS["Default text"]
	local linesOnPage = 0

	local Xdelta = 2
	local allMonStatuses = BattleStatusScreen.PerMonDetails[BattleStatusScreen.viewedMonIndex]
	for key, value in pairs(allMonStatuses) do
		local text = "- " .. key
		if value.active then
			if value.type then
				text = text .. " (" .. value.type .. ")"
			elseif value.move and MoveData.isValid(value.move) then
				text = text .. " (" .. MoveData.Moves[value.move] .. ")"
			elseif value.count then
				text = text .. ": " .. value.count
			elseif value.remainingTurns then
				text = text .. ": Turn " .. value.remainingTurns
			end
			Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
			Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
			offsetY = offsetY + linespacing + 1
			linesOnPage = linesOnPage + 1
		end
		if linesOnPage == BattleStatusScreen.pageSize then break end
	end
end

function drawBattleDiagram()
	local ballColorList = { 0xFF000000, 0xFFF04037, 0xFFFFFFFF, }
	local defaultArrowColorList = {Theme.COLORS["Default text"]}
	local selectedArrowColorList = {Theme.COLORS["Positive text"]}

	--Draw battle box first so team box is highlighted properly
	if BattleStatusScreen.viewingSideStauses or BattleStatusScreen.viewingIndividualStatuses then
		BattleStatusScreen.Buttons[7].boxColors = {"Upper box border", 0x00000000}
		Drawing.drawButton(BattleStatusScreen.Buttons[7])
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleStatusScreen.Buttons[7].box[1] + 3, BattleStatusScreen.Buttons[7].box[2] + 11, defaultArrowColorList, null)
	end
	--Draw Buttons
	if BattleStatusScreen.viewingSideStauses then
		BattleStatusScreen.Buttons[5+((BattleStatusScreen.viewedSideIndex)%2)].boxColors = {"Positive text", "Upper box background"}
		BattleStatusScreen.Buttons[5+((BattleStatusScreen.viewedSideIndex + 1)%2)].boxColors = {"Upper box border", "Upper box background"}
		Drawing.drawButton(BattleStatusScreen.Buttons[5+((BattleStatusScreen.viewedSideIndex + 1)%2)])
		Drawing.drawButton(BattleStatusScreen.Buttons[5+((BattleStatusScreen.viewedSideIndex)%2)])
	else
		BattleStatusScreen.Buttons[5].boxColors = {"Upper box border", "Upper box background"}
		BattleStatusScreen.Buttons[6].boxColors = {"Upper box border", "Upper box background"}
		Drawing.drawButton(BattleStatusScreen.Buttons[5])
		Drawing.drawButton(BattleStatusScreen.Buttons[6])
	end
	Drawing.drawButton(BattleStatusScreen.Buttons[1])
	Drawing.drawButton(BattleStatusScreen.Buttons[2])
	Drawing.drawButton(BattleStatusScreen.Buttons[3])
	Drawing.drawButton(BattleStatusScreen.Buttons[4])
	if BattleStatusScreen.viewingSideStauses then
		if BattleStatusScreen.viewedSideIndex == 0 then
			Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleStatusScreen.Buttons[6].box[1] + 3, BattleStatusScreen.Buttons[6].box[2] + 3, defaultArrowColorList, null)
			Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, BattleStatusScreen.Buttons[5].box[1] + 29, BattleStatusScreen.Buttons[5].box[2] + 3, selectedArrowColorList, null)
		else
			Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, BattleStatusScreen.Buttons[5].box[1] + 29, BattleStatusScreen.Buttons[5].box[2] + 3, defaultArrowColorList, null)
			Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleStatusScreen.Buttons[6].box[1] + 3, BattleStatusScreen.Buttons[6].box[2] + 3, selectedArrowColorList, null)
		end
	elseif BattleStatusScreen.viewingIndividualStatuses then
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, BattleStatusScreen.Buttons[5].box[1] + 29, BattleStatusScreen.Buttons[5].box[2] + 3, defaultArrowColorList, null)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleStatusScreen.Buttons[6].box[1] + 3, BattleStatusScreen.Buttons[6].box[2] + 3, defaultArrowColorList, null)
		Drawing.drawSelectionIndicators(
			BattleStatusScreen.Buttons[BattleStatusScreen.viewedMonIndex+1].box[1],
			BattleStatusScreen.Buttons[BattleStatusScreen.viewedMonIndex+1].box[2],
			BattleStatusScreen.Buttons[BattleStatusScreen.viewedMonIndex+1].box[3],
			BattleStatusScreen.Buttons[BattleStatusScreen.viewedMonIndex+1].box[4], Theme.COLORS["Positive text"], 1, 3, 0)
	else
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, BattleStatusScreen.Buttons[5].box[1] + 29, BattleStatusScreen.Buttons[5].box[2] + 3, defaultArrowColorList, null)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleStatusScreen.Buttons[6].box[1] + 3, BattleStatusScreen.Buttons[6].box[2] + 3, defaultArrowColorList, null)
	end
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleStatusScreen.Buttons[1].box[1], BattleStatusScreen.Buttons[1].box[2], ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleStatusScreen.Buttons[2].box[1], BattleStatusScreen.Buttons[2].box[2], ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleStatusScreen.Buttons[3].box[1], BattleStatusScreen.Buttons[3].box[2], ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleStatusScreen.Buttons[4].box[1], BattleStatusScreen.Buttons[4].box[2], ballColorList, null)

	if not BattleStatusScreen.viewingSideStauses and not BattleStatusScreen.viewingIndividualStatuses then
		BattleStatusScreen.Buttons[7].boxColors = {"Positive text", 0x00000000}
		Drawing.drawButton(BattleStatusScreen.Buttons[7])
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleStatusScreen.Buttons[7].box[1] + 3, BattleStatusScreen.Buttons[7].box[2] + 11, selectedArrowColorList, null)
	end
end

function drawPaging()
	if BattleStatusScreen.numPages > 1 then
		if BattleStatusScreen.currentPage > 1 then
			Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, offsetX + 45, offsetY, defaultArrowColorList, null)
			--Drawing.drawButton(BattleStatusScreen.Buttons[8])
		end
		Drawing.drawText(offsetX + 54, offsetY - 3, BattleStatusScreen.currentPage .. "/" .. BattleStatusScreen.numPages, textColor, nil, linespacing, Constants.Font.FAMILY)
		if BattleStatusScreen.currentPage < BattleStatusScreen.numPages then
			Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, offsetX + 78, offsetY, defaultArrowColorList, null)
		end
	end
end

function BattleStatusScreen.drawScreen()
	if Battle.inBattle == false then
		BattleStatusScreen.Buttons[10].onClick()
		return
	end
	drawTitle()
	drawBattleDiagram()
	if BattleStatusScreen.viewingIndividualStatuses then
		drawPerMonUI()
	elseif BattleStatusScreen.viewingSideStauses then
		drawPerSideUI()
	else
		drawBattleDetailsUI()
	end
	drawPaging()
	Drawing.drawButton(BattleStatusScreen.Buttons[10])
end

function BattleStatusScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, BattleStatusScreen.Buttons, true)
end
--[[
Various passive battle situations
1) Environment (Sandstorm, Hail, Sun, Rain, Type of Floor)
2) Hazards (Spikes, Stealth Rock, Mud Sport, Water Sport)
3) Volatile Statuses (Harmful): (Confuse, Infatuation, Imprisoned, Bound. Cursed, Drowsy, Encored, Identified, Nightmared, Perish Songed, Seeded, Taunted, Tormented)
4) Volatile Statuses (Beneficial): (Aqua Ring, Focused[from Focus Energy], Rooted[Ingrain], Minimized, Recharging[Hyper Beam], Reflect, Light Screen)
5) Hardcoded details (Trainer Items, Pokemon Levels)

TODO:
Get Memory addresses
	- gBattleTerrain, gBattleWeather, gSideStatuses, gBattleMons[gActiveBattler].status2, gStatuses3, gWishFutureKnock
]]--
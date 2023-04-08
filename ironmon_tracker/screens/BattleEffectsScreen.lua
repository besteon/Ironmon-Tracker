BattleEffectsScreen = {

	viewingGeneralBattleInfo = false,
	viewingIndividualStatuses = true,
	viewingSideStauses = false,
	viewedMonIndex = 0,
	viewedSideIndex = 0;

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
	Status2NameMap = {
		[0] = {"Confused"}, --Confusion
		[1] = {"Confused"},
		[2] = {"Confused"},
		[3] = {"Flinched"}, --Flinch
		[4] = {"Uproaring"}, --Uproar
		[5] = {"Uproaring"},
		[6] = {"Uproaring"},
		[8] = {"Using Bide"}, --Bide
		[9] = {"Using Bide"},
		[10] = {"Attacking Wildly"}, --Thrash, Outrage, Petal Dance
		[11] = {"Attacking Wildly"},
		[12] = {"Locked in"}, --Bide, Charge moves, 2-3 turn moves, Uproar, etc.
		[13] = {"Restrained"}, --Wrap, Fire Spin, Clamp, etc.
		[14] = {"Restrained"},
		[15] = {"Restrained"},
		[16] = {"Infatuated"}, --Attract, Cute Charm; bit determines which mon(s) this one is attracted to
		[17] = {"Infatuated"},
		[18] = {"Infatuated"},
		[19] = {"Infatuated"},
		[20] = {"Focused"}, --Focus Energy
		[21] = {"Transformed"}, --Transform
		[22] = {"Recharging"}, --Hyper Beam, Blast Burn, Hydro Cannon, Frenzy Plant
		[23] = {"Raging"}, --Rage
		[24] = {"Behind a Substitute"}, --Substitute
		[25] = {"Using Destiny Bond"}, -- Destiny Bond
		[26] = {"Cannot Escape"}, --Trapping moves, Ingrain, etc.
		[27] = {"Nightmares"}, --Nightmare
		[28] = {"Cursed"}, --Curse (from Ghost-type)
		[29] = {"Foreseeing"}, --Foresight
		[30] = {"Curled Up"}, --Defense Curl
		[31] = {"Tormented"}, --Torment
	},
	Status3NameMap = {
		[0] = {"Leech Seeded by Left"},
		[1] = {"Leech Seeded by Enemy"},
		[2] = {"Leech Seeded"}, --Leech Seed
		[3] = {"Locked On"}, --Lock-on
		[4] = {"Locked On (Extra)"},
		[5] = {"Perishing"}, --Perish Song
		[6] = {"Airborne"}, --Fly,
		[7] = {"Underground"}, --Dig
		[8] = {"Minimized"}, --Minimize
		[9] = {"Charged"}, --Charge
		[10] = {"Rooted"}, --Ingrain
		[11] = {"Drowsy"}, --Yawn
		[12] = {"Drowsy (Extra)"},
		[13] = {"Imprisoning"}, --Imprison
		[14] = {"Grudge"}, --Grudge
		[15] = {"Perishing"},
		[16] = {"Sporting Mud"}, --Mud Sport
		[17] = {"Sporting Water"}, --Water Sport
		[18] = {"Underwater"}, --Dive
		[20] = {"Traced"}, --Trace

	},
	Buttons = {
		Back = {
			type = Constants.ButtonTypes.FULL_BORDER,
			text = "Back",
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				Program.changeScreenView(TrackerScreen)
			end
		},
		[0] = { --LeftOwn
			type = Constants.ButtonTypes.NO_BORDER,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 21, 11, 11 },
			boxColors = {"Upper box border", "Upper box background"},
			isVisible = function() return true end,
			onClick = function(self)
				print ("left own click")
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 0 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 0
				Program.redraw(true)
			end
		},
		[1] = { --LeftOther
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 125, Constants.SCREEN.MARGIN + 6, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				print ("left other click")
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 1 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 1
				Program.redraw(true)
			end
		},
		[2] = { --RightOwn
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 21, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				print ("right own click")
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 2 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 2
				Program.redraw(true)
			end
		},
		[3] = { --RightOther
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 110, Constants.SCREEN.MARGIN + 6, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				print ("right other click")
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 3 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 3
				Program.redraw(true)
			end
		},
		[4] = { --Ally Team
			type = Constants.ButtonTypes.FULL_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, Constants.SCREEN.MARGIN + 19, 40, 15 },
			isVisible = function() return true end,
			onClick = function(self)
				print ("enemy side click")
				if BattleEffectsScreen.viewingSideStauses and BattleEffectsScreen.viewedSideIndex == 0 then return end
				BattleEffectsScreen.viewingIndividualStatuses = false
				BattleEffectsScreen.viewingSideStauses = true
				BattleEffectsScreen.viewedSideIndex = 0
				Program.redraw(true)
			end
		},
		[5] = { -- Enemy Team
			type = Constants.ButtonTypes.FULL_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, Constants.SCREEN.MARGIN + 4, 40, 15 },
			isVisible = function() return true end,
			onClick = function(self)
				print ("allied side click")
				if BattleEffectsScreen.viewingSideStauses and BattleEffectsScreen.viewedSideIndex == 1 then return end
				BattleEffectsScreen.viewingIndividualStatuses = false
				BattleEffectsScreen.viewingSideStauses = true
				BattleEffectsScreen.viewedSideIndex = 1
				Program.redraw(true)
			end
		},
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
	local terrainText = BattleEffectsScreen.TerrainNameMap[battleTerrain]
	BattleEffectsScreen.BattleDetails.Terrain = Utils.inlineIf(terrainText ~= nil,terrainText, BattleEffectsScreen.TerrainNameMap["default"])
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
		BattleEffectsScreen.BattleDetails.Weather = BattleEffectsScreen.WeatherNameMap["default"]
		BattleEffectsScreen.BattleDetails.WeatherTurns = nil
	else
		local weatherBitIndex = 0
		while weatherByte > 1 do
			weatherByte = Utils.bit_rshift(weatherByte, 1)
			weatherBitIndex = weatherBitIndex + 1
		end
		local weatherText = BattleEffectsScreen.WeatherNameMap[weatherBitIndex]
		BattleEffectsScreen.BattleDetails.Weather = Utils.inlineIf(weatherText ~= nil,weatherText, BattleEffectsScreen.WeatherNameMap["default"])
		BattleEffectsScreen.BattleDetails.WeatherTurns = weatherTurns
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
		if BattleEffectsScreen.PerMonDetails[index]["Confused"] then
			BattleEffectsScreen.PerMonDetails[index]["Confused"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Confused"] = {active=true}
		end
	end
	if status2Map[4] or status2Map[5] or status2Map[6] then
		if BattleEffectsScreen.PerMonDetails[index]["Uproar"] then
			BattleEffectsScreen.PerMonDetails[index]["Uproar"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Uproar"] = {active=true}
		end
	end
	if status2Map[8] or status2Map[9] then
		local remainingTurnsBide = (Utils.inlineIf(status2Map[8],1,0) + Utils.inlineIf(status2Map[9],2,0))
		if BattleEffectsScreen.PerMonDetails[index]["Bide"] then
			BattleEffectsScreen.PerMonDetails[index]["Bide"].active=true
			BattleEffectsScreen.PerMonDetails[index]["Bide"].remainingTurns=remainingTurnsBide
		else
			BattleEffectsScreen.PerMonDetails[index]["Bide"] = {active=true, remainingTurns=remainingTurnsBide}
		end
	end
	if status2Map[12] then
		if BattleEffectsScreen.PerMonDetails[index]["Locked Into Attack"] then
			BattleEffectsScreen.PerMonDetails[index]["Locked Into Attack"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Locked Into Attack"] = {active=true}
		end
	end
	if status2Map[13] or status2Map[14] or status2Map[15] then
		if BattleEffectsScreen.PerMonDetails[index]["Trapping Move"] then
			BattleEffectsScreen.PerMonDetails[index]["Trapping Move"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Trapping Move"] = {active=true}
		end
	end
	if status2Map[16] or status2Map[17] or status2Map[18] or status2Map[19] then
		local infatuationTarget = Utils.inlineIf(status2Map[16],0,nil) or Utils.inlineIf(status2Map[17],1,nil) or Utils.inlineIf(status2Map[18],2,nil) or Utils.inlineIf(status2Map[19],3,0)
		if BattleEffectsScreen.PerMonDetails[index]["Attract"] then
			BattleEffectsScreen.PerMonDetails[index]["Attract"].active=true
			BattleEffectsScreen.PerMonDetails[index]["Attract"].affectedBy=infatuationTarget
		else
			BattleEffectsScreen.PerMonDetails[index]["Attract"] = {active=true, affectedBy=infatuationTarget}
		end
	end
	if status2Map[20] then
		if BattleEffectsScreen.PerMonDetails[index]["Focus Energy"] then
			BattleEffectsScreen.PerMonDetails[index]["Focus Energy"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Focus Energy"] = {active=true}
		end
	end
	if status2Map[21] then
		if BattleEffectsScreen.PerMonDetails[index]["Transform"] then
			BattleEffectsScreen.PerMonDetails[index]["Transform"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Transform"] = {active=true}
		end
	end
	if status2Map[22] then
		if BattleEffectsScreen.PerMonDetails[index]["Charge Move Cooldown"] then
			BattleEffectsScreen.PerMonDetails[index]["Charge Move Cooldown"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Charge Move Cooldown"] = {active=true}
		end
	end
	if status2Map[23] then
		if BattleEffectsScreen.PerMonDetails[index]["Rage"] then
			BattleEffectsScreen.PerMonDetails[index]["Rage"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Rage"] = {active=true}
		end
	end
	if status2Map[24] then
		if BattleEffectsScreen.PerMonDetails[index]["Substitute"] then
			BattleEffectsScreen.PerMonDetails[index]["Substitute"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Substitute"] = {active=true}
		end
	end
	if status2Map[25] then
		if BattleEffectsScreen.PerMonDetails[index]["Destiny Bond"] then
			BattleEffectsScreen.PerMonDetails[index]["Destiny Bond"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Destiny Bond"] = {active=true}
		end
	end
	if status2Map[26] then
		if BattleEffectsScreen.PerMonDetails[index]["Cannot Escape"] then
			BattleEffectsScreen.PerMonDetails[index]["Cannot Escape"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Cannot Escape"] = {active=true}
		end
	end
	if status2Map[27] then
		if BattleEffectsScreen.PerMonDetails[index]["Nightmare"] then
			BattleEffectsScreen.PerMonDetails[index]["Nightmare"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Nightmare"] = {active=true}
		end
	end
	if status2Map[28] then
		if BattleEffectsScreen.PerMonDetails[index]["Curse"] then
			BattleEffectsScreen.PerMonDetails[index]["Curse"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Curse"] = {active=true}
		end
	end
	if status2Map[29] then
		if BattleEffectsScreen.PerMonDetails[index]["Foresight"] then
			BattleEffectsScreen.PerMonDetails[index]["Foresight"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Foresight"] = {active=true}
		end
	end
	if status2Map[30] then
		if BattleEffectsScreen.PerMonDetails[index]["Defense Curl"] then
			BattleEffectsScreen.PerMonDetails[index]["Defense Curl"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Defense Curl"] = {active=true}
		end
	end
	if status2Map[31] then
		if BattleEffectsScreen.PerMonDetails[index]["Torment"] then
			BattleEffectsScreen.PerMonDetails[index]["Torment"].active=true
		else
			BattleEffectsScreen.PerMonDetails[index]["Torment"] = {active=true}
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
		if BattleEffectsScreen.PerMonDetails[index]["Leech Seed"] then
			BattleEffectsScreen.PerMonDetails[index]["Leech Seed"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Leech Seed"] = {active=true}
		end
	end
	if status3Map[3] or status3Map[4] then
		if BattleEffectsScreen.PerMonDetails[index]["Lock On"] then
			BattleEffectsScreen.PerMonDetails[index]["Lock On"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Lock On"] = {active=true}
		end
	end
	if status3Map[5] then
		if BattleEffectsScreen.PerMonDetails[index]["Perish Song"] then
			BattleEffectsScreen.PerMonDetails[index]["Perish Song"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Perish Song"] = {active=true}
		end
	end
	if status3Map[6] or status3Map[7] or status3Map[18] then
		local invulnerableType = Utils.inlineIf(status3Map[6],"Air",nil) or Utils.inlineIf(status3Map[7],"Underground",nil) or Utils.inlineIf(status3Map[18],"Underwater","")
		if BattleEffectsScreen.PerMonDetails[index]["Semi Invulnerable"] then
			BattleEffectsScreen.PerMonDetails[index]["Semi Invulnerable"].active = true
			BattleEffectsScreen.PerMonDetails[index]["Semi Invulnerable"].type = invulnerableType
		else
			BattleEffectsScreen.PerMonDetails[index]["Semi Invulnerable"] = {active=true}
		end
	end
	if status3Map[8] then
		if BattleEffectsScreen.PerMonDetails[index]["Minimize"] then
			BattleEffectsScreen.PerMonDetails[index]["Minimize"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Minimize"] = {active=true}
		end
	end
	if status3Map[9] then
		if BattleEffectsScreen.PerMonDetails[index]["Charge"] then
			BattleEffectsScreen.PerMonDetails[index]["Charge"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Charge"] = {active=true}
		end
	end
	if status3Map[10] then
		if BattleEffectsScreen.PerMonDetails[index]["Ingrain"] then
			BattleEffectsScreen.PerMonDetails[index]["Ingrain"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Ingrain"] = {active=true}
		end
	end
	if status3Map[11] or status3Map[12] then
		if BattleEffectsScreen.PerMonDetails[index]["Drowsy"] then
			BattleEffectsScreen.PerMonDetails[index]["Drowsy"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Drowsy"] = {active=true}
		end
	end
	if status3Map[13] then
		if BattleEffectsScreen.PerMonDetails[index]["Imprison"] then
			BattleEffectsScreen.PerMonDetails[index]["Imprison"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Imprison"] = {active=true}
		end
	end
	if status3Map[14] then
		if BattleEffectsScreen.PerMonDetails[index]["Grudge"] then
			BattleEffectsScreen.PerMonDetails[index]["Grudge"].active = true
		else
			BattleEffectsScreen.PerMonDetails[index]["Grudge"] = {active=true}
		end
	end
	if status3Map[16] then
		if BattleEffectsScreen.BattleDetails["Mud Sport"] then
			BattleEffectsScreen.BattleDetails["Mud Sport"].active = true
		else
			BattleEffectsScreen.BattleDetails["Mud Sport"] = {active=true}
		end
		local sources = BattleEffectsScreen.BattleDetails["Mud Sport"].sources
		if sources then
			sources[index] = true
		else
			sources = {index = true}
		end
	end
	if status3Map[17] then
		if BattleEffectsScreen.BattleDetails["Water Sport"] then
			BattleEffectsScreen.BattleDetails["Water Sport"].active = true
		else
			BattleEffectsScreen.BattleDetails["Water Sport"] = {active=true}
		end
		local sources = BattleEffectsScreen.BattleDetails["Water Sport"].sources
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
		BattleEffectsScreen.PerSideDetails[0]["Reflect"] = {active = true,turnsLeft = turnsLeftReflect}
	end
	if sideStatusMap[1] then
		local turnsLeftLightScreen = Memory.readbyte(sideTimersBase + 0x02)
		BattleEffectsScreen.PerSideDetails[0]["Light Screen"] = {active = true,turnsLeft = turnsLeftLightScreen}
	end
	if sideStatusMap[4] then
		local amountSpikes = Memory.readbyte(sideTimersBase + 0x0A)
		BattleEffectsScreen.PerSideDetails[0]["Spikes"] = {active = true,amount = amountSpikes}
	end
	if sideStatusMap[5] then
		local turnsLeftSafeguard = Memory.readbyte(sideTimersBase + 0x06)
		BattleEffectsScreen.PerSideDetails[0]["Safeguard"] = {active = true,turnsLeft = turnsLeftSafeguard}
	end
	if sideStatusMap[8] then
		local turnsLeftMist = Memory.readbyte(sideTimersBase + 0x04)
		BattleEffectsScreen.PerSideDetails[0]["Mist"] = {active = true,turnsLeft = turnsLeftMist}
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
		if BattleEffectsScreen.PerMonDetails[index]["Disable"] then
			BattleEffectsScreen.PerMonDetails[index]["Disable"].active = true
			BattleEffectsScreen.PerMonDetails[index]["Disable"].move = disabledMove
		else
			BattleEffectsScreen.PerMonDetails[index]["Disable"] = {active = true, move = disabledMove}
		end
	end
	local encoredMove = Memory.readword(disableStructBase + 0x06)
	if encoredMove ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index]["Encore"] then
			BattleEffectsScreen.PerMonDetails[index]["Encore"].active = true
			BattleEffectsScreen.PerMonDetails[index]["Encore"].move = encoredMove
		else
			BattleEffectsScreen.PerMonDetails[index]["Encore"] = {active = true, move = encoredMove}
		end
	end
	local protectUses = Memory.readbyte(disableStructBase + 0x08)
	if protectUses ~= 0 then
		BattleEffectsScreen.PerMonDetails[index]["Protect Uses"] = protectUses
	end
	local stockpileCount = Memory.readbyte(disableStructBase + 0x09)
	if stockpileCount ~= 0 then
		BattleEffectsScreen.PerMonDetails[index]["Stockpile"] = stockpileCount
	end
	local perishSongCount = Utils.getbits(Memory.readword(disableStructBase + 0x0F),0,4)
	if perishSongCount ~= 0 then
		BattleEffectsScreen.PerMonDetails[index]["Perish Song"] = perishSongCount
	end
	local furyCutterCount = Memory.readword(disableStructBase + 0x10)
	if furyCutterCount ~= 0 then
		BattleEffectsScreen.PerMonDetails[index]["Fury Cutter"] = furyCutterCount
	end
	local rolloutCount = Utils.getbits(Memory.readword(disableStructBase + 0x11),0,4)
	if rolloutCount ~= 0 then
		BattleEffectsScreen.PerMonDetails[index]["Rollout"] = rolloutCount
	end
	local tauntTimer = Utils.getbits(Memory.readword(disableStructBase + 0x13),0,4)
	if tauntTimer ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index]["Taunt"] then
			BattleEffectsScreen.PerMonDetails[index]["Taunt"].active = true
			BattleEffectsScreen.PerMonDetails[index]["Taunt"].remainingTurns = tauntTimer
		else
			BattleEffectsScreen.PerMonDetails[index]["Taunt"] = {active = true, remainingTurns = tauntTimer}
		end
	end
	local cannotEscapeSource = Memory.readbyte(disableStructBase + 0x14)
	if BattleEffectsScreen.PerMonDetails[index]["Cannot Escape"] then
		BattleEffectsScreen.PerMonDetails[index]["Cannot Escape"].source = cannotEscapeSource
	end
	local lockOnSource = Memory.readbyte(disableStructBase + 0x15)
	if BattleEffectsScreen.PerMonDetails[index]["Lock On"] then
		BattleEffectsScreen.PerMonDetails[index]["Lock On"].source = lockOnSource
	end
	local truantCheck = Memory.readbyte(disableStructBase + 0x18)
	BattleEffectsScreen.PerMonDetails[index]["Truant"] = truantCheck % 1 == 1
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
		if BattleEffectsScreen.PerMonDetails[index]["Future Sight"] then
			BattleEffectsScreen.PerMonDetails[index]["Future Sight"].source = futureSightSource
			BattleEffectsScreen.PerMonDetails[index]["Future Sight"].remainingTurns = futureSightCounter
		else
			BattleEffectsScreen.PerMonDetails[index]["Future Sight"] = {source = futureSightSource, remainingTurns = futureSightCounter}
		end
	end
	local wishCounter = Memory.readbyte(wishStructBase + 0x20 + (index * 0x1))
	if wishCounter ~= 0 then
		local wishSource = Memory.readbyte(wishStructBase + 0x24 + (index * 0x1))
		if BattleEffectsScreen.PerMonDetails[index]["Wish"] then
			BattleEffectsScreen.PerMonDetails[index]["Wish"].source = wishSource
			BattleEffectsScreen.PerMonDetails[index]["Wish"].remainingTurns = wishCounter
		else
			BattleEffectsScreen.PerMonDetails[index]["Wish"] = {source = wishSource, remainingTurns = wishCounter}
		end
	end
end

function BattleEffectsScreen.loadData()
	loadTerrain()
	loadWeather()
	for i=0,3,1 do
		loadStatus2(i)
		loadStatus3(i)
		loadSideStatuses(i)
		loadDisableStruct(i)
		loadWishStruct(i)
	end
end

function BattleEffectsScreen.resetBattleDetails()
	BattleEffectsScreen.BattleDetails = {
		Weather = "None",
		Terrain = "Building",
	}
	BattleEffectsScreen.PerSideDetails = {
		[0] = {},
		[1] = {},
	}
	BattleEffectsScreen.PerMonDetails = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	}
end

function drawTitle()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1
	local offsetY = Constants.SCREEN.MARGIN + 1
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
	Drawing.drawText(offsetX, offsetY, screenTitle, textColor, nil, 12, Constants.Font.FAMILY, "bold")
	offsetY = offsetY + 12

	--Battle scope details
	Drawing.drawText(offsetX,offsetY, "Terrain: " .. BattleEffectsScreen.BattleDetails.Terrain, textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing
	Drawing.drawText(offsetX,offsetY, "Weather: " .. BattleEffectsScreen.BattleDetails.Weather, textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 2

	local Xdelta = 40
	local prefix = "Allied"
	local suffix = "Team"
	if BattleEffectsScreen.viewingIndividualStatuses then
		suffix = "Mon"
		Xdelta = Xdelta + 2
		if BattleEffectsScreen.viewedMonIndex % 2 == 1 then
			prefix = "Enemy"
			Xdelta = Xdelta -2
		end
	elseif BattleEffectsScreen.viewedSideIndex % 2 == 1 then
		prefix = "Enemy"
		Xdelta = Xdelta - 2
	end
	Drawing.drawText(offsetX + Xdelta,offsetY, prefix .. " " .. suffix, textColor, nil, linespacing, Constants.Font.FAMILY,  "bold")

	Xdelta = 5
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Reflect (Turn 2)", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Light Screen (Turn 5)", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Infatuated", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Leech Seed - Tyranitar (Turn 5)", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Light Screen (Turn 5)", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Light Screen (Turn 5)", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing + 1
	Drawing.drawText(offsetX + Xdelta,offsetY, "Really long string just to limit test", textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing
	offsetY = offsetY + linespacing

	Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, offsetX + 45, offsetY, defaultArrowColorList, null)
	Drawing.drawText(offsetX + 54, offsetY - 3, "1/5", textColor, nil, linespacing, Constants.Font.FAMILY)

	Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, offsetX + 78, offsetY, defaultArrowColorList, null)

end

function drawBattleDetailsUI()
end

function drawPerSideUI()
end

function drawPerMonUI()
end

function drawBattleDiagram()
	local ballColorList = { 0xFF000000, 0xFFF04037, 0xFFFFFFFF, }
	local defaultArrowColorList = {Theme.COLORS["Default text"]}
	local selectedArrowColorList = {Theme.COLORS["Positive text"]}

	if BattleEffectsScreen.viewingSideStauses then
		BattleEffectsScreen.Buttons[4+((BattleEffectsScreen.viewedSideIndex)%2)].boxColors = {"Positive text", "Upper box background"}
		BattleEffectsScreen.Buttons[4+((BattleEffectsScreen.viewedSideIndex + 1)%2)].boxColors = {"Upper box border", "Upper box background"}
		Drawing.drawButton(BattleEffectsScreen.Buttons[4+((BattleEffectsScreen.viewedSideIndex + 1)%2)])
		Drawing.drawButton(BattleEffectsScreen.Buttons[4+((BattleEffectsScreen.viewedSideIndex)%2)])
	else
		BattleEffectsScreen.Buttons[4].boxColors = {"Upper box border", "Upper box background"}
		BattleEffectsScreen.Buttons[5].boxColors = {"Upper box border", "Upper box background"}
		Drawing.drawButton(BattleEffectsScreen.Buttons[4])
		Drawing.drawButton(BattleEffectsScreen.Buttons[5])
	end
	Drawing.drawButton(BattleEffectsScreen.Buttons[0])
	Drawing.drawButton(BattleEffectsScreen.Buttons[1])
	Drawing.drawButton(BattleEffectsScreen.Buttons[2])
	Drawing.drawButton(BattleEffectsScreen.Buttons[3])
	if BattleEffectsScreen.viewingSideStauses then
		if BattleEffectsScreen.viewedSideIndex == 0 then
			Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102, Constants.SCREEN.MARGIN + 8, defaultArrowColorList, null)
			Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 130, Constants.SCREEN.MARGIN + 23, selectedArrowColorList, null)
		else
			Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 130, Constants.SCREEN.MARGIN + 23, defaultArrowColorList, null)
			Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102, Constants.SCREEN.MARGIN + 8, selectedArrowColorList, null)
		end
	elseif BattleEffectsScreen.viewingIndividualStatuses then
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 130, Constants.SCREEN.MARGIN + 23, defaultArrowColorList, null)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102, Constants.SCREEN.MARGIN + 8, defaultArrowColorList, null)
		Drawing.drawSelectionIndicators(
			BattleEffectsScreen.Buttons[BattleEffectsScreen.viewedMonIndex].box[1],
			BattleEffectsScreen.Buttons[BattleEffectsScreen.viewedMonIndex].box[2],
			BattleEffectsScreen.Buttons[BattleEffectsScreen.viewedMonIndex].box[3],
			BattleEffectsScreen.Buttons[BattleEffectsScreen.viewedMonIndex].box[4], Theme.COLORS["Positive text"], 1, 3, 0)
	end
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleEffectsScreen.Buttons[0].box[1], BattleEffectsScreen.Buttons[0].box[2], ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleEffectsScreen.Buttons[1].box[1], BattleEffectsScreen.Buttons[1].box[2], ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleEffectsScreen.Buttons[2].box[1], BattleEffectsScreen.Buttons[2].box[2], ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, BattleEffectsScreen.Buttons[3].box[1], BattleEffectsScreen.Buttons[3].box[2], ballColorList, null)
end

function BattleEffectsScreen.drawScreen()
	if Battle.inBattle == false then
		BattleEffectsScreen.Buttons.Back.onClick()
		return
	end
	drawTitle()
	drawBattleDiagram()
	drawBattleDetailsUI()
	drawPerSideUI()
	drawPerMonUI()
	Drawing.drawButton(BattleEffectsScreen.Buttons.Back)
end

function BattleEffectsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, BattleEffectsScreen.Buttons)
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
BattleDetailsScreen = {
	Key = "BattleDetailsScreen",
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	viewingIndividualStatuses = true,
	viewingSideStauses = false,
	viewedMonIndex = 0,
	viewedSideIndex = 0,
	currentPage = 1,
	numPages = 1,
	pageSize = 6,
}
local SCREEN = BattleDetailsScreen

-- Other details recorded in battle
SCREEN.PerSideDetails = {}
SCREEN.PerMonDetails = {}

-- Resources caches
SCREEN.BattleDetails = {}
SCREEN.WeatherNameMap = {}
SCREEN.TerrainNameMap = {}

SCREEN.Buttons = {
	LeftOwn = {
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 101, Constants.SCREEN.MARGIN + 36, 13, 13 },
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		isVisible = function() return true end,
		onClick = function(self)
			if SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 0 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 0
			Program.redraw(true)
		end
	},
	LeftOther = {
		type = Constants.ButtonTypes.NO_BORDER,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 122, Constants.SCREEN.MARGIN + 21, 13, 13 },
		isVisible = function() return true end,
		onClick = function(self)
			if SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 1 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 1
			Program.redraw(true)
		end
	},
	RightOwn = {
		type = Constants.ButtonTypes.NO_BORDER,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 114, Constants.SCREEN.MARGIN + 36, 13, 13 },
		isVisible = function() return Battle.numBattlers == 4 end,
		onClick = function(self)
			if SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 2 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 2
			Program.redraw(true)
		end
	},
	RightOther = {
		type = Constants.ButtonTypes.NO_BORDER,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 109, Constants.SCREEN.MARGIN + 21, 13, 13 },
		isVisible = function() return Battle.numBattlers == 4 end,
		onClick = function(self)
			if SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 3 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 3
			Program.redraw(true)
		end
	},
	AllyTeam = {
		type = Constants.ButtonTypes.NO_BORDER,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 129, Constants.SCREEN.MARGIN + 35, 6, 15 },
		isVisible = function() return true end,
		updateSelf = function(self)
			-- Increase clickable area for team boxes in single battles to include the unused pokeballs
			if Battle.numBattlers == 2 then
				self.box[1] = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115
				self.box[3] = 20
			else
				self.box[1] = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 129
				self.box[3] = 6
			end
		end,
		onClick = function(self)
			if SCREEN.viewingSideStauses and SCREEN.viewedSideIndex == 0 then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = true
			SCREEN.viewedSideIndex = 0
			Program.redraw(true)
		end
	},
	EnemyTeam = {
		type = Constants.ButtonTypes.NO_BORDER,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 101, Constants.SCREEN.MARGIN + 20, 6, 15 },
		isVisible = function() return true end,
		updateSelf = function(self)
			-- Increase clickable area for team boxes in single battles to include the unused pokeballs
			if Battle.numBattlers == 2 then
				self.box[3] = 20
			else
				self.box[3] = 6
			end
		end,
		onClick = function(self)
			if SCREEN.viewingSideStauses and SCREEN.viewedSideIndex == 1 then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = true
			SCREEN.viewedSideIndex = 1
			Program.redraw(true)
		end
	},
	BattleView = {
		type = Constants.ButtonTypes.NO_BORDER,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91, Constants.SCREEN.MARGIN + 20, 9, 30},
		isVisible = function() return true end,
		onClick = function(self)
			if not SCREEN.viewingSideStauses and not SCREEN.viewingIndividualStatuses then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = false
			SCREEN.viewedSideIndex = 0
			SCREEN.viewedMonIndex = 0
			Program.redraw(true)
		end
	},
	PageLeft = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 48, Constants.SCREEN.MARGIN + 137, 10, 10 },
		isVisible = function() return SCREEN.currentPage > 1 end,
		onClick = function(self)
			SCREEN.currentPage = SCREEN.currentPage - 1
			Program.redraw(true)
		end
	},
	PageRight = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		boxColors = {SCREEN.Colors.border, SCREEN.Colors.boxFill},
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 86, Constants.SCREEN.MARGIN + 137, 10, 10 },
		isVisible = function() return SCREEN.currentPage < SCREEN.numPages end,
		onClick = function(self)
			SCREEN.currentPage = SCREEN.currentPage + 1
			Program.redraw(true)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(TrackerScreen)
	end),
}

function BattleDetailsScreen.initialize()
	SCREEN.viewingIndividualStatuses = true
	SCREEN.viewingSideStauses = false
	SCREEN.viewedMonIndex = 0
	SCREEN.viewedSideIndex = 0
	SCREEN.currentPage = 1
	SCREEN.numPages = 1
	SCREEN.testing = false

	SCREEN.PerSideDetails = {
		[0] = {},
		[1] = {},
	}
	SCREEN.PerMonDetails = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	}

	SCREEN.updateResources()
end

function BattleDetailsScreen.updateResources()
	SCREEN.BattleDetails = {
		Weather = Resources[SCREEN.Key].WeatherDefault,
		Terrain = Resources[SCREEN.Key].TerrainDefault,
	}
	SCREEN.WeatherNameMap = {
		[0] = Resources[SCREEN.Key].WeatherRain,
		[1] = Resources[SCREEN.Key].WeatherRain,
		[2] = Resources[SCREEN.Key].WeatherRain,
		[3] = Resources[SCREEN.Key].WeatherSandstorm,
		[4] = Resources[SCREEN.Key].WeatherSandstorm,
		[5] = Resources[SCREEN.Key].WeatherSunlight,
		[6] = Resources[SCREEN.Key].WeatherSunlight,
		[7] = Resources[SCREEN.Key].WeatherHail,
		["default"] = Resources[SCREEN.Key].WeatherDefault,
	}
	SCREEN.TerrainNameMap = {
		[0] = Resources[SCREEN.Key].TerrainGrass,
		[1] = Resources[SCREEN.Key].Terrain,
		[2] = Resources[SCREEN.Key].TerrainSand,
		[3] = Resources[SCREEN.Key].TerrainUnderwater,
		[4] = Resources[SCREEN.Key].TerrainWater,
		[5] = Resources[SCREEN.Key].TerrainPond,
		[6] = Resources[SCREEN.Key].TerrainMountain,
		[7] = Resources[SCREEN.Key].TerrainCave,
		["default"] = Resources[SCREEN.Key].TerrainDefault,
	}
end

local function resetBattleDetails()
	SCREEN.currentPage = 1
	SCREEN.numPages = 1

	SCREEN.BattleDetails.Weather = Resources[SCREEN.Key].WeatherDefault
	SCREEN.BattleDetails.Terrain = Resources[SCREEN.Key].TerrainDefault

	SCREEN.PerSideDetails = {
		[0] = {},
		[1] = {},
	}
	SCREEN.PerMonDetails = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	}
end

local function loadTerrain()
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
	local battleTerrain = Memory.readbyte(GameSettings.gBattleTerrain)
	local terrainText = SCREEN.TerrainNameMap[battleTerrain]
	SCREEN.BattleDetails.Terrain = terrainText or SCREEN.TerrainNameMap["default"]
end

local function loadWeather()
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
	local weatherByte = Memory.readbyte(GameSettings.gBattleWeather)
	local weatherTurns = Memory.readbyte(GameSettings.gWishFutureKnock + 0x28)

	if weatherByte == 0 then
		SCREEN.BattleDetails.Weather = SCREEN.WeatherNameMap["default"]
		SCREEN.BattleDetails.WeatherTurns = 0
	else
		local weatherBitIndex = 0
		while weatherByte > 1 do
			weatherByte = Utils.bit_rshift(weatherByte, 1)
			weatherBitIndex = weatherBitIndex + 1
		end
		local weatherText = SCREEN.WeatherNameMap[weatherBitIndex]
		SCREEN.BattleDetails.Weather = weatherText or SCREEN.WeatherNameMap["default"]
		--Weather Turns are not reset to 0 when temporary weather becomes permanent
		if weatherBitIndex == 0 or weatherBitIndex == 3 or weatherBitIndex == 5 or weatherBitIndex == 7 then
			SCREEN.BattleDetails.WeatherTurns = weatherTurns
		else
			SCREEN.BattleDetails.WeatherTurns = 0
		end
	end
end
local function loadFieldEffects()
	loadTerrain()
	loadWeather()
	local gPaydayMoney = Memory.readword(GameSettings.gPaydayMoney)
	if gPaydayMoney ~= 0 then
		SCREEN.BattleDetails.PayDay = {
			label = Resources[SCREEN.Key].EffectPayDay,
			amount = gPaydayMoney
		}
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
local function loadStatus2(index)
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


	-----------------------------------------------------------------------------------------------------------

	]]--
	local remainingTurnsBide
	if index == nil or index < 0 or index > 3 then
		index = 0
	end
	local battleStructAddress
	if GameSettings.gBattleStructPtr ~= nil then -- Pointer unavailable in RS
		battleStructAddress = Memory.readdword(GameSettings.gBattleStructPtr)
	else
		battleStructAddress = 0x02000000 -- gSharedMem
	end
	local status2Data = Memory.readdword(GameSettings.gBattleMons + (index * Program.Addresses.sizeofBattlePokemon) + Program.Addresses.offsetBattlePokemonStatus2)
	local status2Map = Utils.generateBitwiseMap(status2Data, 32)
	if status2Map[0] or status2Map[1] or status2Map[2] then
		local turnsText = string.format("1- 4 %ss", Resources[SCREEN.Key].TextTurn)
		SCREEN.PerMonDetails[index].Confused = {
			label = Resources[SCREEN.Key].EffectConfused,
			totalTurns = turnsText
		}
	end
	if status2Map[4] or status2Map[5] or status2Map[6] then
		--253 = Uproar
		SCREEN.PerMonDetails[index].Uproar = {
			label = Resources.Game.MoveNames[253]
		}
	end
	if status2Map[8] or status2Map[9] then
		remainingTurnsBide = (Utils.inlineIf(status2Map[8],1,0) + Utils.inlineIf(status2Map[9],2,0))
		--117 = Bide
		SCREEN.PerMonDetails[index].Bide = {
			label = Resources.Game.MoveNames[117],
			remainingTurns=remainingTurnsBide
		}
	end
	if status2Map[12] and remainingTurnsBide == nil then
		SCREEN.PerMonDetails[index].MustAttack = {
			label = Resources[SCREEN.Key].EffectMustAttack
		}
	end
	if status2Map[13] or status2Map[14] or status2Map[15] then
		local sourceBattlerIndex = Memory.readbyte(battleStructAddress + Program.Addresses.offsetBattleStructWrappedBy + index)
		SCREEN.PerMonDetails[index].Trapped = {
			label = Resources[SCREEN.Key].EffectTrapped,
			source = sourceBattlerIndex
		}
	end
	if status2Map[16] or status2Map[17] or status2Map[18] or status2Map[19] then
		local infatuationTarget = Utils.inlineIf(status2Map[16],0,nil) or Utils.inlineIf(status2Map[17],1,nil) or Utils.inlineIf(status2Map[18],2,nil) or Utils.inlineIf(status2Map[19],3,0)
		--213 = Attract
		SCREEN.PerMonDetails[index].Attract = {
			label = Resources.Game.MoveNames[213],
			source=infatuationTarget
		}
	end
	if status2Map[20] then
		--116 = Focus Energy
		SCREEN.PerMonDetails[index].FocusEnergy = {
			label = Resources.Game.MoveNames[116]
		}
	end
	if status2Map[21] then
		--144 = Transform
		SCREEN.PerMonDetails[index].Transform = {
			label = Resources.Game.MoveNames[144]
		}
	end
	if status2Map[22] then
		SCREEN.PerMonDetails[index].CannotAct = {
			label = Resources[SCREEN.Key].EffectCannotAct
		}
	end
	if status2Map[23] then
		--99 = Rage
		SCREEN.PerMonDetails[index].Rage = {
			label = Resources.Game.MoveNames[99]
		}
	end
	--[[
		--leaving here since it is technically a battle status, but the player can physically see the substitute in the battle
		if status2Map[24] then
		SCREEN.PerMonDetails[index][Resources[SCREEN.Key].EffectSubstitute] = {active=true}
	end
	]]--
	if status2Map[25] then
		--194 = Destiny Bond
		SCREEN.PerMonDetails[index].DestinyBond = {
			label = Resources.Game.MoveNames[194]
		}
	end
	if status2Map[26] then
		SCREEN.PerMonDetails[index].CannotEscape = {
			label = Resources[SCREEN.Key].EffectCannotEscape
		}
	end
	if status2Map[27] then
		--171 = Nightmare
		SCREEN.PerMonDetails[index].Nightmare = {
			label = Resources.Game.MoveNames[171]
		}
	end
	if status2Map[28] then
		--174 = Curse
		SCREEN.PerMonDetails[index].Curse = {
			label = Resources.Game.MoveNames[174]
		}
	end
	if status2Map[29] then
		--193 = Foresight
		SCREEN.PerMonDetails[index].Foresight = {
			label = Resources.Game.MoveNames[193]
		}
	end
	if status2Map[30] then
		--111 = Defense Curl
		SCREEN.PerMonDetails[index].DefenseCurl = {
			label = Resources.Game.MoveNames[111]
		}
	end
	if status2Map[31] then
		--259 = Torment
		SCREEN.PerMonDetails[index].Torment = {
			label = Resources.Game.MoveNames[259]
		}
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
local function loadStatus3(index)
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
		index = 0
	end
	local status3Data = Memory.readdword(GameSettings.gStatuses3 + index * (0x04))
	local status3Map = Utils.generateBitwiseMap(status3Data, 21)
	if status3Map[2] then
		local leechSeedSource = (Utils.inlineIf(status3Map[0],1,0) + Utils.inlineIf(status3Map[1],2,0))
		--73 = Leech Seed
		SCREEN.PerMonDetails[index].LeechSeed = {
			label = Resources.Game.MoveNames[73],
			source=leechSeedSource
		}
	end
	if status3Map[3] or status3Map[4] then
		--199 = Lock On
		SCREEN.PerMonDetails[index].LockOn = {
			label = Resources.Game.MoveNames[199]
		}
	end
	if status3Map[5] then
		SCREEN.PerMonDetails[index].PerishCount = {
			label = Resources[SCREEN.Key].EffectPerishCount
		}
	end
	if status3Map[6] or status3Map[7] or status3Map[18] then
		local invulnerableType = Utils.inlineIf(status3Map[6],Resources[SCREEN.Key].EffectAirborne,nil) or Utils.inlineIf(status3Map[7],Resources[SCREEN.Key].EffectUnderground,nil) or Utils.inlineIf(status3Map[18],Resources[SCREEN.Key].EffectUnderwater,"")
		SCREEN.PerMonDetails[index].Invulnerable = {
			label = invulnerableType
		}
	end
	if status3Map[8] then
		--107 = Minimize
		SCREEN.PerMonDetails[index].Minimize = {
			label = Resources.Game.MoveNames[107]
		}
	end
	if status3Map[9] then
		--268 = Charge
		SCREEN.PerMonDetails[index].Charge = {
			label = Resources.Game.MoveNames[268]
		}
	end
	if status3Map[10] then
		--275 = Ingrain
		SCREEN.PerMonDetails[index].Ingrain = {
			label = Resources.Game.MoveNames[275]
		}
	end
	if status3Map[11] or status3Map[12] then
		SCREEN.PerMonDetails[index].Yawn = {
			label = Resources[SCREEN.Key].EffectDrowsy
		}
	end
	if status3Map[13] then
		--286 = Imprison
		SCREEN.PerMonDetails[index].Imprison = {
			label = Resources.Game.MoveNames[286]
		}
	end
	if status3Map[14] then
		--288 = Grudge
		SCREEN.PerMonDetails[index].Grudge = {
			label = Resources.Game.MoveNames[288]
		}
	end
	if status3Map[16] then
		--300 = Mud Sport
		SCREEN.BattleDetails.MudSport = SCREEN.BattleDetails.MudSport or {}
		SCREEN.BattleDetails.MudSport.sources = SCREEN.BattleDetails.MudSport.sources or {}
		SCREEN.BattleDetails.MudSport.label = Resources.Game.MoveNames[300]
		SCREEN.BattleDetails.MudSport.sources[index] = true
	end
	if status3Map[17] then
		--346 = Water Sport
		SCREEN.BattleDetails.WaterSport = SCREEN.BattleDetails.WaterSport or {}
		SCREEN.BattleDetails.WaterSport.sources = SCREEN.BattleDetails.WaterSport.sources or {}
		SCREEN.BattleDetails.WaterSport.label = Resources.Game.MoveNames[346]
		SCREEN.BattleDetails.WaterSport.sources[index] = true
	end
end

---@param index number Must be [0-1], inclusively; represent either the allied or enemy team
local function loadSideStatuses(index)
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
		index = 0
	end
	SCREEN.PerSideDetails[index] = SCREEN.PerSideDetails[index] or {}
	local sideStatuses = Memory.readword(GameSettings.gSideStatuses + (index * 0x02))
	local sideTimersBase = GameSettings.gSideTimers + (index * 0x0C)
	local sideStatusMap = Utils.generateBitwiseMap(sideStatuses, 9)

	if sideStatusMap[0] then
		local turnsLeftReflect = Memory.readbyte(sideTimersBase)
		--115 = Reflect
		SCREEN.PerSideDetails[index].Reflect = {
			label = Resources.Game.MoveNames[115],
			remainingTurns = turnsLeftReflect
		}
	end
	if sideStatusMap[1] then
		local turnsLeftLightScreen = Memory.readbyte(sideTimersBase + 0x02)
		--113 = Light Screen
		SCREEN.PerSideDetails[index].LightScreen = {
			label = Resources.Game.MoveNames[113],
			remainingTurns = turnsLeftLightScreen
		}
	end
	if sideStatusMap[4] then
		local amountSpikes = Memory.readbyte(sideTimersBase + 0x0A)
		--191 = Spikes
		SCREEN.PerSideDetails[index].Spikes = {
			label = Resources.Game.MoveNames[191],
			count = amountSpikes
		}
	end
	if sideStatusMap[5] then
		local turnsLeftSafeguard = Memory.readbyte(sideTimersBase + 0x06)
		--219 = Safeguard
		SCREEN.PerSideDetails[index].Safeguard = {
			label = Resources.Game.MoveNames[219],
			remainingTurns = turnsLeftSafeguard
		}
	end
	if sideStatusMap[8] then
		local turnsLeftMist = Memory.readbyte(sideTimersBase + 0x04)
		--54 = Mist
		SCREEN.PerSideDetails[index].Mist = {
			label = Resources.Game.MoveNames[54],
			remainingTurns = turnsLeftMist
		}
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
local function loadDisableStruct(index)
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
	local disableStructBase = GameSettings.gDisableStructs + (index * 0x1C)
	local disabledMove = Memory.readword(disableStructBase + 0x04)
	if disabledMove ~= 0 then
		--50 = Disable
		SCREEN.PerMonDetails[index].Disable = {
			label = Resources.Game.MoveNames[50],
			move = disabledMove
		}
	end
	local encoredMove = Memory.readword(disableStructBase + 0x06)
	if encoredMove ~= 0 then
		SCREEN.PerMonDetails[index].Encore = {
			label = Resources.Game.MoveNames[227],
			move = encoredMove
		}
	end
	local protectUses = Memory.readbyte(disableStructBase + 0x08)
	if protectUses ~= 0 then
		SCREEN.PerMonDetails[index].Protection = {
			label = Resources[SCREEN.Key].EffectProtectUses,
			count = protectUses}
	end
	local stockpileCount = Memory.readbyte(disableStructBase + 0x09)
	if stockpileCount ~= 0 then
		--254 = Stockpile
		SCREEN.PerMonDetails[index].Stockpile = {
			label = Resources.Game.MoveNames[254],
			count = stockpileCount
		}
	end

	if SCREEN.PerMonDetails[index].PerishCount then
		local perishSongCount = Utils.getbits(Memory.readword(disableStructBase + 0x0F),0,4)
		SCREEN.PerMonDetails[index].PerishCount.count = perishSongCount + 1
	end
	local furyCutterCount = Memory.readbyte(disableStructBase + 0x10)
	if furyCutterCount ~= 0 then
		--210 = Fury Cutter
		SCREEN.PerMonDetails[index].FuryCutter = {
			label = Resources.Game.MoveNames[210],
			count = furyCutterCount}
	end
	local rolloutCount = Utils.getbits(Memory.readword(disableStructBase + 0x11),0,4)
	if rolloutCount ~= 0 then
		local lockedMoves = Memory.readword (GameSettings.gLockedMoves + (index * 0x02))
		local moveName = Resources.Game.MoveNames[lockedMoves] or ""
		SCREEN.PerMonDetails[index].Rollout = {
			label = moveName,
			remainingTurns = rolloutCount
		}
	end
	local tauntTimer = Utils.getbits(Memory.readword(disableStructBase + 0x13),0,4)
	if tauntTimer ~= 0 then
		SCREEN.PerMonDetails[index].Taunt = {
			label = Resources[SCREEN.Key].EffectTaunt,
			remainingTurns = tauntTimer
		}
	end
	local cannotEscapeSource = Memory.readbyte(disableStructBase + 0x14)
	if SCREEN.PerMonDetails[index].Trapped then
		SCREEN.PerMonDetails[index].Trapped.source = cannotEscapeSource
	end
	local lockOnSource = Memory.readbyte(disableStructBase + 0x15)
	if SCREEN.PerMonDetails[index].LockOn then
		--199 = Lock-On
		SCREEN.PerMonDetails[index].LockOn.source = lockOnSource
	end
	--[[
		local truantCheck = Memory.readbyte(disableStructBase + 0x18)
		--Leaving the logic in, but opting to not include Truant turn info since it could reveal the mon had truant before it was tracked
		if truantCheck == 1 then
		if SCREEN.PerMonDetails[index][Resources[SCREEN.Key].EffectTruant] then
			SCREEN.PerMonDetails[index][Resources[SCREEN.Key].EffectTruant].active = true
		else
			SCREEN.PerMonDetails[index][Resources[SCREEN.Key].EffectTruant] = {active = true}
		end
	end
	]]--
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
local function loadWishStruct(index)
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
	local wishStructBase = GameSettings.gWishFutureKnock
	local futureSightCounter = Memory.readbyte(wishStructBase + (index * 0x1))
	if futureSightCounter ~= 0 then
		local futureSightSource = Memory.readbyte(wishStructBase + 0x04 + (index * 0x1))
		SCREEN.PerMonDetails[index].FutureAttack = {
			label = Resources[SCREEN.Key].EffectFutureSight,
			source = futureSightSource,
			remainingTurns = futureSightCounter}
	end
	local wishCounter = Memory.readbyte(wishStructBase + 0x20 + (index * 0x1))
	if wishCounter ~= 0 then
		local wishSource = Memory.readbyte(wishStructBase + 0x24 + (index * 0x1))
		--273 = Wish
		SCREEN.PerMonDetails[index].Wish = {
			label = Resources.Game.MoveNames[273],
			source = wishSource,
			remainingTurns = wishCounter}
	end
	local knockOffCheck = Memory.readbyte(wishStructBase + 0x29 + (index * 0x1) + Utils.inlineIf(index<2,0,1))
	if knockOffCheck ~= 0 then
		--282 = Knock Off
		SCREEN.PerMonDetails[index].KnockOff = {label = Resources.Game.MoveNames[282]}
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
local function loadOther(index)
	local lastMoveID = Battle.LastMoves[index] or 0
	--local lastMoveID = Battle.lastEnemyMoveId
	local moveText = Resources[SCREEN.Key].TextNotAvailable
	if MoveData.isValid(lastMoveID) then
		moveText = MoveData.Moves[lastMoveID].name
	end
	SCREEN.PerMonDetails[index] = SCREEN.PerMonDetails[index] or {}
	SCREEN.PerMonDetails[index].LastMove = {
			label = Resources[SCREEN.Key].TextLastMove,
			value = moveText
		}
end

function BattleDetailsScreen.loadData()
	resetBattleDetails()
	loadFieldEffects()
	for i=0,Battle.numBattlers-1,1 do
		loadStatus2(i)
		loadStatus3(i)
		loadSideStatuses(i)
		loadDisableStruct(i)
		loadWishStruct(i)
		-- loadOther(i) -- info not currently recorded
	end
	SCREEN.resetIndex()
end

function BattleDetailsScreen.resetIndex()
	SCREEN.viewingIndividualStatuses = true
	SCREEN.viewingSideStauses = false
	SCREEN.viewedMonIndex = 0
	SCREEN.viewedSideIndex = 0

	SCREEN.Buttons.AllyTeam:updateSelf()
	SCREEN.Buttons.EnemyTeam:updateSelf()
end

local function parseInput(value)
	local text = ""
	text = "- " .. value.label

	if value.type then
		text = text .. " (" .. value.type .. ")"
	elseif value.move and MoveData.isValid(value.move) then
		text = text .. " (" .. MoveData.Moves[value.move].name .. ")"
	elseif value.count then
		text = text .. ": " .. value.count
	elseif value.remainingTurns then
		text = text .. ": " .. value.remainingTurns .. " " .. Resources[SCREEN.Key].TextTurn
		if value.remainingTurns > 1 or value.remainingTurns == 0 then
			text = text .. "s"
		end
		text = text .. " " .. Resources[SCREEN.Key].TextTurnsRemaining
	elseif value.totalTurns then
		text = text .. " (" .. value.totalTurns .. ")"
	elseif value.source then
		local sourceMonIndex = Battle.Combatants[Battle.IndexMap[value.source]] or 0
		local sourceMonId = Tracker.getPokemon(sourceMonIndex,value.source%2==0).pokemonID
		local sourceMonName = PokemonData.Pokemon[sourceMonId].name
		text = text .. " (" .. sourceMonName .. ")"
	elseif value.sources then
		text = text .. " ("
		local i = 0
		for sourceKey, sourceValue in pairs(value.sources) do
			if i > 0 then
				text = text .. ", "
			end
			local sourceMonIndex = Battle.Combatants[Battle.IndexMap[sourceKey]] or 0
			local sourceMonId = Tracker.getPokemon(sourceMonIndex,sourceKey%2==0).pokemonID
			local sourceMonName = PokemonData.Pokemon[sourceMonId].name
			text = text .. sourceMonName
			i = i + 1
		end
		text = text .. ")"
	end
	return text
end

local function drawTitle()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local offsetY = Constants.SCREEN.MARGIN - 1
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS[SCREEN.Colors.text]
	local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill])

	local screenTitle = Utils.toUpperUTF8(Resources[SCREEN.Key].Title)

	--Background
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SCREEN.Colors.boxFill])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, bottomEdge, Theme.COLORS[SCREEN.Colors.border], Theme.COLORS[SCREEN.Colors.boxFill])

	--Header
	Drawing.drawHeader(offsetX, offsetY, screenTitle, textColor, boxInfoTopShadow)
	offsetY = offsetY + 16
	offsetX = offsetX + 2

	--Battle scope details
	Drawing.drawText(offsetX,offsetY, Resources[SCREEN.Key].TextTerrain .. ": " .. SCREEN.BattleDetails.Terrain, textColor, boxInfoTopShadow)
	offsetY = offsetY + linespacing
	Drawing.drawText(offsetX,offsetY, Resources[SCREEN.Key].TextWeather .. ": " .. SCREEN.BattleDetails.Weather, textColor, boxInfoTopShadow)
	offsetY = offsetY + linespacing
	Drawing.drawText(offsetX,offsetY, Resources[SCREEN.Key].TextTurn .. ": " .. (Battle.turnCount or 0 ) + 1, textColor, boxInfoTopShadow)
	offsetY = Constants.SCREEN.MARGIN + 50

	local prefix = Resources[SCREEN.Key].TextAllied
	local suffix = Resources[SCREEN.Key].TextTeam
	if SCREEN.viewingIndividualStatuses then
		if SCREEN.viewedMonIndex % 2 == 1 then
			prefix = Resources[SCREEN.Key].TextEnemy
		end
		suffix = Resources[SCREEN.Key].TextMon
	elseif not SCREEN.viewingSideStauses then
	 	prefix = Resources[SCREEN.Key].TextField
		suffix = ""
	elseif SCREEN.viewedSideIndex % 2 == 1 then
		prefix = Resources[SCREEN.Key].TextEnemy
	end
	Drawing.drawText(offsetX,offsetY, prefix .. " " .. suffix, highlightColor, boxInfoTopShadow,nil, nil, "underline")--, 10, Constants.Font.FAMILY, "bold")
end

local function drawBattleDetailsUI()
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 62
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS[SCREEN.Colors.text]
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill])

	local linesOnPage = 0

	local size = 0
	local allBattleStatuses = SCREEN.BattleDetails
	local weatherText
	if allBattleStatuses.WeatherTurns > 0 then
		size = size + 1
		weatherText =  Resources[SCREEN.Key].TextWeatherTurns .. " " .. Resources[SCREEN.Key].TextTurnsRemaining .. ":  " .. allBattleStatuses.WeatherTurns
		Drawing.drawText(offsetX,offsetY, weatherText, textColor, boxInfoTopShadow)
		offsetY = offsetY + linespacing + 1
		linesOnPage = linesOnPage + 1
	end

	for key, value in pairs(allBattleStatuses) do
		size = size + 1
		if linesOnPage < SCREEN.pageSize and key ~= "Weather" and key ~= "Terrain" and key ~= "WeatherTurns" then
			local text = parseInput(value)
			Drawing.drawText(offsetX,offsetY, text, textColor, boxInfoTopShadow)
			offsetY = offsetY + linespacing + 1
			linesOnPage = linesOnPage + 1
		end
	end
	SCREEN.numPages  = math.ceil(size/7)
end

local function drawPerSideUI()
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 62
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS[SCREEN.Colors.text]
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill])

	local linesOnPage = 0

	local allSideStatuses = SCREEN.PerSideDetails[SCREEN.viewedSideIndex]

	local size = 0
	for key, value in pairs(allSideStatuses) do
		size = size + 1
		if linesOnPage < SCREEN.pageSize then
			local text = parseInput(value)
			Drawing.drawText(offsetX,offsetY, text, textColor, boxInfoTopShadow)
			offsetY = offsetY + linespacing + 1
			linesOnPage = linesOnPage + 1
		end
	end
	SCREEN.numPages  = math.ceil(size/7)
end

local function drawPerMonUI()
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 62
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS[SCREEN.Colors.text]
	local boxInfoTopShadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill])

	local size = 0

	local allMonStatuses = SCREEN.PerMonDetails[SCREEN.viewedMonIndex]

	if allMonStatuses.LastMove then
		size = size + 1
		if size > (SCREEN.currentPage - 1) * SCREEN.pageSize and size <= (SCREEN.currentPage) * SCREEN.pageSize then
			local firstLine = "- ".. allMonStatuses.LastMove.label .. ": " .. allMonStatuses.LastMove.value
			Drawing.drawText(offsetX,offsetY, firstLine, textColor, boxInfoTopShadow)
			offsetY = offsetY + linespacing + 1
		end
	end
	for key, value in pairs(allMonStatuses) do
		if key ~= "LastMove" then
			size = size + 1
			if size > (SCREEN.currentPage - 1) * SCREEN.pageSize and size <= (SCREEN.currentPage) * SCREEN.pageSize then
				local text = parseInput(value)

				Drawing.drawText(offsetX,offsetY, text, textColor, boxInfoTopShadow)
				offsetY = offsetY + linespacing + 1
			end
		end
	end
	SCREEN.numPages  = math.ceil(size/7)

end

local function drawBattleDiagram()
	local ballColorList = { 0xFF000000, 0xFFF04037, 0xFFFFFFFF, }
	local inactiveBallColorList = { 0xFF000000, 0xFFb3b3b3, 0xFFFFFFFF, }
	local defaultArrowColorList = {Theme.COLORS[SCREEN.Colors.text]}
	local selectedArrowColorList = {Theme.COLORS[SCREEN.Colors.highlight]}
	local BattleBox = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 91,y=Constants.SCREEN.MARGIN + 20,height=30,width=45}
	local EnemyTeamBox = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100,y=Constants.SCREEN.MARGIN + 20,height=15,width=36}
	local AllyTeamBox = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100,y=Constants.SCREEN.MARGIN + 35,height=15,width=36}
	local LeftAllyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102,y=Constants.SCREEN.MARGIN + 37,height=11,width=11}
	local RightAllyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 116,y=Constants.SCREEN.MARGIN + 37,height=11,width=11}
	local RightEnemyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 109,y=Constants.SCREEN.MARGIN + 22,height=11,width=11}
	local LeftEnemyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 123,y=Constants.SCREEN.MARGIN + 22,height=11,width=11}

	local TeamBoxes = {[0] = AllyTeamBox, [1] = EnemyTeamBox}
	local MonBoxes = {[0] = LeftAllyBall, [1] = LeftEnemyBall, [2] = RightAllyBall, [3] = RightEnemyBall}

	--Draw battle box first so team box is highlighted properly
	if SCREEN.viewingSideStauses or SCREEN.viewingIndividualStatuses then
		gui.drawRectangle(BattleBox.x, BattleBox.y, BattleBox.width, BattleBox.height, Theme.COLORS[SCREEN.Colors.border], Theme.COLORS[SCREEN.Colors.boxFill])
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleBox.x + 2, BattleBox.y + 11, defaultArrowColorList)
	end
	--Draw Team Boxes
	if SCREEN.viewingSideStauses then
		gui.drawRectangle(TeamBoxes[1-SCREEN.viewedSideIndex].x, TeamBoxes[1-SCREEN.viewedSideIndex].y, TeamBoxes[1-SCREEN.viewedSideIndex].width, TeamBoxes[1-SCREEN.viewedSideIndex].height, Theme.COLORS[SCREEN.Colors.border], Theme.COLORS[SCREEN.Colors.boxFill])
		gui.drawRectangle(TeamBoxes[SCREEN.viewedSideIndex].x, TeamBoxes[SCREEN.viewedSideIndex].y, TeamBoxes[SCREEN.viewedSideIndex].width, TeamBoxes[SCREEN.viewedSideIndex].height, Theme.COLORS[SCREEN.Colors.highlight], Theme.COLORS[SCREEN.Colors.boxFill])
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, TeamBoxes[0].x + 30, TeamBoxes[0].y + 3, Utils.inlineIf(SCREEN.viewedSideIndex==0,selectedArrowColorList,defaultArrowColorList), nil)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, TeamBoxes[1].x + 2, TeamBoxes[1].y + 3, Utils.inlineIf(SCREEN.viewedSideIndex==1,selectedArrowColorList,defaultArrowColorList), nil)
	else
		gui.drawRectangle(TeamBoxes[0].x, TeamBoxes[0].y, TeamBoxes[0].width, TeamBoxes[0].height, Theme.COLORS[SCREEN.Colors.border], Theme.COLORS[SCREEN.Colors.boxFill])
		gui.drawRectangle(TeamBoxes[1].x, TeamBoxes[1].y, TeamBoxes[1].width, TeamBoxes[1].height, Theme.COLORS[SCREEN.Colors.border], Theme.COLORS[SCREEN.Colors.boxFill])
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, TeamBoxes[0].x + 30, TeamBoxes[0].y + 3, defaultArrowColorList)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, TeamBoxes[1].x + 2, TeamBoxes[1].y + 3, defaultArrowColorList)
	end

	--Draw Mon Boxes
	if SCREEN.viewingIndividualStatuses then
		Drawing.drawSelectionIndicators(
			MonBoxes[SCREEN.viewedMonIndex].x,
			MonBoxes[SCREEN.viewedMonIndex].y,
			MonBoxes[SCREEN.viewedMonIndex].width,
			MonBoxes[SCREEN.viewedMonIndex].height, Theme.COLORS[SCREEN.Colors.highlight], 1, 3, 0)
	end
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[0].x, MonBoxes[0].y, ballColorList)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[1].x, MonBoxes[1].y, ballColorList)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[2].x, MonBoxes[2].y, Utils.inlineIf(Battle.numBattlers == 4,ballColorList,inactiveBallColorList))
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[3].x, MonBoxes[3].y, Utils.inlineIf(Battle.numBattlers == 4,ballColorList,inactiveBallColorList))

	if not SCREEN.viewingSideStauses and not SCREEN.viewingIndividualStatuses then
		gui.drawRectangle(BattleBox.x, BattleBox.y, BattleBox.width, BattleBox.height, Theme.COLORS[SCREEN.Colors.highlight])
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleBox.x + 2, BattleBox.y + 11, selectedArrowColorList)
	end
end

local function drawPaging()
	if SCREEN.numPages > 1 then
		local offsetX = SCREEN.Buttons.PageLeft.box[1]
		local offsetY = SCREEN.Buttons.PageLeft.box[2]
		local linespacing = Constants.SCREEN.LINESPACING - 1
		local textColor = Theme.COLORS[SCREEN.Colors.text]
		local shadowColor = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill])
		if SCREEN.currentPage > 1 then
			Drawing.drawButton(SCREEN.Buttons.PageLeft, shadowColor)
		end
		Drawing.drawText(offsetX + 14, offsetY - 3, SCREEN.currentPage .. "/" .. SCREEN.numPages, textColor, shadowColor)
		if SCREEN.currentPage < SCREEN.numPages then
			Drawing.drawButton(SCREEN.Buttons.PageRight, shadowColor)
		end
	end
end

function BattleDetailsScreen.drawScreen()
	if not Battle.inActiveBattle() then
		SCREEN.Buttons.Back.onClick()
		return
	end
	drawTitle()
	drawBattleDiagram()
	if SCREEN.viewingIndividualStatuses then
		drawPerMonUI()
	elseif SCREEN.viewingSideStauses then
		drawPerSideUI()
	else
		drawBattleDetailsUI()
	end
	drawPaging()
	Drawing.drawButton(SCREEN.Buttons.Back)
end

function BattleDetailsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end
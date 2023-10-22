BattleEffectsScreen = {
	viewingIndividualStatuses = false,
	viewingSideStauses = false,
	viewedMonIndex = 0,
	effectMonIndex = -1,
	viewedSideIndex = 0,
	currentPage = 1,
	numPages = 1,
	pageSize = 7,
	testing = false,
	PerSideDetails = {
		[0] = {},
		[1] = {},
	},
	PerMonDetails = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	}
}
function loadFieldEffects()
	loadTerrain()
	loadWeather()
	local gPaydayMoney = Memory.readword(GameSettings.gPaydayMoney)
	if gPaydayMoney ~= 0 then
		BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectPayDay] = {active = true, amount = gPaydayMoney}
	end
end

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
	local weatherByte = Memory.readbyte(GameSettings.gBattleWeather)
	local weatherTurns = Memory.readbyte(GameSettings.gWishFutureKnock + 0x28)

	if weatherByte == 0 then
		BattleEffectsScreen.BattleDetails.Weather = BattleEffectsScreen.WeatherNameMap["default"]
		BattleEffectsScreen.BattleDetails.WeatherTurns = 0
	else
		local weatherBitIndex = 0
		while weatherByte > 1 do
			weatherByte = Utils.bit_rshift(weatherByte, 1)
			weatherBitIndex = weatherBitIndex + 1
		end
		local weatherText = BattleEffectsScreen.WeatherNameMap[weatherBitIndex]
		BattleEffectsScreen.BattleDetails.Weather = Utils.inlineIf(weatherText ~= nil,weatherText, BattleEffectsScreen.WeatherNameMap["default"])
		--Weather Turns are not reset to 0 when temporary weather becomes permanent
		if weatherBitIndex == 0 or weatherBitIndex == 3 or weatherBitIndex == 5 or weatherBitIndex == 7 then
			BattleEffectsScreen.BattleDetails.WeatherTurns = weatherTurns
		else
			BattleEffectsScreen.BattleDetails.WeatherTurns = 0
		end
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
	local status2Data = Memory.readdword(GameSettings.gBattleMons + (index * 0x58) +0x50)
	local status2Map = Utils.generatebitwisemap(status2Data, 32)
	if status2Map[0] or status2Map[1] or status2Map[2] then
		turnsText = string.format("1- 4 %ss", Resources.BattleEffectsScreen.TextTurn)
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectConfused] = {active=true, totalTurns = turnsText}
	end
	if status2Map[4] or status2Map[5] or status2Map[6] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectUproar] = {active=true}
	end
	if status2Map[8] or status2Map[9] then
		remainingTurnsBide = (Utils.inlineIf(status2Map[8],1,0) + Utils.inlineIf(status2Map[9],2,0))
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectBide] = {active=true, remainingTurns=remainingTurnsBide}
	end
	if status2Map[12] and remainingTurnsBide == nil then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectMustAttack] = {active=true}
	end
	if status2Map[13] or status2Map[14] or status2Map[15] then
		local sourceBattlerIndex = Memory.readbyte(battleStructAddress + 0x14 + index)
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTrapped] = {active=true, source = sourceBattlerIndex}
	end
	if status2Map[16] or status2Map[17] or status2Map[18] or status2Map[19] then
		local infatuationTarget = Utils.inlineIf(status2Map[16],0,nil) or Utils.inlineIf(status2Map[17],1,nil) or Utils.inlineIf(status2Map[18],2,nil) or Utils.inlineIf(status2Map[19],3,0)
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectAttract] = {active=true, source=infatuationTarget}
	end
	if status2Map[20] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFocusEnergy] = {active=true}
	end
	if status2Map[21] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTransform] = {active=true}
	end
	if status2Map[22] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCannotAct] = {active=true}
	end
	if status2Map[23] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectRage] = {active=true}
	end
	--[[
		--leaving here since it is technically a battle status, but the player can physically see the substitute in the battle
		if status2Map[24] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectSubstitute] = {active=true}
	end
	]]--
	if status2Map[25] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDestinyBond] = {active=true}
	end
	if status2Map[26] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCannotEscape] = {active=true}
	end
	if status2Map[27] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectNightmare] = {active=true}
	end
	if status2Map[28] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCurse] = {active=true}
	end
	if status2Map[29] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectForesight] = {active=true}
	end
	if status2Map[30] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDefenseCurl] = {active=true}
	end
	if status2Map[31] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTorment] = {active=true}
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
	local status3Data = Memory.readdword(GameSettings.gStatuses3 + index * (0x04))
	local status3Map = Utils.generatebitwisemap(status3Data, 21)
	if status3Map[2] then
		local leechSeedSource = (Utils.inlineIf(status3Map[0],1,0) + Utils.inlineIf(status3Map[1],2,0))
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLeechSeed] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLeechSeed].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLeechSeed].source = leechSeedSource
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLeechSeed] = {active=true, source=leechSeedSource}
		end
	end
	if status3Map[3] or status3Map[4] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLockOn] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLockOn].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLockOn] = {active=true}
		end
	end
	if status3Map[5] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectPerishSong] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectPerishSong].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectPerishSong] = {active=true}
		end
	end
	if status3Map[6] or status3Map[7] or status3Map[18] then
		local invulnerableType = Utils.inlineIf(status3Map[6],Resources.BattleEffectsScreen.EffectAirborne,nil) or Utils.inlineIf(status3Map[7],Resources.BattleEffectsScreen.EffectUnderground,nil) or Utils.inlineIf(status3Map[18],Resources.BattleEffectsScreen.EffectUnderwater,"")
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectSemiInvulnerable] then
			BattleEffectsScreen.PerMonDetails[index][invulnerableType].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][invulnerableType] = {active=true}
		end
	end
	if status3Map[8] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectMinimize] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectMinimize].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectMinimize] = {active=true}
		end
	end
	if status3Map[9] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCharge] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCharge].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCharge] = {active=true}
		end
	end
	if status3Map[10] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectIngrain] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectIngrain].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectIngrain] = {active=true}
		end
	end
	if status3Map[11] or status3Map[12] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDrowsy] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDrowsy].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDrowsy] = {active=true}
		end
	end
	if status3Map[13] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectImprison] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectImprison].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectImprison] = {active=true}
		end
	end
	if status3Map[14] then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectGrudge] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectGrudge].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectGrudge] = {active=true}
		end
	end
	if status3Map[16] then
		if BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectMudSport] then
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectMudSport].active = true
		else
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectMudSport] = {active=true}
		end
		local sources = BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectMudSport].sources
		if sources then
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectMudSport].sources[index] = true
		else
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectMudSport].sources = {[index] = true}
		end
	end
	if status3Map[17] then
		if BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectWaterSport] then
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectWaterSport].active = true
		else
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectWaterSport] = {active=true}
		end
		local sources = BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectWaterSport].sources
		if sources then
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectWaterSport].sources[index] = true
		else
			BattleEffectsScreen.BattleDetails[Resources.BattleEffectsScreen.EffectWaterSport].sources = {[index] = true}
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
		index = 0
	end
	local sideStatuses = Memory.readword(GameSettings.gStatuses3 + (index * 0x02))
	--local sideStatuses = 65535
	local sideTimersBase = GameSettings.gSideTimers + (index * 0x0C)
	local sideStatusMap = Utils.generatebitwisemap(sideStatuses, 9)
	if sideStatusMap[0] then
		local turnsLeftReflect = Memory.readbyte(sideTimersBase)
		BattleEffectsScreen.PerSideDetails[index][Resources.BattleEffectsScreen.EffectReflect] = {active = true,remainingTurns = turnsLeftReflect}
	end
	if sideStatusMap[1] then
		local turnsLeftLightScreen = Memory.readbyte(sideTimersBase + 0x02)
		BattleEffectsScreen.PerSideDetails[index][Resources.BattleEffectsScreen.EffectLightScreen] = {active = true,remainingTurns = turnsLeftLightScreen}
	end
	if sideStatusMap[4] then
		local amountSpikes = Memory.readbyte(sideTimersBase + 0x0A)
		BattleEffectsScreen.PerSideDetails[index][Resources.BattleEffectsScreen.EffectSpikes] = {active = true,count = amountSpikes}
	end
	if sideStatusMap[5] then
		local turnsLeftSafeguard = Memory.readbyte(sideTimersBase + 0x06)
		BattleEffectsScreen.PerSideDetails[index][Resources.BattleEffectsScreen.EffectSafeguard] = {active = true,remainingTurns = turnsLeftSafeguard}
	end
	if sideStatusMap[8] then
		local turnsLeftMist = Memory.readbyte(sideTimersBase + 0x04)
		BattleEffectsScreen.PerSideDetails[index][Resources.BattleEffectsScreen.EffectMist] = {active = true,remainingTurns = turnsLeftMist}
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
	local disableStructBase = GameSettings.gDisableStructs + (index * 0x1C)
	local disabledMove = Memory.readword(disableStructBase + 0x04)
	if disabledMove ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDisable] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDisable].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDisable].move = disabledMove
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectDisable] = {active = true, move = disabledMove}
		end
	end
	local encoredMove = Memory.readword(disableStructBase + 0x06)
	if encoredMove ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectEncore] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectEncore].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectEncore].move = encoredMove
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectEncore] = {active = true, move = encoredMove}
		end
	end
	local protectUses = Memory.readbyte(disableStructBase + 0x08)
	if protectUses ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectProtectUses] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectProtectUses].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectProtectUses].count = protectUses
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectProtectUses] = {active = true, count = protectUses}
		end
	end
	local stockpileCount = Memory.readbyte(disableStructBase + 0x09)
	if stockpileCount ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectStockpile] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectStockpile].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectStockpile].count = stockpileCount
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectStockpile] = {active = true, count = stockpileCount}
		end
	end

	if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectPerishSong] and BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectPerishSong].active == true then
		local perishSongCount = Utils.getbits(Memory.readword(disableStructBase + 0x0F),0,4)
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectPerishSong].count = perishSongCount + 1
	end
	local furyCutterCount = Memory.readbyte(disableStructBase + 0x10)
	if furyCutterCount ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFuryCutter] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFuryCutter].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFuryCutter].count = furyCutterCount
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFuryCutter] = {active = true, count = furyCutterCount}
		end
	end
	local rolloutCount = Utils.getbits(Memory.readword(disableStructBase + 0x11),0,4)
	if rolloutCount ~= 0 then
		local lockedMoves = Memory.readword (GameSettings.gLockedMoves + (index * 0x02))
		local moveName = Resources.Game.MoveNames[lockedMoves] or ""
		if BattleEffectsScreen.PerMonDetails[index][moveName] then
			BattleEffectsScreen.PerMonDetails[index][moveName].active = true
			BattleEffectsScreen.PerMonDetails[index][moveName].remainingTurns = rolloutCount
		else
			BattleEffectsScreen.PerMonDetails[index][moveName] = {active = true, remainingTurns = rolloutCount}
		end
	end
	local tauntTimer = Utils.getbits(Memory.readword(disableStructBase + 0x13),0,4)
	if tauntTimer ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTaunt] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTaunt].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTaunt].remainingTurns = tauntTimer
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTaunt] = {active = true, remainingTurns = tauntTimer}
		end
	end
	local cannotEscapeSource = Memory.readbyte(disableStructBase + 0x14)
	if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCannotEscape] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectCannotEscape].source = cannotEscapeSource
	end
	local lockOnSource = Memory.readbyte(disableStructBase + 0x15)
	if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLockOn] then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLockOn].source = lockOnSource
	end
	local truantCheck = Memory.readbyte(disableStructBase + 0x18)
	--[[
		--Leaving the logic in, but opting to not include Truant turn info since it could reveal the mon had truant before it was tracked
		if truantCheck == 1 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTruant] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTruant].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectTruant] = {active = true}
		end
	end
	]]--
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
	local wishStructBase = GameSettings.gWishFutureKnock
	local futureSightCounter = Memory.readbyte(wishStructBase + (index * 0x1))
	if futureSightCounter ~= 0 then
		local futureSightSource = Memory.readbyte(wishStructBase + 0x04 + (index * 0x1))
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFutureSight] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFutureSight].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFutureSight].source = futureSightSource
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFutureSight].remainingTurns = futureSightCounter
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectFutureSight] = {active = true, source = futureSightSource, remainingTurns = futureSightCounter}
		end
	end
	local wishCounter = Memory.readbyte(wishStructBase + 0x20 + (index * 0x1))
	if wishCounter ~= 0 then
		local wishSource = Memory.readbyte(wishStructBase + 0x24 + (index * 0x1))
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectWish] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectWish].active = true
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectWish].source = wishSource
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectWish].remainingTurns = wishCounter
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectWish] = {active = true, source = wishSource, remainingTurns = wishCounter}
		end
	end
	local knockOffCheck = Memory.readbyte(wishStructBase + 0x29 + (index * 0x1) + Utils.inlineIf(index<2,0,1))
	if knockOffCheck ~= 0 then
		if BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectKnockOff] then
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectKnockOff].active = true
		else
			BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectKnockOff] = {active = true}
		end
	end
end

function loadOther(index)
	--local lastMoveID = Battle.LastMoves[index]
	local lastMoveID = Battle.lastEnemyMoveId
	if MoveData.isValid(lastMoveID) then
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLastMove] = MoveData.Moves[lastMoveID].name
	else
		BattleEffectsScreen.PerMonDetails[index][Resources.BattleEffectsScreen.EffectLastMove] = Resources.BattleEffectsScreen.TextNotAvailable
	end
end

function BattleEffectsScreen.loadData()
	BattleEffectsScreen.resetBattleDetails()
	loadFieldEffects()
	for i=0,Battle.numBattlers-1,1 do
		loadStatus2(i)
		loadStatus3(i)
		loadSideStatuses(i)
		loadDisableStruct(i)
		loadWishStruct(i)
		loadOther(i)
	end
end

function BattleEffectsScreen.resetBattleDetails()
	BattleEffectsScreen.BattleDetails = {
		Weather = Resources.BattleEffectsScreen.WeatherDefault,
		Terrain = Resources.BattleEffectsScreen.TerrainDefault,
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
	BattleEffectsScreen.viewedMonIndex = 0
	BattleEffectsScreen.viewedSideIndex = 0
	BattleEffectsScreen.effectMonIndex = -1
	BattleEffectsScreen.viewingIndividualStatuses = true
	BattleEffectsScreen.viewingSideStauses = false

	BattleEffectsScreen.currentPage = 1
	BattleEffectsScreen.numPages = 1
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

	local screenTitle = Resources.BattleEffectsScreen.Title

	--Background
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS["Upper box background"])
	gui.drawRectangle(Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN, rightEdge, bottomEdge, Theme.COLORS["Upper box border"], Theme.COLORS["Upper box background"])

	--Header
	Drawing.drawText(offsetX, offsetY, screenTitle, textColor, nil, 15, Constants.Font.FAMILY)
	offsetY = offsetY + 15
	offsetX = offsetX + 2

	--Battle scope details
	Drawing.drawText(offsetX,offsetY, Resources.BattleEffectsScreen.TextTerrain .. ": " .. BattleEffectsScreen.BattleDetails.Terrain, textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY + linespacing
	Drawing.drawText(offsetX,offsetY, Resources.BattleEffectsScreen.TextWeather .. ": " .. BattleEffectsScreen.BattleDetails.Weather, textColor, nil, linespacing, Constants.Font.FAMILY)
	offsetY = offsetY - linespacing - linespacing + 33

	local prefix = Resources.BattleEffectsScreen.TextAllied
	local suffix = Resources.BattleEffectsScreen.TextTeam
	if BattleEffectsScreen.viewingIndividualStatuses then
		if BattleEffectsScreen.viewedMonIndex % 2 == 1 then
			prefix = Resources.BattleEffectsScreen.TextEnemy
		end
		suffix = Resources.BattleEffectsScreen.TextMon
	elseif not BattleEffectsScreen.viewingSideStauses then
	 	prefix = Resources.BattleEffectsScreen.TextField
		suffix = ""
	elseif BattleEffectsScreen.viewedSideIndex % 2 == 1 then
		prefix = Resources.BattleEffectsScreen.TextEnemy
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
	local allBattleStatuses = BattleEffectsScreen.BattleDetails
	local weatherText
	if allBattleStatuses.WeatherTurns > 0 then
		weatherText =  Resources.BattleEffectsScreen.TextWeatherTurns .. " " .. Resources.BattleEffectsScreen.TextTurnsRemaining .. ":  " .. allBattleStatuses.WeatherTurns
		Drawing.drawText(offsetX,offsetY, weatherText, textColor, nil, linespacing, Constants.Font.FAMILY)
		offsetY = offsetY + linespacing + 1
		linesOnPage = linesOnPage + 1
	end

	for key, value in pairs(allBattleStatuses) do
		if key ~= "Weather" and key ~= "Terrain" and key ~= "WeatherTurns" and value.active then
			local text = parseInput(key,value)
			Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
			offsetY = offsetY + linespacing + 1
			linesOnPage = linesOnPage + 1
		end
		if linesOnPage == BattleEffectsScreen.pageSize then break end
	end
end

function drawPerSideUI()
	local rightEdge = Constants.SCREEN.RIGHT_GAP - (2 * Constants.SCREEN.MARGIN)
	local bottomEdge = Constants.SCREEN.HEIGHT - (2 * Constants.SCREEN.MARGIN)
	local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10
	local offsetY = Constants.SCREEN.MARGIN + 50
	local linespacing = Constants.SCREEN.LINESPACING - 1
	local textColor = Theme.COLORS["Default text"]
	local linesOnPage = 0

	local allSideStatuses = BattleEffectsScreen.PerSideDetails[BattleEffectsScreen.viewedSideIndex]

	local Xdelta = 2
	for key, value in pairs(allSideStatuses) do
		local text = parseInput(key,value)
		Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
		Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
		offsetY = offsetY + linespacing + 1
		linesOnPage = linesOnPage + 1
		if linesOnPage == BattleEffectsScreen.pageSize then break end
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
	local allMonStatuses = BattleEffectsScreen.PerMonDetails[BattleEffectsScreen.viewedMonIndex]
	if allMonStatuses[Resources.BattleEffectsScreen.TextLastMove] then
		local firstLine = "- ".. Resources.BattleEffectsScreen.TextLastMove .. ": " .. allMonStatuses[Resources.BattleEffectsScreen.TextLastMove]
		Drawing.drawText(offsetX,offsetY, firstLine, textColor, nil, linespacing, Constants.Font.FAMILY)
		offsetY = offsetY + linespacing + 1
		linesOnPage = linesOnPage + 1
	end
	for key, value in pairs(allMonStatuses) do
		if key ~= Resources.BattleEffectsScreen.TextLastMove then
			local text = parseInput(key,value)

			Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
			Drawing.drawText(offsetX,offsetY, text, textColor, nil, linespacing, Constants.Font.FAMILY)
			offsetY = offsetY + linespacing + 1
			linesOnPage = linesOnPage + 1
			if linesOnPage == BattleEffectsScreen.pageSize then break end
		end
	end
end

function parseInput(key, value)
	local text = ""
	if value.active then
		text = "- " .. key

		if value.type then
			text = text .. " (" .. value.type .. ")"
		elseif value.move and MoveData.isValid(value.move) then
			text = text .. " (" .. MoveData.Moves[value.move].name .. ")"
		elseif value.count then
			text = text .. ": " .. value.count
		elseif value.remainingTurns then
			text = text .. ": " .. value.remainingTurns .. " " .. Resources.BattleEffectsScreen.TextTurn
			if value.remainingTurns > 1 or value.remainingTurns == 0 then
				text = text .. "s"
			end
			text = text .. " " .. Resources.BattleEffectsScreen.TextTurnsRemaining
		elseif value.totalTurns then
			text = text .. " (" .. value.totalTurns .. ")"
		elseif value.source then
			local sourceMonIndex = Battle.Combatants[Battle.IndexMap[value.source]] or {}
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
				local sourceMonIndex = Battle.Combatants[Battle.IndexMap[sourceKey]] or {}
				local sourceMonId = Tracker.getPokemon(sourceMonIndex,sourceKey%2==0).pokemonID
				local sourceMonName = PokemonData.Pokemon[sourceMonId].name
				text = text .. sourceMonName
				i = i + 1
			end
			text = text .. ")"
		end
	end
	return text
end


function drawBattleDiagram()
	local ballColorList = { 0xFF000000, 0xFFF04037, 0xFFFFFFFF, }
	local inactiveBallColorList = { 0xFF000000, 0xFFb3b3b3, 0xFFFFFFFF, }
	local defaultArrowColorList = {Theme.COLORS["Default text"]}
	local selectedArrowColorList = {Theme.COLORS["Positive text"]}
	local BattleBox = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 90,y=Constants.SCREEN.MARGIN + 20,height=36,width=50}
	local AllyTeamBox = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100,y=Constants.SCREEN.MARGIN + 20,height=15,width=36}
	local EnemyTeamBox = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100,y=Constants.SCREEN.MARGIN + 35,height=15,width=36}
	local LeftAllyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102,y=Constants.SCREEN.MARGIN + 37,height=11,width=11}
	local RightAllyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115,y=Constants.SCREEN.MARGIN + 37,height=11,width=11}
	local LeftEnemyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 110,y=Constants.SCREEN.MARGIN + 22,height=11,width=11}
	local RightEnemyBall = {x=Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 123,y=Constants.SCREEN.MARGIN + 22,height=11,width=11}
	local TeamBoxes = {[0] = AllyTeamBox, [1] = EnemyTeamBox}
	local MonBoxes = {[0] = LeftAllyBall, [1] = LeftEnemyBall, [2] = RightAllyBall, [3] = RightEnemyBall}

	--Draw battle box first so team box is highlighted properly
	if BattleEffectsScreen.viewingSideStauses or BattleEffectsScreen.viewingIndividualStatuses then
		gui.drawRectangle(BattleBox.x, BattleBox.y, BattleBox.width, BattleBox.height, "Upper box border", 0x00000000)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleBox.x + 3, BattleBox.y + 11, selectedArrowColorList, null)
	end
	--Draw Team Boxes
	if BattleEffectsScreen.viewingSideStauses then
		gui.drawRectangle(TeamBoxes[BattleEffectsScreen.viewedSideIndex].x, TeamBoxes[BattleEffectsScreen.viewedSideIndex].y, TeamBoxes[BattleEffectsScreen.viewedSideIndex].width, TeamBoxes[BattleEffectsScreen.viewedSideIndex].height, "Positive text", "Upper box background")
		gui.drawRectangle(TeamBoxes[1-BattleEffectsScreen.viewedSideIndex].x, TeamBoxes[1-BattleEffectsScreen.viewedSideIndex].y, TeamBoxes[1-BattleEffectsScreen.viewedSideIndex].width, TeamBoxes[1-BattleEffectsScreen.viewedSideIndex].height, "Upper box border", "Upper box background")
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, TeamBoxes[1-BattleEffectsScreen.viewedSideIndex].x + Utils.inlineIf(BattleEffectsScreen.viewedSideIndex == 0,3,29), TeamBoxes[1-BattleEffectsScreen.viewedSideIndex].y + 3, defaultArrowColorList, null)
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, TeamBoxes[BattleEffectsScreen.viewedSideIndex].x + Utils.inlineIf(BattleEffectsScreen.viewedSideIndex == 0,3,29), TeamBoxes[BattleEffectsScreen.viewedSideIndex].y + 3, selectedArrowColorList, null)
	else
		gui.drawRectangle(TeamBoxes[0].x, TeamBoxes[0].y, TeamBoxes[0].width, TeamBoxes[0].height, "Upper box border", "Upper box background")
		gui.drawRectangle(TeamBoxes[1].x, TeamBoxes[1].y, TeamBoxes[1].width, TeamBoxes[1].height, "Upper box border", "Upper box background")
	end

	--Draw Mon Boxes
	if BattleEffectsScreen.viewingIndividualStatuses then
		Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, TeamBoxes[0].x + 29, TeamBoxes[0].y + 3, defaultArrowColorList, null)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, TeamBoxes[1].x + 3, TeamBoxes[1].x + 3, defaultArrowColorList, null)
		Drawing.drawSelectionIndicators(
			MonBoxes[BattleEffectsScreen.viewedMonIndex].x,
			MonBoxes[BattleEffectsScreen.viewedMonIndex].y,
			MonBoxes[BattleEffectsScreen.viewedMonIndex].width,
			MonBoxes[BattleEffectsScreen.viewedMonIndex].height, Theme.COLORS["Positive text"], 1, 3, 0)
	end
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[0].x, MonBoxes[0].y, ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[1].x, MonBoxes[1].y, ballColorList, null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[2].x, MonBoxes[2].y, Utils.inlineIf(Battle.numBattlers == 4,ballColorList,inactiveBallColorList), null)
	Drawing.drawImageAsPixels(Constants.PixelImages.POKEBALL, MonBoxes[3].x, MonBoxes[3].y, Utils.inlineIf(Battle.numBattlers == 4,ballColorList,inactiveBallColorList), null)

	if not BattleEffectsScreen.viewingSideStauses and not BattleEffectsScreen.viewingIndividualStatuses then
		gui.drawRectangle(BattleBox.x, BattleBox.y, BattleBox.width, BattleBox.height, "Positive text", 0x00000000)
		Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, BattleBox.x + 3, BattleBox.y + 11, selectedArrowColorList, null)
	end
end

function drawPaging()
	if BattleEffectsScreen.numPages > 1 then
		local offsetX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
		local offsetY = Constants.SCREEN.MARGIN
		local linespacing = Constants.SCREEN.LINESPACING - 1
		local textColor = Theme.COLORS["Default text"]
		local defaultArrowColorList = {Theme.COLORS["Default text"]}
		if BattleEffectsScreen.currentPage > 1 then
			Drawing.drawImageAsPixels(Constants.PixelImages.LEFT_TRIANGLE, offsetX + 45, offsetY, defaultArrowColorList, null)
		end
		Drawing.drawText(offsetX + 54, offsetY - 3, BattleEffectsScreen.currentPage .. "/" .. BattleEffectsScreen.numPages, textColor, nil, linespacing, Constants.Font.FAMILY)
		if BattleEffectsScreen.currentPage < BattleEffectsScreen.numPages then
			Drawing.drawImageAsPixels(Constants.PixelImages.RIGHT_TRIANGLE, offsetX + 78, offsetY, defaultArrowColorList, null)
		end
	end
end

function BattleEffectsScreen.drawScreen()
	if not Battle.inActiveBattle() then
		BattleEffectsScreen.Buttons.Back.onClick()
		return
	end
	drawTitle()
	drawBattleDiagram()
	if BattleEffectsScreen.viewingIndividualStatuses then
		drawPerMonUI()
	elseif BattleEffectsScreen.viewingSideStauses then
		drawPerSideUI()
	else
		drawBattleDetailsUI()
	end
	drawPaging()
	Drawing.drawButton(BattleEffectsScreen.Buttons.Back)
end

function BattleEffectsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, BattleEffectsScreen.Buttons, true)
end

function BattleEffectsScreen.initialize()
	BattleEffectsScreen.BattleDetails = {
		Weather = Resources.BattleEffectsScreen.WeatherDefault,
		Terrain = Resources.BattleEffectsScreen.TerrainDefault,
	}

	BattleEffectsScreen.WeatherNameMap = {
		[0] = Resources.BattleEffectsScreen.WeatherRain,
		[1] = Resources.BattleEffectsScreen.WeatherRain,
		[2] = Resources.BattleEffectsScreen.WeatherRain,
		[3] = Resources.BattleEffectsScreen.WeatherSandstorm,
		[4] = Resources.BattleEffectsScreen.WeatherSandstorm,
		[5] = Resources.BattleEffectsScreen.WeatherSunlight,
		[6] = Resources.BattleEffectsScreen.WeatherSunlight,
		[7] = Resources.BattleEffectsScreen.WeatherHail,
		["default"] = Resources.BattleEffectsScreen.WeatherDefault,
	}
	BattleEffectsScreen.TerrainNameMap = {
		[0] = Resources.BattleEffectsScreen.TerrainGrass,
		[1] = Resources.BattleEffectsScreen.Terrain,
		[2] = Resources.BattleEffectsScreen.TerrainSand,
		[3] = Resources.BattleEffectsScreen.TerrainUnderwater,
		[4] = Resources.BattleEffectsScreen.TerrainWater,
		[5] = Resources.BattleEffectsScreen.TerrainPond,
		[6] = Resources.BattleEffectsScreen.TerrainMountain,
		[7] = Resources.BattleEffectsScreen.TerrainCave,
		["default"] = Resources.BattleEffectsScreen.TerrainDefault,
	}
	BattleEffectsScreen.Buttons = {
		LeftOwn = {
			type = Constants.ButtonTypes.NO_BORDER,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 102, Constants.SCREEN.MARGIN + 37, 11, 11 },
			boxColors = {"Upper box border", "Upper box background"},
			isVisible = function() return true end,
			onClick = function(self)
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 0 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 0
				Program.redraw(true)
			end
		},
		LeftOther = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 123, Constants.SCREEN.MARGIN + 22, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 1 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 1
				Program.redraw(true)
			end
		},
		RightOwn = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 37, 11, 11 },
			isVisible = function() return Battle.numBattlers == 4 end,
			onClick = function(self)
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 2 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 2
				Program.redraw(true)
			end
		},
		RightOther = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 110, Constants.SCREEN.MARGIN + 22, 11, 11 },
			isVisible = function() return Battle.numBattlers == 4 end,
			onClick = function(self)
				if BattleEffectsScreen.viewingIndividualStatuses and BattleEffectsScreen.viewedMonIndex == 3 then return end
				BattleEffectsScreen.viewingIndividualStatuses = true
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedMonIndex = 3
				Program.redraw(true)
			end
		},
		AllyTeam = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 35, 36, 15 },
			isVisible = function() return true end,
			onClick = function(self)
				if BattleEffectsScreen.viewingSideStauses and BattleEffectsScreen.viewedSideIndex == 0 then return end
				BattleEffectsScreen.viewingIndividualStatuses = false
				BattleEffectsScreen.viewingSideStauses = true
				BattleEffectsScreen.viewedSideIndex = 0
				Program.redraw(true)
			end
		},
		EnemyTeam = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 100, Constants.SCREEN.MARGIN + 20, 36, 15 },
			isVisible = function() return true end,
			onClick = function(self)
				if BattleEffectsScreen.viewingSideStauses and BattleEffectsScreen.viewedSideIndex == 1 then return end
				BattleEffectsScreen.viewingIndividualStatuses = false
				BattleEffectsScreen.viewingSideStauses = true
				BattleEffectsScreen.viewedSideIndex = 1
				Program.redraw(true)
			end
		},
		BattleView = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 90, Constants.SCREEN.MARGIN + 20, 46, 30},
			isVisible = function() return true end,
			onClick = function(self)
				if not BattleEffectsScreen.viewingSideStauses and not BattleEffectsScreen.viewingIndividualStatuses then return end
				BattleEffectsScreen.viewingIndividualStatuses = false
				BattleEffectsScreen.viewingSideStauses = false
				BattleEffectsScreen.viewedSideIndex = 0
				BattleEffectsScreen.viewedMonIndex = 0
				Program.redraw(true)
			end
		},
		PageLeft = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 37, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				BattleEffectsScreen.currentPage = BattleEffectsScreen.currentPage - 1
				Program.redraw(true)
			end
		},
		PageRight = {
			type = Constants.ButtonTypes.NO_BORDER,
			boxColors = {"Upper box border", "Upper box background"},
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 115, Constants.SCREEN.MARGIN + 37, 11, 11 },
			isVisible = function() return true end,
			onClick = function(self)
				BattleEffectsScreen.currentPage = BattleEffectsScreen.currentPage + 1
				Program.redraw(true)
			end
		},
		Back = Drawing.createUIElementBackButton(function()
			Program.changeScreenView(TrackerScreen)
		end),
	}
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
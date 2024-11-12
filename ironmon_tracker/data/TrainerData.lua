-- Currently, this is only used for connecting to trainer data parsed from a randomizer log file
TrainerData = {}

-- These are populated later after the game being played is determined
TrainerData.Trainers = {}
TrainerData.OrderedIds = {}
TrainerData.GymTMs = {}
TrainerData.CommonTrainers = {} -- Commonly known trainers, used for !trainer command lookups
TrainerData.FinalTrainer = {} -- The final trainer to defeat to win Ironmon

TrainerData.TrainerGroups = {
	All = "All",
	Rival = "Rival",
	Gym = "Gym",
	Elite4 = "Elite 4",
	Boss = "Boss",
	Other = "Other",
}

-- A table of information for each different trainer class
-- 'filename' is used with prefixes and postfixes to determine which image to show, depending on the game being played
TrainerData.Classes = {
	-- Specific trainers
	GymLeader1 = 	{ filename = "gymleader-1", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader2 = 	{ filename = "gymleader-2", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader3 = 	{ filename = "gymleader-3", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader4 = 	{ filename = "gymleader-4", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader5 = 	{ filename = "gymleader-5", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader6 = 	{ filename = "gymleader-6", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader7 = 	{ filename = "gymleader-7", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader8 = 	{ filename = "gymleader-8", 	group = TrainerData.TrainerGroups.Gym, hasPostfix = true, },
	EliteFour1 = 	{ filename = "elitefour-1", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteFour2 = 	{ filename = "elitefour-2", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteFour3 = 	{ filename = "elitefour-3", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteFour4 = 	{ filename = "elitefour-4", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteChampion = { filename = "elitefour-champ", group = TrainerData.TrainerGroups.Elite4, hasPostfix = true, },
	RivalFRLGA = 	{ filename = "rival-a", 		group = TrainerData.TrainerGroups.Rival, },
	RivalFRLGB = 	{ filename = "rival-b", 		group = TrainerData.TrainerGroups.Rival, },
	RivalFRLGC = 	{ filename = "rival-c", 		group = TrainerData.TrainerGroups.Rival, },
	RivalBrendan = 	{ filename = "rival-brendan", 	group = TrainerData.TrainerGroups.Rival, hasPostfix = true, },
	RivalMay = 		{ filename = "rival-may", 		group = TrainerData.TrainerGroups.Rival, hasPostfix = true, },
	Wally = 		{ filename = "wally", 			group = TrainerData.TrainerGroups.Boss, },
	Archie = 		{ filename = "archie", 			group = TrainerData.TrainerGroups.Boss, },
	Tabitha = 		{ filename = "tabitha", 		group = TrainerData.TrainerGroups.Boss, },
	Maxie = 		{ filename = "maxie", 			group = TrainerData.TrainerGroups.Boss, },
	Courtney = 		{ filename = "courtney", 		group = TrainerData.TrainerGroups.Boss, },
	Shelly = 		{ filename = "shelly", 			group = TrainerData.TrainerGroups.Boss, },
	Matt = 			{ filename = "matt", 			group = TrainerData.TrainerGroups.Boss, },
	Steven = 		{ filename = "steven", 			group = TrainerData.TrainerGroups.Boss, },

	-- Generic trainer classes
	AromaLady = 	{ filename = "aroma-lady", },
	BattleGirl = 	{ filename = "battle-girl", },
	Beauty = 		{ filename = "beauty", },
	Biker = 		{ filename = "biker", },
	BirdKeeper = 	{ filename = "bird-keeper", },
	BlackBelt = 	{ filename = "blackbelt", },
	BugCatcher = 	{ filename = "bug-catcher", },
	BugManiac = 	{ filename = "bug-maniac", },
	Burglar = 		{ filename = "burglar", },
	Camper = 		{ filename = "camper", },
	Collector = 	{ filename = "collector", },
	Channeler = 	{ filename = "channeler", },
	CoolCouple = 	{ filename = "cool-couple", },
	CoolTrainer = 	{ filename = "cooltrainer", },
	CrushGirl = 	{ filename = "crush-girl", },
	CrushKin = 		{ filename = "crush-kin", },
	CueBall = 		{ filename = "cue-ball", },
	DragonTamer = 	{ filename = "dragon-tamer", },
	Engineer = 		{ filename = "engineer", },
	Expert = 		{ filename = "expert", },
	Fisherman = 	{ filename = "fisherman", },
	Gamer = 		{ filename = "gamer", },
	Gentleman = 	{ filename = "gentleman", },
	Guitarist = 	{ filename = "guitarist", },
	HexManiac = 	{ filename = "hex-maniac", },
	Hiker = 		{ filename = "hiker", },
	Interviewer = 	{ filename = "interviewer", },
	Juggler = 		{ filename = "juggler", },
	Kindler = 		{ filename = "kindler", },
	Lady = 			{ filename = "lady", },
	Lass = 			{ filename = "lass", },
	NinjaBoy = 		{ filename = "ninja-boy", },
	OldCouple = 	{ filename = "old-couple", },
	Painter = 		{ filename = "painter", },
	ParasolLady = 	{ filename = "parasol-lady", },
	Picnicker = 	{ filename = "picnicker", },
	PkmnBreeder = 	{ filename = "pkmn-breeder", },
	PkmnRanger = 	{ filename = "pkmn-ranger", },
	PokeFan = 		{ filename = "pokefan", },
	PokeManiac = 	{ filename = "pokemaniac", },
	Psychic = 		{ filename = "psychic", },
	RichBoy = 		{ filename = "rich-boy", },
	Rocker = 		{ filename = "rocker", },
	RuinManiac = 	{ filename = "ruin-maniac", },
	Sailor = 		{ filename = "sailor", },
	SchoolKid = 	{ filename = "school-kid", },
	Scientist = 	{ filename = "scientist", },
	SrAndJr = 		{ filename = "sr-and-jr", },
	SisAndBro = 	{ filename = "sis-and-bro", },
	SuperNerd = 	{ filename = "super-nerd", },
	SwimmerF = 		{ filename = "swimmer-f", },
	SwimmerM = 		{ filename = "swimmer-m", },
	Tamer = 		{ filename = "tamer", },
	TeamAquaGrunt = { filename = "team-aqua-grunt", },
	TeamMagmaGrunt = { filename = "team-magma-grunt", },
	TeamRocketGrunt = { filename = "team-rocket-grunt", },
	Triathlete = 	{ filename = "triathlete", },
	Tuber = 		{ filename = "tuber", },
	Twins = 		{ filename = "twins", },
	YoungCouple = 	{ filename = "young-couple", },
	Youngster = 	{ filename = "youngster", },
	Unknown = 		{ filename = "unknown", } -- Default, if none found
}

TrainerData.BlankTrainer = {
	class = TrainerData.Classes.Unknown,
}

function TrainerData.initialize()
	TrainerData.buildData()
end

function TrainerData.buildData()
	TrainerData.Trainers = {}
	TrainerData.GymTMs = {}
	TrainerData.CommonTrainers = {}
	TrainerData.FinalTrainer = {}
	if GameSettings.game == 1 then -- Ruby / Sapphire
		TrainerData.setupTrainersAsRubySapphire()
	elseif GameSettings.game == 2 then
		TrainerData.setupTrainersAsEmerald() -- Emerald
	elseif GameSettings.game == 3 then
		TrainerData.setupTrainersAsFRLG() -- FireRed / LeafGreen
	end
end

function TrainerData.getTrainerInfo(trainerId)
	return TrainerData.Trainers[trainerId or false] or TrainerData.BlankTrainer
end

-- Determines if the trainer's display name should use its in-game name (i.e. Terry) or class name (i.e. Rival)
function TrainerData.shouldUseClassName(trainerId)
	if trainerId == nil then return false end
	if GameSettings.game == 3 then
		if 326 <= trainerId and trainerId <= 334 then -- Rivals
			return true
		elseif 426 <= trainerId and trainerId <= 440 then -- Rivals
			return true
		elseif 739 <= trainerId and trainerId <= 741 then -- Rivals
			return true
		end
	end
	return false
end

---Returns true if the trainer is a possible rival (Note: you fight only 1 of 3 rivals throughout a game)
---@param trainerId number
---@return boolean
function TrainerData.isRival(trainerId)
	local trainerInternal = TrainerData.getTrainerInfo(trainerId) or {}
	return trainerInternal.whichRival ~= nil
end

-- Determines if this trainer should be used; if it's a rival then it has to be the correct rival for the player
function TrainerData.shouldUseTrainer(trainerId)
	local trainerInternal = TrainerData.getTrainerInfo(trainerId) or {}
	if trainerInternal == TrainerData.BlankTrainer then
		return false
	end
	local whichRival = Tracker.getWhichRival()
	-- Always okay to use trainer if it's not a rival
	if whichRival == nil or trainerInternal.whichRival == nil then
		return true
	end
	-- Otherwise, make sure it's the correct rival
	return whichRival == trainerInternal.whichRival
end

-- Returns a list of trainers to exclude from a parsed log, often dummy trainers or VS Seeker rematch
function TrainerData.getExcludedTrainers()
	-- Holds individual trainerIds or a table-pair of ids, which is a range of ids
	local trainerIdRanges = {}
	if GameSettings.game == 1 or GameSettings.game == 2 then -- Ruby/Sapphire/Emerald
		trainerIdRanges = {
			{40, 43}, {47, 50}, {54, 56}, {60, 63}, {67, 70}, {84, 87}, {101, 104}, {110, 113}, 117,
			{120, 123}, {132, 135}, {139, 142}, {147, 150}, 173, {175, 178}, {184, 187}, {197, 200},
			{207, 210}, {219, 222}, {228, 231}, {239, 242}, {250, 253}, {257, 260}, {276, 279}, {282, 285},
			{288, 291}, {295, 298}, {303, 306}, {308, 311}, {314, 317}, {328, 331}, 341, {346, 349},
			{354, 357}, {360, 363}, {365, 368}, {370, 373}, {379, 382}, {388, 391}, {393, 396}, {409, 412},
			{421, 424}, {430, 433}, {437, 440}, 456, 462, {466, 468}, {477, 480}, 482, {485, 489},
			{497, 500}, {515, 518}, {541, 544}, {548, 551}, {555, 558}, {562, 565}, {607, 610}, {622, 625},
			{633, 634}, {636, 639}, {643, 646}, {657, 660}, {682, 685}, {688, 691}, {770, 801}, {805, 847},
			{851, 855},
		}
	elseif GameSettings.game == 3 then -- FireRed/LeafGreen
		trainerIdRanges = {
			{1, 88}, 101, 147, 200, 263, {454, 461}, {492, 515}, 530, {621, 741},
		}
	end

	local trainerIds = {}
	for _, item in pairs(trainerIdRanges) do
		if type(item) == "number" then
			trainerIds[item] = true
		elseif type(item) == "table" and #item == 2 then
			-- Add each number sequentially from the first value to the second value
			for i = item[1], item[2], 1 do
				trainerIds[i] = true
			end
		end
	end
	return trainerIds
end

---Returns true if the provided trainerId (or current opposing trainer) is Giovanni; useful for showing masterballs
---@param trainerId? number
---@return boolean
function TrainerData.isGiovanni(trainerId)
	trainerId = trainerId or TrackerAPI.getOpponentTrainerId()
	return GameSettings.game == 3 and trainerId >= 348 and trainerId <= 350
end

-- Helper functions for the image retrieval functions
local getClassFilename = function(trainerClass)
	trainerClass = trainerClass or TrainerData.Classes.Unknown
	local prefixes = { [1] = "rse-", [2] = "rse-", [3] = "frlg-", }
	local postfixes = { [1] = "-rs", [2] = "-e", }
	local gamePrefix = prefixes[GameSettings.game] or ""
	local gamePostfix = Utils.inlineIf(trainerClass.hasPostfix, postfixes[GameSettings.game] or "", "")
	local classFilename = trainerClass.filename or TrainerData.Classes.Unknown.filename
	return string.format("%s%s%s", gamePrefix, classFilename, gamePostfix)
end

function TrainerData.getFullImage(trainerClass)
	return FileManager.buildImagePath(FileManager.Folders.Trainers, getClassFilename(trainerClass), FileManager.Extensions.TRAINER)
end

function TrainerData.getPortraitIcon(trainerClass)
	return FileManager.buildImagePath(FileManager.Folders.TrainersPortraits, getClassFilename(trainerClass), FileManager.Extensions.TRAINER)
end

-- Helper function to convert Class->{TrainerId(List)} to TrainerId->{Class,Group}
local function mapClassesToTrainers(classMap, trainerList)
	for class, trainers in pairs(classMap) do
		for _, item in pairs(trainers) do
			-- Could be a list of raw ids, or a range ids as pair (fromID, toID)
			if type(item) == "number" then
				trainerList[item] = {
					class = class,
					group = class.group
				}
			elseif type(item) == "table" and #item == 2 then
				-- Add each number sequentially from the first value to the second value
				for i = item[1], item[2], 1 do
					trainerList[i] = {
						class = class,
						group = class.group
					}
				end
			end
		end
	end
end

-- For each trainer, add info on what route they can be found on
local function mapRoutesToTrainers()
	for routeId, route in pairs(RouteData.Info or {}) do
		if route.trainers and #route.trainers > 0 then
			for _, trainerId in ipairs(route.trainers or {}) do
				local trainer = TrainerData.Trainers[trainerId]
				if trainer then
					trainer.routeId = routeId
				end
			end
		end
	end
end

function TrainerData.setupTrainersAsRubySapphire()
	TrainerData.GymTMs = {
		{ leader = "Roxanne", number = 39, },
		{ leader = "Brawly", number = 8, },
		{ leader = "Wattson", number = 34, },
		{ leader = "Flannery", number = 50, },
		{ leader = "Norman", number = 42, },
		{ leader = "Winona", number = 40, },
		{ leader = "Tate & Liza", number = 4, },
		{ leader = "Wallace", number = 3, },
	}
	TrainerData.CommonTrainers = {
		["Rival 1"] = { 520, 523, 526, 529, 532, 535 },
		["Rival 2"] = { 521, 524, 527, 530, 533, 536 },
		["Rival 3"] = { 522, 525, 528, 531, 534, 537 },
		["Rival 4"] = { 661, 662, 663, 664, 665, 666 },
		["Roxanne"] = { 265 },
		["Brawly"] = { 266 },
		["Wattson"] = { 267 },
		["Flannery"] = { 268 },
		["Norman"] = { 269 },
		["Winona"] = { 270 },
		["Tate Liza"] = { 271 },
		["Tate & Liza"] = { 271 },
		["Wallace"] = { 272 }, -- 8th gym leader
		["Sidney"] = { 261 },
		["Phoebe"] = { 262 },
		["Glacia"] = { 263 },
		["Drake"] = { 264 },
		["Steven"] = { 335 }, -- Elite 4 champion
		["Wally 1"] = { 656 },
		["Wally 2"] = { 519 },
	}

	-- Ordered by average level of party Pokémon, lowest to highest
	TrainerData.OrderedIds = {
		616, 603, 615, 333, 318, 520, 523, 526, 529, 532, 535, 337, 319, 114, 136, 604, 320, 483, 617, 621, 631, 322, 280, 575, 273,
		351, 605, 336, 339, 321, 493, 581, 65, 340, 425, 491, 538, 545, 359, 57, 195, 464, 647, 64, 179, 334, 426, 490, 512, 586, 612,
		265, 332, 196, 227, 275, 302, 585, 606, 36, 37, 232, 243, 281, 292, 293, 352, 481, 611, 627, 635, 656, 338, 287, 194, 274,
		299, 344, 353, 358, 266, 419, 78, 94, 115, 191, 213, 312, 364, 369, 471, 476, 626, 629, 521, 524, 527, 530, 533, 536, 326, 51,
		189, 206, 214, 218, 323, 420, 427, 472, 628, 649, 143, 183, 327, 342, 434, 474, 513, 579, 597, 677, 267, 216, 632, 124, 125,
		126, 201, 212, 313, 630, 203, 205, 469, 473, 44, 202, 204, 211, 215, 447, 470, 648, 650, 345, 602, 350, 39, 152, 224, 225, 400,
		416, 445, 448, 693, 46, 153, 156, 158, 182, 188, 343, 408, 441, 446, 496, 584, 618, 619, 620, 651, 268, 692, 52, 58, 59, 66,
		71, 72, 73, 74, 89, 90, 91, 151, 154, 155, 157, 223, 387, 398, 399, 415, 428, 429, 442, 443, 444, 484, 559, 582, 583, 642, 680,
		45, 226, 307, 404, 552, 591, 599, 653, 383, 269, 75, 384, 402, 405, 435, 553, 560, 652, 654, 53, 107, 127, 190, 401, 403, 406,
		436, 522, 525, 528, 531, 534, 537, 568, 588, 655, 294, 669, 286, 270, 92, 95, 106, 109, 236, 238, 249, 254, 300, 378, 589, 592,
		673, 108, 145, 247, 413, 453, 567, 569, 596, 640, 667, 675, 661, 662, 663, 664, 665, 666, 159, 164, 181, 374, 450, 455, 458,
		463, 492, 570, 593, 668, 676, 88, 161, 165, 167, 170, 172, 174, 180, 414, 452, 460, 461, 671, 672, 674, 678, 686, 687, 160,
		162, 163, 166, 169, 235, 397, 449, 451, 454, 457, 670, 234, 244, 246, 376, 377, 385, 386, 407, 573, 171, 233, 245, 571, 168,
		301, 392, 459, 465, 561, 572, 600, 131, 554, 128, 248, 614, 681, 272, 118, 129, 130, 237, 613, 601, 81, 82, 83, 98, 105, 271,
		80, 99, 100, 495, 519, 76, 79, 96, 97, 255, 494, 93, 119, 138, 256, 641, 77, 261, 262, 263, 264, 335
	}

	local classToTrainers = {
		[TrainerData.Classes.Archie] = { 1, 34, 35 },
		[TrainerData.Classes.TeamAquaGrunt] = { {2, 29}, },
		[TrainerData.Classes.Matt] = { 30, 31 },
		[TrainerData.Classes.Shelly] = { 32, 33 },
		[TrainerData.Classes.AromaLady] = { {36, 43}, },
		[TrainerData.Classes.RuinManiac] = { {44, 50}, },
		[TrainerData.Classes.Interviewer] = { {51, 56}, },
		[TrainerData.Classes.Tuber] = { {57, 70}, },
		[TrainerData.Classes.CoolTrainer] = { 648, 670, 671, {71, 104}, },
		[TrainerData.Classes.HexManiac] = { {105, 113}, },
		[TrainerData.Classes.Lady] = { {114, 123}, },
		[TrainerData.Classes.Beauty] = { 647, {124, 135}, },
		[TrainerData.Classes.RichBoy] = { {136, 142}, },
		[TrainerData.Classes.PokeManiac] = { {143, 150}, },
		[TrainerData.Classes.SwimmerM] = { 675, {151, 178}, },
		[TrainerData.Classes.BlackBelt] = { 672, {179, 190}, },
		[TrainerData.Classes.Guitarist] = { {191, 200}, },
		[TrainerData.Classes.Kindler] = { {201, 210}, },
		[TrainerData.Classes.Camper] = { 654, {211, 222}, },
		[TrainerData.Classes.BugManiac] = { {223, 231}, },
		[TrainerData.Classes.Psychic] = { {232, 253}, },
		[TrainerData.Classes.Gentleman] = { {254, 260}, },
		[TrainerData.Classes.EliteFour1] = { 261 },
		[TrainerData.Classes.EliteFour2] = { 262 },
		[TrainerData.Classes.EliteFour3] = { 263 },
		[TrainerData.Classes.EliteFour4] = { 264 },
		[TrainerData.Classes.EliteChampion] = { 335 },
		[TrainerData.Classes.GymLeader1] = { 265 },
		[TrainerData.Classes.GymLeader2] = { 266 },
		[TrainerData.Classes.GymLeader3] = { 267 },
		[TrainerData.Classes.GymLeader4] = { 268 },
		[TrainerData.Classes.GymLeader5] = { 269 },
		[TrainerData.Classes.GymLeader6] = { 270 },
		[TrainerData.Classes.GymLeader7] = { 271 },
		[TrainerData.Classes.GymLeader8] = { 272 },
		[TrainerData.Classes.SchoolKid] = { {273, 285}, },
		[TrainerData.Classes.SrAndJr] = { 678, {286, 291}, },
		[TrainerData.Classes.PokeFan] = { {292, 306}, },
		[TrainerData.Classes.Expert] = { {307, 317}, },
		-- Some "Youngsters" (501-511) are actually "Boarders", but no sprite exists for them
		[TrainerData.Classes.Youngster] = { {318, 334}, {501, 511}, },
		[TrainerData.Classes.Fisherman] = { 673, 693, {336, 350}, {667, 669}, },
		[TrainerData.Classes.Triathlete] = { {351, 391}, },
		[TrainerData.Classes.DragonTamer] = { {392, 397}, },
		[TrainerData.Classes.BirdKeeper] = { 674, {398, 414}, },
		[TrainerData.Classes.NinjaBoy] = { 651, 652, 653, {415, 424}, },
		[TrainerData.Classes.BattleGirl] = { 649, 650, {425, 433}, },
		[TrainerData.Classes.ParasolLady] = { {434, 440}, },
		[TrainerData.Classes.SwimmerF] = { 676, {441, 468}, },
		[TrainerData.Classes.Picnicker] = { 655, {469, 480}, },
		[TrainerData.Classes.Twins] = { 677, {481, 489}, },
		[TrainerData.Classes.Sailor] = { {490, 500}, },
		[TrainerData.Classes.Collector] = { {512, 518}, },
		[TrainerData.Classes.Wally] = { 519, {656, 660} },
		[TrainerData.Classes.RivalBrendan] = { {520, 528}, {661, 663}, },
		[TrainerData.Classes.RivalMay] = { {529, 537}, {664, 666}, },
		[TrainerData.Classes.PkmnBreeder] = { {538, 551}, },
		[TrainerData.Classes.PkmnRanger] = { {552, 565}, },
		[TrainerData.Classes.Maxie] = { 566, 601, 602 },
		[TrainerData.Classes.TeamMagmaGrunt] = { 598, {567, 595}, },
		[TrainerData.Classes.Tabitha] = { 596, 597 },
		[TrainerData.Classes.Courtney] = { 599, 600 },
		[TrainerData.Classes.Lass] = { {603, 614}, },
		[TrainerData.Classes.BugCatcher] = { {615, 625}, },
		[TrainerData.Classes.Hiker] = { {626, 639}, },
		[TrainerData.Classes.YoungCouple] = { 680, {640, 646}, },
		[TrainerData.Classes.OldCouple] = { {681, 685}, },
		[TrainerData.Classes.SisAndBro] = { {686, 692}, },
	}

	TrainerData.Trainers = {}
	mapClassesToTrainers(classToTrainers, TrainerData.Trainers)
	mapRoutesToTrainers()

	-- Mark Rivals so they can be distinguished
	TrainerData.Trainers[520].whichRival = "Brendan Left"
	TrainerData.Trainers[521].whichRival = "Brendan Left"
	TrainerData.Trainers[522].whichRival = "Brendan Left"
	TrainerData.Trainers[661].whichRival = "Brendan Left"
	TrainerData.Trainers[523].whichRival = "Brendan Middle"
	TrainerData.Trainers[524].whichRival = "Brendan Middle"
	TrainerData.Trainers[525].whichRival = "Brendan Middle"
	TrainerData.Trainers[662].whichRival = "Brendan Middle"
	TrainerData.Trainers[526].whichRival = "Brendan Right"
	TrainerData.Trainers[527].whichRival = "Brendan Right"
	TrainerData.Trainers[528].whichRival = "Brendan Right"
	TrainerData.Trainers[663].whichRival = "Brendan Right"

	TrainerData.Trainers[529].whichRival = "May Left"
	TrainerData.Trainers[530].whichRival = "May Left"
	TrainerData.Trainers[531].whichRival = "May Left"
	TrainerData.Trainers[664].whichRival = "May Left"
	TrainerData.Trainers[532].whichRival = "May Middle"
	TrainerData.Trainers[533].whichRival = "May Middle"
	TrainerData.Trainers[534].whichRival = "May Middle"
	TrainerData.Trainers[665].whichRival = "May Middle"
	TrainerData.Trainers[535].whichRival = "May Right"
	TrainerData.Trainers[536].whichRival = "May Right"
	TrainerData.Trainers[537].whichRival = "May Right"
	TrainerData.Trainers[666].whichRival = "May Right"

	TrainerData.FinalTrainer = { [335] = true }
end

function TrainerData.setupTrainersAsEmerald()
	TrainerData.GymTMs = {
		{ leader = "Roxanne", number = 39, },
		{ leader = "Brawly", number = 8, },
		{ leader = "Wattson", number = 34, },
		{ leader = "Flannery", number = 50, },
		{ leader = "Norman", number = 42, },
		{ leader = "Winona", number = 40, },
		{ leader = "Tate & Liza", number = 4, },
		{ leader = "Juan", number = 3, },
	}
	TrainerData.CommonTrainers = {
		["Rival 1"] = { 520, 523, 526, 529, 532, 535 },
		["Rival 2"] = { 521, 524, 527, 530, 533, 536 },
		["Rival 3"] = { 522, 525, 528, 531, 534, 537 },
		["Rival 4"] = { 593, 592, 599, 600, 665, 666 },
		["Rival 5"] = { 661, 662, 663, 664, 768, 769 },
		["Roxanne"] = { 265 },
		["Brawly"] = { 266 },
		["Wattson"] = { 267 },
		["Flannery"] = { 268 },
		["Norman"] = { 269 },
		["Winona"] = { 270 },
		["Tate Liza"] = { 271 },
		["Tate & Liza"] = { 271 },
		["Juan"] = { 272 }, -- 8th gym leader
		["Sidney"] = { 261 },
		["Phoebe"] = { 262 },
		["Glacia"] = { 263 },
		["Drake"] = { 264 },
		["Wallace"] = { 335 }, -- Elite 4 champion
		["Steven"] = { 804 }, -- Final trainer
		["Wally 1"] = { 656 },
		["Wally 2"] = { 519 },
	}

	-- Ordered by average level of party Pokémon, lowest to highest
	TrainerData.OrderedIds = {
		616, 333, 603, 615, 318, 520, 523, 526, 529, 532, 535, 483, 604, 621, 337, 319, 114, 136, 321, 571, 617, 631, 694, 695, 753,
		754, 351, 10, 273, 280, 322, 339, 605, 696, 336, 320, 16, 340, 493, 538, 545, 359, 57, 65, 490, 698, 265, 64, 179, 425, 426,
		491, 572, 573, 574, 647, 697, 334, 592, 593, 599, 600, 768, 769, 21, 36, 37, 302, 352, 512, 612, 699, 700, 715, 20, 196, 232,
		275, 293, 481, 606, 701, 702, 703, 735, 736, 332, 287, 227, 243, 281, 292, 344, 353, 358, 611, 635, 656, 627, 266, 51, 78, 94,
		191, 194, 274, 299, 323, 364, 369, 419, 471, 476, 626, 649, 755, 756, 757, 802, 338, 708, 709, 206, 213, 214, 218, 312, 420,
		427, 472, 513, 628, 629, 705, 706, 707, 710, 711, 712, 746, 747, 752, 143, 183, 189, 326, 327, 342, 434, 474, 521, 524, 527,
		530, 533, 536, 677, 704, 713, 714, 679, 146, 216, 579, 632, 597, 1, 124, 125, 126, 212, 217, 313, 566, 267, 202, 469, 470, 570,
		630, 743, 744, 745, 44, 201, 203, 204, 205, 211, 473, 501, 648, 650, 153, 154, 215, 224, 448, 740, 741, 602, 693, 268, 669,
		350, 46, 144, 158, 343, 345, 375, 399, 408, 416, 441, 444, 446, 496, 619, 620, 642, 651, 737, 738, 742, 760, 765, 766, 182, 9,
		19, 39, 58, 59, 66, 71, 72, 73, 74, 89, 90, 91, 151, 152, 155, 156, 157, 188, 223, 236, 247, 398, 400, 415, 418, 442, 443, 445,
		447, 484, 547, 559, 739, 748, 749, 750, 751, 759, 761, 692, 17, 18, 45, 52, 225, 226, 307, 401, 428, 429, 503, 539, 552, 596,
		655, 680, 26, 32, 75, 116, 405, 435, 553, 560, 618, 652, 653, 719, 720, 763, 269, 11, 92, 107, 127, 254, 404, 406, 654, 716,
		717, 718, 721, 722, 723, 724, 725, 726, 727, 728, 729, 730, 731, 732, 764, 767, 12, 13, 29, 53, 95, 106, 195, 249, 300, 378,
		384, 402, 436, 522, 525, 528, 531, 534, 537, 569, 762, 803, 294, 387, 270, 286, 667, 3, 31, 35, 145, 164, 192, 238, 504, 505,
		586, 640, 2, 4, 5, 22, 23, 24, 27, 28, 108, 109, 180, 190, 193, 475, 577, 587, 588, 589, 590, 674, 661, 662, 663, 664, 665, 666,
		668, 673, 88, 137, 159, 167, 168, 174, 374, 377, 403, 413, 453, 455, 459, 461, 463, 492, 506, 507, 509, 511, 594, 598, 675, 733,
		758, 678, 687, 15, 30, 160, 161, 162, 163, 165, 166, 169, 170, 171, 172, 181, 383, 385, 397, 414, 449, 450, 451, 452, 454, 457,
		458, 460, 508, 510, 576, 580, 595, 670, 671, 672, 676, 686, 376, 386, 464, 567, 578, 6, 7, 8, 233, 234, 235, 244, 245, 246, 407,
		575, 582, 583, 584, 585, 591, 33, 130, 301, 392, 601, 465, 514, 561, 115, 131, 502, 554, 614, 681, 118, 128, 129, 613, 105, 237,
		248, 848, 849, 850, 34, 271, 272, 81, 82, 83, 98, 100, 38, 79, 80, 99, 324, 325, 417, 495, 540, 546, 734, 519, 76, 255, 494, 93,
		96, 97, 119, 138, 256, 641, 77, 261, 262, 263, 264, 335, 804
	}

	local classToTrainers = {
		[TrainerData.Classes.Archie] = { 34 },
		[TrainerData.Classes.AromaLady] = { 36, 37, {39, 43}, 705, 747 },
		[TrainerData.Classes.BattleGirl] = { {425, 433}, 509, 573, 649, 650, 751, 757, 763 },
		[TrainerData.Classes.Beauty] = { {124, 135}, 144, 647, {844, 847} },
		[TrainerData.Classes.BirdKeeper] = { 12, {398, 414}, 674, 709, 738, 742, 803 },
		[TrainerData.Classes.BlackBelt] = { 31, {179, 190}, 574, 672, 703, {824, 827} },
		[TrainerData.Classes.BugCatcher] = { 539, {615, 625} },
		[TrainerData.Classes.BugManiac] = { {223, 231}, 764, 802 },
		[TrainerData.Classes.Camper] = { {211, 216}, {218, 222}, 654, 704, 710, 745 },
		[TrainerData.Classes.Collector] = { 13, 512, 513, {515, 518} },
		[TrainerData.Classes.CoolTrainer] = { 11, 38, {71, 104}, 324, 325, 417, 503, 508, 540, 546, 577, 598, 648, 670, 671, 733, 741, 762, 767, {828, 831} },
		[TrainerData.Classes.DragonTamer] = { {392, 397} },
		[TrainerData.Classes.EliteChampion] = { 335 },
		[TrainerData.Classes.EliteFour1] = { 261 },
		[TrainerData.Classes.EliteFour2] = { 262 },
		[TrainerData.Classes.EliteFour3] = { 263 },
		[TrainerData.Classes.EliteFour4] = { 264 },
		[TrainerData.Classes.Expert] = { 29, 137, {307, 317}, 506, 511, 594, 758 },
		[TrainerData.Classes.Fisherman] = { {336, 350}, {667, 669}, 673, 693, 696, 713 },
		[TrainerData.Classes.Gentleman] = { {254, 260}, 582, 584, 850 },
		[TrainerData.Classes.Guitarist] = { 191, {194, 200}, 700, 702, 759, {832, 835} },
		[TrainerData.Classes.GymLeader1] = { 265, {770, 773} },
		[TrainerData.Classes.GymLeader2] = { 266, {774, 777} },
		[TrainerData.Classes.GymLeader3] = { 267, {778, 781} },
		[TrainerData.Classes.GymLeader4] = { 268, {782, 785} },
		[TrainerData.Classes.GymLeader5] = { 269, {786, 789} },
		[TrainerData.Classes.GymLeader6] = { 270, {790, 793} },
		[TrainerData.Classes.GymLeader7] = { 271, {794, 797} },
		[TrainerData.Classes.GymLeader8] = { 272, {798, 801} },
		[TrainerData.Classes.HexManiac] = { 35, {105, 113}, 575, 583 },
		[TrainerData.Classes.Hiker] = { 1, 501, 571, {626, 639}, 753, {836, 839} },
		[TrainerData.Classes.Interviewer] = { {51, 56} },
		[TrainerData.Classes.Kindler] = { {201, 210}, 707, 746, 760 },
		[TrainerData.Classes.Lady] = { 114, 115, {117, 123}, 695 },
		[TrainerData.Classes.Lass] = { {603, 614} },
		[TrainerData.Classes.Matt] = { 30 },
		[TrainerData.Classes.Maxie] = { 601, 602, 734 },
		[TrainerData.Classes.NinjaBoy] = { 415, 416, {419, 424}, 504, {651, 653}, 749 },
		[TrainerData.Classes.OldCouple] = { {681, 685} },
		[TrainerData.Classes.ParasolLady] = { {434, 440}, 505, 761 },
		[TrainerData.Classes.Picnicker] = { 217, {469, 474}, {476, 480}, 655, 706, 708, 712, 714, 743 },
		[TrainerData.Classes.PkmnBreeder] = { 9, 538, {541, 545}, {548, 551}, 765, 766, {840, 843} },
		[TrainerData.Classes.PkmnRanger] = { {552, 565} },
		[TrainerData.Classes.PokeFan] = { {292, 306}, 502, 699 },
		[TrainerData.Classes.PokeManiac] = { 143, 145, {147, 150}, 711 },
		[TrainerData.Classes.Psychic] = { {232, 253}, 475, 581, 585, 591, 750, 752, 756, 848, 849 },
		[TrainerData.Classes.RichBoy] = { 136, {138, 142}, 694 },
		[TrainerData.Classes.RivalBrendan] = { {520, 528}, 592, 593, 599, {661, 663} },
		[TrainerData.Classes.RivalMay] = { {529, 537}, 600, {664, 666}, 768, 769 },
		[TrainerData.Classes.RuinManiac] = { {44, 50}, 547, 737, 744, {812, 815} },
		[TrainerData.Classes.Sailor] = { {490, 500}, 507, 510, 572, 740, {816, 819} },
		[TrainerData.Classes.SchoolKid] = { {273, 285} },
		[TrainerData.Classes.Shelly] = { 32, 33 },
		[TrainerData.Classes.SisAndBro] = { {686, 692} },
		[TrainerData.Classes.SrAndJr] = { {286, 291}, 678, 679 },
		[TrainerData.Classes.Steven] = { 804, 855 },
		[TrainerData.Classes.SwimmerF] = { {441, 468}, 676, 736 },
		[TrainerData.Classes.SwimmerM] = { 15, {151, 178}, 576, 578, 580, 675, 735 },
		[TrainerData.Classes.Tabitha] = { 514, 597, 732 },
		[TrainerData.Classes.TeamAquaGrunt] = { {2, 8}, 10, 14, {16, 21}, {23, 28}, 192, 193, 567, 569, 596 },
		[TrainerData.Classes.TeamMagmaGrunt] = { 22, 116, 146, 568, 570, 579, {586, 590}, {716, 731} },
		[TrainerData.Classes.Triathlete] = { {351, 374}, {376, 391}, 566, 595, 701, 739, 748, 755, {820, 823} },
		[TrainerData.Classes.Tuber] = { {57, 70}, 418, 697, 698 },
		[TrainerData.Classes.Twins] = { {481, 489}, 677 },
		[TrainerData.Classes.Unknown] = { {805, 811}, {851, 854} },
		[TrainerData.Classes.Wally] = { 519, {656, 660} },
		[TrainerData.Classes.YoungCouple] = { {640, 646}, 680 },
		[TrainerData.Classes.Youngster] = { {318, 323}, {326, 334}, 375, 715, 754 },
	}

	TrainerData.Trainers = {}
	mapClassesToTrainers(classToTrainers, TrainerData.Trainers)
	mapRoutesToTrainers()

	-- Mark Rivals so they can be distinguished
	TrainerData.Trainers[520].whichRival = "Brendan Left"
	TrainerData.Trainers[521].whichRival = "Brendan Left"
	TrainerData.Trainers[522].whichRival = "Brendan Left"
	TrainerData.Trainers[593].whichRival = "Brendan Left"
	TrainerData.Trainers[661].whichRival = "Brendan Left"
	TrainerData.Trainers[523].whichRival = "Brendan Middle"
	TrainerData.Trainers[524].whichRival = "Brendan Middle"
	TrainerData.Trainers[525].whichRival = "Brendan Middle"
	TrainerData.Trainers[592].whichRival = "Brendan Middle"
	TrainerData.Trainers[662].whichRival = "Brendan Middle"
	TrainerData.Trainers[526].whichRival = "Brendan Right"
	TrainerData.Trainers[527].whichRival = "Brendan Right"
	TrainerData.Trainers[528].whichRival = "Brendan Right"
	TrainerData.Trainers[599].whichRival = "Brendan Right"
	TrainerData.Trainers[663].whichRival = "Brendan Right"

	TrainerData.Trainers[529].whichRival = "May Left"
	TrainerData.Trainers[530].whichRival = "May Left"
	TrainerData.Trainers[531].whichRival = "May Left"
	TrainerData.Trainers[600].whichRival = "May Left"
	TrainerData.Trainers[664].whichRival = "May Left"
	TrainerData.Trainers[532].whichRival = "May Middle"
	TrainerData.Trainers[533].whichRival = "May Middle"
	TrainerData.Trainers[534].whichRival = "May Middle"
	TrainerData.Trainers[665].whichRival = "May Middle"
	TrainerData.Trainers[768].whichRival = "May Middle"
	TrainerData.Trainers[535].whichRival = "May Right"
	TrainerData.Trainers[536].whichRival = "May Right"
	TrainerData.Trainers[537].whichRival = "May Right"
	TrainerData.Trainers[666].whichRival = "May Right"
	TrainerData.Trainers[769].whichRival = "May Right"

	TrainerData.FinalTrainer = { [804] = true }
end

function TrainerData.setupTrainersAsFRLG()
	TrainerData.GymTMs = {
		{ leader = "Brock", number = 39, },
		{ leader = "Misty", number = 3, },
		{ leader = "Lt. Surge", number = 34, },
		{ leader = "Erika", number = 19, },
		{ leader = "Koga", number = 6, },
		{ leader = "Sabrina", number = 4, },
		{ leader = "Blaine", number = 38, },
		{ leader = "Giovanni", number = 26, },
	}
	TrainerData.CommonTrainers = {
		["Rival 1"] = { 326, 327, 328 },
		["Rival 2"] = { 329, 330, 331 },
		["Rival 3"] = { 332, 333, 334 },
		["Rival 4"] = { 426, 427, 428 },
		["Rival 5"] = { 429, 430, 431 },
		["Rival 6"] = { 432, 433, 434 },
		["Rival 7"] = { 435, 436, 437 },
		["Brock"] = { 414 },
		["Misty"] = { 415 },
		["Lt. Surge"] = { 416 },
		["Erika"] = { 417 },
		["Koga"] = { 418 },
		["Sabrina"] = { 420 },
		["Blaine"] = { 419 },
		["Giovanni Hideout"] = { 348 },
		["Giovanni Silph Co."] = { 349 },
		["Giovanni Gym"] = { 350 },
		["Dojo"] = { 317 },
		["Lorelei"] = { 410 },
		["Bruno"] = { 411 },
		["Agatha"] = { 412 },
		["Lance"] = { 413 },
		["Champion"] = { 438, 439, 440 },
		["Jimmy"] = { 102 }, -- Bonus trainer, commonly referred to as "Jimmy"
	}

	-- Ordered by average level of party Pokémon, lowest to highest (includes sevii)
	TrainerData.OrderedIds = {
		326, 327, 328, 102, 103, 532, 531, 104, 106, 116, 329, 330, 331, 91, 105, 109, 110, 117, 181, 142, 89, 107, 108, 120, 169, 352,
		353, 123, 170, 414, 125, 183, 351, 354, 90, 92, 95, 118, 121, 143, 471, 93, 153, 182, 356, 111, 122, 146, 151, 152, 234, 332,
		333, 334, 94, 99, 135, 137, 139, 184, 223, 224, 355, 363, 483, 100, 126, 127, 134, 138, 144, 154, 222, 258, 259, 260, 261, 421,
		426, 427, 428, 415, 98, 114, 130, 149, 150, 188, 192, 361, 422, 475, 416, 112, 115, 140, 145, 156, 163, 164, 171, 186, 191, 193,
		357, 360, 364, 465, 474, 96, 97, 136, 141, 148, 157, 158, 185, 187, 189, 194, 220, 221, 228, 265, 358, 359, 365, 368, 131, 159,
		165, 172, 225, 262, 362, 402, 441, 446, 448, 450, 451, 476, 484, 535, 429, 430, 431, 128, 132, 133, 155, 168, 366, 367, 371, 423,
		443, 445, 447, 482, 129, 160, 226, 233, 264, 266, 267, 442, 444, 449, 452, 453, 467, 486, 536, 348, 166, 190, 197, 206, 301, 341,
		369, 374, 390, 417, 173, 207, 255, 302, 305, 309, 314, 336, 340, 370, 382, 385, 227, 231, 238, 241, 268, 276, 469, 195, 198, 202,
		208, 229, 244, 249, 306, 313, 316, 337, 344, 375, 377, 381, 386, 387, 388, 466, 470, 479, 162, 196, 199, 204, 205, 209, 236, 239,
		250, 251, 252, 253, 256, 269, 273, 274, 278, 285, 286, 300, 304, 307, 315, 335, 338, 342, 343, 345, 373, 376, 380, 383, 384, 477,
		478, 480, 487, 488, 489, 235, 237, 240, 271, 277, 279, 310, 468, 473, 490, 119, 230, 242, 272, 280, 288, 318, 321, 472, 248, 319,
		391, 201, 203, 232, 245, 247, 254, 282, 295, 303, 339, 346, 378, 379, 389, 464, 481, 491, 534, 178, 216, 219, 281, 289, 293, 294,
		308, 347, 462, 559, 519, 551, 243, 270, 538, 556, 177, 213, 320, 546, 555, 558, 548, 550, 349, 432, 433, 434, 180, 215, 246, 317,
		518, 523, 527, 537, 547, 554, 560, 218, 283, 292, 324, 400, 463, 528, 529, 539, 549, 552, 553, 561, 592, 597, 392, 401, 420, 418,
		595, 297, 557, 742, 167, 322, 179, 214, 287, 419, 393, 396, 403, 404, 406, 394, 296, 323, 325, 298, 350, 485, 545, 612, 291, 616,
		435, 436, 437, 590, 290, 520, 524, 540, 541, 565, 566, 567, 569, 591, 610, 613, 614, 615, 620, 599, 600, 564, 607, 570, 571, 572,
		517, 593, 608, 619, 587, 525, 516, 542, 568, 573, 574, 577, 579, 581, 583, 585, 596, 606, 611, 617, 618, 526, 562, 563, 575, 576,
		578, 580, 582, 584, 588, 589, 609, 521, 522, 586, 598, 601, 410, 543, 411, 544, 412, 413, 438, 439, 440
	}

	local classToTrainers = {
		[TrainerData.Classes.AromaLady] = { 523, 558, 577, 588 },
		[TrainerData.Classes.Beauty] = { {265, 269}, {273, 275}, 655, 666 },
		[TrainerData.Classes.Biker] = { {195, 209}, 470, {527, 530}, 535, 536, 652, 661, 675, 677 },
		[TrainerData.Classes.BirdKeeper] = { {300, 316}, {570, 572}, 656, 657, {662, 668}, 680, 681, {708, 710} },
		[TrainerData.Classes.BlackBelt] = { {317, 325}, 553, 554, {695, 698} },
		[TrainerData.Classes.BugCatcher] = { {102, 115}, {492, 497}, 531, 532, {611, 613}, {729, 731} },
		[TrainerData.Classes.Burglar] = { {210, 219} },
		[TrainerData.Classes.Camper] = { {142, 149}, 471, 477, 555, 618, {624, 629}, {637, 639} },
		[TrainerData.Classes.Channeler] = { {441, 464} },
		[TrainerData.Classes.CoolCouple] = { 485, 601, 728 },
		[TrainerData.Classes.CoolTrainer] = { {392, 409}, 599, 600, 726, 727 },
		[TrainerData.Classes.CrushGirl] = { 518, 552, 591, 592, {691, 694}, 722 },
		[TrainerData.Classes.CrushKin] = { 488, 557, {672, 674}, 699, 700 },
		[TrainerData.Classes.CueBall] = { {249, 257}, 676, 678, 679, 742 },
		[TrainerData.Classes.EliteChampion] = { 438, 439, 440, 739, 740, 741 },
		[TrainerData.Classes.EliteFour1] = { 410, 735 },
		[TrainerData.Classes.EliteFour2] = { 411, 736 },
		[TrainerData.Classes.EliteFour3] = { 412, 737 },
		[TrainerData.Classes.EliteFour4] = { 413, 738 },
		[TrainerData.Classes.Engineer] = { 220, 221, 222, 635 },
		[TrainerData.Classes.Fisherman] = { {223, 233}, 551, 573, 653, 686 },
		[TrainerData.Classes.Gamer] = { {258, 264}, 636, 651 },
		[TrainerData.Classes.Gentleman] = { {421, 425}, 482, 483, 605 },
		[TrainerData.Classes.GymLeader1] = { 414 },
		[TrainerData.Classes.GymLeader2] = { 415 },
		[TrainerData.Classes.GymLeader3] = { 416 },
		[TrainerData.Classes.GymLeader4] = { 417 },
		[TrainerData.Classes.GymLeader5] = { 418 },
		[TrainerData.Classes.GymLeader6] = { 420 }, -- 420 is Sabrina
		[TrainerData.Classes.GymLeader7] = { 419 }, -- 419 is Blaine and not 420 :(
		[TrainerData.Classes.GymLeader8] = { 348, 349, 350 }, -- All use the same class image, only 350 is the Gym #8 Leader
		[TrainerData.Classes.Hiker] = { {181, 194}, 465, 510, 581, 584, 643, 647, 714 },
		[TrainerData.Classes.Juggler] = { {286, 293}, 590, 719 },
		[TrainerData.Classes.Lady] = { 525, 564, 606 },
		[TrainerData.Classes.Lass] = { {116, 133}, 501, 502, 507, 508, 616, 617, 648, 649 },
		[TrainerData.Classes.Painter] = { 526, 562, 563, 604, 703 },
		[TrainerData.Classes.Picnicker] = { {150, 161}, {466, 469}, {472, 476}, {478, 481}, 556, 619, {621, 623}, {630, 632}, {640, 642}, {658, 660}, {669, 671}, 684, 685 },
		[TrainerData.Classes.PkmnBreeder] = { 520, 609, 610, 705 },
		[TrainerData.Classes.PkmnRanger] = { 521, 522, 595, 596, 597, 598, 720, 721, 724, 725 },
		[TrainerData.Classes.PokeManiac] = { {162, 168}, 585, 594, {644, 646}, 716 },
		[TrainerData.Classes.Psychic] = { {280, 283}, 517, 586, 587, 608, 712, 717, 718 },
		[TrainerData.Classes.RivalFRLGA] = { {326, 328}, {426, 428}, {435, 437} },
		[TrainerData.Classes.RivalFRLGB] = { {329, 331}, {429, 431} },
		[TrainerData.Classes.RivalFRLGC] = { {332, 334}, {432, 434} },
		[TrainerData.Classes.Rocker] = { 284, 285, 654 },
		[TrainerData.Classes.RuinManiac] = { 524, 582, 583, 602, 603, 607, 620, 715 },
		[TrainerData.Classes.Sailor] = { {134, 141} },
		[TrainerData.Classes.Scientist] = { {335, 347}, 545 },
		[TrainerData.Classes.SisAndBro] = { 490, 491, 576, 688, 689 },
		[TrainerData.Classes.SuperNerd] = { {169, 180}, 650 },
		[TrainerData.Classes.SwimmerF] = { {270, 272}, {276, 279}, {546, 548}, 561, 575, 579, 682, 711, 734 },
		[TrainerData.Classes.SwimmerM] = { {234, 248}, 549, 550, 566, 574, 578, 683, 687, 690, 713, 732, 733 },
		[TrainerData.Classes.Tamer] = { {294, 299}, 593, 723 },
		[TrainerData.Classes.TeamRocketGrunt] = { {351, 391}, 516, 537, 538, 539, 540, 541, 542, 543, 544, 567, 568, 569 },
		[TrainerData.Classes.Tuber] = { 519, 559, 701 },
		[TrainerData.Classes.Twins] = { 484, 487, 533, 560, 580, 702 },
		[TrainerData.Classes.Unknown] = { {511, 515} },
		[TrainerData.Classes.YoungCouple] = { 486, 489, 589, 706, 707 },
		[TrainerData.Classes.Youngster] = { {89, 101}, {498, 500}, {503, 506}, 509, 534, 565, 614, 615, 633, 634, 704 },
	}

	TrainerData.Trainers = {}
	mapClassesToTrainers(classToTrainers, TrainerData.Trainers)
	mapRoutesToTrainers()

	-- Custom trainer adjustments
	TrainerData.Trainers[317].group = TrainerData.TrainerGroups.Boss -- Dojo Leader
	TrainerData.Trainers[348].group = TrainerData.TrainerGroups.Boss -- Giovanni 1
	TrainerData.Trainers[349].group = TrainerData.TrainerGroups.Boss -- Giovanni 2
	TrainerData.Trainers[735].group = nil -- Exclude from Elite4 quick access group
	TrainerData.Trainers[736].group = nil -- Exclude from Elite4 quick access group
	TrainerData.Trainers[737].group = nil -- Exclude from Elite4 quick access group
	TrainerData.Trainers[738].group = nil -- Exclude from Elite4 quick access group
	TrainerData.Trainers[739].group = nil -- Exclude from Elite4 quick access group
	TrainerData.Trainers[740].group = nil -- Exclude from Elite4 quick access group
	TrainerData.Trainers[741].group = nil -- Exclude from Elite4 quick access group

	-- Mark Rivals so they can be distinguished
	TrainerData.Trainers[327].whichRival = "Left"
	TrainerData.Trainers[330].whichRival = "Left"
	TrainerData.Trainers[333].whichRival = "Left"
	TrainerData.Trainers[427].whichRival = "Left"
	TrainerData.Trainers[430].whichRival = "Left"
	TrainerData.Trainers[433].whichRival = "Left"
	TrainerData.Trainers[436].whichRival = "Left"
	TrainerData.Trainers[439].whichRival = "Left"
	TrainerData.Trainers[326].whichRival = "Middle"
	TrainerData.Trainers[329].whichRival = "Middle"
	TrainerData.Trainers[332].whichRival = "Middle"
	TrainerData.Trainers[426].whichRival = "Middle"
	TrainerData.Trainers[429].whichRival = "Middle"
	TrainerData.Trainers[432].whichRival = "Middle"
	TrainerData.Trainers[435].whichRival = "Middle"
	TrainerData.Trainers[438].whichRival = "Middle"
	TrainerData.Trainers[328].whichRival = "Right"
	TrainerData.Trainers[331].whichRival = "Right"
	TrainerData.Trainers[334].whichRival = "Right"
	TrainerData.Trainers[428].whichRival = "Right"
	TrainerData.Trainers[431].whichRival = "Right"
	TrainerData.Trainers[434].whichRival = "Right"
	TrainerData.Trainers[437].whichRival = "Right"
	TrainerData.Trainers[440].whichRival = "Right"

	-- All 3 rivals
	TrainerData.FinalTrainer = { [438] = true, [439] = true, [440] = true }
end
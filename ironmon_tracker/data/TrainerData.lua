-- Currently, this is only used for connecting to trainer data parsed from a randomizer log file
TrainerData = {}

-- These are populated later after the game being played is determined
TrainerData.Trainers = {}
TrainerData.GymTMs = {}
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
local mapClassesToTrainers = function(classMap, trainerList)
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
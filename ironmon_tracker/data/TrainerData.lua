-- Currently, this is only used for connecting to trainer data parsed from a randomizer log file
TrainerData = {}

-- These are populated later after the game being played is determined
TrainerData.Trainers = {}
TrainerData.GymTMs = {}

TrainerData.TrainerGroups = {
	All = "All",
	Rival = "Rival",
	Gym = "Gym",
	Elite4 = "Elite 4",
	Boss = "Boss",
	Other = "Other",
}

-- Mapped by [GameNumber][TrainerId] = data table with filename
TrainerData.FileInfo = {
	-- Aim to have width at 42+ and height 63
	maxWidth = 58,
	maxHeight = 63,

	["e-rival-brendan"] =		{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["e-rival-may"] =			{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["rs-rival-brendan"] =		{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["rs-rival-may"] =			{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["rse-wally"] =				{ width = 38, height = 57, offsetX = 10, offsetY = 4, },
	["rse-archie"] =			{ width = 38, height = 63, offsetX = 8, offsetY = 0, },
	["rse-maxie"] =				{ width = 38, height = 63, offsetX = 9, offsetY = 0, },
	["rse-tabitha"] =			{ width = 50, height = 62, offsetX = 0, offsetY = 0, },
	["rse-gymleader-1"] =		{ width = 35, height = 54, offsetX = 4, offsetY = 6, },
	["rse-gymleader-2"] =		{ width = 51, height = 61, offsetX = 0, offsetY = 2, },
	["rse-gymleader-3"] =		{ width = 35, height = 60, offsetX = 0, offsetY = 2, },
	["rse-gymleader-4"] =		{ width = 45, height = 61, offsetX = 3, offsetY = 2, },
	["rse-gymleader-5"] =		{ width = 35, height = 63, offsetX = 0, offsetY = 0, },
	["rse-gymleader-6"] =		{ width = 45, height = 60, offsetX = 0, offsetY = 2, },
	["rse-gymleader-7"] =		{ width = 57, height = 54, offsetX = 0, offsetY = 4, },
	["rse-elitefour-1"] =		{ width = 40, height = 54, offsetX = 0, offsetY = 6, },
	["rse-elitefour-2"] =		{ width = 38, height = 57, offsetX = 5, offsetY = 4, },
	["rse-elitefour-3"] =		{ width = 40, height = 61, offsetX = 0, offsetY = 2, },
	["rse-elitefour-4"] =		{ width = 47, height = 63, offsetX = 3, offsetY = 1, },
	["e-gymleader-8"] =			{ width = 40, height = 63, offsetX = 0, offsetY = 3, },
	["rs-gymleader-8"] =		{ width = 48, height = 55, offsetX = 0, offsetY = 6, },
	["e-elitefour-champ"] =		{ width = 56, height = 59, offsetX = 0, offsetY = 2, },
	["rs-elitefour-champ"] =	{ width = 34, height = 63, offsetX = 0, offsetY = 0, },
	["e-final-steven"] =		{ width = 34, height = 63, offsetX = 0, offsetY = 2, },

	["frlg-rival-a"] =			{ width = 42, height = 57, offsetX = 1, offsetY = 3, },
	["frlg-rival-b"] =			{ width = 42, height = 60, offsetX = 0, offsetY = 2, },
	["frlg-rival-c"] =			{ width = 42, height = 60, offsetX = 0, offsetY = 3, },
	["frlg-blackbelt"] =		{ width = 52, height = 61, offsetX = 0, offsetY = 1, },
	["frlg-gymleader-1"] =		{ width = 43, height = 63, offsetX = 3, offsetY = 2, },
	["frlg-gymleader-2"] =		{ width = 43, height = 61, offsetX = 2, offsetY = 2, },
	["frlg-gymleader-3"] =		{ width = 43, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-4"] =		{ width = 43, height = 57, offsetX = 2, offsetY = 3, },
	["frlg-gymleader-5"] =		{ width = 46, height = 54, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-6"] =		{ width = 43, height = 56, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-7"] =		{ width = 44, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-8"] =		{ width = 42, height = 63, offsetX = 2, offsetY = 1, },
	["frlg-elitefour-1"] =		{ width = 38, height = 62, offsetX = 0, offsetY = 2, },
	["frlg-elitefour-2"] =		{ width = 53, height = 52, offsetX = 0, offsetY = 5, },
	["frlg-elitefour-3"] =		{ width = 30, height = 57, offsetX = 1, offsetY = 3, },
	["frlg-elitefour-4"] =		{ width = 58, height = 60, offsetX = 0, offsetY = 3, },
	["unknown-a"] =				{ width = 42, height = 55, offsetX = 0, offsetY = 8, },
	["unknown-b"] =				{ width = 42, height = 55, offsetX = 0, offsetY = 8, },
}

function TrainerData.initialize()
	if GameSettings.game == 1 then
		TrainerData.setupTrainersAsRubySapphire()
	elseif GameSettings.game == 2 then
		TrainerData.setupTrainersAsEmerald()
	elseif GameSettings.game == 3 then
		TrainerData.setupTrainersAsFRLG()
	end
end

-- Returns a table with trainer info { name, filterGroup, filename, }
function TrainerData.getTrainerInfo(trainerId)
	if trainerId == nil or TrainerData.Trainers[trainerId] == nil then
		local randomIcon = Utils.inlineIf(math.random(2) == 1, "a", "b") -- For now, random between female and male trainer
		return {
			name = "Unknown",
			group = "Other",
			filename = "unknown-" .. randomIcon,
		}
	end
	return TrainerData.Trainers[trainerId]
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

	TrainerData.Trainers = {
		[261] = {
			name = "Sidney",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-1",
		},
		[262] = {
			name = "Phoebe",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-2",
		},
		[263] = {
			name = "Glacia",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-3",
		},
		[264] = {
			name = "Drake",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-4",
		},
		[265] = {
			name = "Roxanne",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-1",
		},
		[266] = {
			name = "Brawly",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-2",
		},
		[267] = {
			name = "Wattson",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-3",
		},
		[268] = {
			name = "Flannery",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-4",
		},
		[269] = {
			name = "Norman",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-5",
		},
		[270] = {
			name = "Winona",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-6",
		},
		[271] = {
			name = "Tate & Liza",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-7",
		},
		[272] = {
			name = "Wallace",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rs-gymleader-8",
		},
		[335] = {
			name = "Steven",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rs-elitefour-champ",
		},
		[520] = {
			name = "Brendan 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[523] = {
			name = "Brendan 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[526] = {
			name = "Brendan 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[521] = {
			name = "Brendan 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[524] = {
			name = "Brendan 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[527] = {
			name = "Brendan 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[522] = {
			name = "Brendan 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[525] = {
			name = "Brendan 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[528] = {
			name = "Brendan 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[661] = {
			name = "Brendan 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[662] = {
			name = "Brendan 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[663] = {
			name = "Brendan 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[529] = {
			name = "May 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[532] = {
			name = "May 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[535] = {
			name = "May 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[530] = {
			name = "May 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[533] = {
			name = "May 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[536] = {
			name = "May 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[531] = {
			name = "May 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[534] = {
			name = "May 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[537] = {
			name = "May 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[664] = {
			name = "May 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[665] = {
			name = "May 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[666] = {
			name = "May 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[1] = {
			name = "Archie 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-archie",
		},
		[35] = {
			name = "Archie 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-archie",
		},
		[34] = {
			name = "Archie 3",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-archie",
		},
		[566] = {
			name = "Maxie 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-maxie",
		},
		[602] = {
			name = "Maxie 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-maxie",
		},
		[601] = {
			name = "Maxie 3",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-maxie",
		},
		[656] = {
			name = "Wally 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[519] = {
			name = "Wally 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[657] = {
			name = "Wally 3",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[658] = {
			name = "Wally 4",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[659] = {
			name = "Wally 5",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[660] = {
			name = "Wally 6",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
	}
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

	TrainerData.Trainers = {
		[261] = {
			name = "Sidney",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-1",
		},
		[262] = {
			name = "Phoebe",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-2",
		},
		[263] = {
			name = "Glacia",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-3",
		},
		[264] = {
			name = "Drake",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "rse-elitefour-4",
		},
		[265] = {
			name = "Roxanne",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-1",
		},
		[266] = {
			name = "Brawly",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-2",
		},
		[267] = {
			name = "Wattson",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-3",
		},
		[268] = {
			name = "Flannery",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-4",
		},
		[269] = {
			name = "Norman",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-5",
		},
		[270] = {
			name = "Winona",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-6",
		},
		[271] = {
			name = "Tate & Liza",
			group = TrainerData.TrainerGroups.Gym,
			filename = "rse-gymleader-7",
		},
		[272] = {
			name = "Juan",
			group = TrainerData.TrainerGroups.Gym,
			filename = "e-gymleader-8",
		},
		[335] = {
			name = "Wallace",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "e-elitefour-champ",
		},
		[520] = {
			name = "Brendan 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[523] = {
			name = "Brendan 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[526] = {
			name = "Brendan 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[593] = {
			name = "Brendan 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[592] = {
			name = "Brendan 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[599] = {
			name = "Brendan 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[521] = {
			name = "Brendan 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[524] = {
			name = "Brendan 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[527] = {
			name = "Brendan 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[522] = {
			name = "Brendan 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[525] = {
			name = "Brendan 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[528] = {
			name = "Brendan 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[661] = {
			name = "Brendan 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[662] = {
			name = "Brendan 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[663] = {
			name = "Brendan 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[529] = {
			name = "May 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[532] = {
			name = "May 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[535] = {
			name = "May 1",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[600] = {
			name = "May 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[768] = {
			name = "May 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[769] = {
			name = "May 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[530] = {
			name = "May 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[533] = {
			name = "May 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[536] = {
			name = "May 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[531] = {
			name = "May 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[534] = {
			name = "May 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[537] = {
			name = "May 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[664] = {
			name = "May 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[665] = {
			name = "May 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[666] = {
			name = "May 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[34] = {
			name = "Archie",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-archie",
		},
		[514] = {
			name = "Tabitha (duo)",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-tabitha",
		},
		[602] = {
			name = "Maxie 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-maxie",
		},
		[601] = {
			name = "Maxie 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-maxie",
		},
		[734] = {
			name = "Maxie (duo)",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-maxie",
		},
		[656] = {
			name = "Wally 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[519] = {
			name = "Wally 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[657] = {
			name = "Wally 3",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[658] = {
			name = "Wally 4",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[659] = {
			name = "Wally 5",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[660] = {
			name = "Wally 6",
			group = TrainerData.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[804] = {
			name = "Steven",
			group = TrainerData.TrainerGroups.Boss,
			filename = "e-final-steven",
		},
	}
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

	TrainerData.Trainers = {
		[410] = {
			name = "Lorelei",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-1",
		},
		[411] = {
			name = "Bruno",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-2",
		},
		[412] = {
			name = "Agatha",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-3",
		},
		[413] = {
			name = "Lance",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-4",
		},
		[414] = {
			name = "Brock",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[415] = {
			name = "Misty",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-2",
		},
		[416] = {
			name = "Lt. Surge",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-3",
		},
		[417] = {
			name = "Erika",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-4",
		},
		[418] = {
			name = "Koga",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-5",
		},
		[420] = {
			name = "Sabrina",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-6",
		},
		[419] = {
			name = "Blaine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-7",
		},
		[350] = {
			name = "Giovanni",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-8",
		},
		-- The follow rivals are shown three times each, in order of starter located in the Middle ball, then Left, then Right
		[326] = {
			name = "Rival 1", -- Rival chose the Middle Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[327] = {
			name = "Rival 1", -- Rival chose the Left Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[328] = {
			name = "Rival 1", -- Rival chose the Right Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[329] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Middle",
		},
		[330] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Left",
		},
		[331] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Right",
		},
		[332] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[333] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[334] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[426] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[427] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[428] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[429] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Middle",
		},
		[430] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Left",
		},
		[431] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Right",
		},
		[432] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[433] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[434] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[435] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[436] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[437] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[438] = {
			name = "Champion",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[439] = {
			name = "Champion",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[440] = {
			name = "Champion",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[348] = {
			name = "Giovanni 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "frlg-gymleader-8",
		},
		[349] = {
			name = "Giovanni 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "frlg-gymleader-8",
		},
		[317] = {
			name = "Dojo Leader",
			group = TrainerData.TrainerGroups.Boss,
			filename = "frlg-blackbelt",
		},
	}
end
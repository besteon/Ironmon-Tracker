--[[
The various Pokémon moves (Gen 3)
Format for an entry:
{
	id: string -> internal id of the move, represented as an integer in a string
	name: string -> the name of the move as it appears in game
	type: string -> the type of damage the move does, using the PokemonTypes enum
	power: string -> the strength of the move specified in game as in integer, or "---" when not applicable
	pp: string -> the base amount of actions this move is capable of
	accuracy: string -> the percent accuracy of the move connecting, or "---" when not applicable
}
]]
MoveData = {
  {
    id = "---",
    name = "---",
    type = "---",
    power = "---",
    pp = "---",
    accuracy = "---"
  },
  {
    id = "1",
    name = "Pound",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "2",
    name = "Karate Chop",
    type = PokemonTypes.FIGHTING,
    power = "50",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "3",
    name = "DoubleSlap",
    type = PokemonTypes.NORMAL,
    power = "15",
    pp = "10",
    accuracy = "85"
  },
  {
    id = "4",
    name = "Comet Punch",
    type = PokemonTypes.NORMAL,
    power = "18",
    pp = "15",
    accuracy = "85"
  },
  {
    id = "5",
    name = "Mega Punch",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "6",
    name = "Pay Day",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "7",
    name = "Fire Punch",
    type = PokemonTypes.FIRE,
    power = "75",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "8",
    name = "Ice Punch",
    type = PokemonTypes.ICE,
    power = "75",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "9",
    name = "ThunderPunch",
    type = PokemonTypes.ELECTRIC,
    power = "75",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "10",
    name = "Scratch",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "11",
    name = "ViceGrip",
    type = PokemonTypes.NORMAL,
    power = "55",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "12",
    name = "Guillotine",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "30"
  },
  {
    id = "13",
    name = "Razor Wind",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "14",
    name = "Swords Dance",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "15",
    name = "Cut",
    type = PokemonTypes.NORMAL,
    power = "50",
    pp = "30",
    accuracy = "95"
  },
  {
    id = "16",
    name = "Gust",
    type = PokemonTypes.FLYING,
    power = "40",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "17",
    name = "Wing Attack",
    type = PokemonTypes.FLYING,
    power = "60",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "18",
    name = "Whirlwind",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "19",
    name = "Fly",
    type = PokemonTypes.FLYING,
    power = "70",
    pp = "15",
    accuracy = "95"
  },
  {
    id = "20",
    name = "Bind",
    type = PokemonTypes.NORMAL,
    power = "15",
    pp = "20",
    accuracy = "75"
  },
  {
    id = "21",
    name = "Slam",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "20",
    accuracy = "75"
  },
  {
    id = "22",
    name = "Vine Whip",
    type = PokemonTypes.GRASS,
    power = "35",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "23",
    name = "Stomp",
    type = PokemonTypes.NORMAL,
    power = "65",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "24",
    name = "Double Kick",
    type = PokemonTypes.FIGHTING,
    power = "30",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "25",
    name = "Mega Kick",
    type = PokemonTypes.NORMAL,
    power = "120",
    pp = "5",
    accuracy = "75"
  },
  {
    id = "26",
    name = "Jump Kick",
    type = PokemonTypes.FIGHTING,
    power = "70",
    pp = "25",
    accuracy = "95"
  },
  {
    id = "27",
    name = "Rolling Kick",
    type = PokemonTypes.FIGHTING,
    power = "60",
    pp = "15",
    accuracy = "85"
  },
  {
    id = "28",
    name = "Sand-Attack",
    type = PokemonTypes.GROUND,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "29",
    name = "Headbutt",
    type = PokemonTypes.NORMAL,
    power = "70",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "30",
    name = "Horn Attack",
    type = PokemonTypes.NORMAL,
    power = "65",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "31",
    name = "Fury Attack",
    type = PokemonTypes.NORMAL,
    power = "15",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "32",
    name = "Horn Drill",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "30"
  },
  {
    id = "33",
    name = "Tackle",
    type = PokemonTypes.NORMAL,
    power = "35",
    pp = "35",
    accuracy = "95"
  },
  {
    id = "34",
    name = "Body Slam",
    type = PokemonTypes.NORMAL,
    power = "85",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "35",
    name = "Wrap",
    type = PokemonTypes.NORMAL,
    power = "15",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "36",
    name = "Take Down",
    type = PokemonTypes.NORMAL,
    power = "90",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "37",
    name = "Thrash",
    type = PokemonTypes.NORMAL,
    power = "90",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "38",
    name = "Double-Edge",
    type = PokemonTypes.NORMAL,
    power = "120",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "39",
    name = "Tail Whip",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = "100"
  },
  {
    id = "40",
    name = "Poison Sting",
    type = PokemonTypes.POISON,
    power = "15",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "41",
    name = "Twineedle",
    type = PokemonTypes.BUG,
    power = "25",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "42",
    name = "Pin Missile",
    type = PokemonTypes.BUG,
    power = "14",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "43",
    name = "Leer",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = "100"
  },
  {
    id = "44",
    name = "Bite",
    type = PokemonTypes.DARK,
    power = "60",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "45",
    name = "Growl",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "100"
  },
  {
    id = "46",
    name = "Roar",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "47",
    name = "Sing",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "55"
  },
  {
    id = "48",
    name = "Supersonic",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "55"
  },
  {
    id = "49",
    name = "SonicBoom",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "90"
  },
  {
    id = "50",
    name = "Disable",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "55"
  },
  {
    id = "51",
    name = "Acid",
    type = PokemonTypes.POISON,
    power = "40",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "52",
    name = "Ember",
    type = PokemonTypes.FIRE,
    power = "40",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "53",
    name = "Flamethrower",
    type = PokemonTypes.FIRE,
    power = "95",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "54",
    name = "Mist",
    type = PokemonTypes.ICE,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "55",
    name = "Water Gun",
    type = PokemonTypes.WATER,
    power = "40",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "56",
    name = "Hydro Pump",
    type = PokemonTypes.WATER,
    power = "120",
    pp = "5",
    accuracy = "80"
  },
  {
    id = "57",
    name = "Surf",
    type = PokemonTypes.WATER,
    power = "95",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "58",
    name = "Ice Beam",
    type = PokemonTypes.ICE,
    power = "95",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "59",
    name = "Blizzard",
    type = PokemonTypes.ICE,
    power = "120",
    pp = "5",
    accuracy = "70"
  },
  {
    id = "60",
    name = "Psybeam",
    type = PokemonTypes.PSYCHIC,
    power = "65",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "61",
    name = "BubbleBeam",
    type = PokemonTypes.WATER,
    power = "65",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "62",
    name = "Aurora Beam",
    type = PokemonTypes.ICE,
    power = "65",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "63",
    name = "Hyper Beam",
    type = PokemonTypes.NORMAL,
    power = "150",
    pp = "5",
    accuracy = "90"
  },
  {
    id = "64",
    name = "Peck",
    type = PokemonTypes.FLYING,
    power = "35",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "65",
    name = "Drill Peck",
    type = PokemonTypes.FLYING,
    power = "80",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "66",
    name = "Submission",
    type = PokemonTypes.FIGHTING,
    power = "80",
    pp = "25",
    accuracy = "80"
  },
  {
    id = "67",
    name = "Low Kick",
    type = PokemonTypes.FIGHTING,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "68",
    name = "Counter",
    type = PokemonTypes.FIGHTING,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "69",
    name = "Seismic Toss",
    type = PokemonTypes.FIGHTING,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "70",
    name = "Strength",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "71",
    name = "Absorb",
    type = PokemonTypes.GRASS,
    power = "20",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "72",
    name = "Mega Drain",
    type = PokemonTypes.GRASS,
    power = "40",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "73",
    name = "Leech Seed",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "90"
  },
  {
    id = "74",
    name = "Growth",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "75",
    name = "Razor Leaf",
    type = PokemonTypes.GRASS,
    power = "55",
    pp = "25",
    accuracy = "95"
  },
  {
    id = "76",
    name = "SolarBeam",
    type = PokemonTypes.GRASS,
    power = "120",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "77",
    name = "PoisonPowder",
    type = PokemonTypes.POISON,
    power = PLACEHOLDER,
    pp = "35",
    accuracy = "75"
  },
  {
    id = "78",
    name = "Stun Spore",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = "75"
  },
  {
    id = "79",
    name = "Sleep Powder",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "75"
  },
  {
    id = "80",
    name = "Petal Dance",
    type = PokemonTypes.GRASS,
    power = "70",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "81",
    name = "String Shot",
    type = PokemonTypes.BUG,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "95"
  },
  {
    id = "82",
    name = "Dragon Rage",
    type = PokemonTypes.DRAGON,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "100"
  },
  {
    id = "83",
    name = "Fire Spin",
    type = PokemonTypes.FIRE,
    power = "15",
    pp = "15",
    accuracy = "70"
  },
  {
    id = "84",
    name = "ThunderShock",
    type = PokemonTypes.ELECTRIC,
    power = "40",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "85",
    name = "Thunderbolt",
    type = PokemonTypes.ELECTRIC,
    power = "95",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "86",
    name = "Thunder Wave",
    type = PokemonTypes.ELECTRIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "87",
    name = "Thunder",
    type = PokemonTypes.ELECTRIC,
    power = "120",
    pp = "10",
    accuracy = "70"
  },
  {
    id = "88",
    name = "Rock Throw",
    type = PokemonTypes.ROCK,
    power = "50",
    pp = "15",
    accuracy = "90"
  },
  {
    id = "89",
    name = "Earthquake",
    type = PokemonTypes.GROUND,
    power = "100",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "90",
    name = "Fissure",
    type = PokemonTypes.GROUND,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "30"
  },
  {
    id = "91",
    name = "Dig",
    type = PokemonTypes.GROUND,
    power = "60",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "92",
    name = "Toxic",
    type = PokemonTypes.POISON,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "85"
  },
  {
    id = "93",
    name = "Confusion",
    type = PokemonTypes.PSYCHIC,
    power = "50",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "94",
    name = "Psychic",
    type = PokemonTypes.PSYCHIC,
    power = "90",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "95",
    name = "Hypnosis",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "60"
  },
  {
    id = "96",
    name = "Meditate",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "97",
    name = "Agility",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "98",
    name = "Quick Attack",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "99",
    name = "Rage",
    type = PokemonTypes.NORMAL,
    power = "20",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "100",
    name = "Teleport",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "101",
    name = "Night Shade",
    type = PokemonTypes.GHOST,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "102",
    name = "Mimic",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "103",
    name = "Screech",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "85"
  },
  {
    id = "104",
    name = "Double Team",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = PLACEHOLDER
  },
  {
    id = "105",
    name = "Recover",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "106",
    name = "Harden",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "107",
    name = "Minimize",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "108",
    name = "SmokeScreen",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "109",
    name = "Confuse Ray",
    type = PokemonTypes.GHOST,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "100"
  },
  {
    id = "110",
    name = "Withdraw",
    type = PokemonTypes.WATER,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "111",
    name = "Defense Curl",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "112",
    name = "Barrier",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "113",
    name = "Light Screen",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "114",
    name = "Haze",
    type = PokemonTypes.ICE,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "115",
    name = "Reflect",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "116",
    name = "Focus Energy",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "117",
    name = "Bide",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "100"
  },
  {
    id = "118",
    name = "Metronome",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "119",
    name = "Mirror Move",
    type = PokemonTypes.FLYING,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "120",
    name = "Selfdestruct",
    type = PokemonTypes.NORMAL,
    power = "200",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "121",
    name = "Egg Bomb",
    type = PokemonTypes.NORMAL,
    power = "100",
    pp = "10",
    accuracy = "75"
  },
  {
    id = "122",
    name = "Lick",
    type = PokemonTypes.GHOST,
    power = "20",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "123",
    name = "Smog",
    type = PokemonTypes.POISON,
    power = "20",
    pp = "20",
    accuracy = "70"
  },
  {
    id = "124",
    name = "Sludge",
    type = PokemonTypes.POISON,
    power = "65",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "125",
    name = "Bone Club",
    type = PokemonTypes.GROUND,
    power = "65",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "126",
    name = "Fire Blast",
    type = PokemonTypes.FIRE,
    power = "120",
    pp = "5",
    accuracy = "85"
  },
  {
    id = "127",
    name = "Waterfall",
    type = PokemonTypes.WATER,
    power = "80",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "128",
    name = "Clamp",
    type = PokemonTypes.WATER,
    power = "35",
    pp = "10",
    accuracy = "75"
  },
  {
    id = "129",
    name = "Swift",
    type = PokemonTypes.NORMAL,
    power = "60",
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "130",
    name = "Skull Bash",
    type = PokemonTypes.NORMAL,
    power = "100",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "131",
    name = "Spike Cannon",
    type = PokemonTypes.NORMAL,
    power = "20",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "132",
    name = "Constrict",
    type = PokemonTypes.NORMAL,
    power = "10",
    pp = "35",
    accuracy = "100"
  },
  {
    id = "133",
    name = "Amnesia",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "134",
    name = "Kinesis",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "80"
  },
  {
    id = "135",
    name = "Softboiled",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "136",
    name = "Hi Jump Kick",
    type = PokemonTypes.FIGHTING,
    power = "85",
    pp = "20",
    accuracy = "90"
  },
  {
    id = "137",
    name = "Glare",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = "75"
  },
  {
    id = "138",
    name = "Dream Eater",
    type = PokemonTypes.PSYCHIC,
    power = "100",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "139",
    name = "Poison Gas",
    type = PokemonTypes.POISON,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "55"
  },
  {
    id = "140",
    name = "Barrage",
    type = PokemonTypes.NORMAL,
    power = "15",
    pp = "20",
    accuracy = "85"
  },
  {
    id = "141",
    name = "Leech Life",
    type = PokemonTypes.BUG,
    power = "20",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "142",
    name = "Lovely Kiss",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "75"
  },
  {
    id = "143",
    name = "Sky Attack",
    type = PokemonTypes.FLYING,
    power = "140",
    pp = "5",
    accuracy = "90"
  },
  {
    id = "144",
    name = "Transform",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "145",
    name = "Bubble",
    type = PokemonTypes.WATER,
    power = "20",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "146",
    name = "Dizzy Punch",
    type = PokemonTypes.NORMAL,
    power = "70",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "147",
    name = "Spore",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "148",
    name = "Flash",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "70"
  },
  {
    id = "149",
    name = "Psywave",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "80"
  },
  {
    id = "150",
    name = "Splash",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "151",
    name = "Acid Armor",
    type = PokemonTypes.POISON,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "152",
    name = "Crabhammer",
    type = PokemonTypes.WATER,
    power = "90",
    pp = "10",
    accuracy = "85"
  },
  {
    id = "153",
    name = "Explosion",
    type = PokemonTypes.NORMAL,
    power = "250",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "154",
    name = "Fury Swipes",
    type = PokemonTypes.NORMAL,
    power = "18",
    pp = "15",
    accuracy = "80"
  },
  {
    id = "155",
    name = "Bonemerang",
    type = PokemonTypes.GROUND,
    power = "50",
    pp = "10",
    accuracy = "90"
  },
  {
    id = "156",
    name = "Rest",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "157",
    name = "Rock Slide",
    type = PokemonTypes.ROCK,
    power = "75",
    pp = "10",
    accuracy = "90"
  },
  {
    id = "158",
    name = "Hyper Fang",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "15",
    accuracy = "90"
  },
  {
    id = "159",
    name = "Sharpen",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "160",
    name = "Conversion",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "161",
    name = "Tri Attack",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "162",
    name = "Super Fang",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "90"
  },
  {
    id = "163",
    name = "Slash",
    type = PokemonTypes.NORMAL,
    power = "70",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "164",
    name = "Substitute",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "165",
    name = "Struggle",
    type = PokemonTypes.NORMAL,
    power = "50",
    pp = "1",
    accuracy = "100"
  },
  {
    id = "166",
    name = "Sketch",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "1",
    accuracy = PLACEHOLDER
  },
  {
    id = "167",
    name = "Triple Kick",
    type = PokemonTypes.FIGHTING,
    power = "10",
    pp = "10",
    accuracy = "90"
  },
  {
    id = "168",
    name = "Thief",
    type = PokemonTypes.DARK,
    power = "40",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "169",
    name = "Spider Web",
    type = PokemonTypes.BUG,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "170",
    name = "Mind Reader",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "100"
  },
  {
    id = "171",
    name = "Nightmare",
    type = PokemonTypes.GHOST,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = PLACEHOLDER
  },
  {
    id = "172",
    name = "Flame Wheel",
    type = PokemonTypes.FIRE,
    power = "60",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "173",
    name = "Snore",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "174",
    name = "Curse",
    type = PokemonTypes.UNKNOWN,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "175",
    name = "Flail",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "176",
    name = "Conversion 2",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = PLACEHOLDER
  },
  {
    id = "177",
    name = "Aeroblast",
    type = PokemonTypes.FLYING,
    power = "100",
    pp = "5",
    accuracy = "95"
  },
  {
    id = "178",
    name = "Cotton Spore",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "85"
  },
  {
    id = "179",
    name = "Reversal",
    type = PokemonTypes.FIGHTING,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "180",
    name = "Spite",
    type = PokemonTypes.GHOST,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "100"
  },
  {
    id = "181",
    name = "Powder Snow",
    type = PokemonTypes.ICE,
    power = "40",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "182",
    name = "Protect",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "183",
    name = "Mach Punch",
    type = PokemonTypes.FIGHTING,
    power = "40",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "184",
    name = "Scary Face",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "90"
  },
  {
    id = "185",
    name = "Faint Attack",
    type = PokemonTypes.DARK,
    power = "60",
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "186",
    name = "Sweet Kiss",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "75"
  },
  {
    id = "187",
    name = "Belly Drum",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "188",
    name = "Sludge Bomb",
    type = PokemonTypes.POISON,
    power = "90",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "189",
    name = "Mud-Slap",
    type = PokemonTypes.GROUND,
    power = "20",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "190",
    name = "Octazooka",
    type = PokemonTypes.WATER,
    power = "65",
    pp = "10",
    accuracy = "85"
  },
  {
    id = "191",
    name = "Spikes",
    type = PokemonTypes.GROUND,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "192",
    name = "Zap Cannon",
    type = PokemonTypes.ELECTRIC,
    power = "100",
    pp = "5",
    accuracy = "50"
  },
  {
    id = "193",
    name = "Foresight",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "100"
  },
  {
    id = "194",
    name = "Destiny Bond",
    type = PokemonTypes.GHOST,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "195",
    name = "Perish Song",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "196",
    name = "Icy Wind",
    type = PokemonTypes.ICE,
    power = "55",
    pp = "15",
    accuracy = "95"
  },
  {
    id = "197",
    name = "Detect",
    type = PokemonTypes.FIGHTING,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "198",
    name = "Bone Rush",
    type = PokemonTypes.GROUND,
    power = "25",
    pp = "10",
    accuracy = "80"
  },
  {
    id = "199",
    name = "Lock-On",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "100"
  },
  {
    id = "200",
    name = "Outrage",
    type = PokemonTypes.DRAGON,
    power = "90",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "201",
    name = "Sandstorm",
    type = PokemonTypes.ROCK,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "202",
    name = "Giga Drain",
    type = PokemonTypes.GRASS,
    power = "60",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "203",
    name = "Endure",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "204",
    name = "Charm",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "205",
    name = "Rollout",
    type = PokemonTypes.ROCK,
    power = "30",
    pp = "20",
    accuracy = "90"
  },
  {
    id = "206",
    name = "False Swipe",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "40",
    accuracy = "100"
  },
  {
    id = "207",
    name = "Swagger",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "90"
  },
  {
    id = "208",
    name = "Milk Drink",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "209",
    name = "Spark",
    type = PokemonTypes.ELECTRIC,
    power = "65",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "210",
    name = "Fury Cutter",
    type = PokemonTypes.BUG,
    power = "10",
    pp = "20",
    accuracy = "95"
  },
  {
    id = "211",
    name = "Steel Wing",
    type = PokemonTypes.STEEL,
    power = "70",
    pp = "25",
    accuracy = "90"
  },
  {
    id = "212",
    name = "Mean Look",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "213",
    name = "Attract",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "214",
    name = "Sleep Talk",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "215",
    name = "Heal Bell",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "216",
    name = "Return",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "217",
    name = "Present",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "90"
  },
  {
    id = "218",
    name = "Frustration",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "219",
    name = "Safeguard",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "25",
    accuracy = PLACEHOLDER
  },
  {
    id = "220",
    name = "Pain Split",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "221",
    name = "Sacred Fire",
    type = PokemonTypes.FIRE,
    power = "100",
    pp = "5",
    accuracy = "95"
  },
  {
    id = "222",
    name = "Magnitude",
    type = PokemonTypes.GROUND,
    power = PLACEHOLDER,
    pp = "30",
    accuracy = "100"
  },
  {
    id = "223",
    name = "DynamicPunch",
    type = PokemonTypes.FIGHTING,
    power = "100",
    pp = "5",
    accuracy = "50"
  },
  {
    id = "224",
    name = "Megahorn",
    type = PokemonTypes.BUG,
    power = "120",
    pp = "10",
    accuracy = "85"
  },
  {
    id = "225",
    name = "DragonBreath",
    type = PokemonTypes.DRAGON,
    power = "60",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "226",
    name = "Baton Pass",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "227",
    name = "Encore",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "100"
  },
  {
    id = "228",
    name = "Pursuit",
    type = PokemonTypes.DARK,
    power = "40",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "229",
    name = "Rapid Spin",
    type = PokemonTypes.NORMAL,
    power = "20",
    pp = "40",
    accuracy = "100"
  },
  {
    id = "230",
    name = "Sweet Scent",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "231",
    name = "Iron Tail",
    type = PokemonTypes.STEEL,
    power = "100",
    pp = "15",
    accuracy = "75"
  },
  {
    id = "232",
    name = "Metal Claw",
    type = PokemonTypes.STEEL,
    power = "50",
    pp = "35",
    accuracy = "95"
  },
  {
    id = "233",
    name = "Vital Throw",
    type = PokemonTypes.FIGHTING,
    power = "70",
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "234",
    name = "Morning Sun",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "235",
    name = "Synthesis",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "236",
    name = "Moonlight",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "237",
    name = "Hidden Power",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "238",
    name = "Cross Chop",
    type = PokemonTypes.FIGHTING,
    power = "100",
    pp = "5",
    accuracy = "80"
  },
  {
    id = "239",
    name = "Twister",
    type = PokemonTypes.DRAGON,
    power = "40",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "240",
    name = "Rain Dance",
    type = PokemonTypes.WATER,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "241",
    name = "Sunny Day",
    type = PokemonTypes.FIRE,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "242",
    name = "Crunch",
    type = PokemonTypes.DARK,
    power = "80",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "243",
    name = "Mirror Coat",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "244",
    name = "Psych Up",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "245",
    name = "ExtremeSpeed",
    type = PokemonTypes.NORMAL,
    power = "80",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "246",
    name = "AncientPower",
    type = PokemonTypes.ROCK,
    power = "60",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "247",
    name = "Shadow Ball",
    type = PokemonTypes.GHOST,
    power = "80",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "248",
    name = "Future Sight",
    type = PokemonTypes.PSYCHIC,
    power = "80",
    pp = "15",
    accuracy = "90"
  },
  {
    id = "249",
    name = "Rock Smash",
    type = PokemonTypes.FIGHTING,
    power = "20",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "250",
    name = "Whirlpool",
    type = PokemonTypes.WATER,
    power = "15",
    pp = "15",
    accuracy = "70"
  },
  {
    id = "251",
    name = "Beat Up",
    type = PokemonTypes.DARK,
    power = "10",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "252",
    name = "Fake Out",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "253",
    name = "Uproar",
    type = PokemonTypes.NORMAL,
    power = "50",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "254",
    name = "Stockpile",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "255",
    name = "Spit Up",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "100"
  },
  {
    id = "256",
    name = "Swallow",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "257",
    name = "Heat Wave",
    type = PokemonTypes.FIRE,
    power = "100",
    pp = "10",
    accuracy = "90"
  },
  {
    id = "258",
    name = "Hail",
    type = PokemonTypes.ICE,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "259",
    name = "Torment",
    type = PokemonTypes.DARK,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "260",
    name = "Flatter",
    type = PokemonTypes.DARK,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "261",
    name = "Will-O-Wisp",
    type = PokemonTypes.FIRE,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "75"
  },
  {
    id = "262",
    name = "Memento",
    type = PokemonTypes.DARK,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "263",
    name = "Facade",
    type = PokemonTypes.NORMAL,
    power = "70",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "264",
    name = "Focus Punch",
    type = PokemonTypes.FIGHTING,
    power = "150",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "265",
    name = "SmellingSalt",
    type = PokemonTypes.NORMAL,
    power = "60",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "266",
    name = "Follow Me",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "267",
    name = "Nature Power",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "268",
    name = "Charge",
    type = PokemonTypes.ELECTRIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "269",
    name = "Taunt",
    type = PokemonTypes.DARK,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "270",
    name = "Helping Hand",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "271",
    name = "Trick",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = "100"
  },
  {
    id = "272",
    name = "Role Play",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "273",
    name = "Wish",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "274",
    name = "Assist",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "275",
    name = "Ingrain",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "276",
    name = "Superpower",
    type = PokemonTypes.FIGHTING,
    power = "120",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "277",
    name = "Magic Coat",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = PLACEHOLDER
  },
  {
    id = "278",
    name = "Recycle",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "279",
    name = "Revenge",
    type = PokemonTypes.FIGHTING,
    power = "60",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "280",
    name = "Brick Break",
    type = PokemonTypes.FIGHTING,
    power = "75",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "281",
    name = "Yawn",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "282",
    name = "Knock Off",
    type = PokemonTypes.DARK,
    power = "20",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "283",
    name = "Endeavor",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "100"
  },
  {
    id = "284",
    name = "Eruption",
    type = PokemonTypes.FIRE,
    power = "150",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "285",
    name = "Skill Swap",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "286",
    name = "Imprison",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "287",
    name = "Refresh",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "288",
    name = "Grudge",
    type = PokemonTypes.GHOST,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "289",
    name = "Snatch",
    type = PokemonTypes.DARK,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "290",
    name = "Secret Power",
    type = PokemonTypes.NORMAL,
    power = "70",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "291",
    name = "Dive",
    type = PokemonTypes.WATER,
    power = "60",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "292",
    name = "Arm Thrust",
    type = PokemonTypes.FIGHTING,
    power = "15",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "293",
    name = "Camouflage",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "294",
    name = "Tail Glow",
    type = PokemonTypes.BUG,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "295",
    name = "Luster Purge",
    type = PokemonTypes.PSYCHIC,
    power = "70",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "296",
    name = "Mist Ball",
    type = PokemonTypes.PSYCHIC,
    power = "70",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "297",
    name = "FeatherDance",
    type = PokemonTypes.FLYING,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "100"
  },
  {
    id = "298",
    name = "Teeter Dance",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "299",
    name = "Blaze Kick",
    type = PokemonTypes.FIRE,
    power = "85",
    pp = "10",
    accuracy = "90"
  },
  {
    id = "300",
    name = "Mud Sport",
    type = PokemonTypes.GROUND,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = PLACEHOLDER
  },
  {
    id = "301",
    name = "Ice Ball",
    type = PokemonTypes.ICE,
    power = "30",
    pp = "20",
    accuracy = "90"
  },
  {
    id = "302",
    name = "Needle Arm",
    type = PokemonTypes.GRASS,
    power = "60",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "303",
    name = "Slack Off",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "10",
    accuracy = PLACEHOLDER
  },
  {
    id = "304",
    name = "Hyper Voice",
    type = PokemonTypes.NORMAL,
    power = "90",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "305",
    name = "Poison Fang",
    type = PokemonTypes.POISON,
    power = "50",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "306",
    name = "Crush Claw",
    type = PokemonTypes.NORMAL,
    power = "75",
    pp = "10",
    accuracy = "95"
  },
  {
    id = "307",
    name = "Blast Burn",
    type = PokemonTypes.FIRE,
    power = "150",
    pp = "5",
    accuracy = "90"
  },
  {
    id = "308",
    name = "Hydro Cannon",
    type = PokemonTypes.WATER,
    power = "150",
    pp = "5",
    accuracy = "90"
  },
  {
    id = "309",
    name = "Meteor Mash",
    type = PokemonTypes.STEEL,
    power = "100",
    pp = "10",
    accuracy = "85"
  },
  {
    id = "310",
    name = "Astonish",
    type = PokemonTypes.GHOST,
    power = "30",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "311",
    name = "Weather Ball",
    type = PokemonTypes.NORMAL,
    power = "50",
    pp = "10",
    accuracy = "100"
  },
  {
    id = "312",
    name = "Aromatherapy",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "313",
    name = "Fake Tears",
    type = PokemonTypes.DARK,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "314",
    name = "Air Cutter",
    type = PokemonTypes.FLYING,
    power = "55",
    pp = "25",
    accuracy = "95"
  },
  {
    id = "315",
    name = "Overheat",
    type = PokemonTypes.FIRE,
    power = "140",
    pp = "5",
    accuracy = "90"
  },
  {
    id = "316",
    name = "Odor Sleuth",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "100"
  },
  {
    id = "317",
    name = "Rock Tomb",
    type = PokemonTypes.ROCK,
    power = "50",
    pp = "10",
    accuracy = "80"
  },
  {
    id = "318",
    name = "Silver Wind",
    type = PokemonTypes.BUG,
    power = "60",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "319",
    name = "Metal Sound",
    type = PokemonTypes.STEEL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = "85"
  },
  {
    id = "320",
    name = "GrassWhistle",
    type = PokemonTypes.GRASS,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = "55"
  },
  {
    id = "321",
    name = "Tickle",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = "100"
  },
  {
    id = "322",
    name = "Cosmic Power",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "323",
    name = "Water Spout",
    type = PokemonTypes.WATER,
    power = "150",
    pp = "5",
    accuracy = "100"
  },
  {
    id = "324",
    name = "Signal Beam",
    type = PokemonTypes.BUG,
    power = "75",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "325",
    name = "Shadow Punch",
    type = PokemonTypes.GHOST,
    power = "60",
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "326",
    name = "Extrasensory",
    type = PokemonTypes.PSYCHIC,
    power = "80",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "327",
    name = "Sky Uppercut",
    type = PokemonTypes.FIGHTING,
    power = "85",
    pp = "15",
    accuracy = "90"
  },
  {
    id = "328",
    name = "Sand Tomb",
    type = PokemonTypes.GROUND,
    power = "15",
    pp = "15",
    accuracy = "70"
  },
  {
    id = "329",
    name = "Sheer Cold",
    type = PokemonTypes.ICE,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = "30"
  },
  {
    id = "330",
    name = "Muddy Water",
    type = PokemonTypes.WATER,
    power = "95",
    pp = "10",
    accuracy = "85"
  },
  {
    id = "331",
    name = "Bullet Seed",
    type = PokemonTypes.GRASS,
    power = "10",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "332",
    name = "Aerial Ace",
    type = PokemonTypes.FLYING,
    power = "60",
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "333",
    name = "Icicle Spear",
    type = PokemonTypes.ICE,
    power = "10",
    pp = "30",
    accuracy = "100"
  },
  {
    id = "334",
    name = "Iron Defense",
    type = PokemonTypes.STEEL,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = PLACEHOLDER
  },
  {
    id = "335",
    name = "Block",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "5",
    accuracy = PLACEHOLDER
  },
  {
    id = "336",
    name = "Howl",
    type = PokemonTypes.NORMAL,
    power = PLACEHOLDER,
    pp = "40",
    accuracy = PLACEHOLDER
  },
  {
    id = "337",
    name = "Dragon Claw",
    type = PokemonTypes.DRAGON,
    power = "80",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "338",
    name = "Frenzy Plant",
    type = PokemonTypes.GRASS,
    power = "150",
    pp = "5",
    accuracy = "90"
  },
  {
    id = "339",
    name = "Bulk Up",
    type = PokemonTypes.FIGHTING,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "340",
    name = "Bounce",
    type = PokemonTypes.FLYING,
    power = "85",
    pp = "5",
    accuracy = "85"
  },
  {
    id = "341",
    name = "Mud Shot",
    type = PokemonTypes.GROUND,
    power = "55",
    pp = "15",
    accuracy = "95"
  },
  {
    id = "342",
    name = "Poison Tail",
    type = PokemonTypes.POISON,
    power = "50",
    pp = "25",
    accuracy = "100"
  },
  {
    id = "343",
    name = "Covet",
    type = PokemonTypes.NORMAL,
    power = "40",
    pp = "40",
    accuracy = "100"
  },
  {
    id = "344",
    name = "Volt Tackle",
    type = PokemonTypes.ELECTRIC,
    power = "120",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "345",
    name = "Magical Leaf",
    type = PokemonTypes.GRASS,
    power = "60",
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "346",
    name = "Water Sport",
    type = PokemonTypes.WATER,
    power = PLACEHOLDER,
    pp = "15",
    accuracy = PLACEHOLDER
  },
  {
    id = "347",
    name = "Calm Mind",
    type = PokemonTypes.PSYCHIC,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "348",
    name = "Leaf Blade",
    type = PokemonTypes.GRASS,
    power = "70",
    pp = "15",
    accuracy = "100"
  },
  {
    id = "349",
    name = "Dragon Dance",
    type = PokemonTypes.DRAGON,
    power = PLACEHOLDER,
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "350",
    name = "Rock Blast",
    type = PokemonTypes.ROCK,
    power = "25",
    pp = "10",
    accuracy = "80"
  },
  {
    id = "351",
    name = "Shock Wave",
    type = PokemonTypes.ELECTRIC,
    power = "60",
    pp = "20",
    accuracy = PLACEHOLDER
  },
  {
    id = "352",
    name = "Water Pulse",
    type = PokemonTypes.WATER,
    power = "60",
    pp = "20",
    accuracy = "100"
  },
  {
    id = "353",
    name = "Doom Desire",
    type = PokemonTypes.STEEL,
    power = "120",
    pp = "5",
    accuracy = "85"
  },
  {
    id = "354",
    name = "Psycho Boost",
    type = PokemonTypes.PSYCHIC,
    power = "140",
    pp = "5",
    accuracy = "90"
  }
}

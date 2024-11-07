BattleManager = {}

BattleManager.Actions = {
	Attack = "Attack",
	Bag = "Bag",
	Switch = "Switch",
	Run = "Run",
}

BattleManager.Strategies = {
	Kill = "Kill",
	Run = "Run",
	Capture = "Capture",
}

BattleManager.Status = {
	Burn = 1,
	Poison = 2,
	Paralysis = 3,
	Confusion = 4,
	Freeze = 5,
	Sleep = 6,
	Love = 7,
	Flinch = 8,
	BadPoison = 9
}

-- Params list @TODO Doubles battle
-- hitMean = 3: By default 1. The damage is inflicted 3 times per attack on average
-- statusInflicted = {}: By default {}. List of status change the attack can inflict
-- statusInflictedChance = 10: By default 100. Percentage of status change chance (here 10%)
-- waitBefore = true: By default false. The attack hits on the 2nd turn
-- waitAfter = true: By default false. Need to wait 1 turn after the attack
-- statsOwnChange = {["atk"]=2, ["def"]=-1}: By default {}. List of stat changes done by the attack
-- statsOwnChangeChance = 10: By default 100. Percentage of stats change chance (here 10%)
-- switchFoe = true: By default false. The attack forces the foe to change Pokemon or flee
-- hideBefore = true: By default false. The attack hides the pokemon on the first turn and hits on the second (ex Fly)
-- trapFoe = true: By default false. The attack forbids the foe from fleeing
-- hitsOwnIfFailed = true: By default false. The user gets damaged if move fails
-- statsFoeChange = {["atk"]=2, ["def"]=-1}: By default {}. List of stat changes done by the attack
-- statsFoeChangeChance = 10: By default 100. Percentage of stats change chance (here 10%)
-- recoilPercentage = 25: By default 0. Recoil damage in percentage of damage dealt
-- loopUntilFail = true: By default false. The attack is used automatically until it fails
-- fixedDamage = 20: By default 0. The attack also does this exact amount of damage each time
-- fixedOwnLevelDamage = true: By default false. The attack does exactly your own level in damage
-- forbidden = true: By default false. The move is forbidden in Kaizo IronMon
-- highCriticalRatio = true: By default false. True if the move has an increased critical ratio
-- rngBased = true: By default false. True if the attack is entirely RNG based
-- hitDelay = 3: By default 0. Hits with an average delay of 3 turns
BattleManager.MoveParams = {
	{},--Pound
	{hitMean = 3},--Karate Chop
	{hitMean = 3},--DoubleSlap
	{hitMean = 3},--CometPunch
	{},--Mega Punch
	{},--Pay Day
	{statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 10},--Fire Punch
	{statusInflicted = {BattleManager.Status.Freeze}, statusInflictedChance = 10},--Ice Punch
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 10},--ThunderPunch
	{},--Scratch
	{},--ViceGrip
	{},--Guillotine
	{waitBefore = true},--Razor Wind
	{statsOwnChange = {["atk"]=2}},--Swords Dance
	{},--Cut
	{},--Gust
	{},--Wing Attack
	{switchFoe = true},--Whirlwind
	{hideBefore = true},--Fly
	{trapFoe = true, loopUntilFail = true},--Bind
	{},--Slam
	{},--Vine Whip
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Stomp @TODO Specific check for Minimize
	{hitMean = 2},--Double Kick
	{},--Mega Kick
	{hitsOwnIfFailed = true},--Jump Kick
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Rolling Kick
	{statsFoeChange = {["acc"]=-1}},--Sand-Attack
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Headbutt
	{},--Horn Attack
	{hitMean = 3},--Fury Attack
	{},--Horn Drill
	{},--Tackle
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 30},--Body Slam
	{trapFoe = true},--Wrap
	{recoilPercentage = 25},--Take Down
	{loopUntilFail = true},-- Thrash
	{recoilPercentage = 33},--Double-Edge
	{statsFoeChange = {["def"]=-1}},--Tail Whip
	{statusInflicted = {BattleManager.Status.Poison}, statusInflictedChance = 30},--Poison Sting
	{hitMean = 2, statusInflicted = {BattleManager.Status.Poison}, statusInflictedChance = 20},--Twineedle
	{hitMean = 3},--Pin Missile
	{statsFoeChange = {["def"]=-1}},--Leer
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Bite
	{statsFoeChange = {["atk"]=-1}},--Growl
	{switchFoe = true},--Roar
	{statusInflicted = {BattleManager.Status.Sleep}},--Sing
	{statusInflicted = {BattleManager.Status.Confusion}},--Supersonic
	{fixedDamage = 20},--Sonicboom
	{},--Disable
	{statsFoeChange = {["def"]=-1}, statsFoeChangeChance = 10},--Acid
	{statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 10},--Ember
	{statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 10},--Flamethrower
	{},--Mist
	{},--Water Gun
	{},--Hydro Pump
	{},--Surf
	{statusInflicted = {BattleManager.Status.Freeze}, statusInflictedChance = 10},--Ice Beam
	{statusInflicted = {BattleManager.Status.Freeze}, statusInflictedChance = 10},--Blizzard
	{statusInflicted = {BattleManager.Status.Confusion}, statusInflictedChance = 10},--Psybeam
	{statsFoeChange = {["spe"]=-1}, statsFoeChangeChance = 10}, --BubbleBeam
	{statsFoeChange = {["atk"]=-1}, statsFoeChangeChance = 10},--Aurora Beam
	{waitAfter = true},--Hyper Beam
	{},--Peck
	{},--Drill Peck
	{},--Low Kick
	{},--Counter
	{fixedOwnLevelDamage = true},--Seismic Toss
	{},--Strength
	{forbidden = true},--Absorb
	{forbidden = true},--Mega Drain
	{forbidden = true},--Leech Seed
	{statsOwnChange = {["spa"]=1}},--Growth
	{highCriticalRatio = true},--Razor Leaf
	{waitBefore = true},--Solar Beam @TODO Specific check for Sun
	{statusInflicted = {BattleManager.Status.Poison}},--PoisonPowder
	{statusInflicted = {BattleManager.Status.Paralysis}},--Stun Spore
	{statusInflicted = {BattleManager.Status.Sleep}},--Sleep Powder
	{loopUntilFail = true},--Petal Dance
	{statsFoeChange = {["spe"]=-1}},--String Shot
	{fixedDamage = 40},--Dragon Rage
	{trapFoe = true},--Fire Spin
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 10},--ThunderShock
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 10},--Thunderbolt
	{statusInflicted = {BattleManager.Status.Paralysis}},--Thunder Wave
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 10},--Thunder @TODO add weather check for Rain/Sun
	{},--Rock Throw
	{},--Earthquake @TODO Check if enemy under the ground
	{},--Fissure
	{hideBefore = true},--Dig
	{statusInflicted = {BattleManager.Status.BadPoison}},--Toxic
	{statusInflicted = {BattleManager.Status.Confusion}, statusInflictedChance = 10},--Confusion
	{statsFoeChange = {["atk"]=-1}, statsFoeChangeChance = 10},--Psychic
	{statusInflicted = {BattleManager.Status.Sleep}},--Hypnosis
	{statsOwnChange = {["atk"]=1}},--Meditate
	{statsOwnChange = {["spe"]=1}},--Agility
	{},--Quick Attack
	{},--Rage
	{forbidden = true},--Teleport
	{fixedOwnLevelDamage = true},--Night Shade
	{rngBased = true},--Mimic
	{statsFoeChange = {["def"]=-2}},--Screech
	{statsOwnChange = {["eva"]=1}},--Double Team
	{forbidden = true},--Recover
	{statsOwnChange = {["def"]=1}},--Harden
	{statsOwnChange = {["eva"]=1}},--Minimize
	{statsFoeChange = {["acc"]=-1}},--SmokeScreen
	{statusInflicted = {BattleManager.Status.Confusion}},--Confuse Ray
	{statsOwnChange = {["def"]=1}},--Withdraw
	{statsOwnChange = {["def"]=1}},--Defense Curl
	{statsOwnChange = {["def"]=2}},--Barrier
	{},--Light Screen
	{},--Haze
	{},--Reflect
	{},--Focus Energy
	{forbidden = true},--Bide
	{rngBased = true},--Metronome
	{rngBased = true},--Mirror Move
	{forbidden = true},--Selfdestruct
	{},--Egg Bomb
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 30},--Lick
	{statusInflicted = {BattleManager.Status.Poison}, statusInflictedChance = 40},--Smog
	{statusInflicted = {BattleManager.Status.Poison}, statusInflictedChance = 30},--Sludge
	{},--Bone Club
	{},--Fire Blast
	{},--Waterfall
	{trapFoe = true},--Clamp
	{},--Swift
	{statsOwnChange = {["def"]=1}, waitBefore = true},--Skull Bash
	{hitMean = 3},--Spike Cannon
	{statsFoeChange = {["spe"]=-1}, statsFoeChangeChance = 10},--Constrict
	{statsOwnChange = {["spd"]=2}},--Amnesia
	{statsFoeChange = {["acc"]=-1}},--Kinesis
	{forbidden = true},--Softboiled
	{hitsOwnIfFailed = true},--Hi Jump Kick
	{statusInflicted = {BattleManager.Status.Paralysis}},--Glare
	{forbidden = true},--Dream Eater
	{statusInflicted = {BattleManager.Status.Poison}},--Poison Gas
	{hitMean = 3},--Barrage
	{forbidden = true},--Leech Life
	{statusInflicted = {BattleManager.Status.Sleep}},--Lovely Kiss
	{waitBefore = true},--Sky Attack
	{forbidden = true},--Transform
	{statsFoeChange = {["spe"]=-1}, statsFoeChangeChance = 10},--Bubble
	{statusInflicted = {BattleManager.Status.Confusion}, statusInflictedChance = 20},--Dizzy Punch
	{forbidden = true},--Spore
	{statsFoeChange = {["acc"]=-1}},--Flash
	{fixedOwnLevelDamage = true},--Psywave
	{},--Splash
	{statsOwnChange = {["def"]=2}},--Acid Armor
	{highCriticalRatio = true},--Crabhammer
	{forbidden = true},--Explosion
	{hitMean = 3},--Fury Swipes
	{hitMean = 2},--Bonemerang
	{forbidden = true},--Rest
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Rock Slide
	{},--Hyper Fang
	{statsOwnChange = {["atk"]=1}},--Sharpen
	{forbidden = true},--Conversion
	{statusInflicted = {BattleManager.Status.Paralysis, BattleManager.Status.Freeze, BattleManager.Status.Burn}, statusInflictedChance = 20},--Tri Attack
	{},--Super Fang
	{highCriticalRatio = true},--Slash
	{forbidden = true},--Substitute
	{},--Struggle, doesn't matter I guess
	{},--Sketch @TODO A move scorer for Sketch?
	{hitMean = 3},--Triple Kick
	{},--Thief
	{},--Spider Web
	{},--Mind Reader
	{},--Nightmare
	{statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 10},--Flame Wheel
	{forbidden = true},--Snore
	{forbidden = true},--Curse
	{},--Flail
	{forbidden = true},--Conversion 2
	{},--Aeroblast
	{statsFoeChange = {["spe"]=-1}},--Cotton Spore
	{},--Reversal
	{},--Spite
	{statusInflicted = {BattleManager.Status.Freeze}, statusInflictedChance = 10},--Powder Snow
	{},--Protect
	{},--Mach Punch
	{statsFoeChange = {["spe"]=-1}},--Scary Face
	{},--Faint Attack
	{statusInflicted = {BattleManager.Status.Confusion}},--Sweet Kiss
	{forbidden = true},--Belly Drum
	{statusInflicted = {BattleManager.Status.Poison}, statusInflictedChance = 30},--Sludge Bomb
	{statsFoeChange = {["acc"]=-1}},--Mud-Slap
	{statsFoeChange = {["acc"]=-1}, statsFoeChangeChance = 50},--Octazooka
	{},--Spikes
	{statusInflicted = {BattleManager.Status.Paralysis}},--Zap Cannon
	{},--Foresight
	{forbidden = true},--Destiny Bond
	{forbidden = true},--Perish Song
	{statsFoeChange = {["spe"]=-1}},--Icy Wind
	{},--Detect
	{hitMean = 3},--Bone Rush
	{},--Lock-On
	{loopUntilFail = true},--Outrage
	{forbidden = true},--Sandstorm
	{forbidden = true},--Giga Drain
	{},--Endure
	{statsFoeChange = {["atk"]=-1}},--Charm
	{loopUntilFail = true},--Rollout
	{},--False Swipe @TODO Manage last hit
	{statsFoeChange = {["atk"]=2}, statusInflicted = {BattleManager.Status.Confusion}},--Swagger
	{forbidden = true},--Milk Drink
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 30},--Spark
	{},--Fury Cutter
	{statsOwnChange = {["def"]=1}, statsOwnChangeChance = 10},--Steel Wing
	{trapFoe = true},--Mean Look
	{},--Attract @TODO Manage genders
	{},--Sleep Talk
	{forbidden = true},--Heal Bell
	{},--Return
	{rngBased = true},--Present
	{},--Frustration
	{},--Safeguard
	{},--Pain Split @TODO Manage Split
	{statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 50},--Sacred Fire
	{rngBased = true},--Magnitude
	{statusInflicted = {BattleManager.Status.Confusion}},--DynamicPunch
	{},--Megahorn
	{statusInflicted = {BattleManager.Status.Paralysis}, statusInflictedChance = 30},--DragonBreath
	{forbidden = true},--Baton Pass
	{},--Encore
	{},--Pursuit
	{},--Rapid Spin
	{statsFoeChange = {["eva"]=-1}},--Sweet Scent
	{statsFoeChange = {["def"]=-1}, statsFoeChangeChance = 30},--Iron Tail
	{statsOwnChange = {["atk"]=1}, statsOwnChangeChance = 10},--Metal Claw
	{},--Vital Throw
	{forbidden = true},--Morning Sun
	{forbidden = true},--Synthesis
	{forbidden = true},--Moonlight
	{},--Hidden Power @TODO Manage Hidden Power
	{},--Cross Chop
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 50},--Twister
	{},--Rain Dance @TODO Manage Weather
	{},--Sunny Day @TODO Manage Weather
	{statsFoeChange = {["spd"]=-1}, statsFoeChangeChance = 20},--Crunch
	{},--Mirror Coat
	{},--Psych Up
	{},--ExtremeSpeed
	{statsOwnChange = {["atk"]=1, ["def"]=1, ["spa"]=1, ["spd"]=1, ["spe"]=1}, statsOwnChangeChance = 10},--AncientPower
	{statsFoeChange = {["spd"]=-1}, statsFoeChangeChance = 20},--Shadow Ball
	{hitDelay = 2},--Future Sight
	{statsFoeChange = {["def"]=-1}, statsFoeChangeChance = 50},--Rock Smash
	{trapFoe = true},--Whirlpool
	{forbidden = true},--Beat Up
	{statusInflicted = {BattleManager.Status.Flinch}},--Fake Out
	{loopUntilFail = true},--Uproar
	{},--Stockpile
	{forbidden = true},--Spit Up
	{forbidden = true},--Swallow
	{statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 10},--Heat Wave
	{forbidden = true},--Hail
	{},--Torment
	{statsFoeChange = {["spa"]=2}, statusInflicted = {BattleManager.Status.Confusion}},--Flatter
	{statusInflicted = {BattleManager.Status.Burn}},--Will-O-Wisp
	{forbidden = true},--Memento
	{},--Facade @TODO Manage Facade
	{forbidden = true},--Focus Punch
	{},--SmellingSalt @TODO Check paralysis
	{},--Follow Me
	{},--Nature Power @TODO Manage Nature Power
	{},--Charge
	{forbidden = true},--Taunt
	{},--Helping Hand
	{forbidden = true},--Trick
	{},--Role Play
	{forbidden = true},--Wish
	{forbidden = true},--Assist
	{forbidden = true},--Ingrain
	{statsOwnChange = {["atk"]=-1, ["def"]=-1}},--Superpower
	{},--Magic Coat
	{forbidden = true},--Recycle
	{},--Revenge
	{},--Brick Break
	{statusInflicted = {BattleManager.Status.Sleep}, hitDelay = 1},--Yawn
	{},--Knock Off
	{},--Endeavor @TODO Manage Endeavor
	{},--Eruption
	{},--Skill Swap
	{},--Imprison
	{forbidden = true},--Refresh
	{},--Grudge
	{},--Snatch
	{},--Secret Power
	{hideBefore = true},--Dive
	{hitMean = 3},--Arm Thrust
	{},--Camouflage
	{statsOwnChange = {["spa"]=2}},--Tail Glow
	{statsFoeChange = {["spd"]=-1}, statsFoeChangeChance = 50},--Luster Purge
	{statsFoeChange = {["spa"]=-1}, statsFoeChangeChance = 50},--Mist Ball
	{statsFoeChange = {["atk"]=-2}},--FeatherDance
	{statusInflicted = {BattleManager.Status.Confusion}},--Teeter Dance
	{highCriticalRatio = true, statusInflicted = {BattleManager.Status.Burn}, statusInflictedChance = 10},--Blaze Kick
	{},--Mud Sport
	{loopUntilFail = true},--Ice Ball
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Needle Arm
	{forbidden = true},--Slack Off
	{},--Hyper Voice
	{statusInflicted = {BattleManager.Status.BadPoison}, statusInflictedChance = 30},--Poison Fang
	{statsFoeChange = {["def"]=-1}, statsFoeChangeChance = 50},--Crush Claw
	{waitAfter = true},--Blast Burn
	{waitAfter = true},--Hydro Cannon
	{statsOwnChange = {["atk"]=1}, statsOwnChangeChance = 20},--Meteor Mash
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 30},--Astonish @TODO Check Minimize
	{},--Weather Ball @TODO Manage Weather
	{forbidden = true},--Aromatherapy
	{statsFoeChange = {["spd"]=-2}},--Fake Tears
	{highCriticalRatio = true},--Air Cutter
	{statsOwnChange = {["spa"]=-2}},--Overheat
	{},--Odor Sleuth
	{trapFoe = true, statsFoeChange = {["spd"]=-1}},--Rock Tomb
	{statsOwnChange = {["atk"]=1, ["def"]=1, ["spa"]=1, ["spd"]=1, ["spe"]=1}, statsOwnChangeChance = 10},--Silver Wind
	{statsFoeChange = {["spd"]=-2}},--Metal Sound
	{statusInflicted = {BattleManager.Status.Sleep}},--GrassWhistle
	{statsFoeChange = {["atk"]=-1, ["def"]=-1}},--Tickle
	{statsOwnChange = {["def"]=1, ["spd"]=1}},--Cosmic Power
	{},--Water Spout
	{statusInflicted = {BattleManager.Status.Confusion}, statusInflictedChance = 10},--Signal Beam
	{},--Shadow Punch
	{statusInflicted = {BattleManager.Status.Flinch}, statusInflictedChance = 10},--Extrasensory @TODO Check for Minimize
	{},--Sky Uppercut @TODO Check if enemy in the sky
	{trapFoe = true},--Sand Tomb
	{},--Sheer Cold
	{statsFoeChange = {["acc"]=-1}, statsFoeChangeChance = 30},--Muddy Water
	{hitMean = 3},--Bullet Seed
	{},--Aerial Ace
	{loopUntilFail = true},--Icicle Spear
	{statsOwnChange = {["def"]=2}},--Iron Defense
	{trapFoe = true},--Block
	{statsOwnChange = {["atk"]=1}},--Howl
	{},--Dragon Claw
	{waitAfter = true},--Frenzy Plant
	{statsOwnChange = {["atk"]=1, ["def"]=1}},--Bulk Up
	{hideBefore = true},--Bounce
	{statsFoeChange = {["spe"]=-1}},--Mud Shot
	{highCriticalRatio = true, statusInflicted = {BattleManager.Status.Poison}, statusInflictedChance = 10},--Poison Tail
	{},--Covet
	{recoilPercentage = 33},--Volt Tackle
	{},--Magical Leaf
	{},--Water Sport
	{statsOwnChange = {["spa"]=1, ["spd"]=1}},--Calm Mind
	{highCriticalRatio = true},--Leaf Blade
	{statsOwnChange = {["atk"]=1, ["spe"]=1}},--Dragon Dance
	{hitMean = 3},--Rock Blast
	{},--Shock Wave
	{statusInflicted = {BattleManager.Status.Confusion}, statusInflictedChance = 20},--Water Pulse
	{hitDelay = 2},--Doom Desire
	{statsOwnChange = {["spd"]=-2}},--Psycho Boost
}

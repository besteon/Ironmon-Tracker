Program = {
	currentScreen = 1,
	previousScreens = {}, -- breadcrumbs for clicking the Back button
	inStartMenu = false,
	inCatchingTutorial = false,
	hasCompletedTutorial = false,
	friendshipRequired = 220,
	activeFormId = 0,
	Frames = {
		waitToDraw = 30, -- counts down
		highAccuracyUpdate = 10, -- counts down
		lowAccuracyUpdate = 30, -- counts down
		three_sec_update = 180, -- counts down
		saveData = 3600, -- counts down
		carouselActive = 0, -- counts up
		battleDataDelay = 60, -- counts down
	},
}

Program.Screens = {
	TRACKER = TrackerScreen.drawScreen,
	INFO = InfoScreen.drawScreen,
	NAVIGATION = NavigationMenu.drawScreen,
	STARTUP = StartupScreen.drawScreen,
	UPDATE = UpdateScreen.drawScreen,
	SETUP = SetupScreen.drawScreen,
	EXTRAS = ExtrasScreen.drawScreen,
	QUICKLOAD = QuickloadScreen.drawScreen,
	GAME_SETTINGS = GameOptionsScreen.drawScreen,
	THEME = Theme.drawScreen,
	MANAGE_DATA = TrackedDataScreen.drawScreen,
	STATS = StatsScreen.drawScreen,
	MOVE_HISTORY = MoveHistoryScreen.drawScreen,
	TYPE_DEFENSES = TypeDefensesScreen.drawScreen,
	GAMEOVER = GameOverScreen.drawScreen,
	STREAMER = StreamerScreen.drawScreen,
	TIME_MACHINE = TimeMachineScreen.drawScreen,
}

Program.GameData = {
	evolutionStones = { -- The evolution stones currently in bag
			[93] = 0, -- Sun Stone
			[94] = 0, -- Moon Stone
			[95] = 0, -- Fire Stone
			[96] = 0, -- Thunder Stone
			[97] = 0, -- Water Stone
			[98] = 0, -- Leaf Stone
	},
}

Program.ActiveRepel = {
	inUse = false,
	stepCount = 0,
	duration = 100,
	shouldDisplay = function(self)
		local enabledAndAllowed = Options["Display repel usage"] and Program.ActiveRepel.inUse and Program.isValidMapLocation()
		local hasConflict = Battle.inBattle or Battle.battleStarting or Program.inStartMenu or GameOverScreen.isDisplayed or LogOverlay.isDisplayed
		return enabledAndAllowed and not hasConflict
	end,
}

Program.Pedometer = {
	totalSteps = 0, -- updated from GAME_STATS
	lastResetCount = 0, -- num steps since last "reset", for counting new steps
	goalSteps = 0, -- num steps that is set by the user as a milestone goal to reach, 0 to disable
	getCurrentStepcount = function(self) return math.max(self.totalSteps - self.lastResetCount, 0) end,
	isInUse = function(self)
		local enabledAndAllowed = Options["Display pedometer"] and Program.isValidMapLocation()
		local hasConflict = Battle.inBattle or Battle.battleStarting or GameOverScreen.isDisplayed or LogOverlay.isDisplayed
		return enabledAndAllowed and not hasConflict
	end,
}

Program.AutoSaver = {
	knownSaveCount = 0,
	framesUntilNextSave = -1,
	updateSaveCount = function(self) -- returns true if the savecount has been updated
		local currentSaveCount = Utils.getGameStat(Constants.GAME_STATS.SAVED_GAME) or 0
		local saveSuccessCountdown = Memory.readbyte(GameSettings.sSaveDialogDelay) or 0
		-- Starts at 60 on success, then immediately decrements to 59 before checking if the save menu should close
		if saveSuccessCountdown == 60 and currentSaveCount > self.knownSaveCount and currentSaveCount < 99999 then
			self.knownSaveCount = currentSaveCount
			return true
		end
		return false
	end,
	checkForNextSave = function(self)
		if not Main.IsOnBizhawk() then return end -- flush saveRAM only for Bizhawk
		if self:updateSaveCount() then
			client.saveram()
		end
	end
}

function Program.initialize()
	-- If an update is available, offer that up first before going to the Tracker StartupScreen
	if Main.Version.showUpdate then
		Program.currentScreen = Program.Screens.UPDATE
	else
		Program.currentScreen = Program.Screens.STARTUP
	end

	-- Check if requirement for Friendship evos has changed (Default:219, MakeEvolutionsFaster:159)
	local friendshipRequired = Memory.readbyte(GameSettings.FriendshipRequiredToEvo) + 1
	if friendshipRequired > 1 and friendshipRequired <= 220 then
		Program.friendshipRequired = friendshipRequired
	end

	Program.AutoSaver:updateSaveCount()

	-- Update data asap
	Program.Frames.highAccuracyUpdate = 0
	Program.Frames.lowAccuracyUpdate = 0
	Program.Frames.three_sec_update = 0
	Program.Frames.waitToDraw = 1
end

function Program.mainLoop()
	if Main.loadNextSeed and not Main.IsOnBizhawk() then -- required escape for mGBA
		Main.LoadNextRom()
		return
	end
	Input.checkForInput()
	Program.update()
	Battle.update()
	Program.redraw(false)
	Program.stepFrames() -- TODO: Really want a better way to handle this
end

-- 'forced' = true will force a draw, skipping the normal frame wait time
function Program.redraw(forced)
	-- Only redraw the screen every half second (60 frames/sec)
	if not forced and Program.Frames.waitToDraw > 0 then
		Program.Frames.waitToDraw = Program.Frames.waitToDraw - 1
		return
	end

	Program.Frames.waitToDraw = 30
	Drawing.drawScreen(Program.currentScreen)
	if LogOverlay.isDisplayed and Main.IsOnBizhawk() then
		LogOverlay.drawScreen()
	end

	if CustomCode.enabled and CustomCode.afterRedraw ~= nil then
		CustomCode.afterRedraw()
	end
end

function Program.changeScreenView(screen)
	-- table.insert(Program.previousScreens, Program.currentScreen) -- TODO: implement later
	Program.currentScreen = screen
	Program.redraw(true)
end

-- TODO: Currently unused, implement later
function Program.goBackToPreviousScreen()
	Utils.printDebug("DEBUG: From %s previous screens.", #Program.previousScreens)
	if #Program.previousScreens == 0 then
		Program.currentScreen = Program.Screens.TRACKER
	else
		Program.currentScreen = table.remove(Program.previousScreens)
	end
	Program.redraw(true)
end

function Program.destroyActiveForm()
	if Program.activeFormId ~= nil and Program.activeFormId ~= 0 then
		forms.destroy(Program.activeFormId)
		Program.activeFormId = 0
	end
end

function Program.update()
	if CustomCode.enabled and CustomCode.beforeDataUpdate ~= nil and Program.Frames.lowAccuracyUpdate == 0 then
		CustomCode.beforeDataUpdate()
	end

	-- Be careful adding too many things to this 10 frame update
	if Program.Frames.highAccuracyUpdate == 0 then
		Program.updateMapLocation() -- trying this here to solve many future problems

		-- If the lead Pokemon changes, then update the animated Pokemon picture box
		if Options["Animated Pokemon popout"] then
			local leadPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn, true)
			if leadPokemon ~= nil and leadPokemon.pokemonID ~= 0 and Program.isValidMapLocation() then
				if leadPokemon.pokemonID ~= Drawing.AnimatedPokemon.pokemonID then
					Drawing.AnimatedPokemon:setPokemon(leadPokemon.pokemonID)
				elseif Drawing.AnimatedPokemon.requiresRelocating then
					Drawing.AnimatedPokemon:relocatePokemon()
				end
			end
		end
	end

	-- Don't bother reading game data before a game even begins
	if not Program.isValidMapLocation() then
		return
	end

	-- Get any "new" information from game memory for player's pokemon team every half second (60 frames/sec)
	if Program.Frames.lowAccuracyUpdate == 0 then
		Program.inCatchingTutorial = Program.isInCatchingTutorial()

		if not Program.inCatchingTutorial and not Program.isInEvolutionScene() then
			Program.updatePokemonTeams()

			-- If the game hasn't started yet, show the start-up screen instead of the main Tracker screen
			if Program.currentScreen == Program.Screens.STARTUP and Program.isValidMapLocation() then
				Program.currentScreen = Program.Screens.TRACKER
			elseif Battle.CurrentRoute.mapId ~= nil and RouteData.Locations.IsInHallOfFame[Battle.CurrentRoute.mapId] then
				Program.currentScreen = Program.Screens.GAMEOVER
			end

			-- Check if summary screen has being shown
			if not Tracker.Data.hasCheckedSummary then
				if Memory.readbyte(GameSettings.sMonSummaryScreen) ~= 0 then
					Tracker.Data.hasCheckedSummary = true
				end
			end

			-- Check if a Pokemon in the player's party is learning a move, if so track it
			local learnedInfoTable = Program.getLearnedMoveInfoTable()
			if learnedInfoTable.pokemonID ~= nil then
				Tracker.TrackMove(learnedInfoTable.pokemonID, learnedInfoTable.moveId, learnedInfoTable.level)
			end

			if Options["Display repel usage"] and not (Battle.inBattle or Battle.battleStarting) then
				-- Check if the player is in the start menu (for hiding the repel usage icon)
				Program.inStartMenu = Program.isInStartMenu()
				-- Check for active repel and steps remaining
				if not Program.inStartMenu then
					Program.updateRepelSteps()
				end
			end

			-- Update step count only if the option is enabled
			if Program.Pedometer:isInUse() then
				Program.Pedometer.totalSteps = Utils.getGameStat(Constants.GAME_STATS.STEPS)
			end

			Program.AutoSaver:checkForNextSave()
			TimeMachineScreen.checkCreatingRestorePoint()
		end
	end

	-- Only update "Heals in Bag", Evolution Stones, "PC Heals", and "Badge Data" info every 3 seconds (3 seconds * 60 frames/sec)
	if Program.Frames.three_sec_update == 0 then
		Program.updateBagItems()
		Program.updatePCHeals()
		Program.updateBadgesObtained()
	end

	-- Only save tracker data every 1 minute (60 seconds * 60 frames/sec) and after every battle (set elsewhere)
	if Program.Frames.saveData == 0 then
		-- Don't bother saving tracked data if the player doesn't have a Pokemon yet
		if Options["Auto save tracked game data"] and Tracker.getPokemon(1, true) ~= nil then
			Tracker.saveData()
		end
	end

	if CustomCode.enabled and CustomCode.afterDataUpdate ~= nil and Program.Frames.lowAccuracyUpdate == 0 then
		CustomCode.afterDataUpdate()
	end
end

function Program.stepFrames()
	Program.Frames.highAccuracyUpdate = (Program.Frames.highAccuracyUpdate - 1) % 10
	Program.Frames.lowAccuracyUpdate = (Program.Frames.lowAccuracyUpdate - 1) % 30
	Program.Frames.three_sec_update = (Program.Frames.three_sec_update - 1) % 180
	Program.Frames.saveData = (Program.Frames.saveData - 1) % 3600
	Program.Frames.carouselActive = Program.Frames.carouselActive + 1
end

function Program.updateRepelSteps()
	-- Checks for an active repel and updates the current steps remaining
	-- Game uses a variable for the repel steps remaining, which remains at 0 when there's no active repel
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	local repelStepCountOffset = Utils.inlineIf(GameSettings.game == 3, 0x40, 0x42)
	local repelStepCount = Memory.readbyte(saveblock1Addr + GameSettings.gameVarsOffset + repelStepCountOffset)
	if repelStepCount ~= nil and repelStepCount > 0 then
		Program.ActiveRepel.inUse = true
		if repelStepCount ~= Program.ActiveRepel.stepCount then
			Program.ActiveRepel.stepCount = repelStepCount
			-- Duration is defaulted to normal repel (100 steps), check if super or max is used instead
			if repelStepCount > Program.ActiveRepel.duration then
				if repelStepCount <= 200 then
					-- Super Repel
					Program.ActiveRepel.duration = 200
				elseif repelStepCount <= 250 then
					-- Max Repel
					Program.ActiveRepel.duration = 250
				end
			end
		end
	elseif repelStepCount == 0 then
		-- Reset the active repel data when none is active (remaining step count 0)
		Program.ActiveRepel.inUse = false
		Program.ActiveRepel.stepCount = 0
		Program.ActiveRepel.duration = 100
	end
end

function Program.updatePokemonTeams()
	-- Check for updates to each pokemon team
	local addressOffset = 0

	-- Check if it's a new game (no Pokémon yet)
	if not Tracker.Data.isNewGame and Tracker.Data.ownTeam[1] == 0 then
		Tracker.Data.isNewGame = true
	end

	for i = 1, 6, 1 do
		-- Lookup information on the player's Pokemon first
		local personality = Memory.readdword(GameSettings.pstats + addressOffset)
		local trainerID = Memory.readdword(GameSettings.pstats + addressOffset + 4)
		-- local previousPersonality = Tracker.Data.ownTeam[i] -- See below
		Tracker.Data.ownTeam[i] = personality

		if personality ~= 0 or trainerID ~= 0 then
			local newPokemonData = Program.readNewPokemon(GameSettings.pstats + addressOffset, personality)

			if Program.validPokemonData(newPokemonData) then
				-- Sets the player's trainerID as soon as they get their first Pokemon
				if Tracker.Data.isNewGame and newPokemonData.trainerID ~= nil and newPokemonData.trainerID ~= 0 then
					if Tracker.Data.trainerID == nil or Tracker.Data.trainerID == 0 then
						Tracker.Data.trainerID = newPokemonData.trainerID
					elseif Tracker.Data.trainerID ~= newPokemonData.trainerID then
						-- Reset the tracker data as old data was loaded and we have a different trainerID now
						print("Old/Incorrect data was detected for this ROM. Initializing new data.")
						Tracker.resetData()
						Tracker.Data.trainerID = newPokemonData.trainerID
					end

					-- Unset the new game flag
					Tracker.Data.isNewGame = false
				end

				-- Remove trainerID value from the pokemon data itself since it's now owned by the player, saves data space
				-- No longer remove, as it's currently used to verify Trainer pokemon with personality values of 0
				-- newPokemonData.trainerID = nil

				Tracker.addUpdatePokemon(newPokemonData, personality, true)

				-- TODO: Removing for now until some better option is available, not sure there is one
				-- If this is a newly caught Pokémon, track all of its moves. Can't do this later cause TMs/HMs
				-- if previousPersonality == 0 then
				-- 	for _, move in ipairs(newPokemonData.moves) do
				-- 		Tracker.TrackMove(newPokemonData.pokemonID, move.id, newPokemonData.level)
				-- 	end
				-- end
			end
		end

		-- Then lookup information on the opposing Pokemon
		personality = Memory.readdword(GameSettings.estats + addressOffset)
		trainerID = Memory.readdword(GameSettings.estats + addressOffset + 4)
		Tracker.Data.otherTeam[i] = personality

		if personality ~= 0 or trainerID ~= 0 then
			local newPokemonData = Program.readNewPokemon(GameSettings.estats + addressOffset, personality)

			if Program.validPokemonData(newPokemonData) then
				-- Double-check a race condition where current PP values are wildly out of range if retrieved right before a battle begins
				if not Battle.inBattle then
					for _, move in pairs(newPokemonData.moves) do
						if move.id ~= 0 then
							move.pp = tonumber(MoveData.Moves[move.id].pp) -- set value to max PP
						end
					end
				end

				Tracker.addUpdatePokemon(newPokemonData, personality, false)
			end
		end

		-- Next Pokemon - Each is offset by 100 bytes
		addressOffset = addressOffset + 100
	end
end

function Program.readNewPokemon(startAddress, personality)
	local otid = Memory.readdword(startAddress + 4)
	local magicword = Utils.bit_xor(personality, otid) -- The XOR encryption key for viewing the Pokemon data

	local aux          = personality % 24
	local growthoffset = (MiscData.TableData.growth[aux + 1] - 1) * 12
	local attackoffset = (MiscData.TableData.attack[aux + 1] - 1) * 12
	-- local effortoffset = (MiscData.TableData.effort[aux + 1] - 1) * 12
	local miscoffset   = (MiscData.TableData.misc[aux + 1] - 1) * 12

	-- Pokemon Data structure: https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_substructures_(Generation_III)
	local growth1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + growthoffset), magicword)
	-- local growth2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + growthoffset + 4), magicword) -- Currently unused
	local growth3 = Utils.bit_xor(Memory.readdword(startAddress + 32 + growthoffset + 8), magicword)
	local attack1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + attackoffset), magicword)
	local attack2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + attackoffset + 4), magicword)
	local attack3 = Utils.bit_xor(Memory.readdword(startAddress + 32 + attackoffset + 8), magicword)
	local misc2   = Utils.bit_xor(Memory.readdword(startAddress + 32 + miscoffset + 4), magicword)

	-- Unused data memory reads
	-- local effort1 = Utils.bit_xor(Memory.readdword(startAddress + 32 + effortoffset), magicword)
	-- local effort2 = Utils.bit_xor(Memory.readdword(startAddress + 32 + effortoffset + 4), magicword)
	-- local effort3 = Utils.bit_xor(Memory.readdword(startAddress + 32 + effortoffset + 8), magicword)
	-- local misc1   = Utils.bit_xor(Memory.readdword(startAddress + 32 + miscoffset), magicword)
	-- local misc3   = Utils.bit_xor(Memory.readdword(startAddress + 32 + miscoffset + 8), magicword)

	-- Checksum, currently unused
	-- local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	-- 		+ Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
	-- 		+ Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
	-- 		+ Utils.addhalves(misc1) + Utils.addhalves(misc2) + Utils.addhalves(misc3)
	-- cs = cs % 65536

	local species = Utils.getbits(growth1, 0, 16) -- Pokemon's Pokedex ID
	local abilityNum = Utils.getbits(misc2, 31, 1) -- [0 or 1] to determine which ability, available in PokemonData

	-- Determine status condition
	local status_aux = Memory.readdword(startAddress + 80)
	local sleep_turns_result = 0
	local status_result = 0
	if status_aux == 0 then --None
		status_result = 0
	elseif status_aux < 8 then -- Sleep
		sleep_turns_result = status_aux
		status_result = 1
	elseif status_aux == 8 then -- Poison
		status_result = 2
	elseif status_aux == 16 then -- Burn
		status_result = 3
	elseif status_aux == 32 then -- Freeze
		status_result = 4
	elseif status_aux == 64 then -- Paralyze
		status_result = 5
	elseif status_aux == 128 then -- Toxic Poison
		status_result = 6
	end

	-- Can likely improve this further using memory.read_bytes_as_array but would require testing to verify
	local level_and_currenthp = Memory.readdword(startAddress + 84)
	local maxhp_and_atk = Memory.readdword(startAddress + 88)
	local def_and_speed = Memory.readdword(startAddress + 92)
	local spatk_and_spdef = Memory.readdword(startAddress + 96)

	return {
		personality = personality,
		trainerID = Utils.getbits(otid, 0, 16),
		pokemonID = species,
		heldItem = Utils.getbits(growth1, 16, 16),
		friendship = Utils.getbits(growth3, 8, 8),
		level = Utils.getbits(level_and_currenthp, 0, 8),
		nature = personality % 25,
		isEgg = Utils.getbits(misc2, 30, 1), -- [0 or 1] to determine if mon is still an egg (1 if true)
		abilityNum = abilityNum,
		status = status_result,
		sleep_turns = sleep_turns_result,
		curHP = Utils.getbits(level_and_currenthp, 16, 16),
		stats = {
			hp = Utils.getbits(maxhp_and_atk, 0, 16),
			atk = Utils.getbits(maxhp_and_atk, 16, 16),
			def = Utils.getbits(def_and_speed, 0, 16),
			spa = Utils.getbits(spatk_and_spdef, 0, 16),
			spd = Utils.getbits(spatk_and_spdef, 16, 16),
			spe = Utils.getbits(def_and_speed, 16, 16),
		},
		statStages = { hp = 6, atk = 6, def = 6, spa = 6, spd = 6, spe = 6, acc = 6, eva = 6 },
		moves = {
			{ id = Utils.getbits(attack1, 0, 16), level = 1, pp = Utils.getbits(attack3, 0, 8) },
			{ id = Utils.getbits(attack1, 16, 16), level = 1, pp = Utils.getbits(attack3, 8, 8) },
			{ id = Utils.getbits(attack2, 0, 16), level = 1, pp = Utils.getbits(attack3, 16, 8) },
			{ id = Utils.getbits(attack2, 16, 16), level = 1, pp = Utils.getbits(attack3, 24, 8) },
		},

		-- Unused data that can be added back in later
		-- secretID = Utils.getbits(otid, 16, 16), -- Unused
		-- experience = Utils.getbits(growth2, 32, 31), -- Unused
		-- pokerus = Utils.getbits(misc1, 0, 8), -- Unused
		-- iv = misc2,
		-- ev1 = effort1,
		-- ev2 = effort2,
	}
end

function Program.updatePCHeals()
	-- Updates PC Heal tallies and handles auto-tracking PC Heal counts when the option is on
	-- Currently checks the total number of heals from pokecenters and from mom
	-- Does not include whiteouts, as those don't increment either of these gamestats

	-- Save blocks move and are re-encrypted right as the battle starts
	if Battle.inBattle or Battle.battleStarting then
		return
	end

	-- Make sure the player is in a map location that can perform a PC heal
	if not RouteData.Locations.CanPCHeal[Battle.CurrentRoute.mapId] then
		return
	end

	local gameStat_UsedPokecenter = Utils.getGameStat(Constants.GAME_STATS.USED_POKECENTER)
	-- Turns out Game Freak are weird and only increment mom heals in RSE, not FRLG
	local gameStat_RestedAtHome = Utils.getGameStat(Constants.GAME_STATS.RESTED_AT_HOME)

	local combinedHeals = gameStat_UsedPokecenter + gameStat_RestedAtHome

	if combinedHeals ~= Tracker.Data.gameStatsHeals then
		-- Update the local tally if there is a new heal
		Tracker.Data.gameStatsHeals = combinedHeals
		-- Only change the displayed PC Heals count when the option is on and auto-tracking is enabled
		if Options["Track PC Heals"] and TrackerScreen.Buttons.PCHealAutoTracking.toggleState then
			if Options["PC heals count downward"] then
				-- Automatically count down
				Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
				if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			else
				-- Automatically count up
				Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
				if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			end
		end
	end
end

function Program.updateBadgesObtained()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return
	end

	local badgeBits = nil
	local saveblock1Addr = Utils.getSaveBlock1Addr()
	if GameSettings.game == 1 then -- Ruby/Sapphire
		badgeBits = Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 2 then -- Emerald
		badgeBits = Utils.getbits(Memory.readword(saveblock1Addr + GameSettings.badgeOffset), 7, 8)
	elseif GameSettings.game == 3 then -- FireRed/LeafGreen
		badgeBits = Memory.readbyte(saveblock1Addr + GameSettings.badgeOffset)
	end

	if badgeBits ~= nil then
		for index = 1, 8, 1 do
			local badgeName = "badge" .. index
			local badgeButton = TrackerScreen.Buttons[badgeName]
			local badgeState = Utils.getbits(badgeBits, index - 1, 1)
			badgeButton:updateState(badgeState)
		end
	end
end

function Program.updateMapLocation()
	-- For now leaving this attached to "Battle" but eventually we'll want to use map coordinates outside of it
	local newMapId = Memory.readword(GameSettings.gMapHeader + 0x12) -- 0x12: mapLayoutId

	-- If the player is in a new area, auto-lookup for mGBA screen
	if not Main.IsOnBizhawk() and newMapId ~= Battle.CurrentRoute.mapId then
		local isFirstLocation = Battle.CurrentRoute.mapId == nil or Battle.CurrentRoute.mapId == 0
		MGBA.Screens.LookupRoute:setData(newMapId, isFirstLocation)
	end
	Battle.CurrentRoute.mapId = newMapId
end

-- More or less used to determine if the player has begun playing the game, returns true if so.
function Program.isValidMapLocation()
	return Battle.CurrentRoute.mapId ~= nil and Battle.CurrentRoute.mapId ~= 0
end

function Program.HandleExit()
	if Main.IsOnBizhawk() then
		gui.clearImageCache()
		Drawing.clearGUI()
		client.SetGameExtraPadding(0, 0, 0, 0)
		forms.destroyall()
	end
end

-- Returns a table that contains {pokemonID, level, and moveId} of the player's Pokemon that is currently learning a new move via experience level-up.
function Program.getLearnedMoveInfoTable()
	local battleMsg = Memory.readdword(GameSettings.gBattlescriptCurrInstr)

	-- If the battle message relates to learning a new move, read in that move id
	if GameSettings.BattleScript_LearnMoveLoop <= battleMsg and battleMsg <= GameSettings.BattleScript_LearnMoveReturn then
		local moveToLearnId = Memory.readword(GameSettings.gMoveToLearn)

		local battleStructAddress
		if GameSettings.gBattleStructPtr ~= nil then -- Pointer unavailable in RS
			battleStructAddress = Memory.readdword(GameSettings.gBattleStructPtr)
		else
			battleStructAddress = 0x02000000 -- gSharedMem
		end

		local partyIndex = Memory.readbyte(battleStructAddress + 0x10) + 1 -- expGetterMonId: Party index of player (1-6)
		local pokemon = Tracker.getPokemon(partyIndex, true)
		if pokemon ~= nil then
			return {
				pokemonID = pokemon.pokemonID,
				level = pokemon.level,
				moveId = moveToLearnId,
			}
		end

		return {
			pokemonID = nil,
			level = nil,
			moveId = moveToLearnId,
		}
	end

	return {
		pokemonID = nil,
		level = nil,
		moveId = nil,
	}
end

-- Useful for dynamically getting the Pokemon's types if they have changed somehow (Color change, Transform, etc)
function Program.getPokemonTypes(isOwn, isLeft)
	local ownerAddressOffset = Utils.inlineIf(isOwn, 0x0, 0x58)
	local leftAddressOffset = Utils.inlineIf(isLeft, 0x0, 0xB0)
	local typesData = Memory.readword(GameSettings.gBattleMons + 0x21 + ownerAddressOffset + leftAddressOffset)
	return {
		PokemonData.TypeIndexMap[Utils.getbits(typesData, 0, 8)],
		PokemonData.TypeIndexMap[Utils.getbits(typesData, 8, 8)],
	}
end

-- Returns true only if the player hasn't completed the catching tutorial
function Program.isInCatchingTutorial()
	if Program.hasCompletedTutorial then return false end

	local tutorialFlag = Memory.readbyte(GameSettings.sSpecialFlags)
	if tutorialFlag == 3 then
		Program.inCatchingTutorial = true
	elseif Program.inCatchingTutorial and tutorialFlag == 0 then
		Program.inCatchingTutorial = false
		Program.hasCompletedTutorial = true
	end

	return Program.inCatchingTutorial
end

function Program.isInEvolutionScene()
	local evoInfo
	--Ruby and Sapphire reference sEvoInfo (EvoInfo struct) directly. All other Gen 3 games instead store a pointer to the EvoInfo struct which needs to be read first
	if GameSettings.game ~= 1 then
		evoInfo = Memory.readdword(GameSettings.sEvoStructPtr)
	else
		evoInfo = GameSettings.sEvoInfo
	end
	-- third byte of EvoInfo is dedicated to the taskId
	local taskID = Memory.readbyte(evoInfo + 0x2)

	--only 16 tasks possible max in gTasks
	if taskID > 15 then return false end

	--Check for Evolution Task (Task_EvolutionScene + 0x1); Task struct size is 0x28
	local taskFunc = Memory.readdword(GameSettings.gTasks + (0x28 * taskID))
	if taskFunc ~= GameSettings.Task_EvolutionScene then return false end

	--Check if the Task is active
	local isActive = Memory.readbyte(GameSettings.gTasks + (0x28 * taskID) + 0x4)
	if isActive ~= 1 then return false end

	return true
end

-- Returns true if player is in the start menu (or the subsequent pokedex/pokemon/bag/etc menus)
function Program.isInStartMenu()
	-- Current Issues:
	-- 1) Sometimes this window ID gets unset for a brief duration during the transition back to the start menu
	-- 2) This window ID doesn't exist at all in Ruby/Sapphire, yet to figure out an alternative
	if GameSettings.game == 1 then return false end -- Skip checking for Ruby/Sapphire

	local startMenuWindowId = Memory.readbyte(GameSettings.sStartMenuWindowId)
	return startMenuWindowId == 1
end

-- Pokemon is valid if it has a valid id, helditem, and each move that exists is a real move.
function Program.validPokemonData(pokemonData)
	if pokemonData == nil then return false end

	-- If the Pokemon exists, but it's ID is invalid
	if not PokemonData.isValid(pokemonData.pokemonID) and pokemonData.pokemonID ~= 0 then -- 0 = blank pokemon id
		return false
	end

	-- If the Pokemon is holding an item, and that item is invalid
	if pokemonData.heldItem ~= nil and (pokemonData.heldItem < 0 or pokemonData.heldItem > 376) then
		return false
	end

	-- For each of the Pokemon's moves that isn't blank, is that move real
	for _, move in pairs(pokemonData.moves) do
		if not MoveData.isValid(move.id) and move.id ~= 0 then -- 0 = blank move id
			return false
		end
	end

	return true
end

function Program.updateBagItems()
	if not Tracker.Data.isViewingOwn then return end

	local leadPokemon = Battle.getViewedPokemon(true)
	if leadPokemon ~= nil then
		local healingItems, evolutionStones = Program.getBagItems()
		if healingItems ~= nil then
			Tracker.Data.healingItems = Program.calcBagHealingItems(leadPokemon.stats.hp, healingItems)
		end
		if evolutionStones ~= nil then
			Program.GameData.evolutionStones = evolutionStones
		end
	end
end

function Program.calcBagHealingItems(pokemonMaxHP, healingItemsInBag)
	local totals = {
		healing = 0,
		numHeals = 0,
	}

	-- Check for potential divide-by-zero errors
	if pokemonMaxHP == nil or pokemonMaxHP == 0 then
		return totals
	end

	-- Formatted as: healingItemsInBag[itemID] = quantity
	for itemID, quantity in pairs(healingItemsInBag) do
		local healItemData = MiscData.HealingItems[itemID]
		if healItemData ~= nil and quantity > 0 then
			local healingPercentage = 0
			if healItemData.type == MiscData.HealingType.Constant then
				local percentage = healItemData.amount / pokemonMaxHP * 100
				if percentage > 100 then
					percentage = 100
				end
				healingPercentage = percentage * quantity
			elseif healItemData.type == MiscData.HealingType.Percentage then
				healingPercentage = healItemData.amount * quantity
			end
			-- Healing is in a percentage compared to the mon's max HP
			totals.healing = totals.healing + healingPercentage
			totals.numHeals = totals.numHeals + quantity
		end
	end

	return totals
end

function Program.getBagItems()
	local healingItems = {}
	local evoStones = {
		[93] = 0, -- Sun Stone
		[94] = 0, -- Moon Stone
		[95] = 0, -- Fire Stone
		[96] = 0, -- Thunder Stone
		[97] = 0, -- Water Stone
		[98] = 0, -- Leaf Stone
	}

	local key = Utils.getEncryptionKey(2) -- Want a 16-bit key
	local saveBlock1Addr = Utils.getSaveBlock1Addr()
	local addressesToScan = {
		[saveBlock1Addr + GameSettings.bagPocket_Items_offset] = GameSettings.bagPocket_Items_Size,
		[saveBlock1Addr + GameSettings.bagPocket_Berries_offset] = GameSettings.bagPocket_Berries_Size,
	}
	for address, size in pairs(addressesToScan) do
		for i = 0, (size - 1), 1 do
			--read 4 bytes at once, should be less expensive than reading two sets of 2 bytes.
			local itemid_and_quantity = Memory.readdword(address + i * 0x4)
			local itemID = Utils.getbits(itemid_and_quantity, 0, 16)
			if itemID ~= 0 then
				local quantity = Utils.getbits(itemid_and_quantity, 16, 16)
				if key ~= nil then quantity = Utils.bit_xor(quantity, key) end

				if MiscData.HealingItems[itemID] ~= nil then
					healingItems[itemID] = quantity
				elseif MiscData.EvolutionStones[itemID] ~= nil then
					evoStones[itemID] = quantity
				end
			end
		end
	end

	return healingItems, evoStones
end

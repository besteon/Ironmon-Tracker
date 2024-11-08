require("extensions.ironbot.BotUtils")
require("extensions.ironbot.BattleManager")
require("extensions.ironbot.InputInjecter")

local function IronBot()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {}
	self.version = "1.0"
	self.name = "IronBot"
	self.author = "DarkySquid"
	self.description = "Bot for Kaizo IronMon"
	self.github = "Darkysquid/Ironmon-Tracker"
	self.url = string.format("https://github.com/%s", self.github or "")

	--------------------------------------
	-- LOCAL FUNCTIONS
	--------------------------------------

	--- Manages the inputs to inject up from game start to the lab fight
	local function manageIntro()
		-- INTRO
		if BotUtils.introToDo then
            InputInjecter.injectInput(InputInjecter.INTRO_INP[BotUtils.introFrameCount])
            BotUtils.introFrameCount = BotUtils.introFrameCount + 1
            if BotUtils.introFrameCount > #InputInjecter.INTRO_INP then
                BotUtils.introToDo = false
            end
        elseif BotUtils.introToStarterToDo then
            InputInjecter.injectInput(InputInjecter.INTRO_TO_STARTER_INP[BotUtils.introToStarterFrameCount])
            BotUtils.introToStarterFrameCount = BotUtils.introToStarterFrameCount + 1
            if BotUtils.introToStarterFrameCount > #InputInjecter.INTRO_TO_STARTER_INP then
                BotUtils.introToStarterToDo = false
            end
        end
        if BotUtils.introToStarterToDo then
            return
        end
        -- STARTER
        if BotUtils.starterId == nil then
            local starterIsOk = false
            local id = TrackerScreen.PokeBalls.chosenBall
            -- Check if all starters are unusable. In that case we take the first selected starter.
            local starter1 = memory.read_u16_le(0x5B1DF8, 'ROM')
            local starter2 = memory.read_u16_le(0x5B1DFA, 'ROM')
            local starter3 = memory.read_u16_le(0x5B1DFC, 'ROM')
            if BotUtils.hasValue(BotUtils.UNUSABLE_MONS, starter1)
                and BotUtils.hasValue(BotUtils.UNUSABLE_MONS, starter2)
                and BotUtils.hasValue(BotUtils.UNUSABLE_MONS, starter3) then
                    return id
            end
            while starterIsOk == false do
                local pokeId = memory.read_u16_le(0x5B1DF8 + 2 * (id-1), 'ROM')
                print("PokeID: " .. tostring(pokeId))
                if BotUtils.hasValue(BotUtils.UNUSABLE_MONS, pokeId) then
                    TrackerScreen.Buttons.RerollBallPicker:onClick()
                    id = TrackerScreen.PokeBalls.chosenBall
                else
                    starterIsOk = true
                end
            end
            BotUtils.starterId = id
            print("Starter: " .. tostring(BotUtils.starterId))
            if BotUtils.starterId < 3 then
                InputInjecter.addToFifo('L', 5)
                InputInjecter.addWaitToFifo(30)
            end
            if BotUtils.starterId < 2 then
                InputInjecter.addToFifo('L', 5)
                InputInjecter.addWaitToFifo(30)
            end
            InputInjecter.mashToFifo('A', '', 60)
        end
	end

	--- Manage battle intro and get the battle strategy
	--- @return string strategy from BattleManager.Strategies
	local function manageBattleIntro()
		-- @TODO Interrupt FIFO
		InputInjecter.addWaitToFifo(60)
		InputInjecter.mashToFifo('B', '', 500)
		-- @TODO Define Strategy
		local strategy = BattleManager.Strategies.Kill
		BotUtils.inBattleIntro = false
		return strategy
	end

	--- Gets the best move to use considering own Pokemon stats and foe Pokemon effectiveness
	--- @param ownData table data for our own Pokemon
	--- @param foeData table data for the foe Pokemon
	--- @return integer maxMoveIndex index of the move to use (from 1 to 4)
	--- @return table moveScores the table of the moves scores
	function self.getBestMove(ownData, foeData)
		local maxMoveScore = 0.0
		local maxMoveIndex = 1
		local moveScores = {}
		for i,move in ipairs(ownData.m.moves) do
			local moveScore = 0.0
			local moveId = tonumber(move.id)-1
			local moveParams = BattleManager.MoveParams[moveId]
			if move.power ~= nil and move.accuracy ~= nil and move.pp ~= "0" then
				local stab = ownData.p.types[1] == move.type or ownData.p.types[2] == move.type
				local power = tonumber(move.power)
				local acc = tonumber(move.accuracy)
				if move.accuracy == Constants.BLANKLINE then acc = 100.0 end
				if acc == 0.0 then acc = 100.0 end
				if power ~= nil and acc ~= nil then
					moveScore = power * (acc / 100.0)
					if stab then moveScore = moveScore * 1.5 end
					if move.category == MoveData.Categories.PHYSICAL then
						moveScore = moveScore * ownData.p["atk"]
					else
						moveScore = moveScore * ownData.p["spa"]
					end
					local effectiveness = PokemonData.getEffectiveness(foeData.p.id)
					for _,eff in ipairs(effectiveness[0]) do
						if eff == move.type then moveScore = moveScore * 0.0 end
					end
					for _,eff in ipairs(effectiveness[0.25]) do
						if eff == move.type then moveScore = moveScore * 0.25 end
					end
					for _,eff in ipairs(effectiveness[0.5]) do
						if eff == move.type then moveScore = moveScore * 0.5 end
					end
					for _,eff in ipairs(effectiveness[2]) do
						if eff == move.type then moveScore = moveScore * 2.0 end
					end
					for _,eff in ipairs(effectiveness[4]) do
						if eff == move.type then moveScore = moveScore * 4.0 end
					end
					-- Move Params
					if moveParams.statusInflicted ~= nil then
						local statusScore = 0.0
						local statusNb = 1
						for j,status in ipairs(moveParams.statusInflicted) do
							statusScore = statusScore + BattleManager.StatusScores[status]
							statusNb = j
						end
						statusScore = statusScore / statusNb
						if moveParams.statusInflictedChance ~= nil then
							statusScore = statusScore * moveParams.statusInflictedChance / 100.0
						end
						moveScore = moveScore + statusScore
					end
					if moveParams.waitBefore ~= nil and moveParams.waitBefore then
						moveScore = moveScore / 2.0
					end
				end
				if moveId ~= nil and BattleManager.MoveParams[math.floor(moveId)].forbidden ~= nil
					and BattleManager.MoveParams[math.floor(moveId)].forbidden == true then
					moveScore = moveScore * -1 - 1
				end
			end
			--print("MOVE " .. tostring(i) .. ": " .. tostring(moveScore))
			moveScores[#moveScores+1] = moveScore
			if moveScore > maxMoveScore then
				maxMoveScore = moveScore
				maxMoveIndex = i
			end
		end
		-- If only forbidden moves, just take the best forbidden move!
		if maxMoveScore < 0 then
			for i,score in ipairs(moveScores) do
				moveScores[i] = score * -1
			end
		end
		return maxMoveIndex, moveScores
	end

	--- Manage new battle turn
	--- @param strategy string from BattleManager.Strategies
	local function manageNewTurn(strategy)
		InputInjecter.addWaitToFifo(60)
		BotUtils.currentTurn = Battle.turnCount
		print("TURN: " .. tostring(BotUtils.currentTurn))
		-- Get best action for defined Strategy
		if strategy == BattleManager.Strategies.Kill then
			local action = BattleManager.Actions.Attack
			-- Inject inputs to do action
			InputInjecter.addWaitToFifo(10)
			if action == BattleManager.Actions.Bag or action == BattleManager.Actions.Run then
				InputInjecter.addToFifo('R', 5)
			else
				InputInjecter.addToFifo('L', 5)
			end
			if action == BattleManager.Actions.Switch or action == BattleManager.Actions.Run then
				InputInjecter.addToFifo('D', 5)
			else
				InputInjecter.addToFifo('U', 5)
			end
			InputInjecter.addToFifo('A', 5)
			if action == BattleManager.Actions.Attack then
				-- Choose best move based on move info and stats
				local maxMoveIndex,_ = self.getBestMove(DataHelper.buildTrackerScreenDisplay(true), DataHelper.buildTrackerScreenDisplay(false))
				print("Using move " .. tostring(maxMoveIndex))
				InputInjecter.addWaitToFifo(10)
				if maxMoveIndex % 2 == 0 then
					InputInjecter.addToFifo('R', 5)
				else
					InputInjecter.addToFifo('L', 5)
				end
				if maxMoveIndex > 2 then
					InputInjecter.addToFifo('D', 5)
				else
					InputInjecter.addToFifo('U', 5)
				end
				InputInjecter.addToFifo('A', 5)
			end
		end
	end

	--- Manage any battle
	local function manageBattle()
		-- Battle Intro
		local strategy = BattleManager.Strategies.Kill
		if BotUtils.inBattleIntro then
			strategy = manageBattleIntro()
		end
		-- Manage new turn
		if Battle.turnCount > BotUtils.currentTurn then
			manageNewTurn(strategy)
		end
		-- Battle Outro
		if Battle.battleMsg == 137209795 and BotUtils.battleFinished == false then
			InputInjecter.mashToFifo('A', 'B', 300)
			BotUtils.battleFinished = true
		end
	end

	--------------------------------------
	-- INTERNAL TRACKER FUNCTIONS BELOW
	-- Add any number of these below functions to your extension that you want to use.
	-- If you don't need a function, don't add it at all; leave ommitted for faster code execution.
	--------------------------------------

	-- Executed when the user clicks the "Options" button while viewing the extension details within the Tracker's UI
	-- Remove this function if you choose not to include a way for the user to configure options for your extension
	-- NOTE: You'll need to implement a way to save & load changes for your extension options, similar to Tracker's Settings.ini file
	function self.configureOptions()
		-- [ADD CODE HERE]
	end

	-- Executed when the user clicks the "Check for Updates" button while viewing the extension details within the Tracker's UI
	-- Returns [true, downloadUrl] if an update is available (downloadUrl auto opens in browser for user); otherwise returns [false, downloadUrl]
	-- Remove this function if you choose not to implement a version update check for your extension
	function self.checkForUpdates()
		-- Update the pattern below to match your version. You can check what this looks like by visiting the latest release url on your repo
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github or "")
		local downloadUrl = string.format("%s/releases/latest", self.url or "")
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
	function self.startup()
        InputInjecter.initialize()
        -- Intro sequence flags
        BotUtils.introToDo = true
        BotUtils.introFrameCount = 1
        BotUtils.introToStarterToDo = true
        BotUtils.introToStarterFrameCount = 1
        BotUtils.starterId = nil
        -- Battle flags
        BotUtils.battleFinished = false
        BotUtils.inBattleIntro = true
        BotUtils.currentTurn = -1
	end

	-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		-- [ADD CODE HERE]
	end

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate()
        --
	end

	-- Executed once every 30 frames, after any battle related data from game memory is read in
	function self.afterBattleDataUpdate()

	end

	-- Executed once every 30 frames or after any redraw event is scheduled (i.e. most button presses)
	function self.afterRedraw()
		-- [ADD CODE HERE]
	end

	-- Executed before a button's onClick() is processed, and only once per click per button
	-- Param: button: the button object being clicked
	function self.onButtonClicked(button)
		-- [ADD CODE HERE]
	end

	-- Executed after a new battle begins (wild or trainer), and only once per battle
	function self.afterBattleBegins()
        print("Battle begins")

	end

	-- Executed after a battle ends, and only once per battle
	function self.afterBattleEnds()
        print("Battle ends")
		BotUtils.inBattleIntro = false
        BotUtils.currentTurn = -1
        BotUtils.battleFinished = false
	end

	-- [Bizhawk only] Executed each frame (60 frames per second)
	-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
	function self.inputCheckBizhawk()
		-- Uncomment to use, otherwise leave commented out
			-- local mouseInput = input.getmouse() -- lowercase 'input' pulls directly from Bizhawk API
			-- local joypadButtons = Input.getJoypadInputFormatted() -- uppercase 'Input' uses Tracker formatted input
		-- [ADD CODE HERE]
	end

	-- [MGBA only] Executed each frame (60 frames per second)
	-- CAUTION: Avoid unnecessary calculations here, as this can easily affect performance.
	function self.inputCheckMGBA()
		-- Uncomment to use, otherwise leave commented out
			-- local joypadButtons = Input.getJoypadInputFormatted()
		-- [ADD CODE HERE]
	end

	-- Executed each frame of the game loop, after most data from game memory is read in but before any natural redraw events occur
	-- CAUTION: Avoid code here if possible, as this can easily affect performance. Most Tracker updates occur at 30-frame intervals, some at 10-frame.
	function self.afterEachFrame()
		-- INTRO (static)
        manageIntro()
        -- BATTLE
        if Battle.inActiveBattle() then
            manageBattle()
        end
        -- Inject input on the next frame
		local input = InputInjecter.INPUT_FIFO:pop()
		print(input)
        InputInjecter.injectInput(input)
	end

	return self
end
return IronBot
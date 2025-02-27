TrackerAPI = {}

-----------------------------------
---  I. INTRODUCTION  -------------
-----------------------------------
--[[
The TrackerAPI lua file offers convenient access to numerous Tracker endpoints.
You can retrieve data about the game, tracked notes, and/or change data.
While this isn't nearly an exhaustive list of what the Tracker can do, it's a start.

Other useful internal Tracker data and functions can be found in:
- /data/ folder - static game data, such as info about a: Pokémon, Move, Ability, Route, Trainer, etc
- /screens/ folder - all the various Tracker screens that are displayed on the emulator
- Tracker.lua - access to all tracked notes/info taken while playing the current game
- English.lua - most text strings used by the Tracker
- Utils.lua - helpful functions
- Constants.lua - helpful values
- GameSettings.lua - known memory address used to read data from the game rom
]]

-----------------------------------
---  II. GAME DATA LOOKUP  --------
-----------------------------------

---Returns a `Program.DefaultPokemon` table of Pokemon data from the game
---@param partySlotNum? number Optional, the party slot number of the Pokemon on the player's team; default: first active pokemon
---@return table|nil pokemon
function TrackerAPI.getPlayerPokemon(partySlotNum)
	if not partySlotNum and Battle.inActiveBattle() then
		partySlotNum = Battle.Combatants.LeftOwn
	end
	return Tracker.getPokemon(partySlotNum or 1, true)
end

---Returns a `Program.DefaultPokemon` table of Pokemon data from the game
---@param partySlotNum? number Optional, the party slot number of the Pokemon on the enemy team; default: first active pokemon
---@return table|nil pokemon
function TrackerAPI.getEnemyPokemon(partySlotNum)
	if not partySlotNum and Battle.inActiveBattle() then
		partySlotNum = Battle.Combatants.LeftOther
	end
	return Tracker.getPokemon(partySlotNum or 1, false)
end

---Returns a `Program.DefaultPokemon` list of Pokemon data from the game, of the 2-4 pokemon active in the current battle
---@return table battlers [1] = LeftOwn, [2] = LeftOther, [3] = RightOwn, [4] = RightOther
function TrackerAPI.getActiveBattlePokemon()
	local battlers = {}
	if not Battle.inActiveBattle() then
		return battlers
	end
	battlers[1] = TrackerAPI.getPlayerPokemon(Battle.Combatants.LeftOwn)
	battlers[2] = TrackerAPI.getEnemyPokemon(Battle.Combatants.LeftOther)
	if Battle.numBattlers > 2 then
		battlers[3] = TrackerAPI.getPlayerPokemon(Battle.Combatants.RightOwn)
		battlers[4] = TrackerAPI.getEnemyPokemon(Battle.Combatants.RightOther)
	end
	return battlers
end

---For a given Pokemon object, returns its abilityId (alternatively, use `PokemonData.getAbilityId(p, n)`)
---@param pokemon table A data object templated like `Program.DefaultPokemon`
---@return number abilityId 0 if pokemon or ability is not valid
function TrackerAPI.getAbilityIdOfPokemon(pokemon)
	pokemon = pokemon or {}
	return PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
end

---Returns a list of the two types of a specific Pokémon in battle, dynamically checked to cover Color Change, Transform, etc
---@param isPlayersMon? boolean Optional, true if checking the player's Pokémon, false to check enemy's; default=true
---@param isOnLeft? boolean Optional, true if checking the "left" Pokémon in doubles (perspective reversed for enemy), false to check right; default=true
---@return table typeList Always a list of two types; second type is the same as the first for mono-typed Pokémon
function TrackerAPI.getPokemonTypes(isPlayersMon, isOnLeft)
	if not TrackerAPI.inActiveBattle() then
		local pokemon = Tracker.getViewedPokemon() or {}
		return pokemon.types or { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY }
	end
	return Program.getPokemonTypes(isPlayersMon ~= false, isOnLeft ~= false)
end

---Returns true if the Pokémon in slot # is shiny (for the player's team or the enemy)
---@param partySlotNum? number Default = 1st active pokemon
---@param isEnemy? boolean Default = false
---@return boolean
function TrackerAPI.isShiny(partySlotNum, isEnemy)
	if not partySlotNum and Battle.inActiveBattle() then
		partySlotNum = isEnemy ~= true and Battle.Combatants.LeftOwn or Battle.Combatants.LeftOther
	end
	local pokemon = Tracker.getPokemon(partySlotNum or 1, isEnemy ~= true) or {}
	return (pokemon.isShiny == true)
end

---Returns true if the Pokémon in slot # has PokéRus (for the player's team or the enemy)
---@param partySlotNum? number Default = 1st active pokemon
---@param isEnemy? boolean Default = false
---@return boolean
function TrackerAPI.hasPokerus(partySlotNum, isEnemy)
	if not partySlotNum and Battle.inActiveBattle() then
		partySlotNum = isEnemy ~= true and Battle.Combatants.LeftOwn or Battle.Combatants.LeftOther
	end
	local pokemon = Tracker.getPokemon(partySlotNum or 1, isEnemy ~= true) or {}
	return (pokemon.hasPokerus == true)
end

---Returns the map id number of the current location of the player's character. When not in the game, the value is 0 (intro screen).
---@return number mapId
function TrackerAPI.getMapId()
	return Program.GameData.mapId or 0
end

---Returns a table with info on quantities of items in the player's bag; refer to `Program.GameData.Items`
---The table contains subtables, each holding a category of items, such as HPHeals and StatusHeals
---@return table bagitems -- A table containg subtables of item data
function TrackerAPI.getBagItems()
	return Program.GameData.Items
end

---Returns the moveId associated with a specific TM or HM number (i.e., TM 28 is moveID=91, "Dig")
---@param tmhmNumber number The TM/HM number to use for move lookup
---@param isHM? boolean Optional, true if the number param is an HM; default: false
---@return number moveId The moveId corresponding to the tm/hm number
function TrackerAPI.getMoveIdFromTMHMNumber(tmhmNumber, isHM)
	return Program.getMoveIdFromTMHMNumber(tmhmNumber, isHM)
end

---Returns true if the player is in an active battle and battle game data is available to be used
---@return boolean
function TrackerAPI.inActiveBattle()
	return Battle.inActiveBattle()
end

---Returns the `trainerId` of the opposing trainer being fought in battle
---@return number trainerId
function TrackerAPI.getOpponentTrainerId()
	return Memory.readword(GameSettings.gTrainerBattleOpponent_A)
end

---Returns a `Program.GameTrainer` table of Trainer data from the game
---@param trainerId? number Optional, the trainerId to lookup; default: the current trainer being battled, if any
---@return table|nil trainer
function TrackerAPI.getTrainerGameData(trainerId)
	trainerId = trainerId or TrackerAPI.getOpponentTrainerId()
	if trainerId <= 0 then
		return nil
	end
	local trainer = Program.readTrainerGameData(trainerId) or {}
	return trainer
end

---Returns a table list of `Program.GameTrainer` Trainer data objects from the game
---@param routeId? number Optional, the routeId to lookup; default: the current route the player is on, if any
---@return table|nil trainerList
function TrackerAPI.getTrainersOnRoute(routeId)
	routeId = routeId or TrackerAPI.getMapId()
	local trainerList = {}
	if not RouteData.hasRoute(routeId) then
		return trainerList
	end
	-- Filter out unused trainers, such as duplicate rivals
	local actualTrainers = {}
	for _, trainerId in pairs(RouteData.Info[routeId].trainers or {}) do
		if TrainerData.shouldUseTrainer(trainerId) then
			table.insert(actualTrainers, trainerId)
		end
	end
	-- Get game data for each trainer known on the route
	for _, trainerId in pairs(actualTrainers) do
		local trainer = TrackerAPI.getTrainerGameData(trainerId)
		table.insert(trainerList, trainer)
	end
	return trainerList
end

---Returns the outcome status of the last battle (or current battle)
---@return number outcome Returns one of: 0 = In battle, 1 = Player won, 2 = Player lost, 4 = Fled, 7 = Caught
function TrackerAPI.getBattleOutcome()
	return Memory.readbyte(GameSettings.gBattleOutcome)
end

---Returns true if the trainer has been defeated by the player; false otherwise
---@param trainerId number
---@return boolean isDefeated
function TrackerAPI.hasDefeatedTrainer(trainerId)
	return Program.hasDefeatedTrainer(trainerId)
end

---Returns a list of which badges have been are obtained (value=true).
---@return table badgeList Each item in list is true if badge obtained, false otherwise {key=badgeIndex, val=isObtained}
function TrackerAPI.getBadgeList()
	local badgeList = {}
	for i = 1, 8, 1 do -- Max of 8 badges per game
		local badgeButton = TrackerScreen.Buttons["badge" .. i] or {}
		local badgeObtained = (badgeButton.badgeState or 0) ~= 0
		badgeList[i] = badgeObtained
	end
	return badgeList
end

---Returns true if the player has started the game (their character can move around); false otherwise, still at title screen / intro
---@return boolean
function TrackerAPI.hasGameStarted()
	return Program.isValidMapLocation()
end

-----------------------------------
---  III. INFO LOOKUP  ------------
-----------------------------------

---Returns a copy of an information object from the table `PokemonData.Pokemon`
---@param pokemonID number
---@return table|nil pokemonInfo
function TrackerAPI.getPokemonInfo(pokemonID)
	if not PokemonData.isValid(pokemonID) then return nil end
	return FileManager.copyTable(PokemonData.Pokemon[pokemonID] or {})
end

---Returns a copy of an information object from the table `MoveData.Moves`
---@param moveId number
---@return table|nil moveInfo
function TrackerAPI.getMoveInfo(moveId)
	if not MoveData.isValid(moveId) then return nil end
	return FileManager.copyTable(MoveData.Moves[moveId] or {})
end

---Returns a copy of an information object from the table `AbilityData.Abilities`
---@param abilityId number
---@return table|nil abilityInfo
function TrackerAPI.getAbilityInfo(abilityId)
	if not AbilityData.isValid(abilityId) then return nil end
	return FileManager.copyTable(AbilityData.Abilities[abilityId] or {})
end

---Returns a copy of an information object from the table `RouteData.Info`
---@param routeId number
---@return table|nil routeInfo
function TrackerAPI.getRouteInfo(routeId)
	if not RouteData.hasRoute(routeId) then return nil end
	return FileManager.copyTable(RouteData.Info[routeId] or {})
end

---Returns a copy of an information object from the table `TrainerData.Trainers`
---@param trainerId number
---@return table|nil trainerInfo If no trainer found, returns `TrainerData.BlankTrainer`
function TrackerAPI.getTrainerInfo(trainerId)
	return FileManager.copyTable(TrainerData.getTrainerInfo(trainerId))
end

---Returns a copy of a list of gym TM numbers for the current game, in order of gym number; or a single gym TM number. From `TrainerData.GymTMs`
---@param gymNumber? number Optional, if provided, returns a single TM number for that gym; table otherwise
---@return table|number|nil tmNumOrList
function TrackerAPI.getGymTMs(gymNumber)
	if type(gymNumber) == "number" then
		local gymInfo = TrainerData.GymTMs[gymNumber] or {}
		return gymInfo.number
	end
	local tmList = {}
	for _, gymInfo in ipairs(TrainerData.GymTMs or {}) do
		table.insert(tmList, gymInfo.number)
	end
	return tmList
end

---Returns the name of an item
---@param itemId number
---@param ignoreLanguage? boolean If true, returns the item's English name, ignoring the Tracker's language setting
---@return string|nil name
function TrackerAPI.getItemName(itemId, ignoreLanguage)
	local resource = (ignoreLanguage and Resources) or Resources.Default
	return resource.Game.ItemNames[itemId]
end

-----------------------------------
---  IV. TRACKER CONFIGURATION  ---
-----------------------------------

---Changes the Tracker screen that is currently being viewed to something else; Refer to: /ironmon_tracker/screens/ folder
---@param newScreen table The name of the screen; i.e. CoverageCalcScreen or TypeDefensesScreen
function TrackerAPI.changeScreen(newScreen)
	if type(newScreen) == "table" then
		Program.changeScreenView(newScreen)
	end
end

---Returns the Tracker option setting for a specified option `key`; full list available in `Options` table
---@param key string
---@return any value Usually a boolean or string
function TrackerAPI.getOption(key)
	-- Checks through categorized options, such as CONTROLS, FILES, or PATHS
	for _, optionCategory in pairs(Options) do
		if type(optionCategory) == "table" and optionCategory[key] ~= nil then
			return optionCategory[key]
		end
	end
	return Options[key]
end

---Changes a Tracker option setting and saves it. Tracket settings are saved (persist) in the Settings.ini file
---Create your own settings for an extension by using: `TrackerAPI.saveExtensionSetting()`
---@param key string
---@param value any Usually a boolean or a string
---@return boolean success true if an existing setting was changed, false if no setting was found
function TrackerAPI.setOption(key, value)
	-- Checks through categorized options, such as CONTROLS, FILES, or PATHS
	for _, optionCategory in pairs(Options) do
		if type(optionCategory) == "table" and optionCategory[key] ~= nil then
			optionCategory[key] = value
			return true
		end
	end
	if Options[key] ~= nil then
		Options.addUpdateSetting(key, value)
		return true
	end
	return false
end

---Returns the current Tracker Theme (or specified Theme) as a Theme code (exported string)
---@param themeName? string Optional, name of the theme to retrieve a code for; default: current theme
---@return string themeCode
function TrackerAPI.getTheme(themeName)
	if themeName then
		for _, theme in ipairs(Theme.Presets or {}) do
			if theme:getText() == themeName then
				return theme.code or ""
			end
		end
		return ""
	end
	return Theme.exportThemeToText()
end

---Changes the Tracker's UI Theme using a `themeCode` and/or `themeName`; providing both will name the new Theme
---@param themeCode? string Optional, a valid theme code, refer to `Theme.resetPresets()` for an example
---@param themeName? string Optional, a valid theme name
---@param saveToLibrary? boolean Optional, if true, will save the theme in the ThemeLibrary for future use
---@return boolean success True if successfully set the theme; false otherwise
function TrackerAPI.setTheme(themeCode, themeName, saveToLibrary)
	-- Must provide at least one of: code or name
	if not themeCode and not themeName then return false end
	themeName = themeName or Utils.newGUID()
	if not themeCode and Theme.Presets then
		for _, theme in ipairs(Theme.Presets or {}) do
			if theme:getText() == themeName then
				themeCode = theme.code
				break
			end
		end
	end
	if not Theme.isValidThemeCode(themeCode) then
		return false
	end
	local success = Theme.importThemeFromText(themeCode, true)
	if success then
		Program.redraw(true)
		if saveToLibrary then
			success = Theme.saveThemeToLibrary(themeName, themeCode)
		end
	end
	return success
end

---Returns the current Tracker Language (or a specified language) as a Resource table
---@param language? string Optional, language key, such as "ENGLISH" or "FRENCH" from `Resources.Languages`
---@return table resourceObject
function TrackerAPI.getLanguage(language)
	if type(language) == "string" then
		return Resources[language:upper()]
	end
	return Resources.currentLanguage
end

---Changes the Tracker Language setting to a specified language
---@param language string|table ENGLISH, SPANISH, GERMAN, FRENCH, ITALIAN, or a Resources.Language table
function TrackerAPI.setLanguage(language)
	if type(language) == "string" then
		Resources.changeLanguageSetting(Resources[language:upper()], true)
	elseif type(language) == "table" then
		Resources.changeLanguageSetting(language, true)
	end
end

---Imports all necessary ROM addresses and values from the a JSON file for the loaded game
---@param filepath string A custom JSON file, usually for rom hacks; refer to GameSettings.lua for json file formatting
---@return boolean success
function TrackerAPI.loadGameSettingsFromJson(filepath)
	return GameSettings.importAddressesFromJson(filepath)
end

---Imports all necessary Tracker Overrides (various hard-coded values) from the a JSON file for the loaded game
---@param filepath string A custom JSON file, usually for rom hacks; refer to GameSettings.lua for json file formatting
---@return boolean success
function TrackerAPI.loadTrackerOverridesFromJson(filepath)
	return GameSettings.importTrackerOverridesFromJson(filepath)
end

-----------------------------------
---  V. EXTENSIONS  ---------------
-----------------------------------

---Checks if a Tracker Extension is enabled, if it exists
---@param extensionName string The name/key of the extension calling this function; use only alphanumeric characters, no spaces
---@return boolean isEnabled
function TrackerAPI.isExtensionEnabled(extensionName)
	local ext = CustomCode.ExtensionLibrary[extensionName or false] or {}
	return ext.isEnabled or false
end

---Gets an extension object, if one exists
---@param extensionName string The name/key of the extension calling this function; use only alphanumeric characters, no spaces
---@return table? extension
function TrackerAPI.getExtensionSelf(extensionName)
	local ext = CustomCode.ExtensionLibrary[extensionName or false] or {}
	return ext.selfObject
end

---Saves a setting to the user's Settings.ini file so that it can be remembered after the emulator shuts down and reopens.
---@param extensionName string The name/key of the extension calling this function; use only alphanumeric characters, no spaces
---@param key string The name of the setting. Combined with extensionName (ext_key) when saved in Settings file
---@param value string|number|boolean The value that is being saved; allowed types: number, boolean, string
function TrackerAPI.saveExtensionSetting(extensionName, key, value)
	if extensionName == nil or key == nil or value == nil then return end

	if type(value) == "string" then
		value = Utils.encodeDecodeForSettingsIni(value, true)
	end

	local encodedName = string.gsub(extensionName, " ", "_")
	local encodedKey = string.gsub(key, " ", "_")
	local settingsKey = string.format("%s_%s", encodedName, encodedKey)
	Main.SetMetaSetting("extconfig", settingsKey, value)
	Main.SaveSettings(true)
end

---Gets a setting from the user's Settings.ini file
---@param extensionName string The name/key of the extension calling this function; use only alphanumeric characters, no spaces
---@param key string The name of the setting. Combined with extensionName (ext_key) when saved in Settings file
---@return string|number|boolean? value Returns the value that was saved, or returns nil if it doesn't exist.
function TrackerAPI.getExtensionSetting(extensionName, key)
	if extensionName == nil or key == nil or Main.MetaSettings.extconfig == nil then return nil end

	local encodedName = string.gsub(extensionName, " ", "_")
	local encodedKey = string.gsub(key, " ", "_")
	local settingsKey = string.format("%s_%s", encodedName, encodedKey)
	local value = Main.MetaSettings.extconfig[settingsKey]
	return tonumber(value or "") or value
end

---Automatically downloads and installs an extension from its latest Github release; This will not enable the extension
---@param githubRepoUrl string The repo url where their extension is hosted; Example: https://github.com/Username/ExtensionName
---@param folderNamesToExclude? table Optional, list of downloaded folder names to remove from the release before copying over; default, refer to: CustomCode.DefaultFoldersToExclude
---@param fileNamesToExclude? table Optional, list of downloaded file names to remove from the release before copying over; default, refer to: CustomCode.DefaultFilenamesToExclude
---@param branchName? string Optional, defaults to the `main` branch: CustomCode.DefaultBranch
---@return boolean success
function TrackerAPI.installNewExtension(githubRepoUrl, folderNamesToExclude, fileNamesToExclude, branchName)
	if Utils.isNilOrEmpty(githubRepoUrl) then
		return false
	end

	-- Perform the download and file update
	local success = CustomCode.downloadAndInstallExtensionFiles(githubRepoUrl, folderNamesToExclude, fileNamesToExclude, branchName)
	if not success then
		return false
	end

	-- Finally, "install it" by making it visible in the loaded extensions list
	Utils.tempDisableBizhawkSound()
	CustomCode.refreshExtensionList()
	if Program.currentScreen == CustomExtensionsScreen then
		CustomExtensionsScreen.buildOutPagedButtons()
		Program.redraw(true)
	end
	Utils.tempEnableBizhawkSound()

	return true
end

---Automatically downloads and updates an extension to its latest Github release, then reloads it into the Tracker
---@param extensionName string The name/key of the existing extension calling this function; use only alphanumeric characters, no spaces
---@param folderNamesToExclude? table Optional, list of downloaded folder names to remove from the release before copying over; default, refer to: CustomCode.DefaultFoldersToExclude
---@param fileNamesToExclude? table Optional, list of downloaded file names to remove from the release before copying over; default, refer to: CustomCode.DefaultFilenamesToExclude
---@param branchName? string Optional, defaults to the `main` branch: CustomCode.DefaultBranch
---@return boolean success
function TrackerAPI.updateExtension(extensionName, folderNamesToExclude, fileNamesToExclude, branchName)
	if Utils.isNilOrEmpty(extensionName) then
		return false
	end
	local extension = CustomCode.ExtensionLibrary[extensionName]
	if not extension then
		return false
	end

	-- A url or github repo is required as a source for the extension release update download
	local githubRepoUrl
	if not Utils.isNilOrEmpty(extension.selfObject.url) then
		githubRepoUrl = extension.selfObject.url
	elseif not Utils.isNilOrEmpty(extension.selfObject.github) then
		githubRepoUrl = string.format("https://github.com/%s", extension.selfObject.github)
	end
	if not githubRepoUrl then
		return false
	end

	-- Perform the download and file update
	local success = CustomCode.downloadAndInstallExtensionFiles(githubRepoUrl, folderNamesToExclude, fileNamesToExclude, branchName)
	if not success then
		return false
	end

	CustomCode.reloadExtension(extension.key)

	return true
end
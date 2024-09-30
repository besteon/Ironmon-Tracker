TrackerAPI = {}

-----------------------------------
---  I. GAME DATA LOOKUP  ---------
-----------------------------------

---Returns a `Program.DefaultPokemon` table of Pokemon data from the game
---@param partySlotNum? number Optional, the party slot number of the Pokemon on the player's team; default: 1
---@return table|nil pokemon
function TrackerAPI.getPlayerPokemon(partySlotNum)
	return Tracker.getPokemon(partySlotNum or 1, true)
end

---Returns a `Program.DefaultPokemon` table of Pokemon data from the game
---@param partySlotNum? number Optional, the party slot number of the Pokemon on the enemy team; default: 1
---@return table|nil pokemon
function TrackerAPI.getEnemyPokemon(partySlotNum)
	return Tracker.getPokemon(partySlotNum or 1, false)
end

---For a given Pokemon object, returns its abilityId (alternatively, use `PokemonData.getAbilityId(p, n)`)
---@param pokemon table A data object templated like `Program.DefaultPokemon`
---@return number abilityId 0 if pokemon or ability is not valid
function TrackerAPI.getAbilityIdOfPokemon(pokemon)
	pokemon = pokemon or {}
	return PokemonData.getAbilityId(pokemon.pokemonID, pokemon.abilityNum)
end

---Returns true if the Pokémon in slot # is shiny (for the player's team or the enemy)
---@param partySlotNum? number Default = 1st
---@param isEnemy? boolean Default = true
---@return boolean
function TrackerAPI.isShiny(partySlotNum, isEnemy)
	local pokemon = Tracker.getPokemon(partySlotNum or 1, isEnemy ~= false) or {}
	return (pokemon.isShiny == true)
end

---Returns true if the Pokémon in slot # has PokéRus (for the player's team or the enemy)
---@param partySlotNum? number Default = 1st
---@param isEnemy? boolean Default = true
---@return boolean
function TrackerAPI.hasPokerus(partySlotNum, isEnemy)
	local pokemon = Tracker.getPokemon(partySlotNum or 1, isEnemy ~= false) or {}
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

---Returns the `trainerId` of the opposing trainer being fought in battle
---@return number trainerId
function TrackerAPI.getOpponentTrainerId()
	return Memory.readword(GameSettings.gTrainerBattleOpponent_A)
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

-----------------------------------
---  II. INFO LOOKUP  -------------
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

---Returns the name of an item
---@param itemId number
---@param ignoreLanguage? boolean If true, returns the item's English name, ignoring the Tracker's language setting
---@return string|nil name
function TrackerAPI.getItemName(itemId, ignoreLanguage)
	local resource = (ignoreLanguage and Resources) or Resources.Default
	return resource.Game.ItemNames[itemId]
end

-----------------------------------
---  III. TRACKER CONFIGURATION  --
-----------------------------------

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

-----------------------------------
---  IV. EXTENSIONS  --------------
-----------------------------------

---Checks if a Tracker Extension is enabled, if it exists
---@param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
---@return boolean isEnabled
function TrackerAPI.isExtensionEnabled(extensionName)
	local ext = CustomCode.ExtensionLibrary[extensionName or false] or {}
	return ext.isEnabled or false
end

---Gets an extension object, if one exists
---@param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
---@return table? extension
function TrackerAPI.getExtensionSelf(extensionName)
	local ext = CustomCode.ExtensionLibrary[extensionName or false] or {}
	return ext.selfObject
end

---Saves a setting to the user's Settings.ini file so that it can be remembered after the emulator shuts down and reopens.
---@param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
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
---@param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
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
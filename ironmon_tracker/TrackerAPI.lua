TrackerAPI = {}

--- Returns the map id number of the current location of the player's character. When not in the game, the value is 0 (intro screen).
--- @return number mapId
function TrackerAPI.getMapId()
	return Program.GameData.mapId or 0
end

--- Checks if a Tracker Extension is enabled, if it exists
--- @param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
--- @return boolean isEnabled
function TrackerAPI.isExtensionEnabled(extensionName)
	local ext = CustomCode.ExtensionLibrary[extensionName or false] or {}
	return ext.isEnabled or false
end

--- Gets an extension object, if one exists
--- @param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
--- @return table? extension
function TrackerAPI.getExtensionSelf(extensionName)
	local ext = CustomCode.ExtensionLibrary[extensionName or false] or {}
	return ext.selfObject
end

--- Saves a setting to the user's Settings.ini file so that it can be remembered after the emulator shuts down and reopens.
--- @param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
--- @param key string The name of the setting. Combined with extensionName (ext_key) when saved in Settings file
--- @param value string|number|boolean The value that is being saved; allowed types: number, boolean, string
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

--- Gets a setting from the user's Settings.ini file
--- @param extensionName string The name of the extension calling this function; use only alphanumeric characters, no spaces
--- @param key string The name of the setting. Combined with extensionName (ext_key) when saved in Settings file
--- @return string|number|boolean? value Returns the value that was saved, or returns nil if it doesn't exist.
function TrackerAPI.getExtensionSetting(extensionName, key)
	if extensionName == nil or key == nil or Main.MetaSettings.extconfig == nil then return nil end

	local encodedName = string.gsub(extensionName, " ", "_")
	local encodedKey = string.gsub(key, " ", "_")
	local settingsKey = string.format("%s_%s", encodedName, encodedKey)
	local value = Main.MetaSettings.extconfig[settingsKey]
	return tonumber(value or "") or value
end
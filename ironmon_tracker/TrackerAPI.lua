TrackerAPI = {}

-- Returns the map id number of the current location of the player's character. When not in the game, the value is 0 (intro screen).
function TrackerAPI.getMapId()
	return Program.GameData.mapId
end

-- Saves a setting to the user's Settings.ini file so that it can be remembered after the emulator shuts down and reopens.
-- extensionName: the name of the extension calling this function; use only alphanumeric characters, no spaces
-- key: is the name of the setting, which gets prepended by the extensionName that is calling it; use only alphanumeric characters, no spaces
-- value: the value that is being saved; allowed types: number, boolean, string
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

-- Gets a setting from the user's Settings.ini file
-- extensionName: the name of the extension calling this function; use only alphanumeric characters, no spaces
-- key: is the name of the setting, which gets prepended by the extensionName that is calling it; use only alphanumeric characters, no spaces
function TrackerAPI.getExtensionSetting(extensionName, key)
	if extensionName == nil or key == nil or Main.MetaSettings.extconfig == nil then return nil end

	local encodedName = string.gsub(extensionName, " ", "_")
	local encodedKey = string.gsub(key, " ", "_")
	local settingsKey = string.format("%s_%s", encodedName, encodedKey)
	return Main.MetaSettings.extconfig[settingsKey]
end
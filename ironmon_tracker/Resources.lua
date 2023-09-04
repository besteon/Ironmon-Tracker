Resources = {}

Resources.Languages = {
	ENGLISH = {
		Key = "ENGLISH",
		DisplayName = "English",
		FileName = "English.lua",
		Ordinal = 1,
	},
	SPANISH = {
		Key = "SPANISH",
		DisplayName = "Español",
		FileName = "Spanish.lua",
		Ordinal = 2,
	},
	GERMAN = {
		Key = "GERMAN",
		DisplayName = "Deutsch",
		FileName = "German.lua",
		Ordinal = 3,
	},
	FRENCH = {
		Key = "FRENCH",
		DisplayName = "Français",
		FileName = "French.lua",
		Ordinal = 4,
	},
	ITALIAN = {
		Key = "ITALIAN",
		DisplayName = "Italiano",
		FileName = "Italian.lua",
		Ordinal = 5,
	},
	CHINESE = {
		Key = "CHINESE",
		DisplayName = "中文",
		FileName = "Chinese.lua",
		Ordinal = 6,
		RequiresUTF16 = true,
		ExcludeFromSettings = true,  -- Currently not yet included or supported.
	},
	JAPANESE = {
		Key = "JAPANESE",
		DisplayName = "日本語",
		FileName = "Japanese.lua",
		Ordinal = 7,
		RequiresUTF16 = true,
		ExcludeFromSettings = true,  -- Currently not supported.
	},
}

-- Holds all current resources data used by all Tracker assets; data is categorized
Resources.Data = {}

-- Define metatables
local mt = {}
setmetatable(Resources, mt)
mt.__index = Resources.Data

Resources.Default = {
	Language = Resources.Languages.ENGLISH,
	Data = {}, -- Used to fill in gaps in other language resource data
}

function Resources.initialize()
	if Resources.hasInitialized then return end

	Resources.defineResourceCallbacks()
	Resources.sanitizeTable(Resources.Languages)

	-- Load in default language data first, to fill in gaps in other language data
	Resources.loadAndApplyLanguage(Resources.Default.Language)
	FileManager.copyTable(Resources.Data, Resources.Default.Data)

	-- Define metatables
	local default_mt = {}
	setmetatable(Resources.Default, default_mt)
	default_mt.__index = Resources.Default.Data

	-- Then load in the language chosen by the user's settings
	if Options["Autodetect language from game"] then
		Resources.autoDetectForeignLanguage()
	else
		local userLanguageKey = Options["Language"] or Resources.Default.Language.Key
		Resources.loadAndApplyLanguage(Resources.Languages[userLanguageKey])
	end

	Resources.hasInitialized = true
end

-- Attempts to automatically change the language based on the game being played.
function Resources.autoDetectForeignLanguage()
	if not Options["Autodetect language from game"] then
		return
	end

	local languageKey = (GameSettings.language or ""):upper()
	local language = Resources.Languages[languageKey]

	if language == nil or language.ExcludeFromSettings then
		return
	end

	Resources.changeLanguageSetting(language, true)
end

function Resources.changeLanguageSetting(language, forced)
	local success = Resources.loadAndApplyLanguage(language)
	if success or forced then
		Resources.currentLanguage = language
		Options["Language"] = language.Key
		Main.SaveSettings(true)
	end
end

-- Loads resources for the specified language into all of the Tracker's assets
function Resources.loadAndApplyLanguage(language)
	if language == nil or language == Resources.currentLanguage or not Resources.Languages[language.Key] then
		return false
	end

	-- Some languages are supported on some emulators
	if language.RequiresUTF16 and not Main.supportsSpecialChars then
		Main.DisplayError(string.format("UTF-16 characters not supported on this emulator version (%s).", Main.emulator))
		return false
	end

	local langFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
	local langFilePath = langFolder .. language.FileName
	if not FileManager.fileExists(langFilePath) then
		return false
	end

	-- Prepopulate with default data. Newly loaded data (if it exists) replaces each key
	FileManager.copyTable(Resources.Default.Data, Resources.Data)

	-- Load data into Resources.Data
	dofile(langFilePath)

	Resources.currentLanguage = language
	Resources.sanitizeTable(Resources.Data)
	FileManager.executeEachFile("updateResources")
	collectgarbage()

	return true
end

-- Establishes global functions used for loading resource data from resource files
function Resources.defineResourceCallbacks()
	-- Sub function used by other resource load functions
	local function dataLoadHelper(asset, data)
		if Resources.Data[asset] == nil then
			Resources.Data[asset] = {}
		end
		local assetTable = Resources.Data[asset]
		for key, val in pairs(data) do
			assetTable[key] = val
		end
	end

	-- Callback function(s) for loading data from resource files
	function GameResources(data) dataLoadHelper("Game", data) end

	-- Each screen is its own asset category of data
	function ScreenResources(data)
		for screen, labels in pairs(data) do
			dataLoadHelper(screen, labels)
		end
	end
end

-- Replaces non-English characters with the their unicode equivalents
function Resources.sanitizeTable(data)
	if Main.supportsSpecialChars then return end

	-- Create a regex pattern of all of the available special characters (those which require encoding)
	local pattern = string.format("[%s]", table.concat(Constants.CharCategories.Special))

	-- A function to recursively replace all strings in a table that match that pattern
	local sanitize -- Yes, this requires two separate lines for "local recursion" in Lua
	sanitize = function(t)
		for key, val in pairs(t) do
			if type(val) == "string" and val:find(pattern) then
				t[key] = Utils.formatSpecialCharacters(val)
			elseif type(val) == "table" then
				sanitize(val)
			end
		end
	end
	sanitize(data)
end
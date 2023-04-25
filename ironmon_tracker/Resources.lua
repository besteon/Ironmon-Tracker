Resources = {}
-- TODO: Task list:
-- - Fix 3D Animated Popout to not rely on Pokemon names from PokemonData
-- - Add Drawing function to draw pokemon type bar with text overlayed
-- - Find solution for text highlights that count pixels of a character/string (i.e. next move level)
-- Swapping to a non-default language, then swapping to another unfinished non-default language won't update missing pieces with default data.

Resources.Languages = {
	ENGLISH = {
		Ordinal = 1,
		Key = "ENGLISH",
		DisplayName = "English",
		FileName = "English.lua",
	},
	SPANISH = {
		Ordinal = 2,
		Key = "SPANISH",
		DisplayName = "Español",
		FileName = "Spanish.lua",
	},
	GERMAN = {
		Ordinal = 3,
		Key = "GERMAN",
		DisplayName = "Deutsche",
		FileName = "German.lua",
	},
	FRENCH = {
		Ordinal = 4,
		Key = "FRENCH",
		DisplayName = "Français",
		FileName = "French.lua",
	},
	ITALIAN = {
		Ordinal = 5,
		Key = "ITALIAN",
		DisplayName = "Italiano",
		FileName = "Italian.lua",
	},
	CHINESE = {
		Ordinal = 6,
		Key = "CHINESE",
		DisplayName = "中文",
		FileName = "Chinese.lua",
		RequiresUTF16 = true,
		ExcludeFromSettings = true,  -- Currently not included or supported yet
	},
	JAPANESE = {
		Ordinal = 7,
		Key = "JAPANESE",
		DisplayName = "日本語",
		FileName = "Japanese.lua",
		RequiresUTF16 = true,
	},
}

Resources.Default = {
	Language = Resources.Languages.ENGLISH,
	Data = nil, -- Used to fill in gaps in other language resource data
}

-- Holds all current resources data used by all Tracker assets; data is categorized
-- For now, it simply holds functions that are used to replace existing data on the Tracker
-- In the future, it will hold the actual resources, and the Tracker will refer here for that data
-- Similar to how Themes.COLORS["key"] works.
Resources.Data = {
	Game = {
		PokemonNames = {
			updateAll = function(self, data)
				for index, val in ipairs(PokemonData.Pokemon) do
					val.name = data[index]
				end
			end,
		},
		MoveNames = {
			updateAll = function(self, data)
				for index, val in ipairs(MoveData.Moves) do
					val.name = data[index]
				end
			end,
		},
		MoveDescriptions = {
			updateAll = function(self, data)
				for index, val in ipairs(MoveData.Moves) do
					val.summary = data[index]
				end
			end,
		},
		AbilityNames = {
			updateAll = function(self, data)
				for index, val in ipairs(AbilityData.Abilities) do
					val.name = data[index]
				end
			end,
		},
		AbilityDescriptions = {
			updateAll = function(self, data)
				for index, val in ipairs(AbilityData.Abilities) do
					val.description = data[index].description
					if data[index].descriptionEmerald ~= nil then
						val.descriptionEmerald = data[index].descriptionEmerald
					end
				end
			end,
		},
		ItemNames = {
			updateAll = function(self, data) MiscData.Items = data end,
		},
		NatureNames = {
			updateAll = function(self, data) MiscData.Natures = data end,
		},
	},
}

function Resources.initialize()
	if Resources.hasInitialized then return end

	-- Define metatable for easier resource lookup. (i.e. Resources.TrackerScreen.StatATK)
	local mt = {}
	setmetatable(Resources, mt)
	mt.__index = Resources.Data

	Resources.defineResourceCallbacks()
	Resources.sanitizeTable(Resources.Languages)

	-- Load in default language data first, to fill in gaps in other language data
	Resources.loadAndApplyLanguage(Resources.Default.Language)

	-- Then load in the user's language
	local userLanguageKey = Options["Language"] or Resources.Default.Language.Key
	Resources.loadAndApplyLanguage(Resources.Languages[userLanguageKey])

	Resources.hasInitialized = true
end

-- Attempts to automatically change the language based on the game being played.
function Resources.autoDetectForeignLanguage()
	local language = Resources.Languages[GameSettings.language:upper()]

	if not Options["Autodetect language from game"] or language == nil or language == Resources.Default.Language then
		return
	end

	Resources.loadAndApplyLanguage(language)
end

function Resources.changeLanguageSetting(language)
	if language == nil or language == Resources.currentLanguage or not Resources.Languages[language.Key] then
		return
	end

	Resources.currentLanguage = language
	Options["Language"] = language.Key
	Main.SaveSettings(true)
	Resources.loadAndApplyLanguage(language)
end

-- Loads resources for the specified language into all of the Tracker's assets
function Resources.loadAndApplyLanguage(language)
	if language == nil or language.FileName == nil then
		return false
	end

	-- Some languages are supported on some emulators
	if language.RequiresUTF16 and not Main.supportsSpecialChars then
		Main.DisplayError(string.format("UTF-16 characters not supported on this emulator version (%s).", Main.emulator))
		return false
	end

	local langFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
	local langFilePath = langFolder .. language.FileName
	if FileManager.fileExists(langFilePath) then
		Resources.LoadedData = {}
		Resources.currentLanguage = language

		-- Load data into Resources.LoadedData
		dofile(langFilePath)

		Resources.sanitizeTable(Resources.LoadedData)
		Resources.updateTrackerResources(Resources.LoadedData)
		Resources.LoadedData = nil

		return true
	else
		return false
	end
end

-- Establishes global functions used for loading resource data from resource files
function Resources.defineResourceCallbacks()
	-- Sub function used by other resource load functions
	local function dataLoadHelper(category, data)
		if Resources.LoadedData[category] == nil then
			Resources.LoadedData[category] = {}
		end
		local loadedCategory = Resources.LoadedData[category]
		local defaultTable = (Resources.Default.Data or {})[category]

		for key, _ in pairs(Resources.Data[category]) do
			if data[key] then
				loadedCategory[key] = data[key]
			elseif defaultTable ~= nil then
				-- Fill in missing data with default data, if available
				loadedCategory[key] = defaultTable[key]
			end
		end
	end

	-- Callback function(s) for loading data from resource files
	function GameResources(data) dataLoadHelper("Game", data) end

	-- Each screen is its own category of data
	function ScreenResources(data)
		for screen, labels in pairs(data) do
			if Resources.Data[screen] == nil then
				Resources.Data[screen] = {}
			end
			for key, val in pairs(labels) do
				Resources.Data[screen][key] = val
			end
		end
	end
	Resources.sanitizeTable(Resources.Data)
end

-- Replaces non-English characters with the their unicode equivalents
function Resources.sanitizeTable(data)
	if Main.supportsSpecialChars then return end

	-- Create a regex pattern of all of the available special characters
	local specialChars = {}
	for char, _ in pairs(Constants.CharMap) do
		table.insert(specialChars, char)
	end
	local pattern = string.format("[%s]", table.concat(specialChars))

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

-- Updates the Tracker's assets with the loaded resource files (required)
-- In the future, will likely have Tracker assets pull directly from loaded data
-- instead of replacing existing data with newly loaded stuff.
function Resources.updateTrackerResources(loadedData)
	if loadedData == nil or loadedData == {} then
		return
	end

	-- Update each asset in each category
	for category, assetList in pairs(Resources.Data) do
		local loadedCategory = loadedData[category]
		if loadedCategory then
			for key, asset in pairs(assetList) do
				local data = loadedCategory[key]
				if data and type(asset.updateAll) == "function" then
					asset:updateAll(data)
				end
			end
		end
	end
end

-- TODO: Internal function only to turn tracker assets into data files.
-- Should not be used or included in the PR
function Resources.fakeOutputDataHelper()
	local filename = "OutputDataFile.txt"
	local filepath = FileManager.prependDir(filename)
	local file = io.open(filepath, "w")

	if file == nil then
		return
	end

	file:write("---@diagnostic disable: undefined-global")
	file:write("\n")
	file:write("\n")
	file:write("GameResources{")
	file:write("\n")

	file:write("	PokemonNames = {")
	file:write("\n")
	for _, val in ipairs(PokemonData.Pokemon) do
		file:write(string.format('		"%s",', val.name))
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("	MoveNames = {")
	file:write("\n")
	for _, val in ipairs(MoveData.Moves) do
		file:write(string.format('		"%s",', val.name))
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("	MoveDescriptions = {")
	file:write("\n")
	for _, val in ipairs(MoveData.Moves) do
		file:write(string.format('		"%s",', val.summary or ""))
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("	AbilityNames = {")
	file:write("\n")
	for _, val in ipairs(AbilityData.Abilities) do
		file:write(string.format('		"%s",', val.name))
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("	AbilityDescriptions = {")
	file:write("\n")
	for _, val in ipairs(AbilityData.Abilities) do
		file:write('		{')
		file:write("\n")
		file:write(string.format('			description = "%s",', val.description or ""))
		file:write("\n")
		if val.descriptionEmerald then
			file:write(string.format('			descriptionEmerald = "%s",', val.descriptionEmerald))
			file:write("\n")
		end
		file:write('		},')
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("	ItemNames = {")
	file:write("\n")
	for _, val in ipairs(MiscData.Items) do
		file:write(string.format('		"%s",', val))
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("	NatureNames = {")
	file:write("\n")
	for _, val in ipairs(MiscData.Natures) do
		file:write(string.format('		"%s",', val))
		file:write("\n")
	end
	file:write("	},")
	file:write("\n")

	file:write("}")
	file:write("\n")
	file:close()

end
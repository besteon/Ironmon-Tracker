Resources = {}

-- Debug: For quickly checking that all resources have been translated.
local DEBUG_REPLACE_ALL_RESOURCES = false
local DEBUG_REPLACEMENT_STRING = "$"

-- TODO: Task list:
-- * Log Viewer reading/parsing/searching log files
-- * Add Drawing function to draw pokemon type bar with text overlayed
-- * Find solution for text highlights that count pixels of a character/string (i.e. next move level)

-- Things to test:
-- * Check on Bizhawk 2.8 that words like "Pokémon" appear correctly

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
		DisplayName = "Deutsch",
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
		ExcludeFromSettings = true,  -- Currently not yet included or supported.
	},
	JAPANESE = {
		Ordinal = 7,
		Key = "JAPANESE",
		DisplayName = "日本語",
		FileName = "Japanese.lua",
		RequiresUTF16 = true,
		ExcludeFromSettings = false and true,  -- This should NOT be supported or reveal, due to risks. (TODO: remove 'false')
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
	Resources.copyTable(Resources.Data, Resources.Default.Data)

	-- Define metatables
	local default_mt = {}
	setmetatable(Resources.Default, default_mt)
	default_mt.__index = Resources.Default.Data

	-- Then load in the language chosen by the user's settings
	local userLanguageKey = Options["Language"] or Resources.Default.Language.Key
	Resources.loadAndApplyLanguage(Resources.Languages[userLanguageKey])

	-- TODO: Remove this before the PR
	Resources.fakeOutputDataHelper()

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
	local success = Resources.loadAndApplyLanguage(language)
	if success then
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
	if FileManager.fileExists(langFilePath) then
		-- Prepopulate with default data. Newly loaded data (if it exists) replaces each key
		Resources.copyTable(Resources.Default.Data, Resources.Data)

		-- Load data into Resources.Data
		dofile(langFilePath)

		Resources.currentLanguage = language
		Resources.sanitizeTable(Resources.Data)
		FileManager.executeEachFile("updateResources")
		collectgarbage()

		return true
	else
		return false
	end
end

-- Establishes global functions used for loading resource data from resource files
function Resources.defineResourceCallbacks()
	local debugReplaceAll
	debugReplaceAll = function(table)
		for key, val in pairs(table or {}) do
			if type(val) == "string" then
				table[key] = DEBUG_REPLACEMENT_STRING or Constants.BLANKLINE
			elseif type(val) == "table" then
				debugReplaceAll(val)
			end
		end
	end

	-- Sub function used by other resource load functions
	local function dataLoadHelper(asset, data)
		if Resources.Data[asset] == nil then
			Resources.Data[asset] = {}
		end
		local assetTable = Resources.Data[asset]
		for key, val in pairs(data) do
			assetTable[key] = val
		end
		-- TODO: Remove this and its related function before PR merge
		if DEBUG_REPLACE_ALL_RESOURCES then
			debugReplaceAll(assetTable)
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

function Resources.copyTable(source, dest)
	for key, val in pairs(source) do
		if type(val) == "table" then
			dest[key] = {}
			Resources.copyTable(val, dest[key])
		else
			dest[key] = val
		end
	end
end

-- TODO: Internal function only to turn tracker assets into data files.
-- Should not be used or included in the PR
function Resources.fakeOutputDataHelper()

	if true then return end -- Comment this line out to use

	local filename = "OutputDataFile.txt"
	local filepath = FileManager.prependDir(filename)
	local file = io.open(filepath, "w")
	if file == nil then return end

	local screenToPrint = "ExtrasScreen"

	-- local langFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
	-- local langFilePath = langFolder .. Resources.Languages.ENGLISH.FileName
	-- local lines = FileManager.readLinesFromFile(langFilePath)

	-- local indexFound
	-- for i, line in ipairs(lines) do
	-- 	if line:find(screenToPrint .. " = {") then
	-- 		indexFound = i
	-- 		break
	-- 	end
	-- end
	-- if not indexFound then
	-- 	return
	-- end

	-- -- Locate {key, value} pairs
	-- local pattern = '^%s*(%S*)%s*=%s*"(.-)",$'
	-- local keys, values = {}, {}
	-- for i = indexFound + 1, #lines, 1 do
	-- 	local line = lines[i]
	-- 	if line:find("^%s*},$") then
	-- 		break
	-- 	end

	-- 	local key, value = string.match(line, pattern)
	-- 	table.insert(keys, key)
	-- 	table.insert(values, value)
	-- end

	-- -- Print collected data to file
	-- local sectionLabel = string.format("- %s Values -", screenToPrint):upper()
	-- file:write(string.rep("-", #sectionLabel))
	-- file:write("\n")
	-- file:write(sectionLabel)
	-- file:write("\n")
	-- file:write(string.rep("-", #sectionLabel))
	-- file:write("\n")
	-- for _, value in ipairs(values) do
	-- 	file:write(value)
	-- 	file:write("\n")
	-- end
	-- file:write("\n")
	-- sectionLabel = string.format("- %s Keys -", screenToPrint):upper()
	-- file:write(string.rep("-", #sectionLabel))
	-- file:write("\n")
	-- file:write(sectionLabel)
	-- file:write("\n")
	-- file:write(string.rep("-", #sectionLabel))
	-- file:write("\n")
	-- for _, key in ipairs(keys) do
	-- 	file:write(key)
	-- 	file:write("\n")
	-- end

	-- if true then
	-- 	file:close()
	-- 	return
	-- end

	file:write("GameResources{")
	file:write("\n")

	-- file:write("	PokemonNames = {")
	-- file:write("\n")
	-- for _, val in ipairs(PokemonData.Pokemon) do
	-- 	file:write(string.format('		"%s",', val.name))
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	-- file:write("	MoveNames = {")
	-- file:write("\n")
	-- for _, val in ipairs(MoveData.Moves) do
	-- 	file:write(string.format('		"%s",', val.name))
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	-- file:write("	MoveDescriptions = {")
	-- file:write("\n")
	-- for _, val in ipairs(MoveData.Moves) do
	-- 	file:write('		{')
	-- 	file:write("\n")
	-- 	file:write(string.format('			NameKey = "%s",', val.name or ""))
	-- 	file:write("\n")
	-- 	file:write(string.format('			Description = "%s",', val.summary or ""))
	-- 	file:write("\n")
	-- 	file:write('		},')
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	-- file:write("	AbilityNames = {")
	-- file:write("\n")
	-- for _, val in ipairs(AbilityData.Abilities) do
	-- 	file:write(string.format('		"%s",', val.name))
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	-- file:write("	AbilityDescriptions = {")
	-- file:write("\n")
	-- for _, val in ipairs(AbilityData.Abilities) do
	-- 	file:write('		{')
	-- 	file:write("\n")
	-- 	file:write(string.format('			NameKey = "%s",', val.name or ""))
	-- 	file:write("\n")
	-- 	file:write(string.format('			Description = "%s",', val.description or ""))
	-- 	file:write("\n")
	-- 	if val.descriptionEmerald then
	-- 		file:write(string.format('			DescriptionEmerald = "%s",', val.descriptionEmerald))
	-- 		file:write("\n")
	-- 	end
	-- 	file:write('		},')
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	-- file:write("	ItemNames = {")
	-- file:write("\n")
	-- for _, val in ipairs(MiscData.Items) do
	-- 	file:write(string.format('		"%s",', val))
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	-- file:write("	NatureNames = {")
	-- file:write("\n")
	-- for _, val in ipairs(MiscData.Natures) do
	-- 	file:write(string.format('		"%s",', val))
	-- 	file:write("\n")
	-- end
	-- file:write("	},")
	-- file:write("\n")

	file:write("}")
	file:write("\n")
	file:close()

end
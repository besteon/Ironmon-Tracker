Resources = {}

Resources.Lang = {
	ENGLISH = { DisplayName = "English", FileName = "English.lua", RequiresUTF16 = false, },
	SPANISH = { DisplayName = "Español", FileName = "Spanish.lua", RequiresUTF16 = false, },
	FRENCH = { DisplayName = "Français", FileName = "French.lua", RequiresUTF16 = false, },
	ITALIAN = { DisplayName = "Italiano", FileName = "Italian.lua", RequiresUTF16 = false, },
	GERMAN = { DisplayName = "Deutsche", FileName = "German.lua", RequiresUTF16 = false, },
	JAPANESE = { DisplayName = "日本語", FileName = "Japanese.lua", RequiresUTF16 = true, },
	CHINESE = { DisplayName = "中文", FileName = "Chinese.lua", RequiresUTF16 = true, }, -- Currently not included or supported
}
Resources.LoadedData = {}

Resources.Default = {
	Lang = Resources.Lang.ENGLISH,
	LoadedData = nil,
}

Resources.DataCategories = {
	GameData = {
		{
			key = "PokemonNames",
			updateAssets = function(data)
				for index, val in ipairs(PokemonData.Pokemon) do
					val.name = data[index]
				end
			end,
		},
		{
			key = "MoveNames",
			updateAssets = function(data)
				for index, val in ipairs(MoveData.Moves) do
					val.name = data[index]
				end
			end,
		},
		{
			key = "MoveDescriptions",
			updateAssets = function(data)
				for index, val in ipairs(MoveData.Moves) do
					val.summary = data[index]
				end
			end,
		},
		{
			key = "AbilityNames",
			updateAssets = function(data)
				for index, val in ipairs(AbilityData.Abilities) do
					val.name = data[index]
				end
			end,
		},
		{
			key = "AbilityDescriptions",
			updateAssets = function(data)
				for index, val in ipairs(AbilityData.Abilities) do
					val.description = data[index].description
					if data[index].descriptionEmerald ~= nil then
						val.descriptionEmerald = data[index].descriptionEmerald
					end
				end
			end,
		},
		{
			key = "ItemNames",
			updateAssets = function(data) MiscData.Items = data end,
		},
		{
			key = "NatureNames",
			updateAssets = function(data) MiscData.Natures = data end,
		},
	},
}

function Resources.getLangFolder()
	return FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
end

-- Loads resources for the specified language into all of the Tracker's assets
function Resources.loadLanguage(language)
	language = language or Resources.Default.Lang

	if language.FileName == nil then
		return false
	end

	-- Clear out existing loaded language data
	Resources.LoadedData = {
		GameData = {},
	}

	Resources.defineLoadFunctions()

	-- Load in default language data first, to fill in gaps in other language data
	local defaultLangFilePath = Resources.getLangFolder() .. Resources.Default.Lang.FileName
	if Resources.Default.LoadedData == nil and FileManager.fileExists(defaultLangFilePath) then
		dofile(defaultLangFilePath)
		Resources.Default.LoadedData = Resources.LoadedData
	end

	-- If the language being loaded is the default language, the work is already done
	if language == Resources.Default.Lang then
		Resources.LoadedData = Resources.Default.LoadedData
		Resources.updateTrackerResources()
		return true
	end

	-- Some languages are supported on some emulators
	if language.RequiresUTF16 and not Main.supportsSpecialChars then
		Main.DisplayError(string.format("UTF-16 characters not supported on this emulator version (%s).", Main.emulator))
		return false
	end

	-- Load in the desired language file
	local langFilePath = Resources.getLangFolder() .. language.FileName
	if FileManager.fileExists(langFilePath) then
		dofile(langFilePath)
		Resources.updateTrackerResources()
		return true
	else
		return false
	end
end

function Resources.defineLoadFunctions()
	if Resources.loadFunctionsDefined then return end

	local function dataLoadHelper(struct, data)
		local loadinTable = Resources.LoadedData[struct]
		local defaultTable = (Resources.Default.LoadedData or {})[struct]

		for _, obj in ipairs(Resources.DataCategories[struct]) do
			if data[obj.key] then
				-- Add in any/all matching data
				loadinTable[obj.key] = data[obj.key]
			elseif defaultTable ~= nil then
				-- Fill in missing data with default data, if available
				loadinTable[obj.key] = defaultTable[obj.key]
			end
		end
	end

	-- Function(s) for loading game data resources
	function GameData(data) dataLoadHelper("GameData", data) end

	Resources.loadFunctionsDefined = true
end

-- Updates the Tracker's assets with the loaded resource files
function Resources.updateTrackerResources()
	-- Load the default language if none present
	if Resources.LoadedData == nil or Resources.LoadedData == {} then
		Resources.loadLanguage(Resources.Default.Lang)
	end

	-- Update all data assets
	for category, assets in pairs(Resources.DataCategories) do
		-- Update each resource asset in the category
		for _, asset in ipairs(assets) do
			local data = Resources.LoadedData[category][asset.key]
			asset.updateAssets(data)
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
	file:write("GameData{")
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

	-- end GameData
	file:write("}")
	file:write("\n")
	file:close()

end
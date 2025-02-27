GachaMonData = {}

GachaMonData.ShinyOdds = 0.002 -- 1 in 500, similar to Pokémon Go

function GachaMonData.initialize()

end

---@param pokemonData IPokemon
---@return IGachaMon gachamon
function GachaMonData.convertPokemonToGachaMon(pokemonData)
	local gachamon = GachaMonData.IGachaMon:new({
		PokemonId = pokemonData.pokemonID,
		Gender = pokemonData.gender,
		Nature = pokemonData.nature,
		Level = pokemonData.level,
		IsShiny = pokemonData.isShiny,
		GameVersion = GameSettings.versioncolor or Constants.HIDDEN_INFO,
		SeedNumber = Main.currentSeed or 0,
	})

	-- Core data copy
	gachamon.AbilityId = PokemonData.getAbilityId(pokemonData.pokemonID, pokemonData.abilityNum)
	for statKey, _ in pairs(pokemonData.stats or {}) do
		gachamon.Stats[statKey] = pokemonData.stats[statKey] or 0
		gachamon.Ivs[statKey] = pokemonData.ivs[statKey] or 0
	end
	for _, move in ipairs(pokemonData.moves or {}) do
		if MoveData.isValid(move.id) then
			table.insert(gachamon.Moves, move.id)
		end
	end
	gachamon.DateObtained = os.time()
	local routeObtained = RouteData.Info[TrackerAPI.getMapId()] or {}
	gachamon.LocationObtained = routeObtained.name or Constants.HIDDEN_INFO

	-- Other data calculations
	gachamon.StarRating = GachaMonData.calcStarRating(gachamon)
	if not gachamon.IsShiny and math.random() <= GachaMonData.ShinyOdds then -- Reroll shininess chance
		gachamon.IsShiny = true
	end

	return gachamon
end


---
---@param gachamon IGachaMon
---@return number rating Value between 0 and 100
function GachaMonData.calcStarRating(gachamon)
	return 0
end

---Imports all GachaMon data from a JSON file
---@param filepath? string Optional, a custom JSON file; default path: FileManager.Files.GACHAMON_DATA
---@return boolean success
function GachaMonData.importDataFromJson(filepath)
	filepath = filepath or GachaMonData.getDataFilePath() or ""
	if not FileManager.fileExists(filepath) then
		return false
	end

	local data = FileManager.decodeJsonFile(filepath)
	if not (data) then
		return false
	end

	-- Copy over the imported data to the gachamon data set

	return true
end

---@return string filepath
function GachaMonData.getDataFilePath()
	return FileManager.prependDir(FileManager.Files.GACHAMON_DATA)
end



-- GachaMon object prototypes

---@class IGachaMon
GachaMonData.IGachaMon = {
	-- ENCODED VALUES (shareable data for trading/battling)

	PokemonId = 0,
	StarRating = 0,
	Gender = 0,
	Nature = 0,
	Level = 0,
	AbilityId = 0,
	IsShiny = false, -- GachaMons have higher shiny chance (TBD)
	Stats = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	Ivs = { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 },
	Moves = {}, -- Ordered list of the 4 move ids the mon had when collected

	-- NON-ENCODED VALUES

	-- Some unique identifier, might not need to be a GUID
	GUID = "",
	-- Which Pokémon game version this mon was collected on
	GameVersion = "",
	-- The seed number at the time this mon was collected
	SeedNumber = 0,
	-- The date time for when this mon was collected
	DateObtained = 0,
	-- Where the mon was collected (route/map name)
	LocationObtained = "",
	-- Where the mon fainted (route/map name)
	LocationDeath = "",
	-- How long this mon survived (gameplay time) between when it was caught and when it fainted
	Lifespan = 0,
}
---Creates and returns a new IGachaMon object
---@param o? table Optional initial object table
---@return IGachaMon profile An IGachaMon object
function GachaMonData.IGachaMon:new(o)
	o = o or {}

	o.PokemonId = o.PokemonId or 0
	o.StarRating = o.StarRating or 0
	o.Gender = o.Gender or 0
	o.Nature = o.Nature or 0
	o.Level = o.Level or 0
	o.AbilityId = o.AbilityId or 0
	o.IsShiny = (o.IsShiny == true)
	o.Stats = o.Stats or { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	o.Ivs = o.Ivs or { hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0 }
	o.Ivs = o.Ivs or { }

	o.GUID = o.GUID or Utils.newGUID()
	o.GameVersion = o.GameVersion or ""
	o.SeedNumber = o.SeedNumber or 0
	o.DateObtained = o.DateObtained or 0
	o.LocationObtained = o.LocationObtained or ""
	o.LocationDeath = o.LocationDeath or ""
	o.Lifespan = o.Lifespan or 0

	setmetatable(o, self)
	self.__index = self
	return o
end

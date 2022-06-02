Tracker = {}

Tracker.userDataKey = "ironmon_tracker_data"

Tracker.redraw = true
Tracker.waitFrames = 0

Tracker.controller = {
	statIndex = 1,
	framesSinceInput = 120,
	boxVisibleFrames = 120,
}

Tracker.Data = {}

function Tracker.InitTrackerData()
	local trackerData = {
		selectedPokemon = {},
		targetedPokemon = {},
		main = {
			ability = 0
		},
		inBattle = 0,
		needCheckSummary = 0,
		selectedPlayer = 1,
		selectedSlot = 1,
		targetPlayer = 2,
		targetSlot = 1,
		selfSlotOne = 1,
		selfSlotTwo = 1,
		enemySlotOne = 1,
		enemySlotTwo = 1,
		moves = {},
		stats = {},
		abilities = {},
		items = {},
		healingItems = {
			healing = 0,
			numHeals = 0,
		},
		notes = {},
		currentHiddenPowerType = PokemonTypes.NORMAL,
		romHash = nil,
	}
	return trackerData
end

function Tracker.Clear()
	if userdata.containskey(Tracker.userDataKey) then
		userdata.remove(Tracker.userDataKey)
	end
	Tracker.Data = Tracker.InitTrackerData()
end

function Tracker.TrackAbility(pokemonId, abilityId)
	local currentAbilities = Tracker.Data.abilities[pokemonId]
	if currentAbilities == nil then
		Tracker.Data.abilities[pokemonId] = {}
		Tracker.Data.abilities[pokemonId][abilityId] = abilityId
	else
		if currentAbilities[abilityId] == nil then
			Tracker.Data.abilities[pokemonId][abilityId] = abilityId
		end
	end
end

function Tracker.TrackItem(pokemonId, itemId)

end

function Tracker.TrackMove(pokemonId, moveId, level)
	local currentMoves = Tracker.Data.moves[pokemonId]
	if currentMoves == nil then
		Tracker.Data.moves[pokemonId] = {}
		Tracker.Data.moves[pokemonId].first = {
			move = moveId,
			level = level
		}
		Tracker.Data.moves[pokemonId].second = {
			move = 1,
			level = 1
		}
		Tracker.Data.moves[pokemonId].third = {
			move = 1,
			level = 1
		}
		Tracker.Data.moves[pokemonId].fourth = {
			move = 1,
			level = 1
		}
	else
		local moveSeen = false
		local moveCount = 0
		local whichMove = 0
		for key, value in pairs(currentMoves) do
			moveCount = moveCount + 1
			if value.move == moveId then
				moveSeen = true
				whichMove = key
			end
		end

		if moveSeen == false then
			if moveCount == 1 then
				Tracker.Data.moves[pokemonId].second = {
					move = moveId,
					level = level
				}
			elseif moveCount == 2 then
				Tracker.Data.moves[pokemonId].third = {
					move = moveId,
					level = level
				}
			elseif moveCount == 3 then
				Tracker.Data.moves[pokemonId].fourth = {
					move = moveId,
					level = level
				}
			elseif moveCount == 4 then
				Tracker.Data.moves[pokemonId].fourth = Tracker.Data.moves[pokemonId].third
				Tracker.Data.moves[pokemonId].third = Tracker.Data.moves[pokemonId].second
				Tracker.Data.moves[pokemonId].second = Tracker.Data.moves[pokemonId].first
				Tracker.Data.moves[pokemonId].first = {
					move = moveId,
					level = level
				}
			end
		else
			Tracker.Data.moves[pokemonId][whichMove] = {
				move = moveId,
				level = level
			}
		end
	end
end

function Tracker.TrackStatPrediction(pokemonId, stats)
	Tracker.Data.stats[pokemonId] = {}
	Tracker.Data.stats[pokemonId].stats = stats
end

function Tracker.SetNote(note)
	if note == nil then
		return
	end
	if string.len(note) > 70 then
		print("Note truncated to 70 characters")
	end
	Tracker.Data.notes[Tracker.Data.selectedPokemon.pokemonID] = string.sub(note, 1, 70)
end

function Tracker.GetNote()
	if Tracker.Data.notes[Tracker.Data.selectedPokemon.pokemonID] == nil then
		return ""
	else
		return Tracker.Data.notes[Tracker.Data.selectedPokemon.pokemonID]
	end
end

function Tracker.getMoves(pokemonId)
	if Tracker.Data.moves[pokemonId] == nil then
		return {
			first = {
				move = 1,
				level = 1
			},
			second = {
				move = 1,
				level = 1
			},
			third = {
				move = 1,
				level = 1
			},
			fourth = {
				move = 1,
				level = 1
			}
		}
	else
		return Tracker.Data.moves[pokemonId]
	end
end

function Tracker.getAbilities(pokemonId)
	if Tracker.Data.abilities[pokemonId] == nil then
		return {
			1
		}
	else
		return Tracker.Data.abilities[pokemonId]
	end
end

function Tracker.getButtonState()
	if Tracker.Data.stats[Tracker.Data.selectedPokemon.pokemonID] == nil then
		return {
			hp = 1,
			att = 1,
			def = 1,
			spa = 1,
			spd = 1,
			spe = 1
		}
	else
		return Tracker.Data.stats[Tracker.Data.selectedPokemon.pokemonID].stats
	end
end

function Tracker.saveData()
	local dataString = pickle(Tracker.Data)
	userdata.set(Tracker.userDataKey, dataString)
end

function Tracker.loadData()
	if userdata.containskey(Tracker.userDataKey) then
		local serializedTable = userdata.get(Tracker.userDataKey)
		local trackerData = unpickle(serializedTable)
		Tracker.Data = Tracker.InitTrackerData()
		for k, v in pairs(trackerData) do
			Tracker.Data[k] = v
		end

		if Tracker.Data.romHash then
			if gameinfo.getromhash() == Tracker.Data.romHash then
				print("Loaded tracker data")
			else
				print("New ROM detected, resetting tracker data")
				Tracker.Data = Tracker.InitTrackerData()
			end
		end
	else
		Tracker.Data = Tracker.InitTrackerData()
		if Settings.tracker.MUST_CHECK_SUMMARY == true then
			Tracker.Data.needCheckSummary = 1
		end
	end

	Tracker.Data.romHash = gameinfo.getromhash()
	Tracker.redraw = true
end

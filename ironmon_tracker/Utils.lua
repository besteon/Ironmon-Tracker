Utils = {}

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1, d)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a, 0, 16)
	local c = Utils.getbits(a, 16, 16)
	return b + c
end

-- If the `condition` is true, the value in `T` is returned, else the value in `F` is returned
function Utils.inlineIf(condition, T, F)
	if condition then return T else return F end
end

function Utils.netEffectiveness(move, pkmnData)
	local effectiveness = 1.0
	if move["power"] == NOPOWER then
		return 1.0
	end

	for _, type in ipairs(pkmnData["type"]) do
		if move["type"] ~= "---" then
			if EffectiveData[move["type"]][type] ~= nil then
				effectiveness = effectiveness * EffectiveData[move["type"]][type]
			end
		end
	end
	return effectiveness
end

function Utils.isSTAB(move, pkmnData)
	for _, type in ipairs(pkmnData["type"]) do
		if move["type"] == type then
			return true
		end
	end
	return false
end

-- Calculate base power for low kick (and grass knot in gen 4)
function Utils.weightMovePower(pkmnData)
	local weight = tonumber(pkmnData["weight"])
	if weight == nil then
		return "WT"
	end
	local power = "20"
	if weight <= 22 then
		power = "20"
	elseif weight > 22 and weight <= 55 then
		power = "40"
	elseif weight > 55 and weight <= 110 then
		power = "60"
	elseif weight > 110 and weight <= 220 then
		power = "80"
	elseif weight > 220 and weight <= 440 then
		power = "100"
	elseif weight > 440 then
		power = "120"
	end
	return power
end

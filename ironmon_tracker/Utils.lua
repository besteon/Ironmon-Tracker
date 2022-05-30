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

function Utils.calculateWeightBasedDamage(weight)
	if weight < 10.0 then
		return "20"
	elseif weight < 25.0 then
		return "40"
	elseif weight < 50.0 then
		return "60"
	elseif weight < 100.0 then
		return "80"
	elseif weight < 200.0 then
		return "100"
	else
		return "120"
	end
end
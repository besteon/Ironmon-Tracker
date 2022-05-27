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
	-- Skip check if move has no power.
	-- In the case of Mirror Coat (id 243), we want to do the type check because it is ineffective against Dark type.
	if move["power"] == NOPOWER and move.id ~= "243" then
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

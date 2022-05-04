Utils = {}

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1, d)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a, 0, 16)
	local c = Utils.getbits(a, 16, 16)
	return b + c
end

function Utils.inlineIf(condition, T, F)
	if condition then return T else return F end
end

function Utils.netEffectiveness(move, pkmnData)
	local effectiveness = 1.0
	for k, v in ipairs(pkmnData["type"]) do
		if move["type"] ~= "---" then
			if EffectiveData[move["type"]][v] ~= nil then
				effectiveness = effectiveness * EffectiveData[move["type"]][v]
			end
		end
	end
	return effectiveness
end
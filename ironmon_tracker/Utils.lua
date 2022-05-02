Utils = {}

Utils.stageMultipliers = {
	[0] = { value = 0.25, color = 0xFFFF0000 },
	[1] = {	value = 0.285714285714, color = 0xFFFF0000 },
	[2] = {	value = 0.333333333333, color = 0xFFFF0000 },
	[3] = {	value = 0.4, color = 0xFFFF0000 },
	[4] = {	value = 0.5, color = 0xFFFF0000	},
	[5] = {	value = 0.666666666666, color = 0xFFFF0000 },
	[6] = {	value = 1.0, color = 0xFFFFFFFF },
	[7] = {	value = 1.5, color = 0xFF00FF00	},
	[8] = {	value = 2.0, color = 0xFF00FF00 },
	[9] = {	value = 2.5, color = 0xFF00FF00	},
	[10] = { value = 3.0, color = 0xFF00FF00 },
	[11] = { value = 3.5, color = 0xFF00FF00 },
	[12] = { value = 4.0, color = 0xFF00FF00 },
}

Utils.accEvasionMultipliers = {
	[0] = { value = 0.333333333333, color = 0xFFFF0000 },
	[1] = {	value = 0.375, color = 0xFFFF0000 },
	[2] = {	value = 0.428571428571, color = 0xFFFF0000 },
	[3] = {	value = 0.5, color = 0xFFFF0000 },
	[4] = {	value = 0.6, color = 0xFFFF0000	},
	[5] = {	value = 0.75, color = 0xFFFF0000 },
	[6] = {	value = 1.0, color = 0xFFFFFFFF },
	[7] = {	value = 1.333333333333, color = 0xFF00FF00	},
	[8] = {	value = 1.666666666666, color = 0xFF00FF00 },
	[9] = {	value = 2.0, color = 0xFF00FF00	},
	[10] = { value = 2.333333333333, color = 0xFF00FF00 },
	[11] = { value = 2.666666666666, color = 0xFF00FF00 },
	[12] = { value = 3.0, color = 0xFF00FF00 },
}

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1 ,d)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a,0,16)
	local c = Utils.getbits(a,16,16)
	return b + c
end

function Utils.getNatureColor(stat, nature)
	local color = "white"
	if nature % 6 == 0 then
		color = "white"
	elseif stat == "atk" then
		if nature < 5 then
			color = 0xFF00FF00
		elseif nature % 5 == 0 then
			color = "red"
		end
	elseif stat == "def" then
		if nature > 4 and nature < 10 then
			color = 0xFF00FF00
		elseif nature % 5 == 1 then
			color = "red"
		end
	elseif stat == "spe" then
		if nature > 9 and nature < 15 then
			color = 0xFF00FF00
		elseif nature % 5 == 2 then
			color = "red"
		end
	elseif stat == "spa" then
		if nature > 14 and nature < 20 then
			color = 0xFF00FF00
		elseif nature % 5 == 3 then
			color = "red"
		end
	elseif stat == "spd" then
		if nature > 19 then
			color = 0xFF00FF00
		elseif nature % 5 == 4 then
			color = "red"
		end
	end
	return color
end

function Utils.getStatValuesAndColors(stats)
	local statValuesAndColors = {
		HP = {},
		ATK = {},
		DEF = {},
		SPEED = {},
		SPATK = {},
		SPDEF = {},
		ACC = {},
		EVASION = {}
	}
	for k, v in pairs(stats) do
		if stat == "ACC" or stat == "EVASION" then
			statValuesAndColors[k] = Utils.accEvasionMultipliers[v]
		else
			statValuesAndColors[k] = Utils.stageMultipliers[v]
		end
	end
	return statValuesAndColors
end
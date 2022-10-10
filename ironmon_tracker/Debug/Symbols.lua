Symbols = {}

local outputFile = "addresses.txt"

local FRLGEtoRSMap = {
	["sBattleBuffersTransferData"] = "gBattleBuffersTransferData"
}

function Symbols.printSymbols(symbolArr,symbolFile,key, gameType, file)
	file:write("------------symbol of ".. key.." ----------------------\n")
    for _,sym in pairs(symbolArr) do
        local found = false
		if gameType == 0 and FRLGEtoRSMap[sym] ~= nil then
			sym = FRLGEtoRSMap[sym]
		end
        for line in symbolFile:lines() do
            if line:find(sym) ~= nil then
                file:write("GameSettings." .. sym .. " = 0x" .. line:sub(1,8) .. "\n")
                found = true
                break;
            end
        end
        symbolFile:seek("set")
        if found == false then
            file:write(sym .. " = 0x could not find\n")
        end
		local i = 100
		while i > 0 do
			i = i - 1
		end
    end
end

-- this table is for all symbol table you want to search in
-- the symbol file should be in your Debug/Symbol folder
local symbolPath = {
    ["fire red 1.1"] = {
		gameType = 1,
		fileName = "pokefirered_rev1.sym.txt"
	},
	["fire red 1.0"] = {
		gameType = 1,
		fileName = "pokefirered.sym.txt"
	},
	["leaf green 1.1"] = {
		gameType = 1,
		fileName = "pokeleafgreen_rev1.sym.txt"
	},
	["leaf green 1.0"] = {
		gameType = 1,
		fileName = "pokeleafgreen.sym.txt"
	},
	["ruby 1.0"] = {
		gameType = 0,
		fileName = "pokeruby.sym.txt"
	},
	["ruby 1.1"] = {
		gameType = 0,
		fileName = "pokeruby_rev1.sym.txt"
	},
	["ruby 1.2"] = {
		gameType = 0,
		fileName = "pokeruby_rev2.sym.txt"
	},
	["sapphire 1.0"] = {
		gameType = 0,
		fileName = "pokesapphire.sym.txt"
	},
	["sapphire 1.1"] = {
		gameType = 0,
		fileName = "pokesapphire_rev1.sym.txt"
	},
	["sapphire 1.2"] = {
		gameType = 0,
		fileName = "pokesapphire_rev2.sym.txt"
	},
	["emerald"] = {
		gameType = 1,
		fileName = "pokeemerald.sym.txt"
	}
}

-- add what symbols you want to search
local symbolSearch = {
    "BattleScript_MoveUsedIsConfused",
	"BattleScript_MoveUsedIsConfusedNoMore",
	"BattleScript_MoveUsedIsInLove",
	"BattleScript_RanAwayUsingMonAbility",
	"gCurrentTurnActionNumber",
	"gActionsByTurnOrder",
	"gHitMarker",
	"gBattleTextBuff1",
	"sBattleBuffersTransferData",
	"gBattleControllerExecFlags",
	"BattleScript_TookAttack",
	"BattleScript_PrintAbilityMadeIneffective"
}

local writeFile = io.open(outputFile,"w+")
if writeFile ~= nil then
	print ("Starting search.")
	for key,val in pairs(symbolPath) do
		local file = io.open(val.fileName,"r")
		if file ~= nil then
			Symbols.printSymbols(symbolSearch,file,key, val.gameType, writeFile)
			file:close()
		else
			print("could not open symbol file " .. key)
		end
		print (key .. " processed.")
	end
	print ("Search Completed.")
	writeFile:close()
end
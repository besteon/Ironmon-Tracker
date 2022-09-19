Symbols = {}

local FRLGEtoRSMap = {
	["sBattleBuffersTransferData"] = "gBattleBuffersTransferData"
}

function Symbols.printSymbols(symbolArr,symbolFile,key, gameType) 
    print("------------symbol of ".. key.." ----------------------")
    for _,sym in pairs(symbolArr) do
        local found = false
		if gameType == 0 and FRLGEtoRSMap[sym] ~= nil then
			sym = FRLGEtoRSMap[sym]
		end
        for line in symbolFile:lines() do
            if line:find(sym) ~= nil then
                print(sym .. " = 0x" .. line:sub(1,8))
                found = true
                break;
            end
        end
        symbolFile:seek("set")
        if found == false then
            print(sym .. " = 0x could not find")
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
	"gBattleControllerExecFlags"
}


for key,val in pairs(symbolPath) do
    local file = io.open(val.fileName,"r")
    if file ~= nil then
        Symbols.printSymbols(symbolSearch,file,key, val.gameType)
        file:close()
    else 
        print("could not open symbol file " .. key)
    end

end
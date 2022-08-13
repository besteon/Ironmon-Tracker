Symbols = {}

function Symbols.printSymbols(symbolArr,symbolFile,key) 
    print("------------symbol of ".. key.." ----------------------")
    for _,sym in pairs(symbolArr) do
        local found = false
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
    ["fire red 1.1"] = "pokefirered_rev1.sym", --example of how to add symbol file should be in same folder as this script
    ["emerald"] = "pokeemerald.sym"
}

-- add what symbols you want to search 
local symbolSearch = {
    "BattleScript_DrizzleActivates", --example of symbol to search
    "gSaveBlock1"
}


for key,val in pairs(symbolPath) do
    local file = io.open(val,"r")
    if file ~= nil then
        Symbols.printSymbols(symbolSearch,file,key)
        file:close()
    else 
        print("could not open symbol file " .. key)
    end

end
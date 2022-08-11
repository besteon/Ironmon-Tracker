Debug = {}

function Debug.createEditPokeForm()
    local editPoke = forms.newform(200,300)
    local y = 5
    local x = 5
    local pokedexData = {}
    table.insert(pokedexData, "Unchange")
	for _, data in pairs(PokemonData.Pokemon) do
        if data.bst ~= Constants.BLANKLINE then
		    table.insert(pokedexData, data.name)
        end
	end
    local allmovesData = {}
    table.insert(allmovesData, "Unchange")
    table.insert(allmovesData,"None")
	for _, data in pairs(MoveData.Moves) do
		if data.name ~= Constants.BLANKLINE then
			table.insert(allmovesData, data.name)
		end
	end
    
    local specie = Debug.createDropDown(editPoke,"specie:",x,y,pokedexData)
    y = y + 25
    local move1 = Debug.createDropDown(editPoke,"move1:",x,y,allmovesData)
    y = y + 25
    local move2 = Debug.createDropDown(editPoke,"move2:",x,y,allmovesData)
    y = y + 25
    local move3 = Debug.createDropDown(editPoke,"move3:",x,y,allmovesData)
    y = y + 25
    local move4 = Debug.createDropDown(editPoke,"move4:",x,y,allmovesData)
    y = y + 25
    local partyNum = Debug.createDropDown(editPoke,"party Num:",x,y,{"1","2","3","4","5","6"})
    y = y + 25
    local ability = Debug.createDropDown(editPoke,"ability:",x,y,{"Unchange","1","2"})
    local enemy = forms.checkbox(editPoke,"opponent ",x ,y +30)
    local formTable = {
        ["mainForm"] = editPoke,
        ["specie"] = specie,
        ["move1"] = move1,
        ["move2"] = move2,
        ["move3"] = move3,
        ["move4"] = move4,
        ["partyNum"] = partyNum,
        ["ability"] = ability,
        ["enemy"] = enemy
    }
    local setBtn = forms.button(editPoke,"set",
                    function () Debug.setPokemonData(formTable) end,
                    120,y+30
                    )
    return formTable
end

function Debug.setPokemonData(formsTable)
    local addr = Utils.inlineIf(forms.ischecked(formsTable["enemy"]),GameSettings.estats,GameSettings.pstats)
    addr = addr + (tonumber(forms.gettext(formsTable["partyNum"])) - 1) * 100 -- size of Pokemon struct
    local personality = Memory.readdword(addr)
    local growthOffset = (MiscData.TableData.growth[personality % 24 + 1] - 1) * 12
    local attacksOffset = (MiscData.TableData.attack[personality % 24 + 1] - 1) * 12
    -- local effortOffset = (MiscData.TableData.effort[personality % 24 + 1] - 1) * 12 if we would like to use it in the future
    local miscOffset = (MiscData.TableData.misc[personality % 24 + 1] - 1) * 12
    local magicWord = bit.bxor(personality,Memory.readdword(addr + 4))
    Debug.setGrowth(magicWord,formsTable,addr + 32 + growthOffset)
    Debug.setAttacks(magicWord,formsTable,addr + 32 + attacksOffset)
    -- Debug.setEvAndCond(magicWord,formsTable,addr + 32 + effortOffset)
    Debug.setMisc(magicWord,formsTable,addr + 32 + miscOffset)
    Debug.setCheckSum(magicWord,addr)
end

function Debug.setCheckSum(magicWord,addr)
    local checksum = 0
    local checksumOffset = 28
    local oldchecksum = Memory.readword(addr + checksumOffset)
    for i=0,11 do
        local read = Memory.readdword(addr + 32 + i * 4)
        local val = bit.bxor(magicWord,read)
        checksum = checksum + Utils.getbits(val,0,16) + Utils.getbits(val,16,16)
        
    end
    Memory.writeword(addr + checksumOffset,checksum)
end

function Debug.setMisc(magicWord,formsTable,addrMisc)
    --struct3 misc iv and few other things
    --this struct use mainly bit field ref to struct https://github.com/pret/pokefirered/blob/25344d1bbd45f8778662bcc7733cee0b7a374021/include/pokemon.h#L40
    -- pokerus u8
    -- metlocation u8
    -- catch info gender u16 highest bit for gender
    -- ivs egg ability u32 bit 31 is ability num bit 30 is isegg
    -- other u32
    local abilityChoise = forms.gettext(formsTable["ability"])
    if abilityChoise ~= "Unchange" then
        local misc2 = bit.bxor(magicWord,Memory.readdword(addrMisc + 4))
        if abilityChoise == "1" then misc2 = bit.band(0x7FFFFFFF,misc2) -- clearing bit 31 ability bit
        else misc2 = bit.bor(0x80000000,misc2) end -- setting bit 31 ability bit
        Memory.writedword(addrMisc + 4,bit.bxor(magicWord,misc2))
    end
end

function Debug.setEvAndCond(magicWord,formsTable,addrEffort)
    --struct2 ev&cond
    -- attEv u8
    -- defEv u8
    -- speEv u8
    -- spaEv u8
    -- spdEv u8
    -- cool u8
    -- beauty u8
    -- cute u8
    -- smart u8
    -- tough u8
    -- sheen u8
    
    --this is for if in the future we would like to write ev and such
end

function Debug.setAttacks(magicWord,formsTable,addrAttacks)
    -- struct1 attacks
    -- move1 u16
    -- move2 u16
    -- move3 u16
    -- move4 u16
    -- pp1 u8
    -- pp2 u8
    -- pp3 u8
    -- pp4 u8
    local magicWord1Byte = Utils.getbits(magicWord,0,8)
    local magicWord2Byte = Utils.getbits(magicWord,0,16)
    for i=1,3,2 do
        local moveChoice = forms.gettext(formsTable["move"..i])
        local moveChoice2 = forms.gettext(formsTable["move"..i + 1])
        if moveChoice ~= "Unchange" or moveChoice2 ~="Unchange" then
            local oldmoves = bit.bxor(Memory.readdword(addrAttacks + (i-1) *2),magicWord)
            local moveId = Utils.inlineIf(moveChoice == "Unchange",Utils.getbits(oldmoves,0,16) ,Debug.moveToId(moveChoice))
            local move2Id = Utils.inlineIf(moveChoice2 == "Unchange",Utils.getbits(oldmoves,16,16) ,Debug.moveToId(moveChoice2))
            local toWrite = bit.lshift(move2Id,16) + moveId
            Memory.writedword(addrAttacks + (i-1) * 2,bit.bxor(magicWord,toWrite)) --write move 2 moves because it easier this way with magicword
        end
    end
    Memory.writedword(addrAttacks+8,bit.bxor(magicWord,0xFFFFFFFF))
end

function Debug.moveToId(movename)
    local moveId = 0
    for idx,mov in pairs(MoveData.Moves) do
        if mov.name == movename then
            moveId = idx
            break
        end
    end
    return moveId
end

function Debug.setGrowth(magicWord,formsTable,addrGrowth)
    -- struct0 growth
    -- specie u16
    -- heldItem u16
    -- exp u32
    -- ppbonus u8
    -- frendship u8
    local magicWord2Byte = Utils.getbits(magicWord,0,16)
    local specieChoice = forms.gettext(formsTable["specie"])
    if  specieChoice ~= "Unchange" then
        local specieid =0
        for idx,poke in pairs(PokemonData.Pokemon) do
            if poke.name == specieChoice then
                specieid = idx
                break
            end
        end
        Memory.writeword(addrGrowth,bit.bxor(magicWord2Byte,specieid))
    end
end

function Debug.createDropDown(handle,text,x,y,options)
    forms.label(handle,text,x,y,40,15)
    local dropDown = forms.dropdown(handle,{"a"},x + 40,y)
    forms.setdropdownitems(dropDown,options,false)
    forms.setproperty(dropDown, "AutoCompleteSource", "ListItems")
	forms.setproperty(dropDown, "AutoCompleteMode", "Append")
    return dropDown
end

if GameSettings == nil then
    print("please load the tracker then reload the debug script")
else
    Debug.createEditPokeForm()
end

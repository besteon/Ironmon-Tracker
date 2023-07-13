Debug = {}

function Debug.createEditPokeForm()
	local form = forms.newform(200,250, "Edit Pokémon")
	forms.setproperty(form, "MinimizeBox", false)
	forms.setproperty(form, "MaximizeBox", false)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local property = "BlocksInputWhenFocused"
		if (forms.getproperty(form, property) or "") ~= "" then
			forms.setproperty(form, property, true)
		end
	end

	local y = 10
	local x = 10
	local pokedexData = {}
	table.insert(pokedexData, "Unchanged")
	for _, data in pairs(PokemonData.Pokemon) do
		if data.bst ~= Constants.BLANKLINE then
			table.insert(pokedexData, data.name)
		end
	end
	local allmovesData = {}
	table.insert(allmovesData, "Unchanged")
	table.insert(allmovesData,"None")
	for _, data in pairs(MoveData.Moves) do
		if data.name ~= Constants.BLANKLINE then
			table.insert(allmovesData, data.name)
		end
	end

	local species = Debug.createDropDown(form,"Species:",x,y,pokedexData)
	y = y + 25
	local move1 = Debug.createDropDown(form,"Move 1:",x,y,allmovesData)
	y = y + 25
	local move2 = Debug.createDropDown(form,"Move 2:",x,y,allmovesData)
	y = y + 25
	local move3 = Debug.createDropDown(form,"Move 3:",x,y,allmovesData)
	y = y + 25
	local move4 = Debug.createDropDown(form,"Move 4:",x,y,allmovesData)
	y = y + 25
	local partyNum = Debug.createDropDown(form,"Party #",x,y,{"1","2","3","4","5","6"})
	y = y + 25
	local ability = Debug.createDropDown(form,"Ability:",x,y,{"Unchanged","1","2"})
	local enemy = forms.checkbox(form,"Opponent",x+10,y+30)
	local formTable = {
		["mainForm"] = form,
		["species"] = species,
		["move1"] = move1,
		["move2"] = move2,
		["move3"] = move3,
		["move4"] = move4,
		["partyNum"] = partyNum,
		["ability"] = ability,
		["enemy"] = enemy
	}
	local setBtn = forms.button(form,"Set",
						function () Debug.setPokemonData(formTable) end,
						125,y+30,50,20
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
	local magicWord = Utils.bit_xor(personality,Memory.readdword(addr + 4))
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
		local val = Utils.bit_xor(magicWord,read)
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
	local abilityChoice = forms.gettext(formsTable["ability"])
	if abilityChoice ~= "Unchanged" then
		local misc2 = Utils.bit_xor(magicWord,Memory.readdword(addrMisc + 4))
		if abilityChoice == "1" then misc2 = Utils.bit_and(0x7FFFFFFF,misc2) -- clearing bit 31 ability bit
		else misc2 = Utils.bit_or(0x80000000,misc2) end -- setting bit 31 ability bit
		Memory.writedword(addrMisc + 4,Utils.bit_xor(magicWord,misc2))
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
		if moveChoice ~= "Unchanged" or moveChoice2 ~="Unchanged" then
			local oldmoves = Utils.bit_xor(Memory.readdword(addrAttacks + (i-1) *2),magicWord)
			local moveId = Utils.inlineIf(moveChoice == "Unchanged",Utils.getbits(oldmoves,0,16) ,Debug.moveToId(moveChoice))
			local move2Id = Utils.inlineIf(moveChoice2 == "Unchanged",Utils.getbits(oldmoves,16,16) ,Debug.moveToId(moveChoice2))
			local toWrite = Utils.bit_lshift(move2Id,16) + moveId
			Memory.writedword(addrAttacks + (i-1) * 2,Utils.bit_xor(magicWord,toWrite)) --write move 2 moves because it easier this way with magicword
		end
	end
	Memory.writedword(addrAttacks+8,Utils.bit_xor(magicWord,0xFFFFFFFF))
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
	-- species u16
	-- heldItem u16
	-- exp u32
	-- ppbonus u8
	-- frendship u8
	local magicWord2Byte = Utils.getbits(magicWord,0,16)
	local speciesChoice = forms.gettext(formsTable["species"])
	if  speciesChoice ~= "Unchanged" then
		local speciesid =0
		for idx,poke in pairs(PokemonData.Pokemon) do
			if poke.name == speciesChoice then
				speciesid = idx
				break
			end
		end
		Memory.writeword(addrGrowth,Utils.bit_xor(magicWord2Byte,speciesid))
	end
end

function Debug.createDropDown(handle,text,x,y,options)
	forms.label(handle,text,x,y,50,15)
	local dropDown = forms.dropdown(handle,{"a"},x + 50,y-4)
	forms.setdropdownitems(dropDown,options,false)
	forms.setproperty(dropDown, "AutoCompleteSource", "ListItems")
	forms.setproperty(dropDown, "AutoCompleteMode", "Append")
	return dropDown
end

if GameSettings == nil then
	print("Please load the tracker first, then load the debug script.")
else
	Debug.createEditPokeForm()
end

-- Continually reads section of Memory (inclusive) of 'size' bytes looking for changes, and outputting if a change occurs.
-- initialPrint: Always outputs first pass if true
function Debug.watchMemoryRange(startAddr, size, initialPrint)
	size = (size or 0) - 1
	if startAddr == nil or size < 0 then return end

	if Utils.prevAddrs == nil then
		Utils.prevAddrsMessage = ""
		Utils.prevAddrs = {}
	end

	local changedAddrMessage = ""

	local addrValues = {} -- table of: key=addr, value=val
	for i = startAddr, startAddr + size, 1 do
		addrValues[i] = Memory.readbyte(i)
		if Utils.prevAddrs[i] ~= addrValues[i] then
			changedAddrMessage = changedAddrMessage .. string.format("0x%x: %s\r\n", i, addrValues[i])
		end
	end

	if changedAddrMessage ~= "" and (initialPrint or #Utils.prevAddrs > 0) and Utils.prevAddrsMessage ~= changedAddrMessage then
		Utils.prevAddrsMessage = changedAddrMessage
		changedAddrMessage = changedAddrMessage .. "----- ----- ----- -----"
		print(changedAddrMessage)
	end

	Utils.prevAddrs = addrValues -- replace previous addresses and values with the new ones
end
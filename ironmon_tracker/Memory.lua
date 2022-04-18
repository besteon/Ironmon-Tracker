Memory = {}

function Memory.read(addr, size)
	mem = ""
	memdomain = bit.rshift(addr, 24)
	if memdomain == 0 then
		mem = "BIOS"
	elseif memdomain == 2 then
		mem = "EWRAM"
	elseif memdomain == 3 then
		mem = "IWRAM"
	elseif memdomain == 8 then
		mem = "ROM"
	end
	addr = bit.band(addr, 0xFFFFFF)
	if size == 1 then
		return memory.read_u8(addr,mem)
	elseif size == 2 then
		return memory.read_u16_le(addr,mem)
	elseif size == 3 then
		return memory.read_u24_le(addr,mem)
	else
		return memory.read_u32_le(addr,mem)
	end 
end

function Memory.readdword(addr)
	return Memory.read(addr, 4)
end

function Memory.readword(addr)
	return Memory.read(addr, 2)
end

function Memory.readbyte(addr)
	return Memory.read(addr, 1)
end
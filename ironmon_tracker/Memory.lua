Memory = {}

function Memory.read(addr, size)
	if addr == nil or addr <= 0x0 then
		print(debug.traceback())
		print("[ERROR] Unable to read game memory from unknown address.")
		return 0
	end

	local mem = ""
	local memdomain = bit.rshift(addr, 24)
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
		return memory.read_u8(addr, mem)
	elseif size == 2 then
		return memory.read_u16_le(addr, mem)
	elseif size == 3 then
		return memory.read_u24_le(addr, mem)
	else
		return memory.read_u32_le(addr, mem)
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

-- Unless absolutely necessary (looking at you fishing rods), do NOT write to memory
function Memory.write(addr, value, size)
	if addr == nil or addr <= 0x0 then
		print(debug.traceback())
		print("[ERROR] Unable to write to game memory using an unknown address.")
		return false
	end

	local mem = ""
	local memdomain = bit.rshift(addr, 24)
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
		return memory.write_u8(addr, value, mem)
	elseif size == 2 then
		return memory.write_u16_le(addr, value, mem)
	elseif size == 3 then
		return memory.write_u24_le(addr, value, mem)
	else
		return memory.write_u32_le(addr, value, mem)
	end
end

function Memory.writedword(addr, value)
	return Memory.write(addr, value, 4)
end

function Memory.writeword(addr, value)
	return Memory.write(addr, value, 2)
end

function Memory.writebyte(addr, value)
	return Memory.write(addr, value, 1)
end
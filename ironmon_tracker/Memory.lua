Memory = {}

function Memory.initialize()
	if Main.IsOnBizhawk() then
		Memory.read8 = function(addr)
			local a, m = Memory.splitDomainAndAddress(addr)
			---@diagnostic disable-next-line: undefined-global
			return memory.read_u8(a, m)
		end
		Memory.read16 = function(addr)
			local a, m = Memory.splitDomainAndAddress(addr)
			---@diagnostic disable-next-line: undefined-global
			return memory.read_u16_le(a, m)
		end
		Memory.read32 = function(addr)
			local a, m = Memory.splitDomainAndAddress(addr)
			---@diagnostic disable-next-line: undefined-global
			return memory.read_u32_le(a, m)
		end
		Memory.write8 = function(addr, value)
			local a, m = Memory.splitDomainAndAddress(addr)
			---@diagnostic disable-next-line: undefined-global
			return memory.write_u8(a, value, m)
		end
		Memory.write16 = function(addr, value)
			local a, m = Memory.splitDomainAndAddress(addr)
			---@diagnostic disable-next-line: undefined-global
			return memory.write_u16_le(a, value, m)
		end
		Memory.write32 = function(addr, value)
			local a, m = Memory.splitDomainAndAddress(addr)
			---@diagnostic disable-next-line: undefined-global
			return memory.write_u32_le(a, value, m)
		end
	else
		---@diagnostic disable-next-line: undefined-global
		Memory.read8 = function(addr) return emu:read8(addr) end
		---@diagnostic disable-next-line: undefined-global
		Memory.read16 = function(addr) return emu:read16(addr) end
		---@diagnostic disable-next-line: undefined-global
		Memory.read32 = function(addr) return emu:read32(addr) end
		---@diagnostic disable-next-line: undefined-global
		Memory.write8 = function(addr, value) return emu:write8(addr, value) end
		---@diagnostic disable-next-line: undefined-global
		Memory.write16 = function(addr, value) return emu:write16(addr, value) end
		---@diagnostic disable-next-line: undefined-global
		Memory.write32 = function(addr, value) return emu:write32(addr, value) end
	end
end

function Memory.splitDomainAndAddress(addr)
	local memdomain = Utils.bit_rshift(addr, 24)
	local splitaddr = Utils.bit_and(addr, 0xFFFFFF)
	if memdomain == 0 then
		return "BIOS", splitaddr
	elseif memdomain == 2 then
		return "EWRAM", splitaddr
	elseif memdomain == 3 then
		return "IWRAM", splitaddr
	elseif memdomain == 8 then
		return "ROM", splitaddr
	end
end

function Memory.read(addr, numbytes)
	if addr == nil or addr <= 0x0 then
		print(debug.traceback())
		print("[ERROR] Unable to read game memory from unknown address.")
		return 0
	end

	if numbytes == 1 then
		return Memory.read8(addr)
	elseif numbytes == 2 then
		return Memory.read16(addr)
	else
		return Memory.read32(addr)
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
function Memory.write(addr, value, numbytes)
	if addr == nil or addr <= 0x0 then
		print(debug.traceback())
		print("[ERROR] Unable to write to game memory using an unknown address.")
		return false
	end

	if numbytes == 1 then
		return Memory.write8(addr, value)
	elseif numbytes == 2 then
		return Memory.write16(addr, value)
	else
		return Memory.write32(addr, value)
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
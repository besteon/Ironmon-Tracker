---@diagnostic disable: duplicate-set-field
Memory = {}

function Memory.initialize()
	if Memory.hasInitialized then return end
	-- Define how to read/write memory from the game depending on which emulator is in use
	if Main.IsOnBizhawk() then
		Memory.read8 = function(addr)
			local m, a = Memory.splitDomainAndAddress(addr)
			return memory.read_u8(a, m)
		end
		Memory.read16 = function(addr)
			local m, a = Memory.splitDomainAndAddress(addr)
			return memory.read_u16_le(a, m)
		end
		Memory.read32 = function(addr)
			local m, a = Memory.splitDomainAndAddress(addr)
			return memory.read_u32_le(a, m)
		end
		Memory.write8 = function(addr, value)
			local m, a = Memory.splitDomainAndAddress(addr)
			return memory.write_u8(a, value, m)
		end
		Memory.write16 = function(addr, value)
			local m, a = Memory.splitDomainAndAddress(addr)
			return memory.write_u16_le(a, value, m)
		end
		Memory.write32 = function(addr, value)
			local m, a = Memory.splitDomainAndAddress(addr)
			return memory.write_u32_le(a, value, m)
		end
	else
		Memory.read8 = function(addr)
			return emu:read8(addr)
		end
		Memory.read16 = function(addr)
			return Memory.read8(addr) + Utils.bit_lshift(Memory.read8(addr + 0x01), 8)
		end
		Memory.read32 = function(addr)
			return Memory.read16(addr) + Utils.bit_lshift(Memory.read16(addr + 0x02), 16)
		end
		Memory.write8 = function(addr, value) return emu:write8(addr, value) end
		Memory.write16 = function(addr, value) return emu:write16(addr, value) end
		Memory.write32 = function(addr, value) return emu:write32(addr, value) end
	end
	Memory.hasInitialized = true
end

function Memory.readbyte(addr)
	return Memory.read8(addr)
end
function Memory.readword(addr)
	return Memory.read16(addr)
end
function Memory.readdword(addr)
	return Memory.read32(addr)
end

-- Unless absolutely necessary, the Tracker must NOT write to memory
function Memory.writebyte(addr, value)
	return Memory.write8(addr, value)
end
function Memory.writeword(addr, value)
	return Memory.write16(addr, value)
end
function Memory.writedword(addr, value)
	return Memory.write32(addr, value)
end

-- Splits the address into [Memory Domain], [Remaining Addr]
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
	return nil, addr
end

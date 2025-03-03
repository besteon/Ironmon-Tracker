-- Used for packing/unpacking data into binary, as well as base64 encoding/decoding that data into a sharable string
StructEncoder = {}

--[[
 * Copyright (c) 2015-2020 Iryont <https://github.com/iryont/lua-struct>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
]]

---@diagnostic disable-next-line: deprecated
StructEncoder.unpackTable = table.unpack or _G.unpack

--[[
PACK FORMAT AVAILABLE TYPES
"b" a signed char.
"B" an unsigned char.
"h" a signed short (2 bytes).
"H" an unsigned short (2 bytes).
"i" a signed int (4 bytes).
"I" an unsigned int (4 bytes).
"l" a signed long (8 bytes).
"L" an unsigned long (8 bytes).
"f" a float (4 bytes).
"d" a double (8 bytes).
"s" a zero-terminated string.
"cn" a sequence of exactly n chars corresponding to a single Lua string (if n <= 0 then for packing - the string length is taken, unpacking - the number value of the previous unpacked value which is not returned).
]]
function StructEncoder.binaryPack(format, ...)
	local stream = {}
	local vars = {...}
	local endianness = true

	for i = 1, format:len() do
		local opt = format:sub(i, i)

		if opt == '<' then
			endianness = true
		elseif opt == '>' then
			endianness = false
		elseif opt:find('[bBhHiIlL]') then
			local n = opt:find('[hH]') and 2 or opt:find('[iI]') and 4 or opt:find('[lL]') and 8 or 1
			local val = tonumber(table.remove(vars, 1))

			local bytes = {}
			for j = 1, n do
				table.insert(bytes, string.char(val % (2 ^ 8)))
				val = math.floor(val / (2 ^ 8))
			end

			if not endianness then
				table.insert(stream, string.reverse(table.concat(bytes)))
			else
				table.insert(stream, table.concat(bytes))
			end
		elseif opt:find('[fd]') then
			local val = tonumber(table.remove(vars, 1))
			local sign = 0

			if val < 0 then
				sign = 1
				val = -val
			end

			---@diagnostic disable-next-line: param-type-mismatch
			local mantissa, exponent = math.frexp(val)
			if val == 0 then
				mantissa = 0
				exponent = 0
			else
				mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, (opt == 'd') and 53 or 24)
				exponent = exponent + ((opt == 'd') and 1022 or 126)
			end

			local bytes = {}
			if opt == 'd' then
				val = mantissa
				for j = 1, 6 do
					table.insert(bytes, string.char(math.floor(val) % (2 ^ 8)))
					val = math.floor(val / (2 ^ 8))
				end
			else
				table.insert(bytes, string.char(math.floor(mantissa) % (2 ^ 8)))
				val = math.floor(mantissa / (2 ^ 8))
				table.insert(bytes, string.char(math.floor(val) % (2 ^ 8)))
				val = math.floor(val / (2 ^ 8))
			end

			table.insert(bytes, string.char(math.floor(exponent * ((opt == 'd') and 16 or 128) + val) % (2 ^ 8)))
			val = math.floor((exponent * ((opt == 'd') and 16 or 128) + val) / (2 ^ 8))
			table.insert(bytes, string.char(math.floor(sign * 128 + val) % (2 ^ 8)))
			val = math.floor((sign * 128 + val) / (2 ^ 8))

			if not endianness then
				table.insert(stream, string.reverse(table.concat(bytes)))
			else
				table.insert(stream, table.concat(bytes))
			end
		elseif opt == 's' then
			table.insert(stream, tostring(table.remove(vars, 1)))
			table.insert(stream, string.char(0))
		elseif opt == 'c' then
			local n = format:sub(i + 1):match('%d+')
			local str = tostring(table.remove(vars, 1))
			local len = tonumber(n)
			if len <= 0 then
				len = str:len()
			end
			if len - str:len() > 0 then
				str = str .. string.rep(' ', len - str:len())
			end
			table.insert(stream, str:sub(1, len))
			i = i + n:len()
		end
	end

	return table.concat(stream)
end

function StructEncoder.binaryUnpack(format, stream, pos)
	local vars = {}
	local iterator = pos or 1
	local endianness = true

	for i = 1, format:len() do
		local opt = format:sub(i, i)

		if opt == '<' then
			endianness = true
		elseif opt == '>' then
			endianness = false
		elseif opt:find('[bBhHiIlL]') then
			local n = opt:find('[hH]') and 2 or opt:find('[iI]') and 4 or opt:find('[lL]') and 8 or 1
			local signed = opt:lower() == opt

			local val = 0
			for j = 1, n do
				local byte = string.byte(stream:sub(iterator, iterator))
				if endianness then
					val = val + byte * (2 ^ ((j - 1) * 8))
				else
					val = val + byte * (2 ^ ((n - j) * 8))
				end
				iterator = iterator + 1
			end

			if signed and val >= 2 ^ (n * 8 - 1) then
				val = val - 2 ^ (n * 8)
			end

			table.insert(vars, math.floor(val))
		elseif opt:find('[fd]') then
			local n = (opt == 'd') and 8 or 4
			local x = stream:sub(iterator, iterator + n - 1)
			iterator = iterator + n

			if not endianness then
				x = string.reverse(x)
			end

			local sign = 1
			local mantissa = string.byte(x, (opt == 'd') and 7 or 3) % ((opt == 'd') and 16 or 128)
			for j = n - 2, 1, -1 do
				mantissa = mantissa * (2 ^ 8) + string.byte(x, j)
			end

			if string.byte(x, n) > 127 then
				sign = -1
			end

			local exponent = (string.byte(x, n) % 128) * ((opt == 'd') and 16 or 2) + math.floor(string.byte(x, n - 1) / ((opt == 'd') and 16 or 128))
			if exponent == 0 then
				table.insert(vars, 0.0)
			else
				mantissa = (math.ldexp(mantissa, (opt == 'd') and -52 or -23) + 1) * sign
				table.insert(vars, math.ldexp(mantissa, exponent - ((opt == 'd') and 1023 or 127)))
			end
		elseif opt == 's' then
			local bytes = {}
			for j = iterator, stream:len() do
				if stream:sub(j,j) == string.char(0) or  stream:sub(j) == '' then
					break
				end

				table.insert(bytes, stream:sub(j, j))
			end

			local str = table.concat(bytes)
			iterator = iterator + str:len() + 1
			table.insert(vars, str)
		elseif opt == 'c' then
			local n = format:sub(i + 1):match('%d+')
			local len = tonumber(n)
			if len <= 0 then
				len = table.remove(vars)
			end

			table.insert(vars, stream:sub(iterator, iterator + len - 1))
			iterator = iterator + len
			i = i + n:len()
		end
	end

	return StructEncoder.unpackTable(vars)
end

--[[
base64 -- v1.5.3 public domain Lua base64 encoder/decoder
no warranty implied; use at your own risk

Needs bit32.extract function. If not present it's implemented using BitOp
or Lua 5.3 native bit operators. For Lua 5.1 fallbacks to pure Lua
implementation inspired by Rici Lake's post:
http://ricilake.blogspot.co.uk/2007/10/iterating-bits-in-lua.html

author: Ilya Kolbin (iskolbin@gmail.com)
url: github.com/iskolbin/lbase64

COMPATIBILITY
Lua 5.1+, LuaJIT

LICENSE
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2018 Ilya Kolbin
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
--]]

local function _getCompatibleExtractFunc()
	---@diagnostic disable-next-line: undefined-field
	local extract = _G.bit32 and _G.bit32.extract -- Lua 5.2/Lua 5.3 in compatibility mode
	if not extract then
		---@diagnostic disable-next-line: undefined-field
		-- if _G.bit then -- LuaJIT (NOT SUPPORTED OR NEEDED)
		-- 	---@diagnostic disable-next-line: undefined-field
		-- 	local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
		-- 	extract = function( v, from, width )
		-- 		return band( shr( v, from ), shl( 1, width ) - 1 )
		-- 	end
		-- elseif _G._VERSION == "Lua 5.1" then
		if _G._VERSION == "Lua 5.1" then
			extract = function( v, from, width )
				local w = 0
				local flag = 2^from
				for i = 0, width-1 do
					local flag2 = flag + flag
					if v % flag2 >= flag then
						w = w + 2^i
					end
					flag = flag2
				end
				return w
			end
		else -- Lua 5.3+
			---@diagnostic disable-next-line: param-type-mismatch
			extract = load[[return function( v, from, width )
				return ( v >> from ) & ((1 << width) - 1)
			end]]()
		end
	end
	return extract
end

StructEncoder.extract = _getCompatibleExtractFunc()

---Default encoder uses [A-Za-z0-9+/=]
function StructEncoder.makeEncoder(s62, s63, spad)
	local encoder = {}
	for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
		'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
		'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
		'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
		'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
		encoder[b64code] = char:byte()
	end
	return encoder
end

function StructEncoder.makeDecoder(s62, s63, spad)
	local decoder = {}
	for b64code, charcode in pairs( StructEncoder.makeEncoder( s62, s63, spad )) do
		decoder[charcode] = b64code
	end
	return decoder
end

StructEncoder.DEFAULT_ENCODER = StructEncoder.makeEncoder()
StructEncoder.DEFAULT_DECODER = StructEncoder.makeDecoder()

---@param str string
---@param encoder? table StructEncoder.makeEncoder()
---@param usecaching? boolean Optional, defaults to false
---@return string
function StructEncoder.encodeBase64(str, encoder, usecaching)
	encoder = encoder or StructEncoder.DEFAULT_ENCODER
	local char, concat, extract = string.char, table.concat, StructEncoder.extract
	local t, k, n = {}, 1, #str
	local lastn = n % 3
	local cache = {}
	for i = 1, n-lastn, 3 do
		local a, b, c = str:byte( i, i+2 )
		local v = a*0x10000 + b*0x100 + c
		local s
		if usecaching then
			s = cache[v]
			if not s then
				s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
				cache[v] = s
			end
		else
			s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
		end
		t[k] = s
		k = k + 1
	end
	if lastn == 2 then
		local a, b = str:byte( n-1, n )
		local v = a*0x10000 + b*0x100
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
	elseif lastn == 1 then
		local v = str:byte( n )*0x10000
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
	end
	return concat( t )
end

---@param b64string string
---@param decoder? table StructEncoder.makeDecoder()
---@param usecaching? boolean Optional, defaults to false
---@return string
function StructEncoder.decodeBase64(b64string, decoder, usecaching)
	decoder = decoder or StructEncoder.DEFAULT_DECODER
	local char, concat, extract = string.char, table.concat, StructEncoder.extract
	local pattern = '[^%w%+%/%=]'
	if decoder then
		local s62, s63
		for charcode, b64code in pairs( decoder ) do
			if b64code == 62 then s62 = charcode
			elseif b64code == 63 then s63 = charcode
			end
		end
		pattern = ('[^%%w%%%s%%%s%%=]'):format( char(s62), char(s63) )
	end
	b64string = b64string:gsub( pattern, '' )
	local cache = usecaching and {}
	local t, k = {}, 1
	local n = #b64string
	local padding = b64string:sub(-2) == '==' and 2 or b64string:sub(-1) == '=' and 1 or 0
	for i = 1, padding > 0 and n-4 or n, 4 do
		local a, b, c, d = b64string:byte( i, i+3 )
		local s
		if usecaching and cache then
			local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
			s = cache[v0]
			if not s then
				local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
				s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
				cache[v0] = s
			end
		else
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
			s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
		end
		t[k] = s
		k = k + 1
	end
	if padding == 1 then
		local a, b, c = b64string:byte( n-3, n-1 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
		t[k] = char( extract(v,16,8), extract(v,8,8))
	elseif padding == 2 then
		local a, b = b64string:byte( n-3, n-2 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000
		t[k] = char( extract(v,16,8))
	end
	return concat( t )
end
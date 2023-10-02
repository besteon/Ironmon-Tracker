----------------------------------------------
-- Pickle.lua
-- A table serialization utility for lua
-- Steve Dekorte, http://www.dekorte.com, Apr 2000
-- Freeware
----------------------------------------------

Pickle = {
	clone = function(t) local nt = {}; for i, v in pairs(t) do nt[i] = v end return nt end
}

function Pickle.pickle(t)
	return Pickle:clone():pickle_(t)
end

function Pickle:pickle_(root)
	if type(root) ~= "table" then
		error("can only pickle tables, not " .. type(root) .. "s")
	end
	self._tableToRef = {}
	self._refToTable = {}
	local savecount = 0
	self:ref_(root)
	local s = ""

	while #self._refToTable > savecount do
		savecount = savecount + 1
		local t = self._refToTable[savecount]
		s = s .. "{"
		for i, v in pairs(t) do
			s = string.format("%s[%s]=%s,", s, self:value_(i), self:value_(v))
		end
		s = s .. "},"
	end

	return string.format("{%s}", s)
end

function Pickle:value_(v)
	local vtype = type(v)
	if vtype == "string" then return string.format("%q", v)
	elseif vtype == "number" then return v
	elseif vtype == "boolean" then return tostring(v)
	elseif vtype == "table" then return "{" .. self:ref_(v) .. "}"
	--else error("pickle a "..type(v).." is not supported")
	end
end

function Pickle:ref_(t)
	local ref = self._tableToRef[t]
	if not ref then
		if t == self then error("can't pickle the pickle class") end
		table.insert(self._refToTable, t)
		ref = #self._refToTable
		self._tableToRef[t] = ref
	end
	return ref
end

----------------------------------------------
-- unpickle
----------------------------------------------

function Pickle.unpickle(s)
	if type(s) ~= "string" then
		error("can't unpickle a " .. type(s) .. ", only strings")
	end
	local datastringToLoad = "return " .. s

	local gentables
	if Main.emulator == Main.EMU.BIZHAWK28 then
		-- Using 'loadstring' over 'load' because Bizhawk 2.8 runs on Lua 5.1
		---@diagnostic disable-next-line: deprecated
		gentables = loadstring(datastringToLoad)
	else
		--- mGBA runs on Lua 5.4
		---@diagnostic disable-next-line: param-type-mismatch
		gentables = load(datastringToLoad) --, nil, "t")
	end

	-- Check if the data in the file is not in the form of Lua code
	if gentables == nil or gentables == "" then
		return nil
	end

	local tables = gentables()

	for tnum = 1, #tables do
		local t = tables[tnum]
		local tcopy = {};
		for i, v in pairs(t) do tcopy[i] = v end
		for i, v in pairs(tcopy) do
			local ni, nv
			if type(i) == "table" then ni = tables[i[1]] else ni = i end
			if type(v) == "table" then nv = tables[v[1]] else nv = v end
			t[i] = nil
			t[ni] = nv
		end
	end
	return tables[1]
end

GachaMonAnimations = {
	ActiveAnimations = {},
}

function GachaMonAnimations.initialize()
	GachaMonAnimations.ActiveAnimations = {}
end

---comment
---@return boolean
function GachaMonAnimations.anyActive()
	return #GachaMonAnimations.ActiveAnimations > 0
end

function GachaMonAnimations.stepFrames()
	if not GachaMonAnimations.anyActive() then
		return
	end
	local toRemove = {}
	for _, framecounter in ipairs(GachaMonAnimations.ActiveAnimations or {}) do
		-- if type(framecounter.step) == "function" then
		-- 	framecounter:step()
		-- end
		-- if framecounter.finished then
		-- 	table.insert(toRemove, index)
		-- end
	end
	-- for _, index in ipairs(toRemove) do
	-- 	table.remove(GachaMonAnimations.ActiveAnimations, index)
	-- end
end
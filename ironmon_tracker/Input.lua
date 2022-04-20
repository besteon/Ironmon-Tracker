Input = {
	mousetab = {},
	mousetab_prev = {},
	joypad = {}
}

function Input.update()
	Input.mousetab = input.getmouse()
	if Input.mousetab["Left"] and not Input.mousetab_prev["Left"] then
		local xmouse = Input.mousetab["X"]
		local ymouse = Input.mousetab["Y"] + GraphicConstants.UP_GAP
		Input.check(xmouse, ymouse)
	end
	Input.mousetab_prev = Input.mousetab

	local joypadButtons = joypad.get()
	-- "Select" pressed
	if joypadButtons.Select == true and Input.joypad.Select ~= joypadButtons.Select then
		if Tracker.Data.inBattle == 1 then
			Tracker.Data.player = (Tracker.Data.player % 2) + 1
			if Tracker.Data.player == 1 then
				Tracker.Data.slot = 1
			elseif Tracker.Data.player == 2 then
				local enemySlotOne = Memory.readbyte(GameSettings.gBattlerPartyIndexesEnemySlotOne) + 1
				Tracker.Data.slot = enemySlotOne
			end
		end
	end
	Input.joypad = joypadButtons
end

function Input.check(xmouse, ymouse)
	for i = 1, table.getn(Buttons), 1 do
		if Buttons[i].visible() then
			if Buttons[i].type == ButtonType.singleButton then
				if Input.isInRange(xmouse, ymouse, Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4]) then
					Buttons[i].onclick()
				end
			end
		end
	end	
end

function Input.isInRange(xmouse,ymouse,x,y,xregion,yregion)
	if xmouse >= x and xmouse <= x + xregion then
		if ymouse >= y and ymouse <= y + yregion then
			return true
		end
	end
	return false
end
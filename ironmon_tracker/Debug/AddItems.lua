AddItems = {}

function AddItems.createAddItemForm()
	local y = 15
	local x = 10
	local itemData = {}
	table.insert(itemData, Constants.BLANKLINE)
	for _, item in pairs(MiscData.Items) do
		if item ~= "unknown" then
			table.insert(itemData, item)
		end
	end

	local form = forms.newform(170, 115, "Add Items")
	forms.setproperty(form, "MinimizeBox", false)
	forms.setproperty(form, "MaximizeBox", false)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local property = "BlocksInputWhenFocused"
		if not Utils.isNilOrEmpty(forms.getproperty(form, property)) then
			forms.setproperty(form, property, true)
		end
	end

	local item = AddItems.createDropDown(form, "Item:", x, y, itemData)
	y = y + 35
	local quantity = AddItems.createNumericTextBox(form, "Quantity:", x, y, 2)
	local formTable = {
		["mainForm"] = form,
		["item"] = item,
		["quantity"] = quantity,
	}
	local addBtn = forms.button(form,"Add",
		function () AddItems.addItem(formTable) end,
		101, y - 2, 50, 20
	)
	return formTable
end

function AddItems.createDropDown(handle, text, x, y, options)
	local labelWidth = 30
	forms.label(handle, text, x, y, labelWidth, 15)
	local dropDown = forms.dropdown(handle, {"a"}, x + labelWidth, y - 3, 110, 20)
	forms.setdropdownitems(dropDown, options, false)
	forms.setproperty(dropDown, "AutoCompleteSource", "ListItems")
	forms.setproperty(dropDown, "AutoCompleteMode", "Append")
	return dropDown
end

function AddItems.createNumericTextBox(handle, text, x, y, digits)
	-- Creates a text box with input limited to positive integers of defined digits
	local labelWidth = 50
	forms.label(handle, text, x, y, labelWidth, 15)
	local textBox = forms.textbox(handle, "1", 30, 15, "UNSIGNED", x + labelWidth, y - 2)
	forms.setproperty(textBox, "MaxLength", digits)
	return textBox
end

function AddItems.getItemId(itemName)
	if itemName == Constants.BLANKLINE then return 0 end
	for id, item in pairs(MiscData.Items) do
		if item == itemName then
			return id
		end
	end
	return 0
end

function AddItems.getBagPocketData(id)
	-- Returns: Offset for bag pocket, capacity of bag pocket, whether to limit quantity to 1
	local gameNumber = GameSettings.game
	local itemsOffset = GameSettings.bagPocket_Items_offset
	local keyItemsOffset = {0x5B0, 0x5D8, 0x03b8}
	local pokeballsOffset = {0x600, 0x650, 0x0430}
	local TMHMOffset = {0x640, 0x690, 0x0464}
	local berriesOffset = GameSettings.bagPocket_Berries_offset

	local itemsCapacity = GameSettings.bagPocket_Items_Size
	local keyItemsCapacity = {20, 30, 30}
	local pokeballsCapacity = {16, 16, 13}
	local TMHMCapacity = {64, 64, 58}
	local berriesCapacity = GameSettings.bagPocket_Berries_Size

	if id < 1 then
		return nil
	elseif id <= 12--[[Premier Ball]] then
		return pokeballsOffset[gameNumber], pokeballsCapacity[gameNumber], false
	elseif id <= 132--[[Retro Mail]] or (id >= 179--[[Bright Powder]] and id <= 258--[[Yellow Scarf]]) then
		return itemsOffset, itemsCapacity, false
	elseif id <= 175--[[Enigma Berry]] then
		return berriesOffset, berriesCapacity, false
	elseif id <= 288--[[Devon Scope]] or (id >= 349--[[Oak's Parcel]] and id <= 376--[[Old Sea Map]]) then
		return keyItemsOffset[gameNumber], keyItemsCapacity[gameNumber], true
	elseif id <= 338--[[TM50]] then
		return TMHMOffset[gameNumber], TMHMCapacity[gameNumber], false
	elseif id <= 346--[[HM08]] then
		return TMHMOffset[gameNumber], TMHMCapacity[gameNumber], true
	end
	return nil
end

function AddItems.addItem(formsTable)
	local itemChoice = forms.gettext(formsTable["item"])
	local quantity = tonumber(forms.gettext(formsTable["quantity"]))
	if itemChoice == Constants.BLANKLINE or quantity == nil or quantity == 0 then return false end

	local itemID = AddItems.getItemId(itemChoice)
	local bagPocketOffset, bagPocketCapacity, limitQuantity = AddItems.getBagPocketData(itemID)
	if bagPocketOffset == nil then return false end

	-- Limit quantity for key items / HMs, don't think it breaks if larger quantity but just in case
	if limitQuantity then quantity = 1 end
	print("Adding " .. itemChoice .. " x" .. quantity)

	-- Add items to the last slot in the bag to minimise overwriting existing items
	local bagPocketSlot = (bagPocketCapacity - 1) * 4
	local address = Utils.getSaveBlock1Addr()
	address = address + bagPocketOffset + bagPocketSlot
	local key = Utils.getEncryptionKey(2)
	if key ~= nil then quantity = Utils.bit_xor(quantity, key) end

	Memory.writeword(address, itemID)
	Memory.writeword(address + 2, quantity)

	print(itemChoice .. " added to bag")
end

function AddItems.DisplayUsage()
	local form = Utils.createBizhawkForm("[v" .. Main.TrackerVersion .. "] Add Items Utility", 400, 150)
	forms.setproperty(form, "MinimizeBox", false)
	forms.setproperty(form, "MaximizeBox", false)
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local property = "BlocksInputWhenFocused"
		if not Utils.isNilOrEmpty(forms.getproperty(form, property)) then
			forms.setproperty(form, property, true)
		end
	end

	local actualLocation = client.transformPoint(100, 50)
	forms.setproperty(form, "Left", client.xpos() + actualLocation['x'] )
	forms.setproperty(form, "Top", client.ypos() + actualLocation['y'] + 64) -- so we are below the ribbon menu

	local usageText = "Welcome to the Add Items tool!\nTo use: simply specify an item/quantity and click the \"Add\" button.\n\nIt is HIGHLY recommended to make a savestate to act as a restore point before adding any items (particularly key items), just in case."
	forms.label(form, usageText, 18, 10, 350, 65)
	forms.button(form, "Close", function()
		Utils.closeBizhawkForm(form)
	end, 155, 85)
end

if GameSettings == nil then
	print("Please load the tracker first, then load the AddItems script.")
else
	AddItems.DisplayUsage()
	AddItems.createAddItemForm()
end

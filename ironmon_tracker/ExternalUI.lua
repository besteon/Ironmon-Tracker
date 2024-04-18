-- Defines all ways to interact with an emulator's external UI components, such as form popups
ExternalUI = {}

ExternalUI.BizForms = {
	-- The current active form popup window; only 1 can be open at any given time
	ActiveFormId = 0,

	-- Options to modify form control elements; usually these values remain unmodified
	AUTO_SIZE_CONTROLS = true,

	Properties = {
		AUTO_SIZE = "AutoSize", -- For most form elements
		BLOCK_INPUT = "BlocksInputWhenFocused", -- For the main form popup
		AUTO_COMPLETE_SOURCE = "AutoCompleteSource", -- For dropdown boxes
		AUTO_COMPLETE_MODE = "AutoCompleteMode", -- For dropdown boxes
	},
}

---Creates a form popup through Bizhawk Lua function
---@param title string?
---@param width number?
---@param height number?
---@param x number?
---@param y number?
---@param onCloseFunc function?
---@param blockInput boolean?
---@return table|nil form An IBizhawkForm object representing the created form; or nil if can't create
function ExternalUI.createBizhawkForm(title, width, height, x, y, onCloseFunc, blockInput)
	if not Main.IsOnBizhawk() then
		return nil
	end

	-- Close the active form popup that's currently open, if any (only one at a time allowed to be open)
	ExternalUI.closeBizhawkForm()

	-- Disable mouse inputs on the emulator window until the form is closed
	Input.allowMouse = false
	Input.resumeMouse = false

	-- Prepare the form to be created, defining defaults
	local form = ExternalUI.IBizhawkForm:new({
		Title = title, Width = width, Height = height, X = x, Y = y,
		BlockInput = (blockInput ~= false),
		OnCloseFunc = onCloseFunc,
	})

	local function safelyCloseForm()
		Input.resumeMouse = true
		client.unpause()
		if not form then
			return
		end
		if type(form.OnCloseFunc) == "function" then
			form:OnCloseFunc()
		end
		ExternalUI.closeBizhawkForm(form)
		if form.ControlId then
			forms.destroy(form.ControlId)
			if ExternalUI.BizForms.ActiveFormId == form.ControlId then
				ExternalUI.BizForms.ActiveFormId = 0
			end
		end
	end

	-- Create the form through Bizhawk
	form.ControlId = forms.newform(form.Width, form.Height, form.Title, safelyCloseForm)

	-- Remember this form, and apply any other adjustments like screen centering
	ExternalUI.BizForms.ActiveFormId = form.ControlId
	Utils.setFormLocation(form.ControlId, form.X, form.Y)

	-- A workaround for a bug for release candidate builds of Bizhawk 2.9
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local currentPropVal = forms.getproperty(form.ControlId, ExternalUI.BizForms.Properties.BLOCK_INPUT)
		if not Utils.isNilOrEmpty(currentPropVal) then
			forms.setproperty(form.ControlId, ExternalUI.BizForms.Properties.BLOCK_INPUT, form.BlockInput)
		end
	end

	return form
end

---Safely closes a specific form, or the active open form popup if none provided
---@param formOrId table|number|nil
function ExternalUI.closeBizhawkForm(formOrId)
	if not Main.IsOnBizhawk() then return end
	formOrId = formOrId or {}
	local controlId = (type(formOrId) == "table" and formOrId.ControlId) or formOrId or ExternalUI.BizForms.ActiveFormId
	Input.resumeMouse = true
	client.unpause()
	if (controlId or 0) ~= 0 then
		forms.destroy(controlId)
	end
	ExternalUI.BizForms.ActiveFormId = 0
end

--- HELPER FUNCTIONS
local _helper = {}

function _helper.tryAutoSize(controlId, width, height)
	if ExternalUI.BizForms.AUTO_SIZE_CONTROLS and not width and not height then
		forms.setproperty(controlId, ExternalUI.BizForms.Properties.AUTO_SIZE, true)
	end
end

--- BIZHAWK FORM OBJECT

ExternalUI.IBizhawkForm = {
	-- This value is set after the form is created; do not define it yourself
	ControlId = 0,
	-- Optional code to run when the form is closed
	OnCloseFunc = function() end,

	-- After the Bizhawk form itself is created, the following attributes cannot be changed
	Title = "Tracker Form",
	X = 100,
	Y = 50,
	Width = 600,
	Height = 600,
	BlockInput = true, -- Disable mouse inputs on the emulator window until the form is closed

	---Creates a Button Control element for a Bizhawk form, returning the id of the created control
	---@param text string
	---@param clickFunc function
	---@param x number
	---@param y number
	---@param width number? Optional
	---@param height number? Optional
	---@return number|nil controlId
	createButton = function(self, text, clickFunc, x, y, width, height)
		local controlId = forms.button(self.ControlId, text, clickFunc, x, y, width, height)
		_helper.tryAutoSize(controlId, width, height)
		return controlId
	end,

	---Creates a Checkbox Control element for a Bizhawk form, returning the id of the created control
	---@param text string
	---@param x number
	---@param y number
	---@param clickFunc function? Optional, note that most checkboxes do not need a click func
	---@return number|nil controlId
	createCheckbox = function(self, text, x, y, clickFunc)
		local controlId = forms.checkbox(self.ControlId, text, x, y)
		_helper.tryAutoSize(controlId)
		if type(clickFunc) == "function" then
			forms.addclick(controlId, clickFunc)
		end
		return controlId
	end,

	---Creates a Dropdown Control element for a Bizhawk form, returning the id of the created control
	---@param itemList table An ordered list of values (ideally strings)
	---@param x number
	---@param y number
	---@param width number?
	---@param height number?
	---@param startItem string?
	---@param sortAlphabetically boolean?
	---@return number|nil controlId
	createDropdown = function(self, itemList, x, y, width, height, startItem, sortAlphabetically)
		sortAlphabetically = (sortAlphabetically ~= false) -- default to true
		local controlId = forms.dropdown(self.ControlId, {["Init"]="..."}, x, y, width, height)
		forms.setdropdownitems(controlId, itemList, sortAlphabetically)
		forms.setproperty(controlId, ExternalUI.BizForms.Properties.AUTO_COMPLETE_SOURCE, "ListItems")
		forms.setproperty(controlId, ExternalUI.BizForms.Properties.AUTO_COMPLETE_MODE, "Append")
		if startItem then
			forms.settext(controlId, startItem)
		end
		_helper.tryAutoSize(controlId, width, height)
		return controlId
	end,
}
---Creates and returns a new IBizhawkForm object; use UIControls.createBizhawkForm instead of calling this directly
---@param o? table Optional initial object table
---@return table form An IBizhawkForm object
function ExternalUI.IBizhawkForm:new(o)
	o = o or {}
	for k, v in pairs(ExternalUI.IBizhawkForm) do
		if o[k] == nil then
			o[k] = v
		end
	end
	setmetatable(o, self)
	self.__index = self
	return o
end

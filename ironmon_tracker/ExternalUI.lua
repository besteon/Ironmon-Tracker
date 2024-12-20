-- Defines all ways to interact with an emulator's external UI components, such as form popups
ExternalUI = {}

-- Contains information related to Bizhawk forms (the popup windows)
ExternalUI.BizForms = {
	-- The current active form popup window; only 1 can be open at any given time
	ActiveFormId = 0,

	-- Options to modify form control elements; usually don't change these
	AUTO_SIZE_CONTROLS = true,

	-- Enum representing the different types of controls that can be created for a form
	ControlTypes = {
		Button = 1, Checkbox = 2, Dropdown = 3, Label = 4, TextBox = 5, PictureBox = 6,
	},
	Properties = {
		ENABLED = "Enabled", -- For most form elements
		VISIBLE = "Visible", -- For most form elements
		AUTO_SIZE = "AutoSize", -- For most form elements
		AUTO_COMPLETE_SOURCE = "AutoCompleteSource", -- For dropdown boxes
		AUTO_COMPLETE_MODE = "AutoCompleteMode", -- For dropdown boxes
		BLOCK_INPUT = "BlocksInputWhenFocused", -- For the main form popup
		CHECKED = "Checked", -- For most form elements
		FORE_COLOR = "ForeColor", -- For most form elements
		BACK_COLOR = "BackColor", -- For most form elements
		MAX_LENGTH = "MaxLength", -- For textboxes
		TOP = "Top", -- For window locations
		LEFT = "Left", -- For window locations
		WIDTH = "Width", -- For window locations
		HEIGHT = "Height", -- For window locations
		IMAGE_LOCATION = "ImageLocation",
		ALLOW_TRANSPARENCY = "AllowTransparency",
		TRANSPARENCY_KEY = "TransparencyKey",
	},
}

function ExternalUI.initialize()
	ExternalUI.BizForms.ActiveFormId = 0
end

--- HELPER FUNCTIONS
local _forms = {}
local _helper = {}
local formsOverrides = {
	"newform", "destroy", "button", "checkbox", "dropdown", "label", "textbox", "pictureBox",
	"addclick", "openfile", "gettext", "settext", "ischecked", "getproperty", "setproperty",
	"setdropdownitems",
}
for _, func in ipairs(formsOverrides) do
	_forms[func] = function(...)
		-- Workaround for Lua 5.1 (Bizhawk 2.8) compatibility with mixed nil params
		if Main.emulator == Main.EMU.BIZHAWK28 then
			return forms[func](unpack({...}))
		end
		---@diagnostic disable-next-line: deprecated
		return forms[func](table.unpack({...}))
	end
end
function _helper.formToId(formOrId)
	if type(formOrId) == "table" and formOrId.ControlId then
		return formOrId.ControlId
	end
	if type(formOrId) == "number" then
		return formOrId
	end
	return ExternalUI.BizForms.ActiveFormId
end
function _helper.tryAutoSize(controlId, width, height)
	if not Main.IsOnBizhawk() then return end
	-- Only auto size the control if the width and height were not specified
	if ExternalUI.BizForms.AUTO_SIZE_CONTROLS and not width and not height then
		ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.AUTO_SIZE, true)
	end
end

---Creates a form popup through Bizhawk Lua function
---@param title string?
---@param width number
---@param height number
---@param x number? Optional
---@param y number? Optional
---@param onCloseFunc function? Optional
---@param blockInput boolean? Optional, default is true
---@return IBizhawkForm form An IBizhawkForm object representing the created form
function ExternalUI.BizForms.createForm(title, width, height, x, y, onCloseFunc, blockInput)
	-- Close the active form popup that's currently open, if any (only one at a time allowed to be open)
	ExternalUI.BizForms.destroyForm()

	-- Prepare the form to be created, defining defaults
	local form = ExternalUI.IBizhawkForm:new({
		Title = title,
		Width = width,
		Height = height,
		X = x,
		Y = y,
		BlockInput = (blockInput ~= false),
		OnCloseFunc = onCloseFunc,
	})

	if not Main.IsOnBizhawk() then
		return form
	end

	local function safelyCloseForm()
		client.unpause()
		if not form then
			return
		end
		if form.BlockInput then
			Input.resumeMouse = true
		end
		if type(form.OnCloseFunc) == "function" then
			form:OnCloseFunc()
		end
		form:destroy()
	end

	-- Disable mouse inputs on the emulator window until the form is closed
	if form.BlockInput then
		Input.allowMouse = false
		Input.resumeMouse = false
	end

	-- Create the form through Bizhawk
	form.ControlId = _forms.newform(form.Width, form.Height, form.Title, safelyCloseForm)

	-- Remember this form, and apply any other adjustments like screen centering
	ExternalUI.BizForms.ActiveFormId = form.ControlId
	ExternalUI.BizForms.setWindowLocation(form, form.X, form.Y)

	-- A workaround for a bug in release candidate builds of Bizhawk 2.9
	if Main.emulator == Main.EMU.BIZHAWK29 or Main.emulator == Main.EMU.BIZHAWK_FUTURE then
		local currentPropVal = ExternalUI.BizForms.getProperty(form.ControlId, ExternalUI.BizForms.Properties.BLOCK_INPUT)
		if not Utils.isNilOrEmpty(currentPropVal) then
			ExternalUI.BizForms.setProperty(form.ControlId, ExternalUI.BizForms.Properties.BLOCK_INPUT, form.BlockInput)
		end
	end

	return form
end

---Safely closes and destroys a specific form, or the active open form popup if none provided
---@param formOrId? IBizhawkForm|number Optional
function ExternalUI.BizForms.destroyForm(formOrId)
	if not Main.IsOnBizhawk() then return end

	local controlId = _helper.formToId(formOrId)
	Input.resumeMouse = true
	client.unpause()
	if (controlId or 0) ~= 0 then
		_forms.destroy(controlId)
	end
	if ExternalUI.BizForms.ActiveFormId == controlId then
		ExternalUI.BizForms.ActiveFormId = 0
	end
end

---Sets the windowTitle location of the form relative to the emulator window
---@param formOrId IBizhawkForm|number
---@param x number
---@param y number
function ExternalUI.BizForms.setWindowLocation(formOrId, x, y)
	if formOrId == nil or not Main.IsOnBizhawk() then return end
	local controlId = _helper.formToId(formOrId)
	local ribbonHight = 64 -- so we are below the ribbon menu
	local actualLocation = client.transformPoint(x, y) or {}
	local left = client.xpos() + (actualLocation.x or 0)
	local top = client.ypos() + (actualLocation.y or 0) + ribbonHight
	ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.LEFT, left)
	ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.TOP, top)
end

---Pauses emulation and opens a standard openfile dialog prompt; returns the chosen filepath, or an empty string if cancelled
---@param filename string
---@param directory string Often uses/includes `FileManager.dir`
---@param filterOptions string Example: "Tracker Data (*.TDAT)|*.tdat|All files (*.*)|*.*"
---@return string filepath, boolean success
function ExternalUI.BizForms.openFilePrompt(filename, directory, filterOptions)
	local filepath = ""
	if not Main.IsOnBizhawk() then
		return filepath, false
	end
	-- Disable the sound, since the openfile dialog will cause their emulation to stutter
	Utils.tempDisableBizhawkSound()
	filepath = _forms.openfile(filename, directory, filterOptions)
	Utils.tempEnableBizhawkSound()
	local success = not Utils.isNilOrEmpty(filepath)
	return filepath, success
end

---Gets the text caption for a given form Control element, usually from a textbox or dropdown
---@param controlId number
---@return string
function ExternalUI.BizForms.getText(controlId)
	if (controlId or 0) == 0 or not Main.IsOnBizhawk() then
		return ""
	end
	return _forms.gettext(controlId) or ""
end

---Sets the text caption for a given form Control element, usually for a textbox or dropdown
---@param controlId number
---@param text string?
function ExternalUI.BizForms.setText(controlId, text)
	if (controlId or 0) == 0 or not Main.IsOnBizhawk() then
		return
	end
	_forms.settext(controlId, text or "")
end

---Returns true if the Checkbox control is checked; false otherwise
---@param controlId number
---@return boolean
function ExternalUI.BizForms.isChecked(controlId)
	if (controlId or 0) == 0 or not Main.IsOnBizhawk() then
		return false
	end
	return _forms.ischecked(controlId)
end

---Sets the value of the Checkbox control; true/false
---@param controlId number
---@param isChecked boolean
function ExternalUI.BizForms.setChecked(controlId, isChecked)
	isChecked = (isChecked == true) -- default to false
	ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.CHECKED, isChecked)
end


---Gets a string representation of the value of a property of a Control
---@param controlId number
---@param property string
---@return string
function ExternalUI.BizForms.getProperty(controlId, property)
	if (controlId or 0) == 0 or not property or not Main.IsOnBizhawk() then
		return ""
	end
	return _forms.getproperty(controlId, property) or ""
end

---Attempts to set the given property of the widget with the given value.
---Note: not all properties will be able to be represented for the control to accept
---@param controlId number
---@param property string
---@param value any
function ExternalUI.BizForms.setProperty(controlId, property, value)
	if (controlId or 0) == 0 or not property or value == nil or not Main.IsOnBizhawk() then
		return
	end
	_forms.setproperty(controlId, property, value)
end

---Adds a click event to a form Control element
---@param controlId number
---@param clickFunc? function
function ExternalUI.BizForms.addOnClick(controlId, clickFunc)
	if (controlId or 0) == 0 or type(clickFunc) ~= "function" or not Main.IsOnBizhawk() then
		return
	end
	_forms.addclick(controlId, clickFunc)
end

--- BIZHAWK FORM OBJECT

--- An object representing a Bizhawk form popup. Contains useful Bizhawk Lua functions to create controls:
--- Button, Checkbox, Dropdown, Label, TextBox
---@class IBizhawkForm
ExternalUI.IBizhawkForm = {
	-- This value is set after the form is created; do not define it yourself
	ControlId = 0,
	-- Optional code to run when the form is closed
	OnCloseFunc = function() end,
	-- Table of created Bizhawk controls: key=id, val=ControlType
	CreatedControls = {},
	-- Table of referenceable Controls: key=name, val=controlid
	Controls = {},

	-- After the Bizhawk form itself is created, the following attributes cannot be changed
	Title = "Tracker Form",
	X = 100,
	Y = 50,
	Width = 600,
	Height = 600,
	BlockInput = true, -- Disable mouse inputs on the emulator window until the form is closed

	destroy = function(self)
		ExternalUI.BizForms.destroyForm(self)
	end,
}
---Creates and returns a new IBizhawkForm object; use `createBizhawkForm` to create a form popup instead of calling this directly
---@param o? table Optional initial object table
---@return IBizhawkForm form An IBizhawkForm object
function ExternalUI.IBizhawkForm:new(o)
	o = o or {}
	for k, v in pairs(ExternalUI.IBizhawkForm) do
		if o[k] == nil then
			if type(v) == "table" then
				o[k] = {}
			else
				o[k] = v
			end
		end
	end
	setmetatable(o, self)
	self.__index = self
	return o
end

---Creates a Button Control element for a Bizhawk form, returning the id of the created control
---@param text string
---@param clickFunc function
---@param x number
---@param y number
---@param width number? Optional
---@param height number? Optional
---@return number controlId
function ExternalUI.IBizhawkForm:createButton(text, x, y, clickFunc, width, height)
	if not Main.IsOnBizhawk() then return 0 end
	local controlId = _forms.button(self.ControlId, text, clickFunc, x, y, width, height)
	_helper.tryAutoSize(controlId, width, height)
	self.CreatedControls[controlId] = ExternalUI.BizForms.ControlTypes.Button
	return controlId
end

---Creates a Checkbox Control element for a Bizhawk form, returning the id of the created control
---@param text string
---@param x number
---@param y number
---@param clickFunc function? Optional, note that you usually don't need a click func for this
---@return number controlId
function ExternalUI.IBizhawkForm:createCheckbox(text, x, y, clickFunc)
	if not Main.IsOnBizhawk() then return 0 end
	local controlId = _forms.checkbox(self.ControlId, text, x, y)
	_helper.tryAutoSize(controlId)
	ExternalUI.BizForms.addOnClick(controlId, clickFunc)
	self.CreatedControls[controlId] = ExternalUI.BizForms.ControlTypes.Checkbox
	return controlId
end

---Creates a Dropdown Control element for a Bizhawk form, returning the id of the created control
---@param itemList table An ordered list of values (ideally strings)
---@param x number
---@param y number
---@param width number?
---@param height number?
---@param startItem string?
---@param sortAlphabetically boolean? Optional, default is true
---@param clickFunc function? Optional, note that you usually don't need a click func for this
---@return number controlId
function ExternalUI.IBizhawkForm:createDropdown(itemList, x, y, width, height, startItem, sortAlphabetically, clickFunc)
	if not Main.IsOnBizhawk() then return 0 end
	sortAlphabetically = (sortAlphabetically ~= false) -- default to true
	local controlId = _forms.dropdown(self.ControlId, {["Init"]="..."}, x, y, width, height)
	_forms.setdropdownitems(controlId, itemList, sortAlphabetically)
	ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.AUTO_COMPLETE_SOURCE, "ListItems")
	ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.AUTO_COMPLETE_MODE, "Append")
	if startItem then
		ExternalUI.BizForms.setText(controlId, startItem)
	end
	_helper.tryAutoSize(controlId, width, height)
	ExternalUI.BizForms.addOnClick(controlId, clickFunc)
	self.CreatedControls[controlId] = ExternalUI.BizForms.ControlTypes.Dropdown
	return controlId
end

---Creates a Label Control element for a Bizhawk form, returning the id of the created control
---@param text string
---@param x number
---@param y number
---@param width number?
---@param height number?
---@param monospaced boolean? Optional, if true will use a a monospaced font: Courier New (size 8)
---@param clickFunc function? Optional, note that you usually don't need a click func for this
---@return number controlId
function ExternalUI.IBizhawkForm:createLabel(text, x, y, width, height, monospaced, clickFunc)
	if not Main.IsOnBizhawk() then return 0 end
	local controlId = _forms.label(self.ControlId, text, x, y, width, height, monospaced)
	_helper.tryAutoSize(controlId, width, height)
	ExternalUI.BizForms.addOnClick(controlId, clickFunc)
	self.CreatedControls[controlId] = ExternalUI.BizForms.ControlTypes.Label
	return controlId
end

---Creates a TextBox Control element for a Bizhawk form, returning the id of the created control
---@param text string
---@param x number
---@param y number
---@param width number?
---@param height number?
---@param boxtype string? Optional, restricts the textbox input; available options: HEX, SIGNED, UNSIGNED
---@param multiline boolean? Optional, if true will enable the standard winform multi-line property
---@param monospaced boolean? Optional, if true will use a a monospaced font: Courier New (size 8)
---@param scrollbars string? Optional when using multiline; available options: Vertical, Horizontal, Both, None
---@param clickFunc function? Optional, note that you usually don't need a click func for this
---@return number controlId
function ExternalUI.IBizhawkForm:createTextBox(text, x, y, width, height, boxtype, multiline, monospaced, scrollbars, clickFunc)
	if not Main.IsOnBizhawk() then return 0 end
	boxtype = boxtype or ""
	local controlId = _forms.textbox(self.ControlId, text, width, height, boxtype, x, y, multiline, monospaced, scrollbars)
	_helper.tryAutoSize(controlId, width, height)
	ExternalUI.BizForms.addOnClick(controlId, clickFunc)
	self.CreatedControls[controlId] = ExternalUI.BizForms.ControlTypes.TextBox
	return controlId
end

---Creates a PictureBox Control element for a Bizhawk form, returning the id of the created control
---@param x number
---@param y number
---@param width number?
---@param height number?
---@param clickFunc function? Optional, note that you usually don't need a click func for this
---@return number controlId
function ExternalUI.IBizhawkForm:createPictureBox(x, y, width, height, clickFunc)
	if not Main.IsOnBizhawk() then return 0 end
	local controlId = _forms.pictureBox(self.ControlId, x, y, width, height)
	_helper.tryAutoSize(controlId, width, height)
	ExternalUI.BizForms.addOnClick(controlId, clickFunc)
	self.CreatedControls[controlId] = ExternalUI.BizForms.ControlTypes.PictureBox
	return controlId
end

Options = {
	-- 'Default' set of Options, but will get replaced by what's in Settings.ini
	["Auto swap to enemy"] = true,
	["Hide stats until summary shown"] = false,
	["Right justified numbers"] = false,
	["Show physical special icons"] = true,
	["Show move effectiveness"] = true,
	["Calculate variable damage"] = true,
	["Count enemy PP usage"] = true,
	["Track PC Heals"] = false,
	["PC heals count downward"] = true,
	["Pokemon Stadium portraits"] = false,

	CONTROLS = {
		["Load next seed"] = "A, B, Start, Select",
		["Toggle view"] = "Start",
		["Cycle through stats"] = "L",
		["Mark stat"] = "R",
	},
}

-- Update drawing the settings page if true
Options.redraw = true

-- Tracks if settings were modified so we know if we need to update Settings.ini or not.
Options.updated = false

Options.buttons = {
	romsFolder = {
		type = Constants.BUTTON_TYPES.NO_BORDER,
		text = "Roms folder: ",
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + 6, 8, Constants.SCREEN.RIGHT_GAP - 12, 11 },
		box = { Constants.SCREEN.WIDTH + 6, 8, 11, 11 },
		onClick = function() Options.openRomPickerWindow() end
	},
	controls = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Controls",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 8, 20, 37, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		onClick = function() Options.openEditControlsWindow() end
	},
	saveTrackerData = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Save Data",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 49, 20, 44, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		onClick = function() Options.openSaveDataPrompt() end
	},
	loadTrackerData = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Load Data",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 97, 20, 44, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		onClick = function() Options.openLoadDataPrompt() end
	},
	customizeTheme = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Customize Theme",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 9, 140, 74, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		onClick = function()
			-- Navigate to the Theme Customization menu
			Program.state = State.THEME
			Theme.redraw = true
			Program.frames.waitToDraw = 0
		end
	},
	close = {
		type = Constants.BUTTON_TYPES.FULL_BORDER,
		text = "Close",
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 116, 140, 25, 11 },
		boxColors = { "Upper box border", "Upper box background" },
		onClick = function()
			-- Save all of the Options to the Settings.ini file, and navigate back to the main Tracker screen
			Options.saveOptions()
			Program.state = State.TRACKER
			Program.frames.waitToDraw = 0
		end
	},
}

function Options.initialize()
	local borderMargin = 5
	local index = 1
	local heightOffset = 35

	for _, optionKey in ipairs(Constants.ORDERED_LISTS.OPTIONS) do
		local button = {
			type = Constants.BUTTON_TYPES.CHECKBOX,
			text = optionKey,
			textColor = "Default text",
			clickableArea = { Constants.SCREEN.WIDTH + borderMargin + 3, heightOffset, Constants.SCREEN.RIGHT_GAP - 12, 11 },
			box = {	Constants.SCREEN.WIDTH + borderMargin + 3, heightOffset, 8, 8 },
			boxColors = { "Upper box border", "Upper box background" },
			toggleState = Options[optionKey],
			togglecolor = "Positive text",
			onClick = function(self)
				-- Toggle the setting and store the change to be saved later in Settings.ini
				Options[optionKey] = not Options[optionKey]
				self.toggleState = Options[optionKey]
				Settings.tracker[string.gsub(optionKey, " ", "_")] = Options[optionKey]

				if optionKey == "PC heals count downward" then
					-- If PC Heal tracking switched, invert the count
					Tracker.Data.centerHeals = math.max(10 - Tracker.Data.centerHeals, 0)
				elseif optionKey == "Hide stats until summary shown" then
					-- If check summary gets toggled, force update on tracker data (case for just starting the game and turning option on)
					Tracker.Data.hasCheckedSummary = not Options["Hide stats until summary shown"]
				end

				Options.updated = true
				Options.redraw = true
				Program.frames.waitToDraw = 0
			end
		}

		Options.buttons[optionKey] = button
		index = index + 1
		heightOffset = heightOffset + 10
	end

	Options.loadOptions()
end

-- Loads the options defined in Settings.ini into the Tracker's constants
function Options.loadOptions()
	-- If no Settings.ini file was present, or sections were missing, define them here
	if Settings == nil then Settings = {} end
	if Settings.config == nil then Settings.config = {} end
	if Settings.tracker == nil then Settings.tracker = {} end
	if Settings.controls == nil then Settings.controls = {} end
	if Settings.theme == nil then Settings.theme = {} end

	-- If ROMS_FOLDER is left empty, Inifile.lua doesn't add it to the settings table, resulting in the ROMS_FOLDER 
	-- being deleted entirely from Settings.ini if another setting is toggled in the tracker options menu
	if Settings.config.ROMS_FOLDER == nil then
		Settings.config.ROMS_FOLDER = ""
		Options.updated = true
	end

	for _, optionKey in ipairs(Constants.ORDERED_LISTS.OPTIONS) do
		local optionValue = Settings.tracker[string.gsub(optionKey, " ", "_")]

		-- If no setting is found, assign it based on the defaults
		if optionValue == nil then
			Settings.tracker[string.gsub(optionKey, " ", "_")] = Options[optionKey]
			Options.updated = true
		else -- Otherwise update the setting that is in use with the one from Settings.ini
			Options[optionKey] = optionValue
		end
	end

	for optionKey, optionValue in pairs(Options.CONTROLS) do
		local controlValue = Settings.controls[string.gsub(optionKey, " ", "_")]

		-- If no control is found, assign it based on the defaults
		if controlValue == nil then
			Settings.controls[string.gsub(optionKey, " ", "_")] = Options.CONTROLS[optionKey]
			Options.updated = true
		else -- Otherwise update the control that is in use with the one from Settings.ini
			Options.CONTROLS[optionKey] = controlValue
		end
	end

	Options.redraw = true
	Program.frames.waitToDraw = 0
end

-- Saves all in-memory Options and Theme elements into the Settings object, to be written to Settings.ini
function Options.saveOptions()
	-- Save the tracker's currently loaded settings into the Settings object to be saved
	if Options.updated then
		for _, optionKey in ipairs(Constants.ORDERED_LISTS.OPTIONS) do
			Settings.tracker[string.gsub(optionKey, " ", "_")] = Options[optionKey]
		end
		for _, controlKey in ipairs(Constants.ORDERED_LISTS.CONTROLS) do
			Settings.controls[string.gsub(controlKey, " ", "_")] = Options.CONTROLS[controlKey]
		end
	end

	-- Save the tracker's currently loaded theme into the Settings object to be saved
	if Theme.updated then
		for _, colorkey in ipairs(Constants.ORDERED_LISTS.THEMECOLORS) do
			Settings.theme[string.gsub(colorkey, " ", "_")] = string.upper(string.sub(string.format("%#x", Theme.COLORS[colorkey]), 5))
		end
	end

	if Options.updated or Theme.updated then
		INI.save("Settings.ini", Settings)
	end
	Options.updated = false
	Theme.updated = false
end

function Options.openRomPickerWindow()
	if Settings.config.ROMS_FOLDER == nil then
		Settings.config.ROMS_FOLDER = ""
	end

	-- Use the standard file open dialog to get the roms folder
	local filterOptions = "ROM File (*.GBA)|*.GBA|All files (*.*)|*.*"
	local file = forms.openfile("SELECT A ROM", Settings.config.ROMS_FOLDER, filterOptions)
	-- Since the user had to pick a file, strip out the file name to just get the folder.
	if file ~= "" then
		Settings.config.ROMS_FOLDER = string.sub(file, 0, string.match(file, "^.*()\\") - 1)
		if Settings.config.ROMS_FOLDER == nil then
			Settings.config.ROMS_FOLDER = ""
		end
	end

	Options.updated = true
	Options.redraw = true
	Program.frames.waitToDraw = 0
	Options.saveOptions() -- Save these changes to the file to avoid case where user resets before clicking the Close button
end

function Options.openEditControlsWindow()
	local form = forms.newform(445, 215, "Controller Inputs", function() return end)
	Utils.setFormLocation(form, 100, 50)
	forms.label(form, "Edit controller inputs for the tracker. Available inputs: A, B, L, R, Start, Select", 39, 10, 410, 20)

	local inputTextboxes = {}
	local offsetX = 90
	local offsetY = 35

	local index = 1
	for _, controlKey in ipairs(Constants.ORDERED_LISTS.CONTROLS) do
		forms.label(form, controlKey .. ":", offsetX, offsetY, 105, 20)
		inputTextboxes[index] = forms.textbox(form, Options.CONTROLS[controlKey], 140, 21, nil, offsetX + 110, offsetY - 2)

		index = index + 1
		offsetY = offsetY + 24
	end

	-- 'Save & Close' and 'Cancel' buttons
	forms.button(form,"Save && Close", function() 
		index = 1
		for _, controlKey in ipairs(Constants.ORDERED_LISTS.CONTROLS) do
			local controlCombination = ""
			for txtInput in string.gmatch(forms.gettext(inputTextboxes[index]), '([^,%s]+)') do
				-- Format "START" as "Start"
				controlCombination = controlCombination .. txtInput:sub(1,1):upper() .. txtInput:sub(2):lower() .. ", "
			end
			controlCombination = controlCombination:sub(1, -3)

			Options.CONTROLS[controlKey] = controlCombination
			Options.updated = true
			index = index + 1
		end

		Options.saveOptions() -- Save these changes to the file to avoid case where user resets before clicking the Close button
		client.unpause()
		forms.destroy(form)
	end, 120, offsetY + 5, 95, 30)

	forms.button(form,"Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 230, offsetY + 5, 65, 30)
end

function Options.openSaveDataPrompt()
	local suggestedFileName = gameinfo.getromname()

	local form = forms.newform(290, 130, "Save Tracker Data", function() return end)
	Utils.setFormLocation(form, 100, 50)
	forms.label(form, "Enter a filename to save Tracker data to:", 18, 10, 300, 20)
	local saveTextBox = forms.textbox(form, suggestedFileName, 200, 30, nil, 20, 30)
	forms.label(form, ".TDAT", 219, 32, 45, 20)
	forms.button(form, "Save Data", function()
		local formInput = forms.gettext(saveTextBox)
		if formInput ~= nil and formInput ~= "" then
			if formInput:sub(-5):lower() ~= Constants.TRACKER_DATA_EXTENSION then
				formInput = formInput .. Constants.TRACKER_DATA_EXTENSION
			end
			Tracker.saveData(formInput)
		end
		client.unpause()
		forms.destroy(form)
	end, 55, 60)
	forms.button(form, "Cancel", function()
		client.unpause()
		forms.destroy(form)
	end, 140, 60)
end

function Options.openLoadDataPrompt()
	local suggestedFileName = gameinfo.getromname() .. Constants.TRACKER_DATA_EXTENSION
	local filterOptions = "Tracker Data (*.TDAT)|*.TDAT|All files (*.*)|*.*"

	local filepath = forms.openfile(suggestedFileName, "/", filterOptions)
	if filepath ~= "" then
		Tracker.loadData(filepath)
	end
end
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

	-- Used to always display the Options in a set order in the menu
	ORDEREDLIST = {
		"Auto swap to enemy",
		"Hide stats until summary shown",
		"Right justified numbers",
		"Show physical special icons",
		"Show move effectiveness",
		"Calculate variable damage",
		"Count enemy PP usage",
		"Track PC Heals",
		"PC heals count downward",
		"Pokemon Stadium portraits"
	},

	CONTROLS = {
		["Load next seed"] = "A, B, Start, Select",
		["Toggle view"] = "Start",
		["Cycle through stats"] = "L",
		["Mark stat"] = "R",
	},

	CONTROLS_ORDERED = {
		"Load next seed",
		"Toggle view",
		"Cycle through stats",
		"Mark stat",
	},
}

-- Update drawing the settings page if true
Options.redraw = true

-- Tracks if settings were modified so we know if we need to update Settings.ini or not.
Options.updated = false

-- A button to close the settings page and save the settings if any changes occurred
Options.closeButton = {
	text = "Close",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP - 39,
		GraphicConstants.SCREEN_HEIGHT - 20,
		29,
		11,
	},
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		-- Save the Settings.ini file if any changes were made
		Options.saveOptions()

		Program.state = State.TRACKER
		Program.frames.waitToDraw = 0
	end
}

-- Not a visible button, but is used by the Input script to see if clicks occurred on the setting
Options.romsFolderOption = {
	text = "Roms folder: ",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 6, 8, 8, 8 },
	onClick = function() Options.openRomPickerWindow() end
}

Options.controlsButton = {
	text = "Controls",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 8, 20, 37, 11 },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function() Options.openEditControlsWindow() end
}

Options.saveTrackerDataButton = {
	text = "Save Data",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 49, 20, 44, 11 },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function() Options.openSaveDataPrompt() end
}

Options.loadTrackerDataButton = {
	text = "Load Data",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 97, 20, 44, 11 },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function() Options.openLoadDataPrompt() end
}

-- A button to navigate to the Theme menu for customizing the Tracker's look and feel
Options.themeButton = {
	text = "Customize Theme",
	textColor = "Default text",
	box = { GraphicConstants.SCREEN_WIDTH + 10, GraphicConstants.SCREEN_HEIGHT - 20, 77, 11 },
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		-- Navigate to the Theme Customization menu
		Program.state = State.THEME
		Theme.redraw = true
		Program.frames.waitToDraw = 0
	end
}

-- Stores the options in the Settings.ini file into configurable toggles in the Tracker
Options.optionsButtons = {}

--[[]]
function Options.buildTrackerOptionsButtons()
	local borderMargin = 5
	local index = 1
	local heightOffset = 35

	for _, optionKey in ipairs(Options.ORDEREDLIST) do
		local button = {
			text = optionKey,
			textColor = "Default text",
			box = {	GraphicConstants.SCREEN_WIDTH + borderMargin + 3, heightOffset, 8, 8 },
			boxColors = { "Upper box border", "Upper box background" },
			togglecolor = "Positive text",
			onClick = function()
				-- Toggle the setting and store the change to be saved later in Settings.ini
				Options[optionKey] = not Options[optionKey]
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
		table.insert(Options.optionsButtons, button)
		index = index + 1
		heightOffset = heightOffset + 10
	end
end

-- Loads the options defined in Settings.ini into the Tracker's constants
function Options.loadOptions()
	-- If no Settings.ini file was present, or sections were missing, define them here
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

	for _, optionKey in ipairs(Options.ORDEREDLIST) do
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
		for _, optionKey in ipairs(Options.ORDEREDLIST) do
			Settings.tracker[string.gsub(optionKey, " ", "_")] = Options[optionKey]
		end
		for _, controlKey in ipairs(Options.CONTROLS_ORDERED) do
			Settings.controls[string.gsub(controlKey, " ", "_")] = Options.CONTROLS[controlKey]
		end
	end

	-- Save the tracker's currently loaded theme into the Settings object to be saved
	if Theme.updated then
		for _, colorkey in ipairs(GraphicConstants.THEMECOLORS_ORDERED) do
			Settings.theme[string.gsub(colorkey, " ", "_")] = string.upper(string.sub(string.format("%#x", GraphicConstants.THEMECOLORS[colorkey]), 5))
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
	local file = forms.openfile("SELECT ANY ROM IN YOUR ROMS FOLDER, THEN HIT OK", Settings.config.ROMS_FOLDER, filterOptions)
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
end

function Options.openEditControlsWindow()
	local form = forms.newform(445, 215, "Controller Inputs", function() return end)
	forms.label(form, "Edit controller inputs for the tracker. Available inputs: A, B, L, R, Start, Select", 39, 10, 410, 20)

	local inputTextboxes = {}
	local offsetX = 90
	local offsetY = 35

	local index = 1
	for _, controlKey in ipairs(Options.CONTROLS_ORDERED) do
		forms.label(form, controlKey .. ":", offsetX, offsetY, 105, 20)
		inputTextboxes[index] = forms.textbox(form, Options.CONTROLS[controlKey], 140, 21, nil, offsetX + 110, offsetY - 2)

		index = index + 1
		offsetY = offsetY + 24
	end

	-- 'Save & Close' and 'Cancel' buttons
	forms.button(form,"Save && Close", function() 
		index = 1
		for _, controlKey in ipairs(Options.CONTROLS_ORDERED) do
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

		forms.destroy(form)
	end, 120, offsetY + 5, 95, 30)

	forms.button(form,"Cancel", function()
		forms.destroy(form)
	end, 230, offsetY + 5, 65, 30)
end

function Options.openSaveDataPrompt()
	local suggestedFileName = gameinfo.getromname()

	local form = forms.newform(290, 130, "Save Tracker Data", function() return end)
	forms.label(form, "Enter a filename to save Tracker data to:", 18, 10, 300, 20)
	local saveTextBox = forms.textbox(form, suggestedFileName, 200, 30, nil, 20, 30)
	forms.label(form, ".TDAT", 219, 32, 45, 20)
	forms.button(form, "Save Data", function()
		local formInput = forms.gettext(saveTextBox)
		if formInput ~= nil and formInput ~= "" then
			if formInput:sub(-5):lower() ~= GameSettings.fileExtension then
				formInput = formInput .. GameSettings.fileExtension
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
	local suggestedFileName = gameinfo.getromname() .. GameSettings.fileExtension
	local filterOptions = "Tracker Data (*.TDAT)|*.TDAT|All files (*.*)|*.*"

	local filepath = forms.openfile(suggestedFileName, "/", filterOptions)
	if filepath ~= "" then
		Tracker.loadData(filepath)
	end
end
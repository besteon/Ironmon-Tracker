Options = {
	-- 'Default' set of Options, but will get replaced by what's in Settings.ini
	["Auto swap to enemy"] = true,
	["Hide stats until summary shown"] = false,
	["Right justified numbers"] = false,
	["Show physical special icons"] = true,
	["Show move effectiveness"] = true,
	["Calculate variable damage"] = true,
	["Track PC Heals"] = false,
	["PC heals count downward"] = true,

	-- Used to always display the Options in a set order in the menu
	ORDEREDLIST = {
		"Auto swap to enemy",
		"Hide stats until summary shown",
		"Right justified numbers",
		"Show physical special icons",
		"Show move effectiveness",
		"Calculate variable damage",
		"Track PC Heals",
		"PC heals count downward",
	},

	CONTROLS = {
		["Cycle view"] = "Start",
		["Cycle stat"] = "L",
		["Cycle prediction"] = "R",
		["Next seed"] = "A,B,Start,Select",
	}
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
		if Options.updated or Theme.updated then
			Options.updated = false
			Theme.updated = false

			-- Save the Settings.ini file if any changes were made
			INI.save("Settings.ini", Settings)
		end

		Program.state = State.TRACKER
		Tracker.redraw = true
	end
}

-- Not a visible button, but is used by the Input script to see if clicks occurred on the setting
Options.romsFolderOption = {
	text = "Roms folder: ",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + 6, -- 6 = borderMargin + 1
		8, -- 8 = borderMargin + 3
		8,
		8,
	},
	onClick = function()
		if Settings.config.ROMS_FOLDER == nil then
			Settings.config.ROMS_FOLDER = ""
		end

		-- Use the standard file open dialog to get the roms folder
		local file = forms.openfile(nil, Settings.config.ROMS_FOLDER)
		-- Since the user had to pick a file, strip out the file name to just get the folder.
		if file ~= "" then
			Settings.config.ROMS_FOLDER = string.sub(file, 0, string.match(file, "^.*()\\") - 1)
			if Settings.config.ROMS_FOLDER == nil then
				Settings.config.ROMS_FOLDER = ""
			end
		end

		Options.updated = true
		Options.redraw = true
	end
}

-- A button to navigate to the Theme menu for customizing the Tracker's look and feel
Options.themeButton = {
	text = "Customize Theme",
	textColor = "Default text",
	box = {
		GraphicConstants.SCREEN_WIDTH + 10,
		GraphicConstants.SCREEN_HEIGHT - 20,
		77,
		11,
	},
	boxColors = { "Upper box border", "Upper box background" },
	onClick = function()
		-- Navigate to the Theme Customization menu
		Program.state = State.THEME
		Theme.redraw = true
	end
}

-- Stores the options in the Settings.ini file into configurable toggles in the Tracker
Options.optionsButtons = {}

--[[]]
function Options.buildTrackerOptionsButtons()
	local borderMargin = 5
	local index = 1
	local heightOffset = 10 + index * 10

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

				-- If PC Heal tracking switched, invert the count
				if optionKey == "PC heals count downward" then
					Tracker.Data.centerHeals = 10 - Tracker.Data.centerHeals
				end

				
				Options.updated = true
				Options.redraw = true
			end
		}
		table.insert(Options.optionsButtons, button)
		index = index + 1
		heightOffset = 10 + index * 10
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
		-- If no setting is found, assign it based on the defaults
		if Settings.controls[string.gsub(optionKey, " ", "_")] == nil then
			Settings.controls[string.gsub(optionKey, " ", "_")] = Options.CONTROLS[optionKey]
			Options.updated = true
		else -- Otherwise update the setting that is in use with the one from Settings.ini
			Options[optionKey] = optionValue
		end
	end

	Options.redraw = true
end
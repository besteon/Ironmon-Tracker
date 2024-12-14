--[[
TODO LIST
- Change Tracker TDAT file to replace old with new name, based on profile's settings name (almost done)
- Change New Run load next seed process to add a setting to auto-update the profile's game version
- Add way to change the selected profile in use
- Add way to delete a profile
- Run tests for Tracker upgrade with no New Run info set, Roms Folder set, as well as Generate rom set.
]]

QuickloadScreen = {
	Colors = {
		text = "Lower box text",
		highlight = "Intermediate text",
		positive = "Positive text",
		negative = "Negative text",
		border = "Lower box border",
		boxFill = "Lower box background",
	},
	Tabs = {
		General = {
			index = 1,
			tabKey = "General",
			resourceKey = "TabGeneral",
		},
		Profiles = {
			index = 2,
			tabKey = "Profiles",
			resourceKey = "TabProfiles",
		},
		Edit = {
			index = 3,
			tabKey = "Edit",
			resourceKey = "TabEdit",
		},
		Options = {
			index = 4,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	currentTab = nil,
	Profiles = {}, -- populated from JSON as a luatable: { [GUID] = IProfile() }
}
local SCREEN = QuickloadScreen
local TAB_HEIGHT = 12
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN + 10 + TAB_HEIGHT,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10 - TAB_HEIGHT,
}

SCREEN.Modes = {
	GENERATE = "Generate",
	PREMADE = "Premade",
}

SCREEN.SetButtonSetup = {
	["ROMs Folder"] = {
		resourceKey = "OptionRomsFolder",
		offsetY = Constants.SCREEN.MARGIN + 55,
		statusIconVisible = function(self) return Options["Use premade ROMs"] end,
	},
	["Randomizer JAR"] = {
		resourceKey = "OptionRandomizerJar",
		offsetY = Constants.SCREEN.MARGIN + 87,
		statusIconVisible = function(self) return Options["Generate ROM each time"] end,
	},
	["Source ROM"] = {
		resourceKey = "OptionSourceRom",
		offsetY = Constants.SCREEN.MARGIN + 101,
		statusIconVisible = function(self) return Options["Generate ROM each time"] end,
	},
	["Settings File"] = {
		resourceKey = "OptionSettingsFile",
		offsetY = Constants.SCREEN.MARGIN + 115,
		statusIconVisible = function(self) return Options["Generate ROM each time"] end,
	},
}

SCREEN.Buttons = {
	-- Description + Button Combo
	NewRunsDescription = {
		type = Constants.ButtonTypes.NO_BORDER,
		-- TODO: change to reflect the selected profile, if set to ROMs Folder
		getCustomText = function() return string.format("%s:", Resources.QuickloadScreen.NewRunsDescription) end,
		box = { CANVAS.X + 2, CANVAS.Y + 2, CANVAS.W - 2, 22 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local wrappedText = Utils.getWordWrapLines(self:getCustomText(), 31) or {}
			local textColor = Theme.COLORS[self.textColor]
			local lineY = y
			for _, line in ipairs(wrappedText) do
				Drawing.drawText(x, lineY, line, textColor, shadowcolor)
				lineY = lineY + Constants.SCREEN.LINESPACING - 1
			end
			lineY = lineY + 2
			local comboRaw = Options.CONTROLS["Load next seed"] or Constants.BLANKLINE
			local comboFormatted = comboRaw:gsub(" ", ""):gsub(",", " + ")
			local centerX = Utils.getCenteredTextX(comboFormatted, w) - 2
			Drawing.drawText(x + centerX, lineY, comboFormatted, Theme.COLORS[SCREEN.Colors.highlight], shadowcolor)
			-- Lazily update the height of this button based on how tall it is drawn
			self.box[4] = lineY + 9 - y
		end,
		onClick = function()
			SetupScreen.currentTab = SetupScreen.Tabs.Controls
			SetupScreen.previousScreen = QuickloadScreen
			Program.changeScreenView(SetupScreen)
		end,
	},
	-- Game Profile label + Active profile
	SelectedGameProfile = {
		type = Constants.ButtonTypes.FULL_BORDER,
		box = { CANVAS.X + 3, CANVAS.Y + 65, CANVAS.W - 6, 33 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		draw = function(self, shadowcolor)
			local profile = QuickloadScreen.getSelectedProfile()
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local textColor = Theme.COLORS[SCREEN.Colors.text]
			local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
			-- Draw Header
			Drawing.drawText(x + 1, y - 11, string.format("%s:", "Selected Game Profile"), textColor, shadowcolor)
			-- Draw Icon
			local iconFilepath = SCREEN.getBoxArtIcon(profile)
			Drawing.drawImage(iconFilepath, x + 1, y + 1, 32, 32)
			gui.drawLine(x + 33, y, x + 33, y + 32, Theme.COLORS[SCREEN.Colors.border])
			-- Draw Profile Information
			-- TODO: find a way to display "Generate" vs. "Premade"
			local col2X = x + 35
			if not profile then
				Drawing.drawText(col2X, y + 5, "Game Profile Missing", highlightColor, shadowcolor)
				Drawing.drawText(col2X, y + 15, "(create one below...)", textColor - 0x20000000, shadowcolor)
				return
			end
			Drawing.drawText(col2X, y + 1, string.format("%s", profile.Name), highlightColor, shadowcolor)
			local attemptsFormatted = Utils.formatNumberWithCommas(profile.AttemptsCount)
			Drawing.drawText(col2X, y + 11, string.format("%s: %s", "Attempts", attemptsFormatted), textColor, shadowcolor)
			local dateFormatted = os.date("%x", profile.LastUsedDate) -- date, (e.g., 09/16/98)
			if type(dateFormatted) == "string" then
				Drawing.drawText(col2X, y + 21, string.format("%s: %s", "Last Played", dateFormatted), textColor - 0x30000000, shadowcolor)
			end
		end,
	},
	ChangeSelectedProfile = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.TRIANGLE_DOWN,
		getText = function(self)
			local profile = QuickloadScreen.getSelectedProfile()
			if profile then
				return "Change Profile" or Resources.QuickloadScreen.ChangeProfile
			else
				return "Add New Profile" or Resources.QuickloadScreen.AddNewProfile
			end
		end,
		box = { CANVAS.X + 27, CANVAS.Y + 103, 84, 16 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		updateSelf = function(self)
			local profile = QuickloadScreen.getSelectedProfile()
			if profile and self.image ~= Constants.PixelImages.TRIANGLE_DOWN then
				self.image = Constants.PixelImages.TRIANGLE_DOWN
				self.textColor = SCREEN.Colors.text
			elseif not profile and self.image ~= Constants.PixelImages.INSTALL_BOX then
				self.image = Constants.PixelImages.INSTALL_BOX
				self.textColor = SCREEN.Colors.positive
			end
		end,
		onClick = function()
			local profile = QuickloadScreen.getSelectedProfile()
			if profile then
				SCREEN.currentTab = SCREEN.Tabs.Profiles
			else
				SCREEN.currentTab = SCREEN.Tabs.Edit
			end
			SCREEN.refreshButtons()
			Program.redraw(true)
		end,
	},
	PremadeRoms = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Use premade ROMs",
		getText = function(self) return Resources.QuickloadScreen.OptionPremadeRoms end,
		clickableArea = { Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 44, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 44, 8, 8 },
		toggleState = false,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		isVisible = function(self) return false end, -- TODO: Debug
		onClick = function(self)
			-- Only one can be enabled at a time
			Options["Generate ROM each time"] = false
			self.toggleState = Options.toggleSetting(self.optionKey)

			-- If turned on initially, automatically locate the loaded rom path
			if self.toggleState and Main.IsOnBizhawk() and (Options.FILES["ROMs Folder"] or "") == "" then
				local luaconsole = client.gettool("luaconsole")
				local luaImp = luaconsole and luaconsole.get_LuaImp()
				local currentRomPath = luaImp and luaImp.PathEntries.LastRomPath or ""
				if currentRomPath ~= "" then
					Options.FILES["ROMs Folder"] = currentRomPath
					Main.SaveSettings(true)
				end
			end

			-- After changing the setup, read-in any existing attempts counter for the new quickload choice
			Main.ReadAttemptsCount()
			SCREEN.verifyOptions()
			SCREEN.refreshButtons()
			NavigationMenu.refreshButtons()
			Program.redraw(true)
		end
	},
	GenerateRom = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Generate ROM each time",
		getText = function(self) return Resources.QuickloadScreen.OptionGenerateRom end,
		clickableArea = { Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 74, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + 13, Constants.SCREEN.MARGIN + 74, 8, 8 },
		toggleState = false,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		isVisible = function(self) return false end, -- TODO: Debug
		onClick = function(self)
			-- Only one can be enabled at a time
			Options["Use premade ROMs"] = false
			self.toggleState = Options.toggleSetting(self.optionKey)

			-- After changing the setup, read-in any existing attempts counter for the new quickload choice
			Main.ReadAttemptsCount()
			SCREEN.verifyOptions()
			SCREEN.refreshButtons()
			NavigationMenu.refreshButtons()
			Program.redraw(true)
		end
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { CANVAS.X + 54, CANVAS.Y + 135, 50, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { CANVAS.X + 42, CANVAS.Y + 136, 10, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { CANVAS.X + 96, CANVAS.Y + 136, 10, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	RefocusEmulator = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Refocus emulator after load",
		getText = function(self) return Resources.QuickloadScreen.OptionRefocusEmulator end,
		clickableArea = { CANVAS.X + 4, CANVAS.Y + 4, 110, 8 },
		box = {	CANVAS.X + 4, CANVAS.Y + 4, 8, 8 },
		toggleState = false,
		-- Option not needed nor used for Bizhawk 2.8
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Options and Main.emulator ~= Main.EMU.BIZHAWK28 end,
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(NavigationMenu)
		SCREEN.currentTab = SCREEN.Tabs.General
	end),
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end,
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer, sortFunc)
		table.sort(self.Buttons, sortFunc or self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP + 1
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local text = string.format("%s/%s", self.currentPage, self.totalPages)
		local bufferSize = 7 - text:len()
		return string.rep(" ", bufferSize) .. text
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
}

function QuickloadScreen.initialize()
	SCREEN.currentTab = SCREEN.Tabs.General
	SCREEN.createTabs()
	SCREEN.createButtons()

	local romfolderBtn = SCREEN.Buttons["ROMs Folder"]
	local jarBtn = SCREEN.Buttons["Randomizer JAR"]
	local gbaBtn = SCREEN.Buttons["Source ROM"]
	local rnqsBtn = SCREEN.Buttons["Settings File"]

	romfolderBtn.clickFunction = SCREEN.handleSetRomFolder
	jarBtn.clickFunction = SCREEN.handleSetRandomizerJar
	gbaBtn.clickFunction = SCREEN.handleSetSourceRom
	rnqsBtn.clickFunction = SCREEN.handleSetCustomSettings

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	SCREEN.verifyOptions()

	local optionPremade = SCREEN.Buttons.PremadeRoms.optionKey
	local optionGenerate = SCREEN.Buttons.GenerateRom.optionKey

	-- If neither premade seeds nor generate ROM each time are enabled, try turning one on if files are setup already
	local settingsChanged = false
	if not Options[optionPremade] and not Options[optionGenerate] then
		if jarBtn.isSet and gbaBtn.isSet and rnqsBtn.isSet then
			Options[optionGenerate] = true
			settingsChanged = true
		elseif romfolderBtn.isSet then
			Options[optionPremade] = true
			settingsChanged = true
		end
	elseif Options[optionPremade] and Options[optionGenerate] then
		-- If both premade seeds and generate ROM each time are enabled, turn one off
		Options[optionGenerate] = false
		settingsChanged = true
	end
	if settingsChanged then
		Main.SaveSettings(true)
	end

	-- TODO: move this later
	SCREEN.loadProfiles()
	SCREEN.buildProfileButtons()

	SCREEN.Buttons.PremadeRoms.toggleState = Options[optionPremade]
	SCREEN.Buttons.GenerateRom.toggleState = Options[optionGenerate]
	NavigationMenu.refreshButtons()
	SCREEN.refreshButtons()
end

function QuickloadScreen.createTabs()
	local startX = CANVAS.X
	local startY = CANVAS.Y - TAB_HEIGHT
	local tabPadding = 5

	-- TABS
	for _, tab in ipairs(Utils.getSortedList(SCREEN.Tabs)) do
		local tabText = Resources.QuickloadScreen[tab.resourceKey]
		local tabWidth = (tabPadding * 2) + Utils.calcWordPixelLength(tabText)
		SCREEN.Buttons["Tab" .. tab.tabKey] = {
			type = Constants.ButtonTypes.NO_BORDER,
			getCustomText = function(self) return tabText end,
			tab = SCREEN.Tabs[tab.tabKey],
			isSelected = false,
			box = {	startX, startY, tabWidth, TAB_HEIGHT },
			updateSelf = function(self)
				self.isSelected = (self.tab == SCREEN.currentTab)
				self.textColor = self.isSelected and SCREEN.Colors.highlight or SCREEN.Colors.text
			end,
			draw = function(self, shadowcolor)
				local x, y = self.box[1], self.box[2]
				local w, h = self.box[3], self.box[4]
				local color = Theme.COLORS[self.boxColors[1]]
				local bgColor = Theme.COLORS[self.boxColors[2]]
				gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, bgColor, bgColor) -- Box fill
				if not self.isSelected then
					gui.drawRectangle(x + 1, y + 1, w - 1, h - 2, Drawing.ColorEffects.DARKEN, Drawing.ColorEffects.DARKEN)
				end
				gui.drawLine(x + 1, y, x + w - 1, y, color) -- Top edge
				gui.drawLine(x, y + 1, x, y + h - 1, color) -- Left edge
				gui.drawLine(x + w, y + 1, x + w, y + h - 1, color) -- Right edge
				if self.isSelected then
					gui.drawLine(x + 1, y + h, x + w - 1, y + h, bgColor) -- Remove bottom edge
				end
				local centeredOffsetX = Utils.getCenteredTextX(self:getCustomText(), w) - 2
				Drawing.drawText(x + centeredOffsetX, y, self:getCustomText(), Theme.COLORS[self.textColor], shadowcolor)
			end,
			onClick = function(self)
				SCREEN.currentTab = self.tab
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end

function QuickloadScreen.createButtons()
	local filenameCutoff = 98
	for optionKey, optionObj in pairs(SCREEN.SetButtonSetup) do
		SCREEN.Buttons[optionKey] = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self)
				if not self:statusIconVisible() then
					return "   " .. Constants.BLANKLINE
				elseif self.isSet then
					return Resources.QuickloadScreen.ButtonClear
				else
					return " " .. Resources.QuickloadScreen.ButtonSet
				end
			end,
			filename = "",
			optionKey = optionKey,
			isSet = false,
			statusIconVisible = optionObj.statusIconVisible,
			box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, optionObj.offsetY, 24, 11 },
			isVisible = function(self) return false end, -- TODO: Debug
			updateSelf = function(self)
				if not self.isSet then
					self.filename = ""
				elseif Utils.isNilOrEmpty(self.filename) then
					if optionKey == "ROMs Folder" then
						self.filename = FileManager.extractFolderNameFromPath(Options.FILES[optionKey] or "") or ""
						local endChar = self.filename ~= "" and self.filename:sub(-1) or ""
						if endChar == FileManager.slash or endChar == "/" then
							endChar = "..."
						else
							endChar = "/..."
						end
						self.filename = self.filename .. endChar
					else
						self.filename = FileManager.extractFileNameFromPath(Options.FILES[optionKey] or "", true) or ""
					end
					self.filename = Utils.formatSpecialCharacters(self.filename)
					self.filename = Utils.shortenText(self.filename, filenameCutoff, true)
				end
			end,
			draw = function(self, shadowcolor)
				local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
				local labelText = Resources.QuickloadScreen[optionObj.resourceKey]
				local labelColor = Theme.COLORS[self.textColor]
				-- If a file is set, use its name instead of the label
				if self.isSet and not Utils.isNilOrEmpty(self.filename) then
					labelText = self.filename
					labelColor = Theme.COLORS["Positive text"]
				end
				Drawing.drawText(topboxX + 6, self.box[2], labelText, labelColor, shadowcolor)

				if not self.isSet and self:statusIconVisible() then
					Drawing.drawImageAsPixels(Constants.PixelImages.CROSS, self.box[1] - 20, self.box[2], { Theme.COLORS["Negative text"] }, shadowcolor)
				end
			end,
			onClick = function(self)
				if not self:statusIconVisible() then return end
				if self.isSet then
					Options.FILES[self.optionKey] = ""
					self.isSet = false
					Main.SaveSettings(true)
					SCREEN.refreshButtons()
					Program.redraw(true)
				else
					if type(self.clickFunction) == "function" then
						self:clickFunction()
					end
				end
			end,
			clickFunction = nil,
		}
	end
end

function QuickloadScreen.buildProfileButtons()
	SCREEN.Pager.Buttons = {}

	-- Sort the loaded profiles by most recent, then alphabetically
	local profiles = {}
	for _, profile in pairs(SCREEN.Profiles or {}) do
		table.insert(profiles, profile)
	end
	table.sort(profiles, function(a,b)
		return a.LastUsedDate > b.LastUsedDate or (a.LastUsedDate == b.LastUsedDate and a.Name < b.Name)
	end)

	-- Build buttons for each profile
	for i, profile in ipairs(profiles) do
		local button = {
			type = Constants.ButtonTypes.FULL_BORDER,
			profile = profile,
			index = i,
			dimensions = { width = CANVAS.W - 6, height = 33 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.currentPage == self.pageVisible end,
			-- includeInGrid = function(self) return true end,
			updateSelf = function(self)
				if not self.boxColors then
					self.boxColors = {}
				end
				if SCREEN.getSelectedProfile() == profile then
					self.boxColors[1] = SCREEN.Colors.positive
				else
					self.boxColors[1] = SCREEN.Colors.border
				end
			end,
			onClick = function(self)
				QuickloadScreen.addEditProfilePrompt(self.profile)
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local textColor = Theme.COLORS[SCREEN.Colors.text]
				local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
				-- Draw Icon
				local iconFilepath = SCREEN.getBoxArtIcon(self.profile)
				Drawing.drawImage(iconFilepath, x + 1, y + 1, 32, 32)
				gui.drawLine(x + 33, y, x + 33, y + 32, Theme.COLORS[SCREEN.Colors.border])
				-- Draw Profile Information
				-- TODO: find a way to display "Generate" vs. "Premade"
				local col2X = x + 35
				Drawing.drawText(col2X, y + 1, string.format("%s", self.profile.Name), highlightColor, shadowcolor)
				local attemptsFormatted = Utils.formatNumberWithCommas(self.profile.AttemptsCount)
				Drawing.drawText(col2X, y + 11, string.format("%s: %s", "Attempts", attemptsFormatted), textColor, shadowcolor)
				local dateFormatted = os.date("%x", self.profile.LastUsedDate) -- date, (e.g., 09/16/98)
				if type(dateFormatted) == "string" then
					Drawing.drawText(col2X, y + 21, string.format("%s: %s", "Last Played", dateFormatted), textColor - 0x30000000, shadowcolor)
				end
			end,
		}
		table.insert(SCREEN.Pager.Buttons, button)
	end

	SCREEN.Pager:realignButtonsToGrid(CANVAS.X + 3, CANVAS.Y + 14, 0, 0)
	SCREEN.refreshButtons()
end

---Returns the currently selected profile used for New Runs; or nil if none selected
---@return IProfile|nil profile
function QuickloadScreen.getSelectedProfile()
	return SCREEN.Profiles[Options["Selected Profile"] or ""]
end

---Loads or creates a set of Profiles from the JSON file stored in the Tracker folder
function QuickloadScreen.loadProfiles()
	if not FileManager.fileExists(FileManager.Files.NEWRUN_PROFILES) then
		SCREEN.createInitialProfile()
	else
		SCREEN.Profiles = FileManager.decodeJsonFile(FileManager.Files.NEWRUN_PROFILES) or {}
	end
end

---Saves the current set of Profiles stored in this SCREEN to a JSON file, saved in the tracker files
---@return boolean success
function QuickloadScreen.saveProfiles()
	local success = FileManager.encodeToJsonFile(FileManager.Files.NEWRUN_PROFILES, SCREEN.Profiles or {})
	return success == true
end

function QuickloadScreen.createInitialProfile()
	SCREEN.Profiles = {}
	-- If no previous New Run method was used, create an empty profiles json
	if not (Options["Generate ROM each time"] or Options["Use premade ROMs"]) then
		FileManager.encodeToJsonFile(FileManager.Files.NEWRUN_PROFILES, SCREEN.Profiles)
		return
	end

	-- Leave GameVersion blank to auto-set when its first New Run occurs
	local profile = QuickloadScreen.IProfile:new({
		AttemptsCount = Main.currentSeed or 0,
	})

	-- Define initial profile attributes based on current New Run settings/files
	local quickloadFiles = Main.tempQuickloadFiles or Main.GetQuickloadFiles()
	if Options["Generate ROM each time"] then
		profile.Name = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1] or "") or ""
		profile.Mode = SCREEN.Modes.GENERATE
		profile.Paths.Settings = quickloadFiles.settingsList[1] or ""
		profile.Paths.Jar = quickloadFiles.jarList[1] or ""
		profile.Paths.Rom = quickloadFiles.romList[1] or ""
	else -- Options["Use premade ROMs"]
		local romsFolderName = FileManager.extractFolderNameFromPath(quickloadFiles.quickloadPath or "") or ""
		if not Utils.isNilOrEmpty(romsFolderName) then
			profile.Name = string.format("%s Premade ROMs", romsFolderName)
		end
		profile.Mode = SCREEN.Modes.PREMADE
		profile.Paths.RomsFolder = FileManager.tryAppendSlash(quickloadFiles.quickloadPath)
	end

	SCREEN.addUpdateProfile(profile, true)
end

---Adds a new profile or updates an existing profile in the `QuickloadScreen.Profiles` list
---@param profile IProfile
---@param setAsActive? boolean Optional, if true then this will also set the profile as the active profile; default false
---@return boolean success Returns true if the profile was successfully added; false otherwise
function QuickloadScreen.addUpdateProfile(profile, setAsActive)
	if not profile or Utils.isNilOrEmpty(profile.Mode) then
		return false
	end

	-- Check various attributes and auto-generate them if necessary
	if Utils.isNilOrEmpty(profile.GUID) then
		profile.GUID = Utils.newGUID()
	end
	if Utils.isNilOrEmpty(profile.Name) then
		profile.Name = string.format("Unknown Profile %s", profile.GUID:sub(1, 4))
	end
	if type(profile.Paths) ~= "table" then
		profile.Paths = {}
	end
	if Utils.isNilOrEmpty(profile.Paths.Tdat) then
		profile.Paths.Tdat = SCREEN.generateTdatFilePath(profile)
	end

	-- Add/update the profile to the list, and save
	SCREEN.Profiles[profile.GUID] = profile
	SCREEN.saveProfiles()
	if setAsActive then
		SCREEN.setActiveProfile(profile)
	end
	SCREEN.buildProfileButtons()
	return true
end

---Builds a full filepath to the TDAT file that will be used by the specified `profile`
---@param profile IProfile
---@return string filepath
function QuickloadScreen.generateTdatFilePath(profile)
	return FileManager.getTdatFolderPath() .. profile.Name .. FileManager.Extensions.TRACKED_DATA
end

---Returns a full filepath to the box art icon used to display this profile information
---@param profile? IProfile
---@return string filepath
function QuickloadScreen.getBoxArtIcon(profile)
	local iconName
	if not profile or Utils.isNilOrEmpty(profile.GameVersion) then
		iconName = "unknown"
	else
		iconName = profile.GameVersion
	end
	return FileManager.buildImagePath("boxart", iconName, ".png")
end

function QuickloadScreen.addEditProfilePrompt(profile)
	profile = profile or QuickloadScreen.IProfile:new()
	if profile.Paths == nil then
		profile.Paths = {}
	end

	local W, H = 500, 370
	local X = 15
	local FILE_BOX_W = 420
	local lineY = 10

	-- TODO: Language Resources

	local form = ExternalUI.BizForms.createForm("Add/Edit Profile", W, H, 50, 10)
	form.Controls.Generate = {}
	form.Controls.Premade = {}

	local function _updateVisibility()
		local isGenerate = ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate)
		local isPremade = ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade)
		for _, controlId in pairs(form.Controls.Generate) do
			ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.VISIBLE, isGenerate)
		end
		for _, controlId in pairs(form.Controls.Premade) do
			ExternalUI.BizForms.setProperty(controlId, ExternalUI.BizForms.Properties.VISIBLE, isPremade)
		end
	end
	local function _extractFolderPath(filepath)
		if not Utils.isNilOrEmpty(filepath) then
			local folder, _, _ = FileManager.getPathParts(filepath)
			return folder
		end
		return filepath
	end
	local function _autoUpdateBlueTextValues()
		if ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate) then
			local chosenRomText = FileManager.extractFileNameFromPath(profile.Paths.Rom or "", true)
			ExternalUI.BizForms.setText(form.Controls.Generate.labelChosenROM, chosenRomText)
			local chosenJarText = FileManager.extractFileNameFromPath(profile.Paths.Jar or "", true)
			ExternalUI.BizForms.setText(form.Controls.Generate.labelChosenJAR, chosenJarText)
			local chosenSettingsText = FileManager.extractFileNameFromPath(profile.Paths.Settings or "", true)
			ExternalUI.BizForms.setText(form.Controls.Generate.labelChosenSettings, chosenSettingsText)
			local createdRomName = FileManager.extractFileNameFromPath(chosenSettingsText)
			if not Utils.isNilOrEmpty(createdRomName) then
				createdRomName = string.format("%s %s%s", createdRomName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
			end
			ExternalUI.BizForms.setText(form.Controls.Generate.labelCreatedRomValue, createdRomName)
		elseif ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			local chosenFolderText = FileManager.extractFolderNameFromPath(profile.Paths.RomsFolder or "")
			ExternalUI.BizForms.setText(form.Controls.Premade.labelChosenFolder, chosenFolderText)
		end
	end
	local function _autoUpdateProfileName()
		-- Don't auto change the name if one already exists
		if not Utils.isNilOrEmpty(ExternalUI.BizForms.getText(form.Controls.textboxProfileName)) then
			return
		end
		local name
		if ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate) then
			local path = ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS)
			name = FileManager.extractFileNameFromPath(path)
		elseif ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			local path = ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER)
			local folderName = FileManager.extractFolderNameFromPath(path)
			if not Utils.isNilOrEmpty(folderName) then
				name = string.format("%s Premade ROMs", folderName)
			end
		end
		if not Utils.isNilOrEmpty(name) then
			ExternalUI.BizForms.setText(form.Controls.textboxProfileName, name)
		end
	end
	local function _verifyFilesAndUpdateButtons()
		local allVerified = true
		if ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate) then
			if Utils.isNilOrEmpty(ExternalUI.BizForms.getText(form.Controls.Generate.textboxROM)) then
				allVerified = false
			end
			if Utils.isNilOrEmpty(ExternalUI.BizForms.getText(form.Controls.Generate.textboxJAR)) then
				allVerified = false
			end
			if Utils.isNilOrEmpty(ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS)) then
				allVerified = false
			end
		elseif ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			if Utils.isNilOrEmpty(ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER)) then
				allVerified = false
			end
		else
			allVerified = false
		end
		ExternalUI.BizForms.setProperty(form.Controls.buttonSave, ExternalUI.BizForms.Properties.ENABLED, allVerified)
	end

	-- MODE
	form.Controls.labelMode = form:createLabel("Mode (choose one):", X, lineY)
	lineY = lineY + 20
	form.Controls.checkboxGenerate = form:createCheckbox("Generate new ROMs", X + 70, lineY, function()
		if ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate) then
			ExternalUI.BizForms.setChecked(form.Controls.checkboxPremade, false)
		end
		_updateVisibility()
	end)
	form.Controls.checkboxPremade = form:createCheckbox("Premade ROMs folder", X + 240, lineY, function()
		if ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			ExternalUI.BizForms.setChecked(form.Controls.checkboxGenerate, false)
		end
		_updateVisibility()
	end)
	lineY = lineY + 30

	-- SOURCE ROM
	form.Controls.Generate.labelROM = form:createLabel("Source ROM (a .GBA file):", X, lineY)
	form.Controls.Generate.labelChosenROM = form:createLabel("", X + 200, lineY)
	ExternalUI.BizForms.setProperty(form.Controls.Generate.labelChosenROM, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
	lineY = lineY + 20
	form.Controls.Generate.textboxROM = form:createTextBox(profile.Paths.Rom or "", X, lineY - 1, FILE_BOX_W, 20)
	form.Controls.Generate.buttonROM = form:createButton("...", X + FILE_BOX_W + 10, lineY - 5, function()
		local currentPath = ExternalUI.BizForms.getText(form.Controls.Generate.textboxROM)
		currentPath = _extractFolderPath(currentPath)
		local filterOptions = "GBA File (*.GBA)|*.gba|All files (*.*)|*.*"
		local newPath, success = ExternalUI.BizForms.openFilePrompt("SELECT A ROM", currentPath, filterOptions)
		if success then
			ExternalUI.BizForms.setText(form.Controls.Generate.textboxROM, newPath)
		end
		_verifyFilesAndUpdateButtons()
		_autoUpdateBlueTextValues()
	end, 35, 25)

	-- ROMS FOLDER
	lineY = lineY - 20
	form.Controls.Premade.labelROM = form:createLabel("Folder with randomized ROMs:", X, lineY)
	form.Controls.Premade.labelChosenFolder = form:createLabel("", X + 200, lineY)
	ExternalUI.BizForms.setProperty(form.Controls.Premade.labelChosenFolder, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
	lineY = lineY + 20
	form.Controls.Premade.textboxFOLDER = form:createTextBox(profile.Paths.RomsFolder or "", X, lineY - 1, FILE_BOX_W, 20)
	form.Controls.Premade.buttonFOLDER = form:createButton("...", X + FILE_BOX_W + 10, lineY - 4, function()
		local currentPath = ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER)
		currentPath = _extractFolderPath(currentPath)
		local filterOptions = "ROM File (*.GBA)|*.gba|All files (*.*)|*.*"
		local newPath, success = ExternalUI.BizForms.openFilePrompt("SELECT A ROM", currentPath, filterOptions)
		if success then
			newPath = _extractFolderPath(newPath)
			ExternalUI.BizForms.setText(form.Controls.Premade.textboxFOLDER, newPath or "")
			_autoUpdateProfileName()
		end
		_verifyFilesAndUpdateButtons()
		_autoUpdateBlueTextValues()
	end, 35, 25)
	lineY = lineY + 32

	-- RANDOMIZER JAR
	form.Controls.Generate.labelJAR = form:createLabel("Randomizer Program (a .JAR file):", X, lineY)
	form.Controls.Generate.labelChosenJAR = form:createLabel("", X + 200, lineY)
	ExternalUI.BizForms.setProperty(form.Controls.Generate.labelChosenJAR, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
	lineY = lineY + 20
	form.Controls.Generate.textboxJAR = form:createTextBox(profile.Paths.Jar or "", X, lineY - 1, FILE_BOX_W, 20)
	form.Controls.Generate.buttonJAR = form:createButton("...", X + FILE_BOX_W + 10, lineY - 4, function()
		local currentPath = ExternalUI.BizForms.getText(form.Controls.Generate.textboxJAR)
		currentPath = _extractFolderPath(currentPath)
		local filterOptions = "JAR File (*.JAR)|*.jar|All files (*.*)|*.*"
		local newPath, success = ExternalUI.BizForms.openFilePrompt("SELECT JAR", currentPath, filterOptions)
		if success then
			ExternalUI.BizForms.setText(form.Controls.Generate.textboxJAR, newPath)
		end
		_verifyFilesAndUpdateButtons()
		_autoUpdateBlueTextValues()
	end, 35, 25)
	lineY = lineY + 32

	-- SETTINGS FILE
	form.Controls.Generate.labelRNQS = form:createLabel("Randomizer Settings (a .RNQS file):", X, lineY)
	form.Controls.Generate.labelChosenSettings = form:createLabel("", X + 200, lineY)
	ExternalUI.BizForms.setProperty(form.Controls.Generate.labelChosenSettings, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
	lineY = lineY + 20
	form.Controls.Generate.textboxRNQS = form:createTextBox(profile.Paths.Settings or "", X, lineY - 1, FILE_BOX_W, 20)
	form.Controls.Generate.buttonSettings = form:createButton("...", X + FILE_BOX_W + 10, lineY - 4, function()
		local currentPath = ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS)
		currentPath = _extractFolderPath(currentPath)
		-- If the custom settings file hasn't ever been set, show the folder containing preloaded setting files
		if Utils.isNilOrEmpty(currentPath) then
			currentPath = FileManager.getRandomizerSettingsPath()
		end
		local filterOptions = "RNQS File (*.RNQS)|*.rnqs|All files (*.*)|*.*"
		local newPath, success = ExternalUI.BizForms.openFilePrompt("SELECT RNQS", currentPath, filterOptions)
		if success then
			ExternalUI.BizForms.setText(form.Controls.Generate.textboxRNQS, newPath)
			_autoUpdateProfileName()
		end
		_verifyFilesAndUpdateButtons()
		_autoUpdateBlueTextValues()
	end, 35, 25)
	lineY = lineY + 30
	form.Controls.Generate.labelCreatedRomName = form:createLabel("Tracker will create this ROM file:", X, lineY)
	form.Controls.Generate.labelCreatedRomValue = form:createLabel("", X + 200, lineY)
	ExternalUI.BizForms.setProperty(form.Controls.Generate.labelCreatedRomValue, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
	lineY = lineY + 20
	form.Controls.labelDivider = form:createLabel(string.rep("-", 200), X, lineY, W - X * 2 - 1, 20)
	lineY = lineY + 25

	-- NAME
	form.Controls.labelName = form:createLabel("Profile Name:", X, lineY)
	form.Controls.textboxProfileName = form:createTextBox(profile.Name or "", X + 144, lineY - 1, 275, 20)
	lineY = lineY + 30

	-- SAVE/CANCEL/HELP
	form.Controls.buttonSave = form:createButton(Resources.AllScreens.Save, X + 95, lineY, function()
		if ExternalUI.BizForms.isCheckedChecked(form.Controls.checkboxGenerate) then
			profile.Mode = SCREEN.Modes.GENERATE
			profile.Paths.Rom = ExternalUI.BizForms.getText(form.Controls.Generate.textboxROM) or ""
			profile.Paths.Jar = ExternalUI.BizForms.getText(form.Controls.Generate.textboxJAR) or ""
			profile.Paths.Settings = ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS) or ""
		elseif ExternalUI.BizForms.isCheckedChecked(form.Controls.checkboxPremade) then
			profile.Mode = SCREEN.Modes.PREMADE
			profile.Paths.RomsFolder = ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER) or ""
		else
			_verifyFilesAndUpdateButtons()
			_autoUpdateBlueTextValues()
			return
		end
		_autoUpdateProfileName()
		profile.Name = ExternalUI.BizForms.getText(form.Controls.textboxProfileName) or ""
		SCREEN.addUpdateProfile(profile)
		form:destroy()
		Program.redraw(true)
	end)
	form.Controls.buttonCancel = form:createButton(Resources.AllScreens.Cancel, X + 195, lineY, function()
		form:destroy()
	end)
	form.Controls.buttonHelp = form:createButton("Help Guide", X + 295, lineY, function()
		Utils.openBrowserWindow(FileManager.Urls.NEW_RUNS, Resources.NavigationMenu.MessageCheckConsole)
	end)

	-- OTHER SETUP
	if profile.Mode == SCREEN.Modes.PREMADE then
		ExternalUI.BizForms.setChecked(form.Controls.checkboxPremade, true)
	else
		ExternalUI.BizForms.setChecked(form.Controls.checkboxGenerate, true)
	end
	_verifyFilesAndUpdateButtons()
	_updateVisibility()
	_autoUpdateBlueTextValues()
end

---Sets the active profile used for New Runs to `profile`, updating the respective `Options.FILES` values to match
---@param profile IProfile
---@return boolean success
function QuickloadScreen.setActiveProfile(profile)
	if not profile or not (profile.Mode == SCREEN.Modes.GENERATE or profile.Mode == SCREEN.Modes.PREMADE) then
		return false
	end

	-- Apply profile's New Run settings to Tracker Options
	local isGenerateMode = profile.Mode == SCREEN.Modes.GENERATE
	Options["Selected Profile"] = profile.GUID
	Options["Generate ROM each time"] = isGenerateMode
	Options["Use premade ROMs"] = not isGenerateMode
	Options.FILES["ROMs Folder"] = not isGenerateMode and profile.Paths.RomsFolder or ""
	Options.FILES["Randomizer JAR"] = isGenerateMode and profile.Paths.Jar or ""
	Options.FILES["Source ROM"] = isGenerateMode and profile.Paths.Rom or ""
	Options.FILES["Settings File"] = isGenerateMode and profile.Paths.Settings or ""
	Main.ReadAttemptsCount(true)
	Main.SaveSettings(true)

	-- Double-check the attempts counts are correct (prioritize the file)
	if Main.currentSeed ~= profile.AttemptsCount then
		SCREEN.Profiles[profile.GUID].AttemptsCount = Main.currentSeed
		SCREEN.saveProfiles()
	end

	SCREEN.refreshButtons()

	return true
end

function QuickloadScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function QuickloadScreen.verifyOptions()
	local romfolderBtn = SCREEN.Buttons["ROMs Folder"]
	local jarBtn = SCREEN.Buttons["Randomizer JAR"]
	local gbaBtn = SCREEN.Buttons["Source ROM"]
	local rnqsBtn = SCREEN.Buttons["Settings File"]

	-- Determine if the files are setup properly based on Settings.ini filepaths or files found in [quickload] folder
	local quickloadFiles = Main.tempQuickloadFiles or Main.GetQuickloadFiles()
	romfolderBtn.isSet = (#quickloadFiles.romList > 1) -- ROMs correct if two or more roms found in 'quickloadPath' folder
	jarBtn.isSet = (#quickloadFiles.jarList == 1) -- JAR correct if exactly one file
	gbaBtn.isSet = (#quickloadFiles.romList == 1) -- GBA correct if exactly one file
	rnqsBtn.isSet = (#quickloadFiles.settingsList == 1) -- RNQS correct if exactly one file
end

function QuickloadScreen.handleSetRomFolder(button)
	local knownpath = Options.FILES[button.optionKey]
	local filterOptions = "ROM File (*.GBA)|*.gba|All files (*.*)|*.*"
	local filepath, success = ExternalUI.BizForms.openFilePrompt("SELECT A ROM", knownpath, filterOptions)
	if success then
		-- Since the user had to pick a file, strip out the file name to just get the folder path
		local pattern = "^.*()" .. FileManager.slash
		filepath = filepath:sub(0, (filepath:match(pattern) or 1) - 1)

		if Utils.isNilOrEmpty(filepath) then
			Options.FILES[button.optionKey] = ""
			button.isSet = false
		else
			Options.FILES[button.optionKey] = filepath
			button.isSet = true
			-- After changing the setup, read-in any existing attempts counter for the new quickload choice
			Main.ReadAttemptsCount()
		end

		Main.SaveSettings(true)
	end
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function QuickloadScreen.handleSetRandomizerJar(button)
	local knownpath = Options.FILES[button.optionKey]
	local filterOptions = "JAR File (*.JAR)|*.jar|All files (*.*)|*.*"
	local filepath, success = ExternalUI.BizForms.openFilePrompt("SELECT JAR", knownpath, filterOptions)
	if success then
		local extension = FileManager.extractFileExtensionFromPath(filepath)
		if extension == "jar" then
			Options.FILES[button.optionKey] = filepath
			button.isSet = true
			Main.SaveSettings(true)
		else
			Main.DisplayError("The file selected is not the Randomizer JAR file.\n\nPlease select the JAR file in the Randomizer ZX folder.")
		end
	end
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function QuickloadScreen.handleSetSourceRom(button)
	local knownpath = Options.FILES[button.optionKey]
	local filterOptions = "GBA File (*.GBA)|*.gba|All files (*.*)|*.*"
	local filepath, success = ExternalUI.BizForms.openFilePrompt("SELECT A ROM", knownpath, filterOptions)
	if success then
		local extension = FileManager.extractFileExtensionFromPath(filepath)
		if extension == "gba" then
			Options.FILES[button.optionKey] = filepath
			button.isSet = true
			Main.SaveSettings(true)
		else
			Main.DisplayError("The file selected is not a GBA ROM file.\n\nPlease select a GBA file: has the file extension \".gba\"")
		end
	end
	SCREEN.refreshButtons()
	Program.redraw(true)
end

function QuickloadScreen.handleSetCustomSettings(button)
	local knownpath = Options.FILES[button.optionKey]
	local filterOptions = "RNQS File (*.RNQS)|*.rnqs|All files (*.*)|*.*"

	-- If the custom settings file hasn't ever been set, show the folder containing preloaded setting files
	if Utils.isNilOrEmpty(knownpath) or not FileManager.fileExists(knownpath) then
		knownpath = FileManager.getRandomizerSettingsPath()
	end

	local filepath, success = ExternalUI.BizForms.openFilePrompt("SELECT RNQS", knownpath, filterOptions)
	if success then
		local extension = FileManager.extractFileExtensionFromPath(filepath)
		if extension == "rnqs" then
			Options.FILES[button.optionKey] = filepath
			button.isSet = true
			-- After changing the setup, read-in any existing attempts counter for the new quickload choice or force-create a new one if it doesn't exist
			Main.ReadAttemptsCount(true)
			Main.SaveSettings(true)
		else
			Main.DisplayError("The file selected is not a Randomizer Settings file.\n\nPlease select an RNQS file: has the file extension \".rnqs\"")
		end
	end
	SCREEN.refreshButtons()
	Program.redraw(true)
end

-- USER INPUT FUNCTIONS
function QuickloadScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
end

-- DRAWING FUNCTIONS
function QuickloadScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[SCREEN.Colors.boxFill])

	local canvas = {
		x = CANVAS.X,
		y = CANVAS.Y,
		width = CANVAS.W,
		height = CANVAS.H,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw header text
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, Utils.toUpperUTF8(Resources.QuickloadScreen.Title), Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	local offsetY = canvas.y

	-- Draw text to explain a choice should be made
	offsetY = offsetY + 18
	local chooseText = string.format("%s:", Resources.QuickloadScreen.ChoiceHeader)
	-- Drawing.drawText(canvas.x + 2, offsetY, chooseText, canvas.text, canvas.shadow)
	offsetY = offsetY + Constants.SCREEN.LINESPACING + 1

	local boxes = {
		{ x = canvas.x + 4, y = offsetY, w = canvas.width - 8, h = 30, },
		{ x = canvas.x + 4, y = offsetY + 30, w = canvas.width - 8, h = 60, },
	}
	-- for _, box in ipairs(boxes) do
	-- 	gui.drawRectangle(box.x + 1, box.y + 1, box.w, box.h, canvas.shadow)
	-- 	gui.drawRectangle(box.x, box.y, box.w, box.h, Theme.COLORS[SCREEN.Colors.border], Theme.COLORS[SCREEN.Colors.boxFill])
	-- end

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

-- Profile object prototypes

---@class IProfile
QuickloadScreen.IProfile = {
	-- Required unique GUID
	GUID = "",
	-- Display Name
	Name = "",
	-- New Run Mode, either: SCREEN.Modes. "Generate" or "Premade"
	Mode = "",
	-- Game Version color, all lowercase
	GameVersion = "",
	-- Attempts Count for this profile
	AttemptsCount = 0,
	-- Date the profile was last used for New Run
	LastUsedDate = 0,
	-- Available Paths used by this profile
	Paths = {},
}
---Creates and returns a new IProfile object
---@param o? table Optional initial object table
---@return IProfile profile An IProfile object
function QuickloadScreen.IProfile:new(o)
	o = o or {}
	o.GUID = o.GUID or Utils.newGUID()
	o.LastUsedDate = o.LastUsedDate or os.time()
	o.Paths = o.Paths or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

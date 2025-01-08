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
		Options = {
			index = 3,
			tabKey = "Options",
			resourceKey = "TabOptions",
		},
	},
	currentTab = nil,
	Profiles = {}, -- populated from JSON as a luatable: { [GUID] = IProfile() }
	FORCE_UPDATE_GAME_VERSION = "ForceUpdateGameVersion",
	PREMADE_ROMS_NAME_FORMAT = "%s Premade"
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

SCREEN.Buttons = {
	-- Description + Button Combo
	NewRunsDescription = {
		type = Constants.ButtonTypes.NO_BORDER,
		getCustomText = function()
			local profile = SCREEN.getActiveProfile()
			if profile and profile.Mode == SCREEN.Modes.PREMADE then
				return string.format("%s:", Resources.QuickloadScreen.NewRunsDescPremade)
			else
				return string.format("%s:", Resources.QuickloadScreen.NewRunsDescGenerate)
			end
		end,
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
	ActiveGameProfile = {
		type = Constants.ButtonTypes.FULL_BORDER,
		box = { CANVAS.X + 3, CANVAS.Y + 61, CANVAS.W - 6, 33 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General end,
		onClick = function(self)
			local profile = QuickloadScreen.getActiveProfile()
			SCREEN.addEditProfilePrompt(profile)
			-- If needing to add new profile, swap to showing the profile list
			if not profile then
				SCREEN.changeTabWithDelay(SCREEN.Tabs.Profiles)
			end
		end,
		draw = function(self, shadowcolor)
			local profile = QuickloadScreen.getActiveProfile()
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local textColor = Theme.COLORS[SCREEN.Colors.text]
			local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
			-- Draw Header
			Drawing.drawText(x, y - 11, string.format("%s:", Resources.QuickloadScreen.LabelActiveProfile), textColor, shadowcolor)
			-- Draw Icon
			local iconFilepath = SCREEN.getBoxArtIcon(profile)
			Drawing.drawImage(iconFilepath, x + 1, y + 1, 32, 32)
			gui.drawLine(x + 33, y, x + 33, y + 32, Theme.COLORS[SCREEN.Colors.border])
			-- Draw Profile Information
			local col2X = x + 35
			if not profile then
				Drawing.drawText(col2X, y + 5, Resources.QuickloadScreen.LabelNoActiveProfile, highlightColor, shadowcolor)
				Drawing.drawText(col2X, y + 15, Resources.QuickloadScreen.LabelClickToAdd, textColor - 0x20000000, shadowcolor)
				return
			end
			local name = Utils.shortenText(profile.Name or "", 96, true)
			Drawing.drawText(col2X, y + 1, string.format("%s", name), highlightColor, shadowcolor)

			local attemptsFormatted
			if (profile.AttemptsCount or 0) == 0 then
				attemptsFormatted = Constants.BLANKLINE
			else
				attemptsFormatted = tostring(profile.AttemptsCount)
			end
			Drawing.drawText(col2X, y + 11, string.format("%s: %s", Resources.QuickloadScreen.LabelProfileAttempts, attemptsFormatted), textColor, shadowcolor)

			local dateFormatted
			if (profile.LastUsedDate or 0) == 0 then
				dateFormatted = Constants.BLANKLINE
			else
				dateFormatted = os.date("%x", profile.LastUsedDate) -- date, (e.g., 09/16/98)
			end
			if type(dateFormatted) == "string" then
				Drawing.drawText(col2X, y + 21, string.format("%s: %s", Resources.QuickloadScreen.LabelProfileLastPlayed, dateFormatted), textColor - 0x30000000, shadowcolor)
			end
		end,
	},
	LoadLastPlayedGame = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.QuickloadScreen.ButtonLoadLastGame end,
		box = { CANVAS.X + 23, CANVAS.Y + 98, 94, 11 },
		isVisible = function(self)
			if SCREEN.currentTab ~= SCREEN.Tabs.General then
				return false
			end
			local profile = SCREEN.getActiveProfile()
			return profile and not Utils.isNilOrEmpty(profile.Paths.CurrentRom)
		end,
		onClick = function(self)
			SCREEN.loadCurrentGamePrompt()
		end,
	},
	LoadNextSeed = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			local profile = SCREEN.getActiveProfile()
			if profile and profile.Mode == SCREEN.Modes.PREMADE then
				return Resources.QuickloadScreen.ButtonGoNextSeed
			else
				return Resources.QuickloadScreen.ButtonCreateNewGame
			end
		end,
		box = { CANVAS.X + 23, CANVAS.Y + 113, 94, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.General and SCREEN.getActiveProfile() ~= nil end,
		onClick = function(self)
			SCREEN.loadNextSeedPrompt()
		end,
	},
	AddNewProfile = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.QuickloadScreen.ButtonAddNew end,
		box = { CANVAS.X + 3, CANVAS.Y + 114, 42, 11 },
		isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Profiles end,
		onClick = function(self)
			SCREEN.addEditProfilePrompt()
		end,
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { CANVAS.X + 60, CANVAS.Y + 114, 50, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { CANVAS.X + 53, CANVAS.Y + 115, 10, 10, },
		isVisible = function() return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { CANVAS.X + 97, CANVAS.Y + 115, 10, 10, },
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
		-- Snap each individual button to their respective button rows
		for _, buttonRow in ipairs(self.Buttons) do
			for _, button in ipairs (buttonRow.buttonList or {}) do
				if type(button.alignToBox) == "function" and buttonRow.box then
					button:alignToBox(buttonRow.box)
				end
			end
		end
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
	SCREEN.loadProfiles()
	SCREEN.checkForActiveProfileChanges()
	SCREEN.buildProfileButtons()

	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end

	NavigationMenu.refreshButtons()
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
				SCREEN.Pager.currentPage = 1
				SCREEN.refreshButtons()
				Program.redraw(true)
			end,
		}
		startX = startX + tabWidth
	end
end

function QuickloadScreen.changeTabWithDelay(tab, framesToDelay)
	Program.addFrameCounter("QuickloadScreenChangeTab", framesToDelay or 1, function()
		SCREEN.currentTab = tab
		SCREEN.refreshButtons()
		Program.redraw(true)
	end, 1)
end

function QuickloadScreen.checkForActiveProfileChanges()
	local profile = SCREEN.getActiveProfile() or {}
	local saveProfiles, saveSettings = false, false
	-- Checks if the active profile still needs it's game version update.
	-- This can only be performed after a successful New Run is completed, as it requires a game ROM from that profile to be created to know it's game version
	if profile.GameVersion == QuickloadScreen.FORCE_UPDATE_GAME_VERSION and GameSettings.versioncolor then
		profile.GameVersion = Utils.toLowerUTF8(GameSettings.versioncolor)
		saveProfiles = true
	end
	-- Update the game over condition if it's different due to profile
	if Options["Game Over condition"] ~= profile.GameOverCondition and not Utils.isNilOrEmpty(profile.GameOverCondition) then
		Options["Game Over condition"] = profile.GameOverCondition
		saveSettings = true
	end
	if saveProfiles then
		SCREEN.saveProfiles()
	end
	if saveSettings then
		Main.SaveSettings(true)
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

	-- X offsets for buttons associated with each profile row
	local PROFILE_H = 33
	local SELECT_X = 33
	local EDIT_X = 70
	local DEL_X = 97

	local activeProfile = SCREEN.getActiveProfile()

	-- Build buttons for each profile
	for i, profile in ipairs(profiles) do
		local borderColor = profile == activeProfile and SCREEN.Colors.positive or SCREEN.Colors.border
		local buttonRow = {
			type = Constants.ButtonTypes.NO_BORDER,
			buttonList = {},
			profile = profile,
			index = i,
			dimensions = { width = CANVAS.W - 6, height = 45 },
			isVisible = function(self) return SCREEN.currentTab == SCREEN.Tabs.Profiles and SCREEN.Pager.currentPage == self.pageVisible end,
			draw = function(self, shadowcolor)
				for _, button in ipairs(self.buttonList or {}) do
					Drawing.drawButton(button, shadowcolor)
				end
			end,
		}
		table.insert(SCREEN.Pager.Buttons, buttonRow)

		local profileInfoBox = {
			type = Constants.ButtonTypes.FULL_BORDER,
			box = { -1, -1, CANVAS.W - 6, PROFILE_H },
			textColor = SCREEN.Colors.text,
			boxColors = { borderColor, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			alignToBox = function(self, box)
				self.box[1] = box[1]
				self.box[2] = box[2]
			end,
			draw = function(self, shadowcolor)
				local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
				local textColor = Theme.COLORS[SCREEN.Colors.text]
				local highlightColor = Theme.COLORS[SCREEN.Colors.highlight]
				-- Draw Icon
				local iconFilepath = SCREEN.getBoxArtIcon(buttonRow.profile)
				Drawing.drawImage(iconFilepath, x + 1, y + 1, 32, 32)
				gui.drawLine(x + 33, y, x + 33, y + 32, Theme.COLORS[self.boxColors[1]])
				-- Draw Profile Information
				local col2X = x + 35
				local name = Utils.shortenText(buttonRow.profile.Name or "", 96, true)
				Drawing.drawText(col2X, y + 1, name, highlightColor, shadowcolor)

				local attemptsFormatted
				if (buttonRow.profile.AttemptsCount or 0) == 0 then
					attemptsFormatted = Constants.BLANKLINE
				else
					attemptsFormatted = tostring(buttonRow.profile.AttemptsCount)
				end
				Drawing.drawText(col2X, y + 11, string.format("%s: %s", Resources.QuickloadScreen.LabelProfileAttempts, attemptsFormatted), textColor, shadowcolor)

				local dateFormatted
				if (buttonRow.profile.LastUsedDate or 0) == 0 then
					dateFormatted = Constants.BLANKLINE
				else
					dateFormatted = os.date("%x", buttonRow.profile.LastUsedDate) -- date, (e.g., 09/16/98)
				end
				if type(dateFormatted) == "string" then
					Drawing.drawText(col2X, y + 21, string.format("%s: %s", Resources.QuickloadScreen.LabelProfileLastPlayed, dateFormatted), textColor - 0x30000000, shadowcolor)
				end
			end,
		}
		table.insert(buttonRow.buttonList, profileInfoBox)

		local btnSelectProfile = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return string.format(" %s", Resources.QuickloadScreen.ButtonSelectProfile) end,
			box = { -1, -1, 37, 11 },
			textColor = SCREEN.Colors.text,
			boxColors = { borderColor, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() and profile ~= activeProfile end,
			alignToBox = function(self, box)
				self.box[1] = box[1] + SELECT_X
				self.box[2] = box[2] + PROFILE_H
			end,
			onClick = function(self)
				SCREEN.setActiveProfile(buttonRow.profile)
				SCREEN.changeTabWithDelay(SCREEN.Tabs.General)
			end,
		}
		table.insert(buttonRow.buttonList, btnSelectProfile)

		local btnEditProfile = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return string.format(" %s", Resources.QuickloadScreen.ButtonEditProfile) end,
			box = { -1, -1, 27, 11 },
			textColor = SCREEN.Colors.text,
			boxColors = { borderColor, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			alignToBox = function(self, box)
				self.box[1] = box[1] + EDIT_X
				self.box[2] = box[2] + PROFILE_H
			end,
			onClick = function(self)
				SCREEN.addEditProfilePrompt(buttonRow.profile)
			end,
		}
		table.insert(buttonRow.buttonList, btnEditProfile)

		local btnDeleteProfile = {
			type = Constants.ButtonTypes.FULL_BORDER,
			getText = function(self) return string.format(" %s", Resources.QuickloadScreen.ButtonDeleteProfile) end,
			box = { -1, -1, 37, 11 },
			textColor = SCREEN.Colors.text,
			boxColors = { borderColor, SCREEN.Colors.boxFill },
			isVisible = function(self) return buttonRow:isVisible() end,
			alignToBox = function(self, box)
				self.box[1] = box[1] + DEL_X
				self.box[2] = box[2] + PROFILE_H
			end,
			onClick = function(self)
				SCREEN.confirmProfileDeletePrompt(buttonRow.profile)
			end,
		}
		table.insert(buttonRow.buttonList, btnDeleteProfile)
	end

	-- Make the add new button stand out if there are no profiles
	if #SCREEN.Pager.Buttons == 0 then
		SCREEN.Buttons.AddNewProfile.textColor = SCREEN.Colors.positive
	else
		SCREEN.Buttons.AddNewProfile.textColor = SCREEN.Colors.text
	end

	SCREEN.Pager:realignButtonsToGrid(CANVAS.X + 3, CANVAS.Y + 4, 0, 8)
	SCREEN.refreshButtons()
end

---Returns the currently active profile used for New Runs; or nil if none in use
---@return IProfile|nil profile
function QuickloadScreen.getActiveProfile()
	return SCREEN.Profiles[Options["Active Profile"] or ""]
end

---Loads or creates a set of Profiles from the JSON file stored in the Tracker folder
function QuickloadScreen.loadProfiles()
	SCREEN.Profiles = {}
	local jsonFile = FileManager.prependDir(FileManager.Files.NEWRUN_PROFILES)
	if FileManager.fileExists(jsonFile) then
		SCREEN.Profiles = FileManager.decodeJsonFile(jsonFile) or {}
	elseif Options["Generate ROM each time"] or Options["Use premade ROMs"] then
		SCREEN.createInitialProfile()
	else
		-- If no previous New Run method was used, create an empty profiles json
		SCREEN.saveProfiles()
	end
end

---Saves the current set of Profiles stored in this SCREEN to a JSON file, saved in the tracker files
---@return boolean success
function QuickloadScreen.saveProfiles()
	local jsonFile = FileManager.prependDir(FileManager.Files.NEWRUN_PROFILES)
	local success = FileManager.encodeToJsonFile(jsonFile, SCREEN.Profiles or {})
	return success == true
end

---Auto-creates a profile based on current legacy New Run settings, for Tracker versions that didn't have profiles originally
function QuickloadScreen.createInitialProfile()
	-- Leave GameVersion blank to auto-set when its first New Run occurs
	local profile = QuickloadScreen.IProfile:new({
		GameOverCondition = Options["Game Over condition"],
		AttemptsCount = Main.currentSeed or 0,
		LastUsedDate = os.time(),
	})

	-- Define initial profile attributes based on current New Run settings/files
	local quickloadFiles = Main.tempQuickloadFiles or Main.GetQuickloadFiles()
	if Options["Generate ROM each time"] then
		profile.Name = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1] or "") or ""
		profile.Mode = SCREEN.Modes.GENERATE
		profile.Paths.Settings = quickloadFiles.settingsList[1] or ""
		profile.Paths.Jar = quickloadFiles.jarList[1] or ""
		profile.Paths.Rom = quickloadFiles.romList[1] or ""
	elseif Options["Use premade ROMs"] then
		local romsFolderName = FileManager.extractFolderNameFromPath(quickloadFiles.quickloadPath or "") or ""
		if not Utils.isNilOrEmpty(romsFolderName) then
			profile.Name = string.format(SCREEN.PREMADE_ROMS_NAME_FORMAT, romsFolderName)
		end
		profile.Mode = SCREEN.Modes.PREMADE
		profile.Paths.RomsFolder = FileManager.tryAppendSlash(quickloadFiles.quickloadPath)
	else
		return
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
	if Utils.isNilOrEmpty(profile.GameOverCondition) then
		profile.GameOverCondition = Options["Game Over condition"]
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

---Called after a successful New Run is performed
---@param romFilepath? string Filepath to the newly created/loaded game ROM file
function QuickloadScreen.afterNewRunProfileCheckup(romFilepath)
	local profile = QuickloadScreen.getActiveProfile()
	if not profile then
		return
	end
	-- Check if this profile's game version has not yet been set/updated (requires loading a newly created rom to deterine version)
	if Utils.isNilOrEmpty(profile.GameVersion) then
		profile.GameVersion = QuickloadScreen.FORCE_UPDATE_GAME_VERSION
	end
	profile.AttemptsCount = Main.currentSeed
	profile.LastUsedDate = os.time()
	if not Utils.isNilOrEmpty(romFilepath) then
		profile.Paths.CurrentRom = romFilepath
	end

	SCREEN.saveProfiles()
end

---Removes an existing profile from the `QuickloadScreen.Profiles` list
---@param profile IProfile
function QuickloadScreen.deleteProfile(profile)
	if not profile then
		return
	end
	-- If being used as the active profile, remove that reference
	if profile.GUID == Options["Active Profile"] then
		Options["Active Profile"] = ""
		Options["Generate ROM each time"] = false
		Options["Use premade ROMs"] = false
		Options.FILES["ROMs Folder"] = ""
		Options.FILES["Randomizer JAR"] = ""
		Options.FILES["Source ROM"] = ""
		Options.FILES["Settings File"] = ""
	end
	SCREEN.Profiles[profile.GUID] = nil
	SCREEN.saveProfiles()
	SCREEN.buildProfileButtons()
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

---Sets the active profile used for New Runs to `profile`, updating the respective `Options.FILES` values to match
---@param profile IProfile
---@return boolean success
function QuickloadScreen.setActiveProfile(profile)
	if not profile or Utils.isNilOrEmpty(profile.Mode) then
		return false
	end

	-- Apply profile's New Run settings to Tracker Options
	Options["Active Profile"] = profile.GUID
	if not Utils.isNilOrEmpty(profile.GameOverCondition) then
		Options["Game Over condition"] = profile.GameOverCondition
	end
	local isGenerateMode = profile.Mode == SCREEN.Modes.GENERATE
	Options["Generate ROM each time"] = isGenerateMode
	Options["Use premade ROMs"] = not isGenerateMode
	Options.FILES["ROMs Folder"] = not isGenerateMode and profile.Paths.RomsFolder or ""
	Options.FILES["Randomizer JAR"] = isGenerateMode and profile.Paths.Jar or ""
	Options.FILES["Source ROM"] = isGenerateMode and profile.Paths.Rom or ""
	Options.FILES["Settings File"] = isGenerateMode and profile.Paths.Settings or ""
	Main.SaveSettings(true)

	-- Since the New Run settings changed, load in the attempts count
	Main.ReadAttemptsCount(isGenerateMode)

	-- Update the attempts number to match
	if profile.AttemptsCount ~= Main.currentSeed then
		profile.AttemptsCount = Main.currentSeed
		SCREEN.saveProfiles()
	end

	if Program.currentScreen == SCREEN then
		SCREEN.buildProfileButtons()
		SCREEN.refreshButtons()
	end

	return true
end

function QuickloadScreen.loadCurrentGamePrompt()
	local profile = SCREEN.getActiveProfile()
	if not profile or Utils.isNilOrEmpty(profile.Paths.CurrentRom) then
		return
	end

	local form = ExternalUI.BizForms.createForm("Load Game?", 300, 175)
	local X = 15
	local lineY = 10
	form.Controls.labelDescription = form:createLabel("Load the most recently played game for this profile?", X, lineY)
	lineY = lineY + 25
	form.Controls.labelGameName = form:createLabel("ROM Name:", X, lineY)
	lineY = lineY + 25
	local romName = FileManager.extractFileNameFromPath(profile.Paths.CurrentRom, true) or ""
	form.Controls.labelProfileName = form:createLabel(romName, X, lineY)
	lineY = lineY + 35

	-- YES/NO
	form.Controls.buttonYes = form:createButton(Resources.AllScreens.Yes, X + 50, lineY, function()
		-- This will force the Tracker to load this rom on the next available frame
		Main.loadDifferentRom = profile.Paths.CurrentRom
		form:destroy()
	end)
	form.Controls.buttonNo = form:createButton(Resources.AllScreens.No, X + 140, lineY, function()
		form:destroy()
	end)
end

function QuickloadScreen.loadNextSeedPrompt()
	local profile = SCREEN.getActiveProfile()
	if not profile then
		return
	end

	local form = ExternalUI.BizForms.createForm("Activate A New Run?", 280, 150)
	local X = 15
	local lineY = 10
	local profileAction
	if profile.Mode == SCREEN.Modes.PREMADE then
		profileAction = "Load next seed"
	else
		profileAction = "Create a new game"
	end
	form.Controls.labelDescription = form:createLabel(string.format("%s for this profile?", profileAction), X, lineY)
	lineY = lineY + 25
	form.Controls.labelProfileName = form:createLabel(string.format("Profile Name:  %s", profile.Name), X, lineY)
	lineY = lineY + 35

	-- YES/NO
	form.Controls.buttonYes = form:createButton(Resources.AllScreens.Yes, X + 40, lineY, function()
		form:destroy()
		Main.loadNextSeed = true
	end)
	form.Controls.buttonNo = form:createButton(Resources.AllScreens.No, X + 130, lineY, function()
		form:destroy()
	end)
end

---@param profile? IProfile If no profile provided, will create/add a new profile; otherwise edits the provided profile
function QuickloadScreen.addEditProfilePrompt(profile)
	local isNewProfile = profile == nil
	profile = profile or QuickloadScreen.IProfile:new({
		AttemptsCount = 0,
	})
	if profile.Paths == nil then
		profile.Paths = {}
	end

	local W, H = 500, 400
	local X = 15
	local FILE_BOX_W = 420
	local lineY = 10

	local form = ExternalUI.BizForms.createForm("Add/Edit Profile", W, H, 50, 10)
	form.Controls.Generate = {}
	form.Controls.Premade = {}

	local dropdownOptionsGameOver = {
		Resources.GameOptionsScreen.OptionLeadPokemonFaints,
		Resources.GameOptionsScreen.OptionHighestLevelFaints,
		Resources.GameOptionsScreen.OptionEntirePartyFaints,
	}

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
			local chosenRomText = FileManager.extractFileNameFromPath(ExternalUI.BizForms.getText(form.Controls.Generate.textboxROM) or "", true)
			ExternalUI.BizForms.setText(form.Controls.Generate.labelChosenROM, chosenRomText)
			local chosenJarText = FileManager.extractFileNameFromPath(ExternalUI.BizForms.getText(form.Controls.Generate.textboxJAR) or "", true)
			ExternalUI.BizForms.setText(form.Controls.Generate.labelChosenJAR, chosenJarText)
			local chosenSettingsText = FileManager.extractFileNameFromPath(ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS) or "", true)
			ExternalUI.BizForms.setText(form.Controls.Generate.labelChosenSettings, chosenSettingsText)
			local createdRomName = FileManager.extractFileNameFromPath(chosenSettingsText)
			if not Utils.isNilOrEmpty(createdRomName) then
				createdRomName = string.format("%s %s%s", createdRomName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
			end
			ExternalUI.BizForms.setText(form.Controls.Generate.labelCreatedRomValue, createdRomName)
		elseif ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			local chosenFolderText = FileManager.extractFolderNameFromPath(ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER) or "")
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
				name = string.format(SCREEN.PREMADE_ROMS_NAME_FORMAT, folderName)
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
	local function _isProfileNameValid()
		local name = ExternalUI.BizForms.getText(form.Controls.textboxProfileName)
		if Utils.isNilOrEmpty(name) then
			return true
		end
		if name:find(FileManager.INVALID_FILE_PATTERN) ~= nil then
			return false
		end
		for _, profileToCheck in pairs(SCREEN.Profiles or {}) do
			-- If a different profile but the same exact name, fail
			if profileToCheck.Name == name and profileToCheck.GUID ~= profile.GUID then
				return false
			end
		end
		return true
	end
	local function _autoUpdateGameOverDropdown()
		local extractedName
		if ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate) then
			local path = ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS)
			extractedName = FileManager.extractFileNameFromPath(path)
		elseif ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			local path = ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER)
			extractedName = FileManager.extractFolderNameFromPath(path)
		end
		local text, selectedOption
		if Utils.containsText(extractedName, "Standard", true) or Utils.containsText(extractedName, "Ultimate", true) then
			selectedOption = "EntirePartyFaints"
			text = dropdownOptionsGameOver[3]
		else -- Kaizo, Survival, etc.
			selectedOption = "LeadPokemonFaints"
			text = dropdownOptionsGameOver[1]
		end
		if form.Controls.dropdownGameOver then
			ExternalUI.BizForms.setText(form.Controls.dropdownGameOver, text)
			if form.Controls.labelGameOverChanged then
				ExternalUI.BizForms.setProperty(form.Controls.labelGameOverChanged, ExternalUI.BizForms.Properties.VISIBLE, true)
			end
		end
		return selectedOption
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
	-- Don't allow changing the mode for existing profiles
	if not isNewProfile then
		ExternalUI.BizForms.setProperty(form.Controls.checkboxGenerate, ExternalUI.BizForms.Properties.ENABLED, false)
		ExternalUI.BizForms.setProperty(form.Controls.checkboxPremade, ExternalUI.BizForms.Properties.ENABLED, false)
	end
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
		_autoUpdateGameOverDropdown()
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
		_autoUpdateGameOverDropdown()
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
	form.Controls.textboxProfileName = form:createTextBox(profile.Name or "", X + 181, lineY - 2, 240, 20)
	lineY = lineY + 25

	-- GAME OVER SETTING
	local selectedGameOverOption
	if not Utils.isNilOrEmpty(profile.GameOverCondition) then
		local gameoverKey = profile.GameOverCondition
		local resourceKey = string.format("Option%s", gameoverKey)
		selectedGameOverOption = Resources.GameOptionsScreen[resourceKey]
	else
		local gameoverKey = _autoUpdateGameOverDropdown()
		local resourceKey = string.format("Option%s", gameoverKey)
		selectedGameOverOption = Resources.GameOptionsScreen[resourceKey] or dropdownOptionsGameOver[1]
	end
	local gameoverLabelText = string.format("%s:", Resources.GameOptionsScreen.LabelGameOverCondition)
	form.Controls.labelGameOver = form:createLabel(gameoverLabelText, X, lineY)
	form.Controls.dropdownGameOver = form:createDropdown(dropdownOptionsGameOver, X + 181, lineY - 2, 240, 20, selectedGameOverOption, false)
	form.Controls.labelGameOverChanged = form:createLabel("*", X + 423, lineY)
	ExternalUI.BizForms.setProperty(form.Controls.labelGameOverChanged, ExternalUI.BizForms.Properties.FORE_COLOR, "blue")
	ExternalUI.BizForms.setProperty(form.Controls.labelGameOverChanged, ExternalUI.BizForms.Properties.VISIBLE, false)
	lineY = lineY + 30

	-- SAVE/CANCEL/HELP
	form.Controls.buttonSave = form:createButton(Resources.AllScreens.Save, X + 95, lineY, function()
		_autoUpdateProfileName()
		if not _isProfileNameValid() then
			ExternalUI.BizForms.setProperty(form.Controls.labelName, ExternalUI.BizForms.Properties.FORE_COLOR, "red")
			return
		end
		ExternalUI.BizForms.setProperty(form.Controls.labelName, ExternalUI.BizForms.Properties.FORE_COLOR, "black")

		if ExternalUI.BizForms.isChecked(form.Controls.checkboxGenerate) then
			profile.Mode = SCREEN.Modes.GENERATE
			profile.Paths.Rom = ExternalUI.BizForms.getText(form.Controls.Generate.textboxROM) or ""
			profile.Paths.Jar = ExternalUI.BizForms.getText(form.Controls.Generate.textboxJAR) or ""
			profile.Paths.Settings = ExternalUI.BizForms.getText(form.Controls.Generate.textboxRNQS) or ""
		elseif ExternalUI.BizForms.isChecked(form.Controls.checkboxPremade) then
			profile.Mode = SCREEN.Modes.PREMADE
			profile.Paths.RomsFolder = ExternalUI.BizForms.getText(form.Controls.Premade.textboxFOLDER) or ""
		else
			_verifyFilesAndUpdateButtons()
			_autoUpdateBlueTextValues()
			return
		end
		local oldProfileName = profile.Name
		profile.Name = ExternalUI.BizForms.getText(form.Controls.textboxProfileName) or ""
		-- If the name changes, update related files to match
		if oldProfileName ~= profile.Name then
			if FileManager.fileExists(profile.Paths.Tdat) then
				local newTdatFilepath = SCREEN.generateTdatFilePath(profile)
				FileManager.CopyFile(profile.Paths.Tdat, newTdatFilepath)
				FileManager.deleteFile(profile.Paths.Tdat)
				profile.Paths.Tdat = newTdatFilepath
			end
		end
		-- Set the GameOver condition
		local selectedGameOverDropdown = ExternalUI.BizForms.getText(form.Controls.dropdownGameOver) or ""
		if selectedGameOverDropdown == dropdownOptionsGameOver[1] then
			profile.GameOverCondition = "LeadPokemonFaints"
		elseif selectedGameOverDropdown == dropdownOptionsGameOver[2] then
			profile.GameOverCondition = "HighestLevelFaints"
		elseif selectedGameOverDropdown == dropdownOptionsGameOver[3] then
			profile.GameOverCondition = "EntirePartyFaints"
		else
			profile.GameOverCondition = Options["Game Over condition"]
		end
		-- If no active profile has been selected yet, use this newly added one; or update active profile if this is the same one
		local activeProfile = SCREEN.getActiveProfile()
		local useThisAsActive = activeProfile == nil or activeProfile.GUID == profile.GUID
		SCREEN.addUpdateProfile(profile, useThisAsActive)
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

---@param profile IProfile
function QuickloadScreen.confirmProfileDeletePrompt(profile)
	if not profile then
		return
	end

	local form = ExternalUI.BizForms.createForm("Delete Profile?", 280, 150)
	local X = 15
	local lineY = 10
	form.Controls.labelDescription = form:createLabel("Are you sure you want to delete the profile:", X, lineY)
	lineY = lineY + 25
	form.Controls.labelProfileName = form:createLabel(profile.Name, X + 20, lineY)
	lineY = lineY + 35

	-- YES/NO
	form.Controls.buttonYes = form:createButton(Resources.AllScreens.Yes, X + 40, lineY, function()
		SCREEN.deleteProfile(profile)
		form:destroy()
		Program.redraw(true)
	end)
	form.Controls.buttonNo = form:createButton(Resources.AllScreens.No, X + 130, lineY, function()
		form:destroy()
	end)
end

---Returns the ROM filename (includes file extension) used by the specified `profile`
---@param profile? table Optional, uses the specific profile to retrieve name & path; default uses currently loaded game profile
---@return string filename
function QuickloadScreen.getGameProfileRomName(profile)
	profile = profile or QuickloadScreen.getActiveProfile() or {}

	local filename
	if profile.Mode == QuickloadScreen.Modes.GENERATE then
		-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
		local settingsFileName = FileManager.extractFileNameFromPath(profile.Paths.Settings or "")
		filename = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
	elseif profile.Mode == QuickloadScreen.Modes.PREMADE then
		filename = GameSettings.getRomName()
		local filepath = (profile.Paths.RomsFolder or "") .. filename .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(filepath) then
			-- File doesn't exist, try again with underscores instead of spaces (awkward Bizhawk issue)
			filename = filename:gsub(" ", "_")
		end
	end

	return filename or (GameSettings.getRomName() .. FileManager.Extensions.GBA_ROM)
end

---Returns the full ROM filepath used by the specified `profile`
---@param profile? table Optional, uses the specific profile to retrieve path; default uses currently loaded game profile
---@return string filepath
function QuickloadScreen.getGameProfileRomPath(profile)
	profile = profile or SCREEN.getActiveProfile() or {}
	local filepath
	if profile.Mode == SCREEN.Modes.GENERATE then
		-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
		local settingsFileName = FileManager.extractFileNameFromPath(profile.Paths.Settings or "")
		local filename = string.format("%s %s%s", settingsFileName, FileManager.PostFixes.AUTORANDOMIZED, FileManager.Extensions.GBA_ROM)
		filepath = FileManager.prependDir(filename)
	elseif profile.Mode == SCREEN.Modes.PREMADE then
		local filename = GameSettings.getRomName()
		filepath = (profile.Paths.RomsFolder or "") .. filename .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(filepath) then
			-- File doesn't exist, try again with underscores instead of spaces (awkward Bizhawk issue)
			filename = filename:gsub(" ", "_")
			filepath = (profile.Paths.RomsFolder or "") .. filename .. FileManager.Extensions.GBA_ROM
		end
	end
	return filepath or (GameSettings.getRomName() .. FileManager.Extensions.GBA_ROM)
end

---Returns the full TDAT filepath used by the specified `profile`
---@param profile? table Optional, uses the specific profile to retrieve path; default uses currently loaded game profile
---@return string filepath
function QuickloadScreen.getGameProfileTdatPath(profile)
	profile = profile or SCREEN.getActiveProfile()
	-- New TDAT file storage method; TDAT name matches profile name
	if profile and profile.Paths and profile.Paths.Tdat then
		return profile.Paths.Tdat
	end
	-- Otherwise, legacy TDAT file storage Method; TDAT name is the rom game version
	local filename = GameSettings.getTrackerAutoSaveName()
	local folder = FileManager.getPathOverride("Tracker Data") or FileManager.dir
	return folder .. filename
end

---Builds a full filepath to the TDAT file that will be used by the specified `profile`
---@param profile IProfile
---@return string filepath
function QuickloadScreen.generateTdatFilePath(profile)
	return FileManager.getTdatFolderPath() .. profile.Name .. FileManager.Extensions.TRACKED_DATA
end

function QuickloadScreen.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, buttonRow in pairs(SCREEN.Pager.Buttons or {}) do
		for _, button in ipairs(buttonRow.buttonList or {}) do
			if type(button.updateSelf) == "function" then
				button:updateSelf()
			end
		end
	end
end

-- USER INPUT FUNCTIONS
function QuickloadScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	if SCREEN.currentTab == SCREEN.Tabs.Profiles then
		for _, buttonRow in ipairs(SCREEN.Pager.Buttons or {}) do
			Input.checkButtonsClicked(xmouse, ymouse, buttonRow.buttonList)
		end
	end
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
	local headerText = Utils.toUpperUTF8(Resources.QuickloadScreen.Title)
	Drawing.drawText(canvas.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)

	-- Draw top border box
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

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
	-- The condition used to determine the game over for this profile's ruleset
	GameOverCondition = "",
	-- Attempts Count for this profile
	AttemptsCount = 0,
	-- Date the profile was last used for New Run
	LastUsedDate = 0,
	-- Available Paths used by this profile
	Paths = {
		--[[ Several useful paths stored for each profile
		Jar = [Generate Mode] path to the jar file used for randomizations (.JAR)
		Rom = [Generate Mode] path to the source rom file used for randomizations (.GBA)
		Settings = [Generate Mode]  path to the randomize settings file used for randomizations (.RNQS)
		RomsFolder = [Premade Mode] path to the folder containing a batch of randomized roms
		Tdat = path to the associated tracker notes file (.TDAT)
		CurrentRom = path to most recently created/loaded ROM
		]]
	},
}
---Creates and returns a new IProfile object
---@param o? table Optional initial object table
---@return IProfile profile An IProfile object
function QuickloadScreen.IProfile:new(o)
	o = o or {}
	o.GUID = o.GUID or Utils.newGUID()
	o.Name = o.Name or ""
	o.Mode = o.Mode or ""
	o.GameVersion = o.GameVersion or ""
	o.GameOverCondition = o.GameOverCondition or ""
	o.AttemptsCount = o.AttemptsCount or 0
	o.LastUsedDate = o.LastUsedDate or 0
	o.Paths = o.Paths or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

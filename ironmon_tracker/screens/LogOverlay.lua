LogOverlay = {
	Colors = {
		headerText = "Header text",
		headerBorder = "Upper box background",
		headerFill = "Main background",
	},
	margin = 2,
	tabHeight = 12,
	isDisplayed = false,
	isGameOver = false, -- Set to true when game is over, so we known to show game over screen if X is pressed
}

-- Dimensions of the screen space occupied by the currentl visible Tab
LogOverlay.TabBox = {
	x = LogOverlay.margin,
	y = LogOverlay.tabHeight,
	width = Constants.SCREEN.WIDTH - (LogOverlay.margin * 2),
	height = Constants.SCREEN.HEIGHT - LogOverlay.tabHeight - LogOverlay.margin - 1,
}

-- A stack manage the back-button within tabs, each element is { tab, page, }
LogOverlay.TabHistory = {}

LogOverlay.Windower = {
	currentTab = nil,
	currentPage = nil,
	totalPages = nil,
	infoId = -1,
	filterGrid = "#",
	getPageText = function(self)
		if self.totalPages == nil or self.totalPages < 1 then return Resources.AllScreens.Page end
		return string.format("%s %s/%s", Resources.AllScreens.Page, self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages == nil or self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages == nil or self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
	changeTab = function(self, newTab, pageNum, totalPages, tabInfoId, filterGrid)
		if newTab == nil then return end

		local prevTab = {
			tab = self.currentTab,
			page = self.currentPage,
			totalPages = self.totalPages,
			infoId = self.infoId,
			filterGrid = self.filterGrid,
		}

		self.currentTab = newTab
		self.currentPage = pageNum or self.currentPage or 1
		self.totalPages = totalPages or self.totalPages or 1
		self.infoId = tabInfoId or self.infoId or -1
		self.filterGrid = filterGrid or self.filterGrid or "#"

		if newTab == LogTabPokemonDetails then
			LogTabPokemonDetails.buildZoomButtons(self.infoId)
			if prevTab.tab ~= LogTabPokemonDetails then
				table.insert(LogOverlay.TabHistory, prevTab)
			end
		elseif newTab == LogTabTrainerDetails then
			LogTabTrainerDetails.buildZoomButtons(self.infoId)
			if prevTab.tab ~= LogTabPokemonDetails and prevTab.tab ~= LogTabTrainerDetails then
				table.insert(LogOverlay.TabHistory, prevTab)
			end
		end

		LogOverlay.refreshButtons()

		-- After reloading the search results content, update to show the last viewed page and grid
		if LogSearchScreen.tryDisplayOrHide() then
			self.currentPage = pageNum or self.currentPage or 1
			self.totalPages = totalPages or self.totalPages or 1
			self.infoId = tabInfoId or self.infoId or -1
			self.filterGrid = filterGrid or self.filterGrid or "#"
		end
	end,
	goBack = function(self)
		local prevTab = table.remove(LogOverlay.TabHistory)
		if prevTab ~= nil then
			self:changeTab(prevTab.tab, prevTab.page, prevTab.totalPages, prevTab.infoId, prevTab.filterGrid)
		else
			LogTabPokemon.realignGrid()
			self:changeTab(LogTabPokemon)
		end
	end,
}

local pagerOffsetX = 151
LogOverlay.HeaderButtons = {
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return LogOverlay.Windower:getPageText() end,
		textColor = Theme.headerHighlightKey,
		box = { LogOverlay.margin + pagerOffsetX, 0, 50, 10, },
		isVisible = function() return LogOverlay.Windower.totalPages > 1 end, -- Likely won't use, unsure where to place it
		updateSelf = function(self) self.textColor = Theme.headerHighlightKey end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		textColor = Theme.headerHighlightKey,
		shadowcolor = false,
		box = { LogOverlay.margin + pagerOffsetX - 13, 1, 10, 10 },
		isVisible = function() return LogOverlay.Windower.totalPages > 1 end,
		updateSelf = function(self) self.textColor = Theme.headerHighlightKey end,
		onClick = function(self) LogOverlay.Windower:prevPage() end,
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		textColor = Theme.headerHighlightKey,
		shadowcolor = false,
		box = { LogOverlay.margin + pagerOffsetX + 50 + 3, 1, 10, 10 },
		isVisible = function() return LogOverlay.Windower.totalPages > 1 end,
		updateSelf = function(self) self.textColor = Theme.headerHighlightKey end,
		onClick = function(self) LogOverlay.Windower:nextPage() end,
	},
	XIcon = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOSE,
		textColor = Theme.headerHighlightKey,
		box = { LogOverlay.margin + 228, 2, 10, 10 },
		updateSelf = function(self)
			self.textColor = Theme.headerHighlightKey
			if LogOverlay.Windower.currentTab == LogTabPokemonDetails or LogOverlay.Windower.currentTab == LogTabTrainerDetails then
				self.image = Constants.PixelImages.LEFT_ARROW
				self.box[2] = 1
			else
				self.image = Constants.PixelImages.CLOSE
				self.box[2] = 2
			end
		end,
		onClick = function(self)
			if self.image == Constants.PixelImages.CLOSE then
				LogOverlay.TabHistory = {}
				LogOverlay.isDisplayed = false
				LogSearchScreen.clearSearch()
				if LogOverlay.isGameOver then
					Program.changeScreenView(GameOverScreen)
				elseif not Program.isValidMapLocation() then
					-- If the game hasn't started yet
					Program.changeScreenView(StartupScreen)
				else
					Program.changeScreenView(TrackerScreen)
				end
			else -- Constants.PixelImages.PREVIOUS_BUTTON
				LogOverlay.Windower:goBack()
				Program.redraw(true)
			end
		end,
	},
}

-- Navigation filters for each of the window tabs. Each has a label for the button, and a sort function for the grid
LogOverlay.NavFilters = {
	Trainers = {
		All = {
			getText = function() return Resources.LogOverlay.FilterAll end,
			group = TrainerData.TrainerGroups.All,
			index = 1,
			sortFunc = function(a, b)
				if a.group < b.group then
					return true
				elseif a.group == b.group then
					if a.group == TrainerData.TrainerGroups.Rival or a.group == TrainerData.TrainerGroups.Boss then -- special sort for rival/wally #s
						return a:getText() < b:getText()
					elseif a.filename < b.filename then
						return a.filename < b.filename
					end
				end
				return false
			end,
		},
		Rival = {
			getText = function() return Resources.LogOverlay.FilterRival end,
			group = TrainerData.TrainerGroups.Rival,
			index = 2,
			sortFunc = function(a, b) return a:getText() < b:getText() end,
		},
		Gym = {
			getText = function() return Resources.LogOverlay.FilterGym end,
			group = TrainerData.TrainerGroups.Gym,
			index = 3,
			sortFunc = function(a, b) return a.filename:sub(-1) < b.filename:sub(-1) end,
		},
		Elite4 = {
			getText = function() return Resources.LogOverlay.FilterElite4 end,
			group = TrainerData.TrainerGroups.Elite4,
			index = 4,
			sortFunc = function(a, b) return a.filename:sub(-1) < b.filename:sub(-1) end,
		},
		Boss = {
			getText = function() return Resources.LogOverlay.FilterBoss end,
			group = TrainerData.TrainerGroups.Boss,
			index = 5,
			sortFunc = function(a, b) return a:getText() < b:getText() end,
		},
		-- { -- Temp Removing both of these until better data gets sorted out
		-- 	getText = function() return Resources.LogOverlay.FilterOther end,
		-- 	group = TrainerData.TrainerGroups.Other,
		-- 	sortFunc = function(a, b) return a:getText() < b:getText() end,
		-- },
		-- {
		-- 	getText = function() return "(?)" end,
		-- 	group = "?",
		-- },
	},
	TMs = {
		TMNumber = { -- If this changes from index 2, update it's references
			getText = function() return Resources.LogOverlay.FilterTMNumber end,
			group = "TM #",
			index = 10,
			sortFunc = function(a, b) return a.tmNumber < b.tmNumber end,
		},
		GymTMs = { -- If this changes from index 2, update it's references
			getText = function() return Resources.LogOverlay.FilterGymTMs end,
			group = "Gym TMs",
			index = 11,
			sortFunc = function(a, b) return a.gymNumber < b.gymNumber end,
		},
	},
}

function LogOverlay.initialize()
	LogOverlay.isDisplayed = false
	LogOverlay.isGameOver = false

	LogOverlay.TabHistory = {}
	LogOverlay.Windower.currentTab = nil

	LogOverlay.addHeaderTabButtons()

	for _, button in pairs(LogOverlay.HeaderButtons) do
		if button.textColor == nil then
			button.textColor = LogOverlay.Colors.headerText
		end
		if button.boxColors == nil then
			button.boxColors = { LogOverlay.Colors.headerBorder, LogOverlay.Colors.headerFill }
		end
	end
end

function LogOverlay.refreshButtons()
	for _, button in pairs(LogOverlay.HeaderButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogOverlay.addHeaderTabButtons()
	local orderedTabs = {
		LogTabPokemon,
		LogTabTrainers,
		LogTabRoutes,
		LogTabTMs,
		LogTabMisc,
	}
	local offsetX = LogOverlay.margin + 1
	local spacer = 2

	for i, tabScreen in ipairs(orderedTabs) do
		local width = Utils.calcWordPixelLength(Resources.LogOverlay[tabScreen.TitleResourceKey or ""]) + 2 + spacer
		local tabButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return Resources.LogOverlay[tabScreen.TitleResourceKey or ""] end,
			index = i,
			isSelected = false,
			box = { offsetX, 0, width, 11, },
			updateSelf = function(self)
				self.isSelected = (LogOverlay.Windower.currentTab == tabScreen)
				self.textColor = Utils.inlineIf(self.isSelected, Theme.headerHighlightKey, LogOverlay.Colors.headerText)
			end,
			draw = function(self)
				if self.isSelected then
					Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
				end
			end,
			onClick = function(self)
				if self.isSelected then return end -- Don't change if already on this tab
				LogOverlay.TabHistory = {}
				LogOverlay.Windower:changeTab(tabScreen)
				LogSearchScreen.resetSearchSortFilter()
				LogOverlay.refreshActiveTabGrid()
				Program.redraw(true)
			end,
		}
		if tabScreen ~= LogTabRoutes or GameSettings.game == 3 then -- LogTabRoutes FRLG only atm
			table.insert(LogOverlay.HeaderButtons, tabButton)
			offsetX = offsetX + width + spacer
		end
	end
end

-- Build out all paged buttons for all Tab screens using the parsed data
function LogOverlay.buildAllTabs()
	-- Pokemon
	LogTabPokemon.buildPagedButtons()
	-- Trainers
	local gymTMs = LogTabTrainers.buildPagedButtons()
	-- Routes
	LogTabRoutes.buildPagedButtons()
	-- TMs
	LogTabTMs.buildPagedButtons(gymTMs)
	LogTabTMs.buildGymTMButtons()
end

function LogOverlay.refreshActiveTabGrid()
	local currentTab = LogOverlay.Windower.currentTab or {}
	if type(currentTab.realignGrid) == "function" then
		if LogSearchScreen.searchText ~= "" and LogSearchScreen.AllowedTabViews[currentTab] then
			currentTab.realignGrid(LogOverlay.Windower.filterGrid, LogSearchScreen.currentSortOrder.sortFunc)
		else
			currentTab.realignGrid()
		end
	elseif type(currentTab.refreshButtons) == "function" then
		currentTab.refreshButtons()
	end
end

-- Rebuilds the buttons for the currently displayed screen. Useful when the Tracker's display language changes
function LogOverlay.rebuildScreen()
	if not LogOverlay.isDisplayed then return end

	-- Rebuild majority of the data, and clear out navigation history
	LogOverlay.TabHistory = {}
	LogOverlay.buildAllTabs()

	local currentTab = LogOverlay.Windower.currentTab or {}
	if type(currentTab.rebuild) == "function" then
		currentTab.rebuild()
	end

	LogOverlay.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogOverlay.checkInput(xmouse, ymouse)
	if not LogOverlay.isDisplayed then return end

	Input.checkButtonsClicked(xmouse, ymouse, LogOverlay.HeaderButtons)

	local currentTab = LogOverlay.Windower.currentTab or {}
	if type(currentTab.checkInput) == "function" then
		currentTab.checkInput(xmouse, ymouse)
	end
end

-- DRAWING FUNCTIONS
function LogOverlay.drawScreen()
	if not LogOverlay.isDisplayed then return end

	Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)

	local currentTab = LogOverlay.Windower.currentTab or {}

	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	local borderColor = Theme.COLORS["Upper box border"]
	if currentTab.Colors and currentTab.Colors.border then
		borderColor = Theme.COLORS[currentTab.Colors.border]
	end

	-- Draw tab dividers; color depends on currently viewed tab
	gui.drawLine(LogOverlay.margin, 1, LogOverlay.margin, LogOverlay.TabBox.y - 1, borderColor)
	for _, headerTab in ipairs(Utils.getSortedList(LogOverlay.HeaderButtons)) do
		local rightEdge = headerTab.box[1] + headerTab.box[3] + 2
		gui.drawLine(rightEdge, 1, rightEdge, LogOverlay.TabBox.y - 1, borderColor)
	end

	-- Draw all buttons
	for _, button in pairs(LogOverlay.HeaderButtons) do
		Drawing.drawButton(button, headerShadow)
	end

	-- Draw current tab
	if type(currentTab.drawTab) == "function" then
		currentTab.drawTab()
	end
end

function LogOverlay.viewLogFile(postfix)
	local logpath = LogOverlay.getLogFileAutodetected(postfix)

	-- Check if there exists a parsed log with the same postfix as the one being requested
	local hasParsedThisLog = RandomizerLog.Data.Settings ~= nil and string.find(RandomizerLog.loadedLogPath or "", postfix, 1, true) ~= nil

	-- Only prompt for a new file if no autodetect and nothing has been parsed yet
	if logpath == nil and not hasParsedThisLog then
		logpath = LogOverlay.getLogFileFromPrompt()
	end

	LogOverlay.parseAndDisplay(logpath)
end

--- Attempts to determine the log file that matches the currently loaded rom. If not match or can't find, returns nil
--- @param postFix string The file's postFix, most likely FileManager.PostFixes.AUTORANDOMIZED or FileManager.PostFixes.PREVIOUSATTEMPT
--- @return string|nil
function LogOverlay.getLogFileAutodetected(postFix)
	postFix = postFix or FileManager.PostFixes.AUTORANDOMIZED

	local romname, rompath
	if Options["Use premade ROMs"] and Options.FILES["ROMs Folder"] ~= nil then
		-- First make sure the ROMs Folder ends with a slash
		if Options.FILES["ROMs Folder"]:sub(-1) ~= FileManager.slash then
			Options.FILES["ROMs Folder"] = Options.FILES["ROMs Folder"] .. FileManager.slash
		end

		romname = GameSettings.getRomName() or ""
		if postFix == FileManager.PostFixes.PREVIOUSATTEMPT then
			local currentRomPrefix = string.match(romname, '[^0-9]+') or ""
			local currentRomNumber = string.match(romname, '[0-9]+') or "0"
			-- Decrement to the previous ROM and determine its full file path
			local prevRomName = string.format(currentRomPrefix .. "%0" .. string.len(currentRomNumber) .. "d", tonumber(currentRomNumber) - 1)
			romname = prevRomName
		end

		rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		if not FileManager.fileExists(rompath) then
			romname = romname:gsub(" ", "_")
			rompath = Options.FILES["ROMs Folder"] .. romname .. FileManager.Extensions.GBA_ROM
		end
	elseif Options["Generate ROM each time"] then
		-- Filename of the AutoRandomized ROM is based on the settings file (for cases of playing Kaizo + Survival + Others)
		local quickloadFiles = Main.GetQuickloadFiles()
		local settingsFileName = FileManager.extractFileNameFromPath(quickloadFiles.settingsList[1] or "")
		romname = string.format("%s %s%s", settingsFileName, postFix, FileManager.Extensions.GBA_ROM)
		rompath = FileManager.prependDir(romname)
	end

	-- Check if the name of the rom being played on the emulator matches the name of the autodetected rom
	if Main.IsOnBizhawk() then
		local plainFormatter = function(filename)
			-- strip out any auto appended postfixes
			filename = filename:gsub(FileManager.PostFixes.AUTORANDOMIZED, "")
			filename = filename:gsub(FileManager.PostFixes.PREVIOUSATTEMPT, "")
			filename = filename:gsub("%.gba", "")
			filename = filename:gsub(" ", "_")
			filename = filename:gsub("%d", "")
			return filename:lower()
		end
		local loadedRomName = GameSettings.getRomName() or "N/A"
		loadedRomName = plainFormatter(loadedRomName .. FileManager.Extensions.GBA_ROM)
		local autodetectedName = plainFormatter(romname or "")
		if loadedRomName ~= autodetectedName then
			return nil
		end
	end

	-- Return the full file path of the log file, or nil if it can't be found
	return FileManager.getPathIfExists((rompath or "") .. FileManager.Extensions.RANDOMIZER_LOGFILE)
end

--- Prompts user to select a log file to parse
--- @return string|nil
function LogOverlay.getLogFileFromPrompt()
	local suggestedFileName = (GameSettings.getRomName() or "") .. FileManager.Extensions.RANDOMIZER_LOGFILE
	local filterOptions = "Randomizer Log (*.log)|*.log|All files (*.*)|*.*"

	local workingDir = FileManager.dir
	if workingDir ~= "" then
		workingDir = workingDir:sub(1, -2) -- remove trailing slash
	end

	Utils.tempDisableBizhawkSound()
	local filepath = forms.openfile(suggestedFileName, workingDir, filterOptions)
	if filepath == "" then
		filepath = nil
	end
	Utils.tempEnableBizhawkSound()

	return filepath
end

function LogOverlay.parseAndDisplay(logpath)
	-- Check for what log we're trying to display, and if it's already been parsed
	if logpath ~= nil and RandomizerLog.loadedLogPath ~= logpath then
		RandomizerLog.Data = {}
		RandomizerLog.loadedLogPath = logpath
	end

	-- If data has already been loaded and parsed, use that first, otherwise try parsing the provided log file
	if RandomizerLog.Data.Settings ~= nil then
		LogOverlay.isDisplayed = true
	else
		LogOverlay.isDisplayed = RandomizerLog.parseLog(logpath)
	end

	if LogOverlay.isDisplayed then
		LogOverlay.TabHistory = {}
		LogOverlay.buildAllTabs()
		LogOverlay.Windower:changeTab(LogTabPokemon)
		LogSearchScreen.resetSearchSortFilter()
		LogOverlay.refreshActiveTabGrid()
		-- If the player has a Pokemon, show it on the side-screen
		local leadPokemon = Tracker.getPokemon(1, true) or Tracker.getDefaultPokemon()
		if PokemonData.isValid(leadPokemon.pokemonID) then
			LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, leadPokemon.pokemonID)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, leadPokemon.pokemonID)
		else
			Program.redraw(true)
		end
	end

	return LogOverlay.isDisplayed
end

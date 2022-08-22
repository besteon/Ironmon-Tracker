QuickloadScreen = {
	headerText = "Quickload Setup",
	textColor = "Default text",
	borderColor = "Upper box border",
	boxFillColor = "Upper box background",
}

-- QuickloadScreen.OptionKeys = {
-- 	"Show tips on startup",
-- 	"Right justified numbers",
-- 	"Track PC Heals",
-- 	"PC heals count downward",
-- 	"Animated Pokemon popout",
-- }

QuickloadScreen.Buttons = {
	RomsFolder = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "ROMs Folder",
		folderText = "Set for Quick- load",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, Constants.SCREEN.MARGIN + 60, 55, 11 },
		onClick = function() QuickloadScreen.openRomPickerWindow() end
	},
	Back = {
		type = Constants.ButtonTypes.FULL_BORDER,
		text = "Back",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 135, 24, 11 },
		onClick = function(self)
			-- Save all of the Options to the Settings.ini file, and navigate back to the Tracker Setup screen
			Main.SaveSettings()
			Program.changeScreenView(Program.Screens.SETUP)
		end
	},
}

function QuickloadScreen.initialize()
	for _, button in pairs(QuickloadScreen.Buttons) do
		button.textColor = QuickloadScreen.textColor
		button.boxColors = { QuickloadScreen.borderColor, QuickloadScreen.boxFillColor }
	end

	if Options.ROMS_FOLDER ~= nil and Options.ROMS_FOLDER ~= "" then
		QuickloadScreen.Buttons.RomsFolder.folderText = Utils.truncateRomsFolder(Options.ROMS_FOLDER)
	end
end

function QuickloadScreen.openRomPickerWindow()
	-- Use the standard file open dialog to get the roms folder
	local filterOptions = "ROM File (*.GBA)|*.GBA|All files (*.*)|*.*"
	local file = forms.openfile("SELECT A ROM", Options.ROMS_FOLDER, filterOptions)
	if file ~= "" then
		-- Since the user had to pick a file, strip out the file name to just get the folder.
		Options.ROMS_FOLDER = string.sub(file, 0, string.match(file, "^.*()\\") - 1)
		if Options.ROMS_FOLDER == nil then
			Options.ROMS_FOLDER = ""
		end
		QuickloadScreen.Buttons.RomsFolder.folderText = Utils.truncateRomsFolder(Options.ROMS_FOLDER)
		Options.settingsUpdated = true

		-- Save these changes to the file to avoid case where user resets before clicking the Close button
		Main.SaveSettings()

		Program.redraw(true)
	end
end

-- DRAWING FUNCTIONS
function QuickloadScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()
	gui.defaultTextBackground(Theme.COLORS[QuickloadScreen.boxFillColor])

	local shadowcolor = Utils.calcShadowColor(Theme.COLORS[QuickloadScreen.boxFillColor])
	local topboxX = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN
	local topboxY = Constants.SCREEN.MARGIN
	local topboxWidth = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2)
	local topboxHeight = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2)

	-- Draw top border box
	gui.drawRectangle(topboxX, topboxY, topboxWidth, topboxHeight, Theme.COLORS[QuickloadScreen.borderColor], Theme.COLORS[QuickloadScreen.boxFillColor])

	-- Draw header text
	Drawing.drawText(topboxX + 33, topboxY + 2, QuickloadScreen.headerText:upper(), Theme.COLORS["Intermediate text"], shadowcolor)

	-- Draw all buttons
	for _, button in pairs(QuickloadScreen.Buttons) do
		Drawing.drawButton(button, shadowcolor)
	end

	local romsButton = QuickloadScreen.Buttons.RomsFolder
	Drawing.drawText(romsButton.box[1] + romsButton.box[3] + 2, romsButton.box[2], romsButton.folderText, Theme.COLORS[romsButton.textColor], shadowcolor)
end
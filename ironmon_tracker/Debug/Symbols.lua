Symbols = {
	symbolSources = {
		[1] = {
			gameName = "ruby 1.0",
			gameType = 0,
			fileName = "pokeruby.sym.txt"
		},
		[2] = {
			gameName = "ruby 1.1",
			gameType = 0,
			fileName = "pokeruby_rev1.sym.txt"
		},
		[3] = {
			gameName = "ruby 1.2",
			gameType = 0,
			fileName = "pokeruby_rev2.sym.txt"
		},
		[4] = {
			gameName = "sapphire 1.0",
			gameType = 1,
			fileName = "pokesapphire.sym.txt"
		},
		[5] = {
			gameName = "sapphire 1.1",
			gameType = 1,
			fileName = "pokesapphire_rev1.sym.txt"
		},
		[6] = {
			gameName = "sapphire 1.2",
			gameType = 1,
			fileName = "pokesapphire_rev2.sym.txt"
		},
		[7] = {
			gameName = "emerald",
			gameType = 2,
			fileName = "pokeemerald.sym.txt"
		},
		[8] = {
			gameName = "fire red 1.0",
			gameType = 3,
			fileName = "pokefirered.sym.txt"
		},
		[9] = {
			gameName = "fire red 1.1",
			gameType = 3,
			fileName = "pokefirered_rev1.sym.txt"
		},
		[10] = {
			gameName = "leaf green 1.0",
			gameType = 4,
			fileName = "pokeleafgreen.sym.txt"
		},
		[11] = {
			gameName = "leaf green 1.1",
			gameType = 4,
			fileName = "pokeleafgreen_rev1.sym.txt"
		},
	},
	symbolSearch = {
		{"sSaveDialogDelay",0x0},
	},
	FRToOtherGameNameMap = {
		["sBattleBuffersTransferData"] = {
			[0] = "gBattleBuffersTransferData",
			[1] = "gBattleBuffersTransferData",
		},
		["BattleIntroDrawPartySummaryScreens"] = {
			[0] = "BtlController_EmitDrawPartyStatusSummary",
			[1] = "BtlController_EmitDrawPartyStatusSummary",
		},
		["BattleIntroOpponentSendsOutMonAnimation"] = {
			[0] = "SendOutMonAnimation",
			[1] = "SendOutMonAnimation",
			[2] = "BattleIntroOpponent2SendsOutMonAnimation",
		},
		["sSaveDialogDelay"] = {
			[0]="saveDialogTimer",
			[1]="saveDialogTimer",
			[2]="sSaveDialogTimer",
		},
		["SaveDialogCB_ReturnSuccess"] = {
			[2]="SaveSuccessCallback",
		}
	},
	outputFile = "addresses.txt",
	gameType = 0
}


function Symbols.populateSymbolsMap()
	for i = 1 , #Symbols.symbolSources, 1 do
		local gameValues = Symbols.symbolSources[i]
		gameValues.symbols = {}
		for j = 1, #Symbols.symbolSearch, 1 do
			print (FileManager.prependDir(gameValues.fileName))
			local symbolFile = io.open(FileManager.prependDir(gameValues.fileName),"r") or ""
			local found = false
			local variableName = Symbols.symbolSearch[j][1]
			if Symbols.FRToOtherGameNameMap[variableName] ~= nil and Symbols.FRToOtherGameNameMap[variableName][gameValues.gameType] ~= nil then
				variableName = Symbols.FRToOtherGameNameMap[variableName][gameValues.gameType]
			end
			for line in symbolFile:lines() do
				if line:find(" " .. variableName .. "$") ~= nil then
					gameValues.symbols[j] = "0x" .. string.format("%x",("0x" .. line:sub(1,8)) + Symbols.symbolSearch[j][2])
					found = true
					break;
				end
			end
			if found == false then
				gameValues.symbols[j] = "nil"
			end
		end
		print (gameValues.fileName .. " processed.")
	end
end

function Symbols.writeSymbolsToFile()
	local writeFile = io.open(FileManager.prependDir(Symbols.outputFile),"w+")
	if writeFile ~= nil then
		for i = 1 , #Symbols.symbolSearch, 1 do
			writeFile:write(Symbols.symbolSearch[i][1] .. " = {\n\t{")
			for j = 1 , #Symbols.symbolSources, 1 do
				local gameValues = Symbols.symbolSources[j]
				if Symbols.gameType < gameValues.gameType then
					if Symbols.gameType == 3 and j > 1 then
						--Account for foreign FR1.1 games, offset FR1.1
						local prevSym = Symbols.symbolSources[j-1].symbols[i]
						local offsetSP, offsetIT, offsetFR, offsetGE = "nil","nil","nil","nil"
						if prevSym ~= "nil" then
							offsetSP = "0x" .. string.format("%x",(tonumber(prevSym,16)) - 0x53e)
							offsetIT = "0x" .. string.format("%x",(tonumber(prevSym,16)) - 0x2c06)
							offsetFR = "0x" .. string.format("%x",(tonumber(prevSym,16)) - 0x189e)
							offsetGE = "0x" .. string.format("%x",(tonumber(prevSym,16)) + 0x4226)
						end
						writeFile:write(" " .. offsetSP .. ", " .. offsetIT .. ", " .. offsetFR .. ", " .. offsetGE .. ",")
					end
					writeFile:write("},\n\t{")
					Symbols.gameType = gameValues.gameType
				end
				writeFile:write(" " .. gameValues.symbols[i] .. ",")
			end
			writeFile:write("}\n},\n")
			Symbols.gameType = 0
		end
		writeFile:close()
	end
end

function Symbols.Main()
	print ("Starting search.")
	Symbols.populateSymbolsMap()
	Symbols.writeSymbolsToFile()
	print ("Search Complete.")
end

Symbols.Main()
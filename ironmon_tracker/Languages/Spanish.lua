ScreenResources{
	GameOverScreenQuotes = {
		"¿Qué pasa, entrenador?", -- Center text
		"¿Qué hará ahora el entrenador?", -- Center text
		"¡Oh! ¡Otro fracaso!", -- Center text
		"Bum!",
		"¡Devastador!", -- Center text
		"¡Eliminado! ¡No tuvo ninguna oportunidad!", -- Center text
		"¿Podrá la estrategia dominar la desventaja de nivel?", -- Center text
		"¡No está en condiciones de luchar!", -- Center text
		"Este combate es entre Pokémon claramente desiguales",
		"El Pokémon vuelve a su Poké Ball",
		"¡Abatido! ¡Fue pan comido!", -- Center text
		"¡Esa ha debido doler!", -- Center text
		"¡Y se acabó el combate!", -- Center text
		"¡Qué giro más inesperado!", -- Center text
		"¡Derrotado al instante!", -- Center text
		"¡Guau! ¡Eso fue arrollador!", -- Center text
		"¡Por fin ha sido derrotado!", -- Center text
		"¡Golpe durísimo!",
		"¡Eso fue brutal!", -- Center text
		"¡Justo en el punto débil!", -- Center text
		"¡Eh! ¿¡Qué está haciendo!? ¡Se desploma!", -- Center text
		},
	AllScreens = {
		Pokemon = "Pokémon",
		Back = "Atrás",
		Yes = "Sí",
		No = "No",
		OK = "OK",
		Cancel = "Cancelar",
		Preview = "Vista previa",
		Save = "Guardar",
		Close = "Cerrar",
		Clear = "Borrar",
		Import = "Importar",
		Export = "Exportar",
		Lookup = "Buscar",
		Page = "Página",
	},
	PokemonEvolutionDetails = {
		-- abbreviation: appears on the main Tracker Screen
		-- short: used for the log viewer
		-- detailed: used for Pokémon Info Look up
		LEVEL = {
			short = "Nv.",
			detailed = "Nivel",
		},
		FRIEND = {
			abbreviation = "AMISTAD",
			short = "Amistad",
			detailed = "Amistad",
		},
		FRIEND_READY = {
			abbreviation = "LISTO",
		},
		THUNDER = {
			abbreviation = "TRUENO",
			short = "Trueno",
			detailed = "Piedra trueno",
		},
		FIRE = {
			abbreviation = "FUEGO",
			short = "Fuego",
			detailed = "Piedra fuego",
		},
		WATER = {
			abbreviation = "AGUA",
			short = "Agua",
			detailed = "Piedra agua",
		},
		MOON = {
			abbreviation = "LUNAR",
			short = "Lunar",
			detailed = "Piedra Lunar",
		},
		LEAF = {
			abbreviation = "HOJA",
			short = "Hoja",
			detailed = "Piedra Hoja",
		},
		SUN = {
			abbreviation = "SOLAR",
			short = "Solar",
			detailed = "Piedra Solar",
		},
		LEAF_SUN = {
			abbreviation = "HJ/SL",
		},
		WATER30 = {
			abbreviation = "30/AGU",
		},
		WATER37 = {
			abbreviation = "37/AGU",
		},
		WATER37_REV = {
			abbreviation = "AGU/37",
		},
		EEVEE_STONES = {
			abbreviation = "PIEDRA",
			detailed = "5 Piedras dif.",
		},
	},
	TrackerScreen = {
		HPAbbreviation = "PS",
		LevelAbbreviation = "Nv",
		RandomBallChosen = "Poké ball elegida al azar",
		RandomBallUserChosen = "Poké Ball elegida",
		RandomBallUserPicks = "Elige",
		RandomBallLeft = "Izquierda",
		RandomBallMiddle = "Medio",
		RandomBallRight = "Derecha",
		RandomBallRandom = "Aleatoria",
		HealsInBag = "Curaciones",
		UnidentifiedGhost = "Fantasma",
		BattleNewEncounter = "Pokémon nuevo",
		BattleLastSeen = "Última vez",
		BattleSeenInTheWild = "Visto (Salvaje)",
		BattleSeenOnTrainers = "Visto (Entrenador)",
		BattleTeam = "Equipo",
		StatHP = "PS",
		StatATK = "ATQ",
		StatDEF = "DEF",
		StatSPA = "ASP",
		StatSPD = "DSP",
		StatSPE = "VEL",
		StatBST = "BST",
		StatAccuracy = "Pre",
		StatEvasion = "Eva",
		HeaderMoves = "Mov.",
		HeaderPP = "PP",
		HeaderPow = "Pot",
		HeaderAcc = "Pre",
		ToCatch = "de captura",
		LeaveANote = "Dejar nota",
		DamageTaken = "daño",
		DamageTakenInTeams = "Total recibido",
		PedometerSteps = "Pasos",
		PedometerGoal = "Meta",
		PedometerTotal = "Totales",
		PedometerReset = "Reset",
		EncounterWalking = "Caminando",
		EncounterSurfing = "Surfeando",
		EncounterUnderwater = "Bajo el agua",
		EncounterStatic = "Estático",
		EncounterRockSmash = "Golpe Roca",
		EncounterSuperRod = "Super Caña",
		EncounterGoodRod = "Caña Buena",
		EncounterOldRod = "Caña Vieja",
		EncounterSeenPokemon = "vistos", -- or: Pok. vistos
		TrainersDefeated = "Entrenadores derrotados",
		TrainersNoneInArea = "Ningún entrenador en el área.",
		GachaMonCaptured = "GachaMon capturado!",
		PromptNoteDesc = "Deja una nota breve para",
		PromptNoteAbilityDesc = "Asigna una o ambas habilidades para",
		PromptNoteClearAbilities = "Borrar habilidades",
		PromptStepsTitle = "Elige una meta de pasos",
		PromptStepsDesc1 = "El podómetro cambiará de color cuando llegues a la meta.",
		PromptStepsDesc2 = "Ajustar a 0 para apagar",
		PromptStepsEnterGoal = "¿Cuántos pasos faltan para llegar a tu meta? ",
	},
	StartupScreen = {
		Title = "Ironmon Tracker",
		Version = "Versión",
		Game = "Juego",
		Attempts = "Intentos",
		TrackedDataMsgLabel = "Notas del Tracker",
		TrackedDataMsgLoadSuccess = "Última sesión de juego cargada.",
		TrackedDataMsgNewGame = "Nuevo juego empezado.",
		TrackedDataMsgAutoDisabled = "Guardado / carga autom. desactivada.",
		TrackedDataMsgRomMismatch = "Archivo ROM incorrecto",
		TrackedDataMsgError = "Error al cargar archivo",
		HeaderFavorites = "Pokémon favoritos",
		HeaderControls = "Controles de GBA",
		ControlsSwapView = "Cambiar Pok. visualizado",
		ControlsQuickload = "Cargar nueva run",
		ControlsEraseGameSave = "Borrar datos de juego guardados",
		PromptChooseAPokemonTitle = "Elige un Pokémon",
		PromptChooseAPokemonDesc = "Elige un Pokémon para mostrar durante el inicio",
		PromptChooseAPokemonByAttempt = "Basado en el intento #",
		PromptChooseAPokemonByRandom = "Siempre aleatorio",
		PromptChooseAPokemonNone = "Ninguno",
	},
	NavigationMenu = {
		Title = "Ajustes del Tracker",
		ButtonSetup = "Ajustes",
		ButtonGameplay = "Jugabilidad",
		ButtonTheme = "Temas",
		ButtonStreaming = "Streaming",
		ButtonExtras = "Extras",
		ButtonQuickload = "Nueva Run",
		ButtonNotebook = "Notas",
		ButtonLanguage = "Idiomas",
		ButtonUpdate = "Actualizar",
		ButtonExtensions = "Extensiones", -- Size
		ButtonCredits = "Créditos", -- Size
		ButtonHelp = "Ayuda", -- Size
		CreditsCreatedBy = "Creado por",
		CreditsContributors = "Colaboradores",
		MessageCheckConsole = "Consulta la consola Lua para ver un enlace al Wiki de Ayuda del Tracker.", -- Unable to see it, but translated
	},
	SetupScreen = {
		Title = "Ajustes básicos del Tracker",
		TabGeneral = "General",
		TabCarousel = "Varios", -- Varios instead Carrusel for better looking
		TabControls = "Controles",
		PokemonIconSetLabel = "Miniaturas Pokémon",
		PokemonIconSetAuthor = "Añadido por",
		OptionShowRandomBallPicker = "Mostrar Poké ball aleatoria",
		OptionShowTeamView = "Mostrar equipo Pokémon",
		OptionRightJustifiedNumbers = "Stats alineadas a la derecha",
		OptionTrackPCHeals = "Mostrar curas del CP",
		OptionPCHealsCountDown = "Orden desc. de curas del CP ",
		OptionAllowSpritesToWalk = "Caminando",
		ButtonManageData = "Gestionar datos", -- Size
		OptionAllowCarouselRotation = "Permitir rotación de varios", -- Varios instead Carrusel for better looking
		LabelInfoToShow = "Información para mostrar",
		LabelSpeedSetting = "Velocidad",
		CarouselBadges = "Medallas de gimnasio",
		CarouselNotes = "Notas sobre Pokémon",
		CarouselRouteInfo = "Encuentros salvajes en el área",
		CarouselTrainers = "Entren. derrotados en el área", -- Size
		CarouselLastAttack = "Daño del último ataque",
		CarouselBattleDetails = "Detalles adicionales de batalla",
		CarouselPedometer = "Pasos del podómetro",
		CarouselGachaMon = "GachaMon capturados",
		OptionOverrideButtonModeLR = "Anular modo de botones de LR", -- Size
		ButtonEditAll = "Editar todo", -- Size
		LabelCurrentControllerBinding = "Combinación actual",
		LabelNewControllerBinding = "Nueva combinación",
		LabelWaiting = "Esperando",
		LabelPressControllerButtons = "Pulsa una combinacion a elegir.",
		LabelButtonsAllowed = "Botones permitidos",
		PromptEditControllerTitle = "Botones del mando",
		PromptEditControllerDesc = "Edita los botones de GBA para el Tracker. Botones permitidos: A, B, L, R, Start, Select",
		PromptEditControllerLoadNext = "Cargar nueva seed",
		PromptEditControllerToggleView = "Alternar vista",
		PromptEditControllerInfoShortcut = "Entrenadores / Pivotantes", -- Size
		PromptEditControllerCycleStats = "Moverte entre las stats",
		PromptEditControllerMarkStat = "Marcar stat",
		PromptEditControllerNextPage = "Siguiente página",
		PromptEditControllerPreviousPage = "Página anterior",
		PromptEditControllerResetDefault = "Reset por defecto",
	},
	ExtrasScreen = {
		Title = "Extras del Tracker",
		TabTools = "Herramientas", -- Size
		TabOptions = "Opciones",
		ButtonViewLogs = "Logs",
		ButtonCoverageCalculator = "Calculadora de cobertura",
		ButtonGachaMonCollection = "Colección de GachaMon",
		ButtonTimeMachine = "Máquina del tiempo",
		ButtonCrashRecovery = "Recuperación de errores",
		LabelTimer = "Opciones de tiempo jugado",
		ButtonEditTime = "Editar", -- Size
		ButtonRelocateTime = "Recolocar", -- or: Reubicar
		OptionDisplayRepelUsage = "Mostrar uso del repelente",
		OptionDisplayPedometer = "Mostrar pasos del podómetro",
		OptionDisplayPlayTime = "Mostrar tiempo jugado",
		OptionDisplayGender = "Mostrar género del Pokémon",
		OptionAnimatedPokemonPopout = "Popout de Pokémon animado",
		ButtonEstimatePokemonIVs = "Mostrar potencial IV aproximado",
		EstimateResultOutstanding = "¡¡¡Excepcional!!!",
		EstimateResultQuiteImpressive = "¡¡Muy impresionante!!",
		EstimateResultAboveAverage = " ¡Por encima de la media!",
		EstimateResultDecent = "Decente",
		EstimateResultUnavailable = "no disponible.",
		TimerPauseTip = "(Clica en el cronómetro para pausar)",
	},
	GameOptionsScreen = {
		Title = "Opciones de jugabilidad",
		TabBattle = "Batalla",
		TabGameOver = "Fin del juego",
		TabOther = "Otros",
		ButtonGameStats = "Estadísticas",
		LabelGameOverCondition = "El juego termina cuando",
		OptionAutoSwapEnemy = "Mostrar Pokémon enem. auto.",
		OptionCanClickTrainers = "Entrenadores de clic en pantalla",
		OptionShowStarterBallInfo = "Mostrar info. Poké Ball inicial",
		OptionHideStatsUntilSummary = "Ocultar resumen hasta ver datos",
		OptionShowNicknames = "Mostrar motes",
		OptionShowExpBar = "Mostrar barra de experiencia",
		OptionShowHealsAsValue = "Mostrar n.º curaciones entero",
		OptionShowPhysicalSpecial = "Mostrar iconos físico / especial",
		OptionShowMoveEffectiveness = "Mostrar mov. superefectivo",
		OptionCalculateVariableDamage = "Calcular daño variable",
		OptionDetermineFriendship = "Verificar estado de amistad",
		OptionShowVanillaGameData = "Mostrar datos del juego original",
		OptionShowBallCatchRate = "Porcentajes de captura",
		OptionCountEnemyPP = "Mostrar PPs del enemigo",
		OptionShowLastDamage = "Mostrar cálculo del último daño",
		OptionRevealRandomizedInfo = "Mostrar datos mov./tipos aleat.",
		OptionLeadPokemonFaints = "Pokémon lider debilitado",
		OptionHighestLevelFaints = "Pokémon de + nivel debilitado",
		OptionEntirePartyFaints = "Todo el equipo debilitado",
		OptionOpenBookPlayMode = "Modo Open Book", -- Text box description? (space left to mini-explain)
		LabelExtraTimeWarning = "Puede ralentizar la carga",
	},
	QuickloadScreen = {
		Title = "Configurar nueva run",
		TabGeneral = "General",
		TabProfiles = "Perfiles",
		TabOptions = "Opciones",
		NewRunsDescGenerate = "El Tracker creará un archivo ROM de juego nuevo y aleatorio al pulsar la combinación de botones",
		NewRunsDescPremade = "El Tracker cargará el siguiente archivo ROM de juego numérico al pulsar la combinación de botones",
		LabelActiveProfile = "Perfil activo",
		LabelNoActiveProfile = "Sin perfil activo",
		LabelClickToAdd = "Pulsa para añadir uno",
		LabelProfileAttempts = "Intentos",
		LabelProfileLastPlayed = "Última vez",
		ButtonLoadLastGame = "Cargar última partida",
		ButtonGoNextSeed = "Siguiente seed",
		ButtonCreateNewGame = "Crear nueva partida",
		ButtonAddNew = "Añadir",
		ButtonSelectProfile = "Usar",
		ButtonEditProfile = "Editar", -- Size
		ButtonDeleteProfile = "Eliminar",
		OptionRefocusEmulator = "Al cargar: volver a Bizhawk",
	},
	ThemeScreen = {
		Title = "Biblioteca de temas",
		HeaderActiveThemeOptions = "Opciones del tema activo",
		LabelDefaultTheme = "Tema predeterminado",
		LabelActiveCustomTheme = "Tema activo (Personalizado)",
		ButtonApplyTheme = "Aplicar tema",
		ButtonSaveAsNew = "Guardar como",
		ButtonRemove = "Eliminar",
		ButtonRemoveConfirm = "¿Estás seguro?", -- Size
		ButtonImport = "Importar tema",
		ButtonExport = "Exportar tema",
		PromptEnterThemeCode = "Introduce un 'code string' para importar (Ctrl+V para pegar)",
		PromptImportError = "Error al importar: Código erróneo.",
		PromptThemeFor = "Tema para",
		PromptCopyThemeCode = "Copia el código de debajo (Ctrl+C)",
		PromptSelectPreset = "Selecciona un tema para previsualizarlo",
		PromptSaveAsTitle = "Guardar tema",
		PromptEnterNameForTheme = "Elige nombre para el tema",
		PromptCantUseReserved = "No puedes usar este nombre.",
		PromptCantUseConsecutiveChars = "El nombre no puede tener 6 caracteres hexa. consecutivos (0-9A-F)",
		PromptNameAlreadyInUse = "Ya existe un tema con ese nombre. ¿Sobrescribir?",
		OptionColorStatNumber = "Color de las stats por naturaleza",
		OptionColorBar = "Barra color por tipos de mov.",
		OptionTextShadows = "Sombras del texto",
		ButtonEditColors = "Editar los colores",
		TitleEditingActiveTheme = "Editando tema activo",
		ColorDefaultText = "Texto de caja superior",
		ColorLowerBoxText = "Texto de caja inferior",
		ColorPositiveText = "Texto positivo",
		ColorNegativeText = "Texto negativo",
		ColorIntermediateText = "Texto intermedio",
		ColorHeaderText = "Texto del encabezado",
		ColorUpperBoxBorder = "Borde de caja superior",
		ColorUpperBoxBackground = "Fondo de caja superior",
		ColorLowerBoxBorder = "Borde de caja inferior",
		ColorLowerBoxBackground = "Fondo de caja inferior",
		ColorMainBackground = "Fondo principal",
		PromptColorPickerTitle = "Selector de color",
		PromptColorPickerHexColor = "Color hex.",
	},
	LanguageScreen = {
		Title = "Opciones de idioma",
		TabDisplay = "Display", -- NEEDS TRANSLATION
		TabOptions = "Options", -- NEEDS TRANSLATION
		DisplayLanguage = "Idioma mostrado",
		AutodetectSetting = "Detectar idioma autom.",
		OptionGameWordsInLanguage = "Show game words in language", -- NEEDS TRANSLATION
		OptionMenusTextInLanguage = "Show menus/text in language", -- NEEDS TRANSLATION
		ButtonHelpContribute = "Colaborar",
	},
	StatsScreen = {
		Title = "Estadísticas de juego",
		StatPlayTime = "Tiempo jugado",
		StatTotalAttempts = "Intentos totales",
		StatPCsUsed = "CP usados",
		StatTrainerBattles = "Combates vs entren.",
		StatWildEncounters = "Encuentros salvajes",
		StatPokemonCaught = "Pokémon capturados",
		StatShopPurchases = "Compras por lotes",
		StatGameSaves = "Partidas guardadas",
		StatTotalSteps = "Pasos totales",
		StatStrugglesUsed = "Usos de Combate",
	},
	UpdateScreen = {
		Title = "Actualizaciones del Tracker",
		VersionCurrent = "Versión actual",
		VersionLatest = "Última versión",
		LabelRelease = "Notas del parche",
		VersionNew = "Nuevo",
		ButtonShow = "Ver",
		ButtonHide = "Nuevo",
		ButtonViewOnline = "Ver en la web",
		CheckboxDevBranch = "Actualizaciones beta",
		ButtonCheckForUpdates = "Buscar actualizaciones",
		ButtonNoUpdates = "Sin actualizaciones",
		ButtonBeginInstall = "Comenzar instalación",
		ButtonInstallNow = "Instalar ahora",
		ButtonInstallFromDev = "Instalar ver. beta",
		ButtonOpenDownload = "Abrir descarga",
		ButtonIgnoreUpdate = "Ignorar actualización", -- Size
		MessageInProgress = "Actualización en curso, por favor espera. Consulta la ventana CMD para ver más.",
		MessageRequireRestart = "Para instalar la actualización, por favor cierra y vuelve a abrir el emulador.",
		MessageError = "Error durante la actualización. Para solucionarlo, reinicia el emulador y vuelve a cargar el script.",
		MessageCheckConsole = "Consulta la consola del Lua para ver el enlace de la últimna actualización del Tracker.",
	},
	StreamerScreen = {
		Title = "Herramientas para Streamer",
		ButtonEdit = "Editar", -- Size
		ButtonStreamConnect = "Conectar Stream",
		LabelAttemptsCount = "Contador de intentos",
		LabelWelcomeMessage = "Mensaje de bienvenida",
		LabelFavorites = "Pokémon favoritos",
		OptionDisplayFavorites = "Mostrar al empezar partida",
		PromptEditAttemptsTitle = "Editar contador de intentos",
		PromptEditAttemptsDesc = "Introduce el número de intentos",
		PromptEditWelcomeTitle = "Editar mensaje de bienvenida",
		PromptEditWelcomeDesc = "Edita el mensaje de bienvenida que aparecerá al empezar nueva partida.",
		PromptChooseFavoriteTitle = "Elige tu favorito",
		PromptChooseFavoriteDesc = "Pokémon favorito que aparece al inicio.",
	},
	InfoScreen = {
		-- Pokémon Info
		ButtonViewEvos = "Ver ...",
		ButtonHistory = "Historial", -- Size
		ButtonResistances = "Mostrar resistencias", -- Size
		ExpYield = "EXP",
		KilogramAbbreviation = "kg",
		LabelWeight = "Peso",
		LabelEvolution = "Evolución",
		LabelLearnMove = "Aprende mov. al nivel",
		LabelNoMoves = "No aprende ningún movimiento",
		LabelWeakTo = "Débil a",
		LabelNoWeaknesses = "Sin debilidades", -- Size
		PromptLookupPokemon = "Elige un Pokémon para ver",
		-- Move Info
		LabelCategory = "Categoría",
		LabelContact = "Contacto",
		LabelPP = "PP",
		LabelPower = "Potencia",
		LabelAccuracy = "Precisión",
		LabelPriority = "Prioridad",
		LabelMoveSummary = "Resumen",
		SetHiddenPowerType = "Sel. tipo",
		PromptLookupMove = "Elige un movimiento para ver",
		-- Ability Info
		LabelEmeraldAbility = "En Esmeralda",
		PromptLookupAbility = "Elige una habilidad para ver",
		-- Route Info
		CheckboxPercentages = "Porcentajes",
		CheckboxLevels = "Niveles",
		LabelSeenBy = "Pokémon vistos",
		LabelSeenEncounters = "Encuentros Pokémon",
		LabelOrderAppearance = "En órden de aparición",
		PromptLookupRoute = "Elige una ruta para ver",
	},
	NotebookIndexScreen = {
		Title = "BLOC DE NOTAS DEL TRACKER",
		LabelReviewDescription = "Revisa las notas de la partida",
		LabelPokemonSeen = "Pokémon vistos",
		LabelTrainersFought = "Entren. peleados",
	},
	NotebookPokemonSeen = {
		Title = "Todos los Pokémon vistos",
		LabelAll = "Todos",
		LabelSeen = "Vistos",
	},
	NotebookPokemonNoteView = {
		HeaderMoveHistory = "Historial de movimientos",
	},
	NotebookTrainersByArea = {
		Title = "Todos los entrenadores por zonas",
		CheckboxShowCompleted = "Mostra completados",
		CheckboxSevii = "Archi7",
	},
	TrainerInfoScreen = {
		LabelAvgIvs = "Media IVs",
		LabelAIScript = "IA Script",
		LabelUsableItems = "Objetos usables",
		LabelDouble = "doble!",
		LabelBattle = "Combate", -- In spanish is Combate (in LabelDouble) doble! (in LabelBattle)
	},
	CustomExtensionsScreen = {
		Title = "Extensiones personalizadas",
		TabGeneral = "General",
		TabExtensions = "Extensiones",
		TabOptions = "Opciones",
		LabelTotalInstalled = "Instaladas totales",
		LabelExtensionsEnabled = "Extensiones activadas",
		ButtonUpdateAllExtensions = "Actualizar extensiones",
		ButtonFindMoreExtensions = "Buscar más extensiones",
		ButtonInstallNewExtension = "Instalar nueva extensión",
		OptionAllowCustomCode = "Permitir código personalizado",
	},
	SingleExtensionScreen = {
		LabelAuthorBy = "Creado por",
		LabelVersion = "Versión",
		LabelEnabled = "Activada",
		EnabledOn = "ON",
		EnabledOff = "OFF",
		ButtonViewOnline = "Ver en línea",
		ButtonOptions = "Opciones", -- Size
		ButtonCheckForUpdates = "Buscar actualizaciones", -- Size
		ButtonUpdateAvailable = "Actualización disponible", -- Size
		ButtonNoUpdateFound = "Ninguna actualización", -- Size
	},
	TrackedDataScreen = {
		Title = "Gestión de datos",
		DescAutoSave = "Los datos trackeados mientras juegas se guardan autom. en cada batalla, almacenados como .TDAT",
		DescManualSave = "Los datos antiguos se perderán si empiezas una partida nueva. Si quieres guardarlos, usa el botón GUARDAR.",
		OptionAutoSaveData = "Guardar autom. los datos",
		ButtonSaveData = "Guardar",
		ButtonLoadData = "Cargar",
		ButtonClearData = "Borrar datos",
		ButtonClearConfirm = "¿Estás seguro?",
		ButtonClearSuccess = "¡Datos borrados!",
		PromptHeaderSave = "Guardar datos del Tracker",
		PromptEnterFilename = "Introduce un nombre para guardar los datos",
	},
	ViewLogWarningScreen = {
		Title = "Advertencia - ¿Ver el Log?",
		ButtonViewCurrentLog = "Ver Log",
		ButtonViewPreviousLog = "Log anterior",
		WarningAreYouSure = "¿Estás seguro que quieres ver el Log?",
		WarningSpiritOfIronmon = "En IronMON, va en contra del espíritu del desafio ver el Log antes de que el juego termine.",
		WarningIfUnsure = "Si no estás seguro, simplemente no cliques en Ver Log.",
	},
	CoverageCalcScreen = {
		Title = "Calculadora de cobertura",
		ButtonAddType = "Añadir tipo",
		ButtonClearTypes = "Limpiar todo", -- Size
		ButtonPokemonMatchups = "Pokémon compatibles", -- Size
		OptionFullyEvolvedOnly = "Solo Pokémon evo. comp.",
		TitleAddMoveType = "Añadir el tipo",
		LabelTotal = "Totales",
	},
	TimeMachineScreen = {
		Title = "Máquina del tiempo",
		OptionEnableRestorePoints = "Activar puntos de restauración",
		DescInstructions = "Selecciona un punto para volver atrás en el tiempo",
		DescNoRestorePoints = "Ningún punto de restauración disponible; Se creará uno cada 5 minutos.",
		RestorePointAgeSingular = "creado hace 1 minuto",
		RestorePointAgePlural = "creado hace %s",
		UndoAndReturnBack = "Volver al futuro",
		ConfirmationRestore = "¿Confirmar restauración?",
		LocationUnknownArea = "Área desconocida",
		ButtonCreate = "Crear",
	},
	CrashRecoveryScreen = {
		Title = "Recuperación de errores",
		StatusMessageCrash = "Error detectado",
		StatusMessageNoCrash = "Ningún error detectado",
		ButtonRecoverSave = "Recuperar save",
		ButtonUndoRecovery = "Deshacer save",
		ButtonDismiss = "Descartar",
		LastPlayedGame = "Último juego",
		SameGameAsLast = "Misma versión del juego",
		SameRomAsLast = "Misma ROM del juego",
		NotAvailable = "(No disponible)",
		OptionEnableCrashRecovery = "Activar recuperación de errores",
	},
	GameOverScreen = {
		Title = "F i n  d e l  j u e g o",
		LabelAttempt = "Intento",
		LabelPlayTime = "Tiempo total",
		ButtonViewGrade = "Ver",
		QuoteCongratulations = "¡¡ENHORABUENA!!",
		ButtonContinuePlaying = "Continuar jugando",
		ButtonRetryBattle = "Reintentar batalla",
		ButtonRetryBattleConfirm = "¿Estás seguro?",
		ButtonSaveAttempt = "Guardar este intento",
		ButtonSaveSuccessful = "Trackers/saved_games",
		ButtonSaveFailed = "Error al guardar",
		ButtonGradeMyNotes = "Puntuar mis notas",
		ButtonInspectLogFile = "Inspeccionar Log",
		ButtonOpenLogFile = "Abrir Log",
		ButtonViewLogSmall = "Ver log",
		ButtonPrizeCard = "Carta premio",
	},
	StatMarkingScoreSheet = {
		Title = "Puntuación efectiva de stats",
		LabelGreatMarks = "Acertadas",
		LabelPoorMarks = "Falladas",
		LabelTotal = "Totales",
		LabelPercentage = "Porcentaje",
		MessageTakeNotesByMarking = "Toma nota mientras juegas marcando las estadísticas del Pokémon contrario. (La estadística de VELOCIDAD está excluida.)",
	},
	RandomEvosScreen = {
		LabelRandomEvos = "Evo. aleatorias",
		LabelEvoShort = "Evo.",
	},
	HealsInBagScreen = {
		TabAll = "Todo",
		TabHP = "PS",
		TabPP = "PP",
		TabStatus = "Estado",
		TabBattle = "Batalla",
	},
	MoveHistoryScreen = {
		HeaderMoves = "Mov. visto al nivel",
		HeaderMin = "Mín",
		HeaderMax = "Máx",
		NoTrackedMoves = "(Sin datos de movimientos)",
		NoMovesLearned = "No aprende ningún movimiento",
		PromptPokemonTitle = "Buscar en la Pokédex",
		PromptPokemonDesc = "Elige al Pokémon",
	},
	CatchRatesScreen = {
		Title = "Porcentaje de captura",
		PokemonsHPPercent = "PS aproximados",
		PokemonsStatus = "Estado",
		HeaderBall = "Ball",
		HeaderBag = "Bag",
		HeaderRate = "Ratio",
	},
	TypeDefensesScreen = {
		Immunities = "Immunidades",
		Resistances = "Resistencias",
		Weaknesses = "Debilidades",
	},
	BattleDetailsScreen = {
		Title = "Detalles de la batalla",
		TextTurn = "Turno",
		TextTerrain = "Terreno",
		TextWeather = "Clima",
		TextWeatherTurns = "Turnos de clima",
		TextAllied = "Aliado",
		TextEnemy = "Enemigo",
		TextTeam = "Equipo",
		TextField = "Efecto de terreno",
		TextTurnsRemaining = "Restantes",
		TextLastMove = "Último mov.",
		TextNotAvailable ="N/D",

		WeatherDefault = "Ninguno",
		WeatherRain = "Lluvia",
		WeatherSandstorm = "Tormenta de arena",
		WeatherSunlight =  "Soleado",
		WeatherHail =  "Granizo",
		TerrainDefault = "Edificio",
		TerrainGrass = "Hierba",
		TerrainLongGrass = "Hierba alta",
		TerrainSand = "Arena",
		TerrainUnderwater = "Bajo el agua",
		TerrainWater = "Agua",
		TerrainPond = "Estanque",
		TerrainMountain = "Montaña",
		TerrainCave = "Cueva",

		EffectConfused = "Confuso",
		EffectMustAttack = "Debe atacar",
		EffectTrapped = "Atrapado",
		EffectCannotAct = "Recargando",
		EffectAirborne = "Aéreo",
		EffectUnderground = "Bajo tierra",
		EffectUnderwater = "Bajo el agua",
		EffectDrowsy = "Somnoliento",
		EffectProtectUses = "Usos de Protección",
		EffectPerishCount = "Cuenta atrás",
		EffectCannotEscape = "No puede escapar",
		EffectTruant = "Holgazaneando",
		EffectFutureSight = "Premonición",
	},
	LogOverlay = { -- Log Viewer
		HeaderTabPokemon = "Pokémon",
		HeaderTabTrainers = "Entrenadores",
		HeaderTabRoutes = "Rutas",
		HeaderTabTMs = "MTs",
		HeaderTabMisc = "Varios",
		LabelBaseStats = "Estad. base",
		LabelBSTTotal = "Total",
		LabelYourIVs = "Tus IVs",
		LabelYourEVs = "Tus EVs",
		LabelShowIVs = "Ver IVs",
		LabelShowEVs = "Ver EVs",
		LabelShowBST = "Ver BST",
		ButtonLevelupMoves = "Mov. por nivel",
		ButtonTMMoves = "Mov. MT",
		LabelGymTMs = "MTs de gimnasio",
		LabelOtherTMs = "Otras MTs",
		LabelFilterBy = "Filtrar por",
		FilterAll = "Todos",
		FilterRival = "Rival",
		FilterGym = "Gimnasio",
		FilterElite4 = "Alto Mando",
		FilterBoss = "Jefe",
		FilterOther = "Otro",
		LabelLocation = "Ubicación",
		LabelEncounters = "Encuentros",
		TabTrainers = "Entrenadores",
		TabGrassCave = "Hierba / Cueva",
		TabSurfing = "Surf",
		TabOldRod = "Caña vieja",
		TabGoodRod = "Caña buena",
		TabSuperRod = "Súper caña",
		TabRockSmash = "Golpe roca",
		FilterTMNumber = "N.º MT",
		FilterGymTMs = "MTs de gimnasio",
		LabelPokemonGame = "Nombre del juego",
		LabelRandomizerVersion = "Versión del Randomizer",
		LabelRandomSeed = "Seed aleatoria",
		LabelSettingsString = "Configuración del String",
		ButtonShareSeed = "Comp. Seed",
		CheckboxShowUnlearnableGymTMs = "Mostrar MTs de gimnasio incompatibles",
		CheckboxShowPreEvolutions = "Mostrar pre-evoluciones",
		CheckboxCustomTrainerNames = "Mostrar nombres personalizados de entrenadores",
		PromptShareSeedTitle = "Compartir Seed randomizada",
		PromptShareSeedDesc = "Copia/pega todo para poder compartir. Cárgalo a través del Randomizer --> Premade Seed.",
	},
	LogSearchScreen = {
		Title = "Buscar en el Log",
		LabelSortBy = "Ordenador por",
		LabelSearch = "Buscar",
		LabelNoResults = "Sin resultados",
		SortAlphabetical = "Alfabético",
		SortPokedexNum = "N.º Pokédex",
		SortBST = "BST",
		SortHP = "PS",
		SortATK = "Ataque",
		SortDEF = "Defensa",
		SortSPA = "At. Esp.",
		SortSPD = "Def. Esp.",
		SortSPE = "Velocidad",
		SortWildPokemonLv = "Nv. Pok. salvaje",
		SortTrainerLevel = "Nv. del entrenador",
		FilterName = "Nombre del Pok.",
		FilterAbility = "Habilidad",
		FilterMove = "Mov. por nivel",
		FilterTrainerName = "Nombre del entr.",
		FilterRouteName = "Nombre de la Ruta",
	},
	GachaMonAnimations = {
		LabelPrizeCardFromTrainer = "Carta premio de entrenador", -- Size
		LabelTabNEW = "NUEVO", -- Size in carrousel its OK, BUT text size in pink box is out
		LabelPressBUTTONtoOpen = "Pulsa (%s) o clica para abrir", -- Size
	},
	GachaMonOverlay = {
		TabRecent = "Capturas",
		TabCollection = "Colección",
		TabView = "Ver",
		TabGachaDex = "GachaDex",
		TabBattle = "Batalla",
		TabOptions = "Opciones",
		TabAbout = "?",

		-- Recent/Captures Tab & Collections Tabs
		RecentCapturesHelpText1 = "Aquí están los GachaMons capturados en esta run.",
		RecentCapturesHelpText2 = "[Añadir a colección] y guardarlos para siempre.",
		LabelSort = "Sort",

		-- View Tab
		LabelRating = "Ranking",
		WordPoints = "puntos",
		WordStars = "estrellas",
		LabelBattlePower = "Pot. Batalla",
		BattlePowerAbbreviation = "PB",
		LabelCollectedOn = "Coleccionado",
		LabelSeed = "Seed",
		LabelStats = "Stats",
		ButtonBattle = "Batalla",
		ButtonFavorite = "Favorito",
		ButtonInCollection = "En colección",
		ButtonAddToCollection = "Añadir a colección",

		-- GachaDex Tab
		LabelSeen = "Vistos", -- Size
		LabelCollAbbreviation = "Col.",

		-- Battle Tab

		-- Options Tab
		LabelOnCaptureHeader = "Cuando capturas nuevo GachaMon, añadir a la colección si",
		LabelRulesetForRatings = "Reglas usadas para rankings",
		LabelTagAuto = "Auto",
		LabelCollectionSize = "GachaMons en colección",
		OptionAutoAddIfNew = "Es una nueva especie de Pokémon",
		OptionAutoAddWhenDefeatTrainers = "Derrota al menos 2 entrenadores",
		OptionShowGachaMonStarsOnTracker = "Mostrar estrellas junto a curaciones",
		OptionShowCardPackOnScreen = "Mostrar apertura de sobre antes de las stats Pokémon",
		OptionAnimateGachaMonPackOpening = "Animar apertura de sobre",
		OptionAutoAddFromTrainerVictory = "Recibir ocasionalmente carta premio de entrenadores",
		ButtonCleanupCollection = "Limpiar colección",

		-- About Tab
		GachaMonGameHeader = "Juego de cartas coleccionable GachaMon", -- Size
		GachaMonGameDescription = "Juega IronMON,  colecciona cartas GachaMon!",
		SectionHowItWorks = "Como funciona",
		LabelCatchPokemon = "Captura Pokémon",
		LabelAcquireGachaMonCards = "Consigue cartas GachaMon",
		LabelKeepCardsInCollection = "Guárdalas en tu colección",
		LabelBattle = "Batalla!  (muy pronto)",
		SectionWhatsOnCard = "Que hay en la carta",
		LabelStarsAndRating = "Estrellas:  Ranking del Pokémon (1- 5)",
		LabelBattlePowerAndStrength = "Pot. Batalla:  Es la fuerza del Pokémon al combatir",
		ButtonHelpWiki = "Ayuda", -- Center text
		MessageCheckConsole = "Consulta la consola Lua para ver un enlace al Wiki de ayuda del Tracker.",
	},
	TeamViewArea = {
		EggNickname = "HUEVO",
	},
	CustomCode = {
		ExtensionsLoaded = "Extensión cargada",
		ExtensionsMissing = "Falta extensión",
	},
	StreamConnect = {
		-- THE BELOW EVENTS NEED TRANSLATION
		CMD_Pokemon_Name = "Info. del Pokémon",
		CMD_Pokemon_Help = "nombre > Muestra info. útil del juego sobre un Pokémon.",
		CMD_BST_Name = "BST del Pokémon",
		CMD_BST_Help = "nombre > Muestra el total de estadísticas base (BST) del Pokémon.",
		CMD_Weak_Name = "Debilidades del Pokémon",
		CMD_Weak_Help = "nombre > Muestra las debilidades del Pokémon.",
		CMD_Move_Name = "Info. del movimiento",
		CMD_Move_Help = "nombre > Muestra la info. del juego sobre un movimiento.",
		CMD_Ability_Name = "Info. de la habilidad",
		CMD_Ability_Help = "nombre > Muestra la info del juego sobre una habilidad.",
		CMD_Trainer_Name = "Info. del entrenador",
		CMD_Trainer_Help = "[name id] > Muestras info. sobre el último entrenador derrotado, o nombre específico del entrenador o la ID.",
		CMD_Route_Name = "Info. de la ruta",
		CMD_Route_Help = "nombre > Muestra info. sobre entrenadores y encuentros salvajes en una ruta o zona.",
		CMD_Dungeon_Name = "Info. de la cueva",
		CMD_Dungeon_Help = "nombre > Muestra info. sobre que entrenadores han sido derrotados en el área.",
		CMD_Unfought_Name = "Entrenadores no derrotados",
		CMD_Unfought_Help = "[cueva] [no dobles] [archi7] > Lista de las áreas ordenadas por menor-nivel, entrenadores no derrotados (Añadir parámetro 'cueva' para cuevas parcialmente completadas y/o 'sin dobles' para excluir combates dobles).",
		CMD_Pivots_Name = "Pivotantes vistos",
		CMD_Pivots_Help = "[safari] > Muestra encuentros salvajes iniciales para un área. (Añadir el parámetro 'safari' para encuentro de mayor-nivel en la Zona Safari).",
		CMD_Revo_Name = "Evoluciones aleatorias",
		CMD_Revo_Help = "nombre [target-ev] > Muestra las posibilidades de evolución aleatoria para el Pokémon, y su [target-evo] si existe más de uno disponible.",
		CMD_Coverage_Name = "Efectividad de la cobertura del tipo",
		CMD_Coverage_Help = "tipos [completamente evolucionado] > Para la lista de tipos de movimientos, verifica la efectividad en todos los enfrentamientos Pokémon (o solo [target-evo]) para la efectividad.",
		CMD_Heals_Name = "Curaciones",
		CMD_Heals_Help = "[pv pp status bayas] > Muestra todas las curas de la mochila, o solo para una [categoría] especificada.",
		CMD_TMs_Name = "MTs conseguidas",
		CMD_TMs_Help = "[gym mo Nº] > Muestra todas las MTs de la mochila, o solo la de una [categoría] específica o N.º MT.",
		CMD_Search_Name = "Buscar info. en el Tracker",
		CMD_Search_Help = "buscarterm > Busca info. ya vista para un Pokémon, movimiento, o habilidad move, or ability.",
		CMD_SearchNotes_Name = "Buscar notas sobre Pokémon",
		CMD_SearchNotes_Help = "notas > Muestra una lista de Pokémon con notas que coincidan.",
		CMD_Favorites_Name = "Starters favoritos",
		CMD_Favorites_Help = "> Muestras la lista de los starters favoritos.",
		CMD_Theme_Name = "Exportar tema",
		CMD_Theme_Help = "nombre > Muestra el nombre y el code string del tema actual.",
		CMD_GameStats_Name = "Estadísticas de la partida",
		CMD_GameStats_Help = "> Muestra estadísticas varias de la partida actual.",
		CMD_Progress_Name = "Progreso de la partida",
		CMD_Progress_Help = "> Muestra el progreso actual de la partida en porcentajes.",
		CMD_Log_Name = "Configuración actual del Randomizer",
		CMD_Log_Help = "> Si el Log se abrió, muestra la configuración compartible del Randomizer actual.",
		CMD_BallQueue_Name = "Cola de los starters",
		CMD_BallQueue_Help = "> Muestra cuanta cola existe y a quien le toca actualmente, si existe alguien.",
		CMD_GachaMon_Name = "Info. GachaMon",
		CMD_GachaMon_Help = "[current nombre] > Muestra la info. de la carta para un GachaMon, más reciente o Pokémon específico.",
		CMD_GachaDex_Name = "Info. GachaDex",
		CMD_GachaDex_Help = "> Muestra la colección e info. del GachaDex.",
		CMD_About_Name = "Acerca del Tracker",
		CMD_About_Help = "> Muestra la info acerca de IronMON Tracker y el juego actual.",
		CMD_Help_Name = "Comando de ayuda",
		CMD_Help_Help = "[comando] > Muestra la lista de todos los comandos, o para una info. específica del [comando].",
		CR_PickBallOnce_Name = "Elige Poké Ball starter (Un intento)",
		CR_PickBallUntilOut_Name = "Elige Poké Ball starter (Hasta salir)",
		CR_ChangeFavorite_Name = "Cambiar starter favorito: # NOMBRE",
		CR_ChangeFavoriteOne_Name = "Cambiar starter favorito: #1",
		CR_ChangeFavoriteTwo_Name = "Cambiar starter favorito: #2",
		CR_ChangeFavoriteThree_Name = "Cambiar starter favorito: #3",
		CR_ChangeTheme_Name = "Cambiar tema del Tracker",
		CR_ChangeLanguage_Name = "Cambiar idioma del Tracker",
		GE_GameOver_Name = "Cuando se termina la partida...",
		GE_GameOver_TriggerEffect = "Actualizar SB Global Variables",
		GE_GachaMonCapture_Name = "Cuando un GachaMon ha sido capturado...",
		GE_GachaMonCapture_TriggerEffect = "Enviar su código compartido base64",
		O_SendMessage = "Mensaje al chat si se completa",
		O_AutoComplete = "Auto completar el canje",
		O_RequireChosenMon = "La dirección elegida debe coincidir",
		O_WordForLeft = "Palabra para la izquierda",
		O_WordForMiddle = "Palabra para el medio",
		O_WordForRight = "Palabra para la derecha",
		O_WordForRandom = "Para para aleatorio",
		O_ShowBallQueueOnStartup = "Muestra la info. de la cola al iniciar",
		-- THE BELOW SCREEN LABELS NEED TRANSLATION
		TabCommands = "Comandos",
		TabRewards = "Recompensas",
		TabQueue = "Cola",
		TabGame = "Juego",
		TabStatus = "Estado",
		ButtonRolePermissions = "Permisos de rol",
		ButtonRename = "Cambiar",
		ButtonOptions = "Opciones",
		ButtonAdd = "Añadir",
		ButtonChange = "Cambiar",
		ButtonQueueAreYouSure = "¿Estás seguro?",
		ButtonQueueClearAll = "Limpiar",
		ButtonQueueConfirm = "Confirmar?",
		ButtonConnect = "Conectar",
		ButtonDisconnect = "Desconectar",
		ButtonSet = "Set",
		ButtonGetStreamerbotCode = "Código Streamerbot",
		ButtonHelp = "Ayuda",
		LabelWaitingForConnection = "(Esperando para conectar...)",
		LabelNoRewardsInQueue = "Ninguna recompensa en la cola.",
		LabelNoGameEvents = "Ningún evento activo se ha añadido.",
		LabelHowToAddGameEvents = "Puedes añadir un nuevo evento activo a través de extensiones personalizadas.",
		LabelConnectionStatus = "Estado de la conexión",
		LabelOnlineEstablished = "En línea: Conexión establecida.",
		LabelOnlineWaiting = "En línea: Esperando para conectar...",
		LabelOffline = "Desconectado.",
		LabelSettings = "Opciones",
		LabelConnectionMode = "Modo de conexión",
		LabelConnectionFolder = "Carpeta de conexión",
		LabelImportCode = "Importar código",
		LabelServerIP = "IP del servidor",
		LabelServerPort = "Puerto",
		LabelHttpGet = "GET",
		LabelHttpPost = "POST",
		WarningSetupImport = "Configuración: Importar código y luego selecciona carpeta.", -- Size
		WarningNotSupported = "Este modo todavía no es soportado por Bizhawk.",
		StatusConnTypeText = "Texto",
		StatusConnTypeWebSockets = "WebSockets",
		StatusConnTypeHttp = "Http",
		OptionAutoConnectStartup = "Conectar automáticamente al iniciar",
		PromptUpdateTitle = "Actualización necesaria de Streamerbot",
		PromptUpdateDesc1 = "El código del Streamerbot Tracker necesita actualizarse.",
		PromptUpdateDesc2 = "Debes reimportar el código para continuar usando Conectar Stream.",
		PromptNetworkShowMe = "Muéstralo",
		PromptNetworkTurnOff = "Apagar Conectar Stream",
		PromptDefault = "Por defecto",
	},
	MGBA = {
		MenuTrackerSettings = "Ajustes del Tracker",
		MenuGeneralSetup = "Opciones generales",
		MenuGameplayOptions = "Opciones de jugabilidad",
		MenuQuickloadSetup = "Configurar nueva run",
		MenuCheckForUpdates = "Buscar actualizaciones",
		MenuNewUpdateVailable = "Nueva actualización disponible",
		MenuLanguage = "Idiomas",
		MenuExtensions = "Extensiones",
		MenuCommands = "Comandos",
		MenuBasicCommands = "Comandos básicos",
		MenuAdvancedCommands = "Comandos avanzados",
		MenuOtherCommands = "Otros comandos",
		MenuInfoLookup = "Info. Pokémon",
		MenuPokemon = "Pokémon",
		MenuMove = "Movimiento",
		MenuAbility = "Habilidad",
		MenuRoute = "Ruta",
		MenuOriginalRoute = "Info. ruta original",
		MenuGameStats = "Estadísticas",
		MenuTracker = "Tracker",
		MenuBattleTracker = "Tracker de combate",
		StartupInstructions = {
			"- Clica en los menús de la izquierda para ver distintas ventanas de información.",
			"- Para usar comandos, escribe el comando en la caja de texto de debajo.",
			"  Envuelve el comando con 'comillas'. Por ejemplo:",
			"    POKÉMON 'Pikachu'",
			"", -- Leave blank just prints a newline
			"- Si no estás seguro que hace el comando, puedes usar: HELP 'command'",
			"- Para más información puedes encontrar la Wiki del Tracker escribiendo: HELPWIKI()",
		},
		OptionKeyError = "La tecla opción no existe",
		OptionFileError = "Archivo no encontrado",
		OptionRightJustifiedNumbers = "Stats alineadas a la derecha", -- Size
		OptionShowNicknames = "Mostrar motes",
		OptionAutosaveTrackedData = "Guardar autom. datos trackeados", -- Size
		OptionTrackPCHeals = "Mostrar curas del CP",
		OptionPCHealsCountDownward = "Orden desc. curas del CP",
		OptionDisplayPedometer = "Mostrar pasos del podómetro", -- Size
		OptionDisplayRepel = "Mostrar uso del repelente",
		OptionDisplayGender = "Mostrar género del Pokémon",
		OptionAnimatedPokemonGIF = "Mostrar GIF del Pokémon",
		OptionDevBranchUpdates = "Actualizaciones beta",
		OptionOverrideButtonModeLR = "Anular botones de LR",
		OptionSwapViewedPokemon = "Pokémon mostrado",
		OptionCycleThroughStats = "Mover entre stats",
		OptionMarkStat = "Marcar stat [+/-]",
		OptionQuickload = "Nueva run",
		OptionAutoswapEnemy = "Mostrar Pok. enem. auto.",
		OptionShowStarterBallInfo = "Info. Poké Ball inicial",
		OptionViewSummaryForStats = "Ver datos para ver stats",
		OptionShowMoveTypes = "Mostrar el tipo del mov.",
		OptionPhysicalSpecialIcons = "Iconos físico / especial",
		OptionShowMoveEffectiveness = "Mostrar mov. superefectivo",
		OptionCalculateVariableDamage = "Calcular daño variable",
		OptionCountEnemyPP = "Mostrar PPs del enemigo",
		OptionShowLastDamage = "Cálculo del último daño",
		OptionRevealRandomizedInfo = "Datos mov./tipos aleat.",
		OptionShowHealsAsValue = "N.º curaciones entero",
		OptionShowBallCatchRate = "Porcentajes de captura",
		OptionAutodetectGameLanguage = "Detectar idioma autom.",
		OptionPremadeRoms = "Usar grupo de ROMs",
		OptionGenerateRom = "Generar una ROM cada vez",
		OptionRomsFolder = "Carpeta de ROMs",
		OptionRandomizerJar = "Randomizer JAR",
		OptionSourceRom = "ROM base",
		OptionSettingsFile = "Opciones de archivo",
		OptionAllowCustomCode = "Permitir código personalizado",
		AnimatedPopoutRequired = "El addon pop-out del Pokémon animado se debe instalar por separado. \n Consulta la Wiki del Tracker para más detalles sobre como configurarlo.",
		JarFileRequired = "Se necesita un archivo '.jar'; por favor introduce la ruta completa para el archivo JAR Randomizer.",
		GbaFileRequired = "Se necesita un archivo '.gba'; por favor introduce la ruta completa para el archivo ROM de GBA.",
		RnqsFileRequired = "Se necesita un archivo '.rnqs'; por favor introduce la ruta completa para el archivo RNQS.",
		ButtonInputRequired = "Entrada de botón necesaria; botones disponibles: A, B, L, R, Start, Select",
	},
	MGBAScreens = {
		SymbolStatus = " ",
		SymbolPhysical = "F",
		SymbolSpecial = "E",
		SymbolEffectivenessImmune = "X",
		SymbolEffectivenessResist = "-",
		SymbolEffectivenessResistDouble = "--",
		SymbolEffectivenessWeak = "+",
		SymbolEffectivenessWeakDouble = "++",
		LabelImmunities = "Immunidades",
		LabelResistances = "Resistencias",
		LabelWeaknesses = "Debilidades",
		LabelPhysical = "Físico",
		LabelSpecial = "Especial",
		LabelStatus = "Estado",
		LabelToggleOption = "Alternar opción con",
		LabelOption = "Opción",
		LabelEnabled = "Activado", -- Size
		GeneralSetupChange = "Cambiar con",
		GeneralSetupButtons = "botón(es)",
		GeneralSetupControls = "Controles",
		GeneralSetupGBAButtons = "Botones GBA",
		GameplayOptionsManualSave = "Guardar/cargar datos trackeados manualmente",
		QuickloadDesc = "Para usar una nueva run, coloca el archivo necesario en la carpeta [quickload] que la encontrarás en la carpeta GBA Tracker.",
		QuickloadChooseMode = "Elegir modo con",
		QuickloadMode = "Modo",
		QuickloadSelected = "Seleccionado", -- Size
		QuickloadRequiredFiles = "Archivos necesarios",
		QuickloadRequiredFilesOneEach = "Archivos necesarios (solo 1 de cada)",
		QuickloadMultipleRoms = "Archivos múltiples de ROM GBA con #s",
		QuickloadJarFile = "Archivo JAR de tu Randomizer",
		QuickloadRnqsFile = "Archivo de opciones RNQS ",
		QuickloadGbaFile = "ROM GBA par randomizar",
		QuickloadButtonCombo = "Combinación de botones",
		QuickloadTextCommand = "Comando de texto",
		UpdateAvailable = "¡Actualización disponible!",
		UpdateCurrentVersion = "Versión actual",
		UpdateLastCheckedVersion = "Última versión vista",
		UpdateNewVersionAvailable = "Nueva versión disponible",
		UpdateManualCheck = "Buscar actualizaciones manualmente",
		UpdateViewReleaseNotes = "Ver notas del parche",
		UpdateDownloadInstall = "Descargar e instalar automaticamente",
		LanguageCurrent = "Idioma actual",
		LanguageChangeWith = "Cambiar tu idioma con",
		LanguageHeaderTag = "Etiqueta",
		LanguageHeaderLang = "Idioma",
		ExtensionsInstallNewWith = "Instalar nueva extensión con",
		ExtensionsInstalledExtensions = "Extensiones instaladas",
		ExtensionsEnableDisable = "Activar/desactivar con",
		CommandsDesc = "Para usar, escribe en la caja de texto de debajo. Por ejemplo",
		CommandsUsageSyntax = "Usar sintaxis",
		CommandsExampleUsage = "Ejemplo de uso",
		PokemonInfoBST = "BST",
		PokemonInfoEXP = "EXP",
		PokemonInfoWeight = "Peso",
		PokemonInfoEvolution = "Evolución",
		PokemonInfoKg = "kg",
		PokemonInfoLevelupMoves = "Movimientos en los niveles",
		PokemonInfoNone = "Ninguno",
		PokemonInfoNote = "Nota",
		PokemonInfoLeaveNote = "(Deja una nota)",
		MoveInfoCategory = "Categoría",
		MoveInfoContact = "Contacto",
		MoveInfoPP = "PP",
		MoveInfoPower = "Potencia",
		MoveInfoAccuracy = "Precisión",
		MoveInfoPriority = "Prioridad",
		MoveInfoSummary = "Resumen del movimiento",
		MoveInfoEmeraldBonus = "En Esmeralda",
		MoveInfoNormalPriority = "Normal",
		RouteInfoUnknownArea = "ÁREA DESCONOCIDA",
		RouteInfoTracked = "Trackeado",
		RouteInfoOriginal = "Original",
		RouteInfoSeen = "vistos",
		TrackerLevel = "Nv",
		TrackerBST = "BST",
		TrackerHP = "PV",
		TrackerAttack = "ATQ",
		TrackerDefense = "DEF",
		TrackerSpAttack = "ASP",
		TrackerSpDefense = "DSP",
		TrackerSpeed = "VEL",
		TrackerCatchRate = "Porcentajes de captura",
		TrackerSurvivalPCs = "PCs restantes",
		TrackerHeals = "Curaciones",
		TrackerLastSeen = "Última vez visto", -- NEEDS TRANSLATION || Can't confirm if it fits because interface when load is bugged. Same with the next ones in this section.
		TrackerNewEncounter = "¡Nuevo encuentro!", -- NEEDS TRANSLATION
		TrackerSeenWild = "Visto salvaje", -- NEEDS TRANSLATION
		TrackerSeenTrainers = "Visto en entrenadores", -- NEEDS TRANSLATION
		TrackerTrainerTeam = "Equipo del entrenador", -- NEEDS TRANSLATION
		TrackerBadges = "Medallas", -- NEEDS TRANSLATION
		TrackerRepel = "Repel", -- NEEDS TRANSLATION
		TrackerHeaderPP = "PP",
		TrackerHeaderPow = "Pot",
		TrackerHeaderAcc = "Pre",
		TrackerHeaderType = "Tipo",
	},
	MGBACommands = {
		UsageError = "[Error de comando] Sintaxis de uso",
		AllCommandsDesc = "Lista de todos los comandos disponibles. usa HELP 'command' para aprender más sobre cualquier comando.",
		HelpDesc = "Se usa para explicar la función de otros comandos y cómo usarlos.",
		HelpUsage = "Uso",
		HelpExample = "Ejemplo",
		HelpError1 = "Donde 'command' es el nombre de un comando.",
		HelpError2 = "Comando no encontrado. Consulta la lista de comandos en el menú lateral de la izquierda.",
		NoteDesc = "Establece la nota trackeada para el Pokémon oponente que estás viendo actualmente.",
		NoteError1 = "Donde 'text' es la nota que dejas para el Pokémon oponente que estás viendo actualmente.",
		NoteError2 = "No se puede dejar una nota; actualmente no estás viendo ningún Pokémon.",
		NoteError3 = "Solo puedes dejar notas para Pokémon enemigos que estés viendo actualmente.",
		NoteSuccess = "Nota añadida para",
		InfoLookupSuccess = "¡Encontrado! Consulta el menú de la izquierda.",
		PokemonDesc = "Busca información útil de la Pokédex sobre un Pokémon, mostrado en el menú lateral de la izquierda.",
		PokemonError1 = "Donde 'name' es un nombre Pokémon válido.",
		PokemonError2 = "Imposible encontrar el Pokémon",
		MoveDesc = "Busca información útil sobre un movimiento del Pokémon, mostrado en el menú lateral de la izquierda.",
		MoveError1 = "Donde 'name' es un nombre válido de movimiento Pokémon.",
		MoveError2 = "Imposible encontrar el movimiento",
		AbilityDesc = "Busca información útil sobre una habilidad del Pokémon, mostrada en el menú lateral de la izquierda.",
		AbilityError1 = "Donde 'name' es un nombre válido de habilidad del Pokémon.",
		AbilityError2 = "Imposible encontrar la habilidad",
		RouteDesc = "Busca inormación útil sobre una ruta, mostrada en la barra lateral de la izquierda. \n Consejo: Intenta añadir un numero de piso después del nombre de la ruta. ej. Mt. Moon P1", -- \n is a newline
		RouteError1 = "Donde 'name' es un nombre válido de número de ruta o nombre de ruta.",
		RouteError2 = "Imposible encontrar la ruta",
		OptionDesc = "Alterna una opción ON u OFF.\n Para algunas opciones, necesitarás proporcionar texto adicional para cambiarla.",
		OptionError1 = "Donde # es un número válido, seguido de cualquier texto opcional.",
		OptionSuccess = "Actualizando opción",
		OptionOn = "ON",
		OptionOff = "OFF",
		OptionError2 = "la opción no existe. Por favor prueba con otro número.",
		HiddenPowerDesc = "Establece el tipo de Poder Oculto para tu Pokémon activo.\n Esto ayuda a la efectividad de los movimientos calculados en batalla.",
		HiddenPowerError1 = "Donde 'type' es un tipo válido.",
		HiddenPowerError2 = "Todavía no tienes a un Pokémon.",
		HiddenPowerError3 = "Tu Pokémon no tiene el movimiento",
		HiddenPowerError4 = "Imposible encontrar el tipo",
		HiddenPowerSuccess1 = "Tipo establecido para",
		HiddenPowerSuccess2 = "La efectivdad del movimiento es visible en el Tracker durante la batalla.",
		HiddenPowerSuccess3 = "Activa la opción 'Show move effectiveness' para ver el tipo durante la batalla.",
		PCHealsDesc = "Te permite cambiar manualmente el uso de los Centros Pokémon a un número distinto.",
		PCHealsError1 = "Donde # es un número positivo entre 0 y 99.",
		PCHealsSuccess = "Actualizando el número de curas del CP",
		CreditsDesc = "Mostrar la lista del equipo de personas que ayudaron a crear IronMON Tracker.",
		CreditsCreated = "Creado por",
		CreditsContributors = "Colaboradores",
		SaveDataDesc = "Guarda todos los datos trackeados del juego actual.\n El archivo de guardado TDAT puedes encontrarlo en la carpeta principal del Tracker.",
		SaveDataError1 = "Donde 'filename' es un nombre válido para el archivo.",
		SaveDataSuccess = "Datos trackeados guardados para este juego en la carpeta del Tracker como",
		LoadDataDesc = "Carga datos trackeados de la anterior partida.\n Cargado desde el archivo TDAT encontrado en la carpeta principal del Tracker.",
		LoadDataError1 = "Donde 'filename' es el nombre del archivo que existe en la carpeta del Tracker.",
		LoadDataError2 = "Los datos trackeados de este archivo no coinciden con este juego. Restaurando datos trackeados.",
		LoadDataError3 = "Imposible cargar datos trackeados del archivo específico. Asegúrate que esté en la carpeta del Tracker.",
		ClearDataDesc = "Borra todos los datos trackeados para esta partida.\n Esto puede solucionar situaciones donde se muestran datos incorrectos.",
		ClearDataSuccess = "Todos los datos trackeados para esta partida han sido borrados.",
		CheckUpdateDesc = "Verifica en línea si existen versiones nuevas del Tracker disponibles, mostradas en la barra lateral de la izquierda",
		CheckUpdateFound = "¡Actualización encontrada! Consulta el menú de la barra lateral izquierda para verla.",
		CheckUpdateNotFound = "No hay actualizaciones disponibles. Última version disponible",
		ReleaseNotesDesc = "Abre el navegador para ver los detalles del último parche actualizado.",
		UpdateNowDesc = "Actualiza automaticamente el Tracker descargando e instalando la última versión.",
		UpdateNowSuccess = "Actualización en curso, por favor espera...",
		UpdateNowSteps0 = "Sigue los pasos para reiniciar el Tracker y aplicar la actualización.",
		UpdateNowSteps1 = "Completa primero una batalla en curso",
		UpdateNowSteps2 = "En la ventana de scripts en mGBA: Clica en el archivo -> Reiniciar",
		UpdateNowSteps3 = "Clica en el archivo -> Cargar script (o carga el script reciente)",
		QuickloadDesc = "Fuerza al Tracker a cargar automaticamente una nueva partida.",
		HelpWikiDesc = "Abre el navegador para mostrar información útil que te explica opciones varias del Tracker.",
		AttemptsDesc = "Permite cambiar manualmente los intentos a otro número, mostrado en la barra lateral de Estadísticas.",
		AttemptsError1 = "Donde # es un número positivo.",
		AttemptsSuccess = "Actualizando el contandor de intentos",
		RandomBallDesc = "Elige una Poké Ball inicial aleatoria entre: Izquierda, centro o Derecha.",
		RandomBallSuccess = "Poké Ball inicial aleatoria elegida.",
		LanguageDesc = "Cambia el dioma del Tracker.",
		LanguageError1 = "Donde 'language' es el nombre o # de un idioma. Consulta el menú de idioma en la barra lateral.",
		LanguageError2 = "Imposible encontrar el idioma",
		LanguageSuccess = "El idioma del Tracker ha sido actualizado.",
		InstallExtDesc = "Instala archivos nuevos de extensión desde la carpeta del Tracker.",
		InstallExtSuccess1 = "¡Se han instalado nuevas extensiones!",
		InstallExtSuccess2 = "No se encontraron archivos nuevos de extensión en la carpeta del Tracker.",
	},
}

GameResources{
	PokemonTypes = {
		normal = "Normal",
		fighting = "Lucha",
		flying = "Volador",
		poison = "Veneno",
		ground = "Tierra",
		rock = "Roca",
		bug = "Bicho",
		ghost = "Fantasma",
		steel = "Acero",
		fire = "Fuego",
		water = "Agua",
		grass = "Planta",
		electric = "Eléctrico",
		psychic = "Psíquico",
		ice = "Hielo",
		dragon = "Dragón",
		dark = "Siniestro",
		unknown = "???", -- For the move "Curse"
	},
	-- The list of Pokémon moves below must remain in the same order
	MoveNames = {
		"Destructor", --Destructor english:Pound
		"Golpe Karate", --Golpe Kárate english:Karate Chop
		"Doblebofetón", --Doblebofetón english:DoubleSlap
		"Puño Cometa", --Puño Cometa english:Comet Punch
		"Megapuño", --Megapuño english:Mega Punch
		"Día De Pago", --Día De Pago english:Pay Day
		"Puño Fuego", --Puño Fuego english:Fire Punch
		"Puño Hielo", --Puño Hielo english:Ice Punch
		"Puño Trueno", --Puño Trueno english:ThunderPunch
		"Arañazo", --Arañazo english:Scratch
		"Agarre", --Agarre english:ViceGrip
		"Guillotina", --Guillotina english:Guillotine
		"V. Cortante", --V. Cortante english:Razor Wind
		"Danza Espada", --Danza Espada english:Swords Dance
		"Corte", --Corte english:Cut
		"Tornado", --Tornado english:Gust
		"Ataque Ala", --Ataque Ala english:Wing Attack
		"Remolino", --Remolino english:Whirlwind
		"Vuelo", --Vuelo english:Fly
		"Atadura", --Atadura english:Bind
		"Portazo", --Portazo english:Slam
		"Látigo Cepa", --Látigo Cepa english:Vine Whip
		"Pisotón", --Pisotón english:Stomp
		"Doble Patada", --Doble Patada english:Double Kick
		"Megapatada", --Megapatada english:Mega Kick
		"Patada Salto", --Patada Salto english:Jump Kick
		"Patada Giro", --Patada Giro english:Rolling Kick
		"Ataque Arena", --Ataque Arena english:Sand-Attack
		"Golpe Cabeza", --Golpe Cabeza english:Headbutt
		"Cornada", --Cornada english:Horn Attack
		"Ataque Furia", --Ataque Furia english:Fury Attack
		"Perforador", --Perforador english:Horn Drill
		"Placaje", --Placaje english:Tackle
		"Golpe Cuerpo", --Golpe Cuerpo english:Body Slam
		"Repetición", --Repetición english:Wrap
		"Derribo", --Derribo english:Take Down
		"Golpe", --Golpe english:Thrash
		"Doble Filo", --Doble Filo english:Double-Edge
		"Látigo", --Látigo english:Tail Whip
		"Picotazo Ven.", --Picotazo Ven. english:Poison Sting
		"Dobleataque", --Dobleataque english:Twineedle
		"Pin Misil", --Pin Misil english:Pin Missile
		"Malicioso", --Malicioso english:Leer
		"Mordisco", --Mordisco english:Bite
		"Gruñido", --Gruñido english:Growl
		"Rugido", --Rugido english:Roar
		"Canto", --Canto english:Sing
		"Supersónico", --Supersónico english:Supersonic
		"Bomba Sónica", --Bomba Sónica english:SonicBoom
		"Anulación", --Anulación english:Disable
		"Ácido", --Ácido english:Acid
		"Ascuas", --Ascuas english:Ember
		"Lanzallamas", --Lanzallamas english:Flamethrower
		"Neblina", --Neblina english:Mist
		"Pistola Agua", --Pistola Agua english:Water Gun
		"Hidrobomba", --Hidrobomba english:Hydro Pump
		"Surf", --Surf english:Surf
		"Rayo Hielo", --Rayo Hielo english:Ice Beam
		"Ventisca", --Ventisca english:Blizzard
		"Psicorrayo", --Psicorrayo english:Psybeam
		"Rayo Burbuja", --Rayo Burbuja english:BubbleBeam
		"Rayo Aurora", --Rayo Aurora english:Aurora Beam
		"Hiperrayo", --Hiperrayo english:Hyper Beam
		"Picotazo", --Picotazo english:Peck
		"Pico Taladro", --Pico Taladro english:Drill Peck
		"Sumisión", --Sumisión english:Submission
		"Patada Baja", --Patada Baja english:Low Kick
		"Contador", --Contador english:Counter
		"Mov. Sísmico", --Mov. Sísmico english:Seismic Toss
		"Fuerza", --Fuerza english:Strength
		"Absorber", --Absorber english:Absorb
		"Megaagotar", --Megaagotar english:Mega Drain
		"Drenadoras", --Drenadoras english:Leech Seed
		"Desarrollo", --Desarrollo english:Growth
		"Hoja Afilada", --Hoja Afilada english:Razor Leaf
		"Rayo Solar", --Rayo Solar english:SolarBeam
		"Polvo Veneno", --Polvo Veneno english:PoisonPowder
		"Paralizador", --Paralizador english:Stun Spore
		"Somnífero", --Somnífero english:Sleep Powder
		"Danza Pétalo", --Danza Pétalo english:Petal Dance
		"Disp. Demora", --Disp. Demora english:String Shot
		"Furia Dragón", --Furia Dragón english:Dragon Rage
		"Giro Fuego", --Giro Fuego english:Fire Spin
		"Impactrueno", --Impactrueno english:ThunderShock
		"Rayo", --Rayo english:Thunderbolt
		"Onda Trueno", --Onda Trueno english:Thunder Wave
		"Trueno", --Trueno english:Thunder
		"Lanzarrocas", --Lanzarrocas english:Rock Throw
		"Terremoto", --Terremoto english:Earthquake
		"Fisura", --Fisura english:Fissure
		"Excavar", --Excavar english:Dig
		"Tóxico", --Tóxico english:Toxic
		"Confusión", --Confusión english:Confusion
		"Psíquico", --Psíquico english:Psychic
		"Hipnosis", --Hipnosis english:Hypnosis
		"Meditación", --Meditación english:Meditate
		"Agilidad", --Agilidad english:Agility
		"At. Rápido", --At. Rápido english:Quick Attack
		"Furia", --Furia english:Rage
		"Teletransp", --Teletransp english:Teleport
		"Tinieblas", --Tinieblas english:Night Shade
		"Mimético", --Mimético english:Mimic
		"Chirrido", --Chirrido english:Screech
		"Doble Equipo", --Doble Equipo english:Double Team
		"Recuperación", --Recuperación english:Recover
		"Fortaleza", --Fortaleza english:Harden
		"Reducción", --Reducción english:Minimize
		"Pantallahumo", --Pantallahumo english:SmokeScreen
		"Rayo Confuso", --Rayo Confuso english:Confuse Ray
		"Refugio", --Refugio english:Withdraw
		"Rizo Defensa", --Rizo Defensa english:Defense Curl
		"Barrera", --Barrera english:Barrier
		"Pantalla Luz", --Pantalla Luz english:Light Screen
		"Niebla", --Niebla english:Haze
		"Reflejo", --Reflejo english:Reflect
		"Foco Energía", --Foco Energía english:Focus Energy
		"Venganza", --Venganza english:Bide
		"Metrónomo", --Metrónomo english:Metronome
		"Mov. Espejo", --Mov. Espejo english:Mirror Move
		"Autodestruc", --Autodestruc english:Selfdestruct
		"Bomba Huevo", --Bomba Huevo english:Egg Bomb
		"Lengüetazo", --Lengüetazo english:Lick
		"Polución", --Polución english:Smog
		"Residuos", --Residuos english:Sludge
		"Hueso Palo", --Hueso Palo english:Bone Club
		"Llamarada", --Llamarada english:Fire Blast
		"Cascada", --Cascada english:Waterfall
		"Tenaza", --Tenaza english:Clamp
		"Rapidez", --Rapidez english:Swift
		"Cabezazo", --Cabezazo english:Skull Bash
		"Clavo Cañón", --Clavo Cañón english:Spike Cannon
		"Restricción", --Restricción english:Constrict
		"Amnesia", --Amnesia english:Amnesia
		"Kinético", --Kinético english:Kinesis
		"Amortiguador", --Amortiguador english:Softboiled
		"Pat. S. Alta", --Pat. S. Alta english:Hi Jump Kick
		"Deslumbrar", --Deslumbrar english:Glare
		"Come Sueños", --Come Sueños english:Dream Eater
		"Gas Venenoso", --Gas Venenoso english:Poison Gas
		"Presa", --Presa english:Barrage
		"Chupavidas", --Chupavidas english:Leech Life
		"Beso Amoroso", --Beso Amoroso english:Lovely Kiss
		"Ataque Aéreo", --Ataque Aéreo english:Sky Attack
		"Transform", --Transform english:Transform
		"Burbuja", --Burbuja english:Bubble
		"Puño Mareo", --Puño Mareo english:Dizzy Punch
		"Espora", --Espora english:Spore
		"Destello", --Destello english:Flash
		"Psicoonda", --Psicoonda english:Psywave
		"Salpicadura", --Salpicadura english:Splash
		"Armad. Ácida", --Armad. Ácida english:Acid Armor
		"Martillazo", --Martillazo english:Crabhammer
		"Explosión", --Explosión english:Explosion
		"Golpes Furia", --Golpes Furia english:Fury Swipes
		"Huesomerang", --Huesomerang english:Bonemerang
		"Descanso", --Descanso english:Rest
		"Avalancha", --Avalancha english:Rock Slide
		"Hip. colmillo", --Hip. colmillo english:Hyper Fang
		"Afilar", --Afilar english:Sharpen
		"Conversión", --Conversión english:Conversion
		"Triataque", --Triataque english:Tri Attack
		"Superdiente", --Superdiente english:Super Fang
		"Cuchillada", --Cuchillada english:Slash
		"Sustituto", --Sustituto english:Substitute
		"Combate", --Combate english:Struggle
		"Esquema", --Esquema english:Sketch
		"Triplepatada", --Triplepatada english:Triple Kick
		"Ladrón", --Ladrón english:Thief
		"Telaraña", --Telaraña english:Spider Web
		"Telépata", --Telépata english:Mind Reader
		"Pesadilla", --Pesadilla english:Nightmare
		"Rueda Fuego", --Rueda Fuego english:Flame Wheel
		"Ronquido", --Ronquido english:Snore
		"Maldición", --Maldición english:Curse
		"Azote", --Azote english:Flail
		"Conversión2", --Conversión2 english:Conversion 2
		"Aerochorro", --Aerochorro english:Aeroblast
		"Esporagodón", --Esporagodón english:Cotton Spore
		"Inversión", --Inversión english:Reversal
		"Rencor", --Rencor english:Spite
		"Nieve Polvo", --Nieve Polvo english:Powder Snow
		"Protección", --Protección english:Protect
		"Ultrapuño", --Ultrapuño english:Mach Punch
		"Cara Susto", --Cara Susto english:Scary Face
		"Finta", --Finta english:Faint Attack
		"Beso Dulce", --Beso Dulce english:Sweet Kiss
		"Tambor", --Tambor english:Belly Drum
		"Bomba Lodo", --Bomba Lodo english:Sludge Bomb
		"Bofetón lodo", --Bofetón lodo english:Mud-Slap
		"Pulpocañón", --Pulpocañón english:Octazooka
		"Púas", --Púas english:Spikes
		"Electrocañón", --Electrocañón english:Zap Cannon
		"Profecía", --Profecía english:Foresight
		"Mismodestino", --Mismodestino english:Destiny Bond
		"Canto Mortal", --Canto Mortal english:Perish Song
		"Viento Hielo", --Viento Hielo english:Icy Wind
		"Detección", --Detección english:Detect
		"Ataque Óseo", --Ataque Óseo english:Bone Rush
		"Fijar Blanco", --Fijar Blanco english:Lock-On
		"Enfado", --Enfado english:Outrage
		"Torm. Arena", --Torm. Arena english:Sandstorm
		"Gigadrenado", --Gigadrenado english:Giga Drain
		"Aguante", --Aguante english:Endure
		"Encanto", --Encanto english:Charm
		"Desenrollar", --Desenrollar english:Rollout
		"Falsotortazo", --Falsotortazo english:False Swipe
		"Contoneo", --Contoneo english:Swagger
		"Batido", --Batido english:Milk Drink
		"Chispa", --Chispa english:Spark
		"Cortefuria", --Cortefuria english:Fury Cutter
		"Ala De Acero", --Ala De Acero english:Steel Wing
		"Mal De Ojo", --Mal De Ojo english:Mean Look
		"Atracción", --Atracción english:Attract
		"Sonámbulo", --Sonámbulo english:Sleep Talk
		"Campana Cura", --Campana Cura english:Heal Bell
		"Retroceso", --Retroceso english:Return
		"Presente", --Presente english:Present
		"Frustración", --Frustración english:Frustration
		"Velo Sagrado", --Velo Sagrado english:Safeguard
		"Divide Dolor", --Divide Dolor english:Pain Split
		"Fuegosagrado", --Fuegosagrado english:Sacred Fire
		"Magnitud", --Magnitud english:Magnitude
		"Puñodinámico", --Puñodinámico english:DynamicPunch
		"Megacuerno", --Megacuerno english:Megahorn
		"Dragoaliento", --Dragoaliento english:DragonBreath
		"Relevo", --Relevo english:Baton Pass
		"Otra Vez", --Otra Vez english:Encore
		"Persecución", --Persecución english:Pursuit
		"Giro Rápido", --Giro Rápido english:Rapid Spin
		"Dulce Aroma", --Dulce Aroma english:Sweet Scent
		"Cola Férrea", --Cola Férrea english:Iron Tail
		"Garra Metal", --Garra Metal english:Metal Claw
		"Tiro Vital", --Tiro Vital english:Vital Throw
		"Sol Matinal", --Sol Matinal english:Morning Sun
		"Síntesis", --Síntesis english:Synthesis
		"Luz Lunar", --Luz Lunar english:Moonlight
		"Poder Oculto", --Poder Oculto english:Hidden Power
		"Tajo Cruzado", --Tajo Cruzado english:Cross Chop
		"Ciclón", --Ciclón english:Twister
		"Danza Lluvia", --Danza Lluvia english:Rain Dance
		"Día Soleado", --Día Soleado english:Sunny Day
		"Triturar", --Triturar english:Crunch
		"Manto Espejo", --Manto Espejo english:Mirror Coat
		"Más Psique", --Más Psique english:Psych Up
		"Vel. Extrema", --Vel. Extrema english:ExtremeSpeed
		"Poder Pasado", --Poder Pasado english:AncientPower
		"Bola Sombra", --Bola Sombra english:Shadow Ball
		"Premonición", --Premonición english:Future Sight
		"Golpe Roca", --Golpe Roca english:Rock Smash
		"Torbellino", --Torbellino english:Whirlpool
		"Paliza", --Paliza english:Beat Up
		"Sorpresa", --Sorpresa english:Fake Out
		"Alboroto", --Alboroto english:Uproar
		"Reserva", --Reserva english:Stockpile
		"Escupir", --Escupir english:Spit Up
		"Tragar", --Tragar english:Swallow
		"Onda Ígnea", --Onda Ígnea english:Heat Wave
		"Granizo", --Granizo english:Hail
		"Tormento", --Tormento english:Torment
		"Camelo", --Camelo english:Flatter
		"Fuego Fatuo", --Fuego Fatuo english:Will-O-Wisp
		"Legado", --Legado english:Memento
		"Imagen", --Imagen english:Facade
		"Puño Certero", --Puño Certero english:Focus Punch
		"Estímulo", --Estímulo english:SmellingSalt
		"Señuelo", --Señuelo english:Follow Me
		"Adaptación", --Adaptación english:Nature Power
		"Carga", --Carga english:Charge
		"Mofa", --Mofa english:Taunt
		"Refuerzo", --Refuerzo english:Helping Hand
		"Truco", --Truco english:Trick
		"Imitación", --Imitación english:Role Play
		"Deseo", --Deseo english:Wish
		"Ayuda", --Ayuda english:Assist
		"Arraigo", --Arraigo english:Ingrain
		"Fuerza Bruta", --Fuerza Bruta english:Superpower
		"Capa Mágica", --Capa Mágica english:Magic Coat
		"Reciclaje", --Reciclaje english:Recycle
		"Desquite", --Desquite english:Revenge
		"Demolición", --Demolición english:Brick Break
		"Bostezo", --Bostezo english:Yawn
		"Desarme", --Desarme english:Knock Off
		"Esfuerzo", --Esfuerzo english:Endeavor
		"Estallido", --Estallido english:Eruption
		"Intercambio", --Intercambio english:Skill Swap
		"Cerca", --Cerca english:Imprison
		"Alivio", --Alivio english:Refresh
		"Rabia", --Rabia english:Grudge
		"Robo", --Robo english:Snatch
		"Daño Secreto", --Daño Secreto english:Secret Power
		"Buceo", --Buceo english:Dive
		"Empujón", --Empujón english:Arm Thrust
		"Camuflaje", --Camuflaje english:Camouflage
		"Ráfaga", --Ráfaga english:Tail Glow
		"Resplandor", --Resplandor english:Luster Purge
		"Bola Neblina", --Bola Neblina english:Mist Ball
		"Danza Pluma", --Danza Pluma english:FeatherDance
		"Danza Caos", --Danza Caos english:Teeter Dance
		"Patada Ígnea", --Patada Ígnea english:Blaze Kick
		"Chapoteolodo", --Chapoteolodo english:Mud Sport
		"Bola Hielo", --Bola Hielo english:Ice Ball
		"Brazo Pincho", --Brazo Pincho english:Needle Arm
		"Relajo", --Relajo english:Slack Off
		"Vozarrón", --Vozarrón english:Hyper Voice
		"Colmillo Ven", --Colmillo Ven english:Poison Fang
		"Garra Brutal", --Garra Brutal english:Crush Claw
		"Anillo Ígneo", --Anillo Ígneo english:Blast Burn
		"Hidrocañón", --Hidrocañón english:Hydro Cannon
		"Puño Meteoro", --Puño Meteoro english:Meteor Mash
		"Impresionar", --Impresionar english:Astonish
		"Meteorobola", --Meteorobola english:Weather Ball
		"Aromaterapia", --Aromaterapia english:Aromatherapy
		"Llanto Falso", --Llanto Falso english:Fake Tears
		"Aire Afilado", --Aire Afilado english:Air Cutter
		"Sofoco", --Sofoco english:Overheat
		"Rastreo", --Rastreo english:Odor Sleuth
		"Tumba Rocas", --Tumba Rocas english:Rock Tomb
		"Viento Plata", --Viento Plata english:Silver Wind
		"Eco Metálico", --Eco Metálico english:Metal Sound
		"Silbato", --Silbato english:GrassWhistle
		"Cosquillas", --Cosquillas english:Tickle
		"Masa Cósmica", --Masa Cósmica english:Cosmic Power
		"Salpicar", --Salpicar english:Water Spout
		"Doble Rayo", --Doble Rayo english:Signal Beam
		"Puño Sombra", --Puño Sombra english:Shadow Punch
		"Paranormal", --Paranormal english:Extrasensory
		"Gancho Alto", --Gancho Alto english:Sky Uppercut
		"Bucle Arena", --Bucle Arena english:Sand Tomb
		"Frío Polar", --Frío Polar english:Sheer Cold
		"Agua Lodosa", --Agua Lodosa english:Muddy Water
		"Recurrente", --Recurrente english:Bullet Seed
		"Golpe Aéreo", --Golpe Aéreo english:Aerial Ace
		"Carámbano", --Carámbano english:Icicle Spear
		"Def. Férrea", --Def. Férrea english:Iron Defense
		"Bloqueo", --Bloqueo english:Block
		"Aullido", --Aullido english:Howl
		"Garra Dragón", --Garra Dragón english:Dragon Claw
		"Planta Feroz", --Planta Feroz english:Frenzy Plant
		"Corpulencia", --Corpulencia english:Bulk Up
		"Bote", --Bote english:Bounce
		"Disp.Lodo", --Disp. Lodo english:Mud Shot
		"Cola Veneno", --Cola Veneno english:Poison Tail
		"Antojo", --Antojo english:Covet
		"Placaje Eléc", --Placaje Eléc english:Volt Tackle
		"Hoja Mágica", --Hoja Mágica english:Magical Leaf
		"Hidrochorro", --Hidrochorro english:Water Sport
		"Paz Mental", --Paz Mental english:Calm Mind
		"Hoja Aguda", --Hoja Aguda english:Leaf Blade
		"Danza Dragón", --Danza Dragón english:Dragon Dance
		"Pedrada", --Pedrada english:Rock Blast
		"Onda Voltio", --Onda Voltio english:Shock Wave
		"Hidropulso", --Hidropulso english:Water Pulse
		"Deseo Oculto", --Deseo Oculto english:Doom Desire
		"Psicoataque", --Psicoataque english:Psycho Boost
	},
	-- The list below must remain in the same order.
	-- These are custom hand-written move summaries, only edit the "Description" value
	MoveDescriptions = {
		{
			NameKey = "Pound",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Karate Chop",
			Description = "Inflige daño y tiene una probabilidad aumentada de golpe crítico. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "DoubleSlap",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. Cualquier golpe puede ser crítico o activar una habilidad de contacto.",
		},
		{
			NameKey = "Comet Punch",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. Cualquier golpe puede ser crítico o activar una habilidad de contacto.",
		},
		{
			NameKey = "Mega Punch",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Pay Day",
			Description = "Esparce monedas equivalentes a cinco veces el nivel del usuario cada vez.",
		},
		{
			NameKey = "Fire Punch",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al oponente.",
		},
		{
			NameKey = "Ice Punch",
			Description = "Inflige daño y tiene un 10% de probabilidad de congelar al oponente.",
		},
		{
			NameKey = "ThunderPunch",
			Description = "Inflige daño y tiene un 10% de probabilidad de paralizar al oponente.",
		},
		{
			NameKey = "Scratch",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "ViceGrip",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Guillotine",
			Description = "KO de un golpe. Este movimiento es 1% más preciso por cada nivel por encima del objetivo. Fallará si el objetivo es de nivel superior.",
		},
		{
			NameKey = "Razor Wind",
			Description = "Ataca en el 2º turno después de usarse. A pesar de la descripción del juego, NO tiene alta probabilidad de crítico.",
		},
		{
			NameKey = "Swords Dance",
			Description = "Aumenta el Ataque del usuario en dos etapas.",
		},
		{
			NameKey = "Cut",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Gust",
			Description = "Inflige el doble de daño si el oponente está usando Vuelo o Rebote.",
		},
		{
			NameKey = "Wing Attack",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Whirlwind",
			Description = "Fuerza al objetivo a cambiar por otro Pokémon aleatorio. Fallará contra Ventosas o Arraigo.",
		},
		{
			NameKey = "Fly",
			Description = "Ataca en el 2º turno. Todavía puede ser golpeado por Tornado, Gancho Alto, Trueno, Ciclón y Remolino.",
		},
		{
			NameKey = "Bind",
			Description = "Inflige daño y causa 1/16 de los PS máximos del objetivo como daño durante 2-5 turnos. Impide que el objetivo cambie o huya.",
		},
		{
			NameKey = "Slam",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Vine Whip",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Stomp",
			Description = "Inflige daño con un 30% de probabilidad de hacer que el objetivo retroceda. El daño se duplica contra un objetivo que usó Reducción.",
		},
		{
		 NameKey = "Double Kick",
		 Description = "Inflige daño dos veces, cada golpe puede ser crítico.",
		},
		{
			NameKey = "Mega Kick",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Jump Kick",
			Description = "Si el movimiento falla, el usuario recibe daño equivalente a 1/2 del daño que habría causado.",
		},
		{
			NameKey = "Rolling Kick",
			Description = "Inflige daño y tiene un 30% de probabilidad de hacer que el objetivo retroceda.",
		},
		{
			NameKey = "Sand-Attack",
			Description = "Reduce la precisión del objetivo en una etapa. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Headbutt",
			Description = "Inflige daño y tiene un 30% de probabilidad de hacer que el objetivo retroceda.",
		},
		{
			NameKey = "Horn Attack",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Fury Attack",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico o activar una habilidad de contacto.",
		},
		{
			NameKey = "Horn Drill",
			Description = "KO de un golpe. Este movimiento es 1% más preciso por cada nivel por encima del objetivo. Fallará si el objetivo es de nivel superior.",
		},
		{
			NameKey = "Tackle",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Body Slam",
			Description = "Inflige daño y tiene un 30% de probabilidad de paralizar al objetivo.",
		},
		{
			NameKey = "Wrap",
			Description = "Inflige daño y causa 1/16 de los PS máximos del objetivo como daño durante 2-5 turnos. Impide que el objetivo cambie o huya.",
		},
		{
			NameKey = "Take Down",
			Description = "El usuario recibe daño por retroceso igual a 1/4 del daño infligido.",
		},
		{
			NameKey = "Thrash",
			Description = "Inflige daño durante 2-3 turnos consecutivos. El usuario queda confundido después.",
		},
		{
			NameKey = "Double-Edge",
			Description = "El usuario recibe daño por retroceso igual a 1/3 del daño infligido.",
		},
		{
			NameKey = "Tail Whip",
			Description = "Reduce la Defensa de todos los oponentes adyacentes en una etapa.",
		},
		{
			NameKey = "Poison Sting",
			Description = "Inflige daño y tiene un 30% de probabilidad de envenenar al objetivo.",
		},
		{
			NameKey = "Twineedle",
			Description = "Inflige daño dos veces, cada golpe puede ser crítico. El golpe final tiene un 20% de probabilidad de envenenar al objetivo.",
		},
		{
			NameKey = "Pin Missile",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Leer",
			Description = "Reduce la Defensa de todos los oponentes adyacentes en una etapa.",
		},
		{
			NameKey = "Bite",
			Description = "Inflige daño y tiene un 30% de probabilidad de hacer que el objetivo retroceda.",
		},
		{
			NameKey = "Growl",
			Description = "Reduce el Ataque de todos los oponentes adyacentes en una etapa.",
		},
		{
			NameKey = "Roar",
			Description = "Fuerza al objetivo a cambiar por otro Pokémon aleatorio. Fallará contra Insonorizar, Ventosas o Arraigo.",
		},
		{
			NameKey = "Sing",
			Description = "Pone al objetivo a dormir, dura de 2 a 5 turnos. Falla contra Insomnio, Espíritu Vital o Insonorizar.",
		},
		{
			NameKey = "Supersonic",
			Description = "Causa confusión al objetivo. Falla contra Insonorizar o Ritmo Propio.",
		},
		{
			NameKey = "SonicBoom",
			Description = "Siempre inflige exactamente 20 puntos de daño si acierta.",
		},
		{
			NameKey = "Disable",
			Description = "Desactiva el último movimiento usado por el objetivo durante 2-5 turnos.",
		},
		{
			NameKey = "Acid",
			Description = "Inflige daño y tiene un 10% de probabilidad de bajar la estadística de Defensa del objetivo en un nivel.",
		},
		{
			NameKey = "Ember",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al objetivo.",
		},
		{
			NameKey = "Flamethrower",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al objetivo.",
		},
		{
			NameKey = "Mist",
			Description = "Durante cinco turnos, los Pokémon enemigos no pueden bajar las estadísticas de los Pokémon de tu equipo.",
		},
		{
			NameKey = "Water Gun",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Hydro Pump",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Surf",
			Description = "Inflige el doble de daño si el oponente está usando Buceo.",
		},
		{
			NameKey = "Ice Beam",
			Description = "Inflige daño y tiene un 10% de probabilidad de congelar al objetivo.",
		},
		{
			NameKey = "Blizzard",
			Description = "Inflige daño y tiene un 10% de probabilidad de congelar al objetivo.",
		},
		{
			NameKey = "Psybeam",
			Description = "Inflige daño y tiene un 10% de probabilidad de confundir al objetivo.",
		},
		{
			NameKey = "BubbleBeam",
			Description = "Inflige daño y tiene un 10% de probabilidad de bajar la estadística de Velocidad del objetivo en un nivel.",
		},
		{
			NameKey = "Aurora Beam",
			Description = "Inflige daño y tiene un 10% de probabilidad de bajar la estadística de Ataque del objetivo en un nivel.",
		},
		{
			NameKey = "Hyper Beam",
			Description = "Inflige daño y luego obliga al usuario a recargar durante el siguiente turno.",
		},
		{
			NameKey = "Peck",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Drill Peck",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Submission",
			Description = "Inflige daño, y el usuario recibe daño de retroceso igual al 25% del daño infligido.",
		},
		{
			NameKey = "Low Kick",
			Description = "Inflige entre 20-120 de daño dependiendo del peso del objetivo.",
		},
		{
			NameKey = "Counter",
			Description = "Si es golpeado por un movimiento de categoría Física, inflige el doble del daño recibido de vuelta al usuario.",
		},
		{
			NameKey = "Seismic Toss",
			Description = "Inflige daño exacto igual al nivel del usuario.",
		},
		{
			NameKey = "Strength",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Absorb",
			Description = "El 50% del daño infligido es restaurado al usuario como PS.",
		},
		{
			NameKey = "Mega Drain",
			Description = "El 50% del daño infligido es restaurado al usuario como PS.",
		},
		{
			NameKey = "Leech Seed",
			Description = "Drena 1/8 de los PS del objetivo al final de cada turno.",
		},
		{
			NameKey = "Growth",
			Description = "Aumenta el Ataque Especial del usuario en una etapa.",
		},
		{
			NameKey = "Razor Leaf",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "SolarBeam",
			Description = "Ataca en el 2º turno después de usarse, o inmediatamente en clima soleado. Daño reducido en lluvia o tormenta de arena.",
		},
		{
			NameKey = "PoisonPowder",
			Description = "Envenena al objetivo, perdiendo 1/8 de su PS máximos al final de cada turno.",
		},
		{
			NameKey = "Stun Spore",
			Description = "Paraliza al objetivo, reduciendo su Velocidad en un 75%, y un 25% de probabilidad de que falle en actuar.",
		},
		{
			NameKey = "Sleep Powder",
			Description = "Pone al objetivo a dormir, dura de 2 a 5 turnos. Falla contra Insomnio o Espíritu Vital.",
		},
		{
			NameKey = "Petal Dance",
			Description = "Inflige daño durante 2-3 turnos consecutivos. El usuario queda confundido después.",
		},
		{
			NameKey = "String Shot",
			Description = "Reduce la Velocidad del objetivo en un nivel.",
		},
		{
			NameKey = "Dragon Rage",
			Description = "Siempre inflige exactamente 40 puntos de daño si acierta.",
		},
		{
			NameKey = "Fire Spin",
			Description = "Inflige daño y causa 1/16 de los PS máximos del objetivo como daño durante 2-5 turnos. Impide que el objetivo cambie o huya.",
		},
		{
			NameKey = "ThunderShock",
			Description = "Inflige daño y tiene un 10% de probabilidad de paralizar al objetivo.",
		},
		{
			NameKey = "Thunderbolt",
			Description = "Inflige daño y tiene un 10% de probabilidad de paralizar al objetivo.",
		},
		{
			NameKey = "Thunder Wave",
			Description = "Paraliza al objetivo, reduciendo su Velocidad en un 75%, y un 25% de probabilidad de que falle al atacar.",
		},
		{
			NameKey = "Thunder",
			Description = "30% de probabilidad de paralizar. Puede golpear a Pokémon en Vuelo y Bote. Siempre acierta durante la lluvia. La precisión es 50 cuando hace sol.",
		},
		{
			NameKey = "Rock Throw",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Earthquake",
			Description = "Inflige el doble de daño si el oponente está usando Excavar.",
		},
		{
			NameKey = "Fissure",
			Description = "KO de un golpe. Este movimiento es 1% más preciso por cada nivel por encima del objetivo. Fallará si el objetivo es de nivel superior. Puede golpear al Pokémon si usa Excavar.",
		},
		{
			NameKey = "Dig",
			Description = "Ataca en el 2º turno. Todavía puede ser golpeado por Terremoto, Fisura y Magnitud. Puede usarse fuera de combate.",
		},
		{
			NameKey = "Toxic",
			Description = "Envenena al objetivo, perdiendo cantidades cada vez mayores de sus PS máximos al final de cada turno.",
		},
		{
			NameKey = "Confusion",
			Description = "Inflige daño y tiene un 10% de probabilidad de confundir al objetivo.",
		},
		{
			NameKey = "Psychic",
			Description = "Inflige daño y tiene un 10% de probabilidad de bajar la estadística de Defensa Especial del objetivo en un nivel.",
		},
		{
			NameKey = "Hypnosis",
			Description = "Pone al objetivo a dormir, dura de 2 a 5 turnos. Falla contra Insomnio o Espíritu Vital.",
		},
		{
			NameKey = "Meditate",
			Description = "Aumenta el Ataque del usuario en un nivel.",
		},
		{
			NameKey = "Agility",
			Description = "Aumenta la Velocidad del usuario en dos niveles.",
		},
		{
			NameKey = "Quick Attack",
			Description = "Este movimiento tiene prioridad aumentada, haciendo que el usuario ataque antes que la mayoría de los movimientos.",
		},
		{
			NameKey = "Rage",
			Description = "Cuando se usa de forma consecutiva, la estadística de Ataque aumenta en un nivel cuando recibe daño por un ataque.",
		},
		{
			NameKey = "Teleport",
			Description = "Huye de batallas salvajes únicamente. Fallará si está atrapado por Bloqueo, Mal de Ojo, Telaraña o Arraigo. Puede usarse fuera de combate.",
		},
		{
			NameKey = "Night Shade",
			Description = "Inflige daño exacto igual al nivel del usuario.",
		},
		{
			NameKey = "Mimic",
			Description = "Copia el último movimiento usado por el objetivo. Fallará contra Esquema, Transformación, Metrónomo o un movimiento ya aprendido.",
		},
		{
			NameKey = "Screech",
			Description = "Reduce la estadística de Defensa del objetivo en dos niveles. Falla contra la habilidad Insonorizar.",
		},
		{
			NameKey = "Double Team",
			Description = "Aumenta la evasión del usuario en un nivel.",
		},
		{
			NameKey = "Recover",
			Description = "Restaura hasta el 50% de los PS máximos del usuario.",
		},
		{
			NameKey = "Harden",
			Description = "Aumenta la estadística de Defensa del usuario en un nivel.",
		},
		{
			NameKey = "Minimize",
			Description = "Aumenta la Evasión en un nivel. El usuario recibirá el doble de daño de Pisotón, Impresionar, Paranormal y Brazo Pincho.",
		},
		{
			NameKey = "SmokeScreen",
			Description = "Reduce la Precisión del objetivo en una etapa. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Confuse Ray",
			Description = "Causa confusión al objetivo durante 2-5 turnos. 50% de probabilidad de hacerse daño a sí mismo como un movimiento físico de 40 de potencia.",
		},
		{
			NameKey = "Withdraw",
			Description = "Aumenta la Defensa del usuario en un nivel.",
		},
		{
			NameKey = "Defense Curl",
			Description = "Aumenta la Defensa del usuario en un nivel. También duplica el poder de los movimientos Desenrollar y Bola Hielo del usuario.",
		},
		{
			NameKey = "Barrier",
			Description = "Aumenta la Defensa del usuario en dos niveles.",
		},
		{
			NameKey = "Light Screen",
			Description = "Durante 5 turnos, reduce a la mitad el daño infligido al equipo del usuario por movimientos Especiales.",
		},
		{
			NameKey = "Haze",
			Description = "Restablece las etapas de estadísticas de todos los Pokémon activos en el campo a 0.",
		},
		{
			NameKey = "Reflect",
			Description = "Durante 5 turnos, reduce a la mitad el daño infligido al equipo del usuario por movimientos Físicos.",
		},
		{
			NameKey = "Focus Energy",
			Description = "Aumenta la tasa de golpe crítico del usuario en dos niveles. (+2 etapas = 1/4 o 25%)",
		},
		{
			NameKey = "Bide",
			Description = "Aguanta ataques durante dos turnos consecutivos. Inflige daño igual al doble del daño recibido.",
		},
		{
			NameKey = "Metronome",
			Description = "Selecciona aleatoriamente un movimiento para usar, y un objetivo aleatorio si es necesario.",
		},
		{
			NameKey = "Mirror Move",
			Description = "Usa el último movimiento dirigido al usuario por un Pokémon aún en el campo.",
		},
		{
			NameKey = "Selfdestruct",
			Description = "La Defensa del objetivo se reduce a la mitad, duplicando efectivamente el poder de este movimiento.",
		},
		{
			NameKey = "Egg Bomb",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Lick",
			Description = "Inflige daño y tiene un 30% de probabilidad de paralizar al objetivo.",
		},
		{
			NameKey = "Smog",
			Description = "Inflige daño y tiene un 40% de probabilidad de envenenar al objetivo.",
		},
		{
			NameKey = "Sludge",
			Description = "Inflige daño y tiene un 30% de probabilidad de envenenar al objetivo.",
		},
		{
			NameKey = "Bone Club",
			Description = "Inflige daño y tiene un 10% de probabilidad de hacer que el objetivo retroceda.",
		},
		{
			NameKey = "Fire Blast",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al objetivo.",
		},
		{
			NameKey = "Waterfall",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Clamp",
			Description = "Inflige daño y causa 1/16 de los PS máximos del objetivo como daño durante 2-5 turnos. Impide que el objetivo cambie o huya.",
		},
		{
			NameKey = "Swift",
			Description = "Inflige daño y siempre acierta, a menos que el objetivo esté en el turno semi-invulnerable de un movimiento como Excavar o Vuelo.",
		},
		{
			NameKey = "Skull Bash",
			Description = "Aumenta la Defensa del usuario en un nivel. En el siguiente turno, inflige daño.",
		},
		{
			NameKey = "Spike Cannon",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Constrict",
			Description = "Inflige daño y tiene un 10% de probabilidad de bajar la Velocidad del objetivo en un nivel.",
		},
		{
			NameKey = "Amnesia",
			Description = "Aumenta la Defensa Especial del usuario en dos niveles.",
		},
		{
			NameKey = "Kinesis",
			Description = "Reduce la estadística de Precisión del objetivo en un nivel. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Softboiled",
			Description = "Restaura hasta 50% de los PS máximos del usuario. Puede usarse fuera de combate para transferir 20% de PS máximos a otro Pokémon.",
		},
		{
			NameKey = "Hi Jump Kick",
			Description = "Si el movimiento falla, el usuario recibe daño equivalente a 1/2 del daño que habría causado.",
		},
		{
			NameKey = "Glare",
			Description = "Paraliza al objetivo, reduciendo su Velocidad en un 75%, y un 25% de probabilidad de que falle en actuar. Falla contra tipo Fantasma.",
		},
		{
			NameKey = "Dream Eater",
			Description = "Falla si el objetivo no está dormido. El 50% del daño infligido es restaurado al usuario como PS.",
		},
		{
			NameKey = "Poison Gas",
			Description = "Envenena al objetivo, perdiendo 1/8 de su PS máximos al final de cada turno.",
		},
		{
			NameKey = "Barrage",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Leech Life",
			Description = "El 50% del daño infligido es restaurado al usuario como PS.",
		},
		{
			NameKey = "Lovely Kiss",
			Description = "Pone al objetivo a dormir, dura de 2 a 5 turnos. Falla contra Insomnio o Espíritu Vital.",
		},
		{
			NameKey = "Sky Attack",
			Description = "Ataca en el 2º turno, 30% de probabilidad de hacer retroceder al objetivo. Tiene tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%).",
		},
		{
			NameKey = "Transform",
			Description = "Se convierte en el objetivo copiando todo sobre él (incluso cambios de estadísticas), excepto los PS actuales y máximos. El PP de cada mov. se convertirá en 5.",
		},
		{
			NameKey = "Bubble",
			Description = "Inflige daño y tiene un 10% de probabilidad de bajar la estadística de Velocidad del objetivo en un nivel.",
		},
		{
			NameKey = "Dizzy Punch",
			Description = "Inflige daño y tiene un 20% de probabilidad de confundir al objetivo.",
		},
		{
			NameKey = "Spore",
			Description = "Pone al objetivo a dormir, dura de 2-5 turnos. Falla contra Insomnio o Espíritu Vital.",
		},
		{
			NameKey = "Flash",
			Description = "Reduce la Precisión del objetivo en una etapa. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Psywave",
			Description = "Inflige una cantidad aleatoria de daño, variando entre 50% y 150% del nivel del usuario. Mínimo de 1 de daño.",
		},
		{
			NameKey = "Splash",
			Description = "No inflige daño y no tiene efecto alguno.",
		},
		{
			NameKey = "Acid Armor",
			Description = "Aumenta la Defensa del usuario en dos niveles.",
		},
		{
			NameKey = "Crabhammer",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Explosion",
			Description = "La Defensa del objetivo se reduce a la mitad, duplicando efectivamente el poder de este movimiento.",
		},
		{
			NameKey = "Fury Swipes",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. Cualquier golpe puede ser crítico o activar una habilidad de contacto.",
		},
		{
			NameKey = "Bonemerang",
			Description = "Inflige daño dos veces, cada golpe puede ser crítico.",
		},
		{
			NameKey = "Rest",
			Description = "Restaura PS por completo mientras duerme durante 2 turnos. Falla si el usuario tiene Insomnio o Espíritu Vital.",
		},
		{
			NameKey = "Rock Slide",
			Description = "Inflige daño y tiene un 30% de probabilidad de hacer que cada objetivo retroceda.",
		},
		{
			NameKey = "Hyper Fang",
			Description = "Inflige daño y tiene un 10% de probabilidad de hacer que el objetivo retroceda.",
		},
		{
			NameKey = "Sharpen",
			Description = "Aumenta la estadística de Ataque del usuario en un nivel.",
		},
		{
			NameKey = "Conversion",
			Description = "Cambia el tipo del usuario para que coincida con el tipo de uno de los movimientos del usuario (incluyendo Conversion en sí mismo).",
		},
		{
			NameKey = "Tri Attack",
			Description = "Inflige daño y tiene un 20% de probabilidad de paralizar, congelar o quemar al objetivo.",
		},
		{
			NameKey = "Super Fang",
			Description = "Inflige daño exacto igual al 50% de los PS actuales del objetivo, mínimo de 1.",
		},
		{
			NameKey = "Slash",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%).",
		},
		{
			NameKey = "Substitute",
			Description = "El usuario pierde el 25% de sus PS máximos para esconderse detrás de un sustituto, que evita los efectos de la mayoría de los ataques.",
		},
		{
			NameKey = "Struggle",
			Description = "Golpea como daño neutral, incluso a través de Superguarda. El usuario recibe daño por retroceso igual a 1/4 del daño infligido.",
		},
		{
			NameKey = "Sketch",
			Description = "El usuario aprende permanentemente el último mov. del objetivo, reemplazando a Esquema en el proceso. Fallará contra algunos mov., o si el usuario ya conoce el mov.",
		},
		{
			NameKey = "Triple Kick",
			Description = "Inflige daño tres veces, cada golpe adicional gana 10 de potencia. Cada golpe tiene una verificación de Precisión separada y puede ser crítico.",
		},
		{
			NameKey = "Thief",
			Description = "Roba el objeto que lleva el objetivo, si tiene uno. No se puede robar un objeto si el usuario ya tiene uno, o el objetivo tiene Viscosidad.",
		},
		{
			NameKey = "Spider Web",
			Description = "Impide que el objetivo cambie o huya. Un Pokémon aún puede huir si tiene Fuga o tiene equipada una Bola Humo.",
		},
		{
			NameKey = "Mind Reader",
			Description = "Permite que el próximo movimiento usado por el usuario nunca falle, incluso contra Bote, Excavar, Buceo y Vuelo.",
		},
		{
			NameKey = "Nightmare",
			Description = "Causa que un objetivo dormido pierda 1/4 de sus PS máximos al final de cada turno que permanezca dormido.",
		},
		{
			NameKey = "Flame Wheel",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al objetivo. Este movimiento primero descongela a su usuario si está congelado.",
		},
		{
			NameKey = "Snore",
			Description = "Si el usuario está dormido, inflige daño y tiene un 30% de probabilidad de hacer que el objetivo retroceda. Sin efecto contra Insonorizar.",
		},
		{
			NameKey = "Curse",
			Description = "- Vel. pero + el Atk. y + Def. Si el usuario es tipo Fantasma, pierde la mitad de sus PS máx. para maldecir al objetivo, y hace que pierda 1/4 de sus PS máx. al final de cada turno.",
		},
		{
			NameKey = "Flail",
			Description = "Inflige más daño cuanto menos PS tenga el usuario. Puntos de referencia importantes: 80 de potencia al 35% de PS o menos, y 150 de potencia al 10% de PS o menos.",
		},
		{
			NameKey = "Conversion 2",
			Description = "Cambia aleatoriamente el tipo del usuario a un nuevo tipo que resista o sea inmune al tipo del último movimiento dañino que recibió.",
		},
		{
			NameKey = "Aeroblast",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Cotton Spore",
			Description = "Reduce la estadística de Velocidad del objetivo en dos niveles.",
		},
		{
			NameKey = "Reversal",
			Description = "Inflige más daño cuanto menos PS tenga el usuario. Puntos de referencia importantes: 80 de potencia al 35% de PS o menos, y 150 de potencia al 10% de PS o menos.",
		},
		{
			NameKey = "Spite",
			Description = "Reduce los PP del último movimiento usado por el objetivo en 2-5 PP, elegidos al azar. Rencor falla si ese movimiento tiene exactamente 1 PP restante.",
		},
		{
			NameKey = "Powder Snow",
			Description = "Inflige daño y tiene un 10% de probabilidad de congelar al objetivo.",
		},
		{
			NameKey = "Protect",
			Description = "Protege al usuario de todos los efectos de mov. en el turno, incluido el daño. Usar este mov. consecutiv. reduce su tasa de éxito a la mitad cada vez.",
		},
		{
			NameKey = "Mach Punch",
			Description = "Este movimiento tiene prioridad aumentada, haciendo que el usuario ataque antes que la mayoría de los movimientos.",
		},
		{
			NameKey = "Scary Face",
			Description = "Reduce la estadística de Velocidad del objetivo en dos niveles.",
		},
		{
			NameKey = "Faint Attack",
			Description = "Inflige daño y omite las comprobaciones de Precisión para acertar siempre, a menos que el objetivo esté en el turno semi-invulnerable de un mov. como Excavar or Vuelo.",
		},
		{
			NameKey = "Sweet Kiss",
			Description = "Causa confusión al objetivo durante 2-5 turnos. 50% de probabilidad de dañarse a sí mismo como un movimiento físico de 40 de potencia.",
		},
		{
			NameKey = "Belly Drum",
			Description = "El usuario pierde la mitad de sus PS máximos, y a cambio aumenta su estadística de Ataque hasta +6 etapas.",
		},
		{
			NameKey = "Sludge Bomb",
			Description = "Inflige daño y tiene un 30% de probabilidad de envenenar al objetivo.",
		},
		{
			NameKey = "Mud-Slap",
			Description = "Inflige daño y baja la precisión del objetivo en un nivel.",
		},
		{
			NameKey = "Octazooka",
			Description = "Inflige daño y tiene un 50% de probabilidad de bajar la precisión del objetivo en un nivel.",
		},
		{
			NameKey = "Spikes",
			Description = "Crea un peligro para el equipo enemigo (puede acumularse 3 veces). Cambiar inflige 1/8, 1/6 o 1/4 de PS máximos en daño a un enemigo sin Vuelo o Levitación.",
		},
		{
			NameKey = "Zap Cannon",
			Description = "Inflige daño y paraliza al objetivo cada vez que acierta.",
		},
		{
			NameKey = "Foresight",
			Description = "Neutraliza las comprobaciones de precisión contra el objetivo, y permite que los movimientos Lucha y Normal lo golpeen si son tipo Fantasma.",
		},
		{
			NameKey = "Destiny Bond",
			Description = "Si el usuario es derrotado como resultado de un ataque directo por un enemigo, ese Pokémon también es derrotado. El efecto termina cuando el usuario usa otro movimiento.",
		},
		{
			NameKey = "Perish Song",
			Description = "Todos los Pokémon son derrotados después de 3 turnos. Cambiar o tener Insonorizar elimina este efecto.",
		},
		{
			NameKey = "Icy Wind",
			Description = "Inflige daño a todos los oponentes adyacentes y baja la Velocidad de cada uno en un nivel.",
		},
		{
			NameKey = "Detect",
			Description = "Protege al usuario de todos los efectos de mov. por el turno, incluido el daño. Usar este mov. consecutiv. reduce su tasa de éxito a la mitad cada vez.",
		},
		{
			NameKey = "Bone Rush",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. Cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Lock-On",
			Description = "Permite que el próximo movimiento usado por el usuario nunca falle, incluso contra Bote, Excavar, Buceo y Vuelo.",
		},
		{
			NameKey = "Outrage",
			Description = "Inflige daño durante 2-3 turnos consecutivos. El usuario queda confuso después.",
		},
		{
			NameKey = "Sandstorm",
			Description = "Cambia el clima a Tormenta de Arena durante 5 turnos. Los Pokémon reciben 1/16 de sus PS máximos como daño, excepto los tipos Acero, Tierra y Roca.",
		},
		{
			NameKey = "Giga Drain",
			Description = "El 50% del daño infligido es restaurado al usuario como PS.",
		},
		{
			NameKey = "Endure",
			Description = "Permite al usuario sobrevivir a cualquier ataque único que lo debilitara, dejándolo con 1 PS en su lugar.",
		},
		{
			NameKey = "Charm",
			Description = "Reduce la estadística de Ataque del objetivo en dos niveles.",
		},
		{
			NameKey = "Rollout",
			Description = "Inflige daño durante 5 turnos, duplicándose en potencia con cada golpe consecutivo. El poder base se duplica si el usuario había usado previamente Def. Férrea.",
		},
		{
			NameKey = "False Swipe",
			Description = "Inflige daño, pero siempre dejará al objetivo con 1 PS si de otro modo lo debilitara.",
		},
		{
			NameKey = "Swagger",
			Description = "Aumenta la estadística de Ataque del objetivo en dos niveles y lo confunde.",
		},
		{
			NameKey = "Milk Drink",
			Description = "Restaura hasta 50% de los PS máximos del usuario. Puede usarse fuera de combate para transferir 20% de PS máximos a otro Pokémon.",
		},
		{
			NameKey = "Spark",
			Description = "Inflige daño y tiene un 30% de probabilidad de paralizar al objetivo.",
		},
		{
			NameKey = "Fury Cutter",
			Description = "Cada vez que este movimiento golpea con éxito, su poder se duplica, hasta un máximo de 160. De lo contrario, se restablece a la potencia base.",
		},
		{
			NameKey = "Steel Wing",
			Description = "Inflige daño y tiene un 10% de probabilidad de aumentar la Defensa del usuario en un nivel.",
		},
		{
			NameKey = "Mean Look",
			Description = "Impide que el objetivo cambie o huya. Un Pokémon aún puede huir si tiene Fuga o tiene equipada una Smoke Ball.",
		},
		{
			NameKey = "Attract",
			Description = "Si el usuario y el objetivo son de géneros opuestos, el objetivo se enamorará, incapaz de usar movimientos el 50% del tiempo.",
		},
		{
			NameKey = "Sleep Talk",
			Description = "Si el usuario está durmiendo, elige aleatoriamente otro de los movimientos del usuario para usar.",
		},
		{
			NameKey = "Heal Bell",
			Description = "Cura a todos los Pokémon en el equipo del usuario de todas las condiciones de estado mayores. Falla contra Pokémon con Insonorizar.",
		},
		{
			NameKey = "Return",
			Description = "El poder varía entre 1 y 102, siendo más fuerte con una amistad de 255. Si la Amistad del usuario es 127 o menos, Frustración es más fuerte.",
		},
		{
			NameKey = "Present",
			Description = "40% de probabilidad de que el poder sea 40, 30% de que sea 80, 10% de que sea 120, y 20% de curar al objetivo en 1/4 de sus PS máximos.",
		},
		{
			NameKey = "Frustration",
			Description = "El poder varía entre 1 y 102, siendo más fuerte con una amistad de 0. Si la amistad del usuario es 128 o mayor, Retroceso es más fuerte.",
		},
		{
			NameKey = "Safeguard",
			Description = "Durante 5 turnos, protege al equipo del usuario de la mayoría de los efectos de estado y Confusión.",
		},
		{
			NameKey = "Pain Split",
			Description = "Iguala los PS del usuario y el objetivo sumando los PS actuales de ambos Pokémon y luego dividiendo entre dos, repartidos uniformemente entre ellos.",
		},
		{
			NameKey = "Sacred Fire",
			Description = "Inflige daño y tiene un 50% de probabilidad de quemar al objetivo. Este movimiento primero descongela a su usuario si está congelado.",
		},
		{
			NameKey = "Magnitude",
			Description = "El poder varía entre valor aleatorio y la probabilidad. Entre poder 4 y 10, cada valor extra añade 20 de pot.; 150 de pot. en el valor 10. Golpea a Pokémon usando Excavar.",
		},
		{
			NameKey = "DynamicPunch",
			Description = "Inflige daño y siempre confunde al objetivo, durando de 2 a 5 turnos.",
		},
		{
			NameKey = "Megahorn",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "DragonBreath",
			Description = "Inflige daño y tiene un 30% de probabilidad de paralizar al objetivo.",
		},
		{
			NameKey = "Baton Pass",
			Description = "Cambia al usuario, pasando todos los cambios temporales de etapa de estadística así como muchos otros efectos y condiciones, al Pokémon que lo reemplaza en la batalla.",
		},
		{
			NameKey = "Encore",
			Description = "Impide que el objetivo use cualquier movimiento excepto el último movimiento que usó, dura de 2 a 6 turnos.",
		},
		{
			NameKey = "Pursuit",
			Description = "Si el Pokémon objetivo intenta cambiar, el poder de Persecución se duplica y lo golpea primero.",
		},
		{
			NameKey = "Rapid Spin",
			Description = "Inflige daño y elimina los efectos de cualquier movimiento de atadura, Drenadoras y cualquier peligro de entrada como Púas del campo del usuario.",
		},
		{
			NameKey = "Sweet Scent",
			Description = "Reduce la evasión de todos los oponentes adyacentes en un nivel. Puede usarse fuera de la batalla para atraer a un Pokémon salvaje.",
		},
		{
			NameKey = "Iron Tail",
			Description = "Inflige daño y tiene un 30% de probabilidad de bajar la estadística de Defensa del objetivo en un nivel.",
		},
		{
			NameKey = "Metal Claw",
			Description = "Inflige daño y tiene un 10% de probabilidad de aumentar la estadística de Ataque del usuario en un nivel.",
		},
		{
			NameKey = "Vital Throw",
			Description = "Este movimiento tiene prioridad disminuida, haciendo que el usuario ataque después de la mayoría de los movimientos.",
		},
		{
			NameKey = "Morning Sun",
			Description = "Restaura los PS del usuario en un porcentaje basado en el clima: 1/2 en clima despejado, 2/3 si está soleado, y 1/4 durante cualquier otra condición climática.",
		},
		{
			NameKey = "Synthesis",
			Description = "Restaura los PS del usuario en un porcentaje basado en el clima: 1/2 en clima despejado, 2/3 si está soleado, y 1/4 durante cualquier otra condición climática.",
		},
		{
			NameKey = "Moonlight",
			Description = "Restaura los PS del usuario en un porcentaje basado en el clima: 1/2 en clima despejado, 2/3 si está soleado, y 1/4 durante cualquier otra condición climática.",
		},
		{
			NameKey = "Hidden Power",
			Description = "El poder y tipo varían con los IVs, el poder varía de 30 a 70. Contador siempre funcionará contra este movimiento, pero nunca Manto Espejo.",
		},
		{
			NameKey = "Cross Chop",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Twister",
			Description = "Inflige daño y tiene un 20% de probabilidad de hacer que cada objetivo retroceda. Golpea a Pokémon usando Vuelo o Rebote con el doble de daño.",
		},
		{
			NameKey = "Rain Dance",
			Description = "Cambia el clima a Lluvia durante 5 turnos. Los mov. de Agua reciben un aumento del 50% y los mov. de Fuego se debilitan en un 50%. Trueno ignora precisión y evasión.",
		},
		{
			NameKey = "Sunny Day",
			Description = "Cambia el clima a Soleado durante 5 turnos. Los mov. de Fuego reciben un aumento del 50% y los mov. de Agua se debilitan en un 50%. Trueno pasa a 50% de precisión.",
		},
		{
			NameKey = "Crunch",
			Description = "Inflige daño y tiene un 20% de probabilidad de bajar la estadística de Defensa Especial del objetivo en un nivel.",
		},
		{
			NameKey = "Mirror Coat",
			Description = "Si es golpeado por un movimiento de categoría Especial, inflige el doble del daño recibido de vuelta al usuario.",
		},
		{
			NameKey = "Psych Up",
			Description = "Restablece los cambios de estadísticas del usuario y copia todas las etapas de estadísticas del objetivo al usuario: ATQ, DEF, ASP, DSP, VEL, PRE, EVA.",
		},
		{
			NameKey = "ExtremeSpeed",
			Description = "Este movimiento tiene prioridad aumentada, haciendo que el usuario ataque antes que la mayoría de los movimientos.",
		},
		{
			NameKey = "AncientPower",
			Description = "Inflige daño y tiene un 10% de probabilidad de aumentar en un nivel el ATQ DEF ASP DSP VEL del usuario.",
		},
		{
			NameKey = "Shadow Ball",
			Description = "Inflige daño y tiene un 20% de probabilidad de bajar la estadística de Defensa Especial del objetivo en un nivel.",
		},
		{
			NameKey = "Future Sight",
			Description = "Fija el daño, basado en el ASP del usuario y DSP del objetivo. Después de 2 turnos, inflige daño al enemigo actual. El ataque es sin tipo: no puede STAB, golpea Superguarda.",
		},
		{
			NameKey = "Rock Smash",
			Description = "Inflige daño y tiene un 50% de probabilidad de bajar la estadística de Defensa del objetivo en un nivel.",
		},
		{
			NameKey = "Whirlpool",
			Description = "Inflige daño (duplicado si el oponente usa Buceo) y causa 1/16 de los PS máximos del objetivo como daño durante 2-5 turnos. Impide que el objetivo cambie o huya.",
		},
		{
			NameKey = "Beat Up",
			Description = "Cada Pokémon vivo, sin estado en el equipo del usuario realiza un ataque independiente, cada uno es sin tipo con un poder de 10.",
		},
		{
			NameKey = "Fake Out",
			Description = "Este movimiento tiene prioridad aumentada. Siempre hace retroceder al objetivo, pero el ataque fallará si no es el primer movimiento usado.",
		},
		{
			NameKey = "Uproar",
			Description = "Inflige daño durante 2-5 turnos consecutivos. Despierta a los Pokémon durmiendo y evita que se duerman, excepto aquellos con Insonorizar.",
		},
		{
			NameKey = "Stockpile",
			Description = "Acumula energía, se acumula tres veces. Libera energía usando Spit Up para infligir daño o Swallow para curar PS.",
		},
		{
			NameKey = "Spit Up",
			Description = "Consume energía acumulada por Reserva, 100 de poder por cada acumulamiento (0 si ninguno). Este movimiento no puede causar un golpe crítico.",
		},
		{
			NameKey = "Swallow",
			Description = "Consume energía acumulada por Reserva, curando al usuario un 25%, 50% o 100% de PS según el número de acumulamientos consumidos (0% si ninguno).",
		},
		{
			NameKey = "Heat Wave",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al objetivo.",
		},
		{
			NameKey = "Hail",
			Description = "Cambia el clima a Granizo durante 5 turnos. Los Pokémon reciben 1/16 de sus PS máximos como daño, excepto los tipos Hielo.",
		},
		{
			NameKey = "Torment",
			Description = "Impide que el objetivo elija usar el mismo movimiento dos veces seguidas. El efecto termina cuando el Pokémon cambia.",
		},
		{
			NameKey = "Flatter",
			Description = "Aumenta la estadística de Ataque Especial del objetivo en un nivel y lo confunde.",
		},
		{
			NameKey = "Will-O-Wisp",
			Description = "Inflige una quemadura al objetivo, ineficaz contra tipo Fuego. Los Pokémon quemados hacen la mitad de daño con mov. Físicos y pierden 1/8 de sus PS máximos cada turno.",
		},
		{
			NameKey = "Memento",
			Description = "El usuario se debilita para bajar la estadística de Ataque y Ataque Especial del objetivo en dos niveles cada uno.",
		},
		{
			NameKey = "Facade",
			Description = "El poder se duplica si el usuario está envenenado, paralizado o quemado. El efecto de quemadura de reducir a la mitad el daño infligido aún se aplica.",
		},
		{
			NameKey = "Focus Punch",
			Description = "Este movimiento tiene prioridad reducida. Fallará si el usuario recibe daño directo antes de usarlo.",
		},
		{
			NameKey = "SmellingSalt",
			Description = "El poder se duplica contra un objetivo paralizado, pero también curará al objetivo de la parálisis.",
		},
		{
			NameKey = "Follow Me",
			Description = "Este movimiento tiene prioridad aumentada. El usuario redirige todos los movimientos dirigidos de Pokémon enemigos hacia sí mismo.",
		},
		{
			NameKey = "Nature Power",
			Description = "Arena: Terrem. Edificio: Rapidez. Cueva: Bola Sombra. Roca: Avalancha. Hierba alta: Paralizador. Hierba larga: Hoja Afil. Estanque: Rayo Burb. Mar: Surf. Bajo el agua: Hidrobomba.",
		},
		{
			NameKey = "Charge",
			Description = "El usuario acumula energía, potenciando el siguiente movimiento que use. Si ese siguiente movimiento es Eléctrico, el daño infligido se duplicará.",
		},
		{
			NameKey = "Taunt",
			Description = "Impide que el Pokémon objetivo use movimientos de categoría Estado; movimientos que no son Físicos o Especiales. Ignora Sustituto. Este efecto dura 2 turnos.",
		},
		{
			NameKey = "Helping Hand",
			Description = "Este es un movimiento de prioridad aumentada. El usuario aumenta el daño infligido por su aliado en un 50% solo para este turno.",
		},
		{
			NameKey = "Trick",
			Description = "Cambia los objetos equipados con el objetivo. Falla si es usado por un Pokémon salvaje, o si ambos Pokémon no tienen objetos, o contra un Sustituto.",
		},
		{
			NameKey = "Role Play",
			Description = "Reemplaza la habilidad del usuario por la del objetivo. Falla si la habilidad es Rastro o Superguarda. Algunas habilidades como Intimidacón no se activan.",
		},
		{
			NameKey = "Wish",
			Description = "Sin efecto en el turno usado. Al final del siguiente turno, el Pokémon en la posición actual del usuario será curado en la mitad de sus PS máximos.",
		},
		{
			NameKey = "Assist",
			Description = "Selecciona aleatoriamente un mov. elegible de todos los demás movimientos conocidos por los Pokémon en el equipo del usuario, incluidos los Pokémon debilitados.",
		},
		{
			NameKey = "Ingrain",
			Description = "Restaura 1/16 de sus PS máximos al final de cada turno. Impide que el usuario cambie, incluso por movimientos como Rugido y Torbellino.",
		},
		{
			NameKey = "Superpower",
			Description = "Inflige daño, luego baja la estadística de Ataque y Defensa del usuario en un nivel cada uno.",
		},
		{
			NameKey = "Magic Coat",
			Description = "Refleja la mayoría de los mov. de categoría Estado de vuelta al enemigo, la mayoría de los mov. ofensivos que no son Físicos o Especiales.",
		},
		{
			NameKey = "Recycle",
			Description = "Recupera un objeto equipado, como una Baya. Falla si el objeto fue perdido a través de Ladrón o Desarme.",
		},
		{
			NameKey = "Revenge",
			Description = "Reemplaza la habilidad del usuario con la del objetivo. Fallará si es Rastro o Superguarda. Intimidación por ejemplo no se activa.",
		},
		{
			NameKey = "Brick Break",
			Description = "Elimina Pantalla Luz y Reflejo del campo del oponente, luego inflige daño. Elimina esos efectos incluso contra Pokémon tipo Fantasma.",
		},
		{
			NameKey = "Yawn",
			Description = "Hace que el objetivo esté somnoliento. Al final del siguiente turno, el Pokémon somnoliento se dormirá.",
		},
		{
			NameKey = "Knock Off",
			Description = "Inutiliza el objeto equipado por el objetivo durante el resto de la batalla, incluso si cambia de Pokémon.",
		},
		{
			NameKey = "Endeavor",
			Description = "Causa que los PS del objetivo sean iguales a los PS actuales del usuario.",
		},
		{
			NameKey = "Eruption",
			Description = "Tiene 150 de potencia con PS máximos, pero su potencia reduce proporcionalmente a los PS restantes del usuario. Fórmula: 150 x currPS / maxPS",
		},
		{
			NameKey = "Skill Swap",
			Description = "Intercambia las habilidades del usuario y del objetivo. Esta información no se muestra al jugador. Falla contra Superguarda.",
		},
		{
			NameKey = "Imprison",
			Description = "Mientras el usuario permanezca en batalla, los oponentes no pueden usar ningún movimiento que también sea conocido por el usuario.",
		},
		{
			NameKey = "Refresh",
			Description = "Cura al usuario de quemaduras, veneno o parálisis. No puede curar sueño si es usado por Sonámbulo.",
		},
		{
			NameKey = "Grudge",
			Description = "Si el usuario es derrotado como resultado de un ataque directo por un enemigo, el último movimiento usado pierde todo su PP. El efecto termina cuando el usuario usa otro movimiento.",
		},
		{
			NameKey = "Snatch",
			Description = "Este es un mov. de prioridad aumentada. Si otro Pokémon intenta usar un mov. de estado beneficioso, el usuario usará ese mov. en su lugar.",
		},
		{
			NameKey = "Secret Power",
			Description = "30% Arena: --PRE. Edificio: parálisis. Cueva: retroceso. Roca: confusión. Hierba alta: envenenamiento. Hierba larga: sueño. Estanque: --DSP. Mar: --ATQ. Bajo el agua: --DEF.",
		},
		{
			NameKey = "Dive",
			Description = "Ataca en el 2º turno. Todavía puede ser golpeado por Surf y Torbellino y recibirá doble daño.",
		},
		{
			NameKey = "Arm Thrust",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico o activar una habilidad de contacto.",
		},
		{
			NameKey = "Camouflage",
			Description = "Cambia el tipo del usuario según el terreno. Edificio: Normal, Arena: Tierra, Cueva/roca: Roca, Hierba corta/larga: Planta, Agua: Agua",
		},
		{
			NameKey = "Tail Glow",
			Description = "Aumenta el Ataque Especial del usuario en dos niveles.",
		},
		{
			NameKey = "Luster Purge",
			Description = "Inflige daño y tiene un 50% de probabilidad de bajar el Defensa Especial del objetivo.",
		},
		{
			NameKey = "Mist Ball",
			Description = "Inflige daño y tiene un 50% de probabilidad de bajar el Ataque Especial del objetivo.",
		},
		{
			NameKey = "FeatherDance",
			Description = "Reduce la estadística de Ataque del objetivo en dos niveles.",
		},
		{
			NameKey = "Teeter Dance",
			Description = "Causa que todos los demás Pokémon se confundan durante 2-5 turnos. 50% de probabilidad de dañarse a sí mismo como un movimiento físico de 40 de potencia.",
		},
		{
			NameKey = "Blaze Kick",
			Description = "Inflige daño y tiene un 10% de probabilidad de quemar al objetivo. También tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Mud Sport",
			Description = "Reduce la potencia de los movimientos Eléctricos en un 50% para todos los Pokémon en la batalla. Este efecto dura hasta que el usuario cambie de lugar.",
		},
		{
			NameKey = "Ice Ball",
			Description = "Inflige daño durante 5 turnos, duplicándose en potencia con cada golpe consecutivo. El poder base se duplica si el usuario había usado previamente Def. Férrea.",
		},
		{
			NameKey = "Needle Arm",
			Description = "Inflige daño y tiene un 30% de probabilidad de hacer que el objetivo retroceda. El daño se duplica contra un objetivo que usó Reducción.",
		},
		{
			NameKey = "Slack Off",
			Description = "Restaura hasta 50% de los PS máximos del usuario.",
		},
		{
			NameKey = "Hyper Voice",
			Description = "Inflige daño a todos los oponentes adyacentes. Los Pokémon con Insonorizar no se ven afectados por este movimiento.",
		},
		{
			NameKey = "Poison Fang",
			Description = "Inflige daño y tiene un 30% de probabilidad de envenenar gravemente al objetivo.",
		},
		{
			NameKey = "Crush Claw",
			Description = "Inflige daño y tiene un 50% de probabilidad de bajar la estadística de Defensa del objetivo en un nivel.",
		},
		{
			NameKey = "Blast Burn",
			Description = "Inflige daño y luego obliga al usuario a recargar durante el siguiente turno.",
		},
		{
			NameKey = "Hydro Cannon",
			Description = "Inflige daño y luego obliga al usuario a recargar durante el siguiente turno.",
		},
		{
			NameKey = "Meteor Mash",
			Description = "Inflige daño y tiene un 20% de probabilidad de aumentar la estadística de Ataque del usuario en un nivel.",
		},
		{
			NameKey = "Astonish",
			Description = "Inflige daño y tiene un 30% de probabilidad de hacer que el objetivo retroceda. El daño se duplica contra un objetivo que usó Reducción.",
		},
		{
			NameKey = "Weather Ball",
			Description = "El poder se duplica en el clima y cambia de tipo: Fuego si está soleado, Agua si está lloviendo, Hielo si hay granizo, Roca si hay tormenta de arena.",
		},
		{
			NameKey = "Aromatherapy",
			Description = "Cura a todos los Pokémon en el equipo del usuario de todas las condiciones de estado mayores.",
		},
		{
			NameKey = "Fake Tears",
			Description = "Reduce la estadística de Defensa Especial del objetivo en dos niveles.",
		},
		{
			NameKey = "Air Cutter",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Overheat",
			Description = "Inflige daño y baja el Ataque Especial del usuario en dos niveles.",
		},
		{
			NameKey = "Odor Sleuth",
			Description = "Neutraliza las verificaciones de precisión contra el objetivo, y permite que los movimientos de tipo Lucha y Normal golpeen a tipo Fantasma.",
		},
		{
			NameKey = "Rock Tomb",
			Description = "Inflige daño y baja la Velocidad del oponente en un nivel.",
		},
		{
			NameKey = "Silver Wind",
			Description = "Inflige daño y tiene un 10% de probabilidad de aumentar en un nivel el Ataque, Defensa, Ataque Especial, Defensa Especial y Velocidad del usuario.",
		},
		{
			NameKey = "Metal Sound",
			Description = "Reduce la estadística de Defensa Especial del objetivo en dos niveles. Falla contra Pokémon con Insonorizar.",
		},
		{
			NameKey = "GrassWhistle",
			Description = "Pone al objetivo a dormir, dura de 2 a 5 turnos. Falla contra Insomnio, Espíritu Vital, o Insonorizar.",
		},
		{
			NameKey = "Tickle",
			Description = "Reduce la estadística de Ataque y Defensa del objetivo en un nivel cada uno. Funciona incluso si el enemigo tiene un Sustituto.",
		},
		{
			NameKey = "Cosmic Power",
			Description = "Aumenta la Defensa y Defensa Especial del usuario en un nivel cada una.",
		},
		{
			NameKey = "Water Spout",
			Description = "Tiene 150 de potencia con PS máximos, pero su potencia reduce proporcionalmente a los PS restantes del usuario. Fórmula: 150 x currPS / maxPS",
		},
		{
			NameKey = "Signal Beam",
			Description = "Inflige daño y tiene un 10% de probabilidad de confundir al objetivo.",
		},
		{
			NameKey = "Shadow Punch",
			Description = "Inflige daño y omite las comprobaciones de Precisión para acertar siempre, a menos que el objetivo esté en el turno semi-invulnerable de un mov. como Excavar or Vuelo.",
		},
		{
			NameKey = "Extrasensory",
			Description = "Inflige daño y tiene un 10% de probabilidad de hacer que el objetivo retroceda. El daño se duplica contra un objetivo que usó Reducción.",
		},
		{
			NameKey = "Sky Uppercut",
			Description = "Inflige daño y puede golpear a Pokémon durante los turnos semi-invulnerables de Vuelo y Rebote.",
		},
		{
			NameKey = "Sand Tomb",
			Description = "Inflige daño y causa 1/16 de los PS máximos del objetivo como daño durante 2-5 turnos. Impide que el objetivo cambie o huya.",
		},
		{
			NameKey = "Sheer Cold",
			Description = "KO de un golpe. Este movimiento es 1% más preciso por cada nivel por encima del objetivo. Fallará si el objetivo es de nivel superior.",
		},
		{
			NameKey = "Muddy Water",
			Description = "Inflige daño y tiene un 30% de probabilidad de bajar la precisión de cada objetivo en un nivel.",
		},
		{
			NameKey = "Bullet Seed",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Aerial Ace",
			Description = "Inflige daño y omite las comprobaciones de Precisión para acertar siempre, a menos que el objetivo esté en el turno semi-invulnerable de un mov. como Excavar or Vuelo.",
		},
		{
			NameKey = "Icicle Spear",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Iron Defense",
			Description = "Aumenta la Defensa del usuario en dos niveles.",
		},
		{
			NameKey = "Block",
			Description = "Impide que el objetivo cambie o huya. Un Pokémon aún puede huir si tiene Fuga o tiene equipada una Bola Humo.",
		},
		{
			NameKey = "Howl",
			Description = "Aumenta la estadística de Ataque del usuario en un nivel.",
		},
		{
			NameKey = "Dragon Claw",
			Description = "Inflige daño y no tiene efecto secundario.",
		},
		{
			NameKey = "Frenzy Plant",
			Description = "Inflige daño y luego obliga al usuario a recargar durante el siguiente turno.",
		},
		{
			NameKey = "Bulk Up",
			Description = "Aumenta la estadística de Ataque y Defensa del usuario en un nivel cada uno.",
		},
		{
			NameKey = "Bounce",
			Description = "Ataca en el 2º turno con un 30% de probabilidad de paralizar al objetivo. Todavía puede ser golpeado por Tornado, Gancho Alto, Trueno y Ciclón.",
		},
		{
			NameKey = "Mud Shot",
			Description = "Inflige daño y luego baja la Velocidad del objetivo en un nivel.",
		},
		{
			NameKey = "Poison Tail",
			Description = "Inflige daño y tiene un 10% de probabilidad de envenenar al objetivo. También tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Covet",
			Description = "Roba el objeto que lleva el objetivo, si tiene uno. No se puede robar si el usuario tiene uno, o si el objetivo tiene Viscosidad.",
		},
		{
			NameKey = "Volt Tackle",
			Description = "El usuario recibe daño de retroceso igual al 1/3 del daño infligido.",
		},
		{
			NameKey = "Magical Leaf",
			Description = "Inflige daño y omite las comprobaciones de Precisión para acertar siempre, a menos que el objetivo esté en el turno semi-invulnerable de un mov. como Excavar or Vuelo",
		},
		{
			NameKey = "Water Sport",
			Description = "Reduce la potencia de los movimientos de Fuego en un 50% para todos los Pokémon en la batalla. Este efecto dura hasta que el usuario cambie de lugar.",
		},
		{
			NameKey = "Calm Mind",
			Description = "Aumenta en un nivel los stats de Ataque Especial y Defensa Especial del usuario.",
		},
		{
			NameKey = "Leaf Blade",
			Description = "Inflige daño y tiene una tasa de golpe crítico aumentada. (+1 etapa = 1/8 o 12.5%)",
		},
		{
			NameKey = "Dragon Dance",
			Description = "Aumenta en un nivel los stats de Ataque y Velocidad del usuario.",
		},
		{
			NameKey = "Rock Blast",
			Description = "Golpea de 2 a 5 veces en un turno. Dos: 37.5%, Tres: 37.5%, Cuatro: 12.5%, Cinco: 12.5%. cualquier golpe puede ser crítico.",
		},
		{
			NameKey = "Shock Wave",
			Description = "Inflige daño y omite las comprobaciones de Precisión para acertar siempre, a menos que el objetivo esté en el turno semi-invulnerable de un mov. como Excavar or Vuelo",
		},
		{
			NameKey = "Water Pulse",
			Description = "Inflige daño y tiene un 20% de probabilidad de confundir al objetivo.",
		},
		{
			NameKey = "Doom Desire",
			Description = "Fija el daño, basado en el ATQ del usuario y DSP del objetivo. Después de 2 turnos, inflige daño al enemigo actual. El ataque es sin tipo: no puede STAB, golpea Superguarda.",
		},
		{
			NameKey = "Psycho Boost",
			Description = "Inflige daño y baja el Ataque Especial del usuario en dos niveles.",
		},
	},
		-- The list of Pokémon abilities below must remain in the same order
	AbilityNames = {
		"Hedor", --Hedor english:Stench
		"Llovizna", --Llovizna english:Drizzle
		"Impulso", --Impulso english:Speed Boost
		"Arm. Bat.", --Arm. Bat. english:Battle Armor
		"Robustez", --Robustez english:Sturdy
		"Humedad", --Humedad english:Damp
		"Flexibilidad", --Flexibilidad english:Limber
		"Velo Arena", --Velo Arena english:Sand Veil
		"Elec. Estática", --Elec. Estática english:Static
		"Absor. Elec.", --Absor. Elec. english:Volt Absorb
		"Absorbe Agua", --Absorbe Agua english:Water Absorb
		"Despiste", --Despiste english:Oblivious
		"Aclimatación", --Aclimatación english:Cloud Nine
		"Ojo Compuesto", --Ojo Compuesto english:Compoundeyes
		"Insomnio", --Insomnio english:Insomnia
		"Cambio Color", --Cambio Color english:Color Change
		"Inmunidad", --Inmunidad english:Immunity
		"Absorbe Fuego", --Absorbe Fuego english:Flash Fire
		"Polvo Escudo", --Polvo Escudo english:Shield Dust
		"Ritmo Propio", --Ritmo Propio english:Own Tempo
		"Ventosas", --Ventosas english:Suction Cups
		"Intimidación", --Intimidación english:Intimidate
		"Sombra Trampa", --Sombra Trampa english:Shadow Tag
		"Piel Tosca", --Piel Tosca english:Rough Skin
		"Superguarda", --Superguarda english:Wonder Guard
		"Levitación", --Levitación english:Levitate
		"Efecto Espora", --Efecto Espora english:Effect Spore
		"Sincronía", --Sincronía english:Synchronize
		"Cuerpo Puro", --Cuerpo Puro english:Clear Body
		"Cura Natural", --Cura Natural english:Natural Cure
		"Pararrayos", --Pararrayos english:Lightningrod
		"Dicha", --Dicha english:Serene Grace
		"Nado Rápido", --Nado Rápido english:Swift Swim
		"Clorofila", --Clorofila english:Chlorophyll
		"Iluminación", --Iluminación english:Illuminate
		"Rastro", --Rastro english:Trace
		"Potencia", --Potencia Bruta english:Huge Power
		"Punto Tóxico", --Punto Tóxico english:Poison Point
		"Fuerza Mental", --Fuerza Mental english:Inner Focus
		"Escudo Magma", --Escudo Magma english:Magma Armor
		"Velo Agua", --Velo Agua english:Water Veil
		"Imán", --Imán english:Magnet Pull
		"Insonorizar", --Insonorizar english:Soundproof
		"Cura Lluvia", --Cura Lluvia english:Rain Dish
		"Chorro Arena", --Chorro Arena english:Sand Stream
		"Presión", --Presión english:Pressure
		"Sebo", --Sebo english:Thick Fat
		"Madrugar", --Madrugar english:Early Bird
		"Cuerpo Llama", --Cuerpo Llama english:Flame Body
		"Fuga", --Fuga english:Run Away
		"Vista Lince", --Vista Lince english:Keen Eye
		"Corte Fuerte", --Corte Fuerte english:Hyper Cutter
		"Recogida", --Recogida english:Pickup
		"Ausente", --Ausente english:Truant
		"Entusiasmo", --Entusiasmo english:Hustle
		"Gran Encanto", --Gran Encanto english:Cute Charm
		"Más", --Más english:Plus
		"Menos", --Menos english:Minus
		"Predicción", --Predicción english:Forecast
		"Viscosidad", --Viscosidad english:Sticky Hold
		"Mudar", --Mudar english:Shed Skin
		"Agallas", --Agallas english:Guts
		"Escama Especial", --Escama Especial english:Marvel Scale
		"Lodo Líquido", --Lodo Líquido english:Liquid Ooze
		"Espesura", --Espesura english:Overgrow
		"Mar Llamas", --Mar Llamas english:Blaze
		"Torrente", --Torrente english:Torrent
		"Enjambre", --Enjambre english:Swarm
		"Cabeza Roca", --Cabeza Roca english:Rock Head
		"Sequía", --Sequía english:Drought
		"Trampa Arena", --Trampa Arena english:Arena Trap
		"Espíritu Vital", --Espíritu Vital english:Vital Spirit
		"Humo Blanco", --Humo Blanco english:White Smoke
		"Energía Pura", --Energía Pura english:Pure Power
		"Caparazón", --Caparazón english:Shell Armor
		"Cacofonía", --Cacofonía english:Cacophony
		"Bucle Aire", --Bucle Aire english:Air Lock
	},
	-- The list below must remain in the same order.
	-- These are custom hand-written ability descriptions, only edit the "Description" and "DescriptionEmerald" values
	AbilityDescriptions = {
		{
			NameKey = "Stench",
			Description = "Mientras esté al frente del equipo, reduce la tasa de encuentros salvajes en un 50%.",
			DescriptionEmerald = "En la Pirámide Batalla, la tasa de encuentros salvajes solo se reduce en un 25%.",
		},
		{
			NameKey = "Drizzle",
			Description = "Cambia el clima a lluvia al entrar en combate. En lluvia, los movimientos de tipo Agua tienen un 50% más de poder y los de tipo Fuego tienen un 50% menos. Trueno siempre acertará, Rayo Solar inflige un 50% menos de daño, y Luz Lunar, Síntesis y Sol Matinal curan 1/4 de los PS máximos.",
		},
		{
			NameKey = "Speed Boost",
			Description = "Al final de cada turno, aumenta la Velocidad en una etapa.",
		},
		{
			NameKey = "Battle Armor",
			Description = "Evita que este Pokémon reciba golpes críticos.",
		},
		{
			NameKey = "Sturdy",
			Description = "No puede ser golpeado por movimientos de KO de un golpe (Fisura, Taladro, Guillotina, Frío Polar).",
		},
		{
			NameKey = "Damp",
			Description = "Evita que los Pokémon aliados y oponentes usen movimientos de autodestrucción (Autodestrucción, Explosión).",
		},
		{
			NameKey = "Limber",
			Description = "No puede ser paralizado. Obtener esta habilidad como a través de Intercambio, curará la parálisis.",
		},
		{
			NameKey = "Sand Veil",
			Description = "Aumenta la Evasión en un 20% durante una tormenta de arena, y este Pokémon no recibe daño al final del turno en una tormenta de arena.",
			DescriptionEmerald = "Mientras esté al frente del equipo, reduce la tasa de encuentros salvajes en un 50% durante una tormenta de arena.",
		},
		{
			NameKey = "Static",
			Description = "Cuando es golpeado por un movimiento de contacto, tiene un 1/3 de probabilidad de paralizar al atacante.",
			DescriptionEmerald = "Mientras esté al frente del equipo, los encuentros salvajes tienen un 50% de probabilidad de ser contra un Pokémon de tipo Eléctrico, si es posible.",
		},
		{
			NameKey = "Volt Absorb",
			Description = "Restaura el 25% de los PS máximos en lugar de recibir daño si es golpeado por un movimiento de tipo Eléctrico.",
		},
		{
			NameKey = "Water Absorb",
			Description = "Restaura el 25% de los PS máximos en lugar de recibir daño si es golpeado por un movimiento de tipo Agua.",
		},
		{
			NameKey = "Oblivious",
			Description = "No puede estar enamorado. Obtener esta habilidad como a través de Intercambio, curará el enamoramiento.",
		},
		{
			NameKey = "Cloud Nine",
			Description = "Niega todos los efectos del clima, pero no termina el clima.",
		},
		{
			NameKey = "Compoundeyes",
			Description = "Aumenta la precisión de los movimientos en un 30% (es decir, Trueno tiene una precisión del 70%. Con esta habilidad, la precisión sería del 70% x 1.3 = 91%).",
			DescriptionEmerald = "Aumenta la probabilidad de encontrar un Pokémon salvaje sosteniendo un objeto.",
		},
		{
			NameKey = "Insomnia",
			Description = "No puede ser dormido. Si este Pokémon usa Descanso, fallará. Obtener esta habilidad, como a través de Intercambio, curará el sueño.",
		},
		{
			NameKey = "Color Change",
			Description = "Cuando es golpeado por un movimiento dañino, cambia el tipo de este Pokémon para que coincida con el tipo del movimiento.",
		},
		{
			NameKey = "Immunity",
			Description = "No puede ser afectado por envenenamiento. Obtener esta habilidad, como a través de Intercambio, curará el envenenamiento.",
		},
		{
			NameKey = "Flash Fire",
			Description = "Inmune a los movimientos de tipo Fuego. La primera vez que este Pokémon es golpeado por un movimiento de tipo Fuego, sus propios movimientos de tipo Fuego ganan un 50% de poder.",
		},
		{
			NameKey = "Shield Dust",
			Description = "No afectado por los efectos adicionales de los movimientos dañinos de otros Pokémon. Por ejemplo, un Pokémon con esta habilidad no puede ser congelado por Ventisca o hacer que retroceda por Finta.",
		},
		{
			NameKey = "Own Tempo",
			Description = "No puede ser confundido. Obtener esta habilidad, como a través de Intercambio, curará la confusión.",
		},
		{
			NameKey = "Suction Cups",
			Description = "Evita que este Pokémon sea obligado a cambiar de lugar.",
			DescriptionEmerald = "Aumenta la probabilidad de recibir mordiscos mientras se pesca.",
		},
		{
			NameKey = "Intimidate",
			Description = "Reduce las estadísticas de Ataque de todos los Pokémon oponentes en una etapa cuando este Pokémon entra en batalla.",
			DescriptionEmerald = "Mientras esté al frente del equipo, 50% de probabilidad de evitar un encuentro salvaje que habría sido con un Pokémon 5 niveles o más bajo que este Pokémon.",
		},
		{
			NameKey = "Shadow Tag",
			Description = "Evita que los Pokémon oponentes cambien de lugar o huyan.",
		},
		{
			NameKey = "Rough Skin",
			Description = "Cuando es golpeado por un movimiento de contacto, el atacante recibe 1/16 de su PS máximo como daño.",
		},
		{
			NameKey = "Wonder Guard",
			Description = "Inmune a todos los movimientos dañinos que no son super efectivos, excepto Combate, Golpe Bajo, Precisión y Deseo Oculto. No puede ser copiado por Imitación o intercambiado por Intercambio.",
		},
		{
			NameKey = "Levitate",
			Description = "Inmune a los movimientos de tipo Tierra. Esta inmunidad se pierde si este Pokémon usa Arraigo.",
		},
		{
			NameKey = "Effect Spore",
			Description = "Cuando es golpeado por un movimiento de contacto, 10% de probabilidad de que el atacante quede afectado por Envenenamiento, Parálisis o Sueño; con igual probabilidad de cada uno. Es posible que el estado aleatorio no afecte al atacante, en el caso de que sea inmune a ese estado.",
		},
		{
			NameKey = "Synchronize",
			Description = "Cuando un Pokémon inflige Envenenamiento, Parálisis o Quemadura a este Pokémon, ese Pokémon será afectado con la misma condición de estado, si es posible.",
			DescriptionEmerald = "Mientras esté al frente del equipo, hay un 50% de probabilidad de que un Pokémon encontrado salvaje tenga la misma naturaleza que este Pokémon.",
		},
		{
			NameKey = "Clear Body",
			Description = "Evita reducciones de estadísticas causadas por movimientos y habilidades de Pokémon oponentes.",
		},
		{
			NameKey = "Natural Cure",
			Description = "Cura cualquier condición de estado al cambiar de Pokémon.",
		},
		{
			NameKey = "Lightningrod",
			Description = "Todos los movimientos eléctricos de un solo objetivo usados por Pokémon oponentes son redirigidos a este Pokémon.",
			DescriptionEmerald = "Mientras esté al frente del equipo, los entrenadores registrados con la función Match Call del PokéNav llamarán el doble de veces.",
		},
		{
			NameKey = "Serene Grace",
			Description = "Duplica la probabilidad de efectos secundarios de los movimientos de este Pokémon.",
		},
		{
			NameKey = "Swift Swim",
			Description = "Duplica la Velocidad durante la lluvia.",
		},
		{
			NameKey = "Chlorophyll",
			Description = "Duplica la Velocidad cuando el clima es soleado.",
		},
		{
			NameKey = "Illuminate",
			Description = "Aumenta la tasa de encuentros salvajes en un 100%.",
		},
		{
			NameKey = "Trace",
			Description = "Copia la habilidad de un Pokémon oponente aleatorio cuando este Pokémon entra en batalla.",
		},
		{
			NameKey = "Huge Power",
			Description = "Duplica el estadística de Ataque de este Pokémon.",
		},
		{
			NameKey = "Poison Point",
			Description = "Cuando es golpeado por un movimiento de contacto, tiene un 1/3 de probabilidad de envenenar al atacante.",
		},
		{
			NameKey = "Inner Focus",
			Description = "Evita retroceder.",
		},
		{
			NameKey = "Magma Armor",
			Description = "No puede ser congelado. Obtener esta habilidad, como a través de Intercambio, curará la congelación.",
			DescriptionEmerald = "Reduce a la mitad el tiempo necesario para incubar un huevo.",
		},
		{
			NameKey = "Water Veil",
			Description = "No puede ser quemado. Obtener esta habilidad, como a través de Intercambio, curará una quemadura.",
		},
		{
			NameKey = "Magnet Pull",
			Description = "Evita que los Pokémon de tipo Acero aliados y oponentes cambien de lugar.",
			DescriptionEmerald = "Mientras esté al frente del equipo, los encuentros salvajes tienen un 50% de probabilidad de ser contra un Pokémon de tipo Acero, si es posible.",
		},
		{
			NameKey = "Soundproof",
			Description = "Inmune a movimientos basados en sonido. Estos movimientos son: Silbato, Gruñido, Campana Cura, Vozarrón, Eco Metálico, Canto Mortal, Rugido, Chillido, Canto, Ronquido, Supersónico, Alboroto",
		},
		{
			NameKey = "Rain Dish",
			Description = "Cura a este Pokémon en un 1/16 de los PS máximos después de cada turno durante la lluvia.",
		},
		{
			NameKey = "Sand Stream",
			Description = "Cambia el clima a una tormenta de arena al entrar en combate. Después de cada turno durante una tormenta de arena, cada Pokémon recibe 1/16 de daño de PS máximos, a menos que sean de tipo Roca, Tierra o Acero.",
		},
		{
			NameKey = "Pressure",
			Description = "Cuando un movimiento tiene como objetivo a este Pokémon, se le deduce un PP adicional. Un Pokémon aún puede tener como objetivo a este Pokémon con un movimiento si solo le queda 1 PP para ello.",
			DescriptionEmerald = "Mientras esté al frente del equipo, 50% de probabilidad de que un Pokémon encontrado salvaje sea el de mayor nivel que podría aparecer.",
		},
		{
			NameKey = "Thick Fat",
			Description = "El daño recibido por movimientos de tipo Hielo o Fuego se reduce a la mitad.",
		},
		{
			NameKey = "Early Bird",
			Description = "Pasa la mitad de tiempo dormido, redondeado hacia abajo.",
		},
		{
			NameKey = "Flame Body",
			Description = "Cuando es golpeado por un movimiento de contacto, tiene un 1/3 de probabilidad de quemar al atacante.",
			DescriptionEmerald = "Reduce a la mitad el tiempo necesario para incubar un huevo.",
		},
		{
			NameKey = "Run Away",
			Description = "Huir de encuentros salvajes siempre tiene éxito.",
		},
		{
			NameKey = "Keen Eye",
			Description = "La precisión de este Pokémon no puede ser reducida.",
			DescriptionEmerald = "Mientras esté al frente del equipo, 50% de probabilidad de evitar un encuentro salvaje que habría sido con un Pokémon 5 niveles o más bajo que este Pokémon.",
		},
		{
			NameKey = "Hyper Cutter",
			Description = "El estadística de Ataque de este Pokémon no puede ser reducida por otros Pokémon.",
			DescriptionEmerald = "Si este Pokémon usa Corte en el mundo exterior, el radio del corte de la hierba alta se aumenta en uno.",
		},
		{
			NameKey = "Pickup",
			Description = "Después de ganar una batalla, hay un 10% de probabilidad de que este Pokémon tenga un objeto en sus manos, si es que no tenía uno ya.",
			DescriptionEmerald = "Los tipos de objetos obtenidos varían según el nivel de este Pokémon, o el nivel actual de la Pirámide Batalla.",
		},
		{
			NameKey = "Truant",
			Description = "Cada dos turnos usando un movimiento en batalla, este Pokémon en su lugar se queda inactivo y no hace nada.",
		},
		{
			NameKey = "Hustle",
			Description = "Aumenta el estadística de Ataque en un 50%, pero reduce la precisión de los movimientos físicos en un 20%.",
			DescriptionEmerald = "Mientras esté al frente del equipo, 50% de probabilidad de que un Pokémon encontrado salvaje sea el de mayor nivel que podría aparecer.",
		},
		{
			NameKey = "Cute Charm",
			Description = "Cuando es golpeado por un movimiento de contacto, tiene un 1/3 de probabilidad de infligir enamoramiento al atacante. No tiene efecto si este Pokémon no tiene género, o si es del mismo género que el atacante.",
			DescriptionEmerald = "Mientras esté al frente del equipo, 2/3 de probabilidad de que un encuentro salvaje sea forzado al género opuesto de este Pokémon, si es posible.",
		},
		{
			NameKey = "Plus",
			Description = "En una Batalla Doble donde cualquier Pokémon activo tiene la habilidad Menos, la estadística de Ataque Especial de este Pokémon aumenta en un 50%.",
		},
		{
			NameKey = "Minus",
			Description = "En una Batalla Doble donde cualquier Pokémon activo tiene la habilidad Más, la estadística de Ataque Especial de este Pokémon aumenta en un 50%.",
		},
		{
			NameKey = "Forecast",
			Description = "El tipo de Castform cambia con el clima. Fuego mientras hace sol, Agua mientras llueve, o Hielo mientras graniza. Aclimatación y Bucle Aire desactivan este efecto. Esta habilidad no tiene efecto si un Pokémon que no es Castform obtiene esta habilidad.",
		},
		{
			NameKey = "Sticky Hold",
			Description = "El objeto que tiene equipado este Pokémon no puede ser robado o eliminado.",
			DescriptionEmerald = "Aumenta la probabilidad de recibir mordiscos mientras se pesca.",
		},
		{
			NameKey = "Shed Skin",
			Description = "1/3 de probabilidad al final de cada turno de curar condiciones de estado mayores (Quemadura, Envenenamiento, Parálisis, Congelación, Sueño).",
		},
		{
			NameKey = "Guts",
			Description = "Aumenta la estadística de Ataque de este Pokémon en un 50% cuando es afectado por una condición de estado mayor (Quemadura, Envenenamiento, Parálisis, Congelación, Sueño), e ignora la reducción de Ataque por Quemadura.",
		},
		{
			NameKey = "Marvel Scale",
			Description = "Aumenta la estadística de Defensa de este Pokémon en un 50% cuando es afectado por una condición de estado mayor (Quemadura, Envenenamiento, Parálisis, Congelación, Sueño).",
		},
		{
			NameKey = "Liquid Ooze",
			Description = "Los movimientos que absorben PS usados contra este Pokémon hacen que el atacante pierda en cambio los PS que habría curado.",
		},
		{
			NameKey = "Overgrow",
			Description = "Si este Pokémon tiene 1/3 o menos de sus PS máximos, el poder de sus movimientos de tipo Planta aumenta en un 50%.",
		},
		{
			NameKey = "Blaze",
			Description = "Si este Pokémon tiene 1/3 o menos de sus PS máximos, el poder de sus movimientos de tipo Fuego aumenta en un 50%.",
		},
		{
			NameKey = "Torrent",
			Description = "Si este Pokémon tiene 1/3 o menos de sus PS máximos, el poder de sus movimientos de tipo Agua aumenta en un 50%.",
		},
		{
			NameKey = "Swarm",
			Description = "Si este Pokémon tiene 1/3 o menos de sus PS máximos, el poder de sus movimientos de tipo Bicho aumenta en un 50%.",
			DescriptionEmerald = "Aumenta la frecuencia con la que se oyen los gritos de los Pokémon salvajes en el mundo exterior.",
		},
		{
			NameKey = "Rock Head",
			Description = "Evita el daño por retroceso de los movimientos, excepto por el tipo Lucha.",
		},
		{
			NameKey = "Drought",
			Description = "Cambia el clima a soleado al entrar en combate. En sol, los movimientos de tipo Fuego tienen un 50% más de poder y los de tipo Agua tienen un 50% menos de poder. Elimina el turno de carga de Rayo Solar, reduce la precisión de Trueno al 50%, y hace que Luz Lunar, Síntesis y Sol Matinal curen 2/3 de los PS máximos.",
		},
		{
			NameKey = "Arena Trap",
			Description = "Evita que los Pokémon oponentes cambien de lugar o huyan, excepto los de tipo Volador y los que tienen Levitación.",
			DescriptionEmerald = "Aumenta la tasa de encuentros salvajes en un 100%.",
		},
		{
			NameKey = "Vital Spirit",
			Description = "No puede ser dormido. Si este Pokémon intenta usar Descanso, fallará. Obtener esta habilidad, como a través de Intercambio, curará el sueño.",
			DescriptionEmerald = "Mientras esté al frente del equipo, 50% de probabilidad de que un encuentro salvaje esté al nivel más alto posible que ese Pokémon podría aparecer.",
		},
		{
			NameKey = "White Smoke",
			Description = "Evita reducciones de estadísticas causadas por movimientos y habilidades de Pokémon oponentes.",
			DescriptionEmerald = "Mientras esté al frente del equipo, reduce la tasa de encuentros salvajes en un 50%.",
		},
		{
			NameKey = "Pure Power",
			Description = "Duplica el estadística de Ataque de este Pokémon.",
		},
		{
			NameKey = "Shell Armor",
			Description = "Evita que este Pokémon reciba golpes críticos.",
		},
		{
			NameKey = "Cacophony",
			Description = "Inmune a movimientos basados en sonido. Estos movimientos son: Silbato, Gruñido, Campana Cura, Vozarrón, Eco Metálico, Canto Mortal, Rugido, Chillido, Canto, Ronquido, Supersónico, Alboroto.",
		},
		{
			NameKey = "Air Lock",
			Description = "Niega todos los efectos del clima, pero no termina el clima.",
		},
	},
	-- The list of item names below must remain in the same order
	ItemNames = {
		"Master Ball", --Master Ball english:Master Ball
		"Ultra Ball", --Ultraball english:Ultra Ball
		"Super Ball", --Superball english:Great Ball
		"Poké Ball", --Poké Ball english:Poke Ball
		"Safari Ball", --Safari Ball english:Safari Ball
		"Malla Ball", --Malla Ball english:Net Ball
		"Buceo Ball", --Buceo Ball english:Dive Ball
		"Nido Ball", --Nido Ball english:Nest Ball
		"Acopio Ball", --Acopio Ball english:Repeat Ball
		"Turno Ball", --Turno Ball english:Timer Ball
		"Lujo Ball", --Lujo Ball english:Luxury Ball
		"Honor Ball", --Honor Ball english:Premier Ball
		"Poción", --Poción english:Potion
		"Antídoto", --Antídoto english:Antidote
		"Antiquemar", --Antiquemar english:Burn Heal
		"Antihielo", --Antihielo english:Ice Heal
		"Despertar", --Despertar english:Awakening
		"Antiparaliz", --Antiparaliz english:Parlyz Heal
		"Restau. Todo", --Restau. Todo english:Full Restore
		"Max. Poción", --Max. Poción english:Max Potion
		"Hiperpoción", --Hiperpoción english:Hyper Potion
		"Superpoción", --Superpoción english:Super Potion
		"Cura Total", --Cura Total english:Full Heal
		"Revivir", --Revivir english:Revive
		"Máx. Revivir", -- english:Max Revive
		"Agua Fresca", --Agua Fresca english:Fresh Water
		"Refresco", --Refresco english:Soda Pop
		"Limonada", --Limonada english:Lemonade
		"Leche Mu-Mu", --Leche Mu-Mu english:Moomoo Milk
		"Polvoenergía", --Polvoenergía english:EnergyPowder
		"Raíz Energía", --Raíz Energía english:Energy Root
		"Polvo curación", --Polvo curación english:Heal Powder
		"Hierba Revivir", --Hierba Revivir english:Revival Herb
		"Éter", --Éter english:Ether
		"Éter Máx.", --Éter Máx. english:Max Ether
		"Elixir", --Elixir english:Elixir
		"Elixir Máx.", --Máximo Elixir english:Max Elixir
		"Galleta Lava", --Galleta Lava english:Lava Cookie
		"Flauta Azul", --Flauta Azul english:Blue Flute
		"Fl. Amarilla", --Flauta Amarilla english:Yellow Flute
		"Flauta Roja", --Flauta Roja english:Red Flute
		"Flauta Negra", --Flauta Negra english:Black Flute
		"Fl. Blanca", --Flauta Blanca english:White Flute
		"Zumo De Baya", --Zumo De Baya english:Berry Juice
		"Cen. Sagrada", --Cen. Sagrada english:Sacred Ash
		"Sal Cardumen", --Sal Cardumen english:Shoal Salt
		"C. Cardumen", --C. Cardumen english:Shoal Shell
		"Parte Roja", --Parte Roja english:Red Shard
		"Parte Azul", --Parte Azul english:Blue Shard
		"P. Amarilla", --P. Amarilla english:Yellow Shard
		"Parte Verde", --Parte Verde english:Green Shard
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Más PS", --Más PS english:HP Up
		"Proteína", --Proteína english:Protein
		"Hierro", --Hierro english:Iron
		"Carburante", --Carburante english:Carbos
		"Calcio", --Calcio english:Calcium
		"Carameloraro", --Carameloraro english:Rare Candy
		"Más PP", --Más PP english:PP Up
		"Zinc", --Zinc english:Zinc
		"Máx. PP", --PP Máximos english:PP Max
		"????????", --???????? english:unknown
		"Protec Esp.", --Protección Especial english:Guard Spec.
		"Directo", --Directo english:Dire Hit
		"Ataque X", --Ataque X english:X Attack
		"Defensa X", --Defensa X english:X Defend
		"Velocidad X", --Velocidad X english:X Speed
		"Precisión X", --Precisión X english:X Accuracy
		"Especial X", --Especial X english:X Special
		"Poké Muñeco", --Poké Muñeco english:Poke Doll
		"Cola Skitty", --Cola Skitty english:Fluffy Tail
		"????????", --???????? english:unknown
		"Superrepel", --Superrepel english:Super Repel
		"Máx. Repel", --Máx. Repel english:Max Repel
		"Cuerda Huida", --Cuerda Huida english:Escape Rope
		"Repelente", --Repelente english:Repel
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Piedra Solar", --Piedra Solar english:Sun Stone
		"Piedra Lunar", --Piedra Lunar english:Moon Stone
		"Piedra Fuego", --Piedra Fuego english:Fire Stone
		"Piedratrueno", --Piedratrueno english:Thunderstone
		"Piedra Agua", --Piedra Agua english:Water Stone
		"Piedra Hoja", --Piedra Hoja english:Leaf Stone
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Mini Seta", --Mini Seta english:TinyMushroom
		"Seta Grande", --Seta Grande english:Big Mushroom
		"????????", --???????? english:unknown
		"Perla", --Perla english:Pearl
		"Perla Grande", --Perla Grande english:Big Pearl
		"Polvoestelar", --Polvoestelar english:Stardust
		"Tr. Estrella", --Tr. Estrella english:Star Piece
		"Pepita", --Pepita english:Nugget
		"Esc. Corazón", --Esc. Corazón english:Heart Scale
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Car. Naranja", --Car. Naranja english:Orange Mail
		"Carta Puerto", --Carta Puerto english:Harbor Mail
		"Carta Brillo", --Carta Brillo english:Glitter Mail
		"Carta Imán", --Carta Imán english:Mech Mail
		"Carta Madera", --Carta Madera english:Wood Mail
		"Carta Ola", --Carta Ola english:Wave Mail
		"Carta Imagen", --Carta Imagen english:Bead Mail
		"Carta Sombra", --Carta Sombra english:Shadow Mail
		"Car. Tropic.", --Car. Tropic. english:Tropic Mail
		"Carta Sueño", --Carta Sueño english:Dream Mail
		"Carta Fab.", --Carta Fabulosa english:Fab Mail
		"Carta Retro", --Carta Retro english:Retro Mail
		"Baya Zreza", --Baya Zreza english:Cheri Berry
		"Baya Atania", --Baya Atania english:Chesto Berry
		"Baya Meloc", --Baya Meloc english:Pecha Berry
		"Baya Safre", --Baya Safre english:Rawst Berry
		"Baya Perasi", --Baya Perasi english:Aspear Berry
		"Baya Zanama", --Baya Zanama english:Leppa Berry
		"Baya Aranja", --Baya Aranja english:Oran Berry
		"Baya Caquic", --Baya Caquic english:Persim Berry
		"Baya Ziuela", --Baya Ziuela english:Lum Berry
		"Baya Zidra", --Baya Zidra english:Sitrus Berry
		"Baya Higog", --Baya Higog english:Figy Berry
		"Baya Wiki", --Baya Wiki english:Wiki Berry
		"Baya Ango", --Baya Ango english:Mago Berry
		"Baya Guaya", --Baya Guaya english:Aguav Berry
		"Baya Pabaya", --Baya Pabaya english:Iapapa Berry
		"Baya Frambu", --Baya Frambu english:Razz Berry
		"Baya Oram", --Baya Oram english:Bluk Berry
		"Baya Latano", --Baya Latano english:Nanab Berry
		"Baya Peragu", --Baya Peragu english:Wepear Berry
		"Baya Pinia", --Baya Pinia english:Pinap Berry
		"Baya Grana", --Baya Grana english:Pomeg Berry
		"Baya Algama", --Baya Algama english:Kelpsy Berry
		"Baya Ispero", --Baya Ispero english:Qualot Berry
		"Baya Meluce", --Baya Meluce english:Hondew Berry
		"Baya Uvav", --Baya Uvav english:Grepa Berry
		"Baya Tamate", --Baya Tamate english:Tamato Berry
		"Baya Mais", --Baya Mais english:Cornn Berry
		"Baya Aostan", --Baya Aostan english:Magost Berry
		"Baya Rautan", --Baya Rautan english:Rabuta Berry
		"Baya Monli", --Baya Monli english:Nomel Berry
		"Baya Wikano", --Baya Wikano english:Spelon Berry
		"Baya Plama", --Baya Plama english:Pamtre Berry
		"Baya Sambia", --Baya Sambia english:Watmel Berry
		"Baya Rudion", --Baya Rudion english:Durin Berry
		"Baya Andano", --Baya Andano english:Belue Berry
		"Baya Lichi", --Baya Lichi english:Liechi Berry
		"Baya Gonlan", --Baya Gonlan english:Ganlon Berry
		"Baya Aslac", --Baya Aslac english:Salac Berry
		"Baya Yapati", --Baya Yapati english:Petaya Berry
		"Baya Aricoc", --Baya Aricoc english:Apicot Berry
		"Baya Zonlan", --Baya Zonlan english:Lansat Berry
		"Baya Arabol", --Baya Arabol english:Starf Berry
		"Baya Enigma", --Baya Enigma english:Enigma Berry
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Polvo Brillo", --Polvo Brillo english:BrightPowder
		"Hier. Blanca", --Hier. Blanca english:White Herb
		"Vestidura", --Vestidura english:Macho Brace
		"Repartir Exp", --Repartir Exp english:Exp. Share
		"Garra Rápida", --Garra Rápida english:Quick Claw
		"Camp. Alivio", --Camp. Alivio english:Soothe Bell
		"Hier. Mental", --Hier. Mental english:Mental Herb
		"Cint. Elegida", --Cint. Elegida english:Choice Band
		"Roca Del Rey", --Roca Del Rey english:King's Rock
		"Polvo Plata", --Polvo Plata english:SilverPowder
		"Mon. Amuleto", --Mon. Amuleto english:Amulet Coin
		"Amuleto", --Amuleto english:Cleanse Tag
		"Rocío Bondad", --Rocío Bondad english:Soul Dew
		"Diente Mar.", --Diente Marino english:DeepSeaTooth
		"Escama Mar.", --Escama Mar. english:DeepSeaScale
		"Bola Humo", --Bola Humo english:Smoke Ball
		"Piedraeterna", --Piedraeterna english:Everstone
		"Cinta Focus", --Cinta Focus english:Focus Band
		"Huevo Suerte", --Huevo Suerte english:Lucky Egg
		"Periscopio", --Periscopio english:Scope Lens
		"Rev.metálico", --Rev. metálico english:Metal Coat
		"Restos", --Restos english:Leftovers
		"Escamadragón", --Escamadragón english:Dragon Scale
		"Bolaluminosa", --Bolaluminosa english:Light Ball
		"Arena Fina", --Arena Fina english:Soft Sand
		"Piedra Dura", --Piedra Dura english:Hard Stone
		"Sem. Milagro", --Sem. Milagro english:Miracle Seed
		"Gafas De Sol", --Gafas De Sol english:BlackGlasses
		"Cint. Negro", --Cint. Negro english:Black Belt
		"Imán", --Imán english:Magnet
		"Agua Mística", --Agua Mística english:Mystic Water
		"Pico Afilado", --Pico Afilado english:Sharp Beak
		"Flecha Ven.", --Flecha Ven. english:Poison Barb
		"Antiderretir", --Antiderretir english:NeverMeltIce
		"Hechizo", --Hechizo english:Spell Tag
		"Cuchara Tor.", --Cuchara Torcida english:TwistedSpoon
		"Carbón", --Carbón english:Charcoal
		"Colmillodrag", --Colmillodrag english:Dragon Fang
		"Pañuelo Seda", --Pañuelo Seda english:Silk Scarf
		"Mejora", --Mejora english:Up-Grade
		"Camp. Concha", --Camp. Concha english:Shell Bell
		"Incie. Mar.", --Incienso Marino english:Sea Incense
		"Incie. Suave", --Incienso Suave english:Lax Incense
		"Puño Suerte", --Puño Suerte english:Lucky Punch
		"Pol.metálico", --Polv.metálico english:Metal Powder
		"Hueso Grueso", --Hueso Grueso english:Thick Club
		"Palo", --Palo english:Stick
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Pañuelo Rojo", --Pañuelo Rojo english:Red Scarf
		"Pañuelo Azul", --Pañuelo Azul english:Blue Scarf
		"Pañuelo Rosa", --Pañuelo Rosa english:Pink Scarf
		"Pañ. Verde", --Pañ. Verde english:Green Scarf
		"P. Amarillo", --P. Amarillo english:Yellow Scarf
		"Bici Carrera", --Bici Carrera english:Mach Bike
		"Monedero", --Monedero english:Coin Case
		"Buscaobjetos", --Buscaobjetos english:Itemfinder
		"Caña Vieja", --Caña Vieja english:Old Rod
		"Caña Buena", --Caña Buena english:Good Rod
		"Supercaña", --Supercaña english:Super Rod
		"Ticket Barco", --Ticket Barco english:S.S. Ticket
		"Pase Concur.", --Pase Concur. english:Contest Pass
		"????????", --???????? english:unknown
		"Cubo Wailmer", --Cubo Wailmer english:Wailmer Pail
		"Piezas Devon", --Piezas Devon english:Devon Goods
		"Saco Hollín", --Saco Hollín english:Soot Sack
		"Ll. Sótano", --Ll. Sótano english:Basement Key
		"Bici Acrob.", --Bici Acrob. english:Acro Bike
		"Tubo Pokécubos", --Kit de Pokécubos english:Pokeblock Case
		"Carta", --Carta english:Letter
		"Ticket Eón", --Ticket Eón english:Eon Ticket
		"Esfera Roja", --Esfera Roja english:Red Orb
		"Esfera Azul", --Esfera Azul english:Blue Orb
		"Escáner", --Escáner english:Scanner
		"Gaf. Aislan.", --Gaf. Aislan. english:Go-Goggles
		"Meteorito", --Meteorito english:Meteorite
		"Ll. Cabina 1", --Ll. Cabina 1 english:Rm. 1 Key
		"Ll. Cabina 2", --Ll. Cabina 2 english:Rm. 2 Key
		"Ll. Cabina 4", --Ll. Cabina 4 english:Rm. 4 Key
		"Ll. Cabina 6", --Ll. Cabina 6 english:Rm. 6 Key
		"Ll. Almacén", --Ll. Almacén english:Storage Key
		"Fósil Raíz", --Fósil Raíz english:Root Fossil
		"Fósil Garra", --Fósil Garra english:Claw Fossil
		"Detec. Devon", --Detector Devon english:Devon Scope
		"Mt01", --Mt01 english:TM01
		"Mt02", --Mt02 english:TM02
		"Mt03", --Mt03 english:TM03
		"Mt04", --Mt04 english:TM04
		"Mt05", --Mt05 english:TM05
		"Mt06", --Mt06 english:TM06
		"Mt07", --Mt07 english:TM07
		"Mt08", --Mt08 english:TM08
		"Mt09", --Mt09 english:TM09
		"Mt10", --Mt10 english:TM10
		"Mt11", --Mt11 english:TM11
		"Mt12", --Mt12 english:TM12
		"Mt13", --Mt13 english:TM13
		"Mt14", --Mt14 english:TM14
		"Mt15", --Mt15 english:TM15
		"Mt16", --Mt16 english:TM16
		"Mt17", --Mt17 english:TM17
		"Mt18", --Mt18 english:TM18
		"Mt19", --Mt19 english:TM19
		"Mt20", --Mt20 english:TM20
		"Mt21", --Mt21 english:TM21
		"Mt22", --Mt22 english:TM22
		"Mt23", --Mt23 english:TM23
		"Mt24", --Mt24 english:TM24
		"Mt25", --Mt25 english:TM25
		"Mt26", --Mt26 english:TM26
		"Mt27", --Mt27 english:TM27
		"Mt28", --Mt28 english:TM28
		"Mt29", --Mt29 english:TM29
		"Mt30", --Mt30 english:TM30
		"Mt31", --Mt31 english:TM31
		"Mt32", --Mt32 english:TM32
		"Mt33", --Mt33 english:TM33
		"Mt34", --Mt34 english:TM34
		"Mt35", --Mt35 english:TM35
		"Mt36", --Mt36 english:TM36
		"Mt37", --Mt37 english:TM37
		"Mt38", --Mt38 english:TM38
		"Mt39", --Mt39 english:TM39
		"Mt40", --Mt40 english:TM40
		"Mt41", --Mt41 english:TM41
		"Mt42", --Mt42 english:TM42
		"Mt43", --Mt43 english:TM43
		"Mt44", --Mt44 english:TM44
		"Mt45", --Mt45 english:TM45
		"Mt46", --Mt46 english:TM46
		"Mt47", --Mt47 english:TM47
		"Mt48", --Mt48 english:TM48
		"Mt49", --Mt49 english:TM49
		"Mt50", --Mt50 english:TM50
		"Mo01", --Mo01 english:HM01
		"Mo02", --Mo02 english:HM02
		"Mo03", --Mo03 english:HM03
		"Mo04", --Mo04 english:HM04
		"Mo05", --Mo05 english:HM05
		"Mo06", --Mo06 english:HM06
		"Mo07", --Mo07 english:HM07
		"Mo08", --Mo08 english:HM08
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Correo-Oak", --Correo-Oak english:Oak's Parcel
		"Poké Flauta", --Poké Flauta english:Poke Flute
		"Ll. Secreta", --Ll. Secreta english:Secret Key
		"Bono Bici", --Bono Bici english:Bike Voucher
		"Dientes Oro", --Dientes Oro english:Gold Teeth
		"Ámbar Viejo", --Ámbar Viejo english:Old Amber
		"Ll.magnética", --Llave magnética english:Card Key
		"Ll. Ascensor", --Llave Ascensor english:Lift Key
		"Fósil Helix", --Fósil Helix english:Helix Fossil
		"Fósil Domo", --Fósil Domo english:Dome Fossil
		"Scope Silph", --Scope Silph english:Silph Scope
		"Bicicleta", --Bicicleta english:Bicycle
		"Mapa", --Mapa english:Town Map
		"Buscapelea", --Buscapelea english:Vs. Seeker
		"Memorín", --Memorín english:Fame Checker
		"Tubo MT-MO", --Tubo MT-MO english:TM Case
		"Saco Bayas", --Saco Bayas english:Berry Pouch
		"Poké Tele", --Poké Tele english:Teachy TV
		"Tri-Ticket", --Tri-Ticket english:Tri-Pass
		"Iris-Ticket", --Iris-Ticket english:Rainbow Pass
		"Té", --Té english:Tea
		"Misti-Ticket", --Misti-Ticket english:MysticTicket
		"Ori-Ticket", --Ori-Ticket english:AuroraTicket
		"Bote Polvos", --Bote Polvos english:Powder Jar
		"Rubí", --Rubí english:Ruby
		"Zafiro", --Zafiro english:Sapphire
		"Signo Magma", --Signo Magma english:Magma Emblem
		"Mapa viejo", -- Mapa viejo english:Old Sea Map
	},
	-- The list of Pokémon natures below must remain in the same order
	NatureNames = {
		"Fuerte",
		"Huraña",
		"Audaz",
		"Firme",
		"Pícara",
		"Osada",
		"Dócil",
		"Plácida",
		"Agitada",
		"Floja",
		"Miedosa",
		"Activa",
		"Seria",
		"Alegre",
		"Ingenua",
		"Modesta",
		"Afable",
		"Mansa",
		"Tímida",
		"Alocada",
		"Serena",
		"Amable",
		"Grosera",
		"Cauta",
		"Rara",
	},
}
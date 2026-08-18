ScreenResources{
	GameOverScreenQuotes = {
		"Que se passe-t-il, dresseur ?",
		"Que va faire le dresseur maintenant ?",
		"Oh ! Encore un échec !",
		"Boum !",
		"Dévastateur !",
		"Terminé ! Il n'a eu aucune chance !",
		"La stratégie peut-elle compenser l'écart de niveau ?",
		"Il n'est plus en état de combattre !",
		"C'est un combat entre Pokémon clairement déséquilibrés.",
		"Le Pokémon retourne dans sa Poké Ball.",
		"A terre ! Ça n'a pas pris longtemps !",
		"Celle-la a fait mal !",
		"Et le combat se termine ainsi !",
		"Quel retournement de situation !",
		"Mis K.O. d'entrée de jeu !",
		"Wouah ! C'était écrasant !",
		"Il est enfin mis K.O. !",
		"Coup violent !",
		"C'était brutal !",
		"Faiblesse touchée en plein !",
		"Hé ! Qu'est-ce qu'il fait ? Et il tombe !",
	},
	AllScreens = {
		Pokemon = "Pokémon",
		Back = "Retour",
		Yes = "Oui",
		No = "Non",
		OK = "OK",
		Cancel = "Annuler",
		Preview = "Aperçu",
		Save = "Sauvegarder",
		Close = "Fermer",
		Clear = "Effacer",
		Import = "Importer",
		Export = "Exporter",
		Lookup = "Rechercher",
		Page = "Page",
	},
	PokemonEvolutionDetails = {
		-- abbreviation: appears on the main Tracker Screen
		-- short: used for the log viewer
		-- detailed: used for Pokémon Info Look up
		LEVEL = {
			short = "Niv.",
			detailed = "Niveau",
		},
		FRIEND = {
			abbreviation = "AMITIE",
			short = "Amitié",
			detailed = "Amitié",
		},
		FRIEND_READY = {
			abbreviation = "PRET",
		},
		THUNDER = {
			abbreviation = "FOUDRE",
			short = "Foudre",
			detailed = "Pierrefoudre",
		},
		FIRE = {
			abbreviation = "FEU",
			short = "Feu",
			detailed = "Pierre Feu",
		},
		WATER = {
			abbreviation = "EAU",
			short = "Eau",
			detailed = "Pierre Eau",
		},
		MOON = {
			abbreviation = "LUNE",
			short = "Lune",
			detailed = "Pierre Lune",
		},
		LEAF = {
			abbreviation = "PLANTE",
			short = "Plante",
			detailed = "Pierreplante",
		},
		SUN = {
			abbreviation = "SOLEIL",
			short = "Soleil",
			detailed = "Pierresoleil",
		},
		LEAF_SUN = {
			abbreviation = "PL/SO",
		},
		WATER30 = {
			abbreviation = "30/EAU",
		},
		WATER37 = {
			abbreviation = "37/EAU",
		},
		WATER37_REV = {
			abbreviation = "EAU/37",
		},
		EEVEE_STONES = {
			abbreviation = "PIERRE",
			detailed = "5 pierres diff.",
		},
	},
	TrackerScreen = {
		HPAbbreviation = "PV",
		LevelAbbreviation = "Niv",
		RandomBallChosen = "Balle choisie au hasard",
		RandomBallUserChosen = "Balle choisie",
		RandomBallUserPicks = "choisit",
		RandomBallLeft = "Gauche",
		RandomBallMiddle = "Milieu",
		RandomBallRight = "Droite",
		RandomBallRandom = "Aléatoire",
		HealsInBag = "Soins",
		UnidentifiedGhost = "Spectre",
		BattleNewEncounter = "Nouv. rencontre",
		BattleLastSeen = "Vu au",
		BattleSeenInTheWild = "Vue (Sauvage)",
		BattleSeenOnTrainers = "Vue (Dresseur)",
		BattleTeam = "Équipe",
		StatHP = "PV",
		StatATK = "ATQ",
		StatDEF = "DEF",
		StatSPA = "ATS",
		StatSPD = "DFS",
		StatSPE = "VIT",
		StatBST = "BST",
		StatAccuracy = "Pré",
		StatEvasion = "Esq",
		HeaderMoves = "Attaques",
		HeaderPP = "PP",
		HeaderPow = "Puiss",
		HeaderAcc = "Pré",
		ToCatch = "capture",
		LeaveANote = "Ajouter une note",
		DamageTaken = "dégâts",
		DamageTakenInTeams = "Total reçu",
		PedometerSteps = "Pas",
		PedometerGoal = "Objectif",
		PedometerTotal = "Total",
		PedometerReset = "Réinit.",
		EncounterWalking = "Marche",
		EncounterSurfing = "Surf",
		EncounterUnderwater = "Sous-marin",
		EncounterStatic = "Statique",
		EncounterRockSmash = "Éclate-Roc",
		EncounterSuperRod = "Super Canne",
		EncounterGoodRod = "Bonne Canne",
		EncounterOldRod = "Canne",
		EncounterSeenPokemon = "Pokémon vus",
		TrainersDefeated = "Dresseurs vaincus",
		TrainersNoneInArea = "Aucun dresseur dans cette zone.",
		GachaMonCaptured = "GachaMon capturé !",
		PromptNoteDesc = "Entrer une note rapide pour",
		PromptNoteAbilityDesc = "Définir une ou deux capacités pour",
		PromptNoteClearAbilities = "Effacer les capacités",
		PromptStepsTitle = "Choisir un objectif de pas",
		PromptStepsDesc1 = "Le podomètre changera de couleur à l'objectif.",
		PromptStepsDesc2 = "Mettre 0 pour désactiver",
		PromptStepsEnterGoal = "Combien de pas pour atteindre l'objectif ?",
	},
	StartupScreen = {
		Title = "Ironmon Tracker",
		Version = "Version",
		Game = "Jeu",
		Attempts = "Tentatives",
		TrackedDataMsgLabel = "Notes du Tracker",
		TrackedDataMsgLoadSuccess = "Chargé depuis la dernière session.",
		TrackedDataMsgNewGame = "Nouvelle partie démarrée.",
		TrackedDataMsgAutoDisabled = "Sauvegarde / chargement auto désactivés.",
		TrackedDataMsgRomMismatch = "ROM incorrecte chargée.",
		TrackedDataMsgError = "Erreur de chargement du fichier.",
		HeaderFavorites = "Pokémon favoris",
		HeaderControls = "Commandes GBA",
		ControlsSwapView = "Changer le Pokémon affiché",
		ControlsQuickload = "Nouvelle partie",
		ControlsEraseGameSave = "Effacer la sauvegarde",
		PromptChooseAPokemonTitle = "Choisir un Pokémon",
		PromptChooseAPokemonDesc = "Choisir un Pokémon à afficher au démarrage",
		PromptChooseAPokemonByAttempt = "Selon le numéro de tentative",
		PromptChooseAPokemonByRandom = "Aléatoire à chaque fois",
		PromptChooseAPokemonNone = "Aucun",
	},
	NavigationMenu = {
		Title = "Paramètres du Tracker",
		ButtonSetup = "Config.",
		ButtonGameplay = "Gameplay",
		ButtonTheme = "Thème",
		ButtonStreaming = "Streaming",
		ButtonExtras = "Extras",
		ButtonQuickload = "N. partie",
		ButtonNotebook = "Carnet",
		ButtonLanguage = "Langue",
		ButtonUpdate = "Mise à jour",
		ButtonExtensions = "Extensions",
		ButtonCredits = "Crédits",
		ButtonHelp = "Aide",
		CreditsCreatedBy = "Créé par",
		CreditsContributors = "Contributeurs",
		MessageCheckConsole = "Consultez la console Lua pour le lien vers le wiki d'aide du tracker.",
	},
	SetupScreen = {
		Title = "Config. du Tracker",
		TabGeneral = "Général",
		TabCarousel = "Carrousel",
		TabControls = "Contrôles",
		PokemonIconSetLabel = "Icônes Pokémon",
		PokemonIconSetAuthor = "Ajouté par",
		OptionShowRandomBallPicker = "Balles aléatoires",
		OptionShowTeamView = "Afficher la vue équipe",
		OptionRightJustifiedNumbers = "Aligner les nombres à droite",
		OptionTrackPCHeals = "Soins PC Pokémon",
		OptionPCHealsCountDown = "Compte à rebours des soins",
		OptionAllowSpritesToWalk = "Marche",
		ButtonManageData = "Données",
		OptionAllowCarouselRotation = "Rotation du panneau",
		LabelInfoToShow = "Infos à afficher",
		LabelSpeedSetting = "Vitesse",
		CarouselBadges = "Badges d'arène",
		CarouselNotes = "Notes sur les Pokémon",
		CarouselRouteInfo = "Sauvages de la zone",
		CarouselTrainers = "Dresseurs vaincus dans la zone",
		CarouselLastAttack = "Dégâts de la dernière attaque",
		CarouselBattleDetails = "Détails supplémentaire",
		CarouselPedometer = "Podomètre",
		CarouselGachaMon = "GachaMon capturés",
		OptionOverrideButtonModeLR = "Forcer le mode LR",
		ButtonEditAll = "Modifier",
		LabelCurrentControllerBinding = "Raccourci actuel",
		LabelNewControllerBinding = "Nouveau raccourci",
		LabelWaiting = "En attente",
		LabelPressControllerButtons = "Appuyez sur le(s) bouton(s) à lier.",
		LabelButtonsAllowed = "Boutons autorisés",
		PromptEditControllerTitle = "Entrées manette",
		PromptEditControllerDesc = "Modifier les boutons GBA du tracker. Boutons disponibles : A, B, L, R, Start, Select",
		PromptEditControllerLoadNext = "Charger la prochaine graine",
		PromptEditControllerToggleView = "Basculer la vue",
		PromptEditControllerInfoShortcut = "Dresseurs / Pivots",
		PromptEditControllerCycleStats = "Parcourir les stats",
		PromptEditControllerMarkStat = "Marquer la stat",
		PromptEditControllerNextPage = "Page suivante",
		PromptEditControllerPreviousPage = "Page précédente",
		PromptEditControllerResetDefault = "Par défaut",
	},
	ExtrasScreen = {
		Title = "Extras",
		TabTools = "Outils",
		TabOptions = "Options",
		ButtonViewLogs = "Journaux",
		ButtonCoverageCalculator = "Couverture",
		ButtonGachaMonCollection = "GachaMon",
		ButtonTimeMachine = "Machine du temps",
		ButtonCrashRecovery = "Récup. crash",
		LabelTimer = "Options du chronomètre",
		ButtonEditTime = "Modifier",
		ButtonRelocateTime = "Déplacer",
		OptionDisplayRepelUsage = "Afficher l'usage des Repels",
		OptionDisplayPedometer = "Afficher le podomètre",
		OptionDisplayPlayTime = "Afficher le temps de jeu",
		OptionDisplayGender = "Afficher le sexe du Pokémon",
		OptionAnimatedPokemonPopout = "Popout Pokémon animé",
		ButtonEstimatePokemonIVs = "Estimer IV Pokémon",
		EstimateResultOutstanding = "Exceptionnel !",
		EstimateResultQuiteImpressive = "Très impressionnant !",
		EstimateResultAboveAverage = "Au-dessus de la moyenne !",
		EstimateResultDecent = "Correct.",
		EstimateResultUnavailable = "Estimation indisponible.",
		TimerPauseTip = "(Cliquez sur le chrono pour mettre en pause)",
	},
	GameOptionsScreen = {
		Title = "Options jeu",
		TabBattle = "Combat",
		TabGameOver = "Défaite",
		TabOther = "Autres",
		ButtonGameStats = "Stats partie",
		LabelGameOverCondition = "Partie perdue si",
		OptionAutoSwapEnemy = "Swap ennemi auto",
		OptionCanClickTrainers = "Cliquer dresseurs",
		OptionShowStarterBallInfo = "Infos balles départ",
		OptionHideStatsUntilSummary = "Masquer stats avant résumé",
		OptionShowNicknames = "Surnoms",
		OptionShowExpBar = "Barre XP",
		OptionShowHealsAsValue = "Soins en valeurs",
		OptionShowPhysicalSpecial = "Phys./Spéc.",
		OptionShowMoveEffectiveness = "Efficacité",
		OptionCalculateVariableDamage = "Dégâts vars",
		OptionDetermineFriendship = "Amitié",
		OptionShowVanillaGameData = "Données vanilla",
		OptionShowBallCatchRate = "Taux capture",
		OptionCountEnemyPP = "PP ennemis",
		OptionShowLastDamage = "Dégâts récents",
		OptionRevealRandomizedInfo = "Infos random",
		OptionLeadPokemonFaints = "Tête KO",
		OptionHighestLevelFaints = "Plus haut niv. KO",
		OptionEntirePartyFaints = "Équipe KO",
		OptionOpenBookPlayMode = "Mode Open Book",
		LabelExtraTimeWarning = "Peut rallonger le chargement",
	},
	QuickloadScreen = {
		Title = "Nouv. parties",
		TabGeneral = "Général",
		TabProfiles = "Profils",
		TabOptions = "Options",
		NewRunsDescGenerate = "Le tracker créera une NOUVELLE ROM randomisée lorsque la combinaison de boutons est pressée.",
		NewRunsDescPremade = "Le tracker chargera la prochaine ROM numérotée lorsque la combinaison de boutons est pressée.",
		LabelActiveProfile = "Profil actif",
		LabelNoActiveProfile = "Aucun profil actif",
		LabelClickToAdd = "cliquez pour ajouter",
		LabelProfileAttempts = "Tentatives",
		LabelProfileLastPlayed = "Dern. partie",
		ButtonLoadLastGame = "Dern. partie",
		ButtonGoNextSeed = "Suivant",
		ButtonCreateNewGame = "Créer partie",
		ButtonAddNew = "Ajouter",
		ButtonSelectProfile = "Sélectionner",
		ButtonEditProfile = "Edit",
		ButtonDeleteProfile = "Suppr.",
		OptionWarnRomMismatch = "Détecter ROM différente",
		OptionRefocusEmulator = "Au chargement : recentrer BizHawk",
	},
	ThemeScreen = {
		Title = "Bibliothèque de thèmes",
		HeaderActiveThemeOptions = "Options du thème actif",
		LabelDefaultTheme = "Thème par défaut",
		LabelActiveCustomTheme = "Thème actif (personnalisé)",
		ButtonApplyTheme = "Appliquer",
		ButtonSaveAsNew = "Enregistrer",
		ButtonRemove = "Supprimer",
		ButtonRemoveConfirm = "Êtes-vous sûr ?",
		ButtonImport = "Importer",
		ButtonExport = "Exporter",
		PromptEnterThemeCode = "Entrez un code de thème à importer (Ctrl+V pour coller)",
		PromptImportError = "Erreur d'import : code de thème invalide.",
		PromptThemeFor = "Thème pour",
		PromptCopyThemeCode = "Copiez le code de thème ci-dessous (Ctrl+C)",
		PromptSelectPreset = "Sélectionnez un preset de thème à prévisualiser",
		PromptSaveAsTitle = "Enregistrer le thème sous",
		PromptEnterNameForTheme = "Entrez un nom pour ce thème",
		PromptCantUseReserved = "Impossible d'utiliser un nom de thème réservé.",
		PromptCantUseConsecutiveChars = "Le nom ne peut pas contenir 6 caractères hex consécutifs (0-9A-F)",
		PromptNameAlreadyInUse = "Un thème avec ce nom existe déjà. Écraser ?",
		OptionColorStatNumber = "Colorer les stats selon la nature ",
		OptionColorBar = "Barre de couleur des types",
		OptionTextShadows = "Ombres de texte",
		ButtonEditColors = "Modifier couleurs",
		TitleEditingActiveTheme = "Édition du thème actif",
		ColorDefaultText = "Texte boîte haute",
		ColorLowerBoxText = "Texte boîte basse",
		ColorPositiveText = "Texte positif",
		ColorNegativeText = "Texte négatif",
		ColorIntermediateText = "Texte intermédiaire",
		ColorHeaderText = "Texte d'en-tête",
		ColorUpperBoxBorder = "Bordure boîte haute",
		ColorUpperBoxBackground = "Fond boîte haute",
		ColorLowerBoxBorder = "Bordure boîte basse",
		ColorLowerBoxBackground = "Fond boîte basse",
		ColorMainBackground = "Fond principal",
		PromptColorPickerTitle = "Sélecteur de couleur",
		PromptColorPickerHexColor = "Couleur hex",
	},
	LanguageScreen = {
		Title = "Paramètres de langue",
		DisplayLanguage = "Langue d'affichage",
		AutodetectSetting = "Détection auto de la langue",
		ButtonHelpContribute = "Aider à traduire",
	},
	StatsScreen = {
		Title = "Stats de partie",
		StatPlayTime = "Temps de jeu",
		StatTotalAttempts = "Tentatives totales",
		StatPCsUsed = "Pokécenters utilisés",
		StatTrainerBattles = "Combats de dresseurs",
		StatWildEncounters = "Rencontres sauvages",
		StatPokemonCaught = "Pokémon capturés",
		StatShopPurchases = "Achats en boutique",
		StatGameSaves = "Sauvegardes du jeu",
		StatTotalSteps = "Pas totaux",
		StatStrugglesUsed = "Luttes utilisées",
	},
	UpdateScreen = {
		Title = "Mise à jour du tracker",
		VersionCurrent = "Version actuelle",
		VersionLatest = "Dernière version",
		LabelRelease = "Notes de version",
		VersionNew = "Nouveau !",
		ButtonShow = "Voir",
		ButtonHide = "Masquer",
		ButtonViewOnline = "Voir en ligne",
		CheckboxDevBranch = "Utiliser les versions bêta",
		ButtonCheckForUpdates = "Vérifier les mises à jour",
		ButtonNoUpdates = "Aucune mise à jour disponible",
		ButtonBeginInstall = "Démarrer l'installation",
		ButtonInstallNow = "Installer maintenant",
		ButtonInstallFromDev = "Installer depuis la branche bêta",
		ButtonOpenDownload = "Ouvrir le téléchargement",
		ButtonIgnoreUpdate = "Ignorer la mise à jour",
		MessageInProgress = "Mise à jour en cours, veuillez patienter. Vérifiez la fenêtre de commande pour le statut.",
		MessageRequireRestart = "Pour installer la mise à jour, veuillez fermer puis rouvrir votre émulateur.",
		MessageError = "Erreur pendant la mise à jour. Pour corriger, redémarrez d'abord votre émulateur puis rechargez le script",
		MessageCheckConsole = "Consultez la console Lua pour le lien vers les notes de version du tracker",
	},
	StreamerScreen = {
		Title = "Outils streamer",
		ButtonEdit = "Edit.",
		ButtonStreamConnect = "Conn. Stream",
		LabelAttemptsCount = "Compteur de tentatives",
		LabelWelcomeMessage = "Message d'accueil",
		LabelFavorites = "Pokémon favoris",
		OptionDisplayFavorites = "Montrer à une nouvelle partie",
		PromptEditAttemptsTitle = "Modifier le compteur de tentatives",
		PromptEditAttemptsDesc = "Saisissez le nombre de tentatives",
		PromptEditWelcomeTitle = "Modifier le message d'accueil",
		PromptEditWelcomeDesc = "Modifier le message d'accueil du Tracker affiché au début de chaque nouvelle partie.",
		PromptChooseFavoriteTitle = "Choisir un favori",
		PromptChooseFavoriteDesc = "Les Pokémon favoris sont affichés au début d'une nouvelle partie.",
	},
	InfoScreen = {
		-- Pokémon Info
		ButtonViewEvos = "Voir...",
		ButtonHistory = "Histo.",
		ButtonResistances = "Voir résistances",
		ExpYield = "EXP",
		KilogramAbbreviation = "kg",
		LabelWeight = "Poids",
		LabelEvolution = "Évolution",
		LabelLearnMove = "Attaque par niveau",
		LabelNoMoves = "N'apprend aucune attaque",
		LabelWeakTo = "Faible à",
		LabelNoWeaknesses = "N'a aucune faiblesse",
		PromptLookupPokemon = "Choisissez un Pokémon à consulter",
		-- Move Info
		LabelCategory = "Catégorie",
		LabelContact = "Contact",
		LabelPP = "PP",
		LabelPower = "Puissance",
		LabelAccuracy = "Précision",
		LabelPriority = "Priorité",
		LabelMoveSummary = "Résumé de l'attaque",
		SetHiddenPowerType = "Définir le type",
		PromptLookupMove = "Choisissez une attaque à consulter",
		-- Ability Info
		LabelEmeraldAbility = "Dans Émeraude",
		PromptLookupAbility = "Choisissez un talent à consulter",
		-- Route Info
		CheckboxPercentages = "Pourcentages",
		CheckboxLevels = "Niveaux",
		LabelSeenBy = "Pokémon vus via",
		LabelSeenEncounters = "Rencontres Pokémon",
		LabelOrderAppearance = "Par ordre d'apparition",
		PromptLookupRoute = "Choisissez une route à consulter",
	},
	NotebookIndexScreen = {
		Title = "Carnet du tracker",
		LabelReviewDescription = "Consulter les notes de la partie",
		LabelPokemonSeen = "Pokémon vus",
		LabelTrainersFought = "Dresseurs vaincus",
	},
	NotebookPokemonSeen = {
		Title = "Tous les Pokémon vus",
		LabelAll = "Tous",
		LabelSeen = "Vus",
	},
	NotebookPokemonNoteView = {
		HeaderMoveHistory = "Historique des attaques",
	},
	NotebookTrainersByArea = {
		Title = "Tous les dresseurs par zone",
		CheckboxShowCompleted = "Afficher complétés",
		CheckboxSevii = "Sevii",
	},
	TrainerInfoScreen = {
		LabelAvgIvs = "IV moy.",
		LabelAIScript = "Script IA",
		LabelUsableItems = "Objets utilisables",
		LabelDouble = "Double",
		LabelBattle = "Combat !",
	},
	CustomExtensionsScreen = {
		Title = "Extensions",
		TabGeneral = "Général",
		TabExtensions = "Extensions",
		TabOptions = "Options",
		LabelTotalInstalled = "Total installées",
		LabelExtensionsEnabled = "Extensions activées",
		ButtonUpdateAllExtensions = "Màj exts",
		ButtonFindMoreExtensions = "Plus d'exts",
		ButtonInstallNewExtension = "Installer ext.",
		OptionAllowCustomCode = "Exécution du code personnalisé",
	},
	SingleExtensionScreen = {
		LabelAuthorBy = "Par",
		LabelVersion = "Version",
		LabelEnabled = "Activée",
		EnabledOn = "OUI",
		EnabledOff = "NON",
		ButtonViewOnline = "Voir en ligne",
		ButtonOptions = "Options",
		ButtonCheckForUpdates = "Rechercher des mises a jour",
		ButtonUpdateAvailable = "Mise a jour disponible",
		ButtonNoUpdateFound = "Aucune mise a jour trouvée",
	},
	TrackedDataScreen = {
		Title = "Données",
		DescAutoSave = "Données sauvegardées après combat (.TDAT).",
		DescManualSave = "Nouvelle partie : anciennes données perdues. Pour les garder, utilisez Sauv.",
		OptionAutoSaveData = "Sauv. auto des données",
		ButtonSaveData = "Sauv.",
		ButtonLoadData = "Charger",
		ButtonClearData = "Effacer",
		ButtonClearConfirm = "Êtes-vous sûr ?",
		ButtonClearSuccess = "Données effacées !",
		PromptHeaderSave = "Sauvegarder les données du Tracker",
		PromptEnterFilename = "Saisissez un nom de fichier pour sauvegarder les données du Tracker",
	},
	ViewLogWarningScreen = {
		Title = "Voir le log ?",
		ButtonViewCurrentLog = "Voir log",
		ButtonViewPreviousLog = "Log préc.",
		WarningAreYouSure = "Voulez-vous vraiment consulter le fichier log ?",
		WarningSpiritOfIronmon = "En Ironmon, consulter des infos du log avant la fin de la partie va à l'encontre de l'esprit du défi.",
		WarningIfUnsure = "En cas de doute, n'ouvrez simplement pas le fichier log.",
	},
	CoverageCalcScreen = {
		Title = "Calculateur de couverture",
		ButtonAddType = "Ajouter type",
		ButtonClearTypes = "Tout effacer",
		ButtonPokemonMatchups = "Matchups Pokémon",
		OptionFullyEvolvedOnly = "Pokémon totalement évolué",
		TitleAddMoveType = "Ajouter type d'attaque",
		LabelTotal = "Total",
	},
	TimeMachineScreen = {
		Title = "Machine temporelle",
		OptionEnableRestorePoints = "Activer les pts de restauration",
		DescInstructions = "Coisissez un point de restauration",
		DescNoRestorePoints = "Aucun point de restauration disponible ; un point est créé toutes les 5 minutes.",
		RestorePointAgeSingular = "créé il y a 1 minute",
		RestorePointAgePlural = "créé il y a %s minutes",
		UndoAndReturnBack = "Retour vers le futur",
		ConfirmationRestore = "Confirmer la restauration ?",
		LocationUnknownArea = "Zone inconnue",
		ButtonCreate = "Créer",
	},
	CrashRecoveryScreen = {
		Title = "Récupération après crash",
		StatusMessageCrash = "Crash détecté",
		StatusMessageNoCrash = "Aucun crash détecté",
		ButtonRecoverSave = "Restauration",
		ButtonUndoRecovery = "Annuler la récupération",
		ButtonDismiss = "Fermer",
		LastPlayedGame = "Dernier jeu joué",
		SameGameAsLast = "Même version de jeu",
		SameRomAsLast = "Exactement la même ROM",
		NotAvailable = "(Indisponible)",
		OptionEnableCrashRecovery = "Récupération après crash",
	},
	GameOverScreen = {
		Title = "Fin de partie",
		LabelAttempt = "Tentative",
		LabelPlayTime = "Temps de jeu",
		ButtonViewGrade = "Voir",
		QuoteCongratulations = "FÉLICITATIONS !",
		ButtonContinuePlaying = "Continuer à jouer",
		ButtonRetryBattle = "Recommencer combat",
		ButtonRetryBattleConfirm = "Êtes-vous sûr ?",
		ButtonSaveAttempt = "Sauv. dernière tentative",
		ButtonSaveSuccessful = "Sauvegardé dans le dossier Tracker",
		ButtonSaveFailed = "Impossible de sauvegarder",
		ButtonGradeMyNotes = "Noter mes notes",
		ButtonInspectLogFile = "Inspecter le log",
		ButtonOpenLogFile = "Ouvrir un fichier log",
		ButtonViewLogSmall = "Voir le log",
		ButtonPrizeCard = "Carte",
	},
	StatMarkingScoreSheet = {
		Title = "Feuille de score de marquage des stats",
		LabelGreatMarks = "Bons marquages",
		LabelPoorMarks = "Mauvais marquages",
		LabelTotal = "Total",
		LabelPercentage = "Pourcentage",
		MessageTakeNotesByMarking = "Prenez des notes en jeu en marquant les stats des Pokémon adverses. (La stat Vitesse est exclue de la notation.)",
	},
	RandomEvosScreen = {
		LabelRandomEvos = "Evos aléatoires",
		LabelEvoShort = "Evo",
	},
	HealsInBagScreen = {
		TabAll = "Tout",
		TabHP = "PV",
		TabPP = "PP",
		TabStatus = "Statut",
		TabBattle = "Combat",
	},
	MoveHistoryScreen = {
		HeaderMoves = "Vu au niveau",
		HeaderMin = "Min",
		HeaderMax = "Max",
		NoTrackedMoves = "(Aucune donnée d'attaque suivie pour l'instant)",
		NoMovesLearned = "N'apprend aucune attaque",
		PromptPokemonTitle = "Recherche Pokédex",
		PromptPokemonDesc = "Choisissez un Pokémon a rechercher",
	},
	CatchRatesScreen = {
		Title = "Taux de capture des Balls",
		PokemonsHPPercent = "PV estimés",
		PokemonsStatus = "Statut",
		HeaderBall = "Ball",
		HeaderBag = "Sac",
		HeaderRate = "Taux",
	},
	TypeDefensesScreen = {
		Immunities = "Immunités",
		Resistances = "Résistances",
		Weaknesses = "Faiblesses",
	},
	BattleDetailsScreen = {
		Title = "Détails du combat",
		TextTurn = "Tour",
		TextTerrain = "Terrain",
		TextWeather = "Météo",
		TextWeatherTurns = "Tours de météo",
		TextAllied = "Allié",
		TextEnemy = "Adverse",
		TextTeam = "Equipe",
		TextField = "Effets de terrain",
		TextTurnsRemaining = "Restants",
		TextLastMove = "Dernière attaque",
		TextNotAvailable ="N/D",

		WeatherDefault = "Aucune",
		WeatherRain = "Pluie",
		WeatherSandstorm = "Tempete de sable",
		WeatherSunlight =  "Soleil",
		WeatherHail =  "Grêle",
		TerrainDefault = "Bâtiment",
		TerrainGrass = "Herbe",
		TerrainLongGrass = "Hautes herbes",
		TerrainSand = "Sable",
		TerrainUnderwater = "Sous l'eau",
		TerrainWater = "Eau",
		TerrainPond = "Etang",
		TerrainMountain = "Montagne",
		TerrainCave = "Grotte",

		EffectConfused = "Confus",
		EffectMustAttack = "Doit attaquer",
		EffectTrapped = "Piégé",
		EffectCannotAct = "Recharge",
		EffectAirborne = "En l'air",
		EffectUnderground = "Sous terre",
		EffectUnderwater = "Sous l'eau",
		EffectDrowsy = "Somnolent",
		EffectProtectUses = "Utilisations de Protection",
		EffectPerishCount = "Compteur Requiem",
		EffectCannotEscape = "Ne peut pas fuir",
		EffectTruant = "Paresse",
		EffectFutureSight = "Prescience",
	},
	LogOverlay = { -- Log Viewer
		HeaderTabPokemon = "Pokémon",
		HeaderTabTrainers = "Dresseurs",
		HeaderTabRoutes = "Routes",
		HeaderTabTMs = "CT",
		HeaderTabMisc = "Divers",
		LabelBaseStats = "Stats de base",
		LabelBSTTotal = "Total",
		LabelYourIVs = "Vos IV",
		LabelYourEVs = "Vos EV",
		LabelShowIVs = "Afficher IV",
		LabelShowEVs = "Afficher EV",
		LabelShowBST = "Afficher BST",
		ButtonLevelupMoves = "Par Niveau",
		ButtonTMMoves = "Par CT",
		LabelGymTMs = "CT d'arène",
		LabelOtherTMs = "Autres CT",
		LabelFilterBy = "Filtrer par",
		FilterAll = "Tous",
		FilterRival = "Rival",
		FilterGym = "Arène",
		FilterElite4 = "Elite 4",
		FilterBoss = "Boss",
		FilterOther = "Autres",
		LabelLocation = "Lieu",
		LabelEncounters = "Rencontres",
		TabTrainers = "Dresseurs",
		TabGrassCave = "Herbe / Grotte",
		TabSurfing = "Surf",
		TabOldRod = "Canne",
		TabGoodRod = "Bonne Canne",
		TabSuperRod = "Super Canne",
		TabRockSmash = "Éclate-Roc",
		FilterTMNumber = "CT #",
		FilterGymTMs = "CT d'arène",
		LabelPokemonGame = "Jeu Pokémon",
		LabelRandomizerVersion = "Version du randomizer",
		LabelRandomSeed = "Seed aléatoire",
		LabelSettingsString = "Chaîne de paramètres",
		ButtonShareSeed = "Partager la seed",
		CheckboxShowUnlearnableGymTMs = "Afficher les CT d'arène non apprenables",
		CheckboxShowPreEvolutions = "Afficher les pré-évolutions",
		CheckboxCustomTrainerNames = "Noms de dresseurs personnalisés",
		PromptShareSeedTitle = "Partager la seed randomizer",
		PromptShareSeedDesc = "Copiez/collez ce qui suit pour partager. Chargez-le via Randomizer --> Premade Seed.",
	},
	LogSearchScreen = {
		Title = "Rechercher dans le log",
		LabelSortBy = "Trier par",
		LabelSearch = "Rechercher",
		LabelNoResults = "Aucun résultat",
		SortAlphabetical = "Alphabétique",
		SortPokedexNum = "Numéro Pokédex",
		SortBST = "BST",
		SortHP = "PV",
		SortATK = "Attaque",
		SortDEF = "Défense",
		SortSPA = "Atk. Spe.",
		SortSPD = "Def. Spe.",
		SortSPE = "Vitesse",
		SortWildPokemonLv = "Niv. Pokémon sauvage",
		SortTrainerLevel = "Niveau du dresseur",
		FilterName = "Nom du Pokémon",
		FilterAbility = "Talent",
		FilterMove = "Attaque par niveau",
		FilterTrainerName = "Nom du dresseur",
		FilterRouteName = "Nom de la route",
	},
	GachaMonAnimations = {
		LabelPrizeCardFromTrainer = "Carte récompense d'un dresseur",
		LabelTabNEW = "NOUVEAU",
		LabelPressBUTTONtoOpen = "Appuyez sur (%s) ou cliquez pour ouvrir"
	},
	GachaMonOverlay = {
		TabRecent = "Captures",
		TabCollection = "Collection",
		TabView = "Vue",
		TabGachaDex = "GachaDex",
		TabBattle = "Combat",
		TabOptions = "Options",
		TabAbout = "?",

		-- Recent/Captures Tab & Collections Tabs
		RecentCapturesHelpText1 = "GachaMon capturés dans cette partie",
		RecentCapturesHelpText2 = "Cliquez sur [Ajouter] pour les conserver",
		LabelSort = "Tri",

		-- View Tab
		LabelRating = "Note",
		WordPoints = "points",
		WordStars = "étoiles",
		LabelBattlePower = "Puis. Combat",
		BattlePowerAbbreviation = "BP",
		LabelCollectedOn = "Collecté le",
		LabelSeed = "Seed",
		LabelStats = "Stats",
		ButtonBattle = "Combat",
		ButtonFavorite = "Favori",
		ButtonInCollection = "Dans la collection",
		ButtonAddToCollection = "Ajouter",

		-- GachaDex Tab
		LabelSeen = "Vus",
		LabelCollAbbreviation = "Coll.",

		-- Battle Tab

		-- Options Tab
		LabelOnCaptureHeader = "Quand un nouveau GachaMon est capturé, l'ajouter si",
		LabelRulesetForRatings = "Règles pour les notes",
		LabelTagAuto = "Auto",
		LabelCollectionSize = "GachaMon dans la collection",
		OptionAutoAddIfNew = "C'est une nouvelle espèce de Pokémon",
		OptionAutoAddWhenDefeatTrainers = "Il bat au moins 2 dresseurs",
		OptionShowGachaMonStarsOnTracker = "Afficher les étoiles près des soins",
		OptionShowCardPackOnScreen = "Afficher le pack avant les stats",
		OptionAnimateGachaMonPackOpening = "Animer l'ouverture du pack",
		OptionAutoAddFromTrainerVictory = "Recevoir des cartes de dresseurs",
		ButtonCleanupCollection = "Nettoyer collec.",

		-- About Tab
		GachaMonGameHeader = "GachaMon  Collectable  Card  Game",
		GachaMonGameDescription = "Jouez à IronMON, collectez les cartes GachaMon !",
		SectionHowItWorks = "Comment ça marche",
		LabelCatchPokemon = "Capturez des Pokémon",
		LabelAcquireGachaMonCards = "Obtenez des cartes GachaMon",
		LabelKeepCardsInCollection = "Conservez les cartes dans votre collection",
		LabelBattle = "Combat ! (bientôt)",
		SectionWhatsOnCard = "Contenu d'une carte",
		LabelStarsAndRating = "Etoiles: note du Pokémon (1-5)",
		LabelBattlePowerAndStrength = "Puissance combat: force en duel",
		ButtonHelpWiki = "Aide",
		MessageCheckConsole = "Consultez la console Lua pour le wiki GachaMon.",
	},
	TeamViewArea = {
		EggNickname = "OEUF",
	},
	CustomCode = {
		ExtensionsLoaded = "Extensions chargées",
		ExtensionsMissing = "Extensions manquantes",
	},
	StreamConnect = {
		-- THE BELOW EVENTS NEED TRANSLATION
		CMD_Pokemon_Name = "Pokémon Info",
		CMD_Pokemon_Help = "name > Affiche des infos utiles du jeu pour un Pokémon.",
		CMD_BST_Name = "Pokémon BST",
		CMD_BST_Help = "name > Affiche le total des stats de base (BST) d'un Pokémon.",
		CMD_Weak_Name = "Faiblesses Pokémon",
		CMD_Weak_Help = "name > Affiche les faiblesses d'un Pokémon.",
		CMD_Move_Name = "Infos attaque",
		CMD_Move_Help = "name > Affiche les infos du jeu pour une attaque.",
		CMD_Ability_Name = "Infos talent",
		CMD_Ability_Help = "name > Affiche les infos du jeu pour un talent Pokémon.",
		CMD_Trainer_Name = "Infos dresseur",
		CMD_Trainer_Help = "[name id] > Affiche les infos du dernier dresseur combattu, ou d'un dresseur précis selon son nom ou son id.",
		CMD_Route_Name = "Infos route",
		CMD_Route_Help = "name > Affiche les infos sur les dresseurs et les rencontres sauvages d'une route ou d'une zone.",
		CMD_Dungeon_Name = "Infos donjon",
		CMD_Dungeon_Help = "name > Affiche les infos sur les dresseurs vaincus dans une zone.",
		CMD_Unfought_Name = "Dresseurs invaincus",
		CMD_Unfought_Help = "[dungeon] [no doubles] [sevii] > Liste les zones triées par dresseurs invaincus de plus bas niveau. (Ajoutez 'dungeon' pour les donjons partiellement complétés et/ou 'nodoubles' pour exclure les combats en double.)",
		CMD_Pivots_Name = "Pivots vus",
		CMD_Pivots_Help = "[safari] > Affiche les rencontres sauvages connues du début de partie pour une zone. (Ajoutez 'safari' pour les rencontres de haut niveau du Safari).",
		CMD_Revo_Name = "Évolutions random Pokémon",
		CMD_Revo_Help = "name [target-evo] > Affiche les possibilités d'évolution random d'un Pokémon, ainsi que son [target-evo] s'il y en a plusieurs.",
		CMD_Coverage_Name = "Efficacité de couverture",
		CMD_Coverage_Help = "types [fully evolved] > Pour une liste de types d'attaque, vérifie tous les matchups Pokémon (ou seulement [fully evolved]) selon leur efficacité.",
		CMD_Heals_Name = "Soins dans le sac",
		CMD_Heals_Help = "[hp pp status berries] > Affiche tous les objets de soin du sac, ou seulement ceux d'une [catégorie] précise.",
		CMD_TMs_Name = "Recherche CT",
		CMD_TMs_Help = "[gym hm #] > Affiche toutes les CT du sac, ou seulement celles d'une [catégorie] précise ou d'une CT #.",
		CMD_Search_Name = "Rechercher infos suivies",
		CMD_Search_Help = "searchterms > Recherche des infos suivies pour un Pokémon, une attaque ou un talent.",
		CMD_SearchNotes_Name = "Rechercher notes Pokémon",
		CMD_SearchNotes_Help = "notes > Affiche la liste des Pokémon ayant des notes correspondantes.",
		CMD_Favorites_Name = "Starters favoris",
		CMD_Favorites_Help = "> Affiche la liste des favoris utilisés pour choisir un starter.",
		CMD_Theme_Name = "Export thème",
		CMD_Theme_Help = "name > Affiche le nom et le code d'un thème Tracker.",
		CMD_GameStats_Name = "Stats de partie",
		CMD_GameStats_Help = "> Affiche quelques stats amusantes sur la partie actuelle.",
		CMD_Progress_Name = "Progression de partie",
		CMD_Progress_Help = "> Affiche des pourcentages de progression de la partie actuelle.",
		CMD_Log_Name = "Paramètres randomizer du log",
		CMD_Log_Help = "> Si le log est ouvert, affiche des paramètres randomizer partageables pour la partie actuelle.",
		CMD_BallQueue_Name = "File des balls",
		CMD_BallQueue_Help = "> Affiche la taille de la file de balls et le choix actuel, s'il y en a un.",
		CMD_GachaMon_Name = "Infos GachaMon",
		CMD_GachaMon_Help = "[current name] > Affiche les infos de carte GachaMon du Pokémon actuellement affiché ou d'un Pokémon nommé.",
		CMD_GachaDex_Name = "Infos GachaDex",
		CMD_GachaDex_Help = "> Affiche les infos de collecte et les stats du GachaDex.",
		CMD_About_Name = "À propos du Tracker",
		CMD_About_Help = "> Affiche des infos sur l'Ironmon Tracker et la partie en cours.",
		CMD_Help_Name = "Aide commande",
		CMD_Help_Help = "[command] > Affiche la liste de toutes les commandes, ou l'aide d'une [command] précise.",
		CR_PickBallOnce_Name = "Pick Starter Ball (One Try)",
		CR_PickBallUntilOut_Name = "Pick Starter Ball (Until Out)",
		CR_ChangeFavorite_Name = "Change Starter Favorite: # NAME",
		CR_ChangeFavoriteOne_Name = "Change Starter Favorite: #1",
		CR_ChangeFavoriteTwo_Name = "Change Starter Favorite: #2",
		CR_ChangeFavoriteThree_Name = "Change Starter Favorite: #3",
		CR_ChangeTheme_Name = "Change Tracker Theme",
		CR_ChangeLanguage_Name = "Change Tracker Language",
		GE_GameOver_Name = "Quand la partie est terminée...",
		GE_GameOver_TriggerEffect = "Envoie le statut victoire/défaite et l'ID Pokémon",
		GE_GachaMonCapture_Name = "Quand un GachaMon est capturé...",
		GE_GachaMonCapture_TriggerEffect = "Envoie son code de partage base64",
		O_SendMessage = "Message si succès",
		O_AutoComplete = "Auto-compléter le redeem",
		O_RequireChosenMon = "La direction choisie doit correspondre",
		O_WordForLeft = "Mot pour gauche",
		O_WordForMiddle = "Mot pour milieu",
		O_WordForRight = "Mot pour droite",
		O_WordForRandom = "Mot pour aléatoire",
		O_ShowBallQueueOnStartup = "Afficher la file de balls au démarrage",
		-- THE BELOW SCREEN LABELS NEED TRANSLATION
		TabCommands = "Commandes",
		TabRewards = "Récompenses",
		TabQueue = "File",
		TabGame = "Jeu",
		TabStatus = "Statut",
		ButtonRolePermissions = "Perm. rôles",
		ButtonRename = "Renommer",
		ButtonOptions = "Options",
		ButtonAdd = "Ajouter",
		ButtonChange = "Changer",
		ButtonQueueAreYouSure = "Êtes-vous sûr ?",
		ButtonQueueClearAll = "Tout effacer",
		ButtonQueueConfirm = "Confirmer ?",
		ButtonConnect = "Connecter",
		ButtonDisconnect = "Déconnecter",
		ButtonSet = "Def.",
		ButtonGetStreamerbotCode = "Code Streamerbot",
		ButtonHelp = "Aide",
		LabelWaitingForConnection = "(En attente...)",
		LabelNoRewardsInQueue = "Aucune récompense en attente.",
		LabelNoGameEvents = "Aucun déclencheur d'événement de jeu ajouté.",
		LabelHowToAddGameEvents = "Ajoutez des déclencheurs via des extensions Tracker personnalisées.",
		LabelConnectionStatus = "Statut connexion",
		LabelOnlineEstablished = "En ligne : connexion établie.",
		LabelOnlineWaiting = "En ligne : en attente de connexion...",
		LabelOffline = "Hors ligne.",
		LabelSettings = "Paramètres",
		LabelConnectionMode = "Mode connexion",
		LabelConnectionFolder = "Dossier connexion",
		LabelImportCode = "Code import",
		LabelServerIP = "IP serveur",
		LabelServerPort = "Port",
		LabelHttpGet = "GET",
		LabelHttpPost = "POST",
		WarningSetupImport = "Config. : importez le code puis définissez le dossier",
		WarningNotSupported = "Mode non pris en charge par BizHawk.",
		StatusConnTypeText = "Texte",
		StatusConnTypeWebSockets = "WebSockets",
		StatusConnTypeHttp = "HTTP",
		OptionAutoConnectStartup = "Connexion auto au démarrage",
		PromptUpdateTitle = "Mise à jour Streamerbot requise",
		PromptUpdateDesc1 = "Le code d'intégration Streamerbot Tracker nécessite une mise à jour.",
		PromptUpdateDesc2 = "Vous devez réimporter le code pour continuer avec Stream Connect.",
		PromptNetworkShowMe = "Montrer",
		PromptNetworkTurnOff = "Désactiver Stream Connect",
		PromptDefault = "Par défaut",
	},
	MGBA = {
		MenuTrackerSettings = "Paramètres du Tracker",
		MenuGeneralSetup = "Configuration générale",
		MenuGameplayOptions = "Options de gameplay",
		MenuQuickloadSetup = "Configuration des nouvelles parties",
		MenuCheckForUpdates = "Rechercher des mises à jour",
		MenuNewUpdateVailable = "Nouvelle mise à jour disponible",
		MenuLanguage = "Langue",
		MenuExtensions = "Extensions",
		MenuCommands = "Commandes",
		MenuBasicCommands = "Commandes de base",
		MenuAdvancedCommands = "Commandes avancées",
		MenuOtherCommands = "Autres commandes",
		MenuInfoLookup = "Recherche d'infos",
		MenuPokemon = "Pokémon",
		MenuMove = "Attaque",
		MenuAbility = "Talent",
		MenuRoute = "Route",
		MenuOriginalRoute = "Infos de route d'origine",
		MenuGameStats = "Stats de partie",
		MenuTracker = "Tracker",
		MenuBattleTracker = "Tracker de combat",
		StartupInstructions = {
			"- Cliquez sur les menus de la barre latérale gauche pour afficher différents écrans d'information.",
			"- Pour utiliser les commandes, tapez la commande dans la zone ci-dessous.",
			"  Entourez les options de commande de guillemets. Exemple :",
			"    POKEMON 'Pikachu'",
			"", -- Leave blank just prints a newline
			"- Si vous ne savez pas à quoi sert une commande, utilisez : HELP 'commande'",
			"- Plus d'informations sont disponibles sur le wiki du Tracker en tapant : HELPWIKI()",
		},
		OptionKeyError = "Clé d'option inexistante",
		OptionFileError = "Fichier introuvable",
		OptionRightJustifiedNumbers = "Nombres à droite",
		OptionShowNicknames = "Surnoms",
		OptionAutosaveTrackedData = "Sauvegarde auto",
		OptionTrackPCHeals = "Soins PC",
		OptionPCHealsCountDownward = "Compter soins PC",
		OptionDisplayPedometer = "Podomètre",
		OptionDisplayRepel = "Repels",
		OptionDisplayGender = "Genre Pokémon",
		OptionAnimatedPokemonGIF = "GIF Pokémon",
		OptionDevBranchUpdates = "Màj beta",
		OptionOverrideButtonModeLR = "Mode boutons LR",
		OptionSwapViewedPokemon = "Permuter Pokémon",
		OptionCycleThroughStats = "Stats cyclées",
		OptionMarkStat = "Marquer stat",
		OptionQuickload = "Nouvelle run",
		OptionAutoswapEnemy = "Swap ennemi auto",
		OptionShowStarterBallInfo = "Infos balles départ",
		OptionViewSummaryForStats = "Résumé stats",
		OptionShowMoveTypes = "Types attaques",
		OptionPhysicalSpecialIcons = "Phys./Spéc.",
		OptionShowMoveEffectiveness = "Efficacité",
		OptionCalculateVariableDamage = "Dégâts vars",
		OptionCountEnemyPP = "PP ennemis",
		OptionShowLastDamage = "Dégâts récents",
		OptionRevealRandomizedInfo = "Infos random",
		OptionShowHealsAsValue = "Soins en valeurs",
		OptionShowBallCatchRate = "Taux capture",
		OptionAutodetectGameLanguage = "Langue jeu auto",
		OptionPremadeRoms = "ROM pré-gén.",
		OptionGenerateRom = "Générer ROM",
		OptionRomsFolder = "Dossier ROM",
		OptionRandomizerJar = "JAR randomizer",
		OptionSourceRom = "ROM source",
		OptionSettingsFile = "Paramètres",
		OptionAllowCustomCode = "Code perso",
		AnimatedPopoutRequired = "L'extension de popout Pokémon animé doit être installée séparément.\n Consultez le wiki du Tracker pour plus de détails de configuration.",
		JarFileRequired = "Un fichier '.jar' est requis; veuillez saisir le chemin complet vers votre fichier JAR du randomizer.",
		GbaFileRequired = "Un fichier '.gba' est requis; veuillez saisir le chemin complet vers votre ROM GBA.",
		RnqsFileRequired = "Un fichier '.rnqs' est requis; veuillez saisir le chemin complet vers votre fichier de paramètres du randomizer.",
		ButtonInputRequired = "Entrée bouton requise; boutons disponibles: A, B, L, R, Start, Select",
	},
	MGBAScreens = {
		SymbolStatus = " ",
		SymbolPhysical = "P",
		SymbolSpecial = "S",
		SymbolEffectivenessImmune = "X",
		SymbolEffectivenessResist = "-",
		SymbolEffectivenessResistDouble = "--",
		SymbolEffectivenessWeak = "+",
		SymbolEffectivenessWeakDouble = "++",
		LabelImmunities = "Immunités",
		LabelResistances = "Résistances",
		LabelWeaknesses = "Faiblesses",
		LabelPhysical = "Physique",
		LabelSpecial = "Spécial",
		LabelStatus = "Statut",
		LabelToggleOption = "Basculer l'option avec",
		LabelOption = "Option",
		LabelEnabled = "Activée",
		GeneralSetupChange = "Modifier avec",
		GeneralSetupButtons = "bouton(s)",
		GeneralSetupControls = "Contrôles",
		GeneralSetupGBAButtons = "Boutons GBA",
		GameplayOptionsManualSave = "Sauvegarder/charger manuellement les données suivies",
		QuickloadDesc = "Pour utiliser une option Charger nouvelle run, placez les fichiers requis dans le dossier [quickload] du dossier principal du Tracker.",
		QuickloadChooseMode = "Choisir un mode avec",
		QuickloadMode = "Mode",
		QuickloadSelected = "Sélectionné",
		QuickloadRequiredFiles = "Fichiers requis",
		QuickloadRequiredFilesOneEach = "Fichiers requis (1 seul de chaque)",
		QuickloadMultipleRoms = "Plusieurs ROM GBA avec des #",
		QuickloadJarFile = "Fichier JAR du randomizer",
		QuickloadRnqsFile = "Fichier RNQS du randomizer",
		QuickloadGbaFile = "ROM GBA à randomiser",
		QuickloadButtonCombo = "Combinaison de boutons",
		QuickloadTextCommand = "Commande texte",
		UpdateAvailable = "Mise à jour disponible !",
		UpdateCurrentVersion = "Version actuelle",
		UpdateLastCheckedVersion = "Dernière version vérifiée",
		UpdateNewVersionAvailable = "Nouvelle version disponible",
		UpdateManualCheck = "Vérifier manuellement les mises à jour",
		UpdateViewReleaseNotes = "Voir les notes de version",
		UpdateDownloadInstall = "Télécharger et installer automatiquement",
		LanguageCurrent = "Langue actuelle",
		LanguageChangeWith = "Changer la langue avec",
		LanguageHeaderTag = "Tag",
		LanguageHeaderLang = "Langue",
		ExtensionsInstallNewWith = "Installer de nouvelles extensions avec",
		ExtensionsInstalledExtensions = "Extensions installées",
		ExtensionsEnableDisable = "Activer/désactiver avec",
		CommandsDesc = "Pour utiliser, tapez dans la zone de texte ci-dessous. Exemple de commande",
		CommandsUsageSyntax = "Syntaxe d'utilisation",
		CommandsExampleUsage = "Exemple d'utilisation",
		PokemonInfoBST = "BST",
		PokemonInfoEXP = "EXP",
		PokemonInfoWeight = "Poids",
		PokemonInfoEvolution = "Evolution",
		PokemonInfoKg = "kg",
		PokemonInfoLevelupMoves = "Attaques par niveau",
		PokemonInfoNone = "Aucun",
		PokemonInfoNote = "Note",
		PokemonInfoLeaveNote = "(Laisser une note)",
		MoveInfoCategory = "Catégorie",
		MoveInfoContact = "Contact",
		MoveInfoPP = "PP",
		MoveInfoPower = "Puissance",
		MoveInfoAccuracy = "Précision",
		MoveInfoPriority = "Priorité",
		MoveInfoSummary = "Résumé attaque",
		MoveInfoEmeraldBonus = "Bonus Emeraude",
		MoveInfoNormalPriority = "Normale",
		RouteInfoUnknownArea = "ZONE INCONNUE",
		RouteInfoTracked = "Suivi",
		RouteInfoOriginal = "Origine",
		RouteInfoSeen = "vu",
		TrackerLevel = "Niv",
		TrackerBST = "BST",
		TrackerHP = "PV",
		TrackerAttack = "ATK",
		TrackerDefense = "DEF",
		TrackerSpAttack = "ATS",
		TrackerSpDefense = "DFS",
		TrackerSpeed = "VIT",
		TrackerCatchRate = "Taux capture",
		TrackerSurvivalPCs = "PC survie",
		TrackerHeals = "Soins",
		TrackerLastSeen = "Dernière vue",
		TrackerNewEncounter = "Nouvelle rencontre !",
		TrackerSeenWild = "Vu à l'état sauvage",
		TrackerSeenTrainers = "Vu chez les dresseurs",
		TrackerTrainerTeam = "Équipe dresseur",
		TrackerBadges = "Badges",
		TrackerRepel = "Repousse",
		TrackerHeaderPP = "PP",
		TrackerHeaderPow = "Puis",
		TrackerHeaderAcc = "Pre",
		TrackerHeaderType = "Type",
	},
	MGBACommands = {
		UsageError = "[Erreur commande] Syntaxe d'utilisation",
		AllCommandsDesc = "Liste toutes les commandes disponibles. Utilisez HELP 'commande' pour en savoir plus sur une commande.",
		HelpDesc = "Explique la fonction des autres commandes et leur utilisation.",
		HelpUsage = "Utilisation",
		HelpExample = "Exemple",
		HelpError1 = "Ou 'commande' est le nom d'une commande.",
		HelpError2 = "Commande introuvable. Vérifiez la liste des commandes dans la barre latérale gauche.",
		NoteDesc = "Définit la note suivie pour le Pokémon adverse actuellement affiché.",
		NoteError1 = "Ou 'texte' est la note à laisser pour le Pokémon adverse affiché.",
		NoteError2 = "Impossible de laisser une note ; aucun Pokémon n'est actuellement affiché.",
		NoteError3 = "Vous pouvez laisser des notes uniquement pour les Pokémon adverses que vous affichez actuellement.",
		NoteSuccess = "Note ajoutée pour",
		InfoLookupSuccess = "trouvé ! Vérifiez le menu latéral pour l'afficher.",
		PokemonDesc = "Recherche des infos Pokédex utiles sur un Pokémon, affichées dans la barre latérale gauche.",
		PokemonError1 = "Ou 'nom' est un nom de Pokémon valide.",
		PokemonError2 = "Impossible de trouver le Pokémon",
		MoveDesc = "Recherche des informations utiles sur une attaque Pokémon, affichées dans la barre latérale gauche.",
		MoveError1 = "Ou 'nom' est un nom d'attaque Pokémon valide.",
		MoveError2 = "Impossible de trouver l'attaque",
		AbilityDesc = "Recherche des informations utiles sur un talent Pokémon, affichées dans la barre latérale gauche.",
		AbilityError1 = "Ou 'nom' est un nom de talent Pokémon valide.",
		AbilityError2 = "Impossible de trouver le talent",
		RouteDesc = "Recherche des informations utiles sur une route, affichées dans la barre latérale gauche.\n Astuce : essayez d'ajouter un numéro d'étage après le nom d'une route, ex. Mt. Moon 1F", -- \n is a newline
		RouteError1 = "Ou 'nom' est un numéro de route valide ou un nom de route valide.",
		RouteError2 = "Impossible de trouver la route",
		OptionDesc = "Active ou désactive une option (ON/OFF).\n Pour certaines options, vous devrez fournir un texte supplémentaire pour la modifier.",
		OptionError1 = "Ou # est un numéro d'option valide, suivi éventuellement d'un texte.",
		OptionSuccess = "Mise à jour de l'option",
		OptionOn = "ON",
		OptionOff = "OFF",
		OptionError2 = "Option inexistante. Veuillez essayer un autre numéro d'option.",
		HiddenPowerDesc = "Définit le type de Puissance Cachée de votre Pokémon actif.\n Cela aide à afficher les calculs d'efficacité des attaques pendant le combat.",
		HiddenPowerError1 = "Ou 'type' est un type Pokémon valide",
		HiddenPowerError2 = "Vous n'avez pas encore de Pokémon.",
		HiddenPowerError3 = "Votre Pokémon n'a pas l'attaque",
		HiddenPowerError4 = "Impossible de trouver le type",
		HiddenPowerSuccess1 = "Type défini sur",
		HiddenPowerSuccess2 = "l'efficacité des attaques est visible sur le Tracker pendant le combat",
		HiddenPowerSuccess3 = "Activez l'option 'Afficher l'efficacité des attaques' pour voir ce type pendant le combat.",
		PCHealsDesc = "Permet de modifier manuellement le compteur d'utilisation des Centres Pokémon suivis.",
		PCHealsError1 = "Ou # est un nombre positif compris entre 0 et 99.",
		PCHealsSuccess = "Mise à jour du nombre de soins PC à",
		CreditsDesc = "Affiche la liste des membres de l'équipe ayant contribué à la création de l'Ironmon Tracker.",
		CreditsCreated = "Créé par",
		CreditsContributors = "Contributeurs",
		SaveDataDesc = "Sauvegarde toutes les données suivies de votre partie actuelle.\n Le fichier de sauvegarde TDAT se trouve dans le dossier principal du Tracker.",
		SaveDataError1 = "Ou 'filename' est un nom de fichier valide.",
		SaveDataSuccess = "Données suivies sauvegardées pour cette partie dans le dossier Tracker sous le nom",
		LoadDataDesc = "Charge les données suivies d'une ancienne partie.\n Charge depuis un fichier TDAT situé dans le dossier principal du Tracker.",
		LoadDataError1 = "Ou 'filename' est le nom d'un fichier existant dans le dossier Tracker.",
		LoadDataError2 = "Les données suivies de ce fichier ne correspondent pas à cette partie. Réinitialisation des données suivies à la place.",
		LoadDataError3 = "Impossible de charger les données suivies depuis ce fichier. Vérifiez qu'il se trouve dans le dossier Tracker.",
		ClearDataDesc = "Efface toutes les données suivies actuelles pour la partie en cours.\n Peut aider à corriger les cas où de mauvaises données continuent de s'afficher.",
		ClearDataSuccess = "Toutes les données suivies de cette partie ont été effacées.",
		CheckUpdateDesc = "Vérifie en ligne si une nouvelle version du Tracker est disponible, affichée dans la barre latérale gauche.",
		CheckUpdateFound = "Mise à jour trouvée ! Consultez le menu latéral pour l'afficher.",
		CheckUpdateNotFound = "Aucune nouvelle mise à jour disponible. Dernière version disponible",
		ReleaseNotesDesc = "Ouvre une fenêtre du navigateur avec les détails des notes de version actuelles.",
		UpdateNowDesc = "Met à jour automatiquement le Tracker en téléchargeant et installant la dernière version.",
		UpdateNowSuccess = "Mise à jour en cours, veuillez patienter...",
		UpdateNowSteps0 = "Suivez ces étapes pour redémarrer le Tracker et appliquer la mise à jour",
		UpdateNowSteps1 = "Terminez d'abord tout combat en cours",
		UpdateNowSteps2 = "Dans la fenêtre de script mGBA : cliquez sur File -> Reset",
		UpdateNowSteps3 = "Cliquez sur File -> Load script (ou Load recent script)",
		QuickloadDesc = "Force le Tracker à charger automatiquement une nouvelle ROM de partie.",
		HelpWikiDesc = "Ouvre une fenêtre du navigateur affichant des pages wiki utiles expliquant les différentes fonctionnalités du Tracker.",
		AttemptsDesc = "Permet de modifier manuellement le compteur de tentatives affiché dans la section Stats.",
		AttemptsError1 = "Ou # est un nombre positif.",
		AttemptsSuccess = "Mise à jour du compteur de tentatives",
		RandomBallDesc = "Choisit aléatoirement une Poké Ball de starter parmi : Gauche, Milieu ou Droite.",
		RandomBallSuccess = "Poké Ball de starter choisie aléatoirement",
		LanguageDesc = "Modifie la langue d'affichage du Tracker.",
		LanguageError1 = "Ou 'language' est le nom ou le # d'une langue. Consultez le menu latéral Langue.",
		LanguageError2 = "Impossible de trouver la langue",
		LanguageSuccess = "La langue d'affichage du Tracker a été mise à jour.",
		InstallExtDesc = "Installe de nouveaux fichiers d'extensions depuis le dossier extensions du Tracker.",
		InstallExtSuccess1 = "De nouvelles extensions ont été installées !",
		InstallExtSuccess2 = "Aucun nouveau fichier d'extension trouvé dans le dossier extensions du Tracker.",
	},
}

GameResources{
	PokemonTypes = {
		normal = "Normal",
		fighting = "Combat",
		flying = "Vol",
		poison = "Poison",
		ground = "Sol",
		rock = "Roche",
		bug = "Insecte",
		ghost = "Spectre",
		steel = "Acier",
		fire = "Feu",
		water = "Eau",
		grass = "Plante",
		electric = "Électrik",
		psychic = "Psy",
		ice = "Glace",
		dragon = "Dragon",
		dark = "Ténèbres",
		fairy = "Fée",
		unknown = "???", -- For the move "Curse"
	},
	-- The list of Pokémon moves below must remain in the same order
	MoveNames = {
		"Ecras'face", --Ecras'face english:Pound
		"Poing-Karate", --Poing-Karate english:Karate Chop
		"Torgnoles", --Torgnoles english:DoubleSlap
		"Poing Comete", --Poing Comete english:Comet Punch
		"Ultimapoing", --Ultimapoing english:Mega Punch
		"Jackpot", --Jackpot english:Pay Day
		"Poing De Feu", --Poing De Feu english:Fire Punch
		"Poinglace", --Poinglace english:Ice Punch
		"Poing-Eclair", --Poing-Eclair english:ThunderPunch
		"Griffe", --Griffe english:Scratch
		"Force Poigne", --Force Poigne english:ViceGrip
		"Guillotine", --Guillotine english:Guillotine
		"Coupe-Vent", --Coupe-Vent english:Razor Wind
		"Danse-Lames", --Danse-Lames english:Swords Dance
		"Coupe", --Coupe english:Cut
		"Tornade", --Tornade english:Gust
		"Cru-Aile", --Cru-Aile english:Wing Attack
		"Cyclone", --Cyclone english:Whirlwind
		"Vol", --Vol english:Fly
		"Etreinte", --Etreinte english:Bind
		"Souplesse", --Souplesse english:Slam
		"Fouet Lianes", --Fouet Lianes english:Vine Whip
		"Ecrasement", --Ecrasement english:Stomp
		"Double Pied", --Double Pied english:Double Kick
		"Ultimawashi", --Ultimawashi english:Mega Kick
		"Pied Saute", --Pied Saute english:Jump Kick
		"Mawashi Geri", --Mawashi Geri english:Rolling Kick
		"Jet De Sable", --Jet De Sable english:Sand-Attack
		"Coup D'boule", --Coup D'boule english:Headbutt
		"Koud'korne", --Koud'korne english:Horn Attack
		"Furie", --Furie english:Fury Attack
		"Empal'korne", --Empal'korne english:Horn Drill
		"Charge", --Charge english:Tackle
		"Plaquage", --Plaquage english:Body Slam
		"Ligotage", --Ligotage english:Wrap
		"Belier", --Belier english:Take Down
		"Mania", --Mania english:Thrash
		"Damocles", --Damocles english:Double-Edge
		"Mimi-Queue", --Mimi-Queue english:Tail Whip
		"Dard-Venin", --Dard-Venin english:Poison Sting
		"Double-Dard", --Double-Dard english:Twineedle
		"Dard-Nuee", --Dard-Nuee english:Pin Missile
		"Groz'yeux", --Groz'yeux english:Leer
		"Morsure", --Morsure english:Bite
		"Rugissement", --Rugissement english:Growl
		"Hurlement", --Hurlement english:Roar
		"Berceuse", --Berceuse english:Sing
		"Ultrason", --Ultrason english:Supersonic
		"Sonicboom", --Sonicboom english:SonicBoom
		"Entrave", --Entrave english:Disable
		"Acide", --Acide english:Acid
		"Flammeche", --Flammeche english:Ember
		"Lance-Flamme", --Lance-Flamme english:Flamethrower
		"Brume", --Brume english:Mist
		"Pistolet A O", --Pistolet A O english:Water Gun
		"Hydrocanon", --Hydrocanon english:Hydro Pump
		"Surf", --Surf english:Surf
		"Laser Glace", --Laser Glace english:Ice Beam
		"Blizzard", --Blizzard english:Blizzard
		"Rafale Psy", --Rafale Psy english:Psybeam
		"Bulles D'o", --Bulles D'o english:BubbleBeam
		"Onde Boreale", --Onde Boreale english:Aurora Beam
		"Ultralaser", --Ultralaser english:Hyper Beam
		"Picpic", --Picpic english:Peck
		"Bec Vrille", --Bec Vrille english:Drill Peck
		"Sacrifice", --Sacrifice english:Submission
		"Balayage", --Balayage english:Low Kick
		"Riposte", --Riposte english:Counter
		"Frappe Atlas", --Frappe Atlas english:Seismic Toss
		"Force", --Force english:Strength
		"Vol-Vie", --Vol-Vie english:Absorb
		"Mega-Sangsue", --Mega-Sangsue english:Mega Drain
		"Vampigraine", --Vampigraine english:Leech Seed
		"Croissance", --Croissance english:Growth
		"Tranch'herbe", --Tranch'herbe english:Razor Leaf
		"Lance-Soleil", --Lance-Soleil english:SolarBeam
		"Poudre Toxik", --Poudre Toxik english:PoisonPowder
		"Para-Spore", --Para-Spore english:Stun Spore
		"Poudre Dodo", --Poudre Dodo english:Sleep Powder
		"Danse-Fleur", --Danse-Fleur english:Petal Dance
		"Secretion", --Secretion english:String Shot
		"Draco-Rage", --Draco-Rage english:Dragon Rage
		"Danseflamme", --Danseflamme english:Fire Spin
		"Eclair", --Eclair english:ThunderShock
		"Tonnerre", --Tonnerre english:Thunderbolt
		"Cage-Eclair", --Cage-Eclair english:Thunder Wave
		"Fatal-Foudre", --Fatal-Foudre english:Thunder
		"Jet-Pierres", --Jet-Pierres english:Rock Throw
		"Seisme", --Seisme english:Earthquake
		"Abime", --Abime english:Fissure
		"Tunnel", --Tunnel english:Dig
		"Toxik", --Toxik english:Toxic
		"Choc Mental", --Choc Mental english:Confusion
		"Psyko", --Psyko english:Psychic
		"Hypnose", --Hypnose english:Hypnosis
		"Yoga", --Yoga english:Meditate
		"Hate", --Hate english:Agility
		"Vive-Attaque", --Vive-Attaque english:Quick Attack
		"Frenesie", --Frenesie english:Rage
		"Teleport", --Teleport english:Teleport
		"Tenebres", --Tenebres english:Night Shade
		"Copie", --Copie english:Mimic
		"Grincement", --Grincement english:Screech
		"Reflet", --Reflet english:Double Team
		"Soin", --Soin english:Recover
		"Armure", --Armure english:Harden
		"Lilliput", --Lilliput english:Minimize
		"Brouillard", --Brouillard english:SmokeScreen
		"Onde Folie", --Onde Folie english:Confuse Ray
		"Repli", --Repli english:Withdraw
		"Boul'armure", --Boul'armure english:Defense Curl
		"Bouclier", --Bouclier english:Barrier
		"Mur Lumiere", --Mur Lumiere english:Light Screen
		"Buee Noire", --Buee Noire english:Haze
		"Protection", --Protection english:Reflect
		"Puissance", --Puissance english:Focus Energy
		"Patience", --Patience english:Bide
		"Metronome", --Metronome english:Metronome
		"Mimique", --Mimique english:Mirror Move
		"Destruction", --Destruction english:Selfdestruct
		"Bomb'oeuf", --Bomb'oeuf english:Egg Bomb
		"Lechouille", --Lechouille english:Lick
		"Puredpois", --Puredpois english:Smog
		"Detritus", --Detritus english:Sludge
		"Massd'os", --Massd'os english:Bone Club
		"Deflagration", --Deflagration english:Fire Blast
		"Cascade", --Cascade english:Waterfall
		"Claquoir", --Claquoir english:Clamp
		"Meteores", --Meteores english:Swift
		"Coud'krane", --Coud'krane english:Skull Bash
		"Picanon", --Picanon english:Spike Cannon
		"Constriction", --Constriction english:Constrict
		"Amnesie", --Amnesie english:Amnesia
		"Telekinesie", --Telekinesie english:Kinesis
		"E-Coque", --E-Coque english:Softboiled
		"Pied Voltige", --Pied Voltige english:Hi Jump Kick
		"Intimidation", --Intimidation english:Glare
		"Devoreve", --Devoreve english:Dream Eater
		"Gaz Toxik", --Gaz Toxik english:Poison Gas
		"Pilonnage", --Pilonnage english:Barrage
		"Vampirisme", --Vampirisme english:Leech Life
		"Grobisou", --Grobisou english:Lovely Kiss
		"Pique", --Pique english:Sky Attack
		"Morphing", --Morphing english:Transform
		"Ecume", --Ecume english:Bubble
		"Uppercut", --Uppercut english:Dizzy Punch
		"Spore", --Spore english:Spore
		"Flash", --Flash english:Flash
		"Vague Psy", --Vague Psy english:Psywave
		"Trempette", --Trempette english:Splash
		"Acidarmure", --Acidarmure english:Acid Armor
		"Pince-Masse", --Pince-Masse english:Crabhammer
		"Explosion", --Explosion english:Explosion
		"Combo-Griffe", --Combo-Griffe english:Fury Swipes
		"Osmerang", --Osmerang english:Bonemerang
		"Repos", --Repos english:Rest
		"Eboulement", --Eboulement english:Rock Slide
		"Croc De Mort", --Croc De Mort english:Hyper Fang
		"Affutage", --Affutage english:Sharpen
		"Adaptation", --Adaptation english:Conversion
		"Triplattaque", --Triplattaque english:Tri Attack
		"Croc Fatal", --Croc Fatal english:Super Fang
		"Tranche", --Tranche english:Slash
		"Clonage", --Clonage english:Substitute
		"Lutte", --Lutte english:Struggle
		"Gribouille", --Gribouille english:Sketch
		"Triple Pied", --Triple Pied english:Triple Kick
		"Larcin", --Larcin english:Thief
		"Toile", --Toile english:Spider Web
		"Lire-Esprit", --Lire-Esprit english:Mind Reader
		"Cauchemar", --Cauchemar english:Nightmare
		"Roue De Feu", --Roue De Feu english:Flame Wheel
		"Ronflement", --Ronflement english:Snore
		"Malediction", --Malediction english:Curse
		"Fleau", --Fleau english:Flail
		"Conversion 2", --Conversion 2 english:Conversion 2
		"Aeroblast", --Aeroblast english:Aeroblast
		"Spore Coton", --Spore Coton english:Cotton Spore
		"Contre", --Contre english:Reversal
		"Depit", --Depit english:Spite
		"Poudreuse", --Poudreuse english:Powder Snow
		"Abri", --Abri english:Protect
		"Mach Punch", --Mach Punch english:Mach Punch
		"Grimace", --Grimace english:Scary Face
		"Feinte", --Feinte english:Faint Attack
		"Doux Baiser", --Doux Baiser english:Sweet Kiss
		"Cognobidon", --Cognobidon english:Belly Drum
		"Bomb-Beurk", --Bomb-Beurk english:Sludge Bomb
		"Coud'boue", --Coud'boue english:Mud-Slap
		"Octazooka", --Octazooka english:Octazooka
		"Picots", --Picots english:Spikes
		"Elecanon", --Elecanon english:Zap Cannon
		"Clairvoyance", --Clairvoyance english:Foresight
		"Prlvt Destin", --Prlvt Destin english:Destiny Bond
		"Requiem", --Requiem english:Perish Song
		"Vent Glace", --Vent Glace english:Icy Wind
		"Detection", --Detection english:Detect
		"Charge-Os", --Charge-Os english:Bone Rush
		"Verrouillage", --Verrouillage english:Lock-On
		"Colere", --Colere english:Outrage
		"Tempetesable", --Tempetesable english:Sandstorm
		"Giga-Sangsue", --Giga-Sangsue english:Giga Drain
		"Tenacite", --Tenacite english:Endure
		"Charme", --Charme english:Charm
		"Roulade", --Roulade english:Rollout
		"Faux-Chage", --Faux-Chage english:False Swipe
		"Vantardise", --Vantardise english:Swagger
		"Lait A Boire", --Lait A Boire english:Milk Drink
		"Etincelle", --Etincelle english:Spark
		"Taillade", --Taillade english:Fury Cutter
		"Aile D'acier", --Aile D'acier english:Steel Wing
		"Regard Noir", --Regard Noir english:Mean Look
		"Attraction", --Attraction english:Attract
		"Blabla Dodo", --Blabla Dodo english:Sleep Talk
		"Glas De Soin", --Glas De Soin english:Heal Bell
		"Retour", --Retour english:Return
		"Cadeau", --Cadeau english:Present
		"Frustration", --Frustration english:Frustration
		"Rune Protect", --Rune Protect english:Safeguard
		"Balance", --Balance english:Pain Split
		"Feu Sacre", --Feu Sacre english:Sacred Fire
		"Ampleur", --Ampleur english:Magnitude
		"Dynamopoing", --Dynamopoing english:DynamicPunch
		"Megacorne", --Megacorne english:Megahorn
		"Dracosouffle", --Dracosouffle english:DragonBreath
		"Relais", --Relais english:Baton Pass
		"Encore", --Encore english:Encore
		"Poursuite", --Poursuite english:Pursuit
		"Tour Rapide", --Tour Rapide english:Rapid Spin
		"Doux Parfum", --Doux Parfum english:Sweet Scent
		"Queue De Fer", --Queue De Fer english:Iron Tail
		"Griffe Acier", --Griffe Acier english:Metal Claw
		"Corps Perdu", --Corps Perdu english:Vital Throw
		"Aurore", --Aurore english:Morning Sun
		"Synthese", --Synthese english:Synthesis
		"Rayon Lune", --Rayon Lune english:Moonlight
		"Puis. Cachee", --Puis. Cachee english:Hidden Power
		"Coup-Croix", --Coup-Croix english:Cross Chop
		"Ouragan", --Ouragan english:Twister
		"Danse Pluie", --Danse Pluie english:Rain Dance
		"Zenith", --Zenith english:Sunny Day
		"Machouille", --Machouille english:Crunch
		"Voile Miroir", --Voile Miroir english:Mirror Coat
		"Boost", --Boost english:Psych Up
		"Vit.extreme", --Vit.extreme english:ExtremeSpeed
		"Pouv.antique", --Pouv.antique english:AncientPower
		"Ball'ombre", --Ball'ombre english:Shadow Ball
		"Prescience", --Prescience english:Future Sight
		"Eclate-Roc", --Eclate-Roc english:Rock Smash
		"Siphon", --Siphon english:Whirlpool
		"Baston", --Baston english:Beat Up
		"Bluff", --Bluff english:Fake Out
		"Brouhaha", --Brouhaha english:Uproar
		"Stockage", --Stockage english:Stockpile
		"Relache", --Relache english:Spit Up
		"Avale", --Avale english:Swallow
		"Canicule", --Canicule english:Heat Wave
		"Grele", --Grele english:Hail
		"Tourmente", --Tourmente english:Torment
		"Flatterie", --Flatterie english:Flatter
		"Feu Follet", --Feu Follet english:Will-O-Wisp
		"Souvenir", --Souvenir english:Memento
		"Facade", --Facade english:Facade
		"Mitra-Poing", --Mitra-Poing english:Focus Punch
		"Stimulant", --Stimulant english:SmellingSalt
		"Par Ici", --Par Ici english:Follow Me
		"Force-Nature", --Force-Nature english:Nature Power
		"Chargeur", --Chargeur english:Charge
		"Provoc", --Provoc english:Taunt
		"Coup D'main", --Coup D'main english:Helping Hand
		"Tourmagik", --Tourmagik english:Trick
		"Imitation", --Imitation english:Role Play
		"Voeu", --Voeu english:Wish
		"Assistance", --Assistance english:Assist
		"Racines", --Racines english:Ingrain
		"Surpuissance", --Surpuissance english:Superpower
		"Reflet Magik", --Reflet Magik english:Magic Coat
		"Recyclage", --Recyclage english:Recycle
		"Vendetta", --Vendetta english:Revenge
		"Casse-Brique", --Casse-Brique english:Brick Break
		"Baillement", --Baillement english:Yawn
		"Sabotage", --Sabotage english:Knock Off
		"Effort", --Effort english:Endeavor
		"Eruption", --Eruption english:Eruption
		"Echange", --Echange english:Skill Swap
		"Possessif", --Possessif english:Imprison
		"Regeneration", --Regeneration english:Refresh
		"Rancune", --Rancune english:Grudge
		"Saisie", --Saisie english:Snatch
		"Force Cachee", --Force Cachee english:Secret Power
		"Plongee", --Plongee english:Dive
		"Cogne", --Cogne english:Arm Thrust
		"Camouflage", --Camouflage english:Camouflage
		"Lumiqueue", --Lumiqueue english:Tail Glow
		"Lumi-Eclat", --Lumi-Eclat english:Luster Purge
		"Ball'brume", --Ball'brume english:Mist Ball
		"Danse-Plume", --Danse-Plume english:FeatherDance
		"Danse-Folle", --Danse-Folle english:Teeter Dance
		"Pied Bruleur", --Pied Bruleur english:Blaze Kick
		"Lance-Boue", --Lance-Boue english:Mud Sport
		"Ball'glace", --Ball'glace english:Ice Ball
		"Poing Dard", --Poing Dard english:Needle Arm
		"Paresse", --Paresse english:Slack Off
		"Megaphone", --Megaphone english:Hyper Voice
		"Crochetvenin", --Crochetvenin english:Poison Fang
		"Eclategriffe", --Eclategriffe english:Crush Claw
		"Rafale Feu", --Rafale Feu english:Blast Burn
		"Hydroblast", --Hydroblast english:Hydro Cannon
		"Poing Meteor", --Poing Meteor english:Meteor Mash
		"Etonnement", --Etonnement english:Astonish
		"Ball'meteo", --Ball'meteo english:Weather Ball
		"Aromatherapi", --Aromatherapi english:Aromatherapy
		"Croco Larme", --Croco Larme english:Fake Tears
		"Tranch'air", --Tranch'air english:Air Cutter
		"Surchauffe", --Surchauffe english:Overheat
		"Flair", --Flair english:Odor Sleuth
		"Tomberoche", --Tomberoche english:Rock Tomb
		"Vent Argente", --Vent Argente english:Silver Wind
		"Strido-Son", --Strido-Son english:Metal Sound
		"Siffl'herbe", --Siffl'herbe english:GrassWhistle
		"Chatouille", --Chatouille english:Tickle
		"Force Cosmik", --Force Cosmik english:Cosmic Power
		"Gicledo", --Gicledo english:Water Spout
		"Rayon Signal", --Rayon Signal english:Signal Beam
		"Poing Ombre", --Poing Ombre english:Shadow Punch
		"Extrasenseur", --Extrasenseur english:Extrasensory
		"Stratopercut", --Stratopercut english:Sky Uppercut
		"Tourbi-Sable", --Tourbi-Sable english:Sand Tomb
		"Glaciation", --Glaciation english:Sheer Cold
		"Ocroupi", --Ocroupi english:Muddy Water
		"Balle Graine", --Balle Graine english:Bullet Seed
		"Aeropique", --Aeropique english:Aerial Ace
		"Stalagtite", --Stalagtite english:Icicle Spear
		"Mur De Fer", --Mur De Fer english:Iron Defense
		"Barrage", --Barrage english:Block
		"Grondement", --Grondement english:Howl
		"Dracogriffe", --Dracogriffe english:Dragon Claw
		"Vege-Attak", --Vege-Attak english:Frenzy Plant
		"Gonflette", --Gonflette english:Bulk Up
		"Rebond", --Rebond english:Bounce
		"Tir De Boue", --Tir De Boue english:Mud Shot
		"Queue-Poison", --Queue-Poison english:Poison Tail
		"Implore", --Implore english:Covet
		"Electacle", --Electacle english:Volt Tackle
		"Feuillemagik", --Feuillemagik english:Magical Leaf
		"Tourniquet", --Tourniquet english:Water Sport
		"Plenitude", --Plenitude english:Calm Mind
		"Lame-Feuille", --Lame-Feuille english:Leaf Blade
		"Danse Draco", --Danse Draco english:Dragon Dance
		"Boule Roc", --Boule Roc english:Rock Blast
		"Onde De Choc", --Onde De Choc english:Shock Wave
		"Vibraqua", --Vibraqua english:Water Pulse
		"Carnareket", --Carnareket english:Doom Desire
		"Psycho Boost", --Psycho Boost english:Psycho Boost
	},
	-- The list below must remain in the same order.
	-- These are custom hand-written move summaries, only edit the "Description" value
	MoveDescriptions = {
		{
			NameKey = "Pound",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Karate Chop",
			Description = "Inflige des dégâts et augmente le taux de coup critique. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "DoubleSlap",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique ou activer un talent de contact.",
		},
		{
			NameKey = "Comet Punch",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique ou activer un talent de contact.",
		},
		{
			NameKey = "Mega Punch",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Pay Day",
			Description = "Eparpille des pieces equivalentes a cinq fois le niveau de l'utilisateur a chaque utilisation.",
		},
		{
			NameKey = "Fire Punch",
			Description = "Inflige des dégâts et a 10% de chance de bruler l'adversaire.",
		},
		{
			NameKey = "Ice Punch",
			Description = "Inflige des dégâts et a 10% de chance de geler l'adversaire.",
		},
		{
			NameKey = "ThunderPunch",
			Description = "Inflige des dégâts et a 10% de chance de paralyser l'adversaire.",
		},
		{
			NameKey = "Scratch",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "ViceGrip",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Guillotine",
			Description = "Attaque K.O. en un coup. Cette attaque gagne 1% de précision par niveau au-dessus de la cible. Echoue si la cible a un niveau supérieur.",
		},
		{
			NameKey = "Razor Wind",
			Description = "Attaque au 2e tour après utilisation. Contrairement a la description du jeu, elle n'a PAS un fort taux de critique.",
		},
		{
			NameKey = "Swords Dance",
			Description = "Augmente l'Attaque de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Cut",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Gust",
			Description = "Inflige le double de dégâts si l'adversaire utilise Vol ou Rebond.",
		},
		{
			NameKey = "Wing Attack",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Whirlwind",
			Description = "Force la cible a etre remplacée par un autre Pokémon aléatoire. Echoue face a Ventouse ou Enracinement.",
		},
		{
			NameKey = "Fly",
			Description = "Attaque au 2e tour. Peut tout de meme etre touché par Tornade, Pied Voltige, Tonnerre, Ouragan et Cyclone.",
		},
		{
			NameKey = "Bind",
			Description = "Inflige des dégâts et retire 1/16 des PV max de la cible pendant 2 a 5 tours. Empêche la cible de fuir ou d'etre remplacée.",
		},
		{
			NameKey = "Slam",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Vine Whip",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Stomp",
			Description = "Inflige des dégâts avec 30% de chance d'apeurer la cible. Les dégâts sont doublés contre une cible ayant utilisé Minimiser.",
		},
		{
			NameKey = "Double Kick",
			Description = "Inflige des dégâts deux fois, chaque coup pouvant etre critique.",
		},
		{
			NameKey = "Mega Kick",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Jump Kick",
			Description = "Si l'attaque échoue, l'utilisateur subit des dégâts égaux a la moitié de ceux qu'elle aurait infligés.",
		},
		{
			NameKey = "Rolling Kick",
			Description = "Inflige des dégâts et a 30% de chance d'apeurer la cible.",
		},
		{
			NameKey = "Sand-Attack",
			Description = "Réduit la précision de la cible d'un niveau. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Headbutt",
			Description = "Inflige des dégâts et a 30% de chance d'apeurer la cible.",
		},
		{
			NameKey = "Horn Attack",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Fury Attack",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique ou activer un talent de contact.",
		},
		{
			NameKey = "Horn Drill",
			Description = "Attaque K.O. en un coup. Cette attaque gagne 1% de précision par niveau au-dessus de la cible. Echoue si la cible a un niveau supérieur.",
		},
		{
			NameKey = "Tackle",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Body Slam",
			Description = "Inflige des dégâts et a 30% de chance de paralyser la cible.",
		},
		{
			NameKey = "Wrap",
			Description = "Inflige des dégâts et retire 1/16 des PV max de la cible pendant 2 a 5 tours. Empêche la cible de fuir ou d'etre remplacée.",
		},
		{
			NameKey = "Take Down",
			Description = "L'utilisateur subit des dégâts de recul égaux a 1/4 des dégâts infligés.",
		},
		{
			NameKey = "Thrash",
			Description = "Inflige des dégâts pendant 2 a 3 tours consécutifs. L'utilisateur devient ensuite confus.",
		},
		{
			NameKey = "Double-Edge",
			Description = "L'utilisateur subit des dégâts de recul égaux a 1/3 des dégâts infligés.",
		},
		{
			NameKey = "Tail Whip",
			Description = "Réduit la Défense de tous les adversaires adjacents d'un niveau.",
		},
		{
			NameKey = "Poison Sting",
			Description = "Inflige des dégâts et a 30% de chance d'empoisonner la cible.",
		},
		{
			NameKey = "Twineedle",
			Description = "Inflige des dégâts deux fois, chaque coup pouvant etre critique. Le dernier coup a 20% de chance d'empoisonner la cible.",
		},
		{
			NameKey = "Pin Missile",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Leer",
			Description = "Réduit la Défense de tous les adversaires adjacents d'un niveau.",
		},
		{
			NameKey = "Bite",
			Description = "Inflige des dégâts et a 30% de chance d'apeurer la cible.",
		},
		{
			NameKey = "Growl",
			Description = "Réduit l'Attaque de tous les adversaires adjacents d'un niveau.",
		},
		{
			NameKey = "Roar",
			Description = "Force la cible a etre remplacée par un autre Pokémon aléatoire. Echoue face a Anti-Bruit, Ventouse ou Enracinement.",
		},
		{
			NameKey = "Sing",
			Description = "Endort la cible pendant 2 a 5 tours. Echoue face a Insomnia, Esprit Vital ou Anti-Bruit.",
		},
		{
			NameKey = "Supersonic",
			Description = "Rend la cible confuse. Echoue face a Anti-Bruit ou Tempo Perso.",
		},
		{
			NameKey = "SonicBoom",
			Description = "Inflige toujours exactement 20 PV de dégâts si elle touche.",
		},
		{
			NameKey = "Disable",
			Description = "Bloque la dernière attaque utilisée par la cible pendant 2 a 5 tours.",
		},
		{
			NameKey = "Acid",
			Description = "Inflige des dégâts et a 10% de chance de réduire la Défense de la cible d'un niveau.",
		},
		{
			NameKey = "Ember",
			Description = "Inflige des dégâts et a 10% de chance de bruler la cible.",
		},
		{
			NameKey = "Flamethrower",
			Description = "Inflige des dégâts et a 10% de chance de bruler la cible.",
		},
		{
			NameKey = "Mist",
			Description = "Pendant cinq tours, les Pokémon ennemis ne peuvent pas baisser les stats des Pokémon de votre équipe.",
		},
		{
			NameKey = "Water Gun",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Hydro Pump",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Surf",
			Description = "Inflige le double de dégâts si l'adversaire utilise Plongée.",
		},
		{
			NameKey = "Ice Beam",
			Description = "Inflige des dégâts et a 10% de chance de geler la cible.",
		},
		{
			NameKey = "Blizzard",
			Description = "Inflige des dégâts et a 10% de chance de geler la cible.",
		},
		{
			NameKey = "Psybeam",
			Description = "Inflige des dégâts et a 10% de chance de rendre la cible confuse.",
		},
		{
			NameKey = "BubbleBeam",
			Description = "Inflige des dégâts et a 10% de chance de réduire la Vitesse de la cible d'un niveau.",
		},
		{
			NameKey = "Aurora Beam",
			Description = "Inflige des dégâts et a 10% de chance de réduire l'Attaque de la cible d'un niveau.",
		},
		{
			NameKey = "Hyper Beam",
			Description = "Inflige des dégâts puis force l'utilisateur a recharger au tour suivant.",
		},
		{
			NameKey = "Peck",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Drill Peck",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Submission",
			Description = "Inflige des dégâts et l'utilisateur subit des dégâts de recul égaux a 25% des dégâts infligés.",
		},
		{
			NameKey = "Low Kick",
			Description = "Inflige entre 20 et 120 de puissance selon le poids de la cible.",
		},
		{
			NameKey = "Counter",
			Description = "Si touché par une attaque de catégorie Physique, renvoie le double des dégâts reçus a l'attaquant.",
		},
		{
			NameKey = "Seismic Toss",
			Description = "Inflige des dégâts fixes égaux au niveau de l'utilisateur.",
		},
		{
			NameKey = "Strength",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Absorb",
			Description = "50% des dégâts infligés sont restaurés en PV a l'utilisateur.",
		},
		{
			NameKey = "Mega Drain",
			Description = "50% des dégâts infligés sont restaurés en PV a l'utilisateur.",
		},
		{
			NameKey = "Leech Seed",
			Description = "Drain 1/8 des PV de la cible a la fin de chaque tour.",
		},
		{
			NameKey = "Growth",
			Description = "Augmente l'Attaque Spéciale de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Razor Leaf",
			Description = "Inflige des dégâts et augmente le taux de coup critique. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "SolarBeam",
			Description = "Attaque au 2e tour après utilisation, ou immédiatement sous le soleil. Dégâts divisés par deux sous la pluie ou la tempete de sable.",
		},
		{
			NameKey = "PoisonPowder",
			Description = "Empoisonne la cible, qui perd 1/8 de ses PV max a la fin de chaque tour.",
		},
		{
			NameKey = "Stun Spore",
			Description = "Paralyse la cible, réduisant sa Vitesse de 75%, avec 25% de chance de ne pas agir.",
		},
		{
			NameKey = "Sleep Powder",
			Description = "Endort la cible pendant 2 a 5 tours. Echoue face a Insomnia ou Esprit Vital.",
		},
		{
			NameKey = "Petal Dance",
			Description = "Inflige des dégâts pendant 2 a 3 tours consécutifs. L'utilisateur devient ensuite confus.",
		},
		{
			NameKey = "String Shot",
			Description = "Réduit la Vitesse des cibles d'un niveau.",
		},
		{
			NameKey = "Dragon Rage",
			Description = "Inflige toujours exactement 40 PV de dégâts si elle touche.",
		},
		{
			NameKey = "Fire Spin",
			Description = "Inflige des dégâts et retire 1/16 des PV max de la cible pendant 2 a 5 tours. Empêche la cible de fuir ou d'etre remplacée.",
		},
		{
			NameKey = "ThunderShock",
			Description = "Inflige des dégâts et a 10% de chance de paralyser la cible.",
		},
		{
			NameKey = "Thunderbolt",
			Description = "Inflige des dégâts et a 10% de chance de paralyser la cible.",
		},
		{
			NameKey = "Thunder Wave",
			Description = "Paralyse la cible, réduisant sa Vitesse de 75%, avec 25% de chance de ne pas agir.",
		},
		{
			NameKey = "Thunder",
			Description = "30% de chance de paralyser. Peut toucher Vol et Rebond. Touche toujours sous la pluie. Sa précision passe a 50 sous le soleil.",
		},
		{
			NameKey = "Rock Throw",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Earthquake",
			Description = "Inflige le double de dégâts si l'adversaire utilise Tunnel.",
		},
		{
			NameKey = "Fissure",
			Description = "Attaque K.O. en un coup. Cette attaque gagne 1% de précision par niveau au-dessus de la cible. Echoue si la cible a un niveau supérieur. Peut toucher un Pokémon utilisant Tunnel.",
		},
		{
			NameKey = "Dig",
			Description = "Attaque au 2e tour. Peut etre touché par Séisme, Abime et Ampleur. Peut etre utilisé hors combat.",
		},
		{
			NameKey = "Toxic",
			Description = "Empoisonne gravement la cible, qui perd une part croissante de ses PV max a la fin de chaque tour.",
		},
		{
			NameKey = "Confusion",
			Description = "Inflige des dégâts et a 10% de chance de rendre la cible confuse.",
		},
		{
			NameKey = "Psychic",
			Description = "Inflige des dégâts et a 10% de chance de réduire la Défense Spéciale de la cible d'un niveau.",
		},
		{
			NameKey = "Hypnosis",
			Description = "Endort la cible pendant 2 a 5 tours. Echoue face a Insomnia ou Esprit Vital.",
		},
		{
			NameKey = "Meditate",
			Description = "Augmente l'Attaque de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Agility",
			Description = "Augmente la Vitesse de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Quick Attack",
			Description = "Attaque a priorité augmentée, permettant d'agir avant la plupart des autres attaques.",
		},
		{
			NameKey = "Rage",
			Description = "Lorsqu'elle est utilisée consécutivement, l'Attaque augmente d'un niveau chaque fois que l'utilisateur subit une attaque.",
		},
		{
			NameKey = "Teleport",
			Description = "Permet uniquement de fuir les combats contre des Pokémon sauvages. Echoue si piégé par Barrage, Regard Noir, Toile ou Enracinement. Peut etre utilisé hors combat.",
		},
		{
			NameKey = "Night Shade",
			Description = "Inflige des dégâts fixes égaux au niveau de l'utilisateur.",
		},
		{
			NameKey = "Mimic",
			Description = "Copie la dernière attaque utilisée par la cible. Echoue face a Gribouille, Morphing, Métronome ou une attaque deja connue.",
		},
		{
			NameKey = "Screech",
			Description = "Réduit la Défense de la cible de deux niveaux. Echoue face au talent Anti-Bruit.",
		},
		{
			NameKey = "Double Team",
			Description = "Augmente l'Esquive de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Recover",
			Description = "Restaure jusqu'a 50% des PV max de l'utilisateur.",
		},
		{
			NameKey = "Harden",
			Description = "Augmente la Défense de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Minimize",
			Description = "Augmente l'Esquive d'un niveau. L'utilisateur reçoit ensuite le double de dégâts de Piétisol, Etonnement, Extrasenseur et Poing Dard.",
		},
		{
			NameKey = "SmokeScreen",
			Description = "Réduit la précision de la cible d'un niveau. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Confuse Ray",
			Description = "Rend la cible confuse pendant 2 a 5 tours. 50% de chance qu'elle se blesse elle-meme avec une attaque Physique de puissance 40.",
		},
		{
			NameKey = "Withdraw",
			Description = "Augmente la Défense de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Defense Curl",
			Description = "Augmente la Défense de l'utilisateur d'un niveau. Double aussi la puissance de Roulade et Ball'Glace.",
		},
		{
			NameKey = "Barrier",
			Description = "Augmente la Défense de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Light Screen",
			Description = "Pendant 5 tours, réduit de moitié les dégâts des attaques Spéciales subis par l'équipe de l'utilisateur.",
		},
		{
			NameKey = "Haze",
			Description = "Réinitialise a 0 les niveaux de stats de tous les Pokémon actifs sur le terrain.",
		},
		{
			NameKey = "Reflect",
			Description = "Pendant 5 tours, réduit de moitié les dégâts des attaques Physiques subis par l'équipe de l'utilisateur.",
		},
		{
			NameKey = "Focus Energy",
			Description = "Augmente le taux de coup critique de l'utilisateur de deux niveaux. (+2 niveaux = 1/4 soit 25%)",
		},
		{
			NameKey = "Bide",
			Description = "Encaisse les attaques pendant deux tours consécutifs. Inflige ensuite des dégâts égaux au double des dégâts reçus.",
		},
		{
			NameKey = "Metronome",
			Description = "Sélectionne aléatoirement une attaque a utiliser, et une cible aléatoire si nécessaire.",
		},
		{
			NameKey = "Mirror Move",
			Description = "Utilise la dernière attaque ciblant l'utilisateur par un Pokémon encore sur le terrain.",
		},
		{
			NameKey = "Selfdestruct",
			Description = "La Défense de la cible est divisée par deux, ce qui double effectivement la puissance de cette attaque.",
		},
		{
			NameKey = "Egg Bomb",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Lick",
			Description = "Inflige des dégâts et a 30% de chance de paralyser la cible.",
		},
		{
			NameKey = "Smog",
			Description = "Inflige des dégâts et a 40% de chance d'empoisonner la cible.",
		},
		{
			NameKey = "Sludge",
			Description = "Inflige des dégâts et a 30% de chance d'empoisonner la cible.",
		},
		{
			NameKey = "Bone Club",
			Description = "Inflige des dégâts et a 10% de chance d'apeurer la cible.",
		},
		{
			NameKey = "Fire Blast",
			Description = "Inflige des dégâts et a 10% de chance de bruler la cible.",
		},
		{
			NameKey = "Waterfall",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Clamp",
			Description = "Inflige des dégâts et retire 1/16 des PV max de la cible pendant 2 a 5 tours. Empêche la cible de fuir ou d'etre remplacée.",
		},
		{
			NameKey = "Swift",
			Description = "Inflige des dégâts et ignore les tests de précision pour toujours toucher, sauf si la cible est dans un tour semi-invulnérable (ex: Tunnel, Vol).",
		},
		{
			NameKey = "Skull Bash",
			Description = "Augmente la Défense de l'utilisateur d'un niveau. Au tour suivant, inflige des dégâts.",
		},
		{
			NameKey = "Spike Cannon",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Constrict",
			Description = "Inflige des dégâts et a 10% de chance de réduire la Vitesse de la cible d'un niveau.",
		},
		{
			NameKey = "Amnesia",
			Description = "Augmente la Défense Spéciale de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Kinesis",
			Description = "Réduit la précision de la cible d'un niveau. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Softboiled",
			Description = "Restaure jusqu'a 50% des PV max de l'utilisateur. Peut etre utilisé hors combat pour transférer 20% des PV max a un autre Pokémon.",
		},
		{
			NameKey = "Hi Jump Kick",
			Description = "Si l'attaque échoue, l'utilisateur subit des dégâts égaux a la moitié de ceux qu'elle aurait infligés.",
		},
		{
			NameKey = "Glare",
			Description = "Paralyse la cible, réduisant sa Vitesse de 75%, avec 25% de chance de ne pas agir. Echoue contre les types Spectre.",
		},
		{
			NameKey = "Dream Eater",
			Description = "Echoue si la cible n'est pas endormie. 50% des dégâts infligés sont restaurés en PV a l'utilisateur.",
		},
		{
			NameKey = "Poison Gas",
			Description = "Empoisonne la cible, qui perd 1/8 de ses PV max a la fin de chaque tour.",
		},
		{
			NameKey = "Barrage",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Leech Life",
			Description = "50% des dégâts infligés sont restaurés en PV a l'utilisateur.",
		},
		{
			NameKey = "Lovely Kiss",
			Description = "Endort la cible pendant 2 a 5 tours. Echoue face a Insomnia ou Esprit Vital.",
		},
		{
			NameKey = "Sky Attack",
			Description = "Attaque au 2e tour, avec 30% de chance d'apeurer la cible. Taux de coup critique augmenté. (+1 niveau = 1/8 soit 12,5%).",
		},
		{
			NameKey = "Transform",
			Description = "Se transforme en la cible en copiant tout (meme les changements de stats), sauf les PV actuels et max. Les PP de chaque attaque deviennent 5.",
		},
		{
			NameKey = "Bubble",
			Description = "Inflige des dégâts et a 10% de chance de réduire la Vitesse de la cible d'un niveau.",
		},
		{
			NameKey = "Dizzy Punch",
			Description = "Inflige des dégâts et a 20% de chance de rendre la cible confuse.",
		},
		{
			NameKey = "Spore",
			Description = "Endort la cible pendant 2 a 5 tours. Echoue face a Insomnia ou Esprit Vital.",
		},
		{
			NameKey = "Flash",
			Description = "Réduit la précision de la cible d'un niveau. (100% -> 75% -> 60% -> 50% ...)",
		},
		{
			NameKey = "Psywave",
			Description = "Inflige des dégâts aléatoires compris entre 50% et 150% du niveau de l'utilisateur. Minimum de 1 dégât.",
		},
		{
			NameKey = "Splash",
			Description = "N'inflige aucun dégât et n'a absolument aucun effet.",
		},
		{
			NameKey = "Acid Armor",
			Description = "Augmente la Défense de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Crabhammer",
			Description = "Inflige des dégâts et augmente le taux de coup critique. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Explosion",
			Description = "La Défense de la cible est divisée par deux, ce qui double effectivement la puissance de cette attaque.",
		},
		{
			NameKey = "Fury Swipes",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique ou activer un talent de contact.",
		},
		{
			NameKey = "Bonemerang",
			Description = "Inflige des dégâts deux fois, chaque coup pouvant etre critique.",
		},
		{
			NameKey = "Rest",
			Description = "Restaure tous les PV puis endort l'utilisateur pendant 2 tours. Echoue si l'utilisateur a Insomnia ou Esprit Vital.",
		},
		{
			NameKey = "Rock Slide",
			Description = "Inflige des dégâts et a 30% de chance d'apeurer chaque cible.",
		},
		{
			NameKey = "Hyper Fang",
			Description = "Inflige des dégâts et a 10% de chance d'apeurer la cible.",
		},
		{
			NameKey = "Sharpen",
			Description = "Augmente l'Attaque de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Conversion",
			Description = "Change le type de l'utilisateur pour correspondre au type d'une de ses attaques (y compris Conversion elle-meme).",
		},
		{
			NameKey = "Tri Attack",
			Description = "Inflige des dégâts et a 20% de chance de paralyser, geler ou bruler la cible.",
		},
		{
			NameKey = "Super Fang",
			Description = "Inflige des dégâts fixes égaux a 50% des PV actuels de la cible, minimum 1.",
		},
		{
			NameKey = "Slash",
			Description = "Inflige des dégâts et augmente le taux de coup critique. (+1 niveau = 1/8 soit 12,5%).",
		},
		{
			NameKey = "Substitute",
			Description = "L'utilisateur perd 25% de ses PV max pour créer un clone qui bloque les effets de la plupart des attaques.",
		},
		{
			NameKey = "Struggle",
			Description = "Inflige des dégâts neutres, meme a travers Garde Mystik. L'utilisateur subit des dégâts de recul égaux a 1/4 des dégâts infligés.",
		},
		{
			NameKey = "Sketch",
			Description = "L'utilisateur apprend définitivement la dernière attaque de la cible, en remplaçant Gribouille. Echoue contre certaines attaques, ou si l'utilisateur la connait deja.",
		},
		{
			NameKey = "Triple Kick",
			Description = "Frappe trois fois, chaque coup supplémentaire gagnant 10 de puissance. Chaque coup a son propre test de précision et peut etre critique.",
		},
		{
			NameKey = "Thief",
			Description = "Vole l'objet tenu par la cible, si elle en a un. Le vol échoue si l'utilisateur tient deja un objet ou si la cible a Glue.",
		},
		{
			NameKey = "Spider Web",
			Description = "Empêche la cible de fuir ou d'etre remplacée. Un Pokémon peut encore fuir avec Fuite ou en tenant une Boule Fumée.",
		},
		{
			NameKey = "Mind Reader",
			Description = "Permet a la prochaine attaque de l'utilisateur de ne jamais rater, meme contre Rebond, Tunnel, Plongée et Vol.",
		},
		{
			NameKey = "Nightmare",
			Description = "Fait perdre 1/4 des PV max d'une cible endormie a la fin de chaque tour tant qu'elle dort.",
		},
		{
			NameKey = "Flame Wheel",
			Description = "Inflige des dégâts et a 10% de chance de bruler la cible. Cette attaque dégèle d'abord son utilisateur s'il est gelé.",
		},
		{
			NameKey = "Snore",
			Description = "Si l'utilisateur dort, inflige des dégâts et a 30% de chance d'apeurer la cible. Sans effet contre Anti-Bruit.",
		},
		{
			NameKey = "Curse",
			Description = "Réduit la Vitesse mais augmente l'Attaque et la Défense. Si l'utilisateur est Spectre, il perd la moitié de ses PV max pour maudire la cible, qui perd alors 1/4 de ses PV max a la fin de chaque tour.",
		},
		{
			NameKey = "Flail",
			Description = "Inflige plus de dégâts quand l'utilisateur a moins de PV. Seuils importants: puissance 80 a 35% PV ou moins, et 150 a 10% PV ou moins.",
		},
		{
			NameKey = "Conversion 2",
			Description = "Change aléatoirement le type de l'utilisateur vers un type qui résiste ou est immunisé au type de la dernière attaque offensive subie.",
		},
		{
			NameKey = "Aeroblast",
			Description = "Inflige des dégâts et augmente le taux de coup critique. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Cotton Spore",
			Description = "Réduit la Vitesse de la cible de deux niveaux.",
		},
		{
			NameKey = "Reversal",
			Description = "Inflige plus de dégâts quand l'utilisateur a moins de PV. Seuils importants: puissance 80 a 35% PV ou moins, et 150 a 10% PV ou moins.",
		},
		{
			NameKey = "Spite",
			Description = "Réduit de 2 a 5 PP (au hasard) la dernière attaque utilisée par la cible. Dépit échoue si cette attaque a exactement 1 PP restant.",
		},
		{
			NameKey = "Powder Snow",
			Description = "Inflige des dégâts et a 10% de chance de geler la cible.",
		},
		{
			NameKey = "Protect",
			Description = "Protège l'utilisateur de tous les effets d'attaque pendant le tour, y compris les dégâts. Son taux de réussite est divisé par deux a chaque utilisation consécutive.",
		},
		{
			NameKey = "Mach Punch",
			Description = "Attaque a priorité augmentée, permettant d'agir avant la plupart des autres attaques.",
		},
		{
			NameKey = "Scary Face",
			Description = "Réduit la Vitesse de la cible de deux niveaux.",
		},
		{
			NameKey = "Faint Attack",
			Description = "Inflige des dégâts et ignore les tests de précision pour toujours toucher, sauf si la cible est dans un tour semi-invulnérable (ex: Tunnel, Vol).",
		},
		{
			NameKey = "Sweet Kiss",
			Description = "Rend la cible confuse pendant 2 a 5 tours. 50% de chance qu'elle se blesse elle-meme avec une attaque Physique de puissance 40.",
		},
		{
			NameKey = "Belly Drum",
			Description = "L'utilisateur perd la moitié de ses PV max et, en échange, monte son Attaque directement a +6 niveaux.",
		},
		{
			NameKey = "Sludge Bomb",
			Description = "Inflige des dégâts et a 30% de chance d'empoisonner la cible.",
		},
		{
			NameKey = "Mud-Slap",
			Description = "Inflige des dégâts et réduit la précision de la cible d'un niveau.",
		},
		{
			NameKey = "Octazooka",
			Description = "Inflige des dégâts et a 50% de chance de réduire la précision de la cible d'un niveau.",
		},
		{
			NameKey = "Spikes",
			Description = "Place un piège sur l'équipe adverse (jusqu'a 3 couches). A chaque entrée, une cible sans type Vol ni Lévitation perd 1/8, 1/6 ou 1/4 de ses PV max.",
		},
		{
			NameKey = "Zap Cannon",
			Description = "Inflige des dégâts et paralyse la cible a chaque fois qu'elle touche.",
		},
		{
			NameKey = "Foresight",
			Description = "Neutralise les vérifications de précision contre la cible et permet aux attaques Combat et Normal de toucher un Spectre.",
		},
		{
			NameKey = "Destiny Bond",
			Description = "Si l'utilisateur est mis K.O. par une attaque directe adverse, ce Pokémon est aussi mis K.O. L'effet cesse quand l'utilisateur emploie une autre attaque.",
		},
		{
			NameKey = "Perish Song",
			Description = "Tous les Pokémon tombent K.O. après 3 tours. Le retrait du terrain ou Anti-Bruit annule cet effet.",
		},
		{
			NameKey = "Icy Wind",
			Description = "Inflige des dégâts a tous les adversaires adjacents et réduit la Vitesse de chacun d'un niveau.",
		},
		{
			NameKey = "Detect",
			Description = "Protège l'utilisateur de tous les effets d'attaque pendant le tour, y compris les dégâts. Son taux de réussite est divisé par deux a chaque utilisation consécutive.",
		},
		{
			NameKey = "Bone Rush",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Lock-On",
			Description = "Permet a la prochaine attaque de l'utilisateur de ne jamais rater, meme contre Rebond, Tunnel, Plongée et Vol.",
		},
		{
			NameKey = "Outrage",
			Description = "Inflige des dégâts pendant 2 a 3 tours consécutifs. L'utilisateur devient ensuite confus.",
		},
		{
			NameKey = "Sandstorm",
			Description = "Change le climat en tempete de sable pendant 5 tours. Les Pokémon perdent 1/16 de leurs PV max, sauf les types Acier, Sol et Roche.",
		},
		{
			NameKey = "Giga Drain",
			Description = "50% des dégâts infligés sont restaurés en PV a l'utilisateur.",
		},
		{
			NameKey = "Endure",
			Description = "Permet a l'utilisateur de survivre a une attaque qui l'aurait mis K.O., en restant a 1 PV.",
		},
		{
			NameKey = "Charm",
			Description = "Réduit l'Attaque de la cible de deux niveaux.",
		},
		{
			NameKey = "Rollout",
			Description = "Dégâts sur 5 tours, puissance doublée à chaque coup. Base doublée après Boul'Armure.",
		},
		{
			NameKey = "False Swipe",
			Description = "Inflige des dégâts mais laisse toujours la cible a 1 PV si elle devait etre mise K.O.",
		},
		{
			NameKey = "Swagger",
			Description = "Augmente l'Attaque de la cible de deux niveaux et la rend confuse.",
		},
		{
			NameKey = "Milk Drink",
			Description = "Restaure jusqu'a 50% des PV max de l'utilisateur. Peut etre utilisé hors combat pour transférer 20% des PV max a un autre Pokémon.",
		},
		{
			NameKey = "Spark",
			Description = "Inflige des dégâts et a 30% de chance de paralyser la cible.",
		},
		{
			NameKey = "Fury Cutter",
			Description = "Chaque fois que cette attaque touche de suite, sa puissance double, jusqu'a un maximum de 160. Sinon, elle revient a sa puissance de base.",
		},
		{
			NameKey = "Steel Wing",
			Description = "Inflige des dégâts et a 10% de chance d'augmenter la Défense de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Mean Look",
			Description = "Empêche la cible de fuir ou d'etre remplacée. Un Pokémon peut encore fuir avec Fuite ou en tenant une Boule Fumée.",
		},
		{
			NameKey = "Attract",
			Description = "Si l'utilisateur et la cible sont de sexes opposés, la cible devient amoureuse et ne peut pas agir 50% du temps.",
		},
		{
			NameKey = "Sleep Talk",
			Description = "Si l'utilisateur dort, choisit aléatoirement une autre de ses attaques a utiliser.",
		},
		{
			NameKey = "Heal Bell",
			Description = "Soigne tous les Pokémon de l'équipe de l'utilisateur de tous les statuts majeurs. Echoue sur les Pokémon avec Anti-Bruit.",
		},
		{
			NameKey = "Return",
			Description = "La puissance varie de 1 a 102, maximale avec une amitié de 255. Si l'amitié de l'utilisateur est de 127 ou moins, Frustration est plus forte.",
		},
		{
			NameKey = "Present",
			Description = "40% de chance d'avoir une puissance de 40, 30% de 80, 10% de 120, et 20% de chance de soigner la cible de 1/4 de ses PV max.",
		},
		{
			NameKey = "Frustration",
			Description = "La puissance varie de 1 a 102, maximale avec une amitié de 0. Si l'amitié de l'utilisateur est de 128 ou plus, Retour est plus fort.",
		},
		{
			NameKey = "Safeguard",
			Description = "Pendant 5 tours, protège l'équipe de l'utilisateur de la plupart des altérations de statut et de la confusion.",
		},
		{
			NameKey = "Pain Split",
			Description = "Egalise les PV de l'utilisateur et de la cible en additionnant leurs PV actuels, puis en divisant par deux pour les répartir équitablement.",
		},
		{
			NameKey = "Sacred Fire",
			Description = "Inflige des dégâts et a 50% de chance de bruler la cible. Cette attaque dégèle d'abord son utilisateur s'il est gelé.",
		},
		{
			NameKey = "Magnitude",
			Description = "La puissance varie selon une valeur aléatoire et sa probabilité. En partant de valeur 4 et puissance 10, chaque valeur supplémentaire ajoute 20; puissance 150 a la valeur 10. Peut toucher un Pokémon utilisant Tunnel.",
		},
		{
			NameKey = "DynamicPunch",
			Description = "Inflige des dégâts et rend toujours la cible confuse, pendant 2 a 5 tours.",
		},
		{
			NameKey = "Megahorn",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "DragonBreath",
			Description = "Inflige des dégâts et a 30% de chance de paralyser la cible.",
		},
		{
			NameKey = "Baton Pass",
			Description = "Remplace l'utilisateur, en transmettant au Pokémon entrant tous les changements temporaires de stats ainsi que de nombreux autres effets et états.",
		},
		{
			NameKey = "Encore",
			Description = "Empêche la cible d'utiliser une autre attaque que la dernière utilisée, pendant 2 a 6 tours.",
		},
		{
			NameKey = "Pursuit",
			Description = "Si le Pokémon ciblé tente d'etre remplacé, la puissance de Poursuite double et l'attaque le frappe d'abord.",
		},
		{
			NameKey = "Rapid Spin",
			Description = "Inflige des dégâts et retire du terrain de l'utilisateur les effets d'entrave, Vampigraine et les pièges d'entrée comme Picots.",
		},
		{
			NameKey = "Sweet Scent",
			Description = "Réduit l'Esquive de tous les adversaires adjacents d'un niveau. Peut etre utilisée hors combat pour attirer un Pokémon sauvage.",
		},
		{
			NameKey = "Iron Tail",
			Description = "Inflige des dégâts et a 30% de chance de réduire la Défense de la cible d'un niveau.",
		},
		{
			NameKey = "Metal Claw",
			Description = "Inflige des dégâts et a 10% de chance d'augmenter l'Attaque de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Vital Throw",
			Description = "Attaque a priorité réduite, ce qui fait agir l'utilisateur après la plupart des autres attaques.",
		},
		{
			NameKey = "Morning Sun",
			Description = "Restaure les PV de l'utilisateur selon la météo: 1/2 sans météo, 2/3 sous le soleil, et 1/4 sous toute autre météo.",
		},
		{
			NameKey = "Synthesis",
			Description = "Restaure les PV de l'utilisateur selon la météo: 1/2 sans météo, 2/3 sous le soleil, et 1/4 sous toute autre météo.",
		},
		{
			NameKey = "Moonlight",
			Description = "Restaure les PV de l'utilisateur selon la météo: 1/2 sans météo, 2/3 sous le soleil, et 1/4 sous toute autre météo.",
		},
		{
			NameKey = "Hidden Power",
			Description = "La puissance et le type varient selon les IV, la puissance allant de 30 a 70. Riposte fonctionne toujours contre cette attaque, mais jamais Voile Miroir.",
		},
		{
			NameKey = "Cross Chop",
			Description = "Inflige des dégâts et augmente le taux de coup critique. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Twister",
			Description = "Inflige des dégâts et a 20% de chance d'apeurer chaque cible. Inflige le double de dégâts aux Pokémon utilisant Rebond ou Vol.",
		},
		{
			NameKey = "Rain Dance",
			Description = "Change la météo en pluie pendant 5 tours. Les attaques Eau gagnent 50% de puissance et les attaques Feu en perdent 50%. Tonnerre ignore précision et esquive.",
		},
		{
			NameKey = "Sunny Day",
			Description = "Change la météo en grand soleil pendant 5 tours. Les attaques Feu gagnent 50% de puissance et les attaques Eau en perdent 50%. La précision de Tonnerre passe a 50%.",
		},
		{
			NameKey = "Crunch",
			Description = "Inflige des dégâts et a 20% de chance de réduire la Défense Spéciale de la cible d'un niveau.",
		},
		{
			NameKey = "Mirror Coat",
			Description = "Si touché par une attaque de catégorie Spéciale, renvoie le double des dégâts reçus a l'attaquant.",
		},
		{
			NameKey = "Psych Up",
			Description = "Réinitialise les changements de stats de l'utilisateur puis copie tous les niveaux de stats de la cible: ATK DEF SPA SPD SPE ACC EVA.",
		},
		{
			NameKey = "ExtremeSpeed",
			Description = "Attaque a priorité augmentée, permettant d'agir avant la plupart des autres attaques.",
		},
		{
			NameKey = "AncientPower",
			Description = "Inflige des dégâts et a 10% de chance d'augmenter d'un niveau l'Attaque, la Défense, l'Attaque Spéciale, la Défense Spéciale et la Vitesse de l'utilisateur.",
		},
		{
			NameKey = "Shadow Ball",
			Description = "Inflige des dégâts et a 20% de chance de réduire la Défense Spéciale de la cible d'un niveau.",
		},
		{
			NameKey = "Future Sight",
			Description = "Verrouille les dégâts a l'utilisation selon l'Attaque Spéciale de l'utilisateur et la Défense Spéciale de la cible. Après 2 tours, inflige des dégâts a l'ennemi actuel. Attaque sans type: pas de STAB, touche Garde Mystik.",
		},
		{
			NameKey = "Rock Smash",
			Description = "Inflige des dégâts et a 50% de chance de réduire la Défense de la cible d'un niveau.",
		},
		{
			NameKey = "Whirlpool",
			Description = "Inflige des dégâts (doublés si l'adversaire utilise Plongée) et retire 1/16 des PV max de la cible pendant 2 a 5 tours. Empêche la cible de fuir ou d'etre remplacée.",
		},
		{
			NameKey = "Beat Up",
			Description = "Chaque Pokémon conscient et sans statut de l'équipe de l'utilisateur effectue une attaque indépendante, sans type et de puissance 10.",
		},
		{
			NameKey = "Fake Out",
			Description = "Attaque a priorité augmentée. Elle apeure toujours la cible, mais échoue si ce n'est pas la première attaque utilisée.",
		},
		{
			NameKey = "Uproar",
			Description = "Inflige des dégâts pendant 2 a 5 tours consécutifs. Réveille les Pokémon endormis et les empêche de s'endormir, sauf ceux avec Anti-Bruit.",
		},
		{
			NameKey = "Stockpile",
			Description = "Accumule de l'énergie, jusqu'a trois charges. Libérez-la avec Relachement pour infliger des dégâts ou Avale pour soigner des PV.",
		},
		{
			NameKey = "Spit Up",
			Description = "Consomme l'énergie accumulée par Stockage, 100 de puissance par charge (0 s'il n'y en a pas). Cette attaque ne peut pas faire de coup critique.",
		},
		{
			NameKey = "Swallow",
			Description = "Consomme l'énergie accumulée par Stockage et soigne l'utilisateur de 25%, 50% ou 100% des PV selon le nombre de charges consommées (0% s'il n'y en a pas).",
		},
		{
			NameKey = "Heat Wave",
			Description = "Inflige des dégâts et a 10% de chance de bruler la cible.",
		},
		{
			NameKey = "Hail",
			Description = "Change la météo en grêle pendant 5 tours. Les Pokémon perdent 1/16 de leurs PV max, sauf les types Glace.",
		},
		{
			NameKey = "Torment",
			Description = "Empêche la cible d'utiliser la meme attaque deux fois de suite. L'effet prend fin quand le Pokémon est remplacé.",
		},
		{
			NameKey = "Flatter",
			Description = "Augmente l'Attaque Spéciale de la cible d'un niveau et la rend confuse.",
		},
		{
			NameKey = "Will-O-Wisp",
			Description = "Brule la cible, inefficace contre les Pokémon de type Feu. Les Pokémon brulés infligent moitié moins de dégâts avec les attaques Physiques et perdent 1/8 de leurs PV max par tour.",
		},
		{
			NameKey = "Memento",
			Description = "L'utilisateur se met K.O. pour réduire de deux niveaux l'Attaque et l'Attaque Spéciale de la cible.",
		},
		{
			NameKey = "Facade",
			Description = "La puissance double si l'utilisateur est empoisonné, paralysé ou brulé. La réduction de dégâts due a la brulure s'applique toujours.",
		},
		{
			NameKey = "Focus Punch",
			Description = "Attaque a priorité réduite. Elle échoue si l'utilisateur subit d'abord des dégâts directs.",
		},
		{
			NameKey = "SmellingSalt",
			Description = "La puissance double contre une cible paralysée, mais soigne aussi sa paralysie.",
		},
		{
			NameKey = "Follow Me",
			Description = "Attaque a priorité augmentée. L'utilisateur redirige vers lui toutes les attaques ciblées des Pokémon ennemis.",
		},
		{
			NameKey = "Nature Power",
			Description = "Sable: Séisme, Bâtiment: Météores, Grotte: Ball'Ombre, Roche: Eboulement, Hautes herbes: Poudre Dodo, Herbes longues: Tranch'Herbe, Etang: Ecume, Mer: Surf, Sous l'eau: Hydrocanon.",
		},
		{
			NameKey = "Charge",
			Description = "L'utilisateur se charge et renforce sa prochaine attaque. Si cette attaque est de type Electrik, les dégâts infligés sont doublés.",
		},
		{
			NameKey = "Taunt",
			Description = "Empêche le Pokémon ciblé d'utiliser des attaques de catégorie Statut; celles qui ne sont ni Physiques ni Spéciales. Ignore Clonage. Cet effet dure 2 tours.",
		},
		{
			NameKey = "Helping Hand",
			Description = "Attaque a priorité augmentée. L'utilisateur augmente de 50% les dégâts de son allié pour ce tour uniquement.",
		},
		{
			NameKey = "Trick",
			Description = "Echange les objets tenus avec la cible. Echoue si utilisée par un Pokémon sauvage, si aucun des deux Pokémon n'a d'objet, ou contre un Clonage.",
		},
		{
			NameKey = "Role Play",
			Description = "Remplace le talent de l'utilisateur par celui de la cible. Echoue si le talent ciblé est Calque ou Garde Mystik. Certains talents comme Intimidation ne s'activent pas.",
		},
		{
			NameKey = "Wish",
			Description = "Aucun effet le tour d'utilisation. A la fin du tour suivant, le Pokémon occupant la position actuelle de l'utilisateur est soigné de la moitié de ses PV max.",
		},
		{
			NameKey = "Assist",
			Description = "Sélectionne aléatoirement une attaque admissible parmi celles connues par les autres Pokémon de l'équipe de l'utilisateur, y compris les K.O.",
		},
		{
			NameKey = "Ingrain",
			Description = "Restaure 1/16 des PV max a la fin de chaque tour. Empêche l'utilisateur d'etre remplacé, meme par des attaques comme Rugissement ou Cyclone.",
		},
		{
			NameKey = "Superpower",
			Description = "Inflige des dégâts, puis réduit d'un niveau l'Attaque et la Défense de l'utilisateur.",
		},
		{
			NameKey = "Magic Coat",
			Description = "Renvoie a l'ennemi la plupart des attaques de catégorie Statut, c'est-a-dire offensives mais ni Physiques ni Spéciales.",
		},
		{
			NameKey = "Recycle",
			Description = "Récupère un objet tenu, comme une Baie. Echoue si l'objet a été perdu via Larcin ou Sabotage.",
		},
		{
			NameKey = "Revenge",
			Description = "Attaque a priorité réduite. La puissance double si l'utilisateur est blessé par la cible durant le meme tour.",
		},
		{
			NameKey = "Brick Break",
			Description = "Retire Mur Lumière et Protection du côté adverse, puis inflige des dégâts. Retire ces effets meme contre les Pokémon Spectre.",
		},
		{
			NameKey = "Yawn",
			Description = "Donne sommeil a la cible. A la fin du tour suivant, le Pokémon somnolent s'endort.",
		},
		{
			NameKey = "Knock Off",
			Description = "Rend l'objet tenu de la cible inutilisable pour le reste du combat, meme si elle est remplacée.",
		},
		{
			NameKey = "Endeavor",
			Description = "Fait tomber les PV de la cible a la valeur actuelle des PV de l'utilisateur.",
		},
		{
			NameKey = "Eruption",
			Description = "A 150 de puissance aux PV max, puis diminue proportionnellement aux PV restants de l'utilisateur. Formule: 150 x PVactuels / PVmax.",
		},
		{
			NameKey = "Skill Swap",
			Description = "Echange les talents de l'utilisateur et de la cible. Cette information n'est pas affichée au joueur. Echoue contre Garde Mystik.",
		},
		{
			NameKey = "Imprison",
			Description = "Tant que l'utilisateur reste en combat, les adversaires ne peuvent pas utiliser les attaques que l'utilisateur connait aussi.",
		},
		{
			NameKey = "Refresh",
			Description = "Soigne l'utilisateur de la brulure, du poison ou de la paralysie. Ne peut pas soigner le sommeil si utilisée via Blabla Dodo.",
		},
		{
			NameKey = "Grudge",
			Description = "Si l'utilisateur est mis K.O. par une attaque directe ennemie, la dernière attaque utilisée perd tous ses PP. L'effet prend fin si l'utilisateur emploie une autre attaque.",
		},
		{
			NameKey = "Snatch",
			Description = "Attaque a priorité augmentée. Si un autre Pokémon tente d'utiliser une attaque de catégorie Statut bénéfique, l'utilisateur l'utilise a sa place.",
		},
		{
			NameKey = "Secret Power",
			Description = "30% de chance selon le terrain: Sable --ACC, Bâtiment paralysie, Grotte apeurement, Roche confusion, Hautes herbes poison, Herbes longues sommeil, Etang --SPD, Mer --ATK, Sous l'eau --DEF",
		},
		{
			NameKey = "Dive",
			Description = "Attaque au 2e tour. Peut toujours etre touché par Surf et Siphon, et subit alors le double de dégâts.",
		},
		{
			NameKey = "Arm Thrust",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique ou déclencher un talent de contact.",
		},
		{
			NameKey = "Camouflage",
			Description = "Change le type de l'utilisateur selon le terrain. Bâtiment: Normal, Sable: Sol, Grotte/roche: Roche, Hautes/herbes longues: Plante, Eau: Eau",
		},
		{
			NameKey = "Tail Glow",
			Description = "Augmente l'Attaque Spéciale de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Luster Purge",
			Description = "Inflige des dégâts et a 50% de chance de réduire la Défense Spéciale de la cible.",
		},
		{
			NameKey = "Mist Ball",
			Description = "Inflige des dégâts et a 50% de chance de réduire l'Attaque Spéciale de la cible.",
		},
		{
			NameKey = "FeatherDance",
			Description = "Réduit l'Attaque de la cible de deux niveaux.",
		},
		{
			NameKey = "Teeter Dance",
			Description = "Rend tous les autres Pokémon confus pendant 2 a 5 tours. 50% de chance de se blesser soi-meme comme avec une attaque Physique de puissance 40.",
		},
		{
			NameKey = "Blaze Kick",
			Description = "Inflige des dégâts et a 10% de chance de bruler la cible. A aussi un taux de coup critique augmenté. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Mud Sport",
			Description = "Réduit de 50% la puissance des attaques Electrik pour tous les Pokémon en combat. Cet effet dure jusqu'au remplacement de l'utilisateur.",
		},
		{
			NameKey = "Ice Ball",
			Description = "Inflige des dégâts sur 5 tours, en doublant de puissance a chaque coup consécutif. La puissance de base est doublée si l'utilisateur a utilisé Roulade auparavant.",
		},
		{
			NameKey = "Needle Arm",
			Description = "Inflige des dégâts et a 30% de chance d'apeurer la cible. Les dégâts sont doublés contre une cible ayant utilisé Lilliput.",
		},
		{
			NameKey = "Slack Off",
			Description = "Restaure jusqu'a 50% des PV max de l'utilisateur.",
		},
		{
			NameKey = "Hyper Voice",
			Description = "Inflige des dégâts a tous les adversaires adjacents. Les Pokémon avec Anti-Bruit ne sont pas affectés.",
		},
		{
			NameKey = "Poison Fang",
			Description = "Inflige des dégâts et a 30% de chance d'empoisonner gravement la cible.",
		},
		{
			NameKey = "Crush Claw",
			Description = "Inflige des dégâts et a 50% de chance de réduire la Défense de la cible d'un niveau.",
		},
		{
			NameKey = "Blast Burn",
			Description = "Inflige des dégâts puis force l'utilisateur a recharger au tour suivant.",
		},
		{
			NameKey = "Hydro Cannon",
			Description = "Inflige des dégâts puis force l'utilisateur a recharger au tour suivant.",
		},
		{
			NameKey = "Meteor Mash",
			Description = "Inflige des dégâts et a 20% de chance d'augmenter l'Attaque de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Astonish",
			Description = "Inflige des dégâts et a 30% de chance d'apeurer la cible. Les dégâts sont doublés contre une cible ayant utilisé Lilliput.",
		},
		{
			NameKey = "Weather Ball",
			Description = "La puissance double sous météo et le type change: Feu sous le soleil, Eau sous la pluie, Glace sous la grêle, Roche sous la tempete de sable.",
		},
		{
			NameKey = "Aromatherapy",
			Description = "Soigne tous les Pokémon de l'équipe de l'utilisateur de toutes les altérations de statut majeures.",
		},
		{
			NameKey = "Fake Tears",
			Description = "Réduit la Défense Spéciale de la cible de deux niveaux.",
		},
		{
			NameKey = "Air Cutter",
			Description = "Inflige des dégâts et a un taux de coup critique augmenté. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Overheat",
			Description = "Inflige des dégâts et réduit l'Attaque Spéciale de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Odor Sleuth",
			Description = "Annule les vérifications de précision contre la cible et permet aux attaques Combat et Normal de toucher un Pokémon Spectre.",
		},
		{
			NameKey = "Rock Tomb",
			Description = "Inflige des dégâts et réduit la Vitesse de l'adversaire d'un niveau.",
		},
		{
			NameKey = "Silver Wind",
			Description = "Inflige des dégâts et a 10% de chance d'augmenter d'un niveau l'Attaque, la Défense, l'Attaque Spéciale, la Défense Spéciale et la Vitesse de l'utilisateur.",
		},
		{
			NameKey = "Metal Sound",
			Description = "Réduit la Défense Spéciale de la cible de deux niveaux. Echoue contre les Pokémon avec Anti-Bruit.",
		},
		{
			NameKey = "GrassWhistle",
			Description = "Endort la cible pour 2 a 5 tours. Echoue contre Insomnia, Esprit Vital ou Anti-Bruit.",
		},
		{
			NameKey = "Tickle",
			Description = "Réduit d'un niveau l'Attaque et la Défense de la cible. Fonctionne meme si l'ennemi a un Clonage.",
		},
		{
			NameKey = "Cosmic Power",
			Description = "Augmente d'un niveau la Défense et la Défense Spéciale de l'utilisateur.",
		},
		{
			NameKey = "Water Spout",
			Description = "A 150 de puissance aux PV max, puis diminue proportionnellement aux PV restants de l'utilisateur. Formule: 150 x PVactuels / PVmax.",
		},
		{
			NameKey = "Signal Beam",
			Description = "Inflige des dégâts et a 10% de chance de rendre la cible confuse.",
		},
		{
			NameKey = "Shadow Punch",
			Description = "Inflige des dégâts et ignore les vérifications de précision pour toujours toucher, sauf si la cible est dans le tour semi-invulnérable d'une attaque comme Tunnel ou Vol.",
		},
		{
			NameKey = "Extrasensory",
			Description = "Inflige des dégâts et a 10% de chance d'apeurer la cible. Les dégâts sont doublés contre une cible ayant utilisé Lilliput.",
		},
		{
			NameKey = "Sky Uppercut",
			Description = "Inflige des dégâts et peut toucher les Pokémon pendant les tours semi-invulnérables de Vol et Rebond.",
		},
		{
			NameKey = "Sand Tomb",
			Description = "Inflige des dégâts et retire 1/16 des PV max de la cible pendant 2 a 5 tours. Empêche la cible de fuir ou d'etre remplacée.",
		},
		{
			NameKey = "Sheer Cold",
			Description = "Attaque K.O. en un coup. Sa précision augmente de 1% par niveau au-dessus de la cible. Echoue si la cible est d'un niveau supérieur.",
		},
		{
			NameKey = "Muddy Water",
			Description = "Inflige des dégâts et a 30% de chance de réduire la précision de chaque cible d'un niveau.",
		},
		{
			NameKey = "Bullet Seed",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Aerial Ace",
			Description = "Inflige des dégâts et ignore les vérifications de précision pour toujours toucher, sauf si la cible est dans le tour semi-invulnérable d'une attaque comme Tunnel ou Vol.",
		},
		{
			NameKey = "Icicle Spear",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Iron Defense",
			Description = "Augmente la Défense de l'utilisateur de deux niveaux.",
		},
		{
			NameKey = "Block",
			Description = "Empêche la cible de fuir ou d'etre remplacée. Un Pokémon peut quand meme fuir avec Fuite ou en tenant une Balle Fumée.",
		},
		{
			NameKey = "Howl",
			Description = "Augmente l'Attaque de l'utilisateur d'un niveau.",
		},
		{
			NameKey = "Dragon Claw",
			Description = "Inflige des dégâts sans effet secondaire.",
		},
		{
			NameKey = "Frenzy Plant",
			Description = "Inflige des dégâts puis force l'utilisateur a recharger au tour suivant.",
		},
		{
			NameKey = "Bulk Up",
			Description = "Augmente d'un niveau l'Attaque et la Défense de l'utilisateur.",
		},
		{
			NameKey = "Bounce",
			Description = "Attaque au 2e tour avec 30% de chance de paralyser la cible. Peut toujours etre touché par Tornade, Casse-Brique Céleste, Tonnerre et Draco-Souffle.",
		},
		{
			NameKey = "Mud Shot",
			Description = "Inflige des dégâts puis réduit la Vitesse de la cible d'un niveau.",
		},
		{
			NameKey = "Poison Tail",
			Description = "Inflige des dégâts et a 10% de chance d'empoisonner la cible. A aussi un taux de coup critique augmenté. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Covet",
			Description = "Vole l'objet tenu de la cible si elle en a un. Un objet ne peut pas etre volé si la cible a Glue.",
		},
		{
			NameKey = "Volt Tackle",
			Description = "L'utilisateur subit des dégâts de recul égaux a 1/3 des dégâts infligés.",
		},
		{
			NameKey = "Magical Leaf",
			Description = "Inflige des dégâts et ignore les vérifications de précision pour toujours toucher, sauf si la cible est dans le tour semi-invulnérable d'une attaque comme Tunnel ou Vol.",
		},
		{
			NameKey = "Water Sport",
			Description = "Réduit de 50% la puissance des attaques Feu pour tous les Pokémon en combat. Cet effet dure jusqu'au remplacement de l'utilisateur.",
		},
		{
			NameKey = "Calm Mind",
			Description = "Augmente d'un niveau l'Attaque Spéciale et la Défense Spéciale de l'utilisateur.",
		},
		{
			NameKey = "Leaf Blade",
			Description = "Inflige des dégâts et a un taux de coup critique augmenté. (+1 niveau = 1/8 soit 12,5%)",
		},
		{
			NameKey = "Dragon Dance",
			Description = "Augmente d'un niveau l'Attaque et la Vitesse de l'utilisateur.",
		},
		{
			NameKey = "Rock Blast",
			Description = "Frappe 2 a 5 fois en un tour. Deux: 37,5%, Trois: 37,5%, Quatre: 12,5%, Cinq: 12,5%. Chaque coup peut etre critique.",
		},
		{
			NameKey = "Shock Wave",
			Description = "Inflige des dégâts et ignore les vérifications de précision pour toujours toucher, sauf si la cible est dans le tour semi-invulnérable d'une attaque comme Tunnel ou Vol.",
		},
		{
			NameKey = "Water Pulse",
			Description = "Inflige des dégâts et a 20% de chance de rendre la cible confuse.",
		},
		{
			NameKey = "Doom Desire",
			Description = "Verrouille les dégâts a l'utilisation selon l'Attaque de l'utilisateur et la Défense de la cible. Après 2 tours, inflige des dégâts a l'ennemi actuel. Attaque sans type: pas de STAB, touche Garde Mystik.",
		},
		{
			NameKey = "Psycho Boost",
			Description = "Inflige des dégâts et réduit l'Attaque Spéciale de l'utilisateur de deux niveaux.",
		},
	},
	-- The list of Pokémon abilities below must remain in the same order
	AbilityNames = {
		"Puanteur", --Puanteur english:Stench
		"Crachin", --Crachin english:Drizzle
		"Turbo", --Turbo english:Speed Boost
		"Armurbaston", --Armurbaston english:Battle Armor
		"Fermete", --Fermete english:Sturdy
		"Moiteur", --Moiteur english:Damp
		"Echauffement", --Echauffement english:Limber
		"Voile Sable", --Voile Sable english:Sand Veil
		"Statik", --Statik english:Static
		"Absorb Volt", --Absorb Volt english:Volt Absorb
		"Absorb Eau", --Absorb Eau english:Water Absorb
		"Benet", --Benet english:Oblivious
		"Ciel Gris", --Ciel Gris english:Cloud Nine
		"Oeil Compose", --Oeil Compose english:Compoundeyes
		"Insomnia", --Insomnia english:Insomnia
		"Deguisement", --Deguisement english:Color Change
		"Vaccin", --Vaccin english:Immunity
		"Torche", --Torche english:Flash Fire
		"Ecran Poudre", --Ecran Poudre english:Shield Dust
		"Tempo Perso", --Tempo Perso english:Own Tempo
		"Ventouse", --Ventouse english:Suction Cups
		"Intimidation", --Intimidation english:Intimidate
		"Marque Ombre", --Marque Ombre english:Shadow Tag
		"Peau Dure", --Peau Dure english:Rough Skin
		"Garde Mystik", --Garde Mystik english:Wonder Guard
		"Levitation", --Levitation english:Levitate
		"Pose Spore", --Pose Spore english:Effect Spore
		"Synchro", --Synchro english:Synchronize
		"Corps Sain", --Corps Sain english:Clear Body
		"Medic Nature", --Medic Nature english:Natural Cure
		"Paratonnerre", --Paratonnerre english:Lightningrod
		"Serenite", --Serenite english:Serene Grace
		"Glissade", --Glissade english:Swift Swim
		"Chlorophyle", --Chlorophyle english:Chlorophyll
		"Lumiatirance", --Lumiatirance english:Illuminate
		"Calque", --Calque english:Trace
		"Coloforce", --Coloforce english:Huge Power
		"Point Poison", --Point Poison english:Poison Point
		"Attention", --Attention english:Inner Focus
		"Armumagma", --Armumagma english:Magma Armor
		"Ignifu-Voile", --Ignifu-Voile english:Water Veil
		"Magnepiege", --Magnepiege english:Magnet Pull
		"Anti-Bruit", --Anti-Bruit english:Soundproof
		"Cuvette", --Cuvette english:Rain Dish
		"Sable Volant", --Sable Volant english:Sand Stream
		"Pression", --Pression english:Pressure
		"Isograisse", --Isograisse english:Thick Fat
		"Matinal", --Matinal english:Early Bird
		"Corps Ardent", --Corps Ardent english:Flame Body
		"Fuite", --Fuite english:Run Away
		"Regard Vif", --Regard Vif english:Keen Eye
		"Hyper Cutter", --Hyper Cutter english:Hyper Cutter
		"Ramassage", --Ramassage english:Pickup
		"Absenteisme", --Absenteisme english:Truant
		"Agitation", --Agitation english:Hustle
		"Joli Sourire", --Joli Sourire english:Cute Charm
		"Plus", --Plus english:Plus
		"Minus", --Minus english:Minus
		"Meteo", --Meteo english:Forecast
		"Glue", --Glue english:Sticky Hold
		"Mue", --Mue english:Shed Skin
		"Cran", --Cran english:Guts
		"Ecaille Spe.", --Ecaille Spe. english:Marvel Scale
		"Suintement", --Suintement english:Liquid Ooze
		"Engrais", --Engrais english:Overgrow
		"Brasier", --Brasier english:Blaze
		"Torrent", --Torrent english:Torrent
		"Essaim", --Essaim english:Swarm
		"Tete De Roc", --Tete De Roc english:Rock Head
		"Secheresse", --Secheresse english:Drought
		"Piege", --Piege english:Arena Trap
		"Esprit Vital", --Esprit Vital english:Vital Spirit
		"Ecran Fumee", --Ecran Fumee english:White Smoke
		"Force Pure", --Force Pure english:Pure Power
		"Coque Armure", --Coque Armure english:Shell Armor
		"Cacophonie", --Cacophonie english:Cacophony
		"Air Lock", --Air Lock english:Air Lock
	},
	-- The list below must remain in the same order.
	-- These are custom hand-written ability descriptions, only edit the "Description" and "DescriptionEmerald" values
	AbilityDescriptions = {
		{
			NameKey = "Stench",
			Description = "En tete d'équipe, réduit de 50% le taux de rencontres sauvages.",
			DescriptionEmerald = "Dans la Pyramide de Combat, le taux de rencontres sauvages n'est réduit que de 25%.",
		},
		{
			NameKey = "Drizzle",
			Description = "Déclenche la pluie a l'arrivée en combat. Sous la pluie, les attaques Eau gagnent 50% de puissance et les attaques Feu en perdent 50%. Tonnerre touche toujours, Lance-Soleil inflige 50% de dégâts en moins, et Rayon Lune, Synthèse et Aurore soignent 1/4 des PV max.",
		},
		{
			NameKey = "Speed Boost",
			Description = "A la fin de chaque tour, augmente la Vitesse d'un niveau.",
		},
		{
			NameKey = "Battle Armor",
			Description = "Empêche ce Pokémon de subir des coups critiques.",
		},
		{
			NameKey = "Sturdy",
			Description = "Empêche d'etre mis K.O. par les attaques K.O. en un coup (Abime, Empal'Korne, Guillotine, Glaciation).",
		},
		{
			NameKey = "Damp",
			Description = "Empêche les Pokémon alliés et adverses d'utiliser les attaques d'autodestruction (Destruction, Explosion).",
		},
		{
			NameKey = "Limber",
			Description = "Ne peut pas etre paralysé. Obtenir ce talent, par exemple via Echange, soigne la paralysie.",
		},
		{
			NameKey = "Sand Veil",
			Description = "Augmente l'Esquive de 20% pendant une tempete de sable, et ce Pokémon ne subit pas de dégâts de fin de tour sous tempete de sable.",
			DescriptionEmerald = "En tete d'équipe, réduit de 50% le taux de rencontres sauvages pendant une tempete de sable.",
		},
		{
			NameKey = "Static",
			Description = "Lorsqu'il est touché par une attaque de contact, 1/3 de chance de paralyser l'attaquant.",
			DescriptionEmerald = "En tete d'équipe, les rencontres sauvages ont 50% de chance d'etre contre un Pokémon Electrik, si possible.",
		},
		{
			NameKey = "Volt Absorb",
			Description = "Restaure 25% des PV max au lieu de subir des dégâts si touché par une attaque Electrik offensive.",
		},
		{
			NameKey = "Water Absorb",
			Description = "Restaure 25% des PV max au lieu de subir des dégâts si touché par une attaque Eau offensive.",
		},
		{
			NameKey = "Oblivious",
			Description = "Ne peut pas etre charmé. Obtenir ce talent, par exemple via Echange, soigne l'attirance.",
		},
		{
			NameKey = "Cloud Nine",
			Description = "Annule tous les effets de la météo, sans mettre fin a la météo.",
		},
		{
			NameKey = "Compoundeyes",
			Description = "Augmente la Précision des attaques de 30% (ex: Tonnerre a 70% de précision; avec ce talent, il passe a 70% x 1,3 = 91%).",
			DescriptionEmerald = "Augmente la chance de rencontrer un Pokémon sauvage tenant un objet.",
		},
		{
			NameKey = "Insomnia",
			Description = "Ne peut pas s'endormir. Si ce Pokémon utilise Repos, l'attaque échoue. Obtenir ce talent, par exemple via Echange, soigne le sommeil.",
		},
		{
			NameKey = "Color Change",
			Description = "Quand ce Pokémon est touché par une attaque offensive, son type devient celui de l'attaque reçue.",
		},
		{
			NameKey = "Immunity",
			Description = "Ne peut pas etre empoisonné. Obtenir ce talent, par exemple via Echange, soigne le poison.",
		},
		{
			NameKey = "Flash Fire",
			Description = "Immunise contre les attaques Feu. La première fois que ce Pokémon est touché par une attaque Feu, ses propres attaques Feu gagnent 50% de puissance.",
		},
		{
			NameKey = "Shield Dust",
			Description = "Insensible aux effets secondaires des attaques offensives adverses. Par exemple, un Pokémon avec ce talent ne peut pas etre gelé par Blizzard ni apeuré par Bluff.",
		},
		{
			NameKey = "Own Tempo",
			Description = "Ne peut pas etre confus. Obtenir ce talent, par exemple via Echange, soigne la confusion.",
		},
		{
			NameKey = "Suction Cups",
			Description = "Empêche ce Pokémon d'etre forcé a quitter le terrain.",
			DescriptionEmerald = "Augmente les chances d'avoir une touche a la peche.",
		},
		{
			NameKey = "Intimidate",
			Description = "Réduit d'un niveau l'Attaque de tous les Pokémon adverses quand ce Pokémon entre en combat.",
			DescriptionEmerald = "En tete d'équipe, 50% de chance d'éviter une rencontre sauvage qui aurait été avec un Pokémon ayant 5 niveaux ou plus de moins.",
		},
		{
			NameKey = "Shadow Tag",
			Description = "Empêche les Pokémon adverses de fuir ou d'etre remplacés.",
		},
		{
			NameKey = "Rough Skin",
			Description = "Lorsqu'il est touché par une attaque de contact, l'attaquant perd 1/16 de ses PV max.",
		},
		{
			NameKey = "Wonder Guard",
			Description = "Immunise contre toutes les attaques offensives qui ne sont pas super efficaces, sauf Lutte, Baston, Prescience et Carnareket. Ne peut pas etre copié par Copie ni échangé par Echange.",
		},
		{
			NameKey = "Levitate",
			Description = "Immunise contre les attaques Sol. Cette immunité est perdue si ce Pokémon utilise Racines.",
		},
		{
			NameKey = "Effect Spore",
			Description = "Lorsqu'il est touché par une attaque de contact, 10% de chance d'infliger a l'attaquant le poison, la paralysie ou le sommeil, avec une chance égale pour chacun. L'altération tirée au sort peut échouer si l'attaquant y est immunisé.",
		},
		{
			NameKey = "Synchronize",
			Description = "Quand un Pokémon inflige poison, paralysie ou brulure a ce Pokémon, il reçoit la meme altération en retour, si possible.",
			DescriptionEmerald = "En tete d'équipe, un Pokémon sauvage rencontré a 50% de chance d'avoir la meme nature que ce Pokémon.",
		},
		{
			NameKey = "Clear Body",
			Description = "Empêche les baisses de stats provoquées par les attaques et talents des Pokémon adverses.",
		},
		{
			NameKey = "Natural Cure",
			Description = "Soigne toute altération de statut lors du remplacement.",
		},
		{
			NameKey = "Lightningrod",
			Description = "Toutes les attaques Electrik adverses a cible unique sont redirigées vers ce Pokémon.",
			DescriptionEmerald = "En tete d'équipe, les Dresseurs enregistrés dans le Match Call du PokéNav appellent deux fois plus souvent.",
		},
		{
			NameKey = "Serene Grace",
			Description = "Double les chances d'effets secondaires des attaques de ce Pokémon.",
		},
		{
			NameKey = "Swift Swim",
			Description = "Double la Vitesse sous la pluie.",
		},
		{
			NameKey = "Chlorophyll",
			Description = "Double la Vitesse quand la météo est ensoleillée.",
		},
		{
			NameKey = "Illuminate",
			Description = "Augmente de 100% le taux de rencontres sauvages.",
		},
		{
			NameKey = "Trace",
			Description = "Copie le talent d'un Pokémon adverse aléatoire quand ce Pokémon entre en combat.",
		},
		{
			NameKey = "Huge Power",
			Description = "Double l'Attaque de ce Pokémon.",
		},
		{
			NameKey = "Poison Point",
			Description = "Lorsqu'il est touché par une attaque de contact, 1/3 de chance d'empoisonner l'attaquant.",
		},
		{
			NameKey = "Inner Focus",
			Description = "Empêche l'apeurement.",
		},
		{
			NameKey = "Magma Armor",
			Description = "Ne peut pas etre gelé. Obtenir ce talent, par exemple via Echange, soigne le gel.",
			DescriptionEmerald = "Réduit de moitié le temps nécessaire pour faire éclore un Oeuf.",
		},
		{
			NameKey = "Water Veil",
			Description = "Ne peut pas etre brulé. Obtenir ce talent, par exemple via Echange, soigne la brulure.",
		},
		{
			NameKey = "Magnet Pull",
			Description = "Empêche les Pokémon Acier alliés et adverses d'etre remplacés.",
			DescriptionEmerald = "En tete d'équipe, les rencontres sauvages ont 50% de chance d'etre contre un Pokémon Acier, si possible.",
		},
		{
			NameKey = "Soundproof",
			Description = "Immunisé contre les attaques sonores. Ces attaques sont: Siffl'Herbe, Rugissement, Glas de Soin, Brouhaha, Strido-Son, Requiem, Rugissement, Grincement, Berceuse, Ronflement, Ultrason, Brouhaha.",
		},
		{
			NameKey = "Rain Dish",
			Description = "Soigne ce Pokémon de 1/16 de ses PV max a la fin de chaque tour sous la pluie.",
		},
		{
			NameKey = "Sand Stream",
			Description = "Déclenche une tempete de sable a l'arrivée en combat. A la fin de chaque tour sous tempete de sable, chaque Pokémon perd 1/16 de ses PV max, sauf les types Roche, Sol et Acier.",
		},
		{
			NameKey = "Pressure",
			Description = "Quand une attaque cible ce Pokémon, 1 PP supplémentaire est consommé. Un Pokémon peut quand meme le cibler avec une attaque qui n'a plus que 1 PP.",
			DescriptionEmerald = "En tete d'équipe, un Pokémon sauvage rencontré a 50% de chance d'etre au niveau maximal possible.",
		},
		{
			NameKey = "Thick Fat",
			Description = "Les dégâts reçus des attaques Glace ou Feu sont divisés par deux.",
		},
		{
			NameKey = "Early Bird",
			Description = "Le nombre de tours de sommeil est divisé par deux, arrondi a l'inférieur.",
		},
		{
			NameKey = "Flame Body",
			Description = "Lorsqu'il est touché par une attaque de contact, 1/3 de chance de bruler l'attaquant.",
			DescriptionEmerald = "Réduit de moitié le temps nécessaire pour faire éclore un Oeuf.",
		},
		{
			NameKey = "Run Away",
			Description = "La fuite face aux Pokémon sauvages réussit toujours.",
		},
		{
			NameKey = "Keen Eye",
			Description = "La Précision de ce Pokémon ne peut pas etre réduite.",
			DescriptionEmerald = "En tete d'équipe, 50% de chance d'éviter une rencontre sauvage qui aurait été avec un Pokémon ayant 5 niveaux ou plus de moins.",
		},
		{
			NameKey = "Hyper Cutter",
			Description = "L'Attaque de ce Pokémon ne peut pas etre réduite par d'autres Pokémon.",
			DescriptionEmerald = "Si ce Pokémon utilise Coupe hors combat, le rayon d'herbes hautes coupées est augmenté de 1.",
		},
		{
			NameKey = "Pickup",
			Description = "Après avoir gagné un combat, ce Pokémon a 10% de chance de tenir un objet s'il n'en tenait pas deja un.",
			DescriptionEmerald = "Les objets obtenus varient selon le niveau de ce Pokémon, ou le niveau actuel de la Pyramide de Combat.",
		},
		{
			NameKey = "Truant",
			Description = "Un tour sur deux, au lieu d'agir en combat, ce Pokémon paresse et ne fait rien.",
		},
		{
			NameKey = "Hustle",
			Description = "Augmente l'Attaque de 50%, mais réduit la Précision des attaques Physiques de 20%.",
			DescriptionEmerald = "En tete d'équipe, un Pokémon sauvage rencontré a 50% de chance d'etre au niveau maximal possible.",
		},
		{
			NameKey = "Cute Charm",
			Description = "Lorsqu'il est touché par une attaque de contact, 1/3 de chance de charmer l'attaquant. N'a aucun effet si ce Pokémon est sans genre ou du meme genre que l'attaquant.",
			DescriptionEmerald = "En tete d'équipe, une rencontre sauvage a 2/3 de chance d'etre forcée au genre opposé de ce Pokémon, si possible.",
		},
		{
			NameKey = "Plus",
			Description = "En Combat Duo, si un Pokémon actif a le talent Minus, l'Attaque Spéciale de ce Pokémon augmente de 50%.",
		},
		{
			NameKey = "Minus",
			Description = "En Combat Duo, si un Pokémon actif a le talent Plus, l'Attaque Spéciale de ce Pokémon augmente de 50%.",
		},
		{
			NameKey = "Forecast",
			Description = "Le type de Morphéo change avec la météo: Feu sous le soleil, Eau sous la pluie, Glace sous la grêle. Ciel Gris et Air Lock annulent cet effet. Ce talent n'a aucun effet si un autre Pokémon que Morphéo l'obtient.",
		},
		{
			NameKey = "Sticky Hold",
			Description = "L'objet tenu de ce Pokémon ne peut pas etre volé ni retiré.",
			DescriptionEmerald = "Augmente les chances d'avoir une touche a la peche.",
		},
		{
			NameKey = "Shed Skin",
			Description = "A la fin de chaque tour, 1/3 de chance de soigner une altération de statut majeure (brulure, poison, paralysie, gel, sommeil).",
		},
		{
			NameKey = "Guts",
			Description = "Augmente l'Attaque de ce Pokémon de 50% s'il est affecté par une altération de statut majeure (brulure, poison, paralysie, gel, sommeil), et ignore la baisse d'Attaque liée a la brulure.",
		},
		{
			NameKey = "Marvel Scale",
			Description = "Augmente la Défense de ce Pokémon de 50% s'il est affecté par une altération de statut majeure (brulure, poison, paralysie, gel, sommeil).",
		},
		{
			NameKey = "Liquid Ooze",
			Description = "Les attaques drainantes utilisées contre ce Pokémon font perdre a l'attaquant les PV qu'il aurait normalement récupérés.",
		},
		{
			NameKey = "Overgrow",
			Description = "Si ce Pokémon est a 1/3 de ses PV max ou moins, la puissance de ses attaques Plante augmente de 50%.",
		},
		{
			NameKey = "Blaze",
			Description = "Si ce Pokémon est a 1/3 de ses PV max ou moins, la puissance de ses attaques Feu augmente de 50%.",
		},
		{
			NameKey = "Torrent",
			Description = "Si ce Pokémon est a 1/3 de ses PV max ou moins, la puissance de ses attaques Eau augmente de 50%.",
		},
		{
			NameKey = "Swarm",
			Description = "Si ce Pokémon est a 1/3 de ses PV max ou moins, la puissance de ses attaques Insecte augmente de 50%.",
			DescriptionEmerald = "Augmente la fréquence a laquelle les cris de Pokémon sauvages sont entendus hors combat.",
		},
		{
			NameKey = "Rock Head",
			Description = "Empêche les dégâts de recul des attaques, sauf ceux de Lutte.",
		},
		{
			NameKey = "Drought",
			Description = "Déclenche le soleil a l'arrivée en combat. Sous le soleil, les attaques Feu gagnent 50% de puissance et les attaques Eau en perdent 50%. Supprime le tour de charge de Lance-Soleil, réduit la Précision de Tonnerre a 50%, et fait soigner Rayon Lune, Synthèse et Aurore de 2/3 des PV max.",
		},
		{
			NameKey = "Arena Trap",
			Description = "Empêche les Pokémon adverses de fuir ou d'etre remplacés, sauf les types Vol et les Pokémon avec Lévitation.",
			DescriptionEmerald = "Augmente de 100% le taux de rencontres sauvages.",
		},
		{
			NameKey = "Vital Spirit",
			Description = "Ne peut pas s'endormir. Si ce Pokémon tente d'utiliser Repos, l'attaque échoue. Obtenir ce talent, par exemple via Echange, soigne le sommeil.",
			DescriptionEmerald = "En tete d'équipe, une rencontre sauvage a 50% de chance d'etre au niveau maximal possible pour cette espèce.",
		},
		{
			NameKey = "White Smoke",
			Description = "Empêche les baisses de stats provoquées par les attaques et talents des Pokémon adverses.",
			DescriptionEmerald = "En tete d'équipe, réduit de 50% le taux de rencontres sauvages.",
		},
		{
			NameKey = "Pure Power",
			Description = "Double l'Attaque de ce Pokémon.",
		},
		{
			NameKey = "Shell Armor",
			Description = "Empêche ce Pokémon de subir des coups critiques.",
		},
		{
			NameKey = "Cacophony",
			Description = "Immunisé contre les attaques sonores. Ces attaques sont: Siffl'Herbe, Rugissement, Glas de Soin, Brouhaha, Strido-Son, Requiem, Rugissement, Grincement, Berceuse, Ronflement, Ultrason, Brouhaha.",
		},
		{
			NameKey = "Air Lock",
			Description = "Annule tous les effets de la météo, sans mettre fin a la météo.",
		},
	},
	-- The list of item names below must remain in the same order
	ItemNames = {
		"Master Ball", --Master Ball english:Master Ball
		"Hyper Ball", --Hyper Ball english:Ultra Ball
		"Super Ball", --Super Ball english:Great Ball
		"Poké Ball", --Poké Ball english:Poke Ball
		"Safari Ball", --Safari Ball english:Safari Ball
		"Filet Ball", --Filet Ball english:Net Ball
		"Scuba Ball", --Scuba Ball english:Dive Ball
		"Faiblo Ball", --Faiblo Ball english:Nest Ball
		"Bis Ball", --Bis Ball english:Repeat Ball
		"Chrono Ball", --Chrono Ball english:Timer Ball
		"Luxe Ball", --Luxe Ball english:Luxury Ball
		"Honor Ball", --Honor Ball english:Premier Ball
		"Potion", --Potion english:Potion
		"Antidote", --Antidote english:Antidote
		"Anti-Brule", --Anti-Brule english:Burn Heal
		"Antigel", --Antigel english:Ice Heal
		"Reveil", --Reveil english:Awakening
		"Anti-Para", --Anti-Para english:Parlyz Heal
		"Guerison", --Guerison english:Full Restore
		"Potion Max", --Potion Max english:Max Potion
		"Hyper Potion", --Hyper Potion english:Hyper Potion
		"Super Potion", --Super Potion english:Super Potion
		"Total Soin", --Total Soin english:Full Heal
		"Rappel", --Rappel english:Revive
		"Rappel Max", --Rappel Max english:Max Revive
		"Eau Fraiche", --Eau Fraiche english:Fresh Water
		"Soda Cool", --Soda Cool english:Soda Pop
		"Limonade", --Limonade english:Lemonade
		"Lait Meumeu", --Lait Meumeu english:Moomoo Milk
		"Poudrenergie", --Poudrenergie english:EnergyPowder
		"Racinenergie", --Racinenergie english:Energy Root
		"Poudre Soin", --Poudre Soin english:Heal Powder
		"Herbe Rappel", --Herbe Rappel english:Revival Herb
		"Huile", --Huile english:Ether
		"Huile Max", --Huile Max english:Max Ether
		"Elixir", --Elixir english:Elixir
		"Max Elixir", --Max Elixir english:Max Elixir
		"Lava Cookie", --Lava Cookie english:Lava Cookie
		"Flute Bleue", --Flute Bleue english:Blue Flute
		"Flute Jaune", --Flute Jaune english:Yellow Flute
		"Flute Rouge", --Flute Rouge english:Red Flute
		"Flute Noire", --Flute Noire english:Black Flute
		"Fluteblanche", --Fluteblanche english:White Flute
		"Jus De Baie", --Jus De Baie english:Berry Juice
		"Cendresacree", --Cendresacree english:Sacred Ash
		"Sel Trefonds", --Sel Trefonds english:Shoal Salt
		"Co. Trefonds", --Co. Trefonds english:Shoal Shell
		"Tesson Rouge", --Tesson Rouge english:Red Shard
		"Tesson Bleu", --Tesson Bleu english:Blue Shard
		"Tesson Jaune", --Tesson Jaune english:Yellow Shard
		"Tesson Vert", --Tesson Vert english:Green Shard
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
		"Pv Plus", --Pv Plus english:HP Up
		"Proteine", --Proteine english:Protein
		"Fer", --Fer english:Iron
		"Carbone", --Carbone english:Carbos
		"Calcium", --Calcium english:Calcium
		"Super Bonbon", --Super Bonbon english:Rare Candy
		"Pp Plus", --Pp Plus english:PP Up
		"Zinc", --Zinc english:Zinc
		"Pp Max", --Pp Max english:PP Max
		"????????", --???????? english:unknown
		"Defense Spec", --Defense Spec english:Guard Spec.
		"Muscle +", --Muscle + english:Dire Hit
		"Attaque +", --Attaque + english:X Attack
		"Defense +", --Defense + english:X Defend
		"Vitesse +", --Vitesse + english:X Speed
		"Precision +", --Precision + english:X Accuracy
		"Special +", --Special + english:X Special
		"Poképoupee", --Poképoupee english:Poke Doll
		"Queue Skitty", --Queue Skitty english:Fluffy Tail
		"????????", --???????? english:unknown
		"Superepousse", --Superepousse english:Super Repel
		"Max Repousse", --Max Repousse english:Max Repel
		"Corde Sortie", --Corde Sortie english:Escape Rope
		"Repousse", --Repousse english:Repel
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Pierresoleil", --Pierresoleil english:Sun Stone
		"Pierre Lune", --Pierre Lune english:Moon Stone
		"Pierre Feu", --Pierre Feu english:Fire Stone
		"Pierrefoudre", --Pierrefoudre english:Thunderstone
		"Pierre Eau", --Pierre Eau english:Water Stone
		"Pierreplante", --Pierreplante english:Leaf Stone
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Petit Champi", --Petit Champi english:TinyMushroom
		"Gros Champi", --Gros Champi english:Big Mushroom
		"????????", --???????? english:unknown
		"Perle", --Perle english:Pearl
		"Grande Perle", --Grande Perle english:Big Pearl
		"Pouss.etoile", --Pouss.etoile english:Stardust
		"Morc. Etoile", --Morc. Etoile english:Star Piece
		"Pepite", --Pepite english:Nugget
		"Ecaillecoeur", --Ecaillecoeur english:Heart Scale
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Lettre Oranj", --Lettre Oranj english:Orange Mail
		"Lettre Port", --Lettre Port english:Harbor Mail
		"Lettre Brill", --Lettre Brill english:Glitter Mail
		"Lettre Meca", --Lettre Meca english:Mech Mail
		"Lettre Bois", --Lettre Bois english:Wood Mail
		"Lettre Vague", --Lettre Vague english:Wave Mail
		"Lettre Bulle", --Lettre Bulle english:Bead Mail
		"Lettre Ombre", --Lettre Ombre english:Shadow Mail
		"Lettre Tropi", --Lettre Tropi english:Tropic Mail
		"Lettre Songe", --Lettre Songe english:Dream Mail
		"Lettre Cool", --Lettre Cool english:Fab Mail
		"Lettre Retro", --Lettre Retro english:Retro Mail
		"Baie Ceriz", --Baie Ceriz english:Cheri Berry
		"Baie Maron", --Baie Maron english:Chesto Berry
		"Baie Pecha", --Baie Pecha english:Pecha Berry
		"Baie Fraive", --Baie Fraive english:Rawst Berry
		"Baie Willia", --Baie Willia english:Aspear Berry
		"Baie Mepo", --Baie Mepo english:Leppa Berry
		"Baie Oran", --Baie Oran english:Oran Berry
		"Baie Kika", --Baie Kika english:Persim Berry
		"Baie Prine", --Baie Prine english:Lum Berry
		"Baie Sitrus", --Baie Sitrus english:Sitrus Berry
		"Baie Figuy", --Baie Figuy english:Figy Berry
		"Baie Wiki", --Baie Wiki english:Wiki Berry
		"Baie Mago", --Baie Mago english:Mago Berry
		"Baie Gowav", --Baie Gowav english:Aguav Berry
		"Baie Papaya", --Baie Papaya english:Iapapa Berry
		"Baie Framby", --Baie Framby english:Razz Berry
		"Baie Remu", --Baie Remu english:Bluk Berry
		"Baie Nanab", --Baie Nanab english:Nanab Berry
		"Baie Repoi", --Baie Repoi english:Wepear Berry
		"Baie Nanana", --Baie Nanana english:Pinap Berry
		"Baie Grena", --Baie Grena english:Pomeg Berry
		"Baie Alga", --Baie Alga english:Kelpsy Berry
		"Baie Qualot", --Baie Qualot english:Qualot Berry
		"Baie Lonme", --Baie Lonme english:Hondew Berry
		"Baie Resin", --Baie Resin english:Grepa Berry
		"Baie Tamato", --Baie Tamato english:Tamato Berry
		"Baie Siam", --Baie Siam english:Cornn Berry
		"Baie Mangou", --Baie Mangou english:Magost Berry
		"Baie Rabuta", --Baie Rabuta english:Rabuta Berry
		"Baie Tronci", --Baie Tronci english:Nomel Berry
		"Baie Kiwan", --Baie Kiwan english:Spelon Berry
		"Baie Palma", --Baie Palma english:Pamtre Berry
		"Baie Stekpa", --Baie Stekpa english:Watmel Berry
		"Baie Durin", --Baie Durin english:Durin Berry
		"Baie Myrte", --Baie Myrte english:Belue Berry
		"Baie Lichii", --Baie Lichii english:Liechi Berry
		"Baie Lingan", --Baie Lingan english:Ganlon Berry
		"Baie Sailak", --Baie Sailak english:Salac Berry
		"Baie Pitaye", --Baie Pitaye english:Petaya Berry
		"Baie Abriko", --Baie Abriko english:Apicot Berry
		"Baie Lansat", --Baie Lansat english:Lansat Berry
		"Baie Frista", --Baie Frista english:Starf Berry
		"Baie Enigma", --Baie Enigma english:Enigma Berry
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Poudreclaire", --Poudreclaire english:BrightPowder
		"Herbeblanche", --Herbeblanche english:White Herb
		"Brac. Macho", --Brac. Macho english:Macho Brace
		"Multi Exp", --Multi Exp english:Exp. Share
		"Vive Griffe", --Vive Griffe english:Quick Claw
		"Grelot Zen", --Grelot Zen english:Soothe Bell
		"Herbe Mental", --Herbe Mental english:Mental Herb
		"Band. Choix", --Band. Choix english:Choice Band
		"Roche Royale", --Roche Royale english:King's Rock
		"Poudre Arg.", --Poudre Arg. english:SilverPowder
		"Piece Rune", --Piece Rune english:Amulet Coin
		"Rune Purif.", --Rune Purif. english:Cleanse Tag
		"Rosee Ame", --Rosee Ame english:Soul Dew
		"Dent Ocean", --Dent Ocean english:DeepSeaTooth
		"Ecailleocean", --Ecailleocean english:DeepSeaScale
		"Boule Fumee", --Boule Fumee english:Smoke Ball
		"Pierre Stase", --Pierre Stase english:Everstone
		"Bandeau", --Bandeau english:Focus Band
		"Oeuf Chance", --Oeuf Chance english:Lucky Egg
		"Lentilscope", --Lentilscope english:Scope Lens
		"Peau Metal", --Peau Metal english:Metal Coat
		"Restes", --Restes english:Leftovers
		"Ecailledraco", --Ecailledraco english:Dragon Scale
		"Ballelumiere", --Ballelumiere english:Light Ball
		"Sable Doux", --Sable Doux english:Soft Sand
		"Pierre Dure", --Pierre Dure english:Hard Stone
		"Grain Miracl", --Grain Miracl english:Miracle Seed
		"Lunet.noires", --Lunet.noires english:BlackGlasses
		"Ceint.noire", --Ceint.noire english:Black Belt
		"Aimant", --Aimant english:Magnet
		"Eau Mystique", --Eau Mystique english:Mystic Water
		"Bec Pointu", --Bec Pointu english:Sharp Beak
		"Pic Venin", --Pic Venin english:Poison Barb
		"Glaceternel", --Glaceternel english:NeverMeltIce
		"Rune Sort", --Rune Sort english:Spell Tag
		"Cuillertordu", --Cuillertordu english:TwistedSpoon
		"Charbon", --Charbon english:Charcoal
		"Croc Dragon", --Croc Dragon english:Dragon Fang
		"Mouch. Soie", --Mouch. Soie english:Silk Scarf
		"Ameliorator", --Ameliorator english:Up-Grade
		"Grelot Coque", --Grelot Coque english:Shell Bell
		"Encens Mer", --Encens Mer english:Sea Incense
		"Encens Doux", --Encens Doux english:Lax Incense
		"Poing Chance", --Poing Chance english:Lucky Punch
		"Poudre Metal", --Poudre Metal english:Metal Powder
		"Masse Os", --Masse Os english:Thick Club
		"Baton", --Baton english:Stick
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
		"Foul. Rouge", --Foul. Rouge english:Red Scarf
		"Foul. Bleu", --Foul. Bleu english:Blue Scarf
		"Foul. Rose", --Foul. Rose english:Pink Scarf
		"Foul. Vert", --Foul. Vert english:Green Scarf
		"Foul. Jaune", --Foul. Jaune english:Yellow Scarf
		"Velo Course", --Velo Course english:Mach Bike
		"Boite Jetons", --Boite Jetons english:Coin Case
		"Cherch'objet", --Cherch'objet english:Itemfinder
		"Canne", --Canne english:Old Rod
		"Super Canne", --Super Canne english:Good Rod
		"Mega Canne", --Mega Canne english:Super Rod
		"Passe Bateau", --Passe Bateau english:S.S. Ticket
		"Passeconcour", --Passeconcour english:Contest Pass
		"????????", --???????? english:unknown
		"Seau Wailmer", --Seau Wailmer english:Wailmer Pail
		"Pack Devon", --Pack Devon english:Devon Goods
		"Sac A Suie", --Sac A Suie english:Soot Sack
		"Cle Sous-Sol", --Cle Sous-Sol english:Basement Key
		"Velo Cross", --Velo Cross english:Acro Bike
		"Boite Pokeblocks", --Boite Pokeblocks english:Pokeblock Case
		"Lettre", --Lettre english:Letter
		"Passe Eon", --Passe Eon english:Eon Ticket
		"Orbe Rouge", --Orbe Rouge english:Red Orb
		"Orbe Bleu", --Orbe Bleu english:Blue Orb
		"Scanner", --Scanner english:Scanner
		"Lunet. Sable", --Lunet. Sable english:Go-Goggles
		"Meteorite", --Meteorite english:Meteorite
		"Cle Salle 1", --Cle Salle 1 english:Rm. 1 Key
		"Cle Salle 2", --Cle Salle 2 english:Rm. 2 Key
		"Cle Salle 4", --Cle Salle 4 english:Rm. 4 Key
		"Cle Salle 6", --Cle Salle 6 english:Rm. 6 Key
		"Cle Stockage", --Cle Stockage english:Storage Key
		"Foss. Racine", --Foss. Racine english:Root Fossil
		"Foss. Griffe", --Foss. Griffe english:Claw Fossil
		"Devon Scope", --Devon Scope english:Devon Scope
		"Ct01", --Ct01 english:TM01
		"Ct02", --Ct02 english:TM02
		"Ct03", --Ct03 english:TM03
		"Ct04", --Ct04 english:TM04
		"Ct05", --Ct05 english:TM05
		"Ct06", --Ct06 english:TM06
		"Ct07", --Ct07 english:TM07
		"Ct08", --Ct08 english:TM08
		"Ct09", --Ct09 english:TM09
		"Ct10", --Ct10 english:TM10
		"Ct11", --Ct11 english:TM11
		"Ct12", --Ct12 english:TM12
		"Ct13", --Ct13 english:TM13
		"Ct14", --Ct14 english:TM14
		"Ct15", --Ct15 english:TM15
		"Ct16", --Ct16 english:TM16
		"Ct17", --Ct17 english:TM17
		"Ct18", --Ct18 english:TM18
		"Ct19", --Ct19 english:TM19
		"Ct20", --Ct20 english:TM20
		"Ct21", --Ct21 english:TM21
		"Ct22", --Ct22 english:TM22
		"Ct23", --Ct23 english:TM23
		"Ct24", --Ct24 english:TM24
		"Ct25", --Ct25 english:TM25
		"Ct26", --Ct26 english:TM26
		"Ct27", --Ct27 english:TM27
		"Ct28", --Ct28 english:TM28
		"Ct29", --Ct29 english:TM29
		"Ct30", --Ct30 english:TM30
		"Ct31", --Ct31 english:TM31
		"Ct32", --Ct32 english:TM32
		"Ct33", --Ct33 english:TM33
		"Ct34", --Ct34 english:TM34
		"Ct35", --Ct35 english:TM35
		"Ct36", --Ct36 english:TM36
		"Ct37", --Ct37 english:TM37
		"Ct38", --Ct38 english:TM38
		"Ct39", --Ct39 english:TM39
		"Ct40", --Ct40 english:TM40
		"Ct41", --Ct41 english:TM41
		"Ct42", --Ct42 english:TM42
		"Ct43", --Ct43 english:TM43
		"Ct44", --Ct44 english:TM44
		"Ct45", --Ct45 english:TM45
		"Ct46", --Ct46 english:TM46
		"Ct47", --Ct47 english:TM47
		"Ct48", --Ct48 english:TM48
		"Ct49", --Ct49 english:TM49
		"Ct50", --Ct50 english:TM50
		"Cs01", --Cs01 english:HM01
		"Cs02", --Cs02 english:HM02
		"Cs03", --Cs03 english:HM03
		"Cs04", --Cs04 english:HM04
		"Cs05", --Cs05 english:HM05
		"Cs06", --Cs06 english:HM06
		"Cs07", --Cs07 english:HM07
		"Cs08", --Cs08 english:HM08
		"????????", --???????? english:unknown
		"????????", --???????? english:unknown
		"Colis Chen", --Colis Chen english:Oak's Parcel
		"Pokéflute", --Pokéflute english:Poke Flute
		"Cle Secrete", --Cle Secrete english:Secret Key
		"Bon Commande", --Bon Commande english:Bike Voucher
		"Dent D'or", --Dent D'or english:Gold Teeth
		"Vieil Ambre", --Vieil Ambre english:Old Amber
		"Carte Magn.", --Carte Magn. english:Card Key
		"Cle Asc.", --Cle Asc. english:Lift Key
		"Nautile", --Nautile english:Helix Fossil
		"Fossile Dome", --Fossile Dome english:Dome Fossil
		"Scope Sylphe", --Scope Sylphe english:Silph Scope
		"Bicyclette", --Bicyclette english:Bicycle
		"Carte", --Carte english:Town Map
		"Cherche Vs", --Cherche Vs english:Vs. Seeker
		"Memorydex", --Memorydex english:Fame Checker
		"Boite Ct", --Boite Ct english:TM Case
		"Sac A Baies", --Sac A Baies english:Berry Pouch
		"Tv Abc", --Tv Abc english:Teachy TV
		"Tri-Passe", --Tri-Passe english:Tri-Pass
		"Passe Prisme", --Passe Prisme english:Rainbow Pass
		"The", --The english:Tea
		"Ticketmystik", --Ticketmystik english:MysticTicket
		"Ticketaurora", --Ticketaurora english:AuroraTicket
		"Pot Poudre", --Pot Poudre english:Powder Jar
		"Rubis", --Rubis english:Ruby
		"Saphir", --Saphir english:Sapphire
		"Sceau Magma", --Sceau Magma english:Magma Emblem
		"Vieille Carte", --Vieille Carte english:Old Sea Map
	},
	-- The list of Pokémon natures below must remain in the same order
	NatureNames = {
		"Hardi",
		"Solo",
		"Brave",
		"Rigide",
		"Mauvais",
		"Assure",
		"Docile",
		"Relax",
		"Malin",
		"Lache",
		"Timide",
		"Presse",
		"Serieux",
		"Jovial",
		"Naif",
		"Modeste",
		"Doux",
		"Discret",
		"Pudique",
		"Foufou",
		"Calme",
		"Gentil",
		"Malpoli",
		"Prudent",
		"Bizarre",
	},
	-- The list of Pokémon names below must remain in the same order
	PokemonNames = {
		"Bulbizarre", --Bulbizarre english:Bulbasaur
		"Herbizarre", --Herbizarre english:Ivysaur
		"Florizarre", --Florizarre english:Venusaur
		"Salameche", --Salameche english:Charmander
		"Reptincel", --Reptincel english:Charmeleon
		"Dracaufeu", --Dracaufeu english:Charizard
		"Carapuce", --Carapuce english:Squirtle
		"Carabaffe", --Carabaffe english:Wartortle
		"Tortank", --Tortank english:Blastoise
		"Chenipan", --Chenipan english:Caterpie
		"Chrysacier", --Chrysacier english:Metapod
		"Papilusion", --Papilusion english:Butterfree
		"Aspicot", --Aspicot english:Weedle
		"Coconfort", --Coconfort english:Kakuna
		"Dardargnan", --Dardargnan english:Beedrill
		"Roucool", --Roucool english:Pidgey
		"Roucoups", --Roucoups english:Pidgeotto
		"Roucarnage", --Roucarnage english:Pidgeot
		"Rattata", --Rattata english:Rattata
		"Rattatac", --Rattatac english:Raticate
		"Piafabec", --Piafabec english:Spearow
		"Rapasdepic", --Rapasdepic english:Fearow
		"Abo", --Abo english:Ekans
		"Arbok", --Arbok english:Arbok
		"Pikachu", --Pikachu english:Pikachu
		"Raichu", --Raichu english:Raichu
		"Sabelette", --Sabelette english:Sandshrew
		"Sablaireau", --Sablaireau english:Sandslash
		"Nidoran F", --Nidoran  english:Nidoran F
		"Nidorina", --Nidorina english:Nidorina
		"Nidoqueen", --Nidoqueen english:Nidoqueen
		"Nidoran M", --Nidoran  english:Nidoran M
		"Nidorino", --Nidorino english:Nidorino
		"Nidoking", --Nidoking english:Nidoking
		"Melofee", --Melofee english:Clefairy
		"Melodelfe", --Melodelfe english:Clefable
		"Goupix", --Goupix english:Vulpix
		"Feunard", --Feunard english:Ninetales
		"Rondoudou", --Rondoudou english:Jigglypuff
		"Grodoudou", --Grodoudou english:Wigglytuff
		"Nosferapti", --Nosferapti english:Zubat
		"Nosferalto", --Nosferalto english:Golbat
		"Mystherbe", --Mystherbe english:Oddish
		"Ortide", --Ortide english:Gloom
		"Rafflesia", --Rafflesia english:Vileplume
		"Paras", --Paras english:Paras
		"Parasect", --Parasect english:Parasect
		"Mimitoss", --Mimitoss english:Venonat
		"Aeromite", --Aeromite english:Venomoth
		"Taupiqueur", --Taupiqueur english:Diglett
		"Triopikeur", --Triopikeur english:Dugtrio
		"Miaouss", --Miaouss english:Meowth
		"Persian", --Persian english:Persian
		"Psykokwak", --Psykokwak english:Psyduck
		"Akwakwak", --Akwakwak english:Golduck
		"Ferosinge", --Ferosinge english:Mankey
		"Colossinge", --Colossinge english:Primeape
		"Caninos", --Caninos english:Growlithe
		"Arcanin", --Arcanin english:Arcanine
		"Ptitard", --Ptitard english:Poliwag
		"Tetarte", --Tetarte english:Poliwhirl
		"Tartard", --Tartard english:Poliwrath
		"Abra", --Abra english:Abra
		"Kadabra", --Kadabra english:Kadabra
		"Alakazam", --Alakazam english:Alakazam
		"Machoc", --Machoc english:Machop
		"Machopeur", --Machopeur english:Machoke
		"Mackogneur", --Mackogneur english:Machamp
		"Chetiflor", --Chetiflor english:Bellsprout
		"Boustiflor", --Boustiflor english:Weepinbell
		"Empiflor", --Empiflor english:Victreebel
		"Tentacool", --Tentacool english:Tentacool
		"Tentacruel", --Tentacruel english:Tentacruel
		"Racaillou", --Racaillou english:Geodude
		"Gravalanch", --Gravalanch english:Graveler
		"Grolem", --Grolem english:Golem
		"Ponyta", --Ponyta english:Ponyta
		"Galopa", --Galopa english:Rapidash
		"Ramoloss", --Ramoloss english:Slowpoke
		"Flagadoss", --Flagadoss english:Slowbro
		"Magneti", --Magneti english:Magnemite
		"Magneton", --Magneton english:Magneton
		"Canarticho", --Canarticho english:Farfetch'd
		"Doduo", --Doduo english:Doduo
		"Dodrio", --Dodrio english:Dodrio
		"Otaria", --Otaria english:Seel
		"Lamantine", --Lamantine english:Dewgong
		"Tadmorv", --Tadmorv english:Grimer
		"Grotadmorv", --Grotadmorv english:Muk
		"Kokiyas", --Kokiyas english:Shellder
		"Crustabri", --Crustabri english:Cloyster
		"Fantominus", --Fantominus english:Gastly
		"Spectrum", --Spectrum english:Haunter
		"Ectoplasma", --Ectoplasma english:Gengar
		"Onix", --Onix english:Onix
		"Soporifik", --Soporifik english:Drowzee
		"Hypnomade", --Hypnomade english:Hypno
		"Krabby", --Krabby english:Krabby
		"Krabboss", --Krabboss english:Kingler
		"Voltorbe", --Voltorbe english:Voltorb
		"Electrode", --Electrode english:Electrode
		"Noeunoeuf", --Noeunoeuf english:Exeggcute
		"Noadkoko", --Noadkoko english:Exeggutor
		"Osselait", --Osselait english:Cubone
		"Ossatueur", --Ossatueur english:Marowak
		"Kicklee", --Kicklee english:Hitmonlee
		"Tygnon", --Tygnon english:Hitmonchan
		"Excelangue", --Excelangue english:Lickitung
		"Smogo", --Smogo english:Koffing
		"Smogogo", --Smogogo english:Weezing
		"Rhinocorne", --Rhinocorne english:Rhyhorn
		"Rhinoferos", --Rhinoferos english:Rhydon
		"Leveinard", --Leveinard english:Chansey
		"Saquedeneu", --Saquedeneu english:Tangela
		"Kangourex", --Kangourex english:Kangaskhan
		"Hypotrempe", --Hypotrempe english:Horsea
		"Hypocean", --Hypocean english:Seadra
		"Poissirene", --Poissirene english:Goldeen
		"Poissoroy", --Poissoroy english:Seaking
		"Stari", --Stari english:Staryu
		"Staross", --Staross english:Starmie
		"M. Mime", --M. Mime english:Mr. Mime
		"Insecateur", --Insecateur english:Scyther
		"Lippoutou", --Lippoutou english:Jynx
		"Elektek", --Elektek english:Electabuzz
		"Magmar", --Magmar english:Magmar
		"Scarabrute", --Scarabrute english:Pinsir
		"Tauros", --Tauros english:Tauros
		"Magicarpe", --Magicarpe english:Magikarp
		"Leviator", --Leviator english:Gyarados
		"Lokhlass", --Lokhlass english:Lapras
		"Metamorph", --Metamorph english:Ditto
		"Evoli", --Evoli english:Eevee
		"Aquali", --Aquali english:Vaporeon
		"Voltali", --Voltali english:Jolteon
		"Pyroli", --Pyroli english:Flareon
		"Porygon", --Porygon english:Porygon
		"Amonita", --Amonita english:Omanyte
		"Amonistar", --Amonistar english:Omastar
		"Kabuto", --Kabuto english:Kabuto
		"Kabutops", --Kabutops english:Kabutops
		"Ptera", --Ptera english:Aerodactyl
		"Ronflex", --Ronflex english:Snorlax
		"Artikodin", --Artikodin english:Articuno
		"Electhor", --Electhor english:Zapdos
		"Sulfura", --Sulfura english:Moltres
		"Minidraco", --Minidraco english:Dratini
		"Draco", --Draco english:Dragonair
		"Dracolosse", --Dracolosse english:Dragonite
		"Mewtwo", --Mewtwo english:Mewtwo
		"Mew", --Mew english:Mew
		"Germignon", --Germignon english:Chikorita
		"Macronium", --Macronium english:Bayleef
		"Meganium", --Meganium english:Meganium
		"Hericendre", --Hericendre english:Cyndaquil
		"Feurisson", --Feurisson english:Quilava
		"Typhlosion", --Typhlosion english:Typhlosion
		"Kaiminus", --Kaiminus english:Totodile
		"Crocrodil", --Crocrodil english:Croconaw
		"Aligatueur", --Aligatueur english:Feraligatr
		"Fouinette", --Fouinette english:Sentret
		"Fouinar", --Fouinar english:Furret
		"Hoothoot", --Hoothoot english:Hoothoot
		"Noarfang", --Noarfang english:Noctowl
		"Coxy", --Coxy english:Ledyba
		"Coxyclaque", --Coxyclaque english:Ledian
		"Mimigal", --Mimigal english:Spinarak
		"Migalos", --Migalos english:Ariados
		"Nostenfer", --Nostenfer english:Crobat
		"Loupio", --Loupio english:Chinchou
		"Lanturn", --Lanturn english:Lanturn
		"Pichu", --Pichu english:Pichu
		"Melo", --Melo english:Cleffa
		"Toudoudou", --Toudoudou english:Igglybuff
		"Togepi", --Togepi english:Togepi
		"Togetic", --Togetic english:Togetic
		"Natu", --Natu english:Natu
		"Xatu", --Xatu english:Xatu
		"Wattouat", --Wattouat english:Mareep
		"Lainergie", --Lainergie english:Flaaffy
		"Pharamp", --Pharamp english:Ampharos
		"Joliflor", --Joliflor english:Bellossom
		"Marill", --Marill english:Marill
		"Azumarill", --Azumarill english:Azumarill
		"Simularbre", --Simularbre english:Sudowoodo
		"Tarpaud", --Tarpaud english:Politoed
		"Granivol", --Granivol english:Hoppip
		"Floravol", --Floravol english:Skiploom
		"Cotovol", --Cotovol english:Jumpluff
		"Capumain", --Capumain english:Aipom
		"Tournegrin", --Tournegrin english:Sunkern
		"Heliatronc", --Heliatronc english:Sunflora
		"Yanma", --Yanma english:Yanma
		"Axoloto", --Axoloto english:Wooper
		"Maraiste", --Maraiste english:Quagsire
		"Mentali", --Mentali english:Espeon
		"Noctali", --Noctali english:Umbreon
		"Cornebre", --Cornebre english:Murkrow
		"Roigada", --Roigada english:Slowking
		"Feuforeve", --Feuforeve english:Misdreavus
		"Zarbi", --Zarbi english:Unown
		"Qulbutoke", --Qulbutoke english:Wobbuffet
		"Girafarig", --Girafarig english:Girafarig
		"Pomdepik", --Pomdepik english:Pineco
		"Foretress", --Foretress english:Forretress
		"Insolourdo", --Insolourdo english:Dunsparce
		"Scorplane", --Scorplane english:Gligar
		"Steelix", --Steelix english:Steelix
		"Snubbull", --Snubbull english:Snubbull
		"Granbull", --Granbull english:Granbull
		"Qwilfish", --Qwilfish english:Qwilfish
		"Cizayox", --Cizayox english:Scizor
		"Caratroc", --Caratroc english:Shuckle
		"Scarhino", --Scarhino english:Heracross
		"Farfuret", --Farfuret english:Sneasel
		"Teddiursa", --Teddiursa english:Teddiursa
		"Ursaring", --Ursaring english:Ursaring
		"Limagma", --Limagma english:Slugma
		"Volcaropod", --Volcaropod english:Magcargo
		"Marcacrin", --Marcacrin english:Swinub
		"Cochignon", --Cochignon english:Piloswine
		"Corayon", --Corayon english:Corsola
		"Remoraid", --Remoraid english:Remoraid
		"Octillery", --Octillery english:Octillery
		"Cadoizo", --Cadoizo english:Delibird
		"Demanta", --Demanta english:Mantine
		"Airmure", --Airmure english:Skarmory
		"Malosse", --Malosse english:Houndour
		"Demolosse", --Demolosse english:Houndoom
		"Hyporoi", --Hyporoi english:Kingdra
		"Phanpy", --Phanpy english:Phanpy
		"Donphan", --Donphan english:Donphan
		"Porygon2", --Porygon2 english:Porygon2
		"Cerfrousse", --Cerfrousse english:Stantler
		"Queulorior", --Queulorior english:Smeargle
		"Debugant", --Debugant english:Tyrogue
		"Kapoera", --Kapoera english:Hitmontop
		"Lippouti", --Lippouti english:Smoochum
		"Elekid", --Elekid english:Elekid
		"Magby", --Magby english:Magby
		"Ecremeuh", --Ecremeuh english:Miltank
		"Leuphorie", --Leuphorie english:Blissey
		"Raikou", --Raikou english:Raikou
		"Entei", --Entei english:Entei
		"Suicune", --Suicune english:Suicune
		"Embrylex", --Embrylex english:Larvitar
		"Ymphect", --Ymphect english:Pupitar
		"Tyranocif", --Tyranocif english:Tyranitar
		"Lugia", --Lugia english:Lugia
		"Ho-Oh", --Ho-Oh english:Ho-Oh
		"Celebi", --Celebi english:Celebi
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"?", --? english:none
		"Arcko", --Arcko english:Treecko
		"Massko", --Massko english:Grovyle
		"Jungko", --Jungko english:Sceptile
		"Poussifeu", --Poussifeu english:Torchic
		"Galifeu", --Galifeu english:Combusken
		"Brasegali", --Brasegali english:Blaziken
		"Gobou", --Gobou english:Mudkip
		"Flobio", --Flobio english:Marshtomp
		"Laggron", --Laggron english:Swampert
		"Medhyena", --Medhyena english:Poochyena
		"Grahyena", --Grahyena english:Mightyena
		"Zigzaton", --Zigzaton english:Zigzagoon
		"Lineon", --Lineon english:Linoone
		"Chenipotte", --Chenipotte english:Wurmple
		"Armulys", --Armulys english:Silcoon
		"Charmillon", --Charmillon english:Beautifly
		"Blindalys", --Blindalys english:Cascoon
		"Papinox", --Papinox english:Dustox
		"Nenupiot", --Nenupiot english:Lotad
		"Lombre", --Lombre english:Lombre
		"Ludicolo", --Ludicolo english:Ludicolo
		"Grainipiot", --Grainipiot english:Seedot
		"Pifeuil", --Pifeuil english:Nuzleaf
		"Tengalice", --Tengalice english:Shiftry
		"Ningale", --Ningale english:Nincada
		"Ninjask", --Ninjask english:Ninjask
		"Munja", --Munja english:Shedinja
		"Nirondelle", --Nirondelle english:Taillow
		"Heledelle", --Heledelle english:Swellow
		"Balignon", --Balignon english:Shroomish
		"Chapignon", --Chapignon english:Breloom
		"Spinda", --Spinda english:Spinda
		"Goelise", --Goelise english:Wingull
		"Bekipan", --Bekipan english:Pelipper
		"Arakdo", --Arakdo english:Surskit
		"Maskadra", --Maskadra english:Masquerain
		"Wailmer", --Wailmer english:Wailmer
		"Wailord", --Wailord english:Wailord
		"Skitty", --Skitty english:Skitty
		"Delcatty", --Delcatty english:Delcatty
		"Kecleon", --Kecleon english:Kecleon
		"Balbuto", --Balbuto english:Baltoy
		"Kaorine", --Kaorine english:Claydol
		"Tarinor", --Tarinor english:Nosepass
		"Chartor", --Chartor english:Torkoal
		"Tenefix", --Tenefix english:Sableye
		"Barloche", --Barloche english:Barboach
		"Barbicha", --Barbicha english:Whiscash
		"Lovdisc", --Lovdisc english:Luvdisc
		"Ecrapince", --Ecrapince english:Corphish
		"Colhomard", --Colhomard english:Crawdaunt
		"Barpau", --Barpau english:Feebas
		"Milobellus", --Milobellus english:Milotic
		"Carvanha", --Carvanha english:Carvanha
		"Sharpedo", --Sharpedo english:Sharpedo
		"Kraknoix", --Kraknoix english:Trapinch
		"Vibraninf", --Vibraninf english:Vibrava
		"Libegon", --Libegon english:Flygon
		"Makuhita", --Makuhita english:Makuhita
		"Hariyama", --Hariyama english:Hariyama
		"Dynavolt", --Dynavolt english:Electrike
		"Elecsprint", --Elecsprint english:Manectric
		"Chamallot", --Chamallot english:Numel
		"Camerupt", --Camerupt english:Camerupt
		"Obalie", --Obalie english:Spheal
		"Phogleur", --Phogleur english:Sealeo
		"Kaimorse", --Kaimorse english:Walrein
		"Cacnea", --Cacnea english:Cacnea
		"Cacturne", --Cacturne english:Cacturne
		"Stalgamin", --Stalgamin english:Snorunt
		"Oniglali", --Oniglali english:Glalie
		"Seleroc", --Seleroc english:Lunatone
		"Solaroc", --Solaroc english:Solrock
		"Azurill", --Azurill english:Azurill
		"Spoink", --Spoink english:Spoink
		"Groret", --Groret english:Grumpig
		"Posipi", --Posipi english:Plusle
		"Negapi", --Negapi english:Minun
		"Mysdibule", --Mysdibule english:Mawile
		"Meditikka", --Meditikka english:Meditite
		"Charmina", --Charmina english:Medicham
		"Tylton", --Tylton english:Swablu
		"Altaria", --Altaria english:Altaria
		"Okeoke", --Okeoke english:Wynaut
		"Skelenox", --Skelenox english:Duskull
		"Teraclope", --Teraclope english:Dusclops
		"Roselia", --Roselia english:Roselia
		"Parecool", --Parecool english:Slakoth
		"Vigoroth", --Vigoroth english:Vigoroth
		"Monaflemit", --Monaflemit english:Slaking
		"Gloupti", --Gloupti english:Gulpin
		"Avaltout", --Avaltout english:Swalot
		"Tropius", --Tropius english:Tropius
		"Chuchmur", --Chuchmur english:Whismur
		"Ramboum", --Ramboum english:Loudred
		"Brouhabam", --Brouhabam english:Exploud
		"Coquiperl", --Coquiperl english:Clamperl
		"Serpang", --Serpang english:Huntail
		"Rosabyss", --Rosabyss english:Gorebyss
		"Absol", --Absol english:Absol
		"Polichombr", --Polichombr english:Shuppet
		"Branette", --Branette english:Banette
		"Seviper", --Seviper english:Seviper
		"Mangriff", --Mangriff english:Zangoose
		"Relicanth", --Relicanth english:Relicanth
		"Galekid", --Galekid english:Aron
		"Galegon", --Galegon english:Lairon
		"Galeking", --Galeking english:Aggron
		"Morpheo", --Morpheo english:Castform
		"Muciole", --Muciole english:Volbeat
		"Lumivole", --Lumivole english:Illumise
		"Lilia", --Lilia english:Lileep
		"Vacilys", --Vacilys english:Cradily
		"Anorith", --Anorith english:Anorith
		"Armaldo", --Armaldo english:Armaldo
		"Tarsal", --Tarsal english:Ralts
		"Kirlia", --Kirlia english:Kirlia
		"Gardevoir", --Gardevoir english:Gardevoir
		"Draby", --Draby english:Bagon
		"Drackhaus", --Drackhaus english:Shelgon
		"Drattak", --Drattak english:Salamence
		"Terhal", --Terhal english:Beldum
		"Metang", --Metang english:Metang
		"Metalosse", --Metalosse english:Metagross
		"Regirock", --Regirock english:Regirock
		"Regice", --Regice english:Regice
		"Registeel", --Registeel english:Registeel
		"Kyogre", --Kyogre english:Kyogre
		"Groudon", --Groudon english:Groudon
		"Rayquaza", --Rayquaza english:Rayquaza
		"Latias", --Latias english:Latias
		"Latios", --Latios english:Latios
		"Jirachi", --Jirachi english:Jirachi
		"Deoxys", --Deoxys english:Deoxys
		"Eoko", --Eoko english:Chimecho
	},
}
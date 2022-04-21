-- DO NOT TOUCH
Settings = {}
Settings.controls = {}
-- END DO NOT TOUCH

-- Ironmon-Tracker Settings:
    -- true/false values are case sensitive

-- Settings.controls
    -- Must be wrapped in quotes and are case sensitive. Ex. "Start"
    -- Options are [ A, B, L, R, Up, Down, Left, Right, Start, Select ]
Settings.controls.CYCLE_VIEW = "Select"
Settings.controls.CYCLE_STAT = "L"
Settings.controls.CYCLE_PREDICTION = "R"

-- Settings.autoTrackOpponentMons
    -- Automatically switches the tracker view to opponent mons after they attack. Recommended for streamers to disable to reduce the tracker flip-flopping back and forth between views.
    -- Manual switching with SELECT is always active.
Settings.autoTrackOpponentMons = true

-- Settings.easterEggs
    -- There is only one easter egg right now. If you are a streamer, this easter egg is very benign / family safe and I think quite humerous. Only activates when you get a certain starter pokemon...
Settings.easterEggs = true

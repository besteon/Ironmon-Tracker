BotUtils = {
    -- List of pokemon that can't be used in Kaizo
    UNUSABLE_MONS={144, 145, 146, 149, 150, 151, 243, 244, 245, 248, 249, 250, 251, 366, 397, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410},
    -- Intro sequence flag
    introToDo = true,
    introFrameCount = 1,
    -- Starter sequence flag
    introToStarterToDo = true,
    introToStarterFrameCount = 1,
    starterId = nil,
    -- Battle flags
    battleFinished = false,
    inBattleIntro = true,
    currentTurn = -1,
}

--- Check if array contains value
--- @return boolean contains
function BotUtils.hasValue(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

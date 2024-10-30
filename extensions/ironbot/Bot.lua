require("InputInjecter")

Bot = {
    -- List of pokemon that can't be used in Kaizo
    UNUSABLE_MONS={144, 145, 146, 149, 150, 151, 243, 244, 245, 248, 249, 250, 251, 366, 397, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410},
    -- Current step count
    currentSteps = -1.0,
    -- Intro sequence flag
    introToDo = true,
    introFrameCount = 1,
    -- Starter sequence flag
    introToStarterToDo = true,
    introToStarterFrameCount = 1,
}

--- Check if array contains value
--- @return boolean contains
function Bot.hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

--- Updates the current step count
function Bot.updateStepCount()
    local newSteps = tonumber(string.sub(TrackerScreen.Buttons.PedometerStepText:getText(), 7));
	if newSteps ~= nil then
		if newSteps > Bot.currentSteps then
            Bot.currentSteps = newSteps;
        end
	end
end

--- Computes the starter to take (1=Left/2=Middle/3=Right)
--- @return integer starterId
function Bot.getStarterID()
    local starterIsOk = false
    local id = TrackerScreen.PokeBalls.chosenBall
    -- Check if all starters are unusable. In that case we take the first selected starter.
    local starter1 = memory.read_u16_le(0x5B1DF8, 'ROM')
    local starter2 = memory.read_u16_le(0x5B1DFA, 'ROM')
    local starter3 = memory.read_u16_le(0x5B1DFC, 'ROM')
    if Bot.hasValue(Bot.UNUSABLE_MONS, starter1) and Bot.hasValue(Bot.UNUSABLE_MONS, starter2) and Bot.hasValue(Bot.UNUSABLE_MONS, starter3) then
        return id
    end
    while starterIsOk == false do
        local pokeId = memory.read_u16_le(0x5B1DF8 + 2 * id, 'ROM')
        if Bot.hasValue(Bot.UNUSABLE_MONS, pokeId) then
            TrackerScreen.Buttons.RerollBallPicker:onClick()
            id = TrackerScreen.PokeBalls.chosenBall
        else
            starterIsOk = true
        end
    end
    return id
end

--- Injects inputs for a certain amount of frames
--- @param inputs string the inputs to inject
--- @param frames integer number of frames to inject the input for
function Bot.injectInputs(inputs, frames)
    for i=1,frames do
        InputInjecter.injectInput(inputs)
        emu.frameadvance();
    end
end

--- Wait a certain amount of frames
--- @param frames integer frames to wait
function Bot.waitFrames(frames)
    for i=1,frames do
        emu.frameadvance();
    end
end

--- Mashes 2 inputs alternatively for 2*times frames
--- @param inputs1 string 
--- @param inputs2 string
--- @param times integer
function Bot.mashInputs(inputs1, inputs2, times)
    for i=1,times do
        InputInjecter.injectInput(inputs1)
        emu.frameadvance();
        InputInjecter.injectInput(inputs2)
        emu.frameadvance();
    end
end

-- INITIALIZING
InputInjecter.initialize();

-- Fixed Intro Sequence
print("Playing Intro Sequence")
while Bot.introToDo do
    InputInjecter.injectInput(InputInjecter.INTRO_INP[Bot.introFrameCount])
    Bot.introFrameCount = Bot.introFrameCount + 1
    emu.frameadvance();
    if Bot.introFrameCount > #InputInjecter.INTRO_INP then
        Bot.introToDo = false
    end
end

-- Fixed Intro to Starter Sequence
print("Playing Into to Starter Sequence")
while Bot.introToStarterToDo do
    InputInjecter.injectInput(InputInjecter.INTRO_TO_STARTER_INP[Bot.introToStarterFrameCount])
    Bot.introToStarterFrameCount = Bot.introToStarterFrameCount + 1
    emu.frameadvance();
    if Bot.introToStarterFrameCount > #InputInjecter.INTRO_TO_STARTER_INP then
        Bot.introToStarterToDo = false
    end
end

-- Choose starter
local starterId = Bot.getStarterID()
if starterId < 2 then
    Bot.injectInputs('L', 5)
    Bot.waitFrames(30)
end
if starterId < 1 then
    Bot.injectInputs('L', 5)
    Bot.waitFrames(30)
end
Bot.mashInputs('A', '', 60)

-- Starter fight


-- MAIN LOOP
while true do
    -- Update the step count
    Bot.updateStepCount();
	emu.frameadvance();
end

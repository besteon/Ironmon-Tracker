InputInjecter = {
    --- MAIN INPUT FIFO, 1 input string per frame
    INPUT_FIFO=nil,
    INPUT_LIST={'A', 'B', 'Up', 'Left', 'Down', 'Right', 'L', 'R', 'Start', 'Select'},
    INPUT_CODES={'A', 'B', 'U', 'L', 'D', 'R', 'l', 'r', 'S', 's'},
    INTRO_FILE="extensions/ironbot/Intro.inp",
    INTRO_INP={},
    INTRO_TO_STARTER_FILE="extensions/ironbot/IntroToStarter.inp",
    INTRO_TO_STARTER_INP={},
}

--- Initialize all Input Sequences
function InputInjecter.initialize()
    InputInjecter.INTRO_INP = InputInjecter.initializeSequence(InputInjecter.INTRO_FILE)
    InputInjecter.INTRO_TO_STARTER_INP = InputInjecter.initializeSequence(InputInjecter.INTRO_TO_STARTER_FILE)
    local new_fifo = require "extensions.ironbot.Fifo"
    InputInjecter.INPUT_FIFO = new_fifo():setempty(function() return nil end).new()
end

--- Adds 'times' input to INPUT_FIFO
--- @param input string
--- @param times integer
function InputInjecter.addToFifo(input, times)
    if times == nil then times = 1 end
    for _=1,times do
        InputInjecter.INPUT_FIFO:push(input)
    end
end

--- Add a waiting sequence to INPUT_FIFO
--- @param frames integer number of frames to wait for
function InputInjecter.addWaitToFifo(frames)
    InputInjecter.addToFifo('', frames)
end

--- Mashes two alternate inputs in FIFO for a certain amount of frames
--- @param inputs1 string
--- @param inputs2 string
--- @param frames integer
function InputInjecter.mashToFifo(inputs1, inputs2, frames)
    for _=1,frames do
        InputInjecter.addToFifo(inputs1, 1)
        InputInjecter.addToFifo(inputs2, 1)
    end
end

--- Returns an array representing an Input Sequence
--- @param file string path to load the input sequence from
--- @returns table 
function InputInjecter.initializeSequence(file)
    local sequence = {}
    for line in io.lines(file) do
        if string.sub(line, 0, 1) ~= '#' then
            sequence[#sequence + 1] = line
        end
    end
    return sequence
end

--- Injects the input for the current frame
--- @param inputs string string containing all the pressed inputs for the current frame
function InputInjecter.injectInput(inputs)
    if inputs ~= nil then
        local input = {}
        input['Power'] = false
        for i=1, #InputInjecter.INPUT_LIST do
            input[InputInjecter.INPUT_LIST[i]] = string.find(inputs, InputInjecter.INPUT_CODES[i]) ~= nil
        end
        joypad.set(input);
    end
end

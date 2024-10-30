InputInjecter = {
    INPUT_LIST={'A', 'B', 'Up', 'Left', 'Down', 'Right', 'L', 'R', 'Start', 'Select'},
    INPUT_CODES={'A', 'B', 'U', 'L', 'D', 'R', 'l', 'r', 'S', 's'},
    INTRO_FILE="Intro.inp",
    INTRO_INP={},
    INTRO_TO_STARTER_FILE="IntroToStarter.inp",
    INTRO_TO_STARTER_INP={},
}

--- Initialize all Input Sequences
function InputInjecter.initialize()
    InputInjecter.INTRO_INP = InputInjecter.initializeSequence(InputInjecter.INTRO_FILE)
    InputInjecter.INTRO_TO_STARTER_INP = InputInjecter.initializeSequence(InputInjecter.INTRO_TO_STARTER_FILE)
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
    local input = {}
    input['Power'] = false
    for i=1, #InputInjecter.INPUT_LIST do
        input[InputInjecter.INPUT_LIST[i]] = string.find(inputs, InputInjecter.INPUT_CODES[i]) ~= nil
    end
    joypad.set(input);
end
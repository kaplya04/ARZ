script_author('Adrian G.')
script_name('Чат-калькулятор')
----------------------------------------------------------------------------------------------------------------
local imgui = require 'imgui'
local window = imgui.ImBool(false)
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
imgui.ShowCursor = false

function main()
    repeat wait(100) until isSampAvailable()
    
    while true do wait(0)
        local text = sampGetChatInputText()
    
        if text:find('%d+') and text:find('[-+/*^%%]') and not text:find('%a+') and text ~= nil then
            ok, number = pcall(load('return '..text))
            result = 'Результат: '..number
        end

        if text == '' then
            ok = false
        end

        imgui.Process = ok
    end
end

function imgui.OnDrawFrame()
    if sampIsChatInputActive() then
        local input = sampGetInputInfoPtr()
        local input = getStructElement(input, 0x8, 4)
        local windowPosX = getStructElement(input, 0x8, 4)
        local windowPosY = getStructElement(input, 0xC, 4)
        imgui.SetNextWindowPos(imgui.ImVec2(windowPosX, windowPosY + 30 + 15), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(result:len()*10, 30))
        imgui.Begin('Solve', window, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
        imgui.CenterText(u8(result))
        imgui.End()
    end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

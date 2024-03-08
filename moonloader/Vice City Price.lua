script_author('Stenford')

local sampev = require 'lib.samp.events'
local inicfg = require("inicfg")
local coursecurrency = 0

local directIni = 'ControlHp.ini'--сохранение настроек
local mainini = inicfg.load(inicfg.load({
    settings = {
        course=1
    },
}, directIni))


local tag="{FF1493}[Vice City Price]{FFB6C1}"
coursecurrency= (mainini.settings.course)






function main()
    while not isSampAvailable() do wait(0) end
       
    sampRegisterChatCommand('vcp',vcp)

    
    if type(coursecurrency) ~= "number" then
        coursecurrency=1
    end

    sampAddChatMessage(tag..' Cкрипт успешно запущен!',0xFFB6C1)
    if tonumber(coursecurrency) >1 then
        sampAddChatMessage(tag..'. Ваш курс: '..coursecurrency..'. Сменить можно командой /vcp',0xFFB6C1)
    else
        sampAddChatMessage(tag..' Вы не установили курс. Воспользуйтесь командой /vcp',0xFFB6C1)
    end


    while true do
        wait(0)
        
    end
end

function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
  print(id)
  print(text)--VC$180.000 за
  print(title)

    if text:match('VC$(.*) за') then
        n = text:match('VC$(.*) за')
        if n:match("%.") then
            moneyseparator = true
            n=(n:gsub("%.", "")) 
            text=(text:gsub("за 1 шт.", "за 1 шт. | $"..comma_value(n*coursecurrency))) 
        else
            text=(text:gsub("за 1 шт.", "за 1 шт. | $"..n*coursecurrency)) 
        end
        return{id, style, title, button1, button2, text}
    end
end

function vcp(arg)
    if arg:match('%d+') then
        arg=arg:match('%d+')
        if arg==0 then 
            arg=1 
        end
        coursecurrency = arg
        mainini.settings.course = arg
        inicfg.save(mainini,directini)
        sampAddChatMessage(tag..'. Вы успешно установили курс - '..coursecurrency..'!',0xFFB6C1)
    else
        sampAddChatMessage(tag..'. Курсом может быть только число!',0xFFB6C1)
    end
end


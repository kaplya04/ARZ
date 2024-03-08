script_author('Stenford')

local sampev = require 'lib.samp.events'
local inicfg = require("inicfg")
local coursecurrency = 0

local directIni = 'ControlHp.ini'--���������� ��������
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

    sampAddChatMessage(tag..' C����� ������� �������!',0xFFB6C1)
    if tonumber(coursecurrency) >1 then
        sampAddChatMessage(tag..'. ��� ����: '..coursecurrency..'. ������� ����� �������� /vcp',0xFFB6C1)
    else
        sampAddChatMessage(tag..' �� �� ���������� ����. �������������� �������� /vcp',0xFFB6C1)
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
  print(text)--VC$180.000 ��
  print(title)

    if text:match('VC$(.*) ��') then
        n = text:match('VC$(.*) ��')
        if n:match("%.") then
            moneyseparator = true
            n=(n:gsub("%.", "")) 
            text=(text:gsub("�� 1 ��.", "�� 1 ��. | $"..comma_value(n*coursecurrency))) 
        else
            text=(text:gsub("�� 1 ��.", "�� 1 ��. | $"..n*coursecurrency)) 
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
        sampAddChatMessage(tag..'. �� ������� ���������� ���� - '..coursecurrency..'!',0xFFB6C1)
    else
        sampAddChatMessage(tag..'. ������ ����� ���� ������ �����!',0xFFB6C1)
    end
end


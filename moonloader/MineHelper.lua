local mem = require "memory"
local imgui = require "imgui"
local encoding = require "encoding"
local events = require "lib.samp.events"
encoding.default = "CP1251"
u8 = encoding.UTF8
font = renderCreateFont("Century Gothic", 9, 5)


local cjtrue = true
local cjfalse = false
local infinityruntrue = true
local infinityrunfalse = false
local work = imgui.ImBool(false)
local work_stat = imgui.ImBool(false)
local render = imgui.ImBool(false)
local mesta = imgui.ImBool(false)
local infinityrun = imgui.ImBool(false)
local cj = imgui.ImBool(false)
local stat = imgui.ImBool(false)
local sbiv_q = imgui.ImBool(false)
local tag = "{AD42FE}[MineHelper]{ffffff} - "
local stone = 0
local	metall = 0
local	bronze = 0
local	silver = 0
local	gold = 0
local vsego = 0


function main()
	repeat wait(0) until isSampAvailable()
	wait(100)
	sampAddChatMessage(tag.."Загружен!", -1)
	sampAddChatMessage(tag.."Активация: /mineh", -1)
	sampRegisterChatCommand("mineh.stat", stat_imgui)
	sampRegisterChatCommand("mineh", menu_imgui)
	while true do
		wait(0)
     if render.v then
	     for id = 0, 2048 do
		     if sampIs3dTextDefined(id) then
	 	       local text, color, x, y, z, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
	 	         if text:find("Месторождение ресурсов") then
	 		        if isPointOnScreen(x, y, z, 3.0) then
	 			        xp, yp, zp = getCharCoordinates(PLAYER_PED)
	 			        x1, y2 = convert3DCoordsToScreen(x, y, z)
	 			        p3, p4 = convert3DCoordsToScreen(xp, yp, zp)
	 			        distance = string.format("%.0f", getDistanceBetweenCoords3d(x, y, z, xp, yp, zp))
	 			        text = ("{ffffff}Руда\n{ff0000}Дистанция: "..distance)
	 			        renderDrawLine(x1, y2, p3, p4, 1.1, 0xFFFF0000)
	 			        renderFontDrawText(font, text, x1, y2, -1)
							end
						end
					end
				end
			end
			if mesta.v then
				for _, v in pairs(getAllObjects()) do
									 if isObjectOnScreen(v) then
											 local result, oX, oY, oZ = getObjectCoordinates(v)
											 local x1, y1 = convert3DCoordsToScreen(oX,oY,oZ)
											 local objmodel = getObjectModel(v)
											 local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
											 local x3, y3 = convert3DCoordsToScreen(x2,y2,z2)
											 distance = string.format("%.0f", getDistanceBetweenCoords3d(oX,oY,oZ, x2, y2, z2))
	                     if objmodel == 19475 then
											 renderFontDrawText(font,"Место появление ресурса", x1, y1, -1)
										 end
									 end
								 end
							 end
							 if sbiv_q.v then
								 if isKeyJustPressed(0x51) then
									 taskPlayAnim(PLAYER_PED, "WF_FWD", "WAYFARER", 1, false, false, false, false, -1)
								 end
							 end
  end
end


function menu_imgui()
		work.v = not work.v
		imgui.Process = work.v
end


function events.onShowTextDraw(id, textdr)
	if textdr.text == "stone + 1" then
		stone = stone + 1
	elseif textdr.text == "metal + 1" then
		metall = metall + 1
	elseif textdr.text == "bronze + 1" then
		bronze = bronze + 1
	elseif textdr.text == "silver + 1" then
		silver = silver + 1
	elseif textdr.text == "gold + 1" then
		gold = gold + 1
	elseif textdr.text == "stone + 2" then
		stone = stone + 2
	elseif textdr.text == "metal + 2" then
		metall = metall + 2
	elseif textdr.text == "bronze + 2" then
		bronze = bronze + 2
	elseif textdr.text == "silver + 2" then
		silver = silver + 2
	elseif textdr.text == "gold + 2" then
		gold = gold + 2
	end
end


function imgui_colors()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	style.WindowPadding = ImVec2(15, 15)
style.WindowRounding = 6.0
style.FramePadding = ImVec2(5, 5)
style.FrameRounding = 4.0
style.ItemSpacing = ImVec2(12, 8)
style.ItemInnerSpacing = ImVec2(8, 6)
style.IndentSpacing = 25.0
style.ScrollbarSize = 15.0
style.ScrollbarRounding = 9.0
style.GrabMinSize = 5.0
style.GrabRounding = 3.0
        colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]         = ImVec4(0.60, 0.60, 0.60, 1.00)
        colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 1.00)
        colors[clr.ChildWindowBg]        = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[clr.PopupBg]              = ImVec4(0.09, 0.09, 0.09, 1.00)
        colors[clr.Border]               = ImVec4(0.71, 0.71, 0.71, 0.40)
        colors[clr.BorderShadow]         = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[clr.FrameBg]              = ImVec4(0.34, 0.30, 0.34, 1.00)
        colors[clr.FrameBgHovered]       = ImVec4(0.22, 0.21, 0.21, 1.00)
        colors[clr.FrameBgActive]        = ImVec4(0.20, 0.20, 0.20, 1.00)
        colors[clr.TitleBg]              = ImVec4(0.52, 0.27, 0.77, 1.00)
        colors[clr.TitleBgActive]        = ImVec4(0.55, 0.28, 0.75, 1.00)
        colors[clr.TitleBgCollapsed]     = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.MenuBarBg]            = ImVec4(0.27, 0.27, 0.29, 1.00)
        colors[clr.ScrollbarBg]          = ImVec4(0.08, 0.08, 0.08, 0.60)
        colors[clr.ScrollbarGrab]        = ImVec4(0.54, 0.20, 0.66, 0.30)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.21, 0.21, 0.21, 0.40)
        colors[clr.ScrollbarGrabActive]  = ImVec4(0.80, 0.50, 0.50, 0.40)
        colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]            = ImVec4(0.89, 0.89, 0.89, 0.50)
        colors[clr.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.SliderGrabActive]     = ImVec4(0.80, 0.50, 0.50, 1.00)
        colors[clr.Button]               = ImVec4(0.48, 0.25, 0.60, 0.60)
        colors[clr.ButtonHovered]        = ImVec4(0.67, 0.40, 0.40, 1.00)
        colors[clr.ButtonActive]         = ImVec4(0.80, 0.50, 0.50, 1.00)
        colors[clr.Header]               = ImVec4(0.56, 0.27, 0.73, 0.44)
        colors[clr.HeaderHovered]        = ImVec4(0.78, 0.44, 0.89, 0.80)
        colors[clr.HeaderActive]         = ImVec4(0.81, 0.52, 0.87, 0.80)
        colors[clr.Separator]            = ImVec4(0.42, 0.42, 0.42, 1.00)
        colors[clr.SeparatorHovered]     = ImVec4(0.57, 0.24, 0.73, 1.00)
        colors[clr.SeparatorActive]      = ImVec4(0.69, 0.69, 0.89, 1.00)
        colors[clr.ResizeGrip]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.ResizeGripHovered]    = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.ResizeGripActive]     = ImVec4(1.00, 1.00, 1.00, 0.89)
        colors[clr.CloseButton]          = ImVec4(0.33, 0.14, 0.46, 0.50)
        colors[clr.CloseButtonHovered]   = ImVec4(0.69, 0.69, 0.89, 0.60)
        colors[clr.CloseButtonActive]    = ImVec4(0.69, 0.69, 0.69, 1.00)
        colors[clr.PlotLines]            = ImVec4(1.00, 0.99, 0.99, 1.00)
        colors[clr.PlotLinesHovered]     = ImVec4(0.49, 0.00, 0.89, 1.00)
        colors[clr.PlotHistogram]        = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.PlotHistogramHovered] = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.TextSelectedBg]       = ImVec4(0.54, 0.00, 1.00, 0.34)
        colors[clr.ModalWindowDarkening] = ImVec4(0.20, 0.20, 0.20, 0.34)
end


function imgui.OnDrawFrame()
	if not work.v and not work_stat.v then
		imgui.Process = false
	end
	if work.v then
	imgui_colors()
	imgui.ShowCursor = true
	imgui.Begin(u8"MineHelper", work, imgui.WindowFlags.NoResize)
	if imgui.Button(u8"Состояние") then
		sampAddChatMessage("Состояние", -1)
		sampAddChatMessage(render.v and "Рендер на руду: {26FF00}Включен" or "Рендер на руду: {FF0000}Выключен", -1)
		sampAddChatMessage(mesta.v and "Места появления руды: {26FF00}Включен" or "Места появления руды: {FF0000}Выключен", -1)
		sampAddChatMessage(infinityrun.v and "Бесконечный бег: {26FF00}Включен" or "Бесконечный бег: {FF0000}Выключен", -1)
		sampAddChatMessage(cj.v and "Скин CJ: {26FF00}Включен" or "Скин CJ: {FF0000}Выключен", -1)
		sampAddChatMessage(stat.v and "Статистика: {26FF00}Включена" or "Статистика: {FF0000}Выключена", -1)
		sampAddChatMessage(sbiv_q.v and "Сбив на Q: {26FF00}Включена" or "Сбив на Q: {FF0000}Выключена", -1)
	end
	imgui.Checkbox(u8"Рендер на руду", render)
	imgui.Checkbox(u8"Места появления руды", mesta)
	imgui.Checkbox(u8"Бесконечный бег", infinityrun)
	imgui.Checkbox(u8"Скин CJ", cj)
	if imgui.Checkbox(u8"Статистика", stat) then
		work_stat.v = not work_stat.v
	end
	imgui.Checkbox(u8"Сбив на Q", sbiv_q)
	if infinityrun.v then
		if infinityruntrue then
		mem.setint8(0xB7CEE4, 1)
		infinityrunfalse = true
		infinityruntrue = false
	end
	else
		if infinityrunfalse then
		mem.setint8(0xB7CEE4, 0)
		infinityrunfalse = false
		infinityruntrue = true
	end
	end
	if cj.v then
		if cjtrue then
			local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			idskin = getCharModel(PLAYER_PED)
			bss = raknetNewBitStream()
			raknetBitStreamWriteInt32(bss, id)
			raknetBitStreamWriteInt32(bss, 74)
			raknetEmulRpcReceiveBitStream(153, bss)
			raknetDeleteBitStream(bss)
	  cjfalse = true
		cjtrue = false
	end
	else
		if cjfalse then
			local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			bs = raknetNewBitStream()
			raknetBitStreamWriteInt32(bs, id)
			raknetBitStreamWriteInt32(bs, idskin)
			raknetEmulRpcReceiveBitStream(153, bs)
			raknetDeleteBitStream(bs)
		cjfalse = false
		cjtrue = true
	end
	end
	imgui.Text("")
	imgui.Text(u8"Автор: Dazai")
	imgui.End()
end
	if work_stat.v then
		if not work.v then
			imgui.ShowCursor = false
		end
		imgui.Begin(u8"")
		imgui.Text(u8"Камень: "..stone)
		imgui.Text(u8"Металл: "..metall)
		imgui.Text(u8"Бронза: "..bronze)
		imgui.Text(u8"Серебро: "..silver)
		imgui.Text(u8"Золото: "..gold)
		imgui.Text(u8"Всего: "..vsego)
		vsego = stone + metall + bronze + silver + gold
		if imgui.Button(u8"Очистить статистику") then
			stone = 0
			metall = 0
			bronze = 0
			silver = 0
			gold = 0
		end
		imgui.End()
	end
end

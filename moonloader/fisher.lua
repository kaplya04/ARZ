local se = require "samp.events"
local ini = require "inicfg"

local cfg = ini.load({ 
	main = {
		autohook = true,
		echoinfo = true,
		fastsell = true,
		afishrod = true,
		pullmode = 3,
		echowait = 2,
		pullspeed = 2
	}
}, "fisher.ini")

local baits = {}
PULL_THE_FISH_ID = nil
FISHROD_DIALOG_ID = nil
INVENTORY_ID = nil
AWAIT_ECHO = { 0, os.clock() }
ECHO = { model = 18875, x = 263, y = 0, z = 180 }
pullspeed_arr = { 0.2, 0.1, 0.0 }
key_n = { "idle", nil }

function se.onShowDialog(id, style, title, but_1, but_2, text)
	if string.find(title, "Информация о рыбе") then
		baits = {}
		for line in string.gmatch(text, "[^\n]+") do
			local bait_1, bait_2, bait_3 = string.match(line, "{%x+}%d+%.%s{%x+}.+{%x+}%sклюёт%sна%s{%x+}(.*)%s/%s(.*)%s/%s(.*)")
			if bait_1 ~= nil then
				baits[bait_1] = (bait_1 ~= "Отсутствует" and bait_1 ~= "") and true or nil
				baits[bait_2] = (bait_2 ~= "Отсутствует" and bait_2 ~= "") and true or nil
				baits[bait_3] = (bait_3 ~= "Отсутствует" and bait_3 ~= "") and true or nil
			end
		end

		if AWAIT_ECHO[1] == 3 then
			if string.find(text, "В данном секторе отсутствует рыба") then
				sampAddChatMessage("[Эхолот] {EEEEEE}В данном секторе отсутствует рыба!", 0xAAFF33)
				sampSendDialogResponse(id, 0, nil, nil)
				AWAIT_ECHO = { 0, os.clock() }
			else
				AWAIT_ECHO = { 4, os.clock() }
				lua_thread.create(open_fishrod, 300)

				local i, strs = 0, {}
				for bait, _ in pairs(baits) do
					if (i % 7 == 0) or (#strs == 0) then
						table.insert(strs, {})
					end
					table.insert(strs[#strs], bait)
					i = i + 1
				end

				sampAddChatMessage("[Эхолот] {EEEEEE}В данном секторе клюёт на:", 0xAAFF33)
				for i, arr in ipairs(strs) do
					if #arr > 0 then
						local str = table.concat(arr, ", ")
						sampAddChatMessage(str .. (i ~= #strs and "," or ""), 0xAAFF90)
					end
				end
			end
			return false
		end
	end

	if string.find(title, "Выбор наживки") then
		local new_text, array, i = "", {}, 0
		for line in string.gmatch(text, "[^\n]+") do
			local bait, count = string.match(line, "{%x+}(.+)\t{%x+}(%d+){%x+}\t{%x+}%[%s.+%s%]")
			if baits[bait] and tonumber(count) > 0 then
				table.insert(array, { count, i })
				if cfg.main.echoinfo then
					line = string.gsub(line, "{ffffff}", "{ffD900}")
				end
			end
			new_text = string.format("%s%s\n", new_text, line)
			i = i + 1
		end

		if AWAIT_ECHO[1] == 5 then
			if #array > 0 then
				AWAIT_ECHO = { 6, os.clock() }
				table.sort(array, function(a, b) return a[1] > b[1] end)
				sampSendDialogResponse(id, 1, array[1][2] - 1, nil)
			else
				AWAIT_ECHO = { 0, os.clock() }
				sampSendDialogResponse(id, 0, nil, nil)
				sampAddChatMessage("[Ошибка] {EEEEEE}У вас нет ни одной подходящей наживки!", 0xAA3333)
			end
			return false
		end

		if AWAIT_ECHO[1] == 6 then
			AWAIT_ECHO = { 0, os.clock() }
			sampSendDialogResponse(id, 0, nil, nil)
			return false
		end

		return { id, style, title, but_1, but_2, new_text }
	end

	if string.find(title, "Продажа редких вещей") or string.find(title, "Продажа рыбы") and cfg.main.fastsell then
		local count = string.match(text, ".+\n{%x+}%s%-%s{%x+}Стоимость%s1%sшт:%s{%x+}.+\n{%x+}%s%-%s{%x+}У%sвас%sв%sналичии:%s{%x+}(%d+)%sшт%.")
		if count ~= nil then
			if tonumber(count) > 0 then
				sampSendDialogResponse(id, 1, nil, count)
				return false
			else
				sampAddChatMessage("[Ошибка] {EEEEEE}У вас нет этого предмета!", 0xFF4040)
				sampSendDialogResponse(id, 0, nil, nil)
				return false
			end
		end
	end

	if string.find(title, "Оснащение удилища") then
		if AWAIT_ECHO[1] == 4 then
			AWAIT_ECHO = { 5, os.clock() }
			sampSendDialogResponse(id, 1, 6, nil)
			return false
		end

		text = string.gsub(
			text,
			"{%x+}%-{%x+} Забросить удочку",
			"\n{ae433d}-{ffffff} Авто-выбор наживки {AAAAAA}(Эхолот)\n{ae433d}» Забросить удочку\n"
		) .. "\n \n{ae433d}[Fisher] {ffffff}Дополнительные настройки"

		FISHROD_DIALOG_ID = id
		return { id, style, title, but_1, but_2, text }
	end

	if string.find(title, "Подсказка по рыбалке") then
		sampSendDialogResponse(id, 0, nil, nil)
		return false
	end
end

function se.onServerMessage(color, text)
	if AWAIT_ECHO[1] > 0 then
		if string.find(text, "[Ошибка]{ffffff} Рядом с Вами нет мест для рыбалки", 1, true) == 1 then
			AWAIT_ECHO = { 0, os.clock() }
		elseif string.find(text, "[Ошибка]{ffffff} Нельзя так часто, раз в 15 секунд", 1, true) == 1 then
			AWAIT_ECHO = { 0, os.clock() }
		end
	end

	if cfg.main.afishrod then
		local playerId = string.match(text, "^[A-z0-9_]+%[(%d+)%] достал%(а%) удочку из воды из%-за неудачной подсечки$")
		if playerId and select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) == tonumber(playerId) then
			lua_thread.create(open_fishrod, 0)
		end

		local playerId = string.match(text, "^[A-z0-9_]+%[(%d+)%] поймал%(а%) рыбу \".+\"$")
		if playerId and select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) == tonumber(playerId) then
			lua_thread.create(open_fishrod, 0)
		end
	end
end

function se.onSendDialogResponse(id, but, list, input)
	if FISHROD_DIALOG_ID == id and but == 1 then
		FISHROD_DIALOG_ID = nil
		if list == 7 then
			if INVENTORY_ID ~= nil then
				sampAddChatMessage("[Ошибка] {EEEEEE}Сначала закройте инвентарь! Открыть меню удочки можно командой /fishrod", 0xAA3333)
				return { id, but, 0, input }
			end

			sampSendDialogResponse(id, 0, nil, nil)
			sampSendChat("/invent")
			AWAIT_ECHO = { 1, os.clock() }

			lua_thread.create(function()
				while AWAIT_ECHO[1] > 0 do
					if (os.clock() - AWAIT_ECHO[2]) > cfg.main.echowait then
						if AWAIT_ECHO[1] == 1 then
							sampAddChatMessage("[Ошибка] {EEEEEE}Не удалось найти эхолот на {AA3333}1 странице{EEEEEE} в вашем инвентаре!", 0xAA3333)
						else
							sampAddChatMessage("[Ошибка] {EEEEEE}Не удалось выбрать наживку, попробуйте ещё раз!", 0xAA3333)
						end
						if AWAIT_ECHO[1] <= 2 then 
							sampSendClickTextdraw(0xFFFF) 
						end
						AWAIT_ECHO = { 0, os.clock() }
						break
					end
					wait(0)
				end
			end)

			return false
		elseif list == 8 then
			return { id, but, 7, input }
		elseif list == 10 then
			lua_thread.create(function() wait(100); CallMenu() end)
			return { id, 0, list, input }
		end
	end
end

function se.onShowTextDraw(id, data)
	if data.text == "INVENTORY" or data.text == "…H‹EHЏAP’" then
		INVENTORY_ID = id
	end

	if (os.clock() - AWAIT_ECHO[2]) <= cfg.main.echowait then
		if AWAIT_ECHO[1] == 1 then
			if data.modelId == ECHO.model then
				if data.rotation.x == ECHO.x and data.rotation.y == ECHO.y and data.rotation.z == ECHO.z then
					sampSendClickTextdraw(id)
					AWAIT_ECHO = { 2, os.clock() }
			  	end
			end
		elseif AWAIT_ECHO[1] == 2 and id == 2302 then
			sampSendClickTextdraw(id)
			sampSendClickTextdraw(0xFFFF)
			AWAIT_ECHO = { 3, os.clock() }
		end
		return false
	end

	if data.text == "PULL_THE_FISH" and cfg.main.pullmode > 1 then
		if cfg.main.pullmode == 3 then
			key_n = { "auto", nil }
		elseif cfg.main.pullmode == 2 then
			key_n = { "down", nil }
		else
			key_n = { "idle", nil }
		end
		PULL_THE_FISH_ID = id
	end
end

function onReceiveRpc(id, bs)
	if AWAIT_ECHO[1] > 0 and id == 83 then
		return false
	end
end

function sendPressKeyN(state)
	local buffer = allocateMemory(68)
	local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	sampStorePlayerOnfootData(id, buffer)
	setStructElement(buffer, 36, 1, state and 128 or 0, false)
	sampSendOnfootData(buffer)
	freeMemory(buffer)
end

function onWindowMessage(msg, wparam, lparam)
	if key_n[1] == "down" then
		if msg == 0x100 and wparam == 0x4E then
			sendPressKeyN(true)
			sendPressKeyN(false)
			consumeWindowMessage()
		end
	end
end

function se.onDisplayGameText(style, time, text)
	if style == 3 and string.find(text, "~r~PRESS N") and cfg.main.autohook then
		sendPressKeyN(true)
	end
end

function se.onTextDrawHide(id)
	if INVENTORY_ID == id then
		INVENTORY_ID = nil
	end

	if PULL_THE_FISH_ID == id and key_n[1] ~= "idle" then
		key_n[1] = "idle"
		PULL_THE_FISH_ID = nil
	end
end

function open_fishrod(delay)
	wait(delay)
	sampSendChat("/fishrod")
end

function main()
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand("fisher", CallMenu)
	
	while true do
		wait(0)
		local result, button, list, input = sampHasDialogRespond(100)
		if result and await_responce then
			if button == 1 then
				if list == 0 then
					cfg.main.autohook = not cfg.main.autohook
					sampAddChatMessage("[Fisher]{EEEEEE} Подсечка рыбы (ожидание нажатия N) будет происходить " .. (cfg.main.autohook and "{AAFFAA}автоматически" or "{FFAAAA}вручную"), 0xae433d)
				elseif list == 1 then
					cfg.main.echoinfo = not cfg.main.echoinfo
					sampAddChatMessage("[Fisher]{EEEEEE} Приманки, подсказанные эхолотом, " .. (cfg.main.echoinfo and "{AAFFAA}" or "{FFAAAA}не ") .. "будут{EEEEEE} подсвечены в меню выбора наживок", 0xae433d)
				elseif list == 2 then
					cfg.main.fastsell = not cfg.main.fastsell
					sampAddChatMessage("[Fisher]{EEEEEE} Количество предметов или рыбы для продажи будет выбирается " .. (cfg.main.echoinfo and "{AAFFAA}автоматически" or "{FFAAAA}вручную"), 0xae433d)
				elseif list == 3 then
					cfg.main.afishrod = not cfg.main.afishrod
					sampAddChatMessage("[Fisher]{EEEEEE} После вылавливания рыбы меню удочки " .. (cfg.main.afishrod and "{AAFFAA}" or "{FFAAAA}не ") .. "будет{EEEEEE} открываться автоматически", 0xae433d)
				elseif list == 4 then
					cfg.main.pullmode = (cfg.main.pullmode + 1 > 3) and 1 or (cfg.main.pullmode + 1)
					if cfg.main.pullmode == 1 then
						sampAddChatMessage("[Fisher]{EEEEEE} Для того что бы выловить рыбу - {ae433d}кликайте N{AAAAAA} (Стандартная система)", 0xae433d)
					elseif cfg.main.pullmode == 2 then
						sampAddChatMessage("[Fisher]{EEEEEE} Для того что бы выловить рыбу - {ae433d}удерживайте N", 0xae433d)
					elseif cfg.main.pullmode == 3 then
						sampAddChatMessage("[Fisher]{EEEEEE} Вылавливание рыбы будет автоматическим", 0xae433d)
					end
				elseif list == 5 then
					if cfg.main.pullmode == 3 then
						cfg.main.pullspeed = (cfg.main.pullspeed + 1 > 3) and 1 or (cfg.main.pullspeed + 1)
						if cfg.main.pullspeed == 1 then
							sampAddChatMessage("[Fisher]{EEEEEE} Скорость вылавливания рыбы будет такая же как и вручную", 0xae433d)
						elseif cfg.main.pullspeed == 2 then
							sampAddChatMessage("[Fisher]{EEEEEE} Скорость вылавливания рыбы будет заметно быстрее обычной", 0xae433d)
						elseif cfg.main.pullspeed == 3 then
							sampAddChatMessage("[Fisher]{EEEEEE} Рыба будет вылавливаться почти моментально", 0xae433d)
						end
					else
						cfg.main.echowait = (cfg.main.echowait + 1 > 5) and 1 or (cfg.main.echowait + 1)
						sampAddChatMessage(("[Fisher]{EEEEEE} Максимальное время ожидания ответа от сервера при авто-проверке наживки: {ae433d}%d сек."):format(cfg.main.echowait), 0xae433d)
					end
				elseif lust == 6 and cfg.main.pullmode == 3 then
					cfg.main.echowait = (cfg.main.echowait + 1 > 5) and 1 or (cfg.main.echowait + 1)
					sampAddChatMessage(("[Fisher]{EEEEEE} Максимальное время ожидания ответа от сервера при авто-проверке наживки: {ae433d}%d сек."):format(cfg.main.echowait), 0xae433d)
				end
				await_responce = nil
				ini.save(cfg, "fisher.ini")
				CallMenu()
			end
		end

		if key_n[1] == "auto" and (key_n[2] == nil or (os.clock() - key_n[2] >= pullspeed_arr[cfg.main.pullspeed])) then
			sendPressKeyN(true)
			sendPressKeyN(false)
			key_n[2] = os.clock()
		end
	end
end

function CallMenu()
	local text = {
		"{FF6000}* {AAAAAA}Выберите пункт чтобы узнать о нём\t ",
		("{ae433d}-{ffffff} Авто-подсечка:\t%s"):format(cfg.main.autohook and "{4A870B}[ Включено ]" or "{909090}[ Выключено ]"),
		("{ae433d}-{ffffff} Подсветка наживок:\t%s"):format(cfg.main.echoinfo and "{4A870B}[ Включено ]" or "{909090}[ Выключено ]"),
		("{ae433d}-{ffffff} Быстрая продажа:\t%s"):format(cfg.main.fastsell and "{4A870B}[ Включено ]" or "{909090}[ Выключено ]"),
		("{ae433d}-{ffffff} Переоткрывать /fishrod:\t%s"):format(cfg.main.afishrod and "{4A870B}[ Включено ]" or "{909090}[ Выключено ]"),
		("{ae433d}-{ffffff} Вылавливание:\t%s"):format( ({"{909090}Вручную", "{4A870B}Удерживание", "{4A870B}Автоматическое"})[cfg.main.pullmode] ),
		cfg.main.pullmode == 3 and ("{ae433d}-{ffffff} Скорость вылавливания:\t%s"):format( ({"{909090}Обычная (Legit)", "{4A870B}Высокая", "{4A870B}Космическая"})[cfg.main.pullspeed] ) or "",
		("{ae433d}-{ffffff} Таймаут авто-наживки:\t{ae433d}[ %d сек. ]"):format(cfg.main.echowait),
	}
	sampShowDialog(100, "{ae433d}Fisher{EEEEEE} | Автор: Cosmo", table.concat(text, "\n"), "Выбрать", "Закрыть", 5)
	await_responce = true
end
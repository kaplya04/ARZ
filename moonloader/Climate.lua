local se = require "samp.events"
local memory = require "memory"
local ini = require "inicfg"

local actual = {
	time = memory.getint8(0xB70153),
	weather = memory.getint16(0xC81320)
}

local cfg = ini.load({
	time = {
		value = 12,
		lock = false
	},
	weather = {
		value = 1,
		lock = false
	}
}, "Climate.ini")

function se.onSetWeather(id)
	actual.weather = id
	if cfg.weather.lock then
		return false
	end
end

function se.onSetPlayerTime(hour, min)
	actual.time = hour
	if cfg.time.lock then
		return false
	end
end

function se.onSetWorldTime(hour)
	actual.time = hour
	if cfg.time.lock then
		return false
	end
end

function se.onSetInterior(id)
	local result = isPlayerInWorld(id)
	if cfg.time.lock then
		setWorldTime(result and cfg.time.value or actual.time, true) 
	end
	if cfg.weather.lock then 
		setWorldWeather(result and cfg.weather.value or actual.weather, true)
	end
end

function main()
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand("st", setWorldTime)
	sampRegisterChatCommand("sw", setWorldWeather)
	sampRegisterChatCommand("bt", toggleFreezeTime)
	sampRegisterChatCommand("bw", toggleFreezeWeather)
	wait(-1)
end

function setWorldTime(hour, no_save)
	if tostring(hour):lower() == "off" then
		hour = actual.time
	end
	hour = tonumber(hour)
	if hour ~= nil and (hour >= 0 and hour <= 23) then
		local bs = raknetNewBitStream()
		raknetBitStreamWriteInt8(bs, hour)
		raknetEmulRpcReceiveBitStream(94, bs)
		raknetDeleteBitStream(bs)
		if no_save == nil then
			cfg.time.value = hour
			ini.save(cfg, "Climate.ini")
		end
		return nil
	end
	sampAddChatMessage("Используйте: {EEEEEE}/st [0 - 23 или OFF]", 0xFFDD90)
end

function setWorldWeather(id, no_save)
	if tostring(id):lower() == "off" then
		id = actual.weather
	end
	id = tonumber(id)
	if id ~= nil and (id >= 0 and id <= 45) then
		local bs = raknetNewBitStream()
		raknetBitStreamWriteInt8(bs, id)
		raknetEmulRpcReceiveBitStream(152, bs)
		raknetDeleteBitStream(bs)
		if no_save == nil then
			cfg.weather.value = id
			ini.save(cfg, "Climate.ini")
		end
		return nil
	end
	sampAddChatMessage("Используйте: {EEEEEE}/sw [0 - 45 или OFF]", 0xFFDD90)
end

function toggleFreezeTime()
	cfg.time.lock = not cfg.time.lock
	if ini.save(cfg, "Climate.ini") then
		local state = (cfg.time.lock and "не сможет" or "снова может")
		sampAddChatMessage("Теперь сервер " .. state .. " изменять время!", 0xFFDD90)
	end
end

function toggleFreezeWeather()
	cfg.weather.lock = not cfg.weather.lock
	if ini.save(cfg, "Climate.ini") then
		local state = (cfg.weather.lock and "не сможет" or "снова может")
		sampAddChatMessage("Теперь сервер " .. state .. " изменять погоду!", 0xFFDD90)
	end
end

function isPlayerInWorld(interior_id)
	local ip, port = sampGetCurrentServerAddress()
	local address = ("%s:%s"):format(ip, port)
	if address == "80.66.82.147:7777" then -- Vice City
		return (interior_id == 20)
	end
	return (interior_id == 0)
end
--[[
Howto:
  * install dkjson (http://dkolf.de/src/dkjson-lua.fsl/home)
  * register on http://www.wunderground.com/weather/api to get apikey.
  * add into bot config weather_apikey = "yourapikey"
  * use .weather <city_you_want_to_know>
]]


function riddim.plugins.weather(bot)
	local apikey = bot.config.weather_apikey;
	if apikey == nil or apikey == "" then
		print ("Apikey not set. Please set your http://www.wunderground.com apikey in bot config. (weather_apikey = \"YourApikeyHere\")")
	else
		require "net.httpclient_listener";
		local http = require "net.http";
-- 		require "LuaXml"
		local json = require ("dkjson")

		function trim(s)
			return (s:gsub("^%s*(.-)%s*$", "%1"))
		end

		function url_encode(str)
			if (str) then
				str = string.gsub (str, "\n", "\r\n")
				str = string.gsub (str, "([^%w %-%_%.%~])",
					function (c) return string.format ("%%%02X", string.byte(c)) end)
				str = string.gsub (str, " ", "+")
			end
			return str
		end

		bot:hook("commands/weather", function (command)
			local city = trim(command.param);

			if city then
				ecity = url_encode(city)
				url = "http://api.wunderground.com/api/"..tostring(apikey).."/conditions/q/"..tostring(ecity)..".json"
				http.request(url, nil, function (data, code)
					if code ~= 200 then
						command:reply("Error while contacting server!")
						return
					end
					local obj, pos, err = json.decode (data, 1, nil)
					if err then
						command:reply("Error while parsing data!")
					end

					if obj.response.error ~= nil then
						command:reply(tostring(obj.response.error.type).." error: "..tostring(obj.response.error.description)..".")
					else
						response = "Weather for "..obj.current_observation.display_location.full.." (Measured at: "
						..obj.current_observation.observation_location.full.."): Temperature: "
 						..tostring(obj.current_observation.temp_c).."°C (feels like "
 						..tostring(obj.current_observation.feelslike_c).."°C), "
 						..obj.current_observation.weather..", "..obj.current_observation.wind_dir
 						.." wind at speed "..tostring(obj.current_observation.wind_kph).." km/h gusting to "
 						..tostring(obj.current_observation.wind_gust_kph).." km/h. Visibility: "
 						..tostring(obj.current_observation.visibility_km).." km. Last updated: "
 						..os.date("%d.%m.%Y %X", obj.current_observation.observation_epoch).."."
						command:reply(response)
					end
				end);
			else
				command:reply("Please specify city as parameter")
			end
		end);

-- Astro command

		bot:hook("commands/astro", function (command)
			local city = trim(command.param);

			if city then
				ecity = url_encode(city)
				url = "http://api.wunderground.com/api/"..tostring(apikey).."/astronomy/q/"..tostring(city)..".json"
				http.request(url, nil, function (data, code)
					if code ~= 200 then
						command:reply("Error while contacting server!")
						return
					end
					local obj, pos, err = json.decode (data, 1, nil)
					if err then
						command:reply("Error while parsing data!")
					end

					if obj.response.error ~= nil then
						command:reply(tostring(obj.response.error.type).." error: "..tostring(obj.response.error.description)..".")
					else
						response = "Astronomy info for "..city
						.." (Local time "..tostring(obj.moon_phase.current_time.hour)
						..":"..tostring(obj.moon_phase.current_time.minute).."): Sunrise at "
						..tostring(obj.sun_phase.sunrise.hour)..":"
 						..tostring(obj.sun_phase.sunrise.minute)..". Sunset at "
 						..tostring(obj.sun_phase.sunset.hour)..":"
 						..tostring(obj.sun_phase.sunset.minute)..". Moon phase: "
 						..obj.moon_phase.phaseofMoon..", moon visibility is "
 						..tostring(obj.moon_phase.percentIlluminated).."%."
						command:reply(response)
					end
				end);
			else
				command:reply("Please specify city as parameter")
			end
		end);
	end
end

function riddim.plugins.svatky(bot)
	require "net.httpclient_listener";
	local http = require ("net.http");

	function trim(s)
		if  s~= nil and s ~= "" then
			return (s:gsub("^%s*(.-)%s*$", "%1"))
		else
			return ""
		end
	end

	bot:hook("commands/svatek", function (command)
		local addr = trim(command.param) or "";

		if addr then
			url = "http://www.martinsimon.cz/svatky/"
			http.request(url, nil, function (data, code)
				if code ~= 200 then
					command:reply("Error while contacting http://www.martinsimon.cz/svatky/ !")
					return
				end

				svatek = string.match(data, '.*<item><title>(.*)</title>.*')

				command:reply(trim(svatek))
			end);
		end
	end);
end
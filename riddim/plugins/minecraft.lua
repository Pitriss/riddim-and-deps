function riddim.plugins.minecraft(bot)
	require "net.httpclient_listener";
	local http = require ("net.http");

	function trim(s)
		if  s~= nil and s ~= "" then
			return (s:gsub("^%s*(.-)%s*$", "%1"))
		else
			return ""
		end
	end

	function string:split(delimiter)
		local result = { }
		local from = 1
		local delim_from, delim_to = string.find( self, delimiter, from )
		while delim_from do
			table.insert( result, string.sub( self, from , delim_from-1 ) )
			from = delim_to + 1
			delim_from, delim_to = string.find( self, delimiter, from )
		end
		table.insert( result, string.sub( self, from ) )
		return result
	end

	bot:hook("commands/mc", function (command)
		local addr = trim(command.param) or "";

		if addr then
			url = "http://minetest.wjake.com/minecraft/api.php?addr="..addr
			http.request(url, nil, function (data, code)
				if code ~= 200 then
					command:reply("Error while contacting API server!")
					return
				end
				if data == "OFFLINE\n" then
					command:reply("Server "..addr.." is currently offline")
					return
				end
				if data == "NO ADDRESS\n" or addr == "" then
					command:reply("Please specify minecraft server address.")
					return
				end
				datap = string.split(data,"\n")
				local reply = "Server "..datap[1].." is online. Ping: "..datap[4].."ms. Players: "..datap[5]..". MOTD: "..datap[6]
				command:reply(reply)
			end);
		else
			command:reply("Please specify minecraft server address.")
		end
	end);
end

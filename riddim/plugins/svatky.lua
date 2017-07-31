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

	-- Lets define holidays granted by law in Czech rep
	-- http://www.mpsv.cz/cs/74
	svatky = {}

	svatky["0101"] = "Nový rok / Den obnovy samostatného českého státu"
	svatky["0105"] = "Svátek práce"
	svatky["0805"] = "Den vítězství"
	svatky["0507"] = "Den slovanských věrozvěstů Cyrila a Metoděje"
	svatky["0607"] = "Den upálení mistra Jana Husa"
	svatky["2809"] = "Den české státnosti"
	svatky["2810"] = "Den vzniku samostatného československého státu"
	svatky["1711"] = "Den boje za svobodu a demokracii"
	svatky["2412"] = "Štědrý den"
	svatky["2512"] = "1. svátek vánoční"
	svatky["2612"] = "2. svátek vánoční"


	bot:hook("commands/svatek", function (command)
		local addr = trim(command.param) or "";

		if addr then
			datum = os.date("%d%m")
			hrdatum = os.date("%d.%m.")
			url = "http://svatky.adresa.info/txt?date=" .. datum
			http.request(url, nil, function (data, code)
				if code ~= 200 then
					command:reply("Error while contacting http://svatky.adresa.info/ !")
					return
				end
				if data == "" then
					svatek = "-"
				else
					lines = {}
					for ss in data:gmatch("[^\r\n]+") do
						s = ss:gsub("^[0-9]+;(.*)", "%1")
						table.insert(lines, s)
					end
					fcount = 0
					svatek = ""
					for k,v in pairs(lines) do
						if fcount ~= 0 then svatek = svatek .. " a " end
						svatek = svatek .. v
						fcount = fcount+1
					end
				end
				ssvatek = nil
				for k,v in pairs(svatky) do
					if datum == k then
						ssvatek = v
					end
				end
				-- lets generae valid reply
				reply = "Dnes je " .. hrdatum .. "\n"
				if svatek ~= "-" and ssvatek ~= nil then
					reply = reply .. "Dnes má svátek " .. svatek .. " a tento den je zároveň státním svátkem: " ..ssvatek
				elseif svatek ~= "-" and ssvatek == nil then
					reply = reply .. "Dnes má svátek " .. svatek
				else
					reply = reply .. "Tento den je státním svátkem: " .. ssvatek
				end

				command:reply(trim(reply))
			end);
		end
	end);
end

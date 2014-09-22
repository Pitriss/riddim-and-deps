function riddim.plugins.urltitle(bot)
	require "net.httpclient_listener";
	local http = require "net.http";
	local iconv = require "iconv";

	local nstr = nil
	local err = nil
	local title = nil

	local function handler(message)
		local url = message.body and message.body:match("https?://%S+");
		if url then
			http.request(url, nil, function (data, code, headers)
				if code ~= 200 then
					if code == 302 or code == 301 then
						reply = "This link redirects to "..headers.responseheaders.location
						if message.room then
							message.room:send_message(reply)
						else
							message:reply(reply);
						end
					end
					return
				end
				local title = data:match("<title[^>]*>([^<]+)");
				local encod = string.upper(data:match('charset=(%w+[-_]%w+)'))
				if title then
					title = title:gsub("\n", "");
					if encod ~= "UTF-8" then
						local constr = iconv.new("UTF-8", encod.."//TRANSLIT")
						nstr, err = constr:iconv(title)
						title = nstr
					end
					if message.room then
						message.room:send_message(title)
					else
						message:reply(title);
					end
				end
			end);
		end
	end
	bot:hook("message", handler);
	bot:hook("groupchat/joined", function(room)
		room:hook("message", handler)
	end);
end

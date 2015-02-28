-- Copyright (C) 2010 Thilo Cestonaro
--
-- This project is MIT/X11 licensed.
--
YTDEBUG = false
require("net.httpclient_listener");
local http = require("net.http");
local st = require("util.stanza");
local tostring = tostring;

function riddim.plugins.youtube(bot)
	local youtubelink_pattern = "https?:%/%/www.youtube.com%/watch%?v=([%a%-%_%d]+).*";

	local function bare_reply(event, reply)
		if event.stanza.attr.type == 'groupchat' then
			local r = st.reply(event.stanza)
			local room_jid = jid.bare(event.sender.jid);
			if bot.rooms[room_jid] then
				bot.rooms[room_jid]:send(r:tag("body"):text(reply));
			end
		else
			return event:reply(reply);
		end
	end

	local function findYoutubeLink(event)
		local body = event.body;
		if not body then return; end
		if event.delay then return; end -- Don't process old messages from groupchat

		local videoId = body:match(youtubelink_pattern);

		if videoId then
			if YTDEBUG then
				print("VideoID: "..tostring(videoId));
			end
			http.request("http://gdata.youtube.com/feeds/api/videos/"..tostring(videoId).."?v=2", nil, function (data, code, request)
				if YTDEBUG then
					print("returned code: "..tostring(code));
					print("-------------------------------------------------------------------------------------------");
					print("returned data: "..tostring(data));
					print("-------------------------------------------------------------------------------------------");
				end
				if code ~= 200 then
					if code > 0 then
						event:reply("Received HTTP "..code.." error (video gone?)");
					else
						event:reply("Unable to fetch the XEP list from xmpp.org: "..data:gsub("%-", " "));
					end
					return;
				end
				local vidlenght = data:match("<yt:duration seconds='(.-)'/>")
				local vidlen = ""
				if vidlenght ~= nil or vidlenght ~= "" then
					local vidsec = tonumber(vidlenght)
					if string.format("%.2d", vidsec/(60*60)) ~= "00" then
						vidlen = string.format("%.2d:%.2d:%.2d", vidsec/(60*60), vidsec/60%60, vidsec%60)
					else
						vidlen = string.format("%.2d:%.2d", vidsec/60%60, vidsec%60)
					end
				end
				local vidviews = data:match("viewCount='(.-)'")
				local info = ""
				if vidviews ~= nil or vidviews ~= "" then
					info = info.."Viewed "..vidviews.."×, "
				end
				local vidlikes = data:match("numLikes='(.-)'/>")
				local viddislikes = data:match("<yt:rating numDislikes='(.-)'")
				local totallikes = "Likes: "..vidlikes..", Dislikes: "..viddislikes
				info = info..totallikes..", "

				local vidrat = data:match("<gd:rating average='(.-)'")
				local vidrat_r = tonumber(string.format("%.2f", vidrat))

				info = info.."AVG rating: "..vidrat_r.."/5"

				local vidtitle = "Title: " .. data:match("<title>(.-)</title>")
				if info ~= "" then info = "\n["..info.."]" end
				local breply = vidtitle.." ("..vidlen..") "..info
				bare_reply(event, breply)
			end);
		end
	end

	bot:hook("message", findYoutubeLink);
	bot:hook("groupchat/joining", function (room)
		room:hook("message", findYoutubeLink);
	end);
end


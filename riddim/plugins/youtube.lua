-- Copyright (C) 2010 Thilo Cestonaro
--
-- This project is MIT/X11 licensed.
--
YTDEBUG = false
require("net.httpclient_listener");
local http = require("net.http");
local st = require("util.stanza");

	local entities = {
		nbsp = " ",
		iexcl = "¡",
		cent = "¢",
		pound = "£",
		curren = "¤",
		yen = "¥",
		brvbar = "¦",
		sect = "§",
		uml = "¨",
		copy = "©",
		ordf = "ª",
		laquo = "«",
-- 		not = "¬", throws error, handled separately
		shy = "­",
		reg = "®",
		macr = "¯",
		deg = "°",
		plusmn = "±",
		sup2 = "²",
		sup3 = "³",
		acute = "´",
		micro = "µ",
		para = "¶",
		middot = "·",
		cedil = "¸",
		sup1 = "¹",
		ordm = "º",
		raquo = "»",
		frac14 = "¼",
		frac12 = "½",
		frac34 = "¾",
		iquest = "¿",
		Agrave = "À",
		Aacute = "Á",
		Acirc = "Â",
		Atilde = "Ã",
		Auml = "Ä",
		Aring = "Å",
		AElig = "Æ",
		Ccedil = "Ç",
		Egrave = "È",
		Eacute = "É",
		Ecirc = "Ê",
		Euml = "Ë",
		Igrave = "Ì",
		Iacute = "Í",
		Icirc = "Î",
		Iuml = "Ï",
		ETH = "Ð",
		Ntilde = "Ñ",
		Ograve = "Ò",
		Oacute = "Ó",
		Ocirc = "Ô",
		Otilde = "Õ",
		Ouml = "Ö",
		times = "×",
		Oslash = "Ø",
		Ugrave = "Ù",
		Uacute = "Ú",
		Ucirc = "Û",
		Uuml = "Ü",
		Yacute = "Ý",
		THORN = "Þ",
		szlig = "ß",
		agrave = "à",
		aacute = "á",
		acirc = "â",
		atilde = "ã",
		auml = "ä",
		aring = "å",
		aelig = "æ",
		ccedil = "ç",
		egrave = "è",
		eacute = "é",
		ecirc = "ê",
		euml = "ë",
		igrave = "ì",
		iacute = "í",
		icirc = "î",
		iuml = "ï",
		eth = "ð",
		ntilde = "ñ",
		ograve = "ò",
		oacute = "ó",
		ocirc = "ô",
		otilde = "õ",
		ouml = "ö",
		divide = "÷",
		oslash = "ø",
		ugrave = "ù",
		uacute = "ú",
		ucirc = "û",
		uuml = "ü",
		yacute = "ý",
		thorn = "þ",
		yuml = "ÿ",
		fnof = "ƒ",
		Alpha = "Α",
		Beta = "Β",
		Gamma = "Γ",
		Delta = "Δ",
		Epsilon = "Ε",
		Zeta = "Ζ",
		Eta = "Η",
		Theta = "Θ",
		Iota = "Ι",
		Kappa = "Κ",
		Lambda = "Λ",
		Mu = "Μ",
		Nu = "Ν",
		Xi = "Ξ",
		Omicron = "Ο",
		Pi = "Π",
		Rho = "Ρ",
		Sigma = "Σ",
		Tau = "Τ",
		Upsilon = "Υ",
		Phi = "Φ",
		Chi = "Χ",
		Psi = "Ψ",
		Omega = "Ω",
		alpha = "α",
		beta = "β",
		gamma = "γ",
		delta = "δ",
		epsilon = "ε",
		zeta = "ζ",
		eta = "η",
		theta = "θ",
		iota = "ι",
		kappa = "κ",
		lambda = "λ",
		mu = "μ",
		nu = "ν",
		xi = "ξ",
		omicron = "ο",
		pi = "π",
		rho = "ρ",
		sigmaf = "ς",
		sigma = "σ",
		tau = "τ",
		upsilon = "υ",
		phi = "φ",
		chi = "χ",
		psi = "ψ",
		omega = "ω",
		bull = "•",
		hellip = "…",
		prime = "′",
		Prime = "″",
		oline = "‾",
		frasl = "⁄",
		trade = "™",
		larr = "←",
		uarr = "↑",
		rarr = "→",
		darr = "↓",
		harr = "↔",
		part = "∂",
		prod = "∏",
		sum = "∑",
		minus = "−",
		radic = "√",
		infin = "∞",
		cap = "∩",
		int = "∫",
		asymp = "≈",
		ne = "≠",
		equiv = "≡",
		le = "≤",
		ge = "≥",
		loz = "◊",
		spades = "♠",
		clubs = "♣",
		hearts = "♥",
		diams = "♦",
		amp = "&",
		lt = "<",
		gt = ">",
		OElig = "Œ",
		oelig = "œ",
		Scaron = "Š",
		scaron = "š",
		Yuml = "Ÿ",
		circ = "ˆ",
		tilde = "˜",
		zwnj = "",
		zwj = "",
		lrm = "",
		rlm = "",
		ndash = "–",
		mdash = "—",
		lsquo = "‘",
		rsquo = "’",
		sbquo = "‚",
		ldquo = "“",
		rdquo = "”",
		bdquo = "„",
		dagger = "†",
		Dagger = "‡",
		permil = "‰",
		lsaquo = "‹",
		rsaquo = "›",
		euro = "€",
	}

	function ReplaceEntity(entity)
		return entities[string.sub(entity, 2, -2)] or entity
	end

	function HumanReadable(title)
		title = title:match("^%s*(.-)%s*$") -- Remove leading and trailing whitespace
		title = title:gsub('%c','') -- Remove all controll characters
		title = title:gsub("&%a+;", ReplaceEntity) -- Replace entities with characters
		title = title:gsub("&not;", "¬") -- Handled separately due simple design
		title = title:gsub('&quot;', '"') -- Handled separately due simple design
		title = title:gsub('&#039;', "'") -- Apostrophe in numeric.
		return title
	end




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
				local vidviews = data:match("viewCount='(.-)'") or "N/A"
				local info = ""
				info = info.."Viewed "..vidviews.."×, "
				local vidlikes = data:match("numLikes='(.-)'/>") or "N/A"
				local viddislikes = data:match("<yt:rating numDislikes='(.-)'") or "N/A"
				local totallikes = "Likes: "..vidlikes..", Dislikes: "..viddislikes
				info = info..totallikes..", "

				local vidrat = data:match("<gd:rating average='(.-)'") or "N/A"
				local vidrat_r = 0
				if vidrat == "N/A" then
					info = info.."AVG rating: N/A"
				else
					vidrat_r = tonumber(string.format("%.2f", vidrat))
					info = info.."AVG rating: "..vidrat_r.."/5"
				end

				local vidtitle = "Title: " .. data:match("<title>(.-)</title>")
				vidtitle = HumanReadable(vidtitle)
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


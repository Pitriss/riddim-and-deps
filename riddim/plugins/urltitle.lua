function riddim.plugins.urltitle(bot)
	require "net.httpclient_listener";
	local http = require "net.http";
	local iconv = require "iconv";

	local nstr = nil
	local err = nil
	local title = nil

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
				if data:match('charset=(%w+[-_]%w+)') == nil then
					return
				end
				local encod = string.upper(data:match('charset=(%w+[-_]%w+)'))
				if title then
					title = title:gsub("\n", "")
					if encod ~= "UTF-8" then
						local constr = iconv.new("UTF-8//TRANSLIT", encod)
						nstr, err = constr:iconv(title)
						title = nstr
					end
					title = title:match("^%s*(.-)%s*$") -- Remove leading and trailing whitespace
					title = title:gsub('%c','') -- Remove all controll characters
					title = title:gsub("&%a+;", ReplaceEntity) -- Replace entities with characters
					title = title:gsub("&not;", "¬") -- Handled separately due simple design
					title = title:gsub('&quot;', '"') -- Handled separately due simple design
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

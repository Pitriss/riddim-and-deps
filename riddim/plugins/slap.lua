-- slap.lua

local st = require 'util.stanza'

function riddim.plugins.slap(bot)
	if type(bot.config.weapons) ~= 'table' then
		-- start off with something to slap people with
		bot.config.weapons = {'a large trout'}
	end

	function trim(s)
		return (s:gsub("^%s*(.-)%s*$", "%1"))
	end

	-- slap someone
	local function slap(command)
		local who, weapon
		if command.param then
			who = string.lower(trim(command.param))
			if who == string.lower(bot.config.nick) then
				if command.sender.nick then
					who = command.sender.nick
				else
					who = (jid.split(command.sender.jid))
				end
				return string.format('/me slaps %s with %s', who, "a go f**k yourself.:P")
			end
		else
		-- slap the sender if they don't specify a target
			if command.sender.nick then
				who = command.sender.nick
			else
				who = (jid.split(command.sender.jid))
			end
		end
		weapon = bot.config.weapons[math.random(#bot.config.weapons)]
		return string.format('/me slaps %s with %s', who, weapon)
	end

	-- pick up a weapon for slapping
	local function weapon(command)
		if command.param then
		if command.param:lower() == 'excalibur' then
			return 'Listen -- strange women lying in ponds distributing swords is no basis for a system of government.  Supreme executive power derives from a mandate from the masses, not from some farcical aquatic ceremony.'
		elseif command.param:lower() == 'paper' then
			return '"Reverse primary thrust, Marvin." That\'s what they say to me. "Open airlock number 3, Marvin." "Marvin, can you pick up that piece of paper?" Here I am, brain the size of a planet, and they ask me to pick up a piece of paper.'
		else
			table.insert(bot.config.weapons, command.param)
			return '/me picks up '..command.param
		end
		else
		return 'Tell me what weapon to pick up'
		end
	end

   -- drop a weapon
	local function drop(command)
		if command.param then
		local found
		for i,v in ipairs(bot.config.weapons) do
			local weapons = bot.config.weapons
			if v == command.param then
				if #weapons == 1 then
			return '/me refuses to drop his last weapon'
				else
			weapons[i] = weapons[#weapons]
			table.remove(weapons)
			found = true
				end
				break
			end
		end
		if found then
			return '/me drops '..command.param
		else
			return "/me doesn't have "..command.param
		end
		else
		return 'Tell me what to drop'
		end
	end

	local function arsenal(command)
		local all_weapons = " - "
		for i,v in ipairs(bot.config.weapons) do
			local weapons = bot.config.weapons
			all_weapons = all_weapons..weapons[i].." - "
		end
		return '/me have following weapons: \n'..all_weapons
	end

	local function backfire(message)
		local weapon = bot.config.weapons[math.random(#bot.config.weapons)]
		local match = "/me slaps "..bot.config.nick..".*"
		if message.body and message.body:match(match) then
			if message.room then
				message.room:send_message("/me dodges and slaps "..message.nick.." around a bit with "..weapon)
			end
		end
	end

	local function spal(command)
		local who, whotest
		if command.param and trim(command.param) ~= "" then
			who = trim(command.param)
			whotest = string.lower(trim(command.param))
			if whotest == string.lower(bot.config.nick) then
				if command.sender.nick then
					who = command.sender.nick
				else
					who = (jid.split(command.sender.jid))
				end
				return string.format('/me sets %s on fire. Next time don\'t f**k with me.', who)
			end
		else
			return 'Chytej... Tu máš sirky a běž si hrát do stohu, cype.'
		end
		return string.format('Nech %s být. Tu máš sirky a běž si hrát do stohu, cype.', who)
	end

	bot:hook("message", backfire)
	bot:hook("groupchat/joining", function (room)
		room:hook("message", backfire)
	end)
	bot:hook('commands/slap', slap)
	bot:hook('commands/weapon', weapon)
	bot:hook('commands/drop', drop)
	bot:hook('commands/arsenal', arsenal)
	bot:hook('commands/spal', spal)
end

-- end of slap.lua

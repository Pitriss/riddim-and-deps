--[[
This plugin uses quotes from http://en.wikiquote.org/wiki/Linus_Torvalds

Howto:
  * add into bot config torvalds_db = "path to your torvalds.db"
  * use .linus (number of quote)
]]

local function load(path)
	local file = io.open(path)
	local quotes = {}
	if file then
		for line in file:lines() do
			table.insert(quotes, line)
		end
		return quotes
	else
		print ("torvalds_db not set or DB doesn't exist there. Please set correct path to torvalds.dat in this config variable.")
	end
end

local function prnd(to)
	math.randomseed(os.time())
	x = math.random(1,to)
	return x
end

function riddim.plugins.linus(bot)
	local tdb = bot.config.torvalds_db
	local quotes
	quotes = load(tdb)

	bot:hook("commands/linus", function (command)
		if command.param then
			qnr = tonumber(command.param)
		else
			qnr = prnd(#quotes)
		end
		result = quotes[qnr]
		if result == nil or result == "" then
			result = "Quote not found."
		else
			result = result.." [Quote # "..qnr.."]"
		end
		command:reply(result)
	end)
end

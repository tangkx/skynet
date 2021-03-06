local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local db = {}

local command = {}

function command.GET(key)
	return db[key]
end

function command.SET(key, value)
	local last = db[key]
	db[key] = value
	return last
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		--print('......cmd is :',cmd)
		--print('session address is : '..session..address)
		local f = command[string.upper(cmd)]
		if f then
			print('f is :',f)
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "SIMPLEDB"
end)

local skynet = require "skynet"
require "skynet.manager"

local db = {}
local command = {}

function command.SET(key,value)
	-- body
	local val = db[key]
	db[key] = value
	return val
end

function command.GET(key)
	-- body
	return db[key]
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua",function ( session,addr,cmd,...)
		-- body
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))	
		else
			print('cmd is error')
		end

	end)

	skynet.register "TKXDB"

end)
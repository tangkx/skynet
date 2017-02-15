local skynet = require "skynet"
local redis = require "redis"

local conf = {
	host="127.0.0.1",
	port = 6379,
	db = 0
}

skynet.start(function ()
	-- body
	local db = redis.connect(conf)
	if not db then
		print("redis connect fail")
	else
		print("redis connect successful")
	end
	

	db:set("F","hello redis")
	print('.....'..db:get("F"))
end)
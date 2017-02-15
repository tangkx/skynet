-- @Author: tkx
-- @Date:   2017-02-13 11:09:50
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-14 17:14:41
package.path = "./service/?.lua;./examples/?.lua;./mysqlcluster/?.lua;./lualib/?.lua"
package.cpath = "./cservice/?.so;./luaclib/?.so"

local skynet = require "skynet"
local redislpool = require "redispool"
local config = require "server_config"

local redisdb
local CMD = {}

function CMD.start()

	local redisconf = config.redis_config
	redisdb = redislpool.new()
	redisdb:init(redisconf)
end

function CMD.set(key, values)

	local db = redisdb:getDB()
	local res = db:set(key, values)
	redisdb:free(db)

	return res
end

function CMD.get(key)

	local db = redisdb:getDB()
	local res = db:get(key)
	redisdb:free(db)

	return res
end

function CMD.hmset(key, t)

	local data = {}
	for k,v in pairs(t) do
		table.insert(data, k)
		table.insert(data, v)
	end
	local db = redisdb:getDB()
	local res = db:hmset(key, table.unpack(data))
	redisdb:free(db)
	return res
end

function CMD.hmget(key, ...)

	if not key then return end
	local db = redisdb:getDB()
	local res = db:hmget(key, ...)
	redisdb:free(db)
	return res
end

function CMD.hgetall(key)
	
	local db = redisdb:getDB()
	local res = db:hgetall(key)
	redisdb:free(db)
	return res
end

function CMD.hset(key, field, value)

	local db = redisdb:getDB()
	local res = db:hset(key, field, value)
	redisdb:free(db)	
	return res
end

function CMD.hget(key, field)

	local db = redisdb:getDB()
	local res = db:hget(key, field)
	redisdb:free(db)	
	return res
end

function CMD.zadd(key, score, member)

	local db = redisdb:getDB()
	local res = db:zadd(key, score, member)
	redisdb:free(db)
	return res
end

function CMD.zrange(key, head, tail)

	local db = redisdb:getDB()
	local res = db:zrange(key, head, tail, "withscores")
	redisdb:free(db)
	return res
end

function CMD.zscore(key, member)
	
	local db = redisdb:getDB()
	local res = db:zscore(key, member)
	redisdb:free(db)
	return res
end

function CMD.zrevrange(key, head, tail)
	
	local db = redisdb:getDB()
	local res = db:zrevrange(key, head, tail, "withscores")
	redisdb:free(db)
	return res
end

function CMD.zrank(key, member)
	
	local db = redisdb:getDB()
	local res = db:rank(key, member)
	redisdb:free(db)
	return res
end

function CMD.zcount(key, head, tail)
	
	local db = redisdb:getDB()
	local res = db:zcount(key, head, tail)
	redisdb:free(db)
	return res
end

function CMD.zcard(key)
	
	local db = redisdb:getDB()
	local res = db:zcard(key)
	redisdb:free(db)
	return res
end

function CMD.del(key)

	local db = redisdb:getDB()
	local res = db:del(key)
	redisdb:free(db)
	return res
end


skynet.start(function ()
	skynet.dispatch("lua", function(_,_, command, ...)
		
		local f = assert(CMD[command], command..'not found')
		skynet.ret(skynet.pack(f(...)))
	end)
end)
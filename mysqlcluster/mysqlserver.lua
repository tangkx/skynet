-- @Author: tkx
-- @Date:   2017-02-13 09:15:00
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-15 14:14:57
package.path = "./service/?.lua;./examples/?.lua;./mysqlcluster/?.lua;./lualib/?.lua;./log/?.lua"
package.cpath = "./cservice/?.so;./luaclib/?.so"

local skynet = require "skynet"
local mysqlpool = require "mysqlpool"
local config = require "server_config"
require "tprint"
--require "skynet.manager"

local mysqldb

local CMD = {}

function CMD.start()
	local dbconf = config.mysql_config

	mysqldb = mysqlpool.new()
	mysqldb:init(dbconf)
end

function CMD.query(sql)
	local db = mysqldb:getDB()
	printI("what is :",db)
	local result
	if not db then
		result = nil
		printE("it's not db")
	else
		result = db:query(sql)
		mysqldb:free(db)
	end

	return result
end


skynet.start(function ()
	skynet.dispatch("lua", function(_,_, command, ...)
		
		local f = assert(CMD[command],command..'not found')
		skynet.ret(skynet.pack(f(...)))
	end)

end)
-- @Author: tkx
-- @Date:   2017-02-13 14:58:32
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-15 17:42:57
package.path = "./lualib/?.lua;./service/?.lua;./test/?.lua;./examples/?.lua;./log/?.lua"

local skynet = require "skynet"
local cluster = require "cluster"
require "tprint"

skynet.start(function()

	-- print(os.time{year = 2017, month = 2, day = 15, hour = 0})
	-- print(os.time())
	-- local temp = os.date("*t", 1487000000)
		-- for k,v in pairs(temp) do
	-- 	print(k,v)
	-- end

	local a = 321
	local b = 521
	print(a&0xFF)
	print(a&0xFF00)
	print(b&0xFF)
	print(b&0xFF00)

	print(~a)
	print(~b)
	cluster.open "c_log"
	local log = skynet.uniqueservice("tlog")
	skynet.call(log, "lua", "start")
	
	printD("my name is tkx")

end)
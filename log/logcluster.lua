-- @Author: tkx
-- @Date:   2017-02-13 14:58:32
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-13 16:31:30
package.path = "./lualib/?.lua;./service/?.lua;./test/?.lua;./examples/?.lua;./log/?.lua"

local skynet = require "skynet"
local cluster = require "cluster"
require "tprint"

skynet.start(function()

	cluster.open "c_log"
	local log = skynet.uniqueservice("tlog")
	skynet.call(log, "lua", "start")
	
	printD("my name is tkx")

end)
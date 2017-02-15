-- @Author: tkx
-- @Date:   2017-02-14 09:36:17
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-14 10:10:39

local skynet = require "skynet"
local cluster = require "cluster"

local conf = {
	address="127.0.0.1",
	port = 8888,
	maxclient = 64,
	nodelay = true,
}

skynet.start(function ()
	
	skynet.uniqueservice("protoloader")
	cluster.open "gateport"
	local gate = skynet.uniqueservice("tgate")
	skynet.call(gate, "lua", "open", conf)
end)
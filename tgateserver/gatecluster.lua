-- @Author: tkx
-- @Date:   2017-02-14 09:36:17
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-15 16:34:43

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

	local mdb = cluster.query("c_database", "mdb")
	local rdb = cluster.query("c_database", "rdb")
	local mproxy = cluster.proxy("c_database", mdb)
	local rproxy = cluster.proxy("c_database", rdb)

	local res = skynet.call(mproxy, "lua", "query", "select *from cats")
	for k,v in pairs(res) do
		if type(v) == "table" then
			for i,j in pairs(v) do
				print(i,j)
			end
		else
			print(k, v)
		end
	end

	res = skynet.call(rproxy, "lua",  "zrange", "TEST", 0, -1)
	if type(res) == "table" then
		for k,v in pairs(res) do
			print(k,v)
		end
	else
		print(res)
	end
end)
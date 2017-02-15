-- @Author: tkx
-- @Date:   2017-02-13 09:44:25
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-14 17:14:33

local skynet = require "skynet"
local cluster = require "cluster"

skynet.start(function()

	cluster.open "c_database"
	local mdb = skynet.uniqueservice("mysqlserver")
	local rdb = skynet.uniqueservice("redisserver")
	local log = skynet.uniqueservice("tlog")

	skynet.call(log, "lua", "start")
	skynet.call(mdb,"lua","start")
	skynet.call(rdb,"lua","start")

	local res = skynet.call(mdb,"lua","query","select *from cats")
	print(#res)

	-- res = skynet.call(rdb,"lua","set","name","tkx")
	-- print(res)

	-- res = skynet.call(rdb,"lua","get","name")
	-- print(res)

	res = skynet.call(rdb, "lua", "zadd", "TEST", 5, "t")
	print(res)
	res = skynet.call(rdb, "lua", "zadd", "TEST", 7, "k")
	print(res)
	res = skynet.call(rdb, "lua", "zadd", "TEST", 8, "x")
	print(res)

	res = skynet.call(rdb, "lua", "zrange", "TEST", 0, -1)
	if type(res) == "table" then
		for k,v in pairs(res) do
			print(k,v)
		end
	else
		print(res)
	end


	-- register name "sdb" for simpledb, you can use cluster.query() later.
	-- See cluster2.lua
	cluster.register("mdb", mdb)
	cluster.register("rdb", rdb)

end)
local skynet = require "skynet"
local cluster = require "cluster"

skynet.start(function()
	-- query name "sdb" of cluster db.
	--local sdb = cluster.query("db", "sdb")
	local sdb = cluster.query("db2","sdb")
	print("db.sbd=",sdb)
	local proxy = cluster.proxy("db", sdb)
	local largekey = string.rep("X", 2)
	local largevalue = string.rep("R", 2)
	print(skynet.call(proxy, "lua", "SET", largekey, largevalue))
	local v = skynet.call(proxy, "lua", "GET", largekey)
	assert(largevalue == v)

	print(cluster.call("db", sdb, "GET", "a"))
	print(cluster.call("db2", sdb, "GET", "a"))
	print(cluster.call("db2", sdb, "GET", "b"))

	-- test snax service
	local pingserver = cluster.snax("db", "pingserver")
	print(pingserver.req.ping "hello")
end)

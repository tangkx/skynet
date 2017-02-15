local skynet = require "skynet"
local cluster = require "cluster"

skynet.start(function ()
	-- body
	--cluster.open "db1"

	local sdb = cluster.query("db","sdb")
	local mysqldb = cluster.query("db1","mysqldb")
	print("......sdb= ",sdb)
	print("......mysqldb",mysqldb)

	local proxy = cluster.proxy("db",sdb)
	
	local mysqlproxy = cluster.proxy("db", mysqldb)

	--local res = skynet.call(mysqlproxy, "lua", "query")
	local res = cluster.call("db",mysqlproxy,"query")
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			print(i,j)
		end
	end

	print(skynet.call(proxy,"lua","GET","a"))
	print(skynet.call(proxy,"lua","GET","b"))

	print('proxy...cluster...'..cluster.call("db",proxy,"GET","a"))
	print('proxy...cluster...'..cluster.call("db",proxy,"GET","b"))
	--print(cluster.call("db",sdb,"GET","a"))

	--local tkx = cluster.snax("db","tkxserver")
	--print('.....'..tkx.req.hello "hello cluster")


end)
package.cpath = "./cservice/?.so;./luaclib/?.so"
package.path = "./lualib/?.lua;./service/?.lua;./tkx_test/?.lua;./examples/?.lua"

local skynet = require "skynet"
local cluster = require "cluster"
local snax = require "snax"
local crypt = require "crypt"
local cjson = require "cjson"

skynet.start(function()
	-- body
	local sdb = skynet.newservice("	tkxdb")
	local  mysqldb = skynet.newservice("tkx_mysql")
	cluster.register("sdb",sdb)
	cluster.register("mysqldb",mysqldb)

	local res = skynet.call(mysqldb,"lua","query")
	for k,v in pairs(res) do
		for i,j in pairs(v) do
			print(i,j)
		end
	end
	
	print(skynet.call(sdb,"lua","SET","a","foobar"))
	print(skynet.call(sdb,"lua","SET","b","foobar1"))
	print(skynet.call(sdb,"lua","GET","a"))
	print(skynet.call(sdb,"lua","GET","b"))

	cluster.open "db"
	cluster.open "db1"

	--print("......"..cluster.call("db",sdb,"GET","a"))
	--print("......"..cluster.call("db",sdb,"GET","b"))

	--local x = crypt.base64encode("123")
	--print('....encode: ',x)
	--print('....decode: ',crypt.base64decode(x))
	--snax.uniqueservice "tkxserver"

	--local sampleJson = [[{"age":"23","testArray":{"array":[8,9,11,14,25]},"Himi":"himigame.com"}]]
	
	skynet.fork(function ()
		while true do
			for i=1, 100 do
				print('heartbeat'..i)
				skynet.sleep(100)
				if i == 100 then
					break;
				end
			end
			break;
		end
	end)

	local jsontable = {}
	local array = {}
	array["age"] = 100
	array["firstname"] = "tang"
	jsontable["name"] = "tkx"
	jsontable["array"] = array
	local jsonstr = cjson.encode(jsontable)
	print(jsonstr)


	local data = cjson.decode(jsonstr);
	for k,v in pairs(data) do
		print(k,v)
	end
end)
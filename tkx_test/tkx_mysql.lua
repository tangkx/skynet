local skynet = require"skynet"
local mysql = require "mysql"

local conf = {
		host="127.0.0.1",
		port=3306,
		database="skynet",
		user="root",
		password="123",
		max_packet_size=1024*1024,
		on_connect=on_connect
		}

local function on_connect(db)
	db:query("set charset utf8")
end

local CMD = {}
local db

function CMD.query()
	--local id = 1
	local res = db:query("select * from cats")
	return res
end

skynet.start(function ()

	db = mysql.connect(conf)

	if not db then
		print("failed to connect")
	else
		print("testmysql success to connect to mysql server")
	end
	

	skynet.dispatch("lua",function (session, source, command, ...)
		print(command)
		local f = CMD[command]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			print("error command")
		end
		
	end)

end)
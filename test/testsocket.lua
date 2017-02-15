local skynet = require "skynet"
local socket = require "socket"

local mode , id = ...

local function echo(id)
	socket.start(id)

	while true do
		local str = socket.read(id)
		if str then
			print("client message is :",str.."\n")
			socket.write(id, str)
		else
			socket.close(id)
			return
		end
	end
end

if mode == "agent" then
	id = tonumber(id)

	skynet.start(function()
		skynet.fork(function()
			echo(id)
			skynet.exit()
		end)
	end)
else
	local function accept(id)
		socket.start(id)
		str = socket.read(id)
		print("client message is :",str)
		--socket.write(id, "Hello Skynet\n")
		socket.write(id,str)
		--skynet.newservice(SERVICE_NAME, "agent", id)
		-- notice: Some data on this connection(id) may lost before new service start.
		-- So, be careful when you want to use start / abandon / start .
		--socket.abandon(id)
	end

	skynet.start(function()
		local id = socket.listen("127.0.0.1", 8001)
		print("Listen socket :", "127.0.0.1", 8001)
		

		socket.start(id , function(id, addr)
			print("connect from " .. addr .. " " .. id)

			-- you have choices :
			--skynet.newservice("testsocket", "agent", id)
			--skynet.fork(echo, id)
			-- 3. accept(id)
			accept(id)
		end)
	end)
end
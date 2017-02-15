local skynet = require "skynet"
local socket = require "socket"

local function readmsg(id)
	-- body
	print('......readmsg')
	--socket.start(id)
	if not id then
		return "no client connect"
	else
		return  socket.read(id)
	end

end

local function requestmsg(id,msg)
	-- body
	--socket.start(id)
	if not id then
		
		print("no client connect")
	else
		socket.write(id,msg)
	end
end
skynet.start(function()
	-- body
	local id = socket.listen("127.0.0.1",8888)
	print("listen 127.0.0.1:8888")
	socket.start(id,function (id,addr)
		-- body
		print("connect from " .. addr .. " " .. id)
		socket.start(id)
		local client_msg = readmsg(id)
		print('......MSG.....'..client_msg)
		requestmsg(id,client_msg)
	end)
end)
local skynet = require "skynet"
local netpack = require "netpack"

local CMD = {}
local SOCKET = {}
local gate
local agent = {}

function SOCKET.open(fd, addr)
	print('&&&&watchdog socket.open')

	skynet.error("New client from : " .. addr)
	agent[fd] = skynet.newservice("agent")
	skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })
end

local function close_agent(fd)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.send(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	print('&&&&watchdog socket.close',fd)

	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print('&&&&watchdog socket.error')

	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	print('&&&&watchdog socket.warning')

	-- size K bytes havn't send out in fd
	print("socket warning", fd, size)
end

function SOCKET.data(fd, msg)
	print('#######socket.data ',fd,msg)
end

function CMD.start(conf)
	print('&&&&watchdog CMD.start')

	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	print('&&&&watchdog CMD.close')

	close_agent(fd)
end

skynet.start(function()
	print('&&&&watchdog skynet.start')

	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		print('&&&&watchdog skynet.dispatch',cmd,subcmd)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gate")
end)

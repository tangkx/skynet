local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd

function REQUEST:get()

	print('&&&&agent REQUEST:get')
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print('&&&&agent REQUEST:set')
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	print('&&&&agent REQUEST:handshake')
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	print('&&&&agent REQUEST:quit')
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	
	local f = assert(REQUEST[name])
	--print('***agent request',name,args,response,f)
	local r = f(args)
	print('***agent request',r)
	if response then
		--print('***agent request response()',response(r))
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		print('&&&&agent skynet.register_protocol  dispatch')
		print(...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}

function CMD.start(conf)
	print('&&&&agent CMD.start')
	local i = 0
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.fork(function()
		while true do
			local str = send_request("heartbeat",{heartbeat = i})
			send_package(str)
			i = i+1
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	print('&&&&agent CMD.disconnect')
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	print('&&&&agent skynet.start')
	skynet.dispatch("lua", function(_,_, command, ...)
		print('&&&&agent skynet.dispatch')
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)

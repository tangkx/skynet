local skynet = require "skynet"
local netpack = require "netpack"
local socketdriver = require "socketdriver"

local mygateserver = {}
local socket
local queue
local maxclient
local client_number = 0
local CMD = setmetatable({}, {__gc = function ()  netpack.clear(queue) end})
local nodelay = false

local connection = {}

function mygateserver.openclient(fd)
	if connection[fd] then
		socketdriver.start(fd)
	end
end

function mygateserver.closeclient(fd)
	local c = connection[fd] 
	if c then
		connection[fd] = false
		socketdriver.close(fd)
	end
end

function mygateserver.start(handler)
	
	assert(handler.connect)
	assert(handler.message)

	function CMD.open(source, conf)
		assert(not socket)
		local address = conf.address or "0.0.0.0"
		local port = assert(conf.port)
		maxclient = conf.maxclient or 1024
		nodelay = conf.nodelay or false
		skynet.error(string.format("listen on %s:%d", address, port))
		socket = socketdriver.listen(address, port)
		socketdriver.start(socket)
		if handler.open then
			return handler.open(source, conf)
		end
	end

	function CMD.close()
		assert(socket)
		socketdriver.close(socket)
	end

	local MSG = {}


	local function dispatch_msg(fd, msg, sz)
		
		if connection[fd] then
			handler.message(fd, msg, sz)
		else
			skynet.error(string.format("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz)))
		end
	end

	MSG.data = dispatch_msg

	local function dispatch_queue()
		
		local fd, msg, sz = netpack.pop(queue)
		if fd then
			skynet.fork(dispatch_queue)
			dispatch_msg(fd, msg, sz)

			for fd, msg, sz in netpack.pop, queue do
				dispatch_msg(fd, msg, sz)
			end
		end
	end

	MSG.more = dispatch_queue

	function MSG.open(fd, msg)

		if client_number >= maxclient then
			socketdriver.close(fd)
			return
		end

		if nodelay then 
			socketdriver.nodelay(fd)
		end

		connection[fd] = true
		client_number = client_number + 1
		handler.connect(fd, msg)
	end

	local function close_fd(fd)
		local c = connection[fd]
		if c ~= nil then
			connection[fd] = nil
			client_number = client_number - 1 
		end
	end

	function MSG.close(fd)
		if fd ~= socket then 
			if handler.disconncet then 
				handler.disconncet(fd)
			end
			close_fd(fd)
		else
			socket = nil
		end
	end

	function MSG.error(fd, msg)
		
		if fd == socket then
			socketdriver.close(fd)
			skynet.error(msg)
		else
			if handler.error then
				handler.error(fd, msg)
			end
			close_fd(fd)
		end
	end

	function MSG.warining(fd, size)
		
		if handler.warining then
			handler.warining(fd, size)
		end
	end

	skynet.register_protocol{

		name = "socket",
		id = skynet.PTYPE_SOCKET,
		unpack = function (msg, sz)
			return netpack.tostring(msg, sz)
		end,

		dispatch = function (_, _, q, type, ...)
			queue = q
			if type then
				MSG[type](...)
			end
		end

	}
	skynet.start(function ()
		
		skynet.dispatch("lua", function (_, address, cmd, ...)
			local f = CMD[cmd]
			if f then 
				skynet.ret(skynet.pack(f(address, ...)))
			else
				skynet.ret(skynet.pack(handler.command(cmd, address, ...)))
			end
		end)
	end)

end

return mygateserver
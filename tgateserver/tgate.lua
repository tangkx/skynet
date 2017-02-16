-- @Author: tkx
-- @Date:   2017-02-14 09:08:23
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-15 11:29:20
package.path = "./lualib/?.lua;./service/?.lua;./test/?.lua;./examples/?.lua;./tgateserver/?.lua;./log/?.lua"

local skynet = require "skynet"
local gateserver = require "tgateserver"
local netpack = require "netpack"

local watchdog
local connection = {}	-- fd -> connection : { fd , client, agent , ip, mode }
local forwarding = {}	-- agent -> connection

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handler = {}

function handler.open(source, conf)
	--print('&&&&gate handler.open')
	--watchdog = conf.watchdog or source
end

function handler.message(fd, msg, sz)
	--print('&&&&gate handler.message')
	-- recv a package, forward it
	local c = connection[fd]
	local agent = c.agent
	if agent then
		print('####',agent,c.client)
		skynet.redirect(agent, c.client, "client", 1, msg, sz)
	else
		print("agent is nil")
	end
end

function handler.connect(fd, addr)
	--print('&&&&gate handler.connect')
	local agent = skynet.newservice("tagent")
	local c = {
		fd = fd,
		ip = addr,
		agent = agent
	}
	connection[fd] = c
	skynet.call(c.agent, "lua", "start", { gate = skynet.self() , client = fd})
	print("*****connection agent",fd,connection[fd].agent)
	--skynet.send(watchdog, "lua", "socket", "open", fd, addr)
end

local function unforward(c)
	if c.agent then
		forwarding[c.agent] = nil
		c.agent = nil
		c.client = nil
	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c then
		unforward(c)
		connection[fd] = nil
	end
end

function handler.disconnect(fd)
	--print('&&&&gate handler.disconnect')
	close_fd(fd)
	--skynet.send(watchdog, "lua", "socket", "close", fd)
end

function handler.error(fd, msg)
	--print('&&&&gate handler.error')
	close_fd(fd)
	--skynet.send(watchdog, "lua", "socket", "error", fd, msg)
end

function handler.warning(fd, size)
	--print('&&&&gate handler.warning')
	--skynet.send(watchdog, "lua", "socket", "warning", fd, size)
end

local CMD = {}

function CMD.forward(source, fd, client, address)
	--print('&&&&gate CMD.forward',source,fd,client,address)

	local c = assert(connection[fd])
	unforward(c)
	c.client = client or 0
	c.agent = address or source
	forwarding[c.agent] = c
	gateserver.openclient(fd)
end

function CMD.accept(source, fd)
	--print('&&&&gate CMD.accept')
	local c = assert(connection[fd])
	unforward(c)
	gateserver.openclient(fd)
end

function CMD.kick(source, fd)
	--print('&&&&gate CMD.kick')
	gateserver.closeclient(fd)
end

function handler.command(cmd, source, ...)
	--print('&&&&gate handler.command')
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)

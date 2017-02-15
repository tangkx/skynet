package.cpath = "./cservice/?.so;./luaclib/?.so"
package.path = "./lualib/?.lua;./service/?.lua;./tkx_test/?.lua;./examples/?.lua"

local gateserver = require "snax.gateserver"
local skynet = require "skynet"
local netpack = require "netpack"
local cjson = require "cjson"

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local connection = {}


local handler = {}

function handler.open(source, conf)
	-- body
	print("****handler open",source)
	print("****conf",conf.address,conf.port,conf.maxclient,conf.nodelay)
end

function handler.connect(fd, ipaddr)
	-- body
	connection[fd] = ipaddr
	print("****handler connect",fd,ipaddr)
	gateserver.openclient(fd)
end

function handler.message(fd, msg, sz)
	-- body
	print("****handler message",fd)
	--print("*****MSG",msg,sz)
	print("%%%%%%TYPE",type(netpack.tostring(msg,sz)))
	--print("%%%%%%MSG",netpack.tostring(msg,sz))

	local data = cjson.decode(netpack.tostring(msg,sz));
	--local data = netpack.tostring(msg,sz);
	for k,v in pairs(data) do
		if type(v) == 'table' then
			for i,j in pairs(v) do
				print(i,j)
			end
		else
			print(k,v)
		end
	end
	--print("&&&&"..string.unpack(">s2", msg))
end

function handler.disconnect(fd)
	-- body
	connection[fd] = nil
	print("****handler disconnect")
	gateserver.closeclient(fd)
end

function handler.error(fd, msg)
	-- body
	print("****handler error")
end

function handler.warning(fd, size)
	-- body
	print("****handler warning")
end

function handler.command(cmd, source, ...)
	print("****handler.command")
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)


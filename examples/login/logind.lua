local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"

local server = {
	host = "127.0.0.1",
	port = 8001,
	multilogin = false,	-- disallow multilogin
	name = "login_master",
}

local server_list = {}
local user_online = {}
local user_login = {}

function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	print('.....logind...server.auth_handler')
	print("#####logind..token :",token)
	--local user, server, password = token:match("([^#]+)@([^#]+):([^#]+)")
	local user, server, password = token:match("(.+)@(.+):(.+)")
	print(string.format("%s:**%s:**%s",user,server,password))
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	print(string.format("%s:**%s:**%s",user,server,password))
	assert(password == "password", "Invalid password")

	
	return server, user
end

function server.login_handler(server, uid, secret)
	print(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	local gameserver = assert(server_list[server], "Unknown server")
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	--print('######last..'..last)
	--print('######user_online[uid]..'..user_online[uid])

	if last then
		skynet.call(last.address, "lua", "kick", uid, last.subid)
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end

	local subid = tostring(skynet.call(gameserver, "lua", "login", uid, secret))
	user_online[uid] = { address = gameserver, subid = subid , server = server}

	print('.....logind...server.login_handler')
	return subid
end

local CMD = {}

function CMD.register_gate(server, address)
	server_list[server] = address
	print('#####server is:',server_list[server])
	print('.....logind...CMD.register_gate')
	print(server..address)
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.server))
		user_online[uid] = nil
	end
	print('.....logind...CMD.logout')
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])

	print('.....logind...server.command_handler')
	return f(...)
end

login(server)

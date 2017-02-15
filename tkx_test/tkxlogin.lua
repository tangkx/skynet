local loginserver = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"

local server = {
	host = "127.0.0.1",
	port = 8008,
	multilogin = false,
	name = "tkx_login",
}

local server_list = {}
local user_online = {}
local user_login = {}

function server.auth_handler( token)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)

	assert(password == "password","error password")

	return server, user
end

function server.login_handler(server, uid, secret)
	
end

function server.command_handler( command, ... )

	local f = assert(CMD[command])
	return f(...)
end

local CMD = {}

function CMD.register_gate(server, address)
	server_list[server] = address
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.server))
		user_online[uid] = nil
	end
end

loginserver(server)


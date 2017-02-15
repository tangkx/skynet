-- @Author: tkx
-- @Date:   2017-02-13 15:25:05
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-13 17:43:47
package.path = "./lualib/?.lua;./service/?.lua;./examples/?.lua;./log/?.lua;./mysqlcluster/?.lua"

local skynet = require "skynet"
local config = require "server_config"


local logconfig = config.log_config

function printI(str, ...)
	if(logconfig.info) then
		skynet.error("[INFO]", string.format(str, ...))
		LOG_INFO(str, ...)
	end
end

function printE(str, ...)
	if(logconfig.error) then
		skynet.error("[ERROR]", string.format(str, ...))
		LOG_ERROR(str, ...)
	end
end

function printD(str, ...)
	if(logconfig.debug) then
		skynet.error("[DEBUG]", string.format(str, ...))
		LOG_DEBUG(str, ...)
	end
end

function LOG_DEBUG(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(".log", "lua", "debug", SERVICE_NAME, msg)
end

function LOG_INFO(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(".log", "lua", "info", SERVICE_NAME, msg)
end

function LOG_WARNING(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(".log", "lua", "warning", SERVICE_NAME, msg)
end

function LOG_ERROR(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(".log", "lua", "error", SERVICE_NAME, msg)
end

function LOG_FATAL(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(".log", "lua", "fatal", SERVICE_NAME, msg)
end
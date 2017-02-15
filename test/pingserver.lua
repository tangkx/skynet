local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "snax"

local i = 0
local hello = "hello"

function response.ping(hello)
	skynet.sleep(100)
	print(hello)
	return hello
end

-- response.sleep and accept.hello share one lock
local lock

function accept.sleep(queue, n)
	print('.....pingserver...accept.sleep')
	if queue then
		lock(
		function()
			print("queue=",queue, n)
			skynet.sleep(n)
		end)
	else
		print("queue=",queue, n)
		skynet.sleep(n)
	end
end

function accept.hello()
	print('.....pingserver...accept.hello')
	lock(function()
	i = i + 1
	print (i, hello)
	end)
end

function accept.exit(...)
	print('.....pingserver...accept.exit')
	snax.exit(...)
end

function response.error()
	print('.....pingserver...response.error')
	--error "throw an error"
end

function init( ... )
	print ("ping server start:", ...)
	snax.enablecluster()	-- enable cluster call
	-- init queue
	lock = queue()
end

function exit(...)
	print ("ping server exit:", ...)
end

local skynet = require "skynet"
local snax = require "snax"
local queue = require "skynet.queue"

local i = 0 
function response.hello(str)
	-- body
	skynet.sleep(1000)
	return 'tkx:'..str
end

function accept.hello(str)
	-- body
	i = i + 1
	print(str..':'..i)
end

function init()
	-- body
	snax.enablecluster()
	print('......tkxserver is start')
end
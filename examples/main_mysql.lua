local skynet = require "skynet"


skynet.start(function()
	print("Main Server start")
	local console = skynet.newservice("tkx_mysql")
	
	print("Main Server exit")
	skynet.exit()
end)

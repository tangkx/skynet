local skynet = require "skynet"


skynet.start(function ()
	
	local gate = skynet.newservice("tkxgate")

	skynet.call(gate, "lua", "open", {
		 address = "127.0.0.1", -- 监听地址 127.0.0.1
   		 port = 9999,    -- 监听端口 8888
    		maxclient = 1024,   -- 最多允许 1024 个外部连接同时建立
    		nodelay = false,
		})

end)
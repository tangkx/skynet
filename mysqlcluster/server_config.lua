-- @Author: tkx
-- @Date:   2017-02-13 09:21:01
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-13 16:38:03

local config = {}

config.mysql_config = {

	mysqlconf = {
		host="127.0.0.1",
		port=3306,
		database="skynet",
		user="root",
		password="123",
		max_packet_size=1024*1024,
	}
}

config.redis_config = {

	redisconf = {
		host="127.0.0.1",
		port = 6379,
		db = 0
	}
}

config.log_config = {
	
	info = true,
	debug = true,
	error = true
}

return config

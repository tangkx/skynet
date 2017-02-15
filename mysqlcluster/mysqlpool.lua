-- @Author: tkx
-- @Date:   2017-02-10 11:13:59
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-13 16:53:48

package.path = "./service/?.lua;./examples/?.lua;./mysqlcluster/?.lua;./lualib/?.lua;./log/?.lua"

local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local lock = skynet_queue()
local mysql = require "mysql"
local queue = require "tqueue"
require "tprint"

--@import 雲峯
local _class={}
function class(super)
	local class_type = {}
	class_type.ctor = false
	class_type.super = super
	class_type.new = function(...) 
			local obj = {}
			do
				local create
				create = function(c,...)
					if c.super then
						create(c.super,...)
					end
					if c.ctor then
						c.ctor(obj,...)
					end
				end
 
				create(class_type,...)
			end
			setmetatable(obj,{ __index = _class[class_type] })
			return obj
		end
	local vtbl = {}
	_class[class_type] = vtbl
 
	setmetatable(class_type,{__newindex =
		function(t,k,v)
			vtbl[k] = v
		end
	})
 
	if super then
		setmetatable(vtbl,{__index=
			function(t,k)
				local ret =_class[super][k]
				vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end

local  dbpool = class()

--database pool conf

dbpool.conf = nil 		--连接配置
dbpool.pool = nil 		--连接池队列 
dbpool.totalNum = nil	--最大连接数 
dbpool.usedNum = 0		--已经使用的连接数
dbpool.threshold = nil	--使用警告阀值
dbpool.pingTime = nil	--激活连接周期
dbpool.lock = false	--连接池队列锁
dbpool.addNum = nil	--额外添加的连接数

local function pushDB(q, db, lo)

	if queue.isFull(q) then
		return 1
	else
		while lo do
			skynet.sleep(0.1 * 100)
		end
		lo = true
		queue.push(q, db)
		lo = false
		return 0
	end

end

local function popDB(q, lo)

	if queue.isEmpty(q) then 
		return 1
	else
		while lo do
			skynet.sleep(0.1 * 100)
		end
		lo = true
		local db = queue.pop(q)
		lo = false
		return db
	end
end

local function activeDB(q, time)

	while  true do 
		for k,v in pairs(q) do
			if type(v) == "table" then
				v:query("select 1")
			end
		end
		skynet.sleep(time * 100)
	end
	
end

function dbpool:active()

	local q = self.pool
	local time = self.pingTime
	skynet.fork(activeDB, q, time)
end

function dbpool:addDB(number)

	local old_total = self.totalNum
	self.totalNum = old_total + number
	queue.setMaxlen(self.pool, self.totalNum)
	local count = 0
	for i=1, number do
		local db = mysql.connect(self.mysqlconf)
		if not db then 
			print("mysql connect fail")
		else
			if lock(pushDB, self.pool, db, self.lock) == 1 then
				printE("addDB is fail")
			else
				--print("add db is success")
				count = count + 1
			end
		end
	end

	printI("add DB sucess is"..count)
end

function dbpool:init(dbconf)

	self.totalNum = dbconf.totalNum or 15
	self.conf = dbconf.mysqlconf or nil
	self.pool = queue.new(self.totalNum)
	self.threshold = dbconf.threshold or 0.7
	self.pingTime = dbconf.pingTime or 3600
	self.addNum =  dbconf.addNum or 5
	self.lock = false

	local count = 0

	for i = 0, self.totalNum do
		local db = mysql.connect(self.conf)
		if not db then
			print("mysql connection fail")
		else
			if lock(pushDB, self.pool, db, self.lock) == 1 then
				printE("push db to pool fail")
				break
			else
				--print("push db to pool success")
				count = count + 1
			end
		end
	end

	printI("push db to pool count"..count)
	self:active()
end

function dbpool:getDB()

	if queue.isEmpty(self.pool) then
		printE("pool is isEmpty")
		return nil
	end
	local db = lock(popDB, self.pool, self.lock)

	if db == 1 then
		printE("get db fail")
		return nil
	else
		printI("get db success")

		if self.usedNum >= (self.threshold * self.totalNum) then
			skynet.fork(addDB, self.addNum)
		end
		self.usedNum = self.usedNum + 1
		return db
	end

end

function dbpool:free(db)

	if lock(pushDB, self.pool, db, self.lock) == 1 then
		printE("free db fail")
	else
		self.usedNum = self.usedNum - 1
	end
end

return dbpool


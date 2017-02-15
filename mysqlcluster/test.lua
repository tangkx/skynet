-- @Author: tkx
-- @Date:   2017-02-10 14:06:51
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-10 14:16:31

local queue = require "tqueue"

local tq = queue.new(20)

for i=0, 30 do
	queue.push(tq, i)
end

print('queue length', queue.getLen(tq))
for i=0, queue.getLen(tq) do

	local value = queue.pop(tq)
	if value == -1 then 
		break
	else
		print(value)
	end
end

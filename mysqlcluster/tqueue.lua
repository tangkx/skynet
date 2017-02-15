-- @Author: tkx
-- @Date:   2017-02-10 13:43:46
-- @Last Modified by:   tkx
-- @Last Modified time: 2017-02-10 14:50:18


local queue = {}

function queue.new(maxlen)
	 
	 if maxlen  ~= nil and type(maxlen) == "number" and maxlen > 0 then
	 	return {head = 0, tail = -1, maxlen = maxlen}
	 else
	 	return {first = 0, last = -1}
	 end
end

function queue.isFull(q)

	if (q.tail - q.head +1) == q.maxlen then
		return true
	else
		return false
	end
end

function queue.isEmpty(q)

	if (q.tail - q.head) == -1 then
		return true
	else
		return false
	end
end

function queue.push(q, value)

	if queue.isFull(q) then
		return -1
	else
		local tail = q.tail + 1
		q.tail = tail 
		q[tail] = value
		return 0
	end
	
end

function queue.pop(q)

	if queue.isEmpty(q) then
		return -1
	else
		local value = q[q.head]
		q[q.head] = nil
		q.head = q.head + 1
		return value
	end
	
end

function queue.getLen(q)
	
	return q.tail - q.head + 1 
end

function queue.getMaxlen(q)

	if q.maxlen then
		return q.maxlen
	else
		return -1
	end
end

function queue.setMaxlen(q, len)

	q.maxlen = len
end

return queue
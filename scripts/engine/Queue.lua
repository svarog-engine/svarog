local Queue = {}

function Queue:New()
	o = { first = 0, last = -1 }
	setmetatable(o, self)
	self.__index = self
	return o
end

function Queue:PushLeft(value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

function Queue:PushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

function Queue:PopLeft()
	local first = self.first
	if first > self.last then error("queue is empty") end
	local value = self[first]
	self[first] = nil
	self.first = first + 1
	return value
end

function Queue:PopRight()
	local last = self.last
	if self.first > last then error("queue is empty") end
	local value = self[last]
	self[last] = nil
	self.last = last - 1
	return value
end

function Queue:IsEmpty()
	return self.first > self.last
end

return Queue
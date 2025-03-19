local CompositeDistanceMap = {}

function CompositeDistanceMap:From(maps)
	local o = { maps = maps }
	setmetatable(o, self)
	self.__index = self
	return o
end

function CompositeDistanceMap:Size()
	if #self.maps == 0 then return 0, 0 end
	return self.maps[1]:Size()
end

function CompositeDistanceMap:Has(x, y)
	local ok = false
	for _, map in ipairs(self.maps) do
		ok = ok or map:Has(x, y)
	end
	return ok
end

function CompositeDistanceMap:Get(x, y)
	local value = 0
	for _, map in ipairs(self.maps) do
		value = value + map:Get(x, y)
	end
	return value
end

return CompositeDistanceMap
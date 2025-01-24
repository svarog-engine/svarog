local Map = {}

function Map:New(w, h)
	o = { width = w, height = h, tiles = {}, keys = {} }
	setmetatable(o, self)
	self.__index = self
	return o
end

function Map:ID(x, y)
	return self.width * y + x
end

function Map:Set(x, y, value)
	local key = self:ID(x, y)
	if self.tiles[key] == nil then
		table.insert(self.keys, key)
	end
	self.tiles[key] = { x = x, y = y, value = value }
end

function Map:Unset(x, y)
	local key = self:ID(x, y)
	self.tiles[key] = nil
	local index = nil
	for k, v in pairs(self.keys) do
		if v == key then
			index = k
			break
		end
	end

	if index ~= nil then
		table.remove(self.keys, k)
	end
end

function Map:Get(x, y)
	return self.tiles[self:ID(x, y)]
end

function Map:Has(x, y)
	return self.tiles[self:ID(x, y)] ~= nil
end

function Map:Iterate()
	return ipairs(self.keys)
end

return Map
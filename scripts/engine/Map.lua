local Map = {}

function Map:New(w, h, defaultValue)
	o = { width = w, height = h, tiles = {}, keys = {} }
	for i = 1, w do
		o.tiles[i] = {}
		for j = 1, h do
			o.tiles[i][j] = defaultValue
		end
	end

	setmetatable(o, self)
	self.__index = self
	return o
end

function Map:ID(x, y)
	return self.width * y + x
end

function Map:XY(k)
	return k % self.width, math.floor(k / self.width)
end

function Map:Set(x, y, value)
	self.tiles[x][y] = value
end

function Map:Unset(x, y)
	self.tiles[x][y] = nil
end

function Map:Get(x, y)
	return self.tiles[x][y]
end

function Map:Has(x, y)
	if x == nil or y == nil then
		print(debug.traceback())
	end
	return self.tiles[x][y] ~= nil
end

function Map:Size()
	return self.width, self.height
end

function Map:Filter(predicate)
	if predicate == nil then return self:Iterate() end

	local filtered = {}
	for _, k in self:Iterate() do
		local tile = self.tiles[k]
		if predicate(tile) then
			table.insert(filtered, k)
		end
	end

	return ipairs(filtered)
end

return Map
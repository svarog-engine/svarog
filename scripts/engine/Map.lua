﻿local Map = {}

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

function Map:From(arr, width)
	local height = arr.Length / width
	o = { width = width, height = height, tiles = {}, keys = {} }
	for i = 1, width do
		o.tiles[i] = {}
		for j = 1, height do
			o.tiles[i][j] = arr[width * (j - 1) + (i - 1)]
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
	self.tiles[math.floor(x)][math.floor(y)] = value
end

function Map:Unset(x, y)
	self.tiles[math.floor(x)][math.floor(y)] = nil
end

function Map:Get(x, y)
	x = math.floor(x)
	y = math.floor(y)
	if self.tiles[x] == nil then 
		return nil
	end
	return self.tiles[x][y]
end

function Map:Has(x, y)
	x = math.floor(x)
	y = math.floor(y)
	if self.tiles[x] == nil then return false end
	return self.tiles[x][y] ~= nil
end

function Map:Neighbors(x, y)
	x = math.floor(x)
	y = math.floor(y)
	if self:Has(x, y) ~= nil then
		local results = {}
		if self:Has(x - 1, y) ~= nil then table.insert(results, { x = x - 1, y = y }) end
		if self:Has(x + 1, y) ~= nil then table.insert(results, { x = x + 1, y = y }) end
		if self:Has(x, y - 1) ~= nil then table.insert(results, { x = x, y = y - 1 }) end
		if self:Has(x, y + 1) ~= nil then table.insert(results, { x = x, y = y + 1 }) end
		return results
	end

	return {}
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

function Map:Reset(defaultValue)
	for i = 1, self.width do
		for j = 1, self.height do
			self:Set(i, j, defaultValue)
		end
	end
end

return Map
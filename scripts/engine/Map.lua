local Map = {}

function Map:New(w, h)
	o = { width = w, height = h, tiles = {}, keys = {}, entities = {} }
	setmetatable(o, self)
	self.__index = self
	return o
end

function Map:ID(x, y)
	return self.width * y + x
end

function Map:XY(k)
	return { k % self.width, math.floor(k / self.width + 0.5) }
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
	local id = self:ID(x, y)
	if self.tiles[id] == nil then
		debug.traceback()
		return nil
	else
		return self.tiles[id]
	end
end

function Map:GetNum(x, y)
	local got = self:Get(x, y)
	if got ~= nil then
		if type(got.value) == number then 
			return got.value
		else
			debug.traceback()
			return nil
		end
	end
end

function Map:MinAround(x, y)
	local min = 10000
	for i = -1, 1 do
		for j = -1, 1 do
			local id = self:ID(x + i, y + j)
			if self.tiles[id] ~= nil and type(self.tiles[id].value) == 'number' then
				if self.tiles[id].value < min then
					min = self.tiles[id].value
				end
			end
		end
	end

	return min
end

function Map:Has(x, y)
	local id = self:ID(x, y)
	return self.tiles[id] ~= nil and self.tiles[id].value ~= nil
end

function Map:Iterate()
	return ipairs(self.keys)
end

function Map:Filter(predicate)
	if predicate == nil then return self:Iterate() end

	local filtered = {}
	for _, k in self:Iterate() do
		local tile = self.tiles[k]
		if predicate(tile.value) then
			table.insert(filtered, k)
		end
	end

	return ipairs(filtered)
end

function Map:DijkstraByClass(query, predicate)
	local goals = {}
	for _, v in pairs(query) do
		for _, e in World:Exec(ECS.Query.All(Position, v[1])):Iterator() do
			table.insert(goals, { e[Position].x, e[Position].y, v[2] or 0 })
		end
	end

	return self:Dijkstra(goals, predicate)
end

function Map:Dijkstra(goals, predicate)
	if predicate == nil then predicate = function(t) return true end end

	local dijkstra = Map:New(self.width, self.height)
	local queue = Queue:New()

	local queued = {}

	for _, g in ipairs(goals) do
		queue:PushRight(g)
		dijkstra:Set(g[1], g[2], g[3] or 0)
		queued[self:ID(g[1], g[2])] = true
	end

	local done = {}
	
	while not queue:IsEmpty() do
		local val = queue:PopLeft()

		local x, y = val[1], val[2]
		done[self:ID(x, y)] = true

		if not dijkstra:Has(x, y) then
			local min = 12321
			for i = -1, 1 do
				for j = -1, 1 do
					if not (i == 0 and j == 0) then
						local cand = 12321
						local nid = self:ID(x + i, y + j)
						
						local t = dijkstra:Get(x + i, y + j)
						if t ~= nil then
							cand = t.value
						end
					
						if not (i == 0 or j == 0) then
							cand = cand + 0.707
						end

						if cand < min then min = cand end
					end
				end
			end
			
			dijkstra:Set(x, y, min + 1)
		end

		for i = -1, 1 do
			if not (i == 0) then
				local id = self:ID(x + i, y)
				if self:Has(x + i, y) and not done[id] and not queued[id] then
					if predicate(self:Get(x + i, y)) then
						queue:PushRight({ x + i, y })
						queued[id] = true
					end
				end

				id = self:ID(x, y + i)
				if self:Has(x, y + i) and not done[id] and not queued[id] then
					if predicate(self:Get(x, y + i)) then
						queue:PushRight({ x, y + i })
						queued[id] = true
					end
				end
			end
		end
	end
	return dijkstra
end

function PassableInDungeon(t) 
	if Dungeon.passable ~= nil and t ~= nil then
		local tile = Dungeon.passable:Get(t.x, t.y)
		if tile ~= nil then
			return tile.value
		end 
	end
		
	return false
end

return Map
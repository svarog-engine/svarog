local Map = {}
local DijkstraMax = 12321

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
	return k % self.width, math.floor(k / self.width + 0.5)
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

function Map:DijkstraByClass(target, query, predicate, limit)
	local goals = {}
	if limit == nil then limit = 10 end

	for _, v in pairs(query) do
		for _, e in World:Exec(ECS.Query.All(Position, v[1])):Iterator() do
			table.insert(goals, { e[Position].x, e[Position].y, v[2] or 0 })
		end
	end

	return self:Dijkstra(target, goals, predicate, limit)
end

function Map:Dijkstra(target, goals, predicate, limit)
	if predicate == nil then predicate = function(t) return true end end
	if limit == nil then limit = 40 end

	local queue = Queue:New()

	local queued = {}

	for _, g in ipairs(goals) do
		local id = self:ID(g[1], g[2])
		queue:PushRight(id)
		self:Set(g[1], g[2], g[3] or 0)
		queued[id] = true
	end

	local done = {}
	local neighborhood = { -1, 1 }

	while not queue:IsEmpty() do
		local rid = queue:PopLeft()
		local x, y = self:XY(rid)
		
		if not (done[rid] or false) then
			done[rid] = true
			local min = DijkstraMax
			for i = -1, 1 do
				for j = -1, 1 do
					if target:Has(x + i, y + j) then
						local cand = DijkstraMax
						local nid = self:ID(x + i, y + j)
						local t = self:Get(x + i, y + j)
					
						if t ~= nil then
							cand = t
						end

						if cand < min then min = cand end
					end
				end
			end
			
			self:Set(x, y, min + 1)
		end

		local val = self:Get(x, y) or 0

		if val < limit then
			for _, n in ipairs(neighborhood) do
				local id = self:ID(x + n, y)
				if target:Has(x + n, y) and not done[id] and not queued[id] then
					if predicate(x + n, y, target:Get(x + n, y)) then
						queue:PushRight(id)
						queued[id] = true
					end
				end

				id = self:ID(x, y + n)
				if target:Has(x, y + n) and not done[id] and not queued[id] then
					if predicate(x, y + n, target:Get(x, y + n)) then
						queue:PushRight(id)
						queued[id] = true
					end
				end
			end
		end
	end

	return self
end

function PassableInDungeon(x, y, t) 
	if Dungeon.floor ~= nil and t ~= nil then
		local tile = Dungeon.floor:Get(x, y)
		if tile ~= nil then
			return tile.type == Floor or tile.type == Door and not tile.entity[Door].closed
		end 
	end
		
	return false
end

return Map
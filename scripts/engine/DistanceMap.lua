local DistanceMap = {}

local MAX = 10001

function DistanceMap.IS_FLOOR(map, x, y)
	return map.origin:Get(x, y).type == Floor
end

function DistanceMap.ISNT_FLOOR(map, x, y)
	local got = map.origin:Get(x, y)
	if got == nil then 
		return true
	else
		return got.type ~= Floor
	end
end

function DistanceMap.IS_OPEN_DOOR(map, x, y)
	local tile = map.origin:Get(x, y)
	return tile.type == Door and not tile.entity[Door].closed
end

function DistanceMap:From(map, goals, low)
	local o = {}
	if low == nil then low = 0 end

	local w, h = map:Size()
	o.origin = map
	o.tiles = Map:New(w, h, nil)
	o.goals = goals
	o.low = low
	o.conditions = {}
	o.neighbors = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

	setmetatable(o, self)
	self.__index = self
	return o
end

function DistanceMap:AddCondition(fn)
	table.insert(self.conditions, fn)
end

function DistanceMap:ID(x, y)
	return self.tiles:ID(x, y)
end

function DistanceMap:XY(k)
	return self.tiles:XY(k)
end

function DistanceMap:Filter(predicate)
	return self.tiles:Filter(predicate)
end

function DistanceMap:Neighbors(x, y)
	return self.tiles:Neighbors(x, y)
end

function DistanceMap:CheckToAdd(x, y)
	if DebugToggle_PrintDistances then
		print("  Checking whether to add position " .. x .. ", " .. y)
	end
	if not self.origin:Has(x, y) then 
		if DebugToggle_PrintDistances then
			print("   Origin doesn't have " .. x .. ", " .. y)
		end
		return false 
	end
	if self.tiles:Get(x, y) < MAX then 
		if DebugToggle_PrintDistances then
			print("   Tile " .. x .. ", " .. y .. " is already evaluated at " .. self.tiles:Get(x, y))
		end
		return false 
	end

	local atLeastOneCondMet = false
	for i, cond in ipairs(self.conditions) do
		local condMet = cond(self, x, y)
		if DebugToggle_PrintDistances then
			if condMet then 
				print("   Tile " .. x .. ", " .. y .. " satisfies condition #" .. i .. ": True")
			else
				print("   Tile " .. x .. ", " .. y .. " satisfies condition #" .. i .. ": False")
			end
		end
		atLeastOneCondMet = atLeastOneCondMet or condMet
	end

	if DebugToggle_PrintDistances then
		print("  Tile " .. x .. ", " .. y .. " satisfies at least one condition: ", atLeastOneCondMet)
	end
	return atLeastOneCondMet
end

function DistanceMap:Size()
	return self.tiles:Size()
end

function DistanceMap:Has(x, y)
	return self.tiles:Has(x, y)
end

function DistanceMap:Get(x, y)
	return self.tiles:Get(x, y)
end

function DistanceMap:Flood()
	local toVisit = Queue:New()
	local visited = {}

	local w, h = self.tiles:Size()
	for i = 1, w do
		for j = 1, h do
			if self.origin:Has(i, j) then
				self.tiles:Set(i, j, MAX)
			end
		end
	end

	for _, xy in ipairs(self.goals) do
		toVisit:PushRight(self.origin:ID(xy[1], xy[2]))
		self.tiles:Set(xy[1], xy[2], self.low)
		if DebugToggle_PrintDistances then
			xy[1] = math.floor(xy[1])
			xy[2] = math.floor(xy[2])
			print("Setting goal to 0 at " .. xy[1] .. ", " .. xy[2])
		end
	end	

	while not toVisit:IsEmpty() do
		local next = toVisit:PopLeft()
		if not visited[next] then
			visited[next] = true
			local x, y = self.origin:XY(next)
			x = math.floor(x)
			y = math.floor(y)
			if DebugToggle_PrintDistances then
				print(" === VALUE ASSIGN ===")
				print("Unqueued: " .. x .. ", " .. y)
			end
			if self.tiles:Has(x, y) and self.tiles:Get(x, y) == MAX then
				local min = MAX
				for _, n in ipairs(self.neighbors) do
					local neighbor = self.tiles:Get(x + n[1], y + n[2]) or MAX
					min = math.min(min, neighbor)
				end
				self.tiles:Set(x, y, min + 1)

				if DebugToggle_PrintDistances then
					print("  Setting new value at " .. x .. ", " .. y .. " to " .. (min + 1))
				end
			end

			if DebugToggle_PrintDistances then
				print(" === NEIGHBOR CHECK ===")
			end

			for _, n in ipairs(self.neighbors) do
				if self:CheckToAdd(x + n[1], y + n[2]) then
					if DebugToggle_PrintDistances then
						print("  Position " .. (x + n[1]) .. ", " .. (y + n[2]) .. " is unset, adding to queue")
					end
					toVisit:PushRight(self.origin:ID(x + n[1], y + n[2]))
				end
			end
		end
	end
end

return DistanceMap
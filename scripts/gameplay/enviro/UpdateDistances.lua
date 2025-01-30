
local UpdateDistancesSystem = Engine.RegisterEnviroSystem()

function UpdateDistancesSystem:Initialize()
	self.co = function()
		self.last = coroutine.create(function() 
			if Dungeon.created then
				Dungeon.playerDistance = Dungeon.floor:DijkstraByClass({ { Player, 0 } }, PassableInDungeon, 20)
			end
		end)
		coroutine.resume(self.last)
	end

	self.last = nil
	self.co()
end

function UpdateDistancesSystem:Update()
	if self.last == nil or coroutine.status(self.last) == 'dead' then
		self.last = nil
		self.co()
	end
end
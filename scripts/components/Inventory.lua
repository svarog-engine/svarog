
Inventory = ECS.Component{items = {}}

function Inventory.Add(entity, item)
	local inventory = entity[Inventory]
	table.insert(inventory.items, item)
end

function Inventory.Remove(entity, item)
	local inventoryList = entity[Inventory].items
	table.remove(inventoryList, table.find(inventoryList, item))
end

function Inventory.HasItem(entity, item)
	local inventoryList = entity[Inventory].items
	if inventoryList ~= nil then
		for _, value in ipairs(inventoryList) do 
			if value == item then
				return true
			end
		end
	end

	return false
end

InventoryWidget = ECS.Component{top = 1, left = 39, width = 20, height = 20, selected = 1, source = {}}
ItemDetailsPanelWidget = ECS.Component {top = 0, left = 20, width = 15, height = 20}
TargetOverlay = ECS.Component {x = 0, y = 0, targetColor = Colors.Red, trailColor = Colors.Yellow}

function InventoryWidget.GetSelected()
	local widget = UI[InventoryWidget]
	if widget.selected <= #(widget.source.items) then
		for i, s in ipairs(widget.source.items) do
			if i == widget.selected then
				return s
			end
		end
	end

	return nil
end

UI = World:Entity(
	InventoryWidget{ top = 1, left = 39, width = 20, height = 10, source = {}, selected = 1},
	ItemDetailsPanelWidget{top = 1, left = 20, width = 15, height = 1},
	TargetOverlay {startX = 0, starty = 0, endX = 0, endY = 0, targetColor = Colors.Red, trailColor = Colors.Yellow}
)
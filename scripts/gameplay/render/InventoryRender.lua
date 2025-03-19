
InventoryRender = Engine.RegisterUIRenderSystem("Inventory Render")

local canConsume = CanConsume
local canCast = CanCast

function InventoryRender.Render(ui)
	local fg = Colors.Gray
	if InventoryEntity[Open] then fg = Colors.White end
	ui.PushStyle(fg, Colors.Black)
		ui.ClearBox(46, 25, 20, 10)
		ui.PushBox(46, 25, 20, 10)
			ui.PushOrder("|")
				ui.Label("= INVENTORY =")
				ui.Space(1)
				ui.List(PlayerEntity[Contents].items, InventoryEntity[Selection].value, function(v) 
					ui.Label(ItemLibrary[v.itemId].name .. " (" .. tostring(v.quantity) .. ")")
				end )
			ui.PopOrder()
		ui.PopBox()

		ui.ClearBox(45, 34, 20, 5)
		ui.PushBox(45, 34, 20, 5)
			ui.PushOrder("|")
				ui.Label(" ------------- ")
				if not InventoryEntity[Open] then
					ui.Label(" [I] Inventory")
				else
					local selection = InventoryEntity[Selection].value
					for i, item in ipairs(PlayerEntity[Contents].items) do
						if i == selection then
							local know = PlayerKnowledge[item.itemId]
							if (CanConsume(item.itemId) or CanCast(item.itemId)) then
								if know ~= nil then
									local color = CompColors[know]
									ui.PushStyle(color.fg, color.bg)
										ui.Label(" " .. know)
									ui.PopStyle()
								else
									ui.Label(" ???")
								end
								ui.Label(" ------------- ")
							end
							ui.Label(" [D] Drop")
							if CanConsume(item.itemId) then
								ui.Label(" [C] Consume")
							elseif CanCast(item.itemId) then
								ui.Label(" [C] Cast")
							end
						end
					end
				
					ui.Label(" [ESC] Back")
				end
			ui.PopOrder()
		ui.PopBox()
	ui.PopStyle()
end


local ScanScreenRenderSystem = Engine.RegisterUIRenderSystem("Scan Screen Render");

local boxes = {}

function ScanScreenRenderSystem:ShouldRender(ui)
	return ScanningMode
end

function ScanScreenRenderSystem.Render(ui)
	local w, h = Dungeon.floor:Size()

	for _, box in pairs(boxes) do
		ui.ClearBox(box[1], box[2], box[3], box[4])
	end

	boxes = {}

	for _, e in World:Exec(ECS.Query.All(Creature, Position, Name)):Iterator() do
		local x, y = e[Position].x, e[Position].y
		local name = "- " .. e[Name].value
		local third_eye = "third_eye_closed"
		if PlayerEntity[Open] ~= nil then
			third_eye = "third_eye_opened"
			local c = e[Health].current
			local m = e[Health].maximum
			local d = (e[BumpAttack] or {}).damage or 0
			name = name .. " (HP: " .. c .. "/" .. m .. ", DMG: " .. d .. ")"
		end

		if Dungeon.floor:Has(x, y) and Dungeon.visibility:Get(x, y) then
			local tab = { x + 1, y, #name, 1 }
			table.insert(boxes, tab)
			ui.PushBox(table.unpack(tab))
				ui.PushStyle(Colors.White, Colors.DarkRed)
				ui.Label(name)
				ui.PopStyle()
			ui.PopBox()
			
			Engine.Glyph(x + 2, y, third_eye, {}, "UI")
		end
	end

	for _, e in World:Exec(ECS.Query.All(Portal, Timeout, Name)):Iterator() do
		local x, y = e[Position].x, e[Position].y
		local name = "- " .. e[Name].value .. " (" .. e[Timeout].value .. " turns)"
		if Dungeon.floor:Has(x, y) and Dungeon.visibility:Get(x, y) then
			local tab = { x + 1, y, #name, 1 }
			table.insert(boxes, tab)
			ui.PushBox(table.unpack(tab))
				ui.PushStyle(Colors.White, Colors.DarkMagenta)
				ui.Label(name)
				ui.PopStyle()
			ui.PopBox()
		end
	end

	local altarCount = 0
	for _, e in World:Exec(ECS.Query.All(Altar, Name)):Iterator() do
		local x, y = e[Position].x, e[Position].y
		
		local dy = -1
		if altarCount == 1 then 
			dy = 1 
		end

		local name = " " .. e[Name].value
		if Dungeon.floor:Has(x, y) and Dungeon.visibility:Get(x, y) then
			local tab = { x, y + dy, #name, 1 }
			table.insert(boxes, tab)
			ui.PushBox(table.unpack(tab))
				ui.PushStyle(Colors.White, Colors.DarkGreen)
				ui.Label(name)
				ui.PopStyle()
				if dy == -1 then
					Engine.Glyph(x, y + dy, "down_arrow", {}, "UI")
				else
					Engine.Glyph(x, y + dy, "up_arrow", {}, "UI")
				end
			ui.PopBox()
		end
		altarCount = altarCount + 1
	end
end

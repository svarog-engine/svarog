local PossibleMoveRenderSystem = Engine.RegisterRenderSystem("Possible Move Render")

function PossibleMoveRenderSystem:ShouldRender()
	return Dungeon ~= nil and PlayerEntity ~= nil and PlayerEntity[Position] ~= nil and PlayerEntity[MoveMode] ~= nil
end

local normalNeighbors = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

function PossibleMoveRenderSystem:Render()
	local px, py, mode = PlayerEntity[Position].x, PlayerEntity[Position].y, PlayerEntity[MoveMode].value
	
	if mode == "Walk" then
		for _, n in ipairs(normalNeighbors) do
			local x, y = px + n[1], py + n[2]
			if Dungeon.floor:Has(x, y) then
				local tile = Dungeon.floor:Get(x, y)
				if tile.type == Floor then
					Engine.Glyph(x, y, "target")
				end
			end
		end
	elseif mode == "Jump" then
		for _, n in ipairs(normalNeighbors) do
			local x, y = px + n[1], py + n[2]
			local x2, y2 = px + 2 * n[1], py + 2 * n[2]

			if PlayerEntity[Flow] ~= nil then
				if Dungeon.floor:Has(x2, y2) then
					local tile = Dungeon.passable:Get(x, y)
					local tile2 = Dungeon.passable:Get(x2, y2)
					if not tile and tile2 then
						Engine.Glyph(x2, y2, "target4")
					elseif tile and tile2 then
						Engine.Glyph(x2, y2, "target2")
					elseif tile and not tile2 then
						Engine.Glyph(x, y, "target3")
					end
				end
			else
				if Dungeon.floor:Has(x, y) and Dungeon.floor:Has(x2, y2) then
					local xyid = Dungeon.floor:ID(x, y)
					local entts = Dungeon.entities[xyid]
					local count = 0
					if entts ~= nil then 
						count = #entts
					end
					local tile = Dungeon.passable:Get(x, y) and count == 0
					local tile2 = Dungeon.passable:Get(x2, y2)
					if tile and tile2 then
						Engine.Glyph(x2, y2, "target2")
					elseif tile and not tile2 then
						Engine.Glyph(x, y, "target3")
					end
				end
			end
		end
	end
end
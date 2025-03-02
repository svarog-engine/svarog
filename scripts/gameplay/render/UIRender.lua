local UIRenderSystem = Engine.RegisterRenderSystem("UI Render")

local UISettings = {
	x = 0, 
	y = 0,
	width = Config.Width,
	height = Config.Height,
	boxes = Stack(),
	orders = Stack(),
}

local FID = function(dx, dy) end
local FH = function(dx, dy) UISettings.x = UISettings.x + dx end
local FV = function(dx, dy) UISettings.y = UISettings.y + dy end

UIRenderer = {
	Line = function(x1, y1, x2, y2, color, isVisibleFn)
		if color == nil then color = Colors.White end
		PlotLine(x1, y1, x2, y2, color, isVisibleFn)
	end,

	Rect = function(x1, y1, x2, y2, color, isVisibleFn)
		UIRenderer.Line(x1, y1, x2, y1, color, isVisibleFn)
		UIRenderer.Line(x1, y1, x1, y2, color, isVisibleFn)
		UIRenderer.Line(x2, y1, x2, y2, color, isVisibleFn)
		UIRenderer.Line(x1, y2, x2, y2, color, isVisibleFn)
	end,

	Label = function(text, config)
		if config == nil then config = {} end
		Engine.Write(UISettings.x, UISettings.y, text, 
			config["fg"] or Colors.White,
			config["bg"] or Colors.Black,
			"UI")
		
		local order = UISettings.orders:top()
		if order ~= nil then
			order(#text, 1)
		end
	end,

	Space = function(size)
		local order = UISettings.orders:top()
		if order ~= nil then
			order(size, size)
		end
	end,

	PushBox = function(x, y, width, height)
		local ox = UISettings.x
		local oy = UISettings.y
		local ow = UISettings.width
		local oh = UISettings.height
		UISettings.boxes:push({ ox, oy, ow, oh })

		UISettings.x = x
		UISettings.y = y
		UISettings.width = width
		UISettings.height = height
	end,

	PopBox = function()
		local ox, oy, ow, oh = table.unpack(UISettings.boxes:pop())
		UISettings.x = ox
		UISettings.y = oy
		UISettings.width = ow
		UISettings.height = oh
	end,

	PushOrder = function(order)
		if order == "-" then
			UISettings.orders:push(FH)
		elseif order == "|" then
			UISettings.orders:push(FV)
		end
	end,

	PopOrder = function()
		UISettings.orders:pop()
	end,
}

function UIRenderSystem:Render()
	for _, entity in World:Exec(ECS.Query.All(UI)):Iterator() do
		entity[UI].work(UIRenderer)
	end
end
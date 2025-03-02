local FID = function(dx, dy) end

local UISettings = {
	x = 1, 
	y = 1,
	width = Config.Width,
	height = Config.Height,
	order = FID,
	fg = Colors.White,
	bg = Colors.Black,
	boxes = Stack(),
	orders = Stack(),
	styles = Stack(),
}

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

	Label = function(text)
		if not (type(text) == 'string') then text = tostring(text) end
		local dx, dy = 0, 0 
		local order = UISettings.order or FID
		for index = 1, #text do
			local str = string.sub(text, index, index)
			Engine.Write(
				UISettings.x + dx, UISettings.y + dy, str, 
				UISettings.fg or Colors.White,
				UISettings.bg or Colors.Black,
				"UI")

			dx = dx + 1
			if dx > UISettings.width then
				dx = 0
				dy = dy + 1
			end
		end
		dy = dy + 1

		if order ~= nil then order(dx, dy) end
	end,

	Space = function(size)
		local order = UISettings.order or FID
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

	PushRel = function(dx, dy)
		PushBox(UISettings.x + dx, UISettings.y + dy, UISettings.width, UISettings.height)
	end,

	PopBox = function()
		local ox, oy, ow, oh = table.unpack(UISettings.boxes:pop())
		UISettings.x = ox
		UISettings.y = oy
		UISettings.width = ow
		UISettings.height = oh
	end,

	PushOrder = function(order)
		UISettings.orders:push(UISettings.order)
		if order == "-" then
			UISettings.order = FH
		elseif order == "|" then
			UISettings.order = FV
		else
			UISettings.order = FID
		end
	end,

	PopOrder = function()
		UISettings.order = UISettings.orders:pop()
	end,

	PushStyle = function(fg, bg)
		UISettings.styles:push({ UISettings.fg, UISettings.bg })
		UISettings.fg = fg
		UISettings.bg = bg
	end,

	PopStyle = function()
		local f, b = table.unpack(UISettings.styles:pop())
		UISettings.fg = f
		UISettings.bg = b
	end,

	List = function(elements, selected, innerFn)
		if innerFn == nil then innerFn = UIRenderer.Label end
		local order = UISettings.order or FID
		local fg = UISettings.fg or Colors.White
		local bg = UISettings.bg or Colors.Black
		
		for i, v in ipairs(elements) do
			if i == selected then
				UIRenderer.PushStyle(bg, fg)
				innerFn(v)
				UIRenderer.PopStyle()
			else
				UIRenderer.PushStyle(fg, bg)
				innerFn(v)
				UIRenderer.PopStyle()
			end
		end
	end,

	Bar = function(title, value, max, config)
		if config == nil then config = {} end
		local width = config.width or UISettings.width - 2
		local start = config.start or "["
		local stop = config.stop or "]"
		local full = config.full or "="
		local empty = config.empty or " "
		
		local s = ""
		s = s .. start
		local fullCells = math.ceil(value / max * width)
		for i = 0, fullCells do s = s .. full end
		for i = 1, width - fullCells do s = s .. empty end
		s = s .. stop
		UIRenderer.Label(title)
		UIRenderer.Label(s)
		UIRenderer.Space(1)
	end,
}

function RenderUI(entity)
	entity[UI].value()(UIRenderer)
end
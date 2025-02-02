World = ECS.World()

Measurements = false

PlayerDone = true
Actions = {}

Pipeline_Startup = {}
Pipeline_Player = {}
Pipeline_Enviro = {}
Pipeline_Render = {}

local RenderChangelist = { Game = {}, UI = {}}

local UpdateCount = 0
local FrameCount = 0

local function ProcessLayer(changelist, matrix, pres)
    local glos = Glossary[pres]
    local type = Glossary.Meta[pres].Type
	for i, c in ipairs(changelist) do        
        if matrix[c.X] ~= nil and matrix[c.X][c.Y] ~= nil then
            local item = matrix[c.X][c.Y]
            if c.Tile ~= nil then 
                local tile = glos[c.Tile]
                if tile ~= nil then
                    if type == EPresentationMode.Sprite then
                        item.TileX = tile.x
                        item.TileY = tile.y
                    else 
                        item.Presentation = tile.char
                    end
                    item.Foreground = tile.fg
                    item.Background = tile.bg
                end
            end

		    if c.Presentation ~= nil then item.Presentation = c.Presentation end
		    if c.Foreground ~= nil then item.Foreground = c.Foreground end
		    if c.Background ~= nil then item.Background = c.Background end
        end
	end
end

local function RenderPass()
    local pres = Config.Presentation or "Default"
    ProcessLayer(RenderChangelist["Game"], Glyphs, pres)
    ProcessLayer(RenderChangelist["UI"], UIGlyphs, pres)

    RenderChangelist["Game"] = {}
    RenderChangelist["UI"] = {}
end

local function Draw(change, layer)
    table.insert(RenderChangelist[layer], change)
end

local function Glyph(x, y, name, overrides, layer)
    local renderlayer = layer or "Game"

    message = {}
    message.X = x
    message.Y = y
    message.Tile = name

    if overrides ~= nil then
        if overrides.fg ~= nil then message.Foreground = overrides.fg end
        if overrides.bg ~= nil then message.Background = overrides.bg end
    end
    
    Engine.Draw(message, renderlayer)
end 

local function Symbol(x, y, glyph, fg, bg, layer)
    local def = Config.Presentation or "Default"
    local renderlayer = layer or "Game"

    if Glossary.Meta[def].Type == EPresentationMode.Sprite then
        local glyphValue = glyph
        if glyph == " " then  glyphValue = "empty" end

        local overrides = {}
        if fg ~= nil then overrides.fg = fg end
        if bg ~= nil then overrides.bg = bg end
        Glyph(x, y, glyphValue, overrides, renderlayer)
    else
        Engine.Draw({ X = x, Y = y, Presentation = glyph or ".", Foreground = fg or Colors.Yellow, Background = bg or Colors.Red}, renderlayer)
    end
end 

local function Write(x, y, text, fg, bg, layer)
    local renderlayer = layer or "Game"
    for i = 0, #text - 1 do
        Engine.Symbol(x + i, y, string.sub(text, i + 1, i + 1), fg, bg, renderlayer)
    end 
end

local function Line(row, char, fg, bg, layer)
    local renderlayer = layer or "Game"

	for i = 0, Config.Width - 1 do
		Glyph(i, row, char, { Foreground = fg or Colors.White, Background = bg or Colors.Black}, renderlayer)
	end
end

local function UpdateWorld(time)
    if World then
        World:Update(PlayerSystem(), time)

        if PlayerDone then
            UpdateCount = UpdateCount + 1
            PlayerDone = false
            World:Update(WorldSystem(), time)
        end

        if not Options.Headless and Svarog:ShouldRedraw() then
            World:Update(RenderSystem(), time)
            RenderPass()
            Svarog:ResetRedraw()
        end
    end
end

local function NextFrame()
    Input.Update()
    FrameCount = FrameCount + 1
    UpdateWorld(FrameCount)
end

local function Setup()
    InputEntity = World:Entity()

    for _, v in ipairs(Pipeline_Player) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Enviro) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Render) do World:AddSystem(v) end

    for _, v in ipairs(Pipeline_Startup) do
        v() 
    end
end

local function Reload()
    World:Destroy()
    World = nil

    World = ECS.World()

    PlayerDone = true

    Pipeline_Startup = {}
    Pipeline_Player = {}
    Pipeline_Enviro = {}
    Pipeline_Render = {}

    FrameCount = 0
    Input.Clear()
    
    Svarog.Instance:ReloadConfig()
    Svarog.Instance:ReloadGlossary()
    Svarog.Instance:ReloadLayers()
    Svarog.Instance:ReloadPresenter()

    InputStack:ReloadActions()
    dofile "scripts\\Library.lua"
    Svarog.Instance:RunScriptMain()
    Setup()
end

function StartMeasure()
    if Measurements then
        start_time = os.clock()
    end
end

function EndMeasure(name)
    if Measurements then
	    end_time = os.clock()
        elapsed_time = end_time - start_time
        print(name .. ': ' .. elapsed_time .. 's')
    end
end

function TableLenght(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function PlayerSystem() return "process" end
function WorldSystem() return "transform" end
function RenderSystem() return "render" end

function RegisterPlayerSystem()
    local system = ECS.System(Engine.PlayerSystem())
    system.Order = #Pipeline_Player
    table.insert(Pipeline_Player, system)
    return system
end

function RegisterEnviroSystem()
    local system = ECS.System(Engine.WorldSystem())
    system.Order = #Pipeline_Enviro
    table.insert(Pipeline_Enviro, system)
    return system
end

function RegisterRenderSystem(q)
    if q == nil then q = function(id) return id end end
    local system = ECS.System(Engine.RenderSystem(), q(ECS.Query.All(Redraw)), function(self)
        if next(self:Result():ToArray()) ~= nil then
            self:Render()
        end
    end)
    system.Order = #Pipeline_Render
    table.insert(Pipeline_Render, system)
    return system
end

function RegisterInputSystem(inputs, fn)
    local system = ECS.System(Engine.PlayerSystem(), ECS.Query.Any(table.unpack(inputs)), function(self) 
        for _, e in self:Result(self.queryAction):Iterator() do
		    fn(e)
            for _, i in ipairs(inputs) do
                Input.Consume(i)
            end
	    end
    end)

    table.insert(Pipeline_Player, system)
end

function OnStartup(fun) 
    table.insert(Pipeline_Startup, fun)
end

function IncludeGameplay(name)
    dofile("scripts\\gameplay\\" .. name .. ".lua")
end

function LoadPlayerSystem(name)
    dofile("scripts\\gameplay\\player\\" .. name .. ".lua")
end

function LoadEnviroSystem(name)
    dofile("scripts\\gameplay\\enviro\\" .. name .. ".lua")
end

function LoadRenderSystem(name)
    dofile("scripts\\gameplay\\render\\" .. name .. ".lua")
end

function Hex(rgb)
    return Colors:Hex(rgb)
end

return {
    Draw = Draw,
    Glyph = Glyph,
    Symbol = Symbol,
    Write = Write,
    Line = Line,
    Setup = Setup,
    Reload = Reload,
    Frame = function() return FrameCount end,
    Tick = function() return UpdateCount end,
    Update = NextFrame,
    PlayerSystem = PlayerSystem,
    WorldSystem = WorldSystem,
    RenderSystem = RenderSystem,
    TaskSystem = TaskSystem,
    OnStartup = OnStartup,
    RegisterPlayerSystem = RegisterPlayerSystem,
    RegisterInputSystem = RegisterInputSystem,
    RegisterEnviroSystem = RegisterEnviroSystem,
    RegisterEnviroTaskSystem = RegisterEnviroTaskSystem,
    RegisterRenderSystem = RegisterRenderSystem,
}
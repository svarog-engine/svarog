﻿World = ECS.World()

PlayerDone = true
Actions = {}

Pipeline_Startup = {}
Pipeline_Player = {}
Pipeline_Enviro = {}
Pipeline_Render = {}

RenderChangelist = {}

local FrameCount = 0

local function RenderPass()
    local pres = Config.Presentation or "Default"
    
	for i, c in ipairs(RenderChangelist) do
        if Glyphs[c.X] ~= nil and Glyphs[c.X][c.Y] ~= nil then
            if c.Tile ~= nil then 
                local tile = Glossary[pres][c.Tile]
                if tile ~= nil then
                    if Glossary.Meta[pres].Type == EPresentationMode.Sprite then
                        Glyphs[c.X][c.Y].TileX = tile.x
                        Glyphs[c.X][c.Y].TileY = tile.y
                    else 
                        Glyphs[c.X][c.Y].Presentation = tile.char
                    end
                    Glyphs[c.X][c.Y].Foreground = tile.fg
                    Glyphs[c.X][c.Y].Background = tile.bg
                end
            end

		    if c.Presentation ~= nil then Glyphs[c.X][c.Y].Presentation = c.Presentation end
		    if c.Foreground ~= nil then Glyphs[c.X][c.Y].Foreground = c.Foreground end
		    if c.Background ~= nil then Glyphs[c.X][c.Y].Background = c.Background end
        end
	end
	RenderChangelist = {}
end

local function Draw(change)
    table.insert(RenderChangelist, change)
end

local function Glyph(x, y, name, overrides)
    message = {}
    message.X = x
    message.Y = y
    message.Tile = name
    
    if overrides ~= nil then
        if overrides.fg ~= nil then message.Foreground = overrides.fg end
        if overrides.bg ~= nil then message.Background = overrides.bg end
    end
    
    Engine.Draw(message)
end 

local function Symbol(x, y, glyph, fg, bg)
    local def = Config.Presentation or "Default"
    if Glossary.Meta[def].Type == EPresentationMode.Sprite then
        if Glossary[def][glyph] == nil then glyph = " " end
        local overrides = {}
        if fg ~= nil then overrides.fg = fg end
        if bg ~= nil then overrides.bg = bg end
        Glyph(x, y, glyph, overrides)
    else
        Engine.Draw({ X = x, Y = y, Presentation = glyph or ".", Foreground = fg or Colors.Yellow, Background = bg or Colors.Red })
    end
end 

local function Write(x, y, text, fg, bg)
    for i = 0, #text - 1 do
        Engine.Symbol(x + i, y, string.sub(text, i + 1, i + 1), fg, bg)
    end 
end

local function Line(row, char, fg, bg)
	for i = 0, Config.Width - 1 do
		Engine.Symbol(i, row, " ", fg or Colors.White, bg or Colors.Black)
	end
end

local function UpdateWorld(time)
    if World then
        World:Update(PlayerSystem(), time)
        
        if PlayerDone then
            World:Update(WorldSystem(), time)
            PlayerDone = false
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
    Svarog.Instance:ReloadGlyphs()
    Svarog.Instance:ReloadPresenter()

    InputStack:ReloadActions()
    dofile "scripts\\gameplay\\Library.lua"
    Svarog.Instance:RunScriptMain()
    Setup()
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
    Update = NextFrame,
    PlayerSystem = PlayerSystem,
    WorldSystem = WorldSystem,
    RenderSystem = RenderSystem,
    OnStartup = OnStartup,
    RegisterPlayerSystem = RegisterPlayerSystem,
    RegisterInputSystem = RegisterInputSystem,
    RegisterEnviroSystem = RegisterEnviroSystem,
    RegisterRenderSystem = RegisterRenderSystem,
}
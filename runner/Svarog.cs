using CommandLine;

using NLua;
using NLua.Exceptions;

using Serilog;
using Serilog.Core;
using SFML.System;
using svarog.input;
using svarog.presentation;
using svarog.utility;

namespace svarog.runner
{
    public class Svarog
    {
        #region Singleton

        private static readonly Svarog ms_Instance = new Svarog();
        static Svarog() { }

        public static Svarog Instance => ms_Instance;

        #endregion Singleton

        #region Logging

        private Logger? m_Logger = null;

        public void LogVerbose(string message) => m_Logger?.Verbose(message);
        public void LogDebug(string message) => m_Logger?.Debug(message);
        public void LogInfo(string message) => m_Logger?.Information(message);
        public void LogWarning(string message) => m_Logger?.Warning(message);
        public void LogError(string message) => m_Logger?.Error(message);
        public void LogFatal(string message) => m_Logger?.Fatal(message);

        private void SetupLogging(CommandLineOptions options)
        {
            if (options.Logging)
            {
                m_Logger = new LoggerConfiguration()
                    .MinimumLevel.Information()
                    .WriteTo.Console()
                    .WriteTo.Debug()
                    .WriteTo.File("log.txt", Serilog.Events.LogEventLevel.Debug)
                    .CreateLogger();
            }
        }

        #endregion Logging

        #region Display

        private void SetupDisplayMode(CommandLineOptions options)
        {
            if (options.Headless && !options.InputPort.HasValue)
            {
                Svarog.Instance.LogError("Cannot run headless mode without an input port for events. Shutting down.");
                m_ShouldShutdown = true;
            }
            else if (options.Headless && options.InputPort.HasValue)
            {
                Svarog.Instance.LogInfo($"Preparing for headless mode using port #{options.InputPort.Value} for inputs.");
            }
            else if (options.InputPort.HasValue)
            {
                Svarog.Instance.LogInfo($"Using port #{options.InputPort.Value} as an aux input port (handy for debugging).");
            }

            if (!options.Headless)
            {
                var parts = options.Presenter.Split(",", 2);
                var presenter = Activator.CreateInstance(parts[1].Trim(), parts[0].Trim());
                if (presenter != null)
                {
                    m_PresentationLayer = (IPresentationLayer?)presenter.Unwrap();
                    Svarog.Instance.LogInfo($"Svarog presenter class ({options.Presenter}) instantiated successfully.");
                }
                else
                {
                    Svarog.Instance.LogFatal($"Svarog presenter class ({options.Presenter}) not found. Quitting.");
                    Shutdown();
                }
            }
        }

        #endregion Display

        #region Scripting

        public void RunScriptMain()
        {
            RunScript(@"dofile ""scripts\\Main.lua""");
        }

        public void RunScript(string code)
        {
            try
            {
                m_Lua.DoString(code);
            }
            catch (LuaScriptException scriptingException)
            {
                LogError(scriptingException.ToString());
            }
            catch (LuaException luaException)
            {
                LogError(luaException.ToString());
            }
        }

        public void RunScriptFile(string filename)
        {
            try
            {
                m_Lua.DoFile(filename);
            }
            catch (LuaScriptException scriptingException)
            {
                LogError(scriptingException.ToString());
            }
            catch (LuaException luaException)
            {
                LogError(luaException.ToString());
            }
        }

        #endregion Scripting

        bool m_ShouldShutdown = false;

        readonly Lua m_Lua;

        public Lua Scripting => m_Lua;

        readonly InputManager m_InputManager;
        IPresentationLayer? m_PresentationLayer = null;

        private Glyph[][] m_Glyphs;

        public Glyph[][] Glyphs => m_Glyphs;

        private Clock m_Clock = new Clock();
        long m_FrameTime = 0;
        long m_RenderFrameTime = 0;
        int m_Counter = 0;

        private bool m_Redraw = true;
        public bool ShouldRedraw() => m_Redraw;
        public void Redraw() { m_Redraw = true; }
        public void ResetRedraw() { m_Redraw = false; }

        private bool m_Reload = false;
        public void Reload() { m_Reload = true; }

        public void ReloadConfig()
        {
            RunScript(@"dofile ""scripts\\engine\\DefaultConfig.lua""");
            RunScript(@"dofile ""scripts\\Config.lua""");
        }

        public void ReloadGlossary()
        {
            Svarog.Instance.LogInfo("Loading glossary");
            RunScript(@"dofile ""scripts\\engine\\Presentation.lua""");
            RunScript("Glossary = {}");
            RunScript("Glossary.Meta = {}");
            m_Colors = new();
            m_Lua["Colors"] = m_Colors;
            if (m_Lua["Config.Palette"] is string palette)
            {
                RunScript($@"dofile ""scripts\\presentation\\palettes\\{palette}.lua""");
            }
            RunScript(@"dofile ""scripts\\presentation\\Glossary.lua""");
        }

        public void ReloadGlyphs()
        {
            var width = (int)((double)m_Lua["Config.Width"]);
            var height = (int)((double)m_Lua["Config.Height"]);
            m_Glyphs = new Glyph[width][];

            for (int i = 0; i < width; i++)
            {
                m_Glyphs[i] = new Glyph[height];
                for (int j = 0; j < height; j++)
                {
                    m_Glyphs[i][j] = new Glyph();
                }
            }
            m_Lua["Glyphs"] = m_Glyphs;
        }

        public void ReloadPresenter()
        {
            m_PresentationLayer?.Reload();
        }

        float m_Delta = 0.0f;
        public float DeltaTime => m_Delta;

        Colors m_Colors;
        internal Colors Colors => m_Colors;

        public void EnqueueInput(InputAction input)
        {
            m_InputManager.Enqueue(input);
        }

        public void Shutdown() => m_ShouldShutdown = true;

        private Svarog()
        {
            m_Lua = new();
            m_InputManager = new();
        }

        static void Main(string[] args)
        {
            Svarog.Instance.Run(args);
        }

        public void Run(string[] args)
        {
            var commandLine = Parser.Default.ParseArguments<CommandLineOptions>(args);

            commandLine.WithParsed(options =>
            {
                m_Lua["Options"] = options;
                SetupLogging(options);

                Svarog.Instance.LogInfo("===========================================");
                Svarog.Instance.LogInfo("Starting up Svarog!");

                SetupDisplayMode(options);
            });

            m_Lua.LoadCLRPackage();
            m_Lua["Svarog"] = this;
            m_Lua["Rand"] = new Randomness();
            m_Lua["InputStack"] = m_InputManager;
            m_Lua["ActionTriggers"] = m_InputManager.Triggered;

            RunScript(@"Map = require ""scripts\\engine\\Map""");
            RunScript(@"Queue = require ""scripts\\engine\\Queue""");
            RunScript(@"ECS = require ""scripts\\engine\\ecs\\ECS""");
            RunScript(@"Engine = require ""scripts\\engine\\Engine""");
            RunScript(@"Input = require ""scripts\\engine\\Input""");

            ReloadConfig();
            ReloadGlossary();
            ReloadGlyphs();

            m_InputManager.ReloadActions();
            commandLine.WithParsed(options => m_PresentationLayer?.Create(options));

            RunScript(@"dofile ""scripts\\Library.lua""");
            RunScriptMain();
            RunScript(@"Engine.Setup()");

            Svarog.Instance.LogInfo("Scripting ECS up and running!");

            while (!m_ShouldShutdown)
            {
                m_InputManager.Clear();
                m_Clock.Restart();

                if (m_Reload)
                {
                    RunScript(@"Engine.Reload()");
                    m_Reload = false;
                }

                m_InputManager.Update();
                m_PresentationLayer?.Update();

                RunScript(@"Engine.Update()");
                m_Counter++;
                m_Delta = m_Clock.ElapsedTime.AsMilliseconds();

                m_FrameTime += (int)m_Delta;
                if (m_FrameTime >= 1000)
                {
                    LogVerbose($"FPS -- {m_Counter}");
                    m_FrameTime = 0;
                    m_Counter = 0;
                }

                m_RenderFrameTime += (int)m_Delta;
                if (m_RenderFrameTime >= (double)m_Lua["Config.FrameTime"])
                {
                    Redraw();
                    m_RenderFrameTime = 0;
                }

                Thread.Yield();
            }

            Svarog.Instance.LogInfo("Shutting Svarog down!");
        }
    }
}

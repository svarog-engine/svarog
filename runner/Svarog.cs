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
        long m_Time = 0;
        int m_Counter = 0;

        private bool m_Reload = false;
        public void Reload() { m_Reload = true; }

        float m_Delta = 0.0f;
        public float DeltaTime => m_Delta;

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
            Parser.Default.ParseArguments<CommandLineOptions>(args)
            .WithParsed(options =>
            {
                m_Lua["Options"] = options;
                SetupLogging(options);

                Svarog.Instance.LogInfo("===========================================");
                Svarog.Instance.LogInfo("Starting up Svarog!");

                SetupDisplayMode(options);
                var width = options.WorldWidth.GetValueOrDefault();
                var height = options.WorldHeight.GetValueOrDefault();
                m_Glyphs = new Glyph[width][];

                for (int i = 0; i < options.WorldWidth; i++)
                {
                    m_Glyphs[i] = new Glyph[height];
                    for (int j = 0; j < options.WorldHeight; j++)
                    {
                        m_Glyphs[i][j] = new Glyph();
                    }
                }

                m_PresentationLayer?.Create(options);
            });

            m_Lua.LoadCLRPackage();
            m_Lua["Svarog"] = this;
            m_Lua["Rand"] = new Randomness();
            m_Lua["Glyphs"] = m_Glyphs;
            m_Lua["Colors"] = new Colors();
            m_Lua["InputStack"] = m_InputManager;
            m_Lua["ActionTriggers"] = m_InputManager.Triggered;

            RunScript(@"ECS = require ""scripts\\engine\\ecs\\ECS""");
            RunScript(@"Engine = require ""scripts\\engine\\Engine""");
            RunScript(@"Input = require ""scripts\\engine\\Input""");
            m_InputManager.ReloadActions();
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
                m_Time += (int)m_Delta;

                if (m_Time >= 1000)
                {
                    LogInfo($"FPS -- {m_Counter}");
                    m_Time = 0;
                    m_Counter = 0;
                }

                Thread.Yield();
            }

            Svarog.Instance.LogInfo("Shutting Svarog down!");
        }
    }
}

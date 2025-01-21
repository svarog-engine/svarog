﻿
using CommandLine;
using NLua;
using SFML.Graphics;
using SFML.Window;

using svarog.input;
using svarog.runner;

namespace svarog.presentation
{
    internal class SFMLPresenter : IPresentationLayer
    {
        private RenderWindow? m_Window = null;

        private Dictionary<string, SFML.Graphics.Font> m_Fonts = [];

        private Sprite m_DrawSprite = new();
        private RenderTexture m_Surface = new(800, 600);
        private GlyphRenderer m_Renderer = new();

        public RenderTexture? Surface => m_Surface;

        public void Create(CommandLineOptions options)
        {
            m_Window = new RenderWindow(new SFML.Window.VideoMode(800, 600), "Svarog");

            m_Window.Closed += (object? _, EventArgs _) =>
            {
                m_Window.Close();
                Svarog.Instance.Shutdown();
            };

            m_Window.KeyPressed += (object? _, KeyEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Press, $"Key: {args.Scancode}", 0));
            };

            m_Window.KeyReleased += (object? _, KeyEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Release, $"Key: {args.Scancode}", 0));
            };

            m_Window.MouseButtonPressed += (object? _, MouseButtonEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Press, $"Mouse: {args.Button}", 1, args.X, args.Y));
            };

            m_Window.MouseButtonReleased += (object? _, MouseButtonEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Release, $"Mouse: {args.Button}", 0, args.X, args.Y));
            };

            m_Window.MouseMoved += (object? _, MouseMoveEventArgs args) =>
            {
                Svarog.Instance.EnqueueInput(new InputAction(EInputActionType.Hold, "Mouse: Move", 0, args.X, args.Y));
            };

            LoadFonts();

            if(Svarog.Instance.Scripting["Config"] is LuaTable config)
            {
                var size = config["Font_Size"].ToString();
                m_Renderer.FontSize = uint.Parse(size);

                var fontName = config["Font"].ToString();
                if (m_Fonts.ContainsKey(fontName))
                {
                    m_Renderer.CurrentFont = m_Fonts[fontName];
                }
                else
                {
                    Svarog.Instance.LogWarning($"Font [{fontName}] was not found. No default font set!");
                }
            }

            m_Surface = new RenderTexture(800, 600);
            m_DrawSprite.Texture = m_Surface.Texture;

            Svarog.Instance.LogInfo("SFML Presenter up and running!");
        }

        void LoadFonts()
        {
            DirectoryInfo d = new DirectoryInfo(@"resources/font");

            FileInfo[] Files = d.GetFiles("*.ttf");

            foreach (var file in Files)
            {
                var name = file.Name.Substring(0, file.Name.LastIndexOf(".ttf"));
                m_Fonts[name] = new SFML.Graphics.Font(file.FullName);
            }
        }

        void DrawTest()
        {
            m_Surface.Clear();
            var map = Svarog.Instance.Glyphs;

            m_Renderer.DrawWithText(map, m_Surface);

            m_Surface.Display();
        }

        public void Update()
        {
            if (m_Window != null)
            {
                m_Window.DispatchEvents();

                DrawTest();
                m_Window.Draw(m_DrawSprite);

                m_Window.Display();
            }
        }
    }
}
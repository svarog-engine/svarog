using SFML.Graphics;
using SFML.Window;

using svarog.input;
using svarog.runner;
using svarog.utility;

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

        private uint m_WindowWidth = 800;
        private uint m_WindowHeight = 600;

        public void Create(CommandLineOptions options)
        {
            LoadFonts();

            if (Svarog.Instance.Scripting["Config.FontSize"].ToString() is string fontSizeValue)
            {
                var fontSize = uint.Parse(fontSizeValue);
                m_Renderer.FontSize = fontSize;

                if (Svarog.Instance.Scripting["Config.WorldWidth"].ToString() is string worldWidhtValue)
                {
                    m_WindowWidth = uint.Parse(worldWidhtValue) * fontSize;
                }

                if (Svarog.Instance.Scripting["Config.WorldHeight"].ToString() is string worldHeightValue)
                {
                    m_WindowHeight = uint.Parse(worldHeightValue) * fontSize;
                }
            }

            if (Svarog.Instance.Scripting["Config.Font"] is string fontFamily)
            {
                if (m_Fonts.ContainsKey(fontFamily))
                {
                    m_Renderer.CurrentFont = m_Fonts[fontFamily];
                }
                else
                {
                    Svarog.Instance.LogWarning($"Font [{fontFamily}] was not found. No default font set!");
                }
            }

            m_Surface = new RenderTexture(m_WindowWidth, m_WindowHeight);
            m_DrawSprite.Texture = m_Surface.Texture;

            InitializeWindow();

            Svarog.Instance.LogInfo($"Created window size: {m_WindowWidth} x {m_WindowHeight}");

            Svarog.Instance.LogInfo("SFML Presenter up and running!");
        }

        void InitializeWindow()
        {
            m_Window = new RenderWindow(new SFML.Window.VideoMode(m_WindowWidth, m_WindowHeight), "Svarog");

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
        }

        void LoadFonts()
        {
            if (m_Fonts.Count > 0)
            {
                m_Fonts.Clear();
            }

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

        public void Reload()
        {
            LoadFonts();

            if (Svarog.Instance.Scripting["Config.FontSize"].ToString() is string fontSizeValue)
            {
                var fontSize = uint.Parse(fontSizeValue);
                m_Renderer.FontSize = fontSize;

                if (Svarog.Instance.Scripting["Config.WorldWidth"].ToString() is string worldWidhtValue)
                {
                    m_WindowWidth = uint.Parse(worldWidhtValue) * fontSize;
                }

                if (Svarog.Instance.Scripting["Config.WorldHeight"].ToString() is string worldHeightValue)
                {
                    m_WindowHeight = uint.Parse(worldHeightValue) * fontSize;
                }
            }

            if (Svarog.Instance.Scripting["Config.Font"] is string fontFamily)
            {
                if (m_Fonts.ContainsKey(fontFamily))
                {
                    m_Renderer.CurrentFont = m_Fonts[fontFamily];
                }
                else
                {
                    Svarog.Instance.LogWarning($"Font [{fontFamily}] was not found. No default font set!");
                }
            }

            m_Surface = new RenderTexture(m_WindowWidth, m_WindowHeight);
            m_DrawSprite.Texture = m_Surface.Texture;

            // doesn't work ???!!?
            // m_Window?.Size = new SFML.System.Vector2u(m_WindowWidth, m_WindowHeight);

            m_Window?.SetWindowSize(m_WindowWidth, m_WindowHeight);
            m_Window?.SetView(new View(new FloatRect(0, 0, m_WindowWidth, m_WindowHeight)));
        }
    }
}
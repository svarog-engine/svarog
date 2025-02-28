using SFML.Graphics;
using SFML.Window;

using svarog.input;
using svarog.runner;
using svarog.utility;
using svarog.utility.filesystem;

namespace svarog.presentation
{
    internal class SFMLPresenter : IPresentationLayer
    {
        private RenderWindow? m_Window = null;

        private Dictionary<string, SFML.Graphics.Font> m_Fonts = [];
        private Dictionary<string, SFML.Graphics.Texture> m_Sprites = [];

        private Sprite m_DrawSprite = new();
        private RenderTexture m_Surface = new(800, 600);
        private IRenderer m_Renderer;
        private IPresentationMode m_Mode;

        public RenderTexture? Surface => m_Surface;

        private uint m_WindowWidth = 800;
        private uint m_WindowHeight = 600;

        void ReloadPresentationMode(IPresentationMode mode)
        {
            m_Mode = mode;
            if (mode is SpritePresentationMode spriteMode)
            {
                var spriteRenderer = new GlyphSpriteRenderer();
                m_Renderer = spriteRenderer;
                spriteRenderer.FontSize = (uint)spriteMode.Size;
                spriteRenderer.Texture = m_Sprites[spriteMode.Font];
                spriteRenderer.OffsetX = spriteMode.OffsetX;
                spriteRenderer.OffsetY = spriteMode.OffsetY;
                spriteRenderer.PaddingX = spriteMode.PaddingX;
                spriteRenderer.PaddingY = spriteMode.PaddingY;

                if (Svarog.Instance.Scripting["Config.FontSize"] is double fontSizeValue)
                {
                    spriteRenderer.Scale = (float)fontSizeValue / (float)spriteMode.Size;
                }

                if (Svarog.Instance.Scripting["Config.Width"] is double worldWidthValue)
                {
                    m_WindowWidth = (uint)(worldWidthValue * m_Renderer.FontSize * spriteRenderer.Scale);
                }

                if (Svarog.Instance.Scripting["Config.Height"] is double worldHeightValue)
                {
                    m_WindowHeight = (uint)(worldHeightValue * m_Renderer.FontSize * spriteRenderer.Scale);
                }
            }
            else
            {
                Svarog.Instance.LogInfo("[Presentation] Unsoported presentation mode! Please, use SpritePresentationMode!");
            }
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

        void LoadSpritesheets()
        {
            var fileSystem = Svarog.Instance.FileSystem;
            if (fileSystem != null)
            {
                foreach (var spriteFile in fileSystem.GetFiles(@"resources\sprites", ".png"))
                {
                    var startIndex = spriteFile.LastIndexOf("\\") + 1;
                    var endIndex = spriteFile.LastIndexOf(".png");
                    var name = spriteFile.Substring(startIndex, endIndex - startIndex) + ".png";

                    m_Sprites[name] = new SFML.Graphics.Texture(fileSystem.GetAsset(spriteFile));
                }

                foreach (var spriteFile in fileSystem.GetFiles(@"resources\fonts\licensed", ".png"))
                {
                    var startIndex = spriteFile.LastIndexOf("\\") + 1;
                    var endIndex = spriteFile.LastIndexOf(".png");
                    var name = spriteFile.Substring(startIndex, endIndex - startIndex) + ".png";

                    m_Sprites[name] = new SFML.Graphics.Texture(fileSystem.GetAsset(spriteFile));
                }
            }
        }

        void DrawSurface()
        {
            m_Surface.Clear();
            var map = Svarog.Instance.Glyphs;
            var UI = Svarog.Instance.UIGlyphs;

            m_Renderer.Draw(map, UI, m_Surface);

            m_Surface.Display();
        }

        public void Update()
        {
            if (m_Window != null)
            {
                m_Window.DispatchEvents();

                DrawSurface();
                m_Window.Draw(m_DrawSprite);

                m_Window.Display();
            }
        }

        private void LoadContent()
        {
            LoadSpritesheets();

            var lua = Svarog.Instance.Scripting;
            if (lua["Config.Presentation"] is string presentation)
            {
                Svarog.Instance.LogInfo($"Using presentation: {presentation}");
                var mode = lua[$"Glossary.Meta.{presentation}"] as IPresentationMode;
                ReloadPresentationMode(mode);
            }

            m_Surface = new RenderTexture(m_WindowWidth, m_WindowHeight);
            m_DrawSprite.Texture = m_Surface.Texture;
            m_DrawSprite.TextureRect = new IntRect(0, 0, (int)m_WindowWidth, (int)m_WindowHeight);
        }

        public void Create(CommandLineOptions options)
        {
            LoadContent();
            InitializeWindow();

            Svarog.Instance.LogInfo($"Created window size: {m_WindowWidth} x {m_WindowHeight}");
            Svarog.Instance.LogInfo("SFML Presenter up and running!");
        }

        public void Reload()
        {
            LoadContent();

            m_Window?.SetWindowSize(m_WindowWidth, m_WindowHeight);
            m_Window?.SetView(new View(new FloatRect(0, 0, m_WindowWidth, m_WindowHeight)));
        }
    }
}
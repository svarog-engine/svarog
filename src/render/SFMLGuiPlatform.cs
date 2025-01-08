using svagui.abstraction;
using svagui.platform;

using svarog.src.windowing;

namespace svarog.src.render
{
    public class SFMLGUIPlatform : IGUIPlatform
    {
        GUIContexts m_Contexts = new();
        GUIEnvironment m_Environment = new();
        GUIInputState m_InputState = new();

        Dictionary<string, SFML.Graphics.Font> m_Fonts = [];
        Dictionary<string, SFML.Graphics.RenderTexture> m_Textures = [];
        string? m_RenderSurface = null;
        Vector2 m_RenderSurfaceOffset = new Vector2(0, 0);
        Vector2 m_RenderSurfaceSize = new Vector2(0, 0);
        Vector2 m_MouseInputOffset = new Vector2(0, 0);
        bool m_MouseInputsEnabled = true;

        MainWindow m_Window;
        SFML.Graphics.Sprite m_Sprite = new();
        SFML.Graphics.CircleShape m_Circle = new();
        SFML.Graphics.RectangleShape m_Rect = new();
        SFML.Graphics.Text m_Text = new();
        SFML.Graphics.Vertex[] m_Line = new SFML.Graphics.Vertex[2];

        public SFMLGUIPlatform(MainWindow window)
        {
            m_Window = window;
            m_Fonts["mont"] = new SFML.Graphics.Font("mont.ttf");
            m_Fonts["fira"] = new SFML.Graphics.Font("fira.ttf");
        }

        public void SetRenderSurface(string name)
        {
            m_RenderSurface = name;
            if (!m_Textures.ContainsKey(m_RenderSurface))
            {
                var state = m_Environment.GetState();
                m_Textures[m_RenderSurface] = new SFML.Graphics.RenderTexture((uint)m_Window.Width, (uint)m_Window.Height, new SFML.Window.ContextSettings() { AntialiasingLevel = 8, SRgbCapable = true });
            }
            m_Textures[m_RenderSurface].Clear(new SFML.Graphics.Color(0, 0, 0, 0));
        }

        public void UnsetRenderSurface()
        {
            m_RenderSurface = null;
        }

        public void SetRenderSurfaceOffset(Vector2 offset)
        {
            m_RenderSurfaceOffset = offset;
        }

        public Vector2 GetRenderSurfaceOffset()
        {
            return m_RenderSurfaceOffset;
        }

        public void SetRenderSurfaceSize(Vector2 size)
        {
            m_RenderSurfaceSize = size;
        }

        public Vector2 GetRenderSurfaceSize()
        {
            return m_RenderSurfaceSize;
        }

        public string GetRenderSurface() => m_RenderSurface ?? "";

        public void DrawCircle(Vector2 center, float radius, Color fill, Color outline, float thickness)
        {
            m_Circle.Position = new SFML.System.Vector2f(center.X + m_RenderSurfaceOffset.X, center.Y + m_RenderSurfaceOffset.Y);
            m_Circle.Radius = radius;
            m_Circle.FillColor = new SFML.Graphics.Color((byte)fill.R, (byte)fill.G, (byte)fill.B, (byte)fill.A);
            m_Circle.OutlineColor = new SFML.Graphics.Color((byte)outline.R, (byte)outline.G, (byte)outline.B, (byte)outline.A);
            m_Circle.OutlineThickness = thickness;
            if (m_RenderSurface == null)
            {
                m_Window.Window?.Draw(m_Circle);
            }
            else
            {
                m_Textures[m_RenderSurface].Draw(m_Circle);
                m_Textures[m_RenderSurface].Display();
            }
        }

        public void DrawLine(Vector2 position, Vector2 size, Color outline, float thickness)
        {
            m_Line[0].Position = new SFML.System.Vector2f(position.X + m_RenderSurfaceOffset.X, position.Y + m_RenderSurfaceOffset.Y);
            m_Line[1].Position = new SFML.System.Vector2f(position.X + size.X + m_RenderSurfaceOffset.X, position.Y + size.Y + m_RenderSurfaceOffset.Y);
            m_Line[0].Color = new SFML.Graphics.Color((byte)outline.R, (byte)outline.G, (byte)outline.B, (byte)outline.A);
            m_Line[1].Color = new SFML.Graphics.Color((byte)outline.R, (byte)outline.G, (byte)outline.B, (byte)outline.A);
            
            if (m_RenderSurface == null)
            {
                m_Window.Window?.Draw(m_Line, SFML.Graphics.PrimitiveType.Lines);
            }
            else
            {
                m_Textures[m_RenderSurface].Draw(m_Line, SFML.Graphics.PrimitiveType.Lines);
                m_Textures[m_RenderSurface].Display();
            }
        }

        public void DrawRectangle(Vector2 position, Vector2 size, Color fill, Color outline, float thickness, float radius)
        {
            m_Rect.Position = new SFML.System.Vector2f(position.X + m_RenderSurfaceOffset.X, position.Y + m_RenderSurfaceOffset.Y);
            m_Rect.Size = new SFML.System.Vector2f(size.X, size.Y);
            m_Rect.FillColor = new SFML.Graphics.Color((byte)fill.R, (byte)fill.G, (byte)fill.B, (byte)fill.A);
            m_Rect.OutlineColor = new SFML.Graphics.Color((byte)outline.R, (byte)outline.G, (byte)outline.B, (byte)outline.A);
            m_Rect.OutlineThickness = thickness;
            
            if (m_RenderSurface == null)
            {
                m_Window.Window?.Draw(m_Rect);
            }
            else
            {
                m_Textures[m_RenderSurface].Draw(m_Rect);
                m_Textures[m_RenderSurface].Display();
            }
        }

        public void DrawText(string fontName, string text, int fontSize, Vector2 position, Color fill, Color outline, float thickness)
        {
            SFML.Graphics.Font font = m_Fonts["fira"];
            if (m_Fonts.ContainsKey(fontName))
            {
                font = m_Fonts[fontName];
            }

            m_Text.Font = font;
            m_Text.DisplayedString = text;
            m_Text.CharacterSize = (uint)fontSize;
            m_Text.Position = new SFML.System.Vector2f(position.X + m_RenderSurfaceOffset.X, position.Y + m_RenderSurfaceOffset.Y);
            m_Text.FillColor = new SFML.Graphics.Color((byte)fill.R, (byte)fill.G, (byte)fill.B, (byte)fill.A);
            m_Text.OutlineColor = new SFML.Graphics.Color((byte)outline.R, (byte)outline.G, (byte)outline.B, (byte)outline.A);
            m_Text.OutlineThickness = thickness;
            if (m_RenderSurface == null)
            {
                m_Window.Window?.Draw(m_Text);
            }
            else
            {
                m_Textures[m_RenderSurface].Draw(m_Text);
                m_Textures[m_RenderSurface].Display();
            }
        }

        public void DrawTexture(string texture, Vector2 position, float scale, Vector2 clipPosition, Vector2 clipSize, Color tint)
        {
            if (m_Textures.ContainsKey(texture))
            {
                m_Sprite.Texture = m_Textures[texture].Texture;
                m_Sprite.Position = new SFML.System.Vector2f(position.X + m_RenderSurfaceOffset.X, position.Y + m_RenderSurfaceOffset.Y);
                m_Sprite.Scale = new SFML.System.Vector2f(scale, scale);
                m_Sprite.Color = new SFML.Graphics.Color((byte)tint.R, (byte)tint.G, (byte)tint.B, (byte)tint.A);
                m_Sprite.TextureRect = new SFML.Graphics.IntRect(
                    new SFML.System.Vector2i((int)clipPosition.X, (int)clipPosition.Y),
                    new SFML.System.Vector2i((int)clipSize.X, (int)clipSize.Y));

                if (m_RenderSurface == null)
                {
                    m_Window.Window?.Draw(m_Sprite);
                }
                else
                {
                    m_Textures[m_RenderSurface].Draw(m_Sprite);
                    m_Textures[m_RenderSurface].Display();
                }
            }
        }

        public GUIContexts GetContexts() => m_Contexts;

        public GUIEnvironment GetEnvironment() => m_Environment;

        public GUIInputState GetInputState() => m_InputState;

        public void Update(GUIInputState inputState)
        {
            var oldPos = m_InputState.MousePosition;
            m_InputState = inputState;
            m_Environment.MouseDelta = inputState.MousePosition - oldPos;
        }

        public void SetMouseInputOffset(Vector2 offset)
        {
            m_MouseInputOffset = offset;
        }

        public Vector2 GetMouseInputOffset()
        {
            return m_MouseInputOffset;
        }

        public void SetMouseInputsEnabled(bool enabled)
        {
            m_MouseInputsEnabled = enabled;
        }

        public bool GetMouseInputsEnabled() => m_MouseInputsEnabled;
    }
}

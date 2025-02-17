using SFML.Graphics;

namespace svarog.presentation
{
    public class GlyphFontRenderer : IRenderer
    {
        SFML.Graphics.Font? m_CurrentFont = null;
        uint m_FontSize = 12;

        SFML.Graphics.Text m_Text = new();
        private RectangleShape m_BackgroundRect = new();

        public SFML.Graphics.Font? CurrentFont
        {
            get => m_CurrentFont;
            set
            {
                m_CurrentFont = value;
                m_Text.Font = m_CurrentFont;
            }
        }
        public uint FontSize
        {
            get => m_FontSize;
            set
            {
                m_FontSize = value;
                m_Text.CharacterSize = m_FontSize;
                m_BackgroundRect = new RectangleShape(new SFML.System.Vector2f(m_FontSize, m_FontSize));
            }
        }

        public void Draw(Glyph[][] gameGlyphs, Glyph[][] UIGlyphs, RenderTexture target)
        {
            for (int i = 0; i < gameGlyphs.Length; i++)
            {
                var width = m_FontSize * i;
                for (int j = 0; j < gameGlyphs[i].Length; j++)
                {
                    var item = UIGlyphs[i][j].IsValid ? UIGlyphs[i][j] : gameGlyphs[i][j];
                    m_BackgroundRect.Position = new SFML.System.Vector2f(width, m_FontSize * j);
                    m_BackgroundRect.FillColor = item.Background;
                    m_BackgroundRect.Draw(target, RenderStates.Default);
                }
            }

            for (int i = 0; i < gameGlyphs.Length; i++)
            {
                for (int j = 0; j < gameGlyphs[i].Length; j++)
                {
                    var item = UIGlyphs[i][j].IsValid ? UIGlyphs[i][j] : gameGlyphs[i][j];
                    if (item.Presentation == " " || item.Presentation == "")
                        continue;

                    m_Text.DisplayedString = item.Presentation;
                    m_Text.FillColor = item.Foreground;
                    m_Text.Position = new SFML.System.Vector2f(m_FontSize * i + m_FontSize * 0.5f, m_FontSize * j + m_FontSize * 0.5f);
                    m_Text.Origin = m_Text.GetLocalBounds().Size / 2.0f + m_Text.GetLocalBounds().Position;
                    m_Text.Draw(target, RenderStates.Default);
                }
            }
        }
    }
}

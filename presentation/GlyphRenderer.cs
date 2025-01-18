using SFML.Graphics;

namespace svarog.presentation
{
    public class GlyphRenderer
    {
        SFML.Graphics.Font? m_CurrentFont = null;
        uint m_FontSize = 12;

        SFML.Graphics.Text m_Text = new();
        private RectangleShape m_BackgroundRect = new RectangleShape();

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

        public void DrawWithText(Glyph[][] matrix, RenderTexture target)
        {
            for (int i = 0; i < matrix.Length; i++)
            {
                for (int j = 0; j < matrix[i].Length; j++)
                {
                    var item = matrix[i][j];
                    m_BackgroundRect.Position = new SFML.System.Vector2f(m_FontSize * i, m_FontSize * j);
                    m_BackgroundRect.FillColor = item.Background;

                    m_BackgroundRect.Draw(target, RenderStates.Default);
                }
            }

            for (int i = 0; i < matrix.Length; i++)
            {
                for (int j = 0; j < matrix[i].Length; j++)
                {
                    var item = matrix[i][j];
                    m_Text.DisplayedString = item.Presentation;
                    m_Text.FillColor = item.Foreground;
                    m_Text.Position = new SFML.System.Vector2f(m_FontSize * i, m_FontSize * j);

                    m_Text.Draw(target, RenderStates.Default);
                }
            }
        }
    }
}

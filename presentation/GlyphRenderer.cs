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

        public void DrawWithText(SparseMatrix<Glyph> matrix, RenderTexture target)
        {
            var height = matrix.Height;
            var width = matrix.Width;

            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    var item = matrix[j, i];
                    m_BackgroundRect.Position = new SFML.System.Vector2f(m_FontSize * j, m_FontSize * i);
                    m_BackgroundRect.FillColor = item.Background;

                    m_BackgroundRect.Draw(target, RenderStates.Default);
                }
            }

            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    var item = matrix[j, i];
                    m_Text.DisplayedString = item.Presentation;
                    m_Text.FillColor = item.Foreground;
                    m_Text.Position = new SFML.System.Vector2f(m_FontSize * j, m_FontSize * i);

                    m_Text.Draw(target, RenderStates.Default);
                }
            }
        }
    }
}

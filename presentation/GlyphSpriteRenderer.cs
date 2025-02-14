using SFML.Graphics;
using SFML.System;
using svarog.core;
using svarog.runner;

namespace svarog.presentation
{
    public class GlyphSpriteRenderer : IRenderer
    {
        SFML.Graphics.Sprite m_Sprite = new();
        private RectangleShape m_BackgroundRect = new();
        private uint m_FontSize;
        private float m_Scale = 1.0f;

        private Texture m_Texture;
        public Texture Texture
        {
            get
            {
                return m_Texture;
            }

            set
            {
                m_Texture = value;
                if (m_Sprite.Texture != m_Texture)
                {
                    m_Sprite.Texture = Texture;
                }
            }
        }

        public uint FontSize
        {
            get => m_FontSize;
            set
            {
                m_FontSize = value;
                m_BackgroundRect = new RectangleShape(new SFML.System.Vector2f(m_FontSize, m_FontSize));
            }
        }

        public float Scale
        {
            get => m_Scale;
            set
            {
                m_Scale = value;
            }
        }

        public uint RowLength { get; set; }
        public Vector2i Padding { get; set; }

        public void Draw(Glyph[][] gameGlyphs, Glyph[][] UIGlyphs, RenderTexture target)
        {
            var scale = new SFML.System.Vector2f(m_Scale, m_Scale);
            for (int i = 0; i < gameGlyphs.Length; i++)
            {
                for (int j = 0; j < gameGlyphs[i].Length; j++)
                {
                    var item = UIGlyphs[i][j].IsValid ? UIGlyphs[i][j] : gameGlyphs[i][j];
                    m_BackgroundRect.Position = new Vector2f(m_FontSize * i * m_Scale, m_FontSize * j * m_Scale);
                    m_BackgroundRect.Scale = scale;
                    m_BackgroundRect.FillColor = item.Background;
                    m_BackgroundRect.Draw(target, RenderStates.Default);
                }
            }

            for (int i = 0; i < gameGlyphs.Length; i++)
            {
                for (int j = 0; j < gameGlyphs[i].Length; j++)
                {
                    var item = UIGlyphs[i][j].IsValid ? UIGlyphs[i][j] : gameGlyphs[i][j];

                    m_Sprite.Color = item.Foreground;
                    m_Sprite.Scale = scale;
                    m_Sprite.Position = new Vector2f(m_FontSize * i * m_Scale, m_FontSize * j * m_Scale);
                    m_Sprite.TextureRect = new((int)(item.TileX * m_FontSize), (int)(item.TileY * m_FontSize), (int)m_FontSize, (int)m_FontSize);
                    m_Sprite.Draw(target, RenderStates.Default);                    
                }
            }
        }
    }
}

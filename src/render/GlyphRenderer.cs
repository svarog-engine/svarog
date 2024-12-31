using SFML.Graphics;
using SFML.System;

using svarog.src.tools;

namespace svarog.src.render
{
    public class GlyphRenderer
    {
        private Svarog m_Core;
        private RenderTexture m_Surface;
        private Sprite m_Sprite = new();

        public RenderTexture Surface => m_Surface;

        public GlyphRenderer(Svarog svarog) 
        {
            m_Core = svarog;
            m_Surface = new RenderTexture((uint)svarog.MainWindow.Width, (uint)svarog.MainWindow.Height);
        }

        public void Clear()
        {
            m_Surface.Clear();
        }

        public void Draw(PatternBlock block, Pattern pat, Vector2f xy, float scale = 1.0f, RenderTexture? targetTexture = null)
        {
            var texture = m_Core.ToolBox.GetTexture(block.Source);
            var w = m_Core.ToolBox.FileData[block.Source].Width;
            var source = new Vector2f(block.SourceId % w, block.SourceId / w);

            m_Sprite.Texture = texture;
            m_Sprite.TextureRect = new IntRect((int)source.X * pat.GridSize, (int)source.Y * pat.GridSize, pat.GridSize, pat.GridSize);
            m_Sprite.Color = new Color((byte)(block.Color.X * 255), (byte)(block.Color.Y * 255), (byte)(block.Color.Z * 255));
            m_Sprite.Scale = new Vector2f(scale, scale);
            m_Sprite.Position = xy * scale;
            if (targetTexture == null)
                m_Sprite.Draw(m_Surface, RenderStates.Default);
            else
                m_Sprite.Draw(targetTexture, RenderStates.Default);
        }

        Dictionary<Pattern, RenderTexture> m_PatternCache = new();

        public void Draw(Pattern pattern, Vector2f xy, float scale = 1.0f)
        {
            if (!m_PatternCache.ContainsKey(pattern))
            {
                var texture = new RenderTexture((uint)(pattern.Width * pattern.GridSize), (uint)(pattern.Height * pattern.GridSize));
                foreach (var block in pattern.Data)
                {
                    var target = new Vector2f(block.TargetId % pattern.Width * pattern.GridSize, block.TargetId / pattern.Width * pattern.GridSize);
                    Draw(block, pattern, target, 1.0f, texture);
                }
                texture.Display();
                m_PatternCache[pattern] = texture;
            }

            m_Sprite.Texture = m_PatternCache[pattern].Texture;
            m_Sprite.TextureRect = new IntRect(0, 0, (int)m_Sprite.Texture.Size.X, (int)m_Sprite.Texture.Size.Y);
            m_Sprite.Color = Color.White;
            m_Sprite.Scale = new Vector2f(scale, scale);
            m_Sprite.Position = xy * scale;
            m_Sprite.Draw(m_Surface, RenderStates.Default);
        }

        public void Draw(GlyphFont font, string text, Vector2f xy, float scale = 1.0f)
        {
            int i = 0;
            foreach (var letter in text)
            {
                i++;
                if (font.LetterMapping.ContainsKey(letter))
                {
                    var offset = font.LetterMapping[letter];
                    Draw(font.Pattern.Data[offset], font.Pattern, xy + new Vector2f(i * font.Pattern.GridSize, 0), scale);
                }
            }
        }

        public void Display()
        {
            m_Surface.Display();
        }
    }
}

using SFML.Graphics;

namespace svarog
{
    public interface IRenderer
    {
        public uint FontSize { get; set; }
        public void Draw(Glyph[][] matrix, RenderTexture target);
    }
}

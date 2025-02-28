using SFML.Graphics;

using svarog.runner;

namespace svarog
{
    public class Glyph(Color foreground, Color background) {
        public int TileX { get; set; } = 0;
        public int TileY { get; set; } = 0;
        public Color Background { get; set; } = background;
        public Color Foreground { get; set; } = foreground;

        public bool IsValid => (TileX > -1 && TileY > -1);

        public Glyph() : this(Svarog.Instance.Colors.Transparent, Svarog.Instance.Colors.Transparent)
        {
            TileX = -1;
            TileY = -1;
        }
    }
}

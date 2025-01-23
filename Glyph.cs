using SFML.Graphics;

namespace svarog
{
    public class Glyph(string presentation, Color foreground, Color background) {
        public string Presentation { get; set; } = presentation;
        public Color Background { get; set; } = background;
        public Color Foreground { get; set; } = foreground; 

        public Glyph() : this(" ", Color.Black, Color.Black)
        {}
    }
}

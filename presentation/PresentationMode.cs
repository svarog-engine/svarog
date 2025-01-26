namespace svarog.presentation
{
    public enum EPresentationMode
    {
        Font,
        Sprite,
    }

    public interface IPresentationMode
    {
        public EPresentationMode Type { get; }
    }

    public class FontPresentationMode : IPresentationMode
    {
        public EPresentationMode Type { get; } = EPresentationMode.Font;
        public string Font { get; set; }
        public int Size { get; set; }
        public bool Variable { get; set; }

        public FontPresentationMode(string font, int size, bool variable)
        {
            Font = font;
            Size = size;
            Variable = variable;
        }
    }

    public class SpritePresentationMode : IPresentationMode
    {
        public string Font { get; set; }
        public int Size { get; set; }
        public int Row { get; set; }
        public EPresentationMode Type { get; } = EPresentationMode.Sprite;

        public SpritePresentationMode(string font, int size, int row)
        {
            Font = font;
            Size = size;
            Row = row;
        }
    }
}

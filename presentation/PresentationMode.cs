namespace svarog.presentation
{
    public enum EPresentationMode
    {
        Sprite,
    }

    public interface IPresentationMode
    {
        public EPresentationMode Type { get; }
    }

    public class SpritePresentationMode : IPresentationMode
    {
        public string Font { get; set; }
        public int Size { get; set; }
        public int PaddingX { get; set; }
        public int PaddingY { get; set; }
        public int OffsetX { get; set; }
        public int OffsetY { get; set; }

        public EPresentationMode Type { get; } = EPresentationMode.Sprite;

        public SpritePresentationMode(string font, int size, int paddingX = 0, int paddingY = 0, int offsetX = 0, int offsetY = 0)
        {
            Font = font;
            Size = size;
            PaddingX = paddingX;
            PaddingY = paddingY;
            OffsetX = offsetX;
            OffsetY = offsetY;
        }
    }
}

namespace svarog.utility
{
    public class BoolMap : IMap<bool, BoolMap>
    {
        private readonly int m_Width;
        private readonly int m_Height;
        private readonly bool[,] m_Map;

        public bool[,] Values => m_Map;
        public int Width => m_Width;
        public int Height => m_Height;

        public BoolMap(int width, int height, bool value = false)
        {
            m_Width = width;
            m_Height = height;
            m_Map = new bool[width, height];
            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    m_Map[i, j] = value;
                }
            }
        }

        public BoolMap Create(int w, int h)
        {
            return new BoolMap(w, h);
        }
    }
}

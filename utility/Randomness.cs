using svarog.runner;

namespace svarog.utility
{
    public class Randomness
    {
        public static readonly Randomness Instance = new();

        private static readonly string ALPHABET = "thequickbrownfoxjumpsoverthelazydog.,;[]()";

        public Randomness()
        {
            m_Seed = (int)DateTime.Now.Ticks;
            Internal = new(m_Seed);
        }

        private System.Random Internal;

        private int m_Seed;
        public bool Coin() => Internal.Next(100) >= 50;
        public float F01() => Internal.NextSingle();
        public int Range(int min, int max) => min + Internal.Next(max);
        public string From(string ts) => ts[Range(0, ts.Length)].ToString();
        public T From<T>(T[] ts) => ts[Range(0, ts.Length)];
        public T From<T>(List<T> ts) => ts[Range(0, ts.Count)];
        public string Char() => From(ALPHABET);
        public void Shuffle<T>(IList<T> ts)
        {
            var count = ts.Count;
            var last = count - 1;
            for (var i = 0; i < last; ++i)
            {
                var r = Range(i, count - i);
                var tmp = ts[i];
                ts[i] = ts[r];
                ts[r] = tmp;
            }
        }

        public int Seed => m_Seed;

        public RandomnessBag Bag(int truesInBag, int bagSize)
        {
            return new RandomnessBag(truesInBag, bagSize);
        }
    }

    public class RandomnessBag
    {
        private int m_NumberOfTrue;
        private int m_TruesInBag;
        private int m_NumberOfGuesses;
        private int m_BagSize;

        public RandomnessBag(int truesInBag, int bagSize) 
        {
            m_TruesInBag = truesInBag;
            m_NumberOfTrue = 0;
            m_NumberOfGuesses = 0;
            m_BagSize = bagSize;
        }

        public bool MakeGuess()
        {
            if(m_NumberOfGuesses == m_BagSize)
            {
                m_NumberOfGuesses = 0;
                m_NumberOfTrue = 0;
            }

            if (m_TruesInBag == m_NumberOfTrue)
            {
                m_NumberOfGuesses++;
                return false;
            }
            else
            {
                bool coin = Svarog.Instance.Random.Coin();
                if (coin)
                {
                    m_NumberOfTrue++;
                    m_NumberOfGuesses++;
                    return true;
                }
                else
                {
                    if (m_NumberOfGuesses - m_NumberOfTrue == m_BagSize - m_TruesInBag)
                    {
                        m_NumberOfTrue++;
                        m_NumberOfGuesses++;
                        return true;
                    }
                    else
                    {
                        m_NumberOfGuesses++;
                        return false;
                    }
                }
            }
        }
    }
}

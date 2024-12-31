using SFML.System;

namespace svarog.src.tools
{
    public enum EFontCase
    {
        OnlyLowercase,
        OnlyUppercase,
        FullCases,
    }

    public class GlyphFont
    {
        private Dictionary<char, int> m_LetterMapping = new();
        private EFontCase m_FontCase = EFontCase.FullCases;
        private Pattern m_Pattern;

        public Pattern Pattern => m_Pattern;
        public EFontCase FontCase => m_FontCase;
        public Dictionary<char, int> LetterMapping => m_LetterMapping;

        public GlyphFont(Svarog svarog, string pattern, string mapping, EFontCase cases = EFontCase.FullCases) 
        {
            m_Pattern = svarog.ToolBox.GetPattern(pattern);
            
            int i = 0;
            foreach (var m in mapping)
            {
                m_LetterMapping[m] = i++;
            }
        }
    }
}

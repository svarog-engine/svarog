using ParsecSharp;

using static ParsecSharp.Parser;
using static ParsecSharp.Text;

namespace svarog.procgen
{
    public record struct AnnotatedId(string Id, string Annotation);
    public record struct Arrow(AnnotatedId Src, string Name, AnnotatedId Tgt);
    public record struct Chain(Arrow[] Arrows);
    public record struct Transform(Chain[] Lhs, Variant[] Rhs);
    public record struct Variant(Chain[] Variants);
    public record struct Procedure(string Name, Transform Transform);
    public class PcgParser
    {
        static Arrow[] ConstructChainFromPostConnections(AnnotatedId id, IReadOnlyCollection<(string, AnnotatedId)> conns)
        {
            AnnotatedId src = id;
            List<Arrow> arrows = new();

            if (conns.Count > 0)
            {
                foreach (var (arr, tgt) in conns)
                {
                    arrows.Add(new(src, arr, tgt));
                    src = tgt;
                }
            }
            else
            {
                arrows.Add(new(src, "-id-", src));
            }
            return [.. arrows];
        }

        readonly IParser<char, Unit> Whitespace = SkipMany(OneOf(" \t\n\r"));
        IParser<char, char> Comma => Char(',').Between(Whitespace);
        IParser<char, char> Turns => Char(':').Between(Whitespace);
        IParser<char, char> Other => Char('|').Between(Whitespace);
        IParser<char, string> Id => Many(AsciiLetter().AsString().Or(String("#"))).Join().Between(Whitespace);
        IParser<char, string> Hole =>
            from _1 in Char('_')
            from n in Many1(Digit())
            select $"_{string.Join("", n)}";
        IParser<char, string> Annotation =>
            from _1 in Char('[')
            from n in Id
            from _2 in Char(']')
            select n;
        IParser<char, AnnotatedId> AnnotatedId =>
            from id in Hole.Between(Whitespace).Or(Id)
            from ann in Optional(Annotation.Map(id => id), "-").Between(Whitespace)
            select new AnnotatedId(id, ann);
        IParser<char, string> Arrow =>
            from _1 in Char('-')
            from name in Optional(Id.Map(id => id), "-").Between(Whitespace)
            from _2 in String("->").Between(Whitespace)
            select name;
        IParser<char, (string, AnnotatedId)> PostConnection =>
            from arr in Arrow.Between(Whitespace)
            from id2 in AnnotatedId.Between(Whitespace)
            select (arr, id2);
        IParser<char, Chain> AnnotatedIdChain =>
            from id in AnnotatedId.Between(Whitespace)
            from conns in Many(PostConnection.Between(Whitespace)).Between(Whitespace)
            select new Chain(ConstructChainFromPostConnections(id, conns));
        IParser<char, Chain[]> AnnotatedIdChains =>
            from chains in AnnotatedIdChain.SeparatedBy(Comma.Between(Whitespace)).Between(Whitespace)
            select chains.ToArray();
        IParser<char, Variant> RhsVariants =>
            from chains in AnnotatedIdChains.Between(Whitespace)
            select new Variant([.. chains]);

        IParser<char, Transform> Transform =>
            from lhs in AnnotatedIdChains
            from _ in Turns
            from rhs in RhsVariants.SeparatedBy(Other.Between(Whitespace)).Between(Whitespace)
            select new Transform(lhs, [.. rhs]);
        IParser<char, Procedure> Procedure =>
            from _1 in Char('(').Between(Whitespace)
            from id in Many(AsciiLetter().Or(Char('-'))).Between(Whitespace)
            from _2 in Char(')').Between(Whitespace)
            from transform in Transform.Between(Whitespace)
            from _3 in Char(';').Between(Whitespace)
            select new Procedure(string.Join("", id), transform);
        IParser<char, Procedure[]> Procedures =>
            from procs in Many(Procedure).Between(Whitespace)
            select procs.ToArray();

        public void Parse(string text)
        {
            var e = Procedures.Parse(text);
            Console.WriteLine(e);
        }
    }
}

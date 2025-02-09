namespace svarog.procgen.rewriting
{
    public interface IPcgAction
    { }

    public record struct PcgAction_UpdateNode(string Name, string? Annotation) : IPcgAction;
    public record struct PcgAction_CreateNode(string Name, string? Annotation) : IPcgAction;
    public record struct PcgAction_CreateArrow(string Src, string Tgt, int Index, string? Name) : IPcgAction;
}

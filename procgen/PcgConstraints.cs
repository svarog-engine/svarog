namespace svarog.procgen
{
    public interface IPcgConstraint
    {}

    public record struct PcgConstraint_NodeExists(string Name, string? Annotation) : IPcgConstraint;
    public record struct PcgConstraint_ConnectionExists(string Src, string Tgt, int Index, string? Name) : IPcgConstraint;
    public record struct PcgConstraint_ConnectionDoesntExist(string Src, string Tgt, string? Name) : IPcgConstraint;
    public record struct PcgConstraint_NodeHasOutDegreeAtLeast(string Name, int Degree) : IPcgConstraint;
    public record struct PcgConstraint_NodeHasInDegreeAtLeast(string Name, int Degree) : IPcgConstraint;
}

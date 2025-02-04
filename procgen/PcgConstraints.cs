namespace svarog.procgen
{
    public interface IPcgConstraints
    {}

    public record struct PcgConstraint_NodeExists(string Name, string? Annotation) : IPcgConstraints;
    public record struct PcgConstraint_ConnectionExists(string Src, string Tgt, string? Name) : IPcgConstraints;
    public record struct PcgConstraint_ConnectionDoesntExist(string Src, string Tgt, string? Name) : IPcgConstraints;
    public record struct PcgConstraint_NodeHasOutDegreeAtLeast(string Name, int Degree) : IPcgConstraints;
    public record struct PcgConstraint_NodeHasInDegreeAtLeast(string Name, int Degree) : IPcgConstraints;
}

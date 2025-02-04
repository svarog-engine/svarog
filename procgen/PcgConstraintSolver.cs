namespace svarog.procgen
{
    public record struct PcgBinding(string Name, uint StoredId);
    public record struct PcgSolution(PcgBinding[] Bindings);
    public class PcgConstraintSolver
    {
        public PcgSolution[] Solve(PcgGraphStorage storage, IReadOnlyCollection<IPcgConstraints> constraints)
        {
            List<PcgSolution> solutions = [];

            List<PcgBinding> bindings = [];
            Dictionary<string, HashSet<uint>> nodeCandidates = new();

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_NodeExists))
            {
                var nc = ((PcgConstraint_NodeExists)constraint);
                nodeCandidates.Add(nc.Name, []);

                foreach (var i in storage.Nodes)
                {
                    if ((nc.Annotation != null && storage.HasAnnotation(i, nc.Annotation)) || nc.Annotation == null)
                    {
                        nodeCandidates[nc.Name].Add(i);
                    }

                    if (nodeCandidates[nc.Name].Count == 0) return [];
                }
            }

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_NodeHasInDegreeAtLeast))
            {
                var ci = ((PcgConstraint_NodeHasInDegreeAtLeast)constraint);
                nodeCandidates[ci.Name].RemoveWhere(id => storage.GetInDegree(id) < ci.Degree);
                if (nodeCandidates[ci.Name].Count == 0) return [];
            }

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_NodeHasOutDegreeAtLeast))
            {
                var ci = ((PcgConstraint_NodeHasOutDegreeAtLeast)constraint);
                nodeCandidates[ci.Name].RemoveWhere(id => storage.GetOutDegree(id) < ci.Degree);
                if (nodeCandidates[ci.Name].Count == 0) return [];
            }

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_ConnectionExists))
            {
                var ce = ((PcgConstraint_ConnectionExists)constraint);
                if (ce.Name != null)
                {
                    if (storage.CountArrowsCalled(ce.Name) == 0) return [];

                    var srcs = storage.GetArrowsCalled(ce.Name).Select(conn => PcgGraphStorage.ExtractNodeIds(conn).Item1).ToHashSet();
                    var tgts = storage.GetArrowsCalled(ce.Name).Select(conn => PcgGraphStorage.ExtractNodeIds(conn).Item2).ToHashSet();
                    nodeCandidates[ce.Src].RemoveWhere(id => !srcs.Contains(id));
                    nodeCandidates[ce.Tgt].RemoveWhere(id => !tgts.Contains(id));
                }
                else
                {
                    var allPossibleTargets = nodeCandidates[ce.Src]
                        .SelectMany(src => storage.GetArrowsFrom(src)
                            .Select(arr => PcgGraphStorage.ExtractNodeIds(storage.GetEndpoints(arr)).Item2));
                        
                    if (allPossibleTargets.Intersect(nodeCandidates[ce.Tgt]).Count() == 0)
                    {
                        return [];
                    }
                }
            }

            // TODO: make solutions here
            return solutions.ToArray();
        }
    }
}

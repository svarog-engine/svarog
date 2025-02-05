using Universal.Common;
using Universal.Common.Collections;

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
            Dictionary<string, List<uint>> nodeCandidates = new();

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_NodeExists))
            {
                var nc = ((PcgConstraint_NodeExists)constraint);
                if (!nodeCandidates.ContainsKey(nc.Name))
                {
                    nodeCandidates.Add(nc.Name, []);
                }

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

                    var srcs = storage.GetArrowsCalled(ce.Name).Select(conn => PcgGraphStorage.ExtractNodeIds(conn).Item1).Distinct();
                    var tgts = storage.GetArrowsCalled(ce.Name).Select(conn => PcgGraphStorage.ExtractNodeIds(conn).Item2).Distinct();
                    nodeCandidates[ce.Src].RemoveWhere(id => !srcs.Contains(id));
                    if (nodeCandidates[ce.Src].Count == 0) return [];
                    nodeCandidates[ce.Tgt].RemoveWhere(id => !tgts.Contains(id));
                    if (nodeCandidates[ce.Tgt].Count == 0) return [];
                }
                else
                {
                    var allPossibleTargets = nodeCandidates[ce.Src]
                        .SelectMany(src => storage.GetArrowsFrom(src)
                            .Select(arr => storage.GetTarget(arr))).Distinct();
                        
                    if (allPossibleTargets.Intersect(nodeCandidates[ce.Tgt]).Count() == 0)
                    {
                        return [];
                    }
                }
            }

            Dictionary<(string, string, int), List<uint>> arrowCandidates = [];
            MultiDictionary<uint, (string, string, int)> revArrowCandidates = [];

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_ConnectionExists))
            {
                var ce = ((PcgConstraint_ConnectionExists)constraint);
                var key = (ce.Src, ce.Tgt, ce.Index);
                arrowCandidates[key] = [];

                foreach (uint src in nodeCandidates[ce.Src])
                {
                    foreach (uint arr in storage.GetArrowsFrom(src))
                    {
                        var tgt = storage.GetTarget(arr);
                        if (nodeCandidates[ce.Tgt].Contains(tgt))
                        {
                            arrowCandidates[key].Add(arr);
                            revArrowCandidates.Add(arr, key);
                        }
                    }
                }

                if (arrowCandidates[key].Count == 0)
                {
                    return [];
                }
            }

            var arrowKeys = arrowCandidates.Keys.ToArray();
            Dictionary<(string, string, int), int> arrowCandidateIndexing = [];
            Dictionary<(string, string, int), int> arrowCandidateMax = [];
            HashSet<uint> usedArrows = [];
            HashSet<uint> usedNodes = [];
            Dictionary<(string, string, int), uint> arrowTempBindings = [];
            Dictionary<string, uint> tempBindings = [];

            for (int i = 0; i < arrowKeys.Length; i++)
            {
                arrowCandidateIndexing[arrowKeys[i]] = 0;
                arrowCandidateMax[arrowKeys[i]] = arrowCandidates[arrowKeys[i]].Count;
            }

            var nodeKeys = nodeCandidates.Keys.ToArray();
            Dictionary<string, int> candidateIndexing = [];
            Dictionary<string, int> candidateMax = [];

            for (int i = 0; i < nodeKeys.Length; i++)
            {
                candidateIndexing[nodeKeys[i]] = 0;
                candidateMax[nodeKeys[i]] = nodeCandidates[nodeKeys[i]].Count;
            }

            // name reuse doesn't work! a, when mentioned again, shouldn't be reintroduction but reusal, and is okay!
            RecurseSolveArrows(ref solutions, ref storage, ref nodeCandidates, ref arrowCandidates, ref revArrowCandidates, ref arrowKeys, ref usedArrows, ref usedNodes, ref arrowTempBindings, ref tempBindings, 0);
            RecurseSolve(ref solutions, ref storage, ref nodeCandidates, ref nodeKeys, ref usedNodes, ref tempBindings, 0);

            return [.. solutions];
        }

        public void RecurseSolveArrows(
            ref List<PcgSolution> solutions,
            ref PcgGraphStorage storage,
            ref Dictionary<string, List<uint>> nodeCandidates,
            ref Dictionary<(string, string, int), List<uint>> arrowCandidates,
            ref MultiDictionary<uint, (string, string, int)> revArrowCandidates,
            ref (string, string, int)[] keys,
            ref HashSet<uint> usedArrows,
            ref HashSet<uint> usedNodes,
            ref Dictionary<(string, string, int), uint> arrowTempBindings,
            ref Dictionary<string, uint> tempBindings,
            int index)
        {
            if (index < keys.Length)
            {
                var key = keys[index];
                foreach (var cand in arrowCandidates[key])
                {
                    if (!usedArrows.Contains(cand))
                    {
                        foreach (var (src, tgt, id) in revArrowCandidates[cand])
                        {
                            foreach (var candSrc in nodeCandidates[src])
                            {
                                if (!usedNodes.Contains(candSrc))
                                {
                                    tempBindings[src] = candSrc;
                                    usedNodes.Add(candSrc);

                                    foreach (var candTgt in nodeCandidates[tgt])
                                    {
                                        if (!usedNodes.Contains(candTgt))
                                        {
                                            tempBindings[tgt] = candTgt;
                                            usedNodes.Add(candTgt);

                                            usedArrows.Add(cand);
                                            arrowTempBindings[(src, tgt, id)] = cand;

                                            RecurseSolveArrows(ref solutions, ref storage, ref nodeCandidates, ref arrowCandidates, ref revArrowCandidates, ref keys, ref usedArrows, ref usedNodes, ref arrowTempBindings, ref tempBindings, index + 1);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                var list = new List<PcgBinding>();
                foreach (var bind in tempBindings)
                {
                    list.Add(new PcgBinding(bind.Key, bind.Value));
                }
                solutions.Add(new PcgSolution([.. list]));
            }
        }

        public void RecurseSolve(
            ref List<PcgSolution> solutions,
            ref PcgGraphStorage storage, 
            ref Dictionary<string, List<uint>> nodeCandidates, 
            ref string[] keys,
            ref HashSet<uint> usedNodes,
            ref Dictionary<string, uint> tempBindings,
            int index)
        {
            if (index < keys.Length)
            {
                var key = keys[index];
                foreach (var cand in nodeCandidates[key])
                {
                    if (!usedNodes.Contains(cand))
                    {
                        tempBindings[key] = cand;
                        usedNodes.Add(cand);
                        RecurseSolve(ref solutions, ref storage, ref nodeCandidates, ref keys, ref usedNodes, ref tempBindings, index + 1);
                        usedNodes.Remove(cand);
                    }
                }
            }
            else
            {
                var list = new List<PcgBinding>();
                foreach (var bind in tempBindings)
                {
                    list.Add(new PcgBinding(bind.Key, bind.Value));
                }
                solutions.Add(new PcgSolution([.. list]));
            }
        }
    }
}

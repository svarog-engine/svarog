using System.Reflection;

using Universal.Common;
using Universal.Common.Collections;

namespace svarog.procgen
{
    public record struct PcgBinding(string Name, uint StoredId);
    public record struct PcgSolution(PcgBinding[] Bindings);
    public class PcgConstraintSolver
    {
        public PcgSolution[] Solve(PcgGraphStorage storage, IReadOnlyCollection<IPcgConstraint> constraints)
        {
            List<PcgSolution> solutions = [];

            List<PcgBinding> bindings = [];
            Dictionary<string, List<uint>> nodeCandidates = new();
            Dictionary<(string, string), HashSet<string>> noArrowsBetween = [];

            foreach (var constraint in constraints.Where(c => c is PcgConstraint_ConnectionDoesntExist))
            {
                var de = (PcgConstraint_ConnectionDoesntExist)constraint;
                var key = (de.Src, de.Tgt);
                if (!noArrowsBetween.ContainsKey(key))
                {
                    noArrowsBetween[key] = [];
                }

                if (de.Name != "" && de.Name != null)
                {
                    noArrowsBetween[key].Add(de.Name);
                }
            }

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
                }

                if (nodeCandidates[nc.Name].Count == 0) return [];
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
                var ce = (PcgConstraint_ConnectionExists)constraint;
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

            RecurseSolveArrows(ref solutions, ref storage, ref nodeCandidates, ref arrowCandidates, ref revArrowCandidates, ref arrowKeys, ref usedArrows, ref usedNodes, ref arrowTempBindings, ref tempBindings, ref noArrowsBetween, 0);

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
            ref Dictionary<(string, string), HashSet<string>> noArrowsBetween,
            int index)
        {
            if (index < keys.Length)
            {
                var (srcName, tgtName, id) = keys[index];
                foreach (var cand in arrowCandidates[keys[index]])
                {
                    if (!usedArrows.Contains(cand))
                    {
                        var (src, tgt) = PcgGraphStorage.ExtractNodeIds(storage.GetEndpoints(cand));
                        if (noArrowsBetween.TryGetValue((srcName, tgtName), out var set))
                        {
                            var name = storage.GetArrowName(cand);
                            if (set.Count == 0 || (name != null && set.Contains(name)))
                            {
                                continue;
                            }
                        }

                        usedArrows.Add(cand);
                        arrowTempBindings.Add(keys[index], cand);

                        bool goOn = true;
                        if (!usedNodes.Contains(src))
                        {
                            if (tempBindings.ContainsKey(srcName) && tempBindings[srcName] != src)
                            {
                                goOn = false;
                            }
                            else
                            {
                                tempBindings.Add(srcName, src);
                                usedNodes.Add(src);
                            }
                        }
                        else if (tempBindings.ContainsKey(srcName) && tempBindings[srcName] != src)
                        {
                            goOn = false;
                        }

                        if (!usedNodes.Contains(tgt) && goOn)
                        {
                            if (tempBindings.ContainsKey(tgtName) && tempBindings[tgtName] != tgt)
                            {
                                goOn = false;
                            }
                            else
                            {
                                tempBindings.Add(tgtName, tgt);
                                usedNodes.Add(tgt);
                            }
                        }
                        else if (tempBindings.ContainsKey(tgtName) && tempBindings[tgtName] != tgt)
                        {
                            goOn = false;
                        }

                        if (goOn)
                            RecurseSolveArrows(ref solutions, ref storage, ref nodeCandidates, ref arrowCandidates, ref revArrowCandidates, ref keys, ref usedArrows, ref usedNodes, ref arrowTempBindings, ref tempBindings, ref noArrowsBetween, index + 1);

                        tempBindings.Remove(srcName);
                        tempBindings.Remove(tgtName);
                        usedNodes.Remove(src);
                        usedNodes.Remove(tgt);

                        arrowTempBindings.Remove(keys[index]);
                        usedArrows.Remove(cand);
                    }
                }
            }
            else
            {
                if (tempBindings.Count < nodeCandidates.Keys.Count)
                {
                    List<string> missing = new();
                    foreach (var key in nodeCandidates.Keys)
                    {
                        if (!tempBindings.ContainsKey(key))
                        {
                            missing.Add(key);
                        }
                    }
                    RecurseSolve(ref solutions, ref storage, ref nodeCandidates, missing, ref usedNodes, ref tempBindings, ref arrowTempBindings, ref noArrowsBetween, 0);
                }
                else
                {
                    ValidateSolutions(storage, tempBindings, arrowTempBindings, ref solutions, ref noArrowsBetween);
                }
            }
        }

        public void RecurseSolve(
            ref List<PcgSolution> solutions,
            ref PcgGraphStorage storage, 
            ref Dictionary<string, List<uint>> nodeCandidates, 
            List<string> missing,
            ref HashSet<uint> usedNodes,
            ref Dictionary<string, uint> tempBindings,
            ref Dictionary<(string, string, int), uint> arrowTempBindings,
            ref Dictionary<(string, string), HashSet<string>> noArrowsBetween,
            int index)
        {
            if (index < missing.Count)
            {
                var key = missing[index];
                foreach (var cand in nodeCandidates[key])
                {
                    if (!usedNodes.Contains(cand))
                    {
                        tempBindings[key] = cand;
                        usedNodes.Add(cand);
                        RecurseSolve(ref solutions, ref storage, ref nodeCandidates, missing, ref usedNodes, ref tempBindings, ref arrowTempBindings, ref noArrowsBetween, index + 1);
                        usedNodes.Remove(cand);
                        tempBindings.Remove(key);
                    }
                }
            }
            else
            {
                ValidateSolutions(storage, tempBindings, arrowTempBindings, ref solutions, ref noArrowsBetween);
            }
        }

        public void ValidateSolutions(
            PcgGraphStorage storage,
            Dictionary<string, uint> tempBindings,
            Dictionary<(string, string, int), uint> arrowTempBindings,
            ref List<PcgSolution> solutions,
            ref Dictionary<(string, string), HashSet<string>> noArrowsBetween)
        {
            bool invalid = false;

            foreach (var key in noArrowsBetween.Keys)
            {
                var (src, tgt) = key;
                if (storage.HasConnBetween(tempBindings[src], tempBindings[tgt]))
                {
                    if (noArrowsBetween[key].Count == 0)
                    {
                        invalid = true;
                        break;
                    }
                    else if (noArrowsBetween[key].Intersect(storage.GetNamesBetween(tempBindings[src], tempBindings[tgt])).ToList().Count > 0)
                    {
                        invalid = true;
                        break;
                    }
                }
            }

            var list = new List<PcgBinding>();
            foreach (var bind in tempBindings)
            {
                list.Add(new PcgBinding(bind.Key, bind.Value));
            }

            foreach (var bind in arrowTempBindings)
            {
                var (src, tgt, id) = bind.Key;
                if (noArrowsBetween.ContainsKey((src, tgt)))
                {
                    invalid = true;
                }
                var key = $"{src}_{tgt}_{id}";
                var (a, b) = PcgGraphStorage.ExtractNodeIds(storage.GetEndpoints(bind.Value));
                if (tempBindings[src] != a || tempBindings[tgt] != b)
                {
                    invalid = true;
                }
                list.Add(new PcgBinding(key, bind.Value));
            }
            if (!invalid)
            {
                solutions.Add(new PcgSolution([.. list]));
            }
        }
    }
}
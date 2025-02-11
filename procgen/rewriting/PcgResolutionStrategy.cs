using svarog.runner;
using svarog.utility;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Channels;
using System.Threading.Tasks;

using Universal.Common.Collections;

namespace svarog.procgen.rewriting
{
    public interface IPcgResolutionStrategy
    {
        bool Resolve(PcgGraphStorage storage, List<IPcgConstraint> constraints, List<IPcgAction>[] branches);
    }

    public class PcgResolution_RandomPick : IPcgResolutionStrategy
    {
        PcgConstraintSolver m_Solver = new();

        private bool Solve(PcgSolution pattern, PcgGraphStorage storage, List<IPcgConstraint> constraints, List<IPcgAction>[] branches)
        {
            bool changes = false;
            var change = branches[Randomness.Instance.Range(0, branches.Length)];
            Dictionary<(string, string), List<string>> availableUnnamedArrows = [];
            HashSet<string> unusedArrows = [];
            Dictionary<string, string> arrowBindings = [];

            Dictionary<string, uint> bindings = [];
            foreach (var b in pattern.Bindings)
            {
                if (b.Name.Contains('_')) // arrow
                {
                    var ps = b.Name.Split('_');
                    var src = ps[0];
                    var tgt = ps[1];
                    var id = int.Parse(ps[2]);
                    if (!availableUnnamedArrows.ContainsKey((src, tgt)))
                    {
                        unusedArrows.Add(b.Name);
                        availableUnnamedArrows[(src, tgt)] = [];
                    }
                    availableUnnamedArrows[(src, tgt)].Add(b.Name);
                }
                bindings.Add(b.Name, b.StoredId);
            }

            foreach (var a in availableUnnamedArrows.Keys)
            {
                Randomness.Instance.Shuffle(availableUnnamedArrows[a]);
            }

            foreach (var c in change.Where(c => c is PcgAction_UpdateNode))
            {
                var un = (PcgAction_UpdateNode)c;
                if (!bindings.ContainsKey(un.Name))
                {
                    Svarog.Instance.LogError($"Unknown node in right-hand side expression: {un.Name}");
                    return false;
                }
                else
                {
                    if (un.Annotation != null)
                    {
                        Svarog.Instance.LogVerbose($"Changing node {un.Name} ({bindings[un.Name]})'s annotation to: {un.Annotation}");
                        changes = true;
                        storage.ChangeAnnotation(bindings[un.Name], un.Annotation);
                    }
                }
            }

            foreach (var c in change.Where(c => c is PcgAction_CreateNode))
            {
                var cn = (PcgAction_CreateNode)c;
                bindings[cn.Name] = storage.AddNode(cn.Annotation);
                changes = true;
                Svarog.Instance.LogVerbose($"Creating node {cn.Name} ({bindings[cn.Name]}) with annotation {cn.Annotation ?? "-"}");
            }

            foreach (var c in change.Where(c => c is PcgAction_CreateArrow))
            {
                var cn = (PcgAction_CreateArrow)c;
                var src = cn.Src;
                var tgt = cn.Tgt;

                if (availableUnnamedArrows.ContainsKey((src, tgt)))
                {
                    var first = availableUnnamedArrows[(src, tgt)].First();
                    Svarog.Instance.LogVerbose($"Found candidate arrow for {src}_{tgt}_{cn.Index} in {first}");
                    availableUnnamedArrows[(src, tgt)].RemoveAt(0);
                    if (availableUnnamedArrows[(src, tgt)].Count == 0)
                    {
                        arrowBindings[$"{src}_{tgt}_{cn.Index}"] = first;
                        availableUnnamedArrows.Remove((src, tgt));
                        unusedArrows.Remove(first);
                    }

                    if (cn.Name != null)
                    {
                        Svarog.Instance.LogVerbose($"Changing arrow {first} (#{bindings[first]})'s name to {cn.Name}");
                        changes = true;
                        storage.ChangeArrowName(bindings[first], cn.Name);
                    }
                }
                else
                {
                    var newArrow = storage.AddConn(bindings[src], bindings[tgt], cn.Name);
                    Svarog.Instance.LogVerbose($"Adding arrow {src}_{tgt}_{cn.Index} (#{newArrow})");
                    changes = true;
                    bindings.Add($"{src}_{tgt}_{cn.Index}", newArrow);
                }
            }

            foreach (var arr in unusedArrows)
            {
                Svarog.Instance.LogVerbose($"Removing unused arrow {arr} (#{bindings[arr]})");
                changes = true;
                storage.DeleteConn(bindings[arr]);
            }

            return changes;
        }

        public bool Resolve(PcgGraphStorage storage, List<IPcgConstraint> constraints, List<IPcgAction>[] branches)
        {
            var solutions = m_Solver.Solve(storage, constraints);
            if (solutions.Length > 0)
            {
                return Solve(solutions[Randomness.Instance.Range(0, solutions.Length)], storage, constraints, branches);
            }

            return false;
        }
    }
}

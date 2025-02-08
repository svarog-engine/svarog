using System.Diagnostics;

using Universal.Common;

namespace svarog.procgen
{
    public class PcgInterpreter<TResolve>(PcgGraphStorage m_Storage) where TResolve : IPcgResolutionStrategy, new()
    {        
        private void Incr(ref Dictionary<string, int> dict, string key)
        {
            if (!dict.ContainsKey(key))
            {
                dict[key] = 1;
            }
            else
            {
                dict[key]++;
            }
        }

        private List<IPcgConstraint> BuildConstraints(Chain[] expr)
        {
            Dictionary<string, int> inDegrees = [];
            Dictionary<string, int> outDegrees = [];
            Dictionary<(string, string), int> connectionCounts = [];
            HashSet<string> madeNodeNames = [];
            List<IPcgConstraint> constraints = [];

            foreach (var chain in expr)
            {
                foreach (var arrow in chain.Arrows)
                {
                    if (arrow.Name == "-id-")
                    {
                        if (!madeNodeNames.Contains(arrow.Src.Id) && arrow.Src.Id != "")
                        {
                            constraints.Add(new PcgConstraint_NodeExists(arrow.Src.Id, arrow.Src.Annotation == "-" ? null : arrow.Src.Annotation));
                            madeNodeNames.Add(arrow.Src.Id);
                        }
                        // no need to add target
                    }
                    else if (arrow.Name.StartsWith('!'))
                    {
                        var negName = arrow.Name.Substring(1).Trim();
                        if (!madeNodeNames.Contains(arrow.Src.Id))
                        {
                            constraints.Add(new PcgConstraint_NodeExists(arrow.Src.Id, arrow.Src.Annotation == "-" ? null : arrow.Src.Annotation));
                            madeNodeNames.Add(arrow.Src.Id);
                        }
                        if (!madeNodeNames.Contains(arrow.Tgt.Id))
                        {
                            constraints.Add(new PcgConstraint_NodeExists(arrow.Tgt.Id, arrow.Tgt.Annotation == "-" ? null : arrow.Tgt.Annotation));
                            madeNodeNames.Add(arrow.Tgt.Id);
                        }
                        constraints.Add(new PcgConstraint_ConnectionDoesntExist(arrow.Src.Id, arrow.Tgt.Id, negName == "" ? null : negName));
                    }
                    else if (arrow.Src.Id != "")
                    {
                        Incr(ref inDegrees, arrow.Src.Id);
                        Incr(ref outDegrees, arrow.Tgt.Id);
                        if (!madeNodeNames.Contains(arrow.Src.Id))
                        {
                            constraints.Add(new PcgConstraint_NodeExists(arrow.Src.Id, arrow.Src.Annotation == "-" ? null : arrow.Src.Annotation));
                            madeNodeNames.Add(arrow.Src.Id);
                        }
                        if (!madeNodeNames.Contains(arrow.Tgt.Id))
                        {
                            constraints.Add(new PcgConstraint_NodeExists(arrow.Tgt.Id, arrow.Tgt.Annotation == "-" ? null : arrow.Tgt.Annotation));
                            madeNodeNames.Add(arrow.Tgt.Id);
                        }
                        if (!connectionCounts.ContainsKey((arrow.Src.Id, arrow.Tgt.Id)))
                        {
                            connectionCounts[(arrow.Src.Id, arrow.Tgt.Id)] = 1;
                        }
                        else
                        {
                            connectionCounts[(arrow.Src.Id, arrow.Tgt.Id)]++;
                        }
                        constraints.Add(new PcgConstraint_ConnectionExists(arrow.Src.Id, arrow.Tgt.Id, connectionCounts[(arrow.Src.Id, arrow.Tgt.Id)], arrow.Name == "" ? null : arrow.Name));
                    }
                }
            }

            foreach (var inDeg in inDegrees)
            {
                constraints.Add(new PcgConstraint_NodeHasInDegreeAtLeast(inDeg.Key, inDeg.Value));
            }

            foreach (var outDeg in outDegrees)
            {
                constraints.Add(new PcgConstraint_NodeHasOutDegreeAtLeast(outDeg.Key, outDeg.Value));
            }

            return constraints;
        }

        private List<IPcgAction> BuildActions(Chain[] expr)
        {
            Dictionary<(string, string), int> connectionCounts = [];
            HashSet<string> madeNodeNames = [];
            List<IPcgAction> actions = new();

            foreach (var chain in expr)
            {
                foreach (var arrow in chain.Arrows)
                {
                    if (arrow.Name == "-id-")
                    {
                        if (!madeNodeNames.Contains(arrow.Src.Id))
                        {
                            if (arrow.Src.Id.StartsWith("_"))
                            {
                                actions.Add(new PcgAction_CreateNode(arrow.Src.Id, arrow.Src.Annotation == "-" ? null : arrow.Src.Annotation));
                            }
                            else
                            {
                                actions.Add(new PcgAction_UpdateNode(arrow.Tgt.Id, arrow.Tgt.Annotation == "-" ? null : arrow.Tgt.Annotation));
                            }
                            madeNodeNames.Add(arrow.Src.Id);
                        }
                        // no need to add target
                    }
                    else
                    {
                        if (!madeNodeNames.Contains(arrow.Src.Id))
                        {
                            if (arrow.Src.Id.StartsWith("_"))
                            {
                                actions.Add(new PcgAction_CreateNode(arrow.Src.Id, arrow.Src.Annotation == "-" ? null : arrow.Src.Annotation));
                            }
                            else
                            {
                                actions.Add(new PcgAction_UpdateNode(arrow.Src.Id, arrow.Src.Annotation == "-" ? null : arrow.Src.Annotation));
                            }
                            madeNodeNames.Add(arrow.Src.Id);
                        }

                        if (!madeNodeNames.Contains(arrow.Tgt.Id))
                        {
                            if (arrow.Tgt.Id.StartsWith("_"))
                            {
                                actions.Add(new PcgAction_CreateNode(arrow.Tgt.Id, arrow.Tgt.Annotation == "-" ? null : arrow.Tgt.Annotation));
                            }
                            else
                            {
                                actions.Add(new PcgAction_UpdateNode(arrow.Tgt.Id, arrow.Tgt.Annotation == "-" ? null : arrow.Tgt.Annotation));
                            }
                            madeNodeNames.Add(arrow.Tgt.Id);
                        }
                        if (!connectionCounts.ContainsKey((arrow.Src.Id, arrow.Tgt.Id)))
                        {
                            connectionCounts[(arrow.Src.Id, arrow.Tgt.Id)] = 1;
                        }
                        else
                        {
                            connectionCounts[(arrow.Src.Id, arrow.Tgt.Id)]++;
                        }
                        actions.Add(new PcgAction_CreateArrow(arrow.Src.Id, arrow.Tgt.Id, connectionCounts[(arrow.Src.Id, arrow.Tgt.Id)], arrow.Name == "" ? null : arrow.Name));
                    }
                }
            }

            return actions;
        }

        private List<IPcgAction>[] BuildVariantActions(Variant[] vars)
        {
            List<IPcgAction>[] branches = new List<IPcgAction>[vars.Length];
            int i = 0;
            foreach (var branch in vars)
            {
                branches[i++] = BuildActions(branch.Graph);
            }

            return branches;
        }

        public bool RunProc(string name, int reps)
        {
            var res = true;
            for (int i = 0; i < reps; i++)
            {
                res |= InternalRun(name);
            }
            return res;
        }

        public bool RunProc(string name)
        {
            PcgGraphStorage.ResetCycleLock();
            return InternalRun(name);
        }

        private bool InternalRun(string name)
        {
            PcgGraphStorage.ResetCycleLock();
            var proc = m_Storage.GetProc(name);
            if (proc.HasValue)
            {
                Console.WriteLine($"== {name} ===============");
                var constraints = BuildConstraints(proc.Value.Lhs);
                var branches = BuildVariantActions(proc.Value.Rhs);

                var result = new TResolve().Resolve(m_Storage, constraints, branches);
                return result;
            }
            else
            {
                Console.WriteLine($"Couldn't find proc {name}");
            }

            return false;
        }

        public void LoadProcs(string name)
        {
            m_Storage.LoadProcs(File.ReadAllText($"resources\\procgen\\{name}.pcg"));
        }

        public void EmitDot()
        {
            void Dot(string s)
            {
                var psi = new ProcessStartInfo
                {
                    FileName = "https://dreampuf.github.io/GraphvizOnline/?engine=dot#" + Uri.EscapeDataString("digraph G\n{\n\n\t" + string.Join("\n\t", s.Split("\n")) + "\n}"),
                    UseShellExecute = true
                };
                Process.Start(psi);
            }

            Dot(m_Storage.ToDot());
        }

        public void Clear()
        {
            m_Storage.Clear();
        }
    }
}

namespace svarog.procgen
{
    public class PcgInterpreter(PcgGraphStorage storage)
    {
        PcgGraphStorage m_Storage = storage;
        PcgConstraintSolver m_Solver = new();

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

        public void RunProc(string name)
        {
            var proc = m_Storage.GetProc(name);
            if (proc.HasValue)
            {
                Dictionary<string, int> inDegrees = [];
                Dictionary<string, int> outDegrees = [];
                Dictionary<(string, string), int> connectionCounts = [];
                HashSet<string> madeNodeNames = [];
                List<IPcgConstraints> constraints = [];
                foreach (var chain in proc.Value.Lhs) 
                {
                    foreach (var arrow in chain.Arrows)
                    {
                        if (arrow.Name == "-id-")
                        {
                            if (!madeNodeNames.Contains(arrow.Src.Id))
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
                        else
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

                m_Solver.Solve(m_Storage, constraints);
            }
        }
    }
}

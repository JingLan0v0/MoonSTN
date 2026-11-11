# Architecture and correctness boundaries

A constraint L <= t[to]-t[from] <= U contributes directed edges from->to of
weight U and to->from of weight -L. Missing bounds create no edge. Contradictory
intervals remain valid models whose result is inconsistent. Duplicate IDs are
rejected, while parallel constraints with distinct IDs are retained for evidence.

The network snapshots the caller's name/constraint arrays and stores only
validated immutable strings and scalar bounds. Public array getters copy data.
No recursive parser, solver or certificate traversal is used.

Bellman-Ford starts all distances at zero, equivalent to an implicit super-source.
It detects negative cycles in disconnected components as well as the anchored
component. A relaxation on round n supplies a predecessor chain; n predecessor
steps enter a cycle. Reversing its collected edges produces an ordered closed
walk. A separate verifier checks edge authenticity, adjacency and negative sum.
It does not trust a claimed status or forged numeric edge weight.

If feasible, subtract the first timepoint's potential from all potentials. This
preserves every difference and anchors that point at zero. verify_assignment
checks every original edge rather than recomputing the solver. It accepts any
complete feasible assignment within its documented proof-coordinate bound.

Floyd-Warshall on feasible networks computes tight all-pairs upper bounds.
Rows with no path from i to k skip their inner traversal while charging all V
logical triples in one operation. Reachable rows reuse the row references and
distance(i,k). This value stays fixed during a feasible closure iteration because
distance(k,k)=0 and no negative cycles remain. This preserves results and the
existing budget boundary; worst-case complexity is unchanged.
The lower bound for b-a is -distance(b,a). No path means unbounded, including
between disconnected components. Each requested bound is individually tight;
arbitrary choices of all pairwise extrema need not form one joint assignment.

Resource accounting charges each relaxation, closure triple, edge initialization
and cycle extraction step. Name validation and fixed input loops are bounded by
hard size caps, not individually metered. No CPU deadline or universal heap bound
is promised. Time complexity O(VE + V^3), memory O(V^2+E). Default budget covers
permitted sizes; callers can deliberately choose smaller budgets.

Numeric reasoning: original edge magnitude <= 10^6; at most 64 rounds * 1024
relaxations bounds pre-detection potential magnitude by 65,536,000,000. Feasible
shortest simple paths use <=63 edges. Closure never runs on negative-cycle graphs.
All arithmetic is well inside signed Int64 and the exact JSON binary64 integer
range. Public proof coordinates are limited to ±10^11 before subtraction.

Core files: model.mbt (validation/snapshots), solver.mbt (reasoning/certificates),
json.mbt (bounded exchange). cmd/main/host.mbt contains only Node I/O. JS test code
is an independent oracle and is not used by the runtime.

The exhaustive oracle enumerates 4^6 three-node networks; six directed arcs are
absent or weighted -1,0,1. It enumerates assignments with a=0 and b,c in [-4,4].
For this family, a feasible component has a potential span <=2; finite pairwise
extrema have magnitude <=2 and can be realized inside this enumeration window.
Reachability, independently of weights, distinguishes finite bounds from unbounded
ones. Every returned witness and ordered conflict is checked against input rules.
This does not establish exhaustive correctness for all 64-node networks.

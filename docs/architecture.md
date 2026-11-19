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

For numeric networks with 32–64 points and 4V–1,024 arcs, a changing first
Int64 pass can be followed by exact binary64 integer relaxation. The solver
rechecks weights against ±1,000,000 and packs each pair of endpoint indices
in two six-bit fields. After at most 64 × 1,024 attempted relaxations, a
candidate represents a sum of at most that many checked edges. Its
magnitude is below 2^36, within the exact integer range of binary64.
Values convert back to Int64 before normalization. The arc order, strict
comparison, predecessor updates and full per-pass work charge are retained.
Planning and caller-edited wider weights use Int64 relaxation.

If feasible, subtract the first timepoint's potential from all potentials. This
preserves every difference and anchors that point at zero. verify_assignment
checks every original edge rather than recomputing the solver. It accepts any
complete feasible assignment within its documented proof-coordinate bound.

Floyd-Warshall on feasible networks computes tight all-pairs upper bounds.
After feasibility is established, reserve the edge-initialization charge and
the fixed V^3 logical triples before allocating the distance matrix. The triple
count fits Int32 because V <= 64. An insufficient budget returns an error
before setup. Negative cycles use the separate certificate budget.
Rows with no path from i to k skip their inner traversal. Reachable rows reuse the row references and
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

Dense feasible graphs can use a flat Int32 closure matrix. The current
eligibility gate requires 32–64 points, at least four distinct off-diagonal
arcs per point on average and at most 1,024 arcs. The current edge weights
are rechecked against ±10^6. Every finite intermediate shortest path can
be simplified by removing nonnegative cycles. Its absolute weight is at
most 63 × 10^6, so a relaxation sum fits within ±126 × 10^6, below the
unreachable sentinel and within Int32. The diagonal stays zero. The solver
widening step returns the existing Int64 distances and unbounded markers.
For each pivot, the narrow loop collects its finite columns and weights
once and reuses that list for every other reachable row. Skipping the
pivot row preserves the list for the whole pass. Matrix and scratch
accesses use checked indices.
When the first row has at least `n / 4` adjacent equal finite distances
(using integer division), widening reuses the previous conversion within
each row. Otherwise each cell is converted directly. Both paths create
the same complete public matrix and preserve unreachable entries.
Inputs outside the gate use the Int64 closure, including caller-edited wide
edge weights. Both paths charge the same arc and closure work.

The numeric CLI serializes bounded analyzer responses by walking the result
tree directly in map insertion order. String values and keys use the core
JSON encoder when they contain a quote, backslash or control character.
The public analyzers return Json for library consumers. Planning CLI output
uses the core JSON serializer.

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


## Resource-aware planning layer (0.2.0)

Each task compiles to start/finish points plus duration, release and deadline rules.
A dependency picks its two endpoints from FS/SS/FF/SF and adds signed lag bounds.
The origin is the first point and the existing solver normalizes it to zero.

At a search node, solve the temporal conjunction. Inconsistency prunes that branch.
Otherwise inspect the witness for overlapping tasks sharing one fixed resource.
If none overlap, the witness satisfies the full model. If A and B overlap, every
valid plan must satisfy finish(A)<=start(B) OR finish(B)<=start(A), because durations
are strictly positive. Push both children and continue depth-first in input order.
This covers all feasible arrangements; if every child is pruned, the model is
unschedulable. An already ordered pair cannot overlap in a later feasible witness,
so a path adds at most T(T-1)/2 rules. There are at most 49 points and
3T + D + T(T-1)/2 <= 412 constraints, below the old STN hard limits. The iterative
DFS stack retains at most one sibling per decision level, rather than a breadth
of all possible permutations. Worst-case runtime remains exponential in pairs.

Planning runs the same Bellman–Ford relaxations and origin normalization as public
STN solving. A change on the last round prunes the branch. Planning only needs
the feasibility decision and witness, so it skips conflict certificate construction
and all-pairs closure.

Each plan call validates its base network and converts the edges to indexed arcs.
Sibling branches share the validated parent arcs until visited. A child validates
and appends one zero-weight ordering arc while retaining the original edge order.
The cap is 500 directed arcs at 24 tasks, 64 two-sided dependencies and 276 orders.

Before each branch, reserve n^3 + n*e + e + 2*n logical work, the conservative full
STN solve bound used in 0.2.0. Keeping the charge preserves the exact work thresholds
and charged_work diagnostics, including for early-pruned nodes. The global remaining
budget is checked before relaxation and node count is global. Exhaustion raises an
error with no feasibility conclusion.

verify_plan checks the original immutable task/dependency arrays directly and
never calls solve/plan. It rejects unknown/missing/duplicate task IDs, unsafe time
values before subtraction, window/duration violations, endpoint-lag violations and
half-open resource overlaps. It does not certify search statistics or UNSAT claims.
The JSON adapter validates schema and delegates to the same library functions.

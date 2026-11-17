# MoonSTN 0.2.0 — initial-review revision

The organizer notice supplied by the participant says the numeric temporal checks
have a use, but the dedicated core beyond general graph algorithms is too light.
This revision retains the repository and history, adding a task-planning layer.
It does not claim that the standard STN algorithms are novel or that additional
tests, packaging, or renaming alone address that criticism.

| Earlier 0.1.2 | Substantive 0.2.0 addition | Implementation and executable evidence |
|---|---|---|
| Caller manually supplies timepoints and difference edges | Validated immutable task model: duration ranges, windows, four typed-by-token dependency endpoint relations, fixed resource ownership | planning.mbt; examples/planning |
| One conjunction of temporal constraints | Resource nonoverlap is a disjunction; conflict-driven binary ordering search, temporal pruning, backtracking, whole-search budgets | plan; maintenance-plan.json requires the opposite ordering after pruning |
| Time-only feasible assignment | Complete task schedule respecting resource occupancy, independently checked against original task rules | verify_plan; forged schedule tests; independent enumeration oracle |
| Time-only contradiction | Resource-induced unschedulability when all order branches fail, separate from budget exhaustion | impossible-plan.json; one-node/work-limit tests |

New public APIs are planning_problem, plan, verify_plan, analyze_plan and
analyze_plan_batch. CLI --plan / --plan-batch use those same MoonBit functions;
Node only handles I/O. Old numeric-STN APIs and examples remain available.

Three synthetic operational workflows cover pipeline runner/deployment-lock
contention, database maintenance ordering and single-vehicle capacity conflict.
Each has an input file, runnable command and asserted output (docs/planning.md).
No real company deployment, runtime performance gain or optimality is asserted.

The new solver enumerates resource order decisions, not every timestamp. STN
propagation handles numeric intervals within each branch. Worst-case search is
exponential; limits can yield an error without a feasibility conclusion. This is
a standard disjunctive scheduling approach implemented for MoonBit, not a new
scheduling theory or a replacement for a general optimizer.

Independent validation enumerates all integer schedules for a defined family of
1,440 two-task models and 256 seeded three-task models, compares existence, and
checks returned witnesses. It covers all four dependency kinds, shared/no resource,
variable durations, windows, cycles and signed lags in the generated family.
The old 4,096-network checks remain. Finite tests do not establish universal proof.

The live MoonPlan README was re-read on 2026-11-17: its finite-domain staffing,
constraints and optimization already overlap with scheduling. The separate boundary
here is numeric task endpoints/duration intervals plus exclusive-resource order
search with existing STN bounds/conflict APIs. This is a focused alternative,
not a claim that MoonBit lacks scheduling or that this project is more capable.
See ecosystem.md and architecture.md for comparisons, limits and references.

Publication/test receipts are in acceptance.md; source CI and registry installation
must be recorded independently. The revision is prepared for organizer re-review;
qualification and final acceptance have not been granted.

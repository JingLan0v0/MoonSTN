# Changelog

## 0.2.31 — 2026-11-24

- Compute origin-relative planning values during schedule construction.
- Verify nonzero and disconnected origins, signed results and exact work budgets on edited models.

## 0.2.30 — 2026-11-23

- Record the next task for each shared resource once and reuse those links when scanning for conflicts.
- Check first-conflict order and exact budgets after caller edits to task resources.

## 0.2.29 — 2026-11-22

- Limit resource-order ID scans to IDs starting with `order` and retain the full rule count for limit checks.
- Verify edited root IDs, repeated ancestor orders, exact error precedence, and reuse after restoring the model.

## 0.2.28 — 2026-11-21

- Keep one arc array and one rule ID array along the active resource-order path and restore the parent's entries before visiting a sibling.
- Verify sibling backtracking at the 512-rule cap, exact budgets, and reuse after errors.

## 0.2.27 — 2026-11-21

- Reuse canonical task timepoint names in resource-order branches and convert each task position once per branch.
- Verify current name resolution for moved timepoints and caller-added task positions at exact budgets.

## 0.2.26 — 2026-11-21

- Precompute built-in timepoint and rule names for each supported task position.
- Verify all 24 task positions, exact rule bounds and schedule, and model isolation after caller edits.

## 0.2.25 — 2026-11-21

- Reuse existing timepoint names when constructing planning dependencies.
- Verify timepoint names, rule order, and exact lags for all four dependency kinds.

## 0.2.24 — 2026-11-20

- Reuse validated task positions when resolving planning dependency endpoints.
- Scan small task lists, long IDs, and early positions directly.
- Assert exact endpoint positions and validation order through the public planning API.

## 0.2.23 — 2026-11-20

- Collect planning dependency fields in one ordered pass before validating their values.
- Check missing, null, and present optional values, exact maximum lag, and task and dependency diagnostic order.

## 0.2.22 — 2026-11-20

- Check exact integer spellings by tracking the decimal point and last nonzero digit.
- Exercise negative zero, exponent saturation, long fractional tails, and caller-constructed JSON numbers.

## 0.2.21 — 2026-11-20

- Reuse numeric constraint field lookups and scan keys only when the recognized fields do not cover the object.
- Check missing and null bounds, original number spellings, and error order in mixed batches.

## 0.2.20 — 2026-11-20

- Scan ASCII names and IDs directly and size validation tables from the model.
- Detect duplicate constraint IDs during insertion and check both bounds without a temporary array.
- Verify constraint error order, two-sided cycle certificates, and exact work budgets in mixed batches.

## 0.2.19 — 2026-11-20

- Collect reachable pivot columns lazily in the wide closure.
- Verify signed bounds and unreachable pairs on a 64-point branching tree.

## 0.2.18 — 2026-11-20

- Charge numeric closure arc initialization and logical triples before
  allocating the distance matrix.
- Check exact and insufficient budgets across both matrix paths and
  negative-cycle certificate construction.

## 0.2.17 — 2026-11-20

- Traverse source characters directly in JSON resource preflight.
- Check exact input size, scan count, depth and Unicode string boundaries.

## 0.2.16 — 2026-11-19

- Resolve both fields of a two-field numeric query directly, with the
  original validation path for other shapes.
- Check error precedence, escaped duplicate query keys and batch recovery.

## 0.2.15 — 2026-11-19

- Write bounded numeric CLI result trees directly, using core JSON
  escaping for strings that need it.
- Check field order, numeric-looking names, unbounded intervals,
  escaped errors and recovery in one mixed CLI batch.

## 0.2.14 — 2026-11-19

- Pack arc endpoints and use exact binary64 integers after the first
  relaxation pass on eligible dense numeric networks.
- Preserve logical work charges and ordered original-edge certificates.
- Check potentials below the Int32 range and precise fallback for an
  edited edge beyond the binary64 exact-integer range.

## 0.2.13 — 2026-11-19

- Reuse Int64 conversions for adjacent equal distances when the narrow
  closure's first row has enough finite repeats.
- Check the complete public matrix for signed repeats and unreachable pairs.
- Benchmark repeated and varied closure results at 0, 4 and 256 JSON queries.

## 0.2.12 — 2026-11-19

- Reuse each flat Int32 pivot row's reachable columns and weights across
  its contributing rows.
- Check signed bounds across separated components and the exact closure
  budget at the narrow path's density threshold.

## 0.2.11 — 2026-11-19

- Index dense numeric arcs with a per-solve name map, and reuse the
  validated map for JSON requests.
- Cover edited names, duplicate-name lookup order and changed edges
  through the public numeric API.

## 0.2.10 — 2026-11-19

- Use a flat Int32 matrix for eligible dense numeric closure and convert
  distances back to the public Int64 representation.
- Test exact closure budgets with caller-edited wide edges and a 64-point
  path of length 63,000,000.

## 0.2.9 — 2026-11-19

- Skip a closure pivot row when its diagonal is zero and read each existing
  cell once. Keep the same logical closure budget.
- Compare 256 tight bounds on a signed 64-point network against an
  independent shortest-path calculation.

## 0.2.8 — 2026-11-19

- Resolve numeric JSON query endpoints once with the validated name index.
  Use those positions to read tight bounds in request order.
- Benchmark 256-query workloads and check output bytes, exact budgets,
  query error precedence and the ordered negative-cycle certificate.

## 0.2.7 — 2026-11-19

- Build schedule entries directly in their final JSON maps. The measured
  planning batches produce identical output bytes.
- Add a paired benchmark for result construction, serialization and peak
  process memory across successful and failed planning batches.

## 0.2.6 — 2026-11-19

- Check the exact source spelling of integer JSON fields. Fractional values
  that round to an integer or underflow to zero now produce a validation error.
- Accept decimal and exponent spellings whose value is an in-range integer.
  Preserve number spellings in the value returned by `parse_json`.

## 0.2.5 — 2026-11-19

- Compile indexed planning edges as constraints are validated, and reuse the
  same timepoint index for new ordering edges. Keep validation, scan order
  and budget charging consistent.
- Verify renamed timepoints in caller-edited models and benchmark maximum-size
  models with and without resource contention.

## 0.2.4 — 2026-11-19

- Reserve the cost of each complete relaxation pass once. Tight, exhaustive
  resource searches spend less time charging individual arcs.
- Cover the numeric conflict-certificate budget boundary and add paired
  deep-search benchmarks with exact limits, recovery and peak process memory.

## 0.2.3 — published, 2026-11-18

- Stop scanning task pairs at the first resource conflict in input order and
  skip rows for tasks without an exclusive resource.
- Preserve deterministic schedules, branch order and budget calculations.
- Extend the paired CLI benchmark with early, late and sustained conflict
  cases and add a timed public-library benchmark fixture.

## 0.2.2 — published, 2026-11-18

- Compile the validated temporal arcs once per planning request and extend
  them with one ordering arc per search child.
- Preserve readable planning model fields, relaxation order, budgets and
  diagnostics. Exercise the maximum task and dependency counts and child
  validation after a caller updates the readable rules array.
- Save individual timing and peak process memory samples in the planning benchmark.

## 0.2.1 — published, 2026-11-18

- Use Bellman–Ford feasibility witnesses during resource search, skipping
  all-pairs closure and conflict certificate construction in planning branches.
- Preserve schedules, search statistics and the 0.2.0 logical budget thresholds.
  Public numeric STN solving still returns tight bounds and conflict certificates.
- Add a planning benchmark and an exact-budget regression.

## 0.2.0 — published, 2026-11-17

- Task duration/window and four endpoint-dependency models, immutable snapshots.
- Exclusive-resource ordering with bounded disjunctive search, temporal pruning,
  backtracking and global node/work accounting; exhaustion never means UNSAT.
- Independent original-rule schedule verification, --plan and --plan-batch.
- Three new operational scenarios, public planning example and independent
  small-schedule enumeration oracle. Existing numeric STN API remains supported.
- Publication status and dated evidence: docs/acceptance.md.

## 0.1.2 — published, 2026-11-16

- Reserve the fixed closure budget once, reducing loop overhead and rejecting
  insufficient budgets before closure traversal without changing logical limits.
- Test exact reachable-network budget boundaries and expand benchmarks to budget
  exhaustion. Published and verified from a fresh registry consumer on 2026-11-16.

## 0.1.1 — published, 2026-11-11

- Skip unreachable closure rows and reuse reachable row references while preserving
  exact logical budgets, assignments, bounds and conflict certificates.
- Add sparse-network budget-boundary regression and reproducible CLI benchmark.
- Published after package extraction, Windows/Ubuntu CI and fresh registry consumer verification.

## 0.1.0 — published 2026-11-11

- Numeric simple temporal network modeling with named lower/upper constraints.
- Feasibility assignments, tight pairwise bounds and original-edge negative cycles.
- Independent assignment/conflict checking, copied model inputs and resource caps.
- Bounded JSON and CLI with per-request batch error isolation.
- Independent exhaustive small-network oracle, unit/boundary/I/O tests and examples.
- Published to Mooncakes after package-extraction and Windows/Ubuntu CI checks.

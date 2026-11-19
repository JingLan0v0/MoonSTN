# Changelog

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

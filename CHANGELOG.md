# Changelog

## Unreleased

- Reserve the fixed closure budget once, reducing loop overhead and rejecting
  insufficient budgets before closure traversal without changing logical limits.
- Test exact reachable-network budget boundaries and expand benchmarks to budget
  exhaustion. Published Mooncakes 0.1.1 remains unchanged.

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

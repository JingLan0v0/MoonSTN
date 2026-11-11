# Changelog

## Unreleased

- Skip unreachable closure rows and reuse reachable row references while preserving
  exact logical budgets, assignments, bounds and conflict certificates.
- Add sparse-network budget-boundary regression and reproducible CLI benchmark.
- Mooncakes 0.1.0 remains the published release; these changes are source-only.

## 0.1.0 — published 2026-11-11

- Numeric simple temporal network modeling with named lower/upper constraints.
- Feasibility assignments, tight pairwise bounds and original-edge negative cycles.
- Independent assignment/conflict checking, copied model inputs and resource caps.
- Bounded JSON and CLI with per-request batch error isolation.
- Independent exhaustive small-network oracle, unit/boundary/I/O tests and examples.
- Published to Mooncakes after package-extraction and Windows/Ubuntu CI checks.

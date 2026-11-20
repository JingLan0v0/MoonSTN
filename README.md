# MoonSTN

MoonSTN plans bounded tasks with duration ranges, deadlines, temporal dependencies
and exclusive resources. Its MoonBit core searches resource orderings, prunes
temporal conflicts and independently verifies schedules. It also checks
**numeric time constraints** without executing tasks. Give it rules
such as “testing starts 10–20 minutes after build starts” and “release follows
5–15 minutes later”; it returns a feasible assignment and the tight release
window, or a negative cycle identifying contradictory original rules.

[中文说明](README.zh-CN.md) · Apache-2.0 · Pure MoonBit core · JS CLI

**Package version [JingLan0v0/stn@0.2.22](https://mooncakes.io/docs/JingLan0v0/stn@0.2.22).**
Verification and installation receipts: [acceptance](docs/acceptance.md).
Repository: [JingLan0v0/MoonSTN](https://github.com/JingLan0v0/MoonSTN).

## Release history

| Version | Date | Main changes |
| --- | --- | --- |
| 0.2.22 | 2026-11-20 | Check exact integer spellings with less work per digit, including trailing-zero decimals. |
| 0.2.21 | 2026-11-20 | Reuse numeric constraint field lookups to skip a second scan of recognized keys. |
| 0.2.20 | 2026-11-20 | Reduce name, constraint ID, and bound validation work in large numeric models. |
| 0.2.19 | 2026-11-20 | Reuse reachable column indices in the wide closure to speed up sparse numeric networks. |
| 0.2.18 | 2026-11-20 | Reserve numeric closure work before allocating either distance matrix, so budget failures avoid setup costs. |

<details>
<summary>Earlier versions</summary>

| Version | Date | Main changes |
| --- | --- | --- |
| 0.2.17 | 2026-11-20 | Scan JSON input directly before decoding. Verify existing resource limits at and beyond their boundaries. |
| 0.2.16 | 2026-11-19 | Resolve the two fields of well-formed numeric queries directly and preserve validation order. |
| 0.2.15 | 2026-11-19 | Write numeric CLI responses directly for faster large query batches, with field order and JSON escaping preserved. |
| 0.2.14 | 2026-11-19 | Speed up multi-pass numeric feasibility with packed arc endpoints and exact bounded arithmetic. Keep the original cycle evidence and budget thresholds. |
| 0.2.13 | 2026-11-19 | Reuse adjacent equal distance conversions when the closure has repeated values. Repeated-value dense library solves took 4.4–9.9% less time across four paired comparisons. |
| 0.2.12 | 2026-11-19 | Reuse reachable columns during dense closure. Median dense library solve time fell 30–32% in two benchmark rounds. |
| 0.2.11 | 2026-11-19 | Speed up arc indexing by reusing validated names for JSON requests and building a name map for dense library calls. |
| 0.2.10 | 2026-11-19 | Use exact Int32 arithmetic for eligible dense networks and return tight bounds as Int64. |
| 0.2.9 | 2026-11-19 | Skip closure updates that cannot improve the pivot row. Add an independent comparison for signed bounds on a 64-point network. |
| 0.2.8 | 2026-11-19 | Resolve query endpoints once and read tight bounds directly by index. |
| 0.2.7 | 2026-11-19 | Build planning results directly in their final JSON form. |
| 0.2.6 | 2026-11-19 | Fix integer validation for JSON fractions that round to integers or underflow to zero. |
| 0.2.5 | 2026-11-19 | Reuse timepoint indices when building planning constraints and resource-order edges. |
| 0.2.4 | 2026-11-19 | Charge the work budget once per complete relaxation pass to reduce overhead in deep searches. |
| 0.2.3 | 2026-11-18 | Stop scanning task pairs at the first exclusive-resource conflict. |
| 0.2.2 | 2026-11-18 | Build temporal arcs once per planning request and reuse them across search branches. |
| 0.2.1 | 2026-11-18 | Check feasibility directly during resource search, avoiding all-pairs closure on each branch. |
| 0.2.0 | 2026-11-17 | Add task planning with duration ranges, time windows, dependencies, exclusive resources and independent schedule verification. |
| 0.1.2 | 2026-11-16 | Check the full closure budget before traversing the matrix. |
| 0.1.1 | 2026-11-11 | Skip unreachable closure rows and reuse references to reachable rows. |
| 0.1.0 | 2026-11-11 | First release with numeric time constraints, tight bounds, verifiable conflict cycles and batch JSON processing. |

</details>

[Full changelog](CHANGELOG.md) · [Benchmarks and verification](docs/acceptance.md)

## New in 0.2.0: resource-aware task planning

```sh
moon run cmd/main --target js -- --plan examples/release-plan.json
moon run cmd/main --target js -- --plan examples/maintenance-plan.json
moon run cmd/main --target js -- --plan examples/impossible-plan.json
moon run examples/planning --target js
```

The maintenance example requires backtracking; the delivery example has feasible
time windows but impossible shared-resource usage. Library APIs `planning_problem`,
`plan`, `verify_plan`, `analyze_plan`, `analyze_plan_batch` expose the same core.
[Schema, semantics and limits](docs/planning.md) · [Substantive revision](docs/review-response.md).

## Run

Install the pinned MoonBit version in `toolchain.json` and Node 24.14.0.

```sh
moon run cmd/main --target js -- examples/deployment.json
moon run cmd/main --target js -- examples/delivery.json
moon run cmd/main --target js -- examples/conflict.json
node scripts/verify.mjs
```

On this Windows machine `./scripts/moon.ps1` locates the separate local toolchain.
The verifier accepts `MOON_HOME` and `MOON_BIN`. No runtime third-party libraries.

## Input and meaning

```json
{"timepoints":["zero","a","b"],"constraints":[
  {"id":"start","from":"zero","to":"a","lower":0,"upper":0},
  {"id":"duration","from":"a","to":"b","lower":5,"upper":20}
],"queries":[{"from":"zero","to":"b"}]}
```

Every rule means `lower <= time[to] - time[from] <= upper`. Either bound may be
omitted/null, but at least one must exist. Units are chosen by the caller and
must be consistent. Times are integer offsets, not dates or timezones. The first
timepoint anchors the returned assignment at zero. No implicit nonnegativity
constraint is added. A witness is one valid arrangement, not an optimized schedule.

`feasible` includes `assignment` and requested `bounds`; a null bound means
unbounded, never zero. `inconsistent` includes an ordered negative-weight cycle
of original upper/lower edges. This is a checkable conflict, not a minimum-cardinality
repair plan. Unknown fields and unknown endpoints are rejected.

`--batch file.json` accepts an array and returns one result/error per request.
Single input/schema/resource/I/O errors exit 2 with empty stdout. Valid feasible
or inconsistent results exit 0. Batch exits 0 even with item errors: inspect
`status`. Unparseable/oversized entire batch input exits 2. Output failure may
leave partial bytes; consumers must check the process exit status.

## Library

Install the published package in your consumer module:

```sh
moon add JingLan0v0/stn@0.2.22
```

Import `JingLan0v0/stn` as `stn` in `moon.pkg`. A complete runnable example is in
`examples/library`. For source development, see [local workspace setup](docs/local-consumer.md).

- `network(names, constraints)` validates and snapshots inputs.
- `solve(network, max_steps=2000000)` returns `Feasible(Solution)` or
  `Inconsistent(Array[Edge])`; failures raise `StnError(code, message)`.
- `Solution::assignment()` returns a copy; `bounds(from,to)` returns tight bounds.
- `verify_assignment` and `verify_conflict` independently check evidence.
- `parse_json`, `analyze`, `analyze_batch` provide bounded text/JSON integration.

## Boundaries and evidence

64 timepoints, 512 constraints, input bounds ±1,000,000, 64 batch items, 256 queries.
Names/IDs: 1–64 ASCII letters/digits/underscore/dot/hyphen. Arithmetic uses Int64;
logical work is bounded separately from input size. See [resource contract](docs/resource-limits.md).
Planning adds <=24 tasks / 64 dependencies and bounded resource-order search.
No alternative resource assignment, cron, calendar, uncertainty/STNU,
network calls or task execution. Not a general constraint optimizer.

Planning is checked against 1,440 exhaustive two-task cases and 256 seeded
three-task cases by independent integer schedule enumeration in each build mode.
The verifier also compares all 4,096 three-node directed networks (each of six arcs
absent or weighted -1/0/1) with independent bounded assignment enumeration,
including all nine ordered pair bounds and actual negative-cycle certificates.
See [acceptance](docs/acceptance.md) for what was actually run, and
[ecosystem comparison](docs/ecosystem.md) for overlap and original contribution.

## Development

```sh
moon fmt
moon check --target js --deny-warn
moon test --target js --deny-warn
moon info --target js
node scripts/verify.mjs
```

Windows and Ubuntu CI runs on repository pushes; actual receipts are recorded
in acceptance.md. See
[progress](docs/progress.md), [publishing](docs/publishing.md), [license](LICENSE)
and [source attribution](THIRD_PARTY_NOTICES.md).

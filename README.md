# MoonSTN

MoonSTN checks **numeric time constraints** without executing tasks. Give it rules
such as “testing starts 10–20 minutes after build starts” and “release follows
5–15 minutes later”; it returns a feasible assignment and the tight release
window, or a negative cycle identifying contradictory original rules.

[中文说明](README.zh-CN.md) · Apache-2.0 · Pure MoonBit core · JS CLI

**Version 0.1.0. Registry publication status and receipts: [acceptance](docs/acceptance.md).**
Repository: [JingLan0v0/MoonSTN](https://github.com/JingLan0v0/MoonSTN).

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

Import `JingLan0v0/stn` as `stn` in a local consumer's `moon.pkg` after configuring
a [local workspace dependency](docs/local-consumer.md). A complete runnable example is in `examples/library`.

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
No resource assignment, disjunctive scheduling, cron, calendar, uncertainty/STNU,
network calls or task execution. Not a general constraint optimizer.

The verifier compares all 4,096 three-node directed networks (each of six arcs
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
in acceptance.md. Mooncakes publication was authorized on 2026-11-11. See
[progress](docs/progress.md), [publishing](docs/publishing.md), [license](LICENSE)
and [source attribution](THIRD_PARTY_NOTICES.md).

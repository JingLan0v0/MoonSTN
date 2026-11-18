# Acceptance evidence — updated 2026-11-18

Project MoonSTN / JingLan0v0/stn, published 0.2.2.

## Early return from resource-conflict scanning — 2026-11-18

The baseline was a clean rebuild of `5ea563b8f30db91aeddd64ff9d05749a65eca7ad`
(0.2.2) on Windows with moon 0.1.20261028, moonc v0.10.18+6c83a7f62 and
Node 24.14.0. A 24-task feasible branch visited all 276 pairs even after finding
its first conflict. A baseline CPU profile confirmed activity in the scan.
The candidate stops at the same first pair and skips rows for tasks with no
exclusive resource. It keeps the existing schedule construction.

Release CLI measurements include startup. Two runs used three warm-up pairs
and nine measured pairs per scenario, alternating order with the same `.js`
extension. Output matched in every sample. The largest observed slowdown
in these runs was 2.1% for the 24-task last-pair case.

| 32-request batch | Run 1 median ms before → after | Run 2 median ms before → after |
|---|---:|---:|
| Four resources | 103.79 → 101.65 | 105.06 → 101.60 |
| One resource | 113.09 → 107.00 | 113.34 → 107.54 |

The timed library driver reuses a caller-created problem, excludes startup and
performs 500 public `plan` calls per sample. Across three paired processes and
nine samples per process after warming, the four-resource median was
65.56 → 61.49 ms and the one-resource median was 126.15 → 120.89 ms.
Both improved in each process pair. Work and schedule checksums matched, and
the CLI batches compared complete outputs. The raw receipt retains timing
samples, ranges, peak RSS for CLI runs, and the initial extension-mismatched
pilot for context.

To reproduce the CLI comparison, build both revisions and copy the 0.2.2 CLI
alongside the candidate with a separate `.js` filename. Pass its absolute path
to `node scripts/benchmark-planning.mjs`. For the library comparison, use
two [local consumers](local-consumer.md), one per checkout, with
`scripts/fixtures/planning-benchmark.mbt` copied as `main.mbt` and
`examples/planning/moon.pkg` as the package manifest. Build both with
`moon build . --target js --release --deny-warn`. Pass the two compiled
drivers to `node scripts/benchmark-planning-library.mjs`, baseline first.
[Raw samples](optimization-0.2.3.json)

## Mooncakes 0.2.2 publication — 2026-11-18

Source `66b7cb2937f923f77ac7e800b85d03aba30924ce` passed Windows and Ubuntu
[CI run 44247426895](https://github.com/JingLan0v0/MoonSTN/actions/runs/44247426895).
The actual 59-file package passed fresh extraction verification at
2026-11-18T05:54:29.842Z. The English and Chinese installation commands and
the consumer instructions all target 0.2.2 in that package.

Preflight returned `202 Accepted`. Publication returned `200 OK`. The registry
records 2026-11-18 13:56:17 Asia/Shanghai. The inspected archive and the independently
downloaded registry ZIP share SHA-256
`5fe3b63494b24aac74fc16c8c2ea3c8ade22dc4c30976cd980964bebe6086add`.

An independent consumer installed exact version 0.2.2 from a fresh registry
cache without publication credentials or a workspace override. Replaying the
consumer after the interrupted session confirmed both public APIs in debug and
release. All 59 installed files matched the registry archive.
[Mooncakes package](https://mooncakes.io/docs/JingLan0v0/stn@0.2.2) ·
[Machine-readable receipts](publication-0.2.2.json).

## Reuse of indexed planning arcs — 2026-11-18

Baseline `e833a154a4e6c64ae41ffa56df500fed356bf508` (0.2.1) built from a fresh
checkout on Windows with moon 0.1.20261028, moonc v0.10.18+6c83a7f62 and Node 24.14.0.
In a CPU profile of eight 24-task requests that exhaust their work budget,
network construction and endpoint indexing accounted for 153 of 334 samples.
Each plan call now prepares indexed arcs once and appends only the new order at
each child. The generated public interface, including readable model fields,
is unchanged. The child is validated after the node limit check, as in 0.2.1.

Paired release CLI samples include process startup and the peak RSS probe.
Each scenario used three warm-up pairs and nine measured pairs with alternating
starting order. Build time is outside these measurements. All measured results
matched 0.2.1 exactly. Ranges are minimum and maximum observed times in ms.

| Scenario | Requests per process | Median ms before → after | Range ms before → after | Median peak RSS MiB before → after |
|---|---:|---:|---:|---:|
| Maintenance example | 64 | 83.73 → 84.90 | 82.39–99.66 → 83.32–87.13 | 53.82 → 48.82 |
| 24 tasks with no shared resources | 64 | 103.90 → 106.53 | 99.77–109.38 → 102.75–118.83 | 58.04 → 58.25 |
| 24 tasks on four resources | 8 | 101.67 → 101.42 | 100.18–103.31 → 98.66–102.96 | 54.17 → 52.76 |
| 24 tasks on one resource | 2 | 85.01 → 85.75 | 82.66–102.83 → 82.28–117.74 | 52.55 → 50.29 |
| 24 tasks on one resource, budget exhausted | 2 | 202.62 → 123.87 | 195.35–206.28 → 123.05–126.00 | 52.00 → 50.70 |

The overload scenario took 38.9% less elapsed time in this run. The other timing
ranges overlapped. A separate numeric STN benchmark matched outputs and budget
errors with median changes from 1.1% faster to 3.6% slower. Library-only
latency and compile time were outside the performance comparison.

The local verifier and a fresh extraction of the candidate package each passed
24 unit tests, 4,096 numeric STN comparisons and 1,696 independent planning
comparisons in debug and release. Planning batch outputs matched 0.2.1,
including errors and statistics. The new regressions cover the exact work charge
at 24 tasks and 64 dependencies, child validation order and recovery after a
change to the readable rules array. Generated interfaces and PowerShell smoke
also passed.

Reproduce using `node scripts/benchmark-planning.mjs /absolute/path/to/0.2.1-main.js`.
See [raw samples and profile counts](optimization-0.2.2.json).

## Mooncakes 0.2.1 publication — 2026-11-18

Source `7469c5fdda3bdb96de2e0354bd124801b9988e25` passed Windows and Ubuntu
[CI run 44245404254](https://github.com/JingLan0v0/MoonSTN/actions/runs/44245404254).
A fresh extraction of the actual 57-file ZIP passed the full verifier and PowerShell
smoke, including the 0.2.0 planning output comparison in both modes.
The extraction verifier completed at 2026-11-18T05:35:23.259Z.

Preflight returned `202 Accepted`. Publication returned `200 OK`. The registry
records 2026-11-18 13:38:22 Asia/Shanghai. The publication ZIP and the independently
downloaded registry ZIP share SHA-256
`7eea20a0f011c1b7e87bca7d7861f446edf26ebbf16e5c16cd4a7c3081600c88`.

A fresh consumer with an empty registry cache installed exact version 0.2.1 without
publication credentials or a workspace override. Debug and release verified version,
assignment, tight bounds, conflict proof, resource ordering, schedule verification,
unschedulability and budget recovery. All 57 installed files matched the downloaded
archive. [Mooncakes package](https://mooncakes.io/docs/JingLan0v0/stn@0.2.1) ·
[Machine-readable receipts](publication-0.2.1.json).

## Planning performance optimization — 2026-11-18

The desktop checkout and GitHub main matched `46b9880165c1f456d90dbb08f6b317f0a418c500`.
The baseline was rebuilt in an isolated checkout on Windows with moon 0.1.20261028,
moonc v0.10.18+6c83a7f62 and Node 24.14.0. Fresh baseline verification passed
22 unit tests, 4,096 independent STN network comparisons and 1,696 independent
planning comparisons in each build mode. PowerShell smoke passed.

V8 CPU profiling used a batch of 32 identical 24-task requests split across four
exclusive resources. The original solve function accounted for 129 of 195 samples,
with the recorded hot lines in the all-pairs closure loop. The optimized planning
branch uses the shared Bellman–Ford feasibility decision and normalized witness.
The branch still reserves the 0.2.0 budget charge.

Paired release CLI results from 2026-11-18T05:32:03.945Z, with two warm-ups, nine
measured samples, alternating baseline/current order and process startup included.
Each request has 24 one-unit tasks. All measured outputs matched, including
schedules, statistics and budget errors.

| Scenario | Requests per sample | 0.2.0 median ms | Optimized median ms |
|---|---:|---:|---:|
| No shared resources | 64 | 126.45 | 101.11 |
| Four exclusive resources | 8 | 138.41 | 99.50 |
| One exclusive resource | 2 | 104.32 | 82.39 |
| One exclusive resource, work budget exhausted | 2 | 363.89 | 206.44 |

To reproduce, save the release CLI built from the baseline SHA, build the current
release CLI, then run `node scripts/benchmark-planning.mjs /absolute/path/to/baseline-main.js`.
Run `node scripts/verify.mjs /absolute/path/to/baseline-main.js` for exact planning
output comparisons alongside the independent oracles.

Local 0.2.1 verification completed at 2026-11-18T05:33:25.411Z. Debug and release
each passed 23 unit tests, 4,096 numeric STN comparisons and 1,696 independent
planning comparisons. The planning batches, including invalid inputs and budget
exhaustion, also matched the 0.2.0 CLI exactly in both modes. The new unit test
asserts the exact work and node thresholds, returned schedule and pruning stats
for a backtracking case. Generated public interfaces, six CLI scenarios, two
library examples and PowerShell smoke passed.

The separate numeric STN benchmark also matched outputs and budget errors against
0.2.0. In its six paired scenarios the medians ranged from 1.9% faster to 1.5%
slower.

## Mooncakes 0.2.0 publication — 2026-11-17

Published from `07e49907dd6472c45433294e0be71ec502a101e7`.
Registry timestamp: 2026-11-17T15:00:51.857994+00:00 (23:00 Asia/Shanghai).
Checkout verification completed at 2026-11-17T14:56:35.121Z;
actual package extraction verification completed at 2026-11-17T15:00:03.786Z.
In each location, debug and release each passed 22 units, 4,096 exhaustive STN
networks and 1,696 independent planning comparisons (1,440 exhaustive two-task
models and 256 seeded three-task models). Checks included six CLI scenarios, two
public API examples, batch isolation and transport failures. PowerShell smoke
passed in both locations.

[CI run 44109093011](https://github.com/JingLan0v0/MoonSTN/actions/runs/44109093011)
passed on Windows and Ubuntu for the exact source commit. Package preflight returned
`202 Accepted`; publication returned `200 OK`. The package contains 55 tracked files
and excludes build outputs, caches, local toolchains and credentials.

The registry index lists 0.2.0 as active. The independently downloaded ZIP has
SHA-256 `adc2cefbbb8586f2b26ce4d9637b671d323a2fb4259784ad89c60bbc0854964e`, identical to the verified preflight archive.
All 55 installed files match. A new consumer without registry credentials or a
local workspace override passed debug and release checks for resource ordering,
schedule verification, unschedulability, budget recovery and the original STN API.

[Mooncakes package](https://mooncakes.io/docs/JingLan0v0/stn@0.2.0) ·
[Machine-readable receipts](publication-0.2.0.json) ·
[Initial review response](review-response.md).

The following documentation commit records the release. This evidence documents
technical delivery; competition re-review remains pending.


## Mooncakes 0.1.2 publication — 2026-11-16

Published from `7d42c5fc89cef33948e9f4e8cec6a4cab703bf22`.
Registry timestamp: 2026-11-16T05:16:36.875552+00:00 (13:16:36 Asia/Shanghai).
Fresh local verifier: 2026-11-16T05:14:38.050Z; actual package extraction verifier:
2026-11-16T05:15:38.617Z. Each passed 15 units and 4,096 exhaustive networks
per mode, plus all existing transport/batch/I/O/scenario checks. PowerShell smoke
passed in the checkout and extraction. These are new November 16 runs.

[CI run 43809017332](https://github.com/JingLan0v0/MoonSTN/actions/runs/43809017332)
passed on Windows and Ubuntu for that exact source SHA before publishing.
The inspected 42-file archive contains no credentials, toolchains, build outputs
or dependency caches. SHA-256, also matched by the fresh registry ZIP:
`763c946a5a52c284e92775c73bd9603b83b0a7d42105f46887e9099233cd2e4c`.
Preflight: `202 Accepted`, exit 0. Actual publication: `200 OK`, exit 0.

A fresh credential-free cache installed 0.1.2 without a workspace/path override.
Debug/release with warnings denied passed version, assignment, bounds, conflict
certificate, budget recovery and batch isolation. All 42 downloaded files match;
the downloaded solver explicitly contains the November 13 fixed-closure budget
optimization. See [publication-0.1.2.json](publication-0.1.2.json).
The following docs-only commit records these receipts and new installation links.
Older versions and their historical evidence remain unchanged.

## Budget optimization — 2026-11-13, subsequently published in 0.1.2

New full verification completed at 2026-11-13T07:09:30.383Z: debug/release each
passed 15 units, 4,096 exhaustive networks and all existing transport, batch,
process I/O and scenario checks. PowerShell smoke passed. Public API unchanged.
New regression covers 2/8/64-node chains and connected cycles, exact budget
thresholds, shortfalls of 1/V-1/V, correct bounds and reuse after budget errors.

Paired release CLI benchmark against 546c2c3, Node 24.14.0, pinned toolchain:
eight 64-point requests per process, two warm-ups, nine samples, alternating order.
Times include process startup and are machine-specific. No universal speed claim.

| Scenario | Before median ms | After median ms |
|---|---:|---:|
| disconnected | 89.78 | 91.19 |
| disconnected-budget-exhausted | 87.18 | 85.14 |
| chain | 99.96 | 98.86 |
| chain-budget-exhausted | 101.75 | 90.12 |
| connected | 120.98 | 117.50 |
| connected-budget-exhausted | 130.60 | 106.22 |

Chain/dense budget failures were about 11.4%/18.7% faster by elapsed time;
normal-case differences were small, including a ~1.6% disconnected slowdown.
All measured outputs and 60 additional budget differential comparisons matched
(30 unique input/budget combinations, repeated across paired scenarios).
Reproduce: `node scripts/benchmark.mjs /absolute/path/to/baseline-main.js`.
See optimization-2026-11-13.json for receipts. Mooncakes 0.1.1 is unchanged.

## Mooncakes 0.1.1 publication — 2026-11-11

Published optimization release from `b9a2de40925c1bdefe6f2f318631400e8ac96118`.
Registry timestamp: 2026-11-11T12:35:04.200439+00:00 (20:35:04 Asia/Shanghai).
Fresh checkout verification: 2026-11-11T12:32:56.565Z.
Fresh actual-package extraction verification: 2026-11-11T12:34:21.756Z.
Both passed 14 units and 4,096 exhaustive networks per mode, all existing
boundary/batch/I/O/scenario checks and PowerShell smoke.

[CI run 43021382909](https://github.com/JingLan0v0/MoonSTN/actions/runs/43021382909)
passed Windows and Ubuntu on the exact release source SHA before publication.
The 40-file publisher archive excluded credentials, build outputs, dependencies
and toolchains. Its SHA-256 and the fresh registry download both equal:
`f145fa32ec4e261c22b28178c40bcba98268cb10bb125ece78d5e63f13f53338`.

Preflight returned `202 Accepted` and actual publication `200 OK`, each exit 0.
A fresh cache with no credentials downloaded 0.1.1 with no workspace/path override.
Debug/release with warnings denied passed version, feasible assignment, bounds,
conflict certificate, budget recovery and batch isolation; all 40 downloaded
files match the validated archive. See [publication-0.1.1.json](publication-0.1.1.json).
The following docs-only commit records receipts and current installation links.
0.1.0 is retained unchanged; earlier evidence below belongs to its stated stage.

## Source optimization before 0.1.1 publication — 2026-11-11

Fresh verification completed at 2026-11-11T12:27:47.730Z: debug/release each
passed 14 units, 4,096 exhaustive networks and existing input/batch/I/O/scenario
checks. PowerShell smoke passed. Generated public interfaces are unchanged.
The new regression checks exact closure budget thresholds for 1/2/8/64 isolated
points, all pairwise bounds and reuse after budget exhaustion.

Paired release CLI benchmark against ac1932c (same Node 24.14.0/toolchain/machine):
64 points, eight requests per process, two warm-ups then nine measured samples,
alternating old/new order. Median milliseconds, including process startup:

| Network | Before | After |
|---|---:|---:|
| Disconnected | 149.12 | 139.39 |
| One-way chain | 165.32 | 151.24 |
| Connected, 512 constraints | 205.43 | 191.61 |

This run reduced end-to-end median time by about 6.5–8.5%; it is not a universal
speed guarantee. All measured outputs matched; 30 additional low/default-budget
comparisons matched errors and successful results. Reproduce after release build:
`node scripts/benchmark.mjs /absolute/path/to/baseline-main.js`.
Omit the argument to measure just the current implementation. Benchmark receipts
are in optimization-2026-11-11.json. Published 0.1.0 was not modified/replaced.

## Mooncakes publication — 2026-11-11

The owner explicitly authorized publication, superseding the earlier deferral.
[JingLan0v0/stn@0.1.0](https://mooncakes.io/docs/JingLan0v0/stn@0.1.0)
was published from `c8265015a4a0829045113bdd055b0a8dab6e6a3e`.

- Fresh checkout verifier completed at 2026-11-11T04:43:22.438Z; extracted actual
  publication ZIP completed at 2026-11-11T04:46:29.037Z. Each passed debug/release:
  13 unit tests, 4,096 exhaustive networks, 15 invalid batch items, seven transport
  rejections, all process I/O checks and three scenarios. PowerShell smoke passed
  in both the checkout and extraction. These are new runs, not the November 10 runs.
- [CI run 42961509778](https://github.com/JingLan0v0/MoonSTN/actions/runs/42961509778)
  passed on Windows and Ubuntu for that exact source SHA before publication.
- The publisher ZIP contains 37 tracked files; only Git attributes, ignore rules
  and CI configuration are omitted. No credentials, toolchains, dependency caches
  or build outputs were packaged. SHA-256:
  `15f0b0e28bbbc46973197a329bc44843c527b7731f80a57bd50078f202c21b78`.
- `moon publish --dry-run`: exit 0, server `202 Accepted`.
  Actual `moon publish`: exit 0, server `200 OK`. Published ZIP and inspected ZIP
  match exactly. The new toolchain used an existing external registry session;
  credentials were never placed in the repository.
- A fresh consumer downloaded `JingLan0v0/stn@0.1.0` from Mooncakes with no local
  workspace/path dependency. All 37 downloaded files match the archive hashes.
  Debug and release, both with warnings denied, passed version, feasible assignment,
  tight bounds, conflict certificate, budget-failure recovery and batch isolation.
- GitHub direct connectivity and the initial registry clone stalled; the existing
  local proxy resolved them. The interrupted clone was not counted as a passed test.
- Machine-readable receipts: [publication-0.1.0.json](publication-0.1.0.json).
  The following docs-only commit records these receipts and installation links;
  it is not a replacement or republication of the immutable 0.1.0 package.

Earlier sections below are historical stages. Their publication deferral has
been superseded. No competition application or organizer approval is implied.

## GitHub upload and CI — 2026-11-10

The owner-created public repository is https://github.com/JingLan0v0/MoonSTN .
Normal Git push retained the original two commits; no force push was used.
Remote main was read back and matched `b3be7d526977c861a0394f5ff0375478fdbf42ab`.
[CI run 42812956601](https://github.com/JingLan0v0/MoonSTN/actions/runs/42812956601) passed on both Windows and Ubuntu for that exact
commit, including the complete verifier and generated-interface check. Windows
also passed PowerShell usage. Both evidence artifacts were uploaded.

Before upload this round reran full local verification and PowerShell: 13 units
and 4,096 exhaustive networks per mode, retained boundary/I/O/scenario checks.
Desktop proposal now contains the actual repository root URL and CI link.
Mooncakes publication remains explicitly deferred. This following docs-only
commit records receipts; the linked CI evidence belongs to the SHA above.

## Initial local preparation results

Pinned moon 0.1.20261028 / moonc v0.10.18+6c83a7f62, Node 24.14.0, Windows.
The separate toolchain's 17 binary checksums were verified against the official
checksum file. MoonJMES's toolchain was not changed.

`node scripts/verify.mjs` completed successfully at 2026-11-10T11:53:03Z (UTC):

- Warning-free check, format check, interface generation and debug/release builds.
- 13 unit tests in EACH mode, covering numeric limits, snapshots/reuse, proof
  forgery, disconnected cycles, model validation and decoder boundaries.
- 4,096 exhaustive three-node networks in EACH mode. Every feasibility result,
  actual assignment, all nine pairwise bounds and negative-cycle certificate
  checked against independent assignment enumeration and original input edges.
- 15 malformed/resource request variants EACH placed between good batch neighbors.
- Seven whole-transport rejections per mode, including duplicate JSON keys,
  invalid UTF-8, excessive nesting/string/text size and batch count.
- BOM input, wrong/missing CLI arguments, missing file, version and stdout failure.
- Three runnable scenarios and the public library example in both modes.

PowerShell pipeline, all three scenarios and caller-directory restoration passed.
An independent local consumer module used a MoonBit workspace dependency and
passed feasible/bounds/conflict public API assertions with warnings denied in
both modes. This is NOT a registry download. Initial legacy consumer manifest
syntax was rejected by the new compiler; the consumer was corrected to moon.mod
plus moon.work and the legacy file removed before successful checks.

The first internal development checks used 0.10.14. Final verification above used
the pinned 0.10.18 toolchain, including explicit `fn main raise` in the public API
example and strict duplicate-key JSON parsing. Do not confuse those stages.

## Delivery gates

- Source commit: `73633fc403ee3c037a909297d88021b3c796883f` (ordinary initial Git commit).
- Source archive: 47 ZIP entries / 39 files, excluding Git metadata, credentials,
  tools, dependency caches and build outputs. SHA-256:
  `2b39131b25d92ccd2232d166aaf860734599b1ad697ef05c3c029a39030a8ffd`.
- A fresh extraction completed the entire verifier and PowerShell smoke in both
  modes. An independent consumer then referenced the extracted module through a
  workspace and passed debug/release public API assertions with warnings denied.
- The following documentation-only commit records these observed receipts; the
  archive refers to the source commit above, not a Mooncakes package.
- Initial local-delivery stage: GitHub and CI had not yet been created/run.
- Upload stage: owner created public https://github.com/JingLan0v0/MoonSTN;
  its main branch and empty state were checked before upload. Upload and CI
  receipts are recorded at the top of this document.
- Mooncakes preflight/publication/registry consumer: deliberately not performed.
- Competition application/qualification/final acceptance: not submitted or proven.

Finite tests do not certify every possible input or guarantee organizer approval.
See architecture.md for the oracle's finite family and resource-limits.md for
arithmetic, work and transport limits.

# Acceptance evidence — updated 2026-11-19

Project MoonSTN / JingLan0v0/stn, published 0.2.7.

## Numeric bound queries — 2026-11-19

Baseline `cb0d8e7` uses the 0.2.7 runtime. The pinned release JS toolchain
and Node 24.14.0 ran on Windows. On 64-point networks the benchmark checks
256 ordered query entries against independent formulas for the empty graph,
directed chain and clockwise eight-neighbor graph.

| Instrumented baseline median | Batch size | Name lookup calls | Query validation, ms | Closure, ms | Feasible result build, ms |
|---|---:|---:|---:|---:|---:|
| Sparse, no edges | 48 | 49,152 | 7.85 | 0.92 | 14.58 |
| Chain | 32 | 36,800 | 5.87 | 6.73 | 11.24 |
| Dense | 16 | 32,768 | 4.19 | 14.57 | 5.79 |

The recorded name lookup time includes wrapper overhead and overlaps
query validation, arc indexing and result construction. The all-isolated
case calls name lookup twice per endpoint, for validation and for reading
bounds. The candidate reuses the validated name map from network construction,
stores endpoint positions at validation time and reads both bounds directly.
The named library lookup and negative-cycle path retain their behavior.

| Plain CLI median, ms | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Sparse | 136.77 → 134.02 | 139.99 → 135.13 |
| Chain | 140.14 → 137.75 | 137.87 → 135.05 |
| Dense | 153.44 → 146.31 | 149.42 → 147.35 |
| Ordinary | 79.82 → 80.04 | 79.60 → 79.05 |

Corresponding improvements were 2.0% / 3.5%, 1.7% / 2.0% and 4.6% / 1.4%
for the three large fixtures. Dense median peak RSS was 89,104 → 88,760 KiB
and 89,328 → 88,596 KiB. The ordinary control varied by less than 1%.
The small-query numeric control also matched all outputs across six
workloads and 30 additional budget checks.

All six timed batches matched byte for byte. The mixed check covers
257 queries, validation of the first unknown endpoint before solve,
invalid budget priority, a disconnected negative cycle with exact
certificate budget and one step less, plus successful neighbors.
Run `node scripts/benchmark-numeric-queries.mjs BASE.js CANDIDATE.js`
and reverse the arguments for the second paired run. Each round measures
nine process pairs after two warm-up pairs. For baseline phase timing,
set `MOONSTN_PROFILE_QUERIES=1` and pass only the 0.2.7 CLI. The phase
markers depend on the pinned generated JS. [Raw measurements](optimization-0.2.8.json)

## Mooncakes 0.2.7 publication — 2026-11-19

Source `d9c7224801186146995bc4e6ff7059185b0c6bde` passed Windows and Ubuntu
[CI run 44468912322](https://github.com/JingLan0v0/MoonSTN/actions/runs/44468912322).
The checkout and a fresh extraction of the 82-file archive each passed 27
unit tests, 4,096 numeric networks and 1,794 planning cases per build mode.
PowerShell smoke passed and generated public interfaces matched Git.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 14:01:12 Asia/Shanghai. The public and preflight ZIP archives
share SHA-256 `448f06472f4d1a1ddc501d64c805cc932d2b2c826c096ad939f01b5e544bb196`.
An independent project with an empty cache installed exactly 0.2.7.
Numeric, planning and exact-integer API calls passed in debug and release.
The installed API's mixed batch with success, unschedulability and budget
error serialized byte-for-byte like 0.2.6. All 82 files matched the archive.
[Release receipts](publication-0.2.7.json)

## Planning result construction — 2026-11-19

Baseline `7e61c8f` uses the 0.2.6 runtime. The pinned release JS toolchain
and Node 24.14.0 ran on Windows. Each fixture sends 64 requests. The phase
profiler measures success or unschedulable object construction, error
object construction and final JSON stringification in instrumented copies.
Every copy is checked against the plain CLI's output.

| Baseline output phase | Output bytes | Result build, ms | Error build, ms | Stringify, ms |
|---|---:|---:|---:|---:|
| Maximum dependency model | 60,226 | 1.03 | 0 | 3.42 |
| Wide schedules, 24 tasks with 64-character IDs | 167,746 | 1.33 | 0 | 3.46 |
| Unschedulable | 5,826 | 0.26 | 0 | 0.73 |
| Work-budget error | 7,234 | 0 | 0.16 | 0.75 |
| Mixed outcomes | 61,948 | 1.05 | 0.07 | 1.92 |

The candidate creates each successful schedule entry in a map sized for the
three fields. It fills the fields in their existing order and avoids the
temporary array of key-value pairs. All six batch outputs matched byte for
byte, including the ordinary maintenance fixture.

| Candidate comparison, median | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Wide schedule result build, ms | 1.277 → 1.164 | 1.543 → 1.126 |
| Mixed outcome result build, ms | 0.991 → 0.582 | 1.145 → 0.570 |
| Wide schedule plain CLI, ms | 106.15 → 105.35 | 108.19 → 107.58 |
| Wide schedule plain CLI peak RSS, KiB | 60,720 → 59,004 | 60,200 → 60,012 |
| Maximum dependency plain CLI, ms | 123.69 → 127.29 | 128.41 → 124.70 |

The wide schedule's end-to-end improvement was under 1% in both rounds.
The maximum dependency workload varied by round. The candidate reduces
construction time for wide and mixed results. The stringify medians show
no consistent improvement across workloads.

Run `node scripts/benchmark-planning-results.mjs BASE.js CANDIDATE.js`
from the repository root, then reverse the arguments. Set
`MOONSTN_PROFILE_RESULTS=1` to enable the compiler-specific phase markers.
Each round has two warm-up and nine measured process pairs. The report
retains ordered samples, peak process RSS, byte counts and output hashes.
[Raw measurements](optimization-0.2.7.json)

## Mooncakes 0.2.6 publication — 2026-11-19

Source `3f510a868b609c2872fa9e2c948d1c39b1f20eb7` passed Windows and Ubuntu
[CI run 44467540629](https://github.com/JingLan0v0/MoonSTN/actions/runs/44467540629).
The checkout and a fresh extraction of the 79-file archive each passed 27
unit tests, 4,096 numeric networks and 1,794 planning cases per build mode.
Raw integer tests and PowerShell smoke passed. Generated public interface
files matched Git.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 13:49:01 Asia/Shanghai. The public and preflight ZIP archives
share SHA-256 `c0b1b36bcfe833d818d5a7cfe4bac6089bdf164c3f331137b199b40dc2661579`.
An independent project with an empty cache installed exactly 0.2.6.
Numeric, planning and exact-integer API calls passed in debug and release.
All 79 installed files matched the archive. [Release receipts](publication-0.2.6.json)

## JSON number exactness — 2026-11-19

The 0.2.5 baseline `f0ddf67` accepted `1000000.00000000001` as 1,000,000
and `1e-400` as zero in numeric constraints. Binary64 rounded both before
schema validation. The same conversion affected planning fields and work
budgets. 0.2.6 retains the source number spelling through core parsing and
checks that its decimal scale makes the value integral. It still imposes
each field's existing bounds. Core syntax and decoded duplicate-key checks
still run first.

Twelve baseline CPU profiles used 64 copies of a 24-task, 64-dependency
model. Among 1,502 samples, identifiable core self samples included 44 in
object parsing, 37 in map membership checks, 17 in map writes, 15 in string
lexing and 43 in number lexing. Ten self samples landed in MoonSTN's field
validator. Inlined work may be attributed to its caller. On this fixture,
the baseline phase medians were 19.33 ms for core grammar and 5.42 ms for
request and result conversion.

The correctness fix intentionally retains more numeric text. With ordinary
integer JSON, two uninstrumented maximum-size CLI batch medians changed
from 123.37 to 125.25 ms and from 125.40 to 125.88 ms. Ordinary two-task
maintenance medians increased 0.9% and 1.6%. The one-run numeric control
matched all outputs and 30 extra budget comparisons, with timings ranging
from 1.1% faster to 5.7% slower across its cases.

Raw CLI tests cover normal and exponent spellings, rounded fractions,
underflow, escaped duplicate keys, first-error order and batch isolation.
An additional seeded probe compared 487 spellings against an independent
BigInt calculation of divisibility and range. The main numeric and planning
comparison suites still match the 0.2.5 baseline for their existing inputs.

The raw report contains the profile sample counts, phase timings, CLI
sample pairs, peak process RSS and build hashes. Reproduce phase timing
with `scripts/profile-planning-cli.mjs` and use
`scripts/benchmark-deep-search.mjs` with reversed argument order for paired
CLI timing. [Raw measurements](optimization-0.2.6.json)

## Planning CLI phase review — 2026-11-19

Baseline `470e2cb` is the published 0.2.5 runtime. Release JS builds
used the pinned toolchain on Windows and Node 24.14.0. The phase profiler
wraps generated functions in a temporary copy of the CLI and compares its
stdout byte-for-byte with the plain build. It takes the median of seven
measured processes per case after discarding the first instrumented run.
The timings cover 64 requests per process and exclude startup and I/O.

| Baseline phase median, ms | Ordinary maintenance | 24 tasks / 64 dependencies, no resources | Same size, four resources |
|---|---:|---:|---:|
| JSON preflight | 0.93 | 3.04 | 2.98 |
| Core JSON grammar and duplicate keys | 3.78 | 19.11 | 18.92 |
| Planning model construction | 0.86 | 3.27 | 2.62 |
| Solve | 2.71 | 9.89 | 16.03 |
| Request and result conversion | 2.16 | 5.94 | 5.49 |
| Output stringify | 1.35 | 2.98 | 2.90 |

The indexed UTF-16 scan candidate counted a valid surrogate pair once and
delegated syntax and duplicate-key checks to the same parser. It lowered
the uncontented maximum-size preflight median from 3.04 to 2.39 ms.
The plain CLI paired runs use a separate 24-task, 64-dependency fixture
with distinct resources. End-to-end medians for 64 such requests were
122.46 to 132.43 ms and 122.37 to 120.86 ms. Ordinary CLI medians also
changed direction across rounds. Numeric CLI medians varied by less than
1% in the control run. All compared outputs and budget checks matched.
The evidence supports keeping the 0.2.5 runtime.

The regression suite covers an escaped quote at the 256-character string
limit and a supplementary-plane character on either side of the 200,000
outer-character limit. At the exact outer limit the invalid source reaches
the grammar parser. One character more yields the existing limit error.

Both the measured candidate and the retained implementation passed local
debug and release verification. Each mode covered 27 unit tests, 4,096
numeric networks and 1,794 planning cases. Comparison batches matched
the baseline CLI. PowerShell smoke and the public interface check passed.

Reproduce the phases with `node scripts/profile-planning-cli.mjs BASE.js`.
Use `node scripts/benchmark-deep-search.mjs BASE.js CANDIDATE.js` twice with
reversed argument order for the CLI timing pairs. The report preserves
ordered samples, peak CLI process RSS, build hashes and the tested patch.
[Raw measurements](planning-cli-review.json)

## Mooncakes 0.2.5 publication — 2026-11-19

Source `70af91076d3378b6f77b00b200d1557e79b865f3` passed Windows and Ubuntu
[CI run 44354461672](https://github.com/JingLan0v0/MoonSTN/actions/runs/44354461672).
In both the working checkout and a fresh extraction of the 75-file package,
debug and release passed 26 unit tests, 4,096 numeric networks and 1,794
planning cases per mode. The numeric and planning comparison batches matched
0.2.4. The added unit test revalidates caller-edited names, checks node-budget
and unknown-timepoint error order, and restores the model for reuse. Generated
interfaces and PowerShell smoke passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 01:05:49 Asia/Shanghai. The downloaded and preflight packages
share SHA-256 `5aca2ddf26ee47ad092c13a7f5f95597b983d9d26f9981bc1efbc350b214f06a`.
An independent project with an empty cache installed exactly 0.2.5, passed
both public API examples in debug and release, and had all 75 installed
files match the public archive. [Release receipts](publication-0.2.5.json)

## Planning edge indexing and name lookup — 2026-11-19

Windows JS release builds used baseline `12bb6fe`, the pinned toolchain and
Node 24.14.0. The library benchmark reused prepared models. Each process
warmed up three times and timed nine samples of 500 calls. Three process
pairs alternated order in each round. The second round reversed the starting
order. The CLI benchmark paired nine measured processes after two warm-ups
and included startup, JSON handling and model construction.

On the baseline 24-task, 64-dependency model with distinct resources,
base edge indexing accounted for 140 of 678 CPU samples and network
validation for 138. With all tasks sharing a resource, relaxation took
3,089 of 4,351 samples. Child compilation took 85, with at least 46
identified on the inlined ordering-ID scan and 19 on the name scan.
These profiles measure self samples, including inlined code.

Reusing a validated name map while still constructing named edges cut
the distinct-resource model's library median by 33.6% and 36.0%, with
slower medians on the two-task library case. The selected candidate emits
indexed edges during constraint validation. It uses the same index to
resolve ordering edges against the caller's current names.
The index belongs to one plan call. Constraints still validate in input
order, and upper edges still precede lower edges.

| Selected candidate | Round 1 baseline → candidate, ms | Round 2 baseline → candidate, ms |
|---|---:|---:|
| Library, 24 tasks and 64 dependencies with distinct resources | 26.61 → 14.34 | 28.28 → 14.94 |
| Library, same model with one resource | 189.97 → 174.16 | 195.57 → 178.72 |
| Library, ordinary two-task maintenance | 1.65 → 1.84 | 1.73 → 1.58 |
| CLI, 32 tight unschedulable requests | 187.05 → 180.72 | 183.43 → 178.18 |
| CLI, 64 maximum-model requests with distinct resources | 124.17 → 130.16 | 127.20 → 124.27 |

The larger library cases took 46.1% / 47.2% and 8.3% / 8.6% less time.
The tight CLI batch took 3.4% and 2.9% less time. The distinct-resource
CLI and ordinary control varied by round. All timed outputs and 30
additional numeric budget comparisons matched. The numeric CLI control's
median changes ranged from 3.0% faster to 0.5% slower in one run.

For library reproduction, place `scripts/fixtures/planning-benchmark.mbt`
and `examples/library/moon.pkg` in an executable package named
`lookupbench` in each checkout. Name the fixture `main.mbt`. Build in
JS release mode and pass the resulting drivers to
`node scripts/benchmark-planning-library.mjs BASE.js CANDIDATE.js`.
Use `scripts/benchmark-deep-search.mjs` for CLI pairs. The evidence file
contains raw timings, CLI peak RSS, binary hashes and candidate patches.
[Raw measurements](optimization-0.2.5.json)

## Planning predecessor review — 2026-11-19

Baseline `5331298` uses the 0.2.4 runtime. Two MoonBit candidates tested
whether avoiding predecessor allocation and writes speeds up planning.
One passed an optional array to the shared relaxation loop. The other
specialized the loop for an array in numeric solves and for a no-op
recorder in planning. The generated JS used separate loops for the
specialized build. Both candidates kept numeric certificate construction.

Each CLI comparison used two warm-up pairs and nine measured pairs. Each
library comparison used four process pairs, with three warm-ups and nine
samples per process. The second measurement round reversed the argument
order. CLI timings include startup and transport. Library timings cover
16 solves on a prepared model. All measured planning outputs matched.

| Tight unschedulable model, median ms | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Optional array, 32 CLI requests | 191.27 → 189.75 | 189.29 → 189.44 |
| Optional array, 16 library calls | 45.85 → 46.24 | 45.08 → 45.60 |
| Specialized recorder, 32 CLI requests | 188.32 → 184.09 | 183.59 → 186.41 |
| Specialized recorder, 16 library calls | 45.35 → 45.73 | 45.76 → 46.32 |

The specialized candidate was 2.2% faster in the first tight CLI round
and 1.5% slower in the second. Both library rounds were slightly slower.
The ordinary and maximum-model CLI controls also varied by round. Median
peak process RSS for tight CLI batches varied by less than 300 KiB within
each pair. In one numeric run, all six graph and budget combinations and
30 additional limit comparisons matched. The dense budget-exhausted
scenario's median rose from 91.45 to 96.67 ms in that run.

The specialized candidate passed full local debug and release verification,
including 25 unit tests, 4,096 numeric networks and 1,794 planning cases
per mode. Ordered negative cycles, schedules, search statistics and budget
errors matched the baseline CLI. Generated interfaces and PowerShell smoke
passed. The observed timings support retaining the 0.2.4 implementation.

The evidence file contains both source patches, binary hashes and ordered
samples. Join the `patch` array with newlines and add a final newline to
apply a candidate to a copy of the baseline with `git apply`. Build the
release CLI and library fixture with the pinned toolchain. Use
`scripts/benchmark-deep-search.mjs` and its `--library` mode as in the
deep-search reproduction. Use `scripts/benchmark.mjs` for the numeric
control. [Raw samples and candidate patches](planning-predecessor-review.json)

## Larger planning models — 2026-11-19

The verifier adds 98 independent comparisons against a fresh release build
of baseline `5389225` (0.2.4). Seed 169603 generates 48 models with 8–12
tasks on three resources and 48 variants with one shifted dependency.
The cases use all four endpoint pairs, bounded and open-ended lags, variable
durations, and tight windows starting near zero or 999,980.

The independent oracle enumerates integer task intervals and filters the
remaining domains against the original resource and dependency rules.
Two additional models reach 24 tasks and 64 dependencies on four resources.
In the feasible model, each resource fits six unit tasks into six slots.
In its overloaded counterpart, four tasks on one resource have just three
slots. The planner reached the expected conclusions in 5 and 47 nodes,
charging 645,235 and 6,069,709 work units respectively.

Of the 98 cases, 71 were feasible and 27 were unschedulable. The verifier
checked every returned schedule directly. In 46 feasible cases the planner
pruned at least one branch before finding a schedule. Both maximum-size
models reached their conclusions with exact budgets. Lowering either
budget by one returned the corresponding `limit_exceeded` error, and the
following batch item reached the original conclusion.

Local Windows debug and release each passed 25 unit tests, 4,096 numeric
networks and 1,794 planning cases, with identical baseline CLI outputs.
Generated interfaces matched Git and the PowerShell smoke checks passed.
The change extends verification. The published package is 0.2.4.

Run `node scripts/verify.mjs`, optionally with the absolute path to the saved
baseline CLI. The verifier writes per-case status and search statistics to
`_build/planning-verification.json`.

## Mooncakes 0.2.4 publication — 2026-11-19

Source `00c2841465c61af53d5c4442629106e26ebbed5f` passed Windows and Ubuntu
[CI run 44346830908](https://github.com/JingLan0v0/MoonSTN/actions/runs/44346830908).
An initial packaging attempt beneath an ignored build directory yielded zero
entries. The release package was generated in the clean Git checkout. All 71
files matched that source revision. The actual ZIP passed full debug/release
verification and PowerShell smoke after fresh extraction.

Preflight returned 202 and formal publication returned 200. The registry
recorded 2026-11-19 00:26:05 Asia/Shanghai. The public ZIP and preflight ZIP
share SHA-256 `2d2663159ae0409446f8f0ccce6827b62d192dd5aeabefad200ad74548622755`.
An independent consumer with an empty registry cache installed exactly 0.2.4.
All 71 installed files matched the ZIP, and both public API examples passed in
debug and release, including conflict certificates and planning budget recovery.
[Publication receipts](publication-0.2.4.json)

## Deep-search profiling and relaxation budget — 2026-11-19

Baseline `564faa9` runs the published 0.2.3 algorithms. Six unit-duration
tasks sharing a five-unit window require 1,439 nodes, 720 prunes, 719 decisions
and 3,885,037 work units to prove infeasibility. A 24-task, 64-dependency
single-resource case finishes in 24 nodes and 3,108,528 work units.

In a baseline CPU profile, relaxation accounted for 289 of 533 self samples
on the tight case and 35 of 202 on the maximum model. In a separate instrumented
public-library run (194 plan calls including two boundary errors), relaxation
took 499.8 ms of 717.3 ms total. Branch compilation took 149.7 ms inclusive,
of which the two array copies took 35.2 ms. Wrapper timing adds overhead.
A diagnostic library build omitting predecessor allocation and writes measured
46.56 ms vs 49.40 ms per 16 calls. This comparison includes code-generation
effects. The production change targets the relaxation loop and retains the
predecessors used to recover an ordered conflict certificate.

0.2.4 reserves a whole arc scan at the start of each Bellman–Ford pass. Each
started pass visits every arc before testing for early termination. An
insufficient budget raises the existing error, and all intermediate data are
local to that solve. The order of updates and the number of billable arcs
on a completed pass are identical.

| Windows release measurement | 0.2.3, ms | Candidate, ms |
|---|---:|---:|
| CLI, 32 tight unschedulable requests, round 1 | 193.00 | 184.80 |
| Same batch, reversed starting order, round 2 | 198.52 | 187.02 |
| Library, 16 calls on one prepared tight model | 48.60 | 45.38 |
| CLI, 16 maximum-model requests, rounds 1 / 2 | 105.51 / 110.00 | 103.63 / 110.91 |
| CLI, 64 maintenance requests, rounds 1 / 2 | 81.04 / 82.83 | 82.48 / 82.56 |

The tight CLI batches took 4.2% and 5.8% less time. Their median peak process RSS
was 52,120 / 52,184 KiB for baseline and 52,140 / 52,168 KiB for candidate.
The library median fell 6.6%. The ordinary and maximum-model controls varied
in direction. The numeric control exercised all six graph/budget combinations
and 30 extra budget checks. All measured outputs matched.

Reproduce with the pinned toolchain, Node 24.14.0 and two release CLI builds.
Run `node scripts/benchmark-deep-search.mjs BASE.js CANDIDATE.js`, then reverse
the arguments. Each case has two warm-up and nine measured pairs. Set
`MOONSTN_CPU_DIR` to an existing directory for separate baseline CPU profiles.
For each library build, copy `scripts/fixtures/deep-search-benchmark.mbt` as
`deepbench/main.mbt` and `examples/library/moon.pkg` as `deepbench/moon.pkg`,
then run `moon build deepbench --target js --release`. Pass both resulting JS
files to the same script after `--library`. Four alternating process pairs
each warm up three times and record nine samples.
[Timings, peak RSS, search statistics and profiles](optimization-0.2.4.json)

Local debug and release each passed 25 unit tests, including budgets 1 through
11 on a reusable negative-cycle network. All 4,096 numeric and 1,696 planning
oracle cases per mode also matched the 0.2.3 CLI. The PowerShell pipeline and
six scenarios passed. Generated public interfaces matched Git.

## Numeric solver performance recheck — 2026-11-18

Windows release builds used moon 0.1.20261028, moonc v0.10.18+6c83a7f62
and Node 24.14.0. Each source tree came from a separate Git archive of 0.2.1
(`e833a15`), 0.2.2 (`96da662`) or 0.2.3 (`6d97634`). The question was whether
the earlier 3.6% dense-network CLI slowdown could be reproduced.

Two CLI rounds per comparison used side-by-side JS files with identical extensions.
Each process handled eight 64-point networks. Each scenario had two warm-up pairs
and nine measured pairs in alternating order. The isolated, chain and dense graphs
ran with default and exhausted budgets. Results matched for every timed batch
and for all ten additional budget settings per graph. On the dense successful
case, 0.2.2 took 0.4% longer then 1.3% less time than 0.2.1. For 0.2.3 the changes
were +1.0% and −0.2%. A 7.1% isolated CLI increase in one 0.2.3 run reversed
direction in the other.

The library fixture times public solve calls on a prepared network, including one
bound lookup on success, and checks its checksum or budget error on every sample.
Each version used three processes per scenario per round, with three warm-ups and
nine timed samples per process. Driver order rotated and the second round reversed
the initial order. The short isolated pilot was repeated with 2,048 calls per sample.

| Library median ms, rounds 1 / 2 | Calls per sample | 0.2.1 | 0.2.2 | 0.2.3 |
|---|---:|---:|---:|---:|
| Dense, successful | 128 | 51.31 / 51.24 | 50.81 / 50.48 | 50.84 / 50.53 |
| Isolated, successful | 2,048 | 24.40 / 24.68 | 24.33 / 24.85 | 24.86 / 24.31 |

The two newer library drivers were byte-identical. Their timing variation provides
a same-code control. These runs did not reproduce a consistent dense solver
regression. The release stays at 0.2.3.
[Raw CLI samples, library samples, driver hashes and peak RSS](numeric-recheck-0.2.3.json)

Fresh Windows verification finished at 2026-11-18T15:36:19Z. Debug and release
each passed 24 unit tests. All 4,096 numeric networks and 1,696 planning cases
passed the independent checks and matched the 0.2.1 CLI results in both modes.
The PowerShell pipeline and six scenarios passed. All four generated interfaces
matched the tracked versions.

To reproduce, build each archived checkout with `moon build cmd/main --target js
--release --deny-warn`, save its CLI as a sibling `.js` file and run
`node scripts/benchmark.mjs BASELINE.js CURRENT.js` twice. For each library
driver, create a package directory named `numeric-bench` in its checkout. Copy
`examples/library/moon.pkg` and `scripts/fixtures/numeric-benchmark.mbt` from
this revision as `moon.pkg` and `main.mbt`. Build the package for release JS,
then pass the three compiled drivers to `node scripts/benchmark-numeric-library.mjs`
in reverse version order for round one and ascending order for round two.

## Mooncakes 0.2.3 publication — 2026-11-18

Source `8e443c52d9cc16b44cbf680913333e90b96081c1` passed Windows and Ubuntu
[CI run 44334121197](https://github.com/JingLan0v0/MoonSTN/actions/runs/44334121197).
Fresh extraction of the actual 64-file package passed full verification at
2026-11-18T15:18:58.930Z. Packaged installation commands target 0.2.3.

Preflight returned `202 Accepted` and formal publication returned `200 OK`.
The registry records 2026-11-18 23:20:25 Asia/Shanghai. The published archive and
independently downloaded ZIP share SHA-256
`9ec66bccadfdb068ffd3917d7471d22da2be6e422fd4097167e99cb01617aeb7`.
A new consumer with an empty registry cache installed exact version 0.2.3
without credentials or a workspace override. Both public API examples passed
in debug and release. All 64 installed files matched the registry ZIP.
[Mooncakes package](https://mooncakes.io/docs/JingLan0v0/stn@0.2.3) ·
[Machine-readable receipts](publication-0.2.3.json).

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

The checkout and a fresh extraction of the candidate package each passed 24 unit
tests, 4,096 STN oracle cases, and 1,696 independent planning oracle cases in each
build mode. Planning batch output matched 0.2.2. The regression with three
simultaneous conflicts asserts the order of branch selection and validation.
Generated public interfaces and PowerShell smoke passed.

To reproduce the CLI comparison, build both revisions and copy the 0.2.2 CLI
alongside the candidate with a separate `.js` filename. Pass its absolute path
to `node scripts/benchmark-planning.mjs`. For the library comparison, use
two [local consumers](local-consumer.md), one per checkout and matching version, with
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

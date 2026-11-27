# Acceptance evidence — updated 2026-11-27

Project MoonSTN / JingLan0v0/stn, published 0.2.33.

## Resource-order ID membership — 2026-11-27

At 0.2.33 the maximum standard model compared 1,518,000 active
path IDs per process with a maximum of 22 per branch. Adding 320
neutral root rules with the order prefix added 44,160,000 root
comparisons. Subtracting the median timer-only control gave about
8.6 ms and 74.3 ms for the standard and edited workloads.
Tight-window search compared 2,528,970 active IDs and used up to
14 per branch. The probe totals include warmups and budget checks.

The first two trials used a second set from the first visited child
or when the active list reached 32. The third reused the set built by
rule validation, removed the prefix scan, and retained generated IDs
for rollback. All three performed 138,000 indexed checks and zero
linear comparisons in the maximum edited workload.
The 32-entry trial left short standard paths on the linear scan.

| Paired workload | Index from first child | Index from 32 entries | Reuse validated IDs |
| --- | ---: | ---: | ---: |
| Standard maximum library | +1.0%, −0.5% | +0.3%, +0.6% | +0.4%, −0.2% |
| Tight-window library | +2.0%, −0.2% | +0.6%, −0.1% | −1.2%, +6.5% |
| First resource pair library | −0.7%, +1.1% | +1.9%, −1.5% | +0.3%, −1.1% |
| Edited maximum, 320 prefixed IDs | +1.9%, +0.7% | +0.7%, +0.3% | −4.2%, −1.5% |
| Edited root, 320 prefixed IDs | +1.1%, +1.0% | −1.5%, +0.3% | −3.7%, −9.8% |
| Edited maximum, 16 prefixed IDs | +0.2%, +1.9% | −1.0%, +0.9% | −0.7%, −1.6% |
| Maximum-model CLI latency | −2.3%, +0.3% | +2.0%, −1.8% | +8.2%, +0.4% |
| Tight-window CLI latency | +3.4%, +2.1% | +0.8%, +1.0% | +2.8%, +1.1% |
| Exact-budget CLI peak RSS | +0.2 MiB, −0.1 MiB | 0.0 MiB, +0.2 MiB | −0.5 MiB, −0.3 MiB |

Positive latency changes mean slower execution. Each pair of values
uses the two initial process orders. Same-binary changes were +0.1%
for the 320-ID library workload and −3.1% for maximum CLI time. The
reused index improved that edited library workload by 1.5–4.2%.
Standard maximum CLI time rose by 8.2% and 0.4%. This round retains
the 0.2.33 scan.

Eight CLI workloads matched byte for byte. The baseline and all three
trials passed 47 unit tests, 4,096 numeric networks and 1,794 planning
cases per mode, plus PowerShell smoke and generated interface checks.
The added regression exercises 48 prefixed root IDs across a 1,439-node
search and verifies sibling rollback, exact budgets, recovery after
exhaustion, and duplicate-ID precedence over the child work budget.
The reused-index trial also matched six numeric CLI workloads and
their low-budget cases in both process orders.

The report contains the source patches, the probes, the rollback
regression, raw measurements, and the eight output digests.
[Round data](planning-order-id-path-review.json)

## Generated resource-order endpoints — 2026-11-26

The 0.2.33 maximum feasible model performed 276,000 branch endpoint
lookups per process. Each endpoint was queried once within its plan.
The tight-window sample made 557,942 lookups, with 2,328 first lookups
across all calls. The approximate lookup time was 4.5 ms and 8.9 ms
after subtracting the empty timing control. The probe includes warmups
and the deep driver’s budget checks.

The lazy cache stores successful lookups within one plan. It reduced
the tight-window process to 2,328 map calls and left the maximum
feasible model at 276,000 calls. The positional check used the expected
timepoint name at a standard index and otherwise called the map.
It made zero branch map calls for the standard workloads. The moved-pair
test moved both shared tasks’ timepoints and made 12,000 map calls.
Both candidates resolved finish before start, after the same rule-count
and duplicate-ID checks.

| Workload | Lazy endpoint cache | Checked position |
| --- | ---: | ---: |
| Maximum-model library | −1.1%, −0.8% | −2.8%, +0.2% |
| Tight-window library | −6.9%, −2.8% | −2.0%, −4.6% |
| First resource pair library | −2.5%, −2.2% | +0.3%, +7.8% |
| Moved resource pair library | +5.2%, −2.9% | −2.8%, −5.6% |
| Four resources library | −3.1%, +2.9% | +0.9%, −0.3% |
| Maximum-model CLI latency | −0.6%, +1.0% | −0.6%, +1.6% |
| Tight-window CLI latency | −3.6%, +0.3% | −1.3%, −0.7% |
| Exact-budget CLI peak RSS | −0.2 MiB, +0.1 MiB | 0.0 MiB, 0.0 MiB |

Positive time changes mean higher latency. The values correspond to the
two initial process orders. Same-binary maximum-model and tight-window
CLI changes were +1.2% and +3.9%, respectively. Same-binary tight-window
library time varied by 5.3%. Both candidates had mixed maximum-model
CLI results. This round retains the 0.2.33 lookup.

Eight CLI workloads matched byte for byte. The baseline and both trials
passed 46 unit tests, 4,096 numeric networks, and 1,794 planning cases
in debug and release. Generated interfaces matched and PowerShell
smoke passed. The existing regressions cover missing and moved names,
the caller-added 25th task, rule limits, duplicate rule IDs, exact
budgets, and reuse after a failed solve. The moved-pair benchmark
also checked the expected ordering on every call.

The report contains the two source patches, generated-JS probes, the
moved-timepoint fixture, raw samples, and output digests.
[Round data](planning-order-endpoints-review.json)

## Pending resource-order stack — 2026-11-26

The 0.2.33 maximum-model probe executed 138,000 branch decisions and
reached 24 pending entries. Tight-window search executed 139,486
decisions and reached six pending entries. Subtracting the median
empty timer control gave roughly 5.5 ms and 4.0 ms of push work per
process, including warmups and the two deep budget probes.

The baseline executes seven object or array creations per decision
in the generated JavaScript. One array and two tuples hold the iteration input.
The two pending branch records retain one order tuple each. Two direct
pushes reduce the count to four. Storing endpoints in each record
reduces it to two. Both candidates preserved the decision counts
and peak pending stack. These counts describe executions of emitted creation expressions.
A JavaScript engine can sometimes eliminate physical allocations.

| Workload | Direct pushes | Endpoint fields |
| --- | ---: | ---: |
| Maximum-model library | −0.9%, +0.5% | −0.3%, +0.9% |
| Tight-window library | −4.2%, +0.1% | −3.6%, +0.7% |
| First resource pair library | −1.2%, −2.9% | +2.3%, +0.6% |
| Four resources library | +1.8%, +1.4% | +1.4%, −1.5% |
| Maximum-model CLI latency | −1.9%, −0.2% | −2.6%, −0.8% |
| Tight-window CLI latency | −0.3%, −3.7% | −0.9%, −1.9% |
| Exact-budget CLI peak RSS | −0.2 MiB, −0.4 MiB | −0.2 MiB, −0.3 MiB |

The two values per cell are the two initial process orders.
Positive time changes mean higher latency. The same-binary control
reported −0.9% for maximum-model library time and +2.5% for
tight-window CLI time. Library and CLI effects varied by workload and
order. The 0.2.33 implementation is retained.

Eight CLI workloads matched the baseline byte for byte. The baseline
and both candidates passed 46 unit tests, 4,096 numeric networks, and
1,794 planning cases per mode, with matching generated interfaces
and successful PowerShell smoke checks. The regressions cover the 0.2.0
schedule and statistics, edited graph endpoints, first conflict, sibling
backtracking, and exact and exhausted search budgets.

Build the release drivers with the pinned toolchain and saved fixtures.
The report embeds both patches, the probe sources, raw statistics, and
the eight CLI digests. [Round data](planning-branch-stack-review.json)

## Mooncakes 0.2.33 publication — 2026-11-26

This release includes the round 38 measurements and version metadata.
Its release CLI matches the 0.2.32 build after substituting the version string.
Source e3060c12113c6a0d885319784cd1dc32612b0191 passed Windows and Ubuntu
[CI run 45763903160](https://github.com/JingLan0v0/MoonSTN/actions/runs/45763903160).
The checkout, clean extraction and public archive passed 46 unit
tests, 4,096 numeric networks and 1,794 planning cases per mode.
PowerShell smoke passed and generated interfaces matched 0.2.32.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-26 14:06:31 Asia/Shanghai. The checked and public ZIP share SHA-256
6958919dc6382e2c4bc29ba2303ceb79a7b304ccc84ee66484a1f72434b22e85.
An empty-cache installation matched all 146 files and passed
three consumer checks per mode.
[Release receipts](publication-0.2.33.json)

## Planning potential buffer reuse — 2026-11-26

The 0.2.32 baseline creates a zero-filled array for every admitted search
node. A maximum-model library process created 144,000 arrays and wrote
7,056,000 slots. The tight-window process created 279,164 arrays and wrote
3,629,132 slots. Subtracting the median timer-only control gives about
12.8 ms and 16.1 ms for allocation and initialization, respectively.
These rough estimates include warmups and are about 1.5% and 6.5% of
the corresponding total relaxation times.

Both candidates reused one buffer within each plan and zeroed it before
every subsequent admitted node. They reduced the measured array counts to
6,000 for the maximum model and 194 for tight-window search. The same
number of slots were initialized. When all 64 calls were rejected at the
root work check, the eager candidate allocated 64 arrays. The baseline
and admitted candidate each allocated zero.

Relative changes below use the two initial process orders. Positive
latency changes mean the workload took longer.

| Workload | Eager allocation | Allocation after admission |
| --- | ---: | ---: |
| Maximum-model library | +2.0%, +4.7% | +1.3%, +1.9% |
| Tight-window library | −2.4%, −1.0% | +0.7%, −1.6% |
| Edited zero-origin library | +11.6%, +6.1% | +6.6%, +8.0% |
| Maximum-model CLI latency | +0.1%, −1.1% | +1.1%, −4.9% |
| Tight-window CLI latency | −1.1%, −2.3% | −0.5%, −1.5% |
| Exact-budget CLI peak RSS | −0.1 MiB, −0.1 MiB | −0.4 MiB, −0.1 MiB |
| Root work-limit CLI latency | +0.3%, −7.6% | −0.6%, −0.6% |

For the maximum model, the same-binary control measured +1.1% in the
library and −7.2% in the CLI. Both candidates increased library latency
in this workload. CLI latency and peak memory varied across paired runs.
This round retains the 0.2.32 implementation.

All eight CLI workloads matched by byte. The baseline and both candidates
passed 46 unit tests, 4,096 numeric networks and 1,794 planning cases in
each build mode, plus PowerShell smoke. The generated public interfaces
matched. The existing cases exercise sibling backtracking, exact node and
work limits, model reuse after failure, and independent schedule checks.

Build release drivers with the pinned toolchain and saved fixtures. The
report contains both source patches, the allocation probes, CLI digests,
and raw paired samples including the same-binary control.

[Round data](planning-potential-review.json)

## Mooncakes 0.2.32 publication — 2026-11-25

Source 0b1d8febbb9aceafbaaf0cb706ab8fa92e95713c passed Windows and Ubuntu
[CI run 45595638479](https://github.com/JingLan0v0/MoonSTN/actions/runs/45595638479).
The checkout, clean extraction and public archive each passed 46 unit
tests, 4,096 numeric networks and 1,794 planning cases per build mode.
PowerShell smoke passed. Generated public interfaces matched 0.2.31.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-25 18:32:13 Asia/Shanghai. The checked and public ZIP share SHA-256
e3e835aa462d9feeb1fe9241b5c9e2196b32b9dc1535646098bb5fb4a09cb2b9.
An empty-cache install matched all 144 files and passed 24 executables
per mode, including edited signed graphs at the maximum size.
[Release receipts](publication-0.2.32.json)

## Planning relaxation with validated weights — 2026-11-25

The 0.2.31 maximum-model library probe scanned 464,712,000 arcs over
1,944,000 passes. Relaxation took 1,707–1,723 ms per process including
warmups and timer overhead. Tight-window searches scanned 90,139,534 arcs
over 2,613,736 passes. Independent tasks needed two passes per call.

The trials compare distinct or packed endpoint fields with Double weights
converted from Int64, and distinct endpoints built directly from validated
Int32 weights. The chosen representation is compiled once for each planning
call. Each branch reuses the active arc array and appends its zero-weight
order arc. A path sums at most 64 × 1,024 weights of magnitude at most
1,000,000. Its magnitude stays below 2^36 even for inconsistent graphs,
and the origin-relative values fit exactly in binary64 before conversion
to the public Int64 schedule. Numeric solves still construct Int64 edges
and track certificate predecessors.

| Paired workload | Int64 conversion | Packed endpoints | Validated weights |
| --- | ---: | ---: | ---: |
| Library maximum | 35.0–36.2% faster | 36.8–38.6% faster | 33.0–41.0% faster |
| Library first conflict | 4.3–18.9% slower | 10.9–15.7% slower | 3.6–7.8% faster |
| Library tight-window | 30.0–32.7% faster | 26.3–31.0% faster | 27.2–31.4% faster |

The selected candidate's CLI maximum was 5.6–8.8% faster, the tight
window was 15.2–16.7% faster, and the one-work-unit-short
case was 3.3% slower and 9.2% faster. Maximum peak RSS changes were
-2.68 and -3.30 MiB across the two CLI orders. Its edited, zero-origin
library result was 8.2–14.9% slower. Seven CLI workload outputs
matched byte for byte in every run.

The signed edited-graph regression reaches 64 timepoints and 1,024
arcs. It checks a 63-step chain, a negative cycle beyond the Int32
potential range, exact work, one unit below, and error precedence.
It passed on 0.2.31 and on the candidate in both build modes.

[Source patches, raw samples, and probe](optimization-0.2.32.json)

## Mooncakes 0.2.31 publication — 2026-11-24

Source bff515884c6ea914e089663ed5af5a539331fb00 passed Windows and Ubuntu
[CI run 45346437789](https://github.com/JingLan0v0/MoonSTN/actions/runs/45346437789).
The checkout, clean extraction, and public archive each passed 45 unit
tests, 4,096 numeric networks, and 1,794 planning cases per mode.
PowerShell smoke passed in the checkout and clean extraction. Generated
public interfaces matched 0.2.30.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-24 15:17:18 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 c64b4c560418b495e8379b125f520178f768634ab5aab62b6ebe15a0d4a63e66.
An empty-cache installation matched all 142 package files and passed
23 executables per mode, including shifted and disconnected planning
origins and exact budgets on edited graphs.
[Release receipts](publication-0.2.31.json)

## Planning origin normalization — 2026-11-24

The 0.2.30 baseline shifts all feasible potentials by subtracting the
origin in a separate array pass. The raw origin was negative in every
feasible node across the nine standard workloads. Every normalization
in the edited, duration-only control saw a disconnected origin at zero.

The instrumented maximum-model process performed 144,000 normalization
passes and 7,056,000 subtractions. Normalization took 42.3–45.0 ms
and relaxation took 1,655.8–1,667.1 ms. The independent workload spent
8.1–8.9 ms normalizing and 8.7–9.0 ms relaxing. These process totals
include warmups and instrumentation overhead.

The selected change applies the same signed Int64 subtraction while
building scheduled tasks. A normal 24-task node shifts 48 task values
as it builds the schedule and skips the origin slot and a separate
writeback pass.

| Ordinary library workload | Zero-origin guard | In-place indexing | Fused construction |
| --- | ---: | ---: | ---: |
| Independent tasks | 7.1% slower, 4.3% faster | 8.9–9.3% faster | 11.0% faster in both runs |
| First resource pair | 12.3–19.4% slower | 0.7–3.2% slower | 2.9% faster, 1.3% slower |
| Edited zero origin | 5.5–10.8% faster | 2.6–5.3% faster | 9.6–14.5% faster |

The selected implementation improved the four-resource workload by
1.3–1.8%. The maintenance library workload took 2.2–4.9% longer. The
tight-window library changes were 0.5% faster and 1.3% slower, compared
with a 1.4% same-binary shift. All seven CLI outputs were byte-identical.
The maximum CLI took 1.3% less time and was effectively flat in the
reverse run. Median peak RSS at the exact budget dropped by 0.45–0.68
MiB. The one-work-unit-short CLI was flat and 2.1% slower.

A public API regression covers a nonzero origin with an extra timepoint,
a disconnected zero origin, negative returned task times on an edited
graph, and exact work accounting. It passed on 0.2.30 in both modes.
The saved benchmark fixture adds the edited zero-origin workload to the
existing planning driver. Add `zero-origin` to the ordinary runner's case
list when using that fixture. Build release drivers and run
`scripts/benchmark-deep-search.mjs` and
`scripts/benchmark-planning-library.mjs` in both argument orders.
[Measurements](optimization-0.2.31.json)

## Schedule construction after resource links — 2026-11-24

This round repeats the 0.2.29 schedule trials against 0.2.30, which uses
same-resource successor links after the first conflict. The new trials
build the root schedule as usual and read solved timepoint values for
linked conflict checks. A linked node builds the schedule when it
returns a feasible plan. The trials compare checked reads, direct
indexing after the root position checks, and inlining the schedule
builder with checked reads.

All three trials reached the same root and linked scan counts. Including
warmups and budget checks, the tight-window unschedulable process
constructed 836,916 task records at baseline and 1,164 in each trial.
The four-resource sample went from 3,024,000 to 288,000 records. The
maximum model went from 3,456,000 to 288,000, a 91.7% reduction. The
distinct-resource probe constructed 144,000 records in each build.

| Library case | Checked reads | Direct indexing | Inlined builder |
| --- | ---: | ---: | ---: |
| Four resources | 1.7–3.5% faster | 2.8–10.4% faster | 0.6% faster, 1.4% slower |
| Distinct resources | 9.0–13.9% slower | 2.0–7.8% slower | 9.8–15.1% slower |
| First conflicting pair | 2.0% slower, 2.3% faster | 5.8–10.0% slower | 0.3–3.6% slower |

Two direct-indexing CLI runs matched all seven baseline outputs by
byte, including exact, one-node-short and one-work-unit-short budgets.
Median peak RSS fell by 1.1–1.7 MiB across the three budget-boundary
workloads. The maximum CLI case took 2.0% longer in one order and
0.1% less time in the other. The two tight-window CLI changes were
1.3% faster and 1.4% slower.

This round retains the 0.2.30 implementation given the repeated
slowdown in ordinary resource layouts. The baseline and the
direct-indexing trial passed the full verifier in debug and release,
including edited timepoints, exact budgets and independent schedule
verification. Both checkouts passed PowerShell smoke.

Build release JS drivers from `scripts/fixtures/deep-search-benchmark.mbt`
and `scripts/fixtures/planning-benchmark.mbt`. Use
`scripts/benchmark-deep-search.mjs --library` for tight-window library
comparisons or pass two CLI binaries for CLI runs. Use
`scripts/benchmark-planning-library.mjs` for the ordinary cases.
The evidence includes the probe source, trial patches, output hashes,
and the paired timing and RSS samples.
[Measurements](linked-schedule-review.json)

## Mooncakes 0.2.30 publication — 2026-11-23

Source 5d0a62a8af19389d5ab9843baae38ce134f563a4 passed Windows and Ubuntu
[CI run 45185283523](https://github.com/JingLan0v0/MoonSTN/actions/runs/45185283523).
The checkout, clean extraction, and public archive each passed 44 unit
tests, 4,096 numeric networks, and 1,794 planning cases per mode.
PowerShell smoke passed in the checkout and clean extraction. The
generated interfaces matched 0.2.29.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-23 21:36:18 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 918bf067bfff1568209a7f33eae6f8f8d4a0e2db263f31b47d8a35feb518165c.
An empty-cache installation matched all 139 package files and passed
22 executables per mode, including edited resource pairs and exact
planning budgets.
[Release receipts](publication-0.2.30.json)

## Reusing same-resource task links — 2026-11-23

The 0.2.29 source compared resource IDs at every feasible search node.
In an instrumented process including warmups, the first-pair and
last-pair fixtures performed 1,662,000 and 3,312,000 ID comparisons.
The four-resource fixture made 22,716,000 comparisons and entered the
overlap predicate 4,140,000 times. The maximum shared-resource fixture
made 26,082,000 ID comparisons.

The selected implementation builds one successor array after the first
conflict. For each task it stores the next task with the same resource.
Following increasing indices preserves the original order of competing
pairs. The root scan handles no-conflict problems without building the
array. The four-resource and maximum fixtures made 342,000 and 144,000
ID comparisons, including setup and the root scan. The number of
overlap checks and visited feasible nodes matched in all nine probes.

| Library milliseconds per 500 calls | Baseline first | Candidate first |
| --- | ---: | ---: |
| Four resources, same-binary control | 41.271 → 41.907 | |
| Four resources, eager task pairs | 42.678 → 41.667 | 42.975 → 43.001 |
| Four resources, eager links | 42.832 → 40.972 | 44.910 → 41.873 |
| Four resources, links after the first conflict | 43.975 → 41.140 | 42.057 → 40.919 |
| One resource, links after the first conflict | 91.401 → 89.771 | 92.373 → 89.354 |
| Distinct resources, links after the first conflict | 5.774 → 6.035 | 5.433 → 5.378 |

The selected implementation took 2.7–6.4% less time for four resources
and 1.8–3.3% less for one resource. The eager-link trial took 7.6–14.9%
longer for distinct resources. The deferred trial had mixed timings
on that workload and in tight-window deep search.

All seven CLI outputs matched byte for byte. The maximum CLI model
took 0.8% longer and 3.7% less time. The one-node-short maximum model
took 1.6% and 8.6% longer, with a 4.9% shift in the same-binary control.

A new public API regression runs interleaved resource groups to assert
the first conflicting pair, error precedence at an exact budget, and
reuse after editing and restoring a task's resource. It passes on the
0.2.29 baseline in both modes.

Use `scripts/fixtures/deep-search-benchmark.mbt` and
`scripts/fixtures/planning-benchmark.mbt` to build the release drivers.
Use `scripts/benchmark-deep-search.mjs --library` for deep library
comparisons, or pass two CLI binaries to the same script for CLI
comparisons. Use `scripts/benchmark-planning-library.mjs` for the
ordinary cases. [Measurements](optimization-0.2.30.json)

## Schedule construction during resource search — 2026-11-23

The 0.2.29 baseline constructs one task record per task before checking
each feasible node for resource conflicts. The instrumented tight-window
process constructed 836,916 records for 139,486 feasible nodes and
returned no schedule. The maximum-model process constructed 3,456,000
records for 144,000 feasible nodes. Construction took 12.4–13.4 ms and
28.0–29.6 ms respectively per probed process, including warmups and
instrumentation overhead.

Three trials read solved positions directly and build the final schedule
after the conflict scan. The first uses checked indexing throughout.
The second relies on the task bounds check before the scan. The third
reads positions only after the resource IDs match. Each trial reached
the same feasible nodes, constructed zero task records in the
unschedulable case, and reduced the maximum-model count to 144,000.
The no-conflict maximum model still constructs one returned schedule.

| Library milliseconds per 16 tight-window searches | Baseline first | Candidate first |
| --- | ---: | ---: |
| Same-binary control | 41.046 → 40.066 | |
| Checked positional reads | 39.491 → 39.556 | 39.730 → 39.539 |
| Positional reads after one bounds check | 40.248 → 40.301 | 40.064 → 40.280 |
| Read only for matching resources | 41.360 → 39.625 | 39.238 → 39.122 |

The distinct-resource model took 9.6–13.0%, 11.6–13.9%, and 7.3–14.9%
longer for the three trials respectively. The same-binary control
differed by 2.3% for that case. The second trial reduced median peak RSS
by 1.3–1.5 MiB on the maximum model at the exact CLI budget. Each
trial's seven CLI workloads matched the baseline byte for byte,
including exact and one-unit-short budgets.

This round retains the 0.2.29 implementation. The baseline and final
trial passed the full verifier in debug and release, including edited
timepoints, exact budgets, and independent schedule verification.
The raw evidence includes candidate patches, the probe source and the
complete paired timing and peak RSS samples.

Build release JS drivers from `scripts/fixtures/deep-search-benchmark.mbt`
and `scripts/fixtures/planning-benchmark.mbt`. Use
`scripts/benchmark-deep-search.mjs --library` for the tight-window library
case and omit that option for CLI comparisons. Use
`scripts/benchmark-planning-library.mjs` for ordinary library cases.
[Measurements](planning-schedule-review.json)

## Mooncakes 0.2.29 publication — 2026-11-22

Source 239561c96b0dbb61bb4a2bae45c69500741f502d passed Windows and Ubuntu
[CI run 44995940871](https://github.com/JingLan0v0/MoonSTN/actions/runs/44995940871).
The checkout, clean extraction, and public archive each passed 43 unit
tests, 4,096 numeric networks, and 1,794 planning cases per mode.
PowerShell smoke passed in the checkout and clean extraction. The
generated interfaces matched 0.2.28.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-22 14:58:08 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 d40f2bc401bf40102f1c2897fc2cfe2f1010277b4a566a42d7f5118768bcc876.
An empty-cache installation matched all 136 package files and passed
21 executables per mode. These checks cover exact root and ancestor order
IDs, budget error precedence, and reuse after restoring the model.
[Release receipts](publication-0.2.29.json)

## Resource-order duplicate ID checks — 2026-11-22

The 0.2.28 probe counted 7,550,448 string comparisons for 278,971 child
checks in the tight-window process and 20,286,000 comparisons for 138,000
checks in the 24-task maximum process. Counts include warmup and budget
checks. The duplicate phase took 31.3–32.9 ms and 46.5–49.4 ms,
respectively, including instrumentation overhead.

The selected candidate tracks root IDs beginning with `order` and the
IDs appended during search. All other rules still count toward the
512-rule cap. Rollback removes the abandoned order IDs and arcs, and
duplicate checks still compare the complete ID before resolving endpoints.
The two probes counted 2,528,970 and 1,518,000 comparisons, reductions of
66.5% and 92.5%, with the same number of checks. The control maintenance
probe went from 72,000 comparisons to zero.

| Deep-search library milliseconds per 16 calls | Baseline first | Candidate first |
| --- | ---: | ---: |
| Same-binary control | 40.252 → 40.053 | |
| Reuse the validated hash set | 40.693 → 40.225 | 40.146 → 39.709 |
| Filter after the first conflict | 38.980 → 38.491 | 39.039 → 38.417 |
| Filter before search (selected) | 39.462 → 39.139 | 41.666 → 39.635 |

The deferred filter kept the same comparison counts. It also slowed the
unbranched maximum library case by 2.3–7.1% and the distinct-resource case
by 3.1–5.7%. The selected filter took 3.4–3.5% less time on the four-resource
workload and 1.5–2.2% less on the maximum with resource conflicts.
Independent tasks took 1.1% and 8.8% longer, with 6.7% variation in the
same-binary control.

The maximum CLI case with resource conflicts took 2.1% less time in one
run and 4.7% more in the other. The tight-window CLI was flat and 2.3%
slower. Median peak RSS for the no-conflict maximum CLI increased by
0.8–1.0 MiB. All seven outputs were byte-identical, including exact,
one-node-short and one-work-unit-short budgets.

A new public API regression covers edited root IDs that share a prefix,
a repeated ancestor order after timepoint moves, node and work error
precedence, and reuse after restoring the model. The regression passes
on 0.2.28 in debug and release.

Use `scripts/fixtures/deep-search-benchmark.mbt` and
`scripts/fixtures/planning-benchmark.mbt` to build the release drivers.
Run `scripts/benchmark-deep-search.mjs` with `--library` and two library
drivers or pass two CLI binaries directly. Use
`scripts/benchmark-planning-library.mjs` for the ordinary cases. The
evidence includes the instrumented scan source, trial patches, output
hashes, elapsed time and peak RSS samples.
[Measurements](optimization-0.2.29.json)

## Mooncakes 0.2.28 publication — 2026-11-21

Source ef243aa67f4d18b75e990a41a19f5516cb547114 passed Windows and Ubuntu
[CI run 44874377637](https://github.com/JingLan0v0/MoonSTN/actions/runs/44874377637).
The checkout, clean extraction, and public archive each passed 42 unit
tests, 4,096 numeric networks, and 1,794 planning cases per mode.
PowerShell smoke passed in the checkout and clean extraction. Generated
interfaces matched the previous version.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-21 14:13:01 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 afe027eb581c2c2b24138cdf64ab727f0412dc62eb4c67d89f4c1bb4ae600017.
An empty-cache installation matched all 134 package files and passed 20
executables per mode, including sibling restoration at the rule cap,
exact budgets, and reuse after errors.
[Release receipts](publication-0.2.28.json)

## Resource-order branch array reuse — 2026-11-21

The 0.2.27 tight-window probe performs 278,971 copies of each array
over one process, including warmups and budget checks. It copies
9,224,274 arc references and 7,550,448 rule ID references. The three
instrumented runs aggregate 16.0–16.7 ms in arc copies and 13.8–14.5 ms
in rule ID copies, including timer overhead. The full 24-task probe
copies 32,430,000 arc and 20,286,000 rule ID references per process.

In 0.2.28, each pending resource ordering remembers its parent's
rule count. The search keeps a private arc array and rule ID array
for the active path. Visiting a sibling pops one arc and one ID for
each abandoned order. The new order is checked before it is appended
to both arrays, preserving arc order, duplicate checks and node and work
budget precedence. A probe verifies the same number of accepted order
rules with zero per-branch array copies.

| Deep-search library milliseconds per 16 calls | Baseline first | Candidate first |
| --- | ---: | ---: |
| Reuse the rule ID array | 42.811 → 41.867 | 43.070 → 42.088 |
| Reuse both arrays (selected) | 43.118 → 40.755 | 42.700 → 39.973 |
| Same-binary control | 41.997 → 42.052 | |

The 24-task maximum library search took 4.5% and 3.4% less time. The
maintenance library case took 9.4% and 2.3% less time, with roughly 6%
variation in the same-binary control. Independent tasks took 0.7% and
3.6% longer. The last-pair workload changed direction across the two runs.

Tight-window CLI batches took 178.22 → 173.78 ms and 179.87 → 170.85 ms.
Same-binary medians were 179.22 and 181.19 ms. In the three maximum
model budget-boundary cases, median peak RSS fell by 2.7–3.2 MiB. The
maximum model at its exact budget took 0.1% and 0.5% longer. The CLI
maintenance control took 0.8% and 0.3% longer. All seven outputs,
including exact, one-node-short and one-work-unit-short budgets, are
byte-identical.

A public API regression backtracks between siblings at the 512-rule
cap, checks the exact schedule and work, exercises node and work
error precedence, and reruns the same model after edits and exhaustion.
It passes on 0.2.27 in debug and release. The deep fixture checks
1,439 nodes, 720 prunes, 719 decisions, and 3,885,037 work units.

Build the JS release library drivers from
`scripts/fixtures/deep-search-benchmark.mbt` and
`scripts/fixtures/planning-benchmark.mbt`. Use `--library` on
`scripts/benchmark-deep-search.mjs` for the deep library case or pass
two CLIs for the end-to-end comparison. Run
`scripts/benchmark-planning-library.mjs` for the ordinary library cases.
The evidence contains both probes, trial patches, output hashes, and
the uninstrumented timing and memory samples.
[Measurements](optimization-0.2.28.json)

## Mooncakes 0.2.27 publication — 2026-11-21

Source f6066c74d9b912f746c2cf8795d34c8bef29d7fc passed Windows and Ubuntu
[CI run 44873022025](https://github.com/JingLan0v0/MoonSTN/actions/runs/44873022025).
The checkout, clean extraction, and public archive each passed 41 unit
tests, 4,096 numeric networks, and 1,794 planning cases per mode.
PowerShell smoke passed in the checkout and clean extraction. Generated
interfaces matched the previous version.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-21 13:55:53 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 1710edf657f375136bd7f4866b0a3b93fe4d174e5e91f1ec7581ca566947f163.
An empty-cache installation matched all 132 package files and passed 19
executables per mode, including moved and caller-appended timepoints at
exact planning budgets.
[Release receipts](publication-0.2.27.json)

## Resource-order branch names — 2026-11-21

The 0.2.26 tight-window fixture visits 1,439 nodes and compiles 1,438
child rules per complete search. Each child converts two positions for
its rule ID and converts them again for the two timepoint names. The
probe counted four conversions and two name lookups per child. Across
the instrumented process, the two endpoint operations took 28–30 ms,
including the probe overhead.

Version 0.2.27 reuses point names for the constructor's 24 supported
positions and uses the existing numeric suffixes for any positions later
appended through the public model arrays. It converts each position once
per child. The name map still resolves both endpoints in their current
positions after the duplicate ID check. The probes count the same number
of child rules and lookups, with half the conversions.

| Deep-search library milliseconds per 16 calls | Baseline first | Candidate first |
| --- | ---: | ---: |
| Share numeric suffixes | 44.184 → 43.813 | 44.273 → 43.520 |
| Reuse canonical names (selected) | 44.507 → 43.148 | 42.494 → 41.541 |
| Check each expected position before name lookup | 42.108 → 41.806 | 43.146 → 41.622 |
| Reuse names and check each expected position | 42.469 → 41.450 | 42.054 → 41.046 |

The same-binary deep library medians were 42.864 and 43.069 ms.
The selected trial resolves names through the existing map and had a
similar gain to the combined positional trial. The ordinary maintenance library case
varied from 4.8% faster to 5.0% slower. The distinct-resource control took
1.3–2.0% longer, and the four-resource case took 2.5–4.4% less time.

Tight-window CLI batches took 186.32 → 184.62 ms and 183.41 → 183.30 ms.
Same-binary medians were 179.29 and 181.09 ms. The maximum-capacity case
with exact budgets took 2.5% and 0.9% longer. All seven batch outputs
matched byte for byte, including both one-unit-short budgets.

Two new direct API regressions compare moved timepoints and a caller-added
25th task, with exact budgets and independent schedule verification. Both
passed on 0.2.26 in debug and release. Existing regressions check unknown
timepoint names, duplicate rule IDs, error precedence, and model reuse.

Build the JS release library drivers from
`scripts/fixtures/deep-search-benchmark.mbt` and
`scripts/fixtures/planning-benchmark.mbt`. Use `--library` on
`scripts/benchmark-deep-search.mjs` for the deep library case or pass two
CLIs for the end-to-end comparison. Run
`scripts/benchmark-planning-library.mjs` for the ordinary library cases.
The evidence file contains the probe and trial patches, raw samples and
output hashes. [Measurements](optimization-0.2.27.json)

## Mooncakes 0.2.26 publication — 2026-11-21

Source 14c0af28a8602d67136e859292a8f5351736aa55 passed Windows and Ubuntu
[CI run 44870529441](https://github.com/JingLan0v0/MoonSTN/actions/runs/44870529441).
The checkout, clean extraction, and public archive each passed 39 unit
tests, 4,096 numeric networks, and 1,794 planning cases per mode.
PowerShell smoke passed in the checkout and clean extraction. Generated
interfaces matched the previous version.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-21 13:24:26 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 b0bee694fb5a33f95d2e8a00822e861d1baf231a7fe07fdab9b329bb9d26b33d.
An empty-cache installation matched all 130 package files and passed 18
checks per mode, including all 24 positional rule groups and fresh model
construction after editing an earlier model.
[Release receipts](publication-0.2.26.json)

## Planning task timepoint and rule names — 2026-11-21

The 0.2.25 constructor converted each validated task index to text five
times for two timepoints and three rules. The JS probe counted 120
conversions in each 24-task construction. The selected implementation
precomputes the 24 suffixes and 120 names at module initialization. Model
construction reads the fixed names and still creates fresh model arrays
and rules with per-task bounds. The probe counted zero task index
conversions per construction. Dependency rule IDs have their own sequence.

The two local reuse trials converted each index once per construction
and either reused the suffix or reused the timepoint prefix. Their timing
direction varied with run order. The trial that cached only the suffixes
improved several large workloads and slowed one small workload by about 7%.
The table of complete names improved all eight library workloads in
both orders.

| Library milliseconds per 1,000 constructions | Baseline first | Candidate first |
| --- | ---: | ---: |
| 2 tasks, no dependencies | 0.432 → 0.359 | 0.451 → 0.342 |
| 24 tasks, no dependencies | 2.706 → 1.386 | 2.555 → 1.127 |
| 24 tasks, mixed dependency kinds | 5.325 → 4.263 | 5.559 → 4.204 |
| Long task IDs | 15.595 → 14.516 | 14.396 → 12.994 |
| Unknown endpoint in final dependency | 6.161 → 4.448 | 5.567 → 4.243 |

The full CLI maximum model took 121.30 → 121.45 ms and 120.25 → 122.33 ms.
The wide schedule took 104.20 → 102.00 ms and 102.50 → 103.76 ms. The
maintenance control took 84.29 → 83.00 ms and 80.56 → 81.81 ms.
The same-binary control varied by up to 8.9%. The largest change in median
peak RSS was about 0.75 MiB, in the late unknown endpoint workload.
All eight CLI outputs matched by byte in both orders.

The direct API regression checks the order, names and bounds of the
72 built-in rules, all 49 timepoint names, the schedule at the exact
budget, independent witness verification and model isolation after
editing the first model. The regression passed on 0.2.25 in both modes.
The full verifier covers the other exact budgets and the short cases.

Build the JS release drivers from
`scripts/fixtures/planning-benchmark.mbt`. Run
`scripts/benchmark-planning-library.mjs` with
`MOONSTN_BENCH_PLAN_CONSTRUCTION=1` and `MOONSTN_BENCH_PLAN_KINDS=1`.
For the CLI, run `scripts/benchmark-planning-results.mjs` with
`MOONSTN_BENCH_PLAN_ENDPOINTS=1`. The evidence file contains all
paired samples, peak RSS, trial patches, and the conversion probe.
[Measurements](optimization-0.2.26.json)

## Mooncakes 0.2.25 publication — 2026-11-21

Source 37fda1da96557d9b30144ca880136ca92193d17d passed Windows and Ubuntu
[CI run 44867002175](https://github.com/JingLan0v0/MoonSTN/actions/runs/44867002175).
The checkout and clean extraction passed 38 unit tests, 4,096 numeric
networks, and 1,794 planning cases per mode. PowerShell smoke and
generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-21 12:39:02 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 4683a3ef53f81de3d1d7745dcbc76641a5b9f7d4ecb39a57a9dcfda4ffe983f9.
An empty-cache installation matched all 128 published files and passed 17
checks per mode, including all four dependency kinds. Both builds from
the public ZIP passed the full verifier and comparisons with 0.2.24.
[Release receipts](publication-0.2.25.json)

## Planning dependency timepoint names — 2026-11-21

The 0.2.24 constructor built 48 task timepoint names and rebuilt another
128 names for the endpoints of 64 dependencies. The selected version reads
the endpoints from the existing table, which starts with the origin and
then lists the start and finish of each task. Probes counted 176 versus 48
name constructions per full model. The rule timer includes endpoint role
checks, name construction or table reads, rule insertion, and timer
overhead. Its elapsed values are separate from the uninstrumented runs.

A second trial handled all four dependency kinds in one match. Its gains
were similar across the construction cases. The selected implementation
keeps the smaller change to the two endpoint name expressions.

| Library milliseconds per 1,000 constructions | Baseline first | Candidate first |
| --- | ---: | ---: |
| 24 tasks, no dependencies | 2.673 → 2.688 | 2.779 → 2.749 |
| Spread endpoints | 7.132 → 5.579 | 7.127 → 5.762 |
| Mixed FS, SS, FF and SF | 7.490 → 5.520 | 6.829 → 5.498 |
| Long task IDs | 16.332 → 14.526 | 16.021 → 14.433 |
| Unknown endpoint in final dependency | 7.445 → 5.846 | 7.082 → 5.623 |

CLI timings had mixed directions. The full model took 126.21 → 123.12 ms
and 126.68 → 129.25 ms. The low-work control took 88.80 → 99.49 ms and
80.93 → 79.02 ms. The same-binary control varied by as much as 6.3%.
All eight CLI outputs matched byte for byte in both orders.

The new direct API test checks the names, order and signed exact lags of
rules, plus a fixed schedule and its independent verification. The test
also passes on the baseline. The full verifier covers exact node and work
budgets and the one-unit-short cases.

Use the JS release drivers built from `scripts/fixtures/planning-benchmark.mbt`
and run `scripts/benchmark-planning-library.mjs` with
`MOONSTN_BENCH_PLAN_CONSTRUCTION=1` and `MOONSTN_BENCH_PLAN_KINDS=1`.
Set `MOONSTN_PROFILE_PLAN_POINTS=1` for probes. Use
`MOONSTN_BENCH_PLAN_ENDPOINTS=1` with `scripts/benchmark-planning-results.mjs`
for the CLI workloads. [Measurements](optimization-0.2.25.json)

## Mooncakes 0.2.24 publication — 2026-11-20

Source 4d8009fa86787482dd738df5bd8c08a77094f6b8 passed Windows and Ubuntu
[CI run 44699259280](https://github.com/JingLan0v0/MoonSTN/actions/runs/44699259280).
The checkout and clean extraction passed 37 unit tests, 4,096 numeric
networks, and 1,794 planning cases per mode. PowerShell smoke and
generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 20:36:27 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 0eb3a71cd72aa5eccc9beb4fad8753d311d169b9d45d71c3e5441bfe2d029839.
The consumer endpoint fixture needed explicit return types. The corrected
fixture passed with a fresh registry cache. Both modes passed 16 checks,
and all 126 installed files matched the archive. Both builds from the
public ZIP passed the full verifier and baseline comparisons.
[Release receipts](publication-0.2.24.json)

## Planning task ID lookup — 2026-11-20

The 0.2.23 constructor scanned task IDs separately for each dependency
endpoint. A 24-task, 64-dependency spread fixture made 128 endpoint calls
and 1,520 string comparisons per construction. Checks for an endpoint in
position zero or one needed one or two comparisons. Timing probes include
their own overhead and count those operations separately from the paired
construction timings.

An all-map trial sped up short IDs and slowed the 63–64-character case by
30–36% in the expanded runs. Tests at 8, 16, and 32 characters located the
point where the gain tapered off. The selected constructor stores task
positions in the validation map, reserves room for larger models, and
uses direct scans for up to four tasks, IDs longer than 16 characters,
and the first two positions. The spread fixture then made 250 string
comparisons and 116 map lookups. The benchmark driver compiled from the
final source matched the measured selected driver byte for byte.

| Library median in milliseconds per 1,000 constructions | Baseline first | Candidate first |
| --- | ---: | ---: |
| Two tasks, one dependency | 0.457 → 0.505 | 0.504 → 0.504 |
| 24 tasks, no dependencies | 2.694 → 2.501 | 2.681 → 2.480 |
| First two endpoints | 5.635 → 5.451 | 6.081 → 5.571 |
| Spread endpoints | 9.627 → 6.568 | 9.716 → 7.027 |
| 16-character IDs | 13.623 → 11.713 | 13.092 → 11.493 |
| 63–64-character IDs | 16.937 → 16.143 | 16.622 → 16.217 |
| Unknown endpoint in final dependency | 10.084 → 7.074 | 9.805 → 7.019 |

On the full CLI, the maximum-model batch took 1.5% and 2.6% less time.
Maintenance took 0.7% and 0.4% more time, and the late-unknown CLI batch
took 0.4% and 0.3% more. The two-task constructor was about 0.05 ms per
1,000 builds slower in one order and essentially flat in the other.
All eight CLI workloads matched output bytes in both orders.

Public API tests check exact endpoint positions, prototype-like and
numeric-looking IDs, duplicate task IDs, `before` and `after` error order,
and independently verified schedules. These tests pass on the baseline
source too. The existing planning oracle exercises the exact node and
work budgets and recovery after exhaustion.

Copy `scripts/fixtures/planning-benchmark.mbt` as `main.mbt` and
`examples/library/moon.pkg` into an executable package named `lookupbench`.
Build JS release drivers for both revisions. Run
`scripts/benchmark-planning-library.mjs` with both drivers and
`MOONSTN_BENCH_PLAN_CONSTRUCTION=1`. Set `MOONSTN_BENCH_PLAN_ID_LENGTHS=1`
for the length sweep or `MOONSTN_PROFILE_PLAN_ENDPOINTS=1` for lookup probes.
Set `MOONSTN_BENCH_PLAN_ENDPOINTS=1` for the CLI cases in
`scripts/benchmark-planning-results.mjs`. [Measurements](optimization-0.2.24.json)

## Mooncakes 0.2.23 publication — 2026-11-20

Source edb9ee95278ba608355dc7379e08595fad8c178d passed Windows and Ubuntu
[CI run 44684836537](https://github.com/JingLan0v0/MoonSTN/actions/runs/44684836537).
The checkout and clean extraction passed 35 unit tests, 4,096 numeric
networks, and 1,794 planning cases per mode. PowerShell smoke and
generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 14:03:10 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 140aaedbe116cdfaa282cdec1c755fbb753509bde4984ca6f0e438429997d085.
A fresh consumer passed 15 executable checks per mode, including the
planning batch field regression. All 124 installed files matched the
archive. Both builds from the public ZIP passed the full verifier and
baseline comparisons.
[Release receipts](publication-0.2.23.json)

## Planning JSON dependency fields — 2026-11-20

On 0.2.22, 64 requests with 24 tasks and 64 dependencies each spent
12.61 ms processing request fields before constructing the model.
Unknown-field scans took 0.37 ms for tasks and 0.91 ms for dependencies.
Required lookups took 2.93 ms, optional lookups 0.57 ms, and integer
validation 1.62 ms. The timers include probe overhead and report nested
components separately.

Three trials compared known-key lookup reuse, a single ordered pass on
both object types, and a single pass on dependencies. The first two
increased peak RSS in multiple maximum-size success cases. The selected
dependency parser collects known values while checking unknown keys in
input order. It then validates the optional maximum lag and required
values in their previous order. In a phase comparison, maximum-size
request field processing took 13.21 → 9.63 ms.

| CLI median in milliseconds per batch of 64 | Baseline first | Candidate first |
| --- | ---: | ---: |
| Maintenance | 88.84 → 86.62 | 85.76 → 84.84 |
| Standard maximum-size model | 123.57 → 125.16 | 124.80 → 126.22 |
| Optional fields omitted | 119.61 → 118.50 | 119.20 → 118.12 |
| Optional fields null | 129.15 → 121.39 | 122.92 → 120.62 |
| Optional fields with values | 123.01 → 121.37 | 124.24 → 121.71 |
| Unknown field in the final dependency | 105.37 → 104.41 | 106.97 → 106.48 |

On a final dependency error, peak RSS fell by 1,228 and 1,092 KiB.
The unschedulable control took 4.7% and 0.2% longer. The standard
maximum-size model took 1.3% and 1.1% longer, within its same-binary
control spread. All 11 payloads matched output bytes in both orders.

The fixed regression checks omitted, null, and present optional values,
an exact schedule, unknown field order, optional-before-required errors,
rounded fractions in maximum lag, and batch recovery. The planning oracle
also checks exact node and work budgets, each one unit below the limit,
and recovery on a repeated valid request.

Run `scripts/benchmark-planning-results.mjs` with both release JS CLIs.
Set `MOONSTN_BENCH_PLAN_FIELDS=1` to include field fixtures or
`MOONSTN_PROFILE_PLAN_FIELDS=1` to time request fields and nested components.
[Measurements](optimization-0.2.23.json)

## JSON decode and number text review — 2026-11-20

On 0.2.22, dense numeric and planning batches spent 18–22 ms in the
core JSON decoder and 1.3–2.4 ms in MoonSTN preflight. The decode-only
control used the same binary and changed the core retention flag. The
observed core medians were 0.31–1.88 ms lower across the larger cases
with the flag disabled. The probes time both phases before serialization.

The flag control kept the same rounded numeric values and changed the
text of `-0`, `0.00`, `1.00000000000000001`, `1e-400`, and `1E+003`.
Replaying the hidden fraction and the nonzero underflow through both
CLI batch APIs demonstrated the loss of exact validation. Each input
was rejected by the released binary and accepted by the flag control.

Two scanner trials kept retention and the core grammar. Consolidating the
character checks slowed the dense scan. Checking the depth only at opening
delimiters reduced the padded-input scan from 3.83 to 3.13 ms and from 3.81
to 3.28 ms. The same trial took 1.3% more CLI time on dense numeric decimals
in each order. It shortened the dense plain planning batch by 0.7–0.9%,
within the 2.2% same-binary control difference. Planning exponents showed
different gains across orders, with one unusually slow baseline. Both
trials matched all 13 retained decode outputs and all 11 CLI outputs.

The released parser is retained. A public API regression verifies exact
round-tripping of negative zero, trailing zeros, an underflow spelling,
exponent spelling, a rounded fraction, and a wide integer in a nested
object. The verifier also exercises duplicate keys, string and nesting
limits, scan-count boundaries, and mixed-batch recovery in both modes.
The checkout passed 35 unit tests, 4,096 numeric networks, and 1,794
independent planning cases per mode, along with PowerShell smoke and
generated interface checks. The verifier compared results with the
0.2.22 release CLI.

Set `MOONSTN_BENCH_JSON_DECODE=1` and run
`scripts/benchmark-integer-spellings.mjs` with one release JS CLI to measure
the retention flag, or pass two CLIs to compare their retained decode phases.
Run the same script without that setting for full CLI measurements.
[Measurements and control outputs](json-decode-review.json)

## Mooncakes 0.2.22 publication — 2026-11-20

Source d77841238c35475ae4698ea12f14361f95dd8f26 passed Windows and Ubuntu
[CI run 44680632988](https://github.com/JingLan0v0/MoonSTN/actions/runs/44680632988).
The checkout and clean extraction passed 34 unit tests, 4,096 numeric
networks, and 1,794 planning cases per mode. PowerShell smoke and
generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 13:24:38 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 f623d19a70ebe5d21a54ef2c4136ced9286881c8471ebc1f13d7ffe0cbd8ef87.
A fresh consumer passed fourteen executable checks in each mode, including
long spellings through both public batch APIs. All 121 installed files
matched the archive, and both builds from the public ZIP passed the full
verifier and baseline comparisons.
[Release receipts](publication-0.2.22.json)

## Exact integer spellings — 2026-11-20

On 0.2.21, dense numeric CLI batches spent 1.1–1.8 ms checking integer
spellings and 20–24 ms decoding JSON. Phase timers include probe overhead.
The selected implementation records how many mantissa digits precede
the point and the position of the last nonzero digit. The difference
gives the smallest exponent that makes the number integral. Zero and
the saturating exponent scan retain their previous handling.

| Direct spelling median in milliseconds | Calls per sample | Baseline first | Candidate first |
| --- | ---: | ---: | ---: |
| Ordinary integers | 400,000 | 5.76 → 4.93 | 5.97 → 5.16 |
| Decimals | 400,000 | 10.82 → 8.93 | 11.36 → 9.31 |
| Exponents | 400,000 | 8.16 → 7.74 | 8.00 → 7.44 |
| Long fractional tails | 18,000 | 5.76 → 4.25 | 5.89 → 4.14 |
| Long exponents | 7,500 | 3.97 → 4.02 | 3.99 → 3.88 |

The direct benchmark extracts the generated spelling function and times
it in one Node process. In both full CLI pairings, the planning decimal
batch took 2.0–2.3% less time and the dense plain numeric batch took
0.4–3.7% more time. Late-fraction and planning exponent results changed
direction with the pairing order. The long numeric decimal validation
phase went from 1.05 to 0.88 ms with probes enabled. Eleven numeric and
planning payloads matched output bytes in both orders.

Fixed checks exercise negative zero, long runs of trailing zeros, large
signed exponents, rounded fractions, underflow, and normal batch recovery.
The public JSON API test covers caller-constructed numbers with and without
spelling, Unicode in a spelling, and the spelling length limit. The same
test passes on the 0.2.21 source.

Run `scripts/benchmark-integer-spellings.mjs` with the two release JS CLIs
in both orders. Set `MOONSTN_BENCH_INTEGER_KERNEL=1` for direct checks or
`MOONSTN_PROFILE_INTEGER_SPELLINGS=1` to time the spelling and decode phases.
The evidence preserves sample timings and memory, hashes, and candidate patches.
[Measurements](optimization-0.2.22.json)

## Mooncakes 0.2.21 publication — 2026-11-20

Source bd963fe61160a547688317103fb52798e93e07ae passed Windows and Ubuntu
[CI run 44670736679](https://github.com/JingLan0v0/MoonSTN/actions/runs/44670736679).
The checkout and clean extraction passed 33 unit tests, 4,096 numeric
networks, and 1,794 planning cases per mode. PowerShell smoke and
generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 11:55:18 Asia/Shanghai. The checked and public ZIP archives share
SHA-256 b4cdd3fbc29735dd9eac6bab7fed1850022a8acfdd9f96647afe412d92f3b37d.
A fresh consumer passed thirteen executable checks in each mode, including
the public numeric batch API with the fixed field cases. All 118 installed
files matched the archive, and both builds from the public ZIP passed
the full verifier and baseline comparisons.
[Release receipts](publication-0.2.21.json)

## Numeric constraint fields — 2026-11-20

On 0.2.20, a batch of twelve 64-point models with 512 two-sided
constraints each spent about 1.32 ms checking keys, 1.77 ms reading
required fields, and 3.97 ms handling bounds. The bound time includes
1.47 ms of exact number validation. Timers wrap generated JS functions
and include probe overhead.

The selected parser reads the five supported keys once. When required
keys are present and the recognized keys account for the whole object,
it proceeds directly to validation. Other shapes use the existing
ordered key scan. A present null value counts as a key. A single-pass
map iteration also helped several cases, while the selected approach
consistently reduced peak RSS on late format errors and dense two-sided
models.

| CLI median, milliseconds per batch | Baseline first | Candidate first |
| --- | ---: | ---: |
| Ordinary | 81.55 → 82.11 | 82.47 → 81.92 |
| 512 one-sided constraints | 113.96 → 112.44 | 111.79 → 112.88 |
| 512 two-sided constraints | 118.21 → 116.57 | 117.67 → 115.88 |
| 512 explicit null lower bounds | 114.79 → 114.03 | 115.52 → 113.93 |
| Unknown field on the final constraint | 106.27 → 102.85 | 104.72 → 100.23 |

The final-constraint error batch used 3.72–3.74 MiB less peak RSS.
The two-sided batch used 1.71–1.89 MiB less. The one-sided timing
changed direction between final pairings.

Eleven numeric and six planning payloads matched byte for byte. The
64-point cycle control ran 1.2% longer and the largest planning-model
control ran 1.3% longer in their broader single pairings.

Fixed cases check reordered and escaped keys, missing and explicit null
bounds, missing and wrongly typed required fields, and exact decimal and
exponent spellings. Underflow and a fractional digit hidden by rounding
are rejected. Unknown-field, required-field, and bound diagnostics appear
in their original order, and later valid batch requests recover.

Run `scripts/benchmark-numeric-results.mjs` with both release JS CLIs.
Set `MOONSTN_BENCH_NUMERIC_CONSTRAINTS=1` for focused cases or
`MOONSTN_PROFILE_NUMERIC_CONSTRAINTS=1` for phase probes.
[Measurements](optimization-0.2.21.json)

## Mooncakes 0.2.20 publication — 2026-11-20

Source 0f3441a5ae187cf96b6d9f5e9631390db39f6325 passed Windows and Ubuntu
[CI run 44668287570](https://github.com/JingLan0v0/MoonSTN/actions/runs/44668287570).
The checkout and clean extraction passed 33 unit tests, 4,096 numeric
networks, and 1,794 planning cases per mode. PowerShell smoke and
generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 11:32:59 Asia/Shanghai. The public and checked ZIP archives share
SHA-256 6a77800a2cbaa2e0525620b4af1e8ac0e5ba580234afa8332a29c468f5af7249.
An empty-cache consumer passed twelve API checks in each mode, and all
116 installed files matched the public archive. Both CLI builds from the
public download passed the full verifier, including the fixed model suite.
[Release receipts](publication-0.2.20.json)

## Numeric model validation — 2026-11-20

On 0.2.19, a batch of twelve 64-point models with 512 two-sided
constraints each spent a median 12.69 ms parsing and validating models.
Validation and edge construction took 5.87 ms of that time, while field
checks took 1.92 ms. The subsequent arc reindexing took 0.95 ms. These
release JS phase probes include instrumentation overhead.

The selected implementation scans ASCII names and IDs directly, reserves
capacity for the validation tables, checks duplicate IDs at insertion, and
checks both bounds without a temporary array. The arc-reuse-only trial was
inconsistent across workloads and increased peak memory on late query errors
by 2.6 MiB. The final implementation retains the existing reindexing step.

| CLI median, milliseconds per batch | Baseline first | Candidate first |
| --- | ---: | ---: |
| Ordinary | 84.66 → 82.71 | 82.03 → 83.42 |
| 512 one-sided constraints | 113.50 → 112.53 | 115.08 → 114.55 |
| 512 two-sided constraints | 120.35 → 117.32 | 122.38 → 118.58 |
| 512 two-sided constraints with 64-character IDs | 128.49 → 121.86 | 127.90 → 122.60 |
| Late query error after 512 two-sided constraints | 111.27 → 109.40 | 110.96 → 108.50 |

The corresponding long-ID phase comparison went from 19.20 to 12.53 ms in
model handling and from 12.52 to 6.58 ms in validation and edge construction.
The long-ID peak RSS rose by 188 and 604 KiB in the final CLI runs. In the
broader run, four-query and cycle controls took about 1.3% longer and the
mixed batch took 1.5% less time. Eleven distinct payloads matched output bytes.

The fixed mixed-batch regression compares 0.2.19 and the candidate byte for
byte. It covers 64-character IDs, invalid Unicode and overlength IDs, parse
errors before model errors, duplicate IDs and ordered endpoint errors,
missing bounds, exact ±1,000,000 bounds, a two-sided negative-cycle
certificate, one step short of budget, and recovery after prior failures.

Run `scripts/benchmark-numeric-results.mjs` with the two release JS CLIs in
both orders. Set `MOONSTN_BENCH_NUMERIC_MODEL=1` for the focused cases or
`MOONSTN_PROFILE_NUMERIC_MODEL=1` for instrumented phase measurements.
The evidence preserves raw samples, output and binary hashes, and trial patches.
[Measurements](optimization-0.2.20.json)

## Mooncakes 0.2.19 publication — 2026-11-20

Source c451f766594cb782d0a2c7b5d30e8579c1a1a431 passed Windows and Ubuntu
[CI run 44569268968](https://github.com/JingLan0v0/MoonSTN/actions/runs/44569268968).
Both modes passed 33 unit tests, 4,096 numeric networks, 256 signed network
bounds, 256 signed wide-tree bounds and 1,794 planning cases locally and
after extraction. PowerShell smoke and generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 00:45:17 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 b2542af57d996fa6bc477888c67acf7ebf35d052301f5d0d4d03578d7dfbba8e.
An empty-cache installation passed the public API checks in both modes.
The rebuilt public CLI passed wide-closure and exact-budget checks in both
modes. All 114 installed files matched the archive.
[Release receipts](publication-0.2.19.json)

## Sparse column scans in the wide closure — 2026-11-20

Baseline b0683a0 was measured on Windows release JS and Node 24.14.0.
A 64-point chain checked 129,024 columns per solve, of which 125,055
were unreachable. The branching fixture missed 16,431 of 16,896
checks, and the disjoint chains missed 29,820 of 30,720. Separate
phase timings measured about 157 microseconds for the chain closure,
32 for the branching fixtures and 47 for the disjoint chains.
Instrumentation overhead is included.

The selected version collects finite column indices lazily and reuses
them for reachable rows. The pivot row retains ordered scanning when
its diagonal is nonzero, then invalidates the indices. The closure
budget still counts all logical triples. A variant also stored the
weights in scratch memory. Index-only enumeration has comparable
sparse gains and needs one scratch array.

| Library median, ms per 128 solves | Baseline first | Candidate first |
|---|---:|---:|
| Chain | 20.591 → 5.771 | 21.636 → 5.516 |
| Positive branches | 5.616 → 3.328 | 5.276 → 3.605 |
| Signed branches | 5.792 → 3.295 | 5.341 → 3.296 |
| Disjoint chains | 7.398 → 4.391 | 8.450 → 3.694 |
| Wide fallback with an edited weight | 41.591 → 31.695 | 41.170 → 31.528 |

CLI elapsed changes were smaller. The chain shortened 1.9% and 0.2%,
and the signed branch batch took 0.5% and 0.9% longer. One final
four-neighbor ring library sample was 11.3% slower on the narrow-path
control. The opposite pairing improved 1.5%.

All 12 CLI workloads matched output bytes in both orders. The
independent ancestor oracle checks 256 signed bounds, including
unreachable pairs. An exact-budget request succeeds, one step short
fails, and the repeated request recovers. 0.2.18 passes the same
regression. Existing tests cover caller-edited weights and certificates.

Use scripts/profile-wide-closure.mjs with the compiled 0.2.18 library
driver from scripts/fixtures/numeric-benchmark.mbt for the phase probe.
Set MOONSTN_BENCH_WIDE=1 and MOONSTN_BENCH_DENSITY=1 when running the
numeric library and query benchmarks. The evidence includes individual
timings, memory samples, binary hashes and candidate patches.
[Measurements](optimization-0.2.19.json)

## Mooncakes 0.2.18 publication — 2026-11-20

Source 60c8c5a6ddb7a967d1be67d5ff3a6439e800e590 passed Windows and Ubuntu
[CI run 44566078299](https://github.com/JingLan0v0/MoonSTN/actions/runs/44566078299).
Both modes passed 33 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases locally and after extraction.
PowerShell smoke and generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 00:28:16 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 f68c62e4d4d99341776d752fd7ec827ef321b9bf1bc90284415f8a370424f628.
An empty-cache installation passed the public API checks in both modes.
The CLI rebuilt from the public archive passed the closure and certificate
budget checks. All 111 installed files matched the archive.
[Release receipts](publication-0.2.18.json)

## Numeric closure budget before allocation — 2026-11-20

Baseline baa28f4 was measured on Windows release JS and Node 24.14.0.
The allocation phase from the wide matrix constructor through arc
initialization measured 2.78 microseconds per edgeless solve, 6.22 for
a chain and 6.06 for a dense ring. These 64-point solves ran one work
unit short of closure and failed after the measured phase. Probe time
includes instrumentation overhead.

The selected version charges arc initialization and all logical closure
triples after feasibility and before either matrix. An unsuccessful
narrow-matrix trial can still fall back to the wide matrix within that
reservation. The negative-cycle path continues to charge its own walk
and certificate. A guard-only candidate also cut failed-call times.
Prepayment let the two matrix paths share the same charge.

| Exhausted library median, ms | Baseline first | Candidate first |
|---|---:|---:|
| Edgeless, 2,048 solves | 5.155 → 2.162 | 5.391 → 2.218 |
| Chain, 128 solves | 2.515 → 1.774 | 2.780 → 1.866 |
| Dense ring, 128 solves | 2.561 → 2.004 | 2.464 → 1.765 |

The final library build reduced failed-call medians on all five graph
shapes. Successful-call timings were mixed for the edgeless and dense
controls. CLI elapsed results varied by run and workload. The edgeless
budget-limit batch had 2,024 and 1,912 KiB lower median peak RSS.

All 13 CLI workloads matched output bytes in both orders. Independent
regressions cover full and one-short budgets on a dense ring and on
parallel arcs that select the wide matrix. They also cover missing arc
initialization budget, malformed endpoints, a negative-cycle certificate
with and without its final work unit, and recovery in the same batch.
The 0.2.17 baseline also passes these behavioral checks.

Use scripts/profile-closure-budget.mjs with the compiled 0.2.17 driver
from scripts/fixtures/numeric-benchmark.mbt to reproduce the allocation
probe. Use MOONSTN_BENCH_CLOSURE_BUDGET=1 and MOONSTN_BENCH_DENSITY=1 with
scripts/benchmark-numeric-queries.mjs for targeted CLI cases.
[Measurements](optimization-0.2.18.json)

## Mooncakes 0.2.17 publication — 2026-11-20

Source 9e58a1c1ff8f1bdd6a82cbcacc6c69173b09c18d passed Windows and Ubuntu
[CI run 44562704002](https://github.com/JingLan0v0/MoonSTN/actions/runs/44562704002).
Both modes passed 33 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases locally and after extraction.
PowerShell smoke and generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-20 00:10:23 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 12958341270f12ba313d6ec8137e14a35699566b8603e0388259414d16ddb3b7.
An empty-cache installation passed the public API checks in both modes.
The CLI rebuilt from the public archive passed byte and scan-limit boundary
checks. All 108 installed files matched the public archive.
[Release receipts](publication-0.2.17.json)

## Numeric JSON preflight and core decoding — 2026-11-20

Baseline 8efc1b2 was measured on Windows release JS with Node 24.14.0.
On 64 requests with 256 queries each, the first phase run measured 3.16 ms
for preflight and 18.71 ms in the core decoder. The whitespace-padded 1 MiB
fixture measured 5.43 ms and 3.70 ms respectively. The reported preflight
phase subtracts the timed core decode from the full parse_json call and
includes instrumentation overhead.

The selected version uses MoonBit's direct character traversal in the
existing scanner. Generated JS uses an indexed loop and combines surrogate
pairs. The resource conditions and the decoder call are preserved. A
separate whitespace branch and manual UTF-16 indexing were also sampled,
with mixed elapsed results and more source changes than direct traversal.

| Final paired phase medians, ms | Preflight baseline → candidate | Core decode baseline → candidate |
|---|---:|---:|
| 64 requests × 256 queries | 3.28 → 2.48 | 20.59 → 20.02 |
| 12 requests × 512 constraints | 2.74 → 2.08 | 18.01 → 18.64 |
| Long names and 256 queries | 4.17 → 3.46 | 10.27 → 10.33 |
| Whitespace-padded 1 MiB | 5.38 → 5.25 | 3.76 → 3.77 |

Uninstrumented final-build runs shortened the 256-query batch by 2.4%
and 1.8%. The dense-model and long-name batches improved about 2–3%
in both prototype orders and in the reversed final-build run. Both were
slightly slower in the other final-build run. The mixed batch took 5.0%
longer in one final-build run and was almost flat in reverse order.
The 1 MiB elapsed measurements also varied by order.

All nine benchmark outputs matched byte for byte. The baseline and final
verifier cover exact and just-over limits for CLI input bytes, scanned
characters, depth, supplementary Unicode strings and escaped quotes.
They check that malformed input keeps its original error classification.
Existing checks for duplicate keys and numeric spellings passed.

Set MOONSTN_BENCH_NUMERIC_PREFLIGHT=1 with scripts/benchmark-numeric-results.mjs
for the padded workload. Set MOONSTN_PROFILE_NUMERIC_PREFLIGHT=1 for the
phase probes. The evidence includes paired samples, memory readings,
candidate patches and binary hashes.
[Measurements](optimization-0.2.17.json)

## Mooncakes 0.2.16 publication — 2026-11-19

Source 0a3114deb373061732459674bacb0c66090a5c6d passed Windows and Ubuntu
[CI run 44559416254](https://github.com/JingLan0v0/MoonSTN/actions/runs/44559416254).
Both modes passed 33 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases locally and after extraction.
PowerShell smoke and generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 23:52:34 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 6c3b2b2d565fcab75f960853a974bcedfad1bcdaf7104f2b147ad247912ee048.
A fresh consumer installed exactly 0.2.16 and passed both modes. Both
CLIs built from the public archive passed query error-order and fixed-byte
checks. All 106 installed files matched the public archive.
[Release receipts](publication-0.2.16.json)

## Numeric JSON query validation — 2026-11-19

The 0.2.15 baseline is edba91b. On Windows release JS and Node 24.14.0,
the first phase run measured 22.48 ms for JSON decoding including its
preflight scan, 3.46 ms for model validation and 5.89 ms for query parsing
across 64 requests with 256 queries each. Query parsing took 10.31 ms
for the long-name batch. Model validation took 10.05 ms for 12 requests
with 512 constraints each. The query phase includes endpoint lookups
and counts only requests that reach arc indexing. Timing probes add overhead.

The selected path reads both fields directly when the map has two entries
and contains both required keys. Other maps still go through ordered
unknown-field checking. Both branches check the two value types before
resolving endpoints. A one-pass map traversal failed to improve the
256-query phase, and a preallocated query-array variant had inconsistent
end-to-end results in the two test orders.

| Median CLI elapsed, ms | Baseline first | Candidate first | Final release build |
|---|---:|---:|---:|
| 64 requests × 256 queries | 146.63 → 143.05 | 147.16 → 145.26 | 151.32 → 147.39 |
| 24 long-name requests × 256 queries | 124.92 → 126.23 | 124.01 → 127.05 | 126.79 → 125.66 |
| 64 mixed requests | 106.57 → 103.84 | 103.95 → 106.40 | 101.43 → 102.86 |

The short-name 256-query batch fell 2.4%, 1.3% and 2.6%. The separate
phase pairing measured 6.06 → 3.08 ms in query parsing for that workload.
Its same-binary elapsed control differed by 1.1%. The long-name and mixed
elapsed results varied by run. The final build's ordinary-request batch
was 3.2% slower. Its peak RSS on the 256-query batch was 444 KiB higher.

All eight CLI workload outputs matched byte for byte. The verifier
checks error precedence for unknown fields, missing fields, wrong types
and unknown endpoints, plus escaped duplicate keys and recovery in the
same batch. The new fixed error-order checks also pass against 0.2.15.

Use MOONSTN_BENCH_NUMERIC_REQUESTS=1 with scripts/benchmark-numeric-results.mjs
for the dense-model control. Use MOONSTN_PROFILE_NUMERIC_REQUESTS=1
for the generated JS phase probes. The evidence includes the candidate
patches, binary hashes and individual timings and memory samples.
[Measurements](optimization-0.2.16.json)

## Mooncakes 0.2.15 publication — 2026-11-19

Source `76bfdd8735bc9f5b1ed43fade541d1c356934ced` passed Windows and Ubuntu
[CI run 44555374009](https://github.com/JingLan0v0/MoonSTN/actions/runs/44555374009).
Both build modes passed 33 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases locally and after extraction.
PowerShell smoke and generated interface checks passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 23:31:29 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 `98157b7db15886f9d5c1d54ea998eaf6359deb9b52e3a442d52fee2e2e137f6b`.
A fresh consumer installed exactly 0.2.15 and passed both modes. The CLI
built from the public archive passed the fixed-byte mixed and single
response checks in both modes. All 104 installed files matched the archive.
[Release receipts](publication-0.2.15.json)

## Numeric CLI result serialization — 2026-11-19

Baseline `54540c6` was built on Windows release JS with Node 24.14.0.
For 64 requests with 256 queries each, the first phase run measured
1.06 ms for assignments, 7.67 ms for bound objects and 28.52 ms for
serialization. The 64-edge conflict batch spent 2.69 ms constructing
cycle objects and 8.06 ms serializing them. Timings include probe overhead.

Direct result maps and removal of interim assignment tuples gave small,
mixed end-to-end changes. The selected numeric CLI writer traverses the
bounded result tree directly. It writes map entries in insertion order,
checks every key and string for quotes, backslashes and control characters,
and uses the core encoder for strings that need escaping. It uses the
same primitive number formatting. The public analyzers return the same
Json values and the planning CLI uses the core serializer.

| Median CLI elapsed, ms | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| 64 requests × 256 queries | 158.29 → 144.58 | 150.49 → 143.66 |
| 24 long-name requests × 256 queries | 129.25 → 122.44 | 123.95 → 121.29 |
| 64 negative cycles with 64 edges each | 121.22 → 117.21 | 122.07 → 117.43 |
| 64 mixed feasible, inconsistent and error responses | 103.00 → 99.21 | 105.63 → 100.60 |

The 256-query medians fell 8.7% and 4.5%, and mixed batch medians fell
3.7% and 4.8%. A separate instrumented comparison put 256-query
serialization at 27.21 → 18.27 ms. Median peak RSS for that workload
changed by −992 and +16 KiB across the two uninstrumented rounds.
The four-query control changed by −0.6% and +0.1%, and ordinary
requests changed by +0.3% and −2.1%.

Both rounds matched all seven output batches byte for byte. Independent
checks cover assignment key order with numeric-looking and prototype-like
names, query order and null bounds, signed numbers, and a certificate
with lower and upper edges. The verifier checks exact output for a
single request and a mixed batch containing tabs, newlines, quotes,
backslashes and Unicode in the error text, followed by a feasible result.

Run `node scripts/benchmark-numeric-results.mjs BASE.js CANDIDATE.js` for
paired CLI timings. Set `MOONSTN_PROFILE_NUMERIC_RESULTS=1` for the
generated JS phase probes. The evidence file includes binary hashes,
alternate implementation patches and raw timing and memory samples.
[Measurements](optimization-0.2.15.json)

## Mooncakes 0.2.14 publication — 2026-11-19

Source `00686bbb6151ce039851a14e205b0f861a5b88e2` passed Windows and Ubuntu
[CI run 44541881279](https://github.com/JingLan0v0/MoonSTN/actions/runs/44541881279).
Both build modes passed 33 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases locally and after package
extraction. PowerShell smoke passed and generated interfaces matched.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 22:18:18 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 `bb98122117bcfc50912bedb5a8805e355fe74a0b10352c7d533d1e890b70dad8`.
A fresh consumer installed exactly 0.2.14 and verified negative potential
range, authentic cycle edges and exact wide-edge fallback in both modes.
All 100 installed files matched the public archive.
[Release receipts](publication-0.2.14.json)

## Numeric feasibility relaxation — 2026-11-19

Baseline `f7732bf` was measured on Windows release JS using Node 24.14.0.
Three 64-point, 512-arc fixtures isolate one-pass feasibility, 64-pass
signed feasibility and 64-pass infeasibility with a 64-edge certificate.
The phase probe recorded about 0.004 ms per solve for one-pass relaxation,
0.138 ms for the signed feasible case and 0.135 ms for the negative-cycle
case. Certificate construction added about 0.002 ms. Probe timings
include instrumentation overhead.

Direct exact binary64 relaxation and switching after the first pass
without packing gave mixed results on exact-budget cases. The selected
version preserves the first Int64 pass and packs each checked arc's
endpoint pair into an integer for subsequent passes. It uses checked
scratch arrays and exact binary64 integers, preserving scan order, strict
updates and the full logical budget. An unchecked variant was also
measured. The selected version retains index checks.
[Integer range proof](architecture.md)

| Median, ms per 64 library solves | Pair 1 baseline → candidate | Pair 2 baseline → candidate |
|---|---:|---:|
| One-pass feasible, exact budget | 8.33 → 8.56 | 8.21 → 7.98 |
| Signed chain, exact budget | 15.85 → 13.65 | 16.41 → 13.66 |
| Signed chain, one step short | 9.09 → 6.39 | 8.69 → 7.00 |
| Late cycle, exact budget | 8.44 → 6.11 | 8.37 → 6.21 |
| Late cycle, one step short | 9.05 → 6.19 | 9.12 → 6.39 |

The exact-budget signed chain improved 13.9% and 16.8%. The exact-budget
late cycle improved 27.6% and 25.9%. One-pass library medians stayed in
the same-binary control range. In two cold-process rounds of 12 requests,
the exact-budget signed CLI batch stayed within 0.3%. The late-cycle batch
one step short improved 2.0% and 2.2%, with median peak RSS 3,392 and
3,280 KiB lower.

All six relaxation and 16 query/density CLI workloads matched output
bytes, as did both mixed boundary batches. The late-cycle comparison
checks authentic edge identity, ordering, negative sum and failures during
relaxation and certificate construction. New regressions check a potential
as low as −32,768,000,000 with an original self-loop certificate, plus
exact fallback for a caller-edited edge of −9,007,199,254,740,993. Both
also pass on the baseline. The full verifier compares planning to the
same baseline in both build modes.

Compile `scripts/fixtures/numeric-relax-benchmark.mbt` as a JS executable
importing `JingLan0v0/stn`. Run `node scripts/benchmark-numeric-relaxation.mjs
profile BASE-LIB.js` for the 0.2.13 compiler markers. The `library` and
`cli` modes accept two builds. The evidence file includes variant patches,
binary hashes and raw paired timing and memory samples.
[Measurements](optimization-0.2.14.json)

## Mooncakes 0.2.13 publication — 2026-11-19

Source `33f6c98452c1e19a54ade49cfa5d1d3c102b0e24` passed Windows and Ubuntu
[CI run 44538481915](https://github.com/JingLan0v0/MoonSTN/actions/runs/44538481915).
Both build modes passed 32 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases in the checkout and a fresh
extraction. PowerShell smoke passed and generated interfaces matched.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 21:58:26 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 `745f568540d6e658082eab7b1e9c1764903e168de54f8dc10d4d4857e89b9238`.
A fresh consumer installed exactly 0.2.13, passed both modes and verified
all 1,024 public matrix entries in the signed repeated-distance case.
All 96 installed files matched the public archive.
[Release receipts](publication-0.2.13.json)

## Widening repeated closure distances — 2026-11-19

Baseline `08653aa` was built on Windows with the pinned MoonBit JS backend
and Node 24.14.0. Two 64-point strongly connected fixtures produce 9 and
3,491 distinct finite distances. Per library solve, widening took about
0.020 ms on both. The closure loop took about 0.081–0.082 ms. With four
disconnected groups, widening took about 0.010 ms. The instrumented CLI
spent 1.65–2.47 ms widening a cold batch of 12 requests across the six
workloads with 0, 4 and 256 queries. Phase timing includes probe overhead.

A small-value lookup table improved some repeated-distance library samples.
Selecting only the requested narrow JSON bounds reduced the 256-query CLI
medians, but 0- and 4-query results varied in direction. Unconditional reuse
of adjacent conversions had a repeated-distance benefit and slowed three of
four varied-distance library comparisons. The selected candidate samples the
first row for adjacent finite repeats and uses direct conversion when their
count is below `n / 4`. Reuse is scoped to one row.

| Median, ms per 128 library solves | Baseline → candidate, first order | Baseline → candidate, reversed order |
|---|---|---|
| Connected, nine distinct values | 15.63 → 14.09 / 15.25 → 14.58 | 15.33 → 13.95 / 15.50 → 13.99 |
| Four arcs per point ring | 9.91 → 9.21 / 10.25 → 9.22 | 9.89 → 9.05 / 9.97 → 8.96 |
| Connected, 3,491 distinct values | 15.11 → 15.65 / 15.53 → 15.53 | 15.27 → 15.34 / 15.30 → 15.26 |
| Four groups | 7.43 → 7.47 / 7.01 → 6.98 | 7.31 → 7.27 / 7.17 → 7.25 |

The repeated-value connected library medians fell 4.4–9.9%, and the
four-arc ring medians fell 7.1–10.1%. Variations for the diverse and
grouped workloads were within the same-binary control range. In the
two six-workload CLI comparisons, the repeated-value 256-query medians
fell 1.0% and 1.5%, whereas the repeated-value four-query medians rose
1.6% and 2.0%. The largest difference in median CLI peak RSS was 936 KiB.

The final release build produced byte-identical output on all 16 CLI
comparison workloads and the mixed boundary batch. A public regression
checks all 1,024 cells of a closure with signed repeated distances,
zero-weight cycles and unreachable pairs. It also passes on the baseline.

Compile `scripts/fixtures/numeric-benchmark.mbt` as a JS executable
importing `JingLan0v0/stn` against each source revision. Use
`MOONSTN_BENCH_WIDENING=1` with the library or CLI benchmark for the extra
workloads and `MOONSTN_BENCH_DENSITY=1` for connectivity controls.
`MOONSTN_BENCH_WIDENING_ONLY=1` selects the six CLI widening cases.
Use `MOONSTN_PROFILE_WIDENING=1` with the baseline CLI alone for phase
timing. The evidence file includes variant patches, binary hashes and
paired timing and memory samples.
[Measurements](optimization-0.2.13.json)

## Mooncakes 0.2.12 publication — 2026-11-19

Source `85fd1a540cbe1f399d78c01edf0cf2992a2f355d` passed Windows and Ubuntu
[CI run 44494072876](https://github.com/JingLan0v0/MoonSTN/actions/runs/44494072876).
Both build modes passed 31 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases in the checkout and a fresh
extraction. PowerShell smoke passed and generated interfaces matched.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 17:13:23 Asia/Shanghai. The public and preflight ZIP archives share
SHA-256 `081c80127503c83ca23af324471746ed698f6ae77550ea8c103c3a20b4b21301`.
A fresh consumer installed exactly 0.2.12 and passed both build modes with
signed separated components, unreachable pairs and exact budgets. All 94
installed files matched the public archive.
[Release receipts](publication-0.2.12.json)

## Flat closure pivot rows — 2026-11-19

Baseline `ad31ee7` was built on Windows using the pinned MoonBit JS backend
and Node 24.14.0. For 1,536 dense solves per process, the phase probe recorded
201.62 ms for the flat closure loop, 30.98 ms to widen and 20.43 ms to index
arcs. The closure measurement is about 0.131 ms per solve and includes probe
overhead. In a separate CPU profile, the narrow closure function accounted
for 480 of 594 samples, including its setup and widening. The generated
inner loop recomputed the destination index and path sum on an update.

The first two candidates computed each sum once, with and without bounds
checks. They improved the connected rings by about 5–8% at their median
across processes. The same-binary connected control varied by up to about
7%. The nested checked Int32 matrix was slower for every eligible shape.
The selected flat variant collects finite columns and weights once per
pivot, then uses them for all reachable rows. All matrix accesses are
checked, and the logical budget charge is still the full number of triples.

| Selected candidate median, ms | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Connected library, 128 solves | 21.98 → 14.92 | 21.64 → 15.12 |
| Four arcs per point ring, 128 solves | 18.97 → 9.56 | 18.81 → 9.69 |
| Four groups, 128 library solves | 10.10 → 7.01 | 10.91 → 7.25 |
| Dense CLI, 16 requests with 256 queries | 135.04 → 132.07 | 134.63 → 132.84 |

The two dense CLI medians fell 2.2% and 1.3%, with peak RSS lower by
304 and 208 KiB. The other CLI medians differed by at most 2.3%. Dense
exhausted library calls took an additional 0.04–0.18 ms per 128 calls.
The no-edge exhausted control was flat in one library round and 0.67 ms
slower per 2,048 calls in the other. Both exhausted paths stop before the
changed loop.

All ten CLI comparison workloads and the mixed boundary batch matched
output bytes in both runs. The new public regression uses two signed
components at 32 points with 128 distinct arcs. It verifies signed paths,
unreachable pairs, an independently checked assignment and the exact
33,280-step budget. The same test passes on the baseline.

Compile `scripts/fixtures/numeric-benchmark.mbt` as a JS executable
importing `JingLan0v0/stn` against each source revision. Run the
numeric library and numeric query benchmarks with
`MOONSTN_BENCH_DENSITY=1`. The sample file includes the variant patches,
binary hashes and raw paired samples. The phase probe uses the original
0.2.11 library fixture and its compiler markers.
[Measurements](optimization-0.2.12.json)

## Mooncakes 0.2.11 publication — 2026-11-19

Source `f1e9c78a8b2f2c26024be363575b37cee24cc03e` passed Windows and Ubuntu
[CI run 44491437629](https://github.com/JingLan0v0/MoonSTN/actions/runs/44491437629).
Both build modes passed 30 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases in the checkout and a fresh
extraction. PowerShell smoke and generated interfaces passed.

Preflight returned 202. The public registry recorded 0.2.11 on
2026-11-19 at 16:54:59 Asia/Shanghai. The public ZIP and preflight ZIP share
SHA-256 `4157dc4f081d3421a169c169fb825f479e8035acf2f75cee3556db11a7054be9`.
A fresh consumer installed exactly 0.2.11 and passed both build modes,
including edited names, duplicate-name lookup and edited edges.
All 92 installed files matched the public ZIP.
[Release receipts](publication-0.2.11.json)

## Numeric arc indexing and widening — 2026-11-19

The 0.2.10 baseline is `9efac87`. On Windows release JS with Node 24.14.0,
the instrumented dense library driver executed 1,536 solves per process,
including fixture warmups. Its phase medians were 140.62 ms for arc
indexing, 201.41 ms for the closure loop and 34.02 ms for widening.
That is approximately 0.092, 0.131 and 0.022 ms per solve respectively.
In the dense exhausted-budget control, indexing took 140.45 ms and
the narrow closure and widening counters stayed at zero. The phase
wrappers add timing overhead.

The selected candidate reuses the validated JSON name map. A library
solve builds a fresh map when it has 16–64 names and at least two arcs
per point on average. Reverse insertion keeps the first occurrence
when a caller has edited the readable names to contain duplicates.
The small library path uses linear lookup. The solver consumes arcs in
their original order and retains the existing closure representation.

| Selected candidate median, ms | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Dense library, 128 successful solves | 32.02 → 21.45 | 32.34 → 21.98 |
| Dense library, 128 exhausted-budget calls | 12.22 → 2.41 | 12.39 → 2.46 |
| Dense CLI, 16 requests with 256 queries | 135.98 → 134.01 | 134.92 → 133.78 |
| Chain library, 128 exhausted-budget calls | 2.17 → 2.34 | 2.10 → 2.25 |

Dense library gains were 33.0% and 32.0% on success, and about 80% on
exhaustion. End-to-end dense CLI medians fell 1.5% and 0.8%. The chain
exhausted workload grew by 0.15–0.17 ms per 128 calls. The CLI peak RSS
medians in the dense case differed by at most 308 KiB per round.

All ten CLI comparison workloads and the mixed boundary batch matched
output bytes. A new library test checks the first unknown endpoint before
a spend-limit error, then edits the same network's names and an edge and
checks the result with duplicate names. The two-round timings use the
existing numeric query and library benchmark scripts with reversed
arguments. Set `MOONSTN_BENCH_DENSITY=1` for the extra CLI workloads.
Run `node scripts/profile-numeric-library.mjs LIB-BASE.js` for the pinned
0.2.10 compiler markers and phase samples.
[Raw measurements](optimization-0.2.11.json)

## Mooncakes 0.2.10 publication — 2026-11-19

Source `73209944809859d6a34a9f1b838ffd78ffd05f25` passed Windows and Ubuntu
[CI run 44489510424](https://github.com/JingLan0v0/MoonSTN/actions/runs/44489510424).
Both build modes passed 29 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases in the checkout and a fresh
extraction. PowerShell smoke and generated interfaces passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 16:41:29 Asia/Shanghai. The public and preflight ZIP archives
share SHA-256 `92cbf9c82c44ade7b9b51549ab7174b4124cf32c576a68b37a29c77cdb5d2b58`.
A fresh consumer installed exactly 0.2.10 and verified both build modes
with the dense closure budget boundary, the 63,000,000 upper bound and
edited edge weights of ±3,000,000,000. All 89 installed files matched the ZIP.
[Release receipts](publication-0.2.10.json)

## Exact narrow arithmetic for dense closure — 2026-11-19

Baseline `ab6b73e` uses the 0.2.9 runtime. The dense library CPU profile
had 1,183 samples. The solver had 954 self samples, with 160 position ticks
on the Int64 addition and 75 on the signed comparison. The library
same-binary control differed by 0.3% in the dense successful scenario.

The first Int32 candidate used nested optional cells. Dense library
medians improved 1.6% and 2.9%, with an empty-graph regression. A flat
matrix preserved the original Int64 fallback and gave a larger dense
gain. The selected variant counts distinct directed pairs while preparing
its flat matrix. Parallel and self edges do not inflate that count.
[Range proof and eligibility](architecture.md)

| Selected candidate median | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Dense library, 128 solves, ms | 49.32 → 32.02 | 50.08 → 32.78 |
| Dense CLI, 16 requests with 256 queries, ms | 141.19 → 135.03 | 142.36 → 135.30 |
| Dense CLI peak RSS, KiB | 88,648 → 85,688 | 88,804 → 85,724 |
| Empty graph CLI, ms | 132.28 → 135.60 | 132.30 → 133.85 |
| Parallel edges only, CLI, ms | 128.91 → 130.14 | 130.28 → 131.28 |

The library medians on the dense workload fell 35.1% and 34.5%, with
end-to-end improvements of 4.4% and 5.0%. Empty-graph CLI medians increased
2.5% and 1.2%. The library comparisons reuse prepared networks and include
widening the matrix back to its public representation. CLI timings include
startup, decoding and serialization.

The ten CLI workloads, including 31/32-point rings, parallel arcs and
separate groups, matched output bytes. The mixed batch checked exact and
one-step-short budgets and the ordered negative-cycle certificate. The
signed 64-point Dijkstra comparison still matches all 256 expected bounds.
New library regressions cover a tight bound of 63,000,000 and edits to
±3,000,000,000 with exact and one-step-short budgets, then reuse the model
with the original weight.

Reproduce by building the pinned release CLI and numeric library fixture
for both revisions. Run `scripts/benchmark-numeric-library.mjs` and
`scripts/benchmark-numeric-queries.mjs` in both argument orders. Set
`MOONSTN_BENCH_DENSITY=1` for the extra selection controls. The report
includes all three patches, ordered samples, build hashes and peak RSS.
[Raw measurements](optimization-0.2.10.json)

## Mooncakes 0.2.9 publication — 2026-11-19

Source `06cecce6d42c446f14eab394b360fb1390c46196` passed Windows and Ubuntu
[CI run 44472818822](https://github.com/JingLan0v0/MoonSTN/actions/runs/44472818822).
Both build modes passed 27 unit tests, 4,096 numeric networks, 256 signed
network bounds and 1,794 planning cases in the checkout and a fresh
extraction. PowerShell smoke and generated interfaces passed.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 14:33:23 Asia/Shanghai. The public and preflight ZIP archives
share SHA-256 `7f40b846ea5b946d29c82dea61da4c55500a0fe25be58ee63b3e7221394c9e06`.
An empty-cache consumer installed exactly 0.2.9. Its dense closure fixture
was split into smaller source literals after hitting the compiler's column
limit. Both modes then matched the baseline strings at the exact and
one-step-short budgets. All 87 installed files matched the verified ZIP.
[Release receipts](publication-0.2.9.json)

## Numeric closure review — 2026-11-19

Baseline `1a7a36a` uses the 0.2.8 runtime. Measurements used the pinned
Windows JS release toolchain and Node 24.14.0. In a dense library CPU
profile, the solver accounted for 940 of 1,189 samples. Two inlined
array-access lines had 313 position ticks, with another 155 on the
closure addition. A same-binary library control had a 3.3% dense
median difference between argument positions.

Reading each existing cell once produced mixed dense timings. The variant
with unchecked access in proven-sized matrix loops lowered chained solve
medians by 5.6% and 5.2%. Its dense difference was smaller than the
same-binary control, and sparse CLI medians were slower in both rounds.

The selected change keeps checked access. It reads the existing cell once
and skips the pivot row when its diagonal is zero. Adding zero to that
row's known values yields those same values. The full logical budget is
reserved first. Negative cycles still return their certificate before
closure.

| Selected library median, ms | Round 1 baseline → candidate | Round 2 baseline → candidate |
|---|---:|---:|
| Empty graph, 2,048 solves | 24.94 → 15.80 | 24.98 → 16.41 |
| Chain, 128 solves | 20.92 → 20.31 | 21.11 → 20.15 |
| Dense, 128 solves | 50.97 → 50.68 | 50.28 → 50.35 |

Empty-graph times fell 36.7% and 34.3%, and chain times fell 2.9% and 4.6%.
Dense times varied within the control range. The empty-graph CLI varied by
round. Dense CLI timings improved 1.7% and 0.2% in the 256-query workload.
The second dense library run with insufficient budget was 6.8% slower.
That path returns before traversing the closure. Raw samples include peak
process RSS and control workloads.

The query benchmark matched all six batch outputs byte for byte, including
budget errors and the negative-cycle certificate. The regression suite
compares another 256 tight bounds on a 64-point signed network with Dijkstra
on nonnegative weights adjusted by endpoint potentials. This exercises
large magnitudes and constraints with both lower and upper limits.

Build two release CLIs and the two library drivers as in the numeric
recheck reproduction. Run `scripts/benchmark-numeric-queries.mjs` and
`scripts/benchmark-numeric-library.mjs` in both argument orders. The report
retains samples, CPU attribution, binary hashes and the three candidate
patches. [Raw measurements](optimization-0.2.9.json)

## Mooncakes 0.2.8 publication — 2026-11-19

Source `99f4bd9b207336aa43aba15d3eb2e8ac54f8e617` passed Windows and Ubuntu
[CI run 44471102558](https://github.com/JingLan0v0/MoonSTN/actions/runs/44471102558).
The checkout and a fresh extraction of the 85-file archive each passed
27 unit tests, 4,096 numeric networks and 1,794 planning cases per build
mode. PowerShell smoke passed and generated public interfaces matched Git.

Preflight returned 202 and publication returned 200. The registry recorded
2026-11-19 14:19:12 Asia/Shanghai. The public and preflight ZIP archives
share SHA-256 `4f3f7db160d6ca5b7d3256a1ca72ee0835044fbcd1854c56408af66ccc143a3d`.
An empty-cache consumer installed exactly 0.2.8. The installed API returned
all 256 bounds at the exact budget with output identical to baseline in
debug and release. All 85 installed files matched the archive.
[Release receipts](publication-0.2.8.json)

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

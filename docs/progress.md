# Continue MoonSTN optimization

The [optimization roadmap](optimization-roadmap.md) records the next measurement
and its acceptance criteria. Next, measure timepoint normalization
in feasible planning nodes.

## Schedule construction after resource links — 2026-11-24

The three trials built the root schedule and deferred linked schedules.
They cut task records by 91.7% in the maximum-model probe. Direct
indexing reduced median CLI peak RSS by 1.1–1.7 MiB at budget boundaries
and slowed the first-conflict library workload by 5.8–10.0%. This round
retains 0.2.30. [Measurements](linked-schedule-review.json)

## Reusing same-resource task links — 2026-11-23

The 0.2.30 source records same-resource successors after the first
conflict. The four-resource probe made 98.5% fewer resource comparisons
with the same overlap checks. Four-resource library timings improved by
2.7–6.4%. All seven CLI workloads matched byte for byte. The direct API
regression checks interleaved conflict order and resource edits.
[Measurements](optimization-0.2.30.json)

Source 5d0a62a passed Windows and Ubuntu CI. An empty-cache installation
matched all 139 published files and passed 22 executables per mode.
[Release receipts](publication-0.2.30.json)

## Schedule construction during resource search — 2026-11-23

The three direct-reading trials avoided 95.8% of task records in the
maximum-model probe. Library timings on distinct-resource inputs
increased by 7.3–14.9% across the trials. All seven CLI workloads matched
the baseline byte for byte. This round retains the published 0.2.29
implementation. [Measurements](planning-schedule-review.json)

## Resource-order duplicate ID checks — 2026-11-22

The 0.2.29 source scans root IDs with the order prefix and IDs on the
active resource path. The maximum workload made 92.5% fewer duplicate
comparisons. Four-resource library searches took 3.4–3.5% less time.
CLI timings varied and all seven outputs matched by byte. The direct API
regression covers edited root IDs and repeated ancestor rules.
[Measurements](optimization-0.2.29.json)

Source 239561c passed Windows and Ubuntu CI. An empty-cache installation
matched all 136 published files and passed 21 executables per mode.
[Release receipts](publication-0.2.29.json)

## Resource-order branch array reuse — 2026-11-21

The 0.2.28 source keeps the arcs and rule IDs for the active resource
search path and restores the parent's entries before visiting a sibling.
The tight-window library search took 5.5–6.4% less time, and its CLI
batch took 2.5–5.0% less time. All seven CLI outputs matched by byte.
The new regression preserves exact budgets, sibling backtracking at
the rule cap, and error precedence. [Measurements](optimization-0.2.28.json)

Source ef243aa passed Windows and Ubuntu CI. An empty-cache installation
matched all 134 published files and passed 20 executables per mode.
[Release receipts](publication-0.2.28.json)

## Resource-order branch names — 2026-11-21

The 0.2.27 source reuses canonical point names in resource-order
branches and shares the numeric suffixes across the ID and endpoint
names. The tight-window library benchmark took 2.2–3.1% less time.
End-to-end timings were mixed and seven CLI outputs matched by byte.
Moved or caller-appended timepoints have direct API regressions at
exact budgets. [Measurements](optimization-0.2.27.json)

Source f6066c7 passed Windows and Ubuntu CI. An empty-cache installation
matched all 132 published files and passed 19 executables per mode.
[Release receipts](publication-0.2.27.json)

## Planning task timepoint and rule names — 2026-11-21

The 0.2.26 source precomputes five names per task position at module
initialization. A 24-task construction skips 120 index-to-text
conversions. No-dependency library builds took 49–56% less time and
mixed-dependency builds took 20–24% less time. The full CLI comparison
had mixed timings and all eight outputs matched by byte. The direct
API regression keeps the rule order, bounds, and the exact-budget
schedule fixed and checks isolation after an edit.
[Measurements](optimization-0.2.26.json)

Source 14c0af2 passed Windows and Ubuntu CI. An empty-cache installation
matched all 130 published files and passed 18 executables per mode.
[Release receipts](publication-0.2.26.json)

## Planning dependency timepoint names — 2026-11-21

Version 0.2.25 reads dependency endpoints from the existing timepoint list.
The maximum-size fixture makes 48 instead of 176 calls to the timepoint
name constructor. Library construction for mixed dependency kinds took
19–26% less time in the two runs. All four kinds have a fixed regression
for exact names, lags, rule order, and schedule verification.
[Measurements](optimization-0.2.25.json)

Source 37fda1d passed Windows and Ubuntu CI. An empty-cache installation
matched all 128 files and checked all four dependency kinds in both modes.
[Release receipts](publication-0.2.25.json)

## Planning task ID lookup — 2026-11-20

Version 0.2.24 stores task positions in the existing validation map. It
uses direct scans for small models, long IDs, and the first two task
positions. The spread fixture dropped from 1,520 string comparisons to
250 comparisons and 116 map lookups per construction. Exact endpoint
positions and diagnostics have dedicated public API regressions.
[Measurements](optimization-0.2.24.json)

Source 4d8009f passed Windows and Ubuntu CI. An empty-cache installation
matched all 126 files and verified planning endpoints in both modes.
[Release receipts](publication-0.2.24.json)

## Planning JSON dependency fields — 2026-11-20

Version 0.2.23 collects each planning dependency's fields in one ordered
pass. In the maximum-size phase probe, request field processing went
from 13.21 to 9.63 ms. Fixed tests cover optional values, exact lag,
diagnostic order, and batch recovery. [Measurements](optimization-0.2.23.json)

Source edb9ee9 passed Windows and Ubuntu CI. An empty-cache installation
matched all 124 files and checked planning diagnostics in both modes.
[Release receipts](publication-0.2.23.json)

## JSON decode and number text review — 2026-11-20

On 0.2.22, the core decoder dominated the measured parse time. The
retention flag added 0.31–1.88 ms in the larger cases and preserved
text needed for exact validation. The scanner trials helped padded
input but gave mixed full CLI results. The released implementation is
retained and the public number round-trip is covered by a new test.
[Measurements](json-decode-review.json)

## Exact integer spellings — 2026-11-20

Version 0.2.22 checks integrality using the digit positions of the point
and last nonzero digit. Direct spelling checks took 14% less time for
ordinary integers and 26–30% less for long fractional tails. Fixed cases
cover negative zero, very long exponents, hidden fractions, and numbers
constructed through the public JSON API.
[Measurements](optimization-0.2.22.json)

Source d778412 passed Windows and Ubuntu CI. An empty-cache installation
matched all 121 files and checked both public batch APIs in both modes.
[Release receipts](publication-0.2.22.json)

## Numeric constraint fields — 2026-11-20

Version 0.2.21 reuses numeric constraint field lookups. At 512 constraints,
two-sided CLI batches took 1.4–1.5% less time and late format errors took
3.2–4.3% less in the two final pairings. Fixed cases cover omitted and null
bounds, exact lexical integers, diagnostic order, and batch recovery.
[Measurements](optimization-0.2.21.json)

Source bd963fe passed both CI platforms. A fresh registry installation
matched all 118 files and passed the public batch API checks in both modes.
[Release receipts](publication-0.2.21.json)

## Numeric model validation — 2026-11-20

Version 0.2.20 validates names, IDs, and bounds with fewer allocations and
hash probes. The long-ID benchmark took 4.1–5.2% less CLI time in the two final
pairings. Eleven distinct payloads matched output bytes. Fixed regressions
check diagnostic order, cycle evidence, exact budget, and batch recovery.
[Measurements](optimization-0.2.20.json)

Source 0f3441a passed Windows and Ubuntu CI. Mooncakes published the
verified archive, and an empty-cache installation passed debug and release.
[Release receipts](publication-0.2.20.json)

## Sparse column scans in the wide closure — 2026-11-20

Version 0.2.19 reuses reachable column indices within wide-closure pivot
passes. Paired library times fell 72–75% on the chain and 38–43% on
signed branches. Both orders of 12 CLI cases matched output bytes.
[Measurements](optimization-0.2.19.json)

Source c451f76 passed Windows and Ubuntu CI. An empty-cache install
verified the public API. The public CLI passed the signed wide bounds
and budget checks in both modes.
[Release receipts](publication-0.2.19.json)

## Numeric closure budget before allocation — 2026-11-20

Version 0.2.18 reserves arc initialization and logical closure triples
before matrix allocation. Near-budget library failures ran about 58–59%
faster on the edgeless case, 30–33% on the chain and 22–28% on the dense
ring. CLI elapsed results varied by run. [Measurements](optimization-0.2.18.json)

Source 60c8c5a passed Windows and Ubuntu CI. An empty-cache install
verified the public API, and the public CLI passed exact budget tests.
[Release receipts](publication-0.2.18.json)

## Numeric JSON preflight — 2026-11-20

Version 0.2.17 traverses JSON input directly during the resource scan.
The 256-query workload's preflight phase fell from 3.28 ms to 2.48 ms.
Final elapsed times fell 2.4% and 1.8% for that workload.
[Measurements](optimization-0.2.17.json)

Source 9e58a1c passed both CI platforms. The public archive passed
scan-limit checks in both modes, and an empty-cache install verified the API.
[Release receipts](publication-0.2.17.json)

## Numeric JSON query validation — 2026-11-19

Version 0.2.16 resolves both fields of well-formed numeric queries directly.
The 256-query batch was 2.4% and 1.3% faster in the paired trials and 2.6%
faster with the final release build. [Measurements](optimization-0.2.16.json)

Source 0a3114d passed Windows and Ubuntu CI. A fresh installation passed
both modes. The public archive CLI preserved query error precedence.
[Release receipts](publication-0.2.16.json)

## Numeric CLI result serialization — 2026-11-19

The 0.2.15 release walks the numeric CLI result tree directly. Median
end-to-end times fell 8.7% and 4.5% for 256-query requests and 3.7% and
4.8% for mixed-outcome batches.
[Measurements](optimization-0.2.15.json)

Published source `76bfdd8` passed Windows and Ubuntu CI. A fresh installation
passed both build modes, and the public archive CLI verified exact output
for numeric-looking names and escaped errors.
[Release receipts](publication-0.2.15.json)

## Numeric feasibility relaxation — 2026-11-19

The 0.2.14 release packs arc endpoints and uses exact binary64 arithmetic
after the first pass on eligible dense numeric networks. Exact-budget
signed-chain library solves took 13.9% and 16.8% less time. Exact-budget
late-cycle library solves took 27.6% and 25.9% less time.
[Measurements](optimization-0.2.14.json)

Published source `00686bb` passed Windows and Ubuntu CI. An empty-cache
installation verified large negative potentials and wide edited edges.
[Release receipts](publication-0.2.14.json)

## Widening repeated closure distances — 2026-11-19

The 0.2.13 release reuses adjacent equal finite distances when widening a
closure with many repeats. Repeated-value dense library medians fell
4.4–9.9% in four paired comparisons.
[Measurements](optimization-0.2.13.json)

Published source `33f6c98` passed Windows and Ubuntu CI. An empty-cache
installation verified the complete public matrix in both build modes.
[Release receipts](publication-0.2.13.json)

## Flat closure pivot rows — 2026-11-19

The 0.2.12 release reuses reachable columns and weights from each pivot row.
The two dense library batch medians fell 32.1% and 30.1%. The four-arc
ring medians fell 49.6% and 48.5%.
[Measurements](optimization-0.2.12.json)

Published source `85fd1a5` passed Windows and Ubuntu CI. A fresh installation
passed both modes, including signed separated components and exact budgets.
[Release receipts](publication-0.2.12.json)

## Numeric arc indexing — 2026-11-19

The 0.2.11 release reuses the validated JSON name map and builds a current
name map for dense library solves. The median elapsed times for the two dense library batches
fell 33.0% and 32.0%.
[Measurements](optimization-0.2.11.json)

Published source `f1e9c78` passed Windows and Ubuntu CI. A fresh installation
passed both build modes, including caller-edited names and edges.
[Release receipts](publication-0.2.11.json)

## Exact narrow arithmetic — 2026-11-19

The 0.2.10 release uses exact Int32 arithmetic for eligible dense closure,
widening the result to Int64. [Measurements](optimization-0.2.10.json)

Published source `7320994` passed Windows and Ubuntu CI. An empty-cache
installation verified the narrow and wide paths in both build modes.
[Release receipts](publication-0.2.10.json)

## Numeric closure review — 2026-11-19

The 0.2.9 release skips zero-diagonal pivot rows, reducing empty and chain
library solve times in both rounds.
[Measurements](optimization-0.2.9.json)

Published source `06cecce` passed Windows and Ubuntu CI. A fresh installation
passed the exact and one-step-short dense closure case in both modes.
[Release receipts](publication-0.2.9.json)

## Numeric bound queries — 2026-11-19

The 0.2.8 release reuses the validated name index for numeric queries and
reads tight bounds by position. [Measurements](optimization-0.2.8.json)

Published source `99f4bd9` passed Windows and Ubuntu CI. A fresh installation
returned the exact same 256 bounds at the work threshold in both build modes.
[Release receipts](publication-0.2.8.json)

## Planning result construction — 2026-11-19

The 0.2.7 release reduces object construction time for wide schedule batches.
[Measurements](optimization-0.2.7.json)

Published source `d9c7224` passed Windows and Ubuntu CI. A fresh installation
passed both build modes and matched the prior release byte-for-byte on the
mixed outcome batch. [Release receipts](publication-0.2.7.json)

## JSON number exactness — 2026-11-19

The 0.2.6 release fixes integer validation for JSON numbers rounded by binary64.
[Measurements](optimization-0.2.6.json)

Published source `3f510a8` passed Windows and Ubuntu CI. An empty-cache
consumer installed 0.2.6 and verified the exact-integer fix in both build
modes. [Release receipts](publication-0.2.6.json)

## Planning CLI phase review — 2026-11-19

Core JSON decoding was the largest measured stage in the maximum-size CLI
batches. An indexed preflight scan reduced phase time without repeatable
end-to-end gains.
[Measurements](planning-cli-review.json)

## Planning edge indexing — 2026-11-19

The 0.2.5 release emits indexed planning edges during validation. Both
maximum-size library workloads improved in two rounds.
[Measurements](optimization-0.2.5.json)

Published source `70af910` passed Windows and Ubuntu CI. A fresh consumer
installed 0.2.5 and passed both build modes. [Release receipts](publication-0.2.5.json)

## Planning predecessor review — 2026-11-19

Two predecessor-recording candidates were benchmarked. Tight-window CLI and
library timings supported retaining the 0.2.4 solver.
[Measurements](planning-predecessor-review.json)

## Larger planning models — 2026-11-19

The verifier adds 98 comparisons on 8–24 tasks with multiple resources,
mixed dependencies and tight windows. Both build modes matched the 0.2.4
baseline. [Verification evidence](acceptance.md)

## Deep-search profiling — 2026-11-19

Deep-search profiling located the main cost in temporal relaxation.
The 0.2.4 release reduced exhaustive tight-window batch time by 4.2%
and 5.8% in two rounds. [Deep-search evidence](acceptance.md)

Published source `00c2841` passed Windows and Ubuntu CI. A fresh consumer
installed exactly 0.2.4 and passed both build modes. [Release receipts](publication-0.2.4.json)

## Numeric STN recheck — 2026-11-18

The two-round numeric recheck did not reproduce the earlier dense-network slowdown.
The released version remains 0.2.3. [Results and reproduction steps](acceptance.md)

# Resource conflict scanning — 2026-11-18

The 0.2.3 planner returns the first conflicting pair in input order during resource
scanning. Its sustained 32-request single-resource CLI scenarios took about 5%
less time in two paired runs. See [acceptance.md](acceptance.md) for controls,
the public-library benchmarks and the release evidence.

# Indexed planning arcs — 2026-11-18

The 0.2.2 release compiles validated temporal arcs once per plan call. In the
24-task one-resource overload benchmark, median CLI time fell 38.9% from 0.2.1.
The paired samples, limits and regression results are in [acceptance.md](acceptance.md).
Windows and Ubuntu source CI passed. Mooncakes publication and independent exact-version
installation were verified. See [publication-0.2.2.json](publication-0.2.2.json).

# Earlier planning performance revision — 2026-11-18

The 0.2.1 source uses only a temporal feasibility witness at each planning
branch. The source passed Windows and Ubuntu CI and was published to Mooncakes.
A fresh consumer installed the exact version and verified both APIs. Windows
measurements against 0.2.0, fresh regressions and publication results are recorded
in [acceptance.md](acceptance.md).

# Historical revision — 2026-11-17

MoonSTN 0.2.0 adds bounded task planning with exclusive-resource ordering,
FS/SS/FF/SF dependencies, temporal pruning/backtracking and independent original-rule
schedule verification. The original repository/history and numeric-STN APIs remain.
The user explicitly authorized implementation, GitHub upload, Mooncakes publication
and a revised desktop proposal. Initial review was rejected for insufficient domain
core; see review-response.md. Do not confuse technical release with contest approval.

Source `07e49907dd6472c45433294e0be71ec502a101e7` passed 22 units, 1,440 two-task
and 256 three-task independent planning comparisons, and 4,096 STN network checks
per build mode, plus six CLI scenarios and two library examples. Windows/Ubuntu CI
[44109093011](https://github.com/JingLan0v0/MoonSTN/actions/runs/44109093011) passed.
Mooncakes 0.2.0 is published and validated from a fresh consumer. The registry
archive and all 55 extracted files match preflight. See acceptance.md and
publication-0.2.0.json. The revised proposal is delivered separately on the desktop.
The participant should update the original form using that proposal; organizer
re-review remains pending.

# Historical progress and handoff — 2026-11-16

## Active project

MoonSTN, public repository https://github.com/JingLan0v0/MoonSTN, module `JingLan0v0/stn`,
version 0.1.2 published and verified on Mooncakes. This is independent of MoonJMES/MoonPatch.
The user requested a new November 2026 project plus a desktop proposal.
The user authorized Mooncakes publication on 2026-11-11, superseding the earlier deferral. GitHub upload remains authorized.

## Latest source optimization — 2026-11-13 (published in 0.1.2)

Closure reserves its fixed V^3 logical budget once before traversal. Insufficient
budgets return the same error earlier, without altering success thresholds or
negative-cycle detection. New regression covers reachable 2/8/64-node networks,
exact thresholds and network reuse after errors. Debug/release each passed 15
units and 4,096 exhaustive networks plus all existing I/O/batch/scenario checks.
See optimization-2026-11-13.json and acceptance.md for fresh receipts and measured
performance, including the small slowdown in the disconnected successful case.
This source change is now included in Mooncakes 0.1.2.

## Earlier source optimization — 2026-11-11

The working source now skips unreachable closure rows and caches reachable row
references. Logical budgets and public API are unchanged. This optimization is
included in the published 0.1.1 release.
Fresh debug/release verification passed 14 units and 4,096 exhaustive networks
per mode, plus all existing boundary/I/O/scenario checks and PowerShell smoke.
A paired before/after benchmark and 30 budget/result comparisons also passed.
See optimization-2026-11-11.json and acceptance.md for actual receipts.

## Implemented and checked

Numeric difference-constraint network, validation/snapshots, exact Int64 solving,
tight pairwise bounds, independent assignment/negative-cycle verification,
bounded JSON and real CLI, batch error isolation, three scenarios and library
example. Full debug/release verification and independent local consumer passed.
See acceptance.md for counts and the actual verification time.

Docs cover provenance, adjacent libraries, algorithm limitations, resource
contract, November requirements and current unverified administrative items.
Pinned compiler 0.10.18 is installed separately from MoonJMES.

## Latest publication: 0.1.2 — 2026-11-16

Source 7d42c5fc89cef33948e9f4e8cec6a4cab703bf22 passed fresh local and actual-package
extraction verification and Windows/Ubuntu CI 43809017332. Preflight returned
202 Accepted; actual publication returned 200 OK. A fresh cache without credentials
installed 0.1.2 and passed debug/release. All 42 downloaded files match the archive;
the downloaded solver includes the November 13 fixed-closure budget optimization.
See publication-0.1.2.json and acceptance.md for actual receipts.

## Earlier publication: 0.1.1 — 2026-11-11

Published from b9a2de40925c1bdefe6f2f318631400e8ac96118 at
2026-11-11T12:35:04.200439Z. Local and extracted-package full verification passed;
Windows/Ubuntu CI 43021382909 passed for that source SHA. Preflight returned
202 Accepted; publication returned 200 OK. A fresh, credential-free consumer
passed debug/release and its downloaded files match the published package.
See publication-0.1.1.json and acceptance.md. Earlier 0.1.0 remains unchanged.

## Earlier publication: 0.1.0 — 2026-11-11

Mooncakes `JingLan0v0/stn@0.1.0` returned `200 OK`. Actual package extraction,
full local checks, Windows/Ubuntu CI 42961509778 on c826501 and fresh registry
consumer debug/release all passed. Source code did not change in this publication
round. The desktop proposal and bilingual installation instructions were updated.
See acceptance.md and publication-0.1.0.json for current, distinct receipts.
Existing 0.1.0 is immutable; use a new version for any future release.

## Earlier delivery status — 2026-11-10

Source commit 73633fc passed clean-source-archive extraction verification and an
independent consumer using the extracted module, in debug/release. The archive
hash is recorded in acceptance.md. The next docs-only commit records receipts.
The clean Git checkout and proposal were delivered directly to the desktop.
The public MoonSTN repository was verified empty before the first authorized
upload. This update configures its real URL and preserves both existing commits.
Source/repository update b3be7d5 was pushed normally, remote SHA matched, and
Windows/Ubuntu CI 42812956601 passed. The following docs-only commit records
those receipts. No Mooncakes upload occurred. See acceptance.md.

## Continue safely

1. Check current folder and Git status; preserve user changes and history.
2. Read AGENTS.md, docs/acceptance.md and docs/competition.md.
3. Use toolchain.json, never infer passing CI from the YAML file.
4. User-authorized GitHub upload occurs only after the repository is supplied;
   check real remote and existing content, use normal commits/push, await CI.
5. Update proposal with the verified actual repository link. No automatic form
   submission, group messaging or qualification promises.

Workspace development path: C:/Users/XJY/Desktop/MoonBit黑客松/moonbit-stn.
Active desktop checkout is at C:/Users/XJY/Desktop/moonbit-stn.
After delivery use the desktop checkout as the active project, and avoid editing
the preparation checkout independently. Local toolchain stays at
C:/Users/XJY/Desktop/MoonBit黑客松/.tools/moonstn-toolchain.

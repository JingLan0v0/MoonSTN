# Continue MoonSTN optimization

The [optimization roadmap](optimization-roadmap.md) records the next measurement
and its acceptance criteria. The 0.2.10 release uses exact Int32 arithmetic
for eligible dense closure, widening the result to Int64. Next, profile
numeric arc indexing and matrix widening. [Measurements](optimization-0.2.10.json)

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

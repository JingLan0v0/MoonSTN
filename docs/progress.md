# Progress and handoff — 2026-11-11

## Active project

MoonSTN, public repository https://github.com/JingLan0v0/MoonSTN, module `JingLan0v0/stn`,
version 0.1.1 published and verified on Mooncakes. This is independent of MoonJMES/MoonPatch.
The user requested a new November 2026 project plus a desktop proposal.
The user authorized Mooncakes publication on 2026-11-11, superseding the earlier deferral. GitHub upload remains authorized.

## Latest source optimization — 2026-11-11

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

## Latest publication: 0.1.1 — 2026-11-11

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

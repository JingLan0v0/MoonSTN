# Acceptance evidence — updated 2026-11-11

Project: MoonSTN / JingLan0v0/stn, published 0.1.0.


## Unreleased source optimization — 2026-11-11

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

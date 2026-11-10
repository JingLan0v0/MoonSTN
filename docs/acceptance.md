# Acceptance evidence — 2026-11-10

Project: MoonSTN / JingLan0v0/stn, local candidate 0.1.0.

## Observed local results

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
- GitHub repository and CI: not created/run; owner will create the repository.
- Mooncakes preflight/publication/registry consumer: deliberately not performed.
- Competition application/qualification/final acceptance: not submitted or proven.

Finite tests do not certify every possible input or guarantee organizer approval.
See architecture.md for the oracle's finite family and resource-limits.md for
arithmetic, work and transport limits.

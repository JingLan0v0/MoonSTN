# MoonSTN contributor instructions

Read docs/progress.md, docs/competition.md and docs/acceptance.md first. This is a
new November 2026 project, separate from MoonJMES and MoonPatch. Preserve Git
history. The user authorized Mooncakes publication on 2026-11-11. The user created
https://github.com/JingLan0v0/MoonSTN and authorized normal Git uploads.
Publish only after verification and record actual registry/consumer receipts. Do not submit competition forms automatically.

Use toolchain.json. Runtime algorithms belong in MoonBit; Node I/O belongs only
in cmd/main/host.mbt. Keep exact arithmetic, work limits, independent certificate
verification and distinct feasible/inconsistent/error results. A work-limit error
must never become an inconsistent result. Do not remove limits to pass tests.

Run moon fmt, node scripts/verify.mjs and scripts/powershell-smoke.ps1. The verifier
checks both build modes with an independent exhaustive oracle. CI configuration
is not evidence of an executed CI run. Keep README and evidence accurate; no
contest acceptance guarantee. Never commit credentials, toolchains or _build.

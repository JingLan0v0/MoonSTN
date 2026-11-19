# Publishing — 0.2.11 published 2026-11-19

The owner authorized Mooncakes publication on 2026-11-11. Require actual registry
and fresh-consumer receipts; do not overwrite an existing version.

GitHub repository: https://github.com/JingLan0v0/MoonSTN . The owner created this
public repository and authorized upload on 2026-11-10. Use normal Git history,
never force-push over existing content. Verify Windows/Ubuntu CI on its exact
commit SHA and record actual results. The proposal uses the repository root URL.

For each future authorized publication: align manifest repository/version, run full local
and remote checks, inspect the package archive, validate a fresh extraction,
perform preflight, publish only a new version, then install the exact version in
a fresh consumer and exercise feasible/conflict/budget/batch APIs. Credentials
stay external. Preflight, CI and registry publication are separate receipts.

Version 0.1.0 returned `200 OK` on 2026-11-11. Exact package hash, source CI and
registry consumer results are recorded in acceptance.md.

Version 0.1.1 returned `200 OK` on 2026-11-11. Fresh cache, no-credential registry
installation passed debug/release. See publication-0.1.1.json for actual receipts.

Version 0.1.2 returned `200 OK` on 2026-11-16. The fresh registry download
contains the latest budget optimization; see publication-0.1.2.json.

Version 0.2.0 returned `200 OK` on 2026-11-17. The fresh registry consumer
passed both modes for the new planning API and the existing STN API. The downloaded
55-file archive matches the verified package. See publication-0.2.0.json.

Version 0.2.1 returned `200 OK` on 2026-11-18. Both APIs passed in a fresh registry
consumer in debug and release. The downloaded 57-file archive matches the verified
package. See publication-0.2.1.json.

Version 0.2.2 returned `200 OK` on 2026-11-18. Both APIs passed in debug and release
in an independent registry consumer. All 59 installed files matched the verified
ZIP. See publication-0.2.2.json.

Version 0.2.3 returned `200 OK` on 2026-11-18. Both APIs passed in debug and release
in an independent registry consumer. All 64 installed files matched the verified
ZIP. See publication-0.2.3.json.

Version 0.2.4 returned `200 OK` on 2026-11-19. A fresh registry installation
passed debug/release API checks. All 71 installed files and the public archive
matched the verified package. [Receipts](publication-0.2.4.json)

Version 0.2.5 returned `200 OK` on 2026-11-19. The downloadable ZIP and all
75 installed files matched the verified package. A fresh consumer passed
both public API examples in debug and release. [Receipts](publication-0.2.5.json)

Version 0.2.6 returned `200 OK` on 2026-11-19. The public ZIP and all 79
installed files matched the verified package. A fresh consumer passed both
build modes, including integer spelling and underflow tests.
[Receipts](publication-0.2.6.json)

Version 0.2.7 returned `200 OK` on 2026-11-19. The public archive and all
82 installed files matched the verified package. A fresh consumer passed
both build modes, including byte comparison of a mixed planning batch.
[Receipts](publication-0.2.7.json)

Version 0.2.8 returned `200 OK` on 2026-11-19. The public archive and all
85 installed files matched the verified package. A fresh consumer passed
both build modes, including 256 bounds at the exact work threshold.
[Receipts](publication-0.2.8.json)

Version 0.2.9 returned `200 OK` on 2026-11-19. The public archive matched
all 87 installed files, and a fresh consumer passed both build modes,
including dense closure budget boundaries. [Receipts](publication-0.2.9.json)

Version 0.2.10 returned `200 OK` on 2026-11-19. The public archive matched
all 89 installed files. A fresh consumer verified long dense paths, edited
wide edge weights and exact budgets in both modes. [Receipts](publication-0.2.10.json)

The public registry lists 0.2.11 from 2026-11-19. The public archive matched
all 92 installed files. A fresh consumer verified edited names, duplicate
name lookup and edited edges in both modes. [Receipts](publication-0.2.11.json)

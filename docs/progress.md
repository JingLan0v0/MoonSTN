# Progress and handoff — 2026-11-10

## Active project

MoonSTN, suggested GitHub repository `moonbit-stn`, module `JingLan0v0/stn`,
version 0.1.0 local candidate. This is independent of MoonJMES/MoonPatch.
The user requested a new November 2026 project plus a desktop proposal.
Do not publish to Mooncakes; wait for the user to create the GitHub repository.

## Implemented and checked

Numeric difference-constraint network, validation/snapshots, exact Int64 solving,
tight pairwise bounds, independent assignment/negative-cycle verification,
bounded JSON and real CLI, batch error isolation, three scenarios and library
example. Full debug/release verification and independent local consumer passed.
See acceptance.md for counts and the actual verification time.

Docs cover provenance, adjacent libraries, algorithm limitations, resource
contract, November requirements and current unverified administrative items.
Pinned compiler 0.10.18 is installed separately from MoonJMES.

## Delivery status

Source commit 73633fc passed clean-source-archive extraction verification and an
independent consumer using the extracted module, in debug/release. The archive
hash is recorded in acceptance.md. The next docs-only commit records receipts.
The delivery step places the clean Git checkout and separate proposal directly
on the desktop; no remote or registry is configured. The next external step
belongs to the user: create the public repository and provide its actual URL.

## Continue safely

1. Check current folder and Git status; preserve user changes and history.
2. Read AGENTS.md, docs/acceptance.md and docs/competition.md.
3. Use toolchain.json, never infer passing CI from the YAML file.
4. User-authorized GitHub upload occurs only after the repository is supplied;
   check real remote and existing content, use normal commits/push, await CI.
5. Update proposal with the verified actual repository link. No automatic form
   submission, group messaging, Mooncakes publication or qualification promises.

Workspace development path: C:/Users/XJY/Desktop/MoonBit黑客松/moonbit-stn.
Final desktop checkout is intended at C:/Users/XJY/Desktop/moonbit-stn.
After delivery use the desktop checkout as the active project, and avoid editing
the preparation checkout independently. Local toolchain stays at
C:/Users/XJY/Desktop/MoonBit黑客松/.tools/moonstn-toolchain.

# Publishing — explicitly deferred

The owner asked not to submit this new project to Mooncakes yet. Do not run
`moon publish`, including server dry-run, until the owner authorizes that phase.
Version 0.1.0 is a local candidate only. No registry install is claimed.

GitHub repository: https://github.com/JingLan0v0/MoonSTN . The owner created this
public repository and authorized upload on 2026-11-10. Use normal Git history,
never force-push over existing content. Verify Windows/Ubuntu CI on its exact
commit SHA and record actual results. The proposal uses the repository root URL.

Future authorized publication: align manifest repository/version, run full local
and remote checks, inspect the package archive, validate a fresh extraction,
perform preflight, publish only a new version, then install the exact version in
a fresh consumer and exercise feasible/conflict/budget/batch APIs. Credentials
stay external. Preflight, CI and registry publication are separate receipts.

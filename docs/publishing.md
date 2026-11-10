# Publishing — explicitly deferred

The owner asked not to submit this new project to Mooncakes yet. Do not run
`moon publish`, including server dry-run, until the owner authorizes that phase.
Version 0.1.0 is a local candidate only. No registry install is claimed.

After the owner creates the GitHub repository (suggested name moonbit-stn), verify
its real URL/default branch and then add origin and push normal history. Never
force-push over existing content. Run the prepared Windows/Ubuntu workflow and
record its exact commit SHA and actual results. Update proposal's repository field
only after verifying the public URL.

Future authorized publication: align manifest repository/version, run full local
and remote checks, inspect the package archive, validate a fresh extraction,
perform preflight, publish only a new version, then install the exact version in
a fresh consumer and exercise feasible/conflict/budget/batch APIs. Credentials
stay external. Preflight, CI and registry publication are separate receipts.

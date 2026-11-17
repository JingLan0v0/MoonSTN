# Task planning API (0.2.0)

`planning_problem(tasks, dependencies)` snapshots validated input. `plan(problem,
max_nodes=1000, max_work=20000000)` returns `Planned(schedule, stats)` or
`Unschedulable(stats)`. `verify_plan(problem, schedule)` checks original rules
without calling the solver. See `examples/planning` for executable public API use.

CLI: `moon run cmd/main --target js -- --plan examples/maintenance-plan.json`.
`--plan-batch file.json` accepts at most 64 independent requests; `-` reads stdin.

```json
{"tasks":[
 {"id":"backup","min_duration":2,"max_duration":2,"release":0,"deadline":6,"resource":"database"},
 {"id":"migration","min_duration":3,"max_duration":3,"release":0,"deadline":3,"resource":"database"}
],"dependencies":[],"max_nodes":1000,"max_work":20000000}
```

Task fields shown above are required except `resource` (missing/null means none).
Dependencies default to an empty array. Each dependency requires `before`, `after`,
`kind`, `min_lag`; `max_lag` is optional/null. Kinds FS, SS, FF, SF select the
before/after task's Finish/Start endpoints respectively. The second endpoint minus
the first lies in [min_lag,max_lag], with an absent upper bound unbounded.
Dependencies may form cycles; feasibility determines whether they are satisfiable.
Unknown fields/IDs, duplicate task IDs and fractional numbers are rejected.

Times are integer offsets from zero in a caller-selected common unit. Durations
are selectable values within a range, NOT uncertain real execution durations.
Each task occupies a half-open interval [start,finish) on at most one fixed exclusive
resource. Adjacent tasks may touch. Resources are not selected or allocated.

`planned` includes `schedule` with original task IDs/start/finish and `stats`.
`unschedulable` means the bounded search finished excluding every branch. Statistics
(nodes, pruned, decisions, charged_work) are diagnostics, NOT an unsatisfiability
certificate. The original STN mode retains independently checkable negative cycles.
Budget exhaustion raises `StnError("limit_exceeded", ...)` and has no feasibility
conclusion. Single errors exit 2 with empty stdout; batch item errors have status
`error`, and do not prevent subsequent items. Valid planned/unschedulable exit 0.

Limits: 1..24 tasks, <=64 dependencies, positive duration 1..1,000,000, windows
0..1,000,000, dependency lags +/-1,000,000. IDs/resources follow the existing
1..64 ASCII name policy. max_nodes is 1..10,000; max_work is 1..100,000,000.
Existing transport limits apply. Work is conservatively reserved per STN call,
including calls pruned early; it is not CPU time. Large cases may exhaust budgets.

No objective optimization, multiple resources per task, resource capacity >1,
preemption, calendars, timezone handling, real task execution, or STNU controllability.

## Complete reproducible scenarios

| Input | User decision | Expected behavior |
|---|---|---|
| release-plan.json | Pipeline owner checks runner/staging/deployment-lock contention alongside build/test/deploy dependencies | A verified arrangement for five tasks |
| maintenance-plan.json | Operator decides whether backup must move after urgent migration on one database | Search prunes backup-first and finds migration-first |
| impossible-plan.json | Dispatcher checks whether two 3-unit jobs fit before time 5 on one vehicle | Both temporal windows individually fit; resource-aware search returns unschedulable |

Files live in `examples/`; run each with `--plan`. These are reproducible synthetic
operational examples, not production-user deployments or a public benchmark suite.

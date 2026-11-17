///|
fn main raise {
  let tasks : Array[@stn.Task] = [
    {
      id: "backup",
      min_duration: 2,
      max_duration: 2,
      release: 0,
      deadline: 6,
      resource: Some("database"),
    },
    {
      id: "migration",
      min_duration: 3,
      max_duration: 3,
      release: 0,
      deadline: 3,
      resource: Some("database"),
    },
  ]
  let problem = @stn.planning_problem(tasks, [])
  guard @stn.plan(problem) is @stn.Planned(schedule, stats) else {
    abort("expected plan")
  }
  assert_true(@stn.verify_plan(problem, schedule))
  assert_true(schedule[1].finish <= schedule[0].start)
  assert_true(stats.pruned > 0)
  let exhausted = try {
    @stn.plan(problem, max_nodes=1) |> ignore
    false
  } catch {
    @stn.StnError(code, _) => code == "limit_exceeded"
  }
  assert_true(exhausted)
  let impossible = @stn.planning_problem(
    [
      {
        id: "a",
        min_duration: 3,
        max_duration: 3,
        release: 0,
        deadline: 5,
        resource: Some("vehicle"),
      },
      {
        id: "b",
        min_duration: 3,
        max_duration: 3,
        release: 0,
        deadline: 5,
        resource: Some("vehicle"),
      },
    ],
    [],
  )
  guard @stn.plan(impossible) is @stn.Unschedulable(_) else {
    abort("expected no plan")
  }
  guard @stn.plan(problem) is @stn.Planned(recovered, _) else {
    abort("recovery")
  }
  assert_true(@stn.verify_plan(problem, recovered))
  println(
    "PASS planning API: backtracking, independent witness, unschedulable and budget recovery",
  )
}

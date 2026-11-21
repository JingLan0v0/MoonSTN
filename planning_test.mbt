///|
fn task(
  id : String,
  duration : Int32,
  deadline : Int32,
  resource : String?,
) -> @stn.Task {
  {
    id,
    min_duration: duration,
    max_duration: duration,
    release: 0,
    deadline,
    resource,
  }
}

///|
test "resource branching backtracks to the feasible order" {
  let p = @stn.planning_problem(
    [
      task("flexible", 2, 6, Some("machine")),
      task("urgent", 3, 3, Some("machine")),
    ],
    [],
  )
  guard @stn.plan(p) is @stn.Planned(s, stats) else { fail("plan") }
  assert_true(@stn.verify_plan(p, s))
  assert_true(stats.decisions > 0 && stats.pruned > 0)
  assert_true(s[1].finish <= s[0].start)
}

///|
test "resource conflict makes temporally feasible tasks impossible" {
  let p = @stn.planning_problem(
    [task("a", 2, 3, Some("machine")), task("b", 2, 3, Some("machine"))],
    [],
  )
  guard @stn.plan(p) is @stn.Unschedulable(stats) else { fail("no plan") }
  assert_eq(stats.nodes, 3)
  assert_eq(stats.pruned, 2)
}

///|
test "planning keeps 0.2.0 schedules, statistics and exact budget thresholds" {
  let p = @stn.planning_problem(
    [task("flexible", 2, 6, Some("r")), task("urgent", 3, 3, Some("r"))],
    [],
  )
  // Five points, eight edges at the root and nine at each child.
  // The first order is pruned and the second order succeeds: 183 + 189 + 189.
  for
    (max_nodes, max_work, reason) in [
      (2, 561, "planning node budget exhausted; no feasibility conclusion"),
      (3, 560, "planning work budget exhausted; no feasibility conclusion"),
    ] {
    let error = try {
      @stn.plan(p, max_nodes~, max_work~) |> ignore
      None
    } catch {
      @stn.StnError(code, message) => Some((code, message))
    }
    assert_eq(error, Some(("limit_exceeded", reason)))
  }
  guard @stn.plan(p, max_nodes=3, max_work=561) is @stn.Planned(s, stats) else {
    fail("expected a plan at the exact budget")
  }
  assert_eq(s, [
    { id: "flexible", start: 3L, finish: 5L, },
    { id: "urgent", start: 0L, finish: 3L, },
  ])
  assert_eq(stats, { nodes: 3, pruned: 1, decisions: 1, charged_work: 561, })
  assert_true(@stn.verify_plan(p, s))
}

///|
test "planning recompiles readable rules and preserves child validation order" {
  let p = @stn.planning_problem(
    [
      task("a", 1, 3, Some("r")),
      task("independent", 1, 3, None),
      task("b", 1, 3, Some("r")),
      task("c", 1, 3, Some("r")),
    ],
    [],
  )
  let original = p.rules[0]
  // There are three conflicting pairs at the root. The first is (0, 2).
  p.rules[0] = { ..original, id: "order0_2", }
  for
    (max_nodes, expected) in [
      (
        1,
        (
          "limit_exceeded", "planning node budget exhausted; no feasibility conclusion",
        ),
      ),
      (2, ("invalid_input", "invalid or duplicate constraint id")),
    ] {
    let error = try {
      @stn.plan(p, max_nodes~) |> ignore
      None
    } catch {
      @stn.StnError(code, message) => Some((code, message))
    }
    assert_eq(error, Some(expected))
  }
  p.rules[0] = original
  guard @stn.plan(p) is @stn.Planned(s, _) else { fail("expected a plan") }
  assert_true(@stn.verify_plan(p, s))
}

///|
test "planning resolves current timepoint names when compiling a child" {
  let p = @stn.planning_problem(
    [task("a", 1, 2, Some("r")), task("b", 1, 2, Some("r"))],
    [],
  )
  let original = p.rules.copy()
  p.names[2] = "renamed_finish"
  for i, rule in original {
    let from = if rule.from == "t0f" { "renamed_finish" } else { rule.from }
    let to = if rule.to == "t0f" { "renamed_finish" } else { rule.to }
    p.rules[i] = { ..rule, from, to, }
  }
  for
    (max_nodes, expected) in [
      (
        1,
        (
          "limit_exceeded", "planning node budget exhausted; no feasibility conclusion",
        ),
      ),
      (2, ("invalid_input", "unknown timepoint: t0f")),
    ] {
    let error = try {
      @stn.plan(p, max_nodes~) |> ignore
      None
    } catch {
      @stn.StnError(code, message) => Some((code, message))
    }
    assert_eq(error, Some(expected))
  }
  p.names[2] = "t0f"
  for i, rule in original {
    p.rules[i] = rule
  }
  guard @stn.plan(p) is @stn.Planned(schedule, _) else {
    fail("expected a plan")
  }
  assert_true(@stn.verify_plan(p, schedule))
}

///|
test "planning exhaustion is error and problem remains reusable" {
  let p = @stn.planning_problem(
    [task("a", 2, 4, Some("r")), task("b", 2, 4, Some("r"))],
    [],
  )
  for nodes in [1, 2] {
    let failed = try {
      @stn.plan(p, max_nodes=nodes) |> ignore
      false
    } catch {
      @stn.StnError(c, _) => c == "limit_exceeded"
    }
    // Two nodes may already find a plan; one must exhaust before resolving the overlap.
    if nodes == 1 {
      assert_true(failed)
    }
  }
  let failed = try {
    @stn.plan(p, max_work=1) |> ignore
    false
  } catch {
    @stn.StnError(c, _) => c == "limit_exceeded"
  }
  assert_true(failed)
  guard @stn.plan(p) is @stn.Planned(s, _) else { fail("reuse") }
  assert_true(@stn.verify_plan(p, s))
}

///|
test "independent verifier rejects forged schedules" {
  let p = @stn.planning_problem(
    [task("a", 2, 4, Some("r")), task("b", 2, 4, Some("r"))],
    [],
  )
  assert_false(
    @stn.verify_plan(p, [
      { id: "a", start: 0L, finish: 2L, },
      { id: "b", start: 1L, finish: 3L, },
    ]),
  )
  assert_false(
    @stn.verify_plan(p, [
      { id: "a", start: 0L, finish: 1L, },
      { id: "b", start: 2L, finish: 4L, },
    ]),
  )
  assert_false(
    @stn.verify_plan(p, [
      { id: "a", start: 0L, finish: 2L, },
      { id: "a", start: 2L, finish: 4L, },
    ]),
  )
  assert_false(
    @stn.verify_plan(p, [
      { id: "a", start: -9223372036854775807L, finish: 2L, },
      { id: "b", start: 2L, finish: 4L, },
    ]),
  )
  assert_true(
    @stn.verify_plan(p, [
      { id: "b", start: 2L, finish: 4L, },
      { id: "a", start: 0L, finish: 2L, },
    ]),
  )
}

///|
test "task snapshot and relation validation" {
  let tasks = [task("a", 1, 5, None), task("b", 1, 5, None)]
  let ds : Array[@stn.Dependency] = [
    { before: "a", after: "b", kind: "FS", min_lag: 1, max_lag: Some(1), },
  ]
  let p = @stn.planning_problem(tasks, ds)
  tasks.clear()
  ds.clear()
  guard @stn.plan(p) is @stn.Planned(s, _) else { fail("plan") }
  assert_true(@stn.verify_plan(p, s))
  assert_false(
    @stn.verify_plan(p, [
      { id: "a", start: 0L, finish: 1L, },
      { id: "b", start: 1L, finish: 2L, },
    ]),
  )
}

///|
test "dependency endpoints use the positions of exact task IDs" {
  let tasks = [
    task("spare", 1, 5, None),
    task("2", 1, 5, None),
    task("constructor", 1, 5, None),
    task("__proto__", 1, 5, None),
    task("10", 1, 5, None),
    task("toString", 1, 5, None),
  ]
  let dependencies : Array[@stn.Dependency] = [
    {
      before: "10",
      after: "__proto__",
      kind: "FS",
      min_lag: 1,
      max_lag: Some(1),
    },
    {
      before: "2",
      after: "constructor",
      kind: "SS",
      min_lag: 1,
      max_lag: Some(1),
    },
  ]
  let p = @stn.planning_problem(tasks, dependencies)
  assert_eq((p.rules[18].from, p.rules[18].to), ("t4f", "t3s"))
  assert_eq((p.rules[19].from, p.rules[19].to), ("t1s", "t2s"))
  guard @stn.plan(p) is @stn.Planned(schedule, _) else {
    fail("expected a plan")
  }
  assert_true(@stn.verify_plan(p, schedule))
}

///|
test "all dependency kinds use the correct named timepoints" {
  let a = task("a", 2, 2, None)
  let b = { ..task("b", 1, 4, None), release: 3, }
  let dependencies : Array[@stn.Dependency] = [
    { before: "a", after: "b", kind: "FS", min_lag: 1, max_lag: Some(1), },
    { before: "a", after: "b", kind: "SS", min_lag: 3, max_lag: Some(3), },
    { before: "a", after: "b", kind: "FF", min_lag: 2, max_lag: Some(2), },
    { before: "a", after: "b", kind: "SF", min_lag: 4, max_lag: Some(4), },
    { before: "b", after: "a", kind: "SS", min_lag: -3, max_lag: Some(-3), },
  ]
  let p = @stn.planning_problem([a, b], dependencies)
  let expected = [
    ("t0f", "t1s", 1),
    ("t0s", "t1s", 3),
    ("t0f", "t1f", 2),
    ("t0s", "t1f", 4),
    ("t1s", "t0s", -3),
  ]
  for i, (from, to, lag) in expected {
    let rule = p.rules[6 + i]
    assert_eq(rule.id, "dependency" + i.to_string())
    assert_eq(
      (rule.from, rule.to, rule.lower, rule.upper),
      (from, to, Some(lag), Some(lag)),
    )
  }
  guard @stn.plan(p) is @stn.Planned(schedule, _) else {
    fail("expected a plan")
  }
  assert_eq(schedule, [
    { id: "a", start: 0L, finish: 2L, },
    { id: "b", start: 3L, finish: 4L, },
  ])
  assert_true(@stn.verify_plan(p, schedule))
}

///|
test "built-in planning rules preserve task positions and windows" {
  let tasks : Array[@stn.Task] = Array::makei(24, i => {
    id: "task-" + (24 - i).to_string(),
    min_duration: 2,
    max_duration: 3,
    release: 4 * i,
    deadline: 4 * i + 2,
    resource: None,
  })
  let p = @stn.planning_problem(tasks, [])
  assert_eq(
    (p.names[0], p.names.length(), p.rules.length()),
    ("origin", 49, 72),
  )
  for i, t in tasks {
    let suffix = i.to_string()
    let start = "t" + suffix + "s"
    let finish = "t" + suffix + "f"
    assert_eq((p.names[2 * i + 1], p.names[2 * i + 2]), (start, finish))
    assert_eq(p.rules[3 * i], {
      id: "duration" + suffix,
      from: start,
      to: finish,
      lower: Some(2),
      upper: Some(3),
    })
    assert_eq(p.rules[3 * i + 1], {
      id: "release" + suffix,
      from: "origin",
      to: start,
      lower: Some(t.release),
      upper: None,
    })
    assert_eq(p.rules[3 * i + 2], {
      id: "deadline" + suffix,
      from: "origin",
      to: finish,
      lower: None,
      upper: Some(t.deadline),
    })
  }
  guard @stn.plan(p, max_nodes=1, max_work=122547)
    is @stn.Planned(schedule, stats) else {
    fail("expected a plan at the exact budget")
  }
  let expected : Array[@stn.ScheduledTask] = tasks.map(t => {
    id: t.id,
    start: t.release.to_int64(),
    finish: t.deadline.to_int64(),
  })
  assert_eq(schedule, expected)
  assert_eq((stats.nodes, stats.charged_work), (1, 122547))
  assert_true(@stn.verify_plan(p, schedule))

  p.names[1] = "renamed"
  p.rules[0] = { ..p.rules[0], id: "edited", }
  let rebuilt = @stn.planning_problem(tasks, [])
  assert_eq((rebuilt.names[1], rebuilt.rules[0].id), ("t0s", "duration0"))
}

///|
test "task validation and ordered dependency endpoint errors" {
  let a = task("a", 1, 5, None)
  let b = task("b", 1, 5, None)
  let invalid : @stn.Dependency = {
    before: "missing-before",
    after: "missing-after",
    kind: "XX",
    min_lag: 0,
    max_lag: Some(-1),
  }
  for
    (tasks, dependency, expected) in [
      ([a, a], invalid, "invalid or duplicate task id"),
      ([a, b], invalid, "unknown task: missing-before"),
      ([a, b], { ..invalid, before: "a", }, "unknown task: missing-after"),
      (
        [a, b],
        { ..invalid, before: "a", after: "b", },
        "dependency kind must be FS/SS/FF/SF and lag within +/-1000000",
      ),
      (
        [a, b],
        { ..invalid, before: "a", after: "b", kind: "FS", },
        "invalid maximum lag",
      ),
    ] {
    let actual = try {
      @stn.planning_problem(tasks, [dependency]) |> ignore
      None
    } catch {
      @stn.StnError(code, message) => Some((code, message))
    }
    assert_eq(actual, Some(("invalid_input", expected)))
  }
}

///|
test "planning model limits and invalid fields" {
  for
    tasks in [
      [],
      Array::makei(25, i => task(i.to_string(), 1, 4, None)),
      [task("a", 0, 4, None)],
      [task("a", 1, 4, Some("bad resource"))],
      [task("a", 1, 4, None), task("a", 1, 4, None)],
    ] {
    let bad = try {
      @stn.planning_problem(tasks, []) |> ignore
      false
    } catch {
      @stn.StnError(_, _) => true
    }
    assert_true(bad)
  }
  let p = @stn.planning_problem([task("a", 3, 2, None)], [])
  guard @stn.plan(p) is @stn.Unschedulable(_) else { fail("window conflict") }
}

///|
test "maximum task and dependency counts preserve work accounting" {
  let p = @stn.planning_problem(
    Array::makei(24, i => task(i.to_string(), 1, 4, None)),
    Array::makei(64, i => {
      before: (i % 24).to_string(),
      after: ((i + 1) % 24).to_string(),
      kind: "SS",
      min_lag: 0,
      max_lag: Some(0),
    }),
  )
  // 49 points and 224 arcs. Each dependency contributes both bounds.
  let failed = try {
    @stn.plan(p, max_work=128946) |> ignore
    false
  } catch {
    @stn.StnError(code, _) => code == "limit_exceeded"
  }
  assert_true(failed)
  guard @stn.plan(p, max_work=128947) is @stn.Planned(s, stats) else {
    fail("plan")
  }
  assert_eq(stats, { nodes: 1, pruned: 0, decisions: 0, charged_work: 128947, })
  assert_true(@stn.verify_plan(p, s))
}

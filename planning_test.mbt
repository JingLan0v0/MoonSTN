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

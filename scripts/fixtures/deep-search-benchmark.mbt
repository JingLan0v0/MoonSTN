///|
extern "js" fn now() -> Double =
  #|() => performance.now()

///|
fn main raise {
  let p = @stn.planning_problem(
    Array::makei(6, i => {
      id: "t" + i.to_string(),
      min_duration: 1,
      max_duration: 1,
      release: 0,
      deadline: 5,
      resource: Some("shared"),
    }),
    [],
  )
  // An exhausted call must leave this same problem reusable.
  for (nodes, work) in [(1438, 3885037), (1439, 3885036)] {
    let exhausted = try {
      @stn.plan(p, max_nodes=nodes, max_work=work) |> ignore
      false
    } catch {
      @stn.StnError(code, _) => code == "limit_exceeded"
    }
    assert_true(exhausted)
  }
  for sample = 0; sample < 12; sample = sample + 1 {
    let start = now()
    for _i = 0; _i < 16; _i = _i + 1 {
      guard @stn.plan(p, max_nodes=1439, max_work=3885037)
        is @stn.Unschedulable(stats) else {
        fail("expected an exhaustive proof")
      }
      assert_eq(stats, {
        nodes: 1439,
        pruned: 720,
        decisions: 719,
        charged_work: 3885037,
      })
    }
    let elapsed = now() - start
    if sample >= 3 {
      println(elapsed.to_string())
    }
  }
}

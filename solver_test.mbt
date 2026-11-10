///|
fn edge(
  id : String,
  from : String,
  to : String,
  lo : Int32?,
  hi : Int32?,
) -> @stn.Constraint {
  { id, from, to, lower: lo, upper: hi, }
}

///|
test "chain bounds and certificate" {
  let net = @stn.network(["zero", "a", "b"], [
    edge("a", "zero", "a", Some(2), Some(4)),
    edge("b", "a", "b", Some(3), Some(6)),
  ])
  guard @stn.solve(net) is @stn.Feasible(s) else { fail("expected feasible") }
  assert_eq(s.bounds("zero", "b"), (Some(5L), Some(10L)))
  assert_true(@stn.verify_assignment(net, s.assignment()))
}

///|
test "disconnected negative cycle and forged certificate" {
  let net = @stn.network(["zero", "a", "b"], [
    edge("one", "a", "b", Some(3), None),
    edge("two", "a", "b", None, Some(2)),
  ])
  guard @stn.solve(net) is @stn.Inconsistent(c) else {
    fail("expected conflict")
  }
  assert_true(@stn.verify_conflict(net, c))
  assert_false(@stn.verify_conflict(net, []))
  c[0] = { ..c[0], bound: -999L, }
  assert_false(@stn.verify_conflict(net, c))
}

///|
test "reversed interval produces authentic conflict" {
  let net = @stn.network(["a", "b"], [edge("bad", "a", "b", Some(2), Some(1))])
  guard @stn.solve(net) is @stn.Inconsistent(c) else {
    fail("expected conflict")
  }
  assert_true(@stn.verify_conflict(net, c))
}

///|
test "negative self loop" {
  let net = @stn.network(["a"], [edge("self", "a", "a", None, Some(-1))])
  guard @stn.solve(net) is @stn.Inconsistent(c) else {
    fail("expected conflict")
  }
  assert_eq(c.length(), 1)
  assert_true(@stn.verify_conflict(net, c))
}

///|
test "unbounded disconnected points are not zero bounds" {
  let net = @stn.network(["a", "b"], [])
  guard @stn.solve(net) is @stn.Feasible(s) else { fail("expected feasible") }
  assert_eq(s.bounds("a", "b"), (None, None))
  assert_eq(s.bounds("a", "a"), (Some(0L), Some(0L)))
}

///|
test "one sided interval and parallel constraints" {
  let net = @stn.network(["a", "b"], [
    edge("loose", "a", "b", None, Some(5)),
    edge("tight", "a", "b", None, Some(2)),
  ])
  guard @stn.solve(net) is @stn.Feasible(s) else { fail("expected feasible") }
  assert_eq(s.bounds("a", "b"), (None, Some(2L)))
  assert_eq(s.bounds("b", "a"), (Some(-2L), None))
}

///|
test "input and result arrays cannot mutate network" {
  let names = ["a", "b"]
  let cs = [edge("c", "a", "b", Some(1), Some(1))]
  let net = @stn.network(names, cs)
  names[0] = "changed"
  cs.clear()
  net.timepoints().clear()
  guard @stn.solve(net) is @stn.Feasible(s) else { fail("expected feasible") }
  s.assignment().clear()
  assert_eq(s.bounds("a", "b"), (Some(1L), Some(1L)))
}

///|
test "budget failure does not poison network" {
  let net = @stn.network(["a", "b"], [edge("c", "a", "b", Some(1), Some(2))])
  let failed = try {
    @stn.solve(net, max_steps=1) |> ignore
    false
  } catch {
    @stn.StnError(code, _) => code == "limit_exceeded"
  }
  assert_true(failed)
  guard @stn.solve(net) is @stn.Feasible(s) else { fail("expected feasible") }
  assert_true(@stn.verify_assignment(net, s.assignment()))
}

///|
test "invalid input model boundaries" {
  for names in [[], ["a", "a"], ["bad name"], [""]] {
    let failed = try {
      @stn.network(names, []) |> ignore
      false
    } catch {
      @stn.StnError(_, _) => true
    }
    assert_true(failed)
  }
  for
    cs in [
      [edge("c", "a", "missing", None, Some(0))],
      [edge("c", "a", "a", None, None)],
      [edge("c", "a", "a", None, Some(1000001))],
      [edge("c", "a", "a", None, Some(0)), edge("c", "a", "a", None, Some(0))],
    ] {
    let failed = try {
      @stn.network(["a"], cs) |> ignore
      false
    } catch {
      @stn.StnError(_, _) => true
    }
    assert_true(failed)
  }
}

///|
test "forged assignments and extreme proof arithmetic" {
  let net = @stn.network(["a", "b"], [edge("c", "a", "b", Some(1), Some(2))])
  assert_false(@stn.verify_assignment(net, [("a", 0L), ("b", 3L)]))
  assert_false(@stn.verify_assignment(net, [("a", 0L), ("a", 1L)]))
  assert_false(
    @stn.verify_assignment(net, [("a", -9223372036854775807L), ("b", 1L)]),
  )
}

///|
test "long chain exact numeric limits" {
  let names = Array::makei(64, i => "v" + i.to_string())
  let cs = Array::makei(63, i => {
    edge(
      "e" + i.to_string(),
      names[i],
      names[i + 1],
      Some(1000000),
      Some(1000000),
    )
  })
  let net = @stn.network(names, cs)
  guard @stn.solve(net) is @stn.Feasible(s) else { fail("expected feasible") }
  assert_eq(s.bounds("v0", "v63"), (Some(63000000L), Some(63000000L)))
  assert_true(@stn.verify_assignment(net, s.assignment()))
}

///|
test "batch isolation" {
  let requests = @stn.parse_json(
    "[{\"timepoints\":[\"a\"],\"constraints\":[]},null,{\"timepoints\":[\"a\",\"b\"],\"constraints\":[],\"max_steps\":1},{\"timepoints\":[\"a\"],\"constraints\":[]}]",
  )
  guard @stn.analyze_batch(requests) is Array(results) else { fail("array") }
  assert_eq(results.length(), 4)
  assert_eq(results[0], results[3])
  assert_true(results[1] != results[0])
  assert_true(results[2] != results[0])
}

///|
test "JSON preflight depth string and size" {
  for
    source in [
      "[".repeat(17) + "0" + "]".repeat(17),
      "\"" + "x".repeat(257) + "\"",
      " ".repeat(1048577),
    ] {
    let failed = try {
      @stn.parse_json(source) |> ignore
      false
    } catch {
      @stn.StnError(code, _) => code == "limit_exceeded"
    }
    assert_true(failed)
  }
}

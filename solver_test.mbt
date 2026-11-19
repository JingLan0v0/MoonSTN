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
test "multi-pass conflict retains exact scan and certificate budgets" {
  let net = @stn.network(["zero", "a", "b"], [
    edge("one", "a", "b", Some(3), None),
    edge("two", "a", "b", None, Some(2)),
  ])
  // Three two-arc passes, three predecessor steps, then two certificate edges.
  for steps = 1; steps < 11; steps = steps + 1 {
    let failed = try {
      @stn.solve(net, max_steps=steps) |> ignore
      false
    } catch {
      @stn.StnError(code, _) => code == "limit_exceeded"
    }
    assert_true(failed)
  }
  guard @stn.solve(net, max_steps=11) is @stn.Inconsistent(cycle) else {
    fail("expected a conflict at the exact budget")
  }
  assert_true(@stn.verify_conflict(net, cycle))
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

///|
test "JSON preflight counts Unicode pairs and escaped quotes at the boundary" {
  let prefix = "😀".repeat(253)
  let quoted = "\"" + prefix + "\\\"" + "\""
  assert_eq(@stn.parse_json(quoted), Json::string(prefix + "\""))
  for
    (source, expected) in [
      ("\"" + prefix + "😀" + "\\\"" + "\"", "limit_exceeded"),
      ("😀".repeat(200000), "invalid_json"),
      ("😀".repeat(200001), "limit_exceeded"),
    ] {
    let code = try {
      @stn.parse_json(source) |> ignore
      None
    } catch {
      @stn.StnError(code, _) => Some(code)
    }
    assert_eq(code, Some(expected))
  }
}

///|
test "sparse closure preserves exact logical budget boundary" {
  for n in [1, 2, 8, 64] {
    let names = Array::makei(n, i => "v" + i.to_string())
    let net = @stn.network(names, [])
    let needed = n * n * n
    if needed > 1 {
      let exhausted = try {
        @stn.solve(net, max_steps=needed - 1) |> ignore
        false
      } catch {
        @stn.StnError(code, _) => code == "limit_exceeded"
      }
      assert_true(exhausted)
    }
    guard @stn.solve(net, max_steps=needed) is @stn.Feasible(s) else {
      fail("expected feasible after budget failure")
    }
    assert_true(@stn.verify_assignment(net, s.assignment()))
    for i = 0; i < n; i = i + 1 {
      for j = 0; j < n; j = j + 1 {
        let expected = if i == j { (Some(0L), Some(0L)) } else { (None, None) }
        assert_eq(s.bounds(names[i], names[j]), expected)
      }
    }
  }
}

///|
test "reachable closure rows preserve exact budget and network reuse" {
  for n in [2, 8, 64] {
    let names = Array::makei(n, i => "v" + i.to_string())
    let cs = Array::makei(n - 1, i => {
      edge("e" + i.to_string(), names[i], names[i + 1], None, Some(1))
    })
    // Positive edges require one Bellman-Ford pass, then edge initialization.
    // Test both one-way reachability and a strongly connected cycle with a zero-weight return edge.
    for connected in [false, true] {
      let rules = cs.copy()
      if connected {
        rules.push(edge("return", names[n - 1], names[0], None, Some(0)))
      }
      let net = @stn.network(names, rules)
      let needed = n * n * n + 2 * rules.length()
      for missing in [1, n - 1, n] {
        let exhausted = try {
          @stn.solve(net, max_steps=needed - missing) |> ignore
          false
        } catch {
          @stn.StnError(code, _) => code == "limit_exceeded"
        }
        assert_true(exhausted)
      }
      guard @stn.solve(net, max_steps=needed) is @stn.Feasible(s) else {
        fail("expected feasible after budget errors")
      }
      assert_true(@stn.verify_assignment(net, s.assignment()))
      let lower = if connected { Some(0L) } else { None }
      assert_eq(
        s.bounds(names[0], names[n - 1]),
        (lower, Some((n - 1).to_int64())),
      )
    }
  }
}

///|
test "wide edited edges keep exact bounds and closure work thresholds" {
  let n = 32
  let names = Array::makei(n, i => "v" + i.to_string())
  // A separate component supplies enough distinct arcs for the narrow path.
  let constraints = Array::makei(150, i => {
    let source = 1 + i / 5
    let target = 1 + (source - 1 + i % 5 + 1) % 30
    edge("arc" + i.to_string(), names[source], names[target], None, Some(0))
  })
  constraints.push(edge("tail", "v0", "v31", None, Some(1)))
  let net = @stn.network(names, constraints)
  let tail = net.edges.length() - 1
  let original = net.edges[tail]
  for (bound, passes) in [(3000000000L, 1), (-3000000000L, 2), (1L, 1)] {
    net.edges[tail] = { ..original, bound, }
    let steps = n * n * n + (passes + 1) * net.edges.length()
    let exhausted = try {
      @stn.solve(net, max_steps=steps - 1) |> ignore
      false
    } catch {
      @stn.StnError(code, _) => code == "limit_exceeded"
    }
    assert_true(exhausted)
    guard @stn.solve(net, max_steps=steps) is @stn.Feasible(solution) else {
      fail("expected a feasible closure")
    }
    assert_eq(solution.bounds("v0", "v31"), (None, Some(bound)))
    assert_eq(solution.bounds("v31", "v0"), (Some(-bound), None))
    assert_true(@stn.verify_assignment(net, solution.assignment()))
  }
}

///|
test "dense closure preserves long paths at the per-edge bound" {
  let n = 64
  let names = Array::makei(n, i => "v" + i.to_string())
  let constraints = Array::makei(n - 1, i => {
    edge("forward" + i.to_string(), names[i], names[i + 1], None, Some(1000000))
  })
  for i = 1; i < n; i = i + 1 {
    for jump = 1; jump <= 4 && jump <= i; jump = jump + 1 {
      constraints.push(
        edge(
          "back" + i.to_string() + "_" + jump.to_string(),
          names[i],
          names[i - jump],
          None,
          Some(1000000),
        ),
      )
    }
  }
  let net = @stn.network(names, constraints)
  let steps = n * n * n + 2 * constraints.length()
  guard @stn.solve(net, max_steps=steps) is @stn.Feasible(solution) else {
    fail("expected dense feasible closure")
  }
  assert_eq(solution.bounds("v0", "v63"), (Some(-16000000L), Some(63000000L)))
  assert_eq(solution.bounds("v63", "v0"), (Some(-63000000L), Some(16000000L)))
}

///|
test "numeric arc indexing reads edited arrays and keeps the first match" {
  let names = Array::makei(32, i => "v" + i.to_string())
  let net = @stn.network(
    names,
    Array::makei(128, i => edge("e" + i.to_string(), "v0", "v31", None, Some(1))),
  )
  net.names[0] = "renamed"
  let error = try {
    @stn.solve(net, max_steps=1) |> ignore
    None
  } catch {
    @stn.StnError(code, message) => Some((code, message))
  }
  assert_eq(error, Some(("invalid_input", "unknown timepoint: v0")))
  net.names[0] = "v0"
  net.names[1] = "v0"
  let original = net.edges[0]
  net.edges[0] = { ..original, bound: -2L, }
  guard @stn.solve(net) is @stn.Feasible(solution) else {
    fail("expected feasible with edited edges")
  }
  assert_eq(solution.bounds("v0", "v31"), (None, Some(-2L)))
  assert_eq(solution.values[31], -2L)
}

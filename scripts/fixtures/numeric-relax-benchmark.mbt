///|
extern "js" fn now() -> Double =
  #|() => performance.now()

///|
extern "js" fn arguments() -> FixedArray[String] =
  #|() => process.argv.slice(2)

///|
fn edge(
  id : String,
  from : String,
  to : String,
  bound : Int32,
) -> @stn.Constraint {
  { id, from, to, lower: None, upper: Some(bound), }
}

///|
fn solve(net : @stn.Network, steps : Int32) -> @stn.Outcome? raise {
  Some(@stn.solve(net, max_steps=steps)) catch {
    @stn.StnError(code, message) =>
      if code == "limit_exceeded" {
        None
      } else {
        fail(message)
      }
  }
}

///|
fn main raise {
  let args = arguments()
  let shape = args[0]
  let names = Array::makei(64, i => "v" + i.to_string())
  let chain_bound = if shape == "positive" { 1 } else { -1 }
  let edges = Array::makei(63, i => {
    let source = 62 - i
    edge(
      "chain" + source.to_string(),
      names[source],
      names[source + 1],
      chain_bound,
    )
  })
  for source = 0; source < 64; source = source + 1 {
    for jump = 2; jump <= 8; jump = jump + 1 {
      let target = (source + jump) % 64
      edges.push(
        edge(
          "decoy" + edges.length().to_string(),
          names[source],
          names[target],
          128,
        ),
      )
    }
  }
  let tail_bound = if shape == "late-cycle" { 62 } else { 128 }
  edges.push(edge("tail", "v63", "v0", tail_bound))
  let net = @stn.network(names, edges)
  let exact = match shape {
    "positive" => 2 * edges.length() + 64 * 64 * 64
    "signed-chain" => 65 * edges.length() + 64 * 64 * 64
    "late-cycle" => 64 * edges.length() + 128
    _ => fail("unknown shape")
  }
  let exhausted = args[1] == "exhausted"
  let steps = if exhausted { exact - 1 } else { exact }
  match solve(net, exact) {
    Some(@stn.Inconsistent(cycle)) => {
      assert_eq(shape, "late-cycle")
      assert_true(@stn.verify_conflict(net, cycle))
      assert_eq(cycle.length(), 64)
    }
    Some(@stn.Feasible(solution)) => {
      assert_true(shape != "late-cycle")
      assert_true(@stn.verify_assignment(net, solution.assignment()))
    }
    None => fail("exact budget must succeed")
  }
  let calls = 64
  let expected = if exhausted {
    -1000L
  } else {
    match shape {
      "positive" => 63L
      "signed-chain" => -63L
      _ => 64L
    }
  }
  for sample = 0; sample < 12; sample = sample + 1 {
    let mut checksum = 0L
    let start = now()
    for _i = 0; _i < calls; _i = _i + 1 {
      checksum += match solve(net, steps) {
        None => -1000L
        Some(@stn.Inconsistent(cycle)) => cycle.length().to_int64()
        Some(@stn.Feasible(result)) => result.bounds("v0", "v63").1.unwrap()
      }
    }
    let ms = now() - start
    assert_eq(checksum, calls.to_int64() * expected)
    if sample >= 3 {
      println(ms.to_string())
    }
  }
}

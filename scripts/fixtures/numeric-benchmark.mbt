///|
extern "js" fn now() -> Double =
  #|() => performance.now()

///|
extern "js" fn arguments() -> FixedArray[String] =
  #|() => process.argv.slice(2)

///|
fn query(net : @stn.Network, steps : Int) -> Int64 raise {
  let result = @stn.solve(net, max_steps=steps) catch {
    @stn.StnError(code, msg) =>
      if code == "limit_exceeded" {
        return -2L
      } else {
        fail(msg)
      }
  }
  guard result is @stn.Feasible(solution) else { fail("expected feasible") }
  let (_, upper) = solution.bounds("v0", "v63")
  upper.unwrap_or(-1L)
}

///|
fn main raise {
  let args = arguments()
  let names = Array::makei(64, i => "v" + i.to_string())
  let edges : Array[@stn.Constraint] = []
  for i = 0; i < 64; i = i + 1 {
    let degree = match args[0] {
      "disconnected" => 0
      "chain" => if i < 63 { 1 } else { 0 }
      "connected" => 8
      _ => fail("unknown shape")
    }
    for j = 1; j <= degree; j = j + 1 {
      edges.push({
        id: "e" + edges.length().to_string(),
        from: names[i],
        to: names[(i + j) % 64],
        lower: None,
        upper: Some(1),
      })
    }
  }
  let net = @stn.network(names, edges)
  let exhausted = args[1] == "exhausted"
  let steps = if exhausted { 64 * 64 * 64 + 2 * edges.length() - 1 } else { 2000000 }
  let expected = if exhausted { -2L } else {
    match args[0] {
      "disconnected" => -1L
      "chain" => 63L
      _ => 8L
    }
  }
  let calls = if args[0] == "disconnected" { 2048 } else { 128 }
  for sample = 0; sample < 12; sample = sample + 1 {
    let mut checksum = 0L
    let start = now()
    for _i = 0; _i < calls; _i = _i + 1 {
      checksum += query(net, steps)
    }
    let ms = now() - start
    assert_eq(checksum, calls.to_int64() * expected)
    if sample >= 3 {
      println(ms.to_string())
    }
  }
}

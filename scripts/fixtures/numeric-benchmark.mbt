///|
extern "js" fn now() -> Double =
  #|() => performance.now()

///|
extern "js" fn arguments() -> FixedArray[String] =
  #|() => process.argv.slice(2)

///|
fn query(net : @stn.Network, steps : Int32) -> Int64 raise {
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
      "chain-groups" => if i % 16 < 15 { 1 } else { 0 }
      "branches" | "signed-branches" =>
        if i < 31 {
          2
        } else if i == 31 {
          1
        } else {
          0
        }
      "ring-four" => 4
      "connected" | "connected-varied" | "four-groups" | "edited-wide" => 8
      _ => fail("unknown shape")
    }
    let width = if args[0] == "four-groups" || args[0] == "chain-groups" {
      16
    } else {
      64
    }
    let group = i / width * width
    for j = 1; j <= degree; j = j + 1 {
      let target = if args[0] == "branches" || args[0] == "signed-branches" {
        2 * i + j
      } else {
        group + (i + j) % width
      }
      let upper = if args[0] == "connected-varied" {
        100000 + 23 * (target * target - i * i)
      } else if args[0] == "signed-branches" {
        -1
      } else {
        1
      }
      edges.push({
        id: "e" + edges.length().to_string(),
        from: names[i],
        to: names[target],
        lower: None,
        upper: Some(upper),
      })
    }
  }
  let net = @stn.network(names, edges)
  if args[0] == "edited-wide" {
    let old = net.edges[0]
    net.edges[0] = { ..old, bound: 3000000000L, }
  }
  let exhausted = args[1] == "exhausted"
  let scans = if args[0] == "signed-branches" { 3 } else { 2 }
  let exact = 64 * 64 * 64 + scans * edges.length()
  let steps = if exhausted { exact - 1 } else { 2000000 }
  let expected = if exhausted {
    -2L
  } else {
    match args[0] {
      "disconnected" | "four-groups" | "chain-groups" => -1L
      "ring-four" => 16L
      "chain" => 63L
      "branches" => 6L
      "signed-branches" => -6L
      "connected-varied" => 891287L
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

///|
fn main raise {
  let net = @stn.network(["zero", "ready"], [
    {
      id: "ready-window",
      from: "zero",
      to: "ready",
      lower: Some(5),
      upper: Some(10),
    },
  ])
  guard @stn.solve(net) is @stn.Feasible(solution) else {
    abort("expected feasible")
  }
  assert_true(@stn.verify_assignment(net, solution.assignment()))
  assert_eq(solution.bounds("zero", "ready"), (Some(5L), Some(10L)))
  let conflict = @stn.network(["zero", "ready"], [
    {
      id: "impossible",
      from: "zero",
      to: "ready",
      lower: Some(5),
      upper: Some(4),
    },
  ])
  guard @stn.solve(conflict) is @stn.Inconsistent(cycle) else {
    abort("expected conflict")
  }
  assert_true(@stn.verify_conflict(conflict, cycle))
  println("PASS public API: feasible bounds and checked conflict")
}

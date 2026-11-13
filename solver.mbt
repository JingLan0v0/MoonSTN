///|
/// All time coordinates are relative to the first timepoint, which is assigned zero.
pub fn solve(
  net : Network,
  max_steps~ : Int32 = 2000000,
) -> Outcome raise StnError {
  if max_steps < 1 || max_steps > 10000000 {
    raise StnError("invalid_input", "max_steps must be 1..10000000")
  }
  let budget = { remaining: max_steps, }
  let n = net.names.length()
  let arcs = net.edges.map(e => {
    (find_name(net.names, e.from), find_name(net.names, e.to))
  })
  // An implicit zero-cost super-source reaches every connected component.
  let values : Array[Int64] = Array::make(n, 0L)
  let pred : Array[Int32] = Array::make(n, -1)
  let mut changed = -1
  for _round = 0; _round < n; _round = _round + 1 {
    changed = -1
    for i = 0; i < arcs.length(); i = i + 1 {
      budget.tick()
      let (a, b) = arcs[i]
      let candidate = values[a] + net.edges[i].bound
      if candidate < values[b] {
        values[b] = candidate
        pred[b] = i
        changed = b
      }
    }
    if changed == -1 {
      break
    }
  }
  if changed != -1 {
    let mut node = changed
    for _i = 0; _i < n; _i = _i + 1 {
      budget.tick()
      node = arcs[pred[node]].0
    }
    let start = node
    let cycle : Array[Edge] = []
    while true {
      budget.tick()
      let i = pred[node]
      cycle.push(net.edges[i])
      node = arcs[i].0
      if node == start {
        break
      }
    }
    return Inconsistent(cycle.rev())
  }
  let origin = values[0]
  for i = 0; i < n; i = i + 1 {
    values[i] -= origin
  }
  let distances : Array[Array[Int64?]] = Array::makei(n, _ => {
    Array::make(n, None)
  })
  for i = 0; i < n; i = i + 1 {
    distances[i][i] = Some(0L)
  }
  for i = 0; i < arcs.length(); i = i + 1 {
    budget.tick()
    let (a, b) = arcs[i]
    let w = net.edges[i].bound
    if distances[a][b] is None || distances[a][b].unwrap() > w {
      distances[a][b] = Some(w)
    }
  }
  // Closure is computed only after feasibility, avoiding negative-cycle amplification.
  // Closure has exactly n^3 logical triples; reserve once before any traversal.
  // All state is local, so an insufficient budget cannot expose a partial result.
  budget.charge(n * n * n)
  for k = 0; k < n; k = k + 1 {
    let via = distances[k]
    for i = 0; i < n; i = i + 1 {
      let row = distances[i]
      guard row[k] is Some(a) else { continue }
      for j = 0; j < n; j = j + 1 {
        if via[j] is Some(b) {
          let w = a + b
          if row[j] is None || row[j].unwrap() > w {
            row[j] = Some(w)
          }
        }
      }
    }
  }
  Feasible({ names: net.names.copy(), values, distances, })
}

///|
/// Independently checks a complete integer assignment against every original edge.
pub fn verify_assignment(
  net : Network,
  assignment : Array[(String, Int64)],
) -> Bool {
  if assignment.length() != net.names.length() {
    return false
  }
  let vals : Map[String, Int64] = Map([])
  for (name, value) in assignment {
    // Also bound untrusted proof arithmetic before subtraction.
    if !net.names.contains(name) ||
      vals.contains(name) ||
      value < -100000000000L ||
      value > 100000000000L {
      return false
    }
    vals[name] = value
  }
  for e in net.edges {
    if vals[e.to] - vals[e.from] > e.bound {
      return false
    }
  }
  true
}

///|
/// A certificate is an ordered closed walk of authentic edges with negative total weight.
pub fn verify_conflict(net : Network, cycle : Array[Edge]) -> Bool {
  if cycle.is_empty() || cycle.length() > net.names.length() {
    return false
  }
  let mut total = 0L
  for i = 0; i < cycle.length(); i = i + 1 {
    let e = cycle[i]
    if !net.edges.contains(e) || e.to != cycle[(i + 1) % cycle.length()].from {
      return false
    }
    total += e.bound
  }
  total < 0L
}

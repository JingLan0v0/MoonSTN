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
  let arcs = indexed_arcs(net)
  let (values, pred, changed) = relax(n, arcs, budget)
  if changed != -1 {
    let mut node = changed
    for _i = 0; _i < n; _i = _i + 1 {
      budget.tick()
      node = arcs[pred[node]].source
    }
    let start = node
    let cycle : Array[Edge] = []
    while true {
      budget.tick()
      let i = pred[node]
      cycle.push(net.edges[i])
      node = arcs[i].source
      if node == start {
        break
      }
    }
    return Inconsistent(cycle.rev())
  }
  normalize(values)
  // Only try the narrow path if the full arc and closure charge fits.
  if n >= 32 && n <= 64 && arcs.length() >= 4 * n && arcs.length() <= 1024 {
    let work = arcs.length() + n * n * n
    if budget.remaining >= work &&
      narrow_distances(n, arcs, budget, work) is Some(distances) {
      return Feasible({ names: net.names.copy(), values, distances, })
    }
  }
  let distances : Array[Array[Int64?]] = Array::makei(n, _ => {
    Array::make(n, None)
  })
  for i = 0; i < n; i = i + 1 {
    distances[i][i] = Some(0L)
  }
  for i = 0; i < arcs.length(); i = i + 1 {
    budget.tick()
    let { source: a, target: b, bound: w, } = arcs[i]
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
      // Adding a zero diagonal cannot improve the pivot row itself.
      if i == k && a == 0L {
        continue
      }
      for j = 0; j < n; j = j + 1 {
        guard via[j] is Some(b) else { continue }
        let w = a + b
        if row[j] is Some(best) && best <= w {
          continue
        }
        row[j] = Some(w)
      }
    }
  }
  Feasible({ names: net.names.copy(), values, distances, })
}

///|
/// With no negative cycle, each finite intermediate shortest path can be
/// made simple. At 64 points and ±1,000,000 per edge, two paths sum within
/// ±126,000,000. The unreachable marker exceeds every finite distance.
fn narrow_distances(
  n : Int32,
  arcs : Array[TemporalArc],
  budget : Budget,
  work : Int32,
) -> Array[Array[Int64?]]? raise StnError {
  let no_path = 0x7fffffff
  let cells = FixedArray::make(n * n, no_path)
  for i = 0; i < n; i = i + 1 {
    cells[i * n + i] = 0
  }
  let mut connected_pairs = 0
  for arc in arcs {
    // The caller can edit the network's readable edges between solves.
    if arc.bound < -1000000L || arc.bound > 1000000L {
      return None
    }
    let cell = arc.source * n + arc.target
    let weight = arc.bound.to_int()
    let previous = cells[cell]
    if previous == no_path {
      connected_pairs += 1
    }
    if weight < previous {
      cells[cell] = weight
    }
  }
  // The initialized diagonals and parallel edges contribute no extra pairs.
  if connected_pairs < 4 * n {
    return None
  }
  budget.charge(work)
  for k = 0; k < n; k = k + 1 {
    let pivot = k * n
    for i = 0; i < n; i = i + 1 {
      if i == k {
        continue
      }
      let row = i * n
      let a = cells[row + k]
      if a == no_path {
        continue
      }
      for j = 0; j < n; j = j + 1 {
        let b = cells[pivot + j]
        if b != no_path && a + b < cells[row + j] {
          cells[row + j] = a + b
        }
      }
    }
  }
  Some(
    Array::makei(n, i => {
      Array::makei(n, j => {
        let value = cells[i * n + j]
        if value == no_path {
          None
        } else {
          Some(value.to_int64())
        }
      })
    }),
  )
}

///|
priv struct TemporalArc {
  source : Int32
  target : Int32
  bound : Int64
}

///|
fn indexed_arcs(net : Network) -> Array[TemporalArc] raise StnError {
  net.edges.map(e => {
    source: find_name(net.names, e.from),
    target: find_name(net.names, e.to),
    bound: e.bound,
  })
}

///|
fn relax(
  n : Int32,
  arcs : Array[TemporalArc],
  budget : Budget,
) -> (Array[Int64], Array[Int32], Int32) raise StnError {
  // An implicit zero-cost super-source reaches every connected component.
  let values : Array[Int64] = Array::make(n, 0L)
  let pred : Array[Int32] = Array::make(n, -1)
  let mut changed = -1
  for _round = 0; _round < n; _round = _round + 1 {
    changed = -1
    // A pass visits every arc. Reserve it before writing any local values.
    budget.charge(arcs.length())
    for i = 0; i < arcs.length(); i = i + 1 {
      let { source: a, target: b, bound, } = arcs[i]
      let candidate = values[a] + bound
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
  (values, pred, changed)
}

///|
fn normalize(values : Array[Int64]) -> Unit {
  let origin = values[0]
  for i = 0; i < values.length(); i = i + 1 {
    values[i] -= origin
  }
}

///|
/// A change on the last round proves inconsistency. Planning only needs this
/// decision and the normalized values of a feasible branch.
fn feasible_values(
  n : Int32,
  arcs : Array[TemporalArc],
  max_steps : Int32,
) -> Array[Int64]? raise StnError {
  let (values, _, changed) = relax(n, arcs, { remaining: max_steps, })
  if changed != -1 {
    return None
  }
  normalize(values)
  Some(values)
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

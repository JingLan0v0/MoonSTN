///|
/// All time coordinates are relative to the first timepoint, which is assigned zero.
pub fn solve(
  net : Network,
  max_steps~ : Int32 = 2000000,
) -> Outcome raise StnError {
  if max_steps < 1 || max_steps > 10000000 {
    raise StnError("invalid_input", "max_steps must be 1..10000000")
  }
  let arcs = indexed_arcs(net)
  solve_indexed(net, arcs, max_steps)
}

///|
fn solve_indexed(
  net : Network,
  arcs : Array[TemporalArc],
  max_steps : Int32,
) -> Outcome raise StnError {
  let budget = { remaining: max_steps, }
  let n = net.names.length()
  let (values, pred, changed) = relax(n, arcs, budget, numeric=true)
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
  // Reserve arc initialization and all logical triples before allocating
  // either closure matrix. Negative cycles use the certificate budget above.
  budget.charge(arcs.length())
  budget.charge(n * n * n)
  if n >= 32 && n <= 64 && arcs.length() >= 4 * n && arcs.length() <= 1024 {
    if narrow_distances(n, arcs) is Some(distances) {
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
    let { source: a, target: b, bound: w, } = arcs[i]
    if distances[a][b] is None || distances[a][b].unwrap() > w {
      distances[a][b] = Some(w)
    }
  }
  let use_columns = n >= 16 && n <= 64 && !arcs.is_empty()
  let capacity = if use_columns { n } else { 0 }
  let columns = FixedArray::make(capacity, 0)
  for k = 0; k < n; k = k + 1 {
    let via = distances[k]
    let mut count = -1
    for i = 0; i < n; i = i + 1 {
      let row = distances[i]
      guard row[k] is Some(a) else { continue }
      if i == k || !use_columns {
        if i == k && a == 0L {
          continue
        }
        for j = 0; j < n; j = j + 1 {
          guard via[j] is Some(b) else { continue }
          update_wide_cell(row, j, a + b)
        }
        // A nonzero diagonal can update the pivot row in place.
        count = -1
        continue
      }
      // Populate the scratch row only when another row can reach this pivot.
      if count < 0 {
        count = 0
        for j = 0; j < n; j = j + 1 {
          if via[j] is Some(_) {
            columns[count] = j
            count += 1
          }
        }
      }
      for entry = 0; entry < count; entry = entry + 1 {
        let j = columns[entry]
        update_wide_cell(row, j, a + via[j].unwrap())
      }
    }
  }
  Feasible({ names: net.names.copy(), values, distances, })
}

///|
#inline
fn update_wide_cell(
  row : Array[Int64?],
  column : Int32,
  weight : Int64,
) -> Unit {
  if row[column] is Some(best) && best <= weight {
    return
  }
  row[column] = Some(weight)
}

///|
/// With no negative cycle, each finite intermediate shortest path can be
/// made simple. At 64 points and ±1,000,000 per edge, two paths sum within
/// ±126,000,000. The unreachable marker exceeds every finite distance.
fn narrow_distances(
  n : Int32,
  arcs : Array[TemporalArc],
) -> Array[Array[Int64?]]? {
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
  // The zero diagonal and absence of negative cycles keep the pivot row
  // unchanged for this pass, so enumerate its finite cells just once.
  let columns = FixedArray::make(n, 0)
  let weights = FixedArray::make(n, 0)
  for k = 0; k < n; k = k + 1 {
    let pivot = k * n
    let mut count = 0
    for j = 0; j < n; j = j + 1 {
      let weight = cells[pivot + j]
      if weight != no_path {
        columns[count] = j
        weights[count] = weight
        count += 1
      }
    }
    for i = 0; i < n; i = i + 1 {
      if i == k {
        continue
      }
      let row = i * n
      let a = cells[row + k]
      if a == no_path {
        continue
      }
      for j = 0; j < count; j = j + 1 {
        let index = row + columns[j]
        let weight = a + weights[j]
        if weight < cells[index] {
          cells[index] = weight
        }
      }
    }
  }
  // A quick sample of the first row keeps conversion direct when few
  // adjacent finite distances repeat.
  let reuse = has_repeated_distances(cells, n, no_path)
  Some(
    Array::makei(n, i => {
      let row = i * n
      if reuse {
        let mut previous = no_path
        let mut widened = None
        Array::makei(n, j => {
          let value = cells[row + j]
          if value != previous {
            previous = value
            widened = widen_distance(value, no_path)
          }
          widened
        })
      } else {
        Array::makei(n, j => widen_distance(cells[row + j], no_path))
      }
    }),
  )
}

///|
fn widen_distance(value : Int32, no_path : Int32) -> Int64? {
  if value == no_path {
    None
  } else {
    Some(value.to_int64())
  }
}

///|
fn has_repeated_distances(
  cells : FixedArray[Int32],
  n : Int32,
  no_path : Int32,
) -> Bool {
  let mut previous = cells[0]
  let mut repeated = 0
  for j = 1; j < n; j = j + 1 {
    let value = cells[j]
    if value != no_path && value == previous {
      repeated += 1
      if repeated >= n / 4 {
        return true
      }
    }
    previous = value
  }
  false
}

///|
priv struct TemporalArc {
  source : Int32
  target : Int32
  bound : Int64
}

///|
fn indexed_arcs(net : Network) -> Array[TemporalArc] raise StnError {
  let n = net.names.length()
  if n >= 16 && n <= 64 && net.edges.length() >= 2 * n {
    let index : Map[String, Int32] = Map([], capacity=n)
    // Readable names can be edited. Reverse insertion keeps the first match.
    for i = n - 1; i >= 0; i = i - 1 {
      index[net.names[i]] = i
    }
    return arcs_with_index(net, index)
  }
  net.edges.map(e => {
    source: find_name(net.names, e.from),
    target: find_name(net.names, e.to),
    bound: e.bound,
  })
}

///|
fn arcs_with_index(
  net : Network,
  index : Map[String, Int32],
) -> Array[TemporalArc] raise StnError {
  net.edges.map(e => {
    source: lookup_name(index, e.from),
    target: lookup_name(index, e.to),
    bound: e.bound,
  })
}

///|
fn resume_relax_doubles(
  n : Int32,
  arcs : Array[TemporalArc],
  budget : Budget,
  values : Array[Int64],
  pred : Array[Int32],
) -> (Array[Int64], Array[Int32], Int32)? raise StnError {
  let count = arcs.length()
  let weights = FixedArray::make(count, 0.0)
  let endpoints = FixedArray::make(count, 0)
  for i = 0; i < count; i = i + 1 {
    let { source, target, bound, } = arcs[i]
    if bound < -1000000L || bound > 1000000L {
      return None
    }
    weights[i] = bound.to_double()
    // Validated endpoint indices are in 0..63, so two six-bit fields fit.
    endpoints[i] = (source << 6) | target
  }
  // At most 64 * 1024 relaxations can add one checked edge each.
  // Every candidate has magnitude below 2^36, so Double is exact.
  let narrow = FixedArray::makei(n, i => values[i].to_double())
  let mut changed = -1
  for round = 1; round < n; round = round + 1 {
    changed = -1
    budget.charge(count)
    for i = 0; i < count; i = i + 1 {
      let pair = endpoints[i]
      let b = pair & 63
      let candidate = narrow[pair >> 6] + weights[i]
      if candidate < narrow[b] {
        narrow[b] = candidate
        pred[b] = i
        changed = b
      }
    }
    if changed == -1 {
      break
    }
  }
  Some((Array::makei(n, i => narrow[i].to_int64()), pred, changed))
}

///|
fn relax(
  n : Int32,
  arcs : Array[TemporalArc],
  budget : Budget,
  numeric~ : Bool = false,
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
    if _round == 0 &&
      numeric &&
      n >= 32 &&
      n <= 64 &&
      arcs.length() >= 4 * n &&
      arcs.length() <= 1024 &&
      budget.remaining >= arcs.length() &&
      resume_relax_doubles(n, arcs, budget, values, pred) is Some(result) {
      return result
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
/// decision and the unshifted potentials of a feasible branch.
fn feasible_potentials(
  n : Int32,
  arcs : Array[TemporalArc],
  max_steps : Int32,
) -> Array[Int64]? raise StnError {
  let (values, _, changed) = relax(n, arcs, { remaining: max_steps, })
  if changed != -1 {
    return None
  }
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

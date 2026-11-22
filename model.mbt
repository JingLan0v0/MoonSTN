///|
pub(all) struct Constraint {
  id : String
  from : String
  to : String
  lower : Int32?
  upper : Int32?
} derive(Eq, Debug)

///|
pub(all) suberror StnError {
  StnError(String, String)
}

///|
pub(all) struct Edge {
  id : String
  from : String
  to : String
  bound : Int64
  side : String
} derive(Eq, Debug)

///|
pub struct Network {
  names : Array[String]
  edges : Array[Edge]
}

///|
pub struct Solution {
  names : Array[String]
  values : Array[Int64]
  distances : Array[Array[Int64?]]
}

///|
pub(all) enum Outcome {
  Feasible(Solution)
  Inconsistent(Array[Edge])
}

///|
priv struct Budget {
  mut remaining : Int32
}

///|
fn Budget::tick(self : Budget) -> Unit raise StnError {
  self.charge(1)
}

///|
fn Budget::charge(self : Budget, steps : Int32) -> Unit raise StnError {
  if self.remaining < steps {
    raise StnError(
      "limit_exceeded", "work budget exhausted; no feasibility conclusion",
    )
  }
  self.remaining -= steps
}

///|
fn valid_name(name : String) -> Bool {
  let length = name.length()
  if length == 0 || length > 64 {
    return false
  }
  for i = 0; i < length; i = i + 1 {
    // Only ASCII is accepted, so a UTF-16 code unit scan suffices.
    match name.code_unit_at(i) {
      'a'..<='z' | 'A'..<='Z' | '0'..<='9' | '_' | '-' | '.' => ()
      _ => return false
    }
  }
  true
}

///|
fn find_name(names : Array[String], name : String) -> Int32 raise StnError {
  for i = 0; i < names.length(); i = i + 1 {
    if names[i] == name {
      return i
    }
  }
  raise StnError("invalid_input", "unknown timepoint: " + name)
}

///|
pub fn network(
  names : Array[String],
  constraints : Array[Constraint],
) -> Network raise StnError {
  let (net, _) = network_with_index(names, constraints)
  net
}

///|
fn network_with_index(
  names : Array[String],
  constraints : Array[Constraint],
) -> (Network, Map[String, Int32]) raise StnError {
  let (index, edges) = compile_edges(names, constraints, (
    id,
    source,
    target,
    bound,
    side,
  ) => { id, from: names[source], to: names[target], bound, side, })
  ({ names: names.copy(), edges, }, index)
}

///|
fn lookup_name(
  index : Map[String, Int32],
  name : String,
) -> Int32 raise StnError {
  guard index.get(name) is Some(i) else {
    raise StnError("invalid_input", "unknown timepoint: " + name)
  }
  i
}

///|
/// Validate names and rules in input order and emit upper then lower edges.
fn[E] compile_edges(
  names : Array[String],
  constraints : Array[Constraint],
  make_edge : (String, Int32, Int32, Int64, String) -> E,
) -> (Map[String, Int32], Array[E]) raise StnError {
  if names.length() == 0 || names.length() > 64 || constraints.length() > 512 {
    raise StnError(
      "limit_exceeded", "require 1..64 timepoints and at most 512 constraints",
    )
  }
  let index : Map[String, Int32] = Map([], capacity=names.length().max(8))
  for i, name in names {
    if !valid_name(name) || index.contains(name) {
      raise StnError("invalid_input", "invalid or duplicate timepoint name")
    }
    index[name] = i
  }
  let ids : @hashset.HashSet[String] = HashSet(
    [],
    capacity=(constraints.length() * 2).max(8),
  )
  let edges : Array[E] = []
  for c in constraints {
    if !valid_name(c.id) || !ids.add_and_check(c.id) {
      raise StnError("invalid_input", "invalid or duplicate constraint id")
    }
    let from = lookup_name(index, c.from)
    let to = lookup_name(index, c.to)
    if c.lower is None && c.upper is None {
      raise StnError(
        "invalid_input", "constraint must have a lower or upper bound",
      )
    }
    if (c.lower is Some(lo) && (lo < -1000000 || lo > 1000000)) ||
      (c.upper is Some(hi) && (hi < -1000000 || hi > 1000000)) {
      raise StnError(
        "invalid_input", "bounds must be integers in -1000000..1000000",
      )
    }
    // Reversed intervals are legitimate inconsistent constraints, not syntax errors.
    if c.upper is Some(v) {
      edges.push(make_edge(c.id, from, to, v.to_int64(), "upper"))
    }
    if c.lower is Some(v) {
      edges.push(make_edge(c.id, to, from, -v.to_int64(), "lower"))
    }
  }
  (index, edges)
}

///|
pub fn Network::timepoints(self : Network) -> Array[String] {
  self.names.copy()
}

///|
pub fn Solution::assignment(self : Solution) -> Array[(String, Int64)] {
  self.names.mapi((i, name) => (name, self.values[i]))
}

///|
/// Returns the tight interval for to - from; None means unbounded in that direction.
pub fn Solution::bounds(
  self : Solution,
  from : String,
  to : String,
) -> (Int64?, Int64?) raise StnError {
  let a = find_name(self.names, from)
  let b = find_name(self.names, to)
  self.bounds_at(a, b)
}

///|
fn Solution::bounds_at(
  self : Solution,
  a : Int32,
  b : Int32,
) -> (Int64?, Int64?) {
  (self.distances[b][a].map(v => -v), self.distances[a][b])
}

///|
pub fn version() -> String {
  "0.2.29"
}

///|
pub extend Constraint with Eq::{equal, not_equal}

///|
pub extend Constraint with @debug.Debug::{to_repr}

///|
pub extend Edge with Eq::{equal, not_equal}

///|
pub extend Edge with @debug.Debug::{to_repr}

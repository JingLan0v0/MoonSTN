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
  if name.length() == 0 || name.length() > 64 {
    return false
  }
  for c in name.iter() {
    if !((c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      c == '_' ||
      c == '-' ||
      c == '.') {
      return false
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
  if names.length() == 0 || names.length() > 64 || constraints.length() > 512 {
    raise StnError(
      "limit_exceeded", "require 1..64 timepoints and at most 512 constraints",
    )
  }
  let seen : Map[String, Bool] = Map([])
  for name in names {
    if !valid_name(name) || seen.contains(name) {
      raise StnError("invalid_input", "invalid or duplicate timepoint name")
    }
    seen[name] = true
  }
  let ids : Map[String, Bool] = Map([])
  let edges : Array[Edge] = []
  for c in constraints {
    if !valid_name(c.id) || ids.contains(c.id) {
      raise StnError("invalid_input", "invalid or duplicate constraint id")
    }
    ids[c.id] = true
    find_name(names, c.from) |> ignore
    find_name(names, c.to) |> ignore
    if c.lower is None && c.upper is None {
      raise StnError(
        "invalid_input", "constraint must have a lower or upper bound",
      )
    }
    for bound in [c.lower, c.upper] {
      if bound is Some(v) && (v < -1000000 || v > 1000000) {
        raise StnError(
          "invalid_input", "bounds must be integers in -1000000..1000000",
        )
      }
    }
    // Reversed intervals are legitimate inconsistent constraints, not syntax errors.
    if c.upper is Some(v) {
      edges.push({
        id: c.id,
        from: c.from,
        to: c.to,
        bound: v.to_int64(),
        side: "upper",
      })
    }
    if c.lower is Some(v) {
      edges.push({
        id: c.id,
        from: c.to,
        to: c.from,
        bound: -v.to_int64(),
        side: "lower",
      })
    }
  }
  { names: names.copy(), edges, }
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
  (self.distances[b][a].map(v => -v), self.distances[a][b])
}

///|
pub fn version() -> String {
  "0.1.1"
}

///|
pub extend Constraint with Eq::{equal, not_equal}

///|
pub extend Constraint with @debug.Debug::{to_repr}

///|
pub extend Edge with Eq::{equal, not_equal}

///|
pub extend Edge with @debug.Debug::{to_repr}

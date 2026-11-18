///|
pub(all) struct Task {
  id : String
  min_duration : Int32
  max_duration : Int32
  release : Int32
  deadline : Int32
  resource : String?
} derive(Eq, Debug)

///|
pub(all) struct Dependency {
  before : String
  after : String
  kind : String
  min_lag : Int32
  max_lag : Int32?
} derive(Eq, Debug)

///|
pub struct PlanningProblem {
  tasks : Array[Task]
  dependencies : Array[Dependency]
  names : Array[String]
  rules : Array[Constraint]
}

///|
pub(all) struct ScheduledTask {
  id : String
  start : Int64
  finish : Int64
} derive(Eq, Debug)

///|
pub(all) struct PlanStats {
  nodes : Int32
  pruned : Int32
  decisions : Int32
  charged_work : Int32
} derive(Eq, Debug)

///|
pub(all) enum PlanResult {
  Planned(Array[ScheduledTask], PlanStats)
  Unschedulable(PlanStats)
}

///|
fn task_index(tasks : Array[Task], id : String) -> Int32 raise StnError {
  for i = 0; i < tasks.length(); i = i + 1 {
    if tasks[i].id == id {
      return i
    }
  }
  raise StnError("invalid_input", "unknown task: " + id)
}

///|
fn point(i : Int32, finish : Bool) -> String {
  "t" + i.to_string() + (if finish { "f" } else { "s" })
}

///|
pub fn planning_problem(
  tasks : Array[Task],
  dependencies : Array[Dependency],
) -> PlanningProblem raise StnError {
  if tasks.length() < 1 || tasks.length() > 24 || dependencies.length() > 64 {
    raise StnError(
      "limit_exceeded", "require 1..24 tasks and at most 64 dependencies",
    )
  }
  let ids : Map[String, Bool] = Map([])
  let names = ["origin"]
  let rules : Array[Constraint] = []
  for i = 0; i < tasks.length(); i = i + 1 {
    let t = tasks[i]
    if !valid_name(t.id) || ids.contains(t.id) {
      raise StnError("invalid_input", "invalid or duplicate task id")
    }
    ids[t.id] = true
    if t.min_duration < 1 ||
      t.max_duration < t.min_duration ||
      t.max_duration > 1000000 ||
      t.release < 0 ||
      t.release > 1000000 ||
      t.deadline < 0 ||
      t.deadline > 1000000 {
      raise StnError(
        "invalid_input", "durations require 1<=min<=max<=1000000; windows require 0..1000000",
      )
    }
    if t.resource is Some(r) && !valid_name(r) {
      raise StnError("invalid_input", "invalid resource id")
    }
    let s = point(i, false)
    let f = point(i, true)
    names.push(s)
    names.push(f)
    rules.push({
      id: "duration" + i.to_string(),
      from: s,
      to: f,
      lower: Some(t.min_duration),
      upper: Some(t.max_duration),
    })
    rules.push({
      id: "release" + i.to_string(),
      from: "origin",
      to: s,
      lower: Some(t.release),
      upper: None,
    })
    rules.push({
      id: "deadline" + i.to_string(),
      from: "origin",
      to: f,
      lower: None,
      upper: Some(t.deadline),
    })
  }
  for i = 0; i < dependencies.length(); i = i + 1 {
    let d = dependencies[i]
    let a = task_index(tasks, d.before)
    let b = task_index(tasks, d.after)
    if !["FS", "SS", "FF", "SF"].contains(d.kind) ||
      d.min_lag < -1000000 ||
      d.min_lag > 1000000 {
      raise StnError(
        "invalid_input", "dependency kind must be FS/SS/FF/SF and lag within +/-1000000",
      )
    }
    if d.max_lag is Some(v) && (v < d.min_lag || v > 1000000) {
      raise StnError("invalid_input", "invalid maximum lag")
    }
    rules.push({
      id: "dependency" + i.to_string(),
      from: point(a, d.kind == "FS" || d.kind == "FF"),
      to: point(b, d.kind == "FF" || d.kind == "SF"),
      lower: Some(d.min_lag),
      upper: d.max_lag,
    })
  }
  { tasks: tasks.copy(), dependencies: dependencies.copy(), names, rules, }
}

///|
/// Checks original task windows, durations, relations and exclusive resources; never calls solve.
pub fn verify_plan(
  p : PlanningProblem,
  schedule : Array[ScheduledTask],
) -> Bool {
  if schedule.length() != p.tasks.length() {
    return false
  }
  let values : Map[String, ScheduledTask] = Map([])
  for s in schedule {
    if values.contains(s.id) ||
      s.start < 0L ||
      s.finish < s.start ||
      s.finish > 1000000L {
      return false
    }
    values[s.id] = s
  }
  for t in p.tasks {
    guard values.get(t.id) is Some(s) else { return false }
    if s.start < t.release.to_int64() ||
      s.finish > t.deadline.to_int64() ||
      s.finish - s.start < t.min_duration.to_int64() ||
      s.finish - s.start > t.max_duration.to_int64() {
      return false
    }
  }
  for d in p.dependencies {
    let a = values[d.before]
    let b = values[d.after]
    let from = if d.kind == "FS" || d.kind == "FF" { a.finish } else { a.start }
    let to = if d.kind == "FF" || d.kind == "SF" { b.finish } else { b.start }
    if to - from < d.min_lag.to_int64() {
      return false
    }
    if d.max_lag is Some(v) && to - from > v.to_int64() {
      return false
    }
  }
  for i = 0; i < p.tasks.length(); i = i + 1 {
    for j = i + 1; j < p.tasks.length(); j = j + 1 {
      if p.tasks[i].resource is Some(r) && p.tasks[j].resource == Some(r) {
        let a = values[p.tasks[i].id]
        let b = values[p.tasks[j].id]
        if a.start < b.finish && b.start < a.finish {
          return false
        }
      }
    }
  }
  true
}

///|
priv struct PlanBranch {
  arcs : Array[TemporalArc]
  rule_ids : Array[String]
  order : (Int32, Int32)?
}

///|
fn PlanBranch::compile(
  self : PlanBranch,
  names : Array[String],
) -> (Array[TemporalArc], Array[String]) raise StnError {
  guard self.order is Some((before, after)) else {
    return (self.arcs, self.rule_ids)
  }
  // The validated parent is shared by both children. Check only the new rule.
  // Rule IDs and caps also cover callers using the readable model arrays.
  if self.rule_ids.length() == 512 {
    raise StnError(
      "limit_exceeded", "require 1..64 timepoints and at most 512 constraints",
    )
  }
  let id = "order" + before.to_string() + "_" + after.to_string()
  if self.rule_ids.contains(id) {
    raise StnError("invalid_input", "invalid or duplicate constraint id")
  }
  let finish = find_name(names, point(before, true))
  let start = find_name(names, point(after, false))
  let arcs = self.arcs.copy()
  // finish(before) <= start(after) is a zero-weight lower-bound arc.
  arcs.push({ source: start, target: finish, bound: 0L, })
  let ids = self.rule_ids.copy()
  ids.push(id)
  (arcs, ids)
}

///|
/// Bounded disjunctive search. Budget exhaustion raises, never returns Unschedulable.
pub fn plan(
  p : PlanningProblem,
  max_nodes~ : Int32 = 1000,
  max_work~ : Int32 = 20000000,
) -> PlanResult raise StnError {
  if max_nodes < 1 || max_nodes > 10000 || max_work < 1 || max_work > 100000000 {
    raise StnError(
      "invalid_input", "planning budgets: nodes 1..10000, work 1..100000000",
    )
  }
  let net = network(p.names, p.rules)
  let n = net.names.length()
  let stack : Array[PlanBranch] = [
    {
      arcs: indexed_arcs(net),
      rule_ids: p.rules.map(rule => rule.id),
      order: None,
    },
  ]
  let mut nodes = 0
  let mut pruned = 0
  let mut decisions = 0
  let mut charged = 0
  while !stack.is_empty() {
    if nodes == max_nodes {
      raise StnError(
        "limit_exceeded", "planning node budget exhausted; no feasibility conclusion",
      )
    }
    let (arcs, rule_ids) = stack.pop().unwrap().compile(net.names)
    let e = arcs.length()
    // Keep the 0.2.0 full-solve charge while computing only a feasibility witness.
    let work = n * n * n + n * e + e + 2 * n
    if work > max_work - charged {
      raise StnError(
        "limit_exceeded", "planning work budget exhausted; no feasibility conclusion",
      )
    }
    charged += work
    nodes += 1
    match feasible_values(n, arcs, work) {
      None => pruned += 1
      Some(values) => {
        let schedule = p.tasks.mapi((i, t) => {
          id: t.id,
          start: values[1 + 2 * i],
          finish: values[2 + 2 * i],
        })
        let mut conflict : (Int32, Int32)? = None
        for i = 0; i < p.tasks.length(); i = i + 1 {
          for j = i + 1; j < p.tasks.length(); j = j + 1 {
            if conflict is None &&
              p.tasks[i].resource is Some(r) &&
              p.tasks[j].resource == Some(r) &&
              schedule[i].start < schedule[j].finish &&
              schedule[j].start < schedule[i].finish {
              conflict = Some((i, j))
            }
          }
        }
        match conflict {
          None =>
            return Planned(schedule, {
              nodes,
              pruned,
              decisions,
              charged_work: charged,
            })
          Some((i, j)) => {
            decisions += 1
            // Positive durations imply exactly one order must hold on this resource.
            for (a, b) in [(j, i), (i, j)] {
              stack.push({ arcs, rule_ids, order: Some((a, b)), })
            }
          }
        }
      }
    }
  }
  Unschedulable({ nodes, pruned, decisions, charged_work: charged, })
}

///|
pub extend Task with Eq::{equal, not_equal}

///|
pub extend Task with @debug.Debug::{to_repr}

///|
pub extend Dependency with Eq::{equal, not_equal}

///|
pub extend Dependency with @debug.Debug::{to_repr}

///|
pub extend ScheduledTask with Eq::{equal, not_equal}

///|
pub extend ScheduledTask with @debug.Debug::{to_repr}

///|
pub extend PlanStats with Eq::{equal, not_equal}

///|
pub extend PlanStats with @debug.Debug::{to_repr}

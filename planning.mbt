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
fn task_index(
  tasks : Array[Task],
  ids : Map[String, Int32],
  id : String,
) -> Int32 raise StnError {
  // Small scans and long keys favor comparisons. Check the early positions
  // directly on the indexed path as well.
  let scan = if tasks.length() <= 4 || id.length() > 16 {
    tasks.length()
  } else {
    2
  }
  for i = 0; i < scan; i = i + 1 {
    if tasks[i].id == id {
      return i
    }
  }
  if scan < tasks.length() && ids.get(id) is Some(i) {
    return i
  }
  raise StnError("invalid_input", "unknown task: " + id)
}

///|
fn point(suffix : String, finish : Bool) -> String {
  "t" + suffix + (if finish { "f" } else { "s" })
}

///|
const MAX_PLANNING_TASKS = 24

///|
priv struct TaskRuleNames {
  start : String
  finish : String
  duration : String
  release : String
  deadline : String
}

///|
let task_rule_names : Array[TaskRuleNames] = Array::makei(MAX_PLANNING_TASKS, i => {
  let suffix = i.to_string()
  {
    start: point(suffix, false),
    finish: point(suffix, true),
    duration: "duration" + suffix,
    release: "release" + suffix,
    deadline: "deadline" + suffix,
  }
})

///|
pub fn planning_problem(
  tasks : Array[Task],
  dependencies : Array[Dependency],
) -> PlanningProblem raise StnError {
  if tasks.length() < 1 ||
    tasks.length() > MAX_PLANNING_TASKS ||
    dependencies.length() > 64 {
    raise StnError(
      "limit_exceeded", "require 1..24 tasks and at most 64 dependencies",
    )
  }
  let ids : Map[String, Int32] = if tasks.length() <= 4 {
    Map([])
  } else {
    Map([], capacity=tasks.length())
  }
  let names = ["origin"]
  let rules : Array[Constraint] = []
  for i = 0; i < tasks.length(); i = i + 1 {
    let t = tasks[i]
    if !valid_name(t.id) || ids.contains(t.id) {
      raise StnError("invalid_input", "invalid or duplicate task id")
    }
    ids[t.id] = i
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
    let task_names = task_rule_names[i]
    let s = task_names.start
    let f = task_names.finish
    names.push(s)
    names.push(f)
    rules.push({
      id: task_names.duration,
      from: s,
      to: f,
      lower: Some(t.min_duration),
      upper: Some(t.max_duration),
    })
    rules.push({
      id: task_names.release,
      from: "origin",
      to: s,
      lower: Some(t.release),
      upper: None,
    })
    rules.push({
      id: task_names.deadline,
      from: "origin",
      to: f,
      lower: None,
      upper: Some(t.deadline),
    })
  }
  for i = 0; i < dependencies.length(); i = i + 1 {
    let d = dependencies[i]
    let a = task_index(tasks, ids, d.before)
    let b = task_index(tasks, ids, d.after)
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
      from: names[2 * a + (if d.kind == "FS" || d.kind == "FF" { 2 } else { 1 })],
      to: names[2 * b + (if d.kind == "FF" || d.kind == "SF" { 2 } else { 1 })],
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
  parent_rule_count : Int32
  order : (Int32, Int32)?
}

///|
fn append_order_rule(
  arcs : Array[PlanningArc],
  rule_ids : Array[String],
  other_rule_count : Int32,
  index : Map[String, Int32],
  before : Int32,
  after : Int32,
) -> Unit raise StnError {
  // Rule IDs and caps also cover callers using the readable model arrays.
  if other_rule_count + rule_ids.length() == 512 {
    raise StnError(
      "limit_exceeded", "require 1..64 timepoints and at most 512 constraints",
    )
  }
  let before_suffix = before.to_string()
  let after_suffix = after.to_string()
  let id = "order" + before_suffix + "_" + after_suffix
  if rule_ids.contains(id) {
    raise StnError("invalid_input", "invalid or duplicate constraint id")
  }
  let finish_name = if before < MAX_PLANNING_TASKS {
    task_rule_names[before].finish
  } else {
    point(before_suffix, true)
  }
  let finish = lookup_name(index, finish_name)
  let start_name = if after < MAX_PLANNING_TASKS {
    task_rule_names[after].start
  } else {
    point(after_suffix, false)
  }
  let start = lookup_name(index, start_name)
  // finish(before) <= start(after) is a zero-weight lower-bound arc.
  arcs.push({ source: start, target: finish, bound: 0.0, })
  rule_ids.push(id)
}

///|
fn first_resource_conflict(
  tasks : Array[Task],
  schedule : Array[ScheduledTask],
) -> (Int32, Int32)? {
  for i = 0; i < tasks.length(); i = i + 1 {
    guard tasks[i].resource is Some(resource) else { continue }
    let a = schedule[i]
    for j = i + 1; j < tasks.length(); j = j + 1 {
      if tasks[j].resource == Some(resource) &&
        a.start < schedule[j].finish &&
        schedule[j].start < a.finish {
        return Some((i, j))
      }
    }
  }
  None
}

///|
fn next_resource_tasks(tasks : Array[Task]) -> Array[Int32] {
  let next = Array::make(tasks.length(), -1)
  for i = 0; i < tasks.length(); i = i + 1 {
    guard tasks[i].resource is Some(resource) else { continue }
    for j = i + 1; j < tasks.length(); j = j + 1 {
      if tasks[j].resource == Some(resource) {
        next[i] = j
        break
      }
    }
  }
  next
}

///|
fn first_linked_conflict(
  next : Array[Int32],
  schedule : Array[ScheduledTask],
) -> (Int32, Int32)? {
  for i = 0; i < next.length(); i = i + 1 {
    let successor = next[i]
    if successor < 0 {
      continue
    }
    let a = schedule[i]
    for j = successor; j >= 0; j = next[j] {
      let b = schedule[j]
      if a.start < b.finish && b.start < a.finish {
        return Some((i, j))
      }
    }
  }
  None
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
  let (index, arcs) : (_, Array[PlanningArc]) = compile_edges(
    p.names,
    p.rules,
    (_, source, target, bound, _) => {
      source,
      target,
      bound: bound.to_double(),
    },
  )
  let n = p.names.length()
  let mut resource_links : Array[Int32]? = None
  // Generated ordering IDs can only match rules in this prefix.
  let rule_ids : Array[String] = []
  for rule in p.rules {
    if rule.id.has_prefix("order") {
      rule_ids.push(rule.id)
    }
  }
  let other_rule_count = p.rules.length() - rule_ids.length()
  let stack : Array[PlanBranch] = [
    { parent_rule_count: rule_ids.length(), order: None, },
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
    let branch = stack.pop().unwrap()
    // The pending node shares the current path up to its parent.
    // Each order on the path contributes one rule ID and one arc.
    while rule_ids.length() > branch.parent_rule_count {
      rule_ids.pop() |> ignore
      arcs.pop() |> ignore
    }
    if branch.order is Some((before, after)) {
      append_order_rule(arcs, rule_ids, other_rule_count, index, before, after)
    }
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
    match feasible_potentials(n, arcs, work) {
      None => pruned += 1
      Some(values) => {
        let origin = values[0]
        let schedule = p.tasks.mapi((i, t) => {
          id: t.id,
          start: (values[1 + 2 * i] - origin).to_int64(),
          finish: (values[2 + 2 * i] - origin).to_int64(),
        })
        let conflict = match resource_links {
          Some(links) => first_linked_conflict(links, schedule)
          None => first_resource_conflict(p.tasks, schedule)
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
            if resource_links is None {
              // The root scan found contention. Reuse links in later nodes.
              resource_links = Some(next_resource_tasks(p.tasks))
            }
            decisions += 1
            // Positive durations imply exactly one order must hold on this resource.
            let parent_rule_count = rule_ids.length()
            for (a, b) in [(j, i), (i, j)] {
              stack.push({ parent_rule_count, order: Some((a, b)), })
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

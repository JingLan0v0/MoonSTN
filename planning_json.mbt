///|
fn plan_int(v : Json) -> Int32 raise StnError {
  guard v is Number(n, ..) &&
    n >= -100000000.0 &&
    n <= 100000000.0 &&
    n.floor() == n else {
    raise StnError("invalid_input", "expected bounded integer")
  }
  n.to_int()
}

///|
pub fn analyze_plan(value : Json) -> Json raise StnError {
  guard value is Object(obj) else {
    raise StnError("invalid_input", "plan request must be object")
  }
  fields(obj, ["tasks", "dependencies", "max_nodes", "max_work"])
  guard required(obj, "tasks") is Array(ts) else {
    raise StnError("invalid_input", "tasks must be array")
  }
  if ts.length() > 24 {
    raise StnError("limit_exceeded", "at most 24 tasks")
  }
  let tasks : Array[Task] = ts.map(v => {
    guard v is Object(t) else {
      raise StnError("invalid_input", "task must be object")
    }
    fields(t, [
      "id", "min_duration", "max_duration", "release", "deadline", "resource",
    ])
    let resource = match t.get("resource") {
      None | Some(Null) => None
      Some(v) => Some(text(v, "resource"))
    }
    {
      id: text(required(t, "id"), "id"),
      min_duration: plan_int(required(t, "min_duration")),
      max_duration: plan_int(required(t, "max_duration")),
      release: plan_int(required(t, "release")),
      deadline: plan_int(required(t, "deadline")),
      resource,
    }
  })
  let dependencies : Array[Dependency] = match obj.get("dependencies") {
    None => []
    Some(Array(ds)) => {
      if ds.length() > 64 {
        raise StnError("limit_exceeded", "at most 64 dependencies")
      }
      ds.map(v => {
        guard v is Object(d) else {
          raise StnError("invalid_input", "dependency must be object")
        }
        fields(d, ["before", "after", "kind", "min_lag", "max_lag"])
        let max_lag = match d.get("max_lag") {
          None | Some(Null) => None
          Some(v) => Some(plan_int(v))
        }
        {
          before: text(required(d, "before"), "before"),
          after: text(required(d, "after"), "after"),
          kind: text(required(d, "kind"), "kind"),
          min_lag: plan_int(required(d, "min_lag")),
          max_lag,
        }
      })
    }
    _ => raise StnError("invalid_input", "dependencies must be array")
  }
  let nodes = match obj.get("max_nodes") {
    None => 1000
    Some(v) => plan_int(v)
  }
  let work = match obj.get("max_work") {
    None => 20000000
    Some(v) => plan_int(v)
  }
  let p = planning_problem(tasks, dependencies)
  let result = plan(p, max_nodes=nodes, max_work=work)
  let out : Map[String, Json] = Map([])
  let stats = match result {
    Planned(schedule, stats) => {
      out["status"] = Json::string("planned")
      out["schedule"] = Json::array(
        schedule.map(s => {
          Json::object(
            Map([
              ("id", Json::string(s.id)),
              ("start", number(Some(s.start))),
              ("finish", number(Some(s.finish))),
            ]),
          )
        }),
      )
      stats
    }
    Unschedulable(stats) => {
      out["status"] = Json::string("unschedulable")
      stats
    }
  }
  out["stats"] = Json::object(
    Map([
      ("nodes", Json::number(stats.nodes.to_double())),
      ("pruned", Json::number(stats.pruned.to_double())),
      ("decisions", Json::number(stats.decisions.to_double())),
      ("charged_work", Json::number(stats.charged_work.to_double())),
    ]),
  )
  Json::object(out)
}

///|
pub fn analyze_plan_batch(value : Json) -> Json raise StnError {
  guard value is Array(xs) else {
    raise StnError("invalid_input", "plan batch must be array")
  }
  if xs.length() > 64 {
    raise StnError("limit_exceeded", "at most 64 plans")
  }
  Json::array(
    xs.map(x => analyze_plan(x) catch { StnError(c, m) => error_json(c, m) }),
  )
}

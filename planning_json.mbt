///|
fn plan_int(v : Json) -> Int32 raise StnError {
  guard bounded_integer(v, -100000000.0, 100000000.0) is Some(n) else {
    raise StnError("invalid_input", "expected bounded integer")
  }
  n
}

///|
fn parse_dependency(value : Json) -> Dependency raise StnError {
  guard value is Object(obj) else {
    raise StnError("invalid_input", "dependency must be object")
  }
  let mut before = None
  let mut after = None
  let mut kind = None
  let mut min_lag = None
  let mut max_lag = None
  obj.each((key, field) => {
    match key {
      "before" => before = Some(field)
      "after" => after = Some(field)
      "kind" => kind = Some(field)
      "min_lag" => min_lag = Some(field)
      "max_lag" => max_lag = Some(field)
      _ => raise StnError("invalid_input", "unknown field: " + key)
    }
  })
  // Report unknown keys before checking the optional lag and required values.
  let max_lag = match max_lag {
    None | Some(Null) => None
    Some(v) => Some(plan_int(v))
  }
  {
    before: text(required_value(before, "before"), "before"),
    after: text(required_value(after, "after"), "after"),
    kind: text(required_value(kind, "kind"), "kind"),
    min_lag: plan_int(required_value(min_lag, "min_lag")),
    max_lag,
  }
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
      ds.map(parse_dependency)
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
          let entry : Map[String, Json] = Map([], capacity=3)
          entry["id"] = Json::string(s.id)
          entry["start"] = Json::number(s.start.to_double())
          entry["finish"] = Json::number(s.finish.to_double())
          Json::object(entry)
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

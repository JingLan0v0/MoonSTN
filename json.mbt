///|
fn text(value : Json, field : String) -> String raise StnError {
  guard value is String(s) else {
    raise StnError("invalid_input", field + " must be a string")
  }
  s
}

///|
fn required(obj : Map[String, Json], field : String) -> Json raise StnError {
  guard obj.get(field) is Some(v) else {
    raise StnError("invalid_input", "missing field: " + field)
  }
  v
}

///|
fn bound(obj : Map[String, Json], field : String) -> Int32? raise StnError {
  match obj.get(field) {
    None | Some(Null) => None
    Some(Number(v, ..)) if v >= -1000000.0 && v <= 1000000.0 && v.floor() == v =>
      Some(v.to_int())
    _ =>
      raise StnError(
        "invalid_input",
        field + " must be null or an integer in -1000000..1000000",
      )
  }
}

///|
fn fields(
  obj : Map[String, Json],
  allowed : Array[String],
) -> Unit raise StnError {
  for key in obj.keys() {
    if !allowed.contains(key) {
      raise StnError("invalid_input", "unknown field: " + key)
    }
  }
}

///|
fn parse_network(value : Json) -> Network raise StnError {
  guard value is Object(obj) else {
    raise StnError("invalid_input", "network must be an object")
  }
  fields(obj, ["timepoints", "constraints", "queries", "max_steps"])
  guard required(obj, "timepoints") is Array(ns) else {
    raise StnError("invalid_input", "timepoints must be an array")
  }
  guard required(obj, "constraints") is Array(cs) else {
    raise StnError("invalid_input", "constraints must be an array")
  }
  if ns.length() > 64 || cs.length() > 512 {
    raise StnError("limit_exceeded", "network size limit")
  }
  let names = ns.map(v => text(v, "timepoint"))
  let constraints : Array[Constraint] = []
  for v in cs {
    guard v is Object(c) else {
      raise StnError("invalid_input", "constraint must be an object")
    }
    fields(c, ["id", "from", "to", "lower", "upper"])
    constraints.push({
      id: text(required(c, "id"), "id"),
      from: text(required(c, "from"), "from"),
      to: text(required(c, "to"), "to"),
      lower: bound(c, "lower"),
      upper: bound(c, "upper"),
    })
  }
  network(names, constraints)
}

///|
fn number(value : Int64?) -> Json {
  match value {
    Some(v) => Json::number(v.to_double())
    None => Json::null()
  }
}

///|
/// One JSON request. Inconsistency is a valid result, while malformed input raises.
pub fn analyze(value : Json) -> Json raise StnError {
  let net = parse_network(value)
  guard value is Object(obj) else { abort("validated object") }
  let steps = match obj.get("max_steps") {
    None => 2000000
    Some(Number(v, ..)) if v >= 1.0 && v <= 10000000.0 && v.floor() == v =>
      v.to_int()
    _ =>
      raise StnError(
        "invalid_input", "max_steps must be an integer in 1..10000000",
      )
  }
  let queries : Array[(String, String)] = []
  match obj.get("queries") {
    None => ()
    Some(Array(qs)) => {
      if qs.length() > 256 {
        raise StnError("limit_exceeded", "at most 256 queries")
      }
      for q in qs {
        guard q is Object(q) else {
          raise StnError("invalid_input", "query must be an object")
        }
        fields(q, ["from", "to"])
        let a = text(required(q, "from"), "from")
        let b = text(required(q, "to"), "to")
        find_name(net.names, a) |> ignore
        find_name(net.names, b) |> ignore
        queries.push((a, b))
      }
    }
    _ => raise StnError("invalid_input", "queries must be an array")
  }
  match solve(net, max_steps=steps) {
    Feasible(solution) => {
      let assignment : Map[String, Json] = Map([])
      for (name, value) in solution.assignment() {
        assignment[name] = number(Some(value))
      }
      let ranges = queries.map(q => {
        let (lower, upper) = solution.bounds(q.0, q.1)
        Json::object(
          Map([
            ("from", Json::string(q.0)),
            ("to", Json::string(q.1)),
            ("lower", number(lower)),
            ("upper", number(upper)),
          ]),
        )
      })
      Json::object(
        Map([
          ("status", Json::string("feasible")),
          ("assignment", Json::object(assignment)),
          ("bounds", Json::array(ranges)),
        ]),
      )
    }
    Inconsistent(cycle) => {
      let edges = cycle.map(e => {
        Json::object(
          Map([
            ("id", Json::string(e.id)),
            ("from", Json::string(e.from)),
            ("to", Json::string(e.to)),
            ("bound", number(Some(e.bound))),
            ("side", Json::string(e.side)),
          ]),
        )
      })
      Json::object(
        Map([
          ("status", Json::string("inconsistent")),
          ("cycle", Json::array(edges)),
        ]),
      )
    }
  }
}

///|
fn error_json(code : String, message : String) -> Json {
  Json::object(
    Map([
      ("status", Json::string("error")),
      ("code", Json::string(code)),
      ("message", Json::string(message)),
    ]),
  )
}

///|
pub fn analyze_batch(requests : Json) -> Json raise StnError {
  guard requests is Array(items) else {
    raise StnError("invalid_input", "batch must be an array")
  }
  if items.length() > 64 {
    raise StnError("limit_exceeded", "at most 64 batch items")
  }
  Json::array(
    items.map(item => {
      analyze(item) catch {
        StnError(code, msg) => error_json(code, msg)
      }
    }),
  )
}

///|
/// Preflight bounds decoder work before delegating exact JSON grammar to core.
pub fn parse_json(source : String) -> Json raise StnError {
  if source.length() > 1048576 {
    raise StnError("limit_exceeded", "JSON exceeds 1 Mi UTF-16 units")
  }
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  let mut tokens = 0
  let mut string_units = 0
  for c in source.iter() {
    if quoted {
      string_units += 1
      if string_units > 256 {
        raise StnError(
          "limit_exceeded", "JSON string exceeds 256 source characters",
        )
      }
      if escaped {
        escaped = false
      } else if c == '\\' {
        escaped = true
      } else if c == '"' {
        quoted = false
      }
    } else {
      if c == '"' {
        quoted = true
        string_units = 0
      }
      if c == '{' || c == '[' {
        depth += 1
      }
      if c == '}' || c == ']' {
        depth -= 1
      }
      if c != ' ' && c != '\n' && c != '\r' && c != '\t' {
        tokens += 1
      }
      if depth > 16 || tokens > 200000 {
        raise StnError(
          "limit_exceeded", "JSON nesting or token budget exceeded",
        )
      }
    }
  }
  @json.parse(source, max_nesting_depth=16, reject_duplicate_keys=true) catch {
    _ => raise StnError("invalid_json", "invalid JSON text")
  }
}

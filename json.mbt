///|
fn text(value : Json, field : String) -> String raise StnError {
  guard value is String(s) else {
    raise StnError("invalid_input", field + " must be a string")
  }
  s
}

///|
fn required(obj : Map[String, Json], field : String) -> Json raise StnError {
  required_value(obj.get(field), field)
}

///|
fn required_value(value : Json?, field : String) -> Json raise StnError {
  guard value is Some(v) else {
    raise StnError("invalid_input", "missing field: " + field)
  }
  v
}

///|
fn bounded_integer(value : Json, min : Double, max : Double) -> Int32? {
  guard value is Number(n, repr~) && n >= min && n <= max && n.floor() == n else {
    return None
  }
  if repr is Some(source) && !integer_spelling(source) {
    return None
  }
  Some(n.to_int())
}

///|
/// An exponent makes the decimal integral when it moves the point to or
/// past the last nonzero digit. The parser checks the JSON number grammar.
fn integer_spelling(source : String) -> Bool {
  let length = source.length()
  if length == 0 || length > 1048576 {
    return false
  }
  let mut i = if source.at(0) == '-'.to_int().to_uint16() { 1 } else { 0 }
  let mut digits = 0
  let mut digits_before_point = -1
  let mut last_nonzero = 0
  while i < length {
    match source.at(i) {
      '0' => digits += 1
      '1'..<='9' => {
        digits += 1
        last_nonzero = digits
      }
      '.' => if digits_before_point < 0 { digits_before_point = digits }
      'e' | 'E' => break
      _ => return false
    }
    i += 1
  }
  if last_nonzero == 0 {
    return true
  }
  let digits_before_point = if digits_before_point < 0 {
    digits
  } else {
    digits_before_point
  }
  let needed = last_nonzero - digits_before_point
  if i == length {
    return needed <= 0
  }
  i += 1
  guard i < length else { return false }
  let sign = source.at(i).to_int()
  let negative = sign == '-'.to_int()
  if negative || sign == '+'.to_int() {
    i += 1
  }
  guard i < length else { return false }
  let mut exponent = 0
  while i < length {
    let digit = source.at(i).to_int() - '0'.to_int()
    if digit < 0 || digit > 9 {
      return false
    }
    // Saturation keeps even very long exponents in range.
    if exponent <= length {
      exponent = exponent * 10 + digit
    }
    i += 1
  }
  (if negative { -exponent } else { exponent }) >= needed
}

///|
fn bound(value : Json?, field : String) -> Int32? raise StnError {
  match value {
    None | Some(Null) => None
    Some(v) => {
      guard bounded_integer(v, -1000000.0, 1000000.0) is Some(n) else {
        raise StnError(
          "invalid_input",
          field + " must be null or an integer in -1000000..1000000",
        )
      }
      Some(n)
    }
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
fn parse_constraint(value : Json) -> Constraint raise StnError {
  guard value is Object(obj) else {
    raise StnError("invalid_input", "constraint must be an object")
  }
  let id = obj.get("id")
  let from = obj.get("from")
  let to = obj.get("to")
  let lower = obj.get("lower")
  let upper = obj.get("upper")
  let bound_keys = (if lower is Some(_) { 1 } else { 0 }) +
    (if upper is Some(_) { 1 } else { 0 })
  // A present null bound still occupies a key. Other shapes need an ordered scan.
  if id is None || from is None || to is None || obj.length() != 3 + bound_keys {
    fields(obj, ["id", "from", "to", "lower", "upper"])
  }
  // Unknown keys take precedence, then values are checked in schema order.
  {
    id: text(required_value(id, "id"), "id"),
    from: text(required_value(from, "from"), "from"),
    to: text(required_value(to, "to"), "to"),
    lower: bound(lower, "lower"),
    upper: bound(upper, "upper"),
  }
}

///|
fn parse_network(value : Json) -> (Network, Map[String, Int32]) raise StnError {
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
    constraints.push(parse_constraint(v))
  }
  network_with_index(names, constraints)
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
  let (net, index) = parse_network(value)
  guard value is Object(obj) else { abort("validated object") }
  let steps = match obj.get("max_steps") {
    None => 2000000
    Some(v) => {
      guard bounded_integer(v, 1.0, 10000000.0) is Some(n) else {
        raise StnError(
          "invalid_input", "max_steps must be an integer in 1..10000000",
        )
      }
      n
    }
  }
  let queries : Array[(Int32, Int32)] = []
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
        let (a, b) = if q.length() == 2 &&
          q.get("from") is Some(from) &&
          q.get("to") is Some(to) {
          (text(from, "from"), text(to, "to"))
        } else {
          fields(q, ["from", "to"])
          (text(required(q, "from"), "from"), text(required(q, "to"), "to"))
        }
        let from = lookup_name(index, a)
        let to = lookup_name(index, b)
        queries.push((from, to))
      }
    }
    _ => raise StnError("invalid_input", "queries must be an array")
  }
  let arcs = arcs_with_index(net, index)
  match solve_indexed(net, arcs, steps) {
    Feasible(solution) => {
      let assignment : Map[String, Json] = Map([])
      for (name, value) in solution.assignment() {
        assignment[name] = number(Some(value))
      }
      let ranges = queries.map(q => {
        let (from, to) = q
        let (lower, upper) = solution.bounds_at(from, to)
        Json::object(
          Map([
            ("from", Json::string(net.names[from])),
            ("to", Json::string(net.names[to])),
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
  for c in source {
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
  @json.parse(
    source,
    max_nesting_depth=16,
    reject_duplicate_keys=true,
    preserve_number_repr=true,
  ) catch {
    _ => raise StnError("invalid_json", "invalid JSON text")
  }
}

///|
extern "js" fn now() -> Double =
  #|() => performance.now()

///|
extern "js" fn shape() -> String =
  #|() => process.argv[2]

///|
fn shared_resource(case_name : String, i : Int32) -> String? {
  match case_name {
    "independent" => None
    "first-pair" if i < 2 => Some("pair")
    "last-pair" if i >= 22 => Some("pair")
    "four-resources" => Some((i / 6).to_string())
    "one-resource" | "max-model" => Some("shared")
    _ => Some(i.to_string())
  }
}

///|
fn benchmark_construction(case_name : String) -> Unit raise {
  let n = if case_name.has_prefix("construct-small") { 2 } else { 24 }
  let id_length = match case_name {
    "construct-id-8" => 8
    "construct-id-16" => 16
    "construct-id-32" => 32
    _ => 0
  }
  let tasks : Array[@stn.Task] = Array::makei(n, i => {
    let digits = i.to_string()
    let id = if case_name == "construct-long" {
      "task-" + "x".repeat(57) + digits
    } else if id_length > 0 {
      "x".repeat(id_length - digits.length()) + digits
    } else {
      digits
    }
    {
      id,
      min_duration: 1,
      max_duration: 1,
      release: 0,
      deadline: 24,
      resource: None,
    }
  })
  let dependency_count = match case_name {
    "construct-small-none" | "construct-large-none" => 0
    "construct-small-linked" => 1
    _ => 64
  }
  let dependencies : Array[@stn.Dependency] = Array::makei(dependency_count, i => {
    let (before, after) = if case_name == "construct-early" || n == 2 {
      (0, 1)
    } else {
      (i % n, (i * 7 + 3) % n)
    }
    {
      before: tasks[before].id,
      after: if case_name == "construct-late-unknown" && i == 63 {
        "missing-after"
      } else {
        tasks[after].id
      },
      kind: "SS",
      min_lag: -24,
      max_lag: Some(24),
    }
  })
  for sample = 0; sample < 12; sample = sample + 1 {
    let start = now()
    let mut rules = 0
    let mut errors = 0
    for _i = 0; _i < 1000; _i = _i + 1 {
      try {
        let problem = @stn.planning_problem(tasks, dependencies)
        rules += problem.rules.length()
      } catch {
        @stn.StnError("invalid_input", "unknown task: missing-after") =>
          errors += 1
        e => raise e
      }
    }
    let ms = now() - start
    if case_name == "construct-late-unknown" {
      assert_eq((rules, errors), (0, 1000))
    } else {
      assert_eq((rules, errors), ((3 * n + dependency_count) * 1000, 0))
    }
    if sample >= 3 {
      println(
        ms.to_string() + "," + rules.to_string() + "," + errors.to_string(),
      )
    }
  }
}

///|
fn main raise {
  let case_name = shape()
  if case_name.has_prefix("construct-") {
    benchmark_construction(case_name)
    return
  }
  let tasks : Array[@stn.Task] = if case_name == "maintenance" {
    [
      {
        id: "backup",
        min_duration: 2,
        max_duration: 2,
        release: 0,
        deadline: 6,
        resource: Some("db"),
      },
      {
        id: "migration",
        min_duration: 3,
        max_duration: 3,
        release: 0,
        deadline: 3,
        resource: Some("db"),
      },
    ]
  } else {
    Array::makei(24, i => {
      id: i.to_string(),
      min_duration: 1,
      max_duration: 1,
      release: 0,
      deadline: 24,
      resource: shared_resource(case_name, i),
    })
  }
  let dependencies : Array[@stn.Dependency] = []
  if case_name == "max-root" || case_name == "max-model" {
    for i = 0; i < 24 && dependencies.length() < 64; i = i + 1 {
      for j = i + 1; j < 24 && dependencies.length() < 64; j = j + 1 {
        dependencies.push({
          before: tasks[i].id,
          after: tasks[j].id,
          kind: "SS",
          min_lag: -24,
          max_lag: Some(24),
        })
      }
    }
  }
  let p = @stn.planning_problem(tasks, dependencies)
  for sample = 0; sample < 12; sample = sample + 1 {
    let start = now()
    let mut work = 0L
    let mut checksum = 0L
    for _i = 0; _i < 500; _i = _i + 1 {
      guard @stn.plan(p, max_work=100000000) is @stn.Planned(s, stats) else {
        fail("expected a plan")
      }
      work += stats.charged_work.to_int64()
      let last = s[s.length() - 1]
      checksum += s[0].start + last.start + last.finish
    }
    let ms = now() - start
    if sample >= 3 {
      println(
        ms.to_string() + "," + work.to_string() + "," + checksum.to_string(),
      )
    }
  }
}

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
fn main raise {
  let case_name = shape()
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

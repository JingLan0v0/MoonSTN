///|
extern "js" fn now() -> Double =
  #|() => performance.now()

///|
extern "js" fn shape() -> String =
  #|() => process.argv[2]

///|
fn shared_resource(case_name : String, i : Int) -> String? {
  match case_name {
    "independent" => None
    "first-pair" if i < 2 => Some("pair")
    "last-pair" if i >= 22 => Some("pair")
    "four-resources" => Some((i / 6).to_string())
    "one-resource" => Some("shared")
    _ => Some(i.to_string())
  }
}

///|
fn main raise {
  let case_name = shape()
  let p = @stn.planning_problem(
    Array::makei(24, i => {
      id: i.to_string(),
      min_duration: 1,
      max_duration: 1,
      release: 0,
      deadline: 24,
      resource: shared_resource(case_name, i),
    }),
    [],
  )
  for sample = 0; sample < 12; sample = sample + 1 {
    let start = now()
    let mut work = 0L
    let mut checksum = 0L
    for _i = 0; _i < 500; _i = _i + 1 {
      guard @stn.plan(p, max_work=100000000) is @stn.Planned(s, stats) else {
        fail("expected a plan")
      }
      work += stats.charged_work.to_int64()
      checksum += s[0].start + s[23].start + s[23].finish
    }
    let ms = now() - start
    if sample >= 3 {
      println(ms.to_string() + "," + work.to_string() + "," + checksum.to_string())
    }
  }
}

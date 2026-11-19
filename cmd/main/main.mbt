///|
fn main {
  initialize_output()
  let args = arguments()
  if args.length() == 1 && args[0] == "--version" {
    write_stdout(@stn.version() + "\n")
    return
  }
  if args.length() == 1 && args[0] == "--help" {
    write_stdout(
      "moon-stn [--batch|--plan|--plan-batch] <request.json|->\nTimes are integer offsets in caller-chosen units.\n",
    )
    return
  }
  let planning = args.length() == 2 &&
    (args[0] == "--plan" || args[0] == "--plan-batch")
  let batch = args.length() == 2 &&
    (args[0] == "--batch" || args[0] == "--plan-batch")
  if !(args.length() == 1 || batch || planning) {
    write_stderr(
      "usage: moon-stn [--batch|--plan|--plan-batch] <request.json|->\n",
    )
    set_exit(2)
    return
  }
  let path = args[if batch || planning { 1 } else { 0 }]
  if path != "-" && path.has_prefix("-") {
    write_stderr("invalid option\n")
    set_exit(2)
    return
  }
  let input = read_utf8(path)
  if input[0] != "" {
    write_stderr("io: " + input[0] + "\n")
    set_exit(2)
    return
  }
  try {
    let value = @stn.parse_json(input[1])
    let result = if planning {
      if batch {
        @stn.analyze_plan_batch(value)
      } else {
        @stn.analyze_plan(value)
      }
    } else if batch {
      @stn.analyze_batch(value)
    } else {
      @stn.analyze(value)
    }
    let output = if planning {
      result.stringify()
    } else {
      numeric_output(result)
    }
    write_stdout(output + "\n")
  } catch {
    @stn.StnError(code, message) => {
      write_stderr(code + ": " + message + "\n")
      set_exit(2)
    }
  }
}

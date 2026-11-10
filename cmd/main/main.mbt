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
      "moon-stn [--batch] <request.json|->\nTimes are integer offsets in caller-chosen units.\n",
    )
    return
  }
  let batch = args.length() == 2 && args[0] == "--batch"
  if !(args.length() == 1 || batch) {
    write_stderr("usage: moon-stn [--batch] <request.json|->\n")
    set_exit(2)
    return
  }
  let path = args[if batch { 1 } else { 0 }]
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
    let result = if batch {
      @stn.analyze_batch(value)
    } else {
      @stn.analyze(value)
    }
    write_stdout(result.stringify() + "\n")
  } catch {
    @stn.StnError(code, message) => {
      write_stderr(code + ": " + message + "\n")
      set_exit(2)
    }
  }
}

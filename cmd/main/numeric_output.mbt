///|
fn numeric_output(result : Json) -> String {
  let buf = StringBuilder()
  write_numeric_value(buf, result)
  buf.to_string()
}

///|
// Only numeric responses built by the CLI analyzer reach this writer.
// Their schema bounds the depth of the generated result tree.
fn write_numeric_value(buf : StringBuilder, value : Json) -> Unit {
  match value {
    Object(fields) => {
      buf.write_char('{')
      let mut first = true
      for key, field_value in fields {
        if !first {
          buf.write_char(',')
        }
        first = false
        write_quoted_result_string(buf, key)
        buf.write_char(':')
        write_numeric_value(buf, field_value)
      }
      buf.write_char('}')
    }
    Array(items) => {
      buf.write_char('[')
      for i, item in items {
        if i > 0 {
          buf.write_char(',')
        }
        write_numeric_value(buf, item)
      }
      buf.write_char(']')
    }
    String(text) => write_quoted_result_string(buf, text)
    Number(number, repr~) =>
      match repr {
        None => buf.write_object(number)
        Some(text) => buf.write_string(text)
      }
    Null => buf.write_string("null")
    True => buf.write_string("true")
    False => buf.write_string("false")
  }
}

///|
fn write_quoted_result_string(buf : StringBuilder, text : String) -> Unit {
  for i = 0; i < text.length(); i = i + 1 {
    let c = text[i]
    if c < ' ' || c == '"' || c == '\\' {
      buf.write_string(Json::string(text).stringify())
      return
    }
  }
  buf.write_char('"')
  buf.write_string(text)
  buf.write_char('"')
}

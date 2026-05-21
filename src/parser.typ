// src/parser.typ
// String → token array conversion
//
// Token schema:
//   (type: "char", text: <single character>)
//   (type: "newline", text: "\n")
//   (type: "tcy", text: <Latin/number run>)

/// Tests whether a character cluster is an ASCII Latin letter or digit.
///
/// - ch (str): A single character cluster.
/// -> bool
#let is-tcy-char(ch) = {
  ch.match(regex("^[A-Za-z0-9]+$")) != none
}

/// Splits an input string into an array of tokens.
/// - Newline characters → type "newline"
/// - Consecutive ASCII Latin/digit runs → type "tcy"
/// - Everything else → type "char" (one per cluster)
///
/// - input (str): The string to tokenize.
/// -> array: Array of token dictionaries.
#let tokenize(input) = {
  if input == "" {
    return ()
  }

  let tokens = ()
  let tcy-buf = ""

  for ch in input.clusters() {
    if ch == "\n" {
      // Flush any pending TCY buffer
      if tcy-buf != "" {
        tokens.push((type: "tcy", text: tcy-buf))
        tcy-buf = ""
      }
      tokens.push((type: "newline", text: "\n"))
    } else if is-tcy-char(ch) {
      // Accumulate Latin/digit run
      tcy-buf += ch
    } else {
      // Flush any pending TCY buffer
      if tcy-buf != "" {
        tokens.push((type: "tcy", text: tcy-buf))
        tcy-buf = ""
      }
      tokens.push((type: "char", text: ch))
    }
  }

  // Flush trailing TCY buffer
  if tcy-buf != "" {
    tokens.push((type: "tcy", text: tcy-buf))
  }

  tokens
}

#import "@preview/cjk-spacer:0.2.1": cjk-spacer

#show: cjk-spacer

#let text = [これにより、文庫本や新聞のような、美しい二段組み（あるいは三段組み）のレイアウトをTypst上でネイティブに実現することができます。]

#let print-ast(c) = {
  if type(c) == array {
    for child in c {
      print-ast(child)
    }
  } else if type(c) == str {
    "STR(" + c + ")"
  } else if type(c) == content {
    let fname = repr(c.func())
    let out = "ELEMENT[" + fname + "]("
    if c.has("children") {
      out += print-ast(c.children)
    } else if c.has("body") {
      out += print-ast(c.body)
    } else if c.has("text") {
      out += "TEXT:" + c.text
    } else {
      out += "OTHER"
    }
    out + ")"
  }
}

#let out = print-ast(text)
#set page(width: auto, height: auto)
#out

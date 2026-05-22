// combined-debug.typ — All debug-*.typ files merged for visual debugging
// Generated from: debug.typ, debug-cjk.typ, debug-cols.typ, debug-eq.typ,
//   debug-font.typ, debug-heading.typ, debug-layout.typ, debug-math.typ, debug-spacing.typ
#set page(width: auto, height: auto)
#set text(font: "Harano Aji Mincho")

=== Source: debug.typ — Config check
#import "/src/config.typ": default-opts, merge-config
#let cfg = merge-config(default-opts, (:))
Config OK. Top-level keys: #repr(cfg.keys())

=== Source: debug-cjk.typ — CJK Spacer AST inspection

#import "@preview/cjk-spacer:0.2.1": cjk-spacer
#show: cjk-spacer
#let text-debug = [これにより、文庫本や新聞のような、美しい二段組み（あるいは三段組み）のレイアウトをTypst上でネイティブに実現することができます。]
#let print-ast(c) = {
  if type(c) == array {
    let out = ""
    for child in c {
      out += print-ast(child)
    }
    out
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
#let out-debug = print-ast(text-debug)
#raw(out-debug)

=== Source: debug-cols.typ — Basic tate columns
#set page(width: 300pt, height: 400pt, margin: 10pt)
#import "../lib.typ": tate
#tate[
  = 吾輩は猫である
  == 第一章
  吾輩（わがはい）は猫である。名前はまだ無い。
]
#tate[
  = ポラーノの広場
  == 第一章
  あのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモリーオ市、郊外のぎらぎらひかる草の波。
]

#pagebreak()
=== Source: debug-eq.typ — Figure detection
#let test-eq(c) = {
  if repr(c.func()) == "figure" {
    [Is figure! ]
  } else {
    [Not a figure]
  }
}
#test-eq(figure(rect()))

#pagebreak()
=== Source: debug-font.typ — Font measurement
#set text(font: "Arial", size: 10pt)
#context {
  let m1 = measure(text("Testing")).width
  let m2 = measure(text(font: "Courier", size: 20pt, "Testing")).width
  [Arial "Testing" width: #m1, Courier 20pt "Testing" width: #m2]
}

#pagebreak()
=== Source: debug-heading.typ — Heading fields
#let test-heading(c) = {
  [Heading fields: #repr(c.fields())]
}
#test-heading(heading(level: 1, "Heading"))

#pagebreak()
=== Source: debug-math.typ — Math content detection
#let check-math(c) = {
  if type(c) == content {
    [Type is: #repr(c.func())]
    [Fields: #repr(c.fields())]
  }
}
#check-math($a$)

#pagebreak()
=== Source: debug-spacing.typ — Place/context spacing
#set page(width: 200pt, height: 150pt, margin: 10pt)
#set text(size: 12pt)
#place(top + left, rect(width: 5pt, height: 130pt, fill: red))
#place(context {
  layout(size => {})
})
#context {
  align(right + top, rect(width: 12pt, height: 120pt, fill: blue.lighten(50%)))
}

#pagebreak()
=== Source: debug-layout.typ — Layout pagination debug
#set page(width: 300pt, height: 200pt, margin: 10pt)
#import "../src/flatten.typ": flatten
#import "../src/layout.typ": paginate
#import "../src/kinsoku.typ": default-resolver
#import "../src/config.typ": default-opts
#let text-layout = [
  これは縦書きにおける段組み（水平分割）のテストです。西洋の横書きレイアウトでは、段組みはページを左右に分割しますが、日本の伝統的な縦書きでは、ページを上下に分割します。
  このテキストは、まず上段を右から左に向かって埋めていきます。そして上段がいっぱいになると、自動的に下段の右端へとシームレスに移動して配置されます。これにより、文庫本や新聞のような、美しい二段組み（あるいは三段組み）のレイアウトをTypst上でネイティブに実現することができます。
]
#let tokens-debug = flatten(text-layout, default-opts)
#let heights = tokens-debug.map(token => {
  if token.type == "newline" { 0pt } else { 12pt }
})
#let max-height = 105pt
#let cfg-debug = (kinsoku: default-resolver(), char-box-abs: 12pt)
#let cols = paginate(tokens-debug, heights, max-height, cfg-debug)
#let out = ""
#for (i, col) in cols.enumerate() {
  out += "Col " + str(i + 1) + ": "
  for t in col {
    out += t.text
  }
  out += "\n"
}
#raw(out)

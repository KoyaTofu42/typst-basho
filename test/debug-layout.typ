#import "../src/flatten.typ": flatten
#import "../src/layout.typ": paginate
#import "../src/kinsoku.typ": default-resolver
#import "../src/config.typ": default-opts

#let text = [
  これは縦書きにおける段組み（水平分割）のテストです。西洋の横書きレイアウトでは、段組みはページを左右に分割しますが、日本の伝統的な縦書きでは、ページを上下に分割します。

  このテキストは、まず上段を右から左に向かって埋めていきます。そして上段がいっぱいになると、自動的に下段の右端へとシームレスに移動して配置されます。これにより、文庫本や新聞のような、美しい二段組み（あるいは三段組み）のレイアウトをTypst上でネイティブに実現することができます。
]

#let tokens = flatten(text, default-opts)

#let heights = tokens.map(token => {
  if token.type == "newline" {
    0pt
  } else {
    12pt
  }
})

#let max-height = 105pt

// Minimal config for kinsoku
#let cfg = (
  kinsoku: default-resolver(),
  char-box-abs: 12pt,
)

#let cols = paginate(tokens, heights, max-height, cfg)

#let debug-out = ""
#for (i, col) in cols.enumerate() {
  debug-out += "Col " + str(i + 1) + ": "
  for t in col {
    debug-out += t.text
  }
  debug-out += "\n"
}

#panic(debug-out)

#import "../src/flatten.typ": flatten
#import "../src/layout.typ": paginate, apply-kinsoku
#import "../src/renderer.typ": render-char-token

#let text = [
  これは縦書きにおける段組み（水平分割）のテストです。西洋の横書きレイアウトでは、段組みはページを左右に分割しますが、日本の伝統的な縦書きでは、ページを上下に分割します。

  このテキストは、まず上段を右から左に向かって埋めていきます。そして上段がいっぱいになると、自動的に下段の右端へとシームレスに移動して配置されます。これにより、文庫本や新聞のような、美しい二段組み（あるいは三段組み）のレイアウトをTypst上でネイティブに実現することができます。
]

#let tokens = flatten(text)

#let heights = tokens.map(token => {
  if token.type == "newline" {
    0pt
  } else {
    12pt
  }
})

#let max-height = 105pt

#let cols = apply-kinsoku(paginate(tokens, heights, max-height))

#let debug-out = ""
#for (i, col) in cols.enumerate() {
  debug-out += "Col " + str(i + 1) + ": "
  for t in col {
    debug-out += t.text
  }
  debug-out += "\n"
}

#panic(debug-out)

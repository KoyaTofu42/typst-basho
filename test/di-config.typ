#import "../lib.typ": tate, tcy
#import "../src/config.typ": default-opts

#set page(width: 10cm, height: 10cm)

// 1. A middleware that changes "ー" to "〜"
#let mw-tilde(tokens, config) = {
  tokens.map(t => {
    if t.type == "char" and t.text == "ー" {
      t.text = "〜"
    }
    t
  })
}

// 2. A custom node renderer for "warichu" (split notes)
#let render-warichu(token, font, config) = {
  box(
    width: config.sizing.char-box,
    height: config.sizing.char-box,
    align(center + horizon)[
      #text(font: font, size: 0.5em, features: config.features, token.text)
    ],
  )
}

// 3. A macro that inserts a "warichu" token
#let warichu(body) = metadata((type: "warichu", text: body))

= Default

#tate(
  columns: 2,
  [
    スーパーで。#warichu("注釈")これは#tcy("Test")です！
  ],
)

#pagebreak()
= With DI Config

#tate(
  columns: 2,
  config: (
    middleware: (mw-tilde,),
    node-renderers: (warichu: render-warichu),
    sizing: (
      tcy-sizes: (1.2em, 0.8em, 0.6em), // larger TCY
    ),
    kinsoku: (
      mode: "oikomi", // oikomi for closing chars
      forbidden-start: "。！",
    ),
  ),
  [
    スーパーで。
    #warichu("注釈")
    これは#tcy("Test")です！
  ],
)

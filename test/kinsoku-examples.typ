// test/kinsoku-examples.typ
// Examples of customized kinsoku shori configurations.
// Each section applies the same test text with different kinsoku settings.
//
// Compile: typst compile --root . test/kinsoku-examples.typ /tmp/kinsoku-examples.pdf

#import "../lib.typ": ruby, tate
#import "../src/core/kinsoku.typ": calculate-shrinkable-space, default-resolver, is-forbidden-start, is-hanging

#set page(width: 10cm, height: 10cm)
#set text(font: "Harano Aji Mincho")

// Test text that triggers various kinsoku scenarios:
//   - hanging punctuation (。、)
//   - forbidden-start chars (）〕」)
//   - forbidden-end chars （〔「)
//   - unbreakable pairs (—— ……)
#let test_text = [
  = 禁則処理サンプル
  これは、禁則処理の動作を確認するためのテスト文です。（括弧）や「かぎかっこ」の扱い、句読点。、のぶら下がり、そして——や……のような連続記号——も含みます。
  さらに、）〕〕）のような行頭禁則文字が連続するケースや、（〔〔（のような行末禁則文字——が含まれるケースも検証します。
  あああああああああああああああああああああああああああああああああああああああああああああああああああああああいいいいいいいいいいいいいいいいいいいいいいいいいい。
]

// ---------------------------------------------------------------------------
// 1. Default — burasagari mode (no customization)
// ---------------------------------------------------------------------------
#tate(columns: 2)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 2. Custom hanging set — add ！ to hanging punctuation
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(hanging: "、。，．！"),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 3. Oikomi mode — compression instead of hanging
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(mode: "oikomi"),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 4. Oikomi with tighter compression
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(
      mode: "oikomi",
      compression-per-punct: 0.3,
      consecutive-compression: 0.15,
    ),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 5. Custom forbidden-start — only push on ）、】
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(forbidden-start: "）〕】"),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 6. Extended unbreakable pairs — add 「」 to the set
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(unbreakable-chars: "—―…‥「」"),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 7. Custom compressible punctuation — only compress 、。
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(
      mode: "oikomi",
      compressible-punctuation: "、。",
    ),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 8. Full replacement — custom resolve with built-in helpers
// Uses the built-in helpers but overrides the decision logic:
// always push-previous for any char that is not an ideograph.
// ---------------------------------------------------------------------------
#let custom-resolve-1(col, token, h, config, cur-h, max-h) = {
  if token.type == "char" {
    let is-ideograph = token.text.match(regex("^[\u{4e00}-\u{9fff}]$")) != none
    if is-ideograph {
      return (action: "oidashi")
    }
    return (action: "push-previous")
  }
  (action: "oidashi")
}

#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(resolve-fn: custom-resolve-1),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 9. Full replacement — ignore all kinsoku, always break normally
// ---------------------------------------------------------------------------
#let always-break(col, token, h, config, cur-h, max-h) = {
  (action: "oidashi")
}

#tate(
  columns: 2,
  config: (
    kinsoku: (resolve: always-break),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 10. Aggressive push-previous — push back to the start of the last CJK word
// ---------------------------------------------------------------------------
#let aggressive-push(col, token, h, config, cur-h, max-h) = {
  // Always push at least 3 chars back if the column is long enough
  if is-forbidden-start(token, config.kinsoku.forbidden-start) {
    return (action: "push-previous")
  }
  if col.len() >= 3 {
    return (action: "push-previous")
  }
  (action: "oidashi")
}

#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(resolve-fn: aggressive-push),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 11. Mixed — burasagari with custom sets + different compression params
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(
      mode: "burasagari",
      hanging: "、。，．！？",
      forbidden-start: "）〕］｝〉》」』】)]}〞\u{201d}\u{2019}。、，．・：；！？",
      forbidden-end: "（〔［｛〈《「『【([{〝\u{201c}\u{2018}",
    ),
  ),
)[
  #test_text
]

#pagebreak()

// ---------------------------------------------------------------------------
// 12. Oikomi with no consecutive compression bonus
// ---------------------------------------------------------------------------
#tate(
  columns: 2,
  config: (
    kinsoku: default-resolver(
      mode: "oikomi",
      consecutive-compression: 0,
    ),
  ),
)[
  #test_text
]

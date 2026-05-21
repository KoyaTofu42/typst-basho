// test/phase6.typ
// Phase 6 verification: Ruby (Furigana) - Complex Examples

#import "../src/layout.typ": render-tokens

#set page(width: 250pt, height: 250pt, margin: 10pt)
#set text(size: 12pt)

// Test 1: Standard ruby and long ruby
#let test-tokens-1 = (
  (type: "char", text: "東"),
  (type: "ruby", text: "京", ruby: "キョウ"), // standard ruby
  (type: "char", text: "都"),
  (type: "ruby", text: "庁", ruby: "チョウ"),
  (type: "newline", text: "\n"),
  (type: "char", text: "短"),
  (type: "char", text: "い"),
  (type: "char", text: "文"),
  (type: "newline", text: "\n"),
  (type: "ruby", text: "漢", ruby: "かん"),
  (type: "ruby", text: "字", ruby: "じ"),
)

#render-tokens(test-tokens-1, "Harano Aji Mincho")

#pagebreak()

// Test 2: Combined features (TCY + Kinsoku + Group Ruby)
#let test-tokens-2 = (
  (type: "char", text: "「"),
  // Grouped ruby for multiple kanji (prevents overlap)
  (type: "ruby", text: "昭和", ruby: "ショウワ"),
  (type: "tcy", text: "50"),
  (type: "char", text: "年"),
  (type: "char", text: "」"),
  (type: "char", text: "の"),
  // Grouped ruby again
  (type: "ruby", text: "記憶", ruby: "キオク"),
  (type: "char", text: "。"),
)

#render-tokens(test-tokens-2, "Harano Aji Mincho")

#pagebreak()

// Test 3: Empty ruby handling and specific multi-kanji words requested
#let test-tokens-3 = (
  (type: "char", text: "普"),
  (type: "char", text: "通"),
  (type: "char", text: "の"),
  (type: "ruby", text: "文", ruby: ""), // Empty ruby
  (type: "ruby", text: "字", ruby: none), // None ruby
  (type: "newline", text: "\n"),
  (type: "ruby", text: "今日", ruby: "きょう"), // 3 ruby chars on 2 kanji
  (type: "char", text: "は"),
  (type: "char", text: "晴"),
  (type: "char", text: "天"),
)

#render-tokens(test-tokens-3, "Harano Aji Mincho")

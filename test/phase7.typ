// test/phase7.typ
// Phase 7 verification: Content Flattener & API Finalization

#import "../lib.typ": ruby, tate, tcy

#set page(width: 300pt, height: 250pt, margin: 10pt)
#set text(size: 12pt)

// We can now use native Typst markup inside tate!
#tate[
  「#ruby("昭和", "ショウワ")#tcy("50")年の記憶」

  今日は*とても*良い天気ですね。

  長い#ruby("漢字", "かんじ")も、問題なくレンダリングされます。

  自動的に123も横書きになります。
]

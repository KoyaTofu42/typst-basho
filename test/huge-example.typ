#import "../lib.typ": burasagari, hblock, oikomi, ruby, tate, tcy, turn, vblock

#set page(width: 320pt, height: 460pt, margin: 12pt)
#set text(font: "Harano Aji Mincho", size: 11pt)
#set par(justify: true)

#tate[
  = aaaa #turn[Basho]

  この文書は、#turn[Basho]パッケージの大規模なレンダリングテスト用のサンプルです。Typstの一般的なマークアップと、Bashoの公開 APIを組み合わせて、縦組みでの表示を幅広く確認します。

  この段落では、#strong[太字]、#emph[斜体]、#underline[下線]、#strike[取消線]、#overline[上線]、#highlight[強調] をまとめて確認する。

  また、#tcy("IT")と#tcy("ABCDE")のような短い英数字列も混在させ、三文字以上のTCYが分割される経路も見ておく。

  内側の式も確認する。行内は $x + y = z$、独立したブロック式は $sum_(k=1)^n k = n(n+1)/2$。

  さらに、#vblock[$f(x) = 1 / (1 + e^(-x))$] のような縦中の数式、#turn[CLI]のような回転文字、#hblock[#circle(radius: 10pt, fill: luma(60%))] のような横置きブロックも混ぜる。

  句読点と禁則の確認のために、（かっこ、）や「かぎかっこ」、そして……――――のような連続記号も入れる。ああ、ここで改行が必要になるくらい長く続けて、ぶら下がりと追い込みの差が出るようにしておく。

  = 第二節
  ここではTypstの通常の段落、改行、スペース、そして複数の文を続けて、縦組みの行送りをたくさん発生させる。日本語の長文は、縦書きでは右から左へ列が進み、禁則処理が効くはずだ。

  2026年の春には、42と#tcy("24")と#tcy("9999")が同じ文章に並ぶ。#tcy("9999")は長いので、内部フィルタで分割されることも確認できる。

  == 図形とブロック
  この節では、ブロック扱いされるTypstコンテンツを縦組みに入れる。パッケージ側では未対応ブロックを #hblock[...] として扱うので、横置きのまま落ちるかを見たい。

  #hblock[
    #stack(
      dir: ltr,
      spacing: 4pt,
      [
        #rect(width: 90pt, height: 24pt, fill: rgb("d8e8ff"), stroke: 0.5pt + rgb("4f6f9f"))
        #align(center)[サンプル矩形]
      ],
      [
        #circle(radius: 12pt, fill: rgb("ffd9c7"), stroke: 0.5pt + rgb("b86d43"))
        #align(center)[円形]
      ],
    )
  ]

  #vblock[
    #stack(
      dir: ttb,
      spacing: 3pt,
      [#rect(width: 40pt, height: 12pt, fill: rgb("c8f0d8"))],
      [#rect(width: 56pt, height: 12pt, fill: rgb("c8f0d8"))],
      [#rect(width: 72pt, height: 12pt, fill: rgb("c8f0d8"))],
    )
  ]

  #turn[
    #box(stroke: 0.5pt + black, inset: 4pt)[
      回転したラベル
    ]
  ]

  #ruby("縦書き", "たてがき")と#ruby("禁則処理", "きんそくしょり")をもう一度確認する。#strong[太字]と#emph[斜体]も同時に並べる。

  === 複合サンプル

  ここには、見出し、本文、英数字、記号、そして複数の Typst関数が一気に入る。

  - 箇条書き一
  - 箇条書き二
  - 箇条書き三

  1. 番号付き項目
  2. 番号付き項目
  3. 番号付き項目

  #table(
    columns: 3,
    align: center,
    [項目], [値], [備考],
    [TCY], [#tcy("88")], [短い数字列],
    [Ruby], [#ruby("漢字", "かんじ")], [ルビ付き],
  )

  #lorem(60)
]

#pagebreak()

= Kinsoku Modes

The next two blocks use the same content with different line-breaking presets so the output can be compared visually.

== Burasagari

#tate(
  columns: 2,
  column-gap: 10pt,
  config: (
    kinsoku: (burasagari,),
    layout: (gap: 1.1em, columns: 2, column-gap: 10pt),
  ),
)[
  これはぶら下がりの確認用の長文です。行末に来た「かぎかっこ」や（丸括弧）や、句読点、そして……のような連続記号が、列の端でどのように処理されるかを確認するために、あえて長く続けています。さらに、英数字の #tcy("2026") と #turn[PDF,]を混ぜて、縦組みの中での表示差も見ます。

  もう一段長く続けます。日本語の縦書きでは、列の高さが足りなくなったときに、禁則に応じて一文字押し出されたり、ぶら下がったりします。その挙動を観察するために、ここでは括弧、句読点、長音符、そして複数の句を連ねて、あえて折り返し位置を作っています。
]

== Oikomi

#tate(
  columns: 2,
  column-gap: 10pt,
  config: (
    kinsoku: (oikomi,),
    layout: (gap: 1.1em, columns: 2, column-gap: 10pt),
  ),
)[
  これは追い込みの確認用の長文です。行末に来た「かぎかっこ」や（丸括弧）や、句読点、そして……のような連続記号が、ぶら下がりではなく追い込み寄りに処理されるかを見ます。#ruby("追い込み", "おいこみ")の見え方も合わせて確認します。

  さらに、#hblock[#box(stroke: 0.5pt + gray, inset: 4pt)[横置きの注釈]] と #vblock[$integral_0^1 x^2 dif x$] を混ぜ、ブロック系のトークンが縦組みレイアウトでどう収まるかも確認します。

  ここでも長文を続けます。#tcy("2024")、#tcy("IT")、#tcy("12345")、#turn[GitHub, VS Code]のような短いラベルを連続させ、TCY の長さ分岐と回転表示の両方を走らせます。
]

== Final Stress

#tate(
  font: "Harano Aji Mincho",
  columns: 3,
  column-gap: 8pt,
  config: (
    sizing: (
      char-box: 1em,
      ruby-size: 0.45em,
      ruby-offset: 1.05em,
      heading-scales: (1.6, 1.35, 1.15),
    ),
    layout: (gap: 0.95em, columns: 3, column-gap: 8pt),
  ),
)[
  = 総合確認
  ここでは、#strong[総合テスト]、#emph[見た目]、#ruby("縦横", "たてよこ")、#tcy("OK")、#turn[RT]、#vblock[$a/b$]、#hblock[#rect(width: 24pt, height: 12pt, fill: rgb("b9d4ff"))] を一度にまとめて確認する。

  行の中には、ひらがな、カタカナ、漢字、アルファベット、数字、記号、句読点、括弧、そして長い文章を詰め込む。これで、文字種ごとのレンダリングと列送りの両方を広く試せる。

  == 終わりに
  Bashoの public APIは少ないが、Typst側の組み合わせは多い。#lorem(40)
]
